{$StackFrames On}
Unit RecordingIndexU;

Interface

 Uses
  Winapi.Windows, System.SysUtils, System.Classes, System.DateUtils,
  FireDAC.Comp.Client, FireDAC.Phys.SQLite;

 Type
  TRecordingIndex = Class
   Private
    fDB     : TFDConnection;
    fDriver : TFDPhysSQLiteDriverLink;
    fRoot   : String;
    fDLL    : String;
   Public
    Constructor Create(Const Path, SQLiteDLL : String);
    Destructor Destroy; Override;
    Function Reserve(Const StartedUTC : String) : Integer;
    Procedure Sync(ID, LocalID : Integer; Source : TFDConnection; Const Status : String);
    Function Resolve(Const RelativePath : String) : String;
    Function RecordingPath(ID : Integer) : String;
    Function PathFor(ID : Integer) : String;
    Procedure SetPath(ID : Integer; Const RelativePath : String);
    Procedure SetStatus(ID : Integer; Const Status : String);
    Function Recover(ID : Integer; Out Error : String) : Boolean;
    Procedure Migrate(Const LegacyPath : String);
    Procedure Discover(Const Directory : String; Recursive : Boolean = True);
    Procedure RepairPlanMetadata;
    Property Connection : TFDConnection Read fDB;
    Property Root       : String Read fRoot;
  End;

 Function RecordingAircraftCode(Const Model, Title : String) : String;
 Function RecordingCode(Const Value : String) : String;
 Function RecordingTime(Const ISO : String) : TDateTime;

