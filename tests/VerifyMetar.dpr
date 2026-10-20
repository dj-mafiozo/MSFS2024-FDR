program VerifyMetar;

{$APPTYPE CONSOLE}

uses LocalizationU, Winapi.Windows,System.SysUtils,System.DateUtils,System.JSON,FlightDatabaseU,FlightTelemetryU,MetarU,AnalysisContextU,

 FireDAC.Comp.Client,IdHTTPServer,IdCustomHTTPServer,IdContext;

type TResponder=class

 Calls:Integer;

 procedure Reply(Context:TIdContext;Request:TIdHTTPRequestInfo;Response:TIdHTTPResponseInfo);

end;

procedure TResponder.Reply(Context:TIdContext;Request:TIdHTTPRequestInfo;Response:TIdHTTPResponseInfo);

begin

 Inc(Calls);Response.ContentType:='application/json';

 if Request.Document='/empty' then begin Response.ResponseNo:=204;Exit;end;

 Response.ContentText:='[{"icaoId":"EPLL","rawOb":"EPLL 151200Z 25005KT 9999 SCT020 12/08 Q1013","obsTime":1792065600}]';

end;

procedure Require(B:Boolean;const M:string);begin if not B then raise Exception.Create(M);end;

var DB:TFlightDatabase;S:TFlightSample;Service:TMetarService;Server:TIdHTTPServer;Responder:TResponder;Q:TFDQuery;J:TJSONObject;

 ID,Row,OldRow:Integer;Started:UInt64;Text,Observed,UTC:string;

begin

 DecodeMetar('[{"icaoId":"EPLL","rawOb":"EPLL TEST","obsTime":1792065600}]','EPLL',Text,Observed);

 DecodeMetarForTime('[{"icaoId":"EPLL","rawOb":"FUTURE","obsTime":1792069200},{"icaoId":"EPLL","rawOb":"VALID","obsTime":1792065600},{"icaoId":"EPLL","rawOb":"OLDER","obsTime":1792062000}]','EPLL',DateToISO8601(UnixToDateTime(1792067400,True),True),Text,Observed);

 Require(Text='VALID','Historical METAR must be latest observation at or before event');

 DecodeMetar('[{"icaoId":"EPLL","rawOb":"EPLL TEST","obsTime":1792065600}]','EPLL',Text,Observed);

 Require((Text='EPLL TEST') and (Observed<>''),'METAR decode');

 try DecodeMetar('[]','EPLL',Text,Observed);raise Exception.Create('Empty should fail');except on E:Exception do Require(Pos(Tr('No valid METAR for '),E.Message)>0,'Empty observation failure');end;

 DB:=TFlightDatabase.Create(ExtractFilePath(ParamStr(0))+'metar-'+IntToStr(GetTickCount64)+'.db',ExtractFilePath(ParamStr(0))+'sqlite3.dll');

 S:=TFlightSample.Create;Server:=TIdHTTPServer.Create(nil);Responder:=TResponder.Create;Q:=TFDQuery.Create(nil);Service:=nil;

 try

  ID:=DB.StartTrip(S);OldRow:=DB.Contact(ID,S,False);Row:=DB.Contact(ID,S,True);

  UTC:=DateToISO8601(TTimeZone.Local.ToUniversalTime(Now),True);

  DB.Connection.ExecSQL('update trip_liftoffs set icao=''EPLL'' where id=:id',[OldRow]);

  DB.Connection.ExecSQL('update trip_touchdowns set icao=''EPLL'',metar_status=''awaiting_airport'',metar_requested_utc=:u,runway_length_m=2500,runway_width_m=45 where id=:id',[UTC,Row]);

  Server.Bindings.Add.IP:='127.0.0.1';Server.Bindings[0].Port:=19789;Server.OnCommandGet:=Responder.Reply;Server.Active:=True;

  Service:=TMetarService.Create(DB);Service.Endpoint:='http://127.0.0.1:19789/metar';Service.Tick;Started:=GetTickCount64;

  repeat Sleep(20);Service.Tick;until (string(DB.Connection.ExecSQLScalar('select metar_status from trip_touchdowns where id=:id',[Row]))='ok') or (GetTickCount64-Started>5000);

  Q.Connection:=DB.Connection;Q.Open('select * from trip_touchdowns where id='+IntToStr(Row));

  Require(Q.FieldByName('metar_status').AsString='ok','Async METAR stored');Require(Q.FieldByName('metar_text').AsString<>'','Raw report');

  Require(Q.FieldByName('metar_fetched_utc').AsString<>'','Capture timestamp');Require(Q.FieldByName('metar_observed_utc').AsString<>'','Observation timestamp');

  Require(Responder.Calls=1,'No METAR backfill of historical contacts');

  // Use valid simulator time for analysis of the saved event.

  DB.Connection.ExecSQL('update trip_touchdowns set time_zulu=''2026-10-15T12:00:00.000+00:00_4'' where id=:id',[Row]);Q.Close;Q.Open;

  DB.Connection.ExecSQL('update trip_liftoffs set time_zulu=''2026-10-15T12:00:00.000+00:00_4'' where trip=:id',[ID]);

  J:=BuildContactContext(DB,Q,1,1);

  try Require(J.GetValue<TJSONObject>('event').GetValue<Integer>('runway_length_m')=2500,'Runway metres in analysis');Require(Pos('EPLL',J.GetValue<TJSONObject>('event').GetValue<string>('metar_text'))=1,'METAR in analysis');finally J.Free;end;

  Service.RequestHistorical(ID);

  Require(string(DB.Connection.ExecSQLScalar('select metar_status from trip_liftoffs where id=:id',[OldRow]))='historical_pending','Historical request for takeoff');

  Require(string(DB.Connection.ExecSQLScalar('select metar_target_utc from trip_touchdowns where id=:id',[Row]))<>'','Historical target stored');

  FreeAndNil(Service);DB.Connection.ExecSQL('update trip_touchdowns set metar_status=''awaiting_airport'' where id=:id',[Row]);

  Service:=TMetarService.Create(DB);Service.Endpoint:='http://127.0.0.1:19789/empty';Service.Tick;

  Started:=GetTickCount64;

  repeat Sleep(20);Service.Tick;until (string(DB.Connection.ExecSQLScalar('select metar_status from trip_touchdowns where id=:id',[Row]))='unavailable') or (GetTickCount64-Started>5000);

  Require(string(DB.Connection.ExecSQLScalar('select metar_status from trip_touchdowns where id=:id',[Row]))='unavailable','No METAR stored as explicit unavailable');

 finally Service.Free;Q.Free;Server.Free;Responder.Free;S.Free;DB.Free;end;

 Writeln('PASS: async METAR storage, observation/capture time, no historical backfill, unavailable response, runway metres and analysis context. Mock server only.');

end.

