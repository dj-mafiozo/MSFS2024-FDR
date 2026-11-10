Library MockPMDG777Sim;

Uses
 Winapi.Windows, System.SysUtils, System.Math, PMDG777CatalogU;

Const
 AreaIDs : Array [0..3] Of DWORD = (PMDG777DataID, PMDG777CDU0ID, PMDG777CDU1ID, PMDG777CDU2ID);
 DefIDs : Array [0..3] Of DWORD = (PMDG777DataDefinition, PMDG777CDU0Definition, PMDG777CDU1Definition, PMDG777CDU2Definition);
 Sizes : Array [0..3] Of Integer = (PMDG777DataSize, PMDG777CDUSize, PMDG777CDUSize, PMDG777CDUSize);
 Names : Array [0..3] Of String = ('PMDG_777X_Data', 'PMDG_777X_CDU_0', 'PMDG_777X_CDU_1', 'PMDG_777X_CDU_2');

Var
 Mode     : Integer;
 Maps     : Integer;
 Defs     : Integer;
 Requests : Integer;
 Opens    : Integer;
 Closes   : Integer;
 Writes   : Integer;
 Errors   : Integer;
 Queue    : Integer;
 LastSend : DWORD;
 Streams  : Array [0..3] Of DWORD;
 Packet   : Array [0..40 + PMDG777CDUSize - 1] Of Byte;

Procedure PMDGMockReset(m : Integer); Stdcall;
 Begin
  Mode     := m;
  Maps     := 0;
  Defs     := 0;
  Requests := 0;
  Opens    := 0;
  Closes   := 0;
  Writes   := 0;
  Errors   := 0;
  Queue    := 0;
  LastSend := 0;
 End;

Function PMDGMockCount(Kind : Integer) : Integer; Stdcall;
 Begin
  Case Kind Of
   0 : Result := Maps;
   1 : Result := Defs;
   2 : Result := Requests;
   3 : Result := Writes;
   4 : Result := Closes;
  Else Result := Errors;
  End;
 End;

Function SimConnect_Open(Var h : THandle; n : PAnsiChar; w : HWND; e : DWORD; EH : THandle; c : DWORD) : HRESULT; Stdcall;
 Begin
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

Function SimConnect_MapClientDataNameToID(h : THandle; n : PAnsiChar; ID : DWORD) : HRESULT; Stdcall;
 Var
  i : Integer;
 Begin
  Inc(Maps);
  Inc(LastSend);
  Result := 0;
  For i  := 0 To 3 Do
   If (ID = AreaIDs[i]) And (String(AnsiString(n)) = Names[i]) Then
    Exit;
  Inc(Errors);
  Result := HRESULT($80004005);
 End;

Function SimConnect_AddToClientDataDefinition(h : THandle; ID, Offset, Size : DWORD; Epsilon : Single; DatumID : DWORD) : HRESULT; Stdcall;
 Var
  i : Integer;
 Begin
  Inc(Defs);
  Inc(LastSend);
  Result := 0;
  For i  := 0 To 3 Do
   If (ID = DefIDs[i]) And (Offset = 0) And (Size = DWORD(Sizes[i])) Then
    Exit;
  Inc(Errors);
  Result := HRESULT($80004005);
 End;

Function SimConnect_RequestClientData(h : THandle; ID, RequestID, Definition, Period, Flags, Origin, Interval, Limit : DWORD) : HRESULT; Stdcall;
 Var
  i : Integer;
 Begin
  Inc(Requests);
  Inc(LastSend);
  Result := 0;
  For i  := 0 To 3 Do
   If (ID = AreaIDs[i]) And (Definition = DefIDs[i]) And (Flags = 0) Then
    Begin
     If (RequestID = DWORD(7000 + i)) And (Period = 3) Then
      Begin
       Streams[i] := LastSend;
       Exit;
      End;
     If (RequestID = DWORD(7100 + i)) And (Period = 1) Then
      Exit;
    End;
  Inc(Errors);
  Result := HRESULT($80004005);
 End;

Procedure PutD(Offset : Integer; Value : DWORD);
 Begin
  Move(Value, Packet[Offset], 4);
 End;

Procedure PutField(Const Name : String; Value : Double; Const Text : AnsiString = '');
 Var
  i  : Integer;
  k  : Integer;
  f  : TPMDG777Field;
  v  : Single;
  w  : Word;
  SW : SmallInt;
  d  : Cardinal;
  SD : Integer;
 Begin
  For i := 0 To PMDG777FieldCount - 1 Do
   If PMDG777Fields[i].Name = Name Then
    Begin
     f := PMDG777Fields[i];
     k := 40 + f.Offset;
     If f.Kind = 'f32' Then
      Begin
       v := Value;
       Move(v, Packet[k], 4);
      End
     Else If f.Kind = 'u16' Then
      Begin
       w := Round(Value);
       Move(w, Packet[k], 2);
      End
     Else If f.Kind = 'i16' Then
      Begin
       SW := Round(Value);
       Move(SW, Packet[k], 2);
      End
     Else If f.Kind = 'u32' Then
      Begin
       d := Round(Value);
       Move(d, Packet[k], 4);
      End
     Else If f.Kind = 'i32' Then
      Begin
       SD := Round(Value);
       Move(SD, Packet[k], 4);
      End
     Else If f.Kind = 'text' Then
      Begin
       If Length(Text) > 0 Then
        Move(Text[1], Packet[k], Min(Length(Text), f.Size));
      End
     Else
      Packet[k] := Round(Value);
     Exit;
    End;
  Inc(Errors);
 End;

