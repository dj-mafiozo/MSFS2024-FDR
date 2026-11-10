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
/// This unit implements classes and functions to parse and decode values from
/// a JSON (JavaScript Object Notation) formatted string.
/// </summary>
Unit i18nJSON;

{$I DELPHIAREA.INC}

Interface

 Uses
  Windows, SysUtils, Classes, Contnrs;

 Type

  {$Region 'xmldoc'}
  /// <summary>
  /// This enumeration type identifies the different types of JSON tokens.
  /// </summary>
  {$Endregion}
  TJSONToken = (
  {$Region 'xmldoc'}
  /// Indicates that the token is a left brace character, which signals the start
  /// of a JSON object.
  {$Endregion}
  T_ObjectBegin,
  {$Region 'xmldoc'}
  /// Indicates that the token is a right brace character, which signals the end
  /// of a JSON object.
  {$Endregion}
  T_ObjectEnd,
  {$Region 'xmldoc'}
  /// Indicates that the token is a left bracket character, which signals
  /// the start of a JSON array.
  {$Endregion}
  T_ArrayBegin,
  {$Region 'xmldoc'}
  /// Indicates that the token is a right bracket character, which signals
  /// the end of a JSON array.
  {$Endregion}
  T_ArrayEnd,
  {$Region 'xmldoc'}
  /// Indicates that the token is a JSON string value enclosed by double
  /// quote characters.
  {$Endregion}
  T_String,
  {$Region 'xmldoc'}
  /// Indicates that the token is a JSON numeric value.
  {$Endregion}
  T_Number,
  {$Region 'xmldoc'}
  /// Indicates that the token is the JSON <c>true</c> value.
  {$Endregion}
  T_True,
  {$Region 'xmldoc'}
  /// Indicates that the token is the JSON <c>false</c> value.
  {$Endregion}
  T_False,
  {$Region 'xmldoc'}
  /// Indicates that the token is the JSON <c>null</c> value.
  {$Endregion}
  T_Null,
  {$Region 'xmldoc'}
  /// Indicates that the token is a comma character.
  {$Endregion}
  T_ItemSeparator,
  {$Region 'xmldoc'}
  /// Indicates that the token is a colon character.
  {$Endregion}
  T_KeyValueSeparator,
  {$Region 'xmldoc'}
  /// Indicates that the token is any whitespace character.
  {$Endregion}
  T_Whitespace,
  {$Region 'xmldoc'}
  /// Indicates that the end of the JSON formatted string has been reached.
  {$Endregion}
  T_EOJ
  );

{$Region 'xmldoc'}
/// <summary>
/// TJSONTokenizer extracts special symbols, reserved words, numerals, and
/// character strings from a JSON string.
/// </summary>
{$Endregion}

  TJSONTokenizer = Class(TObject)
   Private
    fJSON     : String;
    fTokenPtr : PChar;
    fTokenLen : Integer;
    fTokenID  : TJSONToken;
    Function GetToken : String;
    Function GetTokenPos : Integer;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the next JSON token from a specified JSON formatted string.
    /// </summary>
    /// <param name="S">
    /// Pointer to the JSON formatted string. When the method exits, the pointer
    /// moves to the end of current token.
    /// </param>
    /// <returns>
    /// The <see cref="TJSONToken"/> value of the token.
    /// </returns>
    /// <seealso cref="Next"/>
    {$Endregion}
    Class Function GetNextToken(Var s : PChar) : TJSONToken;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the class for tokenizing a specified JSON formatted
    /// string.
    /// </summary>
    /// <param name="JSON">
    /// The JSON formatted string.
    /// </param>
    {$Endregion}
    Constructor Create(Const JSON : String);
    {$Region 'xmldoc'}
    /// <summary>
    /// Updates the properties with the next token.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> if no error occurs and the end of the JSON
    /// formatted string is not reached; otherwise, returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function Next : Boolean;
    {$Region 'xmldoc'}
    /// <summary>
    /// Restarts parsing the JSON formatted string from the beginning.
    /// </summary>
    {$Endregion}
    Procedure Reset;
    {$Region 'xmldoc'}
    /// <summary>
    /// The JSON formatted string that is being parsed.
    /// </summary>
    {$Endregion}
    Property JSON : String Read fJSON;
    {$Region 'xmldoc'}
    /// <summary>
    /// The current token as a string.
    /// </summary>
    {$Endregion}
    Property Token : String Read GetToken;
    {$Region 'xmldoc'}
    /// <summary>
    /// The pointer to the current token within the <see cref="JSON"/> property.
    /// </summary>
    {$Endregion}
    Property TokenPtr : PChar Read fTokenPtr;
    {$Region 'xmldoc'}
    /// <summary>
    /// The character index of the current token in the <see cref="JSON"/> property.
    /// </summary>
    {$Endregion}
    Property TokenPos : Integer Read GetTokenPos;
    {$Region 'xmldoc'}
    /// <summary>
    /// The length of current token in characters.
    /// </summary>
    {$Endregion}
    Property TokenLen : Integer Read fTokenLen;
    {$Region 'xmldoc'}
    /// <summary>
    /// The current token as a <see cref="TJSONToken"/> value.
    /// </summary>
    {$Endregion}
    Property TokenID : TJSONToken Read fTokenID;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TJSONValue represents a JSON value.
