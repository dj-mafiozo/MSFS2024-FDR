program VerifyPort;
{$APPTYPE CONSOLE}
uses Winapi.Windows,System.SysUtils,System.IOUtils,System.Classes,System.Math,
  TelemetryCatalogU in '..\src\telemetry\TelemetryCatalogU.pas',FlightTelemetryU in '..\src\telemetry\FlightTelemetryU.pas',
  SimConnectClientU in '..\src\simconnect\SimConnectClientU.pas',FlightDatabaseU in '..\src\data\FlightDatabaseU.pas',
  FlightRecorderU in '..\src\recording\FlightRecorderU.pas',FacilitiesU in '..\src\simconnect\FacilitiesU.pas',EventFilterU in '..\src\recording\EventFilterU.pas';
type TProbe=class
  Count,Retracted:Integer;
  procedure Commit(const Name:string;const O:TOccurrence;Seq:Int64);
  procedure Retract(Seq:Int64);
end;
procedure TProbe.Commit(const Name:string;const O:TOccurrence;Seq:Int64);begin Inc(Count);end;
procedure TProbe.Retract(Seq:Int64);begin Inc(Retracted);end;
procedure Require(B:Boolean;const Message:string);begin if not B then raise Exception.Create(Message);end;
var Root,FileName:string;DB:TFlightDatabase;Rec:TFlightRecorder;Payload:TBytes;Header:array[0..9]of DWORD;
  Packet:TBytes;Event:array[0..5]of DWORD;Plot:TTripPlot;I,Trip:Integer;Text:AnsiString;
  Filter:TEventFilter;Probe:TProbe;O:TOccurrence;R:TRunway;Secondary:Boolean;Along,Cross:Double;
