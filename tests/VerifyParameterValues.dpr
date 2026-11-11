Program VerifyParameterValues;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU In 'TestPathsU.pas', DUnitX.TestFramework, NativeTestRunnerU In 'NativeTestRunnerU.pas', System.SysUtils, System.Classes, System.Math, ParameterNamesU In '..\src\Visualization\ParameterNamesU.pas', LocalizationU In '..\src\i18n\LocalizationU.pas',
 TelemetryCatalogU In '..\src\Telemetry\TelemetryCatalogU.pas', iFlySDKCatalogU In '..\src\Aircraft\iFly\iFlySDKCatalogU.pas', PMDGNG3CatalogU In '..\src\Aircraft\PMDG\PMDGNG3CatalogU.pas', PMDG777CatalogU In '..\src\Aircraft\PMDG\PMDG777CatalogU.pas', FenixCatalogU In '..\src\Aircraft\Fenix\FenixCatalogU.pas', FBWCatalogU In '..\src\Aircraft\FBW\FBWCatalogU.pas';

Procedure Check(b : Boolean; Const m : String);
 Begin
  If Not b Then
   Raise Exception.Create(m);
 End;

Var
 i : Integer;
 l : TStringList;
 v : TArray<Double>;

Const
 Flaps : Array[0..8] Of String = ('UP', '1', '2', '5', '10', '15', '25', '30', '40');
 Brakes : Array[0..5] Of String = ('RTO', 'DISARMED', '1', '2', '3', 'MAX');

