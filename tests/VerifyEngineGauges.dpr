Program VerifyEngineGauges;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU In 'TestPathsU.pas', DUnitX.TestFramework, NativeTestRunnerU In 'NativeTestRunnerU.pas', Winapi.Windows, System.SysUtils, System.Classes, System.Math, System.IOUtils,
 Vcl.Forms, Vcl.Controls, Vcl.ExtCtrls, Vcl.Graphics, FlightDatabaseU In '..\src\Data\FlightDatabaseU.pas', FlightTelemetryU In '..\src\Telemetry\FlightTelemetryU.pas', TelemetryCatalogU In '..\src\Telemetry\TelemetryCatalogU.pas',
 InstrumentDataU In '..\src\Visualization\InstrumentDataU.pas', EngineGaugesU In '..\src\Visualization\EngineGaugesU.pas', fraEnginesU In '..\src\Frames\fraEnginesU.pas', frmViewWindowU In '..\src\Forms\frmViewWindowU.pas', LocalizationU In '..\src\i18n\LocalizationU.pas', ParameterNamesU In '..\src\Visualization\ParameterNamesU.pas';

Procedure Check(b : Boolean; Const m : String);
 Begin
  If Not b Then
   Raise Exception.Create(m);
 End;

Procedure SetValue(Plot : TTripPlot; Const Name : String; v : Double);
 Var
  p : TPlotPoint;
  k : Integer;
 Begin
  p        := Plot.Points[0];
  p.Values := Copy(p.Values);
  k        := Plot.Labels.IndexOf(Name);
  If k < 0 Then
   Begin
    k := Plot.Labels.Add(Name);
    SetLength(p.Values, k + 1);
   End;
  p.Values[k]    := v;
  Plot.Points[0] := p;
 End;

Function Has(g : TEngineGauges; Const Name : String; Out Value : Double) : Boolean;
 Var
  Item : TEngineReading;
 Begin
  Result := False;
  Value  := NaN;
  For Item In g.Items Do
   If Item.Parameter = Name Then
    Begin
     Value := Item.Value;
     Exit(True);
    End;
 End;

