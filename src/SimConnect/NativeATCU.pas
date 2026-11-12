Unit NativeATCU;

Interface

 Uses
  Winapi.Windows, System.SysUtils, System.Classes, System.JSON, SimConnectClientU,
  FlightDatabaseU, RouteBridgeU, System.Generics.Collections;

 Type
  TMSFSATC = Class
   Private
    fSim        : TSimConnectClient;
    fDB         : TFlightDatabase;
    fHandle     : THandle;
    fNext       : UInt64;
    fStartedUTC : TDateTime;
    fTrip       : Integer;
    fUTC        : String;
    fLastState  : String;
    fValues     : TJSONObject;
    fSeen       : TDictionary<String, Boolean>;
    fRequest    : Function(h : THandle; r, d, o, p, f, a, i, l : DWORD) : HRESULT; StdCall;
    fAdd        : Function(h : THandle; d : DWORD; n, u : PAnsiChar; t : DWORD; e : Single; ID : DWORD) : HRESULT; StdCall;
    fPackets    : TDictionary<DWORD, Integer>;
    fDisabled   : Array [0..18] Of Boolean;
    fLastPacket : Function(h : THandle; Var ID : DWORD) : HRESULT; StdCall;
    fClear      : Function(h : THandle; d : DWORD) : HRESULT; StdCall;
    Procedure Track(Index : Integer);
    Procedure Store(Const Kind, Payload : String);
   Public
    Constructor Create(Sim : TSimConnectClient; DB : TFlightDatabase);
    Destructor  Destroy; Override;
    Procedure   Tick  (Bridge : TRouteBridge; Trip : Integer; Const UTC : String);
    Procedure   Feed  (p : Pointer; Size : DWORD);
  End;

Implementation

 Uses
  System.DateUtils, System.Math;

