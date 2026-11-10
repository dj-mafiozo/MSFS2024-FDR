Program VerifyDisplayUnits;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU,
 System.SysUtils, System.IOUtils, System.Classes, System.IniFiles, System.Math, System.Generics.Collections,
 Vcl.Forms, Vcl.Graphics, Vcl.Imaging.pngimage, ParameterNamesU, frmSettingsU, LocalizationU, FlightChartsU;

Procedure Check(b : Boolean; Const m : String);
 Begin
  If Not b Then
   Raise Exception.Create(m);
 End;

Procedure Near(a, b : Double; Const m : String);
 Begin
  Check(Abs(a - b) < 0.000001, m + ' ' + FloatToStr(a));
 End;

Var
 Config   : TMemIniFile;
 f        : TfrmSettings;
 c        : TFlightCharts;
 Indices  : TList<Integer>;
 i        : Integer;
 FileName : String;
 b        : TBitmap;
 p        : TPngImage;

Type

 [TestFixture]
 TVerifyDisplayUnitsTests = Class
  Public
   [Test]
   Procedure Regression;
 End;

Procedure TVerifyDisplayUnitsTests.Regression;
 Begin
  Application.Initialize;
  SetLanguage('pl-PL');
  FileName := TPath.GetTempFileName;
  Config   := TMemIniFile.Create(FileName);
  Try
   LoadDisplayUnits(Config);
   Near(ParameterDisplayValue('plane_altitude', 1000), 1000, 'Default raw');
   SaveDisplayUnit(Config, 'ft', 'm');
   SaveDisplayUnit(Config, 'lb', 'kg');
   SaveDisplayUnit(Config, 'lb/h', 'kg/h');
   SaveDisplayUnit(Config, 'ft/min', 'm/s');
   SaveDisplayUnit(Config, 'kt', 'km/h');
   SaveDisplayUnit(Config, 'US gal', 'l');
   SaveDisplayUnit(Config, #$00B0 + 'C', #$00B0 + 'F');
   SaveDisplayUnit(Config, 'inHg', 'hPa');
   LoadDisplayUnits(Config);
   Near(ParameterDisplayValue('plane_altitude', 1000), 304.8, 'Feet');
   Near(ParameterDisplayValue('vertical_speed', 600), 3.048, 'Vertical speed');
   Near(ParameterDisplayValue('airspeed_indicated', 100), 185.2, 'Knots');
   Near(ParameterDisplayValue('total_weight', 100), 45.359237, 'Pounds');
   Near(ParameterDisplayValue('fuel_total_quantity', 10), 37.85411784, 'US gallons');
   Near(ParameterDisplayValue('ambient_temperature', 0), 32, 'Temperature offset');
   Near(ParameterDisplayValue('ambient_pressure', 1), 33.86389, 'Pressure');
   Near(ParameterDisplayValue('iFlySDK.Unknown', 100), 100, 'Unknown SDK unit is not guessed');
   Check(IsNan(ParameterDisplayValue('plane_altitude', NaN)), 'NaN retained');
   Check(IsInfinite(ParameterDisplayValue('plane_altitude', Infinity)), 'Infinity retained');
   Check(Pos('[m]', ParameterCaption('plane_altitude')) > 0, 'Caption unit agrees');
   SaveDisplayUnit(Config, 'ft', 'kg');
   LoadDisplayUnits(Config);
   Near(ParameterDisplayValue('plane_altitude', 1000), 304.8, 'Reject incompatible target');
   f := TfrmSettings.Create(Nil);
   Try
    f.Load(Config);
    Check(f.UnitsEditor.RowCount = DisplayUnitCount + 1, 'One setting per source unit');
    Check(f.UnitsEditor.ItemProps[0].PickList.IndexOf('m') >= 0, 'Unit dropdown');
    f.UnitsEditor.Cells[1, 1] := 'ft';
    f.Save(Config);
    Near(ParameterDisplayValue('plane_altitude', 1000), 1000, 'Settings save applies immediately');
    For i := 0 To 3 Do
     Begin
      Case i Of
       0 : SetLanguage('pl-PL');
       1 : SetLanguage('en-US');
       2 : SetLanguage('de-DE');
       3 : SetLanguage('es-ES');
      End;
      Check(f.UnitsEditor.TitleCaptions[0] <> '', 'Localized headings');
     End;
    Check(f.UnitsEditor.TitleCaptions[0] = 'Unidad original', 'Spanish column heading');
    f.Position := poDesigned;
    f.Left     := -4000;
    f.Show;
    Application.ProcessMessages;
    f.SettingsPages.ActivePage := f.UnitsPage;
    Application.ProcessMessages;
    b := TBitmap.Create;
    p := TPngImage.Create;
    Try
     b.SetSize(f.ClientWidth, f.ClientHeight);
     f.PaintTo(b.Canvas, 0, 0);
     p.Assign(b);
     p.SaveToFile(ExtractFilePath(ParamStr(0)) + 'units-preview.png');
    Finally
     p.Free;
     b.Free;
    End;
   Finally
    f.Free;
   End;
   c       := TFlightCharts.Create(Nil);
   Indices := TList<Integer>.Create;
   Try
    For i := 0 To 63 Do
     Indices.Add(i);
    c.Select(Indices);
    Check(c.DoubleBuffered, '64 charts remain buffered');
   Finally
    Indices.Free;
    c.Free;
   End;
  Finally
   Config.Free;
   DeleteFile(FileName);
  End;
  System.Writeln('PASS: display conversion, affine temperature, units/captions, invalid targets, unknown SDK, NaN/Infinity, settings and 64 buffered charts. Synthetic only.');

 End;

Begin
 RunNativeTests(TVerifyDisplayUnitsTests);

End.
