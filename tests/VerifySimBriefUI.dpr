Program VerifySimBriefUI;

{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU In 'TestPathsU.pas', DUnitX.TestFramework, NativeTestRunnerU In 'NativeTestRunnerU.pas',
 Winapi.Windows, System.SysUtils, System.Classes, System.IOUtils, System.IniFiles,

 Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Graphics, Vcl.Imaging.pngimage,

 frmSimBriefFrameU In '..\src\Frames\frmSimBriefFrameU.pas', frmSimBriefU In '..\src\Forms\frmSimBriefU.pas';

Type
 TPopupProbe = Class

  Frame   : TfraSimBrief;
  Checked : Boolean;
  Error   : String;

  Procedure Tick(Sender : TObject);

 End;

Var
 Host : TForm;
 f    : TfraSimBrief;
 c    : TMemIniFile;
 g    : TGroupBox;
 b    : TButton;
 i    : Integer;
 j    : Integer;

 Probe      : TPopupProbe;
 PopupTimer : TTimer;
 Msg        : TMsg;
 Handled    : Boolean;
 p          : TPoint;

 Path    : String;
 Payload : String;
 Bitmap  : TBitmap;
 PNG     : TPngImage;

Procedure Check(Value : Boolean; Const MessageText : String);
 Begin
  If Not Value Then
   Raise Exception.Create(MessageText);
 End;

Procedure TPopupProbe.Tick(Sender : TObject);
 Var
  i : Integer;
  w : TfrmSimBrief;
 Begin

  For i := 0 To Screen.FormCount - 1 Do
   If Screen.Forms[i] Is TfrmSimBrief Then
    Begin

     TTimer(Sender).Enabled := False;
     w                      := TfrmSimBrief(Screen.Forms[i]);

     Try

      Check(Frame.Parent = w.ViewHost, 'Same live frame in separate window');

      Check(w.BorderStyle = bsSizeable, 'Resizable window');

      w.Width  := 1100;
      w.Height := 750;
      Checked  := True;

     Except
      On E : Exception Do
       Error := E.Message;
     End;

     w.ModalResult := mrCancel;
     Exit;

    End;

 End;

Function Content(c : TWinControl) : String;
 Var
  i : Integer;
 Begin

  Result := '';

  For i := 0 To c.ControlCount - 1 Do
   Begin

    If c.Controls[i] Is TLabel Then
     Result := Result + TLabel(c.Controls[i]).Caption + sLineBreak;

    If c.Controls[i] Is TMemo Then
     Result := Result + TMemo(c.Controls[i]).Text + sLineBreak;

    If c.Controls[i] Is TWinControl Then
     Result := Result + Content(TWinControl(c.Controls[i]));

   End;

 End;

Type

 [TestFixture]
 TVerifySimBriefUITests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifySimBriefUITests.Regression;
 Begin

  Application.Initialize;

  Probe      := Nil;
  PopupTimer := Nil;

  Path := TPath.Combine(TPath.GetTempPath, 'simbrief-ui-' + IntToStr(GetTickCount64) + '.ini');

  c      := TMemIniFile.Create(Path);
  Host   := TForm.Create(Nil);
  Bitmap := TBitmap.Create;
  PNG    := TPngImage.Create;

  Try

   Host.SetBounds( -4000, 0, 800, 950);
   Host.Caption := 'SimBrief Dispatch preview';

   f        := TfraSimBrief.Create(Host);
   f.Parent := Host;
   f.Align  := alClient;

   f.Configure(c);
   f.SetTrip(Nil, 0);

   Payload := '{"origin":{"icao_code":"EPLL","plan_rwy":"25"},"destination":{"icao_code":"EGLL"},' +

   '"general":{"icao_airline":"LOT","flight_number":"131","route":"TEST ROUTE","dx_rmk":["REMARK TEST &ft &amp; DATA"],"initial_altitude":"36000","costindex":"15"},' +

   '"alternate":[{"icao_code":"EGSS"},{"icao_code":"EGKK"}],' +

   '"aircraft":{"reg":"SP-LVA","name":"B737 MAX 8"},"atc":{"callsign":"LOT131","flightplan_text":"FPL TEST"},' +

   '"params":{"time_generated":"2026-10-04T18:34:56Z","units":"kgs"},' +

   '"weights":{"pax_count":"125","est_tow":"66583"},' +

   '"text":{"plan_html":"<pre>LIDO OFP &amp; TEST\n  FUEL    TIME\n  1234    0100</pre>"}}';

   f.LoadPayload(Payload, 'Synthetic Dispatch');
   Host.Show;
   Application.ProcessMessages;

   Check(f.Sections.ControlCount = 14, 'Dispatch sections without network filing');

   Check(f.FindComponent('SB_downloads') = Nil, 'Downloads removed');
   Check(f.FindComponent('SB_prefile') = Nil, 'Network filing removed');
   Check(Assigned(f.WheelEvents.OnMessage), 'Loaded connects application mouse-wheel events without designer binding');

   f.Sections.VertScrollBar.Position := 0;

   FillChar(Msg, SizeOf(Msg), 0);
   Msg.Message := $020A;
   Msg.hwnd    := f.eAccount.Handle;

   p := f.eAccount.ClientToScreen(Point(5, 5));

   Msg.lParam := MakeLong(Word(p.X), Word(p.Y));
   Msg.wParam := wParam(Word(SmallInt( -120))) Shl 16;

   Handled := False;
   f.WheelMessage(Msg, Handled);

   Check(Handled And (f.Sections.VertScrollBar.Position > 0), 'Wheel over input scrolls whole Dispatch');
   f.Sections.VertScrollBar.Position := 0;
   PostMessage(f.eAccount.Handle, Msg.Message, Msg.wParam, Msg.lParam);
   Application.ProcessMessages;
   Check(f.Sections.VertScrollBar.Position > 0, 'Queued Windows mouse wheel reaches the Loaded event handler');

   Msg.hwnd := Host.Handle;
   Handled  := False;
   f.WheelMessage(Msg, Handled);

   Check(Handled, 'Wheel follows hovered Dispatch even when another control has focus');

   f.Sections.VertScrollBar.Position := 0;

   Check(Pos('EPLL - EGLL', f.lStatus.Caption) > 0, 'Actual payload airports, independent of test recordings');

   Check(Not f.btnAttach.Enabled, 'Preview cannot attach without trip');

   Check(Pos('EGSS, EGKK', Content(f)) > 0, 'v2 alternate array');

   Check(Pos('LOT131', Content(f)) > 0, 'Airline and flight number');

   Check(Pos('LIDO', Content(f)) > 0, 'Default OFP layout');

   Check((Pos('REMARK TEST &ft & DATA', Content(f)) > 0) And (Pos('FPL TEST', Content(f)) > 0), 'Remarks and ATC text preserved');

   Check((Pos('dx_rmk', Content(f)) = 0) And (Pos('flightplan_text', Content(f)) = 0) And

   (Pos('atc /', Content(f)) = 0), 'No technical API prefixes');

   Probe       := TPopupProbe.Create;
   Probe.Frame := f;
   PopupTimer  := TTimer.Create(Nil);

   PopupTimer.Enabled  := False;
   PopupTimer.Interval := 20;
   PopupTimer.OnTimer  := Probe.Tick;
   PopupTimer.Enabled  := True;

   f.aWindowExecute(f.aWindow);

   Check(Probe.Checked And (Probe.Error = ''), 'Separate window: ' + Probe.Error);

   Check((f.Parent = Host) And f.btnWindow.Enabled, 'Frame restored after close');

   Check(f.btnOFP.Enabled, 'OFP action available');

   g := f.FindComponent('SB_ofp') As TGroupBox;

   f.ToggleSection(g.Controls[0]);

   Check((g.Height > 49) And (g.Height < 200), 'Short briefing fits content');

   For i := 0 To g.ControlCount - 1 Do
    If g.Controls[i] Is TMemo Then
     Begin

      Check(TMemo(g.Controls[i]).Lines.Count >= 3, 'LF source displayed as separate Windows lines');

      Check(TMemo(g.Controls[i]).Lines[1] = '  FUEL    TIME', 'Preserve column spacing and indentation');

      Msg.hwnd := TMemo(g.Controls[i]).Handle;
      Handled  := False;

      f.Sections.VertScrollBar.Position := 0;
      f.WheelMessage(Msg, Handled);

      Check(Handled And (f.Sections.VertScrollBar.Position > 0), 'Wheel from memo scrolls whole Dispatch');

      f.Sections.VertScrollBar.Position := 0;

     End;

   f.ToggleSection(g.Controls[0]);
   f.ToggleSection(g.Controls[0]);

   Check((g.Height > 49) And (g.Height < 200), 'Content height restored on expand');

   g := f.FindComponent('SB_summary') As TGroupBox;

   Check(g <> Nil, 'Summary group');
   Check(g.Height > 49, 'Expanded summary');

   b := g.Controls[0] As TButton;
   f.ToggleSection(b);

   Check(g.Height = 49, 'Collapse summary');
   Check(Not c.ReadBool('simbrief_sections', 'summary', True), 'Collapse saved');

   f.LoadPayload(Payload, 'Reload');
   g := f.FindComponent('SB_summary') As TGroupBox;

   Check(g.Height = 49, 'Collapse restored after reload');
   f.ToggleSection(g.Controls[0]);

   For i := 0 To f.Sections.ControlCount - 1 Do
    Begin

     g := f.Sections.Controls[i] As TGroupBox;

     Check(g.Controls[0] Is TButton, 'Each group has toggle');

     For j := 0 To g.ControlCount - 1 Do

      If g.Controls[j] Is TMemo Then
       Check(TMemo(g.Controls[j]).ReadOnly, 'Read-only content');

    End;

   Host.Width := 240;
   Application.ProcessMessages;
   f.ResizeCards(Nil);

   Check((f.eAccount.Parent = f.Tools) And (f.eAccount.Width <= f.Tools.ClientWidth), 'Account field fits narrow frame');
   Check(f.btnOlder.Left + f.btnOlder.Width <= f.ToolBar1.ClientWidth, 'Toolbar fits narrow frame');

   Host.Width := 800;
   Application.ProcessMessages;
   f.ResizeCards(Nil);

   Bitmap.SetSize(Host.ClientWidth, Host.ClientHeight);
   Host.PaintTo(Bitmap.Canvas, 0, 0);

   PNG.Assign(Bitmap);
   PNG.SaveToFile(ExtractFilePath(ParamStr(0)) + 'simbrief-preview.png');

   Check(f.Payload = Payload, 'Full payload retained');

   f.LoadPayload(Payload.Replace('LIDO OFP &amp; TEST', StringReplace(StringOfChar('X', 100), 'X', 'LINE\n', [rfReplaceAll])), 'Long briefing');

   g := f.FindComponent('SB_ofp') As TGroupBox;

   If g.Height = 49 Then
    f.ToggleSection(g.Controls[0]);

   Check(g.Height > 1000, 'Long briefing expands to all lines');

   For i := 0 To g.ControlCount - 1 Do
    If g.Controls[i] Is TMemo Then

     Check(TMemo(g.Controls[i]).ScrollBars = ssNone, 'No nested vertical memo scrolling');

   f.LoadPayload(Payload, 'Restore');

   Try
    f.LoadPayload('{}', 'bad');
   Except
    On E : Exception Do
     ;
   End;

   Check(f.Payload = Payload, 'Malformed response preserves preview');

  Finally
   PopupTimer.Free;
   Probe.Free;
   PNG.Free;
   Bitmap.Free;
   Host.Free;
   c.Free;
   If TFile.Exists(Path) Then
    TFile.Delete(Path);
  End;

  System.Writeln('PASS: SimBrief native Dispatch frame, 14 groups, EPLL-EGLL preview, collapse persistence, responsive toolbar, read-only sections, independent preview and original OFP action.');

 End;

Begin
 RunNativeTests(TVerifySimBriefUITests);
End.
