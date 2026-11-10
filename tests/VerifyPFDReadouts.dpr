Program VerifyPFDReadouts;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU, System.SysUtils, System.Math, AirbusDataU, FlightDatabaseU, PFDReadoutsU, FlightTelemetryU, TelemetryCatalogU;

Procedure Check(b : Boolean; Const Msg : String);
 Begin
  If Not b Then
   Raise Exception.Create(Msg);
 End;

Function ARINC(V : Single; SSM : Cardinal = 3) : Double;
 Var
  b : Cardinal;
 Begin
  Move(V, b, 4);
  Result := UInt64(b) + (UInt64(SSM) Shl 32);
 End;

Var
 Plot  : TTripPlot;
 p     : TPlotPoint;
 Data  : TAirbusData;
 Radio : TRadioReadout;
 DB    : TFlightDatabase;
 s     : TFlightSample;
 i     : Integer;
 Trip  : Integer;

Procedure V(Const Name : String; Value : Double);
 Var
  k : Integer;
 Begin
  k := Plot.Labels.IndexOf(Name);
  If k < 0 Then
   Begin
    k := Plot.Labels.Add(Name);
    SetLength(p.Values, k + 1);
   End;
  p.Values[k] := Value;
 End;

Procedure Point;
 Begin
  If Plot.Points.Count = 0 Then
   Plot.Points.Add(p)
  Else
   Plot.Points[0] := p;
  Data.SetPoint(Plot, 0);
 End;

Procedure N(Const Name : String; Value : Double);
 Var
  k : Integer;
 Begin
  For k := 0 To FieldCount - 1 Do
   If SimFields[k].Name = Name Then
    Begin
     s.Numbers[k] := Value;
     Exit;
    End;
  Raise Exception.Create(Name);
 End;

Type

 [TestFixture]
 TVerifyPFDReadoutsTests = Class
  Public
   [Test]
   Procedure Regression;
 End;

