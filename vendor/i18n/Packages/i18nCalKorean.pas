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
/// This unit implements the Korean Tangun Era calendar.
/// </summary>
Unit i18nCalKorean;

{$I DELPHIAREA.INC}

Interface

 Uses
  SysUtils, i18nCalendar, i18nCalGregorian;

 Type

  {$Region 'xmldoc'}
  /// <summary>
  /// This class implements the Korean Tangun Era calendar.
  /// </summary>
  /// <remarks>
  /// <para>
  /// TKoreanCalendar provides properties and methods to manipulate dates in
  /// the Korean Tangun Era calendar as well as the Gregorian calendar.
  /// </para>
  /// <para>
  /// The Korean calendar is identical to the Gregorian calendar, except that years
  /// are counted from 2333 B.C.E. (regarded as year one).
  /// </para>
  /// <para>
  /// TKoreanCalendar supports both the Common Era (C.E.) and the Korean Tangun Era.
  /// </para>
  /// </remarks>
  {$Endregion}
  TKoreanCalendar = Class(TGregorianCalendar)
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// The difference between years in the Korean Era and the Common Era.
    /// </summary>
    {$Endregion}
    Const KOREAN_YEAR_OFFSET = -2333;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Specifies the index of the Korean Era.
    /// </summary>
    {$Endregion}
    Const KoreanEra = 2;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the unique identifier of the calendar.
    /// </summary>
    /// <returns>
    /// Returns <see cref="CAL_KOREA"/>.
    /// </returns>
    {$Endregion}
    Class Function CalendarID : Cardinal; Override;
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
    /// Returns the <see cref="TKoreanCalendarSettings"/> class.
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
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class provides locale-specific settings for the <see cref="TKoreanCalendar"/>
/// class.
/// </summary>
/// <remarks>
/// The TKoreanCalendarSettings class collects the Korean calendar's locale-specific
/// settings, which are required by the <see cref="TKoreanCalendar"/> class.
/// </remarks>
{$Endregion}

  TKoreanCalendarSettings = Class(TGregorianCalendarSettings)
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Sets <see cref="EraNames"/> and <see cref="ShortEraNames"/> properties for
    /// the specified era based on the given locale and calendar identifier.
    /// </summary>
    /// <param name="Era">
    /// The era for which the name properties should be set.
    /// </param>
    /// <param name="Locale">
    /// The locale of the name.
    /// </param>
    /// <param name="CalendarID">
    /// The identifier of the calendar system.
    /// </param>
    {$Endregion}
    Procedure PrepareEraName(Era : Integer; Const Locale : String; CalendarID : Cardinal); Override;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Determines the calendar system that this settings is provided for.
    /// </summary>
    /// <returns>
    /// Returns the <see cref="TKoreanCalendar"/> class.
    /// </returns>
    {$Endregion}
    Class Function CalendarClass : TCalendarClass; Override;
  End;

Implementation

 Uses
  Math, Types, i18nWinNLS;

{ TKoreanCalendar }

  Class Function TKoreanCalendar.CalendarID : Cardinal;

Begin
 Result := CAL_KOREA;

End;

  Class Function TKoreanCalendar.SettingsClass : TCalendarSettingsClass;

Begin
 Result := TKoreanCalendarSettings;

End;

  Class Function TKoreanCalendar.MaxEra : Integer;

Begin
 Result := KoreanEra;

End;

  Class Function TKoreanCalendar.MinSupportedDateTime : TDateTime;

Begin
 Result := Max({0001/01/01 Korean} -1545704.0, Inherited);

End;

  Class Function TKoreanCalendar.MaxSupportedDateTime : TDateTime;

Begin
 Result := Min({9999/12/31 Korean} 2106355.99999, Inherited);

End;

 Function TKoreanCalendar.ConvertYear(Year, FromEra, ToEra : Integer) : Integer;
  Begin
   If Year = 0 Then
    YearError(FromEra, 0)
   Else If FromEra <> ToEra Then
    Begin
     If FromEra = KoreanEra Then
      Year := OffsetYear(Year, +KOREAN_YEAR_OFFSET, FromEra, CommonEra)
     Else If FromEra <> CommonEra Then
      EraError(FromEra);
     If ToEra = KoreanEra Then
      Year := OffsetYear(Year, -KOREAN_YEAR_OFFSET, CommonEra, ToEra)
     Else If ToEra <> CommonEra Then
      EraError(ToEra);
    End
   Else If Not(FromEra In [CommonEra, KoreanEra]) Then
    EraError(FromEra);
   Result := Year;
  End;

{ TKoreanCalendarSettings }

  Class Function TKoreanCalendarSettings.CalendarClass : TCalendarClass;

Begin
 Result := TKoreanCalendar;

End;

 Procedure TKoreanCalendarSettings.PrepareEraName(Era : Integer; Const Locale : String; CalendarID : Cardinal);
  Begin
   If Era = TKoreanCalendar.CommonEra Then
    Inherited PrepareEraName(Era, Locale, CAL_GREGORIAN)
   Else
    Inherited PrepareEraName(Era, Locale, CalendarID);
  End;

Initialization
 CalendarTypes.Register(TKoreanCalendar, ['ko-KR']);

End.
