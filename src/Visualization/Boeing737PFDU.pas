Unit Boeing737PFDU;

Interface

 Uses
  System.Classes, System.Types, Vcl.Controls, Vcl.Graphics, FlightDatabaseU, SixPackU, iFlyFMAU, FlightDirectorU, AirbusDataU, PFDReadoutsU;

 Type
  TMAXFlightInfo = Record
   FlightNumber : String;
   Transponder  : String;
   Selcal       : String;
   Registration : String;
   UTC          : String;
   Date         : String;
   Elapsed      : String;
  End;

  TPFD737Display = Class(TCustomControl)
   Private
    fInfo          : TMAXFlightInfo;
    fReadoutData   : TAirbusData;
    fSpeedText     : String;
    fBaroText      : String;
    fRadios        : Array [1..2] Of TRadioReadout;
    fWindAngle     : Double;
    fFD            : TFlightDirectorSampler;
    fFMA           : T737FMA;
    fSampler       : TSixPackDisplay;
    fBuffer        : TBitmap;
    fLayout        : TBitmap;
    fSpeed         : Double;
    fAltitude      : Double;
    fHeading       : Double;
    fRadioHeight   : Double;
    fMach          : Double;
    fAoA           : Double;
    fGroundSpeed   : Double;
    fTrueSpeed     : Double;
    fWind          : Double;
    fWindDirection : Double;
    fOnGround      : Double;
    Function  GetState : TSixPackState;
    Procedure Render;
   Protected
    Procedure Paint; Override;
   Public
    Constructor Create  (AOwner : TComponent); Override;
    Destructor  Destroy; Override;
    Procedure   SetPoint(Plot : TTripPlot; Index : Integer);
    Procedure   Clear;
    Property FlightInfo : TMAXFlightInfo Read fInfo;
    Property State      : TSixPackState Read GetState;
  End;

 Var
  B38MAoAEnabled  : Boolean = False;
  B38MInfoEnabled : Boolean = True;
  B38MInfoOnLeft  : Boolean = True;

 Function PFD737AoADegrees(Radians, OnGround, GroundSpeed : Double) : Double;
 Function PFD737VSIDeflection(FeetPerMinute : Double) : Double;