/// </summary>
{$Endregion}

    TJSONValue = Class Abstract(TObject)
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts the JSON value represented by the object to a JSON formatted
    /// string.
    /// </summary>
    /// <returns>
    /// The JSON value as a JSON formatted string.
    /// </returns>
    {$Endregion}
    Function GetJSON : String; Virtual; Abstract;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the JSON value as a JSON formatted string.
    /// </summary>
    {$Endregion}
    Property JSON : String Read GetJSON;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TJSONValueNull represents JSON's <c>null</c> value.
/// </summary>
{$Endregion}

  TJSONValueNull = Class(TJSONValue)
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts the JSON's <c>null</c> value represented by the object to a
    /// JSON formatted string.
    /// </summary>
    /// <returns>
    /// The <c>null</c> value as a JSON formatted string.
    /// </returns>
    {$Endregion}
    Function GetJSON : String; Override;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TJSONValueBoolean represents a JSON boolean value.
/// </summary>
{$Endregion}

  TJSONValueBoolean = Class(TJSONValue)
   Private
    fValue : Boolean;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts the JSON boolean value represented by the object to a JSON
    /// formatted string.
    /// </summary>
    /// <returns>
    /// The boolean value as a JSON formatted string.
    /// </returns>
    {$Endregion}
    Function GetJSON : String; Override;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates and initializes an instance of the class.
    /// </summary>
    /// <param name="AValue">
    /// The initial boolean value of the instance.
    /// </param>
    {$Endregion}
    Constructor Create(AValue : Boolean);
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the boolean value represented by the object.
    /// </summary>
    {$Endregion}
    Property Value : Boolean Read fValue Write fValue;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TJSONValueNumber represents a JSON numeric value.
/// </summary>
{$Endregion}

  TJSONValueNumber = Class(TJSONValue)
   Private
    fValue : Extended;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts the JSON numeric value represented by the object to a JSON
    /// formatted string.
    /// </summary>
    /// <returns>
    /// The numeric value as a JSON formatted string.
    /// </returns>
    {$Endregion}
    Function GetJSON : String; Override;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates and initializes an instance of the class.
    /// </summary>
    /// <param name="AValue">
    /// The initial numeric value of the instance.
    /// </param>
    {$Endregion}
    Constructor Create(Const AValue : Extended);
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the numeric value represented by the object.
    /// </summary>
    {$Endregion}
    Property Value : Extended Read fValue Write fValue;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TJSONValueString represents a JSON string value.
/// </summary>
{$Endregion}

  TJSONValueString = Class(TJSONValue)
   Private
    fValue : String;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts the JSON string value represented by the object to a JSON
    /// formatted string.
    /// </summary>
    /// <returns>
    /// The string value as a JSON formatted string.
    /// </returns>
    {$Endregion}
    Function GetJSON : String; Override;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates and initializes an instance of the class.
    /// </summary>
    /// <param name="AValue">
    /// The initial string value of the instance.
    /// </param>
    {$Endregion}
    Constructor Create(Const AValue : String);
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the string value represented by the object.
    /// </summary>
    {$Endregion}
    Property Value : String Read fValue Write fValue;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TJSONValueArray represents a JSON array value.
