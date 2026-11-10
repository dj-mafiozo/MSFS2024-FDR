Program VerifyAIModelMatching;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU, System.SysUtils, System.Classes, System.IOUtils, FSLTLU;

Procedure Check(b : Boolean; Const s : String);
 Begin
  If Not b Then
   Raise Exception.Create(s);
 End;

Var
 Root   : String;
 p      : String;
 Models : TArray<TAIModelInfo>;
 f      : TAIModelInfo;
 a      : TAIModelInfo;

Type

 [TestFixture]
 TVerifyAIModelMatchingTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyAIModelMatchingTests.Regression;
 Begin
  Root := TPath.Combine(TestDataDirectory, 'Community');
  p    := TPath.Combine(Root, 'fsltl-traffic-base\SimObjects\Airplanes\FSLTL_A320');
  ForceDirectories(p);
  TFile.WriteAllText(TPath.Combine(p, 'aircraft.cfg'), '[GENERAL]' + sLineBreak + 'icao_type_designator="A320"' + sLineBreak + '[FLTSIM.0]' + sLineBreak + 'title="FSLTL_A320_LOT"' + sLineBreak + 'icao_airline="LOT"' + sLineBreak + 'atc_id="SP-LVA"' + sLineBreak + 'ui_variation="LOT"', TEncoding.UTF8);
  p := TPath.Combine(Root, 'aig-aitraffic-oci\SimObjects\Airplanes\AIG_B38M');
  ForceDirectories(p);
  TFile.WriteAllText(TPath.Combine(p, 'aircraft.cfg'), '[GENERAL]' + sLineBreak + 'icao_type_designator="B38M"' + sLineBreak + '[FLTSIM.0]' + sLineBreak + 'title="AIGAIM_B38M_LOT"' + sLineBreak + 'icao_airline="LOT"', TEncoding.UTF8);
  Models := ReadAIModels(TArray<String>.Create(Root));
  Check(Length(Models) = 2, 'Both installed libraries found');
  If Models[0].Provider = ampFSLTL Then
   Begin
    f := Models[0];
    a := Models[1];
   End
  Else
   Begin
    f := Models[1];
    a := Models[0];
   End;
  Check(f.ICAO = 'A320', 'ICAO from cfg');
  Check(f.Airline = 'LOT', 'Airline from cfg');
  Check(AIModelMatchScore(f, 'A320', 'LOT', 'SP-LVA', '') > AIModelMatchScore(f, 'A320', 'BAW', '', ''), 'Livery match');
  f.ICAO := 'B738';
  Check(AIModelMatchScore(a, 'B38M', 'LOT', '', '') > AIModelMatchScore(f, 'B38M', 'LOT', '', ''), 'Exact AIG MAX beats substitute FSLTL NG');
  f.ICAO := 'B38M';
  Check(AIModelMatchScore(f, 'B38M', 'LOT', '', '') > AIModelMatchScore(a, 'B38M', 'LOT', '', ''), 'FSLTL wins equal match');
  f.Airline := 'BAW';
  Check(AIModelMatchScore(a, 'B38M', 'LOT', '', '') > AIModelMatchScore(f, 'B38M', 'LOT', '', ''), 'Matching AIG livery beats wrong FSLTL livery');
  Check(FSLTLProfileIndex('FSLTL_A320_LOT') >= 0, 'Compiled mapping');
  Check(FSLTLUses('FSLTL_A21N_LOT', 'TURB ENG JET THRUST:1'), 'Verified reverser input');
  Check(FSLTLUses('FSLTL_A21N_LOT', 'SIM ON GROUND'), 'Reverser ground input');
  Check(Not FSLTLUses('UNKNOWN', 'TURB ENG JET THRUST:1'), 'No guessed capabilities');
  Models := ReadAIModels(TArray<String>.Create(TPath.Combine(TestDataDirectory, 'absent')));
  Check(Length(Models) = 0, 'No installed models means no AI candidates');
  System.Writeln('PASS: installed FSLTL/AIG detection, ICAO/livery parsing, type-before-provider matching, FSLTL tie priority, exact AIG livery and compiled animation/reverser inputs. Synthetic only.');

 End;

Begin
 RunNativeTests(TVerifyAIModelMatchingTests);
End.
