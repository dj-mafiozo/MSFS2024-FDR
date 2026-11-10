Program VerifySixPack;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU, Winapi.Windows, System.SysUtils, System.Classes, System.Math, System.IOUtils, System.IniFiles,
 Vcl.Imaging.pngimage, Vcl.Forms, Vcl.Controls, Vcl.ExtCtrls, Vcl.Graphics, FlightDatabaseU, FlightTelemetryU, TelemetryCatalogU,
 fraSixPackU, SixPackU, frmViewWindowU, LocalizationU, ParameterNamesU;

Procedure Check(b : Boolean; Const m : String);
 Begin
  If Not b Then
   Raise Exception.Create(m);
 End;

Type
 TCountingLabels = Class(TPlotLabels)
  Public
   Lookups : Integer;
   Function IndexOf(Const s : String) : Integer; Override;
 End;

 TLabelProbe = Class
  Count : Integer;
  Procedure Changed(Sender : TObject);
 End;

Function TCountingLabels.IndexOf(Const s : String) : Integer;
 Begin
  Inc(Lookups);
  Result := Inherited IndexOf(s);
 End;

Procedure TLabelProbe.Changed(Sender : TObject);
 Begin
  Inc(Count);
 End;

Procedure VerifyStableMechanics;
 Var
  Plot     : TTripPlot;
  Other    : TTripPlot;
  p        : TPlotPoint;
  l        : TCountingLabels;
  d        : TSixPackDisplay;
  Host     : TForm;
  Config   : TMemIniFile;
  Shot     : TBitmap;
  a        : TAltimeterAngles;
  b        : TAltimeterAngles;
  i        : Integer;
  j        : Integer;
  Before   : Integer;
  Revision : UInt64;
  Probe    : TLabelProbe;
  Swap     : Double;
 Begin
  Plot  := TTripPlot.Create;
  Other := TTripPlot.Create;
  Host  := TForm.Create(Nil);
  Probe := TLabelProbe.Create;
  Try
   Plot.Labels.Free;
   l           := TCountingLabels.Create;
   Plot.Labels := l;
   l.Add('vertical_speed');
   l.Add('indicated_altitude');
   l.Add('airspeed_indicated');
   For i := 1 To 3000 Do
    l.Add('dummy_' + IntToStr(i));
   l.OnChange := Probe.Changed;
   SetLength(p.Values, 3);
   p.Values[0] := 100;
   p.Values[1] := 12500;
   p.Values[2] := 145;
   Plot.Points.Add(p);
   p.Values    := Copy(p.Values);
   p.Values[0] := -5600;
   Plot.Points.Add(p);
   p.Values    := Copy(p.Values);
   p.Values[0] := NaN;
   Plot.Points.Add(p);
   p.Values    := Copy(p.Values);
   p.Values[0] := Infinity;
   Plot.Points.Add(p);
   SetLength(p.Values, 0);
   Plot.Points.Add(p);
   Host.ClientWidth  := 960;
   Host.ClientHeight := 660;
   d                 := TSixPackDisplay.Create(Host);
   d.Parent          := Host;
   d.Align           := alClient;
   d.SetPoint(Plot, 0);
   Check(d.VSIFullScale = 6000, 'VSI range covers entire recording before high-rate sample');
   Before := l.Lookups;
   For i  := 0 To 999 Do
    Begin
     d.SetPoint(Plot, i Mod 5);
     Check(d.VSIFullScale = 6000, 'VSI range independent of playback direction/sample');
    End;
   Check(l.Lookups = Before, 'No IndexOf calls during 1000 cached SetPoint calls with 3003 labels');
   d.SetPoint(Plot, 0);
   Host.Show;
   Application.ProcessMessages;
   a := AltimeterNeedleAngles(d.State.Altitude);
   Check((Abs(a.Thousands - 180) < 0.001) And (Abs(a.TenThousands - 90) < 0.001) And (Abs(a.HundredThousands - 45) < 0.001), 'Classic foot-based needle gearing');
   Shot   := TBitmap.Create;
   Config := TMemIniFile.Create('');
   Try
    Shot.SetSize(d.Width, d.Height);
    d.PaintTo(Shot.Canvas, 0, 0);
    Check(ColorToRGB(Shot.Canvas.Pixels[800, 277]) = clWhite, 'Long foot-based altimeter needle position');
    SaveDisplayUnit(Config, 'ft', 'm');
    SaveDisplayUnit(Config, 'ft/min', 'm/s');
    LoadDisplayUnits(Config);
    d.SetPoint(Plot, 0);
    b := AltimeterNeedleAngles(d.State.Altitude);
    Check((a.Thousands = b.Thousands) And (a.TenThousands = b.TenThousands) And (a.HundredThousands = b.HundredThousands), 'Changing display units preserves all three needle angles');
    Check(Abs(ParameterDisplayValue('indicated_altitude', d.State.Altitude) - 3810) < 0.001, 'Metric numeric altitude remains available');
    Check(Abs(ParameterDisplayValue('vertical_speed', -5600) / ParameterDisplayValue('vertical_speed', d.VSIFullScale) - ( -5600 / 6000)) < 1E-10, 'VSI unit change preserves needle ratio');
    d.PaintTo(Shot.Canvas, 0, 0);
    Check(ColorToRGB(Shot.Canvas.Pixels[800, 277]) = clWhite, 'Renderer retains foot geometry with metric readout');
    Shot.SaveToFile(TestRepositoryPath('tests\six-pack-metric-preview.bmp'));
   Finally
    Config.EraseSection('display_units');
    LoadDisplayUnits(Config);
    Config.Free;
    Shot.Free;
   End;
   // Same-size schema mutation must invalidate indices, while preserving OnChange clients.
   Revision := l.Revision;
   l.Exchange(0, 1);
   Check((l.Revision > Revision) And (Probe.Count > 0), 'Revision changes without replacing OnChange');
   For i := 0 To Plot.Points.Count - 1 Do
    Begin
     p        := Plot.Points[i];
     p.Values := Copy(p.Values);
     If Length(p.Values) >= 2 Then
      Begin
       Swap        := p.Values[0];
       p.Values[0] := p.Values[1];
       p.Values[1] := Swap;
      End;
     Plot.Points[i] := p;
    End;
   Before := l.Lookups;
   d.SetPoint(Plot, 1);
   Check((d.State.Altitude = 12500) And (d.State.VSI = -5600) And (l.Lookups > Before), 'Same-count label reorder rebuilds cache');
   j            := l.IndexOf('vertical_speed');
   l.Strings[j] := 'retired_vertical_speed';
   d.SetPoint(Plot, 0);
   Check(IsNan(d.State.VSI) And (d.VSIFullScale = 2000), 'Missing VSI uses safe fixed fallback');
   Other.Labels.DelimitedText := 'indicated_altitude,vertical_speed,airspeed_indicated';
   SetLength(p.Values, 3);
   p.Values[0] := -500;
   p.Values[1] := 750;
   p.Values[2] := 100;
   Other.Points.Add(p);
   d.SetPoint(Other, 0);
   Check((d.State.Altitude = -500) And (d.VSIFullScale = 2000), 'Switching plot rebuilds bindings and ranges');
   a := AltimeterNeedleAngles( -500);
   Check(Abs(a.Thousands - 180) < 0.001, 'Below-sea-level altitude wraps correctly');
   a := AltimeterNeedleAngles(NaN);
   Check(IsNan(a.Thousands), 'Missing altitude has no fabricated needle');
   d.Clear;
   Check(IsNan(d.State.Altitude), 'Clear releases cache binding');
  Finally
   Host.Free;
   Plot.Free;
   Other.Free;
   Probe.Free;
  End;
 End;

