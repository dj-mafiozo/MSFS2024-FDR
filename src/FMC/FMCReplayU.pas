{$StackFrames On}
Unit FMCReplayU;

Interface

 Uses
  System.SysUtils, System.Generics.Collections, FMCScreensU, FireDAC.Comp.Client;

 Type
  TFMCSnapshot = Class
   Time   : TDateTime;
   ID     : Int64;
   Screen : TFMCScreen;
   Destructor Destroy; Override;
  End;

  TFMCDeviceHistory = Class
   Name     : String;
   Provider : String;
   Device   : String;
   Items    : TObjectList<TFMCSnapshot>;
   Constructor Create;
   Destructor  Destroy; Override;
   Function    AtTime(Time : TDateTime) : TFMCSnapshot;
  End;

  TFMCHistory = Class
   TripTitle : String;
   Devices   : TObjectList<TFMCDeviceHistory>;
   Constructor Create;
   Destructor  Destroy; Override;
   Procedure   Load(Connection : TFDConnection; Trip : Integer);
  End;

 Function FMCTime(Const Text : String; Out Value : TDateTime) : Boolean;
 Function DetectFMCFamily(Const Title, Provider : String) : String;

Implementation

 Uses
  System.DateUtils, System.Generics.Defaults, FireDAC.Stan.Param;

 Function DetectFMCFamily(Const Title, Provider : String) : String;
  Var
   t : String;
  Begin
   t      := UpperCase(Title + ' ' + Provider).Replace('-', '').Replace('_', '').Replace(' ', '');
   Result := '';
   If (Pos('A32', t) > 0) Or (Pos('FENIX', t) > 0) Or (Pos('FBW', t) > 0) Then
    Result := 'A320'
   Else If (Pos('777', t) > 0) Or (Pos('B77', t) > 0) Then
    Result := 'B777'
   Else If (Pos('737', t) > 0) Or (Pos('NG3', t) > 0) Or (Pos('B735', t) > 0) Then
    Result := 'B737';
  End;

 Function FMCTime(Const Text : String; Out Value : TDateTime) : Boolean;
  Var
   s : String;
   i : Integer;
  Begin
   // Recorder timestamps retain a weekday suffix; it is not part of ISO 8601.
   s := Text;
   i := Pos('_', s);
   If i > 0 Then
    SetLength(s, i - 1);
   Result := TryISO8601ToDate(s, Value, True);
  End;

 Destructor TFMCSnapshot.Destroy;
  Begin
   Screen.Free;
   Inherited;
  End;

 Constructor TFMCDeviceHistory.Create;
  Begin
   Inherited;
   Items := TObjectList<TFMCSnapshot>.Create(True);
  End;

 Destructor TFMCDeviceHistory.Destroy;
  Begin
   Items.Free;
   Inherited;
  End;

 Function TFMCDeviceHistory.AtTime(Time : TDateTime) : TFMCSnapshot;
  Var
   l : Integer;
   h : Integer;
   m : Integer;
  Begin
   Result := Nil;
   l      := 0;
   h      := Items.Count - 1;
   While l <= h Do
    Begin
     m := (l + h) Div 2;
     If Items[m].Time <= Time Then
      Begin
       Result := Items[m];
       l      := m + 1;
      End
     Else
      h := m - 1;
    End;
  End;

 Constructor TFMCHistory.Create;
  Begin
   Inherited;
   Devices := TObjectList<TFMCDeviceHistory>.Create(True);
  End;

 Destructor TFMCHistory.Destroy;
  Begin
   Devices.Free;
   Inherited;
  End;

 Procedure TFMCHistory.Load(Connection : TFDConnection; Trip : Integer);
  Var
   q         : TFDQuery;
   d         : TFMCDeviceHistory;
   Candidate : TFMCDeviceHistory;
   s         : TFMCSnapshot;
   Name      : String;
   Stamp     : TDateTime;
  Begin
   Devices.Clear;
   TripTitle := '';
   If (Connection = Nil) Or (Trip <= 0) Then
    Exit;
   q := TFDQuery.Create(Nil);
   Try
    q.Connection := Connection;
    q.Open('select title from trips where id=:t', [Trip]);
    If Not q.IsEmpty Then
     TripTitle := q.FieldByName('title').AsString;
    q.Close;
    q.Open('select * from trip_fmc_screens where trip=:t order by id', [Trip]);
    While Not q.Eof Do
     Begin
      If FMCTime(q.FieldByName('time_zulu').AsString, Stamp) Then
       Begin
        Name := q.FieldByName('provider').AsString + ' / ' + q.FieldByName('device').AsString;
        d    := Nil;
        For Candidate In Devices Do
         If Candidate.Name = Name Then
          Begin
           d := Candidate;
           Break;
          End;
        If d = Nil Then
         Begin
          d          := TFMCDeviceHistory.Create;
          d.Name     := Name;
          d.Provider := q.FieldByName('provider').AsString;
          d.Device   := q.FieldByName('device').AsString;
          Devices.Add(d);
         End;
        s := TFMCSnapshot.Create;
        d.Items.Add(s);
        s.Time                    := Stamp;
        s.ID                      := q.FieldByName('id').AsLargeInt;
        s.Screen                  := TFMCScreen.Create;
        s.Screen.Provider         := q.FieldByName('provider').AsString;
        s.Screen.Device           := q.FieldByName('device').AsString;
        s.Screen.Available        := q.FieldByName('available').AsInteger <> 0;
        s.Screen.PowerState       := q.FieldByName('powered').AsInteger;
        s.Screen.Title            := q.FieldByName('title').AsString;
        s.Screen.Lines.Text       := q.FieldByName('raw_text').AsString;
        s.Screen.StyleJSON        := q.FieldByName('style_json').AsString;
        s.Screen.AnnunciatorsJSON := q.FieldByName('annunciators_json').AsString;
       End;
      q.Next;
     End;
    For d In Devices Do
     d.Items.Sort(TComparer<TFMCSnapshot>.Construct(
     Function(Const a, b : TFMCSnapshot) : Integer
     Begin
     If a.Time < b.Time Then
     Result := -1
     Else If a.Time > b.Time Then
     Result := 1
     Else If a.ID < b.ID Then
     Result := -1
     Else If a.ID > b.ID Then
     Result := 1
     Else
     Result := 0;
     End));
   Finally
    q.Free;
   End;
  End;

End.
