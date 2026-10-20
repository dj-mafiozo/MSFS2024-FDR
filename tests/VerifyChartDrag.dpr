program VerifyChartDrag;
{$APPTYPE CONSOLE}
uses System.SysUtils,System.Classes,System.Types,Winapi.Windows,Winapi.Messages,
 Vcl.Forms,Vcl.XPMan,Vcl.Controls,Vcl.Graphics,Vcl.Imaging.pngimage,frmChartsConfigureU,LocalizationU;
var D:TfrmChartsConfigure;A,S,R:TStringList;Keys,Original:TKeyboardState;Obj:TDragObject;Accepted:Boolean;B:TBitmap;P:TPngImage;
procedure Check(Value:Boolean;const Message:string);begin if not Value then raise Exception.Create(Message);end;
procedure Ctrl(Value:Boolean);
begin GetKeyboardState(Keys);Keys[VK_CONTROL]:=0;if Value then Keys[VK_CONTROL]:=$80;SetKeyboardState(Keys);end;
procedure Start(Source:TObject;Index:Integer);
begin
 D.ListEndDrag(Source,nil,0,0);
 if Source=D.ParameterList then D.ParameterList.ItemIndex:=Index else D.ChartOrderList.ItemIndex:=Index;
 Obj:=nil;D.ListStartDrag(Source,Obj);
end;
procedure Drop(Target,Source:TObject;Y:Integer);
begin
 Accepted:=False;D.ListDragOver(Target,Source,30,Y,dsDragMove,Accepted);Check(Accepted,'Expected accepted drop');D.ListDragDrop(Target,Source,30,Y);
end;
procedure Saved(const Expected:string);
begin D.CopySelectionTo(R);Check(R.CommaText=Expected,'Expected '+Expected+', got '+R.CommaText);end;
begin
 GetKeyboardState(Original);Application.Initialize;SetLanguage('pl-PL');
 D:=TfrmChartsConfigure.Create(nil);A:=TStringList.Create;S:=TStringList.Create;R:=TStringList.Create;
 try
  A.CommaText:='ALT,IAS,VS,foo_bar,fooBar';S.CommaText:='ALT,unknown_aircraft,VS';D.Configure(A,S);
  D.Position:=poDesigned;D.Left:=-4000;D.Show;Application.ProcessMessages;
  Ctrl(False);
  Start(D.ParameterList,1);Drop(D.ChartOrderList,D.ParameterList,0);Saved('IAS,ALT,unknown_aircraft,VS');
  Check(D.ParameterList.Checked[1],'Added item checked');
  Start(D.ParameterList,1);Drop(D.ChartOrderList,D.ParameterList,D.ChartOrderList.ClientHeight-2);Saved('ALT,unknown_aircraft,VS,IAS');
  Check(D.ChartOrderList.Count=3,'Existing item moved without duplicate');
  Start(D.ChartOrderList,2);Accepted:=True;D.ListDragOver(D.ChartOrderList,D.ChartOrderList,30,0,dsDragMove,Accepted);
  Check(not Accepted,'Same-list reorder requires Ctrl');D.ListDragDrop(D.ChartOrderList,D.ChartOrderList,30,0);Saved('ALT,unknown_aircraft,VS,IAS');
  Ctrl(True);Start(D.ChartOrderList,2);Drop(D.ChartOrderList,D.ChartOrderList,0);Saved('IAS,ALT,unknown_aircraft,VS');
  Start(D.ChartOrderList,0);Drop(D.ChartOrderList,D.ChartOrderList,D.ChartOrderList.ClientHeight-2);Saved('ALT,unknown_aircraft,VS,IAS');
  Ctrl(False);D.eSearch.Text:='alt';Start(D.ChartOrderList,2);Drop(D.ParameterList,D.ChartOrderList,5);Saved('ALT,unknown_aircraft,VS');
  D.eSearch.Clear;Check(not D.ParameterList.Checked[1],'Removal updates check even while filtered');
  Start(D.ParameterList,3);Drop(D.ChartOrderList,D.ParameterList,0);
  Start(D.ParameterList,4);Drop(D.ChartOrderList,D.ParameterList,0);Saved('fooBar,foo_bar,ALT,unknown_aircraft,VS');
  Check(D.ChartOrderList.Items[0]=D.ChartOrderList.Items[1],'Duplicate display captions fixture');
  Ctrl(True);Start(D.ChartOrderList,1);Drop(D.ChartOrderList,D.ChartOrderList,0);Saved('foo_bar,fooBar,ALT,unknown_aircraft,VS');
  Ctrl(False);Start(D.ChartOrderList,0);D.ListEndDrag(D.ChartOrderList,nil,0,0);Saved('foo_bar,fooBar,ALT,unknown_aircraft,VS');
  Check(not D.DragScrollTimer.Enabled,'Cancelled drag stops scroll timer');
  Accepted:=True;D.ListDragOver(D.ChartOrderList,D,30,0,dsDragMove,Accepted);Check(not Accepted,'Foreign source rejected');
  S.Clear;D.Configure(A,S);Start(D.ParameterList,2);Drop(D.ChartOrderList,D.ParameterList,0);Saved('VS');
  Start(D.ChartOrderList,0);Drop(D.ParameterList,D.ChartOrderList,0);Saved('');
  Check(D.ChartOrderList.Count=0,'Removal of last chart');
  D.ParameterList.Perform(WM_LBUTTONDOWN,MK_LBUTTON,MakeLParam(3,5));
  D.ParameterList.Perform(WM_LBUTTONUP,0,MakeLParam(3,5));
  Check(D.ParameterList.Checked[0],'Native checkbox click preserved');
  D.CopySelectionTo(R);Check(R.IndexOf('ALT')>=0,'Native checkbox changes working selection');
  Check(S.Count=0,'Caller data unchanged before OK');D.aCancel.Execute;Check(D.ModalResult=mrCancel,'Cancel preserved');
  S.CommaText:='ALT,IAS,VS';D.Configure(A,S);Ctrl(True);Start(D.ChartOrderList,0);Accepted:=False;
  D.ListDragOver(D.ChartOrderList,D.ChartOrderList,30,D.ChartOrderList.ItemRect(2).Top,dsDragMove,Accepted);
  Check(Accepted and D.DragScrollTimer.Enabled,'Insertion/edge-scroll state');
  B:=D.GetFormImage;P:=TPngImage.Create;try P.Assign(B);P.SaveToFile(ExtractFilePath(ParamStr(0))+'chart-drag-preview.png');finally P.Free;B.Free;end;
  D.ListEndDrag(D.ChartOrderList,nil,0,0);
 finally SetKeyboardState(Original);R.Free;S.Free;A.Free;D.Free;end;
 Writeln('PASS: cross-list add/remove, insertion/end/empty drops, no duplicates, Ctrl-only reorder, raw-ID collisions, filtered removal, cancellation/foreign drops, timer state and native checkbox clicks.');
end.
