Program VerifyPFD737;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU In 'TestPathsU.pas', DUnitX.TestFramework, NativeTestRunnerU In 'NativeTestRunnerU.pas', System.SysUtils, System.Classes, System.Math, System.Types, Vcl.Forms, Vcl.Controls, Vcl.Graphics,
 Vcl.Imaging.pngimage, FlightDatabaseU In '..\src\Data\FlightDatabaseU.pas', Boeing737PFDU In '..\src\Visualization\Boeing737PFDU.pas', fraPFD737U In '..\src\Frames\fraPFD737U.pas', fraA320PFDU In '..\src\Frames\fraA320PFDU.pas', fraSixPackU In '..\src\Frames\fraSixPackU.pas', frmViewWindowU In '..\src\Forms\frmViewWindowU.pas', LocalizationU In '..\src\i18n\LocalizationU.pas';

Procedure Check(b : Boolean; Const m : String);
 Begin
  If Not b Then
   Raise Exception.Create(m);
 End;

Var
 Plot  : TTripPlot;
 p     : TPlotPoint;
 Host  : TForm;
 Frame : TfraPFD737;
 View  : TfrmViewWindow;
 b     : TBitmap;
 PNG   : TPngImage;
 i     : Integer;

Procedure Value(Const Name : String; v : Double);
 Var
  k : Integer;
 Begin
  k := Plot.Labels.IndexOf(Name);
  If k < 0 Then
   Begin
    k := Plot.Labels.Add(Name);
    SetLength(p.Values, k + 1);
   End;
  p.Values[k] := v;
 End;

Procedure Render;
 Begin
  Frame.SetPoint(Plot, 0);
  b.SetSize(Frame.Display.Width, Frame.Display.Height);
  Frame.Display.PaintTo(b.Canvas, 0, 0);
 End;

Type

 [TestFixture]
 TVerifyPFD737Tests = Class
  Public
   [Test] Procedure Regression;
   [Test] Procedure LocalizedConstruction;
 End;

