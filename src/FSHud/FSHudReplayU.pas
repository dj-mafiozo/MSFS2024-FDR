Unit FSHudReplayU;

Interface

 Uses
  System.SysUtils, System.Classes, System.Generics.Collections, FireDAC.Comp.Client;

 Type
  TATCPacket = Record
   Time    : TDateTime;
   Payload : String;
  End;

  TATCMessage = Record
   Time     : TDateTime;
   Text     : String;
   Sequence : Integer;
  End;

  TFSHudReplay = Class
   Private
    fMessages : TList<TATCMessage>;
    fLastTime : TDateTime;
    fHasTime  : Boolean;
    fText     : String;
    fPackets  : TList<TATCPacket>;
    Procedure BuildMessages;
    Function ParseTime(Const s : String; Out t : TDateTime) : Boolean;
   Public
    Constructor Create;
    Destructor Destroy; Override;
    Procedure Load(Connection : TFDConnection; Trip : Integer);
    Function TextAt(Const Time : String) : String;
    Function LastMessageAt(Const Time : String; Seconds : Integer = 30) : String;
  End;

Implementation

 Uses
  System.JSON, System.DateUtils, System.Generics.Defaults, Data.DB;

 Constructor TFSHudReplay.Create;
  Begin
   Inherited;
   fPackets  := TList<TATCPacket>.Create;
   fMessages := TList<TATCMessage>.Create;
  End;

 Destructor TFSHudReplay.Destroy;
  Begin
   fMessages.Free;
   fPackets.Free;
   Inherited;
  End;

 Function TFSHudReplay.ParseTime(Const s : String; Out t : TDateTime) : Boolean;
  Var
   Clean : String;
   i     : Integer;
  Begin
   Clean := s;
   i     := Pos('_', Clean);
   If i > 0 Then
    SetLength(Clean, i - 1);
   Result := TryISO8601ToDate(Clean, t, True);
  End;

 Procedure TFSHudReplay.Load(Connection : TFDConnection; Trip : Integer);
  Var
   q : TFDQuery;
   p : TATCPacket;
  Begin
   fPackets.Clear;
   fMessages.Clear;
   fHasTime := False;
   fText    := '';
   If (Connection = Nil) Or (Trip <= 0) Then
    Exit;
   q := TFDQuery.Create(Nil);
   Try
    q.Connection := Connection;
    q.Open('SELECT name FROM sqlite_master WHERE type=''table'' AND name=''trip_fshud_messages''');
    If q.IsEmpty Then
     Exit;
    q.Close;
    q.SQL.Text                      := 'SELECT sim_utc,payload FROM trip_fshud_messages WHERE trip=:trip AND message_type in (''RadioMessagesData'',''NativeATCLine'') ORDER BY id';
    q.ParamByName('trip').AsInteger := Trip;
    q.Open;
    While Not q.Eof Do
     Begin
      If ParseTime(q.FieldByName('sim_utc').AsString, p.Time) Then
       Begin
        p.Payload := q.FieldByName('payload').AsString;
        fPackets.Add(p);
       End;
      q.Next;
     End;
   Finally
    q.Free;
   End;
   BuildMessages;
  End;

 Function TFSHudReplay.TextAt(Const Time : String) : String;
  Var
   t           : TDateTime;
   p           : TATCPacket;
   v           : TJSONValue;
   o           : TJSONObject;
   Item        : TJSONObject;
   Changed     : Boolean;
   a           : TJSONArray;
   i           : Integer;
   k           : Integer;
   ID          : String;
   Line        : String;
   MessageText : String;
   Lines       : TStringList;
   IDs         : TStringList;

   Function Field(Obj : TJSONObject; Const Name : String) : String;
    Var
     Value : TJSONValue;
    Begin
     Value := Obj.GetValue(Name);
     If (Value = Nil) Or (Value Is TJSONNull) Then
      Result := ''
     Else
      Result := Value.Value;
    End;

  Begin
   Result := '';
   If Not ParseTime(Time, t) Then
    Exit;
   Changed := Not fHasTime;
   If fHasTime Then
    For p In fPackets Do
     If (p.Time <= t) <> (p.Time <= fLastTime) Then
      Begin
       Changed := True;
       Break;
      End;
   If Not Changed Then
    Exit(fText);
   fLastTime := t;
   fHasTime  := True;
   Lines     := TStringList.Create;
   IDs       := TStringList.Create;
   Try
    For p In fPackets Do
     If p.Time <= t Then
      Begin
       v := TJSONObject.ParseJSONValue(p.Payload);
       Try
        If Not(v Is TJSONObject) Then
         Continue;
        o := TJSONObject(v);
        // Communication history retains messages removed from FSHud's short visible list.
        If SameText(Field(o, 'NotificationType'), 'Removed') Then
         Continue;
        v := o; // owned by this iteration
        If o.GetValue('MessageItems') Is TJSONArray Then
         Begin
          a     := TJSONArray(o.GetValue('MessageItems'));
          For i := 0 To a.Count - 1 Do
           Begin
            If Not(a.Items[i] Is TJSONObject) Then
             Continue;
            Item        := TJSONObject(a.Items[i]);
            MessageText := Field(Item, 'Message');
            If MessageText = '' Then
             Continue;
            ID   := Field(Item, 'Id');
            Line := FormatDateTime('hh:nn:ss', p.Time) + '  ' + Field(Item, 'ChannelFrequency') + '  ' + Field(Item, 'TransmittingStationCallsign') + sLineBreak + MessageText;
            k    := -1;
            If ID <> '' Then
             k := IDs.IndexOf(ID);
            If k >= 0 Then
             Lines[k] := Line
            Else
             Begin
              IDs.Add(ID);
              Lines.Add(Line);
             End;
           End;
         End
        Else If Field(o, 'Message') <> '' Then
         Begin
          IDs.Add('');
          Lines.Add(FormatDateTime('hh:nn:ss', p.Time) + '  ' + Field(o, 'Message'));
         End;
       Finally
        v.Free;
       End;
      End;
    Result := Lines.Text;
    fText  := Result;
   Finally
    IDs.Free;
    Lines.Free;
   End;
  End;

 Procedure TFSHudReplay.BuildMessages;
  Var
   p     : TATCPacket;
   v     : TJSONValue;
   Items : TJSONValue;
   m     : TJSONValue;
   o     : TJSONObject;
   a     : TJSONArray;
   i     : Integer;
   Seen  : TDictionary<String, Boolean>;
   Entry : TATCMessage;

   Procedure Take(Obj : TJSONObject);
    Var
     Msg : TJSONValue;
     Key : TJSONValue;
     ID  : String;
    Begin
     Msg := Obj.GetValue('Message');
     If (Msg = Nil) Or (Msg.Value = '') Then
      Exit;
     Key := Obj.GetValue('Id');
     ID  := '';
     If Key <> Nil Then
      ID := Key.Value;
     If ID = '' Then
      ID := 'text:' + Msg.Value
     Else
      ID := 'id:' + ID;
     If Seen.ContainsKey(ID) Then
      Exit;
     Seen.Add(ID, True);
     Entry.Time     := p.Time;
     Entry.Text     := Msg.Value;
     Entry.Sequence := fMessages.Count;
     fMessages.Add(Entry);
    End;

  Begin
   fMessages.Clear;
   Seen := TDictionary<String, Boolean>.Create;
   Try
    For p In fPackets Do
     Begin
      v := TJSONObject.ParseJSONValue(p.Payload);
      Try
       If Not(v Is TJSONObject) Then
        Continue;
       o := TJSONObject(v);
       m := o.GetValue('NotificationType');
       If (m <> Nil) And SameText(m.Value, 'Removed') Then
        Continue;
       Items := o.GetValue('MessageItems');
       If Items Is TJSONArray Then
        Begin
         a     := TJSONArray(Items);
         For i := 0 To a.Count - 1 Do
          If a.Items[i] Is TJSONObject Then
           Take(TJSONObject(a.Items[i]));
        End
       Else
        Take(o);
      Finally
       v.Free;
      End;
     End;
    fMessages.Sort(TComparer<TATCMessage>.Construct(
    Function(Const l, r : TATCMessage) : Integer
    Begin
    If l.Time < r.Time Then
    Result := -1
    Else If l.Time > r.Time Then
    Result := 1
    Else
    Result := l.Sequence - r.Sequence;
    End));
   Finally
    Seen.Free;
   End;
  End;

 Function TFSHudReplay.LastMessageAt(Const Time : String; Seconds : Integer) : String;
  Var
   t     : TDateTime;
   Lo    : Integer;
   Hi    : Integer;
   Mid   : Integer;
   Found : Integer;
   m     : TATCMessage;
  Begin
   Result := '';
   If Not ParseTime(Time, t) Then
    Exit;
   Lo    := 0;
   Hi    := fMessages.Count - 1;
   Found := -1;
   While Lo <= Hi Do
    Begin
     Mid := Lo + (Hi - Lo) Div 2;
     If fMessages[Mid].Time <= t Then
      Begin
       Found := Mid;
       Lo    := Mid + 1;
      End
     Else
      Hi := Mid - 1;
    End;
   If Found < 0 Then
    Exit;
   m := fMessages[Found];
   If (t - m.Time) * SecsPerDay <= Seconds Then
    Result := m.Text;
  End;

End.