/// </summary>
{$Endregion}

  TJSONValueArray = Class(TJSONValue)
   Private
    fValues : TObjectList;
    Function GetCount : Integer;
    Procedure SetCount(Value : Integer);
    Function GetValues(Index : Integer) : TJSONValue;
    Procedure SetValues(Index : Integer; Value : TJSONValue);
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts the JSON array value represented by the object to a JSON
    /// formatted string.
    /// </summary>
    /// <returns>
    /// The array value as a JSON formatted string.
    /// </returns>
    {$Endregion}
    Function GetJSON : String; Override;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the class.
    /// </summary>
    {$Endregion}
    Constructor Create;
    {$Region 'xmldoc'}
    /// <summary>
    /// Destroys the instance and releases its allocated memory.
    /// </summary>
    {$Endregion}
    Destructor Destroy; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Adds a new value to the end of the array.
    /// </summary>
    /// <param name="Value">
    /// The JSON value to add to the array.
    /// </param>
    /// <seealso cref="Insert"/>
    {$Endregion}
    Procedure Add(Value : TJSONValue);
    {$Region 'xmldoc'}
    /// <summary>
    /// Adds a new value into a specified position in the array.
    /// </summary>
    /// <param name="Index">
    /// Specifies where to insert the value.
    /// </param>
    /// <param name="Value">
    /// The JSON value to add to the array.
    /// </param>
    /// <seealso cref="Add"/>
    {$Endregion}
    Procedure Insert(Index : Integer; Value : TJSONValue);
    {$Region 'xmldoc'}
    /// <summary>
    /// Removes a value at a specific position from the array.
    /// </summary>
    /// <param name="Index">
    /// Identifies the value to remove by its index in the array.
    /// </param>
    {$Endregion}
    Procedure Delete(Index : Integer);
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the number of values in the array.
    /// </summary>
    {$Endregion}
    Property Count : Integer Read GetCount Write SetCount;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the values in the array.
    /// </summary>
    {$Endregion}
    Property Values[Index : Integer] : TJSONValue Read GetValues Write SetValues; Default;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TJSONValueObject represents a JSON object (key-value pair) value.
/// </summary>
{$Endregion}

  TJSONValueObject = Class(TJSONValue)
   Private
    fValues : TStringList;
    Function GetCount : Integer;
    Function GetNames(Index : Integer) : String;
    Function GetValues(Const Name : String) : TJSONValue;
    Procedure SetValues(Const Name : String; Value : TJSONValue);
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts the JSON object value represented by the object to a JSON
    /// formatted string.
    /// </summary>
    /// <returns>
    /// The object value as a JSON formatted string.
    /// </returns>
    {$Endregion}
    Function GetJSON : String; Override;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the class.
    /// </summary>
    {$Endregion}
    Constructor Create;
    {$Region 'xmldoc'}
    /// <summary>
    /// Destroys the instance and releases its allocated memory.
    /// </summary>
    {$Endregion}
    Destructor Destroy; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether a value with a specified name exists.
    /// </summary>
    /// <param name="Name">
    /// The name that identifies the value to examine.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the value exists, otherwise returns
    /// <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function Exists(Const Name : String) : Boolean;
    {$Region 'xmldoc'}
    /// <summary>
    /// Removes a value with a specified name.
    /// </summary>
    /// <param name="Name">
    /// The name that identifies the value to remove.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the value was removed; returns <see langword="false"/>
    /// if the value was not found.
    /// </returns>
    {$Endregion}
    Function Delete(Const Name : String) : Boolean;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the number of values in the object.
    /// </summary>
    {$Endregion}
    Property Count : Integer Read GetCount;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the names of the values in the object.
    /// </summary>
    {$Endregion}
    Property Names[Index : Integer] : String Read GetNames;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the values of the object by their names.
    /// </summary>
    {$Endregion}
    Property Values[Const Name : String] : TJSONValue Read GetValues Write SetValues; Default;
  End;

