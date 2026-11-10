Program VerifyChartDrag;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU,
 System.SysUtils, System.Classes, System.Types, Winapi.Windows, Winapi.Messages,
 Vcl.Forms, Vcl.XPMan, Vcl.Controls, Vcl.Graphics, Vcl.Imaging.pngimage, frmChartsConfigureU, LocalizationU;

Var
 d        : TfrmChartsConfigure;
 a        : TStringList;
 s        : TStringList;
 r        : TStringList;
 Keys     : TKeyboardState;
 Original : TKeyboardState;
 Obj      : TDragObject;
 Accepted : Boolean;
 b        : TBitmap;
 p        : TPngImage;

Procedure Check(Value : Boolean; Const Message : String);
 Begin
  If Not Value Then
   Raise Exception.Create(Message);
 End;

Procedure Ctrl(Value : Boolean);
 Begin
  GetKeyboardState(Keys);
  Keys[VK_CONTROL] := 0;
  If Value Then
   Keys[VK_CONTROL] := $80;
  SetKeyboardState(Keys);
 End;

Procedure Start(Source : TObject; Index : Integer);
 Begin
  d.ListEndDrag(Source, Nil, 0, 0);
  If Source = d.ParameterList Then
   d.ParameterList.ItemIndex := Index
  Else
   d.ChartOrderList.ItemIndex := Index;
  Obj                         := Nil;
  d.ListStartDrag(Source, Obj);
 End;

Procedure Drop(Target, Source : TObject; y : Integer);
 Begin
  Accepted := False;
  d.ListDragOver(Target, Source, 30, y, dsDragMove, Accepted);
  Check(Accepted, 'Expected accepted drop');
  d.ListDragDrop(Target, Source, 30, y);
 End;

Procedure Saved(Const Expected : String);
 Begin
  d.CopySelectionTo(r);
  Check(r.CommaText = Expected, 'Expected ' + Expected + ', got ' + r.CommaText);
 End;

Type

 [TestFixture]
 TVerifyChartDragTests = Class
  Public
   [Test]
   Procedure Regression;
 End;

