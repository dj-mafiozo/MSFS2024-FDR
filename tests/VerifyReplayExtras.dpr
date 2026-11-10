Program VerifyReplayExtras;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU, Winapi.Windows, System.SysUtils, FireDAC.Comp.Client, FireDAC.Stan.Def, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FSHudReplayU, SimConnectClientU;

Procedure Check(b : Boolean; Const m : String);
 Begin
  If Not b Then
   Raise Exception.Create(m);
 End;

Var
 c : TFDConnection;
 r : TFSHudReplay;
 s : TSimConnectClient;

Type

 [TestFixture]
 TVerifyReplayExtrasTests = Class
  Public
   [Test]
   Procedure Regression;
 End;

Procedure TVerifyReplayExtrasTests.Regression;
 Begin
  c := TFDConnection.Create(Nil);
  r := TFSHudReplay.Create;
  s := TSimConnectClient.Create;
  Try
   c.DriverName                := 'SQLite';
   c.Params.Values['Database'] := TestDatabasePath('replay-extras.db');
   c.LoginPrompt               := False;
   c.Connected                 := True;
   c.ExecSQL('create table trip_fshud_messages(id integer primary key,trip integer,sim_utc text,payload text,message_type text)');
   c.ExecSQL('insert into trip_fshud_messages values(1,1,''2026-10-25T10:00:00Z'',''{"MessageItems":[{"Id":"1","Message":"CLEARED"}]}'',''RadioMessagesData'')');
   c.ExecSQL('insert into trip_fshud_messages values(2,1,''2026-10-25T10:00:20Z'',''{"MessageItems":[{"Id":"1","Message":"CLEARED"}]}'',''RadioMessagesData'')');
   c.ExecSQL('insert into trip_fshud_messages values(3,1,''2026-10-25T10:01:00Z'',''{"MessageItems":[{"Id":"2","Message":"TAXI"}]}'',''RadioMessagesData'')');
   r.Load(c, 1);
   Check(r.LastMessageAt('2026-10-25T09:59:59Z') = '', 'No future ATC');
   Check(r.LastMessageAt('2026-10-25T10:00:29Z') = 'CLEARED', 'ATC visible for recording time');
   Check(r.LastMessageAt('2026-10-25T10:00:31Z') = '', 'Repeated history must not extend ATC timeout');
   Check(r.LastMessageAt('2026-10-25T10:01:01Z') = 'TAXI', 'New ATC message');
   Check(r.LastMessageAt('2026-10-25T10:00:10Z') = 'CLEARED', 'Seek backwards restores ATC');
   s.Connect(TestRuntimeFile('MockLifecycleSim.dll'));
   s.Poll;
   s.ApplyFlow(2, 'CustomFlight.FLT');
   Check(Not s.FlightStarted, 'Loaded flight is not Ready for flight');
   s.ApplyFlow(14, 'CustomFlight.FLT');
   Check(s.FlightStarted, 'FLIGHT_START arms automatic recording');
   s.ApplyFlow(15, '');
   Check(Not s.FlightStarted, 'Flight end disarms recording');
   s.ApplyFlow(2, 'CustomFlight.FLT');
   Check(Not s.FlightStarted, 'Next preparation screen remains disarmed');
  Finally
   s.Free;
   r.Free;
   c.Free;
  End;
  System.Writeln('PASS: recording-time ATC lifetime, history deduplication, seek and Ready-for-flight Flow gating. Mock only.');

 End;

Begin
 RunNativeTests(TVerifyReplayExtrasTests);

End.
