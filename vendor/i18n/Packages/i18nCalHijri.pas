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
/// This unit implements the base functionality of Hijri (or Islamic) calendar.
/// </summary>
Unit i18nCalHijri;

{$I DELPHIAREA.INC}

Interface

 Uses
  SysUtils, Classes, i18nCalendar;

 Type

  {$Region 'xmldoc'}
  /// <summary>
  /// THijriCalendarAdjustmentEvent is the type for event handlers that respond when
  /// a Hijri date needs to be adjusted.
  /// </summary>
  /// <param name="Sender">
  /// The object that generated the event.
  /// </param>
  /// <param name="JulianDay">
  /// The Julian day that is subject to the adjustment.
  /// </param>
  /// <param name="NumberOfDays">
  /// The number of days that should be added or subtracted from the Julian day
  /// to have a correct Hijri date. The handler must provide a value for this
  /// parameter.
  /// </param>
  {$Endregion}
  THijriCalendarAdjustmentEvent = Procedure(Sender : TObject; Const JulianDay : Extended; Var NumberOfDays : Integer) Of Object;

{$Region 'xmldoc'}
/// <summary>
/// This class implements the Hijri (or Islamic) calendar.
/// </summary>
/// <remarks>
/// <para>
/// THijriCalendar provides properties and methods to manipulate dates in
/// the Hijri calendar.
/// </para>
/// <para>
/// The Hijri (or Islamic) calendar is purely lunar and consists of twelve
/// alternating months of 30 and 29 days, with the final 29-day month extended
/// to 30 days during leap years. Leap years follow a 30-year cycle and occur
/// in years 1, 5, 7, 10, 13, 16, 18, 21, 24, 26, and 29. Days are considered
/// to begin at sunset. The calendar begins on Friday, July 16th, 622 C.E. in
/// the Julian calendar, Julian day 1948439.5, the day of Muhammad's flight
/// from Mecca to Medina, with sunset on the preceding day reckoned as the
/// first day of the first month of year 1 A.H. (Anno Hegirae). Days are
/// numbered with Saturday as day 1, through Friday as day 7.
/// </para>
/// <para>
/// Each cycle of 30 years thus contains 19 normal years of 354 days and 11
/// leap years of 355, so the average length of a year is therefore
/// <c>((19 x 354) + (11 x 355)) / 30 = 354.365</c> days, with a mean length
/// of month of 1/12 of this figure, or 29.53055 days, which closely approximates
/// the mean synodic month (time from new Moon to next new Moon) of 29.530588
/// days, with the calendar only slipping one day with respect to the Moon
/// every 2525 years. Since the calendar is fixed to the Moon, not the solar
/// year, the months shift with respect to the seasons, with each month beginning
/// about 11 days earlier in each successive solar year.
/// </para>
/// <para>
/// The calendar presented here is the most commonly used civil calendar in the
/// Islamic world; for religious purposes months are defined to start with the
/// first observation of the crescent of the new Moon.
/// </para>
/// <para>
/// NOTE: Both description and algorithm of this calendar are adapted from
/// http://www.fourmilab.ch/documents/calendar/.
/// </para>
/// </remarks>
{$Endregion}

  THijriCalendar = Class(TCalendar)
   Private
    fAdjustDays   : Integer;
    fOnAdjustment : THijriCalendarAdjustmentEvent;
    Procedure SetHijriAdjust(Value : Integer);
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// The start of the Hijri calendar in Julian days.
    /// </summary>
    {$Endregion}
    Const HIJRI_EPOCH = 1948439.5;
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts a Hijri date represented by its year, month and day
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
    /// Julian day of the specified Hijri date.
    /// </returns>
    /// <seealso cref="FromJulianDay"/>
    {$Endregion}
    Function ToJulianDay(Year, Month, Day : Integer) : Extended; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts a date expressed in Julian day, to its year, month, and day
    /// components in the Hijri calendar.
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
    {$Region 'xmldoc'}
    /// <summary>
    /// Adjusts a Julian day before or after being converted to or from a Hijri date.
    /// </summary>
    /// <param name="JD">
    /// The date expressed in Julian day.
    /// </param>
    /// <param name="Backward">
    /// Specifies the direction of the conversion. If <see langword="true"/>, the Julian day
    /// is being converted to a Hijri date; if <see langword="false"/>, the Julian day
    /// is the result of converting from a Hijri date.
    /// </param>
    /// <returns>
    /// Returns the adjusted Julian day.
    /// </returns>
    {$Endregion}
    Function AdjustJulianDay(Const JD : Extended; Backward : Boolean) : Extended; Override;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Specifies the index of the Hijri Era.
    /// </summary>
    {$Endregion}
    Const HijriEra = 1;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the unique identifier of the calendar.
    /// </summary>
    /// <returns>
    /// Returns <see cref="CAL_HIJRI"/>.
    /// </returns>
    {$Endregion}
    Class Function CalendarID : Cardinal; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the algorithm type of the calendar system.
    /// </summary>
    /// <returns>
    /// Returns <see cref="TCalendarKind"/> of ckLunar.
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
    /// Returns <see cref="THijriCalendarSettings"/> class.
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
    /// Returns 354 for normal and 355 for leap years.
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
    /// Copies the contents of another object to the current one.
    /// </summary>
    /// <param name="Source">
    /// The source object.
    /// </param>
    {$Endregion}
    Procedure Assign(Source : TPersistent); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the number of days to adjust the Hijri date.
    /// This property is ignored when the <see cref="OnAdjustment"/> event is set.
    /// </summary>
    {$Endregion}
    Property AdjustDays : Integer Read fAdjustDays Write SetHijriAdjust Default 0;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when a Julian day is about to be converted to a Hijri date or vice versa.
    /// </summary>
    {$Endregion}
    Property OnAdjustment : THijriCalendarAdjustmentEvent Read fOnAdjustment Write fOnAdjustment;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class provides locale specific settings for the <see cref="THijriCalendar"/>
