Unit PFDScalesU;

Interface

 Uses
  System.Types, System.UITypes, Vcl.Graphics;

 Function PFDVSIDeflection(FeetPerMinute : Double) : Double;
 Procedure DrawPFDTape(c : TCanvas; Bounds : TRect; Raw : Double; Const Parameter : String; Step, Span : Double);
 Procedure DrawPFDVSI(c : TCanvas; Bounds : TRect; Raw : Double; Airbus : Boolean = False);

Implementation

 Uses
  Winapi.Windows, System.SysUtils, System.Math, InstrumentDataU, ParameterNamesU;

 Function PFDVSIDeflection(FeetPerMinute : Double) : Double;
  Var
   v : Double;
  Begin
   If Not InstrumentValid(FeetPerMinute) Then
    Exit(NaN);
   v := Min(6000, Abs(FeetPerMinute));
   If v <= 1000 Then
    Result := v / 2000
   Else If v <= 2000 Then
    Result := 0.5 + (v - 1000) / 4000
   Else
    Result := 0.75 + (v - 2000) / 16000;
   If FeetPerMinute < 0 Then
    Result := -Result;
  End;

 Procedure LabelAt(c : TCanvas; x, y : Integer; Const Text : String; Size : Integer);
  Begin
   c.Font.Name   := 'Consolas';
   c.Font.Size   := Size;
   c.Font.Style  := [];
   c.Font.Color  := clWhite;
   c.Brush.Style := bsClear;
   c.TextOut(x, y, Text);
  End;

 Function Number(Const Parameter : String; Raw : Double) : String;
  Begin
   If InstrumentValid(Raw) Then
    Result := Format('%.0f', [ParameterDisplayValue(Parameter, Raw)])
   Else
    Result := '--';
  End;

 Procedure DrawPFDTape(c : TCanvas; Bounds : TRect; Raw : Double; Const Parameter : String; Step, Span : Double);
  Var
   DC        : Integer;
   Tick      : Integer;
   y         : Integer;
   Mid       : Integer;
   Half      : Integer;
   FontSize  : Integer;
   BoxHalf   : Integer;
   v         : Double;
   LabelStep : Double;
  Begin
   If (Bounds.Width < 24) Or (Bounds.Height < 40) Then
    Exit;
   DC := SaveDC(c.Handle);
   Try
    IntersectClipRect(c.Handle, Bounds.Left, Bounds.Top, Bounds.Right, Bounds.Bottom);
    c.Brush.Style := bsSolid;
    c.Brush.Color := $00474747;
    c.Pen.Color   := c.Brush.Color;
    c.FillRect(Bounds);
    Mid       := (Bounds.Top + Bounds.Bottom) Div 2;
    Half      := Bounds.Height Div 2;
    FontSize  := Max(7, Min(13, Bounds.Width Div 6));
    LabelStep := Step * Max(1, Ceil((FontSize * 96 / 72 + 3) * Span / (Half * Step)));
    If InstrumentValid(Raw) Then
     For Tick := -6 To 6 Do
      Begin
       v := (Floor(Raw / LabelStep) + Tick) * LabelStep;
       If (Parameter = 'airspeed_indicated') And (v < 0) Then
        Continue;
       y           := Mid - Round((v - Raw) / Span * Half);
       c.Pen.Color := clWhite;
       c.Pen.Width := 1;
       c.MoveTo(Bounds.Right - 10, y);
       c.LineTo(Bounds.Right, y);
       LabelAt(c, Bounds.Left + 3, y - 8, Number(Parameter, v), FontSize);
      End;
    BoxHalf       := Max(10, Min(21, Bounds.Height Div 8));
    c.Brush.Style := bsSolid;
    c.Brush.Color := clBlack;
    c.Pen.Color   := clWhite;
    c.Pen.Width   := 2;
    c.Rectangle(Bounds.Left, Mid - BoxHalf, Bounds.Right, Mid + BoxHalf);
    LabelAt(c, Bounds.Left + 3, Mid - BoxHalf + 2, Number(Parameter, Raw), Max(8, Min(19, Bounds.Width Div 5)));
   Finally
    RestoreDC(c.Handle, DC);
   End;
  End;

 Procedure DrawPFDVSI(c : TCanvas; Bounds : TRect; Raw : Double; Airbus : Boolean);
  Var
   DC   : Integer;
   i    : Integer;
   y    : Integer;
   Mid  : Integer;
   Half : Integer;
   v    : Double;
  Begin
   If (Bounds.Width < 20) Or (Bounds.Height < 40) Then
    Exit;
   DC := SaveDC(c.Handle);
   Try
    IntersectClipRect(c.Handle, Bounds.Left, Bounds.Top, Bounds.Right, Bounds.Bottom);
    c.Brush.Style := bsSolid;
    c.Brush.Color := $00353535;
    c.FillRect(Bounds);
    Mid   := (Bounds.Top + Bounds.Bottom) Div 2;
    Half  := Max(1, Bounds.Height Div 2 - 12);
    For i := -3 To 3 Do
     Begin
      Case Abs(i) Of
       0 : v := 0;
       1 : v := 1000;
       2 : v := 2000;
      Else v := 6000;
      End;
      If i < 0 Then
       v          := -v;
      y           := Mid - Round(PFDVSIDeflection(v) * Half);
      c.Pen.Color := clWhite;
      c.Pen.Width := 1;
      c.MoveTo(Bounds.Left + 2, y);
      c.LineTo(Bounds.Left + 10, y);
      If (Bounds.Height >= 180) Or (i = -3) Or (i = 0) Or (i = 3) Then
       LabelAt(c, Bounds.Left + 12, y - 7, Number('vertical_speed', Abs(v)), Max(6, Min(9, Bounds.Width Div 5)));
     End;
    If InstrumentValid(Raw) Then
     Begin
      c.Pen.Color := clWhite;
      c.Pen.Width := 3;
      c.MoveTo(Bounds.Right - 1, Mid);
      c.LineTo(Bounds.Left + 2, Mid - Round(PFDVSIDeflection(Raw) * Half));
      If Airbus And (Raw <> 0) Then
       Begin
        // Airbus readout is the magnitude in hundreds of ft/min;
        // the pointer position supplies the climb/descent direction.
        y := Mid - Round(PFDVSIDeflection(Raw) * Half);
        If Raw > 0 Then
         Dec(y, 18)
        Else
         Inc(y, 2);
        y := EnsureRange(y, Bounds.Top, Bounds.Bottom - 18);
        LabelAt(c, Bounds.Left + 12, y,
        Format('%.2d', [Max(1, Round(Abs(Raw) / 100))]), 10);
        c.Font.Color  := clLime;
        c.Brush.Style := bsSolid;
        c.Brush.Color := clBlack;
        c.TextOut(Bounds.Left + 12, y,
        Format('%.2d', [Max(1, Round(Abs(Raw) / 100))]));
       End;
     End;
   Finally
    RestoreDC(c.Handle, DC);
   End;
  End;

End.
