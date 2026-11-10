Library MockFenixSim;

Uses
 Winapi.Windows, System.SysUtils, System.Math, FenixCatalogU, FBWCatalogU, AirlinerVarsU, AirlinerCatalogU, GSXVarsU;

Var
 IsAirliner : Boolean;
 IsFBW      : Boolean;
 IsGSX      : Boolean;
 Mode       : Integer;
 Adds       : Integer;
 Requests   : Integer;
 Opens      : Integer;
 Closes     : Integer;
 Writes     : Integer;
 Errors     : Integer;
 Queue      : Integer;
 LastSend   : DWORD;

 Counts : Array [0..FenixFieldCount - 1] Of Integer;

 RequestSend : Array [0..FenixFieldCount - 1] Of DWORD;

 Packet : Array [0..40 + FenixBatchSize * 8 - 1] Of Byte;

Function BlockSize : Integer;
 Begin
  If IsAirliner Or IsGSX Then
   Result := 1
  Else
   Result := FenixBatchSize;
 End;

Function FieldCount : Integer;
 Begin
  If IsGSX Then
   Result := GSXVarCount
  Else If IsAirliner Then
   Result := AirlinerVarCount
  Else If IsFBW Then
   Result := FBWFieldCount
  Else
   Result := FenixFieldCount;
 End;

Function BatchCount : Integer;
 Begin
  Result := (FieldCount + BlockSize - 1) Div BlockSize;
 End;

Function FieldName(i : Integer) : String;
 Begin
  If IsGSX Then
   Result := GSXNames[i]
  Else If IsAirliner Then
   Result := AirlinerNames[i]
  Else If IsFBW Then
   Result := FBWFields[i].Name
  Else
   Result := FenixFields[i].Name;
 End;

Procedure FenixMockReset(m : Integer); Stdcall;
 Begin
  IsGSX      := False;
  IsAirliner := False;
  IsFBW      := False;
  Mode       := m;
  Adds       := 0;
  Requests   := 0;
  Opens      := 0;
  Closes     := 0;
  Writes     := 0;
  Errors     := 0;
  Queue      := 0;
  LastSend   := 0;
  FillChar(Counts, SizeOf(Counts), 0);
 End;

Function FenixMockCount(Kind : Integer) : Integer; Stdcall;
 Begin
  Case Kind Of
   0 : Result := Adds;
   1 : Result := Requests;
   2 : Result := Opens;
   3 : Result := Closes;
   4 : Result := Writes;
  Else Result := Errors;
  End;
 End;

Function SimConnect_Open(Var h : THandle; n : PAnsiChar; w : HWND; e : DWORD; EH : THandle; c : DWORD) : HRESULT; Stdcall;
 Begin
  IsGSX      := Pos('GSX', String(AnsiString(n))) > 0;
  IsAirliner := Pos('AIRLINER', String(AnsiString(n))) > 0;
  IsFBW      := Pos('FBW', String(AnsiString(n))) > 0;
  Inc(Opens);
  h      := 1;
  Result := 0;
 End;

Function SimConnect_Close(h : THandle) : HRESULT; Stdcall;
 Begin
  Inc(Closes);
  Result := 0;
 End;

Function SimConnect_GetLastSentPacketID(h : THandle; Var ID : DWORD) : HRESULT; Stdcall;
 Begin
  ID     := LastSend;
  Result := 0;
 End;

Function SimConnect_AddToDataDefinition(h : THandle; ID : DWORD; n, u : PAnsiChar; t : DWORD; e : Single; d : DWORD) : HRESULT; Stdcall;
 Var
  b : Integer;
  i : Integer;
 Begin

  Inc(LastSend);
  Inc(Adds);
  Result := 0;
  b      := Integer(ID) - 1000;

  If (b < 0) Or (b >= BatchCount) Then
   Begin
    Inc(Errors);
    Exit;
   End;

  i := b * BlockSize + Counts[b];
  Inc(Counts[b]);

  If (i >= FieldCount) Or (String(AnsiString(n)) <> 'L:' + FieldName(i)) Or (String(AnsiString(u)) <> 'number') Or (t <> 4) Then
   Inc(Errors);

 End;

Function SimConnect_RequestDataOnSimObject(h : THandle; r, d, o, p, f, a, i, l : DWORD) : HRESULT; Stdcall;
 Var
  b : Integer;
 Begin

  Inc(LastSend);
  Inc(Requests);
  b      := Integer(d) - 1000;
  Result := 0;

  If (b < 0) Or (b >= BatchCount) Then
   Begin
    Inc(Errors);
    Exit;
   End;

  RequestSend[b] := LastSend;
  If (r <> 2000 + DWORD(b)) Or (p <> 3) Or (o <> 0) Or (f <> 0) Then
   Inc(Errors);

 End;

