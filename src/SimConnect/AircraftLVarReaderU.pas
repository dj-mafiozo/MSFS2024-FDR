{$StackFrames On}
Unit AircraftLVarReaderU;

Interface

 Uses
  Winapi.Windows, System.SysUtils, System.Math, System.Generics.Collections,
  LocalizationU;

 Const
  LVarBatchSize = 128;

 Type
  TAircraftLVarReader = Class
   Private
    fPollInterval : Integer;
    fRequestedAt  : TArray<UInt64>;
    fPolling      : Boolean;
    fPending      : TArray<Boolean>;
    fBatchSize    : Integer;
    fLib          : HMODULE;
    fHandle       : THandle;
    fDLL          : String;
    fError        : String;
    fClientName   : String;
    fNames        : TArray<String>;
    fUnits        : TArray<String>;
    fNextRetry    : UInt64;
    fCheckFreshAt : UInt64;
    fValues       : TArray<Double>;
    fUpdated      : TArray<UInt64>;
    fSeen         : TArray<Boolean>;
    fFailed       : TArray<Boolean>;
    fPacketBatch  : TDictionary<DWORD, Integer>;
    fOpen         : Function(Var h : THandle; n : PAnsiChar; w : HWND; e : DWORD; EH : THandle; c : DWORD) : HRESULT; Stdcall;
    fClose        : Function(h : THandle) : HRESULT; Stdcall;
    fAdd          : Function(h : THandle; ID : DWORD; n, u : PAnsiChar; t : DWORD; e : Single; d : DWORD) : HRESULT; Stdcall;
    fRequest      : Function(h : THandle; r, d, o, p, f, a, i, l : DWORD) : HRESULT; Stdcall;
    fNext         : Function(h : THandle; Var p : Pointer; Var Size : DWORD) : HRESULT; Stdcall;
    fLast         : Function(h : THandle; Var ID : DWORD) : HRESULT; Stdcall;
    Procedure Connect;
    Procedure Track(Batch : Integer);
    Procedure Receive(p : Pointer; Size : DWORD; NowTick : UInt64);
   Public
    Constructor Create(Const Names : TArray<String>; Const ClientName : String; Const DLL : String = ''; BatchSize : Integer = LVarBatchSize; Polling : Boolean = False; Const Units : TArray<String> = Nil);
    Destructor Destroy; Override;
    Procedure Close;
    Procedure Tick;
    Function Snapshot(Out Values : TArray<Double>; Out AgeMS : UInt64; MaxAgeMS : UInt64) : Integer;
    Property PollIntervalMS : Integer Read fPollInterval Write fPollInterval;
    Property LastError      : String Read fError;
    {$IFDEF PORT_TEST}
    Procedure Feed(p : Pointer; Size : DWORD; NowTick : UInt64); {$ENDIF}
  End;