{$Region 'xmldoc'}
/// <summary>
/// Converts a JSON formatted string to a <see cref="TJSONValue"/> object.
/// </summary>
/// <param name="JSON">
/// The JSON formatted string.
/// </param>
/// <param name="ErrorPos">
/// The error location within the <paramref name="JSON"/> parameter, in character
/// position.
/// </param>
/// <returns>
/// The <see cref="TJSONValue"/> object or <see langword="nil"/> if an error
/// occurred.
/// </returns>
/// <seealso cref="TJSONValue.JSON"/>
{$Endregion}

 Function DecodeJSON(Const JSON : String; Out ErrorPos : Integer) : TJSONValue; Overload;

 {$Region 'xmldoc'}
 /// <summary>
 /// Converts a JSON formatted string to a <see cref="TJSONValue"/> object.
 /// </summary>
 /// <param name="JSON">
 /// The JSON formatted string.
 /// </param>
 /// <returns>
 /// The <see cref="TJSONValue"/> object or <see langword="nil"/> if an error
 /// occurred.
 /// </returns>
 /// <seealso cref="TJSONValue.JSON"/>
 {$Endregion}
 Function DecodeJSON(Const JSON : String) : TJSONValue; Overload;

Implementation

 Resourcestring
  SInvalidJSONString = 'Invalid JSON string';

