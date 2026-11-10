Program VerifyRecordingFiles;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU, Winapi.Windows, System.SysUtils, System.Classes, System.IOUtils,
 System.Variants, Vcl.Forms, FireDAC.Comp.Client, FireDAC.Stan.Param, Data.DB,
 FlightDatabaseU, RecordingIndexU, FlightTelemetryU, TelemetryCatalogU;

Procedure Check(b : Boolean; Const Msg : String);
 Begin
  If Not b Then
   Raise Exception.Create(Msg);
 End;

Procedure SetText(s : TFlightSample; Const Name, Value : String);
 Var
  i : Integer;
 Begin
  For i := 0 To FieldCount - 1 Do
   If SimFields[i].Name = Name Then
    s.Texts[i] := Value;
 End;

Procedure SetNumber(s : TFlightSample; Const Name : String; Value : Double);
 Var
  i : Integer;
 Begin
  For i := 0 To FieldCount - 1 Do
   If SimFields[i].Name = Name Then
    s.Numbers[i] := Value;
 End;

Function Sample : TFlightSample;
 Begin
  Result := TFlightSample.Create;
  SetText(Result, 'title', 'iFly 737-MAX8 LOT SP-LVA (166Seat)');
  SetText(Result, 'atc_model', 'B38M');
  SetText(Result, 'atc_type', 'BOEING');
  SetNumber(Result, 'time_zulu.year', 2026);
  SetNumber(Result, 'time_zulu.month', 10);
  SetNumber(Result, 'time_zulu.day', 21);
  SetNumber(Result, 'time_local.year', 2026);
  SetNumber(Result, 'time_local.month', 10);
  SetNumber(Result, 'time_local.day', 21);
 End;

