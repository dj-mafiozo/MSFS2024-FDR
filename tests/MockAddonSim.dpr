Library MockAddonSim;

Uses
 Winapi.Windows, System.SysUtils, System.Generics.Collections, System.Math;

Var
 Pending  : TQueue<DWORD>;
 Queued   : TDictionary<DWORD, Boolean>;
 Names    : TDictionary<DWORD, String>;
 Mode     : Integer;
 Requests : Integer;
 Writes   : Integer;
 Errors   : Integer;
 Maximum  : Integer;
 Serial   : Integer;
 Packet   : Array [0..47] Of Byte;

Procedure MockReset(m : Integer); Stdcall;
 Begin
  Mode     := m;
  Requests := 0;
  Writes   := 0;
  Errors   := 0;
  Maximum  := 0;
  Serial   := 0;
  Pending.Clear;
  Queued.Clear;
  Names.Clear;
 End;

Function MockCount(Kind : Integer) : Integer; Stdcall;
 Begin
  Case Kind Of
   0 : Result := Requests;
   1 : Result := Writes;
   2 : Result := Errors;
   3 : Result := Maximum;
  Else Result := Pending.Count;
  End;
 End;

Function SimConnect_Open(Var h : THandle; n : PAnsiChar; w : HWND; e : DWORD; EH : THandle; c : DWORD) : HRESULT; Stdcall;
 Begin
  h      := 1;
  Result := 0;
 End;

Function SimConnect_Close(h : THandle) : HRESULT; Stdcall;
 Begin
  Pending.Clear;
  Queued.Clear;
  Names.Clear;
  Result := 0;
 End;

Function SimConnect_GetLastSentPacketID(h : THandle; Var ID : DWORD) : HRESULT; Stdcall;
 Begin
  ID     := Serial;
  Result := 0;
 End;

Function SimConnect_AddToDataDefinition(h : THandle; ID : DWORD; n, u : PAnsiChar; t : DWORD; e : Single; d : DWORD) : HRESULT; Stdcall;
 Begin
  Inc(Serial);
  Result := 0;
  If Mode = 3 Then
   Begin
    If (String(AnsiString(u)) <> 'bool') Or (t <> 4) Or (String(AnsiString(n)) <> 'LIGHT NAV') Then
     Begin
      Inc(Errors);
      Result := HRESULT($80004005);
      Exit;
     End;
   End
  Else If (String(AnsiString(u)) <> 'number') Or (t <> 4) Or (Copy(String(AnsiString(n)), 1, 2) <> 'L:') Then
   Begin
    Inc(Errors);
    Result := HRESULT($80004005);
    Exit;
   End;
  If (Mode = 1) And (ID = 1003) Then
   Begin
    Result := HRESULT($80004005);
    Exit;
   End;
  Names.AddOrSetValue(ID, String(AnsiString(n)));
 End;

Function SimConnect_RequestDataOnSimObject(h : THandle; r, d, o, p, f, a, i, l : DWORD) : HRESULT; Stdcall;
 Begin
  Inc(Serial);
  Inc(Requests);
  Result := 0;
  If (p <> 1) Or (r <> d + 1000) Or (f <> 0) Or Not Names.ContainsKey(d) Then
   Begin
    Inc(Errors);
    Result := HRESULT($80004005);
    Exit;
   End;
  If Queued.ContainsKey(d) Then
   Inc(Errors)
  Else
   Begin
    Queued.Add(d, True);
    Pending.Enqueue(d);
   End;
  Maximum := Max(Maximum, Pending.Count);
 End;

Procedure PutD(At : Integer; v : DWORD);
 Begin
  Move(v, Packet[At], 4);
 End;

Function SimConnect_GetNextDispatch(h : THandle; Var p : Pointer; Var Size : DWORD) : HRESULT; Stdcall;
 Var
  d : DWORD;
  v : Double;
 Begin
  Result := HRESULT($80004005);
  If Pending.Count = 0 Then
   Exit;
  d := Pending.Dequeue;
  Queued.Remove(d);
  FillChar(Packet, SizeOf(Packet), 0);
  Size := SizeOf(Packet);
  PutD(0, Size);
  PutD(8, 8);
  PutD(12, d + 1000);
  PutD(20, d);
  PutD(36, 1);
  v := d - 999;
  If (Mode = 2) And (d = 1002) Then
   v := NaN;
  Move(v, Packet[40], 8);
  p      := @Packet[0];
  Result := 0;
 End;

Function SimConnect_SetDataOnSimObject : HRESULT; Stdcall;
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
 MockReset, MockCount, SimConnect_Open, SimConnect_Close, SimConnect_GetLastSentPacketID, SimConnect_AddToDataDefinition,
 SimConnect_RequestDataOnSimObject, SimConnect_GetNextDispatch, SimConnect_SetDataOnSimObject, SimConnect_TransmitClientEvent;

Begin
 Pending := TQueue<DWORD>.Create;
 Queued  := TDictionary<DWORD, Boolean>.Create;
 Names   := TDictionary<DWORD, String>.Create;
 MockReset(0);

End.
