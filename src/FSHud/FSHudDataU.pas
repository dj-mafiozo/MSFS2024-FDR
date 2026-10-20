{$StackFrames On}
Unit FSHudDataU;

Interface

 Uses
  System.SysUtils, System.JSON, System.Generics.Collections, FireDAC.Comp.Client,
  FSHudClientU;

 Const
  FSHudFieldCount                        = 3;
  FSHudFields : Array [0 .. 2] Of String = ('COM1_selected_MHz', 'COM2_selected_MHz', 'squawk_display');

 Type
  TFSHudData = Class
   Private
    fClient : TFSHudClient;
    fLast   : TDictionary<String, String>;
    fTimes  : TDictionary<String, String>;
    fTrip   : Integer;
    Procedure WriteMessage(DB : TFDConnection; Trip : Integer; Const SimUTC : String; Const M : TFSHudMessage);
   Public
    Constructor Create(Connect : Boolean = True);
    Destructor Destroy; Override;
    Procedure BeginTrip(DB : TFDConnection; Trip : Integer; Const SimUTC : String);
    Procedure Tick(DB : TFDConnection; Trip : Integer; Const SimUTC : String);
    Procedure Apply(DB : TFDConnection; Trip : Integer; Const SimUTC : String; Const Messages : TArray<TFSHudMessage>);
    Function Snapshot : TJSONObject;
  End;

 Function FSHudContext(DB : TFDConnection; Trip : Integer; Const CapturedUTC : String) : TJSONObject;