{ Local Helper Functions }

 Function StrToNumber(Const Str : String) : Extended;
  Begin
   {$IFDEF COMPILER_XE2_UP}
   With FormatSettings Do
   {$ENDIF}
    If DecimalSeparator <> '.' Then
     Result := StrToFloat(StringReplace(Str, '.', DecimalSeparator, []))
    Else
     Result := StrToFloat(Str)
  End;

 Function NumberToStr(Const Value : Extended) : String;
  Begin
   Result := Format('%g', [Value]);
   {$IFDEF COMPILER_XE2_UP}
   With FormatSettings Do
   {$ENDIF}
    If DecimalSeparator <> '.' Then
     Result := StringReplace(Result, DecimalSeparator, '.', []);
  End;

 Function ToJSONString(Const Str : String) : String;
  Const
   HexDigits : Array[0..15] Of Char = '0123456789ABCDEF';
   Chars8to13 : Array[#$8..#$D] Of Char = 'btnvfr';
  Var
   i      : Integer;
   r      : PChar;
   c, Esc : Char;
  Begin
   {$IFNDEF COMPILER_XE5_UP}
   Esc := #0; // to prevent compiler warning
   {$ENDIF}
   SetString(Result, Nil, 4 * Length(Str) + 2);
   r     := PChar(Result);
   r^    := '"';
   For i := 1 To Length(Str) Do
    Begin
     Inc(r);
     c := Str[i];
     Case c Of
      #$8..#$D :
       Esc := Chars8to13[c];    // -> \b \t \n \v \f \r
      '/' :
       Esc := '/';              // -> \/
      '\' :
       Esc := '\';              // -> \\
      '"' :
       Esc := '"';              // -> \"
     Else
       If c < #$20 Then                   // -> \xHH
        Esc := 'x'
       Else
        Begin
         r^ := c;
         Continue;
        End;
     End;
     r^ := '\';
     Inc(r);
     r^ := Esc;
     If Esc = 'x' Then
      Begin
       Inc(r);
       r^ := HexDigits[Ord(c) Shr 4];
       Inc(r);
       r^ := HexDigits[Ord(c) And $000F];
      End;
    End;
   Inc(r);
   r^ := '"';
   SetLength(Result, r - PChar(Result) + 1);
  End;

 Function FromJSONString(Const Str : String) : String;

   Function GetEscapedChar(Var Index : Integer; MaxLen : Integer) : Char;
    Var
     Count : Integer;
     Value : Word;
    Begin
     Value := 0;
     Count := 0;
     While (Count < MaxLen) And (Index < Length(Str)) Do
      Begin
       Inc(Index);
       Case Str[Index] Of
        '0'..'9' : Value := Value * 16 + Ord(Str[Index]) - Ord('0');
        'A'..'F' : Value := Value * 16 + 10 + Ord(Str[Index]) - Ord('A');
        'a'..'f' : Value := Value * 16 + 10 + Ord(Str[Index]) - Ord('a');
       Else Break;
       End;
       Inc(Count);
      End;
     If Count = 0 Then
      EConvertError.Create(SInvalidJSONString);
     Result := Char(Value);
    End;
  Var
   StrLen, i : Integer;
   r         : PChar;

  Begin
   StrLen := Length(Str);
   If (StrLen >= 2) And (Str[1] = Str[StrLen]) And (Str[1] = '"') Then
    Begin
     SetString(Result, Nil, StrLen - 2);
     r := PChar(Result);
     i := 2;
     While i < StrLen Do
      Begin
       If Str[i] = '\' Then
        Begin
         Inc(i);
         If i = StrLen Then
          EConvertError.Create(SInvalidJSONString);
         Case Str[i] Of
          'r' :
           r^ := #$D;  // carriage return
          'f' :
           r^ := #$C;  // form feed
          'v' :
           r^ := #$B;  // vertical tab
          'n' :
           r^ := #$A;  // line feed
          't' :
           r^ := #$9;  // horizontal tab
          'b' :
           r^ := #$8;  // backspace
          'x' :
           r^ := GetEscapedChar(i, 2);
          'u' :
           r^ := GetEscapedChar(i, 4);
         Else
           r^ := Str[i];
         End;
        End
       Else
        r^ := Str[i];
       Inc(r);
       Inc(i);
      End;
     SetLength(Result, r - PChar(Result));
    End
   Else
    Result := Str;
  End;

{ Global Helper Functions }

 Function DecodeJSON(Const JSON : String; Out ErrorPos : Integer) : TJSONValue; Overload;

   Function DecodeValue(Tokenizer : TJSONTokenizer) : TJSONValue;
    Var
     Name       : String;
     ChildValue : TJSONValue;
     Failed     : Boolean;
    Begin
     Case Tokenizer.TokenID Of
      T_ObjectBegin :
       Begin
        Result := TJSONValueObject.Create;
        Repeat
         Failed := True;
         Tokenizer.Next;
         If Tokenizer.TokenID = T_String Then
          Begin
           Name := FromJSONString(Tokenizer.Token);
           Tokenizer.Next;
           If Tokenizer.TokenID = T_KeyValueSeparator Then
            Begin
             Tokenizer.Next;
             ChildValue := DecodeValue(Tokenizer);
             If Assigned(ChildValue) Then
              Begin
               TJSONValueObject(Result).Values[Name] := ChildValue;
               Failed                                := False;
              End;
            End;
          End;
        Until Failed Or (Tokenizer.TokenID <> T_ItemSeparator);
        If Not Failed And (Tokenizer.TokenID = T_ObjectEnd) Then
         Tokenizer.Next
        Else
         FreeAndNil(Result);
       End;
      T_ArrayBegin :
       Begin
        Result := TJSONValueArray.Create;
        Repeat
         Failed := True;
         Tokenizer.Next;
         ChildValue := DecodeValue(Tokenizer);
         If Assigned(ChildValue) Then
          Begin
           TJSONValueArray(Result).Add(ChildValue);
           Failed := False;
          End;
        Until Failed Or (Tokenizer.TokenID <> T_ItemSeparator);
        If Not Failed And (Tokenizer.TokenID = T_ArrayEnd) Then
         Tokenizer.Next
        Else
         FreeAndNil(Result);
       End;
      T_String :
       Begin
        Result := TJSONValueString.Create(FromJSONString(Tokenizer.Token));
        Tokenizer.Next;
       End;
      T_Number :
       Begin
        Result := TJSONValueNumber.Create(StrToNumber(Tokenizer.Token));
        Tokenizer.Next;
       End;
      T_True :
       Begin
        Result := TJSONValueBoolean.Create(True);
        Tokenizer.Next;
       End;
      T_False :
       Begin
        Result := TJSONValueBoolean.Create(False);
        Tokenizer.Next;
       End;
      T_Null :
       Begin
        Result := TJSONValueNull.Create;
        Tokenizer.Next;
       End;
     Else
       Result := Nil;
     End;
    End;
  Var
   Tokenizer : TJSONTokenizer;

  Begin
   Tokenizer := TJSONTokenizer.Create(JSON);
   Try
    Try
     Result := DecodeValue(Tokenizer);
    Except
     // Ignore exceptions
    End;
    If Assigned(Result) And (Tokenizer.TokenID <> T_EOJ) Then
     FreeAndNil(Result);
    If Not Assigned(Result) Then
     ErrorPos := Tokenizer.TokenPos
    Else
     ErrorPos := 0;
   Finally
    Tokenizer.Free;
   End;
  End;

 Function DecodeJSON(Const JSON : String) : TJSONValue;
  Var
   ErrorPos : Integer;
  Begin
   Result := DecodeJSON(JSON, ErrorPos);
  End;

{ TJSONTokenizer }

 Constructor TJSONTokenizer.Create(Const JSON : String);
  Begin
   fJSON := JSON;
   Reset;
  End;

 Function TJSONTokenizer.GetToken : String;
  Begin
   If fTokenID <> T_EOJ Then
    SetString(Result, fTokenPtr, fTokenLen)
   Else
    Result := '';
  End;

 Function TJSONTokenizer.GetTokenPos : Integer;
  Begin
   Result := fTokenPtr - PChar(fJSON) + 1;
  End;

  Class Function TJSONTokenizer.GetNextToken(Var s : PChar) : TJSONToken;

 Var
  p : PChar;

Begin
 Result := T_EOJ;
 Case s^Of
  #9, #10, #13, #32 :                             // white space
   Begin
    Repeat
     Inc(s);
    Until Not CharInSet(s^, [#9, #10, #13, #32]);
    Result := T_Whitespace;
   End;
  ',' :                                           // comma
   Begin
    Inc(s);
    Result := T_ItemSeparator;
   End;
  ':' :                                           // colon
   Begin
    Inc(s);
    Result := T_KeyValueSeparator;
   End;
  '{' :                                           // object begin
   Begin
    Inc(s);
    Result := T_ObjectBegin;
   End;
  '}' :                                           // object end
   Begin
    Inc(s);
    Result := T_ObjectEnd;
   End;
  '[' :                                           // array begin
   Begin
    Inc(s);
    Result := T_ArrayBegin;
   End;
  ']' :                                           // array end
   Begin
    Inc(s);
    Result := T_ArrayEnd;
   End;
  '"' :                                           // string
   Begin
    Repeat
     Inc(s);
    Until((s^ = '"') And ((s - 1)^ <> '\')) Or (s^ = #0);
    If s^ <> #0 Then
     Begin
      Inc(s);
      Result := T_String;
     End
   End;
  '-', '+', '0'..'9' :                            // number
   Begin
    If s^ = '-' Then
     Begin
      Inc(s);
      If Not CharInSet(s^, ['0'..'9']) Then
       Exit;
     End;
    Repeat
     Inc(s);
    Until Not CharInSet(s^, ['0'..'9']);
    If s^ = '.' Then
     Begin
      Inc(s);
      If Not CharInSet(s^, ['0'..'9']) Then
       Exit;
      Repeat
       Inc(s);
      Until Not CharInSet(s^, ['0'..'9']);
     End;
    If CharInSet(s^, ['E', 'e']) Then
     Begin
      Inc(s);
      If CharInSet(s^, ['+', '-']) Then
       Inc(s);
      If Not CharInSet(s^, ['0'..'9']) Then
       Exit;
      Repeat
       Inc(s);
      Until Not CharInSet(s^, ['0'..'9'])
     End;
    Result := T_Number;
   End;
  'n', 't', 'f' :                                 // null, true, false
   Begin
    p := s;
    Repeat
     Inc(s);
    Until Not CharInSet(s^, ['a'..'z']);
    If AnsiStrLComp(p, 'null', s - p) = 0 Then
     Result := T_Null
    Else If AnsiStrLComp(p, 'true', s - p) = 0 Then
     Result := T_True
    Else If AnsiStrLComp(p, 'false', s - p) = 0 Then
     Result := T_False;
   End;
 End;

End;

 Function TJSONTokenizer.Next : Boolean;
  Var
   s : PChar;
  Begin
   Repeat
    Inc(fTokenPtr, fTokenLen);
    s         := fTokenPtr;
    fTokenID  := GetNextToken(s);
    fTokenLen := s - fTokenPtr;
   Until(fTokenID <> T_Whitespace);
   Result := (fTokenID <> T_EOJ);
  End;

 Procedure TJSONTokenizer.Reset;
  Begin
   fTokenPtr := PChar(fJSON);
   fTokenLen := 0;
   Next;
  End;

{ TJSONValueNull }

 Function TJSONValueNull.GetJSON : String;
  Begin
   Result := 'null';
  End;

{ TJSONValueBoolean }

 Constructor TJSONValueBoolean.Create(AValue : Boolean);
  Begin
   fValue := AValue;
  End;

 Function TJSONValueBoolean.GetJSON : String;
  Begin
   If Value Then
    Result := 'true'
   Else
    Result := 'false';
  End;

{ TJSONValueNumber }

 Constructor TJSONValueNumber.Create(Const AValue : Extended);
  Begin
   fValue := AValue;
  End;

 Function TJSONValueNumber.GetJSON : String;
  Begin
   Result := NumberToStr(Value);
  End;

{ TJSONValueString }

 Constructor TJSONValueString.Create(Const AValue : String);
  Begin
   fValue := AValue;
  End;

 Function TJSONValueString.GetJSON : String;
  Begin
   Result := ToJSONString(Value);
  End;

{ TJSONValueArray }

 Constructor TJSONValueArray.Create;
  Begin
   fValues             := TObjectList.Create;
   fValues.OwnsObjects := True;
  End;

 Destructor TJSONValueArray.Destroy;
  Begin
   fValues.Free;
   Inherited Destroy;
  End;

 Function TJSONValueArray.GetJSON : String;
  Var
   i : Integer;
  Begin
   Result := '[';
   For i  := 0 To Count - 1 Do
    Begin
     If i > 0 Then
      Result := Result + ', ';
     Result  := Result + Values[i].JSON;
    End;
   Result := Result + ']';
  End;

 Function TJSONValueArray.GetCount : Integer;
  Begin
   Result := fValues.Count;
  End;

 Procedure TJSONValueArray.SetCount(Value : Integer);
  Begin
   If Value < 0 Then
    Value := 0;
   While fValues.Count > Value Do
    fValues.Delete(fValues.Count - 1);
   While fValues.Count < Value Do
    fValues.Add(TJSONValueNull.Create);
  End;

 Function TJSONValueArray.GetValues(Index : Integer) : TJSONValue;
  Begin
   Result := TJSONValue(fValues[Index]);
  End;

 Procedure TJSONValueArray.SetValues(Index : Integer; Value : TJSONValue);
  Begin
   fValues[Index] := Value;
  End;

 Procedure TJSONValueArray.Add(Value : TJSONValue);
  Begin
   fValues.Add(Value);
  End;

 Procedure TJSONValueArray.Insert(Index : Integer; Value : TJSONValue);
  Begin
   fValues.Insert(Index, Value);
  End;

 Procedure TJSONValueArray.Delete(Index : Integer);
  Begin
   fValues.Delete(Index);
  End;

{ TJSONValueObject }

 Constructor TJSONValueObject.Create;
  Begin
   fValues               := TStringList.Create;
   fValues.OwnsObjects   := True;
   fValues.CaseSensitive := True;
   fValues.Duplicates    := dupIgnore;
   fValues.Sorted        := True;
  End;

 Destructor TJSONValueObject.Destroy;
  Begin
   fValues.Free;
   Inherited Destroy;
  End;

 Function TJSONValueObject.GetJSON : String;
  Var
   i : Integer;
  Begin
   Result := '{';
   For i  := 0 To Count - 1 Do
    Begin
     If i > 0 Then
      Result := Result + ', ';
     Result  := Result + ToJSONString(fValues.Strings[i]) + ': '
     + TJSONValue(fValues.Objects[i]).JSON;
    End;
   Result := Result + '}';
  End;

 Function TJSONValueObject.GetCount : Integer;
  Begin
   Result := fValues.Count;
  End;

 Function TJSONValueObject.GetNames(Index : Integer) : String;
  Begin
   Result := fValues[Index];
  End;

 Function TJSONValueObject.GetValues(Const Name : String) : TJSONValue;
  Var
   Index : Integer;
  Begin
   Index := fValues.IndexOf(Name);
   If Index < 0 Then
    Index := fValues.AddObject(Name, TJSONValueNull.Create);
   Result := TJSONValue(fValues.Objects[Index]);
  End;

 Procedure TJSONValueObject.SetValues(Const Name : String; Value : TJSONValue);
  Var
   Index : Integer;
  Begin
   Index := fValues.IndexOf(Name);
   If Index < 0 Then
    fValues.AddObject(Name, Value)
   Else
    fValues.Objects[Index] := Value;
  End;

 Function TJSONValueObject.Exists(Const Name : String) : Boolean;
  Begin
   Result := (fValues.IndexOf(Name) >= 0);
  End;

 Function TJSONValueObject.Delete(Const Name : String) : Boolean;
  Var
   Index : Integer;
  Begin
   Result := False;
   Index  := fValues.IndexOf(Name);
   If Index >= 0 Then
    Begin
     fValues.Delete(Index);
     Result := True;
    End;
  End;

End.
