program VerifyUI;

{$APPTYPE CONSOLE}

uses Winapi.Windows,System.SysUtils,System.Classes,System.IOUtils,Vcl.ExtCtrls,System.UITypes,Vcl.Forms,Vcl.Grids,System.Types,Vcl.Graphics,Vcl.Imaging.pngimage,

  LocalizationU,frmReportU,FlightPlanU,frmChartsConfigureU,frmSettingsU,System.IniFiles,

  frmMainU in '..\src\forms\frmMainU.pas',FlightDatabaseU in '..\src\data\FlightDatabaseU.pas',FlightTelemetryU in '..\src\telemetry\FlightTelemetryU.pas',TelemetryCatalogU in '..\src\telemetry\TelemetryCatalogU.pas';

type TErrors=class procedure Error(Sender:TObject;E:Exception);end;

procedure TErrors.Error(Sender:TObject;E:Exception);begin Writeln('VCL ERROR: ',E.Message);Halt(1);end;

type TChartProbe=class
  Mode:Integer;Found:Boolean;Timer:TTimer;
  procedure Run(Sender:TObject);
end;
procedure TChartProbe.Run(Sender:TObject);
var I,J:Integer;D:TfrmChartsConfigure;
begin
 for J:=0 to Screen.FormCount-1 do if Screen.Forms[J] is TfrmChartsConfigure then begin
  Timer.Enabled:=False;Found:=True;D:=TfrmChartsConfigure(Screen.Forms[J]);
  if Mode=0 then begin
   if D.ParameterList.Count<200 then raise Exception.Create('Parameters missing in chart dialog');
   for I:=0 to D.ParameterList.Count-1 do begin
    D.ParameterList.ItemIndex:=I;D.ParameterList.Checked[I]:=I<32;D.ParameterCheck(D.ParameterList);
   end;
  end else if Mode=1 then begin
   D.ChartOrderList.ItemIndex:=1;D.MoveChart(D.btnMoveUp);
   if D.ChartOrderList.ItemIndex<>0 then raise Exception.Create('Chart reordering failed');
  end else begin
   D.ChartOrderList.ItemIndex:=0;D.HideChart(D.btnHide);D.ModalResult:=mrCancel;Exit;
  end;
  D.ModalResult:=mrOk;Exit;
 end;
end;

procedure CheckCachedReport(Main:TfrmMain;Landing:Boolean);
var I:Integer;Report:TfrmReport;Found:Boolean;Expected:string;
begin
 Found:=False;
 if Landing then begin Main.miLanding.Click;Expected:=Tr('Analiza lądowania');end
 else begin Main.miTakeoff.Click;Expected:=Tr('Analiza startu');end;
 for I:=Screen.FormCount-1 downto 0 do if Screen.Forms[I] is TfrmReport then begin
  Report:=TfrmReport(Screen.Forms[I]);Found:=True;
  if Report.Caption<>Expected then raise Exception.Create('Cached report title: '+Report.Caption);
  Report.Close;
 end;
 Application.ProcessMessages;
 if not Found then raise Exception.Create('Cached report action did not open report');
end;

var Handled:Boolean;Mouse:TPoint;BeforeSeconds,AfterSeconds:Integer;Settings:TfrmSettings;Config:TMemIniFile;Plan:TFlightPlan;DB:TFlightDatabase;S:TFlightSample;F:TfrmMain;Root:string;ID,I,J:Integer;B:TBitmap;PNG:TPngImage;Errors:TErrors;Probe:TChartProbe;OldRange:Integer;

procedure SetN(const Name:string;Value:Double);

var I:Integer;

begin for I:=0 to FieldCount-1 do if SimFields[I].Name=Name then begin S.Numbers[I]:=Value;Exit;end;raise Exception.Create('Missing field '+Name);end;

