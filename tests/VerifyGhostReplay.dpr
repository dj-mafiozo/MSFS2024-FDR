Program VerifyGhostReplay;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU In 'TestPathsU.pas', DUnitX.TestFramework, NativeTestRunnerU In 'NativeTestRunnerU.pas', Winapi.Windows, System.SysUtils, System.Math, System.IOUtils, FSLTLU In '..\src\Visualization\FSLTLU.pas', GhostReplayU In '..\src\Visualization\GhostReplayU.pas', FlightDatabaseU In '..\src\Data\FlightDatabaseU.pas';

Procedure Check(b : Boolean; Const s : String);
 Begin
  If Not b Then
   Raise Exception.Create(s);
 End;

Var
 a     : TGhostSample;
 b     : TGhostSample;
 r     : TGhostSample;
 p     : TTripPlot;
 Point : TPlotPoint;
 g     : TGhostReplayThread;
 State : TGhostState;
 Lib   : HMODULE;
 Reset : Procedure(Old : BOOL);
 Stdcall;
 Counter : Function(i : Integer) : Integer;
 Stdcall;
 i         : Integer;
 Deadline  : UInt64;
 Before    : Double;
 Inventory : TAIModelInventory;
 Cfg       : String;
 Community : String;

Type

 [TestFixture]
 TVerifyGhostReplayTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyGhostReplayTests.Regression;
 Begin
  a            := Default(TGhostSample);
  b            := a;
  b.Seconds    := 2;
  a.Pose[1]    := 179;
  b.Pose[1]    := -179;
  a.Pose[5]    := 359;
  b.Pose[5]    := 1;
  a.Visual[0]  := NaN;
  b.Visual[0]  := 1;
  a.Visual[13] := 0;
  b.Visual[13] := 1;
  r            := GhostInterpolate(a, b, 1);
  Check(Abs(Abs(r.Pose[1]) - 180) < 0.001, 'Date line');
  Check(Abs(r.Pose[5]) < 0.001, 'Heading shortest arc');
  Check(IsNan(r.Visual[0]), 'Missing not zero');
  Check(r.Visual[13] = 0, 'Discrete held');
  b.BreakBefore := True;
  r             := GhostInterpolate(a, b, 1);
  Check(r.Pose[1] = 179, 'Gap');
  Check(GhostModelScore('B38M', 'FSLTL_B738_TEST', '') > 0, 'MAX model fallback');
  Check(GhostModelScore('B38M', 'FSLTL_B38M_TEST', '') > GhostModelScore('B38M', 'FSLTL_B738_TEST', ''), 'Prefer dedicated MAX');
  Check(GhostModelScore('A320', 'Fenix A320', '') < 0, 'No heavy addon');
  Lib := LoadLibrary(PChar(TestRuntimeFile('MockGhostSim.dll')));
  Check(Lib <> 0, 'Mock');
  @Reset := GetProcAddress(Lib, 'Reset');
  @Counter := GetProcAddress(Lib, 'Counter');
  Reset(False);
  p := TTripPlot.Create;
  g := Nil;
  Try
   p.AircraftTypeICAO := 'A320';
   p.Labels.Add('plane_latitude');
   p.Labels.Add('plane_longitude');
   p.Labels.Add('plane_altitude');
   p.Labels.Add('plane_pitch_degrees');
   p.Labels.Add('plane_bank_degrees');
   p.Labels.Add('plane_heading_degrees_true');
   p.Labels.Add('aileron_left_deflection_pct');
   For i := 0 To 2 Do
    Begin
     Point         := Default(TPlotPoint);
     Point.Seconds := i * 10;
     SetLength(Point.Values, 7);
     Point.Values[0] := 51;
     Point.Values[1] := 19;
     Point.Values[2] := 1000 + i * 100;
     Point.Values[6] := 0.5;
     p.Points.Add(Point);
    End;
   g := TGhostReplayThread.Create(p, TestRuntimeFile('MockGhostSim.dll'), '', 30, 0);
   g.Start;
   Deadline := GetTickCount64 + 5000;
   Repeat
    State := g.Snapshot;
    Sleep(20);
   Until State.Failed Or (Counter(6) > 2) Or (GetTickCount64 > Deadline);
   Check(Not State.Failed, State.Error);
   Check(Counter(6) > 2, 'Updates');
   Check(Counter(3) = 1, 'Created once');
   g.Toggle;
   Sleep(120);
   State  := g.Snapshot;
   Before := State.Position;
   Sleep(120);
   State := g.Snapshot;
   Check(Abs(State.Position - Before) < 0.02, 'Pause');
   g.Skip(10);
   Sleep(120);
   State := g.Snapshot;
   Check(Abs(State.Position - Before - 10) < 0.1, '+10s');
   g.Skip( -10);
   Sleep(120);
   State := g.Snapshot;
   Check(Abs(State.Position - Before) < 0.1, '-10s');
   FreeAndNil(g);
   Check(Counter(5) = 1, 'Removed');
   Check(Counter(1) = 1, 'Closed');
   Check(Counter(9) = 0, 'Thread owner');
   // Enumerated third-party models must also exist in the startup Community inventory.
   Reset(False);
   Inventory := TAIModelInventory.Create(TPath.Combine(TestDataDirectory, 'empty-local'), TPath.Combine(TestDataDirectory, 'empty-roaming'));
   Inventory.Start;
   Try
    g := TGhostReplayThread.Create(p, TestRuntimeFile('MockGhostSim.dll'), '', 30, 0, Inventory);
    g.Start;
    Deadline := GetTickCount64 + 5000;
    Repeat
     State := g.Snapshot;
     Sleep(20);
    Until State.Failed Or (Counter(6) > 1) Or (GetTickCount64 > Deadline);
    Check(Not State.Failed, State.Error);
    Check(State.Model = 'AIPlane_A320', 'Missing libraries fall back to default despite FSLTL enumeration');
    FreeAndNil(g);
   Finally
    Inventory.Free;
   End;
   Community := TPath.Combine(TestDataDirectory, 'packages\Community');
   Cfg       := TPath.Combine(TestDataDirectory, 'roaming\Microsoft Flight Simulator 2024');
   ForceDirectories(Cfg);
   TFile.WriteAllText(TPath.Combine(Cfg, 'UserCfg.opt'), 'InstalledPackagesPath "' + TPath.Combine(TestDataDirectory, 'packages') + '"', TEncoding.UTF8);
   Cfg := TPath.Combine(Community, 'fsltl-traffic-base\SimObjects\Airplanes\FSLTL_A320');
   ForceDirectories(Cfg);
   TFile.WriteAllText(TPath.Combine(Cfg, 'aircraft.cfg'), '[GENERAL]' + sLineBreak + 'icao_type_designator=A320' + sLineBreak + '[FLTSIM.0]' + sLineBreak + 'title=FSLTL_A320_TEST' + sLineBreak + 'icao_airline=BAW', TEncoding.UTF8);
   Cfg := TPath.Combine(Community, 'aig-aitraffic-oci\SimObjects\Airplanes\AIG_A320');
   ForceDirectories(Cfg);
   TFile.WriteAllText(TPath.Combine(Cfg, 'aircraft.cfg'), '[GENERAL]' + sLineBreak + 'icao_type_designator=A320' + sLineBreak + '[FLTSIM.0]' + sLineBreak + 'title=AIGAIM_A320_LOT' + sLineBreak + 'icao_airline=LOT', TEncoding.UTF8);
   p.Airline := 'LOT';
   Reset(False);
   Inventory := TAIModelInventory.Create('', TPath.Combine(TestDataDirectory, 'roaming'));
   Inventory.Start;
   Try
    g := TGhostReplayThread.Create(p, TestRuntimeFile('MockGhostSim.dll'), '', 30, 0, Inventory);
    g.Start;
    Deadline := GetTickCount64 + 5000;
    Repeat
     State := g.Snapshot;
     Sleep(20);
    Until State.Failed Or (Counter(6) > 1) Or (GetTickCount64 > Deadline);
    Check(Not State.Failed, State.Error);
    Check(State.Model = 'AIGAIM_A320_LOT', 'Installed AIG livery beats wrong FSLTL livery');
    FreeAndNil(g);
   Finally
    Inventory.Free;
   End;
   Reset(True);
   g := TGhostReplayThread.Create(p, TestRuntimeFile('MockGhostSim.dll'), '', 60, 0);
   g.Start;
   g.WaitFor;
   State := g.Snapshot;
   Check(State.Failed, 'Reject MSFS2020');
   Check(Counter(3) = 0, 'Never spawn in old sim');
   FreeAndNil(g);
  Finally
   g.Free;
   p.Free;
   FreeLibrary(Lib);
  End;
  System.Writeln('PASS: ghost memory cache, model matching, connection ownership, freeze/update/remove, pause, +/-10s, animation errors, MSFS24 gate. Mock only.');

 End;

Begin
 RunNativeTests(TVerifyGhostReplayTests);
End.
