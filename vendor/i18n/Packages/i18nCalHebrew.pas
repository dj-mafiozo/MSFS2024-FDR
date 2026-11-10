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
/// This unit implements the Hebrew (or Jewish) calendar.
/// </summary>
Unit i18nCalHebrew;

{$I DELPHIAREA.INC}

Interface

 Uses
  SysUtils, i18nCalendar;

 Type

  {$Region 'xmldoc'}
  /// <summary>
  /// This class implements the Hebrew (or Jewish) calendar.
  /// </summary>
  /// <remarks>
  /// <para>
  /// THebrewCalendar provides properties and methods to manipulate dates in
  /// the Hebrew calendar.
  /// </para>
  /// <para>
  /// The Hebrew (or Jewish) calendar attempts to simultaneously maintain alignment
  /// between the months and the seasons and synchronize the months with the Moon; it
  /// is thus deemed a "luni-solar calendar". In addition, there are constraints
  /// on which days of the week a year can begin and to shift the otherwise
  /// required extra days to prior years to keep the length of the year within the
  /// prescribed bounds. This isn't easy, and the computations required are
  /// correspondingly intricate.
  /// </para>
  /// <para>
  /// Years are classified as common (normal) or embolismic (leap) years which occur
  /// in a 19 year cycle in years 3, 6, 8, 11, 14, 17, and 19. In an embolismic
  /// (leap) year, an extra month of 29 days, "Veadar" or "Adar II", is added to the
  /// end of the year after the month "Adar", which is designated "Adar I" in such
  /// years. Further, years may be deficient, regular, or complete, having respectively
  /// 353, 354, or 355 days in a common year and 383, 384, or 385 days in embolismic
  /// years. Days are defined as beginning at sunset, and the calendar begins at sunset
  /// the night before Monday, October 7, 3761 B.C.E. in the Julian calendar, or Julian
  /// day 347995.5. Days are numbered with Sunday as day 1, through Saturday as day 7.
  /// </para>
  /// <para>
  /// The average length of a month is 29.530594 days, extremely close to the mean
  /// synodic month (time from new Moon to next new Moon) of 29.530588 days. Such is
  /// the accuracy that more than 13,800 years elapse before a single day discrepancy
  /// between the calendar's average reckoning of the start of months and the mean time
  /// of the new Moon. Alignment with the solar year is better than the Julian calendar,
  /// but inferior to the Gregorian. The average length of a year is 365.2468 days
  /// compared to the actual solar tropical year (time from equinox to equinox) of
  /// 365.24219 days, so the calendar accumulates one day of error with respect to the
  /// solar year every 216 years.
  /// </para>
  /// <para>
  /// NOTE: Both description and algorithm of this calendar are adapted from
  /// http://www.fourmilab.ch/documents/calendar/.
  /// </para>
  /// </remarks>
  {$Endregion}
  THebrewCalendar = Class(TCalendar)
   Private
    Class Function ElapsedDays(Year : Integer) : Integer; Static;
    Class Function Delay(Year : Integer) : Integer; Static;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// The start of the Hebrew calendar in Julian days.
    /// </summary>
    {$Endregion}
    Const HEBREW_EPOCH = 347995.5;
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts a Hebrew date represented by its year, month and day
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
    /// Julian day of the specified Hebrew date.
    /// </returns>
    /// <seealso cref="FromJulianDay"/>
    {$Endregion}
    Function ToJulianDay(Year, Month, Day : Integer) : Extended; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts a date expressed in Julian day, to its year, month, and day
    /// components in the Hebrew calendar.
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
    /// Returns <see langword="true"/> if the function is succeeded, otherwise
    /// returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="ToJulianDay"/>
    {$Endregion}
    Function FromJulianDay(Const JD : Extended; Out Year, Month, Day : Integer) : Boolean; Override;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Specifies index of Hebrew Era (C.E.).
    /// </summary>
    {$Endregion}
    Const HebrewEra = 1;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the unique identifier of the calendar.
    /// </summary>
    /// <returns>
    /// Returns <see cref="CAL_HEBREW"/>.
    /// </returns>
    {$Endregion}
    Class Function CalendarID : Cardinal; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the algorithm type of the calendar system.
    /// </summary>
    /// <returns>
    /// Returns a <see cref="TCalendarKind"/> value of ckLunisolar.
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
    /// Returns the <see cref="TCalendarSettings"/> class that provides locale-
    /// specific settings for the calendar.
    /// </summary>
    /// <returns>
    /// Returns the <see cref="THebrewCalendarSettings"/> class.
    /// </returns>
    {$Endregion}
    Class Function SettingsClass : TCalendarSettingsClass; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the maximum number of months that the calendar may have in a year.
    /// </summary>
    /// <returns>
    /// Returns 13.
    /// </returns>
    {$Endregion}
    Class Function MaxMonthsPerYear : Integer; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the first month of the year for the calendar.
    /// </summary>
    /// <returns>
    /// Returns 7 (Tishri).
    /// </returns>
    {$Endregion}
    Class Function FirstMonthOfYear : Integer; Override;
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
    /// Returns 12 for common (normal) and 13 for embolismic (leap) years.
    /// </returns>
    {$Endregion}
    Function MonthsInYear(Era, Year : Integer) : Integer; Override;
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
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class provides locale-specific settings for the <see cref="THebrewCalendar"/>
/// class.
/// </summary>
/// <remarks>
/// <para>
/// THebrewCalendarSettings class collects the Hebrew calendar's locale-specific
/// settings, which are required by the <see cref="THebrewCalendar"/> class.
/// </para>
/// </remarks>
{$Endregion}

  THebrewCalendarSettings = Class(TCalendarSettings)
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts a given month number to its index in the Windows calendar
    /// information.
    /// </summary>
    /// <param name="Month">
    /// The month number.
    /// </param>
    /// <returns>
    /// The zero-based index of given month number in the Windows calendar
    /// information.
    /// </returns>
    {$Endregion}
    Function GetMonthInfoIndex(Month : Integer) : Integer; Override;
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
    Procedure PrepareMonthNames(Const Locale : String; CalendarID : Cardinal); Override;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Determines the calendar system that these settings are provided for.
    /// </summary>
    /// <returns>
    /// Returns the <see cref="THebrewCalendar"/> class.
    /// </returns>
    {$Endregion}
    Class Function CalendarClass : TCalendarClass; Override;
  End;

