{$StackFrames On}
Unit AirbusMCDUValuesU;

Interface

 Uses
  System.Classes, System.JSON;

 Function AirbusMCDUPage(Lines : TStrings) : String;
 Function ParseAirbusMCDU(Lines : TStrings) : TJSONObject;

Implementation

 Uses
  System.SysUtils, System.RegularExpressions;

 Function Compact(Const S : String) : String;
  Begin
   Result := TRegEx.Replace(UpperCase(Trim(S)), '\s+', '');
  End;

 Function AirbusMCDUPage(Lines : TStrings) : String;
  Var
   T : String;
   I : Integer;
  Begin
   Result := '';
   If Lines.Count = 0 Then
    Exit;
   T := Compact(Lines[0]);
   If Pos('TAKEOFF', T) > 0 Then
    Result := 'AIRBUS_PERF_TAKEOFF'
   Else If TRegEx.IsMatch(UpperCase(Lines[0]), '\b(APPR|APPROACH)\b') Then
    Result := 'AIRBUS_PERF_APPR'
   Else If TRegEx.IsMatch(UpperCase(Lines[0]), '\b(GO\s*AROUND|GA)\b') Then
    Result := 'AIRBUS_PERF_GO_AROUND'
   Else If TRegEx.IsMatch(UpperCase(Lines[0]), '\b(CLB|CLIMB)\b') Then
    Result := 'AIRBUS_PERF_CLB'
   Else If TRegEx.IsMatch(UpperCase(Lines[0]), '\b(CRZ|CRUISE)\b') Then
    Result := 'AIRBUS_PERF_CRZ'
   Else If TRegEx.IsMatch(UpperCase(Lines[0]), '\b(DES|DESCENT)\b') Then
    Result := 'AIRBUS_PERF_DES'
   Else If TRegEx.IsMatch(UpperCase(Lines[0]), '\bINIT(?:\s*[AB])?\b') Then
    Begin
     Result := 'AIRBUS_INIT_A';
     For I  := 1 To Lines.Count - 2 Do
      If (Pos('ZFW', Compact(Lines[I])) > 0) Or (Pos('BLOCK', Compact(Lines[I])) > 0) Then
       Result := 'AIRBUS_INIT_B';
     If TRegEx.IsMatch(UpperCase(Lines[0]), '\bINIT\s*B\b') Then
      Result := 'AIRBUS_INIT_B';
    End;
  End;

 Function ParseAirbusMCDU(Lines : TStrings) : TJSONObject;
  Var
   Page  : String;
   Value : String;
   FS    : TFormatSettings;
   M     : TMatch;
   A     : Double;
   B     : Double;

   Function Group(Index : Integer) : String;
    Begin
     Result := '';
     If Index < M.Groups.Count Then
      Result := M.Groups[Index].Value;
    End;

  // Read only label/data rows, never row 13 (scratchpad). Exact half-screen
  // boundaries prevent an unrelated value in the other column being borrowed.
   Function Field(Const LabelText : String; Out V : String) : Boolean;
    Var
     R        : Integer;
     C        : Integer;
     Half     : String;
     LabelKey : String;
     H        : String;
    Begin
     Result   := False;
     V        := '';
     LabelKey := Compact(LabelText);
     R        := 1;
     While (R + 1 < Lines.Count) And (R + 1 <= 12) Do
      Begin
       For C := 0 To 1 Do
        Begin
         Half := Copy(Lines[R], C * 12 + 1, 12);
         If Compact(Half) = LabelKey Then
          Begin
           V := Trim(UpperCase(Copy(Lines[R + 1], C * 12 + 1, 12)));
           Exit(True);
          End;
         H := Trim(UpperCase(Half));
         If (Copy(H, 1, Length(LabelText)) = UpperCase(LabelText)) And (Length(H) > Length(LabelText)) And CharInSet(H[Length(LabelText) + 1], [' ', ':', '=']) Then
          Begin
           V := Trim(Copy(H, Length(LabelText) + 1, MaxInt));
           If (V <> '') And CharInSet(V[1], [':', '=']) Then
            V := Trim(Copy(V, 2, MaxInt));
           Exit(True);
          End;
        End;
       Inc(R, 2);
      End;
    End;

   Procedure Null(Const Key : String);
    Begin
     Result.RemovePair(Key).Free;
     Result.AddPair(Key, TJSONNull.Create);
    End;

   Procedure Number(Const Key : String; N : Double);
    Begin
     Result.RemovePair(Key).Free;
     Result.AddPair(Key, TJSONNumber.Create(N));
    End;

   Procedure TextField(Const LabelText, Key : String);
    Begin
     If Not Field(LabelText, Value) Then
      Exit;
     If (Value = '') Or TRegEx.IsMatch(Value, '^[\s\[\]\-_' + WideChar($25AE) + WideChar($25A1) + ']+$') Then
      Null(Key)
     Else
      Begin
       Result.RemovePair(Key).Free;
       Result.AddPair(Key, Value);
      End;
    End;

   Procedure NumericField(Const LabelText, Key : String; Low, High : Double);
    Var
     V     : String;
     N     : Double;
     Match : TMatch;
    Begin
     If Not Field(LabelText, V) Then
      Exit;
     Null(Key);
     Match := TRegEx.Match(V, '^\s*([+-]?\d+(?:[.,]\d+)?)\s*(?:KT|KTS|FT|' + WideChar($B0) + '?C)?\s*$');
     If Match.Success And TryStrToFloat(Match.Groups[1].Value.Replace(',', '.'), N, FS) And (N >= Low) And (N <= High) Then
      Number(Key, N);
    End;

   Procedure Altitudes(Const LabelText, Key1, Key2 : String);
    Var
     V     : String;
     Match : TMatch;
     N     : Double;
    Begin
     If Not Field(LabelText, V) Then
      Exit;
     Null(Key1);
     Null(Key2);
     Match := TRegEx.Match(V, '^(\d{1,5})\s*/\s*(\d{1,5})$');
     If Not Match.Success Then
      Exit;
     N := StrToInt(Match.Groups[1].Value);
     If N <= 60000 Then
      Number(Key1, N);
     N := StrToInt(Match.Groups[2].Value);
     If N <= 60000 Then
      Number(Key2, N);
    End;

  Begin
   Result              := TJSONObject.Create;
   Page                := AirbusMCDUPage(Lines);
   FS                  := TFormatSettings.Create;
   FS.DecimalSeparator := '.';
   If Pos('AIRBUS_PERF_', Page) = 1 Then
    Begin
     NumericField('V1', 'v1_kt', 1, 399);
     NumericField('VR', 'vr_kt', 1, 399);
     NumericField('V2', 'v2_kt', 1, 399);
     NumericField('VAPP', 'vapp_kt', 1, 399);
     NumericField('VLS', 'vls_kt', 1, 399);
     NumericField('VREF', 'vref_kt', 1, 399);
     NumericField('TRANS ALT', 'transition_altitude_ft', 0, 60000);
     NumericField('TRANS LVL', 'transition_level_fl', 0, 600);
     NumericField('ENG OUT ACC', 'engine_out_acceleration_altitude_ft', 0, 60000);
     Altitudes('THR RED/ACC', 'thrust_reduction_altitude_ft', 'acceleration_altitude_ft');
     Altitudes('THR RED /ACC', 'thrust_reduction_altitude_ft', 'acceleration_altitude_ft');
     NumericField('FLX TO TEMP', 'flex_to_temperature_c', -99, 99);
     NumericField('FLEX TO TEMP', 'flex_to_temperature_c', -99, 99);
     NumericField('TEMP', 'approach_temperature_c', -99, 99);
     NumericField('MDA', 'minimum_descent_altitude_ft', -1500, 60000);
     NumericField('BARO', 'barometric_minimum_ft', -1500, 60000);
     NumericField('DH', 'decision_height_ft', 0, 9999);
     NumericField('RADIO', 'radio_minimum_ft', 0, 9999);
     TextField('FINAL', 'final_approach');
     TextField('RWY', 'takeoff_runway');
     If Field('QNH', Value) Then
      Begin
       Null('approach_qnh_hpa');
       Null('approach_qnh_inhg');
       M := TRegEx.Match(Value, '^(\d{3,4}(?:\.\d+)?)\s*(?:HPA)?$');
       If M.Success And TryStrToFloat(M.Groups[1].Value, A, FS) And (A >= 800) And (A <= 1100) Then
        Number('approach_qnh_hpa', A)
       Else
        Begin
         M := TRegEx.Match(Value, '^(\d{2}\.\d{2})\s*(?:INHG)?$');
         If M.Success And TryStrToFloat(M.Groups[1].Value, A, FS) And (A >= 23) And (A <= 33) Then
          Number('approach_qnh_inhg', A);
        End;
      End;
     If Field('MAG WIND', Value) Then
      Begin
       Null('approach_wind_magnetic_deg');
       Null('approach_wind_kt');
       M := TRegEx.Match(Value, '^(\d{1,3})\s*/\s*(\d{1,3})$');
       If M.Success Then
        Begin
         A := StrToInt(M.Groups[1].Value);
         B := StrToInt(M.Groups[2].Value);
         If (A <= 360) And (B <= 250) Then
          Begin
           Number('approach_wind_magnetic_deg', A);
           Number('approach_wind_kt', B);
          End;
        End;
      End;
     If Field('FLAPS/THS', Value) Then
      Begin
       Null('takeoff_flaps');
       Null('takeoff_ths_nose_up_deg');
       M := TRegEx.Match(Value, '^([123])\s*/\s*(?:(UP|DN)\s*)?(\d(?:[.,]\d+)?)\s*(UP|DN)?$');
       If M.Success Then
        Begin
         Number('takeoff_flaps', StrToInt(M.Groups[1].Value));
         // Direction is required; an unsigned trim value is ambiguous.
         If ((Group(2) = '') Xor (Group(4) = '')) And TryStrToFloat(M.Groups[3].Value.Replace(',', '.'), A, FS) And (A <= 15) Then
          Begin
           If (Group(2) = 'DN') Or (Group(4) = 'DN') Then
            A := -A;
           Number('takeoff_ths_nose_up_deg', A);
          End;
        End;
      End;
     If Field('LDG CONF', Value) Then
      Begin
       Null('landing_configuration');
       If TRegEx.IsMatch(Value, '^(?:CONF\s*)?(3|FULL)$') Then
        Begin
         Result.RemovePair('landing_configuration').Free;
         Result.AddPair('landing_configuration', TRegEx.Match(Value, '(3|FULL)$').Value);
        End;
      End;
     If (Pos('APPR', Page) > 0) And (Result.GetValue('vapp_kt') Is TJSONNumber) And (Result.GetValue('vls_kt') Is TJSONNumber) Then
      Begin
       Null('approach_speed_additive_kt');
       A := TJSONNumber(Result.GetValue('vapp_kt')).AsDouble - TJSONNumber(Result.GetValue('vls_kt')).AsDouble;
       If (A >= 0) And (A <= 99) Then
        Number('approach_speed_additive_kt', A);
      End
     Else If (Pos('APPR', Page) > 0) And ((Result.GetValue('vapp_kt') <> Nil) Or (Result.GetValue('vls_kt') <> Nil)) Then
      Null('approach_speed_additive_kt');
    End;
   If Pos('AIRBUS_INIT_', Page) = 1 Then
    Begin
     TextField('FROM/TO', 'from_to');
     TextField('ALTN', 'alternate_airport');
     TextField('FLT NBR', 'flight_number');
     NumericField('COST INDEX', 'cost_index', 0, 999);
     NumericField('CI', 'cost_index', 0, 999);
     TextField('ZFW/ZFWCG', 'zero_fuel_weight_cg_display');
     TextField('BLOCK', 'block_fuel_display');
     If Field('CRZ FL/TEMP', Value) Then
      Begin
       Null('cruise_flight_level');
       Null('cruise_temperature_c');
       M := TRegEx.Match(Value, '^(?:FL)?(\d{2,3})\s*/\s*([+-]?\d{1,2})$');
       If M.Success Then
        Begin
         A := StrToInt(M.Groups[1].Value);
         B := StrToInt(M.Groups[2].Value);
         If A <= 600 Then
          Number('cruise_flight_level', A);
         Number('cruise_temperature_c', B);
        End;
      End;
    End;
  End;

End.
