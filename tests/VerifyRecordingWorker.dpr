Program VerifyRecordingWorker;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU, Winapi.Windows, System.SysUtils, System.Classes, System.IOUtils,
 System.Variants, Vcl.Forms, Vcl.ExtCtrls, FlightDatabaseU, RecordingIndexU,
 RecorderWorkerU, FlightRecorderU, TelemetryCatalogU;

Type
 TFixtureWorker = Class(TRecorderWorker)
  Protected
   Procedure PollRecorder(Recorder : TFlightRecorder); Override;
 End;

 THeartbeat = Class
  Count : Integer;
  Procedure Tick(Sender : TObject);
 End;

Procedure Check(b : Boolean; Const Msg : String);
 Begin
  If Not b Then
   Raise Exception.Create(Msg);
 End;

Procedure THeartbeat.Tick(Sender : TObject);
 Begin
  Inc(Count);
 End;

Procedure TFixtureWorker.PollRecorder(Recorder : TFlightRecorder);
 Var
  i : Integer;
 Begin
  Recorder.Sim.SimulatorSupported := True;
  Recorder.Sim.Connected          := True;
  Recorder.Sim.Running            := True;
  If Not Recorder.Sim.FlightStarted Then
   Recorder.Sim.ApplyFlow(14, 'fixture.FLT');
  For i := 0 To FieldCount - 1 Do
   Begin
    If SimFields[i].Name = 'title' Then
     Recorder.Sim.Sample.Texts[i] := 'Worker file fixture';
    If SimFields[i].Name = 'atc_model' Then
     Recorder.Sim.Sample.Texts[i] := 'B38M';
    If SimFields[i].Name = 'time_zulu.year' Then
     Recorder.Sim.Sample.Numbers[i] := 2026;
    If SimFields[i].Name = 'time_zulu.month' Then
     Recorder.Sim.Sample.Numbers[i] := 10;
    If SimFields[i].Name = 'time_zulu.day' Then
     Recorder.Sim.Sample.Numbers[i] := 21;
   End;
  Recorder.Sim.OnSample(Recorder.Sim, Recorder.Sim.Sample);
 End;

Procedure Pump(MS : Cardinal);
 Var
  UntilMS : UInt64;
 Begin
  UntilMS := GetTickCount64 + MS;
  Repeat
   Application.ProcessMessages;
   Sleep(1);
  Until GetTickCount64 >= UntilMS;
 End;

Var
 w        : TFixtureWorker;
 Index    : TRecordingIndex;
 Reader   : TFlightDatabase;
 h        : THeartbeat;
 Timer    : TTimer;
 State    : TRecorderState;
 Path     : String;
 FilePath : String;
 UntilMS  : UInt64;
 Started  : UInt64;
 ID       : Integer;

Type

 [TestFixture]
 TVerifyRecordingWorkerTests = Class
  Public
   [Test]
   Procedure Regression;
 End;

Procedure TVerifyRecordingWorkerTests.Regression;
 Begin
  Try
   Application.Initialize;
   Path   := TPath.Combine(TestDataDirectory, 'flight_data.mfzi');
   Index  := TRecordingIndex.Create(Path, TestRuntimeFile('sqlite3.dll'));
   w      := TFixtureWorker.Create(Path, ExtractFileDir(TestRuntimeFile('sqlite3.dll')), '', 0, False);
   h      := THeartbeat.Create;
   Timer  := TTimer.Create(Nil);
   Reader := Nil;
   Try
    Timer.Interval := 20;
    Timer.OnTimer  := h.Tick;
    w.Configure(20, True);
    w.Start;
    UntilMS := GetTickCount64 + 10000;
    Repeat
     Pump(10);
     State := w.Snapshot;
     Check(Not State.Failed, State.Error);
    Until(State.Ready And (State.Trip > 0)) Or (GetTickCount64 >= UntilMS);
    Check(State.Ready And (State.Trip > 0), 'Writer starts with only index');
    ID       := State.Trip;
    FilePath := Index.PathFor(ID);
    Check(FileExists(FilePath), 'Worker created per-flight file');
    Reader := TFlightDatabase.Create(FilePath, TestRuntimeFile('sqlite3.dll'), True);
    Reader.Connection.StartTransaction;
    Reader.Connection.ExecSQL('insert into trip_groups(name) values(''writer contention'')');
    Pump(300);
    Started := GetTickCount64;
    w.Configure(250, False);
    w.Command('stop');
    State := w.Snapshot;
    Check(GetTickCount64 - Started < 250, 'UI commands never wait for recording lock');
    Check(h.Count >= 3, 'VCL heartbeat continues during file contention');
    Check(State.WorkerThreadID <> GetCurrentThreadId, 'Worker owns recorder');
    Reader.Connection.Commit;
    FreeAndNil(Reader);
    UntilMS := GetTickCount64 + 10000;
    Repeat
     Pump(20);
     State := w.Snapshot;
    Until(State.Trip = 0) Or (GetTickCount64 >= UntilMS);
    Check(State.Trip = 0, 'Stop completed');
    FreeAndNil(w);
    Check(VarToStr(Index.Connection.ExecSQLScalar('select status from trips where id=:id', [ID])) = 'completed', 'Worker finalized index status');
    FilePath := Index.PathFor(ID);
    Reader   := TFlightDatabase.Create(FilePath, TestRuntimeFile('sqlite3.dll'), True);
    Check(Integer(Reader.Connection.ExecSQLScalar('select count(*) from trips')) = 1, 'One trip file');
    Check(Integer(Reader.Connection.ExecSQLScalar('select count(*) from trip_data')) > 1, 'Worker samples survived final rename');
    System.Writeln('PASS: indexed recording in worker, file contention, VCL heartbeat, nonblocking commands, finalization, samples, shutdown.');
   Finally
    If Assigned(Reader) And Reader.Connection.InTransaction Then
     Reader.Connection.Rollback;
    Reader.Free;
    w.Free;
    Timer.Free;
    h.Free;
    Index.Free;
   End;
  Except
   On E : Exception Do
    Begin
     System.Writeln(E.ClassName + ': ' + E.Message);
     Raise Exception.Create('Regression failed; see diagnostic above');
    End;
  End;

 End;

Begin
 RunNativeTests(TVerifyRecordingWorkerTests);

End.