Implementation

 Uses
  Math, Types, i18nWinNLS;

{ THebrewCalendar }

  Class Function THebrewCalendar.CalendarID : Cardinal;

Begin
 Result := CAL_HEBREW;

End;

  Class Function THebrewCalendar.CalendarKind : TCalendarKind;

Begin
 Result := ckLunisolar;

End;

  Class Function THebrewCalendar.MaxMonthsPerYear : Integer;

Begin
 Result := 13;

End;

  Class Function THebrewCalendar.MinSupportedDateTime : TDateTime;

Begin
 Result := Max({0001/07/01 Hebrew} -2067021.0, Inherited);

End;

  Class Function THebrewCalendar.MaxSupportedDateTime : TDateTime;

Begin
 Result := Min({9999/06/29 Hebrew} 1585056.99999, Inherited);

End;

  Class Function THebrewCalendar.SettingsClass : TCalendarSettingsClass;

Begin
 Result := THebrewCalendarSettings;

End;

  Class Function THebrewCalendar.FirstMonthOfYear : Integer;

Begin
 Result := 7;

End;

 Function THebrewCalendar.IsLeapYear(Era, Year : Integer) : Boolean;
  Begin
   Year   := ConvertYear(Year, Era, HebrewEra);
   Year   := ToZeroBase(HebrewEra, Year);
   Result := Modulus(((Year * 7) + 1), 19) < 7;
  End;

 Function THebrewCalendar.MonthsInYear(Era, Year : Integer) : Integer;
  Begin
   If IsLeapYear(Era, Year) Then
    Result := 13
   Else
    Result := 12;
  End;

 Function THebrewCalendar.DaysInMonth(Era, Year, Month : Integer) : Integer;
  Begin
   If (Month < 1) Or (Month > 13) Or ((Month = 13) And Not IsLeapYear(Era, Year)) Then
    MonthError(Era, Year, Month);
   If Month In [2, 4, 6, 10, 13] Then
    Result := 29
   Else If (Month = 12) And Not IsLeapYear(Era, Year) Then
    Result := 29
   Else If (Month = 8) And ((DaysInYear(Era, Year) Mod 10) <> 5) Then
    Result := 29
   Else If (Month = 9) And ((DaysInYear(Era, Year) Mod 10) = 3) Then
    Result := 29
   Else
    Result := 30;
  End;

  Class Function THebrewCalendar.ElapsedDays(Year : Integer) : Integer;

 Var
  Months : Integer;
  Day    : Integer;
  Parts  : Integer;

