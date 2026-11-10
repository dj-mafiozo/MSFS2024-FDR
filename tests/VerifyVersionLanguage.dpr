Program VerifyVersionLanguage;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}
{$R '..\src\MSFS2024-FDR.res'}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU,
 System.SysUtils, System.IniFiles, System.IOUtils, Vcl.Forms, Vcl.Graphics, Vcl.Imaging.pngimage, VersionU, LocalizationU, frmMainU, frmSettingsU, frmAboutU, frmChartsConfigureU;

Procedure Check(b : Boolean; Const m : String); Forward;

Procedure CheckSearchHints(Main : TfrmMain);
 Var
  Charts : TfrmChartsConfigure;
 Begin
  SetLanguage('en-US');
  Charts := TfrmChartsConfigure.Create(Nil);
  Try
   Check(Main.eSearch.TextHint = 'Search recordings', 'Recording search hint');
   Check(Main.eValueSearch.TextHint = 'Search parameters', 'Value search hint');
   Check(Charts.eSearch.TextHint = 'Search parameters', 'Chart search hint');
   SetLanguage('pl-PL');
   Check(Main.eSearch.TextHint = 'Szukaj nagrania lotu', 'Recording hint restored');
   Check(Main.eValueSearch.TextHint = 'Szukaj parametru', 'Value hint restored');
  Finally
   Charts.Free;
  End;
 End;

Procedure Check(b : Boolean; Const m : String);
 Begin
  If Not b Then
   Raise Exception.Create(m);
 End;

Procedure Picture(f : TForm; Const Name : String);
 Var
  b : TBitmap;
  p : TPngImage;
 Begin
  f.Position := poDesigned;
  f.Left     := -4000;
  f.Show;
  Application.ProcessMessages;
  b := f.GetFormImage;
  p := TPngImage.Create;
  Try
   p.Assign(b);
   p.SaveToFile(ExtractFilePath(ParamStr(0)) + Name + '.png');
  Finally
   p.Free;
   b.Free;
   f.Hide;
  End;
 End;

Var
 v        : TExeVersionInfo;
 m        : TfrmMain;
 s        : TfrmSettings;
 a        : TfrmAbout;
 c        : TMemIniFile;
 FileName : String;
 i        : Integer;

Const
 Inputs : Array [0..13] Of String = ('en-GB', 'EN_au', 'fr-CA', 'pt-BR', 'es-MX', 'de-AT', 'pl', 'ru-KZ', 'tr', 'it-CH', 'ja-JP', 'xx', 'en', '');
 Expected : Array [0..13] Of String = ('en-GB', 'en-US', 'fr-CA', 'pt-BR', 'es-ES', 'de-AT', 'pl-PL', 'ru-RU', 'tr-TR', 'it-IT', 'ja-JP', 'en-US', 'en-US', 'en-US');
 Captions : Array [0..8] Of String = ('Ustawienia', 'Settings', 'Einstellungen', 'Ajustes', 'Paramètres', 'Настройки', 'Ayarlar', 'Impostazioni', 'Definições');
 Locales : Array [0..8] Of String = ('pl-PL', 'en-US', 'de-DE', 'es-ES', 'fr-FR', 'ru-RU', 'tr-TR', 'it-IT', 'pt-PT');

