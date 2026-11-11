Program VerifyFenix;

{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU In 'TestPathsU.pas', DUnitX.TestFramework, NativeTestRunnerU In 'NativeTestRunnerU.pas',
 Winapi.Windows, System.SysUtils, System.Math, System.JSON, System.IOUtils, FireDAC.Comp.Client,

 FlightTelemetryU In '..\src\Telemetry\FlightTelemetryU.pas', TelemetryCatalogU In '..\src\Telemetry\TelemetryCatalogU.pas', FlightDatabaseU In '..\src\Data\FlightDatabaseU.pas', AircraftTelemetryU In '..\src\Telemetry\AircraftTelemetryU.pas', FenixReaderU In '..\src\Aircraft\Fenix\FenixReaderU.pas', FenixCatalogU In '..\src\Aircraft\Fenix\FenixCatalogU.pas', AircraftDataStoreU In '..\src\Data\AircraftDataStoreU.pas', AnalysisContextU In '..\src\Analysis\AnalysisContextU.pas';

Type
 TReset = Procedure(Mode : Integer);

 Stdcall;

 TCount = Function(Kind : Integer) : Integer;

 Stdcall;

Var
 DLL      : HMODULE;
 Reset    : TReset;
 Counter  : TCount;
 Reader   : TFenixReader;
 Registry : TAircraftProviders;
 Provider : TFenixProvider;
 s        : TFlightSample;
 DB       : TFlightDatabase;
 q        : TFDQuery;
 v        : TArray<Double>;
 Age      : UInt64;
 n        : Integer;
 i        : Integer;
 Gear     : Integer;
 Flaps    : Integer;
 ID       : Integer;
 EventID  : Integer;
 Path     : String;
 MockPath : String;
 Plot     : TTripPlot;
 Context  : TJSONObject;
 State    : TJSONObject;
 History  : TAircraftHistory;

 Packet : Array [0..40 + FenixBatchSize * 8 - 1] Of Byte;

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

Function IndexOf(Const Name : String) : Integer;
 Begin
  For Result := 0 To FenixFieldCount - 1 Do
   If FenixFields[Result].Name = Name Then
    Exit;
  Raise Exception.Create(Name);
 End;

Procedure Put(Offset : Integer; Value : DWORD);
 Begin
  Move(Value, Packet[Offset], 4);
 End;

Type

 [TestFixture]
 TVerifyFenixTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyFenixTests.Regression;
 Begin

  MockPath := ExtractFilePath(ParamStr(0)) + 'MockFenixSim.dll';
  DLL      := LoadLibrary(PChar(MockPath));
  Check(DLL <> 0, 'Load mock Fenix transport');

  @Reset := GetProcAddress(DLL, 'FenixMockReset');
  @Counter := GetProcAddress(DLL, 'FenixMockCount');

  Reader   := TFenixReader.Create(MockPath);
  Provider := TFenixProvider.Create(MockPath);
  s        := TFlightSample.Create;
  DB       := Nil;

  Try

   Check(Provider.Matches('Fenix A320 CFM LOT SP-LNA'), 'Fenix title');
   Check(IndexOf('B_CONFIG_BARO_UNIT') >= 0, 'Current modular cockpit baro configuration included');
   Check(IndexOf('N_CONFIG_ENGINETYPE') >= 0, 'Renamed engine configuration included');
   Check(FenixRetiredFieldCount > 0, 'Historical-only definitions preserved');
   For i := 0 To FenixFieldCount - 1 Do
    Check(FenixFields[i].Name <> 'CB_A01_HP_FUEL_SOV_1', 'Retired circuit breaker is not subscribed');
   Check(Provider.Matches('FNX_320_IAE'), 'FNX title');

   Check(Not Provider.Matches('iFly 737-MAX8 LOT'), 'No iFly match');
   Check(Not Provider.Matches('Asobo A320neo'), 'No other Airbus match');

   Registry := TAircraftProviders.Create(MockPath);

   Try

    Reset(0);
    SetTitle('Asobo A320neo');
    Registry.Capture(s);
    Check(s.AircraftData = Nil, 'Generic aircraft uses SimConnect only');
    Check(Counter(0) = 0, 'No Fenix requests for other aircraft');

    SetTitle('Fenix A320 LOT');
    Registry.Capture(s);
    Check(s.AircraftData.GetValue('provider').Value = 'FenixA32X', 'Automatic Fenix provider selection');
    Check(s.AircraftData.GetValue('received_field_count').Value = IntToStr(FenixFieldCount), 'Automatic live reader capture');

    Reset(6);
    SetTitle('Fenix A320 Another Livery');
    Registry.Capture(s);
    Check(s.AircraftData.GetValue('status').Value = 'unavailable_simconnect_fallback', 'Changing Fenix title invalidates old data');

    SetTitle('Asobo A320neo');
    Registry.Tick(s, True, 500);
    Registry.Capture(s);
    Check(s.AircraftData = Nil, 'Leaving Fenix clears provider state');

   Finally
    Registry.Free;
   End;

   Reset(0);
   Reader.Tick;
   n := Reader.Snapshot(v, Age, 3000);
   Check(n = FenixFieldCount, 'All Fenix L-vars decoded');

   Check(Counter(0) = FenixFieldCount, 'Every L-var defined');
   Check(Counter(1) = FenixBatchCount, 'Bounded definition batches');
   Check(Counter(5) = 0, 'Correct names, datatype, units and read requests');
   Check(Counter(4) = 0, 'No simulator writes');

   Gear  := IndexOf('S_MIP_GEAR');
   Flaps := IndexOf('S_FC_FLAPS');
   Check(v[Gear] = 1, 'Gear L-var value');
   Check(v[Flaps] = 3, 'Flap L-var value');

   SetN('gear_handle_position', 0);
   SetN('flaps_handle_index', 0);
   SetN('general_eng_throttle_lever_position[0]', 79);
   SetN('autopilot_master', 0);

   Provider.Apply(s, v, Age, '');
   Check(s.N('gear_handle_position') = 1, 'Gear SDK precedence');
   Check(s.N('flaps_handle_index') = 3, 'Flap SDK precedence');

   Check(s.N('general_eng_throttle_lever_position[0]') = 79, 'Fenix animation input is not throttle percent');
   Check(s.N('autopilot_master') = 0, 'AP annunciator not mistaken for AP master');

   Check(s.DataSources.GetValue('gear_handle_position').Value = 'FenixLVar:S_MIP_GEAR', 'Fenix provenance');

   // Transport failures remain optional and never invent zero values.

   For i := 1 To 7 Do
    Begin

     Reader.Close;
     Reset(i);
     Reader.Tick;
     n := Reader.Snapshot(v, Age, 3000);

     Case i Of

      1 :
       Check(n = FenixFieldCount - (FenixFieldCount Mod FenixBatchSize), 'Missing batch is null');

      2 :
       Begin
        Check(n = FenixFieldCount - 1, 'Non-finite L-var is null');
        Check(IsNan(v[Gear]), 'Invalid gear not zero');
       End;

      3 :
       Begin
        Check(n = FenixFieldCount - FenixBatchSize, 'Optional exception isolates batch');
        Check(Reader.LastError <> '', 'Optional exception diagnostics');
       End;

      4 :
       Check(n = FenixFieldCount - FenixBatchSize, 'Malformed batch rejected');

      5 :
       Check(n = 0, 'Quit invalidates cached values');

      6 :
       Check(n = 0, 'No replies produce null values');

      7 :
       Begin
        Check(n = FenixFieldCount, 'Received zero values retained');
        Check(v[Gear] = 0, 'Real transported zero retained');
       End;

     End;

    End;

   Reader.Close;
   Reset(0);
   Reader.Tick;
   Check(Reader.Snapshot(v, Age, 3000) = FenixFieldCount, 'Reconnection');

   FillChar(Packet, SizeOf(Packet), 0);
   Put(8, 8);

   For i := 0 To FenixBatchCount - 1 Do
    Begin

     Put(12, 2000 + i);
     Put(20, 1000 + i);
     n := Min(FenixBatchSize, FenixFieldCount - i * FenixBatchSize);
     Put(36, n);

     Reader.Feed(@Packet[0], 40 + n * 8, GetTickCount64 - 10000);

    End;

   Check(Reader.Snapshot(v, Age, 1000) = 0, 'Stale packets expire');

   Reader.Close;
   Reset(0);
   Reader.Tick;
   Reader.Snapshot(v, Age, 3000);
   Provider.Apply(s, v, Age, '');

   SetN('time_zulu.year', 2026);
   SetN('time_zulu.month', 10);
   SetN('time_zulu.day', 17);

   Path := TestDatabasePath(ExtractFilePath(ParamStr(0)) + 'fenix-' + IntToStr(GetTickCount64) + '.db');
   DB   := TFlightDatabase.Create(TestDatabasePath(Path), ExtractFilePath(ParamStr(0)) + 'sqlite3.dll');
   ID   := DB.StartTrip(s);

   TJSONObject(s.AircraftData.GetValue('fields')).AddPair('CB_LEGACY_FIXTURE', TJSONNumber.Create(7));
   DB.RecordSample(ID, s);
   SetN('time_zulu.seconds', 1);
   DB.RecordSample(ID, s);

   Check(DB.Connection.ExecSQLScalar('select count(*) from trip_aircraft_data') = 1, 'Unchanged Fenix state omitted');

   v[Flaps] := 1;
   Provider.Apply(s, v, Age, '');
   SetN('time_zulu.seconds', 2);
   DB.RecordSample(ID, s);
   EventID := DB.Contact(ID, s, True);

   Check(Pos('I_FCU_AP1', String(DB.Connection.ExecSQLScalar('select payload from trip_aircraft_data order by sample desc limit 1'))) = 0, 'Delta omits unchanged Fenix fields');

   For i := 0 To High(v) Do
    v[i] := NaN;
   SetN('gear_handle_position', 0.5);
   Provider.Apply(s, v, 0, 'No fresh Fenix response');
   SetN('time_zulu.seconds', 3);
   DB.RecordSample(ID, s);

   Check(s.DataSources = Nil, 'Outage clears SDK overrides');
   Check(s.N('gear_handle_position') = 0.5, 'Outage preserves SimConnect');

   Reader.Close;
   Reset(0);
   Reader.Tick;
   Reader.Snapshot(v, Age, 3000);
   Provider.Apply(s, v, Age, '');
   SetN('time_zulu.seconds', 4);
   DB.RecordSample(ID, s);

   // A provider change must reset carry-forward state instead of mixing aircraft.

   FreeAndNil(s.AircraftData);
   FreeAndNil(s.DataSources);
   s.AircraftData := TJSONObject.ParseJSONValue('{"provider":"iFly737MAX","status":"available","fields":{"CabinAltitude":5000}}') As TJSONObject;

   SetN('time_zulu.seconds', 5);
   DB.RecordSample(ID, s);

   Plot := DB.LoadTrip(ID);

   Try

    i := Plot.Labels.IndexOf('FenixLVar.S_FC_FLAPS');
    Check(i >= 0, 'Fenix chart parameter');
    Check(Plot.Labels.IndexOf('FenixLVar.CB_LEGACY_FIXTURE') >= 0, 'Historical fields absent from new live catalog remain visible');
    Check(Plot.Points[0].Values[Plot.Labels.IndexOf('FenixLVar.CB_LEGACY_FIXTURE')] = 7, 'Historical field value preserved');

    Check(Plot.Points[0].Values[i] = 3, 'Fenix chart baseline');
    Check(Plot.Points[1].Values[i] = 3, 'Fenix chart carry forward');
    Check(Plot.Points[2].Values[i] = 1, 'Fenix chart delta');

    Check(IsNan(Plot.Points[3].Values[i]), 'Fenix chart outage gap');
    Check(Plot.Points[4].Values[i] = 3, 'Fenix chart reconnect');
    Check(IsNan(Plot.Points[5].Values[i]), 'No cross-provider carry forward');

    i := Plot.Labels.IndexOf('iFlySDK.CabinAltitude');
    Check(Plot.Points[5].Values[i] = 5000, 'iFly history still loads');

   Finally
    Plot.Free;
   End;

   q            := TFDQuery.Create(Nil);
   q.Connection := DB.Connection;

   Try

    q.Open('select * from trip_touchdowns where id=:i', [EventID]);
    Context := BuildContactContext(DB, q, 1, 1);

    Try

     Check(Context.GetValue('fenix_lvar_field_definitions') <> Nil, 'Fenix definitions in AI');

     Check(Pos('FenixA32X', Context.ToJSON) > 0, 'Fenix payload in AI');
     Check(Pos('S_FC_FLAPS', Context.ToJSON) > 0, 'Fenix window baseline');

     Check(Pos('unavailable_simconnect_fallback', Context.ToJSON) > 0, 'Fenix outage in AI');

    Finally
     Context.Free;
    End;

   Finally
    q.Free;
   End;

   History := TAircraftHistory.Create(DB.Connection, ID);

   Try
    State := History.AtSample(DB.Connection.ExecSQLScalar('select max(id) from trip_data'));
    Try
     Check(Pos('S_FC_FLAPS', State.ToJSON) = 0, 'Provider reset drops old fields');
    Finally
     State.Free;
    End;
   Finally
    History.Free;
   End;

   DB.DeleteTrip(ID);
   Check(DB.Connection.ExecSQLScalar('select count(*) from trip_aircraft_data') = 0, 'Fenix history deletion');

  Finally
   DB.Free;
   s.Free;
   Provider.Free;
   Reader.Free;
   FreeLibrary(DLL);
   If Path <> '' Then
    DeleteFile(PChar(Path));
  End;

  System.Writeln('PASS: automatic Fenix matching, ', FenixFieldCount, ' active L-vars via mock SimConnect DLL, batching, read-only API, provenance, zeros/null/stale/partial/malformed/error/reconnect, delta storage, charts, AI and provider isolation.');

 End;

Begin
 RunNativeTests(TVerifyFenixTests);
End.
