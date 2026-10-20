program VerifyLocaleExpansion;
{$APPTYPE CONSOLE}
uses System.SysUtils,System.Classes,System.IniFiles,System.IOUtils, System.Actions,
 Vcl.Forms,Vcl.Graphics,Vcl.Imaging.pngimage,Vcl.ActnList,LocalizationU,frmMainU,frmSettingsU,ParameterNamesU,AppHelpU;
procedure Check(B:Boolean;const S:string);begin if not B then raise Exception.Create(S);end;
procedure Picture(F:TForm;const Name:string);
var B:TBitmap;P:TPngImage;
begin
 F.Position:=poDesigned;F.Left:=-4000;F.Show;Application.ProcessMessages;B:=F.GetFormImage;P:=TPngImage.Create;
 try P.Assign(B);P.SaveToFile(ExtractFilePath(ParamStr(0))+Name+'.png');finally P.Free;B.Free;F.Hide;end;
end;
var M:TfrmMain;S:TfrmSettings;C:TMemIniFile;FileName,BeforeLanguage:string;Before:Char;I,J:Integer;Action:TAction;
const Inputs:array[0..29]of string=('en-GB','EN_gb','fr-CA','pt-BR','de-AT','de-CH','be','el','uk','hr','cs','da','nl','fi','no','nb','nn','nb-NO','nn-NO','sk','sv','sv-FI','nl-BE','de-DE','fr-FR','en-AU','pt-PT','ja-JP','xx','');
 Expected:array[0..29]of string=('en-GB','en-GB','fr-CA','pt-BR','de-AT','de-CH','be-BY','el-GR','uk-UA','hr-HR','cs-CZ','da-DK','nl-NL','fi-FI','nb-NO','nb-NO','nb-NO','nb-NO','nb-NO','sk-SK','sv-SE','sv-SE','nl-NL','de-DE','fr-FR','en-US','pt-PT','ja-JP','en-US','en-US');
 Captions:array[0..31]of string=('الإعدادات','Налады','Nastavení','Indstillinger','Einstellungen','Einstellungen','Einstellungen','Ρυθμίσεις','Settings','Settings','Ajustes','Asetukset','Paramètres','Paramètres','הגדרות','सेटिंग्स','Postavke','Pengaturan','Impostazioni','設定','Innstillinger','Instellingen','Ustawienia','Configurações','Definições','Настройки','Nastavenia','Inställningar','Ayarlar','Налаштування','Cài đặt','设置');
begin
 try
  Application.Initialize;Before:=FormatSettings.DecimalSeparator;
  for I:=0 to High(Inputs) do Check(NormalizeLanguage(Inputs[I])=Expected[I],'Normalize '+Inputs[I]);
  FileName:=TPath.GetTempFileName;C:=TMemIniFile.Create(FileName);M:=TfrmMain.Create(nil);S:=TfrmSettings.Create(nil);
  try
   M.Timer.Enabled:=False;Check(UILanguageCount=32,'32 registered locales');
   for I:=0 to UILanguageCount-1 do begin
    Action:=nil;
    for J:=0 to M.ActionList.ActionCount-1 do
     if (M.ActionList.Actions[J] is TAction) and (TAction(M.ActionList.Actions[J]).Category='Language') and (M.ActionList.Actions[J].Tag=I+1) then Action:=TAction(M.ActionList.Actions[J]);
    Check(Assigned(Action),'Locale action '+UILanguageLocales[I]);Action.Execute;
    Check((Language=UILanguageLocales[I]) and (LanguagePreference=UILanguageLocales[I]) and Action.Checked,'Action locale '+UILanguageLocales[I]);
    C.WriteString('ui','language',UILanguageLocales[I]);S.Load(C);
    Check(S.cbLanguage.ItemIndex=I+1,'Settings index '+UILanguageLocales[I]);Check(S.Caption=Captions[I],'Caption '+UILanguageLocales[I]+' '+S.Caption);
    S.Save(C);Check(C.ReadString('ui','language','')=UILanguageLocales[I],'Persist variant '+UILanguageLocales[I]);
    Check(ParameterCaption('plane_altitude')<>'plane_altitude','Readable parameter');
    Check(FileExists(HelpFileName),'Available help or fallback');
    if (UILanguageLocales[I]='el-GR') or (UILanguageLocales[I]='be-BY') or (UILanguageLocales[I]='pt-BR') then Picture(S,'settings-'+UILanguageLocales[I]+'-preview');
   end;
   Check(S.cbLanguage.Items.Count=33,'Auto plus 32 choices');
   C.WriteString('ui','language','nn-NO');S.Load(C);Check(S.cbLanguage.ItemIndex=21,'Nynorsk maps to available Bokmal');
   BeforeLanguage:=Language;S.Load(C);Check(Language=BeforeLanguage,'Settings load does not apply');
   S.cbLanguage.ItemIndex:=0;S.Save(C);Check((LanguagePreference='auto') and (C.ReadString('ui','language','')='auto'),'Preserve auto');
   M.aLangAuto.Execute;Check(M.aLangAuto.Checked,'Auto action');
   Check(FormatSettings.DecimalSeparator=Before,'Formatting remains Windows-controlled');
  finally S.Free;M.Free;C.Free;DeleteFile(FileName);end;
  Writeln('PASS: 30 regional/alias/fallback cases; all 32 menu actions, captions, settings indices/persistence, auto, number format and help fallback. Synthetic only.');
 except on E:Exception do begin Writeln('FAIL: ',E.Message);Halt(1);end;end;
end.