{ FLD+ }

 Const
  Base = 62000;
  Names : Array [0..18] Of AnsiString =
   (
    'ATC ASSIGNED ALTITUDE',
    'ATC CLEARED IFR',
    'ATC CLEARED TAXI',
    'ATC CLEARED TAKEOFF',
    'ATC CLEARED LANDING',
    'ATC DESIGNATED RUNWAY TAKEOFF',
    'ATC DESIGNATED RUNWAY LANDING',
    'ATC FUTURE AGENT NAME',
    'ATC FUTURE AGENT TYPE',
    'ATC FUTURE AGENT FREQUENCY',
    'COM ACTIVE FREQUENCY:1',
    'COM ACTIVE FREQ IDENT:1',
    'COM ACTIVE FREQ TYPE:1',
    'COM ACTIVE FREQUENCY:2',
    'COM ACTIVE FREQ IDENT:2',
    'COM ACTIVE FREQ TYPE:2',
    'COM ACTIVE FREQUENCY:3',
    'COM ACTIVE FREQ IDENT:3',
    'COM ACTIVE FREQ TYPE:3'
   );
{ FLD- }

 Constructor TMSFSATC.Create(Sim : TSimConnectClient; DB : TFlightDatabase);
  Begin
   Inherited Create;
   fSim     := Sim;
   fDB      := DB;
   fValues  := TJSONObject.Create;
   fSeen    := TDictionary<String, Boolean>.Create;
   fPackets := TDictionary<DWORD, Integer>.Create;
  End;

 Destructor TMSFSATC.Destroy;
  Begin
   fValues.Free;
   fSeen.Free;
   fPackets.Free;
   Inherited;
  End;

 Procedure TMSFSATC.Track(Index : Integer);
  Var
   ID : DWORD;
  Begin
   If Assigned(fLastPacket) Then
    If fLastPacket(fHandle, ID) >= 0 Then
     Begin
      If fPackets.Count > 256 Then
       fPackets.Clear;
      fPackets.AddOrSetValue(ID, Index);
     End;
  End;

 Procedure TMSFSATC.Store(Const Kind, Payload : String);
  Begin
   If (fTrip <= 0) Or (fUTC = '') Then
    Exit;
   fDB.Connection.ExecSQL('insert into trip_fshud_messages(trip,captured_utc,sim_utc,message_type,payload) values(:t,:c,:s,:k,:p)', [fTrip, DateToISO8601(TTimeZone.Local.ToUniversalTime(Now), True), fUTC, Kind, Payload]);
  End;

 Procedure TMSFSATC.Tick(Bridge : TRouteBridge; Trip : Integer; Const UTC : String);
  Var
   Captured : TDateTime;
   i        : Integer;
   n        : Integer;
   Raw      : String;
   ID       : String;
   Msg      : String;
   v        : TJSONValue;
   o        : TJSONObject;
   u        : AnsiString;
   t        : DWORD;
   Pair     : TJSONPair;
  Begin
   If Trip <> fTrip Then
    Begin
     fStartedUTC := TTimeZone.Local.ToUniversalTime(Now);
     fSeen.Clear;
     fLastState := '';
     fValues.Free;
     fValues := TJSONObject.Create;
    End;
   fTrip := Trip;
   fUTC  := UTC;
   If Bridge <> Nil Then
    For n := 1 To 256 Do
     Begin
      Raw := Bridge.TakeATC;
      If Raw = '' Then
       Break;
      If (Trip <= 0) Or Not fSim.TelemetryActive Then
       Continue;
      v := TJSONObject.ParseJSONValue(Raw);
      Try
       If Not(v Is TJSONObject) Then
        Continue;
       o := TJSONObject(v);
       If o.GetValue('captured_utc') <> Nil Then
        If Not TryISO8601ToDate(o.GetValue('captured_utc').Value, Captured, True) Or (Captured < fStartedUTC - 1 / SecsPerDay) Then
         Continue;
       If o.GetValue('id') = Nil Then
        Continue;
       ID := o.GetValue('id').Value;
       If (ID = '') Or (Length(ID) > 160) Or fSeen.ContainsKey(ID) Then
        Continue;
       fSeen.Add(ID, True);
       If fSeen.Count > 8192 Then
        fSeen.Clear;
       Msg := '';
       If o.GetValue('text') <> Nil Then
        Msg := o.GetValue('text').Value;
       If Msg <> '' Then
        Begin
         Pair := o.RemovePair('Message');
         Pair.Free;
         o.AddPair('Message', '[MSFS ATC] ' + Msg);
         o.AddPair('Id', 'msfs:' + ID);
        End;
       Store('NativeATCLine', o.ToJSON);
      Finally
       v.Free;
      End;
     End;
   If Not fSim.Connected Or Not fSim.SimulatorSupported Or Not fSim.TelemetryActive Or (Trip <= 0) Then
    Begin
     fHandle := 0;
     Exit;
    End;
   If fHandle <> fSim.Handle Then
    Begin
     fHandle := fSim.Handle;
     FillChar(fDisabled, SizeOf(fDisabled), 0);
     fPackets.Clear;
     fValues.Free;
     fValues := TJSONObject.Create;
     @fLastPacket := fSim.FunctionAddress('SimConnect_GetLastSentPacketID');
     @fAdd := fSim.FunctionAddress('SimConnect_AddToDataDefinition');
     @fRequest := fSim.FunctionAddress('SimConnect_RequestDataOnSimObject');
     @fClear := fSim.FunctionAddress('SimConnect_ClearDataDefinition');
     If Not Assigned(fAdd) Or Not Assigned(fRequest) Then
      Exit;
     For i := 0 To High(Names) Do
      Begin
       u := 'number';
       t := 4;
       If i = 0 Then
        u := 'feet';
       If i In [1, 2, 3, 4] Then
        u := 'bool';
       If i In [10, 13, 16] Then
        u := 'MHz';
       If i In [5, 6, 7, 11, 12, 14, 15, 17, 18] Then
        Begin
         t := 9;
         u := '';
        End;
       If Assigned(fClear) Then
        fClear(fHandle, Base + i);
       If fAdd(fHandle, Base + i, PAnsiChar(Names[i]), PAnsiChar(u), t, 0, $FFFFFFFF) < 0 Then
        fDisabled[i] := True
       Else
        Track(i);
       fSim.TrackAuxiliary('native ATC definition ' + String(Names[i]));
      End;
    End;
   If GetTickCount64 < fNext Then
    Exit;
   fNext := GetTickCount64 + 1000;
   If Assigned(fRequest) Then
    For i := 0 To High(Names) Do
     If Not fDisabled[i] Then
      Begin
       If fRequest(fHandle, Base + i, Base + i, 0, 1, 0, 0, 0, 0) < 0 Then
        fDisabled[i] := True
       Else
        Track(i);
       fSim.TrackAuxiliary('native ATC read ' + String(Names[i]));
      End;
   Raw := fValues.ToJSON;
   If (Raw <> '{}') And (Raw <> fLastState) Then
    Begin
     Store('NativeATCState', Raw);
     fLastState := Raw;
    End;
  End;

 Procedure TMSFSATC.Feed(p : Pointer; Size : DWORD);
  Var
   k    : Integer;
   ID   : DWORD;
   r    : DWORD;
   i    : DWORD;
   n    : DWORD;
   s    : AnsiString;
   d    : Double;
   v    : TJSONValue;
   Pair : TJSONPair;
  Begin
   If (p = Nil) Or (Size < 12) Then
    Exit;
   Move(PByte(NativeUInt(p) + 8)^, ID, 4);
   If (ID = 1) And (Size >= 24) Then
    Begin
     Move(PByte(NativeUInt(p) + 16)^, r, 4);
     If fPackets.TryGetValue(r, k) Then
      Begin
       fDisabled[k] := True;
       Pair         := fValues.RemovePair(String(Names[k]));
       Pair.Free;
      End;
     Exit;
    End;
   If (Size < 40) Or (fTrip <= 0) Or Not fSim.TelemetryActive Then
    Exit;
   Move(PByte(NativeUInt(p) + 8)^, ID, 4);
   If ID <> 8 Then
    Exit;
   Move(PByte(NativeUInt(p) + 12)^, r, 4);
   If (r < Base) Or (r > Base + High(Names)) Then
    Exit;
   i := r - Base;
   If i In [5, 6, 7, 11, 12, 14, 15, 17, 18] Then
    Begin
     If Size < 296 Then
      Exit;
     n := 0;
     While (n < 256) And (PByte(NativeUInt(p) + 40 + n)^ <> 0) Do
      Inc(n);
     SetString(s, PAnsiChar(NativeUInt(p) + 40), n);
     v := TJSONString.Create(String(s));
    End
   Else
    Begin
     If Size < 48 Then
      Exit;
     Move(PByte(NativeUInt(p) + 40)^, d, 8);
     If IsNan(d) Or IsInfinite(d) Then
      Exit;
     v := TJSONNumber.Create(d);
    End;
   Pair := fValues.RemovePair(String(Names[i]));
   Pair.Free;
   fValues.AddPair(String(Names[i]), v);
  End;

End.
