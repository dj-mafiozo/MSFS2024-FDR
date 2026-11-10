Program VerifyAirbusDisplays;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU, System.SysUtils, System.Classes, System.Math, System.Types, System.JSON,
 Vcl.Forms, Vcl.Controls, Vcl.Graphics, Vcl.Imaging.pngimage,
 FlightDatabaseU, FlightTelemetryU, TelemetryCatalogU, InstrumentDataU, AirbusDataU,
 AirbusFMAU, AirbusMessagesU, AirbusPFDU, AirbusECAMU, fraA320PFDU, fraA320ECAMU, frmViewWindowU, LocalizationU;

Procedure Check(b : Boolean; Const m : String);
 Begin
  If Not b Then
   Raise Exception.Create(m);
 End;

Type
 TSDProbe = Class(TAirbusSD)
  Procedure Save(Const Name : String);
 End;

 TPFDProbe = Class(TAirbusPFD)
  Procedure Save(Const Name : String);
 End;

 TEWDProbe = Class(TAirbusEWD)
  Procedure Save(Const Name : String);
 End;

Procedure TSDProbe.Save(Const Name : String);
 Var
  p : TPngImage;
 Begin
  fBuffer.Canvas.Brush.Style := bsSolid;
  fBuffer.Canvas.Brush.Color := clBlack;
  fBuffer.Canvas.FillRect(Rect(0, 0, 640, 640));
  Render;
  p := TPngImage.Create;
  Try
   p.Assign(fBuffer);
   p.SaveToFile(TestRepositoryPath(Name));
  Finally
   p.Free;
  End;
 End;

Procedure TPFDProbe.Save(Const Name : String);
 Var
  p : TPngImage;
 Begin
  fBuffer.Canvas.Brush.Style := bsSolid;
  fBuffer.Canvas.Brush.Color := clBlack;
  fBuffer.Canvas.FillRect(Rect(0, 0, 640, 640));
  Render;
  p := TPngImage.Create;
  Try
   p.Assign(fBuffer);
   p.SaveToFile(TestRepositoryPath(Name));
  Finally
   p.Free;
  End;
 End;

Procedure TEWDProbe.Save(Const Name : String);
 Var
  p : TPngImage;
 Begin
  fBuffer.Canvas.Brush.Style := bsSolid;
  fBuffer.Canvas.Brush.Color := clBlack;
  fBuffer.Canvas.FillRect(Rect(0, 0, 640, 640));
  Render;
  p := TPngImage.Create;
  Try
   p.Assign(fBuffer);
   p.SaveToFile(TestRepositoryPath(Name));
  Finally
   p.Free;
  End;
 End;

Function ARINC(V : Single; SSM : Cardinal = 3) : Double;
 Var
  Bits : Cardinal;
 Begin
  Move(V, Bits, 4);
  Result := UInt64(Bits) + (UInt64(SSM) Shl 32);
 End;

