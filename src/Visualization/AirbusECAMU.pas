Unit AirbusECAMU;

Interface

 Uses
  System.Classes, AirbusDisplayU, AirbusDataU;

 Type
  TAirbusEWD = Class(TAirbusDisplay)
   Protected
    Procedure Render; Override;
  End;

  TAirbusSD = Class(TAirbusDisplay)
   Private
    fPage : Integer;
    Procedure SetPage   (Value : Integer);
    Procedure Footer;
    Procedure EnginePage(Cruise : Boolean);
    Procedure BleedPage;
    Procedure PressPage;
    Procedure ElecPage;
    Procedure HydPage;
    Procedure FuelPage;
    Procedure ApuPage;
    Procedure CondPage;
    Procedure DoorPage;
    Procedure WheelPage;
    Procedure FlightControlPage;
    Procedure StatusPage;
   Protected
    Procedure Render; Override;
   Public
    Constructor Create(AOwner : TComponent); Override;
    Property Page : Integer Read fPage Write SetPage;
    Function DisplayedPage : Integer;
  End;

Implementation

 Uses
  System.SysUtils, System.Math, Vcl.Graphics, InstrumentDataU, AirbusMessagesU;

 Procedure TAirbusEWD.Render;
  Var
   e    : Integer;
   x    : Integer;
   Mode : Integer;
   v    : Double;
  Begin
   For e := 1 To 2 Do
    Begin
     x := 140 + (e - 1) * 350;
     Gauge(x, 135, 80, fData.Engine('turb_eng_n1', e), 110, 'N1 %');
     Gauge(x, 285, 80, fData.Engine('eng_exhaust_gas_temperature', e), 1000, 'EGT C');
     Number(x - 45, 365, fData.Engine('turb_eng_n2', e), 1);
     Text(x - 30, 395, 'N2 %', clWhite, 12);
     v := fData.FBW('A32NX_ENGINE_FF:' + IntToStr(e));
     If Not InstrumentValid(v) Then
      v := fData.Engine('turb_eng_fuel_flow_pph', e) * 0.45359237;
     Number(x - 45, 430, v, 0);
     Text(x - 65, 460, 'FF KG/H', clAqua, 12);
    End;
   Text(245, 10, 'E / WD', clWhite, 15);
   v := fData.FBW('A32NX_AUTOTHRUST_THRUST_LIMIT');
   Number(470, 8, v, 1, clAqua);
   v := fData.FBW('A32NX_AUTOTHRUST_THRUST_LIMIT_TYPE');
   If InstrumentValid(v) Then
    Begin
     Mode := Trunc(v);
     Case Mode Of
      1 : Text(400, 8, 'CLB', clAqua, 14);
      2 : Text(400, 8, 'MCT', clAqua, 14);
      3 : Text(400, 8, 'FLEX', clAqua, 14);
      4 : Text(400, 8, 'TOGA', clAqua, 14);
      5 : Text(400, 8, 'REV', clAqua, 14);
     End;
    End;
   Text(10, 490, 'FOB', clWhite);
   Number(75, 490, fData.Value('fuel_total_quantity_weight') * 0.45359237);
   Text(180, 490, 'KG', clAqua, 12);
   Text(335, 490, 'FLAPS', clWhite, 12);
   Number(405, 490, fData.Value('trailing_edge_flaps_left_angle'), 1);
   Line(5, 525, 635, 525);
   Line(320, 535, 320, 635);
   DrawAirbusText(fBuffer.Canvas, 5, 532, 9, 15, AirbusMessageLines(fData, False), Frac(fData.Seconds) < 0.5);
   DrawAirbusText(fBuffer.Canvas, 325, 532, 9, 15, AirbusMessageLines(fData, True), Frac(fData.Seconds) < 0.5);
  End;

 Constructor TAirbusSD.Create(AOwner : TComponent);
  Begin
   Inherited;
   fPage := -1;
  End;

 Procedure TAirbusSD.SetPage(Value : Integer);
  Begin
   If (Value < -1) Or (Value > Ord(High(TAirbusSDPage))) Then
    Value := -1;
   fPage  := Value;
   Invalidate;
  End;

 Function TAirbusSD.DisplayedPage : Integer;
  Begin
   Result := fPage;
   If Result < 0 Then
    Result := fData.RecordedPage;
  End;

 Procedure TAirbusSD.Footer;
  Begin
   Line(2, 550, 638, 550);
   Line(210, 550, 210, 637);
   Line(425, 550, 425, 637);
   Text(10, 563, 'TAT', clWhite, 13);
   Number(70, 563, fData.Value('total_air_temperature'));
   Text(155, 563, 'C', clAqua, 12);
   Text(10, 597, 'SAT', clWhite, 13);
   Number(70, 597, fData.Value('ambient_temperature'));
   Text(155, 597, 'C', clAqua, 12);
   Text(235, 582, Copy(fData.Time, 12, 5), clLime, 17);
   Text(445, 565, 'GW', clWhite, 13);
   Number(485, 565, fData.Value('total_weight') * 0.45359237);
   Text(545, 600, 'KG', clAqua, 12);
  End;

 Procedure TAirbusSD.EnginePage(Cruise : Boolean);
  Var
   e : Integer;
   x : Integer;
  Begin
   For e := 1 To 2 Do
    Begin
     x := 145 + (e - 1) * 350;
     Text(x - 10, 65, IntToStr(e));
     Number(x - 35, 110, fData.FBW('A32NX_FUEL_USED:' + IntToStr(e)));
     Text(x - 50, 140, 'F.USED KG', clAqua, 12);
     Gauge(x, 240, 75, fData.Engine('eng_oil_quantity', e) * 100, 100, 'OIL %');
     If Not Cruise Then
      Begin
       Gauge(x, 390, 75, fData.Engine('eng_oil_pressure', e) / 144, 120, 'OIL PSI');
       Number(x - 35, 455, fData.Engine('eng_oil_temperature', e));
       Text(x - 55, 485, 'OIL TEMP C', clAqua, 12);
      End
     Else
      Begin
       Number(x - 25, 330, fData.Engine('turb_eng_vibration', e), 1);
       Text(x - 45, 365, 'VIB', clWhite, 13);
      End;
    End;
   If Cruise Then
    Begin
     Text(220, 410, 'CAB ALT FT', clAqua, 12);
     Number(245, 440, fData.Cabin('CABIN_ALTITUDE'));
    End;
  End;

 Procedure TAirbusSD.BleedPage;
  Var
   e : Integer;
   x : Integer;
   v : Double;
  Begin
   For e := 1 To 2 Do
    Begin
     x := 140 + (e - 1) * 360;
     Text(x - 20, 80, 'PACK ' + IntToStr(e), clWhite, 13);
     v := fData.FBW('A32NX_COND_PACK_FLOW_VALVE_' + IntToStr(e) + '_IS_OPEN');
     If InstrumentValid(v) And (v <> 0) Then
      Line(x, 120, x, 460, clLime, 2)
     Else
      Line(x, 120, x, 460, clGray, 2);
     Box(x - 70, 145, x + 70, 225);
     Text(x - 60, 158, 'PACK FLOW', clWhite, 11);
     Number(x - 30, 187, fData.FBW('A32NX_COND_PACK_FLOW'));
     Number(x - 30, 335, fData.FBW('A32NX_PNEU_ENG_' + IntToStr(e) + '_REGULATED_TRANSDUCER_PRESSURE'));
     Text(x - 50, 370, 'PSI', clAqua, 13);
     Text(x - 15, 465, IntToStr(e));
    End;
   Line(140, 420, 500, 420, clGray);
   Line(320, 420, 320, 475, clGray);
   Text(290, 485, 'APU', clWhite, 13);
  End;

 Procedure TAirbusSD.PressPage;
  Begin
   Gauge(110, 230, 75, fData.Cabin('CABIN_DELTA_PRESSURE'), 10, 'DELTA P PSI');
   Gauge(320, 230, 75, fData.Cabin('CABIN_VS'), 2000, 'CAB V/S FT/MIN');
   Gauge(530, 230, 75, fData.Cabin('CABIN_ALTITUDE'), 15000, 'CAB ALT FT');
   Line(80, 360, 560, 360);
   Line(80, 360, 80, 470);
   Line(560, 360, 560, 470);
   Line(80, 470, 560, 470, clGray);
   Text(245, 390, 'VENT --', clSilver, 16);
   Text(110, 495, 'PACK 1', clWhite, 13);
   Text(450, 495, 'PACK 2', clWhite, 13);
  End;

 Procedure TAirbusSD.ElecPage;
  Var
   e : Integer;
   x : Integer;
  Begin
   For e := 1 To 2 Do
    Begin
     x := 140 + (e - 1) * 360;
     Box(x - 75, 80, x + 75, 180);
     Text(x - 55, 90, 'BAT ' + IntToStr(e), clWhite, 14);
     Number(x - 40, 120, fData.FBW('A32NX_ELEC_BAT_' + IntToStr(e) + '_POTENTIAL'));
     Text(x + 25, 120, 'V', clAqua, 12);
     Number(x - 40, 150, fData.FBW('A32NX_ELEC_BAT_' + IntToStr(e) + '_CURRENT'));
     Text(x + 25, 150, 'A', clAqua, 12);
     Line(x, 180, x, 310, clGray);
     Box(x - 75, 325, x + 75, 470);
     Text(x - 55, 340, 'GEN ' + IntToStr(e), clWhite, 14);
     Number(x - 40, 375, fData.FBW('A32NX_ELEC_ENG_GEN_' + IntToStr(e) + '_POTENTIAL'));
     Text(x + 25, 375, 'V', clAqua, 12);
     Number(x - 40, 415, fData.FBW('A32NX_ELEC_ENG_GEN_' + IntToStr(e) + '_FREQUENCY'));
     Text(x + 20, 415, 'HZ', clAqua, 12);
    End;
   Line(140, 245, 500, 245, clGray);
   Text(255, 220, 'DC BAT', clWhite, 13);
   Text(245, 290, 'AC ESS --', clSilver, 13);
  End;

 Procedure TAirbusSD.HydPage;
  Const
   Names : Array [0..2] Of String = ('GREEN', 'BLUE', 'YELLOW');
  Var
   i : Integer;
   x : Integer;
   v : Double;
  Begin
   For i := 0 To 2 Do
    Begin
     x := 110 + i * 210;
     Text(x - 45, 90, Names[i], clWhite, 13);
     v := fData.FBW('A32NX_HYD_' + Names[i] + '_SYSTEM_1_SECTION_PRESSURE');
     Number(x - 35, 130, v);
     Text(x - 20, 165, 'PSI', clAqua, 12);
     Line(x, 205, x, 460, clGray);
     Box(x - 18, 275, x + 18, 315);
     Box(x - 22, 440, x + 22, 495);
     Number(x - 30, 465, fData.FBW('A32NX_HYD_' + Names[i] + '_RESERVOIR_LEVEL'), 1);
    End;
   Line(110, 230, 530, 230, clGray);
   Text(265, 205, 'PTU', clWhite, 12);
  End;

 Procedure TAirbusSD.FuelPage;
  Const
   Tank : Array [0..2] Of String = ('fuel_tank_left_main_quantity', 'fuel_tank_center_quantity', 'fuel_tank_right_main_quantity');
  Var
   i : Integer;
   x : Integer;
   v : Double;
   d : Double;
  Begin
   d     := fData.Value('fuel_weight_per_gallon');
   For i := 0 To 2 Do
    Begin
     x := 110 + i * 210;
     Box(x - 90, 270, x + 90, 390);
     Text(x - 45, 285, 'TANK ' + IntToStr(i + 1), clWhite, 12);
     v := fData.Value(Tank[i]);
     If Not InstrumentValid(d) Or (d <= 0) Then
      v := NaN
     Else
      v := v * d * 0.45359237;
     Number(x - 55, 335, v);
     Line(x, 270, x, 160, clGray);
     Box(x - 15, 215, x + 15, 245, clGray);
    End;
   Line(110, 160, 530, 160, clGray);
   Text(230, 110, 'X FEED --', clSilver, 14);
   Text(20, 460, 'FOB', clWhite, 14);
   Number(90, 460, fData.Value('fuel_total_quantity_weight') * 0.45359237);
   Text(235, 460, 'KG', clAqua, 13);
   Text(20, 500, 'F.USED 1+2', clWhite, 12);
   Number(200, 500, fData.FBW('A32NX_FUEL_USED:1') + fData.FBW('A32NX_FUEL_USED:2'));
  End;

 Procedure TAirbusSD.ApuPage;
  Begin
   Box(60, 85, 245, 220);
   Text(80, 100, 'APU GEN', clWhite, 14);
   Number(100, 145, fData.FBW('A32NX_ELEC_APU_GEN_1_POTENTIAL'));
   Text(175, 145, 'V', clAqua, 12);
   Number(100, 180, fData.FBW('A32NX_ELEC_APU_GEN_1_FREQUENCY'));
   Text(170, 180, 'HZ', clAqua, 12);
   Box(420, 110, 580, 220);
   Text(440, 125, 'BLEED', clWhite, 14);
   Number(460, 170, fData.FBW('APU_BLEED_PRESSURE'));
   Gauge(200, 350, 85, fData.ARINC('A32NX_APU_N'), 110, 'N %');
   Gauge(440, 350, 85, fData.ARINC('A32NX_APU_EGT'), 1000, 'EGT C');
   Text(235, 490, 'FLAP', clWhite, 13);
   Number(310, 490, fData.FBW('A32NX_APU_FLAP_OPEN_PERCENTAGE'));
  End;

 Procedure TAirbusSD.CondPage;
  Const
   Names : Array [0..2] Of String = ('CKPT', 'FWD', 'AFT');
  Var
   i : Integer;
   x : Integer;
  Begin
   Box(50, 130, 590, 280);
   For i := 0 To 2 Do
    Begin
     x := 140 + i * 180;
     Text(x - 35, 145, Names[i], clWhite, 13);
     Number(x - 20, 200, fData.FBW('A32NX_COND_' + Names[i] + '_TEMP'));
     Text(x + 30, 200, 'C', clAqua, 12);
     Line(x, 280, x, 425, clGray);
     Number(x - 20, 335, fData.FBW('A32NX_COND_' + Names[i] + '_DUCT_TEMP'));
    End;
   Line(140, 425, 580, 425, clGray);
   Text(440, 465, 'HOT AIR --', clSilver, 13);
  End;

 Procedure TAirbusSD.DoorPage;
  Var
   i : Integer;
   y : Integer;
  Begin
   Line(270, 80, 230, 170);
   Line(230, 170, 230, 470);
   Line(230, 470, 270, 510);
   Line(370, 80, 410, 170);
   Line(410, 170, 410, 470);
   Line(410, 470, 370, 510);
   Line(270, 80, 370, 80);
   Line(230, 300, 60, 360);
   Line(410, 300, 580, 360);
   For i := 0 To 3 Do
    Begin
     y := 165 + i * 85;
     Box(220, y, 240, y + 25, clGray);
     Box(400, y, 420, y + 25, clGray);
    End;
   Text(60, 90, 'CKPT OXY --', clSilver, 12);
   Text(470, 490, 'SLIDES --', clSilver, 12);
  End;

 Procedure TAirbusSD.WheelPage;
  Var
   i : Integer;
   x : Integer;
   y : Integer;
   v : Double;
  Begin
   For i := 0 To 2 Do
    Begin
     x := 130 + i * 190;
     y := 230;
     If i = 1 Then
      y := 100;
     v  := fData.Value('gear_position_' + IntToStr(i));
     Box(x - 40, y, x + 40, y + 30, clGray);
     Line(x, y + 30, x, y + 85, clGray);
     Box(x - 25, y + 85, x + 25, y + 125, clGray);
     Number(x - 20, y + 43, v, 1);
    End;
   For i := 1 To 4 Do
    Begin
     x := 65 + (i - 1) * 155;
     Number(x, 430, fData.ARINC('A32NX_REPORTED_BRAKE_TEMPERATURE_' + IntToStr(i)));
     Text(x, 465, IntToStr(i) + ' C', clAqua, 12);
    End;
   Text(200, 510, 'ANTI SKID --', clSilver, 12);
  End;

 Procedure TAirbusSD.FlightControlPage;
  Var
   i : Integer;
   x : Integer;
   y : Integer;
   v : Double;
  Begin
   Text(245, 65, 'G  B  Y', clSilver, 16);
   Text(240, 125, 'SPD BRK', clWhite, 13);
   For i := 0 To 1 Do
    Begin
     x := 95 + i * 450;
     Line(x, 200, x, 380);
     Text(x - 30, 175, 'AIL', clWhite, 12);
     If i = 0 Then
      v := fData.Value('aileron_left_deflection_pct')
     Else
      v := fData.Value('aileron_right_deflection_pct');
     If InstrumentValid(v) Then
      Begin
       y := 290 - Round(EnsureRange(v, -1.0, 1.0) * 80);
       Line(x - 15, y, x + 15, y, clLime, 3);
      End;
    End;
   Text(240, 240, 'PITCH TRIM', clWhite, 14);
   Number(275, 285, fData.Value('elevator_trim_position'), 1);
   Text(270, 365, 'RUD', clWhite, 14);
   v := fData.Value('rudder_deflection_pct');
   Box(245, 410, 395, 490, clGray);
   If InstrumentValid(v) Then
    Begin
     x := 320 + Round(EnsureRange(v, -1.0, 1.0) * 70);
     Line(320, 490, x, 415, clLime, 3);
    End;
  End;

 Procedure TAirbusSD.StatusPage;
  Begin
   Line(350, 70, 350, 525);
   Text(390, 75, 'INOP SYS', clWhite, 15);
   Text(50, 130, 'STATUS TEXT --', clSilver, 16);
   Text(390, 130, '--', clSilver, 16);
   Text(50, 470, 'NO RECORDED ECAM TEXT', clSilver, 12);
  End;

 Procedure TAirbusSD.Render;
  Var
   p : Integer;
  Begin
   p := DisplayedPage;
   Text(20, 12, AirbusPageName(p), clWhite, 20);
   Line(20, 44, 180, 44);
   Case p Of
    0 :
     EnginePage(False);
    1 :
     BleedPage;
    2 :
     PressPage;
    3 :
     ElecPage;
    4 :
     HydPage;
    5 :
     FuelPage;
    6 :
     ApuPage;
    7 :
     CondPage;
    8 :
     DoorPage;
    9 :
     WheelPage;
    10 :
     FlightControlPage;
    11 :
     StatusPage;
    12 :
     EnginePage(True);
   Else
     Begin
      Text(160, 230, 'RECORDED PAGE --', clSilver, 18);
      Text(100, 280, 'SELECT A SYSTEM PAGE BELOW', clSilver, 12);
     End;
   End;
   Footer;
  End;

End.
