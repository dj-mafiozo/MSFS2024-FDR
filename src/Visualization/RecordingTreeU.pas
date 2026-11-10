{$StackFrames On}
Unit RecordingTreeU;

Interface

 Uses
  System.SysUtils, System.Classes, Data.DB, VirtualTrees, VirtualTrees.BaseTree, VirtualTrees.Types, RecordingIndexU;

 Procedure ConfigureRecordingTree(Tree : TVirtualStringTree);
 Procedure FillRecordingTree(Tree : TVirtualStringTree; Rows : TDataSet; Index : TRecordingIndex; GroupID : Integer; Const Search, Locale : String);
 Function RecordingNodeID(Node : PVirtualNode) : Integer;
 Function RecordingNodeCaption(Node : PVirtualNode) : String;
 Function RecordingNodeImage(Tree : TVirtualStringTree; Node : PVirtualNode) : Integer;

Implementation

 Uses
  System.UITypes, Winapi.Windows, System.DateUtils, System.Generics.Collections,
  LocalizationU;

 Type
  TRecordingNodeInfo = Class
   ID      : Integer;
   Caption : String;
   Key     : String;
  End;

  PRecordingNodeData = ^TRecordingNodeInfo;

  TRecordingTreePresenter = Class(TComponent)
   Private
    Procedure GetText(Sender : TBaseVirtualTree; Node : PVirtualNode; Column : TColumnIndex; TextType : TVSTTextType; Var CellText : String);
    Procedure GetImage(Sender : TBaseVirtualTree; Node : PVirtualNode; Kind : TVTImageKind; Column : TColumnIndex; Var Ghosted : Boolean; Var ImageIndex : TImageIndex);
    Procedure FreeNode(Sender : TBaseVirtualTree; Node : PVirtualNode);
   Public
    Constructor CreateFor(Tree : TVirtualStringTree);
  End;

 Function NodeInfo(Node : PVirtualNode) : TRecordingNodeInfo;
  Begin
   Result := Nil;
   If Node <> Nil Then
    Result := PRecordingNodeData(Node.GetData)^;
  End;

 Function RecordingNodeID(Node : PVirtualNode) : Integer;
  Var
   Info : TRecordingNodeInfo;
  Begin
   Result := 0;
   Info   := NodeInfo(Node);
   If Info <> Nil Then
    Result := Info.ID;
  End;

 Function RecordingNodeCaption(Node : PVirtualNode) : String;
  Var
   Info : TRecordingNodeInfo;
  Begin
   Result := '';
   Info   := NodeInfo(Node);
   If Info <> Nil Then
    Result := Info.Caption;
  End;

 Function NodeKey(Node : PVirtualNode) : String;
  Var
   Info : TRecordingNodeInfo;
  Begin
   Result := '';
   Info   := NodeInfo(Node);
   If Info <> Nil Then
    Result := Info.Key;
  End;

 Function RecordingNodeImage(Tree : TVirtualStringTree; Node : PVirtualNode) : Integer;
  Begin
   If RecordingNodeID(Node) > 0 Then
    Result := 63
   Else If Tree.Expanded[Node] Then
    Result := 4
   Else
    Result := 29;
  End;

 Constructor TRecordingTreePresenter.CreateFor(Tree : TVirtualStringTree);
  Begin
   Inherited Create(Tree);
   Name                              := 'RecordingTreePresenter';
   Tree.NodeDataSize                 := SizeOf(TRecordingNodeInfo);
   Tree.OnGetText                    := GetText;
   Tree.OnGetImageIndex              := GetImage;
   Tree.OnFreeNode                   := FreeNode;
   Tree.TreeOptions.MiscOptions      := Tree.TreeOptions.MiscOptions - [toEditable];
   Tree.TreeOptions.AutoOptions      := Tree.TreeOptions.AutoOptions - [toAutoSort];
   Tree.TreeOptions.SelectionOptions := Tree.TreeOptions.SelectionOptions + [toFullRowSelect];
  End;

 Procedure TRecordingTreePresenter.GetText(Sender : TBaseVirtualTree; Node : PVirtualNode; Column : TColumnIndex; TextType : TVSTTextType; Var CellText : String);
  Begin
   CellText := RecordingNodeCaption(Node);
  End;

 Procedure TRecordingTreePresenter.GetImage(Sender : TBaseVirtualTree; Node : PVirtualNode; Kind : TVTImageKind; Column : TColumnIndex; Var Ghosted : Boolean; Var ImageIndex : TImageIndex);
  Begin
   ImageIndex := -1;
   If (TVirtualStringTree(Sender).Images <> Nil) And (Kind In [ikNormal, ikSelected]) Then
    ImageIndex := RecordingNodeImage(TVirtualStringTree(Sender), Node);
  End;

 Procedure TRecordingTreePresenter.FreeNode(Sender : TBaseVirtualTree; Node : PVirtualNode);
  Var
   Data : PRecordingNodeData;
  Begin
   Data := Sender.GetNodeData(Node);
   If Data <> Nil Then
    Begin
     Data^.Free;
     Data^ := Nil;
    End;
  End;

 Procedure ConfigureRecordingTree(Tree : TVirtualStringTree);
  Begin
   If Tree.FindComponent('RecordingTreePresenter') = Nil Then
    TRecordingTreePresenter.CreateFor(Tree);
  End;

 Function AddNode(Tree : TVirtualStringTree; Parent : PVirtualNode; Const Caption, Key : String; ID : Integer) : PVirtualNode;
  Var
   Info : TRecordingNodeInfo;
  Begin
   Result                                        := Tree.AddChild(Parent);
   Info                                          := TRecordingNodeInfo.Create;
   PRecordingNodeData(Tree.GetNodeData(Result))^ := Info;
   Info.Caption                                  := Caption;
   Info.Key                                      := Key;
   Info.ID                                       := ID;
  End;

 Procedure FillRecordingTree(Tree : TVirtualStringTree; Rows : TDataSet; Index : TRecordingIndex; GroupID : Integer; Const Search, Locale : String);
  Var
   Folders   : TDictionary<String, PVirtualNode>;
   Nodes     : TDictionary<String, PVirtualNode>;
   Expanded  : TStringList;
   Node      : PVirtualNode;
   Parent    : PVirtualNode;
   Selected  : PVirtualNode;
   ID        : Integer;
   OldID     : Integer;
   i         : Integer;
   d         : TDateTime;
   FS        : TFormatSettings;
   Key       : String;
   Part      : String;
   Title     : String;
   Filter    : String;
   Status    : String;
   Path      : String;
   OldKey    : String;
   TopKey    : String;
   Parts     : TArray<String>;
   MonthName : Array [0..127] Of WideChar;
  Begin
   ConfigureRecordingTree(Tree);
   OldID    := RecordingNodeID(Tree.FocusedNode);
   OldKey   := NodeKey(Tree.FocusedNode);
   TopKey   := NodeKey(Tree.TopNode);
   Folders  := TDictionary<String, PVirtualNode>.Create;
   Nodes    := TDictionary<String, PVirtualNode>.Create;
   Expanded := TStringList.Create;
   Tree.BeginUpdate;
   Try
    Node := Tree.GetFirst;
    While Node <> Nil Do
     Begin
      If Tree.Expanded[Node] Then
       Expanded.Add(NodeKey(Node));
      Node := Tree.GetNext(Node);
     End;
    Tree.Clear;
    FS    := TFormatSettings.Create(Locale);
    For i := 1 To 12 Do
     If GetCalendarInfoEx(PChar(Locale), CAL_GREGORIAN, Nil, CAL_SMONTHNAME1 + i - 1, @MonthName[0], Length(MonthName), Nil) > 0 Then
      FS.LongMonthNames[i] := String(MonthName);
    Filter                 := LowerCase(Trim(Search));
    Selected               := Nil;
    Rows.First;
    While Not Rows.Eof Do
     Begin
      ID   := Rows.FieldByName('id').AsInteger;
      Path := '';
      If Rows.FieldByName('relative_path').AsString <> '' Then
       Path  := Index.Resolve(Rows.FieldByName('relative_path').AsString);
      Status := Rows.FieldByName('status').AsString;
      Title  := Rows.FieldByName('title').AsString;
      If FileExists(Path) And ((GroupID = 0) Or (Rows.FieldByName('group_id').AsInteger = GroupID)) And ((Filter = '') Or (Pos(Filter, LowerCase(Title + ' ' + Rows.FieldByName('atc_id').AsString + ' ' + Rows.FieldByName('atc_model').AsString + ' ' + Rows.FieldByName('departure_icao').AsString + ' ' + Rows.FieldByName('destination_icao').AsString + ' ' + Rows.FieldByName('started_utc').AsString + ' ' + Rows.FieldByName('group_name').AsString)) > 0)) Then
       Begin
        d      := RecordingTime(Rows.FieldByName('started_utc').AsString);
        Parts  := TArray<String>.Create(RecordingAircraftCode(Rows.FieldByName('atc_model').AsString, Rows.FieldByName('title').AsString), RecordingCode(Rows.FieldByName('departure_icao').AsString), FormatDateTime('yyyy', d), FormatDateTime('mm', d));
        Parent := Nil;
        Key    := '';
        For i  := 0 To High(Parts) Do
         Begin
          Part := Parts[i];
          Key  := Key + Part + '\';
          If Not Folders.TryGetValue(Key, Node) Then
           Begin
            If i = 3 Then
             Part := FS.LongMonthNames[MonthOf(d)];
            Node  := AddNode(Tree, Parent, Part, Key, 0);
            Folders.Add(Key, Node);
            Nodes.Add(Key, Node);
           End;
          Parent := Node;
         End;
        Title := FormatDateTime('yyyy-mm-dd hh:nn:ss', d) + ' ' + RecordingCode(Rows.FieldByName('departure_icao').AsString) + ' - ' + RecordingCode(Rows.FieldByName('destination_icao').AsString) + ' | ' + Title;
        If Status = 'recording' Then
         Title := Tr('[Nagrywanie...]') + ' ' + Title
        Else If Status = 'finalizing' Then
         Title := Tr('[Finalizowanie...]') + ' ' + Title
        Else If Status = 'interupted' Then
         Title := Tr('[Przerwane]') + ' ' + Title
        Else If Status = 'error' Then
         Title := Tr('[Błąd]') + ' ' + Title;
        Key    := 'recording:' + IntToStr(ID);
        Node   := AddNode(Tree, Parent, Title, Key, ID);
        Nodes.Add(Key, Node);
        Tree.IsDisabled[Node] := (Status = 'recording') Or (Status = 'finalizing') Or (Status = 'error') Or (Rows.FieldByName('recovery_pending').AsInteger <> 0);
        If ID = OldID Then
         Selected := Node;
       End;
      Rows.Next;
     End;
    For Key In Expanded Do
     If Nodes.TryGetValue(Key, Node) Then
      Tree.Expanded[Node] := True;
    If (Selected = Nil) And (OldKey <> '') Then
     Nodes.TryGetValue(OldKey, Selected);
    If (Selected <> Nil) And Not Tree.IsDisabled[Selected] Then
     Begin
      Tree.FocusedNode        := Selected;
      Tree.Selected[Selected] := True;
      If OldID > 0 Then
       Rows.Locate('id', OldID, []);
     End;
    If (TopKey <> '') And Nodes.TryGetValue(TopKey, Node) Then
     Tree.TopNode := Node;
   Finally
    Tree.EndUpdate;
    Expanded.Free;
    Nodes.Free;
    Folders.Free;
   End;
  End;

End.
