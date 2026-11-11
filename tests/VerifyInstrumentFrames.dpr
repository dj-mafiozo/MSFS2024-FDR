Program VerifyInstrumentFrames;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU In 'TestPathsU.pas', DUnitX.TestFramework, NativeTestRunnerU In 'NativeTestRunnerU.pas', System.SysUtils, System.Classes, System.IniFiles, System.Math, System.Types,
 Vcl.ImgList, Vcl.Forms, Vcl.Controls, Vcl.Graphics, Vcl.Imaging.pngimage,
 FlightDatabaseU In '..\src\Data\FlightDatabaseU.pas', FlightTelemetryU In '..\src\Telemetry\FlightTelemetryU.pas', TelemetryCatalogU In '..\src\Telemetry\TelemetryCatalogU.pas', InstrumentDataU In '..\src\Visualization\InstrumentDataU.pas', SixPackU In '..\src\Visualization\SixPackU.pas', PFDScalesU In '..\src\Visualization\PFDScalesU.pas',
 frmMainU In '..\src\Forms\frmMainU.pas', fraB38MEICASU In '..\src\Frames\fraB38MEICASU.pas', ParameterNamesU In '..\src\Visualization\ParameterNamesU.pas';

Procedure Check(b : Boolean; Const m : String);
 Begin
  If Not b Then
   Raise Exception.Create(m);
 End;

Var
 DB     : TFlightDatabase;
 s      : TFlightSample;
 Main   : TfrmMain;
 IDs    : Array[0..4] Of Integer;
 i      : Integer;
 j      : Integer;
 k      : Integer;
 b      : TBitmap;
 PNG    : TPngImage;
 Plot   : TTripPlot;
 p      : TPlotPoint;
 Bounds : TRect;
 Config : TMemIniFile;

Procedure N(Const Name : String; v : Double);
 Var
  f : Integer;
 Begin
  For f := 0 To FieldCount - 1 Do
   If SimFields[f].Name = Name Then
    Begin
     s.Numbers[f] := v;
     Exit;
    End;
  Raise Exception.Create(Name);
 End;

Procedure CheckPlaybackIcons;
 Var
  l          : TImageList;
  t          : TBitmap;
  i          : Integer;
  x          : Integer;
  y          : Integer;
  Foreground : Integer;
 Begin
  t := TBitmap.Create;
  Try
   For l In TArray<TImageList>.Create(Main.ImageList, Main.ImageListSmall) Do
    Begin
     Check(l.Count = 70, 'All manual icon indices preserved');
     t.SetSize(l.Width, l.Height);
     For i := 64 To 69 Do
      Begin
       t.Canvas.Brush.Color := clFuchsia;
       t.Canvas.FillRect(Rect(0, 0, t.Width, t.Height));
       l.Draw(t.Canvas, 0, 0, i, True);
       Check(ColorToRGB(t.Canvas.Pixels[0, 0]) = ColorToRGB(clFuchsia), 'Playback icon corner stays transparent');
       Foreground := 0;
       For y      := 0 To t.Height - 1 Do
        For x     := 0 To t.Width - 1 Do
         If ColorToRGB(t.Canvas.Pixels[x, y]) <> ColorToRGB(clFuchsia) Then
          Inc(Foreground);
       Check(Foreground > 0, 'Playback icon remains visible');
      End;
    End;
  Finally
   t.Free;
  End;
 End;

Procedure CheckFooter;
 Begin
  Check(Main.SliderPanel.Parent = Main.CenterPanel, 'Timeline has an independent parent from resizable views');
  Check(Main.InstrumentsPanel.Parent = Main.ViewsPanel, 'Instrument panel is inside view container');
  Check(Main.SplitterInstruments.Parent = Main.ViewsPanel, 'Instrument splitter can only resize view siblings');
  Check(Main.ViewsPanel.Top + Main.ViewsPanel.Height <= Main.SliderPanel.Top, 'Views stay above timeline');
  If Main.InstrumentsPanel.Visible Then
   Check(Main.SplitterInstruments.Top + Main.SplitterInstruments.Height = Main.InstrumentsPanel.Top, 'Horizontal splitter stays immediately above instruments');
 End;

Procedure OpenFlight(ID : Integer);
 Begin
  Main.SelectRecording(ID);
  Main.SelectTrip(Main);
  Application.ProcessMessages;
 End;

