program VerifyVersionLanguage;
{$APPTYPE CONSOLE}
{$R '..\src\MSFS2024-FDR.res'}
uses System.SysUtils,System.IniFiles,System.IOUtils,Vcl.Forms,Vcl.Graphics,Vcl.Imaging.pngimage,VersionU,LocalizationU,frmMainU,frmSettingsU,frmAboutU;
procedure Check(B:Boolean;const M:string);begin if not B then raise Exception.Create(M);end;
procedure Picture(F:TForm;const Name:string);
var B:TBitmap;P:TPngImage;
begin
 F.Position:=poDesigned;F.Left:=-4000;F.Show;Application.ProcessMessages;B:=F.GetFormImage;P:=TPngImage.Create;
 try P.Assign(B);P.SaveToFile(ExtractFilePath(ParamStr(0))+Name+'.png');finally P.Free;B.Free;F.Hide;end;
end;
var V:TExeVersionInfo;M:TfrmMain;S:TfrmSettings;A:TfrmAbout;C:TMemIniFile;FileName:string;I:Integer;
const Inputs:array[0..13]of string=('en-GB','EN_au','fr-CA','pt-BR','es-MX','de-AT','pl','ru-KZ','tr','it-CH','ja-JP','xx','en','');
 Expected:array[0..13]of string=('en-GB','en-US','fr-CA','pt-BR','es-ES','de-AT','pl-PL','ru-RU','tr-TR','it-IT','ja-JP','en-US','en-US','en-US');
 Captions:array[0..8]of string=('Ustawienia','Settings','Einstellungen','Ajustes','Paramètres','Настройки','Ayarlar','Impostazioni','Definições');
 Locales:array[0..8]of string=('pl-PL','en-US','de-DE','es-ES','fr-FR','ru-RU','tr-TR','it-IT','pt-PT');
begin
 try
  Application.Initialize;
  for I:=0 to High(Inputs) do Check(NormalizeLanguage(Inputs[I])=Expected[I],'Regional normalization '+Inputs[I]);
  SetLanguage('auto');Check((LanguagePreference='auto') and (Language=WindowsLanguage),'Windows auto resolution');
  V:=ReadVersionInfo(ExtractFilePath(ParamStr(0))+'..\bin\MSFS2024-FDR.exe');
  Check(V.Available and (V.FileVersion=ExeVersionInfo.FileVersion),'Resource fixed version');
  Check((V.ProductVersion='0.1') and (V.CompanyName='DJ M@fi0z0'+#$2122),'Preserved metadata/Unicode');
  Check(Pos(#$00A9+' 2026',V.LegalCopyright)>0,'Copyright Unicode');
  Check(not ReadVersionInfo('missing-file.exe').Available,'Missing resource handled');
  FileName:=TPath.GetTempFileName;C:=TMemIniFile.Create(FileName);M:=TfrmMain.Create(nil);S:=TfrmSettings.Create(nil);
  try
   M.Timer.Enabled:=False;M.aLangAuto.Execute;Check((LanguagePreference='auto') and M.aLangAuto.Checked,'Auto action');
   M.aFrench.Execute;Check((Language='fr-FR') and M.aFrench.Checked and not M.aLangAuto.Checked,'French action');
   M.aRussian.Execute;Check(Language='ru-RU','Russian action');M.aTurkish.Execute;Check(Language='tr-TR','Turkish action');
   M.aItalian.Execute;Check(Language='it-IT','Italian action');M.aPortuguese.Execute;Check(Language='pt-PT','Portuguese action');
   C.WriteString('ui','language','en-GB');S.Load(C);Check(S.cbLanguage.ItemIndex=9,'Settings regional language index');
   S.cbLanguage.ItemIndex:=0;S.Save(C);Check((C.ReadString('ui','language','')='auto') and (LanguagePreference='auto'),'Persist auto rather than effective locale');
   C.WriteString('ui','language','fr-CA');S.Load(C);Check(S.cbLanguage.ItemIndex=13,'Settings French region');
   SetLanguage('pl-PL');S.Load(C);Check(Language='pl-PL','Load/cancel does not change active language');
   for I:=0 to High(Locales) do begin
    SetLanguage(Locales[I]);Check(Language=Locales[I],'Selectable locale');
    Check(S.Caption=Captions[I],'Localized settings '+Locales[I]+': '+S.Caption);
   end;
   Check(S.cbLanguage.Items.Count=UILanguageCount+1,'Auto plus nine languages');SetLanguage('fr-FR');Picture(S,'settings-fr-preview');SetLanguage('ru-RU');
   A:=TfrmAbout.Create(nil);try Check(A.lLicense.Caption<>'','About remains localized');Check(Pos('Версия',A.lVersion.Caption)=1,'Localized version label');Check(Pos(ExeVersionInfo.FileVersion,A.lVersion.Caption)>0,'About reads its EXE resource');Picture(A,'about-ru-preview');finally A.Free;end;
  finally S.Free;M.Free;C.Free;DeleteFile(FileName);end;
  Writeln('PASS: 14 regional/fallback cases, Windows auto, nine locales/actions, settings persistence/cancel and Unicode EXE VersionInfo. Synthetic; actual EXE resource inspected.');
 except on E:Exception do begin Writeln('FAIL: ',E.Message);Halt(1);end;end;
end.
