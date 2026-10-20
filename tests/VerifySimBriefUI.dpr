program VerifySimBriefUI;

{$APPTYPE CONSOLE}

uses Winapi.Windows, System.SysUtils, System.Classes, System.IOUtils, System.IniFiles,

  Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Graphics, Vcl.Imaging.pngimage,

  frmSimBriefFrameU, frmSimBriefU;

type TPopupProbe=class

  Frame:TfraSimBrief;Checked:Boolean;Error:string;

  procedure Tick(Sender:TObject);

end;

var Host:TForm;F:TfraSimBrief;C:TMemIniFile;G:TGroupBox;B:TButton;I,J:Integer;

  Probe:TPopupProbe;PopupTimer:TTimer;Msg:TMsg;Handled:Boolean;P:TPoint;

  Path,Payload:string;Bitmap:TBitmap;PNG:TPngImage;

procedure Check(Value:Boolean;const MessageText:string);

begin if not Value then raise Exception.Create(MessageText);end;

procedure TPopupProbe.Tick(Sender:TObject);

var I:Integer;W:TfrmSimBrief;

begin

  for I:=0 to Screen.FormCount-1 do if Screen.Forms[I] is TfrmSimBrief then begin

    TTimer(Sender).Enabled:=False;W:=TfrmSimBrief(Screen.Forms[I]);

    try

      Check(Frame.Parent=W.ViewHost,'Same live frame in separate window');

      Check(W.BorderStyle=bsSizeable,'Resizable window');

      W.Width:=1100;W.Height:=750;Checked:=True;

    except on E:Exception do Error:=E.Message;end;

    W.ModalResult:=mrCancel;Exit;

  end;

end;

function Content(C:TWinControl):string;

var I:Integer;

begin

  Result:='';

  for I:=0 to C.ControlCount-1 do begin

    if C.Controls[I] is TLabel then Result:=Result+TLabel(C.Controls[I]).Caption+sLineBreak;

    if C.Controls[I] is TMemo then Result:=Result+TMemo(C.Controls[I]).Text+sLineBreak;

    if C.Controls[I] is TWinControl then Result:=Result+Content(TWinControl(C.Controls[I]));

  end;

end;

