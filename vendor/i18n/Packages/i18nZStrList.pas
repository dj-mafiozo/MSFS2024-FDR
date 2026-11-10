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
/// This unit implements a class to deal with null character separated strings.
/// </summary>
Unit i18nZStrList;

Interface

{$I DELPHIAREA.INC}

 Uses
  SysUtils, Types;

 Type

  {$Region 'xmldoc'}
  /// <summary>
  /// ZStrings provides a set of class methods to work with null character (#0)
  /// separated strings.
  /// </summary>
  {$Endregion}
  ZStrings = Class
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates a list of null separated strings from a specified array of strings.
    /// </summary>
    /// <param name="StrArray">
    /// The source array of strings.
    /// </param>
    /// <returns>
    /// The list of null character separated strings.
    /// </returns>
    {$Endregion}
    Class Function Construct(Const StrArray : Array Of String) : String; Overload; Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates a list of null separated strings from a specified string. The
    /// sub-strings of the source string are delimited by a specified delimiter
    /// string.
    /// </summary>
    /// <param name="Str">
    /// The source string.
    /// </param>
    /// <param name="Delimiter">
    /// The delimiter string that separates sub-strings of the source string.
    /// </param>
    /// <returns>
    /// The list of null character separated strings.
    /// </returns>
    {$Endregion}
    Class Function Construct(Const Str : String; Const Delimiter : String) : String; Overload; Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Adds a sub-string at the end of a specified list of null character
    /// separated strings.
    /// </summary>
    /// <param name="ZStrs">
    /// The null character separated strings.
    /// </param>
    /// <param name="SubStr">
    /// The value for the new sub-string.
    /// </param>
    /// <seealso cref="Insert"/>
    {$Endregion}
    Class Procedure Add(Var ZStrs : String; Const SubStr : String); Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Inserts a sub-string at a specified index of a specified list of null character
    /// separated strings.
    /// </summary>
    /// <param name="ZStrs">
    /// The null character separated strings.
    /// </param>
    /// <param name="Index">
    /// The index where the sub-string must be inserted before.
    /// </param>
    /// <param name="SubStr">
    /// The value for the new sub-string.
    /// </param>
    /// <seealso cref="Add"/>
    {$Endregion}
    Class Procedure Insert(Var ZStrs : String; Index : Integer; Const SubStr : String); Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Deletes a sub-string at a specified index of a specified list of null character
    /// separated strings.
    /// </summary>
    /// <param name="ZStrs">
    /// The null character separated strings.
    /// </param>
    /// <param name="Index">
    /// The index of the sub-string to delete.
    /// </param>
    {$Endregion}
    Class Procedure Delete(Var ZStrs : String; Index : Integer); Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Replaces a sub-string at a specified index of a specified list of null character
    /// separated strings.
    /// </summary>
    /// <param name="ZStrs">
    /// The null character separated strings.
    /// </param>
    /// <param name="Index">
    /// The index of the sub-string to replace.
    /// </param>
    /// <param name="SubStr">
    /// The new value for the sub-string at the specified index.
    /// </param>
    /// <seealso cref="GetSubStrAt"/>
    {$Endregion}
    Class Procedure SetSubStrAt(Var ZStrs : String; Index : Integer; Const SubStr : String); Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the sub-string at a specified index of a specified list of null
    /// character separated strings.
    /// </summary>
    /// <param name="ZStrs">
    /// The null character separated strings.
    /// </param>
    /// <param name="Index">
    /// The index of the sub-string to retrieve.
    /// </param>
    /// <returns>
    /// The sub-string at the specified index.
    /// </returns>
    /// <seealso cref="SetSubStrAt"/>
    {$Endregion}
    Class Function GetSubStrAt(Const ZStrs : String; Index : Integer) : String; Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the number of sub-strings in a specified list of null character
    /// separated strings.
    /// </summary>
    /// <param name="ZStrs">
    /// The null character separated strings.
    /// </param>
    /// <returns>
    /// The number of sub-strings.
    /// </returns>
    {$Endregion}
    Class Function Count(Const ZStrs : String) : Integer; Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts a specified list of null character separated strings to a list
    /// of delimited sub-strings.
    /// </summary>
    /// <param name="ZStrs">
    /// The null character separated strings.
    /// </param>
    /// <param name="Delimiter">
    /// The string that separates sub-strings.
    /// </param>
    /// <returns>
    /// The string of sub-strings delimited by given <paramref name="Delimiter"/>
    /// string.
    /// </returns>
    {$Endregion}
    Class Function Split(Const ZStrs : String; Const Delimiter : String) : String; Overload; Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts a specified list of null character separated strings to an array
    /// of its sub-strings.
    /// </summary>
    /// <param name="ZStrs">
    /// The null character separated strings.
    /// </param>
    /// <returns>
    /// The array of sub-strings.
    /// </returns>
    {$Endregion}
    Class Function Split(Const ZStrs : String) : TStringDynArray; Overload; Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the index of sub-string at a specified character position of a
    /// specified list of null character separated strings.
    /// </summary>
    /// <param name="ZStrs">
    /// The null character separated strings.
    /// </param>
    /// <param name="Pos">
    /// The character position within the null character separated strings.
    /// </param>
    /// <returns>
    /// The zero-based index of sub-strings at the specified character position.
    /// If position given by <paramref name="Pos"/> is less than or equal to zero
    /// or <paramref name="ZStrs"/> is empty, the function returns zero.
    /// </returns>
    {$Endregion}
    Class Function IndexFromCharPos(Const ZStrs : String; Pos : Integer) : Integer; Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the start position of a sub-string specified with its index within
    /// a specified list of null character separated strings.
    /// </summary>
    /// <param name="ZStrs">
    /// The null character separated strings.
    /// </param>
    /// <param name="Index">
    /// The index of the sub-string to find its start position.
    /// </param>
    /// <returns>
    /// The character position of the specified sub-string within the specified
    /// null character separated strings.
    /// </returns>
    {$Endregion}
    Class Function CharPosFromIndex(Const ZStrs : String; Index : Integer) : Integer; Static;
  End;