Procedure TVerifyPFDReadoutsTests.Regression;
 Begin
  Try
   Plot := TTripPlot.Create;
   Data := TAirbusData.Create;
   Try
    V('kohlsman_setting_std', 1);
    Point;
    Check(PFDBaroCaption(Data, False) = 'STD', 'STD independent of missing pressure');
    V('kohlsman_setting_std', 0);
    V('kohlsman_setting_mb', 1013.25);
    V('iFlySDK.BARO_STD_Status[0]', 1);
    Point;
    Check(PFDBaroCaption(Data, False) <> 'STD', 'QNH 1013 and pressed STD button do not imply latched STD');
    V('FBWLVar.A32NX_FCU_LEFT_EIS_DISCRETE_WORD_2', ARINC(1 Shl 27));
    Point;
    Check(PFDBaroCaption(Data, True) = 'STD', 'FBW ARINC STD');
    V('FBWLVar.A32NX_FCU_LEFT_EIS_DISCRETE_WORD_2', ARINC(1 Shl 28));
    V('FBWLVar.A32NX_FCU_LEFT_EIS_BARO_HPA', ARINC(1020));
    Point;
    Check(Pos('QNH', PFDBaroCaption(Data, True)) = 1, 'FBW native QNH');
    V('FBWLVar.A32NX_FCU_LEFT_EIS_DISCRETE_WORD_2', ARINC(0));
    Point;
    Check(Pos('QFE', PFDBaroCaption(Data, True)) = 1, 'FBW QFE');
    V('FBWLVar.A32NX_FCU_LEFT_EIS_DISCRETE_WORD_2', ARINC(0, 1));
    Point;
    Check(PFDBaroCaption(Data, True) = 'BARO --', 'Invalid ARINC does not use stale standard setting');
    V('autopilot_managed_speed_in_mach', 1);
    V('autopilot_mach_hold_var', 0.79);
    Point;
    Check(PFDSpeedCaption(Data, Plot, 0, True) = 'M 0.790', 'Standard Mach target');
    V('autopilot_managed_speed_in_mach', 0);
    V('autopilot_airspeed_hold_var', 250);
    Point;
    Check(PFDSpeedCaption(Data, Plot, 0, True) = '250', 'Standard IAS target');
    V('iFlySDK.SPD_Point_Status', 1);
    V('iFlySDK.SPD_100_Status', 7);
    V('iFlySDK.SPD_10_Status', 8);
    V('iFlySDK.SPD_1_Status', 0);
    Point;
    Check(PFDSpeedCaption(Data, Plot, 0, True) = 'M 0.780', 'SDK Mach decimal overrides standard IAS');
    V('iFlySDK.SPD_100_Status', 14);
    V('iFlySDK.SPD_10_Status', 14);
    V('iFlySDK.SPD_1_Status', 14);
    Point;
    Check(PFDSpeedCaption(Data, Plot, 0, True) = '---', 'Blank MCP window does not use stale standard target');
    V('FBWLVar.A32NX_FCU_AFS_DISPLAY_MACH_MODE', 1);
    V('FBWLVar.A32NX_FCU_AFS_DISPLAY_SPD_MACH_VALUE', 0.82);
    Point;
    Check(PFDSpeedCaption(Data, Plot, 0, False) = 'M 0.820', 'FBW native Mach');
    V('FBWLVar.A32NX_FCU_AFS_DISPLAY_MACH_MODE', 0);
    V('FBWLVar.A32NX_FCU_AFS_DISPLAY_SPD_MACH_VALUE', 210);
    Point;
    Check(PFDSpeedCaption(Data, Plot, 0, False) = '210', 'FBW IAS change');
    V('iFlySDK.VORADF_L_Status[0]', 0);
    V('nav_active_frequency_1', 117.6);
    V('nav_has_dme_1', 1);
    V('nav_dme_1', 0);
    Point;
    Radio := PFDRadio(Data, 1);
    Check((Radio.LabelText = 'VOR 1') And (Radio.Frequency = '117.60') And (Radio.Distance = 'DME 0.0 NM'), 'VOR frequency and genuine zero DME');
    V('nav_has_dme_1', 0);
    Point;
    Radio := PFDRadio(Data, 1);
    Check(Radio.Distance = 'DME --', 'No DME is not zero distance');
    V('iFlySDK.VORADF_R_Status[0]', 2);
    V('adf_active_frequency_2', 350.5);
    Point;
    Radio := PFDRadio(Data, 2);
    Check((Radio.LabelText = 'ADF 2') And (Radio.Frequency = '350.5') And (Radio.Distance = ''), 'ADF 2 frequency, no fabricated DME');
    V('iFlySDK.VORADF_L_Status[0]', 1);
    Point;
    Radio := PFDRadio(Data, 1);
    Check(Radio.LabelText = '', 'OFF hides block');
    Check(PFDWindDirection(0, 0) = 180, 'Northerly wind flows aft');
    Check(PFDWindDirection(90, 0) = 270, 'Easterly wind flows left');
    Check(PFDWindDirection(0, 90) = 90, 'Wind rotates with TRUE heading');
    Check(IsNan(PFDWindDirection(90, NaN)), 'Missing heading cannot become north');
    Plot.Labels.Clear;
    Data.SetPoint(Plot, 0);
    Radio := PFDRadio(Data, 1);
    Check((Radio.LabelText = '') And (PFDBaroCaption(Data, False) = 'BARO --'), 'Missing channels do not retain prior flight');
   Finally
    Data.Free;
    Plot.Free;
   End;
   DB := TFlightDatabase.Create(TestDatabasePath('readouts.mfzr'), TestRuntimeFile('sqlite3.dll'));
   s  := TFlightSample.Create;
   Try
    N('time_zulu.year', 2026);
    N('time_zulu.month', 10);
    N('time_zulu.day', 25);
    N('time_zulu.seconds', 43200);
    Trip := DB.StartTrip(s);
    N('nav_active_frequency_1', 117.6);
    N('nav_dme_1', 0);
    N('adf_active_frequency_2', NaN);
    DB.RecordSample(Trip, s);
    Plot := DB.LoadTrip(Trip);
    Try
     i := Plot.Labels.IndexOf('nav_active_frequency_1');
     Check(Abs(Plot.Points[0].Values[i] - 117.6) < 1E-9, 'Radio frequency SQLite roundtrip');
     i := Plot.Labels.IndexOf('nav_dme_1');
     Check(Plot.Points[0].Values[i] = 0, 'Zero DME roundtrip');
     i := Plot.Labels.IndexOf('adf_active_frequency_2');
     Check(IsNan(Plot.Points[0].Values[i]), 'Missing ADF remains NULL');
    Finally
     Plot.Free;
    End;
   Finally
    s.Free;
    DB.Free;
   End;
   System.Writeln('PASS: native/standard STD, QNH/QFE, IAS/Mach, blank MCP, VOR/ADF/OFF/DME, TRUE relative wind, missing data and SQLite. Synthetic only.');
  Except
   On E : Exception Do
    Begin
     System.Writeln(E.ClassName + ': ' + E.Message);
     Raise Exception.Create('Regression failed; see diagnostic above');
    End;
  End;

 End;

Begin
 RunNativeTests(TVerifyPFDReadoutsTests);

End.
