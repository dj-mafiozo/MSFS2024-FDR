Program VerifyPMDG;

{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU,
 Winapi.Windows, System.SysUtils, System.Math, System.JSON, FireDAC.Comp.Client, FlightTelemetryU, TelemetryCatalogU, FlightDatabaseU,

 AircraftTelemetryU, PMDGNG3ReaderU, PMDGNG3CatalogU, PMDGNG3DecodeU, AnalysisContextU;

Type
 TReset = Procedure(Mode : Integer);

 Stdcall;

 TCount = Function(Kind : Integer) : Integer;

 Stdcall;

Var
 DLL      : HMODULE;
 Reset    : TReset;
 Counter  : TCount;
 Reader   : TPMDGNG3Reader;
 Provider : TPMDGNG3Provider;
 Registry : TAircraftProviders;

 s           : TFlightSample;
 DB          : TFlightDatabase;
 q           : TFDQuery;
 Fields      : TJSONObject;
 Performance : TJSONObject;
 CDU         : TJSONObject;
 Context     : TJSONObject;
 Rows        : TJSONArray;

 Data     : TBytes;
 Screen   : TBytes;
 Packet   : TBytes;
 Age      : UInt64;
 i        : Integer;
 ID       : Integer;
 EventID  : Integer;
 Index    : Integer;
 Path     : String;
 MockPath : String;
 Plot     : TTripPlot;

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
  Reader.Snapshot(0, Data, Age);
 End;

Procedure SetSDKByte(Const Name : String; v : Byte);
 Var
  k : Integer;
 Begin
  For k := 0 To PMDGFieldCount - 1 Do
   If PMDGFields[k].Name = Name Then
    Begin
     Data[PMDGFields[k].Offset] := v;
     Exit;
    End;
  Raise Exception.Create(Name);
 End;

Procedure PutHeader(Offset : Integer; v : DWORD);
 Begin
  Move(v, Packet[Offset], 4);
 End;

Type

 [TestFixture]
 TVerifyPMDGTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyPMDGTests.Regression;
 Begin

  MockPath := ExtractFilePath(ParamStr(0)) + 'MockPMDGSim.dll';
  DLL      := LoadLibrary(PChar(MockPath));
  Check(DLL <> 0, 'Load mock PMDG transport');

  @Reset := GetProcAddress(DLL, 'PMDGMockReset');
  @Counter := GetProcAddress(DLL, 'PMDGMockCount');

  Reader   := TPMDGNG3Reader.Create(MockPath);
  Provider := TPMDGNG3Provider.Create(MockPath);
  s        := TFlightSample.Create;
  DB       := Nil;

  Try

   Check(Provider.Matches('PMDG 737-600 LOT'), 'PMDG 736');
   Check(Provider.Matches('PMDG 737-700 BBJ'), 'PMDG 737');
   Check(Provider.Matches('PMDG B738 LOT'), 'PMDG B738');

   Check(Not Provider.Matches('PMDG 777-300ER'), 'No PMDG widebody');
   Check(Not Provider.Matches('PMDG 737 MAX8'), 'No different MAX SDK');
   Check(Not Provider.Matches('iFly 737 MAX8'), 'No other vendor');

   ReadMode(0);
   Check(Length(Data) = PMDGDataSize, 'SDK block size');
   Check(Counter(0) = 3, 'Only main and CDU areas mapped');
   Check(Counter(1) = 3, 'SDK definitions');
   Check(Counter(2) = 6, 'ON_SET and ONCE requests');
   Check(Counter(5) = 0, 'Names, IDs, sizes and periods');
   Check(Counter(3) = 0, 'No SDK writes or controls');

   Fields := DecodePMDGData(Data);

   Try

    Check(Fields.Count = PMDGFieldCount, 'All 494 named fields');
    Check(Fields.GetValue('FMC_V1').Value = '135', 'V1 byte');
    Check(Fields.GetValue('MCP_VertSpeed').Value = '-700', 'Signed MCP vertical speed');

    Check(Fields.GetValue('FMC_LandingAltitude').Value = '-150', 'Signed below-sea-level elevation');
    Check(Fields.GetValue('COMM_ReceiverSwitches[0]').Value = IntToStr(Int64($F1234567)), 'Unsigned 32-bit flags');
    Check(Fields.GetValue('FMC_flightNumber').Value = 'LOT123', 'Null-terminated string');

   Finally
    Fields.Free;
   End;

   Check(Reader.Snapshot(1, Screen, Age), 'Optional captain CDU');
   CDU := DecodePMDGCDU(Screen);

   Try
    Rows := CDU.GetValue('rows') As TJSONArray;
    Check(Rows.Count = 14, '14 CDU rows');
    Check(Pos('PMDG CAPTAIN', Rows.Items[0].Value) = 1, 'Column-major CDU text');
    Check(Rows.Items[1].Value[1] = WideChar($2190), 'CDU special arrow');
    Check(Copy(CDU.GetValue('raw_cells_hex').Value, 7, 6) = 'A10101', 'CDU symbol/color/font flags preserved');
   Finally
    CDU.Free;
   End;

   SetN('gear_handle_position', 0.25);
   SetN('autopilot_master', 0);
   SetN('autothrottle_active', 0);
   SetN('autopilot_airspeed_hold_var', 222);

   Provider.Apply(s, Data, Age, '');
   Check(s.N('gear_handle_position') = 1, 'SDK down lever precedence');
   Check(s.N('autopilot_master') = 1, 'Actual AFS control');
   Check(s.N('autothrottle_active') = 1, 'Actual A/T servo connection');

   Check(s.N('fuel_total_quantity_weight') = 5000, 'Fuel mass pounds');
   Check(s.N('autopilot_vertical_hold_var') = -700, 'SDK vertical target');
   Check(s.N('autopilot_airspeed_hold_var') = 175, 'MCP IAS');

   Performance := s.AircraftData.GetValue('performance_reference') As TJSONObject;

   Check(Performance.GetValue('v1_kt').Value = '135', 'FMC V1 reference');
   Check(Performance.GetValue('vr_kt').Value = '140', 'FMC VR reference');
   Check(Performance.GetValue('v2_kt').Value = '145', 'FMC V2 reference');
   Check(Performance.GetValue('vref_kt').Value = '130', 'FMC VREF reference');
   Check(Performance.GetValue('distance_to_tod_nm').Value = '0', 'TOD passed zero remains valid');

   ReadMode(7);
   Provider.Apply(s, Data, Age, '');
   Performance := s.AircraftData.GetValue('performance_reference') As TJSONObject;

   Check(Performance.GetValue('v1_kt') Is TJSONNull, 'Unset V-speed not zero');
   Check(Performance.GetValue('vref_kt') Is TJSONNull, 'Unset VREF');
   Check(Performance.GetValue('landing_altitude_ft') Is TJSONNull, 'Unavailable altitude sentinel');
   Check(Performance.GetValue('distance_to_tod_nm') Is TJSONNull, 'Unavailable negative distance');

   ReadMode(8);
   SetN('gear_handle_position', 0.25);
   Provider.Apply(s, Data, Age, '');
   Check(s.N('gear_handle_position') = 0.25, 'OFF lever is not collapsed to up/down');
   Check(s.DataSources.GetValue('gear_handle_position') = Nil, 'OFF lever provenance retains SimConnect');

   ReadMode(9);
   Provider.Apply(s, Data, Age, '');
   Check(Abs(s.N('autopilot_mach_hold_var') - 0.78) < 0.0001, 'MCP Mach float');

   ReadMode(10);
   SetN('autopilot_heading_lock_dir', 123);
   Provider.Apply(s, Data, Age, '');
   Check(s.N('autopilot_heading_lock_dir') = 123, 'Unpowered MCP preserves target');

   ReadMode(12);
   SetN('autopilot_airspeed_hold_var', 222);
   SetN('autopilot_vertical_hold_var', -222);
   Provider.Apply(s, Data, Age, '');
   Check(s.N('autopilot_airspeed_hold_var') = 222, 'Blank IAS');
   Check(s.N('autopilot_vertical_hold_var') = -222, 'Blank VS');

   ReadMode(2);
   SetN('pressurization_cabin_altitude', 2000);
   SetN('autopilot_airspeed_hold_var', 222);
   Provider.Apply(s, Data, Age, '');
   Check(s.AircraftData.GetValue('status').Value = 'partial', 'Malformed field makes partial status');
   Check(s.N('pressurization_cabin_altitude') = 2000, 'NaN does not override standard field');
   Check(s.N('autopilot_airspeed_hold_var') = 222, 'Invalid bool does not masquerade as blank=false');

   ReadMode(11);
   Provider.Apply(s, Data, Age, '');
   Check(s.DataSources = Nil, 'Uninitialized SDK does not override');
   Check(s.AircraftData.GetValue('status').Value = 'initializing', 'Model zero not valid flight data');

   For i := 1 To 6 Do
    Begin

     ReadMode(i);

     Case i Of

      1 :
       Begin
        Check(Length(Data) = PMDGDataSize, 'Missing optional CDU cannot block main data');
        Check(Not Reader.Snapshot(2, Screen, Age), 'Missing CDU unavailable');
       End;

      3, 4, 5, 6 :
       Check(Length(Data) = 0, 'Error/truncation/quit/no reply invalidates main data');

     End;

    End;

   ReadMode(15);
   Check(Length(Data) = PMDGDataSize, 'Optional CDU error isolated');
   Check(Not Reader.Snapshot(2, Screen, Age), 'Failed CDU unavailable');

   ReadMode(0);
   SetLength(Packet, 40 + PMDGDataSize);
   FillChar(Packet[0], Length(Packet), 0);
   PutHeader(8, 16);
   PutHeader(12, 7000);
   PutHeader(20, PMDGDataDefinition);
   PutHeader(36, 1);
   Move(Data[0], Packet[40], PMDGDataSize);

   Reader.Feed(@Packet[0], Length(Packet), GetTickCount64 - 60000);
   Check(Reader.Snapshot(0, Data, Age) And (Age >= 60000), 'ON_SET cached state retained without artificial heartbeat');

   Reader.Close;
   Registry := TAircraftProviders.Create('', '', MockPath);

   Try

    Reset(0);
    SetTitle('PMDG 737-600 LOT');
    Registry.Capture(s);
    Check(s.AircraftData.GetValue('provider').Value = 'PMDGNG3', 'Automatic SDK selection');
    Check(s.AircraftData.GetValue('cdu') <> Nil, 'Both CDUs included in snapshot');

    Reset(6);
    SetTitle('PMDG 737-800 Another Livery');
    Registry.Capture(s);
    Check(s.AircraftData.GetValue('status').Value = 'unavailable_simconnect_fallback', 'Aircraft change resets SDK cache');

    SetTitle('Asobo A320neo');
    Registry.Capture(s);
    Check(s.AircraftData = Nil, 'No SDK values leak into generic aircraft');

   Finally
    Registry.Free;
   End;

   ReadMode(0);
   Provider.Apply(s, Data, Age, '');
   SetN('time_zulu.year', 2026);
   SetN('time_zulu.month', 10);
   SetN('time_zulu.day', 17);

   Path := TestDatabasePath(ExtractFilePath(ParamStr(0)) + 'pmdg-' + IntToStr(GetTickCount64) + '.db');
   DB   := TFlightDatabase.Create(TestDatabasePath(Path), ExtractFilePath(ParamStr(0)) + 'sqlite3.dll');
   ID   := DB.StartTrip(s);

   DB.RecordSample(ID, s);
   SetN('time_zulu.seconds', 1);
   DB.RecordSample(ID, s);
   Check(DB.Connection.ExecSQLScalar('select count(*) from trip_aircraft_data') = 1, 'Unchanged PMDG SDK state omitted');

   SetSDKByte('FMC_V1', 136);
   Provider.Apply(s, Data, Age, '');
   SetN('time_zulu.seconds', 2);
   DB.RecordSample(ID, s);
   EventID := DB.Contact(ID, s, True);

   Check(Pos('FMC_VR', String(DB.Connection.ExecSQLScalar('select payload from trip_aircraft_data order by sample desc limit 1'))) = 0, 'Unchanged FMC fields omitted from delta');

   Provider.Apply(s, Nil, 0, 'No SDK data');
   SetN('time_zulu.seconds', 3);
   DB.RecordSample(ID, s);
   ReadMode(0);
   Provider.Apply(s, Data, Age, '');
   SetN('time_zulu.seconds', 4);
   DB.RecordSample(ID, s);

   Plot := DB.LoadTrip(ID);

   Try
    Index := Plot.Labels.IndexOf('PMDGNG3.FMC_V1');
    Check(Index >= 0, 'PMDG chart parameter');
    Check(Plot.Points[0].Values[Index] = 135, 'SDK chart baseline');
    Check(Plot.Points[1].Values[Index] = 135, 'SDK chart carry forward');
    Check(Plot.Points[2].Values[Index] = 136, 'SDK chart change');
    Check(IsNan(Plot.Points[3].Values[Index]), 'SDK chart gap');
    Check(Plot.Points[4].Values[Index] = 135, 'SDK chart recovery');
   Finally
    Plot.Free;
   End;

   q            := TFDQuery.Create(Nil);
   q.Connection := DB.Connection;

   Try
    q.Open('select * from trip_touchdowns where id=:i', [EventID]);
    Context := BuildContactContext(DB, q, 1, 1);

    Try
     Check(Context.GetValue('pmdg_ng3_field_definitions') <> Nil, 'SDK definitions in AI');
     Check(Pos('vref_kt', Context.ToJSON) > 0, 'FMC references in AI');
     Check(Pos('PMDGNG3', Context.ToJSON) > 0, 'SDK time series in AI');
    Finally
     Context.Free;
    End;

   Finally
    q.Free;
   End;

   DB.DeleteTrip(ID);
   Check(DB.Connection.ExecSQLScalar('select count(*) from trip_aircraft_data') = 0, 'SDK trip cleanup');

  Finally
   DB.Free;
   s.Free;
   Provider.Free;
   Reader.Free;
   FreeLibrary(DLL);
   If Path <> '' Then
    DeleteFile(PChar(Path));
  End;

  System.Writeln('PASS: PMDG NG3 typed Client Data, 494 fields, signed/float/text decoding, FMC sentinels, AP/AT, MCP blank/power/Mach, gear OFF, CDU layout/arrows/colors, optional failures, provider reset, cached ON_SET, delta history, charts and AI. Mock only.');

 End;

Begin
 RunNativeTests(TVerifyPMDGTests);
End.
