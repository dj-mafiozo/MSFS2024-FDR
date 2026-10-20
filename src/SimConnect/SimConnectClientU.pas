{$StackFrames On}
Unit SimConnectClientU;

Interface

 Uses
  Winapi.Windows, System.SysUtils, System.Generics.Collections,
  LocalizationU, AppLogU, TelemetryCatalogU, FlightTelemetryU, AirlinerVarsU, GSXVarsU;

 Type
  TSampleEvent  = Procedure(Sender : TObject; Sample : TFlightSample) Of Object;
  TPacketEvent  = Procedure(P : Pointer; Size : DWORD) Of Object;
  TCockpitEvent = Procedure(Sender : TObject; Const Name : String) Of Object;

  TSimConnectClient = Class
   Private
    fGetNext          : Function(H : THandle; Var P : Pointer; Var Size : DWORD) : HRESULT; Stdcall;
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
    fFlow             : Function(H : THandle) : HRESULT; Stdcall;
    fState            : Function(H : THandle; ID : DWORD; Name : PAnsiChar) : HRESULT; Stdcall;
    fPlanRefresh      : Boolean;
    fPlanNext         : UInt64;
    fLastPacket       : Function(H : THandle; Var ID : DWORD) : HRESULT; Stdcall;
    fLib              : HMODULE;
    fHandle           : THandle;
    fOpen             : Function(Var H : THandle; N : PAnsiChar; W : HWND; E : DWORD; EH : THandle; C : DWORD) : HRESULT; Stdcall;
    fClose            : Function(H : THandle) : HRESULT; Stdcall;
    fAdd              : Function(H : THandle; ID : DWORD; N, U : PAnsiChar; T : DWORD; E : Single; D : DWORD) : HRESULT; Stdcall;
    fRequest          : Function(H : THandle; R, D, O, P, F, A, I, L : DWORD) : HRESULT; Stdcall;
    fDispatch         : Function(H : THandle; CB, Context : Pointer) : HRESULT; Stdcall;
    fSubscribe        : Function(H : THandle; ID : DWORD; N : PAnsiChar) : HRESULT; Stdcall;
    fMap              : Function(H : THandle; ID : DWORD; N : PAnsiChar) : HRESULT; Stdcall;
    fGroup            : Function(H : THandle; G, ID : DWORD; Mask : BOOL) : HRESULT; Stdcall;
    fPriority         : Function(H : THandle; G, P : DWORD) : HRESULT; Stdcall;
    Procedure QueueTelemetry(P : Pointer);
    Procedure DeliverTelemetry(Const Data : TBytes);
    Procedure FlushTelemetry;
    Procedure Track(Const Context : String);
    Procedure Check(HR : HRESULT);
    Procedure Receive(P : Pointer; Size : DWORD);
   Public
    Sample         : TFlightSample;
    Connected      : Boolean;
    Running        : Boolean;
    Paused         : Boolean;
    Quit           : Boolean;
    Opened         : Boolean;
    Error          : String;
    FlightPlanPath : String;
    FlightEnded    : Boolean;
    FlightLoading  : Boolean;
    FLoadedFlight  : String;
    OnSample       : TSampleEvent;
    OnCockpit      : TCockpitEvent;
    OnPacket       : TPacketEvent;
    Procedure ApplyFlow(Event : DWORD; Const Path : String);
    Property Handle : THandle Read fHandle;
    Function FunctionAddress(Const Name : AnsiString) : Pointer;
    Constructor Create;
    Destructor Destroy; Override;
    Procedure Connect(Const DLL : String);
    Procedure Disconnect;
    Procedure Poll;
    {$IFDEF PORT_TEST}
    Procedure Feed(P : Pointer; Size : DWORD);
    Procedure FeedBatch(Const Packets : TArray<TBytes>);
    {$ENDIF}
  End;

