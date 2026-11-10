Unit InstrumentRenderU;

Interface

 Uses
  Winapi.Windows, System.Types, Vcl.Graphics;

 Function BeginInstrumentRender(Bitmap : TBitmap; LogicalWidth, LogicalHeight, TargetWidth, TargetHeight : Integer) : Integer;
 Procedure EndInstrumentRender(Bitmap : TBitmap; SavedDC : Integer);
 Procedure DrawInstrumentBitmap(Canvas : TCanvas; Const Target : TRect; Bitmap : TBitmap);
 Procedure SelectInstrumentClip(Canvas : TCanvas; Region : HRGN; Mode : Integer = RGN_COPY);

Implementation

 Uses
  System.Math, System.SysUtils;

 Function BeginInstrumentRender(Bitmap : TBitmap; LogicalWidth, LogicalHeight, TargetWidth, TargetHeight : Integer) : Integer;
  Var
   Factor : Integer;
   Scale  : Double;
  Begin
   LogicalWidth  := Max(1, LogicalWidth);
   LogicalHeight := Max(1, LogicalHeight);
   Scale         := Min(TargetWidth / LogicalWidth, TargetHeight / LogicalHeight);
   Factor        := EnsureRange(Ceil(Max(0.01, Scale) * 2), 1, 8);
   // Limit supersampling memory for large or multi-engine surfaces.
   While (Factor > 1) And (Int64(LogicalWidth) * LogicalHeight * Factor * Factor > 8 * 1024 * 1024) Do
    Dec(Factor);
   Bitmap.PixelFormat := pf32bit;
   Bitmap.SetSize(LogicalWidth * Factor, LogicalHeight * Factor);
   Bitmap.Canvas.Font.Quality := fqAntialiased;
   Bitmap.Canvas.Lock;
   Result := SaveDC(Bitmap.Canvas.Handle);
   SetMapMode(Bitmap.Canvas.Handle, MM_ANISOTROPIC);
   SetWindowExtEx(Bitmap.Canvas.Handle, LogicalWidth, LogicalHeight, Nil);
   SetViewportExtEx(Bitmap.Canvas.Handle, Bitmap.Width, Bitmap.Height, Nil);
   SetWindowOrgEx(Bitmap.Canvas.Handle, 0, 0, Nil);
   SetViewportOrgEx(Bitmap.Canvas.Handle, 0, 0, Nil);
  End;

 Procedure EndInstrumentRender(Bitmap : TBitmap; SavedDC : Integer);
  Begin
   Try
    RestoreDC(Bitmap.Canvas.Handle, SavedDC);
    Bitmap.Canvas.Refresh;
   Finally
    Bitmap.Canvas.Unlock;
   End;
  End;

 Procedure DrawInstrumentBitmap(Canvas : TCanvas; Const Target : TRect; Bitmap : TBitmap);
  Var
   DC : Integer;
  Begin
   If (Target.Width <= 0) Or (Target.Height <= 0) Then
    Exit;
   Canvas.Lock;
   Bitmap.Canvas.Lock;
   DC := SaveDC(Canvas.Handle);
   Try
    SetStretchBltMode(Canvas.Handle, HALFTONE);
    SetBrushOrgEx(Canvas.Handle, 0, 0, Nil);
    StretchBlt(Canvas.Handle, Target.Left, Target.Top, Target.Width, Target.Height, Bitmap.Canvas.Handle, 0, 0, Bitmap.Width, Bitmap.Height, SRCCOPY);
   Finally
    RestoreDC(Canvas.Handle, DC);
    Bitmap.Canvas.Unlock;
    Canvas.Unlock;
   End;
  End;

 Procedure SelectInstrumentClip(Canvas : TCanvas; Region : HRGN; Mode : Integer);
  Var
   Size      : DWORD;
   Data      : TBytes;
   Transform : TXForm;
   p         : Array [0..1] Of TPoint;
   Scaled    : HRGN;
  Begin
   Size := GetRegionData(Region, 0, Nil);
   If Size = 0 Then
    Exit;
   SetLength(Data, Size);
   GetRegionData(Region, Size, PRgnData(@Data[0]));
   p[0] := Point(0, 0);
   p[1] := Point(1, 1);
   LPtoDP(Canvas.Handle, p[0], 2);
   FillChar(Transform, SizeOf(Transform), 0);
   Transform.eM11 := p[1].X - p[0].X;
   Transform.eM22 := p[1].Y - p[0].Y;
   Transform.eDx  := p[0].X;
   Transform.eDy  := p[0].Y;
   Scaled         := ExtCreateRegion(@Transform, Size, PRgnData(@Data[0])^);
   If Scaled = 0 Then
    RaiseLastOSError;
   Try
    ExtSelectClipRgn(Canvas.Handle, Scaled, Mode);
   Finally
    DeleteObject(Scaled);
   End;
  End;

End.
