{$StackFrames On}
Unit SixPackU;

Interface

 Uses
  System.Classes, System.SysUtils, System.Types, System.Math, Vcl.Controls,
  Vcl.Graphics, FlightDatabaseU, InstrumentDataU;

 Type
  TSixPackState = Record
   Time            : String;
   IAS             : Double;
   Pitch           : Double;
   Bank            : Double;
   Altitude        : Double;
   Heading         : Double;
   VSI             : Double;
   TurnRate        : Double;
   Ball            : Double;
   Localizer       : Double;
   Glideslope      : Double;
   Baro            : Double;
   AP              : Double;
   fD              : Double;
   AT              : Double;
   LocalizerValid  : Boolean;
   GlideslopeValid : Boolean;
   StandardBaro    : Boolean;
   Kind            : TInstrumentKind;
  End;

  TSixPackParameter = (spIAS, spPitch, spBank, spAltitude, spHeading, spVSI, spTurnRate, spBall, spCDIValid, spLocalizer, spGPS, spCDI, spGSValid, spGS, spBaroMB, spBaroHG, spBaroSTD, spAP, spFD, spAT);

  TAltimeterAngles = Record
   Thousands        : Double;
   TenThousands     : Double;
   HundredThousands : Double;
  End;

  TSixPackDisplay = Class(TCustomControl)
   Private
    fRenderBuffer : TBitmap;
    fState        : TSixPackState;
    // Identity only: Clear before releasing a bound plot. Labels are revisioned.
    fCachedPlot     : TTripPlot;
    fCachedLabels   : TPlotLabels;
    fCachedRevision : UInt64;
    fCachedTitle    : String;
    fIndices        : Array [TSixPackParameter] Of Integer;
    fVSIFullScale   : Double;
    fIASFullScale   : Double;
    fKind           : TInstrumentKind;
    Procedure BindPlot(Plot : TTripPlot; Index : Integer);
    Procedure DrawInstruments;
    Procedure DrawGlass;
    Procedure DrawILS(c : TCanvas; CX, CY, r : Integer);
    Procedure DrawDial(c : TCanvas; CX, CY, r, Kind : Integer);
   Protected
    Procedure Paint; Override;
   Public
    Constructor Create(AOwner : TComponent); Override;
    Destructor Destroy; Override;
    Procedure Clear;
    Procedure SetPoint(Plot : TTripPlot; Index : Integer);
    Property State        : TSixPackState Read fState;
    Property VSIFullScale : Double Read fVSIFullScale;
    Property IASFullScale : Double Read fIASFullScale;
  End;

 Function AltimeterNeedleAngles(AltitudeFeet : Double) : TAltimeterAngles;

