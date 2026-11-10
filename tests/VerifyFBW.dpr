Program VerifyFBW;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU,
 Winapi.Windows, System.SysUtils, System.Math, System.JSON, FireDAC.Comp.Client, FlightTelemetryU, TelemetryCatalogU, FlightDatabaseU,
 AircraftTelemetryU, AircraftDataStoreU, AircraftLVarReaderU, FBWReaderU, FBWCatalogU, AnalysisContextU;

Type
 TReset = Procedure(Mode : Integer);

 Stdcall;

 TCount = Function(Kind : Integer) : Integer;

 Stdcall;

Var
 DLL      : HMODULE;
 Reset    : TReset;
 Counter  : TCount;
 Reader   : TFBWReader;
 Provider : TFBWProvider;
 Registry : TAircraftProviders;
 s        : TFlightSample;
 DB       : TFlightDatabase;
 v        : TArray<Double>;
 Age      : UInt64;
 i        : Integer;
 n        : Integer;
 ID       : Integer;
 EventID  : Integer;
 Flaps    : Integer;
 Path     : String;
 MockPath : String;
 Plot     : TTripPlot;
 q        : TFDQuery;
 Context  : TJSONObject;

Function IndexOf(Const Name : String) : Integer;
 Begin
  For Result := 0 To FBWFieldCount - 1 Do
   If FBWFields[Result].Name = Name Then
    Exit;
  Result := -1;
 End;

Procedure Check(b : Boolean; Const m : String);
 Begin
  If Not b Then
   Raise Exception.Create(m);
 End;

Procedure SetN(Const Name : String; Value : Double);
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

Procedure SetTitle(Const Title : String);
 Var
  k : Integer;
 Begin
  For k := 0 To FieldCount - 1 Do
   If SimFields[k].Name = 'title' Then
    Begin
     s.Texts[k] := Title;
     Exit;
    End;
 End;

Procedure ReadMode(Mode : Integer);
 Begin
  Reader.Close;
  Reset(Mode);
  Reader.Tick;
  n := Reader.Snapshot(v, Age, 3000);
 End;

