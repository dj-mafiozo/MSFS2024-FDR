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
    fBatchSize    : Integer;
    fLib          : HMODULE;
    fHandle       : THandle;
    fDLL          : String;
    fError        : String;
    fClientName   : String;
    fNames        : TArray<String>;
    fNextRetry    : UInt64;
    fCheckFreshAt : UInt64;
    fValues       : TArray<Double>;
    fUpdated      : TArray<UInt64>;
    fSeen         : TArray<Boolean>;
    fFailed       : TArray<Boolean>;
    fPacketBatch  : TDictionary<DWORD, Integer>;
    fOpen         : Function(Var H : THandle; N : PAnsiChar; W : HWND; E : DWORD; EH : THandle; C : DWORD) : HRESULT; Stdcall;
    fClose        : Function(H : THandle) : HRESULT; Stdcall;
    fAdd          : Function(H : THandle; ID : DWORD; N, U : PAnsiChar; T : DWORD; E : Single; D : DWORD) : HRESULT; Stdcall;
    fRequest      : Function(H : THandle; R, D, O, P, F, A, I, L : DWORD) : HRESULT; Stdcall;
    fNext         : Function(H : THandle; Var P : Pointer; Var Size : DWORD) : HRESULT; Stdcall;
    fLast         : Function(H : THandle; Var ID : DWORD) : HRESULT; Stdcall;
    Procedure Connect;
    Procedure Track(Batch : Integer);
    Procedure Receive(P : Pointer; Size : DWORD; NowTick : UInt64);
   Public
    Constructor Create(Const Names : TArray<String>; Const ClientName : String; Const DLL : String = ''; BatchSize : Integer = LVarBatchSize);
    Destructor Destroy; Override;
    Procedure Close;
    Procedure Tick;
    Function Snapshot(Out Values : TArray<Double>; Out AgeMS : UInt64; MaxAgeMS : UInt64) : Integer;
    Property LastError : String Read fError;
    {$IFDEF PORT_TEST} Procedure Feed(P : Pointer; Size : DWORD; NowTick : UInt64); {$ENDIF}
  End;

