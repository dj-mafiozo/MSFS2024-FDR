Program VerifyAddonLVars;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU In 'TestPathsU.pas', DUnitX.TestFramework, NativeTestRunnerU In 'NativeTestRunnerU.pas',
 Winapi.Windows, System.SysUtils, System.IOUtils, System.JSON, System.Math,
 AddonLVarCatalogU In '..\src\Aircraft\AddonLVarCatalogU.pas', AircraftTelemetryU In '..\src\Telemetry\AircraftTelemetryU.pas', AircraftLVarReaderU In '..\src\SimConnect\AircraftLVarReaderU.pas', FlightTelemetryU In '..\src\Telemetry\FlightTelemetryU.pas', FlightDatabaseU In '..\src\Data\FlightDatabaseU.pas', TelemetryCatalogU In '..\src\Telemetry\TelemetryCatalogU.pas';

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
 Reader    : TAircraftLVarReader;
 P         : TAddonLVarProvider;
 Values    : TArray<Double>;
 Names     : TArray<String>;
 Age       : UInt64;
 s         : TFlightSample;
 i         : Integer;
 j         : Integer;
 n         : Integer;
 Trip      : Integer;
 Idx       : Integer;
 DB        : TFlightDatabase;
 Plot      : TTripPlot;
 Root      : String;
 Title     : String;
 Providers : TAircraftProviders;

Type

 [TestFixture]
 TVerifyAddonLVarsTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyAddonLVarsTests.Regression;
 Begin
  Root := TestDataDirectory;
  Lib  := LoadLibrary(PChar(Root + 'MockAddonSim.dll'));
  Check(Lib <> 0, 'Mock');
  @Reset := GetProcAddress(Lib, 'MockReset');
  @Count := GetProcAddress(Lib, 'MockCount');
  Reset(3);
  SetLength(Names, 1);
  Names[0] := 'A:LIGHT NAV';
  Reader   := TAircraftLVarReader.Create(Names, 'standard binding test', Root + 'MockAddonSim.dll', 1, True, TArray<String>.Create('bool'));
  Try
   Reader.Tick;
   Check((Reader.Snapshot(Values, Age, 5000) = 1) And (Count(2) = 0), 'Standard A binding strips A prefix and preserves declared units');
  Finally
   Reader.Free;
  End;
  SetLength(Names, AddonProfiles[1].Count);
  For i     := 0 To High(Names) Do
   Names[i] := 'TEST_' + IntToStr(i);
  Reset(0);
  Reader := TAircraftLVarReader.Create(Names, 'test XML polling', Root + 'MockAddonSim.dll', 1, True);
  Try
   Reader.PollIntervalMS := 10000;
   For i                 := 1 To 8 Do
    Reader.Tick;
   Check(Reader.Snapshot(Values, Age, 5000) = Length(Names), 'Every field delivered despite 512-packet pump bound');
   Check((Count(0) = Length(Names)) And (Count(2) = 0), 'ONCE requests, no continuous stream or duplicate pending');
   Check(Count(3) <= Length(Names), 'Bounded outstanding queue');
   Reader.PollIntervalMS := 20;
   Sleep(25);
   For i := 1 To 8 Do
    Reader.Tick;
   Check(Count(3) <= Length(Names), 'Polling remains bounded');
   Check(Count(1) = 0, 'Read-only');
   Reader.Close;
   Reset(1);
   For i := 1 To 8 Do
    Reader.Tick;
   n := Reader.Snapshot(Values, Age, 5000);
   Check(n = Length(Names) - 1, 'Rejected L-var does not discard neighbors');
   Check(IsNan(Values[3]) And Not IsNan(Values[4]), 'Per-field isolation');
  Finally
   Reader.Free;
  End;
  s  := TFlightSample.Create;
  DB := TFlightDatabase.Create(TestDatabasePath(Root + 'addon-lvars-test.db'), Root + 'sqlite3.dll');
  Try
   Check(AddonProfileCount = 8, 'Eight aircraft families');
   Check(AddonFieldCount >= 3207, 'Literal XML catalog');
   Check(MatchesAddon(3, 'McDonnell Douglas DC-9-30 AEROMEXICO'), 'Unbranded installed DC-9 title');
   Check(MatchesAddon(4, 'McDonnell Douglas MD-11 KLM'), 'Unbranded installed MD-11 title');
   Check(Not MatchesAddon(4, 'TFDi Design MD-11 KLM'), 'Do not claim another developer');
   For i := 0 To AddonProfileCount - 1 Do
    Begin
     Case i Of
      0 : Title := 'PMDG DC-6B';
      1 : Title := 'CSS B737-500';
      2 : Title := 'Fly the Maddog X';
      3 : Title := 'SkySim DC-9-30';
      4 : Title := 'SkySim MD-11';
      5 : Title := 'TFDi Design MD-11';
      6 : Title := 'Bell 407';
     Else Title := 'EC135';
     End;
     P := TAddonLVarProvider.Create(i, Root + 'MockAddonSim.dll');
     Try
      Check(P.Matches(Title) And Not P.Matches('Asobo C172'), 'Specific aircraft detection');
      SetLength(Values, AddonProfiles[i].Count);
      For j      := 0 To High(Values) Do
       Values[j] := j + 1;
      Values[0]  := NaN;
      P.Apply(s, Values, 0);
      Check(s.AircraftData.GetValue('fields').GetValue<TJSONValue>(AddonFields[AddonProfiles[i].First].Name) Is TJSONNull, 'Unavailable stays null');
      Trip := DB.StartTrip(s);
      DB.RecordSample(Trip, s);
      DB.RecordSample(Trip, s);
      Check(DB.Connection.ExecSQLScalar('select count(*) from trip_aircraft_data where trip=:t', [Trip]) = 1, 'Change-only storage');
      Plot := DB.LoadTrip(Trip);
      Try
       Idx := Plot.Labels.IndexOf(AddonProfiles[i].Provider + '.' + AddonFields[AddonProfiles[i].First + 1].Name);
       Check((Idx >= 0) And (Plot.Points.Last.Values[Idx] = 2), 'Raw parameter replay');
      Finally
       Plot.Free;
      End;
     Finally
      P.Free;
     End;
    End;
   Reset(0);
   Providers := TAircraftProviders.Create(Root + 'MockAddonSim.dll', Root + 'MockAddonSim.dll', Root + 'MockAddonSim.dll');
   Try
    For i := 0 To FieldCount - 1 Do
     If SimFields[i].Name = 'title' Then
      s.Texts[i] := 'TFDi Design MD-11';
    For i        := 1 To 8 Do
     Providers.Tick(s, True, 10000);
    Check(Count(0) = AddonProfiles[5].Count, 'Only matching TFDi catalog subscribed');
    Providers.Tick(s, False, 10000);
    Check(Count(4) = 0, 'Inactive flight closes provider queue');
   Finally
    Providers.Free;
   End;
   System.Writeln('PASS: XML literal L-vars, eight aircraft families, isolated optional failures, ONCE polling and bounded queue, no writes, nulls, change-only database and chart replay. Synthetic only.');
  Finally
   s.Free;
   DB.Free;
   FreeLibrary(Lib);
  End;

 End;

Begin
 RunNativeTests(TVerifyAddonLVarsTests);
End.
