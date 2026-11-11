Program VerifyDetachedViews;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU In 'TestPathsU.pas', DUnitX.TestFramework, NativeTestRunnerU In 'NativeTestRunnerU.pas',
 System.SysUtils, System.Classes, System.IOUtils, System.Types,
 System.Generics.Collections, Vcl.ImgList, Vcl.Graphics, Vcl.Forms, Vcl.Controls, Vcl.ExtCtrls,
 frmMainU In '..\src\Forms\frmMainU.pas', frmChartsConfigureU In '..\src\Forms\frmChartsConfigureU.pas', FlightDatabaseU In '..\src\Data\FlightDatabaseU.pas', FlightTelemetryU In '..\src\Telemetry\FlightTelemetryU.pas',
 TelemetryCatalogU In '..\src\Telemetry\TelemetryCatalogU.pas', LocalizationU In '..\src\i18n\LocalizationU.pas', FlightChartsU In '..\src\Visualization\FlightChartsU.pas', fraGraphU In '..\src\Frames\fraGraphU.pas', fraMapU In '..\src\Frames\fraMapU.pas', fraSixPackU In '..\src\Frames\fraSixPackU.pas', SixPackU In '..\src\Visualization\SixPackU.pas', fraEnginesU In '..\src\Frames\fraEnginesU.pas', EngineGaugesU In '..\src\Visualization\EngineGaugesU.pas';

Procedure Check(Value : Boolean; Const MessageText : String);
 Begin
  If Not Value Then
   Raise Exception.Create(MessageText);
 End;

Type
 TModalProbe = Class
  Seen : Boolean;
  Procedure Tick(Sender : TObject);
 End;

Procedure TModalProbe.Tick(Sender : TObject);
 Var
  i      : Integer;
  Dialog : TfrmChartsConfigure;
 Begin
  For i := 0 To Screen.FormCount - 1 Do
   If Screen.Forms[i] Is TfrmChartsConfigure Then
    Begin
     TTimer(Sender).Enabled := False;
     Dialog                 := TfrmChartsConfigure(Screen.Forms[i]);
     Check(Dialog.ImageList.Count = 6, 'Detached configuration icons');
     Seen := True;
     Dialog.aCancel.Execute;
     Exit;
    End;
 End;

Var
 Probe         : TModalProbe;
 ProbeTimer    : TTimer;
 DB            : TFlightDatabase;
 Sample        : TFlightSample;
 Main          : TfrmMain;
 Root          : String;
 RangeCaption  : String;
 IDs           : Array [0..1] Of Integer;
 i             : Integer;
 j             : Integer;
 k             : Integer;
 MapIdentity   : TObject;
 GraphIdentity : TObject;
 Chart         : TFlightCharts;
 Graph         : TfraGraph;
 Map           : TfraMap;
 StartTime     : Double;
 EndTime       : Double;
 MapHeight     : Double;
 Handled       : Boolean;
 Mouse         : TPoint;
 Indices       : TList<Integer>;

Procedure SetN(Const Name : String; Value : Double);
 Var
  Index : Integer;
 Begin
  For Index := 0 To FieldCount - 1 Do
   If SimFields[Index].Name = Name Then
    Begin
     Sample.Numbers[Index] := Value;
     Exit;
    End;
  Raise Exception.Create('Missing field ' + Name);
 End;

Procedure VerifyEnginesDetach(Main : TfrmMain);
 Var
  Frame : TfraEngines;
 Begin
  Frame := Main.EnginesFrame;
  Frame.btnWindow.Click;
  Check((Main.EnginesWindow <> Nil) And (Frame.Parent = Main.EnginesWindow), 'Engine same frame detached');
  Main.Timeline.Position := 10;
  Main.TimelineChange(Main.Timeline);
  Check(Frame.Display.Time = Main.CursorLabel.Caption, 'Engine timeline synchronization');
  Frame.btnWindow.Click;
  Application.ProcessMessages;
  Check(Main.EnginesWindow = Nil, 'Engine button returns');
  Frame.btnWindow.Click;
  Main.EnginesWindow.Close;
  Application.ProcessMessages;
  Check(Main.EnginesWindow = Nil, 'Engine Close returns');
 End;

Procedure VerifyAlpha(Images : TCustomImageList);
 Var
  b : TBitmap;
  i : Integer;
 Begin
  b := TBitmap.Create;
  Try
   b.SetSize(Images.Width, Images.Height);
   For i := 0 To 1 Do
    Begin
     b.Canvas.Brush.Color := clWhite;
     b.Canvas.FillRect(Rect(0, 0, b.Width, b.Height));
     Images.Draw(b.Canvas, 0, 0, i);
     Check(ColorToRGB(b.Canvas.Pixels[0, 0]) = ColorToRGB(clWhite), 'Icon alpha on white background');
     b.Canvas.Brush.Color := clBlack;
     b.Canvas.FillRect(Rect(0, 0, b.Width, b.Height));
     Images.Draw(b.Canvas, 0, 0, i);
     Check(ColorToRGB(b.Canvas.Pixels[0, 0]) = ColorToRGB(clBlack), 'Icon alpha on black background');
    End;
  Finally
   b.Free;
  End;
 End;

