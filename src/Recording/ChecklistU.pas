Unit ChecklistU;

Interface

 Uses
  System.SysUtils, System.Classes, System.JSON, System.Generics.Collections,
  FireDAC.Comp.Client, FlightDatabaseU, RouteBridgeU, Vcl.StdCtrls, Vcl.CheckLst;

 Type
  TChecklistRecorder = Class
   Private
    fDB        : TFlightDatabase;
    fTrip      : Integer;
    fLastRaw   : String;
    fLastState : String;
   Public
    Constructor Create(DB : TFlightDatabase);
    Procedure   Tick  (Bridge : TRouteBridge; Trip : Integer; Const UTC : String; Active : Boolean);
  End;

  TChecklistPacket = Record
   Time     : TDateTime;
   Sequence : Integer;
   Payload  : String;
  End;

  TChecklistReplay = Class
   Private
    fPackets : TList<TChecklistPacket>;
    fIDs     : TStringList;
    fData    : TJSONObject;
    fShown   : String;
   Public
    Constructor Create;
    Destructor  Destroy; Override;
    Procedure   Load           (Connection : TFDConnection; Trip : Integer);
    Function    SnapshotAt     (Const UTC : String) : String;
    Procedure   Present        (Const UTC : String; Selector : TComboBox; Items : TCheckListBox; Empty : TLabel);
    Procedure   SelectChecklist(Selector : TComboBox; Items : TCheckListBox);
  End;

 Function ValidChecklistSnapshot(Value : TJSONValue) : Boolean;

