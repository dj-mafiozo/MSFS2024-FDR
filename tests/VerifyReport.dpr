Program VerifyReport;

{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU In 'TestPathsU.pas', DUnitX.TestFramework, NativeTestRunnerU In 'NativeTestRunnerU.pas',
 LocalizationU In '..\src\i18n\LocalizationU.pas', Winapi.Windows, System.SysUtils, Vcl.Forms, frmReportU In '..\src\Forms\frmReportU.pas', ReportMarkdownU In '..\src\Analysis\ReportMarkdownU.pas', HelpScreenshotU In 'HelpScreenshotU.pas', Vcl.Graphics;

Procedure Require(b : Boolean; Const s : String);
 Begin
  If Not b Then
   Raise Exception.Create(s);
 End;

Type
 TProbe = Class
  Closed : Boolean;
  Procedure Destroyed(Sender : TObject);
 End;

Procedure TProbe.Destroyed(Sender : TObject);
 Begin
  Closed := True;
 End;

Var
 f       : TfrmReport;
 p       : TProbe;
 h       : String;
 Started : UInt64;
 Image   : TBitmap;

Type

 [TestFixture]
 TVerifyReportTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyReportTests.Regression;
 Begin

  h := ReportHTML('# Ocena' + sLineBreak + '**Dobrze** i `IAS`' + sLineBreak + '- punkt' + sLineBreak + '1. wskazowka' + sLineBreak + '<script>alert(1)</script>');

  Require(Pos('<h1>Ocena</h1>', h) > 0, 'Heading');
  Require(Pos('<strong>Dobrze</strong>', h) > 0, 'Bold');
  Require(Pos('<code>IAS</code>', h) > 0, 'Inline code');
  Require(Pos('<ul><li>punkt</li></ul>', h) > 0, 'Bullet list');
  Require(Pos('<ol>', h) > 0, 'Ordered list');
  Require(Pos('<script>', h) = 0, 'Raw HTML must be escaped');

  Application.Initialize;
  p := TProbe.Create;
  f := TfrmReport.Create(Nil);

  f.SetReport('Takeoff', False);
  Require(f.Caption = 'Analiza startu', 'Takeoff title');
  SetLanguage('en-US');
  Require(f.Caption = 'Takeoff analysis', 'Live takeoff title');
  f.SetReport('Landing', True);
  Require(f.Caption = 'Landing analysis', 'Landing title');
  SetLanguage('de-DE');
  Require(f.Caption = 'Landeanalyse', 'German landing title');
  SetLanguage('es-ES');
  Require(f.Caption = 'Análisis del aterrizaje', 'Spanish landing title');
  f.SetReport('Takeoff again', False);
  Require(f.Caption = 'Análisis del despegue', 'Reused report title');
  f.Caption := 'SimBrief OFP';
  f.SetHTMLDocument('<p>OFP</p>');
  SetLanguage('pl-PL');
  Require(f.Caption = 'SimBrief OFP', 'External HTML title preserved');
  f.OnDestroy := p.Destroyed;
  f.SetReport('# Analiza' + sLineBreak + '**Manewr prawidlowy.**');
  f.Show;
  Application.ProcessMessages;
  Require(HelpReportText(f).GetTextLen > 20, 'Native report content retained');
  Image := CaptureHelpWindow(f);
  Image.Free;

  Started := GetTickCount64;

  While (GetTickCount64 - Started < 1500) Do
   Begin
    Application.ProcessMessages;
    Sleep(10);
   End;

  f.btnClose.Click;
  Application.ProcessMessages;

  Require(p.Closed, 'Nonmodal report close did not destroy form');
  p.Free;

  System.Writeln('PASS: Markdown formatting, escaped HTML and nonmodal Close button.');

 End;

Begin
 RunNativeTests(TVerifyReportTests);
End.