/// class.
/// </summary>
/// <remarks>
/// THijriCalendarSettings class collects the Hijri calendar's locale specific
/// settings, which are required by the <see cref="THijriCalendar"/> class.
/// </remarks>
{$Endregion}

  THijriCalendarSettings = Class(TCalendarSettings)
   Protected
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
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Determines the calendar system that this settings is provided for.
    /// </summary>
    /// <returns>
    /// Returns <see cref="THijriCalendar"/> class.
    /// </returns>
    {$Endregion}
    Class Function CalendarClass : TCalendarClass; Override;
  End;

Implementation

 Uses
  Math, Types, i18nWinNLS;

{ THijriCalendar }

  Class Function THijriCalendar.CalendarID : Cardinal;

Begin
 Result := CAL_HIJRI;

End;

  Class Function THijriCalendar.CalendarKind : TCalendarKind;

Begin
 Result := ckLunar;

End;

  Class Function THijriCalendar.MinSupportedDateTime : TDateTime;

Begin
 Result := Max({0001/01/01 Hijri} -466579.0, Inherited);

End;

  Class Function THijriCalendar.MaxSupportedDateTime : TDateTime;

Begin
 Result := Min({9999/12/29 Hijri} 3076732.99999, Inherited);

End;

  Class Function THijriCalendar.SettingsClass : TCalendarSettingsClass;

Begin
 Result := THijriCalendarSettings;

