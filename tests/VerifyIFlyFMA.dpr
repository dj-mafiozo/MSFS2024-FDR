Program VerifyIFlyFMA;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU, System.SysUtils, System.Math, System.JSON, System.IOUtils, System.Generics.Collections, FlightDatabaseU, iFlyFMAU;

Procedure Check(b : Boolean; Const m : String);
 Begin
  If Not b Then
   Raise Exception.Create(m);
 End;

Var
 Plot : TTripPlot;
 p    : TPlotPoint;
 f    : T737FMA;

Procedure V(Const Name : String; n : Double);
 Var
  k : Integer;
 Begin
  k := Plot.Labels.IndexOf(Name);
  If k < 0 Then
   Begin
    k := Plot.Labels.Add(Name);
    SetLength(p.Values, k + 1);
   End;
  p.Values[k] := n;
 End;

Procedure Sample;
 Begin
  If Plot.Points.Count = 0 Then
   Plot.Points.Add(p)
  Else
   Plot.Points[0] := p;
  f               := ReconstructIFlyFMA(Plot, 0);
 End;

Procedure Historical;
 Var
  Root   : TJSONObject;
  Cases  : TJSONArray;
  Item   : TJSONValue;
  Fields : TJSONObject;
  Pair   : TJSONPair;
  n      : Integer;
 Begin
  Root := TJSONObject.ParseJSONValue(TFile.ReadAllText(TestRepositoryPath('tests\fixtures\ifly-sdk-afds.json'))) As TJSONObject;
  Try
   Cases := Root.GetValue('cases') As TJSONArray;
   Check(Cases.Count > 18, 'Actual SDK state coverage');
   For Item In Cases Do
    Begin
     Plot.Labels.Clear;
     p.Values := Nil;
     Fields   := (Item As TJSONObject).GetValue('sdk') As TJSONObject;
     For Pair In Fields Do
      V('iFlySDK.' + Pair.JsonString.Value, (Pair.JsonValue As TJSONNumber).AsDouble);
     // The old standard flags can be false despite proprietary CMD / A/T engagement.
     V('autopilot_master', 0);
     V('autothrottle_active', 0);
     Sample;
     Check(f.Engagement = (Item As TJSONObject).GetValue('expected_engagement').Value, 'Historical SDK CMD/FD selection');
     Check(f.Thrust = (Item As TJSONObject).GetValue('expected_sdk_thrust').Value, 'Historical SDK N1/SPEED with standard A/T zero');
     n := StrToInt((Item As TJSONObject).GetValue('sample').Value);
     If n = 4570 Then
      Begin
       Check(IFlyMCPValue(Plot, 0, 'ALT') = 13000, 'Historical selected altitude');
       Check(IFlyMCPValue(Plot, 0, 'HDG') = 244, 'Historical heading');
       Check(IFlyMCPValue(Plot, 0, 'SPD') = 137, 'Historical IAS');
      End;
     If n = 5293 Then
      Check(IsNan(IFlyMCPValue(Plot, 0, 'SPD')), 'Blank historical speed is not zero');
     If n = 6657 Then
      Check(IFlyMCPValue(Plot, 0, 'ALT') = 3000, 'Historical leading blank altitude digit');
    End;
  Finally
   Root.Free;
  End;
 End;

Type

 [TestFixture]
 TVerifyIFlyFMATests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyIFlyFMATests.Regression;
 Begin
  Try
   Plot := TTripPlot.Create;
   Try
    V('iFlySDK.FD_1_Switch_Status', 1);
    V('iFlySDK.CMD_A_Switch_Status', 2);
    V('iFlySDK.LNAV_Switch_Status', 2);
    V('iFlySDK.VNAV_Switch_Status', 2);
    V('iFlySDK.AT_Switch_Status', 1);
    V('iFlySDK.N1_Switch_Status', 2);
    V('autothrottle_active', 1);
    V('vertical_speed', 1500);
    Sample;
    Check(f.Estimated And (f.Roll = 'LNAV') And (f.Pitch = 'VNAV SPD') And (f.Thrust = 'N1') And (f.Engagement = 'CMD'), 'VNAV climb / lit MCP decoding');
    V('iFlySDK.CMD_A_Switch_Status', 3);
    V('iFlySDK.LNAV_Switch_Status', 3);
    V('iFlySDK.VNAV_Switch_Status', 3);
    V('iFlySDK.HDG_SEL_Switch_Status', 4);
    V('iFlySDK.VS_Switch_Status', 5);
    Sample;
    Check((f.Roll = 'HDG SEL') And (f.Pitch = 'V/S') And (f.Engagement = 'FD'), 'Pressed-unlit differs from pressed-lit');
    V('autopilot_approach_captured', 1);
    V('autopilot_approach_is_localizer', 1);
    V('autopilot_glideslope_active', 1);
    Sample;
    Check((f.Roll = 'VOR/LOC') And (f.Pitch = 'G/S'), 'Captured ILS overrides selected modes');
    V('autopilot_glideslope_active', 0);
    V('autopilot_glideslope_arm', 1);
    V('indicated_altitude', 9900);
    V('autopilot_altitude_lock_var', 10000);
    V('vertical_speed', 1200);
    V('sim_on_ground', 0);
    Sample;
    Check((f.Pitch = 'ALT ACQ') And (f.PitchArmed = 'G/S'), 'Closing altitude / armed GS');
    V('iFlySDK.FD_1_Switch_Status', 0);
    V('iFlySDK.FD_2_Switch_Status', 0);
    V('iFlySDK.CMD_A_Switch_Status', 0);
    Sample;
    Check((f.Roll = '') And (f.Pitch = '') And (f.Thrust = 'N1'), 'Autothrottle independent of FD');
    Plot.Labels.Clear;
    f := ReconstructIFlyFMA(Plot, 0);
    Check(f.Pitch = '--', 'Missing SDK does not fabricate modes');
    Historical;
   Finally
    Plot.Free;
   End;
   System.Writeln('PASS: reconstructed iFly FMA mode priorities, six-state MCP lamps, AP/FD, ILS, armed GS, altitude capture and missing data. Synthetic cases plus recorded SDK configurations; actual FMA text is not available for comparison.');
  Except
   On E : Exception Do
    Begin
     System.Writeln(E.ClassName + ': ' + E.Message);
     Raise Exception.Create('Regression failed; see diagnostic above');
    End;
  End;

 End;

Begin
 RunNativeTests(TVerifyIFlyFMATests);
End.
