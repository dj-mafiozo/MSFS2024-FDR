{$StackFrames On}
Unit FlightDatabaseU;

Interface

 Uses
  LocalizationU, System.SysUtils, System.Classes, System.Math, System.DateUtils,
  System.Generics.Collections, System.JSON,
  Data.DB, FireDAC.Comp.Client, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.Def, FireDAC.Stan.Async, FireDAC.Stan.Param, FireDAC.DApt, FireDAC.VCLUI.Wait, FireDAC.Comp.UI,
  TelemetryCatalogU, FlightTelemetryU, LegacyMigrationU, FlightPlanU, AircraftDataStoreU,
  iFlySDKCatalogU, FenixCatalogU, FBWCatalogU, PMDGNG3CatalogU, FMCScreensU;

 Type
  TPlotPoint = Record
   Public
    Lat         : Double;
    Lon         : Double;
    Seconds     : Double;
    Time        : String;
    Values      : TArray<Double>;
    BreakBefore : Boolean;
    GroupID     : Integer;
  End;

  TContactView = Record
   Public
    Lat         : Double;
    Lon         : Double;
    Kind        : String;
    Time        : String;
    Description : String;
  End;

  TTripPlot = Class
   Public
    Points     : TList<TPlotPoint>;
    Labels     : TStringList;
    Contacts   : TList<TContactView>;
    TripID     : Integer;
    FlightPlan : TFlightPlan;
    Constructor Create;
    Destructor Destroy; Override;
  End;

  TFlightDatabase = Class
   Private
    fLastAircraft     : TJSONObject;
    fLastAircraftTrip : Integer;
    fDriver           : TFDPhysSQLiteDriverLink;
    fWait             : TFDGUIxWaitCursor;
    fDB               : TFDConnection;
    fSample           : TFDQuery;
    fEngine           : TFDQuery;
    Procedure SaveAircraft(ID : Integer; Row : Int64; S : TFlightSample);
    Procedure EnsureTable(Const Table, Fields : String);
    Function ContactFields(Touchdown : Boolean) : String;
   Public
    Constructor Create(Const FileName, SQLiteDLL : String; Background : Boolean = False);
    Destructor Destroy; Override;
    Function StartTrip(S : TFlightSample) : Integer;
    Procedure EndTrip(ID : Integer; S : TFlightSample);
    Procedure RecordSample(ID : Integer; S : TFlightSample);
    Function Contact(ID : Integer; S : TFlightSample; Touchdown : Boolean) : Integer;
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
  iFlyDisplaysU, FSHudDataU, GSXVarsU, AirlinerVarsU, AirlinerCatalogU;

 Procedure TFlightDatabase.SaveAircraft(ID : Integer; Row : Int64; S : TFlightSample);
  Var
   Current : TJSONObject;
   Delta   : TJSONObject;
   SDK     : TJSONObject;
   Reset   : Boolean;
   Payload : String;

   Function ProviderOf(O : TJSONObject) : String;
    Var
     V : TJSONValue;
    Begin
     Result := '';
     V      := O.GetValue('aircraft_sdk');
     If V Is TJSONObject Then
      Begin
       V := TJSONObject(V).GetValue('provider');
       If V <> Nil Then
        Result := V.Value;
      End;
    End;

  Begin
   Current := TJSONObject.Create;
   Try
    If S.AircraftData <> Nil Then
     Begin
      SDK := TJSONObject.ParseJSONValue(S.AircraftData.ToJSON) As TJSONObject;
      CompactIFlySDK(SDK);
      Current.AddPair('aircraft_sdk', SDK);
     End
    Else
     Current.AddPair('aircraft_sdk', TJSONNull.Create);
    If S.DataSources <> Nil Then
     Current.AddPair('overrides', TJSONObject.ParseJSONValue(S.DataSources.ToJSON))
    Else
     Current.AddPair('overrides', TJSONNull.Create);
    If S.FSHudDataU <> Nil Then
     Current.AddPair('fshud', TJSONObject.ParseJSONValue(S.FSHudDataU.ToJSON));
    If S.GSXData <> Nil Then
     Current.AddPair('gsx_lvars', TJSONObject.ParseJSONValue(S.GSXData.ToJSON));
    If S.AirlinerData <> Nil Then
     Current.AddPair('airliner_lvars', TJSONObject.ParseJSONValue(S.AirlinerData.ToJSON));
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

 Constructor TTripPlot.Create;
  Begin
   Inherited;
   Points   := TList<TPlotPoint>.Create;
   Labels   := TStringList.Create;
   Contacts := TList<TContactView>.Create;
  End;

 Destructor TTripPlot.Destroy;
  Begin
   FlightPlan.Free;
   Points.Free;
   Labels.Free;
   Contacts.Free;
   Inherited;
  End;

 Function StripISO(Const V : String) : TDateTime;
  Var
   P : Integer;
   S : String;
  Begin
   S := V;
   P := Pos('_', S);
   If P > 0 Then
    SetLength(S, P - 1);
   If Not TryISO8601ToDate(S, Result, True) Then
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

 Constructor TFlightDatabase.Create(Const FileName, SQLiteDLL : String; Background : Boolean);
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
   Inherited Create;
   Existing := FileExists(FileName);
   If Not Background Then
    Begin
     fWait          := TFDGUIxWaitCursor.Create(Nil);
     fWait.Provider := 'Forms';
    End;
   fDriver                        := TFDPhysSQLiteDriverLink.Create(Nil);
   fDriver.VendorLib              := SQLiteDLL;
   fDB                            := TFDConnection.Create(Nil);
   fDB.LoginPrompt                := False;
   fDB.ResourceOptions.SilentMode := True;
   fDB.Params.Add('DriverID=SQLite');
   fDB.Params.Add('SharedCache=False');
   fDB.Params.Add('LockingMode=Normal');
   fDB.Params.Add('JournalMode=WAL');
   fDB.Params.Add('Database=' + FileName);
   fDB.Connected := True;
   fDB.ExecSQL('pragma busy_timeout=5000');
   fDB.ExecSQL('pragma journal_mode=WAL');
   If Not Background Then
    EnsureTable('trip_fmc_screens', 'id INTEGER PRIMARY KEY AUTOINCREMENT,trip INTEGER NOT NULL,sample INTEGER NOT NULL,time_zulu TEXT NOT NULL,captured_utc TEXT NOT NULL,' + 'provider TEXT NOT NULL,device TEXT NOT NULL,page_key TEXT NOT NULL,title TEXT NOT NULL,available INTEGER NOT NULL,powered INTEGER NOT NULL,raw_text TEXT,parsed_json TEXT NOT NULL,style_json TEXT,annunciators_json TEXT,formatted_html TEXT');
   If Not Background Then
    fDB.ExecSQL('create index if not exists idx_fmc_device on trip_fmc_screens(trip,provider,device,id)');
   If Not Background Then
    fDB.ExecSQL('create index if not exists idx_fmc_time on trip_fmc_screens(trip,time_zulu,id)');
   If Not Background Then
    EnsureTable('trip_aircraft_data', 'trip INTEGER NOT NULL,sample INTEGER PRIMARY KEY,reset_state INTEGER NOT NULL,payload TEXT NOT NULL');
   If Not Background Then
    EnsureTable('trips', 'id INTEGER PRIMARY KEY AUTOINCREMENT,title VARCHAR(256) NOT NULL,atc_airline VARCHAR(64) NOT NULL,atc_flight_number VARCHAR(8) NOT NULL,atc_id VARCHAR(32) NOT NULL,atc_model VARCHAR(32) NOT NULL,atc_t' + 'ype VARCHAR(64) NOT NULL,departure_latitude REAL NOT NULL,departure_longitude REAL NOT NULL,departure_icao VARCHAR(4),departure_name VARCHAR(64),departure_region VARCHAR(2),departure_rwy VARCHAR(3),de' +
     'parture_zulu_time VARCHAR(32) NOT NULL,departure_local_time VARCHAR(32) NOT NULL,destination_latitude REAL,destination_longitude REAL,destination_icao VARCHAR(4),destination_name VARCHAR(64),destinati' + 'on_region VARCHAR(2),destination_rwy VARCHAR(3),destination_zulu_time VARCHAR(32),destination_local_time VARCHAR(32),group_id INTEGER');
   Cols   := 'id INTEGER PRIMARY KEY,trip INTEGER NOT NULL,bool_group_1 INTEGER NOT NULL,bool_group_2 INTEGER NOT NULL,bool_group_3 INTEGER NOT NULL';
   Names  := 'trip,bool_group_1,bool_group_2,bool_group_3';
   Params := ':trip,:b1,:b2,:b3';
   For i  := 0 To High(NumericColumns) Do
    Begin
     Cols   := Cols + ',' + NumericColumns[i].Name + ' ' + NumericColumns[i].SQLType + ' NOT NULL';
     Names  := Names + ',' + NumericColumns[i].Name;
     Params := Params + ',:v' + IntToStr(i);
    End;
   Cols   := Cols + ',zulu_time VARCHAR(32) NOT NULL,local_time VARCHAR(32) NOT NULL';
   Names  := Names + ',zulu_time,local_time';
   Params := Params + ',:z,:l';
   If Not Background Then
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
   If Not Background Then
    EnsureTable('trip_engine_data', EngCols + ',PRIMARY KEY (sample, engine)');
   If Not Background Then
    EnsureTable('trip_events', 'trip INTEGER NOT NULL,event VARCHAR(32) NOT NULL,time_zulu VARCHAR(32) NOT NULL,time_local VARCHAR(32) NOT NULL,event_seq INTEGER');
   If Not Background Then
    EnsureTable('trip_liftoffs', ContactFields(False));
   If Not Background Then
    EnsureTable('trip_touchdowns', ContactFields(True));
   If Not Background Then
    EnsureTable('trip_fshud_messages', 'id INTEGER PRIMARY KEY AUTOINCREMENT,trip INTEGER NOT NULL,captured_utc TEXT NOT NULL,sim_utc TEXT,message_type TEXT NOT NULL,payload TEXT NOT NULL');
   If Not Background Then
    fDB.ExecSQL('create index if not exists idx_fshud_trip_type_time on trip_fshud_messages(trip,message_type,captured_utc,id)');
   If Not Background Then
    EnsureTable('trip_simbrief', 'trip INTEGER PRIMARY KEY,captured_utc TEXT NOT NULL,evidence TEXT,payload TEXT NOT NULL,allow_older INTEGER DEFAULT 0');
   If Not Background Then
    EnsureTable('trip_flight_plans', 'id INTEGER PRIMARY KEY AUTOINCREMENT,trip INTEGER NOT NULL,captured_utc TEXT NOT NULL,source TEXT NOT NULL,path TEXT,format TEXT NOT NULL,summary TEXT,payload TEXT NOT NULL');
   If Not Background Then
    EnsureTable('trip_groups', 'id INTEGER PRIMARY KEY AUTOINCREMENT,name VARCHAR(64) NOT NULL,sort_order INTEGER NOT NULL DEFAULT 0');
   If Not Background Then
    UpgradeLegacy(fDB, FileName, Existing, fDriver);
   If Not Background Then
    fDB.ExecSQL('create index if not exists ix_native_samples on trip_data(trip,id)');
   If Not Background Then
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
   fLastAircraft.Free;
   fSample.Free;
   fEngine.Free;
   fDB.Free;
   fDriver.Free;
   fWait.Free;
   Inherited;
  End;

 Function TFlightDatabase.StartTrip(S : TFlightSample) : Integer;
  Begin
   fDB.ExecSQL('insert into trips(title,atc_airline,atc_flight_number,atc_id,atc_model,atc_type,departure_latitude,departure_longitude,departure_zulu_time,departure_local_time) values (:t,:a,:f,:i,:m,:y,:lat,:lon,:z,:l)', [S.S('title'), S.S('atc_airline'), S.S('atc_flight_number'), S.S('atc_id'), S.S('atc_model'), S.S('atc_type'), S.N('plane_coordinate.latitude'), S.N('plane_coordinate.longitude'), S.Time('time_zulu'), S.Time('time_local')]);
   Result := fDB.ExecSQLScalar('select last_insert_rowid()');
  End;

 Procedure TFlightDatabase.EndTrip(ID : Integer; S : TFlightSample);
  Begin
   fDB.ExecSQL('update trips set destination_zulu_time=:z,destination_local_time=:l where id=:id', [S.Time('time_zulu'), S.Time('time_local'), ID]);
  End;

 Procedure TFlightDatabase.RecordSample(ID : Integer; S : TFlightSample);
  Var
   i, e   : Integer;
   Groups : Array [1 .. 3] Of Cardinal;
   Row    : Int64;
   V      : Double;
  Begin
   FillChar(Groups, SizeOf(Groups), 0);
   For i := 0 To High(BooleanColumns) Do
    If S.Numbers[BooleanColumns[i].FieldIndex] <> 0 Then
     Groups[BooleanColumns[i].Group] := Groups[BooleanColumns[i].Group] Or (Cardinal(1) Shl BooleanColumns[i].Bit);
   fDB.StartTransaction;
   Try
    fSample.ParamByName('trip').AsInteger              := ID;
    For i                                              := 1 To 3 Do
     fSample.ParamByName('b' + IntToStr(i)).AsLargeInt := Groups[i];
    For i                                              := 0 To High(NumericColumns) Do
     Begin
      V := S.Numbers[NumericColumns[i].FieldIndex];
      If IsNan(V) Or IsInfinite(V) Then
       Raise Exception.Create(Tr('Invalid SimVar ') + NumericColumns[i].Name);
      If NumericColumns[i].SQLType = 'INTEGER' Then
       fSample.ParamByName('v' + IntToStr(i)).AsLargeInt := Trunc(V)
      Else
       fSample.ParamByName('v' + IntToStr(i)).AsFloat := V;
     End;
    fSample.ParamByName('z').AsString := S.Time('time_zulu');
    fSample.ParamByName('l').AsString := S.Time('time_local');
    fSample.ExecSQL;
    Row   := fDB.ExecSQLScalar('select last_insert_rowid()');
    For e := 1 To S.EngineCount Do
     Begin
      fEngine.ParamByName('sample').AsLargeInt := Row;
      fEngine.ParamByName('engine').AsInteger  := e;
      fEngine.ParamByName('trip').AsInteger    := ID;
      For i                                    := 0 To High(EngineColumns) Do
       Begin
        V := S.Numbers[EngineColumns[i].FieldIndex + e - 1];
        If IsNan(V) Or IsInfinite(V) Then
         fEngine.ParamByName('v' + IntToStr(i)).Clear
        Else If EngineColumns[i].SQLType = 'INTEGER' Then
         fEngine.ParamByName('v' + IntToStr(i)).AsLargeInt := Trunc(V)
        Else
         fEngine.ParamByName('v' + IntToStr(i)).AsFloat := V;
       End;
      fEngine.ExecSQL;
     End;
    SaveFMCScreens(fDB, ID, Row, S.Time('time_zulu'), S.AircraftData);
    SaveAircraft(ID, Row, S);
    fDB.Commit;
   Except
    FreeAndNil(fLastAircraft);
    fDB.Rollback;
    Raise;
   End;
  End;

 Function TFlightDatabase.Contact(ID : Integer; S : TFlightSample; Touchdown : Boolean) : Integer;
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
    q.ParamByName('ias').AsInteger     := Trunc(S.N('airspeed_indicated'));
    q.ParamByName('vs').AsInteger      := Trunc(S.N('vertical_speed'));
    q.ParamByName('pitch').AsFloat     := S.N('plane_pitch_degrees');
    q.ParamByName('bank').AsFloat      := S.N('plane_bank_degrees');
    q.ParamByName('heading').AsInteger := Trunc(S.N('heading_indicator'));
    q.ParamByName('lat').AsFloat       := S.N('plane_coordinate.latitude');
    q.ParamByName('lon').AsFloat       := S.N('plane_coordinate.longitude');
    q.ParamByName('wind').AsInteger    := Trunc(S.N('ambient_wind_direction'));
    q.ParamByName('vel').AsInteger     := Trunc(S.N('ambient_wind_velocity'));
    q.ParamByName('z').AsString        := S.Time('time_zulu');
    q.ParamByName('l').AsString        := S.Time('time_local');
    q.ParamByName('captured').AsString := DateToISO8601(TTimeZone.Local.ToUniversalTime(Now), True);
    If Touchdown Then
     q.ParamByName('g').AsFloat := S.N('g_force');
    q.ExecSQL;
    Result := fDB.ExecSQLScalar('select last_insert_rowid()');
    If Touchdown Then
     fDB.ExecSQL('update trips set destination_latitude=:a,destination_longitude=:o where id=:id', [S.N('plane_coordinate.latitude'), S.N('plane_coordinate.longitude'), ID]);
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
   q : TFDQuery;
  Begin
   If (ID <= 0) Or (Plan = Nil) Then
    Exit;
   q := TFDQuery.Create(Nil);
   Try
    q.Connection := fDB;
    q.Open('select payload,source from trip_flight_plans where trip=' + IntToStr(ID) + ' order by id desc limit 1');
    If Not q.IsEmpty And (q.FieldByName('payload').AsString = Plan.Raw) And (q.FieldByName('source').AsString = Plan.Source) Then
     Exit;
    q.Close;
    fDB.ExecSQL('insert into trip_flight_plans(trip,captured_utc,source,path,format,summary,payload) values (:t,:c,:s,:p,:f,:r,:v)', [ID, DateToISO8601(TTimeZone.Local.ToUniversalTime(Now), True), Plan.Source, Plan.Path, Plan.Format, Plan.Summary, Plan.Raw]);
   Finally
    q.Free;
   End;
  End;

 Procedure TFlightDatabase.DeleteTrip(ID : Integer);
  Const
   Tables : Array [0 .. 9] Of String = ('trip_fshud_messages', 'trip_simbrief', 'trip_fmc_screens', 'trip_aircraft_data', 'trip_flight_plans', 'trip_data', 'trip_engine_data', 'trip_events', 'trip_liftoffs', 'trip_touchdowns');
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
   q               : TFDQuery;
   e               : TFDQuery;
   P               : TPlotPoint;
   i               : Integer;
   J               : Integer;
   MaxEng          : Integer;
   Idx             : Integer;
   Base            : TDateTime;
   Rows            : TDictionary<Int64, Integer>;
   Groups          : Array [1 .. 3] Of Cardinal;
   ContactPoint    : TContactView;
   History         : TAircraftHistory;
   State           : TJSONObject;
   SDKValue        : TJSONValue;
   SDKBase         : Integer;
   SDKPresent      : Boolean;
   FenixPresent    : Boolean;
   FBWPresent      : Boolean;
   PMDGPresent     : Boolean;
   AirlinerPresent : Boolean;
   GSXPresent      : Boolean;
   FSHudPresent    : Boolean;
   ExtraFields     : TDictionary<String, Integer>;
   Pair            : TJSONPair;
   Provider        : String;
   DisplayName     : String;
   LegacyIFly      : Boolean;
  Begin
   Result := TTripPlot.Create;
   q      := TFDQuery.Create(Nil);
   e      := TFDQuery.Create(Nil);
   Rows   := TDictionary<Int64, Integer>.Create;
   Try
    Result.TripID := ID;
    q.Connection  := fDB;
    e.Connection  := fDB;
    q.Open('select * from trip_flight_plans where trip=' + IntToStr(ID) + ' order by id desc limit 1');
    If Not q.IsEmpty Then
     Begin
      If q.FieldByName('format').AsString = 'PLN' Then
       Result.FlightPlan := ParsePLN(q.FieldByName('payload').AsString, q.FieldByName('path').AsString)
      Else
       Result.FlightPlan       := ParseEFBRoute(q.FieldByName('payload').AsString);
      Result.FlightPlan.Source := q.FieldByName('source').AsString;
     End;
    q.Close;
    MaxEng := fDB.ExecSQLScalar('select coalesce(max(engine),0) from trip_engine_data where trip=:id', [ID]);
    MaxEng := EnsureRange(MaxEng, 0, 16);
    For i  := 0 To High(NumericColumns) Do
     Result.Labels.Add(NumericColumns[i].Name);
    For i := 0 To High(BooleanColumns) Do
     Result.Labels.Add(BooleanColumns[i].Name);
    For J  := 1 To MaxEng Do
     For i := 0 To High(EngineColumns) Do
      Result.Labels.Add(EngineColumns[i].Name + ' #' + IntToStr(J));
    q.Open('select * from trip_data where trip=' + IntToStr(ID) + ' order by id');
    Base := 0;
    While Not q.Eof Do
     Begin
      P.BreakBefore := False;
      P.GroupID     := 0;
      P.Lat         := q.FieldByName('plane_latitude').AsFloat;
      P.Lon         := q.FieldByName('plane_longitude').AsFloat;
      P.Time        := q.FieldByName('zulu_time').AsString;
      If Base = 0 Then
       Base     := StripISO(P.Time);
      P.Seconds := (StripISO(P.Time) - Base) * 86400;
      SetLength(P.Values, Result.Labels.Count);
      For i        := 0 To High(P.Values) Do
       P.Values[i] := NaN;
      For i        := 0 To High(NumericColumns) Do
       If Not q.FieldByName(NumericColumns[i].Name).IsNull Then
        P.Values[i]                         := q.FieldByName(NumericColumns[i].Name).AsFloat;
      For i                                 := 1 To 3 Do
       Groups[i]                            := Cardinal(q.FieldByName('bool_group_' + IntToStr(i)).AsLargeInt);
      For i                                 := 0 To High(BooleanColumns) Do
       P.Values[Length(NumericColumns) + i] := Ord((Groups[BooleanColumns[i].Group] And (Cardinal(1) Shl BooleanColumns[i].Bit)) <> 0);
      Rows.Add(q.FieldByName('id').AsLargeInt, Result.Points.Count);
      Result.Points.Add(P);
      q.Next;
      SetLength(P.Values, 0);
     End;
    e.Open('select * from trip_engine_data where trip=' + IntToStr(ID) + ' order by sample,engine');
    While Not e.Eof Do
     Begin
      If Rows.TryGetValue(e.FieldByName('sample').AsLargeInt, Idx) Then
       Begin
        P     := Result.Points[Idx];
        J     := e.FieldByName('engine').AsInteger;
        For i := 0 To High(EngineColumns) Do
         If Not e.FieldByName(EngineColumns[i].Name).IsNull Then
          P.Values[Length(NumericColumns) + Length(BooleanColumns) + (J - 1) * Length(EngineColumns) + i] := e.FieldByName(EngineColumns[i].Name).AsFloat;
        Result.Points[Idx]                                                                                := P;
       End;
      e.Next;
     End;
    SDKPresent      := fDB.ExecSQLScalar('select count(*) from trip_aircraft_data where trip=:t and payload like :p', [ID, '%iFly737MAX%']) > 0;
    FenixPresent    := fDB.ExecSQLScalar('select count(*) from trip_aircraft_data where trip=:t and payload like :p', [ID, '%FenixA32X%']) > 0;
    FBWPresent      := fDB.ExecSQLScalar('select count(*) from trip_aircraft_data where trip=:t and payload like :p', [ID, '%FBWA32NX%']) > 0;
    PMDGPresent     := fDB.ExecSQLScalar('select count(*) from trip_aircraft_data where trip=:t and payload like :p', [ID, '%PMDGNG3%']) > 0;
    AirlinerPresent := fDB.ExecSQLScalar('select count(*) from trip_aircraft_data where trip=:t and payload like :p', [ID, '%airliner_lvars%']) > 0;
    GSXPresent      := fDB.ExecSQLScalar('select count(*) from trip_aircraft_data where trip=:t and payload like :p', [ID, '%gsx_lvars%']) > 0;
    FSHudPresent    := fDB.ExecSQLScalar('select count(*) from trip_aircraft_data where trip=:t and payload like :p', [ID, '%"fshud"%']) > 0;
    If SDKPresent Or FenixPresent Or FBWPresent Or PMDGPresent Or AirlinerPresent Or GSXPresent Or FSHudPresent Then
     Begin
      ExtraFields := TDictionary<String, Integer>.Create;
      Try
       LegacyIFly := fDB.ExecSQLScalar('select count(*) from trip_aircraft_data where trip=:t and payload like :p', [ID, '%LSKChar[%']) > 0;
       If SDKPresent Then
        For i := 0 To SDKFieldCount - 1 Do
         Begin
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
        For i := 0 To FenixFieldCount - 1 Do
         Begin
          ExtraFields.Add('FenixA32X:' + FenixFields[i].Name, Result.Labels.Count);
          Result.Labels.Add('FenixLVar.' + FenixFields[i].Name);
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
           P       := Result.Points[Idx];
           SDKBase := Length(P.Values);
           SetLength(P.Values, Result.Labels.Count);
           For i        := SDKBase To High(P.Values) Do
            P.Values[i] := NaN;
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
                P.Values[i] := TJSONNumber(Pair.JsonValue).AsDouble;
            End;
           SDKValue := State.GetValue('airliner_lvars');
           If SDKValue Is TJSONObject Then
            Begin
             SDKValue := TJSONObject(SDKValue).GetValue('fields');
             If SDKValue Is TJSONObject Then
              For Pair In TJSONObject(SDKValue) Do
               If (Pair.JsonValue Is TJSONNumber) And ExtraFields.TryGetValue('AIRLINER:' + Pair.JsonString.Value, i) Then
                P.Values[i] := TJSONNumber(Pair.JsonValue).AsDouble;
            End;
           SDKValue := State.GetValue('gsx_lvars');
           If SDKValue Is TJSONObject Then
            Begin
             SDKValue := TJSONObject(SDKValue).GetValue('fields');
             If SDKValue Is TJSONObject Then
              For Pair In TJSONObject(SDKValue) Do
               If (Pair.JsonValue Is TJSONNumber) And ExtraFields.TryGetValue('GSX:' + Pair.JsonString.Value, i) Then
                P.Values[i] := TJSONNumber(Pair.JsonValue).AsDouble;
            End;
           SDKValue := State.GetValue('fshud');
           If SDKValue Is TJSONObject Then
            Begin
             SDKValue := TJSONObject(SDKValue).GetValue('fields');
             If SDKValue Is TJSONObject Then
              For Pair In TJSONObject(SDKValue) Do
               If (Pair.JsonValue Is TJSONNumber) And ExtraFields.TryGetValue('FSHUD:' + Pair.JsonString.Value, i) Then
                P.Values[i] := TJSONNumber(Pair.JsonValue).AsDouble;
            End;
           Result.Points[Idx] := P;
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
   P     : TPlotPoint;
   FS    : TFormatSettings;
  Begin
   Data                := LoadTrip(ID);
   Lines               := TStringList.Create;
   FS                  := TFormatSettings.Create;
   FS.DecimalSeparator := '.';
   Try
    Lines.Add('<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://www.opengis.net/kml/2.2"><Document><Placemark><name>Flight ' + IntToStr(ID) + '</name><LineString><altitudeMode>absolute</altitudeMode><coordinates>');
    For P In Data.Points Do
     Lines.Add(FloatToStr(P.Lon, FS) + ',' + FloatToStr(P.Lat, FS) + ',' + FloatToStr(P.Values[Data.Labels.IndexOf('plane_altitude')] * 0.3048, FS));
    Lines.Add('</coordinates></LineString></Placemark></Document></kml>');
    Lines.SaveToFile(FileName, TEncoding.UTF8);
   Finally
    Lines.Free;
    Data.Free;
   End;
  End;

End.
