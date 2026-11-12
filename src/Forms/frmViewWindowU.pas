{$StackFrames On}
Unit frmViewWindowU;

Interface

 Uses
  Winapi.Windows, Winapi.Messages, System.Types, System.Classes, Vcl.ActnList, Vcl.Controls, Vcl.Forms, LocalizationU, i18nLocalizer, ViewStateU,
  i18nCore;

 Type
  TfrmViewWindow = Class(TLocalizedForm)
    AppTranslator : TTranslator;
    Procedure ViewDockOver    (Sender : TObject; Source : TDragDockObject; x, y : Integer; State : TDragState; Var Accept : Boolean);
    Procedure ViewUnDock      (Sender : TObject; Client : TControl; NewTarget : TWinControl; Var Allow : Boolean);
    Procedure DockFinished    (Sender : TObject; Target : TObject; x, y : Integer);
    Procedure StartDockPreview(Sender : TObject; Var DragObject : TDragDockObject);
    Procedure FormClose       (Sender : TObject; Var Action : TCloseAction);
    Procedure TranslateTitle  (Sender : TObject);
   Private
    fDockResizeSnapshot : TMemoryStream;
    fSnapshotWidth      : Integer;
    fSnapshotHeight     : Integer;
    fApplyingDockResize : Boolean;
    fView               : TFrame;
    fWindowAction       : TAction;
    fDock               : TWinControl;
    fReturned           : TNotifyEvent;
    fTitle              : String;
    fStateStore         : TViewStateStore;
    fViewID             : String;
    Procedure WMWindowPosChanging(Var Msg : TWMWindowPosChanging); Message WM_WINDOWPOSCHANGING;
    Procedure WMSize             (Var Msg : TWMSize); Message WM_SIZE;
    Procedure ReturnView;
   Public
    Procedure  SetBounds(ALeft, ATop, AWidth, AHeight : Integer); Override;
    Destructor Destroy; Override;
    Procedure  Attach   (View : TFrame; Dock : TWinControl; Const Title : String; Returned : TNotifyEvent; StateStore : TViewStateStore = Nil; Const ViewID : String = '');
  End;

Implementation

 Uses
  DockPreviewU;

 Type
  TDockTreeAccess = Class(TDockTree)
   Property RelativeSizes;
  End;

