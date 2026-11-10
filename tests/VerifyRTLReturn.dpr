Program VerifyRTLReturn;
{$APPTYPE CONSOLE}

Uses
 TestPathsU,
 System.SysUtils, System.Classes, System.IOUtils, System.IniFiles, System.Types,
 Winapi.Windows, Winapi.Messages, Vcl.Forms, Vcl.Controls, Vcl.Menus, Vcl.ActnList, Vcl.ExtCtrls,
 LocalizationU, frmMainU, frmSettingsU, fraMapU, fraGraphU;

Type
  TControlAccess = Class(TControl);

  TMenuPaintProbe = Class(TLocalizedForm)
   Public
    PaintCount : Integer;
   Protected
    Procedure WndProc(Var Message : TMessage); Override;
  End;

 Procedure TMenuPaintProbe.WndProc(Var Message : TMessage);
  Begin
   If Message.Msg = WM_NCPAINT Then
    Inc(PaintCount);
   Inherited;
  End;

 Procedure CheckIdleMenuPaint;
  Var
   Form : TMenuPaintProbe;
   Menu : TMainMenu;
   Item : TMenuItem;
   i    : Integer;
  Begin
   Form := TMenuPaintProbe.CreateNew(Nil);
   Try
    Menu         := TMainMenu.Create(Form);
    Item         := TMenuItem.Create(Menu);
    Item.Caption := 'File';
    Menu.Items.Add(Item);
    Form.Menu := Menu;
    Form.Show;
    Form.Perform(CM_MENUCHANGED, 0, 0);
    Application.ProcessMessages;
    Form.PaintCount := 0;
    For i           := 1 To 40 Do
     Begin
      Form.Perform(CM_MENUCHANGED, 0, 0);
      Application.ProcessMessages;
     End;
    If Form.PaintCount <> 0 Then
     Raise Exception.Create('Unchanged menu notifications repaint the nonclient area');
    Item.Caption := 'Changed';
    Form.Perform(CM_MENUCHANGED, 0, 0);
    Application.ProcessMessages;
    If Form.PaintCount = 0 Then
     Raise Exception.Create('Changed menu header did not repaint');
   Finally
    Form.Free;
   End;
 End;

Procedure Check(b : Boolean; Const s : String);
 Begin
  If Not b Then
   Raise Exception.Create(s);
 End;

Procedure CheckLTR(c : TControl);
 Var
  i     : Integer;
  Style : NativeInt;
 Begin
  If TControlAccess(c).BiDiMode <> bdLeftToRight Then
   Raise Exception.Create('Stale VCL mode: ' + c.Name);
  If c Is TWinControl Then
   Begin
    If TWinControl(c).HandleAllocated Then
     Begin
      Style := GetWindowLongPtr(TWinControl(c).Handle, GWL_EXSTYLE);
      If (Style And (WS_EX_LAYOUTRTL Or WS_EX_RTLREADING Or WS_EX_RIGHT Or WS_EX_LEFTSCROLLBAR)) <> 0 Then
       Raise Exception.Create('Stale HWND style: ' + c.Name + ' ' + IntToHex(Style, 8));
     End;
    For i := 0 To TWinControl(c).ControlCount - 1 Do
     CheckLTR(TWinControl(c).Controls[i]);
   End;
 End;

Procedure CheckMenuDirection(h : HMENU; RTL : Boolean);
 Var
  i        : Integer;
  Info     : TMenuItemInfo;
  Expected : DWORD;
 Begin
  Expected := 0;
  If RTL Then
   Expected := MFT_RIGHTORDER Or MFT_RIGHTJUSTIFY;
  For i     := 0 To GetMenuItemCount(h) - 1 Do
   Begin
    FillChar(Info, SizeOf(Info), 0);
    Info.cbSize := SizeOf(Info);
    Info.fMask  := MIIM_FTYPE Or MIIM_SUBMENU;
    Check(GetMenuItemInfo(h, i, True, Info), 'Read HMENU item');
    Check((Info.fType And (MFT_RIGHTORDER Or MFT_RIGHTJUSTIFY)) = Expected, 'Stale HMENU direction item ' + IntToStr(i));
    If Info.hSubMenu <> 0 Then
     CheckMenuDirection(Info.hSubMenu, RTL);
   End;
 End;

Procedure Dump(m : TfrmMain; Const Phase : String);
 Begin
  System.Writeln(Phase, ' language ', Language, ' mode ', Ord(m.BiDiMode), ' flipped ', m.AppTranslator.IsLayoutFlipped, ' left=', Ord(m.LeftPanel.Align), ' right=', Ord(m.RightPanel.Align), ' center=', m.CenterPanel.Left, ' app=', Ord(Application.BiDiMode));
 End;

Var
 m       : TfrmMain;
 Config  : TMemIniFile;
 Path    : String;
 Backup  : TBytes;
 Existed : Boolean;
 Flags   : Array [0..31] Of Integer;
 i       : Integer;
 Item    : TMenuItem;
 s       : TfrmSettings;

 FirstRect : TRect;
 NextRect  : TRect;
 Pass      : Integer;

