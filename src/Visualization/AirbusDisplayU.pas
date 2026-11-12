Unit AirbusDisplayU;

Interface

 Uses
  System.Classes, System.Types, Vcl.Controls, Vcl.Graphics, FlightDatabaseU, AirbusDataU;

 Type
  TAirbusDisplay = Class(TCustomControl)
   Protected
    fBuffer : TBitmap;
    fData   : TAirbusData;
    Procedure Render; Virtual; Abstract;
    Procedure Paint; Override;
    Procedure Text  (x, y : Integer; Const s : String; Col : TColor = clWhite; Size : Integer = 16);
    Procedure Line  (X1, Y1, X2, Y2 : Integer; Col : TColor = clWhite; w : Integer = 1);
    Procedure Box   (X1, Y1, X2, Y2 : Integer; Col : TColor = clWhite);
    Procedure Number(x, y : Integer; v : Double; Digits : Integer = 0; Col : TColor = clLime);
    Procedure Gauge (x, y, r : Integer; v, Maximum : Double; Const LabelText : String);
   Public
    Constructor Create  (AOwner : TComponent); Override;
    Destructor  Destroy; Override;
    Procedure   SetPoint(Plot : TTripPlot; Index : Integer); Virtual;
    Procedure   Clear; Virtual;
    Property Data : TAirbusData Read fData;
  End;

Implementation

 Uses
  InstrumentRenderU, Winapi.Windows, System.SysUtils, System.Math, InstrumentDataU;

 Constructor TAirbusDisplay.Create(AOwner : TComponent);
  Begin
   Inherited;
   DoubleBuffered      := True;
   ParentBiDiMode      := False;
   BiDiMode            := bdLeftToRight;
   fBuffer             := Vcl.Graphics.TBitmap.Create;
   fBuffer.PixelFormat := pf32bit;
   fBuffer.SetSize(640, 640);
   fData := TAirbusData.Create;
  End;

 Destructor TAirbusDisplay.Destroy;
  Begin
   fData.Free;
   fBuffer.Free;
   Inherited;
  End;

 Procedure TAirbusDisplay.SetPoint(Plot : TTripPlot; Index : Integer);
  Begin
   fData.SetPoint(Plot, Index);
   Invalidate;
  End;

 Procedure TAirbusDisplay.Clear;
  Begin
   fData.Clear;
   Invalidate;
  End;

 Procedure TAirbusDisplay.Text(x, y : Integer; Const s : String; Col : TColor; Size : Integer);
  Begin
   With fBuffer.Canvas Do
    Begin
     Font.Name   := 'Consolas';
     Font.Size   := Size;
     Font.Style  := [];
     Font.Color  := Col;
     Brush.Style := bsClear;
     TextOut(x, y, s);
    End;
  End;

 Procedure TAirbusDisplay.Number(x, y : Integer; v : Double; Digits : Integer; Col : TColor);
  Begin
   If InstrumentValid(v) Then
    Text(x, y, Format('%.*f', [Digits, v], TFormatSettings.Create('en-US')), Col)
   Else
    Text(x, y, '--', clSilver);
  End;

 Procedure TAirbusDisplay.Line(X1, Y1, X2, Y2 : Integer; Col : TColor; w : Integer);
  Begin
   With fBuffer.Canvas Do
    Begin
     Pen.Color := Col;
     Pen.Width := w;
     MoveTo(X1, Y1);
     LineTo(X2, Y2);
    End;
  End;

 Procedure TAirbusDisplay.Box(X1, Y1, X2, Y2 : Integer; Col : TColor);
  Begin
   With fBuffer.Canvas Do
    Begin
     Brush.Style := bsClear;
     Pen.Color   := Col;
     Pen.Width   := 1;
     Rectangle(X1, Y1, X2, Y2);
    End;
  End;

 Procedure TAirbusDisplay.Gauge(x, y, r : Integer; v, Maximum : Double; Const LabelText : String);
  Var
   i  : Integer;
   a  : Double;
   P1 : TPoint;
   P2 : TPoint;
  Begin
   With fBuffer.Canvas Do
    Begin
     Brush.Style := bsClear;
     Pen.Width   := 2;
     Pen.Color   := clWhite;
     Arc(x - r, y - r, x + r, y + r, x + r, y, x - r, y);
    End;
   For i := 0 To 4 Do
    Begin
     a  := Pi - i * Pi / 4;
     P1 := Point(x + Round(Cos(a) * r), y - Round(Sin(a) * r));
     P2 := Point(x + Round(Cos(a) * (r - 8)), y - Round(Sin(a) * (r - 8)));
     Line(P1.x, P1.y, P2.x, P2.y);
    End;
   If InstrumentValid(v) Then
    Begin
     a := Pi - EnsureRange(v / Maximum, 0.0, 1.0) * Pi;
     Line(x, y, x + Round(Cos(a) * (r - 6)), y - Round(Sin(a) * (r - 6)), clLime, 3);
    End;
   Number(x - 30, y + 3, v, 1);
   Text(x - r, y + 33, LabelText, clWhite, 11);
  End;

 Procedure TAirbusDisplay.Paint;
  Var
   Scale    : Double;
   w        : Integer;
   h        : Integer;
   RenderDC : Integer;
   Target   : TRect;
  Begin
   Canvas.Brush.Style := bsSolid;
   Canvas.Brush.Color := clBlack;
   Canvas.FillRect(ClientRect);
   If (ClientWidth < 1) Or (ClientHeight < 1) Then
    Exit;
   RenderDC := BeginInstrumentRender(fBuffer, 640, 640, ClientWidth, ClientHeight);
   Try
    fBuffer.Canvas.Brush.Style := bsSolid;
    fBuffer.Canvas.Brush.Color := clBlack;
    fBuffer.Canvas.FillRect(Rect(0, 0, 640, 640));
    Render;
   Finally
    EndInstrumentRender(fBuffer, RenderDC);
   End;
   Scale  := Min(ClientWidth / 640, ClientHeight / 640);
   w      := Max(1, Round(640 * Scale));
   h      := Max(1, Round(640 * Scale));
   Target := Rect((ClientWidth - w) Div 2, (ClientHeight - h) Div 2, (ClientWidth + w) Div 2, (ClientHeight + h) Div 2);
   DrawInstrumentBitmap(Canvas, Target, fBuffer);
  End;

End.
