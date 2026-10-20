program VerifyOllamaModels;
{$APPTYPE CONSOLE}
uses Winapi.Windows,System.SysUtils,System.Classes,OllamaAnalysisU,frmSettingsU,
  IdHTTPServer,IdCustomHTTPServer,IdContext;
type TResponder=class
  Mode,Calls:Integer;
  procedure Reply(Context:TIdContext;Request:TIdHTTPRequestInfo;Response:TIdHTTPResponseInfo);
end;
procedure TResponder.Reply(Context:TIdContext;Request:TIdHTTPRequestInfo;Response:TIdHTTPResponseInfo);
begin
  Inc(Calls);Response.ContentType:='application/json';
  if (Request.Command<>'GET') or (Copy(Request.Document,Length(Request.Document)-8,9)<>'/api/tags') then
  begin Response.ResponseNo:=400;Exit;end;
  if Pos('/slow/',Request.Document)>0 then Sleep(1500);
  case Mode of
    1:Response.ContentText:='{"models":[]}';
    2:Response.ContentText:='invalid json';
    3:Response.ContentText:='{}';
    4:Response.ContentText:='{"models":[{"name":""}]}';
    5:begin Response.ResponseNo:=503;Response.ContentText:='{"error":"unavailable"}';end;
  else Response.ContentText:='{"models":[{"name":"zeta:latest"},{"name":"alpha:8b"},{"name":"alpha:8b"}]}';end;
end;
procedure Check(B:Boolean;const M:string);
begin if not B then raise Exception.Create(M);end;
procedure WaitUI(F:TfrmSettings);
var Started:UInt64;
begin
  Started:=GetTickCount64;
  repeat F.ModelsTick(nil);Sleep(10);until not F.ModelsTimer.Enabled or (GetTickCount64-Started>6000);
  Check(not F.ModelsTimer.Enabled,'Model fetch completed');
end;
var Server:TIdHTTPServer;Responder:TResponder;Models:TStringList;F:TfrmSettings;
  URL:string;Mode:Integer;Started:UInt64;Worker:TOllamaModelsThread;
begin
  Check(OllamaModelsURL('http://localhost:11434/')='http://localhost:11434/api/tags','Tags URL');
  Check(OllamaModelsURL('http://localhost:11434/proxy/api/chat')='http://localhost:11434/proxy/api/tags','Proxy and chat URL');
  Server:=TIdHTTPServer.Create(nil);Responder:=TResponder.Create;
  try
    Server.Bindings.Add.IP:='127.0.0.1';Server.Bindings[0].Port:=0;
    Server.OnCommandGet:=Responder.Reply;Server.Active:=True;
    URL:='http://127.0.0.1:'+IntToStr(Server.Bindings[0].Port);
    Models:=ListOllamaModels(URL+'/proxy',nil);
    try Check((Models.Count=2) and (Models[0]='alpha:8b') and (Models[1]='zeta:latest'),'Sorted unique installed models');finally Models.Free;end;
    for Mode:=1 to 5 do begin
      Responder.Mode:=Mode;
      if Mode=1 then begin Models:=ListOllamaModels(URL,nil);try Check(Models.Count=0,'Empty installed models');finally Models.Free;end;end
      else begin
        Models:=nil;
        try Models:=ListOllamaModels(URL,nil);raise Exception.Create('Expected error');
        except on E:Exception do Check(E.Message<>'Expected error','Bad list response rejected');end;
        Models.Free;
      end;
    end;
    Responder.Mode:=0;F:=TfrmSettings.Create(nil);
    try
      F.eOllamaURL.Text:=URL+'/proxy';F.cbOllamaModel.Text:='zeta:latest';
      Started:=GetTickCount64;F.RefreshOllamaModels(nil);
      Check(GetTickCount64-Started<500,'Refresh does not block UI');WaitUI(F);
      Check(F.cbOllamaModel.Items.Count=2,'Combo populated');Check(F.cbOllamaModel.Text='zeta:latest','Existing selection preserved');
      F.cbOllamaModel.ItemIndex:=0;Check(F.cbOllamaModel.Text='alpha:8b','Dropdown selection');
      F.cbOllamaModel.Text:='missing:old';F.RefreshOllamaModels(nil);WaitUI(F);
      Check(F.cbOllamaModel.Text='missing:old','Missing configured model retained');
      Check(Pos('nie wystepuje',F.lHelp.Caption)>0,'Missing model feedback');
      Responder.Mode:=1;F.RefreshOllamaModels(nil);WaitUI(F);
      Check((F.cbOllamaModel.Items.Count=0) and (Pos('brak zainstalowanych',F.lHelp.Caption)>0),'Empty list feedback');
      Responder.Mode:=5;F.RefreshOllamaModels(nil);WaitUI(F);Check(Pos('503',F.lHelp.Caption)>0,'Connection error feedback');
      Responder.Mode:=0;F.eOllamaURL.Text:=URL+'/slow';F.RefreshOllamaModels(nil);Sleep(100);
      F.eOllamaURL.Text:=URL+'/proxy';F.RefreshOllamaModels(nil);WaitUI(F);
      Check(F.cbOllamaModel.Items.Count=2,'URL change cancels old fetch and applies new server');
      F.eOllamaURL.Text:=URL+'/slow';F.RefreshOllamaModels(nil);Sleep(100);
      Started:=GetTickCount64;
    finally F.Free;end;
    Check(GetTickCount64-Started<1000,'Close settings cancels pending request');
    Worker:=TOllamaModelsThread.Create(URL+'/slow');Worker.Start;Sleep(100);Started:=GetTickCount64;
    Worker.Terminate;Worker.Free;Check(GetTickCount64-Started<1000,'Model worker cancellation');
  finally Server.Free;Responder.Free;end;
  Writeln('PASS: Ollama GET tags, proxy URLs, sorted/deduplicated models, empty/malformed/HTTP failures, async dropdown, selection retention, URL replacement and close/cancellation. Local mock only.');
end.
