Program VerifySubscriptions;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU In 'TestPathsU.pas', DUnitX.TestFramework, NativeTestRunnerU In 'NativeTestRunnerU.pas', Winapi.Windows, System.SysUtils, System.Math, SimConnectClientU In '..\src\SimConnect\SimConnectClientU.pas', SimVarSelectionU In '..\src\Telemetry\SimVarSelectionU.pas', TelemetryCatalogU In '..\src\Telemetry\TelemetryCatalogU.pas', FlightTelemetryU In '..\src\Telemetry\FlightTelemetryU.pas';

Type
 TProbe = Class
  Count         : Integer;
  PistonMissing : Boolean;
  Procedure Sample(Sender : TObject; s : TFlightSample);
 End;

Procedure TProbe.Sample(Sender : TObject; s : TFlightSample);
 Begin
  Inc(Count);
  PistonMissing := IsNan(s.N('recip_eng_manifold_pressure[0]'));
 End;

Procedure Check(b : Boolean; Const m : String);
 Begin
  If Not b Then
   Raise Exception.Create(m);
 End;

Var
 Sim      : TSimConnectClient;
 Probe    : TProbe;
 Lib      : HMODULE;
 Root     : String;
 i        : Integer;
 Before   : Integer;
 Def      : Integer;
 Aircraft : Procedure(n : PAnsiChar; k, e : Integer);
 Stdcall;
 Event : Procedure(ID, Value : DWORD; Path : PAnsiChar);
 Stdcall;
 State : Procedure(ID, Value : DWORD; Path : PAnsiChar);
 Stdcall;
 Basic, Full : Procedure;
 Stdcall;
 Count : Function(k : Integer) : Integer;
 Stdcall;
 Has : Function(n : PAnsiChar) : BOOL;
 Stdcall;

