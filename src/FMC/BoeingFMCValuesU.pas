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
   L      : String;
   R      : String;
   Mode   : String;
   Side   : String;
   State  : String;
   Prefix : String;
   i      : Integer;
   j      : Integer;
   FS     : TFormatSettings;
   M      : TMatch;

   Procedure Number(Const Key, Text, Pattern : String; Group : Integer = 1; Scale : Double = 1);
    Var
     Match : TMatch;
     V     : Double;
    Begin
     Match := TRegEx.Match(Text, Pattern);
     Values.RemovePair(Key).Free;
     If Match.Success And TryStrToFloat(Match.Groups[Group].Value.Replace(',', '.'), V, FS) Then
      Values.AddPair(Key, TJSONNumber.Create(V * Scale))
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
      L := UpperCase(Copy(Lines[i], 1, 12));
      R := Copy(Lines[i + 1], 1, 12);
      If Pos('FLAPS', L) > 0 Then
       Number('takeoff_flaps_deg', R, '^\s*(\d{1,2})(?:\D|$)');
      If Pos('TO N1', L) > 0 Then
       N1(R);
      If (Pos('CG', L) > 0) And (Pos('TRIM', L) > 0) Then
       Begin
        Number('takeoff_cg_pct', R, '^\s*(\d{1,2}(?:[.,]\d+)?)\s*%');
        Number('takeoff_trim_units', R, '%\s*(\d{1,2}(?:[.,]\d+)?)\s*$');
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
         L := Copy(Lines[i + 1], 1, 12);
         R := Copy(Lines[i + 1], 13, 12);
         Number('assumed_temp_c', L, '^\s*([+-]?\d{1,2})\s*/');
         Number('oat_c', L, '/\s*([+-]?\d{1,2})');
         N1(R);
        End;
       For j := 0 To 1 Do
        Begin
         L    := UpperCase(Copy(Lines[i], j * 12 + 1, 12));
         Mode := '';
         If j = 0 Then
          Begin
           Side := 'takeoff';
           M    := TRegEx.Match(L, '<\s*(TO(?:-[12B])?)\b');
          End
         Else
          Begin
           Side := 'climb';
           M    := TRegEx.Match(L, '\b(CLB(?:-[12])?)\s*>');
          End;
         If M.Success Then
          Mode := M.Groups[1].Value;
         If Mode = '' Then
          Continue;
         If Pos('<ACT>', L) > 0 Then
          State := 'active'
         Else If Pos('<SEL>', L) > 0 Then
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
      L := UpperCase(Copy(Lines[i], 1, 12));
      R := Copy(Lines[i + 1], 1, 12);
      If Pos('GW/', L) > 0 Then
       Begin
        Number('gross_weight_display', R, '^\s*(\d+(?:[.,]\d+)?)\s*/');
        Number('cruise_cg_pct', R, '/\s*(\d+(?:[.,]\d+)?)\s*%');
       End;
      If Pos('PLAN/FUEL', L) > 0 Then
       Begin
        Number('planned_fuel_display', R, '^\s*(\d+(?:[.,]\d+)?)\s*/');
        Number('fuel_display', R, '/\s*(\d+(?:[.,]\d+)?)');
        M := TRegEx.Match(UpperCase(Copy(Lines[i + 1], 1, 14)), '(SENS|CALC)\s*$');
        If M.Success Then
         Text('fuel_source', M.Groups[1].Value)
        Else
         Text('fuel_source', '');
       End;
      If Pos('ZFW', L) > 0 Then
       Number('zfw_display', R, '^\s*(\d+(?:[.,]\d+)?)\s*$');
      If Pos('RESERVES', L) > 0 Then
       Number('reserves_display', R, '^\s*(\d+(?:[.,]\d+)?)\s*$');
      If Pos('COST INDEX', L) > 0 Then
       Number('cost_index', R, '^\s*(\d+)\s*$');
      L := UpperCase(Copy(Lines[i], 13, 12));
      R := UpperCase(Copy(Lines[i + 1], 13, 12));
      If Pos('CRZ ALT', L) > 0 Then
       Begin
        If Pos('FL', R) > 0 Then
         Number('cruise_altitude_ft', R, '^\s*FL\s*(\d{2,3})\s*$', 1, 100)
        Else
         Number('cruise_altitude_ft', R, '^\s*(\d{3,5})\s*$');
       End;
      If Pos('TRANS ALT', L) > 0 Then
       Number('transition_altitude_ft', R, '^\s*(\d{3,5})\s*$');
      If Pos('CRZ WIND', L) > 0 Then
       Begin
        Number('cruise_wind_deg', R, '^\s*(\d{1,3})\D*/');
        Number('cruise_wind_kt', R, '/\s*(\d{1,3})\s*$');
       End;
      If Pos('ISA DEV', L) > 0 Then
       Begin
        Number('isa_dev_f', R, '([+-]?\d{1,3})\x{00B0}?F');
        Number('isa_dev_c', R, '([+-]?\d{1,3})\x{00B0}?C');
       End;
      If Pos('T/C OAT', L) > 0 Then
       Begin
        Number('top_of_climb_oat_f', R, '([+-]?\d{1,3})\x{00B0}?F');
        Number('top_of_climb_oat_c', R, '([+-]?\d{1,3})\x{00B0}?C');
       End;
     End;
  End;

End.
