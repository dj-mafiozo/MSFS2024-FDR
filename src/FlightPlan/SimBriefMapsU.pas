Unit SimBriefMapsU;

Interface

 Uses
  System.Classes, System.SysUtils, System.JSON, FireDAC.Comp.Client;

 Type
  TSimBriefMap = Record
   Name  : String;
   URL   : String;
   Error : String;
   Data  : TBytes;
  End;

  TSimBriefMapsFetch = Class(TThread)
   Private
    Procedure ReceiveData(Const Sender : TObject; AContentLength, AReadCount : Int64; Var Abort : Boolean);
   Protected
    Procedure Execute; Override;
   Public
    PlanKey : String;
    Images  : TArray<TSimBriefMap>;
    Constructor Create(Const Payload : String);
  End;

 Function SimBriefMapRequests(Const Payload : String) : TArray<TSimBriefMap>;
 Function SimBriefPlanKey(Const Payload : String) : String;
 Function ValidSimBriefGIF(Const Data : TBytes) : Boolean;
 Procedure SaveSimBriefMaps(Connection : TFDConnection; Trip : Integer; Const Payload : String; Const Images : TArray<TSimBriefMap>);
 Function LoadSimBriefMaps(Connection : TFDConnection; Trip : Integer; Const Payload : String) : TArray<TSimBriefMap>;

