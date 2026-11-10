{$StackFrames On}
Unit RouteBridgeU;

Interface

 Uses
  System.JSON, System.Generics.Collections, System.SysUtils, System.Classes, System.SyncObjs, IdContext, IdCustomHTTPServer, IdHTTPServer;

 Type
  TRouteBridge = Class
   Private
    fServer           : TIdHTTPServer;
    fLock             : TCriticalSection;
    fWeatherRequests  : TDictionary<String, String>;
    fWeatherResponses : TQueue<String>;
    fPending          : String;
    fATC              : TQueue<String>;
    Function GetPort : Word;
    Procedure Command(Context : TIdContext; Request : TIdHTTPRequestInfo; Response : TIdHTTPResponseInfo);
   Public
    Constructor Create(Port : Word);
    Destructor Destroy; Override;
    Property Port : Word Read GetPort;
    Procedure QueueWeather(Const ID, JSON : String);
    Procedure CancelWeather(Const ID : String);
    Function TakeWeather : String;
    Function TakeATC : String;
    Function Take : String;
  End;

Implementation

 Constructor TRouteBridge.Create(Port : Word);
  Begin
   Inherited Create;
   fLock             := TCriticalSection.Create;
   fATC              := TQueue<String>.Create;
   fWeatherRequests  := TDictionary<String, String>.Create;
   fWeatherResponses := TQueue<String>.Create;
   fServer           := TIdHTTPServer.Create(Nil);
   fServer.Bindings.Clear;
   fServer.Bindings.Add;
   fServer.Bindings[0].IP   := '127.0.0.1';
   fServer.Bindings[0].Port := Port;
   fServer.OnCommandGet     := Command;
   fServer.OnCommandOther   := Command;
   fServer.Active           := True;
  End;

 Destructor TRouteBridge.Destroy;
  Begin
   fServer.Free;
   fWeatherRequests.Free;
   fWeatherResponses.Free;
   fATC.Free;
   fLock.Free;
   Inherited;
  End;

 Procedure TRouteBridge.Command(Context : TIdContext; Request : TIdHTTPRequestInfo; Response : TIdHTTPResponseInfo);
  Var
   Bytes : TBytes;
   Text  : String;
   ID    : String;
   Item  : String;
   v     : TJSONValue;
   a     : TJSONArray;
   o     : TJSONObject;
  Begin
   Response.ContentType                                                  := 'text/plain';
   Response.CharSet                                                      := 'utf-8';
   Response.CustomHeaders.Values['Access-Control-Allow-Origin']          := '*';
   Response.CustomHeaders.Values['Access-Control-Allow-Methods']         := 'GET, POST, OPTIONS';
   Response.CustomHeaders.Values['Access-Control-Allow-Headers']         := 'Content-Type';
   Response.CustomHeaders.Values['Access-Control-Allow-Private-Network'] := 'true';
   Response.CloseConnection                                              := True;
   If Request.Document = '/atc/messages' Then
    Begin
     If Request.Command = 'OPTIONS' Then
      Begin
       Response.ResponseNo := 204;
       Exit;
      End;
     If Request.Command <> 'POST' Then
      Begin
       Response.ResponseNo := 405;
       Exit;
      End;
     If (Request.PostStream = Nil) Or (Request.PostStream.Size < 2) Or (Request.PostStream.Size > 65536) Then
      Begin
       Response.ResponseNo := 413;
       Exit;
      End;
     SetLength(Bytes, Request.PostStream.Size);
     Request.PostStream.Position := 0;
     Request.PostStream.ReadBuffer(Bytes[0], Length(Bytes));
     Text := TEncoding.UTF8.GetString(Bytes);
     v    := TJSONObject.ParseJSONValue(Text);
     Try
      If Not(v Is TJSONObject) Then
       Begin
        Response.ResponseNo := 400;
        Exit;
       End;
      fLock.Enter;
      Try
       If fATC.Count >= 256 Then
        Begin
         Response.ResponseNo := 429;
         Exit;
        End;
       fATC.Enqueue(Text);
      Finally
       fLock.Leave;
      End;
     Finally
      v.Free;
     End;
     Response.ResponseNo := 202;
     Exit;
    End;
   If Request.Document = '/weather/requests' Then
    Begin
     If Request.Command = 'OPTIONS' Then
      Begin
       Response.ResponseNo := 204;
       Exit;
      End;
     If Request.Command <> 'GET' Then
      Begin
       Response.ResponseNo := 405;
       Exit;
      End;
     a := TJSONArray.Create;
     Try
      fLock.Enter;
      Try
       For Item In fWeatherRequests.Values Do
        a.AddElement(TJSONObject.ParseJSONValue(Item));
      Finally
       fLock.Leave;
      End;
      Response.ContentType := 'application/json';
      Response.ContentText := a.ToJSON;
     Finally
      a.Free;
     End;
     Exit;
    End;
   If Request.Document = '/weather/responses' Then
    Begin
     If Request.Command = 'OPTIONS' Then
      Begin
       Response.ResponseNo := 204;
       Exit;
      End;
     If Request.Command <> 'POST' Then
      Begin
       Response.ResponseNo := 405;
       Exit;
      End;
     If (Request.PostStream = Nil) Or (Request.PostStream.Size > 262144) Then
      Begin
       Response.ResponseNo := 413;
       Exit;
      End;
     SetLength(Bytes, Request.PostStream.Size);
     Request.PostStream.Position := 0;
     If Length(Bytes) > 0 Then
      Request.PostStream.ReadBuffer(Bytes[0], Length(Bytes));
     Text := TEncoding.UTF8.GetString(Bytes);
     v    := TJSONObject.ParseJSONValue(Text);
     Try
      If Not(v Is TJSONObject) Then
       Begin
        Response.ResponseNo := 400;
        Exit;
       End;
      o  := TJSONObject(v);
      ID := '';
      If o.GetValue('id') <> Nil Then
       ID := o.GetValue('id').Value;
      fLock.Enter;
      Try
       If Not fWeatherRequests.ContainsKey(ID) Then
        Begin
         Response.ResponseNo := 410;
         Exit;
        End;
       If fWeatherResponses.Count >= 32 Then
        Begin
         Response.ResponseNo := 503;
         Exit;
        End;
       fWeatherResponses.Enqueue(Text);
       fWeatherRequests.Remove(ID);
      Finally
       fLock.Leave;
      End;
      Response.ResponseNo  := 202;
      Response.ContentText := 'Weather queued';
     Finally
      v.Free;
     End;
     Exit;
    End;
   If Request.Document <> '/efb-route' Then
    Begin
     Response.ResponseNo := 404;
     Exit;
    End;
   If Request.Command = 'OPTIONS' Then
    Begin
     Response.ResponseNo := 204;
     Exit;
    End;
   If Request.Command <> 'POST' Then
    Begin
     Response.ResponseNo := 405;
     Exit;
    End;
   If (Request.PostStream = Nil) Or (Request.PostStream.Size < 2) Or (Request.PostStream.Size > 1048576) Then
    Begin
     Response.ResponseNo := 413;
     Exit;
    End;
   SetLength(Bytes, Request.PostStream.Size);
   Request.PostStream.Position := 0;
   Request.PostStream.ReadBuffer(Bytes[0], Length(Bytes));
   Text := TEncoding.UTF8.GetString(Bytes);
   fLock.Enter;
   Try
    fPending := Text;
   Finally
    fLock.Leave;
   End;
   Response.ResponseNo  := 202;
   Response.ContentText := 'Route queued';
  End;

 Function TRouteBridge.GetPort : Word;
  Begin
   Result := fServer.Bindings[0].Port;
  End;

 Procedure TRouteBridge.QueueWeather(Const ID, JSON : String);
  Begin
   fLock.Enter;
   Try
    If (fWeatherRequests.Count < 16) Or fWeatherRequests.ContainsKey(ID) Then
     fWeatherRequests.AddOrSetValue(ID, JSON);
   Finally
    fLock.Leave;
   End;
  End;

 Procedure TRouteBridge.CancelWeather(Const ID : String);
  Begin
   fLock.Enter;
   Try
    fWeatherRequests.Remove(ID);
   Finally
    fLock.Leave;
   End;
  End;

 Function TRouteBridge.TakeWeather : String;
  Begin
   Result := '';
   fLock.Enter;
   Try
    If fWeatherResponses.Count > 0 Then
     Result := fWeatherResponses.Dequeue;
   Finally
    fLock.Leave;
   End;
  End;

 Function TRouteBridge.TakeATC : String;
  Begin
   Result := '';
   fLock.Enter;
   Try
    If fATC.Count > 0 Then
     Result := fATC.Dequeue;
   Finally
    fLock.Leave;
   End;
  End;

 Function TRouteBridge.Take : String;
  Begin
   fLock.Enter;
   Try
    Result   := fPending;
    fPending := '';
   Finally
    fLock.Leave;
   End;
  End;

End.
