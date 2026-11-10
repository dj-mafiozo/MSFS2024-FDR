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
/// This unit implements the Jalali (or Persian) calendar.
/// </summary>
Unit i18nCalJalali;

{$I DELPHIAREA.INC}

Interface

 Uses
  SysUtils, i18nCalendar;

 Type

  {$Region 'xmldoc'}
  /// <summary>
  /// This class implements the Jalali (or Persian) calendar.
  /// </summary>
  /// <remarks>
  /// <para>
  /// TJalaliCalendar provides properties and methods to manipulate dates in
  /// the Jalali (or Persian) calendar.
  /// </para>
  /// <para>
  /// The Jalali calendar consists of 12 months: the first six are 31 days,
  /// the next five are 30 days, and the final month is 29 days in a common year
  /// and 30 days in a leap year.
  /// </para>
  /// <para>
  /// In the astronomical definition of the Jalali calendar, each year begins on
  /// Nowruz, determined by the vernal equinox. Leap years do not recur in a fixed
  /// arithmetic pattern; a year is a leap year when 366 days elapse between
  /// consecutive Nowruz days.
  /// </para>
  /// <para>
  /// This implementation uses astronomical calculations to determine Nowruz dates
  /// based on the vernal equinox time in Iran Standard Time.
  /// </para>
  /// <para>
  /// The Jalali calendar supports two eras:
  /// <list type="bullet">
  ///   <item>
  ///     <term>Imperial Era</term>
  ///     <description>
  ///       The era starting with the coronation of Cyrus the Great (year 1 = 559 BCE).
  ///     </description>
  ///   </item>
  ///   <item>
  ///     <term>Hijri Era</term>
  ///     <description>
  ///       The era starting with the Hijra of Prophet Muhammad (year 1 = 622 CE).
  ///     </description>
  ///   </item>
  /// </list>
  /// </remarks>
  {$Endregion}
  TJalaliCalendar = Class(TCalendar)
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// The start of the Jalali calendar in Julian days (Imperial year 1).
    /// </summary>
    {$Endregion}
    Const JALALI_EPOCH = 1517699.5;
    {$Region 'xmldoc'}
    /// <summary>
    /// The year offset between Hijri and Imperial eras in the Jalali calendar.
    /// </summary>
    {$Endregion}
    Const HIJRI_YEAR_OFFSET = 1180;
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts a Jalali date represented by its year, month and day
    /// components to its corresponding Julian day.
    /// </summary>
    /// <param name="Year">
    /// The year.
    /// </param>
    /// <param name="Month">
    /// The month of the year.
    /// </param>
    /// <param name="Day">
    /// The day of the month.
    /// </param>
    /// <returns>
    /// Julian day of the specified Jalali date.
    /// </returns>
    /// <seealso cref="FromJulianDay"/>
    {$Endregion}
    Function ToJulianDay(Year, Month, Day : Integer) : Extended; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts a date expressed in Julian day, to its year, month, and day
    /// components in the Jalali calendar.
    /// </summary>
    /// <param name="JD">
    /// The date expressed in Julian day.
    /// </param>
    /// <param name="Year">
    /// The year.
    /// </param>
    /// <param name="Month">
    /// The month of the year.
    /// </param>
    /// <param name="Day">
    /// The day of the month.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the conversion succeeds, otherwise
    /// returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="ToJulianDay"/>
    {$Endregion}
    Function FromJulianDay(Const JD : Extended; Out Year, Month, Day : Integer) : Boolean; Override;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Specifies the index of the Imperial era.
    /// </summary>
    {$Endregion}
    Const ImperialEra = 1;
    {$Region 'xmldoc'}
    /// <summary>
    /// Specifies the index of the Hijri era.
    /// </summary>
    {$Endregion}
    Const HijriEra = 2;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the number of eras that the calendar class supports.
    /// </summary>
    /// <returns>
    /// Returns 2.
    /// </returns>
    {$Endregion}
    Class Function MaxEra : Integer; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the unique identifier of the calendar.
    /// </summary>
    /// <returns>
    /// Returns <see cref="CAL_PERSIAN"/>.
    /// </returns>
    {$Endregion}
    Class Function CalendarID : Cardinal; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the algorithm type of the calendar system.
    /// </summary>
    /// <returns>
    /// Returns <see cref="TCalendarKind.ckSolar"/>.
    /// </returns>
    {$Endregion}
    Class Function CalendarKind : TCalendarKind; Override;
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
    Class Function MinSupportedDateTime : TDateTime; Override;
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
    Class Function MaxSupportedDateTime : TDateTime; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the <see cref="TCalendarSettings"/> class that provides locale
    /// specific settings for the calendar.
    /// </summary>
    /// <returns>
    /// Returns <see cref="TJalaliCalendarSettings"/> class.
    /// </returns>
    {$Endregion}
    Class Function SettingsClass : TCalendarSettingsClass; Override;
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
    Function ConvertYear(Year, FromEra, ToEra : Integer) : Integer; Override;
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
    Function IsValidYear(Era, Year : Integer) : Boolean; Override;
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
    Function IsLeapYear(Era, Year : Integer) : Boolean; Override;
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
    /// Returns 365 for normal and 366 for leap years.
    /// </returns>
    {$Endregion}
    Function DaysInYear(Era, Year : Integer) : Integer; Override;
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
    Function DaysInMonth(Era, Year, Month : Integer) : Integer; Override;
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
    Function DaysToMonth(Era, Year, Month : Integer) : Integer; Override;
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
    /// <param name="YearDay">
    /// The day of the year.
    /// </param>
    /// <param name="Month">
    /// The month of the year.
    /// </param>
    /// <param name="Day">
    /// The day of the month.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the conversion succeeds, otherwise
    /// returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function DayOfYearToDayOfMonth(Era, Year, YearDay : Integer; Var Month, Day : Integer) : Boolean; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the date and time of the vernal equinox for a specified era and year
    /// in Iran Standard Time.
    /// </summary>
    /// <param name="Era">
    /// The era.
    /// </param>
    /// <param name="Year">
    /// The year in the Jalali calendar.
    /// </param>
    /// <returns>
    /// The date and time of the vernal equinox in <see cref="TDateTime"/> format.
    /// </returns>
    /// <remarks>
    /// The returned <see cref="TDateTime"/> value is expressed in Tehran civil time
    /// (UTC+03:30). The astronomical algorithm provides sub-minute accuracy for
    /// equinox times across the supported date range.
    /// </remarks>
    {$Endregion}
    Function VernalEquinox(Era, Year : Integer) : TDateTime; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the date and time of the vernal equinox for a specified year in
    /// Iran Standard Time.
    /// </summary>
    /// <param name="Year">
    /// The year in the Jalali calendar.
    /// </param>
    /// <returns>
    /// The date and time of the vernal equinox in <see cref="TDateTime"/> format.
    /// </returns>
    /// <remarks>
    /// The returned <see cref="TDateTime"/> value is expressed in Tehran civil time
    /// (UTC+03:30). The astronomical algorithm provides sub-minute accuracy for
    /// equinox times across the supported date range.
    /// </remarks>
    /// <seealso cref="DefaultEra"/>
    {$Endregion}
    Function VernalEquinox(Year : Integer) : TDateTime; Overload; Inline;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class provides locale specific settings for the <see cref="TJalaliCalendar"/>
