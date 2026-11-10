{$StackFrames On}
Unit PMDGNG3DecodeU;

Interface

 Uses
  System.SysUtils, System.JSON;

 Function DecodePMDGData(Const Data : TBytes) : TJSONObject;
 Function DecodePMDGCDU(Const Data : TBytes) : TJSONObject;

Implementation

 Uses
  System.Math, PMDGNG3CatalogU;

 Function DecodePMDGData(Const Data : TBytes) : TJSONObject;
  Var
   i    : Integer;
   f    : TPMDGField;
   b    : Byte;
   w    : Word;
   SW   : SmallInt;
   d    : Cardinal;
   SD   : Integer;
   v    : Single;
   Text : AnsiString;
   z    : Integer;
  Begin
   Result := TJSONObject.Create;
   Try
    For i := 0 To PMDGFieldCount - 1 Do
     Begin
      f := PMDGFields[i];
      If (f.Offset + f.Size > Length(Data)) Then
       Begin
        Result.AddPair(f.Name, TJSONNull.Create);
        Continue;
       End;
      If f.Kind = 'text' Then
       Begin
        SetString(Text, PAnsiChar(@Data[f.Offset]), f.Size);
        z := Pos(#0, String(Text));
        If z > 0 Then
         SetLength(Text, z - 1);
        Result.AddPair(f.Name, String(Text));
       End
      Else If (f.Kind = 'u8') Or (f.Kind = 'bool') Then
       Begin
        b := Data[f.Offset];
        If (f.Kind = 'bool') And (b > 1) Then
         Result.AddPair(f.Name, TJSONNull.Create)
        Else
         Result.AddPair(f.Name, TJSONNumber.Create(b));
       End
      Else If f.Kind = 'i16' Then
       Begin
        Move(Data[f.Offset], SW, 2);
        Result.AddPair(f.Name, TJSONNumber.Create(SW));
       End
      Else If f.Kind = 'u16' Then
       Begin
        Move(Data[f.Offset], w, 2);
        Result.AddPair(f.Name, TJSONNumber.Create(w));
       End
      Else If f.Kind = 'i32' Then
       Begin
        Move(Data[f.Offset], SD, 4);
        Result.AddPair(f.Name, TJSONNumber.Create(SD));
       End
      Else If f.Kind = 'u32' Then
       Begin
        Move(Data[f.Offset], d, 4);
        Result.AddPair(f.Name, TJSONNumber.Create(Int64(d)));
       End
      Else If f.Kind = 'f32' Then
       Begin
        Move(Data[f.Offset], v, 4);
        If IsNan(v) Or IsInfinite(v) Then
         Result.AddPair(f.Name, TJSONNull.Create)
        Else
         Result.AddPair(f.Name, TJSONNumber.Create(Double(v)));
       End
      Else
       Result.AddPair(f.Name, TJSONNull.Create);
     End;
   Except
    Result.Free;
    Raise;
   End;
  End;

 Function DecodePMDGCDU(Const Data : TBytes) : TJSONObject;
  Const
   HexDigits : String = '0123456789ABCDEF';
  Var
   Styles     : TJSONArray;
   Appearance : TJSONObject;
   StyleRow   : String;
   ColorCode  : Byte;
   Flags      : Byte;
   Palette    : Array [0..5] Of String;
   Rows       : TJSONArray;
   Row        : Integer;
   Col        : Integer;
   Offset     : Integer;
   i          : Integer;
   Line       : String;
   Hex        : String;
   b          : Byte;
   Ch         : WideChar;
  Begin
   Result := TJSONObject.Create;
   If (Length(Data) < PMDGCDUSize) Or (Data[1008] > 1) Then
    Begin
     Result.AddPair('status', 'unavailable');
     Exit;
    End;
   Result.AddPair('status', 'available');
   Result.AddPair('powered', TJSONBool.Create(Data[1008] <> 0));
   Rows := TJSONArray.Create;
   Result.AddPair('rows', Rows);
   For Row := 0 To 13 Do
    Begin
     Line    := '';
     For Col := 0 To 23 Do
      Begin
       Offset := (Col * 14 + Row) * 3;
       b      := Data[Offset];
       Ch     := WideChar(b);
       Case b Of
        0   : Ch := ' ';
        $A1 : Ch := WideChar($2190);
        $A2 : Ch := WideChar($2192);
        $A3 : Ch := WideChar($2191);
        $A4 : Ch := WideChar($2193);
       End;
       Line := Line + Ch;
      End;
     Rows.Add(Line);
    End;
   SetLength(Hex, 1008 * 2);
   For i := 0 To 1007 Do
    Begin
     b              := Data[i];
     Hex[i * 2 + 1] := HexDigits[(b Shr 4) + 1];
     Hex[i * 2 + 2] := HexDigits[(b And 15) + 1];
    End;
   Result.AddPair('raw_cells_hex', Hex);
   Palette[0] := 'FFFFFF';
   Palette[1] := '00FFFF';
   Palette[2] := '00FF00';
   Palette[3] := 'FF00FF';
   Palette[4] := 'FFBF00';
   Palette[5] := 'FF0000';
   Appearance := TJSONObject.Create;
   Try
    Appearance.AddPair('encoding', 'rgb-flags-v1');
    Styles := TJSONArray.Create;
    Appearance.AddPair('rows', Styles);
    For Row := 0 To 13 Do
     Begin
      StyleRow := '';
      For Col  := 0 To 23 Do
       Begin
        Offset    := (Col * 14 + Row) * 3;
        ColorCode := Data[Offset + 1];
        Flags     := Data[Offset + 2];
        If ColorCode > 5 Then
         ColorCode := 0;
        StyleRow   := StyleRow + Palette[ColorCode] + IntToHex(Flags, 2);
       End;
      Styles.Add(StyleRow);
     End;
    Result.AddPair('style_json', Appearance.ToJSON);
   Finally
    Appearance.Free;
   End;
  End;

End.
