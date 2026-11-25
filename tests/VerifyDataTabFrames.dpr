Program VerifyDataTabFrames;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU        In 'TestPathsU.pas', DUnitX.TestFramework,
 NativeTestRunnerU In 'NativeTestRunnerU.pas',
 System.SysUtils, System.Classes, System.Types, Vcl.Forms, Vcl.Controls,
 Vcl.ComCtrls, Vcl.ActnList,
 frmMainU          In '..\src\Forms\frmMainU.pas',
 frmDockViewU      In '..\src\Forms\frmDockViewU.pas',
 LocalizationU     In '..\src\i18n\LocalizationU.pas';

Type

 [TestFixture]
 TDataTabFrameTests = Class
  Private
   Main : TfrmMain;
  Public
   [Setup]    Procedure Setup;
   [TearDown] Procedure TearDown;
   [Test]     Procedure OwnControlsAndDock;
   [Test]     Procedure FrameTranslations;
 End;

Procedure TDataTabFrameTests.Setup;
 Begin
  Main                       := TfrmMain.Create(Nil);
  Main.Timer.Enabled         := False;
  Main.PlaybackTimer.Enabled := False;
 End;

Procedure TDataTabFrameTests.TearDown;
 Begin
  SetLanguage('pl-PL');
  Main.Free;
 End;

Procedure TDataTabFrameTests.OwnControlsAndDock;
 Var
  i      : Integer;
  Count  : Integer;
  View   : TfrmDockView;
  Frame  : TFrame;
  Action : TAction;
  Page   : TTabSheet;
 Begin
  Assert.IsTrue(Main.ChecklistItems.Owner = Main.fChecklistsTab);
  Assert.IsTrue(Main.DataGrid.Owner = Main.fValuesTab);
  Assert.IsTrue(Main.GSXGrid.Owner = Main.fGSXTab);
  Assert.IsTrue(Main.mPlan.Owner = Main.fFlightPlanTab);
  Assert.IsTrue(Main.EventGrid.Owner = Main.fEventsTab);
  Assert.IsTrue(Main.fSHudMemo.Owner = Main.fATCTab);
  Assert.IsTrue(Main.ContactGrid.Owner = Main.fContactsTab);
  Count := 0;
  For i := 0 To Main.ComponentCount - 1 Do
   If Main.Components[i] Is TfrmDockView Then
    Begin
     View := TfrmDockView(Main.Components[i]);
     Page := View.Page;
     Assert.AreEqual(1, Page.ControlCount, 'Exactly one frame per data page');
     Assert.IsTrue(Page.Controls[0] Is TFrame);
     Frame := TFrame(Page.Controls[0]);
     Assert.IsTrue(Frame.Align = alClient);
     Action := Frame.FindComponent('aWindow') As TAction;
     Assert.IsNotNull(Action);
     Assert.AreEqual(0, Action.ImageIndex);
     Assert.IsTrue(Action.Execute, 'Frame detach action is connected');
     Assert.IsTrue(View.HostDockSite = Nil);
     Assert.AreEqual(1, Action.ImageIndex, 'Detached icon');
     View.ClientWidth  := 720;
     View.ClientHeight := 480;
     View.FitClient(View);
     Assert.AreEqual(Page.ClientWidth, Frame.Width);
     Assert.AreEqual(Page.ClientHeight, Frame.Height);
     View.Close;
     Assert.IsTrue(View.HostDockSite = Main.DataTabs, 'Closing returns to original tab host');
     Assert.AreEqual(0, Action.ImageIndex, 'Docked icon');
     Assert.IsTrue(Frame.Parent = Page, 'Frame and control lifetime preserved');
     Inc(Count);
    End;
  Assert.AreEqual(7, Count, 'Seven data frames plus existing SimBrief and FMC frames');
 End;

Procedure TDataTabFrameTests.FrameTranslations;
 Var
  PolishHint : String;
 Begin
  SetLanguage('pl-PL');
  PolishHint := Main.eValueSearch.TextHint;
  SetLanguage('en-US');
  Assert.AreNotEqual(PolishHint, Main.eValueSearch.TextHint, 'Search hint is translated by its frame');
  Assert.AreEqual('Checklists', Main.ChecklistPage.Caption);
  Assert.IsTrue(Pos('No ', Main.ChecklistEmpty.Caption) = 1, 'Empty-state translation follows moved owner');
  SetLanguage('he-IL');
  SetLanguage('pl-PL');
  Assert.AreEqual(PolishHint, Main.eValueSearch.TextHint);
  Assert.IsTrue(Main.fValuesTab.BiDiMode = bdLeftToRight, 'Frame returns from RTL to LTR');
 End;

Begin
 RunNativeTests(TDataTabFrameTests);
End.
