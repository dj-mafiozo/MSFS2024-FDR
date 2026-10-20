Unit AircraftTelemetryU;

Interface

 Uses
  Winapi.Windows, System.DateUtils, System.Math, System.SysUtils, System.JSON, System.Generics.Collections,
  FlightTelemetryU, iFlyReaderU, iFlySDKCatalogU, FDRTypesU, FenixReaderU, FenixCatalogU, AppLogU, FBWReaderU, FBWCatalogU, PMDGNG3ReaderU, PMDGNG3CatalogU, PMDGNG3DecodeU;

 Type
  TAircraftProvider = Class
   Public
    Function Matches(Const Title : String) : Boolean; Virtual; Abstract;
    Procedure Capture(S : TFlightSample); Virtual; Abstract;
    Procedure Deactivate; Virtual;
    Procedure Tick(IntervalMS : Integer); Virtual;
  End;

  TIFlyProvider = Class(TAircraftProvider)
   Private
    fReader : TIFlyReader;
   Public
    Constructor Create;
    Destructor Destroy; Override;
    Function Matches(Const Title : String) : Boolean; Override;
    Procedure Capture(S : TFlightSample); Override;
    Procedure Deactivate; Override;
    Procedure Apply(S : TFlightSample; Const Values : TReadings);
  End;

  TFenixProvider = Class(TAircraftProvider)
   Private
    fReader     : TFenixReader;
    fMaxAge     : UInt64;
    fLastStatus : String;
   Public
    Constructor Create(Const DLL : String = '');
    Destructor Destroy; Override;
    Function Matches(Const Title : String) : Boolean; Override;
    Procedure Deactivate; Override;
    Procedure Tick(IntervalMS : Integer); Override;
    Procedure Capture(S : TFlightSample); Override;
    Procedure Apply(S : TFlightSample; Const Values : TArray<Double>; AgeMS : UInt64; Const Error : String);
  End;

  TFBWProvider = Class(TAircraftProvider)
   Private
    fReader     : TFBWReader;
    fMaxAge     : UInt64;
    fLastStatus : String;
   Public
    Constructor Create(Const DLL : String = '');
    Destructor Destroy; Override;
    Function Matches(Const Title : String) : Boolean; Override;
    Procedure Deactivate; Override;
    Procedure Tick(IntervalMS : Integer); Override;
    Procedure Capture(S : TFlightSample); Override;
    Procedure Apply(S : TFlightSample; Const Values : TArray<Double>; AgeMS : UInt64; Const Error : String);
  End;

  TPMDGNG3Provider = Class(TAircraftProvider)
   Private
    fReader     : TPMDGNG3Reader;
    fLastStatus : String;
   Public
    Constructor Create(Const DLL : String = '');
    Destructor Destroy; Override;
    Function Matches(Const Title : String) : Boolean; Override;
    Procedure Deactivate; Override;
    Procedure Tick(IntervalMS : Integer); Override;
    Procedure Capture(S : TFlightSample); Override;
    Procedure Apply(S : TFlightSample; Const Data : TBytes; AgeMS : UInt64; Const Error : String);
  End;

  TAircraftProviders = Class
   Private
    fItems     : TObjectList<TAircraftProvider>;
    fLastTitle : String;
    Procedure CheckAircraft(Const Title : String);
   Public
    Constructor Create(Const FenixDLL : String = ''; Const FBWDLL : String = ''; Const PMDGDLL : String = '');
    Destructor Destroy; Override;
    Procedure RegisterProvider(P : TAircraftProvider);
    Procedure Tick(S : TFlightSample; Active : Boolean; IntervalMS : Integer);
    Procedure Capture(S : TFlightSample);
  End;

