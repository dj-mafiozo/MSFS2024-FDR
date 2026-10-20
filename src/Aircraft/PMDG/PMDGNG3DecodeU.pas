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
   F    : TPMDGField;
   B    : Byte;
   W    : Word;
   SW   : SmallInt;
   D    : Cardinal;
   SD   : Integer;
   V    : Single;
   Text : AnsiString;
   Z    : Integer;
  Begin
   Result := TJSONObject.Create;
   Try
    For i := 0 To PMDGFieldCount - 1 Do
     Begin
      F := PMDGFields[i];
      If (F.Offset + F.Size > Length(Data)) Then
       Begin
        Result.AddPair(F.Name, TJSONNull.Create);
        Continue;
       End;
      If F.Kind = 'text' Then
       Begin
        SetString(Text, PAnsiChar(@Data[F.Offset]), F.Size);
        Z := Pos(#0, String(Text));
        If Z > 0 Then
         SetLength(Text, Z - 1);
        Result.AddPair(F.Name, String(Text));
       End
      Else If (F.Kind = 'u8') Or (F.Kind = 'bool') Then
       Begin
        B := Data[F.Offset];
        If (F.Kind = 'bool') And (B > 1) Then
         Result.AddPair(F.Name, TJSONNull.Create)
        Else
         Result.AddPair(F.Name, TJSONNumber.Create(B));
       End
      Else If F.Kind = 'i16' Then
       Begin
        Move(Data[F.Offset], SW, 2);
        Result.AddPair(F.Name, TJSONNumber.Create(SW));
       End
      Else If F.Kind = 'u16' Then
       Begin
        Move(Data[F.Offset], W, 2);
        Result.AddPair(F.Name, TJSONNumber.Create(W));
       End
      Else If F.Kind = 'i32' Then
       Begin
        Move(Data[F.Offset], SD, 4);
        Result.AddPair(F.Name, TJSONNumber.Create(SD));
       End
      Else If F.Kind = 'u32' Then
       Begin
        Move(Data[F.Offset], D, 4);
        Result.AddPair(F.Name, TJSONNumber.Create(Int64(D)));
       End
      Else If F.Kind = 'f32' Then
       Begin
        Move(Data[F.Offset], V, 4);
        If IsNan(V) Or IsInfinite(V) Then
         Result.AddPair(F.Name, TJSONNull.Create)
        Else
         Result.AddPair(F.Name, TJSONNumber.Create(Double(V)));
       End
      Else
       Result.AddPair(F.Name, TJSONNull.Create);
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
   Rows   : TJSONArray;
   Row    : Integer;
   Col    : Integer;
   Offset : Integer;
   i      : Integer;
   Line   : String;
   Hex    : String;
   B      : Byte;
   Ch     : WideChar;
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
       B      := Data[Offset];
       Ch     := WideChar(B);
       Case B Of
        0 :
         Ch := ' ';
        $A1 :
         Ch := WideChar($2190);
        $A2 :
         Ch := WideChar($2192);
        $A3 :
         Ch := WideChar($2191);
        $A4 :
         Ch := WideChar($2193);
       End;
       Line := Line + Ch;
      End;
     Rows.Add(Line);
    End;
   SetLength(Hex, 1008 * 2);
   For i := 0 To 1007 Do
    Begin
     B              := Data[i];
     Hex[i * 2 + 1] := HexDigits[(B Shr 4) + 1];
     Hex[i * 2 + 2] := HexDigits[(B And 15) + 1];
    End;
   Result.AddPair('raw_cells_hex', Hex);
  End;

End.
