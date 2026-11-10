Program VerifyRecorderWorker;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU,
 Winapi.Windows, System.SysUtils, System.Classes, System.IOUtils,
 Vcl.Forms, Vcl.ExtCtrls, LocalizationU, SimConnectClientU, FlightDatabaseU, RecorderWorkerU, FlightRecorderU, TelemetryCatalogU;

Type
 TTestRecorder = Class(TRecorderWorker)
  Protected
   Procedure PollRecorder(Recorder : TFlightRecorder); Override;
 End;

 TOfflineRecorder = Class(TRecorderWorker)
  Public
   Calls : Integer;
  Protected
   Procedure ConnectRecorder(Recorder : TFlightRecorder); Override;
   Procedure PollRecorder(Recorder : TFlightRecorder); Override;
 End;

 THeartbeat = Class
  Count : Integer;
  Procedure Tick(Sender : TObject);
 End;

Procedure TOfflineRecorder.ConnectRecorder(Recorder : TFlightRecorder);
 Begin
  Inc(Calls);
  Raise ESimConnectUnavailable.Create('SimConnect_Open: E_FAIL (80004005)');
 End;

Procedure TOfflineRecorder.PollRecorder(Recorder : TFlightRecorder);
 Begin
 End;

Procedure TTestRecorder.PollRecorder(Recorder : TFlightRecorder);
 Var
  i : Integer;
 Begin
  Recorder.Sim.SimulatorSupported := True;
  Recorder.Sim.Connected          := True;
  Recorder.Sim.Running            := True;
  If Not Recorder.Sim.FlightStarted Then
   Recorder.Sim.ApplyFlow(14, 'worker.FLT');
  For i := 0 To FieldCount - 1 Do
   Begin
    If SimFields[i].Name = 'title' Then
     Recorder.Sim.Sample.Texts[i] := 'Worker test aircraft';
    If SimFields[i].Name = 'time_zulu.year' Then
     Recorder.Sim.Sample.Numbers[i] := 2026;
    If SimFields[i].Name = 'time_zulu.month' Then
     Recorder.Sim.Sample.Numbers[i] := 10;
    If SimFields[i].Name = 'time_zulu.day' Then
     Recorder.Sim.Sample.Numbers[i] := 18;
    If SimFields[i].Name = 'sim_on_ground' Then
     Recorder.Sim.Sample.Numbers[i] := 1;
    If SimFields[i].Name = 'surface_type' Then
     Recorder.Sim.Sample.Numbers[i] := 0;
   End;
  Recorder.Sim.OnSample(Recorder.Sim, Recorder.Sim.Sample);
 End;

Procedure THeartbeat.Tick(Sender : TObject);
 Begin
  Inc(Count);
 End;

Procedure Check(Value : Boolean; Const Msg : String);
 Begin
  If Not Value Then
   Raise Exception.Create(Msg);
 End;

Procedure TestOffline;
 Var
  w         : TOfflineRecorder;
  s         : TRecorderState;
  UntilTime : UInt64;
 Begin
  w := TOfflineRecorder.Create(TestDatabasePath(TestDataDirectory + 'offline.mfzi'), TestDataDirectory, '', 0, True);
  Try
   w.Start;
   UntilTime := GetTickCount64 + 5000;
   Repeat
    Sleep(10);
    s := w.Snapshot;
   Until(w.Calls > 0) Or s.Failed Or (GetTickCount64 > UntilTime);
   Sleep(100);
   s := w.Snapshot;
   Check(s.Ready And Not s.Failed And (s.Error = ''), 'Absent SimConnect is not a recorder failure');
   Check(s.Status = Tr('Oczekiwanie na MSFS'), 'Localized offline status');
   Check(w.Calls = 1, 'Disconnected retry is throttled');
  Finally
   w.Free;
  End;
  System.Writeln('PASS: unavailable SimConnect_Open waits without duplicate error or recording failure. Mock connection only.');
 End;

Var
 DB      : TFlightDatabase;
 w       : TRecorderWorker;
 Root    : String;
 Path    : String;
 Plan    : String;
 Timer   : TTimer;
 Heart   : THeartbeat;
 Started : UInt64;
 State   : TRecorderState;

