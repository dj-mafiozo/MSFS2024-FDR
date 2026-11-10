{$StackFrames On}
Unit FlightRecorderU;

Interface

 Uses
  NativeATCU, Winapi.Windows, System.SysUtils, System.IOUtils, System.Classes, System.DateUtils, System.Math,
  LocalizationU, FlightDatabaseU, FlightTelemetryU, SimConnectClientU, EventFilterU, FacilitiesU,
  AppLogU, ProcedureRouteU, FlightPlanU, RouteBridgeU, MetarU, AircraftTelemetryU, FMCPreflightU, FSHudDataU;

 Type
  TFlightRecorder = Class
   Private
    fProviders      : TAircraftProviders;
    fFSHud          : TFSHudData;
    fNativeATC      : TMSFSATC;
    fPreflight      : TFMCPreflightCache;
    fPreflightTitle : String;
    fPreflightNext  : UInt64;
    fDB             : TFlightDatabase;
    fFilter         : TEventFilter;
    fFacilities     : TFacilityReader;
    fProcedures     : TProcedureReader;
    fMetar          : TMetarService;
    fNext           : UInt64;
    fSamples        : Integer;
    fPlan           : TFlightPlan;
    fBridge         : TRouteBridge;
    fPlanNext       : UInt64;
    fWasGround      : Boolean;
    fTitle          : String;
    Procedure FacilityPacket(p : Pointer; Size : DWORD);
    Procedure ProceduresUpdated(Sender : TObject);
    Procedure SampleReceived(Sender : TObject; s : TFlightSample);
    Procedure Cockpit(Sender : TObject; Const Name : String);
    Procedure Commit(Const Name : String; Const o : TOccurrence; Seq : Int64);
    Procedure Retract(Seq : Int64);
   Public
    Sim        : TSimConnectClient;
    Trip       : Integer;
    Enabled    : Boolean;
    IntervalMS : Integer;
    Status     : String;
    Constructor Create(DB : TFlightDatabase);
    Destructor Destroy; Override;
    Procedure RequestHistoricalMetar(TripID : Integer);
    Procedure EnableRouteBridge(Port : Word);
    Procedure SetFlightPlan(Plan : TFlightPlan);
    Procedure LoadPlanFile(Const Path : String);
    Function PlanSummary : String;
    Procedure Tick;
    Procedure Stop;
    Procedure Start;
  End;