Type

 [TestFixture]
 TVerifyParameterValuesTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyParameterValuesTests.Regression;
 Begin
  SetLanguage('en-US');
  For i := 0 To 8 Do
   Begin
    Check(ParameterDisplayText('iFlySDK.FLAP_Status', i) = Flaps[i], 'iFly flap detent');
    Check(ParameterDisplayText('flaps_handle_index', i, 'B38M') = Flaps[i], 'Standard Boeing flap detent');
   End;
  For i := 0 To 5 Do
   Begin
    Check(ParameterDisplayText('iFlySDK.Autobrake_Selector_Status', i) = Brakes[i], 'iFly autobrake');
    Check(ParameterDisplayText('PMDGNG3.MAIN_AutobrakeSelector', i) = Brakes[i], 'PMDG autobrake');
   End;
  Check(ParameterDisplayText('flaps_handle_index', 3, 'A320') = '2', 'Airbus detents independent from Boeing');
  Check(ParameterDisplayText('flaps_handle_index', 3, 'XXXX') = '3', 'Unknown airframe does not get Boeing detents');
  Check(ParameterDisplayText('FenixLVar.S_OH_EXT_LT_STROBE', 1) = 'AUTO', 'Fenix XML ANIMTIP enum');
  Check(ParameterDisplayText('FenixLVar.S_OH_EXT_LT_LANDING_L', 0) = 'RETRACT', 'Fenix linked landing-light variable');
  Check(ParameterDisplayText('FBWLVar.XMLVAR_SWITCH_OVHD_INTLT_EMEREXIT_POSITION', 1) = 'AUTO', 'FBW explicit documented enum');
  Check(ParameterDisplayText('FBWLVar.LIGHTING_LANDING_1', 2) = 'OFF', 'FBW nose selector opposite to Fenix');
  Check(ParameterDisplayText('iFlySDK.Compass_Light_Switch_Status', 0) = 'DIM', 'Original GB18030 SDK enum');
  Check(ParameterDisplayText('iFlySDK.Aircraft_Model', 2) = '737 MAX 8200', 'Header declared aircraft enum');
  Check(ParameterDisplayText('iFlySDK.RTP_Left_Num_100_Status[0]', 10) = 'A', 'Header glyph code');
  Check(ParameterDisplayText('iFlySDK.RTP_Left_Num_100_Status[0]', 9) = '9', 'Digit range stays a digit');
  Check(ParameterDisplayText('PMDGNG3.ELEC_DCMeterSelector', 7) = 'TEST', 'Partial SDK enum endpoint');
  Check(ParameterDisplayText('PMDGNG3.ELEC_DCMeterSelector', 2) = '2', 'Undocumented intermediate value is numeric');
  Check(ParameterDisplayText('CSS737.helper_bugs_landing', 1) = 'PRESSED', 'Explicit XML press/release');
  Check(ParameterDisplayText('FenixLVar.S_MIP_GEAR', 1) = 'DOWN', 'Fenix gear');
  Check(ParameterDisplayText('FBWLVar.A32NX_FLAPS_HANDLE_INDEX', 4) = 'FULL', 'FBW flaps');
  Check(ParameterDisplayText('PMDG777.FCTL_Flaps_Lever', 3) = '15', '777 separate detents');
  Check(ParameterDisplayText('turb_eng_ignition_switch_ex1 #2', 1) = 'AUTO', 'Indexed engine ignition enum');
  Check(ParameterDisplayText('turb_eng_condition_lever_position #1', 2) = 'HIGH IDLE', 'Indexed condition lever');
  Check(ParameterDisplayText('bleed_air_source_control_1', 2) = 'APU', 'Bleed selector');
  Check(ParameterDisplayText('pitot_heat_switch', 2) = 'AUTO', 'Pitot selector');
  Check(ParameterDisplayText('autopilot_master', 0) = 'OFF', 'Standard boolean zero');
  Check(ParameterDisplayText('autopilot_master', 1) = 'ON', 'Standard boolean one');
  Check(ParameterDisplayText('iFlySDK.FLAP_Status', 9) = '9', 'Unknown enum numeric fallback');
  Check(ParameterDisplayText('iFlySDK.FLAP_Status', 3.5) = Format('%.8g', [3.5]), 'Fraction is not rounded into detent');
  Check(ParameterDisplayText('iFlySDK.FLAP_Status', NaN) = '-', 'Missing data stays missing');
  SetLanguage('pl-PL');
  Check(ParameterDisplayText('iFlySDK.Autobrake_Selector_Status', 0) = 'RTO', 'Cockpit labels never translated');
  l := TStringList.Create;
  Try
   l.Add('GSX.FSDT_GSX_BOARDING_STATE');
   l.Add('GSX.FSDT_GSX_NUMPASSENGERS_BOARDING_TOTAL');
   l.Add('GSX.FSDT_GSX_NUMPASSENGERS');
   l.Add('GSX.FSDT_GSX_BOARDING_CARGO_PERCENT');
   SetLength(v, 4);
   v[0] := 5;
   v[1] := 14;
   v[2] := 145;
   v[3] := 25;
   Check(Pos('14/145', GSXDisplayText(l[0], l, v)) > 0, 'Cumulative passengers/target');
   Check(Pos('25%', GSXDisplayText(l[0], l, v)) > 0, 'Real baggage percentage');
   Check(Pos(Tr('In progress'), GSXDisplayText(l[0], l, v)) = 1, 'Translated active state');
   Check(Tr('In progress') <> 'In progress', 'Polish localization actually loaded');
   v[0] := 6;
   v[1] := 145;
   v[3] := 100;
   Check(Pos(Tr('Completed'), GSXDisplayText(l[0], l, v)) = 1, 'Completed state');
   Check(Pos('145/145', GSXDisplayText(l[0], l, v)) > 0, 'Completed actual passengers');
   v[0] := 5;
   v[1] := 14;
   v[2] := NaN;
   v[3] := NaN;
   Check(Pos('14/-', GSXDisplayText(l[0], l, v)) > 0, 'Old recording target missing, no future inference');
   v[0] := 0;
   Check(GSXDisplayText(l[0], l, v) = Tr('Brak danych'), 'Absent GSX zero is not idle');
   v[0] := 5;
   v[2] := 145;
   v[3] := 25;
   SetLanguage('en-US');
   Check(Pos('In progress', GSXDisplayText(l[0], l, v)) = 1, 'Language switch refreshes GSX');
   Check(Pos('Passengers: 14/145', GSXDisplayText(l[0], l, v)) > 0, 'English progress');
  Finally
   l.Free;
  End;
  System.Writeln('PASS: switch enums, Boeing/Airbus detents, raw fallback, missing values, untranslated cockpit labels, localized GSX states and real cumulative/target/cargo progress. Synthetic only.');

 End;

Begin
 RunNativeTests(TVerifyParameterValuesTests);
End.