Function SimConnect_GetNextDispatch(h : THandle; Var p : Pointer; Var Size : DWORD) : HRESULT; Stdcall;
 Var
  a      : Integer;
  Row    : Integer;
  Col    : Integer;
  Offset : Integer;
  i      : Integer;
  Text   : AnsiString;
 Begin
  Result := HRESULT($80004005);
  If (Mode = 6) Or (Queue >= 4) Then
   Exit;
  a := Queue;
  Inc(Queue);
  If (Mode = 1) And (a = 2) Then
   Exit;
  FillChar(Packet, SizeOf(Packet), 0);
  p      := @Packet[0];
  Result := 0;
  If Mode = 5 Then
   Begin
    PutD(8, 3);
    Size  := 12;
    Queue := 4;
    Exit;
   End;
  If ((Mode = 3) And (a = 0)) Or ((Mode = 15) And (a = 2)) Then
   Begin
    PutD(8, 1);
    PutD(12, 3);
    PutD(16, Streams[a]);
    Size := 24;
    Exit;
   End;
  Size := 40 + Sizes[a];
  PutD(0, Size);
  PutD(8, 16);
  PutD(12, 7100 + a);
  PutD(16, AreaIDs[a]);
  PutD(20, DefIDs[a]);
  PutD(36, 1);
  If (Mode = 4) And (a = 0) Then
   Begin
    Dec(Size);
    Exit;
   End;
  If a = 0 Then
   Begin
    PutField('CDU_annunEXEC[0]', 1);
    PutField('CDU_annunMSG[0]', 1);
    PutField('CDU_annunDSPY[2]', 1);
    PutField('AircraftModel', 6);
    PutField('FMC_V1', 135);
    PutField('FMC_VR', 140);
    PutField('FMC_V2', 145);
    PutField('FMC_LandingVREF', 130);
    PutField('FMC_TakeoffFlaps', 5);
    PutField('FMC_LandingFlaps', 30);
    PutField('FMC_CruiseAlt', 37000);
    PutField('FMC_LandingAltitude', -150);
    PutField('FMC_PerfInputComplete', 1);
    PutField('FMC_DistanceToTOD', 0);
    PutField('FMC_DistanceToDest', 123.5);
    PutField('MCP_annunAP[0]', 1);
    PutField('MCP_annunAP[1]', 1);
    PutField('MCP_ATArm_Sw_On[0]', 1);
    PutField('MCP_FD_Sw_On[0]', 1);
    PutField('MCP_IASMach', 175);
    PutField('MCP_Heading', 251);
    PutField('MCP_Altitude', 5000);
    PutField('MCP_VertSpeed', -700);
    PutField('GEAR_Lever', 1);
    PutField('FUEL_QtyAux', 1250.5);
    PutField('FUEL_QtyCenter', 1000);
    PutField('FUEL_QtyLeft', 2000);
    PutField('FUEL_QtyRight', 2000);
    PutField('FMC_flightNumber', 0, 'LOT123');
    PutField('COMM_ReceiverSwitches[0]', $F1234567);
    If Mode = 2 Then
     Begin
      PutField('FUEL_QtyAux', NaN);
      PutField('MCP_IASBlank', 255);
     End;
    If Mode = 7 Then
     Begin
      PutField('FMC_V1', 0);
      PutField('FMC_VR', 0);
      PutField('FMC_V2', 0);
      PutField('FMC_LandingVREF', 0);
      PutField('FMC_CruiseAlt', 0);
      PutField('FMC_LandingAltitude', -32767);
      PutField('FMC_DistanceToTOD', -1);
      PutField('FMC_DistanceToDest', -2);
     End;
    If Mode = 8 Then
     PutField('GEAR_Lever', 1);
    If Mode = 9 Then
     PutField('MCP_IASMach', 0.78);
    If Mode = 10 Then
     If Mode = 11 Then
      PutField('AircraftModel', 0);
    If Mode = 12 Then
     Begin
      PutField('MCP_IASBlank', 1);
      PutField('MCP_VertSpeedBlank', 1);
     End;
   End
  Else
   Begin
    For Col                             := 0 To 33 Do
     For Row                            := 0 To 13 Do
      Packet[40 + (Col * 14 + Row) * 3] := 32;
    If a = 1 Then
     Text := 'PMDG CAPTAIN'
    Else If a = 2 Then
     Text := 'PMDG FIRST OFFICER'
    Else
     Text := 'PMDG CENTER';
    For i := 1 To Length(Text) Do
     Begin
      Offset         := 40 + ((i - 1) * 14) * 3;
      Packet[Offset] := Byte(Text[i]);
     End;
    Packet[40 + 3]    := $A1;
    Packet[40 + 4]    := 1;
    Packet[40 + 5]    := 1;
    Packet[40 + 1008] := 1;
    If Mode = 13 Then
     Packet[40 + 1008] := 0;
   End;
 End;

Function SimConnect_SetClientData : HRESULT; Stdcall;
 Begin
  Inc(Writes);
  Result := HRESULT($80004005);
 End;

Function SimConnect_TransmitClientEvent : HRESULT; Stdcall;
 Begin
  Inc(Writes);
  Result := HRESULT($80004005);
 End;

Exports
 SimConnect_Open, SimConnect_Close, SimConnect_GetLastSentPacketID, SimConnect_MapClientDataNameToID, SimConnect_AddToClientDataDefinition,
 SimConnect_RequestClientData, SimConnect_GetNextDispatch, SimConnect_SetClientData, SimConnect_TransmitClientEvent, PMDGMockReset, PMDGMockCount;

Begin
 PMDGMockReset(0);

End.