Implementation

 Uses
  Data.DB;

 Function FSHudContext(DB : TFDConnection; Trip : Integer; Const CapturedUTC : String) : TJSONObject;
  Var
   q        : TFDQuery;
   Seen     : TDictionary<String, Boolean>;
   Messages : TJSONObject;
   Item     : TJSONObject;
   Kind     : String;
   Payload  : String;
   Size     : Integer;
  Begin
   Result   := TJSONObject.Create;
   Messages := TJSONObject.Create;
   Result.AddPair('messages', Messages);
   Result.AddPair('selection', 'latest received per message type before contact wall-clock UTC; simulation clock is independent');
   If CapturedUTC = '' Then
    Begin
     Result.AddPair('reason', 'No wall-clock contact timestamp in this legacy recording');
     Exit;
    End;
   q    := TFDQuery.Create(Nil);
   Seen := TDictionary<String, Boolean>.Create;
   Size := 0;
   Try
    q.Connection := DB;
    q.Open('select m.message_type,m.payload,m.captured_utc,m.sim_utc from trip_fshud_messages m join ' + '(select message_type,max(id) id from trip_fshud_messages where trip=:t and captured_utc<=:c group by message_type) last on m.id=last.id order by m.id desc', [Trip, CapturedUTC]);
    While Not q.Eof And (Seen.Count < 9) Do
     Begin
      Kind := q.FieldByName('message_type').AsString;
      If Not Seen.ContainsKey(Kind) Then
       Begin
        Seen.Add(Kind, True);
        Payload := q.FieldByName('payload').AsString;
        If Size + Length(Payload) <= 65536 Then
         Begin
          Inc(Size, Length(Payload));
          Item := TJSONObject.Create;
          Messages.AddPair(Kind, Item);
          Item.AddPair('captured_utc', q.FieldByName('captured_utc').AsString);
          Item.AddPair('sim_utc', q.FieldByName('sim_utc').AsString);
          Item.AddPair('data', TJSONObject.ParseJSONValue(Payload));
         End
        Else
         Result.AddPair('omitted_' + Kind, 'Payload exceeds analysis excerpt limit; full data remains in the flight database');
       End;
      q.Next;
     End;
   Finally
    Seen.Free;
    q.Free;
   End;
  End;

 Constructor TFSHudData.Create(Connect : Boolean);
  Begin
   Inherited Create;
   fLast  := TDictionary<String, String>.Create;
   fTimes := TDictionary<String, String>.Create;
   If Connect Then
    Begin
     fClient := TFSHudClient.Create;
     fClient.Start;
    End;
  End;

 Destructor TFSHudData.Destroy;
  Begin
   fClient.Free;
   fTimes.Free;
   fLast.Free;
   Inherited;
  End;

 Procedure TFSHudData.WriteMessage(DB : TFDConnection; Trip : Integer; Const SimUTC : String; Const M : TFSHudMessage);
  Begin
   If (DB <> Nil) And (Trip > 0) Then
    DB.ExecSQL('insert into trip_fshud_messages(trip,captured_utc,sim_utc,message_type,payload) values(:t,:c,:s,:k,:p)', [Trip, M.CapturedUTC, SimUTC, M.Kind, M.Payload]);
  End;

 Procedure TFSHudData.BeginTrip(DB : TFDConnection; Trip : Integer; Const SimUTC : String);
  Var
   Pair : TPair<String, String>;
   M    : TFSHudMessage;
  Begin
   If fTrip = Trip Then
    Exit;
   fTrip := Trip;
   For Pair In fLast Do
    Begin
     M.Kind        := Pair.Key;
     M.Payload     := Pair.Value;
     M.CapturedUTC := fTimes[Pair.Key];
     WriteMessage(DB, Trip, SimUTC, M);
    End;
  End;

 Procedure TFSHudData.Apply(DB : TFDConnection; Trip : Integer; Const SimUTC : String; Const Messages : TArray<TFSHudMessage>);
  Var
   M        : TFSHudMessage;
   Previous : String;
  Begin
   BeginTrip(DB, Trip, SimUTC);
   For M In Messages Do
    Begin
     If Not RecordFSHudKind(M.Kind) Then
      Continue;
     If fLast.TryGetValue(M.Kind, Previous) And (Previous = M.Payload) Then
      Continue;
     fLast.AddOrSetValue(M.Kind, M.Payload);
     fTimes.AddOrSetValue(M.Kind, M.CapturedUTC);
     WriteMessage(DB, Trip, SimUTC, M);
    End;
  End;

 Procedure TFSHudData.Tick(DB : TFDConnection; Trip : Integer; Const SimUTC : String);
  Begin
   If fClient = Nil Then
    Exit;
   Apply(DB, Trip, SimUTC, fClient.Take);
   If fClient.GetStatus <> 'connected' Then
    Begin
     fLast.Clear;
     fTimes.Clear;
    End;
  End;

 Function TFSHudData.Snapshot : TJSONObject;
  Var
   Item    : TJSONObject;
   Fields  : TJSONObject;
   V       : TJSONValue;
   Leaf    : TJSONValue;
   Payload : String;
   Part    : String;
   Path    : String;
   i       : Integer;
   j       : Integer;
   Digit   : Integer;
   Squawk  : Integer;
   n       : Double;
   FS      : TFormatSettings;
   Valid   : Boolean;

   Procedure Number(Const Name : String; Value : Double);
    Begin
     Fields.RemovePair(Name).Free;
     Fields.AddPair(Name, TJSONNumber.Create(Value));
    End;

  Begin
   Result := TJSONObject.Create;
   Result.AddPair('source', 'FSHud local panel WebSocket - unofficial read-only integration');
   If fClient = Nil Then
    Result.AddPair('status', 'offline_test')
   Else If fClient.GetStatus = 'connected' Then
    Result.AddPair('status', 'connected')
   Else
    Result.AddPair('status', 'unavailable');
   Fields := TJSONObject.Create;
   Result.AddPair('fields', Fields);
   For i := 0 To High(FSHudFields) Do
    Fields.AddPair(FSHudFields[i], TJSONNull.Create);
   If (fClient <> Nil) And (fClient.GetStatus <> 'connected') Then
    Exit;
   FS                   := TFormatSettings.Create;
   FS.DecimalSeparator  := '.';
   FS.ThousandSeparator := #0;
   If fLast.TryGetValue('RadioPanelData', Payload) Then
    Begin
     V := TJSONObject.ParseJSONValue(Payload);
     Try
      For i := 0 To 1 Do
       Begin
        If i = 0 Then
         Path := 'PanelRadioStates.Com1.SelectedFrequency'
        Else
         Path := 'PanelRadioStates.Com2.SelectedFrequency';
        Leaf  := V;
        For Part In Path.Split(['.']) Do
         Begin
          If Not(Leaf Is TJSONObject) Then
           Begin
            Leaf := Nil;
            Break;
           End;
          Leaf := TJSONObject(Leaf).GetValue(Part);
         End;
        If (Leaf <> Nil) And TryStrToFloat(Leaf.Value, n, FS) And (n >= 100) And (n < 200) Then
         Number(FSHudFields[i], n);
       End;
     Finally
      V.Free;
     End;
    End;
   If fLast.TryGetValue('UserAircraftDetailsMessage', Payload) Then
    Begin
     V := TJSONObject.ParseJSONValue(Payload);
     Try
      Leaf := Nil;
      If V Is TJSONObject Then
       Leaf  := TJSONObject(V).GetValue('UserAircraftDetails');
      Squawk := 0;
      Valid  := Leaf Is TJSONObject;
      If Valid Then
       For j := 0 To 3 Do
        Begin
         Item    := TJSONObject(Leaf);
         Payload := '';
         If Item.GetValue('SquawkCode' + IntToStr(j)) <> Nil Then
          Payload := Item.GetValue('SquawkCode' + IntToStr(j)).Value;
         If Not TryStrToInt(Payload, Digit) Or (Digit < 0) Or (Digit > 7) Then
          Valid := False
         Else
          Squawk := Squawk * 10 + Digit;
        End;
      If Valid Then
       Number(FSHudFields[2], Squawk);
     Finally
      V.Free;
     End;
    End;
  End;

End.