Implementation

 Uses
  System.Hash, System.IOUtils, System.Variants, Data.DB, FireDAC.Stan.Param,
  FireDAC.Phys.SQLiteWrapper, FireDAC.Phys.SQLiteDef, FireDAC.Stan.Def, FireDAC.DApt, FlightDatabaseU, FlightPlanU, ProcedureRouteU;

 Const
  MetadataFields = 'title,atc_airline,atc_flight_number,atc_id,atc_model,atc_type,' + 'departure_latitude,departure_longitude,departure_icao,departure_name,departure_region,departure_rwy,' + 'departure_zulu_time,departure_local_time,destination_latitude,destination_longitude,destination_icao,' + 'destination_name,destination_region,destination_rwy,destination_zulu_time,destination_local_time';

 Function RecordingAircraftCode(Const Model, Title : String) : String;
  Var
   s : String;
   t : String;
   c : Char;

   Function Has(Const Token : String) : Boolean;
    Begin
     Result := Pos(Token, t) > 0;
    End;

  Begin
   s := UpperCase(Trim(Model));
   If (Length(s) >= 2) And (Length(s) <= 4) And CharInSet(s[1], ['A'..'Z']) Then
    Begin
     Result := s;
     For c In s Do
      If Not CharInSet(c, ['A'..'Z', '0'..'9']) Then
       Result := '';
     If (Result <> '') And (Result <> 'NONE') And (Result <> 'NULL') And (RecordingCode(Result) = Result) Then
      Exit;
    End;
   t := UpperCase(Title).Replace(' ', '').Replace('-', '').Replace('_', '');
   If Has('737MAX8') Or Has('7378MAX') Or Has('B38M') Then
    Result := 'B38M'
   Else If Has('737MAX9') Or Has('B39M') Then
    Result := 'B39M'
   Else If Has('737800') Or Has('B738') Then
    Result := 'B738'
   Else If Has('737300') Or Has('B733') Then
    Result := 'B733'
   Else If Has('737400') Or Has('B734') Then
    Result := 'B734'
   Else If Has('737500') Or Has('B735') Then
    Result := 'B735'
   Else If Has('737700') Or Has('B737') Then
    Result := 'B737'
   Else If Has('737600') Or Has('B736') Then
    Result := 'B736'
   Else If Has('A32NX') Or Has('A320NEO') Or Has('A20N') Then
    Result := 'A20N'
   Else If Has('A321NEO') Or Has('A21N') Then
    Result := 'A21N'
   Else If Has('A319') Then
    Result := 'A319'
   Else If Has('A321') Then
    Result := 'A321'
   Else If Has('A320') Then
    Result := 'A320'
   Else If Has('777300') Or Has('77W') Then
    Result := 'B77W'
   Else If Has('DC6') Then
    Result := 'DC6'
   Else If Has('MD11') Then
    Result := 'MD11'
   Else If Has('C172') Then
    Result := 'C172'
   Else
    Result := 'UNKNOWN';
  End;

 Function RecordingTime(Const ISO : String) : TDateTime;
  Begin
   If Not TryISO8601ToDate(ISO, Result, True) Then
    Raise EConvertError.Create('Invalid recording start timestamp: ' + ISO);
  End;

 Function RecordingCode(Const Value : String) : String;
  Var
   c : Char;
  Begin
   Result := '';
   For c In UpperCase(Trim(Value)) Do
    If CharInSet(c, ['A'..'Z', '0'..'9']) Then
     Result := Result + c;
   If Result = '' Then
    Result := 'UNKNOWN';
   Result  := Copy(Result, 1, 16);
   // Never allow a Windows device name as a directory component.
   If (Result = 'CON') Or (Result = 'PRN') Or (Result = 'AUX') Or (Result = 'NUL') Or ((Length(Result) = 4) And ((Copy(Result, 1, 3) = 'COM') Or (Copy(Result, 1, 3) = 'LPT')) And CharInSet(Result[4], ['0'..'9'])) Then
    Result := '_' + Result;
  End;

 Constructor TRecordingIndex.Create(Const Path, SQLiteDLL : String);
  Begin
   Inherited Create;
   fRoot := ExtractFileDir(ExpandFileName(Path));
   fDLL  := SQLiteDLL;
   ForceDirectories(fRoot);
   fDriver                          := TFDPhysSQLiteDriverLink.Create(Nil);
   fDriver.VendorLib                := SQLiteDLL;
   fDB                              := TFDConnection.Create(Nil);
   fDB.LoginPrompt                  := False;
   fDB.ResourceOptions.SilentMode   := True;
   fDB.Params.Values['DriverID']    := 'SQLite';
   fDB.Params.Values['Database']    := Path;
   fDB.Params.Values['LockingMode'] := 'Normal';
   fDB.Params.Values['SharedCache'] := 'False';
   fDB.Params.Values['JournalMode'] := 'WAL';
   fDB.Connected                    := True;
   fDB.ExecSQL('pragma busy_timeout=5000');
   fDB.ExecSQL('pragma journal_mode=WAL');
   fDB.ExecSQL('create table if not exists trips (id integer primary key autoincrement,' + 'local_trip_id integer,started_utc text not null,relative_path text,pending_path text,' + 'status text not null check(status in (''recording'',''finalizing'',''completed'',''interupted'',''error'')),' + 'recovery_pending integer not null default 0,source_key text unique collate nocase,group_id integer,' + 'title text,atc_airline text,atc_flight_number text,atc_id text,atc_model text,atc_type text,' +
   'departure_latitude real,departure_longitude real,departure_icao text,departure_name text,' + 'departure_region text,departure_rwy text,departure_zulu_time text,departure_local_time text,' + 'destination_latitude real,destination_longitude real,destination_icao text,destination_name text,' + 'destination_region text,destination_rwy text,destination_zulu_time text,destination_local_time text)');
   fDB.ExecSQL('create table if not exists trip_groups(id integer primary key autoincrement,name text not null,sort_order integer not null default 0)');
   fDB.ExecSQL('create table if not exists migrations(source text primary key collate nocase,finished integer not null default 0)');
   fDB.ExecSQL('create index if not exists idx_recordings_started on trips(started_utc desc,id desc)');
  End;

 Destructor TRecordingIndex.Destroy;
  Begin
   fDB.Free;
   fDriver.Free;
   Inherited;
  End;

 Function TRecordingIndex.Reserve(Const StartedUTC : String) : Integer;
  Begin
   RecordingTime(StartedUTC);
   fDB.ExecSQL('insert into trips(started_utc,status,recovery_pending) values(:u,''recording'',1)', [DateToISO8601(RecordingTime(StartedUTC), True)]);
   Result := fDB.ExecSQLScalar('select last_insert_rowid()');
  End;

 Procedure TRecordingIndex.Sync(ID, LocalID : Integer; Source : TFDConnection; Const Status : String);
  Var
   q      : TFDQuery;
   u      : TFDQuery;
   Fields : TStringList;
   i      : Integer;
   SQL    : String;
  Begin
   q      := TFDQuery.Create(Nil);
   u      := TFDQuery.Create(Nil);
   Fields := TStringList.Create;
   Try
    Fields.CommaText := MetadataFields;
    q.Connection     := Source;
    q.Open('select ' + MetadataFields + ' from trips where id=:id', [LocalID]);
    If q.IsEmpty Then
     Raise Exception.Create('Recording trip metadata missing');
    SQL                                 := 'update trips set local_trip_id=:local_id,status=:status';
    For i                               := 0 To Fields.Count - 1 Do
     SQL                                := SQL + ',' + Fields[i] + '=:p' + IntToStr(i);
    u.Connection                        := fDB;
    u.SQL.Text                          := SQL + ' where id=:id';
    u.ParamByName('local_id').AsInteger := LocalID;
    u.ParamByName('status').AsString    := Status;
    u.ParamByName('id').AsInteger       := ID;
    For i                               := 0 To Fields.Count - 1 Do
     Begin
      u.ParamByName('p' + IntToStr(i)).DataType := q.Fields[i].DataType;
      u.ParamByName('p' + IntToStr(i)).Value    := q.Fields[i].Value;
     End;
    u.ExecSQL;
   Finally
    Fields.Free;
    u.Free;
    q.Free;
   End;
  End;

 Function TRecordingIndex.Resolve(Const RelativePath : String) : String;
  Var
   Prefix : String;
  Begin
   If (RelativePath = '') Or TPath.IsPathRooted(RelativePath) Then
    Raise Exception.Create('Invalid recording relative path');
   Prefix := IncludeTrailingPathDelimiter(TPath.GetFullPath(fRoot));
   Result := TPath.GetFullPath(TPath.Combine(fRoot, RelativePath));
   If Not SameText(Copy(Result, 1, Length(Prefix)), Prefix) Then
    Raise Exception.Create('Recording path escapes storage directory');
  End;

 Function TRecordingIndex.PathFor(ID : Integer) : String;
  Var
   v : Variant;
  Begin
   v      := fDB.ExecSQLScalar('select relative_path from trips where id=:id', [ID]);
   Result := '';
   If Not VarIsNull(v) And Not VarIsEmpty(v) And (VarToStr(v) <> '') Then
    Result := Resolve(VarToStr(v));
  End;

 Procedure TRecordingIndex.SetPath(ID : Integer; Const RelativePath : String);
  Begin
   Resolve(RelativePath);
   fDB.ExecSQL('update trips set relative_path=:p,pending_path=null where id=:id', [RelativePath, ID]);
  End;

 Procedure TRecordingIndex.SetStatus(ID : Integer; Const Status : String);
  Begin
   fDB.ExecSQL('update trips set status=:s,recovery_pending=:r where id=:id', [Status, Ord((Status = 'recording') Or (Status = 'finalizing')), ID]);
  End;

 Function TRecordingIndex.RecordingPath(ID : Integer) : String;
  Var
   q        : TFDQuery;
   d        : TDateTime;
   a        : String;
   Dep      : String;
   Arr      : String;
   Base     : String;
   Occupied : Variant;
  Begin
   q := TFDQuery.Create(Nil);
   Try
    q.Connection := fDB;
    q.Open('select * from trips where id=:id', [ID]);
    If q.IsEmpty Then
     Raise Exception.Create('Unknown recording');
    d        := RecordingTime(q.FieldByName('started_utc').AsString);
    a        := RecordingAircraftCode(q.FieldByName('atc_model').AsString, q.FieldByName('title').AsString);
    Dep      := RecordingCode(q.FieldByName('departure_icao').AsString);
    Arr      := RecordingCode(q.FieldByName('destination_icao').AsString);
    Base     := 'Recordings\' + a + '\' + Dep + '\' + FormatDateTime('yyyy\mm', d) + '\' + FormatDateTime('yyyy-mm-dd_hh-nn-ss', d) + '-' + Dep + '-' + Arr + '_' + a;
    Result   := Base + '.mfzr';
    Occupied := fDB.ExecSQLScalar('select id from trips where relative_path=:p and id<>:id', [Result, ID]);
    If (Not VarIsNull(Occupied) And Not VarIsEmpty(Occupied)) Or (FileExists(Resolve(Result)) And Not SameText(PathFor(ID), Resolve(Result))) Then
     Result := Base + '-' + IntToStr(ID) + '.mfzr';
   Finally
    q.Free;
   End;
  End;

 Function TRecordingIndex.Recover(ID : Integer; Out Error : String) : Boolean;
  Var
   DB      : TFlightDatabase;
   q       : TFDQuery;
   Path    : String;
   Pending : String;
   LocalID : Integer;
  Begin
   Result := False;
   Error  := '';
   DB     := Nil;
   q      := TFDQuery.Create(Nil);
   Try
    Try
     q.Connection := fDB;
     q.Open('select * from trips where id=:id', [ID]);
     If q.IsEmpty Then
      Raise Exception.Create('Unknown recording');
     Path    := PathFor(ID);
     Pending := q.FieldByName('pending_path').AsString;
     // A crash between rename and the index commit must not orphan a valid file.
     If (Not FileExists(Path)) And (Pending <> '') And FileExists(Resolve(Pending)) Then
      Begin
       SetPath(ID, Pending);
       Path := Resolve(Pending);
      End;
     If Not FileExists(Path) Then
      Raise Exception.Create('Recording file missing: ' + Path);
     LocalID := q.FieldByName('local_trip_id').AsInteger;
     DB      := TFlightDatabase.Create(Path, fDLL, True);
     If VarToStr(DB.Connection.ExecSQLScalar('pragma quick_check')) <> 'ok' Then
      Raise Exception.Create('SQLite integrity check failed');
     If Integer(DB.Connection.ExecSQLScalar('select count(*) from trips')) <> 1 Then
      Raise Exception.Create('Recording must contain exactly one trip');
     If LocalID = 0 Then
      LocalID := DB.Connection.ExecSQLScalar('select id from trips');
     Sync(ID, LocalID, DB.Connection, 'interupted');
     If Integer(DB.Connection.ExecSQLScalar('pragma wal_checkpoint(TRUNCATE)')) <> 0 Then
      Raise Exception.Create('SQLite checkpoint is busy');
     SetStatus(ID, 'interupted');
     Result := True;
    Except
     On E : Exception Do
      Begin
       Error := E.Message;
       SetStatus(ID, 'error');
      End;
    End;
   Finally
    DB.Free;
    q.Free;
   End;
  End;

