program VerifyChartsConfigure;
{$APPTYPE CONSOLE}
uses Vcl.ImgList,System.IOUtils,System.SysUtils,System.Classes,System.UITypes,Winapi.Windows,Vcl.Forms,Vcl.Graphics,
  Vcl.Imaging.pngimage,frmSimBriefFrameU,LocalizationU,frmChartsConfigureU,frmMainU;
procedure Check(B:Boolean;const M:string);begin if not B then raise Exception.Create(M);end;
procedure CheckDialogIcons(Images:TCustomImageList);
const Names:array[0..5]of string=('go-top.png','go-up.png','go-down.png','go-bottom.png','go-previous.png','go-next.png');
var Actual,Expected:TBitmap;Source:TPngImage;I,X,Y:Integer;A,E:TColor;
begin
 Actual:=TBitmap.Create;Expected:=TBitmap.Create;Source:=TPngImage.Create;
 try
  Actual.SetSize(22,22);Expected.SetSize(22,22);
  for I:=0 to 5 do begin
   Source.LoadFromFile(ExtractFilePath(ParamStr(0))+'..\Icons\22x22\'+Names[I]);
   Actual.Canvas.Brush.Color:=RGB(123,151,179);Actual.Canvas.FillRect(Rect(0,0,22,22));
   Expected.Canvas.Brush.Color:=RGB(123,151,179);Expected.Canvas.FillRect(Rect(0,0,22,22));Expected.Canvas.Draw(0,0,Source);
   Images.Draw(Actual.Canvas,0,0,I);
   for Y:=0 to 21 do for X:=0 to 21 do begin
    A:=ColorToRGB(Actual.Canvas.Pixels[X,Y]);E:=ColorToRGB(Expected.Canvas.Pixels[X,Y]);
    Check((Abs(GetRValue(A)-GetRValue(E))<=3) and (Abs(GetGValue(A)-GetGValue(E))<=3) and (Abs(GetBValue(A)-GetBValue(E))<=3),'Dialog PNG alpha '+IntToStr(I));
   end;
  end;
 finally Source.Free;Expected.Free;Actual.Free;end;
end;
var D:TfrmChartsConfigure;Available,Selected,ResultList:TStringList;F:TfrmMain;
 S:TfraSimBrief;Names:TStringList;
 Ratio:Double; I:Integer;B,Expected:TBitmap;PNG:TPngImage;Background:TColor;Source:TPngImage;X,Y:Integer;FileName:string;ActualColor,ExpectedColor:TColor;
begin
 Application.Initialize;SetLanguage('pl-PL');
 Available:=TStringList.Create;Selected:=TStringList.Create;ResultList:=TStringList.Create;
 D:=TfrmChartsConfigure.Create(nil);
 try
  Available.Add('ALT');Available.Add('IAS');Available.Add('VS');
  Selected.Add('ALT');Selected.Add('other_aircraft_field');Selected.Add('VS');
  Check((D.ImageList.Count=6) and (D.ActionList.ActionCount=8),'Owned icons and actions');CheckDialogIcons(D.ImageList);
  D.Configure(Available,Selected);
  Check(D.ParameterList.Count=3,'All parameters loaded');Check(D.ChartOrderList.Count=2,'Only available selected charts shown');
  D.eSearch.Text:='ias';Check(D.ParameterList.Count=1,'Case-insensitive filter');
  D.ParameterList.ItemIndex:=0;D.ParameterList.Checked[0]:=True;D.ParameterCheck(D);
  D.eSearch.Text:='ALT';D.ParameterList.ItemIndex:=0;D.ParameterList.Checked[0]:=False;D.ParameterCheck(D);
  D.eSearch.Clear;Check(D.ParameterList.Checked[1] and D.ParameterList.Checked[2] and not D.ParameterList.Checked[0],'Checks survive filtering');
  D.ChartOrderList.ItemIndex:=1;D.aMoveUp.Execute;
  Check(D.ChartOrderList.Items[0]='IAS','Reorder');
  D.aHide.Execute;Check(D.ChartOrderList.Count=1,'Hide selected chart');
  Check(not D.ParameterList.Checked[1],'Hide unchecks parameter');
  Check((Selected.Count=3) and (Selected[0]='ALT'),'Caller data unchanged until acceptance');
  D.CopySelectionTo(ResultList);
  Check((ResultList.Count=2) and (ResultList[0]='other_aircraft_field') and (ResultList[1]='VS'),'Unseen aircraft preferences preserved');
  D.ListPanel.Width:=300;D.Splitter1.OnMoved(D.Splitter1);
  Ratio:=D.ListPanel.Width/(D.MainPanel.ClientWidth-D.Splitter1.Width-D.GraphButtonPanel.Width);
  D.Width:=1200;D.FormResize(D);
  Check(Abs(D.ListPanel.Width-Ratio*(D.MainPanel.ClientWidth-D.Splitter1.Width-D.GraphButtonPanel.Width))<=1,'User split ratio on grow');
  D.Width:=850;D.FormResize(D);
  Check(Abs(D.ListPanel.Width-Ratio*(D.MainPanel.ClientWidth-D.Splitter1.Width-D.GraphButtonPanel.Width))<=1,'User split ratio on shrink');
  Check((D.btnMoveUp.Glyph.PixelFormat=pf24bit) and (D.btnMoveUp.NumGlyphs=1),'SpeedButton compatible colour-key glyph');
  D.Width:=1000;D.ButtonsResize(D);
  Check(Abs((D.btnOk.Left+D.btnCancel.Left+D.btnCancel.Width)-D.ButtonPanel.ClientWidth)<=1,'Buttons centered on resize');
  D.Configure(Available,Selected);D.ChartOrderList.ItemIndex:=0;D.OrderClick(D);
  Check(not D.btnMoveUp.Enabled and D.btnMoveDown.Enabled,'Reorder boundaries');
  SetLanguage('en-US');Check(D.Caption='Chart settings','Localized new form');
  Check(D.btnCancel.Caption='&Cancel','Localized cancel');
  D.aCancel.Execute;Check(D.ModalResult=mrCancel,'Cancel action');D.aAccept.Execute;Check(D.ModalResult=mrOk,'Accept action');
 finally D.Free;ResultList.Free;Selected.Free;Available.Free;end;
 F:=TfrmMain.Create(nil);B:=TBitmap.Create;Expected:=TBitmap.Create;Expected.SetSize(22,22);PNG:=TPngImage.Create;
 try
  F.Timer.Enabled:=False;F.aTiles.Checked:=False;F.aTilesExecute(F.aTiles);
  Check(F.ImageList.Count=35,'Image indices preserved');Check(not F.ImageList.Masked,'True-alpha image list');
  B.PixelFormat:=pf32bit;B.SetSize(22,22);Background:=RGB(123,151,179);
  Source:=TPngImage.Create;
  try
   for I:=0 to F.ImageList.Count-1 do begin
    case I of
     0:FileName:='application-exit.png';1:FileName:='applications-internet.png';
     2:FileName:='applications-system.png';3:FileName:='dconf-editor.png';
     4:FileName:='document-open.png';5:FileName:='help-about.png';
     6:FileName:='media-playback-stop.png';7:FileName:='media-record.png';
     8:FileName:='preferences-system.png';9:FileName:='system-run.png';
     10:FileName:='view-refresh.png';11:FileName:='view-sort-ascending.png';
     12:FileName:='view-sort-descending.png';13:FileName:='zoom-fit-best.png';
     14:FileName:='zoom-in.png';15:FileName:='zoom-original.png';16:FileName:='zoom-out.png';
     17:FileName:='document-save.png';18:FileName:='document-send.png';
     19:FileName:='document-properties.png';20:FileName:='preferences-desktop-locale.png';
     25:FileName:='edit-delete.png';26:FileName:='image-x-generic.png';27:FileName:='emblem-shared.png';
     28:FileName:='folder-new.png';29:FileName:='folder.png';30:FileName:='weather-few-clouds.png';
     31:FileName:='insert-text.png';32:FileName:='view-restore.png';33:FileName:='view-fullscreen.png';34:FileName:='analysis-contact.png';else FileName:='';
    end;
    if FileName<>'' then begin
     Source.LoadFromFile(ExtractFilePath(ParamStr(0))+'..\Icons\22x22\'+FileName);
     Expected.Canvas.Brush.Color:=Background;Expected.Canvas.FillRect(Rect(0,0,22,22));Expected.Canvas.Draw(0,0,Source);
    end;
    B.Canvas.Brush.Color:=Background;B.Canvas.FillRect(Rect(0,0,22,22));F.ImageList.Draw(B.Canvas,0,0,I);
    if FileName='' then Check(ColorToRGB(B.Canvas.Pixels[0,0])=Background,'Transparent flag margin')
    else for Y:=0 to 21 do for X:=0 to 21 do begin
     ActualColor:=ColorToRGB(B.Canvas.Pixels[X,Y]);ExpectedColor:=ColorToRGB(Expected.Canvas.Pixels[X,Y]);
     Check((Abs(GetRValue(ActualColor)-GetRValue(ExpectedColor))<=3) and
       (Abs(GetGValue(ActualColor)-GetGValue(ExpectedColor))<=3) and
       (Abs(GetBValue(ActualColor)-GetBValue(ExpectedColor))<=3),'PNG alpha rendering '+IntToStr(I)+' pixel '+IntToStr(X)+','+IntToStr(Y)+' actual='+IntToHex(ActualColor,6)+' expected='+IntToHex(ExpectedColor,6));
    end;
   end;
  finally Source.Free;end;
  B.Canvas.Brush.Color:=Background;B.Canvas.FillRect(Rect(0,0,22,22));F.ImageList.Draw(B.Canvas,0,0,21);
  Expected.LoadFromFile(ExtractFilePath(ParamStr(0))+'..\Icons\de.bmp');
  for Y:=0 to Expected.Height-1 do for X:=0 to Expected.Width-1 do
   Check(ColorToRGB(B.Canvas.Pixels[X+3,Y+5])=ColorToRGB(Expected.Canvas.Pixels[X,Y]),'Opaque flag colors must be preserved');
  S:=F.SimBriefPage.Controls[0] as TfraSimBrief;Names:=TStringList.Create;
  try
   Names.LoadFromFile(ExtractFilePath(ParamStr(0))+'..\tools\simbrief-icons.txt');
   Check((S.ImageList.Count=Names.Count) and not S.ImageList.Masked,'SimBrief alpha list');
   for I:=0 to Names.Count-1 do begin
    PNG.LoadFromFile(ExtractFilePath(ParamStr(0))+'..\Icons\22x22\'+Names[I]);
    Expected.SetSize(22,22);Expected.Canvas.Brush.Color:=Background;Expected.Canvas.FillRect(Rect(0,0,22,22));Expected.Canvas.Draw(0,0,PNG);
    B.Canvas.Brush.Color:=Background;B.Canvas.FillRect(Rect(0,0,22,22));S.ImageList.Draw(B.Canvas,0,0,I);
    for Y:=0 to 21 do for X:=0 to 21 do begin
     ActualColor:=ColorToRGB(B.Canvas.Pixels[X,Y]);ExpectedColor:=ColorToRGB(Expected.Canvas.Pixels[X,Y]);
     Check((Abs(GetRValue(ActualColor)-GetRValue(ExpectedColor))<=3) and
       (Abs(GetGValue(ActualColor)-GetGValue(ExpectedColor))<=3) and
       (Abs(GetBValue(ActualColor)-GetBValue(ExpectedColor))<=3),'SimBrief PNG alpha '+IntToStr(I));
    end;
   end;
  finally Names.Free;end;
  S.aOlder.Checked:=False;S.btnOlder.Click;Check(S.aOlder.Checked,'SimBrief older-plan toggle');S.btnOlder.Click;
  F.aAuto.Checked:=False;F.btnAuto.Click;Check(F.aAuto.Checked,'Auto-record action toggles');
  F.btnAuto.Click;Check(not F.aAuto.Checked,'Auto-record toggles back');
  F.Position:=poDesigned;F.Left:=-4000;F.Top:=0;F.Show;Application.ProcessMessages;
  B.SetSize(F.ClientWidth,F.ClientHeight);F.PaintTo(B.Canvas,0,0);PNG.Assign(B);PNG.SaveToFile(ExtractFilePath(ParamStr(0))+'toolbar-preview.png');
 finally PNG.Free;Expected.Free;B.Free;F.Free;end;
 SetLanguage('pl-PL');
 Writeln('PASS: chart configuration working copy, filtering, check state, order/hide, resize, localization; 47 alpha icons across all three lists and opaque flag stripe; action toggles.');
end.
