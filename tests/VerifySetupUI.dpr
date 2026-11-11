Program VerifySetupUI;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU In 'TestPathsU.pas', DUnitX.TestFramework, NativeTestRunnerU In 'NativeTestRunnerU.pas', FDRSetupProductU In '..\..\MSFS2024-FDR-Setup\src\FDRSetupProductU.pas', Winapi.Windows, System.SysUtils, System.Classes, System.IOUtils, Vcl.Forms, Vcl.ExtCtrls, System.UITypes, frmSetupRunningU In '..\..\setup-core\src\frmSetupRunningU.pas',
 IdHTTPServer, IdCustomHTTPServer, IdContext, UpdateProtocolU In '..\..\setup-common\src\UpdateProtocolU.pas', SetupPlatformU In '..\..\MSFS2024-FDR-Setup\src\SetupPlatformU.pas', frmSetupU In '..\..\MSFS2024-FDR-Setup\src\frmSetupU.pas', SetupLocalizationU In '..\..\MSFS2024-FDR-Setup\src\SetupLocalizationU.pas';

Type
 TResponder = Class
  Calls : Integer;
  Mode  : Integer;
  Procedure Reply(Context : TIdContext; Request : TIdHTTPRequestInfo; Response : TIdHTTPResponseInfo);
 End;

Procedure TResponder.Reply(Context : TIdContext; Request : TIdHTTPRequestInfo; Response : TIdHTTPResponseInfo);
 Begin
  Inc(Calls);
  Sleep(100);
  If (Mode = 0) Or (Request.Document = '/asset') Then
   Begin
    Response.ResponseNo  := 503;
    Response.ContentText := 'unavailable';
    Exit;
   End;
  Response.ContentType := 'application/json';
  If Mode = 1 Then
   Response.ContentText := '{"tag_name":"v0.0.0","assets":[{"name":"MSFS2024-FDR-Win64-0.0.0.zip","browser_download_url":"https://github.com/dj-mafiozo/MSFS2024-FDR/releases/download/v0.0.0/app.zip","size":10}]}'
  Else
   Response.ContentText := '{"tag_name":"v99.0.0","assets":[{"name":"MSFS2024-FDR-Win64-99.0.0.zip","browser_download_url":"https://github.com/dj-mafiozo/MSFS2024-FDR/releases/download/v99.0.0/app.zip","size":10}]}';
 End;

Procedure Check(b : Boolean; Const Msg : String);
 Begin
  If Not b Then
   Raise Exception.Create(Msg);
 End;

Type
 TModalDriver = Class
  Timer      : TTimer;
  Mutex      : THandle;
  Calls      : Integer;
  CancelTest : Boolean;
  Procedure Tick(Sender : TObject);
 End;

Procedure TModalDriver.Tick(Sender : TObject);
 Var
  d : TfrmSetupRunning;
 Begin
  If Not(Screen.ActiveCustomForm Is TfrmSetupRunning) Then
   Exit;
  d := TfrmSetupRunning(Screen.ActiveCustomForm);
  Inc(Calls);
  Check((d.BorderStyle = bsDialog) And (d.btnRetry.ModalResult = mrRetry) And (d.btnCancel.ModalResult = mrCancel), 'DFM modal Retry/Cancel contract');
  If CancelTest Then
   d.btnCancel.Click
  Else
   Begin
    If Calls = 3 Then
     Begin
      CloseHandle(Mutex);
      Mutex := 0;
     End;
    d.btnRetry.Click;
   End;
 End;

Procedure TestRunningDialog;
 Var
  Driver    : TModalDriver;
  f         : TfrmSetup;
  Cancelled : Boolean;
 Begin
  Driver       := TModalDriver.Create;
  f            := TfrmSetup.Create(Nil);
  Driver.Timer := TTimer.Create(Nil);
  Try
   Driver.Mutex := AcquireRecorderMutex;
   Check(Driver.Mutex <> 0, 'Isolated recorder lock');
   Driver.Timer.Interval := 30;
   Driver.Timer.OnTimer  := Driver.Tick;
   Driver.Timer.Enabled  := True;
   f.WaitForRecorderForTest;
   Check(Driver.Calls = 3, 'Retry repeats until recorder exits');
   Check(Not RecorderRunning(''), 'Recorder exit permits continuation');
   Driver.Mutex      := AcquireRecorderMutex;
   Driver.CancelTest := True;
   Driver.Calls      := 0;
   Cancelled         := False;
   Try
    f.WaitForRecorderForTest;
   Except
    On E : EAbort Do
     Cancelled := True;
   End;
   Check(Cancelled And (Driver.Calls = 1), 'Cancel aborts operation');
   Check(RecorderRunning(''), 'Cancel leaves recorder alive');
  Finally
   Driver.Timer.Free;
   If Driver.Mutex <> 0 Then
    CloseHandle(Driver.Mutex);
   f.Free;
   Driver.Free;
  End;
  System.Writeln('PASS: actual DFM modal loop: three retries, release, cancellation without stopping recorder.');
 End;