Implementation

{ ZStrings }

  Class Function ZStrings.Construct(Const StrArray : Array Of String) : String;

 Var
  i   : Integer;
  Len : Integer;
  s   : PChar;

Begin
 Len   := Length(StrArray);
 For i := 0 To Length(StrArray) - 1 Do
  Inc(Len, Length(StrArray[i]));
 SetLength(Result, Len);
 s     := PChar(Result);
 For i := 0 To Length(StrArray) - 1 Do
  Begin
   StrCopy(s, PChar(StrArray[i]));
   Inc(s, Length(StrArray[i]) + 1);
  End;

End;

  Class Function ZStrings.Construct(Const Str, Delimiter : String) : String;

Begin
 If Str = '' Then
  Result := ''
 Else
  Result := StringReplace(Str, Delimiter, #0, [rfReplaceAll]) + #0;

End;

  Class Procedure ZStrings.Add(Var ZStrs : String; Const SubStr : String);

Begin
 ZStrs := ZStrs + SubStr + #0;

End;

  Class Procedure ZStrings.Insert(Var ZStrs : String; Index : Integer; Const SubStr : String);

 Var
  EndPtr : PChar;
  s      : PChar;

Begin
 If Index <= 0 Then
  ZStrs := SubStr + #0 + ZStrs
 Else
  Begin
   s      := PChar(ZStrs);
   EndPtr := s + Length(ZStrs);
   While (Index > 0) And (s < EndPtr) Do
    Begin
     s := StrEnd(s) + 1;
     Dec(Index);
     If Index = 0 Then
      Begin
       System.Insert(#0 + SubStr, ZStrs, s - PChar(ZStrs));
       Exit;
      End;
    End;
   ZStrs := ZStrs + SubStr + #0;
  End;

End;

  Class Procedure ZStrings.Delete(Var ZStrs : String; Index : Integer);

 Var
  EndPtr : PChar;
  s      : PChar;

Begin
 If ZStrs <> '' Then
  Begin
   s      := PChar(ZStrs);
   EndPtr := s + Length(ZStrs);
   While (Index > 0) And (s < EndPtr) Do
    Begin
     Dec(Index);
     s := StrEnd(s) + 1;
    End;
   If Index = 0 Then
    System.Delete(ZStrs, s - PChar(ZStrs) + 1, StrLen(s) + 1);
  End;

End;

  Class Procedure ZStrings.SetSubStrAt(Var ZStrs : String; Index : Integer; Const SubStr : String);

Begin
 ZStrings.Delete(ZStrs, Index);
 ZStrings.Insert(ZStrs, Index, SubStr);

End;

  Class Function ZStrings.GetSubStrAt(Const ZStrs : String; Index : Integer) : String;

 Var
  EndPtr : PChar;
  s      : PChar;

Begin
 s      := PChar(ZStrs);
 EndPtr := s + Length(ZStrs);
 While (Index > 0) And (s < EndPtr) Do
  Begin
   Dec(Index);
   s := StrEnd(s) + 1;
  End;
 SetString(Result, s, StrLen(s));

End;

  Class Function ZStrings.Count(Const ZStrs : String) : Integer;

 Var
  EndPtr : PChar;
  s      : PChar;

Begin
 Result := 0;
 s      := PChar(ZStrs);
 EndPtr := s + Length(ZStrs);
 While s < EndPtr Do
  Begin
   Inc(Result);
   s := StrEnd(s) + 1;
  End;

End;

  Class Function ZStrings.Split(Const ZStrs : String; Const Delimiter : String) : String;

 Var
  EndPtr : PChar;
  s      : PChar;

Begin
 Result := '';
 s      := PChar(ZStrs);
 EndPtr := s + Length(ZStrs);
 While s < EndPtr Do
  Begin
   If Result = '' Then
    Result := String(s)
   Else
    Result := Result + Delimiter + String(s);
   s       := StrEnd(s) + 1;
  End;

End;

  Class Function ZStrings.Split(Const ZStrs : String) : TStringDynArray;

 Var
  s : PChar;
  e : PChar;
  i : Integer;

Begin
 s := PChar(ZStrs);
 SetLength(Result, ZStrings.Count(ZStrs));
 For i := 0 To Length(Result) - 1 Do
  Begin
   e := StrEnd(s);
   SetString(Result[i], s, e - s);
   s := e + 1;
  End;

End;

  Class Function ZStrings.IndexFromCharPos(Const ZStrs : String; Pos : Integer) : Integer;

 Var
  EndPtr : PChar;
  s      : PChar;
  e      : PChar;

Begin
 Result := -1;
 s      := PChar(ZStrs);
 EndPtr := s + Length(ZStrs);
 While (s < EndPtr) And (Pos > 0) Do
  Begin
   e := StrEnd(s);
   Dec(Pos, e - s + 1);
   s := e + 1;
   Inc(Result);
  End;

End;

  Class Function ZStrings.CharPosFromIndex(Const ZStrs : String; Index : Integer) : Integer;

 Var
  EndPtr : PChar;
  s      : PChar;

Begin
 s      := PChar(ZStrs);
 EndPtr := s + Length(ZStrs);
 While (Index > 0) And (s < EndPtr) Do
  Begin
   Dec(Index);
   s := StrEnd(s) + 1;
  End;
 Result := s - PChar(ZStrs) + 1;

End;

End.