Procedure Put(Offset : Integer; Value : DWORD);
 Begin
  Move(Value, Packet[Offset], 4);
 End;

Function SimConnect_GetNextDispatch(h : THandle; Var p : Pointer; Var Size : DWORD) : HRESULT; Stdcall;
 Var
  b    : Integer;
  i    : Integer;
  n    : Integer;
  v    : Double;
  Name : String;
 Begin

  Result := HRESULT($80004005);
  If (Mode = 6) Or (Queue >= BatchCount) Then
   Exit;

  b := Queue;
  Inc(Queue);
  If (Mode = 1) And (b = BatchCount - 1) Then
   Exit;

  FillChar(Packet, SizeOf(Packet), 0);
  p      := @Packet[0];
  Result := 0;

  If (Mode = 5) Then
   Begin
    Put(8, 3);
    Size  := 12;
    Queue := BatchCount;
    Exit;
   End;

  If (Mode = 3) And (b = 0) Then
   Begin
    Put(8, 1);
    Put(12, 3);
    Put(16, RequestSend[0]);
    Size := 24;
    Exit;
   End;

  n    := Min(BlockSize, FieldCount - b * BlockSize);
  Size := 40 + n * 8;

  Put(0, Size);
  Put(8, 8);
  Put(12, 2000 + b);
  Put(20, 1000 + b);
  Put(36, n);

  If (Mode = 4) And (b = 0) Then
   Put(36, n + 1);

  For i := 0 To n - 1 Do
   Begin

    Name := FieldName(b * BlockSize + i);
    v    := 0;

    If Name = 'S_MIP_GEAR' Then
     v := 1
    Else If Name = 'S_FC_FLAPS' Then
     v := 3

    Else If Name = 'A_FC_THROTTLE_LEFT_INPUT' Then
     v := 3
    Else If Name = 'I_FCU_AP1' Then
     v := 1;

    If IsAirliner Then
     Begin

      If Name = 'AIRLINER_V1_SPEED' Then
       v := 135
      Else If Name = 'AIRLINER_VR_SPEED' Then
       v := 140
      Else If Name = 'AIRLINER_V2_SPEED' Then
       v := 145

      Else If Name = 'AIRLINER_MINIMUM_DESCENT_ALTITUDE' Then
       v := 420
      Else
       v := 200;

     End;

    If IsGSX Then
     Begin
      If Pos('_STATE', Name) > 0 Then
       v := 5
      Else If Name = 'FSDT_VAR_Frozen' Then
       v := 1
      Else
       v := 42;
     End;

    If IsFBW Then
     Begin

      If Name = 'A32NX_IS_READY' Then
       v := 1

      Else If Name = 'A32NX_FLAPS_HANDLE_INDEX' Then
       v := 3

      Else If Name = 'A32NX_AUTOTHRUST_STATUS' Then
       v := 2

      Else If Name = 'A32NX_SPEEDS_VAPP' Then
       v := 138

      Else If Name = 'A32NX_SPEEDS_MANAGED_PFD' Then
       v := 145

      Else If Name = 'A32NX_FCU_AFS_DISPLAY_SPD_MACH_VALUE' Then
       Begin
        If Mode = 9 Then
         v := 0.78
        Else
         v := 180;
       End

      Else If Name = 'A32NX_FCU_AFS_DISPLAY_MACH_MODE' Then
       v := Ord(Mode = 9)

      Else If Name = 'A32NX_FCU_AP_1_LIGHT_ON' Then
       v := 1;

      If (Mode = 8) And (Name = 'A32NX_IS_READY') Then
       v := 0;

      If (Mode = 10) And (Name = 'A32NX_FCU_AFS_DISPLAY_SPD_MACH_DASHES') Then
       v := 1;

     End;

    If (Mode = 2) And ((Name = 'S_MIP_GEAR') Or (Name = 'A32NX_AUTOTHRUST_STATUS') Or (Name = 'AIRLINER_V1_SPEED') Or (Name = 'FSDT_GSX_BOARDING_STATE')) Then
     v := NaN;

    If Mode = 7 Then
     v := 0;
    Move(v, Packet[40 + i * 8], 8);

   End;

 End;

Function SimConnect_SetDataOnSimObject : HRESULT; Stdcall;
 Begin
  Inc(Writes);
  Result := HRESULT($80004005);
 End;

Exports
 SimConnect_Open, SimConnect_Close, SimConnect_GetLastSentPacketID, SimConnect_AddToDataDefinition,

 SimConnect_RequestDataOnSimObject, SimConnect_GetNextDispatch, SimConnect_SetDataOnSimObject, FenixMockReset, FenixMockCount;

Begin
 FenixMockReset(0);

End.
