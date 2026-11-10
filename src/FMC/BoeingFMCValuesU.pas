{$StackFrames On}
Unit BoeingFMCValuesU;

Interface

 Uses
  System.Classes, System.JSON;

 Procedure ParseBoeingPerformance(Lines : TStrings; Values : TJSONObject);

Implementation

 Uses
  System.SysUtils, System.RegularExpressions;

 Procedure ParseBoeingPerformance(Lines : TStrings; Values : TJSONObject);
  Var
   Title  : String;
   l      : String;
   r      : String;
   Mode   : String;
   Side   : String;
   State  : String;
   Prefix : String;
   i      : Integer;
   j      : Integer;
   FS     : TFormatSettings;
   m      : TMatch;

   Procedure Number(Const Key, Text, Pattern : String; Group : Integer = 1; Scale : Double = 1);
    Var
     Match : TMatch;
     v     : Double;
    Begin
     Match := TRegEx.Match(Text, Pattern);
     Values.RemovePair(Key).Free;
     If Match.Success And TryStrToFloat(Match.Groups[Group].Value.Replace(',', '.'), v, FS) Then
      Values.AddPair(Key, TJSONNumber.Create(v * Scale))
     Else
      Values.AddPair(Key, TJSONNull.Create);
    End;

   Procedure Text(Const Key, Value : String);
    Begin
     Values.RemovePair(Key).Free;
     If Value = '' Then
      Values.AddPair(Key, TJSONNull.Create)
     Else
      Values.AddPair(Key, Value);
    End;

   Procedure N1(Const Row : String);
    Const
     Pair = '^\s*(\d{1,3}(?:[.,]\d+)?)\s*/\s*(\d{1,3}(?:[.,]\d+)?)\s*%?\s*$';
    Begin
     Number('takeoff_n1_left_pct', Row, Pair, 1);
     Number('takeoff_n1_right_pct', Row, Pair, 2);
    End;

  Begin
   If Lines.Count = 0 Then
    Exit;
   FS                  := TFormatSettings.Create;
   FS.DecimalSeparator := '.';
   Title               := UpperCase(Lines[0]).Replace(' ', '');
   If Pos('TAKEOFFREF', Title) > 0 Then
    For i := 1 To Lines.Count - 2 Do
     Begin
      l := UpperCase(Copy(Lines[i], 1, 12));
      r := Copy(Lines[i + 1], 1, 12);
      If Pos('FLAPS', l) > 0 Then
       Number('takeoff_flaps_deg', r, '^\s*(\d{1,2})(?:\D|$)');
      If Pos('TO N1', l) > 0 Then
       N1(r);
      If (Pos('CG', l) > 0) And (Pos('TRIM', l) > 0) Then
       Begin
        Number('takeoff_cg_pct', r, '^\s*(\d{1,2}(?:[.,]\d+)?)\s*%');
        Number('takeoff_trim_units', r, '%\s*(\d{1,2}(?:[.,]\d+)?)\s*$');
       End;
     End;
   If Pos('N1LIMIT', Title) > 0 Then
    Begin
     For j := 0 To 1 Do
      Begin
       If j = 0 Then
        Side := 'takeoff'
       Else
        Side := 'climb';
       Text(Side + '_mode_active', '');
       Text(Side + '_mode_selected', '');
      End;
     For j := 0 To 1 Do
      Begin
       If j = 0 Then
        Prefix := 'takeoff_active'
       Else
        Prefix := 'takeoff_selected';
       Text(Prefix + '_rating_k', '');
       Text(Prefix + '_derate_pct', '');
       Text(Prefix + '_bump', '');
      End;
     For i := 1 To Lines.Count - 2 Do
      Begin
       If Pos('SEL/OAT', UpperCase(Lines[i])) > 0 Then
        Begin
         l := Copy(Lines[i + 1], 1, 12);
         r := Copy(Lines[i + 1], 13, 12);
         Number('assumed_temp_c', l, '^\s*([+-]?\d{1,2})\s*/');
         Number('oat_c', l, '/\s*([+-]?\d{1,2})');
         N1(r);
        End;
       For j := 0 To 1 Do
        Begin
         l    := UpperCase(Copy(Lines[i], j * 12 + 1, 12));
         Mode := '';
         If j = 0 Then
          Begin
           Side := 'takeoff';
           m    := TRegEx.Match(l, '<\s*(TO(?:-[12B])?)\b');
          End
         Else
          Begin
           Side := 'climb';
           m    := TRegEx.Match(l, '\b(CLB(?:-[12])?)\s*>');
          End;
         If m.Success Then
          Mode := m.Groups[1].Value;
         If Mode = '' Then
          Continue;
         If Pos('<ACT>', l) > 0 Then
          State := 'active'
         Else If Pos('<SEL>', l) > 0 Then
          State := 'selected'
         Else
          Continue;
         Prefix := Side + '_' + State;
         Text(Side + '_mode_' + State, Mode);
         If j = 0 Then
          Begin
           Number(Prefix + '_rating_k', UpperCase(Lines[i - 1]), '\b(\d{2})K\b');
           Values.RemovePair(Prefix + '_derate_pct').Free;
           If Mode = 'TO-1' Then
            Values.AddPair(Prefix + '_derate_pct', TJSONNumber.Create(10))
           Else If Mode = 'TO-2' Then
            Values.AddPair(Prefix + '_derate_pct', TJSONNumber.Create(20))
           Else
            Values.AddPair(Prefix + '_derate_pct', TJSONNumber.Create(0));
           Values.RemovePair(Prefix + '_bump').Free;
           Values.AddPair(Prefix + '_bump', TJSONBool.Create(Mode = 'TO-B'));
          End;
        End;
      End;
    End;
   If (Pos('PERFINIT', Title) > 0) Or (Pos('PREFINIT', Title) > 0) Then
    For i := 1 To Lines.Count - 2 Do
     Begin
      l := UpperCase(Copy(Lines[i], 1, 12));
      r := Copy(Lines[i + 1], 1, 12);
      If Pos('GW/', l) > 0 Then
       Begin
        Number('gross_weight_display', r, '^\s*(\d+(?:[.,]\d+)?)\s*/');
        Number('cruise_cg_pct', r, '/\s*(\d+(?:[.,]\d+)?)\s*%');
       End;
      If Pos('PLAN/FUEL', l) > 0 Then
       Begin
        Number('planned_fuel_display', r, '^\s*(\d+(?:[.,]\d+)?)\s*/');
        Number('fuel_display', r, '/\s*(\d+(?:[.,]\d+)?)');
        m := TRegEx.Match(UpperCase(Copy(Lines[i + 1], 1, 14)), '(SENS|CALC)\s*$');
        If m.Success Then
         Text('fuel_source', m.Groups[1].Value)
        Else
         Text('fuel_source', '');
       End;
      If Pos('ZFW', l) > 0 Then
       Number('zfw_display', r, '^\s*(\d+(?:[.,]\d+)?)\s*$');
      If Pos('RESERVES', l) > 0 Then
       Number('reserves_display', r, '^\s*(\d+(?:[.,]\d+)?)\s*$');
      If Pos('COST INDEX', l) > 0 Then
       Number('cost_index', r, '^\s*(\d+)\s*$');
      l := UpperCase(Copy(Lines[i], 13, 12));
      r := UpperCase(Copy(Lines[i + 1], 13, 12));
      If Pos('CRZ ALT', l) > 0 Then
       Begin
        If Pos('FL', r) > 0 Then
         Number('cruise_altitude_ft', r, '^\s*FL\s*(\d{2,3})\s*$', 1, 100)
        Else
         Number('cruise_altitude_ft', r, '^\s*(\d{3,5})\s*$');
       End;
      If Pos('TRANS ALT', l) > 0 Then
       Number('transition_altitude_ft', r, '^\s*(\d{3,5})\s*$');
      If Pos('CRZ WIND', l) > 0 Then
       Begin
        Number('cruise_wind_deg', r, '^\s*(\d{1,3})\D*/');
        Number('cruise_wind_kt', r, '/\s*(\d{1,3})\s*$');
       End;
      If Pos('ISA DEV', l) > 0 Then
       Begin
        Number('isa_dev_f', r, '([+-]?\d{1,3})\x{00B0}?F');
        Number('isa_dev_c', r, '([+-]?\d{1,3})\x{00B0}?C');
       End;
      If Pos('T/C OAT', l) > 0 Then
       Begin
        Number('top_of_climb_oat_f', r, '([+-]?\d{1,3})\x{00B0}?F');
        Number('top_of_climb_oat_c', r, '([+-]?\d{1,3})\x{00B0}?C');
       End;
     End;
  End;

End.
