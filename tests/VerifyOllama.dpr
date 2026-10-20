program VerifyOllama;

{$APPTYPE CONSOLE}

uses Winapi.Windows,System.SysUtils,System.Classes,System.JSON,System.IniFiles,

  FlightAnalysisU,OllamaAnalysisU,frmSettingsU,IdHTTPServer,IdCustomHTTPServer,IdContext;

type TResponder=class

  Mode,Calls:Integer;

  ValidRequest:Boolean;

  procedure Reply(Context:TIdContext;Request:TIdHTTPRequestInfo;Response:TIdHTTPResponseInfo);

end;

procedure TResponder.Reply(Context:TIdContext;Request:TIdHTTPRequestInfo;Response:TIdHTTPResponseInfo);

var J,V:TJSONValue;M:TJSONArray;Input:TStringStream;

begin

  Inc(Calls);ValidRequest:=False;

  Input:=TStringStream.Create('',TEncoding.UTF8);

  try Request.PostStream.Position:=0;Input.LoadFromStream(Request.PostStream);

    J:=TJSONObject.ParseJSONValue(Input.DataString);

  finally Input.Free;end;

  try

    if J is TJSONObject then begin

      V:=TJSONObject(J).GetValue('messages');

      if V is TJSONArray then begin M:=TJSONArray(V);

        ValidRequest:=(Request.Document='/proxy/api/chat') and (Request.Command='POST') and

          (TJSONObject(TJSONObject(J).GetValue('options')).GetValue('num_ctx').Value='32768') and

          (TJSONObject(J).GetValue('model').Value='test:local') and

          (TJSONObject(J).GetValue('stream').Value='false') and (M.Count=1) and

          (Pos('po polsku',TJSONObject(M.Items[0]).GetValue('content').Value)>0) and

          (Pos(#$017C#$00F3#$0142#$0107,TJSONObject(M.Items[0]).GetValue('content').Value)>0);

      end;

    end;

  finally J.Free;end;

  Response.ContentType:='application/json';Response.CharSet:='utf-8';

  case Mode of

    1:begin Response.ResponseNo:=404;Response.ContentText:='{"error":"model missing"}';end;

    2:Response.ContentText:='invalid json';

    3:Response.ContentText:='{"error":"out of memory"}';

    4:Response.ContentText:='{"done":true}';

    5:Response.ContentText:='{"done":true,"message":{"content":" "}}';

    6:Response.ContentText:='{"done":false,"message":{"content":"partial"}}';

    7:begin Sleep(2500);Response.ContentText:='{"done":true,"message":{"content":"too late"}}';end;

  else Response.ContentText:='{"done":true,"message":{"content":"**Dobre l'+#$0105+'dowanie**: '+#$017C#$00F3#$0142#$0107+'","thinking":"hidden reasoning"}}';end;

end;

procedure Check(B:Boolean;const M:string);

begin if not B then raise Exception.Create(M);end;

var Server:TIdHTTPServer;Responder:TResponder;A:TAnalysisThread;Mode:Integer;

  Started:UInt64;URL,Prompt,ConfigPath:string;Config:TMemIniFile;Settings:TfrmSettings;

begin

  Check(OllamaChatURL('')='http://localhost:11434/api/chat','Default URL');

  Check(OllamaChatURL('http://localhost:11434/api/chat/')='http://localhost:11434/api/chat','No double endpoint');

  try OllamaChatURL('ftp://localhost');raise Exception.Create('Expected bad URL');

  except on E:Exception do Check(Pos('HTTP/HTTPS',E.Message)>0,'Invalid URL rejected');end;

  ConfigPath:=ExtractFilePath(ParamStr(0))+'ollama-'+IntToStr(GetTickCount64)+'.ini';

  Config:=TMemIniFile.Create(ConfigPath);Settings:=TfrmSettings.Create(nil);

  try

    Settings.Load(Config);Check(Settings.cbProvider.Items.Count=3,'Ollama provider in DFM');

    Check(Settings.eOllamaURL.Text='http://localhost:11434','Default settings');

    Settings.cbProvider.ItemIndex:=2;Settings.eOllamaURL.Text:='http://127.0.0.1:11434';

    Settings.cbOllamaModel.Text:='test:local';Settings.Save(Config);Settings.cbProvider.ItemIndex:=0;

    Settings.cbOllamaModel.Clear;Settings.Load(Config);

    Check((Settings.cbProvider.ItemIndex=2) and (Settings.cbOllamaModel.Text='test:local') and

      (Settings.eOllamaURL.Text='http://127.0.0.1:11434'),'Ollama config roundtrip');

  finally Settings.Free;Config.Free;DeleteFile(PChar(ConfigPath));end;

  Prompt:=BuildAnalysisPrompt('{"text":"'+#$017C#$00F3#$0142#$0107+'"}','ladowanie');

  Server:=TIdHTTPServer.Create(nil);Responder:=TResponder.Create;

  try

    Server.Bindings.Add.IP:='127.0.0.1';Server.Bindings[0].Port:=0;

    Server.OnCommandGet:=Responder.Reply;Server.Active:=True;

    URL:='http://127.0.0.1:'+IntToStr(Server.Bindings[0].Port)+'/proxy/';

    for Mode:=0 to 6 do begin

      Responder.Mode:=Mode;A:=TAnalysisThread.Create('ollama','','test:local',Prompt,'',5,URL);

      try A.Start;A.WaitFor;Check(Responder.ValidRequest,'Valid UTF-8 Ollama chat request');

        if Mode=0 then begin Check(A.Error='',A.Error);Check(A.Report='**Dobre l'+#$0105+'dowanie**: '+#$017C#$00F3#$0142#$0107,'Polish Markdown result only');end

        else begin Check(A.Error<>'','Invalid response must fail');Check(A.Report='','No partial report saved');

          if Mode=1 then Check(Pos('404',A.Error)>0,'HTTP status');

          if Mode=3 then Check(Pos('out of memory',A.Error)>0,'API error');end;

      finally A.Free;end;

    end;

    Responder.Mode:=7;Started:=GetTickCount64;A:=TAnalysisThread.Create('ollama','','test:local',Prompt,'',1,URL);

    try A.Start;A.WaitFor;Check(Pos('limit czasu',A.Error)>0,'Ollama deadline');Check(GetTickCount64-Started<2000,'Deadline aborts pending response');finally A.Free;end;

    Started:=GetTickCount64;A:=TAnalysisThread.Create('ollama','','test:local',Prompt,'',10,URL);

    try A.Start;Sleep(150);A.Terminate;A.WaitFor;Check(Pos('anulowana',A.Error)>0,'Ollama cancellation');Check(GetTickCount64-Started<1500,'Cancellation aborts pending response');finally A.Free;end;

    A:=TAnalysisThread.Create('ollama','','',Prompt,'',1,URL);

    try A.Start;A.WaitFor;Check(Pos('modelu',A.Error)>0,'Missing model is explicit');finally A.Free;end;

  finally Server.Free;Responder.Free;end;

  Writeln('PASS: Ollama settings/DFM, UTF-8 Polish chat and Markdown, custom URL, HTTP/API/JSON/empty/incomplete errors, model validation, timeout and cancellation. Local mock only.');

end.

