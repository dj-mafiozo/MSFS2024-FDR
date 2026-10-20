program VerifyRecorderWorker;
{$APPTYPE CONSOLE}
uses Winapi.Windows, System.SysUtils, System.Classes, System.IOUtils,
  Vcl.Forms, Vcl.ExtCtrls, FlightDatabaseU, RecorderWorkerU, FlightRecorderU, TelemetryCatalogU;
type
TTestRecorder = class(TRecorderWorker)
protected
  procedure PollRecorder(Recorder: TFlightRecorder); override;
end;
THeartbeat = class
  Count: Integer;
  procedure Tick(Sender: TObject);
end;
procedure TTestRecorder.PollRecorder(Recorder: TFlightRecorder);
var I: Integer;
begin
  Recorder.Sim.Connected := True; Recorder.Sim.Running := True;
  for I:=0 to FieldCount-1 do begin
    if SimFields[I].Name='title' then Recorder.Sim.Sample.Texts[I]:='Worker test aircraft';
    if SimFields[I].Name='time_zulu.year' then Recorder.Sim.Sample.Numbers[I]:=2026;
    if SimFields[I].Name='time_zulu.month' then Recorder.Sim.Sample.Numbers[I]:=10;
    if SimFields[I].Name='time_zulu.day' then Recorder.Sim.Sample.Numbers[I]:=18;
    if SimFields[I].Name='sim_on_ground' then Recorder.Sim.Sample.Numbers[I]:=1;
    if SimFields[I].Name='surface_type' then Recorder.Sim.Sample.Numbers[I]:=0;
  end;
  Recorder.Sim.OnSample(Recorder.Sim, Recorder.Sim.Sample);
end;
procedure THeartbeat.Tick(Sender: TObject);
begin Inc(Count); end;
procedure Check(Value: Boolean; const Msg: string);
begin if not Value then raise Exception.Create(Msg); end;
var DB: TFlightDatabase; W: TRecorderWorker; Root, Path, Plan: string;
    Timer: TTimer; Heart: THeartbeat; Started: UInt64; State: TRecorderState;
procedure Pump(Milliseconds: Cardinal);
var UntilMS: UInt64;
begin
  UntilMS := GetTickCount64 + Milliseconds;
  repeat Application.ProcessMessages; Sleep(1); until GetTickCount64 >= UntilMS;
end;
procedure AwaitReady;
var UntilMS: UInt64;
begin
  UntilMS := GetTickCount64 + 10000;
  repeat
    Pump(10); State := W.Snapshot;
    Check(not State.Failed, 'Worker failed: '+State.Status);
  until State.Ready or (GetTickCount64 >= UntilMS);
  Check(State.Ready, 'Worker initialization timeout');
end;
begin
  Application.Initialize;
  Root := ExtractFilePath(ParamStr(0));
  Path := Root+'worker-'+IntToStr(GetTickCount64)+'.db';
  Plan := Root+'fixtures\EPLL-EPLL.PLN';
  if not FileExists(Plan) then Plan := Root+'fixtures\EPMO-EPMO.PLN';
  Check(FileExists(Plan), 'Missing PLN fixture');
  DB := TFlightDatabase.Create(Path,Root+'sqlite3.dll');
  W := nil; Timer := TTimer.Create(nil); Heart := THeartbeat.Create;
  try
    Timer.Interval := 20; Timer.OnTimer := Heart.Tick;
    Check(SameText(DB.Connection.ExecSQLScalar('pragma journal_mode'), 'wal'), 'WAL missing');
    W := TTestRecorder.Create(Path, Root, '', 0, False);
    W.Configure(20, True); W.Start;
    AwaitReady;
    Check(State.Trip>0, 'Worker did not start recording synthetic telemetry');
    DB.Connection.StartTransaction;
    DB.Connection.ExecSQL('insert into trip_groups(name) values(''writer lock'')');
    Pump(300);
    State := W.Snapshot;
    Check((State.WorkerThreadID<>0) and (State.WorkerThreadID<>GetCurrentThreadId), 'Recorder must own another thread');
    Started := GetTickCount64;
    W.Configure(250, False); W.Command('plan',Plan); State := W.Snapshot;
    Check(GetTickCount64-Started<250, 'UI waits for recorder/database lock');
    Check(Heart.Count>=3, 'VCL timer stopped while worker was blocked');
    DB.Connection.Commit;
    Started := GetTickCount64;
    repeat Pump(10); State := W.Snapshot;
    until (Pos('EPLL',State.Plan)>0) or (Pos('EPMO',State.Plan)>0) or (GetTickCount64-Started>5000);
    Check((Pos('EPLL',State.Plan)>0) or (Pos('EPMO',State.Plan)>0), 'Queued plan did not reach worker');
    Check(DB.Connection.ExecSQLScalar('select count(*) from trip_data')>1, 'Worker did not resume sample writes');
    W.Command('plan',Root+'missing-file.pln'); Pump(100);
    State := W.Snapshot;
    Check(not State.Failed and (Pos('missing-file',State.Error)>0), 'Command error not published: '+State.Error);
    W.Command('stop'); Pump(50);
    FreeAndNil(W);
    Check(DB.Connection.ExecSQLScalar('select count(*) from trip_groups')=1, 'UI connection invalid after worker shutdown');
    W := TRecorderWorker.Create(Path, Root, '', 0, False);
    W.Free; W := nil; // Closing before Start must not deadlock.
  finally
    if DB.Connection.InTransaction then DB.Connection.Rollback;
    W.Free; Timer.Free; Heart.Free; DB.Free;
    DeleteFile(PChar(Path)); DeleteFile(PChar(Path+'-wal')); DeleteFile(PChar(Path+'-shm'));
  end;
  Writeln('PASS: recorder owns background connection/thread, VCL heartbeat and nonblocking commands under SQLite contention, WAL, queued PLN/errors, shutdown and unstarted cleanup. No simulator or network.');
end.
