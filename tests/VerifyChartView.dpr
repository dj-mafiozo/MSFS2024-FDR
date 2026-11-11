Program VerifyChartView;

{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU In 'TestPathsU.pas', DUnitX.TestFramework, NativeTestRunnerU In 'NativeTestRunnerU.pas',
 System.SysUtils, System.Classes, System.Types, System.Generics.Collections, Vcl.Forms, Vcl.Controls, FlightChartsU In '..\src\Visualization\FlightChartsU.pas', FlightDatabaseU In '..\src\Data\FlightDatabaseU.pas';

Type
 TChartProbe = Class(TFlightCharts)

  Procedure Drag(a, b : Integer; Zoom : Boolean = True);

  Procedure Hover(x : Integer);

  Procedure CtrlWheel;

 End;

 TObserver = Class
  Index : Integer;
  Procedure Cursor(Sender : TObject; i : Integer);
 End;

Procedure TObserver.Cursor(Sender : TObject; i : Integer);
 Begin
  Index := i;
 End;

Procedure TChartProbe.Drag(a, b : Integer; Zoom : Boolean);
 Var
  s : TShiftState;
 Begin
  s := [];
  If Zoom Then
   Include(s, ssShift);
  MouseDown(mbLeft, s, a, 40);
  Include(s, ssLeft);
  MouseMove(s, b, 40);
  MouseUp(mbLeft, s, b, 40);
 End;

Procedure TChartProbe.Hover(x : Integer);
 Begin
  MouseMove([], x, 40);
 End;

Procedure TChartProbe.CtrlWheel;
 Begin
  DoMouseWheel([ssCtrl], 120, Point(0, 0));
 End;

Procedure Require(b : Boolean; Const s : String);
 Begin
  If Not b Then
   Raise Exception.Create(s);
 End;

Var
 Host : TForm;
 c    : TChartProbe;
 p    : TTripPlot;
 v    : TPlotPoint;
 o    : TObserver;
 i    : Integer;
 Span : Double;

Type

 [TestFixture]
 TVerifyChartViewTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyChartViewTests.Regression;
 Begin

  Application.Initialize;
  Host := TForm.CreateNew(Nil);
  c    := TChartProbe.Create(Nil);
  p    := TTripPlot.Create;
  o    := TObserver.Create;

  Try

   p.Labels.Add('test');
   For i := 0 To 10 Do
    Begin
     v         := Default(TPlotPoint);
     v.Seconds := 100 + i * 10;
     SetLength(v.Values, 1);
     v.Values[0] := i;
     p.Points.Add(v);
    End;

   c.Parent := Host;
   c.Width  := 600;
   c.SetData(p);
   c.OnCursor := o.Cursor;

   Require((c.ViewStart = 100) And (c.ViewEnd = 200), 'Full view with nonzero time origin');

   c.SetView(140, 160);
   c.Hover(60);
   Require(o.Index = 4, 'Cursor respects zoomed origin');

   c.SetView(120, 160);
   c.Drag(300, 400, False);
   Require((c.ViewStart < 120) And (Abs(c.ViewEnd - c.ViewStart - 40) < 0.001), 'Plain drag pans without zoom');

   c.SetView(120, 160);
   c.Drag(500, 100);

   Require((c.ViewStart >= 120) And (c.ViewEnd <= 160) And (c.ViewEnd > c.ViewStart), 'Reverse mouse selection');

   Span := c.ViewEnd - c.ViewStart;
   c.Pan(1);
   Require(Abs(c.ViewEnd - 200) < 0.001, 'Pan to end');

   c.CtrlWheel;
   Require(c.ViewEnd - c.ViewStart < Span, 'Ctrl wheel zoom');

   c.ResetView;
   Require((c.ViewStart = 100) And (c.ViewEnd = 200), 'Reset full view');

  Finally
   c.Free;
   Host.Free;
   p.Free;
   o.Free;
  End;

  System.Writeln('PASS: chart viewport, nonzero origin, cursor mapping, reverse drag zoom, panning, Ctrl+wheel and reset.');

 End;

Begin
 RunNativeTests(TVerifyChartViewTests);
End.