/// class.
/// </summary>
/// <remarks>
/// TJalaliCalendarSettings class collects the Jalali calendar's locale specific
/// settings, which are required by the <see cref="TJalaliCalendar"/> class.
/// </remarks>
{$Endregion}

  TJalaliCalendarSettings = Class(TCalendarSettings)
   Protected
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
    /// The identifier of the calendar system.
    /// </param>
    {$Endregion}
    Procedure PrepareEraName(Era : Integer; Const Locale : String; CalendarID : Cardinal); Override;
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
    /// The identifier of the calendar system.
    /// </param>
    {$Endregion}
    Procedure PrepareMonthNames(Const Locale : String; CalendarID : Cardinal); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Sets all writable properties based on the given locale and calendar
    /// identifier.
    /// </summary>
    /// <param name="Locale">
    /// The locale of the settings.
    /// </param>
    /// <param name="CalendarID">
    /// The identifier of the calendar system.
    /// </param>
    {$Endregion}
    Procedure PrepareSettings(Const Locale : String; CalendarID : Cardinal); Override;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Determines the calendar system that this settings is provided for.
    /// </summary>
    /// <returns>
    /// Returns the <see cref="TJalaliCalendar"/> class.
    /// </returns>
    {$Endregion}
    Class Function CalendarClass : TCalendarClass; Override;
  End;

