Program VerifyDetachedViews;
{$APPTYPE CONSOLE}

Uses
 System.SysUtils, System.Classes, System.IOUtils, System.Types,
 System.Generics.Collections, Vcl.Forms, Vcl.Controls, Vcl.ExtCtrls,
 frmMainU, frmChartsConfigureU, FlightDatabaseU, FlightTelemetryU,
 TelemetryCatalogU, LocalizationU, FlightChartsU, fraGraphU, fraMapU;

Procedure Check(Value : Boolean; Const MessageText : String);
 Begin
  If Not Value Then Raise Exception.Create(MessageText);
 End;

Type
 TModalProbe = Class
  Seen : Boolean;
  Procedure Tick(Sender : TObject);
 End;

Procedure TModalProbe.Tick(Sender : TObject);
 Var I : Integer; Dialog : TfrmChartsConfigure;
 Begin
  For I := 0 To Screen.FormCount - 1 Do
   If Screen.Forms[I] Is TfrmChartsConfigure Then
    Begin
     TTimer(Sender).Enabled := False;
     Dialog := TfrmChartsConfigure(Screen.Forms[I]);
     Check(Dialog.ImageList.Count = 6, 'Detached configuration icons');
     Seen := True;
     Dialog.aCancel.Execute;
     Exit;
    End;
 End;

Var
 Probe : TModalProbe;
 ProbeTimer : TTimer;
 DB : TFlightDatabase;
 Sample : TFlightSample;
 Main : TfrmMain;
 Root, RangeCaption : String;
 IDs : Array[0..1] Of Integer;
 I, J, K : Integer;
 MapIdentity, GraphIdentity : TObject;
 Chart : TFlightCharts;
 Graph : TfraGraph;
 Map : TfraMap;
 StartTime, EndTime, MapHeight : Double;
 Handled : Boolean;
 Mouse : TPoint;
 Indices : TList<Integer>;

Procedure SetN(Const Name : String; Value : Double);
 Var Index : Integer;
 Begin
  For Index := 0 To FieldCount - 1 Do
   If SimFields[Index].Name = Name Then
    Begin
     Sample.Numbers[Index] := Value;
     Exit;
    End;
  Raise Exception.Create('Missing field ' + Name);
 End;

