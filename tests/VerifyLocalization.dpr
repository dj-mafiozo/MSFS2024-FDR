program VerifyLocalization;
{$APPTYPE CONSOLE}
uses Vcl.Menus,System.Actions,System.UITypes,System.SysUtils,System.Classes,System.IniFiles,System.IOUtils,Vcl.Forms,Vcl.StdCtrls,Vcl.Graphics,Vcl.Imaging.pngimage,
 LocalizationU,LocalizationCatalogU,frmMainU,frmSettingsU,frmReportU,frmTripInfoU,frmSimBriefFrameU;
procedure Check(B:Boolean;const M:string);begin if not B then raise Exception.Create(M);end;
function HasMenuAction(Item:TMenuItem;Action:TBasicAction):Boolean;
var I:Integer;
begin
 Result:=Item.Action=Action;
 for I:=0 to Item.Count-1 do if HasMenuAction(Item.Items[I],Action) then Exit(True);
end;
var I:Integer;
var F:TfrmMain;S:TfrmSettings;R:TfrmReport;B:TfraSimBrief;C:TMemIniFile;DecimalBefore:Char;Worker:TThread;Failure:string;Bitmap:TBitmap;PNG:TPngImage;
begin
 Application.Initialize;SetLanguage('pl-PL');DecimalBefore:=FormatSettings.DecimalSeparator;
 Check(Tr('Settings')='Settings','Unknown source fallback');
 Check(Tr('Ustawienia')='Ustawienia','Polish default');
 F:=TfrmMain.Create(nil);
 try
  for I:=0 to F.ActionList.ActionCount-1 do begin
   Check(HasMenuAction(F.MainMenu.Items,F.ActionList.Actions[I]),'Menu missing action '+F.ActionList.Actions[I].Name);
   Check(Assigned(F.ActionList.Actions[I].OnExecute),'Missing action handler '+F.ActionList.Actions[I].Name);
  end;
  F.aPolish.Execute;
  Check(F.aSettings.Caption='Ustawienia','Polish button');
  Check(StringReplace(F.miFile.Caption,'&','',[rfReplaceAll])='Plik','Polish menu');
  F.aEnglish.Execute;
  Check(F.aSettings.Caption='Settings','English button');
  Check(F.aChartsConfigure.Hint='Configure charts','Localized icon tooltip');
  Check(F.aGerman.Enabled and F.aSpanish.Enabled,'Four languages available');
  F.aGerman.Execute;Check((Language='de-DE') and (F.aSettings.Caption='Einstellungen'),'German menu');
  F.aSpanish.Execute;Check((Language='es-ES') and (F.aSettings.Caption='Ajustes'),'Spanish menu');
  Check(Pos('Arrastrar:',F.ChartsHost.Controls[0].Hint)=1,'Dynamic chart hint changes language');
  F.aEnglish.Execute;
  Check(Tr('Inny numer lotu.')='Flight number does not match.','SimBrief validation translation');
  Check(StringReplace(F.miFile.Caption,'&','',[rfReplaceAll])='File','Live menu translation');
  Check(F.DataTabs.Pages[0].Caption<>'','Tabs retained');
  S:=TfrmSettings.Create(nil);C:=TMemIniFile.Create(TPath.Combine(ExtractFilePath(ParamStr(0)),'localization-test.ini'));
  try
   C.WriteString('ui','language','en-US');S.Load(C);
   Check(S.Caption='Settings','New form uses current language');
   Check(S.cbLanguage.ItemIndex=10,'Load language selection');
   Check((S.SettingsPages.PageCount=4) and (S.ProviderPages.PageCount=3),'Tabbed settings');
   Check((S.cbLanguage.Items.Count=UILanguageCount+1) and (S.ClientHeight<600),'Compact four-language settings');
   Check(S.btnCancel.Caption='Cancel','English dialog button');
   Check(S.cbProvider.Items[1]='Gemini (API key)','Combo item translation');
   Check(Pos('run codex login',S.lHelp.Caption)>0,'Multiline DFM help translation');
   Bitmap:=TBitmap.Create;PNG:=TPngImage.Create;
   try S.Show;Application.ProcessMessages;Bitmap.SetSize(S.ClientWidth,S.ClientHeight);S.PaintTo(Bitmap.Canvas,0,0);PNG.Assign(Bitmap);PNG.SaveToFile(ExtractFilePath(ParamStr(0))+'settings-en-preview.png');
   finally S.Hide;PNG.Free;Bitmap.Free;end;
   Bitmap:=TBitmap.Create;PNG:=TPngImage.Create;
   try
    S.Show;
    for I:=1 to 3 do begin S.SettingsPages.ActivePageIndex:=I;Application.ProcessMessages;Bitmap.SetSize(S.ClientWidth,S.ClientHeight);S.PaintTo(Bitmap.Canvas,0,0);PNG.Assign(Bitmap);PNG.SaveToFile(ExtractFilePath(ParamStr(0))+'settings-tab-'+IntToStr(I)+'.png');end;
    S.SettingsPages.ActivePageIndex:=0;S.Hide;
   finally PNG.Free;Bitmap.Free;end;
   S.cbLanguage.ItemIndex:=7;S.Save(C);Check((Language='de-DE') and (C.ReadString('ui','language','')='de-DE'),'Save German');
   S.cbLanguage.ItemIndex:=11;S.Save(C);Check((Language='es-ES') and (S.Caption='Ajustes'),'Save Spanish');
   S.cbLanguage.ItemIndex:=23;S.Save(C);
   Check(Language='pl-PL','Save applies language');
   Check(F.aSettings.Caption='Ustawienia','Open form retranslates');
   C.WriteString('ui','language','en-US');S.Load(C);S.ModalResult:=mrCancel;
   Check(Language='pl-PL','Loading/cancelling settings does not apply selection');
  finally S.Free;C.Free;DeleteFile(TPath.Combine(ExtractFilePath(ParamStr(0)),'localization-test.ini'));end;
  SetLanguage('en-US');R:=TfrmReport.Create(nil);B:=TfraSimBrief.Create(nil);B.Parent:=F;
  try
   Check(R.btnClose.Caption='Close','Report translation');
   Check(B.btnFetch.Caption='Fetch latest plan','Frame translation');
   B.LoadPayload('{"origin":{"icao_code":"EPLL"},"destination":{"icao_code":"EGLL"},"general":{"flight_number":"LOT123"}}','Test');
   Check(TGroupBox(B.Sections.Controls[0]).Caption='Flight Info','Dynamic section translation');
   SetLanguage('pl-PL');B.Retranslate;
   Check(TGroupBox(B.Sections.Controls[0]).Caption='Informacje o locie','Dynamic Polish section');
  finally B.Free;R.Free;end;
  Worker:=TThread.CreateAnonymousThread(procedure begin try if Tr('Ustawienia')<>'Ustawienia' then Failure:='Worker translation';except on E:Exception do Failure:=E.Message;end;end);
  Worker.FreeOnTerminate:=False;Worker.Start;Worker.WaitFor;Worker.Free;
  Check(Failure='','Thread-safe lookup: '+Failure);
  Check(FormatSettings.DecimalSeparator=DecimalBefore,'Numeric formatting unchanged');
  SetLanguage('unsupported');Check(Language='en-US','Unsupported locale falls back to English');
 finally F.aPolish.Execute;F.Free;end;
 Writeln('PASS: Polish default, live English/Polish/German/Spanish menu/forms/frame, dynamic SimBrief, saved language, cancel, worker lookup and invariant number formatting.');
end.
