Library MockGhostSim;

Uses
 TestPathsU, Winapi.Windows, System.SysUtils, System.Generics.Collections;

Type
 TInit = Packed Record
  v      : Array[0..5]Of Double;
  Ground : DWORD;
  Speed  : DWORD;
 End;

Var
 Queue      : TQueue<TBytes>;
 Current    : TBytes;
 Owner      : DWORD;
 Packet     : DWORD;
 FreezeMask : DWORD;
 c          : Array[0..9]Of Integer;
 Old        : Boolean;

Procedure Put(Var b : TBytes; o : Integer; v : DWORD);
 Begin
  Move(v, b[o], 4);
 End;

Function Counter(i : Integer) : Integer; Stdcall;
 Begin
  Result := c[i];
 End;

Procedure Reset(v : BOOL); Stdcall;
 Begin
  FillChar(c, SizeOf(c), 0);
  FreezeMask := 0;
  Packet     := 0;
  Owner      := 0;
  Queue.Clear;
  Old := v;
 End;

Procedure Own;
 Begin
  If GetCurrentThreadID <> Owner Then
   Inc(c[9]);
 End;

Function SimConnect_Open(Var h : THandle; n : PAnsiChar; w : HWND; e : DWORD; EH : THandle; Conf : DWORD) : HRESULT; Stdcall;
 Var
  b : TBytes;
  s : AnsiString;
 Begin
  Owner := GetCurrentThreadID;
  h     := 123;
  Inc(c[0]);
  SetLength(b, 308);
  Put(b, 0, 308);
  Put(b, 8, 2);
  Put(b, 268, 12);
  s := 'SunRise';
  If Old Then
   Begin
    s := 'KittyHawk';
    Put(b, 268, 11);
   End;
  Move(s[1], b[12], Length(s));
  Queue.Enqueue(b);
  Result := 0;
 End;

Function SimConnect_Close(h : THandle) : HRESULT; Stdcall;
 Begin
  Own;
  Inc(c[1]);
  Result := 0;
 End;

Function SimConnect_GetNextDispatch(h : THandle; Var p : Pointer; Var Size : DWORD) : HRESULT; Stdcall;
 Begin
  Own;
  p    := Nil;
  Size := 0;
  If Queue.Count = 0 Then
   Exit(HRESULT($80004005));
  Current := Queue.Dequeue;
  p       := @Current[0];
  Size    := Length(Current);
  Result  := 0;
 End;

Function SimConnect_EnumerateSimObjectsAndLiveries(h : THandle; r, t : DWORD) : HRESULT; Stdcall;
 Var
  b : TBytes;
  s : AnsiString;
 Begin
  Own;
  Inc(c[2]);
  SetLength(b, 28 + 3 * 512);
  Put(b, 0, Length(b));
  Put(b, 8, 38);
  Put(b, 12, r);
  Put(b, 16, 3);
  Put(b, 24, 1);
  s := 'FSLTL_A320_TEST';
  Move(s[1], b[28], Length(s));
  s := 'AIPlane_A320';
  Move(s[1], b[540], Length(s));
  s := 'AIGAIM_A320_LOT';
  Move(s[1], b[1052], Length(s));
  Queue.Enqueue(b);
  Inc(Packet);
  Result := 0;
 End;

Function SimConnect_AICreateNonATCAircraft_EX1(h : THandle; t, l, n : PAnsiChar; Init : TInit; r : DWORD) : HRESULT; Stdcall;
 Var
  b : TBytes;
 Begin
  Own;
  Inc(c[3]);
  If (String(t) <> 'FSLTL_A320_TEST') And (String(t) <> 'AIPlane_A320') And (String(t) <> 'AIGAIM_A320_LOT') Then
   Exit(HRESULT($80004005));
  SetLength(b, 20);
  Put(b, 0, 20);
  Put(b, 8, 12);
  Put(b, 12, r);
  Put(b, 16, 900);
  Queue.Enqueue(b);
  Inc(Packet);
  Result := 0;
 End;

Function SimConnect_AIReleaseControl(h : THandle; o, r : DWORD) : HRESULT; Stdcall;
 Begin
  Own;
  If o <> 900 Then
   Exit(HRESULT($80004005));
  Inc(c[4]);
  Inc(Packet);
  Result := 0;
 End;

Function SimConnect_AIRemoveObject(h : THandle; o, r : DWORD) : HRESULT; Stdcall;
 Begin
  Own;
  If o <> 900 Then
   Exit(HRESULT($80004005));
  Inc(c[5]);
  Inc(Packet);
  Result := 0;
 End;

Function SimConnect_AddToDataDefinition(h : THandle; d : DWORD; n, u : PAnsiChar; t : DWORD; e : Single; ID : DWORD) : HRESULT; Stdcall;
 Begin
  Own;
  Inc(Packet);
  Result := 0;
 End;

Function SimConnect_SetDataOnSimObject(h : THandle; d, o, f, n, Size : DWORD; p : Pointer) : HRESULT; Stdcall;
 Var
  b : TBytes;
 Begin
  Own;
  Inc(Packet);
  If (o <> 900) Or (FreezeMask <> 7) Then
   Exit(HRESULT($80004005));
  If d = 1 Then
   Inc(c[6])
  Else
   Begin
    Inc(c[7]);
    If c[7] = 1 Then
     Begin
      SetLength(b, 24);
      Put(b, 0, 24);
      Put(b, 8, 1);
      Put(b, 12, 20);
      Put(b, 16, Packet);
      Queue.Enqueue(b);
     End;
   End;
  Result := 0;
 End;

Function SimConnect_MapClientEventToSimEvent(h : THandle; e : DWORD; n : PAnsiChar) : HRESULT; Stdcall;
 Begin
  Own;
  Inc(Packet);
  Result := 0;
 End;

Function SimConnect_TransmitClientEvent(h : THandle; o, e, v, g, f : DWORD) : HRESULT; Stdcall;
 Begin
  Own;
  Inc(Packet);
  If o <> 900 Then
   Exit(HRESULT($80004005));
  If (e >= 1) And (e <= 3) And (v = 1)Then
   FreezeMask := FreezeMask Or (1 Shl (e - 1));
  Inc(c[8]);
  Result := 0;
 End;

Function SimConnect_GetLastSentPacketID(h : THandle; Var ID : DWORD) : HRESULT; Stdcall;
 Begin
  ID     := Packet;
  Result := 0;
 End;

Exports
 Reset, Counter, SimConnect_Open, SimConnect_Close, SimConnect_GetNextDispatch, SimConnect_EnumerateSimObjectsAndLiveries,
 SimConnect_AICreateNonATCAircraft_EX1, SimConnect_AIReleaseControl, SimConnect_AIRemoveObject, SimConnect_AddToDataDefinition,
 SimConnect_SetDataOnSimObject, SimConnect_MapClientEventToSimEvent, SimConnect_TransmitClientEvent, SimConnect_GetLastSentPacketID;

Begin
 Queue := TQueue<TBytes>.Create;
End.
