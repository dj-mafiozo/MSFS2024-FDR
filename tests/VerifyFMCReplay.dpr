Program VerifyFMCReplay;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU In 'TestPathsU.pas', DUnitX.TestFramework, NativeTestRunnerU In 'NativeTestRunnerU.pas',
 StackTrace    In '..\vendor\Delphi-StackTrace\source\StackTrace.pas', Winapi.Windows, System.SysUtils, System.Classes, System.IOUtils,
 Vcl.StdCtrls, Vcl.Forms, Vcl.Controls, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Graphics,
 FlightDatabaseU In '..\src\Data\FlightDatabaseU.pas', FMCReplayU In '..\src\FMC\FMCReplayU.pas', fraFMCU In '..\src\Frames\fraFMCU.pas', frmViewWindowU In '..\src\Forms\frmViewWindowU.pas', frmReportU In '..\src\Forms\frmReportU.pas',
 LocalizationU In '..\src\i18n\LocalizationU.pas';

Function PrintWindow(Wnd : HWND; DC : HDC; Flags : UINT) : BOOL; Stdcall; External 'user32.dll';

Procedure Check(b : Boolean; Const s : String);
 Begin
  If Not b Then
   Raise Exception.Create(s);
 End;

Var
 DB      : TFlightDatabase;
 Root    : String;
 Text    : String;
 Style   : String;
 Frame   : TfraFMC;
 Host    : TForm;
 Dock    : TPanel;
 View    : TfrmViewWindow;
 History : TFMCHistory;
 Stamp   : TDateTime;
 r       : TfrmReport;
 i       : Integer;
 Rich    : TRichEdit;
 Shot    : TBitmap;

