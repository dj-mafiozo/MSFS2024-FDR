Program VerifyChartsConfigure;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU,
 Vcl.ImgList, System.IOUtils, System.SysUtils, System.Classes, System.UITypes, Winapi.Windows, Vcl.Forms, Vcl.Graphics,
 Vcl.Imaging.pngimage, frmSimBriefFrameU, LocalizationU, frmChartsConfigureU, frmMainU;

Procedure Check(b : Boolean; Const m : String);
 Begin
  If Not b Then
   Raise Exception.Create(m);
 End;

Procedure CheckDialogIcons(Images : TCustomImageList);
 Const
  Names : Array [0..5] Of String = ('go-top.png', 'go-up.png', 'go-down.png', 'go-bottom.png', 'go-previous.png', 'go-next.png');
 Var
  Actual   : TBitmap;
  Expected : TBitmap;
  Source   : TPngImage;
  i        : Integer;
  x        : Integer;
  y        : Integer;
  a        : TColor;
  e        : TColor;
 Begin
  Actual   := TBitmap.Create;
  Expected := TBitmap.Create;
  Source   := TPngImage.Create;
  Try
   Actual.SetSize(22, 22);
   Expected.SetSize(22, 22);
   For i := 0 To 5 Do
    Begin
     Source.LoadFromFile(ExtractFilePath(ParamStr(0)) + '..\Icons\22x22\' + Names[i]);
     Actual.Canvas.Brush.Color := RGB(123, 151, 179);
     Actual.Canvas.FillRect(Rect(0, 0, 22, 22));
     Expected.Canvas.Brush.Color := RGB(123, 151, 179);
     Expected.Canvas.FillRect(Rect(0, 0, 22, 22));
     Expected.Canvas.Draw(0, 0, Source);
     Images.Draw(Actual.Canvas, 0, 0, i);
     For y  := 0 To 21 Do
      For x := 0 To 21 Do
       Begin
        a := ColorToRGB(Actual.Canvas.Pixels[x, y]);
        e := ColorToRGB(Expected.Canvas.Pixels[x, y]);
        Check((Abs(GetRValue(a) - GetRValue(e)) <= 3) And (Abs(GetGValue(a) - GetGValue(e)) <= 3) And (Abs(GetBValue(a) - GetBValue(e)) <= 3), 'Dialog PNG alpha ' + IntToStr(i));
       End;
    End;
  Finally
   Source.Free;
   Expected.Free;
   Actual.Free;
  End;
 End;

Var
 d             : TfrmChartsConfigure;
 Available     : TStringList;
 Selected      : TStringList;
 ResultList    : TStringList;
 f             : TfrmMain;
 s             : TfraSimBrief;
 Names         : TStringList;
 Ratio         : Double;
 i             : Integer;
 b             : TBitmap;
 Expected      : TBitmap;
 PNG           : TPngImage;
 Background    : TColor;
 Source        : TPngImage;
 x             : Integer;
 y             : Integer;
 FileName      : String;
 ActualColor   : TColor;
 ExpectedColor : TColor;

Type

 [TestFixture]
 TVerifyChartsConfigureTests = Class
  Public
   [Test]
   Procedure Regression;
 End;

Procedure TVerifyChartsConfigureTests.Regression;
 Begin
  Application.Initialize;
  SetLanguage('pl-PL');
  Available  := TStringList.Create;
  Selected   := TStringList.Create;
  ResultList := TStringList.Create;
  d          := TfrmChartsConfigure.Create(Nil);
  Try
   Available.Add('ALT');
   Available.Add('IAS');
   Available.Add('VS');
   Selected.Add('ALT');
   Selected.Add('other_aircraft_field');
   Selected.Add('VS');
   Check((d.ImageList.Count = 6) And (d.ActionList.ActionCount = 8), 'Owned icons and actions');
   CheckDialogIcons(d.ImageList);
   d.Configure(Available, Selected);
   Check(d.ParameterList.Count = 3, 'All parameters loaded');
   Check(d.ChartOrderList.Count = 2, 'Only available selected charts shown');
   d.eSearch.Text := 'ias';
   Check(d.ParameterList.Count = 1, 'Case-insensitive filter');
   d.ParameterList.ItemIndex  := 0;
   d.ParameterList.Checked[0] := True;
   d.ParameterCheck(d);
   d.eSearch.Text             := 'ALT';
   d.ParameterList.ItemIndex  := 0;
   d.ParameterList.Checked[0] := False;
   d.ParameterCheck(d);
   d.eSearch.Clear;
   Check(d.ParameterList.Checked[1] And d.ParameterList.Checked[2] And Not d.ParameterList.Checked[0], 'Checks survive filtering');
   d.ChartOrderList.ItemIndex := 1;
   d.aMoveUp.Execute;
   Check(d.ChartOrderList.Items[0] = 'IAS', 'Reorder');
   d.aHide.Execute;
   Check(d.ChartOrderList.Count = 1, 'Hide selected chart');
   Check(Not d.ParameterList.Checked[1], 'Hide unchecks parameter');
   Check((Selected.Count = 3) And (Selected[0] = 'ALT'), 'Caller data unchanged until acceptance');
   d.CopySelectionTo(ResultList);
   Check((ResultList.Count = 2) And (ResultList[0] = 'other_aircraft_field') And (ResultList[1] = 'VS'), 'Unseen aircraft preferences preserved');
   d.ListPanel.Width := 300;
   d.Splitter1.OnMoved(d.Splitter1);
   Ratio   := d.ListPanel.Width / (d.MainGroupBox.ClientWidth - d.Splitter1.Width - d.GraphButtonPanel.Width);
   d.Width := 1200;
   d.FormResize(d);
   Check(Abs(d.ListPanel.Width - Ratio * (d.MainGroupBox.ClientWidth - d.Splitter1.Width - d.GraphButtonPanel.Width)) <= 1, 'User split ratio on grow');
   d.Width := 850;
   d.FormResize(d);
   Check(Abs(d.ListPanel.Width - Ratio * (d.MainGroupBox.ClientWidth - d.Splitter1.Width - d.GraphButtonPanel.Width)) <= 1, 'User split ratio on shrink');
   Check((d.btnMoveUp.Glyph.PixelFormat = pf24bit) And (d.btnMoveUp.NumGlyphs = 1), 'SpeedButton compatible colour-key glyph');
   d.Width := 1000;
   d.ButtonsResize(d);
   Check(Abs((d.btnOk.Left + d.btnCancel.Left + d.btnCancel.Width) - d.ButtonPanel.ClientWidth) <= 1, 'Buttons centered on resize');
   d.Configure(Available, Selected);
   d.ChartOrderList.ItemIndex := 0;
   d.OrderClick(d);
   Check(Not d.btnMoveUp.Enabled And d.btnMoveDown.Enabled, 'Reorder boundaries');
   SetLanguage('en-US');
   Check(d.Caption = 'Chart settings', 'Localized new form');
   Check(d.btnCancel.Caption = '&Cancel', 'Localized cancel');
   d.aCancel.Execute;
   Check(d.ModalResult = mrCancel, 'Cancel action');
   d.aAccept.Execute;
   Check(d.ModalResult = mrOk, 'Accept action');
  Finally
   d.Free;
   ResultList.Free;
   Selected.Free;
   Available.Free;
  End;
  f        := TfrmMain.Create(Nil);
  b        := TBitmap.Create;
  Expected := TBitmap.Create;
  Expected.SetSize(22, 22);
  PNG := TPngImage.Create;
  Try
   f.Timer.Enabled  := False;
   f.aTiles.Checked := False;
   f.aTilesExecute(f.aTiles);
   Check(f.ImageList.Count >= 40, 'Image indices preserved');
   Check(Not f.ImageList.Masked, 'True-alpha image list');
   b.PixelFormat := pf32bit;
   b.SetSize(22, 22);
   Background := RGB(123, 151, 179);
   Source     := TPngImage.Create;
   Try
    For i := 0 To 34 Do
     Begin
      Case i Of
       0  : FileName := 'application-exit.png';
       1  : FileName := 'applications-internet.png';
       2  : FileName := 'applications-system.png';
       3  : FileName := 'dconf-editor.png';
       4  : FileName := 'document-open.png';
       5  : FileName := 'help-about.png';
       6  : FileName := 'media-playback-stop.png';
       7  : FileName := 'media-record.png';
       8  : FileName := 'preferences-system.png';
       9  : FileName := 'system-run.png';
       10 : FileName := 'view-refresh.png';
       11 : FileName := 'view-sort-ascending.png';
       12 : FileName := 'view-sort-descending.png';
       13 : FileName := 'zoom-fit-best.png';
       14 : FileName := 'zoom-in.png';
       15 : FileName := 'zoom-original.png';
       16 : FileName := 'zoom-out.png';
       17 : FileName := 'document-save.png';
       18 : FileName := 'document-send.png';
       19 : FileName := 'document-properties.png';
       20 : FileName := 'preferences-desktop-locale.png';
       25 : FileName := 'edit-delete.png';
       26 : FileName := 'image-x-generic.png';
       27 : FileName := 'emblem-shared.png';
       28 : FileName := 'folder-new.png';
       29 : FileName := 'folder.png';
       30 : FileName := 'weather-few-clouds.png';
       31 : FileName := 'insert-text.png';
       32 : FileName := 'view-restore.png';
       33 : FileName := 'view-fullscreen.png';
       34 : FileName := 'analysis-contact.png';
      Else FileName := '';
      End;
      If FileName <> '' Then
       Begin
        Source.LoadFromFile(ExtractFilePath(ParamStr(0)) + '..\Icons\22x22\' + FileName);
        Expected.Canvas.Brush.Color := Background;
        Expected.Canvas.FillRect(Rect(0, 0, 22, 22));
        Expected.Canvas.Draw(0, 0, Source);
       End;
      b.Canvas.Brush.Color := Background;
      b.Canvas.FillRect(Rect(0, 0, 22, 22));
      f.ImageList.Draw(b.Canvas, 0, 0, i);
      If FileName = '' Then
       Check(ColorToRGB(b.Canvas.Pixels[0, 0]) = Background, 'Transparent flag margin')
      Else
       For y  := 0 To 21 Do
        For x := 0 To 21 Do
         Begin
          ActualColor   := ColorToRGB(b.Canvas.Pixels[x, y]);
          ExpectedColor := ColorToRGB(Expected.Canvas.Pixels[x, y]);
          Check((Abs(GetRValue(ActualColor) - GetRValue(ExpectedColor)) <= 3) And (Abs(GetGValue(ActualColor) - GetGValue(ExpectedColor)) <= 3) And (Abs(GetBValue(ActualColor) - GetBValue(ExpectedColor)) <= 3), 'PNG alpha rendering ' + IntToStr(i) + ' pixel ' + IntToStr(x) + ',' + IntToStr(y) + ' actual=' + IntToHex(ActualColor, 6) + ' expected=' + IntToHex(ExpectedColor, 6));
         End;
     End;
   Finally
    Source.Free;
   End;
   b.Canvas.Brush.Color := Background;
   b.Canvas.FillRect(Rect(0, 0, 22, 22));
   f.ImageList.Draw(b.Canvas, 0, 0, 21);
   Expected.LoadFromFile(ExtractFilePath(ParamStr(0)) + '..\Icons\Flags\de.bmp');
   For y  := 0 To Expected.Height - 1 Do
    For x := 0 To Expected.Width - 1 Do
     Check(ColorToRGB(b.Canvas.Pixels[x + 3, y + 5]) = ColorToRGB(Expected.Canvas.Pixels[x, y]), 'Opaque flag colors must be preserved');
   s     := f.SimBriefPage.Controls[0] As TfraSimBrief;
   Names := TStringList.Create;
   Try
    Names.LoadFromFile(ExtractFilePath(ParamStr(0)) + '..\tools\dispatch-icons.txt');
    Check((s.ImageList.Count >= Names.Count) And Not s.ImageList.Masked, 'SimBrief alpha list');
    For i := 0 To Names.Count - 1 Do
     Begin
      PNG.LoadFromFile(ExtractFilePath(ParamStr(0)) + '..\Icons\22x22\' + Names[i]);
      Expected.SetSize(22, 22);
      Expected.Canvas.Brush.Color := Background;
      Expected.Canvas.FillRect(Rect(0, 0, 22, 22));
      Expected.Canvas.Draw(0, 0, PNG);
      b.Canvas.Brush.Color := Background;
      b.Canvas.FillRect(Rect(0, 0, 22, 22));
      s.ImageList.Draw(b.Canvas, 0, 0, i);
      For y  := 0 To 21 Do
       For x := 0 To 21 Do
        Begin
         ActualColor   := ColorToRGB(b.Canvas.Pixels[x, y]);
         ExpectedColor := ColorToRGB(Expected.Canvas.Pixels[x, y]);
         Check((Abs(GetRValue(ActualColor) - GetRValue(ExpectedColor)) <= 3) And (Abs(GetGValue(ActualColor) - GetGValue(ExpectedColor)) <= 3) And (Abs(GetBValue(ActualColor) - GetBValue(ExpectedColor)) <= 3), 'SimBrief PNG alpha ' + IntToStr(i));
        End;
     End;
   Finally
    Names.Free;
   End;
   s.aOlder.Checked := False;
   s.btnOlder.Click;
   Check(s.aOlder.Checked, 'SimBrief older-plan toggle');
   s.btnOlder.Click;
   f.aAuto.Checked := False;
   f.aAuto.Update;
   Check(Not f.aAuto.Enabled, 'Auto-record disabled without supported MSFS24');
   f.btnAuto.Click;
   Check(Not f.aAuto.Checked, 'Unsupported simulator cannot toggle recording');
   f.Position := poDesigned;
   f.Left     := -4000;
   f.Top      := 0;
   f.Show;
   Application.ProcessMessages;
   b.SetSize(f.ClientWidth, f.ClientHeight);
   f.PaintTo(b.Canvas, 0, 0);
   PNG.Assign(b);
   PNG.SaveToFile(ExtractFilePath(ParamStr(0)) + 'toolbar-preview.png');
  Finally
   PNG.Free;
   Expected.Free;
   b.Free;
   f.Free;
  End;
  SetLanguage('pl-PL');
  System.Writeln('PASS: chart configuration working copy, filtering, check state, order/hide, resize, localization; 47 alpha icons across all three lists and opaque flag stripe; action toggles.');

 End;

Begin
 RunNativeTests(TVerifyChartsConfigureTests);

End.
