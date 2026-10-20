program VerifyGlobalLocales;
{$APPTYPE CONSOLE}
uses System.SysUtils,System.Classes,System.Types,System.IniFiles,System.IOUtils,
 Winapi.Windows,Vcl.Forms,Vcl.Graphics,Vcl.Controls,Vcl.Menus,Vcl.ActnList,Vcl.Imaging.pngimage,
 LocalizationU,UIFontsU,frmMainU,frmSettingsU,FlightChartsU,FlightMapU;
procedure Check(B:Boolean;const S:string);begin if not B then raise Exception.Create(S);end;
procedure Picture(F:TForm;const Name:string);
var B:TBitmap;P:TPngImage;
begin
 F.Position:=poDesigned;F.Left:=-4000;F.Show;Application.ProcessMessages;B:=F.GetFormImage;P:=TPngImage.Create;
 try P.Assign(B);P.SaveToFile(ExtractFilePath(ParamStr(0))+Name+'.png');finally P.Free;B.Free;F.Hide;end;
end;
var M:TfrmMain;S,Fresh:TfrmSettings;B:TBitmap;I,J:Integer;Indices:array[0..63]of Word;Text,Code:string;
 L:Integer;Chart:TFlightCharts;Map:TFlightMap;Pref:TMemIniFile;Temp:string;Sep:Char;
const Codes:array[0..6]of string=('zh-CN','ja-JP','vi-VN','hi-IN','ar-SA','he-IL','id-ID');
 Samples:array[0..6]of string=('简体中文','日本語','Tiếng Việt','हिन्दी','العربية','עברית','Bahasa Indonesia');
begin
 try
  Application.Initialize;Sep:=FormatSettings.DecimalSeparator;
  Check(BundledFontCount=5,'Five private font files loaded');
  Check((NormalizeLanguage('ar')='ar-SA') and (NormalizeLanguage('he')='he-IL') and
   (NormalizeLanguage('iw-IL')='he-IL') and (NormalizeLanguage('in-ID')='id-ID'),'Aliases');
  Check((NormalizeLanguage('zh-Hans-CN')='zh-CN') and (NormalizeLanguage('ja')='ja-JP'),'Script/primary fallback');
  for I:=1 to UILanguageCount-1 do Check(CompareStr(UILanguageLocales[I-1],UILanguageLocales[I])<0,'Sorted codes');
  SetLanguage('en-US');M:=TfrmMain.Create(nil);S:=TfrmSettings.Create(nil);B:=TBitmap.Create;
  Chart:=TFlightCharts.Create(nil);Map:=TFlightMap.Create(nil);Temp:=TPath.GetTempFileName;Pref:=TMemIniFile.Create(Temp);
  try
   M.Timer.Enabled:=False;L:=S.LanguageLabel.Left;
   Check(M.miLanguage.Count=UILanguageCount+1,'Menu count');
   for I:=0 to UILanguageCount-1 do begin
    Check((M.miLanguage.Items[I+1].Action as TAction).Tag=I+1,'Sorted language menu');
    Check(S.cbLanguage.Items[I+1]=UILanguageNames[I],'Sorted settings list');
   end;
   B.SetSize(1000,16*30); B.Canvas.Brush.Color:=clMenu; B.Canvas.FillRect(Rect(0,0,B.Width,B.Height));
   for I:=0 to UILanguageCount-1 do
    M.LanguageMenuDraw(M.miLanguage.Items[I+1],B.Canvas,Rect((I div 16)*500,(I mod 16)*30,(I div 16)*500+500,(I mod 16)*30+30),False);
   B.SaveToFile(ExtractFilePath(ParamStr(0))+'global-language-menu.bmp');
   for I:=0 to High(Codes) do begin
    Code:=Codes[I];SetLanguage(Code);Application.ProcessMessages;
    Check(S.Font.Name=LocaleFontName(Code),'Form font '+Code);
    Check((S.BiDiMode=bdRightToLeft)=((I=4)or(I=5)),'Form direction '+Code);
    Check((Application.BiDiMode=bdRightToLeft)=((I=4)or(I=5)),'Application direction '+Code);
    if (I=4)or(I=5) then begin
     Fresh:=TfrmSettings.Create(nil);
     try Check((Fresh.BiDiMode=bdRightToLeft) and (Fresh.LanguageLabel.Left>Fresh.ClientWidth div 2),'Fresh RTL layout '+Code);
     finally Fresh.Free;end;
    end;
    Check((M.mPlan.BiDiMode=bdLeftToRight) and (M.Timeline.BiDiMode=bdLeftToRight) and (M.ViewPan.BiDiMode=bdLeftToRight) and (Chart.BiDiMode=bdLeftToRight) and
     (Map.BiDiMode=bdLeftToRight),'Raw data/map/time axis stay LTR');
    B.SetSize(700,40);B.Canvas.Font.Name:=LocaleFontName(Code);Text:=Samples[I];
    Check(GetGlyphIndicesW(B.Canvas.Handle,PWideChar(Text),Length(Text),@Indices[0],GGI_MARK_NONEXISTING_GLYPHS)<>GDI_ERROR,'Glyph lookup');
    for J:=0 to Length(Text)-1 do Check(Indices[J]<>$FFFF,'Missing glyph '+Code+' '+IntToHex(Ord(Text[J+1]),4));
    Pref.WriteString('ui','language',Code);S.Load(Pref);S.Save(Pref);
    Check(Pref.ReadString('ui','language','')=Code,'Round trip '+Code);
    Picture(S,'global-settings-'+Code);
    SetLanguage('en-US');Check(S.BiDiMode=bdLeftToRight,'Return LTR');
    Check(S.LanguageLabel.Left=L,'Layout round trip '+Code+' expected '+IntToStr(L)+' actual '+IntToStr(S.LanguageLabel.Left));
   end;
   Check(FormatSettings.DecimalSeparator=Sep,'Numeric formats unchanged');
  finally Pref.Free;System.SysUtils.DeleteFile(Temp);Map.Free;Chart.Free;B.Free;S.Free;M.Free;end;
  Writeln('PASS: 32 sorted locales, aliases, per-locale fonts, all seven script glyph samples, RTL/LTR/layout round trips, raw LTR and persisted settings. Synthetic only.');
 except on E:Exception do begin Writeln('FAIL: ',E.ClassName,': ',E.Message);Halt(1);end;end;
end.
