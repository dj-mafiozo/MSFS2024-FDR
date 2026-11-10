Program VerifyLocaleExpansion;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU,
 System.SysUtils, System.Classes, System.IniFiles, System.IOUtils, System.Actions,
 Vcl.Forms, Vcl.Graphics, Vcl.Imaging.pngimage, Vcl.ActnList, LocalizationU, frmMainU, frmSettingsU, ParameterNamesU, AppHelpU;

Procedure Check(b : Boolean; Const s : String);
 Begin
  If Not b Then
   Raise Exception.Create(s);
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
 m              : TfrmMain;
 s              : TfrmSettings;
 c              : TMemIniFile;
 FileName       : String;
 BeforeLanguage : String;
 Before         : Char;
 i              : Integer;
 j              : Integer;
 Action         : TAction;

Const
 Inputs : Array [0..29] Of String = ('en-GB', 'EN_gb', 'fr-CA', 'pt-BR', 'de-AT', 'de-CH', 'be', 'el', 'uk', 'hr', 'cs', 'da', 'nl', 'fi', 'no', 'nb', 'nn', 'nb-NO', 'nn-NO', 'sk', 'sv', 'sv-FI', 'nl-BE', 'de-DE', 'fr-FR', 'en-AU', 'pt-PT', 'ja-JP', 'xx', '');
 Expected : Array [0..29] Of String = ('en-GB', 'en-GB', 'fr-CA', 'pt-BR', 'de-AT', 'de-CH', 'be-BY', 'el-GR', 'uk-UA', 'hr-HR', 'cs-CZ', 'da-DK', 'nl-NL', 'fi-FI', 'nb-NO', 'nb-NO', 'nb-NO', 'nb-NO', 'nb-NO', 'sk-SK', 'sv-SE', 'sv-SE', 'nl-NL', 'de-DE', 'fr-FR', 'en-US', 'pt-PT', 'ja-JP', 'en-US', 'en-US');
 Captions : Array [0..31] Of String = ('الإعدادات', 'Налады', 'Nastavení', 'Indstillinger', 'Einstellungen', 'Einstellungen', 'Einstellungen', 'Ρυθμίσεις', 'Settings', 'Settings', 'Ajustes', 'Asetukset', 'Paramètres', 'Paramètres', 'הגדרות', 'सेटिंग्स', 'Postavke', 'Pengaturan', 'Impostazioni', '設定', 'Innstillinger', 'Instellingen', 'Ustawienia', 'Configurações', 'Definições', 'Настройки', 'Nastavenia', 'Inställningar', 'Ayarlar', 'Налаштування', 'Cài đặt', '设置');

Type

 [TestFixture]
 TVerifyLocaleExpansionTests = Class
  Public
   [Test]
   Procedure Regression;
 End;

Procedure TVerifyLocaleExpansionTests.Regression;
 Begin
  Try
   Application.Initialize;
   Before := FormatSettings.DecimalSeparator;
   For i  := 0 To High(Inputs) Do
    Check(NormalizeLanguage(Inputs[i]) = Expected[i], 'Normalize ' + Inputs[i]);
   FileName := TPath.GetTempFileName;
   c        := TMemIniFile.Create(FileName);
   m        := TfrmMain.Create(Nil);
   s        := TfrmSettings.Create(Nil);
   Try
    m.Timer.Enabled := False;
    Check(UILanguageCount = 32, '32 registered locales');
    For i := 0 To UILanguageCount - 1 Do
     Begin
      Action := Nil;
      For j  := 0 To m.ActionList.ActionCount - 1 Do
       If (m.ActionList.Actions[j] Is TAction) And (TAction(m.ActionList.Actions[j]).Category = 'Language') And (m.ActionList.Actions[j].Tag = i + 1) Then
        Action := TAction(m.ActionList.Actions[j]);
      Check(Assigned(Action), 'Locale action ' + UILanguageLocales[i]);
      Action.Execute;
      Check((Language = UILanguageLocales[i]) And (LanguagePreference = UILanguageLocales[i]) And Action.Checked, 'Action locale ' + UILanguageLocales[i]);
      c.WriteString('ui', 'language', UILanguageLocales[i]);
      s.Load(c);
      Check(s.cbLanguage.ItemIndex = i + 1, 'Settings index ' + UILanguageLocales[i]);
      Check(s.Caption = Captions[i], 'Caption ' + UILanguageLocales[i] + ' ' + s.Caption);
      s.Save(c);
      Check(c.ReadString('ui', 'language', '') = UILanguageLocales[i], 'Persist variant ' + UILanguageLocales[i]);
      Check(ParameterCaption('plane_altitude') <> 'plane_altitude', 'Readable parameter');
      Check(FileExists(HelpFileName), 'Available help or fallback');
      If (UILanguageLocales[i] = 'el-GR') Or (UILanguageLocales[i] = 'be-BY') Or (UILanguageLocales[i] = 'pt-BR') Then
       Picture(s, 'settings-' + UILanguageLocales[i] + '-preview');
     End;
    Check(s.cbLanguage.Items.Count = 33, 'Auto plus 32 choices');
    c.WriteString('ui', 'language', 'nn-NO');
    s.Load(c);
    Check(s.cbLanguage.ItemIndex = 21, 'Nynorsk maps to available Bokmal');
    BeforeLanguage := Language;
    s.Load(c);
    Check(Language = BeforeLanguage, 'Settings load does not apply');
    s.cbLanguage.ItemIndex := 0;
    s.Save(c);
    Check((LanguagePreference = 'auto') And (c.ReadString('ui', 'language', '') = 'auto'), 'Preserve auto');
    m.aLangAuto.Execute;
    Check(m.aLangAuto.Checked, 'Auto action');
    Check(FormatSettings.DecimalSeparator = Before, 'Formatting remains Windows-controlled');
   Finally
    s.Free;
    m.Free;
    c.Free;
    DeleteFile(FileName);
   End;
   System.Writeln('PASS: 30 regional/alias/fallback cases; all 32 menu actions, captions, settings indices/persistence, auto, number format and help fallback. Synthetic only.');
  Except
   On E : Exception Do
    Begin
     System.Writeln('FAIL: ', E.Message);
     Raise Exception.Create('Regression failed; see diagnostic above');
    End;
  End;

 End;

Begin
 RunNativeTests(TVerifyLocaleExpansionTests);

End.
