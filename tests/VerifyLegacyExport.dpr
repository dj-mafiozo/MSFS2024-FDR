Program VerifyLegacyExport;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU, System.SysUtils, System.Classes, System.IOUtils, System.Hash,
 System.Variants, System.Math, System.Types, FireDAC.Comp.Client, FireDAC.Stan.Param,
 FlightDatabaseU, FlightTelemetryU, TelemetryCatalogU, LegacyExportU, RecordingIndexU, InstrumentDataU;

Procedure Check(v : Boolean; Const m : String);
 Begin
  If Not v Then
   Raise Exception.Create(m);
 End;

Function Hash(Const Path : String) : String;
 Var
  s : TFileStream;
 Begin
  s := TFileStream.Create(Path, fmOpenRead Or fmShareDenyNone);
  Try
   Result := THashSHA2.GetHashString(s);
  Finally
   s.Free;
  End;
 End;

Var
 DB           : TFlightDatabase;
 s            : TFlightSample;
 c            : TFDConnection;
 q            : TFDQuery;
 Path         : String;
 OutPath      : String;
 Before       : String;
 TargetBefore : String;
 ImportedPath : String;
 ImportRoot   : String;
 PartPath     : String;
 MultiPath    : String;
 MultiBefore  : String;
 TableName    : String;
 Index        : TRecordingIndex;
 Imported     : TFlightDatabase;
 Plot         : TTripPlot;
 IDs          : Array[0..1] Of Integer;
 i            : Integer;
 j            : Integer;
 k            : Integer;
 Failed       : Boolean;

Procedure N(Const Name : String; v : Double);
 Var
  f : Integer;
 Begin
  For f := 0 To FieldCount - 1 Do
   If SimFields[f].Name = Name Then
    Begin
     s.Numbers[f] := v;
     Exit;
    End;
  Raise Exception.Create(Name);
 End;

Type

 [TestFixture]
 TVerifyLegacyExportTests = Class
  Public
   [Test]
   Procedure Regression;
 End;

