{$StackFrames On}
Unit FlightDatabaseU;

Interface

 Uses
  RecordingIndexU, LocalizationU, System.Variants, System.SysUtils, System.Classes, System.Math, System.DateUtils,
  System.Generics.Collections, System.JSON,
  Data.DB, FireDAC.Comp.Client, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.Def, FireDAC.Stan.Async, FireDAC.Stan.Param, FireDAC.DApt, FireDAC.VCLUI.Wait, FireDAC.Comp.UI,
  TelemetryCatalogU, FlightTelemetryU, LegacyMigrationU, FlightPlanU, AircraftDataStoreU,
  iFlySDKCatalogU, FenixCatalogU, FBWCatalogU, PMDGNG3CatalogU, PMDG777CatalogU, AddonLVarCatalogU, FMCScreensU;

 Type
  TPlotPoint = Record
   Lat         : Double;
   Lon         : Double;
   Seconds     : Double;
   Time        : String;
   Values      : TArray<Double>;
   BreakBefore : Boolean;
   GroupID     : Integer;
  End;

  TContactView = Record
   Lat         : Double;
   Lon         : Double;
   Kind        : String;
   Time        : String;
   Description : String;
  End;

  TPlotLabels = Class(TStringList)
   Private
    fRevision : UInt64;
   Protected
    Procedure Changed; Override;
   Public
    Property Revision : UInt64 Read fRevision;
  End;

  TTripPlot = Class
   Private
    fDisplayPoint    : TPlotPoint;
    fDisplayIndex    : Integer;
    fHasDisplayPoint : Boolean;
   Public
    Points                 : TList<TPlotPoint>;
    Labels                 : TPlotLabels;
    Contacts               : TList<TContactView>;
    TripID                 : Integer;
    AircraftTitle          : String;
    FlightNumber           : String;
    Airline                : String;
    Registration           : String;
    Selcal                 : String;
    RecordedStartTime      : String;
    SamplingIntervalMS     : Integer;
    SamplingIntervalSource : String;
    AircraftTypeICAO       : String;
    FlightPlan             : TFlightPlan;
    Constructor Create;
    Destructor Destroy; Override;
    Function DisplayPoint(Index : Integer) : TPlotPoint;
    Procedure ClearDisplayPoint;
    Procedure ResolveSamplingInterval(StoredMS : Integer = 0);
    Procedure SetDisplayPoint(Index : Integer; Const p : TPlotPoint);
  End;

  TFlightDatabase = Class
   Private
    fIndex            : TRecordingIndex;
    fIndexID          : Integer;
    fMetadataNext     : UInt64;
    fStoragePath      : String;
    fSQLiteDLL        : String;
    fReadOnly         : Boolean;
    fLastAircraft     : TJSONObject;
    fLastAircraftTrip : Integer;
    fDriver           : TFDPhysSQLiteDriverLink;
    fWait             : TFDGUIxWaitCursor;
    fDB               : TFDConnection;
    fSample           : TFDQuery;
    fEngine           : TFDQuery;
    Procedure InitializeStorage(Const FileName : String; Background : Boolean);
    Procedure SaveAircraft(ID : Integer; Row : Int64; s : TFlightSample);
    Procedure EnsureTable(Const Table, Fields : String);
    Function ContactFields(Touchdown : Boolean) : String;
   Public
    Constructor Create(Const FileName, SQLiteDLL : String; Background : Boolean = False; ReadOnly : Boolean = False);
    Destructor Destroy; Override;
    Function StartTrip(s : TFlightSample; SamplingIntervalMS : Integer = 0) : Integer;
    Procedure EndTrip(ID : Integer; s : TFlightSample);
    Procedure FinalizeRecording;
    Procedure RefreshRecordingMetadata;
    Procedure RecordingError;
    Property RecordingIndex : TRecordingIndex Read fIndex;
    Procedure RecordSample(ID : Integer; s : TFlightSample);
    Function Contact(ID : Integer; s : TFlightSample; Touchdown : Boolean) : Integer;
    Procedure Event(ID : Integer; Const Name, Zulu, Local : String; Seq : Int64);
    Procedure Retract(Seq : Int64);
    Procedure SaveFlightPlan(ID : Integer; Plan : TFlightPlan);
    Procedure DeleteTrip(ID : Integer);
    Function LoadTrip(ID : Integer) : TTripPlot;
    Procedure ExportKML(ID : Integer; Const FileName : String);
    Property Connection : TFDConnection Read fDB;
  End;