Implementation

 Constructor TAircraftLVarReader.Create(Const Names : TArray<String>; Const ClientName, DLL : String; BatchSize : Integer);
  Begin
   Inherited Create;
   fBatchSize  := EnsureRange(BatchSize, 1, LVarBatchSize);
   fNames      := Copy(Names);
   fClientName := ClientName;
   fDLL        := DLL;
   If fDLL = '' Then
    fDLL        := ExtractFilePath(ParamStr(0)) + 'SimConnect.dll';
   fPacketBatch := TDictionary<DWORD, Integer>.Create;
   SetLength(fValues, Length(fNames));
   SetLength(fUpdated, (Length(fNames) + fBatchSize - 1) Div fBatchSize);
   SetLength(fSeen, Length(fUpdated));
   SetLength(fFailed, Length(fUpdated));
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
   I : Integer;
  Begin
   If (fHandle <> 0) And Assigned(fClose) Then
    fClose(fHandle);
   fHandle := 0;
   If fLib <> 0 Then
    FreeLibrary(fLib);
   fLib  := 0;
   For I := 0 To High(fUpdated) Do
    Begin
     fSeen[I]    := False;
     fFailed[I]  := False;
     fUpdated[I] := 0;
    End;
   For I       := 0 To High(fValues) Do
    fValues[I] := NaN;
   fPacketBatch.Clear;
   fNextRetry    := 0;
   fCheckFreshAt := 0;
  End;

 Procedure TAircraftLVarReader.Track(Batch : Integer);
  Var
   ID : DWORD;
  Begin
   If Assigned(fLast) And (fLast(fHandle, ID) >= 0) Then
    fPacketBatch.AddOrSetValue(ID, Batch);
  End;

 Procedure TAircraftLVarReader.Connect;
  Var
   I  : Integer;
   B  : Integer;
   N  : AnsiString;
   HR : HRESULT;
  Begin
   fLib := LoadLibraryEx(PChar(fDLL), 0, LOAD_WITH_ALTERED_SEARCH_PATH);
   If fLib = 0 Then
    RaiseLastOSError;
   @fOpen    := GetProcAddress(fLib, 'SimConnect_Open');
   @fClose   := GetProcAddress(fLib, 'SimConnect_Close');
   @fAdd     := GetProcAddress(fLib, 'SimConnect_AddToDataDefinition');
   @fRequest := GetProcAddress(fLib, 'SimConnect_RequestDataOnSimObject');
   @fNext    := GetProcAddress(fLib, 'SimConnect_GetNextDispatch');
   @fLast    := GetProcAddress(fLib, 'SimConnect_GetLastSentPacketID');
   If Not(Assigned(fOpen) And Assigned(fClose) And Assigned(fAdd) And Assigned(fRequest) And Assigned(fNext)) Then
    Raise Exception.Create(Tr('Incomplete SimConnect DLL for aircraft L-vars'));
   N := AnsiString(fClientName);
   If fOpen(fHandle, PAnsiChar(N), 0, 0, 0, 0) < 0 Then
    Raise Exception.Create(Tr('aircraft SimConnect open failed'));
   fCheckFreshAt := GetTickCount64 + 30000;
   For I         := 0 To Length(fNames) - 1 Do
    Begin
     B  := I Div fBatchSize;
     N  := AnsiString('L:' + fNames[I]);
     HR := fAdd(fHandle, 1000 + B, PAnsiChar(N), 'number', 4, 0, $FFFFFFFF);
     Track(B);
     If HR < 0 Then
      Begin
       fFailed[B] := True;
       fError     := 'aircraft L-var definition rejected: ' + fNames[I];
      End;
    End;
   For B := 0 To Length(fUpdated) - 1 Do
    If Not fFailed[B] Then
     Begin
      // SIM_FRAME provides the latest data; persistence still follows the configured millisecond interval.
      HR := fRequest(fHandle, 2000 + B, 1000 + B, 0, 3, 0, 0, 0, 0);
      Track(B);
      If HR < 0 Then
       Begin
        fFailed[B] := True;
        fError     := 'aircraft L-var request rejected';
       End;
     End;
  End;

 Procedure TAircraftLVarReader.Receive(P : Pointer; Size : DWORD; NowTick : UInt64);
  Var
   ID, Req, Def, Flags, Count, SendID, Code : DWORD;
   B, I, N                                  : Integer;
   V                                        : Double;
  Begin
   If (P = Nil) Or (Size < 12) Then
    Exit;
   Move(PByte(NativeUInt(P) + 8)^, ID, 4);
   Case ID Of
    1 :
     Begin
      If Size < 24 Then
       Exit;
      Move(PByte(NativeUInt(P) + 12)^, Code, 4);
      Move(PByte(NativeUInt(P) + 16)^, SendID, 4);
      If fPacketBatch.TryGetValue(SendID, B) Then
       Begin
        fFailed[B] := True;
        fSeen[B]   := False;
        fError     := Format('aircraft L-vars batch %d: SimConnect exception %d', [B, Code]);
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
      Move(PByte(NativeUInt(P) + 12)^, Req, 4);
      Move(PByte(NativeUInt(P) + 20)^, Def, 4);
      Move(PByte(NativeUInt(P) + 24)^, Flags, 4);
      Move(PByte(NativeUInt(P) + 36)^, Count, 4);
      If (Def < 1000) Or (Def >= 1000 + Length(fUpdated)) Then
       Exit;
      B := Def - 1000;
      N := Min(fBatchSize, Length(fNames) - B * fBatchSize);
      If (Req <> DWORD(2000 + B)) Or (Flags <> 0) Or (Count <> DWORD(N)) Or (Size < DWORD(40 + N * 8)) Or fFailed[B] Then
       Exit;
      For I := 0 To N - 1 Do
       Begin
        Move(PByte(NativeUInt(P) + 40 + NativeUInt(I * 8))^, V, 8);
        fValues[B * fBatchSize + I] := V;
       End;
      fUpdated[B] := NowTick;
      fSeen[B]    := True;
     End;
   End;
  End;

 Procedure TAircraftLVarReader.Tick;
  Var
   P       : Pointer;
   Size    : DWORD;
   I       : Integer;
   Fresh   : Boolean;
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
    For I := 1 To 512 Do
     Begin
      If fHandle = 0 Then
       Break;
      P    := Nil;
      Size := 0;
      If fNext(fHandle, P, Size) < 0 Then
       Break;
      Receive(P, Size, GetTickCount64);
     End;
    NowTick := GetTickCount64;
    If (fHandle <> 0) And (NowTick >= fCheckFreshAt) Then
     Begin
      Fresh := False;
      For I := 0 To Length(fUpdated) - 1 Do
       If fSeen[I] And Not fFailed[I] And (NowTick >= fUpdated[I]) And (NowTick - fUpdated[I] < 5000) Then
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
    On E : Exception Do
     Begin
      fError := E.Message;
      Close;
      fNextRetry := GetTickCount64 + 2000;
     End;
   End;
  End;

 Function TAircraftLVarReader.Snapshot(Out Values : TArray<Double>; Out AgeMS : UInt64; MaxAgeMS : UInt64) : Integer;
  Var
   I, B         : Integer;
   NowTick, Age : UInt64;
  Begin
   SetLength(Values, Length(fNames));
   Result  := 0;
   AgeMS   := 0;
   NowTick := GetTickCount64;
   For I   := 0 To Length(fNames) - 1 Do
    Begin
     Values[I] := NaN;
     B         := I Div fBatchSize;
     If Not fSeen[B] Or fFailed[B] Or (NowTick < fUpdated[B]) Then
      Continue;
     Age := NowTick - fUpdated[B];
     If Age > MaxAgeMS Then
      Continue;
     If Age > AgeMS Then
      AgeMS := Age;
     If IsNan(fValues[I]) Or IsInfinite(fValues[I]) Then
      Continue;
     Values[I] := fValues[I];
     Inc(Result);
    End;
  End;
 {$IFDEF PORT_TEST}

 Procedure TAircraftLVarReader.Feed(P : Pointer; Size : DWORD; NowTick : UInt64);
  Begin
   Receive(P, Size, NowTick);
  End;
 {$ENDIF}

End.