Implementation

 Constructor TFlightRecorder.Create(DB : TFlightDatabase);
  Var
   Seq : Int64;
  Begin
   Inherited Create;
   fDB                   := DB;
   fFSHud                := TFSHudData.Create({$IFDEF PORT_TEST}False{$ELSE}True{$ENDIF});
   fProviders            := TAircraftProviders.Create;
   fPreflight            := TFMCPreflightCache.Create;
   Sim                   := TSimConnectClient.Create;
   fNativeATC            := TMSFSATC.Create(Sim, fDB);
   Sim.OnSample          := SampleReceived;
   Sim.OnCockpit         := Cockpit;
   Seq                   := fDB.Connection.ExecSQLScalar('select coalesce(max(event_seq),0) from trip_events');
   fFilter               := TEventFilter.Create(Seq);
   fFilter.OnCommit      := Commit;
   fFilter.OnRetract     := Retract;
   fFacilities           := TFacilityReader.Create(Sim, fDB);
   fProcedures           := TProcedureReader.Create(Sim);
   fProcedures.OnUpdated := ProceduresUpdated;
   Sim.OnPacket          := FacilityPacket;
   fMetar                := TMetarService.Create(fDB);
   IntervalMS            := 500;
   Enabled               := True;
   Status                := Tr('Oczekiwanie na MSFS');
  End;

 Destructor TFlightRecorder.Destroy;
  Begin
   Stop;
   fNativeATC.Free;
   fFSHud.Free;
   fMetar.Free;
   fBridge.Free;
   fProcedures.Free;
   fPlan.Free;
   fFacilities.Free;
   Sim.Free;
   fProviders.Free;
   fPreflight.Free;
   fFilter.Free;
   Inherited;
  End;

 Procedure TFlightRecorder.FacilityPacket(p : Pointer; Size : DWORD);
  Begin
   fNativeATC.Feed(p, Size);
   fFacilities.Feed(p, Size);
   fProcedures.Feed(p, Size);
  End;

 Procedure TFlightRecorder.ProceduresUpdated(Sender : TObject);
  Begin
   If (Trip > 0) And (fPlan <> Nil) Then
    fDB.SaveFlightPlan(Trip, fPlan);
  End;

 Procedure TFlightRecorder.Commit(Const Name : String; Const o : TOccurrence; Seq : Int64);
  Begin
   If o.Trip > 0 Then
    fDB.Event(o.Trip, Name, o.Zulu, o.Local, Seq);
  End;

 Procedure TFlightRecorder.Retract(Seq : Int64);
  Begin
   fDB.Retract(Seq);
  End;

 Procedure TFlightRecorder.Cockpit(Sender : TObject; Const Name : String);
  Var
   o : TOccurrence;
  Begin
   o.Trip  := Trip;
   o.Zulu  := Sim.Sample.Time('time_zulu');
   o.Local := Sim.Sample.Time('time_local');
   fFilter.Add(Name, o, GetTickCount64);
   If (Name = 'CRASHED') Or (Name = 'FLIGHT_ENDED') Then
    Stop;
  End;

 Procedure TFlightRecorder.Start;
  Var
   Task : TFacilityTask;
  Begin
   If (Trip <> 0) Or Not Sim.Connected Or Not Sim.SimulatorSupported Or Not Sim.Running Or Sim.FlightEnded Or Sim.FlightLoading Then
    Exit;
   Trip      := fDB.StartTrip(Sim.Sample, IntervalMS);
   fPlanNext := 0;
   If (fPlan <> Nil) And ((fPlan.ProcedureData = '') Or (fPlan.Points.Count = 0)) Then
    fProcedures.SetPlan(fPlan);
   fFSHud.BeginTrip(fDB.Connection, Trip, Sim.Sample.Time('time_zulu'));
   Try
    fPreflight.Flush(fDB.Connection, Trip);
   Except
    On E : Exception Do
     Log(1, 'FMC preflight cache: ' + E.Message);
   End;
   fPreflight.Clear;
   If fPlan <> Nil Then
    fDB.SaveFlightPlan(Trip, fPlan);
   fTitle     := Sim.Sample.S('title');
   fWasGround := Sim.Sample.N('sim_on_ground') <> 0;
   fNext      := 0;
   fSamples   := 0;
   Status     := Tr('Nagrywanie lotu ') + IntToStr(Trip);
   Log(2, Status + ' ' + fTitle);
   Task.Trip    := Trip;
   Task.Row     := Trip;
   Task.Kind    := 'departure';
   Task.Lat     := Sim.Sample.N('plane_coordinate.latitude');
   Task.Lon     := Sim.Sample.N('plane_coordinate.longitude');
   Task.Heading := Sim.Sample.N('plane_heading_degrees_true');
   fFacilities.Request(Task);
  End;

 Procedure TFlightRecorder.Stop;
  Begin
   If Assigned(fPreflight) Then
    fPreflight.Clear;
   If Assigned(fFilter) Then
    fFilter.Flush(GetTickCount64, True);
   If Trip > 0 Then
    Begin
     Log(2, Format('Stop trip=%d samples=%d running=%s engines=%s ground=%.0f error=%s', [Trip, fSamples, BoolToStr(Sim.Running, True), BoolToStr(Sim.Sample.EngineRunning, True), Sim.Sample.N('sim_on_ground'), Sim.Error]));
     fDB.EndTrip(Trip, Sim.Sample);
     Trip := 0;
     If fDB.RecordingIndex <> Nil Then
      Begin
       FreeAndNil(fMetar);
       FreeAndNil(fFacilities);
       fDB.FinalizeRecording;
       fFacilities := TFacilityReader.Create(Sim, fDB);
       fMetar      := TMetarService.Create(fDB);
       fMetar.AttachBridge(fBridge);
      End;
    End;
  End;

 Procedure TFlightRecorder.SampleReceived(Sender : TObject; s : TFlightSample);
  Var
   Ground   : Boolean;
   Captured : Boolean;
   NowMS    : UInt64;
   Task     : TFacilityTask;
  Begin
   Captured := False;
   If fPreflightTitle <> s.S('title') Then
    Begin
     fPreflight.Clear;
     fPreflightTitle := s.S('title');
     fPreflightNext  := 0;
    End;
   If (Trip > 0) And (Sim.FlightEnded Or ((Trim(s.S('title')) <> '') And (s.S('title') <> fTitle))) Then
    Stop;
   If Not Sim.Running Or Sim.Paused Or Sim.FlightEnded Or Sim.FlightLoading Or (Trim(s.S('title')) = '') Then
    Exit;
   If (Trip = 0) And Enabled And (GetTickCount64 >= fPreflightNext) Then
    Begin
     fProviders.Capture(s);
     Captured := True;
     fPreflight.Observe(s.AircraftData, s.Time('time_zulu'));
     fPreflightNext := GetTickCount64 + UInt64(Max(1, IntervalMS));
    End;
   Ground := s.N('sim_on_ground') <> 0;
   If Enabled And Sim.FlightStarted And (Trip = 0) Then
    Start;

   If Trip > 0 Then
    Begin
     If Ground <> fWasGround Then
      Begin
       Task.Trip := Trip;
       Task.Row  := fDB.Contact(Trip, s, Ground);
       Task.Kind := 'trip_liftoffs';
       If Ground Then
        Task.Kind   := 'trip_touchdowns';
       Task.Lat     := s.N('plane_coordinate.latitude');
       Task.Lon     := s.N('plane_coordinate.longitude');
       Task.Heading := s.N('plane_heading_degrees_true');
       fDB.Connection.ExecSQL('update ' + Task.Kind + ' set metar_status=''awaiting_airport'',metar_requested_utc=:u where id=:id', [DateToISO8601(TTimeZone.Local.ToUniversalTime(Now), True), Task.Row]);
       fFacilities.Request(Task);
      End;
     fWasGround := Ground;
     NowMS      := GetTickCount64;
     If NowMS >= fNext Then
      Begin
       If Not Captured Then
        fProviders.Capture(s);
       FreeAndNil(s.FSHudDataU);
       s.FSHudDataU := fFSHud.Snapshot;
       fDB.RecordSample(Trip, s);
       Inc(fSamples);
       If (fSamples = 1) Or (fSamples Mod 100 = 0) Then
        Log(2, Format('Trip %d: %d samples', [Trip, fSamples]));
       fNext := NowMS + UInt64(IntervalMS);
      End;
    End;
  End;

 Procedure TFlightRecorder.RequestHistoricalMetar(TripID : Integer);
  Begin
   fMetar.RequestHistorical(TripID);
  End;

 Procedure TFlightRecorder.EnableRouteBridge(Port : Word);
  Begin
   fMetar.AttachBridge(Nil);
   FreeAndNil(fBridge);
   Try
    fBridge := TRouteBridge.Create(Port);
    fMetar.AttachBridge(fBridge);
    Log(2, 'EFB route bridge: 127.0.0.1:' + IntToStr(Port));
   Except
    On E : Exception Do
     Log(1, 'EFB route bridge disabled: ' + E.Message);
   End;
  End;

 Procedure TFlightRecorder.SetFlightPlan(Plan : TFlightPlan);
  Begin
   If Plan = Nil Then
    Exit;
   If (fPlan <> Nil) And (Plan.Raw = fPlan.Raw) And (Plan.Source = fPlan.Source) Then
    Begin
     Plan.Free;
     Exit;
    End;
   fProcedures.SetPlan(Nil);
   fPlan.Free;
   fPlan := Plan;
   fProcedures.SetPlan(fPlan);
   fDB.SaveFlightPlan(Trip, fPlan);
   Log(2, 'Flight plan: ' + fPlan.Source + ' | ' + fPlan.Summary);
  End;

 Procedure TFlightRecorder.LoadPlanFile(Const Path : String);
  Var
   Plan   : TFlightPlan;
   Raw    : String;
   Stream : TFileStream;
   Reader : TStreamReader;
  Begin
   Stream := TFileStream.Create(Path, fmOpenRead Or fmShareDenyNone);
   Try
    If Stream.Size > 1048576 Then
     Raise Exception.Create(Tr('PLN exceeds 1 MB'));
    Reader := TStreamReader.Create(Stream, TEncoding.UTF8, True);
    Try
     Raw := Reader.ReadToEnd;
    Finally
     Reader.Free;
    End;
   Finally
    Stream.Free;
   End;
   If (fPlan <> Nil) And (fPlan.Raw = Raw) Then
    Exit;
   Plan := ParsePLN(Raw, Path);
   SetFlightPlan(Plan);
  End;

 Function TFlightRecorder.PlanSummary : String;
  Begin
   Result := 'No flight plan';
   If fPlan <> Nil Then
    Result := fPlan.Summary;
  End;

 Procedure TFlightRecorder.Tick;
  Var
   Raw : String;
  Begin
   Sim.Poll;
   If (Sim.UnsupportedSimulator <> '') And Not Sim.Quit Then
    Begin
     Status := Sim.UnsupportedSimulator;
     Exit;
    End;
   fProviders.Tick(Sim.Sample, Sim.TelemetryActive And Sim.Connected And Sim.Running And Not Sim.Paused And Not Sim.FlightEnded And Not Sim.FlightLoading And (Enabled Or (Trip > 0)), IntervalMS);
   fFSHud.Tick(fDB.Connection, Trip, Sim.Sample.Time('time_zulu'));
   fNativeATC.Tick(fBridge, Trip, Sim.Sample.Time('time_zulu'));
   If Not Sim.Connected Or Not Sim.Running Then
    fPreflight.Clear;
   // Parse and persist only on the owning recorder thread, never in HTTP/SimConnect callbacks.
   If fBridge <> Nil Then
    Begin
     Raw := fBridge.Take;
     If Raw <> '' Then
      Try
       SetFlightPlan(ParseEFBRoute(Raw));
      Except
       On E : Exception Do
        Log(1, 'EFB route rejected: ' + E.Message);
      End;
    End;
   If GetTickCount64 >= fPlanNext Then
    Begin
     fPlanNext := GetTickCount64 + 10000;
     If (Sim.FlightPlanPath <> '') And ((fPlan = Nil) Or (fPlan.Source <> 'MSFS24 EFB')) Then
      Try
       LoadPlanFile(Sim.FlightPlanPath);
      Except
       On E : Exception Do
        Log(1, 'Active PLN unavailable: ' + E.Message);
      End;
    End;
   fFilter.Flush(GetTickCount64);
   fFacilities.Tick;
   fProcedures.Tick;
   fMetar.Tick;
   If Trip > 0 Then
    fDB.RefreshRecordingMetadata;
   If Sim.Quit Then
    Begin
     Stop;
     Sim.Disconnect;
     Status := Tr('MSFS roz'#322#261'czony');
    End;
  End;

End.
