Program VerifyB38MEICAS;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU, System.SysUtils, System.Classes, System.Math, System.IOUtils, System.Types, System.Hash, System.JSON, AnalysisContextU, System.Variants, FireDAC.Comp.Client,
 Vcl.Forms, Vcl.Controls, Vcl.ExtCtrls, Vcl.Graphics, Vcl.Imaging.pngimage,
 B38MEICASU, EngineGaugesU, fraEnginesU, frmViewWindowU, FlightDatabaseU, FlightTelemetryU, TelemetryCatalogU, InstrumentDataU, LocalizationU;

Procedure Check(b : Boolean; Const m : String);
 Begin
  If Not b Then
   Raise Exception.Create(m);
 End;

Procedure Visual;
 Var
  Plot  : TTripPlot;
  p     : TPlotPoint;
  Host  : TForm;
  Frame : TfraEngines;
  View  : TfrmViewWindow;
  b     : TBitmap;
  PNG   : TPngImage;
  i     : Integer;

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

  Procedure Render;
   Begin
    Frame.SetPoint(Plot, 0);
    Frame.Display.Eicas.PaintTo(b.Canvas, Rect(0, 0, 640, 800));
   End;

 Begin
  Plot := TTripPlot.Create;
  Host := TForm.Create(Nil);
  b    := TBitmap.Create;
  PNG  := TPngImage.Create;
  Try
   Check((B38MSelectedFlaps(0) = 0) And (B38MSelectedFlaps(7) = 30) And IsNan(B38MSelectedFlaps(1.5)), '737 flap detents, not raw degrees');
   Check((B38MFlapDeflection(5) = 3 / 8) And (B38MFlapDeflection(40) = 1), 'Nonlinear flap scale follows detents');
   Check((B38MFuelMass(100, 6.7) = 670) And IsNan(B38MFuelMass(100, NaN)) And IsNan(B38MFuelMass(100, 0)), 'Fuel mass needs measured density');
   Plot.AircraftTitle    := 'iFly 737 MAX 8';
   Plot.AircraftTypeICAO := 'B38M';
   p.Time                := '2026-10-24T12:00:00Z';
   V('engine_type', 1);
   V('number_of_engines', 2);
   V('turb_eng_n1 #1', 84.7);
   V('turb_eng_n1 #2', 83.2);
   V('turb_eng_n2 #1', 92.1);
   V('turb_eng_n2 #2', 91.8);
   V('eng_exhaust_gas_temperature #1', 650);
   V('eng_exhaust_gas_temperature #2', 640);
   V('turb_eng_fuel_flow_pph #1', 4400.5);
   V('turb_eng_fuel_flow_pph #2', 4300.25);
   V('eng_oil_pressure #1', 0);
   V('eng_oil_pressure #2', 7632);
   V('eng_oil_temperature #1', 90);
   V('eng_oil_temperature #2', 92);
   V('eng_oil_quantity #1', 0.8);
   V('eng_oil_quantity #2', 0.79);
   V('turb_eng_vibration #1', 0.1);
   V('turb_eng_vibration #2', 0.2);
   V('total_air_temperature', 24.3);
   V('fuel_weight_per_gallon', 6.7);
   V('fuel_tank_left_main_quantity', 1250);
   V('fuel_tank_center_quantity', 2500);
   V('fuel_tank_right_main_quantity', 1250);
   V('fuel_total_quantity_weight', 33500);
   V('flaps_handle_index', 5);
   V('trailing_edge_flaps_left_angle', 15);
   V('trailing_edge_flaps_right_angle', 15);
   V('general_eng_starter_active #1', 1);
   V('general_eng_starter_active #2', 0);
   V('eng_failed #1', 0);
   V('eng_failed #2', 1);
   V('iFlySDK.FILTER_BYPASS_Light_Status[0]', 2);
   V('iFlySDK.FILTER_BYPASS_Light_Status[1]', 0);
   V('iFlySDK.ENG_VALVE_CLOSED_Light_Status[0]', 0);
   V('iFlySDK.ENG_VALVE_CLOSED_Light_Status[1]', 0);
   V('iFlySDK.LOW_OIL_PRESSURE_Light_Status', 1);
   V('warning_oil_pressure', 0);
   Plot.Points.Add(p);
   Host.ClientWidth  := 640;
   Host.ClientHeight := 840;
   Frame             := TfraEngines.Create(Host);
   Frame.Parent      := Host;
   Frame.Align       := alClient;
   Host.Show;
   Application.ProcessMessages;
   b.SetSize(640, 800);
   Render;
   Check(Frame.Display.IsB38M, 'Automatic EICAS mode on existing DFM engine frame');
   Check(Abs(Frame.Display.Eicas.State.Engines[0].N1 - 84.7) < 0.0001, 'Engine 1 independent raw value');
   Check(Frame.Display.Eicas.State.Engines[1].N1 = 83.2, 'Engine 2 independent value');
   Check(Frame.Display.Eicas.State.FlapSelected = 15, 'Selected flaps derived from recorded detent');
   Check(Abs(EngineGaugeValue('eng_oil_pressure #2', Frame.Display.Eicas.State.Engines[1].OilPressure) - 53) < 0.001, 'Oil psf to psi');
   Check(ColorToRGB(b.Canvas.Pixels[480, 160]) = ColorToRGB(clYellow), 'Fuel-filter amber tile comes from actual SDK lamp');
   Check(ColorToRGB(b.Canvas.Pixels[612, 112]) = ColorToRGB(clYellow), 'Second engine failure tile independent');
   Check(ColorToRGB(b.Canvas.Pixels[400, 380]) = ColorToRGB(clBlack), 'APU oil lamp and zero oil pressure do not create engine warnings');
   PNG.Assign(b);
   PNG.SaveToFile(TestRepositoryPath('tests\b38m-eicas-preview.png'));
   p.Values                                        := Copy(p.Values);
   p.Time                                          := '2026-10-24T12:00:01Z';
   p.Values[Plot.Labels.IndexOf('turb_eng_n1 #1')] := 30;
   Plot.Points.Add(p);
   View := TfrmViewWindow.Create(Host);
   View.Attach(Frame, Host, 'B38M EICAS', Nil);
   Frame.SetPoint(Plot, 1);
   Check((Frame.aWindow.ImageIndex = 1) And (Frame.Display.Eicas.State.Engines[0].N1 = 30), 'Detached EICAS follows timeline');
   Frame.SetPoint(Plot, 0);
   Check(Frame.Display.Eicas.State.Engines[0].N1 = 84.7, 'Backward seek restores EICAS');
   View.Close;
   Application.ProcessMessages;
   Check((Frame.Parent = Host) And (Frame.aWindow.ImageIndex = 0), 'Same frame returns');
   p                                                                      := Plot.Points[0];
   p.Values                                                               := Copy(p.Values);
   p.Values[Plot.Labels.IndexOf('iFlySDK.FILTER_BYPASS_Light_Status[0]')] := NaN;
   p.Values[Plot.Labels.IndexOf('eng_failed #2')]                         := NaN;
   p.Values[Plot.Labels.IndexOf('turb_eng_n1 #1')]                        := NaN;
   Plot.Points[0]                                                         := p;
   Render;
   Check(IsNan(Frame.Display.Eicas.State.Engines[0].N1), 'Missing engine value stays NaN');
   Check(ColorToRGB(b.Canvas.Pixels[480, 160]) <> ColorToRGB(clYellow), 'Lost lamp does not retain old amber tile');
   For i := 0 To 2 Do
    Begin
     b.SetSize(320 + i * 100, 180 + i * 250);
     Frame.Display.Eicas.PaintTo(b.Canvas, Rect(0, 0, b.Width, b.Height));
    End;
   SetLanguage('he-IL');
   Check(Frame.Display.BiDiMode = bdLeftToRight, 'Physical EICAS stays LTR');
   SetLanguage('pl-PL');
   Plot.AircraftTitle    := 'PMDG 737-800';
   Plot.AircraftTypeICAO := 'B738';
   Frame.SetPoint(Plot, 0);
   Check(Not Frame.Display.IsB38M, 'Aircraft switch restores generic jet gauges');
   Plot.AircraftTitle    := 'SP-LVA custom livery';
   Plot.AircraftTypeICAO := 'B38M';
   Frame.SetPoint(Plot, 0);
   Check(Frame.Display.IsB38M, 'Recorded ICAO selects EICAS independently of livery title');
   Frame.Clear;
   Check(IsNan(Frame.Display.Eicas.State.TAT), 'Clear releases old data');
  Finally
   PNG.Free;
   b.Free;
   Host.Free;
   Plot.Free;
  End;
 End;

