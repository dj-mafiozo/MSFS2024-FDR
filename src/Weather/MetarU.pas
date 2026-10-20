{$StackFrames On}
Unit MetarU;

Interface

 Uses
  LocalizationU,
  Winapi.Windows, System.SysUtils, System.Classes, System.JSON, System.DateUtils, System.Net.HttpClient,
  Data.DB, FireDAC.Comp.Client, FlightDatabaseU, AppLogU;

 Type
  TMetarWorker = Class(TThread)
   Protected
    Procedure Execute; Override;
   Public
    Station     : String;
    TableName   : String;
    ReportText  : String;
    ObservedUTC : String;
    FetchedUTC  : String;
    Error       : String;
    RowID       : Integer;
    TargetUTC   : String;
    Endpoint    : String;
    Constructor Create(Const ICAO, Table_ : String; ID : Integer);
  End;

  TMetarService = Class
   Private
    fDB     : TFlightDatabase;
    fWorker : TMetarWorker;
    fNext   : UInt64;
    Procedure FinishRequest;
   Public
    Endpoint : String;
    Constructor Create(DB : TFlightDatabase);
    Destructor Destroy; Override;
    Procedure RequestHistorical(Trip : Integer);
    Procedure Tick;
  End;

 Procedure DecodeMetar(Const JSON, Station : String; Out ReportText, ObservedUTC : String);
 Procedure DecodeMetarForTime(Const JSON, Station, TargetUTC : String; Out ReportText, ObservedUTC : String);

