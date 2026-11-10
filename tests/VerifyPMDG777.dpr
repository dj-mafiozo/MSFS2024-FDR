Program VerifyPMDG777;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU,
 Winapi.Windows, System.SysUtils, System.IOUtils, System.JSON, System.Math,
 PMDG777ReaderU, PMDG777CatalogU, PMDG777DecodeU, AircraftTelemetryU, FlightTelemetryU,
 FlightDatabaseU, FMCScreensU, TelemetryCatalogU, FMCStyleU, Vcl.Graphics;

Procedure Check(b : Boolean; Const s : String);
 Begin
  If Not b Then
   Raise Exception.Create(s);
 End;

Var
 Lib   : HMODULE;
 Reset : Procedure(m : Integer);
 Stdcall;
 Count : Function(k : Integer) : Integer;
 Stdcall;
 Reader   : TPMDG777Reader;
 Provider : TPMDG777Provider;
 Data     : TBytes;
 Age      : UInt64;
 s        : TFlightSample;
 Root     : String;
 DB       : TFlightDatabase;
 Trip     : Integer;
 I        : Integer;
 Idx      : Integer;
 Plot     : TTripPlot;
 CDU      : TJSONObject;
 Fields   : TJSONObject;
 Style    : TFMCStyle;

Type

 [TestFixture]
 TVerifyPMDG777Tests = Class
  Public
   [Test]
   Procedure Regression;
 End;

Procedure TVerifyPMDG777Tests.Regression;
 Begin
  Root := TestDataDirectory;
  Lib  := LoadLibrary(PChar(Root + 'MockPMDG777Sim.dll'));
  Check(Lib <> 0, 'Mock DLL');
  @Reset := GetProcAddress(Lib, 'PMDGMockReset');
  @Count := GetProcAddress(Lib, 'PMDGMockCount');
  Reader   := TPMDG777Reader.Create(Root + 'MockPMDG777Sim.dll');
  Provider := TPMDG777Provider.Create(Root + 'MockPMDG777Sim.dll');
  s        := TFlightSample.Create;
  Try
   Check(PMDG777DataSize = 684, 'Verified SDK size');
   Check(PMDG777FieldCount = 522, 'All official fields');
   Check(Provider.Matches('PMDG 777-300ER LOT') And Provider.Matches('PMDG B77W') And Not Provider.Matches('PMDG 737-800'), 'Aircraft matching');
   Reset(0);
   Reader.Tick;
   Check((Count(0) = 4) And (Count(1) = 4) And (Count(2) = 8) And (Count(5) = 0), 'Four mapped areas and ON_SET/initial requests');
   For I := 0 To 3 Do
    Check(Reader.Snapshot(I, Data, Age), 'Data and all three CDUs');
   Reader.Snapshot(0, Data, Age);
   Provider.Apply(s, Data, Age, '');
   Check(s.AircraftData.GetValue('provider').Value = 'PMDG777', 'Independent provider');
   Check(s.AircraftData.GetValue('performance_reference').GetValue<Double>('v1_kt') = 135, 'V1 SDK reference');
   Check(s.N('gear_handle_position') = 1, '777 gear DOWN encoding');
   Check(s.N('autopilot_master') = 1, 'AP annunciators');
   Reader.Snapshot(3, Data, Age);
   CDU := DecodePMDG777CDU(Data);
   Try
    Check(Pos('PMDG CENTER', CDU.GetValue('rows').ToJSON) > 0, 'Third CDU decoded');
    Style := TFMCStyle.Create(CDU.GetValue('style_json').Value);
    Try
     Check(Style.Cell(1, 0).Small, 'PMDG small font');
     Check(Style.Cell(1, 0).Foreground = clAqua, 'SDK cyan palette');
    Finally
     Style.Free;
    End;
   Finally
    CDU.Free;
   End;
   Reader.Close;
   Reset(7);
   Reader.Tick;
   Reader.Snapshot(0, Data, Age);
   Provider.Apply(s, Data, Age, '');
   Check(s.AircraftData.GetValue('performance_reference').GetValue<TJSONValue>('vref_kt') Is TJSONNull, 'Unset VREF is null');
   Reader.Close;
   Reset(1);
   Reader.Tick;
   Reader.Tick;
   Check(Not Reader.Snapshot(2, Data, Age), 'Unavailable right CDU');
   Check(Reader.Snapshot(3, Data, Age), 'Center independent of right');
   Reader.Close;
   Provider.Deactivate;
   Reset(0);
   Provider.Capture(s);
   Check(s.AircraftData.GetValue('cdu').GetValue<TJSONObject>('0').GetValue('annunciators_json').Value.Contains('"EXEC":1'), 'CDU lamps');
   For I := 0 To FieldCount - 1 Do
    Begin
     If SimFields[I].Name = 'time_zulu.year' Then
      s.Numbers[I] := 2026;
     If SimFields[I].Name = 'time_zulu.month' Then
      s.Numbers[I] := 10;
     If SimFields[I].Name = 'time_zulu.day' Then
      s.Numbers[I] := 21;
     If SimFields[I].Name = 'title' Then
      s.Texts[I] := 'PMDG 777-300ER test';
    End;
   DB := TFlightDatabase.Create(TestDatabasePath(Root + 'pmdg777-test.db'), Root + 'sqlite3.dll');
   Try
    Trip := DB.StartTrip(s);
    DB.RecordSample(Trip, s);
    DB.RecordSample(Trip, s);
    Check(DB.Connection.ExecSQLScalar('select count(*) from trip_fmc_screens where trip=:t', [Trip]) = 3, 'Three screens, unchanged suppressed');
    Check(DB.Connection.ExecSQLScalar('select count(*) from trip_aircraft_data where trip=:t', [Trip]) = 1, 'Unchanged SDK payload suppressed');
    Plot := DB.LoadTrip(Trip);
    Try
     Idx := Plot.Labels.IndexOf('PMDG777.FMC_V2');
     Check(Idx >= 0, 'SDK chart field');
     Check(Plot.Points.Last.Values[Idx] = 145, 'SDK chart replay');
    Finally
     Plot.Free;
    End;
   Finally
    DB.Free;
   End;
   Check(Count(3) = 0, 'Read-only SDK; no client writes/events');
   System.Writeln('PASS: official 777 layout, 522 fields, four SimConnect areas, three styled CDUs/lamps, readiness/sentinels, independent availability, AP/gear references, delta database and charts. Mock only.');
  Finally
   s.Free;
   Provider.Free;
   Reader.Free;
   FreeLibrary(Lib);
  End;

 End;

Begin
 RunNativeTests(TVerifyPMDG777Tests);

End.
