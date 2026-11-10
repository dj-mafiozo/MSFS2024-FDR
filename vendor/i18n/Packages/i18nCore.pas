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
/// This unit implements classes and functions to collect information about cultures
/// (locales), territories (countries/regions), and currencies. It also provides
/// methods to perform culture-specific operations such as formatting and parsing
/// of numbers and date-time values, digit substitution, string verification,
/// and code page conversions.
/// </summary>
Unit i18nCore;

{$I DELPHIAREA.INC}

{-$DEFINE EXCLUDE_TERRITORIES_WITH_NO_CULTURE_INFO}
{$DEFINE EXCLUDE_TERRITORIES_WITH_X_CODE}

Interface

 Uses
  Windows, SysUtils, Classes, i18nHashList, i18nUnicode, i18nPlurals,
  i18nCalendar, i18nCalendars, i18nWinNLS;

 Const
  {$Region 'xmldoc'}
  /// <summary>
  /// Specifies the start range of custom primary language identifiers.
  /// </summary>
  {$Endregion}
  CUSTOM_LANG = $0200;
{$Region 'xmldoc'}
/// <summary>
/// Specifies the end range of custom primary language identifiers.
/// </summary>
{$Endregion}
  CUSTOM_LANG_LAST = $03FF;
{$Region 'xmldoc'}
/// <summary>
/// Specifies the start range of custom secondary language identifiers.
/// </summary>
{$Endregion}
  CUSTOM_SUBLANG = $20;
{$Region 'xmldoc'}
/// <summary>
/// Specifies the end range of custom secondary language identifiers.
/// </summary>
{$Endregion}
  CUSTOM_SUBLANG_LAST = $3F;

 Const
  {$Region 'xmldoc'}
  /// <summary>
  /// Lists nominal digits as a string of characters.
  /// </summary>
  {$Endregion}
  NOMINAL_DIGITS = '0123456789';

 Type
  TCultureInfo           = Class;
  TReadonlyCultureList   = Class;
  TCultureList           = Class;
  TTerritoryInfo         = Class;
  TReadonlyTerritoryList = Class;
  TTerritoryList         = Class;
  TCurrencyInfo          = Class;
  TReadonlyCurrencyList  = Class;
  TCurrencyList          = Class;

{$Region 'xmldoc'}
/// <summary>
/// This data type represents a pointer to <see cref="TFormatSettings"/> record.
/// </summary>
{$Endregion}

  PFormatSettings = ^TFormatSettings;

{$Region 'xmldoc'}
/// <summary>
/// This enumeration type identifies the type of code pages.
/// </summary>
{$Endregion}

  TCodePageType = (
  {$Region 'xmldoc'}
  /// OEM code page
  {$Endregion}
  cpOEM,
  {$Region 'xmldoc'}
  /// ANSI code page
  {$Endregion}
  cpANSI,
  {$Region 'xmldoc'}
  /// MAC code page
  {$Endregion}
  cpMAC
  );

{$Region 'xmldoc'}
/// <summary>
/// This enumeration type identifies the measurement systems.
/// </summary>
{$Endregion}

  TMeasurementSystem = (
  {$Region 'xmldoc'}
  /// S.I. system
  {$Endregion}
  msMetric,
  {$Region 'xmldoc'}
  /// U.S. system
  {$Endregion}
  msUS
  );

{$Region 'xmldoc'}
/// <summary>
/// This enumeration type identifies the reading direction of languages.
/// </summary>
{$Endregion}

  TReadingLayout = (
  {$Region 'xmldoc'}
  /// Read from left to right, as for the English (United States) locale.
  {$Endregion}
  rlLeftToRight,
  {$Region 'xmldoc'}
  /// Read from right to left, as for Arabic locales.
  {$Endregion}
  rlRightToLeft,
  {$Region 'xmldoc'}
  /// Read vertically from top to bottom with columns to the right, and read
  /// from right to left, as for the Japanese (Japan) locale.
  {$Endregion}
  rlTopToBottomColRightToLeft,
  {$Region 'xmldoc'}
  /// Read vertically from top to bottom with columns proceeding to the right,
  /// as for the Mongolian (Mongolian) locale.
  {$Endregion}
  rlTopToBottomColLeftToRight
  );

{$Region 'xmldoc'}
/// <summary>
/// This enumeration type identifies the possible display names for
/// <see cref="TCultureInfo"/> objects.
/// </summary>
{$Endregion}

  TCultureDisplayName = (
  {$Region 'xmldoc'}
  /// Nothing
  {$Endregion}
  cnNone,
  {$Region 'xmldoc'}
  /// Locale name, a multi-part tag to uniquely identify the locale.
  {$Endregion}
  cnLocale,
  {$Region 'xmldoc'}
  /// Two characters of the international language code specified in ISO 639-1.
  {$Endregion}
  cnLanguage,
  {$Region 'xmldoc'}
  /// Three characters of the international language code specified in ISO 639-2/T.
  {$Endregion}
  cnLanguage3,
  {$Region 'xmldoc'}
  /// Full localized (in Windows user's language) name of the locale, for example,
  /// Deutsch (Deutschland) for German (Germany).
  {$Endregion}
  cnLocalizedDisplayName,
  {$Region 'xmldoc'}
  /// Display name of the locale in English. Usually the display name consists of
  /// the language and the country/region, for example, German (Germany) for
  /// Deutsch (Deutschland).
  {$Endregion}
  cnEnglishDisplayName,
  {$Region 'xmldoc'}
  /// Display name of the locale in its native language, for example, Deutsch
  /// (Deutschland) for the locale German (Germany).
  {$Endregion}
  cnNativeDisplayName,
  {$Region 'xmldoc'}
  /// Full localized (in Windows user's language) name of the language, for example,
  /// Deutsch representing German.
  {$Endregion}
  cnLocalizedLanguageName,
  {$Region 'xmldoc'}
  /// English name of the language, for example, German for Deutsch, from
  /// International ISO Standard 639.
  {$Endregion}
  cnEnglishLanguageName,
  {$Region 'xmldoc'}
  /// Native name of the language, for example, Deutsch for German (Germany).
  {$Endregion}
  cnNativeLanguageName,
  {$Region 'xmldoc'}
  /// Native name of the country/region associated with the locale, in the native
  /// language of the locale.
  {$Endregion}
  cnNativeCountryName,
  {$Region 'xmldoc'}
  /// Native name of the currency associated with the locale, in the native language
  /// of the locale.
  {$Endregion}
  cnNativeCurrencyName
  );