Begin
 Months := Floor(((235 * Year) - 234) / 19);
 Parts  := 12084 + (13753 * Months);
 Day    := (Months * 29) + Floor(Parts / 25920);
 If ((3 * (Day + 1)) Mod 7) < 3 Then
  Inc(Day);
 Result := Day;

End;

  Class Function THebrewCalendar.Delay(Year : Integer) : Integer;

 Var
  Last    : Integer;
  Present : Integer;
  Next    : Integer;

Begin
 Last    := ElapsedDays(Year - 1);
 Present := ElapsedDays(Year);
 Next    := ElapsedDays(Year + 1);
 If (Next - Present) = 356 Then
  Result := 2
 Else If (Present - Last) = 382 Then
  Result := 1
 Else
  Result := 0;
 Inc(Result, Present);

End;

 Function THebrewCalendar.ToJulianDay(Year, Month, Day : Integer) : Extended;
  Var
   m : Integer;
  Begin
   Year   := ToZeroBase(HebrewEra, Year);
   Result := HEBREW_EPOCH + Delay(Year) + Day + 1;
   Year   := FromZeroBase(HebrewEra, Year);
   If Month < 7 Then
    Begin
     For m   := 1 To Month - 1 Do
      Result := Result + DaysInMonth(HebrewEra, Year, m);
     For m   := 7 To MonthsInYear(HebrewEra, Year) Do
      Result := Result + DaysInMonth(HebrewEra, Year, m);
    End
   Else
    Begin
     For m   := 7 To Month - 1 Do
      Result := Result + DaysInMonth(HebrewEra, Year, m);
    End;
  End;

 Function THebrewCalendar.FromJulianDay(Const JD : Extended; Out Year, Month, Day : Integer) : Boolean;
  Var
   NormalizedJD : Extended;
   Diff         : Extended;
  Begin
   NormalizedJD := Trunc(JD - 0.5) + 0.5;
   Year         := Floor(((NormalizedJD - HEBREW_EPOCH) * 98496) / 35975351);
   Year         := FromZeroBase(HebrewEra, Year);
   Diff         := NormalizedJD - ToJulianDay(Year, 7, 1);
   If Diff >= 0 Then
    Begin
     Inc(Year, Floor(Diff / 385));
     While NormalizedJD >= ToJulianDay(Year, 7, 1) Do
      Inc(Year);
    End;
   Dec(Year);
   If NormalizedJD < ToJulianDay(Year, 1, 1) Then
    Month := 7
   Else
    Month := 1;
   While NormalizedJD > ToJulianDay(Year, Month, DaysInMonth(HebrewEra, Year, Month)) Do
    Inc(Month);
   Day    := Trunc(NormalizedJD - ToJulianDay(Year, Month, 1)) + 1;
   Result := (Day >= 0);
  End;

{ THebrewCalendarSettings }

  Class Function THebrewCalendarSettings.CalendarClass : TCalendarClass;

Begin
 Result := THebrewCalendar;

End;

 Function THebrewCalendarSettings.GetMonthInfoIndex(Month : Integer) : Integer;
  Begin
   Result := (Month + 6) Mod 13;
  End;

 Procedure THebrewCalendarSettings.PrepareMonthNames(Const Locale : String; CalendarID : Cardinal);
  Const
   EnglishMonthNames : Array[1..13] Of String = (
   'Nisan', 'Iyyar', 'Sivan', 'Tammuz', 'Av', 'Elul', 'Tishri',
   'Heshvan', 'Kislev', 'Teveth', 'Shevat', 'Adar', 'Adar II');
   EnglishShortMonthNames : Array[1..13] Of String = (
   'NIS', 'IYA', 'SIV', 'TAM', 'AV', 'ELU', 'TIS',
   'HES', 'KIS', 'TEV', 'SHE', 'ADA', 'AD2');
  Var
   m : Integer;
  Begin
   If Pos('Hebr;', GetLocaleScripts(Locale)) <> 0 Then
    Inherited PrepareMonthNames(Locale, CalendarID)
   Else
    Begin
     For m := 1 To 13 Do
      Begin
       MonthNames[m]         := EnglishMonthNames[m];
       ShortMonthNames[m]    := EnglishShortMonthNames[m];
       GenitiveMonthNames[m] := EnglishMonthNames[m];
      End;
    End;
  End;

Initialization
 CalendarTypes.Register(THebrewCalendar, ['he-IL']);

End.