Implementation

 Uses
  Math, Types, i18nWinNLS, i18nCore, i18nAstronomy;

 Const
  // Year offset between Jalali and Gregorian calendars
  JALALI_TO_GREGORIAN_YEAR_OFFSET = -559;
// Supported astronomical (zero-based) years in the Jalali calendar
  JALALI_MIN_YEAR = MEEUS_MIN_YEAR - JALALI_TO_GREGORIAN_YEAR_OFFSET;
  JALALI_MAX_YEAR = MEEUS_MAX_YEAR - JALALI_TO_GREGORIAN_YEAR_OFFSET;
// Mean length of a Jalali year in days
  MEAN_JALALI_YEAR_DAYS = 365.24219858156;
// Iran Standard Time offset from UTC in days (+03:30)
  IRAN_UTC_OFFSET_DAYS = 3.5 / 24.0;

 Var
  // Computed Nowruz Julian Day Number for each astronomical (zero-based) Jalali year.
  // Zero indicates that the value is not yet computed.
  NowruzCache : Array[JALALI_MIN_YEAR..JALALI_MAX_YEAR] Of Integer;

// Calculates the Julian Day Number for Nowruz (the start of the Jalali year)
// for a given astronomical (zero-based) Jalali year.

 Function NowruzJDN(Jy : Integer) : Integer;
  Var
   EquinoxJD_UT     : Extended;
   EquinoxJD_Tehran : Extended;
   TehranMidnightJD : Extended;
   TehranCivilDay   : Integer;
   FractionOfDay    : Extended;
  Begin
   If (Jy < JALALI_MIN_YEAR) Or (Jy > JALALI_MAX_YEAR) Then
    Begin
     Result := 0;
     Exit;
    End;

   Result := NowruzCache[Jy];
   If Result <> 0 Then
    Exit;

   // Astronomical equinox instant (noon-based)
   EquinoxJD_UT := VernalEquinoxJulianDay(Jy + JALALI_TO_GREGORIAN_YEAR_OFFSET);

   // Convert equinox instant to Tehran local time (still noon-based)
   EquinoxJD_Tehran := EquinoxJD_UT + IRAN_UTC_OFFSET_DAYS;

   // Shift to midnight-based civil day numbering
   TehranMidnightJD := EquinoxJD_Tehran + 0.5;

   // Extract Tehran civil day and time within that day
   TehranCivilDay := Trunc(TehranMidnightJD);
   FractionOfDay  := TehranMidnightJD - TehranCivilDay;

   // Nowruz rule:
   //   before noon  -> same civil day
   //   noon or after -> next civil day
   If FractionOfDay < 0.5 Then
    Result := TehranCivilDay
   Else
    Result := TehranCivilDay + 1;

   NowruzCache[Jy] := Result;
  End;