Type

 [TestFixture]
 TVerifyVersionLanguageTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyVersionLanguageTests.Regression;
 Begin
  Try
   Application.Initialize;
   For i := 0 To High(Inputs) Do
    Check(NormalizeLanguage(Inputs[i]) = Expected[i], 'Regional normalization ' + Inputs[i]);
   SetLanguage('auto');
   Check((LanguagePreference = 'auto') And (Language = WindowsLanguage), 'Windows auto resolution');
   Check(TFile.ReadAllText(ExtractFilePath(ParamStr(0)) + '..\bin\MSFS2024-FDR.i18n', TEncoding.UTF8) =
   TFile.ReadAllText(ExtractFilePath(ParamStr(0)) + '..\translations\MSFS2024-FDR.i18n', TEncoding.UTF8), 'Build deploys current translation catalog');
   v := ReadVersionInfo(ExtractFilePath(ParamStr(0)) + '..\bin\MSFS2024-FDR.exe');
   Check(v.Available And (v.FileVersion = ExeVersionInfo.FileVersion), 'Resource fixed version');
   Check((v.ProductVersion = '0.1') And (v.CompanyName = 'DJ M@fi0z0' + #$2122), 'Preserved metadata/Unicode');
   Check(Pos(#$00A9 + ' 2026', v.LegalCopyright) > 0, 'Copyright Unicode');
   Check(Not ReadVersionInfo('missing-file.exe').Available, 'Missing resource handled');
   FileName := TPath.GetTempFileName;
   c        := TMemIniFile.Create(FileName);
   m        := TfrmMain.Create(Nil);
   s        := TfrmSettings.Create(Nil);
   Try
    m.Timer.Enabled := False;
    m.aLangAuto.Execute;
    Check((LanguagePreference = 'auto') And m.aLangAuto.Checked, 'Auto action');
    CheckSearchHints(m);
    m.aFrench.Execute;
    Check((Language = 'fr-FR') And m.aFrench.Checked And Not m.aLangAuto.Checked, 'French action');
    m.aRussian.Execute;
    Check(Language = 'ru-RU', 'Russian action');
    m.aTurkish.Execute;
    Check(Language = 'tr-TR', 'Turkish action');
    m.aItalian.Execute;
    Check(Language = 'it-IT', 'Italian action');
    m.aPortuguese.Execute;
    Check(Language = 'pt-PT', 'Portuguese action');
    c.WriteString('ui', 'language', 'en-GB');
    s.Load(c);
    Check(s.cbLanguage.ItemIndex = 9, 'Settings regional language index');
    s.cbLanguage.ItemIndex := 0;
    s.Save(c);
    Check((c.ReadString('ui', 'language', '') = 'auto') And (LanguagePreference = 'auto'), 'Persist auto rather than effective locale');
    c.WriteString('ui', 'language', 'fr-CA');
    s.Load(c);
    Check(s.cbLanguage.ItemIndex = 13, 'Settings French region');
    SetLanguage('pl-PL');
    s.Load(c);
    Check(Language = 'pl-PL', 'Load/cancel does not change active language');
    For i := 0 To High(Locales) Do
     Begin
      SetLanguage(Locales[i]);
      Check(Language = Locales[i], 'Selectable locale');
      Check(s.Caption = Captions[i], 'Localized settings ' + Locales[i] + ': ' + s.Caption);
     End;
    Check(s.cbLanguage.Items.Count = UILanguageCount + 1, 'Auto plus nine languages');
    SetLanguage('fr-FR');
    Picture(s, 'settings-fr-preview');
    SetLanguage('ru-RU');
    a := TfrmAbout.Create(Nil);
    Try
     Check(a.lLicense.Caption <> '', 'About remains localized');
     Check(Pos('Версия', a.lVersion.Caption) = 1, 'Localized version label');
     Check(Pos(ExeVersionInfo.FileVersion, a.lVersion.Caption) > 0, 'About reads its EXE resource');
     Picture(a, 'about-ru-preview');
    Finally
     a.Free;
    End;
   Finally
    s.Free;
    m.Free;
    c.Free;
    DeleteFile(FileName);
   End;
   System.Writeln('PASS: 14 regional/fallback cases, Windows auto, nine locales/actions, settings persistence/cancel and Unicode EXE VersionInfo. Synthetic; actual EXE resource inspected.');
  Except
   On E : Exception Do
    Begin
     System.Writeln('FAIL: ', E.Message);
     Raise Exception.Create('Regression failed; see diagnostic above');
    End;
  End;

 End;

Begin
 RunNativeTests(TVerifyVersionLanguageTests);
End.
