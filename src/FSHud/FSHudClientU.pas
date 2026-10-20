Unit FSHudClientU;

Interface

 Uses
  LocalizationU, System.Classes, System.SysUtils, System.JSON, System.SyncObjs, System.Generics.Collections;

 Type
  TFSHudMessage = Record
   Public
    CapturedUTC : String;
    Payload     : String;
    Kind        : String;
  End;

  TFSHudClient = Class(TThread)
   Private
    fLock   : TCriticalSection;
    fQueue  : TQueue<TFSHudMessage>;
    fSocket : Pointer;
    fStatus : String;
    Procedure Connection;
    Procedure Status(Const Value : String);
   Protected
    Procedure Execute; Override;
   Public
    Constructor Create;
    Destructor Destroy; Override;
    Procedure Abort;
    Procedure Accept(Const JSON : String);
    Function Take : TArray<TFSHudMessage>;
    Function GetStatus : String;
  End;

 Function RecordFSHudKind(Const Kind : String) : Boolean;

Implementation

 Uses
  Winapi.Windows, System.Net.HttpClient, System.RegularExpressions, System.DateUtils, FSHudProtocolU;

 Type
  HINTERNET = Pointer;

 Function WinHttpOpen(Agent : PWideChar; Access : DWORD; Proxy, Bypass : PWideChar; Flags : DWORD) : HINTERNET; Stdcall; External 'winhttp.dll';
 Function WinHttpConnect(H : HINTERNET; Server : PWideChar; Port : Word; Reserved : DWORD) : HINTERNET; Stdcall; External 'winhttp.dll';
 Function WinHttpOpenRequest(H : HINTERNET; Verb, Path, Version, Referrer : PWideChar; Accept : Pointer; Flags : DWORD) : HINTERNET; Stdcall; External 'winhttp.dll';
 Function WinHttpSetTimeouts(H : HINTERNET; Resolve, Connect, Send, Receive : Integer) : BOOL; Stdcall; External 'winhttp.dll';
 Function WinHttpSetOption(H : HINTERNET; Option : DWORD; Data : Pointer; Size : DWORD) : BOOL; Stdcall; External 'winhttp.dll';
 Function WinHttpSendRequest(H : HINTERNET; Headers : PWideChar; Length : DWORD; Data : Pointer; Size, Total : DWORD; Context : NativeUInt) : BOOL; Stdcall; External 'winhttp.dll';
 Function WinHttpReceiveResponse(H : HINTERNET; Reserved : Pointer) : BOOL; Stdcall; External 'winhttp.dll';
 Function WinHttpWebSocketCompleteUpgrade(H : HINTERNET; Context : NativeUInt) : HINTERNET; Stdcall; External 'winhttp.dll';
 Function WinHttpWebSocketSend(H : HINTERNET; Kind : Integer; Buffer : Pointer; Length : DWORD) : DWORD; Stdcall; External 'winhttp.dll';
 Function WinHttpWebSocketReceive(H : HINTERNET; Buffer : Pointer; Length : DWORD; Out Received : DWORD; Out Kind : Integer) : DWORD; Stdcall; External 'winhttp.dll';
 Function WinHttpCloseHandle(H : HINTERNET) : BOOL; Stdcall; External 'winhttp.dll';

 Function RecordFSHudKind(Const Kind : String) : Boolean;
  Begin
   Result := (Kind = 'ApplicationStateMessage') Or (Kind = 'RadioMessagesData') Or (Kind = 'MenuStateMessageData') Or (Kind = 'FlightStepsMessage') Or (Kind = 'RadioPanelData') Or (Kind = 'RadioComChannelsMessageData') Or (Kind = 'FlightPlanningMessageData') Or (Kind = 'FlightSelectionDetailsMessage') Or (Kind = 'UserAircraftDetailsMessage');
  End;

 Constructor TFSHudClient.Create;
  Begin
   Inherited Create(True);
   fLock   := TCriticalSection.Create;
   fQueue  := TQueue<TFSHudMessage>.Create;
   fStatus := 'connecting';
  End;

 Destructor TFSHudClient.Destroy;
  Begin
   Abort;
   If Not Suspended Then
    WaitFor;
   fQueue.Free;
   fLock.Free;
   Inherited;
  End;

 Procedure TFSHudClient.Abort;
  Begin
   Terminate;
   fLock.Enter;
   Try
    If fSocket <> Nil Then
     WinHttpCloseHandle(fSocket);
    fSocket := Nil;
   Finally
    fLock.Leave;
   End;
  End;

 Procedure TFSHudClient.Status(Const Value : String);
  Begin
   fLock.Enter;
   Try
    fStatus := Value;
   Finally
    fLock.Leave;
   End;
  End;

 Function TFSHudClient.GetStatus : String;
  Begin
   fLock.Enter;
   Try
    Result := fStatus;
   Finally
    fLock.Leave;
   End;
  End;

 Procedure TFSHudClient.Accept(Const JSON : String);
  Var
   V       : TJSONValue;
   Data    : TJSONValue;
   Message : TFSHudMessage;
  Begin
   V := TJSONObject.ParseJSONValue(JSON);
   Try
    If Not(V Is TJSONObject) Then
     Raise Exception.Create(Tr('Invalid FSHud JSON'));
    Data := TJSONObject(V).GetValue('MessageData');
    If Not(Data Is TJSONObject) Then
     Exit;
    Message.Kind := TJSONObject(Data).GetValue<String>('DataType', '');
    If Message.Kind = 'ClientValidationResponseMessage' Then
     Begin
      If TJSONObject(Data).GetValue<Boolean>('IsValid', False) Then
       Status('connected')
      Else
       Raise Exception.Create(Tr('FSHud panel version rejected'));
      Exit;
     End;
    If Not RecordFSHudKind(Message.Kind) Then
     Exit;
    If Message.Kind = 'ApplicationStateMessage' Then
     Begin
      TJSONObject(Data).RemovePair('NetworkUrls').Free;
      TJSONObject(Data).RemovePair('MicrophoneRecordingStatus').Free;
      TJSONObject(Data).RemovePair('CloudTrafficSettingsState').Free;
      TJSONObject(Data).RemovePair('MsfsPanelZoomFactor').Free;
     End;
    If Message.Kind = 'FlightPlanningMessageData' Then
     TJSONObject(Data).RemovePair('CurrentSimBriefResponse').Free;
    Message.Payload     := Data.ToJSON;
    Message.CapturedUTC := DateToISO8601(TTimeZone.Local.ToUniversalTime(Now), True);
    fLock.Enter;
    Try
     If fQueue.Count >= 256 Then
      Raise Exception.Create(Tr('FSHud receive queue full'));
     fQueue.Enqueue(Message);
    Finally
     fLock.Leave;
    End;
   Finally
    V.Free;
   End;
  End;

 Function TFSHudClient.Take : TArray<TFSHudMessage>;
  Var
   I : Integer;
  Begin
   fLock.Enter;
   Try
    SetLength(Result, fQueue.Count);
    For I      := 0 To High(Result) Do
     Result[I] := fQueue.Dequeue;
   Finally
    fLock.Leave;
   End;
  End;

 Procedure TFSHudClient.Connection;
  Var
   HTTP     : THTTPClient;
   HTML     : String;
   JS       : String;
   Key      : String;
   Version  : String;
   Frame    : String;
   M        : TMatch;
   Session  : HINTERNET;
   Server   : HINTERNET;
   Request  : HINTERNET;
   WS       : HINTERNET;
   Buffer   : Array [0 .. 65535] Of Byte;
   Bytes    : TBytes;
   Stream   : TMemoryStream;
   Received : DWORD;
   Kind     : Integer;
  Begin
   Session := Nil;
   Server  := Nil;
   Request := Nil;
   WS      := Nil;
   Stream  := Nil;
   HTTP    := THTTPClient.Create;
   Try
    HTTP.ConnectionTimeout := 3000;
    HTTP.ResponseTimeout   := 3000;
    HTML                   := HTTP.Get('http://localhost:19786/').ContentAsString;
    M                      := TRegEx.Match(HTML, 'src="(main\.[a-zA-Z0-9]+\.js)"');
    If Not M.Success Then
     Raise Exception.Create(Tr('Unsupported FSHud panel entry'));
    JS := HTTP.Get('http://localhost:19786/' + M.Groups[1].Value).ContentAsString;
    M  := TRegEx.Match(JS, 'encryptionKey="([^"]{16})"');
    If Not M.Success Then
     Raise Exception.Create(Tr('Unsupported FSHud panel codec'));
    Key := M.Groups[1].Value;
    M   := TRegEx.Match(JS, '"name":"fshud-panel","version":"([^"]+)"');
    If Not M.Success Then
     Raise Exception.Create(Tr('FSHud panel version not found'));
    Version := M.Groups[1].Value;
    Session := WinHttpOpen('MSFS FDR read-only FSHud', 1, Nil, Nil, 0);
    If Session = Nil Then
     RaiseLastOSError;
    WinHttpSetTimeouts(Session, 3000, 3000, 3000, 10000);
    Server := WinHttpConnect(Session, 'localhost', 19786, 0);
    If Server = Nil Then
     RaiseLastOSError;
    Request := WinHttpOpenRequest(Server, 'GET', '/ws', Nil, Nil, Nil, 0);
    If Request = Nil Then
     RaiseLastOSError;
    If Not WinHttpSetOption(Request, 114, Nil, 0) Then
     RaiseLastOSError;
    If Not WinHttpSendRequest(Request, Nil, 0, Nil, 0, 0, 0) Then
     RaiseLastOSError;
    If Not WinHttpReceiveResponse(Request, Nil) Then
     RaiseLastOSError;
    WS := WinHttpWebSocketCompleteUpgrade(Request, 0);
    If WS = Nil Then
     RaiseLastOSError;
    fLock.Enter;
    Try
     fSocket := WS;
     If Terminated Then
      Exit;
    Finally
     fLock.Leave;
    End;
    Frame := FSHudEncode('{"MessageData":{"DataType":"ClientValidationRequestMessage","Version":"' + Version + '"}}', Key);
    Bytes := TEncoding.UTF8.GetBytes(Frame);
    If WinHttpWebSocketSend(WS, 2, @Bytes[0], Length(Bytes)) <> 0 Then
     Raise Exception.Create(Tr('FSHud handshake failed'));
    Stream := TMemoryStream.Create;
    While Not Terminated Do
     Begin
      If WinHttpWebSocketReceive(WS, @Buffer[0], SizeOf(Buffer), Received, Kind) <> 0 Then
       Raise Exception.Create(Tr('FSHud socket closed'));
      If Kind = 4 Then
       Exit;
      If Not(Kind In [2, 3]) Then
       Raise Exception.Create(Tr('Unsupported FSHud frame'));
      If Stream.Size + Received > 2 * 1024 * 1024 Then
       Raise Exception.Create(Tr('FSHud frame too large'));
      Stream.WriteBuffer(Buffer, Received);
      If Kind = 2 Then
       Begin
        SetLength(Bytes, Stream.Size);
        If Length(Bytes) > 0 Then
         Move(Stream.Memory^, Bytes[0], Length(Bytes));
        Accept(FSHudDecode(TEncoding.UTF8.GetString(Bytes), Key));
        Stream.Clear;
       End;
     End;
   Finally
    fLock.Enter;
    Try
     If fSocket = WS Then
      Begin
       If WS <> Nil Then
        WinHttpCloseHandle(WS);
       fSocket := Nil;
      End;
    Finally
     fLock.Leave;
    End;
    Stream.Free;
    If Request <> Nil Then
     WinHttpCloseHandle(Request);
    If Server <> Nil Then
     WinHttpCloseHandle(Server);
    If Session <> Nil Then
     WinHttpCloseHandle(Session);
    HTTP.Free;
   End;
  End;

 Procedure TFSHudClient.Execute;
  Var
   I : Integer;
  Begin
   While Not Terminated Do
    Begin
     Try
      Status('connecting');
      Connection;
      Status('disconnected');
     Except
      On E : Exception Do
       Status('unavailable: ' + E.Message);
     End;
     For I := 1 To 50 Do
      Begin
       If Terminated Then
        Exit;
       Sleep(100);
      End;
    End;
  End;

End.
