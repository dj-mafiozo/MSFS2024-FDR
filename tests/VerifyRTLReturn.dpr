program VerifyRTLReturn;
{$APPTYPE CONSOLE}
uses System.SysUtils,System.Classes,System.IOUtils,System.IniFiles,System.Types,
 Winapi.Windows,Winapi.Messages,Vcl.Forms,Vcl.Controls,Vcl.Menus,Vcl.ActnList,Vcl.ExtCtrls,
 LocalizationU,frmMainU,frmSettingsU,fraMapU,fraGraphU;
type TControlAccess=class(TControl);
procedure Check(B:Boolean;const S:string);begin if not B then raise Exception.Create(S);end;
procedure CheckLTR(C:TControl);
var I:Integer;Style:NativeInt;
begin
 if TControlAccess(C).BiDiMode<>bdLeftToRight then raise Exception.Create('Stale VCL mode: '+C.Name);
 if C is TWinControl then begin
  if TWinControl(C).HandleAllocated then begin
   Style:=GetWindowLongPtr(TWinControl(C).Handle,GWL_EXSTYLE);
   if (Style and (WS_EX_LAYOUTRTL or WS_EX_RTLREADING or WS_EX_RIGHT or WS_EX_LEFTSCROLLBAR))<>0 then
    raise Exception.Create('Stale HWND style: '+C.Name+' '+IntToHex(Style,8));
  end;
  for I:=0 to TWinControl(C).ControlCount-1 do CheckLTR(TWinControl(C).Controls[I]);
 end;
end;
procedure CheckMenuDirection(H:HMENU;RTL:Boolean);
var I:Integer;Info:TMenuItemInfo;Expected:DWORD;
begin
 Expected:=0;if RTL then Expected:=MFT_RIGHTORDER or MFT_RIGHTJUSTIFY;
 for I:=0 to GetMenuItemCount(H)-1 do begin
  FillChar(Info,SizeOf(Info),0);Info.cbSize:=SizeOf(Info);Info.fMask:=MIIM_FTYPE or MIIM_SUBMENU;
  Check(GetMenuItemInfo(H,I,True,Info),'Read HMENU item');
  Check((Info.fType and (MFT_RIGHTORDER or MFT_RIGHTJUSTIFY))=Expected,'Stale HMENU direction item '+IntToStr(I));
  if Info.hSubMenu<>0 then CheckMenuDirection(Info.hSubMenu,RTL);
 end;
end;
procedure Dump(M:TfrmMain;const Phase:string);
begin
 Writeln(Phase,' language ',Language,' mode ',Ord(M.BiDiMode),' flipped ',M.AppTranslator.IsLayoutFlipped,
 ' left=',Ord(M.LeftPanel.Align),' right=',Ord(M.RightPanel.Align),' center=',M.CenterPanel.Left,
 ' app=',Ord(Application.BiDiMode));
end;
var M:TfrmMain;Config:TMemIniFile;Path:string;Backup:TBytes;Existed:Boolean;Flags:array[0..31]of Integer;I:Integer;Item:TMenuItem;S:TfrmSettings;
begin
 try
  Path:=TPath.GetFullPath(ExtractFilePath(ParamStr(0))+'settings.ini');Existed:=TFile.Exists(Path);if Existed then Backup:=TFile.ReadAllBytes(Path);
  try
   Config:=TMemIniFile.Create(Path);try Config.WriteString('ui','language','ar-SA');Config.WriteBool('recording','enabled',False);Config.UpdateFile;finally Config.Free;end;
   Application.Initialize;M:=TfrmMain.Create(nil);
   try
    for I:=0 to 31 do Flags[I]:=(M.miLanguage.Items[I+1].Action as TAction).ImageIndex;
    M.Timer.Enabled:=False;M.Position:=poDesigned;M.Left:=-4000;M.Show;Application.ProcessMessages;Dump(M,'startup RTL');
    M.Perform(WM_INITMENUPOPUP,WPARAM(M.miLanguage.Handle),0); M.aEnglish.Execute;Application.ProcessMessages;Dump(M,'returned LTR');CheckLTR(M);
    Check(M.BiDiMode=bdLeftToRight,'Main direction after RTL startup');
    Check((M.LeftPanel.Align=alLeft) and (M.RightPanel.Align=alRight),'Panel alignment after RTL startup');
    Check((M.LeftPanel.Left<M.CenterPanel.Left) and (M.RightPanel.Left>M.CenterPanel.Left),'Panel placement after RTL startup');
    for I:=0 to M.miLanguage.Count-1 do begin Item:=M.miLanguage.Items[I];Check(Pos('&',Item.Caption)=0,'Language mnemonic: '+Item.Name);end;
    for I:=0 to 3 do begin
     if Odd(I) then M.aHebrew.Execute else M.aArabic.Execute;Application.ProcessMessages;Dump(M,'RTL loop');
     S:=TfrmSettings.Create(nil);try Check(S.BiDiMode=bdRightToLeft,'Fresh RTL settings');finally S.Free;end;
     M.aPolish.Execute;Application.ProcessMessages;Dump(M,'LTR loop');CheckLTR(M);
     Check((M.BiDiMode=bdLeftToRight) and (M.LeftPanel.Align=alLeft) and (M.RightPanel.Align=alRight),'Repeated LTR round trip');
    end;
    M.aHebrew.Execute;Application.ProcessMessages;
    M.Perform(WM_INITMENUPOPUP,WPARAM(M.miLanguage.Handle),0);
    CheckMenuDirection(M.MainMenu.Handle,True);
    M.aLangAuto.Execute;Application.ProcessMessages;
    Check(LanguagePreference='auto','Auto preference retained');
    M.Perform(WM_INITMENUPOPUP,WPARAM(M.miLanguage.Handle),0);
    CheckMenuDirection(M.MainMenu.Handle,Application.BiDiMode=bdRightToLeft);
    if Application.BiDiMode=bdLeftToRight then CheckLTR(M);
    for I:=0 to 31 do Check((M.miLanguage.Items[I+1].Action as TAction).ImageIndex=Flags[I],'Language flag changed');
   finally M.Free;end;
  finally if Existed then TFile.WriteAllBytes(Path,Backup) else TFile.Delete(Path);end;
  Writeln('PASS: RTL startup, LTR restoration, repeated Arabic/Hebrew switches and clean language menu and unchanged flag indices.');
 except on E:Exception do begin Writeln('FAIL: ',E.Message);Halt(1);end;end;
end.