Procedure TVerifyPFD737Tests.Regression;
 Begin
  Try
   Application.Initialize;
   Plot := TTripPlot.Create;
   Host := TForm.Create(Nil);
   b    := TBitmap.Create;
   PNG  := TPngImage.Create;
   Try
    Check(Abs(PFD737AoADegrees(DegToRad(2.4), 0, 150) - 2.4) < 1E-9, 'AoA radians to physical degrees');
    Check(PFD737AoADegrees(DegToRad(2.4), 1, 79) = 0, 'AoA ground inhibit');
    Check(Abs(PFD737AoADegrees(DegToRad(2.4), 1, 80) - 2.4) < 1E-9, 'AoA ground threshold');
    Check(IsNan(PFD737AoADegrees(NaN, 1, 0)), 'Missing AoA does not become zero on ground');
    Check(PFD737AoADegrees(0, 0, 150) = 0, 'Real zero AoA');
    Check(Abs(PFD737VSIDeflection(1000) - 0.5) < 1E-9, 'VSI first nonlinear scale segment');
    Check((PFD737VSIDeflection( -2000) = -0.75) And (PFD737VSIDeflection(9000) = 1), 'VSI negative and clamped deflections');
    Check(IsNan(PFD737VSIDeflection(NaN)), 'VSI missing data remains unavailable');
    B38MInfoOnLeft         := False;
    B38MInfoEnabled        := False;
    Plot.FlightNumber      := 'IBK1762';
    Plot.Registration      := 'EI-FYB';
    Plot.RecordedStartTime := '2026-10-24T23:59:00Z';
    Plot.AircraftTitle     := 'iFly 737 MAX 8';
    p.Time                 := '2026-10-24T23:59:30+00:00_4';
    Value('airspeed_indicated', 285);
    Value('plane_pitch_degrees', -3);
    Value('plane_bank_degrees', 0);
    Value('indicated_altitude', 8020);
    Value('heading_indicator', 351);
    Value('vertical_speed', -677);
    Value('kohlsman_setting_mb', 1013);
    Value('autopilot_master', 1);
    Value('autopilot_flight_director_active', 1);
    Value('autothrottle_active', 1);
    Value('autopilot_airspeed_hold_var', 290);
    Value('autopilot_altitude_lock_var', 18000);
    Value('autopilot_heading_lock_dir', 290);
    Value('hsi_cdi_needle', 63.5);
    Value('hsi_cdi_valid', 1);
    Value('hsi_has_localizer', 1);
    Value('hsi_gsi_needle', -59.5);
    Value('hsi_gsi_valid', 1);
    Value('gps_drives_nav1', 0);
    Value('iFlySDK.FD_1_Switch_Status', 1);
    Value('iFlySDK.CMD_A_Switch_Status', 2);
    Value('iFlySDK.LNAV_Switch_Status', 2);
    Value('iFlySDK.VNAV_Switch_Status', 2);
    Value('iFlySDK.AT_Switch_Status', 1);
    Value('iFlySDK.N1_Switch_Status', 2);
    Value('autopilot_flight_director_pitch', DegToRad( -8));
    Value('autopilot_flight_director_bank', DegToRad( -10));
    B38MAoAEnabled := True;
    Value('incidence_alpha', DegToRad(2.4));
    Value('sim_on_ground', 0);
    Value('ground_velocity', 280);
    Value('airspeed_true', 310);
    Value('plane_heading_degrees_true', 351);
    Value('iFlySDK.VORADF_L_Status[0]', 0);
    Value('iFlySDK.VORADF_R_Status[0]', 2);
    Value('nav_active_frequency_1', 117.6);
    Value('nav_has_dme_1', 1);
    Value('nav_dme_1', 56.2);
    Value('adf_active_frequency_2', 350.5);
    Value('ambient_wind_direction', 276);
    Value('ambient_wind_velocity', 57);
    Value('iFlySDK.Transponder_Windows_Digital_1000_Status', 0);
    Value('iFlySDK.Transponder_Windows_Digital_100_Status', 4);
    Value('iFlySDK.Transponder_Windows_Digital_10_Status', 2);
    Value('iFlySDK.Transponder_Windows_Digital_1_Status', 1);
    Value('radio_height', 1200);
    Value('airspeed_mach', 0.498);
    Plot.Points.Add(p);
    Check(TfraPFD737.ClassParent = TFrame, 'Source-only IDE recognizes direct TFrame');
    Host.ClientWidth  := 600;
    Host.ClientHeight := 669;
    Frame             := TfraPFD737.Create(Host);
    Frame.Parent      := Host;
    Frame.Align       := alClient;
    Host.Show;
    Application.ProcessMessages;
    Render;
    Check((Frame.Display.State.IAS = 285) And (Frame.Display.State.Pitch = 3) And (Frame.Display.State.Altitude = 8020), 'Timeline raw state and pitch convention');
    Check((Frame.Display.Width = 600) And (Frame.Display.Height = 640), 'DFM toolbar reserves space');
    Check(ColorToRGB(b.Canvas.Pixels[335, 430]) = ColorToRGB(clFuchsia), 'LOC diamond rendered');
    Check(ColorToRGB(b.Canvas.Pixels[440, 217]) = ColorToRGB(clFuchsia), 'GS diamond rendered');
    Check(ColorToRGB(b.Canvas.Pixels[315, 230]) = ColorToRGB(clFuchsia), 'Crossbar FD bank command');
    Check(ColorToRGB(b.Canvas.Pixels[200, 260]) = ColorToRGB(clFuchsia), 'Crossbar FD pitch command');
    PNG.Assign(b);
    PNG.SaveToFile(TestRepositoryPath('tests\pfd737-preview.png'));
    B38MAoAEnabled := False;
    Render;
    Check(ColorToRGB(b.Canvas.Pixels[390, 100]) <> ColorToRGB(clWhite), 'Optional AoA hidden');
    B38MAoAEnabled := True;
    Check((Frame.Display.FlightInfo.Transponder = '0421') And (Frame.Display.FlightInfo.UTC = '23:59:30 Z') And (Frame.Display.FlightInfo.Elapsed = '00:00:30'), 'Recorded UTC, elapsed and leading squawk zero');
    Check((Frame.Display.FlightInfo.FlightNumber = 'IBK1762') And (Frame.Display.FlightInfo.Registration = 'EI-FYB') And (Frame.Display.FlightInfo.Selcal = '--'), 'Recorded metadata and absent SELCAL');
    B38MInfoEnabled  := True;
    Host.ClientWidth := 860;
    Application.ProcessMessages;
    Render;
    Check(ColorToRGB(b.Canvas.Pixels[615, 75]) = ColorToRGB($00533C36), 'MAX information panel rendered');
    PNG.Assign(b);
    PNG.SaveToFile(TestRepositoryPath('tests\pfd737-info-preview.png'));
    B38MInfoOnLeft := True;
    Render;
    Check(ColorToRGB(b.Canvas.Pixels[15, 75]) = ColorToRGB($00533C36), 'CPT: information panel on left');
    Check(ColorToRGB(b.Canvas.Pixels[270, 100]) <> ColorToRGB(clBlack), 'CPT: PFD moves intact to the right');
    PNG.Assign(b);
    PNG.SaveToFile(TestRepositoryPath('tests\pfd737-info-fo-preview.png'));
    B38MInfoOnLeft := False;
    Render;
    Check(ColorToRGB(b.Canvas.Pixels[615, 75]) = ColorToRGB($00533C36), 'FO: return panel to right');
    B38MInfoEnabled  := False;
    Host.ClientWidth := 600;
    Application.ProcessMessages;
    Render;
    Check(ColorToRGB(b.Canvas.Pixels[10, 100]) <> ColorToRGB(clBlack), 'Hiding panel restores full-width PFD scale');
    View              := TfrmViewWindow.Create(Host);
    View.ClientWidth  := 600;
    View.ClientHeight := 669;
    View.Attach(Frame, Host, 'PFD 737', Nil);
    Check((Frame.Parent = View) And (Frame.aWindow.ImageIndex = 1), 'Separate synchronized window and detach glyph');
    p.Values    := Copy(p.Values);
    p.Values[0] := 286;
    p.Time      := '2026-10-25T00:00:45Z';
    Plot.Points.Add(p);
    Frame.SetPoint(Plot, 1);
    Check((Frame.Display.State.IAS = 286) And (Frame.lTime.Caption = p.Time), 'Detached timeline advances');
    Check((Frame.Display.FlightInfo.UTC = '00:00:45 Z') And (Frame.Display.FlightInfo.Date = '2026-10-25') And (Frame.Display.FlightInfo.Elapsed = '00:01:45'), 'Timeline crosses midnight with recording-derived elapsed');
    Frame.SetPoint(Plot, 0);
    Check(Frame.Display.FlightInfo.Elapsed = '00:00:30', 'Reverse seek restores elapsed');
    Check(Frame.Display.State.IAS = 285, 'Backward seek restores earlier state');
    View.Close;
    Application.ProcessMessages;
    Host.Show;
    Check((Frame.Parent = Host) And (Frame.aWindow.ImageIndex = 0), 'Window close returns same frame and icon');
    For i := 0 To 2 Do
     Begin
      Case i Of
       0 :
        Begin
         Host.ClientWidth  := 1200;
         Host.ClientHeight := 349;
        End;
       1 :
        Begin
         Host.ClientWidth  := 320;
         Host.ClientHeight := 669;
        End;
       2 :
        Begin
         Host.ClientWidth  := 64;
         Host.ClientHeight := 93;
        End;
      End;
      Application.ProcessMessages;
      Render;
     End;
    SetLanguage('he-IL');
    Check(Frame.Display.BiDiMode = bdLeftToRight, 'Physical PFD remains LTR');
    SetLanguage('pl-PL');
    Plot.Labels.Clear;
    Frame.SetPoint(Plot, 0);
    Check(IsNan(Frame.Display.State.IAS), 'Missing historical labels are unavailable');
    p.Time         := 'invalid';
    Plot.Points[1] := p;
    Frame.SetPoint(Plot, 1);
    Check((Frame.Display.FlightInfo.UTC = '--') And (Frame.Display.FlightInfo.Elapsed = '--'), 'Invalid recorded time never uses wall clock');
    Frame.Clear;
    Check(Frame.Display.FlightInfo.FlightNumber = '--', 'Clear removes previous flight metadata');
    Check(IsNan(Frame.Display.State.Altitude), 'Clear before plot release');
   Finally
    PNG.Free;
    b.Free;
    Host.Free;
    Plot.Free;
   End;
   System.Writeln('PASS: native PFD737 rendering/ILS, raw telemetry, nonlinear VSI, fixed aspect ratios, NaN, timeline reverse, detach/dock icons and RTL. Synthetic only.');
  Except
   On E : Exception Do
    Begin
     System.Writeln(E.ClassName + ': ' + E.Message);
     Raise Exception.Create('Regression failed; see diagnostic above');
    End;
  End;

 End;

