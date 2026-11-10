Program VerifyPFDMinima;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU, System.SysUtils, System.Math, System.Types, FlightDatabaseU, AirbusDataU, PFDMinimaU, Vcl.Graphics;

Procedure Check(b : Boolean; Const Msg : String);
 Begin
  If Not b Then
   Raise Exception.Create(Msg);
 End;

Function ARINC(V : Single; SSM : UInt64 = 3) : Double;
 Var
  Bits : Cardinal;
 Begin
  Move(V, Bits, 4);
  Result := Bits + SSM * 4294967296.0;
 End;

Var
 Plot   : TTripPlot;
 p      : TPlotPoint;
 Data   : TAirbusData;
 m      : TPFDMinimum;
 Bounds : TRect;
 b      : TBitmap;

Procedure V(Const Name : String; Value : Double);
 Var
  k : Integer;
 Begin
  k := Plot.Labels.IndexOf(Name);
  If k < 0 Then
   Begin
    k := Plot.Labels.Add(Name);
    SetLength(p.Values, k + 1);
   End;
  p.Values[k] := Value;
 End;

Procedure Sample;
 Begin
  If Plot.Points.Count = 0 Then
   Plot.Points.Add(p)
  Else
   Plot.Points[0] := p;
  Data.SetPoint(Plot, 0);
  m := ReadFBWMinimum(Data);
 End;

Type

 [TestFixture]
 TVerifyPFDMinimaTests = Class
  Public
   [Test]
   Procedure Regression;
 End;

Procedure TVerifyPFDMinimaTests.Regression;
 Begin
  Try
   Plot := TTripPlot.Create;
   Data := TAirbusData.Create;
   b    := TBitmap.Create;
   Try
    Bounds := Rect(500, 155, 574, 500);
    Sample;
    Check(m.Kind = mkNone, 'Historical missing channels');
    V('FBWLVar.A32NX_FM1_MINIMUM_DESCENT_ALTITUDE', ARINC(1200));
    V('FBWLVar.A32NX_FM1_DECISION_HEIGHT', ARINC(0, 1));
    Sample;
    Check((m.Kind = mkBaro) And (m.Feet = 1200), 'Normal BARO / unavailable RADIO');
    Check(MinimumTapeY(m, 1400, 250, Bounds, 450) = 403, 'BARO marker uses tape geometry');
    Check(MinimumTapeY(m, 3000, 250, Bounds, 450) = -1, 'Off-scale minimum stays hidden');
    V('FBWLVar.A32NX_FM1_DECISION_HEIGHT', ARINC(200));
    Sample;
    Check((m.Kind = mkRadio) And (m.Feet = 200), 'Valid RADIO takes precedence');
    Check(MinimumTapeY(m, 1400, 200, Bounds, 450) = 327, 'RADIO minimum reached at RA, not absolute altitude');
    Check(MinimumTapeY(m, 1400, NaN, Bounds, 450) = -1, 'Invalid RA suppresses relative marker');
    b.SetSize(640, 640);
    b.Canvas.Brush.Color := clBlack;
    b.Canvas.FillRect(Rect(0, 0, 640, 640));
    DrawMinimum(b.Canvas, m, 1400, 200, Bounds, 450);
    Check(ColorToRGB(b.Canvas.Pixels[501, 327]) = ColorToRGB($0000BFFF), 'At minimum marker becomes amber');
    V('FBWLVar.A32NX_FM1_EIS_DISCRETE_WORD_2', ARINC(1 Shl 28));
    Sample;
    Check((m.Kind = mkNoDH) And (MinimumCaption(m) = 'NO DH') And (MinimumTapeY(m, 1400, 200, Bounds, 450) = -1), 'NO DH has no invented marker');
    V('FBWLVar.A32NX_FM1_EIS_DISCRETE_WORD_2', ARINC(0));
    V('FBWLVar.A32NX_FM1_DECISION_HEIGHT', ARINC(0));
    Sample;
    Check((m.Kind = mkRadio) And (m.Feet = 0), 'Real zero DH valid');
    V('FBWLVar.A32NX_FM1_DECISION_HEIGHT', ARINC(0, 0));
    V('FBWLVar.A32NX_FM1_MINIMUM_DESCENT_ALTITUDE', ARINC(0, 1));
    Sample;
    Check(m.Kind = mkNone, 'Failure / NCD words are not zero minima');
    Plot.Labels.Clear;
    Data.SetPoint(Plot, 0);
    m := ReadFBWMinimum(Data);
    Check(m.Kind = mkNone, 'Clear cannot retain prior source');
   Finally
    b.Free;
    Data.Free;
    Plot.Free;
   End;
   System.Writeln('PASS: BARO/RADIO/NO DH, ARINC validity, zero/missing, relative RA vs MSL, approaching/off-scale/amber marker. Synthetic only.');
  Except
   On E : Exception Do
    Begin
     System.Writeln(E.ClassName + ': ' + E.Message);
     Raise Exception.Create('Regression failed; see diagnostic above');
    End;
  End;

 End;

Begin
 RunNativeTests(TVerifyPFDMinimaTests);

End.
