Unit PFDReadoutsU;

Interface

 Uses
  System.Types, AirbusDataU, FlightDatabaseU;

 Type
  TRadioReadout = Record
   LabelText : String;
   Frequency : String;
   Distance  : String;
  End;

 Function PFDSpeedCaption(Data : TAirbusData; Plot : TTripPlot; Index : Integer; Boeing : Boolean) : String;
 Function PFDBaroCaption(Data : TAirbusData; Airbus : Boolean) : String;
 Function PFDRadio(Data : TAirbusData; Side : Integer) : TRadioReadout;
 Function PFDWindDirection(FromTrue, HeadingTrue : Double) : Double;

Implementation

 Uses
  System.SysUtils, System.Math, InstrumentDataU, iFlyFMAU, AirbusFMAU, ParameterNamesU;

 Function SpeedText(v : Double; Mach : Boolean) : String;
  Var
   f : TFormatSettings;
  Begin
   Result := '--';
   If Not InstrumentValid(v) Or (v < 0) Then
    Exit;
   If Mach Then
    Begin
     If v >= 2 Then
      Exit;
     f                  := TFormatSettings.Create;
     f.DecimalSeparator := '.';
     Result             := 'M ' + FormatFloat('0.000', v, f);
    End
   Else
    Result := Format('%.0f', [ParameterDisplayValue('airspeed_indicated', v)]);
  End;

 Function PFDSpeedCaption(Data : TAirbusData; Plot : TTripPlot; Index : Integer; Boeing : Boolean) : String;
  Var
   Mode : Double;
   v    : Double;
  Begin
   If Boeing Then
    Begin
     Mode := Data.Value('iFlySDK.SPD_Point_Status');
     If (Mode = 0) Or (Mode = 1) Then
      Begin
       v := IFlyMCPValue(Plot, Index, 'SPD');
       If Not InstrumentValid(v) Then
        Exit('---');
       Exit(SpeedText(v, Mode = 1));
      End;
    End
   Else
    Begin
     Mode := Data.FBW('A32NX_FCU_AFS_DISPLAY_MACH_MODE');
     v    := Data.FBW('A32NX_FCU_AFS_DISPLAY_SPD_MACH_VALUE');
     If (Mode = 0) Or (Mode = 1) Then
      Exit(SpeedText(v, Mode = 1));
    End;
   Mode := Data.Value('autopilot_managed_speed_in_mach');
   If Not InstrumentValid(Mode) Then
    Mode := Data.Value('autopilot_mach_hold');
   If Mode = 1 Then
    Result := SpeedText(Data.Value('autopilot_mach_hold_var'), True)
   Else
    Result := SpeedText(Data.Value('autopilot_airspeed_hold_var'), False);
  End;

 Function PFDBaroCaption(Data : TAirbusData; Airbus : Boolean) : String;
  Var
   Raw    : Double;
   w      : Double;
   Value  : Double;
   Prefix : String;
  Begin
   Prefix := '';
   Value  := NaN;
   If Airbus Then
    Begin
     Raw := Data.FBW('A32NX_FCU_LEFT_EIS_DISCRETE_WORD_2');
     If InstrumentValid(Raw) Then
      Begin
       w := DecodeAirbusARINC(Raw);
       If Not InstrumentValid(w) Then
        Exit('BARO --');
       If AirbusBit(w, 28) Then
        Exit('STD');
       If AirbusBit(w, 29) Then
        Prefix := 'QNH '
       Else
        Prefix := 'QFE ';
       Value   := Data.ARINC('A32NX_FCU_LEFT_EIS_BARO_HPA');
       If Not InstrumentValid(Value) Then
        Begin
         Value := Data.ARINC('A32NX_FCU_LEFT_EIS_BARO');
         If InstrumentValid(Value) Then
          Value := Value * 33.8638866667;
        End;
      End;
    End;
   If Prefix = '' Then
    Begin
     If Data.Value('kohlsman_setting_std') = 1 Then
      Exit('STD');
     If Airbus Then
      Prefix := 'QNH ';
     Value   := Data.Value('kohlsman_setting_mb');
     If Not InstrumentValid(Value) Then
      Begin
       Value := Data.Value('kohlsman_setting_hg');
       If InstrumentValid(Value) Then
        Value := Value * 33.8638866667;
      End;
    End;
   If Not InstrumentValid(Value) Or (Value <= 0) Then
    Exit('BARO --');
   If ParameterDisplayUnit('kohlsman_setting_mb') = 'hPa' Then
    Result := Format('%.0f', [ParameterDisplayValue('kohlsman_setting_mb', Value)])
   Else
    Result := Format('%.2f', [ParameterDisplayValue('kohlsman_setting_mb', Value)]);
   Result  := Prefix + Result + ' ' + ParameterDisplayUnit('kohlsman_setting_mb');
  End;

 Function PFDRadio(Data : TAirbusData; Side : Integer) : TRadioReadout;
  Var
   Mode     : Double;
   f        : Double;
   d        : Double;
   HasDME   : Double;
   Receiver : String;
   FS       : TFormatSettings;
  Begin
   FS                  := TFormatSettings.Create;
   FS.DecimalSeparator := '.';
   Result.LabelText    := '';
   Result.Frequency    := '--';
   Result.Distance     := '';
   If (Side < 1) Or (Side > 2) Then
    Exit;
   Receiver := IntToStr(Side);
   If Side = 1 Then
    Mode := Data.Value('iFlySDK.VORADF_L_Status[0]')
   Else
    Mode := Data.Value('iFlySDK.VORADF_R_Status[0]');
   If Mode = 1 Then
    Exit;
   If Mode = 0 Then
    Begin
     Result.LabelText := 'VOR ' + Receiver;
     f                := Data.Value('nav_active_frequency_' + Receiver);
     d                := Data.Value('nav_dme_' + Receiver);
     HasDME           := Data.Value('nav_has_dme_' + Receiver);
     If InstrumentValid(f) And (f >= 108) And (f <= 118) Then
      Result.Frequency := FormatFloat('0.00', f, FS);
     Result.Distance   := 'DME --';
     If (HasDME = 1) And InstrumentValid(d) And (d >= 0) Then
      Result.Distance := 'DME ' + FormatFloat('0.0', d, FS) + ' NM';
    End
   Else If Mode = 2 Then
    Begin
     Result.LabelText := 'ADF ' + Receiver;
     f                := Data.Value('adf_active_frequency_' + Receiver);
     If InstrumentValid(f) And (f >= 100) And (f <= 1800) Then
      Result.Frequency := FormatFloat('0.0', f, FS);
    End;
  End;

 Function PFDWindDirection(FromTrue, HeadingTrue : Double) : Double;
  Begin
   Result := NaN;
   If Not InstrumentValid(FromTrue) Or Not InstrumentValid(HeadingTrue) Or (FromTrue < 0) Or (FromTrue > 360) Or (HeadingTrue < 0) Or (HeadingTrue > 360) Then
    Exit;
   Result := FromTrue - HeadingTrue + 180;
   Result := Result - 360 * Floor(Result / 360);
  End;

End.
