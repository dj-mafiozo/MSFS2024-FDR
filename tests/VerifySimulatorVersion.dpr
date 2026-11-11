Program VerifySimulatorVersion;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU In 'TestPathsU.pas', DUnitX.TestFramework, NativeTestRunnerU In 'NativeTestRunnerU.pas', Winapi.Windows, System.SysUtils, SimConnectClientU In '..\src\SimConnect\SimConnectClientU.pas';

Procedure Check(b : Boolean; Const m : String);
 Begin
  If Not b Then
   Raise Exception.Create(m);
 End;

Var
 Sim          : TSimConnectClient;
 Lib          : HMODULE;
 Root         : String;
 b            : TBytes;
 SetSimulator : Procedure(Name : PAnsiChar; Major : DWORD);
 Stdcall;
 Event : Procedure(ID, Value : DWORD; Path : PAnsiChar);
 Stdcall;
 Count : Function(k : Integer) : Integer;
 Stdcall;

Procedure Reject(Const Name : AnsiString; Major : DWORD);
 Begin
  SetSimulator(PAnsiChar(Name), Major);
  Sim.Connect(Root + 'MockLifecycleSim.dll');
  Check(Not Sim.Connected And Not Sim.SimulatorSupported, 'Await OPEN before enabling recording');
  Check(Count(0) = 0, 'No definitions before OPEN');
  Sim.Poll;
  Check(Not Sim.Connected And Not Sim.SimulatorSupported And Not Sim.TelemetryActive, 'Unsupported simulator rejected');
  Check(Sim.UnsupportedSimulator <> '', 'Rejection exposed to GUI');
  Check((Count(0) = 0) And (Count(1) = 0), 'Unsupported simulator gets no subscriptions');
  Event(1, 1, '');
  Event(7, 0, '');
  Event(9, 0, 'test.cfg');
  Sim.Poll;
  Check(Not Sim.Running And Not Sim.TelemetryActive, 'Lifecycle events cannot bypass rejection');
  Sim.Disconnect;
 End;

Type

 [TestFixture]
 TVerifySimulatorVersionTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifySimulatorVersionTests.Regression;
 Begin
  Root := TestDataDirectory;
  Lib  := LoadLibrary(PChar(Root + 'MockLifecycleSim.dll'));
  Check(Lib <> 0, 'Mock DLL');
  @SetSimulator := GetProcAddress(Lib, 'MockSimulator');
  @Event := GetProcAddress(Lib, 'MockEvent');
  @Count := GetProcAddress(Lib, 'MockCount');
  Sim := TSimConnectClient.Create;
  Try
   Reject('KittyHawk', 11);
   Reject('Microsoft Flight Simulator X', 10);
   Reject('Prepar3D', 6);
   Reject('Prepar3D', 12);
   Reject('SunRise', 11);
   Reject('SunRise', 13);
   SetLength(b, 12);
   b[8] := 2;
   Sim.Feed(@b[0], Length(b));
   Check(Not Sim.SimulatorSupported And (Sim.UnsupportedSimulator <> ''), 'Truncated OPEN fails closed');
   Sim.Disconnect;
   SetSimulator('SunRise', 12);
   Sim.Connect(Root + 'MockLifecycleSim.dll');
   Sim.Poll;
   Check(Sim.Connected And Sim.SimulatorSupported And (Sim.UnsupportedSimulator = ''), 'MSFS24 reconnect clears rejection');
   Check(Pos('SunRise 12.2', Sim.SimulatorVersion) = 1, 'Application version decoded independently of SimConnect DLL');
   Check((Count(0) = 3) And (Count(1) = 1), 'Bootstrap only after supported OPEN');
   Event(1, 1, '');
   Event(9, 0, 'test.cfg');
   Event(7, 0, '');
   Sim.Poll;
   Check(Sim.TelemetryActive, 'Supported simulator can record');
   System.Writeln('PASS: OPEN handshake gating, MSFS24 accepted, MSFS20/FSX/P3D/unknown/truncated rejected, no rejected subscriptions, reconnect recovery. Mock only.');
  Finally
   Sim.Free;
   FreeLibrary(Lib);
  End;

 End;

Begin
 RunNativeTests(TVerifySimulatorVersionTests);
End.