procedure SetN(const Name:string;Value:Double);
var I:Integer;
begin for I:=0 to FieldCount-1 do if SimFields[I].Name=Name then begin Move(Value,Payload[SimFields[I].Offset],8);Exit;end;raise Exception.Create('Fixture field not found '+Name);end;
procedure Feed;
begin Move(Payload[0],Packet[40],Length(Payload));Rec.Sim.Feed(@Packet[0],Length(Packet));end;
begin
  Root:=ExtractFilePath(ParamStr(0));FileName:=TPath.Combine(Root,'port-test-'+IntToStr(GetTickCount64)+'.db');
  DB:=TFlightDatabase.Create(FileName,ExpandFileName(TPath.Combine(Root,'..\bin\sqlite3.dll')));Rec:=TFlightRecorder.Create(DB);
  try
    Rec.IntervalMS:=1;SetLength(Payload,PayloadSize);SetLength(Packet,40+PayloadSize);FillChar(Header,SizeOf(Header),0);Header[0]:=Length(Packet);Header[2]:=8;Header[3]:=1;Header[5]:=1;Header[9]:=FieldCount;Move(Header,Packet[0],40);
    for I:=0 to FieldCount-1 do if SimFields[I].Name='title' then begin Text:='iFly 737 MAX Test';Move(Text[1],Payload[SimFields[I].Offset],Length(Text));end;
    SetN('number_of_engines',2);SetN('eng_combustion[0]',1);SetN('eng_combustion[1]',1);SetN('sim_on_ground',1);SetN('surface_type',4);
    SetN('time_zulu.year',2026);SetN('time_zulu.month',10);SetN('time_zulu.day',12);SetN('time_zulu.seconds',36000);
    SetN('time_local.year',2026);SetN('time_local.month',10);SetN('time_local.day',12);SetN('time_local.seconds',43200);SetN('time_local.offset',-7200);
    SetN('plane_coordinate.latitude',52);SetN('plane_coordinate.longitude',20);SetN('plane_altitude',1000);SetN('turb_eng_n1[0]',45);SetN('turb_eng_n1[1]',46);SetN('autopilot_master',1);
    FillChar(Event,SizeOf(Event),0);Event[2]:=2;Rec.Sim.Feed(@Event,12);Event[2]:=4;Event[4]:=1;Event[5]:=1;Rec.Sim.Feed(@Event,24);Feed;
    Require(Rec.Trip>0,'Automatic loaded-flight trip');Trip:=Rec.Trip;
    Event[2]:=1;Event[3]:=3;Event[4]:=9999;Event[5]:=0;
    Rec.Sim.Feed(@Event,24);Rec.Sim.Poll;
    Require(Rec.Trip=Trip,'Optional SimConnect exception must not end flight');
    Require(Rec.Sim.Sample.Time('time_local')='2026-10-12T12:00:00.000+02:00_0','SimConnect timezone sign');
    Sleep(20);SetN('sim_on_ground',0);SetN('time_zulu.seconds',36001);SetN('plane_altitude',1100);Feed;
    Require(Integer(DB.Connection.ExecSQLScalar('select count(*) from trip_liftoffs'))=1,'Liftoff persisted');
    Sleep(20);SetN('sim_on_ground',1);SetN('time_zulu.seconds',36002);SetN('g_force',1.2);Feed;
    Require(Integer(DB.Connection.ExecSQLScalar('select count(*) from trip_touchdowns'))=1,'Touchdown persisted');
    Sleep(20);SetN('eng_combustion[0]',0);SetN('eng_combustion[1]',0);Feed;Require(Rec.Trip=Trip,'Shutdown remains in session');
    Rec.Sim.ApplyFlow(15,'');Require(Rec.Trip=0,'Flight end closes session');
    Plot:=DB.LoadTrip(Trip);try Require(Plot.Points.Count=4,'Samples including engine shutdown');Require(Abs(Plot.Points[0].Values[Plot.Labels.IndexOf('turb_eng_n1 #2')]-46)<0.001,'Engine #2 history');Require(Plot.Points[0].Values[Plot.Labels.IndexOf('autopilot_master')]=1,'Packed boolean decoding');finally Plot.Free;end;
    DB.DeleteTrip(Trip);
    // A long session with repeated optional SDK errors must remain one flight.
    Rec.Sim.ApplyFlow(2,'next-flight.flt');
    SetN('plane_altitude',1000);SetN('eng_combustion[0]',1);SetN('eng_combustion[1]',1);Feed;
    Trip:=Rec.Trip;
    for I:=1 to 120 do begin
      Event[2]:=1;Event[3]:=3;Event[4]:=9999;
      Rec.Sim.Feed(@Event,24);Rec.Sim.Poll;
      Sleep(20);SetN('time_zulu.seconds',36002+I);Feed;
      Require(Rec.Trip=Trip,'Continuous recording after optional SDK exception');
    end;
    Require(Integer(DB.Connection.ExecSQLScalar('select count(*) from trip_data where trip=:t',[Trip]))=121,'121 continuous snapshots');
    Rec.Stop;
    DB.ExportKML(Trip,TPath.Combine(Root,'port-test.kml'));Require(Pos('20,52,304.8',TFile.ReadAllText(TPath.Combine(Root,'port-test.kml')))>0,'KML coordinates and feet-to-metres');
    DB.DeleteTrip(Trip);Require(Integer(DB.Connection.ExecSQLScalar('select count(*) from trip_data'))=0,'Delete samples');Require(Integer(DB.Connection.ExecSQLScalar('select count(*) from trip_engine_data'))=0,'Delete engines');
  finally Rec.Free;DB.Free;end;
  Probe:=TProbe.Create;Filter:=TEventFilter.Create(0);Filter.OnCommit:=Probe.Commit;Filter.OnRetract:=Probe.Retract;O:=Default(TOccurrence);
  try
    Filter.Add('AP_MASTER',O,10000);Filter.Add('AP_MASTER',O,10100);Filter.Add('AP_MASTER',O,10200);Filter.Flush(11000);Require(Probe.Count=0,'Fast flood suppression');
    Filter.Add('AP_MASTER',O,20000);Filter.Flush(20500);Filter.Add('AP_MASTER',O,21000);Filter.Flush(21500);Filter.Add('AP_MASTER',O,22000);Filter.Flush(22500);Require((Probe.Count=3)and(Probe.Retracted=3),'Slow flood retraction');
    Filter.Add('FLAPS_INCR',O,23000);Filter.Add('FLAPS_INCR',O,23001);Filter.Add('FLAPS_INCR',O,23002);Require(Probe.Count=6,'Flap repeats bypass filter');
  finally Filter.Free;Probe.Free;end;
  R:=Default(TRunway);R.Length:=2000;R.Width:=50;R.Heading:=0;R.Primary:=36;R.Secondary:=18;
  Require(MatchRunway(R,0,0,0,Secondary,Along,Cross) and not Secondary and (Abs(Along-1000)<0.01),'Runway centre northbound');
  Require(not MatchRunway(R,0,0.01,0,Secondary,Along,Cross),'Off-runway position rejected');
  Writeln('PASS: native SQLite schema, automatic trips, telemetry/engines, contacts, timezone, KML, deletion, flood filter and runway geometry.');
end.