Implementation

 Procedure SimCallback(P : Pointer; Size : DWORD; Context : Pointer); Stdcall;
  Begin
   Try
    TSimConnectClient(Context).Receive(P, Size);
   Except
    On E : Exception Do
     Begin
      TSimConnectClient(Context).Error := E.ClassName + ': ' + E.Message;
      Log(0, 'SimConnect callback: ' + TSimConnectClient(Context).Error);
     End;
   End;
  End;

 Constructor TSimConnectClient.Create;
  Var
   I : Integer;
  Begin
   Inherited;
   fPackets := TDictionary<DWORD, String>.Create;
   Sample   := TFlightSample.Create;
   fEdges   := TList<TBytes>.Create;
   For I    := 0 To FieldCount - 1 Do
    If SimFields[I].Name = 'sim_on_ground' Then
     fGroundOffset := SimFields[I].Offset;
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
    fPackets.AddOrSetValue(ID, Context);
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

 Procedure TSimConnectClient.Connect(Const DLL : String);
  Var
   I    : Integer;
   N, U : AnsiString;
  Begin
   Disconnect;
   Error := '';
   Quit  := False;
   fLib  := LoadLibraryEx(PChar(DLL), 0, LOAD_WITH_ALTERED_SEARCH_PATH);
   If fLib = 0 Then
    RaiseLastOSError;
   Try
    @fGetNext      := GetProcAddress(fLib, 'SimConnect_GetNextDispatch');
    @fState        := GetProcAddress(fLib, 'SimConnect_RequestSystemState');
    fPlanRefresh   := True;
    fPlanNext      := 0;
    FlightPlanPath := '';
    @fLastPacket   := GetProcAddress(fLib, 'SimConnect_GetLastSentPacketID');
    fPackets.Clear;
    @fOpen      := GetProcAddress(fLib, 'SimConnect_Open');
    @fClose     := GetProcAddress(fLib, 'SimConnect_Close');
    @fAdd       := GetProcAddress(fLib, 'SimConnect_AddToDataDefinition');
    @fRequest   := GetProcAddress(fLib, 'SimConnect_RequestDataOnSimObject');
    @fDispatch  := GetProcAddress(fLib, 'SimConnect_CallDispatch');
    @fSubscribe := GetProcAddress(fLib, 'SimConnect_SubscribeToSystemEvent');
    @fMap       := GetProcAddress(fLib, 'SimConnect_MapClientEventToSimEvent');
    @fGroup     := GetProcAddress(fLib, 'SimConnect_AddClientEventToNotificationGroup');
    @fPriority  := GetProcAddress(fLib, 'SimConnect_SetNotificationGroupPriority');
    If Not(Assigned(fOpen) And Assigned(fClose) And Assigned(fAdd) And Assigned(fRequest) And Assigned(fDispatch) And Assigned(fSubscribe) And Assigned(fMap) And Assigned(fGroup) And Assigned(fPriority)) Then
     Raise Exception.Create(Tr('Incomplete SimConnect DLL'));
    Check(fOpen(fHandle, 'MSFS FDR Delphi', 0, 0, 0, 0));
    For I := 0 To FieldCount - 1 Do
     Begin
      N := AnsiString(SimFields[I].SimVar);
      U := AnsiString(SimFields[I].Units);
      If U = '' Then
       Check(fAdd(fHandle, 1, PAnsiChar(N), Nil, SimFields[I].DataType, 0, $FFFFFFFF))
      Else
       Check(fAdd(fHandle, 1, PAnsiChar(N), PAnsiChar(U), 4, 0, $FFFFFFFF));
      Track('telemetry definition: ' + String(N));
     End;
    Check(fSubscribe(fHandle, 1, 'Sim'));
    Check(fSubscribe(fHandle, 2, 'Pause'));
    fSubscribe(fHandle, 6, 'FlightLoaded');
    @fFlow := GetProcAddress(fLib, 'SimConnect_SubscribeToFlowEvent');
    If Assigned(fFlow) Then
     fFlow(fHandle);
    If Assigned(fState) Then
     fState(fHandle, 502, 'FlightLoaded');
    Check(fSubscribe(fHandle, 3, 'Crashed'));
    fSubscribe(fHandle, 4, 'FlightPlanActivated');
    fSubscribe(fHandle, 5, 'FlightPlanDeactivated');
    For I := 0 To High(CockpitEvents) Do
     Begin
      N := AnsiString(CockpitEvents[I]);
      Check(fMap(fHandle, 100 + I, PAnsiChar(N)));
      Track('cockpit event: ' + String(N));
      Check(fGroup(fHandle, 1, 100 + I, False));
     End;
    Check(fPriority(fHandle, 1, 4000000000)); // observe; never mask or transmit cockpit events
    Check(fRequest(fHandle, 1, 1, 0, 3, 0, 0, 0, 0));
    Track('telemetry request');
    fAirliner      := TAirlinerVars.Create(DLL);
    fAirlinerTitle := '';
    fGSX           := TGSXVars.Create(DLL);
    Opened         := True;
    Log(2, 'SimConnect opened');
   Except
    Disconnect;
    Raise;
   End;
  End;

 Procedure TSimConnectClient.Disconnect;
  Begin
   FreeAndNil(fGSX);
   FreeAndNil(Sample.GSXData);
   FreeAndNil(fAirliner);
   FreeAndNil(Sample.AirlinerData);
   If (fHandle <> 0) And Assigned(fClose) Then
    fClose(fHandle);
   fHandle := 0;
   If fLib <> 0 Then
    FreeLibrary(fLib);
   fLib          := 0;
   Opened        := False;
   Connected     := False;
   Running       := False;
   FlightEnded   := False;
   FlightLoading := False;
   FLoadedFlight := '';
   Paused        := False;
   fPending      := Nil;
   fEdges.Clear;
   fGroundKnown := False;
  End;

 Procedure TSimConnectClient.Receive(P : Pointer; Size : DWORD);
  Var
   ID, Event, Value, SendID, Index, Req, Def, Count, Flags : DWORD;
   Context, MessageText                                    : String;
   PathBytes                                               : AnsiString;
  Begin
   If Size < 12 Then
    Exit;
   Move(PByte(NativeUInt(P) + 8)^, ID, 4);
   Case ID Of
    1 :
     Begin
      If Size < 16 Then
       Exit;
      Move(PByte(NativeUInt(P) + 12)^, Value, 4);
      SendID := 0;
      Index  := 0;
      If Size >= 24 Then
       Begin
        Move(PByte(NativeUInt(P) + 16)^, SendID, 4);
        Move(PByte(NativeUInt(P) + 20)^, Index, 4);
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
     Connected := True;
    3 :
     Begin
      Connected := False;
      Quit      := True;
     End;
    4 :
     Begin
      If Size < 24 Then
       Exit;
      Move(PByte(NativeUInt(P) + 16)^, Event, 4);
      Move(PByte(NativeUInt(P) + 20)^, Value, 4);
      If Event = 1 Then
       Running := Value <> 0
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
        Move(PByte(NativeUInt(P) + 16)^, Event, 4);
        If Event = 4 Then
         fPlanRefresh := True;
        If Event = 6 Then
         Begin
          Index := 24;
          While (Index < Size) And (PByte(NativeUInt(P) + Index)^ <> 0) Do
           Inc(Index);
          SetString(PathBytes, PAnsiChar(NativeUInt(P) + 24), Index - 24);
          If Not Assigned(fFlow) And (FLoadedFlight <> '') Then
           ApplyFlow(1, '');
          FLoadedFlight := UTF8ToString(UTF8String(PathBytes));
          ApplyFlow(2, FLoadedFlight);
         End;
       End;
     End;
    15 : // SIMCONNECT_RECV_SYSTEM_STATE
     Begin
      If Size >= 24 Then
       Begin
        Move(PByte(NativeUInt(P) + 12)^, Req, 4);
        If Req = 502 Then
         Begin
          Index := 24;
          While (Index < Size) And (PByte(NativeUInt(P) + Index)^ <> 0) Do
           Inc(Index);
          SetString(PathBytes, PAnsiChar(NativeUInt(P) + 24), Index - 24);
          Context := UTF8ToString(UTF8String(PathBytes));
          If (Context <> '') And (Context <> FLoadedFlight) Then
           Begin
            If FLoadedFlight <> '' Then
             ApplyFlow(1, '');
            FLoadedFlight := Context;
            ApplyFlow(2, Context);
           End;
         End;
        If Req = 501 Then
         Begin
          Index := 24;
          While (Index < Size) And (PByte(NativeUInt(P) + Index)^ <> 0) Do
           Inc(Index);
          SetString(PathBytes, PAnsiChar(NativeUInt(P) + 24), Index - 24);
          FlightPlanPath := UTF8ToString(UTF8String(PathBytes));
         End;
       End;
     End;
    39, 40 : // FLOW_EVENT: retail header omits the conditional PICK slot
     Begin
      If (Size >= 272) And Assigned(fFlow) Then
       Begin
        Move(PByte(NativeUInt(P) + 12)^, Event, 4);
        Index := 16;
        While (Index < 272) And (PByte(NativeUInt(P) + Index)^ <> 0) Do
         Inc(Index);
        SetString(PathBytes, PAnsiChar(NativeUInt(P) + 16), Index - 16);
        ApplyFlow(Event, UTF8ToString(UTF8String(PathBytes)));
       End;
     End;
    8 :
     Begin
      If Size < 40 + PayloadSize Then
       Exit;
      Move(PByte(NativeUInt(P) + 12)^, Req, 4);
      Move(PByte(NativeUInt(P) + 20)^, Def, 4);
      Move(PByte(NativeUInt(P) + 24)^, Flags, 4);
      Move(PByte(NativeUInt(P) + 36)^, Count, 4);
      If (Req <> 1) Or (Def <> 1) Or (Flags <> 0) Or (Count <> FieldCount) Then
       Exit;
      If Error <> '' Then
       Exit;
      QueueTelemetry(Pointer(NativeUInt(P) + 40));
      If Not fDeferSamples Then
       FlushTelemetry;
     End;
    18, 28, 29 :
     If Assigned(OnPacket) Then
      OnPacket(P, Size);
   End;
  End;

 Procedure TSimConnectClient.QueueTelemetry(P : Pointer);
  Var
   Data        : TBytes;
   GroundValue : Double;
   Ground      : Boolean;
  Begin
   Inc(fReceivedCount);
   SetLength(Data, PayloadSize);
   Move(P^, Data[0], PayloadSize);
   Move(PByte(NativeUInt(P) + NativeUInt(fGroundOffset))^, GroundValue, 8);
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
     If fGSX <> Nil Then
      Sample.GSXData := fGSX.Snapshot;
    End;
   If Assigned(OnSample) Then
    OnSample(Self, Sample);
  End;

 Procedure TSimConnectClient.FlushTelemetry;
  Var
   Latest : TBytes;
   Edges  : TArray<TBytes>;
   I      : Integer;
  Begin
   Latest   := fPending;
   fPending := Nil;
   Edges    := fEdges.ToArray;
   fEdges.Clear;
   For I := 0 To High(Edges) Do
    DeliverTelemetry(Edges[I]);
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
     End;
    14 :
     Begin
      FlightLoading := False;
      FlightEnded   := False;
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
   P       : Pointer;
   Size    : DWORD;
   N       : Integer;
   UntilMS : UInt64;
  Begin
   If fGSX <> Nil Then
    If Connected And Running And Not Paused Then
     fGSX.Tick
    Else
     fGSX.Close;
   If fAirliner <> Nil Then
    If Connected And Running And Not Paused Then
     fAirliner.Tick
    Else
     fAirliner.Close;
   fDeferSamples := True;
   Try
    If fHandle <> 0 Then
     Begin
      If Assigned(fGetNext) Then
       Begin
        N       := 0;
        UntilMS := GetTickCount64 + 25;
        Repeat
         P    := Nil;
         Size := 0;
         If fGetNext(fHandle, P, Size) < 0 Then
          Break;
         If (P = Nil) Or (Size < 12) Then
          Break;
         Receive(P, Size);
         Inc(N);
        Until (N >= 4096) Or (fEdges.Count >= 16) Or (GetTickCount64 >= UntilMS);
       End
      Else
       Check(fDispatch(fHandle, @SimCallback, Self));
     End;
   Finally
    fDeferSamples := False;
   End;
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
 {$IFDEF PORT_TEST} Procedure TSimConnectClient.Feed(P : Pointer; Size : DWORD);
  Begin
   Receive(P, Size);
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
