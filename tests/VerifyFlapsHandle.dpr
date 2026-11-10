Program VerifyFlapsHandle;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU, System.SysUtils, System.Classes, System.Math, FlapsHandleU, ParameterNamesU;

Procedure Check(b : Boolean; Const m : String);
 Begin
  If Not b Then
   Raise Exception.Create(m);
 End;

Function LabelAt(Const ICAO : String; Index : Integer; Const Title : String = ''; Count : Integer = 0) : String;
 Var
  l : TStringList;
 Begin
  l := TStringList.Create;
  Try
   l.Text := StringReplace(FlapsHandleDisplayValue(ICAO, Title, Count), '\r\n', #13#10, [rfReplaceAll]);
   Result := l.Values[IntToStr(Index)];
  Finally
   l.Free;
  End;
 End;

Var
 l : TStringList;
 v : TArray<Double>;

Type

 [TestFixture]
 TVerifyFlapsHandleTests = Class
  Public
   [Test]
   Procedure Regression;
 End;

Procedure TVerifyFlapsHandleTests.Regression;
 Begin
  Check(LabelAt('B38M', 8, '', 9) = '40', 'Boeing nine positions');
  Check(LabelAt('B733', 8, 'CSS 737-300', 9) = '40', 'CSS 300 full flaps');
  Check(LabelAt('B734', 4, 'CSS 737-400', 9) = '10', 'CSS 400 flaps ten');
  Check(LabelAt('B735', 3, '', 9) = '5', 'Classic 737');
  Check(LabelAt('A320', 2, 'Fenix A320', 6) = '1+F', 'Standard A320 has separate 1+F');
  Check(LabelAt('A20N', 5, 'FBW A32NX', 6) = 'FULL', 'Standard A320 six positions');
  Check(ParameterDisplayText('FBWLVar.A32NX_FLAPS_HANDLE_INDEX', 4) = 'FULL', 'SDK lever stays five positions');
  Check(LabelAt('C172', 1, '', 4) = '10', 'Default C172');
  Check(LabelAt('C208', 2, '', 4) = '20', 'Default Caravan');
  Check(LabelAt('C700', 3, '', 4) = 'FULL', 'Default Longitude cockpit label');
  Check(LabelAt('C25C', 2, '', 3) = '35', 'Default CJ4');
  Check(LabelAt('SF50', 1, '', 3) = '50%', 'Default Vision Jet percent detent');
  Check(LabelAt('OPCA', 5, '', 6) = '50', 'Default Optica six positions');
  Check(LabelAt('S12', 0, '', 6) = '-10', 'Negative glider flap position');
  Check(LabelAt('S12', 2, '', 6) = '0', 'Glider neutral is not index zero');
  Check(LabelAt('MD11', 5, 'TFDi Design MD-11', 8) = '28', 'TFDi MD11 layout');
  Check(LabelAt('MD11', 5, 'SkySimulations MD-11', 7) = '35', 'SkySim MD11 different layout');
  Check(FlapsHandleDisplayValue('MD11') = '', 'Unknown MD11 provider stays unknown');
  Check(FlapsHandleDisplayValue('MD11', 'TFDi Design MD-11', 7) = '', 'Recorded count beats reference');
  Check(LabelAt('WILG', 4, 'Draco X', 5) = '44', 'Draco title');
  Check(FlapsHandleDisplayValue('WILG', 'PZL Wilga', 4) = '', 'No wrong Draco map for ordinary Wilga');
  Check(FlapsHandleDisplayValue('B38M', '', 5) = '', 'Different configuration not mislabelled');
  Check(LabelAt('ULAC', 1, 'CGS Hawk Arrow II', 2) = '10', 'Ultralight title match');
  Check(FlapsHandleDisplayValue('HAWK', 'BAE Hawk', 3) = '', 'No ultralight profile for jet trainer');
  Check(FlapsHandleDisplayValue('B407') = '', 'No wing flaps');
  Check(FlapsHandleDisplayValue('UNKNOWN') = '', 'Unknown empty default');
  Check(FlapsHandleDisplayValue('') = '', 'Empty ICAO');
  Check(LabelAt(' c172 ', 3) = '30', 'Case and whitespace normalization');
  Check(ParameterDisplayText('flaps_handle_index', 3, 'A320', 'Fenix A320', 6) = '2', 'Inspector integration');
  Check(ParameterDisplayText('flaps_handle_index', 3, 'B38M', 'iFly', 5) = '3', 'Count mismatch numeric fallback');
  l := TStringList.Create;
  Try
   l.Add('flaps_num_handle_positions');
   SetLength(v, 1);
   v[0] := 6;
   Check(RecordedFlapPositionCount(l, v) = 6, 'Recorded count');
   v[0] := NaN;
   Check(RecordedFlapPositionCount(l, v) = 0, 'Missing count');
   v[0] := 3.5;
   Check(RecordedFlapPositionCount(l, v) = 0, 'Fractional count invalid');
   v[0] := 0;
   Check(RecordedFlapPositionCount(l, v) = 0, 'Unknown count');
  Finally
   l.Free;
  End;
  System.Writeln('PASS: ICAO flap profiles, standard vs SDK Airbus indices, GA/glider detents, provider differences, recorded count guard and numeric fallback. Synthetic only.');

 End;

Begin
 RunNativeTests(TVerifyFlapsHandleTests);

End.