Procedure Insert(ID : Integer; Const Device, Time, Raw : String; Available, Power : Integer);
 Begin
  DB.Connection.ExecSQL('insert into trip_fmc_screens(id,trip,sample,time_zulu,captured_utc,provider,device,page_key,title,available,powered,raw_text,parsed_json,style_json,annunciators_json,formatted_html) ' + 'values(:id,1,1,:t,:t,''iFly737MAX'',:d,''test'',''TEST'',:a,:p,:raw,''{}'',:s,''{"EXEC":1,"MSG":1,"FAIL":0}'','''')', [ID, Time, Device, Available, Power, Raw, Style]);
 End;

Type

 [TestFixture]
 TVerifyFMCReplayTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyFMCReplayTests.Regression;
 Begin
  Try
   Check(DetectFMCFamily('Fenix A320', '') = 'A320', 'A320 from flight title');
   Check(DetectFMCFamily('PMDG 777-300ER', '') = 'B777', '777 from flight title');
   Check(DetectFMCFamily('LOT B737-800', '') = 'B737', '737 from flight title');
   Check(DetectFMCFamily('Cessna 172', '') = '', 'Unknown aircraft has no false FMC model');
   Application.Initialize;
   Root := TPath.Combine(TestDataDirectory, 'replay');
   ForceDirectories(Root);
   DB      := TFlightDatabase.Create(TPath.Combine(Root, 'replay.db'), TPath.Combine(ExtractFilePath(ParamStr(0)), 'sqlite3.dll'));
   History := TFMCHistory.Create;
   Host    := TForm.Create(Nil);
   Try
    Style := '{"encoding":"color-font-nibbles-v1","rows":["102031004070800000000000000000000000000000000000"]}';
    Text  := 'COLOR SMALL FONT TEST    ' + sLineBreak + 'FLAPS          QRH   V1' + sLineBreak + '15              124  124';
    Insert(1, '0', '2026-10-21T10:00:01Z', Text, 1, 1);
    Insert(2, '1', '2026-10-21T10:00:02Z', 'RIGHT CDU', 1, 1);
    Insert(3, '0', '2026-10-21T12:00:03+02:00', 'POWER OFF', 1, 0);
    Insert(4, '0', '2026-10-21T10:00:04Z', 'OLD SAME TIME', 1, 1);
    Insert(5, '0', '2026-10-21T10:00:04Z', 'LATEST SAME TIME', 1, 1);
    Insert(6, '0', '2026-10-21T10:00:05Z', 'STALE', 0, -1);
    Insert(7, '0', '2026-10-21T10:00:06Z', Text, 1, 1);
    History.Load(DB.Connection, 1);
    Check(History.Devices.Count = 2, 'Two devices');
    FMCTime('2026-10-21T09:59:59Z', Stamp);
    Check(History.Devices[0].AtTime(Stamp) = Nil, 'Never show future screen');
    Check(FMCTime('2026-10-21T10:00:03.000+00:00_0', Stamp), 'Recorder weekday suffix');
    Check(History.Devices[0].AtTime(Stamp).Screen.PowerState = 0, 'UTC offset normalized; power off retained');
    FMCTime('2026-10-21T10:00:04Z', Stamp);
    Check(History.Devices[0].AtTime(Stamp).ID = 5, 'Latest ID at equal timestamp');
    Check(History.Devices[1].AtTime(Stamp).ID = 2, 'Independent device state');
    Dock         := TPanel.Create(Host);
    Dock.Parent  := Host;
    Dock.Align   := alClient;
    Frame        := TfraFMC.Create(Host);
    Frame.Parent := Dock;
    Frame.Align  := alClient;
    Frame.Load(DB.Connection, 1);
    Frame.SetTime('2026-10-21T10:00:06Z');
    Check(Frame.Current.ID = 7, 'Frame synchronized');
    Check(Frame.AirframeKind = 'B737', 'FMC model inferred from recorded provider');
    Check(Frame.DeviceTabs.Tabs.Count = 2, 'CDUs populated without aircraft/device combo');
    SetLanguage('he-IL');
    Check(Frame.BiDiMode = bdLeftToRight, 'Physical CDU must not mirror in RTL');
    SetLanguage('pl-PL');
    Check(Frame.BiDiMode = bdLeftToRight, 'CDU remains LTR after language return');
    Host.ClientWidth  := 440;
    Host.ClientHeight := 750;
    Host.Show;
    View             := TfrmViewWindow.Create(Host);
    View.BorderStyle := bsDialog;
    View.Attach(Frame, Dock, 'FMC/MCDU', Nil);
    Check((Frame.Parent = View) And Not Dock.Visible, 'Detached same frame');
    Frame.SetTime('2026-10-21T10:00:05Z');
    Check(Not Frame.Current.Screen.Available, 'Unavailable suppresses stale display');
    View.Close;
    Application.ProcessMessages;
    Check((Frame.Parent = Dock) And Dock.Visible, 'Close docks same frame');
    Frame.SetTime('2026-10-21T10:00:06Z');
    Application.ProcessMessages;
    Shot := TBitmap.Create;
    Try
     Shot.SetSize(Host.Width, Host.Height);
     Host.PaintTo(Shot.Canvas, 0, 0);
     Shot.SaveToFile(TPath.Combine(ExtractFilePath(ParamStr(0)), 'fmc-replay-preview.bmp'));
    Finally
     Shot.Free;
    End;
    Frame.Load(Nil, 0);
    Check(Frame.Current = Nil, 'Trip clear removes display');
    r := TfrmReport.Create(Nil);
    Try
     r.SetHTMLDocument('<pre>A&amp;B' + #10 + '  C&lt;D' + #10 + 'E</pre>');
     Check(r.mReport.ReadOnly And (r.mReport.ScrollBars = ssNone) And (r.mReport.BorderStyle = bsNone), 'Native memo properties');
     Check(r.mReport.Font.Name = 'Consolas', 'Monospace font');
     Check(r.mReport.Lines[0] = 'A&B', 'Entities decoded');
     Check(r.mReport.Lines[1] = '  C<D', 'Whitespace preserved');
     i := r.mReport.Height;
     r.SetHTMLDocument('<pre>' + StringOfChar('A', 120) + StringReplace(StringOfChar('X', 100), 'X', #10 + 'line', [rfReplaceAll]) + '</pre>');
     Check(r.mReport.Height > i * 10, 'Memo expands for all lines');
     r.SetReport('# Heading' + sLineBreak + '**Bold** normal *italic* `IAS` [source](https://example.org)', True);
     Rich  := Nil;
     For i := 0 To r.ComponentCount - 1 Do
      If r.Components[i] Is TRichEdit Then
       Rich := TRichEdit(r.Components[i]);
     Check((Rich <> Nil) And (Pos('**', Rich.Text) = 0), 'Native Markdown bold markers rendered');
     Check((Pos('`', Rich.Text) = 0) And (Pos('*', Rich.Text) = 0) And (Pos('[source]', Rich.Text) = 0), 'Native inline formatting');
     Check(r.Caption = 'Analiza lądowania', 'Report title');
    Finally
     r.Free;
    End;
    System.Writeln('PASS: UTC replay seek, no future screen, power/unavailable transitions, device isolation, tie ordering, detach/dock, native memo height and Markdown.');
   Finally
    Host.Free;
    History.Free;
    DB.Free;
    If TDirectory.Exists(Root) Then
     TDirectory.Delete(Root, True);
   End;
  Except
   On E : Exception Do
    Begin
     System.Writeln(E.ClassName + ': ' + E.Message);
     System.Writeln(E.StackTrace);
     Raise Exception.Create('Regression failed; see diagnostic above');
    End;
  End;

 End;

Begin
 RunNativeTests(TVerifyFMCReplayTests);
End.