Procedure VerifySixPackDetach(Main : TfrmMain);
 Var
  Frame : TfraSixPack;
  State : TSixPackState;
 Begin
  Check(Not Main.SixPackFrame.ShowEmbeddedEngines And (Main.SixPackFrame.Display.Height > 80), 'New short panel reserves height for instruments, not duplicate engines');
  VerifyAlpha(Main.PFD737Frame.ImageList1);
  VerifyAlpha(Main.SixPackFrame.ImageList1);
  VerifyAlpha(Main.EnginesFrame.ImageList1);
  VerifyAlpha(Main.FMCFrame.ImageList1);
  VerifyAlpha(Main.MapFrame.ImageList);
  VerifyAlpha(Main.GraphFrame.ImageList);
  VerifyAlpha(Main.SimBriefFrame.ImageList);
  Frame := Main.SixPackFrame;
  Check(Frame.aWindow.ImageIndex = 0, 'Docked icon');
  Frame.btnWindow.Click;
  Check((Frame.aWindow.ImageIndex = 1) And Not Main.SixPackPanel.Visible, 'Detached icon and hidden six-pack panel');
  Main.EnginesFrame.btnWindow.Click;
  Check((Main.EnginesFrame.aWindow.ImageIndex = 1) And Not Main.InstrumentsPanel.Visible And Not Main.SplitterInstruments.Visible, 'Both detached hide instrument container/splitter');
  Main.EnginesWindow.Close;
  Application.ProcessMessages;
  Check((Main.EnginesFrame.aWindow.ImageIndex = 0) And Main.EnginePanel.Visible And Main.InstrumentsPanel.Visible, 'Engine Close restores icon and panel');
  Check((Main.SixPackWindow <> Nil) And (Frame.Parent = Main.SixPackWindow), 'Six-pack same instance detached');
  Main.Timeline.Position := 10;
  Main.TimelineChange(Main.Timeline);
  State := Frame.Display.State;
  Check(Not Main.PFD737Frame.Visible, 'B38M PFD is hidden for a generic recording');
  Check(State.Altitude = 0, 'Six-pack uses indicated altitude');
  Check(State.Time = Main.CursorLabel.Caption, 'Six-pack timeline synchronization');
  Frame.btnWindow.Click;
  Application.ProcessMessages;
  Check(Main.SixPackWindow = Nil, 'Six-pack button docks back');
  Frame.btnWindow.Click;
  Main.SixPackWindow.Close;
  Application.ProcessMessages;
  Check(Main.SixPackWindow = Nil, 'Six-pack Close docks back');
  Check((Frame.aWindow.ImageIndex = 0) And Main.SixPackPanel.Visible And Main.SplitterSixPackEngines.Visible, 'Six-pack Close restores icon and splitter');
 End;