Implementation

 Uses
  InstrumentRenderU, Winapi.Windows, ParameterNamesU, PFDScalesU;

 Const
  SixPackNames : Array [TSixPackParameter] Of String = ('airspeed_indicated', 'plane_pitch_degrees', 'plane_bank_degrees', 'indicated_altitude', 'heading_indicator', 'vertical_speed', 'turn_indicator_rate', 'turn_coordinator_ball', 'hsi_cdi_valid', 'hsi_has_localizer', 'gps_drives_nav1', 'hsi_cdi_needle', 'hsi_gsi_valid', 'hsi_gsi_needle', 'kohlsman_setting_mb', 'kohlsman_setting_hg', 'kohlsman_setting_std', 'autopilot_master', 'autopilot_flight_director_active', 'autothrottle_active');

 Function Valid(V : Double) : Boolean;
  Begin
   Result := Not IsNan(V) And Not IsInfinite(V);
  End;

 Function Angle(V : Double) : Double;
  Begin
   If Valid(V) Then
    Result := V - Floor(V / 360) * 360
   Else
    Result := NaN;
  End;

 Function AltimeterNeedleAngles(AltitudeFeet : Double) : TAltimeterAngles;
  Begin
   Result.Thousands        := Angle(AltitudeFeet / 1000 * 360);
   Result.TenThousands     := Angle(AltitudeFeet / 10000 * 360);
   Result.HundredThousands := Angle(AltitudeFeet / 100000 * 360);
  End;

 Function InstrumentRange(Peak, Minimum : Double) : Double;
  Var
   Step : Double;
  Begin
   Peak   := Max(Peak, Minimum);
   Step   := Power(10, Floor(Log10(Peak)));
   Result := Ceil(Peak / Step) * Step;
   If Not Valid(Result) Then
    Result := Peak;
  End;

 Procedure TSixPackDisplay.BindPlot(Plot : TTripPlot; Index : Integer);
  Var
   Parameter : TSixPackParameter;
   Point     : TPlotPoint;
   k         : Integer;
   PeakVSI   : Double;
   PeakIAS   : Double;
   Value     : Double;
   Profile   : TInstrumentProfile;
  Begin
   fCachedPlot          := Plot;
   fCachedLabels        := Plot.Labels;
   fCachedRevision      := Plot.Labels.Revision;
   fCachedTitle         := Plot.AircraftTitle + '|' + Plot.AircraftTypeICAO;
   For Parameter        := Low(TSixPackParameter) To High(TSixPackParameter) Do
    fIndices[Parameter] := Plot.Labels.IndexOf(SixPackNames[Parameter]);
   PeakVSI              := 2000;
   PeakIAS              := 400;
   // Replay plots are immutable. Determine raw ranges once, independent of cursor/units.
   For Point In Plot.Points Do
    Begin
     k := fIndices[spVSI];
     If (k >= 0) And (k < Length(Point.Values)) Then
      Begin
       Value := Point.Values[k];
       If Valid(Value) Then
        PeakVSI := Max(PeakVSI, Abs(Value));
      End;
     k := fIndices[spIAS];
     If (k >= 0) And (k < Length(Point.Values)) Then
      Begin
       Value := Point.Values[k];
       If Valid(Value) Then
        PeakIAS := Max(PeakIAS, Abs(Value));
      End;
    End;
   fVSIFullScale := InstrumentRange(PeakVSI, 2000);
   fIASFullScale := InstrumentRange(PeakIAS, 400);
   Profile       := InstrumentProfile(Plot, Index);
   fKind         := Profile.Kind;
  End;

 Constructor TSixPackDisplay.Create(AOwner : TComponent);
  Begin
   Inherited;
   fRenderBuffer  := Vcl.Graphics.TBitmap.Create;
   DoubleBuffered := True;
   Color          := $00202020;
   ParentBiDiMode := False;
   BiDiMode       := bdLeftToRight;
   Clear;
  End;

 Procedure TSixPackDisplay.Clear;
  Begin
   fCachedPlot            := Nil;
   fCachedLabels          := Nil;
   fCachedTitle           := '';
   fVSIFullScale          := 2000;
   fIASFullScale          := 400;
   fState.Time            := '';
   fState.IAS             := NaN;
   fState.Pitch           := NaN;
   fState.Bank            := NaN;
   fState.Localizer       := NaN;
   fState.Glideslope      := NaN;
   fState.Baro            := NaN;
   fState.LocalizerValid  := False;
   fState.GlideslopeValid := False;
   fState.StandardBaro    := False;
   fState.AP              := NaN;
   fState.fD              := NaN;
   fState.AT              := NaN;
   fState.Kind            := ikGaAnalog;
   fState.Altitude        := NaN;
   fState.Heading         := NaN;
   fState.VSI             := NaN;
   fState.TurnRate        := NaN;
   fState.Ball            := NaN;
   Invalidate;
  End;

 Procedure TSixPackDisplay.SetPoint(Plot : TTripPlot; Index : Integer);
  Var
   Sample : TPlotPoint;

   Function V(Parameter : TSixPackParameter) : Double;
    Var
     k : Integer;
    Begin
     Result := NaN;
     If Plot = Nil Then
      Exit;
     k := fIndices[Parameter];
     If (k >= 0) And (k < Length(Sample.Values)) Then
      Result := Sample.Values[k];
    End;

   Function Flag(Parameter : TSixPackParameter; Expected : Double) : Boolean;
    Var
     Value : Double;
    Begin
     Value  := V(Parameter);
     Result := InstrumentValid(Value) And (Value = Expected);
    End;

  Begin
   If (Plot = Nil) Or (Index < 0) Or (Index >= Plot.Points.Count) Then
    Begin
     Clear;
     Exit;
    End;
   If (Plot <> fCachedPlot) Or (Plot.Labels <> fCachedLabels) Or (Plot.Labels.Revision <> fCachedRevision) Or ((Plot.AircraftTitle + '|' + Plot.AircraftTypeICAO) <> fCachedTitle) Then
    BindPlot(Plot, Index);
   Sample                 := Plot.DisplayPoint(Index);
   fState.Time            := Sample.Time;
   fState.IAS             := V(spIAS);
   fState.Pitch           := -V(spPitch);
   fState.Bank            := V(spBank);
   fState.Altitude        := V(spAltitude);
   fState.Heading         := Angle(V(spHeading));
   fState.VSI             := V(spVSI);
   fState.TurnRate        := V(spTurnRate);
   fState.Ball            := V(spBall);
   fState.LocalizerValid  := Flag(spCDIValid, 1) And Flag(spLocalizer, 1) And Flag(spGPS, 0) And InstrumentValid(V(spCDI));
   fState.GlideslopeValid := Flag(spLocalizer, 1) And Flag(spGPS, 0) And Flag(spGSValid, 1) And InstrumentValid(V(spGS));
   fState.Localizer       := NaN;
   fState.Glideslope      := NaN;
   If fState.LocalizerValid Then
    fState.Localizer := EnsureRange(V(spCDI) / 127, -1.0, 1.0);
   If fState.GlideslopeValid Then
    fState.Glideslope := EnsureRange(V(spGS) / 119, -1.0, 1.0);
   fState.Baro        := V(spBaroMB);
   If Not InstrumentValid(fState.Baro) And InstrumentValid(V(spBaroHG)) Then
    fState.Baro := V(spBaroHG) * 33.8638866667;
   If InstrumentValid(fState.Baro) And (fState.Baro <= 0) Then
    fState.Baro        := NaN;
   fState.StandardBaro := Flag(spBaroSTD, 1);
   fState.AP           := V(spAP);
   fState.fD           := V(spFD);
   fState.AT           := V(spAT);
   fState.Kind         := fKind;
   Invalidate;
  End;

 Procedure TSixPackDisplay.DrawDial(c : TCanvas; CX, CY, r, Kind : Integer);
  Const
   Titles : Array [0..5] Of String = ('IAS', 'ATT', 'ALT', 'TURN', 'HDG', 'VSI');
  Var
   i       : Integer;
   x       : Integer;
   y       : Integer;
   Clip    : Integer;
   OldClip : Integer;
   HadClip : Integer;
   V       : Double;
   MaxV    : Double;
   a       : Double;
   Pitch   : Double;
   Roll    : Double;
   d       : Double;
   Needles : TAltimeterAngles;
   Name    : String;
   Units   : String;
   Text    : String;
   b       : TRect;
   Pts     : Array [0..3] Of TPoint;

   Function P(Angle, Radius : Double) : TPoint;
    Begin
     Result := Point(CX + Round(Sin(DegToRad(Angle)) * r * Radius), CY - Round(Cos(DegToRad(Angle)) * r * Radius));
    End;

   Procedure LabelAt(Const s : String; x, y : Integer; Col : TColor);
    Begin
     c.Brush.Style := bsClear;
     c.Font.Color  := Col;
     c.TextOut(x - c.TextWidth(s) Div 2, y - c.TextHeight(s) Div 2, s);
    End;

   Procedure Line(P1, P2 : TPoint; Col : TColor; Width : Integer);
    Begin
     c.Pen.Color := Col;
     c.Pen.Width := Width;
     c.MoveTo(P1.x, P1.y);
     c.LineTo(P2.x, P2.y);
    End;

   Procedure Needle(Angle, Length : Double; Col : TColor; Width : Integer);
    Begin
     Line(Point(CX, CY), P(Angle, Length), Col, Width);
    End;

   Function HP(x, y : Double) : TPoint;
    Begin
     Result := Point(CX + Round(x * Cos(Roll) - y * Sin(Roll)), CY + Round(x * Sin(Roll) + y * Cos(Roll)));
    End;

   Procedure HorizonPolygon(Y1, Y2 : Double; Col : TColor);
    Begin
     Pts[0]        := HP( -r * 4, Y1);
     Pts[1]        := HP(r * 4, Y1);
     Pts[2]        := HP(r * 4, Y2);
     Pts[3]        := HP( -r * 4, Y2);
     c.Brush.Style := bsSolid;
     c.Brush.Color := Col;
     c.Pen.Color   := Col;
     c.Polygon(Pts);
    End;

  Begin
   If r < 12 Then
    Exit;
   b             := Rect(CX - r, CY - r, CX + r, CY + r);
   c.Brush.Style := bsSolid;
   c.Brush.Color := $00101010;
   c.Pen.Width   := Max(2, r Div 30);
   c.Pen.Color   := $00686868;
   c.Ellipse(b);
   c.Font.Name  := 'Segoe UI';
   c.Font.Size  := Max(7, r Div 11);
   c.Font.Style := [];
   LabelAt(Titles[Kind], CX, CY + Round(r * 0.48), clSilver);
   If Kind = 1 Then
    Begin
     If Valid(fState.Pitch) And Valid(fState.Bank) Then
      Begin
       OldClip := CreateRectRgn(0, 0, 0, 0);
       HadClip := GetClipRgn(c.Handle, OldClip);
       Clip    := CreateEllipticRgn(b.Left + 3, b.Top + 3, b.Right - 3, b.Bottom - 3);
       SelectInstrumentClip(c, Clip, RGN_AND);
       Try
        Pitch := EnsureRange(fState.Pitch, -89.0, 89.0) * r / 45;
        Roll  := DegToRad(Angle(fState.Bank));
        HorizonPolygon( -r * 4, Pitch, $00BA7238);
        HorizonPolygon(Pitch, r * 4, $00315A82);
        Line(HP( -r * 3, Pitch), HP(r * 3, Pitch), clWhite, 2);
        For i := -3 To 3 Do
         If i <> 0 Then
          Begin
           d := Pitch - i * r * 10 / 45;
           Line(HP( -r * 0.22, d), HP(r * 0.22, d), clWhite, 1);
          End;
       Finally
        If HadClip = 1 Then
         SelectClipRgn(c.Handle, OldClip)
        Else
         SelectClipRgn(c.Handle, 0);
        DeleteObject(Clip);
        DeleteObject(OldClip);
       End;
       For i := -6 To 6 Do
        If i Mod 3 = 0 Then
         Line(P(i * 10, 0.94), P(i * 10, 0.84), clWhite, 1);
       Line(P(0, 0.94), P(0, 0.82), clYellow, 3);
       If Not(fState.Kind In [ikGaGlass, ikAirlinerPFD, ikB38MPFD, ikA320PFD]) Then
        LabelAt(Format('%.1f / %.1f', [fState.Pitch, -fState.Bank]), CX, CY + Round(r * 0.60), clWhite);
      End
     Else
      LabelAt('--', CX, CY, clSilver);
     Line(Point(CX - r Div 2, CY), Point(CX - r Div 7, CY), clYellow, 3);
     Line(Point(CX + r Div 7, CY), Point(CX + r Div 2, CY), clYellow, 3);
     Line(Point(CX - r Div 7, CY), Point(CX, CY + r Div 10), clYellow, 3);
     Line(Point(CX, CY + r Div 10), Point(CX + r Div 7, CY), clYellow, 3);
     If fState.LocalizerValid And Not(fState.Kind In [ikGaGlass, ikAirlinerPFD, ikB38MPFD, ikA320PFD]) Then
      Begin
       x := CX + Round(fState.Localizer * r * 0.55);
       Line(Point(x, CY - r Div 2), Point(x, CY + r Div 2), clFuchsia, 2);
       LabelAt('LOC', CX, CY + Round(r * 0.80), clFuchsia);
      End;
     If fState.GlideslopeValid And Not(fState.Kind In [ikGaGlass, ikAirlinerPFD, ikB38MPFD, ikA320PFD]) Then
      Begin
       y := CY + Round(fState.Glideslope * r * 0.55);
       Line(Point(CX - r Div 2, y), Point(CX + r Div 2, y), clFuchsia, 2);
       LabelAt('GS', CX + Round(r * 0.75), CY, clFuchsia);
      End;
     Exit;
    End;
   If Kind = 4 Then
    Begin
     If Not Valid(fState.Heading) Then
      Begin
       LabelAt('--', CX, CY, clSilver);
       Exit;
      End;
     For i := 0 To 35 Do
      Begin
       a := i * 10 - fState.Heading;
       Line(P(a, 0.94), P(a, 0.83), clWhite, 1);
       If i Mod 3 = 0 Then
        Begin
         Case i Of
          0  : Text := 'N';
          9  : Text := 'E';
          18 : Text := 'S';
          27 : Text := 'W';
         Else Text := IntToStr(i);
         End;
         Pts[0] := P(a, 0.68);
         LabelAt(Text, Pts[0].x, Pts[0].y, clWhite);
        End;
      End;
     Line(Point(CX, CY - r + 3), Point(CX, CY - r + r Div 5), clYellow, 3);
     LabelAt(Format('%.0f', [fState.Heading]), CX, CY, clWhite);
     Exit;
    End;
   If Kind = 3 Then
    Begin
     LabelAt('L', CX - r Div 2, CY - r Div 4, clWhite);
     LabelAt('R', CX + r Div 2, CY - r Div 4, clWhite);
     If Valid(fState.TurnRate) Then
      Begin
       a := EnsureRange(fState.TurnRate, -6.0, 6.0) * 5;
       Line(P(270 + a, 0.55), P(90 + a, 0.55), clWhite, 3);
       Needle(a, 0.18, clWhite, 3);
       LabelAt(Format('%.1f deg/s', [fState.TurnRate]), CX, CY + r Div 4, clWhite);
      End
     Else
      LabelAt('--', CX, CY, clSilver);
     c.Brush.Style := bsSolid;
     c.Brush.Color := $00C0C0C0;
     c.Pen.Width   := 1;
     c.Pen.Color   := clGray;
     c.RoundRect(CX - r Div 2, CY + r Div 2, CX + r Div 2, CY + r * 3 Div 4, r Div 6, r Div 6);
     If Valid(fState.Ball) Then
      Begin
       x             := CX + Round(EnsureRange(fState.Ball / 127, -1.0, 1.0) * r * 0.36);
       y             := CY + r * 5 Div 8;
       c.Brush.Color := clBlack;
       c.Ellipse(x - r Div 11, y - r Div 11, x + r Div 11, y + r Div 11);
      End
     Else
      LabelAt('--', CX, CY + r * 5 Div 8, clGray);
     Line(Point(CX - r Div 8, CY + r Div 2), Point(CX - r Div 8, CY + r * 3 Div 4), clBlack, 1);
     Line(Point(CX + r Div 8, CY + r Div 2), Point(CX + r Div 8, CY + r * 3 Div 4), clBlack, 1);
     Exit;
    End;
   Case Kind Of
    0 :
     Begin
      V    := fState.IAS;
      Name := 'airspeed_indicated';
      MaxV := fIASFullScale;
     End;
    2 :
     Begin
      V    := fState.Altitude;
      Name := 'indicated_altitude';
      MaxV := 1000;
     End;
   Else
     Begin
      V    := fState.VSI;
      Name := 'vertical_speed';
      MaxV := fVSIFullScale;
     End;
   End;
   V     := ParameterDisplayValue(Name, V);
   MaxV  := Abs(ParameterDisplayValue(Name, MaxV));
   Units := ParameterDisplayUnit(Name);
   For i := 0 To 10 Do
    Begin
     If Kind = 2 Then
      a := i * 36
     Else If Kind = 5 Then
      a := 150 + i * 24
     Else
      a := -135 + i * 27;
     Line(P(a, 0.94), P(a, 0.83), clWhite, 1);
     If ((i Mod 2 = 0) Or ((Kind = 5) And (i = 5))) And ((Kind <> 2) Or (i < 10)) And ((Kind <> 5) Or (r >= 60) Or (i = 0) Or (i = 5) Or (i = 10)) Then
      Begin
       If Kind = 2 Then
        Text := IntToStr(i)
       Else If Kind = 5 Then
        Begin
         d := -MaxV + i * MaxV / 5;
         If (Abs(d) >= 1000) And (Units = 'ft/min') Then
          Text := Format('%.1fk', [d / 1000])
         Else
          Text := Format('%.0f', [d]);
        End
       Else
        Text  := Format('%.0f', [i * MaxV / 10]);
       Pts[0] := P(a, 0.68);
       LabelAt(Text, Pts[0].x, Pts[0].y, clWhite);
      End;
    End;
   If Valid(V) Then
    Begin
     If Kind = 2 Then
      Begin
       Needles := AltimeterNeedleAngles(fState.Altitude);
       Needle(Needles.HundredThousands, 0.35, clSilver, 2);
       Needle(Needles.TenThousands, 0.53, clWhite, 3);
       Needle(Needles.Thousands, 0.78, clWhite, 2);
      End
     Else
      Begin
       If Kind = 5 Then
        a := 270 + EnsureRange(V / MaxV, -1.0, 1.0) * 120
       Else
        a := -135 + EnsureRange(V / MaxV, 0.0, 1.0) * 270;
       Needle(a, 0.79, clWhite, 2);
      End;
     Text := Format('%.0f %s', [V, Units]);
    End
   Else
    Text := '-- ' + Units;
   If Kind = 5 Then
    LabelAt(Text, CX, CY - r - 12, clWhite)
   Else
    LabelAt(Text, CX, CY + Round(r * 0.30), clWhite);
   If Kind = 2 Then
    LabelAt('FT', CX, CY - Round(r * 0.30), clSilver);
   If (Kind = 2) And InstrumentValid(fState.Baro) Then
    Begin
     Text := Format('%.2f %s', [ParameterDisplayValue('kohlsman_setting_mb', fState.Baro), ParameterDisplayUnit('kohlsman_setting_mb')]);
     If fState.StandardBaro Then
      Text       := 'STD ' + Text;
     c.Font.Size := Max(7, r Div 14);
     LabelAt(Text, CX, CY + Round(r * 0.70), clAqua);
    End;
  End;

 Procedure TSixPackDisplay.DrawILS(c : TCanvas; CX, CY, r : Integer);
  Var
   i      : Integer;
   Span   : Integer;
   Offset : Integer;
   Dot    : Integer;
   Size   : Integer;
   x      : Integer;
   y      : Integer;

   Procedure Diamond(x, y : Integer; FullScale : Boolean);
    Var
     P : Array [0..3] Of TPoint;
    Begin
     P[0]        := Point(x, y - Size);
     P[1]        := Point(x + Size, y);
     P[2]        := Point(x, y + Size);
     P[3]        := Point(x - Size, y);
     c.Pen.Color := clFuchsia;
     c.Pen.Width := 2;
     // A hollow end-stop symbol distinguishes full-scale deflection.
     c.Brush.Color := clFuchsia;
     If FullScale Then
      c.Brush.Style := bsClear
     Else
      c.Brush.Style := bsSolid;
     c.Polygon(P);
    End;

  Begin
   If r < 28 Then
    Exit;
   Span         := Max(12, Round(r * 0.50));
   Offset       := Round(r * 0.82);
   Dot          := Max(1, r Div 90);
   Size         := Max(4, r Div 28);
   c.Font.Name  := 'Segoe UI';
   c.Font.Size  := Max(7, Min(10, r Div 16));
   c.Font.Style := [];
   c.Font.Color := clWhite;
   // Scales are fixed to the instrument face, independent of bank and pitch.
   If fState.LocalizerValid Then
    Begin
     y             := CY + Offset;
     c.Pen.Width   := 1;
     c.Pen.Color   := clWhite;
     c.Brush.Style := bsClear;
     For i         := -2 To 2 Do
      If i <> 0 Then
       Begin
        x := CX + Round(i * Span / 2);
        c.Ellipse(x - Dot, y - Dot, x + Dot + 1, y + Dot + 1);
       End;
     c.MoveTo(CX, y - Size);
     c.LineTo(CX, y + Size + 1);
     If Not(fState.Kind In [ikGaGlass, ikAirlinerPFD, ikB38MPFD, ikA320PFD]) Then
      c.TextOut(CX - c.TextWidth('LOC') Div 2, y + Size + 3, 'LOC');
     Diamond(CX + Round(fState.Localizer * Span), y, Abs(fState.Localizer) >= 1);
    End;
   If fState.GlideslopeValid Then
    Begin
     x             := CX + Offset;
     c.Pen.Width   := 1;
     c.Pen.Color   := clWhite;
     c.Brush.Style := bsClear;
     For i         := -2 To 2 Do
      If i <> 0 Then
       Begin
        y := CY + Round(i * Span / 2);
        c.Ellipse(x - Dot, y - Dot, x + Dot + 1, y + Dot + 1);
       End;
     c.MoveTo(x - Size, CY);
     c.LineTo(x + Size + 1, CY);
     c.TextOut(x - c.TextWidth('GS') Div 2, CY - Span - Size - c.TextHeight('GS') - 2, 'GS');
     Diamond(x, CY + Round(fState.Glideslope * Span), Abs(fState.Glideslope) >= 1);
    End;
   c.Brush.Style := bsSolid;
   c.Pen.Width   := 1;
  End;

 Procedure TSixPackDisplay.DrawGlass;
  Var
   r       : Integer;
   CX      : Integer;
   CY      : Integer;
   TapeW   : Integer;
   VSIW    : Integer;
   TopY    : Integer;
   BottomY : Integer;
   RightX  : Integer;
   Text    : String;
   c       : TCanvas;

   Function Status(V : Double) : String;
    Begin
     If Not InstrumentValid(V) Then
      Result := '--'
     Else If V = 0 Then
      Result := '0'
     Else
      Result := '1';
    End;

   Procedure LabelAt(x, y : Integer; Const Value : String; Col : TColor);
    Begin
     c.Font.Name   := 'Consolas';
     c.Font.Size   := 9;
     c.Font.Style  := [];
     c.Font.Color  := Col;
     c.Brush.Style := bsClear;
     c.TextOut(x, y, Value);
    End;

  Begin
   c := fRenderBuffer.Canvas;
   LabelAt(6, 5, InstrumentKindName(fState.Kind) + '  AP ' + Status(fState.AP) + ' FD ' + Status(fState.fD) + ' A/T ' + Status(fState.AT), clSilver);
   If InstrumentValid(fState.Baro) Then
    Begin
     Text := Format('BARO %.2f %s', [ParameterDisplayValue('kohlsman_setting_mb', fState.Baro), ParameterDisplayUnit('kohlsman_setting_mb')]);
     If fState.StandardBaro Then
      Text := 'STD ' + Text;
     LabelAt(6, 23, Text, clAqua);
    End;
   If (Width < 210) Or (Height < 105) Then
    Exit;
   TapeW   := Max(40, Min(90, Width Div 6));
   VSIW    := Max(30, Min(58, Width Div 9));
   TopY    := 47;
   BottomY := Height - 24;
   RightX  := Width - VSIW - TapeW - 14;
   r       := Max(12, Min((RightX - TapeW - 30) Div 2, (BottomY - TopY - 24) Div 2));
   CX      := (TapeW + 10 + RightX) Div 2;
   CY      := TopY + (BottomY - TopY - 20) Div 2;
   DrawDial(c, CX, CY, r, 1);
   DrawILS(c, CX, CY, r);
   If InstrumentValid(fState.Heading) Then
    Text := Format('HDG %.0f', [fState.Heading])
   Else
    Text := 'HDG --';
   LabelAt(CX - 32, CY + r + 7, Text, clWhite);
   DrawPFDTape(c, Rect(4, TopY, 4 + TapeW, BottomY), fState.IAS, 'airspeed_indicated', 10, 50);
   DrawPFDTape(c, Rect(RightX, TopY, RightX + TapeW, BottomY), fState.Altitude, 'indicated_altitude', 100, 450);
   DrawPFDVSI(c, Rect(Width - VSIW - 4, TopY, Width - 4, BottomY), fState.VSI);
   LabelAt(4, BottomY + 3, ParameterDisplayUnit('airspeed_indicated'), clSilver);
   LabelAt(RightX, BottomY + 3, ParameterDisplayUnit('indicated_altitude'), clSilver);
   LabelAt(Width - VSIW - 4, BottomY + 3, 'V/S', clSilver);
  End;

 Destructor TSixPackDisplay.Destroy;
  Begin
   fRenderBuffer.Free;
   Inherited;
  End;

 Procedure TSixPackDisplay.Paint;
  Var
   DC : Integer;
  Begin
   If (ClientWidth < 1) Or (ClientHeight < 1) Then
    Exit;
   DC := BeginInstrumentRender(fRenderBuffer, ClientWidth, ClientHeight, ClientWidth, ClientHeight);
   Try
    DrawInstruments;
   Finally
    EndInstrumentRender(fRenderBuffer, DC);
   End;
   DrawInstrumentBitmap(Canvas, ClientRect, fRenderBuffer);
  End;

 Procedure TSixPackDisplay.DrawInstruments;
  Var
   i    : Integer;
   CW   : Integer;
   CH   : Integer;
   r    : Integer;
   Left : Integer;
   Top  : Integer;
  Begin
   fRenderBuffer.Canvas.Brush.Style := bsSolid;
   fRenderBuffer.Canvas.Brush.Color := Color;
   fRenderBuffer.Canvas.FillRect(ClientRect);
   If fState.Kind In [ikGaGlass, ikAirlinerPFD, ikB38MPFD, ikA320PFD] Then
    Begin
     DrawGlass;
     Exit;
    End;
   CW    := ClientWidth Div 3;
   CH    := ClientHeight Div 2;
   r     := Min(CW, CH) Div 2 - 8;
   Left  := (ClientWidth - CW * 3) Div 2;
   Top   := (ClientHeight - CH * 2) Div 2;
   For i := 0 To 5 Do
    DrawDial(fRenderBuffer.Canvas, Left + CW * (i Mod 3) + CW Div 2, Top + CH * (i Div 3) + CH Div 2, r, i);
  End;

End.
