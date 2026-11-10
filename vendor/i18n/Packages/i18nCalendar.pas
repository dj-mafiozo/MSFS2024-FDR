{------------------------------------------------------------------------------}
{                                                                              }
{  i18n Package                                                                }
{  Internationalization and Localization for Delphi                            }
{                                                                              }
{ Copyright(c) Kambiz Khojasteh                                              }
{  https://github.com/khojasteh/i18n                                           }
{                                                                              }
{------------------------------------------------------------------------------}

/// This unit contains base classes for calendar systems and date-time
/// manipulation.
Unit i18nCalendar;

{$I DELPHIAREA.INC}

Interface

 Uses
  SysUtils, Classes;

 Type
  TCalendar         = Class;
  TCalendarSettings = Class;

{$Region 'xmldoc'}
/// <summary>
/// This is a class reference for the <see cref="TCalendar"/> class or for one of
/// its descendants.
/// </summary>
/// <remarks>
/// TCalendarClass is the metaclass for <see cref="TCalendar"/>. Its value
/// is the class reference for <see cref="TCalendar"/> or for one of its
/// descendants.
/// </remarks>
{$Endregion}

  TCalendarClass = Class Of TCalendar;

{$Region 'xmldoc'}
/// <summary>
/// This is a class reference for the <see cref="TCalendarSettings"/> class or for
/// one of its descendants.
/// </summary>
/// <remarks>
/// TCalendarSettingsClass is the metaclass for <see cref="TCalendarSettings"/>.
/// Its value is the class reference for <see cref="TCalendarSettings"/> or for
/// one of its descendants.
/// </remarks>
{$Endregion}

  TCalendarSettingsClass = Class Of TCalendarSettings;

{$Region 'xmldoc'}
/// <summary>
/// This enumeration type identifies days of the week.
/// </summary>
{$Endregion}

  TDayOfWeek = (Monday = 1, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday);

{$Region 'xmldoc'}
/// <summary>
/// This data type represents a set of days of the week.
/// </summary>
{$Endregion}

  TDaysOfWeek = Set Of TDayOfWeek;

{$Region 'xmldoc'}
/// <summary>
/// This enumeration type identifies the rules that determine which week is the
/// first week of a year.
/// </summary>
{$Endregion}

  TWeekRule = (
  {$Region 'xmldoc'}
  /// The first week of the year starts on the first day of the year and
  /// ends before the following designated first day of the week.
  {$Endregion}
  wrFirstDayWeek,
  {$Region 'xmldoc'}
  /// The first week of the year is the first week with four or more days
  /// before the designated first day of the week (if Monday is specified
  /// as the first day of the week, this rule complies with ISO 8601).
  {$Endregion}
  wrFirstFourDayWeek,
  {$Region 'xmldoc'}
  /// The first week of the year begins on the first occurrence of the
  /// designated first day of the week on or after the first day of the year.
  {$Endregion}
  wrFullWeek
  );

{$Region 'xmldoc'}
/// <summary>
/// This enumeration type identifies the algorithm types of the calendar systems.
/// </summary>
{$Endregion}

  TCalendarKind = (
  {$Region 'xmldoc'}
  /// The calendar type is unknown.
  {$Endregion}
  ckUnknown,
  {$Region 'xmldoc'}
  /// The calendar is based on the solar year and seasons.
  {$Endregion}
  ckSolar,
  {$Region 'xmldoc'}
  /// The calendar is based on the path of the moon.
  {$Endregion}
  ckLunar,
  {$Region 'xmldoc'}
  /// The calendar indicates both the moon phase and the time of the solar year.
  {$Endregion}
  ckLunisolar
  );

{$Region 'xmldoc'}
/// <summary>
/// This data type represents a date as a four-byte (DWORD) value.
/// </summary>
{$Endregion}

  TDateYMD = Packed Record
   {$Region 'xmldoc'}
   /// Year in range -32768 to 32767
   {$Endregion}
   Year : SmallInt;
   {$Region 'xmldoc'}
   /// Month of the year
   {$Endregion}
   Month : Byte;
   {$Region 'xmldoc'}
   /// Day of the month
   {$Endregion}
   Day : Byte;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class is the base class for classes that provide locale-specific settings
/// for a calendar.
/// </summary>
/// <remarks>
/// TCalendarSettings is an abstract class that cannot be instantiated. Descendant
/// classes override many of the methods of the TCalendarSettings class to provide
/// calendar-specific information.
/// </remarks>
{$Endregion}

    TCalendarSettings = Class Abstract(TPersistent)
   Private
    fLocale             : String;
    fCalendarName       : String;
    fEraNames           : Array Of String;
    fShortEraNames      : Array Of String;
    fMonthNames         : Array Of String;
    fShortMonthNames    : Array Of String;
    fGenitiveMonthNames : Array Of String;
    fDayNames           : Array[TDayOfWeek] Of String;
    fShortDayNames      : Array[TDayOfWeek] Of String;
    fShortestDayNames   : Array[TDayOfWeek] Of String;
    fLongDateFormat     : String;
    fShortDateFormat    : String;
    fYearMonthFormat    : String;
    fMonthDayFormat     : String;
    fYearFormat         : String;
    fTwoDigitYearMax    : Word;
    fWeekRule           : TWeekRule;
    fFirstDayOfWeek     : TDayOfWeek;
    fDateSeparator      : String;
    fTimeSeparator      : String;
    fTimeAMString       : String;
    fTimePMString       : String;
    fShortTimeFormat    : String;
    fLongTimeFormat     : String;
    fUpdateCount        : Integer;
    fUpdateAffected     : Boolean;
    fOnChange           : TNotifyEvent;
    Procedure SetCalendarName(Const Value : String);
    Function GetEraCount : Integer; Inline;
    Function GetEraNames(Era : Integer) : String; Inline;
    Procedure SetEraNames(Era : Integer; Const Value : String);
    Function GetShortEraNames(Era : Integer) : String; Inline;
    Procedure SetShortEraNames(Era : Integer; Const Value : String);
    Function GetMonthCount : Integer; Inline;
    Function GetMonthNames(Month : Integer) : String; Inline;
    Procedure SetMonthNames(Month : Integer; Const Value : String);
    Function GetShortMonthNames(Month : Integer) : String; Inline;
    Procedure SetShortMonthNames(Month : Integer; Const Value : String);
    Function GetGenitiveMonthNames(Month : Integer) : String; Inline;
    Procedure SetGenitiveMonthNames(Month : Integer; Const Value : String);
    Function GetDayNames(DoW : TDayOfWeek) : String; Inline;
    Procedure SetDayNames(DoW : TDayOfWeek; Const Value : String);
    Function GetShortDayNames(DoW : TDayOfWeek) : String; Inline;
    Procedure SetShortDayNames(DoW : TDayOfWeek; Const Value : String);
    Function GetShortestDayNames(DoW : TDayOfWeek) : String; Inline;
    Procedure SetShortestDayNames(DoW : TDayOfWeek; Const Value : String);
    Procedure SetLongDateFormat(Const Value : String);
    Procedure SetShortDateFormat(Const Value : String);
    Procedure SetYearMonthFormat(Const Value : String);
    Procedure SetMonthDayFormat(Const Value : String);
    Procedure SetYearFormat(Const Value : String);
    Procedure SetTwoDigitYearMax(Value : Word);
    Procedure SetWeekRule(Value : TWeekRule);
    Procedure SetFirstDayOfWeek(Value : TDayOfWeek);
    Procedure SetDateSeparator(Const Value : String);
    Procedure SetTimeSeparator(Const Value : String);
    Procedure SetTimeAMString(Const Value : String);
    Procedure SetTimePMString(Const Value : String);
    Procedure SetShortTimeFormat(Const Value : String);
    Procedure SetLongTimeFormat(Const Value : String);
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Performs a case-insensitive search in the <paramref name="Names"/> array
    /// to find the block of characters given by the <paramref name="S"/> parameter.
    /// </summary>
    /// <param name="S">
    /// The search string.
    /// </param>
    /// <param name="Names">
    /// The array of names to search.
    /// </param>
    /// <returns>
    /// The position of <paramref name="S"/> in the <paramref name="Names"/>
    /// array (positioning from one), or zero if <paramref name="S"/> is not found.
    /// </returns>
    /// <remarks>
    /// If the search succeeds, the <paramref name="S"/> pointer will be advanced
    /// by the length of the matched name.
    /// </remarks>
    {$Endregion}
    Function ScanNames(Var s : PChar; Names : Array Of String) : Integer;
    {$Region 'xmldoc'}
    /// <summary>
    /// Searches for the block of characters given by the <paramref name="S"/> parameter
    /// within the <see cref="EraNames"/> property. The search is case-insensitive.
    /// </summary>
    /// <param name="S">
    /// The search string.
    /// </param>
    /// <returns>
    /// Index of <paramref name="S"/> in the <see cref="EraNames"/> property,
    /// or zero if <paramref name="S"/> is not found.
    /// </returns>
    /// <remarks>
    /// If the search succeeds, the <paramref name="S"/> pointer will be advanced
    /// by the length of the matched name.
    /// </remarks>
    {$Endregion}
    Function ScanEraNames(Var s : PChar) : Integer; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Searches for the block of characters given by the <paramref name="S"/> parameter
    /// within the <see cref="ShortEraNames"/> property. The search is case-insensitive.
    /// </summary>
    /// <param name="S">
    /// The search string.
    /// </param>
    /// <returns>
    /// Index of <paramref name="S"/> in the <see cref="ShortEraNames"/>
    /// property, or zero if <paramref name="S"/> is not found.
    /// </returns>
    /// <remarks>
    /// If the search succeeds, the <paramref name="S"/> pointer will be advanced
    /// by the length of the matched name.
    /// </remarks>
    {$Endregion}
    Function ScanShortEraNames(Var s : PChar) : Integer; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Searches for the block of characters given by the <paramref name="S"/> parameter
    /// within the <see cref="MonthNames"/> property. The search is case-insensitive.
    /// </summary>
    /// <param name="S">
    /// The search string.
    /// </param>
    /// <returns>
    /// Index of <paramref name="S"/> in the <see cref="MonthNames"/> property,
    /// or zero if <paramref name="S"/> is not found.
    /// </returns>
    /// <remarks>
    /// If the search succeeds, the <paramref name="S"/> pointer will be advanced
    /// by the length of the matched name.
    /// </remarks>
    {$Endregion}
    Function ScanMonthNames(Var s : PChar) : Integer; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Searches for the block of characters given by the <paramref name="S"/> parameter
    /// within the <see cref="ShortMonthNames"/> property. The search is case-insensitive.
    /// </summary>
    /// <param name="S">
    /// The search string.
    /// </param>
    /// <returns>
    /// Index of <paramref name="S"/> in the <see cref="ShortMonthNames"/> property,
    /// or zero if <paramref name="S"/> is not found.
    /// </returns>
    /// <remarks>
    /// If the search succeeds, the <paramref name="S"/> pointer will be advanced
    /// by the length of the matched name.
    /// </remarks>
    {$Endregion}
    Function ScanShortMonthNames(Var s : PChar) : Integer; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Searches for the block of characters given by the <paramref name="S"/> parameter
    /// within the <see cref="GenitiveMonthNames"/> property. The search is case-insensitive.
    /// </summary>
    /// <param name="S">
    /// The search string.
    /// </param>
    /// <returns>
    /// Index of <paramref name="S"/> in the <see cref="GenitiveMonthNames"/>
    /// property, or zero if <paramref name="S"/> is not found.
    /// </returns>
    /// <remarks>
    /// If the search succeeds, the <paramref name="S"/> pointer will be advanced
    /// by the length of the matched name.
    /// </remarks>
    {$Endregion}
    Function ScanGenitiveMonthNames(Var s : PChar) : Integer; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Searches for the block of characters given by the <paramref name="S"/> parameter
    /// within the <see cref="DayNames"/> property. The search is case-insensitive.
    /// </summary>
    /// <param name="S">
    /// The search string.
    /// </param>
    /// <returns>
    /// Index of <paramref name="S"/> in the <see cref="DayNames"/> property,
    /// or zero if <paramref name="S"/> is not found.
    /// </returns>
    /// <remarks>
    /// If the search succeeds, the <paramref name="S"/> pointer will be advanced
    /// by the length of the matched name.
    /// </remarks>
    {$Endregion}
    Function ScanDayNames(Var s : PChar) : Integer; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Searches for the block of characters given by the <paramref name="S"/> parameter
    /// within the <see cref="ShortDayNames"/> property. The search is case-insensitive.
    /// </summary>
    /// <param name="S">
    /// The search string.
    /// </param>
    /// <returns>
    /// Index of <paramref name="S"/> in the <see cref="ShortDayNames"/> property,
    /// or zero if <paramref name="S"/> is not found.
    /// </returns>
    /// <remarks>
    /// If the search succeeds, the <paramref name="S"/> pointer will be advanced
    /// by the length of the matched name.
    /// </remarks>
    {$Endregion}
    Function ScanShortDayNames(Var s : PChar) : Integer; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Searches for the block of characters given by the <paramref name="S"/> parameter
    /// within the <see cref="ShortestDayNames"/> property. The search is case-insensitive.
    /// </summary>
    /// <param name="S">
    /// The search string.
    /// </param>
    /// <returns>
    /// Index of <paramref name="S"/> in the <see cref="ShortestDayNames"/> property,
    /// or zero if <paramref name="S"/> is not found.
    /// </returns>
    /// <remarks>
    /// If the search succeeds, the <paramref name="S"/> pointer will be advanced
    /// by the length of the matched name.
    /// </remarks>
    {$Endregion}
    Function ScanShortestDayNames(Var s : PChar) : Integer; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Searches for the block of characters given by the <paramref name="S"/> parameter
    /// within the <see cref="TimeAMString"/> and <see cref="TimePMString"/> properties.
    /// The search is case-insensitive.
    /// </summary>
    /// <param name="S">
    /// The search string.
    /// </param>
    /// <returns>
    /// If string <paramref name="S"/> is identical to the value of <see cref="TimeAMString"/> or
    /// <see cref="TimePMString"/> properties, respectively returns one or two. If the string
    /// is not identical to either of the properties, returns zero.
    /// </returns>
    /// <remarks>
    /// If the search succeeds, the <paramref name="S"/> pointer will be advanced
    /// by the length of the matched name.
    /// </remarks>
    {$Endregion}
    Function ScanAMPM(Var s : PChar) : Integer; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Retrieves a piece of information for a locale by looking in the Windows calendar
    /// information. If the retrieval from Windows calendar information fails, then tries
    /// to retrieve the information from the Windows locale information.
    /// </summary>
    /// <param name="Locale">
    /// The locale name.
    /// </param>
    /// <param name="CalID">
    /// The identifier of calendar system.
    /// </param>
    /// <param name="LType">
    /// The identifier of locale information to retrieve.
    /// </param>
    /// <param name="CType">
    /// The identifier of calendar information to retrieve.
    /// </param>
    /// <param name="Default">
    /// The default value of the information if the function failed.
    /// </param>
    /// <returns>
    /// The locale or calendar information.
    /// </returns>
    {$Endregion}
    Function SafeGetInfoStr(Const Locale : String; CalID : Cardinal; LType, CType : Cardinal; Const Default : String) : String;
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts a given month number to its index in the Windows calendar
    /// information.
    /// </summary>
    /// <param name="Month">
    /// The month number.
    /// </param>
    /// <returns>
    /// The zero-based index of the given month number in the Windows calendar
    /// information.
    /// </returns>
    {$Endregion}
    Function GetMonthInfoIndex(Month : Integer) : Integer; Virtual;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnChange"/> event.
    /// </summary>
    {$Endregion}
    Procedure DoChange; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Sets <see cref="EraNames"/> and <see cref="ShortEraNames"/> properties for
    /// the specified era based on the given locale and calendar identifier.
    /// </summary>
    /// <param name="Era">
    /// The era whose name properties should be set.
    /// </param>
    /// <param name="Locale">
    /// The locale of the name.
    /// </param>
    /// <param name="CalendarID">
    /// The identifier of calendar system.
    /// </param>
    {$Endregion}
    Procedure PrepareEraName(Era : Integer; Const Locale : String; CalendarID : Cardinal); Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Sets <see cref="MonthNames"/>, <see cref="ShortMonthNames"/> and
    /// <see cref="GenitiveMonthNames"/> properties based on the given locale and
    /// calendar identifier.
    /// </summary>
    /// <param name="Locale">
    /// The locale of the names.
    /// </param>
    /// <param name="CalendarID">
    /// The identifier of calendar system.
    /// </param>
    {$Endregion}
    Procedure PrepareMonthNames(Const Locale : String; CalendarID : Cardinal); Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Sets <see cref="DayNames"/>, <see cref="ShortDayNames"/> and
    /// <see cref="ShortestDayNames"/> properties based on the given locale and
    /// calendar identifier.
    /// </summary>
    /// <param name="Locale">
    /// The locale of the names.
    /// </param>
    /// <param name="CalendarID">
    /// The identifier of calendar system.
    /// </param>
    {$Endregion}
    Procedure PrepareDayNames(Const Locale : String; CalendarID : Cardinal); Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Sets <see cref="LongDateFormat"/>, <see cref="ShortDateFormat"/>,
    /// <see cref="YearMonthFormat"/>, <see cref="MonthDayFormat"/> and
    /// <see cref="YearFormat"/> properties based on the given locale and calendar
    /// identifier.
    /// </summary>
    /// <param name="Locale">
    /// The locale of the formats.
    /// </param>
    /// <param name="CalendarID">
    /// The identifier of calendar system.
    /// </param>
    {$Endregion}
    Procedure PrepareDateFormats(Const Locale : String; CalendarID : Cardinal); Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Sets <see cref="LongTimeFormat"/>, <see cref="ShortTimeFormat"/>,
    /// <see cref="TimeAMString"/>, <see cref="TimePMString"/>,
    /// <see cref="TimeSeparator"/> and <see cref="DateSeparator"/> properties
    /// based on the given locale.
    /// </summary>
    /// <param name="Locale">
    /// The locale of the formats.
    /// </param>
    {$Endregion}
    Procedure PrepareTimeFormats(Const Locale : String); Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Sets <see cref="FirstDayOfWeek"/> and <see cref="WeekRule"/> properties
    /// based on the given locale.
    /// </summary>
    /// <param name="Locale">
    /// The locale for the week information.
    /// </param>
    {$Endregion}
    Procedure PrepareWeekParams(Const Locale : String); Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Sets all writable properties based on the given locale and calendar
    /// identifier.
    /// </summary>
    /// <param name="Locale">
    /// The locale of the settings.
    /// </param>
    /// <param name="CalendarID">
    /// The identifier of calendar system.
    /// </param>
    {$Endregion}
    Procedure PrepareSettings(Const Locale : String; CalendarID : Cardinal); Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Loads all the writable properties from a stream.
    /// </summary>
    /// <param name="Reader">
    /// The reader object connected to the stream.
    /// </param>
    /// <seealso cref="WriteSettings"/>
    {$Endregion}
    Procedure ReadSettings(Reader : TReader); Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Saves all the writable properties to a stream.
    /// </summary>
    /// <param name="Writer">
    /// The writer object connected to the stream.
    /// </param>
    /// <seealso cref="ReadSettings"/>
    {$Endregion}
    Procedure WriteSettings(Writer : TWriter); Virtual;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the class without setting any value for the locale
    /// specific properties.
    /// </summary>
    {$Endregion}
    Constructor Create; Overload; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the class, and collects the values of the properties based
    /// on the given locale identifier.
    /// </summary>
    /// <param name="LocaleID">
    /// The locale identifier.
    /// </param>
    {$Endregion}
    Constructor Create(LocaleID : Cardinal); Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the class, and collects the values of the properties based
    /// on the given locale name.
    /// </summary>
    /// <param name="Locale">
    /// The locale name.
    /// </param>
    {$Endregion}
    Constructor Create(Const Locale : String); Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Destroys the instance and releases its allocated memory.
    /// </summary>
    {$Endregion}
    Destructor Destroy; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Determines the calendar system that these settings are provided for.
    /// </summary>
    /// <returns>
    /// The <see cref="TCalendar"/> class or one of its descendants.
    /// </returns>
    {$Endregion}
    Class Function CalendarClass : TCalendarClass; Virtual; Abstract;
    {$Region 'xmldoc'}
    /// <summary>
    /// Collects the values of the properties based on the given locale identifier.
    /// </summary>
    /// <param name="LocaleID">
    /// The locale identifier.
    /// </param>
    {$Endregion}
    Procedure Prepare(LocaleID : Cardinal); Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Collects the values of the properties based on the given locale name.
    /// </summary>
    /// <param name="Locale">
    /// The locale name.
    /// </param>
    {$Endregion}
    Procedure Prepare(Const Locale : String); Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Loads the settings from a stream. The stream must be created previously
    /// by the same <see cref="TCalendarSettings"/> class.
    /// </summary>
    /// <param name="Stream">
    /// The stream containing the previously saved settings.
    /// </param>
    /// <seealso cref="SaveToStream"/>
    {$Endregion}
    Procedure LoadFromStream(Stream : TStream);
    {$Region 'xmldoc'}
    /// <summary>
    /// Saves the settings to a stream.
    /// </summary>
    /// <param name="Stream">
    /// The stream to store the settings.
    /// </param>
    /// <seealso cref="LoadFromStream"/>
    {$Endregion}
    Procedure SaveToStream(Stream : TStream);
    {$Region 'xmldoc'}
    /// <summary>
    /// Copies the contents of another object to the current one.
    /// </summary>
    /// <param name="Source">
    /// The source object.
    /// </param>
    {$Endregion}
    Procedure Assign(Source : TPersistent); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Prevents generation of the <see cref="OnChange"/> event until the
    /// <see cref="EndUpdate"/> method is called.
    /// </summary>
    /// <seealso cref="EndUpdate"/>
    {$Endregion}
    Procedure BeginUpdate;
    {$Region 'xmldoc'}
    /// <summary>
    /// Reenables <see cref="OnChange"/> event generation that was turned off
    /// with the <see cref="BeginUpdate"/> method.
    /// </summary>
    /// <seealso cref="BeginUpdate"/>
    {$Endregion}
    Procedure EndUpdate;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the locale name of the current settings.
    /// </summary>
    {$Endregion}
    Property Locale : String Read fLocale;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the native name of the calendar in the current locale.
    /// </summary>
    {$Endregion}
    Property CalendarName : String Read fCalendarName Write SetCalendarName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the number of eras supported by the calendar.
    /// </summary>
    {$Endregion}
    Property EraCount : Integer Read GetEraCount;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the full name of each calendar's eras in the current locale.
    /// </summary>
    {$Endregion}
    Property EraNames[Era : Integer] : String Read GetEraNames Write SetEraNames;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the short name of each calendar's eras in the current locale.
    /// </summary>
    {$Endregion}
    Property ShortEraNames[Era : Integer] : String Read GetShortEraNames Write SetShortEraNames;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the maximum number of months in the calendar in the current locale.
    /// </summary>
    {$Endregion}
    Property MonthCount : Integer Read GetMonthCount;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the full name of each month of the calendar in the current locale.
    /// </summary>
    {$Endregion}
    Property MonthNames[Month : Integer] : String Read GetMonthNames Write SetMonthNames;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the short name of each month of the calendar in the current locale.
    /// </summary>
    {$Endregion}
    Property ShortMonthNames[Month : Integer] : String Read GetShortMonthNames Write SetShortMonthNames;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the genitive name of each month of the calendar in the current locale.
    /// </summary>
    {$Endregion}
    Property GenitiveMonthNames[Month : Integer] : String Read GetGenitiveMonthNames Write SetGenitiveMonthNames;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the full name of each day of week in the current locale.
    /// </summary>
    {$Endregion}
    Property DayNames[DoW : TDayOfWeek] : String Read GetDayNames Write SetDayNames;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the short name of each day of week in the current locale.
    /// </summary>
    {$Endregion}
    Property ShortDayNames[DoW : TDayOfWeek] : String Read GetShortDayNames Write SetShortDayNames;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the shortest name of each day of week in the current locale.
    /// </summary>
    {$Endregion}
    Property ShortestDayNames[DoW : TDayOfWeek] : String Read GetShortestDayNames Write SetShortestDayNames;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the long date format in the current locale.
    /// </summary>
    {$Endregion}
    Property LongDateFormat : String Read fLongDateFormat Write SetLongDateFormat;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the short date format in the current locale.
    /// </summary>
    {$Endregion}
    Property ShortDateFormat : String Read fShortDateFormat Write SetShortDateFormat;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the year-month format in the current locale.
    /// </summary>
    {$Endregion}
    Property YearMonthFormat : String Read fYearMonthFormat Write SetYearMonthFormat;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the month-day format in the current locale.
    /// </summary>
    {$Endregion}
    Property MonthDayFormat : String Read fMonthDayFormat Write SetMonthDayFormat;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the year format in the current locale.
    /// </summary>
    {$Endregion}
    Property YearFormat : String Read fYearFormat Write SetYearFormat;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the last year of a 100-year range that can be represented by a 2-digit year.
    /// </summary>
    {$Endregion}
    Property TwoDigitYearMax : Word Read fTwoDigitYearMax Write SetTwoDigitYearMax;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the rule for determining the first week of the year for the current locale.
    /// </summary>
    {$Endregion}
    Property WeekRule : TWeekRule Read fWeekRule Write SetWeekRule;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the starting day of a week for the current locale.
    /// </summary>
    {$Endregion}
    Property FirstDayOfWeek : TDayOfWeek Read fFirstDayOfWeek Write SetFirstDayOfWeek;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the string that separates the components of a date, that is, the year, month, and day.
    /// </summary>
    {$Endregion}
    Property DateSeparator : String Read fDateSeparator Write SetDateSeparator;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the string that separates the components of time, that is, the hour, minutes, and seconds.
    /// </summary>
    {$Endregion}
    Property TimeSeparator : String Read fTimeSeparator Write SetTimeSeparator;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the string designator for hours that are "ante meridiem" (before noon).
    /// </summary>
    {$Endregion}
    Property TimeAMString : String Read fTimeAMString Write SetTimeAMString;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the string designator for hours that are "post meridiem" (after noon).
    /// </summary>
    {$Endregion}
    Property TimePMString : String Read fTimePMString Write SetTimePMString;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the long time format in the current locale.
    /// </summary>
    {$Endregion}
    Property ShortTimeFormat : String Read fShortTimeFormat Write SetShortTimeFormat;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the short time format in the current locale.
    /// </summary>
    {$Endregion}
    Property LongTimeFormat : String Read fLongTimeFormat Write SetLongTimeFormat;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when there is a change in any of the properties.
    /// </summary>
    {$Endregion}
    Property OnChange : TNotifyEvent Read fOnChange Write fOnChange;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class is the base class for classes that encapsulate a calendar system.
/// </summary>
/// <remarks>
/// TCalendar is an abstract class that cannot be instantiated. This class provides
/// a uniform interface for managing date and time. Descendant classes override many
/// of the methods of <see cref="TCalendar"/> class to provide calendar specific functionality.
/// </remarks>
{$Endregion}

    TCalendar = Class Abstract(TPersistent)
   Private
    fSettings   : TCalendarSettings;
    fDefaultEra : Integer;
    fOnChange   : TNotifyEvent;
    Procedure SetSettings(Value : TCalendarSettings); Inline;
    Procedure SetDefaultEra(Value : Integer);
    Procedure SettingsChanged(Sender : TObject);
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Call this method when an Era is not in the valid range to raise an EEncodingError
    /// exception.
    /// </summary>
    /// <param name="Era">
    /// The era, which caused the error.
    /// </param>
    {$Endregion}
    Class Procedure EraError(Era : Integer);
    {$Region 'xmldoc'}
    /// <summary>
    /// Call this method when a year is not in the valid range to raise an EEncodingError
    /// exception.
    /// </summary>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <param name="Year">
    /// The year of the era, which caused the error.
    /// </param>
    {$Endregion}
    Class Procedure YearError(Era, Year : Integer);
    {$Region 'xmldoc'}
    /// <summary>
    /// Call this method when a month is not in the valid range to raise an EEncodingError
    /// exception.
    /// </summary>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <param name="Year">
    /// The year of the era.
    /// </param>
    /// <param name="Month">
    /// The month of the year, which caused the error.
    /// </param>
    {$Endregion}
    Class Procedure MonthError(Era, Year, Month : Integer);
    {$Region 'xmldoc'}
    /// <summary>
    /// Call this method when a day is not in the valid range to raise an EEncodingError
    /// exception.
    /// </summary>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <param name="Year">
    /// The year of the era.
    /// </param>
    /// <param name="Month">
    /// The month of the year.
    /// </param>
    /// <param name="Day">
    /// The day of the month, which caused the error.
    /// </param>
    {$Endregion}
    Class Procedure DayError(Era, Year, Month, Day : Integer);
    {$Region 'xmldoc'}
    /// <summary>
    /// Call this method when a numeral representation of the day of the week is not
    /// in range 1 to 7 to raise an EConvertError exception.
    /// </summary>
    /// <param name="DayNum">
    /// The numeral representation of the day of the week.
    /// </param>
    {$Endregion}
    Class Procedure DayNumError(DayNum : Integer);
    {$Region 'xmldoc'}
    /// <summary>
    /// Call this method when a <see cref="TDateTime"/> value is not in the valid range
    /// to raise an EConvertError exception.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value, which caused the error.
    /// </param>
    {$Endregion}
    Class Procedure DateError(Const DateTime : TDateTime);
    {$Region 'xmldoc'}
    /// <summary>
    /// Call this method when a day of year is not in the valid range to raise an
    /// EEncodingError exception.
    /// </summary>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <param name="Year">
    /// The year of the era.
    /// </param>
    /// <param name="DayOfYear">
    /// The day of the year, which caused the error.
    /// </param>
    {$Endregion}
    Class Procedure DateDayError(Era, Year, DayOfYear : Integer);
    {$Region 'xmldoc'}
    /// <summary>
    /// Call this method when a week of year is not in the valid range to raise
    /// an EEncodingError exception.
    /// </summary>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <param name="Year">
    /// The year of the era.
    /// </param>
    /// <param name="Week">
    /// The week number of the year, which caused the error.
    /// </param>
    /// <param name="DoW">
    /// The day of the week, which caused the error.
    /// </param>
    {$Endregion}
    Class Procedure DateWeekError(Era, Year, Week : Integer; DoW : TDayOfWeek);
    {$Region 'xmldoc'}
    /// <summary>
    /// Call this method when conversion of a year from one era to another fails
    /// to raise an EConvertError exception.
    /// </summary>
    /// <param name="Year">
    /// The year that was going to convert.
    /// </param>
    /// <param name="FromEra">
    /// The source era.
    /// </param>
    /// <param name="ToEra">
    /// The target era.
    /// </param>
    {$Endregion}
    Class Procedure ConvertEraError(Year, FromEra, ToEra : Integer);
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Divides two integers, returning both quotient and remainder.
    /// </summary>
    /// <param name="Numerator">
    /// The numerator.
    /// </param>
    /// <param name="Denominator">
    /// The denominator.
    /// </param>
    /// <param name="Quotient">
    /// The quotient of the division.
    /// </param>
    /// <param name="Reminder">
    /// The remainder of the division.
    /// </param>
    /// <seealso cref="Modulus"/>
    {$Endregion}
    Class Procedure Divide(Numerator, Denominator : Integer; Out Quotient, Reminder : Integer); Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns remainder of an integer division.
    /// </summary>
    /// <param name="Numerator">
    /// The numerator.
    /// </param>
    /// <param name="Denominator">
    /// The denominator.
    /// </param>
    /// <returns>
    /// The remainder of the division.
    /// </returns>
    /// <seealso cref="Divide"/>
    {$Endregion}
    Class Function Modulus(Numerator, Denominator : Integer) : Integer; Inline;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// The starting epoch of <see cref="TDateTime"/> values in Julian days.
    /// </summary>
    {$Endregion}
    Const DATETIME_EPOCH = 2415018.5;
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnChange"/> event.
    /// </summary>
    {$Endregion}
    Procedure DoChange; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts a date represented by its year, month and day components to its
    /// corresponding Julian day. The year should be in the calendar's base era.
    /// </summary>
    /// <param name="Year">
    /// The year in calendar's base era.
    /// </param>
    /// <param name="Month">
    /// The month of the year.
    /// </param>
    /// <param name="Day">
    /// The day of the month.
    /// </param>
    /// <returns>
    /// Julian day of the specified date.
    /// </returns>
    /// <seealso cref="FromJulianDay"/>
    /// <seealso cref="BaseEra"/>
    {$Endregion}
    Function ToJulianDay(Year, Month, Day : Integer) : Extended; Virtual; Abstract;
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts a date expressed in Julian day, to its year, month, and day components.
    /// The result year is in the calendar's base era.
    /// </summary>
    /// <param name="JD">
    /// The date expressed in Julian day.
    /// </param>
    /// <param name="Year">
    /// The year in calendar's base era.
    /// </param>
    /// <param name="Month">
    /// The month of the year.
    /// </param>
    /// <param name="Day">
    /// The day of the month.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the function succeeds, otherwise returns
    /// <see langword="false"/>.
    /// </returns>
    /// <seealso cref="ToJulianDay"/>
    /// <seealso cref="BaseEra"/>
    {$Endregion}
    Function FromJulianDay(Const JD : Extended; Out Year, Month, Day : Integer) : Boolean; Virtual; Abstract;
    {$Region 'xmldoc'}
    /// <summary>
    /// Adjusts a Julian day before or after being converted to or from a date in a
    /// calendar system.
    /// </summary>
    /// <param name="JD">
    /// The date expressed in Julian day.
    /// </param>
    /// <param name="Backward">
    /// Indicates the direction of adjustment. If <see langword="true"/>, the Julian day
    /// is about to be converted to a date. If <see langword="false"/>, the Julian day
    /// is the result of converting a date.
    /// </param>
    /// <returns>
    /// Returns the adjusted Julian day.
    /// </returns>
    {$Endregion}
    Function AdjustJulianDay(Const JD : Extended; Backward : Boolean) : Extended; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the era that is used for internal calculations of the calendar.
    /// </summary>
    /// <returns>
    /// The base era of the calendar.
    /// </returns>
    {$Endregion}
    Function BaseEra : Integer; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the era that is more suitable for expressing a year in the calendar's
    /// base era.
    /// </summary>
    /// <param name="Year">
    /// The year expressed in the calendar's base era.
    /// </param>
    /// <returns>
    /// The best era to express the specified year.
    /// </returns>
    /// <seealso cref="BaseEra"/>
    {$Endregion}
    Function BestEraOfBaseEraYear(Year : Integer) : Integer; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts a year to zero-based year. Most calendar systems do not have year
    /// zero, but the TCalendar class uses zero-based year in its internal calculations.
    /// </summary>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <param name="Year">
    /// The year of the era.
    /// </param>
    /// <returns>
    /// The year as zero-based for internal calculations.
    /// </returns>
    /// <remarks>
    /// It is safe to call this method for a calendar system that year zero is
    /// a valid year for it.
    /// </remarks>
    /// <seealso cref="FromZeroBase"/>
    {$Endregion}
    Function ToZeroBase(Era, Year : Integer) : Integer; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts a year previously converted to zero-based year by using the
    /// <see cref="ToZeroBase"/> method.
    /// </summary>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <param name="Year">
    /// The year of the era.
    /// </param>
    /// <returns>
    /// The year as expected by the calendar system.
    /// </returns>
    /// <remarks>
    /// It is safe to call this method for a calendar system that year zero is
    /// a valid year for it.
    /// </remarks>
    /// <seealso cref="ToZeroBase"/>
    {$Endregion}
    Function FromZeroBase(Era, Year : Integer) : Integer; Inline;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Represents the number of days in a week.
    /// </summary>
    {$Endregion}
    Const DaysPerWeek = 7;
    {$Region 'xmldoc'}
    /// <summary>
    /// Represents one day.
    /// </summary>
    {$Endregion}
    Const OneDay = 1.0;
    {$Region 'xmldoc'}
    /// <summary>
    /// Represents one hour as fraction of a day.
    /// </summary>
    {$Endregion}
    Const OneHour = OneDay / HoursPerDay;
    {$Region 'xmldoc'}
    /// <summary>
    /// Represents one minute as fraction of a day.
    /// </summary>
    {$Endregion}
    Const OneMinute = OneDay / MinsPerDay;
    {$Region 'xmldoc'}
    /// <summary>
    /// Represents one second as fraction of a day.
    /// </summary>
    {$Endregion}
    Const OneSecond = OneDay / SecsPerDay;
    {$Region 'xmldoc'}
    /// <summary>
    /// Represents one millisecond as fraction of a day.
    /// </summary>
    {$Endregion}
    Const OneMillisecond = OneDay / MSecsPerDay;
    {$Region 'xmldoc'}
    /// <summary>
    /// Represents one week.
    /// </summary>
    {$Endregion}
    Const OneWeek = OneDay * DaysPerWeek;
    {$Region 'xmldoc'}
    /// <summary>
    /// Represents no date or an invalid date value.
    /// </summary>
    {$Endregion}
    Const NoDate : TDateTime = -0.5;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the class without initializing the locale-specific
    /// settings.
    /// </summary>
    {$Endregion}
    Constructor Create; Overload; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the class, and initializes the locale-specific settings
    /// based on the given locale identifier.
    /// </summary>
    /// <param name="LocaleID">
    /// The locale identifier.
    /// </param>
    {$Endregion}
    Constructor Create(LocaleID : Integer); Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the class, and initializes the locale-specific settings
    /// based on the given locale name.
    /// </summary>
    /// <param name="Locale">
    /// The locale name.
    /// </param>
    {$Endregion}
    Constructor Create(Const Locale : String); Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Destroys the instance and releases its allocated memory.
    /// </summary>
    {$Endregion}
    Destructor Destroy; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Copies the contents of another object to the current one.
    /// </summary>
    /// <param name="Source">
    /// The source object.
    /// </param>
    {$Endregion}
    Procedure Assign(Source : TPersistent); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Copies the contents of this object to another object.
    /// </summary>
    /// <param name="Dest">
    /// The target object.
    /// </param>
    {$Endregion}
    Procedure AssignTo(Dest : TPersistent); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates and returns a copy of the object, with the same class and with all the
    /// properties having the same values.
    /// </summary>
    /// <returns>
    /// The newly created <see cref="TCalendar"/> object.
    /// </returns>
    {$Endregion}
    Function Clone : TCalendar; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the locale-specific settings of the calendar.
    /// </summary>
    {$Endregion}
    Property Settings : TCalendarSettings Read fSettings Write SetSettings;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the default era of the calendar.
    /// </summary>
    {$Endregion}
    Property DefaultEra : Integer Read fDefaultEra Write SetDefaultEra;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when any of the calendar settings is changed.
    /// </summary>
    {$Endregion}
    Property OnChange : TNotifyEvent Read fOnChange Write fOnChange;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the friendly name of the calendar system. This name is automatically
    /// made from the class name.
    /// </summary>
    /// <returns>
    /// The friendly name of the calendar system.
    /// </returns>
    {$Endregion}
    Class Function CalendarName : String;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the unique identifier of the calendar.
    /// </summary>
    /// <returns>
    /// The unique identifier of the calendar.
    /// </returns>
    {$Endregion}
    Class Function CalendarID : Cardinal; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the algorithm type of the calendar system.
    /// </summary>
    /// <returns>
    /// The algorithm type of the calendar system.
    /// </returns>
    {$Endregion}
    Class Function CalendarKind : TCalendarKind; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the <see cref="TCalendarSettings"/> class that provides locale
    /// specific settings for the calendar.
    /// </summary>
    /// <returns>
    /// The <see cref="TCalendarSettings"/> class or one of its descendents.
    /// </returns>
    {$Endregion}
    Class Function SettingsClass : TCalendarSettingsClass; Virtual;
    { Min/Max Functions }
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the number of eras that the calendar class supports.
    /// </summary>
    /// <returns>
    /// The maximum number of eras.
    /// </returns>
    {$Endregion}
    Class Function MaxEra : Integer; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the maximum number of months that the calendar may have in a year.
    /// </summary>
    /// <returns>
    /// The maximum number of months per year.
    /// </returns>
    {$Endregion}
    Class Function MaxMonthsPerYear : Integer; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the minimum <see cref="TDateTime"/> value that can be managed by
    /// the calendar.
    /// </summary>
    /// <returns>
    /// The minimum supported <see cref="TDateTime"/> value.
    /// </returns>
    /// <seealso cref="MaxSupportedDateTime"/>
    {$Endregion}
    Class Function MinSupportedDateTime : TDateTime; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the maximum <see cref="TDateTime"/> value that can be managed by
    /// the calendar.
    /// </summary>
    /// <returns>
    /// The maximum supported <see cref="TDateTime"/> value.
    /// </returns>
    /// <seealso cref="MinSupportedDateTime"/>
    {$Endregion}
    Class Function MaxSupportedDateTime : TDateTime; Virtual;
    { Miscellaneous Functions }
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value that represents the current date.
    /// </summary>
    /// <returns>
    /// The date of today.
    /// </returns>
    /// <seealso cref="Yesterday"/>
    /// <seealso cref="Tomorrow"/>
    {$Endregion}
    Class Function Today : TDate; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value that represents the preceding day.
    /// </summary>
    /// <returns>
    /// The date of yesterday.
    /// </returns>
    /// <seealso cref="Today"/>
    /// <seealso cref="Tomorrow"/>
    {$Endregion}
    Class Function Yesterday : TDate; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value that represents the following day.
    /// </summary>
    /// <returns>
    /// The date of tomorrow.
    /// </returns>
    /// <seealso cref="Today"/>
    /// <seealso cref="Yesterday"/>
    {$Endregion}
    Class Function Tomorrow : TDate; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the first month of the year for the calendar.
    /// </summary>
    /// <returns>
    /// The first month of the year.
    /// </returns>
    {$Endregion}
    Class Function FirstMonthOfYear : Integer; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the number of days from beginning of a specified year to beginning
    /// of a specified month.
    /// </summary>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <param name="Year">
    /// The year of the era.
    /// </param>
    /// <param name="Month">
    /// The month of the year.
    /// </param>
    /// <returns>
    /// The number of days between start of the year and start of the month.
    /// </returns>
    {$Endregion}
    Function DaysToMonth(Era, Year, Month : Integer) : Integer; Overload; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the number of days from beginning of a specified year to beginning
    /// of a specified month.
    /// </summary>
    /// <param name="Year">
    /// The year expressed in thecurrent calendar era.
    /// </param>
    /// <param name="Month">
    /// The month of the year.
    /// </param>
    /// <returns>
    /// The number of days between start of the year and start of the month.
    /// </returns>
    /// <seealso cref="DefaultEra"/>
    {$Endregion}
    Function DaysToMonth(Year, Month : Integer) : Integer; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the number of days from beginning of the year to beginning of the month
    /// of a specified <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The target date.
    /// </param>
    /// <returns>
    /// The number of days between start of the year and start of the month.
    /// </returns>
    {$Endregion}
    Function DaysToMonth(Const DateTime : TDateTime) : Integer; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the number of days in a specified month of a specified year.
    /// </summary>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <param name="Year">
    /// The year of the era.
    /// </param>
    /// <param name="Month">
    /// The month of the year.
    /// </param>
    /// <returns>
    /// The number of days in the month.
    /// </returns>
    {$Endregion}
    Function DaysInMonth(Era, Year, Month : Integer) : Integer; Overload; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the number of days in a specified month of a specified year.
    /// </summary>
    /// <param name="Year">
    /// The year expressed in the calendar's default era.
    /// </param>
    /// <param name="Month">
    /// The month of the year.
    /// </param>
    /// <returns>
    /// The number of days in the month.
    /// </returns>
    /// <seealso cref="DefaultEra"/>
    {$Endregion}
    Function DaysInMonth(Year, Month : Integer) : Integer; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the number of days in the month of a specified <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The target date.
    /// </param>
    /// <returns>
    /// The number of days in the month.
    /// </returns>
    {$Endregion}
    Function DaysInMonth(Const DateTime : TDateTime) : Integer; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the number of days in a specified year.
    /// </summary>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <param name="Year">
    /// The year of the era.
    /// </param>
    /// <returns>
    /// The number of days in the year.
    /// </returns>
    {$Endregion}
    Function DaysInYear(Era, Year : Integer) : Integer; Overload; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the number of days in a specified year.
    /// </summary>
    /// <param name="Year">
    /// The year expressed in the calendar's default era.
    /// </param>
    /// <returns>
    /// The number of days in the year.
    /// </returns>
    /// <seealso cref="DefaultEra"/>
    {$Endregion}
    Function DaysInYear(Year : Integer) : Integer; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the number of days in the year of a specified <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The target date.
    /// </param>
    /// <returns>
    /// The number of days in the year.
    /// </returns>
    {$Endregion}
    Function DaysInYear(Const DateTime : TDateTime) : Integer; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the number of months in a specified year.
    /// </summary>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <param name="Year">
    /// The year of the era.
    /// </param>
    /// <returns>
    /// The number of months in the year.
    /// </returns>
    {$Endregion}
    Function MonthsInYear(Era, Year : Integer) : Integer; Overload; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the number of months in a specified year.
    /// </summary>
    /// <param name="Year">
    /// The year expressed in the calendar's default era.
    /// </param>
    /// <returns>
    /// The number of months in the year.
    /// </returns>
    /// <seealso cref="DefaultEra"/>
    {$Endregion}
    Function MonthsInYear(Year : Integer) : Integer; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the number of months in the year of a specified <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The target date.
    /// </param>
    /// <returns>
    /// The number of months in the year.
    /// </returns>
    {$Endregion}
    Function MonthsInYear(Const DateTime : TDateTime) : Integer; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the number of weeks in a specified year.
    /// </summary>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <param name="Year">
    /// The year of the era.
    /// </param>
    /// <returns>
    /// The number of weeks in the year.
    /// </returns>
    {$Endregion}
    Function WeeksInYear(Era, Year : Integer) : Integer; Overload; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the number of weeks in a specified year.
    /// </summary>
    /// <param name="Year">
    /// The year expressed in the calendar's default era.
    /// </param>
    /// <returns>
    /// The number of weeks in the year.
    /// </returns>
    /// <seealso cref="DefaultEra"/>
    {$Endregion}
    Function WeeksInYear(Year : Integer) : Integer; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the number of weeks in the year of a specified <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The target date.
    /// </param>
    /// <returns>
    /// The number of weeks in the year.
    /// </returns>
    {$Endregion}
    Function WeeksInYear(Const DateTime : TDateTime) : Integer; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the number of whole weeks in a specified month of a specified year.
    /// </summary>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <param name="Year">
    /// The year of the era.
    /// </param>
    /// <param name="Month">
    /// The month of the year.
    /// </param>
    /// <returns>
    /// The number of whole weeks in the month.
    /// </returns>
    {$Endregion}
    Function WeeksInMonth(Era, Year, Month : Integer) : Integer; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the number of whole weeks in a specified month of a specified year.
    /// </summary>
    /// <param name="Year">
    /// The year expressed in the calendar's default era.
    /// </param>
    /// <param name="Month">
    /// The month of the year.
    /// </param>
    /// <returns>
    /// The number of whole weeks in the month.
    /// </returns>
    /// <seealso cref="DefaultEra"/>
    {$Endregion}
    Function WeeksInMonth(Year, Month : Integer) : Integer; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the number of whole weeks in the month of a specified <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The target date.
    /// </param>
    /// <returns>
    /// The number of whole weeks in the month.
    /// </returns>
    {$Endregion}
    Function WeeksInMonth(Const DateTime : TDateTime) : Integer; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Finds month and day of the month for a specified day of a specified year.
    /// </summary>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <param name="Year">
    /// The year of the era.
    /// </param>
    /// <param name="DayOfYear">
    /// The day of the year.
    /// </param>
    /// <param name="Month">
    /// The month of the year.
    /// </param>
    /// <param name="Day">
    /// The day of the month.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the function is succeeded, otherwise
    /// returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function DayOfYearToDayOfMonth(Era, Year, DayOfYear : Integer; Var Month, Day : Integer) : Boolean; Overload; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Finds month and day of the month for a specified day of a specified year.
    /// </summary>
    /// <param name="Year">
    /// The year expressed in the calendar's default era.
    /// </param>
    /// <param name="DayOfYear">
    /// The day of the year.
    /// </param>
    /// <param name="Month">
    /// The month of the year.
    /// </param>
    /// <param name="Day">
    /// The day of the month.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the function is succeeded, otherwise
    /// returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="DefaultEra"/>
    {$Endregion}
    Function DayOfYearToDayOfMonth(Year, DayOfYear : Integer; Var Month, Day : Integer) : Boolean; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Finds day of year for a date specified by its era, year, month, and day
    /// components.
    /// </summary>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <param name="Year">
    /// The year of the era.
    /// </param>
    /// <param name="Month">
    /// The month of the year.
    /// </param>
    /// <param name="Day">
    /// The day of the month.
    /// </param>
    /// <param name="DayOfYear">
    /// The day of the year.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the function is succeeded, otherwise
    /// returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function DayOfMonthToDayOfYear(Era, Year, Month, Day : Integer; Out DayOfYear : Integer) : Boolean; Overload; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Finds day of year for a date specified by its year, month, and day
    /// components.
    /// </summary>
    /// <param name="Year">
    /// The year expressed in the calendar's default era.
    /// </param>
    /// <param name="Month">
    /// The month of the year.
    /// </param>
    /// <param name="Day">
    /// The day of the month.
    /// </param>
    /// <param name="DayOfYear">
    /// The day of the year.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the function is succeeded, otherwise
    /// returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="DefaultEra"/>
    {$Endregion}
    Function DayOfMonthToDayOfYear(Year, Month, Day : Integer; Out DayOfYear : Integer) : Boolean; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts a year from one era to another.
    /// </summary>
    /// <param name="Year">
    /// The year to convert.
    /// </param>
    /// <param name="FromEra">
    /// The source era.
    /// </param>
    /// <param name="ToEra">
    /// The target era.
    /// </param>
    /// <returns>
    /// The year expressed in the target era.
    /// </returns>
    {$Endregion}
    Function ConvertYear(Year, FromEra, ToEra : Integer) : Integer; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts a two-digit year to four-digit.
    /// </summary>
    /// <param name="Year">
    /// The two-digit year.
    /// </param>
    /// <returns>
    /// The four-digit year.
    /// </returns>
    {$Endregion}
    Function ToFourDigitYear(Year : Integer) : Integer; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether the year zero is a valid year for an era.
    /// </summary>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the era can have year zero, otherwise
    /// returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function CanHaveZeroYear(Era : Integer) : Boolean; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Increments a year by a specified number of years, and converts era of
    /// the year as well.
    /// </summary>
    /// <param name="Year">
    /// The year to increment.
    /// </param>
    /// <param name="NumberOfYears">
    /// The number of years to add.
    /// </param>
    /// <param name="FromEra">
    /// The era of the input year.
    /// </param>
    /// <param name="ToEra">
    /// The era of the output year.
    /// </param>
    /// <returns>
    /// The year incremented by the number of years.
    /// </returns>
    /// <remarks>
    /// Use this method to safely increment/decrement year regardless of whether
    /// year zero is a valid year for the source and target eras or not.
    /// </remarks>
    {$Endregion}
    Function OffsetYear(Year, NumberOfYears : Integer; FromEra, ToEra : Integer) : Integer; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Increments a year by a specified number of years.
    /// </summary>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <param name="Year">
    /// The year of the era.
    /// </param>
    /// <param name="NumberOfYears">
    /// The number of years to add.
    /// </param>
    /// <returns>
    /// The year incremented by the number of years.
    /// </returns>
    /// <remarks>
    /// Use this method to safely increment/decrement year regardless of whether
    /// year zero is a valid year for the source and target eras or not.
    /// </remarks>
    {$Endregion}
    Function OffsetYear(Era, Year, NumberOfYears : Integer) : Integer; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Increments a year by a specified number of years.
    /// </summary>
    /// <param name="Year">
    /// The year expressed in the calendar's default era.
    /// </param>
    /// <param name="NumberOfYears">
    /// The number of years to add.
    /// </param>
    /// <returns>
    /// The year incremented by the number of years.
    /// </returns>
    /// <remarks>
    /// Use this method to safely increment/decrement year regardless of whether
    /// year zero is a valid year for the source and target eras or not.
    /// </remarks>
    /// <seealso cref="DefaultEra"/>
    {$Endregion}
    Function OffsetYear(Year, NumberOfYears : Integer) : Integer; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Adds the amount of days and fraction of a day to a specified <see cref="TDateTime"/> value.
    /// </summary>
    /// <remarks>
    /// The OffsetDateTime method will offset a <see cref="TDateTime"/> value by considering the
    /// following rules:
    /// <list type="bullet">
    ///   <item>
    ///   The fraction part in a <see cref="TDateTime"/> value is always a positive value even
    ///   when the whole value is negative.</item>
    ///   <item>
    ///   There is no <see cref="TDateTime"/> value in range (-1, 0).</item>
    /// </list>
    /// </remarks>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="Delta">
    /// The amount of days (or fraction of a day) to add.
    /// </param>
    /// <returns>
    /// The new <see cref="TDateTime"/> value.
    /// </returns>
    {$Endregion}
    Class Function OffsetDateTime(Const DateTime : TDateTime; Const Delta : Double) : TDateTime; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the whole days between two specified <see cref="TDateTime"/> values.
    /// </summary>
    /// <param name="DateTime1">
    /// The first date.
    /// </param>
    /// <param name="DateTime2">
    /// The second date.
    /// </param>
    /// <returns>
    /// The whole days between two dates.
    /// </returns>
    {$Endregion}
    Class Function DaysBetween(DateTime1, DateTime2 : TDateTime) : Integer; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the number of days between two specified days of week.
    /// </summary>
    /// <param name="DoW1">
    /// The first day of week.
    /// </param>
    /// <param name="DoW2">
    /// The second day of week.
    /// </param>
    /// <returns>
    /// The number of whole days between two days of week.
    /// </returns>
    {$Endregion}
    Class Function DaysOfWeekBetween(DoW1, DoW2 : TDayOfWeek) : Integer; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts a specified TDayOfWeek value to its numeral representation,
    /// where the first day of the week is 1 and the last day of the week is 7.
    /// </summary>
    /// <param name="DoW">
    /// The day of the week.
    /// </param>
    /// <returns>
    /// The numeral representation of the day of the week in range 1 to 7.
    /// </returns>
    /// <remarks>
    /// The returned value is locale dependent.
    /// </remarks>
    /// <seealso cref="DayNumToDayOfWeek"/>
    {$Endregion}
    Function DayOfWeekToDayNum(DoW : TDayOfWeek) : Integer; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts a number in range 1 to 7 that represents the day of the week to
    /// a TDayOfWeek value.
    /// </summary>
    /// <param name="DayNum">
    /// The numeral representation of the day of the week in range 1 to 7, where
    /// the first day of the week is 1 and the last day of the week is 7.
    /// </param>
    /// <returns>
    /// The day of the week.
    /// </returns>
    /// <remarks>
    /// The input value is locale dependent.
    /// </remarks>
    /// <seealso cref="DayOfWeekToDayNum"/>
    {$Endregion}
    Function DayNumToDayOfWeek(DayNum : Integer) : TDayOfWeek;
    { Is Functions }
    {$Region 'xmldoc'}
    /// <summary>
    /// Checks whether a specified <see cref="TDateTime"/> value is invalid.
    /// </summary>
    /// <param name="DateTime">
    /// The datatime value to examine.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the <see cref="TDateTime"/> value is invalid,
    /// otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="IsValidDate"/>
    {$Endregion}
    Class Function IsNoDate(Const DateTime : TDateTime) : Boolean; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Checks whether a specified <see cref="TDateTime"/> value is valid and supported
    /// by the calendar.
    /// </summary>
    /// <param name="DateTime">
    /// The data to examine.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the <see cref="TDateTime"/> value is valid and
    /// in the supported range of the calendar, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function IsValidDate(Const DateTime : TDateTime) : Boolean; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Checks whether a specified day in a specified year is valid.
    /// </summary>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <param name="Year">
    /// The year of the era.
    /// </param>
    /// <param name="DayOfYear">
    /// The day of the year.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the <see cref="TDateTime"/> value is valid,
    /// otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function IsValidDateDay(Era, Year, DayOfYear : Integer) : Boolean; Overload; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Checks whether a specified day in a specified year is valid.
    /// </summary>
    /// <param name="Year">
    /// The year expressed in the calendar's default era.
    /// </param>
    /// <param name="DayOfYear">
    /// The day of the year.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the <see cref="TDateTime"/> value is valid,
    /// otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="DefaultEra"/>
    {$Endregion}
    Function IsValidDateDay(Year, DayOfYear : Integer) : Boolean; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Checks whether a specified day of a specified week in a speified year is
    /// valid.
    /// </summary>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <param name="Year">
    /// The year of the era.
    /// </param>
    /// <param name="Week">
    /// The week number of the year.
    /// </param>
    /// <param name="DoW">
    /// The day of the week.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the <see cref="TDateTime"/> value is valid,
    /// otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function IsValidDateWeek(Era, Year, Week : Integer; DoW : TDayOfWeek) : Boolean; Overload; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Checks whether a specified day of a specified week in a speified year is
    /// valid.
    /// </summary>
    /// <param name="Year">
    /// The year expressed in the calendar's default era.
    /// </param>
    /// <param name="Week">
    /// The week number of the year.
    /// </param>
    /// <param name="DoW">
    /// The day of the week.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the <see cref="TDateTime"/> value is valid,
    /// otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="DefaultEra"/>
    {$Endregion}
    Function IsValidDateWeek(Year, Week : Integer; DoW : TDayOfWeek) : Boolean; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Checks whether a era is valid.
    /// </summary>
    /// <param name="Era">
    /// The era to check.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the era is valid, otherwise returns
    /// <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function IsValidEra(Era : Integer) : Boolean; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Checks whether a specified year in a specified era is valid.
    /// </summary>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <param name="Year">
    /// The year of the era.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the era and year pair is valid, otherwise
    /// returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function IsValidYear(Era, Year : Integer) : Boolean; Overload; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Checks whether a specified year is valid.
    /// </summary>
    /// <param name="Year">
    /// The year expressed in the calendar's default era.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the year is valid, otherwise returns
    /// <see langword="false"/>.
    /// </returns>
    /// <seealso cref="DefaultEra"/>
    {$Endregion}
    Function IsValidYear(Year : Integer) : Boolean; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Checks whether a specified month in a specified year is valid.
    /// </summary>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <param name="Year">
    /// The year of the era.
    /// </param>
    /// <param name="Month">
    /// The month of the year.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the era, year and month triple is valid,
    /// otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function IsValidMonth(Era, Year, Month : Integer) : Boolean; Overload; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Checks whether a specified month in a specified year is valid.
    /// </summary>
    /// <param name="Year">
    /// The year expressed in the calendar's default era.
    /// </param>
    /// <param name="Month">
    /// The month of the year.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the year and month pair is valid, otherwise
    /// returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="DefaultEra"/>
    {$Endregion}
    Function IsValidMonth(Year, Month : Integer) : Boolean; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Checkes whether a specified day of a specified month in a specified year
    /// is valid.
    /// </summary>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <param name="Year">
    /// The year of the era.
    /// </param>
    /// <param name="Month">
    /// The month of the year.
    /// </param>
    /// <param name="Day">
    /// The day of the month.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the date is valid, otherwise returns
    /// <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function IsValidDay(Era, Year, Month, Day : Integer) : Boolean; Overload; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Checkes whether a specified day of a specified month in a specified year
    /// is valid.
    /// </summary>
    /// <param name="Year">
    /// The year expressed in the calendar's default era.
    /// </param>
    /// <param name="Month">
    /// The month of the year.
    /// </param>
    /// <param name="Day">
    /// The day of the month.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the date is valid, otherwise returns
    /// <see langword="false"/>.
    /// </returns>
    /// <seealso cref="DefaultEra"/>
    {$Endregion}
    Function IsValidDay(Year, Month, Day : Integer) : Boolean; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether a specified year in a specified era is a leap year.
    /// </summary>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <param name="Year">
    /// The year of the era.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the year is a leap year, otherwise
    /// returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function IsLeapYear(Era, Year : Integer) : Boolean; Overload; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether a specified year is a leap year.
    /// </summary>
    /// <param name="Year">
    /// The year expressed in the calendar's default era.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the year is a leap year, otherwise
    /// returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="DefaultEra"/>
    {$Endregion}
    Function IsLeapYear(Year : Integer) : Boolean; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether a specified <see cref="TDateTime"/> value is within a leap year.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value to examine.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the <see cref="TDateTime"/> value is in a leap
    /// year, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function IsInLeapYear(Const DateTime : TDateTime) : Boolean;
    {$Region 'xmldoc'}
    /// <summary>
    /// Checks whether a specified <see cref="TDateTime"/> value is within the given date
    /// range (inclusive).
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value to examine.
    /// </param>
    /// <param name="RangeStart">
    /// The <see cref="TDateTime"/> value that specifies start of the range.
    /// </param>
    /// <param name="RangeEnd">
    /// The <see cref="TDateTime"/> value that specifies end of the range.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the datetime is within the range, otherwise
    /// returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Class Function IsInRange(Const DateTime, RangeStart, RangeEnd : TDateTime) : Boolean; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Checkes whether a specified <see cref="TDateTime"/> value is within the
    /// current era.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value to examine.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the <see cref="TDateTime"/> value is within
    /// the current era, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function IsThisEra(Const DateTime : TDateTime) : Boolean; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Checkes whether a specified era is the current era.
    /// </summary>
    /// <param name="Era">
    /// The era to examine.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the era is the current era, otherwise
    /// returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function IsThisEra(Era : Integer) : Boolean; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Checkes whether a specified <see cref="TDateTime"/> value is within the
    /// current year.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value to examine.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the <see cref="TDateTime"/> value is within
    /// the current year, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function IsThisYear(Const DateTime : TDateTime) : Boolean; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Checkes whether a specified year in a specified era represents the current year.
    /// </summary>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <param name="Year">
    /// The year of the era.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the era and year pair represents the
    /// current year, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function IsThisYear(Era, Year : Integer) : Boolean; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Checkes whether a specified year is the current year.
    /// </summary>
    /// <param name="Year">
    /// The year expressed in the calendar's default era.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the year is the current year, otherwise
    /// returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="DefaultEra"/>
    {$Endregion}
    Function IsThisYear(Year : Integer) : Boolean; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Checkes whether a specified <see cref="TDateTime"/> value is within the
    /// current month.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value to examine.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the <see cref="TDateTime"/> value is within
    /// the current month, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function IsThisMonth(Const DateTime : TDateTime) : Boolean; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Checkes whether a specified month in a specified year represents the
    /// current month.
    /// </summary>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <param name="Year">
    /// The year of the era.
    /// </param>
    /// <param name="Month">
    /// The month of the year.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the era, year, and month triple represents
    /// the current month, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function IsThisMonth(Era, Year, Month : Integer) : Boolean; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Checkes whether a specified month in a specified year represents the
    /// current month.
    /// </summary>
    /// <param name="Year">
    /// The year expressed in the calendar's default era.
    /// </param>
    /// <param name="Month">
    /// The month of the year.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the year, and month pair represents the
    /// current month, otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="DefaultEra"/>
    {$Endregion}
    Function IsThisMonth(Year, Month : Integer) : Boolean; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Checkes whether a specified month is the current month.
    /// </summary>
    /// <param name="Month">
    /// The month to examine.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the month is the current month, otherwise
    /// returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function IsThisMonth(Month : Integer) : Boolean; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Checkes whether a specified <see cref="TDateTime"/> value is within the
    /// current week.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value to examine.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the <see cref="TDateTime"/> value is within
    ///  the current week, otherwise returns <see langword="false"/>.
    ///  </returns>
    {$Endregion}
    Function IsThisWeek(Const DateTime : TDateTime) : Boolean; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Checkes whether a specified <see cref="TDateTime"/> value represents the
    /// current date.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value to examine.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the <see cref="TDateTime"/> value represents
    /// the current date, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Class Function IsToday(Const DateTime : TDateTime) : Boolean; Overload; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Checkes whether a specified day of week is the today's day of week.
    /// </summary>
    /// <param name="DoW">
    /// The day of week to examine.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the day of week is the today's day of week,
    /// otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Class Function IsToday(DoW : TDayOfWeek) : Boolean; Overload; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether the time portion of a specified <see cref="TDateTime"/>
    /// value occurs after noon.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value to examine.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the time is  after noon, and returns
    /// <see langword="false"/> if the time is before noon.
    /// </returns>
    {$Endregion}
    Class Function IsPM(Const DateTime : TDateTime) : Boolean; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// CHeckes whether two specified <see cref="TDateTime"/> values are equal.
    /// </summary>
    /// <param name="DateTime1">
    /// The first <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="DateTime2">
    /// The second <see cref="TDateTime"/> value.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the two <see cref="TDateTime"/> values are
    /// equal, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Class Function IsSame(Const DateTime1, DateTime2 : TDateTime) : Boolean; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Checkes whether two specified <see cref="TDateTime"/> values are within the
    /// same era.
    /// </summary>
    /// <param name="DateTime1">
    /// The first <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="DateTime2">
    /// The second <see cref="TDateTime"/> value.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the two <see cref="TDateTime"/> values are
    /// within the same era, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function IsSameEra(Const DateTime1, DateTime2 : TDateTime) : Boolean; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Checkes whether two specified <see cref="TDateTime"/> values are within the
    /// same year.
    /// </summary>
    /// <param name="DateTime1">
    /// The first <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="DateTime2">
    /// The second <see cref="TDateTime"/> value.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the two <see cref="TDateTime"/> values are
    /// within the same year, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function IsSameYear(Const DateTime1, DateTime2 : TDateTime) : Boolean;
    {$Region 'xmldoc'}
    /// <summary>
    /// Checkes whether two specified <see cref="TDateTime"/> values are within the
    /// same month.
    /// </summary>
    /// <param name="DateTime1">
    /// The first <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="DateTime2">
    /// The second <see cref="TDateTime"/> value.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the two <see cref="TDateTime"/> values are
    /// within the same month, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function IsSameMonth(Const DateTime1, DateTime2 : TDateTime) : Boolean;
    {$Region 'xmldoc'}
    /// <summary>
    /// Checkes whether two specified <see cref="TDateTime"/> values are within the
    /// same week.
    /// </summary>
    /// <param name="DateTime1">
    /// The first <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="DateTime2">
    /// The second <see cref="TDateTime"/> value.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the two <see cref="TDateTime"/> values are
    /// within the same week, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function IsSameWeek(Const DateTime1, DateTime2 : TDateTime) : Boolean;
    {$Region 'xmldoc'}
    /// <summary>
    /// Checkes whether two specified <see cref="TDateTime"/> values reperesent
    /// the same day.
    /// </summary>
    /// <param name="DateTime1">
    /// The first <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="DateTime2">
    /// The second <see cref="TDateTime"/> value.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the two <see cref="TDateTime"/> values
    /// reperesent the same day, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Class Function IsSameDay(Const DateTime1, DateTime2 : TDateTime) : Boolean; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Compares two specified <see cref="TDateTime"/> values.
    /// </summary>
    /// <param name="DateTime1">
    /// The first <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="DateTime2">
    /// The second <see cref="TDateTime"/> value.
    /// </param>
    /// <returns>
    /// Returns -1 if <paramref name="DateTime1"/> is less than <paramref name="DateTime2"/>,
    /// returns zero if <paramref name="DateTime1"/> is equal to <paramref name="DateTime2"/>,
    /// and returns 1 if <paramref name="DateTime1"/> is greater than <paramref name="DateTime2"/>.</returns>
    {$Endregion}
    Class Function Compare(Const DateTime1, DateTime2 : TDateTime) : Integer; Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Compares the date portion of two specified <see cref="TDateTime"/> values.
    /// </summary>
    /// <param name="DateTime1">
    /// The first <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="DateTime2">
    /// The second <see cref="TDateTime"/> value.
    /// </param>
    /// <returns>
    /// Returns -1 if date of <paramref name="DateTime1"/> is less than date of
    /// <paramref name="DateTime2"/>, returns zero if date of <paramref name="DateTime1"/>
    /// is equal to date of <paramref name="DateTime2"/>, and returns 1 if date of
    /// <paramref name="DateTime1"/> is greater than date of <paramref name="DateTime2"/>.</returns>
    {$Endregion}
    Class Function CompareDate(Const DateTime1, DateTime2 : TDateTime) : Integer; Overload; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Compares the time portion of two specified <see cref="TDateTime"/> values.
    /// </summary>
    /// <param name="DateTime1">
    /// The first <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="DateTime2">
    /// The second <see cref="TDateTime"/> value.
    /// </param>
    /// <returns>
    /// Returns -1 if time of <paramref name="DateTime1"/> is less than time of
    /// <paramref name="DateTime2"/>, returns zero if time of <paramref name="DateTime1"/>
    /// is equal to time of <paramref name="DateTime2"/>, and returns 1 if time of
    /// <paramref name="DateTime1"/> is greater than time of <paramref name="DateTime2"/>.</returns>
    {$Endregion}
    Class Function CompareTime(Const DateTime1, DateTime2 : TDateTime) : Integer; Overload; Static; Inline;
    { Encode/Decode Functions }
    {$Region 'xmldoc'}
    /// <summary>
    /// Calculates a <see cref="TDateTime"/> value that represents a specified day
    /// of a specified week in a specified year.
    /// </summary>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <param name="Year">
    /// The year of the era.
    /// </param>
    /// <param name="Week">
    /// The week of the year.
    /// </param>
    /// <param name="DoW">
    /// The day of the week.
    /// </param>
    /// <param name="DateTime">
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the conversion succeeded, otherwise returns
    /// <see langword="false"/>.
    /// </returns>
    /// <seealso cref="EncodeDateWeek"/>
    {$Endregion}
    Function TryEncodeDateWeek(Era, Year, Week : Integer; DoW : TDayOfWeek; Out DateTime : TDateTime) : Boolean; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Calculates a <see cref="TDateTime"/> value that represents a specified day
    /// of a specified week in a specified year.
    /// </summary>
    /// <param name="Year">
    /// The year expressed in the calendar's default era.
    /// </param>
    /// <param name="Week">
    /// The week of the year.
    /// </param>
    /// <param name="DoW">
    /// The day of the week.
    /// </param>
    /// <param name="DateTime">
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the conversion succeeded, otherwise returns
    /// <see langword="false"/>.
    /// </returns>
    /// <seealso cref="DefaultEra"/>
    /// <seealso cref="EncodeDateWeek"/>
    {$Endregion}
    Function TryEncodeDateWeek(Year, Week : Integer; DoW : TDayOfWeek; Out DateTime : TDateTime) : Boolean; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the <see cref="TDateTime"/> value that represents a specified day
    /// of a specified week in a specified year.
    /// </summary>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <param name="Year">
    /// The year of the era.
    /// </param>
    /// <param name="Week">
    /// The week of the year.
    /// </param>
    /// <param name="DoW">
    /// The day of the week.
    /// </param>
    /// <returns>
    /// The <see cref="TDateTime"/> value.
    /// </returns>
    /// <exception cref="EConvertError">
    /// Occurs when the conversion is failed.
    /// </exception>
    /// <seealso cref="TryEncodeDateWeek"/>
    {$Endregion}
    Function EncodeDateWeek(Era, Year, Week : Integer; DoW : TDayOfWeek) : TDateTime; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the <see cref="TDateTime"/> value that represents a specified day
    /// of a specified week in a specified year.
    /// </summary>
    /// <param name="Year">
    /// The year expressed in the calendar's default era.
    /// </param>
    /// <param name="Week">
    /// The week of the year.
    /// </param>
    /// <param name="DoW">
    /// The day of the week.
    /// </param>
    /// <returns>
    /// The <see cref="TDateTime"/> value.
    /// </returns>
    /// <exception cref="EConvertError">
    /// Occurs when the conversion is failed.
    /// </exception>
    /// <seealso cref="DefaultEra"/>
    /// <seealso cref="TryEncodeDateWeek"/>
    {$Endregion}
    Function EncodeDateWeek(Year, Week : Integer; DoW : TDayOfWeek) : TDateTime; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Calculates the era, year of the era, week of the year, and day of the week
    /// for a specified <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <param name="Year">
    /// The year of the era.
    /// </param>
    /// <param name="Week">
    /// The week of the year.
    /// </param>
    /// <param name="DoW">
    /// The day of the week.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the conversion succeeded, otherwise returns
    /// <see langword="false"/>.
    /// </returns>
    /// <seealso cref="DecodeDateWeek"/>
    {$Endregion}
    Function TryDecodeDateWeek(Const DateTime : TDateTime; Out Era, Year, Week : Integer; Out DoW : TDayOfWeek) : Boolean; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Calculates the year, week of the year, and day of the week for a specified
    /// <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="Year">
    /// The year expressed in the calendar's default era.
    /// </param>
    /// <param name="Week">
    /// The week of the year.
    /// </param>
    /// <param name="DoW">
    /// The day of the week.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the conversion succeeded, otherwise returns
    /// <see langword="false"/>.
    /// </returns>
    /// <seealso cref="DefaultEra"/>
    /// <seealso cref="DecodeDateWeek"/>
    {$Endregion}
    Function TryDecodeDateWeek(Const DateTime : TDateTime; Out Year, Week : Integer; Out DoW : TDayOfWeek) : Boolean; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Calculates the era, year of the era, week of the year, and day of the week
    /// for a specified <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <param name="Year">
    /// The year of the era.
    /// </param>
    /// <param name="Week">
    /// The week of the year.
    /// </param>
    /// <param name="DoW">
    /// The day of the week.
    /// </param>
    /// <exception cref="EConvertError">
    /// Occurs when the conversion is failed.
    /// </exception>
    /// <seealso cref="TryDecodeDateWeek"/>
    {$Endregion}
    Procedure DecodeDateWeek(Const DateTime : TDateTime; Out Era, Year, Week : Integer; Out DoW : TDayOfWeek); Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Calculates the year, week of the year, and day of the week for a specified
    /// <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="Year">
    /// The year expressed in the calendar's default era.
    /// </param>
    /// <param name="Week">
    /// The week of the year.
    /// </param>
    /// <param name="DoW">
    /// The day of the week.
    /// </param>
    /// <exception cref="EConvertError">
    /// Occurs when the conversion is failed.
    /// </exception>
    /// <seealso cref="DefaultEra"/>
    /// <seealso cref="TryDecodeDateWeek"/>
    {$Endregion}
    Procedure DecodeDateWeek(Const DateTime : TDateTime; Out Year, Week : Integer; Out DoW : TDayOfWeek); Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Calculates the <see cref="TDateTime"/> value that represents a specified
    /// day of the year for a specified year.
    /// </summary>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <param name="Year">
    /// The year of the era.
    /// </param>
    /// <param name="DayOfYear">
    /// The day of the year.
    /// </param>
    /// <param name="DateTime">
    /// The TDateTimeValue.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the conversion succeeded, otherwise returns
    /// <see langword="false"/>.
    /// </returns>
    /// <seealso cref="EncodeDateDay"/>
    {$Endregion}
    Function TryEncodeDateDay(Era, Year, DayOfYear : Integer; Out DateTime : TDateTime) : Boolean; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Calculates the <see cref="TDateTime"/> value that represents a specified day
    /// of the year for a specified year.
    /// </summary>
    /// <param name="Year">
    /// The year expressed in the calendar's default era.
    /// </param>
    /// <param name="DayOfYear">
    /// The day of the year.
    /// </param>
    /// <param name="DateTime">
    /// The TDateTimeValue.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the conversion succeeded, otherwise returns
    /// <see langword="false"/>.
    /// </returns>
    /// <seealso cref="DefaultEra"/>
    /// <seealso cref="EncodeDateDay"/>
    {$Endregion}
    Function TryEncodeDateDay(Year, DayOfYear : Integer; Out DateTime : TDateTime) : Boolean; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the <see cref="TDateTime"/> value that represents a specified day
    /// of the year for a specified year.
    /// </summary>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <param name="Year">
    /// The year of the era.
    /// </param>
    /// <param name="DayOfYear">
    /// The day of the year.
    /// </param>
    /// <returns>
    /// The <see cref="TDateTime"/> value.
    /// </returns>
    /// <exception cref="EConvertError">
    /// Occurs when the conversion is failed.
    /// </exception>
    /// <seealso cref="TryEncodeDateDay"/>
    {$Endregion}
    Function EncodeDateDay(Era, Year, DayOfYear : Integer) : TDateTime; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the <see cref="TDateTime"/> value that represents a specified day
    /// of the year for a specified year.
    /// </summary>
    /// <param name="Year">
    /// The year expressed in the calendar's default era.
    /// </param>
    /// <param name="DayOfYear">
    /// The day of the year.
    /// </param>
    /// <returns>
    /// The <see cref="TDateTime"/> value.
    /// </returns>
    /// <exception cref="EConvertError">
    /// Occurs when the conversion is failed.
    /// </exception>
    /// <seealso cref="DefaultEra"/>
    /// <seealso cref="TryEncodeDateDay"/>
    {$Endregion}
    Function EncodeDateDay(Year, DayOfYear : Integer) : TDateTime; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Calculates the year and day of the year for a specified <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <param name="Year">
    /// The year of the era.
    /// </param>
    /// <param name="DayOfYear">
    /// The day of the year.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the conversion succeeded, otherwise returns
    /// <see langword="false"/>.
    /// </returns>
    /// <seealso cref="DecodeDateDay"/>
    {$Endregion}
    Function TryDecodeDateDay(Const DateTime : TDateTime; Out Era, Year, DayOfYear : Integer) : Boolean; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Calculates the year and day of the year for a specified <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="Year">
    /// The year expressed in the calendar's default era.
    /// </param>
    /// <param name="DayOfYear">
    /// The day of the year.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the conversion succeeded, otherwise returns
    /// <see langword="false"/>.
    /// </returns>
    /// <seealso cref="DefaultEra"/>
    /// <seealso cref="DecodeDateDay"/>
    {$Endregion}
    Function TryDecodeDateDay(Const DateTime : TDateTime; Out Year, DayOfYear : Integer) : Boolean; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Calculates the year and day of the year for a specified <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <param name="Year">
    /// The year of the era.
    /// </param>
    /// <param name="DayOfYear">
    /// The day of the year.
    /// </param>
    /// <exception cref="EConvertError">
    /// Occurs when the conversion is failed.
    /// </exception>
    /// <seealso cref="TryDecodeDateDay"/>
    {$Endregion}
    Procedure DecodeDateDay(Const DateTime : TDateTime; Out Era, Year, DayOfYear : Integer); Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Calculates the year and day of the year for a specified <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="Year">
    /// The year expressed in the calendar's default era.
    /// </param>
    /// <param name="DayOfYear">
    /// The day of the year.
    /// </param>
    /// <exception cref="EConvertError">
    /// Occurs when the conversion is failed.
    /// </exception>
    /// <seealso cref="DefaultEra"/>
    /// <seealso cref="TryDecodeDateDay"/>
    {$Endregion}
    Procedure DecodeDateDay(Const DateTime : TDateTime; Out Year, DayOfYear : Integer); Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Calculates the <see cref="TDateTime"/> value that represents a specified
    /// era, year, month, and day.
    /// </summary>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <param name="Year">
    /// The year of the era.
    /// </param>
    /// <param name="Month">
    /// The month of the year.
    /// </param>
    /// <param name="Day">
    /// The day of the month.
    /// </param>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the conversion succeeded, otherwise returns
    /// <see langword="false"/>.
    /// </returns>
    /// <seealso cref="EncodeDate"/>
    {$Endregion}
    Function TryEncodeDate(Era, Year, Month, Day : Integer; Out DateTime : TDateTime) : Boolean; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Calculates the <see cref="TDateTime"/> value that represents a specified
    /// year, month, and day.
    /// </summary>
    /// <param name="Year">
    /// The year expressed in the calendar's default era.
    /// </param>
    /// <param name="Month">
    /// The month of the year.
    /// </param>
    /// <param name="Day">
    /// The day of the month.
    /// </param>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the conversion succeeded, otherwise returns
    /// <see langword="false"/>.
    /// </returns>
    /// <seealso cref="DefaultEra"/>
    /// <seealso cref="EncodeDate"/>
    {$Endregion}
    Function TryEncodeDate(Year, Month, Day : Integer; Out DateTime : TDateTime) : Boolean; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the <see cref="TDateTime"/> value that represents a specified era,
    /// year, month, and day.
    /// </summary>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <param name="Year">
    /// The year of the era.
    /// </param>
    /// <param name="Month">
    /// The month of the year.
    /// </param>
    /// <param name="Day">
    /// The day of the month.
    /// </param>
    /// <returns>
    /// The <see cref="TDateTime"/> value.
    /// </returns>
    /// <exception cref="EConvertError">
    /// Occurs when the conversion is failed.
    /// </exception>
    /// <seealso cref="TryEncodeDate"/>
    {$Endregion}
    Function EncodeDate(Era, Year, Month, Day : Integer) : TDateTime; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the <see cref="TDateTime"/> value that represents a specified year,
    /// month, and day.
    /// </summary>
    /// <param name="Year">
    /// The year expressed in the calendar's default era.
    /// </param>
    /// <param name="Month">
    /// The month of the year.
    /// </param>
    /// <param name="Day">
    /// The day of the month.
    /// </param>
    /// <returns>
    /// The <see cref="TDateTime"/> value.
    /// </returns>
    /// <exception cref="EConvertError">
    /// Occurs when the conversion is failed.
    /// </exception>
    /// <seealso cref="DefaultEra"/>
    /// <seealso cref="TryEncodeDate"/>
    {$Endregion}
    Function EncodeDate(Year, Month, Day : Integer) : TDateTime; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Calculates the era, year, month, and day values for a specified <see cref="TDateTime"/>
    /// value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <param name="Year">
    /// The year of the era.
    /// </param>
    /// <param name="Month">
    /// The month of the year.
    /// </param>
    /// <param name="Day">
    /// The day of the month.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the conversion succeeded, otherwise returns
    /// <see langword="false"/>.
    /// </returns>
    /// <seealso cref="DecodeDate"/>
    {$Endregion}
    Function TryDecodeDate(Const DateTime : TDateTime; Out Era, Year, Month, Day : Integer) : Boolean; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Calculates the year, month, and day values for a specified <see cref="TDateTime"/>
    /// value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="Year">
    /// The year expressed in the calendar's default era.
    /// </param>
    /// <param name="Month">
    /// The month of the year.
    /// </param>
    /// <param name="Day">
    /// The day of the month.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the conversion succeeded, otherwise returns
    /// <see langword="false"/>.
    /// </returns>
    /// <seealso cref="DefaultEra"/>
    /// <seealso cref="DecodeDate"/>
    {$Endregion}
    Function TryDecodeDate(Const DateTime : TDateTime; Out Year, Month, Day : Integer) : Boolean; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Calculates the era, year, month, and day values for a specified <see cref="TDateTime"/>
    /// value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <param name="Year">
    /// The year of the era.
    /// </param>
    /// <param name="Month">
    /// The month of the year.
    /// </param>
    /// <param name="Day">
    /// The day of the month.
    /// </param>
    /// <exception cref="EConvertError">
    /// Occurs when the conversion is failed.
    /// </exception>
    /// <seealso cref="TryDecodeDate"/>
    {$Endregion}
    Procedure DecodeDate(Const DateTime : TDateTime; Out Era, Year, Month, Day : Integer); Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Calculates the year, month, and day values for a specified <see cref="TDateTime"/>
    /// value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="Year">
    /// The year expressed in the calendar's default era.
    /// </param>
    /// <param name="Month">
    /// The month of the year.
    /// </param>
    /// <param name="Day">
    /// The day of the month.
    /// </param>
    /// <exception cref="EConvertError">
    /// Occurs when the conversion is failed.
    /// </exception>
    /// <seealso cref="DefaultEra"/>
    /// <seealso cref="TryDecodeDate"/>
    {$Endregion}
    Procedure DecodeDate(Const DateTime : TDateTime; Out Year, Month, Day : Integer); Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the Julian day for a specified <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <returns>
    /// The Julian day.
    /// </returns>
    /// <seealso cref="JulianDayToDateTime"/>
    {$Endregion}
    Class Function DateTimeToJulianDay(Const DateTime : TDateTime) : Extended; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the <see cref="TDateTime"/> value for a specified Julian day.
    /// </summary>
    /// <param name="JulianDate">
    /// The Julian day.
    /// </param>
    /// <returns>
    /// The <see cref="TDateTime"/> value.
    /// </returns>
    /// <seealso cref="DateTimeToJulianDay"/>
    {$Endregion}
    Class Function JulianDayToDateTime(Const JulianDate : Extended) : TDateTime; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value, which is the result of combining
    /// a specified date with a specified time.
    /// </summary>
    /// <param name="Date">
    /// The <see cref="TDate"/> value.
    /// </param>
    /// <param name="Time">
    /// The <see cref="TTime"/> value.
    /// </param>
    /// <returns>
    /// The <see cref="TDateTime"/> value.
    /// </returns>
    {$Endregion}
    Class Function CombineDateTime(Const Date : TDate; Const Time : TTime) : TDateTime; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the universal time coosrdinate of a specified local time.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value in local time coordinate.
    /// </param>
    /// <returns>
    /// The <see cref="TDateTime"/> value in universal time coordinate.
    /// </returns>
    /// <seealso cref="UniversalToLocalDateTime"/>
    {$Endregion}
    Class Function LocalToUniversalDateTime(Const DateTime : TDateTime) : TDateTime; Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the local time of a specified universal time coosrdinate.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value in universal time coordinate.
    /// </param>
    /// <returns>
    /// The <see cref="TDateTime"/> value in local time coordinate.
    /// </returns>
    /// <seealso cref="LocalToUniversalDateTime"/>
    {$Endregion}
    Class Function UniversalToLocalDateTime(Const DateTime : TDateTime) : TDateTime; Static;
    { Pick-a-Field Functions }
    {$Region 'xmldoc'}
    /// <summary>
    /// Strips the time portion from a <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <returns>
    /// The date portion of the <see cref="TDateTime"/> value.
    /// </returns>
    /// <seealso cref="TimeOf"/>
    {$Endregion}
    Class Function DateOf(Const DateTime : TDateTime) : TDate; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the era represented by a <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <returns>
    /// The era represented by the <see cref="TDateTime"/> value.
    /// </returns>
    {$Endregion}
    Function EraOf(Const DateTime : TDateTime) : Integer; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the year represented by a <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <returns>
    /// The year represented by the <see cref="TDateTime"/> value.
    /// </returns>
    {$Endregion}
    Function YearOf(Const DateTime : TDateTime) : Integer; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the month of the year represented by a <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <returns>
    /// The month of the year represented by the <see cref="TDateTime"/> value.
    /// </returns>
    {$Endregion}
    Function MonthOfYear(Const DateTime : TDateTime) : Integer; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the week of the year represented by a <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <returns>
    /// The week of the year represented by the <see cref="TDateTime"/> value.
    /// </returns>
    {$Endregion}
    Function WeekOfYear(Const DateTime : TDateTime) : Integer; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the month of the month represented by a <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <returns>
    /// The week of the month represented by the <see cref="TDateTime"/> value.
    /// </returns>
    {$Endregion}
    Function WeekOfMonth(Const DateTime : TDateTime) : Integer; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the day of the year represented by a <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <returns>
    /// The day of the year represented by the <see cref="TDateTime"/> value.
    /// </returns>
    {$Endregion}
    Function DayOfYear(Const DateTime : TDateTime) : Integer; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the day of the month represented by a <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <returns>
    /// The day of the month represented by the <see cref="TDateTime"/> value.
    /// </returns>
    {$Endregion}
    Function DayOfMonth(Const DateTime : TDateTime) : Integer; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the day of the week represented by a <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <returns>
    /// The day of the week represented by the <see cref="TDateTime"/> value.
    /// </returns>
    {$Endregion}
    Class Function DayOfWeek(Const DateTime : TDateTime) : TDayOfWeek; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Strips the date portion from a <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <returns>
    /// The time portion of the <see cref="TDateTime"/> value.
    /// </returns>
    /// <seealso cref="DateOf"/>
    {$Endregion}
    Class Function TimeOf(Const DateTime : TDateTime) : TTime; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the hour of the day represented by a <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <returns>
    /// The hour of the day represented by the <see cref="TDateTime"/> value.
    /// </returns>
    {$Endregion}
    Class Function HourOfDay(Const DateTime : TDateTime) : Integer; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the number of minutes between a specified <see cref="TDateTime"/>
    /// value and midnight of the same day.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <returns>
    /// The minute of the day represented by the <see cref="TDateTime"/> value.
    /// </returns>
    {$Endregion}
    Class Function MinuteOfDay(Const DateTime : TDateTime) : Integer; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the minute of the hour represented by a <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <returns>
    /// The minute of the hour represented by the <see cref="TDateTime"/> value.
    /// </returns>
    {$Endregion}
    Class Function MinuteOfHour(Const DateTime : TDateTime) : Integer; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the number of seconds between a specified <see cref="TDateTime"/>
    /// value and midnight of the same day.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <returns>
    /// The second of the day represented by the <see cref="TDateTime"/> value.
    /// </returns>
    {$Endregion}
    Class Function SecondOfDay(Const DateTime : TDateTime) : Integer; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the second of the minute represented by a <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <returns>
    /// The second of the minute represented by the <see cref="TDateTime"/> value.
    /// </returns>
    {$Endregion}
    Class Function SecondOfMinute(Const DateTime : TDateTime) : Integer; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the number of milliseconds between a specified <see cref="TDateTime"/>
    /// value and midnight of the same day.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <returns>
    /// The millisecond of the day represented by the <see cref="TDateTime"/> value.
    /// </returns>
    {$Endregion}
    Class Function MillisecondOfDay(Const DateTime : TDateTime) : Integer; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the millisecond of the second represented by a <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <returns>
    /// The millisecond of the second represented by the <see cref="TDateTime"/> value.
    /// </returns>
    {$Endregion}
    Class Function MillisecondOfSecond(Const DateTime : TDateTime) : Integer; Static; Inline;
    { Start of a Field Functions }
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value that represents the first expressible
    /// moment of a specified era.
    /// </summary>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <returns>
    /// The <see cref="TDateTime"/> value of the first moment.
    /// </returns>
    /// <seealso cref="EndOfEra"/>
    {$Endregion}
    Function StartOfEra(Era : Integer) : TDateTime; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value that represents the first expressible
    /// moment of a specified year.
    /// </summary>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <param name="Year">
    /// The year of the era.
    /// </param>
    /// <returns>
    /// The <see cref="TDateTime"/> value of the first moment.
    /// </returns>
    /// <seealso cref="EndOfYear"/>
    {$Endregion}
    Function StartOfYear(Era, Year : Integer) : TDateTime; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value that represents the first expressible
    /// moment of a specified year.
    /// </summary>
    /// <param name="Year">
    /// The year expressed in the calendar's default era.
    /// </param>
    /// <returns>
    /// The <see cref="TDateTime"/> value of the first moment.
    /// </returns>
    /// <seealso cref="EndOfYear"/>
    {$Endregion}
    Function StartOfYear(Year : Integer) : TDateTime; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value that represents the first expressible
    /// moment of the year identified by a specified <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value of the first moment.
    /// </param>
    /// <returns>
    /// The <see cref="TDateTime"/> value of the first moment.
    /// </returns>
    /// <seealso cref="EndOfYear"/>
    {$Endregion}
    Function StartOfYear(Const DateTime : TDateTime) : TDateTime; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value that represents the first expressible
    /// moment of a specified month in a specified year.
    /// </summary>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <param name="Year">
    /// The year of the era.
    /// </param>
    /// <param name="Month">
    /// The month of the year.
    /// </param>
    /// <returns>
    /// The <see cref="TDateTime"/> value of the first moment.
    /// </returns>
    /// <seealso cref="EndOfMonth"/>
    {$Endregion}
    Function StartOfMonth(Era, Year, Month : Integer) : TDateTime; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value that represents the first expressible
    /// moment of a specified month in a specified year.
    /// </summary>
    /// <param name="Year">
    /// The year expressed in the calendar's default era.
    /// </param>
    /// <param name="Month">
    /// The month of the year.
    /// </param>
    /// <returns>
    /// The <see cref="TDateTime"/> value of the first moment.
    /// </returns>
    /// <seealso cref="EndOfMonth"/>
    {$Endregion}
    Function StartOfMonth(Year, Month : Integer) : TDateTime; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value that represents the first expressible
    /// moment of the month identified by a specified <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value of the first moment.
    /// </param>
    /// <returns>
    /// The <see cref="TDateTime"/> value of the first moment.
    /// </returns>
    /// <seealso cref="EndOfMonth"/>
    {$Endregion}
    Function StartOfMonth(Const DateTime : TDateTime) : TDateTime; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value that represents the first expressible
    /// moment of the week identified by a specified <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value of the first moment.
    /// </param>
    /// <returns>
    /// The <see cref="TDateTime"/> value of the first moment.
    /// </returns>
    /// <seealso cref="EndOfWeek"/>
    {$Endregion}
    Function StartOfWeek(Const DateTime : TDateTime) : TDateTime; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value that represents the first expressible
    /// moment of the day identified by a specified <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value of the first moment.
    /// </param>
    /// <returns>
    /// The <see cref="TDateTime"/> value of the first moment.
    /// </returns>
    /// <seealso cref="EndOfDay"/>
    {$Endregion}
    Class Function StartOfDay(Const DateTime : TDateTime) : TDateTime; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value that represents the first expressible
    /// moment of the hour identified by a specified <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value of the first moment.
    /// </param>
    /// <returns>
    /// The <see cref="TDateTime"/> value of the first moment.
    /// </returns>
    /// <seealso cref="EndOfHour"/>
    {$Endregion}
    Class Function StartOfHour(Const DateTime : TDateTime) : TDateTime; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value that represents the first expressible
    /// moment of the minute identified by a specified <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value of the first moment.
    /// </param>
    /// <returns>
    /// The <see cref="TDateTime"/> value of the first moment.
    /// </returns>
    /// <seealso cref="EndOfMinute"/>
    {$Endregion}
    Class Function StartOfMinute(Const DateTime : TDateTime) : TDateTime; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value that represents the first expressible
    /// moment of the second identified by a specified <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value of the first moment.
    /// </param>
    /// <returns>
    /// The <see cref="TDateTime"/> value of the first moment.
    /// </returns>
    /// <seealso cref="EndOfSecond"/>
    {$Endregion}
    Class Function StartOfSecond(Const DateTime : TDateTime) : TDateTime; Static; Inline;
    { End of a Field Functions }
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value that represents the last expressible
    /// moment of a specified era.
    /// </summary>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <returns>
    /// The <see cref="TDateTime"/> value of the last moment.
    /// </returns>
    /// <seealso cref="StartOfEra"/>
    {$Endregion}
    Function EndOfEra(Era : Integer) : TDateTime; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value that represents the last expressible
    /// moment of a specified year.
    /// </summary>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <param name="Year">
    /// The year of the era.
    /// </param>
    /// <returns>
    /// The <see cref="TDateTime"/> value of the last moment.
    /// </returns>
    /// <seealso cref="StartOfYear"/>
    {$Endregion}
    Function EndOfYear(Era, Year : Integer) : TDateTime; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value that represents the last expressible
    /// moment of a specified year.
    /// </summary>
    /// <param name="Year">
    /// The year expressed in the calendar's default era.
    /// </param>
    /// <returns>
    /// The <see cref="TDateTime"/> value of the last moment.
    /// </returns>
    /// <seealso cref="StartOfYear"/>
    {$Endregion}
    Function EndOfYear(Year : Integer) : TDateTime; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value that represents the last expressible
    /// moment of the year identified by a specified <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value of the last moment.
    /// </param>
    /// <returns>
    /// The <see cref="TDateTime"/> value of the last moment.
    /// </returns>
    /// <seealso cref="StartOfYear"/>
    {$Endregion}
    Function EndOfYear(Const DateTime : TDateTime) : TDateTime; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value that represents the last expressible
    /// moment of a specified month in a specified year.
    /// </summary>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <param name="Year">
    /// The year of the era.
    /// </param>
    /// <param name="Month">
    /// The month of the year.
    /// </param>
    /// <returns>
    /// The <see cref="TDateTime"/> value of the last moment.
    /// </returns>
    /// <seealso cref="StartOfMonth"/>
    {$Endregion}
    Function EndOfMonth(Era, Year, Month : Integer) : TDateTime; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value that represents the last expressible
    /// moment of a specified month in a specified year.
    /// </summary>
    /// <param name="Year">
    /// The year expressed in the calendar's default era.
    /// </param>
    /// <param name="Month">
    /// The month of the year.
    /// </param>
    /// <returns>
    /// The <see cref="TDateTime"/> value of the last moment.
    /// </returns>
    /// <seealso cref="StartOfMonth"/>
    {$Endregion}
    Function EndOfMonth(Year, Month : Integer) : TDateTime; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value that represents the last expressible
    /// moment of the month identified by a specified <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value of the last moment.
    /// </param>
    /// <returns>
    /// The <see cref="TDateTime"/> value of the last moment.
    /// </returns>
    /// <seealso cref="StartOfMonth"/>
    {$Endregion}
    Function EndOfMonth(Const DateTime : TDateTime) : TDateTime; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value that represents the last expressible
    /// moment of the week identified by a specified <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value of the last moment.
    /// </param>
    /// <returns>
    /// The <see cref="TDateTime"/> value of the last moment.
    /// </returns>
    /// <seealso cref="StartOfWeek"/>
    {$Endregion}
    Function EndOfWeek(Const DateTime : TDateTime) : TDateTime; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value that represents the last expressible
    /// moment of the day identified by a specified <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value of the last moment.
    /// </param>
    /// <returns>
    /// The <see cref="TDateTime"/> value of the last moment.
    /// </returns>
    /// <seealso cref="StartOfDay"/>
    {$Endregion}
    Class Function EndOfDay(Const DateTime : TDateTime) : TDateTime; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value that represents the last expressible
    /// moment of the hour identified by a specified <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value of the last moment.
    /// </param>
    /// <returns>
    /// The <see cref="TDateTime"/> value of the last moment.
    /// </returns>
    /// <seealso cref="StartOfHour"/>
    {$Endregion}
    Class Function EndOfHour(Const DateTime : TDateTime) : TDateTime; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value that represents the last expressible
    /// moment of the minute identified by a specified <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value of the last moment.
    /// </param>
    /// <returns>
    /// The <see cref="TDateTime"/> value of the last moment.
    /// </returns>
    /// <seealso cref="StartOfMinute"/>
    {$Endregion}
    Class Function EndOfMinute(Const DateTime : TDateTime) : TDateTime; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value that represents the last expressible
    /// moment of the second identified by a specified <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value of the last moment.
    /// </param>
    /// <returns>
    /// The <see cref="TDateTime"/> value of the last moment.
    /// </returns>
    /// <seealso cref="StartOfSecond"/>
    {$Endregion}
    Class Function EndOfSecond(Const DateTime : TDateTime) : TDateTime; Static; Inline;
    { Previous of a Field Functions }
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value shifted back by a specified number of years.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="NumberOfYears">
    /// The number of years.
    /// </param>
    /// <returns>
    /// The shifted <see cref="TDateTime"/> value.
    /// </returns>
    /// <seealso cref="NextYear"/>
    /// <seealso cref="IncYear"/>
    /// <seealso cref="DecYear"/>
    {$Endregion}
    Function PrevYear(Const DateTime : TDateTime; NumberOfYears : Integer = 1) : TDateTime; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value shifted back by a specified number of months.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="NumberOfMonths">
    /// The number of months.
    /// </param>
    /// <returns>
    /// The shifted <see cref="TDateTime"/> value.
    /// </returns>
    /// <seealso cref="NextMonth"/>
    /// <seealso cref="IncMonth"/>
    /// <seealso cref="DecMonth"/>
    {$Endregion}
    Function PrevMonth(Const DateTime : TDateTime; NumberOfMonths : Integer = 1) : TDateTime; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value shifted back by a specified number of weeks.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="NumberOfWeeks">
    /// The number of weeks.
    /// </param>
    /// <returns>
    /// The shifted <see cref="TDateTime"/> value.
    /// </returns>
    /// <seealso cref="NextWeek"/>
    /// <seealso cref="IncWeek"/>
    /// <seealso cref="DecWeek"/>
    {$Endregion}
    Class Function PrevWeek(Const DateTime : TDateTime; NumberOfWeeks : Integer = 1) : TDateTime; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value shifted back by a specified number of days.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="NumberOfDays">
    /// The number of days.
    /// </param>
    /// <returns>
    /// The shifted <see cref="TDateTime"/> value.
    /// </returns>
    /// <seealso cref="NextDay"/>
    /// <seealso cref="IncDay"/>
    /// <seealso cref="DecDay"/>
    {$Endregion}
    Class Function PrevDay(Const DateTime : TDateTime; NumberOfDays : Integer = 1) : TDateTime; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value that represents the last day of the
    /// week of a specified day in a specified <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="DoW">
    /// The day of the week.
    /// </param>
    /// <returns>
    /// The <see cref="TDateTime"/> value of the last day of the week.
    /// </returns>
    /// <seealso cref="NextDayOfWeek"/>
    {$Endregion}
    Function PrevDayOfWeek(Const DateTime : TDateTime; DoW : TDayOfWeek) : TDateTime;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value shifted back by a specified number of hours.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="NumberOfHours">
    /// The number of hours.
    /// </param>
    /// <returns>
    /// The shifted <see cref="TDateTime"/> value.
    /// </returns>
    /// <seealso cref="NextHour"/>
    /// <seealso cref="IncHour"/>
    /// <seealso cref="DecHour"/>
    {$Endregion}
    Class Function PrevHour(Const DateTime : TDateTime; NumberOfHours : Integer = 1) : TDateTime; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value shifted back by a specified number of minutes.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="NumberOfMinutes">
    /// The number of minutes.
    /// </param>
    /// <returns>
    /// The shifted <see cref="TDateTime"/> value.
    /// </returns>
    /// <seealso cref="NextMinute"/>
    /// <seealso cref="IncMinute"/>
    /// <seealso cref="DecMinute"/>
    {$Endregion}
    Class Function PrevMinute(Const DateTime : TDateTime; NumberOfMinutes : Integer = 1) : TDateTime; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value shifted back by a specified number of seconds.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="NumberOfSeconds">
    /// The number of seconds.
    /// </param>
    /// <returns>
    /// The shifted <see cref="TDateTime"/> value.
    /// </returns>
    /// <seealso cref="NextSecond"/>
    /// <seealso cref="IncSecond"/>
    /// <seealso cref="DecSecond"/>
    {$Endregion}
    Class Function PrevSecond(Const DateTime : TDateTime; NumberOfSeconds : Integer = 1) : TDateTime; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value shifted back by a specified number of milliseconds.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="NumberOfMilliseconds">
    /// The number of milliseconds.
    /// </param>
    /// <returns>
    /// The shifted <see cref="TDateTime"/> value.
    /// </returns>
    /// <seealso cref="NextMillisecond"/>
    /// <seealso cref="IncMillisecond"/>
    /// <seealso cref="DecMillisecond"/>
    {$Endregion}
    Class Function PrevMillisecond(Const DateTime : TDateTime; NumberOfMilliseconds : Integer = 1) : TDateTime; Static; Inline;
    { Next of a Field Functions }
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value shifted forward by a specified number of years.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="NumberOfYears">
    /// The number of years.
    /// </param>
    /// <returns>
    /// The shifted <see cref="TDateTime"/> value.
    /// </returns>
    /// <seealso cref="PrevYear"/>
    /// <seealso cref="IncYear"/>
    /// <seealso cref="DecYear"/>
    {$Endregion}
    Function NextYear(Const DateTime : TDateTime; NumberOfYears : Integer = 1) : TDateTime;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value shifted forward by a specified number of months.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="NumberOfMonths">
    /// The number of months.
    /// </param>
    /// <returns>
    /// The shifted <see cref="TDateTime"/> value.
    /// </returns>
    /// <seealso cref="PrevMonth"/>
    /// <seealso cref="IncMonth"/>
    /// <seealso cref="DecMonth"/>
    {$Endregion}
    Function NextMonth(Const DateTime : TDateTime; NumberOfMonths : Integer = 1) : TDateTime;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value shifted forward by a specified number of weeks.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="NumberOfWeeks">
    /// The number of weeks.
    /// </param>
    /// <returns>
    /// The shifted <see cref="TDateTime"/> value.
    /// </returns>
    /// <seealso cref="PrevWeek"/>
    /// <seealso cref="IncWeek"/>
    /// <seealso cref="DecWeek"/>
    {$Endregion}
    Class Function NextWeek(Const DateTime : TDateTime; NumberOfWeeks : Integer = 1) : TDateTime; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value shifted forward by a specified number of days.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="NumberOfDays">
    /// The number of days.
    /// </param>
    /// <returns>
    /// The shifted <see cref="TDateTime"/> value.
    /// </returns>
    /// <seealso cref="PrevDay"/>
    /// <seealso cref="IncDay"/>
    /// <seealso cref="DecDay"/>
    {$Endregion}
    Class Function NextDay(Const DateTime : TDateTime; NumberOfDays : Integer = 1) : TDateTime; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value that represents the next day of the
    /// week of a specified day in a specified <see cref="TDateTime"/> value.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="DoW">
    /// The day of the week.
    /// </param>
    /// <returns>
    /// The <see cref="TDateTime"/> value of the next day of the week.
    /// </returns>
    /// <seealso cref="PrevDayOfWeek"/>
    {$Endregion}
    Function NextDayOfWeek(Const DateTime : TDateTime; DoW : TDayOfWeek) : TDateTime;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value shifted forward by a specified number of hours.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="NumberOfHours">
    /// The number of hours.
    /// </param>
    /// <returns>
    /// The shifted <see cref="TDateTime"/> value.
    /// </returns>
    /// <seealso cref="PrevHour"/>
    /// <seealso cref="IncHour"/>
    /// <seealso cref="DecHour"/>
    {$Endregion}
    Class Function NextHour(Const DateTime : TDateTime; NumberOfHours : Integer = 1) : TDateTime; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value shifted forward by a specified number of minutes.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="NumberOfMinutes">
    /// The number of minutes.
    /// </param>
    /// <returns>
    /// The shifted <see cref="TDateTime"/> value.
    /// </returns>
    /// <seealso cref="PrevMinute"/>
    /// <seealso cref="IncMinute"/>
    /// <seealso cref="DecMinute"/>
    {$Endregion}
    Class Function NextMinute(Const DateTime : TDateTime; NumberOfMinutes : Integer = 1) : TDateTime; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value shifted forward by a specified number of seconds.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="NumberOfSeconds">
    /// The number of seconds.
    /// </param>
    /// <returns>
    /// The shifted <see cref="TDateTime"/> value.
    /// </returns>
    /// <seealso cref="PrevSecond"/>
    /// <seealso cref="IncSecond"/>
    /// <seealso cref="DecSecond"/>
    {$Endregion}
    Class Function NextSecond(Const DateTime : TDateTime; NumberOfSeconds : Integer = 1) : TDateTime; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a <see cref="TDateTime"/> value shifted forward by a specified number of milliseconds.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="NumberOfMilliseconds">
    /// The number of milliseconds.
    /// </param>
    /// <returns>
    /// The shifted <see cref="TDateTime"/> value.
    /// </returns>
    /// <seealso cref="PrevMillisecond"/>
    /// <seealso cref="IncMillisecond"/>
    /// <seealso cref="DecMillisecond"/>
    {$Endregion}
    Class Function NextMillisecond(Const DateTime : TDateTime; NumberOfMilliseconds : Integer = 1) : TDateTime; Static; Inline;
    { Increment Field Functions }
    {$Region 'xmldoc'}
    /// <summary>
    /// Increments a <see cref="TDateTime"/> value by a specified number of years.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="NumberOfYears">
    /// The number of years.
    /// </param>
    /// <seealso cref="DecYear"/>
    /// <seealso cref="NextYear"/>
    /// <seealso cref="PrevYear"/>
    {$Endregion}
    Procedure IncYear(Var DateTime : TDateTime; NumberOfYears : Integer = 1); Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Increments a <see cref="TDate"/> value by a specified number of years.
    /// </summary>
    /// <param name="Date">
    /// The <see cref="TDate"/> value.
    /// </param>
    /// <param name="NumberOfYears">
    /// The number of years.
    /// </param>
    /// <seealso cref="DecYear"/>
    /// <seealso cref="NextYear"/>
    /// <seealso cref="PrevYear"/>
    {$Endregion}
    Procedure IncYear(Var Date : TDate; NumberOfYears : Integer = 1); Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Increments a <see cref="TDateTime"/> value by a specified number of months.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="NumberOfMonths">
    /// The number of months.
    /// </param>
    /// <seealso cref="DecMonth"/>
    /// <seealso cref="NextMonth"/>
    /// <seealso cref="PrevMonth"/>
    {$Endregion}
    Procedure IncMonth(Var DateTime : TDateTime; NumberOfMonths : Integer = 1); Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Increments a <see cref="TDate"/> value by a specified number of months.
    /// </summary>
    /// <param name="Date">
    /// The <see cref="TDate"/> value.
    /// </param>
    /// <param name="NumberOfMonths">
    /// The number of months.
    /// </param>
    /// <seealso cref="DecMonth"/>
    /// <seealso cref="NextMonth"/>
    /// <seealso cref="PrevMonth"/>
    {$Endregion}
    Procedure IncMonth(Var Date : TDate; NumberOfMonths : Integer = 1); Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Increments a <see cref="TDateTime"/> value by a specified number of weeks.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="NumberOfWeeks">
    /// The number of weeks.
    /// </param>
    /// <seealso cref="DecWeek"/>
    /// <seealso cref="NextWeek"/>
    /// <seealso cref="PrevWeek"/>
    {$Endregion}
    Class Procedure IncWeek(Var DateTime : TDateTime; NumberOfWeeks : Integer = 1); Overload; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Increments a <see cref="TDate"/> value by a specified number of weeks.
    /// </summary>
    /// <param name="Date">
    /// The <see cref="TDate"/> value.
    /// </param>
    /// <param name="NumberOfWeeks">
    /// The number of weeks.
    /// </param>
    /// <seealso cref="DecWeek"/>
    /// <seealso cref="NextWeek"/>
    /// <seealso cref="PrevWeek"/>
    {$Endregion}
    Class Procedure IncWeek(Var Date : TDate; NumberOfWeeks : Integer = 1); Overload; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Increments a <see cref="TDateTime"/> value by a specified number of days.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="NumberOfDays">
    /// The number of days.
    /// </param>
    /// <seealso cref="DecDay"/>
    /// <seealso cref="NextDay"/>
    /// <seealso cref="PrevDay"/>
    {$Endregion}
    Class Procedure IncDay(Var DateTime : TDateTime; NumberOfDays : Integer = 1); Overload; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Increments a <see cref="TDate"/> value by a specified number of days.
    /// </summary>
    /// <param name="Date">
    /// The <see cref="TDate"/> value.
    /// </param>
    /// <param name="NumberOfDays">
    /// The number of days.
    /// </param>
    /// <seealso cref="DecDay"/>
    /// <seealso cref="NextDay"/>
    /// <seealso cref="PrevDay"/>
    {$Endregion}
    Class Procedure IncDay(Var Date : TDate; NumberOfDays : Integer = 1); Overload; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Increments a <see cref="TDateTime"/> value by a specified number of hours.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="NumberOfHours">
    /// The number of hours.
    /// </param>
    /// <seealso cref="DecHour"/>
    /// <seealso cref="NextHour"/>
    /// <seealso cref="PrevHour"/>
    {$Endregion}
    Class Procedure IncHour(Var DateTime : TDateTime; NumberOfHours : Integer = 1); Overload; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Increments a <see cref="TTime"/> value by a specified number of hours.
    /// </summary>
    /// <param name="Time">
    /// The <see cref="TTime"/> value.
    /// </param>
    /// <param name="NumberOfHours">
    /// The number of hours.
    /// </param>
    /// <seealso cref="DecHour"/>
    /// <seealso cref="NextHour"/>
    /// <seealso cref="PrevHour"/>
    {$Endregion}
    Class Procedure IncHour(Var Time : TTime; NumberOfHours : Integer = 1); Overload; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Increments a <see cref="TDateTime"/> value by a specified number of minutes.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="NumberOfMinutes">
    /// The number of minutes.
    /// </param>
    /// <seealso cref="DecMinute"/>
    /// <seealso cref="NextMinute"/>
    /// <seealso cref="PrevMinute"/>
    {$Endregion}
    Class Procedure IncMinute(Var DateTime : TDateTime; NumberOfMinutes : Integer = 1); Overload; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Increments a <see cref="TTime"/> value by a specified number of minutes.
    /// </summary>
    /// <param name="Time">
    /// The <see cref="TTime"/> value.
    /// </param>
    /// <param name="NumberOfMinutes">
    /// The number of minutes.
    /// </param>
    /// <seealso cref="DecMinute"/>
    /// <seealso cref="NextMinute"/>
    /// <seealso cref="PrevMinute"/>
    {$Endregion}
    Class Procedure IncMinute(Var Time : TTime; NumberOfMinutes : Integer = 1); Overload; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Increments a <see cref="TDateTime"/> value by a specified number of seconds.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="NumberOfSeconds">
    /// The number of seconds.
    /// </param>
    /// <seealso cref="DecSecond"/>
    /// <seealso cref="NextSecond"/>
    /// <seealso cref="PrevSecond"/>
    {$Endregion}
    Class Procedure IncSecond(Var DateTime : TDateTime; NumberOfSeconds : Integer = 1); Overload; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Increments a <see cref="TTime"/> value by a specified number of seconds.
    /// </summary>
    /// <param name="Time">
    /// The <see cref="TTime"/> value.
    /// </param>
    /// <param name="NumberOfSeconds">
    /// The number of seconds.
    /// </param>
    /// <seealso cref="DecSecond"/>
    /// <seealso cref="NextSecond"/>
    /// <seealso cref="PrevSecond"/>
    {$Endregion}
    Class Procedure IncSecond(Var Time : TTime; NumberOfSeconds : Integer = 1); Overload; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Increments a <see cref="TDateTime"/> value by a specified number of milliseconds.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="NumberOfMilliseconds">
    /// The number of milliseconds.
    /// </param>
    /// <seealso cref="DecMillisecond"/>
    /// <seealso cref="NextMillisecond"/>
    /// <seealso cref="PrevMillisecond"/>
    {$Endregion}
    Class Procedure IncMillisecond(Var DateTime : TDateTime; NumberOfMilliseconds : Integer = 1); Overload; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Increments a <see cref="TTime"/> value by a specified number of milliseconds.
    /// </summary>
    /// <param name="Time">
    /// The <see cref="TTime"/> value.
    /// </param>
    /// <param name="NumberOfMilliseconds">
    /// The number of milliseconds.
    /// </param>
    /// <seealso cref="DecMillisecond"/>
    /// <seealso cref="NextMillisecond"/>
    /// <seealso cref="PrevMillisecond"/>
    {$Endregion}
    Class Procedure IncMillisecond(Var Time : TTime; NumberOfMilliseconds : Integer = 1); Overload; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Increments a <see cref="TDateTime"/> value by a specified number of days
    /// including fraction of a day.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="Delta">
    /// The number of days including fraction of a day.
    /// </param>
    /// <seealso cref="DecDateTime"/>
    {$Endregion}
    Class Procedure IncDateTime(Var DateTime : TDateTime; Const Delta : Double); Static; Inline;
    { Decrement Field procedures }
    {$Region 'xmldoc'}
    /// <summary>
    /// Decrements a <see cref="TDateTime"/> value by a specified number of years.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="NumberOfYears">
    /// The number of years.
    /// </param>
    /// <seealso cref="IncYear"/>
    /// <seealso cref="NextYear"/>
    /// <seealso cref="PrevYear"/>
    {$Endregion}
    Procedure DecYear(Var DateTime : TDateTime; NumberOfYears : Integer = 1); Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Decrements a <see cref="TDate"/> value by a specified number of years.
    /// </summary>
    /// <param name="Date">
    /// The <see cref="TDate"/> value.
    /// </param>
    /// <param name="NumberOfYears">
    /// The number of years.
    /// </param>
    /// <seealso cref="IncYear"/>
    /// <seealso cref="NextYear"/>
    /// <seealso cref="PrevYear"/>
    {$Endregion}
    Procedure DecYear(Var Date : TDate; NumberOfYears : Integer = 1); Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Decrements a <see cref="TDateTime"/> value by a specified number of months.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="NumberOfMonths">
    /// The number of months.
    /// </param>
    /// <seealso cref="IncMonth"/>
    /// <seealso cref="NextMonth"/>
    /// <seealso cref="PrevMonth"/>
    {$Endregion}
    Procedure DecMonth(Var DateTime : TDateTime; NumberOfMonths : Integer = 1); Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Decrements a <see cref="TDate"/> value by a specified number of months.
    /// </summary>
    /// <param name="Date">
    /// The <see cref="TDate"/> value.
    /// </param>
    /// <param name="NumberOfMonths">
    /// The number of months.
    /// </param>
    /// <seealso cref="IncMonth"/>
    /// <seealso cref="NextMonth"/>
    /// <seealso cref="PrevMonth"/>
    {$Endregion}
    Procedure DecMonth(Var Date : TDate; NumberOfMonths : Integer = 1); Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Decrements a <see cref="TDateTime"/> value by a specified number of weeks.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="NumberOfWeeks">
    /// The number of weeks.
    /// </param>
    /// <seealso cref="IncWeek"/>
    /// <seealso cref="NextWeek"/>
    /// <seealso cref="PrevWeek"/>
    {$Endregion}
    Class Procedure DecWeek(Var DateTime : TDateTime; NumberOfWeeks : Integer = 1); Overload; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Decrements a <see cref="TDate"/> value by a specified number of weeks.
    /// </summary>
    /// <param name="Date">
    /// The <see cref="TDate"/> value.
    /// </param>
    /// <param name="NumberOfWeeks">
    /// The number of weeks.
    /// </param>
    /// <seealso cref="IncWeek"/>
    /// <seealso cref="NextWeek"/>
    /// <seealso cref="PrevWeek"/>
    {$Endregion}
    Class Procedure DecWeek(Var Date : TDate; NumberOfWeeks : Integer = 1); Overload; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Decrements a <see cref="TDateTime"/> value by a specified number of days.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="NumberOfDays">
    /// The number of days.
    /// </param>
    /// <seealso cref="IncDay"/>
    /// <seealso cref="NextDay"/>
    /// <seealso cref="PrevDay"/>
    {$Endregion}
    Class Procedure DecDay(Var DateTime : TDateTime; NumberOfDays : Integer = 1); Overload; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Decrements a <see cref="TDate"/> value by a specified number of days.
    /// </summary>
    /// <param name="Date">
    /// The <see cref="TDate"/> value.
    /// </param>
    /// <param name="NumberOfDays">
    /// The number of days.
    /// </param>
    /// <seealso cref="IncDay"/>
    /// <seealso cref="NextDay"/>
    /// <seealso cref="PrevDay"/>
    {$Endregion}
    Class Procedure DecDay(Var Date : TDate; NumberOfDays : Integer = 1); Overload; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Decrements a <see cref="TDateTime"/> value by a specified number of hours.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="NumberOfHours">
    /// The number of hours.
    /// </param>
    /// <seealso cref="IncHour"/>
    /// <seealso cref="NextHour"/>
    /// <seealso cref="PrevHour"/>
    {$Endregion}
    Class Procedure DecHour(Var DateTime : TDateTime; NumberOfHours : Integer = 1); Overload; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Decrements a <see cref="TTime"/> value by a specified number of hours.
    /// </summary>
    /// <param name="Time">
    /// The <see cref="TTime"/> value.
    /// </param>
    /// <param name="NumberOfHours">
    /// The number of hours.
    /// </param>
    /// <seealso cref="IncHour"/>
    /// <seealso cref="NextHour"/>
    /// <seealso cref="PrevHour"/>
    {$Endregion}
    Class Procedure DecHour(Var Time : TTime; NumberOfHours : Integer = 1); Overload; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Decrements a <see cref="TDateTime"/> value by a specified number of minutes.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="NumberOfMinutes">
    /// The number of minutes.
    /// </param>
    /// <seealso cref="IncMinute"/>
    /// <seealso cref="NextMinute"/>
    /// <seealso cref="PrevMinute"/>
    {$Endregion}
    Class Procedure DecMinute(Var DateTime : TDateTime; NumberOfMinutes : Integer = 1); Overload; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Decrements a <see cref="TTime"/> value by a specified number of minutes.
    /// </summary>
    /// <param name="Time">
    /// The <see cref="TTime"/> value.
    /// </param>
    /// <param name="NumberOfMinutes">
    /// The number of minutes.
    /// </param>
    /// <seealso cref="IncMinute"/>
    /// <seealso cref="NextMinute"/>
    /// <seealso cref="PrevMinute"/>
    {$Endregion}
    Class Procedure DecMinute(Var Time : TTime; NumberOfMinutes : Integer = 1); Overload; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Decrements a <see cref="TDateTime"/> value by a specified number of seconds.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="NumberOfSeconds">
    /// The number of seconds.
    /// </param>
    /// <seealso cref="IncSecond"/>
    /// <seealso cref="NextSecond"/>
    /// <seealso cref="PrevSecond"/>
    {$Endregion}
    Class Procedure DecSecond(Var DateTime : TDateTime; NumberOfSeconds : Integer = 1); Overload; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Decrements a <see cref="TTime"/> value by a specified number of seconds.
    /// </summary>
    /// <param name="Time">
    /// The <see cref="TTime"/> value.
    /// </param>
    /// <param name="NumberOfSeconds">
    /// The number of seconds.
    /// </param>
    /// <seealso cref="IncSecond"/>
    /// <seealso cref="NextSecond"/>
    /// <seealso cref="PrevSecond"/>
    {$Endregion}
    Class Procedure DecSecond(Var Time : TTime; NumberOfSeconds : Integer = 1); Overload; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Decrements a <see cref="TDateTime"/> value by a specified number of milliseconds.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="NumberOfMilliseconds">
    /// The number of milliseconds.
    /// </param>
    /// <seealso cref="IncMillisecond"/>
    /// <seealso cref="NextMillisecond"/>
    /// <seealso cref="PrevMillisecond"/>
    {$Endregion}
    Class Procedure DecMillisecond(Var DateTime : TDateTime; NumberOfMilliseconds : Integer = 1); Overload; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Decrements a <see cref="TTime"/> value by a specified number of milliseconds.
    /// </summary>
    /// <param name="Time">
    /// The <see cref="TTime"/> value.
    /// </param>
    /// <param name="NumberOfMilliseconds">
    /// The number of milliseconds.
    /// </param>
    /// <seealso cref="IncMillisecond"/>
    /// <seealso cref="NextMillisecond"/>
    /// <seealso cref="PrevMillisecond"/>
    {$Endregion}
    Class Procedure DecMillisecond(Var Time : TTime; NumberOfMilliseconds : Integer = 1); Overload; Static; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Decrements a <see cref="TDateTime"/> value by a specified number of days
    /// including fraction of a day.
    /// </summary>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <param name="Delta">
    /// The number of days including fraction of a day.
    /// </param>
    /// <seealso cref="IncDateTime"/>
    {$Endregion}
    Class Procedure DecDateTime(Var DateTime : TDateTime; Const Delta : Double); Static; Inline;
    { String Conversion Functions }
    {$Region 'xmldoc'}
    /// <summary>
    /// Formats a <see cref="TDateTime"/> value.
    /// </summary>
    /// <remarks>
    /// <para>
    /// The Format method formats the <see cref="TDateTime"/> value given by
    /// <paramref name="DateTime"/> using the format string given by <paramref name="FmtStr"/>.
    /// </para>
    /// <para>
    /// The format string controls the formatting of date and time, and is composed from
    /// specifiers that represent values to insert into the formatted string. Some
    /// specifiers (such as "d"), simply format numbers or strings. Other specifiers
    /// (such as "/") refer to the locale-specific strings from <see cref="Settings"/>
    /// property.
    /// </para>
    /// <para>
    /// In the following table, specifiers are given in lower case. Case is ignored in
    /// formats, except for the "am/pm" and "a/p" specifiers.
    /// </para>
    /// <list type="table">
    ///   <listheader>
    ///     <term>Specifier</term>
    ///     <description>Meaning</description>
    ///   </listheader>
    ///   <item>
    ///     <term>c</term>
    ///     <description>
    ///     The date using the format given by the <see cref="Settings.ShortDateFormat"/>
    ///     property, followed by the time using the format given by the
    ///     <see cref="Settings.LongTimeFormat"/> property. The time is not displayed
    ///     if the date-time value indicates midnight precisely.
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <term>q</term>
    ///     <description>
    ///     The date and time using '<c>yyyy-mm-dd hh:nn:ss</c>' format.
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <term>u</term>
    ///     <description>
    ///     The date and time using '<c>yyyy-mm-dd hh:nn:ss</c>' format in universal
    ///     time coordinate.
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <term>g</term>
    ///     <description>
    ///     The period/era as an abbreviation.
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <term>gg</term>
    ///     <description>
    ///     The period/era as a full name.
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <term>yy</term>
    ///     <description>
    ///     The year as a two-digit number.
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <term>yyyy</term>
    ///     <description>
    ///     The year as a four-digit number.
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <term>m</term>
    ///     <description>
    ///     The month as a number without a leading zero. If the <c>m</c> specifier
    ///     immediately follows an <c>h</c> or <c>hh</c> specifier, the minute rather
    ///     than the month is displayed.
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <term>mm</term>
    ///     <description>
    ///     The month as a tw-digit number with a leading zero. If the <c>mm</c>
    ///     specifier immediately follows an <c>h</c> or <c>hh</c>  specifier, the
    ///     minute rather than the month is displayed.
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <term>mmm</term>
    ///     <description>
    ///     The month as an abbreviation using the strings given by the
    ///     <see cref="Settings.ShortMonthNames"/> property.
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <term>mmmm</term>
    ///     <description>
    ///     The month as a full name using the strings given by either the
    ///     <see cref="Settings.MonthNames"/> or <see cref="Settings.GenitiveMonthNames"/>
    ///     properties depends on the context.
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <term>d</term>
    ///     <description>
    ///     The day as a number without a leading zero.
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <term>dd</term>
    ///     <description>
    ///     The day as a two-digit number with a leading zero.
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <term>ddd</term>
    ///     <description>
    ///     The day of the week as an abbreviation using the strings given by
    ///     the <see cref="Settings.ShortDayNames"/> property.
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <term>dddd</term>
    ///     <description>
    ///     The day of the week as a full name using the strings given by the
    ///     <see cref="Settings.DayNames"/> property.
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <term>ddddd</term>
    ///     <description>
    ///     The date using the format given by the <see cref="Settings.ShortDateFormat"/>
    ///     property.
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <term>dddddd</term>
    ///     <description>
    ///     The date using the format given by the <see cref="Settings.LongDateFormat"/>
    ///     property.
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <term>i</term>
    ///     <description>
    ///     The day of the year without a leading zero.
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <term>iii</term>
    ///     <description>
    ///     The day of the year with a leading zero.
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <term>rr</term>
    ///     <description>
    ///     The week number year as a two-digit number. This has the same value
    ///     as <c>yy</c> specifier, except that if the week number belongs to the
    ///     previous or next year, that year is used instead.
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <term>rrrr</term>
    ///     <description>
    ///     The week number year as a four-digit number. This has the same
    ///     value as <c>yyyy</c> specifier, except that if the week number belongs
    ///     to the previous or next year, that year is used instead.
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <term>w</term>
    ///     <description>
    ///     The week of the year without a leading zero.
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <term>ww</term>
    ///     <description>
    ///     The week of the year with a leading zero.
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <term>o</term>
    ///     <description>
    ///     The day of the week as a number, where 1 represents the first day
    ///     of the week and 7 represents the last day of the week.
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <term>h</term>
    ///     <description>
    ///     The hour without a leading zero (0-23).
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <term>hh</term>
    ///     <description>
    ///     The hour with a leading zero (00-23).
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <term>n</term>
    ///     <description>
    ///     The minute without a leading zero (0-59).
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <term>nn</term>
    ///     <description>
    ///     The minute with a leading zero (00-59).
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <term>s</term>
    ///     <description>
    ///     The second without a leading zero (0-59).
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <term>ss</term>
    ///     <description>
    ///     The second with a leading zero (00-59).
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <term>z</term>
    ///     <description>
    ///     The millisecond without a leading zero (0-999).
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <term>zzz</term>
    ///     <description>
    ///     The millisecond with a leading zero (000-999).
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <term>t</term>
    ///     <description>
    ///     The time using the format given by the <see cref="Settings.ShortTimeFormat"/>
    ///     property.
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <term>tt</term>
    ///     <description>
    ///     The time using the format given by the <see cref="Settings.LongTimeFormat"/>
    ///     property.
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <term>am/pm</term>
    ///     <description>
    ///     Uses the 12-hour clock for the preceding <c>h</c> or <c>hh</c> specifier,
    ///     and displays 'am' for any hour before noon, and 'pm' for any hour after
    ///     noon. The am/pm specifier can use lower, upper, or mixed case, and the
    ///     result is displayed accordingly.
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <term>a/p</term>
    ///     <description>
    ///     Uses the 12-hour clock for the preceding <c>h</c> or <c>hh</c> specifier,
    ///     and displays 'a' for any hour before noon, and 'p' for any hour after
    ///     noon. The a/p specifier can use lower, upper, or mixed case, and the
    ///     result is displayed accordingly.
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <term>ampm</term>
    ///     <description>
    ///     Uses the 12-hour clock for the preceding <c>h</c> or <c>hh</c> specifier,
    ///     and displays the contents of the <see cref="Settings.TimeAMString"/>
    ///     property for any hour before noon, and the contents of the
    ///     <see cref="Settings.TimePMString"/> property for any hour after noon.
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <term>/</term>
    ///     <description>
    ///     The date separator given by the <see cref="Settings.DateSeparator"/>
    ///     property.
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <term>:</term>
    ///     <description>
    ///     The time separator given by the <see cref="Settings.TimeSeparator"/>
    ///     property.
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <term>'xx'/"xx"</term>
    ///     <description>
    ///     Characters enclosed in single or double quotes are displayed as-is,
    ///     and do not affect formatting.
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <term>{calendar:format}</term>
    ///     <description>
    ///     Formats the same <see cref="TDateTime"/> value using another registered
    ///     calendar system. The calendar name is matched case-insensitively against
    ///     registered calendar names, first as specified and then with ' Calendar'
    ///     appended. The scoped calendar uses the current calendar's locale.
    ///     </description>
    ///   </item>
    ///   <item>
    ///     <term>{calendar,era:format}</term>
    ///     <description>
    ///     Formats the same <see cref="TDateTime"/> value using another registered
    ///     calendar system and the specified numeric era. The era must be valid for
    ///     the scoped calendar.
    ///     </description>
    ///   </item>
    /// </list>
    /// <para>
    /// If the string specified by the <paramref name="FmtStr"/> parameter is empty,
    /// the <see cref="TDateTime"/> value is formatted as if a 'c' format specifier
    /// had been given.
    /// </para>
    /// <para>
    /// If a scoped calendar block is invalid, references an unregistered calendar,
    /// or specifies an invalid era, the opening brace is handled as a normal format
    /// character and parsing continues with the remaining characters. This preserves
    /// compatibility with existing format strings.
    /// </para>
    /// <para>
    /// Scoped blocks may appear in the format pattern of another scoped block.
    /// </para>
    /// </remarks>
    /// <param name="FmtStr">
    /// The format string.
    /// </param>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <returns>
    /// The formatted <see cref="TDateTime"/> value as a string.
    /// </returns>
    /// <seealso cref="Settings"/>
    /// <seealso cref="Parse"/>
    /// <seealso cref="TryParse"/>
    {$Endregion}
    Function Format(Const FmtStr : String; Const DateTime : TDateTime) : String; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts a string to a <see cref="TDateTime"/> value using a specified
    /// format string.
    /// </summary>
    /// <remarks>
    /// <para>
    /// The Parse method scans the string given by <paramref name="DateTimeStr"/>
    /// using the format string given by <paramref name="FmtStr"/> to extract its
    /// date and time values. See <see cref="Format"/> method for more information
    /// about the format string.
    /// </para>
    /// <para>
    /// If the string specified by the <paramref name="FmtStr"/> parameter is empty,
    /// it is assumed to be a 'c' format specifier had been given.
    /// </para>
    /// </remarks>
    /// <param name="FmtStr">
    /// The format string. See <see cref="Format"/> method for details.
    /// </param>
    /// <param name="DateTimeStr">
    /// The date and time value as a string.
    /// </param>
    /// <returns>
    /// The <see cref="TDateTime"/> value.
    /// </returns>
    /// <exception cref="EConvertError">
    /// Occurs when the conversion is failed.
    /// </exception>
    /// <seealso cref="TryParse"/>
    /// <seealso cref="Format"/>
    {$Endregion}
    Function Parse(Const FmtStr : String; Const DateTimeStr : String) : TDateTime; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts a string to a <see cref="TDateTime"/> value using a specified
    /// format string.
    /// </summary>
    /// <remarks>
    /// The TryParse method scans the string given by <paramref name="DateTimeStr"/>
    /// using the format string given by <paramref name="FmtStr"/> to extract its
    /// date and time values. See <see cref="Format"/> method for more information
    /// about the format string.
    /// <para>
    /// If the string specified by the <paramref name="FmtStr"/> parameter is empty,
    /// it is assumed that a 'c' format specifier had been given.
    /// </para>
    /// </remarks>
    /// <param name="FmtStr">
    /// The format string. See <see cref="Format"/> method for details.
    /// </param>
    /// <param name="DateTimeStr">
    /// The date and time value as a string.
    /// </param>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the conversion is succeeded, otherwise
    /// returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="Parse"/>
    /// <seealso cref="Format"/>
    {$Endregion}
    Function TryParse(Const FmtStr : String; Const DateTimeStr : String; Var DateTime : TDateTime) : Boolean;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TCalendarClassList maintains a list of <see cref="TCalendar"/> classes.
/// </summary>
/// <remarks>
/// Use TCalendarClassList to store and maintain a list of <see cref="TCalendar"/>
/// classes. TCalendarClassList provides properties and methods to add, delete,
/// rearrange, locate, access, and sort <see cref="TCalendar"/> classes.
/// </remarks>
{$Endregion}

  TCalendarClassList = Class(TList)
   Private
    Function GetItems(Index : NativeInt) : TCalendarClass; Inline;
    Procedure SetItems(Index : NativeInt; Value : TCalendarClass);
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Retrieves the first <see cref="TCalendar"/> class in the <see cref="Items"/>
    /// array.
    /// </summary>
    /// <returns>
    /// The first item in the list.
    /// </returns>
    /// <seealso cref="Last"/>
    {$Endregion}
    Function First : TCalendarClass; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Retrieves the last <see cref="TCalendar"/> class in the <see cref="Items"/>
    /// array.
    /// </summary>
    /// <returns>
    /// The last item in the list.
    /// </returns>
    /// <seealso cref="First"/>
    {$Endregion}
    Function Last : TCalendarClass; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Inserts the <paramref name="Item"/> parameter at the end of the <see cref="Items"/>
    /// array.
    /// </summary>
    /// <param name="Item">
    /// The <see cref="TCalendar"/> class to add.
    /// </param>
    /// <returns>
    /// The index of the new item.
    /// </returns>
    /// <seealso cref="Insert"/>
    {$Endregion}
    Function Add(Item : TCalendarClass) : Integer; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Inserts the <paramref name="Item"/> parameter in the <see cref="Items"/> array,
    /// at the position specified by <paramref name="Index"/>.
    /// </summary>
    /// <param name="Index">
    /// Position of the item in the <see cref="Items"/> array.
    /// </param>
    /// <param name="Item">
    /// The <see cref="TCalendar"/> class to insert.
    /// </param>
    /// <seealso cref="Add"/>
    {$Endregion}
    Procedure Insert(Index : Integer; Item : TCalendarClass); Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Deletes the first reference to the <paramref name="Item"/> parameter from
    /// the <see cref="Items"/> array.
    /// </summary>
    /// <param name="Item">
    /// The <see cref="TCalendar"/> class to remove.
    /// </param>
    /// <returns>
    /// The index of the removed item, or -1 if the item is not found.
    /// </returns>
    /// <seealso cref="RemoveItem"/>
    {$Endregion}
    Function Remove(Item : TCalendarClass) : Integer; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Deletes the first or last reference to the <paramref name="Item"/> parameter
    /// from the <see cref="Items"/> array.
    /// </summary>
    /// <param name="Item">
    /// The <see cref="TCalendar"/> class to remove.
    /// </param>
    /// <param name="Direction">
    /// The direction of search for locating the item.
    /// </param>
    /// <returns>
    /// The index of the removed item, or -1 if the item is not found.
    /// </returns>
    /// <seealso cref="Remove"/>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Function RemoveItem(Item : TCalendarClass; Direction : TList.TDirection) : Integer;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Deletes the first reference to the <paramref name="Item"/> parameter from
    /// the <see cref="Items"/> array.
    /// </summary>
    /// <param name="Item">
    /// The <see cref="TCalendar"/> class to extract.
    /// </param>
    /// <returns>
    /// The extracted item, or <see langword="nil"/> if the item is not found.
    /// </returns>
    /// <seealso cref="ExtractItem"/>
    {$Endregion}
    Function Extract(Item : TCalendarClass) : TCalendarClass; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Deletes the first or last reference to the <paramref name="Item"/> parameter
    /// from the <see cref="Items"/> array.
    /// </summary>
    /// <param name="Item">
    /// The <see cref="TCalendar"/> class to extract.
    /// </param>
    /// <param name="Direction">
    /// The direction of search for locating the item.
    /// </param>
    /// <returns>
    /// The extracted item, or <see langword="nil"/> if the item is not found.
    /// </returns>
    /// <seealso cref="Extract"/>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Function ExtractItem(Item : TCalendarClass; Direction : TList.TDirection) : TCalendarClass; Inline;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns index of the first reference to the <paramref name="Item"/> parameter
    /// in the <see cref="Items"/> array.
    /// </summary>
    /// <param name="Item">
    /// The <see cref="TCalendar"/> class to locate.
    /// </param>
    /// <returns>
    /// The index of item, or -1 if the item is not found.
    /// </returns>
    /// <seealso cref="IndexOfItem"/>
    {$Endregion}
    Function IndexOf(Item : TCalendarClass) : Integer; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns index of the first or last reference to the <paramref name="Item"/>
    /// parameter in the <see cref="Items"/> array.
    /// </summary>
    /// <param name="Item">
    /// The <see cref="TCalendar"/> class to locate.
    /// </param>
    /// <param name="Direction">
    /// The direction of search for locating the item.
    /// </param>
    /// <returns>
    /// The index of item, or -1 if the item is not found.
    /// </returns>
    /// <seealso cref="IndexOf"/>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Function IndexOfItem(Item : TCalendarClass; Direction : TList.TDirection) : Integer; Inline;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the <see cref="TCalendar"/> classes.
    /// </summary>
    {$Endregion}
    Property Items[Index : NativeInt] : TCalendarClass Read GetItems Write SetItems; Default;
  End;

{$Region 'xmldoc'}
/// <summary>
/// CalendarTypes maintains a list of registered <see cref="TCalendar"/> classes.
/// </summary>
/// <remarks>
/// Use CalendarTypes to register or unregister a <see cref="TCalendar"/> class.
/// Also, CalendarTypes provides properties and methods to locate. and access the
/// registered <see cref="TCalendar"/> classes by their identifier, name, or
/// associated locale names.
/// </remarks>
{$Endregion}

  CalendarTypes = Class
   Private
    Class Var CalendarList : TStringList;
    Class Procedure Cleanup;
   Protected
    Type
    {$Region 'xmldoc'}
    /// <summary>
    /// TCalendarRegInfo associates a <see cref="TCalendar"/> class with a set of locales.
    /// </summary>
    {$Endregion}
    TCalendarRegInfo = Class(TObject)
     Private
      fCalendarClass : TCalendarClass;
      fLocales       : TStringList;
     Public
      {$Region 'xmldoc'}
      /// <summary>
      /// Creates an instance of the class.
      /// </summary>
      /// <param name="ACalendarClass">
      /// The <see cref="TCalendar"/> class that is referenced by the object.
      /// </param>
      {$Endregion}
      Constructor Create(ACalendarClass : TCalendarClass);
      {$Region 'xmldoc'}
      /// <summary>
      /// Destroys the instance and releases its allocated momory.
      /// </summary>
      {$Endregion}
      Destructor Destroy; Override;
      {$Region 'xmldoc'}
      /// <summary>
      /// Links a set of locale names to the <see cref="TCalendar"/> class
      /// referenced by the <see cref="CalendarClass"/> property.
      /// </summary>
      /// <param name="Locales">
      /// The array of locale names.
      /// </param>
      /// <seealso cref="Dissociate"/>
      {$Endregion}
      Procedure Associate(Const Locales : Array Of String);
      {$Region 'xmldoc'}
      /// <summary>
      /// Unlinks a set of locale names from the <see cref="TCalendar"/> class
      /// referenced by the <see cref="CalendarClass"/> property.
      /// </summary>
      /// <param name="Locales">
      /// The array of locale names.
      /// </param>
      /// <seealso cref="Associate"/>
      {$Endregion}
      Procedure Dissociate(Const Locales : Array Of String);
      {$Region 'xmldoc'}
      /// <summary>
      /// Lists the locale names, which are linked to the <see cref="TCalendar"/>
      /// class referenced by the <see cref="CalendarClass"/> property.
      /// </summary>
      {$Endregion}
      Property AssociatedLocales : TStringList Read fLocales;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets the <see cref="TCalendar"/> class referenced by the object.
      /// </summary>
      {$Endregion}
      Property CalendarClass : TCalendarClass Read fCalendarClass;
    End;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Registers a <see cref="TCalendar"/> class for all locales.
    /// </summary>
    /// <param name="CalendarClass">
    /// The <see cref="TCalendar"/> class to register.
    /// </param>
    /// <seealso cref="Unregister"/>
    {$Endregion}
    Class Procedure Register(CalendarClass : TCalendarClass); Overload; Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Registers a <see cref="TCalendar"/> class for a list of specific locales.
    /// </summary>
    /// <param name="CalendarClass">
    /// The <see cref="TCalendar"/> class to register.
    /// </param>
    /// <param name="Locales">
    /// The array of locale names.
    /// </param>
    /// <seealso cref="Unregister"/>
    {$Endregion}
    Class Procedure Register(CalendarClass : TCalendarClass; Const Locales : Array Of String); Overload; Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Unregisters a previously registered <see cref="TCalendar"/> class for all locales.
    /// </summary>
    /// <param name="CalendarClass">
    /// The <see cref="TCalendar"/> class to unregister.
    /// </param>
    /// <seealso cref="Register"/>
    {$Endregion}
    Class Procedure Unregister(CalendarClass : TCalendarClass); Overload; Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Unregisters a previously registered <see cref="TCalendar"/> class, only for
    /// a list of specific locales.
    /// </summary>
    /// <param name="CalendarClass">
    /// The <see cref="TCalendar"/> class to unregister.
    /// </param>
    /// <param name="Locales">
    /// The array of locale names.
    /// </param>
    /// <seealso cref="Register"/>
    {$Endregion}
    Class Procedure Unregister(CalendarClass : TCalendarClass; Const Locales : Array Of String); Overload; Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the minimum <see cref="TDateTime"/> value that is supported by all
    /// registered <see cref="TCalendar"/> classes.
    /// </summary>
    /// <returns>
    /// The smallest <see cref="TDateTime"/> value that is supported by all the
    /// registered <see cref="TCalendar"/> classes.
    /// </returns>
    {$Endregion}
    Class Function MinSupportedDateTime : TDateTime; Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the maximum <see cref="TDateTime"/> value that is supported by all registered
    /// <see cref="TCalendar"/> classes.
    /// </summary>
    /// <returns>
    /// The largest <see cref="TDateTime"/> value that is supported by all the
    /// registered <see cref="TCalendar"/> classes.
    /// </returns>
    {$Endregion}
    Class Function MaxSupportedDateTime : TDateTime; Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the number of registered <see cref="TCalendar"/> classes.
    /// </summary>
    /// <returns>
    /// The number of registered <see cref="TCalendar"/> classes.
    /// </returns>
    {$Endregion}
    Class Function Count : Integer; Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets a registered <see cref="TCalendar"/> classe by its index.
    /// </summary>
    /// <returns>
    /// The <see cref="TCalendar"/> class at the specified index, or <see langword="nil"/>
    /// if the index is out of range.
    /// </returns>
    /// <seealso cref="ByID"/>
    /// <seealso cref="ByName"/>
    /// <seealso cref="ByLocale"/>
    {$Endregion}
    Class Function ByIndex(Index : Integer) : TCalendarClass; Inline; Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets a <see cref="TCalendar"/> class by its unique identifier.
    /// </summary>
    /// <param name="ID">
    /// The unique identifier of the calendar.
    /// </param>
    /// <returns>
    /// The <see cref="TCalendar"/> class with the specified identifier, or
    /// <see langword="nil"/> if the identifier is unknown.
    /// </returns>
    /// <seealso cref="ByIndex"/>
    /// <seealso cref="ByName"/>
    /// <seealso cref="ByLocale"/>
    {$Endregion}
    Class Function ByID(ID : Cardinal) : TCalendarClass; Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets a <see cref="TCalendar"/> class by its unique name.
    /// </summary>
    /// <param name="Name">
    /// The unique name of the calendar.
    /// </param>
    /// <returns>
    /// The <see cref="TCalendar"/> class with the specified name, or <see langword="nil"/>
    /// if the name is unknown.
    /// </returns>
    /// <seealso cref="ByIndex"/>
    /// <seealso cref="ByID"/>
    /// <seealso cref="ByLocale"/>
    {$Endregion}
    Class Function ByName(Const Name : String) : TCalendarClass; Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets a <see cref="TCalendar"/> class by its associated locale name.
    /// </summary>
    /// <param name="Locale">
    /// The locale name.
    /// </param>
    /// <returns>
    /// The <see cref="TCalendar"/> class that is associated with the locale, or
    /// <see langword="nil"/> if no calendar class is associated with the locale.
    /// </returns>
    /// <seealso cref="ByIndex"/>
    /// <seealso cref="ByID"/>
    /// <seealso cref="ByLocale"/>
    {$Endregion}
    Class Function ByLocale(Const Locale : String) : TCalendarClass; Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Collects the list of <see cref="TCalendar"/> classes, which are associated
    /// with a specified locale name.
    /// </summary>
    /// <param name="Locale">
    /// The locale name.
    /// </param>
    /// <param name="CalendarClasses">
    /// The list of matched <see cref="TCalendar"/> classes.
    /// </param>
    {$Endregion}
    Class Procedure GetCalendersOfLocale(Const Locale : String; CalendarClasses : TCalendarClassList); Static;
  End;

Implementation

 Uses
  Math, Types, SysConst, RTLConsts, Windows, i18nWinNLS, i18nCore, i18nUnicode;

 Resourcestring
  SStreamReadError = 'Incompatible calendar settings';
  SInvalidEraError = '%d is not a valid era in %s';
  SInvalidYearError = '%d is not a valid year in %s (Era = %d)';
  SInvalidMonthError = '%d/%d is not a valid year/month in %s (Era = %d)';
  SInvalidDayError = '%d/%d/%d is not a valid year/month/day in %s (Era = %d)';
  SInvalidDayNumError = 'The numeric value of a day of the week (%d) must be in range 1 to 7.';
  SInvalidDateError = 'The Gregorian date (%s) is not supported by %s';
  SInvalidDateDayError = '(%d, %d) is not a valid DateDay pair in %s (Era = %d)';
  SInvalidDateWeekError = '(%d, %d, %d) is not a valid DateWeek triplet in %s (Era = %d)';
  SInvalidConvertEraError = 'Year %d cannot be converted from era %d to era %d in %s';

{ TCalendarSettings }

 Constructor TCalendarSettings.Create;
  Begin
   SetLength(fEraNames, CalendarClass.MaxEra);
   SetLength(fShortEraNames, CalendarClass.MaxEra);
   SetLength(fMonthNames, CalendarClass.MaxMonthsPerYear);
   SetLength(fShortMonthNames, CalendarClass.MaxMonthsPerYear);
   SetLength(fGenitiveMonthNames, CalendarClass.MaxMonthsPerYear);
  End;

 Constructor TCalendarSettings.Create(LocaleID : Cardinal);
  Begin
   Create;
   Prepare(LocaleID);
  End;

 Constructor TCalendarSettings.Create(Const Locale : String);
  Begin
   Create;
   Prepare(Locale);
  End;

 Destructor TCalendarSettings.Destroy;
  Begin
   fEraNames           := Nil;
   fShortEraNames      := Nil;
   fMonthNames         := Nil;
   fShortMonthNames    := Nil;
   fGenitiveMonthNames := Nil;
   Inherited Destroy;
  End;

 Procedure TCalendarSettings.SetCalendarName(Const Value : String);
  Begin
   If CalendarName <> Value Then
    Begin
     fCalendarName := Value;
     DoChange;
    End;
  End;

 Function TCalendarSettings.GetEraCount : Integer;
  Begin
   Result := Length(fEraNames);
  End;

 Function TCalendarSettings.GetEraNames(Era : Integer) : String;
  Begin
   Result := fEraNames[Era - 1];
  End;

 Procedure TCalendarSettings.SetEraNames(Era : Integer; Const Value : String);
  Begin
   If EraNames[Era] <> Value Then
    Begin
     fEraNames[Era - 1] := Value;
     DoChange;
    End;
  End;

 Function TCalendarSettings.GetShortEraNames(Era : Integer) : String;
  Begin
   Result := fShortEraNames[Era - 1];
  End;

 Procedure TCalendarSettings.SetShortEraNames(Era : Integer; Const Value : String);
  Begin
   If ShortEraNames[Era] <> Value Then
    Begin
     fShortEraNames[Era - 1] := Value;
     DoChange;
    End;
  End;

 Function TCalendarSettings.GetMonthCount : Integer;
  Begin
   Result := Length(fMonthNames);
  End;

 Function TCalendarSettings.GetMonthNames(Month : Integer) : String;
  Begin
   Result := fMonthNames[Month - 1];
  End;

 Procedure TCalendarSettings.SetMonthNames(Month : Integer; Const Value : String);
  Begin
   If MonthNames[Month] <> Value Then
    Begin
     fMonthNames[Month - 1] := Value;
     DoChange;
    End;
  End;

 Function TCalendarSettings.GetShortMonthNames(Month : Integer) : String;
  Begin
   Result := fShortMonthNames[Month - 1];
  End;

 Procedure TCalendarSettings.SetShortMonthNames(Month : Integer; Const Value : String);
  Begin
   If ShortMonthNames[Month] <> Value Then
    Begin
     fShortMonthNames[Month - 1] := Value;
     DoChange;
    End;
  End;

 Function TCalendarSettings.GetGenitiveMonthNames(Month : Integer) : String;
  Begin
   Result := fGenitiveMonthNames[Month - 1];
  End;

 Procedure TCalendarSettings.SetGenitiveMonthNames(Month : Integer; Const Value : String);
  Begin
   If GenitiveMonthNames[Month] <> Value Then
    Begin
     fGenitiveMonthNames[Month - 1] := Value;
     DoChange;
    End;
  End;

 Function TCalendarSettings.GetDayNames(DoW : TDayOfWeek) : String;
  Begin
   Result := fDayNames[DoW];
  End;

 Procedure TCalendarSettings.SetDayNames(DoW : TDayOfWeek; Const Value : String);
  Begin
   If DayNames[DoW] <> Value Then
    Begin
     fDayNames[DoW] := Value;
     DoChange;
    End;
  End;

 Function TCalendarSettings.GetShortDayNames(DoW : TDayOfWeek) : String;
  Begin
   Result := fShortDayNames[DoW];
  End;

 Procedure TCalendarSettings.SetShortDayNames(DoW : TDayOfWeek; Const Value : String);
  Begin
   If ShortDayNames[DoW] <> Value Then
    Begin
     fShortDayNames[DoW] := Value;
     DoChange;
    End;
  End;

 Function TCalendarSettings.GetShortestDayNames(DoW : TDayOfWeek) : String;
  Begin
   Result := fShortestDayNames[DoW];
  End;

 Procedure TCalendarSettings.SetShortestDayNames(DoW : TDayOfWeek; Const Value : String);
  Begin
   If ShortestDayNames[DoW] <> Value Then
    Begin
     fShortestDayNames[DoW] := Value;
     DoChange;
    End;
  End;

 Procedure TCalendarSettings.SetLongDateFormat(Const Value : String);
  Begin
   If LongDateFormat <> Value Then
    Begin
     fLongDateFormat := Value;
     DoChange;
    End;
  End;

 Procedure TCalendarSettings.SetShortDateFormat(Const Value : String);
  Begin
   If ShortDateFormat <> Value Then
    Begin
     fShortDateFormat := Value;
     DoChange;
    End;
  End;

 Procedure TCalendarSettings.SetYearMonthFormat(Const Value : String);
  Begin
   If YearMonthFormat <> Value Then
    Begin
     fYearMonthFormat := Value;
     DoChange;
    End;
  End;

 Procedure TCalendarSettings.SetMonthDayFormat(Const Value : String);
  Begin
   If MonthDayFormat <> Value Then
    Begin
     fMonthDayFormat := Value;
     DoChange;
    End;
  End;

 Procedure TCalendarSettings.SetYearFormat(Const Value : String);
  Begin
   If YearFormat <> Value Then
    Begin
     fYearFormat := Value;
     DoChange;
    End;
  End;

 Procedure TCalendarSettings.SetTwoDigitYearMax(Value : Word);
  Begin
   If TwoDigitYearMax <> Value Then
    Begin
     fTwoDigitYearMax := Value;
     DoChange;
    End;
  End;

 Procedure TCalendarSettings.SetWeekRule(Value : TWeekRule);
  Begin
   If WeekRule <> Value Then
    Begin
     fWeekRule := Value;
     DoChange;
    End;
  End;

 Procedure TCalendarSettings.SetFirstDayOfWeek(Value : TDayOfWeek);
  Begin
   If FirstDayOfWeek <> Value Then
    Begin
     fFirstDayOfWeek := Value;
     DoChange;
    End;
  End;

 Procedure TCalendarSettings.SetDateSeparator(Const Value : String);
  Begin
   If DateSeparator <> Value Then
    Begin
     fDateSeparator := Value;
     DoChange;
    End;
  End;

 Procedure TCalendarSettings.SetTimeSeparator(Const Value : String);
  Begin
   If TimeSeparator <> Value Then
    Begin
     fTimeSeparator := Value;
     DoChange;
    End;
  End;

 Procedure TCalendarSettings.SetTimeAMString(Const Value : String);
  Begin
   If TimeAMString <> Value Then
    Begin
     fTimeAMString := Value;
     DoChange;
    End;
  End;

 Procedure TCalendarSettings.SetTimePMString(Const Value : String);
  Begin
   If fTimePMString <> Value Then
    Begin
     fTimePMString := Value;
     DoChange;
    End;
  End;

 Procedure TCalendarSettings.SetShortTimeFormat(Const Value : String);
  Begin
   If ShortTimeFormat <> Value Then
    Begin
     fShortTimeFormat := Value;
     DoChange;
    End;
  End;

 Procedure TCalendarSettings.SetLongTimeFormat(Const Value : String);
  Begin
   If LongTimeFormat <> Value Then
    Begin
     fLongTimeFormat := Value;
     DoChange;
    End;
  End;

 Function TCalendarSettings.ScanNames(Var s : PChar; Names : Array Of String) : Integer;
  Var
   i, Len, MaxMatchedLen : Integer;
  Begin
   Result        := 0;
   MaxMatchedLen := 0;
   For i         := Low(Names) To High(Names) Do
    Begin
     Len := Length(Names[i]);
     If (AnsiStrLIComp(s, PChar(Names[i]), Len) = 0) Then
      Begin
       If Len > MaxMatchedLen Then
        Begin
         MaxMatchedLen := Len;
         Result        := i + 1;
        End;
      End;
    End;
   Inc(s, MaxMatchedLen);
  End;

 Function TCalendarSettings.ScanEraNames(Var s : PChar) : Integer;
  Begin
   Result := ScanNames(s, fEraNames);
  End;

 Function TCalendarSettings.ScanShortEraNames(Var s : PChar) : Integer;
  Begin
   Result := ScanNames(s, fShortEraNames);
  End;

 Function TCalendarSettings.ScanMonthNames(Var s : PChar) : Integer;
  Begin
   Result := ScanNames(s, fMonthNames);
  End;

 Function TCalendarSettings.ScanShortMonthNames(Var s : PChar) : Integer;
  Begin
   Result := ScanNames(s, fShortMonthNames);
  End;

 Function TCalendarSettings.ScanGenitiveMonthNames(Var s : PChar) : Integer;
  Begin
   Result := ScanNames(s, fGenitiveMonthNames);
  End;

 Function TCalendarSettings.ScanDayNames(Var s : PChar) : Integer;
  Begin
   Result := ScanNames(s, fDayNames);
  End;

 Function TCalendarSettings.ScanShortDayNames(Var s : PChar) : Integer;
  Begin
   Result := ScanNames(s, fShortDayNames);
  End;

 Function TCalendarSettings.ScanShortestDayNames(Var s : PChar) : Integer;
  Begin
   Result := ScanNames(s, fShortestDayNames);
  End;

 Function TCalendarSettings.ScanAMPM(Var s : PChar) : Integer;
  Begin
   Result := ScanNames(s, [TimeAMString, TimePMString]);
  End;

 Function TCalendarSettings.SafeGetInfoStr(Const Locale : String; CalID : Cardinal; LType, CType : Cardinal; Const Default : String) : String;
  Begin
   If CalID <> 0 Then
    Begin
     Result := GetCalendarStr(Locale, CalID, CType, '');
     If Result <> '' Then
      Exit;
    End;
   Result := GetLocaleStr(Locale, LType, Default);
  End;

 Function TCalendarSettings.GetMonthInfoIndex(Month : Integer) : Integer;
  Begin
   Result := Month - 1;
  End;

 Procedure TCalendarSettings.DoChange;
  Begin
   If fUpdateCount <> 0 Then
    fUpdateAffected := True
   Else If Assigned(OnChange) Then
    OnChange(Self);
  End;

 Procedure TCalendarSettings.Prepare(LocaleID : Cardinal);
  Begin
   Prepare(LCIDToLocaleName(LocaleID));
  End;

 Procedure TCalendarSettings.Prepare(Const Locale : String);
  Begin
   fLocale := Locale;
   BeginUpdate;
   Try
    PrepareSettings(Locale, CalendarClass.CalendarID);
   Finally
    EndUpdate;
   End;
  End;

 Procedure TCalendarSettings.LoadFromStream(Stream : TStream);
  Var
   Reader          : TReader;
   SourceClassName : String;
  Begin
   BeginUpdate;
   Try
    Reader := TReader.Create(Stream, 1024);
    Try
     SourceClassName := Reader.ReadString;
     If Not SameText(SourceClassName, CalendarClass.ClassName) Then
      EStreamError.CreateRes(@SStreamReadError);
     fLocale := Reader.ReadString;
     ReadSettings(Reader);
    Finally
     Reader.Free;
    End;
   Finally
    EndUpdate;
   End;
  End;

 Procedure TCalendarSettings.SaveToStream(Stream : TStream);
  Var
   Writer : TWriter;
  Begin
   Writer := TWriter.Create(Stream, 1024);
   Try
    Writer.WriteString(CalendarClass.ClassName);
    Writer.WriteString(Locale);
    WriteSettings(Writer);
    Writer.FlushBuffer;
   Finally
    Writer.Free;
   End;
  End;

 Procedure TCalendarSettings.BeginUpdate;
  Begin
   If fUpdateCount = 0 Then
    fUpdateAffected := False;
   Inc(fUpdateCount);
  End;

 Procedure TCalendarSettings.EndUpdate;
  Begin
   Dec(fUpdateCount);
   If (fUpdateCount = 0) And fUpdateAffected Then
    DoChange;
  End;

 Procedure TCalendarSettings.Assign(Source : TPersistent);
  Var
   i   : Integer;
   Day : TDayOfWeek;
  Begin
   If (Source Is TCalendarSettings) And
   (CalendarClass = TCalendarSettings(Source).CalendarClass) Then
    Begin
     BeginUpdate;
     Try
      WeekRule        := TCalendarSettings(Source).WeekRule;
      FirstDayOfWeek  := TCalendarSettings(Source).FirstDayOfWeek;
      TwoDigitYearMax := TCalendarSettings(Source).TwoDigitYearMax;
      CalendarName    := TCalendarSettings(Source).CalendarName;
      For i           := 1 To EraCount Do
       Begin
        EraNames[i]      := TCalendarSettings(Source).EraNames[i];
        ShortEraNames[i] := TCalendarSettings(Source).ShortEraNames[i];
       End;
      For i := 1 To MonthCount Do
       Begin
        MonthNames[i]         := TCalendarSettings(Source).MonthNames[i];
        ShortMonthNames[i]    := TCalendarSettings(Source).ShortMonthNames[i];
        GenitiveMonthNames[i] := TCalendarSettings(Source).GenitiveMonthNames[i];
       End;
      For Day := Low(TDayOfWeek) To High(TDayOfWeek) Do
       Begin
        DayNames[Day]         := TCalendarSettings(Source).DayNames[Day];
        ShortDayNames[Day]    := TCalendarSettings(Source).ShortDayNames[Day];
        ShortestDayNames[Day] := TCalendarSettings(Source).ShortestDayNames[Day];
       End;
      LongDateFormat  := TCalendarSettings(Source).LongDateFormat;
      ShortDateFormat := TCalendarSettings(Source).ShortDateFormat;
      YearMonthFormat := TCalendarSettings(Source).YearMonthFormat;
      MonthDayFormat  := TCalendarSettings(Source).MonthDayFormat;
      YearFormat      := TCalendarSettings(Source).YearFormat;
      ShortTimeFormat := TCalendarSettings(Source).ShortTimeFormat;
      LongTimeFormat  := TCalendarSettings(Source).LongTimeFormat;
      DateSeparator   := TCalendarSettings(Source).DateSeparator;
      TimeSeparator   := TCalendarSettings(Source).TimeSeparator;
      TimeAMString    := TCalendarSettings(Source).TimeAMString;
      TimePMString    := TCalendarSettings(Source).TimePMString;
     Finally
      EndUpdate;
     End;
    End
   Else
    Inherited Assign(Source);
  End;

 Procedure TCalendarSettings.PrepareEraName(Era : Integer; Const Locale : String; CalendarID : Cardinal);
  Var
   Temp : String;
  Begin
   Temp := GetCalendarStr(Locale, CalendarID, CAL_SERASTRING, '');
   SetLength(Temp, StrLen(PChar(Temp)));
   EraNames[Era] := Temp;
   Temp          := GetCalendarStr(Locale, CalendarID, CAL_SABBREVERASTRING, '');
   SetLength(Temp, StrLen(PChar(Temp)));
   ShortEraNames[Era] := Temp;
  End;

 Procedure TCalendarSettings.PrepareMonthNames(Const Locale : String; CalendarID : Cardinal);
  Var
   m, i : Integer;
  Begin
   For m := 1 To MonthCount Do
    Begin
     i             := GetMonthInfoIndex(m);
     MonthNames[m] := SafeGetInfoStr(Locale, CalendarID,
     LOCALE_SMONTHNAME1 + i, CAL_SMONTHNAME1 + i, '');
     ShortMonthNames[m] := SafeGetInfoStr(Locale, CalendarID,
     LOCALE_SABBREVMONTHNAME1 + i, CAL_SABBREVMONTHNAME1 + i, '');
     GenitiveMonthNames[m] := SafeGetInfoStr(Locale, CalendarID,
     LOCALE_RETURN_GENITIVE_NAMES Or CAL_SMONTHNAME1 + i,
     CAL_RETURN_GENITIVE_NAMES Or CAL_SMONTHNAME1 + i, MonthNames[m]);
    End;
  End;

 Procedure TCalendarSettings.PrepareDayNames(Const Locale : String; CalendarID : Cardinal);
  Var
   Day : TDayOfWeek;
   i   : Integer;
  Begin
   For Day := Low(TDayOfWeek) To High(TDayOfWeek) Do
    Begin
     i             := Ord(Day) - Ord(Monday);
     DayNames[Day] := SafeGetInfoStr(Locale, CalendarID,
     LOCALE_SDAYNAME1 + i, CAL_SDAYNAME1 + i, '');
     ShortDayNames[Day] := SafeGetInfoStr(Locale, CalendarID,
     LOCALE_SABBREVDAYNAME1 + i, CAL_SABBREVDAYNAME1 + i, '');
     ShortestDayNames[Day] := SafeGetInfoStr(Locale, CalendarID,
     LOCALE_SSHORTESTDAYNAME1 + i, CAL_SSHORTESTDAYNAME1 + i, ShortDayNames[Day]);
    End;
  End;

 Procedure TCalendarSettings.PrepareDateFormats(Const Locale : String; CalendarID : Cardinal);
  Const
   ArabicComma = #$60C;
  Var
   TranslateComma : Boolean;
   Format         : String;
  Begin
   TranslateComma := (Pos('Arab;', GetLocaleScripts(Locale)) <> 0);
   Format         := SafeGetInfoStr(Locale, CalendarID,
   LOCALE_SLONGDATE, CAL_SLONGDATE, 'dddd, MMMM d, y');
   If TranslateComma Then
    LongDateFormat := StringReplace(Format, ',', ArabicComma, [rfReplaceAll])
   Else
    LongDateFormat := Format;
   Format          := SafeGetInfoStr(Locale, CalendarID,
   LOCALE_SSHORTDATE, CAL_SSHORTDATE, 'dd/MM/yyyy');
   If TranslateComma Then
    ShortDateFormat := StringReplace(Format, ',', ArabicComma, [rfReplaceAll])
   Else
    ShortDateFormat := Format;
   Format           := SafeGetInfoStr(Locale, CalendarID,
   LOCALE_SYEARMONTH, CAL_SYEARMONTH, 'MMMM, y');
   If TranslateComma Then
    YearMonthFormat := StringReplace(Format, ',', ArabicComma, [rfReplaceAll])
   Else
    YearMonthFormat := Format;
   Format           := SafeGetInfoStr(Locale, CalendarID,
   LOCALE_SMONTHDAY, CAL_SMONTHDAY, 'd MMMM');
   If TranslateComma Then
    MonthDayFormat := StringReplace(Format, ',', ArabicComma, [rfReplaceAll])
   Else
    MonthDayFormat := Format;
   YearFormat      := 'y';
  End;

 Procedure TCalendarSettings.PrepareTimeFormats(Const Locale : String);
  Var
   TimePrefix, TimePostfix : String;
   HourFmt                 : String;
  Begin
   TimePrefix  := '';
   TimePostfix := '';
   If GetLocaleInt(Locale, LOCALE_ITIME, 0) = 0 Then
    Begin
     If GetLocaleInt(Locale, LOCALE_ITIMEMARKPOSN, 0) = 0 Then
      TimePostfix := ' AMPM'
     Else
      TimePrefix := 'AMPM ';
    End;
   If GetLocaleInt(Locale, LOCALE_ITLZERO, 0) = 0 Then
    HourFmt := 'h'
   Else
    HourFmt        := 'hh';
   DateSeparator   := GetLocaleStr(Locale, LOCALE_SDATE, '/');
   TimeSeparator   := GetLocaleStr(Locale, LOCALE_STIME, ':');
   TimeAMString    := GetLocaleStr(Locale, LOCALE_S1159, 'am');
   TimePMString    := GetLocaleStr(Locale, LOCALE_S2359, 'pm');
   ShortTimeFormat := GetLocaleStr(Locale, LOCALE_SSHORTTIME, TimePrefix + HourFmt + ':nn' + TimePostfix);
   ShortTimeFormat := StringReplace(ShortTimeFormat, 'tt', 'ampm', [rfReplaceAll]);
   LongTimeFormat  := GetLocaleStr(Locale, LOCALE_STIMEFORMAT, TimePrefix + HourFmt + ':nn:ss' + TimePostfix);
   LongTimeFormat  := StringReplace(LongTimeFormat, 'tt', 'ampm', [rfReplaceAll]);
  End;

 Procedure TCalendarSettings.PrepareWeekParams(Const Locale : String);
  Const
   FullWeekLocales : Array[1..2] Of String = ('et-EE', 'ur-PK');
   FirstFourWeekLocales : Array[1..34] Of String = ('de-AT', 'fr-BE', 'nl-BE',
   'cs-CZ', 'da-DK', 'et-EE', 'fo-FO', 'fi-FI', 'sv-FI', 'mk-MK', 'fr-FR',
   'de-DE', 'el-GR', 'is-IS', 'en-IE', 'it-IT', 'lv-LV', 'de-LI', 'de-LU',
   'fr-LU', 'nl-NL', 'nb-NO', 'nn-NO', 'pl-PL', 'pt-PT', 'ca-ES', 'es-ES',
   'es-ES_tradnl', 'eu-ES', 'sv-SE', 'de-CH', 'it-CH', 'fr-CH', 'en-GB');

   Function IsMemberOf(Const Locales : Array Of String) : Boolean;
    Var
     i : Integer;
    Begin
     For i := Low(Locales) To High(Locales) Do
      If SameText(Locale, Locales[i]) Then
       Begin
        Result := True;
        Exit;
       End;
     Result := False;
    End;

  Begin
   FirstDayOfWeek := TDayOfWeek(GetLocaleInt(Locale, LOCALE_IFIRSTDAYOFWEEK, 0) + 1);
   If IsMemberOf(FullWeekLocales) Then
    WeekRule := wrFullWeek
   Else If IsMemberOf(FirstFourWeekLocales) Then
    WeekRule := wrFirstFourDayWeek
   Else
    WeekRule := wrFirstDayWeek;
  End;

 Procedure TCalendarSettings.PrepareSettings(Const Locale : String; CalendarID : Cardinal);
  Var
   Era : Integer;
  Begin
   CalendarName := GetCalendarStr(Locale, CalendarID, CAL_SCALNAME, CalendarClass.CalendarName);
   For Era      := 1 To  EraCount Do
    PrepareEraName(Era, Locale, CalendarID);
   PrepareMonthNames(Locale, CalendarID);
   PrepareDayNames(Locale, CalendarID);
   PrepareDateFormats(Locale, CalendarID);
   PrepareDateFormats(Locale, CalendarID);
   PrepareTimeFormats(Locale);
   PrepareWeekParams(Locale);
   TwoDigitYearMax := GetCalendarInt(Locale, CalendarID, CAL_ITWODIGITYEARMAX, 99);
  End;

 Procedure TCalendarSettings.ReadSettings(Reader : TReader);
  Var
   i   : Integer;
   Day : TDayOfWeek;
  Begin
   WeekRule        := TWeekRule(Reader.ReadInteger);
   FirstDayOfWeek  := TDayOfWeek(Reader.ReadInteger);
   TwoDigitYearMax := Reader.ReadInteger;
   CalendarName    := Reader.ReadString;
   For i           := 1 To EraCount Do
    Begin
     EraNames[i]      := Reader.ReadString;
     ShortEraNames[i] := Reader.ReadString;
    End;
   For i := 1 To MonthCount Do
    Begin
     MonthNames[i]         := Reader.ReadString;
     ShortMonthNames[i]    := Reader.ReadString;
     GenitiveMonthNames[i] := Reader.ReadString;
    End;
   For Day := Low(TDayOfWeek) To High(TDayOfWeek) Do
    Begin
     DayNames[Day]         := Reader.ReadString;
     ShortDayNames[Day]    := Reader.ReadString;
     ShortestDayNames[Day] := Reader.ReadString;
    End;
   LongDateFormat  := Reader.ReadString;
   ShortDateFormat := Reader.ReadString;
   YearMonthFormat := Reader.ReadString;
   MonthDayFormat  := Reader.ReadString;
   YearFormat      := Reader.ReadString;
   ShortTimeFormat := Reader.ReadString;
   LongTimeFormat  := Reader.ReadString;
   DateSeparator   := Reader.ReadString;
   TimeSeparator   := Reader.ReadString;
   TimeAMString    := Reader.ReadString;
   TimePMString    := Reader.ReadString;
  End;

 Procedure TCalendarSettings.WriteSettings(Writer : TWriter);
  Var
   i   : Integer;
   Day : TDayOfWeek;
  Begin
   Writer.WriteInteger(Ord(WeekRule));
   Writer.WriteInteger(Ord(FirstDayOfWeek));
   Writer.WriteInteger(TwoDigitYearMax);
   Writer.WriteString(CalendarName);
   For i := 1 To EraCount Do
    Begin
     Writer.WriteString(EraNames[i]);
     Writer.WriteString(ShortEraNames[i]);
    End;
   For i := 1 To MonthCount Do
    Begin
     Writer.WriteString(MonthNames[i]);
     Writer.WriteString(ShortMonthNames[i]);
     Writer.WriteString(GenitiveMonthNames[i]);
    End;
   For Day := Low(TDayOfWeek) To High(TDayOfWeek) Do
    Begin
     Writer.WriteString(DayNames[Day]);
     Writer.WriteString(ShortDayNames[Day]);
     Writer.WriteString(ShortestDayNames[Day]);
    End;
   Writer.WriteString(LongDateFormat);
   Writer.WriteString(ShortDateFormat);
   Writer.WriteString(YearMonthFormat);
   Writer.WriteString(MonthDayFormat);
   Writer.WriteString(YearFormat);
   Writer.WriteString(ShortTimeFormat);
   Writer.WriteString(LongTimeFormat);
   Writer.WriteString(DateSeparator);
   Writer.WriteString(TimeSeparator);
   Writer.WriteString(TimeAMString);
   Writer.WriteString(TimePMString);
  End;

{ TCalendar }

 Constructor TCalendar.Create;
  Begin
   fSettings          := SettingsClass.Create;
   fSettings.OnChange := SettingsChanged;
   fDefaultEra        := MaxEra;
  End;

 Constructor TCalendar.Create(LocaleID : Integer);
  Begin
   Create;
   Settings.Prepare(LocaleID);
  End;

 Constructor TCalendar.Create(Const Locale : String);
  Begin
   Create;
   Settings.Prepare(Locale);
  End;

 Destructor TCalendar.Destroy;
  Begin
   fSettings.Free;
   Inherited Destroy;
  End;

 Procedure TCalendar.SettingsChanged(Sender : TObject);
  Begin
   DoChange;
  End;

 Procedure TCalendar.Assign(Source : TPersistent);
  Begin
   If Source Is TCalendar Then
    Begin
     DefaultEra := TCalendar(Source).DefaultEra;
     Settings.Assign(TCalendar(Source).Settings);
    End
   Else If Source Is TCalendarSettings Then
    Settings.Assign(Source)
   Else
    Inherited Assign(Source);
  End;

 Procedure TCalendar.AssignTo(Dest : TPersistent);
  Begin
   If Dest Is TCalendar Then
    TCalendar(Dest).Assign(Self)
   Else If Dest Is TCalendarSettings Then
    TCalendarSettings(Dest).Assign(Self.Settings)
   Else
    Inherited AssignTo(Dest);
  End;

 Function TCalendar.Clone : TCalendar;
  Begin
   Result := TCalendarClass(ClassType).Create;
   Result.Assign(Self);
  End;

 Procedure TCalendar.SetSettings(Value : TCalendarSettings);
  Begin
   Settings.Assign(Value);
  End;

 Procedure TCalendar.SetDefaultEra(Value : Integer);
  Begin
   If DefaultEra <> Value Then
    Begin
     If Not IsValidEra(Value) Then
      EraError(Value);
     fDefaultEra := Value;
     DoChange;
    End;
  End;

  Class Function TCalendar.SettingsClass : TCalendarSettingsClass;

Begin
 Result := TCalendarSettings;

End;

 Procedure TCalendar.DoChange;
  Begin
   If Assigned(OnChange) Then
    OnChange(Self);
  End;

  Class Procedure TCalendar.EraError(Era : Integer);

Begin
 Raise EEncodingError.CreateResFmt(@SInvalidEraError,
 [Era, CalendarName]);

End;

  Class Procedure TCalendar.YearError(Era, Year : Integer);

Begin
 Raise EEncodingError.CreateResFmt(@SInvalidYearError,
 [Year, CalendarName, Era]);

End;

  Class Procedure TCalendar.MonthError(Era, Year, Month : Integer);

Begin
 Raise EEncodingError.CreateResFmt(@SInvalidMonthError,
 [Year, Month, CalendarName, Era]);

End;

  Class Procedure TCalendar.DayError(Era, Year, Month, Day : Integer);

Begin
 Raise EEncodingError.CreateResFmt(@SInvalidDayError,
 [Year, Month, Day, CalendarName, Era]);

End;

  Class Procedure TCalendar.DayNumError(DayNum : Integer);

Begin
 Raise EConvertError.CreateResFmt(@SInvalidDayNumError,
 [DayNum]);

End;

  Class Procedure TCalendar.DateError(Const DateTime : TDateTime);

Begin
 Raise EConvertError.CreateResFmt(@SInvalidDateError,
 [DateToStr(DateTime), CalendarName]);

End;

  Class Procedure TCalendar.DateDayError(Era, Year, DayOfYear : Integer);

Begin
 Raise EEncodingError.CreateResFmt(@SInvalidDateDayError,
 [Year, DayOfYear, CalendarName, Era]);

End;

  Class Procedure TCalendar.DateWeekError(Era, Year, Week : Integer; DoW : TDayOfWeek);

Begin
 Raise EEncodingError.CreateResFmt(@SInvalidDateWeekError,
 [Year, Week, Ord(DoW), CalendarName, Era]);

End;

  Class Procedure TCalendar.ConvertEraError(Year, FromEra, ToEra : Integer);

Begin
 Raise EComponentError.CreateResFmt(@SInvalidConvertEraError, [Year, FromEra, ToEra, CalendarName]);

End;

  Class Procedure TCalendar.Divide(Numerator, Denominator : Integer; Out Quotient, Reminder : Integer);

Begin
 Quotient := Floor(Numerator / Denominator);
 Reminder := Numerator - (Denominator * Quotient);

End;

  Class Function TCalendar.Modulus(Numerator, Denominator : Integer) : Integer;

Begin
 Result := Numerator - (Denominator * Floor(Numerator / Denominator));

End;

 Function TCalendar.ToZeroBase(Era, Year : Integer) : Integer;
  Begin
   Result := Year;
   If (Year < 1) And Not CanHaveZeroYear(Era) Then
    Inc(Result)
  End;

 Function TCalendar.FromZeroBase(Era, Year : Integer) : Integer;
  Begin
   Result := Year;
   If (Year < 1) And Not CanHaveZeroYear(Era) Then
    Dec(Result)
  End;

  Class Function TCalendar.CalendarID : Cardinal;

Begin
 Result := 0;

End;

  Class Function TCalendar.CalendarKind : TCalendarKind;

Begin
 Result := ckUnknown;

End;

  Class Function TCalendar.CalendarName : String;

 Var
  i                     : Integer;
  NeedsSpace            : Boolean;
  NeedsCloseParenthesis : Boolean;

Begin
 Result := String(ClassName);
 Delete(Result, 1, 1);
 NeedsSpace            := False;
 NeedsCloseParenthesis := False;
 i                     := 1;
 While i <= Length(Result) Do
  Begin
   If (Result[i] = '_') And Not NeedsCloseParenthesis Then
    Begin
     Result[i] := ' ';
     Inc(i);
     Insert('(', Result, i);
     NeedsSpace            := False;
     NeedsCloseParenthesis := True;
    End
   Else If Not CharInSet(Result[i], ['A'..'Z', '0'..'9']) Then
    NeedsSpace := True
   Else If NeedsSpace Then
    Begin
     Insert(' ', Result, i);
     Inc(i);
     NeedsSpace := False;
    End;
   Inc(i);
  End;
 If NeedsCloseParenthesis Then
  Insert(')', Result, i);

End;

  Class Function TCalendar.MaxEra : Integer;

Begin
 Result := 1;

End;

  Class Function TCalendar.MaxMonthsPerYear : Integer;

Begin
 Result := 12;

End;

  Class Function TCalendar.MinSupportedDateTime : TDateTime;

Begin
 Result := SysUtils.MinDateTime;

End;

  Class Function TCalendar.MaxSupportedDateTime : TDateTime;

Begin
 Result := SysUtils.MaxDateTime;

End;

  Class Function TCalendar.Today : TDate;

Begin
 Result := SysUtils.Date;

End;

  Class Function TCalendar.Yesterday : TDate;

Begin
 Result := PrevDay(Today);

End;

  Class Function TCalendar.Tomorrow : TDate;

Begin
 Result := NextDay(Today);

End;

  Class Function TCalendar.FirstMonthOfYear : Integer;

Begin
 Result := 1;

End;

 Function TCalendar.DaysToMonth(Era, Year, Month : Integer) : Integer;
  Begin
   If Month <> FirstMonthOfYear Then
    Result := DaysBetween(StartOfMonth(Era, Year, Month), StartOfYear(Era, Year))
   Else
    Result := 0;
  End;

 Function TCalendar.DaysToMonth(Year, Month : Integer) : Integer;
  Begin
   Result := DaysToMonth(DefaultEra, Year, Month);
  End;

 Function TCalendar.DaysToMonth(Const DateTime : TDateTime) : Integer;
  Var
   Era, Year, Month, Day : Integer;
  Begin
   DecodeDate(DateTime, Era, Year, Month, Day);
   Result := DaysToMonth(Era, Year, Month);
  End;

 Function TCalendar.DaysInMonth(Era, Year, Month : Integer) : Integer;
  Begin
   Result := DaysBetween(EndOfMonth(Era, Year, Month), StartOfMonth(Era, Year, Month)) + 1;
  End;

 Function TCalendar.DaysInMonth(Year, Month : Integer) : Integer;
  Begin
   Result := DaysInMonth(DefaultEra, Year, Month);
  End;

 Function TCalendar.DaysInMonth(Const DateTime : TDateTime) : Integer;
  Var
   Era, Year, Month, Day : Integer;
  Begin
   DecodeDate(DateTime, Era, Year, Month, Day);
   Result := DaysInMonth(Era, Year, Month);
  End;

 Function TCalendar.DaysInYear(Era, Year : Integer) : Integer;
  Begin
   Result := DaysBetween(EndOfYear(Era, Year), StartOfYear(Era, Year)) + 1;
  End;

 Function TCalendar.DaysInYear(Year : Integer) : Integer;
  Begin
   Result := DaysInYear(DefaultEra, Year);
  End;

 Function TCalendar.DaysInYear(Const DateTime : TDateTime) : Integer;
  Var
   Era, Year, Month, Day : Integer;
  Begin
   DecodeDate(DateTime, Era, Year, Month, Day);
   Result := DaysInYear(Era, Year);
  End;

 Function TCalendar.MonthsInYear(Era, Year : Integer) : Integer;
  Begin
   Result := MaxMonthsPerYear;
  End;

 Function TCalendar.MonthsInYear(Year : Integer) : Integer;
  Begin
   Result := MonthsInYear(DefaultEra, Year);
  End;

 Function TCalendar.MonthsInYear(Const DateTime : TDateTime) : Integer;
  Var
   Era, Year, Month, Day : Integer;
  Begin
   DecodeDate(DateTime, Era, Year, Month, Day);
   Result := MonthsInYear(Era, Year);
  End;

 Function TCalendar.WeeksInYear(Era, Year : Integer) : Integer;
  Var
   LastWeekDate : TDate;
  Begin
   LastWeekDate := StartOfWeek(EndOfYear(Era, Year));
   Result       := WeekOfYear(LastWeekDate);
   If Result = 1 Then
    Begin
     DecWeek(LastWeekDate);
     Result := WeekOfYear(LastWeekDate);
    End;
  End;

 Function TCalendar.WeeksInYear(Year : Integer) : Integer;
  Begin
   Result := WeeksInYear(DefaultEra, Year);
  End;

 Function TCalendar.WeeksInYear(Const DateTime : TDateTime) : Integer;
  Var
   Era, Year, Month, Day : Integer;
  Begin
   DecodeDate(DateTime, Era, Year, Month, Day);
   Result := WeeksInYear(Era, Year);
  End;

 Function TCalendar.WeeksInMonth(Era, Year, Month : Integer) : Integer;
  Begin
   Result := ((DaysInMonth(Era, Year, Month) - 1) Div DaysPerWeek) + 1;
  End;

 Function TCalendar.WeeksInMonth(Year, Month : Integer) : Integer;
  Begin
   Result := WeeksInMonth(DefaultEra, Year, Month);
  End;

 Function TCalendar.WeeksInMonth(Const DateTime : TDateTime) : Integer;
  Var
   Era, Year, Month, Day : Integer;
  Begin
   DecodeDate(DateTime, Era, Year, Month, Day);
   Result := WeeksInMonth(Era, Year, Month);
  End;

 Function TCalendar.DayOfYearToDayOfMonth(Era, Year, DayOfYear : Integer; Var Month, Day : Integer) : Boolean;
  Var
   FirstMonth    : Integer;
   MonthsPerYear : Integer;
   DaysPerMonth  : Integer;
  Begin
   FirstMonth    := FirstMonthOfYear;
   Day           := DayOfYear;
   Month         := FirstMonth;
   MonthsPerYear := MonthsInYear(Era, Year);
   DaysPerMonth  := DaysInMonth(Era, Year, Month);
   While Day > DaysPerMonth Do
    Begin
     Dec(Day, DaysPerMonth);
     Inc(Month);
     If Month > MonthsPerYear Then
      Begin
       Month := 1;
       If Month = FirstMonth Then
        Begin
         Result := False;
         Exit;
        End;
      End;
     DaysPerMonth := DaysInMonth(Era, Year, Month);
    End;
   Result := (Day >= 1);
  End;

 Function TCalendar.DayOfYearToDayOfMonth(Year, DayOfYear : Integer; Var Month, Day : Integer) : Boolean;
  Begin
   Result := DayOfYearToDayOfMonth(DefaultEra, Year, DayOfYear, Month, Day);
  End;

 Function TCalendar.DayOfMonthToDayOfYear(Era, Year, Month, Day : Integer; Out DayOfYear : Integer) : Boolean;
  Begin
   If IsValidDay(Era, Year, Month, Day) Then
    Begin
     If Month = FirstMonthOfYear Then
      DayOfYear := Day
     Else
      DayOfYear := DaysToMonth(Era, Year, Month) + Day;
     Result     := True;
    End
   Else
    Result := False;
  End;

 Function TCalendar.DayOfMonthToDayOfYear(Year, Month, Day : Integer; Out DayOfYear : Integer) : Boolean;
  Begin
   Result := DayOfMonthToDayOfYear(DefaultEra, Year, Month, Day, DayOfYear);
  End;

 Function TCalendar.ConvertYear(Year, FromEra, ToEra : Integer) : Integer;
  Begin
   If FromEra <> ToEra Then
    ConvertEraError(Year, FromEra, ToEra);
   If Not IsValidYear(FromEra, Year) Then
    YearError(FromEra, Year);
   Result := Year;
  End;

 Function TCalendar.AdjustJulianDay(Const JD : Extended; Backward : Boolean) : Extended;
  Begin
   Result := JD;
  End;

 Function TCalendar.BaseEra : Integer;
  Begin
   Result := 1;
  End;

 Function TCalendar.BestEraOfBaseEraYear(Year : Integer) : Integer;
  Begin
   Result := DefaultEra;
  End;

 Function TCalendar.ToFourDigitYear(Year : Integer) : Integer;
  Begin
   Result := Year;
   If (Year > 0) And (Year < 100) Then
    Begin
     Inc(Result, 100 * (Settings.TwoDigitYearMax Div 100));
     If Result > Settings.TwoDigitYearMax Then
      Dec(Result, 100);
    End;
  End;

 Function TCalendar.OffsetYear(Year, NumberOfYears, FromEra, ToEra : Integer) : Integer;
  Begin
   // In most calendars the year zero is meaningless and we should take care of it.
   Result := FromZeroBase(ToEra, ToZeroBase(FromEra, Year) + NumberOfYears);
  End;

 Function TCalendar.OffsetYear(Era, Year, NumberOfYears : Integer) : Integer;
  Begin
   Result := OffsetYear(Year, NumberOfYears, Era, Era);
  End;

 Function TCalendar.OffsetYear(Year, NumberOfYears : Integer) : Integer;
  Begin
   Result := OffsetYear(DefaultEra, Year, NumberOfYears);
  End;

  Class Function TCalendar.OffsetDateTime(Const DateTime : TDateTime; Const Delta : Double) : TDateTime;

Begin
 // We should take in account that in TDateTime type
 // 1. The fraction part is always a positive value even when the whole value is negative
 // 2. There is no value in range (-1, 0)
 Result := JulianDayToDateTime(DateTimeToJulianDay(DateTime) + Delta);

End;

  Class Function TCalendar.DaysBetween(DateTime1, DateTime2 : TDateTime) : Integer;

Begin
 Result := Abs(Trunc(DateTime1) - Trunc(DateTime2));

End;

  Class Function TCalendar.DaysOfWeekBetween(DoW1, DoW2 : TDayOfWeek) : Integer;

Begin
 Result := (Ord(DoW1) - Ord(DoW2) + DaysPerWeek) Mod DaysPerWeek;

End;

 Function TCalendar.DayOfWeekToDayNum(DoW : TDayOfWeek) : Integer;
  Begin
   Result := ((DaysPerWeek - Ord(Settings.FirstDayOfWeek) + Ord(DoW)) Mod DaysPerWeek) + 1;
  End;

 Function TCalendar.DayNumToDayOfWeek(DayNum : Integer) : TDayOfWeek;
  Begin
   If DayNum In [1..7] Then
    DayNumError(DayNum);
   Result := TDayOfWeek(((Ord(Settings.FirstDayOfWeek) + DayNum - 2) Mod DaysPerWeek) + 1);
  End;

 Function TCalendar.CanHaveZeroYear(Era : Integer) : Boolean;
  Begin
   Result := False;
  End;

  Class Function TCalendar.IsNoDate(Const DateTime : TDateTime) : Boolean;

Begin
 Result := (DateTime > -1) And (DateTime < 0);

End;

 Function TCalendar.IsValidDate(Const DateTime : TDateTime) : Boolean;
  Begin
   Result := IsInRange(DateTime, MinSupportedDateTime, MaxSupportedDateTime);
  End;

 Function TCalendar.IsValidDateDay(Era, Year, DayOfYear : Integer) : Boolean;
  Begin
   Result := IsValidYear(Era, Year)
   And (DayOfYear >= 1) And (DayOfYear <= DaysInYear(Era, Year));
  End;

 Function TCalendar.IsValidDateDay(Year, DayOfYear : Integer) : Boolean;
  Begin
   Result := IsValidDateDay(DefaultEra, Year);
  End;

 Function TCalendar.IsValidDateWeek(Era, Year, Week : Integer; DoW : TDayOfWeek) : Boolean;
  Begin
   Result := IsValidYear(Era, Year)
   And (Week >= 1) And (Week <= WeeksInYear(Era, Year))
   And (Ord(DoW) In [Ord(Low(TDayOfWeek))..Ord(High(TDayOfWeek))]);
  End;

 Function TCalendar.IsValidDateWeek(Year, Week : Integer; DoW : TDayOfWeek) : Boolean;
  Begin
   Result := IsValidDateWeek(DefaultEra, Year, DoW);
  End;

 Function TCalendar.IsValidEra(Era : Integer) : Boolean;
  Begin
   Result := (Era = DefaultEra) Or ((Era >= 1) And (Era <= MaxEra));
  End;

 Function TCalendar.IsValidYear(Era, Year : Integer) : Boolean;
  Begin
   Result := IsValidEra(Era) And ((Year <> 0) Or CanHaveZeroYear(Era));
  End;

 Function TCalendar.IsValidYear(Year : Integer) : Boolean;
  Begin
   Result := IsValidYear(DefaultEra, Year);
  End;

 Function TCalendar.IsValidMonth(Era, Year, Month : Integer) : Boolean;
  Begin
   Result := IsValidYear(Era, Year)
   And ((Month = FirstMonthOfYear) Or ((Month >= 1) And (Month <= MonthsInYear(Era, Year))));
  End;

 Function TCalendar.IsValidMonth(Year, Month : Integer) : Boolean;
  Begin
   Result := IsValidMonth(DefaultEra, Year, Month);
  End;

 Function TCalendar.IsValidDay(Era, Year, Month, Day : Integer) : Boolean;
  Begin
   Result := IsValidMonth(Era, Year, Month)
   And ((Day = 1) Or ((Day >= 1) And (Day <= DaysInMonth(Era, Year, Month))));
  End;

 Function TCalendar.IsValidDay(Year, Month, Day : Integer) : Boolean;
  Begin
   Result := IsValidDay(DefaultEra, Year, Month)
  End;

 Function TCalendar.IsLeapYear(Era, Year : Integer) : Boolean;
  Begin
   If Not IsValidYear(Era, Year) Then
    YearError(Era, Year);
   Result := False;
  End;

 Function TCalendar.IsLeapYear(Year : Integer) : Boolean;
  Begin
   Result := IsLeapYear(DefaultEra, Year);
  End;

 Function TCalendar.IsInLeapYear(Const DateTime : TDateTime) : Boolean;
  Var
   Era, Year, Month, Day : Integer;
  Begin
   DecodeDate(DateTime, Era, Year, Month, Day);
   Result := IsLeapYear(Era, Year);
  End;

  Class Function TCalendar.IsInRange(Const DateTime, RangeStart, RangeEnd : TDateTime) : Boolean;

Begin
 Result := Not IsNoDate(DateTime)
 And (Compare(DateTime, RangeStart) >= 0) And (Compare(DateTime, RangeEnd) <= 0);

End;

 Function TCalendar.IsThisEra(Const DateTime : TDateTime) : Boolean;
  Begin
   Result := IsSameEra(DateTime, Today);
  End;

 Function TCalendar.IsThisEra(Era : Integer) : Boolean;
  Begin
   Result := (EraOf(Today) = Era);
  End;

 Function TCalendar.IsThisYear(Const DateTime : TDateTime) : Boolean;
  Begin
   Result := IsSameYear(DateTime, Today);
  End;

 Function TCalendar.IsThisYear(Era, Year : Integer) : Boolean;
  Begin
   Result := IsThisYear(ConvertYear(Year, Era, DefaultEra));
  End;

 Function TCalendar.IsThisYear(Year : Integer) : Boolean;
  Begin
   Result := (YearOf(Today) = Year);
  End;

 Function TCalendar.IsThisMonth(Const DateTime : TDateTime) : Boolean;
  Begin
   Result := IsSameMonth(DateTime, Today);
  End;

 Function TCalendar.IsThisMonth(Era, Year, Month : Integer) : Boolean;
  Begin
   Result := IsThisMonth(ConvertYear(Year, Era, DefaultEra), Month);
  End;

 Function TCalendar.IsThisMonth(Year, Month : Integer) : Boolean;
  Var
   TodayYear, TodayMonth, TodayDay : Integer;
  Begin
   DecodeDate(Today, TodayYear, TodayMonth, TodayDay);
   Result := (TodayYear = Year) And (TodayMonth = Month);
  End;

 Function TCalendar.IsThisMonth(Month : Integer) : Boolean;
  Begin
   Result := (MonthOfYear(Today) = Month);
  End;

 Function TCalendar.IsThisWeek(Const DateTime : TDateTime) : Boolean;
  Begin
   Result := IsSameWeek(DateTime, Today);
  End;

  Class Function TCalendar.IsToday(Const DateTime : TDateTime) : Boolean;

Begin
 Result := IsSameDay(DateTime, Today);

End;

  Class Function TCalendar.IsToday(DoW : TDayOfWeek) : Boolean;

Begin
 Result := (DayOfWeek(Today) = DoW);

End;

  Class Function TCalendar.IsPM(Const DateTime : TDateTime) : Boolean;

Begin
 Result := TimeOf(DateTime) >= 0.5;

End;

  Class Function TCalendar.IsSame(Const DateTime1, DateTime2 : TDateTime) : Boolean;

Begin
 Result := (Abs(DateTime1 - DateTime2) < OneMillisecond);

End;

 Function TCalendar.IsSameEra(Const DateTime1, DateTime2 : TDateTime) : Boolean;
  Begin
   Result := (EraOf(DateTime1) = EraOf(DateTime2));
  End;

 Function TCalendar.IsSameYear(Const DateTime1, DateTime2 : TDateTime) : Boolean;
  Var
   Era1, Year1, Month1, Day1 : Integer;
   Era2, Year2, Month2, Day2 : Integer;
  Begin
   DecodeDate(DateTime1, Era1, Year1, Month1, Day1);
   DecodeDate(DateTime2, Era2, Year2, Month2, Day2);
   Result := (Era1 = Era2) And (Year1 = Year2);
  End;

 Function TCalendar.IsSameMonth(Const DateTime1, DateTime2 : TDateTime) : Boolean;
  Var
   Era1, Year1, Month1, Day1 : Integer;
   Era2, Year2, Month2, Day2 : Integer;
  Begin
   DecodeDate(DateTime1, Era1, Year1, Month1, Day1);
   DecodeDate(DateTime2, Era2, Year2, Month2, Day2);
   Result := (Era1 = Era2) And (Year1 = Year2) And (Month1 = Month2);
  End;

 Function TCalendar.IsSameWeek(Const DateTime1, DateTime2 : TDateTime) : Boolean;
  Begin
   Result := IsInRange(DateTime1, StartOfWeek(DateTime2), EndOfWeek(DateTime2));
  End;

  Class Function TCalendar.IsSameDay(Const DateTime1, DateTime2 : TDateTime) : Boolean;

Begin
 Result := (Trunc(DateTime1) = Trunc(DateTime2));

End;

  Class Function TCalendar.Compare(Const DateTime1, DateTime2 : TDateTime) : Integer;

Begin
 If IsSame(DateTime1, DateTime2) Then
  Result := 0
 Else If DateTime1 < DateTime2 Then
  Result := -1
 Else
  Result := +1;

End;

  Class Function TCalendar.CompareDate(Const DateTime1, DateTime2 : TDateTime) : Integer;

Begin
 Result := Compare(DateOf(DateTime1), DateOf(DateTime2));

End;

  Class Function TCalendar.CompareTime(Const DateTime1, DateTime2 : TDateTime) : Integer;

Begin
 Result := Compare(TimeOf(DateTime1), TimeOf(DateTime2));

End;

 Function TCalendar.TryEncodeDateWeek(Era, Year, Week : Integer; DoW : TDayOfWeek; Out DateTime : TDateTime) : Boolean;
  Var
   YearStart : TDateTime;
   DayOfYear : Integer;
   Offset    : Integer;
  Begin
   Result := False;
   If IsValidDateWeek(Era, Year, Week, DoW) Then
    Begin
     YearStart := StartOfYear(Era, Year);
     DayOfYear := ((Week - 1) * DaysPerWeek) + DaysOfWeekBetween(DoW, Settings.FirstDayOfWeek);
     Offset    := DaysOfWeekBetween(DayOfWeek(YearStart), Settings.FirstDayOfWeek);
     Case Settings.WeekRule Of
      wrFirstFourDayWeek :
       If Offset >= 4 Then
        Dec(Offset, DaysPerWeek);
      wrFullWeek :
       If Offset <> 0 Then
        Dec(Offset, DaysPerWeek);
     End;
     DateTime := YearStart + DayOfYear - Offset;
     Result   := True;
    End;
  End;

 Function TCalendar.TryEncodeDateWeek(Year, Week : Integer; DoW : TDayOfWeek; Out DateTime : TDateTime) : Boolean;
  Begin
   Result := TryEncodeDateWeek(DefaultEra, Year, Week, DoW, DateTime);
  End;

 Function TCalendar.EncodeDateWeek(Era, Year, Week : Integer; DoW : TDayOfWeek) : TDateTime;
  Begin
   If Not TryEncodeDateWeek(Era, Year, Week, DoW, Result) Then
    DateWeekError(Era, Year, Week, DoW);
  End;

 Function TCalendar.EncodeDateWeek(Year, Week : Integer; DoW : TDayOfWeek) : TDateTime;
  Begin
   Result := EncodeDateWeek(DefaultEra, Year, Week, DoW);
  End;

 Function TCalendar.TryDecodeDateWeek(Const DateTime : TDateTime; Out Era, Year, Week : Integer; Out DoW : TDayOfWeek) : Boolean;

   Function DoDecode(Const Date : TDateTime) : Boolean;
    Var
     DayOfYear           : Integer;
     FirstOffset, Offset : Integer;
    Begin
     Result := TryDecodeDateDay(Date, Era, Year, DayOfYear);
     If Result Then
      Begin
       FirstOffset := Ord(DayOfWeek(Date)) - ((DayOfYear - 1) Mod DaysPerWeek);
       If Settings.WeekRule = wrFirstDayWeek Then
        Begin
         Offset := (FirstOffset - Ord(Settings.FirstDayOfWeek) + 2 * DaysPerWeek) Mod DaysPerWeek;
         Week   := ((DayOfYear + Offset - 1) Div DaysPerWeek) + 1;
        End
       Else
        Begin
         Offset := (Ord(Settings.FirstDayOfWeek) - FirstOffset + 2 * DaysPerWeek) Mod DaysPerWeek;
         If (Settings.WeekRule = wrFirstFourDayWeek) And (Offset >= 4) Then
          Dec(Offset, DaysPerWeek);
         If DayOfYear > Offset Then
          Week := ((DayOfYear - Offset - 1) Div DaysPerWeek) + 1
         Else
          Result := DoDecode(Date - DayOfYear);
        End;
      End;
    End;

  Begin
   DoW := DayOfWeek(DateTime);
   If (Settings.WeekRule = wrFirstFourDayWeek) And
   (DaysOfWeekBetween(DoW, Settings.FirstDayOfWeek) <= 2)
   Then
    Result := DoDecode(DateTime + 3)
   Else
    Result := DoDecode(DateTime);
  End;

 Function TCalendar.TryDecodeDateWeek(Const DateTime : TDateTime; Out Year, Week : Integer; Out DoW : TDayOfWeek) : Boolean;
  Var
   Era : Integer;
  Begin
   Result := TryDecodeDateWeek(DateTime, Era, Year, Week, DoW);
   If Result And (Era <> DefaultEra) Then
    Year := ConvertYear(Year, Era, DefaultEra);
  End;

 Procedure TCalendar.DecodeDateWeek(Const DateTime : TDateTime; Out Era, Year, Week : Integer; Out DoW : TDayOfWeek);
  Begin
   If Not TryDecodeDateWeek(DateTime, Era, Year, Week, DoW) Then
    DateError(DateTime);
  End;

 Procedure TCalendar.DecodeDateWeek(Const DateTime : TDateTime; Out Year, Week : Integer; Out DoW : TDayOfWeek);
  Begin
   If Not TryDecodeDateWeek(DateTime, Year, Week, DoW) Then
    DateError(DateTime);
  End;

 Function TCalendar.TryEncodeDateDay(Era, Year, DayOfYear : Integer; Out DateTime : TDateTime) : Boolean;
  Begin
   If IsValidDateDay(Era, Year, DayOfYear) Then
    Begin
     DateTime := StartOfYear(Era, Year) + (DayOfYear - 1);
     Result   := True;
    End
   Else
    Result := False;
  End;

 Function TCalendar.TryEncodeDateDay(Year, DayOfYear : Integer; Out DateTime : TDateTime) : Boolean;
  Begin
   Result := TryEncodeDateDay(DefaultEra, Year, DayOfYear, DateTime);
  End;

 Function TCalendar.EncodeDateDay(Era, Year, DayOfYear : Integer) : TDateTime;
  Begin
   If Not TryEncodeDateDay(Era, Year, DayOfYear, Result) Then
    DateDayError(Era, Year, DayOfYear);
  End;

 Function TCalendar.EncodeDateDay(Year, DayOfYear : Integer) : TDateTime;
  Begin
   Result := EncodeDateDay(DefaultEra, Year, DayOfYear);
  End;

 Function TCalendar.TryDecodeDateDay(Const DateTime : TDateTime; Out Era, Year, DayOfYear : Integer) : Boolean;
  Var
   Month, Day : Integer;
  Begin
   Result := TryDecodeDate(DateTime, Era, Year, Month, Day)
   And DayOfMonthToDayOfYear(Era, Year, Month, Day, DayOfYear);
  End;

 Function TCalendar.TryDecodeDateDay(Const DateTime : TDateTime; Out Year, DayOfYear : Integer) : Boolean;
  Var
   Era : Integer;
  Begin
   Result := TryDecodeDateDay(DateTime, Era, Year, DayOfYear);
   If Result And (Era <> DefaultEra) Then
    Year := ConvertYear(Year, Era, DefaultEra);
  End;

 Procedure TCalendar.DecodeDateDay(Const DateTime : TDateTime; Out Era, Year, DayOfYear : Integer);
  Begin
   If Not TryDecodeDateDay(DateTime, Era, Year, DayOfYear) Then
    DateError(DateTime);
  End;

 Procedure TCalendar.DecodeDateDay(Const DateTime : TDateTime; Out Year, DayOfYear : Integer);
  Begin
   If Not TryDecodeDateDay(DateTime, Year, DayOfYear) Then
    DateError(DateTime);
  End;

 Function TCalendar.TryEncodeDate(Era, Year, Month, Day : Integer; Out DateTime : TDateTime) : Boolean;
  Var
   JD : Extended;
  Begin
   Result := False;
   If IsValidDay(Era, Year, Month, Day) Then
    Begin
     Year     := ConvertYear(Year, Era, BaseEra);
     JD       := ToJulianDay(Year, Month, Day);
     JD       := AdjustJulianDay(JD, True);
     DateTime := JulianDayToDateTime(JD);
     Result   := True;
    End;
  End;

 Function TCalendar.TryEncodeDate(Year, Month, Day : Integer; Out DateTime : TDateTime) : Boolean;
  Begin
   Result := TryEncodeDate(DefaultEra, Year, Month, Day, DateTime);
  End;

 Function TCalendar.EncodeDate(Era, Year, Month, Day : Integer) : TDateTime;
  Begin
   If Not TryEncodeDate(Era, Year, Month, Day, Result) Then
    DayError(Era, Year, Month, Day);
  End;

 Function TCalendar.EncodeDate(Year, Month, Day : Integer) : TDateTime;
  Begin
   Result := EncodeDate(DefaultEra, Year, Month, Day);
  End;

 Function TCalendar.TryDecodeDate(Const DateTime : TDateTime; Out Era, Year, Month, Day : Integer) : Boolean;
  Var
   JD : Extended;
  Begin
   JD     := DateTimeToJulianDay(DateTime);
   JD     := AdjustJulianDay(JD, False);
   Result := FromJulianDay(JD, Year, Month, Day);
   If Result Then
    Begin
     Era := BestEraOfBaseEraYear(Year);
     If Era <> BaseEra Then
      Year := ConvertYear(Year, BaseEra, Era);
    End;
  End;

 Function TCalendar.TryDecodeDate(Const DateTime : TDateTime; Out Year, Month, Day : Integer) : Boolean;
  Var
   JD : Extended;
  Begin
   JD     := DateTimeToJulianDay(DateTime);
   JD     := AdjustJulianDay(JD, False);
   Result := FromJulianDay(JD, Year, Month, Day);
   If Result And (DefaultEra <> BaseEra) Then
    Year := ConvertYear(Year, BaseEra, DefaultEra);
  End;

 Procedure TCalendar.DecodeDate(Const DateTime : TDateTime; Out Era, Year, Month, Day : Integer);
  Begin
   If Not TryDecodeDate(DateTime, Era, Year, Month, Day) Then
    DateError(DateTime);
  End;

 Procedure TCalendar.DecodeDate(Const DateTime : TDateTime; Out Year, Month, Day : Integer);
  Begin
   If Not TryDecodeDate(DateTime, Year, Month, Day) Then
    DateError(DateTime);
  End;

  Class Function TCalendar.DateTimeToJulianDay(Const DateTime : TDateTime) : Extended;

Begin
 Result := DateTime + DATETIME_EPOCH;
 // We should take in account that in TDateTime type
 // 1. The fraction part is always a positive value even when the whole value is negative
 // 2. There is no value in range (-1, 0)
 If DateTime < 0 Then
  Result := Result - 2 * Frac(DateTime);

End;

  Class Function TCalendar.JulianDayToDateTime(Const JulianDate : Extended) : TDateTime;

 Var
  f : Double;

Begin
 Result := JulianDate - DATETIME_EPOCH;
 // We should take in account that in TDateTime type
 // 1. The fraction part is always a positive value even when the whole value is negative
 // 2. There is no value in range (-1, 0)
 If Result < 0 Then
  Begin
   f := Frac(Result);
   If f <> 0 Then
    Result := Result - 2 * (f + 1);
  End;

End;

  Class Function TCalendar.CombineDateTime(Const Date : TDate; Const Time : TTime) : TDateTime;

Begin
 If Date < 0 Then
  Result := Date - Time
 Else
  Result := Date + Time;

End;

  Class Function TCalendar.LocalToUniversalDateTime(Const DateTime : TDateTime) : TDateTime;

 Var
  LocalSystemTime, UniversalSystemTime : TSystemTime;
  LocalFileTime, UniversalFileTime     : TFileTime;

Begin
 DateTimeToSystemTime(DateTime, LocalSystemTime);
 SystemTimeToFileTime(LocalSystemTime, LocalFileTime);
 LocalFileTimeToFileTime(LocalFileTime, UniversalFileTime);
 FileTimeToSystemTime(UniversalFileTime, UniversalSystemTime);
 Result := SystemTimeToDateTime(UniversalSystemTime);

End;

  Class Function TCalendar.UniversalToLocalDateTime(Const DateTime : TDateTime) : TDateTime;

 Var
  LocalTime, UniversalTime : TSystemTime;

Begin
 DateTimeToSystemTime(DateTime, UniversalTime);
 SystemTimeToTzSpecificLocalTime(Nil, UniversalTime, LocalTime);
 Result := SystemTimeToDateTime(LocalTime);

End;

  Class Function TCalendar.DateOf(Const DateTime : TDateTime) : TDate;

Begin
 Result := Trunc(DateTime);

End;

 Function TCalendar.EraOf(Const DateTime : TDateTime) : Integer;
  Var
   Year, Month, Day : Integer;
  Begin
   DecodeDate(DateTime, Result, Year, Month, Day);
  End;

 Function TCalendar.YearOf(Const DateTime : TDateTime) : Integer;
  Var
   Month, Day : Integer;
  Begin
   DecodeDate(DateTime, Result, Month, Day);
  End;

 Function TCalendar.MonthOfYear(Const DateTime : TDateTime) : Integer;
  Var
   Year, Day : Integer;
  Begin
   DecodeDate(DateTime, Year, Result, Day);
  End;

 Function TCalendar.WeekOfYear(Const DateTime : TDateTime) : Integer;
  Var
   Year : Integer;
   DoW  : TDayOfWeek;
  Begin
   DecodeDateWeek(DateTime, Year, Result, DoW);
  End;

 Function TCalendar.WeekOfMonth(Const DateTime : TDateTime) : Integer;
  Begin
   Result := ((DayOfMonth(DateTime) - 1) Div DaysPerWeek) + 1;
  End;

 Function TCalendar.DayOfYear(Const DateTime : TDateTime) : Integer;
  Begin
   Result := DaysBetween(DateTime, StartOfYear(DateTime)) + 1;
  End;

 Function TCalendar.DayOfMonth(Const DateTime : TDateTime) : Integer;
  Var
   Year, Month : Integer;
  Begin
   DecodeDate(DateTime, Year, Month, Result);
  End;

  Class Function TCalendar.DayOfWeek(Const DateTime : TDateTime) : TDayOfWeek;

Begin
 Result := TDayOfWeek((Trunc(DateTimeToJulianDay(DateTime) + 0.5) Mod DaysPerWeek) + 1);

End;

  Class Function TCalendar.TimeOf(Const DateTime : TDateTime) : TTime;

Begin
 Result := Abs(Frac(DateTime));

End;

  Class Function TCalendar.HourOfDay(Const DateTime : TDateTime) : Integer;

Begin
 Result := Trunc(TimeOf(DateTime) * HoursPerDay);

End;

  Class Function TCalendar.MinuteOfDay(Const DateTime : TDateTime) : Integer;

Begin
 Result := Trunc(TimeOf(DateTime) * MinsPerDay);

End;

  Class Function TCalendar.MinuteOfHour(Const DateTime : TDateTime) : Integer;

Begin
 Result := MinuteOfDay(DateTime) Mod MinsPerHour;

End;

  Class Function TCalendar.SecondOfDay(Const DateTime : TDateTime) : Integer;

Begin
 Result := Trunc(TimeOf(DateTime) * SecsPerDay);

End;

  Class Function TCalendar.SecondOfMinute(Const DateTime : TDateTime) : Integer;

Begin
 Result := SecondOfDay(DateTime) Mod SecsPerMin;

End;

  Class Function TCalendar.MillisecondOfDay(Const DateTime : TDateTime) : Integer;

Begin
 Result := Trunc(TimeOf(DateTime) * MSecsPerDay);

End;

  Class Function TCalendar.MillisecondOfSecond(Const DateTime : TDateTime) : Integer;

Begin
 Result := MillisecondOfDay(DateTime) Mod MSecsPerSec;

End;

 Function TCalendar.StartOfEra(Era : Integer) : TDateTime;
  Begin
   If Not IsValidEra(Era) Then
    EraError(Era);
   If CanHaveZeroYear(Era) Then
    Result := StartOfYear(Era, 0)
   Else
    Result := StartOfYear(Era, 1);
  End;

 Function TCalendar.StartOfYear(Era, Year : Integer) : TDateTime;
  Begin
   Result := EncodeDate(Era, Year, FirstMonthOfYear, 1);
  End;

 Function TCalendar.StartOfYear(Year : Integer) : TDateTime;
  Begin
   Result := StartOfYear(DefaultEra, Year);
  End;

 Function TCalendar.StartOfYear(Const DateTime : TDateTime) : TDateTime;
  Begin
   Result := StartOfYear(YearOf(DateTime));
  End;

 Function TCalendar.StartOfMonth(Era, Year, Month : Integer) : TDateTime;
  Begin
   Result := EncodeDate(Era, Year, Month, 1);
  End;

 Function TCalendar.StartOfMonth(Year, Month : Integer) : TDateTime;
  Begin
   Result := StartOfMonth(DefaultEra, Year, Month);
  End;

 Function TCalendar.StartOfMonth(Const DateTime : TDateTime) : TDateTime;
  Var
   Year, Month, Day : Integer;
  Begin
   DecodeDate(DateTime, Year, Month, Day);
   Result := DateOf(DateTime) - (Day - 1);
  End;

 Function TCalendar.StartOfWeek(Const DateTime : TDateTime) : TDateTime;
  Begin
   Result := DateOf(DateTime) - DaysOfWeekBetween(DayOfWeek(DateTime), Settings.FirstDayOfWeek);
  End;

  Class Function TCalendar.StartOfDay(Const DateTime : TDateTime) : TDateTime;

Begin
 Result := DateOf(DateTime);

End;

  Class Function TCalendar.StartOfHour(Const DateTime : TDateTime) : TDateTime;

Begin
 Result := Trunc(DateTime / OneHour) * OneHour;

End;

  Class Function TCalendar.StartOfMinute(Const DateTime : TDateTime) : TDateTime;

Begin
 Result := Trunc(DateTime / OneMinute) * OneMinute;

End;

  Class Function TCalendar.StartOfSecond(Const DateTime : TDateTime) : TDateTime;

Begin
 Result := Trunc(DateTime / OneSecond) * OneSecond;

End;

 Function TCalendar.EndOfEra(Era : Integer) : TDateTime;
  Begin
   If Not IsValidEra(Era) Then
    EraError(Era);
   If Era < MaxEra Then
    Result := PrevMillisecond(StartOfEra(Era + 1))
   Else
    Result := MaxSupportedDateTime;
  End;

 Function TCalendar.EndOfYear(Era, Year : Integer) : TDateTime;
  Var
   NextYear : Integer;
  Begin
   NextYear := OffsetYear(Era, Year, +1);
   Result   := PrevMillisecond(StartOfYear(Era, NextYear));
  End;

 Function TCalendar.EndOfYear(Year : Integer) : TDateTime;
  Begin
   Result := EndOfYear(DefaultEra, Year);
  End;

 Function TCalendar.EndOfYear(Const DateTime : TDateTime) : TDateTime;
  Begin
   Result := EndOfYear(YearOf(DateTime));
  End;

 Function TCalendar.EndOfMonth(Era, Year, Month : Integer) : TDateTime;
  Var
   NextMonth : Integer;
  Begin
   NextMonth := (Month Mod MonthsInYear(Era, Year)) + 1;
   If NextMonth = FirstMonthOfYear Then
    Result := EndOfYear(Era, Year)
   Else
    Result := PrevMillisecond(StartOfMonth(Era, Year, NextMonth));
  End;

 Function TCalendar.EndOfMonth(Year, Month : Integer) : TDateTime;
  Begin
   Result := EndOfMonth(DefaultEra, Year, Month);
  End;

 Function TCalendar.EndOfMonth(Const DateTime : TDateTime) : TDateTime;
  Var
   Era, Year, Month, Day : Integer;
  Begin
   DecodeDate(DateTime, Era, Year, Month, Day);
   Result := EndOfMonth(Era, Year, Month);
  End;

 Function TCalendar.EndOfWeek(Const DateTime : TDateTime) : TDateTime;
  Begin
   Result := PrevMillisecond(StartOfWeek(DateTime) + OneWeek);
  End;

  Class Function TCalendar.EndOfDay(Const DateTime : TDateTime) : TDateTime;

Begin
 Result := PrevMillisecond(StartOfDay(DateTime) + OneDay);

End;

  Class Function TCalendar.EndOfHour(Const DateTime : TDateTime) : TDateTime;

Begin
 Result := PrevMillisecond(StartOfHour(DateTime) + OneHour);

End;

  Class Function TCalendar.EndOfMinute(Const DateTime : TDateTime) : TDateTime;

Begin
 Result := PrevMillisecond(StartOfMinute(DateTime) + OneMinute);

End;

  Class Function TCalendar.EndOfSecond(Const DateTime : TDateTime) : TDateTime;

Begin
 Result := PrevMillisecond(StartOfSecond(DateTime) + OneSecond);

End;

 Function TCalendar.PrevYear(Const DateTime : TDateTime; NumberOfYears : Integer) : TDateTime;
  Begin
   Result := NextYear(DateTime, -NumberOfYears);
  End;

 Function TCalendar.PrevMonth(Const DateTime : TDateTime; NumberOfMonths : Integer) : TDateTime;
  Begin
   Result := NextMonth(DateTime, -NumberOfMonths)
  End;

  Class Function TCalendar.PrevWeek(Const DateTime : TDateTime; NumberOfWeeks : Integer) : TDateTime;

Begin
 Result := OffsetDateTime(DateTime, -NumberOfWeeks * OneWeek);

End;

  Class Function TCalendar.PrevDay(Const DateTime : TDateTime; NumberOfDays : Integer) : TDateTime;

Begin
 Result := OffsetDateTime(DateTime, -NumberOfDays * OneDay);

End;

 Function TCalendar.PrevDayOfWeek(Const DateTime : TDateTime; DoW : TDayOfWeek) : TDateTime;
  Var
   Days : Integer;
  Begin
   Days   := DaysPerWeek - DaysOfWeekBetween(DayOfWeek(DateTime), DoW);
   Result := PrevDay(DateTime, Days);
  End;

  Class Function TCalendar.PrevHour(Const DateTime : TDateTime; NumberOfHours : Integer) : TDateTime;

Begin
 Result := OffsetDateTime(DateTime, -NumberOfHours * OneHour);

End;

  Class Function TCalendar.PrevMinute(Const DateTime : TDateTime; NumberOfMinutes : Integer) : TDateTime;

Begin
 Result := OffsetDateTime(DateTime, -NumberOfMinutes * OneMinute);

End;

  Class Function TCalendar.PrevSecond(Const DateTime : TDateTime; NumberOfSeconds : Integer) : TDateTime;

Begin
 Result := OffsetDateTime(DateTime, -NumberOfSeconds * OneSecond);

End;

  Class Function TCalendar.PrevMillisecond(Const DateTime : TDateTime; NumberOfMilliseconds : Integer) : TDateTime;

Begin
 Result := OffsetDateTime(DateTime, -NumberOfMilliseconds * OneMillisecond);

End;

 Function TCalendar.NextYear(Const DateTime : TDateTime; NumberOfYears : Integer) : TDateTime;
  Var
   Era, Year, Month, Day : Integer;
  Begin
   If NumberOfYears = 0 Then
    Begin
     Result := DateTime;
     Exit;
    End;
   DecodeDate(DateTime, Era, Year, Month, Day);
   Year   := OffsetYear(Era, Year, NumberOfYears);
   Month  := Min(Month, MonthsInYear(Era, Year));
   Day    := Min(Day, DaysInMonth(Era, Year, Month));
   Result := CombineDateTime(EncodeDate(Era, Year, Month, Day), Frac(DateTime));
  End;

 Function TCalendar.NextMonth(Const DateTime : TDateTime; NumberOfMonths : Integer) : TDateTime;
  Var
   Era, Year, Month, Day                 : Integer;
   MonthsToStartOfYear, MonthsOfThisYear : Integer;
   FirstMonth                            : Integer;
  Begin
   If NumberOfMonths = 0 Then
    Begin
     Result := DateTime;
     Exit;
    End;
   DecodeDate(DateTime, Era, Year, Month, Day);
   MonthsOfThisYear := MonthsInYear(Era, Year);
   FirstMonth       := FirstMonthOfYear;
   If NumberOfMonths < 0 Then
    Begin
     If Month < FirstMonth Then
      MonthsToStartOfYear := MonthsOfThisYear - (FirstMonth - Month)
     Else
      MonthsToStartOfYear := Month - FirstMonth;
     If - NumberOfMonths > MonthsToStartOfYear Then
      Begin
       Inc(NumberOfMonths, MonthsToStartOfYear);
       Month := FirstMonth;
       Repeat
        Year             := OffsetYear(Era, Year, -1);
        MonthsOfThisYear := MonthsInYear(Era, Year);
        Inc(NumberOfMonths, MonthsOfThisYear);
       Until NumberOfMonths >= 0;
      End;
    End
   Else
    Begin
     If Month >= FirstMonth Then
      MonthsToStartOfYear := MonthsOfThisYear - (Month - FirstMonth)
     Else
      MonthsToStartOfYear := FirstMonth - Month;
     If NumberOfMonths >= MonthsToStartOfYear Then
      Begin
       Month := FirstMonth;
       Repeat
        Dec(NumberOfMonths, MonthsToStartOfYear);
        Year                := OffsetYear(Era, Year, +1);
        MonthsToStartOfYear := MonthsInYear(Era, Year);
       Until NumberOfMonths < MonthsToStartOfYear;
       MonthsOfThisYear := MonthsToStartOfYear;
      End;
    End;
   Month  := ((Month + NumberOfMonths + MonthsOfThisYear - 1) Mod MonthsOfThisYear) + 1;
   Day    := Min(Day, DaysInMonth(Era, Year, Month));
   Result := CombineDateTime(EncodeDate(Era, Year, Month, Day), Frac(DateTime));
  End;

  Class Function TCalendar.NextWeek(Const DateTime : TDateTime; NumberOfWeeks : Integer) : TDateTime;

Begin
 Result := OffsetDateTime(DateTime, NumberOfWeeks * OneWeek);

End;

  Class Function TCalendar.NextDay(Const DateTime : TDateTime; NumberOfDays : Integer) : TDateTime;

Begin
 Result := OffsetDateTime(DateTime, NumberOfDays * OneDay);

End;

 Function TCalendar.NextDayOfWeek(Const DateTime : TDateTime; DoW : TDayOfWeek) : TDateTime;
  Var
   Days : Integer;
  Begin
   Days := DaysOfWeekBetween(DayOfWeek(DateTime), DoW);
   If Days = 0 Then
    Days  := DaysPerWeek;
   Result := NextDay(DateTime, Days);
  End;

  Class Function TCalendar.NextHour(Const DateTime : TDateTime; NumberOfHours : Integer) : TDateTime;

Begin
 Result := OffsetDateTime(DateTime, NumberOfHours * OneHour);

End;

  Class Function TCalendar.NextMinute(Const DateTime : TDateTime; NumberOfMinutes : Integer) : TDateTime;

Begin
 Result := OffsetDateTime(DateTime, NumberOfMinutes * OneDay);

End;

  Class Function TCalendar.NextSecond(Const DateTime : TDateTime; NumberOfSeconds : Integer) : TDateTime;

Begin
 Result := OffsetDateTime(DateTime, NumberOfSeconds * OneSecond);

End;

  Class Function TCalendar.NextMillisecond(Const DateTime : TDateTime; NumberOfMilliseconds : Integer) : TDateTime;

Begin
 Result := OffsetDateTime(DateTime, NumberOfMilliseconds * OneSecond);

End;

 Procedure TCalendar.IncYear(Var DateTime : TDateTime; NumberOfYears : Integer);
  Begin
   DateTime := NextYear(DateTime, NumberOfYears);
  End;

 Procedure TCalendar.IncYear(Var Date : TDate; NumberOfYears : Integer);
  Begin
   IncYear(TDateTime(Date), NumberOfYears);
  End;

 Procedure TCalendar.IncMonth(Var DateTime : TDateTime; NumberOfMonths : Integer);
  Begin
   DateTime := NextMonth(DateTime, NumberOfMonths);
  End;

 Procedure TCalendar.IncMonth(Var Date : TDate; NumberOfMonths : Integer);
  Begin
   IncMonth(TDateTime(Date), NumberOfMonths);
  End;

  Class Procedure TCalendar.IncWeek(Var DateTime : TDateTime; NumberOfWeeks : Integer);

Begin
 IncDateTime(DateTime, NumberOfWeeks * OneWeek);

End;

  Class Procedure TCalendar.IncWeek(Var Date : TDate; NumberOfWeeks : Integer);

Begin
 IncWeek(TDateTime(Date), NumberOfWeeks);

End;

  Class Procedure TCalendar.IncDay(Var DateTime : TDateTime; NumberOfDays : Integer);

Begin
 IncDateTime(DateTime, NumberOfDays * OneDay);

End;

  Class Procedure TCalendar.IncDay(Var Date : TDate; NumberOfDays : Integer);

Begin
 IncDay(TDateTime(Date), NumberOfDays);

End;

  Class Procedure TCalendar.IncHour(Var DateTime : TDateTime; NumberOfHours : Integer);

Begin
 IncDateTime(DateTime, NumberOfHours * OneHour);

End;

  Class Procedure TCalendar.IncHour(Var Time : TTime; NumberOfHours : Integer);

Begin
 IncHour(TDateTime(Time), NumberOfHours);

End;

  Class Procedure TCalendar.IncMinute(Var DateTime : TDateTime; NumberOfMinutes : Integer);

Begin
 IncDateTime(DateTime, NumberOfMinutes * OneMinute);

End;

  Class Procedure TCalendar.IncMinute(Var Time : TTime; NumberOfMinutes : Integer);

Begin
 IncMinute(TDateTime(Time), NumberOfMinutes);

End;

  Class Procedure TCalendar.IncSecond(Var DateTime : TDateTime; NumberOfSeconds : Integer);

Begin
 IncDateTime(DateTime, NumberOfSeconds * OneSecond);

End;

  Class Procedure TCalendar.IncSecond(Var Time : TTime; NumberOfSeconds : Integer);

Begin
 IncSecond(TDateTime(Time), NumberOfSeconds);

End;

  Class Procedure TCalendar.IncMillisecond(Var DateTime : TDateTime; NumberOfMilliseconds : Integer);

Begin
 IncDateTime(DateTime, NumberOfMilliseconds * OneMillisecond);

End;

  Class Procedure TCalendar.IncMillisecond(Var Time : TTime; NumberOfMilliseconds : Integer);

Begin
 IncMillisecond(TDateTime(Time), NumberOfMilliseconds);

End;

  Class Procedure TCalendar.IncDateTime(Var DateTime : TDateTime; Const Delta : Double);

Begin
 DateTime := OffsetDateTime(DateTime, Delta);

End;

 Procedure TCalendar.DecYear(Var DateTime : TDateTime; NumberOfYears : Integer);
  Begin
   DateTime := PrevYear(DateTime, NumberOfYears);
  End;

 Procedure TCalendar.DecYear(Var Date : TDate; NumberOfYears : Integer);
  Begin
   DecYear(TDateTime(Date), NumberOfYears);
  End;

 Procedure TCalendar.DecMonth(Var DateTime : TDateTime; NumberOfMonths : Integer);
  Begin
   DateTime := PrevMonth(DateTime, NumberOfMonths);
  End;

 Procedure TCalendar.DecMonth(Var Date : TDate; NumberOfMonths : Integer);
  Begin
   DecMonth(TDateTime(Date), NumberOfMonths);
  End;

  Class Procedure TCalendar.DecWeek(Var DateTime : TDateTime; NumberOfWeeks : Integer);

Begin
 DecDateTime(DateTime, NumberOfWeeks * OneWeek);

End;

  Class Procedure TCalendar.DecWeek(Var Date : TDate; NumberOfWeeks : Integer);

Begin
 DecWeek(TDateTime(Date), NumberOfWeeks);

End;

  Class Procedure TCalendar.DecDay(Var DateTime : TDateTime; NumberOfDays : Integer);

Begin
 DecDateTime(DateTime, NumberOfDays * OneDay);

End;

  Class Procedure TCalendar.DecDay(Var Date : TDate; NumberOfDays : Integer);

Begin
 DecDay(TDateTime(Date), NumberOfDays);

End;

  Class Procedure TCalendar.DecHour(Var DateTime : TDateTime; NumberOfHours : Integer);

Begin
 DecDateTime(DateTime, NumberOfHours * OneHour);

End;

  Class Procedure TCalendar.DecHour(Var Time : TTime; NumberOfHours : Integer);

Begin
 DecHour(TDateTime(Time), NumberOfHours);

End;

  Class Procedure TCalendar.DecMinute(Var DateTime : TDateTime; NumberOfMinutes : Integer);

Begin
 DecDateTime(DateTime, NumberOfMinutes * OneMinute);

End;

  Class Procedure TCalendar.DecMinute(Var Time : TTime; NumberOfMinutes : Integer);

Begin
 DecMinute(TDateTime(Time), NumberOfMinutes);

End;

  Class Procedure TCalendar.DecSecond(Var DateTime : TDateTime; NumberOfSeconds : Integer);

Begin
 DecDateTime(DateTime, NumberOfSeconds * OneSecond);

End;

  Class Procedure TCalendar.DecSecond(Var Time : TTime; NumberOfSeconds : Integer);

Begin
 DecSecond(TDateTime(Time), NumberOfSeconds);

End;

  Class Procedure TCalendar.DecMillisecond(Var DateTime : TDateTime; NumberOfMilliseconds : Integer);

Begin
 DecDateTime(DateTime, NumberOfMilliseconds * OneMillisecond);

End;

  Class Procedure TCalendar.DecMillisecond(Var Time : TTime; NumberOfMilliseconds : Integer);

Begin
 DecMillisecond(TDateTime(Time), NumberOfMilliseconds);

End;

  Class Procedure TCalendar.DecDateTime(Var DateTime : TDateTime; Const Delta : Double);

Begin
 DateTime := OffsetDateTime(DateTime, -Delta);

End;

 Function TCalendar.Format(Const FmtStr : String; Const DateTime : TDateTime) : String;
  Var
   BufPos, AppendLevel                   : Integer;
   Buffer                                : Array[0..$3FF] Of Char;
   Era, Year, Month, Day                 : Integer;
   Hour, Min, Sec, MSec, h               : Word;
   WeekDecoded, DateDecoded, TimeDecoded : Boolean;
   WeekYear, WeekNum                     : Integer;
   DoW                                   : TDayOfWeek;

   Procedure AppendChars(p : PChar; Count : Integer);
    Var
     n : Integer;
    Begin
     n := (SizeOf(Buffer) Div SizeOf(Char)) - BufPos;
     If n > Count Then
      n := Count;
     If n <> 0 Then
      Begin
       Move(p^, Buffer[BufPos], n * SizeOf(Char));
       Inc(BufPos, n);
      End;
    End;

   Procedure AppendString(Const s : String); Inline;
    Begin
     AppendChars(PChar(s), Length(s));
    End;

   Procedure AppendNumber(Number, Digits : Integer); Inline;
    Begin
     AppendString(SysUtils.Format('%.*d', [Digits, Number]));
    End;

   Procedure AppendFormat(Fmt : PChar; TranslateSeparators : Boolean = False);
    Var
     Starter, Token, LastToken : Char;
     Use12HourClock            : Boolean;
     BetweenQuotes             : Boolean;
     Count                     : Integer;
     p                         : PChar;

     Procedure GetCount;
      Var
       p : PChar;
      Begin
       p := Fmt;
       While Fmt^ = Starter Do
        Inc(Fmt);
       Count := Fmt - p + 1;
      End;

     Procedure GetDateWeek;
      Begin
       If Not WeekDecoded Then
        Begin
         DecodeDateWeek(DateTime, WeekYear, WeekNum, DoW);
         WeekDecoded := True;
        End;
      End;

     Procedure GetDate;
      Begin
       If Not DateDecoded Then
        Begin
         DecodeDate(DateTime, Era, Year, Month, Day);
         DateDecoded := True;
        End;
      End;

     Procedure GetTime;
      Begin
       If Not TimeDecoded Then
        Begin
         DecodeTime(DateTime, Hour, Min, Sec, MSec);
         TimeDecoded := True;
        End;
      End;

     Function TryAppendScopedCalendar(Var Fmt : PChar) : Boolean;
      Var
       BlockStart, BlockEnd, HeaderEnd, p     : PChar;
       Header, Pattern, CalendarName, EraText : String;
       CalendarClass                          : TCalendarClass;
       ScopedCalendar                         : TCalendar;
       ScopedEra, CommaPos, Depth             : Integer;
       Quote                                  : Char;
      Begin
       Result     := False;
       BlockStart := Fmt;
       BlockEnd   := Nil;
       HeaderEnd  := Nil;
       p          := Fmt;
       Depth      := 1;
       Quote      := #0;
       While p^ <> #0 Do
        Begin
         If Quote <> #0 Then
          Begin
           If p^ = Quote Then
            Quote := #0;
          End
         Else
          Case p^Of
           '''', '"' :
            Quote := p^;
           '{' :
            Inc(Depth);
           '}' :
            Begin
             Dec(Depth);
             If Depth = 0 Then
              Begin
               BlockEnd := p;
               Break;
              End;
            End;
           ':' :
            If (Depth = 1) And (HeaderEnd = Nil) Then
             HeaderEnd := p;
          End;
         Inc(p);
        End;
       If (BlockEnd = Nil) Or (HeaderEnd = Nil) Then
        Exit;

       SetString(Header, BlockStart, HeaderEnd - BlockStart);
       SetString(Pattern, HeaderEnd + 1, BlockEnd - HeaderEnd - 1);
       Header   := Trim(Header);
       CommaPos := Pos(',', Header);
       If CommaPos <> 0 Then
        Begin
         CalendarName := Trim(Copy(Header, 1, CommaPos - 1));
         EraText      := Trim(Copy(Header, CommaPos + 1, MaxInt));
         If (EraText = '') Or Not TryStrToInt(EraText, ScopedEra) Then
          Exit;
        End
       Else
        Begin
         CalendarName := Header;
         ScopedEra    := 0;
        End;
       If CalendarName = '' Then
        Exit;

       CalendarClass := CalendarTypes.ByName(CalendarName);
       If CalendarClass = Nil Then
        CalendarClass := CalendarTypes.ByName(CalendarName + ' Calendar');
       If CalendarClass = Nil Then
        Exit;

       ScopedCalendar := CalendarClass.Create(Settings.Locale);
       Try
        If ScopedEra <> 0 Then
         Begin
          If Not ScopedCalendar.IsValidEra(ScopedEra) Then
           Exit;
          ScopedCalendar.DefaultEra := ScopedEra;
         End;
        AppendString(ScopedCalendar.Format(Pattern, DateTime));
       Finally
        ScopedCalendar.Free;
       End;
       Fmt    := BlockEnd + 1;
       Result := True;
      End;

    Begin
     If (Fmt <> Nil) And (AppendLevel < 2) Then
      Begin
       Inc(AppendLevel);
       LastToken      := ' ';
       Use12HourClock := False;
       While Fmt^ <> #0 Do
        Begin
         Starter := Fmt^;
         Inc(Fmt);
         Token := UpCase(Starter);
         If CharInSet(Token, ['A'..'Z']) Then
          Begin
           If (Token = 'M') And (LastToken = 'H') Then
            Token := 'N'
           Else If Token = 'E' Then
            Token    := 'Y';
           LastToken := Token;
          End;
         Case Token Of
          'G' :
           Begin
            GetCount;
            GetDate;
            If Count = 1 Then
             AppendString(Settings.ShortEraNames[Era])
            Else
             AppendString(Settings.EraNames[Era]);
           End;
          'Y' :
           Begin
            GetCount;
            GetDate;
            Case Count Of
             1 : AppendNumber(Year, 1);
             2 : AppendNumber(Year Mod 100, 2);
            Else AppendNumber(Year, 4);
            End;
           End;
          'M' :
           Begin
            GetCount;
            GetDate;
            Case Count Of
             1, 2 :
              AppendNumber(Month, Count);
             3 :
              AppendString(Settings.ShortMonthNames[Month]);
            Else
              If (LastToken = 'Y') Or (LastToken = 'D') Then
               AppendString(Settings.GenitiveMonthNames[Month])
              Else
               AppendString(Settings.MonthNames[Month]);
            End;
           End;
          'D' :
           Begin
            GetCount;
            If Count <= 2 Then
             GetDate;
            Case Count Of
             1, 2 : AppendNumber(Day, Count);
             3    : AppendString(Settings.ShortDayNames[DayOfWeek(DateTime)]);
             4    : AppendString(Settings.DayNames[DayOfWeek(DateTime)]);
             5    : AppendFormat(PChar(Settings.ShortDateFormat));
            Else AppendFormat(PChar(Settings.LongDateFormat));
            End;
           End;
          'I' :
           Begin
            GetCount;
            GetDate;
            AppendNumber(DayOfYear(DateTime), Count);
           End;
          'O' :
           Begin
            GetCount;
            AppendNumber(DayOfWeekToDayNum(DayOfWeek(DateTime)), 1);
           End;
          'W' :
           Begin
            GetCount;
            GetDateWeek;
            AppendNumber(WeekNum, Count)
           End;
          'R' :
           Begin
            GetCount;
            GetDateWeek;
            Case Count Of
             1 : AppendNumber(WeekYear, 1);
             2 : AppendNumber(WeekYear Mod 100, 2);
            Else AppendNumber(WeekYear, 4);
            End;
           End;
          'H' :
           Begin
            GetCount;
            GetTime;
            BetweenQuotes := False;
            p             := Fmt;
            While p^ <> #0 Do
             Begin
              Case p^Of
               'A', 'a' :
                If Not BetweenQuotes Then
                 Begin
                  If ((AnsiStrLIComp(p, 'AM/PM', 5) = 0) Or
                  (AnsiStrLIComp(p, 'A/P', 3) = 0) Or
                  (AnsiStrLIComp(p, 'AMPM', 4) = 0))
                  Then
                   Use12HourClock := True;
                  Break;
                 End;
               'H', 'h' :
                Break;
               '''', '"' :
                BetweenQuotes := Not BetweenQuotes;
              End;
              Inc(p);
             End;
            h := Hour;
            If Use12HourClock Then
             If h = 0 Then
              h := 12
             Else If h > 12 Then
              Dec(h, 12);
            If Count > 2 Then
             Count := 2;
            AppendNumber(h, Count);
           End;
          'N' :
           Begin
            GetCount;
            GetTime;
            If Count > 2 Then
             Count := 2;
            AppendNumber(Min, Count);
           End;
          'S' :
           Begin
            GetCount;
            GetTime;
            If Count > 2 Then
             Count := 2;
            AppendNumber(Sec, Count);
           End;
          'Z' :
           Begin
            GetCount;
            GetTime;
            If Count > 3 Then
             Count := 3;
            AppendNumber(MSec, Count);
           End;
          'A' :
           Begin
            GetTime;
            p := Fmt - 1;
            If AnsiStrLIComp(p, 'AM/PM', 5) = 0 Then
             Begin
              If Hour >= 12 Then
               Inc(p, 3);
              AppendChars(p, 2);
              Inc(Fmt, 4);
              Use12HourClock := True;
             End
            Else If AnsiStrLIComp(p, 'A/P', 3) = 0 Then
             Begin
              If Hour >= 12 Then
               Inc(p, 2);
              AppendChars(p, 1);
              Inc(Fmt, 2);
              Use12HourClock := True;
             End
            Else If AnsiStrLIComp(p, 'AMPM', 4) = 0 Then
             Begin
              If Hour < 12 Then
               AppendString(Settings.TimeAMString)
              Else
               AppendString(Settings.TimePMString);
              Inc(Fmt, 3);
              Use12HourClock := True;
             End
            Else
             AppendChars(@Starter, 1);
           End;
          'C' :
           Begin
            GetCount;
            AppendFormat(PChar(Settings.ShortDateFormat));
            GetTime;
            If (Hour <> 0) Or (Min <> 0) Or (Sec <> 0) Then
             Begin
              AppendChars(' ', 1);
              AppendFormat(PChar(Settings.LongTimeFormat));
             End;
           End;
          'T' :
           Begin
            GetCount;
            If Count = 1 Then
             AppendFormat(PChar(Settings.ShortTimeFormat))
            Else
             AppendFormat(PChar(Settings.LongTimeFormat));
           End;
          'Q' :
           Begin
            GetCount;
            AppendFormat('YYYY-MM-DD HH:NN:SS');
           End;
          'U' :
           Begin
            GetCount;
            AppendString(Format('Q', LocalToUniversalDateTime(DateTime)));
           End;
          '/' :
           Begin
            If TranslateSeparators Then
             AppendString(Settings.DateSeparator)
            Else
             AppendChars(@Starter, 1);
           End;
          ':' :
           Begin
            If TranslateSeparators Then
             AppendString(Settings.TimeSeparator)
            Else
             AppendChars(@Starter, 1);
           End;
          '{' :
           Begin
            If Not TryAppendScopedCalendar(Fmt) Then
             AppendChars(@Starter, 1);
           End;
          '"', '''' :
           Begin
            p := Fmt;
            While (Fmt^ <> #0) And (Fmt^ <> Starter) Do
             Inc(Fmt);
            AppendChars(p, Fmt - p);
            If Fmt^ <> #0 Then
             Inc(Fmt);
           End;
         Else
           AppendChars(@Starter, 1);
         End;
        End;
       Dec(AppendLevel);
      End;
    End;

  Begin
   If IsNoDate(DateTime) Then
    Result := ''
   Else
    Begin
     BufPos      := 0;
     AppendLevel := 0;
     WeekDecoded := False;
     DateDecoded := False;
     TimeDecoded := False;
     If FmtStr <> '' Then
      AppendFormat(PChar(FmtStr), True)
     Else
      AppendFormat('C');
     SetString(Result, Buffer, BufPos);
    End;
  End;

 Function TCalendar.Parse(Const FmtStr : String; Const DateTimeStr : String) : TDateTime;
  Var
   Era, Year, Month, Day                 : Integer;
   Hour, Min, Sec, MSec                  : Word;
   WeekYear, WeekNum, DoW, DoY           : Integer;
   WeekScanned, DateScanned, TimeScanned : Boolean;
   Is12Hours, IsHourPM                   : Boolean;
   IsUTC                                 : Boolean;
   ScanLevel                             : Integer;
   s                                     : PChar;

   Function ScanNumber : Integer;
    Var
     Negate : Boolean;
    Begin
     Result := 0;
     If (s^ = UCC_NODS) Or (s^ = UCC_NADS) Then
      Inc(s);
     Negate := (s^ = '-');
     If Negate Then
      Inc(s);
     While CharInSet(s^, ['0'..'9']) Do
      Begin
       Result := Result * 10 + (Ord(s^) - Ord('0'));
       Inc(s);
      End;
     If Negate Then
      Result := -Result;
    End;

   Function ScanString(Terminator : Char) : String;
    Var
     Start : PChar;
    Begin
     Start := s;
     While (s^ <> #0) And (s^ <> Terminator) Do
      Inc(s);
     SetString(Result, Start, s - Start);
    End;

   Procedure ScanFormat(Fmt : PChar; TranslateSeparators : Boolean = False);
    Var
     Starter, Token, LastToken : Char;
     Count                     : Integer;
     p                         : PChar;

     Procedure GetCount;
      Var
       p : PChar;
      Begin
       p := Fmt;
       While Fmt^ = Starter Do
        Inc(Fmt);
       Count := Fmt - p + 1;
      End;

    Begin
     If (Fmt <> Nil) And (ScanLevel < 2) Then
      Begin
       Inc(ScanLevel);
       LastToken := ' ';
       While (Fmt^ <> #0) And (s^ <> #0) Do
        Begin
         Starter := Fmt^;
         Inc(Fmt);
         Token := UpCase(Starter);
         If CharInSet(Token, ['A'..'Z']) Then
          Begin
           If (Token = 'M') And (LastToken = 'H') Then
            Token := 'N';
           If Token = 'E' Then
            Token    := 'Y';
           LastToken := Token;
          End;
         Case Token Of
          'G' :
           Begin
            GetCount;
            If Count = 1 Then
             Era := Settings.ScanShortEraNames(s)
            Else
             Era := Settings.ScanEraNames(s)
           End;
          'Y' :
           Begin
            GetCount;
            Year := ScanNumber;
            If Count <= 2 Then
             Year       := ToFourDigitYear(Year);
            DateScanned := True;
            If Not WeekScanned Then
             WeekYear := Year;
           End;
          'M' :
           Begin
            GetCount;
            Case Count Of
             1, 2 :
              Month := ScanNumber;
             3 :
              Month := Settings.ScanShortMonthNames(s);
            Else
              Month := Settings.ScanMonthNames(s);
              If Month = 0 Then
               Month := Settings.ScanGenitiveMonthNames(s);
            End;
            DateScanned := True;
           End;
          'D' :
           Begin
            GetCount;
            Case Count Of
             1, 2 :
              Begin
               Day         := ScanNumber;
               DateScanned := True;
              End;
             3 :
              DoW := Settings.ScanShortDayNames(s);
             4 :
              DoW := Settings.ScanDayNames(s);
             5 :
              ScanFormat(PChar(Settings.ShortDateFormat));
            Else
              ScanFormat(PChar(Settings.LongDateFormat));
            End;
           End;
          'I' :
           Begin
            GetCount;
            DoY         := ScanNumber;
            DateScanned := True;
           End;
          'O' :
           Begin
            GetCount;
            DoW         := Ord(DayNumToDayOfWeek(ScanNumber));
            WeekScanned := True;
           End;
          'W' :
           Begin
            GetCount;
            WeekNum     := ScanNumber;
            WeekScanned := True;
           End;
          'R' :
           Begin
            GetCount;
            WeekYear := ScanNumber;
            If Count <= 2 Then
             WeekYear   := ToFourDigitYear(WeekYear);
            WeekScanned := True;
           End;
          'H' :
           Begin
            GetCount;
            Hour        := ScanNumber;
            TimeScanned := True;
           End;
          'N' :
           Begin
            GetCount;
            Min         := ScanNumber;
            TimeScanned := True;
           End;
          'S' :
           Begin
            GetCount;
            Sec         := ScanNumber;
            TimeScanned := True;
           End;
          'Z' :
           Begin
            GetCount;
            MSec        := ScanNumber;
            TimeScanned := True;
           End;
          'A' :
           Begin
            p := Fmt - 1;
            If AnsiStrLIComp(p, 'AM/PM', 5) = 0 Then
             Begin
              Inc(Fmt, 4);
              Is12Hours := True;
              IsHourPM  := (AnsiStrLIComp(s, 'PM', 2) = 0);
              Inc(s, 2);
             End
            Else If AnsiStrLIComp(p, 'A/P', 3) = 0 Then
             Begin
              Inc(Fmt, 2);
              Is12Hours := True;
              IsHourPM  := (AnsiStrLIComp(s, 'P', 1) = 0);
              Inc(s, 1);
             End
            Else If AnsiStrLIComp(p, 'AMPM', 4) = 0 Then
             Begin
              Inc(Fmt, 3);
              Is12Hours := True;
              IsHourPM  := (Settings.ScanAMPM(s) = 2);
             End;
           End;
          'C' :
           Begin
            GetCount;
            ScanFormat(PChar(Settings.ShortDateFormat + ' ' + Settings.LongTimeFormat));
           End;
          'T' :
           Begin
            GetCount;
            If Count = 1 Then
             ScanFormat(PChar(Settings.ShortTimeFormat))
            Else
             ScanFormat(PChar(Settings.LongTimeFormat));
           End;
          'Q', 'U' :
           Begin
            GetCount;
            ScanFormat('YYYY-MM-DD HH:NN:SS');
            IsUTC := (Token = 'U');
           End;
          '/' :
           Begin
            If TranslateSeparators Then
             Begin
              p := PChar(Settings.DateSeparator);
              While (p^ <> #0) And (s^ <> #0) Do
               Begin
                Inc(p);
                Inc(s);
               End;
             End
            Else
             Inc(s);
           End;
          ':' :
           Begin
            If TranslateSeparators Then
             Begin
              p := PChar(Settings.TimeSeparator);
              While (p^ <> #0) And (s^ <> #0) Do
               Begin
                Inc(p);
                Inc(s);
               End;
             End
            Else
             Inc(s);
           End;
          '"', '''' :
           Begin
            While (Fmt^ <> #0) And (Fmt^ <> Starter) And (s^ <> #0) Do
             Begin
              Inc(Fmt);
              Inc(s);
             End;
            If Fmt^ <> #0 Then
             Inc(Fmt);
           End;
         Else
           Inc(s);
         End;
        End;
       Dec(ScanLevel);
      End;
    End;
  Var
   Date : TDate;
   Time : TTime;

  Begin
   Era         := DefaultEra;
   Year        := 0;
   Month       := 0;
   Day         := 0;
   Hour        := 0;
   Min         := 0;
   Sec         := 0;
   MSec        := 0;
   WeekYear    := 0;
   WeekNum     := 0;
   DoW         := 0;
   WeekScanned := False;
   DateScanned := False;
   TimeScanned := False;
   Is12Hours   := False;
   IsHourPM    := False;
   IsUTC       := False;
   s           := PChar(DateTimeStr);
   ScanLevel   := 0;
   If FmtStr <> '' Then
    ScanFormat(PChar(FmtStr), True)
   Else
    ScanFormat('C');
   If TimeScanned Then
    Begin
     If Is12Hours Then
      Begin
       If IsHourPM And (Hour < 12) Then
        Hour := (Hour + 12) Mod 24
       Else If Not IsHourPM And (Hour = 12) Then
        Hour := 0;
      End;
     Time := EncodeTime(Hour, Min, Sec, MSec);
    End
   Else
    Time := 0;
   If DateScanned Then
    Begin
     If (DoY <> 0) And ((Month = 0) Or (Day = 0)) Then
      Date := EncodeDateDay(Era, Year, DoY)
     Else
      Date := EncodeDate(Era, Year, Month, Day);
    End
   Else If WeekScanned Then
    Date := EncodeDateWeek(Era, WeekYear, WeekNum, TDayOfWeek(DoW))
   Else
    Date  := 0;
   Result := CombineDateTime(Date, Time);
   If IsUTC Then
    Result := UniversalToLocalDateTime(Result);
  End;

 Function TCalendar.TryParse(Const FmtStr : String; Const DateTimeStr : String; Var DateTime : TDateTime) : Boolean;
  Begin
   Try
    DateTime := Parse(FmtStr, DateTimeStr);
    Result   := True;
   Except
    Result := False;
   End;
  End;

{ TCalendarClassList }

 Function TCalendarClassList.GetItems(Index : NativeInt) : TCalendarClass;
  Begin
   Result := TCalendarClass(Get(Index));
  End;

 Procedure TCalendarClassList.SetItems(Index : NativeInt; Value : TCalendarClass);
  Begin
   Put(Index, Value);
  End;

 Function TCalendarClassList.First : TCalendarClass;
  Begin
   Result := TCalendarClass(Inherited First);
  End;

 Function TCalendarClassList.Last : TCalendarClass;
  Begin
   Result := TCalendarClass(Inherited Last);
  End;

 Function TCalendarClassList.Add(Item : TCalendarClass) : Integer;
  Begin
   Result := Inherited Add(Item);
  End;

 Procedure TCalendarClassList.Insert(Index : Integer; Item : TCalendarClass);
  Begin
   Inherited Insert(Index, Item);
  End;

 Function TCalendarClassList.Remove(Item : TCalendarClass) : Integer;
  Begin
   Result := Inherited Remove(Item);
  End;

{$IFDEF COMPILER2010_UP}

 Function TCalendarClassList.RemoveItem(Item : TCalendarClass; Direction : TList.TDirection) : Integer;
  Begin
   Result := Inherited RemoveItem(Item, Direction);
  End;
{$ENDIF}

 Function TCalendarClassList.Extract(Item : TCalendarClass) : TCalendarClass;
  Begin
   Result := TCalendarClass(Inherited Extract(Item));
  End;

{$IFDEF COMPILER2010_UP}

 Function TCalendarClassList.ExtractItem(Item : TCalendarClass; Direction : TList.TDirection) : TCalendarClass;
  Begin
   Result := TCalendarClass(Inherited ExtractItem(Item, Direction));
  End;
{$ENDIF}

 Function TCalendarClassList.IndexOf(Item : TCalendarClass) : Integer;
  Begin
   Result := Inherited IndexOf(Item);
  End;

{$IFDEF COMPILER2010_UP}

 Function TCalendarClassList.IndexOfItem(Item : TCalendarClass; Direction : TList.TDirection) : Integer;
  Begin
   Result := Inherited IndexOfItem(Item, Direction);
  End;
{$ENDIF}

{ CalendarTypes }

  Class Procedure CalendarTypes.Cleanup;

Begin
 If Assigned(CalendarList) Then
  FreeAndNil(CalendarList);

End;

  Class Procedure CalendarTypes.Register(CalendarClass : TCalendarClass);

 Var
  Index   : Integer;
  RegInfo : TCalendarRegInfo;

Begin
 If Not Assigned(CalendarList) Then
  Begin
   CalendarList               := TStringList.Create;
   CalendarList.Sorted        := True;
   CalendarList.CaseSensitive := False;
   CalendarList.Duplicates    := dupIgnore;
   CalendarList.OwnsObjects   := True;
  End;
 Index   := CalendarList.Add(CalendarClass.CalendarName);
 RegInfo := TCalendarRegInfo(CalendarList.Objects[Index]);
 If Not Assigned(RegInfo) Then
  Begin
   RegInfo                     := TCalendarRegInfo.Create(CalendarClass);
   CalendarList.Objects[Index] := RegInfo;
  End;

End;

  Class Procedure CalendarTypes.Register(CalendarClass : TCalendarClass; Const Locales : Array Of String);

 Var
  Index : Integer;

Begin
 Register(CalendarClass);
 Index := CalendarList.IndexOf(CalendarClass.CalendarName);
 TCalendarRegInfo(CalendarList.Objects[Index]).Associate(Locales);

End;

  Class Procedure CalendarTypes.Unregister(CalendarClass : TCalendarClass);

 Var
  Index : Integer;

Begin
 If Assigned(CalendarList) Then
  Begin
   Index := CalendarList.IndexOf(CalendarClass.CalendarName);
   If Index >= 0 Then
    CalendarList.Delete(Index);
  End;

End;

  Class Procedure CalendarTypes.Unregister(CalendarClass : TCalendarClass; Const Locales : Array Of String);

 Var
  Index   : Integer;
  RegInfo : TCalendarRegInfo;

Begin
 If Assigned(CalendarList) Then
  Begin
   Index := CalendarList.IndexOf(CalendarClass.CalendarName);
   If Index >= 0 Then
    Begin
     RegInfo := TCalendarRegInfo(CalendarList.Objects[Index]);
     RegInfo.Dissociate(Locales);
    End;
  End;

End;

  Class Function CalendarTypes.MinSupportedDateTime : TDateTime;

 Var
  i             : Integer;
  CalendarClass : TCalendarClass;

Begin
 Result := SysUtils.MinDateTime;
 If Assigned(CalendarList) Then
  For i := CalendarList.Count - 1 Downto 0 Do
   Begin
    CalendarClass := TCalendarRegInfo(CalendarList.Objects[i]).CalendarClass;
    If TCalendar.CompareDate(CalendarClass.MinSupportedDateTime, Result) > 0 Then
     Result := CalendarClass.MinSupportedDateTime;
   End;

End;

  Class Function CalendarTypes.MaxSupportedDateTime : TDateTime;

 Var
  i             : Integer;
  CalendarClass : TCalendarClass;

Begin
 Result := SysUtils.MaxDateTime;
 If Assigned(CalendarList) Then
  For i := CalendarList.Count - 1 Downto 0 Do
   Begin
    CalendarClass := TCalendarRegInfo(CalendarList.Objects[i]).CalendarClass;
    If TCalendar.CompareDate(CalendarClass.MaxSupportedDateTime, Result) < 0 Then
     Result := CalendarClass.MaxSupportedDateTime;
   End;

End;

  Class Function CalendarTypes.Count : Integer;

Begin
 If Assigned(CalendarList) Then
  Result := CalendarList.Count
 Else
  Result := 0;

End;

  Class Function CalendarTypes.ByIndex(Index : Integer) : TCalendarClass;

Begin
 If Assigned(CalendarList) And (Index >= 0) And (Index < CalendarList.Count) Then
  Result := TCalendarRegInfo(CalendarList.Objects[Index]).CalendarClass
 Else
  Result := Nil;

End;

  Class Function CalendarTypes.ByID(ID : Cardinal) : TCalendarClass;

 Var
  i : Integer;

Begin
 If Assigned(CalendarList) Then
  For i := CalendarList.Count - 1 Downto 0 Do
   Begin
    Result := TCalendarRegInfo(CalendarList.Objects[i]).CalendarClass;
    If Result.CalendarID = ID Then
     Exit;
   End;
 Result := Nil;

End;

  Class Function CalendarTypes.ByName(Const Name : String) : TCalendarClass;

 Var
  i : Integer;

Begin
 If Assigned(CalendarList) And CalendarList.Find(Name, i) Then
  Result := TCalendarRegInfo(CalendarList.Objects[i]).CalendarClass
 Else
  Result := Nil;

End;

  Class Function CalendarTypes.ByLocale(Const Locale : String) : TCalendarClass;

 Var
  CalendarID : Cardinal;
  Index, i   : Integer;
  RegInfo    : TCalendarRegInfo;

Begin
 CalendarID := GetLocaleInt(Locale, LOCALE_ICALENDARTYPE, CAL_GREGORIAN);
 Result     := ByID(CalendarID);
 For Index  := 0 To Count - 1 Do
  Begin
   RegInfo := TCalendarRegInfo(CalendarList.Objects[Index]);
   If Assigned(RegInfo.AssociatedLocales) Then
    Begin
     For i := 0 To RegInfo.AssociatedLocales.Count - 1 Do
      If SameLanguage(Locale, RegInfo.AssociatedLocales[i]) Then
       Begin
        Result := RegInfo.CalendarClass;
        If SameText(Locale, RegInfo.AssociatedLocales[i]) Then
         Exit;
       End;
    End;
  End;

End;

  Class Procedure CalendarTypes.GetCalendersOfLocale(Const Locale : String; CalendarClasses : TCalendarClassList);

 Var
  Index, i : Integer;
  RegInfo  : TCalendarRegInfo;

Begin
 For Index := 0 To Count - 1 Do
  Begin
   RegInfo := TCalendarRegInfo(CalendarList.Objects[Index]);
   If Not Assigned(RegInfo.AssociatedLocales) Then
    CalendarClasses.Add(RegInfo.CalendarClass)
   Else
    Begin
     For i := 0 To RegInfo.AssociatedLocales.Count - 1 Do
      If SameLanguage(Locale, RegInfo.AssociatedLocales[i]) Then
       Begin
        CalendarClasses.Add(RegInfo.CalendarClass);
        Break;
       End;
    End;
  End;

End;

{ CalendarTypes.TCalendarRegInfo }

 Constructor CalendarTypes.TCalendarRegInfo.Create(ACalendarClass : TCalendarClass);
  Begin
   fCalendarClass := ACalendarClass;
  End;

 Destructor CalendarTypes.TCalendarRegInfo.Destroy;
  Begin
   If Assigned(fLocales) Then
    fLocales.Free;
   Inherited Destroy;
  End;

 Procedure CalendarTypes.TCalendarRegInfo.Associate(Const Locales : Array Of String);
  Var
   i : Integer;
  Begin
   If Length(Locales) = 0 Then
    Exit;
   If Not Assigned(fLocales) Then
    Begin
     fLocales               := TStringList.Create;
     fLocales.Sorted        := True;
     fLocales.CaseSensitive := False;
     fLocales.Duplicates    := dupIgnore;
    End;
   For i := Low(Locales) To High(Locales) Do
    fLocales.Add(Locales[i]);
  End;

 Procedure CalendarTypes.TCalendarRegInfo.Dissociate(Const Locales : Array Of String);
  Var
   i, Index : Integer;
  Begin
   If Assigned(fLocales) Then
    For i := Low(Locales) To High(Locales) Do
     If fLocales.Find(Locales[i], Index) Then
      fLocales.Delete(Index);
  End;

Initialization

Finalization
 CalendarTypes.Cleanup;

End.