// This is an in-memory snapshot emitted by this exact VCL DockManager, not a file format.
// Scaling absolute zone limits avoids VCL's monitor-relative serialization and its leaf-axis ambiguity.

 Function ScaleDockSnapshot(Stream : TMemoryStream; OldW, OldH, NewW, NewH : Integer) : Boolean;
  Var
   Version    : Integer;
   Count      : Integer;
   i          : Integer;
   l          : Integer;
   NameSize   : Integer;
   Value      : Integer;
   Relative   : Byte;
   RootOrient : Byte;
   Orient     : Byte;
   Parents    : Array [0..255] Of Byte;
   PosValue   : Int64;

   Procedure SkipName;
    Begin
     Stream.ReadBuffer(NameSize, SizeOf(NameSize));
     Stream.Position := Stream.Position + NameSize;
    End;

   Procedure ScaleValue(Vertical : Boolean);
    Begin
     PosValue := Stream.Position;
     Stream.ReadBuffer(Value, SizeOf(Value));
     If Vertical Then
      Value := MulDiv(Value, NewH, OldH)
     Else
      Value          := MulDiv(Value, NewW, OldW);
     Stream.Position := PosValue;
     Stream.WriteBuffer(Value, SizeOf(Value));
    End;

  Begin
   Result := False;
   If (OldW <= 0) Or (OldH <= 0) Or (NewW <= 0) Or (NewH <= 0) Then
    Exit;
   Stream.Position := 0;
   Stream.ReadBuffer(Version, SizeOf(Version));
   If Version <> $00080000 Then
    Exit;
   Stream.ReadBuffer(Relative, 1);
   If Relative <> 0 Then
    Exit;
   Stream.ReadBuffer(RootOrient, 1);
   Stream.ReadBuffer(Count, SizeOf(Count));
   For i := 1 To Count Do
    SkipName;
   ScaleValue(Integer(RootOrient) = Integer(doHorizontal));
   While Stream.Position < Stream.Size Do
    Begin
     Stream.ReadBuffer(l, SizeOf(l));
     If l = -1 Then
      Begin
       Result := True;
       Break;
      End;
     If (l < 0) Or (l > 255) Then
      Exit;
     Stream.ReadBuffer(Orient, 1);
     Parents[l] := Orient;
     If l = 0 Then
      ScaleValue(Integer(RootOrient) <> Integer(doHorizontal))
     Else
      ScaleValue(Integer(Parents[l - 1]) = Integer(doHorizontal));
     SkipName;
    End;
   Stream.Position := 0;
  End;
{$R *.dfm}

 Procedure TfrmViewWindow.SetBounds(ALeft, ATop, AWidth, AHeight : Integer);
  Begin
   If Not fApplyingDockResize And ((AWidth <> Width) Or (AHeight <> Height)) And (DockClientCount > 1) And (DockManager <> Nil) And ((fDockResizeSnapshot = Nil) Or (fDockResizeSnapshot.Size = 0)) Then
    Begin
     If fDockResizeSnapshot = Nil Then
      fDockResizeSnapshot := TMemoryStream.Create;
     fDockResizeSnapshot.Clear;
     TDockTreeAccess(DockManager As TDockTree).RelativeSizes := False;
     fSnapshotWidth                                          := ClientWidth;
     fSnapshotHeight                                         := ClientHeight;
     DockManager.SaveToStream(fDockResizeSnapshot);
    End;
   Inherited;
  End;

 Procedure TfrmViewWindow.WMWindowPosChanging(Var Msg : TWMWindowPosChanging);
  Begin
   If Not fApplyingDockResize And ((Msg.WindowPos.flags And SWP_NOSIZE) = 0) And (DockClientCount > 1) And (DockManager <> Nil) And ((fDockResizeSnapshot = Nil) Or (fDockResizeSnapshot.Size = 0)) Then
    Begin
     If fDockResizeSnapshot = Nil Then
      fDockResizeSnapshot := TMemoryStream.Create;
     fDockResizeSnapshot.Clear;
     TDockTreeAccess(DockManager As TDockTree).RelativeSizes := False;
     fSnapshotWidth                                          := ClientWidth;
     fSnapshotHeight                                         := ClientHeight;
     DockManager.SaveToStream(fDockResizeSnapshot);
    End;
   Inherited;
  End;

 Procedure TfrmViewWindow.WMSize(Var Msg : TWMSize);
  Begin
   Inherited;
   If Not fApplyingDockResize And (fDockResizeSnapshot <> Nil) And (fDockResizeSnapshot.Size > 0) And (Msg.SizeType <> SIZE_MINIMIZED) Then
    Begin
     fApplyingDockResize := True;
     Try
      fDockResizeSnapshot.Position := 0;
      If ScaleDockSnapshot(fDockResizeSnapshot, fSnapshotWidth, fSnapshotHeight, ClientWidth, ClientHeight) Then
       DockManager.LoadFromStream(fDockResizeSnapshot);
     Finally
      fDockResizeSnapshot.Clear;
      fApplyingDockResize := False;
     End;
    End;
  End;

 Procedure TfrmViewWindow.ViewDockOver(Sender : TObject; Source : TDragDockObject; x, y : Integer; State : TDragState; Var Accept : Boolean);
  Var
   p : TWinControl;
  Begin
   Accept := (Source.Control Is TCustomForm) And (Source.Control <> Self);
   p      := Self;
   While (p <> Nil) And Accept Do
    Begin
     If p = Source.Control Then
      Accept := False;
     p       := p.Parent;
    End;
  End;

 Procedure TfrmViewWindow.ViewUnDock(Sender : TObject; Client : TControl; NewTarget : TWinControl; Var Allow : Boolean);
  Begin
   Allow := (Client <> fView) Or (fApplyingDockResize And (NewTarget = Self));
  End;

 Procedure TfrmViewWindow.StartDockPreview(Sender : TObject; Var DragObject : TDragDockObject);
  Begin
   DragObject := TWindowDragDockObject.Create(Self);
  End;

 Procedure TfrmViewWindow.Attach(View : TFrame; Dock : TWinControl; Const Title : String; Returned : TNotifyEvent; StateStore : TViewStateStore; Const ViewID : String);
  Begin
   fViewID := ViewID;
   fView   := View;
   If View.FindComponent('aWindow') Is TAction Then
    fWindowAction := TAction(View.FindComponent('aWindow'))
   Else If View.FindComponent('aMapWindow') Is TAction Then
    fWindowAction := TAction(View.FindComponent('aMapWindow'))
   Else If View.FindComponent('aGraphWindow') Is TAction Then
    fWindowAction := TAction(View.FindComponent('aGraphWindow'));
   If fWindowAction <> Nil Then
    fWindowAction.ImageIndex := 1;
   HelpType                  := htContext;
   HelpContext               := View.HelpContext;
   fDock                     := Dock;
   fReturned                 := Returned;
   fTitle                    := Title;
   TranslateTitle(Self);
   View.Parent := Self;
   View.Align  := alClient;
   View.Align  := alNone;
   View.ManualDock(Self, Nil, alClient);
   Dock.Visible := False;
   If StateStore <> Nil Then
    Begin
     StateStore.Opened(fViewID, Self);
     fStateStore := StateStore;
    End;
   Show;
  End;

 Procedure TfrmViewWindow.DockFinished(Sender : TObject; Target : TObject; x, y : Integer);
  Begin
   If fWindowAction <> Nil Then
    If HostDockSite = Nil Then
     fWindowAction.ImageIndex := 1
    Else
     fWindowAction.ImageIndex := 0;
  End;

 Procedure TfrmViewWindow.TranslateTitle(Sender : TObject);
  Begin
   If fTitle <> '' Then
    Caption := Tr(fTitle);
  End;

 Procedure TfrmViewWindow.ReturnView;
  Var
   View     : TFrame;
   Dock     : TWinControl;
   Returned : TNotifyEvent;
   Store    : TViewStateStore;
   i        : Integer;
   Client   : TControl;
   p        : TPoint;
   r        : TRect;
  Begin
   fApplyingDockResize := True;
   If fDockResizeSnapshot <> Nil Then
    fDockResizeSnapshot.Clear;
   // Other views remain alive when their floating dock host is closed.
   For i := DockClientCount - 1 Downto 0 Do
    Begin
     Client := DockClients[i];
     If Client <> fView Then
      Begin
       p := Client.ClientToScreen(Point(0, 0));
       r := Rect(p.x, p.y, p.x + Client.Width, p.y + Client.Height);
       Client.ManualFloat(r);
      End;
    End;
   If fWindowAction <> Nil Then
    fWindowAction.ImageIndex := 0;
   fWindowAction             := Nil;
   View                      := fView;
   Dock                      := fDock;
   Returned                  := fReturned;
   fView                     := Nil;
   fDock                     := Nil;
   fReturned                 := Nil;
   Store                     := fStateStore;
   fStateStore               := Nil;
   Try
    If Store <> Nil Then
     Store.Returned(fViewID);
   Finally
    If (View <> Nil) And (Dock <> Nil) Then
     Begin
      View.Dock(Nil, View.BoundsRect);
      View.Parent  := Dock;
      View.Align   := alClient;
      Dock.Visible := True;
     End;
    If Assigned(Returned) Then
     Returned(Self);
   End;
  End;

 Procedure TfrmViewWindow.FormClose(Sender : TObject; Var Action : TCloseAction);
  Begin
   ReturnView;
   Action := caFree;
  End;

 Destructor TfrmViewWindow.Destroy;
  Begin
   ReturnView;
   fDockResizeSnapshot.Free;
   Inherited;
  End;

End.
