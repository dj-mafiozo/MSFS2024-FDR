Unit SimWeatherU;

Interface

 Uses
  System.SysUtils, System.Classes, FlightDatabaseU, RouteBridgeU, FireDAC.Comp.Client;

 Type
  TSimWeatherService = Class
   Private
    fDatabase : TFlightDatabase;
    fBridge   : TRouteBridge;
    fNext     : UInt64;
    Procedure Receive(Const Text : String);
   Public
    Constructor Create(Database : TFlightDatabase; Bridge : TRouteBridge);
    Destructor  Destroy; Override;
    Procedure   Tick;
  End;

 Procedure StoreRealWeather(DB : TFDConnection; Const TableName : String; RowID : Integer; Const Station, ReportText, ObservedUTC, FetchedUTC, Status, Error, JSON : String);

Implementation

 Uses
  System.JSON, System.DateUtils, Data.DB, Winapi.Windows;

 Function NowUTC : String;
  Begin
   Result := DateToISO8601(TTimeZone.Local.ToUniversalTime(Now), True);
  End;

 Function Field(o : TJSONObject; Const Name : String) : String;
  Var
   v : TJSONValue;
  Begin
   Result := '';
   If o = Nil Then
    Exit;
   v := o.GetValue(Name);
   If (v <> Nil) And Not(v Is TJSONNull) Then
    Result := v.Value;
  End;

 Procedure StoreRealWeather(DB : TFDConnection; Const TableName : String; RowID : Integer; Const Station, ReportText, ObservedUTC, FetchedUTC, Status, Error, JSON : String);
  Begin
   If Not((TableName = 'trip_liftoffs') Or (TableName = 'trip_touchdowns')) Then
    Exit;
   DB.ExecSQL('insert or replace into trip_weather_reports(trip,contact_table,contact_id,source,requested_station,station,event_utc,requested_utc,fetched_utc,observed_utc,status,error,metar_text,raw_json) ' + 'select trip,:tb,id,''aviationweather.gov'',icao,:s,time_zulu,metar_requested_utc,:f,:o,:st,:e,:m,:j from ' + TableName + ' where id=:id', [TableName, Station, FetchedUTC, ObservedUTC, Status, Error, ReportText, JSON, RowID]);
  End;

 Constructor TSimWeatherService.Create(Database : TFlightDatabase; Bridge : TRouteBridge);
  Begin
   Inherited Create;
   fDatabase := Database;
   fBridge   := Bridge;
  End;

 Destructor TSimWeatherService.Destroy;
  Var
   q : TFDQuery;
  Begin
   q := TFDQuery.Create(Nil);
   Try
    q.Connection := fDatabase.Connection;
    q.Open('select request_id from trip_weather_reports where source=''msfs'' and status=''pending''');
    While Not q.Eof Do
     Begin
      fBridge.CancelWeather(q.Fields[0].AsString);
      q.Next;
     End;
    q.Close;
    fDatabase.Connection.ExecSQL('update trip_weather_reports set status=''unavailable'',error=''Capture ended before simulator response'' where source=''msfs'' and status=''pending''');
   Finally
    q.Free;
   End;
   Inherited;
  End;

 Procedure TSimWeatherService.Receive(Const Text : String);
  Var
   v          : TJSONValue;
   m          : TJSONValue;
   t          : TJSONValue;
   o          : TJSONObject;
   ID         : String;
   Raw        : String;
   Station    : String;
   ReportText : String;
   TAFText    : String;
   Status     : String;
   Error      : String;
  Begin
   v := TJSONObject.ParseJSONValue(Text);
   Try
    If Not(v Is TJSONObject) Then
     Exit;
    o          := TJSONObject(v);
    ID         := Field(o, 'id');
    m          := o.GetValue('metar');
    t          := o.GetValue('taf');
    Station    := '';
    ReportText := '';
    TAFText    := '';
    If m Is TJSONObject Then
     Begin
      Station    := Field(TJSONObject(m), 'icao');
      ReportText := Field(TJSONObject(m), 'metarString');
     End;
    If t Is TJSONObject Then
     TAFText := Field(TJSONObject(t), 'tafString');
    Error    := Field(o, 'metar_error');
    Status   := 'ok';
    If ReportText = '' Then
     Status := 'unavailable';
    Raw     := o.ToJSON;
    fDatabase.Connection.ExecSQL('update trip_weather_reports set station=:s,metar_text=:m,taf_text=:t,status=:st,error=:e,raw_json=:j,fetched_utc=:u where request_id=:id and source=''msfs'' and status=''pending''', [Station, ReportText, TAFText, Status, Error, Raw, NowUTC, ID]);
   Finally
    v.Free;
   End;
  End;

 Procedure TSimWeatherService.Tick;
  Const
   Tables : Array [0..1] Of String = ('trip_liftoffs', 'trip_touchdowns');
  Var
   q         : TFDQuery;
   TableName : String;
   ID        : String;
   Text      : String;
   o         : TJSONObject;
   g         : TGUID;
  Begin
   Text := fBridge.TakeWeather;
   While Text <> '' Do
    Begin
     Receive(Text);
     Text := fBridge.TakeWeather;
    End;
   If GetTickCount64 < fNext Then
    Exit;
   fNext := GetTickCount64 + 1000;
   q     := TFDQuery.Create(Nil);
   Try
    q.Connection := fDatabase.Connection;
    q.Open('select request_id from trip_weather_reports where source=''msfs'' and status=''pending'' and julianday(''now'')-julianday(requested_utc)>0.0003472222');
    While Not q.Eof Do
     Begin
      fBridge.CancelWeather(q.Fields[0].AsString);
      q.Next;
     End;
    q.Close;
    fDatabase.Connection.ExecSQL('update trip_weather_reports set status=''unavailable'',error=''Simulator weather bridge timed out'' where source=''msfs'' and status=''pending'' and julianday(''now'')-julianday(requested_utc)>0.0003472222');
    For TableName In Tables Do
     Begin
      q.SQL.Text                   := 'select c.id,c.trip,c.icao,c.time_zulu,c.metar_requested_utc,c.plane_latitude,c.plane_longitude from ' + TableName + ' c ' + 'where coalesce(c.metar_target_utc,'''')='''' and c.metar_requested_utc is not null and length(c.icao)=4 and julianday(''now'')-julianday(c.metar_requested_utc) between 0 and 0.0013888889 ' + 'and not exists(select 1 from trip_weather_reports w where w.contact_table=:tb and w.contact_id=c.id and w.source=''msfs'') order by c.id limit 4';
      q.ParamByName('tb').AsString := TableName;
      q.Open;
      While Not q.Eof Do
       Begin
        CreateGUID(g);
        ID := GUIDToString(g);
        o  := TJSONObject.Create;
        Try
         o.AddPair('id', ID);
         o.AddPair('station', UpperCase(q.FieldByName('icao').AsString));
         o.AddPair('lat', TJSONNumber.Create(q.FieldByName('plane_latitude').AsFloat));
         o.AddPair('lon', TJSONNumber.Create(q.FieldByName('plane_longitude').AsFloat));
         o.AddPair('event_utc', q.FieldByName('time_zulu').AsString);
         fDatabase.Connection.ExecSQL('insert into trip_weather_reports(trip,contact_table,contact_id,source,request_id,requested_station,event_utc,requested_utc,status) values(:t,:tb,:c,''msfs'',:id,:s,:e,:u,''pending'')', [q.FieldByName('trip').AsInteger, TableName, q.FieldByName('id').AsInteger, ID, q.FieldByName('icao').AsString, q.FieldByName('time_zulu').AsString, NowUTC]);
         fBridge.QueueWeather(ID, o.ToJSON);
        Finally
         o.Free;
        End;
        q.Next;
       End;
      q.Close;
     End;
   Finally
    q.Free;
   End;
  End;

End.
