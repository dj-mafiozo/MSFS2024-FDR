Unit B38MEICASU;

Interface

 Uses
  System.Classes, System.Types, Vcl.Graphics, FlightDatabaseU;

 Type
  TEicasEngine = Record
   N1               : Double;
   N2               : Double;
   EGT              : Double;
   FuelFlow         : Double;
   OilPressure      : Double;
   OilTemperature   : Double;
   OilQuantity      : Double;
   Vibration        : Double;
   Starter          : Double;
   Failed           : Double;
   FuelFilterBypass : Double;
   ValveClosed      : Double;
  End;

  TB38MEicasState = Record
   Time         : String;
   Engines      : Array [0..1] Of TEicasEngine;
   TAT          : Double;
   FuelDensity  : Double;
   TotalFuel    : Double;
   Fuel         : Array [0..2] Of Double; // recorded US gallons; no assumed fuel density
   FlapLeft     : Double;
   FlapRight    : Double;
   FlapSelected : Double;
   OilWarning   : Double;
  End;

  TB38MEICAS = Class
   Private
    fState  : TB38MEicasState;
    fBuffer : TBitmap;
    Procedure Render;
   Public
    Constructor Create;
    Destructor Destroy; Override;
    Procedure Clear;
    Procedure SetPoint(Plot : TTripPlot; Index : Integer);
    Procedure PaintTo(Canvas : TCanvas; Const Bounds : TRect);
    Property State : TB38MEicasState Read fState;
  End;

 Function B38MSelectedFlaps(Index : Double) : Double;
 Function B38MFlapDeflection(Degrees : Double) : Double;
 Function B38MFuelMass(Gallons, DensityLbPerGallon : Double) : Double;