End;

 Function THijriCalendar.IsLeapYear(Era, Year : Integer) : Boolean;
  Begin
   Year   := ConvertYear(Year, Era, HijriEra);
   Year   := ToZeroBase(HijriEra, Year);
   Result := Modulus(((Year * 11) + 14), 30) < 11;
  End;

 Function THijriCalendar.DaysInYear(Era : Integer; Year : Integer) : Integer;
  Begin
   If IsLeapYear(Era, Year) Then
    Result := 355
   Else
    Result := 354;
  End;

 Function THijriCalendar.DaysInMonth(Era : Integer; Year : Integer; Month : Integer) : Integer;
  Begin
   If (Month < 1) Or (Month > 12) Then
    MonthError(Era, Year, Month);
   If Odd(Month) Or ((Month = 12) And IsLeapYear(Era, Year)) Then
    Result := 30
   Else
    Result := 29;
  End;

 Function THijriCalendar.ToJulianDay(Year, Month, Day : Integer) : Extended;
  Begin
   Year   := ToZeroBase(HijriEra, Year);
   Result := HIJRI_EPOCH +
   +(Year - 1) * 354 + Floor((3 + (11 * Year)) / 30)
   + (29 * (Month - 1)) + (Month Div 2) + (Day - 1);
  End;

 Function THijriCalendar.FromJulianDay(Const JD : Extended; Out Year, Month, Day : Integer) : Boolean;
  Var
   NormalizedJD : Extended;
   YearDay      : Integer;
  Begin
   NormalizedJD := Trunc(JD - 0.5) + 0.5;
   Year         := Floor((30 * (NormalizedJD - HIJRI_EPOCH) + 10646) / 10631);
   Year         := FromZeroBase(HijriEra, Year);
   YearDay      := Trunc(NormalizedJD - ToJulianDay(Year, 1, 1)) + 1;
   Result       := DayOfYearToDayOfMonth(HijriEra, Year, YearDay, Month, Day);
  End;

 Function THijriCalendar.AdjustJulianDay(Const JD : Extended; Backward : Boolean) : Extended;
  Var
   NumberOfDays : Integer;
  Begin
   NumberOfDays := AdjustDays;
   If Assigned(OnAdjustment) Then
    OnAdjustment(Self, JD, NumberOfDays);
   If Backward Then
    Result := JD - NumberOfDays
   Else
    Result := JD + NumberOfDays;
  End;

 Procedure THijriCalendar.SetHijriAdjust(Value : Integer);
  Begin
   If AdjustDays <> Value Then
    Begin
     fAdjustDays := Value;
     DoChange;
    End;
  End;

 Procedure THijriCalendar.Assign(Source : TPersistent);
  Begin
   If Source Is THijriCalendar Then
    AdjustDays := THijriCalendar(Source).AdjustDays;
   Inherited Assign(Source);
  End;

{ THijriCalendarSettings }

  Class Function THijriCalendarSettings.CalendarClass : TCalendarClass;

Begin
 Result := THijriCalendar;

End;

 Procedure THijriCalendarSettings.PrepareMonthNames(Const Locale : String; CalendarID : Cardinal);
  Const
   EnglishMonthNames : Array[1..12] Of String = (
   'Muharram', 'Safar', 'Rabi`al-Awwal', 'Rabi`ath-Thani',
   'Jumada l-Ula', 'Jumada t-Tania', 'Rajab', 'Sha`ban',
   'Ramadan', 'Shawwal', 'Dhu l-Qa`da', 'Dhu l-Hijja');
  Var
   m             : Integer;
   LocaleScripts : String;
  Begin
   LocaleScripts := GetLocaleScripts(Locale);
   If (Pos('Arab;', LocaleScripts) <> 0) Or (Pos('Thaa;', LocaleScripts) <> 0) Then
    Inherited PrepareMonthNames(Locale, CalendarID)
   Else
    Begin
     For m := 1 To 12 Do
      Begin
       MonthNames[m]         := EnglishMonthNames[m];
       ShortMonthNames[m]    := EnglishMonthNames[m];
       GenitiveMonthNames[m] := EnglishMonthNames[m];
      End;
    End;
  End;

Initialization
 CalendarTypes.Register(THijriCalendar, ['ar', 'ur-PK', 'dv-MV']);

End.
