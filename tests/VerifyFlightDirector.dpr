Program VerifyFlightDirector;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU, System.SysUtils, System.Math, FlightDatabaseU, FlightDirectorU,
 FlightTelemetryU, TelemetryCatalogU, AirbusDataU;

Procedure Check(b : Boolean; Const m : String);
 Begin
  If Not b Then
   Raise Exception.Create(m);
 End;

Function ARINC(V : Single; SSM : Cardinal = 3) : Double;
 Var
  Bits : Cardinal;
 Begin
  Move(V, Bits, 4);
  Result := UInt64(Bits) + (UInt64(SSM) Shl 32);
 End;

Var
 Plot : TTripPlot;
 p    : TPlotPoint;
 FD   : TFlightDirectorSampler;
 s    : TFlightSample;
 DB   : TFlightDatabase;
 Trip : Integer;
 i    : Integer;

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

Procedure Point(PreferFBW : Boolean = False);
 Begin
  If Plot.Points.Count = 0 Then
   Plot.Points.Add(p)
  Else
   Plot.Points[0] := p;
  FD.SetPoint(Plot, 0, PreferFBW);
 End;

Procedure N(Const Name : String; Value : Double);
 Var
  k : Integer;
 Begin
  For k := 0 To FieldCount - 1 Do
   If SimFields[k].Name = Name Then
    Begin
     s.Numbers[k] := Value;
     Exit;
    End;
  Raise Exception.Create(Name);
 End;

Type

 [TestFixture]
 TVerifyFlightDirectorTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyFlightDirectorTests.Regression;
 Begin
  Try
   Plot := TTripPlot.Create;
   FD   := TFlightDirectorSampler.Create;
   Try
    V('plane_pitch_degrees', 0);
    V('plane_bank_degrees', 0);
    V('autopilot_flight_director_active', 1);
    V('autopilot_flight_director_pitch', DegToRad( -10));
    V('autopilot_flight_director_bank', DegToRad( -20));
    Point;
    Check(FD.State.PitchValid And FD.State.BankValid And (Abs(FD.State.PitchError - 10) < 1E-6) And (Abs(FD.State.BankError - 20) < 1E-6), 'Sim pitch down/bank left signs and radians conversion');
    V('autopilot_flight_director_pitch', 0);
    V('autopilot_flight_director_pitch_ex1', DegToRad(15));
    Point;
    Check(FD.State.PitchValid And (FD.State.PitchError = 0), 'Genuine zero never falls back to EX1');
    V('autopilot_flight_director_pitch', NaN);
    Point;
    Check(Abs(FD.State.PitchError + 15) < 1E-6, 'NULL filtered reference uses raw EX1');
    V('autopilot_flight_director_active', 0);
    Point;
    Check(Not FD.State.PitchValid And Not FD.State.BankValid, 'FD off suppresses commands');
    V('iFlySDK.FD_1_Switch_Status', 1);
    Point;
    Check(FD.State.PitchValid, 'iFly SDK switch supersedes unreliable standard active flag');
    V('FenixLVar.I_FCU_EFIS1_FD', 0);
    Point;
    Check(Not FD.State.PitchValid, 'Fenix captain FD off');
    V('FBWLVar.A32NX_FMGC_1_DISCRETE_WORD_4', ARINC(1 Shl 12));
    V('FBWLVar.A32NX_FCU_LEFT_EIS_DISCRETE_WORD_2', ARINC(0));
    V('FBWLVar.A32NX_FMGC_1_PITCH_FD_COMMAND', ARINC( -5));
    V('FBWLVar.A32NX_FMGC_1_ROLL_FD_COMMAND', ARINC(9));
    Point(True);
    Check(FD.State.Selected And (FD.State.PitchError = 5) And (FD.State.BankError = 9), 'FBW ARINC deviations are not attitude targets');
    V('FBWLVar.A32NX_FMGC_1_PITCH_FD_COMMAND', ARINC(0, 0));
    Point(True);
    Check(Not FD.State.PitchValid And FD.State.BankValid, 'Independent axes and invalid native SSM do not fall back to standard');
    V('FBWLVar.A32NX_FCU_LEFT_EIS_DISCRETE_WORD_2', ARINC(1 Shl 22));
    Point(True);
    Check(Not FD.State.BankValid, 'FBW EIS FD off selection');
    V('FBWLVar.A32NX_FCU_LEFT_EIS_DISCRETE_WORD_2', ARINC(0));
    V('FBWLVar.A32NX_FCU_DISCRETE_WORD_1', ARINC(1 Shl 24));
    Point(True);
    Check(Not FD.State.BankValid, 'TRK/FPA does not display crossbars');
    FD.Clear;
    Check(Not FD.State.BankValid, 'Clear never retains commands');
    Plot.Labels.Clear;
    FD.SetPoint(Plot, 0, False);
    Check(Not FD.State.PitchValid, 'Missing historical labels never become zero');
   Finally
    FD.Free;
    Plot.Free;
   End;
   DB := TFlightDatabase.Create(TestDatabasePath('fd.mfzr'), TestRuntimeFile('sqlite3.dll'));
   s  := TFlightSample.Create;
   Try
    For i := 0 To FieldCount - 1 Do
     If SimFields[i].Name = 'title' Then
      s.Texts[i] := 'iFly 737 MAX 8';
    For i        := 0 To FieldCount - 1 Do
     Begin
      If SimFields[i].Name = 'atc_flight_number' Then
       s.Texts[i] := '1762';
      If SimFields[i].Name = 'atc_id' Then
       s.Texts[i] := 'EI-FYB';
     End;
    N('time_zulu.year', 2026);
    N('time_zulu.month', 10);
    N('time_zulu.day', 25);
    N('number_of_engines', 0);
    Trip := DB.StartTrip(s);
    N('time_zulu.seconds', 43200);
    N('autopilot_flight_director_pitch', 0);
    N('autopilot_flight_director_bank', NaN);
    DB.RecordSample(Trip, s);
    Plot := DB.LoadTrip(Trip);
    Try
     Check((Plot.FlightNumber = '1762') And (Plot.Registration = 'EI-FYB') And (Plot.RecordedStartTime <> ''), 'Flight metadata loaded for MAX panel');
     i := Plot.Labels.IndexOf('autopilot_flight_director_pitch');
     Check(Plot.Points[0].Values[i] = 0, 'SQLite preserves zero');
     i := Plot.Labels.IndexOf('autopilot_flight_director_bank');
     Check(IsNan(Plot.Points[0].Values[i]), 'SQLite NULL remains unavailable');
    Finally
     Plot.Free;
    End;
   Finally
    s.Free;
    DB.Free;
   End;
   System.Writeln('PASS: standard/EX1 FD references, radians/signs, real zero vs missing, source/engagement priority, native ARINC validity and independent axes, SQLite NULL/zero. Synthetic only.');
  Except
   On E : Exception Do
    Begin
     System.Writeln(E.ClassName + ': ' + E.Message);
     Raise Exception.Create('Regression failed; see diagnostic above');
    End;
  End;

 End;

Begin
 RunNativeTests(TVerifyFlightDirectorTests);
End.