{$Region 'xmldoc'}
/// <summary>
/// This class represents a culture (locale).
/// </summary>
/// <remarks>
/// Each instance of TCultureInfo class represents a specific locale. This class has
/// properties and methods to query information about the locale, and perform the
/// locale specific tasks.
///
/// NOTE: Do not create or destroy an instance of TCultureInfo class. Use <see cref="CultureOf"/>
/// global function to get TCultureInfo instance of a locale.
/// </remarks>
/// <seealso cref="CultureOf"/>
/// <seealso cref="World.Cultures"/>
{$Endregion}

    TCultureInfo = Class Sealed(TObject)
   Private
    fLocaleID              : LCID;
    fGeoID                 : GEOID;
    fLocale                : String;
    fLanguage2             : String;
    fLanguage3             : String;
    fScriptCodes           : String;
    fNativeDigits          : String;
    fNativeCalendarType    : TCalendarClass;
    fCalendarTypes         : TCalendarClassList;
    fScripts               : TUnicodeScripts;
    fReadingLayout         : TReadingLayout;
    fMeasurementSystem     : TMeasurementSystem;
    fDefaultCodePages      : Array[TCodePageType] Of Integer;
    fNativeCalendar        : TCalendar;
    fLocalizedDisplayName  : String;
    fEnglishDisplayName    : String;
    fNativeDisplayName     : String;
    fLocalizedLanguageName : String;
    fEnglishLanguageName   : String;
    fNativeLanguageName    : String;
    fNativeCountryName     : String;
    fNativeCurrencyName    : String;
    fPercentNegative       : String;
    fPercentPositive       : String;
    fPluralRule            : String;
    fCountry               : TTerritoryInfo;
    fCurrency              : TCurrencyInfo;
    fFormatSettings        : PFormatSettings;
    Function GetLangID : LANGID; Inline;
    Function GetPrimaryLangID : LANGID; Inline;
    Function GetSubLangID : LANGID; Inline;
    Function GetBiDiMode : TBiDiMode; Inline;
    Function GetDefaultCodePages(CodePageType : TCodePageType) : Integer;
    Function GetDisplayNames(DisplayName : TCultureDisplayName) : String;
    Function GetFormatSettings : PFormatSettings;
    Function GetNativeCalendar : TCalendar;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the class for the locale specified by its identifier.
    /// </summary>
    /// <param name="ALocaleID">
    /// The identifier of the locale.
    /// </param>
    {$Endregion}
    Constructor Create(ALocaleID : LCID); Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the class for the locale specified by its name.
    /// </summary>
    /// <param name="ALocale">
    /// The name of the locale.
    /// </param>
    {$Endregion}
    Constructor Create(Const ALocale : String); Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Destroys the object and releases its allocated memory.
    /// </summary>
    {$Endregion}
    Destructor Destroy; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a string that its embedded nominal digits (0-9) are substituted with
    /// their corresponding digits in this culture.
    /// </summary>
    /// <remarks>
    /// <para>
    /// This method substitutes the nominal digits in the string specified
    /// by <paramref name="Str"/> to their corresponding native digits of this culture.
    /// </para>
    /// <para>
    /// If the argument passed as <paramref name="IgnoreUCC"/> parameter is false, the
    /// method will not substitute nominal digits that are marked with NODS (Nominal digit
    /// shapes) Unicode control character, otherwise all nominal digits will be substituted.
    /// </para>
    /// </remarks>
    /// <param name="Str">
    /// The string to convert.
    /// </param>
    /// <param name="IgnoreUCCs">
    /// Indicates whether ignore Unicode control characters.
    /// </param>
    /// <returns>
    /// The string that its digits are represented in native digits.
    /// </returns>
    /// <seealso cref="NominalDigitsToNative"/>
    /// <seealso cref="FreezeDigits"/>
    /// <seealso cref="UnfreezeDigits"/>
    /// <see cref="UCC_NODS"/>
    {$Endregion}
    Function NominalDigitsToNative(Const Str : String; IgnoreUCCs : Boolean = False) : String;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a string that its embedded native digits are substituted with their
    /// corresponding nominal digits (0-9).
    /// </summary>
    /// <remarks>
    /// <para>
    /// This method substitutes the native digits of this culture in the
    /// string specified by <paramref name="Str"/> to their corresponding nominal digits.
    /// </para>
    /// <para>
    /// If the argument passed as <paramref name="IgnoreUCC"/> parameter is false, the
    /// method will not substitute native digits that are marked with NADS (Native digit
    /// shapes substitution) Unicode control character, otherwise all native digits will
    /// be substituted.
    /// </para>
    /// </remarks>
    /// <param name="Str">
    /// The string to convert.
    /// </param>
    /// <param name="IgnoreUCCs">
    /// Indicates whether ignore Unicode control characters.
    /// </param>
    /// <returns>
    /// The string that its digits are represented in nominal digits.
    /// </returns>
    /// <seealso cref="NativeDigitsToNominal"/>
    /// <seealso cref="FreezeDigits"/>
    /// <seealso cref="UnfreezeDigits"/>
    /// <see cref="UCC_NADS"/>
    {$Endregion}
    Function NativeDigitsToNominal(Const Str : String; IgnoreUCCs : Boolean = False) : String;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a string that its embedded digits will always be displayed as either native
    /// or nominal, regardless of Windows settings.
    /// </summary>
    /// <remarks>
    /// <para>
    /// Based on the user's selection (configurable via Windows control panel), Windows may
    /// display nominal digits (0-9) in different digit shapes.
    /// </para>
    /// <para>
    /// FreezeDigits inserts appropriate Unicode control character in front of the string
    /// to prevent automatic digit substitution by Windows.
    /// </para>
    /// <para>
    /// If argument passed as <paramref name="NativeDigits"/> is true, FreezeDigits will
    /// also substitute nominal digits with native digits.
    /// </para>
    /// </remarks>
    /// <param name="Str">
    /// The string to convert.
    /// </param>
    /// <param name="UseNativeDigits">
    /// Indicates whether to use native digits or nominal digits.
    /// </param>
    /// <returns>
    /// The string that its digits are fixed as either nominal or native.
    /// </returns>
    /// <seealso cref="UnfreezeDigits"/>
    /// <seealso cref="NominalDigitsToNative"/>
    /// <seealso cref="NativeDigitsToNominal"/>
    {$Endregion}
    Function FreezeDigits(Const Str : String; UseNativeDigits : Boolean) : String;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a string that its embedded digits can be displayed automatically as either
    /// native or nominal by Windows.
    /// </summary>
    /// <remarks>
    /// <para>
    /// UnfreezeDigits reverts changes made by <see cref="FreezeDigits"/> on the string
    /// specified by the <paramref name="Str"/> parameter.
    /// </para>
    /// <para>
    /// That means, if the string specified by the <paramref name="Str"/> parameter has
    /// NODS (Nominal digit shapes) Unicode control character in front, the control
    /// character will be removed and its native digits will be substituted with their
    /// corresponding nominal digits.
    /// </para>
    /// </remarks>
    /// <param name="Str">
    /// The string to convert.
    /// </param>
    /// <returns>
    /// The string that its digits can be displayed as either native or nominal.
    /// </returns>
    /// <seealso cref="FreezeDigits"/>
    {$Endregion}
    Function UnfreezeDigits(Const Str : String) : String;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a formatted string assembled from a format string and an array of
    /// arguments.
    /// </summary>
    /// <remarks>
    /// <para>
    /// Format method acts like Format function of Delphi, except that it uses this
    /// culture's preferences for formatting the values.
    /// </para>
    /// <para>
    /// Optionally, this method can represent numbers in native digits.
    /// </para>
    /// </remarks>
    /// <param name="Fmt">
    /// The format string as in used by Delphi's standard Format function.
    /// </param>
    /// <param name="Args">
    /// The array of arguments to apply to the format specifiers in the format string.
    /// </param>
    /// <param name="UseNativeDigits">
    /// Indicates whether to use native digits or nominal digits for numbers.
    /// </param>
    /// <returns>
    /// The formatted string.
    /// </returns>
    {$Endregion}
    Function Format(Const Fmt : String; Const Args : Array Of Const; UseNativeDigits : Boolean = True) : String;
    {$Region 'xmldoc'}
    /// <summary>
    /// Formats a floating point value.
    /// </summary>
    /// <remarks>
    /// <para>
    /// FormatNumber method acts like FormatFloat function of Delphi, except that it
    /// uses this culture's preferences for formatting the number.
    /// </para>
    /// <para>
    /// Optionally, this method can represent the number in native digits.
    /// </para>
    /// </remarks>
    /// <param name="Fmt">
    /// The format string.
    /// </param>
    /// <param name="Value">
    /// The floating point value to format.
    /// </param>
    /// <param name="UseNativeDigits">
    /// Indicates whether to use native digits or nominal digits for the number.
    /// </param>
    /// <returns>
    /// The formatted string.
    /// </returns>
    {$Endregion}
    Function FormatNumber(Const Fmt : String; Const Value : Extended; UseNativeDigits : Boolean = True) : String;
    {$Region 'xmldoc'}
    /// <summary>
    /// Formats a floating point value as a percentage.
    /// </summary>
    /// <remarks>
    /// <para>
    /// FormatPercent represents a floating point value as a percentage using the
    /// percentage format of this culture.
    /// </para>
    /// <para>
    /// Optionally, this method can represent the percentage in native digits.
    /// </para>
    /// </remarks>
    /// <param name="Value">
    /// The floating point value to format.
    /// </param>
    /// <param name="Decimals">
    /// The number of decimals.
    /// </param>
    /// <param name="UseNativeDigits">
    /// Indicates whether to use native digits or nominal digits for the percentage.
    /// </param>
    /// <returns>
    /// The formatted string.
    /// </returns>
    {$Endregion}
    Function FormatPercent(Const Value : Extended; Decimals : Integer = 2; UseNativeDigits : Boolean = True) : String;
    {$Region 'xmldoc'}
    /// <summary>
    /// Formats a <see cref="TDateTime"/> value.
    /// </summary>
    /// <remarks>
    /// <para>
    /// FormatDateTime formats the <see cref="TDateTime"/> value given by <paramref name="Value"/>
    /// using the format given by <paramref name="Fmt"/>.
    /// </para>
    /// <para>
    /// FormatDateTime uses <see cref="NativeCalendar"/> object to extract components of
    /// the specified <see cref="TDateTime"/> value.
    /// </para>
    /// <para>
    /// Optionally, this method can represent the numbers in native digits.
    /// </para>
    /// </remarks>
    /// <param name="Fmt">
    /// The format string. See the <see cref="TCalendar.Format"/> method for details.
    /// </param>
    /// <param name="Value">
    /// The <see cref="TDateTime"/> value to format.
    /// </param>
    /// <param name="UseNativeDigits">
    /// Indicates whether to use native digits or nominal digits for the numbers.
    /// </param>
    /// <returns>
    /// The formatted date-time string.
    /// </returns>
    /// <seealso cref="NativeCalendar"/>
    /// <seealso cref="TryParseDateTime"/>
    /// <seealso cref="ParseDateTime"/>
    {$Endregion}
    Function FormatDateTime(Const Fmt : String; Const Value : TDateTime; UseNativeDigits : Boolean = True) : String;
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts a string to a <see cref="TDateTime"/> value using a specified format
    /// string.
    /// </summary>
    /// <remarks>
    /// <para>
    /// The ParseDateTime method scans the string given by <paramref name="Str"/>
    /// using the format string given by <paramref name="Fmt"/> to extract its
    /// date and time values.
    /// </para>
    /// <para>
    /// ParseDateTime uses the calendar object specified by <see cref="NativeCalendar"/>
    /// property to extract the date and time components from the input string.
    /// </para>
    /// </remarks>
    /// <param name="Fmt">
    /// The format string. See the <see cref="TCalendar.Format"/> method for details.
    /// </param>
    /// <param name="Str">
    /// The date and time value as a string.
    /// </param>
    /// <returns>
    /// The <see cref="TDateTime"/> value.
    /// </returns>
    /// <exception cref="EConvertError">
    /// Occurs when the conversion is failed.
    /// </exception>
    /// <seealso cref="TryParseDateTime"/>
    /// <seealso cref="FormatDateTime"/>
    {$Endregion}
    Function ParseDateTime(Const Fmt : String; Const Str : String) : TDateTime;
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts a string to a <see cref="TDateTime"/> value using a specified format
    /// string.
    /// </summary>
    /// <remarks>
    /// <para>
    /// The TryParseDateTime method scans the string given by <paramref name="Str"/>
    /// using the format string given by <paramref name="Fmt"/> to extract its
    /// date and time values.
    /// </para>
    /// <para>
    /// TryParseDateTime uses the calendar object specified by <see cref="NativeCalendar"/>
    /// property to extract the date and time components of the input string.
    /// </para>
    /// </remarks>
    /// <param name="Fmt">
    /// The format string. See the <see cref="TCalendar.Format"/> method for details.
    /// </param>
    /// <param name="Str">
    /// The date and time value as a string.
    /// </param>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the conversion is succeeded, otherwise
    /// returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="ParseDateTime"/>
    /// <seealso cref="FormatDateTime"/>
    {$Endregion}
    Function TryParseDateTime(Const Fmt : String; Const Str : String; Var DateTime : TDateTime) : Boolean;
    {$Region 'xmldoc'}
    /// <summary>
    /// Verifies whether a specified string used the scripts of this culture.
    /// </summary>
    /// <param name="Str">
    /// The string to examine.
    /// </param>
    /// <param name="AllowLatin">
    /// Indicates whether the Latin script is allowed anyway.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the string uses scripts of this culture,
    /// otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="ScriptCodes"/>
    /// <seealso cref="Scripts"/>
    {$Endregion}
    Function VerifyString(Const Str : String; AllowLatin : Boolean = True) : Boolean;
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts a string in default OEM code page of this culture's language to Unicode.
    /// </summary>
    /// <param name="Str">
    /// The OEM string.
    /// </param>
    /// <returns>
    /// The Unicode string.
    /// </returns>
    /// <seealso cref="UnicodeToOem"/>
    /// <seealso cref="AnsiToUnicode"/>
    /// <seealso cref="MacToUnicode"/>
    /// <seealso cref="DefaultCodePages"/>
    {$Endregion}
    Function OemToUnicode(Const Str : RawByteString) : String;
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts a string from Unicode to default OEM code page of this culture's language.
    /// </summary>
    /// <param name="Str">
    /// The Unicode string
    /// </param>
    /// <returns>
    /// The OEM string.
    /// </returns>
    /// <seealso cref="OemToUnicode"/>
    /// <seealso cref="UnicodeToAnsi"/>
    /// <seealso cref="UnicodeToMac"/>
    /// <seealso cref="DefaultCodePages"/>
    {$Endregion}
    Function UnicodeToOem(Const Str : String) : RawByteString;
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts a string in default ANSI code page of this culture's language to Unicode.
    /// </summary>
    /// <param name="Str">
    /// The ANSI string.
    /// </param>
    /// <returns>
    /// The Unicode string.
    /// </returns>
    /// <seealso cref="UnicodeToAnsi"/>
    /// <seealso cref="OemToUnicode"/>
    /// <seealso cref="MacToUnicode"/>
    /// <seealso cref="DefaultCodePages"/>
    {$Endregion}
    Function AnsiToUnicode(Const Str : RawByteString) : String;
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts a string from Unicode to default ANSI code page of this culture's language.
    /// </summary>
    /// <param name="Str">
    /// The Unicode string
    /// </param>
    /// <returns>
    /// The ANSI string.
    /// </returns>
    /// <seealso cref="AnsiToUnicode"/>
    /// <seealso cref="UnicodeToOem"/>
    /// <seealso cref="UnicodeToMac"/>
    /// <seealso cref="DefaultCodePages"/>
    {$Endregion}
    Function UnicodeToAnsi(Const Str : String) : RawByteString;
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts a string in default MAC code page of this culture's language to Unicode.
    /// </summary>
    /// <param name="Str">
    /// The MAC string.
    /// </param>
    /// <returns>
    /// The Unicode string.
    /// </returns>
    /// <seealso cref="UnicodeToMac"/>
    /// <seealso cref="AnsiToUnicode"/>
    /// <seealso cref="OemToUnicode"/>
    /// <seealso cref="DefaultCodePages"/>
    {$Endregion}
    Function MacToUnicode(Const Str : RawByteString) : String;
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts a string from Unicode to default MAC code page of this culture's language.
    /// </summary>
    /// <param name="Str">
    /// The Unicode string
    /// </param>
    /// <returns>
    /// The MAC string.
    /// </returns>
    /// <seealso cref="MacToUnicode"/>
    /// <seealso cref="UnicodeToAnsi"/>
    /// <seealso cref="UnicodeToOem"/>
    /// <seealso cref="DefaultCodePages"/>
    {$Endregion}
    Function UnicodeToMac(Const Str : String) : RawByteString;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the adjusted DrawText flags based on the language direction of this
    /// culture.
    /// </summary>
    /// <param name="Flags">
    /// The DrawText flags to adjust.
    /// </param>
    /// <returns>
    /// The adjusted DrawText flags.
    /// </returns>
    /// <seealso cref="DrawTextBiDiModeFlagsReadingOnly"/>
    {$Endregion}
    Function DrawTextBiDiModeFlags(Flags : Cardinal) : Integer;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the DrawText reading order flag based on the language direction of
    /// this culture.
    /// </summary>
    /// <returns>
    /// The DrawText reading order flag.
    /// </returns>
    /// <seealso cref="DrawTextBiDiModeFlags"/>
    {$Endregion}
    Function DrawTextBiDiModeFlagsReadingOnly : Integer; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether a specified culture object has the same primary language
    /// as this culture.
    /// </summary>
    /// <param name="Culture">
    /// The culture object to examined.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if primary languages are identical, otherwise
    /// returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function IsDialectOf(Culture : TCultureInfo) : Boolean; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether a specified locale name represents the primary language
    /// of this culture.
    /// </summary>
    /// <param name="Locale">
    /// The locale name to examine.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if primary languages are identical, otherwise
    /// returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function IsDialectOf(Const Locale : String) : Boolean; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether a specified language identifier represents the primary
    /// language of this culture.
    /// </summary>
    /// <param name="LangID">
    /// The language identifier to examine.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if primary languages are identical, otherwise
    /// returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function IsDialectOf(LANGID : LANGID) : Boolean; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether the nominal digits (0-9) are the native digits of this culture.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> if the nominal digits are the native digits of this
    /// culture, otherwise returns <see langword="false"/>.
    /// </returns>
    /// <see cref="NativeDigits"/>
    {$Endregion}
    Function IsUsingNominalDigits : Boolean; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether the Gregorian calendar in Common Era (C.E.) is the native calendar
    /// of this culture.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> if the Gregorian calendar in Common Era is the native
    /// calendar of this culture, otherwise returns <see langword="false"/>.
    /// </returns>
    /// <see cref="NativeCalendar"/>
    {$Endregion}
    Function IsUsingCommonEraCalendar : Boolean; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether the language direction of this culture is from right to left.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> if the language direction of this culture
    /// is from right to left, otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="ReadingLayout"/>
    {$Endregion}
    Function IsRightToLeft : Boolean; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether the language represented by this culture is the default
    /// dialect (sub-language) of its main language (primary language).
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> if this culture's language is the default
    /// dialect of its primary language, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function IsDefault : Boolean; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the locale identifier of the culture.
    /// </summary>
    {$Endregion}
    Property LocaleID : LCID Read fLocaleID;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the language identifier of the culture.
    /// </summary>
    {$Endregion}
    Property LANGID : LANGID Read GetLangID;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the primary language identifier of the culture.
    /// </summary>
    {$Endregion}
    Property PrimaryLangID : LANGID Read GetPrimaryLangID;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the sub-language identifier of the culture.
    /// </summary>
    {$Endregion}
    Property SubLangID : LANGID Read GetSubLangID;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the geographical identifier of the culture.
    /// </summary>
    {$Endregion}
    Property GEOID : GEOID Read fGeoID;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the locale name of the culture.
    /// </summary>
    {$Endregion}
    Property Locale : String Read fLocale;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the two-character ISO 639-1 international language code of the culture.
    /// </summary>
    {$Endregion}
    Property Language2 : String Read fLanguage2;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the three-character ISO 639-2/T international language code of the culture.
    /// </summary>
    {$Endregion}
    Property Language3 : String Read fLanguage3;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets country information of the culture.
    /// </summary>
    {$Endregion}
    Property Country : TTerritoryInfo Read fCountry;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets currency information of the culture.
    /// </summary>
    {$Endregion}
    Property Currency : TCurrencyInfo Read fCurrency;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the four-character ISO 15924 script codes of the culture separated by
    /// semicolon.
    /// </summary>
    {$Endregion}
    Property ScriptCodes : String Read fScriptCodes;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the set of culture's scripts.
    /// </summary>
    {$Endregion}
    Property Scripts : TUnicodeScripts Read fScripts;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the default measurement system used by the culture.
    /// </summary>
    {$Endregion}
    Property MeasurementSystem : TMeasurementSystem Read fMeasurementSystem;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the native digits of the culture starting from 0 to 9.
    /// </summary>
    {$Endregion}
    Property NativeDigits : String Read fNativeDigits;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the <see cref="TCalendar"/> class that manages the default calendar system
    /// used by the culture.
    /// </summary>
    {$Endregion}
    Property NativeCalendarType : TCalendarClass Read fNativeCalendarType;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the native calendar used by the culture.
    /// </summary>
    {$Endregion}
    Property NativeCalendar : TCalendar Read GetNativeCalendar;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the reading order of the scripts in the culture.
    /// </summary>
    {$Endregion}
    Property ReadingLayout : TReadingLayout Read fReadingLayout;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the TBiDiMode value of the culture's reading order.
    /// </summary>
    {$Endregion}
    Property BiDiMode : TBiDiMode Read GetBiDiMode;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the language's plural rule that determines how the language handles
    /// plurals of nouns or unit expressions.
    /// </summary>
    /// <remarks>
    /// <para>
    /// NOTE: During development of the i18n package, I could not find the plural
    /// rule of some languages. For those languages, the PluralRule property will
    /// return a default rule that is 'nplurals=1; plural=0; ASSUMED'. So, you can
    /// check for existence of word 'ASSUMED' in a plural rule returned by this
    /// property to find out whether the rule is correct or is just a default
    /// assumption.
    /// </para>
    /// </remarks>
    /// <seealso cref="TPluralForms"/>
    {$Endregion}
    Property PluralRule : String Read fPluralRule;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the localized (in Windows user's language) name of the culture.
    /// </summary>
    {$Endregion}
    Property LocalizedDisplayName : String Read fLocalizedDisplayName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the English name of the culture.
    /// </summary>
    {$Endregion}
    Property EnglishDisplayName : String Read fEnglishDisplayName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the native name of the culture.
    /// </summary>
    {$Endregion}
    Property NativeDisplayName : String Read fNativeDisplayName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the localized (in Windows user's language) name of the culture's language.
    /// </summary>
    {$Endregion}
    Property LocalizedLanguageName : String Read fLocalizedLanguageName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the English name of the culture's language.
    /// </summary>
    {$Endregion}
    Property EnglishLanguageName : String Read fEnglishLanguageName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the native name of the culture's language.
    /// </summary>
    {$Endregion}
    Property NativeLanguageName : String Read fNativeLanguageName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the native name of the culture's country.
    /// </summary>
    {$Endregion}
    Property NativeCountryName : String Read fNativeCountryName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the native name of the culture's currency.
    /// </summary>
    {$Endregion}
    Property NativeCurrencyName : String Read fNativeCurrencyName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets pointer to the culture's format settings.
    /// </summary>
    {$Endregion}
    Property FormatSettings : PFormatSettings Read GetFormatSettings;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the default ANSI, OEM, and MAC codepages of the culture.
    /// </summary>
    {$Endregion}
    Property DefaultCodePages[CodePageType : TCodePageType] : Integer Read GetDefaultCodePages;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists display names of the culture.
    /// </summary>
    {$Endregion}
    Property DisplayNames[DisplayName : TCultureDisplayName] : String Read GetDisplayNames;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TCultureEnumerator enumerates through the <see cref="TCultureInfo"/> objects
/// of an instance of <see cref="TReadonlyCultureList"/> or its descendent class.
/// </summary>
{$Endregion}

  TCultureEnumerator = Class(TListEnumerator)
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the class for a specified list.
    /// </summary>
    /// <param name="list">
    /// The list to enumerate its items.
    /// </param>
    {$Endregion}
    Constructor Create(List : TReadonlyCultureList);
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the current <see cref="TCultureInfo"/> object of the list being
    /// enumerated.
    /// </summary>
    /// <returns>
    /// Returns the current <see cref="TCultureInfo"/> object.
    /// </returns>
    {$Endregion}
    Function GetCurrent : TCultureInfo; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the current <see cref="TCultureInfo"/> object.
    /// </summary>
    {$Endregion}
    Property Current : TCultureInfo Read GetCurrent;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class maintains a read-only list of <see cref="TCultureInfo"/> objects.
/// </summary>
/// <remarks>
/// TReadonlyCultureList maintains a read-only list of <see cref="TCultureInfo"/>
/// objects, and provides properties and methods to locate and access the objects.
/// The objects in the list are hashed and can be located quickly.
/// </remarks>
/// <see cref="TCultureList"/>
{$Endregion}

  TReadonlyCultureList = Class(TPersistent)
   Private
    Lookup_LocaleID             : TKeyLookup<LCID, Integer>;
    Lookup_Locale               : TKeyLookup<String, Integer>;
    IsLookupTableValid_LocaleID : Boolean;
    IsLookupTableValid_Locale   : Boolean;
    Function GetCount : Integer; Inline;
    Function GetItems(Index : Integer) : TCultureInfo; Inline;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Provides direct access to the individual <see cref="TCultureInfo"/> objects.
    /// </summary>
    {$Endregion}
    List : TList;
    {$Region 'xmldoc'}
    /// <summary>
    /// Attaches a specified <see cref="TCultureInfo"/> object with a specified index
    /// in the list.
    /// </summary>
    /// <remarks>
    /// <para>
    /// NOTE: This method does not add the object to the list, it only creates its lookup
    /// entries for all the lookup tables.
    /// </para>
    /// </remarks>
    /// <param name="Culture">
    /// The <see cref="TCultureInfo"/> object to add to the lookup tables.
    /// </param>
    /// <param name="Index">
    /// The index of the <see cref="TCultureInfo"/> object in the list.
    /// </param>
    /// <seealso cref="RemoveLookupEntries"/>
    {$Endregion}
    Procedure AddLookupEntries(Culture : TCultureInfo; Index : Integer);
    {$Region 'xmldoc'}
    /// <summary>
    /// Detaches a specified <see cref="TCultureInfo"/> object from the previously attached
    /// index.
    /// </summary>
    /// <remarks>
    /// <para>
    /// NOTE: This method does not remove the object from the list, it only deletes its
    /// lookup entries from all lookup tables.
    /// </para>
    /// </remarks>
    /// <param name="Culture">
    /// The <see cref="TCultureInfo"/> object to remove from the lookup tables.
    /// </param>
    /// <seealso cref="AddLookupEntries"/>
    {$Endregion}
    Procedure RemoveLookupEntries(Culture : TCultureInfo);
    {$Region 'xmldoc'}
    /// <summary>
    /// Clears all entries from all lookup tables.
    /// </summary>
    {$Endregion}
    Procedure ClearLookupTables;
    {$Region 'xmldoc'}
    /// <summary>
    /// Schedules rebuilding of all lookup tables.
    /// </summary>
    {$Endregion}
    Procedure InvalidateLookupTables; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Validates lookup table for <see cref="TCultureInfo.LocaleID"/> values.
    /// </summary>
    {$Endregion}
    Procedure ValidateLookupTable_LocaleID;
    {$Region 'xmldoc'}
    /// <summary>
    /// Validates lookup table for <see cref="TCultureInfo.Locale"/> values.
    /// </summary>
    {$Endregion}
    Procedure ValidateLookupTable_Locale;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the class.
    /// </summary>
    {$Endregion}
    Constructor Create; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Destroys the instance and releases its allocated memory.
    /// </summary>
    {$Endregion}
    Destructor Destroy; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TCultureEnumerator"/> reference, which enumerates
    /// all <see cref="TCultureInfo"/> objects in the list.
    /// </summary>
    /// <returns>
    /// Returns a reference to a <see cref="TCultureEnumerator"/> instance.
    /// </returns>
    {$Endregion}
    Function GetEnumerator : TCultureEnumerator;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the first <see cref="TCultureInfo"/> object in the list.
    /// </summary>
    /// <returns>
    /// The first <see cref="TCultureInfo"/> object in the list.
    /// </returns>
    /// <seealso cref="Last"/>
    {$Endregion}
    Function First : TCultureInfo;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the last <see cref="TCultureInfo"/> object in the list.
    /// </summary>
    /// <returns>
    /// The last <see cref="TCultureInfo"/> object in the list.
    /// </returns>
    /// <seealso cref="First"/>
    {$Endregion}
    Function Last : TCultureInfo;
    {$Region 'xmldoc'}
    /// <summary>
    /// Copies <see cref="TCultureInfo"/> objects in the list to another object.
    /// </summary>
    /// <param name="Dest">
    /// The destination object.
    /// </param>
    /// <seealso cref="AssignLabelsTo"/>
    {$Endregion}
    Procedure AssignTo(Dest : TPersistent); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Copies display name of <see cref="TCultureInfo"/> objects in the list to
    /// a <see cref="TStrings"/> object.
    /// </summary>
    /// <param name="Dest">
    /// The destination <see cref="TStrings"/> object.
    /// </param>
    /// <param name="DisplayName">
    /// Determines which <see cref="TCultureInfo.DisplayNames"/> value should be used.
    /// </param>
    /// <seealso cref="AssignTo"/>
    /// <seealso cref="TCultureInfo.DisplayNames"/>
    {$Endregion}
    Procedure AssignLabelsTo(Dest : TStrings; DisplayName : TCultureDisplayName);
    {$Region 'xmldoc'}
    /// <summary>
    /// Locates a <see cref="TCultureInfo"/> object in the list by its locale identifier.
    /// </summary>
    /// <param name="LocaleID">
    /// The locale identifier.
    /// </param>
    /// <returns>
    /// The <see cref="TCultureInfo"/> object with the specified locale identifier
    /// or <see langword="nil"/> if the object is not found.
    /// </returns>
    /// <seealso cref="FindNearest"/>
    {$Endregion}
    Function Find(LocaleID : LCID) : TCultureInfo; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Locates a <see cref="TCultureInfo"/> object in the list by its locale name.
    /// </summary>
    /// <param name="Locale">
    /// The locale name.
    /// </param>
    /// <returns>
    /// The <see cref="TCultureInfo"/> object with the specified locale name
    /// or <see langword="nil"/> if the object is not found.
    /// </returns>
    /// <seealso cref="FindNearest"/>
    {$Endregion}
    Function Find(Const Locale : String) : TCultureInfo; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Locates a <see cref="TCultureInfo"/> object in the list, which is either
    /// identical to or a dialect of a specified <see cref="TCultureInfo"/> object.
    /// </summary>
    /// <param name="Culture">
    /// The <see cref="TCultureInfo"/> object to be located.
    /// </param>
    /// <returns>
    /// The matched <see cref="TCultureInfo"/> object or <see langword="nil"/> if
    /// the object is not found.
    /// </returns>
    /// <seealso cref="Find"/>
    {$Endregion}
    Function FindNearest(Culture : TCultureInfo) : TCultureInfo; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Locates a <see cref="TCultureInfo"/> object in the list, which is either
    /// identical to or a dialect of a specified locale identifier.
    /// </summary>
    /// <param name="LocaleID">
    /// The locale identifier.
    /// </param>
    /// <returns>
    /// The matched <see cref="TCultureInfo"/> object or <see langword="nil"/> if
    /// the object is not found.
    /// </returns>
    /// <seealso cref="Find"/>
    {$Endregion}
    Function FindNearest(LocaleID : LCID) : TCultureInfo; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Locates a <see cref="TCultureInfo"/> object in the list, which is either
    /// identical to or a dialect of a specified locale name.
    /// </summary>
    /// <param name="Locale">
    /// The locale name.
    /// </param>
    /// <returns>
    /// The matched <see cref="TCultureInfo"/> object or <see langword="nil"/> if
    /// the object is not found.
    /// </returns>
    /// <seealso cref="Find"/>
    {$Endregion}
    Function FindNearest(Const Locale : String) : TCultureInfo; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Finds index of a specified <see cref="TCultureInfo"/> object in the list.
    /// </summary>
    /// <param name="Culture">
    /// The <see cref="TCultureInfo"/> object to locate.
    /// </param>
    /// <returns>
    /// The index of <see cref="TCultureInfo"/> object or -1 if the object is not found.
    /// </returns>
    /// <seealso cref="IndexOfName"/>
    /// <seealso cref="NearestIndexOf"/>
    {$Endregion}
    Function IndexOf(Culture : TCultureInfo) : Integer; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Finds index of a <see cref="TCultureInfo"/> object in the list by its locale
    /// identifier.
    /// </summary>
    /// <param name="LocaleID">
    /// The locale identifier.
    /// </param>
    /// <returns>
    /// The index of <see cref="TCultureInfo"/> object or -1 if the object is not found.
    /// </returns>
    /// <seealso cref="IndexOfName"/>
    /// <seealso cref="NearestIndexOf"/>
    {$Endregion}
    Function IndexOf(LocaleID : LCID) : Integer; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Finds index of a <see cref="TCultureInfo"/> object in the list by its locale
    /// name.
    /// </summary>
    /// <param name="Locale">
    /// The locale name.
    /// </param>
    /// <returns>
    /// The index of <see cref="TCultureInfo"/> object or -1 if the object is not found.
    /// </returns>
    /// <seealso cref="IndexOfName"/>
    /// <seealso cref="NearestIndexOf"/>
    {$Endregion}
    Function IndexOf(Const Locale : String) : Integer; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Finds index of a <see cref="TCultureInfo"/> object in the list by its display name.
    /// </summary>
    /// <param name="AName">
    /// The display name of the target object.
    /// </param>
    /// <param name="DisplayName">
    /// Indicates which <see cref="TCultureInfo.DisplayNames"/> value should be used.
    /// </param>
    /// <returns>
    /// The index of <see cref="TCultureInfo"/> object or -1 if the object is not found.
    /// </returns>
    /// <seealso cref="IndexOf"/>
    {$Endregion}
    Function IndexOfName(Const AName : String; DisplayName : TCultureDisplayName) : Integer;
    {$Region 'xmldoc'}
    /// <summary>
    /// Finds index of a <see cref="TCultureInfo"/> object in the list, which is either
    /// identical to or a dialect of a specified <see cref="TCultureInfo"/> object.
    /// </summary>
    /// <param name="Culture">
    /// The <see cref="TCultureInfo"/> object to locate.
    /// </param>
    /// <returns>
    /// The index of the matched <see cref="TCultureInfo"/> object or -1 if the
    /// object is not found.
    /// </returns>
    /// <seealso cref="IndexOf"/>
    {$Endregion}
    Function NearestIndexOf(Culture : TCultureInfo) : Integer; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Finds index of a <see cref="TCultureInfo"/> object in the list, which is either
    /// identical to or a dialect of a specified locale identifier.
    /// </summary>
    /// <param name="LocaleID">
    /// The locale identifier.
    /// </param>
    /// <returns>
    /// The index of the matched <see cref="TCultureInfo"/> object or -1 if the
    /// object is not found.
    /// </returns>
    /// <seealso cref="IndexOf"/>
    {$Endregion}
    Function NearestIndexOf(LocaleID : LCID) : Integer; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Finds index of a <see cref="TCultureInfo"/> object in the list, which is either
    /// identical to or a dialect of a specified locale name.
    /// </summary>
    /// <param name="Locale">
    /// The locale name.
    /// </param>
    /// <returns>
    /// The index of the matched <see cref="TCultureInfo"/> object or -1 if the
    /// object is not found.
    /// </returns>
    /// <seealso cref="IndexOf"/>
    {$Endregion}
    Function NearestIndexOf(Const Locale : String) : Integer; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether a specified <see cref="TCultureInfo"/> object is in the list.
    /// </summary>
    /// <param name="Culture">
    /// The <see cref="TCultureInfo"/> object to examine.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the <see cref="TCultureInfo"/> object is in the
    /// list, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function Exists(Culture : TCultureInfo) : Boolean; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether a <see cref="TCultureInfo"/> object with a specified locale
    /// identifier is in the list.
    /// </summary>
    /// <param name="LocaleID">
    /// The locale identifier.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if a <see cref="TCultureInfo"/> object with the
    /// specified locale identifier is in the list, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function Exists(LocaleID : LCID) : Boolean; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether a <see cref="TCultureInfo"/> object with a specified locale
    /// name is in the list.
    /// </summary>
    /// <param name="Locale">
    /// The locale name.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if a <see cref="TCultureInfo"/> object with the
    /// specified locale name is in the list, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function Exists(Const Locale : String) : Boolean; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the number of <see cref="TCultureInfo"/> objects in the list.
    /// </summary>
    {$Endregion}
    Property Count : Integer Read GetCount;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the <see cref="TCultureInfo"/> objects in the list.
    /// </summary>
    {$Endregion}
    Property Items[Index : Integer] : TCultureInfo Read GetItems; Default;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class maintains a list of <see cref="TCultureInfo"/> objects.
/// </summary>
/// <remarks>
/// Use TCultureList to store and maintain a list of <see cref="TCultureInfo"/>
/// objects. TCultureList provides properties and methods to add, delete, rearrange,
/// locate, access, and sort <see cref="TCultureInfo"/> objects.
/// </remarks>
{$Endregion}

  TCultureList = Class(TReadonlyCultureList)
   Private
    fDuplicates  : TDuplicates;
    fUpdateCount : Integer;
    fOnChange    : TNotifyEvent;
    fOnChanging  : TNotifyEvent;
    Function GetCapacity : Integer; Inline;
    Procedure SetCapacity(Value : Integer);
    Procedure ReadLocales(Reader : TReader);
    Procedure WriteLocales(Writer : TWriter);
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Reads and writes the <see cref="Items"/> property as if it were published.
    /// </summary>
    /// <param name="Filer">
    /// The current <see cref="TReader"/> or <see cref="TWriter"/> object that is
    /// loading or saving the list.
    /// </param>
    {$Endregion}
    Procedure DefineProperties(Filer : TFiler); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnChanging"/> event.
    /// </summary>
    /// <seealso cref="Change"/>
    {$Endregion}
    Procedure Changing; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnChange"/> event.
    /// </summary>
    /// <seealso cref="Changing"/>
    {$Endregion}
    Procedure Change; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the update level.
    /// </summary>
    {$Endregion}
    Property UpdateCount : Integer Read fUpdateCount;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Prevents generating of the <see cref="OnChanging"/> and <see cref="OnChange"/>
    /// events until the <see cref="EndUpdate"/> method is called.
    /// </summary>
    /// <seealso cref="EndUpdate"/>
    {$Endregion}
    Procedure BeginUpdate;
    {$Region 'xmldoc'}
    /// <summary>
    /// Reenables <see cref="OnChanging"/> and <see cref="OnChange"/> events generation
    /// that was turned off with the <see cref="BeginUpdate"/> method.
    /// </summary>
    /// <seealso cref="BeginUpdate"/>
    {$Endregion}
    Procedure EndUpdate;
    {$Region 'xmldoc'}
    /// <summary>
    /// Deletes all items from the list.
    /// </summary>
    {$Endregion}
    Procedure Clear;
    {$Region 'xmldoc'}
    /// <summary>
    /// Sorts the items in the list by a specified display name.
    /// </summary>
    /// <param name="OrderBy">
    /// Determines which <see cref="TCultureInfo.DisplayNames"/> value should the
    /// list be sorted by.
    /// </param>
    {$Endregion}
    Procedure Sort(OrderBy : TCultureDisplayName);
    {$Region 'xmldoc'}
    /// <summary>
    /// Copies the list of <see cref="TCultureInfo"/> objects from another object.
    /// </summary>
    /// <param name="Source">
    /// The source list.
    /// </param>
    /// <seealso cref="Apply"/>
    {$Endregion}
    Procedure Assign(Source : TPersistent); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Copies <see cref="TCultureInfo"/> objects of one list to another.
    /// </summary>
    /// <remarks>
    /// Call Apply to assign the elements of another list to this one. Assign combines
    /// the source list with this one using the logical operator specified by the
    /// <paramref name="Op"/> parameter.
    ///
    /// If the <paramref name="ListB"/> parameter is specified or not <see langword="nil"/>,
    /// then Apply first replaces all the elements of this list with those in <paramref name="ListA"/>,
    /// and then merges <paramref name="ListB"/> into this list using the operator specified
    /// by <paramref name="Op"/>.
    ///
    /// These operators are acceptable in Apply method:
    ///
    /// <list type="table">
    ///   <listheader>
    ///     <term>Operator</term>
    ///     <description>Description</description>
    ///   </listheader>
    ///   <item>
    ///     <term>laCopy</term>
    ///     <description>Destination becomes a copy of the source</description>
    ///   </item>
    ///   <item>
    ///     <term>laAnd</term>
    ///     <description>Intersection of the two lists</description>
    ///   </item>
    ///   <item>
    ///     <term>laOr</term>
    ///     <description>Union of the two lists</description>
    ///   </item>
    ///   <item>
    ///     <term>laXor</term>
    ///     <description>Only those not in both lists</description>
    ///   </item>
    ///   <item>
    ///     <term>laSrcUnique</term>
    ///     <description>Only those unique to source (same as laAnd followed by laXor)</description>
    ///   </item>
    ///   <item>
    ///     <term>laDestUnique</term>
    ///     <description>Only those unique to destination (same as laOr followed by laXor)</description>
    ///   </item>
    /// </list>
    ///
    /// </remarks>
    /// <param name="ListA">
    /// The source list.
    /// </param>
    /// <param name="Op">
    /// The operator that indicates how the two lists should be merged.
    /// </param>
    /// <param name="ListB">
    /// The optional and aditional source list.
    /// </param>
    /// <seealso cref="Assign"/>
    {$Endregion}
    Procedure Apply(ListA : TReadonlyCultureList; Op : TListAssignOp = laCopy; ListB : TReadonlyCultureList = Nil);
    {$Region 'xmldoc'}
    /// <summary>
    /// Adds a specified <see cref="TCultureInfo"/> object to the list.
    /// </summary>
    /// <param name="Culture">
    /// The <see cref="TCultureInfo"/> object to add.
    /// </param>
    /// <returns>
    /// The index of new <see cref="TCultureInfo"/> object in the list.
    /// </returns>
    {$Endregion}
    Function Add(Culture : TCultureInfo) : Integer; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Adds a <see cref="TCultureInfo"/> object to the list by its locale identifier.
    /// </summary>
    /// <param name="LocaleID">
    /// The locale identifier.
    /// </param>
    /// <returns>
    /// The index of new <see cref="TCultureInfo"/> object in the list.
    /// </returns>
    {$Endregion}
    Function Add(LocaleID : LCID) : Integer; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Adds a <see cref="TCultureInfo"/> object to the list by its locale name.
    /// </summary>
    /// <param name="Locale">
    /// The locale name.
    /// </param>
    /// <returns>
    /// The index of new <see cref="TCultureInfo"/> object in the list.
    /// </returns>
    {$Endregion}
    Function Add(Const Locale : String) : Integer; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Deletes a specified <see cref="TCultureInfo"/> object from the list.
    /// </summary>
    /// <param name="Culture">
    /// The <see cref="TCultureInfo"/> object to remove.
    /// </param>
    /// <returns>
    /// The index of the removed <see cref="TCultureInfo"/> object, or -1 if the object
    /// is not found.
    /// </returns>
    /// <seealso cref="Delete"/>
    {$Endregion}
    Function Remove(Culture : TCultureInfo) : Integer; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Deletes a <see cref="TCultureInfo"/> object from the list by its locale identifier.
    /// </summary>
    /// <param name="LocaleID">
    /// The locale identifier.
    /// </param>
    /// <returns>
    /// The index of the removed <see cref="TCultureInfo"/> object, or -1 if the object
    /// is not found.
    /// </returns>
    /// <seealso cref="Delete"/>
    {$Endregion}
    Function Remove(LocaleID : LCID) : Integer; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Deletes a <see cref="TCultureInfo"/> object from the list by its locale name.
    /// </summary>
    /// <param name="Locale">
    /// The locale name.
    /// </param>
    /// <returns>
    /// The index of the removed <see cref="TCultureInfo"/> object, or -1 if the object
    /// is not found.
    /// </returns>
    /// <seealso cref="Delete"/>
    {$Endregion}
    Function Remove(Const Locale : String) : Integer; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Deletes a <see cref="TCultureInfo"/> object at a specified index of the list.
    /// </summary>
    /// <param name="Index">
    /// The index of <see cref="TCultureInfo"/> object to removed.
    /// </param>
    /// <seealso cref="Remove"/>
    {$Endregion}
    Procedure Delete(Index : Integer);
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the number of <see cref="TCultureInfo"/> objects the TCultureList object can hold.
    /// </summary>
    {$Endregion}
    Property Capacity : Integer Read GetCapacity Write SetCapacity;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether duplicate <see cref="TCultureInfo"/> objects can be added to the list.
    /// </summary>
    {$Endregion}
    Property Duplicates : TDuplicates Read fDuplicates Write fDuplicates;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs immediately after the list of <see cref="TCultureInfo"/> objects changes.
    /// </summary>
    {$Endregion}
    Property OnChange : TNotifyEvent Read fOnChange Write fOnChange;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs immediately before the list of <see cref="TCultureInfo"/> objects changes.
    /// </summary>
    {$Endregion}
    Property OnChanging : TNotifyEvent Read fOnChanging Write fOnChanging;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This enumeration type identifies the possible display names for
/// <see cref="TTerritoryInfo"/> objects.
/// </summary>
{$Endregion}

  TTerritoryDisplayName = (
  {$Region 'xmldoc'}
  /// Nothing
  {$Endregion}
  tnNone,
  {$Region 'xmldoc'}
  /// Two characters of the international country code specified in ISO 3166-2.
  {$Endregion}
  tnCode2,
  {$Region 'xmldoc'}
  /// Three characters of the international country code specified in ISO 3166-3.
  {$Endregion}
  tnCode3,
  {$Region 'xmldoc'}
  /// The friendly name of the nation, for example, Germany.
  {$Endregion}
  tnFriendlyName,
  {$Region 'xmldoc'}
  /// The official name of the nation, for example, Federal Republic of Germany.
  {$Endregion}
  tnOfficialName,
  {$Region 'xmldoc'}
  /// Full localized (in Windows user's language) name of the country/region, for
  /// example, Deutschland for Germany.
  {$Endregion}
  tnLocalizedName,
  {$Region 'xmldoc'}
  /// English name of the country/region, for example, Germany for Deutschland.
  {$Endregion}
  tnEnglishName,
  {$Region 'xmldoc'}
  /// Native name of the country/region, for example, Deutschland for Germany.
  {$Endregion}
  tnNativeName
  );

{$Region 'xmldoc'}
/// <summary>
/// This class represents a country/region.
/// </summary>
/// <remarks>
/// Each instance of TTerritoryInfo class represents a specific geographical location,
/// and has properties and methods to query information about it.
///
/// NOTE: Do not create or destroy an instance of TTerritoryInfo class. Use <see cref="TerritoryOf"/>
/// global function to get TTerritoryInfo instance of a geographical location.
/// </remarks>
/// <seealso cref="TerritoryOf"/>
/// <seealso cref="World.Territories"/>
{$Endregion}

    TTerritoryInfo = Class Sealed(TObject)
   Private
    fGeoID         : GEOID;
    fCode2         : String;
    fCode3         : String;
    fLatitude      : Double;
    fLongitude     : Double;
    fFriendlyName  : String;
    fOfficialName  : String;
    fLocalizedName : String;
    fEnglishName   : String;
    fCurrencies    : TCurrencyList;
    fCultures      : TCultureList;
    Function GetNativeName : String;
    Function GetCultures : TReadonlyCultureList; Inline;
    Function GetCurrencies : TReadonlyCurrencyList; Inline;
    Function GetDisplayNames(DisplayName : TTerritoryDisplayName) : String;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Associates the specified <see cref="TCultureInfo"/> and <see cref="TCurrencyInfo"/>
    /// objects to this TTerritoryInfo object.
    /// </summary>
    /// <param name="Culture">
    /// The <see cref="TCultureInfo"/> object.
    /// </param>
    /// <param name="Currency">
    /// The <see cref="TCurrencyInfo"/> object.
    /// </param>
    {$Endregion}
    Procedure Associate(Culture : TCultureInfo; Currency : TCurrencyInfo);
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the object for a specified geographical identifier.
    /// </summary>
    /// <param name="AGeoID">
    /// The geographical identifier.
    /// </param>
    /// <seealso cref="CreateByLocaleID"/>
    /// <seealso cref="CreateByLocale"/>
    {$Endregion}
    Constructor Create(AGeoID : GEOID);
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the object for a specified locale identifier.
    /// </summary>
    /// <param name="LocaleID">
    /// The locale identifier.
    /// </param>
    /// <param name="Dummy">
    /// This parameter is for compatibility with c++.
    /// </param>
    /// <seealso cref="Create"/>
    /// <seealso cref="CreateByLocale"/>
    {$Endregion}
    Constructor CreateByLocaleID(LocaleID : LCID; Dummy : Integer = 0);
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the object for a specified locale name.
    /// </summary>
    /// <param name="Locale">
    /// The locale name.
    /// </param>
    /// <seealso cref="Create"/>
    /// <seealso cref="CreateByLocaleID"/>
    {$Endregion}
    Constructor CreateByLocale(Const Locale : String);
    {$Region 'xmldoc'}
    /// <summary>
    /// Destroys the object and releases its allocated memory.
    /// </summary>
    {$Endregion}
    Destructor Destroy; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the geographical identifier of the country/region.
    /// </summary>
    {$Endregion}
    Property GEOID : GEOID Read fGeoID;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the two-character ISO 3166-2 international country code.
    /// </summary>
    {$Endregion}
    Property Code2 : String Read fCode2;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the three-character ISO 3166-3 international country code.
    /// </summary>
    {$Endregion}
    Property Code3 : String Read fCode3;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the geographical latitude of the territory's capital, in degrees.
    /// </summary>
    {$Endregion}
    Property Latitude : Double Read fLatitude;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the geographical longitude of the territory's capital, in degrees.
    /// </summary>
    {$Endregion}
    Property Longitude : Double Read fLongitude;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the friendly name of the nation.
    /// </summary>
    {$Endregion}
    Property FriendlyName : String Read fFriendlyName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the official name of the nation.
    /// </summary>
    {$Endregion}
    Property OfficialName : String Read fOfficialName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the localized (in Windows user's language) name of the country/region.
    /// </summary>
    {$Endregion}
    Property LocalizedName : String Read fLocalizedName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the English name of the country/region.
    /// </summary>
    {$Endregion}
    Property EnglishName : String Read fEnglishName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the Native name of the country/region.
    /// </summary>
    {$Endregion}
    Property NativeName : String Read GetNativeName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists different cultures in this country/region.
    /// </summary>
    {$Endregion}
    Property Cultures : TReadonlyCultureList Read GetCultures;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists authoritative currencies in this country/region.
    /// </summary>
    {$Endregion}
    Property Currencies : TReadonlyCurrencyList Read GetCurrencies;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists display names of the country/region.
    /// </summary>
    {$Endregion}
    Property DisplayNames[DisplayName : TTerritoryDisplayName] : String Read GetDisplayNames;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TTerritoryEnumerator enumerates through the <see cref="TTerritoryInfo"/> objects
/// of an instance of <see cref="TReadonlyTerritoryList"/> or its descendent class.
/// </summary>
{$Endregion}

  TTerritoryEnumerator = Class(TListEnumerator)
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the class for a specified list.
    /// </summary>
    /// <param name="list">
    /// The list to enumerate its items.
    /// </param>
    {$Endregion}
    Constructor Create(List : TReadonlyTerritoryList);
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the current <see cref="TTerritoryInfo"/> object of the list being
    /// enumerated.
    /// </summary>
    /// <returns>
    /// Returns the current <see cref="TTerritoryInfo"/> object.
    /// </returns>
    {$Endregion}
    Function GetCurrent : TTerritoryInfo; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the current <see cref="TTerritoryInfo"/> object.
    /// </summary>
    {$Endregion}
    Property Current : TTerritoryInfo Read GetCurrent;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class maintains a read-only list of <see cref="TTerritoryInfo"/> objects.
/// </summary>
/// <remarks>
/// TReadonlyTerritoryList maintains a read-only list of <see cref="TTerritoryInfo"/>
/// objects, and provides properties and methods to locate and access the objects.
/// The objects in the list are hashed and can be located quickly.
/// </remarks>
/// <see cref="TTerritoryList"/>
{$Endregion}

  TReadonlyTerritoryList = Class(TPersistent)
   Private
    LookupTable_GeoID        : TKeyLookup<GEOID, Integer>;
    LookupTable_Code2        : TKeyLookup<String, Integer>;
    LookupTable_Code3        : TKeyLookup<String, Integer>;
    IsLookupTableValid_GeoID : Boolean;
    IsLookupTableValid_Code2 : Boolean;
    IsLookupTableValid_Code3 : Boolean;
    Function GetCount : Integer; Inline;
    Function GetItems(Index : Integer) : TTerritoryInfo; Inline;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Provides direct access to the individual <see cref="TTerritoryInfo"/> objects.
    /// </summary>
    {$Endregion}
    List : TList;
    {$Region 'xmldoc'}
    /// <summary>
    /// Attaches a specified <see cref="TTerritoryInfo"/> object with a specified index
    /// in the list.
    /// </summary>
    /// <remarks>
    /// <para>
    /// NOTE: This method does not add the object to the list, it only creates its lookup
    /// entries for all the lookup tables.
    /// </para>
    /// </remarks>
    /// <param name="Territory">
    /// The <see cref="TTerritoryInfo"/> object to add to the lookup tables.
    /// </param>
    /// <param name="Index">
    /// The index of the <see cref="TTerritoryInfo"/> object in the list.
    /// </param>
    /// <seealso cref="RemoveLookupEntries"/>
    {$Endregion}
    Procedure AddLookupEntries(Territory : TTerritoryInfo; Index : Integer);
    {$Region 'xmldoc'}
    /// <summary>
    /// Detaches a specified <see cref="TTerritoryInfo"/> object from the previously attached
    /// index.
    /// </summary>
    /// <remarks>
    /// <para>
    /// NOTE: This method does not remove the object from the list, it only deletes its
    /// lookup entries from all lookup tables.
    /// </para>
    /// </remarks>
    /// <param name="Territory">
    /// The <see cref="TTerritoryInfo"/> object to remove from the lookup tables.
    /// </param>
    /// <seealso cref="AddLookupEntries"/>
    {$Endregion}
    Procedure RemoveLookupEntries(Territory : TTerritoryInfo);
    {$Region 'xmldoc'}
    /// <summary>
    /// Clears all entries from all lookup tables.
    /// </summary>
    {$Endregion}
    Procedure ClearLookupTables;
    {$Region 'xmldoc'}
    /// <summary>
    /// Schedules rebuilding of all lookup tables.
    /// </summary>
    {$Endregion}
    Procedure InvalidateLookupTables; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Validates lookup table for <see cref="TTerritoryInfo.GeoID"/> values.
    /// </summary>
    {$Endregion}
    Procedure ValidateLookupTable_GeoID;
    {$Region 'xmldoc'}
    /// <summary>
    /// Validates lookup table for <see cref="TTerritoryInfo.Code2"/> values.
    /// </summary>
    {$Endregion}
    Procedure ValidateLookupTable_Code2;
    {$Region 'xmldoc'}
    /// <summary>
    /// Validates lookup table for <see cref="TTerritoryInfo.Code3"/> values.
    /// </summary>
    {$Endregion}
    Procedure ValidateLookupTable_Code3;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the class.
    /// </summary>
    {$Endregion}
    Constructor Create; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Destroys the instance and releases its allocated memory.
    /// </summary>
    {$Endregion}
    Destructor Destroy; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TTerritoryEnumerator"/> reference, which enumerates
    /// all <see cref="TTerritoryInfo"/> objects in the list.
    /// </summary>
    /// <returns>
    /// Returns an instance of <see cref="TTerritoryEnumerator"/> class.
    /// </returns>
    {$Endregion}
    Function GetEnumerator : TTerritoryEnumerator;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the first <see cref="TTerritoryInfo"/> object in the list.
    /// </summary>
    /// <returns>
    /// The first <see cref="TTerritoryInfo"/> object in the list.
    /// </returns>
    /// <seealso cref="Last"/>
    {$Endregion}
    Function First : TTerritoryInfo;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the last <see cref="TTerritoryInfo"/> object in the list.
    /// </summary>
    /// <returns>
    /// The last <see cref="TTerritoryInfo"/> object in the list.
    /// </returns>
    /// <seealso cref="First"/>
    {$Endregion}
    Function Last : TTerritoryInfo;
    {$Region 'xmldoc'}
    /// <summary>
    /// Copies <see cref="TTerritoryInfo"/> objects in the list to another object.
    /// </summary>
    /// <param name="Dest">
    /// The destination object.
    /// </param>
    /// <seealso cref="AssignLabelsTo"/>
    {$Endregion}
    Procedure AssignTo(Dest : TPersistent); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Copies display name of <see cref="TTerritoryInfo"/> objects in the list to
    /// a <see cref="TStrings"/> object.
    /// </summary>
    /// <param name="Dest">
    /// The destination <see cref="TStrings"/> object.
    /// </param>
    /// <param name="DisplayName">
    /// Determines which <see cref="TTerritoryInfo.DisplayNames"/> value should be used.
    /// </param>
    /// <seealso cref="AssignTo"/>
    /// <seealso cref="TTerritoryInfo.DisplayNames"/>
    {$Endregion}
    Procedure AssignLabelsTo(Dest : TStrings; DisplayName : TTerritoryDisplayName);
    {$Region 'xmldoc'}
    /// <summary>
    /// Locates a <see cref="TTerritoryInfo"/> object in the list by its geographical identifier.
    /// </summary>
    /// <param name="GeoID">
    /// The geographical identifier.
    /// </param>
    /// <returns>
    /// The <see cref="TTerritoryInfo"/> object with the specified geographical identifier
    /// or <see langword="nil"/> if the object is not found.
    /// </returns>
    {$Endregion}
    Function Find(GEOID : GEOID) : TTerritoryInfo; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Locates a <see cref="TTerritoryInfo"/> object in the list by its two or three
    /// characters international country/region code.
    /// </summary>
    /// <param name="Code">
    /// The two or three characters international code.
    /// </param>
    /// <returns>
    /// The <see cref="TTerritoryInfo"/> object with the specified international code
    /// or <see langword="nil"/> if the object is not found.
    /// </returns>
    {$Endregion}
    Function Find(Const Code : String) : TTerritoryInfo; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Finds index of a specified <see cref="TTerritoryInfo"/> object in the list.
    /// </summary>
    /// <param name="Territory">
    /// The <see cref="TTerritoryInfo"/> object to locate.
    /// </param>
    /// <returns>
    /// The index of <see cref="TTerritoryInfo"/> object or -1 if the object is not found.
    /// </returns>
    /// <seealso cref="IndexOfName"/>
    {$Endregion}
    Function IndexOf(Territory : TTerritoryInfo) : Integer; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Finds index of a <see cref="TTerritoryInfo"/> object in the list by its geographical
    /// identifier.
    /// </summary>
    /// <param name="GeoID">
    /// The geographical identifier.
    /// </param>
    /// <returns>
    /// The index of <see cref="TTerritoryInfo"/> object or -1 if the object is not found.
    /// </returns>
    /// <seealso cref="IndexOfName"/>
    {$Endregion}
    Function IndexOf(GEOID : GEOID) : Integer; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Finds index of a <see cref="TTerritoryInfo"/> object in the list by its two or three
    /// characters international code.
    /// </summary>
    /// <param name="Code">
    /// The two or three characters international code.
    /// </param>
    /// <returns>
    /// The index of <see cref="TTerritoryInfo"/> object or -1 if the object is not found.
    /// </returns>
    /// <seealso cref="IndexOfName"/>
    {$Endregion}
    Function IndexOf(Const Code : String) : Integer; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Finds index of a <see cref="TTerritoryInfo"/> object in the list by its display name.
    /// </summary>
    /// <param name="AName">
    /// The display name of the target object.
    /// </param>
    /// <param name="DisplayName">
    /// Indicates which <see cref="TTerritoryInfo.DisplayNames"/> value should be used.
    /// </param>
    /// <returns>
    /// The index of <see cref="TTerritoryInfo"/> object or -1 if the object is not found.
    /// </returns>
    /// <seealso cref="IndexOf"/>
    {$Endregion}
    Function IndexOfName(Const AName : String; DisplayName : TTerritoryDisplayName) : Integer;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether a specified <see cref="TTerritoryInfo"/> object is in the list.
    /// </summary>
    /// <param name="Territory">
    /// The <see cref="TTerritoryInfo"/> object to examine.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the <see cref="TTerritoryInfo"/> object is in the
    /// list, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function Exists(Territory : TTerritoryInfo) : Boolean; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether a <see cref="TTerritoryInfo"/> object with a specified geographical
    /// identifier is in the list.
    /// </summary>
    /// <param name="GeoID">
    /// The geographical identifier.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if a <see cref="TTerritoryInfo"/> object with the
    /// specified geographical identifier is in the list, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function Exists(GEOID : GEOID) : Boolean; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether a <see cref="TTerritoryInfo"/> object with a specified two or three
    /// characters international code is in the list.
    /// </summary>
    /// <param name="Code">
    /// The two or three characters international code.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if a <see cref="TTerritoryInfo"/> object with the
    /// specified international code is in the list, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function Exists(Const Code : String) : Boolean; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the number of <see cref="TTerritoryInfo"/> objects in the list.
    /// </summary>
    {$Endregion}
    Property Count : Integer Read GetCount;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the <see cref="TTerritoryInfo"/> objects in the list.
    /// </summary>
    {$Endregion}
    Property Items[Index : Integer] : TTerritoryInfo Read GetItems; Default;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class maintains a list of <see cref="TTerritoryInfo"/> objects.
/// </summary>
/// <remarks>
/// Use TTerritoryList to store and maintain a list of <see cref="TTerritoryInfo"/>
/// objects. TTerritoryList provides properties and methods to add, delete, rearrange,
/// locate, access, and sort <see cref="TTerritoryInfo"/> objects.
/// </remarks>
{$Endregion}

  TTerritoryList = Class(TReadonlyTerritoryList)
   Private
    fDuplicates  : TDuplicates;
    fUpdateCount : Integer;
    fOnChanging  : TNotifyEvent;
    fOnChange    : TNotifyEvent;
    Function GetCapacity : Integer; Inline;
    Procedure SetCapacity(Value : Integer);
    Procedure ReadTerritory(Reader : TReader);
    Procedure WriteTerritory(Writer : TWriter);
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Reads and writes the <see cref="Items"/> property as if it were published.
    /// </summary>
    /// <param name="Filer">
    /// The current <see cref="TReader"/> or <see cref="TWriter"/> object that is
    /// loading or saving the list.
    /// </param>
    {$Endregion}
    Procedure DefineProperties(Filer : TFiler); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnChanging"/> event.
    /// </summary>
    /// <seealso cref="Change"/>
    {$Endregion}
    Procedure Changing; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnChange"/> event.
    /// </summary>
    /// <seealso cref="Changing"/>
    {$Endregion}
    Procedure Change; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the update level.
    /// </summary>
    {$Endregion}
    Property UpdateCount : Integer Read fUpdateCount;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Prevents generating of the <see cref="OnChanging"/> and <see cref="OnChange"/>
    /// events until the <see cref="EndUpdate"/> method is called.
    /// </summary>
    /// <seealso cref="EndUpdate"/>
    {$Endregion}
    Procedure BeginUpdate;
    {$Region 'xmldoc'}
    /// <summary>
    /// Reenables <see cref="OnChanging"/> and <see cref="OnChange"/> events generation
    /// that was turned off with the <see cref="BeginUpdate"/> method.
    /// </summary>
    /// <seealso cref="BeginUpdate"/>
    {$Endregion}
    Procedure EndUpdate;
    {$Region 'xmldoc'}
    /// <summary>
    /// Deletes all items from the list.
    /// </summary>
    {$Endregion}
    Procedure Clear;
    {$Region 'xmldoc'}
    /// <summary>
    /// Sorts the items in the list by a specified display name.
    /// </summary>
    /// <param name="OrderBy">
    /// Determines which <see cref="TTerritoryInfo.DisplayNames"/> value should the
    /// list be sorted by.
    /// </param>
    {$Endregion}
    Procedure Sort(OrderBy : TTerritoryDisplayName);
    {$Region 'xmldoc'}
    /// <summary>
    /// Copies the list of <see cref="TTerritoryInfo"/> objects from another object.
    /// </summary>
    /// <param name="Source">
    /// The source list.
    /// </param>
    /// <seealso cref="Apply"/>
    {$Endregion}
    Procedure Assign(Source : TPersistent); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Copies <see cref="TTerritoryInfo"/> objects of one list to another.
    /// </summary>
    /// <remarks>
    /// Call Apply to assign the elements of another list to this one. Assign combines
    /// the source list with this one using the logical operator specified by the
    /// <paramref name="Op"/> parameter.
    ///
    /// If the <paramref name="ListB"/> parameter is specified or not <see langword="nil"/>,
    /// then Apply first replaces all the elements of this list with those in <paramref name="ListA"/>,
    /// and then merges <paramref name="ListB"/> into this list using the operator specified
    /// by <paramref name="Op"/>.
    ///
    /// These operators are acceptable in Apply method:
    ///
    /// <list type="table">
    ///   <listheader>
    ///     <term>Operator</term>
    ///     <description>Description</description>
    ///   </listheader>
    ///   <item>
    ///     <term>laCopy</term>
    ///     <description>Destination becomes a copy of the source</description>
    ///   </item>
    ///   <item>
    ///     <term>laAnd</term>
    ///     <description>Intersection of the two lists</description>
    ///   </item>
    ///   <item>
    ///     <term>laOr</term>
    ///     <description>Union of the two lists</description>
    ///   </item>
    ///   <item>
    ///     <term>laXor</term>
    ///     <description>Only those not in both lists</description>
    ///   </item>
    ///   <item>
    ///     <term>laSrcUnique</term>
    ///     <description>Only those unique to source (same as laAnd followed by laXor)</description>
    ///   </item>
    ///   <item>
    ///     <term>laDestUnique</term>
    ///     <description>Only those unique to destination (same as laOr followed by laXor)</description>
    ///   </item>
    /// </list>
    ///
    /// </remarks>
    /// <param name="ListA">
    /// The source list.
    /// </param>
    /// <param name="Op">
    /// The operator that indicates how the two lists should be merged.
    /// </param>
    /// <param name="ListB">
    /// The optional and aditional source list.
    /// </param>
    /// <seealso cref="Assign"/>
    {$Endregion}
    Procedure Apply(ListA : TReadonlyTerritoryList; Op : TListAssignOp = laCopy; ListB : TReadonlyTerritoryList = Nil);
    {$Region 'xmldoc'}
    /// <summary>
    /// Adds a specified <see cref="TTerritoryInfo"/> object to the list.
    /// </summary>
    /// <param name="Territory">
    /// The <see cref="TTerritoryInfo"/> object to add.
    /// </param>
    /// <returns>
    /// The index of new <see cref="TTerritoryInfo"/> object in the list.
    /// </returns>
    {$Endregion}
    Function Add(Territory : TTerritoryInfo) : Integer; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Adds a <see cref="TTerritoryInfo"/> object to the list by its geographical identifier.
    /// </summary>
    /// <param name="GeoID">
    /// The geographical identifier.
    /// </param>
    /// <returns>
    /// The index of new <see cref="TTerritoryInfo"/> object in the list.
    /// </returns>
    {$Endregion}
    Function Add(GEOID : GEOID) : Integer; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Adds a <see cref="TTerritoryInfo"/> object to the list by its two or three
    /// character international code.
    /// </summary>
    /// <param name="Code">
    /// The two or three character international code.
    /// </param>
    /// <returns>
    /// The index of new <see cref="TTerritoryInfo"/> object in the list.
    /// </returns>
    {$Endregion}
    Function Add(Const Code : String) : Integer; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Deletes a specified <see cref="TTerritoryInfo"/> object from the list.
    /// </summary>
    /// <param name="Territory">
    /// The <see cref="TTerritoryInfo"/> object to remove.
    /// </param>
    /// <returns>
    /// The index of the removed <see cref="TTerritoryInfo"/> object, or -1 if the object
    /// is not found.
    /// </returns>
    /// <seealso cref="Delete"/>
    {$Endregion}
    Function Remove(Territory : TTerritoryInfo) : Integer; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Deletes a <see cref="TTerritoryInfo"/> object from the list by its geographical
    /// identifier.
    /// </summary>
    /// <param name="GeoID">
    /// The geographical identifier.
    /// </param>
    /// <returns>
    /// The index of the removed <see cref="TTerritoryInfo"/> object, or -1 if the object
    /// is not found.
    /// </returns>
    /// <seealso cref="Delete"/>
    {$Endregion}
    Function Remove(GEOID : GEOID) : Integer; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Deletes a <see cref="TTerritoryInfo"/> object from the list by its two or three
    /// characters international code.
    /// </summary>
    /// <param name="Code">
    /// The two or three character sinternational code.
    /// </param>
    /// <returns>
    /// The index of the removed <see cref="TTerritoryInfo"/> object, or -1 if the object
    /// is not found.
    /// </returns>
    /// <seealso cref="Delete"/>
    {$Endregion}
    Function Remove(Const Code : String) : Integer; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Deletes a <see cref="TTerritoryInfo"/> object at a specified index of the list.
    /// </summary>
    /// <param name="Index">
    /// The index of <see cref="TTerritoryInfo"/> object to remove.
    /// </param>
    /// <seealso cref="Remove"/>
    {$Endregion}
    Procedure Delete(Index : Integer);
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the number of <see cref="TTerritoryInfo"/> objects the TTerritoryList object can hold.
    /// </summary>
    {$Endregion}
    Property Capacity : Integer Read GetCapacity Write SetCapacity;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether duplicate <see cref="TTerritoryInfo"/> objects can be added to the list.
    /// </summary>
    {$Endregion}
    Property Duplicates : TDuplicates Read fDuplicates Write fDuplicates;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs immediately after the list of <see cref="TTerritoryInfo"/> objects changes.
    /// </summary>
    {$Endregion}
    Property OnChange : TNotifyEvent Read fOnChange Write fOnChange;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs immediately before the list of <see cref="TTerritoryInfo"/> objects changes.
    /// </summary>
    {$Endregion}
    Property OnChanging : TNotifyEvent Read fOnChanging Write fOnChanging;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This enumeration type identifies the possible display names for
/// <see cref="TCurrencyInfo"/> objects.
/// </summary>
{$Endregion}

  TCurrencyDisplayName = (
  {$Region 'xmldoc'}
  /// Nothing
  {$Endregion}
  crnNone,
  {$Region 'xmldoc'}
  /// Three characters of the international monetary symbol specified in ISO 4217.
  {$Endregion}
  crnIntlSymbol,
  {$Region 'xmldoc'}
  /// The full English name of the currency.
  {$Endregion}
  crnEnglishName,
  {$Region 'xmldoc'}
  /// The native name of the currency.
  {$Endregion}
  crnNativeName
  );

{$Region 'xmldoc'}
/// <summary>
/// This class represents a currency.
/// </summary>
/// <remarks>
/// Each instance of TCurrencyInfo class represents a specific currency and has properties
/// and methods to query information about it.
///
/// NOTE: Do not create or destroy an instance of TCurrencyInfo class. Use <see cref="CurrencyOf"/>
/// global function to get TCurrencyInfo instance of a currency.
/// </remarks>
/// <seealso cref="CurrencyOf"/>
/// <seealso cref="World.Currencies"/>
{$Endregion}

    TCurrencyInfo = Class Sealed(TObject)
   Private
    fIntlSymbol    : String;
    fLocalSymbol   : String;
    fEnglishName   : String;
    fCultures      : TCultureList;
    fCountries     : TTerritoryList;
    fOriginCountry : TTerritoryInfo;
    Function GetNativeName : String; Inline;
    Function GetCultures : TReadonlyCultureList; Inline;
    Function GetCountries : TReadonlyTerritoryList; Inline;
    Function GetDisplayNames(DisplayName : TCurrencyDisplayName) : String;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Associates the specified <see cref="TCultureInfo"/> and <see cref="TTerritoryInfo"/>
    /// objects to this TCurrencyInfo object.
    /// </summary>
    /// <param name="Culture">
    /// The <see cref="TCultureInfo"/> object.
    /// </param>
    /// <param name="Territory">
    /// The <see cref="TTerritoryInfo"/> object.
    /// </param>
    {$Endregion}
    Procedure Associate(Culture : TCultureInfo; Territory : TTerritoryInfo);
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the object for a specified locale identifier.
    /// </summary>
    /// <param name="LocaleID">
    /// The locale identifier.
    /// </param>
    {$Endregion}
    Constructor Create(LocaleID : LCID); Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the object for a specified locale name.
    /// </summary>
    /// <param name="Locale">
    /// The locale name.
    /// </param>
    {$Endregion}
    Constructor Create(Const Locale : String); Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Destroyes the object and releases its allocated memory.
    /// </summary>
    {$Endregion}
    Destructor Destroy; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Specifies the three-character ISO 4217 international monetary symbol of
    /// the currency.
    /// </summary>
    {$Endregion}
    Property IntlSymbol : String Read fIntlSymbol;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the local monetary symbol of the currency.
    /// </summary>
    {$Endregion}
    Property LocalSymbol : String Read fLocalSymbol;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the English name of the currency.
    /// </summary>
    {$Endregion}
    Property EnglishName : String Read fEnglishName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the native name of the currency.
    /// </summary>
    {$Endregion}
    Property NativeName : String Read GetNativeName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists cultures that this currency is authoritative in.
    /// </summary>
    {$Endregion}
    Property Cultures : TReadonlyCultureList Read GetCultures;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists countries/regions that this currency is authoritative in.
    /// </summary>
    {$Endregion}
    Property Countries : TReadonlyTerritoryList Read GetCountries;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the main country/region of the currency. The value of this property
    /// can be <see langword="nil"/>. For example, Euro has no main country.
    /// </summary>
    {$Endregion}
    Property OriginCountry : TTerritoryInfo Read fOriginCountry;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists display names of the currency.
    /// </summary>
    {$Endregion}
    Property DisplayNames[DisplayName : TCurrencyDisplayName] : String Read GetDisplayNames;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TCurrencyEnumerator enumerates through the <see cref="TCurrencyInfo"/> objects
/// of an instance of <see cref="TReadonlyCurrencyList"/> or its descendent class.
/// </summary>
{$Endregion}

  TCurrencyEnumerator = Class(TListEnumerator)
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the class for a specified list.
    /// </summary>
    /// <param name="list">
    /// The list to enumerate its items.
    /// </param>
    {$Endregion}
    Constructor Create(List : TReadonlyCurrencyList);
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the current <see cref="TCurrencyInfo"/> object of the list being
    /// enumerated.
    /// </summary>
    /// <returns>
    /// Returns the current <see cref="TCurrencyInfo"/> object.
    /// </returns>
    {$Endregion}
    Function GetCurrent : TCurrencyInfo; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the current <see cref="TCurrencyInfo"/> object.
    /// </summary>
    {$Endregion}
    Property Current : TCurrencyInfo Read GetCurrent;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class maintains a read-only list of <see cref="TCurrencyInfo"/> objects.
/// </summary>
/// <remarks>
/// TReadonlyCurrencyList maintains a read-only list of <see cref="TCurrencyInfo"/>
/// objects, and provides properties and methods to locate and access the objects.
/// The objects in the list are hashed and can be located quickly.
/// </remarks>
/// <see cref="TCurrencyList"/>
{$Endregion}

  TReadonlyCurrencyList = Class(TPersistent)
   Private
    LookupTable_IntlSymbol        : TKeyLookup<String, Integer>;
    IsLookupTableValid_IntlSymbol : Boolean;
    Function GetCount : Integer; Inline;
    Function GetItems(Index : Integer) : TCurrencyInfo; Inline;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Provides direct accress to the individual <see cref="TCurrencyInfo"/> objects.
    /// </summary>
    {$Endregion}
    List : TList;
    {$Region 'xmldoc'}
    /// <summary>
    /// Attaches a specified <see cref="TCurrencyInfo"/> object with a specified index
    /// in the list.
    ///
    /// NOTE: This method does not add the object to the list, it only creats its lookup
    /// entries for all the lookup tables.
    /// </summary>
    /// <param name="Currency">
    /// The <see cref="TCurrencyInfo"/> object to add to the lookup tables.
    /// </param>
    /// <param name="Index">
    /// The index of the <see cref="TCurrencyInfo"/> object in the list.
    /// </param>
    /// <seealso cref="RemoveLookupEntries"/>
    {$Endregion}
    Procedure AddLookupEntries(Currency : TCurrencyInfo; Index : Integer);
    {$Region 'xmldoc'}
    /// <summary>
    /// Detaches a specified <see cref="TCurrencyInfo"/> object from the previosuly
    /// attached index.
    ///
    /// NOTE: This method does not remove the object from the list, it only deletes its
    /// lookup entries from all lookup tables.
    /// </summary>
    /// <param name="Currency">
    /// The <see cref="TCurrencyInfo"/> object to remove from the lookup tables.
    /// </param>
    /// <seealso cref="AddLookupEntries"/>
    {$Endregion}
    Procedure RemoveLookupEntries(Currency : TCurrencyInfo);
    {$Region 'xmldoc'}
    /// <summary>
    /// Clears all entries from all lookup tables.
    /// </summary>
    {$Endregion}
    Procedure ClearLookupTables;
    {$Region 'xmldoc'}
    /// <summary>
    /// Schedules rebuilding of all lookup tables.
    /// </summary>
    {$Endregion}
    Procedure InvalidateLookupTables; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Validates lookup table for <see cref="TCurrencyInfo.IntlSymbol"/> values.
    /// </summary>
    {$Endregion}
    Procedure ValidateLookupTable_IntlSymbol;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creats an instance of the class.
    /// </summary>
    {$Endregion}
    Constructor Create; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Destroys the instance and releases its allocated memory.
    /// </summary>
    {$Endregion}
    Destructor Destroy; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TCurrencyEnumerator"/> reference, which enumerates
    /// all <see cref="TCurrencyInfo"/> objects in the list.
    /// </summary>
    /// <returns>
    /// Returns an instance of <see cref="TCurrencyEnumerator"/> class.
    /// </returns>
    {$Endregion}
    Function GetEnumerator : TCurrencyEnumerator;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the first <see cref="TCurrencyInfo"/> object in the list.
    /// </summary>
    /// <returns>
    /// The first <see cref="TCurrencyInfo"/> object in the list.
    /// </returns>
    /// <seealso cref="Last"/>
    {$Endregion}
    Function First : TCurrencyInfo;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the last <see cref="TCurrencyInfo"/> object in the list.
    /// </summary>
    /// <returns>
    /// The last <see cref="TCurrencyInfo"/> object in the list.
    /// </returns>
    /// <seealso cref="First"/>
    {$Endregion}
    Function Last : TCurrencyInfo;
    {$Region 'xmldoc'}
    /// <summary>
    /// Copies <see cref="TCurrencyInfo"/> objects in the list to another object.
    /// </summary>
    /// <param name="Dest">
    /// The destination object.
    /// </param>
    /// <seealso cref="AssignLabelsTo"/>
    {$Endregion}
    Procedure AssignTo(Dest : TPersistent); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Copies display name of <see cref="TCurrencyInfo"/> objects in the list to
    /// a <see cref="TStrings"/> object.
    /// </summary>
    /// <param name="Dest">
    /// The destination <see cref="TStrings"/> object.
    /// </param>
    /// <param name="DisplayName">
    /// Determines which <see cref="TCurrencyInfo.DisplayNames"/> value should be used.
    /// </param>
    /// <seealso cref="AssignTo"/>
    /// <seealso cref="TCurrencyInfo.DisplayNames"/>
    {$Endregion}
    Procedure AssignLabelsTo(Dest : TStrings; DisplayName : TCurrencyDisplayName);
    {$Region 'xmldoc'}
    /// <summary>
    /// Locates a <see cref="TCurrencyInfo"/> object in the list by its three characters
    /// international monetary symbol.
    /// </summary>
    /// <param name="IntlSymbol">
    /// The international monetary sumbol.
    /// </param>
    /// <returns>
    /// The <see cref="TCurrencyInfo"/> object with the specified international monetary
    /// sumbol or <see langword="nil"/> if the object is not found.
    /// </returns>
    {$Endregion}
    Function Find(Const IntlSymbol : String) : TCurrencyInfo;
    {$Region 'xmldoc'}
    /// <summary>
    /// Finds index of a specified <see cref="TCurrencyInfo"/> object in the list.
    /// </summary>
    /// <param name="Currency">
    /// The <see cref="TCurrencyInfo"/> object to locate.
    /// </param>
    /// <returns>
    /// The index of <see cref="TCurrencyInfo"/> object or -1 if the object is not found.
    /// </returns>
    /// <seealso cref="IndexOfName"/>
    {$Endregion}
    Function IndexOf(Currency : TCurrencyInfo) : Integer; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Finds index of a <see cref="TCurrencyInfo"/> object in the list by its three
    /// characters international monetary symbol.
    /// </summary>
    /// <param name="IntlSymbol">
    /// The international monetary symbol.
    /// </param>
    /// <returns>
    /// The index of <see cref="TCurrencyInfo"/> object or -1 if the object is not found.
    /// </returns>
    /// <seealso cref="IndexOfName"/>
    {$Endregion}
    Function IndexOf(Const IntlSymbol : String) : Integer; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Finds index of a <see cref="TCurrencyInfo"/> object in the list by its display name.
    /// </summary>
    /// <param name="AName">
    /// The display name of the target object.
    /// </param>
    /// <param name="DisplayName">
    /// Indicates which <see cref="TCurrencyInfo.DisplayNames"/> value should be used.
    /// </param>
    /// <returns>
    /// The index of <see cref="TCurrencyInfo"/> object or -1 if the object is not found.
    /// </returns>
    /// <seealso cref="IndexOf"/>
    {$Endregion}
    Function IndexOfName(Const AName : String; DisplayName : TCurrencyDisplayName) : Integer;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether a specified <see cref="TCurrencyInfo"/> object is in the list.
    /// </summary>
    /// <param name="Currency">
    /// The <see cref="TCurrencyInfo"/> object to examine.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the <see cref="TCurrencyInfo"/> object is in the
    /// list, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function Exists(Currency : TCurrencyInfo) : Boolean; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether a <see cref="TCurrencyInfo"/> object with a specified three characters
    /// international monetary symbol is in the list.
    /// </summary>
    /// <param name="IntlSymbol">
    /// The international monetary symbol.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if a <see cref="TCurrencyInfo"/> object with the
    /// specified international monetary symbol is in the list, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function Exists(Const IntlSymbol : String) : Boolean; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the number of <see cref="TCurrencyInfo"/> objects in the list.
    /// </summary>
    {$Endregion}
    Property Count : Integer Read GetCount;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the <see cref="TCurrencyInfo"/> objects in the list.
    /// </summary>
    {$Endregion}
    Property Items[Index : Integer] : TCurrencyInfo Read GetItems; Default;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class maintains a list of <see cref="TCurrencyInfo"/> objects.
/// </summary>
/// <remarks>
/// Use TCurrencyList to store and maintain a list of <see cref="TCurrencyInfo"/>
/// objects. TCurrencyList provides properties and methods to add, delete, rearrange,
/// locate, access, and sort <see cref="TCurrencyInfo"/> objects.
/// </remarks>
{$Endregion}

  TCurrencyList = Class(TReadonlyCurrencyList)
   Private
    fDuplicates  : TDuplicates;
    fUpdateCount : Integer;
    fOnChanging  : TNotifyEvent;
    fOnChange    : TNotifyEvent;
    Function GetCapacity : Integer; Inline;
    Procedure SetCapacity(Value : Integer);
    Procedure ReadCurrencies(Reader : TReader);
    Procedure WriteCurrencies(Writer : TWriter);
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Reads and writes the <see cref="Items"/> property as if it were published.
    /// </summary>
    /// <param name="Filer">
    /// The current <see cref="TReader"/> or <see cref="TWriter"/> object that is
    /// loading or saving the list.
    /// </param>
    {$Endregion}
    Procedure DefineProperties(Filer : TFiler); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnChanging"/> event.
    /// </summary>
    /// <seealso cref="Change"/>
    {$Endregion}
    Procedure Changing; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnChange"/> event.
    /// </summary>
    /// <seealso cref="Changing"/>
    {$Endregion}
    Procedure Change; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the update level.
    /// </summary>
    {$Endregion}
    Property UpdateCount : Integer Read fUpdateCount;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Prevents generating of the <see cref="OnChanging"/> and <see cref="OnChange"/>
    /// events until the <see cref="EndUpdate"/> method is called.
    /// </summary>
    /// <seealso cref="EndUpdate"/>
    {$Endregion}
    Procedure BeginUpdate;
    {$Region 'xmldoc'}
    /// <summary>
    /// Reenables <see cref="OnChanging"/> and <see cref="OnChange"/> events generation
    /// that was turned off with the <see cref="BeginUpdate"/> method.
    /// </summary>
    /// <seealso cref="BeginUpdate"/>
    {$Endregion}
    Procedure EndUpdate;
    {$Region 'xmldoc'}
    /// <summary>
    /// Deletes all items from the list.
    /// </summary>
    {$Endregion}
    Procedure Clear;
    {$Region 'xmldoc'}
    /// <summary>
    /// Sorts the items in the list by a specified display name.
    /// </summary>
    /// <param name="OrderBy">
    /// Determines which <see cref="TCurrencyInfo.DisplayNames"/> value should the
    /// list be sorted by.
    /// </param>
    {$Endregion}
    Procedure Sort(OrderBy : TCurrencyDisplayName);
    {$Region 'xmldoc'}
    /// <summary>
    /// Copies the list of <see cref="TCurrencyInfo"/> objects from another object.
    /// </summary>
    /// <param name="Source">
    /// The source list.
    /// </param>
    /// <seealso cref="Apply"/>
    {$Endregion}
    Procedure Assign(Source : TPersistent); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Copies <see cref="TCurrencyInfo"/> objects of one list to another.
    /// </summary>
    /// <remarks>
    /// Call Apply to assign the elements of another list to this one. Assign combines
    /// the source list with this one using the logical operator specified by the
    /// <paramref name="Op"/> parameter.
    ///
    /// If the <paramref name="ListB"/> parameter is specified or not <see langword="nil"/>,
    /// then Apply first replaces all the elements of this list with those in <paramref name="ListA"/>,
    /// and then merges <paramref name="ListB"/> into this list using the operator specified
    /// by <paramref name="Op"/>.
    ///
    /// These operators are acceptable in Apply method:
    ///
    /// <list type="table">
    ///   <listheader>
    ///     <term>Operator</term>
    ///     <description>Description</description>
    ///   </listheader>
    ///   <item>
    ///     <term>laCopy</term>
    ///     <description>Destination becomes a copy of the source</description>
    ///   </item>
    ///   <item>
    ///     <term>laAnd</term>
    ///     <description>Intersection of the two lists</description>
    ///   </item>
    ///   <item>
    ///     <term>laOr</term>
    ///     <description>Union of the two lists</description>
    ///   </item>
    ///   <item>
    ///     <term>laXor</term>
    ///     <description>Only those not in both lists</description>
    ///   </item>
    ///   <item>
    ///     <term>laSrcUnique</term>
    ///     <description>Only those unique to source (same as laAnd followed by laXor)</description>
    ///   </item>
    ///   <item>
    ///     <term>laDestUnique</term>
    ///     <description>Only those unique to destination (same as laOr followed by laXor)</description>
    ///   </item>
    /// </list>
    ///
    /// </remarks>
    /// <param name="ListA">
    /// The source list.
    /// </param>
    /// <param name="Op">
    /// The operator that indicates how the two lists should be merged.
    /// </param>
    /// <param name="ListB">
    /// The optional and aditional source list.
    /// </param>
    /// <seealso cref="Assign"/>
    {$Endregion}
    Procedure Apply(ListA : TReadonlyCurrencyList; Op : TListAssignOp = laCopy; ListB : TReadonlyCurrencyList = Nil);
    {$Region 'xmldoc'}
    /// <summary>
    /// Adds a specified <see cref="TCurrencyInfo"/> object to the list.
    /// </summary>
    /// <param name="Currency">
    /// The <see cref="TCurrencyInfo"/> object to add.
    /// </param>
    /// <returns>
    /// The index of new <see cref="TCurrencyInfo"/> object in the list.
    /// </returns>
    {$Endregion}
    Function Add(Currency : TCurrencyInfo) : Integer; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Adds a <see cref="TCurrencyInfo"/> object to the list by its three characters
    /// international monetary symbol.
    /// </summary>
    /// <param name="IntlSymbol">
    /// The international monetary symbol.
    /// </param>
    /// <returns>
    /// The index of new <see cref="TCurrencyInfo"/> object in the list.
    /// </returns>
    {$Endregion}
    Function Add(Const IntlSymbol : String) : Integer; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Deletes a specified <see cref="TCurrencyInfo"/> object from the list.
    /// </summary>
    /// <param name="Currency">
    /// The <see cref="TCurrencyInfo"/> object to remove.
    /// </param>
    /// <returns>
    /// The index of the removed <see cref="TCurrencyInfo"/> object, or -1 if the object
    /// is not found.
    /// </returns>
    /// <seealso cref="Delete"/>
    {$Endregion}
    Function Remove(Currency : TCurrencyInfo) : Integer; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Deletes a <see cref="TCurrencyInfo"/> object from the list by its three characters
    /// international monetry symbol.
    /// </summary>
    /// <param name="IntlSymbol">
    /// The international monetry symbol.
    /// </param>
    /// <returns>
    /// The index of the removed <see cref="TCurrencyInfo"/> object, or -1 if the object
    /// is not found.
    /// </returns>
    /// <seealso cref="Delete"/>
    {$Endregion}
    Function Remove(Const IntlSymbol : String) : Integer; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Deletes a <see cref="TCurrencyInfo"/> object at a specified index of the list.
    /// </summary>
    /// <param name="Index">
    /// The index of <see cref="TCurrencyInfo"/> object to remove.
    /// </param>
    /// <seealso cref="Remove"/>
    {$Endregion}
    Procedure Delete(Index : Integer);
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the number of <see cref="TCurrencyInfo"/> objects the TCurrencyList object can hold.
    /// </summary>
    {$Endregion}
    Property Capacity : Integer Read GetCapacity Write SetCapacity;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether duplicate <see cref="TCurrencyInfo"/> objects can be added to the list.
    /// </summary>
    {$Endregion}
    Property Duplicates : TDuplicates Read fDuplicates Write fDuplicates;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs immediately after the list of <see cref="TCurrencyInfo"/> objects changes.
    /// </summary>
    {$Endregion}
    Property OnChange : TNotifyEvent Read fOnChange Write fOnChange;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs immediately before the list of <see cref="TCurrencyInfo"/> objects changes.
    /// </summary>
    {$Endregion}
    Property OnChanging : TNotifyEvent Read fOnChanging Write fOnChanging;
  End;

{$Region 'xmldoc'}
/// <summary>
/// World class provides information about all cultures, territories, and
/// currencies.
/// </summary>
/// <remarks>
/// World class provides properties to locate and access all available
/// <see cref="TCultureInfo"/>, <see cref="TTerritoryInfo"/>, and
/// <see cref="TCurrencyInfo"/> objects.
/// </remarks>
{$Endregion}

  World = Class
   Private
    Class Var Changing : Boolean;
    Class Var CultureList : TCultureList;
    Class Var TerritoryList : TTerritoryList;
    Class Var CurrencyList : TCurrencyList;
    Class Procedure Startup; Static;
    Class Procedure Cleanup; Static;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the read-only list of all available <see cref="TCultureInfo"/> objects.
    /// </summary>
    /// <returns>
    /// The read-only list of all available <see cref="TCultureInfo"/> objects.
    /// </returns>
    {$Endregion}
    Class Function Cultures : TReadonlyCultureList; Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the read-only list of all available <see cref="TTerritoryInfo"/> objects.
    /// </summary>
    /// <returns>
    /// The read-only list of all available <see cref="TTerritoryInfo"/> objects.
    /// </returns>
    {$Endregion}
    Class Function Territories : TReadonlyTerritoryList; Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the read-only list of all available <see cref="TCurrencyInfo"/> objects.
    /// </summary>
    /// <returns>
    /// The read-only list of all available <see cref="TCurrencyInfo"/> objects.
    /// </returns>
    {$Endregion}
    Class Function Currencies : TReadonlyCurrencyList; Static;
  End;

{$Region 'xmldoc'}
/// <summary>
/// Indicates whether the i18n package functionality is available for the current
/// version of Windows.
/// </summary>
/// <remarks>
/// The i18n package is only supported by Windows XP and newer versions of Windows.
/// Use i18nAvailable to determine whether the current version of Windows can support
/// the i18n package or not.
/// </remarks>
/// <returns>
/// Returns <see langword="true"/> if the i18n package can be used, otherwise returns
/// <see langword="false"/>.
/// </returns>
{$Endregion}

 Function i18nAvailable : Boolean; Inline;

 {$Region 'xmldoc'}
 /// <summary>
 /// Returns the <see cref="TCultureInfo"/> object that represents the application's
 /// default locale.
 /// </summary>
 /// <returns>
 /// The <see cref="TCultureInfo"/> object.
 /// </returns>
 /// <seealso cref="GetSystemDefaultCulture"/>
 /// <seealso cref="GetUserDefaultCulture"/>
 /// <seealso cref="GetUserDefaultUICulture"/>
 {$Endregion}
 Function GetApplicationDefaultCulture : TCultureInfo;

 {$Region 'xmldoc'}
 /// <summary>
 /// Returns the <see cref="TCultureInfo"/> object that represents the system
 /// default locale.
 /// </summary>
 /// <returns>
 /// The <see cref="TCultureInfo"/> object.
 /// </returns>
 /// <seealso cref="GetUserDefaultCulture"/>
 /// <seealso cref="GetUserDefaultUICulture"/>
 {$Endregion}
 Function GetSystemDefaultCulture : TCultureInfo; Inline;

 {$Region 'xmldoc'}
 /// <summary>
 /// Returns the <see cref="TCultureInfo"/> object that represents the user's
 /// default locale.
 /// </summary>
 /// <returns>
 /// The <see cref="TCultureInfo"/> object.
 /// </returns>
 /// <seealso cref="GetUserDefaultUICulture"/>
 /// <seealso cref="GetSystemDefaultCulture"/>
 {$Endregion}
 Function GetUserDefaultCulture : TCultureInfo; Inline;

 {$Region 'xmldoc'}
 /// <summary>
 /// Returns the <see cref="TCultureInfo"/> object that represents the user's
 /// default user interface locale.
 /// </summary>
 /// <returns>
 /// The <see cref="TCultureInfo"/> object.
 /// </returns>
 /// <seealso cref="GetUserDefaultCulture"/>
 /// <seealso cref="GetSystemDefaultCulture"/>
 {$Endregion}
 Function GetUserDefaultUICulture : TCultureInfo;

 {$Region 'xmldoc'}
 /// <summary>
 /// Returns the <see cref="TTerritoryInfo"/> object that represents the geographical
 /// location of the user.
 /// </summary>
 /// <returns>
 /// The <see cref="TTerritoryInfo"/> object.
 /// </returns>
 {$Endregion}
 Function GetUserTerritory : TTerritoryInfo; Inline;

 {$Region 'xmldoc'}
 /// <summary>
 /// Returns the <see cref="TCultureInfo"/> object that represents a locale specified
 /// by its identifier.
 /// </summary>
 /// <remarks>
 /// <para>
 /// Use CultureOf to get information about a locale specified by its identifier.
 /// </para>
 /// <para>
 /// When the argument passed as <paramref name="Exact"/> parameter is <see langword="true"/>,
 /// the returned <see cref="TCultureInfo"/> object has the same locale as the locale
 /// specified by the <paramref name="LocaleID"/> parameter.
 /// </para>
 /// <para>
 /// When the argument passed as <paramref name="Exact"/> parameter is <see langword="false"/>,
 /// the returned <see cref="TCultureInfo"/> object is the nearest locale to the locale
 /// specified by the <paramref name="LocaleID"/> parameter if the exact match is not found.
 /// </para>
 /// </remarks>
 /// <param name="LocaleID">
 /// The locale identifier.
 /// </param>
 /// <param name="Exact">
 /// Indicates whether a dialect of the locale can be a match.
 /// </param>
 /// <returns>
 /// The <see cref="TCultureInfo"/> object or <see langword="nil"/> if the locale
 /// identifier is undefined.
 /// </returns>
 {$Endregion}
 Function CultureOf(LocaleID : LCID; Exact : Boolean = True) : TCultureInfo; Overload; Inline;

 {$Region 'xmldoc'}
 /// <summary>
 /// Returns the <see cref="TCultureInfo"/> object that represents a locale specified
 /// by its name.
 /// </summary>
 /// <remarks>
 /// <para>
 /// Use CultureOf to get information about a locale specified by its name.
 /// </para>
 /// <para>
 /// When the argument passed as <paramref name="Exact"/> parameter is <see langword="true"/>,
 /// the returned <see cref="TCultureInfo"/> object has the same locale as the locale
 /// specified by the <paramref name="Locale"/> parameter.
 /// </para>
 /// <para>
 /// When the argument passed as <paramref name="Exact"/> parameter is <see langword="false"/>,
 /// the returned <see cref="TCultureInfo"/> object is the nearest locale to the locale
 /// specified by the <paramref name="Locale"/> parameter if the exact match is not found.
 /// </para>
 /// </remarks>
 /// <param name="Locale">
 /// The locale name.
 /// </param>
 /// <param name="Exact">
 /// Indicates whether a dialect of the locale can be a match.
 /// </param>
 /// <returns>
 /// The <see cref="TCultureInfo"/> object or <see langword="nil"/> if the locale
 /// identifier is undefined.
 /// </returns>
 {$Endregion}
 Function CultureOf(Const Locale : String; Exact : Boolean = True) : TCultureInfo; Overload; Inline;

 {$Region 'xmldoc'}
 /// <summary>
 /// Returns the <see cref="TTerritoryInfo"/> object that represents a country/region
 /// specified by its geographical identifier.
 /// </summary>
 /// <param name="GeoID">
 /// The geographical identifier.
 /// </param>
 /// <returns>
 /// The <see cref="TTerritoryInfo"/> object or <see langword="nil"/> if the geographical
 /// identifier is undefined.
 /// </returns>
 {$Endregion}
 Function TerritoryOf(GEOID : GEOID) : TTerritoryInfo; Overload; Inline;

 {$Region 'xmldoc'}
 /// <summary>
 /// Returns the <see cref="TTerritoryInfo"/> object that represents a country/region
 /// specified by its two or three characters international code.
 /// </summary>
 /// <param name="Code">
 /// The two or three characters of the international code.
 /// </param>
 /// <returns>
 /// The <see cref="TTerritoryInfo"/> object or <see langword="nil"/> if the international
 /// code is undefined.
 /// </returns>
 {$Endregion}
 Function TerritoryOf(Const Code : String) : TTerritoryInfo; Overload; Inline;

 {$Region 'xmldoc'}
 /// <summary>
 /// Returns the <see cref="TCurrencyInfo"/> object that represents a currency specified
 /// by its international monetary symbol.
 /// </summary>
 /// <param name="IntlSymbol">
 /// The three characters of the international monetary symbol.
 /// </param>
 /// <returns>
 /// The <see cref="TCurrencyInfo"/> object or <see langword="nil"/> if the international
 /// monetary symbol is undefined.
 /// </returns>
 {$Endregion}
 Function CurrencyOf(Const IntlSymbol : String) : TCurrencyInfo; Inline;

 {$Region 'xmldoc'}
 /// <summary>
 /// Indicates whether two locale names represent the same primary language.
 /// </summary>
 /// <param name="Locale1">
 /// The first locale name.
 /// </param>
 /// <param name="Locale2">
 /// The second locale name.
 /// </param>
 /// <returns>
 /// Returns <see langword="true"/> if both locales represent the same primary
 /// language, otherwise returns <see langword="false"/>.
 /// </returns>
 /// <seealso cref="SameCountry"/>
 {$Endregion}
 Function SameLanguage(Const Locale1, Locale2 : String) : Boolean;

 {$Region 'xmldoc'}
 /// <summary>
 /// Indicates whether two locale names represent the same country.
 /// </summary>
 /// <param name="Locale1">
 /// The first locale name.
 /// </param>
 /// <param name="Locale2">
 /// The second locale name.
 /// </param>
 /// <returns>
 /// Returns <see langword="true"/> if both locales represent the same country,
 /// otherwise returns <see langword="false"/>.
 /// </returns>
 /// <seealso cref="SameLanguage"/>
 {$Endregion}
 Function SameCountry(Const Locale1, Locale2 : String) : Boolean;

 {$Region 'xmldoc'}
 /// <summary>
 /// Call DefaultCalendar to get the <see cref="TCalendar"/> object that indicates
 /// the default calendar of the application.
 /// </summary>
 /// <returns>
 /// Returns a <see cref="TCalendar"/> object.
 /// </returns>
 /// <seealso cref="ChangeDefaultCalendarType"/>
 {$Endregion}
 Function DefaultCalendar : TCalendar;

 {$Region 'xmldoc'}
 /// <summary>
 /// Call ChangeDefaultCalendarType to change the default calendar system of the
 /// application.
 /// </summary>
 /// <param name="CalendarClass">
 /// The <see cref="TCalendar"/> class that represents the new calendar system.
 /// </param>
 /// <seealso cref="DefaultCalendar"/>
 {$Endregion}
 Procedure ChangeDefaultCalendarType(CalendarClass : TCalendarClass);

Implementation

 Uses
  Types, i18nUtils, i18nCalGregorian;

 Resourcestring
  SInstanceCreateError = 'You cannot create an instance of %s class.';
  SInstanceDestroyError = 'You cannot destroy an instance of %s class.';
  SDuplicateItemError = 'List does not allow duplicates (%u)';

{ Helper Functions }

 Var
  TheDefaultCalendar      : TCalendar      = Nil;
  TheDefaultCalendarClass : TCalendarClass = TGregorianCalendar;

 Function i18nAvailable : Boolean;
  Begin
   Result := (WinVer >= $0501); // Windows XP or Later
  End;

 Function DefaultCalendar : TCalendar;
  Begin
   If Not Assigned(TheDefaultCalendar) Then
    TheDefaultCalendar := TheDefaultCalendarClass.Create(LOCALE_USER_DEFAULT);
   Result              := TheDefaultCalendar;
  End;

 Procedure ChangeDefaultCalendarType(CalendarClass : TCalendarClass);
  Begin
   If TheDefaultCalendarClass <> CalendarClass Then
    Begin
     TheDefaultCalendarClass := CalendarClass;
     If Assigned(TheDefaultCalendar) Then
      FreeAndNil(TheDefaultCalendar);
    End;
  End;

 Function GetApplicationDefaultCulture : TCultureInfo;
  Var
   AppFileName        : String;
   VerInfoSize, Dummy : Cardinal;
   VerInfo, Trans     : Pointer;
  Begin
   Result      := Nil;
   AppFileName := ParamStr(0);
   VerInfoSize := GetFileVersioninfoSize(PChar(AppFileName), Dummy);
   If VerInfoSize <> 0 Then
    Begin
     GetMem(VerInfo, VerInfoSize);
     Try
      If GetFileVersionInfo(PChar(PChar(AppFileName)), Dummy, VerInfoSize, VerInfo) And
      VerQueryValue(VerInfo, '\VarFileInfo\Translation', Trans, Dummy)
      Then
       Result := CultureOf(LoWord(PDWORD(Trans)^));
     Finally
      FreeMem(VerInfo);
     End;
    End;
   If Not Assigned(Result) Then
    Result := CultureOf('en-US');
  End;

 Function GetSystemDefaultCulture : TCultureInfo;
  Begin
   Result := World.Cultures.Find(GetSystemDefaultLCID);
  End;

 Function GetUserDefaultCulture : TCultureInfo;
  Begin
   Result := World.Cultures.Find(GetUserDefaultLCID);
  End;

{$INLINE OFF}

 Function GetUserDefaultUICulture : TCultureInfo;
  Begin
   Result := World.Cultures.Find(GetUserDefaultUILanguage);
  End;
{$INLINE AUTO}

 Function GetUserTerritory : TTerritoryInfo;
  Begin
   Result := World.Territories.Find(GetUserGeoID(GEOCLASS_NATION));
  End;

 Function CultureOf(LocaleID : LCID; Exact : Boolean) : TCultureInfo;
  Begin
   If Exact Then
    Result := World.Cultures.Find(LocaleID)
   Else
    Result := World.Cultures.FindNearest(LocaleID);
  End;

 Function CultureOf(Const Locale : String; Exact : Boolean) : TCultureInfo;
  Begin
   If Exact Then
    Result := World.Cultures.Find(Locale)
   Else
    Result := World.Cultures.FindNearest(Locale);
  End;

 Function TerritoryOf(GEOID : GEOID) : TTerritoryInfo;
  Begin
   Result := World.Territories.Find(GEOID);
  End;

 Function TerritoryOf(Const Code : String) : TTerritoryInfo;
  Begin
   Result := World.Territories.Find(Code);
  End;

 Function CurrencyOf(Const IntlSymbol : String) : TCurrencyInfo;
  Begin
   Result := World.Currencies.Find(IntlSymbol);
  End;

 Function SameLanguage(Const Locale1, Locale2 : String) : Boolean;
  Var
   S1, S2 : PChar;
  Begin
   Result := False;
   S1     := PChar(Locale1);
   S2     := PChar(Locale2);
   While (S1^ <> #0) And (S1^ <> '-') Do
    Begin
     If UpCase(S1^) <> UpCase(S2^) Then
      Exit;
     Inc(S1);
     Inc(S2);
    End;
   Result := (S2^ = #0) Or (S2^ = '-');
  End;

 Function SameCountry(Const Locale1, Locale2 : String) : Boolean;
  Var
   P1, P2 : PChar;
  Begin
   P1     := StrRScan(PChar(Locale1), '-');
   P2     := StrRScan(PChar(Locale2), '-');
   Result := (P1 <> Nil) And (P2 <> Nil) And (StrIComp(P1, P2) = 0);
  End;

 Function IsRightToLeftLanguage(LocaleID : LCID) : Boolean;
  Var
   i       : Integer;
   BufferA : Array [128..255] Of AnsiChar;
   BufferW : Array [128..256] Of WideChar;
  Begin
   Result      := False;
   For i       := Low(BufferA) To High(BufferA) Do
    BufferA[i] := AnsiChar(i);
   GetStringTypeExA(LocaleID, CT_CTYPE2, @BufferA,
   High(BufferA) - Low(BufferA) + 1, BufferW);
   For i := Low(BufferA) To High(BufferA) Do
    If Ord(BufferW[i]) = C2_RIGHTTOLEFT Then
     Begin
      Result := True;
      Exit;
     End;
  End;

{ TCulture }

 Constructor TCultureInfo.Create(ALocaleID : LCID);
  Var
   CurrencySymbol : String;
   PercentSign    : String;
  Begin
   If Not World.Changing Then
    Raise Exception.CreateResFmt(@SInstanceCreateError, [ClassName]);
   fLocaleID              := ALocaleID;
   fLocale                := LCIDToLocaleName(LocaleID);
   fLanguage2             := GetLocaleStr(LocaleID, LOCALE_SISO639LANGNAME, '');
   fLanguage3             := GetLocaleStr(LocaleID, LOCALE_SISO639LANGNAME2, '');
   fGeoID                 := GetLocaleInt(LocaleID, LOCALE_IGEOID, 0);
   fLocalizedDisplayName  := GetLocaleStr(LocaleID, LOCALE_SLOCALIZEDDISPLAYNAME, '');
   fEnglishDisplayName    := GetLocaleStr(LocaleID, LOCALE_SENGLISHDISPLAYNAME, '');
   fNativeDisplayName     := GetLocaleStr(LocaleID, LOCALE_SNATIVEDISPLAYNAME, '');
   fLocalizedLanguageName := GetLocaleStr(LocaleID, LOCALE_SLOCALIZEDLANGUAGENAME, '');
   fEnglishLanguageName   := GetLocaleStr(LocaleID, LOCALE_SENGLISHLANGUAGENAME, '');
   fNativeLanguageName    := GetLocaleStr(LocaleID, LOCALE_SNATIVELANGUAGENAME, '');
   fNativeCountryName     := GetLocaleStr(LocaleID, LOCALE_SNATIVECOUNTRYNAME, '');
   fNativeCurrencyName    := GetLocaleStr(LocaleID, LOCALE_SNATIVECURRNAME, '');
   fScriptCodes           := GetLocaleScripts(Locale);
   fScripts               := ScriptCodesToScripts(ScriptCodes);
   Case GetLocaleInt(LocaleID, LOCALE_IREADINGLAYOUT, -1) Of
    0 :
     fReadingLayout := rlLeftToRight;
    1 :
     fReadingLayout := rlRightToLeft;
    2 :
     fReadingLayout := rlTopToBottomColRightToLeft;
    3 :
     fReadingLayout := rlTopToBottomColLeftToRight;
   Else
     If IsRightToLeftLanguage(LocaleID) Then
      fReadingLayout := rlRightToLeft;
   End;
   If GetLocaleInt(LocaleID, LOCALE_IMEASURE, 0) = 0 Then
    fMeasurementSystem := msMetric
   Else
    fMeasurementSystem       := msUS;
   fDefaultCodePages[cpOEM]  := GetLocaleInt(LocaleID, LOCALE_IDEFAULTCODEPAGE, 0);
   fDefaultCodePages[cpANSI] := GetLocaleInt(LocaleID, LOCALE_IDEFAULTANSICODEPAGE, 0);
   fDefaultCodePages[cpMAC]  := GetLocaleInt(LocaleID, LOCALE_IDEFAULTMACCODEPAGE, 0);
   fNativeDigits             := GetLocaleStr(LocaleID, LOCALE_SNATIVEDIGITS, NOMINAL_DIGITS);
   fNativeCalendarType       := CalendarTypes.ByLocale(Locale);
   If Not Assigned(fNativeCalendarType) Then
    fNativeCalendarType := TGregorianCalendar;
   If GEOID <> 0 Then
    Begin
     fCountry := World.TerritoryList.Find(GEOID);
     If Not Assigned(fCountry) Then
      Begin
       fCountry := TTerritoryInfo.CreateByLocaleID(LocaleID);
       World.TerritoryList.Add(fCountry);
      End;
    End;
   CurrencySymbol := GetLocaleStr(LocaleID, LOCALE_SINTLSYMBOL, '');
   If CurrencySymbol <> '' Then
    Begin
     fCurrency := World.CurrencyList.Find(CurrencySymbol);
     If Not Assigned(fCurrency) Then
      Begin
       fCurrency := TCurrencyInfo.Create(LocaleID);
       World.CurrencyList.Add(fCurrency);
      End;
    End;
   If Assigned(fCountry) Then
    fCountry.Associate(Self, fCurrency);
   If Assigned(fCurrency) Then
    fCurrency.Associate(Self, fCountry);
   Case GetLocaleInt(LocaleID, LOCALE_IPOSITIVEPERCENT, 0) Of
    0 : fPercentPositive := '# %';
    1 : fPercentPositive := '#%';
    2 : fPercentPositive := '%#';
    3 : fPercentPositive := '% #';
   End;
   Case GetLocaleInt(LocaleID, LOCALE_INEGATIVEPERCENT, 0) Of
    0  : fPercentNegative := '-# %';
    1  : fPercentNegative := '-#%';
    2  : fPercentNegative := '-%#';
    3  : fPercentNegative := '%-#';
    4  : fPercentNegative := '%#-';
    5  : fPercentNegative := '#-%';
    6  : fPercentNegative := '#%-';
    7  : fPercentNegative := '-% #';
    8  : fPercentNegative := '# %-';
    9  : fPercentNegative := '% #-';
    10 : fPercentNegative := '% -#';
    11 : fPercentNegative := '#- %';
   End;
   PercentSign := GetLocaleStr(LocaleID, LOCALE_SPERCENT, '%');
   If PercentSign <> '%' Then
    Begin
     fPercentPositive := StringReplace(fPercentPositive, '%', PercentSign, []);
     fPercentNegative := StringReplace(fPercentNegative, '%', PercentSign, []);
    End;
   fPluralRule := TPluralForms.RuleOf(Locale, 'nplurals=1; plural=0; ASSUMED');
  End;

 Constructor TCultureInfo.Create(Const ALocale : String);
  Begin
   Create(LocaleNameToLCID(ALocale));
  End;

 Destructor TCultureInfo.Destroy;
  Begin
   If Not World.Changing Then
    Raise Exception.CreateResFmt(@SInstanceDestroyError, [ClassName]);
   If Assigned(fFormatSettings) Then
    Dispose(fFormatSettings);
   If Assigned(fNativeCalendar) Then
    fNativeCalendar.Free;
   If Assigned(fCalendarTypes) Then
    fCalendarTypes.Free;
   Inherited Destroy;
  End;

 Function TCultureInfo.GetDisplayNames(DisplayName : TCultureDisplayName) : String;
  Begin
   Case DisplayName Of
    cnLocale                : Result := Locale;
    cnLanguage              : Result := Language2;
    cnLanguage3             : Result := Language3;
    cnLocalizedDisplayName  : Result := LocalizedDisplayName;
    cnEnglishDisplayName    : Result := EnglishDisplayName;
    cnNativeDisplayName     : Result := NativeDisplayName;
    cnLocalizedLanguageName : Result := LocalizedLanguageName;
    cnEnglishLanguageName   : Result := EnglishLanguageName;
    cnNativeLanguageName    : Result := NativeLanguageName;
    cnNativeCountryName     : Result := NativeCountryName;
    cnNativeCurrencyName    : Result := NativeCurrencyName;
   Else Result := '';
   End;
  End;

 Function TCultureInfo.GetDefaultCodePages(CodePageType : TCodePageType) : Integer;
  Begin
   Result := fDefaultCodePages[CodePageType];
  End;

 Function TCultureInfo.GetLangID : LANGID;
  Begin
   Result := Windows.LANGID(LocaleID);
  End;

 Function TCultureInfo.GetPrimaryLangID : LANGID;
  Begin
   Result := Windows.PrimaryLangID(LocaleID);
  End;

 Function TCultureInfo.GetSubLangID : LANGID;
  Begin
   Result := Windows.SubLangID(LocaleID);
  End;

 Function TCultureInfo.GetBiDiMode : TBiDiMode;
  Begin
   If IsRightToLeft Then
    Result := bdRightToLeft
   Else
    Result := bdLeftToRight;
  End;

 Function TCultureInfo.GetFormatSettings : PFormatSettings;
  Begin
   If Not Assigned(fFormatSettings) Then
    Begin
     New(fFormatSettings);
     {$IFDEF COMPILER_XE2_UP}
     {$WARN SYMBOL_PLATFORM OFF}
     fFormatSettings^ := TFormatSettings.Create(LocaleID);
     {$WARN SYMBOL_PLATFORM ON}
     {$ELSE}
     GetLocaleFormatSettings(LocaleID, fFormatSettings^);
     {$ENDIF}
    End;
   Result := fFormatSettings;
  End;

 Function TCultureInfo.GetNativeCalendar : TCalendar;
  Begin
   If Not Assigned(fNativeCalendar) Then
    fNativeCalendar := NativeCalendarType.Create(Locale);
   Result           := fNativeCalendar;
  End;

 Function TCultureInfo.IsRightToLeft : Boolean;
  Begin
   Result := (ReadingLayout = rlRightToLeft);
  End;

 Function TCultureInfo.IsDefault : Boolean;
  Begin
   Result := (SubLangID = SUBLANG_DEFAULT);
  End;

 Function TCultureInfo.IsDialectOf(Culture : TCultureInfo) : Boolean;
  Begin
   Result := (Culture.PrimaryLangID = PrimaryLangID);
  End;

 Function TCultureInfo.IsDialectOf(Const Locale : String) : Boolean;
  Begin
   Result := (Pos(Language2, LowerCase(Locale)) = 1) And
   ((Length(Language2) = Length(Locale)) Or
   (Locale[Length(Language2) + 1] = '-'));
  End;

 Function TCultureInfo.IsDialectOf(LANGID : LANGID) : Boolean;
  Begin
   Result := (Windows.PrimaryLangID(LANGID) = PrimaryLangID);
  End;

 Function TCultureInfo.IsUsingNominalDigits : Boolean;
  Begin
   Result := (Pos('0', NativeDigits) = 1);
  End;

 Function TCultureInfo.IsUsingCommonEraCalendar : Boolean;
  Begin
   Result := (NativeCalendarType = TGregorianCalendar);
  End;

 Function TCultureInfo.DrawTextBiDiModeFlags(Flags : Cardinal) : Integer;
  Begin
   Result := Flags;
   If IsRightToLeft Then
    Begin
     If (Result And DT_RIGHT) = DT_RIGHT Then
      Result := Result And Not DT_RIGHT
     Else If (Result And DT_CENTER) <> DT_CENTER Then
      Result := Result Or DT_RIGHT;
    End;
   Result := Result Or DrawTextBiDiModeFlagsReadingOnly;
  End;

 Function TCultureInfo.DrawTextBiDiModeFlagsReadingOnly : Integer;
  Begin
   If IsRightToLeft Then
    Result := DT_RTLREADING
   Else
    Result := 0;
  End;

 Function TCultureInfo.VerifyString(Const Str : String; AllowLatin : Boolean) : Boolean;
  Begin
   Result := VerifyScripts(ScriptCodes, GetStringScripts(Str));
  End;

 Function TCultureInfo.OemToUnicode(Const Str : RawByteString) : String;
  Begin
   Result := CodePageToUnicode(DefaultCodePages[cpOEM], Str);
  End;

 Function TCultureInfo.UnicodeToOem(Const Str : String) : RawByteString;
  Begin
   Result := UnicodeToCodePage(DefaultCodePages[cpOEM], Str);
  End;

 Function TCultureInfo.AnsiToUnicode(Const Str : RawByteString) : String;
  Begin
   Result := CodePageToUnicode(DefaultCodePages[cpANSI], Str);
  End;

 Function TCultureInfo.UnicodeToAnsi(Const Str : String) : RawByteString;
  Begin
   Result := UnicodeToCodePage(DefaultCodePages[cpANSI], Str);
  End;

 Function TCultureInfo.MacToUnicode(Const Str : RawByteString) : String;
  Begin
   Result := CodePageToUnicode(DefaultCodePages[cpMAC], Str);
  End;

 Function TCultureInfo.UnicodeToMac(Const Str : String) : RawByteString;
  Begin
   Result := UnicodeToCodePage(DefaultCodePages[cpMAC], Str);
  End;

 Function TCultureInfo.NominalDigitsToNative(Const Str : String; IgnoreUCCs : Boolean) : String;
  Var
   s         : PChar;
   Zero      : Char;
   CanChange : Boolean;
  Begin
   Result := Str;
   Zero   := PChar(NativeDigits)^;
   If Zero <> '0' Then
    Begin
     CanChange := True;
     s         := PChar(Result);
     While s^ <> #0 Do
      Begin
       If s^ = UCC_NODS Then
        CanChange := IgnoreUCCs
       Else If s^ = UCC_NADS Then
        CanChange := True
       Else If CanChange And (s^ >= '0') And (s^ <= '9') Then
        s^ := Chr(Ord(Zero) + Ord(s^) - Ord('0'));
       Inc(s);
      End;
    End;
  End;

 Function TCultureInfo.NativeDigitsToNominal(Const Str : String; IgnoreUCCs : Boolean) : String;
  Var
   s         : PChar;
   Zero      : Char;
   CanChange : Boolean;
  Begin
   Result := Str;
   Zero   := PChar(NativeDigits)^;
   If Zero <> '0' Then
    Begin
     CanChange := True;
     s         := PChar(Result);
     While s^ <> #0 Do
      Begin
       If s^ = UCC_NADS Then
        CanChange := IgnoreUCCs
       Else If s^ = UCC_NODS Then
        CanChange := True
       Else If CanChange And (Cardinal(Ord(s^) - Ord(Zero)) <= 9) Then
        s^ := Chr(Ord('0') + Ord(s^) - Ord(Zero));
       Inc(s);
      End;
    End;
  End;

 Function TCultureInfo.FreezeDigits(Const Str : String; UseNativeDigits : Boolean) : String;
  Begin
   If UseNativeDigits Then
    Result := UCC_NODS + NominalDigitsToNative(Str, False)
   Else
    Result := UCC_NODS + Str;
  End;

 Function TCultureInfo.UnfreezeDigits(Const Str : String) : String;
  Begin
   Result := Str;
   If PChar(Result)^ = UCC_NODS Then
    Begin
     Delete(Result, 1, 1);
     Result := NativeDigitsToNominal(Result, False);
    End;
  End;

 Function TCultureInfo.Format(Const Fmt : String; Const Args : Array Of Const; UseNativeDigits : Boolean) : String;
  Begin
   Result := FreezeDigits(SysUtils.Format(Fmt, Args, FormatSettings^), UseNativeDigits);
  End;

 Function TCultureInfo.FormatNumber(Const Fmt : String; Const Value : Extended; UseNativeDigits : Boolean) : String;
  Begin
   Result := FreezeDigits(SysUtils.FormatFloat(Fmt, Value, FormatSettings^), UseNativeDigits);
  End;

 Function TCultureInfo.FormatPercent(Const Value : Extended; Decimals : Integer; UseNativeDigits : Boolean) : String;
  Var
   Str, Fmt : String;
  Begin
   If Decimals < 0 Then
    Fmt := '#,##0.' + StringOfChar('0', Abs(Decimals))
   Else
    Fmt := '#,##0.' + StringOfChar('#', Decimals);
   Str  := FormatNumber(Fmt, Abs(Value * 100.0), UseNativeDigits);
   If Value < 0 Then
    Result := StringReplace(fPercentNegative, '#', Str, [])
   Else
    Result := StringReplace(fPercentPositive, '#', Str, []);
  End;

 Function TCultureInfo.FormatDateTime(Const Fmt : String; Const Value : TDateTime; UseNativeDigits : Boolean) : String;
  Begin
   Result := FreezeDigits(NativeCalendar.Format(Fmt, Value), UseNativeDigits);
  End;

 Function TCultureInfo.ParseDateTime(Const Fmt : String; Const Str : String) : TDateTime;
  Begin
   Result := NativeCalendar.Parse(Fmt, UnfreezeDigits(Str));
  End;

 Function TCultureInfo.TryParseDateTime(Const Fmt : String; Const Str : String; Var DateTime : TDateTime) : Boolean;
  Begin
   Result := NativeCalendar.TryParse(Fmt, UnfreezeDigits(Str), DateTime);
  End;

{ TCultureEnumerator }

 Constructor TCultureEnumerator.Create(List : TReadonlyCultureList);
  Begin
   Inherited Create(List.List);
  End;

 Function TCultureEnumerator.GetCurrent : TCultureInfo;
  Begin
   Result := TCultureInfo(Inherited GetCurrent);
  End;

{ TReadonlyCultureList }

 Constructor TReadonlyCultureList.Create;
  Begin
   List := TList.Create;
  End;

 Destructor TReadonlyCultureList.Destroy;
  Begin
   List.Free;
   If Assigned(Lookup_LocaleID) Then
    Lookup_LocaleID.Free;
   If Assigned(Lookup_Locale) Then
    Lookup_Locale.Free;
   Inherited;
  End;

 Function TReadonlyCultureList.GetCount : Integer;
  Begin
   Result := List.Count;
  End;

 Function TReadonlyCultureList.GetItems(Index : Integer) : TCultureInfo;
  Begin
   Result := TCultureInfo(List[Index]);
  End;

 Function TReadonlyCultureList.GetEnumerator : TCultureEnumerator;
  Begin
   Result := TCultureEnumerator.Create(Self);
  End;

 Procedure TReadonlyCultureList.AddLookupEntries(Culture : TCultureInfo; Index : Integer);
  Begin
   If IsLookupTableValid_LocaleID Then
    Lookup_LocaleID.Add(Culture.LocaleID, Index);
   If IsLookupTableValid_Locale Then
    Lookup_Locale.Add(AnsiLowerCase(Culture.Locale), Index);
  End;

 Procedure TReadonlyCultureList.RemoveLookupEntries(Culture : TCultureInfo);
  Begin
   If IsLookupTableValid_LocaleID Then
    Lookup_LocaleID.Remove(Culture.LocaleID);
   If IsLookupTableValid_Locale Then
    Lookup_Locale.Remove(AnsiLowerCase(Culture.Locale));
  End;

 Procedure TReadonlyCultureList.ClearLookupTables;
  Begin
   If Assigned(Lookup_LocaleID) Then
    Begin
     Lookup_LocaleID.Clear;
     IsLookupTableValid_LocaleID := False;
    End;
   If Assigned(Lookup_Locale) Then
    Begin
     Lookup_Locale.Clear;
     IsLookupTableValid_Locale := False;
    End;
  End;

 Procedure TReadonlyCultureList.InvalidateLookupTables;
  Begin
   IsLookupTableValid_LocaleID := False;
   IsLookupTableValid_Locale   := False;
  End;

 Procedure TReadonlyCultureList.ValidateLookupTable_LocaleID;
  Var
   i : Integer;
  Begin
   If Not IsLookupTableValid_LocaleID Then
    Begin
     If Assigned(Lookup_LocaleID) Then
      Lookup_LocaleID.Clear
     Else
      Lookup_LocaleID := TKeyLookup<LCID, Integer>.Create;
     For i            := 0 To Count - 1 Do
      Lookup_LocaleID.Add(Items[i].LocaleID, i);
     IsLookupTableValid_LocaleID := True;
    End;
  End;

 Procedure TReadonlyCultureList.ValidateLookupTable_Locale;
  Var
   i : Integer;
  Begin
   If Not IsLookupTableValid_Locale Then
    Begin
     If Assigned(Lookup_Locale) Then
      Lookup_Locale.Clear
     Else
      Lookup_Locale := TKeyLookup<String, Integer>.Create;
     For i          := 0 To Count - 1 Do
      Lookup_Locale.Add(LowerCase(Items[i].Locale), i);
     IsLookupTableValid_Locale := True;
    End;
  End;

 Function TReadonlyCultureList.First : TCultureInfo;
  Begin
   If Count <> 0 Then
    Result := Items[0]
   Else
    Result := Nil;
  End;

 Function TReadonlyCultureList.Last : TCultureInfo;
  Begin
   If Count <> 0 Then
    Result := Items[Count - 1]
   Else
    Result := Nil;
  End;

 Procedure TReadonlyCultureList.AssignTo(Dest : TPersistent);
  Var
   Strings : TStrings Absolute Dest;
   i       : Integer;
  Begin
   If Dest Is TStrings Then
    Begin
     Strings.BeginUpdate;
     Try
      Strings.Clear;
      For i := 0 To Count - 1 Do
       Strings.AddObject(Items[i].Locale, Items[i]);
     Finally
      Strings.EndUpdate;
     End;
    End
   Else
    Inherited AssignTo(Dest);
  End;

 Procedure TReadonlyCultureList.AssignLabelsTo(Dest : TStrings; DisplayName : TCultureDisplayName);
  Var
   i : Integer;
  Begin
   Dest.BeginUpdate;
   Try
    Dest.Clear;
    For i := 0 To Count - 1 Do
     Dest.AddObject(Items[i].DisplayNames[DisplayName], Items[i]);
   Finally
    Dest.EndUpdate;
   End;
  End;

 Function TReadonlyCultureList.Find(LocaleID : LCID) : TCultureInfo;
  Var
   Index : Integer;
  Begin
   If Not IsLookupTableValid_LocaleID Then
    ValidateLookupTable_LocaleID;
   If Lookup_LocaleID.Retrieve(LocaleID, Index) Then
    Result := Items[Index]
   Else
    Result := Nil;
  End;

 Function TReadonlyCultureList.Find(Const Locale : String) : TCultureInfo;
  Var
   Index : Integer;
  Begin
   If Not IsLookupTableValid_Locale Then
    ValidateLookupTable_Locale;
   If Lookup_Locale.Retrieve(LowerCase(Locale), Index) Then
    Result := Items[Index]
   Else
    Result := Nil;
  End;

 Function TReadonlyCultureList.FindNearest(Culture : TCultureInfo) : TCultureInfo;
  Var
   Index : Integer;
  Begin
   Index := NearestIndexOf(Culture);
   If Index >= 0 Then
    Result := Items[Index]
   Else
    Result := Nil;
  End;

 Function TReadonlyCultureList.FindNearest(LocaleID : LCID) : TCultureInfo;
  Var
   Index : Integer;
  Begin
   Index := NearestIndexOf(LocaleID);
   If Index >= 0 Then
    Result := Items[Index]
   Else
    Result := Nil;
  End;

 Function TReadonlyCultureList.FindNearest(Const Locale : String) : TCultureInfo;
  Var
   Index : Integer;
  Begin
   Index := NearestIndexOf(Locale);
   If Index >= 0 Then
    Result := Items[Index]
   Else
    Result := Nil;
  End;

 Function TReadonlyCultureList.IndexOf(Culture : TCultureInfo) : Integer;
  Begin
   If Assigned(Culture) Then
    Result := IndexOf(Culture.LocaleID)
   Else
    Result := -1;
  End;

 Function TReadonlyCultureList.IndexOf(LocaleID : LCID) : Integer;
  Begin
   If Not IsLookupTableValid_LocaleID Then
    ValidateLookupTable_LocaleID;
   If Not Lookup_LocaleID.Retrieve(LocaleID, Result) Then
    Result := -1;
  End;

 Function TReadonlyCultureList.IndexOf(Const Locale : String) : Integer;
  Begin
   If Not IsLookupTableValid_Locale Then
    ValidateLookupTable_Locale;
   If Not Lookup_Locale.Retrieve(LowerCase(Locale), Result) Then
    Result := -1;
  End;

 Function TReadonlyCultureList.IndexOfName(Const AName : String; DisplayName : TCultureDisplayName) : Integer;
  Var
   i : Integer;
  Begin
   For i := 0 To Count - 1 Do
    If AnsiSameText(Items[i].DisplayNames[DisplayName], AName) Then
     Begin
      Result := i;
      Exit;
     End;
   Result := -1;
  End;

 Function TReadonlyCultureList.NearestIndexOf(Culture : TCultureInfo) : Integer;
  Begin
   If Assigned(Culture) Then
    Result := NearestIndexOf(Culture.LocaleID)
   Else
    Result := -1;
  End;

 Function TReadonlyCultureList.NearestIndexOf(LocaleID : LCID) : Integer;
  Var
   PriID, SubID : LANGID;
   i            : Integer;
  Begin
   Result := IndexOf(LocaleID);
   If Result >= 0 Then
    Exit;
   PriID := Windows.PrimaryLangID(LocaleID);
   If PriID = 0 Then
    Exit;
   SubID := High(LANGID);
   For i := 0 To Count - 1 Do
    With Items[i] Do
     Begin
      If PrimaryLangID <> PriID Then
       Continue;
      If IsDefault Then
       Begin
        Result := i;
        Exit;
       End;
      If (Result < 0) Or (SubLangID < SubID) Then
       Begin
        Result := i;
        SubID  := SubLangID;
       End;
     End;
  End;

 Function TReadonlyCultureList.NearestIndexOf(Const Locale : String) : Integer;
  Var
   Lang  : String;
   SubID : LANGID;
   i     : Integer;
  Begin
   Result := IndexOf(Locale);
   If Result >= 0 Then
    Exit;
   i := Pos('-', Locale);
   If i <> 0 Then
    Lang := LowerCase(Copy(Locale, 1, i - 1))
   Else
    Lang := LowerCase(Locale);
   If Lang = '' Then
    Exit;
   SubID := High(LANGID);
   For i := 0 To Count - 1 Do
    With Items[i] Do
     Begin
      If Language2 <> Lang Then
       Continue;
      If IsDefault Then
       Begin
        Result := i;
        Exit;
       End;
      If (Result < 0) Or (SubLangID < SubID) Then
       Begin
        Result := i;
        SubID  := SubLangID;
       End;
     End;
  End;

 Function TReadonlyCultureList.Exists(Culture : TCultureInfo) : Boolean;
  Begin
   Result := Assigned(Culture) And Exists(Culture.LocaleID);
  End;

 Function TReadonlyCultureList.Exists(LocaleID : LCID) : Boolean;
  Begin
   If Not IsLookupTableValid_LocaleID Then
    ValidateLookupTable_LocaleID;
   Result := Lookup_LocaleID.Exists(LocaleID);
  End;

 Function TReadonlyCultureList.Exists(Const Locale : String) : Boolean;
  Begin
   If Not IsLookupTableValid_Locale Then
    ValidateLookupTable_Locale;
   Result := Lookup_Locale.Exists(LowerCase(Locale));
  End;

{ TCultureList }

 Function TCultureList.GetCapacity : Integer;
  Begin
   Result := List.Capacity;
  End;

 Procedure TCultureList.SetCapacity(Value : Integer);
  Begin
   List.Capacity := Value;
   If Value < Count Then
    InvalidateLookupTables;
  End;

 Procedure TCultureList.ReadLocales(Reader : TReader);
  Var
   Locale : String;
  Begin
   BeginUpdate;
   Try
    Clear;
    Reader.ReadListBegin;
    While Not Reader.EndOfList Do
     Begin
      Locale := Reader.ReadString;
      If Locale = '*' Then
       Begin
        Assign(World.Cultures);
        Break;
       End;
      Add(Locale);
     End;
    Reader.ReadListEnd;
   Finally
    EndUpdate;
   End;
  End;

 Procedure TCultureList.WriteLocales(Writer : TWriter);
  Var
   i : Integer;
  Begin
   Writer.WriteListBegin;
   If (Duplicates <> dupAccept) And (Count = World.Cultures.Count) Then
    Writer.WriteString('*') // all cultures
   Else
    For i := 0 To Count - 1 Do
     Writer.WriteString(Items[i].Locale);
   Writer.WriteListEnd;
  End;

 Procedure TCultureList.DefineProperties(Filer : TFiler);
  Begin
   Inherited DefineProperties(Filer);
   Filer.DefineProperty('Cultures', ReadLocales, WriteLocales, Count <> 0);
  End;

 Procedure TCultureList.Change;
  Begin
   If (UpdateCount = 0) And Assigned(OnChange) Then
    OnChange(Self);
  End;

 Procedure TCultureList.Changing;
  Begin
   If (UpdateCount = 0) And Assigned(OnChanging) Then
    OnChanging(Self);
  End;

 Procedure TCultureList.BeginUpdate;
  Begin
   If UpdateCount = 0 Then
    Changing;
   Inc(fUpdateCount);
  End;

 Procedure TCultureList.EndUpdate;
  Begin
   Dec(fUpdateCount);
   If UpdateCount = 0 Then
    Change;
  End;

 Procedure TCultureList.Clear;
  Begin
   If Count <> 0 Then
    Begin
     Changing;
     Try
      List.Clear;
      ClearLookupTables;
     Finally
      Change;
     End;
    End;
  End;

 Procedure TCultureList.Sort(OrderBy : TCultureDisplayName);

   Procedure QuickSort(l, r : Integer);
    Var
     i, j, p : Integer;
     Pivot   : String;
    Begin
     Repeat
      i := l;
      j := r;
      p := (l + r) Shr 1;
      Repeat
       Pivot := Items[p].DisplayNames[OrderBy];
       While AnsiCompareText(Items[i].DisplayNames[OrderBy], Pivot) < 0 Do
        Inc(i);
       While AnsiCompareText(Items[j].DisplayNames[OrderBy], Pivot) > 0 Do
        Dec(j);
       If i <= j Then
        Begin
         If i <> j Then
          Begin
           List.Exchange(i, j);
           InvalidateLookupTables;
          End;
         If p = i Then
          p := j
         Else If p = j Then
          p := i;
         Inc(i);
         Dec(j);
        End;
      Until i > j;
      If l < j Then
       QuickSort(l, j);
      l := i;
     Until i >= r;
    End;

  Begin
   If (OrderBy <> cnNone) And (Count > 1) Then
    Begin
     Changing;
     Try
      QuickSort(0, Count - 1);
     Finally
      Change;
     End;
    End;
  End;

 Procedure TCultureList.Assign(Source : TPersistent);
  Begin
   If Source Is TReadonlyCultureList Then
    Apply(TReadonlyCultureList(Source), laCopy)
   Else
    Inherited Assign(Source);
  End;

 Procedure TCultureList.Apply(ListA : TReadonlyCultureList; Op : TListAssignOp; ListB : TReadonlyCultureList);
  Begin
   Changing;
   Try
    If Assigned(ListB) Then
     List.Assign(ListA.List, Op, ListB.List)
    Else
     List.Assign(ListA.List, Op, Nil);
    InvalidateLookupTables;
   Finally
    Change;
   End;
  End;

 Function TCultureList.Add(Culture : TCultureInfo) : Integer;
  Begin
   Result := -1;
   If Assigned(Culture) Then
    Begin
     If Duplicates <> dupAccept Then
      Begin
       Result := IndexOf(Culture);
       If Result >= 0 Then
        Begin
         If Duplicates = dupError Then
          Raise EListError.CreateResFmt(@SDuplicateItemError, [Result]);
         Exit;
        End;
      End;
     Changing;
     Try
      Result := List.Add(Culture);
      AddLookupEntries(Culture, Result);
     Finally
      Change;
     End;
    End;
  End;

 Function TCultureList.Add(LocaleID : LCID) : Integer;
  Begin
   Result := Add(World.Cultures.Find(LocaleID));
  End;

 Function TCultureList.Add(Const Locale : String) : Integer;
  Begin
   Result := Add(World.Cultures.Find(Locale));
  End;

 Function TCultureList.Remove(Culture : TCultureInfo) : Integer;
  Begin
   Result := IndexOf(Culture);
   If Result >= 0 Then
    Delete(Result);
  End;

 Function TCultureList.Remove(LocaleID : LCID) : Integer;
  Begin
   Result := IndexOf(LocaleID);
   If Result >= 0 Then
    Delete(Result);
  End;

 Function TCultureList.Remove(Const Locale : String) : Integer;
  Begin
   Result := IndexOf(Locale);
   If Result >= 0 Then
    Delete(Result);
  End;

 Procedure TCultureList.Delete(Index : Integer);
  Begin
   Changing;
   Try
    RemoveLookupEntries(Items[Index]);
    List.Delete(Index);
   Finally
    Change;
   End;
  End;

{ TTerritory }

 Constructor TTerritoryInfo.Create(AGeoID : GEOID);
  Begin
   If Not World.Changing Then
    Raise Exception.CreateResFmt(@SInstanceCreateError, [ClassName]);
   fCultures      := TCultureList.Create;
   fCurrencies    := TCurrencyList.Create;
   fGeoID         := AGeoID;
   fCode2         := GetGeoStr(GEOID, GEO_ISO2, '');
   fCode3         := GetGeoStr(GEOID, GEO_ISO3, '');
   fLatitude      := StrToFloatDef(GetGeoStr(GEOID, GEO_LATITUDE, '0'), 0);
   fLongitude     := StrToFloatDef(GetGeoStr(GEOID, GEO_LONGITUDE, '0'), 0);
   fFriendlyName  := GetGeoStr(GEOID, GEO_FRIENDLYNAME, '');
   fOfficialName  := GetGeoStr(GEOID, GEO_OFFICIALNAME, '');
   fLocalizedName := FriendlyName;
   fEnglishName   := FriendlyName;
  End;

 Constructor TTerritoryInfo.CreateByLocaleID(LocaleID : LCID; Dummy : Integer);
  Begin
   Create(GetLocaleInt(LocaleID, LOCALE_IGEOID, 0));
   fLocalizedName := GetLocaleStr(LocaleID, LOCALE_SLOCALIZEDCOUNTRYNAME, '');
   fEnglishName   := GetLocaleStr(LocaleID, LOCALE_SENGLISHCOUNTRYNAME, '');
  End;

 Constructor TTerritoryInfo.CreateByLocale(Const Locale : String);
  Begin
   CreateByLocaleID(LocaleNameToLCID(Locale));
  End;

 Destructor TTerritoryInfo.Destroy;
  Begin
   If Not World.Changing Then
    Raise Exception.CreateResFmt(@SInstanceDestroyError, [ClassName]);
   fCultures.Free;
   fCurrencies.Free;
   Inherited Destroy;
  End;

 Function TTerritoryInfo.GetDisplayNames(DisplayName : TTerritoryDisplayName) : String;
  Begin
   Case DisplayName Of
    tnCode2         : Result := Code2;
    tnCode3         : Result := Code3;
    tnFriendlyName  : Result := FriendlyName;
    tnOfficialName  : Result := OfficialName;
    tnLocalizedName : Result := LocalizedName;
    tnEnglishName   : Result := EnglishName;
    tnNativeName    : Result := NativeName;
   Else Result := '';
   End;
  End;

 Function TTerritoryInfo.GetNativeName : String;
  Begin
   If Cultures.Count <> 0 Then
    Result := Cultures[0].NativeCountryName
   Else
    Result := '';
  End;

 Function TTerritoryInfo.GetCurrencies : TReadonlyCurrencyList;
  Begin
   Result := fCurrencies;
  End;

 Function TTerritoryInfo.GetCultures : TReadonlyCultureList;
  Begin
   Result := fCultures;
  End;

 Procedure TTerritoryInfo.Associate(Culture : TCultureInfo; Currency : TCurrencyInfo);
  Begin
   If Assigned(Culture) And Not fCultures.Exists(Culture) Then
    fCultures.Add(Culture);
   If Assigned(Currency) And Not fCurrencies.Exists(Currency) Then
    fCurrencies.Add(Currency);
  End;

{ TTerritoryEnumerator }

 Constructor TTerritoryEnumerator.Create(List : TReadonlyTerritoryList);
  Begin
   Inherited Create(List.List);
  End;

 Function TTerritoryEnumerator.GetCurrent : TTerritoryInfo;
  Begin
   Result := TTerritoryInfo(Inherited GetCurrent);
  End;

{ TReadonlyTerritoryList }

 Constructor TReadonlyTerritoryList.Create;
  Begin
   List := TList.Create;
  End;

 Destructor TReadonlyTerritoryList.Destroy;
  Begin
   List.Free;
   If Assigned(LookupTable_GeoID) Then
    LookupTable_GeoID.Free;
   If Assigned(LookupTable_Code2) Then
    LookupTable_Code2.Free;
   If Assigned(LookupTable_Code3) Then
    LookupTable_Code3.Free;
   Inherited Destroy;
  End;

 Function TReadonlyTerritoryList.GetCount;
  Begin
   Result := List.Count;
  End;

 Function TReadonlyTerritoryList.GetItems(Index : Integer) : TTerritoryInfo;
  Begin
   Result := TTerritoryInfo(List[Index]);
  End;

 Function TReadonlyTerritoryList.GetEnumerator : TTerritoryEnumerator;
  Begin
   Result := TTerritoryEnumerator.Create(Self);
  End;

 Procedure TReadonlyTerritoryList.AddLookupEntries(Territory : TTerritoryInfo; Index : Integer);
  Begin
   If IsLookupTableValid_GeoID Then
    LookupTable_GeoID.Add(Territory.GEOID, Index);
   If IsLookupTableValid_Code2 Then
    LookupTable_Code2.Add(Territory.Code2, Index);
   If IsLookupTableValid_Code3 Then
    LookupTable_Code3.Add(Territory.Code3, Index);
  End;

 Procedure TReadonlyTerritoryList.RemoveLookupEntries(Territory : TTerritoryInfo);
  Begin
   If IsLookupTableValid_GeoID Then
    LookupTable_GeoID.Remove(Territory.GEOID);
   If IsLookupTableValid_Code2 Then
    LookupTable_Code2.Remove(Territory.Code2);
   If IsLookupTableValid_Code3 Then
    LookupTable_Code3.Remove(Territory.Code3);
  End;

 Procedure TReadonlyTerritoryList.ClearLookupTables;
  Begin
   If Assigned(LookupTable_GeoID) Then
    Begin
     LookupTable_GeoID.Clear;
     IsLookupTableValid_GeoID := False;
    End;
   If Assigned(LookupTable_Code2) Then
    Begin
     LookupTable_Code2.Clear;
     IsLookupTableValid_Code2 := False;
    End;
   If Assigned(LookupTable_Code3) Then
    Begin
     LookupTable_Code3.Clear;
     IsLookupTableValid_Code3 := False;
    End;
  End;

 Procedure TReadonlyTerritoryList.InvalidateLookupTables;
  Begin
   IsLookupTableValid_GeoID := False;
   IsLookupTableValid_Code2 := False;
   IsLookupTableValid_Code3 := False;
  End;

 Procedure TReadonlyTerritoryList.ValidateLookupTable_GeoID;
  Var
   i : Integer;
  Begin
   If Not IsLookupTableValid_GeoID Then
    Begin
     If Assigned(LookupTable_GeoID) Then
      LookupTable_GeoID.Clear
     Else
      LookupTable_GeoID := TKeyLookup<GEOID, Integer>.Create;
     For i              := 0 To Count - 1 Do
      LookupTable_GeoID.Add(Items[i].GEOID, i);
     IsLookupTableValid_GeoID := True;
    End;
  End;

 Procedure TReadonlyTerritoryList.ValidateLookupTable_Code2;
  Var
   i : Integer;
  Begin
   If Not IsLookupTableValid_Code2 Then
    Begin
     If Assigned(LookupTable_Code2) Then
      LookupTable_Code2.Clear
     Else
      LookupTable_Code2 := TKeyLookup<String, Integer>.Create;
     For i              := 0 To Count - 1 Do
      LookupTable_Code2.Add(Items[i].Code2, i);
     IsLookupTableValid_Code2 := True;
    End;
  End;

 Procedure TReadonlyTerritoryList.ValidateLookupTable_Code3;
  Var
   i : Integer;
  Begin
   If Not IsLookupTableValid_Code3 Then
    Begin
     If Assigned(LookupTable_Code3) Then
      LookupTable_Code3.Clear
     Else
      LookupTable_Code3 := TKeyLookup<String, Integer>.Create;
     For i              := 0 To Count - 1 Do
      LookupTable_Code3.Add(Items[i].Code3, i);
     IsLookupTableValid_Code3 := True;
    End;
  End;

 Function TReadonlyTerritoryList.First : TTerritoryInfo;
  Begin
   If Count <> 0 Then
    Result := Items[0]
   Else
    Result := Nil;
  End;

 Function TReadonlyTerritoryList.Last : TTerritoryInfo;
  Begin
   If Count <> 0 Then
    Result := Items[Count - 1]
   Else
    Result := Nil;
  End;

 Procedure TReadonlyTerritoryList.AssignTo(Dest : TPersistent);
  Var
   Strings : TStrings Absolute Dest;
   i       : Integer;
  Begin
   If Dest Is TStrings Then
    Begin
     Strings.BeginUpdate;
     Try
      Strings.Clear;
      For i := 0 To Count - 1 Do
       Strings.AddObject(Items[i].Code2, Items[i]);
     Finally
      Strings.EndUpdate;
     End;
    End
   Else
    Inherited AssignTo(Dest);
  End;

 Procedure TReadonlyTerritoryList.AssignLabelsTo(Dest : TStrings; DisplayName : TTerritoryDisplayName);
  Var
   i : Integer;
  Begin
   Dest.BeginUpdate;
   Try
    Dest.Clear;
    For i := 0 To Count - 1 Do
     Dest.AddObject(Items[i].DisplayNames[DisplayName], Items[i]);
   Finally
    Dest.EndUpdate;
   End;
  End;

 Function TReadonlyTerritoryList.Find(GEOID : GEOID) : TTerritoryInfo;
  Var
   Index : Integer;
  Begin
   If Not IsLookupTableValid_GeoID Then
    ValidateLookupTable_GeoID;
   If LookupTable_GeoID.Retrieve(GEOID, Index) Then
    Result := Items[Index]
   Else
    Result := Nil;
  End;

 Function TReadonlyTerritoryList.Find(Const Code : String) : TTerritoryInfo;
  Var
   Index : Integer;
  Begin
   Result := Nil;
   Case Length(Code) Of
    2 :
     Begin
      If Not IsLookupTableValid_Code2 Then
       ValidateLookupTable_Code2;
      If LookupTable_Code2.Retrieve(UpperCase(Code), Index) Then
       Result := Items[Index];
     End;
    3 :
     Begin
      If Not IsLookupTableValid_Code3 Then
       ValidateLookupTable_Code3;
      If LookupTable_Code3.Retrieve(UpperCase(Code), Index) Then
       Result := Items[Index];
     End;
   End;
  End;

 Function TReadonlyTerritoryList.IndexOf(Territory : TTerritoryInfo) : Integer;
  Begin
   If Assigned(Territory) Then
    Result := IndexOf(Territory.GEOID)
   Else
    Result := -1;
  End;

 Function TReadonlyTerritoryList.IndexOf(GEOID : GEOID) : Integer;
  Begin
   If Not IsLookupTableValid_GeoID Then
    ValidateLookupTable_GeoID;
   If Not LookupTable_GeoID.Retrieve(GEOID, Result) Then
    Result := -1;
  End;

 Function TReadonlyTerritoryList.IndexOf(Const Code : String) : Integer;
  Begin
   Case Length(Code) Of
    2 :
     Begin
      If Not IsLookupTableValid_Code2 Then
       ValidateLookupTable_Code2;
      If Not LookupTable_Code2.Retrieve(UpperCase(Code), Result) Then
       Result := -1;
     End;
    3 :
     Begin
      If Not IsLookupTableValid_Code3 Then
       ValidateLookupTable_Code3;
      If Not LookupTable_Code3.Retrieve(UpperCase(Code), Result) Then
       Result := -1;
     End;
   Else
     Result := -1;
   End;
  End;

 Function TReadonlyTerritoryList.IndexOfName(Const AName : String; DisplayName : TTerritoryDisplayName) : Integer;
  Var
   i : Integer;
  Begin
   For i := 0 To Count - 1 Do
    If AnsiSameText(Items[i].DisplayNames[DisplayName], AName) Then
     Begin
      Result := i;
      Exit;
     End;
   Result := -1;
  End;

 Function TReadonlyTerritoryList.Exists(Territory : TTerritoryInfo) : Boolean;
  Begin
   Result := Assigned(Territory) And Exists(Territory.GEOID);
  End;

 Function TReadonlyTerritoryList.Exists(GEOID : GEOID) : Boolean;
  Begin
   If Not IsLookupTableValid_GeoID Then
    ValidateLookupTable_GeoID;
   Result := LookupTable_GeoID.Exists(GEOID);
  End;

 Function TReadonlyTerritoryList.Exists(Const Code : String) : Boolean;
  Begin
   Case Length(Code) Of
    2 :
     Begin
      If Not IsLookupTableValid_Code2 Then
       ValidateLookupTable_Code2;
      Result := LookupTable_Code2.Exists(UpperCase(Code));
     End;
    3 :
     Begin
      If Not IsLookupTableValid_Code3 Then
       ValidateLookupTable_Code3;
      Result := LookupTable_Code3.Exists(UpperCase(Code));
     End;
   Else
     Result := False;
   End;
  End;

{ TTerritoryList }

 Function TTerritoryList.GetCapacity : Integer;
  Begin
   Result := List.Capacity;
  End;

 Procedure TTerritoryList.SetCapacity(Value : Integer);
  Begin
   List.Capacity := Value;
   If Value < Count Then
    InvalidateLookupTables;
  End;

 Procedure TTerritoryList.ReadTerritory(Reader : TReader);
  Var
   Code2 : String;
  Begin
   BeginUpdate;
   Try
    Clear;
    Reader.ReadListBegin;
    While Not Reader.EndOfList Do
     Begin
      Code2 := Reader.ReadString;
      If Code2 = '*' Then
       Begin
        Assign(World.Territories);
        Break;
       End;
      Add(Code2);
     End;
    Reader.ReadListEnd;
   Finally
    EndUpdate;
   End;
  End;

 Procedure TTerritoryList.WriteTerritory(Writer : TWriter);
  Var
   i : Integer;
  Begin
   Writer.WriteListBegin;
   If (Duplicates <> dupAccept) And (Count = World.Territories.Count) Then
    Writer.WriteString('*') // all territories
   Else
    For i := 0 To Count - 1 Do
     Writer.WriteString(Items[i].Code2);
   Writer.WriteListEnd;
  End;

 Procedure TTerritoryList.DefineProperties(Filer : TFiler);
  Begin
   Inherited DefineProperties(Filer);
   Filer.DefineProperty('Territories', ReadTerritory, WriteTerritory, Count <> 0);
  End;

 Procedure TTerritoryList.Changing;
  Begin
   If (UpdateCount = 0) And Assigned(OnChanging) Then
    OnChanging(Self);
  End;

 Procedure TTerritoryList.Change;
  Begin
   If (UpdateCount = 0) And Assigned(OnChange) Then
    OnChange(Self);
  End;

 Procedure TTerritoryList.BeginUpdate;
  Begin
   If UpdateCount = 0 Then
    Changing;
   Inc(fUpdateCount);
  End;

 Procedure TTerritoryList.EndUpdate;
  Begin
   Dec(fUpdateCount);
   If UpdateCount = 0 Then
    Change;
  End;

 Procedure TTerritoryList.Clear;
  Begin
   If Count <> 0 Then
    Begin
     Changing;
     Try
      List.Clear;
      ClearLookupTables;
     Finally
      Change;
     End;
    End;
  End;

 Procedure TTerritoryList.Sort(OrderBy : TTerritoryDisplayName);

   Procedure QuickSort(l, r : Integer);
    Var
     i, j, p : Integer;
     Pivot   : String;
    Begin
     Repeat
      i := l;
      j := r;
      p := (l + r) Shr 1;
      Repeat
       Pivot := Items[p].DisplayNames[OrderBy];
       While AnsiCompareText(Items[i].DisplayNames[OrderBy], Pivot) < 0 Do
        Inc(i);
       While AnsiCompareText(Items[j].DisplayNames[OrderBy], Pivot) > 0 Do
        Dec(j);
       If i <= j Then
        Begin
         If i <> j Then
          Begin
           List.Exchange(i, j);
           InvalidateLookupTables;
          End;
         If p = i Then
          p := j
         Else If p = j Then
          p := i;
         Inc(i);
         Dec(j);
        End;
      Until i > j;
      If l < j Then
       QuickSort(l, j);
      l := i;
     Until i >= r;
    End;

  Begin
   If (OrderBy <> tnNone) And (Count > 1) Then
    Begin
     Changing;
     Try
      QuickSort(0, Count - 1);
     Finally
      Change;
     End;
    End;
  End;

 Procedure TTerritoryList.Assign(Source : TPersistent);
  Begin
   If Source Is TReadonlyTerritoryList Then
    Apply(TReadonlyTerritoryList(Source), laCopy)
   Else
    Inherited Assign(Source);
  End;

 Procedure TTerritoryList.Apply(ListA : TReadonlyTerritoryList; Op : TListAssignOp; ListB : TReadonlyTerritoryList);
  Begin
   Changing;
   Try
    If Assigned(ListB) Then
     List.Assign(ListA.List, Op, ListB.List)
    Else
     List.Assign(ListA.List, Op, Nil);
    InvalidateLookupTables;
   Finally
    Change;
   End;
  End;

 Function TTerritoryList.Add(Territory : TTerritoryInfo) : Integer;
  Begin
   If Assigned(Territory) Then
    Begin
     If Duplicates <> dupAccept Then
      Begin
       Result := IndexOf(Territory);
       If Result >= 0 Then
        Begin
         If Duplicates = dupError Then
          Raise EListError.CreateResFmt(@SDuplicateItemError, [Result]);
         Exit;
        End;
      End;
     Changing;
     Try
      Result := List.Add(Territory);
      AddLookupEntries(Territory, Result);
     Finally
      Change;
     End;
    End
   Else
    Result := -1;
  End;

 Function TTerritoryList.Add(GEOID : GEOID) : Integer;
  Begin
   Result := Add(World.Territories.Find(GEOID));
  End;

 Function TTerritoryList.Add(Const Code : String) : Integer;
  Begin
   Result := Add(World.Territories.Find(Code));
  End;

 Function TTerritoryList.Remove(Territory : TTerritoryInfo) : Integer;
  Begin
   Result := IndexOf(Territory);
   If Result >= 0 Then
    Delete(Result);
  End;

 Function TTerritoryList.Remove(GEOID : GEOID) : Integer;
  Begin
   Result := IndexOf(GEOID);
   If Result >= 0 Then
    Delete(Result);
  End;

 Function TTerritoryList.Remove(Const Code : String) : Integer;
  Begin
   Result := IndexOf(Code);
   If Result >= 0 Then
    Delete(Result);
  End;

 Procedure TTerritoryList.Delete(Index : Integer);
  Begin
   Changing;
   Try
    RemoveLookupEntries(Items[Index]);
    List.Delete(Index);
   Finally
    Change;
   End;
  End;

{ TCurrency }

 Constructor TCurrencyInfo.Create(LocaleID : LCID);
  Begin
   If Not World.Changing Then
    Raise Exception.CreateResFmt(@SInstanceCreateError, [ClassName]);
   fCultures    := TCultureList.Create;
   fCountries   := TTerritoryList.Create;
   fIntlSymbol  := GetLocaleStr(LocaleID, LOCALE_SINTLSYMBOL, '');
   fLocalSymbol := GetLocaleStr(LocaleID, LOCALE_SCURRENCY, '');
   fEnglishName := GetLocaleStr(LocaleID, LOCALE_SENGCURRNAME, '');
  End;

 Constructor TCurrencyInfo.Create(Const Locale : String);
  Begin
   Create(LocaleNameToLCID(Locale));
  End;

 Destructor TCurrencyInfo.Destroy;
  Begin
   If Not World.Changing Then
    Raise Exception.CreateResFmt(@SInstanceDestroyError, [ClassName]);
   fCultures.Free;
   fCountries.Free;
   Inherited Destroy;
  End;

 Function TCurrencyInfo.GetDisplayNames(DisplayName : TCurrencyDisplayName) : String;
  Begin
   Case DisplayName Of
    crnIntlSymbol  : Result := IntlSymbol;
    crnEnglishName : Result := EnglishName;
    crnNativeName  : Result := NativeName;
   Else Result := '';
   End;
  End;

 Function TCurrencyInfo.GetNativeName : String;
  Begin
   If Assigned(OriginCountry) Then
    Result := OriginCountry.Cultures[0].NativeCurrencyName
   Else
    Result := '';
  End;

 Function TCurrencyInfo.GetCultures : TReadonlyCultureList;
  Begin
   Result := fCultures;
  End;

 Function TCurrencyInfo.GetCountries : TReadonlyTerritoryList;
  Begin
   Result := fCountries;
  End;

 Procedure TCurrencyInfo.Associate(Culture : TCultureInfo; Territory : TTerritoryInfo);
  Begin
   If Assigned(Culture) And Not fCultures.Exists(Culture) Then
    fCultures.Add(Culture);
   If Assigned(Territory) And Not fCountries.Exists(Territory) Then
    Begin
     fCountries.Add(Territory);
     If Assigned(fOriginCountry) And (Pos(fOriginCountry.Code2, IntlSymbol) = 0) Then
      fOriginCountry := Nil;
     If (fCountries.Count = 1) Or (Pos(Territory.Code2, IntlSymbol) <> 0) Then
      fOriginCountry := Territory;
    End;
  End;

{ TCurrencyEnumerator }

 Constructor TCurrencyEnumerator.Create(List : TReadonlyCurrencyList);
  Begin
   Inherited Create(List.List);
  End;

 Function TCurrencyEnumerator.GetCurrent : TCurrencyInfo;
  Begin
   Result := TCurrencyInfo(Inherited GetCurrent);
  End;

{ TReadonlyCurrencyList }

 Constructor TReadonlyCurrencyList.Create;
  Begin
   List := TList.Create;
  End;

 Destructor TReadonlyCurrencyList.Destroy;
  Begin
   List.Free;
   If Assigned(LookupTable_IntlSymbol) Then
    LookupTable_IntlSymbol.Free;
   Inherited Destroy;
  End;

 Function TReadonlyCurrencyList.GetCount : Integer;
  Begin
   Result := List.Count;
  End;

 Function TReadonlyCurrencyList.GetItems(Index : Integer) : TCurrencyInfo;
  Begin
   Result := TCurrencyInfo(List[Index]);
  End;

 Function TReadonlyCurrencyList.GetEnumerator : TCurrencyEnumerator;
  Begin
   Result := TCurrencyEnumerator.Create(Self);
  End;

 Procedure TReadonlyCurrencyList.AddLookupEntries(Currency : TCurrencyInfo; Index : Integer);
  Begin
   If IsLookupTableValid_IntlSymbol Then
    LookupTable_IntlSymbol.Add(Currency.IntlSymbol, Index);
  End;

 Procedure TReadonlyCurrencyList.RemoveLookupEntries(Currency : TCurrencyInfo);
  Begin
   If IsLookupTableValid_IntlSymbol Then
    LookupTable_IntlSymbol.Remove(Currency.IntlSymbol);
  End;

 Procedure TReadonlyCurrencyList.ClearLookupTables;
  Begin
   If Assigned(LookupTable_IntlSymbol) Then
    Begin
     LookupTable_IntlSymbol.Clear;
     IsLookupTableValid_IntlSymbol := False;
    End;
  End;

 Procedure TReadonlyCurrencyList.InvalidateLookupTables;
  Begin
   IsLookupTableValid_IntlSymbol := False;
  End;

 Procedure TReadonlyCurrencyList.ValidateLookupTable_IntlSymbol;
  Var
   i : Integer;
  Begin
   If Not IsLookupTableValid_IntlSymbol Then
    Begin
     If Assigned(LookupTable_IntlSymbol) Then
      LookupTable_IntlSymbol.Clear
     Else
      LookupTable_IntlSymbol := TKeyLookup<String, Integer>.Create;
     For i                   := 0 To Count - 1 Do
      LookupTable_IntlSymbol.Add(Items[i].IntlSymbol, i);
     IsLookupTableValid_IntlSymbol := True;
    End;
  End;

 Function TReadonlyCurrencyList.First : TCurrencyInfo;
  Begin
   If Count <> 0 Then
    Result := Items[0]
   Else
    Result := Nil;
  End;

 Function TReadonlyCurrencyList.Last : TCurrencyInfo;
  Begin
   If Count <> 0 Then
    Result := Items[Count - 1]
   Else
    Result := Nil;
  End;

 Procedure TReadonlyCurrencyList.AssignTo(Dest : TPersistent);
  Var
   Strings : TStrings Absolute Dest;
   i       : Integer;
  Begin
   If Dest Is TStrings Then
    Begin
     Strings.BeginUpdate;
     Try
      Strings.Clear;
      For i := 0 To Count - 1 Do
       Strings.AddObject(Items[i].IntlSymbol, Items[i]);
     Finally
      Strings.EndUpdate;
     End;
    End
   Else
    Inherited AssignTo(Dest);
  End;

 Procedure TReadonlyCurrencyList.AssignLabelsTo(Dest : TStrings; DisplayName : TCurrencyDisplayName);
  Var
   i : Integer;
  Begin
   Dest.BeginUpdate;
   Try
    Dest.Clear;
    For i := 0 To Count - 1 Do
     Dest.AddObject(Items[i].DisplayNames[DisplayName], Items[i]);
   Finally
    Dest.EndUpdate;
   End;
  End;

 Function TReadonlyCurrencyList.Find(Const IntlSymbol : String) : TCurrencyInfo;
  Var
   Index : Integer;
  Begin
   If Not IsLookupTableValid_IntlSymbol Then
    ValidateLookupTable_IntlSymbol;
   If LookupTable_IntlSymbol.Retrieve(UpperCase(IntlSymbol), Index) Then
    Result := Items[Index]
   Else
    Result := Nil;
  End;

 Function TReadonlyCurrencyList.IndexOf(Currency : TCurrencyInfo) : Integer;
  Begin
   If Assigned(Currency) Then
    Result := IndexOf(Currency.IntlSymbol)
   Else
    Result := -1;
  End;

 Function TReadonlyCurrencyList.IndexOf(Const IntlSymbol : String) : Integer;
  Begin
   If Not IsLookupTableValid_IntlSymbol Then
    ValidateLookupTable_IntlSymbol;
   If Not LookupTable_IntlSymbol.Retrieve(UpperCase(IntlSymbol), Result) Then
    Result := -1;
  End;

 Function TReadonlyCurrencyList.IndexOfName(Const AName : String; DisplayName : TCurrencyDisplayName) : Integer;
  Var
   i : Integer;
  Begin
   For i := 0 To Count - 1 Do
    If AnsiSameText(Items[i].DisplayNames[DisplayName], AName) Then
     Begin
      Result := i;
      Exit;
     End;
   Result := -1;
  End;

 Function TReadonlyCurrencyList.Exists(Currency : TCurrencyInfo) : Boolean;
  Begin
   Result := Assigned(Currency) And Exists(Currency.IntlSymbol);
  End;

 Function TReadonlyCurrencyList.Exists(Const IntlSymbol : String) : Boolean;
  Begin
   If Not IsLookupTableValid_IntlSymbol Then
    ValidateLookupTable_IntlSymbol;
   Result := LookupTable_IntlSymbol.Exists(UpperCase(IntlSymbol));
  End;

{ TCurrencyList }

 Function TCurrencyList.GetCapacity : Integer;
  Begin
   Result := List.Capacity;
  End;

 Procedure TCurrencyList.SetCapacity(Value : Integer);
  Begin
   List.Capacity := Value;
   If Value < Count Then
    InvalidateLookupTables;
  End;

 Procedure TCurrencyList.ReadCurrencies(Reader : TReader);
  Var
   IntlSymbol : String;
  Begin
   BeginUpdate;
   Try
    Clear;
    Reader.ReadListBegin;
    While Not Reader.EndOfList Do
     Begin
      IntlSymbol := Reader.ReadString;
      If IntlSymbol = '*' Then
       Begin
        Assign(World.Currencies);
        Break;
       End;
      Add(IntlSymbol);
     End;
    Reader.ReadListEnd;
   Finally
    EndUpdate;
   End;
  End;

 Procedure TCurrencyList.WriteCurrencies(Writer : TWriter);
  Var
   i : Integer;
  Begin
   Writer.WriteListBegin;
   If (Duplicates <> dupAccept) And (Count = World.Currencies.Count) Then
    Writer.WriteString('*') // all currencies
   Else
    For i := 0 To Count - 1 Do
     Writer.WriteString(Items[i].IntlSymbol);
   Writer.WriteListEnd;
  End;

 Procedure TCurrencyList.DefineProperties(Filer : TFiler);
  Begin
   Inherited DefineProperties(Filer);
   Filer.DefineProperty('Currencies', ReadCurrencies, WriteCurrencies, Count <> 0);
  End;

 Procedure TCurrencyList.Changing;
  Begin
   If (UpdateCount = 0) And Assigned(OnChanging) Then
    OnChanging(Self);
  End;

 Procedure TCurrencyList.Change;
  Begin
   If (UpdateCount = 0) And Assigned(OnChange) Then
    OnChange(Self);
  End;

 Procedure TCurrencyList.BeginUpdate;
  Begin
   If UpdateCount = 0 Then
    Changing;
   Inc(fUpdateCount);
  End;

 Procedure TCurrencyList.EndUpdate;
  Begin
   Dec(fUpdateCount);
   If UpdateCount = 0 Then
    Change;
  End;

 Procedure TCurrencyList.Clear;
  Begin
   If Count <> 0 Then
    Begin
     Changing;
     Try
      List.Clear;
      ClearLookupTables;
     Finally
      Change;
     End;
    End;
  End;

 Procedure TCurrencyList.Sort(OrderBy : TCurrencyDisplayName);

   Procedure QuickSort(l, r : Integer);
    Var
     i, j, p : Integer;
     Pivot   : String;
    Begin
     Repeat
      i := l;
      j := r;
      p := (l + r) Shr 1;
      Repeat
       Pivot := Items[p].DisplayNames[OrderBy];
       While AnsiCompareText(Items[i].DisplayNames[OrderBy], Pivot) < 0 Do
        Inc(i);
       While AnsiCompareText(Items[j].DisplayNames[OrderBy], Pivot) > 0 Do
        Dec(j);
       If i <= j Then
        Begin
         If i <> j Then
          Begin
           List.Exchange(i, j);
           InvalidateLookupTables;
          End;
         If p = i Then
          p := j
         Else If p = j Then
          p := i;
         Inc(i);
         Dec(j);
        End;
      Until i > j;
      If l < j Then
       QuickSort(l, j);
      l := i;
     Until i >= r;
    End;

  Begin
   If (OrderBy <> crnNone) And (Count > 1) Then
    Begin
     Changing;
     Try
      QuickSort(0, Count - 1);
     Finally
      Change;
     End;
    End;
  End;

 Procedure TCurrencyList.Assign(Source : TPersistent);
  Begin
   If Source Is TReadonlyCurrencyList Then
    Apply(TReadonlyCurrencyList(Source), laCopy)
   Else
    Inherited Assign(Source);
  End;

 Procedure TCurrencyList.Apply(ListA : TReadonlyCurrencyList; Op : TListAssignOp; ListB : TReadonlyCurrencyList);
  Begin
   Changing;
   Try
    If Assigned(ListB) Then
     List.Assign(ListA.List, Op, ListB.List)
    Else
     List.Assign(ListA.List, Op, Nil);
    InvalidateLookupTables;
   Finally
    Change;
   End;
  End;

 Function TCurrencyList.Add(Currency : TCurrencyInfo) : Integer;
  Begin
   If Assigned(Currency) Then
    Begin
     If Duplicates <> dupAccept Then
      Begin
       Result := IndexOf(Currency);
       If Result >= 0 Then
        Begin
         If Duplicates = dupError Then
          Raise EListError.CreateResFmt(@SDuplicateItemError, [Result]);
         Exit;
        End;
      End;
     Changing;
     Try
      Result := List.Add(Currency);
      AddLookupEntries(Currency, Result);
     Finally
      Change;
     End;
    End
   Else
    Result := -1;
  End;

 Function TCurrencyList.Add(Const IntlSymbol : String) : Integer;
  Begin
   Result := Add(World.Currencies.Find(IntlSymbol));
  End;

 Function TCurrencyList.Remove(Currency : TCurrencyInfo) : Integer;
  Begin
   Result := IndexOf(Currency);
   If Result >= 0 Then
    Delete(Result);
  End;

 Function TCurrencyList.Remove(Const IntlSymbol : String) : Integer;
  Begin
   Result := IndexOf(IntlSymbol);
   If Result >= 0 Then
    Delete(Result);
  End;

 Procedure TCurrencyList.Delete(Index : Integer);
  Begin
   Changing;
   Try
    RemoveLookupEntries(Items[Index]);
    List.Delete(Index);
   Finally
    Change;
   End;
  End;

{ World }

 Function LocaleEnumCallbackEx(lpLocaleString : PChar; dwFlags : DWORD; lParam : lParam) : Integer; Stdcall;
  Begin
   World.CultureList.Add(TCultureInfo.Create(lpLocaleString));
   Result := 1;
  End;

 Function LocaleEnumCallback(lpLocaleString : PChar) : Integer; Stdcall;
  Var
   LocaleID : LCID;
  Begin
   LocaleID := StrToIntDef('$' + String(lpLocaleString), 0);
   If LocaleID <> 0 Then
    World.CultureList.Add(TCultureInfo.Create(LocaleID));
   Result := 1;
  End;

 Function GeoEnumCallBack(GEOID : GEOID) : Integer; Stdcall;
  Begin
   If Not World.TerritoryList.Exists(GEOID) Then
    Begin
     {$IFDEF EXCLUDE_TERRITORIES_WITH_X_CODE}
     If Pos('X', GetGeoStr(GEOID, GEO_ISO3, 'X')) <> 1 Then
     {$ENDIF}
      World.TerritoryList.Add(TTerritoryInfo.Create(GEOID));
    End;
   Result := 1;
  End;

  Class Procedure World.Startup;

Begin
 CultureList            := TCultureList.Create;
 TerritoryList          := TTerritoryList.Create;
 CurrencyList           := TCurrencyList.Create;
 CultureList.Capacity   := 300;
 TerritoryList.Capacity := 300;
 CurrencyList.Capacity  := 300;
 Changing               := True;
 Try
  EnumSystemLocales(@LocaleEnumCallback, LCID_SUPPORTED);
  {$IFNDEF EXCLUDE_TERRITORIES_WITH_NO_CULTURE_INFO}
  EnumSystemGeoID(GEOCLASS_NATION, 0, @GeoEnumCallBack);
  {$ENDIF}
 Finally
  Changing := False;
 End;
 CultureList.List.Capacity   := CultureList.Count;
 TerritoryList.List.Capacity := TerritoryList.Count;
 CurrencyList.List.Capacity  := CurrencyList.Count;

End;

  Class Procedure World.Cleanup;

 Var
  i : Integer;

Begin
 Changing := True;
 Try
  If Assigned(CultureList) Then
   Begin
    For i := 0 To CultureList.Count - 1 Do
     CultureList[i].Free;
    FreeAndNil(CultureList);
   End;
  If Assigned(TerritoryList) Then
   Begin
    For i := 0 To TerritoryList.Count - 1 Do
     TerritoryList[i].Free;
    FreeAndNil(TerritoryList);
   End;
  If Assigned(CurrencyList) Then
   Begin
    For i := 0 To CurrencyList.Count - 1 Do
     CurrencyList[i].Free;
    FreeAndNil(CurrencyList);
   End;
 Finally
  Changing := False;
 End;

End;

  Class Function World.Cultures : TReadonlyCultureList;

Begin
 If Not Assigned(CultureList) Then
  Startup;
 Result := CultureList;

End;

  Class Function World.Territories : TReadonlyTerritoryList;

Begin
 If Not Assigned(TerritoryList) Then
  Startup;
 Result := TerritoryList;

End;

  Class Function World.Currencies : TReadonlyCurrencyList;

Begin
 If Not Assigned(CultureList) Then
  Startup;
 Result := CurrencyList;

End;

Initialization

Finalization
 If Assigned(TheDefaultCalendar) Then
  FreeAndNil(TheDefaultCalendar);
 World.Cleanup;

End.
