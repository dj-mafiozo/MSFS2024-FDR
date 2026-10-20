Unit PMDGNG3ReaderU;

Interface

 Uses
  Winapi.Windows, System.SysUtils, System.Generics.Collections, PMDGNG3CatalogU, LocalizationU;

 Type
  TPMDGNG3Reader = Class
   Private
    fLib        : HMODULE;
    fHandle     : THandle;
    fDLL        : String;
    fError      : String;
    fNextRetry  : UInt64;
    fCheckAt    : UInt64;
    fBuffers    : Array [0 .. 2] Of TBytes;
    fSeen       : Array [0 .. 2] Of Boolean;
    fFailed     : Array [0 .. 2] Of Boolean;
    fUpdated    : Array [0 .. 2] Of UInt64;
    fPacketArea : TDictionary<DWORD, Integer>;
    fOpen       : Function(Var H : THandle; N : PAnsiChar; W : HWND; E : DWORD; EH : THandle; C : DWORD) : HRESULT; Stdcall;
    fClose      : Function(H : THandle) : HRESULT; Stdcall;
    fMap        : Function(H : THandle; Name : PAnsiChar; ID : DWORD) : HRESULT; Stdcall;
    fAdd        : Function(H : THandle; ID, Offset, Size : DWORD; Epsilon : Single; DatumID : DWORD) : HRESULT; Stdcall;
    fRequest    : Function(H : THandle; ID, RequestID, Definition, Period, Flags, Origin, Interval, Limit : DWORD) : HRESULT; Stdcall;
    fNext       : Function(H : THandle; Var P : Pointer; Var Size : DWORD) : HRESULT; Stdcall;
    fLast       : Function(H : THandle; Var ID : DWORD) : HRESULT; Stdcall;
    Procedure Track(Area : Integer);
    Procedure Connect;
    Procedure Receive(P : Pointer; Size : DWORD; NowTick : UInt64);
   Public
    Constructor Create(Const DLL : String = '');
    Destructor Destroy; Override;
    Procedure Close;
    Procedure Tick;
    Function Snapshot(Area : Integer; Out Data : TBytes; Out AgeMS : UInt64) : Boolean;
    Property LastError : String Read fError;
    {$IFDEF PORT_TEST} Procedure Feed(P : Pointer; Size : DWORD; NowTick : UInt64); {$ENDIF}
  End;

 Const
  PMDGAreaIDs : Array [0 .. 2] Of DWORD         = (PMDGDataID, PMDGCDU0ID, PMDGCDU1ID);
  PMDGAreaDefinitions : Array [0 .. 2] Of DWORD = (PMDGDataDefinition, PMDGCDU0Definition, PMDGCDU1Definition);
  PMDGAreaSizes : Array [0 .. 2] Of Integer     = (PMDGDataSize, PMDGCDUSize, PMDGCDUSize);
  PMDGAreaNames : Array [0 .. 2] Of String      = (PMDGDataName, 'PMDG_NG3_CDU_0', 'PMDG_NG3_CDU_1');