Procedure VerifyILSBaro;
 Var
  Plot : TTripPlot;
  p    : TPlotPoint;
  d    : TSixPackDisplay;
  s    : TSixPackState;
 Begin
  Plot := TTripPlot.Create;
  d    := TSixPackDisplay.Create(Nil);
  Try
   Plot.Labels.DelimitedText := 'hsi_cdi_needle,hsi_cdi_valid,hsi_has_localizer,hsi_gsi_needle,hsi_gsi_valid,gps_drives_nav1,kohlsman_setting_mb,kohlsman_setting_hg,kohlsman_setting_std';
   SetLength(p.Values, 9);
   p.Values[0] := 63.5;
   p.Values[1] := 1;
   p.Values[2] := 1;
   p.Values[3] := -59.5;
   p.Values[4] := 1;
   p.Values[5] := 0;
   p.Values[6] := 1026;
   p.Values[7] := 30.3;
   p.Values[8] := 0;
   Plot.Points.Add(p);
   d.SetPoint(Plot, 0);
   s := d.State;
   Check(s.LocalizerValid And s.GlideslopeValid And (Abs(s.Localizer - 0.5) < 0.001) And (Abs(s.Glideslope + 0.5) < 0.001), 'Valid ILS normalized independently');
   Check((s.Baro = 1026) And Not s.StandardBaro, 'Current selected baro, not weather pressure');
   p.Values       := Copy(p.Values);
   p.Values[5]    := 1;
   Plot.Points[0] := p;
   d.SetPoint(Plot, 0);
   s := d.State;
   Check(Not s.LocalizerValid And Not s.GlideslopeValid, 'GPS CDI is not ILS');
   p.Values[5]    := 0;
   p.Values[4]    := 0;
   p.Values[6]    := NaN;
   p.Values[7]    := 29.92;
   p.Values[8]    := 1;
   Plot.Points[0] := p;
   d.SetPoint(Plot, 0);
   s := d.State;
   Check(s.LocalizerValid And Not s.GlideslopeValid, 'Lost GS hidden with LOC remaining');
   Check(s.StandardBaro And (Abs(s.Baro - 1013.207) < 0.01), 'Fallback inHg to hPa and STD');
   p.Values[1]    := NaN;
   p.Values[7]    := NaN;
   p.Values[8]    := NaN;
   Plot.Points[0] := p;
   d.SetPoint(Plot, 0);
   s := d.State;
   Check(Not s.LocalizerValid And Not s.GlideslopeValid And IsNan(s.Baro), 'Missing flags and baro are safe NaNs');
  Finally
   d.Free;
   Plot.Free;
  End;
 End;