Implementation

 Uses
  System.DateUtils, System.Generics.Defaults, Data.DB;

 Function ParseTime(Const UTC : String; Out Time : TDateTime) : Boolean;
  Var
   Text  : String;
   Index : Integer;
  Begin
   Text  := UTC;
   Index := Pos('_', Text);
   If Index > 0 Then
    SetLength(Text, Index - 1);
   Result := TryISO8601ToDate(Text, Time, True);
  End;

 Function ValidChecklistSnapshot(Value : TJSONValue) : Boolean;
  Var
   Root      : TJSONObject;
   List      : TJSONObject;
   Item      : TJSONObject;
   Lists     : TJSONArray;
   Items     : TJSONArray;
   ListValue : TJSONValue;
   ItemValue : TJSONValue;
   State     : TJSONValue;
   Total     : Integer;
  Begin
   Result := False;
   If Not(Value Is TJSONObject) Then
    Exit;
   Root := TJSONObject(Value);
   If (Root.GetValue('schema') = Nil) Or (Root.GetValue('schema').Value <> '1') Then
    Exit;
   If Not(Root.GetValue('checklists') Is TJSONArray) Then
    Exit;
   Lists := TJSONArray(Root.GetValue('checklists'));
   If Lists.Count > 256 Then
    Exit;
   Total := 0;
   For ListValue In Lists Do
    Begin
     If Not(ListValue Is TJSONObject) Then
      Exit;
     List := TJSONObject(ListValue);
     If Not(List.GetValue('id') Is TJSONString) Or Not(List.GetValue('name') Is TJSONString) Then
      Exit;
     If (List.GetValue('id').Value = '') Or (Length(List.GetValue('name').Value) > 4096) Then
      Exit;
     If Not(List.GetValue('items') Is TJSONArray) Then
      Exit;
     Items := TJSONArray(List.GetValue('items'));
     Inc(Total, Items.Count);
     If Total > 8192 Then
      Exit;
     For ItemValue In Items Do
      Begin
       If Not(ItemValue Is TJSONObject) Then
        Exit;
       Item := TJSONObject(ItemValue);
       If Not(Item.GetValue('text') Is TJSONString) Then
        Exit;
       If Length(Item.GetValue('text').Value) > 8192 Then
        Exit;
       State := Item.GetValue('checked');
       If Not(State Is TJSONBool) And Not(State Is TJSONNull) Then
        Exit;
      End;
    End;
   Result := True;
  End;

 Constructor TChecklistRecorder.Create(DB : TFlightDatabase);
  Begin
   Inherited Create;
   fDB := DB;
  End;

 Procedure TChecklistRecorder.Tick(Bridge : TRouteBridge; Trip : Integer; Const UTC : String; Active : Boolean);
  Var
   Raw      : String;
   State    : String;
   Value    : TJSONValue;
   Root     : TJSONObject;
   Captured : TDateTime;
  Begin
   If Trip <> fTrip Then
    Begin
     fTrip      := Trip;
     fLastRaw   := '';
     fLastState := '';
    End;
   If (Bridge = Nil) Or (Trip <= 0) Or Not Active Or (UTC = '') Then
    Exit;
   Raw := Bridge.ChecklistSnapshot;
   If (Raw = '') Or (Raw = fLastRaw) Then
    Exit;
   Value := TJSONObject.ParseJSONValue(Raw);
   Try
    If Not ValidChecklistSnapshot(Value) Then
     Exit;
    Root := TJSONObject(Value);
    If (Root.GetValue('captured_utc') = Nil) Or
    Not ParseTime(Root.GetValue('captured_utc').Value, Captured) Then
     Exit;
    If Abs((TTimeZone.Local.ToUniversalTime(Now) - Captured) * SecsPerDay) > 15 Then
     Exit;
    State := Root.GetValue('checklists').ToJSON;
    If Root.GetValue('activeChecklistId') <> Nil Then
     State := State + Root.GetValue('activeChecklistId').ToJSON;
    If State <> fLastState Then
     Begin
      fDB.Connection.ExecSQL('insert into trip_checklists(trip,captured_utc,sim_utc,payload) values(:t,:c,:s,:p)',
      [Trip, Root.GetValue('captured_utc').Value, UTC, Raw]);
      fLastState := State;
     End;
    fLastRaw := Raw;
   Finally
    Value.Free;
   End;
  End;

 Constructor TChecklistReplay.Create;
  Begin
   Inherited;
   fPackets := TList<TChecklistPacket>.Create;
   fIDs     := TStringList.Create;
   fShown   := #0;
  End;

 Destructor TChecklistReplay.Destroy;
  Begin
   fData.Free;
   fIDs.Free;
   fPackets.Free;
   Inherited;
  End;

 Procedure TChecklistReplay.Load(Connection : TFDConnection; Trip : Integer);
  Var
   Query  : TFDQuery;
   Packet : TChecklistPacket;
  Begin
   fPackets.Clear;
   fShown := #0;
   If (Connection = Nil) Or (Trip <= 0) Then
    Exit;
   Query := TFDQuery.Create(Nil);
   Try
    Query.Connection := Connection;
    Query.Open('select name from sqlite_master where type=''table'' and name=''trip_checklists''');
    If Query.IsEmpty Then
     Exit;
    Query.Close;
    Query.Open('select id,sim_utc,payload from trip_checklists where trip=:t order by id', [Trip]);
    While Not Query.Eof Do
     Begin
      If ParseTime(Query.FieldByName('sim_utc').AsString, Packet.Time) Then
       Begin
        Packet.Sequence := Query.FieldByName('id').AsInteger;
        Packet.Payload  := Query.FieldByName('payload').AsString;
        fPackets.Add(Packet);
       End;
      Query.Next;
     End;
    fPackets.Sort(TComparer<TChecklistPacket>.Construct(
    Function(Const Left, Right : TChecklistPacket) : Integer
    Begin
    If Left.Time < Right.Time Then Exit( -1);
    If Left.Time > Right.Time Then Exit(1);
    If Left.Sequence < Right.Sequence Then Exit( -1);
    If Left.Sequence > Right.Sequence Then Exit(1);
    Result := 0;
    End));
   Finally
    Query.Free;
   End;
  End;

 Function TChecklistReplay.SnapshotAt(Const UTC : String) : String;
  Var
   Time      : TDateTime;
   LowIndex  : Integer;
   HighIndex : Integer;
   Middle    : Integer;
   Found     : Integer;
  Begin
   Result := '';
   If Not ParseTime(UTC, Time) Then
    Exit;
   LowIndex  := 0;
   HighIndex := fPackets.Count - 1;
   Found     := -1;
   While LowIndex <= HighIndex Do
    Begin
     Middle := (LowIndex + HighIndex) Div 2;
     If fPackets[Middle].Time <= Time Then
      Begin
       Found    := Middle;
       LowIndex := Middle + 1;
      End
     Else
      HighIndex := Middle - 1;
    End;
   If Found >= 0 Then
    Result := fPackets[Found].Payload;
  End;

 Procedure TChecklistReplay.Present(Const UTC : String; Selector : TComboBox; Items : TCheckListBox; Empty : TLabel);
  Var
   Raw       : String;
   Selected  : String;
   Active    : String;
   Value     : TJSONValue;
   ListValue : TJSONValue;
   Lists     : TJSONArray;
   List      : TJSONObject;
   Index     : Integer;
  Begin
   Raw := SnapshotAt(UTC);
   If Raw = fShown Then
    Exit;
   Selected := '';
   If (Selector.ItemIndex >= 0) And (Selector.ItemIndex < fIDs.Count) Then
    Selected := fIDs[Selector.ItemIndex];
   FreeAndNil(fData);
   Value := TJSONObject.ParseJSONValue(Raw);
   If ValidChecklistSnapshot(Value) Then
    fData := TJSONObject(Value)
   Else
    Value.Free;
   Selector.Items.BeginUpdate;
   Try
    Selector.Items.Clear;
    fIDs.Clear;
    Active := '';
    If fData <> Nil Then
     Begin
      If fData.GetValue('activeChecklistId') <> Nil Then
       Active := fData.GetValue('activeChecklistId').Value;
      Lists   := TJSONArray(fData.GetValue('checklists'));
      For ListValue In Lists Do
       Begin
        List := TJSONObject(ListValue);
        fIDs.Add(List.GetValue('id').Value);
        Selector.Items.Add(List.GetValue('name').Value);
       End;
     End;
    Index := fIDs.IndexOf(Selected);
    If Index < 0 Then
     Index := fIDs.IndexOf(Active);
    If (Index < 0) And (fIDs.Count > 0) Then
     Index             := 0;
    Selector.ItemIndex := Index;
    Selector.Enabled   := fIDs.Count > 0;
    Empty.Visible      := fIDs.Count = 0;
   Finally
    Selector.Items.EndUpdate;
   End;
   SelectChecklist(Selector, Items);
   fShown := Raw;
  End;

 Procedure TChecklistReplay.SelectChecklist(Selector : TComboBox; Items : TCheckListBox);
  Var
   Lists    : TJSONArray;
   Rows     : TJSONArray;
   RowValue : TJSONValue;
   State    : TJSONValue;
   Row      : TJSONObject;
   Index    : Integer;
  Begin
   Items.Items.BeginUpdate;
   Try
    Items.Items.Clear;
    If (fData = Nil) Or (Selector.ItemIndex < 0) Then
     Exit;
    Lists := TJSONArray(fData.GetValue('checklists'));
    If Selector.ItemIndex >= Lists.Count Then
     Exit;
    Rows := TJSONArray(TJSONObject(Lists.Items[Selector.ItemIndex]).GetValue('items'));
    For RowValue In Rows Do
     Begin
      Row   := TJSONObject(RowValue);
      Index := Items.Items.Add(Row.GetValue('text').Value);
      State := Row.GetValue('checked');
      If State Is TJSONNull Then
       Items.State[Index] := cbGrayed
      Else If State.Value = 'true' Then
       Items.State[Index] := cbChecked
      Else
       Items.State[Index]      := cbUnchecked;
      Items.ItemEnabled[Index] := False;
     End;
   Finally
    Items.Items.EndUpdate;
   End;
  End;

End.