Procedure Visual;
 Var
  Plot  : TTripPlot;
  p     : TPlotPoint;
  Host  : TForm;
  Frame : TfraA320ECAM;
  PFD   : TfraA320PFD;
  FMA   : TAirbusFMA;
  Group : String;
  Msg   : String;
  View  : TfrmViewWindow;
  SD    : TSDProbe;
  EW    : TEWDProbe;
  PD    : TPFDProbe;
  i     : Integer;
  j     : Integer;
  b     : TBitmap;

  Procedure V(Const Name : String; N : Double);
   Var
    k : Integer;
   Begin
    k := Plot.Labels.IndexOf(Name);
    If k < 0 Then
     Begin
      k := Plot.Labels.Add(Name);
      SetLength(p.Values, k + 1);
     End;
    p.Values[k] := N;
   End;

 Begin
  Plot := TTripPlot.Create;
  Host := TForm.Create(Nil);
  SD   := TSDProbe.Create(Nil);
  EW   := TEWDProbe.Create(Nil);
  PD   := TPFDProbe.Create(Nil);
  b    := TBitmap.Create;
  Try
   Plot.AircraftTitle    := 'FlyByWire A32NX';
   Plot.AircraftTypeICAO := 'A20N';
   p.Time                := '2026-10-24T12:00:00.000Z';
   V('airspeed_indicated', 145);
   V('indicated_altitude', 3720);
   V('plane_pitch_degrees', -3);
   V('plane_bank_degrees', 0);
   V('heading_indicator', 261);
   V('vertical_speed', 800);
   V('kohlsman_setting_mb', 1013);
   V('autopilot_master', 1);
   V('autopilot_flight_director_active', 1);
   V('autothrottle_active', 1);
   V('autopilot_altitude_lock_var', 5000);
   V('autopilot_airspeed_hold_var', 145);
   V('radio_height', 2310);
   V('hsi_cdi_needle', 63.5);
   V('hsi_cdi_valid', 1);
   V('hsi_has_localizer', 1);
   V('hsi_gsi_needle', -59.5);
   V('hsi_gsi_valid', 1);
   V('gps_drives_nav1', 0);
   V('FBWLVar.A32NX_ECAM_SD_PAGE_TO_DISPLAY', 0);
   V('FBWLVar.A32NX_ECAM_SD_CURRENT_PAGE_INDEX', 5);
   V('FBWLVar.A32NX_ENGINE_N1:1', 19.7);
   V('turb_eng_n1 #1', 90);
   V('FBWLVar.A32NX_ENGINE_N1:2', 19.8);
   V('FBWLVar.A32NX_ENGINE_N2:1', 68.2);
   V('FBWLVar.A32NX_ENGINE_N2:2', 68.1);
   V('FBWLVar.A32NX_ENGINE_EGT:1', 518);
   V('FBWLVar.A32NX_ENGINE_EGT:2', 507);
   V('FBWLVar.A32NX_ENGINE_FF:1', 320);
   V('FBWLVar.A32NX_ENGINE_FF:2', 300);
   V('fuel_total_quantity_weight', 9520 / 0.45359237);
   V('total_weight', 59700 / 0.45359237);
   V('ambient_temperature', 12);
   V('total_air_temperature', 14);
   V('eng_oil_quantity #1', 0.8);
   V('eng_oil_quantity #2', 0.79);
   V('eng_oil_pressure #1', 53 * 144);
   V('eng_oil_pressure #2', 52 * 144);
   V('eng_oil_temperature #1', 91);
   V('eng_oil_temperature #2', 107);
   V('FBWLVar.A32NX_FUEL_USED:1', 4);
   V('FBWLVar.A32NX_FUEL_USED:2', 9);
   V('FBWLVar.A32NX_HYD_GREEN_SYSTEM_1_SECTION_PRESSURE', 3000);
   V('FBWLVar.A32NX_HYD_BLUE_SYSTEM_1_SECTION_PRESSURE', 3000);
   V('FBWLVar.A32NX_HYD_YELLOW_SYSTEM_1_SECTION_PRESSURE', 3000);
   V('FBWLVar.A32NX_APU_N', ARINC(100));
   V('FBWLVar.A32NX_APU_EGT', ARINC(415));
   V('FBWLVar.A32NX_PRESS_CPC_1_DISCRETE_WORD', ARINC(1024));
   V('FBWLVar.A32NX_PRESS_CPC_1_CABIN_ALTITUDE', ARINC(1285));
   V('FBWLVar.A32NX_PRESS_CPC_1_CABIN_DELTA_PRESSURE', ARINC(0.5));
   V('FBWLVar.A32NX_PRESS_CPC_1_CABIN_VS', ARINC(100));
   V('FBWLVar.A32NX_FMGC_1_DISCRETE_WORD_1', ARINC((1 Shl 21) Or (1 Shl 19)));
   V('FBWLVar.A32NX_FMGC_1_DISCRETE_WORD_2', ARINC(1 Shl 13));
   V('FBWLVar.A32NX_FMGC_1_DISCRETE_WORD_3', ARINC(1 Shl 19));
   V('FBWLVar.A32NX_FM1_MINIMUM_DESCENT_ALTITUDE', ARINC(3500));
   V('FBWLVar.A32NX_FCU_LEFT_EIS_DISCRETE_WORD_2', ARINC(1 Shl 27));
   V('FBWLVar.A32NX_FCU_AFS_DISPLAY_MACH_MODE', 1);
   V('FBWLVar.A32NX_FCU_AFS_DISPLAY_SPD_MACH_VALUE', 0.78);
   V('FBWLVar.A32NX_FMGC_1_PITCH_FD_COMMAND', ARINC( -4));
   V('FBWLVar.A32NX_FMGC_1_ROLL_FD_COMMAND', ARINC(10));
   V('FBWLVar.A32NX_FMGC_1_DISCRETE_WORD_4', ARINC((1 Shl 11) Or (1 Shl 12) Or (1 Shl 24)));
   V('FBWLVar.A32NX_FMGC_1_ATS_DISCRETE_WORD', ARINC(0));
   V('FBWLVar.A32NX_FMGC_2_DISCRETE_WORD_4', ARINC((1 Shl 11) Or (1 Shl 12)));
   V('FBWLVar.A32NX_FMGC_2_ATS_DISCRETE_WORD', ARINC(0));
   V('FBWLVar.A32NX_FCU_ATS_DISCRETE_WORD', ARINC((1 Shl 12) Or (1 Shl 13)));
   V('FBWLVar.A32NX_FCU_ATS_FMA_DISCRETE_WORD', ARINC(1 Shl 18));
   V('FBWLVar.A32NX_FCU_DISCRETE_WORD_2', ARINC(0));
   V('FBWLVar.A32NX_Ewd_LOWER_LEFT_LINE_1', 260001001);
   V('FBWLVar.A32NX_Ewd_LOWER_LEFT_LINE_2', 260001002);
   V('FBWLVar.A32NX_Ewd_LOWER_RIGHT_LINE_1', 20001);
   V('brake_parking_indicator', 1);
   V('spoilers_armed', 1);
   Plot.Points.Add(p);
   p.Values                                                               := Copy(p.Values);
   p.Time                                                                 := '2026-10-24T12:00:01.000Z';
   p.Values[Plot.Labels.IndexOf('FBWLVar.A32NX_ECAM_SD_PAGE_TO_DISPLAY')] := 11;
   Plot.Points.Add(p);
   Check(InstrumentProfile(Plot, 0).Kind = ikA320PFD, 'FBW A20N selects A320 PFD');
   Check((DecodeAirbusARINC(ARINC(100)) = 100) And (DecodeAirbusARINC(ARINC(0)) = 0), 'Float32 ARINC payload, including genuine zero');
   For i := 0 To 2 Do
    Check(IsNan(DecodeAirbusARINC(ARINC(100, i))), 'Invalid ARINC SSM suppressed');
   Check(IsNan(DecodeAirbusARINC(NaN)) And IsNan(DecodeAirbusARINC( -1)), 'Malformed ARINC suppressed');
   SD.SetPoint(Plot, 0);
   Check(SD.DisplayedPage = 0, 'Recorded uses displayed page, not selected button');
   FMA := ReadAirbusFMA(SD.Data);
   Check(FMA.Available And (FMA.Cells[0, 0].Text = 'SPEED') And (FMA.Cells[1, 0].Text = 'G/S') And (FMA.Cells[2, 0].Text = 'LOC'), 'Recorded active FMA modes');
   Check((FMA.Cells[3, 0].Text = 'CAT3') And (FMA.Cells[3, 1].Text = 'DUAL') And (FMA.Cells[4, 0].Text = 'AP1+2') And (FMA.Cells[4, 1].Text = '1 FD 2'), 'Approach and engagement FMA');
   Check(FMA.Cells[4, 2].Text = 'A/THR', 'A/THR engagement');
   Check(Not AirbusBit(NaN, 12) And Not AirbusBit( -1, 12), 'Invalid discrete words never activate modes');
   Group := '';
   Msg   := AirbusMessage(260001001, Group);
   Check(Pos('ENG 1 FIRE', Msg) > 0, 'Full warning catalog heading');
   Msg := AirbusMessage(260001001, Group);
   Check(Pos('ENG 1 FIRE', Msg) = 0, 'Repeated group heading suppressed');
   Check(Pos(#27 + ' ', Msg) = 0, 'No dangling escape in repeated heading');
   Msg := AirbusMessage(20001, Group);
   Check(Pos('PARK BRK', Msg) > 0, 'Numeric code padded by catalog identity');
   Msg := AirbusMessage(999999999, Group);
   Check(Pos('999999999', Msg) > 0, 'Unknown IDs remain visible instead of fabricated text');
   Msg := AirbusMessage(NaN, Group);
   Check(Msg = '', 'Missing text is not NORMAL');
   InstrumentKindOverride := Ord(ikB38MPFD);
   Check(InstrumentProfile(Plot, 0).Kind = ikB38MPFD, 'Debug override independent of aircraft');
   InstrumentKindOverride := -1;
   Check(SD.Data.Engine('turb_eng_n1', 1) = 19.7, 'Native FBW engine value precedes SimConnect fallback');
   Check(SD.Data.Cabin('CABIN_ALTITUDE') = 1285, 'Active CPC and ARINC decoded');
   Check(AirbusPageFromFBWDisplay(11) = Ord(aspCRUISE), 'Display index 11 is CRUISE');
   Check(AirbusPageFromFBWDisplay(12) = Ord(aspSTS), 'Display index 12 is STATUS');
   Check(AirbusPageFromFBWDisplay( -1) = -1, 'Unknown recorded page remains unknown');
   For i := 0 To 12 Do
    Begin
     SD.Page := i;
     SD.Save('tests\airbus-sd-' + IntToStr(i) + '.png');
    End;
   SD.Page := -1;
   SD.SetPoint(Plot, 1);
   Check(SD.DisplayedPage = 12, 'Recorded follows forward timeline');
   SD.SetPoint(Plot, 0);
   Check(SD.DisplayedPage = 0, 'Recorded follows backward timeline');
   EW.SetPoint(Plot, 0);
   EW.Save('tests\airbus-ewd-preview.png');
   PD.SetPoint(Plot, 0);
   PD.Save('tests\airbus-pfd-preview.png');
   Check((PD.Sampler.State.Pitch = 3) And PD.Sampler.State.LocalizerValid And PD.Sampler.State.GlideslopeValid, 'PFD retains pitch sign and independent ILS validity');
   Host.ClientWidth  := 640;
   Host.ClientHeight := 900;
   Frame             := TfraA320ECAM.Create(Host);
   Frame.Parent      := Host;
   Frame.Align       := alClient;
   Host.Show;
   Application.ProcessMessages;
   Check(Frame.btnRecorded.Caption = 'Z nagrania', 'Recorded caption is localized in Polish');
   Frame.SetPoint(Plot, 0);
   Check(Frame.LowerDisplay.Page = -1, 'DFM defaults to Recorded');
   Frame.btnFUEL.Click;
   Check((Frame.LowerDisplay.Page = 5) And Frame.btnFUEL.Down, 'Manual system page and button state');
   Frame.SetPoint(Plot, 1);
   Check(Frame.LowerDisplay.DisplayedPage = 5, 'Manual page survives timeline movement');
   Frame.btnRecorded.Click;
   Check(Frame.LowerDisplay.DisplayedPage = 12, 'Recorded returns to current display page');
   View := TfrmViewWindow.Create(Host);
   View.Attach(Frame, Host, 'A320 ECAM', Nil);
   Frame.SetPoint(Plot, 0);
   Check((Frame.Parent = View) And (Frame.aWindow.ImageIndex = 1) And (Frame.LowerDisplay.DisplayedPage = 0), 'Detached ECAM preserves replay');
   View.Close;
   Application.ProcessMessages;
   Check((Frame.Parent = Host) And (Frame.aWindow.ImageIndex = 0), 'ECAM returns same frame');
   For i := 0 To 2 Do
    Begin
     Host.ClientWidth  := 320 + i * 300;
     Host.ClientHeight := 400 + i * 200;
     Application.ProcessMessages;
     Frame.FrameResize(Nil);
     Check(Frame.PagePanel.Height < Frame.ClientHeight, 'All page buttons fit without covering entire display');
     For j := 0 To Frame.PagePanel.ControlCount - 1 Do
      Check(Frame.PagePanel.Controls[j].Top + Frame.PagePanel.Controls[j].Height <= Frame.PagePanel.ClientHeight, 'Every page button remains inside footer');
     b.SetSize(Frame.UpperDisplay.Width, Frame.UpperDisplay.Height);
     Frame.UpperDisplay.PaintTo(b.Canvas, 0, 0);
    End;
   Frame.Free;
   PFD        := TfraA320PFD.Create(Host);
   PFD.Parent := Host;
   PFD.Align  := alClient;
   PFD.SetPoint(Plot, 0);
   View := TfrmViewWindow.Create(Host);
   View.Attach(PFD, Host, 'A320 PFD', Nil);
   PFD.SetPoint(Plot, 1);
   Check(PFD.Display.Data.Time = p.Time, 'Detached A320 PFD follows cursor');
   View.Close;
   Application.ProcessMessages;
   SetLanguage('he-IL');
   Check(PFD.Display.BiDiMode = bdLeftToRight, 'Physical PFD stays LTR');
   SetLanguage('pl-PL');
   Plot.AircraftTitle                                                     := 'Fenix A320';
   Plot.AircraftTypeICAO                                                  := 'A320';
   p                                                                      := Plot.Points[0];
   p.Values                                                               := Copy(p.Values);
   p.Values[Plot.Labels.IndexOf('FBWLVar.A32NX_ECAM_SD_PAGE_TO_DISPLAY')] := NaN;
   Plot.Points[0]                                                         := p;
   SD.Page                                                                := -1;
   SD.SetPoint(Plot, 0);
   Check(SD.DisplayedPage = -1, 'Fenix auto page is not guessed from control lamps');
   SD.Page := 3;
   SD.Save('tests\airbus-fenix-missing-preview.png');
   Check(SD.DisplayedPage = 3, 'Fenix manual pages remain available');
   Plot.Labels.Clear;
   SD.SetPoint(Plot, 0);
   Check(IsNan(SD.Data.Engine('turb_eng_n1', 1)), 'Missing labels never retain old SDK data');
   SD.Save('tests\airbus-missing-preview.png');
   SD.Clear;
   EW.Clear;
   PD.Clear;
   PFD.Clear;
  Finally
   b.Free;
   PD.Free;
   EW.Free;
   SD.Free;
   Host.Free;
   Plot.Free;
  End;
 End;

Procedure Storage;
 Var
  DB     : TFlightDatabase;
  s      : TFlightSample;
  Plot   : TTripPlot;
  d      : TAirbusData;
  Fields : TJSONObject;
  i      : Integer;
  Trip   : Integer;

  Procedure N(Const Name : String; V : Double);
   Var
    k : Integer;
   Begin
    For k := 0 To FieldCount - 1 Do
     If SimFields[k].Name = Name Then
      Begin
       s.Numbers[k] := V;
       Exit;
      End;
    Raise Exception.Create(Name);
   End;

 Begin
  DB := TFlightDatabase.Create(TestDatabasePath('airbus.mfzr'), TestRuntimeFile('sqlite3.dll'));
  s  := TFlightSample.Create;
  d  := TAirbusData.Create;
  Try
   For i := 0 To FieldCount - 1 Do
    Begin
     If SimFields[i].Name = 'title' Then
      s.Texts[i] := 'FBW A32NX';
     If SimFields[i].Name = 'atc_model' Then
      s.Texts[i] := 'A20N';
    End;
   N('time_zulu.year', 2026);
   N('time_zulu.month', 10);
   N('time_zulu.day', 24);
   N('number_of_engines', 2);
   N('engine_type', 1);
   Trip  := DB.StartTrip(s);
   For i := 0 To 1 Do
    Begin
     s.AircraftData.Free;
     s.AircraftData := TJSONObject.Create;
     s.AircraftData.AddPair('provider', 'FBWA32NX');
     Fields := TJSONObject.Create;
     Fields.AddPair('A32NX_ECAM_SD_PAGE_TO_DISPLAY', TJSONNumber.Create(i * 11));
     Fields.AddPair('A32NX_ENGINE_N1:1', TJSONNumber.Create(19.7 + i));
     s.AircraftData.AddPair('fields', Fields);
     N('time_zulu.seconds', 43200 + i);
     DB.RecordSample(Trip, s);
    End;
   Plot := DB.LoadTrip(Trip);
   Try
    d.SetPoint(Plot, 0);
    Check((d.RecordedPage = 0) And (d.Engine('turb_eng_n1', 1) = 19.7), 'SQLite SDK fields reach ECAM sampler');
    d.SetPoint(Plot, 1);
    Check(d.RecordedPage = Ord(aspCRUISE), 'Recorded SD page delta restored');
    d.SetPoint(Plot, 0);
    Check(d.RecordedPage = 0, 'Reverse seek restores historical page');
   Finally
    d.Clear;
    Plot.Free;
   End;
  Finally
   d.Free;
   s.Free;
   DB.Free;
  End;
 End;

Type

 [TestFixture]
 TVerifyAirbusDisplaysTests = Class
  Public
   [Test]
   Procedure Regression;
 End;

Procedure TVerifyAirbusDisplaysTests.Regression;
 Begin
  Try
   Application.Initialize;
   Visual;
   Storage;
   System.Writeln('PASS: native A320 PFD/EWD/all SD pages, actual vs selector mapping, manual/Recorded behavior, valid ARINC/CPC, missing data, SQLite SDK deltas, reverse seek, frames/detach/icons/RTL/resize. Synthetic only.');
  Except
   On E : Exception Do
    Begin
     System.Writeln(E.ClassName + ': ' + E.Message);
     Raise Exception.Create('Regression failed; see diagnostic above');
    End;
  End;

 End;

Begin
 RunNativeTests(TVerifyAirbusDisplaysTests);

End.
