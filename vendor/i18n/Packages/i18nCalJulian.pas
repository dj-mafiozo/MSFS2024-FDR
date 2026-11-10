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
/// This unit implements the Julian calendar.
/// </summary>
Unit i18nCalJulian;

{$I DELPHIAREA.INC}

Interface

 Uses
  SysUtils, i18nCalendar;

 Type

  {$Region 'xmldoc'}
  /// <summary>
  /// This class implements the Julian calendar.
  /// </summary>
  /// <remarks>
  /// <para>
  /// TJulianCalendar provides properties and methods to manipulate dates in
  /// the Julian calendar.
  /// </para>
  /// <para>
  /// The Julian calendar was proclaimed by Julius Caesar in 46 B.C. and underwent
  /// several modifications before reaching its final form in 8 C.E. The Julian
  /// calendar differs from the Gregorian only in the determination of leap years,
  /// lacking the correction for years divisible by 100 and 400 in the Gregorian
  /// calendar. In the Julian calendar, any positive year is a leap year if
  /// divisible by 4. (Negative years are leap years if the absolute value divided
  /// by 4 yields a remainder of 1.) Days are considered to begin at midnight.
  /// </para>
  /// <para>
  /// In the Julian calendar the average year has a length of 365.25 days compared
  /// to the actual solar tropical year of 365.24219878 days. The calendar thus
  /// accumulates one day of error with respect to the solar year every 128 years.
  /// Being a purely solar calendar, no attempt is made to synchronise the start of
  /// months to the phases of the Moon.
  /// </para>
  /// <para>
  /// NOTE: Both the description and algorithm of this calendar are adapted from
  /// http://www.fourmilab.ch/documents/calendar/.
  /// </para>
  /// </remarks>
  {$Endregion}
  TJulianCalendar = Class(TCalendar)
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts a Julian date represented by its year, month, and day
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
    /// The Julian day of the specified Julian date.
    /// </returns>
    /// <seealso cref="FromJulianDay" />
    {$Endregion}
    Function ToJulianDay(Year, Month, Day : Integer) : Extended; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts a date expressed in Julian day to its year, month, and day
    /// components in the Julian calendar.
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
    /// Returns <see langword="true" /> if the function is successful; otherwise,
    /// returns <see langword="false" />.
    /// </returns>
    /// <seealso cref="ToJulianDay" />
    {$Endregion}
    Function FromJulianDay(Const JD : Extended; Out Year, Month, Day : Integer) : Boolean; Override;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Specifies the index of the Julian Era.
    /// </summary>
    {$Endregion}
    Const JulianEra = 1;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the algorithm type of the calendar system.
    /// </summary>
    /// <returns>
    /// Returns <see cref="TCalendarKind" /> of ckSolar.
    /// </returns>
    {$Endregion}
    Class Function CalendarKind : TCalendarKind; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the minimum <see cref="TDateTime" /> value that can be managed by
    /// the calendar.
    /// </summary>
    /// <returns>
    /// The minimum supported <see cref="TDateTime" /> value.
    /// </returns>
    /// <seealso cref="MaxSupportedDateTime" />
    {$Endregion}
    Class Function MinSupportedDateTime : TDateTime; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the maximum <see cref="TDateTime" /> value that can be managed by
    /// the calendar.
    /// </summary>
    /// <returns>
    /// The maximum supported <see cref="TDateTime" /> value.
    /// </returns>
    /// <seealso cref="MinSupportedDateTime" />
    {$Endregion}
    Class Function MaxSupportedDateTime : TDateTime; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the <see cref="TCalendarSettings" /> class that provides locale-
    /// specific settings for the calendar.
    /// </summary>
    /// <returns>
    /// Returns the <see cref="TJulianCalendarSettings" /> class.
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
    /// Returns <see langword="true" /> if the year is a leap year; otherwise,
    /// returns <see langword="false" />.
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
    /// Returns 365 for normal years and 366 for leap years.
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
    /// Returns the number of days from the beginning of a specified year to the beginning
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
    /// The number of days between the start of the year and the start of the month.
    /// </returns>
    {$Endregion}
    Function DaysToMonth(Era, Year, Month : Integer) : Integer; Override;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class provides locale-specific settings for the <see cref="TJulianCalendar" />
