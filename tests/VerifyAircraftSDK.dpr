Program VerifyAircraftSDK;

{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU In 'TestPathsU.pas', DUnitX.TestFramework, NativeTestRunnerU In 'NativeTestRunnerU.pas',
 Winapi.Windows, System.SysUtils, System.Math, System.JSON, System.IOUtils, FireDAC.Comp.Client,

 FlightTelemetryU In '..\src\Telemetry\FlightTelemetryU.pas', FlightDatabaseU In '..\src\Data\FlightDatabaseU.pas', AircraftTelemetryU In '..\src\Telemetry\AircraftTelemetryU.pas', AircraftDataStoreU In '..\src\Data\AircraftDataStoreU.pas', iFlyReaderU In '..\src\Aircraft\iFly\iFlyReaderU.pas', iFlySDKCatalogU In '..\src\Aircraft\iFly\iFlySDKCatalogU.pas', FDRTypesU In '..\src\Core\FDRTypesU.pas', TelemetryCatalogU In '..\src\Telemetry\TelemetryCatalogU.pas', AnalysisContextU In '..\src\Analysis\AnalysisContextU.pas';

Procedure Check(b : Boolean; Const m : String);
 Begin
  If Not b Then
   Raise Exception.Create(m);
 End;

Var
 p       : TIFlyProvider;
 r       : TIFlyReader;
 v       : TReadings;
 Stamp   : TCaptureTime;
 Map     : THandle;
 Mutex   : THandle;
 View    : Pointer;
 Buffer  : Array [0..SDKSize - 1] Of Byte;
 s       : TFlightSample;
 q       : TFDQuery;
 Context : TJSONObject;
 Samples : TJSONArray;
 EventID : Integer;
 DB      : TFlightDatabase;
 ID      : Integer;
 i       : Integer;
 RowID   : Integer;
 History : TAircraftHistory;
 State   : TJSONObject;
 Plot    : TTripPlot;
 Name    : String;
 Path    : String;

Procedure Put(Const Field : String; Value : Double);
 Var
  k : Integer;
  n : Integer;
 Begin
  For k := 0 To SDKFieldCount - 1 Do
   If SDKFields[k].Name = Field Then
    Begin

     n := Round(Value);
     If SDKFields[k].Kind = 'float64' Then
      Move(Value, Buffer[SDKFields[k].Offset], 8)

     Else If SDKFields[k].Kind = 'int32' Then
      Move(n, Buffer[SDKFields[k].Offset], 4)

     Else
      Buffer[SDKFields[k].Offset] := n;
     Exit;
    End;
  Raise Exception.Create(Field);
 End;

Procedure SetN(Const Field : String; Value : Double);
 Var
  k : Integer;
 Begin
  For k := 0 To FieldCount - 1 Do
   If SimFields[k].Name = Field Then
    Begin
     s.Numbers[k] := Value;
     Exit;
    End;
  Raise Exception.Create(Field);
 End;

Type

 [TestFixture]
 TVerifyAircraftSDKTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyAircraftSDKTests.Regression;
 Begin

  Name := 'MSFSFDRTest' + IntToStr(GetCurrentProcessId);
  Path := TestDatabasePath(ExtractFilePath(ParamStr(0)) + 'sdk-' + Name + '.db');

  Mutex := CreateMutex(Nil, False, PChar(Name + 'Mutex'));
  Map   := CreateFileMapping(INVALID_HANDLE_VALUE, Nil, PAGE_READWRITE, 0, SDKSize, PChar(Name + 'Map'));
  View  := MapViewOfFile(Map, FILE_MAP_WRITE, 0, 0, SDKSize);

  r  := TIFlyReader.Create(Name + 'Map', Name + 'Mutex');
  p  := TIFlyProvider.Create;
  s  := TFlightSample.Create;
  DB := Nil;

  Try

   Check(p.Matches('iFly 737-MAX8 LOT SP-LVA (166Seat)'), 'Detect iFly title');
   Check(Not p.Matches('Boeing 737 MAX8'), 'No other vendor');

   Check(Not p.Matches('iFly 737-700'), 'No other model');

   FillChar(Buffer, SizeOf(Buffer), 0);
   Put('iFly737MAX_STATE', 1);
   Put('Aircraft_Model', 1);
   Put('FLAP_Status', 5);
   Put('Gear_Lever_Status', 1);
   Put('Throttle_Lever_1_Position', 0.63);
   Put('AT_Switch_Status', 1);
   Put('HDG_100_Status', 2);
   Put('HDG_10_Status', 5);
   Put('HDG_1_Status', 1);
   Put('SPD_100_Status', 2);
   Put('SPD_10_Status', 4);
   Put('SPD_1_Status', 0);

   Move(Buffer, View^, SDKSize);
   Check(r.Read(v, Stamp), 'Read mapped SDK');
   Check(Length(v) = SDKFieldCount, 'Read every SDK field');

   SetN('time_zulu.year', 2026);
   SetN('time_zulu.month', 10);
   SetN('time_zulu.day', 17);
   SetN('airspeed_indicated', 145);
   SetN('number_of_engines', 2);

   p.Apply(s, v);
   Check(s.N('flaps_handle_index') = 5, 'SDK flap override');
   Check(Abs(s.N('general_eng_throttle_lever_position[0]') - 63) < 0.001, 'Throttle unit conversion');
   Check(s.N('airspeed_indicated') = 145, 'SimConnect dynamics preserved');
   Check(s.N('autopilot_heading_lock_dir') = 251, 'SDK selected heading digits');
   Check(s.N('autopilot_airspeed_hold_var') = 240, 'SDK selected IAS digits');

   SetN('autopilot_heading_lock_dir', 123);
   Put('HDG_100_Status', 14);
   Move(Buffer, View^, SDKSize);
   Check(r.Read(v, Stamp), 'Read blank display');
   p.Apply(s, v);
   Check(s.N('autopilot_heading_lock_dir') = 123, 'Blank SDK digits preserve SimConnect');

   Put('HDG_100_Status', 2);
   Move(Buffer, View^, SDKSize);
   Check(r.Read(v, Stamp), 'Read restored display');
   p.Apply(s, v);

   Check((s.AircraftData.GetValue('fields') As TJSONObject).Count = SDKFieldCount, 'All raw SDK fields');

   DB := TFlightDatabase.Create(TestDatabasePath(Path), ExtractFilePath(ParamStr(0)) + 'sqlite3.dll');
   ID := DB.StartTrip(s);

   DB.RecordSample(ID, s);
   SetN('time_zulu.seconds', 1);
   DB.RecordSample(ID, s);

   Check(DB.Connection.ExecSQLScalar('select count(*) from trip_aircraft_data') = 1, 'Unchanged SDK omitted');

   Put('FLAP_Status', 6);
   Move(Buffer, View^, SDKSize);
   Check(r.Read(v, Stamp), 'Read changed SDK');
   p.Apply(s, v);
   SetN('time_zulu.seconds', 2);
   DB.RecordSample(ID, s);

   State := TJSONObject.ParseJSONValue(DB.Connection.ExecSQLScalar('select payload from trip_aircraft_data order by sample desc limit 1')) As TJSONObject;

   Try
    Check(Pos('FLAP_Status', State.ToJSON) > 0, 'SDK delta includes change');
    Check(Pos('Aircraft_Model', State.ToJSON) = 0, 'SDK delta omits unchanged');
   Finally
    State.Free;
   End;

   EventID := DB.Contact(ID, s, True);

   FreeAndNil(s.AircraftData);
   FreeAndNil(s.DataSources);
   s.AircraftData := TJSONObject.Create;
   s.AircraftData.AddPair('provider', 'iFly737MAX');
   s.AircraftData.AddPair('status', 'unavailable_simconnect_fallback');
   SetN('time_zulu.seconds', 3);
   DB.RecordSample(ID, s);

   RowID   := DB.Connection.ExecSQLScalar('select max(id) from trip_data');
   History := TAircraftHistory.Create(DB.Connection, ID);

   Try
    State := History.AtSample(RowID);
    Try
     Check(Pos('FLAP_Status', State.ToJSON) = 0, 'No stale SDK on disconnect');
    Finally
     State.Free;
    End;
   Finally
    History.Free;
   End;

   p.Apply(s, v);
   SetN('time_zulu.seconds', 4);
   DB.RecordSample(ID, s);
   Plot := DB.LoadTrip(ID);

   Try
    i := Plot.Labels.IndexOf('iFlySDK.FLAP_Status');
    Check(i >= 0, 'SDK chart available');
    Check(Plot.Points[0].Values[i] = 5, 'SDK chart baseline');
    Check(Plot.Points[1].Values[i] = 5, 'SDK chart carry forward');
    Check(Plot.Points[2].Values[i] = 6, 'SDK chart delta');
    Check(IsNan(Plot.Points[3].Values[i]), 'SDK chart gap');
    Check(Plot.Points[4].Values[i] = 6, 'SDK chart reconnect');
   Finally
    Plot.Free;
   End;

   q            := TFDQuery.Create(Nil);
   q.Connection := DB.Connection;

   Try
    q.Open('select * from trip_touchdowns where id=:i', [EventID]);
    Context := BuildContactContext(DB, q, 1, 1);

    Try

     Check(Context.GetValue('ifly_sdk_field_definitions') <> Nil, 'SDK units/enum descriptions in analysis');

     Samples := Context.GetValue('samples') As TJSONArray;
     Check(Samples.Count = 3, 'Analysis window');

     Check(Pos('FLAP_Status', Samples.Items[0].ToJSON) > 0, 'Window baseline reconstructs earlier SDK data');

     Check(Pos('unavailable_simconnect_fallback', Samples.Items[2].ToJSON) > 0, 'Analysis SDK outage');

    Finally
     Context.Free;
    End;

   Finally
    q.Free;
   End;

   Put('iFly737MAX_STATE', 0);
   Move(Buffer, View^, SDKSize);
   Check(Not r.Read(v, Stamp), 'SDK not running rejected');

   DB.DeleteTrip(ID);
   Check(DB.Connection.ExecSQLScalar('select count(*) from trip_aircraft_data') = 0, 'SDK trip cleanup');

  Finally
   DB.Free;
   s.Free;
   p.Free;
   r.Free;
   UnmapViewOfFile(View);
   CloseHandle(Map);
   CloseHandle(Mutex);
   DeleteFile(PChar(Path));
  End;

  System.Writeln('PASS: official SDK shared memory, aircraft detection, all 2411 fields, precedence, units, delta persistence, chart replay, disconnect/reconnect and cleanup.');

 End;

Begin
 RunNativeTests(TVerifyAircraftSDKTests);
End.
