Unit iFlyFMAU;

Interface

 Uses
  FlightDatabaseU;

 Type
  T737FMA = Record
   Thrust     : String;
   Roll       : String;
   Pitch      : String;
   RollArmed  : String;
   PitchArmed : String;
   Engagement : String;
   Estimated  : Boolean;
  End;

 Function IFlyMCPValue(Plot : TTripPlot; Index : Integer; Const Prefix : String) : Double;
 Function ReconstructIFlyFMA(Plot : TTripPlot; Index : Integer) : T737FMA;

Implementation

 Uses
  System.SysUtils, System.Math, InstrumentDataU;

 Function IFlyMCPValue(Plot : TTripPlot; Index : Integer; Const Prefix : String) : Double;
  Var
   i       : Integer;
   d       : Double;
   V       : Double;
   Name    : String;
   Started : Boolean;
  Begin
   Result  := NaN;
   V       := 0;
   Started := False;
   If (Prefix <> 'ALT') And (Prefix <> 'SPD') And (Prefix <> 'HDG') Then
    Exit;
   If Prefix = 'ALT' Then
    i := 10000
   Else
    i := 100;
   While i >= 1 Do
    Begin
     Name := 'iFlySDK.' + Prefix + '_' + IntToStr(i) + '_Status';
     d    := InstrumentValue(Plot, Index, Name);
     If (d = 14) And Not Started Then
      Begin
       i := i Div 10;
       Continue;
      End;
     If Not InstrumentValid(d) Or (d < 0) Or (d > 9) Or (d <> Trunc(d)) Then
      Exit;
     Started := True;
     V       := V + d * i;
     i       := i Div 10;
    End;
   If Not Started Then
    Exit;
   If Prefix = 'SPD' Then
    Begin
     d := InstrumentValue(Plot, Index, 'iFlySDK.SPD_Point_Status');
     If Not InstrumentValid(d) Or Not((d = 0) Or (d = 1)) Then
      Exit;
     If d = 1 Then
      V := V / 1000;
    End;
   If (Prefix = 'HDG') And (V > 360) Then
    Exit;
   Result := V;
  End;

 Function ReconstructIFlyFMA(Plot : TTripPlot; Index : Integer) : T737FMA;
  Var
   VN        : Boolean;
   FL        : Boolean;
   AH        : Boolean;
   VS        : Boolean;
   APP       : Boolean;
   LOC       : Boolean;
   LNAV      : Boolean;
   HDG       : Boolean;
   AP        : Boolean;
   FD        : Boolean;
   AT        : Boolean;
   Ground    : Boolean;
   Alt       : Double;
   Target    : Double;
   VSpeed    : Double;
   RA        : Double;
   Speed     : Double;
   Selected  : Double;
   SDKTarget : Double;

   Function V(Const Name : String) : Double;
    Begin
     Result := InstrumentValue(Plot, Index, Name);
    End;

   Function OnFlag(Const Name : String) : Boolean;
    Var
     x : Double;
    Begin
     x      := V(Name);
     Result := InstrumentValid(x) And (x <> 0);
    End;

   Function Lit(Const Name : String) : Boolean;
    Var
     x : Double;
     n : Integer;
    Begin
     x      := V('iFlySDK.' + Name + '_Switch_Status');
     Result := False;
     If Not InstrumentValid(x) Or (x < 0) Or (x > 5) Or (x <> Trunc(x)) Then
      Exit;
     n      := Trunc(x) Mod 3;
     Result := n <> 0; // 3 is pressed but unlit, 4/5 pressed and lit
    End;

  Begin
   Result           := Default(T737FMA);
   Result.Estimated := True;
   If (Plot = Nil) Or (Index < 0) Or (Index >= Plot.Points.Count) Then
    Exit;
   If Not InstrumentValid(V('iFlySDK.FD_1_Switch_Status')) And Not InstrumentValid(V('iFlySDK.FD_2_Switch_Status')) And Not InstrumentValid(V('iFlySDK.CMD_A_Switch_Status')) Then
    Begin
     Result.Thrust := '--';
     Result.Roll   := '--';
     Result.Pitch  := '--';
     Exit;
    End;
   VN     := Lit('VNAV');
   FL     := Lit('LVL_CHG');
   AH     := Lit('ALT_HLD');
   VS     := Lit('VS');
   APP    := Lit('APP');
   LOC    := Lit('VOR_LOC');
   LNAV   := Lit('LNAV');
   HDG    := Lit('HDG_SEL');
   AP     := Lit('CMD_A') Or Lit('CMD_B');
   FD     := OnFlag('iFlySDK.FD_1_Switch_Status') Or OnFlag('iFlySDK.FD_2_Switch_Status');
   AT     := OnFlag('autothrottle_active') Or (OnFlag('iFlySDK.AT_Switch_Status') And (Lit('N1') Or Lit('SPEED')));
   Ground := OnFlag('sim_on_ground');
   If AP Then
    Result.Engagement := 'CMD'
   Else If Lit('CWS_A') Or Lit('CWS_B') Then
    Result.Engagement := 'CWS'
   Else If FD Then
    Result.Engagement := 'FD';

   Alt       := V('indicated_altitude');
   Target    := V('autopilot_altitude_lock_var');
   VSpeed    := V('vertical_speed');
   RA        := V('radio_height');
   Speed     := V('airspeed_indicated');
   Selected  := V('autopilot_airspeed_hold_var');
   SDKTarget := IFlyMCPValue(Plot, Index, 'ALT');
   If InstrumentValid(SDKTarget) Then
    Target := SDKTarget;
   If OnFlag('autopilot_approach_captured') And OnFlag('autopilot_approach_is_localizer') Then
    Result.Roll := 'VOR/LOC'
   Else If LNAV Then
    Result.Roll := 'LNAV'
   Else If HDG Or OnFlag('autopilot_heading_lock') Then
    Result.Roll := 'HDG SEL'
   Else If LOC And OnFlag('autopilot_approach_active') Then
    Result.Roll := 'VOR/LOC';
   If (APP Or LOC) And (Result.Roll <> 'VOR/LOC') Then
    Result.RollArmed := 'VOR/LOC';
   If OnFlag('autopilot_glideslope_active') Then
    Result.Pitch := 'G/S'
   Else If OnFlag('autopilot_takeoff_power_active') Then
    Begin
     Result.Pitch := 'TO/GA';
     If Result.Roll = '' Then
      Result.Roll := 'TO/GA';
    End
   Else If VN Then
    Begin
     If AH Or OnFlag('autopilot_altitude_lock') Then
      Result.Pitch := 'VNAV ALT'
     Else If InstrumentValid(VSpeed) And (VSpeed < -200) And InstrumentValid(Speed) And InstrumentValid(Selected) And (Abs(Speed - Selected) < 10) Then
      Result.Pitch := 'VNAV PTH'
     Else
      Result.Pitch := 'VNAV SPD';
    End
   Else If AH Or OnFlag('autopilot_altitude_lock') Then
    Result.Pitch := 'ALT HOLD'
   Else If VS Or OnFlag('autopilot_vertical_hold') Then
    Result.Pitch := 'V/S'
   Else If FL Or OnFlag('autopilot_flight_level_change') Then
    Result.Pitch := 'MCP SPD';
   If (Result.Pitch <> 'G/S') And (Result.Pitch <> 'TO/GA') And Not Ground And InstrumentValid(Alt) And InstrumentValid(Target) And InstrumentValid(VSpeed) And (Abs(VSpeed) > 200) And ((Target - Alt) * VSpeed > 0) And (Abs(Target - Alt) < Max(60, Abs(VSpeed) * 7 / 60)) Then
    Result.Pitch := 'ALT ACQ';
   If (APP Or OnFlag('autopilot_glideslope_arm')) And (Result.Pitch <> 'G/S') Then
    Result.PitchArmed := 'G/S';
   If OnFlag('autopilot_takeoff_power_active') And AT Then
    Begin
     If InstrumentValid(Speed) And (Speed >= 84) And (Ground Or (InstrumentValid(RA) And (RA < 800))) Then
      Result.Thrust := 'THR HLD'
     Else
      Result.Thrust := 'N1';
    End
   Else If AT And Lit('N1') Then
    Result.Thrust := 'N1'
   Else If AT And (Lit('SPEED') Or OnFlag('autopilot_airspeed_hold') Or OnFlag('autopilot_mach_hold')) Then
    Result.Thrust := 'MCP SPD'
   Else If AT And InstrumentValid(RA) And (RA < 27) And Not Ground And (Result.Pitch = 'G/S') Then
    Result.Thrust := 'RETARD'
   Else If AT And FL And InstrumentValid(Alt) And InstrumentValid(Target) And (Target < Alt) Then
    Result.Thrust := 'RETARD'
   Else If AT And VN And (Result.Pitch = 'VNAV PTH') Then
    Result.Thrust := 'FMC SPD'
   Else If OnFlag('iFlySDK.AT_Switch_Status') Then
    Result.Thrust := 'ARM';
   If (Result.Pitch = 'G/S') And Lit('CMD_A') And Lit('CMD_B') And APP Then
    Begin
     If Ground Then
      Result.Roll := 'ROLLOUT'
     Else If InstrumentValid(RA) And (RA < 50) Then
      Result.Pitch := 'FLARE'
     Else
      Result.PitchArmed := 'FLARE';
    End;
   If Not(AP Or FD Or Lit('CWS_A') Or Lit('CWS_B')) Then
    Begin
     Result.Roll       := '';
     Result.Pitch      := '';
     Result.RollArmed  := '';
     Result.PitchArmed := '';
    End;
  End;

End.