/// class.
/// </summary>
/// <remarks>
/// <para>
/// The TJulianCalendarSettings class collects the Julian calendar's locale-specific
/// settings, which are required by the <see cref="TJulianCalendar" /> class.
/// </para>
/// </remarks>
{$Endregion}

  TJulianCalendarSettings = Class(TCalendarSettings)
   Protected
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
    /// Determines the calendar system that this settings class is provided for.
    /// </summary>
    /// <returns>
    /// Returns the <see cref="TJulianCalendar" /> class.
    /// </returns>
    {$Endregion}
    Class Function CalendarClass : TCalendarClass; Override;
  End;

Implementation

 Uses
  Math, Types, i18nWinNLS;

{ TJulianCalendar }

  Class Function TJulianCalendar.CalendarKind : TCalendarKind;

Begin
 Result := ckSolar;

End;

  Class Function TJulianCalendar.MinSupportedDateTime : TDateTime;

Begin
 Result := Max({0001/01/01} -693595, Inherited);

End;

  Class Function TJulianCalendar.MaxSupportedDateTime : TDateTime;

Begin
 Result := Min({9999/12/31} 2958538.99999, Inherited);

End;

  Class Function TJulianCalendar.SettingsClass : TCalendarSettingsClass;

Begin
 Result := TJulianCalendarSettings;

End;

 Function TJulianCalendar.IsLeapYear(Era, Year : Integer) : Boolean;
  Begin
   Year := ConvertYear(Year, Era, JulianEra);
   Year := ToZeroBase(JulianEra, Year);
   If Year > 0 Then
    Result := ((Year Mod 4) = 0)
   Else
    Result := ((Year Mod 4) = -3);
  End;

 Function TJulianCalendar.DaysInYear(Era, Year : Integer) : Integer;
  Begin
   If IsLeapYear(Era, Year) Then
    Result := 366
   Else
    Result := 365;
  End;

 Function TJulianCalendar.DaysInMonth(Era, Year, Month : Integer) : Integer;
  Const
   Days : Array[Boolean] Of TDayTable =
   ((31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31),
   (31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31));
  Begin
   If (Month < 1) Or (Month > 12) Then
    MonthError(Era, Year, Month);
   Result := Days[IsLeapYear(Era, Year)][Month];
  End;

 Function TJulianCalendar.DaysToMonth(Era, Year, Month : Integer) : Integer;
  Const
   Days : Array[Boolean] Of TDayTable =
   ((0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334),
   (0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335));
  Begin
   If (Month < 1) Or (Month > 12) Then
    MonthError(Era, Year, Month);
   Result := Days[IsLeapYear(Era, Year)][Month];
  End;

 Function TJulianCalendar.ToJulianDay(Year, Month, Day : Integer) : Extended;
  Begin
   Year := ToZeroBase(JulianEra, Year);
   If Month <= 2 Then
    Begin
     Dec(Year);
     Inc(Month, 12);
    End;
   Result := Floor(365.25 * (Year + 4716))
   + Floor(30.6001 * (Month + 1)) + Day - 1524.5;
  End;

 Function TJulianCalendar.FromJulianDay(Const JD : Extended; Out Year, Month, Day : Integer) : Boolean;
  Var
   NormalizedJD : Extended;
   a            : Extended;
   b            : Extended;
   c            : Extended;
   d            : Extended;
   e            : Extended;
  Begin
   NormalizedJD := Trunc(JD - 0.5) + 0.5;
   a            := NormalizedJD + 0.5;
   b            := a + 1524;
   c            := Floor((b - 122.1) / 365.25);
   d            := Floor(365.25 * c);
   e            := Floor((b - d) / 30.6001);
   Day          := Trunc(b - d - Floor(30.6001 * e));
   Month        := Trunc(e - 1);
   If Month > 12 Then
    Dec(Month, 12);
   Year := Trunc(c - 4715);
   If Month > 2 Then
    Dec(Year);
   Year   := FromZeroBase(JulianEra, Year);
   Result := IsValidDay(JulianEra, Year, Month, Day);
  End;

{ TJulianCalendarSettings }

  Class Function TJulianCalendarSettings.CalendarClass : TCalendarClass;

Begin
 Result := TJulianCalendar;

End;

 Procedure TJulianCalendarSettings.PrepareSettings(Const Locale : String; CalendarID : Cardinal);
  Begin
   Inherited PrepareSettings(Locale, CAL_GREGORIAN);
   CalendarName := TJulianCalendar.CalendarName;
  End;

Initialization
 CalendarTypes.Register(TJulianCalendar);

End.
