{$StackFrames On}
Unit iFlyDisplaysU;

Interface

 Uses
  System.JSON;

 Procedure AssembleiFlyDisplays(Fields : TJSONObject; RemoveSegments : Boolean = False);
 Procedure CompactiFlySDK(SDK : TJSONObject);
 Function iFlyDisplayNames : TArray<String>;
 Procedure AddiFlyDisplayDefinitions(Definitions : TJSONObject);
 Function iFlyCompactField(Const Name : String) : Boolean;

Implementation

 Uses
  System.SysUtils, System.Generics.Collections, System.Math;

 Type
  TDisplayDef = Record
   Public
    Name   : String;
    Keys   : String;
    Points : String;
    Symbol : String;
    Blank  : Integer;
    Mode   : Integer;
    Scale  : Double;
  End;

 Const
  Defs : Array [0 .. 25] Of TDisplayDef = (
   (Name: 'Flight_Altitude_Indicator';   Keys: 'Flight_Altitude_Indicator_10000_Status|Flight_Altitude_Indicator_1000_Status|Flight_Altitude_Indicator_100_Status|Flight_Altitude_Indicator_10_Status|Flight_Altitude_Indicator_1_Status';      Points: '';                                                                                                    Symbol: '';                 Blank: 11; Mode: 0; Scale: 1),
   (Name: 'Landing_Altitude_Indicator';  Keys: 'Landing_Altitude_Indicator_10000_Status|Landing_Altitude_Indicator_1000_Status|Landing_Altitude_Indicator_100_Status|Landing_Altitude_Indicator_10_Status|Landing_Altitude_Indicator_1_Status'; Points: '';                                                                                                    Symbol: '';                 Blank: 11; Mode: 0; Scale: 1),
   (Name: 'Course_1';                    Keys: 'Course_1_100_Status|Course_1_10_Status|Course_1_1_Status';                                                                                                                                      Points: '';                                                                                                    Symbol: '';                 Blank: 14; Mode: 0; Scale: 1),
   (Name: 'Course_2';                    Keys: 'Course_2_100_Status|Course_2_10_Status|Course_2_1_Status';                                                                                                                                      Points: '';                                                                                                    Symbol: '';                 Blank: 14; Mode: 0; Scale: 1),
   (Name: 'HDG';                         Keys: 'HDG_100_Status|HDG_10_Status|HDG_1_Status';                                                                                                                                                     Points: '';                                                                                                    Symbol: '';                 Blank: 14; Mode: 0; Scale: 1),
   (Name: 'ALT';                         Keys: 'ALT_10000_Status|ALT_1000_Status|ALT_100_Status|ALT_10_Status|ALT_1_Status';                                                                                                                    Points: '';                                                                                                    Symbol: '';                 Blank: 14; Mode: 0; Scale: 1),
   (Name: 'SPD';                         Keys: 'SPD_100_Status|SPD_10_Status|SPD_1_Status';                                                                                                                                                     Points: 'SPD_Point_Status';                                                                                    Symbol: '';                 Blank: 14; Mode: 5; Scale: 1),
   (Name: 'VS';                          Keys: 'VS_1000_Status|VS_100_Status|VS_10_Status|VS_1_Status';                                                                                                                                         Points: '';                                                                                                    Symbol: 'VS_Symbol_Status'; Blank: 14; Mode: 6; Scale: 1),
   (Name: 'Transponder_Windows_Digital'; Keys: 'Transponder_Windows_Digital_1000_Status|Transponder_Windows_Digital_100_Status|Transponder_Windows_Digital_10_Status|Transponder_Windows_Digital_1_Status';                                     Points: '';                                                                                                    Symbol: '';                 Blank: 10; Mode: 0; Scale: 1),
   (Name: 'ADF_num[0]';                  Keys: 'ADF_num_1000_Status[0]|ADF_num_100_Status[0]|ADF_num_10_Status[0]|ADF_num_1_Status[0]|ADF_num_01_Status[0]';                                                                                    Points: 'ADF_num_point1_Status[0]|ADF_num_point2_Status[0]|ADF_num_point3_Status[0]|ADF_num_point4_Status[0]'; Symbol: '';                 Blank: 10; Mode: 4; Scale: 1),
   (Name: 'NAV_num[0][0]';               Keys: 'NAV_num_100_Status[0][0]|NAV_num_10_Status[0][0]|NAV_num_1_Status[0][0]|NAV_num_01_Status[0][0]|NAV_num_001_Status[0][0]';                                                                      Points: '';                                                                                                    Symbol: '';                 Blank: 10; Mode: 3; Scale: 0.01),
   (Name: 'NAV_num[0][1]';               Keys: 'NAV_num_100_Status[0][1]|NAV_num_10_Status[0][1]|NAV_num_1_Status[0][1]|NAV_num_01_Status[0][1]|NAV_num_001_Status[0][1]';                                                                      Points: '';                                                                                                    Symbol: '';                 Blank: 10; Mode: 3; Scale: 0.01),
   (Name: 'ADF_num[1]';                  Keys: 'ADF_num_1000_Status[1]|ADF_num_100_Status[1]|ADF_num_10_Status[1]|ADF_num_1_Status[1]|ADF_num_01_Status[1]';                                                                                    Points: 'ADF_num_point1_Status[1]|ADF_num_point2_Status[1]|ADF_num_point3_Status[1]|ADF_num_point4_Status[1]'; Symbol: '';                 Blank: 10; Mode: 4; Scale: 1),
   (Name: 'NAV_num[1][0]';               Keys: 'NAV_num_100_Status[1][0]|NAV_num_10_Status[1][0]|NAV_num_1_Status[1][0]|NAV_num_01_Status[1][0]|NAV_num_001_Status[1][0]';                                                                      Points: '';                                                                                                    Symbol: '';                 Blank: 10; Mode: 3; Scale: 0.01),
   (Name: 'NAV_num[1][1]';               Keys: 'NAV_num_100_Status[1][1]|NAV_num_10_Status[1][1]|NAV_num_1_Status[1][1]|NAV_num_01_Status[1][1]|NAV_num_001_Status[1][1]';                                                                      Points: '';                                                                                                    Symbol: '';                 Blank: 10; Mode: 3; Scale: 0.01),
   (Name: 'Fuel_Quantity_Indicator[0]';  Keys: 'Fuel_Quantity_Indicator_Status[0][0]|Fuel_Quantity_Indicator_Status[0][1]|Fuel_Quantity_Indicator_Status[0][2]|Fuel_Quantity_Indicator_Status[0][3]|Fuel_Quantity_Indicator_Status[0][4]';      Points: '';                                                                                                    Symbol: '';                 Blank: 10; Mode: 0; Scale: 1),
   (Name: 'Fuel_Quantity_Indicator[1]';  Keys: 'Fuel_Quantity_Indicator_Status[1][0]|Fuel_Quantity_Indicator_Status[1][1]|Fuel_Quantity_Indicator_Status[1][2]|Fuel_Quantity_Indicator_Status[1][3]|Fuel_Quantity_Indicator_Status[1][4]';      Points: '';                                                                                                    Symbol: '';                 Blank: 10; Mode: 0; Scale: 1),
   (Name: 'Fuel_Quantity_Indicator[2]';  Keys: 'Fuel_Quantity_Indicator_Status[2][0]|Fuel_Quantity_Indicator_Status[2][1]|Fuel_Quantity_Indicator_Status[2][2]|Fuel_Quantity_Indicator_Status[2][3]|Fuel_Quantity_Indicator_Status[2][4]';      Points: '';                                                                                                    Symbol: '';                 Blank: 10; Mode: 0; Scale: 1),
   (Name: 'IRS_Window_L';                Keys: 'IRS_Window_L_1_Status|IRS_Window_L_2_Status|IRS_Window_L_3_Status|IRS_Window_L_4_Status|IRS_Window_L_5_Status|IRS_Window_L_6_Status';                                                           Points: 'IRS_Window_L_point_1_Status|IRS_Window_L_point_2_Status|IRS_Window_L_point_3_Status';                 Symbol: '';                 Blank: 10; Mode: 1; Scale: 1),
   (Name: 'IRS_Window_R';                Keys: 'IRS_Window_R_1_Status|IRS_Window_R_2_Status|IRS_Window_R_3_Status|IRS_Window_R_4_Status|IRS_Window_R_5_Status|IRS_Window_R_6_Status|IRS_Window_R_7_Status';                                     Points: 'IRS_Window_R_point_1_Status|IRS_Window_R_point_2_Status|IRS_Window_R_point_3_Status';                 Symbol: '';                 Blank: 10; Mode: 1; Scale: 1),
   (Name: 'RTP_Left_Num[0]';             Keys: 'RTP_Left_Num_100_Status[0]|RTP_Left_Num_10_Status[0]|RTP_Left_Num_1_Status[0]|RTP_Left_Num_point1_Status[0]|RTP_Left_Num_point2_Status[0]|RTP_Left_Num_point3_Status[0]';                       Points: 'RTP_Left_Num_point_Status[0]';                                                                        Symbol: '';                 Blank: 24; Mode: 2; Scale: 1),
   (Name: 'RTP_Left_Num[1]';             Keys: 'RTP_Left_Num_100_Status[1]|RTP_Left_Num_10_Status[1]|RTP_Left_Num_1_Status[1]|RTP_Left_Num_point1_Status[1]|RTP_Left_Num_point2_Status[1]|RTP_Left_Num_point3_Status[1]';                       Points: 'RTP_Left_Num_point_Status[1]';                                                                        Symbol: '';                 Blank: 24; Mode: 2; Scale: 1),
   (Name: 'RTP_Left_Num[2]';             Keys: 'RTP_Left_Num_100_Status[2]|RTP_Left_Num_10_Status[2]|RTP_Left_Num_1_Status[2]|RTP_Left_Num_point1_Status[2]|RTP_Left_Num_point2_Status[2]|RTP_Left_Num_point3_Status[2]';                       Points: 'RTP_Left_Num_point_Status[2]';                                                                        Symbol: '';                 Blank: 24; Mode: 2; Scale: 1),
   (Name: 'RTP_Right_Num[0]';            Keys: 'RTP_Right_Num_100_Status[0]|RTP_Right_Num_10_Status[0]|RTP_Right_Num_1_Status[0]|RTP_Right_Num_point1_Status[0]|RTP_Right_Num_point2_Status[0]|RTP_Right_Num_point3_Status[0]';                 Points: 'RTP_Right_Num_point_Status[0]';                                                                       Symbol: '';                 Blank: 24; Mode: 2; Scale: 1),
   (Name: 'RTP_Right_Num[1]';            Keys: 'RTP_Right_Num_100_Status[1]|RTP_Right_Num_10_Status[1]|RTP_Right_Num_1_Status[1]|RTP_Right_Num_point1_Status[1]|RTP_Right_Num_point2_Status[1]|RTP_Right_Num_point3_Status[1]';                 Points: 'RTP_Right_Num_point_Status[1]';                                                                       Symbol: '';                 Blank: 24; Mode: 2; Scale: 1),
   (Name: 'RTP_Right_Num[2]';            Keys: 'RTP_Right_Num_100_Status[2]|RTP_Right_Num_10_Status[2]|RTP_Right_Num_1_Status[2]|RTP_Right_Num_point1_Status[2]|RTP_Right_Num_point2_Status[2]|RTP_Right_Num_point3_Status[2]';                 Points: 'RTP_Right_Num_point_Status[2]';                                                                       Symbol: '';                 Blank: 24; Mode: 2; Scale: 1)
  );

 Var
  Removed : TDictionary<String, Boolean>;

 Function FieldName(Const Base, Suffix : String) : String;
  Var
   P : Integer;
  Begin
   P := Pos('[', Base);
   If P = 0 Then
    Result := Base + Suffix
   Else
    Result := Copy(Base, 1, P - 1) + Suffix + Copy(Base, P, MaxInt);
  End;

 Function iFlyDisplayNames : TArray<String>;
  Var
   I : Integer;
  Begin
   SetLength(Result, Length(Defs));
   For I      := 0 To High(Defs) Do
    Result[I] := FieldName(Defs[I].Name, '_Value');
  End;

 Procedure AddiFlyDisplayDefinitions(Definitions : TJSONObject);
  Var
   D : TDisplayDef;
  Begin
   For D In Defs Do
    Begin
     Definitions.AddPair(FieldName(D.Name, '_Value'), 'Assembled display value, not a separate physical measurement. IRS/radio messages may be text. Blank/unknown/test numeric values are null; units follow the display.');
     Definitions.AddPair(FieldName(D.Name, '_Text'), 'Display characters with leading zeroes, spaces and direction letters retained.');
     Definitions.AddPair(FieldName(D.Name, '_DisplayStatus'), 'value, text, encoded_irs, blank, unavailable, decimal_unspecified, invalid or special_or_test.');
     Definitions.AddPair(FieldName(D.Name, '_Codes'), 'Packed hex original digit codes only for blank/unknown/special states; ?? means missing.');
     If D.Points <> '' Then
      Definitions.AddPair(FieldName(D.Name, '_Points'), 'Bit mask of SDK decimal/point indicators; IRS point positions are not interpreted as coordinates.');
    End;
  End;

 Function iFlyCompactField(Const Name : String) : Boolean;
  Begin
   Result := Removed.ContainsKey(Name) Or (Pos('LSKChar[', Name) = 1) Or (Pos('LSK_Color[', Name) = 1) Or (Pos('LSK_SmallFont[', Name) = 1) Or (Pos('CDU_FAIL_Status[', Name) = 1) Or (Pos('CDU_MSG_Status[', Name) = 1) Or (Pos('CDU_EXEC_Status[', Name) = 1) Or (Pos('CDU_CALL_Status[', Name) = 1) Or (Pos('CDU_OFST_Status[', Name) = 1);
  End;

 Function Code(Fields : TJSONObject; Const Key : String) : Integer;
  Var
   V : TJSONValue;
   N : Double;
  Begin
   Result := -1;
   V      := Fields.GetValue(Key);
   If Not(V Is TJSONNumber) Then
    Exit;
   N := TJSONNumber(V).AsDouble;
   If IsNan(N) Or IsInfinite(N) Or (N < 0) Or (N > 255) Or (N <> Trunc(N)) Then
    Exit;
   Result := Trunc(N);
  End;

 Procedure AssembleiFlyDisplays(Fields : TJSONObject; RemoveSegments : Boolean);
  Var
   D       : TDisplayDef;
   Keys    : TArray<String>;
   Points  : TArray<String>;
   Key     : String;
   Text    : String;
   Codes   : String;
   Status  : String;
   I       : Integer;
   C       : Integer;
   Mask    : Integer;
   P       : Integer;
   Count   : Integer;
   Sign    : Integer;
   Missing : Boolean;
   Bad     : Boolean;
   Any     : Boolean;
   Number  : Double;
   FS      : TFormatSettings;
   V       : TJSONValue;

   Procedure Put(Const Suffix : String; Value : TJSONValue);
    Var
     K : String;
    Begin
     K := FieldName(D.Name, Suffix);
     Fields.RemovePair(K).Free;
     Fields.AddPair(K, Value);
    End;

  Begin
   If Fields = Nil Then
    Exit;
   FS                  := TFormatSettings.Create;
   FS.DecimalSeparator := '.';
   For D In Defs Do
    Begin
     Keys := D.Keys.Split(['|']);
     Any  := False;
     For Key In Keys Do
      If Fields.GetValue(Key) <> Nil Then
       Any := True;
     If Not Any Then
      Continue; // Already assembled or an incomplete provider: do not overwrite derived fields.
     Text    := '';
     Codes   := '';
     Bad     := False;
     Missing := False;
     For Key In Keys Do
      Begin
       C := Code(Fields, Key);
       If C < 0 Then
        Begin
         Missing := True;
         Codes   := Codes + '??';
        End
       Else
        Codes := Codes + IntToHex(C, 2);
       If (C >= 0) And (C <= 9) Then
        Text := Text + Char(Ord('0') + C)
       Else If C = D.Blank Then
        Text := Text + ' '
       Else If (D.Mode = 0) And (D.Blank = 11) And (C = 10) Then
        Text := Text + '-'
       Else If (D.Mode = 1) And (C >= 11) And (C <= 17) Then
        Text := Text + Copy('ENSTWMH', C - 10, 1)
       Else If (D.Mode = 2) And (C >= 10) And (C <= 19) Then
        Text := Text + Copy('ADEFILNOPT', C - 9, 1)
       Else
        Begin
         Text := Text + '?';
         Bad  := True;
        End;
      End;
     Mask  := 0;
     P     := 0;
     Count := 0;
     If D.Points <> '' Then
      Begin
       Points := D.Points.Split(['|']);
       For I  := 0 To High(Points) Do
        Begin
         C := Code(Fields, Points[I]);
         If (C <> 0) And (C <> 1) Then
          Missing := True;
         If C = 1 Then
          Begin
           Mask := Mask Or (1 Shl I);
           P    := I + 1;
           Inc(Count);
          End;
        End;
      End;
     If D.Mode = 3 Then
      Insert('.', Text, 4);
     If (D.Mode = 4) And (Count = 1) Then
      Insert('.', Text, P + 1);
     If (D.Mode = 4) And (Count > 1) Then
      Bad := True;
     If (D.Mode = 2) And (Mask = 1) Then
      Insert('.', Text, 4);
     If (D.Mode = 5) And (Mask = 1) Then
      Bad := True; // SDK does not define the Mach decimal position.
     If D.Symbol <> '' Then
      Begin
       Sign := Code(Fields, D.Symbol);
       If Sign = 11 Then
        Text := '-' + Text
       Else If Sign = 12 Then
        Text := '+' + Text
       Else If Sign <> 14 Then
        Bad := True;
      End;
     V      := TJSONNull.Create;
     Status := 'value';
     If Missing Then
      Status := 'unavailable'
     Else If Bad Then
      Status := 'special_or_test'
     Else If Trim(Text) = '' Then
      Status := 'blank'
     Else If D.Mode = 1 Then
      Begin
       V.Free;
       V      := TJSONString.Create(Text);
       Status := 'encoded_irs';
      End
     Else If TryStrToFloat(Trim(Text), Number, FS) And Not IsNan(Number) And Not IsInfinite(Number) Then
      Begin
       V.Free;
       V := TJSONNumber.Create(Number);
      End
     Else If D.Mode = 2 Then
      Begin
       V.Free;
       V      := TJSONString.Create(Text);
       Status := 'text';
      End
     Else
      Status := 'invalid';
     If (D.Mode = 5) And (Mask = 1) And Not Missing Then
      Status := 'decimal_unspecified';
     Put('_Value', V);
     Put('_Text', TJSONString.Create(Text));
     Put('_DisplayStatus', TJSONString.Create(Status));
     If (Status = 'value') Or (Status = 'encoded_irs') Or (Status = 'text') Then
      Put('_Codes', TJSONNull.Create)
     Else
      Put('_Codes', TJSONString.Create(Codes));
     If D.Points <> '' Then
      Begin
       If Missing Then
        Put('_Points', TJSONNull.Create)
       Else
        Put('_Points', TJSONNumber.Create(Mask));
      End;
    End;
   If RemoveSegments Then
    For I := Fields.Count - 1 Downto 0 Do
     If iFlyCompactField(Fields.Pairs[I].JsonString.Value) Then
      Fields.RemovePair(Fields.Pairs[I].JsonString.Value).Free;
  End;

 Procedure CompactiFlySDK(SDK : TJSONObject);
  Var
   V : TJSONValue;
  Begin
   If (SDK = Nil) Or (SDK.GetValue('provider') = Nil) Or (SDK.GetValue('provider').Value <> 'iFly737MAX') Then
    Exit;
   V := SDK.GetValue('fields');
   If V Is TJSONObject Then
    Begin
     AssembleiFlyDisplays(TJSONObject(V), True);
     SDK.RemovePair('representation').Free;
     SDK.AddPair('representation', 'assembled-displays-v1');
    End;
  End;

 Procedure Init;
  Var
   D   : TDisplayDef;
   Key : String;
  Begin
   Removed := TDictionary<String, Boolean>.Create;
   For D In Defs Do
    Begin
     For Key In D.Keys.Split(['|']) Do
      Removed.AddOrSetValue(Key, True);
     If D.Points <> '' Then
      For Key In D.Points.Split(['|']) Do
       Removed.AddOrSetValue(Key, True);
     If D.Symbol <> '' Then
      Removed.AddOrSetValue(D.Symbol, True);
    End;
  End;

Initialization

 Init;

Finalization

 Removed.Free;

End.
