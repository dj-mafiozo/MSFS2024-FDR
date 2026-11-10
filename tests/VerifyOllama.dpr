Program VerifyOllama;

{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU,
 Winapi.Windows, System.SysUtils, System.Classes, System.JSON, System.IniFiles,

 FlightAnalysisU, OllamaAnalysisU, frmSettingsU, IdHTTPServer, IdCustomHTTPServer, IdContext;

Type
 TResponder = Class
  Public
   Mode         : Integer;
   Calls        : Integer;
   ValidRequest : Boolean;
   Procedure Reply(Context : TIdContext; Request : TIdHTTPRequestInfo; Response : TIdHTTPResponseInfo);
 End;

Procedure TResponder.Reply(Context : TIdContext; Request : TIdHTTPRequestInfo; Response : TIdHTTPResponseInfo);
 Var
  j     : TJSONValue;
  v     : TJSONValue;
  m     : TJSONArray;
  Input : TStringStream;
 Begin
  Inc(Calls);
  ValidRequest := False;

  Input := TStringStream.Create('', TEncoding.UTF8);

  Try
   Request.PostStream.Position := 0;
   Input.LoadFromStream(Request.PostStream);

   j := TJSONObject.ParseJSONValue(Input.DataString);
  Finally
   Input.Free;
  End;

  Try
   If j Is TJSONObject Then
    Begin
     v := TJSONObject(j).GetValue('messages');
     If v Is TJSONArray Then
      Begin
       m            := TJSONArray(v);
       ValidRequest := (Request.Document = '/proxy/api/chat') And (Request.Command = 'POST') And (TJSONObject(TJSONObject(j).GetValue('options')).GetValue('num_ctx').Value = '32768') And (TJSONObject(j).GetValue('model').Value = 'test:local') And (TJSONObject(j).GetValue('stream').Value = 'false') And (m.Count = 1) And (Pos('RESPONSE LANGUAGE: pl-PL', TJSONObject(m.Items[0]).GetValue('content').Value) > 0) And (Pos(#$017C#$00F3#$0142#$0107, TJSONObject(m.Items[0]).GetValue('content').Value) > 0);
      End;
    End;

  Finally
   j.Free;
  End;

  Response.ContentType := 'application/json';
  Response.CharSet     := 'utf-8';

  Case Mode Of
   1 :
    Begin
     Response.ResponseNo  := 404;
     Response.ContentText := '{"error":"model missing"}';
    End;
   2 :
    Response.ContentText := 'invalid json';
   3 :
    Response.ContentText := '{"error":"out of memory"}';
   4 :
    Response.ContentText := '{"done":true}';
   5 :
    Response.ContentText := '{"done":true,"message":{"content":" "}}';
   6 :
    Response.ContentText := '{"done":false,"message":{"content":"partial"}}';
   7 :
    Begin
     Sleep(2500);
     Response.ContentText := '{"done":true,"message":{"content":"too late"}}';
    End;
  Else
    Response.ContentText := '{"done":true,"message":{"content":"**Dobre l' + #$0105 + 'dowanie**: ' + #$017C#$00F3#$0142#$0107 + '","thinking":"hidden reasoning"}}';
  End;
 End;

Procedure Check(b : Boolean; Const m : String);
 Begin
  If Not b Then
   Raise Exception.Create(m);
 End;

Var
 Server     : TIdHTTPServer;
 Responder  : TResponder;
 a          : TAnalysisThread;
 Mode       : Integer;
 Started    : UInt64;
 URL        : String;
 Prompt     : String;
 ConfigPath : String;
 Config     : TMemIniFile;
 Settings   : TfrmSettings;

Type

 [TestFixture]
 TVerifyOllamaTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyOllamaTests.Regression;
 Begin
  Check(OllamaChatURL('') = 'http://localhost:11434/api/chat', 'Default URL');
  Check(OllamaChatURL('http://localhost:11434/api/chat/') = 'http://localhost:11434/api/chat', 'No double endpoint');
  Try
   OllamaChatURL('ftp://localhost');
   Raise Exception.Create('Expected bad URL');
  Except
   On E : Exception Do
    Check(Pos('HTTP/HTTPS', E.Message) > 0, 'Invalid URL rejected');
  End;
  ConfigPath := ExtractFilePath(ParamStr(0)) + 'ollama-' + IntToStr(GetTickCount64) + '.ini';
  Config     := TMemIniFile.Create(ConfigPath);
  Settings   := TfrmSettings.Create(Nil);
  Try
   Settings.Load(Config);
   Check(Settings.cbProvider.Items.Count = 3, 'Ollama provider in DFM');
   Check(Settings.eOllamaURL.Text = 'http://localhost:11434', 'Default settings');
   Settings.cbProvider.ItemIndex := 2;
   Settings.eOllamaURL.Text      := 'http://127.0.0.1:11434';
   Settings.cbOllamaModel.Text   := 'test:local';
   Settings.Save(Config);
   Settings.cbProvider.ItemIndex := 0;
   Settings.cbOllamaModel.Clear;
   Settings.Load(Config);
   Check((Settings.cbProvider.ItemIndex = 2) And (Settings.cbOllamaModel.Text = 'test:local') And (Settings.eOllamaURL.Text = 'http://127.0.0.1:11434'), 'Ollama config roundtrip');
  Finally
   Settings.Free;
   Config.Free;
   DeleteFile(PChar(ConfigPath));
  End;
  Prompt    := BuildAnalysisPrompt('{"text":"' + #$017C#$00F3#$0142#$0107 + '"}', 'ladowanie');
  Server    := TIdHTTPServer.Create(Nil);
  Responder := TResponder.Create;
  Try
   Server.Bindings.Add.IP  := '127.0.0.1';
   Server.Bindings[0].Port := 0;
   Server.OnCommandGet     := Responder.Reply;
   Server.Active           := True;

   URL := 'http://127.0.0.1:' + IntToStr(Server.Bindings[0].Port) + '/proxy/';

   For Mode := 0 To 6 Do
    Begin

     Responder.Mode := Mode;
     a              := TAnalysisThread.Create('ollama', '', 'test:local', Prompt, '', 5, URL);

     Try
      a.Start;
      a.WaitFor;
      Check(Responder.ValidRequest, 'Valid UTF-8 Ollama chat request');

      If Mode = 0 Then
       Begin
        Check(a.Error = '', a.Error);
        Check(a.Report = '**Dobre l' + #$0105 + 'dowanie**: ' + #$017C#$00F3#$0142#$0107, 'Polish Markdown result only');
       End

      Else
       Begin
        Check(a.Error <> '', 'Invalid response must fail');
        Check(a.Report = '', 'No partial report saved');

        If Mode = 1 Then
         Check(Pos('404', a.Error) > 0, 'HTTP status');

        If Mode = 3 Then
         Check(Pos('out of memory', a.Error) > 0, 'API error');
       End;

     Finally
      a.Free;
     End;

    End;

   Responder.Mode := 7;
   Started        := GetTickCount64;
   a              := TAnalysisThread.Create('ollama', '', 'test:local', Prompt, '', 1, URL);

   Try
    a.Start;
    a.WaitFor;
    Check(Pos('limit czasu', a.Error) > 0, 'Ollama deadline');
    Check(GetTickCount64 - Started < 2000, 'Deadline aborts pending response');
   Finally
    a.Free;
   End;

   Started := GetTickCount64;
   a       := TAnalysisThread.Create('ollama', '', 'test:local', Prompt, '', 10, URL);

   Try
    a.Start;
    Sleep(150);
    a.Terminate;
    a.WaitFor;
    Check(Pos('anulowana', a.Error) > 0, 'Ollama cancellation');
    Check(GetTickCount64 - Started < 1500, 'Cancellation aborts pending response');
   Finally
    a.Free;
   End;

   a := TAnalysisThread.Create('ollama', '', '', Prompt, '', 1, URL);

   Try
    a.Start;
    a.WaitFor;
    Check(Pos('modelu', a.Error) > 0, 'Missing model is explicit');
   Finally
    a.Free;
   End;

  Finally
   Server.Free;
   Responder.Free;
  End;

  System.Writeln('PASS: Ollama settings/DFM, UTF-8 Polish chat and Markdown, custom URL, HTTP/API/JSON/empty/incomplete errors, model validation, timeout and cancellation. Local mock only.');

 End;

Begin
 RunNativeTests(TVerifyOllamaTests);
End.
