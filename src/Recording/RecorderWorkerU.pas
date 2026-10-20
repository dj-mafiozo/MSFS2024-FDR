Unit RecorderWorkerU;

Interface

 Uses
  System.Classes, System.SysUtils, System.SyncObjs, System.Generics.Collections,
  LocalizationU, FlightRecorderU;

 Type
  TRecorderState = Record
   Public
    Trip           : Integer;
    WorkerThreadID : Cardinal;
    Status         : String;
    Plan           : String;
    Error          : String;
    Ready          : Boolean;
    Failed         : Boolean;
  End;

  TRecorderCommand = Record
   Public
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
   Public
    Constructor Create(Const Path, Root, Plan : String; BridgePort : Integer; Connect : Boolean = True);
    Destructor Destroy; Override;
    Procedure Configure(Interval : Integer; Enabled : Boolean);
    Procedure Command(Const Kind : String; Const Value : String = ''; ID : Integer = 0);
    Function Snapshot : TRecorderState;
  End;

Implementation

 Uses
  Winapi.Windows, Winapi.ActiveX, System.IOUtils, FlightDatabaseU, AppLogU;

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
   C : TRecorderCommand;
  Begin
   C.Kind  := Kind;
   C.Value := Value;
   C.ID    := ID;
   fLock.Enter;
   Try
    If fCommands.Count >= 128 Then
     Raise Exception.Create(Tr('Recorder command queue full'));
    fCommands.Add(C);
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
   DB       : TFlightDatabase;
   R        : TFlightRecorder;
   Commands : TArray<TRecorderCommand>;
   C        : TRecorderCommand;
   State    : TRecorderState;
   Retry    : UInt64;
   HR       : HRESULT;
  Begin
   DB                   := Nil;
   R                    := Nil;
   Retry                := 0;
   State                := Default (TRecorderState);
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
     R  := TFlightRecorder.Create(DB);
     If fBridgePort > 0 Then
      R.EnableRouteBridge(fBridgePort);
     If FileExists(fPlan) Then
      Try
       R.LoadPlanFile(fPlan);
      Except
       On E : Exception Do
        Log(1, 'Fallback PLN: ' + E.Message);
      End;
     State.Ready := True;
     While Not Terminated Do
      Begin
       fLock.Enter;
       Try
        R.IntervalMS := fInterval;
        R.Enabled    := fEnabled;
        Commands     := fCommands.ToArray;
        fCommands.Clear;
       Finally
        fLock.Leave;
       End;
       For C In Commands Do
        Try
         State.Error := '';
         If C.Kind = 'start' Then
          R.Start
         Else If C.Kind = 'stop' Then
          R.Stop
         Else If C.Kind = 'plan' Then
          R.LoadPlanFile(C.Value)
         Else If C.Kind = 'metar' Then
          R.RequestHistoricalMetar(C.ID);
        Except
         On E : Exception Do
          Begin
           State.Error := E.Message;
           R.Status    := E.Message;
           Log(1, 'Recorder command: ' + E.Message);
          End;
        End;
       Try
        If fConnect And Not R.Sim.Opened And (GetTickCount64 >= Retry) Then
         Begin
          Retry := GetTickCount64 + 3000;
          R.Sim.Connect(TPath.Combine(fRoot, 'SimConnect.dll'));
         End;
        PollRecorder(R);
       Except
        On E : Exception Do
         Begin
          R.Status := E.Message;
          Log(1, Tr('Recorder worker: ') + E.Message);
          State.Error := E.Message;
          Try
           R.Stop;
          Except
           On X : Exception Do
            Log(0, 'Recorder stop: ' + X.Message);
          End;
          R.Sim.Disconnect;
         End;
       End;
       State.Trip   := R.Trip;
       State.Plan   := R.PlanSummary;
       State.Status := R.Status;
       If R.Sim.Connected Then
        State.Status := Format(Tr('MSFS: %s | lot %d | IAS %.0f | ALT %.0f'), [R.Sim.Sample.S('title'), R.Trip, R.Sim.Sample.N('airspeed_indicated'), R.Sim.Sample.N('plane_altitude')]);
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
     R.Free;
    Finally
     DB.Free;
     If Succeeded(HR) Then
      CoUninitialize;
    End;
   End;
  End;

End.