Procedure VerifyPFDILS;
 Var
  Plot : TTripPlot;
  p    : TPlotPoint;
  Host : TForm;
  d    : TSixPackDisplay;
  b    : TBitmap;
  PNG  : TPngImage;
  i    : Integer;

  Procedure Render;
   Begin
    d.SetPoint(Plot, 0);
    d.PaintTo(b.Canvas, 0, 0);
   End;

  Function Magenta(x, y : Integer) : Boolean;
   Begin
    Result := ColorToRGB(b.Canvas.Pixels[x, y]) = ColorToRGB(clFuchsia);
   End;

 Begin
  Plot := TTripPlot.Create;
  Host := TForm.Create(Nil);
  b    := TBitmap.Create;
  PNG  := TPngImage.Create;
  Try
   Plot.AircraftTitle        := 'iFly 737 MAX 8';
   Plot.Labels.DelimitedText := 'hsi_cdi_needle,hsi_cdi_valid,hsi_has_localizer,hsi_gsi_needle,hsi_gsi_valid,gps_drives_nav1,plane_pitch_degrees,plane_bank_degrees,airspeed_indicated,indicated_altitude';
   SetLength(p.Values, 10);
   For i        := 0 To 9 Do
    p.Values[i] := 0;
   p.Values[0]  := 63.5;
   p.Values[1]  := 1;
   p.Values[2]  := 1;
   p.Values[3]  := -59.5;
   p.Values[4]  := 1;
   p.Values[8]  := 145;
   p.Values[9]  := 2500;
   Plot.Points.Add(p);
   Host.ClientWidth  := 720;
   Host.ClientHeight := 600;
   d                 := TSixPackDisplay.Create(Host);
   d.Parent          := Host;
   d.Align           := alClient;
   Host.Show;
   Application.ProcessMessages;
   b.SetSize(720, 600);
   Render;
   // R=219, span=110, offset=180, instrument center=(329,301).
   Check(Magenta(384, 481), 'PFD LOC diamond right of center for positive deviation');
   Check(Magenta(509, 246), 'PFD GS diamond above center for negative needle');
   PNG.Assign(b);
   PNG.SaveToFile(TestRepositoryPath('tests\pfd-ils-preview.png'));
   p.Values       := Copy(p.Values);
   p.Values[0]    := -63.5;
   p.Values[3]    := 59.5;
   p.Values[6]    := -8;
   p.Values[7]    := 25;
   Plot.Points[0] := p;
   Render;
   Check(Magenta(274, 481) And Magenta(509, 356), 'ILS scales stay fixed during bank/pitch changes and reverse deviation');
   p.Values[1]    := 0;
   Plot.Points[0] := p;
   Render;
   Check(Not d.State.LocalizerValid And d.State.GlideslopeValid, 'GS remains available when LOC flag is invalid');
   Check(Not Magenta(274, 481) And Magenta(509, 356), 'Invalid LOC hidden without hiding valid GS');
   p.Values[1]    := 1;
   p.Values[4]    := 0;
   Plot.Points[0] := p;
   Render;
   Check(Magenta(274, 481) And Not Magenta(509, 356), 'Invalid GS hidden independently');
   p.Values[4]    := 1;
   p.Values[5]    := 1;
   Plot.Points[0] := p;
   Render;
   Check(Not Magenta(274, 481) And Not Magenta(509, 356), 'GPS guidance does not draw ILS diamonds');
   p.Values[5]    := 0;
   p.Values[0]    := 1000;
   p.Values[3]    := -1000;
   Plot.Points[0] := p;
   Render;
   Check((d.State.Localizer = 1) And (d.State.Glideslope = -1), 'Out-of-range deflections clamp to end stops');
   Check(Not Magenta(439, 481) And Not Magenta(509, 191), 'Full-scale diamonds have hollow centers');
   Check(Magenta(439, 474) And Magenta(509, 184), 'Full-scale symbols remain visible at end stops');
   p.Values[0]    := NaN;
   p.Values[3]    := NaN;
   Plot.Points[0] := p;
   Render;
   Check(Not d.State.LocalizerValid And Not d.State.GlideslopeValid, 'NaN needles unavailable');
   p.Values[0]    := 0;
   p.Values[3]    := 0;
   p.Values[6]    := 0;
   p.Values[7]    := 0;
   Plot.Points[0] := p;
   Plot.Labels.Add('vertical_speed');
   SetLength(p.Values, 11);
   p.Values[10]      := -677;
   Plot.Points[0]    := p;
   Host.ClientWidth  := 900;
   Host.ClientHeight := 200;
   Application.ProcessMessages;
   b.SetSize(900, 200);
   Render;
   Check(ColorToRGB(b.Canvas.Pixels[419, 70]) = ColorToRGB(TColor($00BA7238)), 'Wide/short PFD preserves a full-height horizon');
   PNG.Assign(b);
   PNG.SaveToFile(TestRepositoryPath('tests\pfd-wide-preview.png'));

  Finally
   PNG.Free;
   b.Free;
   Host.Free;
   Plot.Free;
  End;
  System.Writeln('PASS: PFD ILS rendered pixels, independent validity, GPS exclusion, bank/pitch independence, hollow full-scale markers and missing data. Synthetic only.');
 End;

