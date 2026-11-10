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
/// This unit implements the Gregorian calendar.
/// </summary>
Unit i18nCalGregorian;

{$I DELPHIAREA.INC}

Interface

 Uses
  SysUtils, i18nCalendar;

 Type

  {$Region 'xmldoc'}
  /// <summary>
  /// This class implements the Gregorian calendar.
  /// </summary>
  /// <remarks>
  /// <para>
  /// TGregorianCalendar provides properties and methods to manipulate dates
  /// in the Gregorian calendar.
  /// </para>
  /// <para>
  /// The Gregorian calendar is a minor correction to the Julian calendar, proclaimed
  /// by Pope Gregory XIII. In the Julian calendar every fourth year is a leap year
  /// in which February has 29, not 28 days, but in the Gregorian, years divisible
  /// by 100 are not leap years unless they are also divisible by 400. As in the
  /// Julian calendar, days are considered to begin at midnight.
  /// </para>
  /// <para>
  /// The average length of a year in the Gregorian calendar is 365.2425 days
  /// compared to the actual solar tropical year (time from equinox to equinox)
  /// of 365.24219878 days, so the calendar accumulates one day of error with
  /// respect to the solar year about every 3300 years. As a purely solar calendar,
  /// no attempt is made to synchronize the start of months to the phases of the Moon.
  /// </para>
  /// <para>
  /// NOTE: Both description and algorithm of this calendar are adapted from
  /// http://www.fourmilab.ch/documents/calendar/.
  /// </para>
  /// </remarks>
  {$Endregion}
  TGregorianCalendar = Class(TCalendar)
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// The start of the Gregorian calendar in Julian days.
    /// </summary>
    {$Endregion}
    Const GREGORIAN_EPOCH = 1721425.5;
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts a Gregorian date represented by its year, month and day
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
    /// Julian day of the specified Gregorian date.
    /// </returns>
    /// <seealso cref="FromJulianDay"/>
    {$Endregion}
    Function ToJulianDay(Year, Month, Day : Integer) : Extended; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts a date expressed in Julian day to its year, month, and day
    /// components in the Gregorian calendar.
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
    /// Returns <see langword="true"/> if the function succeeds, otherwise
    /// returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="ToJulianDay"/>
    {$Endregion}
    Function FromJulianDay(Const JD : Extended; Out Year, Month, Day : Integer) : Boolean; Override;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Specifies index of Common Era (C.E.).
    /// </summary>
    {$Endregion}
    Const CommonEra = 1;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the unique identifier of the calendar.
    /// </summary>
    /// <returns>
    /// Returns <see cref="CAL_GREGORIAN"/>.
    /// </returns>
    {$Endregion}
    Class Function CalendarID : Cardinal; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the algorithm type of the calendar system.
    /// </summary>
    /// <returns>
    /// Returns a <see cref="TCalendarKind"/> value of ckSolar.
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
    /// Returns the <see cref="TCalendarSettings"/> class that provides locale-specific
    /// settings for the calendar.
    /// </summary>
    /// <returns>
    /// Returns <see cref="TGregorianCalendarSettings"/> class.
    /// </returns>
    {$Endregion}
    Class Function SettingsClass : TCalendarSettingsClass; Override;
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
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class provides locale-specific settings for the <see cref="TGregorianCalendar"/>
/// class.
/// </summary>
/// <remarks>
/// TGregorianCalendarSettings class collects the Gregorian calendar's locale-specific
/// settings, which are required by the <see cref="TGregorianCalendar"/> class.
/// </remarks>
{$Endregion}

  TGregorianCalendarSettings = Class(TCalendarSettings)
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Determines the calendar system that this settings is provided for.
    /// </summary>
    /// <returns>
    /// Returns <see cref="TGregorianCalendar"/> class.
    /// </returns>
    {$Endregion}
    Class Function CalendarClass : TCalendarClass; Override;
  End;

Implementation

 Uses
  Math, Windows, Types, i18nWinNLS;

{ TGregorianCalendar }

  Class Function TGregorianCalendar.CalendarID : Cardinal;

Begin
 Result := CAL_GREGORIAN;