// Finds the astronomical (zero-based) Jalali year corresponding
// to a given Julian Day Number.

 Function FindJalaliYear(JDN : Integer) : Integer;
  Var
   MinJDN : Integer;
   MaxJDN : Integer;
   Year   : Integer;
  Begin
   MinJDN := NowruzJDN(JALALI_MIN_YEAR);
   If (JDN < MinJDN) Then
    Begin
     // Return a year just before the minimum to indicate out-of-range.
     Result := JALALI_MIN_YEAR - 1;
     Exit;
    End;

   MaxJDN := NowruzJDN(JALALI_MAX_YEAR);
   If (JDN >= MaxJDN) Then
    Begin
     // Return a year just after the maximum to indicate out-of-range.
     Result := JALALI_MAX_YEAR + 1;
     Exit;
    End;

   // Approximate using the mean Jalali year length.
   Year := JALALI_MIN_YEAR + Trunc((JDN - MinJDN) / MEAN_JALALI_YEAR_DAYS);

   // Clamp in case floating-point estimation lands just outside the range.
   If (Year < JALALI_MIN_YEAR) Then
    Year := JALALI_MIN_YEAR;
   If (Year > JALALI_MAX_YEAR) Then
    Year := JALALI_MAX_YEAR;

   // Adjust downward if the Nowruz of the estimated year is after the JDN.
   While (NowruzJDN(Year) > JDN) Do
    Dec(Year);

   // Adjust upward if the Nowruz of the next year is on or before the JDN.
   While (NowruzJDN(Year + 1) <= JDN) Do
    Inc(Year);

   Result := Year;
  End;

{ TJalaliCalendar }

  Class Function TJalaliCalendar.CalendarID : Cardinal;

Begin
 Result := CAL_PERSIAN;

End;

  Class Function TJalaliCalendar.CalendarKind : TCalendarKind;

Begin
 Result := ckSolar;

End;

  Class Function TJalaliCalendar.MinSupportedDateTime : TDateTime;

Begin
 Result := Max({1/01/01 Jalali - Imperial} -897684, Inherited);

End;

  Class Function TJalaliCalendar.MaxSupportedDateTime : TDateTime;

Begin
 Result := Min({3558/12/29 Jalali - Imperial} 401847.99999, Inherited);

End;

  Class Function TJalaliCalendar.MaxEra : Integer;

Begin
 Result := HijriEra;

End;

  Class Function TJalaliCalendar.SettingsClass : TCalendarSettingsClass;

Begin
 Result := TJalaliCalendarSettings;