Type

 [TestFixture]
 TVerifySubscriptionsTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifySubscriptionsTests.Regression;
 Begin
  Root := TestDataDirectory;
  Lib  := LoadLibrary(PChar(Root + 'MockLifecycleSim.dll'));
  Check(Lib <> 0, 'DLL');
  @Aircraft := GetProcAddress(Lib, 'MockAircraft');
  @Event := GetProcAddress(Lib, 'MockEvent');
  @Basic := GetProcAddress(Lib, 'MockBasic');
  @State := GetProcAddress(Lib, 'MockState');
  @Full := GetProcAddress(Lib, 'MockFull');
  @Count := GetProcAddress(Lib, 'MockCount');
  @Has := GetProcAddress(Lib, 'MockHas');
  Sim   := TSimConnectClient.Create;
  Probe := TProbe.Create;
  Try
   Sim.OnSample := Probe.Sample;
   Sim.Connect(Root + 'MockLifecycleSim.dll');
   Event(2, 1, '');
   Sim.Poll;
   Check((Count(0) = 3) And (Count(1) = 1) And Not Sim.TelemetryActive, 'Idle must subscribe only three identity SimVars');
   Event(1, 1, '');
   Event(9, 0, 'PMDG_737\aircraft.cfg');
   Event(7, 0, '');
   Sim.Poll;
   Check(Sim.TelemetryActive, 'AircraftLoaded + SimStart activate without FlightLoaded');
   Check(Has('NAV ACTIVE FREQUENCY:1') And Has('ADF ACTIVE FREQUENCY:2') And Has('NAV DME:2'), 'NAV/ADF/DME sampled only in active flight');
   Check(Has('INCIDENCE ALPHA'), 'AoA subscribed in flight');
   Check(Has('AUTOPILOT FLIGHT DIRECTOR PITCH') And Has('AUTOPILOT FLIGHT DIRECTOR BANK') And Has('AUTOPILOT FLIGHT DIRECTOR PITCH EX1') And Has('AUTOPILOT FLIGHT DIRECTOR BANK EX1'), 'All four FD angles subscribed in flight');
   Check(Has('TURB ENG N1:1') And Has('TURB ENG N1:2'), 'Jet fields');
   Check(Has('ENG OIL QUANTITY:1') And Has('ENG OIL QUANTITY:2') And Not Has('ENG OIL QUANTITY:3'), 'New EICAS oil quantity only for existing engines');
   Check(Has('TOTAL AIR TEMPERATURE') And Has('FUEL TANK CENTER QUANTITY'), 'New EICAS environmental and tank fields');
   Check(Not Has('RECIP ENG MANIFOLD PRESSURE:1') And Not Has('PROP RPM:1') And Not Has('TURB ENG N1:3'), 'No piston, propeller or nonexistent engines');
   Check((Probe.Count > 0) And Probe.PistonMissing, 'Sparse payload decoded; excluded engine parameter unavailable');
   Before := Probe.Count;
   Def    := Count(5);
   Full;
   Event(9, 0, 'PMDG_737\aircraft.cfg');
   Sim.Poll;
   Check(Sim.TelemetryActive And (Count(5) <> Def), 'AircraftLoaded of same model rebuilds subscriptions');
   Check(Probe.Count = Before + 1, 'Old request rejected; only new model sample delivered');
   Aircraft('PMDG 737-900', 1, 2);
   Before := Probe.Count;
   Full;
   Sim.Poll;
   Check(Sim.TelemetryActive And (Probe.Count = Before + 1), 'Changed title in full packet forces fresh identity before delivery');
   Before := Probe.Count;
   Full;
   Sim.ApplyFlow(9, '');
   Sim.Poll;
   Check(Not Sim.TelemetryActive And (Count(1) = 1), 'End leaves bootstrap only');
   Check(Not Has('AUTOPILOT FLIGHT DIRECTOR PITCH') And Not Has('AUTOPILOT FLIGHT DIRECTOR BANK EX1'), 'FD angles unsubscribed after flight');
   Check(Probe.Count = Before, 'Queued old full packet discarded');
   Basic;
   Sim.Poll;
   Check(Not Sim.TelemetryActive, 'Identity updates cannot reopen ended session');
   Aircraft('PMDG DC-6B', 0, 4);
   Event(9, 0, 'PMDG_DC6\aircraft.cfg');
   Event(7, 0, '');
   Sim.Poll;
   Check(Sim.TelemetryActive And Has('RECIP ENG MANIFOLD PRESSURE:4') And Has('PROP RPM:4'), 'Piston four-engine selection');
   Check(Not Has('TURB ENG N1:1') And Not Has('RECIP ENG MANIFOLD PRESSURE:5'), 'Piston excludes turbine and excess engines');
   Event(8, 0, '');
   Sim.Poll;
   Check(Not Sim.TelemetryActive And (Count(1) = 1), 'SimStop unsubscribes');
   Aircraft('Asobo Cessna 208', 5, 1);
   Event(6, 0, 'test.FLT');
   Event(7, 0, '');
   Sim.Poll;
   Check(Sim.TelemetryActive And Has('PROP RPM:1') And Has('TURB ENG N1:1'), 'Turboprop selects turbine plus propeller');
   Check(Not Has('TURB ENG N1:2'), 'Single engine');
   Event(6, 0, 'MAINMENU.FLT');
   Sim.Poll;
   Check(Not Sim.TelemetryActive And Sim.FlightEnded, 'Main menu ends');
   State(504, 0, 'cached\aircraft.cfg');
   State(503, 1, '');
   Basic;
   Sim.Poll;
   Check(Not Sim.TelemetryActive, 'Cached AircraftLoaded state in menu cannot activate');
   Event(7, 0, '');
   Sim.Poll;
   Check(Not Sim.TelemetryActive, 'SimStart waits for fresh flight-state confirmation after explicit end');
   State(505, 0, 'next.FLT');
   Sim.Poll;
   Check(Sim.TelemetryActive, 'SimStart alone with current flight confirmation can activate');
   Sim.ApplyFlow(9, '');
   Event(7, 0, '');
   State(505, 0, 'MAINMENU.FLT');
   Sim.Poll;
   Check(Not Sim.TelemetryActive, 'SimStart with current menu flight stays idle');
   Check((Count(2) > 0) And (Count(3) > 0), 'Requests cancelled and definitions cleared');
   Check(Not UseSharedAirliner('C172', '', 0) And Not UseSharedAirliner('PMDG 777', '', 1), 'No broad common airliner catalog');
   Check(UseSharedAirliner('Asobo A320neo', '', 1), 'Known shared airliner fallback');
   System.Writeln('PASS: idle bootstrap only, AircraftLoaded/SimStart/FlightLoaded orders, jet/piston/turboprop and engine-count selection, cancellation, stale packet rejection, no menu reactivation. Mock DLL only.');
  Finally
   Sim.Free;
   Probe.Free;
   FreeLibrary(Lib);
  End;

 End;

Begin
 RunNativeTests(TVerifySubscriptionsTests);
End.