Function Hash(Const Path : String) : String;
 Var
  s : TFileStream;
 Begin
  s := TFileStream.Create(Path, fmOpenRead Or fmShareDenyNone);
  Try
   Result := THashSHA2.GetHashString(s);
  Finally
   s.Free;
  End;
 End;

Procedure Storage;
 Var
  DB     : TFlightDatabase;
  s      : TFlightSample;
  Plot   : TTripPlot;
  i      : Integer;
  Trip   : Integer;
  Path   : String;
  Before : String;
  q      : TFDQuery;
  j      : TJSONObject;

  Procedure N(Const Name : String; V : Double);
   Var
    j : Integer;
   Begin
    For j := 0 To FieldCount - 1 Do
     If SimFields[j].Name = Name Then
      Begin
       s.Numbers[j] := V;
       Exit;
      End;
    Raise Exception.Create('Missing sim field ' + Name);
   End;

  Procedure MakeOlderTable(Const Table, Removed : String);
   Var
    q    : TFDQuery;
    Cols : String;
    SQL  : String;
    Name : String;
   Begin
    q    := TFDQuery.Create(Nil);
    Cols := '';
    Try
     q.Connection := DB.Connection;
     q.Open('pragma table_info(' + Table + ')');
     While Not q.Eof Do
      Begin
       Name := q.FieldByName('name').AsString;
       If Pos(',' + Name + ',', ',' + Removed + ',') = 0 Then
        Begin
         If Cols <> '' Then
          Cols := Cols + ',';
         Cols  := Cols + Name;
        End;
       q.Next;
      End;
    Finally
     q.Free;
    End;
    SQL := VarToStr(DB.Connection.ExecSQLScalar('select sql from sqlite_master where name=:n', [Table]));
    For Name In Removed.Split([',']) Do
     SQL := StringReplace(SQL, ',' + Name + ' REAL', '', [rfIgnoreCase]);
    DB.Connection.ExecSQL('alter table ' + Table + ' rename to ' + Table + '_newer_fixture');
    DB.Connection.ExecSQL(SQL);
    DB.Connection.ExecSQL('insert into ' + Table + '(' + Cols + ') select ' + Cols + ' from ' + Table + '_newer_fixture');
    DB.Connection.ExecSQL('drop table ' + Table + '_newer_fixture');
   End;

 Begin
  Path := TestDatabasePath('eicas.db');
  DB   := TFlightDatabase.Create(Path, TestRuntimeFile('sqlite3.dll'));
  s    := TFlightSample.Create;
  Try
   For i := 0 To FieldCount - 1 Do
    If SimFields[i].Name = 'title' Then
     s.Texts[i] := 'iFly 737 MAX 8';
   For i        := 0 To FieldCount - 1 Do
    If SimFields[i].Name = 'atc_model' Then
     s.Texts[i] := 'B38M';
   N('number_of_engines', 2);
   N('engine_type', 1);
   N('time_zulu.year', 2026);
   N('time_zulu.month', 10);
   N('time_zulu.day', 24);
   N('time_zulu.seconds', 43200);
   N('turb_eng_n1[0]', 84.7);
   N('airspeed_indicated', 145);
   N('vertical_speed', 100);
   N('plane_pitch_degrees', -8);
   N('plane_bank_degrees', 0);
   N('heading_indicator', 245);
   N('plane_coordinate.latitude', 51.7);
   N('plane_coordinate.longitude', 19.4);
   N('ambient_wind_direction', 0);
   N('ambient_wind_velocity', 0);
   N('eng_oil_quantity[0]', 0.813);
   N('total_air_temperature', 24.37);
   N('fuel_tank_center_quantity', 1250.75);
   N('trailing_edge_flaps_left_angle', 14.9);
   Trip := DB.StartTrip(s);
   DB.RecordSample(Trip, s);
   DB.Contact(Trip, s, False);
   Plot := DB.LoadTrip(Trip);
   Try
    Check(Plot.AircraftTypeICAO = 'B38M', 'Recorded aircraft ICAO loaded without changing raw metadata');
    Check(Abs(InstrumentValue(Plot, 0, 'eng_oil_quantity #1') - 0.813) < 0.00001, 'Oil quantity precise SQLite replay');
    Check(Abs(InstrumentValue(Plot, 0, 'total_air_temperature') - 24.37) < 0.00001, 'TAT precise SQLite replay');
    Check(InstrumentValue(Plot, 0, 'fuel_tank_center_quantity') = 1250.75, 'Center tank stored');
   Finally
    Plot.Free;
   End;
   // Simulate an older recording, preserving its existing rows.
   MakeOlderTable('trip_engine_data', 'eng_oil_quantity');
   MakeOlderTable('trip_data', 'total_air_temperature,fuel_tank_center_quantity,fuel_tank_left_main_quantity,fuel_tank_right_main_quantity,trailing_edge_flaps_left_angle,trailing_edge_flaps_right_angle');
  Finally
   s.Free;
   DB.Free;
  End;
  Before := Hash(Path);
  DB     := TFlightDatabase.Create(Path, TestRuntimeFile('sqlite3.dll'), True, True);
  Try
   Plot := DB.LoadTrip(Trip);
   Try
    Check(Abs(InstrumentValue(Plot, 0, 'turb_eng_n1 #1') - 84.7) < 0.0001, 'Legacy rows and N1 survive missing-column fixture');
    Check(IsNan(InstrumentValue(Plot, 0, 'total_air_temperature')) And IsNan(InstrumentValue(Plot, 0, 'eng_oil_quantity #1')), 'Older read-only recording supplies NaN, no missing-field error');
   Finally
    Plot.Free;
   End;
   q := TFDQuery.Create(Nil);
   Try
    q.Connection := DB.Connection;
    q.Open('select * from trip_liftoffs limit 1');
    j := BuildContactContext(DB, q, 5, 5);
    Try
     Check(j <> Nil, 'Legacy read-only AI context accepts missing EICAS fields');
    Finally
     j.Free;
    End;
   Finally
    q.Free;
   End;
  Finally
   DB.Free;
  End;
  Check(Hash(Path) = Before, 'Read-only older recording is byte-for-byte unchanged');
  DB := TFlightDatabase.Create(Path, TestRuntimeFile('sqlite3.dll'));
  Try
   Plot := DB.LoadTrip(Trip);
   Try
    Check(IsNan(InstrumentValue(Plot, 0, 'eng_oil_quantity #1')), 'Migrated old oil data remains NULL, not zero');
   Finally
    Plot.Free;
   End;
  Finally
   DB.Free;
  End;
 End;

Type

 [TestFixture]
 TVerifyB38MEICASTests = Class
  Public
   [Test]
   Procedure Regression;
 End;

Procedure TVerifyB38MEICASTests.Regression;
 Begin
  Try
   Application.Initialize;
   Visual;
   Storage;
   System.Writeln('PASS: B38M automatic EICAS, independent engines, raw units, flap detents, density-safe fuel, explicit warnings/no APU leakage, stale-frame clearing, seek/detach/RTL, new SQLite fields, unchanged legacy read-only replay and migration. Synthetic only.');
  Except
   On E : Exception Do
    Begin
     System.Writeln(E.ClassName + ': ' + E.Message);
     Raise Exception.Create('Regression failed; see diagnostic above');
    End;
  End;

 End;

Begin
 RunNativeTests(TVerifyB38MEICASTests);

End.