Procedure TVerifyLegacyExportTests.Regression;
 Begin
  Try
   Path    := TestDatabasePath('export-source.mfzr');
   OutPath := TestDatabasePath('legacy.db');
   DB      := TFlightDatabase.Create(Path, TestRuntimeFile('sqlite3.dll'));
   s       := TFlightSample.Create;
   Try
    N('time_zulu.year', 2026);
    N('time_zulu.month', 10);
    N('time_zulu.day', 24);
    N('time_local.year', 2026);
    N('time_local.month', 10);
    N('time_local.day', 24);
    N('number_of_engines', 2);
    N('engine_type', 1);
    N('airspeed_indicated', 145);
    N('plane_pitch_degrees', -8.67602079016548);
    N('plane_coordinate.latitude', 51.7);
    N('plane_coordinate.longitude', 19.4);
    N('turb_eng_n1[0]', 93.812345);
    N('turb_eng_n1[1]', 94.1);
    N('eng_oil_quantity[0]', 0.8);
    N('turb_eng_n2[0]', NaN);
    N('turb_eng_n2[1]', NaN);
    N('autopilot_master', 1);
    N('sim_on_ground', 1);
    N('autothrottle_active', 1);
    N('total_air_temperature', 24.3);
    For i := 0 To 1 Do
     Begin
      For k := 0 To FieldCount - 1 Do
       If SimFields[k].Name = 'title' Then
        s.Texts[k] := 'Zażółć gęślą ' + IntToStr(i);
      IDs[i]       := DB.StartTrip(s);
      For j        := 0 To 2 Do
       Begin
        N('time_zulu.seconds', i * 100 + j);
        DB.RecordSample(IDs[i], s);
       End;
      DB.Contact(IDs[i], s, False);
      DB.Contact(IDs[i], s, True);
      DB.Event(IDs[i], 'TEST', '2026-10-24T12:00:00Z', '2026-10-24T14:00:00+02:00', i + 10);
      DB.EndTrip(IDs[i], s);
     End;
    DB.Connection.ExecSQL('insert into trip_groups(id,name,sort_order) values(7,''Załoga'',1)');
    DB.Connection.ExecSQL('update trips set group_id=7 where id=:id', [IDs[1]]);
    DB.Connection.ExecSQL('update trips set departure_local_time=''2026-10-24T14:00:00.000+02:00'',destination_local_time=''2026-10-24T15:00:00.000+02:00''');
    DB.Connection.ExecSQL('update trip_data set local_time=''2026-10-24T14:00:00.000+02:00''');
    DB.Connection.ExecSQL('update trip_touchdowns set analysis_report=''extra AI report''');
   Finally
    s.Free;
    DB.Free;
   End;
   Before := Hash(Path);
   DB     := TFlightDatabase.Create(Path, TestRuntimeFile('sqlite3.dll'), True, True);
   Try
    ExportLegacyFlight(DB.Connection, IDs[1], OutPath);
    Check(Hash(Path) = Before, 'Read-only source unchanged');
    TargetBefore := Hash(OutPath);
    Failed       := False;
    Try
     ExportLegacyFlight(DB.Connection, 999999, OutPath);
    Except
     Failed := True;
    End;
    Check(Failed And (Hash(OutPath) = TargetBefore), 'Failed export preserves existing destination');
    Failed := False;
    Try
     ExportLegacyFlight(DB.Connection, IDs[1], Path);
    Except
     Failed := True;
    End;
    Check(Failed And (Hash(Path) = Before), 'Cannot overwrite source');
   Finally
    DB.Free;
   End;
   c := TFDConnection.Create(Nil);
   q := TFDQuery.Create(Nil);
   Try
    c.LoginPrompt               := False;
    c.Params.Values['DriverID'] := 'SQLite';
    c.Params.Values['Database'] := OutPath;
    c.Connected                 := True;
    Check(Integer(c.ExecSQLScalar('select count(*) from trips')) = 1, 'Exactly one flight');
    Check(Integer(c.ExecSQLScalar('select id from trips')) = IDs[1], 'Trip identity preserved');
    Check(Integer(c.ExecSQLScalar('select count(*) from trip_data')) = 3, 'Only selected samples');
    Check(Integer(c.ExecSQLScalar('select count(*) from trip_engine_data')) = 6, 'Two engines per selected sample');
    Check(Integer(c.ExecSQLScalar('select count(*) from trip_engine_data where turb_eng_n2 is null')) = 6, 'Missing engine readings stay NULL');
    Check(Integer(c.ExecSQLScalar('select count(*) from trip_events')) = 1, 'Only selected event');
    Check(Integer(c.ExecSQLScalar('select count(*) from trip_liftoffs')) = 1, 'Only selected liftoff');
    Check(Integer(c.ExecSQLScalar('select count(*) from trip_touchdowns')) = 1, 'Only selected touchdown');
    Check(Integer(c.ExecSQLScalar('select count(*) from trip_engine_data e left join trip_data d on e.sample=d.id where d.id is null or e.trip<>d.trip')) = 0, 'Sample keys remain linked');
    Check(String(c.ExecSQLScalar('select title from trips')) = 'Zażółć gęślą 1', 'Unicode metadata preserved');
    Check(String(c.ExecSQLScalar('select name from trip_groups')) = 'Załoga', 'Only referenced group');
    Check(Abs(Double(c.ExecSQLScalar('select turb_eng_n1 from trip_engine_data where engine=1 limit 1')) - 93.812345) < 0.0000001, 'Unrounded raw engine values');
    Check(Integer(c.ExecSQLScalar('select count(*) from trip_touchdowns where analysis_report is not null')) = 0, 'No extended AI reports');
    Check(Integer(c.ExecSQLScalar('select count(*) from sqlite_master where type=''table'' and name not like ''sqlite_%''')) = 7, 'Only seven Qt tables');
    q.Connection := c;
    q.Open('pragma table_info(trip_data)');
    q.FetchAll;
    Check(q.RecordCount = 130, 'Qt trip_data contract has 130 columns');
    q.Close;
    q.Open('select * from trip_data limit 1');
    Check((q.FindField('total_air_temperature') = Nil) And (q.FindField('hsi_cdi_needle') = Nil), 'No extended telemetry columns');
    Check((q.FieldByName('bool_group_1').AsLargeInt And (Int64(1) Shl 18)) <> 0, 'AP master bool preserved');
    q.Close;
    q.Open('select * from trip_engine_data limit 1');
    Check(q.FindField('eng_oil_quantity') = Nil, 'No new oil quantity field');
    q.Close;
    Check(String(c.ExecSQLScalar('pragma integrity_check')) = 'ok', 'Export integrity');
    Check(Integer(c.ExecSQLScalar('pragma user_version')) = 1, 'Qt offset migration version preserved');
   Finally
    q.Free;
    c.Free;
   End;
   // Import the Qt-only schema through the same path used by aImportFlight.
   TargetBefore := Hash(OutPath);
   ImportRoot   := TestDataDirectory + 'qt-library';
   ForceDirectories(ImportRoot);
   Index := TRecordingIndex.Create(TPath.Combine(ImportRoot, 'flight_data.mfzi'), TestRuntimeFile('sqlite3.dll'));
   Try
    Index.Migrate(OutPath);
    Check(Integer(Index.Connection.ExecSQLScalar('select count(*) from trips')) = 1, 'Qt database imports into recording library');
    i            := Index.Connection.ExecSQLScalar('select id from trips limit 1');
    ImportedPath := Index.PathFor(i);
    Check(FileExists(ImportedPath) And SameText(ExtractFileExt(ImportedPath), '.mfzr'), 'Qt flight receives a separate mfzr');
    Imported := TFlightDatabase.Create(ImportedPath, TestRuntimeFile('sqlite3.dll'), True, True);
    Try
     Check(Integer(Imported.Connection.ExecSQLScalar('select count(*) from trips')) = 1, 'Imported file contains only one flight');
     Check(String(Imported.Connection.ExecSQLScalar('select departure_local_time from trips')) = '2026-10-24T14:00:00.000+02:00', 'Current Qt offset is not inverted');
     Check(Integer(Imported.Connection.ExecSQLScalar('select count(*) from trip_engine_data')) = 6, 'Imported engine records preserved');
     Plot := Imported.LoadTrip(IDs[1]);
     Try
      Check(Plot.Points.Count = 3, 'Imported Qt telemetry can be replayed');
      Check(Abs(InstrumentValue(Plot, 0, 'turb_eng_n1 #1') - 93.812345) < 0.0000001, 'Imported engine precision');
      Check(IsNan(InstrumentValue(Plot, 0, 'eng_oil_quantity #1')), 'Unavailable extension remains NaN');
     Finally
      Plot.Free;
     End;
    Finally
     Imported.Free;
    End;
    Index.Migrate(OutPath);
    Check(Integer(Index.Connection.ExecSQLScalar('select count(*) from trips')) = 1, 'Repeated Qt import is idempotent');
   Finally
    Index.Free;
   End;
   Check(Hash(OutPath) = TargetBefore, 'Qt source remains byte-identical during import');
   // Qt's monolithic flight_data.db may contain many flights.
   PartPath  := TestDatabasePath('qt-part.db');
   MultiPath := TestDatabasePath('qt-multiple.db');
   DB        := TFlightDatabase.Create(Path, TestRuntimeFile('sqlite3.dll'), True, True);
   Try
    ExportLegacyFlight(DB.Connection, IDs[0], PartPath);
   Finally
    DB.Free;
   End;
   TFile.Copy(OutPath, MultiPath);
   c := TFDConnection.Create(Nil);
   Try
    c.LoginPrompt               := False;
    c.Params.Values['DriverID'] := 'SQLite';
    c.Params.Values['Database'] := MultiPath;
    c.Connected                 := True;
    c.ExecSQL('attach database :p as part', [PartPath]);
    For TableName In TArray<String>.Create('trips', 'trip_data', 'trip_engine_data', 'trip_events', 'trip_liftoffs', 'trip_touchdowns', 'trip_groups') Do
     c.ExecSQL('insert or ignore into main.' + TableName + ' select * from part.' + TableName);
    c.ExecSQL('detach database part');
   Finally
    c.Free;
   End;
   MultiBefore := Hash(MultiPath);
   ImportRoot  := TestDataDirectory + 'qt-multiple-library';
   ForceDirectories(ImportRoot);
   Index := TRecordingIndex.Create(TPath.Combine(ImportRoot, 'flight_data.mfzi'), TestRuntimeFile('sqlite3.dll'));
   Try
    Index.Migrate(MultiPath);
    Check(Integer(Index.Connection.ExecSQLScalar('select count(*) from trips')) = 2, 'Multiple Qt flights become separate library entries');
    For i := 1 To 2 Do
     Begin
      ImportedPath := Index.PathFor(i);
      Check(FileExists(ImportedPath), 'Each Qt flight has a file');
      Imported := TFlightDatabase.Create(ImportedPath, TestRuntimeFile('sqlite3.dll'), True, True);
      Try
       Check(Integer(Imported.Connection.ExecSQLScalar('select count(*) from trips')) = 1, 'Exactly one trip per imported file');
       Check(Integer(Imported.Connection.ExecSQLScalar('select count(*) from trip_data')) = 3, 'No cross-flight sample leakage');
      Finally
       Imported.Free;
      End;
     End;
    Index.Migrate(MultiPath);
    Check(Integer(Index.Connection.ExecSQLScalar('select count(*) from trips')) = 2, 'Repeated multi-flight import does not duplicate');
   Finally
    Index.Free;
   End;
   Check(Hash(MultiPath) = MultiBefore, 'Multi-flight Qt source remains unchanged');
   // Export over an existing file only after successful completion.
   DB := TFlightDatabase.Create(Path, TestRuntimeFile('sqlite3.dll'), True, True);
   Try
    ExportLegacyFlight(DB.Connection, IDs[0], OutPath);
   Finally
    DB.Free;
   End;
   Check(Hash(Path) = Before, 'Source still unchanged after second export');
   // A corrupt legacy event fails during copying, after target tables and samples were written.
   TargetBefore := Hash(OutPath);
   DB           := TFlightDatabase.Create(Path, TestRuntimeFile('sqlite3.dll'));
   Try
    DB.Connection.ExecSQL('drop table trip_events');
    DB.Connection.ExecSQL('create table trip_events(trip INTEGER,event TEXT,time_zulu TEXT,time_local TEXT,event_seq INTEGER)');
    DB.Connection.ExecSQL('insert into trip_events(trip,event,time_zulu,time_local) values(:t,NULL,''z'',''l'')', [IDs[0]]);
   Finally
    DB.Free;
   End;
   Before := Hash(Path);
   DB     := TFlightDatabase.Create(Path, TestRuntimeFile('sqlite3.dll'), True, True);
   Try
    Failed := False;
    Try
     ExportLegacyFlight(DB.Connection, IDs[0], OutPath);
    Except
     On E : Exception Do
      Begin
       System.Writeln('Expected export failure: ', E.Message);
       Failed := True;
      End;
    End;
    Check(Failed And (Hash(OutPath) = TargetBefore), 'Mid-copy constraint failure preserves old destination');
    Check(Hash(Path) = Before, 'Failure never changes source');
   Finally
    DB.Free;
   End;
   Check(Length(TDirectory.GetFiles(TestDataDirectory, 'legacy.db.*.tmp')) = 0, 'No failed temporary exports remain');
   System.Writeln('PASS: Qt single/multi-flight import and replay, offsets, deduplication, one-flight export schema, engine/sample links, ' +
   'event/contacts/group filtering, Unicode, raw precision, dropped extras/reports, readonly source hash, atomic replace and rejected source overwrite. Synthetic only.');
  Except
   On E : Exception Do
    Begin
     System.Writeln(E.ClassName + ': ' + E.Message);
     Raise Exception.Create('Regression failed; see diagnostic above');
    End;
  End;

 End;

Begin
 RunNativeTests(TVerifyLegacyExportTests);

End.
