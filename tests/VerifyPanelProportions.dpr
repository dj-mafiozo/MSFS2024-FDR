Program VerifyPanelProportions;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU In 'TestPathsU.pas', DUnitX.TestFramework, NativeTestRunnerU In 'NativeTestRunnerU.pas', System.SysUtils, System.Math, Vcl.Forms, Vcl.Controls, Vcl.ExtCtrls,
 PanelProportionsU In '..\src\Visualization\PanelProportionsU.pas', frmViewWindowU In '..\src\Forms\frmViewWindowU.pas';

Procedure Check(b : Boolean; Const s : String);
 Begin
  If Not b Then
   Raise Exception.Create(s);
 End;

Var
 Root      : TForm;
 Left      : TPanel;
 Right     : TPanel;
 Center    : TPanel;
 Primary   : TPanel;
 Secondary : TPanel;
 Ratios    : TPanelProportions;
 i         : Integer;
 PF        : TFrame;
 EF        : TFrame;
 PFD       : TfrmViewWindow;
 Engine    : TfrmViewWindow;
 r         : Double;

Type

 [TestFixture]
 TVerifyPanelProportionsTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyPanelProportionsTests.Regression;
 Begin
  Application.Initialize;
  Root   := TForm.Create(Nil);
  Ratios := TPanelProportions.Create;
  Try
   Root.ClientWidth  := 1000;
   Root.ClientHeight := 700;
   Left              := TPanel.Create(Root);
   Left.Parent       := Root;
   Left.Align        := alLeft;
   Left.Width        := 200;
   Right             := TPanel.Create(Root);
   Right.Parent      := Root;
   Right.Align       := alRight;
   Right.Width       := 200;
   Center            := TPanel.Create(Root);
   Center.Parent     := Root;
   Center.Align      := alClient;
   Primary           := TPanel.Create(Root);
   Primary.Parent    := Center;
   Primary.Align     := alLeft;
   Primary.Width     := 240;
   Secondary         := TPanel.Create(Root);
   Secondary.Parent  := Center;
   Secondary.Align   := alClient;
   Ratios.Add(Left, True, 100, 200);
   Ratios.Add(Right, True, 100, 200);
   Ratios.Add(Primary, True, 100, 100);
   Ratios.Capture;
   For i := 1 To 20 Do
    Begin
     Root.ClientWidth := 1500;
     Ratios.Apply;
     Check((Abs(Left.Width - 300) <= 1) And (Abs(Right.Width - 300) <= 1), 'Side panels preserve ratios');
     Check(Abs(Primary.Width / Center.ClientWidth - 0.4) < 0.01, 'Nested instrument ratio follows parent');
     Root.ClientWidth := 1000;
     Ratios.Apply;
     Check(Abs(Left.Width - 200) <= 1, 'Repeated resizing has no cumulative rounding drift');
    End;
   Left.Width := 300;
   Ratios.CaptureGroup(Root, True);
   Ratios.Apply;
   Root.ClientWidth := 1500;
   Ratios.Apply;
   Check(Abs(Left.Width - 450) <= 1, 'Splitter establishes new ratio');
   Check(Abs(Primary.Width / Center.ClientWidth - 0.4) < 0.01, 'Outer splitter preserves nested ratio');
   Left.Visible     := False;
   Root.ClientWidth := 1800;
   Ratios.Apply;
   Check(Left.Width = 450, 'Hidden panel untouched');
   Root.ClientWidth := 400;
   Ratios.Apply;
   Check(Center.ClientWidth >= 190, 'Minimum center space protected');
   PF        := TFrame.Create(Root);
   PF.Name   := 'PrimaryFrame';
   PF.Parent := Primary;
   EF        := TFrame.Create(Root);
   EF.Name   := 'EngineFrame';
   EF.Parent := Secondary;
   PFD       := TfrmViewWindow.Create(Root);
   Engine    := TfrmViewWindow.Create(Root);
   Try
    PFD.Name    := 'FloatingPFD';
    Engine.Name := 'FloatingEICAS';
    PFD.Attach(PF, Primary, 'PFD', Nil);
    Engine.Attach(EF, Secondary, 'EICAS', Nil);
    PFD.ClientWidth  := 1000;
    PFD.ClientHeight := 700;
    Engine.ManualDock(PFD, Nil, alRight);
    Check((Engine.HostDockSite = PFD) And (PF.Parent = PFD) And (EF.Parent = Engine), 'EICAS docks into floating PFD without moving frame owners');
    Check((PF.Width > 50) And (Engine.Width > 50) And (PF.Left + PF.Width <= Engine.Left + 4), 'PFD and EICAS have separate visible areas');
    r                := Engine.Width / PFD.ClientWidth;
    PFD.ClientWidth  := 1400;
    PFD.ClientHeight := 900;
    Check(Abs(Engine.Width / PFD.ClientWidth - r) < 0.01, 'Floating dock split scales proportionally');
    For i := 1 To 10 Do
     Begin
      PFD.ClientWidth  := 1000;
      PFD.ClientHeight := 700;
      PFD.ClientWidth  := 1400;
      PFD.ClientHeight := 900;
     End;
    Check(Abs(Engine.Width / PFD.ClientWidth - r) < 0.02, 'Repeated floating resize preserves split');
    Engine.ManualDock(PFD, Nil, alBottom);
    r                := Engine.Height / PFD.ClientHeight;
    PFD.ClientWidth  := 1200;
    PFD.ClientHeight := 1100;
    Check(Abs(Engine.Height / PFD.ClientHeight - r) < 0.02, 'Vertical PFD/ECAM split scales proportionally');
    PFD.Close;
    Application.ProcessMessages;
    Check((Engine.HostDockSite = Nil) And (EF.Parent = Engine), 'Closing PFD keeps EICAS alive and floating');
    PFD := Nil;
    Engine.Close;
    Application.ProcessMessages;
    Engine := Nil;
    Check((PF.Parent = Primary) And (EF.Parent = Secondary), 'Both frames return safely to main hosts');
   Finally
    Engine.Free;
    PFD.Free;
   End;
  Finally
   Ratios.Free;
   Root.Free;
  End;
  System.Writeln('PASS: proportional nested resize, manual split, no rounding drift, hidden/minimum panels and floating PFD/EICAS docking/resize/close. Synthetic VCL only.');

 End;

Begin
 RunNativeTests(TVerifyPanelProportionsTests);
End.