Begin
 Try
  CheckIdleMenuPaint;
  Path    := TPath.GetFullPath(ExtractFilePath(ParamStr(0)) + 'settings.ini');
  Existed := TFile.Exists(Path);
  If Existed Then
   Backup := TFile.ReadAllBytes(Path);
  Try
   Config := TMemIniFile.Create(Path);
   Try
    Config.WriteString('ui', 'language', 'ar-SA');
    Config.WriteBool('recording', 'enabled', False);
    Config.UpdateFile;
   Finally
    Config.Free;
   End;
   Application.Initialize;
   m := TfrmMain.Create(Nil);
   Try
    For i           := 0 To 31 Do
     Flags[i]       := (m.miLanguage.Items[i + 1].Action As TAction).ImageIndex;
    m.Timer.Enabled := False;
    m.Position      := poDesigned;
    m.Left          := -4000;
    m.Show;
    Application.ProcessMessages;
    Dump(m, 'startup RTL');
    m.Perform(WM_INITMENUPOPUP, WPARAM(m.miLanguage.Handle), 0);
    m.aEnglish.Execute;
    Application.ProcessMessages;
    Dump(m, 'returned LTR');
    CheckLTR(m);
    Check(m.BiDiMode = bdLeftToRight, 'Main direction after RTL startup');
    Check((m.LeftPanel.Align = alLeft) And (m.RightPanel.Align = alRight), 'Panel alignment after RTL startup');
    Check((m.LeftPanel.Left < m.CenterPanel.Left) And (m.RightPanel.Left > m.CenterPanel.Left), 'Panel placement after RTL startup');
    For i := 0 To m.miLanguage.Count - 1 Do
     Begin
      Item := m.miLanguage.Items[i];
      Check(Pos('&', Item.Caption) = 0, 'Language mnemonic: ' + Item.Name);
     End;
    For i := 0 To 3 Do
     Begin
      If Odd(i) Then
       m.aHebrew.Execute
      Else
       m.aArabic.Execute;
      Application.ProcessMessages;
      Dump(m, 'RTL loop');
      s := TfrmSettings.Create(Nil);
      Try
       Check(s.BiDiMode = bdRightToLeft, 'Fresh RTL settings');
      Finally
       s.Free;
      End;
      m.aPolish.Execute;
      Application.ProcessMessages;
      Dump(m, 'LTR loop');
      CheckLTR(m);
      Check((m.BiDiMode = bdLeftToRight) And (m.LeftPanel.Align = alLeft) And (m.RightPanel.Align = alRight), 'Repeated LTR round trip');
     End;
    m.aHebrew.Execute;
    Application.ProcessMessages;
    m.Perform(WM_INITMENUPOPUP, WPARAM(m.miLanguage.Handle), 0);
    CheckMenuDirection(m.MainMenu.Handle, True);
    m.aLangAuto.Execute;
    Application.ProcessMessages;
    Check(LanguagePreference = 'auto', 'Auto preference retained');
    Check(GetMenuItemRect(m.Handle, m.MainMenu.Handle, 0, FirstRect), 'Initial menu position');
    For Pass := 1 To 40 Do
     Begin
      // Exercise CM_MENUCHANGED on an already attached native menu, as
      // action/image updates do while the main window is idle.
      m.Perform(CM_MENUCHANGED, 0, 0);
      CheckMenuDirection(m.MainMenu.Handle, Application.BiDiMode = bdRightToLeft);
      m.ActionList.UpdateAction(m.aPlayPause);
      Application.ProcessMessages;
      Sleep(10);
      Check(GetMenuItemRect(m.Handle, m.MainMenu.Handle, 0, NextRect), 'Menu position during idle');
      Check((FirstRect.Left = NextRect.Left) And (FirstRect.Right = NextRect.Right), 'Menu must not alternate left/right during idle');
     End;
    m.Perform(WM_INITMENUPOPUP, WPARAM(m.miLanguage.Handle), 0);
    CheckMenuDirection(m.MainMenu.Handle, Application.BiDiMode = bdRightToLeft);
    If Application.BiDiMode = bdLeftToRight Then
     CheckLTR(m);
    For i := 0 To 31 Do
     Check((m.miLanguage.Items[i + 1].Action As TAction).ImageIndex = Flags[i], 'Language flag changed');
   Finally
    m.Free;
   End;
  Finally
   If Existed Then
    TFile.WriteAllBytes(Path, Backup)
   Else
    TFile.Delete(Path);
  End;
  System.Writeln('PASS: RTL startup, LTR restoration, repeated Arabic/Hebrew switches and clean language menu and unchanged flag indices.');
 Except
  On E : Exception Do
   Begin
    System.Writeln('FAIL: ', E.Message);
    Raise Exception.Create('Regression failed; see diagnostic above');
   End;
 End;
End.
