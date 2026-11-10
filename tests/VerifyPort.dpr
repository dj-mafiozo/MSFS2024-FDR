Program VerifyPort;

{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU,
 Winapi.Windows, System.SysUtils, System.IOUtils, System.Classes, System.Math,

 TelemetryCatalogU In '..\src\telemetry\TelemetryCatalogU.pas', FlightTelemetryU In '..\src\telemetry\FlightTelemetryU.pas',

 SimConnectClientU In '..\src\simconnect\SimConnectClientU.pas', FlightDatabaseU In '..\src\data\FlightDatabaseU.pas',

 FlightRecorderU In '..\src\recording\FlightRecorderU.pas', FacilitiesU In '..\src\simconnect\FacilitiesU.pas', EventFilterU In '..\src\recording\EventFilterU.pas';

Type
 TProbe = Class

  Count     : Integer;
  Retracted : Integer;

  Procedure Commit(Const Name : String; Const o : TOccurrence; Seq : Int64);

  Procedure Retract(Seq : Int64);

 End;

Procedure TProbe.Commit(Const Name : String; Const o : TOccurrence; Seq : Int64);
 Begin
  Inc(Count);
 End;

Procedure TProbe.Retract(Seq : Int64);
 Begin
  Inc(Retracted);
 End;

Procedure Require(b : Boolean; Const Message : String);
 Begin
  If Not b Then
   Raise Exception.Create(Message);
 End;

Var
 Root     : String;
 FileName : String;
 DB       : TFlightDatabase;
 Rec      : TFlightRecorder;
 Payload  : TBytes;
 Header   : Array [0..9] Of DWORD;

 OpenPacket : Array[0..76] Of DWORD;
 Packet     : TBytes;
 Event      : Array [0..5] Of DWORD;
 Plot       : TTripPlot;
 i          : Integer;
 Trip       : Integer;
 Text       : AnsiString;

 Filter    : TEventFilter;
 Probe     : TProbe;
 o         : TOccurrence;
 r         : TRunway;
 Secondary : Boolean;
 Along     : Double;
 Cross     : Double;

Procedure SetN(Const Name : String; Value : Double);
 Var
  i : Integer;
 Begin
  For i := 0 To FieldCount - 1 Do
   If SimFields[i].Name = Name Then
    Begin
     Move(Value, Payload[SimFields[i].Offset], 8);
     Exit;
    End;
  Raise Exception.Create('Fixture field not found ' + Name);
 End;

Procedure Feed;
 Begin
  Move(Payload[0], Packet[40], Length(Payload));
  Rec.Sim.Feed(@Packet[0], Length(Packet));
 End;

Type

 [TestFixture]
 TVerifyPortTests = Class
  Public
   [Test]
   Procedure Regression;
 End;

Procedure TVerifyPortTests.Regression;
 Begin

  Root     := TestDataDirectory;
  FileName := TestDatabasePath(TPath.Combine(Root, 'port-test-' + IntToStr(GetTickCount64) + '.db'));

  DB  := TFlightDatabase.Create(TestDatabasePath(FileName), TestRuntimeFile('sqlite3.dll'));
  Rec := TFlightRecorder.Create(DB);

  Try

   Rec.IntervalMS := 1;
   SetLength(Payload, PayloadSize);
   SetLength(Packet, 40 + PayloadSize);
   FillChar(Header, SizeOf(Header), 0);
   Header[0] := Length(Packet);
   Header[2] := 8;
   Header[3] := 1;
   Header[5] := 1;
   Header[9] := FieldCount;
   Move(Header, Packet[0], 40);

   For i := 0 To FieldCount - 1 Do
    If SimFields[i].Name = 'title' Then
     Begin
      Text := 'iFly 737 MAX Test';
      Move(Text[1], Payload[SimFields[i].Offset], Length(Text));
     End;

   SetN('number_of_engines', 2);
   SetN('eng_combustion[0]', 1);
   SetN('eng_combustion[1]', 1);
   SetN('sim_on_ground', 1);
   SetN('surface_type', 4);

   SetN('time_zulu.year', 2026);
   SetN('time_zulu.month', 10);
   SetN('time_zulu.day', 12);
   SetN('time_zulu.seconds', 36000);

   SetN('time_local.year', 2026);
   SetN('time_local.month', 10);
   SetN('time_local.day', 12);
   SetN('time_local.seconds', 43200);
   SetN('time_local.offset', -7200);

   SetN('plane_coordinate.latitude', 52);
   SetN('plane_coordinate.longitude', 20);
   SetN('plane_altitude', 1000);
   SetN('turb_eng_n1[0]', 45);
   SetN('turb_eng_n1[1]', 46);
   SetN('autopilot_master', 1);

   FillChar(Event, SizeOf(Event), 0);
   FillChar(OpenPacket, SizeOf(OpenPacket), 0);
   OpenPacket[0]  := SizeOf(OpenPacket);
   OpenPacket[2]  := 2;
   OpenPacket[67] := 12;
   Text           := 'SunRise';
   Move(Text[1], OpenPacket[3], Length(Text));
   Rec.Sim.Feed(@OpenPacket, SizeOf(OpenPacket));
   Event[2] := 4;
   Event[4] := 1;
   Event[5] := 1;
   Rec.Sim.Feed(@Event, 24);
   Feed;

   Require(Rec.Trip = 0, 'Preparation is not Ready for flight');
   Rec.Sim.ApplyFlow(14, 'test-flight.flt');
   Sleep(20);
   Feed;
   Require(Rec.Trip > 0, 'Automatic ready-flight trip');
   Trip := Rec.Trip;

   Event[2] := 1;
   Event[3] := 3;
   Event[4] := 9999;
   Event[5] := 0;

   Rec.Sim.Feed(@Event, 24);
   Rec.Sim.Poll;

   Require(Rec.Trip = Trip, 'Optional SimConnect exception must not end flight');

   Require(Rec.Sim.Sample.Time('time_local') = '2026-10-12T12:00:00.000+02:00_0', 'SimConnect timezone sign');

   Sleep(20);
   SetN('sim_on_ground', 0);
   SetN('time_zulu.seconds', 36001);
   SetN('plane_altitude', 1100);
   Feed;

   Require(Integer(DB.Connection.ExecSQLScalar('select count(*) from trip_liftoffs')) = 1, 'Liftoff persisted');

   Sleep(20);
   SetN('sim_on_ground', 1);
   SetN('time_zulu.seconds', 36002);
   SetN('g_force', 1.2);
   Feed;

   Require(Integer(DB.Connection.ExecSQLScalar('select count(*) from trip_touchdowns')) = 1, 'Touchdown persisted');

   Sleep(20);
   SetN('eng_combustion[0]', 0);
   SetN('eng_combustion[1]', 0);
   Feed;
   Require(Rec.Trip = Trip, 'Shutdown remains in session');

   Rec.Sim.ApplyFlow(15, '');
   Require(Rec.Trip = 0, 'Flight end closes session');

   Plot := DB.LoadTrip(Trip);
   Try
    Require(Plot.Points.Count = 4, 'Samples including engine shutdown');
    Require(Abs(Plot.Points[0].Values[Plot.Labels.IndexOf('turb_eng_n1 #2')] - 46) < 0.001, 'Engine #2 history');
    Require(Plot.Points[0].Values[Plot.Labels.IndexOf('autopilot_master')] = 1, 'Packed boolean decoding');
   Finally
    Plot.Free;
   End;

   DB.DeleteTrip(Trip);

   // A long session with repeated optional SDK errors must remain one flight.

   Rec.Sim.ApplyFlow(2, 'next-flight.flt');
   Rec.Sim.ApplyFlow(14, 'next-flight.flt');

   SetN('plane_altitude', 1000);
   SetN('eng_combustion[0]', 1);
   SetN('eng_combustion[1]', 1);
   Feed;

   Trip := Rec.Trip;

   For i := 1 To 120 Do
    Begin

     Event[2] := 1;
     Event[3] := 3;
     Event[4] := 9999;

     Rec.Sim.Feed(@Event, 24);
     Rec.Sim.Poll;

     Sleep(20);
     SetN('time_zulu.seconds', 36002 + i);
     Feed;

     Require(Rec.Trip = Trip, 'Continuous recording after optional SDK exception');

    End;

   Require(Integer(DB.Connection.ExecSQLScalar('select count(*) from trip_data where trip=:t', [Trip])) = 121, '121 continuous snapshots');

   Rec.Stop;

   DB.ExportKML(Trip, TPath.Combine(Root, 'port-test.kml'));
   Require(Pos('20,52,304.8', TFile.ReadAllText(TPath.Combine(Root, 'port-test.kml'))) > 0, 'KML coordinates and feet-to-metres');

   DB.DeleteTrip(Trip);
   Require(Integer(DB.Connection.ExecSQLScalar('select count(*) from trip_data')) = 0, 'Delete samples');
   Require(Integer(DB.Connection.ExecSQLScalar('select count(*) from trip_engine_data')) = 0, 'Delete engines');

  Finally
   Rec.Free;
   DB.Free;
  End;

  Probe            := TProbe.Create;
  Filter           := TEventFilter.Create(0);
  Filter.OnCommit  := Probe.Commit;
  Filter.OnRetract := Probe.Retract;
  o                := Default(TOccurrence);

  Try

   Filter.Add('AP_MASTER', o, 10000);
   Filter.Add('AP_MASTER', o, 10100);
   Filter.Add('AP_MASTER', o, 10200);
   Filter.Flush(11000);
   Require(Probe.Count = 0, 'Fast flood suppression');

   Filter.Add('AP_MASTER', o, 20000);
   Filter.Flush(20500);
   Filter.Add('AP_MASTER', o, 21000);
   Filter.Flush(21500);
   Filter.Add('AP_MASTER', o, 22000);
   Filter.Flush(22500);
   Require((Probe.Count = 3) And (Probe.Retracted = 3), 'Slow flood retraction');

   Filter.Add('FLAPS_INCR', o, 23000);
   Filter.Add('FLAPS_INCR', o, 23001);
   Filter.Add('FLAPS_INCR', o, 23002);
   Require(Probe.Count = 6, 'Flap repeats bypass filter');

  Finally
   Filter.Free;
   Probe.Free;
  End;

  r           := Default(TRunway);
  r.Length    := 2000;
  r.Width     := 50;
  r.Heading   := 0;
  r.Primary   := 36;
  r.Secondary := 18;

  Require(MatchRunway(r, 0, 0, 0, Secondary, Along, Cross) And Not Secondary And (Abs(Along - 1000) < 0.01), 'Runway centre northbound');

  Require(Not MatchRunway(r, 0, 0.01, 0, Secondary, Along, Cross), 'Off-runway position rejected');

  System.Writeln('PASS: native SQLite schema, automatic trips, telemetry/engines, contacts, timezone, KML, deletion, flood filter and runway geometry.');

 End;

Begin
 RunNativeTests(TVerifyPortTests);

End.
