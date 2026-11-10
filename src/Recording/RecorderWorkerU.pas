{$StackFrames On}
Unit RecorderWorkerU;

Interface

 Uses
  System.Classes, System.SysUtils, System.SyncObjs, System.Generics.Collections,
  LocalizationU, FlightRecorderU;

 Type
  TRecorderState = Record
   Trip                 : Integer;
   WorkerThreadID       : Cardinal;
   Status               : String;
   Plan                 : String;
   Error                : String;
   SimulatorSupported   : Boolean;
   UnsupportedSimulator : String;
   Ready                : Boolean;
   Failed               : Boolean;
  End;

  TRecorderCommand = Record
   Kind  : String;
   Value : String;
   ID    : Integer;
  End;

  TRecorderWorker = Class(TThread)
   Private
    fLock       : TCriticalSection;
    fWake       : TEvent;
    fCommands   : TList<TRecorderCommand>;
    fState      : TRecorderState;
    fPath       : String;
    fRoot       : String;
    fPlan       : String;
    fBridgePort : Integer;
    fInterval   : Integer;
    fEnabled    : Boolean;
    fConnect    : Boolean;
   Protected
    Procedure Execute; Override;
    Procedure PollRecorder(Recorder : TFlightRecorder); Virtual;
    Procedure ConnectRecorder(Recorder : TFlightRecorder); Virtual;
   Public
    Constructor Create(Const Path, Root, Plan : String; BridgePort : Integer; Connect : Boolean = True);
    Destructor Destroy; Override;
    Procedure Configure(Interval : Integer; Enabled : Boolean);
    Procedure Command(Const Kind : String; Const Value : String = ''; ID : Integer = 0);
    Function Snapshot : TRecorderState;
  End;