End;

 Function TJalaliCalendar.DayOfYearToDayOfMonth(Era, Year, YearDay : Integer; Var Month, Day : Integer) : Boolean;
  Begin
   If YearDay <= 6 * 31 Then
    Begin
     Month  := ((YearDay - 1) Div 31) + 1;
     Day    := YearDay - (Month - 1) * 31;
     Result := True;
    End
   Else If YearDay <= DaysInYear(Era, Year) Then
    Begin
     Dec(YearDay, 6 * 31);
     Month  := ((YearDay - 1) Div 30) + 7;
     Day    := YearDay - (Month - 7) * 30;
     Result := True;
    End
   Else
    Result := False;
  End;

 Function TJalaliCalendar.ToJulianDay(Year, Month, Day : Integer) : Extended;
  Var
   JDN : Integer;
  Begin
   JDN := NowruzJDN(ToZeroBase(ImperialEra, Year));
   If JDN = 0 Then
    YearError(ImperialEra, Year);

   If (Day < 1) Or (Day > DaysInMonth(ImperialEra, Year, Month)) Then
    DayError(ImperialEra, Year, Month, Day);

   Result := JDN + DaysToMonth(ImperialEra, Year, Month) + (Day - 1) - 0.5;
  End;

 Function TJalaliCalendar.FromJulianDay(Const JD : Extended; Out Year, Month, Day : Integer) : Boolean;
  Var
   JDN     : Integer;
   Jy      : Integer;
   Nowruz  : Integer;
   YearDay : Integer;
  Begin
   JDN := Trunc(JD + 0.5); // Assumed JD is in Tehran civil time

   Jy     := FindJalaliYear(JDN);
   Nowruz := NowruzJDN(Jy);
   If Nowruz = 0 Then
    Begin
     Result := False;
     Exit;
    End;

   Year    := FromZeroBase(ImperialEra, Jy);
   YearDay := (JDN - Nowruz) + 1;
   Result  := DayOfYearToDayOfMonth(ImperialEra, Year, YearDay, Month, Day);
  End;

 Function TJalaliCalendar.ConvertYear(Year, FromEra, ToEra : Integer) : Integer;
  Begin
   If Year = 0 Then
    YearError(FromEra, 0)
   Else If FromEra <> ToEra Then
    Begin
     If FromEra = HijriEra Then
      Year := OffsetYear(Year, +HIJRI_YEAR_OFFSET, FromEra, ImperialEra)
     Else If FromEra <> ImperialEra Then
      EraError(FromEra);
     If ToEra = HijriEra Then
      Year := OffsetYear(Year, -HIJRI_YEAR_OFFSET, ImperialEra, ToEra)
     Else If ToEra <> ImperialEra Then
      EraError(ToEra);
    End
   Else If Not(FromEra In [ImperialEra, HijriEra]) Then
    EraError(FromEra);
   Result := Year;
  End;

 Function TJalaliCalendar.IsValidYear(Era, Year : Integer) : Boolean;
  Var
   Jy : Integer;
  Begin
   Jy     := ToZeroBase(ImperialEra, ConvertYear(Year, Era, ImperialEra));
   Result := (Jy >= JALALI_MIN_YEAR) And (Jy <= JALALI_MAX_YEAR);
  End;

 Function TJalaliCalendar.IsLeapYear(Era, Year : Integer) : Boolean;
  Begin
   Result := DaysInYear(Era, Year) = 366;
  End;

 Function TJalaliCalendar.DaysInYear(Era, Year : Integer) : Integer;
  Var
   Jy      : Integer;
   Current : Integer;
   Next    : Integer;
  Begin
   Jy := ToZeroBase(ImperialEra, ConvertYear(Year, Era, ImperialEra));

   Current := NowruzJDN(Jy);
   If Current = 0 Then
    YearError(Era, Year);

   Next := NowruzJDN(Jy + 1);
   If Next = 0 Then
    YearError(Era, Year);

   Result := Next - Current;
  End;

 Function TJalaliCalendar.DaysInMonth(Era, Year, Month : Integer) : Integer;
  Begin
   If (Month < 1) Or (Month > 12) Then
    MonthError(Era, Year, Month);

   If (Month = 12) And Not IsLeapYear(Era, Year) Then
    Result := 29
   Else If Month > 6 Then
    Result := 30
   Else
    Result := 31;
  End;

 Function TJalaliCalendar.DaysToMonth(Era, Year, Month : Integer) : Integer;
  Begin
   If (Month < 1) Or (Month > 12) Then
    MonthError(Era, Year, Month);

   Result := Min(Month - 1, 6) + ((Month - 1) * 30);
  End;

 Function TJalaliCalendar.VernalEquinox(Era, Year : Integer) : TDateTime;
  Var
   Jy        : Integer;
   EquinoxJD : Extended;
  Begin
   Jy := ToZeroBase(ImperialEra, ConvertYear(Year, Era, ImperialEra));
   If (Jy < JALALI_MIN_YEAR) Or (Jy > JALALI_MAX_YEAR) Then
    YearError(Era, Year);

   EquinoxJD := VernalEquinoxJulianDay(Jy + JALALI_TO_GREGORIAN_YEAR_OFFSET);
   Result    := JulianDayToDateTime(EquinoxJD + IRAN_UTC_OFFSET_DAYS);
  End;

 Function TJalaliCalendar.VernalEquinox(Year : Integer) : TDateTime;
  Begin
   Result := VernalEquinox(DefaultEra, Year);
  End;

{ TJalaliCalendarSettings }

  Class Function TJalaliCalendarSettings.CalendarClass : TCalendarClass;

Begin
 Result := TJalaliCalendar;