Type

 [TestFixture]
 TVerifyDetachedViewsTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyDetachedViewsTests.Regression;
 Begin
  Try
   Application.Initialize;
   Root   := TestDataDirectory;
   DB     := TFlightDatabase.Create(TestDatabasePath(TPath.Combine(Root, 'flight_data.db')), TPath.Combine(Root, 'sqlite3.dll'));
   Sample := TFlightSample.Create;
   Try
    SetN('time_zulu.year', 2026);
    SetN('time_zulu.month', 10);
    SetN('time_zulu.day', 18);
    SetN('time_local.year', 2026);
    SetN('time_local.month', 10);
    SetN('time_local.day', 18);
    SetN('number_of_engines', 2);
    For i := 0 To 1 Do
     Begin
      SetN('time_zulu.seconds', 0);
      SetN('time_local.seconds', 0);
      For k := 0 To FieldCount - 1 Do
       If SimFields[k].Name = 'title' Then
        Sample.Texts[k] := 'Detached views ' + IntToStr(i);
      IDs[i]            := DB.StartTrip(Sample);
      For j             := 0 To 20 Do
       Begin
        SetN('time_zulu.seconds', j * (i + 1));
        SetN('time_local.seconds', j * (i + 1));
        SetN('plane_coordinate.latitude', 52 + j * 0.001);
        SetN('plane_coordinate.longitude', 20 + j * 0.001);
        SetN('plane_altitude', 1000 + j * 10);
        DB.RecordSample(IDs[i], Sample);
       End;
      DB.EndTrip(IDs[i], Sample);
      SetN('time_zulu.seconds', 0);
      DB.Connection.ExecSQL('insert into trip_fmc_screens(trip,sample,time_zulu,captured_utc,provider,device,page_key,title,available,powered,raw_text,parsed_json) ' + 'values(:t,1,:z,:z,''iFly737MAX'',''0'',''test'',''TEST'',1,1,:raw,''{}'')', [IDs[i], Sample.Time('time_zulu'), 'TRIP ' + IntToStr(i)]);
     End;
   Finally
    Sample.Free;
    DB.Free;
   End;
   Main  := TfrmMain.Create(Nil);
   Graph := Main.GraphFrame;
   Map   := Main.MapFrame;
   Try
    Main.Timer.Enabled  := False;
    Main.aTiles.Checked := False;
    Main.aTilesExecute(Main.aTiles);
    Main.Position := poDesigned;
    Main.Left     := -4000;
    Main.Top      := 0;
    Main.Show;
    Main.SelectRecording(IDs[0]);
    Main.SelectTrip(Main);
    Application.ProcessMessages;
    Check(Main.FMCFrame.Current <> Nil, 'Main timeline initializes FMC');
    Check(Main.FMCFrame.Current.Screen.Lines[0] = 'TRIP 0', 'Initial FMC trip');
    Main.FMCFrame.btnWindow.Click;
    Check((Main.FMCWindow <> Nil) And (Main.FMCWindow.BorderStyle = bsDialog), 'FMC detach action');
    Check(Main.FMCFrame.Parent = Main.FMCWindow, 'Main FMC frame reparented');
    Main.Timeline.Position := 7;
    Main.TimelineChange(Main.Timeline);
    Check(Main.FMCFrame.Current.Screen.Lines[0] = 'TRIP 0', 'Detached FMC timeline');
    Main.FMCFrame.btnWindow.Click;
    Application.ProcessMessages;
    Check(Main.FMCWindow = Nil, 'FMC button docks back');
    Main.FMCFrame.btnWindow.Click;
    Main.FMCWindow.Close;
    Application.ProcessMessages;
    Check(Main.FMCWindow = Nil, 'FMC close docks back');
    Main.FMCFrame.btnWindow.Click;
    VerifySixPackDetach(Main);
    VerifyEnginesDetach(Main);
    Check(Map.Actions.Owner = Map, 'Map action list ownership');
    Check(Graph.Actions.Owner = Graph, 'Chart action list ownership');
    Check(Map.ImageList.Owner = Map, 'Map image list ownership');
    Check(Graph.ImageList.Owner = Graph, 'Chart image list ownership');
    Check(Map.ToolBar6.Images = Map.ImageList, 'Local map images');
    Check(Graph.ToolBar2.Images = Graph.ImageList, 'Local chart images');
    Check(Main.miMapWindow.Action = Map.aMapWindow, 'Map menu shares frame action');
    Check(Main.miGraphWindow.Action = Graph.aGraphWindow, 'Chart menu shares frame action');
    MapIdentity   := Map.Map;
    GraphIdentity := Graph.Charts;
    Graph.Charts.SetView(3, 12);
    StartTime := Graph.Charts.ViewStart;
    EndTime   := Graph.Charts.ViewEnd;
    MapHeight := Main.MapPanel.Height;
    Main.aMapWindow.Execute;
    Main.MapWindow.Left := -4000;
    Check((Map.Parent = Main.MapWindow) And Not Main.MapPanel.Visible, 'Map not detached');
    Check(Main.aMapWindow.Checked And Not Main.SplitMap.Visible, 'Map action/splitter state');
    Check(Graph.Parent = Main.GraphPanel, 'Graph unexpectedly detached');
    Main.aGraphWindow.Execute;
    Main.GraphWindow.Left := -4000;
    Graph.btnZoomIn.Click;
    Check(Graph.Charts.ViewEnd - Graph.Charts.ViewStart < EndTime - StartTime, 'Detached zoom action');
    Graph.Charts.SetView(StartTime, EndTime);
    Check((Graph.Parent = Main.GraphWindow) And Not Main.GraphPanel.Visible, 'Graph not detached');
    Check((MapIdentity = Map.Map) And (GraphIdentity = Graph.Charts), 'Controls were recreated');
    Check((Graph.Charts.ViewStart = StartTime) And (Graph.Charts.ViewEnd = EndTime), 'Detach lost viewport');
    // Delphi 10.2 Win64 emits an invalid temporary for a repeated nested property in this event call.
    Chart := Graph.Charts;
    Chart.OnCursor(Chart, 4);
    Check(Main.Timeline.Position = 4, 'Detached cursor not synchronized');
    Main.Timeline.Position := 7;
    Main.TimelineChange(Main.Timeline);
    Check(Pos('00:00:07', Main.CursorLabel.Caption) > 0, 'Main timeline stopped updating');
    Indices := TList<Integer>.Create;
    Try
     For j := 0 To 15 Do
      Indices.Add(j);
     Graph.Charts.Select(Indices);
    Finally
     Indices.Free;
    End;
    Application.ProcessMessages;
    Mouse   := Main.ChartsHost.ClientToScreen(Point(10, 10));
    Handled := False;
    Main.ChartsWheel(Main, [], -120, Mouse, Handled);
    Check(Not Handled, 'Main window must not consume detached wheel events');
    Graph.Wheel(Graph, [], -120, Mouse, Handled);
    Check(Handled And (Main.ChartsHost.VertScrollBar.Position > 0), 'Detached wheel scrolling');
    Handled := False;
    Graph.Wheel(Graph, [ssCtrl], 120, Mouse, Handled);
    Check(Handled And (Graph.Charts.ViewEnd - Graph.Charts.ViewStart < EndTime - StartTime), 'Detached wheel zoom');
    Probe      := TModalProbe.Create;
    ProbeTimer := TTimer.Create(Nil);
    Try
     ProbeTimer.Interval := 20;
     ProbeTimer.OnTimer  := Probe.Tick;
     ProbeTimer.Enabled  := True;
     Graph.btnChartsConfigure.Click;
     Check(Probe.Seen, 'Detached configuration button is not wired');
    Finally
     ProbeTimer.Free;
     Probe.Free;
    End;
    RangeCaption := Graph.lView.Caption;
    SetLanguage('de-DE');
    Check(Main.MapWindow.Caption = 'Flugkarte', 'Detached map language');
    Check(Main.GraphWindow.Caption = 'Flugdiagramme', 'Detached chart language');
    Check(Graph.lView.Caption = RangeCaption, 'Language change lost the viewport label');
    SetLanguage('pl-PL');
    Main.SelectRecording(IDs[1]);
    Main.SelectTrip(Main);
    Check(Main.FMCFrame.Current.Screen.Lines[0] = 'TRIP 1', 'Detached FMC follows trip switch');
    Check(Graph.Charts.ViewEnd > 30, 'Trip change did not reach detached graph');
    Map.btnMapWindow.Click;
    Application.ProcessMessages;
    Check((Main.MapWindow = Nil) And Main.MapPanel.Visible And Not Main.aMapWindow.Checked, 'Map close did not return frame');
    Check(Map.Parent = Main.MapPanel, 'Map parent not restored');
    Check(Main.MapPanel.Align = alClient, 'Map does not fill space while graph detached');
    Graph.btnGraphWindow.Click;
    Application.ProcessMessages;
    Check((Main.GraphWindow = Nil) And Main.GraphPanel.Visible, 'Graph action did not dock');
    Check((Main.MapPanel.Align = alTop) And (Main.MapPanel.Height = Round(MapHeight)) And Main.SplitMap.Visible, 'Docked layout lost');
    Check((MapIdentity = Map.Map) And (GraphIdentity = Graph.Charts), 'Return recreated controls');
    For j := 0 To 2 Do
     Begin
      Main.aMapWindow.Execute;
      Main.aMapWindow.Execute;
      Application.ProcessMessages;
     End;
    Main.aMapWindow.Execute;
    Main.aGraphWindow.Execute;
    Main.GraphWindow.Close;
    Application.ProcessMessages;
    Check(Main.GraphPanel.Visible And Not Main.MapPanel.Visible And Not Main.SplitMap.Visible, 'Graph-first close layout');
    Main.MapWindow.Close;
    Application.ProcessMessages;
    Check(Main.MapPanel.Visible And Main.SplitMap.Visible And (Main.MapPanel.Height = Round(MapHeight)), 'Graph-first return lost map height');
    Main.aMapWindow.Execute;
    Main.aGraphWindow.Execute;
    // Destruction must return the frames before their parent windows are freed.
   Finally
    Main.Free;
   End;
   Application.ProcessMessages;
   System.Writeln('PASS: same map/chart/FMC frames, independent detach/dock/close, both views detached, viewport/cursor/trip synchronization, wheel/zoom, language changes, layout restoration, repeated toggles and main-window shutdown. Synthetic only.');
  Except
   On E : Exception Do
    Begin
     System.Writeln('FAIL: ', E.ClassName, ': ', E.Message);
     Raise Exception.Create('Regression failed; see diagnostic above');
    End;
  End;

 End;

Begin
 RunNativeTests(TVerifyDetachedViewsTests);
End.
