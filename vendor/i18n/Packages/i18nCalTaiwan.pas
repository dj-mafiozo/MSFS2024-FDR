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
/// This unit implements the Taiwan calendar.
/// </summary>
Unit i18nCalTaiwan;

{$I DELPHIAREA.INC}

Interface

 Uses
  SysUtils, i18nCalendar, i18nCalGregorian;

 Type

  {$Region 'xmldoc'}
  /// <summary>
  /// This class implements the Taiwan calendar.
  /// </summary>
  /// <remarks>
  /// <para>
  /// TTaiwanCalendar provides properties and methods to manipulate dates in
  /// the Taiwan calendar as well as the Gregorian calendar.
  /// </para>
  /// <para>
  /// The Taiwan calendar is identical to Gregorian calendar, except that years
  /// are counted from 1911 C.E. (regarded as year one).
  /// </para>
  /// <para>
  /// TTaiwanCalendar supports both Common Era (C.E.) and Taiwan Era.
  /// </para>
  /// </remarks>
  {$Endregion}
  TTaiwanCalendar = Class(TGregorianCalendar)
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// The difference between years in Taiwan Era and Common Era.
    /// </summary>
    {$Endregion}
    Const TAIWAN_YEAR_OFFSET = 1911;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Specifies index of Taiwan Era.
    /// </summary>
    {$Endregion}
    Const TaiwanEra = 2;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the unique identifier of the calendar.
    /// </summary>
    /// <returns>
    /// Returns <see cref="CAL_TAIWAN"/>.
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
    /// Returns the <see cref="TCalendarSettings"/> class that provides locale
    /// specific settings for the calendar.
    /// </summary>
    /// <returns>
    /// Returns <see cref="TTaiwanCalendarSettings"/> class.
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
/// This class provides locale specific settings for the <see cref="TTaiwanCalendar"/>
/// class.
/// </summary>
/// <remarks>
/// TTaiwanCalendarSettings class collects the Taiwan calendar's locale specific
/// settings, which are required by the <see cref="TTaiwanCalendar"/> class.
/// </remarks>
{$Endregion}

  TTaiwanCalendarSettings = Class(TGregorianCalendarSettings)
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Sets <see cref="EraNames"/> and <see cref="ShortEraNames"/> properties for
    /// the specified era based on the given locale and calendar identifier.
    /// </summary>
    /// <param name="Era">
    /// The era that its name properties should be set.
    /// </param>
    /// <param name="Locale">
    /// The locale of the name.
    /// </param>
    /// <param name="CalendarID">
    /// The identifier of calendar system.
    /// </param>
    {$Endregion}
    Procedure PrepareEraName(Era : Integer; Const Locale : String; CalendarID : Cardinal); Override;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Determines the calendar system that this settings is provided for.
    /// </summary>
    /// <returns>
    /// Returns <see cref="TTaiwanCalendar"/> class.
    /// </returns>
    {$Endregion}
    Class Function CalendarClass : TCalendarClass; Override;
  End;

Implementation

 Uses
  Math, Types, i18nWinNLS, Windows;

{ TTaiwanCalendar }

  Class Function TTaiwanCalendar.CalendarID : Cardinal;

Begin
 Result := CAL_TAIWAN;

End;

  Class Function TTaiwanCalendar.SettingsClass : TCalendarSettingsClass;

Begin
 Result := TTaiwanCalendarSettings;

End;

  Class Function TTaiwanCalendar.MaxEra : Integer;

Begin
 Result := TaiwanEra;

End;

  Class Function TTaiwanCalendar.MinSupportedDateTime : TDateTime;

Begin
 Result := Max({0001/01/01 Taiwan} 4384.0, Inherited);

End;

  Class Function TTaiwanCalendar.MaxSupportedDateTime : TDateTime;

Begin
 Result := Min({9999/12/31 Taiwan} 3656443.99999, Inherited);

End;

 Function TTaiwanCalendar.ConvertYear(Year, FromEra, ToEra : Integer) : Integer;
  Begin
   If Year = 0 Then
    YearError(FromEra, 0)
   Else If FromEra <> ToEra Then
    Begin
     If FromEra = TaiwanEra Then
      Year := OffsetYear(Year, +TAIWAN_YEAR_OFFSET, FromEra, CommonEra)
     Else If FromEra <> CommonEra Then
      EraError(FromEra);
     If ToEra = TaiwanEra Then
      Year := OffsetYear(Year, -TAIWAN_YEAR_OFFSET, CommonEra, ToEra)
     Else If ToEra <> CommonEra Then
      EraError(ToEra);
    End
   Else If Not(FromEra In [CommonEra, TaiwanEra]) Then
    EraError(FromEra);
   Result := Year;
  End;

{ TTaiwanCalendarSettings }

  Class Function TTaiwanCalendarSettings.CalendarClass : TCalendarClass;

Begin
 Result := TTaiwanCalendar;

End;

 Procedure TTaiwanCalendarSettings.PrepareEraName(Era : Integer; Const Locale : String; CalendarID : Cardinal);
  Begin
   If Era = TTaiwanCalendar.CommonEra Then
    Inherited PrepareEraName(Era, Locale, CAL_GREGORIAN)
   Else
    Inherited PrepareEraName(Era, Locale, CalendarID);
  End;

Initialization
 CalendarTypes.Register(TTaiwanCalendar, ['zh-TW']);

End.