Type

 [TestFixture]
 TVerifyInstrumentFramesTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyInstrumentFramesTests.Regression;
 Begin
  Try
   Application.Initialize;
   Config := TMemIniFile.Create(TestDataDirectory + 'settings.ini', TEncoding.UTF8);
   Try
    Config.WriteBool('recording', 'enabled', False);
    Config.WriteBool('map', 'online_tiles', False);
    Config.UpdateFile;
   Finally
    Config.Free;
   End;
   Plot := TTripPlot.Create;
   Try
    p.Time := '2026-10-24T12:00:00Z';
    Plot.Points.Add(p);
    Plot.AircraftTitle := 'iFly 737 MAX 8';
    Check(InstrumentProfile(Plot, 0).Kind <> ikB38MPFD, 'Title alone cannot select B38M');
    Plot.AircraftTypeICAO := 'B38M';
    Check(InstrumentProfile(Plot, 0).Kind = ikB38MPFD, 'Exact ICAO selects B38M');
    For i := 6 To 9 Do
     Begin
      Plot.AircraftTypeICAO := 'B73' + IntToStr(i);
      Check(InstrumentProfile(Plot, 0).Kind = ikAirlinerPFD, 'NG remains generic');
     End;
   Finally
    Plot.Free;
   End;
   Check(PFDVSIDeflection(1000) = 0.5, 'Shared pointer geometry');
   DB := TFlightDatabase.Create(TestDatabasePath('flight_data.db'), TestRuntimeFile('sqlite3.dll'));
   s  := TFlightSample.Create;
   Try
    N('time_zulu.year', 2026);
    N('time_zulu.month', 10);
    N('time_zulu.day', 24);
    N('time_local.year', 2026);
    N('time_local.month', 10);
    N('time_local.day', 24);
    N('engine_type', 1);
    N('number_of_engines', 2);
    N('airspeed_indicated', 145);
    N('indicated_altitude', 3000);
    N('plane_pitch_degrees', -3);
    N('plane_bank_degrees', 0);
    N('heading_indicator', 251);
    N('vertical_speed', 1000);
    N('kohlsman_setting_mb', 1013);
    N('plane_coordinate.latitude', 51.7);
    N('plane_coordinate.longitude', 19.4);
    N('turb_eng_n1[0]', 84.7);
    For i := 0 To 4 Do
     Begin
      For k := 0 To FieldCount - 1 Do
       Begin
        If SimFields[k].Name = 'title' Then
         Case i Of
          3 : s.Texts[k] := 'Fenix A320';
          4 : s.Texts[k] := 'FlyByWire A32NX';
         Else s.Texts[k] := 'Custom livery ' + IntToStr(i);
         End;
        If SimFields[k].Name = 'atc_model' Then
         Case i Of
          0 : s.Texts[k] := 'B38M';
          1 : s.Texts[k] := 'B738';
          2 : s.Texts[k] := 'C172';
          3 : s.Texts[k] := 'A320';
          4 : s.Texts[k] := 'A20N';
         End;
       End;
      N('time_zulu.seconds', i * 100);
      IDs[i] := DB.StartTrip(s);
      For j  := 0 To 1 Do
       Begin
        N('time_zulu.seconds', i * 100 + j);
        DB.RecordSample(IDs[i], s);
       End;
      DB.EndTrip(IDs[i], s);
     End;
   Finally
    s.Free;
    DB.Free;
   End;
   Main := TfrmMain.Create(Nil);
   Try
    Main.Timer.Enabled := False;
    Main.Show;
    CheckPlaybackIcons;
    Check(Pos('*.db', Main.ImportFlightDialog.Filter) > 0, 'DFM import dialog accepts Qt databases');
    Check(Main.miExportLegacy.Action = Main.aExportLegacy, 'Legacy export menu uses DFM action');
    Check((Main.LegacyExportDialog.DefaultExt = 'db') And Assigned(Main.aExportLegacy.OnExecute), 'Legacy save dialog and execute handler are present');
    Check(Main.EnginesFrame.FindComponent('Scroll') = Nil, 'Generic engine frame has no ScrollBox');
    Check(Main.B38MEICASFrame.FindComponent('Scroll') = Nil, 'EICAS frame has no ScrollBox');
    OpenFlight(IDs[0]);
    CheckFooter;
    Check(Main.aPlayPause.Enabled And (Main.lPlayRate.Caption = '1x'), 'Playback enabled for selected flight');
    Main.aPlayPause.Execute;
    Check(Main.PlaybackTimer.Enabled And (Main.aPlayPause.ImageIndex = 65), 'Play starts timer and pause glyph');
    Main.aPlayPause.Execute;
    Check(Not Main.PlaybackTimer.Enabled And (Main.aPlayPause.ImageIndex = 64), 'Pause stops timer and restores play glyph');
    Main.aEnding.Execute;
    Check(Main.Timeline.Position = 1, 'End action seeks last sample');
    Main.aBeginning.Execute;
    Check(Main.Timeline.Position = 0, 'Beginning seeks first sample');
    Main.aSkip.Execute;
    Check(Main.Timeline.Position = 1, 'Skip action clamps at end');
    Main.aBack.Execute;
    Check(Main.Timeline.Position = 0, 'Back action clamps at beginning');
    Main.aStopPlayback.Execute;
    Check((Main.lPlayRate.Caption = '1x') And (Main.PlayBackRate.Position = 4), 'Stop restores 1x selector');
    For i := 0 To 2 Do
     Begin
      Main.ClientHeight := 650 + i * 100;
      Application.ProcessMessages;
      CheckFooter;
     End;
    Check(Main.InstrumentKind = ikB38MPFD, 'Replay ICAO picks specialized kind');
    Check(Main.PFD737Frame.Visible And Not Main.SixPackFrame.Visible, 'PFD replaces six-pack in existing slot');
    Check(Main.PFD737Frame.Parent = Main.SixPackPanel, 'PFD declared inline in instrument panel');
    Check(Main.B38MEICASFrame.Visible And Not Main.EnginesFrame.Visible, 'EICAS replaces engine frame');
    Check(Main.B38MEICASFrame.Parent = Main.EnginePanel, 'EICAS declared inline in engine panel');
    Check((Main.B38MEICASFrame.Display.Align = alClient) And
    (Main.B38MEICASFrame.Display.Height = Main.B38MEICASFrame.ClientHeight - Main.B38MEICASFrame.ToolBar1.Height),
    'EICAS fits remaining frame client area');
    Main.SixPackPanel.Width := Main.SixPackPanel.Width - 30;
    Main.InstrumentSplitMoved(Main);
    Application.ProcessMessages;
    Check(Main.SplitterSixPackEngines.Left = Main.SixPackPanel.Left + Main.SixPackPanel.Width, 'Splitter remains after primary display');
    Check(Main.EnginePanel.Left = Main.SplitterSixPackEngines.Left + Main.SplitterSixPackEngines.Width, 'Engine panel follows splitter');
    Check(Not Main.SplitterSixPackEngines.AutoSnap, 'Splitter cannot collapse primary display');
    Main.PFD737Frame.aWindow.Execute;
    Main.B38MEICASFrame.aWindow.Execute;
    Check((Main.SixPackWindow <> Nil) And (Main.EnginesWindow <> Nil), 'Both slots detach');
    CheckFooter;
    Check((Main.PFD737Frame.aWindow.ImageIndex = 1) And (Main.B38MEICASFrame.aWindow.ImageIndex = 1), 'Detached icons');
    Bounds                 := Main.SixPackWindow.BoundsRect;
    Main.Timeline.Position := 1;
    Main.TimelineChange(Main.Timeline);
    Check(Main.PFD737Frame.Display.State.Time = Main.CursorLabel.Caption, 'PFD follows timeline');
    Check(Main.B38MEICASFrame.Display.Time = Main.CursorLabel.Caption, 'EICAS follows timeline');
    OpenFlight(IDs[1]);
    Check(Main.InstrumentKind = ikAirlinerPFD, 'NG remains generic on recording switch');
    Check((Main.EnginesFrame.Display.Align = alClient) And
    (Main.EnginesFrame.Display.Height = Main.EnginesFrame.ClientHeight - Main.EnginesFrame.ToolBar1.Height),
    'Generic gauges fit their frame instead of growing per sample');
    Check((Main.SixPackFrame.Parent = Main.SixPackWindow) And (Main.EnginesFrame.Parent = Main.EnginesWindow), 'Detached slots replace frame after flight switch');
    Check(EqualRect(Main.SixPackWindow.BoundsRect, Bounds), 'Floating bounds survive frame switch');
    Check(Not Main.PFD737Frame.Visible And Not Main.B38MEICASFrame.Visible, 'Inactive MAX frames hidden');
    OpenFlight(IDs[0]);
    Check((Main.PFD737Frame.Parent = Main.SixPackWindow) And (Main.B38MEICASFrame.Parent = Main.EnginesWindow), 'Reverse switch restores MAX frames');
    Main.PFD737Frame.aWindow.Execute;
    Main.EnginesWindow.Close;
    Application.ProcessMessages;
    Check((Main.SixPackWindow = Nil) And (Main.EnginesWindow = Nil), 'Return button and X dock both slots');
    Check(Main.PFD737Frame.Visible And Main.B38MEICASFrame.Visible, 'Docked MAX frames visible');
    CheckFooter;
    Check((Main.PFD737Frame.aWindow.ImageIndex = 0) And (Main.B38MEICASFrame.aWindow.ImageIndex = 0), 'Docked icons');
    OpenFlight(IDs[1]);
    b   := TBitmap.Create;
    PNG := TPngImage.Create;
    Try
     Main.InstrumentsPanel.Height := 300;
     Main.SixPackPanel.Width      := 600;
     Application.ProcessMessages;
     b.SetSize(Main.SixPackFrame.Display.Width, Main.SixPackFrame.Display.Height);
     Main.SixPackFrame.Display.PaintTo(b.Canvas, 0, 0);
     PNG.Assign(b);
     PNG.SaveToFile(TestRepositoryPath('tests\generic-pfd-preview.png'));
     Check(ColorToRGB(b.Canvas.Pixels[5, 60]) = ColorToRGB($00474747), 'IAS tape replaces former box');
    Finally
     PNG.Free;
     b.Free;
    End;
    OpenFlight(IDs[2]);
    Check(Main.InstrumentKind = ikGaAnalog, 'GA returns to analog instruments');
    OpenFlight(IDs[3]);
    Check(Main.InstrumentKind = ikA320PFD, 'Fenix selects A320 kind');
    Check(Main.A320PFDFrame.Visible And Main.A320ECAMFrame.Visible, 'A320 frames replace generic/Boeing');
    Check(Not Main.SixPackFrame.Visible And Not Main.PFD737Frame.Visible And Not Main.B38MEICASFrame.Visible, 'No duplicate instrument displays');
    Main.A320PFDFrame.aWindow.Execute;
    Main.A320ECAMFrame.aWindow.Execute;
    Check((Main.A320PFDFrame.Parent = Main.SixPackWindow) And (Main.A320ECAMFrame.Parent = Main.EnginesWindow), 'Airbus slots detach');
    Bounds := Main.SixPackWindow.BoundsRect;
    OpenFlight(IDs[0]);
    Check(Main.PFD737Frame.Parent = Main.SixPackWindow, 'Airbus to Boeing while detached');
    OpenFlight(IDs[4]);
    Check(Main.A320PFDFrame.Parent = Main.SixPackWindow, 'FBW restores Airbus frame');
    Check(EqualRect(Main.SixPackWindow.BoundsRect, Bounds), 'Airbus swap preserves floating geometry');
    Main.Timeline.Position := 1;
    Main.TimelineChange(Main.Timeline);
    Check(Main.A320ECAMFrame.UpperDisplay.Data.Time = Main.CursorLabel.Caption, 'Upper ECAM synchronized');
    Check(Main.A320ECAMFrame.LowerDisplay.Data.Time = Main.CursorLabel.Caption, 'Lower ECAM synchronized');
    Check(Main.A320PFDFrame.Display.Data.Time = Main.CursorLabel.Caption, 'Airbus PFD synchronized');
    Main.A320ECAMFrame.aWindow.Execute;
    Main.SixPackWindow.Close;
    Application.ProcessMessages;
    CheckFooter;

   Finally
    Main.Free;
   End;
   System.Writeln('PASS: strict ICAO B38M kind, NG generic, DFM frame replacement, timeline, dock/float icons, switch while detached with preserved bounds, generic shared IAS/ALT/VSI and GA fallback. Synthetic only.');
  Except
   On E : Exception Do
    Begin
     System.Writeln(E.ClassName + ': ' + E.Message);
     Raise Exception.Create('Regression failed; see diagnostic above');
    End;
  End;

 End;

Begin
 RunNativeTests(TVerifyInstrumentFramesTests);
End.