Implementation

 Constructor TPMDGNG3Reader.Create(Const DLL : String);
  Begin
   Inherited Create;
   fDLL := DLL;
   If fDLL = '' Then
    fDLL       := ExtractFilePath(ParamStr(0)) + 'SimConnect.dll';
   fPacketArea := TDictionary<DWORD, Integer>.Create;
  End;

 Destructor TPMDGNG3Reader.Destroy;
  Begin
   Close;
   fPacketArea.Free;
   Inherited;
  End;

 Procedure TPMDGNG3Reader.Close;
  Var
   i : Integer;
  Begin
   If (fHandle <> 0) And Assigned(fClose) Then
    fClose(fHandle);
   fHandle := 0;
   If fLib <> 0 Then
    FreeLibrary(fLib);
   fLib  := 0;
   For i := 0 To 2 Do
    Begin
     fBuffers[i] := Nil;
     fSeen[i]    := False;
     fFailed[i]  := False;
     fUpdated[i] := 0;
    End;
   fPacketArea.Clear;
   fNextRetry := 0;
   fCheckAt   := 0;
  End;

 Procedure TPMDGNG3Reader.Track(Area : Integer);
  Var
   ID : DWORD;
  Begin
   If Assigned(fLast) And (fLast(fHandle, ID) >= 0) Then
    fPacketArea.AddOrSetValue(ID, Area);
  End;

 Procedure TPMDGNG3Reader.Connect;
  Var
   i  : Integer;
   N  : AnsiString;
   HR : HRESULT;
  Begin
   fLib := LoadLibraryEx(PChar(fDLL), 0, LOAD_WITH_ALTERED_SEARCH_PATH);
   If fLib = 0 Then
    RaiseLastOSError;
   @fOpen    := GetProcAddress(fLib, 'SimConnect_Open');
   @fClose   := GetProcAddress(fLib, 'SimConnect_Close');
   @fMap     := GetProcAddress(fLib, 'SimConnect_MapClientDataNameToID');
   @fAdd     := GetProcAddress(fLib, 'SimConnect_AddToClientDataDefinition');
   @fRequest := GetProcAddress(fLib, 'SimConnect_RequestClientData');
   @fNext    := GetProcAddress(fLib, 'SimConnect_GetNextDispatch');
   @fLast    := GetProcAddress(fLib, 'SimConnect_GetLastSentPacketID');
   If Not(Assigned(fOpen) And Assigned(fClose) And Assigned(fMap) And Assigned(fAdd) And Assigned(fRequest) And Assigned(fNext)) Then
    Raise Exception.Create(Tr('Incomplete SimConnect DLL for PMDG NG3 Client Data'));
   If fOpen(fHandle, 'MSFS FDR PMDG NG3 SDK (read only)', 0, 0, 0, 0) < 0 Then
    Raise Exception.Create(Tr('PMDG NG3 SDK connection failed'));
   fCheckAt := GetTickCount64 + 30000;
   For i    := 0 To 2 Do
    Begin
     N  := AnsiString(PMDGAreaNames[i]);
     HR := fMap(fHandle, PAnsiChar(N), PMDGAreaIDs[i]);
     Track(i);
     If HR < 0 Then
      Begin
       fFailed[i] := True;
       fError     := 'PMDG SDK area mapping failed: ' + PMDGAreaNames[i];
       Continue;
      End;
     HR := fAdd(fHandle, PMDGAreaDefinitions[i], 0, PMDGAreaSizes[i], 0, $FFFFFFFF);
     Track(i);
     If HR < 0 Then
      Begin
       fFailed[i] := True;
       fError     := 'PMDG SDK definition failed: ' + PMDGAreaNames[i];
       Continue;
      End;
     // ON_SET receives SDK updates even when values happen to be unchanged.
     HR := fRequest(fHandle, PMDGAreaIDs[i], 7000 + i, PMDGAreaDefinitions[i], 3, 0, 0, 0, 0);
     Track(i);
     If HR < 0 Then
      Begin
       fFailed[i] := True;
       fError     := 'PMDG SDK subscription failed: ' + PMDGAreaNames[i];
       Continue;
      End;
     // Seed from the current block; later ON_SET updates replace it atomically.
     HR := fRequest(fHandle, PMDGAreaIDs[i], 7100 + i, PMDGAreaDefinitions[i], 1, 0, 0, 0, 0);
     Track(i);
     If HR < 0 Then
      fError := 'PMDG SDK initial request failed: ' + PMDGAreaNames[i];
    End;
  End;

 Procedure TPMDGNG3Reader.Receive(P : Pointer; Size : DWORD; NowTick : UInt64);
  Var
   ID     : DWORD;
   Req    : DWORD;
   Def    : DWORD;
   Flags  : DWORD;
   Count  : DWORD;
   Code   : DWORD;
   SendID : DWORD;
   Area   : Integer;
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
      If fPacketArea.TryGetValue(SendID, Area) Then
       Begin
        fFailed[Area] := True;
        fSeen[Area]   := False;
        fError        := Format('PMDG SDK %s: SimConnect exception %d', [PMDGAreaNames[Area], Code]);
       End;
     End;
    3 :
     Begin
      fError := 'Simulator disconnected';
      Close;
      fNextRetry := NowTick + 2000;
     End;
    16 :
     Begin
      If Size < 40 Then
       Exit;
      Move(PByte(NativeUInt(P) + 12)^, Req, 4);
      Move(PByte(NativeUInt(P) + 20)^, Def, 4);
      Move(PByte(NativeUInt(P) + 24)^, Flags, 4);
      Move(PByte(NativeUInt(P) + 36)^, Count, 4);
      For Area := 0 To 2 Do
       If ((Req = DWORD(7000 + Area)) Or (Req = DWORD(7100 + Area))) And (Def = PMDGAreaDefinitions[Area]) Then
        Begin
         If (Flags <> 0) Or (Count <> 1) Or (Size < DWORD(40 + PMDGAreaSizes[Area])) Or fFailed[Area] Then
          Exit;
         SetLength(fBuffers[Area], PMDGAreaSizes[Area]);
         Move(PByte(NativeUInt(P) + 40)^, fBuffers[Area][0], PMDGAreaSizes[Area]);
         fUpdated[Area] := NowTick;
         fSeen[Area]    := True;
         Exit;
        End;
     End;
   End;
  End;

 Procedure TPMDGNG3Reader.Tick;
  Var
   P       : Pointer;
   Size    : DWORD;
   i       : Integer;
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
    For i := 1 To 512 Do
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
    If (fHandle <> 0) And (NowTick >= fCheckAt) Then
     Begin
      fCheckAt := NowTick + 30000;
      If Not fSeen[0] Or fFailed[0] Then
       Begin
        fError := 'No PMDG NG3 data; check [SDK] EnableDataBroadcast=1';
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

 Function TPMDGNG3Reader.Snapshot(Area : Integer; Out Data : TBytes; Out AgeMS : UInt64) : Boolean;
  Var
   T : UInt64;
  Begin
   Data   := Nil;
   AgeMS  := 0;
   Result := (Area >= 0) And (Area <= 2);
   If Not Result Then
    Exit;
   Result := fSeen[Area] And Not fFailed[Area];
   If Not Result Then
    Exit;
   Data := Copy(fBuffers[Area]);
   T    := GetTickCount64;
   If T >= fUpdated[Area] Then
    AgeMS := T - fUpdated[Area];
  End;
 {$IFDEF PORT_TEST}

 Procedure TPMDGNG3Reader.Feed(P : Pointer; Size : DWORD; NowTick : UInt64);
  Begin
   Receive(P, Size, NowTick);
  End;
 {$ENDIF}

End.