Implementation

 Constructor TAircraftLVarReader.Create(Const Names : TArray<String>; Const ClientName, DLL : String; BatchSize : Integer; Polling : Boolean; Const Units : TArray<String>);
  Begin
   Inherited Create;
   fPolling      := Polling;
   fPollInterval := 500;
   fBatchSize    := EnsureRange(BatchSize, 1, LVarBatchSize);
   fNames        := Copy(Names);
   fUnits        := Copy(Units);
   fClientName   := ClientName;
   fDLL          := DLL;
   If fDLL = '' Then
    fDLL        := ExtractFilePath(ParamStr(0)) + 'SimConnect.dll';
   fPacketBatch := TDictionary<DWORD, Integer>.Create;
   SetLength(fValues, Length(fNames));
   SetLength(fUpdated, (Length(fNames) + fBatchSize - 1) Div fBatchSize);
   SetLength(fSeen, Length(fUpdated));
   SetLength(fFailed, Length(fUpdated));
   SetLength(fPending, Length(fUpdated));
   SetLength(fRequestedAt, Length(fUpdated));
   Close;
  End;

 Destructor TAircraftLVarReader.Destroy;
  Begin
   Close;
   fPacketBatch.Free;
   Inherited;
  End;

 Procedure TAircraftLVarReader.Close;
  Var
   i : Integer;
  Begin
   If (fHandle <> 0) And Assigned(fClose) Then
    fClose(fHandle);
   fHandle := 0;
   If fLib <> 0 Then
    FreeLibrary(fLib);
   fLib  := 0;
   For i := 0 To High(fUpdated) Do
    Begin
     fSeen[i]        := False;
     fRequestedAt[i] := 0;
     fPending[i]     := False;
     fFailed[i]      := False;
     fUpdated[i]     := 0;
    End;
   For i       := 0 To High(fValues) Do
    fValues[i] := NaN;
   fPacketBatch.Clear;
   fNextRetry    := 0;
   fCheckFreshAt := 0;
  End;

 Procedure TAircraftLVarReader.Track(Batch : Integer);
  Var
   ID : DWORD;
  Begin
   If fPolling And (fPacketBatch.Count > 32768) Then
    fPacketBatch.Clear;
   If Assigned(fLast) And (fLast(fHandle, ID) >= 0) Then
    fPacketBatch.AddOrSetValue(ID, Batch);
  End;

 Procedure TAircraftLVarReader.Connect;
  Var
   i      : Integer;
   b      : Integer;
   n      : AnsiString;
   HR     : HRESULT;
   Period : DWORD;
  Begin
   fLib := LoadLibraryEx(PChar(fDLL), 0, LOAD_WITH_ALTERED_SEARCH_PATH);
   If fLib = 0 Then
    RaiseLastOSError;
   @fOpen := GetProcAddress(fLib, 'SimConnect_Open');
   @fClose := GetProcAddress(fLib, 'SimConnect_Close');
   @fAdd := GetProcAddress(fLib, 'SimConnect_AddToDataDefinition');
   @fRequest := GetProcAddress(fLib, 'SimConnect_RequestDataOnSimObject');
   @fNext := GetProcAddress(fLib, 'SimConnect_GetNextDispatch');
   @fLast := GetProcAddress(fLib, 'SimConnect_GetLastSentPacketID');
   If Not(Assigned(fOpen) And Assigned(fClose) And Assigned(fAdd) And Assigned(fRequest) And Assigned(fNext)) Then
    Raise Exception.Create(Tr('Incomplete SimConnect DLL for aircraft L-vars'));
   n := AnsiString(fClientName);
   If fOpen(fHandle, PAnsiChar(n), 0, 0, 0, 0) < 0 Then
    Raise Exception.Create(Tr('aircraft SimConnect open failed'));
   fCheckFreshAt := GetTickCount64 + 30000;
   For i         := 0 To Length(fNames) - 1 Do
    Begin
     b := i Div fBatchSize;
     If Pos('A:', fNames[i]) = 1 Then
      n := AnsiString(Copy(fNames[i], 3, MaxInt))
     Else
      n := AnsiString('L:' + fNames[i]);
     If (i < Length(fUnits)) And (Pos('A:', fNames[i]) = 1) Then
      HR := fAdd(fHandle, 1000 + b, PAnsiChar(n), PAnsiChar(AnsiString(fUnits[i])), 4, 0, $FFFFFFFF)
     Else
      HR := fAdd(fHandle, 1000 + b, PAnsiChar(n), 'number', 4, 0, $FFFFFFFF);
     Track(b);
     If HR < 0 Then
      Begin
       fFailed[b] := True;
       fError     := 'aircraft L-var definition rejected: ' + fNames[i];
      End;
    End;
   Period := 3;
   If fPolling Then
    Period := 1;
   For b   := 0 To Length(fUpdated) - 1 Do
    If Not fFailed[b] Then
     Begin
      // SIM_FRAME provides the latest data; persistence still follows the configured millisecond interval.
      HR              := fRequest(fHandle, 2000 + b, 1000 + b, 0, Period, 0, 0, 0, 0);
      fRequestedAt[b] := GetTickCount64;
      fPending[b]     := HR >= 0;
      Track(b);
      If HR < 0 Then
       Begin
        fFailed[b] := True;
        fError     := 'aircraft L-var request rejected';
       End;
     End;
  End;

 Procedure TAircraftLVarReader.Receive(p : Pointer; Size : DWORD; NowTick : UInt64);
  Var
   ID     : DWORD;
   Req    : DWORD;
   Def    : DWORD;
   Flags  : DWORD;
   Count  : DWORD;
   SendID : DWORD;
   Code   : DWORD;
   b      : Integer;
   i      : Integer;
   n      : Integer;
   v      : Double;
  Begin
   If (p = Nil) Or (Size < 12) Then
    Exit;
   Move(PByte(NativeUInt(p) + 8)^, ID, 4);
   Case ID Of
    1 :
     Begin
      If Size < 24 Then
       Exit;
      Move(PByte(NativeUInt(p) + 12)^, Code, 4);
      Move(PByte(NativeUInt(p) + 16)^, SendID, 4);
      If fPacketBatch.TryGetValue(SendID, b) Then
       Begin
        fFailed[b] := True;
        fSeen[b]   := False;
        fError     := Format('aircraft L-vars batch %d: SimConnect exception %d', [b, Code]);
       End;
     End;
    3 :
     Begin
      fError := 'Simulator disconnected';
      Close;
      fNextRetry := NowTick + 2000;
     End;
    8 :
     Begin
      If Size < 40 Then
       Exit;
      Move(PByte(NativeUInt(p) + 12)^, Req, 4);
      Move(PByte(NativeUInt(p) + 20)^, Def, 4);
      Move(PByte(NativeUInt(p) + 24)^, Flags, 4);
      Move(PByte(NativeUInt(p) + 36)^, Count, 4);
      If (Def < 1000) Or (Def >= 1000 + Length(fUpdated)) Then
       Exit;
      b := Def - 1000;
      n := Min(fBatchSize, Length(fNames) - b * fBatchSize);
      If (Req <> DWORD(2000 + b)) Or (Flags <> 0) Or (Count <> DWORD(n)) Or (Size < DWORD(40 + n * 8)) Or fFailed[b] Then
       Exit;
      For i := 0 To n - 1 Do
       Begin
        Move(PByte(NativeUInt(p) + 40 + NativeUInt(i * 8))^, v, 8);
        fValues[b * fBatchSize + i] := v;
       End;
      fPending[b] := False;
      fUpdated[b] := NowTick;
      fSeen[b]    := True;
     End;
   End;
  End;

 Procedure TAircraftLVarReader.Tick;
  Var
   p       : Pointer;
   Size    : DWORD;
   i       : Integer;
   Fresh   : Boolean;
   HR      : HRESULT;
   NowTick : UInt64;
  Begin
   If (fHandle = 0) And (GetTickCount64 < fNextRetry) Then
    Exit;
   Try
    If fHandle = 0 Then
     Begin
      fError := '';
      Connect;
     End;
    // Bound each pump so malformed or excessive traffic cannot monopolize the UI thread.
    For i := 1 To 512 Do
     Begin
      If fHandle = 0 Then
       Break;
      p    := Nil;
      Size := 0;
      If fNext(fHandle, p, Size) < 0 Then
       Break;
      Receive(p, Size, GetTickCount64);
     End;
    // XML catalog polling has at most one outstanding ONCE request per field.
    // It cannot accumulate an unbounded SIM_FRAME queue at long recording intervals.
    If fPolling And (fHandle <> 0) Then
     For i := 0 To High(fPending) Do
      If Not fPending[i] And Not fFailed[i] And (GetTickCount64 - fRequestedAt[i] >= UInt64(Max(20, fPollInterval))) Then
       Begin
        HR := fRequest(fHandle, 2000 + i, 1000 + i, 0, 1, 0, 0, 0, 0);
        Track(i);
        fRequestedAt[i] := GetTickCount64;
        fPending[i]     := HR >= 0;
        If HR < 0 Then
         fFailed[i] := True;
       End;
    NowTick := GetTickCount64;
    If (fHandle <> 0) And (NowTick >= fCheckFreshAt) Then
     Begin
      Fresh := False;
      For i := 0 To Length(fUpdated) - 1 Do
       If fSeen[i] And Not fFailed[i] And (NowTick >= fUpdated[i]) And (NowTick - fUpdated[i] < 5000) Then
        Fresh       := True;
      fCheckFreshAt := NowTick + 30000;
      If Not Fresh Then
       Begin
        fError := 'No fresh aircraft L-var packets; reconnecting';
        Close;
        fNextRetry := NowTick + 2000;
       End;
     End;
   Except
    On e : Exception Do
     Begin
      fError := e.Message;
      Close;
      fNextRetry := GetTickCount64 + 2000;
     End;
   End;
  End;

 Function TAircraftLVarReader.Snapshot(Out Values : TArray<Double>; Out AgeMS : UInt64; MaxAgeMS : UInt64) : Integer;
  Var
   i       : Integer;
   b       : Integer;
   NowTick : UInt64;
   Age     : UInt64;
  Begin
   SetLength(Values, Length(fNames));
   Result  := 0;
   AgeMS   := 0;
   NowTick := GetTickCount64;
   For i   := 0 To Length(fNames) - 1 Do
    Begin
     Values[i] := NaN;
     b         := i Div fBatchSize;
     If Not fSeen[b] Or fFailed[b] Or (NowTick < fUpdated[b]) Then
      Continue;
     Age := NowTick - fUpdated[b];
     If Age > MaxAgeMS Then
      Continue;
     If Age > AgeMS Then
      AgeMS := Age;
     If IsNan(fValues[i]) Or IsInfinite(fValues[i]) Then
      Continue;
     Values[i] := fValues[i];
     Inc(Result);
    End;
  End;
{$IFDEF PORT_TEST}

 Procedure TAircraftLVarReader.Feed(p : Pointer; Size : DWORD; NowTick : UInt64);
  Begin
   Receive(p, Size, NowTick);
  End;
{$ENDIF}

End.
