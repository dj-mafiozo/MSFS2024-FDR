Program VerifyAnalysis;

{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU In 'TestPathsU.pas', DUnitX.TestFramework, NativeTestRunnerU In 'NativeTestRunnerU.pas',
 Winapi.Windows, System.SysUtils, System.Classes, System.IOUtils, FlightAnalysisU In '..\src\Analysis\FlightAnalysisU.pas', LocalizationU In '..\src\i18n\LocalizationU.pas';

Procedure Require(b : Boolean; Const s : String);
 Begin
  If Not b Then
   Raise Exception.Create(s);
 End;

Procedure Mock;
 Var
  b      : Array [0..1023] Of Byte;
  n      : DWORD;
  Stream : TMemoryStream;
  Bytes  : TBytes;
  Prompt : String;
  Output : String;
  i      : Integer;
 Begin
  Stream := TMemoryStream.Create;

  Try
   While ReadFile(GetStdHandle(STD_INPUT_HANDLE), b, SizeOf(b), n, Nil) And (n > 0) Do
    Stream.WriteBuffer(b, n);

   SetLength(Bytes, Stream.Size);
   Stream.Position := 0;
   If Length(Bytes) > 0 Then
    Stream.ReadBuffer(Bytes[0], Length(Bytes));
   Prompt := TEncoding.UTF8.GetString(Bytes);

  Finally
   Stream.Free;
  End;

  If Pos('TIMEOUT', Prompt) > 0 Then
   Sleep(10000);

  If Pos('FAIL', Prompt) > 0 Then
   Begin
    System.Writeln('mock: brak logowania');
    Halt(7);
   End;

  Require(Pos('RESPONSE LANGUAGE: pl-PL', Prompt) > 0, 'Application language query missing');

  Require(Pos(#$017C#$00F3#$0142#$0107, Prompt) > 0, 'UTF-8 stdin corrupted');

  Output := '';
  For i  := 1 To ParamCount - 1 Do
   If ParamStr(i) = '-o' Then
    Output := ParamStr(i + 1);

  Require(Output <> '', 'Output path missing');

  Require(Pos('exec', CmdLine) > 0, 'exec missing');

  TFile.WriteAllBytes(Output, TEncoding.UTF8.GetBytes('Analiza l' + #$0105 + 'dowania: ' + #$017C#$00F3#$0142#$0107));

 End;

Var
 a       : TAnalysisThread;
 Prompt  : String;
 Started : UInt64;

Type

 [TestFixture]
 TVerifyAnalysisTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyAnalysisTests.Regression;
 Begin
  For Prompt In UILanguageLocales Do
   Begin
    SetLanguage(Prompt);
    Require(Pos('RESPONSE LANGUAGE: ' + Prompt + '.', BuildAnalysisPrompt('{}', 'landing')) > 0, 'AI response language');
   End;
  SetLanguage('pl-PL');

  Prompt := BuildAnalysisPrompt('{"test":"' + #$017C#$00F3#$0142#$0107 + '"}', 'l'#261'dowanie');

  a := TAnalysisThread.Create('codex', '', 'model with spaces', Prompt, ParamStr(0), 10);

  Try
   a.Start;
   a.WaitFor;
   Require(a.Error = '', a.Error);
   Require(a.Report = 'Analiza l' + #$0105 + 'dowania: ' + #$017C#$00F3#$0142#$0107, 'UTF-8 result corrupted');
  Finally
   a.Free;
  End;

  a := TAnalysisThread.Create('codex', '', '', Prompt + ' FAIL', ParamStr(0), 10);

  Try
   a.Start;
   a.WaitFor;
   Require(Pos('7', a.Error) > 0, 'Nonzero exit not reported');
   Require(Pos('brak logowania', a.Error) > 0, 'CLI diagnostic missing');
  Finally
   a.Free;
  End;

  Started := GetTickCount64;
  a       := TAnalysisThread.Create('codex', '', '', Prompt + ' TIMEOUT', ParamStr(0), 1);

  Try
   a.Start;
   a.WaitFor;
   Require(Pos('limit czasu', a.Error) > 0, 'Timeout missing');
   Require(GetTickCount64 - Started < 5000, 'Timeout did not terminate child');
  Finally
   a.Free;
  End;

  a := TAnalysisThread.Create('codex', '', '', Prompt + ' TIMEOUT', ParamStr(0), 10);

  Try
   a.Start;
   Sleep(200);
   a.Terminate;
   a.WaitFor;
   Require(Pos('anulowana', a.Error) > 0, 'Cancellation missing');
  Finally
   a.Free;
  End;

  System.Writeln('PASS: hidden Codex process, UTF-8 Polish query/result, argument quoting, CLI failure, timeout and cancellation. No cloud requests.');

 End;

Begin
 If ParamStr(1) = 'exec' Then
  Mock
 Else
  RunNativeTests(TVerifyAnalysisTests);
End.
