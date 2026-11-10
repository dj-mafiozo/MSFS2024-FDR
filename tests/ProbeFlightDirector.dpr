Program ProbeFlightDirector;
{$APPTYPE CONSOLE}

Uses
 TestPathsU, Winapi.Windows, System.SysUtils, System.Math, SimConnectClientU, FlightTelemetryU;

Type
 TProbe = Class
  Count : Integer;
  Next  : UInt64;
  Procedure Sample(Sender : TObject; s : TFlightSample);
 End;

Function F(v : Double) : String;
 Begin
  If IsNan(v) Or IsInfinite(v) Then
   Result := 'missing'
  Else
   Result := FormatFloat('0.000000', v, TFormatSettings.Create('en-US'));
 End;

Procedure TProbe.Sample(Sender : TObject; s : TFlightSample);
 Begin
  Inc(Count);
  If GetTickCount64 < Next Then
   Exit;
  Next := GetTickCount64 + 1000;
  Writeln('active=', F(s.N('autopilot_flight_director_active')), ' pitch=', F(s.N('autopilot_flight_director_pitch')),
  ' bank=', F(s.N('autopilot_flight_director_bank')), ' pitch_ex1=', F(s.N('autopilot_flight_director_pitch_ex1')), ' bank_ex1=', F(s.N('autopilot_flight_director_bank_ex1')));
 End;

Var
 Sim       : TSimConnectClient;
 Probe     : TProbe;
 UntilTick : UInt64;

Begin
 Sim   := TSimConnectClient.Create;
 Probe := TProbe.Create;
 Try
  Writeln('Read-only FD probe, 8 seconds; angular channels are raw radians. Compare with the aircraft PFD.');
  Try
   Sim.OnSample := Probe.Sample;
   Sim.Connect(TestRuntimeFile('SimConnect.dll'));
   UntilTick := GetTickCount64 + 8000;
   Repeat
    Sim.Poll;
    Sleep(20);
   Until GetTickCount64 >= UntilTick;
   If Probe.Count = 0 Then
    Writeln('No active flight telemetry received; live FD output NOT verified.');
  Except
   On E : Exception Do
    Writeln('Live FD output NOT verified: ', E.Message);
  End;
 Finally
  Probe.Free;
  Sim.Free;
 End;
End.
