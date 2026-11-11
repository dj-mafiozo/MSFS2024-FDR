Program VerifyNativeATC;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU In 'TestPathsU.pas', DUnitX.TestFramework, NativeTestRunnerU In 'NativeTestRunnerU.pas', Winapi.Windows, System.SysUtils, System.Classes, System.Net.HttpClient, FlightDatabaseU In '..\src\Data\FlightDatabaseU.pas', FlightTelemetryU In '..\src\Telemetry\FlightTelemetryU.pas', SimConnectClientU In '..\src\SimConnect\SimConnectClientU.pas', NativeATCU In '..\src\SimConnect\NativeATCU.pas', FSHudReplayU In '..\src\FSHud\FSHudReplayU.pas', RouteBridgeU In '..\src\FlightPlan\RouteBridgeU.pas';

Procedure Check(b : Boolean; Const s : String);
 Begin
  If Not b Then
   Raise Exception.Create(s);
 End;

Var
 DB     : TFlightDatabase;
 Sim    : TSimConnectClient;
 Native : TMSFSATC;
 Bridge : TRouteBridge;
 HTTP   : THTTPClient;
 Body   : TStringStream;
 s      : TFlightSample;
 Trip   : Integer;
 Replay : TFSHudReplay;
 Packet : TBytes;
 d      : Double;
 ID     : DWORD;

Procedure Send(Const ID, Text : String);
 Begin
  Body := TStringStream.Create('{"id":"' + ID + '","text":"' + Text + '"}', TEncoding.UTF8);
  Try
   Check(HTTP.Post('http://127.0.0.1:' + IntToStr(Bridge.Port) + '/atc/messages', Body).StatusCode = 202, 'POST accepted');
  Finally
   Body.Free;
  End;
 End;

Type

 [TestFixture]
 TVerifyNativeATCTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyNativeATCTests.Regression;
 Begin
  DB     := TFlightDatabase.Create(TestDatabasePath('native.mfzr'), TestRuntimeFile('sqlite3.dll'));
  Sim    := TSimConnectClient.Create;
  s      := TFlightSample.Create;
  Native := Nil;
  Bridge := Nil;
  HTTP   := THTTPClient.Create;
  Replay := TFSHudReplay.Create;
  Try
   Trip                := DB.StartTrip(s);
   Native              := TMSFSATC.Create(Sim, DB);
   Bridge              := TRouteBridge.Create(0);
   Sim.TelemetryActive := True;
   Native.Tick(Bridge, Trip, '2026-10-26T12:00:00Z');
   Send('session:1', 'Cleared for takeoff');
   Native.Tick(Bridge, Trip, '2026-10-26T12:00:01Z');
   Check(DB.Connection.ExecSQLScalar('select count(*) from trip_fshud_messages where message_type=''NativeATCLine''') = 1, 'Stored');
   Send('session:1', 'Cleared for takeoff');
   Native.Tick(Bridge, Trip, '2026-10-26T12:00:02Z');
   Check(DB.Connection.ExecSQLScalar('select count(*) from trip_fshud_messages where message_type=''NativeATCLine''') = 1, 'Deduplicated');
   Replay.Load(DB.Connection, Trip);
   Check(Pos('Cleared for takeoff', Replay.TextAt('2026-10-26T12:00:02Z')) > 0, 'Replay');
   Check(Pos('Cleared for takeoff', Replay.LastMessageAt('2026-10-26T12:00:15Z')) > 0, 'Slider 30 seconds');
   Check(Replay.LastMessageAt('2026-10-26T12:00:32Z') = '', 'Expiry');
   SetLength(Packet, 48);
   ID := 8;
   Move(ID, Packet[8], 4);
   ID := 62000;
   Move(ID, Packet[12], 4);
   d := 0;
   Move(d, Packet[40], 8);
   Native.Feed(@Packet[0], Length(Packet));
   Sim.Connected          := True;
   Sim.SimulatorSupported := True;
   Sleep(1100);
   Native.Tick(Bridge, Trip, '2026-10-26T12:00:03Z');
   Check(DB.Connection.ExecSQLScalar('select count(*) from trip_fshud_messages where message_type=''NativeATCState'' and payload like ''%ATC ASSIGNED ALTITUDE%''') > 0, 'SimConnect state including zero');
   Sim.Connected := False;
   Native.Tick(Bridge, 0, '2026-10-26T12:00:03Z');
   Send('session:2', 'Outside recording');
   Native.Tick(Bridge, 0, '2026-10-26T12:00:04Z');
   Check(DB.Connection.ExecSQLScalar('select count(*) from trip_fshud_messages where message_type=''NativeATCLine''') = 1, 'Recording scope');
  Finally
   Replay.Free;
   HTTP.Free;
   Native.Free;
   Bridge.Free;
   s.Free;
   Sim.Free;
   DB.Free;
  End;
  System.Writeln('PASS: native ATC ingress, persistence, retry deduplication, replay and slider expiry. Synthetic only.');

 End;

Begin
 RunNativeTests(TVerifyNativeATCTests);
End.
