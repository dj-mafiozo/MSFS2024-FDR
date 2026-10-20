Unit OllamaAnalysisU;

Interface

 Uses
  System.SysUtils, System.Classes, LocalizationU;

 Type
  TOllamaModelsThread = Class(TThread)
   Private
    fBaseURL : String;
   Protected
    Procedure Execute; Override;
   Public
    Models : TStringList;
    Error  : String;
    Constructor Create(Const BaseURL : String);
    Destructor Destroy; Override;
  End;

 Function OllamaModelsURL(Const BaseURL : String) : String;
 Function ListOllamaModels(Const BaseURL : String; Const Cancelled : TFunc<Boolean>) : TStringList;
 Function OllamaChatURL(Const BaseURL : String) : String;
 Function GenerateOllama(Const BaseURL, Model, Prompt : String; TimeoutSeconds, ContextTokens : Integer; Const Cancelled : TFunc<Boolean>) : String;

Implementation

 Uses
  Winapi.Windows, Winapi.WinHttp, System.JSON,
  System.SyncObjs, System.Net.URLClient;

 Type
  TOllamaHTTP = Class(TThread)
   Private
    fLock    : TCriticalSection;
    fRequest : HINTERNET;
    fAborted : Boolean;
    fURL     : String;
    fBody    : String;
   Protected
    Procedure Execute; Override;
   Public
    Text  : String;
    Error : String;
    Constructor Create(Const URL, Body : String);
    Destructor Destroy; Override;
    Procedure AbortRequest;
  End;

 Function OllamaChatURL(Const BaseURL : String) : String;
  Var
   U : TURI;
  Begin
   Result := Trim(BaseURL);
   If Result = '' Then
    Result := 'http://localhost:11434';
   U       := TURI.Create(Result);
   If Not(SameText(U.Scheme, 'http') Or SameText(U.Scheme, 'https')) Or (U.Host = '') Or (U.Query <> '') Or (U.Fragment <> '') Or (U.Username <> '') Then
    Raise Exception.Create(Tr('Ollama: podaj adres HTTP/HTTPS serwera bez query, fragmentu i danych logowania.'));
   While (Result <> '') And (Result[Length(Result)] = '/') Do
    Delete(Result, Length(Result), 1);
   If Not SameText(Copy(Result, Length(Result) - 8, 9), '/api/chat') Then
    Result := Result + '/api/chat';
  End;

 Function OllamaModelsURL(Const BaseURL : String) : String;
  Begin
   Result := OllamaChatURL(BaseURL);
   Result := Copy(Result, 1, Length(Result) - 4) + 'tags';
  End;

 Constructor TOllamaModelsThread.Create(Const BaseURL : String);
  Begin
   Inherited Create(True);
   FreeOnTerminate := False;
   fBaseURL        := BaseURL;
  End;

 Destructor TOllamaModelsThread.Destroy;
  Begin
   Terminate;
   WaitFor;
   Models.Free;
   Inherited;
  End;

 Procedure TOllamaModelsThread.Execute;
  Begin
   Try
    Models := ListOllamaModels(fBaseURL,
      Function : Boolean
      Begin
       Result := Terminated;
      End);
   Except
    On E : Exception Do
     Error := E.Message;
   End;
  End;

 Constructor TOllamaHTTP.Create(Const URL, Body : String);
  Begin
   Inherited Create(True);
   FreeOnTerminate := False;
   fLock           := TCriticalSection.Create;
   fURL            := URL;
   fBody           := Body;
  End;

 Procedure TOllamaHTTP.AbortRequest;
  Begin
   fLock.Acquire;
   Try
    fAborted := True;
    If fRequest <> Nil Then
     Begin
      WinHttpCloseHandle(fRequest);
      fRequest := Nil;
     End;
   Finally
    fLock.Release;
   End;
  End;

 Destructor TOllamaHTTP.Destroy;
  Begin
   AbortRequest;
   WaitFor;
   fLock.Free;
   Inherited;
  End;

 Procedure TOllamaHTTP.Execute;
  Var
   Session    : HINTERNET;
   Connection : HINTERNET;
   Request    : HINTERNET;
   U          : TURI;
   Flags      : DWORD;
   Status     : DWORD;
   Size       : DWORD;
   Available  : DWORD;
   Read       : DWORD;
   Method     : String;
   Data       : TBytes;
   Buffer     : TBytes;
   Output     : TMemoryStream;

   Procedure Check(B : BOOL);
    Begin
     If Not B Then
      RaiseLastOSError;
    End;

  Begin
   Session    := Nil;
   Connection := Nil;
   Output     := TMemoryStream.Create;
   Try
    Try
     U       := TURI.Create(fURL);
     Session := WinHttpOpen('MSFSFDR/1.0', WINHTTP_ACCESS_TYPE_NO_PROXY, Nil, Nil, 0);
     Check(Session <> Nil);
     Check(WinHttpSetTimeouts(Session, 5000, 5000, 5000, 1800000));
     Connection := WinHttpConnect(Session, PChar(U.Host), U.Port, 0);
     Check(Connection <> Nil);
     Flags := 0;
     If SameText(U.Scheme, 'https') Then
      Flags := WINHTTP_FLAG_SECURE;
     Method := 'POST';
     If fBody = '' Then
      Method := 'GET';
     Request := WinHttpOpenRequest(Connection, PChar(Method), PChar(U.Path), Nil, Nil, Nil, Flags);
     Check(Request <> Nil);
     fLock.Acquire;
     Try
      If fAborted Then
       Begin
        WinHttpCloseHandle(Request);
        Raise Exception.Create(Tr('Analiza anulowana.'));
       End;
      fRequest := Request;
     Finally
      fLock.Release;
     End;
     Data := TEncoding.UTF8.GetBytes(fBody);
     If Length(Data) > 0 Then
      Check(WinHttpSendRequest(Request, 'Content-Type: application/json; charset=utf-8'#13#10, DWORD( -1), @Data[0], Length(Data), Length(Data), 0))
     Else
      Check(WinHttpSendRequest(Request, Nil, 0, Nil, 0, 0, 0));
     Check(WinHttpReceiveResponse(Request, Nil));
     Size := SizeOf(Status);
     Check(WinHttpQueryHeaders(Request, WINHTTP_QUERY_STATUS_CODE Or WINHTTP_QUERY_FLAG_NUMBER, Nil, @Status, Size, Nil));
     Repeat
      Available := 0;
      Check(WinHttpQueryDataAvailable(Request, @Available));
      If Available = 0 Then
       Break;
      If Output.Size + Available > 16 * 1024 * 1024 Then
       Raise Exception.Create(Tr('Ollama: odpowiedz przekracza 16 MB.'));
      SetLength(Buffer, Available);
      Check(WinHttpReadData(Request, Buffer[0], Available, @Read));
      If Read = 0 Then
       Break;
      Output.WriteBuffer(Buffer[0], Read);
     Until False;
     SetLength(Buffer, Output.Size);
     If Output.Size > 0 Then
      Move(Output.Memory^, Buffer[0], Output.Size);
     Text := TEncoding.UTF8.GetString(Buffer);
     If Status <> 200 Then
      Raise Exception.CreateFmt('Ollama HTTP %d: %s', [Status, Copy(Text, 1, 2000)]);
    Except
     On E : Exception Do
      Error := E.Message;
    End;
   Finally
    AbortRequest;
    If Connection <> Nil Then
     WinHttpCloseHandle(Connection);
    If Session <> Nil Then
     WinHttpCloseHandle(Session);
    Output.Free;
   End;
  End;

 Function ListOllamaModels(Const BaseURL : String; Const Cancelled : TFunc<Boolean>) : TStringList;
  Var
   Worker  : TOllamaHTTP;
   Started : UInt64;
   JSON    : TJSONValue;
   Models  : TJSONValue;
   Item    : TJSONValue;
   Name    : TJSONValue;
  Begin
   Result := Nil;
   Worker := TOllamaHTTP.Create(OllamaModelsURL(BaseURL), '');
   Try
    Worker.Start;
    Started := GetTickCount64;
    While WaitForSingleObject(Worker.Handle, 50) = WAIT_TIMEOUT Do
     Begin
      If Assigned(Cancelled) And Cancelled() Then
       Begin
        Worker.AbortRequest;
        Raise Exception.Create(Tr('Pobieranie modeli anulowane.'));
       End;
      If GetTickCount64 - Started >= 5000 Then
       Begin
        Worker.AbortRequest;
        Raise Exception.Create(Tr('Ollama: limit czasu pobierania modeli.'));
       End;
     End;
    If Worker.Error <> '' Then
     Raise Exception.Create(Worker.Error);
    JSON := TJSONObject.ParseJSONValue(Worker.Text);
    Try
     If Not(JSON Is TJSONObject) Then
      Raise Exception.Create(Tr('Ollama: nieprawidlowa lista modeli.'));
     Name := TJSONObject(JSON).GetValue('error');
     If Name <> Nil Then
      Raise Exception.Create(Tr('Ollama: ') + Name.Value);
     Models := TJSONObject(JSON).GetValue('models');
     If Not(Models Is TJSONArray) Then
      Raise Exception.Create(Tr('Ollama: brak listy models.'));
     Result               := TStringList.Create;
     Result.CaseSensitive := True;
     Result.Sorted        := True;
     Result.Duplicates    := dupIgnore;
     Try
      For Item In TJSONArray(Models) Do
       Begin
        If Not(Item Is TJSONObject) Then
         Raise Exception.Create(Tr('Ollama: nieprawidlowy model.'));
        Name := TJSONObject(Item).GetValue('name');
        If Not(Name Is TJSONString) Or (Trim(Name.Value) = '') Then
         Raise Exception.Create(Tr('Ollama: brak nazwy modelu.'));
        Result.Add(Name.Value);
       End;
     Except
      FreeAndNil(Result);
      Raise;
     End;
    Finally
     JSON.Free;
    End;
   Finally
    Worker.Free;
   End;
  End;

 Function GenerateOllama(Const BaseURL, Model, Prompt : String; TimeoutSeconds, ContextTokens : Integer; Const Cancelled : TFunc<Boolean>) : String;
  Var
   Body     : TJSONObject;
   Message  : TJSONObject;
   Options  : TJSONObject;
   Messages : TJSONArray;
   Worker   : TOllamaHTTP;
   Started  : UInt64;
   JSON     : TJSONValue;
   V        : TJSONValue;
  Begin
   If Trim(Model) = '' Then
    Raise Exception.Create(Tr('Ollama: wpisz nazwe zainstalowanego modelu w ustawieniach AI.'));
   Body := TJSONObject.Create;
   Try
    Options := TJSONObject.Create;
    Options.AddPair('num_ctx', TJSONNumber.Create(ContextTokens));
    Body.AddPair('options', Options);
    Body.AddPair('model', Trim(Model));
    Body.AddPair('stream', TJSONBool.Create(False));
    Message := TJSONObject.Create;
    Message.AddPair('role', 'user');
    Message.AddPair('content', Prompt);
    Messages := TJSONArray.Create;
    Messages.AddElement(Message);
    Body.AddPair('messages', Messages);
    Worker := TOllamaHTTP.Create(OllamaChatURL(BaseURL), Body.ToJSON);
   Finally
    Body.Free;
   End;
   Try
    Worker.Start;
    Started := GetTickCount64;
    While WaitForSingleObject(Worker.Handle, 50) = WAIT_TIMEOUT Do
     Begin
      If Assigned(Cancelled) And Cancelled() Then
       Begin
        Worker.AbortRequest;
        Raise Exception.Create(Tr('Analiza anulowana.'));
       End;
      If GetTickCount64 - Started >= UInt64(TimeoutSeconds) * 1000 Then
       Begin
        Worker.AbortRequest;
        Raise Exception.Create(Tr('Przekroczono limit czasu analizy Ollama.'));
       End;
     End;
    If Assigned(Cancelled) And Cancelled() Then
     Raise Exception.Create(Tr('Analiza anulowana.'));
    If Worker.Error <> '' Then
     Raise Exception.Create(Worker.Error);
    JSON := TJSONObject.ParseJSONValue(Worker.Text);
    Try
     If Not(JSON Is TJSONObject) Then
      Raise Exception.Create(Tr('Ollama: nieprawidlowa odpowiedz JSON.'));
     V := TJSONObject(JSON).GetValue('error');
     If V <> Nil Then
      Raise Exception.Create(Tr('Ollama: ') + V.Value);
     V := TJSONObject(JSON).GetValue('done');
     If Not(V Is TJSONBool) Or Not TJSONBool(V).AsBoolean Then
      Raise Exception.Create(Tr('Ollama: niekompletna odpowiedz.'));
     V := TJSONObject(JSON).GetValue('message');
     If Not(V Is TJSONObject) Then
      Raise Exception.Create(Tr('Ollama: brak wiadomosci odpowiedzi.'));
     V := TJSONObject(V).GetValue('content');
     If Not(V Is TJSONString) Or (Trim(V.Value) = '') Then
      Raise Exception.Create(Tr('Ollama: pusty raport.'));
     Result := V.Value;
    Finally
     JSON.Free;
    End;
   Finally
    Worker.Free;
   End;
  End;

End.
