Program VerifyOllamaModels;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU In 'TestPathsU.pas', DUnitX.TestFramework, NativeTestRunnerU In 'NativeTestRunnerU.pas',
 Winapi.Windows, System.SysUtils, System.Classes, OllamaAnalysisU In '..\src\Analysis\OllamaAnalysisU.pas', frmSettingsU In '..\src\Forms\frmSettingsU.pas',
 IdHTTPServer, IdCustomHTTPServer, IdContext;

Type
 TResponder = Class
  Mode  : Integer;
  Calls : Integer;
  Procedure Reply(Context : TIdContext; Request : TIdHTTPRequestInfo; Response : TIdHTTPResponseInfo);
 End;

Procedure TResponder.Reply(Context : TIdContext; Request : TIdHTTPRequestInfo; Response : TIdHTTPResponseInfo);
 Begin
  Inc(Calls);
  Response.ContentType := 'application/json';
  If (Request.Command <> 'GET') Or (Copy(Request.Document, Length(Request.Document) - 8, 9) <> '/api/tags') Then
   Begin
    Response.ResponseNo := 400;
    Exit;
   End;
  If Pos('/slow/', Request.Document) > 0 Then
   Sleep(1500);
  Case Mode Of
   1 :
    Response.ContentText := '{"models":[]}';
   2 :
    Response.ContentText := 'invalid json';
   3 :
    Response.ContentText := '{}';
   4 :
    Response.ContentText := '{"models":[{"name":""}]}';
   5 :
    Begin
     Response.ResponseNo  := 503;
     Response.ContentText := '{"error":"unavailable"}';
    End;
  Else
    Response.ContentText := '{"models":[{"name":"zeta:latest"},{"name":"alpha:8b"},{"name":"alpha:8b"}]}';
  End;
 End;

Procedure Check(b : Boolean; Const m : String);
 Begin
  If Not b Then
   Raise Exception.Create(m);
 End;

Procedure WaitUI(f : TfrmSettings);
 Var
  Started : UInt64;
 Begin
  Started := GetTickCount64;
  Repeat
   f.ModelsTick(Nil);
   Sleep(10);
  Until Not f.ModelsTimer.Enabled Or (GetTickCount64 - Started > 6000);
  Check(Not f.ModelsTimer.Enabled, 'Model fetch completed');
 End;

Var
 Server    : TIdHTTPServer;
 Responder : TResponder;
 Models    : TStringList;
 f         : TfrmSettings;
 URL       : String;
 Mode      : Integer;
 Started   : UInt64;
 Worker    : TOllamaModelsThread;

Type

 [TestFixture]
 TVerifyOllamaModelsTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyOllamaModelsTests.Regression;
 Begin
  Check(OllamaModelsURL('http://localhost:11434/') = 'http://localhost:11434/api/tags', 'Tags URL');
  Check(OllamaModelsURL('http://localhost:11434/proxy/api/chat') = 'http://localhost:11434/proxy/api/tags', 'Proxy and chat URL');
  Server    := TIdHTTPServer.Create(Nil);
  Responder := TResponder.Create;
  Try
   Server.Bindings.Add.IP  := '127.0.0.1';
   Server.Bindings[0].Port := 0;
   Server.OnCommandGet     := Responder.Reply;
   Server.Active           := True;
   URL                     := 'http://127.0.0.1:' + IntToStr(Server.Bindings[0].Port);
   Models                  := ListOllamaModels(URL + '/proxy', Nil);
   Try
    Check((Models.Count = 2) And (Models[0] = 'alpha:8b') And (Models[1] = 'zeta:latest'), 'Sorted unique installed models');
   Finally
    Models.Free;
   End;
   For Mode := 1 To 5 Do
    Begin
     Responder.Mode := Mode;
     If Mode = 1 Then
      Begin
       Models := ListOllamaModels(URL, Nil);
       Try
        Check(Models.Count = 0, 'Empty installed models');
       Finally
        Models.Free;
       End;
      End
     Else
      Begin
       Models := Nil;
       Try
        Models := ListOllamaModels(URL, Nil);
        Raise Exception.Create('Expected error');
       Except
        On E : Exception Do
         Check(E.Message <> 'Expected error', 'Bad list response rejected');
       End;
       Models.Free;
      End;
    End;
   Responder.Mode := 0;
   f              := TfrmSettings.Create(Nil);
   Try
    f.eOllamaURL.Text    := URL + '/proxy';
    f.cbOllamaModel.Text := 'zeta:latest';
    Started              := GetTickCount64;
    f.RefreshOllamaModels(Nil);
    Check(GetTickCount64 - Started < 500, 'Refresh does not block UI');
    WaitUI(f);
    Check(f.cbOllamaModel.Items.Count = 2, 'Combo populated');
    Check(f.cbOllamaModel.Text = 'zeta:latest', 'Existing selection preserved');
    f.cbOllamaModel.ItemIndex := 0;
    Check(f.cbOllamaModel.Text = 'alpha:8b', 'Dropdown selection');
    f.cbOllamaModel.Text := 'missing:old';
    f.RefreshOllamaModels(Nil);
    WaitUI(f);
    Check(f.cbOllamaModel.Text = 'missing:old', 'Missing configured model retained');
    Check(Pos('nie wystepuje', f.lHelp.Caption) > 0, 'Missing model feedback');
    Responder.Mode := 1;
    f.RefreshOllamaModels(Nil);
    WaitUI(f);
    Check((f.cbOllamaModel.Items.Count = 0) And (Pos('brak zainstalowanych', f.lHelp.Caption) > 0), 'Empty list feedback');
    Responder.Mode := 5;
    f.RefreshOllamaModels(Nil);
    WaitUI(f);
    Check(Pos('503', f.lHelp.Caption) > 0, 'Connection error feedback');
    Responder.Mode    := 0;
    f.eOllamaURL.Text := URL + '/slow';
    f.RefreshOllamaModels(Nil);
    Sleep(100);
    f.eOllamaURL.Text := URL + '/proxy';
    f.RefreshOllamaModels(Nil);
    WaitUI(f);
    Check(f.cbOllamaModel.Items.Count = 2, 'URL change cancels old fetch and applies new server');
    f.eOllamaURL.Text := URL + '/slow';
    f.RefreshOllamaModels(Nil);
    Sleep(100);
    Started := GetTickCount64;
   Finally
    f.Free;
   End;
   Check(GetTickCount64 - Started < 1000, 'Close settings cancels pending request');
   Worker := TOllamaModelsThread.Create(URL + '/slow');
   Worker.Start;
   Sleep(100);
   Started := GetTickCount64;
   Worker.Terminate;
   Worker.Free;
   Check(GetTickCount64 - Started < 1000, 'Model worker cancellation');
  Finally
   Server.Free;
   Responder.Free;
  End;
  System.Writeln('PASS: Ollama GET tags, proxy URLs, sorted/deduplicated models, empty/malformed/HTTP failures, async dropdown, selection retention, URL replacement and close/cancellation. Local mock only.');

 End;

Begin
 RunNativeTests(TVerifyOllamaModelsTests);
End.