Procedure Visual;
 Var
  Host    : TForm;
  Dock    : TPanel;
  Frame   : TfraEngines;
  View    : TfrmViewWindow;
  Plot    : TTripPlot;
  p       : TPlotPoint;
  v       : Double;
  i       : Integer;
  Shot    : TBitmap;
  Profile : TInstrumentProfile;
 Begin
  SetLanguage('en-US');
  Check(Tr('Silniki') = 'Engines', 'Engine title translation');
  Check(Pos('HSI CDI signal valid', ParameterCaption('hsi_cdi_valid')) > 0, 'Readable new parameter translation');
  SetLanguage('pl-PL');
  Host := TForm.Create(Nil);
  Plot := TTripPlot.Create;
  Try
   p.Time := '2026-10-21T12:00:00Z';
   Plot.Points.Add(p);
   Dock               := TPanel.Create(Host);
   Dock.Parent        := Host;
   Dock.Align         := alClient;
   Frame              := TfraEngines.Create(Host);
   Frame.Parent       := Dock;
   Frame.Align        := alClient;
   Plot.AircraftTitle := 'C172 steam';
   SetValue(Plot, 'engine_type', 0);
   SetValue(Plot, 'number_of_engines', 1);
   SetValue(Plot, 'general_eng_rpm #1', 2350);
   SetValue(Plot, 'recip_eng_cylinder_head_temperature #1', 190);
   SetValue(Plot, 'eng_oil_pressure #1', 7632);
   Check((EngineGaugeUnit('eng_oil_pressure #1') = 'psi') And (Abs(EngineGaugeValue('eng_oil_pressure #1', 7632) - 53) < 0.001), '7632 raw psf displays as 53 psi');
   SetValue(Plot, 'fuel_left_quantity', 0);
   SetValue(Plot, 'electrical_battery_load', -3);
   Frame.SetPoint(Plot, 0);
   Check(Frame.Display.Profile.Kind = ikGaAnalog, 'Analog GA classifier');
   Check(Has(Frame.Display, 'general_eng_rpm #1', v) And (v = 2350), 'Piston RPM');
   Check(Has(Frame.Display, 'fuel_left_quantity', v) And (v = 0), 'Valid empty tank retained');
   Check(Not Has(Frame.Display, 'turb_eng_n1 #1', v), 'No turbine dial on piston');
   Check(Has(Frame.Display, 'eng_oil_pressure #1', v) And (v = 7632), 'Oil raw psf preserved');
   Check(IsNan(EngineGaugeValue('eng_oil_pressure #1', NaN)), 'Missing pressure remains unavailable');
   Check(Not Has(Frame.Display, 'suction_pressure', v), 'Missing optional hidden');
   Check(ParameterSourceUnit('electrical_battery_load') = 'A', 'Ampere unit');
   Plot.AircraftTitle := 'TBM 930';
   SetValue(Plot, 'engine_type', 5);
   SetValue(Plot, 'number_of_engines', 1);
   SetValue(Plot, 'turb_eng_itt #1', 710);
   SetValue(Plot, 'turb_eng_condition_lever_position #1', 2);
   Frame.SetPoint(Plot, 0);
   Check(Frame.Display.Profile.Kind = ikGaGlass, 'Glass GA classifier');
   Check(Has(Frame.Display, 'turb_eng_itt #1', v) And (v = 710), 'Turboprop ITT');
   Check(Has(Frame.Display, 'turb_eng_condition_lever_position #1', v) And (v = 2), 'Condition lever');
   Check(Not Has(Frame.Display, 'general_eng_rpm #1', v), 'No piston RPM dial on turboprop');
   Plot.AircraftTitle := 'CSS B737-500';
   SetValue(Plot, 'engine_type', 1);
   SetValue(Plot, 'number_of_engines', 2);
   Frame.SetPoint(Plot, 0);
   Check(Frame.Display.Profile.Kind = ikAirlinerClassic, 'Classic classifier');
   Plot.AircraftTitle := 'iFly 737-MAX8';
   SetValue(Plot, 'turb_eng_n1 #1', 93.8);
   SetValue(Plot, 'turb_eng_n1 #2', 94.1);
   Frame.SetPoint(Plot, 0);
   Check(Frame.Display.Profile.Kind = ikAirlinerPFD, 'Airliner PFD classifier');
   Check(Has(Frame.Display, 'turb_eng_n1 #2', v) And (Abs(v - 94.1) < 0.001), 'Independent engines');
   Check(Not Has(Frame.Display, 'turb_eng_itt #1', v), 'No turboprop ITT on jet');
   Host.ClientWidth  := 1000;
   Host.ClientHeight := 700;
   Host.Show;
   Application.ProcessMessages;
   Shot := TBitmap.Create;
   Try
    Shot.SetSize(Frame.Display.Width, Frame.Display.Height);
    Frame.Display.PaintTo(Shot.Canvas, 0, 0);
    Shot.SaveToFile(TestRepositoryPath('tests\engine-gauges-preview.bmp'));
   Finally
    Shot.Free;
   End;
   View := TfrmViewWindow.Create(Host);
   View.Attach(Frame, Dock, 'Engines', Nil);
   SetValue(Plot, 'turb_eng_n1 #2', 84.2);
   Frame.SetPoint(Plot, 0);
   Check((Frame.Parent = View) And Has(Frame.Display, 'turb_eng_n1 #2', v) And (Abs(v - 84.2) < 0.001), 'Detached synchronization');
   View.Close;
   Application.ProcessMessages;
   Check(Frame.Parent = Dock, 'Dock same frame');
   SetLanguage('he-IL');
   Check(Frame.Display.BiDiMode = bdLeftToRight, 'Engine instruments physical LTR');
   SetLanguage('pl-PL');
   For i In [0, 1, 2, 4, 16] Do
    Begin
     SetValue(Plot, 'number_of_engines', i);
     Frame.SetPoint(Plot, 0);
     Check(Frame.Display.Profile.EngineCount = i, 'Engine count');
     Host.ClientWidth := 320;
     Frame.FrameResize(Nil);
     Frame.Display.Repaint;
    End;
   SetValue(Plot, 'number_of_engines', 99);
   Profile := InstrumentProfile(Plot, 0);
   Check(Profile.EngineCount = 0, 'Invalid count');
   Frame.Clear;
   Plot.Free;
   Plot := Nil;
   Frame.Display.Repaint;
   Check(Frame.Display.Items.Count = 0, 'Clear releases all plot references');
  Finally
   Plot.Free;
   Host.Free;
  End;
 End;

