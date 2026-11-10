Unit frmDockViewU;

Interface

 Uses
  System.Classes, System.IniFiles, System.Types, Vcl.Forms, Vcl.Controls, Vcl.ComCtrls;

 Type
  TfrmDockView = Class(TForm)
    Procedure FitClient(Sender : TObject);
    Procedure StartDockPreview(Sender : TObject; Var DragObject : TDragDockObject);
    Procedure FormClose(Sender : TObject; Var Action : TCloseAction);
   Private
    fFitting     : Boolean;
    fFloatBounds : TRect;
    fPage        : TTabSheet;
    fHome        : TPageControl;
   Public
    Procedure Dock(NewDockSite : TWinControl; ARect : TRect); Override;
    Procedure Attach(Page : TTabSheet; Home : TPageControl);
    Procedure Toggle;
    Procedure Restore(Config : TCustomIniFile);
    Procedure Save(Config : TCustomIniFile);
    Procedure ReleasePage;
    Property Page : TTabSheet Read fPage;
  End;

 Procedure SaveDockTree(Host : TWinControl; Config : TCustomIniFile);
 Procedure RestoreDockTree(Host : TWinControl; Config : TCustomIniFile);

Implementation

 Uses
  DockPreviewU, System.SysUtils, System.NetEncoding, System.Math, Vcl.ExtCtrls;
{$R *.dfm}

 Procedure SaveDockTree(Host : TWinControl; Config : TCustomIniFile);
  Var
   m : TMemoryStream;
   b : TBytes;
  Begin
   If Host.DockManager = Nil Then
    Exit;
   m := TMemoryStream.Create;
   Try
    Host.DockManager.SaveToStream(m);
    SetLength(b, m.Size);
    If Length(b) > 0 Then
     Move(m.Memory^, b[0], Length(b));
    Config.WriteString('dock.tree', Host.Name, TNetEncoding.Base64.EncodeBytesToString(b));
   Finally
    m.Free;
   End;
  End;

 Procedure RestoreDockTree(Host : TWinControl; Config : TCustomIniFile);
  Var
   m : TBytesStream;
   b : TBytes;
   s : String;
  Begin
   s := Config.ReadString('dock.tree', Host.Name, '');
   If (s = '') Or (Length(s) > 1048576) Or (Host.DockManager = Nil) Then
    Exit;
   Try
    b := TNetEncoding.Base64.DecodeStringToBytes(s);
    m := TBytesStream.Create(b);
    Try
     Host.DockManager.LoadFromStream(m);
    Finally
     m.Free;
    End;
   Except
    // Invalid local layout never prevents application startup.
    Config.DeleteKey('dock.tree', Host.Name);
   End;
  End;

 Procedure TfrmDockView.FitClient(Sender : TObject);
  Begin
   If fFitting Or (fPage = Nil) Or (csDestroying In ComponentState) Then
    Exit;
   fFitting := True;
   Try
    // Tab hosts own the full client rectangle; side DockManagers own their zones.
    If (HostDockSite Is TPageControl) And (Parent Is TTabSheet) Then
     Begin
      Align := alClient;
      If (Width <> Parent.ClientWidth) Or (Height <> Parent.ClientHeight) Or (Left <> 0) Or (Top <> 0) Then
       SetBounds(0, 0, Parent.ClientWidth, Parent.ClientHeight);
     End;
    fPage.Align := alClient;
    If (fPage.Width <> ClientWidth) Or (fPage.Height <> ClientHeight) Or (fPage.Left <> 0) Or (fPage.Top <> 0) Then
     fPage.SetBounds(0, 0, ClientWidth, ClientHeight);
    fPage.Realign;
   Finally
    fFitting := False;
   End;
  End;

 Procedure TfrmDockView.StartDockPreview(Sender : TObject; Var DragObject : TDragDockObject);
  Begin
   DragObject := TWindowDragDockObject.Create(Self);
  End;

 Procedure TfrmDockView.Dock(NewDockSite : TWinControl; ARect : TRect);
  Begin
   If (HostDockSite = Nil) And (NewDockSite <> Nil) Then
    fFloatBounds := BoundsRect;
   Inherited;
   FitClient(Self);
  End;

 Procedure TfrmDockView.Attach(Page : TTabSheet; Home : TPageControl);
  Begin
   fPage            := Page;
   fHome            := Home;
   Name             := 'Dock_' + Page.Name;
   Caption          := Page.Caption;
   fFloatBounds     := BoundsRect;
   Page.PageControl := Nil;
   Page.Parent      := Self;
   Page.Align       := alClient;
   Page.Visible     := True;
   ManualDock(Home, Nil, alClient);
   Show;
   FitClient(Self);
  End;

 Procedure TfrmDockView.Toggle;
  Var
   p : TPoint;
  Begin
   If HostDockSite = fHome Then
    Begin
     p := fHome.ClientToScreen(Point(20, 20));
     If fFloatBounds.Width > 0 Then
      ManualFloat(fFloatBounds)
     Else
      ManualFloat(Rect(p.X, p.Y, p.X + 600, p.Y + 650));
    End
   Else
    ManualDock(fHome, Nil, alClient);
   Show;
  End;

 Procedure TfrmDockView.FormClose(Sender : TObject; Var Action : TCloseAction);
  Begin
   ManualDock(fHome, Nil, alClient);
   Action := caNone;
  End;

 Procedure TfrmDockView.Save(Config : TCustomIniFile);
  Var
   s : String;
   b : TRect;
  Begin
   s := 'dock.' + fPage.Name;
   If HostDockSite <> Nil Then
    Config.WriteString(s, 'host', HostDockSite.Name)
   Else
    Config.WriteString(s, 'host', '');
   If HostDockSite = Nil Then
    b := BoundsRect
   Else
    b := fFloatBounds;
   Config.WriteInteger(s, 'left', b.Left);
   Config.WriteInteger(s, 'top', b.Top);
   Config.WriteInteger(s, 'width', b.Width);
   Config.WriteInteger(s, 'height', b.Height);
   If Parent Is TTabSheet Then
    Config.WriteInteger(s, 'order', TTabSheet(Parent).PageIndex);
  End;

 Procedure TfrmDockView.Restore(Config : TCustomIniFile);
  Var
   s : String;
   h : String;
   c : TComponent;
   b : TRect;
   w : TRect;
  Begin
   s                   := 'dock.' + fPage.Name;
   fFloatBounds        := Rect(Config.ReadInteger(s, 'left', 40), Config.ReadInteger(s, 'top', 40), 0, 0);
   fFloatBounds.Right  := fFloatBounds.Left + EnsureRange(Config.ReadInteger(s, 'width', 600), 200, 32767);
   fFloatBounds.Bottom := fFloatBounds.Top + EnsureRange(Config.ReadInteger(s, 'height', 650), 150, 32767);
   h                   := Config.ReadString(s, 'host', fHome.Name);
   c                   := Owner.FindComponent(h);
   If (c Is TWinControl) And TWinControl(c).DockSite Then
    ManualDock(TWinControl(c), Nil, alClient)
   Else
    Begin
     w        := Screen.WorkAreaRect;
     b.Left   := EnsureRange(Config.ReadInteger(s, 'left', w.Left + 40), w.Left, w.Right - 200);
     b.Top    := EnsureRange(Config.ReadInteger(s, 'top', w.Top + 40), w.Top, w.Bottom - 150);
     b.Right  := b.Left + EnsureRange(Config.ReadInteger(s, 'width', 600), 200, w.Width);
     b.Bottom := b.Top + EnsureRange(Config.ReadInteger(s, 'height', 650), 150, w.Height);
     OffsetRect(b, Min(0, w.Right - b.Right), Min(0, w.Bottom - b.Bottom));
     ManualFloat(b);
    End;
   If Parent Is TTabSheet Then
    TTabSheet(Parent).PageIndex := EnsureRange(Config.ReadInteger(s, 'order', TTabSheet(Parent).PageIndex), 0, fHome.PageCount - 1);
   Show;
   FitClient(Self);
  End;

 Procedure TfrmDockView.ReleasePage;
  Begin
   OnClose      := Nil;
   fPage.Parent := Nil;
   ManualFloat(Rect(0, 0, Width, Height));
   fPage.PageControl := fHome;
   fPage             := Nil;
  End;

End.
