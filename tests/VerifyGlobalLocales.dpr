Program VerifyGlobalLocales;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU,
 System.SysUtils, System.Classes, System.Types, System.IniFiles, System.IOUtils,
 Winapi.Windows, Vcl.Forms, Vcl.Graphics, Vcl.Controls, Vcl.Menus, Vcl.ActnList, Vcl.Imaging.pngimage,
 LocalizationU, UIFontsU, frmMainU, frmSettingsU, FlightChartsU, FlightMapU;

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
 m       : TfrmMain;
 s       : TfrmSettings;
 Fresh   : TfrmSettings;
 b       : TBitmap;
 i       : Integer;
 j       : Integer;
 Indices : Array [0..63] Of Word;
 Text    : String;
 Code    : String;
 l       : Integer;
 Chart   : TFlightCharts;
 Map     : TFlightMap;
 Pref    : TMemIniFile;
 Temp    : String;
 Sep     : Char;

Const
 Codes : Array [0..6] Of String = ('zh-CN', 'ja-JP', 'vi-VN', 'hi-IN', 'ar-SA', 'he-IL', 'id-ID');
 Samples : Array [0..6] Of String = ('简体中文', '日本語', 'Tiếng Việt', 'हिन्दी', 'العربية', 'עברית', 'Bahasa Indonesia');

Type

 [TestFixture]
 TVerifyGlobalLocalesTests = Class
  Public
   [Test]
   Procedure Regression;
 End;

Procedure TVerifyGlobalLocalesTests.Regression;
 Begin
  Try
   Application.Initialize;
   Sep := FormatSettings.DecimalSeparator;
   Check(BundledFontCount = 5, 'Five private font files loaded');
   Check((NormalizeLanguage('ar') = 'ar-SA') And (NormalizeLanguage('he') = 'he-IL') And (NormalizeLanguage('iw-IL') = 'he-IL') And (NormalizeLanguage('in-ID') = 'id-ID'), 'Aliases');
   Check((NormalizeLanguage('zh-Hans-CN') = 'zh-CN') And (NormalizeLanguage('ja') = 'ja-JP'), 'Script/primary fallback');
   For i := 1 To UILanguageCount - 1 Do
    Check(CompareStr(UILanguageLocales[i - 1], UILanguageLocales[i]) < 0, 'Sorted codes');
   SetLanguage('en-US');
   m     := TfrmMain.Create(Nil);
   s     := TfrmSettings.Create(Nil);
   b     := TBitmap.Create;
   Chart := TFlightCharts.Create(Nil);
   Map   := TFlightMap.Create(Nil);
   Temp  := TPath.GetTempFileName;
   Pref  := TMemIniFile.Create(Temp);
   Try
    m.Timer.Enabled := False;
    l               := s.LanguageLabel.Left;
    Check(m.miLanguage.Count = UILanguageCount + 1, 'Menu count');
    For i := 0 To UILanguageCount - 1 Do
     Begin
      Check((m.miLanguage.Items[i + 1].Action As TAction).Tag = i + 1, 'Sorted language menu');
      Check(s.cbLanguage.Items[i + 1] = UILanguageNames[i], 'Sorted settings list');
     End;
    b.SetSize(1000, 16 * 30);
    b.Canvas.Brush.Color := clMenu;
    b.Canvas.FillRect(Rect(0, 0, b.Width, b.Height));
    For i := 0 To UILanguageCount - 1 Do
     m.LanguageMenuDraw(m.miLanguage.Items[i + 1], b.Canvas, Rect((i Div 16) * 500, (i Mod 16) * 30, (i Div 16) * 500 + 500, (i Mod 16) * 30 + 30), False);
    b.SaveToFile(ExtractFilePath(ParamStr(0)) + 'global-language-menu.bmp');
    For i := 0 To High(Codes) Do
     Begin
      Code := Codes[i];
      SetLanguage(Code);
      Application.ProcessMessages;
      Check(s.Font.Name = LocaleFontName(Code), 'Form font ' + Code);
      Check((s.BiDiMode = bdRightToLeft) = ((i = 4) Or (i = 5)), 'Form direction ' + Code);
      Check((Application.BiDiMode = bdRightToLeft) = ((i = 4) Or (i = 5)), 'Application direction ' + Code);
      If (i = 4) Or (i = 5) Then
       Begin
        Fresh := TfrmSettings.Create(Nil);
        Try
         Check((Fresh.BiDiMode = bdRightToLeft) And (Fresh.LanguageLabel.Left > Fresh.ClientWidth Div 2), 'Fresh RTL layout ' + Code);
        Finally
         Fresh.Free;
        End;
       End;
      Check((m.mPlan.BiDiMode = bdLeftToRight) And (m.Timeline.BiDiMode = bdLeftToRight) And (m.ViewPan.BiDiMode = bdLeftToRight) And (Chart.BiDiMode = bdLeftToRight) And (Map.BiDiMode = bdLeftToRight), 'Raw data/map/time axis stay LTR');
      b.SetSize(700, 40);
      b.Canvas.Font.Name := LocaleFontName(Code);
      Text               := Samples[i];
      Check(GetGlyphIndicesW(b.Canvas.Handle, PWideChar(Text), Length(Text), @Indices[0], GGI_MARK_NONEXISTING_GLYPHS) <> GDI_ERROR, 'Glyph lookup');
      For j := 0 To Length(Text) - 1 Do
       Check(Indices[j] <> $FFFF, 'Missing glyph ' + Code + ' ' + IntToHex(Ord(Text[j + 1]), 4));
      Pref.WriteString('ui', 'language', Code);
      s.Load(Pref);
      s.Save(Pref);
      Check(Pref.ReadString('ui', 'language', '') = Code, 'Round trip ' + Code);
      Picture(s, 'global-settings-' + Code);
      SetLanguage('en-US');
      Check(s.BiDiMode = bdLeftToRight, 'Return LTR');
      Check(s.LanguageLabel.Left = l, 'Layout round trip ' + Code + ' expected ' + IntToStr(l) + ' actual ' + IntToStr(s.LanguageLabel.Left));
     End;
    Check(FormatSettings.DecimalSeparator = Sep, 'Numeric formats unchanged');
   Finally
    Pref.Free;
    System.SysUtils.DeleteFile(Temp);
    Map.Free;
    Chart.Free;
    b.Free;
    s.Free;
    m.Free;
   End;
   System.Writeln('PASS: 32 sorted locales, aliases, per-locale fonts, all seven script glyph samples, RTL/LTR/layout round trips, raw LTR and persisted settings. Synthetic only.');
  Except
   On E : Exception Do
    Begin
     System.Writeln('FAIL: ', E.ClassName, ': ', E.Message);
     Raise Exception.Create('Regression failed; see diagnostic above');
    End;
  End;

 End;

Begin
 RunNativeTests(TVerifyGlobalLocalesTests);

End.