Implementation

 Uses
  InstrumentRenderU, System.SysUtils, System.Math, Winapi.Windows, InstrumentDataU, ParameterNamesU;

 Function B38MSelectedFlaps(Index : Double) : Double;
  Const
   Positions : Array [0..8] Of Double = (0, 1, 2, 5, 10, 15, 25, 30, 40);
  Begin
   Result := NaN;
   If Not InstrumentValid(Index) Or (Index < 0) Or (Index > 8) Then
    Exit;
   If Index <> Trunc(Index) Then
    Exit;
   Result := Positions[Trunc(Index)];
  End;

 Function B38MFlapDeflection(Degrees : Double) : Double;
  Const
   Positions : Array [0..8] Of Double = (0, 1, 2, 5, 10, 15, 25, 30, 40);
  Var
   i : Integer;
  Begin
   Result := NaN;
   If Not InstrumentValid(Degrees) Then
    Exit;
   If Degrees <= 0 Then
    Exit(0);
   If Degrees >= 40 Then
    Exit(1);
   For i := 1 To 8 Do
    If Degrees <= Positions[i] Then
     Begin
      Result := ((i - 1) + (Degrees - Positions[i - 1]) / (Positions[i] - Positions[i - 1])) / 8;
      Exit;
     End;
  End;

 Function B38MFuelMass(Gallons, DensityLbPerGallon : Double) : Double;
  Begin
   Result := NaN;
   If Not InstrumentValid(Gallons) Or Not InstrumentValid(DensityLbPerGallon) Then
    Exit;
   If (Gallons < 0) Or (DensityLbPerGallon <= 0) Then
    Exit;
   Result := Gallons * DensityLbPerGallon;
  End;

 Constructor TB38MEICAS.Create;
  Begin
   Inherited;
   fBuffer             := Vcl.Graphics.TBitmap.Create;
   fBuffer.PixelFormat := pf32bit;
   fBuffer.SetSize(640, 800);
   Clear;
  End;

 Destructor TB38MEICAS.Destroy;
  Begin
   fBuffer.Free;
   Inherited;
  End;

 Procedure TB38MEICAS.Clear;
  Var
   e : Integer;
  Begin
   fState := Default(TB38MEicasState);
   For e  := 0 To 1 Do
    With fState.Engines[e] Do
     Begin
      N1               := NaN;
      N2               := NaN;
      EGT              := NaN;
      FuelFlow         := NaN;
      OilPressure      := NaN;
      OilTemperature   := NaN;
      OilQuantity      := NaN;
      Vibration        := NaN;
      Starter          := NaN;
      Failed           := NaN;
      FuelFilterBypass := NaN;
      ValveClosed      := NaN;
     End;
   fState.TAT          := NaN;
   fState.FuelDensity  := NaN;
   fState.TotalFuel    := NaN;
   For e               := 0 To 2 Do
    fState.Fuel[e]     := NaN;
   fState.FlapLeft     := NaN;
   fState.FlapRight    := NaN;
   fState.FlapSelected := NaN;
   fState.OilWarning   := NaN;
  End;

 Procedure TB38MEICAS.SetPoint(Plot : TTripPlot; Index : Integer);
  Var
   e      : Integer;
   Suffix : String;
   SDK    : String;

   Function V(Const Name : String) : Double;
    Begin
     Result := InstrumentValue(Plot, Index, Name);
    End;

   Function Fallback(Const a, b : String) : Double;
    Begin
     Result := V(a);
     If Not InstrumentValid(Result) Then
      Result := V(b);
    End;

  Begin
   Clear;
   If (Plot = Nil) Or (Index < 0) Or (Index >= Plot.Points.Count) Then
    Exit;
   fState.Time := Plot.DisplayPoint(Index).Time;
   For e       := 0 To 1 Do
    Begin
     Suffix := ' #' + IntToStr(e + 1);
     SDK    := '[' + IntToStr(e) + ']';
     With fState.Engines[e] Do
      Begin
       N1               := V('turb_eng_n1' + Suffix);
       N2               := V('turb_eng_n2' + Suffix);
       EGT              := V('eng_exhaust_gas_temperature' + Suffix);
       FuelFlow         := Fallback('turb_eng_fuel_flow_pph' + Suffix, 'eng_fuel_flow_pph' + Suffix);
       OilPressure      := V('eng_oil_pressure' + Suffix);
       OilTemperature   := V('eng_oil_temperature' + Suffix);
       OilQuantity      := V('eng_oil_quantity' + Suffix);
       Vibration        := V('turb_eng_vibration' + Suffix);
       Starter          := V('general_eng_starter_active' + Suffix);
       Failed           := V('eng_failed' + Suffix);
       FuelFilterBypass := V('iFlySDK.FILTER_BYPASS_Light_Status' + SDK);
       ValveClosed      := V('iFlySDK.ENG_VALVE_CLOSED_Light_Status' + SDK);
      End;
    End;
   fState.TAT          := V('total_air_temperature');
   fState.FuelDensity  := V('fuel_weight_per_gallon');
   fState.Fuel[0]      := Fallback('fuel_tank_left_main_quantity', 'fuel_left_quantity');
   fState.Fuel[1]      := V('fuel_tank_center_quantity');
   fState.Fuel[2]      := Fallback('fuel_tank_right_main_quantity', 'fuel_right_quantity');
   fState.TotalFuel    := V('fuel_total_quantity_weight');
   fState.FlapLeft     := V('trailing_edge_flaps_left_angle');
   fState.FlapRight    := V('trailing_edge_flaps_right_angle');
   fState.FlapSelected := B38MSelectedFlaps(V('flaps_handle_index'));
   fState.OilWarning   := V('warning_oil_pressure');
   // LOW_OIL_PRESSURE_Light_Status belongs to the APU, not either engine.
   // Starter ACTIVE is deliberately not relabeled START VALVE OPEN.
  End;

 Procedure TB38MEICAS.Render;
  Var
   c     : TCanvas;
   e     : Integer;
   i     : Integer;
   x     : Integer;
   y     : Integer;
   k     : Integer;
   Known : Integer;
   Value : Double;
   a     : Double;
   Scale : Double;
   Units : String;

   Procedure Text(x, y : Integer; Const Caption : String; Color : TColor; Size : Integer = 14);
    Begin
     c.Brush.Style := bsClear;
     c.Font.Name   := 'Consolas';
     c.Font.Size   := Size;
     c.Font.Color  := Color;
     c.TextOut(x, y, Caption);
    End;

   Procedure Line(X1, Y1, X2, Y2 : Integer; Color : TColor; w : Integer = 1);
    Begin
     c.Pen.Color := Color;
     c.Pen.Width := w;
     c.MoveTo(X1, Y1);
     c.LineTo(X2, Y2);
    End;

   Procedure Box(l, t, r, b : Integer; Fill, Border : TColor);
    Begin
     c.Brush.Color := Fill;
     c.Brush.Style := bsSolid;
     c.Pen.Color   := Border;
     c.Pen.Width   := 1;
     c.Rectangle(l, t, r, b);
    End;

   Function Num(V : Double; Digits : Integer) : String;
    Begin
     If InstrumentValid(V) Then
      Result := Format('%.*f', [Digits, V])
     Else
      Result := '--';
    End;

   Procedure Readout(x, y, w : Integer; V : Double; Digits : Integer);
    Begin
     Box(x, y, x + w, y + 25, clBlack, clWhite);
     Text(x + 4, y + 1, Num(V, Digits), clWhite, 14);
    End;

   Procedure Dial(CX, CY : Integer; V, Full : Double; Const LabelText : String; Digits : Integer);
    Var
     t     : Integer;
     Angle : Double;
    Begin
     c.Brush.Style := bsClear;
     c.Pen.Color   := clWhite;
     c.Pen.Width   := 2;
     For t         := 0 To 49 Do
      Begin
       Angle := DegToRad( -135 + t * 270 / 49);
       x     := CX + Round(Sin(Angle) * 57);
       y     := CY - Round(Cos(Angle) * 57);
       If t = 0 Then
        c.MoveTo(x, y)
       Else
        c.LineTo(x, y);
      End;
     For t := 0 To 5 Do
      Begin
       Angle := DegToRad( -135 + t * 54);
       Line(CX + Round(Sin(Angle) * 57), CY - Round(Cos(Angle) * 57), CX + Round(Sin(Angle) * 49), CY - Round(Cos(Angle) * 49), clWhite);
      End;
     If InstrumentValid(V) Then
      Begin
       Angle := DegToRad( -135 + EnsureRange(V / Full, 0.0, 1.0) * 270);
       Line(CX, CY, CX + Round(Sin(Angle) * 47), CY - Round(Cos(Angle) * 47), clWhite, 3);
      End;
     Readout(CX - 43, CY - 49, 86, V, Digits);
     Text(CX - 25, CY + 58, LabelText, clAqua, 11);
    End;

   Procedure Message(Const L1, L2 : String; Color : TColor; Amber : Boolean);
    Var
     Fill : TColor;
     Ink  : TColor;
    Begin
     Fill := clBlack;
     Ink  := Color;
     If Amber Then
      Begin
       Fill := Color;
       Ink  := clBlack;
      End;
     Box(x, y, x + 117, y + 43, Fill, Color);
     Text(x + 5, y + 3, L1, Ink, 10);
     Text(x + 5, y + 20, L2, Ink, 10);
     Inc(y, 45);
    End;

   Function Flag(V : Double) : Boolean;
    Begin
     Result := InstrumentValid(V) And ((V = 0) Or (V = 1));
    End;

   Function Lamp(V : Double) : Boolean;
    Begin
     Result := InstrumentValid(V) And ((V = 0) Or (V = 1) Or (V = 2));
    End;

  Begin
   c := fBuffer.Canvas;
   Box(0, 0, 640, 800, clBlack, clBlack);
   Text(18, 10, 'TAT ' + Num(ParameterDisplayValue('total_air_temperature', fState.TAT), 0) + ' ' + ParameterDisplayUnit('total_air_temperature'), clAqua, 12);
   Text(380, 10, 'B38M', clAqua, 12);
   For e := 0 To 1 Do
    Begin
     k := 96 + e * 158;
     Text(k - 28, 40, 'ENG ' + IntToStr(e + 1), clAqua, 12);
     With fState.Engines[e] Do
      Begin
       Dial(k, 120, N1, 110, 'N1 %', 1);
       Dial(k, 278, EGT, 1100, 'EGT ' + ParameterDisplayUnit('eng_exhaust_gas_temperature'), 0);
       Dial(k, 436, N2, 110, 'N2 %', 1);
       Value := ParameterDisplayValue('turb_eng_fuel_flow_pph', FuelFlow) / 1000;
       Readout(k - 45, 522, 90, Value, 2);
       Value := ParameterDisplayValue('eng_oil_pressure', OilPressure);
       Units := ParameterDisplayUnit('eng_oil_pressure');
       If Units = 'psf' Then
        Begin
         Value := Value / 144;
         Units := 'psi';
        End;
       Readout(k - 45, 570, 90, Value, 0);
       Readout(k - 45, 618, 90, ParameterDisplayValue('eng_oil_temperature', OilTemperature), 0);
       Readout(k - 45, 666, 90, OilQuantity * 100, 0);
       Readout(k - 45, 714, 90, Vibration, 1);
      End;
    End;
   Text(115, 550, 'FF ' + ParameterDisplayUnit('turb_eng_fuel_flow_pph') + ' x1000', clAqua, 10);
   Text(115, 598, 'OIL P ' + Units, clAqua, 10);
   Text(115, 646, 'OIL T ' + ParameterDisplayUnit('eng_oil_temperature'), clAqua, 10);
   Text(115, 694, 'OIL QTY %', clAqua, 10);
   Text(115, 744, 'VIB', clAqua, 10);
   For e := 0 To 1 Do
    Begin
     x     := 372 + e * 127;
     y     := 75;
     Known := 0;
     Text(x + 26, 48, 'ENG ' + IntToStr(e + 1), clAqua, 11);
     Box(x, y, x + 117, 350, clBlack, clGray);
     With fState.Engines[e] Do
      Begin
       If Flag(Starter) Then
        Begin
         Inc(Known);
         If Starter = 1 Then
          Message('STARTER', 'ACTIVE', clAqua, False);
        End;
       If Flag(Failed) Then
        Begin
         Inc(Known);
         If Failed = 1 Then
          Message('ENG', 'FAIL', clYellow, True);
        End;
       If Lamp(FuelFilterBypass) Then
        Begin
         Inc(Known);
         If FuelFilterBypass > 0 Then
          Message('FUEL FILTER', 'BYPASS', clYellow, True);
        End;
       If Lamp(ValveClosed) Then
        Begin
         Inc(Known);
         If ValveClosed > 0 Then
          Message('ENG VALVE', 'CLOSED', clAqua, False);
        End;
      End;
     If Known < 4 Then
      Text(x + 8, 327, 'STATUS --', clGray, 10);
    End;
   If InstrumentValid(fState.OilWarning) And (fState.OilWarning = 1) Then
    Begin
     Box(372, 363, 626, 397, clYellow, clYellow);
     Text(379, 370, 'OIL PRESS WARNING', clBlack, 12);
    End;
   // Separate actual left/right surface angles from selected 737 detent.
   Text(436, 419, 'FLAPS', clAqua, 14);
   c.Brush.Style := bsClear;
   c.Pen.Color   := clWhite;
   c.Pen.Width   := 2;
   c.Ellipse(427, 450, 573, 596);
   For i := 0 To 8 Do
    Begin
     a     := DegToRad( -135 + i * 270 / 8);
     Scale := 62;
     x     := 500 + Round(Sin(a) * Scale);
     y     := 523 - Round(Cos(a) * Scale);
     Text(x - 8, y - 6, Num(B38MSelectedFlaps(i), 0), clWhite, 8);
    End;
   If InstrumentValid(fState.FlapLeft) And InstrumentValid(fState.FlapRight) Then
    Begin
     Value := (fState.FlapLeft + fState.FlapRight) / 2;
     a     := DegToRad( -135 + B38MFlapDeflection(Value) * 270);
     Line(500, 523, 500 + Round(Sin(a) * 45), 523 - Round(Cos(a) * 45), clWhite, 3);
    End;
   Text(450, 510, 'SEL ' + Num(fState.FlapSelected, 0), clWhite, 12);
   Text(385, 610, 'ACT L/R ' + Num(fState.FlapLeft, 1) + '/' + Num(fState.FlapRight, 1) + ' deg', clAqua, 10);
   Units := ParameterDisplayUnit('fuel_total_quantity_weight');
   Box(368, 660, 627, 722, clBlack, clAqua);
   Text(380, 638, 'FUEL QTY ' + Units + ' x1000', clAqua, 11);
   For i := 0 To 2 Do
    Begin
     Value := B38MFuelMass(fState.Fuel[i], fState.FuelDensity);
     Value := ParameterDisplayValue('fuel_total_quantity_weight', Value) / 1000;
     Text(377 + i * 82, 682, Num(Value, 2), clWhite, 13);
    End;
   Text(384, 741, 'TOTAL ' + Num(ParameterDisplayValue('fuel_total_quantity_weight', fState.TotalFuel) / 1000, 2), clAqua, 14);
  End;

 Procedure TB38MEICAS.PaintTo(Canvas : TCanvas; Const Bounds : TRect);
  Var
   w        : Integer;
   h        : Integer;
   RenderDC : Integer;
   s        : Double;
   Target   : TRect;
  Begin
   Canvas.Brush.Color := clBlack;
   Canvas.Brush.Style := bsSolid;
   Canvas.FillRect(Bounds);
   w := Bounds.Right - Bounds.Left;
   h := Bounds.Bottom - Bounds.Top;
   If (w < 1) Or (h < 1) Then
    Exit;
   RenderDC := BeginInstrumentRender(fBuffer, 640, 800, w, h);
   Try
    Render;
   Finally
    EndInstrumentRender(fBuffer, RenderDC);
   End;
   s      := Min(w / 640, h / 800);
   w      := Max(1, Round(640 * s));
   h      := Max(1, Round(800 * s));
   Target := Rect(Bounds.Left + (Bounds.Width - w) Div 2, Bounds.Top + (Bounds.Height - h) Div 2, Bounds.Left + (Bounds.Width + w) Div 2, Bounds.Top + (Bounds.Height + h) Div 2);
   SetStretchBltMode(Canvas.Handle, HALFTONE);
   SetBrushOrgEx(Canvas.Handle, 0, 0, Nil);
   DrawInstrumentBitmap(Canvas, Target, fBuffer);
  End;

End.
