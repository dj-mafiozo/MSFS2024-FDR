Unit AirbusPFDU;

Interface

 Uses
  System.Classes, FlightDatabaseU, AirbusDisplayU, SixPackU, AirbusFMAU, FlightDirectorU, PFDMinimaU, PFDReadoutsU;

 Type
  TAirbusPFD = Class(TAirbusDisplay)
   Private
    fMinimum : TPFDMinimum;
    fFD      : TFlightDirectorSampler;
    fSampler : TSixPackDisplay;
    fFMA     : TAirbusFMA;
    fChanged : Array [0..4, 0..2] Of Boolean;
   Protected
    Procedure Render; Override;
   Public
    Constructor Create(AOwner : TComponent); Override;
    Destructor Destroy; Override;
    Procedure SetPoint(Plot : TTripPlot; Index : Integer); Override;
    Procedure Clear; Override;
    Property Sampler : TSixPackDisplay Read fSampler;
  End;

Implementation

 Uses
  InstrumentRenderU, Winapi.Windows, System.SysUtils, System.Math, System.Types, Vcl.Graphics,
  InstrumentDataU, PFDScalesU, ParameterNamesU, AirbusDataU;

 Constructor TAirbusPFD.Create(AOwner : TComponent);
  Begin
   Inherited;
   fSampler := TSixPackDisplay.Create(Self);
   fFD      := TFlightDirectorSampler.Create;
  End;

 Destructor TAirbusPFD.Destroy;
  Begin
   fFD.Free;
   Inherited;
  End;

 Procedure TAirbusPFD.SetPoint(Plot : TTripPlot; Index : Integer);
  Var
   Previous : TAirbusData;
   Old      : TAirbusFMA;
   j        : Integer;
   c        : Integer;
   r        : Integer;
   NowTime  : Double;
   Pending  : Array [0..4, 0..2] Of Boolean;
  Begin
   Inherited;
   fSampler.SetPoint(Plot, Index);
   fFD.SetPoint(Plot, Index, True);
   fFMA     := ReadAirbusFMA(fData);
   fMinimum := ReadFBWMinimum(fData);
   FillChar(fChanged, SizeOf(fChanged), 0);
   FillChar(Pending, SizeOf(Pending), 1);
   If (Plot = Nil) Or (Index < 1) Or (Index >= Plot.Points.Count) Then
    Exit;
   Previous := TAirbusData.Create;
   Try
    NowTime := fData.Seconds;
    // Replay time, not wall clock: seeking backwards must reproduce the same boxes.
    For j := Index - 1 Downto 0 Do
     Begin
      Previous.SetPoint(Plot, j);
      If NowTime - Previous.Seconds > 10 Then
       Break;
      Old    := ReadAirbusFMA(Previous);
      For c  := 0 To 4 Do
       For r := 0 To 2 Do
        If Pending[c, r] And ((Old.Cells[c, r].Text <> fFMA.Cells[c, r].Text) Or (Old.Cells[c, r].Color <> fFMA.Cells[c, r].Color)) Then
         Begin
          Pending[c, r]  := False;
          fChanged[c, r] := fFMA.Cells[c, r].Text <> '';
         End;
     End;
   Finally
    Previous.Free;
   End;
  End;

 Procedure TAirbusPFD.Clear;
  Begin
   Inherited;
   fMinimum := Default(TPFDMinimum);
   If fFD <> Nil Then
    fFD.Clear;
   fFMA := Default(TAirbusFMA);
   FillChar(fChanged, SizeOf(fChanged), 0);
   If fSampler <> Nil Then
    fSampler.Clear;
  End;

 Procedure TAirbusPFD.Render;
  Var
   s     : TSixPackState;
   c     : TCanvas;
   i     : Integer;
   x     : Integer;
   y     : Integer;
   DC    : Integer;
   Clip  : Integer;
   FD    : TFlightDirectorState;
   FMA   : TAirbusFMA;
   r     : Integer;
   Roll  : Double;
   Pitch : Double;
   a     : Double;
   v     : Double;
   p     : Array [0..3] Of TPoint;

   Function H(x, y : Double) : TPoint;
    Begin
     Result := Point(295 + Round(x * Cos(Roll) - y * Sin(Roll)), 325 + Round(x * Sin(Roll) + y * Cos(Roll)));
    End;

   Procedure Ground(Y1, Y2 : Double; Col : TColor);
    Begin
     p[0]          := H( -1000, Y1);
     p[1]          := H(1000, Y1);
     p[2]          := H(1000, Y2);
     p[3]          := H( -1000, Y2);
     c.Brush.Style := bsSolid;
     c.Brush.Color := Col;
     c.Pen.Color   := Col;
     c.Polygon(p);
    End;

   Procedure Diamond(x, y : Integer; Hollow : Boolean);
    Begin
     p[0]          := Point(x, y - 8);
     p[1]          := Point(x + 8, y);
     p[2]          := Point(x, y + 8);
     p[3]          := Point(x - 8, y);
     c.Pen.Color   := clFuchsia;
     c.Pen.Width   := 2;
     c.Brush.Color := clFuchsia;
     c.Brush.Style := bsSolid;
     If Hollow Then
      c.Brush.Style := bsClear;
     c.Polygon(p);
    End;

   Procedure Flag(x, y : Integer; Const LabelText : String; v : Double);
    Begin
     If Not InstrumentValid(v) Then
      Text(x, y, LabelText + ' --', clSilver, 11)
     Else If v <> 0 Then
      Text(x, y, LabelText + ' ON', clWhite, 11)
     Else
      Text(x, y, LabelText + ' OFF', clWhite, 11);
    End;

  Begin
   s := fSampler.State;
   c := fBuffer.Canvas;
   v := fData.Fenix('I_FCU_AP1');
   If InstrumentValid(v) Then
    Begin
     s.AP := v;
     v    := fData.Fenix('I_FCU_AP2');
     If InstrumentValid(v) Then
      s.AP := Max(s.AP, v);
    End;
   v := fData.Fenix('I_FCU_EFIS1_FD');
   If InstrumentValid(v) Then
    s.FD := v;
   v     := fData.Fenix('I_FCU_ATHR');
   If InstrumentValid(v) Then
    s.AT := v;
   FMA   := fFMA;
   For i := 1 To 4 Do
    Begin
     If (i <> 2) Or (FMA.Common = '') Then
      Line(i * 128, 4, i * 128, 78, clGray);
    End;
   For i  := 0 To 4 Do
    For r := 0 To 2 Do
     Begin
      If Not FMA.Cells[i, r].Flash Or (Frac(fData.Seconds) < 0.5) Then
       Text(i * 128 + 4, r * 25 + 4, FMA.Cells[i, r].Text, FMA.Cells[i, r].Color, 11);
      If FMA.Cells[i, r].Boxed Or ((r = 0) And fChanged[i, r]) Then
       Box(i * 128 + 1, r * 25 + 1, i * 128 + 126, r * 25 + 25, clWhite);
     End;
   If FMA.Common <> '' Then
    Text(180, 4, FMA.Common, clLime, 13);
   DrawPFDTape(c, Rect(10, 155, 84, 500), s.IAS, 'airspeed_indicated', 10, 50);
   DrawPFDTape(c, Rect(500, 155, 574, 500), s.Altitude, 'indicated_altitude', 100, 450);
   DrawPFDVSI(c, Rect(590, 155, 638, 500), s.VSI, True);
   v := fData.Value('autopilot_altitude_lock_var');
   If InstrumentValid(v) Then
    Text(500, 115, Format('%.0f', [ParameterDisplayValue('indicated_altitude', v)]), clAqua, 15);
   Text(10, 115, PFDSpeedCaption(fData, Nil, 0, False), clAqua, 15);
   c.Brush.Style := bsSolid;
   c.Brush.Color := clBlack;
   c.FillRect(Rect(502, 307, 572, 347));
   If InstrumentValid(s.Altitude) Then
    Text(502, 309, Format('%.0f', [ParameterDisplayValue('indicated_altitude', s.Altitude)]), clLime, 16);
   If InstrumentValid(s.Pitch) And InstrumentValid(s.Bank) Then
    Begin
     Roll  := DegToRad(s.Bank);
     Pitch := EnsureRange(s.Pitch, -80.0, 80.0) * 5;
     DC    := SaveDC(c.Handle);
     Clip  := CreateEllipticRgn(120, 150, 470, 500);
     Try
      SelectInstrumentClip(c, Clip);
      Ground( -1500, Pitch, $00F39B00);
      Ground(Pitch, 1500, $001C4C8E);
      p[0] := H( -1000, Pitch);
      p[1] := H(1000, Pitch);
      Line(p[0].x, p[0].y, p[1].x, p[1].y, clWhite, 2);
      For i := -6 To 6 Do
       If i <> 0 Then
        Begin
         x := 20;
         If i Mod 2 = 0 Then
          x   := 65;
         p[0] := H( -x, Pitch - i * 25);
         p[1] := H(x, Pitch - i * 25);
         Line(p[0].x, p[0].y, p[1].x, p[1].y, clWhite, 2);
         If i Mod 2 = 0 Then
          Begin
           p[0] := H( -98, Pitch - i * 25);
           Text(p[0].x, p[0].y - 9, IntToStr(Abs(i * 5)), clWhite, 12);
          End;
        End;
     Finally
      RestoreDC(c.Handle, DC);
      DeleteObject(Clip);
     End;
    End
   Else
    Text(250, 315, 'ATT --', clRed);
   For i := -6 To 6 Do
    If (Abs(i) <= 3) Or (i Mod 3 = 0) Then
     Begin
      a := DegToRad(i * 10);
      Line(295 + Round(Sin(a) * 180), 325 - Round(Cos(a) * 180), 295 + Round(Sin(a) * 190), 325 - Round(Cos(a) * 190), clWhite, 2);
     End;
   Line(286, 130, 295, 143, clYellow, 2);
   Line(295, 143, 304, 130, clYellow, 2);
   Line(304, 130, 286, 130, clYellow, 2);
   FD := fFD.State;
   If InstrumentValid(s.Pitch) And InstrumentValid(s.Bank) And FD.BankValid Then
    Begin
     x := 295 + Round(EnsureRange(FD.BankError / 45, -1.0, 1.0) * 110);
     Line(x, 250, x, 400, clLime, 3);
    End;
   If InstrumentValid(s.Pitch) And InstrumentValid(s.Bank) And FD.PitchValid Then
    Begin
     y := 325 - Round(EnsureRange(FD.PitchError / 22.5, -1.0, 1.0) * 90);
     Line(210, y, 380, y, clLime, 3);
    End;
   If FD.Selected And Not FD.PitchValid And Not FD.BankValid Then
    Text(130, 115, 'FD --', clSilver, 11);
   Line(125, 325, 210, 325, clYellow, 4);
   Line(210, 325, 210, 340, clYellow, 4);
   Line(380, 340, 380, 325, clYellow, 4);
   Line(380, 325, 465, 325, clYellow, 4);
   Box(290, 320, 300, 330, clYellow);
   If s.LocalizerValid Then
    Begin
     For i := -2 To 2 Do
      Begin
       x             := 295 + i * 70;
       c.Brush.Style := bsClear;
       c.Pen.Color   := clWhite;
       c.Pen.Width   := 2;
       c.Ellipse(x - 3, 525, x + 4, 532);
      End;
     Diamond(295 + Round(s.Localizer * 140), 528, Abs(s.Localizer) >= 1);
    End;
   If s.GlideslopeValid Then
    Begin
     For i := -2 To 2 Do
      Begin
       y             := 325 + i * 70;
       c.Brush.Style := bsClear;
       c.Pen.Color   := clWhite;
       c.Ellipse(480, y - 3, 487, y + 4);
      End;
     Diamond(483, 325 + Round(s.Glideslope * 140), Abs(s.Glideslope) >= 1);
    End;
   v := fData.Value('radio_height');
   If InstrumentValid(v) And (v >= 0) And (v < 2500) Then
    Number(265, 465, v, 0);
   Box(125, 570, 470, 623, clGray);
   If InstrumentValid(s.Heading) Then
    For i := -5 To 5 Do
     Begin
      v := (Floor(s.Heading / 10) + i) * 10;
      x := 295 + Round((v - s.Heading) * 6);
      If (x > 125) And (x < 470) Then
       Begin
        Line(x, 570, x, 582);
        Text(x - 12, 588, Format('%.0f', [((Round(v) Mod 360) + 360) Mod 360 / 10]), clWhite, 13);
       End;
     End;
   Line(295, 560, 295, 581, clYellow, 3);
   Text(440, 535, PFDBaroCaption(fData, True), clAqua, 12);
   v := fData.Value('airspeed_mach');
   If InstrumentValid(v) And (v >= 0) Then
    Text(10, 530, Format('M %.3f', [v]), clWhite, 12);
   DrawMinimum(c, fMinimum, s.Altitude, fData.Value('radio_height'), Rect(500, 155, 574, 500), 450);
   Text(386, 54, MinimumCaption(fMinimum), clWhite, 10);
   Text(8, 505, ParameterDisplayUnit('airspeed_indicated'), clWhite, 10);
   Text(500, 505, ParameterDisplayUnit('indicated_altitude'), clWhite, 10);
  End;

End.