Implementation

 Uses
  ProcedureRouteU,
  Winapi.Windows, iFlyDisplaysU, FSHudDataU, GSXVarsU, AirlinerVarsU, AirlinerCatalogU;

 Procedure TFlightDatabase.SaveAircraft(ID : Integer; Row : Int64; s : TFlightSample);
  Var
   Current : TJSONObject;
   Delta   : TJSONObject;
   SDK     : TJSONObject;
   Reset   : Boolean;
   Payload : String;

   Function ProviderOf(o : TJSONObject) : String;
    Var
     v : TJSONValue;
    Begin
     Result := '';
     v      := o.GetValue('aircraft_sdk');
     If v Is TJSONObject Then
      Begin
       v := TJSONObject(v).GetValue('provider');
       If v <> Nil Then
        Result := v.Value;
      End;
    End;

  Begin
   Current := TJSONObject.Create;
   Try
    If s.AircraftData <> Nil Then
     Begin
      SDK := TJSONObject.ParseJSONValue(s.AircraftData.ToJSON) As TJSONObject;
      CompactIFlySDK(SDK);
      If (SDK.GetValue('provider') <> Nil) And (SDK.GetValue('provider').Value = 'iFly737MAX') And (SDK.GetValue('fields') Is TJSONObject) Then
       TJSONObject(SDK.GetValue('fields')).RemovePair('Tick18').Free;
      Current.AddPair('aircraft_sdk', SDK);
     End
    Else
     Current.AddPair('aircraft_sdk', TJSONNull.Create);
    If s.DataSources <> Nil Then
     Current.AddPair('overrides', TJSONObject.ParseJSONValue(s.DataSources.ToJSON))
    Else
     Current.AddPair('overrides', TJSONNull.Create);
    If s.FSHudDataU <> Nil Then
     Current.AddPair('fshud', TJSONObject.ParseJSONValue(s.FSHudDataU.ToJSON));
    If s.GSXData <> Nil Then
     Current.AddPair('gsx_lvars', TJSONObject.ParseJSONValue(s.GSXData.ToJSON));
    If s.AirlinerData <> Nil Then
     Current.AddPair('airliner_lvars', TJSONObject.ParseJSONValue(s.AirlinerData.ToJSON));
    Reset := (fLastAircraft = Nil) Or (fLastAircraftTrip <> ID);
    If Not Reset Then
     Reset := ProviderOf(Current) <> ProviderOf(fLastAircraft);
    If Not Reset Then
     Reset := (Current.GetValue('aircraft_sdk') Is TJSONNull) <> (fLastAircraft.GetValue('aircraft_sdk') Is TJSONNull);
    If Not Reset Then
     Reset := (Pos('unavailable_simconnect_fallback', Current.ToJSON) > 0) <> (Pos('unavailable_simconnect_fallback', fLastAircraft.ToJSON) > 0);
    If Reset Then
     Delta := JSONDelta(Current, Nil)
    Else
     Delta := JSONDelta(Current, fLastAircraft);
    Try
     If Reset Or (Delta.Count > 0) Then
      Begin
       Payload := Delta.ToJSON;
       fDB.ExecSQL('insert into trip_aircraft_data(trip,sample,reset_state,payload) values(:t,:s,:r,:p)', [ID, Row, Ord(Reset), Payload]);
      End;
    Finally
     Delta.Free;
    End;
    fLastAircraft.Free;
    fLastAircraft     := Current;
    Current           := Nil;
    fLastAircraftTrip := ID;
   Finally
    Current.Free;
   End;
  End;

 Procedure TPlotLabels.Changed;
  Begin
   Inc(fRevision);
   Inherited;
  End;

 Procedure TTripPlot.SetDisplayPoint(Index : Integer; Const p : TPlotPoint);
  Begin
   fDisplayPoint    := p;
   fDisplayIndex    := Index;
   fHasDisplayPoint := True;
  End;

 Procedure TTripPlot.ClearDisplayPoint;
  Begin
   fHasDisplayPoint := False;
   fDisplayPoint    := Default(TPlotPoint);
  End;

 Function TTripPlot.DisplayPoint(Index : Integer) : TPlotPoint;
  Begin
   If fHasDisplayPoint And (Index = fDisplayIndex) Then
    Result := fDisplayPoint
   Else
    Result := Points[Index];
  End;

 Constructor TTripPlot.Create;
  Begin
   Inherited;
   SamplingIntervalMS     := 500;
   SamplingIntervalSource := 'fallback';
   Points                 := TList<TPlotPoint>.Create;
   Labels                 := TPlotLabels.Create;
   Contacts               := TList<TContactView>.Create;
  End;

 Procedure TTripPlot.ResolveSamplingInterval(StoredMS : Integer);
  Var
   Deltas : TArray<Double>;
   i      : Integer;
   n      : Integer;
   d      : Double;
  Begin
   SamplingIntervalMS     := 500;
   SamplingIntervalSource := 'fallback';
   If (StoredMS >= 1) And (StoredMS <= 60000) Then
    Begin
     SamplingIntervalMS     := StoredMS;
     SamplingIntervalSource := 'stored';
     Exit;
    End;
   SetLength(Deltas, Max(0, Points.Count - 1));
   n     := 0;
   For i := 1 To Points.Count - 1 Do
    Begin
     d := (Points[i].Seconds - Points[i - 1].Seconds) * 1000;
     If Not IsNan(d) And Not IsInfinite(d) And (d >= 1) And (d <= 60000) Then
      Begin
       Deltas[n] := d;
       Inc(n);
      End;
    End;
   If n = 0 Then
    Exit;
   SetLength(Deltas, n);
   TArray.Sort<Double>(Deltas);
   d := Deltas[n Div 2];
   If n Mod 2 = 0 Then
    d                     := (d + Deltas[n Div 2 - 1]) / 2;
   SamplingIntervalMS     := EnsureRange(Round(d), 1, 60000);
   SamplingIntervalSource := 'estimated';
  End;

 Destructor TTripPlot.Destroy;
  Begin
   FlightPlan.Free;
   Points.Free;
   Labels.Free;
   Contacts.Free;
   Inherited;
  End;

 Function StripISO(Const v : String) : TDateTime;
  Var
   p : Integer;
   s : String;
  Begin
   s := v;
   p := Pos('_', s);
   If p > 0 Then
    SetLength(s, p - 1);
   If Not TryISO8601ToDate(s, Result, True) Then
    Result := 0;
  End;

 Procedure TFlightDatabase.EnsureTable(Const Table, Fields : String);
  Var
   q        : TFDQuery;
   Existing : TStringList;
   Part     : String;
   Name     : String;
   Decl     : String;
   Parts    : TArray<String>;
   i        : Integer;
  Begin
   fDB.ExecSQL('create table if not exists ' + Table + ' (' + Fields + ')');
   Existing := TStringList.Create;
   q        := TFDQuery.Create(Nil);
   Try
    q.Connection := fDB;
    q.Open('pragma table_info(' + Table + ')');
    While Not q.Eof Do
     Begin
      Existing.Add(q.FieldByName('name').AsString);
      q.Next;
     End;
    Parts := Fields.Split([',']);
    For i := 0 To High(Parts) Do
     Begin
      Part := Trim(Parts[i]);
      Name := Copy(Part, 1, Pos(' ', Part) - 1);
      If (Name = '') Or SameText(Name, 'PRIMARY') Or (Existing.IndexOf(Name) >= 0) Then
       Continue;
      Decl := Part.Replace(' NOT NULL', '').Replace(' PRIMARY KEY AUTOINCREMENT', '').Replace(' UNIQUE', '');
      fDB.ExecSQL('alter table ' + Table + ' add column ' + Decl);
     End;
   Finally
    q.Free;
    Existing.Free;
   End;
  End;

 Function TFlightDatabase.ContactFields(Touchdown : Boolean) : String;
  Begin
   Result := 'id INTEGER PRIMARY KEY AUTOINCREMENT,trip INTEGER NOT NULL,airspeed_indicated INTEGER NOT NULL,vertical_speed INTEGER NOT NULL,';
   If Touchdown Then
    Result := Result + 'g_force REAL NOT NULL,';
   Result  := Result + 'plane_pitch_degrees REAL NOT NULL,plane_bank_degrees REAL NOT NULL,heading_indicator INTEGER NOT NULL,plane_latitude REAL NOT NULL,plane_longitude REAL NOT NULL,icao VARCHAR(4),airport_name VARCHAR(64' + '),runway VARCHAR(3),runway_heading INTEGER,distance_length REAL,distance_width REAL,distance_length_percent REAL,distance_width_percent REAL,wind_direction INTEGER,wind_velocity INTEGER,time_zulu VARC' +
   'HAR(32) NOT NULL,time_local VARCHAR(32) NOT NULL,analysis_report TEXT,runway_length_m REAL,runway_width_m REAL,' + 'metar_text TEXT,metar_station TEXT,metar_observed_utc TEXT,metar_fetched_utc TEXT,metar_requested_utc TEXT,metar_source TEXT,metar_status TEXT,metar_error TEXT,metar_target_utc TEXT,captured_utc TEXT';
  End;

 Constructor TFlightDatabase.Create(Const FileName, SQLiteDLL : String; Background : Boolean; ReadOnly : Boolean);
  Begin
   Inherited Create;
   fSQLiteDLL := SQLiteDLL;
   fReadOnly  := ReadOnly;
   If SameText(ExtractFileExt(FileName), '.mfzi') Then
    Begin
     fIndex := TRecordingIndex.Create(FileName, SQLiteDLL);
     InitializeStorage(':memory:', Background);
    End
   Else
    InitializeStorage(FileName, Background);
  End;

 Procedure TFlightDatabase.InitializeStorage(Const FileName : String; Background : Boolean);
  Var
   i         : Integer;
   Cols      : String;
   Names     : String;
   Params    : String;
   EngCols   : String;
   EngNames  : String;
   EngParams : String;
   Existing  : Boolean;
  Begin
   FreeAndNil(fLastAircraft);
   FreeAndNil(fSample);
   FreeAndNil(fEngine);
   FreeAndNil(fDB);
   FreeAndNil(fDriver);
   FreeAndNil(fWait);
   fStoragePath := FileName;
   Existing     := FileExists(FileName);
   If Not Background Then
    Begin
     fWait          := TFDGUIxWaitCursor.Create(Nil);
     fWait.Provider := 'Forms';
    End;
   fDriver                        := TFDPhysSQLiteDriverLink.Create(Nil);
   fDriver.VendorLib              := fSQLiteDLL;
   fDB                            := TFDConnection.Create(Nil);
   fDB.LoginPrompt                := False;
   fDB.ResourceOptions.SilentMode := True;
   fDB.Params.Add('DriverID=SQLite');
   fDB.Params.Add('SharedCache=False');
   fDB.Params.Add('LockingMode=Normal');
   fDB.Params.Add('JournalMode=WAL');
   If fReadOnly Then
    fDB.Params.Add('OpenMode=ReadOnly');
   fDB.Params.Add('Database=' + FileName);
   fDB.Connected := True;
   fDB.ExecSQL('pragma busy_timeout=5000');
   If Not fReadOnly Then
    fDB.ExecSQL('pragma journal_mode=WAL');
   If Not fReadOnly And (Not Background Or Not Existing) Then
    EnsureTable('trip_fmc_screens', 'id INTEGER PRIMARY KEY AUTOINCREMENT,trip INTEGER NOT NULL,sample INTEGER NOT NULL,time_zulu TEXT NOT NULL,captured_utc TEXT NOT NULL,' + 'provider TEXT NOT NULL,device TEXT NOT NULL,page_key TEXT NOT NULL,title TEXT NOT NULL,available INTEGER NOT NULL,powered INTEGER NOT NULL,raw_text TEXT,parsed_json TEXT NOT NULL,style_json TEXT,annunciators_json TEXT,formatted_html TEXT');
   If Not fReadOnly And (Not Background Or Not Existing) Then
    fDB.ExecSQL('create index if not exists idx_fmc_device on trip_fmc_screens(trip,provider,device,id)');
   If Not fReadOnly And (Not Background Or Not Existing) Then
    fDB.ExecSQL('create index if not exists idx_fmc_time on trip_fmc_screens(trip,time_zulu,id)');
   If Not fReadOnly And (Not Background Or Not Existing) Then
    EnsureTable('trip_aircraft_data', 'trip INTEGER NOT NULL,sample INTEGER PRIMARY KEY,reset_state INTEGER NOT NULL,payload TEXT NOT NULL');
   If Not fReadOnly And (Not Background Or Not Existing) Then
    EnsureTable('trips', 'id INTEGER PRIMARY KEY AUTOINCREMENT,title VARCHAR(256) NOT NULL,atc_airline VARCHAR(64) NOT NULL,atc_flight_number VARCHAR(8) NOT NULL,atc_id VARCHAR(32) NOT NULL,atc_model VARCHAR(32) NOT NULL,atc_t' + 'ype VARCHAR(64) NOT NULL,departure_latitude REAL NOT NULL,departure_longitude REAL NOT NULL,departure_icao VARCHAR(4),departure_name VARCHAR(64),departure_region VARCHAR(2),departure_rwy VARCHAR(3),de' +
    'parture_zulu_time VARCHAR(32) NOT NULL,departure_local_time VARCHAR(32) NOT NULL,destination_latitude REAL,destination_longitude REAL,destination_icao VARCHAR(4),destination_name VARCHAR(64),destinati' + 'on_region VARCHAR(2),destination_rwy VARCHAR(3),destination_zulu_time VARCHAR(32),destination_local_time VARCHAR(32),group_id INTEGER,sample_interval_ms INTEGER');
   Cols   := 'id INTEGER PRIMARY KEY,trip INTEGER NOT NULL,bool_group_1 INTEGER NOT NULL,bool_group_2 INTEGER NOT NULL,bool_group_3 INTEGER NOT NULL';
   Names  := 'trip,bool_group_1,bool_group_2,bool_group_3';
   Params := ':trip,:b1,:b2,:b3';
   For i  := 0 To High(NumericColumns) Do
    Begin
     Cols := Cols + ',' + NumericColumns[i].Name + ' ' + NumericColumns[i].SQLType;
     If NumericColumns[i].FieldIndex < 709 Then
      Cols  := Cols + ' NOT NULL';
     Names  := Names + ',' + NumericColumns[i].Name;
     Params := Params + ',:v' + IntToStr(i);
    End;
   Cols   := Cols + ',zulu_time VARCHAR(32) NOT NULL,local_time VARCHAR(32) NOT NULL';
   Names  := Names + ',zulu_time,local_time';
   Params := Params + ',:z,:l';
   If Not fReadOnly And (Not Background Or Not Existing) Then
    EnsureTable('trip_data', Cols);
   EngCols   := 'sample INTEGER NOT NULL,engine INTEGER NOT NULL,trip INTEGER NOT NULL';
   EngNames  := 'sample,engine,trip';
   EngParams := ':sample,:engine,:trip';
   For i     := 0 To High(EngineColumns) Do
    Begin
     EngCols   := EngCols + ',' + EngineColumns[i].Name + ' ' + EngineColumns[i].SQLType;
     EngNames  := EngNames + ',' + EngineColumns[i].Name;
     EngParams := EngParams + ',:v' + IntToStr(i);
    End;
   If Not fReadOnly And (Not Background Or Not Existing) Then
    EnsureTable('trip_engine_data', EngCols + ',PRIMARY KEY (sample, engine)');
   If Not fReadOnly And (Not Background Or Not Existing) Then
    EnsureTable('trip_events', 'trip INTEGER NOT NULL,event VARCHAR(32) NOT NULL,time_zulu VARCHAR(32) NOT NULL,time_local VARCHAR(32) NOT NULL,event_seq INTEGER');
   If Not fReadOnly And (Not Background Or Not Existing) Then
    EnsureTable('trip_liftoffs', ContactFields(False));
   If Not fReadOnly And (Not Background Or Not Existing) Then
    EnsureTable('trip_touchdowns', ContactFields(True));
   If Not fReadOnly And (Not Background Or Not Existing) Then
    EnsureTable('trip_weather_reports', 'id INTEGER PRIMARY KEY AUTOINCREMENT,trip INTEGER NOT NULL,contact_table TEXT NOT NULL,contact_id INTEGER NOT NULL,source TEXT NOT NULL,request_id TEXT,requested_station TEXT,station TEXT,event_utc TE' + 'XT,requested_utc TEXT,fetched_utc TEXT,observed_utc TEXT,status TEXT,error TEXT,metar_text TEXT,taf_text TEXT,raw_json TEXT');
   fDB.ExecSQL('create unique index if not exists idx_weather_contact_source on trip_weather_reports(contact_table,contact_id,source)');
   EnsureTable('trip_fshud_messages', 'id INTEGER PRIMARY KEY AUTOINCREMENT,trip INTEGER NOT NULL,captured_utc TEXT NOT NULL,sim_utc TEXT,message_type TEXT NOT NULL,payload TEXT NOT NULL');
   If Not fReadOnly And (Not Background Or Not Existing) Then
    fDB.ExecSQL('create index if not exists idx_fshud_trip_type_time on trip_fshud_messages(trip,message_type,captured_utc,id)');
   If Not fReadOnly And (Not Background Or Not Existing) Then
    EnsureTable('trip_simbrief', 'trip INTEGER PRIMARY KEY,captured_utc TEXT NOT NULL,evidence TEXT,payload TEXT NOT NULL,allow_older INTEGER DEFAULT 0');
   EnsureTable('trip_simbrief_maps', 'trip INTEGER NOT NULL,plan_sha256 TEXT NOT NULL,name TEXT,url TEXT NOT NULL,mime TEXT,data BLOB,error TEXT,captured_utc TEXT NOT NULL,PRIMARY KEY(trip,url)');
   If Not fReadOnly And (Not Background Or Not Existing) Then
    EnsureTable('trip_flight_plans', 'id INTEGER PRIMARY KEY AUTOINCREMENT,trip INTEGER NOT NULL,captured_utc TEXT NOT NULL,source TEXT NOT NULL,path TEXT,format TEXT NOT NULL,summary TEXT,payload TEXT NOT NULL');
   If Not fReadOnly And (Not Background Or Not Existing) Then
    EnsureTable('trip_groups', 'id INTEGER PRIMARY KEY AUTOINCREMENT,name VARCHAR(64) NOT NULL,sort_order INTEGER NOT NULL DEFAULT 0');
   If Not fReadOnly And (Not Background Or Not Existing) Then
    UpgradeLegacy(fDB, FileName, Existing, fDriver);
   If Not fReadOnly And (Not Background Or Not Existing) Then
    fDB.ExecSQL('create index if not exists ix_native_samples on trip_data(trip,id)');
   If Not fReadOnly And (Not Background Or Not Existing) Then
    fDB.ExecSQL('create index if not exists ix_native_engines on trip_engine_data(trip,sample)');
   fSample            := TFDQuery.Create(Nil);
   fSample.Connection := fDB;
   fSample.SQL.Text   := 'insert into trip_data (' + Names + ') values (' + Params + ')';
   fEngine            := TFDQuery.Create(Nil);
   fEngine.Connection := fDB;
   fEngine.SQL.Text   := 'insert into trip_engine_data (' + EngNames + ') values (' + EngParams + ')';
  End;

 Destructor TFlightDatabase.Destroy;
  Begin
   fIndex.Free;
   fLastAircraft.Free;
   fSample.Free;
   fEngine.Free;
   fDB.Free;
   fDriver.Free;
   fWait.Free;
   Inherited;
  End;

 Function TFlightDatabase.StartTrip(s : TFlightSample; SamplingIntervalMS : Integer) : Integer;
  Var
   StartedUTC : String;
   Started    : TDateTime;
  Begin
   If fIndex <> Nil Then
    Begin
     If fIndexID <> 0 Then
      FinalizeRecording;
     StartedUTC := s.Time('time_zulu');
     If Not TryISO8601ToDate(StartedUTC, Started, True) Then
      StartedUTC := DateToISO8601(TTimeZone.Local.ToUniversalTime(Now), True);
     fIndexID    := fIndex.Reserve(StartedUTC);
     // Publish the intended path before creating the file, so startup can recover it.
     fIndex.Connection.ExecSQL('update trips set atc_model=:m where id=:id', [s.s('atc_model'), fIndexID]);
     fStoragePath := fIndex.Resolve(fIndex.RecordingPath(fIndexID));
     fIndex.SetPath(fIndexID, ExtractRelativePath(IncludeTrailingPathDelimiter(fIndex.Root), fStoragePath));
     ForceDirectories(ExtractFileDir(fStoragePath));
     InitializeStorage(fStoragePath, True);
    End;
   fDB.ExecSQL('insert into trips(title,atc_airline,atc_flight_number,atc_id,atc_model,atc_type,departure_latitude,departure_longitude,departure_zulu_time,departure_local_time) values (:t,:a,:f,:i,:m,:y,:lat,:lon,:z,:l)', [s.s('title'), s.s('atc_airline'), s.s('atc_flight_number'), s.s('atc_id'), s.s('atc_model'), s.s('atc_type'), s.n('plane_coordinate.latitude'), s.n('plane_coordinate.longitude'), s.Time('time_zulu'), s.Time('time_local')]);
   Result := fDB.ExecSQLScalar('select last_insert_rowid()');
   If (SamplingIntervalMS >= 1) And (SamplingIntervalMS <= 60000) Then
    fDB.ExecSQL('update trips set sample_interval_ms=:ms where id=:id', [SamplingIntervalMS, Result]);
   If fIndex <> Nil Then
    Begin
     fDB.ExecSQL('update trips set id=:newid where id=:oldid', [fIndexID, Result]);
     Result := fIndexID;
     fIndex.Sync(fIndexID, Result, fDB, 'recording');
    End;
  End;

 Procedure TFlightDatabase.EndTrip(ID : Integer; s : TFlightSample);
  Begin
   fDB.ExecSQL('update trips set destination_zulu_time=:z,destination_local_time=:l where id=:id', [s.Time('time_zulu'), s.Time('time_local'), ID]);
   If (fIndex <> Nil) And (fIndexID > 0) Then
    fIndex.Sync(fIndexID, ID, fDB, 'finalizing');
  End;

 Procedure TFlightDatabase.RefreshRecordingMetadata;
  Begin
   If (fIndex <> Nil) And (fIndexID > 0) And (GetTickCount64 >= fMetadataNext) Then
    Begin
     fMetadataNext := GetTickCount64 + 5000;
     fIndex.Sync(fIndexID, fIndexID, fDB, 'recording');
    End;
  End;

 Procedure TFlightDatabase.RecordingError;
  Begin
   If (fIndex <> Nil) And (fIndexID > 0) Then
    Begin
     fIndex.SetStatus(fIndexID, 'error');
     fIndex.Connection.ExecSQL('update trips set recovery_pending=1 where id=:id', [fIndexID]);
     fIndexID := 0;
    End;
  End;

 Procedure TFlightDatabase.FinalizeRecording;
  Var
   Relative : String;
   Target   : String;
   OldPath  : String;
  Begin
   If (fIndex = Nil) Or (fIndexID = 0) Then
    Exit;
   fIndex.Sync(fIndexID, fIndexID, fDB, 'finalizing');
   Relative := fIndex.RecordingPath(fIndexID);
   Target   := fIndex.Resolve(Relative);
   OldPath  := fStoragePath;
   fIndex.Connection.ExecSQL('update trips set pending_path=:p where id=:id', [Relative, fIndexID]);
   If Integer(fDB.ExecSQLScalar('pragma wal_checkpoint(TRUNCATE)')) <> 0 Then
    Raise Exception.Create('SQLite recording checkpoint is busy');
   // All recorder services have been drained before this call. No UI opens finalizing files.
   FreeAndNil(fSample);
   FreeAndNil(fEngine);
   FreeAndNil(fDB);
   ForceDirectories(ExtractFileDir(Target));
   If Not SameText(OldPath, Target) Then
    If Not RenameFile(OldPath, Target) Then
     RaiseLastOSError;
   fIndex.SetPath(fIndexID, Relative);
   fIndex.SetStatus(fIndexID, 'completed');
   fIndexID := 0;
   InitializeStorage(':memory:', True);
  End;

 Procedure TFlightDatabase.RecordSample(ID : Integer; s : TFlightSample);
  Var
   i      : Integer;
   e      : Integer;
   Groups : Array [1..3] Of Cardinal;
   Row    : Int64;
   v      : Double;
  Begin
   FillChar(Groups, SizeOf(Groups), 0);
   For i := 0 To High(BooleanColumns) Do
    If s.Numbers[BooleanColumns[i].FieldIndex] <> 0 Then
     Groups[BooleanColumns[i].Group] := Groups[BooleanColumns[i].Group] Or (Cardinal(1) Shl BooleanColumns[i].Bit);
   fDB.StartTransaction;
   Try
    fSample.ParamByName('trip').AsInteger              := ID;
    For i                                              := 1 To 3 Do
     fSample.ParamByName('b' + IntToStr(i)).AsLargeInt := Groups[i];
    For i                                              := 0 To High(NumericColumns) Do
     Begin
      v := s.Numbers[NumericColumns[i].FieldIndex];
      If IsNan(v) Or IsInfinite(v) Then
       Begin
        If NumericColumns[i].FieldIndex >= 709 Then
         Begin
          fSample.ParamByName('v' + IntToStr(i)).DataType := ftFloat;
          fSample.ParamByName('v' + IntToStr(i)).Clear;
          Continue;
         End;
        Raise Exception.Create(Tr('Invalid SimVar ') + NumericColumns[i].Name);
       End;
      If NumericColumns[i].SQLType = 'INTEGER' Then
       fSample.ParamByName('v' + IntToStr(i)).AsLargeInt := Trunc(v)
      Else
       fSample.ParamByName('v' + IntToStr(i)).AsFloat := v;
     End;
    fSample.ParamByName('z').AsString := s.Time('time_zulu');
    fSample.ParamByName('l').AsString := s.Time('time_local');
    fSample.ExecSQL;
    Row   := fDB.ExecSQLScalar('select last_insert_rowid()');
    For e := 1 To s.EngineCount Do
     Begin
      fEngine.ParamByName('sample').AsLargeInt := Row;
      fEngine.ParamByName('engine').AsInteger  := e;
      fEngine.ParamByName('trip').AsInteger    := ID;
      For i                                    := 0 To High(EngineColumns) Do
       Begin
        v := s.Numbers[EngineColumns[i].FieldIndex + e - 1];
        If IsNan(v) Or IsInfinite(v) Then
         Begin
          fEngine.ParamByName('v' + IntToStr(i)).DataType := ftFloat;
          fEngine.ParamByName('v' + IntToStr(i)).Clear;
         End
        Else If EngineColumns[i].SQLType = 'INTEGER' Then
         fEngine.ParamByName('v' + IntToStr(i)).AsLargeInt := Trunc(v)
        Else
         fEngine.ParamByName('v' + IntToStr(i)).AsFloat := v;
       End;
      fEngine.ExecSQL;
     End;
    SaveFMCScreens(fDB, ID, Row, s.Time('time_zulu'), s.AircraftData);
    SaveAircraft(ID, Row, s);
    fDB.Commit;
   Except
    FreeAndNil(fLastAircraft);
    fDB.Rollback;
    Raise;
   End;
  End;

 Function TFlightDatabase.Contact(ID : Integer; s : TFlightSample; Touchdown : Boolean) : Integer;
  Var
   Table  : String;
   Cols   : String;
   Params : String;
   q      : TFDQuery;
  Begin
   Table := 'trip_liftoffs';
   If Touchdown Then
    Table := 'trip_touchdowns';
   Cols   := 'trip,airspeed_indicated,vertical_speed,plane_pitch_degrees,plane_bank_degrees,heading_indicator,plane_latitude,plane_longitude,wind_direction,wind_velocity,time_zulu,time_local,captured_utc';
   Params := ':id,:ias,:vs,:pitch,:bank,:heading,:lat,:lon,:wind,:vel,:z,:l,:captured';
   If Touchdown Then
    Begin
     Cols   := Cols + ',g_force';
     Params := Params + ',:g';
    End;
   q := TFDQuery.Create(Nil);
   Try
    q.Connection                       := fDB;
    q.SQL.Text                         := 'insert into ' + Table + '(' + Cols + ') values (' + Params + ')';
    q.ParamByName('id').AsInteger      := ID;
    q.ParamByName('ias').AsInteger     := Trunc(s.n('airspeed_indicated'));
    q.ParamByName('vs').AsInteger      := Trunc(s.n('vertical_speed'));
    q.ParamByName('pitch').AsFloat     := s.n('plane_pitch_degrees');
    q.ParamByName('bank').AsFloat      := s.n('plane_bank_degrees');
    q.ParamByName('heading').AsInteger := Trunc(s.n('heading_indicator'));
    q.ParamByName('lat').AsFloat       := s.n('plane_coordinate.latitude');
    q.ParamByName('lon').AsFloat       := s.n('plane_coordinate.longitude');
    q.ParamByName('wind').AsInteger    := Trunc(s.n('ambient_wind_direction'));
    q.ParamByName('vel').AsInteger     := Trunc(s.n('ambient_wind_velocity'));
    q.ParamByName('z').AsString        := s.Time('time_zulu');
    q.ParamByName('l').AsString        := s.Time('time_local');
    q.ParamByName('captured').AsString := DateToISO8601(TTimeZone.Local.ToUniversalTime(Now), True);
    If Touchdown Then
     q.ParamByName('g').AsFloat := s.n('g_force');
    q.ExecSQL;
    Result := fDB.ExecSQLScalar('select last_insert_rowid()');
    If Touchdown Then
     fDB.ExecSQL('update trips set destination_latitude=:a,destination_longitude=:o where id=:id', [s.n('plane_coordinate.latitude'), s.n('plane_coordinate.longitude'), ID]);
   Finally
    q.Free;
   End;
  End;

 Procedure TFlightDatabase.Event(ID : Integer; Const Name, Zulu, Local : String; Seq : Int64);
  Begin
   fDB.ExecSQL('insert into trip_events(trip,event,time_zulu,time_local,event_seq) values (:id,:e,:z,:l,:s)', [ID, Name, Zulu, Local, Seq]);
  End;

 Procedure TFlightDatabase.Retract(Seq : Int64);
  Begin
   fDB.ExecSQL('delete from trip_events where event_seq=:s', [Seq]);
  End;

 Procedure TFlightDatabase.SaveFlightPlan(ID : Integer; Plan : TFlightPlan);
  Var
   q            : TFDQuery;
   Payload      : String;
   StoredFormat : String;
  Begin
   If (ID <= 0) Or (Plan = Nil) Then
    Exit;
   If (Length(Plan.DestinationICAO) = 4) And (Plan.DestinationICAO <> 'ZZZZ') Then
    fDB.ExecSQL('update trips set destination_icao=:a where id=:id', [Plan.DestinationICAO, ID]);
   Payload      := EncodeRecordedPlan(Plan);
   StoredFormat := Plan.Format;
   If Plan.ProcedureData <> '' Then
    StoredFormat := 'FDR ROUTE';
   q             := TFDQuery.Create(Nil);
   Try
    q.Connection := fDB;
    q.Open('select payload,source from trip_flight_plans where trip=' + IntToStr(ID) + ' order by id desc limit 1');
    If Not q.IsEmpty And (q.FieldByName('payload').AsString = Payload) And (q.FieldByName('source').AsString = Plan.Source) Then
     Exit;
    q.Close;
    fDB.ExecSQL('insert into trip_flight_plans(trip,captured_utc,source,path,format,summary,payload) values (:t,:c,:s,:p,:f,:r,:v)', [ID, DateToISO8601(TTimeZone.Local.ToUniversalTime(Now), True), Plan.Source, Plan.Path, StoredFormat, Plan.Summary, Payload]);
   Finally
    q.Free;
   End;
  End;

 Procedure TFlightDatabase.DeleteTrip(ID : Integer);
  Const
   Tables : Array [0..11] Of String = ('trip_simbrief_maps', 'trip_weather_reports', 'trip_fshud_messages', 'trip_simbrief', 'trip_fmc_screens', 'trip_aircraft_data', 'trip_flight_plans', 'trip_data', 'trip_engine_data', 'trip_events', 'trip_liftoffs', 'trip_touchdowns');
  Var
   Table : String;
  Begin
   fDB.StartTransaction;
   Try
    For Table In Tables Do
     fDB.ExecSQL('delete from ' + Table + ' where trip=:id', [ID]);
    fDB.ExecSQL('delete from trips where id=:id', [ID]);
    fDB.Commit;
   Except
    fDB.Rollback;
    Raise;
   End;
  End;

 Function TFlightDatabase.LoadTrip(ID : Integer) : TTripPlot;
  Var
   q                : TFDQuery;
   e                : TFDQuery;
   p                : TPlotPoint;
   i                : Integer;
   j                : Integer;
   MaxEng           : Integer;
   Idx              : Integer;
   Base             : TDateTime;
   Rows             : TDictionary<Int64, Integer>;
   Groups           : Array [1..3] Of Cardinal;
   ContactPoint     : TContactView;
   History          : TAircraftHistory;
   State            : TJSONObject;
   SDKValue         : TJSONValue;
   SDKBase          : Integer;
   SDKPresent       : Boolean;
   FenixPresent     : Boolean;
   FBWPresent       : Boolean;
   PMDGPresent      : Boolean;
   PMDG777Present   : Boolean;
   AddonsPresent    : Boolean;
   Addon            : Integer;
   IField           : Integer;
   AirlinerPresent  : Boolean;
   GSXPresent       : Boolean;
   FSHudPresent     : Boolean;
   ExtraFields      : TDictionary<String, Integer>;
   Pair             : TJSONPair;
   Provider         : String;
   DisplayName      : String;
   LegacyIFly       : Boolean;
   StoredSamplingMS : Integer;
  Begin
   Result := TTripPlot.Create;
   q      := TFDQuery.Create(Nil);
   e      := TFDQuery.Create(Nil);
   Rows   := TDictionary<Int64, Integer>.Create;
   Try
    StoredSamplingMS        := 0;
    Result.TripID           := ID;
    Result.AircraftTitle    := VarToStr(fDB.ExecSQLScalar('select title from trips where id=:id', [ID]));
    Result.AircraftTypeICAO := RecordingAircraftCode(VarToStr(fDB.ExecSQLScalar('select atc_model from trips where id=:id', [ID])), Result.AircraftTitle);
    q.Connection            := fDB;
    q.Open('select * from trips where id=:id', [ID]);
    If Not q.IsEmpty Then
     Begin
      Result.FlightNumber := q.FieldByName('atc_flight_number').AsString;
      If q.FindField('atc_airline') <> Nil Then
       Result.Airline          := q.FieldByName('atc_airline').AsString;
      Result.Registration      := q.FieldByName('atc_id').AsString;
      Result.RecordedStartTime := q.FieldByName('departure_zulu_time').AsString;
      If q.FindField('sample_interval_ms') <> Nil Then
       StoredSamplingMS := q.FieldByName('sample_interval_ms').AsInteger;
     End;
    q.Close;
    e.Connection := fDB;
    q.Open('select * from trip_flight_plans where trip=' + IntToStr(ID) + ' order by id desc limit 1');
    If Not q.IsEmpty Then
     Begin
      Result.FlightPlan        := DecodeRecordedPlan(q.FieldByName('format').AsString, q.FieldByName('payload').AsString, q.FieldByName('path').AsString);
      Result.FlightPlan.Source := q.FieldByName('source').AsString;
     End;
    q.Close;
    ResolvePlanNames(Result.FlightPlan, VarToStr(fDB.ExecSQLScalar('select payload from trip_simbrief where trip=:id', [ID])));
    MaxEng := fDB.ExecSQLScalar('select coalesce(max(engine),0) from trip_engine_data where trip=:id', [ID]);
    MaxEng := EnsureRange(MaxEng, 0, 16);
    For i  := 0 To High(NumericColumns) Do
     Result.Labels.Add(NumericColumns[i].Name);
    For i := 0 To High(BooleanColumns) Do
     Result.Labels.Add(BooleanColumns[i].Name);
    For j  := 1 To MaxEng Do
     For i := 0 To High(EngineColumns) Do
      Result.Labels.Add(EngineColumns[i].Name + ' #' + IntToStr(j));
    q.Open('select * from trip_data where trip=' + IntToStr(ID) + ' order by id');
    Base := 0;
    While Not q.Eof Do
     Begin
      p.BreakBefore := False;
      p.GroupID     := 0;
      p.Lat         := q.FieldByName('plane_latitude').AsFloat;
      p.Lon         := q.FieldByName('plane_longitude').AsFloat;
      p.Time        := q.FieldByName('zulu_time').AsString;
      If Base = 0 Then
       Base     := StripISO(p.Time);
      p.Seconds := (StripISO(p.Time) - Base) * 86400;
      SetLength(p.Values, Result.Labels.Count);
      For i        := 0 To High(p.Values) Do
       p.Values[i] := NaN;
      For i        := 0 To High(NumericColumns) Do
       If (q.FindField(NumericColumns[i].Name) <> Nil) And Not q.FieldByName(NumericColumns[i].Name).IsNull Then
        p.Values[i]                         := q.FieldByName(NumericColumns[i].Name).AsFloat;
      For i                                 := 1 To 3 Do
       Groups[i]                            := Cardinal(q.FieldByName('bool_group_' + IntToStr(i)).AsLargeInt);
      For i                                 := 0 To High(BooleanColumns) Do
       p.Values[Length(NumericColumns) + i] := Ord((Groups[BooleanColumns[i].Group] And (Cardinal(1) Shl BooleanColumns[i].Bit)) <> 0);
      Rows.Add(q.FieldByName('id').AsLargeInt, Result.Points.Count);
      Result.Points.Add(p);
      q.Next;
      SetLength(p.Values, 0);
     End;
    e.Open('select * from trip_engine_data where trip=' + IntToStr(ID) + ' order by sample,engine');
    While Not e.Eof Do
     Begin
      If Rows.TryGetValue(e.FieldByName('sample').AsLargeInt, Idx) Then
       Begin
        p     := Result.Points[Idx];
        j     := e.FieldByName('engine').AsInteger;
        For i := 0 To High(EngineColumns) Do
         If (e.FindField(EngineColumns[i].Name) <> Nil) And Not e.FieldByName(EngineColumns[i].Name).IsNull Then
          p.Values[Length(NumericColumns) + Length(BooleanColumns) + (j - 1) * Length(EngineColumns) + i] := e.FieldByName(EngineColumns[i].Name).AsFloat;
        Result.Points[Idx]                                                                                := p;
       End;
      e.Next;
     End;
    SDKPresent     := fDB.ExecSQLScalar('select count(*) from trip_aircraft_data where trip=:t and payload like :p', [ID, '%iFly737MAX%']) > 0;
    FenixPresent   := fDB.ExecSQLScalar('select count(*) from trip_aircraft_data where trip=:t and payload like :p', [ID, '%FenixA32X%']) > 0;
    FBWPresent     := fDB.ExecSQLScalar('select count(*) from trip_aircraft_data where trip=:t and payload like :p', [ID, '%FBWA32NX%']) > 0;
    PMDGPresent    := fDB.ExecSQLScalar('select count(*) from trip_aircraft_data where trip=:t and payload like :p', [ID, '%PMDGNG3%']) > 0;
    PMDG777Present := fDB.ExecSQLScalar('select count(*) from trip_aircraft_data where trip=:t and payload like :p', [ID, '%PMDG777%']) > 0;
    AddonsPresent  := False;
    For Addon      := 0 To AddonProfileCount - 1 Do
     If fDB.ExecSQLScalar('select count(*) from trip_aircraft_data where trip=:t and payload like :p', [ID, '%' + AddonProfiles[Addon].Provider + '%']) > 0 Then
      AddonsPresent := True;
    AirlinerPresent := fDB.ExecSQLScalar('select count(*) from trip_aircraft_data where trip=:t and payload like :p', [ID, '%airliner_lvars%']) > 0;
    GSXPresent      := fDB.ExecSQLScalar('select count(*) from trip_aircraft_data where trip=:t and payload like :p', [ID, '%gsx_lvars%']) > 0;
    FSHudPresent    := fDB.ExecSQLScalar('select count(*) from trip_aircraft_data where trip=:t and payload like :p', [ID, '%"fshud"%']) > 0;
    If SDKPresent Or FenixPresent Or FBWPresent Or PMDGPresent Or PMDG777Present Or AddonsPresent Or AirlinerPresent Or GSXPresent Or FSHudPresent Then
     Begin
      ExtraFields := TDictionary<String, Integer>.Create;
      Try
       LegacyIFly := fDB.ExecSQLScalar('select count(*) from trip_aircraft_data where trip=:t and payload like :p', [ID, '%LSKChar[%']) > 0;
       If SDKPresent Then
        For i := 0 To SDKFieldCount - 1 Do
         Begin
          If SDKFields[i].Name = 'Tick18' Then
           Continue;
          If Not LegacyIFly And IFlyCompactField(SDKFields[i].Name) Then
           Continue;
          ExtraFields.Add('iFly737MAX:' + SDKFields[i].Name, Result.Labels.Count);
          Result.Labels.Add('iFlySDK.' + SDKFields[i].Name);
         End;
       If SDKPresent Then
        For DisplayName In IFlyDisplayNames Do
         Begin
          ExtraFields.Add('iFly737MAX:' + DisplayName, Result.Labels.Count);
          Result.Labels.Add('iFlySDK.' + DisplayName);
         End;
       If FenixPresent Then
        For DisplayName In RecordedSDKFields(fDB, ID, 'FenixA32X') Do
         Begin
          ExtraFields.Add('FenixA32X:' + DisplayName, Result.Labels.Count);
          Result.Labels.Add('FenixLVar.' + DisplayName);
         End;
       If FBWPresent Then
        For i := 0 To FBWFieldCount - 1 Do
         Begin
          ExtraFields.Add('FBWA32NX:' + FBWFields[i].Name, Result.Labels.Count);
          Result.Labels.Add('FBWLVar.' + FBWFields[i].Name);
         End;
       If PMDGPresent Then
        For i := 0 To PMDGFieldCount - 1 Do
         Begin
          ExtraFields.Add('PMDGNG3:' + PMDGFields[i].Name, Result.Labels.Count);
          Result.Labels.Add('PMDGNG3.' + PMDGFields[i].Name);
         End;
       If PMDG777Present Then
        For i := 0 To PMDG777FieldCount - 1 Do
         Begin
          ExtraFields.Add('PMDG777:' + PMDG777Fields[i].Name, Result.Labels.Count);
          Result.Labels.Add('PMDG777.' + PMDG777Fields[i].Name);
         End;
       If AddonsPresent Then
        For Addon := 0 To AddonProfileCount - 1 Do
         If fDB.ExecSQLScalar('select count(*) from trip_aircraft_data where trip=:t and payload like :p', [ID, '%' + AddonProfiles[Addon].Provider + '%']) > 0 Then
          For IField := AddonProfiles[Addon].First To AddonProfiles[Addon].First + AddonProfiles[Addon].Count - 1 Do
           Begin
            ExtraFields.Add(AddonProfiles[Addon].Provider + ':' + AddonFields[IField].Name, Result.Labels.Count);
            Result.Labels.Add(AddonProfiles[Addon].Provider + '.' + AddonFields[IField].Name);
           End;
       If AirlinerPresent Then
        For i := 0 To AirlinerVarCount - 1 Do
         Begin
          ExtraFields.Add('AIRLINER:' + AirlinerNames[i], Result.Labels.Count);
          Result.Labels.Add('AirlinerLVar.' + AirlinerNames[i]);
         End;
       If GSXPresent Then
        For i := 0 To GSXVarCount - 1 Do
         Begin
          ExtraFields.Add('GSX:' + GSXNames[i], Result.Labels.Count);
          Result.Labels.Add('GSX.' + GSXNames[i]);
         End;
       If FSHudPresent Then
        For i := 0 To FSHudFieldCount - 1 Do
         Begin
          ExtraFields.Add('FSHUD:' + FSHudFields[i], Result.Labels.Count);
          Result.Labels.Add('FSHud.' + FSHudFields[i]);
         End;
       History := TAircraftHistory.Create(fDB, ID);
       Try
        q.Close;
        q.Open('select id from trip_data where trip=:t order by id', [ID]);
        Idx := 0;
        While Not q.Eof Do
         Begin
          State := History.AtSample(q.FieldByName('id').AsLargeInt);
          Try
           p       := Result.Points[Idx];
           SDKBase := Length(p.Values);
           SetLength(p.Values, Result.Labels.Count);
           For i        := SDKBase To High(p.Values) Do
            p.Values[i] := NaN;
           SDKValue     := State.GetValue('aircraft_sdk');
           If SDKValue Is TJSONObject Then
            Begin
             Pair     := TJSONObject(SDKValue).Get('provider');
             Provider := '';
             If Pair <> Nil Then
              Provider := Pair.JsonValue.Value;
             SDKValue  := TJSONObject(SDKValue).GetValue('fields');
             If SDKValue Is TJSONObject Then
              For Pair In TJSONObject(SDKValue) Do
               If (Pair.JsonValue Is TJSONNumber) And ExtraFields.TryGetValue(Provider + ':' + Pair.JsonString.Value, i) Then
                p.Values[i] := TJSONNumber(Pair.JsonValue).AsDouble;
            End;
           SDKValue := State.GetValue('airliner_lvars');
           If SDKValue Is TJSONObject Then
            Begin
             SDKValue := TJSONObject(SDKValue).GetValue('fields');
             If SDKValue Is TJSONObject Then
              For Pair In TJSONObject(SDKValue) Do
               If (Pair.JsonValue Is TJSONNumber) And ExtraFields.TryGetValue('AIRLINER:' + Pair.JsonString.Value, i) Then
                p.Values[i] := TJSONNumber(Pair.JsonValue).AsDouble;
            End;
           SDKValue := State.GetValue('gsx_lvars');
           If SDKValue Is TJSONObject Then
            Begin
             SDKValue := TJSONObject(SDKValue).GetValue('fields');
             If SDKValue Is TJSONObject Then
              For Pair In TJSONObject(SDKValue) Do
               If (Pair.JsonValue Is TJSONNumber) And ExtraFields.TryGetValue('GSX:' + Pair.JsonString.Value, i) Then
                p.Values[i] := TJSONNumber(Pair.JsonValue).AsDouble;
            End;
           SDKValue := State.GetValue('fshud');
           If SDKValue Is TJSONObject Then
            Begin
             SDKValue := TJSONObject(SDKValue).GetValue('fields');
             If SDKValue Is TJSONObject Then
              For Pair In TJSONObject(SDKValue) Do
               If (Pair.JsonValue Is TJSONNumber) And ExtraFields.TryGetValue('FSHUD:' + Pair.JsonString.Value, i) Then
                p.Values[i] := TJSONNumber(Pair.JsonValue).AsDouble;
            End;
           Result.Points[Idx] := p;
          Finally
           State.Free;
          End;
          Inc(Idx);
          q.Next;
         End;
       Finally
        History.Free;
       End;
      Finally
       ExtraFields.Free;
      End;
     End;
    q.Close;
    q.Open('select ''Start'' kind,time_zulu,plane_latitude,plane_longitude,icao,runway,airspeed_indicated,vertical_speed from trip_liftoffs where trip=' + IntToStr(ID) + ' union all select ''Landing'',time_zulu,plane_latitude,plane_longitude,icao,runway,airspeed_indicated,vertical_speed from trip_touchdowns where trip=' + IntToStr(ID));
    While Not q.Eof Do
     Begin
      ContactPoint.Lat         := q.FieldByName('plane_latitude').AsFloat;
      ContactPoint.Lon         := q.FieldByName('plane_longitude').AsFloat;
      ContactPoint.Kind        := q.FieldByName('kind').AsString;
      ContactPoint.Time        := q.FieldByName('time_zulu').AsString;
      ContactPoint.Description := ContactPoint.Kind + ' ' + q.FieldByName('icao').AsString + ' ' + q.FieldByName('runway').AsString + ' | IAS ' + q.FieldByName('airspeed_indicated').AsString + ' kt | VS ' + q.FieldByName('vertical_speed').AsString + ' fpm';
      Result.Contacts.Add(ContactPoint);
      q.Next;
     End;
    Result.ResolveSamplingInterval(StoredSamplingMS);
   Except
    Result.Free;
    Raise;
   End;
   Rows.Free;
   q.Free;
   e.Free;
  End;

 Procedure TFlightDatabase.ExportKML(ID : Integer; Const FileName : String);
  Var
   Data  : TTripPlot;
   Lines : TStringList;
   p     : TPlotPoint;
   FS    : TFormatSettings;
  Begin
   Data                := LoadTrip(ID);
   Lines               := TStringList.Create;
   FS                  := TFormatSettings.Create;
   FS.DecimalSeparator := '.';
   Try
    Lines.Add('<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://www.opengis.net/kml/2.2"><Document><Placemark><name>Flight ' + IntToStr(ID) + '</name><LineString><altitudeMode>absolute</altitudeMode><coordinates>');
    For p In Data.Points Do
     Lines.Add(FloatToStr(p.Lon, FS) + ',' + FloatToStr(p.Lat, FS) + ',' + FloatToStr(p.Values[Data.Labels.IndexOf('plane_altitude')] * 0.3048, FS));
    Lines.Add('</coordinates></LineString></Placemark></Document></kml>');
    Lines.SaveToFile(FileName, TEncoding.UTF8);
   Finally
    Lines.Free;
    Data.Free;
   End;
  End;

End.
