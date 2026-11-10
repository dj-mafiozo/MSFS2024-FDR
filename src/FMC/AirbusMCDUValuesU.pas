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

 Function Compact(Const s : String) : String;
  Begin
   Result := TRegEx.Replace(UpperCase(Trim(s)), '\s+', '');
  End;

 Function AirbusMCDUPage(Lines : TStrings) : String;
  Var
   t : String;
   i : Integer;
  Begin
   Result := '';
   If Lines.Count = 0 Then
    Exit;
   t := Compact(Lines[0]);
   If Pos('TAKEOFF', t) > 0 Then
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
     For i  := 1 To Lines.Count - 2 Do
      If (Pos('ZFW', Compact(Lines[i])) > 0) Or (Pos('BLOCK', Compact(Lines[i])) > 0) Then
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
   m     : TMatch;
   a     : Double;
   b     : Double;

   Function Group(Index : Integer) : String;
    Begin
     Result := '';
     If Index < m.Groups.Count Then
      Result := m.Groups[Index].Value;
    End;

  // Read only label/data rows, never row 13 (scratchpad). Exact half-screen
  // boundaries prevent an unrelated value in the other column being borrowed.

   Function Field(Const LabelText : String; Out v : String) : Boolean;
    Var
     r        : Integer;
     c        : Integer;
     Half     : String;
     LabelKey : String;
     h        : String;
    Begin
     Result   := False;
     v        := '';
     LabelKey := Compact(LabelText);
     r        := 1;
     While (r + 1 < Lines.Count) And (r + 1 <= 12) Do
      Begin
       For c := 0 To 1 Do
        Begin
         Half := Copy(Lines[r], c * 12 + 1, 12);
         If Compact(Half) = LabelKey Then
          Begin
           v := Trim(UpperCase(Copy(Lines[r + 1], c * 12 + 1, 12)));
           Exit(True);
          End;
         h := Trim(UpperCase(Half));
         If (Copy(h, 1, Length(LabelText)) = UpperCase(LabelText)) And (Length(h) > Length(LabelText)) And CharInSet(h[Length(LabelText) + 1], [' ', ':', '=']) Then
          Begin
           v := Trim(Copy(h, Length(LabelText) + 1, MaxInt));
           If (v <> '') And CharInSet(v[1], [':', '=']) Then
            v := Trim(Copy(v, 2, MaxInt));
           Exit(True);
          End;
        End;
       Inc(r, 2);
      End;
    End;

   Procedure Null(Const Key : String);
    Begin
     Result.RemovePair(Key).Free;
     Result.AddPair(Key, TJSONNull.Create);
    End;

   Procedure Number(Const Key : String; n : Double);
    Begin
     Result.RemovePair(Key).Free;
     Result.AddPair(Key, TJSONNumber.Create(n));
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
     v     : String;
     n     : Double;
     Match : TMatch;
    Begin
     If Not Field(LabelText, v) Then
      Exit;
     Null(Key);
     Match := TRegEx.Match(v, '^\s*([+-]?\d+(?:[.,]\d+)?)\s*(?:KT|KTS|FT|' + WideChar($B0) + '?C)?\s*$');
     If Match.Success And TryStrToFloat(Match.Groups[1].Value.Replace(',', '.'), n, FS) And (n >= Low) And (n <= High) Then
      Number(Key, n);
    End;

   Procedure Altitudes(Const LabelText, Key1, Key2 : String);
    Var
     v     : String;
     Match : TMatch;
     n     : Double;
    Begin
     If Not Field(LabelText, v) Then
      Exit;
     Null(Key1);
     Null(Key2);
     Match := TRegEx.Match(v, '^(\d{1,5})\s*/\s*(\d{1,5})$');
     If Not Match.Success Then
      Exit;
     n := StrToInt(Match.Groups[1].Value);
     If n <= 60000 Then
      Number(Key1, n);
     n := StrToInt(Match.Groups[2].Value);
     If n <= 60000 Then
      Number(Key2, n);
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
       m := TRegEx.Match(Value, '^(\d{3,4}(?:\.\d+)?)\s*(?:HPA)?$');
       If m.Success And TryStrToFloat(m.Groups[1].Value, a, FS) And (a >= 800) And (a <= 1100) Then
        Number('approach_qnh_hpa', a)
       Else
        Begin
         m := TRegEx.Match(Value, '^(\d{2}\.\d{2})\s*(?:INHG)?$');
         If m.Success And TryStrToFloat(m.Groups[1].Value, a, FS) And (a >= 23) And (a <= 33) Then
          Number('approach_qnh_inhg', a);
        End;
      End;
     If Field('MAG WIND', Value) Then
      Begin
       Null('approach_wind_magnetic_deg');
       Null('approach_wind_kt');
       m := TRegEx.Match(Value, '^(\d{1,3})\s*/\s*(\d{1,3})$');
       If m.Success Then
        Begin
         a := StrToInt(m.Groups[1].Value);
         b := StrToInt(m.Groups[2].Value);
         If (a <= 360) And (b <= 250) Then
          Begin
           Number('approach_wind_magnetic_deg', a);
           Number('approach_wind_kt', b);
          End;
        End;
      End;
     If Field('FLAPS/THS', Value) Then
      Begin
       Null('takeoff_flaps');
       Null('takeoff_ths_nose_up_deg');
       m := TRegEx.Match(Value, '^([123])\s*/\s*(?:(UP|DN)\s*)?(\d(?:[.,]\d+)?)\s*(UP|DN)?$');
       If m.Success Then
        Begin
         Number('takeoff_flaps', StrToInt(m.Groups[1].Value));
         // Direction is required; an unsigned trim value is ambiguous.
         If ((Group(2) = '') Xor (Group(4) = '')) And TryStrToFloat(m.Groups[3].Value.Replace(',', '.'), a, FS) And (a <= 15) Then
          Begin
           If (Group(2) = 'DN') Or (Group(4) = 'DN') Then
            a := -a;
           Number('takeoff_ths_nose_up_deg', a);
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
       a := TJSONNumber(Result.GetValue('vapp_kt')).AsDouble - TJSONNumber(Result.GetValue('vls_kt')).AsDouble;
       If (a >= 0) And (a <= 99) Then
        Number('approach_speed_additive_kt', a);
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
       m := TRegEx.Match(Value, '^(?:FL)?(\d{2,3})\s*/\s*([+-]?\d{1,2})$');
       If m.Success Then
        Begin
         a := StrToInt(m.Groups[1].Value);
         b := StrToInt(m.Groups[2].Value);
         If a <= 600 Then
          Number('cruise_flight_level', a);
         Number('cruise_temperature_c', b);
        End;
      End;
    End;
  End;

End.
