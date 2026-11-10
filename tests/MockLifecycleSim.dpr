Library MockLifecycleSim;

Uses
 Winapi.Windows, System.SysUtils, System.Generics.Collections;

Type
 TField = Record
  Name : String;
  Kind : DWORD;
  Size : Integer;
 End;

Var
 Defs        : TObjectDictionary<DWORD, TList<TField>>;
 Active      : TDictionary<DWORD, DWORD>;
 Queue       : TQueue<TBytes>;
 Current     : TBytes;
 Title       : AnsiString;
 Kind        : Integer;
 Engines     : Integer;
 CancelCount : Integer;
 ClearCount  : Integer;
 Calls       : Integer;
 LastFull    : DWORD;
 LastBasic   : DWORD;
 SimName     : AnsiString = 'SunRise';
 SimMajor    : DWORD      = 12;

Procedure Put(Var b : TBytes; At : Integer; v : DWORD);
 Begin
  Move(v, b[At], 4);
 End;

Procedure PushID(ID : DWORD);
 Var
  b : TBytes;
 Begin
  SetLength(b, 12);
  Put(b, 0, 12);
  Put(b, 8, ID);
  Queue.Enqueue(b);
 End;

Procedure MockSimulator(Name : PAnsiChar; Major : DWORD); Stdcall;
 Begin
  SimName  := AnsiString(Name);
  SimMajor := Major;
 End;

Procedure MockOpen(Name : PAnsiChar; Major : DWORD); Stdcall;
 Var
  b : TBytes;
  a : AnsiString;
 Begin
  a := AnsiString(Name);
  SetLength(b, 308);
  Put(b, 0, 308);
  Put(b, 8, 2);
  If Length(a) > 255 Then
   SetLength(a, 255);
  If Length(a) > 0 Then
   Move(a[1], b[12], Length(a));
  Put(b, 268, Major);
  Put(b, 272, 2);
  Put(b, 284, 99);
  Queue.Enqueue(b);
 End;

Procedure MockAircraft(n : PAnsiChar; k, e : Integer); Stdcall;
 Begin
  Title   := AnsiString(n);
  Kind    := k;
  Engines := e;
 End;

Procedure MockEvent(ID, Value : DWORD; Path : PAnsiChar); Stdcall;
 Var
  b : TBytes;
  a : AnsiString;
 Begin
  a := AnsiString(Path);
  If ID In [6, 9] Then
   Begin
    SetLength(b, 25 + Length(a));
    Put(b, 8, 6);
    If Length(a) > 0 Then
     Move(a[1], b[24], Length(a));
   End
  Else
   Begin
    SetLength(b, 24);
    Put(b, 8, 4);
   End;
  Put(b, 0, Length(b));
  Put(b, 16, ID);
  Put(b, 20, Value);
  Queue.Enqueue(b);
 End;

Procedure MockState(ID, Value : DWORD; Path : PAnsiChar); Stdcall;
 Var
  b : TBytes;
  a : AnsiString;
 Begin
  a := AnsiString(Path);
  SetLength(b, 25 + Length(a));
  Put(b, 0, Length(b));
  Put(b, 8, 15);
  Put(b, 12, ID);
  Put(b, 16, Value);
  If Length(a) > 0 Then
   Move(a[1], b[24], Length(a));
  Queue.Enqueue(b);
 End;

Function SimConnect_RequestSystemState(h : THandle; ID : DWORD; Name : PAnsiChar) : HRESULT; Stdcall;
 Begin
  Result := 0;
 End;

Procedure Emit(r, d : DWORD);
 Var
  b  : TBytes;
  f  : TField;
  n  : Integer;
  At : Integer;
  v  : Double;
 Begin
  If Not Defs.ContainsKey(d) Then
   Exit;
  n := 40;
  For f In Defs[d] Do
   Inc(n, f.Size);
  SetLength(b, n);
  Put(b, 0, n);
  Put(b, 8, 8);
  Put(b, 12, r);
  Put(b, 20, d);
  Put(b, 36, Defs[d].Count);
  At := 40;
  For f In Defs[d] Do
   Begin
    If f.Kind = 4 Then
     Begin
      v := 1;
      If f.Name = 'ENGINE TYPE' Then
       v := Kind
      Else If f.Name = 'NUMBER OF ENGINES' Then
       v := Engines;
      Move(v, b[At], 8);
     End
    Else If f.Name = 'TITLE' Then
     Begin
      n := Length(Title);
      If n >= f.Size Then
       n := f.Size - 1;
      If n > 0 Then
       Move(Title[1], b[At], n);
     End;
    Inc(At, f.Size);
   End;
  Queue.Enqueue(b);
 End;

Procedure MockBasic; Stdcall;
 Begin
  Emit(LastBasic, 10);
 End;

Procedure MockFull; Stdcall;
 Begin
  Emit(LastFull, LastFull);
 End;

Function MockCount(k : Integer) : Integer; Stdcall;
 Begin
  Case k Of
   0 :
    If Defs.ContainsKey(10) Then
     Result := Defs[10].Count
    Else
     Result := 0;
   1 :
    Result := Active.Count;
   2 :
    Result := CancelCount;
   3 :
    Result := ClearCount;
   4 :
    Result := Calls;
  Else
    Result := LastFull;
  End;
 End;

