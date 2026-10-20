program VerifySimBrief;

{$APPTYPE CONSOLE}

uses Winapi.Windows, System.SysUtils, System.JSON, FlightDatabaseU, FlightTelemetryU,

  TelemetryCatalogU, SimBriefImportU, frmTripInfoU;

var DB:TFlightDatabase;S:TFlightSample;Path,Payload,Reason:string;Trip:Integer;V,C:TJSONObject;F:TfrmTripInfo;

procedure Check(B:Boolean;const M:string);

begin if not B then raise Exception.Create(M);end;

procedure SetN(const Name:string;N:Double);

var K:Integer;

begin for K:=0 to FieldCount-1 do if SimFields[K].Name=Name then begin S.Numbers[K]:=N;Exit;end;end;

procedure SetTrip(const ColumnName,Value:string);

begin DB.Connection.ExecSQL('update trips set '+ColumnName+'=:v where id=:t',[Value,Trip]);end;

begin

  Check(DecodeSimBriefHTML('A &amp; B &ft invalid &custom;')='A & B &ft invalid &custom;','Bare ampersands and unknown entities survive');

  Check(DecodeSimBriefHTML('&#176; &#x1F600;')=WideChar(176)+' '+WideChar($D83D)+WideChar($DE00),'Unicode numeric entities');

  Check(DecodeSimBriefHTML('&#999999999; &#xD800;')='&#999999999; &#xD800;','Invalid Unicode entities preserved');

  Check(DecodeSimBriefHTML('&amp;lt;')='&lt;','Decode once');

  Path:=ExtractFilePath(ParamStr(0))+'simbrief-'+IntToStr(GetTickCount64)+'.db';

  DB:=TFlightDatabase.Create(Path,ExtractFilePath(ParamStr(0))+'sqlite3.dll');S:=TFlightSample.Create;F:=nil;V:=nil;C:=nil;

  try

    SetN('time_zulu.year',2026);SetN('time_zulu.month',10);SetN('time_zulu.day',17);

    Trip:=DB.StartTrip(S);SetTrip('departure_icao','EPLL');SetTrip('destination_icao','EGSS');

    SetTrip('atc_id','SP-LVA');SetTrip('atc_flight_number','0131');

    Payload:='{"origin":{"icao_code":"EPLL"},"destination":{"icao_code":"EGSS"},'+

      '"times":{"sched_out":"2026-10-17T01:00:00Z"},"general":{"flight_number":"131","route":"TEST ROUTE"},'+

      '"aircraft":{"reg":"SP-LVA"},"params":{"request_id":"test"},'+

      '"text":{"plan_html":"<style>secretstyle</style><pre>OFP TEST &amp; DATA</pre>"}}';

    V:=TJSONObject.ParseJSONValue(Payload) as TJSONObject;

    Check(MatchSimBrief(DB.Connection,Trip,V,Reason),'Matching airports/date/flight/registration');

    SetTrip('destination_icao','EPLL');Check(not MatchSimBrief(DB.Connection,Trip,V,Reason),'Different destination rejected');

    SetTrip('destination_icao','');Check(not MatchSimBrief(DB.Connection,Trip,V,Reason),'Missing destination rejected');

    DB.Connection.ExecSQL('insert into trip_flight_plans(trip,captured_utc,source,format,payload) '+

      'values(:t,''test'',''MSFS24 EFB'',''EFB JSON'',:p)',

      [Trip,'{"departureAirport":{"ident":"EPLL"},"destinationAirport":{"ident":"EGSS"}}']);

    Check(MatchSimBrief(DB.Connection,Trip,V,Reason),'Active trip destination from recorded EFB route');

    SetTrip('destination_icao','EPLL');Check(not MatchSimBrief(DB.Connection,Trip,V,Reason),'Actual destination overrides EFB');

    DB.Connection.ExecSQL('delete from trip_flight_plans where trip=:t',[Trip]);

    SetTrip('destination_icao','EGSS');SetTrip('atc_id','OTHER');Check(not MatchSimBrief(DB.Connection,Trip,V,Reason),'Different registration rejected');

    SetTrip('atc_id','SP-LVA');SetTrip('atc_flight_number','132');Check(not MatchSimBrief(DB.Connection,Trip,V,Reason),'Different flight rejected');

    SetTrip('atc_flight_number','131');SetTrip('departure_zulu_time','2026-10-04T00:00:00Z');

    Check(not MatchSimBrief(DB.Connection,Trip,V,Reason),'Old OFP rejected against simulator date');

    SetTrip('departure_zulu_time','invalid');Check(not MatchSimBrief(DB.Connection,Trip,V,Reason),'Missing/invalid date rejected');

    SetTrip('departure_zulu_time','2026-10-17T00:00:00Z');

    FreeAndNil(V);

    V:=TJSONObject.ParseJSONValue(Payload.Replace('2026-10-17T01:00:00Z','2026-10-04T01:00:00Z')) as TJSONObject;

    Check(not MatchSimBrief(DB.Connection,Trip,V,Reason),'Older plan requires opt-in');

    Check(not MatchSimBrief(DB.Connection,Trip,V,Reason,True),'Older plan requires recorded route');

    DB.Connection.ExecSQL('insert into trip_flight_plans(trip,captured_utc,source,format,payload) '+

      'values(:t,''test'',''MSFS24 EFB'',''EFB JSON'',:p)',

      [Trip,'{"departureAirport":{"ident":"EPLL"},"destinationAirport":{"ident":"EGSS"},'+

      '"enroute":[{"fixIcao":{"ident":"TEST"}},{"fixIcao":{"ident":"ROUTE"}}]}']);

    Check(MatchSimBrief(DB.Connection,Trip,V,Reason,True),'Older matching route accepted');

    Check(Pos('UWAGA:',Reason)>0,'Earlier generation warning');

    TJSONObject(V.GetValue('aircraft')).AddPair('icaocode','B38M');

    TJSONObject(V.GetValue('general')).AddPair('icao_airline','LOT');

    SetTrip('atc_model','A320');Check(not MatchSimBrief(DB.Connection,Trip,V,Reason,True),'Different ICAO model rejected');

    SetTrip('atc_model','B38M');SetTrip('atc_airline','EZY');

    Check(not MatchSimBrief(DB.Connection,Trip,V,Reason,True),'Different airline rejected');SetTrip('atc_airline','LOT');

    V.AddPair('navlog',TJSONObject.ParseJSONValue('[{"ident":"TEST"},{"ident":"ROUTE"}]'));

    Check(MatchSimBrief(DB.Connection,Trip,V,Reason,True),'Expanded navlog route accepted');

    DB.Connection.ExecSQL('update trip_flight_plans set payload=:p where trip=:t',

      ['{"enroute":[{"fixIcao":{"ident":"ROUTE"}},{"fixIcao":{"ident":"TEST"}}]}',Trip]);

    Check(not MatchSimBrief(DB.Connection,Trip,V,Reason,True),'Reordered route rejected');

    TJSONObject(V.GetValue('general')).AddPair('sid_ident','SID1');

    DB.Connection.ExecSQL('update trip_flight_plans set payload=:p where trip=:t',

      ['{"departure":"SID2","enroute":[{"fixIcao":{"ident":"TEST"}},{"fixIcao":{"ident":"ROUTE"}}]}',Trip]);

    Check(not MatchSimBrief(DB.Connection,Trip,V,Reason,True),'Different SID rejected');

    DB.Connection.ExecSQL('update trip_flight_plans set format=''PLN'',payload=:p where trip=:t',

      ['<SimBase.Document><FlightPlan.FlightPlan><DepartureID>EPLL</DepartureID><DestinationID>EGSS</DestinationID>'+

       '<ATCWaypoint id="TEST"><WorldPosition>N51 0 0,E019 0 0,+000000.00</WorldPosition></ATCWaypoint>'+

       '</FlightPlan.FlightPlan></SimBase.Document>',Trip]);

    Check(MatchSimBrief(DB.Connection,Trip,V,Reason,True),'PLN fixes accepted');

    DB.Connection.ExecSQL('update trip_flight_plans set payload=replace(payload,''EGSS'',''EPLL'') where trip=:t',[Trip]);

    Check(not MatchSimBrief(DB.Connection,Trip,V,Reason,True),'PLN destination mismatch rejected');

    DB.Connection.ExecSQL('update trip_flight_plans set format=''EFB JSON'',payload=:p where trip=:t',

      ['{"enroute":[{"fixIcao":{"ident":"TEST"}},{"fixIcao":{"ident":"ROUTE"}}]}',Trip]);

    SaveSimBrief(DB.Connection,Trip,V.ToJSON,'',True);

    C:=SimBriefContext(DB.Connection,Trip);

    Check(C.GetValue('date_warning')<>nil,'Persisted opt-in and warning survive AI revalidation');FreeAndNil(C);

    F:=TfrmTripInfo.Create(nil);F.LoadTrip(DB.Connection,Trip);

    Check(Pos('UWAGA:',F.mInfo.Text)>0,'Older OFP visible in trip information');FreeAndNil(F);

    SetTrip('atc_id','OTHER');Check(not MatchSimBrief(DB.Connection,Trip,V,Reason,True),'Opt-in cannot bypass registration');

    SetTrip('atc_id','SP-LVA');SetTrip('atc_flight_number','999');

    Check(not MatchSimBrief(DB.Connection,Trip,V,Reason,True),'Opt-in cannot bypass flight number');SetTrip('atc_flight_number','131');

    DB.Connection.ExecSQL('update trip_flight_plans set payload=:p where trip=:t',

      ['{"enroute":[{"fixIcao":{"ident":"OTHER"}}]}',Trip]);

    Check(not MatchSimBrief(DB.Connection,Trip,V,Reason,True),'Different route rejected with opt-in');

    C:=SimBriefContext(DB.Connection,Trip);Check(C.GetValue('excluded_reason')<>nil,'Changed route excludes old plan');FreeAndNil(C);

    DB.Connection.ExecSQL('delete from trip_flight_plans where trip=:t',[Trip]);

    FreeAndNil(V);V:=TJSONObject.ParseJSONValue(Payload) as TJSONObject;

    SaveSimBrief(DB.Connection,Trip,Payload,'');SaveSimBrief(DB.Connection,Trip,Payload,'');

    Check(DB.Connection.ExecSQLScalar('select count(*) from trip_simbrief where trip=:t',[Trip])=1,'Import replaces current plan without duplicates');

    Check(Pos('OFP TEST &amp; DATA',SimBriefOFP(DB.Connection,Trip))>0,'Raw full OFP preserved');

    C:=SimBriefContext(DB.Connection,Trip);

    Check(Pos('TEST ROUTE',C.ToJSON)>0,'Structured plan included');

    Check(Pos('OFP TEST & DATA',SBValue(C,'ofp_text_excerpt'))>0,'OFP decoded for model');

    Check(Pos('secretstyle',C.ToJSON)=0,'Styles excluded from prompt');FreeAndNil(C);

    SaveSimBrief(DB.Connection,Trip,Payload.Replace('OFP TEST &amp; DATA',StringOfChar('X',26000)),'');

    C:=SimBriefContext(DB.Connection,Trip);

    Check(Length(SBValue(C,'ofp_text_excerpt'))=24000,'Bounded OFP text');

    Check(SBValue(C,'ofp_excerpt_truncated')='true','Explicit truncation');FreeAndNil(C);

    Check(Length(SimBriefOFP(DB.Connection,Trip))>26000,'Full OFP not truncated in database');

    SetTrip('atc_id','OTHER');C:=SimBriefContext(DB.Connection,Trip);

    Check(C.GetValue('excluded_reason')<>nil,'Revalidate plan before AI use');FreeAndNil(C);

    SetTrip('atc_id','SP-LVA');

    F:=TfrmTripInfo.Create(nil);F.LoadTrip(DB.Connection,Trip);

    Check(Pos('SimBrief - pobrano UTC',F.mInfo.Text)>0,'Trip information includes import');

    Check(Assigned(F.btnImport.OnClick) and Assigned(F.btnOFP.OnClick) and Assigned(F.FetchTimer.OnTimer),'DFM actions connected');

    DB.DeleteTrip(Trip);Check(DB.Connection.ExecSQLScalar('select count(*) from trip_simbrief')=0,'Delete trip removes OFP');

  finally F.Free;C.Free;V.Free;S.Free;DB.Free;DeleteFile(PChar(Path));end;

  Writeln('PASS: SimBrief offline matching, stale/mismatched/incomplete rejection, raw OFP storage, decoded analysis excerpt, revalidation, DFM actions and deletion.');

end.