Procedure TVerifyPFD737Tests.LocalizedConstruction;
 Var
  Locale  : String;
  Parent  : TForm;
  Boeing  : TfraPFD737;
  Airbus  : TfraA320PFD;
  Generic : TfraSixPack;
 Begin
  For Locale In UILanguageLocales Do
   Begin
    SetLanguage(Locale);
    Parent := TForm.Create(Nil);
    Try
     Boeing         := TfraPFD737.Create(Parent);
     Boeing.Parent  := Parent;
     Airbus         := TfraA320PFD.Create(Parent);
     Airbus.Parent  := Parent;
     Generic        := TfraSixPack.Create(Parent);
     Generic.Parent := Parent;
     Assert.AreEqual(Tr('Osobne okno'), Generic.aWindow.Caption, Locale);
     Assert.AreEqual(Tr('Osobne okno'), Boeing.aWindow.Caption, Locale);
     Assert.AreEqual(Tr('Osobne okno'), Airbus.aWindow.Caption, Locale);
     Assert.AreEqual(710, Integer(Boeing.HelpContext));
     Assert.AreEqual(730, Integer(Airbus.HelpContext));
    Finally
     Parent.Free;
    End;
   End;
  SetLanguage('pl-PL');
 End;

Begin
 RunNativeTests(TVerifyPFD737Tests);
End.
