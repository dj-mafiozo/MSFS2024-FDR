program VerifyFSHud;
{$APPTYPE CONSOLE}
uses Winapi.Windows,System.SysUtils,System.JSON,FSHudProtocolU,FSHudClientU,FSHudDataU,
  FlightDatabaseU,FlightTelemetryU,TelemetryCatalogU,AircraftDataStoreU;
var C:TFSHudClient;D:TFSHudData;DB:TFlightDatabase;S:TFlightSample;Messages:TArray<TFSHudMessage>;
  J:TJSONObject;Path,Text,Encrypted:string;I,Trip,Index:Integer;Plot:TTripPlot;Failed:Boolean;
procedure Check(B:Boolean;const M:string);begin if not B then raise Exception.Create(M);end;
begin
  Text:='{"MessageData":{"DataType":"RadioMessagesData","Message":"'+WideChar($141)+'odz & QNH 1013"}}';
  Encrypted:=FSHudEncode(Text,'0123456789ABCDEF');Check(FSHudDecode(Encrypted,'0123456789ABCDEF')=Text,'AES/CBC UTF8 frame roundtrip');
  Failed:=False;try FSHudDecode('!','0123456789ABCDEF');except Failed:=True;end;Check(Failed,'Malformed frame rejected');
  C:=TFSHudClient.Create;D:=TFSHudData.Create(False);S:=TFlightSample.Create;
  Path:=ExtractFilePath(ParamStr(0))+'fshud-'+IntToStr(GetTickCount64)+'.db';DB:=TFlightDatabase.Create(Path,ExtractFilePath(ParamStr(0))+'sqlite3.dll');
  try
    C.Accept('{"MessageData":{"DataType":"ClientValidationResponseMessage","IsValid":true}}');Check(C.GetStatus='connected','Validation accepted');
    C.Accept(Text);Messages:=C.Take;Check(Length(Messages)=1,'Radio message captured');
    for I:=0 to FieldCount-1 do begin
      if SimFields[I].Name='time_zulu.year' then S.Numbers[I]:=2026;
      if SimFields[I].Name='time_zulu.month' then S.Numbers[I]:=10;
      if SimFields[I].Name='time_zulu.day' then S.Numbers[I]:=17;
    end;
    Trip:=DB.StartTrip(S);D.Apply(DB.Connection,Trip,S.Time('time_zulu'),Messages);
    D.Apply(DB.Connection,Trip,S.Time('time_zulu'),Messages);
    Check(DB.Connection.ExecSQLScalar('select count(*) from trip_fshud_messages')=1,'Identical message omitted');
    C.Accept('{"MessageData":{"DataType":"ApplicationSettingsMessageData","secret":"PRIVATE"}}');Check(Length(C.Take)=0,'Settings excluded');
    C.Accept('{"MessageData":{"DataType":"ApplicationStateMessage","NetworkUrls":["PRIVATE"],"ApplicationState":{"Mode":1}}}');
    Messages:=C.Take;Check(Pos('PRIVATE',Messages[0].Payload)=0,'Network addresses excluded');
    D.Apply(DB.Connection,Trip,S.Time('time_zulu'),Messages);
    C.Accept('{"MessageData":{"DataType":"RadioPanelData","PanelRadioStates":{"Com1":{"SelectedFrequency":"120.005"},"Com2":{"SelectedFrequency":"126.500"}}}}');
    D.Apply(DB.Connection,Trip,S.Time('time_zulu'),C.Take);
    C.Accept('{"MessageData":{"DataType":"UserAircraftDetailsMessage","UserAircraftDetails":{"SquawkCode0":1,"SquawkCode1":2,"SquawkCode2":3,"SquawkCode3":4}}}');
    D.Apply(DB.Connection,Trip,S.Time('time_zulu'),C.Take);
    S.FSHudDataU:=D.Snapshot;DB.RecordSample(Trip,S);
    J:=TJSONObject.ParseJSONValue(DB.Connection.ExecSQLScalar('select payload from trip_aircraft_data')) as TJSONObject;
    try Check(J.GetValue('fshud')<>nil,'FSHud state in unified sample history');finally J.Free;end;
    Plot:=DB.LoadTrip(Trip);
    try
      Index:=Plot.Labels.IndexOf('FSHud.COM1_selected_MHz');Check(Index>=0,'FSHud chart fields');
      Check(Abs(Plot.Points[0].Values[Index]-120.005)<0.0001,'COM MHz decoded with invariant decimal');
      Index:=Plot.Labels.IndexOf('FSHud.squawk_display');Check(Plot.Points[0].Values[Index]=1234,'Four squawk digits');
    finally Plot.Free;end;
    Check(DB.Connection.ExecSQLScalar('select captured_utc from trip_fshud_messages limit 1')<>'','Reception timestamp');
    I:=DB.Contact(Trip,S,False);
    Text:=DB.Connection.ExecSQLScalar('select captured_utc from trip_liftoffs where id=:i',[I]);
    DB.Connection.ExecSQL('insert into trip_fshud_messages(trip,captured_utc,sim_utc,message_type,payload) values(:t,''2099-01-01T00:00:00.000Z'',:s,''RadioMessagesData'',''{"Message":"FUTURE"}'')',[Trip,S.Time('time_zulu')]);
    J:=FSHudContext(DB.Connection,Trip,Text);
    try Check(Pos('FUTURE',J.ToJSON)=0,'Wall-clock bound excludes future radio even at same simulation time');
      Check(Pos('QNH 1013',J.ToJSON)>0,'ATC messages included once in contact context');finally J.Free;end;
    DB.DeleteTrip(Trip);Check(DB.Connection.ExecSQLScalar('select count(*) from trip_fshud_messages')=0,'FSHud cleanup');
  finally DB.Free;S.Free;D.Free;C.Free;DeleteFile(PChar(Path));end;
  Writeln('PASS: FSHud codec Unicode/malformed frames, validation, read-only allowlist, privacy filter, duplicate suppression, timestamped raw messages, snapshot history and cleanup. Offline only.');
end.