Implementation

 Uses
  InstrumentRenderU, Winapi.Windows, System.UITypes, System.DateUtils, System.SysUtils, System.Math, InstrumentDataU, ParameterNamesU, PFDScalesU;

 Function RecordedUTC(Const Stamp : String; Out d : TDateTime) : Boolean;
  Var
   s : String;
   i : Integer;
  Begin
   s := Stamp;
   i := Pos('_', s);
   If i > 0 Then
    SetLength(s, i - 1);
   Result := TryISO8601ToDate(s, d, True);
  End;

 Function InfoText(Const s : String) : String;
  Begin
   Result := Trim(s);
   If Result = '' Then
    Result := '--';
  End;

 Function RecordedFlightIdentifier(Const Airline, FlightNumber : String) : String;
  Var
   Prefix : String;
  Begin
   Result := UpperCase(Trim(FlightNumber));
   If Result = '' Then
    Exit('--');
   Prefix := UpperCase(Trim(Airline));
   // ATC AIRLINE can also contain a long display name. Only use a recorded
   // ICAO designator to prefix a number; complete callsigns already carry it.
   If (Length(Prefix) = 3) And CharInSet(Result[1], ['0'..'9']) Then
    If CharInSet(Prefix[1], ['A'..'Z']) And CharInSet(Prefix[2], ['A'..'Z']) And
    CharInSet(Prefix[3], ['A'..'Z']) Then
     Result := Prefix + Result;
  End;

 Function MAXFlightInfo(Plot : TTripPlot; Index : Integer) : TMAXFlightInfo;
  Var
   d          : TDateTime;
   Start      : TDateTime;
   i          : Integer;
   Digit      : Integer;
   v          : Double;
   Duration   : Int64;
   StartStamp : String;
  Begin
   Result.FlightNumber := '--';
   Result.Transponder  := '--';
   Result.Selcal       := '--';
   Result.Registration := '--';
   Result.UTC          := '--';
   Result.Date         := '--';
   Result.Elapsed      := '--';
   If (Plot = Nil) Or (Index < 0) Or (Index >= Plot.Points.Count) Then
    Exit;
   Result.FlightNumber := RecordedFlightIdentifier(Plot.Airline, Plot.FlightNumber);
   Result.Registration := InfoText(Plot.Registration);
   Result.Selcal       := InfoText(Plot.Selcal);
   Digit               := 1000;
   Result.Transponder  := '';
   For i               := 0 To 3 Do
    Begin
     v := InstrumentValue(Plot, Index, 'iFlySDK.Transponder_Windows_Digital_' + IntToStr(Digit) + '_Status');
     If Not InstrumentValid(v) Or (v < 0) Or (v > 7) Or (v <> Trunc(v)) Then
      Begin
       Result.Transponder := '--';
       Break;
      End;
     Result.Transponder := Result.Transponder + IntToStr(Trunc(v));
     Digit              := Digit Div 10;
    End;
   If Not RecordedUTC(Plot.DisplayPoint(Index).Time, d) Then
    Exit;
   Result.UTC  := FormatDateTime('hh:nn:ss', d) + ' Z';
   Result.Date := FormatDateTime('yyyy-mm-dd', d);
   StartStamp  := Plot.RecordedStartTime;
   If Trim(StartStamp) = '' Then
    StartStamp := Plot.Points[0].Time;
   If RecordedUTC(StartStamp, Start) And (d >= Start) Then
    Begin
     Duration       := Trunc((d - Start) * 86400 + 0.001);
     Result.Elapsed := Format('%.2d:%.2d:%.2d', [Duration Div 3600, (Duration Div 60) Mod 60, Duration Mod 60]);
    End;
  End;

 Function PFD737AoADegrees(Radians, OnGround, GroundSpeed : Double) : Double;
  Begin
   Result := NaN;
   If Not InstrumentValid(Radians) Or (Abs(Radians) > Pi / 2) Then
    Exit;
   Result := RadToDeg(Radians);
   If InstrumentValid(OnGround) And (OnGround <> 0) And InstrumentValid(GroundSpeed) And (GroundSpeed < 80) Then
    Result := 0;
  End;

 Function PFD737VSIDeflection(FeetPerMinute : Double) : Double;
  Begin
   Result := PFDVSIDeflection(FeetPerMinute);
  End;

 Constructor TPFD737Display.Create(AOwner : TComponent);
  Begin
   Inherited;
   DoubleBuffered      := True;
   ParentBiDiMode      := False;
   BiDiMode            := bdLeftToRight;
   fSampler            := TSixPackDisplay.Create(Self);
   fFD                 := TFlightDirectorSampler.Create;
   fReadoutData        := TAirbusData.Create;
   fBuffer             := Vcl.Graphics.TBitmap.Create;
   fLayout             := Vcl.Graphics.TBitmap.Create;
   fLayout.PixelFormat := pf32bit;
   fBuffer.PixelFormat := pf32bit;
   fBuffer.SetSize(600, 640);
   Clear;
  End;

 Destructor TPFD737Display.Destroy;
  Begin
   fFD.Free;
   fReadoutData.Free;
   fBuffer.Free;
   fLayout.Free;
   Inherited;
  End;

 Function TPFD737Display.GetState : TSixPackState;
  Begin
   Result := fSampler.State;
  End;

 Procedure TPFD737Display.Clear;
  Begin
   fReadoutData.Clear;
   fSpeedText := '--';
   fBaroText  := 'BARO --';
   fWindAngle := NaN;
   fRadios[1] := Default(TRadioReadout);
   fRadios[2] := Default(TRadioReadout);
   fSampler.Clear;
   fInfo := MAXFlightInfo(Nil, 0);
   If fFD <> Nil Then
    fFD.Clear;
   fFMA           := Default(T737FMA);
   fSpeed         := NaN;
   fAltitude      := NaN;
   fHeading       := NaN;
   fRadioHeight   := NaN;
   fMach          := NaN;
   fAoA           := NaN;
   fGroundSpeed   := NaN;
   fTrueSpeed     := NaN;
   fWind          := NaN;
   fWindDirection := NaN;
   fOnGround      := NaN;
   Invalidate;
  End;

 Procedure TPFD737Display.SetPoint(Plot : TTripPlot; Index : Integer);
  Begin
   fReadoutData.SetPoint(Plot, Index);
   fSpeedText := PFDSpeedCaption(fReadoutData, Plot, Index, True);
   fBaroText  := PFDBaroCaption(fReadoutData, False);
   fRadios[1] := PFDRadio(fReadoutData, 1);
   fRadios[2] := PFDRadio(fReadoutData, 2);
   fWindAngle := PFDWindDirection(fReadoutData.Value('ambient_wind_direction'), fReadoutData.Value('plane_heading_degrees_true'));
   fSampler.SetPoint(Plot, Index);
   fInfo := MAXFlightInfo(Plot, Index);
   fFD.SetPoint(Plot, Index, False);
   fFMA           := ReconstructIFlyFMA(Plot, Index);
   fSpeed         := InstrumentValue(Plot, Index, 'autopilot_airspeed_hold_var');
   fAltitude      := InstrumentValue(Plot, Index, 'autopilot_altitude_lock_var');
   fHeading       := InstrumentValue(Plot, Index, 'autopilot_heading_lock_dir');
   fRadioHeight   := InstrumentValue(Plot, Index, 'radio_height');
   fMach          := InstrumentValue(Plot, Index, 'airspeed_mach');
   fAoA           := InstrumentValue(Plot, Index, 'incidence_alpha');
   fGroundSpeed   := InstrumentValue(Plot, Index, 'ground_velocity');
   fTrueSpeed     := InstrumentValue(Plot, Index, 'airspeed_true');
   fWind          := InstrumentValue(Plot, Index, 'ambient_wind_velocity');
   fWindDirection := InstrumentValue(Plot, Index, 'ambient_wind_direction');
   fOnGround      := InstrumentValue(Plot, Index, 'sim_on_ground');
   If InstrumentValid(IFlyMCPValue(Plot, Index, 'ALT')) Then
    fAltitude := IFlyMCPValue(Plot, Index, 'ALT');
   If InstrumentValid(IFlyMCPValue(Plot, Index, 'HDG')) Then
    fHeading := IFlyMCPValue(Plot, Index, 'HDG');
   If InstrumentValid(IFlyMCPValue(Plot, Index, 'SPD')) Then
    fSpeed := IFlyMCPValue(Plot, Index, 'SPD');
   Invalidate;
  End;

 Procedure TPFD737Display.Render;
  Var
   c     : TCanvas;
   s     : TSixPackState;
   i     : Integer;
   j     : Integer;
   x     : Integer;
   y     : Integer;
   DC    : Integer;
   Pitch : Double;
   Roll  : Double;
   a     : Double;
   v     : Double;
   FD    : TFlightDirectorState;
   FDY   : Double;
   Arc   : Array [0..36] Of TPoint;
   p     : Array [0..3] Of TPoint;

   Procedure Text(x, y : Integer; Const Value : String; Color : TColor; Size : Integer = 16);
    Begin
     c.Brush.Style := bsClear;
     c.Font.Name   := 'Consolas';
     c.Font.Size   := Size;
     c.Font.Color  := Color;
     SetBkMode(c.Handle, TRANSPARENT);
     c.TextOut(x, y, Value);
    End;

   Procedure Line(X1, Y1, X2, Y2 : Integer; Color : TColor; w : Integer = 1);
    Begin
     c.Pen.Color := Color;
     c.Pen.Width := w;
     c.MoveTo(X1, Y1);
     c.LineTo(X2, Y2);
    End;

   Procedure Box(l, t, r, b : Integer; Color : TColor);
    Begin
     c.Brush.Color := Color;
     c.Brush.Style := bsSolid;
     c.Pen.Color   := Color;
     c.Pen.Width   := 1;
     c.Rectangle(l, t, r, b);
    End;

   Function Number(Const Param : String; Raw : Double) : String;
    Begin
     If InstrumentValid(Raw) Then
      Result := Format('%.0f', [ParameterDisplayValue(Param, Raw)])
     Else
      Result := '--';
    End;

   Function H(x, y : Double) : TPoint;
    Begin
     Result := Point(285 + Round(x * Cos(Roll) - y * Sin(Roll)), 285 + Round(x * Sin(Roll) + y * Cos(Roll)));
    End;

   Procedure Ground(Y1, Y2 : Double; Color : TColor);
    Begin
     p[0]          := H( -1000, Y1);
     p[1]          := H(1000, Y1);
     p[2]          := H(1000, Y2);
     p[3]          := H( -1000, Y2);
     c.Brush.Color := Color;
     c.Brush.Style := bsSolid;
     c.Pen.Color   := Color;
     c.Polygon(p);
    End;

   Procedure Diamond(x, y : Integer; EndStop : Boolean);
    Begin
     p[0]          := Point(x, y - 8);
     p[1]          := Point(x + 8, y);
     p[2]          := Point(x, y + 8);
     p[3]          := Point(x - 8, y);
     c.Brush.Color := clFuchsia;
     If EndStop Then
      c.Brush.Style := bsClear
     Else
      c.Brush.Style := bsSolid;
     c.Pen.Width    := 2;
     c.Pen.Color    := clFuchsia;
     c.Polygon(p);
    End;

   Procedure Tape(Raw : Double; IsAltitude : Boolean);
    Begin
     If IsAltitude Then
      Begin
       DrawPFDTape(c, Rect(452, 135, 530, 435), Raw, 'indicated_altitude', 100, 450);
       Text(452, 440, ParameterDisplayUnit('indicated_altitude'), clWhite, 11);
      End
     Else
      Begin
       DrawPFDTape(c, Rect(20, 135, 108, 435), Raw, 'airspeed_indicated', 10, 50);
       Text(20, 440, ParameterDisplayUnit('airspeed_indicated'), clWhite, 11);
      End;
    End;

   Procedure Flag(x : Integer; Const Name : String; Value : Double);
    Var
     t   : String;
     Col : TColor;
    Begin
     t   := Name + ' --';
     Col := clSilver;
     If InstrumentValid(Value) Then
      Begin
       If Value <> 0 Then
        Begin
         t   := Name + ' ON';
         Col := clLime;
        End
       Else
        t := Name + ' OFF';
      End;
     Text(x, 17, t, Col, 13);
    End;

  Begin
   c := fBuffer.Canvas;
   s := State;
   Box(0, 0, 860, 640, clBlack);
   Box(130, 8, 535, 52, $00474747);
   Line(260, 8, 260, 52, clWhite);
   Line(395, 8, 395, 52, clWhite);
   Text(134, 12, fFMA.Thrust, clLime, 12);
   Text(265, 12, fFMA.Roll, clLime, 12);
   Text(265, 35, fFMA.RollArmed, clWhite, 10);
   Text(400, 12, fFMA.Pitch, clLime, 12);
   Text(400, 35, fFMA.PitchArmed, clWhite, 10);
   Text(10, 632, 'FMA EST', clSilver, 7);
   Text(20, 85, fSpeedText, clFuchsia, 19);
   Text(450, 85, Number('indicated_altitude', fAltitude), clFuchsia, 19);

   Box(0, 70, 600, 470, $00282828);
   If InstrumentValid(s.Pitch) And InstrumentValid(s.Bank) Then
    Begin
     Pitch := EnsureRange(s.Pitch, -80.0, 80.0) * 5;
     Roll  := DegToRad(s.Bank);
     DC    := SaveDC(c.Handle);
     Try
      IntersectClipRect(c.Handle, 0, 70, 600, 470);
      Ground( -1500, Pitch, $00B75E13);
      Ground(Pitch, 1500, $00366C93);
      p[0] := H( -1000, Pitch);
      p[1] := H(1000, Pitch);
      Line(p[0].x, p[0].y, p[1].x, p[1].y, clWhite, 2);
      IntersectClipRect(c.Handle, 140, 135, 430, 410);
      For i := -6 To 6 Do
       If i <> 0 Then
        Begin
         j := 25;
         If i Mod 2 = 0 Then
          j   := 55;
         p[0] := H( -j, Pitch - i * 25);
         p[1] := H(j, Pitch - i * 25);
         Line(p[0].x, p[0].y, p[1].x, p[1].y, clWhite);
         If i Mod 2 = 0 Then
          Begin
           p[0] := H(65, Pitch - i * 25);
           Text(p[0].x, p[0].y - 9, IntToStr(Abs(i * 5)), clWhite, 12);
           p[0] := H( -92, Pitch - i * 25);
           Text(p[0].x, p[0].y - 9, IntToStr(Abs(i * 5)), clWhite, 12);
          End;
        End;
     Finally
      RestoreDC(c.Handle, DC);
     End;
    End
   Else
    Text(230, 245, 'ATT --', clRed, 18);
   // Recorded attitude and standard Flight Director command deviations.
   For i := -6 To 6 Do
    If (Abs(i) <= 3) Or (i Mod 3 = 0) Then
     Begin
      a := DegToRad(i * 10);
      Line(285 + Round(Sin(a) * 128), 265 - Round(Cos(a) * 128), 285 + Round(Sin(a) * 118), 265 - Round(Cos(a) * 118), clWhite, 2);
     End;
   If InstrumentValid(s.Bank) Then
    Begin
     a := DegToRad(EnsureRange(s.Bank, -60.0, 60.0));
     Line(285 + Round(Sin(a) * 110), 265 - Round(Cos(a) * 110), 285 + Round(Sin(a) * 99), 265 - Round(Cos(a) * 99), clWhite, 3);
    End;
   Line(277, 143, 285, 132, clWhite, 2);
   Line(285, 132, 293, 143, clWhite, 2);
   Line(293, 143, 277, 143, clWhite, 2);
   Tape(s.IAS, False);
   Tape(s.Altitude, True);
   FD := fFD.State;
   If B38MFlightDirectorEnabled And FD.PitchValid And FD.BankValid Then
    Begin
     x   := 285 + Round(EnsureRange(FD.BankError, -30.0, 30.0) * 3);
     FDY := -EnsureRange(FD.PitchError, -15.0, 15.0) * 5;
     Line(190, 285 + Round(FDY), 380, 285 + Round(FDY), clFuchsia, 3);
     Line(x, 205, x, 365, clFuchsia, 3);
    End;
   If B38MFlightDirectorEnabled And FD.Selected And Not(FD.PitchValid And FD.BankValid) Then
    Text(145, 112, 'FD --', clSilver, 10);
   Line(180, 285, 245, 285, clWhite, 7);
   Line(325, 285, 390, 285, clWhite, 7);
   Line(180, 285, 245, 285, clBlack, 3);
   Line(325, 285, 390, 285, clBlack, 3);
   Line(245, 285, 245, 298, clWhite, 3);
   Line(325, 285, 325, 298, clWhite, 3);
   Box(282, 282, 288, 288, clWhite);
   Text(20, 85, fSpeedText, clFuchsia, 19);
   Text(450, 85, Number('indicated_altitude', fAltitude), clFuchsia, 19);
   If s.LocalizerValid Then
    Text(140, 94, 'ILS', clWhite, 12);
   If fFMA.Engagement <> '' Then
    Text(252, 106, fFMA.Engagement, clLime, 18);
   If s.LocalizerValid Then
    Begin
     For i := -2 To 2 Do
      Begin
       x             := 285 + i * 50;
       c.Brush.Style := bsClear;
       c.Pen.Width   := 1;
       c.Pen.Color   := clWhite;
       c.Ellipse(x - 4, 426, x + 4, 434);
      End;
     Diamond(285 + Round(s.Localizer * 100), 430, Abs(s.Localizer) >= 1);
    End;
   If s.GlideslopeValid Then
    Begin
     For i := -2 To 2 Do
      Begin
       y             := 272 + i * 55;
       c.Brush.Style := bsClear;
       c.Pen.Width   := 1;
       c.Pen.Color   := clWhite;
       c.Ellipse(436, y - 4, 444, y + 4);
      End;
     Diamond(440, 272 + Round(s.Glideslope * 110), Abs(s.Glideslope) >= 1);
    End;
   DrawPFDVSI(c, Rect(548, 135, 590, 435), s.VSI);
   Text(540, 110, Number('vertical_speed', s.VSI), clWhite, 12);
   Text(540, 440, ParameterDisplayUnit('vertical_speed'), clWhite, 9);
   // Half compass rose, magnetic heading at the fixed top index.
   For i := 0 To 36 Do
    Begin
     a      := Pi + i * Pi / 36;
     Arc[i] := Point(285 + Round(Cos(a) * 145), 620 + Round(Sin(a) * 145));
    End;
   c.Brush.Style := bsSolid;
   c.Brush.Color := $00515151;
   c.Pen.Color   := c.Brush.Color;
   c.Polygon(Arc);
   If InstrumentValid(s.Heading) Then
    For i := 0 To 71 Do
     Begin
      v := i * 5;
      a := v - s.Heading;
      a := a - 360 * Floor((a + 180) / 360);
      If Abs(a) > 90 Then
       Continue;
      a := DegToRad(a);
      x := 285 + Round(Sin(a) * 145);
      y := 620 - Round(Cos(a) * 145);
      Line(x, y, 285 + Round(Sin(a) * 135), 620 - Round(Cos(a) * 135), clWhite, 1);
      If i Mod 6 = 0 Then
       Text(275 + Round(Sin(a) * 118), 610 - Round(Cos(a) * 118), IntToStr(i * 5 Div 10), clWhite, 12);
     End;
   Line(278, 475, 285, 487, clWhite, 2);
   Line(285, 487, 292, 475, clWhite, 2);
   Line(292, 475, 278, 475, clWhite, 2);
   If InstrumentValid(fHeading) Then
    Begin
     If InstrumentValid(s.Heading) Then
      Begin
       a := fHeading - s.Heading;
       a := a - 360 * Floor((a + 180) / 360);
       If Abs(a) <= 90 Then
        Begin
         a := DegToRad(a);
         Line(285, 620, 285 + Round(Sin(a) * 145), 620 - Round(Cos(a) * 145), clFuchsia, 1);
        End;
      End;
     Text(210, 620, 'SEL HDG ' + Number('heading_indicator', fHeading) + ' MAG', clFuchsia, 10);
    End;
   Text(10, 478, 'GS ' + Number('ground_velocity', fGroundSpeed) + ' TAS ' + Number('airspeed_true', fTrueSpeed), clWhite, 10);
   Text(10, 498, Number('ambient_wind_direction', fWindDirection) + '/' + Number('ambient_wind_velocity', fWind), clWhite, 10);
   Text(440, 480, fBaroText, clLime, 11);
   If InstrumentValid(fWindAngle) And InstrumentValid(fWind) And (fWind > 0) Then
    Begin
     a := DegToRad(fWindAngle);
     x := 60 + Round(Sin(a) * 12);
     y := 550 - Round(Cos(a) * 12);
     Line(60 - Round(Sin(a) * 12), 550 + Round(Cos(a) * 12), x, y, clWhite, 2);
     Line(x, y, x - Round(Sin(a + 0.5) * 10), y + Round(Cos(a + 0.5) * 10), clWhite, 2);
     Line(x, y, x - Round(Sin(a - 0.5) * 10), y + Round(Cos(a - 0.5) * 10), clWhite, 2);
    End;
   For i := 1 To 2 Do
    If fRadios[i].LabelText <> '' Then
     Begin
      x := 10;
      If i = 2 Then
       x := 460;
      Text(x, 566, fRadios[i].LabelText, clLime, 11);
      Text(x, 584, fRadios[i].Frequency, clLime, 11);
      Text(x, 602, fRadios[i].Distance, clLime, 9);
     End;
   If InstrumentValid(fRadioHeight) And (fRadioHeight >= 0) And (fRadioHeight < 2500) Then
    Text(150, 455, 'RA ' + Number('indicated_altitude', fRadioHeight), clWhite, 13);
   If B38MAoAEnabled Then
    Begin
     j     := 0;
     DC    := 0;
     For i := 0 To 6 Do
      Begin
       a := DegToRad( -120 + i * 30);
       x := 390 + Round(Cos(a) * 28);
       y := 100 + Round(Sin(a) * 28);
       If i > 0 Then
        Line(j, DC, x, y, clWhite, 1);
       j  := x;
       DC := y;
      End;
     v := PFD737AoADegrees(fAoA, fOnGround, fGroundSpeed);
     If InstrumentValid(v) Then
      Begin
       a := DegToRad( -120 + (EnsureRange(v, -6.0, 21.0) + 6) * 180 / 27);
       Line(390, 100, 390 + Round(Cos(a) * 26), 100 + Round(Sin(a) * 26), clWhite, 2);
       Text(350, 104, Format('%.1f', [Round(v * 5) / 5]), clWhite, 10);
      End
     Else
      Text(350, 104, 'AOA --', clSilver, 9);
    End;
   If InstrumentValid(fMach) Then
    Text(10, 520, Format('M %.3f', [fMach]), clWhite, 13);
   If B38MInfoEnabled Then
    Begin
     DC := SaveDC(c.Handle);
     Try
      IntersectClipRect(c.Handle, 610, 70, 855, 315);
      Box(610, 70, 855, 315, $00533C36);
      Line(610, 70, 855, 70, clSilver);
      Line(610, 70, 610, 315, clSilver);
      Line(610, 315, 855, 315, clSilver);
      Line(855, 70, 855, 315, clSilver);
      Text(622, 92, 'FLT #', clAqua, 10);
      Text(704, 89, fInfo.FlightNumber, clWhite, 13);
      Text(622, 125, 'XPNDR', clAqua, 10);
      Text(704, 122, fInfo.Transponder, clWhite, 13);
      Text(622, 158, 'SELCAL', clAqua, 10);
      Text(704, 155, fInfo.Selcal, clWhite, 13);
      Text(622, 191, 'TAIL #', clAqua, 10);
      Text(704, 188, fInfo.Registration, clWhite, 13);
      Line(610, 223, 855, 223, clSilver);
      Text(622, 235, 'UTC TIME', clAqua, 9);
      Text(622, 253, fInfo.UTC, clWhite, 12);
      Text(622, 279, fInfo.Date, clWhite, 11);
      Text(747, 235, 'ELAPSED', clAqua, 9);
      Text(747, 253, fInfo.Elapsed, clWhite, 10);
     Finally
      RestoreDC(c.Handle, DC);
     End;
    End;

  End;

 Procedure TPFD737Display.Paint;
  Var
   Scale    : Double;
   w        : Integer;
   H        : Integer;
   LogicalW : Integer;
   RenderDC : Integer;
   SplitX   : Integer;
   Target   : TRect;
  Begin
   Canvas.Brush.Color := clBlack;
   Canvas.Brush.Style := bsSolid;
   Canvas.FillRect(ClientRect);
   If (ClientWidth < 1) Or (ClientHeight < 1) Then
    Exit;
   If B38MInfoEnabled Then
    LogicalW := 860
   Else
    LogicalW := 600;
   RenderDC  := BeginInstrumentRender(fBuffer, LogicalW, 640, ClientWidth, ClientHeight);
   Try
    Render;
   Finally
    EndInstrumentRender(fBuffer, RenderDC);
   End;
   Scale  := Min(ClientWidth / LogicalW, ClientHeight / 640);
   w      := Max(1, Round(LogicalW * Scale));
   H      := Max(1, Round(640 * Scale));
   Target := Rect((ClientWidth - w) Div 2, (ClientHeight - H) Div 2, (ClientWidth + w) Div 2, (ClientHeight + H) Div 2);
   SetStretchBltMode(Canvas.Handle, HALFTONE);
   SetBrushOrgEx(Canvas.Handle, 0, 0, Nil);
   If B38MInfoEnabled And B38MInfoOnLeft Then
    Begin
     fLayout.SetSize(fBuffer.Width, fBuffer.Height);
     SplitX := MulDiv(fBuffer.Width, 600, 860);
     fLayout.Canvas.CopyRect(Rect(0, 0, fBuffer.Width - SplitX, fBuffer.Height), fBuffer.Canvas, Rect(SplitX, 0, fBuffer.Width, fBuffer.Height));
     fLayout.Canvas.CopyRect(Rect(fBuffer.Width - SplitX, 0, fBuffer.Width, fBuffer.Height), fBuffer.Canvas, Rect(0, 0, SplitX, fBuffer.Height));
     DrawInstrumentBitmap(Canvas, Target, fLayout);
    End
   Else
    DrawInstrumentBitmap(Canvas, Target, fBuffer);
  End;

End.
