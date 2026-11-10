Unit FlightDirectorU;

Interface

 Uses
  FlightDatabaseU, AirbusDataU;

 Type
  TFlightDirectorState = Record
   Selected       : Boolean;
   SelectionKnown : Boolean;
   PitchValid     : Boolean;
   BankValid      : Boolean;
   PitchError     : Double; // Degrees: positive pitch error commands nose up; positive bank error commands right.
   BankError      : Double; // Degrees: positive pitch error commands nose up; positive bank error commands right.
   Source         : String;
  End;

  TFlightDirectorSampler = Class
   Private
    fData  : TAirbusData;
    fState : TFlightDirectorState;
   Public
    Constructor Create;
    Destructor Destroy; Override;
    Procedure Clear;
    Procedure SetPoint(Plot : TTripPlot; Index : Integer; PreferFBW : Boolean);
    Property State : TFlightDirectorState Read fState;
  End;

 Var
  B38MFlightDirectorEnabled : Boolean = True;

Implementation

 Uses
  System.SysUtils, System.Math, InstrumentDataU, AirbusFMAU;

 Constructor TFlightDirectorSampler.Create;
  Begin
   Inherited;
   fData := TAirbusData.Create;
   Clear;
  End;

 Destructor TFlightDirectorSampler.Destroy;
  Begin
   fData.Free;
   Inherited;
  End;

 Procedure TFlightDirectorSampler.Clear;
  Begin
   fData.Clear;
   fState            := Default(TFlightDirectorState);
   fState.PitchError := NaN;
   fState.BankError  := NaN;
  End;

 Procedure TFlightDirectorSampler.SetPoint(Plot : TTripPlot; Index : Integer; PreferFBW : Boolean);
  Var
   p      : Double;
   b      : Double;
   Actual : Double;
   W1     : Double;
   W2     : Double;
   EIS    : Double;
   v      : Double;
   Prefix : String;
   Native : Boolean;

   Procedure Selection(Value : Double);
    Begin
     If InstrumentValid(Value) Then
      Begin
       fState.SelectionKnown := True;
       fState.Selected       := Value <> 0;
      End;
    End;

   Function Standard(Const Name : String) : Double;
    Begin
     Result := fData.Value(Name);
     // A real zero in the filtered channel must never select a different EX1 value.
     If Not InstrumentValid(Result) Then
      Result := fData.Value(Name + '_ex1');
    End;

  Begin
   fState            := Default(TFlightDirectorState);
   fState.PitchError := NaN;
   fState.BankError  := NaN;
   fData.SetPoint(Plot, Index);
   W1     := fData.FBW('A32NX_FMGC_1_DISCRETE_WORD_4');
   W2     := fData.FBW('A32NX_FMGC_2_DISCRETE_WORD_4');
   Native := PreferFBW And (InstrumentValid(W1) Or InstrumentValid(W2));
   If Native Then
    Begin
     fState.Source := 'FBW FMGC';
     W1            := DecodeAirbusARINC(W1);
     W2            := DecodeAirbusARINC(W2);
     EIS           := fData.ARINC('A32NX_FCU_LEFT_EIS_DISCRETE_WORD_2');
     If InstrumentValid(EIS) And (InstrumentValid(W1) Or InstrumentValid(W2)) Then
      Begin
       fState.SelectionKnown := True;
       fState.Selected       := (AirbusBit(W1, 13) Or AirbusBit(W2, 13)) And Not AirbusBit(EIS, 23);
      End;
     Prefix := 'A32NX_FMGC_1_';
     If Not AirbusBit(W1, 13) And AirbusBit(W2, 13) Then
      Prefix := 'A32NX_FMGC_2_';
     p       := fData.ARINC(Prefix + 'PITCH_FD_COMMAND');
     b       := fData.ARINC(Prefix + 'ROLL_FD_COMMAND');
     // FBW sends deviations, not attitude targets (AttitudeIndicatorFixed.tsx).
     If InstrumentValid(p) Then
      Begin
       fState.PitchError := -p;
       fState.PitchValid := True;
      End;
     If InstrumentValid(b) Then
      Begin
       fState.BankError := b;
       fState.BankValid := True;
      End;
     // Crossbars are not the TRK/FPA Flight Path Director symbol.
     v := fData.ARINC('A32NX_FCU_DISCRETE_WORD_1');
     If AirbusBit(v, 25) Then
      Begin
       fState.PitchValid := False;
       fState.BankValid  := False;
      End;
    End
   Else
    Begin
     fState.Source := 'SimConnect';
     Selection(fData.Value('autopilot_flight_director_active'));
     v := fData.Value('iFlySDK.FD_1_Switch_Status');
     If InstrumentValid(v) Then
      Selection(v);
     v := fData.Fenix('I_FCU_EFIS1_FD');
     If InstrumentValid(v) Then
      Selection(v);
     p      := Standard('autopilot_flight_director_pitch');
     b      := Standard('autopilot_flight_director_bank');
     Actual := fData.Value('plane_pitch_degrees');
     If InstrumentValid(p) And (Abs(p) <= Pi / 2) And InstrumentValid(Actual) And (Abs(Actual) <= 90) Then
      Begin
       fState.PitchError := Actual - RadToDeg(p);
       fState.PitchValid := True;
      End;
     Actual := fData.Value('plane_bank_degrees');
     If InstrumentValid(b) And (Abs(b) <= Pi) And InstrumentValid(Actual) And (Abs(Actual) <= 180) Then
      Begin
       fState.BankError := Actual - RadToDeg(b);
       fState.BankError := fState.BankError - 360 * Floor((fState.BankError + 180) / 360);
       fState.BankValid := True;
      End;
    End;
   If Not fState.Selected Or Not fState.SelectionKnown Then
    Begin
     fState.PitchValid := False;
     fState.BankValid  := False;
    End;
  End;

End.