Procedure TVerifyChartDragTests.Regression;
 Begin
  GetKeyboardState(Original);
  Application.Initialize;
  SetLanguage('pl-PL');
  d := TfrmChartsConfigure.Create(Nil);
  a := TStringList.Create;
  s := TStringList.Create;
  r := TStringList.Create;
  Try
   a.CommaText := 'ALT,IAS,VS,foo_bar,fooBar';
   s.CommaText := 'ALT,unknown_aircraft,VS';
   d.Configure(a, s);
   d.Position := poDesigned;
   d.Left     := -4000;
   d.Show;
   Application.ProcessMessages;
   Ctrl(False);
   Start(d.ParameterList, 1);
   Drop(d.ChartOrderList, d.ParameterList, 0);
   Saved('IAS,ALT,unknown_aircraft,VS');
   Check(d.ParameterList.Checked[1], 'Added item checked');
   Start(d.ParameterList, 1);
   Drop(d.ChartOrderList, d.ParameterList, d.ChartOrderList.ClientHeight - 2);
   Saved('ALT,unknown_aircraft,VS,IAS');
   Check(d.ChartOrderList.Count = 3, 'Existing item moved without duplicate');
   Start(d.ChartOrderList, 2);
   Accepted := True;
   d.ListDragOver(d.ChartOrderList, d.ChartOrderList, 30, 0, dsDragMove, Accepted);
   Check(Not Accepted, 'Same-list reorder requires Ctrl');
   d.ListDragDrop(d.ChartOrderList, d.ChartOrderList, 30, 0);
   Saved('ALT,unknown_aircraft,VS,IAS');
   Ctrl(True);
   Start(d.ChartOrderList, 2);
   Drop(d.ChartOrderList, d.ChartOrderList, 0);
   Saved('IAS,ALT,unknown_aircraft,VS');
   Start(d.ChartOrderList, 0);
   Drop(d.ChartOrderList, d.ChartOrderList, d.ChartOrderList.ClientHeight - 2);
   Saved('ALT,unknown_aircraft,VS,IAS');
   Ctrl(False);
   d.eSearch.Text := 'alt';
   Start(d.ChartOrderList, 2);
   Drop(d.ParameterList, d.ChartOrderList, 5);
   Saved('ALT,unknown_aircraft,VS');
   d.eSearch.Clear;
   Check(Not d.ParameterList.Checked[1], 'Removal updates check even while filtered');
   Start(d.ParameterList, 3);
   Drop(d.ChartOrderList, d.ParameterList, 0);
   Start(d.ParameterList, 4);
   Drop(d.ChartOrderList, d.ParameterList, 0);
   Saved('fooBar,foo_bar,ALT,unknown_aircraft,VS');
   Check(d.ChartOrderList.Items[0] = d.ChartOrderList.Items[1], 'Duplicate display captions fixture');
   Ctrl(True);
   Start(d.ChartOrderList, 1);
   Drop(d.ChartOrderList, d.ChartOrderList, 0);
   Saved('foo_bar,fooBar,ALT,unknown_aircraft,VS');
   Ctrl(False);
   Start(d.ChartOrderList, 0);
   d.ListEndDrag(d.ChartOrderList, Nil, 0, 0);
   Saved('foo_bar,fooBar,ALT,unknown_aircraft,VS');
   Check(Not d.DragScrollTimer.Enabled, 'Cancelled drag stops scroll timer');
   Accepted := True;
   d.ListDragOver(d.ChartOrderList, d, 30, 0, dsDragMove, Accepted);
   Check(Not Accepted, 'Foreign source rejected');
   s.Clear;
   d.Configure(a, s);
   Start(d.ParameterList, 2);
   Drop(d.ChartOrderList, d.ParameterList, 0);
   Saved('VS');
   Start(d.ChartOrderList, 0);
   Drop(d.ParameterList, d.ChartOrderList, 0);
   Saved('');
   Check(d.ChartOrderList.Count = 0, 'Removal of last chart');
   d.ParameterList.Perform(WM_LBUTTONDOWN, MK_LBUTTON, MakeLParam(3, 5));
   d.ParameterList.Perform(WM_LBUTTONUP, 0, MakeLParam(3, 5));
   Check(d.ParameterList.Checked[0], 'Native checkbox click preserved');
   d.CopySelectionTo(r);
   Check(r.IndexOf('ALT') >= 0, 'Native checkbox changes working selection');
   Check(s.Count = 0, 'Caller data unchanged before OK');
   d.aCancel.Execute;
   Check(d.ModalResult = mrCancel, 'Cancel preserved');
   s.CommaText := 'ALT,IAS,VS';
   d.Configure(a, s);
   Ctrl(True);
   Start(d.ChartOrderList, 0);
   Accepted := False;
   d.ListDragOver(d.ChartOrderList, d.ChartOrderList, 30, d.ChartOrderList.ItemRect(2).Top, dsDragMove, Accepted);
   Check(Accepted And d.DragScrollTimer.Enabled, 'Insertion/edge-scroll state');
   b := d.GetFormImage;
   p := TPngImage.Create;
   Try
    p.Assign(b);
    p.SaveToFile(ExtractFilePath(ParamStr(0)) + 'chart-drag-preview.png');
   Finally
    p.Free;
    b.Free;
   End;
   d.ListEndDrag(d.ChartOrderList, Nil, 0, 0);
  Finally
   SetKeyboardState(Original);
   r.Free;
   s.Free;
   a.Free;
   d.Free;
  End;
  System.Writeln('PASS: cross-list add/remove, insertion/end/empty drops, no duplicates, Ctrl-only reorder, raw-ID collisions, filtered removal, cancellation/foreign drops, timer state and native checkbox clicks.');

 End;

Begin
 RunNativeTests(TVerifyChartDragTests);

End.