Function MockHas(n : PAnsiChar) : BOOL; Stdcall;
 Var
  f : TField;
 Begin
  Result := False;
  If Not Defs.ContainsKey(LastFull) Then
   Exit;
  For f In Defs[LastFull] Do
   If SameText(f.Name, String(AnsiString(n))) Then
    Exit(True);
 End;

Function SimConnect_Open(Var h : THandle; n : PAnsiChar; w : HWND; e : DWORD; EH : THandle; c : DWORD) : HRESULT; Stdcall;
 Begin
  h      := 1;
  Result := 0;
  MockOpen(PAnsiChar(SimName), SimMajor);
 End;

Function SimConnect_Close(h : THandle) : HRESULT; Stdcall;
 Begin
  Active.Clear;
  Defs.Clear;
  Queue.Clear;
  Result := 0;
 End;

Function SimConnect_AddToDataDefinition(h : THandle; ID : DWORD; n, u : PAnsiChar; t : DWORD; e : Single; d : DWORD) : HRESULT; Stdcall;
 Var
  f : TField;
 Begin
  Inc(Calls);
  If Not Defs.ContainsKey(ID) Then
   Defs.Add(ID, TList<TField>.Create);
  f.Name := String(AnsiString(n));
  f.Kind := t;
  Case t Of
   4  : f.Size := 8;
   5  : f.Size := 8;
   6  : f.Size := 32;
   7  : f.Size := 64;
   8  : f.Size := 128;
   9  : f.Size := 256;
   10 : f.Size := 260;
  Else f.Size := 8;
  End;
  Defs[ID].Add(f);
  Result := 0;
 End;

Function SimConnect_ClearDataDefinition(h : THandle; ID : DWORD) : HRESULT; Stdcall;
 Begin
  Defs.Remove(ID);
  Inc(ClearCount);
  Result := 0;
 End;

Function SimConnect_RequestDataOnSimObject(h : THandle; r, d, o, p, f, a, i, l : DWORD) : HRESULT; Stdcall;
 Begin
  Result := 0;
  If p = 0 Then
   Begin
    Active.Remove(r);
    Inc(CancelCount);
    Exit;
   End;
  Active.AddOrSetValue(r, p);
  If d = 10 Then
   Begin
    LastBasic := r;
    Emit(r, d);
   End
  Else If p = 3 Then
   Begin
    LastFull := d;
    Emit(r, d);
   End;
 End;

Function SimConnect_GetNextDispatch(h : THandle; Var p : Pointer; Var Size : DWORD) : HRESULT; Stdcall;
 Begin
  If Queue.Count = 0 Then
   Exit(HRESULT($80004005));
  Current := Queue.Dequeue;
  p       := @Current[0];
  Size    := Length(Current);
  Result  := 0;
 End;

Function SimConnect_SubscribeToSystemEvent(h : THandle; ID : DWORD; n : PAnsiChar) : HRESULT; Stdcall;
 Begin
  Result := 0;
 End;

Function SimConnect_MapClientEventToSimEvent(h : THandle; ID : DWORD; n : PAnsiChar) : HRESULT; Stdcall;
 Begin
  Result := 0;
 End;

Function SimConnect_AddClientEventToNotificationGroup(h : THandle; g, ID : DWORD; Mask : BOOL) : HRESULT; Stdcall;
 Begin
  Result := 0;
 End;

Function SimConnect_SetNotificationGroupPriority(h : THandle; g, p : DWORD) : HRESULT; Stdcall;
 Begin
  Result := 0;
 End;

Function SimConnect_CallDispatch(h : THandle; CB, Context : Pointer) : HRESULT; Stdcall;
 Begin
  Result := 0;
 End;

Function SimConnect_AddToFacilityDefinition(h : THandle; ID : DWORD; Name : PAnsiChar) : HRESULT; Stdcall;
 Begin
  Result := 0;
 End;

Function SimConnect_RequestFacilityData(h : THandle; Def, Req : DWORD; ICAO, Region : PAnsiChar) : HRESULT; Stdcall;
 Begin
  Result := 0;
 End;

Function SimConnect_SubscribeToFlowEvent(h : THandle) : HRESULT; Stdcall;
 Begin
  Result := 0;
 End;

Exports
 MockSimulator, MockOpen, SimConnect_SubscribeToFlowEvent, SimConnect_AddToFacilityDefinition, SimConnect_RequestFacilityData, MockState, SimConnect_RequestSystemState, MockAircraft, MockEvent, MockBasic, MockFull, MockCount, MockHas, SimConnect_Open, SimConnect_Close,
 SimConnect_AddToDataDefinition, SimConnect_ClearDataDefinition, SimConnect_RequestDataOnSimObject,
 SimConnect_GetNextDispatch, SimConnect_SubscribeToSystemEvent, SimConnect_MapClientEventToSimEvent,
 SimConnect_AddClientEventToNotificationGroup, SimConnect_SetNotificationGroupPriority, SimConnect_CallDispatch;

Begin
 Defs    := TObjectDictionary<DWORD, TList<TField>>.Create([doOwnsValues]);
 Active  := TDictionary<DWORD, DWORD>.Create;
 Queue   := TQueue<TBytes>.Create;
 Title   := 'PMDG 737-800';
 Kind    := 1;
 Engines := 2;

End.
