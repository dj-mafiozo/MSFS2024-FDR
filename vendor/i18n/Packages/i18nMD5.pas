{------------------------------------------------------------------------------}
{                                                                              }
{  i18n Package                                                                }
{  Internationalization and Localization for Delphi                            }
{                                                                              }
{ Copyright(c) Kambiz Khojasteh                                              }
{  https://github.com/khojasteh/i18n                                           }
{                                                                              }
{------------------------------------------------------------------------------}

/// <summary>
/// This unit implements MD5 hashing algorithm.
/// </summary>
Unit i18nMD5;

{$I DELPHIAREA.INC}

Interface

 Uses
  Classes, SysUtils, Types;

 Type

  {$Region 'xmldoc'}
  /// <summary>
  /// EMD5Error is the exception class for errors that occur in instances of
  /// the <see cref="TMD5"/> class.
  /// </summary>
  /// <remarks>
  /// EMD5Error is raised when an error occurs in a <see cref="TMD5"/> object. This
  /// exception commonly occurs when an application appends new data to a <see cref="TMD5"/>
  /// object before resetting it.
  /// </remarks>
  /// <seealso cref="TMD5"/>
  {$Endregion}
   EMD5Error = Class(Exception);

 {$Region 'xmldoc'}
 /// <summary>
 /// TMD5 calculates MD5 hash value of data from various data sources.
 /// </summary>
 {$Endregion}

   TMD5 = Class(TObject)
    Private
     Count         : UInt64;                    { message length in bytes }
     Digest        : Array[0..3] Of Cardinal;  { digest buffer }
     Buffer        : Array[0..63] Of Byte;     { accumulate block }
     IsFinalized   : Boolean;
     FaultyPadding : Boolean;
     Function GetValue : String;
     Procedure Process(Const Block);
     Procedure Finalize;
    Public
     {$Region 'xmldoc'}
     /// <summary>
     /// Creates an instance of the TMD5 class.
     /// </summary>
     {$Endregion}
     Constructor Create; Overload;
     {$Region 'xmldoc'}
     /// <summary>
     /// Creates an instance of the TMD5 class with an option for legacy
     /// compatibility.
     /// </summary>
     /// <param name="Legacy">
     /// If set to True, the object uses faulty padding for legacy compatibility.
     /// </param>
     /// <remarks>
     /// Do not use this constructor unless you need to maintain compatibility
     /// with previous versions that used faulty padding.
     /// </remarks>
     {$Endregion}
     Constructor Create(Legacy : Boolean); Overload;
     {$Region 'xmldoc'}
     /// <summary>
     /// Resets the object for appending a new set of data.
     /// </summary>
     {$Endregion}
     Procedure Reset;
     {$Region 'xmldoc'}
     /// <summary>
     /// Appends a specified number of bytes to the MD5 buffer.
     /// </summary>
     /// <param name="Data">
     /// The data to append.
     /// </param>
     /// <param name="Size">
     /// The number of bytes of <paramref name="Data"/> to append.
     /// </param>
     /// <seealso cref="AppendString"/>
     /// <seealso cref="AppendStream"/>
     /// <seealso cref="AppendFile"/>
     {$Endregion}
     Procedure Append(Const Data; Size : Cardinal);
     {$Region 'xmldoc'}
     /// <summary>
     /// Appends characters of a specified string to the MD5 buffer.
     /// </summary>
     /// <param name="Str">
     /// The string to append.
     /// </param>
     /// <seealso cref="Append"/>
     /// <seealso cref="AppendStream"/>
     /// <seealso cref="AppendFile"/>
     {$Endregion}
     Procedure AppendString(Const Str : String); Overload; Inline;
     {$Region 'xmldoc'}
     /// <summary>
     /// Appends characters of a specified AnsiString to the MD5 buffer.
     /// </summary>
     /// <param name="Str">
     /// The string to append.
     /// </param>
     /// <seealso cref="Append"/>
     /// <seealso cref="AppendStream"/>
     /// <seealso cref="AppendFile"/>
     {$Endregion}
     Procedure AppendString(Const Str : AnsiString); Overload; Inline;
     {$Region 'xmldoc'}
     /// <summary>
     /// Appends characters of a specified WideString to the MD5 buffer.
     /// </summary>
     /// <param name="Str">
     /// The string to append.
     /// </param>
     /// <seealso cref="Append"/>
     /// <seealso cref="AppendStream"/>
     /// <seealso cref="AppendFile"/>
     {$Endregion}
     Procedure AppendString(Const Str : WideString); Overload; Inline;
     {$Region 'xmldoc'}
     /// <summary>
     /// Appends content of a specified stream to the MD5 buffer.
     /// </summary>
     /// <param name="Stream">
     /// The stream to append.
     /// </param>
     /// <seealso cref="Append"/>
     /// <seealso cref="AppendString"/>
     /// <seealso cref="AppendFile"/>
     {$Endregion}
     Procedure AppendStream(Stream : TStream);
     {$Region 'xmldoc'}
     /// <summary>
     /// Appends content of a specified file to the MD5 buffer.
     /// </summary>
     /// <param name="FileName">
     /// The path to the file to append.
     /// </param>
     /// <seealso cref="Append"/>
     /// <seealso cref="AppendString"/>
     /// <seealso cref="AppendStream"/>
     {$Endregion}
     Procedure AppendFile(Const FileName : String);
     {$Region 'xmldoc'}
     /// <summary>
     /// Gets the 128-bit MD5 hash value of the previously appended data as a
     /// hexadecimal string.
     /// </summary>
     {$Endregion}
     Property Value : String Read GetValue;
   End;

 {$Region 'xmldoc'}
 /// <summary>
 /// Calculates MD5 hash value of a specified number of bytes.
 /// </summary>
 /// <param name="Data">
 /// The data to calculate its hash value.
 /// </param>
 /// <param name="Size">
 /// The number of bytes of <paramref name="Data"/>.
 /// </param>
 /// <returns>
 /// The hash value as a hexadecimal string.
 /// </returns>
 /// <seealso cref="FileMD5"/>
 {$Endregion}

  Function MD5(Const Data; Size : Integer) : String; Overload;

  {$Region 'xmldoc'}
  /// <summary>
  /// Calculates MD5 hash value of a specified string.
  /// </summary>
  /// <param name="Str">
  /// The string to calculate its hash value.
  /// </param>
  /// <returns>
  /// The hash value as a hexadecimal string.
  /// </returns>
  /// <seealso cref="FileMD5"/>
  {$Endregion}
  Function MD5(Const Str : String) : String; Overload;

  {$Region 'xmldoc'}
  /// <summary>
  /// Calculates MD5 hash value of a specified AnsiString.
  /// </summary>
  /// <param name="Str">
  /// The string to calculate its hash value.
  /// </param>
  /// <returns>
  /// The hash value as a hexadecimal string.
  /// </returns>
  /// <seealso cref="FileMD5"/>
  {$Endregion}
  Function MD5(Const Str : AnsiString) : String; Overload;

  {$Region 'xmldoc'}
  /// <summary>
  /// Calculates MD5 hash value of a specified WideString.
  /// </summary>
  /// <param name="Str">
  /// The string to calculate its hash value.
  /// </param>
  /// <returns>
  /// The hash value as a hexadecimal string.
  /// </returns>
  /// <seealso cref="FileMD5"/>
  {$Endregion}
  Function MD5(Const Str : WideString) : String; Overload;

  {$Region 'xmldoc'}
  /// <summary>
  /// Calculates MD5 hash value of a specified stream.
  /// </summary>
  /// <param name="Stream">
  /// The stream to calculate hash value of its content.
  /// </param>
  /// <returns>
  /// The hash value as a hexadecimal string.
  /// </returns>
  /// <seealso cref="FileMD5"/>
  {$Endregion}
  Function MD5(Stream : TStream) : String; Overload;

  {$Region 'xmldoc'}
  /// <summary>
  /// Calculates MD5 hash value of a specified file.
  /// </summary>
  /// <param name="FileName">
  /// The path to the file that hash value of its content should be calculated.
  /// </param>
  /// <returns>
  /// The hash value as a hexadecimal string.
  /// </returns>
  /// <seealso cref="MD5"/>
  {$Endregion}
  Function FileMD5(Const FileName : String) : String;

 Implementation

  Uses
   Math, i18nUtils;

  Resourcestring
   SResetRequired = 'You must reset the MD5 object before appending new data';
   SInvalidSize = 'Invalid size passed to MD5: %d';

 { Helper Functions }

  Function MD5(Const Data; Size : Integer) : String;
   Begin
    If Not Assigned(@Data) And (Size <> 0) Then
     Raise EMD5Error.CreateResFmt(@SInvalidSize, [Size]);
    If Size < 0 Then
     Raise EMD5Error.CreateResFmt(@SInvalidSize, [Size]);

    With TMD5.Create Do
     Try
      Append(Data, Cardinal(Size));
      Result := Value;
     Finally
      Free;
     End;
  End;

 Function MD5(Const Str : String) : String;
  Begin
   With TMD5.Create Do
    Try
     AppendString(Str);
     Result := Value;
    Finally
     Free;
    End;
  End;

 Function MD5(Const Str : AnsiString) : String;
  Begin
   With TMD5.Create Do
    Try
     AppendString(Str);
     Result := Value;
    Finally
     Free;
    End;
  End;

 Function MD5(Const Str : WideString) : String;
  Begin
   With TMD5.Create Do
    Try
     AppendString(Str);
     Result := Value;
    Finally
     Free;
    End;
  End;

 Function MD5(Stream : TStream) : String;
  Begin
   With TMD5.Create Do
    Try
     AppendStream(Stream);
     Result := Value;
    Finally
     Free;
    End;
  End;

 Function FileMD5(Const FileName : String) : String;
  Begin
   With TMD5.Create Do
    Try
     AppendFile(FileName);
     Result := Value;
    Finally
     Free;
    End;
  End;

{ TMD5 }

 Const
  T : Array[1..64] Of Cardinal = (
  $D76AA478, $E8C7B756, $242070DB, $C1BDCEEE, $F57C0FAF, $4787C62A,
  $A8304613, $FD469501, $698098D8, $8B44F7AF, $FFFF5BB1, $895CD7BE,
  $6B901122, $FD987193, $A679438E, $49B40821, $F61E2562, $C040B340,
  $265E5A51, $E9B6C7AA, $D62F105D, $02441453, $D8A1E681, $E7D3FBC8,
  $21E1CDE6, $C33707D6, $F4D50D87, $455A14ED, $A9E3E905, $FCEFA3F8,
  $676F02D9, $8D2A4C8A, $FFFA3942, $8771F681, $6D9D6122, $FDE5380C,
  $A4BEEA44, $4BDECFA9, $F6BB4B60, $BEBFBC70, $289B7EC6, $EAA127FA,
  $D4EF3085, $04881D05, $D9D4D039, $E6DB99E5, $1FA27CF8, $C4AC5665,
  $F4292244, $432AFF97, $AB9423A7, $FC93A039, $655B59C3, $8F0CCC92,
  $FFEFF47D, $85845DD1, $6FA87E4F, $FE2CE6E0, $A3014314, $4E0811A1,
  $F7537E82, $BD3AF235, $2AD7D2BB, $EB86D391);
  Padding : Array[0..63] Of Byte = (
  $80, $00, $00, $00, $00, $00, $00, $00,
  $00, $00, $00, $00, $00, $00, $00, $00,
  $00, $00, $00, $00, $00, $00, $00, $00,
  $00, $00, $00, $00, $00, $00, $00, $00,
  $00, $00, $00, $00, $00, $00, $00, $00,
  $00, $00, $00, $00, $00, $00, $00, $00,
  $00, $00, $00, $00, $00, $00, $00, $00,
  $00, $00, $00, $00, $00, $00, $00, $00);

 Type
  TBlock = Array[0..15] Of Cardinal;

 Procedure TMD5.Process(Const Block);

   Procedure Set1(Const x : TBlock; Var a, b, c, d : Cardinal; k, s, i : Cardinal); Inline;
    Var
     n : Cardinal;
    Begin
     n := a + x[k] + T[i] + ((b And c) Or (Not b And d));
     a := ((n Shl s) Or (n Shr (32 - s))) + b;
    End;

   Procedure Set2(Const x : TBlock; Var a, b, c, d : Cardinal; k, s, i : Cardinal); Inline;
    Var
     n : Cardinal;
    Begin
     n := a + x[k] + T[i] + ((b And d) Or (c And Not d));
     a := ((n Shl s) Or (n Shr (32 - s))) + b;
    End;

   Procedure Set3(Const x : TBlock; Var a, b, c, d : Cardinal; k, s, i : Cardinal); Inline;
    Var
     n : Cardinal;
    Begin
     n := a + x[k] + T[i] + (b Xor c Xor d);
     a := ((n Shl s) Or (n Shr (32 - s))) + b;
    End;

   Procedure Set4(Const x : TBlock; Var a, b, c, d : Cardinal; k, s, i : Cardinal); Inline;
    Var
     n : Cardinal;
    Begin
     n := a + x[k] + T[i] + (c Xor (b Or Not d));
     a := ((n Shl s) Or (n Shr (32 - s))) + b;
    End;
  Var
   x : TBlock Absolute Block;
   a : Cardinal;
   b : Cardinal;
   c : Cardinal;
   d : Cardinal;

  Begin
   a := Digest[0];
   b := Digest[1];
   c := Digest[2];
   d := Digest[3];
   Set1(x, a, b, c, d, 0, 7, 1);
   Set1(x, d, a, b, c, 1, 12, 2);
   Set1(x, c, d, a, b, 2, 17, 3);
   Set1(x, b, c, d, a, 3, 22, 4);
   Set1(x, a, b, c, d, 4, 7, 5);
   Set1(x, d, a, b, c, 5, 12, 6);
   Set1(x, c, d, a, b, 6, 17, 7);
   Set1(x, b, c, d, a, 7, 22, 8);
   Set1(x, a, b, c, d, 8, 7, 9);
   Set1(x, d, a, b, c, 9, 12, 10);
   Set1(x, c, d, a, b, 10, 17, 11);
   Set1(x, b, c, d, a, 11, 22, 12);
   Set1(x, a, b, c, d, 12, 7, 13);
   Set1(x, d, a, b, c, 13, 12, 14);
   Set1(x, c, d, a, b, 14, 17, 15);
   Set1(x, b, c, d, a, 15, 22, 16);
   Set2(x, a, b, c, d, 1, 5, 17);
   Set2(x, d, a, b, c, 6, 9, 18);
   Set2(x, c, d, a, b, 11, 14, 19);
   Set2(x, b, c, d, a, 0, 20, 20);
   Set2(x, a, b, c, d, 5, 5, 21);
   Set2(x, d, a, b, c, 10, 9, 22);
   Set2(x, c, d, a, b, 15, 14, 23);
   Set2(x, b, c, d, a, 4, 20, 24);
   Set2(x, a, b, c, d, 9, 5, 25);
   Set2(x, d, a, b, c, 14, 9, 26);
   Set2(x, c, d, a, b, 3, 14, 27);
   Set2(x, b, c, d, a, 8, 20, 28);
   Set2(x, a, b, c, d, 13, 5, 29);
   Set2(x, d, a, b, c, 2, 9, 30);
   Set2(x, c, d, a, b, 7, 14, 31);
   Set2(x, b, c, d, a, 12, 20, 32);
   Set3(x, a, b, c, d, 5, 4, 33);
   Set3(x, d, a, b, c, 8, 11, 34);
   Set3(x, c, d, a, b, 11, 16, 35);
   Set3(x, b, c, d, a, 14, 23, 36);
   Set3(x, a, b, c, d, 1, 4, 37);
   Set3(x, d, a, b, c, 4, 11, 38);
   Set3(x, c, d, a, b, 7, 16, 39);
   Set3(x, b, c, d, a, 10, 23, 40);
   Set3(x, a, b, c, d, 13, 4, 41);
   Set3(x, d, a, b, c, 0, 11, 42);
   Set3(x, c, d, a, b, 3, 16, 43);
   Set3(x, b, c, d, a, 6, 23, 44);
   Set3(x, a, b, c, d, 9, 4, 45);
   Set3(x, d, a, b, c, 12, 11, 46);
   Set3(x, c, d, a, b, 15, 16, 47);
   Set3(x, b, c, d, a, 2, 23, 48);
   Set4(x, a, b, c, d, 0, 6, 49);
   Set4(x, d, a, b, c, 7, 10, 50);
   Set4(x, c, d, a, b, 14, 15, 51);
   Set4(x, b, c, d, a, 5, 21, 52);
   Set4(x, a, b, c, d, 12, 6, 53);
   Set4(x, d, a, b, c, 3, 10, 54);
   Set4(x, c, d, a, b, 10, 15, 55);
   Set4(x, b, c, d, a, 1, 21, 56);
   Set4(x, a, b, c, d, 8, 6, 57);
   Set4(x, d, a, b, c, 15, 10, 58);
   Set4(x, c, d, a, b, 6, 15, 59);
   Set4(x, b, c, d, a, 13, 21, 60);
   Set4(x, a, b, c, d, 4, 6, 61);
   Set4(x, d, a, b, c, 11, 10, 62);
   Set4(x, c, d, a, b, 2, 15, 63);
   Set4(x, b, c, d, a, 9, 21, 64);
   Inc(Digest[0], a);
   Inc(Digest[1], b);
   Inc(Digest[2], c);
   Inc(Digest[3], d);
  End;

 Procedure TMD5.Finalize;

 // LegacyInvalidPadding is NOT MD5.
 // It reproduces the historical identifier values produced by early versions
 // of i18n Delphi package for backward compatibility with stored translation keys.

   Procedure LegacyInvalidPadding(Len : Cardinal);
    Var
     Offset : Cardinal;
    Begin
     Offset := Count Mod 64;
     Move(Padding, Buffer[Offset], 64 - Offset);
     Inc(Count, Len);
    End;
  Var
   BitCount : UInt64;
   Mod64    : Cardinal;

  Begin
   // Save the length, in bits, before padding
   BitCount := Count Shl 3;

   // Append the padding
   Mod64 := Cardinal(Count Mod 64);
   If Mod64 < 56 Then
    Append(Padding, 56 - Mod64)
   Else If Not FaultyPadding Then
    Append(Padding, 64 + 56 - Mod64)
   Else
    LegacyInvalidPadding(56 - Mod64);

   // Append the length
   Append(BitCount, 8);
  End;

 Procedure TMD5.Append(Const Data; Size : Cardinal);
  Var
   p                : PByte;
   Offset           : Cardinal;
   RemainingSize    : Cardinal;
   PartialBlockSize : Cardinal;
  Begin
   If IsFinalized Then
    Raise EMD5Error.Create(SResetRequired);

   If Size = 0 Then
    Exit;

   p             := @Data;
   RemainingSize := Size;
   Offset        := Count Mod 64;

   // Update the message length
   Inc(Count, Size);

   // Process an initial partial block
   If Offset <> 0 Then
    Begin
     PartialBlockSize := Min(Size, 64 - Offset);
     Move(p^, Buffer[Offset], PartialBlockSize);
     If Offset + PartialBlockSize < 64 Then
      Exit;

     Process(Buffer[0]);
     Inc(p, PartialBlockSize);
     Dec(RemainingSize, PartialBlockSize);
    End;

   // Process full blocks
   While RemainingSize >= 64 Do
    Begin
     Process(p^);
     Inc(p, 64);
     Dec(RemainingSize, 64);
    End;

   // Save final partial block for future process
   If RemainingSize > 0 Then
    Move(p^, Buffer[0], RemainingSize);
  End;

 Procedure TMD5.AppendString(Const Str : String);
  Begin
   {$IFDEF UNICODE}
   AppendString(WideString(Str));
   {$ELSE}
   AppendString(AnsiString(Str));
   {$ENDIF}
  End;

 Procedure TMD5.AppendString(Const Str : AnsiString);
  Var
   l : Integer;
  Begin
   l := Length(Str);
   If l > 0 Then
    Append(PAnsiChar(Str)^, Cardinal(l) * SizeOf(AnsiChar));
  End;

 Procedure TMD5.AppendString(Const Str : WideString);
  Var
   Utf8Str : AnsiString;
  Begin
   Utf8Str := UTF8Encode(Str);
   AppendString(Utf8Str);
  End;

 Procedure TMD5.AppendStream(Stream : TStream);
  Var
   Bytes     : Array[1..$FF00] Of Byte;
   ByteCount : Integer;
  Begin
   ByteCount := Stream.Read(Bytes, SizeOf(Bytes));
   While ByteCount > 0 Do
    Begin
     Append(Bytes, ByteCount);
     ByteCount := Stream.Read(Bytes, SizeOf(Bytes));
    End;
  End;

 Procedure TMD5.AppendFile(Const FileName : String);
  Var
   Stream : TStream;
  Begin
   Stream := TFileStream.Create(FileName, fmOpenRead Or fmShareDenyWrite);
   Try
    AppendStream(Stream);
   Finally
    Stream.Free;
   End;
  End;

 Procedure TMD5.Reset;
  Begin
   Count       := 0;
   Digest[0]   := $67452301;
   Digest[1]   := $EFCDAB89;
   Digest[2]   := $98BADCFE;
   Digest[3]   := $10325476;
   IsFinalized := False;
  End;

 Function TMD5.GetValue : String;
  Begin
   If Not IsFinalized Then
    Begin
     Finalize;
     IsFinalized := True;
    End;

   Result := HexString(Digest, 16);
  End;

 Constructor TMD5.Create(Legacy : Boolean);
  Begin
   FaultyPadding := Legacy;
   Reset;
  End;

 Constructor TMD5.Create;
  Begin
   Create(False);
  End;

End.