Implementation

 Uses
  Winapi.Windows, Winapi.ActiveX, System.IOUtils, SimConnectClientU, FlightDatabaseU, AppLogU, MetarU;

 Procedure TRecorderWorker.ConnectRecorder(Recorder : TFlightRecorder);
  Begin
   Recorder.Sim.Connect(TPath.Combine(fRoot, 'SimConnect.dll'));
  End;

 Procedure TRecorderWorker.PollRecorder(Recorder : TFlightRecorder);
  Begin
   Recorder.Tick;
  End;

 Constructor TRecorderWorker.Create(Const Path, Root, Plan : String; BridgePort : Integer; Connect : Boolean);
  Begin
   Inherited Create(True);
   fLock         := TCriticalSection.Create;
   fWake         := TEvent.Create(Nil, False, False, '');
   fCommands     := TList<TRecorderCommand>.Create;
   fPath         := Path;
   fRoot         := Root;
   fPlan         := Plan;
   fBridgePort   := BridgePort;
   fConnect      := Connect;
   fInterval     := 500;
   fEnabled      := True;
   fState.Status := Tr('Starting recorder');
  End;

 Destructor TRecorderWorker.Destroy;
  Begin
   Terminate;
   If Suspended Then
    Start;
   fWake.SetEvent;
   WaitFor;
   fCommands.Free;
   fWake.Free;
   fLock.Free;
   Inherited;
  End;

 Procedure TRecorderWorker.Configure(Interval : Integer; Enabled : Boolean);
  Begin
   fLock.Enter;
   Try
    fInterval := Interval;
    fEnabled  := Enabled;
   Finally
    fLock.Leave;
   End;
  End;

 Procedure TRecorderWorker.Command(Const Kind, Value : String; ID : Integer);
  Var
   c : TRecorderCommand;
  Begin
   c.Kind  := Kind;
   c.Value := Value;
   c.ID    := ID;
   fLock.Enter;
   Try
    If fCommands.Count >= 128 Then
     Raise Exception.Create(Tr('Recorder command queue full'));
    fCommands.Add(c);
   Finally
    fLock.Leave;
   End;
   fWake.SetEvent;
  End;

 Function TRecorderWorker.Snapshot : TRecorderState;
  Begin
   fLock.Enter;
   Try
    Result := fState;
   Finally
    fLock.Leave;
   End;
  End;

 Procedure TRecorderWorker.Execute;
  Var
   DB        : TFlightDatabase;
   r         : TFlightRecorder;
   WeatherDB : TFlightDatabase;
   Weather   : TMetarService;
   Commands  : TArray<TRecorderCommand>;
   c         : TRecorderCommand;
   State     : TRecorderState;
   Retry     : UInt64;
   HR        : HRESULT;
  Begin
   WeatherDB            := Nil;
   Weather              := Nil;
   DB                   := Nil;
   r                    := Nil;
   Retry                := 0;
   State                := Default(TRecorderState);
   State.WorkerThreadID := GetCurrentThreadId;
   State.Status         := Tr('Starting recorder');
   fLock.Enter;
   Try
    fState := State;
   Finally
    fLock.Leave;
   End;
   HR := CoInitializeEx(Nil, COINIT_MULTITHREADED);
   Try
    Try
     If Terminated Then
      Exit;
     DB := TFlightDatabase.Create(fPath, TPath.Combine(fRoot, 'sqlite3.dll'), True);
     r  := TFlightRecorder.Create(DB);
     If fBridgePort > 0 Then
      r.EnableRouteBridge(fBridgePort);
     If FileExists(fPlan) Then
      Try
       r.LoadPlanFile(fPlan);
      Except
       On E : Exception Do
        Log(1, 'Fallback PLN: ' + E.Message);
      End;
     State.Ready := True;
     While Not Terminated Do
      Begin
       fLock.Enter;
       Try
        r.IntervalMS := fInterval;
        r.Enabled    := fEnabled;
        Commands     := fCommands.ToArray;
        fCommands.Clear;
       Finally
        fLock.Leave;
       End;
       For c In Commands Do
        Try
         State.Error := '';
         If c.Kind = 'start' Then
          r.Start
         Else If c.Kind = 'stop' Then
          r.Stop
         Else If c.Kind = 'plan' Then
          r.LoadPlanFile(c.Value)
         Else If c.Kind = 'metar' Then
          If c.Value = '' Then
           r.RequestHistoricalMetar(c.ID)
          Else
           Begin
            FreeAndNil(Weather);
            FreeAndNil(WeatherDB);
            If Not FileExists(c.Value) Then
             Raise Exception.Create('Recording file missing');
            WeatherDB := TFlightDatabase.Create(c.Value, TPath.Combine(fRoot, 'sqlite3.dll'), True);
            Weather   := TMetarService.Create(WeatherDB);
            Weather.RequestHistorical(c.ID);
           End;
        Except
         On E : Exception Do
          Begin
           State.Error := E.Message;
           r.Status    := E.Message;
           Log(1, 'Recorder command: ' + E.Message);
          End;
        End;
       Try
        If fConnect And Not r.Sim.Opened And (GetTickCount64 >= Retry) Then
         Begin
          Retry := GetTickCount64 + 3000;
          Try
           ConnectRecorder(r);
           State.Error := '';
          Except
           On E : ESimConnectUnavailable Do
            Begin
             r.Status := Tr('Oczekiwanie na MSFS');
             // No active recording was touched; replay remains independent.
             State.Error := '';
            End;
          End;
         End;
        PollRecorder(r);
        If Weather <> Nil Then
         Weather.Tick;
       Except
        On E : Exception Do
         Begin
          r.Status := E.Message;
          Log(1, Tr('Recorder worker: ') + E.Message);
          State.Error := E.Message;
          DB.RecordingError;
          Try
           r.Stop;
          Except
           On X : Exception Do
            Log(0, 'Recorder stop: ' + X.Message);
          End;
          r.Sim.Disconnect;
         End;
       End;
       State.SimulatorSupported   := r.Sim.SimulatorSupported And r.Sim.Connected;
       State.UnsupportedSimulator := r.Sim.UnsupportedSimulator;
       State.Trip                 := r.Trip;
       State.Plan                 := r.PlanSummary;
       State.Status               := r.Status;
       If r.Sim.Connected Then
        State.Status := Format(Tr('MSFS: %s | lot %d | IAS %.0f | ALT %.0f'), [r.Sim.Sample.S('title'), r.Trip, r.Sim.Sample.N('airspeed_indicated'), r.Sim.Sample.N('plane_altitude')]);
       fLock.Enter;
       Try
        fState := State;
       Finally
        fLock.Leave;
       End;
       fWake.WaitFor(20);
      End;
    Except
     On E : Exception Do
      Begin
       State.Failed := True;
       State.Status := E.Message;
       State.Error  := E.Message;
       fLock.Enter;
       Try
        fState := State;
       Finally
        fLock.Leave;
       End;
       Log(0, 'Recorder worker failed: ' + E.Message);
      End;
    End;
   Finally
    Try
     Weather.Free;
     WeatherDB.Free;
     r.Free;
    Finally
     DB.Free;
     If Succeeded(HR) Then
      CoUninitialize;
    End;
   End;
  End;

End.