Procedure Storage;
 Var
  DB   : TFlightDatabase;
  s    : TFlightSample;
  Plot : TTripPlot;
  Trip : Integer;
  i    : Integer;
  k    : Integer;
  Path : String;
 Begin
  Path := TestDatabasePath('engines.db');
  DB   := TFlightDatabase.Create(Path, TestRuntimeFile('sqlite3.dll'));
  s    := TFlightSample.Create;
  Try
   For i := 0 To FieldCount - 1 Do
    Begin
     If SimFields[i].Name = 'title' Then
      s.Texts[i] := 'Engine gauge storage';
     If SimFields[i].Name = 'number_of_engines' Then
      s.Numbers[i] := 2;
     If SimFields[i].Name = 'kohlsman_setting_mb' Then
      s.Numbers[i] := 1026.35;
     If SimFields[i].Name = 'engine_type' Then
      s.Numbers[i] := 5;
     If SimFields[i].Name = 'turb_eng_itt[0]' Then
      s.Numbers[i] := 712.5;
    End;
   Trip := DB.StartTrip(s);
   DB.RecordSample(Trip, s);
   For i := 0 To FieldCount - 1 Do
    If SimFields[i].Name = 'turb_eng_itt[1]' Then
     s.Numbers[i] := 601.25;
   DB.RecordSample(Trip, s);
   For i := 0 To FieldCount - 1 Do
    If SimFields[i].Name = 'turb_eng_itt[1]' Then
     s.Numbers[i] := NaN;
   DB.RecordSample(Trip, s);
   Plot := DB.LoadTrip(Trip);
   Try
    Check(Plot.AircraftTitle = 'Engine gauge storage', 'Loaded aircraft title');
    k := Plot.Labels.IndexOf('turb_eng_itt #1');
    Check(k >= 0, 'ITT replay label');
    Check(Abs(Plot.Points[0].Values[k] - 712.5) < 0.001, 'ITT precise replay');
    k := Plot.Labels.IndexOf('turb_eng_itt #2');
    Check(IsNan(Plot.Points[0].Values[k]), 'Unavailable second engine stays NULL/NaN');
    Check(Abs(Plot.Points[1].Values[k] - 601.25) < 0.001, 'NULL to valid in prepared statement');
    Check(IsNan(Plot.Points[2].Values[k]), 'Valid to NULL in prepared statement');
    k := Plot.Labels.IndexOf('kohlsman_setting_mb');
    Check(Abs(Plot.Points[0].Values[k] - 1026.35) < 0.001, 'Baro fractional precision');
    k := Plot.Labels.IndexOf('hsi_cdi_needle');
    Check(IsNan(Plot.Points[0].Values[k]), 'Optional common field NULL/NaN');
   Finally
    Plot.Free;
   End;
  Finally
   s.Free;
   DB.Free;
  End;
 End;

Type

 [TestFixture]
 TVerifyEngineGaugesTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyEngineGaugesTests.Regression;
 Begin
  Try
   Application.Initialize;
   Visual;
   Storage;
   System.Writeln('PASS: piston/turboprop/jet gauges, independent engine counts, optional vs missing/zero, profile kinds, ampere units, paint/resize, detachable snapshot synchronization, RTL, database NULL and precise replay. Synthetic only.');
  Except
   On E : Exception Do
    Begin
     System.Writeln(E.ClassName + ': ' + E.Message);
     Raise Exception.Create('Regression failed; see diagnostic above');
    End;
  End;

 End;

Begin
 RunNativeTests(TVerifyEngineGaugesTests);
End.
