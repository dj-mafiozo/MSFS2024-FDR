{$StackFrames On}
Unit ViewStateU;

Interface

 Uses
  System.Classes, System.SysUtils, System.IniFiles, System.Types,
  System.Generics.Collections, Vcl.Forms;

 Type
  TViewStateEntry = Class
   ID     : String;
   Toggle : TNotifyEvent;
   Window : TForm;
  End;

// The configuration remains owned by the caller and must outlive this store.

  TViewStateStore = Class
   Private
    fConfig       : TCustomIniFile;
    fEntries      : TObjectList<TViewStateEntry>;
    fShuttingDown : Boolean;
    fRestored     : Boolean;
    Function Find(Const ID : String) : TViewStateEntry;
    Function Section(Const ID : String) : String;
    Procedure SaveGeometry(Entry : TViewStateEntry);
    Procedure RestoreGeometry(Entry : TViewStateEntry);
    Procedure RestoreDockHost(Entry : TViewStateEntry);
    Procedure Flush;
   Public
    Constructor Create(Config : TCustomIniFile);
    Destructor Destroy; Override;
    Procedure RegisterView(Const ID : String; Toggle : TNotifyEvent);
    Procedure Restore;
    Procedure Opened(Const ID : String; Window : TForm);
    Procedure Returned(Const ID : String);
    Procedure BeginShutdown;
    Procedure Reset;
  End;