begin

  Application.Initialize;Errors:=TErrors.Create;Application.OnException:=Errors.Error;Root:=ExtractFilePath(ParamStr(0));Writeln('Creating fixture');DB:=TFlightDatabase.Create(TPath.Combine(Root,'flight_data.db'),TPath.Combine(Root,'sqlite3.dll'));S:=TFlightSample.Create;

  try

    for I:=0 to FieldCount-1 do if SimFields[I].Name='title' then S.Texts[I]:='Native VCL Test Flight';

    SetN('time_zulu.year',2026);SetN('time_zulu.month',10);SetN('time_zulu.day',12);SetN('time_local.year',2026);SetN('time_local.month',10);SetN('time_local.day',12);

    SetN('number_of_engines',2);SetN('eng_combustion[0]',1);SetN('eng_combustion[1]',1);SetN('plane_coordinate.latitude',52);SetN('plane_coordinate.longitude',20);ID:=DB.StartTrip(S);

    for J:=0 to 20 do begin SetN('time_zulu.seconds',J);SetN('time_local.seconds',J);SetN('plane_coordinate.latitude',52+J*0.005);SetN('plane_coordinate.longitude',20+J*0.01);SetN('plane_altitude',1000+J*50);SetN('vertical_speed',1000-J*50);SetN('turb_eng_n1[0]',45+J*2);DB.RecordSample(ID,S);end;DB.EndTrip(ID,S);
    DB.Contact(ID,S,False);DB.Contact(ID,S,True);
    DB.Connection.ExecSQL('update trip_liftoffs set analysis_report=:r where trip=:t',['# Cached takeoff',ID]);
    DB.Connection.ExecSQL('update trip_touchdowns set analysis_report=:r where trip=:t',['# Cached landing',ID]);

    Plan:=ParsePLN('<SimBase.Document><FlightPlan.FlightPlan><DepartureID>EPLL</DepartureID><DestinationID>EPLL</DestinationID>'+

      '<DepartureDetails><RunwayNumberFP>25</RunwayNumberFP><DepartureFP>ADOX2W</DepartureFP></DepartureDetails>'+

      '<ATCWaypoint id="TEST1"><WorldPosition>52.02,20.02,0</WorldPosition></ATCWaypoint>'+

      '<ATCWaypoint id="TEST2"><WorldPosition>52.09,20.18,0</WorldPosition></ATCWaypoint>'+

      '</FlightPlan.FlightPlan></SimBase.Document>','fixture.pln');

    try DB.SaveFlightPlan(ID,Plan);finally Plan.Free;end;

  finally S.Free;DB.Free;end;

  Config:=TMemIniFile.Create(TPath.Combine(Root,'ai-settings-test.ini'));

  Settings:=TfrmSettings.Create(nil);

  try

   Config.EraseSection('ai');

   ReadAnalysisWindow(Config,False,BeforeSeconds,AfterSeconds);

   if (BeforeSeconds<>60) or (AfterSeconds<>30) then raise Exception.Create('Takeoff defaults');

   ReadAnalysisWindow(Config,True,BeforeSeconds,AfterSeconds);

   if (BeforeSeconds<>180) or (AfterSeconds<>30) then raise Exception.Create('Landing defaults');

   Config.WriteInteger('ai','context_before_seconds',42);Config.WriteInteger('ai','context_after_seconds',17);

   ReadAnalysisWindow(Config,True,BeforeSeconds,AfterSeconds);

   if (BeforeSeconds<>42) or (AfterSeconds<>17) then raise Exception.Create('Legacy window fallback');

   Settings.Load(Config);Settings.seBefore.Value:=65;Settings.seAfter.Value:=25;Settings.seLandingBefore.Value:=240;Settings.seLandingAfter.Value:=45;

   Settings.cbProvider.ItemIndex:=1;Settings.eCodexModel.Text:='test-model';Settings.seTimeout.Value:=123;Settings.Save(Config);

   Settings.cbProvider.ItemIndex:=0;Settings.eCodexModel.Clear;Settings.Load(Config);

   ReadAnalysisWindow(Config,False,BeforeSeconds,AfterSeconds);

   if (BeforeSeconds<>65) or (AfterSeconds<>25) then raise Exception.Create('Independent takeoff window');

   ReadAnalysisWindow(Config,True,BeforeSeconds,AfterSeconds);

   if (BeforeSeconds<>240) or (AfterSeconds<>45) or (Settings.seLandingBefore.Value<>240) or (Settings.seLandingAfter.Value<>45) then raise Exception.Create('Landing window persistence');

   Config.WriteInteger('ai','landing_before_seconds',999);Config.WriteInteger('ai','landing_after_seconds',-1);

   ReadAnalysisWindow(Config,True,BeforeSeconds,AfterSeconds);

   if (BeforeSeconds<>300) or (AfterSeconds<>1) then raise Exception.Create('Window limits');

   if (Settings.cbProvider.ItemIndex<>1) or (Settings.eCodexModel.Text<>'test-model') or (Settings.seTimeout.Value<>123) then raise Exception.Create('AI settings roundtrip failed');

  finally Settings.Free;Config.Free;end;

  Writeln('Creating VCL form');F:=TfrmMain.Create(nil);B:=TBitmap.Create;PNG:=TPngImage.Create;Writeln('Showing test form');

  try

    F.Timer.Enabled:=False;F.aTiles.Checked:=False;F.aTilesExecute(F.aTiles);F.Position:=poDesigned;F.Left:=-4000;F.Top:=0;F.Show;Application.ProcessMessages;F.SelectTrip(F);F.aFit.Execute;Application.ProcessMessages;

    CheckCachedReport(F,False);CheckCachedReport(F,True);
    if not Assigned(F.HistoryGrid.OnDblClick) then raise Exception.Create('History double-click missing');

    if F.SimBriefPage.PageIndex<>F.PlanPage.PageIndex+1 then raise Exception.Create('SimBrief tab must follow flight plan');

    if F.SimBriefPage.ControlCount<>1 then raise Exception.Create('SimBrief frame missing');

    F.HistoryGrid.OnDblClick(F.HistoryGrid);

    if not F.HistoryGrid.ReadOnly or not F.EventGrid.ReadOnly or not F.ContactGrid.ReadOnly or (goEditing in F.DataGrid.Options) then raise Exception.Create('Grid editing enabled');

    Probe:=TChartProbe.Create;Probe.Timer:=TTimer.Create(nil);
    try
     Probe.Mode:=0;Probe.Timer.Interval:=20;Probe.Timer.OnTimer:=Probe.Run;Probe.Timer.Enabled:=True;
     F.aChartsConfigure.Execute;Application.ProcessMessages;
     if not Probe.Found then raise Exception.Create('Chart action did not open configuration');
    finally Probe.Timer.Free;Probe.Free;end;

    if F.ChartsHost.VertScrollBar.Range<32*155 then raise Exception.Create('More than 8 charts unavailable');

    Mouse:=F.ChartsHost.ClientToScreen(Point(20,20));Handled:=False;

    F.ChartsWheel(F,[],-120,Mouse,Handled);

    if not Handled or (F.ChartsHost.VertScrollBar.Position=0) then raise Exception.Create('Chart wheel failed');

    if F.SplitMap.Top<F.MapPanel.Top+F.MapPanel.Height-2 then raise Exception.Create('Map splitter is above map');

    F.MapPanel.Height:=320;F.LeftPanel.Width:=280;F.RightPanel.Width:=320;

    if F.DataGrid.RowCount<200 then raise Exception.Create('Native data inspector missing telemetry');


    if not Assigned(F.btnLandingAnalysis) or not Assigned(F.btnOverview) then raise Exception.Create('DFM actions missing');

    Probe:=TChartProbe.Create;Probe.Timer:=TTimer.Create(nil);
    try
     Probe.Mode:=1;Probe.Timer.Interval:=20;Probe.Timer.OnTimer:=Probe.Run;Probe.Timer.Enabled:=True;
     F.aChartsConfigure.Execute;
     if not Probe.Found then raise Exception.Create('Reorder dialog not opened');
     OldRange:=F.ChartsHost.VertScrollBar.Range;
     Probe.Mode:=2;Probe.Found:=False;Probe.Timer.Enabled:=True;F.aChartsConfigure.Execute;
     if not Probe.Found or (F.ChartsHost.VertScrollBar.Range<>OldRange) then raise Exception.Create('Cancel changed active charts');
    finally Probe.Timer.Free;Probe.Free;end;

    F.aZoomIn.Execute;if not F.ViewPan.Enabled then raise Exception.Create('Zoom did not enable pan');

    F.ViewPan.Position:=1000;F.PanChart(F);

    F.aFullView.Execute;if F.ViewPan.Enabled then raise Exception.Create('Full view did not reset pan');

    F.Timeline.Position:=10;F.TimelineChange(F);if Pos('00:00:10',F.CursorLabel.Caption)=0 then raise Exception.Create('Native timeline not synchronized');

    if Pos('EPLL.25 ADOX2W',F.mPlan.Text)=0 then raise Exception.Create('Saved flight plan missing from UI');

    F.DataTabs.ActivePage:=F.PlanPage;Application.ProcessMessages;

    B.SetSize(F.ClientWidth,F.ClientHeight);F.PaintTo(B.Canvas,0,0);PNG.Assign(B);PNG.SaveToFile(TPath.Combine(Root,'native-preview.png'));

    Writeln('PASS: VCL DFM, native map/charts, parameter selection, synchronized timeline and inspector. PNG saved.');

  finally F.Free;PNG.Free;B.Free;end;

  Config:=TMemIniFile.Create(TPath.Combine(Root,'settings.ini'));

  try

   if (Config.ReadInteger('layout','map_height',0)<>320) then raise Exception.Create('Panel sizes not saved');

  finally Config.Free;end;

end.

