Program VerifyLocalization;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU,
 Vcl.Menus, System.Actions, System.UITypes, System.SysUtils, System.Classes, System.IniFiles, System.IOUtils, Vcl.Forms, Vcl.StdCtrls, Vcl.Graphics, Vcl.Imaging.pngimage,
 LocalizationU, LocalizationCatalogU, frmMainU, frmSettingsU, frmReportU, frmTripInfoU, frmSimBriefFrameU;

Procedure Check(b : Boolean; Const m : String);
 Begin
  If Not b Then
   Raise Exception.Create(m);
 End;

Function HasMenuAction(Item : TMenuItem; Action : TBasicAction) : Boolean;
 Var
  i : Integer;
 Begin
  Result := Item.Action = Action;
  For i  := 0 To Item.Count - 1 Do
   If HasMenuAction(Item.Items[i], Action) Then
    Exit(True);
 End;

Var
 i : Integer;

Var
 f             : TfrmMain;
 s             : TfrmSettings;
 r             : TfrmReport;
 b             : TfraSimBrief;
 c             : TMemIniFile;
 DecimalBefore : Char;
 Worker        : TThread;
 Failure       : String;
 Bitmap        : TBitmap;
 PNG           : TPngImage;

Type

 [TestFixture]
 TVerifyLocalizationTests = Class
  Public
   [Test]
   Procedure Regression;
 End;