Var
 f         : TfrmSetup;
 Server    : TIdHTTPServer;
 Responder : TResponder;
 UntilTime : UInt64;
 Ticks     : Integer;
 Mode      : Integer;
 Launch    : String;
 URL       : String;

Type

 [TestFixture]
 TVerifySetupUITests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifySetupUITests.Regression;
 Begin
  Try
   Application.Initialize;
   TestRunningDialog;
   f := TfrmSetup.Create(Nil);
   Try
    Check(f.cbBridge.Checked, 'Bridge checkbox defaults on');
    Check(f.eCommunity.Parent = f.SimulatorPage, 'Community path in DFM');
    Check(f.Pages.PageCount = 6, 'Wizard pages in DFM');
    Check(f.cbStartMenu.Checked And f.cbDesktop.Checked And f.cbSimulator.Checked, 'Optional tasks default on');
    f.NextClick(Nil);
    Check(f.Pages.ActivePage = f.OptionsPage, 'Welcome advances to options');
    Check(f.InstallPath.Text = InstallDirectory, 'Program Files target shown');
    f.NextClick(Nil);
    Check(f.Pages.ActivePage = f.SimulatorPage, 'Product options follow generic options');
    f.BackClick(Nil);
    Check(f.Pages.ActivePage = f.OptionsPage, 'Back from product options');
    f.cbDesktop.Checked := False;
    Check(Not f.cbDesktop.Checked, 'Desktop option can be disabled');
    f.BackClick(Nil);
    Check(f.Pages.ActivePage = f.WelcomePage, 'Back navigation');
   Finally
    f.Free;
   End;
   ForceDirectories(InstallDirectory);
   TFile.Copy(TestRepositoryPath('bin\' + MainExeName), TPath.Combine(InstallDirectory, MainExeName));
   Server    := TIdHTTPServer.Create(Nil);
   Responder := TResponder.Create;
   Try
    Server.Bindings.Clear;
    With Server.Bindings.Add Do
     Begin
      IP   := '127.0.0.1';
      Port := 0;
     End;
    Server.OnCommandGet := Responder.Reply;
    Server.Active       := True;
    URL                 := 'http://127.0.0.1:' + IntToStr(Server.Bindings[0].Port);
    SetEnvironmentVariable('SETUP_TEST_RELEASE_URL', PChar(URL + '/latest'));
    SetEnvironmentVariable('SETUP_TEST_ASSET_URL', PChar(URL + '/asset'));
    For Mode := 0 To 2 Do
     Begin
      Responder.Mode  := Mode;
      Responder.Calls := 0;
      f               := TfrmSetup.Create(Nil);
      Try
       f.UpdateForTest;
       Check((f.ClientWidth = 440) And (f.ClientHeight = 130), 'Small update window geometry');
       Check(f.MiniText.Caption = ST('Updating...'), 'Polish DFM text encoding');
       f.Show;
       UntilTime := GetTickCount64 + 10000;
       Ticks     := 0;
       While f.Visible And (GetTickCount64 < UntilTime) Do
        Begin
         Application.ProcessMessages;
         Inc(Ticks);
         Sleep(5);
        End;
       Check(Not f.Visible, 'Updater completed fallback');
       Check(Ticks > 10, 'VCL heartbeat during network check');
       Check(Responder.Calls = 1 + Ord(Mode = 2), 'Expected isolated API and asset requests');
       Launch := TFile.ReadAllText(TPath.Combine(TestDataDirectory, 'launch.txt'), TEncoding.UTF8);
       Check(Pos(MainExeName, Launch) > 0, 'Installed app launched on API failure');
       Check(Pos('/NoUpdate', Launch) > 0, 'No update loop');
       Check(Pos('False', Launch) > 0, 'Fallback launch not elevated');
      Finally
       f.Free;
      End;
     End;
   Finally
    Server.Free;
    Responder.Free;
   End;
   System.Writeln('PASS: DFM wizard navigation/options, asynchronous small updater, VCL heartbeat and non-elevated installed-version fallback on API failure. Test doubles only.');
  Except
   On E : Exception Do
    Begin
     System.Writeln(E.ClassName + ': ' + E.Message);
     Raise Exception.Create('Regression failed; see diagnostic above');
    End;
  End;

 End;

Begin
 RunNativeTests(TVerifySetupUITests);
End.