Begin
 Try
  Application.Initialize;
  Root := ExtractFilePath(ParamStr(0));
  DB := TFlightDatabase.Create(TPath.Combine(Root, 'flight_data.db'), TPath.Combine(Root, 'sqlite3.dll'));
  Sample := TFlightSample.Create;
  Try
   SetN('time_zulu.year', 2026); SetN('time_zulu.month', 10); SetN('time_zulu.day', 18);
   SetN('time_local.year', 2026); SetN('time_local.month', 10); SetN('time_local.day', 18);
   SetN('number_of_engines', 2);
   For I := 0 To 1 Do
    Begin
     SetN('time_zulu.seconds', 0); SetN('time_local.seconds', 0);
     For K := 0 To FieldCount - 1 Do If SimFields[K].Name = 'title' Then Sample.Texts[K] := 'Detached views ' + IntToStr(I);
     IDs[I] := DB.StartTrip(Sample);
     For J := 0 To 20 Do
      Begin
       SetN('time_zulu.seconds', J * (I + 1)); SetN('time_local.seconds', J * (I + 1));
       SetN('plane_coordinate.latitude', 52 + J * 0.001);
       SetN('plane_coordinate.longitude', 20 + J * 0.001);
       SetN('plane_altitude', 1000 + J * 10);
       DB.RecordSample(IDs[I], Sample);
      End;
     DB.EndTrip(IDs[I], Sample);
    End;
  Finally Sample.Free; DB.Free; End;
  Main := TfrmMain.Create(Nil);
  Graph := Main.GraphFrame;
  Map := Main.MapFrame;
  Try
   Main.Timer.Enabled := False;
   Main.aTiles.Checked := False; Main.aTilesExecute(Main.aTiles);
   Main.Position := poDesigned; Main.Left := -4000; Main.Top := 0; Main.Show;
   Main.HistoryGrid.DataSource.DataSet.Locate('id', IDs[0], []); Main.SelectTrip(Main);
   Application.ProcessMessages;
   Check(Map.Actions.Owner = Map, 'Map action list ownership');
   Check(Graph.Actions.Owner = Graph, 'Chart action list ownership');
   Check(Map.ImageList.Owner = Map, 'Map image list ownership');
   Check(Graph.ImageList.Owner = Graph, 'Chart image list ownership');
   Check(Map.ToolBar6.Images = Map.ImageList, 'Local map images');
   Check(Graph.ToolBar2.Images = Graph.ImageList, 'Local chart images');
   Check(Main.miMapWindow.Action = Map.aMapWindow, 'Map menu shares frame action');
   Check(Main.miGraphWindow.Action = Graph.aGraphWindow, 'Chart menu shares frame action');
   MapIdentity := Map.Map;
   GraphIdentity := Graph.Charts;
   Graph.Charts.SetView(3, 12);
   StartTime := Graph.Charts.ViewStart; EndTime := Graph.Charts.ViewEnd;
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
   Main.Timeline.Position := 7; Main.TimelineChange(Main.Timeline);
   Check(Pos('00:00:07', Main.CursorLabel.Caption) > 0, 'Main timeline stopped updating');
   Indices := TList<Integer>.Create;
   Try
    For J := 0 To 15 Do Indices.Add(J);
    Graph.Charts.Select(Indices);
   Finally Indices.Free; End;
   Application.ProcessMessages;
   Mouse := Main.ChartsHost.ClientToScreen(Point(10, 10)); Handled := False;
   Main.ChartsWheel(Main, [], -120, Mouse, Handled);
   Check(Not Handled, 'Main window must not consume detached wheel events');
   Graph.Wheel(Graph, [], -120, Mouse, Handled);
   Check(Handled And (Main.ChartsHost.VertScrollBar.Position > 0), 'Detached wheel scrolling');
   Handled := False; Graph.Wheel(Graph, [ssCtrl], 120, Mouse, Handled);
   Check(Handled And (Graph.Charts.ViewEnd - Graph.Charts.ViewStart < EndTime - StartTime), 'Detached wheel zoom');
   Probe := TModalProbe.Create; ProbeTimer := TTimer.Create(Nil);
   Try
    ProbeTimer.Interval := 20; ProbeTimer.OnTimer := Probe.Tick; ProbeTimer.Enabled := True;
    Graph.btnChartsConfigure.Click;
    Check(Probe.Seen, 'Detached configuration button is not wired');
   Finally ProbeTimer.Free; Probe.Free; End;
   RangeCaption := Graph.lView.Caption;
   SetLanguage('de-DE'); Check(Main.MapWindow.Caption = 'Flugkarte', 'Detached map language');
   Check(Main.GraphWindow.Caption = 'Flugdiagramme', 'Detached chart language');
   Check(Graph.lView.Caption = RangeCaption, 'Language change lost the viewport label'); SetLanguage('pl-PL');
   Main.HistoryGrid.DataSource.DataSet.Locate('id', IDs[1], []); Main.SelectTrip(Main);
   Check(Graph.Charts.ViewEnd > 30, 'Trip change did not reach detached graph');
   Map.btnMapWindow.Click; Application.ProcessMessages;
   Check((Main.MapWindow = Nil) And Main.MapPanel.Visible And Not Main.aMapWindow.Checked, 'Map close did not return frame');
   Check(Map.Parent = Main.MapPanel, 'Map parent not restored');
   Check(Main.MapPanel.Align = alClient, 'Map does not fill space while graph detached');
   Graph.btnGraphWindow.Click; Application.ProcessMessages;
   Check((Main.GraphWindow = Nil) And Main.GraphPanel.Visible, 'Graph action did not dock');
   Check((Main.MapPanel.Align = alTop) And (Main.MapPanel.Height = Round(MapHeight)) And Main.SplitMap.Visible, 'Docked layout lost');
   Check((MapIdentity = Map.Map) And (GraphIdentity = Graph.Charts), 'Return recreated controls');
   For J := 0 To 2 Do Begin Main.aMapWindow.Execute; Main.aMapWindow.Execute; Application.ProcessMessages; End;
   Main.aMapWindow.Execute; Main.aGraphWindow.Execute;
   Main.GraphWindow.Close; Application.ProcessMessages;
   Check(Main.GraphPanel.Visible And Not Main.MapPanel.Visible And Not Main.SplitMap.Visible, 'Graph-first close layout');
   Main.MapWindow.Close; Application.ProcessMessages;
   Check(Main.MapPanel.Visible And Main.SplitMap.Visible And (Main.MapPanel.Height = Round(MapHeight)), 'Graph-first return lost map height');
   Main.aMapWindow.Execute; Main.aGraphWindow.Execute;
   // Destruction must return the frames before their parent windows are freed.
  Finally Main.Free; End;
  Application.ProcessMessages;
  Writeln('PASS: same map/chart frames, independent detach/dock/close, both views detached, viewport/cursor/trip synchronization, wheel/zoom, language changes, layout restoration, repeated toggles and main-window shutdown. Synthetic only.');
 Except
  On E : Exception Do Begin Writeln('FAIL: ', E.ClassName, ': ', E.Message); Halt(1); End;
 End;
End.