Var
 Plot   : TTripPlot;
 p      : TPlotPoint;
 Frame  : TfraSixPack;
 Host   : TForm;
 Dock   : TPanel;
 View   : TfrmViewWindow;
 Shot   : TBitmap;
 DB     : TFlightDatabase;
 s      : TFlightSample;
 i      : Integer;
 Trip   : Integer;
 Root   : String;
 Path   : String;
 OldSQL : String;
 Config : TMemIniFile;

Type

 [TestFixture]
 TVerifySixPackTests = Class
  Public
   [Test]
   Procedure Regression;
 End;

Procedure TVerifySixPackTests.Regression;
 Begin
  Try
   Application.Initialize;
   VerifyStableMechanics;
   VerifyILSBaro;
   VerifyPFDILS;
   Plot := TTripPlot.Create;
   Host := TForm.Create(Nil);
   Try
    Plot.Labels.DelimitedText := 'airspeed_indicated,plane_pitch_degrees,plane_bank_degrees,indicated_altitude,heading_indicator,vertical_speed,turn_indicator_rate,turn_coordinator_ball';
    SetLength(p.Values, 8);
    p.Time      := '2026-10-21T12:00:00Z';
    p.Values[0] := 145;
    p.Values[1] := -8.5;
    p.Values[2] := 15;
    p.Values[3] := 3500;
    p.Values[4] := 359;
    p.Values[5] := 1200;
    p.Values[6] := -3;
    p.Values[7] := 15;
    Plot.Points.Add(p);
    p.Values    := Copy(p.Values);
    p.Time      := '2026-10-21T12:00:01Z';
    p.Values[0] := 148;
    p.Values[4] := 361;
    Plot.Points.Add(p);
    Dock        := TPanel.Create(Host);
    Dock.Parent := Host;
    Dock.Align  := alClient;
    Check(TfraSixPack.ClassParent = TFrame, 'Inline SixPack has direct TFrame ancestry');
    Frame        := TfraSixPack.Create(Host);
    Frame.Parent := Dock;
    Frame.Align  := alClient;
    Frame.SetPoint(Plot, 0);
    Check((Frame.Display.State.IAS = 145) And (Frame.Display.State.Pitch = 8.5), 'IAS and pitch sign');
    Check((Frame.Display.State.Altitude = 3500) And (Frame.Display.State.Heading = 359), 'Altimeter and heading indicator sources');
    Check((Frame.Display.State.TurnRate = -3) And (Frame.Display.State.Ball = 15), 'Measured turn and ball, not estimated from bank');
    Host.ClientWidth  := 960;
    Host.ClientHeight := 660;
    Host.Show;
    View := TfrmViewWindow.Create(Host);
    View.Attach(Frame, Dock, 'Six-pack', Nil);
    Frame.SetPoint(Plot, 1);
    Check((Frame.Parent = View) And (Frame.Display.State.IAS = 148) And (Frame.Display.State.Heading = 1), 'Same detached frame updates and normalizes heading');
    View.Close;
    Application.ProcessMessages;
    Check((Frame.Parent = Dock) And Dock.Visible, 'Close restores same frame');
    SetLanguage('he-IL');
    Check(Frame.Display.BiDiMode = bdLeftToRight, 'Physical gauges must remain LTR');
    SetLanguage('pl-PL');
    Frame.SetPoint(Plot, 0);
    Application.ProcessMessages;
    Shot := TBitmap.Create;
    Try
     Shot.SetSize(Frame.Display.Width, Frame.Display.Height);
     Frame.Display.PaintTo(Shot.Canvas, 0, 0);
     Shot.SaveToFile(ExtractFilePath(ParamStr(0)) + 'six-pack-preview.bmp');
    Finally
     Shot.Free;
    End;
    Config := TMemIniFile.Create('');
    Try
     SaveDisplayUnit(Config, 'ft', 'm');
     SaveDisplayUnit(Config, 'kt', 'km/h');
     LoadDisplayUnits(Config);
     Check(Abs(ParameterDisplayValue('indicated_altitude', Frame.Display.State.Altitude) - 1066.8) < 0.001, 'Display conversion with raw state preserved');
     Frame.Display.Repaint;
    Finally
     Config.EraseSection('display_units');
     LoadDisplayUnits(Config);
     Config.Free;
    End;
    Frame.SetPoint(Plot, -1);
    Check(IsNan(Frame.Display.State.IAS), 'Invalid timeline clears');
    Plot.Labels.Clear;
    Frame.SetPoint(Plot, 0);
    Check(IsNan(Frame.Display.State.TurnRate), 'Missing historical parameter stays unavailable');
    Frame.Display.Repaint;
    Host.ClientWidth  := 150;
    Host.ClientHeight := 110;
    Frame.Display.Repaint;
   Finally
    Host.Free;
    Plot.Free;
   End;
   Root := TestDataDirectory;
   Path := TestDatabasePath(Root + 'six-pack-test-' + IntToStr(GetTickCount64) + '.db');
   DB   := TFlightDatabase.Create(TestDatabasePath(Path), Root + 'sqlite3.dll');
   Try
    OldSQL := DB.Connection.ExecSQLScalar('select sql from sqlite_master where name=''trip_data''');
    OldSQL := StringReplace(OldSQL, ',turn_indicator_rate REAL', '', [rfIgnoreCase]);
    OldSQL := StringReplace(OldSQL, ',turn_coordinator_ball REAL', '', [rfIgnoreCase]);
    DB.Connection.ExecSQL('drop table trip_data');
    DB.Connection.ExecSQL(OldSQL);
   Finally
    DB.Free;
   End;
   DB := TFlightDatabase.Create(TestDatabasePath(Path), Root + 'sqlite3.dll');
   s  := TFlightSample.Create;
   Try
    For i := 0 To FieldCount - 1 Do
     If SimFields[i].Name = 'title' Then
      s.Texts[i] := 'Six-pack migration';
    Trip         := DB.StartTrip(s);
    DB.RecordSample(Trip, s);
    Check(DB.Connection.ExecSQLScalar('select turn_indicator_rate is null and turn_coordinator_ball is null from trip_data limit 1') = 1, 'Missing instrument data stored as NULL after migration');
    Plot := DB.LoadTrip(Trip);
    Try
     Check(IsNan(Plot.Points[0].Values[Plot.Labels.IndexOf('turn_indicator_rate')]), 'NULL remains unavailable in replay');
    Finally
     Plot.Free;
    End;
   Finally
    s.Free;
    DB.Free;
    DeleteFile(Path);
   End;
   System.Writeln('PASS: stable replay ranges, cached indices/schema revisions, metric readout with foot-based needle geometry and native six-pack snapshot sync, pitch sign, heading wrap, ' +
   'measured turn/ball, detach/dock, RTL, display conversion, missing data, resize, legacy schema migration and NULL replay. Synthetic only.');
  Except
   On E : Exception Do
    Begin
     System.Writeln(E.ClassName + ': ' + E.Message);
     Raise Exception.Create('Regression failed; see diagnostic above');
    End;
  End;

 End;

Begin
 RunNativeTests(TVerifySixPackTests);

End.