Implementation

 Uses
  FlightPadScreensU;

 Procedure TAircraftProvider.Deactivate;
  Begin
  End;

 Procedure TAircraftProvider.Tick(IntervalMS : Integer);
  Begin
  End;

 Procedure TIFlyProvider.Deactivate;
  Begin
   fReader.Close;
  End;

 Constructor TIFlyProvider.Create;
  Begin
   Inherited;
   fReader := TIFlyReader.Create;
  End;

 Destructor TIFlyProvider.Destroy;
  Begin
   fReader.Free;
   Inherited;
  End;

 Function TIFlyProvider.Matches(Const Title : String) : Boolean;
  Var
   T : String;
  Begin
   T      := UpperCase(Title).Replace('-', '').Replace(' ', '');
   Result := (Pos('IFLY', T) > 0) And ((Pos('737MAX8', T) > 0) Or (Pos('7378', T) > 0));
  End;

 Procedure TIFlyProvider.Capture(S : TFlightSample);
  Var
   V     : TReadings;
   Stamp : TCaptureTime;
  Begin
   If fReader.Read(V, Stamp) And ((V[1].ValueText = '1') Or (V[1].ValueText = '2')) Then
    Begin
     Apply(S, V);
     S.AircraftData.AddPair('capture_utc_us', TJSONNumber.Create(Stamp.UTCUS));
    End
   Else
    Begin
     S.AircraftData := TJSONObject.Create;
     S.AircraftData.AddPair('provider', 'iFly737MAX');
     S.AircraftData.AddPair('status', 'unavailable_simconnect_fallback');
    End;
  End;

 Procedure TIFlyProvider.Apply(S : TFlightSample; Const Values : TReadings);
  Var
   R      : TReading;
   Fields : TJSONObject;
   V      : Double;
   FS     : TFormatSettings;
   Function Digits(Const Prefix : String; Places : Integer; Out Number : Double) : Boolean;
    Var
     Place : Integer;
     Digit : TJSONValue;
     D     : Double;
    Begin
     Number := 0;
     Place  := Places;
     While Place > 0 Do
      Begin
       Digit := Fields.GetValue(Prefix + IntToStr(Place) + '_Status');
       If Not(Digit Is TJSONNumber) Then
        Exit(False);
       D := TJSONNumber(Digit).AsDouble;
       If (D < 0) Or (D > 9) Or (D <> Trunc(D)) Then
        Exit(False);
       Number := Number + D * Place;
       Place  := Place Div 10;
      End;
     Result := True;
    End;

  Begin
   FreeAndNil(S.DataSources);
   FreeAndNil(S.AircraftData);
   S.AircraftData := TJSONObject.Create;
   S.AircraftData.AddPair('provider', 'iFly737MAX');
   S.AircraftData.AddPair('status', 'available');
   S.AircraftData.AddPair('sdk_header_sha256', SDKHeaderSHA256);
   Fields := TJSONObject.Create;
   S.AircraftData.AddPair('fields', Fields);
   FS                  := TFormatSettings.Create;
   FS.DecimalSeparator := '.';
   For R In Values Do
    Begin
     If (R.Kind = 'char') Then
      Fields.AddPair(R.Name, R.ValueText)
     Else If TryStrToFloat(R.ValueText, V, FS) And Not IsNan(V) And Not IsInfinite(V) Then
      Begin
       Fields.AddPair(R.Name, TJSONNumber.Create(V));
       If R.Name = 'CabinAltitude' Then
        S.OverrideNumber('pressurization_cabin_altitude', V, 'iFlySDK:' + R.Name)
       Else If R.Name = 'Gear_Lever_Status' Then
        S.OverrideNumber('gear_handle_position', V, 'iFlySDK:' + R.Name)
       Else If R.Name = 'FLAP_Status' Then
        S.OverrideNumber('flaps_handle_index', V, 'iFlySDK:' + R.Name)
       Else If R.Name = 'Parking_Brake_Lever_Status' Then
        S.OverrideNumber('brake_parking_indicator', V, 'iFlySDK:' + R.Name)
       Else If R.Name = 'AT_Switch_Status' Then
        S.OverrideNumber('autopilot_throttle_arm', V, 'iFlySDK:' + R.Name)
       Else If R.Name = 'FD_1_Switch_Status' Then
        S.OverrideNumber('autopilot_flight_director_active', V, 'iFlySDK:' + R.Name)
       Else If R.Name = 'Throttle_Lever_1_Position' Then
        S.OverrideNumber('general_eng_throttle_lever_position[0]', V * 100, 'iFlySDK:' + R.Name)
       Else If R.Name = 'Throttle_Lever_2_Position' Then
        S.OverrideNumber('general_eng_throttle_lever_position[1]', V * 100, 'iFlySDK:' + R.Name);
      End
     Else
      Fields.AddPair(R.Name, TJSONNull.Create);
    End;
   If Digits('HDG_', 100, V) Then
    S.OverrideNumber('autopilot_heading_lock_dir', V, 'iFlySDK:HDG_digits');
   If Digits('ALT_', 10000, V) Then
    S.OverrideNumber('autopilot_altitude_lock_var', V, 'iFlySDK:ALT_digits');
   If Digits('SPD_', 100, V) And (Fields.GetValue('SPD_Point_Status') Is TJSONNumber) Then
    Begin
     If TJSONNumber(Fields.GetValue('SPD_Point_Status')).AsDouble = 0 Then
      S.OverrideNumber('autopilot_airspeed_hold_var', V, 'iFlySDK:SPD_digits'); // Mach decimal position is not defined by SDK 1.5: preserve SimConnect.
    End;
  End;

 Constructor TFenixProvider.Create(Const DLL : String);
  Begin
   Inherited Create;
   fReader := TFenixReader.Create(DLL);
   fMaxAge := 1500;
  End;

 Destructor TFenixProvider.Destroy;
  Begin
   fReader.Free;
   Inherited;
  End;

 Function TFenixProvider.Matches(Const Title : String) : Boolean;
  Begin
   Result := IsFenixAircraft(Title);
  End;

 Procedure TFenixProvider.Deactivate;
  Begin
   fReader.Close;
   fLastStatus := '';
  End;

 Procedure TFenixProvider.Tick(IntervalMS : Integer);
  Begin
   fMaxAge := UInt64(Max(1000, IntervalMS)) * 3;
   fReader.Tick;
  End;

 Procedure TFenixProvider.Capture(S : TFlightSample);
  Var
   V   : TArray<Double>;
   Age : UInt64;
  Begin
   fReader.Tick;
   fReader.Snapshot(V, Age, fMaxAge);
   Apply(S, V, Age, fReader.LastError);
   If fLastStatus <> S.AircraftData.GetValue('status').Value Then
    Begin
     fLastStatus := S.AircraftData.GetValue('status').Value;
     Log(2, 'Fenix L-vars: ' + fLastStatus + ' ' + S.AircraftData.GetValue('received_field_count').Value + '/' + IntToStr(FenixFieldCount) + ' ' + fReader.LastError);
    End;
  End;

 Procedure TFenixProvider.Apply(S : TFlightSample; Const Values : TArray<Double>; AgeMS : UInt64; Const Error : String);
  Var
   Fields : TJSONObject;
   i      : Integer;
   Count  : Integer;
   V      : Double;
  Begin
   FreeAndNil(S.DataSources);
   FreeAndNil(S.AircraftData);
   S.AircraftData := TJSONObject.Create;
   S.AircraftData.AddPair('provider', 'FenixA32X');
   S.AircraftData.AddPair('source', 'SimConnect L-vars (read only)');
   S.AircraftData.AddPair('cockpit_xml_sha256', FenixCockpitSHA256);
   S.AircraftData.AddPair('capture_utc', DateToISO8601(TTimeZone.Local.ToUniversalTime(Now), True));
   S.AircraftData.AddPair('max_transport_age_ms', TJSONNumber.Create(AgeMS));
   S.AircraftData.AddPair('validity', 'Finite values from complete fresh SimConnect packets. No response/invalid/stale values are null. SimConnect does not confirm individual L-var existence; an absent L-var returning zero cannot be distinguished from a genuine zero.');
   Fields := TJSONObject.Create;
   S.AircraftData.AddPair('fields', Fields);
   Count := 0;
   For i := 0 To FenixFieldCount - 1 Do
    Begin
     V := NaN;
     If i < Length(Values) Then
      V := Values[i];
     If IsNan(V) Or IsInfinite(V) Then
      Fields.AddPair(FenixFields[i].Name, TJSONNull.Create)
     Else
      Begin
       Inc(Count);
       Fields.AddPair(FenixFields[i].Name, TJSONNumber.Create(V));
       If (FenixFields[i].Name = 'S_MIP_GEAR') And ((V = 0) Or (V = 1)) Then
        S.OverrideNumber('gear_handle_position', V, 'FenixLVar:S_MIP_GEAR')
       Else If (FenixFields[i].Name = 'S_FC_FLAPS') And (V >= 0) And (V <= 4) And (V = Trunc(V)) Then
        S.OverrideNumber('flaps_handle_index', V, 'FenixLVar:S_FC_FLAPS');
      End;
    End;
   S.AircraftData.AddPair('received_field_count', TJSONNumber.Create(Count));
   If Count = 0 Then
    S.AircraftData.AddPair('status', 'unavailable_simconnect_fallback')
   Else If Count < FenixFieldCount Then
    S.AircraftData.AddPair('status', 'partial')
   Else
    S.AircraftData.AddPair('status', 'available');
   If Error <> '' Then
    S.AircraftData.AddPair('transport_error', Error);
  End;

 Constructor TFBWProvider.Create(Const DLL : String);
  Begin
   Inherited Create;
   fReader := TFBWReader.Create(DLL);
   fMaxAge := 3000;
  End;

 Destructor TFBWProvider.Destroy;
  Begin
   fReader.Free;
   Inherited;
  End;

 Function TFBWProvider.Matches(Const Title : String) : Boolean;
  Begin
   Result := IsFBWAircraft(Title);
  End;

 Procedure TFBWProvider.Deactivate;
  Begin
   fReader.Close;
   fLastStatus := '';
  End;

 Procedure TFBWProvider.Tick(IntervalMS : Integer);
  Begin
   fMaxAge := UInt64(Max(1000, IntervalMS)) * 3;
   fReader.Tick;
  End;

 Procedure TFBWProvider.Capture(S : TFlightSample);
  Var
   V   : TArray<Double>;
   Age : UInt64;
  Begin
   fReader.Tick;
   fReader.Snapshot(V, Age, fMaxAge);
   Apply(S, V, Age, fReader.LastError);
   If fLastStatus <> S.AircraftData.GetValue('status').Value Then
    Begin
     fLastStatus := S.AircraftData.GetValue('status').Value;
     Log(2, 'FBW A32NX L-vars: ' + fLastStatus + ' ' + S.AircraftData.GetValue('received_field_count').Value + '/' + IntToStr(FBWFieldCount) + ' ' + fReader.LastError);
    End;
  End;

 Procedure TFBWProvider.Apply(S : TFlightSample; Const Values : TArray<Double>; AgeMS : UInt64; Const Error : String);
  Var
   Fields      : TJSONObject;
   Performance : TJSONObject;
   i           : Integer;
   Count       : Integer;
   V           : Double;
   Mode        : Double;
   Ready       : Boolean;

   Function Number(Const Name : String; Out Value : Double) : Boolean;
    Var
     J : TJSONValue;
    Begin
     J      := Fields.GetValue(Name);
     Result := J Is TJSONNumber;
     If Result Then
      Value := TJSONNumber(J).AsDouble
     Else
      Value := NaN;
    End;

   Function Flag(Const Name : String; Expected : Double) : Boolean;
    Var
     N : Double;
    Begin
     Result := Number(Name, N) And (N = Expected);
    End;

  Begin
   FreeAndNil(S.DataSources);
   FreeAndNil(S.AircraftData);
   S.AircraftData := TJSONObject.Create;
   S.AircraftData.AddPair('provider', 'FBWA32NX');
   S.AircraftData.AddPair('source', 'SimConnect L-vars (read only)');
   S.AircraftData.AddPair('api_html_sha256', FBWSourceSHA256);
   S.AircraftData.AddPair('capture_utc', DateToISO8601(TTimeZone.Local.ToUniversalTime(Now), True));
   S.AircraftData.AddPair('max_transport_age_ms', TJSONNumber.Create(AgeMS));
   S.AircraftData.AddPair('validity', 'Raw documented readable L-vars; null=no fresh valid reply. SimConnect cannot distinguish an absent L-var returning zero from a real zero. API version may differ from installed aircraft.');
   Fields := TJSONObject.Create;
   S.AircraftData.AddPair('fields', Fields);
   Count := 0;
   For i := 0 To FBWFieldCount - 1 Do
    Begin
     V := NaN;
     If i < Length(Values) Then
      V := Values[i];
     If IsNan(V) Or IsInfinite(V) Then
      Fields.AddPair(FBWFields[i].Name, TJSONNull.Create)
     Else
      Begin
       Inc(Count);
       Fields.AddPair(FBWFields[i].Name, TJSONNumber.Create(V));
      End;
    End;
   Ready := Flag('A32NX_IS_READY', 1);
   S.AircraftData.AddPair('aircraft_ready', TJSONBool.Create(Ready));
   Performance := TJSONObject.Create;
   S.AircraftData.AddPair('performance_reference', Performance);
   If Ready And Number('A32NX_SPEEDS_VAPP', V) And (V > 0) And (V < 400) Then
    Performance.AddPair('vapp_kt', TJSONNumber.Create(V))
   Else
    Performance.AddPair('vapp_kt', TJSONNull.Create);
   If Ready Then
    Begin
     If Number('A32NX_FLAPS_HANDLE_INDEX', V) And (V >= 0) And (V <= 4) And (V = Trunc(V)) Then
      Begin
       If V > 0 Then
        V := V + 1;
       S.OverrideNumber('flaps_handle_index', V, 'FBWLVar:A32NX_FLAPS_HANDLE_INDEX (native 0..4 to MSFS 0/2..5)');
      End;
     If Number('A32NX_AUTOTHRUST_STATUS', V) And (V >= 0) And (V <= 2) And (V = Trunc(V)) Then
      Begin
       S.OverrideNumber('autopilot_throttle_arm', Ord(V > 0), 'FBWLVar:A32NX_AUTOTHRUST_STATUS');
       S.OverrideNumber('autothrottle_active', Ord(V = 2), 'FBWLVar:A32NX_AUTOTHRUST_STATUS');
      End;
     If Flag('A32NX_FCU_AFS_DISPLAY_SPD_MACH_DASHES', 0) And Number('A32NX_FCU_AFS_DISPLAY_SPD_MACH_VALUE', V) And Number('A32NX_FCU_AFS_DISPLAY_MACH_MODE', Mode) Then
      Begin
       If (Mode = 0) And (V > 0) And (V < 400) Then
        S.OverrideNumber('autopilot_airspeed_hold_var', V, 'FBWLVar:FCU SPD display')
       Else If (Mode = 1) And (V > 0) And (V < 1) Then
        S.OverrideNumber('autopilot_mach_hold_var', V, 'FBWLVar:FCU Mach display');
      End;
    End;
   S.AircraftData.AddPair('received_field_count', TJSONNumber.Create(Count));
   If Count = 0 Then
    S.AircraftData.AddPair('status', 'unavailable_simconnect_fallback')
   Else If Not Ready Then
    S.AircraftData.AddPair('status', 'initializing')
   Else If Count < FBWFieldCount Then
    S.AircraftData.AddPair('status', 'partial')
   Else
    S.AircraftData.AddPair('status', 'available');
   If Error <> '' Then
    S.AircraftData.AddPair('transport_error', Error);
  End;

 Constructor TPMDGNG3Provider.Create(Const DLL : String);
  Begin
   Inherited Create;
   fReader := TPMDGNG3Reader.Create(DLL);
  End;

 Destructor TPMDGNG3Provider.Destroy;
  Begin
   fReader.Free;
   Inherited;
  End;

 Function TPMDGNG3Provider.Matches(Const Title : String) : Boolean;
  Begin
   Result := IsPMDGNG3Aircraft(Title);
  End;

 Procedure TPMDGNG3Provider.Deactivate;
  Begin
   fReader.Close;
   fLastStatus := '';
  End;

 Procedure TPMDGNG3Provider.Tick(IntervalMS : Integer);
  Begin
   fReader.Tick;
  End;

 Procedure TPMDGNG3Provider.Capture(S : TFlightSample);
  Var
   Data : TBytes;
   Age  : UInt64;
   CDUs : TJSONObject;
   CDU  : TJSONObject;
   i    : Integer;
  Begin
   fReader.Tick;
   fReader.Snapshot(0, Data, Age);
   Apply(S, Data, Age, fReader.LastError);
   CDUs := TJSONObject.Create;
   S.AircraftData.AddPair('cdu', CDUs);
   For i := 0 To 1 Do
    Begin
     fReader.Snapshot(i + 1, Data, Age);
     CDU := DecodePMDGCDU(Data);
     CDU.AddPair('last_update_age_ms', TJSONNumber.Create(Age));
     CDUs.AddPair(IntToStr(i), CDU);
    End;
   If fLastStatus <> S.AircraftData.GetValue('status').Value Then
    Begin
     fLastStatus := S.AircraftData.GetValue('status').Value;
     Log(2, 'PMDG NG3 SDK: ' + fLastStatus + ' ' + fReader.LastError);
    End;
  End;

 Procedure TPMDGNG3Provider.Apply(S : TFlightSample; Const Data : TBytes; AgeMS : UInt64; Const Error : String);
  Var
   Fields      : TJSONObject;
   Performance : TJSONObject;
   i           : Integer;
   Count       : Integer;
   Ready       : Boolean;
   Powered     : Boolean;
   V           : Double;
   A           : Double;
   B           : Double;
   C           : Double;

   Function Number(Const Name : String; Out Value : Double) : Boolean;
    Var
     J : TJSONValue;
    Begin
     J      := Fields.GetValue(Name);
     Result := J Is TJSONNumber;
     If Result Then
      Value := TJSONNumber(J).AsDouble
     Else
      Value := NaN;
    End;

   Function Flag(Const Name : String) : Boolean;
    Var
     N : Double;
    Begin
     Result := Number(Name, N) And (N = 1);
    End;

   Procedure Reference(Const RawName, Alias : String; Minimum : Double);
    Var
     N : Double;
    Begin
     If Ready And Number(RawName, N) And (N >= Minimum) Then
      Performance.AddPair(Alias, TJSONNumber.Create(N))
     Else
      Performance.AddPair(Alias, TJSONNull.Create);
    End;

  Begin
   FreeAndNil(S.DataSources);
   FreeAndNil(S.AircraftData);
   S.AircraftData := TJSONObject.Create;
   S.AircraftData.AddPair('provider', 'PMDGNG3');
   S.AircraftData.AddPair('source', 'PMDG NG3 SDK / SimConnect Client Data (read only)');
   S.AircraftData.AddPair('sdk_header_sha256', PMDGHeaderSHA256);
   S.AircraftData.AddPair('capture_utc', DateToISO8601(TTimeZone.Local.ToUniversalTime(Now), True));
   S.AircraftData.AddPair('data_update_age_ms', TJSONNumber.Create(AgeMS));
   S.AircraftData.AddPair('cache_semantics', 'SDK updates use ON_SET; unchanged values are carried forward until the next broadcast. No artificial expiry without an SDK heartbeat. Age is wall-clock time since the last packet. Aircraft/pause/disconnect resets invalidate the cache.');
   Fields := DecodePMDGData(Data);
   S.AircraftData.AddPair('fields', Fields);
   Count := 0;
   For i := 0 To Fields.Count - 1 Do
    If Not(Fields.Pairs[i].JsonValue Is TJSONNull) Then
     Inc(Count);
   Ready := (Length(Data) >= PMDGDataSize) And Number('AircraftModel', V) And (V >= 1) And (V <= 22);
   S.AircraftData.AddPair('sdk_model_valid', TJSONBool.Create(Ready));
   Performance := TJSONObject.Create;
   S.AircraftData.AddPair('performance_reference', Performance);
   Reference('FMC_V1', 'v1_kt', 1);
   Reference('FMC_VR', 'vr_kt', 1);
   Reference('FMC_V2', 'v2_kt', 1);
   Reference('FMC_LandingVREF', 'vref_kt', 1);
   Reference('FMC_TakeoffFlaps', 'takeoff_flaps_deg', 1);
   Reference('FMC_LandingFlaps', 'landing_flaps_deg', 1);
   Reference('FMC_CruiseAlt', 'cruise_altitude_ft', 1);
   Reference('FMC_DistanceToTOD', 'distance_to_tod_nm', 0);
   Reference('FMC_DistanceToDest', 'distance_to_destination_nm', 0);
   If Ready And Number('FMC_LandingAltitude', V) And (V <> -32767) Then
    Performance.AddPair('landing_altitude_ft', TJSONNumber.Create(V))
   Else
    Performance.AddPair('landing_altitude_ft', TJSONNull.Create);
   If Ready Then
    Begin
     If Number('FMC_PerfInputComplete', V) Then
      Performance.AddPair('perf_input_complete', TJSONBool.Create(V = 1))
     Else
      Performance.AddPair('perf_input_complete', TJSONNull.Create);
     If Number('AFS_AutothrottleServosConnected', V) Then
      S.OverrideNumber('autothrottle_active', V, 'PMDGNG3:AFS_AutothrottleServosConnected');
     If Number('AFS_ControlsPitch', A) And Number('AFS_ControlsRoll', B) Then
      S.OverrideNumber('autopilot_master', Ord((A = 1) Or (B = 1)), 'PMDGNG3:AFS_ControlsPitch/Roll (active control incl. CWS)');
     If Number('MCP_ATArmSw', V) Then
      S.OverrideNumber('autopilot_throttle_arm', V, 'PMDGNG3:MCP_ATArmSw');
     If Number('MCP_FDSw[0]', V) Then
      S.OverrideNumber('autopilot_flight_director_active', V, 'PMDGNG3:MCP_FDSw[0]');
     If Number('AIR_CabinAltNeedle', V) Then
      S.OverrideNumber('pressurization_cabin_altitude', V, 'PMDGNG3:AIR_CabinAltNeedle');
     If Number('MAIN_GearLever', V) And ((V = 0) Or (V = 2)) Then
      S.OverrideNumber('gear_handle_position', V / 2, 'PMDGNG3:MAIN_GearLever (OFF retains SimConnect)');
     If Number('FUEL_QtyCenter', A) And Number('FUEL_QtyLeft', B) And Number('FUEL_QtyRight', C) And (A >= 0) And (B >= 0) And (C >= 0) Then
      S.OverrideNumber('fuel_total_quantity_weight', A + B + C, 'PMDGNG3:FUEL_QtyCenter/Left/Right (lb)');
     Powered := Flag('MCP_indication_powered');
     If Powered Then
      Begin
       If Number('MCP_Heading', V) And (V <= 360) Then
        S.OverrideNumber('autopilot_heading_lock_dir', V, 'PMDGNG3:MCP_Heading');
       If Number('MCP_Altitude', V) Then
        S.OverrideNumber('autopilot_altitude_lock_var', V, 'PMDGNG3:MCP_Altitude');
       If Number('MCP_VertSpeedBlank', B) And (B = 0) And Number('MCP_VertSpeed', V) Then
        S.OverrideNumber('autopilot_vertical_hold_var', V, 'PMDGNG3:MCP_VertSpeed');
       If Number('MCP_IASBlank', B) And (B = 0) And Number('MCP_IASMach', V) Then
        Begin
         If (V > 0) And (V < 1) Then
          S.OverrideNumber('autopilot_mach_hold_var', V, 'PMDGNG3:MCP_IASMach')
         Else If (V >= 10) And (V < 500) Then
          S.OverrideNumber('autopilot_airspeed_hold_var', V, 'PMDGNG3:MCP_IASMach');
        End;
      End;
    End;
   S.AircraftData.AddPair('received_field_count', TJSONNumber.Create(Count));
   If Length(Data) < PMDGDataSize Then
    S.AircraftData.AddPair('status', 'unavailable_simconnect_fallback')
   Else If Not Ready Then
    S.AircraftData.AddPair('status', 'initializing')
   Else If Count < PMDGFieldCount Then
    S.AircraftData.AddPair('status', 'partial')
   Else
    S.AircraftData.AddPair('status', 'available');
   If Error <> '' Then
    S.AircraftData.AddPair('transport_error', Error);
  End;

 Constructor TAircraftProviders.Create(Const FenixDLL, FBWDLL, PMDGDLL : String);
  Begin
   Inherited Create;
   fItems := TObjectList<TAircraftProvider>.Create(True);
   RegisterProvider(TIFlyProvider.Create);
   RegisterProvider(TFenixProvider.Create(FenixDLL));
   RegisterProvider(TFBWProvider.Create(FBWDLL));
   RegisterProvider(TPMDGNG3Provider.Create(PMDGDLL));
  End;

 Destructor TAircraftProviders.Destroy;
  Begin
   fItems.Free;
   Inherited;
  End;

 Procedure TAircraftProviders.RegisterProvider(P : TAircraftProvider);
  Begin
   fItems.Add(P);
  End;

 Procedure TAircraftProviders.CheckAircraft(Const Title : String);
  Var
   P : TAircraftProvider;
  Begin
   If fLastTitle = Title Then
    Exit;
   For P In fItems Do
    P.Deactivate;
   fLastTitle := Title;
  End;

 Procedure TAircraftProviders.Tick(S : TFlightSample; Active : Boolean; IntervalMS : Integer);
  Var
   P : TAircraftProvider;
  Begin
   CheckAircraft(S.S('title'));
   For P In fItems Do
    If Active And P.Matches(S.S('title')) Then
     P.Tick(IntervalMS)
    Else
     P.Deactivate;
  End;

 Procedure TAircraftProviders.Capture(S : TFlightSample);
  Var
   P : TAircraftProvider;
  Begin
   CheckAircraft(S.S('title'));
   FreeAndNil(S.AircraftData);
   FreeAndNil(S.DataSources);
   For P In fItems Do
    If Not P.Matches(S.S('title')) Then
     P.Deactivate;
   For P In fItems Do
    If P.Matches(S.S('title')) Then
     Begin
      P.Capture(S);
      AttachFlightPadScreen(S.AircraftData);
      Exit;
     End;
  End;

End.
