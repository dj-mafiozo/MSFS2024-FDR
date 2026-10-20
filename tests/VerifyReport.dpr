program VerifyReport;

{$APPTYPE CONSOLE}

uses LocalizationU,Winapi.Windows,System.SysUtils,Vcl.Forms,frmReportU,ReportMarkdownU;

procedure Require(B:Boolean;const S:string);begin if not B then raise Exception.Create(S);end;

type TProbe=class Closed:Boolean;procedure Destroyed(Sender:TObject);end;

procedure TProbe.Destroyed(Sender:TObject);begin Closed:=True;end;

var F:TfrmReport;P:TProbe;H:string;Started:UInt64;

begin

 H:=ReportHTML('# Ocena'+sLineBreak+'**Dobrze** i `IAS`'+sLineBreak+'- punkt'+sLineBreak+'1. wskazowka'+sLineBreak+'<script>alert(1)</script>');

 Require(Pos('<h1>Ocena</h1>',H)>0,'Heading');Require(Pos('<strong>Dobrze</strong>',H)>0,'Bold');Require(Pos('<code>IAS</code>',H)>0,'Inline code');Require(Pos('<ul><li>punkt</li></ul>',H)>0,'Bullet list');Require(Pos('<ol>',H)>0,'Ordered list');Require(Pos('<script>',H)=0,'Raw HTML must be escaped');

 Application.Initialize;P:=TProbe.Create;F:=TfrmReport.Create(nil);

 F.SetReport('Takeoff',False);Require(F.Caption='Analiza startu','Takeoff title');
 SetLanguage('en-US');Require(F.Caption='Takeoff analysis','Live takeoff title');
 F.SetReport('Landing',True);Require(F.Caption='Landing analysis','Landing title');
 SetLanguage('de-DE');Require(F.Caption='Landeanalyse','German landing title');
 SetLanguage('es-ES');Require(F.Caption='Análisis del aterrizaje','Spanish landing title');
 F.SetReport('Takeoff again',False);Require(F.Caption='Análisis del despegue','Reused report title');
 F.Caption:='SimBrief OFP';F.SetHTMLDocument('<p>OFP</p>');SetLanguage('pl-PL');Require(F.Caption='SimBrief OFP','External HTML title preserved');
 F.OnDestroy:=P.Destroyed;F.SetReport('# Analiza'+sLineBreak+'**Manewr prawidlowy.**');F.Show;

 Started:=GetTickCount64;

 while (GetTickCount64-Started<1500) do begin Application.ProcessMessages;Sleep(10);end;

 F.btnClose.Click;Application.ProcessMessages;

 Require(P.Closed,'Nonmodal report close did not destroy form');P.Free;

 Writeln('PASS: Markdown formatting, escaped HTML and nonmodal Close button.');

end.

