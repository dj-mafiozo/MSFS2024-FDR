Program VerifyNativeDocking;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU, Winapi.Windows, DockPreviewU, System.SysUtils, System.Classes, System.Types, System.IniFiles,
 Vcl.StdCtrls, Vcl.Forms, Vcl.Controls, Vcl.ComCtrls, Vcl.ExtCtrls, frmDockViewU;

Procedure Check(b : Boolean; Const s : String);
 Begin
  If Not b Then
   Raise Exception.Create(s);
 End;

Type
 TPreviewProbe = Class(TWindowDragDockObject)
  Public
   Procedure Draw;
   Procedure Erase;
 End;

Procedure TPreviewProbe.Draw;
 Begin
  DrawDragDockImage;
 End;

Procedure TPreviewProbe.Erase;
 Begin
  EraseDragDockImage;
 End;

Procedure PreviewLifecycle(Control : TControl);
 Var
  d      : TPreviewProbe;
  h      : HWND;
  r      : TRect;
  Region : HRGN;
  i      : Integer;
 Begin
  h := 0;
  d := TPreviewProbe.Create(Control);
  Try
   For i := 0 To 49 Do
    Begin
     d.DockRect := Rect( -100 + i * 5, 20 + i * 3, 200 + i * 5, 220 + i * 3);
     d.Draw;
     If i = 0 Then
      h := d.PreviewHandle;
     Check(d.PreviewHandle = h, 'Moving preview reuses one HWND');
     GetWindowRect(h, r);
     Check(EqualRect(r, d.DockRect), 'Preview follows screen coordinates including negative monitor coordinates');
    End;
   Check(IsWindowVisible(h), 'Preview visible during drag');
   Region := CreateRectRgn(0, 0, 0, 0);
   Try
    GetWindowRgn(h, Region);
    Check(PtInRegion(Region, 1, 1) And Not PtInRegion(Region, 100, 100), 'Preview region contains only border');
   Finally
    DeleteObject(Region);
   End;
   d.Erase;
   Check(Not IsWindowVisible(h), 'Drop or cancel hides preview');
   d.Draw;
   Check(IsWindowVisible(h), 'Preview can be shown after erase');
  Finally
   d.Free;
  End;
  Check(Not IsWindow(h), 'Drag object destruction destroys preview HWND');
 End;

Var
 Main  : TForm;
 Home  : TPageControl;
 Side  : TPanel;
 Page  : TTabSheet;
 Child : TMemo;
 View  : TfrmDockView;
 Ini   : TMemIniFile;

Type

 [TestFixture]
 TVerifyNativeDockingTests = Class
  Public
   [Test]
   Procedure Regression;
 End;

Procedure TVerifyNativeDockingTests.Regression;
 Begin
  Application.Initialize;
  Main := TForm.Create(Nil);
  Ini  := TMemIniFile.Create('');
  Try
   PreviewLifecycle(Main);
   Main.Name := 'DockTest';
   Main.SetBounds(10, 10, 900, 700);
   Home                := TPageControl.Create(Main);
   Home.Name           := 'Home';
   Home.Parent         := Main;
   Home.Align          := alClient;
   Home.DockSite       := True;
   Side                := TPanel.Create(Main);
   Side.Name           := 'Side';
   Side.Parent         := Main;
   Side.Align          := alLeft;
   Side.Width          := 250;
   Side.DockSite       := True;
   Side.UseDockManager := True;
   Page                := TTabSheet.Create(Main);
   Page.Name           := 'ATCTest';
   Page.Caption        := 'ATC';
   Page.PageControl    := Home;
   Child               := TMemo.Create(Main);
   Child.Parent        := Page;
   Child.Text          := 'Recorded message';
   View                := TfrmDockView.Create(Main);
   Try
    Check(Assigned(View.OnStartDock), 'DFM wires window preview for tab dragging');
    View.Attach(Page, Home);
    Check((View.HostDockSite = Home) And (Child.Parent = Page), 'Native initial tab docking preserves controls');
    Main.Show;
    Main.ClientWidth  := 1200;
    Main.ClientHeight := 900;
    Application.ProcessMessages;
    Check((View.Width = View.Parent.ClientWidth) And (View.Height = View.Parent.ClientHeight), 'Docked view fills tab after initial parent resize');
    Check((Page.Width = View.ClientWidth) And (Page.Height = View.ClientHeight), 'DFM page fills docked form without detach/redock');
    View.Toggle;
    Check(View.HostDockSite = Nil, 'Tab floats');
    Check(Child.Text = 'Recorded message', 'Content survives undock');
    View.Save(Ini);
    View.ManualDock(Side, Nil, alLeft);
    Check(View.HostDockSite = Side, 'Native side docking');
    View.Restore(Ini);
    Check(View.HostDockSite = Nil, 'Floating state restored');
    View.ManualDock(Side, Nil, alLeft);
    View.Save(Ini);
    SaveDockTree(Side, Ini);
    RestoreDockTree(Side, Ini);
    Check(View.HostDockSite = Side, 'Native DockManager tree round trip');
    View.Toggle;
    View.Restore(Ini);
    Check(View.HostDockSite = Side, 'Dock host restored');
    View.Close;
    Check(View.HostDockSite = Home, 'Close returns tab without destroying content');
    View.ReleasePage;
    Check((Page.PageControl = Home) And (Child.Text = 'Recorded message'), 'Shutdown returns original DFM page');
   Finally
    View.Free;
   End;
  Finally
   Ini.Free;
   Main.Free;
  End;
  System.Writeln('PASS: native tab docking, float, side docking, close-return, host persistence and control lifetime. Synthetic only.');

 End;

Begin
 RunNativeTests(TVerifyNativeDockingTests);

End.