Implementation

 Uses
  System.Variants, System.Net.HttpClient, System.Net.URLClient, System.Hash, System.DateUtils, System.Generics.Collections,
  Data.DB, FireDAC.Stan.Param;

 Const
  MaxMapBytes   = 8 * 1024 * 1024;
  MaxTotalBytes = 48 * 1024 * 1024;
  MaxMaps       = 16;

 Function SimBriefPlanKey(Const Payload : String) : String;
  Begin
   Result := THashSHA2.GetHashString(Payload);
  End;

 Function ValidSimBriefGIF(Const Data : TBytes) : Boolean;
  Var
   w : Integer;
   h : Integer;
  Begin
   Result := False;
   If Length(Data) < 13 Then
    Exit;
   If (Data[0] <> 71) Or (Data[1] <> 73) Or (Data[2] <> 70) Or (Data[3] <> 56) Or Not(Data[4] In [55, 57]) Or (Data[5] <> 97) Then
    Exit;
   w      := Data[6] + 256 * Data[7];
   h      := Data[8] + 256 * Data[9];
   Result := (w > 0) And (h > 0) And (w <= 4096) And (h <= 4096) And (Length(Data) <= MaxMapBytes);
  End;

 Function AllowedURL(Const URL : String) : Boolean;
  Var
   u    : TURI;
   Host : String;
  Begin
   Result := False;
   Try
    u      := TURI.Create(URL);
    Host   := LowerCase(u.Host);
    Result := SameText(u.Scheme, 'https') And ((Host = 'simbrief.com') Or Host.EndsWith('.simbrief.com'));
    {$IFDEF PORT_TEST}
    Result := Result Or (SameText(u.Scheme, 'http') And (Host = '127.0.0.1'));
    {$ENDIF}
   Except
    Result := False;
   End;
  End;

 Function SimBriefMapRequests(Const Payload : String) : TArray<TSimBriefMap>;
  Var
   Root      : TJSONValue;
   Images    : TJSONValue;
   Maps      : TJSONValue;
   v         : TJSONValue;
   o         : TJSONObject;
   Directory : String;
   Link      : String;
   m         : TSimBriefMap;
   l         : TList<TSimBriefMap>;
   Seen      : TDictionary<String, Boolean>;

   Function Value(Obj : TJSONObject; Const Key : String) : String;
    Var
     p : TJSONValue;
    Begin
     p := Obj.GetValue(Key);
     If p = Nil Then
      Result := ''
     Else
      Result := p.Value;
    End;

   Procedure Add(Item : TJSONValue);
    Begin
     If Not(Item Is TJSONObject) Or (l.Count >= MaxMaps) Then
      Exit;
     o    := TJSONObject(Item);
     Link := Value(o, 'link');
     If Link = '' Then
      Exit;
     m      := Default(TSimBriefMap);
     m.Name := Value(o, 'name');
     If m.Name = '' Then
      m.Name := 'Map ' + IntToStr(l.Count + 1);
     If Link.StartsWith('https://', True) Or Link.StartsWith('http://', True) Then
      m.URL := Link
     Else If Link.StartsWith('//') Then
      m.URL := 'https:' + Link
     Else
      m.URL := Directory + Link;
     If Seen.ContainsKey(m.URL) Then
      Exit;
     Seen.Add(m.URL, True);
     If Not AllowedURL(m.URL) Then
      m.Error := 'Unsupported SimBrief map URL';
     l.Add(m);
    End;

  Begin
   Result := Nil;
   Root   := TJSONObject.ParseJSONValue(Payload);
   l      := TList<TSimBriefMap>.Create;
   Seen   := TDictionary<String, Boolean>.Create;
   Try
    If Not(Root Is TJSONObject) Then
     Exit;
    Images := TJSONObject(Root).GetValue('images');
    If Not(Images Is TJSONObject) Then
     Exit;
    Directory := Value(TJSONObject(Images), 'directory');
    If (Directory <> '') And Not Directory.EndsWith('/') Then
     Directory := Directory + '/';
    Maps       := TJSONObject(Images).GetValue('map');
    If Maps Is TJSONArray Then
     For v In TJSONArray(Maps) Do
      Add(v)
    Else
     Add(Maps);
    Result := l.ToArray;
   Finally
    Seen.Free;
    l.Free;
    Root.Free;
   End;
  End;

 Constructor TSimBriefMapsFetch.Create(Const Payload : String);
  Begin
   Inherited Create(True);
   FreeOnTerminate := False;
   PlanKey         := SimBriefPlanKey(Payload);
   Images          := SimBriefMapRequests(Payload);
  End;

 Procedure TSimBriefMapsFetch.ReceiveData(Const Sender : TObject; AContentLength, AReadCount : Int64; Var Abort : Boolean);
  Begin
   Abort := Terminated Or (AReadCount > MaxMapBytes) Or (AContentLength > MaxMapBytes);
  End;

 Procedure TSimBriefMapsFetch.Execute;
  Var
   Client   : THTTPClient;
   Stream   : TMemoryStream;
   Response : IHTTPResponse;
   i        : Integer;
   Total    : Integer;
  Begin
   Client := THTTPClient.Create;
   Stream := TMemoryStream.Create;
   Total  := 0;
   Try
    Client.ConnectionTimeout := 5000;
    Client.ResponseTimeout   := 10000;
    Client.HandleRedirects   := False;
    Client.OnReceiveData     := ReceiveData;
    For i                    := 0 To High(Images) Do
     Begin
      If Terminated Then
       Break;
      If Images[i].Error <> '' Then
       Continue;
      Try
       If Total >= MaxTotalBytes Then
        Raise Exception.Create('SimBrief map total size limit');
       Stream.Clear;
       Response := Client.Get(Images[i].URL, Stream);
       If Response.StatusCode <> 200 Then
        Raise Exception.Create('SimBrief map HTTP ' + IntToStr(Response.StatusCode));
       If (Stream.Size > MaxMapBytes) Or (Stream.Size + Total > MaxTotalBytes) Then
        Raise Exception.Create('SimBrief map size limit');
       SetLength(Images[i].Data, Stream.Size);
       If Stream.Size > 0 Then
        Move(Stream.Memory^, Images[i].Data[0], Stream.Size);
       If Not ValidSimBriefGIF(Images[i].Data) Then
        Raise Exception.Create('Invalid SimBrief GIF');
       Inc(Total, Length(Images[i].Data));
      Except
       On E : Exception Do
        Begin
         Images[i].Data  := Nil;
         Images[i].Error := E.Message;
        End;
      End;
     End;
   Finally
    Stream.Free;
    Client.Free;
   End;
  End;

 Function HasMaps(Connection : TFDConnection) : Boolean;
  Begin
   Result := (Connection <> Nil) And (Connection.ExecSQLScalar('select count(*) from sqlite_master where type=''table'' and name=''trip_simbrief_maps''') <> 0);
  End;

 Procedure SaveSimBriefMaps(Connection : TFDConnection; Trip : Integer; Const Payload : String; Const Images : TArray<TSimBriefMap>);
  Var
   q       : TFDQuery;
   m       : TSimBriefMap;
   Key     : String;
   Current : Variant;
   Stream  : TBytesStream;
  Begin
   If (Connection = Nil) Or (Trip <= 0) Or Not HasMaps(Connection) Then
    Exit;
   Current := Connection.ExecSQLScalar('select payload from trip_simbrief where trip=:t', [Trip]);
   If VarToStr(Current) <> Payload Then
    Exit; // Never attach images to a different plan or flight.
   Key := SimBriefPlanKey(Payload);
   q   := TFDQuery.Create(Nil);
   Try
    q.Connection := Connection;
    q.SQL.Text   := 'insert or replace into trip_simbrief_maps(trip,plan_sha256,name,url,mime,data,error,captured_utc) values(:t,:k,:n,:u,''image/gif'',:d,:e,:c)';
    For m In Images Do
     Begin
      If (Length(m.Data) = 0) And (m.Error = '') Then
       Continue;
      If (Length(m.Data) > 0) And Not ValidSimBriefGIF(m.Data) Then
       Continue;
      q.ParamByName('t').AsInteger := Trip;
      q.ParamByName('k').AsString  := Key;
      q.ParamByName('n').AsString  := m.Name;
      q.ParamByName('u').AsString  := m.URL;
      Stream                       := TBytesStream.Create(m.Data);
      Try
       q.ParamByName('d').LoadFromStream(Stream, ftBlob);
      Finally
       Stream.Free;
      End;
      q.ParamByName('e').AsString := m.Error;
      q.ParamByName('c').AsString := DateToISO8601(TTimeZone.Local.ToUniversalTime(Now), True);
      q.ExecSQL;
     End;
   Finally
    q.Free;
   End;
  End;

 Function LoadSimBriefMaps(Connection : TFDConnection; Trip : Integer; Const Payload : String) : TArray<TSimBriefMap>;
  Var
   q : TFDQuery;
   l : TList<TSimBriefMap>;
   m : TSimBriefMap;
  Begin
   Result := Nil;
   If (Trip <= 0) Or Not HasMaps(Connection) Then
    Exit;
   q := TFDQuery.Create(Nil);
   l := TList<TSimBriefMap>.Create;
   Try
    q.Connection := Connection;
    q.Open('select name,url,data,error from trip_simbrief_maps where trip=:t and plan_sha256=:k order by rowid', [Trip, SimBriefPlanKey(Payload)]);
    While Not q.Eof Do
     Begin
      m       := Default(TSimBriefMap);
      m.Name  := q.FieldByName('name').AsString;
      m.URL   := q.FieldByName('url').AsString;
      m.Data  := q.FieldByName('data').AsBytes;
      m.Error := q.FieldByName('error').AsString;
      If (Length(m.Data) > 0) And Not ValidSimBriefGIF(m.Data) Then
       Begin
        m.Data  := Nil;
        m.Error := 'Invalid stored SimBrief GIF';
       End;
      l.Add(m);
      q.Next;
     End;
    Result := l.ToArray;
   Finally
    l.Free;
    q.Free;
   End;
  End;

End.
