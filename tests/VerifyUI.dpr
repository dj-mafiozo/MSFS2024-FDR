Program VerifyUI;

{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU In 'TestPathsU.pas', DUnitX.TestFramework, NativeTestRunnerU In 'NativeTestRunnerU.pas',
 Winapi.Windows, System.SysUtils, System.Classes, System.Math, Vcl.ComCtrls, System.IOUtils, VirtualTrees, VirtualTrees.BaseTree, VirtualTrees.Types, Vcl.Controls, Vcl.ExtCtrls, System.UITypes, Vcl.Forms, Vcl.Grids, System.Types, Vcl.Graphics, Vcl.Imaging.pngimage,

 frmDockViewU In '..\src\Forms\frmDockViewU.pas', LocalizationU In '..\src\i18n\LocalizationU.pas', frmReportU In '..\src\Forms\frmReportU.pas', FlightPlanU In '..\src\FlightPlan\FlightPlanU.pas', frmChartsConfigureU In '..\src\Forms\frmChartsConfigureU.pas', frmSettingsU In '..\src\Forms\frmSettingsU.pas', System.IniFiles,

 frmMainU In '..\src\forms\frmMainU.pas', FlightDatabaseU In '..\src\data\FlightDatabaseU.pas', FlightTelemetryU In '..\src\telemetry\FlightTelemetryU.pas', TelemetryCatalogU In '..\src\telemetry\TelemetryCatalogU.pas';

Procedure CheckGSXProgress(f : TfrmMain);
 Var
  l : TStringList;
  v : TArray<Double>;
  i : Integer;

  Procedure Check(b : Boolean; Const m : String);
   Begin
    If Not b Then
     Raise Exception.Create(m);
   End;

 Begin
  l := TStringList.Create;
  Try
   l.Add('GSX.FSDT_GSX_BOARDING_STATE');
   l.Add('GSX.FSDT_GSX_NUMPASSENGERS_BOARDING_TOTAL');
   l.Add('GSX.FSDT_GSX_NUMPASSENGERS');
   l.Add('GSX.FSDT_GSX_BOARDING_CARGO_PERCENT');
   l.Add('GSX.FSDT_GSX_REFUELING_STATE');
   l.Add('GSX.FSDT_GSX_FUEL_COUNTER');
   l.Add('GSX.FSDT_GSX_FUEL_COUNTER_MAX');
   l.Add('GSX.FSDT_GSX_CATERING_STATE');
   SetLength(v, l.Count);
   For i := 0 To High(v) Do
    v[i] := NaN;
   f.UpdateGSXProgress(l, v);
   Check(Not f.GSXProgressPanel.Visible, 'Missing GSX hides progress');
   v[0] := 1;
   f.UpdateGSXProgress(l, v);
   Check(Not f.GSXBoardingProgressPanel.Visible, 'Available has no progress');
   v[0] := 4;
   v[1] := 0;
   v[2] := 145;
   v[3] := 0;
   f.UpdateGSXProgress(l, v);
   Check(f.GSXProgressPanel.Visible And f.GSXBoardingProgressPanel.Visible, 'Requested reveals progress');
   Check((f.GSXBoardingProgress.Style = pbstNormal) And (f.GSXBoardingProgress.Position = 0), 'Requested baseline');
   v[0] := 5;
   v[1] := 14;
   v[3] := 25;
   f.UpdateGSXProgress(l, v);
   Check((f.GSXBoardingProgress.Position = 10) And (f.GSXBoardingCargoProgress.Position = 25), 'Passenger and baggage progress');
   v[0] := 6;
   v[1] := 145;
   v[3] := 100;
   f.UpdateGSXProgress(l, v);
   Check(f.GSXBoardingProgressPanel.Visible And (f.GSXBoardingProgress.Position = 100), 'Completion remains visible');
   v[0] := 4;
   v[1] := 0;
   v[3] := 0;
   f.UpdateGSXProgress(l, v);
   Check(f.GSXBoardingProgress.Position = 0, 'Backward seek resets progress');
   v[0] := 1;
   v[4] := 4;
   f.UpdateGSXProgress(l, v);
   Check(f.GSXRefuelingProgressPanel.Visible And (f.GSXRefuelingProgress.Style = pbstMarquee), 'Refueling requested without denominator');
   v[4] := 5;
   v[5] := 250;
   v[6] := 1000;
   f.UpdateGSXProgress(l, v);
   Check((f.GSXRefuelingProgress.Style = pbstNormal) And (f.GSXRefuelingProgress.Position = 25), 'Actual fuel truck counter');
   v[5] := 0;
   f.UpdateGSXProgress(l, v);
   Check(f.GSXRefuelingProgress.Position = 0, 'New fuel truck resets its counter');
   v[4] := 6;
   v[5] := 1000;
   f.UpdateGSXProgress(l, v);
   Check(f.GSXRefuelingProgress.Position = 100, 'Fuel completion');
   v[7] := 4;
   f.UpdateGSXProgress(l, v);
   Check(f.GSXCateringProgress.Style = pbstMarquee, 'Unmeasured service is indeterminate');
   v[7] := 6;
   f.UpdateGSXProgress(l, v);
   Check(f.GSXCateringProgress.Position = 100, 'Unmeasured completion');
   f.UpdateGSXProgress(Nil, Nil);
   Check(Not f.GSXProgressPanel.Visible, 'Clearing recording hides all bars');
   System.Writeln('PASS: DFM GSX bars, Requested/active/completed/backward seek, missing values, passengers/cargo and fuel truck resets. Synthetic only.');
  Finally
   l.Free;
  End;
 End;

Type
 TErrors = Class
  Procedure Error(Sender : TObject; e : Exception);
 End;

Procedure TErrors.Error(Sender : TObject; e : Exception);
 Begin
  System.Writeln('VCL ERROR: ', e.Message);
  Raise Exception.Create('Regression failed; see diagnostic above');
 End;

Type
 TLayoutProbe = Class
  Changes : Integer;
  Procedure Resize(Sender : TObject);
 End;

Procedure TLayoutProbe.Resize(Sender : TObject);
 Begin
  Inc(Changes);
 End;

Procedure CheckIdleLayout(f : TfrmMain);
 Var
  p : TLayoutProbe;
  i : Integer;
  a : TNotifyEvent;
  b : TNotifyEvent;
  c : TNotifyEvent;
 Begin
  f.Tick(f);
  Application.ProcessMessages;
  p := TLayoutProbe.Create;
  a := f.CenterPanel.OnResize;
  b := f.RightPanel.OnResize;
  c := f.StatusBar1.OnResize;
  Try
   f.CenterPanel.OnResize := p.Resize;
   f.RightPanel.OnResize  := p.Resize;
   f.StatusBar1.OnResize  := p.Resize;
   For i                  := 1 To 100 Do
    Begin
     f.Tick(f);
     Application.ProcessMessages;
    End;
   If p.Changes <> 0 Then
    Raise Exception.CreateFmt('Idle layout causes %d resize events', [p.Changes]);
  Finally
   f.CenterPanel.OnResize := a;
   f.RightPanel.OnResize  := b;
   f.StatusBar1.OnResize  := c;
   p.Free;
  End;
 End;

Type
 TChartProbe = Class
  Mode  : Integer;
  Found : Boolean;
  Timer : TTimer;
  Procedure Run(Sender : TObject);
 End;

Procedure TChartProbe.Run(Sender : TObject);
 Var
  i : Integer;
  j : Integer;
  d : TfrmChartsConfigure;
 Begin
  For j := 0 To Screen.FormCount - 1 Do
   If Screen.Forms[j] Is TfrmChartsConfigure Then
    Begin
     Timer.Enabled := False;
     Found         := True;
     d             := TfrmChartsConfigure(Screen.Forms[j]);
     If Mode = 0 Then
      Begin
       If d.ParameterList.Count < 200 Then
        Raise Exception.Create('Parameters missing in chart dialog');
       For i := 0 To d.ParameterList.Count - 1 Do
        Begin
         d.ParameterList.ItemIndex  := i;
         d.ParameterList.Checked[i] := i < 32;
         d.ParameterCheck(d.ParameterList);
        End;
      End
     Else If Mode = 1 Then
      Begin
       d.ChartOrderList.ItemIndex := 1;
       d.MoveChart(d.btnMoveUp);
       If d.ChartOrderList.ItemIndex <> 0 Then
        Raise Exception.Create('Chart reordering failed');
      End
     Else
      Begin
       d.ChartOrderList.ItemIndex := 0;
       d.HideChart(d.btnHide);
       d.ModalResult := mrCancel;
       Exit;
      End;
     d.ModalResult := mrOk;
     Exit;
    End;
 End;

Procedure CheckCachedReport(Main : TfrmMain; Landing : Boolean);
 Var
  i        : Integer;
  Report   : TfrmReport;
  Found    : Boolean;
  Expected : String;
 Begin
  Found := False;
  If Landing Then
   Begin
    Main.miLanding.Click;
    Expected := Tr('Analiza lądowania');
   End
  Else
   Begin
    Main.miTakeoff.Click;
    Expected := Tr('Analiza startu');
   End;
  For i := Screen.FormCount - 1 Downto 0 Do
   If Screen.Forms[i] Is TfrmReport Then
    Begin
     Report := TfrmReport(Screen.Forms[i]);
     Found  := True;
     If Report.Caption <> Expected Then
      Raise Exception.Create('Cached report title: ' + Report.Caption);
     Report.Close;
    End;
  Application.ProcessMessages;
  If Not Found Then
   Raise Exception.Create('Cached report action did not open report');
 End;

Var
 Handled       : Boolean;
 Mouse         : TPoint;
 BeforeSeconds : Integer;
 AfterSeconds  : Integer;
 Settings      : TfrmSettings;
 Config        : TMemIniFile;
 Plan          : TFlightPlan;
 DB            : TFlightDatabase;
 s             : TFlightSample;
 f             : TfrmMain;
 Root          : String;
 ID            : Integer;
 i             : Integer;
 j             : Integer;
 b             : TBitmap;
 PNG           : TPngImage;
 Errors        : TErrors;
 Probe         : TChartProbe;
 OldRange      : Integer;

Procedure SetN(Const Name : String; Value : Double);
 Var
  i : Integer;
 Begin
  For i := 0 To FieldCount - 1 Do
   If SimFields[i].Name = Name Then
    Begin
     s.Numbers[i] := Value;
     Exit;
    End;
  Raise Exception.Create('Missing field ' + Name);
 End;

Type

 [TestFixture]
 TVerifyUITests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyUITests.Regression;
 Begin

  Application.Initialize;
  Errors                  := TErrors.Create;
  Application.OnException := Errors.Error;
  Root                    := TestDataDirectory;
  System.Writeln('Creating fixture');
  DB := TFlightDatabase.Create(TestDatabasePath(TPath.Combine(Root, 'flight_data.db')), TPath.Combine(Root, 'sqlite3.dll'));
  s  := TFlightSample.Create;

  Try

   For i := 0 To FieldCount - 1 Do
    If SimFields[i].Name = 'title' Then
     s.Texts[i] := 'Native VCL Test Flight';

   SetN('time_zulu.year', 2026);
   SetN('time_zulu.month', 10);
   SetN('time_zulu.day', 12);
   SetN('time_local.year', 2026);
   SetN('time_local.month', 10);
   SetN('time_local.day', 12);

   SetN('number_of_engines', 2);
   SetN('eng_combustion[0]', 1);
   SetN('eng_combustion[1]', 1);
   SetN('plane_coordinate.latitude', 52);
   SetN('plane_coordinate.longitude', 20);
   ID := DB.StartTrip(s);

   For j := 0 To 20 Do
    Begin
     SetN('time_zulu.seconds', j);
     SetN('time_local.seconds', j);
     SetN('plane_coordinate.latitude', 52 + j * 0.005);
     SetN('plane_coordinate.longitude', 20 + j * 0.01);
     SetN('plane_altitude', 1000 + j * 50);
     SetN('vertical_speed', 1000 - j * 50);
     SetN('turb_eng_n1[0]', 45 + j * 2);
     DB.RecordSample(ID, s);
    End;
   DB.EndTrip(ID, s);
   DB.Contact(ID, s, False);
   DB.Contact(ID, s, True);
   DB.Connection.ExecSQL('update trip_liftoffs set analysis_report=:r where trip=:t', ['# Cached takeoff', ID]);
   DB.Connection.ExecSQL('update trip_touchdowns set analysis_report=:r where trip=:t', ['# Cached landing', ID]);

   Plan := ParsePLN('<SimBase.Document><FlightPlan.FlightPlan><DepartureID>EPLL</DepartureID><DestinationID>EPLL</DestinationID>' +

   '<DepartureDetails><RunwayNumberFP>25</RunwayNumberFP><DepartureFP>ADOX2W</DepartureFP></DepartureDetails>' +

   '<ATCWaypoint id="TEST1"><WorldPosition>52.02,20.02,0</WorldPosition></ATCWaypoint>' +

   '<ATCWaypoint id="TEST2"><WorldPosition>52.09,20.18,0</WorldPosition></ATCWaypoint>' +

   '</FlightPlan.FlightPlan></SimBase.Document>', 'fixture.pln');

   Try
    DB.SaveFlightPlan(ID, Plan);
   Finally
    Plan.Free;
   End;

  Finally
   s.Free;
   DB.Free;
  End;

  Config := TMemIniFile.Create(TPath.Combine(Root, 'ai-settings-test.ini'));

  Settings := TfrmSettings.Create(Nil);

  Try

   Config.EraseSection('ai');

   ReadAnalysisWindow(Config, False, BeforeSeconds, AfterSeconds);

   If (BeforeSeconds <> 60) Or (AfterSeconds <> 30) Then
    Raise Exception.Create('Takeoff defaults');

   ReadAnalysisWindow(Config, True, BeforeSeconds, AfterSeconds);

   If (BeforeSeconds <> 180) Or (AfterSeconds <> 30) Then
    Raise Exception.Create('Landing defaults');

   Config.WriteInteger('ai', 'context_before_seconds', 42);
   Config.WriteInteger('ai', 'context_after_seconds', 17);

   ReadAnalysisWindow(Config, True, BeforeSeconds, AfterSeconds);

   If (BeforeSeconds <> 42) Or (AfterSeconds <> 17) Then
    Raise Exception.Create('Legacy window fallback');

   Settings.Load(Config);
   Settings.seBefore.Value        := 65;
   Settings.seAfter.Value         := 25;
   Settings.seLandingBefore.Value := 240;
   Settings.seLandingAfter.Value  := 45;

   Settings.cbProvider.ItemIndex := 1;
   Settings.eCodexModel.Text     := 'test-model';
   Settings.seTimeout.Value      := 123;
   Settings.Save(Config);

   Settings.cbProvider.ItemIndex := 0;
   Settings.eCodexModel.Clear;
   Settings.Load(Config);

   ReadAnalysisWindow(Config, False, BeforeSeconds, AfterSeconds);

   If (BeforeSeconds <> 65) Or (AfterSeconds <> 25) Then
    Raise Exception.Create('Independent takeoff window');

   ReadAnalysisWindow(Config, True, BeforeSeconds, AfterSeconds);

   If (BeforeSeconds <> 240) Or (AfterSeconds <> 45) Or (Settings.seLandingBefore.Value <> 240) Or (Settings.seLandingAfter.Value <> 45) Then
    Raise Exception.Create('Landing window persistence');

   Config.WriteInteger('ai', 'landing_before_seconds', 999);
   Config.WriteInteger('ai', 'landing_after_seconds', -1);

   ReadAnalysisWindow(Config, True, BeforeSeconds, AfterSeconds);

   If (BeforeSeconds <> 300) Or (AfterSeconds <> 1) Then
    Raise Exception.Create('Window limits');

   If (Settings.cbProvider.ItemIndex <> 1) Or (Settings.eCodexModel.Text <> 'test-model') Or (Settings.seTimeout.Value <> 123) Then
    Raise Exception.Create('AI settings roundtrip failed');

  Finally
   Settings.Free;
   Config.Free;
  End;

  System.Writeln('Creating VCL form');
  f   := TfrmMain.Create(Nil);
  b   := TBitmap.Create;
  PNG := TPngImage.Create;
  System.Writeln('Showing test form');

  Try

   f.Timer.Enabled  := False;
   f.aTiles.Checked := False;
   f.aTilesExecute(f.aTiles);
   f.Position := poDesigned;
   f.Left     := -4000;
   f.Top      := 0;
   f.Show;
   Application.ProcessMessages;
   f.SelectTrip(f);
   f.aFit.Execute;
   Application.ProcessMessages;

   CheckGSXProgress(f);
   CheckCachedReport(f, False);
   CheckCachedReport(f, True);
   If Not Assigned(f.vstRecordings.OnDblClick) Then
    Raise Exception.Create('History double-click missing');

   If f.SimBriefPage.PageIndex <> f.PlanPage.PageIndex + 1 Then
    Raise Exception.Create('SimBrief tab must follow flight plan');

   If f.SimBriefPage.ControlCount <> 1 Then
    Raise Exception.Create('SimBrief frame missing');

   f.vstRecordings.OnDblClick(f.vstRecordings);

   If (toEditable In f.vstRecordings.TreeOptions.MiscOptions) Or Not f.EventGrid.ReadOnly Or Not f.ContactGrid.ReadOnly Or (goEditing In f.DataGrid.Options) Then
    Raise Exception.Create('Grid editing enabled');

   Probe       := TChartProbe.Create;
   Probe.Timer := TTimer.Create(Nil);
   Try
    Probe.Mode           := 0;
    Probe.Timer.Interval := 20;
    Probe.Timer.OnTimer  := Probe.Run;
    Probe.Timer.Enabled  := True;
    f.aChartsConfigure.Execute;
    Application.ProcessMessages;
    If Not Probe.Found Then
     Raise Exception.Create('Chart action did not open configuration');
   Finally
    Probe.Timer.Free;
    Probe.Free;
   End;

   If f.ChartsHost.VertScrollBar.Range < 32 * 155 Then
    Raise Exception.Create('More than 8 charts unavailable');

   Mouse   := f.ChartsHost.ClientToScreen(Point(20, 20));
   Handled := False;

   f.ChartsWheel(f, [], -120, Mouse, Handled);

   If Not Handled Or (f.ChartsHost.VertScrollBar.Position = 0) Then
    Raise Exception.Create('Chart wheel failed');

   If f.SplitMap.Top < f.MapPanel.Top + f.MapPanel.Height - 2 Then
    Raise Exception.Create('Map splitter is above map');

   f.MapPanel.Height  := 320;
   f.LeftPanel.Width  := 280;
   f.RightPanel.Width := 320;

   If f.DataGrid.RowCount < 200 Then
    Raise Exception.Create('Native data inspector missing telemetry');

   f.eValueSearch.Text := 'plane_altitude';
   If (f.DataGrid.RowCount <> 2) Or (f.DataGrid.Cells[0, 1] = '') Then
    Raise Exception.Create('Inspector raw parameter search failed');
   f.eValueSearch.Text := 'no_such_parameter_xyz';
   If f.DataGrid.Cells[0, 1] <> '' Then
    Raise Exception.Create('Empty search retains stale row');
   f.eValueSearch.Text := '';
   If f.GSXPage.Caption <> 'GSX Pro' Then
    Raise Exception.Create('GSX DFM page missing');
   If f.MapFrame.Owner <> f Then
    Raise Exception.Create('Map frame ownership');

   If Not Assigned(f.btnLandingAnalysis) Or Not Assigned(f.btnOverview) Then
    Raise Exception.Create('DFM actions missing');

   Probe       := TChartProbe.Create;
   Probe.Timer := TTimer.Create(Nil);
   Try
    Probe.Mode           := 1;
    Probe.Timer.Interval := 20;
    Probe.Timer.OnTimer  := Probe.Run;
    Probe.Timer.Enabled  := True;
    f.aChartsConfigure.Execute;
    If Not Probe.Found Then
     Raise Exception.Create('Reorder dialog not opened');
    OldRange            := f.ChartsHost.VertScrollBar.Range;
    Probe.Mode          := 2;
    Probe.Found         := False;
    Probe.Timer.Enabled := True;
    f.aChartsConfigure.Execute;
    If Not Probe.Found Or (f.ChartsHost.VertScrollBar.Range <> OldRange) Then
     Raise Exception.Create('Cancel changed active charts');
   Finally
    Probe.Timer.Free;
    Probe.Free;
   End;

   f.aZoomIn.Execute;
   If Not f.ViewPan.Enabled Then
    Raise Exception.Create('Zoom did not enable pan');

   f.ViewPan.Position := 1000;
   f.PanChart(f);

   f.aFullView.Execute;
   If f.ViewPan.Enabled Then
    Raise Exception.Create('Full view did not reset pan');

   f.Timeline.Position := 10;
   f.TimelineChange(f);
   If Pos('00:00:10', f.CursorLabel.Caption) = 0 Then
    Raise Exception.Create('Native timeline not synchronized');

   If Pos('EPLL.25 ADOX2W', f.mPlan.Text) = 0 Then
    Raise Exception.Create('Saved flight plan missing from UI');

   f.DataTabs.ActivePage := f.PlanPage;
   Application.ProcessMessages;

   For i := 0 To f.ComponentCount - 1 Do
    If f.Components[i] Is TfrmDockView Then
     TfrmDockView(f.Components[i]).ManualFloat(Rect(50, 50, 500, 500));
   f.FMCFrame.aWindow.Execute;
   f.SimBriefFrame.aWindow.Execute;
   f.Tick(f);
   If f.RightPanel.Visible Or f.SplitRight.Visible Then
    Raise Exception.Create('Empty tab host reserves space');
   For i := 0 To f.ComponentCount - 1 Do
    If f.Components[i] Is TfrmDockView Then
     TfrmDockView(f.Components[i]).ManualDock(f.DataTabs, Nil, alClient);
   f.FMCWindow.Close;
   f.SimBriefWindow.Close;
   f.Tick(f);
   If Not f.RightPanel.Visible Then
    Raise Exception.Create('Docked tabs did not restore host');
   If f.SplitterInstruments.Top + f.SplitterInstruments.Height > f.InstrumentsPanel.Top Then
    Raise Exception.Create('Instrument splitter overlaps instruments');

   For i := 0 To f.DataTabs.PageCount - 1 Do
    Begin
     f.DataTabs.ActivePageIndex := i;
     Application.ProcessMessages;
     If f.DataTabs.ActivePage.ControlCount > 0 Then
      If f.DataTabs.ActivePage.Controls[0].Align = alClient Then
       If (f.DataTabs.ActivePage.Controls[0].Width <> f.DataTabs.ActivePage.ClientWidth) Or
       (f.DataTabs.ActivePage.Controls[0].Height <> f.DataTabs.ActivePage.ClientHeight) Then
        Raise Exception.Create('Active tab content does not fill client area');
    End;
   CheckIdleLayout(f);
   b.SetSize(f.ClientWidth, f.ClientHeight);
   f.PaintTo(b.Canvas, 0, 0);
   PNG.Assign(b);
   PNG.SaveToFile(TPath.Combine(Root, 'native-preview.png'));

   System.Writeln('PASS: VCL DFM, native map/charts, parameter selection, synchronized timeline and inspector. PNG saved.');

  Finally
   f.Free;
   PNG.Free;
   b.Free;
  End;

  Config := TMemIniFile.Create(TPath.Combine(Root, 'settings.ini'));

  Try

   If (Config.ReadInteger('layout', 'map_height', 0) <> 320) Then
    Raise Exception.Create('Panel sizes not saved');

  Finally
   Config.Free;
  End;

 End;

Begin
 RunNativeTests(TVerifyUITests);
End.