// Copy rows directly inside SQLite: no telemetry is decoded/re-encoded, including
// BLOBs and tables unknown to this version. Indexes/triggers are installed last.

 Procedure ExtractRecording(Source : TFDConnection; Const Snapshot, Target : String; Trip : Integer);
  Var
   Destination : TFDConnection;
   Schema      : TFDQuery;
   Info        : TFDQuery;
   Name        : String;
   Columns     : String;
   Predicate   : String;
   SQL         : String;
   HasTrip     : Boolean;

   Function Quoted(Const Value : String) : String;
    Begin
     Result := '"' + StringReplace(Value, '"', '""', [rfReplaceAll]) + '"';
    End;

  Begin
   If FileExists(Target) Then
    TFile.Delete(Target);
   // No connection has opened this unpublished file yet; remove abandoned journals on retry.
   If FileExists(Target + '-wal') Then
    TFile.Delete(Target + '-wal');
   If FileExists(Target + '-shm') Then
    TFile.Delete(Target + '-shm');
   Destination := TFDConnection.Create(Nil);
   Schema      := TFDQuery.Create(Nil);
   Info        := TFDQuery.Create(Nil);
   Try
    Destination.LoginPrompt                  := False;
    Destination.ResourceOptions.SilentMode   := True;
    Destination.Params.Values['DriverID']    := 'SQLite';
    Destination.Params.Values['Database']    := Target;
    Destination.Params.Values['SharedCache'] := 'False';
    Destination.Params.Values['LockingMode'] := 'Normal';
    Destination.Params.Values['JournalMode'] := 'WAL';
    Destination.Connected                    := True;
    Destination.ExecSQL('pragma busy_timeout=5000');
    Destination.ExecSQL('attach database :p as source', [Snapshot]);
    Schema.Connection := Source;
    Info.Connection   := Source;
    Schema.Open('select name,sql from sqlite_master where type=''table'' and name not like ''sqlite_%'' and sql is not null order by name');
    Destination.StartTransaction;
    Try
     While Not Schema.Eof Do
      Begin
       Name := Schema.FieldByName('name').AsString;
       Destination.ExecSQL(Schema.FieldByName('sql').AsString);
       Info.Open('pragma table_info(' + Quoted(Name) + ')');
       Columns := '';
       HasTrip := False;
       While Not Info.Eof Do
        Begin
         If Columns <> '' Then
          Columns := Columns + ',';
         Columns  := Columns + Quoted(Info.FieldByName('name').AsString);
         If SameText(Info.FieldByName('name').AsString, 'trip') Then
          HasTrip := True;
         Info.Next;
        End;
       Info.Close;
       Predicate := '';
       If SameText(Name, 'trips') Then
        Predicate := ' where id=:trip'
       Else If HasTrip Then
        Predicate := ' where trip=:trip';
       SQL        := 'insert into main.' + Quoted(Name) + '(' + Columns + ') select ' + Columns + ' from source.' + Quoted(Name) + Predicate;
       If Predicate = '' Then
        Destination.ExecSQL(SQL)
       Else
        Destination.ExecSQL(SQL, [Trip]);
       Schema.Next;
      End;
     Schema.Close;
     Schema.Open('select sql from sqlite_master where type in (''index'',''view'',''trigger'') and sql is not null order by case type when ''index'' then 0 when ''view'' then 1 else 2 end');
     While Not Schema.Eof Do
      Begin
       Destination.ExecSQL(Schema.Fields[0].AsString);
       Schema.Next;
      End;
     Schema.Close;
     Destination.Commit;
    Except
     Destination.Rollback;
     Raise;
    End;
    Destination.ExecSQL('pragma user_version=' + IntToStr(Integer(Source.ExecSQLScalar('pragma user_version'))));
    Destination.ExecSQL('detach database source');
    If Integer(Destination.ExecSQLScalar('select count(*) from trips')) <> 1 Then
     Raise Exception.Create('Migration must produce one trip');
    If VarToStr(Destination.ExecSQLScalar('pragma quick_check')) <> 'ok' Then
     Raise Exception.Create('Migration integrity check failed');
    If Integer(Destination.ExecSQLScalar('pragma wal_checkpoint(TRUNCATE)')) <> 0 Then
     Raise Exception.Create('Migration checkpoint is busy');
   Finally
    Info.Free;
    Schema.Free;
    Destination.Free;
   End;
  End;

 Procedure TRecordingIndex.RepairPlanMetadata;
  Var
   q    : TFDQuery;
   p    : TFDQuery;
   c    : TFDConnection;
   Plan : TFlightPlan;
   Path : String;
  Begin
   q := TFDQuery.Create(Nil);
   p := TFDQuery.Create(Nil);
   c := TFDConnection.Create(Nil);
   Try
    q.Connection := fDB;
    q.Open('select id,local_trip_id,relative_path from trips where status not in (''recording'',''finalizing'') and (destination_icao is null or destination_icao='''' or destination_icao=''UNKNOWN'')');
    c.DriverName                   := 'SQLite';
    c.LoginPrompt                  := False;
    c.Params.Values['OpenMode']    := 'ReadOnly';
    c.Params.Values['JournalMode'] := 'WAL';
    c.Params.Values['LockingMode'] := 'Normal';
    c.Params.Values['SharedCache'] := 'False';
    p.Connection                   := c;
    While Not q.Eof Do
     Begin
      Path := Resolve(q.FieldByName('relative_path').AsString);
      If FileExists(Path) Then
       Try
        c.Params.Values['Database'] := Path;
        c.Connected                 := True;
        p.Open('select name from sqlite_master where type=''table'' and name=''trip_flight_plans''');
        If Not p.IsEmpty Then
         Begin
          p.Close;
          p.Open('select format,payload,path from trip_flight_plans where trip=:t order by id desc limit 1', [q.FieldByName('local_trip_id').AsInteger]);
          If Not p.IsEmpty Then
           Begin
            Plan := DecodeRecordedPlan(p.FieldByName('format').AsString, p.FieldByName('payload').AsString, p.FieldByName('path').AsString);
            Try
             If (Length(Plan.DestinationICAO) = 4) And (Plan.DestinationICAO <> 'ZZZZ') Then
              fDB.ExecSQL('update trips set destination_icao=:a where id=:i', [Plan.DestinationICAO, q.FieldByName('id').AsInteger]);
            Finally
             Plan.Free;
            End;
           End;
         End;
       Except
        On E : Exception Do
         Begin
          OutputDebugString(PChar('Recording plan metadata: ' + E.Message));
         End;
       End;
      p.Close;
      c.Connected := False;
      q.Next;
     End;
   Finally
    p.Free;
    c.Free;
    q.Free;
   End;
  End;

 Procedure TRecordingIndex.Discover(Const Directory : String; Recursive : Boolean);
  Var
   Path     : String;
   Relative : String;
   Option   : TSearchOption;
  Begin
   If Not TDirectory.Exists(Directory) Then
    Exit;
   RepairPlanMetadata;
   Option := TSearchOption.soTopDirectoryOnly;
   If Recursive Then
    Option := TSearchOption.soAllDirectories;
   For Path In TDirectory.GetFiles(Directory, '*.mfzr', Option) Do
    Begin
     Relative := ExtractRelativePath(IncludeTrailingPathDelimiter(fRoot), Path);
     If Integer(fDB.ExecSQLScalar('select count(*) from trips where relative_path=:p or pending_path=:p', [Relative])) > 0 Then
      Continue;
     // Foreign files are validated on an isolated SQLite snapshot by Migrate.
     Try
      Migrate(Path);
     Except
      On E : Exception Do
       OutputDebugString(PChar('Recording discovery: ' + Path + ': ' + E.Message));
     End;
    End;
  End;

 Procedure TRecordingIndex.Migrate(Const LegacyPath : String);
  Var
   Backup    : TFDSQLiteBackup;
   Snapshot  : String;
   Target    : String;
   Relative  : String;
   SourceKey : String;
   Started   : String;
   DB        : TFlightDatabase;
   q         : TFDQuery;
   ID        : Integer;
   LocalID   : Integer;
   Status    : String;
   Done      : Variant;
  Begin
   If Not FileExists(LegacyPath) Then
    Exit;
   If SameText(ExtractFileExt(LegacyPath), '.mfzr') Then
    Begin
     Relative := ExtractRelativePath(IncludeTrailingPathDelimiter(fRoot), ExpandFileName(LegacyPath));
     If Integer(fDB.ExecSQLScalar('select count(*) from trips where relative_path=:p or pending_path=:p', [Relative])) > 0 Then
      Exit;
    End;

   Snapshot := TPath.Combine(fRoot, 'legacy-migration-' + Copy(THashSHA2.GetHashString(LowerCase(ExpandFileName(LegacyPath))), 1, 16) + '.snapshot');
   // A replaced single-file import must not reuse an earlier invalid snapshot.
   If SameText(ExtractFileExt(LegacyPath), '.mfzr') And FileExists(Snapshot) Then
    TFile.Delete(Snapshot);
   // SQLite online backup includes committed WAL pages. The source is never modified.
   If Not FileExists(Snapshot) Then
    Begin
     Backup := TFDSQLiteBackup.Create(Nil);
     Try
      Backup.DriverLink   := fDriver;
      Backup.Database     := LegacyPath;
      Backup.DestDatabase := Snapshot + '.partial';
      Backup.DestMode     := smCreate;
      Backup.Backup;
      TFile.Move(Snapshot + '.partial', Snapshot);
     Finally
      Backup.Free;
     End;
    End;
   DB := TFlightDatabase.Create(Snapshot, fDLL);
   q  := TFDQuery.Create(Nil);
   Try
    q.Connection := DB.Connection;
    If SameText(ExtractFileExt(LegacyPath), '.mfzr') And (Integer(DB.Connection.ExecSQLScalar('select count(*) from trips')) <> 1) Then
     Raise Exception.Create('A recording file must contain exactly one trip');
    // Group membership is remapped by name, including imports into an existing index.
    q.Open('select * from trip_groups');
    While Not q.Eof Do
     Begin
      fDB.ExecSQL('insert into trip_groups(name,sort_order) select :n,:s where not exists(select 1 from trip_groups where name=:n)', [q.FieldByName('name').AsString, q.FieldByName('sort_order').AsInteger]);
      q.Next;
     End;
    q.Close;
    q.Open('select * from trips order by id');
    While Not q.Eof Do
     Begin
      LocalID   := q.FieldByName('id').AsInteger;
      SourceKey := ExpandFileName(LegacyPath) + '|' + IntToStr(LocalID);
      Done      := fDB.ExecSQLScalar('select id from trips where source_key=:k', [SourceKey]);
      If VarIsNull(Done) Or VarIsEmpty(Done) Then
       Begin
        Started := q.FieldByName('departure_zulu_time').AsString;
        RecordingTime(Started);
        ID := Reserve(Started);
        fDB.ExecSQL('update trips set source_key=:k where id=:id', [SourceKey, ID]);
       End
      Else
       ID := Done;
      If (PathFor(ID) <> '') And FileExists(PathFor(ID)) Then
       Begin
        q.Next;
        Continue;
       End;
      Sync(ID, LocalID, DB.Connection, 'finalizing');
      fDB.ExecSQL('update trips set group_id=(select g.id from trip_groups g where g.name=:n) where id=:id', [VarToStr(DB.Connection.ExecSQLScalar('select g.name from trip_groups g join trips t on t.group_id=g.id where t.id=:id', [LocalID])), ID]);
      Relative := RecordingPath(ID);
      Target   := Resolve(Relative);
      ForceDirectories(ExtractFileDir(Target));
      fDB.ExecSQL('update trips set relative_path=:p where id=:id', [Relative, ID]);
      ExtractRecording(DB.Connection, Snapshot, Target + '.partial', LocalID);
      TFile.Move(Target + '.partial', Target);
      Status := 'completed';
      If q.FieldByName('destination_zulu_time').IsNull Or (q.FieldByName('destination_zulu_time').AsString = '') Then
       Status := 'interupted';
      SetStatus(ID, Status);
      If Status = 'interupted' Then
       fDB.ExecSQL('update trips set recovery_pending=1 where id=:id', [ID]);
      q.Next;
     End;
    fDB.ExecSQL('insert or replace into migrations(source,finished) values(:p,1)', [ExpandFileName(LegacyPath)]);
   Finally
    q.Free;
    DB.Free;
   End;
   // Keep the legacy source as the backup; the temporary full snapshot is no longer needed.
   DeleteFile(PChar(Snapshot));
  End;

End.