Implementation

 Function UTCNow : String;
  Begin
   Result := DateToISO8601(TTimeZone.Local.ToUniversalTime(Now), True);
  End;

 Procedure DecodeMetar(Const JSON, Station : String; Out ReportText, ObservedUTC : String);
  Begin
   DecodeMetarForTime(JSON, Station, '', ReportText, ObservedUTC);
  End;

 Procedure DecodeMetarForTime(Const JSON, Station, TargetUTC : String; Out ReportText, ObservedUTC : String);
  Var
   V      : TJSONValue;
   Item   : TJSONValue;
   O      : TJSONObject;
   Epoch  : Int64;
   Best   : Int64;
   Target : Int64;
   DT     : TDateTime;
  Begin
   ReportText  := '';
   ObservedUTC := '';
   Best        := -1;
   Target      := High(Int64);
   If TargetUTC <> '' Then
    Begin
     If Not TryISO8601ToDate(TargetUTC, DT, True) Then
      Raise Exception.Create(Tr('Invalid METAR target UTC'));
     Target := DateTimeToUnix(DT, True);
    End;
   V := TJSONObject.ParseJSONValue(JSON);
   Try
    If Not(V Is TJSONArray) Then
     Raise Exception.Create(Tr('Invalid METAR JSON'));
    For Item In TJSONArray(V) Do
     If Item Is TJSONObject Then
      Begin
       O := TJSONObject(Item);
       If (O.GetValue('icaoId') <> Nil) And SameText(O.GetValue('icaoId').Value, Station) And (O.GetValue('obsTime') <> Nil) And TryStrToInt64(O.GetValue('obsTime').Value, Epoch) And (Epoch <= Target) And ((TargetUTC = '') Or (Target - Epoch <= 10800)) And (Epoch > Best) Then
        Begin
         If O.GetValue('rawOb') <> Nil Then
          Begin
           ReportText  := O.GetValue('rawOb').Value;
           ObservedUTC := DateToISO8601(UnixToDateTime(Epoch, True), True);
           Best        := Epoch;
          End;
        End;
      End;
    If (Trim(ReportText) = '') Or (ObservedUTC = '') Then
     Raise Exception.Create(Tr('No valid METAR for ') + Station + Tr(' at requested time'));
   Finally
    V.Free;
   End;
  End;

 Constructor TMetarWorker.Create(Const ICAO, Table_ : String; ID : Integer);
  Begin
   Inherited Create(True);
   FreeOnTerminate := False;
   Station         := ICAO;
   TableName       := Table_;
   RowID           := ID;
   Endpoint        := 'https://aviationweather.gov/api/data/metar';
  End;

 Procedure TMetarWorker.Execute;
  Var
   HTTP : THTTPClient;
   R    : IHTTPResponse;
   URL  : String;
   DT   : TDateTime;
  Begin
   HTTP := Nil;
   Try
    Try
     HTTP                   := THTTPClient.Create;
     HTTP.UserAgent         := 'MSFSFDR-VCL/1.0';
     HTTP.ConnectionTimeout := 3000;
     HTTP.ResponseTimeout   := 5000;
     URL                    := Endpoint + '?ids=' + Station + '&format=json';
     If TargetUTC <> '' Then
      Begin
       If Not TryISO8601ToDate(TargetUTC, DT, True) Then
        Raise Exception.Create(Tr('Invalid historical date'));
       URL := URL + '&hours=3&date=' + FormatDateTime('yyyy-mm-dd"T"hh:nn:ss"Z"', DT);
      End;
     R          := HTTP.Get(URL);
     FetchedUTC := UTCNow;
     If R.StatusCode <> 200 Then
      Raise Exception.CreateFmt('METAR HTTP %d', [R.StatusCode]);
     DecodeMetarForTime(R.ContentAsString, Station, TargetUTC, ReportText, ObservedUTC);
    Except
     On E : Exception Do
      Begin
       Error      := E.Message;
       FetchedUTC := UTCNow;
      End;
    End;
   Finally
    HTTP.Free;
   End;
  End;

 Constructor TMetarService.Create(DB : TFlightDatabase);
  Begin
   Inherited Create;
   fDB      := DB;
   Endpoint := 'https://aviationweather.gov/api/data/metar';
  End;

 Procedure TMetarService.FinishRequest;
  Var
   Status : String;
  Begin
   Try
    Status := 'ok';
    If fWorker.Error <> '' Then
     Status := 'unavailable';
    fDB.Connection.ExecSQL('update ' + fWorker.TableName + ' set metar_text=:r,metar_station=:s,metar_observed_utc=:o,metar_fetched_utc=:f,metar_source=:src,metar_status=:st,metar_error=:e where id=:id', [fWorker.ReportText, fWorker.Station, fWorker.ObservedUTC, fWorker.FetchedUTC, 'aviationweather.gov', Status, fWorker.Error, fWorker.RowID]);
    If fWorker.Error <> '' Then
     Log(1, 'METAR ' + fWorker.Station + ': ' + fWorker.Error);
   Finally
    FreeAndNil(fWorker);
   End;
  End;

 Destructor TMetarService.Destroy;
  Begin
   If fWorker <> Nil Then
    Begin
     fWorker.Terminate;
     fWorker.WaitFor;
     Try
      FinishRequest;
     Except
      On E : Exception Do
       Begin
        Log(1, 'METAR shutdown: ' + E.Message);
        FreeAndNil(fWorker);
       End;
     End;
    End;
   Inherited;
  End;

 Procedure TMetarService.RequestHistorical(Trip : Integer);
  Const
   Tables : Array [0 .. 1] Of String = ('trip_liftoffs', 'trip_touchdowns');
  Var
   q      : TFDQuery;
   Table_ : String;
   Time   : String;
   P      : Integer;
   Count  : Integer;
   DT     : TDateTime;
  Begin
   Count := 0;
   q     := TFDQuery.Create(Nil);
   Try
    q.Connection := fDB.Connection;
    For Table_ In Tables Do
     Begin
      q.Close;
      q.Open('select id,time_zulu from ' + Table_ + ' where trip=:t and icao is not null and length(icao)=4 and coalesce(metar_status,'''')<>''fetching''', [Trip]);
      While Not q.Eof Do
       Begin
        Time := q.FieldByName('time_zulu').AsString;
        P    := Pos('_', Time);
        If P > 0 Then
         SetLength(Time, P - 1);
        If TryISO8601ToDate(Time, DT, True) Then
         Begin
          fDB.Connection.ExecSQL('update ' + Table_ + ' set metar_status=''historical_pending'',metar_requested_utc=:u,metar_target_utc=:target where id=:id', [UTCNow, DateToISO8601(DT, True), q.FieldByName('id').AsInteger]);
          Inc(Count);
         End;
        q.Next;
       End;
     End;
   Finally
    q.Free;
   End;
   If Count = 0 Then
    Raise Exception.Create(Tr('Brak zdarzen z rozpoznanym ICAO i poprawnym czasem UTC.'));
   fNext := 0;
  End;

 Procedure TMetarService.Tick;
  Const
   Tables : Array [0 .. 1] Of String = ('trip_liftoffs', 'trip_touchdowns');
  Var
   q       : TFDQuery;
   Table_  : String;
   Station : String;
   Target  : String;
   ID      : Integer;
   i       : Integer;
   Valid   : Boolean;
  Begin
   If fWorker <> Nil Then
    Begin
     If WaitForSingleObject(fWorker.Handle, 0) <> WAIT_OBJECT_0 Then
      Exit;
     FinishRequest;
    End;
   If GetTickCount64 < fNext Then
    Exit;
   fNext := GetTickCount64 + 2000;
   q     := TFDQuery.Create(Nil);
   Try
    q.Connection := fDB.Connection;
    For Table_ In Tables Do
     Begin
      // Never backfill historical flights with today's weather.
      fDB.Connection.ExecSQL('update ' + Table_ + ' set metar_status=''unavailable'',metar_error=''Capture expired'' where metar_status=''awaiting_airport'' and julianday(''now'')-julianday(metar_requested_utc)>0.0034722222');
      q.Close;
      q.Open('select id,icao,metar_target_utc from ' + Table_ + ' where metar_status in (''awaiting_airport'',''historical_pending'') and icao is not null and length(icao)>0 order by id limit 1');
      If q.IsEmpty Then
       Continue;
      Station := UpperCase(Trim(q.FieldByName('icao').AsString));
      Valid   := Length(Station) = 4;
      For i   := 1 To Length(Station) Do
       Valid  := Valid And CharInSet(Station[i], ['A' .. 'Z', '0' .. '9']);
      ID      := q.FieldByName('id').AsInteger;
      Target  := q.FieldByName('metar_target_utc').AsString;
      q.Close;
      If Not Valid Then
       Begin
        fDB.Connection.ExecSQL('update ' + Table_ + ' set metar_status=''unavailable'',metar_error=''Invalid ICAO'' where id=:id', [ID]);
        Continue;
       End;
      fDB.Connection.ExecSQL('update ' + Table_ + ' set metar_status=''fetching'',metar_station=:s,metar_source=''aviationweather.gov'' where id=:id', [Station, ID]);
      fWorker           := TMetarWorker.Create(Station, Table_, ID);
      fWorker.Endpoint  := Endpoint;
      fWorker.TargetUTC := Target;
      fWorker.Start;
      Break;
     End;
   Finally
    q.Free;
   End;
  End;

End.