Procedure Pump(Milliseconds : Cardinal);
 Var
  UntilMS : UInt64;
 Begin
  UntilMS := GetTickCount64 + Milliseconds;
  Repeat
   Application.ProcessMessages;
   Sleep(1);
  Until GetTickCount64 >= UntilMS;
 End;

Procedure AwaitReady;
 Var
  UntilMS : UInt64;
 Begin
  UntilMS := GetTickCount64 + 10000;
  Repeat
   Pump(10);
   State := w.Snapshot;
   Check(Not State.Failed, 'Worker failed: ' + State.Status);
  Until State.Ready Or (GetTickCount64 >= UntilMS);
  Check(State.Ready, 'Worker initialization timeout');
 End;

Type

 [TestFixture]
 TVerifyRecorderWorkerTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyRecorderWorkerTests.Regression;
 Begin
  Application.Initialize;
  TestOffline;
  Root := TestDataDirectory;
  Path := TestDatabasePath(Root + 'worker-' + IntToStr(GetTickCount64) + '.db');
  Plan := Root + 'fixtures\EPLL-EPLL.PLN';
  If Not FileExists(Plan) Then
   Plan := Root + 'fixtures\EPMO-EPMO.PLN';
  Check(FileExists(Plan), 'Missing PLN fixture');
  DB    := TFlightDatabase.Create(TestDatabasePath(Path), Root + 'sqlite3.dll');
  w     := Nil;
  Timer := TTimer.Create(Nil);
  Heart := THeartbeat.Create;
  Try
   Timer.Interval := 20;
   Timer.OnTimer  := Heart.Tick;
   Check(SameText(DB.Connection.ExecSQLScalar('pragma journal_mode'), 'wal'), 'WAL missing');
   w := TTestRecorder.Create(Path, Root, '', 0, False);
   w.Configure(20, True);
   w.Start;
   AwaitReady;
   Check(State.Trip > 0, 'Worker did not start recording synthetic telemetry');
   DB.Connection.StartTransaction;
   DB.Connection.ExecSQL('insert into trip_groups(name) values(''writer lock'')');
   Pump(300);
   State := w.Snapshot;
   Check((State.WorkerThreadID <> 0) And (State.WorkerThreadID <> GetCurrentThreadId), 'Recorder must own another thread');
   Started := GetTickCount64;
   w.Configure(250, False);
   w.Command('plan', Plan);
   State := w.Snapshot;
   Check(GetTickCount64 - Started < 250, 'UI waits for recorder/database lock');
   Check(Heart.Count >= 3, 'VCL timer stopped while worker was blocked');
   DB.Connection.Commit;
   Started := GetTickCount64;
   Repeat
    Pump(10);
    State := w.Snapshot;
   Until(Pos('EPLL', State.Plan) > 0) Or (Pos('EPMO', State.Plan) > 0) Or (GetTickCount64 - Started > 5000);
   Check((Pos('EPLL', State.Plan) > 0) Or (Pos('EPMO', State.Plan) > 0), 'Queued plan did not reach worker');
   Check(DB.Connection.ExecSQLScalar('select count(*) from trip_data') > 1, 'Worker did not resume sample writes');
   w.Command('plan', Root + 'missing-file.pln');
   Pump(100);
   State := w.Snapshot;
   Check(Not State.Failed And (Pos('missing-file', State.Error) > 0), 'Command error not published: ' + State.Error);
   w.Command('stop');
   Pump(50);
   FreeAndNil(w);
   Check(DB.Connection.ExecSQLScalar('select count(*) from trip_groups') = 1, 'UI connection invalid after worker shutdown');
   w := TRecorderWorker.Create(Path, Root, '', 0, False);
   w.Free;
   w := Nil; // Closing before Start must not deadlock.
  Finally
   If DB.Connection.InTransaction Then
    DB.Connection.Rollback;
   w.Free;
   Timer.Free;
   Heart.Free;
   DB.Free;
   DeleteFile(PChar(Path));
   DeleteFile(PChar(Path + '-wal'));
   DeleteFile(PChar(Path + '-shm'));
  End;
  System.Writeln('PASS: recorder owns background connection/thread, VCL heartbeat and nonblocking commands under SQLite contention, WAL, queued PLN/errors, shutdown and unstarted cleanup. No simulator or network.');

 End;

Begin
 RunNativeTests(TVerifyRecorderWorkerTests);
End.