End;

 Procedure TJalaliCalendarSettings.PrepareEraName(Era : Integer; Const Locale : String; CalendarID : Cardinal);
  Begin
   If Pos('Arab;', GetLocaleScripts(Locale)) = 0 Then
    Case Era Of
     TJalaliCalendar.ImperialEra :
      Begin
       EraNames[Era]      := 'Imperial';
       ShortEraNames[Era] := 'IE';
      End;
     TJalaliCalendar.HijriEra :
      Begin
       EraNames[Era]      := 'Solar Hijri';
       ShortEraNames[Era] := 'SH';
      End;
    End
   Else If SameLanguage(Locale, 'fa') Or SameLanguage(Locale, 'ps') Or SameLanguage(Locale, 'prs') Then
    Case Era Of
     TJalaliCalendar.ImperialEra :
      Begin
       EraNames[Era]      := 'شاهنشاهی';
       ShortEraNames[Era] := 'ش';
      End;
     TJalaliCalendar.HijriEra :
      Begin
       EraNames[Era]      := 'هجری خورشیدی';
       ShortEraNames[Era] := 'هـ.خ';
      End;
    End
   Else
    Case Era Of
     TJalaliCalendar.ImperialEra :
      Begin
       EraNames[Era]      := 'الإمبراطورية';
       ShortEraNames[Era] := 'إم';
      End;
     TJalaliCalendar.HijriEra :
      Begin
       EraNames[Era]      := 'الهجري الشمسي';
       ShortEraNames[Era] := 'هـ.ش';
      End;
    End;
  End;

 Procedure TJalaliCalendarSettings.PrepareMonthNames(Const Locale : String; CalendarID : Cardinal);
  Const
   PersianMonthNames : Array [1..12] Of String = (
   'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور',
   'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند');
   ArabicMonthNames : Array [1..12] Of String = (
   'حمل', 'ثور', 'جوزا', 'سرطان', 'اسد', 'سنبله',
   'میزان', 'عقرب', 'قوس', 'جدی', 'دلو', 'حوت');
   EnglishMonthNames : Array [1..12] Of String = (
   'Farvardin', 'Ordibehesht', 'Khordad', 'Tir', 'Mordad', 'Shahrivar',
   'Mehr', 'Aban', 'Azar', 'Dey', 'Bahman', 'Esfand');
  Var
   m : Integer;
  Begin
   If Pos('Arab;', GetLocaleScripts(Locale)) <> 0 Then
    Begin
     If SameText(Locale, 'fa-IR') Then
      For m := 1 To 12 Do
       Begin
        MonthNames[m]         := PersianMonthNames[m];
        ShortMonthNames[m]    := PersianMonthNames[m];
        GenitiveMonthNames[m] := PersianMonthNames[m];
       End
     Else
      For m := 1 To 12 Do
       Begin
        MonthNames[m]         := ArabicMonthNames[m];
        ShortMonthNames[m]    := ArabicMonthNames[m];
        GenitiveMonthNames[m] := ArabicMonthNames[m];
       End
    End
   Else
    Begin
     For m := 1 To 12 Do
      Begin
       MonthNames[m]         := EnglishMonthNames[m];
       ShortMonthNames[m]    := Copy(EnglishMonthNames[m], 1, 3);
       GenitiveMonthNames[m] := EnglishMonthNames[m];
      End;
    End;
  End;

 Procedure TJalaliCalendarSettings.PrepareSettings(Const Locale : String; CalendarID : Cardinal);
  Begin
   Inherited PrepareSettings(Locale, CalendarID);

   TwoDigitYearMax := 2530;
   FirstDayOfWeek  := Saturday;

   If SameLanguage(Locale, 'fa') Or SameLanguage(Locale, 'ps') Or SameLanguage(Locale, 'prs') Then
    CalendarName := 'گاهشمار جلالی';

   If SameText(Locale, 'fa-IR') Then
    Begin
     // Workaround for Windows NLS incorrect formats
     If SameText(LongDateFormat, 'yyyy/MM/dd') Then
      LongDateFormat := 'dddd d MMMM yyyy';
     If SameText(LongTimeFormat, 'hh:mm:ss ampm') Then
      LongTimeFormat := 'hh:nn:ss';
     If Win32MajorVersion <= 5 Then
      Begin
       ShortestDayNames[Saturday]  := 'ش';
       ShortestDayNames[Sunday]    := 'ی';
       ShortestDayNames[Monday]    := 'د';
       ShortestDayNames[Tuesday]   := 'س';
       ShortestDayNames[Wednesday] := 'چ';
       ShortestDayNames[Thursday]  := 'پ';
       ShortestDayNames[Friday]    := 'ج';
      End;
    End;
  End;

Initialization
 CalendarTypes.Register(TJalaliCalendar, ['fa-IR', 'prs-AF', 'ps-AF']);

End.