End;

  Class Function TGregorianCalendar.CalendarKind : TCalendarKind;

Begin
 Result := ckSolar;

End;

  Class Function TGregorianCalendar.MinSupportedDateTime : TDateTime;

Begin
 Result := Max({0001/01/01} -693593, Inherited);

End;

  Class Function TGregorianCalendar.MaxSupportedDateTime : TDateTime;

Begin
 Result := Min({9999/12/31} 2958465.99999, Inherited);

End;

  Class Function TGregorianCalendar.SettingsClass : TCalendarSettingsClass;

Begin
 Result := TGregorianCalendarSettings;

End;

 Function TGregorianCalendar.IsLeapYear(Era, Year : Integer) : Boolean;
  Begin
   Year   := ConvertYear(Year, Era, CommonEra);
   Year   := ToZeroBase(CommonEra, Year);
   Result := ((Year Mod 4) = 0) And (((Year Mod 100) <> 0) Or ((Year Mod 400) = 0));
  End;

 Function TGregorianCalendar.DaysInYear(Era, Year : Integer) : Integer;
  Begin
   If IsLeapYear(Era, Year) Then
    Result := 366
   Else
    Result := 365;
  End;

 Function TGregorianCalendar.DaysInMonth(Era, Year, Month : Integer) : Integer;
  Const
   Days : Array[Boolean] Of TDayTable =
   ((31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31),
   (31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31));
  Begin
   If (Month < 1) Or (Month > 12) Then
    MonthError(Era, Year, Month);
   Result := Days[IsLeapYear(Era, Year)][Month];
  End;

 Function TGregorianCalendar.DaysToMonth(Era, Year, Month : Integer) : Integer;
  Const
   Days : Array[Boolean] Of TDayTable =
   ((0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334),
   (0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335));
  Begin
   If (Month < 1) Or (Month > 12) Then
    MonthError(Era, Year, Month);
   Result := Days[IsLeapYear(Era, Year)][Month];
  End;

 Function TGregorianCalendar.ToJulianDay(Year, Month, Day : Integer) : Extended;
  Const
   AdjustDays : Array[Boolean] Of Integer = (2, 1);
  Var
   Adjust : Integer;
  Begin
   If Month > 2 Then
    Adjust := AdjustDays[IsLeapYear(CommonEra, Year)]
   Else
    Adjust := 0;
   Year    := ToZeroBase(CommonEra, Year);
   Result  := GREGORIAN_EPOCH + (Year - 1) * 365
   + Floor((Year - 1) / 4) - Floor((Year - 1) / 100) + Floor((Year - 1) / 400)
   + Floor(((367 * Month) - 362) / 12) + (Day - 1) - Adjust;
  End;

 Function TGregorianCalendar.FromJulianDay(Const JD : Extended; Out Year, Month, Day : Integer) : Boolean;
  Var
   NormalizedJD : Extended;
   Period       : Integer;
   QuadriCent   : Integer;
   Cent         : Integer;
   Quad         : Integer;
   YearOfQuad   : Integer;
   DayOfYear    : Integer;
  Begin
   NormalizedJD := Trunc(JD - 0.5) + 0.5;
   Period       := Trunc(NormalizedJD - GREGORIAN_EPOCH);
   Divide(Period, 146097, QuadriCent, Period);
   Divide(Period, 36524, Cent, Period);
   Divide(Period, 1461, Quad, Period);
   YearOfQuad := Floor(Period / 365);
   Year       := (QuadriCent * 400) + (Cent * 100) + (Quad * 4) + YearOfQuad;
   If (Cent <> 4) And (YearOfQuad <> 4) Then
    Inc(Year);
   Year      := FromZeroBase(CommonEra, Year);
   DayOfYear := Trunc(NormalizedJD - ToJulianDay(Year, 1, 1)) + 1;
   Result    := DayOfYearToDayOfMonth(CommonEra, Year, DayOfYear, Month, Day);
  End;

{ TGregorianCalendarSettings }

  Class Function TGregorianCalendarSettings.CalendarClass : TCalendarClass;

Begin
 Result := TGregorianCalendar;

End;

Initialization
 CalendarTypes.Register(TGregorianCalendar);

End.
