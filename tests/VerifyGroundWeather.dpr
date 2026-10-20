program VerifyGroundWeather;
{$APPTYPE CONSOLE}
uses Winapi.Windows,System.SysUtils,System.JSON,FlightDatabaseU,FlightTelemetryU,TelemetryCatalogU,
  AnalysisContextU,FlightAnalysisU,FireDAC.Comp.Client;
var DB:TFlightDatabase;S:TFlightSample;Q:TFDQuery;J,Context:TJSONObject;Trip,EmptyTrip,I,StartID,LandingID:Integer;Path:string;
procedure Check(B:Boolean;const M:string);begin if not B then raise Exception.Create(M);end;
procedure SetN(const Name:string;N:Double);
var K:Integer;begin for K:=0 to FieldCount-1 do if SimFields[K].Name=Name then begin S.Numbers[K]:=N;Exit;end;end;
begin
  Path:=ExtractFilePath(ParamStr(0))+'ground-weather-'+IntToStr(GetTickCount64)+'.db';
  DB:=TFlightDatabase.Create(Path,ExtractFilePath(ParamStr(0))+'sqlite3.dll');S:=TFlightSample.Create;Q:=TFDQuery.Create(nil);
  try
    SetN('time_zulu.year',2026);SetN('time_zulu.month',10);SetN('time_zulu.day',17);Trip:=DB.StartTrip(S);
    StartID:=0;LandingID:=0;
    for I:=0 to 5 do begin
      SetN('time_zulu.seconds',I);SetN('ambient_temperature',20+I);SetN('ambient_pressure',29+I*0.01);
      SetN('kohlsman_setting_mb',1026);SetN('plane_altitude',1000+I*100);
      SetN('sim_on_ground',Ord((I<2) or (I=3) or (I=5)));DB.RecordSample(Trip,S);
      if I=2 then StartID:=DB.Contact(Trip,S,False);
      if I=3 then LandingID:=DB.Contact(Trip,S,True);
    end;
    J:=GroundWeatherReference(DB.Connection,Trip,'2026-10-17T00:00:02.000Z',False);
    try Check(J.GetValue('ambient_temperature').Value='21','Last ground before takeoff');Check(Pos('00:00:01',J.GetValue('utc').Value)>0,'Takeoff ground timestamp');finally J.Free;end;
    J:=GroundWeatherReference(DB.Connection,Trip,'2026-10-17T00:00:03.000Z',True);
    try Check(J.GetValue('ambient_temperature').Value='23','First landing ground, not later bounce/rollout');Check(J.GetValue('kohlsman_setting_mb').Value='1026','Setting separate from ambient pressure');finally J.Free;end;
    Q.Connection:=DB.Connection;Q.Open('select * from trip_liftoffs where id=:i',[StartID]);Context:=BuildContactContext(DB,Q,0,0);
    try J:=(Context.GetValue('weather') as TJSONObject).GetValue('ground_reference') as TJSONObject;
      Check(J.GetValue('ambient_temperature').Value='21','Reference outside selected analysis window');finally Context.Free;end;
    Q.Close;Q.Open('select * from trip_touchdowns where id=:i',[LandingID]);Context:=BuildContactContext(DB,Q,0,0);
    try J:=(Context.GetValue('weather') as TJSONObject).GetValue('ground_reference') as TJSONObject;
      Check(J.GetValue('ambient_temperature').Value='23','Landing classification in context');finally Context.Free;end;
    EmptyTrip:=DB.StartTrip(S);J:=GroundWeatherReference(DB.Connection,EmptyTrip,S.Time('time_zulu'),False);
    try Check(J.GetValue('available').Value='false','Missing reference explicit');Check(J.GetValue('ambient_temperature')=nil,'No other-trip/airborne fallback');finally J.Free;end;
    Check(Pos('weather.ground_reference',BuildAnalysisPrompt('{}','start'))>0,'Prompt ground-only policy');
    DB.DeleteTrip(Trip);DB.DeleteTrip(EmptyTrip);
  finally Q.Free;S.Free;DB.Free;DeleteFile(PChar(Path));end;
  Writeln('PASS: last pre-liftoff ground/first landing ground weather, bounce exclusion, outside-window selection, missing reference without fallback, trip isolation and prompt policy.');
end.
