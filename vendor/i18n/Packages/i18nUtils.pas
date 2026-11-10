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
/// This unit implements some utility functions.
/// </summary>
Unit i18nUtils;

{$I DELPHIAREA.INC}

Interface

 Uses
  Windows, SysUtils, Classes, Variants, SyncObjs, i18nCore, i18nUnicode;

{$Region 'xmldoc'}
/// <summary>
/// Extracts the component name from a specified property path.
/// </summary>
/// <param name="PropertyPath">
/// The full path of the property.
/// </param>
/// <returns>
/// The name of component that owns the property.
/// </returns>
{$Endregion}

 Function ExtractComponentName(Const PropertyPath : String) : String;

 {$Region 'xmldoc'}
 /// <summary>
 /// Expands environment-variable strings and replaces them with their defined
 /// values.
 /// </summary>
 /// <param name="Str">
 /// The string that might contain references to environment-variable strings of
 /// the form: <c>%variableName%</c>.</param>
 /// <returns>
 /// The string with its environment variables replaced with the current
 /// values of those environment variables.
 /// </returns>
 {$Endregion}
 Function ExpandEnvStr(Const Str : String) : String;

 {$Region 'xmldoc'}
 /// <summary>
 /// Escapes all whitespace characters, except blank, in a specified string
 /// using backslash escapes.
 /// </summary>
 /// <param name="Str">
 /// The string to be escaped.
 /// </param>
 /// <returns>
 /// The escaped string.
 /// </returns>
 /// <seealso cref="UnescapeString"/>
 {$Endregion}
 Function EscapeString(Const Str : String) : String;

 {$Region 'xmldoc'}
 /// <summary>
 /// Unescapes a specified string that was previously escaped using
 /// <see cref="EscapeString"/> function.
 /// </summary>
 /// <param name="Str">
 /// The source string.
 /// </param>
 /// <returns>
 /// The string as normal.
 /// </returns>
 /// <exception cref="EConvertError">
 /// Occurs if the source string contains invalid escaped characters.
 /// </exception>
 /// <seealso cref="EscapeString"/>
 {$Endregion}
 Function UnescapeString(Const Str : String) : String;

 {$Region 'xmldoc'}
 /// <summary>
 /// Calculates Damerau-Levenshtein distance between two specified strings.
 /// </summary>
 /// <remarks>
 /// <para>
 /// The Damerau-Levenshtein distance (named after Frederick J. Damerau and Vladimir I.
 /// Levenshtein) is a "distance" (string metric) between two strings, i.e., finite
 /// sequence of symbols, given by counting the minimum number of operations needed
 /// to transform one string into the other, where an operation is defined as an
 /// insertion, deletion, or substitution of a single character, or a transposition
 /// of two adjacent characters.
 /// </para>
 /// </remarks>
 /// <param name="Str1">
 /// The first string.
 /// </param>
 /// <param name="Str2">
 /// The second string.
 /// </param>
 /// <returns>
 /// The Damerau-Levenshtein distance.
 /// </returns>
 /// <seealso cref="StringSimilarityRatio"/>
 /// <seealso cref="TextSimilarityRatio"/>
 {$Endregion}
 Function DamerauLevenshteinDistance(Const Str1, Str2 : String) : Integer;

 {$Region 'xmldoc'}
 /// <summary>
 /// Calculates the ratio that determines how much two specified strings are
 /// similar. The comparison is case sensitive.
 /// </summary>
 /// <param name="Str1">
 /// The first string.
 /// </param>
 /// <param name="Str2">
 /// The second string.
 /// </param>
 /// <returns>
 /// The similarity ratio in range 0 to 1, where 0 means not similar at all and
 /// 1 means identical.
 /// </returns>
 /// <seealso cref="DamerauLevenshteinDistance"/>
 /// <seealso cref="TextSimilarityRatio"/>
 {$Endregion}
 Function StringSimilarityRatio(Const Str1, Str2 : String) : Double;

 {$Region 'xmldoc'}
 /// <summary>
 /// Calculates the ratio that determines how much two specified strings are
 /// similar. The comparison is case insensitive.
 /// </summary>
 /// <param name="Str1">
 /// The first string.
 /// </param>
 /// <param name="Str2">
 /// The second string.
 /// </param>
 /// <returns>
 /// The similarity ratio in range 0 to 1, where 0 means not similar at all and
 /// 1 means identical (ignoring case of letters).
 /// </returns>
 /// <seealso cref="DamerauLevenshteinDistance"/>
 /// <seealso cref="StringSimilarityRatio"/>
 {$Endregion}
 Function TextSimilarityRatio(Const Str1, Str2 : String) : Double; Inline;

 {$Region 'xmldoc'}
 /// <summary>
 /// Substitutes the native digits of a source language with native digits of
 /// another language, in a specified string.
 /// </summary>
 /// <param name="Str">
 /// The string to substitute its digits.
 /// </param>
 /// <param name="FromCulture">
 /// The <see cref="TCultureInfo"/> object that specifies the source language.
 /// </param>
 /// <param name="ToCulture">
 /// The <see cref="TCultureInfo"/> object that specifies the target language.
 /// </param>
 /// <returns>
 /// The string that its digits are substituted.
 /// </returns>
 {$Endregion}
 Function TranslateDigits(Const Str : String; FromCulture, ToCulture : TCultureInfo) : String;

 {$Region 'xmldoc'}
 /// <summary>
 /// Converts a specified value using a format string.
 /// </summary>
 /// <remarks>
 /// <para>
 /// FormatValue formats the value given by <paramref name="Value"/> using the format
 /// specifier given by <paramref name="Fmt"/>.
 /// </para>
 /// <para>
 /// The format specifiers for datetime values and numeric values respectively correspond
 /// to the Fmt parameters of <see cref="TCalendar.Format"/> and <see cref="TCultureInfo.FormatNumber"/>
 /// methods. In addition, there are some extra format specifiers for numeric values:
 /// </para>
 ///
 /// <list type="table">
 ///   <listheader>
 ///     <term>Format Specifier</term>
 ///     <description>Name</description>
 ///     <description>Description</description>
 ///   </listheader>
 ///   <item>
 ///     <term>C or c</term>
 ///     <description>Currency</description>
 ///     <description>
 ///     <para>
 ///     The number is converted to a string that represents a currency amount. The conversion is
 ///     controlled by the currency format information of the <paramref name="Culture"/> parameter
 ///     or the current locale's settings.
 ///     </para>
 ///     <para>
 ///     The precision specifier indicates the desired number of decimal places. If the precision
 ///     specifier is omitted, the default currency precision given by the <paramref name="Culture"/>
 ///     parameter or the current locale's settings is used.
 ///     </para>
 ///     <example>
 ///     The following example formats a floating point value with the currency format specifier.
 ///     <code>
 ///     value := 12345.6789;
 ///     a := FormatValue('C', value);  // $12345.68
 ///     b := FormatValue('C3', value); // $12345.679
 ///     </code>
 ///     </example>
 ///     </description>
 ///   </item>
 ///   <item>
 ///     <term>D or d</term>
 ///     <description>Decimal</description>
 ///     <description>
 ///     <para>
 ///     This format is supported only for integral types. The number is converted to a string of
 ///     decimal digits (0-9), prefixed by a minus sign if the number is negative.
 ///     </para>
 ///     <para>
 ///     The precision specifier indicates the minimum number of digits desired in the resulting
 ///     string. If required, the number is padded with zeros to its left to produce the number
 ///     of digits given by the precision specifier.
 ///     </para>
 ///     <example>
 ///     The following example formats an integer value with the decimal format specifier.
 ///     <code>
 ///     value := 12345;
 ///     a := FormatValue('D', value);  // 12345
 ///     b := FormatValue('D8', value); // 00012345
 ///
 ///     value := -12345;
 ///     c := FormatValue('D', value);  // -12345
 ///     d := FormatValue('D8', value); // -00012345
 ///     </code>
 ///     </example>
 ///     </description>
 ///   </item>
 ///   <item>
 ///     <term>E or e</term>
 ///     <description>Scientific (Exponential)</description>
 ///     <description>
 ///     <para>
 ///     The number is converted to a string of the form "-d.ddd...E+ddd" or "-d.ddd...e+ddd",
 ///     where each 'd' indicates a digit (0-9). The string starts with a minus sign if the number
 ///     is negative. One digit always precedes the decimal point.
 ///     </para>
 ///     <para>
 ///     The precision specifier indicates the desired number of digits after the decimal point. If
 ///     the precision specifier is omitted, a default of six digits after the decimal point is used.
 ///     </para>
 ///     <para>
 ///     The case of the format specifier indicates whether to prefix the exponent with an 'E' or an
 ///     'e'. The exponent always consists of a plus or minus sign and a minimum of three digits. The
 ///     exponent is padded with zeros to meet this minimum, if required.
 ///     </para>
 ///     <example>
 ///     The following example formats a floating point value with the scientific format specifier.
 ///     <code>
 ///     value := 12345.6789;
 ///     a := FormatValue('E', value);   // 1.234568E+004
 ///     b := FormatValue('E10', value); // 1.2345678900E+004
 ///     c := FormatValue('e4', value);  // 1.2346e+004
 ///     </code>
 ///     </example>
 ///     </description>
 ///   </item>
 ///   <item>
 ///     <term>F or f</term>
 ///     <description>Fixed-point</description>
 ///     <description>
 ///     <para>
 ///     The number is converted to a string of the form "-ddd.ddd..." where each 'd' indicates a
 ///     digit (0-9). The string starts with a minus sign if the number is negative.
 ///     </para>
 ///     <para>
 ///     The precision specifier indicates the desired number of decimal places. If the precision
 ///     specifier is omitted, the default numeric precision is given by the <paramref name="Culture"/>
 ///     parameter or the current locale's settings.
 ///     </para>
 ///     <example>
 ///     The following example formats a floating point value with the fixed-point format specifier.
 ///     <code>
 ///     value := 12345.6789;
 ///     a := FormatValue('F', value);   // 12345.68
 ///     b := FormatValue('F3', value);  // 12345.679
 ///     c := FormatValue('F0', value);  // 12346
 ///     </code>
 ///     </example>
 ///     </description>
 ///   </item>
 ///   <item>
 ///     <term>G or g</term>
 ///     <description>General</description>
 ///     <description>
 ///     <para>
 ///     The number is converted to the most compact of either fixed-point or scientific notation,
 ///     depending on the type of the number and whether a precision specifier is present. If the
 ///     precision specifier is omitted or zero, the type of the number determines the default
 ///     precision.
 ///     </para>
 ///     <para>
 ///     Fixed-point notation is used if the exponent that would result from expressing the number
 ///     in scientific notation is greater than -5 and less than the precision specifier; otherwise,
 ///     scientific notation is used. The result contains a decimal point if required and trailing
 ///     zeroes are omitted. If the precision specifier is present and the number of significant
 ///     digits in the result exceeds the specified precision, then the excess trailing digits are
 ///     removed by rounding.
 ///     </para>
 ///     <para>
 ///     The exception to the preceding rule is if the number is a decimal and the precision specifier
 ///     is omitted. In that case, fixed-point notation is always used and trailing zeroes are preserved.
 ///     </para>
 ///     <para>
 ///     If scientific notation is used, the exponent in the result is prefixed with 'E' if the format
 ///     specifier is 'G', or 'e' if the format specifier is 'g'.
 ///     </para>
 ///     <example>
 ///     The following example formats assorted integer and floating point values with the general
 ///     format specifier.
 ///     <code>
 ///     value := 12345.6789;
 ///     a := FormatValue('G', value);   // 12345.6789
 ///     b := FormatValue('G7', value);  // 12345.68
 ///
 ///     value := 0.0000023;
 ///     c := FormatValue('G', value);   // 2.3E-006
 ///
 ///     value := 0.0023;
 ///     d := FormatValue('G', value);   // 0.0023
 ///
 ///     value := 1234;
 ///     e := FormatValue('G2', value);  // 1.2E003
 ///
 ///     value := PI;
 ///     f := FormatValue('G5', value);  // 3.1416
 ///     </code>
 ///     </example>
 ///     </description>
 ///   </item>
 ///   <item>
 ///     <term>N or n</term>
 ///     <description>Number</description>
 ///     <description>
 ///     <para>
 ///     The number is converted to a string of the form "-d,ddd,ddd.ddd...", where '-' indicates a negative
 ///     number symbol if required, 'd' indicates a digit (0-9), ',' indicates a thousand separator between
 ///     number groups, and '.' indicates a decimal point symbol. The actual negative number pattern, number
 ///     group size, thousand separator, and decimal separator are specified by the <paramref name="Culture"/>
 ///     parameter or the current locale's settings.
 ///     </para>
 ///     <para>
 ///     The precision specifier indicates the desired number of decimal places. If the precision specifier
 ///     is omitted, the default numeric precision is given by the <paramref name="Culture"/> parameter
 ///     or the current locale's settings.
 ///     </para>
 ///     <example>
 ///     The following example formats a floating point and an integer value with the number format specifier.
 ///     <code>
 ///     value := -12345.6789;
 ///     a := FormatValue('N', value);   // -12,345.68
 ///     b := FormatValue('N1', value);  // -12,345.7
 ///
 ///     value := 123456789;
 ///     c := FormatValue('N', value);   // 123,456,789.00
 ///     d := FormatValue('N0', value);  // 123,456,789
 ///     </code>
 ///     </example>
 ///     </description>
 ///   </item>
 ///   <item>
 ///     <term>P or p</term>
 ///     <description>Percent</description>
 ///     <description>
 ///     <para>
 ///     The number is converted to a string that represents a percent. The converted number is multiplied
 ///     by 100 in order to be presented as a percentage. The percent sign and its location is determined
 ///     by the <paramref name="Culture"/> parameter or the current locale's settings.
 ///     </para>
 ///     <para>
 ///     The precision specifier indicates the desired number of decimal places. If the precision specifier
 ///     is omitted, the default numeric precision given by the <paramref name="Culture"/> parameter or the
 ///     current locale's settings is used.
 ///     </para>
 ///     <example>
 ///     The following example formats a floating point value with the percent format specifier.
 ///     <code>
 ///     value := 0.2468013;
 ///     a := FormatValue('P', value);   // 24.68%
 ///     b := FormatValue('P1', value);  // 24.7%
 ///     </code>
 ///     </example>
 ///     </description>
 ///   </item>
 ///   <item>
 ///     <term>X or x</term>
 ///     <description>Hexadecimal</description>
 ///     <description>
 ///     <para>
 ///     This format is supported only for integer values. The number is converted to a string of hexadecimal
 ///     digits. The case of the format specifier indicates whether to use uppercase or lowercase characters
 ///     for the hexadecimal digits greater than 9. For example, use 'X' to produce "ABCDEF", and 'x' to produce
 ///     "abcdef".
 ///     </para>
 ///     <para>
 ///     The precision specifier indicates the minimum number of digits desired in the resulting string. If
 ///     required, the number is padded with zeros to its left to produce the number of digits given by the
 ///     precision specifier.
 ///     </para>
 ///     <example>
 ///     The following example formats various integer values with the hexadecimal format specifier.
 ///     <code>
 ///     value := $2045e;
 ///     a := FormatValue('X', value);    // 2045E
 ///     b := FormatValue('X8', value);   // 0002045E
 ///
 ///     value := 123456789;
 ///     c := FormatValue('X', value);    // 75BCD15
 ///     d := FormatValue('X2', value);   // 75BCD15
 ///     e := FormatValue('x10', value);  // 00075bcd15
 ///     </code>
 ///     </example>
 ///     </description>
 ///   </item>
 ///   <item>
 ///     <term>B or b</term>
 ///     <description>Binary</description>
 ///     <description>
 ///     <para>
 ///     This format is supported only for integer values. The number is converted to a string of binary
 ///     digits.
 ///     </para>
 ///     <para>
 ///     The precision specifier indicates the minimum number of digits desired in the resulting string.
 ///     If required, the number is padded with zeros to its left to produce the number of digits given
 ///     by the precision specifier.
 ///     </para>
 ///     <example>
 ///     The following example formats various integer values with the binary format specifier.
 ///     <code>
 ///     value := $A6;
 ///     a := FormatValue('B', value);    // 10100110
 ///     b := FormatValue('B12', value);  // 000010100110
 ///
 ///     value := 123;
 ///     c := FormatValue('B', value);    // 1111011
 ///     d := FormatValue('B4', value);   // 1111011
 ///     e := FormatValue('B10', value);  // 0001111011
 ///     </code>
 ///     </example>
 ///     </description>
 ///   </item>
 /// </list>
 /// <para>
 /// NOTE: FormatValue always uses the native calendar system of the specified
 /// culture to format a date value.
 /// </para>
 /// </remarks>
 /// <param name="Fmt">
 /// The format string. See <see cref="FormatCS"/> for details.
 /// </param>
 /// <param name="Value">
 /// The value to be formatted.
 /// </param>
 /// <param name="Culture">
 /// The optional <see cref="TCultureInfo"/> object that provides the locale specific
 /// format settings.
 /// </param>
 /// <param name="UseNativeDigits">
 /// Indicates whether the numbers should be represented in the native digits of the
 /// specified <paramref name="Culture"/>.
 /// </param>
 /// <returns>
 /// The formatted value as a string.
 /// </returns>
 /// <seealso cref="FormatCS"/>
 {$Endregion}
 Function FormatValue(Const Fmt : String; Const Value : Variant; Culture : TCultureInfo = Nil; UseNativeDigits : Boolean = True) : String;

 {$Region 'xmldoc'}
 /// <summary>
 /// Returns a formatted string assembled from a format string in C# language style
 /// and an array of arguments.
 /// </summary>
 /// <remarks>
 /// <para>
 /// FormatCS returns a string produced according to the formatting string <paramref name="Fmt"/>.
 /// </para>
 /// <para>
 /// The <paramref name="Fmt"/> parameter consists of zero or more runs of text intermixed
 /// with zero or more indexed placeholders, called format items, that correspond to a value
 /// in the parameter list of this function. The formatting process replaces each format item
 /// with the text representation of the value of the corresponding value.
 /// </para>
 /// <para>
 /// The syntax of a format item is <c>{index[,alignment][:specifier]}</c>, which specifies
 /// a mandatory index, the optional length and alignment of the formatted text, and an optional
 /// string of format specifier characters that govern how the value of the corresponding argument
 /// is formatted. The components of a format item are:
 /// </para>
 ///
 /// <list type="table">
 ///   <listheader>
 ///     <term>Format Component</term>
 ///     <description>Description</description>
 ///   </listheader>
 ///   <item>
 ///     <term>index</term>
 ///     <description>
 ///     A zero-based integer that indicates which element in a list of objects to format.
 ///     </description>
 ///   </item>
 ///   <item>
 ///     <term>alignment</term>
 ///     <description>
 ///     An optional integer indicating the minimum width of the region to contain the formatted
 ///     value. If the length of the formatted value is less than alignment, then the region is
 ///     padded with spaces. If alignment is negative, the formatted value is left justified in
 ///     the region; if alignment is positive, the formatted value is right justified. If alignment
 ///     is not specified, the length of the region is the length of the formatted value. The comma
 ///     is required if alignment is specified.
 ///     </description>
 ///   </item>
 ///   <item>
 ///     <term>specifier</term>
 ///     <description>
 ///     An optional string of format specifiers. The format specifier for datetime values and numeric
 ///     values respectively correspond to the Fmt parameters of <see cref="TCalendar.Format"/>
 ///     and <see cref="TCultureInfo.FormatNumber"/> methods. In addition, there are some extra format
 ///     specifiers for numeric values. See <see cref="FormatValue"/> for details.
 ///     </description>
 ///   </item>
 /// </list>
 /// <para>
 /// The leading and trailing brace characters, '{' and '}', are required. To specify a single
 /// literal brace character in format, specify two leading or trailing brace characters; that
 /// is, "{{" or "}}".
 /// </para>
 /// <para>
 /// If FormatCS cannot expand a format item, it will include the format item in the string
 /// as untouched.
 /// </para>
 /// <para>
 /// NOTE: FormatCS always uses the native digits and calendar system of the specified
 /// culture to format values.
 /// </para>
 /// </remarks>
 /// <param name="Fmt">
 /// The format string.
 /// </param>
 /// <param name="Args">
 /// The array of arguments to apply to the format items in the format string.
 /// </param>
 /// <param name="Culture">
 /// The optional <see cref="TCultureInfo"/> object that provides the locale specific
 /// formatting information.
 /// </param>
 /// <returns>
 /// The formatted string.
 /// </returns>
 /// <seealso cref="FormatValue"/>
 {$Endregion}
 Function FormatCS(Const Fmt : String; Const Args : Array Of Variant; Culture : TCultureInfo = Nil) : String;

 {$Region 'xmldoc'}
 /// <summary>
 /// Maps a specified string in a specified code page to a Unicode string.
 /// </summary>
 /// <param name="CodePage">
 /// The code page of the source string.
 /// </param>
 /// <param name="Str">
 /// The source string.
 /// </param>
 /// <returns>
 /// The Unicode string.
 /// </returns>
 /// <seealso cref="UnicodeToCodePage"/>
 {$Endregion}
 Function CodePageToUnicode(CodePage : Integer; Const Str : RawByteString) : UnicodeString;

 {$Region 'xmldoc'}
 /// <summary>
 /// Maps a specified Unicode string to a string in a specified code page.
 /// </summary>
 /// <param name="CodePage">
 /// The code page of the result string.
 /// </param>
 /// <param name="Str">
 /// The source Unicode string.
 /// </param>
 /// <returns>
 /// The string in the code page.
 /// </returns>
 /// <seealso cref="CodePageToUnicode"/>
 {$Endregion}
 Function UnicodeToCodePage(CodePage : Integer; Const Str : UnicodeString) : RawByteString;

 {$Region 'xmldoc'}
 /// <summary>
 /// Provides a list of scripts used in a specified Unicode string.
 /// </summary>
 /// <param name="Str">
 /// The Unicode string.
 /// </param>
 /// <param name="AllowInheritedCommon">
 /// Indicates whether to retrieve "Qaii" (INHERITED) and "Zyyy" (COMMON) script
 /// information.
 /// </param>
 /// <returns>
 /// The set of scripts used in the Unicode string.
 /// </returns>
 {$Endregion}
 Function StringScripts(Const Str : String; AllowInheritedCommon : Boolean = False) : TUnicodeScripts;

 {$Region 'xmldoc'}
 /// <summary>
 /// Indicates whether a specified string represents a GUID.
 /// </summary>
 /// <param name="Str">
 /// The string to examine.
 /// </param>
 /// <returns>
 /// Returns <see langword="true"/> if the string represents a GUID, otherwise
 /// returns <see langword="false"/>.
 /// </returns>
 {$Endregion}
 Function IsStringGUID(Const Str : String) : Boolean;

 {$Region 'xmldoc'}
 /// <summary>
 /// Indicates whether a specified string contains translatable phrases.
 /// </summary>
 /// <remarks>
 /// <para>
 /// A string is considered translatable if it contains non-whitespace characters
 /// and does not represent a GUID.
 /// </para>
 /// </remarks>
 /// <param name="Str">
 /// The string to examine.
 /// </param>
 /// <returns>
 /// Returns <see langword="true"/> if the string is translatable, otherwise returns
 /// <see langword="false"/>.
 /// </returns>
 {$Endregion}
 Function IsStringTranslatable(Const Str : String) : Boolean;

 {$Region 'xmldoc'}
 /// <summary>
 /// Converts binary data to its hexadecimal string representation.
 /// </summary>
 /// <param name="Data">
 /// The binary data to convert.
 /// </param>
 /// <param name="Size">
 /// The size of the binary data in bytes.
 /// </param>
 /// <returns>
 /// The hexadecimal string representation of the binary data, or empty string if
 /// <paramref name="Size"/> is less than or equal to zero.
 /// </returns>
 {$Endregion}
 Function HexString(Const Data; Size : Integer) : String;

 {$Region 'xmldoc'}
 /// <summary>
 /// Generates a string identifier from a specified string.
 /// </summary>
 /// <param name="Str">
 /// The source string.
 /// </param>
 /// <returns>
 /// The string identifier.
 /// </returns>
 /// <remarks>
 /// This function generates an identifier from a specified string, so that it
 /// can be used to identify the literal strings for translation purposes.
 {$Endregion}
 Function GetStringIdentifier(Const Str : String) : String;