Implementation

 Uses
  Winapi.Windows, System.Math, Vcl.Controls;

 Constructor TViewStateStore.Create(Config : TCustomIniFile);
  Begin
   Inherited Create;
   If Config = Nil Then
    Raise EArgumentNilException.Create('Config');
   fConfig  := Config;
   fEntries := TObjectList<TViewStateEntry>.Create(True);
  End;

 Destructor TViewStateStore.Destroy;
  Begin
   fEntries.Free;
   Inherited;
  End;

 Function TViewStateStore.Section(Const ID : String) : String;
  Begin
   Result := 'view.' + ID;
  End;

 Function TViewStateStore.Find(Const ID : String) : TViewStateEntry;
  Var
   e : TViewStateEntry;
  Begin
   For e In fEntries Do
    If e.ID = ID Then
     Exit(e);
   Raise EArgumentException.Create('Unregistered view: ' + ID);
  End;

 Procedure TViewStateStore.RegisterView(Const ID : String; Toggle : TNotifyEvent);
  Var
   e : TViewStateEntry;
   c : Char;
  Begin
   If (ID = '') Or Not Assigned(Toggle) Then
    Raise EArgumentException.Create('View ID and toggle required');
   For c In ID Do
    If Not CharInSet(c, ['a'..'z', '0'..'9', '_', '-']) Then
     Raise EArgumentException.Create('Use a stable lowercase view ID: ' + ID);
   For e In fEntries Do
    If e.ID = ID Then
     Raise EArgumentException.Create('Duplicate view: ' + ID);
   e        := TViewStateEntry.Create;
   e.ID     := ID;
   e.Toggle := Toggle;
   fEntries.Add(e);
  End;

 Procedure TViewStateStore.Flush;
  Begin
   fConfig.UpdateFile;
  End;

 Procedure TViewStateStore.SaveGeometry(Entry : TViewStateEntry);
  Var
   b : TRect;
   p : TWindowPlacement;
   m : TMonitor;
   w : TForm;
   s : String;
  Begin
   w := Entry.Window;
   If w = Nil Then
    Exit;
   s := Section(Entry.ID);
   If w.HostDockSite <> Nil Then
    Begin
     fConfig.WriteString(s, 'dock_host', w.HostDockSite.Name);
     If w.DockOrientation = doVertical Then
      If w.Left < w.HostDockSite.ClientWidth Div 2 Then
       fConfig.WriteInteger(s, 'dock_align', Ord(alLeft))
      Else
       fConfig.WriteInteger(s, 'dock_align', Ord(alRight))
     Else If w.Top < w.HostDockSite.ClientHeight Div 2 Then
      fConfig.WriteInteger(s, 'dock_align', Ord(alTop))
     Else
      fConfig.WriteInteger(s, 'dock_align', Ord(alBottom));
     Exit; // Preserve the independent floating geometry.
    End;
   fConfig.WriteString(s, 'dock_host', '');
   b := w.BoundsRect;
   If w.HandleAllocated And (w.WindowState <> wsNormal) Then
    Begin
     FillChar(p, SizeOf(p), 0);
     p.Length := SizeOf(p);
     If GetWindowPlacement(w.Handle, @p) Then
      Begin
       b := p.rcNormalPosition;
       // WINDOWPLACEMENT uses workspace coordinates for normal top-level windows.
       m := Screen.MonitorFromWindow(w.Handle, mdNearest);
       If (GetWindowLong(w.Handle, GWL_EXSTYLE) And WS_EX_TOOLWINDOW) = 0 Then
        OffsetRect(b, m.WorkareaRect.Left - m.Left, m.WorkareaRect.Top - m.Top);
      End;
    End;
   s := Section(Entry.ID);
   fConfig.WriteInteger(s, 'left', b.Left);
   fConfig.WriteInteger(s, 'top', b.Top);
   fConfig.WriteInteger(s, 'width', b.Right - b.Left);
   fConfig.WriteInteger(s, 'height', b.Bottom - b.Top);
   fConfig.WriteInteger(s, 'ppi', Max(1, w.PixelsPerInch));
   fConfig.WriteBool(s, 'maximized', w.WindowState = wsMaximized);
  End;

 Procedure TViewStateStore.RestoreGeometry(Entry : TViewStateEntry);
  Var
   s      : String;
   b      : TRect;
   Work   : TRect;
   w      : TForm;
   Width  : Integer;
   Height : Integer;
   PPI    : Integer;
  Begin
   w := Entry.Window;
   s := Section(Entry.ID);
   If Not fConfig.ValueExists(s, 'width') Then
    Exit;
   b      := w.BoundsRect;
   b.Left := fConfig.ReadInteger(s, 'left', b.Left);
   b.Top  := fConfig.ReadInteger(s, 'top', b.Top);
   // Bound before scaling, so malformed INI values cannot overflow rectangle arithmetic.
   Width    := EnsureRange(fConfig.ReadInteger(s, 'width', w.Width), 100, 32767);
   Height   := EnsureRange(fConfig.ReadInteger(s, 'height', w.Height), 100, 32767);
   PPI      := EnsureRange(fConfig.ReadInteger(s, 'ppi', w.PixelsPerInch), 48, 768);
   Width    := EnsureRange(MulDiv(Width, Max(1, w.PixelsPerInch), PPI), 100, 32767);
   Height   := EnsureRange(MulDiv(Height, Max(1, w.PixelsPerInch), PPI), 100, 32767);
   b.Left   := EnsureRange(b.Left, -1000000, 1000000);
   b.Top    := EnsureRange(b.Top, -1000000, 1000000);
   b.Right  := b.Left + Width;
   b.Bottom := b.Top + Height;
   Work     := Screen.MonitorFromRect(b, mdNearest).WorkareaRect;
   Width    := Min(Max(Width, w.Constraints.MinWidth), Work.Width);
   Height   := Min(Max(Height, w.Constraints.MinHeight), Work.Height);
   If w.Constraints.MaxWidth > 0 Then
    Width := Min(Width, w.Constraints.MaxWidth);
   If w.Constraints.MaxHeight > 0 Then
    Height    := Min(Height, w.Constraints.MaxHeight);
   b.Left     := EnsureRange(b.Left, Work.Left, Work.Right - Width);
   b.Top      := EnsureRange(b.Top, Work.Top, Work.Bottom - Height);
   w.Position := poDesigned;
   w.SetBounds(b.Left, b.Top, Width, Height);
   If fConfig.ReadBool(s, 'maximized', False) Then
    w.WindowState := wsMaximized;
  End;

 Procedure TViewStateStore.RestoreDockHost(Entry : TViewStateEntry);
  Var
   c      : TComponent;
   Target : TWinControl;
   p      : TWinControl;
   Side   : Integer;
  Begin
   If (Entry.Window = Nil) Or (Entry.Window.Owner = Nil) Then
    Exit;
   c := Entry.Window.Owner.FindComponent(fConfig.ReadString(Section(Entry.ID), 'dock_host', ''));
   If Not(c Is TWinControl) Then
    Exit;
   Target := TWinControl(c);
   If Not Target.DockSite Or (Target = Entry.Window.HostDockSite) Then
    Exit;
   p := Target;
   While p <> Nil Do
    Begin
     If p = Entry.Window Then
      Exit;
     p := p.Parent;
    End;
   Side := fConfig.ReadInteger(Section(Entry.ID), 'dock_align', Ord(alClient));
   If (Side < Ord(Low(TAlign))) Or (Side > Ord(High(TAlign))) Then
    Side := Ord(alClient);
   Entry.Window.ManualDock(Target, Nil, TAlign(Side));
  End;

 Procedure TViewStateStore.Opened(Const ID : String; Window : TForm);
  Var
   e : TViewStateEntry;
  Begin
   e := Find(ID);
   If (Window = Nil) Or (e.Window <> Nil) Then
    Raise EArgumentException.Create('View already open or nil: ' + ID);
   If (Window.Owner <> Nil) And (Window.Owner.FindComponent('View_' + ID) <> Nil) And (Window.Owner.FindComponent('View_' + ID) <> Window) Then
    Window.Owner.FindComponent('View_' + ID).Name := ''; // Previous caFree window may await its release message.
   Window.Name                                    := 'View_' + ID;
   e.Window                                       := Window;
   Try
    RestoreGeometry(e);
    RestoreDockHost(e);
    If Not fShuttingDown Then
     Begin
      fConfig.WriteBool(Section(ID), 'detached', True);
      Flush;
     End;
   Except
    e.Window := Nil;
    Raise;
   End;
  End;

 Procedure TViewStateStore.Returned(Const ID : String);
  Var
   e : TViewStateEntry;
  Begin
   e := Find(ID);
   If e.Window = Nil Then
    Exit;
   Try
    If Not fShuttingDown Then
     Begin
      SaveGeometry(e);
      fConfig.WriteBool(Section(ID), 'detached', False);
      Flush;
     End;
   Finally
    e.Window := Nil;
   End;
  End;

 Procedure TViewStateStore.Restore;
  Var
   e : TViewStateEntry;
  Begin
   If fRestored Or fShuttingDown Then
    Exit;
   fRestored := True;
   For e In fEntries Do
    If (e.Window = Nil) And fConfig.ReadBool(Section(e.ID), 'detached', False) Then
     e.Toggle(Self);
   For e In fEntries Do
    RestoreDockHost(e);
  End;

 Procedure TViewStateStore.BeginShutdown;
  Var
   e : TViewStateEntry;
  Begin
   If fShuttingDown Then
    Exit;
   // Snapshot before forms return their frames during destruction.
   For e In fEntries Do
    Begin
     SaveGeometry(e);
     fConfig.WriteBool(Section(e.ID), 'detached', e.Window <> Nil);
    End;
   fShuttingDown := True;
   Flush;
  End;

 Procedure TViewStateStore.Reset;
  Var
   e : TViewStateEntry;
  Begin
   If fShuttingDown Then
    Exit;
   fShuttingDown := True;
   Try
    For e In fEntries Do
     If e.Window <> Nil Then
      e.Window.Close;
    For e In fEntries Do
     fConfig.EraseSection(Section(e.ID));
    Flush;
   Finally
    fShuttingDown := False;
   End;
  End;

End.