Type

 [TestFixture]
 TVerifyFBWTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyFBWTests.Regression;
 Begin
  MockPath := ExtractFilePath(ParamStr(0)) + 'MockFenixSim.dll';
  DLL      := LoadLibrary(PChar(MockPath));
  Check(DLL <> 0, 'Load mock aircraft transport');
  @Reset := GetProcAddress(DLL, 'FenixMockReset');
  @Counter := GetProcAddress(DLL, 'FenixMockCount');
  Reader   := TFBWReader.Create(MockPath);
  Provider := TFBWProvider.Create(MockPath);
  s        := TFlightSample.Create;
  DB       := Nil;
  Try
   Check(Provider.Matches('FlyByWire A320neo LOT'), 'FlyByWire title');
   Check(Provider.Matches('FBW-A32NX LOT'), 'A32NX title');
   Check(Not Provider.Matches('Fenix A320 CFM'), 'No Fenix match');
   Check(Not Provider.Matches('Asobo A320neo'), 'No generic A320 match');
   Check(Not Provider.Matches('FlyByWire A380X'), 'No FBW A380 match');
   Check(IndexOf('A32NX_AUTOPILOT_1_ACTIVE') < 0, 'Deprecated AP fields excluded');
   Check(IndexOf('A32NX_AUTOBRAKES_ARMED_MODE_SET') < 0, 'Write-only setters excluded');
   Check(IndexOf('A32NX.FCU_AP_1_PUSH') < 0, 'Events excluded');
   ReadMode(0);
   Check(n = FBWFieldCount, 'All readable FBW L-vars');
   Check(Counter(0) = FBWFieldCount, 'All current catalog definitions');
   Check(Counter(5) = 0, 'Correct read-only API definition');
   Check(Counter(4) = 0, 'No writes');
   SetN('autopilot_master', 0);
   SetN('autopilot_throttle_arm', 0);
   SetN('autothrottle_active', 0);
   SetN('general_eng_throttle_lever_position[0]', 79);
   Provider.Apply(s, v, Age, '');
   Check(s.N('flaps_handle_index') = 4, 'Native FBW detent 3 maps to MSFS detent 4');
   Check(s.N('autopilot_throttle_arm') = 1, 'Documented A/THR armed');
   Check(s.N('autothrottle_active') = 1, 'Documented A/THR active');
   Check(s.N('autopilot_master') = 0, 'AP light is not actual AP state');
   Check(s.N('autopilot_airspeed_hold_var') = 180, 'FCU selected IAS');
   Check(s.N('general_eng_throttle_lever_position[0]') = 79, 'Flight dynamics retained');
   Check((s.AircraftData.GetValue('performance_reference') As TJSONObject).GetValue('vapp_kt').Value = '138', 'FMS VAPP in knots');
   ReadMode(8);
   SetN('flaps_handle_index', 2);
   Provider.Apply(s, v, Age, '');
   Check(s.N('flaps_handle_index') = 2, 'Initialization preserves SimConnect');
   Check(s.DataSources = Nil, 'No SDK overrides until ready');
   Check((s.AircraftData.GetValue('performance_reference') As TJSONObject).GetValue('vapp_kt') Is TJSONNull, 'No fabricated VAPP before ready');
   ReadMode(9);
   Provider.Apply(s, v, Age, '');
   Check(Abs(s.N('autopilot_mach_hold_var') - 0.78) < 0.00001, 'Mach value is not treated as IAS');
   ReadMode(10);
   SetN('autopilot_airspeed_hold_var', 222);
   Provider.Apply(s, v, Age, '');
   Check(s.N('autopilot_airspeed_hold_var') = 222, 'FCU dashes preserve target');
   For i := 1 To 7 Do
    Begin
     ReadMode(i);
     Case i Of
      1    : Check(n = FBWFieldCount - ((FBWFieldCount - 1) Mod LVarBatchSize + 1), 'Missing final batch remains unavailable');
      2    : Check(n = FBWFieldCount - 1, 'Nonfinite FBW value unavailable');
      3, 4 : Check(n = FBWFieldCount - LVarBatchSize, 'Optional failed or malformed batch isolated');
      5, 6 : Check(n = 0, 'Quit or missing replies clear values');
      7    : Check(n = FBWFieldCount, 'Raw transported zeros retained');
     End;
    End;
   Reader.Close;
   Registry := TAircraftProviders.Create('', MockPath);
   Try
    Reset(0);
    SetTitle('FBW A32NX LOT');
    Registry.Capture(s);
    Check(s.AircraftData.GetValue('provider').Value = 'FBWA32NX', 'Automatic FBW selection');
    Reset(6);
    SetTitle('FBW A32NX New Livery');
    Registry.Capture(s);
    Check(s.AircraftData.GetValue('status').Value = 'unavailable_simconnect_fallback', 'Aircraft change resets FBW cache');
    SetTitle('Asobo A320neo');
    Registry.Tick(s, True, 500);
    Registry.Capture(s);
    Check(s.AircraftData = Nil, 'No SDK values leak into other aircraft');
   Finally
    Registry.Free;
   End;
   ReadMode(0);
   Provider.Apply(s, v, Age, '');
   SetN('time_zulu.year', 2026);
   SetN('time_zulu.month', 10);
   SetN('time_zulu.day', 17);
   Path := TestDatabasePath(ExtractFilePath(ParamStr(0)) + 'fbw-' + IntToStr(GetTickCount64) + '.db');
   DB   := TFlightDatabase.Create(TestDatabasePath(Path), ExtractFilePath(ParamStr(0)) + 'sqlite3.dll');
   ID   := DB.StartTrip(s);
   DB.RecordSample(ID, s);
   SetN('time_zulu.seconds', 1);
   DB.RecordSample(ID, s);
   Check(DB.Connection.ExecSQLScalar('select count(*) from trip_aircraft_data') = 1, 'Unchanged FBW state omitted');
   Flaps    := IndexOf('A32NX_FLAPS_HANDLE_INDEX');
   v[Flaps] := 4;
   Provider.Apply(s, v, Age, '');
   SetN('time_zulu.seconds', 2);
   DB.RecordSample(ID, s);
   EventID := DB.Contact(ID, s, True);
   Check(Pos('A32NX_SPEEDS_VAPP', String(DB.Connection.ExecSQLScalar('select payload from trip_aircraft_data order by sample desc limit 1'))) = 0, 'Delta omits unchanged raw FBW fields');
   For i := 0 To High(v) Do
    v[i] := NaN;
   Provider.Apply(s, v, 0, 'No response');
   SetN('time_zulu.seconds', 3);
   DB.RecordSample(ID, s);
   ReadMode(0);
   Provider.Apply(s, v, Age, '');
   SetN('time_zulu.seconds', 4);
   DB.RecordSample(ID, s);
   Plot := DB.LoadTrip(ID);
   Try
    i := Plot.Labels.IndexOf('FBWLVar.A32NX_FLAPS_HANDLE_INDEX');
    Check(i >= 0, 'FBW chart parameter');
    Check(Plot.Points[0].Values[i] = 3, 'Raw FBW chart baseline');
    Check(Plot.Points[1].Values[i] = 3, 'FBW carry forward');
    Check(Plot.Points[2].Values[i] = 4, 'Raw full flap detent');
    Check(IsNan(Plot.Points[3].Values[i]), 'FBW chart gap');
    Check(Plot.Points[4].Values[i] = 3, 'FBW chart recovery');
   Finally
    Plot.Free;
   End;
   q            := TFDQuery.Create(Nil);
   q.Connection := DB.Connection;
   Try
    q.Open('select * from trip_touchdowns where id=:i', [EventID]);
    Context := BuildContactContext(DB, q, 1, 1);
    Try
     Check(Context.GetValue('fbw_lvar_field_definitions') <> Nil, 'FBW field definitions in AI');
     Check(Pos('vapp_kt', Context.ToJSON) > 0, 'VAPP in AI');
     Check(Pos('FBWA32NX', Context.ToJSON) > 0, 'FBW samples in AI');
    Finally
     Context.Free;
    End;
   Finally
    q.Free;
   End;
   DB.DeleteTrip(ID);
   Check(DB.Connection.ExecSQLScalar('select count(*) from trip_aircraft_data') = 0, 'FBW trip cleanup');
  Finally
   DB.Free;
   s.Free;
   Provider.Free;
   Reader.Free;
   FreeLibrary(DLL);
   If Path <> '' Then
    DeleteFile(PChar(Path));
  End;
  System.Writeln('PASS: FBW title detection, readable API catalog, real DLL calls, optional failures, readiness, A/THR, flap mapping, IAS/Mach/dashes, VAPP, cache isolation, delta history, charts and AI. Mock only.');

 End;

Begin
 RunNativeTests(TVerifyFBWTests);
End.
