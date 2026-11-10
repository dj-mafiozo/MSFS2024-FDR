Program VerifyFlightPlan;

{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU,
 Winapi.Windows, Winapi.ActiveX, System.SysUtils, System.Classes, System.IOUtils, System.Math,

 IdHTTP, FlightPlanU, FlightDatabaseU, FlightRecorderU, SimConnectClientU, FlightTelemetryU;

Procedure Require(b : Boolean; Const m : String);
 Begin
  If Not b Then
   Raise Exception.Create(m);
 End;

Const
 Route = '{"departureAirport":{"ident":"EPLL"},"destinationAirport":{"ident":"EPLL"},' +

 '"departureRunway":{"number":"25","designator":""},"destinationRunway":{"number":"25","designator":""},' +

 '"departure":"ADOX2W","departureTransition":"ADOXO","arrival":"SOXE2T","arrivalTransition":"SOXER",' +

 '"approachTransition":"LL501","approach":{"type":"ILS","suffix":"Z","runway":{"number":"25","designator":""}},' +

 '"enroute":[{"fixIcao":{"ident":"SOXER"},"via":"","hasLatLon":true,"isPpos":false,"lat":52.1,"lon":19.8},' +

 '{"fixIcao":{"ident":"UNKNOWN"},"hasLatLon":false},{"fixIcao":{"ident":"LL501"},"hasLatLon":true,"lat":51.7,"lon":19.5}]}';

Var
 Root   : String;
 Name   : String;
 Raw    : String;
 p      : TFlightPlan;
 DB     : TFlightDatabase;
 Rec    : TFlightRecorder;
 HTTP   : TIdHTTP;
 Body   : TStringStream;
 Packet : TBytes;
 ID     : DWORD;
 Req    : DWORD;
 Path   : AnsiString;
 Plot   : TTripPlot;

Type

 [TestFixture]
 TVerifyFlightPlanTests = Class
  Public
   [Test]
   Procedure Regression;
 End;

Procedure TVerifyFlightPlanTests.Regression;
 Begin

  CoInitialize(Nil);
  p := ParsePLN('<SimBase.Document><FlightPlan.FlightPlan><DepartureID>EPWA</DepartureID><DestinationID>EPLL</DestinationID><ATCWaypoint id=""><WorldPosition>N52 0 0,E20 0 0,0</WorldPosition>' +
  '<AltDescFP>ALT_DESC_AT_OR_ABOVE</AltDescFP><Alt1FP>5000</Alt1FP><SpeedMaxFP>210</SpeedMaxFP></ATCWaypoint></FlightPlan.FlightPlan></SimBase.Document>', 'constraints.pln');
  Try
   Require(p.Points.Count = 1, 'Coordinate-only point retained');
   Require(p.Points[0].ConstraintText = '210KT 5000A', 'PLN published restrictions');
   ResolvePlanNames(p, '{"navlog":{"fix":[{"ident":"MATCH","pos_lat":"52","pos_long":"20"},{"ident":"WRONG","pos_lat":"53","pos_long":"21"}]}}');
   Require(p.Points[0].Ident = 'MATCH', 'OFP name matched by coordinates');
  Finally
   p.Free;
  End;

  Root := TestDataDirectory;

  p := ParsePLN(TFile.ReadAllText(Root + 'fixtures\EPMO-EPMO.PLN'), 'EPMO-EPMO.PLN');

  Try
   Require(Pos('SOXE4C', p.Summary) > 0, 'Actual EPMO procedure');
   Require(p.Points.Count = 0, 'Do not fabricate PLN waypoints');
  Finally
   p.Free;
  End;

  p := ParsePLN(TFile.ReadAllText(Root + 'fixtures\EPLL-EPLL.PLN'), 'EPLL-EPLL.PLN');

  Try
   Require(Pos('ADOX2W SOXE2T LL501 ILSZ.25', p.Summary) > 0, 'EPLL procedures and approach suffix');
  Finally
   p.Free;
  End;

  p := ParsePLN('<SimBase.Document><FlightPlan.FlightPlan><DepartureID>EPLL</DepartureID><DestinationID>EPLL</DestinationID>' +

  '<ATCWaypoint id="TEST"><WorldPosition>N52' + #$00B0 + ' 30'' 0",W20' + #$00B0 + ' 15'' 0",+000100.00</WorldPosition></ATCWaypoint>' +

  '</FlightPlan.FlightPlan></SimBase.Document>', 'test.pln');

  Try
   Require((p.Points.Count = 1) And (Abs(p.Points[0].Lat - 52.5) < 0.0001) And (Abs(p.Points[0].Lon + 20.25) < 0.0001), 'DMS coordinates');
  Finally
   p.Free;
  End;

  p := ParseEFBRoute(Route);

  Try
   Require(Pos('EPLL.25 ADOX2W ADOXO DCT SOXER', p.Summary) > 0, 'EFB enroute');
   Require(p.Points.Count = 2, 'Explicit route coordinates');
   Require(p.Points[1].BreakBefore, 'Missing position breaks planned line');
  Finally
   p.Free;
  End;

  Name := Root + 'route-test-' + IntToStr(GetTickCount64) + '.db';
  DB   := TFlightDatabase.Create(TestDatabasePath(Name), Root + 'sqlite3.dll');
  Rec  := TFlightRecorder.Create(DB);
  HTTP := TIdHTTP.Create(Nil);

  Try

   Rec.EnableRouteBridge(19788);
   HTTP.Request.ContentType := 'application/json';
   Body                     := TStringStream.Create(Route, TEncoding.UTF8);

   Try
    HTTP.Post('http://127.0.0.1:19788/efb-route', Body);
   Finally
    Body.Free;
   End;

   Rec.Tick;
   Require(Pos('ADOX2W', Rec.PlanSummary) > 0, 'HTTP bridge delivers EFB plan');

   Rec.Sim.SimulatorSupported := True;
   Rec.Sim.Connected          := True;
   Rec.Sim.Running            := True;
   Rec.Start;

   Require(Integer(DB.Connection.ExecSQLScalar('select count(*) from trip_flight_plans')) = 1, 'Pending EFB plan saved at trip start');

   Rec.SetFlightPlan(ParseEFBRoute(Route));
   Require(Integer(DB.Connection.ExecSQLScalar('select count(*) from trip_flight_plans')) = 1, 'Identical plan deduplicated');

   Raw := Route.Replace('ADOX2W', 'TEST1');
   Rec.SetFlightPlan(ParseEFBRoute(Raw));

   Require(Integer(DB.Connection.ExecSQLScalar('select count(*) from trip_flight_plans')) = 2, 'Changed plan retained as revision');

   Plot := DB.LoadTrip(Rec.Trip);
   Try
    Require((Plot.FlightPlan <> Nil) And (Pos('TEST1', Plot.FlightPlan.Summary) > 0), 'Plan restored from database');
   Finally
    Plot.Free;
   End;

   ID := Rec.Trip;
   Rec.Stop;
   DB.DeleteTrip(ID);
   Require(Integer(DB.Connection.ExecSQLScalar('select count(*) from trip_flight_plans')) = 0, 'Plan revisions deleted with flight');

   SetLength(Packet, 284);
   ID  := 15;
   Req := 501;
   Move(ID, Packet[8], 4);
   Move(Req, Packet[12], 4);
   Path := TestDataDirectory + 'EPLL-EPLL.PLN';
   Move(Path[1], Packet[24], Length(Path));

   Rec.Sim.Feed(@Packet[0], Length(Packet));
   Require(Rec.Sim.FlightPlanPath = String(Path), 'SimConnect FlightPlan system state');

  Finally
   HTTP.Free;
   Rec.Free;
   DB.Free;
  End;

  CoUninitialize;

  System.Writeln('PASS: actual EPMO/EPLL plans, DMS, EFB route, loopback bridge, per-flight revisions, deduplication and SimConnect path.');

 End;

Begin
 RunNativeTests(TVerifyFlightPlanTests);

End.
