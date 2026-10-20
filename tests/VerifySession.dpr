program VerifySession;
{$APPTYPE CONSOLE}
uses Winapi.Windows,System.SysUtils,FlightRecorderU,FlightDatabaseU,FlightTelemetryU,TelemetryCatalogU;
var DB:TFlightDatabase;R:TFlightRecorder;S:TFlightSample;Path:string;I,First,Second:Integer;
procedure Check(B:Boolean;const M:string);begin if not B then raise Exception.Create(M);end;
procedure SetN(const Name:string;Value:Double);
var K:Integer;begin for K:=0 to FieldCount-1 do if SimFields[K].Name=Name then begin S.Numbers[K]:=Value;Exit;end;end;
procedure Sample(Seconds:Integer);
begin SetN('time_zulu.seconds',Seconds);Sleep(20);R.Sim.OnSample(R.Sim,S);end;
begin
  Path:=ExtractFilePath(ParamStr(0))+'session-'+IntToStr(GetTickCount64)+'.db';
  DB:=TFlightDatabase.Create(Path,ExtractFilePath(ParamStr(0))+'sqlite3.dll');R:=TFlightRecorder.Create(DB);
  try
    S:=R.Sim.Sample;R.IntervalMS:=1;R.Sim.Connected:=True;R.Sim.Running:=True;
    for I:=0 to FieldCount-1 do if SimFields[I].Name='title' then S.Texts[I]:='Session test aircraft';
    SetN('time_zulu.year',2026);SetN('time_zulu.month',10);SetN('time_zulu.day',17);
    SetN('sim_on_ground',1);SetN('surface_type',0);SetN('number_of_engines',2);
    Sample(0);First:=R.Trip;Check(First>0,'Loaded flight starts with engines off');
    Sample(1);Check(R.Trip=First,'Boarding before engine start stays in trip');
    // Unknown surface below an airborne aircraft must not suppress flight telemetry or contacts.
    R.IntervalMS:=250;SetN('surface_type',255);SetN('sim_on_ground',0);
    for I:=1 to 6 do begin Sleep(260);Sample(I+10);end;
    Check(DB.Connection.ExecSQLScalar('select count(*) from trip_data where trip=:t and surface_type=255',[First])=6,
      'All airborne unknown-surface samples survive 250 ms interval');
    Check(DB.Connection.ExecSQLScalar('select count(*) from trip_liftoffs where trip=:t',[First])=1,
      'Liftoff detected even with unknown surface');
    SetN('sim_on_ground',1);Sleep(260);Sample(17);
    Check(DB.Connection.ExecSQLScalar('select count(*) from trip_touchdowns where trip=:t',[First])=1,
      'Touchdown detected even with unknown surface');
    SetN('surface_type',0);R.IntervalMS:=1;
    SetN('eng_combustion[0]',1);Sample(2);Check(R.Trip=First,'Engine start keeps trip');
    SetN('eng_combustion[0]',0);Sample(3);Check(R.Trip=First,'Shutdown does not end flight');
    R.Sim.Paused:=True;R.Sim.Running:=False;Sample(4);Check(R.Trip=First,'Pause/settings do not split trip');
    R.Sim.Paused:=False;R.Sim.Running:=True;Sample(5);Check(R.Trip=First,'Resume same trip');
    R.Sim.ApplyFlow(15,'');Check(R.Trip=0,'Flight end closes trip immediately');
    Sample(6);Check(R.Trip=0,'Ended session cannot restart on stale telemetry');
    R.Sim.ApplyFlow(2,'EPLL.FLT');Sample(7);Second:=R.Trip;
    Check((Second>0) and (Second<>First),'Next loaded flight gets new trip');
    R.Sim.ApplyFlow(2,'MAINMENU.FLT');Check(R.Trip=0,'Legacy main-menu FLT ends session');
    Sample(8);Check(R.Trip=0,'Menu cannot start a recording');
    Check(DB.Connection.ExecSQLScalar('select count(*) from trips')=2,'One trip per session');
    Check(DB.Connection.ExecSQLScalar('select count(*) from trip_data where trip=:t',[First])>=5,'Preflight and shutdown telemetry recorded');
    DB.DeleteTrip(First);DB.DeleteTrip(Second);
  finally R.Free;DB.Free;DeleteFile(PChar(Path));end;
  Writeln('PASS: loaded-flight recording with engines off, engine start/shutdown continuity, pause/resume, explicit flight end, next flight and main-menu fallback.');
end.