Implementation

 Uses
  Types, Math, i18nWinNLS, i18nMD5;

 Resourcestring
  SInvalidString = 'Invalid escaped character in the string';

 Function ExtractComponentName(Const PropertyPath : String) : String;
  Var
   i : Integer;
  Begin
   i := Pos('.', PropertyPath);
   If i = 0 Then
    i := Pos('[', PropertyPath);
   If i <> 0 Then
    Result := Copy(PropertyPath, 1, i - 1)
   Else
    Result := '';
  End;

 Function ExpandEnvStr(Const Str : String) : String;
  Var
   Size : Cardinal;
  Begin
   Size := 2048;
   SetString(Result, Nil, Size);
   Size := ExpandEnvironmentStrings(PChar(Str), PChar(Result), Size);
   If Size > Cardinal(Length(Result)) Then
    Begin
     SetString(Result, Nil, Size);
     Size := ExpandEnvironmentStrings(PChar(Str), PChar(Result), Size);
    End;
   If Size > 0 Then
    SetLength(Result, Size - 1)
   Else
    Result := '';
  End;

 Function EscapeString(Const Str : String) : String;
  Const
   HexDigits : Array[0..15] Of Char = '0123456789ABCDEF';
   Chars8to13 : Array[#$8..#$D] Of Char = 'btnvfr';
  Var
   i   : Integer;
   r   : PChar;
   c   : Char;
   Esc : Char;
  Begin
   {$IFNDEF COMPILER_XE5_UP}
   Esc := #0; // to prevent compiler warning
   {$ENDIF}
   SetString(Result, Nil, 2 * Length(Str));
   r     := PChar(Result) - 1;
   For i := 1 To Length(Str) Do
    Begin
     Inc(r);
     c := Str[i];
     Case c Of
      #$8..#$D :
       Esc := Chars8to13[c];    // -> \b \t \n \v \f \r
      #$0 :
       Esc := '0';              // -> \0
      '\' :
       Esc := '\';              // -> \\
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
   SetLength(Result, r - PChar(Result) + 1);
  End;

 Function UnescapeString(Const Str : String) : String;

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
      EConvertError.Create(SInvalidString);
     Result := Char(Value);
    End;
  Var
   i   : Integer;
   Len : Integer;
   r   : PChar;

  Begin
   Len := Length(Str);
   SetString(Result, Nil, Len);
   r := PChar(Result);
   i := 1;
   While i <= Len Do
    Begin
     r^ := Str[i];
     If Str[i] = '\' Then
      Begin
       Inc(i);
       If i > Len Then
        Break;
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
        '0' :
         r^ := #$0;  // null character
        'x' :
         r^ := GetEscapedChar(i, 2);
        'u' :
         r^ := GetEscapedChar(i, 4);
       End;
      End;
     Inc(r);
     Inc(i);
    End;
   SetLength(Result, r - PChar(Result));
  End;

 Function DamerauLevenshteinDistance(Const Str1, Str2 : String) : Integer;

   Function Min(Const a, b, c : Integer) : Integer; Inline;
    Begin
     Result := a;
     If b < Result Then
      Result := b;
     If c < Result Then
      Result := c;
    End;
  Var
   LenStr1  : Integer;
   LenStr2  : Integer;
   i        : Integer;
   j        : Integer;
   Cost     : Integer;
   PrevCost : Integer;
   pStr1    : PChar;
   pStr2    : PChar;
   S1       : PChar;
   S2       : PChar;
   d        : PIntegerArray;

  Begin
   LenStr1 := Length(Str1);
   LenStr2 := Length(Str2);
   // to save some space, make sure the second index points to the shorter string
   If LenStr1 < LenStr2 Then
    Begin
     i       := LenStr1;
     LenStr1 := LenStr2;
     LenStr2 := i;
     pStr1   := PChar(Str2);
     pStr2   := PChar(Str1);
    End
   Else
    Begin
     pStr1 := PChar(Str1);
     pStr2 := PChar(Str2);
    End;
   // skip leading matches
   While (LenStr2 <> 0) And (pStr1^ = pStr2^) Do
    Begin
     Inc(pStr1);
     Inc(pStr2);
     Dec(LenStr1);
     Dec(LenStr2);
    End;
   // skip trailing matches
   While (LenStr2 <> 0) And ((pStr1 + LenStr1 - 1)^ = (pStr2 + LenStr2 - 1)^) Do
    Begin
     Dec(LenStr1);
     Dec(LenStr2);
    End;
   // when one string is empty, length of the other is the distance
   If LenStr2 = 0 Then
    Begin
     Result := LenStr1;
     Exit;
    End;
   // calculate the edit distance
   d     := AllocMem((LenStr2 + 1) * SizeOf(Integer));
   S1    := pStr1;
   For i := 1 To LenStr1 Do
    Begin
     PrevCost := i - 1;
     Cost     := i;
     S2       := pStr2;
     For j    := 1 To LenStr2 Do
      Begin
       If (S1^ = S2^) Or ((i > 1) And (j > 1) And (S1^ = (S2 - 1)^) And (S2^ = (S1 - 1)^)) Then
        Cost := PrevCost
       Else
        Cost    := 1 + Min(Cost, PrevCost, d[j]);
       PrevCost := d[j];
       d[j]     := Cost;
       Inc(S2);
      End;
     Inc(S1);
    End;
   Result := d[LenStr2];
   FreeMem(d);
  End;

 Function StringSimilarityRatio(Const Str1, Str2 : String) : Double;
  Var
   MaxLen   : Integer;
   Distance : Integer;
  Begin
   Result := 1.0;
   If Length(Str1) > Length(Str2) Then
    MaxLen := Length(Str1)
   Else
    MaxLen := Length(Str2);
   If MaxLen <> 0 Then
    Begin
     Distance := DamerauLevenshteinDistance(Str1, Str2);
     Result   := Result - (Distance / MaxLen);
    End;
  End;

 Function TextSimilarityRatio(Const Str1, Str2 : String) : Double;
  Begin
   Result := StringSimilarityRatio(LowerCase(Str1), LowerCase(Str2));
  End;

 Function TranslateDigits(Const Str : String; FromCulture, ToCulture : TCultureInfo) : String;
  Var
   s        : PChar;
   FromZero : Char;
   ToZero   : Char;
  Begin
   Result   := Str;
   FromZero := FromCulture.NativeDigits[1];
   ToZero   := ToCulture.NativeDigits[1];
   If FromZero = ToZero Then
    Exit;
   s := PChar(Result);
   While s^ <> #0 Do
    Begin
     If Cardinal(Ord(s^) - Ord(FromZero)) <= 9 Then
      s^ := Chr(Ord(ToZero) + Ord(s^) - Ord(FromZero));
     Inc(s);
    End;
  End;

 Function IntToBin(Value : Cardinal; Len : Integer) : String;
  Begin
   Result := '';
   While Value <> 0 Do
    Begin
     If LongBool(Value And 1) Then
      Result := '1' + Result
     Else
      Result := '0' + Result;
     Value   := Value Shr 1;
    End;
   If Len > Length(Result) Then
    Result := StringOfChar('0', Len - Length(Result)) + Result;
  End;

 Function FormatValue(Const Fmt : String; Const Value : Variant; Culture : TCultureInfo; UseNativeDigits : Boolean) : String; Overload;
  Var
   m            : Char;
   FmtStr       : String;
   FloatValue   : Extended;
   IntegerValue : Integer;
   Precision    : Integer;
   IsFloat      : Boolean;
   NeedsPrec    : Boolean;
   NeedsLen     : Boolean;
  Begin
   If VarIsStr(Value) And ((Fmt = '') Or Not TryStrToFloat(Value, FloatValue)) Then
    Begin
     Result := VarToStr(Value);
     Exit;
    End;
   If Length(Fmt) <> 0 Then
    m := Fmt[1]
   Else If VarType(Value) <> varDate Then
    m := 'G'
   Else
    m           := '*';
   FmtStr       := '';
   FloatValue   := 0.0;
   IntegerValue := 0;
   Precision    := 0;
   NeedsPrec    := False;
   NeedsLen     := False;
   IsFloat      := False;
   If Length(Fmt) > 1 Then
    NeedsPrec := TryStrToInt(Copy(Fmt, 2, Length(Fmt) - 1), Precision);
   Case m Of
    'C', 'c' :
     Begin
      IsFloat    := True;
      FloatValue := Value;
      FmtStr     := 'm';
     End;
    'G', 'g' :
     Begin
      IsFloat    := True;
      FloatValue := Value;
      FmtStr     := 'g';
     End;
    'E', 'e' :
     Begin
      IsFloat    := True;
      FloatValue := Value;
      FmtStr     := 'e';
      If Not NeedsPrec Then
       Begin
        NeedsPrec := True;
        Precision := 7;
       End
      Else
       Inc(Precision);
     End;
    'F', 'f' :
     Begin
      IsFloat    := True;
      FloatValue := Value;
      FmtStr     := 'f';
     End;
    'N', 'n' :
     Begin
      IsFloat    := True;
      FloatValue := Value;
      FmtStr     := 'n';
     End;
    'P', 'p' :
     Begin
      If Not NeedsPrec Then
       Begin
        NeedsPrec := True;
        Precision := 2;
       End;
      If Assigned(Culture) Then
       Begin
        Result := Culture.FormatPercent(Value, Precision, UseNativeDigits);
        Exit;
       End;
      IsFloat    := True;
      FloatValue := Value * 100.0;
      FmtStr     := 'f%%';
     End;
    'D', 'd' :
     Begin
      IntegerValue := Value;
      FmtStr       := 'd';
      NeedsLen     := NeedsPrec;
     End;
    'X', 'x' :
     Begin
      Result := IntToHex(Value, Precision);
      If m = 'x' Then
       Result := LowerCase(Result);
      Exit;
     End;
    'B', 'b' :
     Begin
      Result := IntToBin(Value, Precision);
      Exit;
     End;
   Else
     If Assigned(Culture) Then
      If VarType(Value) = varDate Then
       Result := Culture.FormatDateTime(Fmt, VarToDateTime(Value), UseNativeDigits)
      Else
       Result := Culture.FormatNumber(Fmt, Value, UseNativeDigits)
     Else If VarType(Value) = varDate Then
      Result := DefaultCalendar.Format(Fmt, VarToDateTime(Value))
     Else
      Result := SysUtils.FormatFloat(Fmt, Value);
     Exit;
   End;
   If NeedsPrec Then
    FmtStr := '.' + IntToStr(Precision) + FmtStr;
   If NeedsLen Then
    FmtStr := IntToStr(Precision) + FmtStr;
   FmtStr  := '%' + FmtStr;
   If Assigned(Culture) Then
    If IsFloat Then
     Result := Culture.Format(FmtStr, [FloatValue], UseNativeDigits)
    Else
     Result := Culture.Format(FmtStr, [IntegerValue], UseNativeDigits)
   Else If IsFloat Then
    Result := SysUtils.Format(FmtStr, [FloatValue])
   Else
    Result := SysUtils.Format(FmtStr, [IntegerValue]);
   If (m = 'g') Or (m = 'e') Then
    Result := LowerCase(Result);
  End;

 Function FormatCS(Const Fmt : String; Const Args : Array Of Variant; Culture : TCultureInfo) : String;
  Var
   Buffer    : String;
   BufferPos : Integer;

   Procedure Append(p : PChar; Count : Integer); Overload;
    Begin
     If Count <> 0 Then
      Begin
       If BufferPos + Count > Length(Buffer) Then
        SetLength(Buffer, BufferPos + Max(512, Count));
       Move(p^, Buffer[BufferPos + 1], Count * SizeOf(Char));
       Inc(BufferPos, Count);
      End;
    End;

   Procedure Append(c : Char; Count : Integer); Overload;
    Begin
     If Count <> 0 Then
      Begin
       If BufferPos + Count > Length(Buffer) Then
        SetLength(Buffer, BufferPos + Max(512, Count));
       Repeat
        Inc(BufferPos);
        Buffer[BufferPos] := c;
        Dec(Count);
       Until Count = 0;
      End;
    End;

   Procedure Append(Const Str : String); Overload;
    Begin
     Append(PChar(Str), Length(Str));
    End;

   Function AppendItem(Const Item : String; UseNativeDigits : Boolean) : Boolean;
    Var
     IndexStr      : String;
     AlignStr      : String;
     Specifier     : String;
     Index         : Integer;
     Align         : Integer;
     FormattedItem : String;
     p             : Integer;
    Begin
     Result := False;
     p      := Pos(':', Item);
     If p > 0 Then
      Begin
       IndexStr  := Copy(Item, 1, p - 1);
       Specifier := Copy(Item, p + 1, Length(Item) - p);
      End
     Else
      Begin
       IndexStr  := Item;
       Specifier := '';
      End;
     p := Pos(',', IndexStr);
     If p > 0 Then
      Begin
       AlignStr := Copy(IndexStr, p + 1, Length(IndexStr) - p);
       Delete(IndexStr, p, Length(IndexStr) - p + 1);
      End
     Else
      AlignStr := '';
     Align     := 0;
     If TryStrToInt(IndexStr, Index) And
     (Index >= 0) And (Index < Length(Args)) And
     ((AlignStr = '') Or TryStrToInt(AlignStr, Align)) Then
      Begin
       FormattedItem := FormatValue(Specifier, Args[Index], Culture, UseNativeDigits);
       If (AlignStr <> '') And (Abs(Align) > Length(FormattedItem)) Then
        Begin
         If Align < 0 Then
          Append(' ', -Align - Length(FormattedItem));
         Append(FormattedItem);
         If Align > 0 Then
          Append(' ', Align - Length(FormattedItem));
        End
       Else
        Append(FormattedItem);
       Result := True;
      End;
    End;
  Var
   FmtItem         : String;
   P1              : PChar;
   P2              : PChar;
   UseNativeDigits : Boolean;

  Begin
   Buffer          := '';
   BufferPos       := 0;
   UseNativeDigits := True;
   P2              := PChar(Fmt);
   While P2^ <> #0 Do
    Begin
     P1 := P2;
     While (P2^ <> #0) And (P2^ <> '{') And (P2^ <> '}') Do
      Begin
       Case P2^Of
        UCC_NODS : UseNativeDigits := False;
        UCC_NADS : UseNativeDigits := True;
       End;
       Inc(P2);
      End;
     Append(P1, P2 - P1);
     If P2^ <> #0 Then
      Begin
       If P2^ = (P2 + 1)^Then
        Begin
         Append(P2, 1);
         Inc(P2, 2);
        End
       Else If P2^ = '{' Then
        Begin
         Inc(P2);
         P1 := P2;
         While P2^ <> #0 Do
          Begin
           If P2^ = '}' Then
            Begin
             If P2^ = (P2 + 1)^Then
              Inc(P2)
             Else
              Break;
            End;
           Inc(P2);
          End;
         If P2^ = '}' Then
          Begin
           SetString(FmtItem, P1, P2 - P1);
           Inc(P2);
           FmtItem := StringReplace(FmtItem, '{{', '{', [rfReplaceAll]);
           FmtItem := StringReplace(FmtItem, '}}', '}', [rfReplaceAll]);
           If Not AppendItem(FmtItem, UseNativeDigits) Then
            Append(FmtItem);
          End
         Else
          Append(P1 - 1, P2 - P1 + 1);
        End
       Else // if P2^ = '}' then
        Begin
         Append(P2, 1);
         Inc(P2);
        End;
      End;
    End;
   SetLength(Buffer, BufferPos);
   Result := Buffer;
  End;

 Function CodePageToUnicode(CodePage : Integer; Const Str : RawByteString) : UnicodeString;
  Var
   NumOfChars : Integer;
  Begin
   Result     := '';
   NumOfChars := MultiByteToWideChar(CodePage, 0, PAnsiChar(Str), Length(Str), Nil, 0);
   If NumOfChars <> 0 Then
    Begin
     SetString(Result, Nil, NumOfChars);
     MultiByteToWideChar(CodePage, 0, PAnsiChar(Str), Length(Str), PWideChar(Result), NumOfChars);
    End;
  End;

 Function UnicodeToCodePage(CodePage : Integer; Const Str : UnicodeString) : RawByteString;
  Var
   NumOfChars : Integer;
  Begin
   Result     := '';
   NumOfChars := WideCharToMultiByte(CodePage, 0, PWideChar(Str), Length(Str), Nil, 0, Nil, Nil);
   If NumOfChars <> 0 Then
    Begin
     SetString(Result, Nil, NumOfChars);
     WideCharToMultiByte(CodePage, 0, PWideChar(Str), Length(Str), PAnsiChar(Result), NumOfChars, Nil, Nil);
    End;
  End;

 Function StringScripts(Const Str : String; AllowInheritedCommon : Boolean) : TUnicodeScripts;
  Var
   ScriptCodes : String;
  Begin
   ScriptCodes := GetStringScripts(Str, AllowInheritedCommon);
   Result      := ScriptCodesToScripts(ScriptCodes);
  End;

 Function IsStringGUID(Const Str : String) : Boolean;

   Function IsHexNumber(s : PChar; Count : Integer) : Boolean;
    Begin
     While (Count > 0) And CharInSet(s^, ['0'..'9', 'a'..'f', 'A'..'F']) Do
      Begin
       Inc(s);
       Dec(Count);
      End;
     Result := (Count = 0);
    End;

  Begin
   Result := (Length(Str) = 38)
   And (Str[1] = '{') And (Str[38] = '}')
   And (Str[10] = '-') And (Str[15] = '-')
   And (Str[20] = '-') And (Str[25] = '-')
   And IsHexNumber(@Str[2], 8) And IsHexNumber(@Str[11], 4)
   And IsHexNumber(@Str[16], 4) And IsHexNumber(@Str[21], 4)
   And IsHexNumber(@Str[26], 12);
  End;

 Function IsStringTranslatable(Const Str : String) : Boolean;
  Var
   i : Integer;
  Begin
   Result := False;
   For i  := 1 To Length(Str) Do
    If Ord(Str[i]) > 32 Then
     Begin
      Result := Not IsStringGUID(Str);
      Exit;
     End;
  End;

 Function HexString(Const Data; Size : Integer) : String;
  Const
   HexDigits : Array[0..15] Of Char = '0123456789ABCDEF';
  Var
   s : PChar;
   b : PByte;
   i : Integer;
  Begin
   If Not Assigned(@Data) Or (Size <= 0) Then
    Begin
     Result := '';
     Exit;
    End;

   SetString(Result, Nil, Size * 2);
   s     := PChar(Result);
   b     := PByte(@Data);
   For i := 0 To Size - 1 Do
    Begin
     s^ := HexDigits[(b^ Shr 4) And $0F];
     Inc(s);
     s^ := HexDigits[b^ And $0F];
     Inc(s);
     Inc(b);
    End;
  End;

 Function GetStringIdentifier(Const Str : String) : String;
  Begin
   With TMD5.Create(True) Do
    Try
     AppendString(Str);
     Result := Value;
    Finally
     Free;
    End;
  End;

End.