Procedure TVerifyLocalizationTests.Regression;
 Begin
  Application.Initialize;
  SetLanguage('pl-PL');
  DecimalBefore := FormatSettings.DecimalSeparator;
  Check(Tr('Settings') = 'Settings', 'Unknown source fallback');
  Check(Tr('Ustawienia') = 'Ustawienia', 'Polish default');
  f := TfrmMain.Create(Nil);
  Try
   For i := 0 To f.ActionList.ActionCount - 1 Do
    Begin
     Check(HasMenuAction(f.MainMenu.Items, f.ActionList.Actions[i]), 'Menu missing action ' + f.ActionList.Actions[i].Name);
     Check(Assigned(f.ActionList.Actions[i].OnExecute), 'Missing action handler ' + f.ActionList.Actions[i].Name);
    End;
   f.aPolish.Execute;
   Check(f.aSettings.Caption = 'Ustawienia', 'Polish button');
   Check(StringReplace(f.miFile.Caption, '&', '', [rfReplaceAll]) = 'Plik', 'Polish menu');
   f.aEnglish.Execute;
   Check(f.aSettings.Caption = 'Settings', 'English button');
   Check(f.aChartsConfigure.Hint = 'Configure charts', 'Localized icon tooltip');
   Check(f.aGerman.Enabled And f.aSpanish.Enabled, 'Four languages available');
   f.aGerman.Execute;
   Check((Language = 'de-DE') And (f.aSettings.Caption = 'Einstellungen'), 'German menu');
   f.aSpanish.Execute;
   Check((Language = 'es-ES') And (f.aSettings.Caption = 'Ajustes'), 'Spanish menu');
   Check(Pos('Arrastrar:', f.ChartsHost.Controls[0].Hint) = 1, 'Dynamic chart hint changes language');
   f.aEnglish.Execute;
   Check(Tr('Inny numer lotu.') = 'Flight number does not match.', 'SimBrief validation translation');
   Check(StringReplace(f.miFile.Caption, '&', '', [rfReplaceAll]) = 'File', 'Live menu translation');
   Check(f.DataTabs.Pages[0].Caption <> '', 'Tabs retained');
   s := TfrmSettings.Create(Nil);
   c := TMemIniFile.Create(TPath.Combine(ExtractFilePath(ParamStr(0)), 'localization-test.ini'));
   Try
    c.WriteString('ui', 'language', 'en-US');
    s.Load(c);
    Check(s.Caption = 'Settings', 'New form uses current language');
    Check(s.cbLanguage.ItemIndex = 10, 'Load language selection');
    Check((s.SettingsPages.PageCount = 6) And (s.ProviderPages.PageCount = 3), 'Tabbed settings');
    Check((s.cbLanguage.Items.Count = UILanguageCount + 1) And (s.ClientHeight < 600), 'Compact multilingual settings');
    Check(s.btnCancel.Caption = 'Cancel', 'English dialog button');
    Check(s.cbProvider.Items[1] = 'Gemini (API key)', 'Combo item translation');
    Check(Pos('run codex login', s.lHelp.Caption) > 0, 'Multiline DFM help translation');
    Bitmap := TBitmap.Create;
    PNG    := TPngImage.Create;
    Try
     s.Show;
     Application.ProcessMessages;
     Bitmap.SetSize(s.ClientWidth, s.ClientHeight);
     s.PaintTo(Bitmap.Canvas, 0, 0);
     PNG.Assign(Bitmap);
     PNG.SaveToFile(ExtractFilePath(ParamStr(0)) + 'settings-en-preview.png');
    Finally
     s.Hide;
     PNG.Free;
     Bitmap.Free;
    End;
    Bitmap := TBitmap.Create;
    PNG    := TPngImage.Create;
    Try
     s.Show;
     For i := 1 To 3 Do
      Begin
       s.SettingsPages.ActivePageIndex := i;
       Application.ProcessMessages;
       Bitmap.SetSize(s.ClientWidth, s.ClientHeight);
       s.PaintTo(Bitmap.Canvas, 0, 0);
       PNG.Assign(Bitmap);
       PNG.SaveToFile(ExtractFilePath(ParamStr(0)) + 'settings-tab-' + IntToStr(i) + '.png');
      End;
     s.SettingsPages.ActivePageIndex := 0;
     s.Hide;
    Finally
     PNG.Free;
     Bitmap.Free;
    End;
    s.cbLanguage.ItemIndex := 7;
    s.Save(c);
    Check((Language = 'de-DE') And (c.ReadString('ui', 'language', '') = 'de-DE'), 'Save German');
    s.cbLanguage.ItemIndex := 11;
    s.Save(c);
    Check((Language = 'es-ES') And (s.Caption = 'Ajustes'), 'Save Spanish');
    s.cbLanguage.ItemIndex := 23;
    s.Save(c);
    Check(Language = 'pl-PL', 'Save applies language');
    Check(f.aSettings.Caption = 'Ustawienia', 'Open form retranslates');
    c.WriteString('ui', 'language', 'en-US');
    s.Load(c);
    s.ModalResult := mrCancel;
    Check(Language = 'pl-PL', 'Loading/cancelling settings does not apply selection');
   Finally
    s.Free;
    c.Free;
    DeleteFile(TPath.Combine(ExtractFilePath(ParamStr(0)), 'localization-test.ini'));
   End;
   SetLanguage('en-US');
   r        := TfrmReport.Create(Nil);
   b        := TfraSimBrief.Create(Nil);
   b.Parent := f;
   Try
    Check(r.btnClose.Caption = 'Close', 'Report translation');
    Check(b.btnFetch.Caption = 'Fetch latest plan', 'Frame translation');
    b.LoadPayload('{"origin":{"icao_code":"EPLL"},"destination":{"icao_code":"EGLL"},"general":{"flight_number":"LOT123"}}', 'Test');
    Check(TGroupBox(b.Sections.Controls[0]).Caption = 'Flight Info', 'Dynamic section translation');
    SetLanguage('pl-PL');
    b.Retranslate;
    Check(TGroupBox(b.Sections.Controls[0]).Caption = 'Informacje o locie', 'Dynamic Polish section');
   Finally
    b.Free;
    r.Free;
   End;
   Worker := TThread.CreateAnonymousThread(
   Procedure
   Begin
   Try
   If Tr('Ustawienia') <> 'Ustawienia' Then
   Failure := 'Worker translation';
   Except
   On E : Exception Do
   Failure := E.Message;
   End;
   End);
   Worker.FreeOnTerminate := False;
   Worker.Start;
   Worker.WaitFor;
   Worker.Free;
   Check(Failure = '', 'Thread-safe lookup: ' + Failure);
   Check(FormatSettings.DecimalSeparator = DecimalBefore, 'Numeric formatting unchanged');
   SetLanguage('unsupported');
   Check(Language = 'en-US', 'Unsupported locale falls back to English');
  Finally
   f.aPolish.Execute;
   f.Free;
  End;
  System.Writeln('PASS: Polish default, live English/Polish/German/Spanish menu/forms/frame, dynamic SimBrief, saved language, cancel, worker lookup and invariant number formatting.');

 End;

Begin
 RunNativeTests(TVerifyLocalizationTests);

End.
