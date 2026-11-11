Program VerifySimBrief;

{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU In 'TestPathsU.pas', DUnitX.TestFramework, NativeTestRunnerU In 'NativeTestRunnerU.pas',
 Winapi.Windows, System.SysUtils, System.JSON, FlightDatabaseU In '..\src\Data\FlightDatabaseU.pas', FlightTelemetryU In '..\src\Telemetry\FlightTelemetryU.pas',

 TelemetryCatalogU In '..\src\Telemetry\TelemetryCatalogU.pas', SimBriefImportU In '..\src\FlightPlan\SimBriefImportU.pas', frmTripInfoU In '..\src\Forms\frmTripInfoU.pas';

Var
 DB      : TFlightDatabase;
 s       : TFlightSample;
 Path    : String;
 Payload : String;
 Reason  : String;
 Trip    : Integer;
 v       : TJSONObject;
 c       : TJSONObject;
 f       : TfrmTripInfo;

Procedure Check(b : Boolean; Const m : String);
 Begin
  If Not b Then
   Raise Exception.Create(m);
 End;

Procedure SetN(Const Name : String; n : Double);
 Var
  k : Integer;
 Begin
  For k := 0 To FieldCount - 1 Do
   If SimFields[k].Name = Name Then
    Begin
     s.Numbers[k] := n;
     Exit;
    End;
 End;

Procedure SetTrip(Const ColumnName, Value : String);
 Begin
  DB.Connection.ExecSQL('update trips set ' + ColumnName + '=:v where id=:t', [Value, Trip]);
 End;

Type

 [TestFixture]
 TVerifySimBriefTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifySimBriefTests.Regression;
 Begin

  Check(DecodeSimBriefHTML('A &amp; B &ft invalid &custom;') = 'A & B &ft invalid &custom;', 'Bare ampersands and unknown entities survive');

  Check(DecodeSimBriefHTML('&#176; &#x1F600;') = WideChar(176) + ' ' + WideChar($D83D) + WideChar($DE00), 'Unicode numeric entities');

  Check(DecodeSimBriefHTML('&#999999999; &#xD800;') = '&#999999999; &#xD800;', 'Invalid Unicode entities preserved');

  Check(DecodeSimBriefHTML('&amp;lt;') = '&lt;', 'Decode once');

  Path := TestDatabasePath(ExtractFilePath(ParamStr(0)) + 'simbrief-' + IntToStr(GetTickCount64) + '.db');

  DB := TFlightDatabase.Create(TestDatabasePath(Path), ExtractFilePath(ParamStr(0)) + 'sqlite3.dll');
  s  := TFlightSample.Create;
  f  := Nil;
  v  := Nil;
  c  := Nil;

  Try

   SetN('time_zulu.year', 2026);
   SetN('time_zulu.month', 10);
   SetN('time_zulu.day', 17);

   Trip := DB.StartTrip(s);
   SetTrip('departure_icao', 'EPLL');
   SetTrip('destination_icao', 'EGSS');

   SetTrip('atc_id', 'SP-LVA');
   SetTrip('atc_flight_number', '0131');

   Payload := '{"origin":{"icao_code":"EPLL"},"destination":{"icao_code":"EGSS"},' +

   '"times":{"sched_out":"2026-10-17T01:00:00Z"},"general":{"flight_number":"131","route":"TEST ROUTE"},' +

   '"aircraft":{"reg":"SP-LVA"},"params":{"request_id":"test"},' +

   '"text":{"plan_html":"<style>secretstyle</style><pre>OFP TEST &amp; DATA</pre>"}}';

   v := TJSONObject.ParseJSONValue(Payload) As TJSONObject;

   Check(MatchSimBrief(DB.Connection, Trip, v, Reason), 'Matching airports/date/flight/registration');

   SetTrip('destination_icao', 'EPLL');
   Check(Not MatchSimBrief(DB.Connection, Trip, v, Reason), 'Different destination rejected');

   SetTrip('destination_icao', '');
   Check(Not MatchSimBrief(DB.Connection, Trip, v, Reason), 'Missing destination rejected');

   DB.Connection.ExecSQL('insert into trip_flight_plans(trip,captured_utc,source,format,payload) ' +

   'values(:t,''test'',''MSFS24 EFB'',''EFB JSON'',:p)',

   [Trip, '{"departureAirport":{"ident":"EPLL"},"destinationAirport":{"ident":"EGSS"}}']);

   Check(MatchSimBrief(DB.Connection, Trip, v, Reason), 'Active trip destination from recorded EFB route');

   SetTrip('destination_icao', 'EPLL');
   Check(Not MatchSimBrief(DB.Connection, Trip, v, Reason), 'Actual destination overrides EFB');

   DB.Connection.ExecSQL('delete from trip_flight_plans where trip=:t', [Trip]);

   SetTrip('destination_icao', 'EGSS');
   SetTrip('atc_id', 'OTHER');
   Check(Not MatchSimBrief(DB.Connection, Trip, v, Reason), 'Different registration rejected');

   SetTrip('atc_id', 'SP-LVA');
   SetTrip('atc_flight_number', '132');
   Check(Not MatchSimBrief(DB.Connection, Trip, v, Reason), 'Different flight rejected');

   SetTrip('atc_flight_number', '131');
   SetTrip('departure_zulu_time', '2026-10-04T00:00:00Z');

   Check(Not MatchSimBrief(DB.Connection, Trip, v, Reason), 'Old OFP rejected against simulator date');

   SetTrip('departure_zulu_time', 'invalid');
   Check(Not MatchSimBrief(DB.Connection, Trip, v, Reason), 'Missing/invalid date rejected');

   SetTrip('departure_zulu_time', '2026-10-17T00:00:00Z');

   FreeAndNil(v);

   v := TJSONObject.ParseJSONValue(Payload.Replace('2026-10-17T01:00:00Z', '2026-10-04T01:00:00Z')) As TJSONObject;

   Check(Not MatchSimBrief(DB.Connection, Trip, v, Reason), 'Older plan requires opt-in');

   Check(Not MatchSimBrief(DB.Connection, Trip, v, Reason, True), 'Older plan requires recorded route');

   DB.Connection.ExecSQL('insert into trip_flight_plans(trip,captured_utc,source,format,payload) ' +

   'values(:t,''test'',''MSFS24 EFB'',''EFB JSON'',:p)',

   [Trip, '{"departureAirport":{"ident":"EPLL"},"destinationAirport":{"ident":"EGSS"},' +

   '"enroute":[{"fixIcao":{"ident":"TEST"}},{"fixIcao":{"ident":"ROUTE"}}]}']);

   Check(MatchSimBrief(DB.Connection, Trip, v, Reason, True), 'Older matching route accepted');

   Check(Pos('UWAGA:', Reason) > 0, 'Earlier generation warning');

   TJSONObject(v.GetValue('aircraft')).AddPair('icaocode', 'B38M');

   TJSONObject(v.GetValue('general')).AddPair('icao_airline', 'LOT');

   SetTrip('atc_model', 'A320');
   Check(Not MatchSimBrief(DB.Connection, Trip, v, Reason, True), 'Different ICAO model rejected');

   SetTrip('atc_model', 'B38M');
   SetTrip('atc_airline', 'EZY');

   Check(Not MatchSimBrief(DB.Connection, Trip, v, Reason, True), 'Different airline rejected');
   SetTrip('atc_airline', 'LOT');

   v.AddPair('navlog', TJSONObject.ParseJSONValue('[{"ident":"TEST"},{"ident":"ROUTE"}]'));

   Check(MatchSimBrief(DB.Connection, Trip, v, Reason, True), 'Expanded navlog route accepted');

   DB.Connection.ExecSQL('update trip_flight_plans set payload=:p where trip=:t',

   ['{"enroute":[{"fixIcao":{"ident":"ROUTE"}},{"fixIcao":{"ident":"TEST"}}]}', Trip]);

   Check(Not MatchSimBrief(DB.Connection, Trip, v, Reason, True), 'Reordered route rejected');

   TJSONObject(v.GetValue('general')).AddPair('sid_ident', 'SID1');

   DB.Connection.ExecSQL('update trip_flight_plans set payload=:p where trip=:t',

   ['{"departure":"SID2","enroute":[{"fixIcao":{"ident":"TEST"}},{"fixIcao":{"ident":"ROUTE"}}]}', Trip]);

   Check(Not MatchSimBrief(DB.Connection, Trip, v, Reason, True), 'Different SID rejected');

   DB.Connection.ExecSQL('update trip_flight_plans set format=''PLN'',payload=:p where trip=:t',

   ['<SimBase.Document><FlightPlan.FlightPlan><DepartureID>EPLL</DepartureID><DestinationID>EGSS</DestinationID>' +

   '<ATCWaypoint id="TEST"><WorldPosition>N51 0 0,E019 0 0,+000000.00</WorldPosition></ATCWaypoint>' +

   '</FlightPlan.FlightPlan></SimBase.Document>', Trip]);

   Check(MatchSimBrief(DB.Connection, Trip, v, Reason, True), 'PLN fixes accepted');

   DB.Connection.ExecSQL('update trip_flight_plans set payload=replace(payload,''EGSS'',''EPLL'') where trip=:t', [Trip]);

   Check(Not MatchSimBrief(DB.Connection, Trip, v, Reason, True), 'PLN destination mismatch rejected');

   DB.Connection.ExecSQL('update trip_flight_plans set format=''EFB JSON'',payload=:p where trip=:t',

   ['{"enroute":[{"fixIcao":{"ident":"TEST"}},{"fixIcao":{"ident":"ROUTE"}}]}', Trip]);

   SaveSimBrief(DB.Connection, Trip, v.ToJSON, '', True);

   c := SimBriefContext(DB.Connection, Trip);

   Check(c.GetValue('date_warning') <> Nil, 'Persisted opt-in and warning survive AI revalidation');
   FreeAndNil(c);

   f := TfrmTripInfo.Create(Nil);
   f.LoadTrip(DB.Connection, Trip);

   Check(Pos('UWAGA:', f.mInfo.Text) > 0, 'Older OFP visible in trip information');
   FreeAndNil(f);

   SetTrip('atc_id', 'OTHER');
   Check(Not MatchSimBrief(DB.Connection, Trip, v, Reason, True), 'Opt-in cannot bypass registration');

   SetTrip('atc_id', 'SP-LVA');
   SetTrip('atc_flight_number', '999');

   Check(Not MatchSimBrief(DB.Connection, Trip, v, Reason, True), 'Opt-in cannot bypass flight number');
   SetTrip('atc_flight_number', '131');

   DB.Connection.ExecSQL('update trip_flight_plans set payload=:p where trip=:t',

   ['{"enroute":[{"fixIcao":{"ident":"OTHER"}}]}', Trip]);

   Check(Not MatchSimBrief(DB.Connection, Trip, v, Reason, True), 'Different route rejected with opt-in');

   c := SimBriefContext(DB.Connection, Trip);
   Check(c.GetValue('excluded_reason') <> Nil, 'Changed route excludes old plan');
   FreeAndNil(c);

   DB.Connection.ExecSQL('delete from trip_flight_plans where trip=:t', [Trip]);

   FreeAndNil(v);
   v := TJSONObject.ParseJSONValue(Payload) As TJSONObject;

   SaveSimBrief(DB.Connection, Trip, Payload, '');
   DB.Connection.ExecSQL('insert into trip_simbrief_maps(trip,plan_sha256,name,url,mime,data,captured_utc) values(:t,''fixture'',''Route'',''test.gif'',''image/gif'',x''00'',''2026-10-25T12:00:00Z'')', [Trip]);
   SaveSimBrief(DB.Connection, Trip, Payload, '');
   Check(DB.Connection.ExecSQLScalar('select count(*) from trip_simbrief_maps where trip=:t', [Trip]) = 1, 'Attaching identical plan preserves map BLOBs');

   Check(DB.Connection.ExecSQLScalar('select count(*) from trip_simbrief where trip=:t', [Trip]) = 1, 'Import replaces current plan without duplicates');

   Check(Pos('OFP TEST &amp; DATA', SimBriefOFP(DB.Connection, Trip)) > 0, 'Raw full OFP preserved');

   c := SimBriefContext(DB.Connection, Trip);

   Check(Pos('TEST ROUTE', c.ToJSON) > 0, 'Structured plan included');

   Check(Pos('OFP TEST & DATA', SBValue(c, 'ofp_text_excerpt')) > 0, 'OFP decoded for model');

   Check(Pos('secretstyle', c.ToJSON) = 0, 'Styles excluded from prompt');
   FreeAndNil(c);

   SaveSimBrief(DB.Connection, Trip, Payload.Replace('OFP TEST &amp; DATA', StringOfChar('X', 26000)), '');
   Check(DB.Connection.ExecSQLScalar('select count(*) from trip_simbrief_maps where trip=:t', [Trip]) = 0, 'Replacing a plan clears stale map BLOBs');

   c := SimBriefContext(DB.Connection, Trip);

   Check(Length(SBValue(c, 'ofp_text_excerpt')) = 24000, 'Bounded OFP text');

   Check(SBValue(c, 'ofp_excerpt_truncated') = 'true', 'Explicit truncation');
   FreeAndNil(c);

   Check(Length(SimBriefOFP(DB.Connection, Trip)) > 26000, 'Full OFP not truncated in database');

   SetTrip('atc_id', 'OTHER');
   c := SimBriefContext(DB.Connection, Trip);

   Check(c.GetValue('excluded_reason') <> Nil, 'Revalidate plan before AI use');
   FreeAndNil(c);

   SetTrip('atc_id', 'SP-LVA');

   f := TfrmTripInfo.Create(Nil);
   f.LoadTrip(DB.Connection, Trip);

   Check(Pos('SimBrief - pobrano UTC', f.mInfo.Text) > 0, 'Trip information includes import');

   Check(Assigned(f.btnImport.OnClick) And Assigned(f.btnOFP.OnClick) And Assigned(f.FetchTimer.OnTimer), 'DFM actions connected');

   DB.DeleteTrip(Trip);
   Check(DB.Connection.ExecSQLScalar('select count(*) from trip_simbrief') = 0, 'Delete trip removes OFP');

  Finally
   f.Free;
   c.Free;
   v.Free;
   s.Free;
   DB.Free;
   DeleteFile(PChar(Path));
  End;

  System.Writeln('PASS: SimBrief offline matching, stale/mismatched/incomplete rejection, raw OFP storage, decoded analysis excerpt, revalidation, DFM actions and deletion.');

 End;

Begin
 RunNativeTests(TVerifySimBriefTests);
End.