begin

  Application.Initialize;

  Probe:=nil;PopupTimer:=nil;

  Path:=TPath.Combine(TPath.GetTempPath,'simbrief-ui-'+IntToStr(GetTickCount64)+'.ini');

  C:=TMemIniFile.Create(Path);Host:=TForm.Create(nil);Bitmap:=TBitmap.Create;PNG:=TPngImage.Create;

  try

    Host.SetBounds(-4000,0,800,950);Host.Caption:='SimBrief Dispatch preview';

    F:=TfraSimBrief.Create(Host);F.Parent:=Host;F.Align:=alClient;

    F.Configure(C);F.SetTrip(nil,0);

    Payload:='{"origin":{"icao_code":"EPLL","plan_rwy":"25"},"destination":{"icao_code":"EGLL"},'+

      '"general":{"icao_airline":"LOT","flight_number":"131","route":"TEST ROUTE","dx_rmk":["REMARK TEST &ft &amp; DATA"],"initial_altitude":"36000","costindex":"15"},'+

      '"alternate":[{"icao_code":"EGSS"},{"icao_code":"EGKK"}],'+

      '"aircraft":{"reg":"SP-LVA","name":"B737 MAX 8"},"atc":{"callsign":"LOT131","flightplan_text":"FPL TEST"},'+

      '"params":{"time_generated":"2026-10-04T18:34:56Z","units":"kgs"},'+

      '"weights":{"pax_count":"125","est_tow":"66583"},'+

      '"text":{"plan_html":"<pre>LIDO OFP &amp; TEST\n  FUEL    TIME\n  1234    0100</pre>"}}';

    F.LoadPayload(Payload,'Synthetic Dispatch');Host.Show;Application.ProcessMessages;

    Check(F.Sections.ControlCount=15,'Dispatch sections');

    Check(F.FindComponent('SB_downloads')=nil,'Downloads removed');

    F.Sections.VertScrollBar.Position:=0;

    FillChar(Msg,SizeOf(Msg),0);Msg.message:=$020A;Msg.hwnd:=F.eAccount.Handle;

    P:=F.eAccount.ClientToScreen(Point(5,5));

    Msg.lParam:=MakeLong(Word(P.X),Word(P.Y));Msg.wParam:=WPARAM(Word(SmallInt(-120))) shl 16;

    Handled:=False;F.WheelMessage(Msg,Handled);

    Check(Handled and (F.Sections.VertScrollBar.Position>0),'Wheel over input scrolls whole Dispatch');

    Msg.hwnd:=Host.Handle;Handled:=False;F.WheelMessage(Msg,Handled);

    Check(not Handled,'Unrelated control wheel is ignored');

    F.Sections.VertScrollBar.Position:=0;

    Check(Pos('EPLL - EGLL',F.lStatus.Caption)>0,'Actual payload airports, independent of test recordings');

    Check(not F.btnAttach.Enabled,'Preview cannot attach without trip');

    Check(Pos('EGSS, EGKK',Content(F))>0,'v2 alternate array');

    Check(Pos('LOT131',Content(F))>0,'Airline and flight number');

    Check(Pos('LIDO',Content(F))>0,'Default OFP layout');

    Check((Pos('REMARK TEST &ft & DATA',Content(F))>0) and (Pos('FPL TEST',Content(F))>0),'Remarks and ATC text preserved');

    Check((Pos('dx_rmk',Content(F))=0) and (Pos('flightplan_text',Content(F))=0) and

      (Pos('atc /',Content(F))=0),'No technical API prefixes');

    Probe:=TPopupProbe.Create;Probe.Frame:=F;PopupTimer:=TTimer.Create(nil);

    PopupTimer.Enabled:=False;PopupTimer.Interval:=20;PopupTimer.OnTimer:=Probe.Tick;PopupTimer.Enabled:=True;

    F.aWindowExecute(F.aWindow);

    Check(Probe.Checked and (Probe.Error=''),'Separate window: '+Probe.Error);

    Check((F.Parent=Host) and F.btnWindow.Enabled,'Frame restored after close');

    Check(F.btnOFP.Enabled,'OFP action available');

    G:=F.FindComponent('SB_ofp') as TGroupBox;

    F.ToggleSection(G.Controls[0]);

    Check((G.Height>49) and (G.Height<200),'Short briefing fits content');

    for I:=0 to G.ControlCount-1 do if G.Controls[I] is TMemo then begin

      Check(TMemo(G.Controls[I]).Lines.Count>=3,'LF source displayed as separate Windows lines');

      Check(TMemo(G.Controls[I]).Lines[1]='  FUEL    TIME','Preserve column spacing and indentation');

      Msg.hwnd:=TMemo(G.Controls[I]).Handle;Handled:=False;

      F.Sections.VertScrollBar.Position:=0;F.WheelMessage(Msg,Handled);

      Check(Handled and (F.Sections.VertScrollBar.Position>0),'Wheel from memo scrolls whole Dispatch');

      F.Sections.VertScrollBar.Position:=0;

    end;

    F.ToggleSection(G.Controls[0]);F.ToggleSection(G.Controls[0]);

    Check((G.Height>49) and (G.Height<200),'Content height restored on expand');

    G:=F.FindComponent('SB_summary') as TGroupBox;

    Check(G<>nil,'Summary group');Check(G.Height>49,'Expanded summary');

    B:=G.Controls[0] as TButton;F.ToggleSection(B);

    Check(G.Height=49,'Collapse summary');Check(not C.ReadBool('simbrief_sections','summary',True),'Collapse saved');

    F.LoadPayload(Payload,'Reload');G:=F.FindComponent('SB_summary') as TGroupBox;

    Check(G.Height=49,'Collapse restored after reload');F.ToggleSection(G.Controls[0]);

    for I:=0 to F.Sections.ControlCount-1 do begin

      G:=F.Sections.Controls[I] as TGroupBox;

      Check(G.Controls[0] is TButton,'Each group has toggle');

      for J:=0 to G.ControlCount-1 do

        if G.Controls[J] is TMemo then Check(TMemo(G.Controls[J]).ReadOnly,'Read-only content');

    end;

    Host.Width:=240;Application.ProcessMessages;F.ResizeCards(nil);

    Check((F.eAccount.Parent=F.Tools) and (F.eAccount.Width<=F.Tools.ClientWidth),'Account field fits narrow frame');
    Check(F.btnOlder.Left+F.btnOlder.Width<=F.ToolBar1.ClientWidth,'Toolbar fits narrow frame');

    Host.Width:=800;Application.ProcessMessages;F.ResizeCards(nil);

    Bitmap.SetSize(Host.ClientWidth,Host.ClientHeight);Host.PaintTo(Bitmap.Canvas,0,0);

    PNG.Assign(Bitmap);PNG.SaveToFile(ExtractFilePath(ParamStr(0))+'simbrief-preview.png');

    Check(F.Payload=Payload,'Full payload retained');

    F.LoadPayload(Payload.Replace('LIDO OFP &amp; TEST',StringReplace(StringOfChar('X',100),'X','LINE\n',[rfReplaceAll])),'Long briefing');

    G:=F.FindComponent('SB_ofp') as TGroupBox;

    if G.Height=49 then F.ToggleSection(G.Controls[0]);

    Check(G.Height>1000,'Long briefing expands to all lines');

    for I:=0 to G.ControlCount-1 do if G.Controls[I] is TMemo then

      Check(TMemo(G.Controls[I]).ScrollBars=ssHorizontal,'No nested vertical memo scrolling');

    F.LoadPayload(Payload,'Restore');

    try F.LoadPayload('{}','bad');except on E:Exception do ;end;

    Check(F.Payload=Payload,'Malformed response preserves preview');

  finally PopupTimer.Free;Probe.Free;PNG.Free;Bitmap.Free;Host.Free;C.Free;TFile.Delete(Path);end;

  Writeln('PASS: SimBrief native Dispatch frame, 15 groups, EPLL-EGLL preview, collapse persistence, responsive toolbar, read-only sections, independent preview and original OFP action.');

end.

