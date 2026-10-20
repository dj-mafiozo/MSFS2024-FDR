program VerifyFlightPlan;
{$APPTYPE CONSOLE}
uses Winapi.Windows,Winapi.ActiveX,System.SysUtils,System.Classes,System.IOUtils,System.Math,
 IdHTTP,FlightPlanU,FlightDatabaseU,FlightRecorderU,SimConnectClientU,FlightTelemetryU;
procedure Require(B:Boolean;const M:string);begin if not B then raise Exception.Create(M);end;
const Route='{"departureAirport":{"ident":"EPLL"},"destinationAirport":{"ident":"EPLL"},'+
 '"departureRunway":{"number":"25","designator":""},"destinationRunway":{"number":"25","designator":""},'+
 '"departure":"ADOX2W","departureTransition":"ADOXO","arrival":"SOXE2T","arrivalTransition":"SOXER",'+
 '"approachTransition":"LL501","approach":{"type":"ILS","suffix":"Z","runway":{"number":"25","designator":""}},'+
 '"enroute":[{"fixIcao":{"ident":"SOXER"},"via":"","hasLatLon":true,"isPpos":false,"lat":52.1,"lon":19.8},'+
 '{"fixIcao":{"ident":"UNKNOWN"},"hasLatLon":false},{"fixIcao":{"ident":"LL501"},"hasLatLon":true,"lat":51.7,"lon":19.5}]}';
var Root,Name,Raw:string;P:TFlightPlan;DB:TFlightDatabase;Rec:TFlightRecorder;HTTP:TIdHTTP;Body:TStringStream;
 Packet:TBytes;ID,Req:DWORD;Path:AnsiString;Plot:TTripPlot;
begin
 CoInitialize(nil);
 Root:=ExtractFilePath(ParamStr(0));
 P:=ParsePLN(TFile.ReadAllText(Root+'fixtures\EPMO-EPMO.PLN'),'EPMO-EPMO.PLN');
 try Require(Pos('SOXE4C',P.Summary)>0,'Actual EPMO procedure');Require(P.Points.Count=0,'Do not fabricate PLN waypoints');finally P.Free;end;
 P:=ParsePLN(TFile.ReadAllText(Root+'fixtures\EPLL-EPLL.PLN'),'EPLL-EPLL.PLN');
 try Require(Pos('ADOX2W SOXE2T LL501 ILSZ.25',P.Summary)>0,'EPLL procedures and approach suffix');finally P.Free;end;
 P:=ParsePLN('<SimBase.Document><FlightPlan.FlightPlan><DepartureID>EPLL</DepartureID><DestinationID>EPLL</DestinationID>'+
  '<ATCWaypoint id="TEST"><WorldPosition>N52'+#$00B0+' 30'' 0",W20'+#$00B0+' 15'' 0",+000100.00</WorldPosition></ATCWaypoint>'+
  '</FlightPlan.FlightPlan></SimBase.Document>','test.pln');
 try Require((P.Points.Count=1) and (Abs(P.Points[0].Lat-52.5)<0.0001) and (Abs(P.Points[0].Lon+20.25)<0.0001),'DMS coordinates');finally P.Free;end;
 P:=ParseEFBRoute(Route);
 try Require(Pos('EPLL.25 ADOX2W ADOXO DCT SOXER',P.Summary)>0,'EFB enroute');Require(P.Points.Count=2,'Explicit route coordinates');Require(P.Points[1].BreakBefore,'Missing position breaks planned line');finally P.Free;end;
 Name:=Root+'route-test-'+IntToStr(GetTickCount64)+'.db';DB:=TFlightDatabase.Create(Name,Root+'sqlite3.dll');Rec:=TFlightRecorder.Create(DB);HTTP:=TIdHTTP.Create(nil);
 try
  Rec.EnableRouteBridge(19788);HTTP.Request.ContentType:='application/json';Body:=TStringStream.Create(Route,TEncoding.UTF8);
  try HTTP.Post('http://127.0.0.1:19788/efb-route',Body);finally Body.Free;end;
  Rec.Tick;Require(Pos('ADOX2W',Rec.PlanSummary)>0,'HTTP bridge delivers EFB plan');
  Rec.Sim.Connected:=True;Rec.Sim.Running:=True;Rec.Start;
  Require(Integer(DB.Connection.ExecSQLScalar('select count(*) from trip_flight_plans'))=1,'Pending EFB plan saved at trip start');
  Rec.SetFlightPlan(ParseEFBRoute(Route));Require(Integer(DB.Connection.ExecSQLScalar('select count(*) from trip_flight_plans'))=1,'Identical plan deduplicated');
  Raw:=Route.Replace('ADOX2W','TEST1');Rec.SetFlightPlan(ParseEFBRoute(Raw));
  Require(Integer(DB.Connection.ExecSQLScalar('select count(*) from trip_flight_plans'))=2,'Changed plan retained as revision');
  Plot:=DB.LoadTrip(Rec.Trip);try Require((Plot.FlightPlan<>nil) and (Pos('TEST1',Plot.FlightPlan.Summary)>0),'Plan restored from database');finally Plot.Free;end;
  ID:=Rec.Trip;Rec.Stop;DB.DeleteTrip(ID);Require(Integer(DB.Connection.ExecSQLScalar('select count(*) from trip_flight_plans'))=0,'Plan revisions deleted with flight');
  SetLength(Packet,284);ID:=15;Req:=501;Move(ID,Packet[8],4);Move(Req,Packet[12],4);Path:='C:\plans\EPLL-EPLL.PLN';Move(Path[1],Packet[24],Length(Path));
  Rec.Sim.Feed(@Packet[0],Length(Packet));Require(Rec.Sim.FlightPlanPath=string(Path),'SimConnect FlightPlan system state');
 finally HTTP.Free;Rec.Free;DB.Free;end;
 CoUninitialize;
 Writeln('PASS: actual EPMO/EPLL plans, DMS, EFB route, loopback bridge, per-flight revisions, deduplication and SimConnect path.');
end.
