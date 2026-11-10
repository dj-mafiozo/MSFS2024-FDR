Program VerifySession;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU,
 Winapi.Windows, System.SysUtils, FlightRecorderU, FlightDatabaseU, FlightTelemetryU, TelemetryCatalogU;

Var
 DB     : TFlightDatabase;
 r      : TFlightRecorder;
 s      : TFlightSample;
 Path   : String;
 i      : Integer;
 First  : Integer;
 Second : Integer;

Procedure Check(b : Boolean; Const m : String);
 Begin
  If Not b Then
   Raise Exception.Create(m);
 End;

Procedure SetN(Const Name : String; Value : Double);
 Var
  k : Integer;
 Begin
  For k := 0 To FieldCount - 1 Do
   If SimFields[k].Name = Name Then
    Begin
     s.Numbers[k] := Value;
     Exit;
    End;
 End;

Procedure Sample(Seconds : Integer);
 Begin
  SetN('time_zulu.seconds', Seconds);
  Sleep(20);
  r.Sim.OnSample(r.Sim, s);
 End;

Type

 [TestFixture]
 TVerifySessionTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifySessionTests.Regression;
 Begin
  Path := TestDatabasePath(ExtractFilePath(ParamStr(0)) + 'session-' + IntToStr(GetTickCount64) + '.db');
  DB   := TFlightDatabase.Create(TestDatabasePath(Path), ExtractFilePath(ParamStr(0)) + 'sqlite3.dll');
  r    := TFlightRecorder.Create(DB);
  Try
   s                        := r.Sim.Sample;
   r.IntervalMS             := 1;
   r.Sim.SimulatorSupported := True;
   r.Sim.Connected          := True;
   r.Sim.Running            := True;
   For i                    := 0 To FieldCount - 1 Do
    If SimFields[i].Name = 'title' Then
     s.Texts[i] := 'Session test aircraft';
   SetN('time_zulu.year', 2026);
   SetN('time_zulu.month', 10);
   SetN('time_zulu.day', 17);
   SetN('sim_on_ground', 1);
   SetN('surface_type', 0);
   SetN('number_of_engines', 2);
   Sample(0);
   Check(r.Trip = 0, 'Preparation screen does not record');
   r.Sim.ApplyFlow(14, 'EPLL.FLT');
   Sample(0);
   First := r.Trip;
   Check(First > 0, 'Loaded flight starts with engines off');
   Sample(1);
   Check(r.Trip = First, 'Boarding before engine start stays in trip');
   // Unknown surface below an airborne aircraft must not suppress flight telemetry or contacts.
   r.IntervalMS := 250;
   SetN('surface_type', 255);
   SetN('sim_on_ground', 0);
   For i := 1 To 6 Do
    Begin
     Sleep(260);
     Sample(i + 10);
    End;
   Check(DB.Connection.ExecSQLScalar('select count(*) from trip_data where trip=:t and surface_type=255', [First]) = 6, 'All airborne unknown-surface samples survive 250 ms interval');
   Check(DB.Connection.ExecSQLScalar('select count(*) from trip_liftoffs where trip=:t', [First]) = 1, 'Liftoff detected even with unknown surface');
   SetN('sim_on_ground', 1);
   Sleep(260);
   Sample(17);
   Check(DB.Connection.ExecSQLScalar('select count(*) from trip_touchdowns where trip=:t', [First]) = 1, 'Touchdown detected even with unknown surface');
   SetN('surface_type', 0);
   r.IntervalMS := 1;
   SetN('eng_combustion[0]', 1);
   Sample(2);
   Check(r.Trip = First, 'Engine start keeps trip');
   SetN('eng_combustion[0]', 0);
   Sample(3);
   Check(r.Trip = First, 'Shutdown does not end flight');
   r.Sim.Paused  := True;
   r.Sim.Running := False;
   Sample(4);
   Check(r.Trip = First, 'Pause/settings do not split trip');
   r.Sim.Paused  := False;
   r.Sim.Running := True;
   Sample(5);
   Check(r.Trip = First, 'Resume same trip');
   r.Sim.ApplyFlow(15, '');
   Check(r.Trip = 0, 'Flight end closes trip immediately');
   Sample(6);
   Check(r.Trip = 0, 'Ended session cannot restart on stale telemetry');
   r.Sim.ApplyFlow(2, 'EPLL.FLT');
   Sample(7);
   Second := r.Trip;
   Check((Second > 0) And (Second <> First), 'Next loaded flight gets new trip');
   r.Sim.ApplyFlow(2, 'MAINMENU.FLT');
   Check(r.Trip = 0, 'Legacy main-menu FLT ends session');
   Sample(8);
   Check(r.Trip = 0, 'Menu cannot start a recording');
   Check(DB.Connection.ExecSQLScalar('select count(*) from trips') = 2, 'One trip per session');
   Check(DB.Connection.ExecSQLScalar('select count(*) from trip_data where trip=:t', [First]) >= 5, 'Preflight and shutdown telemetry recorded');
   DB.DeleteTrip(First);
   DB.DeleteTrip(Second);
  Finally
   r.Free;
   DB.Free;
   DeleteFile(PChar(Path));
  End;
  System.Writeln('PASS: loaded-flight recording with engines off, engine start/shutdown continuity, pause/resume, explicit flight end, next flight and main-menu fallback.');

 End;

Begin
 RunNativeTests(TVerifySessionTests);
End.