Procedure TestWriter;
 Var
  DB     : TFlightDatabase;
  ReadDB : TFlightDatabase;
  Index  : TRecordingIndex;
  s      : TFlightSample;
  Root   : String;
  Path   : String;
  First  : String;
  Second : String;
  ID     : Integer;
  ID2    : Integer;
 Begin
  Root := TPath.Combine(TestDataDirectory, 'writer');
  ForceDirectories(Root);
  Path := TPath.Combine(Root, 'flight_data.mfzi');
  DB   := TFlightDatabase.Create(Path, TestRuntimeFile('sqlite3.dll'), True);
  s    := Sample;
  Try
   ID := DB.StartTrip(s);
   DB.RecordSample(ID, s);
   DB.Connection.ExecSQL('update trips set departure_icao=''EPLL'',destination_icao=''EPLL'' where id=:id', [ID]);
   DB.Event(ID, 'FIRST', s.Time('time_zulu'), s.Time('time_local'), 1);
   First := DB.RecordingIndex.PathFor(ID);
   Check(FileExists(First), 'Active file exists');
   Check(VarToStr(DB.RecordingIndex.Connection.ExecSQLScalar('select status from trips where id=:id', [ID])) = 'recording', 'Recording status');
   Check(Integer(DB.RecordingIndex.Connection.ExecSQLScalar('select count(*) from sqlite_master where name=''trip_data''')) = 0, 'Index has no telemetry tables');
   DB.EndTrip(ID, s);
   Check(VarToStr(DB.RecordingIndex.Connection.ExecSQLScalar('select status from trips where id=:id', [ID])) = 'finalizing', 'Finalizing status');
   DB.FinalizeRecording;
   First := DB.RecordingIndex.PathFor(ID);
   Check(FileExists(First), 'Finalized file exists');
   Check(Pos('Recordings\B38M\EPLL\', First) > 0, 'ICAO hierarchy');
   Check(Pos('-EPLL-EPLL_B38M.mfzr', First) > 0, 'Canonical filename');
   Check(ExtractFileName(First) = '2026-10-21_00-00-00-EPLL-EPLL_B38M.mfzr', 'Name uses flight start, not Windows clock');
   Check(VarToStr(DB.RecordingIndex.Connection.ExecSQLScalar('select status from trips where id=:id', [ID])) = 'completed', 'Completed status');
   SetText(s, 'atc_model', 'A320');
   SetText(s, 'title', 'Fenix A320');
   ID2 := DB.StartTrip(s);
   DB.RecordSample(ID2, s);
   DB.Event(ID2, 'SECOND', s.Time('time_zulu'), s.Time('time_local'), 2);
   DB.EndTrip(ID2, s);
   DB.FinalizeRecording;
   Second := DB.RecordingIndex.PathFor(ID2);
   Check(ID <> ID2, 'Index IDs unique');
   Check(Not SameText(First, Second), 'Separate files');
   ReadDB := TFlightDatabase.Create(First, TestRuntimeFile('sqlite3.dll'), True);
   Try
    ReadDB.Connection.ExecSQL('insert into trip_flight_plans(trip,captured_utc,source,format,payload) values(:t,''2026-10-25T00:00:00Z'',''test'',''PLN'',:p)', [ID, '<SimBase.Document><FlightPlan.FlightPlan><DepartureID>EPLL</DepartureID><DestinationID>EGLL</DestinationID></FlightPlan.FlightPlan></SimBase.Document>']);
    DB.RecordingIndex.Connection.ExecSQL('update trips set destination_icao=NULL where id=:t', [ID]);
    DB.RecordingIndex.RepairPlanMetadata;
    Check(VarToStr(DB.RecordingIndex.Connection.ExecSQLScalar('select destination_icao from trips where id=:t', [ID])) = 'EGLL', 'Missing destination recovered from stored PLN');
    Check(Integer(ReadDB.Connection.ExecSQLScalar('select count(*) from trips')) = 1, 'First has one trip');
    Check(Integer(ReadDB.Connection.ExecSQLScalar('select count(*) from trip_data')) = 1, 'First samples');
    Check(VarToStr(ReadDB.Connection.ExecSQLScalar('select event from trip_events')) = 'FIRST', 'First events isolated');
   Finally
    ReadDB.Free;
   End;
   ReadDB := TFlightDatabase.Create(Second, TestRuntimeFile('sqlite3.dll'), True);
   Try
    Check(Integer(ReadDB.Connection.ExecSQLScalar('select count(*) from trips')) = 1, 'Second has one trip');
    Check(VarToStr(ReadDB.Connection.ExecSQLScalar('select event from trip_events')) = 'SECOND', 'Second events isolated');
   Finally
    ReadDB.Free;
   End;
  Finally
   s.Free;
   DB.Free;
  End;
  Index := TRecordingIndex.Create(Path, TestRuntimeFile('sqlite3.dll'));
  Try
   TFile.Delete(First);
   Check(Integer(Index.Connection.ExecSQLScalar('select count(*) from trips')) = 2, 'Missing file never removes metadata');
   Try
    Index.Resolve('..\outside.mfzr');
    Raise Exception.Create('Traversal accepted');
   Except
    On E : Exception Do
     Check(Pos('escapes', E.Message) > 0, 'Traversal rejected');
   End;
  Finally
   Index.Free;
  End;
  System.Writeln('PASS: per-flight files, metadata-only index, lifecycle, paths, sample/event isolation, missing files.');
 End;

Procedure TestMigration;
 Var
  DB        : TFlightDatabase;
  Flight    : TFlightDatabase;
  Index     : TRecordingIndex;
  s         : TFlightSample;
  q         : TFDQuery;
  Root      : String;
  Legacy    : String;
  IndexPath : String;
  Original  : String;
  ID        : Integer;
  i         : Integer;
  Before    : TBytes;
  After     : TBytes;
 Begin
  Root := TPath.Combine(TestDataDirectory, 'migration');
  ForceDirectories(Root);
  Legacy    := TPath.Combine(Root, 'flight_data.db');
  IndexPath := TPath.Combine(Root, 'flight_data.mfzi');
  DB        := TFlightDatabase.Create(Legacy, TestRuntimeFile('sqlite3.dll'));
  s         := Sample;
  Try
   DB.Connection.ExecSQL('insert into trip_groups(id,name) values(7,''Practice'')');
   DB.Connection.ExecSQL('create table extra_payload(trip integer,raw_text text)');
   For i := 1 To 3 Do
    Begin
     SetText(s, 'title', 'Migration ' + IntToStr(i));
     ID := DB.StartTrip(s);
     DB.RecordSample(ID, s);
     DB.Connection.ExecSQL('update trips set departure_icao=''EPLL'',destination_icao=''EPMO'',group_id=7 where id=:id', [ID]);
     DB.Event(ID, 'EVENT ' + IntToStr(i), s.Time('time_zulu'), s.Time('time_local'), i);
     DB.Connection.ExecSQL('insert into extra_payload values(:id,:p)', [ID, 'RAW ' + IntToStr(i)]);
     DB.Connection.ExecSQL('insert into trip_fmc_screens(trip,sample,time_zulu,captured_utc,provider,device,page_key,title,available,powered,raw_text,parsed_json,style_json,annunciators_json) ' +
     'values(:id,1,''2026-10-21T00:00:00Z'',''2026-10-21T00:00:00Z'',''test'',''0'',''page'',''PAGE'',1,1,:raw,''{}'',''{"font":"small"}'',''{"EXEC":true}'')', [ID, 'SCREEN ' + IntToStr(i)]);
     DB.EndTrip(ID, s);
    End;
   DB.Connection.ExecSQL('pragma wal_checkpoint(TRUNCATE)');
  Finally
   s.Free;
   DB.Free;
  End;
  Before := TFile.ReadAllBytes(Legacy);
  Index  := TRecordingIndex.Create(IndexPath, TestRuntimeFile('sqlite3.dll'));
  q      := TFDQuery.Create(Nil);
  Try
   Index.Migrate(Legacy);
   Index.Migrate(Legacy);
   Check(Integer(Index.Connection.ExecSQLScalar('select count(*) from trips')) = 3, 'Idempotent migration');
   Check(Integer(Index.Connection.ExecSQLScalar('select count(*) from trip_groups')) = 1, 'Groups migrated once');
   q.Connection := Index.Connection;
   q.Open('select * from trips order by id');
   i := 0;
   While Not q.Eof Do
    Begin
     Inc(i);
     Original := Index.PathFor(q.FieldByName('id').AsInteger);
     Check(FileExists(Original), 'Migrated file exists');
     Check(Pos('2026-10-21_00-00-00-EPLL-EPMO_B38M', Original) > 0, 'Original start timestamp');
     Check(Pos('\2026\10\', Original) > 0, 'Numeric year/month folders');
     Check(q.FieldByName('group_id').AsInteger > 0, 'Group link retained');
     Flight := TFlightDatabase.Create(Original, TestRuntimeFile('sqlite3.dll'));
     Try
      Check(Integer(Flight.Connection.ExecSQLScalar('select count(*) from trips')) = 1, 'One migrated trip');
      Check(Integer(Flight.Connection.ExecSQLScalar('pragma user_version')) = 1, 'Schema version preserved');
      Check(Integer(Flight.Connection.ExecSQLScalar('select count(*) from trip_data')) = 1, 'One migrated sample');
      Check(VarToStr(Flight.Connection.ExecSQLScalar('select raw_text from extra_payload')) = 'RAW ' + IntToStr(i), 'Extension table isolated');
      Check(VarToStr(Flight.Connection.ExecSQLScalar('select raw_text from trip_fmc_screens')) = 'SCREEN ' + IntToStr(i), 'FMC preserved');
      Check(VarToStr(Flight.Connection.ExecSQLScalar('select style_json from trip_fmc_screens')) = '{"font":"small"}', 'FMC formatting preserved');
      Check(VarToStr(Flight.Connection.ExecSQLScalar('select annunciators_json from trip_fmc_screens')) = '{"EXEC":true}', 'FMC lights preserved');
     Finally
      Flight.Free;
     End;
     q.Next;
    End;
   Check(i = 3, 'All flights migrated');
   Check(Length(TDirectory.GetFiles(TPath.Combine(Root, 'Recordings'), '*.before-native-*', TSearchOption.soAllDirectories)) = 0, 'No repeated schema upgrade backup on migrated files');
  Finally
   q.Free;
   Index.Free;
  End;
  After := TFile.ReadAllBytes(Legacy);
  Check((Length(Before) = Length(After)) And CompareMem(@Before[0], @After[0], Length(Before)), 'Legacy original byte-for-byte unchanged');
  System.Writeln('PASS: three-flight migration, groups, raw extension/FMC/style/lights, collisions, idempotence, original unchanged.');
 End;

Procedure CrashFixture(Const Path : String);
 Var
  DB : TFlightDatabase;
  s  : TFlightSample;
  ID : Integer;
 Begin
  DB := TFlightDatabase.Create(Path, TestRuntimeFile('sqlite3.dll'), True);
  s  := Sample;
  ID := DB.StartTrip(s);
  DB.RecordSample(ID, s);
  DB.Connection.ExecSQL('update trips set departure_icao=''EPLL'' where id=:id', [ID]);
  DB.RefreshRecordingMetadata;
  TerminateProcess(GetCurrentProcess, 0); // Deliberately bypass destructors/SQLite checkpoint.
 End;

Procedure TestRecovery;
 Var
  Root        : String;
  Path        : String;
  CommandLine : String;
  Error       : String;
  OldPath     : String;
  NewRelative : String;
  NewPath     : String;
  SI          : TStartupInfo;
  PI          : TProcessInformation;
  ExitCode    : DWORD;
  Index       : TRecordingIndex;
  ID          : Integer;
  DB          : TFlightDatabase;
 Begin
  Root := TPath.Combine(TestDataDirectory, 'recovery');
  ForceDirectories(Root);
  Path           := TPath.Combine(Root, 'flight_data.mfzi');
  SI             := Default(TStartupInfo);
  SI.cb          := SizeOf(SI);
  SI.dwFlags     := STARTF_USESHOWWINDOW;
  SI.wShowWindow := SW_HIDE;
  PI             := Default(TProcessInformation);
  CommandLine    := '"' + ParamStr(0) + '" --crash-fixture "' + Path + '"';
  UniqueString(CommandLine);
  Check(CreateProcess(Nil, PChar(CommandLine), Nil, Nil, False, CREATE_NO_WINDOW, Nil, Nil, SI, PI), 'Launch crash fixture');
  Try
   Check(WaitForSingleObject(PI.hProcess, 15000) = WAIT_OBJECT_0, 'Crash fixture timeout');
   Check(GetExitCodeProcess(PI.hProcess, ExitCode) And (ExitCode = 0), 'Crash fixture success');
  Finally
   CloseHandle(PI.hThread);
   CloseHandle(PI.hProcess);
  End;
  Index := TRecordingIndex.Create(Path, TestRuntimeFile('sqlite3.dll'));
  Try
   ID      := Index.Connection.ExecSQLScalar('select id from trips');
   OldPath := Index.PathFor(ID);
   Check(FileExists(OldPath + '-wal'), 'Crash leaves committed WAL');
   Check(Integer(Index.Connection.ExecSQLScalar('select recovery_pending from trips')) = 1, 'Pending recovery detected');
   Check(Index.Recover(ID, Error), 'Recover WAL: ' + Error);
   Check(VarToStr(Index.Connection.ExecSQLScalar('select status from trips')) = 'interupted', 'Interrupted status retained');
   DB := TFlightDatabase.Create(OldPath, TestRuntimeFile('sqlite3.dll'), True);
   Try
    Check(Integer(DB.Connection.ExecSQLScalar('select count(*) from trip_data')) = 1, 'Recovered committed sample');
   Finally
    DB.Free;
   End;
   // Simulate termination after rename but before publishing the new index path.
   NewRelative := Index.RecordingPath(ID);
   NewPath     := Index.Resolve(NewRelative);
   Check(Not SameText(OldPath, NewPath), 'Recovery path changed after airport lookup');
   ForceDirectories(ExtractFileDir(NewPath));
   TFile.Move(OldPath, NewPath);
   Index.Connection.ExecSQL('update trips set pending_path=:p,status=''finalizing'',recovery_pending=1 where id=:id', [NewRelative, ID]);
   Check(Index.Recover(ID, Error), 'Recover pending rename: ' + Error);
   Check(SameText(Index.PathFor(ID), NewPath), 'Recovered renamed path');
   // Failed validation retains the metadata and damaged file.
   TFile.WriteAllText(NewPath, 'not SQLite', TEncoding.UTF8);
   Check(Not Index.Recover(ID, Error), 'Corrupt recording rejected');
   Check(Error <> '', 'Recovery error supplied');
   Check(FileExists(NewPath), 'Corrupt file retained');
   Check(Integer(Index.Connection.ExecSQLScalar('select count(*) from trips')) = 1, 'Corrupt metadata retained');
  Finally
   Index.Free;
  End;
  System.Writeln('PASS: hard process termination, committed WAL recovery, interrupted rename, corrupt file retention.');
 End;

Type

 [TestFixture]
 TVerifyRecordingFilesTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyRecordingFilesTests.Regression;
 Begin
  Try

   Application.Initialize;
   TestWriter;
   TestMigration;
   TestRecovery;
  Except
   On E : Exception Do
    Begin
     System.Writeln(E.ClassName + ': ' + E.Message);
     Raise Exception.Create('Regression failed; see diagnostic above');
    End;
  End;

 End;

Begin
 If (ParamCount = 2) And (ParamStr(1) = '--crash-fixture') Then
  CrashFixture(ParamStr(2))
 Else
  RunNativeTests(TVerifyRecordingFilesTests);

End.
