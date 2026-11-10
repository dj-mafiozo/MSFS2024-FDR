Unit DockPreviewU;

Interface

 Uses
  Winapi.Windows, System.Types, Vcl.Controls;

 Type
  // The docking protocol remains VCL's; only its desktop XOR image is replaced.
  TWindowDragDockObject = Class(TDragDockObjectEx)
   Private
    fPreview : HWND;
   Protected
    Procedure DrawDragDockImage; Override;
    Procedure EraseDragDockImage; Override;
    Function GetEraseWhenMoving : Boolean; Override;
   Public
    Destructor Destroy; Override;
    Property PreviewHandle : HWND Read fPreview;
  End;

Implementation

 Uses
  System.SysUtils, System.Math;

 Function TWindowDragDockObject.GetEraseWhenMoving : Boolean;
  Begin
   Result := False; // Moving a real window invalidates its old screen area.
  End;

 Procedure TWindowDragDockObject.DrawDragDockImage;
  Var
   r      : TRect;
   w      : Integer;
   h      : Integer;
   Border : Integer;
   Outer  : HRGN;
   Inner  : HRGN;
  Begin
   r := DockRect;
   w := r.Right - r.Left;
   h := r.Bottom - r.Top;
   If (w <= 0) Or (h <= 0) Then
    Begin
     EraseDragDockImage;
     Exit;
    End;
   If fPreview = 0 Then
    Begin
     fPreview := CreateWindowEx(WS_EX_LAYERED Or WS_EX_TRANSPARENT Or WS_EX_TOOLWINDOW Or WS_EX_NOACTIVATE, 'STATIC', Nil, WS_POPUP Or SS_BLACKRECT, 0, 0, 0, 0, 0, 0, HInstance, Nil);
     If fPreview = 0 Then
      RaiseLastOSError;
     SetLayeredWindowAttributes(fPreview, 0, 180, LWA_ALPHA);
    End;
   Border := Min(4, Min(w, h));
   Outer  := CreateRectRgn(0, 0, w, h);
   Try
    Inner := CreateRectRgn(Border, Border, Max(Border, w - Border), Max(Border, h - Border));
    Try
     CombineRgn(Outer, Outer, Inner, RGN_DIFF);
    Finally
     DeleteObject(Inner);
    End;
    If SetWindowRgn(fPreview, Outer, True) <> 0 Then
     Outer := 0; // Window owns the region on success.
   Finally
    If Outer <> 0 Then
     DeleteObject(Outer);
   End;
   SetWindowPos(fPreview, HWND_TOPMOST, r.Left, r.Top, w, h, SWP_NOACTIVATE Or SWP_SHOWWINDOW);
  End;

 Procedure TWindowDragDockObject.EraseDragDockImage;
  Begin
   If fPreview <> 0 Then
    ShowWindow(fPreview, SW_HIDE);
  End;

 Destructor TWindowDragDockObject.Destroy;
  Begin
   If fPreview <> 0 Then
    Begin
     DestroyWindow(fPreview);
     fPreview := 0;
    End;
   Inherited;
  End;

End.
