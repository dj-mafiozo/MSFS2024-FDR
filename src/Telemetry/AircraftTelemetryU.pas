{$StackFrames On}
Unit AircraftTelemetryU;

Interface

 Uses
  Winapi.Windows, System.DateUtils, System.Math, System.SysUtils, System.JSON, System.Generics.Collections,
  FlightTelemetryU, iFlyReaderU, iFlySDKCatalogU, FDRTypesU, FenixReaderU, FenixCatalogU,
  AppLogU, FBWReaderU, FBWCatalogU, PMDGNG3ReaderU, PMDGNG3CatalogU, PMDGNG3DecodeU, PMDG777ReaderU, PMDG777CatalogU, PMDG777DecodeU, AddonLVarCatalogU, AircraftLVarReaderU;

 Type
  TAircraftProvider = Class
   Function Matches(Const Title : String) : Boolean; Virtual; Abstract;

   Procedure Capture(s : TFlightSample); Virtual; Abstract;

   Procedure Deactivate; Virtual;

   Procedure Tick(IntervalMS : Integer); Virtual;

  End;

  TIFlyProvider = Class(TAircraftProvider)
   Private
    fReader : TIFlyReader;
   Public
    Constructor Create;
    Destructor  Destroy; Override;
    Function    Matches(Const Title : String) : Boolean; Override;
    Procedure   Capture(s : TFlightSample); Override;
    Procedure   Deactivate; Override;
    Procedure   Apply  (s : TFlightSample; Const Values : TReadings);
  End;

  TFenixProvider = Class(TAircraftProvider)
   Private
    fReader     : TFenixReader;
    fMaxAge     : UInt64;
    fLastStatus : String;
   Public
    Constructor Create (Const DLL : String = '');
    Destructor  Destroy; Override;
    Function    Matches(Const Title : String) : Boolean; Override;
    Procedure   Deactivate; Override;
    Procedure   Tick   (IntervalMS : Integer); Override;
    Procedure   Capture(s : TFlightSample); Override;
    Procedure   Apply  (s : TFlightSample; Const Values : TArray<Double>; AgeMS : UInt64; Const Error : String);
  End;

  TFBWProvider = Class(TAircraftProvider)
   Private
    fReader     : TFBWReader;
    fMaxAge     : UInt64;
    fLastStatus : String;
   Public
    Constructor Create (Const DLL : String = '');
    Destructor  Destroy; Override;
    Function    Matches(Const Title : String) : Boolean; Override;
    Procedure   Deactivate; Override;
    Procedure   Tick   (IntervalMS : Integer); Override;
    Procedure   Capture(s : TFlightSample); Override;
    Procedure   Apply  (s : TFlightSample; Const Values : TArray<Double>; AgeMS : UInt64; Const Error : String);
  End;

  TPMDGNG3Provider = Class(TAircraftProvider)
   Private
    fReader     : TPMDGNG3Reader;
    fLastStatus : String;
   Public
    Constructor Create (Const DLL : String = '');
    Destructor  Destroy; Override;
    Function    Matches(Const Title : String) : Boolean; Override;
    Procedure   Deactivate; Override;
    Procedure   Tick   (IntervalMS : Integer); Override;
    Procedure   Capture(s : TFlightSample); Override;
    Procedure   Apply  (s : TFlightSample; Const Data : TBytes; AgeMS : UInt64; Const Error : String);
  End;

  TPMDG777Provider = Class(TAircraftProvider)
   Private
    fReader     : TPMDG777Reader;
    fLastStatus : String;
   Public
    Constructor Create (Const DLL : String = '');
    Destructor  Destroy; Override;
    Function    Matches(Const Title : String) : Boolean; Override;
    Procedure   Deactivate; Override;
    Procedure   Tick   (IntervalMS : Integer); Override;
    Procedure   Capture(s : TFlightSample); Override;
    Procedure   Apply  (s : TFlightSample; Const Data : TBytes; AgeMS : UInt64; Const Error : String);
  End;

  TAddonLVarProvider = Class(TAircraftProvider)
   Private
    fProfile : Integer;
    fReader  : TAircraftLVarReader;
    fMaxAge  : UInt64;
   Public
    Constructor Create (Profile : Integer; Const DLL : String = '');
    Destructor  Destroy; Override;
    Function    Matches(Const Title : String) : Boolean; Override;
    Procedure   Deactivate; Override;
    Procedure   Tick   (IntervalMS : Integer); Override;
    Procedure   Capture(s : TFlightSample); Override;
    Procedure   Apply  (s : TFlightSample; Const Values : TArray<Double>; Age : UInt64);
  End;

  TAircraftProviders = Class
   Private
    fItems     : TObjectList<TAircraftProvider>;
    fLastTitle : String;
    Procedure CheckAircraft(Const Title : String);
   Public
    Constructor Create          (Const FenixDLL : String = ''; Const FBWDLL : String = ''; Const PMDGDLL : String = '');
    Destructor  Destroy; Override;
    Procedure   RegisterProvider(p : TAircraftProvider);
    Procedure   Tick            (s : TFlightSample; Active : Boolean; IntervalMS : Integer);
    Procedure   Capture         (s : TFlightSample);
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
   t : String;
  Begin
   t      := UpperCase(Title).Replace('-', '').Replace(' ', '');
   Result := (Pos('IFLY', t) > 0) And ((Pos('737MAX8', t) > 0) Or (Pos('7378', t) > 0));
  End;

 Procedure TIFlyProvider.Capture(s : TFlightSample);
  Var
   v     : TReadings;
   Stamp : TCaptureTime;
  Begin
   If fReader.Read(v, Stamp) And ((v[1].ValueText = '1') Or (v[1].ValueText = '2')) Then
    Begin
     Apply(s, v);
     s.AircraftData.AddPair('capture_utc_us', TJSONNumber.Create(Stamp.UTCUS));
    End
   Else
    Begin
     s.AircraftData := TJSONObject.Create;
     s.AircraftData.AddPair('provider', 'iFly737MAX');
     s.AircraftData.AddPair('status', 'unavailable_simconnect_fallback');
    End;
  End;

 Procedure TIFlyProvider.Apply(s : TFlightSample; Const Values : TReadings);
  Var
   r      : TReading;
   Fields : TJSONObject;
   v      : Double;
   FS     : TFormatSettings;

   Function Digits(Const Prefix : String; Places : Integer; Out Number : Double) : Boolean;
    Var
     Place : Integer;
     Digit : TJSONValue;
     d     : Double;
    Begin
     Number := 0;
     Place  := Places;
     While Place > 0 Do
      Begin
       Digit := Fields.GetValue(Prefix + IntToStr(Place) + '_Status');
       If Not(Digit Is TJSONNumber) Then
        Exit(False);
       d := TJSONNumber(Digit).AsDouble;
       If (d < 0) Or (d > 9) Or (d <> Trunc(d)) Then
        Exit(False);
       Number := Number + d * Place;
       Place  := Place Div 10;
      End;
     Result := True;
    End;

  Begin
   FreeAndNil(s.DataSources);
   FreeAndNil(s.AircraftData);
   s.AircraftData := TJSONObject.Create;
   s.AircraftData.AddPair('provider', 'iFly737MAX');
   s.AircraftData.AddPair('status', 'available');
   s.AircraftData.AddPair('sdk_header_sha256', SDKHeaderSHA256);
   Fields := TJSONObject.Create;
   s.AircraftData.AddPair('fields', Fields);
   FS                  := TFormatSettings.Create;
   FS.DecimalSeparator := '.';
   For r In Values Do
    Begin
     If (r.Kind = 'char') Then
      Fields.AddPair(r.Name, r.ValueText)
     Else If TryStrToFloat(r.ValueText, v, FS) And Not IsNan(v) And Not IsInfinite(v) Then
      Begin
       Fields.AddPair(r.Name, TJSONNumber.Create(v));
       If r.Name = 'CabinAltitude' Then
        s.OverrideNumber('pressurization_cabin_altitude', v, 'iFlySDK:' + r.Name)
       Else If r.Name = 'Gear_Lever_Status' Then
        s.OverrideNumber('gear_handle_position', v, 'iFlySDK:' + r.Name)
       Else If r.Name = 'FLAP_Status' Then
        s.OverrideNumber('flaps_handle_index', v, 'iFlySDK:' + r.Name)
       Else If r.Name = 'Parking_Brake_Lever_Status' Then
        s.OverrideNumber('brake_parking_indicator', v, 'iFlySDK:' + r.Name)
       Else If r.Name = 'AT_Switch_Status' Then
        s.OverrideNumber('autopilot_throttle_arm', v, 'iFlySDK:' + r.Name)
       Else If r.Name = 'FD_1_Switch_Status' Then
        s.OverrideNumber('autopilot_flight_director_active', v, 'iFlySDK:' + r.Name)
       Else If r.Name = 'Throttle_Lever_1_Position' Then
        s.OverrideNumber('general_eng_throttle_lever_position[0]', v * 100, 'iFlySDK:' + r.Name)
       Else If r.Name = 'Throttle_Lever_2_Position' Then
        s.OverrideNumber('general_eng_throttle_lever_position[1]', v * 100, 'iFlySDK:' + r.Name);
      End
     Else
      Fields.AddPair(r.Name, TJSONNull.Create);
    End;
   If Digits('HDG_', 100, v) Then
    s.OverrideNumber('autopilot_heading_lock_dir', v, 'iFlySDK:HDG_digits');
   If Digits('ALT_', 10000, v) Then
    s.OverrideNumber('autopilot_altitude_lock_var', v, 'iFlySDK:ALT_digits');
   If Digits('SPD_', 100, v) And (Fields.GetValue('SPD_Point_Status') Is TJSONNumber) Then
    Begin
     If TJSONNumber(Fields.GetValue('SPD_Point_Status')).AsDouble = 0 Then
      s.OverrideNumber('autopilot_airspeed_hold_var', v, 'iFlySDK:SPD_digits'); // Mach decimal position is not defined by SDK 1.5: preserve SimConnect.
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

 Procedure TFenixProvider.Capture(s : TFlightSample);
  Var
   v   : TArray<Double>;
   Age : UInt64;
  Begin
   fReader.Tick;
   fReader.Snapshot(v, Age, fMaxAge);
   Apply(s, v, Age, fReader.LastError);
   If fLastStatus <> s.AircraftData.GetValue('status').Value Then
    Begin
     fLastStatus := s.AircraftData.GetValue('status').Value;
     Log(2, 'Fenix L-vars: ' + fLastStatus + ' ' + s.AircraftData.GetValue('received_field_count').Value + '/' + IntToStr(FenixFieldCount) + ' ' + fReader.LastError);
    End;
  End;

 Procedure TFenixProvider.Apply(s : TFlightSample; Const Values : TArray<Double>; AgeMS : UInt64; Const Error : String);
  Var
   Fields : TJSONObject;
   i      : Integer;
   Count  : Integer;
   v      : Double;
  Begin
   FreeAndNil(s.DataSources);
   FreeAndNil(s.AircraftData);
   s.AircraftData := TJSONObject.Create;
   s.AircraftData.AddPair('provider', 'FenixA32X');
   s.AircraftData.AddPair('source', 'SimConnect L-vars (read only)');
   s.AircraftData.AddPair('cockpit_xml_sha256', FenixCockpitSHA256);
   s.AircraftData.AddPair('catalog_sha256', FenixCatalogSHA256);
   s.AircraftData.AddPair('catalog_package_version', FenixPackageVersion);
   s.AircraftData.AddPair('capture_utc', DateToISO8601(TTimeZone.Local.ToUniversalTime(Now), True));
   s.AircraftData.AddPair('max_transport_age_ms', TJSONNumber.Create(AgeMS));
   s.AircraftData.AddPair('validity', 'Finite values from complete fresh SimConnect packets. No response/invalid/stale values are null. SimConnect does not confirm individual L-var existence; an absent L-var returning zero cannot be distinguished from a genuine zero.');
   Fields := TJSONObject.Create;
   s.AircraftData.AddPair('fields', Fields);
   Count := 0;
   For i := 0 To FenixFieldCount - 1 Do
    Begin
     v := NaN;
     If i < Length(Values) Then
      v := Values[i];
     If IsNan(v) Or IsInfinite(v) Then
      Fields.AddPair(FenixFields[i].Name, TJSONNull.Create)
     Else
      Begin
       Inc(Count);
       Fields.AddPair(FenixFields[i].Name, TJSONNumber.Create(v));
       If (FenixFields[i].Name = 'S_MIP_GEAR') And ((v = 0) Or (v = 1)) Then
        s.OverrideNumber('gear_handle_position', v, 'FenixLVar:S_MIP_GEAR')
       Else If (FenixFields[i].Name = 'S_FC_FLAPS') And (v >= 0) And (v <= 4) And (v = Trunc(v)) Then
        s.OverrideNumber('flaps_handle_index', v, 'FenixLVar:S_FC_FLAPS');
      End;
    End;
   s.AircraftData.AddPair('received_field_count', TJSONNumber.Create(Count));
   If Count = 0 Then
    s.AircraftData.AddPair('status', 'unavailable_simconnect_fallback')
   Else If Count < FenixFieldCount Then
    s.AircraftData.AddPair('status', 'partial')
   Else
    s.AircraftData.AddPair('status', 'available');
   If Error <> '' Then
    s.AircraftData.AddPair('transport_error', Error);
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

 Procedure TFBWProvider.Capture(s : TFlightSample);
  Var
   v   : TArray<Double>;
   Age : UInt64;
  Begin
   fReader.Tick;
   fReader.Snapshot(v, Age, fMaxAge);
   Apply(s, v, Age, fReader.LastError);
   If fLastStatus <> s.AircraftData.GetValue('status').Value Then
    Begin
     fLastStatus := s.AircraftData.GetValue('status').Value;
     Log(2, 'FBW A32NX L-vars: ' + fLastStatus + ' ' + s.AircraftData.GetValue('received_field_count').Value + '/' + IntToStr(FBWFieldCount) + ' ' + fReader.LastError);
    End;
  End;

 Procedure TFBWProvider.Apply(s : TFlightSample; Const Values : TArray<Double>; AgeMS : UInt64; Const Error : String);
  Var
   Fields      : TJSONObject;
   Performance : TJSONObject;
   i           : Integer;
   Count       : Integer;
   v           : Double;
   Mode        : Double;
   Ready       : Boolean;

   Function Number(Const Name : String; Out Value : Double) : Boolean;
    Var
     j : TJSONValue;
    Begin
     j      := Fields.GetValue(Name);
     Result := j Is TJSONNumber;
     If Result Then
      Value := TJSONNumber(j).AsDouble
     Else
      Value := NaN;
    End;

   Function Flag(Const Name : String; Expected : Double) : Boolean;
    Var
     n : Double;
    Begin
     Result := Number(Name, n) And (n = Expected);
    End;

  Begin
   FreeAndNil(s.DataSources);
   FreeAndNil(s.AircraftData);
   s.AircraftData := TJSONObject.Create;
   s.AircraftData.AddPair('provider', 'FBWA32NX');
   s.AircraftData.AddPair('source', 'SimConnect L-vars (read only)');
   s.AircraftData.AddPair('api_html_sha256', FBWSourceSHA256);
   s.AircraftData.AddPair('capture_utc', DateToISO8601(TTimeZone.Local.ToUniversalTime(Now), True));
   s.AircraftData.AddPair('max_transport_age_ms', TJSONNumber.Create(AgeMS));
   s.AircraftData.AddPair('validity', 'Raw documented readable L-vars; null=no fresh valid reply. SimConnect cannot distinguish an absent L-var returning zero from a real zero. API version may differ from installed aircraft.');
   Fields := TJSONObject.Create;
   s.AircraftData.AddPair('fields', Fields);
   Count := 0;
   For i := 0 To FBWFieldCount - 1 Do
    Begin
     v := NaN;
     If i < Length(Values) Then
      v := Values[i];
     If IsNan(v) Or IsInfinite(v) Then
      Fields.AddPair(FBWFields[i].Name, TJSONNull.Create)
     Else
      Begin
       Inc(Count);
       Fields.AddPair(FBWFields[i].Name, TJSONNumber.Create(v));
      End;
    End;
   Ready := Flag('A32NX_IS_READY', 1);
   s.AircraftData.AddPair('aircraft_ready', TJSONBool.Create(Ready));
   Performance := TJSONObject.Create;
   s.AircraftData.AddPair('performance_reference', Performance);
   If Ready And Number('A32NX_SPEEDS_VAPP', v) And (v > 0) And (v < 400) Then
    Performance.AddPair('vapp_kt', TJSONNumber.Create(v))
   Else
    Performance.AddPair('vapp_kt', TJSONNull.Create);
   If Ready Then
    Begin
     If Number('A32NX_FLAPS_HANDLE_INDEX', v) And (v >= 0) And (v <= 4) And (v = Trunc(v)) Then
      Begin
       If v > 0 Then
        v := v + 1;
       s.OverrideNumber('flaps_handle_index', v, 'FBWLVar:A32NX_FLAPS_HANDLE_INDEX (native 0..4 to MSFS 0/2..5)');
      End;
     If Number('A32NX_AUTOTHRUST_STATUS', v) And (v >= 0) And (v <= 2) And (v = Trunc(v)) Then
      Begin
       s.OverrideNumber('autopilot_throttle_arm', Ord(v > 0), 'FBWLVar:A32NX_AUTOTHRUST_STATUS');
       s.OverrideNumber('autothrottle_active', Ord(v = 2), 'FBWLVar:A32NX_AUTOTHRUST_STATUS');
      End;
     If Flag('A32NX_FCU_AFS_DISPLAY_SPD_MACH_DASHES', 0) And Number('A32NX_FCU_AFS_DISPLAY_SPD_MACH_VALUE', v) And Number('A32NX_FCU_AFS_DISPLAY_MACH_MODE', Mode) Then
      Begin
       If (Mode = 0) And (v > 0) And (v < 400) Then
        s.OverrideNumber('autopilot_airspeed_hold_var', v, 'FBWLVar:FCU SPD display')
       Else If (Mode = 1) And (v > 0) And (v < 1) Then
        s.OverrideNumber('autopilot_mach_hold_var', v, 'FBWLVar:FCU Mach display');
      End;
    End;
   s.AircraftData.AddPair('received_field_count', TJSONNumber.Create(Count));
   If Count = 0 Then
    s.AircraftData.AddPair('status', 'unavailable_simconnect_fallback')
   Else If Not Ready Then
    s.AircraftData.AddPair('status', 'initializing')
   Else If Count < FBWFieldCount Then
    s.AircraftData.AddPair('status', 'partial')
   Else
    s.AircraftData.AddPair('status', 'available');
   If Error <> '' Then
    s.AircraftData.AddPair('transport_error', Error);
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

 Procedure TPMDGNG3Provider.Capture(s : TFlightSample);
  Var
   Data : TBytes;
   Age  : UInt64;
   CDUs : TJSONObject;
   CDU  : TJSONObject;
   i    : Integer;
  Begin
   fReader.Tick;
   fReader.Snapshot(0, Data, Age);
   Apply(s, Data, Age, fReader.LastError);
   CDUs := TJSONObject.Create;
   s.AircraftData.AddPair('cdu', CDUs);
   For i := 0 To 1 Do
    Begin
     fReader.Snapshot(i + 1, Data, Age);
     CDU := DecodePMDGCDU(Data);
     CDU.AddPair('last_update_age_ms', TJSONNumber.Create(Age));
     CDUs.AddPair(IntToStr(i), CDU);
    End;
   If fLastStatus <> s.AircraftData.GetValue('status').Value Then
    Begin
     fLastStatus := s.AircraftData.GetValue('status').Value;
     Log(2, 'PMDG NG3 SDK: ' + fLastStatus + ' ' + fReader.LastError);
    End;
  End;

 Procedure TPMDGNG3Provider.Apply(s : TFlightSample; Const Data : TBytes; AgeMS : UInt64; Const Error : String);
  Var
   Fields      : TJSONObject;
   Performance : TJSONObject;
   i           : Integer;
   Count       : Integer;
   Ready       : Boolean;
   Powered     : Boolean;
   v           : Double;
   a           : Double;
   b           : Double;
   c           : Double;

   Function Number(Const Name : String; Out Value : Double) : Boolean;
    Var
     j : TJSONValue;
    Begin
     j      := Fields.GetValue(Name);
     Result := j Is TJSONNumber;
     If Result Then
      Value := TJSONNumber(j).AsDouble
     Else
      Value := NaN;
    End;

   Function Flag(Const Name : String) : Boolean;
    Var
     n : Double;
    Begin
     Result := Number(Name, n) And (n = 1);
    End;

   Procedure Reference(Const RawName, Alias : String; Minimum : Double);
    Var
     n : Double;
    Begin
     If Ready And Number(RawName, n) And (n >= Minimum) Then
      Performance.AddPair(Alias, TJSONNumber.Create(n))
     Else
      Performance.AddPair(Alias, TJSONNull.Create);
    End;

  Begin
   FreeAndNil(s.DataSources);
   FreeAndNil(s.AircraftData);
   s.AircraftData := TJSONObject.Create;
   s.AircraftData.AddPair('provider', 'PMDGNG3');
   s.AircraftData.AddPair('source', 'PMDG NG3 SDK / SimConnect Client Data (read only)');
   s.AircraftData.AddPair('sdk_header_sha256', PMDGHeaderSHA256);
   s.AircraftData.AddPair('capture_utc', DateToISO8601(TTimeZone.Local.ToUniversalTime(Now), True));
   s.AircraftData.AddPair('data_update_age_ms', TJSONNumber.Create(AgeMS));
   s.AircraftData.AddPair('cache_semantics', 'SDK updates use ON_SET; unchanged values are carried forward until the next broadcast. No artificial expiry without an SDK heartbeat. Age is wall-clock time since the last packet. Aircraft/pause/disconnect resets invalidate the cache.');
   Fields := DecodePMDGData(Data);
   s.AircraftData.AddPair('fields', Fields);
   Count := 0;
   For i := 0 To Fields.Count - 1 Do
    If Not(Fields.Pairs[i].JsonValue Is TJSONNull) Then
     Inc(Count);
   Ready := (Length(Data) >= PMDGDataSize) And Number('AircraftModel', v) And (v >= 1) And (v <= 22);
   s.AircraftData.AddPair('sdk_model_valid', TJSONBool.Create(Ready));
   Performance := TJSONObject.Create;
   s.AircraftData.AddPair('performance_reference', Performance);
   Reference('FMC_V1', 'v1_kt', 1);
   Reference('FMC_VR', 'vr_kt', 1);
   Reference('FMC_V2', 'v2_kt', 1);
   Reference('FMC_LandingVREF', 'vref_kt', 1);
   Reference('FMC_TakeoffFlaps', 'takeoff_flaps_deg', 1);
   Reference('FMC_LandingFlaps', 'landing_flaps_deg', 1);
   Reference('FMC_CruiseAlt', 'cruise_altitude_ft', 1);
   Reference('FMC_DistanceToTOD', 'distance_to_tod_nm', 0);
   Reference('FMC_DistanceToDest', 'distance_to_destination_nm', 0);
   If Ready And Number('FMC_LandingAltitude', v) And (v <> -32767) Then
    Performance.AddPair('landing_altitude_ft', TJSONNumber.Create(v))
   Else
    Performance.AddPair('landing_altitude_ft', TJSONNull.Create);
   If Ready Then
    Begin
     If Number('FMC_PerfInputComplete', v) Then
      Performance.AddPair('perf_input_complete', TJSONBool.Create(v = 1))
     Else
      Performance.AddPair('perf_input_complete', TJSONNull.Create);
     If Number('AFS_AutothrottleServosConnected', v) Then
      s.OverrideNumber('autothrottle_active', v, 'PMDGNG3:AFS_AutothrottleServosConnected');
     If Number('AFS_ControlsPitch', a) And Number('AFS_ControlsRoll', b) Then
      s.OverrideNumber('autopilot_master', Ord((a = 1) Or (b = 1)), 'PMDGNG3:AFS_ControlsPitch/Roll (active control incl. CWS)');
     If Number('MCP_ATArmSw', v) Then
      s.OverrideNumber('autopilot_throttle_arm', v, 'PMDGNG3:MCP_ATArmSw');
     If Number('MCP_FDSw[0]', v) Then
      s.OverrideNumber('autopilot_flight_director_active', v, 'PMDGNG3:MCP_FDSw[0]');
     If Number('AIR_CabinAltNeedle', v) Then
      s.OverrideNumber('pressurization_cabin_altitude', v, 'PMDGNG3:AIR_CabinAltNeedle');
     If Number('MAIN_GearLever', v) And ((v = 0) Or (v = 2)) Then
      s.OverrideNumber('gear_handle_position', v / 2, 'PMDGNG3:MAIN_GearLever (OFF retains SimConnect)');
     If Number('FUEL_QtyCenter', a) And Number('FUEL_QtyLeft', b) And Number('FUEL_QtyRight', c) And (a >= 0) And (b >= 0) And (c >= 0) Then
      s.OverrideNumber('fuel_total_quantity_weight', a + b + c, 'PMDGNG3:FUEL_QtyCenter/Left/Right (lb)');
     Powered := Flag('MCP_indication_powered');
     If Powered Then
      Begin
       If Number('MCP_Heading', v) And (v <= 360) Then
        s.OverrideNumber('autopilot_heading_lock_dir', v, 'PMDGNG3:MCP_Heading');
       If Number('MCP_Altitude', v) Then
        s.OverrideNumber('autopilot_altitude_lock_var', v, 'PMDGNG3:MCP_Altitude');
       If Number('MCP_VertSpeedBlank', b) And (b = 0) And Number('MCP_VertSpeed', v) Then
        s.OverrideNumber('autopilot_vertical_hold_var', v, 'PMDGNG3:MCP_VertSpeed');
       If Number('MCP_IASBlank', b) And (b = 0) And Number('MCP_IASMach', v) Then
        Begin
         If (v > 0) And (v < 1) Then
          s.OverrideNumber('autopilot_mach_hold_var', v, 'PMDGNG3:MCP_IASMach')
         Else If (v >= 10) And (v < 500) Then
          s.OverrideNumber('autopilot_airspeed_hold_var', v, 'PMDGNG3:MCP_IASMach');
        End;
      End;
    End;
   s.AircraftData.AddPair('received_field_count', TJSONNumber.Create(Count));
   If Length(Data) < PMDGDataSize Then
    s.AircraftData.AddPair('status', 'unavailable_simconnect_fallback')
   Else If Not Ready Then
    s.AircraftData.AddPair('status', 'initializing')
   Else If Count < PMDGFieldCount Then
    s.AircraftData.AddPair('status', 'partial')
   Else
    s.AircraftData.AddPair('status', 'available');
   If Error <> '' Then
    s.AircraftData.AddPair('transport_error', Error);
  End;

 Constructor TPMDG777Provider.Create(Const DLL : String);
  Begin
   Inherited Create;
   fReader := TPMDG777Reader.Create(DLL);
  End;

 Destructor TPMDG777Provider.Destroy;
  Begin
   fReader.Free;
   Inherited;
  End;

 Function TPMDG777Provider.Matches(Const Title : String) : Boolean;
  Begin
   Result := IsPMDG777Aircraft(Title);
  End;

 Procedure TPMDG777Provider.Deactivate;
  Begin
   fReader.Close;
   fLastStatus := '';
  End;

 Procedure TPMDG777Provider.Tick(IntervalMS : Integer);
  Begin
   fReader.Tick;
  End;

 Procedure TPMDG777Provider.Capture(s : TFlightSample);
  Var
   Data   : TBytes;
   Age    : UInt64;
   CDUs   : TJSONObject;
   CDU    : TJSONObject;
   i      : Integer;
   Lamp   : Integer;
   Lights : TJSONObject;
   Fields : TJSONValue;
   Value  : TJSONValue;
   Names  : TArray<String>;
  Begin
   fReader.Tick;
   fReader.Snapshot(0, Data, Age);
   Apply(s, Data, Age, fReader.LastError);
   CDUs := TJSONObject.Create;
   s.AircraftData.AddPair('cdu', CDUs);
   For i := 0 To 2 Do
    Begin
     fReader.Snapshot(i + 1, Data, Age);
     CDU      := DecodePMDG777CDU(Data);
     Lights   := TJSONObject.Create;
     Names    := TArray<String>.Create('EXEC', 'DSPY', 'FAIL', 'MSG', 'OFST');
     Fields   := s.AircraftData.GetValue('fields');
     For Lamp := 0 To High(Names) Do
      Begin
       Value := Nil;
       If Fields Is TJSONObject Then
        Value := TJSONObject(Fields).GetValue(Format('CDU_annun%s[%d]', [Names[Lamp], i]));
       If Value <> Nil Then
        Lights.AddPair(Names[Lamp], TJSONObject.ParseJSONValue(Value.ToJSON))
       Else
        Lights.AddPair(Names[Lamp], TJSONNull.Create);
      End;
     CDU.AddPair('annunciators_json', Lights.ToJSON);
     Lights.Free;
     CDUs.AddPair(IntToStr(i), CDU);
    End;
   If fLastStatus <> s.AircraftData.GetValue('status').Value Then
    Begin
     fLastStatus := s.AircraftData.GetValue('status').Value;
     Log(2, 'PMDG 777 SDK: ' + fLastStatus + ' ' + fReader.LastError);
    End;
  End;

 Procedure TPMDG777Provider.Apply(s : TFlightSample; Const Data : TBytes; AgeMS : UInt64; Const Error : String);
  Var
   Fields      : TJSONObject;
   Performance : TJSONObject;
   i           : Integer;
   Count       : Integer;
   Ready       : Boolean;
   Powered     : Boolean;
   v           : Double;
   a           : Double;
   b           : Double;
   c           : Double;

   Function Number(Const Name : String; Out Value : Double) : Boolean;
    Var
     j : TJSONValue;
    Begin
     j      := Fields.GetValue(Name);
     Result := j Is TJSONNumber;
     If Result Then
      Value := TJSONNumber(j).AsDouble
     Else
      Value := NaN;
    End;

   Function Flag(Const Name : String) : Boolean;
    Var
     n : Double;
    Begin
     Result := Number(Name, n) And (n = 1);
    End;

   Procedure Reference(Const RawName, Alias : String; Minimum : Double);
    Var
     n : Double;
    Begin
     If Ready And Number(RawName, n) And (n >= Minimum) Then
      Performance.AddPair(Alias, TJSONNumber.Create(n))
     Else
      Performance.AddPair(Alias, TJSONNull.Create);
    End;

  Begin
   FreeAndNil(s.DataSources);
   FreeAndNil(s.AircraftData);
   s.AircraftData := TJSONObject.Create;
   s.AircraftData.AddPair('provider', 'PMDG777');
   s.AircraftData.AddPair('source', 'PMDG 777 SDK / SimConnect Client Data (read only)');
   s.AircraftData.AddPair('sdk_header_sha256', PMDG777HeaderSHA256);
   s.AircraftData.AddPair('cache_semantics', 'SDK updates use ON_SET; unchanged values are carried forward until the next broadcast. No artificial expiry without an SDK heartbeat. Age is wall-clock time since the last packet. Aircraft/pause/disconnect resets invalidate the cache.');
   Fields := DecodePMDG777Data(Data);
   s.AircraftData.AddPair('fields', Fields);
   Count := 0;
   For i := 0 To Fields.Count - 1 Do
    If Not(Fields.Pairs[i].JsonValue Is TJSONNull) Then
     Inc(Count);
   Ready := (Length(Data) >= PMDG777DataSize) And Number('AircraftModel', v) And (v >= 1) And (v <= 6);
   s.AircraftData.AddPair('sdk_model_valid', TJSONBool.Create(Ready));
   Performance := TJSONObject.Create;
   s.AircraftData.AddPair('performance_reference', Performance);
   Reference('FMC_V1', 'v1_kt', 1);
   Reference('FMC_VR', 'vr_kt', 1);
   Reference('FMC_V2', 'v2_kt', 1);
   Reference('FMC_LandingVREF', 'vref_kt', 1);
   Reference('FMC_TakeoffFlaps', 'takeoff_flaps_deg', 1);
   Reference('FMC_LandingFlaps', 'landing_flaps_deg', 1);
   Reference('FMC_AccelerationAlt', 'acceleration_altitude_ft', 1);
   Reference('FMC_EOAccelerationAlt', 'engine_out_acceleration_altitude_ft', 1);
   Reference('FMC_TransitionAlt', 'transition_altitude_ft', 1);
   Reference('FMC_TransitionLevel', 'transition_level_ft', 1);
   Reference('FMC_ThrustLimitMode', 'thrust_limit_mode', 0);
   Reference('FMC_CruiseAlt', 'cruise_altitude_ft', 1);
   Reference('FMC_DistanceToTOD', 'distance_to_tod_nm', 0);
   Reference('FMC_DistanceToDest', 'distance_to_destination_nm', 0);
   If Ready And Number('FMC_LandingAltitude', v) And (v <> -32767) Then
    Performance.AddPair('landing_altitude_ft', TJSONNumber.Create(v))
   Else
    Performance.AddPair('landing_altitude_ft', TJSONNull.Create);
   If Ready Then
    Begin
     If Number('FMC_PerfInputComplete', v) Then
      Performance.AddPair('perf_input_complete', TJSONBool.Create(v = 1))
     Else
      Performance.AddPair('perf_input_complete', TJSONNull.Create);
     If Number('MCP_annunAP[0]', a) And Number('MCP_annunAP[1]', b) Then
      s.OverrideNumber('autopilot_master', Ord((a = 1) Or (b = 1)), 'PMDG777:MCP_annunAP');
     If Number('MCP_ATArm_Sw_On[0]', a) And Number('MCP_ATArm_Sw_On[1]', b) Then
      s.OverrideNumber('autopilot_throttle_arm', Ord((a = 1) Or (b = 1)), 'PMDG777:MCP_ATArm_Sw_On');
     If Number('MCP_FD_Sw_On[0]', v) Then
      s.OverrideNumber('autopilot_flight_director_active', v, 'PMDG777:MCP_FD_Sw_On[0]');
     If Number('GEAR_Lever', v) And ((v = 0) Or (v = 1)) Then
      s.OverrideNumber('gear_handle_position', v, 'PMDG777:GEAR_Lever');
     If Number('FUEL_QtyCenter', a) And Number('FUEL_QtyLeft', b) And Number('FUEL_QtyRight', c) And Number('FUEL_QtyAux', v) And (a >= 0) And (b >= 0) And (c >= 0) And (v >= 0) Then
      s.OverrideNumber('fuel_total_quantity_weight', a + b + c + v, 'PMDG777:FUEL_QtyCenter/Left/Right/Aux (lb)');
     If Number('MCP_HDGDial_Mode', b) And (b = 0) And Number('MCP_Heading', v) And (v <= 360) Then
      s.OverrideNumber('autopilot_heading_lock_dir', v, 'PMDG777:MCP_Heading (HDG mode)');
     If Number('MCP_Altitude', v) Then
      s.OverrideNumber('autopilot_altitude_lock_var', v, 'PMDG777:MCP_Altitude');
     If Number('MCP_VSDial_Mode', a) And (a = 0) And Number('MCP_VertSpeedBlank', b) And (b = 0) And Number('MCP_VertSpeed', v) Then
      s.OverrideNumber('autopilot_vertical_hold_var', v, 'PMDG777:MCP_VertSpeed (VS mode)');
     If Number('MCP_IASBlank', b) And (b = 0) And Number('MCP_IASMach', v) Then
      Begin
       If (v > 0) And (v < 1) Then
        s.OverrideNumber('autopilot_mach_hold_var', v, 'PMDG777:MCP_IASMach')
       Else If (v >= 10) And (v < 500) Then
        s.OverrideNumber('autopilot_airspeed_hold_var', v, 'PMDG777:MCP_IASMach');
      End;
    End;
   s.AircraftData.AddPair('received_field_count', TJSONNumber.Create(Count));
   If Length(Data) < PMDG777DataSize Then
    s.AircraftData.AddPair('status', 'unavailable_simconnect_fallback')
   Else If Not Ready Then
    s.AircraftData.AddPair('status', 'initializing')
   Else If Count < PMDG777FieldCount Then
    s.AircraftData.AddPair('status', 'partial')
   Else
    s.AircraftData.AddPair('status', 'available');
   If Error <> '' Then
    s.AircraftData.AddPair('transport_error', Error);
  End;

 Constructor TAddonLVarProvider.Create(Profile : Integer; Const DLL : String);
  Var
   Names : TArray<String>;
   Units : TArray<String>;
   i     : Integer;
  Begin
   Inherited Create;
   fProfile := Profile;
   fMaxAge  := 5000;
   SetLength(Names, AddonProfiles[Profile].Count);
   SetLength(Units, Length(Names));
   For i := 0 To High(Names) Do
    Begin
     Names[i] := AddonFields[AddonProfiles[Profile].First + i].Name;
     Units[i] := AddonFields[AddonProfiles[Profile].First + i].SourceUnits;
    End;
   // Single-field batches isolate an unsupported variable from every other field.
   fReader := TAircraftLVarReader.Create(Names, 'MSFS FDR ' + AddonProfiles[Profile].Title + ' (read only)', DLL, 1, True, Units);
  End;

 Destructor TAddonLVarProvider.Destroy;
  Begin
   fReader.Free;
   Inherited;
  End;

 Function TAddonLVarProvider.Matches(Const Title : String) : Boolean;
  Begin
   Result := MatchesAddon(fProfile, Title);
  End;

 Procedure TAddonLVarProvider.Deactivate;
  Begin
   fReader.Close;
  End;

 Procedure TAddonLVarProvider.Tick(IntervalMS : Integer);
  Begin
   fMaxAge                := Max(5000, UInt64(IntervalMS) * 4);
   fReader.PollIntervalMS := Max(20, IntervalMS Div 2);
   fReader.Tick;
  End;

 Procedure TAddonLVarProvider.Capture(s : TFlightSample);
  Var
   Values : TArray<Double>;
   Age    : UInt64;
  Begin
   fReader.Tick;
   fReader.Snapshot(Values, Age, fMaxAge);
   Apply(s, Values, Age);
  End;

 Procedure TAddonLVarProvider.Apply(s : TFlightSample; Const Values : TArray<Double>; Age : UInt64);
  Var
   Fields : TJSONObject;
   i      : Integer;
   Count  : Integer;
   v      : Double;
  Begin
   FreeAndNil(s.DataSources);
   FreeAndNil(s.AircraftData);
   s.AircraftData := TJSONObject.Create;
   s.AircraftData.AddPair('provider', AddonProfiles[fProfile].Provider);
   If fProfile >= 6 Then
    s.AircraftData.AddPair('source', 'Installed locpak cross-locale literal numeric bindings / SimConnect (read only)')
   Else
    s.AircraftData.AddPair('source', 'Installed model XML literal L-vars / SimConnect (read only)');
   s.AircraftData.AddPair('semantics', 'Raw model-specific numbers. Missing L-vars may return zero; zero is not proof of support. Do not infer physical units or override standard SimVars without verified mappings.');
   Fields := TJSONObject.Create;
   s.AircraftData.AddPair('fields', Fields);
   Count := 0;
   For i := 0 To AddonProfiles[fProfile].Count - 1 Do
    Begin
     v := NaN;
     If i < Length(Values) Then
      v := Values[i];
     If IsNan(v) Or IsInfinite(v) Then
      Fields.AddPair(AddonFields[AddonProfiles[fProfile].First + i].Name, TJSONNull.Create)
     Else
      Begin
       Fields.AddPair(AddonFields[AddonProfiles[fProfile].First + i].Name, TJSONNumber.Create(v));
       Inc(Count);
      End;
    End;
   s.AircraftData.AddPair('received_field_count', TJSONNumber.Create(Count));
   If Count = 0 Then
    s.AircraftData.AddPair('status', 'unavailable_simconnect_fallback')
   Else If Count < AddonProfiles[fProfile].Count Then
    s.AircraftData.AddPair('status', 'partial')
   Else
    s.AircraftData.AddPair('status', 'received_unverified_lvars');
   If fReader.LastError <> '' Then
    s.AircraftData.AddPair('transport_error', fReader.LastError);
  End;

 Constructor TAircraftProviders.Create(Const FenixDLL, FBWDLL, PMDGDLL : String);
  Var
   i : Integer;
  Begin
   Inherited Create;
   fItems := TObjectList<TAircraftProvider>.Create(True);
   RegisterProvider(TIFlyProvider.Create);
   RegisterProvider(TFenixProvider.Create(FenixDLL));
   RegisterProvider(TFBWProvider.Create(FBWDLL));
   RegisterProvider(TPMDGNG3Provider.Create(PMDGDLL));
   RegisterProvider(TPMDG777Provider.Create(PMDGDLL));
   For i := 0 To AddonProfileCount - 1 Do
    RegisterProvider(TAddonLVarProvider.Create(i, PMDGDLL));
  End;

 Destructor TAircraftProviders.Destroy;
  Begin
   fItems.Free;
   Inherited;
  End;

 Procedure TAircraftProviders.RegisterProvider(p : TAircraftProvider);
  Begin
   fItems.Add(p);
  End;

 Procedure TAircraftProviders.CheckAircraft(Const Title : String);
  Var
   p : TAircraftProvider;
  Begin
   If fLastTitle = Title Then
    Exit;
   For p In fItems Do
    p.Deactivate;
   fLastTitle := Title;
  End;

 Procedure TAircraftProviders.Tick(s : TFlightSample; Active : Boolean; IntervalMS : Integer);
  Var
   p : TAircraftProvider;
  Begin
   CheckAircraft(s.S('title'));
   For p In fItems Do
    If Active And p.Matches(s.S('title')) Then
     p.Tick(IntervalMS)
    Else
     p.Deactivate;
  End;

 Procedure TAircraftProviders.Capture(s : TFlightSample);
  Var
   p : TAircraftProvider;
  Begin
   CheckAircraft(s.S('title'));
   FreeAndNil(s.AircraftData);
   FreeAndNil(s.DataSources);
   For p In fItems Do
    If Not p.Matches(s.S('title')) Then
     p.Deactivate;
   For p In fItems Do
    If p.Matches(s.S('title')) Then
     Begin
      p.Capture(s);
      AttachFlightPadScreen(s.AircraftData);
      Exit;
     End;
  End;

End.
