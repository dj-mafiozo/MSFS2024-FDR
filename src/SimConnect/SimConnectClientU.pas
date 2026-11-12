{$StackFrames On}
Unit SimConnectClientU;

Interface

 Uses
  Winapi.Windows, System.SysUtils, System.Generics.Collections,
  LocalizationU, AppLogU, TelemetryCatalogU, FlightTelemetryU, AirlinerVarsU, GSXVarsU, SimVarSelectionU, System.Math;

 Type
   ESimConnectUnavailable = Class(Exception);

   TSampleEvent = Procedure(Sender : TObject; Sample : TFlightSample) Of Object;

   TPacketEvent = Procedure(p : Pointer; Size : DWORD) Of Object;

   TCockpitEvent = Procedure(Sender : TObject; Const Name : String) Of Object;

   TSimConnectClient = Class
    Private
     fBasicRequest     : DWORD;
     fFullRequest      : DWORD;
     fGeneration       : DWORD;
     fFullFields       : TArray<Integer>;
     fBasicFields      : TArray<Integer>;
     fFullSize         : Integer;
     fIdentityTitle    : String;
     fIdentityType     : Integer;
     fIdentityEngines  : Integer;
     fIdentityFresh    : Boolean;
     fSessionReady     : Boolean;
     fFlightStarted    : Boolean;
     fEndObserved      : Boolean;
     fDLL              : String;
     fClear            : Function(h : THandle; ID : DWORD) : HRESULT; Stdcall;
     fGetNext          : Function(h : THandle; Var p : Pointer; Var Size : DWORD) : HRESULT; Stdcall;
     fDeferSamples     : Boolean;
     fGroundKnown      : Boolean;
     fLastGround       : Boolean;
     fGroundOffset     : Integer;
     fPending          : TBytes;
     fEdges            : TList<TBytes>;
     fReceivedCount    : Int64;
     fDeliveredCount   : Int64;
     fTelemetryLogNext : UInt64;
     fAirliner         : TAirlinerVars;
     fGSX              : TGSXVars;
     fAirlinerTitle    : String;
     fPackets          : TDictionary<DWORD, String>;
     fFlow             : Function(h : THandle) : HRESULT; Stdcall;
     fState            : Function(h : THandle; ID : DWORD; Name : PAnsiChar) : HRESULT; Stdcall;
     fPlanRefresh      : Boolean;
     fPlanNext         : UInt64;
     fLastPacket       : Function(h : THandle; Var ID : DWORD) : HRESULT; Stdcall;
     fLib              : HMODULE;
     fHandle           : THandle;
     fOpen             : Function(Var h : THandle; n : PAnsiChar; w : HWND; e : DWORD; EH : THandle; c : DWORD) : HRESULT; Stdcall;
     fClose            : Function(h : THandle) : HRESULT; Stdcall;
     fAdd              : Function(h : THandle; ID : DWORD; n, u : PAnsiChar; t : DWORD; e : Single; d : DWORD) : HRESULT; Stdcall;
     fRequest          : Function(h : THandle; r, d, o, p, f, a, i, l : DWORD) : HRESULT; Stdcall;
     fDispatch         : Function(h : THandle; CB, Context : Pointer) : HRESULT; Stdcall;
     fSubscribe        : Function(h : THandle; ID : DWORD; n : PAnsiChar) : HRESULT; Stdcall;
     fMap              : Function(h : THandle; ID : DWORD; n : PAnsiChar) : HRESULT; Stdcall;
     fGroup            : Function(h : THandle; g, ID : DWORD; Mask : BOOL) : HRESULT; Stdcall;
     fPriority         : Function(h : THandle; g, p : DWORD) : HRESULT; Stdcall;
     Procedure InitializeSession;
     Procedure ReadSimulatorVersion(p : Pointer; Size : DWORD);
     Procedure RefreshIdentity;
     Procedure StopTelemetry;
     Procedure ConfigureTelemetry;
     Procedure Bootstrap           (p : Pointer; Size : DWORD);
     Function  MatchesIdentity     (Const Data : TBytes) : Boolean;
     Procedure QueueTelemetry      (p : Pointer);
     Procedure DeliverTelemetry    (Const Data : TBytes);
     Procedure FlushTelemetry;
     Procedure Track               (Const Context : String);
     Procedure Check               (HR : HRESULT);
     Procedure Receive             (p : Pointer; Size : DWORD);
    Public
     SimulatorSupported   : Boolean;
     SimulatorVersion     : String;
     UnsupportedSimulator : String;
     AircraftPath         : String;
     TelemetryActive      : Boolean;
     Sample               : TFlightSample;
     Connected            : Boolean;
     Running              : Boolean;
     Paused               : Boolean;
     Quit                 : Boolean;
     Opened               : Boolean;
     Error                : String;
     FlightPlanPath       : String;
     FlightEnded          : Boolean;
     FlightLoading        : Boolean;
     fLoadedFlight        : String;
     OnSample             : TSampleEvent;
     OnCockpit            : TCockpitEvent;
     OnPacket             : TPacketEvent;
     Procedure ApplyFlow     (Event : DWORD; Const Path : String);
     Procedure TrackAuxiliary(Const Context : String);
     Property FlightStarted : Boolean Read fFlightStarted;
     Property Handle        : THandle Read fHandle;
     Function    FunctionAddress(Const Name : AnsiString) : Pointer;
     Constructor Create;
     Destructor  Destroy; Override;
     Procedure   Connect        (Const DLL : String);
     Procedure   Disconnect;
     Procedure   Poll;
     {$IFDEF PORT_TEST}
     Procedure Feed     (p : Pointer; Size : DWORD);
     Procedure FeedBatch(Const Packets : TArray<TBytes>);
     {$ENDIF}
   End;

 Implementation

  Procedure SimCallback(p : Pointer; Size : DWORD; Context : Pointer); Stdcall;
   Begin
    Try
     TSimConnectClient(Context).Receive(p, Size);
    Except
     On e : Exception Do
      Begin
       TSimConnectClient(Context).Error := e.ClassName + ': ' + e.Message;
       Log(0, 'SimConnect callback: ' + TSimConnectClient(Context).Error);
      End;
    End;
  End;

 Constructor TSimConnectClient.Create;
  Var
   i : Integer;
  Begin
   Inherited;
   fPackets := TDictionary<DWORD, String>.Create;
   Sample   := TFlightSample.Create;
   fEdges   := TList<TBytes>.Create;
   For i    := 0 To FieldCount - 1 Do
    If SimFields[i].Name = 'sim_on_ground' Then
     fGroundOffset := SimFields[i].Offset;
  End;

 Destructor TSimConnectClient.Destroy;
  Begin
   Disconnect;
   Sample.Free;
   fEdges.Free;
   fPackets.Free;
   Inherited;
  End;

 Procedure TSimConnectClient.Track(Const Context : String);
  Var
   ID : DWORD;
  Begin
   If Assigned(fLastPacket) And (fLastPacket(fHandle, ID) >= 0) Then
    Begin
     If fPackets.Count >= 32768 Then
      fPackets.Clear;
     fPackets.AddOrSetValue(ID, Context);
    End;
  End;

 Procedure TSimConnectClient.TrackAuxiliary(Const Context : String);
  Begin
   Track(Context);
  End;

 Procedure TSimConnectClient.Check(HR : HRESULT);
  Begin
   If HR < 0 Then
    Raise Exception.CreateFmt(Tr('SimConnect HRESULT %s'), [IntToHex(Cardinal(HR), 8)]);
  End;

 Function TSimConnectClient.FunctionAddress(Const Name : AnsiString) : Pointer;
  Begin
   Result := GetProcAddress(fLib, PAnsiChar(Name));
  End;

 Procedure TSimConnectClient.RefreshIdentity;
  Begin
   fIdentityFresh := False;
   If (fHandle = 0) Or Not Assigned(fRequest) Then
    Exit;
   fRequest(fHandle, fBasicRequest, 10, 0, 0, 0, 0, 0, 0);
   Inc(fBasicRequest);
   If fBasicRequest >= 900 Then
    fBasicRequest := 10;
   Check(fRequest(fHandle, fBasicRequest, 10, 0, 4, 0, 0, 0, 0));
  End;

 Procedure TSimConnectClient.StopTelemetry;
  Begin
   If (fHandle <> 0) And TelemetryActive Then
    Begin
     fRequest(fHandle, fFullRequest, fFullRequest, 0, 0, 0, 0, 0, 0);
     If Assigned(fClear) Then
      fClear(fHandle, fFullRequest);
    End;
   TelemetryActive := False;
   fIdentityFresh  := False;
   fFullFields     := Nil;
   fFullSize       := 0;
   fPending        := Nil;
   fEdges.Clear;
   fGroundKnown := False;
   FreeAndNil(fAirliner);
   FreeAndNil(fGSX);
   FreeAndNil(Sample.AirlinerData);
   FreeAndNil(Sample.GSXData);
  End;

 Procedure TSimConnectClient.ConfigureTelemetry;
  Var
   i : Integer;
   n : AnsiString;
   u : AnsiString;
  Begin
   If TelemetryActive Or (fHandle = 0) Or Not Connected Or Not SimulatorSupported Or Not Running Or FlightEnded Or FlightLoading Or Not fSessionReady Or Not fIdentityFresh Or (fIdentityTitle = '') Then
    Exit;
   Inc(fGeneration);
   fFullRequest := fGeneration;
   fFullSize    := 0;
   fFullFields  := Nil;
   Try
    For i := 0 To FieldCount - 1 Do
     If UseSimField(i, fIdentityType, fIdentityEngines) Then
      Begin
       n := AnsiString(SimFields[i].SimVar);
       u := AnsiString(SimFields[i].Units);
       If u = '' Then
        Check(fAdd(fHandle, fFullRequest, PAnsiChar(n), Nil, SimFields[i].DataType, 0, $FFFFFFFF))
       Else
        Check(fAdd(fHandle, fFullRequest, PAnsiChar(n), PAnsiChar(u), SimFields[i].DataType, 0, $FFFFFFFF));
       Track('telemetry definition: ' + String(n));
       SetLength(fFullFields, Length(fFullFields) + 1);
       fFullFields[High(fFullFields)] := i;
       Inc(fFullSize, SimFields[i].Size);
      End;
    Check(fRequest(fHandle, fFullRequest, fFullRequest, 0, 3, 0, 0, 0, 0));
    Track('telemetry request');
    TelemetryActive := True;
    fAirlinerTitle  := fIdentityTitle;
    If UseSharedAirliner(fIdentityTitle, AircraftPath, fIdentityType) Then
     fAirliner := TAirlinerVars.Create(fDLL);
    fGSX       := TGSXVars.Create(fDLL);
    Log(2, Format('Aircraft subscriptions: %s, engine type=%d count=%d; standard fields=%d of %d', [fIdentityTitle, fIdentityType, fIdentityEngines, Length(fFullFields), FieldCount]));
   Except
    If Assigned(fClear) Then
     fClear(fHandle, fFullRequest);
    StopTelemetry;
    Raise;
   End;
  End;

 Function TSimConnectClient.MatchesIdentity(Const Data : TBytes) : Boolean;
  Var
   i : Integer;
   f : Integer;
   a : AnsiString;
   v : Double;
  Begin
   Result := False;
   For i  := 0 To High(fBasicFields) Do
    Begin
     f := fBasicFields[i];
     If SimFields[f].DataType = 4 Then
      Begin
       Move(Data[SimFields[f].Offset], v, 8);
       If IsNan(v) Or IsInfinite(v) Then
        Exit;
       If (SimFields[f].Name = 'engine_type') And (v <> fIdentityType) Then
        Exit;
       If (SimFields[f].Name = 'number_of_engines') And (v <> fIdentityEngines) Then
        Exit;
      End
     Else
      Begin
       SetString(a, PAnsiChar(@Data[SimFields[f].Offset]), SimFields[f].Size);
       If Pos(#0, String(a)) > 0 Then
        SetLength(a, Pos(#0, String(a)) - 1);
       If Trim(UTF8ToString(UTF8String(a))) <> fIdentityTitle Then
        Exit;
      End;
    End;
   Result := True;
  End;

 Procedure TSimConnectClient.Bootstrap(p : Pointer; Size : DWORD);
  Var
   i       : Integer;
   Offset  : Integer;
   Need    : Integer;
   v       : Double;
   Title   : String;
   Kind    : Integer;
   Engines : Integer;
   a       : AnsiString;
  Begin
   Need  := 0;
   For i := 0 To High(fBasicFields) Do
    Inc(Need, SimFields[fBasicFields[i]].Size);
   If Size < DWORD(Need) Then
    Exit;
   Title   := '';
   Kind    := -1;
   Engines := -1;
   Offset  := 0;
   For i   := 0 To High(fBasicFields) Do
    Begin
     If SimFields[fBasicFields[i]].DataType = 4 Then
      Begin
       Move(PByte(NativeUInt(p) + NativeUInt(Offset))^, v, 8);
       If IsNan(v) Or IsInfinite(v) Or (v < 0) Or (v > 16) Then
        Exit;
       If SimFields[fBasicFields[i]].Name = 'engine_type' Then
        Kind := Trunc(v);
       If SimFields[fBasicFields[i]].Name = 'number_of_engines' Then
        Engines := Trunc(v);
      End
     Else
      Begin
       SetString(a, PAnsiChar(NativeUInt(p) + NativeUInt(Offset)), SimFields[fBasicFields[i]].Size);
       If Pos(#0, String(a)) > 0 Then
        SetLength(a, Pos(#0, String(a)) - 1);
       Title := Trim(UTF8ToString(UTF8String(a)));
      End;
     Inc(Offset, SimFields[fBasicFields[i]].Size);
    End;
   If (Kind < 0) Or (Kind > 6) Or (Engines < 0) Or (Engines > 16) Or (Title = '') Then
    Begin
     StopTelemetry;
     fIdentityFresh := False;
     Exit;
    End;
   If (fIdentityTitle <> Title) Or (fIdentityType <> Kind) Or (fIdentityEngines <> Engines) Then
    Begin
     StopTelemetry;
     If (fIdentityTitle <> '') And Assigned(OnCockpit) Then
      OnCockpit(Self, 'FLIGHT_ENDED');
    End;
   fIdentityTitle   := Title;
   fIdentityType    := Kind;
   fIdentityEngines := Engines;
   fIdentityFresh   := True;
   ConfigureTelemetry;
  End;

 Procedure TSimConnectClient.Connect(Const DLL : String);
  Var
   OpenResult : HRESULT;
  Begin
   Disconnect;
   Error        := '';
   Quit         := False;
   fDLL         := DLL;
   FlightEnded  := True;
   fEndObserved := False;
   fLib         := LoadLibraryEx(PChar(DLL), 0, LOAD_WITH_ALTERED_SEARCH_PATH);
   If fLib = 0 Then
    RaiseLastOSError;
   Try
    @fGetNext := GetProcAddress(fLib, 'SimConnect_GetNextDispatch');
    @fState := GetProcAddress(fLib, 'SimConnect_RequestSystemState');
    fPlanRefresh   := True;
    fPlanNext      := 0;
    FlightPlanPath := '';
    @fLastPacket := GetProcAddress(fLib, 'SimConnect_GetLastSentPacketID');
    fPackets.Clear;
    @fOpen := GetProcAddress(fLib, 'SimConnect_Open');
    @fClose := GetProcAddress(fLib, 'SimConnect_Close');
    @fAdd := GetProcAddress(fLib, 'SimConnect_AddToDataDefinition');
    @fClear := GetProcAddress(fLib, 'SimConnect_ClearDataDefinition');
    @fRequest := GetProcAddress(fLib, 'SimConnect_RequestDataOnSimObject');
    @fDispatch := GetProcAddress(fLib, 'SimConnect_CallDispatch');
    @fSubscribe := GetProcAddress(fLib, 'SimConnect_SubscribeToSystemEvent');
    @fMap := GetProcAddress(fLib, 'SimConnect_MapClientEventToSimEvent');
    @fGroup := GetProcAddress(fLib, 'SimConnect_AddClientEventToNotificationGroup');
    @fPriority := GetProcAddress(fLib, 'SimConnect_SetNotificationGroupPriority');
    If Not(Assigned(fOpen) And Assigned(fClose) And Assigned(fAdd) And Assigned(fRequest) And Assigned(fDispatch) And Assigned(fSubscribe) And Assigned(fMap) And Assigned(fGroup) And Assigned(fPriority)) Then
     Raise Exception.Create(Tr('Incomplete SimConnect DLL'));
    OpenResult := fOpen(fHandle, 'MSFS FDR Delphi', 0, 0, 0, 0);
    If OpenResult = E_FAIL Then
     Raise ESimConnectUnavailable.Create('SimConnect_Open: E_FAIL (80004005)');
    Check(OpenResult);
    Opened := True;
    Log(2, 'SimConnect opened');
   Except
    Disconnect;
    Raise;
   End;
  End;

 Procedure TSimConnectClient.InitializeSession;
  Var
   i : Integer;
   n : AnsiString;
   u : AnsiString;
  Begin
   fBasicFields := Nil;
   For i        := 0 To FieldCount - 1 Do
    If IsBootstrapField(i) Then
     Begin
      SetLength(fBasicFields, Length(fBasicFields) + 1);
      fBasicFields[High(fBasicFields)] := i;
      n                                := AnsiString(SimFields[i].SimVar);
      u                                := AnsiString(SimFields[i].Units);
      If u = '' Then
       Check(fAdd(fHandle, 10, PAnsiChar(n), Nil, SimFields[i].DataType, 0, $FFFFFFFF))
      Else
       Check(fAdd(fHandle, 10, PAnsiChar(n), PAnsiChar(u), SimFields[i].DataType, 0, $FFFFFFFF));
      Track('identity definition: ' + String(n));
     End;
   fBasicRequest := 10;
   fGeneration   := 1000;
   Check(fRequest(fHandle, fBasicRequest, 10, 0, 4, 0, 0, 0, 0));
   Check(fSubscribe(fHandle, 1, 'Sim'));
   Check(fSubscribe(fHandle, 2, 'Pause'));
   fSubscribe(fHandle, 6, 'FlightLoaded');
   fSubscribe(fHandle, 7, 'SimStart');
   fSubscribe(fHandle, 8, 'SimStop');
   fSubscribe(fHandle, 9, 'AircraftLoaded');
   @fFlow := GetProcAddress(fLib, 'SimConnect_SubscribeToFlowEvent');
   If Assigned(fFlow) Then
    fFlow(fHandle);
   If Assigned(fState) Then
    Begin
     fState(fHandle, 502, 'FlightLoaded');
     fState(fHandle, 503, 'Sim');
     fState(fHandle, 504, 'AircraftLoaded');
    End;
   Check(fSubscribe(fHandle, 3, 'Crashed'));
   fSubscribe(fHandle, 4, 'FlightPlanActivated');
   fSubscribe(fHandle, 5, 'FlightPlanDeactivated');
   For i := 0 To High(CockpitEvents) Do
    Begin
     n := AnsiString(CockpitEvents[i]);
     Check(fMap(fHandle, 100 + i, PAnsiChar(n)));
     Track('cockpit event: ' + String(n));
     Check(fGroup(fHandle, 1, 100 + i, False));
    End;
   Check(fPriority(fHandle, 1, 4000000000)); // observe; never mask or transmit cockpit events
  End;

 Procedure TSimConnectClient.ReadSimulatorVersion(p : Pointer; Size : DWORD);
  Var
   Name       : AnsiString;
   Major      : DWORD;
   Minor      : DWORD;
   BuildMajor : DWORD;
   BuildMinor : DWORD;
   n          : Integer;
  Begin
   If Connected Or (UnsupportedSimulator <> '') Then
    Exit;
   SimulatorSupported := False;
   SimulatorVersion   := 'Unknown';
   // SIMCONNECT_RECV_OPEN: 12-byte header, char[256], application version.
   // Read the simulator's version, never the client DLL/SimConnect version.
   If Size >= 308 Then
    Begin
     n := 0;
     While (n < 256) And (PByte(NativeUInt(p) + 12 + NativeUInt(n))^ <> 0) Do
      Inc(n);
     SetString(Name, PAnsiChar(NativeUInt(p) + 12), n);
     Move(PByte(NativeUInt(p) + 268)^, Major, 4);
     Move(PByte(NativeUInt(p) + 272)^, Minor, 4);
     Move(PByte(NativeUInt(p) + 276)^, BuildMajor, 4);
     Move(PByte(NativeUInt(p) + 280)^, BuildMinor, 4);
     SimulatorVersion   := Format('%s %d.%d.%d.%d', [String(Name), Major, Minor, BuildMajor, BuildMinor]);
     SimulatorSupported := (Major = 12) And (SameText(String(Name), 'SunRise') Or SameText(String(Name), 'Microsoft Flight Simulator 2024'));
    End;
   Log(2, 'SimConnect simulator: ' + SimulatorVersion);
   If Not SimulatorSupported Then
    Begin
     UnsupportedSimulator := SimulatorVersion;
     Connected            := False;
     Running              := False;
     FlightEnded          := True;
     StopTelemetry;
     Exit;
    End;
   Connected := True;
   If fHandle <> 0 Then
    InitializeSession;
  End;

 Procedure TSimConnectClient.Disconnect;
  Begin
   StopTelemetry;
   fSessionReady  := False;
   fFlightStarted := False;
   fIdentityFresh := False;
   AircraftPath   := '';
   FreeAndNil(fGSX);
   FreeAndNil(Sample.GSXData);
   FreeAndNil(fAirliner);
   FreeAndNil(Sample.AirlinerData);
   If (fHandle <> 0) And Assigned(fClose) Then
    fClose(fHandle);
   fHandle := 0;
   If fLib <> 0 Then
    FreeLibrary(fLib);
   fLib                 := 0;
   SimulatorSupported   := False;
   SimulatorVersion     := '';
   UnsupportedSimulator := '';
   Opened               := False;
   Connected            := False;
   Running              := False;
   FlightEnded          := False;
   FlightLoading        := False;
   fLoadedFlight        := '';
   Paused               := False;
   fPending             := Nil;
   fEdges.Clear;
   fGroundKnown := False;
  End;

 Procedure TSimConnectClient.Receive(p : Pointer; Size : DWORD);
  Var
   ID          : DWORD;
   Event       : DWORD;
   Value       : DWORD;
   SendID      : DWORD;
   Index       : DWORD;
   Req         : DWORD;
   Def         : DWORD;
   Count       : DWORD;
   Flags       : DWORD;
   Context     : String;
   MessageText : String;
   Data        : TBytes;
   i           : Integer;
   Offset      : Integer;
   v           : Double;
   PathBytes   : AnsiString;
  Begin
   If Size < 12 Then
    Exit;
   Move(PByte(NativeUInt(p) + 8)^, ID, 4);
   If Opened And Not Connected And (ID <> 2) And (ID <> 3) Then
    Exit;
   If (ID In [1, 8]) And Assigned(OnPacket) Then
    OnPacket(p, Size);
   Case ID Of
    1 :
     Begin
      If Size < 16 Then
       Exit;
      Move(PByte(NativeUInt(p) + 12)^, Value, 4);
      SendID := 0;
      Index  := 0;
      If Size >= 24 Then
       Begin
        Move(PByte(NativeUInt(p) + 16)^, SendID, 4);
        Move(PByte(NativeUInt(p) + 20)^, Index, 4);
       End;
      If Not fPackets.TryGetValue(SendID, Context) Then
       Context    := 'auxiliary request';
      MessageText := Format('SimConnect exception %d, send=%d, index=%d, %s', [Value, SendID, Index, Context]);
      Log(1, MessageText);
      // Optional cockpit/facility failures must not terminate a telemetry flight.
      If Pos('telemetry', Context) = 1 Then
       Error := MessageText;
     End;
    2 :
     ReadSimulatorVersion(p, Size);
    3 :
     Begin
      StopTelemetry;
      Connected      := False;
      Quit           := True;
      fFlightStarted := False;
     End;
    4 :
     Begin
      If Size < 24 Then
       Exit;
      Move(PByte(NativeUInt(p) + 16)^, Event, 4);
      Move(PByte(NativeUInt(p) + 20)^, Value, 4);
      If Event = 1 Then
       Begin
        Running := Value <> 0;
        If Not Running Then
         StopTelemetry
        Else
         ConfigureTelemetry;
       End
      Else If Event = 7 Then
       Begin
        Running      := True;
        fPlanRefresh := True;
        If Assigned(fState) Then
         fState(fHandle, 505, 'FlightLoaded')
        Else
         Begin
          fSessionReady := True;
          fEndObserved  := False;
         End;
        If fSessionReady Then
         Begin
          FlightLoading := False;
          FlightEnded   := False;
         End;
        RefreshIdentity;
       End
      Else If Event = 8 Then
       Begin
        Running := False;
        StopTelemetry;
       End
      Else If Event = 2 Then
       Paused := Value <> 0
      Else If Event = 5 Then
       Begin
        FlightPlanPath := '';
        fPlanRefresh   := True;
       End
      Else If Event = 3 Then
       Begin
        If Assigned(OnCockpit) Then
         OnCockpit(Self, 'CRASHED');
       End
      Else If (Event >= 100) And (Event < 100 + DWORD(Length(CockpitEvents))) And Assigned(OnCockpit) Then
       OnCockpit(Self, CockpitEvents[Event - 100]);
     End;
    6 : // SIMCONNECT_RECV_EVENT_FILENAME
     Begin
      If Size >= 24 Then
       Begin
        Move(PByte(NativeUInt(p) + 16)^, Event, 4);
        If Event = 4 Then
         fPlanRefresh := True;
        If (Event = 6) Or (Event = 9) Then
         fPlanRefresh := True;
        If Event = 9 Then
         Begin
          Index := 24;
          While (Index < Size) And (PByte(NativeUInt(p) + Index)^ <> 0) Do
           Inc(Index);
          SetString(PathBytes, PAnsiChar(NativeUInt(p) + 24), Index - 24);
          Context := UTF8ToString(UTF8String(PathBytes));
          If Context <> '' Then
           Begin
            StopTelemetry;
            If Assigned(OnCockpit) Then
             OnCockpit(Self, 'FLIGHT_ENDED');
            AircraftPath  := Context;
            fSessionReady := Pos('MAINMENU', UpperCase(Context)) = 0;
            FlightEnded   := Not fSessionReady;
            fEndObserved  := Not fSessionReady;
            RefreshIdentity;
           End;
         End;
        If Event = 6 Then
         Begin
          Index := 24;
          While (Index < Size) And (PByte(NativeUInt(p) + Index)^ <> 0) Do
           Inc(Index);
          SetString(PathBytes, PAnsiChar(NativeUInt(p) + 24), Index - 24);
          If Not Assigned(fFlow) And (fLoadedFlight <> '') Then
           ApplyFlow(1, '');
          fLoadedFlight := UTF8ToString(UTF8String(PathBytes));
          ApplyFlow(2, fLoadedFlight);
         End;
       End;
     End;
    15 : // SIMCONNECT_RECV_SYSTEM_STATE
     Begin
      If Size >= 24 Then
       Begin
        Move(PByte(NativeUInt(p) + 12)^, Req, 4);
        If Req = 503 Then
         Begin
          Move(PByte(NativeUInt(p) + 16)^, Value, 4);
          Running := Value <> 0;
          If Not Running Then
           StopTelemetry
          Else
           ConfigureTelemetry;
         End;
        If Req = 504 Then
         Begin
          Index := 24;
          While (Index < Size) And (PByte(NativeUInt(p) + Index)^ <> 0) Do
           Inc(Index);
          SetString(PathBytes, PAnsiChar(NativeUInt(p) + 24), Index - 24);
          Context := UTF8ToString(UTF8String(PathBytes));
          If (Context <> '') And (AircraftPath = '') Then
           Begin
            AircraftPath := Context;
            // Cached AircraftLoaded state also exists in the main menu.
            // It supplies identification only, never proof of a live flight.
           End;
         End;
        If (Req = 502) Or (Req = 505) Then
         Begin
          Index := 24;
          While (Index < Size) And (PByte(NativeUInt(p) + Index)^ <> 0) Do
           Inc(Index);
          SetString(PathBytes, PAnsiChar(NativeUInt(p) + 24), Index - 24);
          Context := UTF8ToString(UTF8String(PathBytes));
          If (Req = 505) And (Context <> '') Then
           Begin
            If Pos('MAINMENU.FLT', UpperCase(Context)) > 0 Then
             ApplyFlow(9, Context)
            Else
             Begin
              FlightLoading := False;
              FlightEnded   := False;
              fEndObserved  := False;
              fSessionReady := True;
              RefreshIdentity;
             End;
           End;
          If (Context <> '') And (Context <> fLoadedFlight) Then
           Begin
            If fLoadedFlight <> '' Then
             ApplyFlow(1, '');
            fLoadedFlight := Context;
            ApplyFlow(2, Context);
           End;
         End;
        If Req = 501 Then
         Begin
          Index := 24;
          While (Index < Size) And (PByte(NativeUInt(p) + Index)^ <> 0) Do
           Inc(Index);
          SetString(PathBytes, PAnsiChar(NativeUInt(p) + 24), Index - 24);
          FlightPlanPath := UTF8ToString(UTF8String(PathBytes));
         End;
       End;
     End;
    39, 40 : // FLOW_EVENT: retail header omits the conditional PICK slot
     Begin
      If (Size >= 272) And Assigned(fFlow) Then
       Begin
        Move(PByte(NativeUInt(p) + 12)^, Event, 4);
        Index := 16;
        While (Index < 272) And (PByte(NativeUInt(p) + Index)^ <> 0) Do
         Inc(Index);
        SetString(PathBytes, PAnsiChar(NativeUInt(p) + 16), Index - 16);
        ApplyFlow(Event, UTF8ToString(UTF8String(PathBytes)));
       End;
     End;
    8 :
     Begin
      If Size < 40 Then
       Exit;
      Move(PByte(NativeUInt(p) + 12)^, Req, 4);
      Move(PByte(NativeUInt(p) + 20)^, Def, 4);
      Move(PByte(NativeUInt(p) + 24)^, Flags, 4);
      Move(PByte(NativeUInt(p) + 36)^, Count, 4);
      If (Req = fBasicRequest) And (Def = 10) And (Flags = 0) And (Count = DWORD(Length(fBasicFields))) Then
       Begin
        Bootstrap(Pointer(NativeUInt(p) + 40), Size - 40);
        Exit;
       End;
      If TelemetryActive And (Req = fFullRequest) And (Def = fFullRequest) And (Flags = 0) And (Count = DWORD(Length(fFullFields))) Then
       Begin
        If Size < DWORD(40 + fFullSize) Then
         Exit;
        SetLength(Data, PayloadSize);
        FillChar(Data[0], PayloadSize, 0);
        For i := 0 To FieldCount - 1 Do
         If IsEngineField(SimFields[i].SimVar) Then
          Begin
           v := NaN;
           Move(v, Data[SimFields[i].Offset], 8);
          End;
        Offset := 0;
        For i  := 0 To High(fFullFields) Do
         Begin
          Move(PByte(NativeUInt(p) + 40 + NativeUInt(Offset))^, Data[SimFields[fFullFields[i]].Offset], SimFields[fFullFields[i]].Size);
          Inc(Offset, SimFields[fFullFields[i]].Size);
         End;
        If Not MatchesIdentity(Data) Then
         Begin
          StopTelemetry;
          RefreshIdentity;
          Exit;
         End;
        QueueTelemetry(@Data[0]);
        If Not fDeferSamples Then
         FlushTelemetry;
        Exit;
       End;
      {$IFDEF PORT_TEST}
      // Existing synthetic fixtures use the historical full wire layout; never accepted in production.
      If (Req <> 1) Or (Def <> 1) Or (Flags <> 0) Or (Count <> FieldCount) Or (Size < 40 + PayloadSize) Then
       Exit;
      {$ELSE}
      Exit;
      {$ENDIF}
      If Error <> '' Then
       Exit;
      QueueTelemetry(Pointer(NativeUInt(p) + 40));
      If Not fDeferSamples Then
       FlushTelemetry;
     End;
    18, 28, 29 :
     If Assigned(OnPacket) Then
      OnPacket(p, Size);
   End;
  End;

 Procedure TSimConnectClient.QueueTelemetry(p : Pointer);
  Var
   Data        : TBytes;
   GroundValue : Double;
   Ground      : Boolean;
  Begin
   Inc(fReceivedCount);
   SetLength(Data, PayloadSize);
   Move(p^, Data[0], PayloadSize);
   Move(PByte(NativeUInt(p) + NativeUInt(fGroundOffset))^, GroundValue, 8);
   Ground := GroundValue <> 0;
   If Not fGroundKnown Or (Ground <> fLastGround) Then
    fEdges.Add(Data);
   fGroundKnown := True;
   fLastGround  := Ground;
   fPending     := Data;
  End;

 Procedure TSimConnectClient.DeliverTelemetry(Const Data : TBytes);
  Begin
   Inc(fDeliveredCount);
   Sample.Decode(@Data[0], Length(Data));
   If fAirliner <> Nil Then
    Begin
     If fAirlinerTitle <> Sample.S('title') Then
      Begin
       fAirliner.Close;
       If fGSX <> Nil Then
        fGSX.Close;
       fAirlinerTitle := Sample.S('title');
      End;
     Sample.AirlinerData := fAirliner.Snapshot;
    End;
   If fGSX <> Nil Then
    Sample.GSXData := fGSX.Snapshot;
   If Assigned(OnSample) Then
    OnSample(Self, Sample);
  End;

 Procedure TSimConnectClient.FlushTelemetry;
  Var
   Latest : TBytes;
   Edges  : TArray<TBytes>;
   i      : Integer;
  Begin
   Latest   := fPending;
   fPending := Nil;
   Edges    := fEdges.ToArray;
   fEdges.Clear;
   For i := 0 To High(Edges) Do
    DeliverTelemetry(Edges[i]);
   If (Length(Latest) > 0) And ((Length(Edges) = 0) Or Not CompareMem(@Edges[High(Edges)][0], @Latest[0], Length(Latest))) Then
    DeliverTelemetry(Latest);
  End;

 Procedure TSimConnectClient.ApplyFlow(Event : DWORD; Const Path : String);
  Begin
   If (Event = 1) Or (Event = 9) Or (Event = 15) Or (Event = 16) Or (Pos('MAINMENU.FLT', UpperCase(Path)) > 0) Then
    Begin
     fPending := Nil;
     fEdges.Clear;
     fGroundKnown := False;
    End;
   If Pos('MAINMENU.FLT', UpperCase(Path)) > 0 Then
    Event := 9;
   If (Event = 1) Or (Event = 9) Or (Event = 15) Or (Event = 16) Then
    Begin
     StopTelemetry;
     fSessionReady  := False;
     fIdentityFresh := False;
     fEndObserved   := True;
    End;
   Log(2, Format('Flight flow: event=%d path=%s', [Event, Path]));
   If Event In [1, 9, 15, 16] Then
    fFlightStarted := False;
   Case Event Of
    1 :
     Begin
      FlightLoading := True;
      If Assigned(OnCockpit) Then
       OnCockpit(Self, 'FLIGHT_ENDED');
     End;
    2 :
     Begin
      FlightLoading := False;
      FlightEnded   := False;
      fSessionReady := True;
      fEndObserved  := False;
      If Not Assigned(fFlow) Then
       fFlightStarted := True;
      RefreshIdentity;
     End;
    14 :
     Begin
      fFlightStarted := True;
      FlightLoading  := False;
      FlightEnded    := False;
      fSessionReady  := True;
      fEndObserved   := False;
      RefreshIdentity;
     End;
    9, 15, 16 :
     Begin
      FlightLoading := False;
      FlightEnded   := True;
      If Assigned(OnCockpit) Then
       OnCockpit(Self, 'FLIGHT_ENDED');
     End;
   End;
  End;

 Procedure TSimConnectClient.Poll;
  Var
   p       : Pointer;
   Size    : DWORD;
   n       : Integer;
   UntilMS : UInt64;
  Begin
   fDeferSamples := True;
   Try
    If fHandle <> 0 Then
     Begin
      If Assigned(fGetNext) Then
       Begin
        n       := 0;
        UntilMS := GetTickCount64 + 25;
        Repeat
         p    := Nil;
         Size := 0;
         If fGetNext(fHandle, p, Size) < 0 Then
          Break;
         If (p = Nil) Or (Size < 12) Then
          Break;
         Receive(p, Size);
         Inc(n);
        Until(n >= 4096) Or (fEdges.Count >= 16) Or (GetTickCount64 >= UntilMS);
       End
      Else
       Check(fDispatch(fHandle, @SimCallback, Self));
     End;
   Finally
    fDeferSamples := False;
   End;
   ConfigureTelemetry;
   If fGSX <> Nil Then
    If Connected And Running And TelemetryActive And Not Paused Then
     fGSX.Tick
    Else
     fGSX.Close;
   If fAirliner <> Nil Then
    If Connected And Running And TelemetryActive And Not Paused Then
     fAirliner.Tick
    Else
     fAirliner.Close;
   FlushTelemetry;
   If (fReceivedCount > 0) And (GetTickCount64 >= fTelemetryLogNext) Then
    Begin
     fTelemetryLogNext := GetTickCount64 + 30000;
     Log(2, Format('SimConnect telemetry: received=%d delivered=%d coalesced=%d', [fReceivedCount, fDeliveredCount, fReceivedCount - fDeliveredCount]));
    End;
   If Error <> '' Then
    Raise Exception.Create(Error);
   If Connected And Assigned(fState) And (fPlanRefresh Or (GetTickCount64 >= fPlanNext)) Then
    Begin
     fPlanRefresh := False;
     fPlanNext    := GetTickCount64 + 10000;
     fState(fHandle, 501, 'FlightPlan');
     fState(fHandle, 502, 'FlightLoaded');
    End;
  End;

{$IFDEF PORT_TEST}

 Procedure TSimConnectClient.Feed(p : Pointer; Size : DWORD);
  Begin
   Receive(p, Size);
  End; {$ENDIF}
{$IFDEF PORT_TEST}

 Procedure TSimConnectClient.FeedBatch(Const Packets : TArray<TBytes>);
  Var
   Packet : TBytes;
  Begin
   fDeferSamples := True;
   Try
    For Packet In Packets Do
     If Length(Packet) > 0 Then
      Receive(@Packet[0], Length(Packet));
   Finally
    fDeferSamples := False;
   End;
   FlushTelemetry;
  End;
{$ENDIF}

End.
