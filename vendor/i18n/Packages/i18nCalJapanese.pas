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
/// This unit implements the Japanese Emperor Era calendar.
/// </summary>
Unit i18nCalJapanese;

{$I DELPHIAREA.INC}

Interface

 Uses
  SysUtils, i18nCalendar, i18nCalGregorian;

 Type

  {$Region 'xmldoc'}
  /// <summary>
  /// This class implements the Japanese Emperor Era calendar.
  /// </summary>
  /// <remarks>
  /// <para>
  /// TJapaneseCalendar provides properties and methods to manipulate dates in
  /// the Japanese Emperor Era calendar as well as the Gregorian calendar.
  /// </para>
  /// <para>
  /// The Japanese era calendar scheme is a common calendar scheme used in Japan,
  /// which identifies a year by the combination of the Japanese era name and the
  /// year number within the era. For example, the year 2011 is Heisei 23.
  /// </para>
  /// <para>
  /// This calendar supports Common Era (C.E.) as well as Japanese Emperor Eras.
  /// </para>
  /// </remarks>
  {$Endregion}
  TJapaneseCalendar = Class(TGregorianCalendar)
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the era that contains the specified year expressed in Common Era.
    /// If the value of <see cref="DefaultEra"/> is
    /// <see cref="CommonEra"/>, this method returns <see cref="CommonEra"/>
    /// regardless.
    /// </summary>
    /// <param name="Year">
    /// The year expressed in Common Era.
    /// </param>
    /// <returns>
    /// The best era for expressing the year.
    /// </returns>
    {$Endregion}
    Function BestEraOfBaseEraYear(Year : Integer) : Integer; Override;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Specifies index of Meiji Era.
    /// </summary>
    {$Endregion}
    Const MeijiEra = 2;
    {$Region 'xmldoc'}
    /// <summary>
    /// Specifies index of Taisho Era.
    /// </summary>
    {$Endregion}
    Const TaishoEra = 3;
    {$Region 'xmldoc'}
    /// <summary>
    /// Specifies index of Showa Era.
    /// </summary>
    {$Endregion}
    Const ShowaEra = 4;
    {$Region 'xmldoc'}
    /// <summary>
    /// Specifies index of Heisei Era.
    /// </summary>
    {$Endregion}
    Const HeiseiEra = 5;
    {$Region 'xmldoc'}
    /// <summary>
    /// Specifies index of Reiwa Era.
    /// </summary>
    {$Endregion}
    Const ReiwaEra = 6;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the unique identifier of the calendar.
    /// </summary>
    /// <returns>
    /// Returns <see cref="CAL_JAPAN"/>.
    /// </returns>
    {$Endregion}
    Class Function CalendarID : Cardinal; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the number of eras that the calendar class supports.
    /// </summary>
    /// <returns>
    /// The maximum number of eras.
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
    /// Returns <see cref="TJapaneseCalendarSettings"/> class.
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
    Function StartOfEra(Era : Integer) : TDateTime; Override;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class provides locale specific settings for the <see cref="TJapaneseCalendar"/>
/// class.
/// </summary>
/// <remarks>
/// <para>
/// TJapaneseCalendarSettings class collects the Japanese calendar's locale specific
/// settings, which are required by the <see cref="TJapaneseCalendar"/> class.
/// </para>
/// </remarks>
{$Endregion}

  TJapaneseCalendarSettings = Class(TGregorianCalendarSettings)
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
    /// The identifier of calendar system.
    /// </param>
    {$Endregion}
    Procedure PrepareEraName(Era : Integer; Const Locale : String; CalendarID : Cardinal); Override;
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
    Procedure PrepareDateFormats(Const Locale : String; CalendarID : Cardinal); Override;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Determines the calendar system that this settings is provided for.
    /// </summary>
    /// <returns>
    /// Returns <see cref="TJapaneseCalendar"/> class.
    /// </returns>
    {$Endregion}
    Class Function CalendarClass : TCalendarClass; Override;
  End;

Implementation

 Uses
  Math, Types, i18nWinNLS, Windows, Registry, Classes;

{ Japanese Eras }

 Type
  // Stores information about a single Japanese era.
  TJapaneseEraInfo = Record
   Start            : TDateYMD;
   StartDate        : TDate;
   NativeName       : String;
   ShortNativeName  : String;
   EnglishName      : String;
   ShortEnglishName : String;
  End;

 Var
  // Stores minimum supported TDateTime value for Japanese calendar.
  JapaneseMinDateTime : TDateTime;
// Stores maximum supported TDateTime value for Japanese calendar.
  JapaneseMaxDateTime : TDateTime;
// Lists information about the Japanese eras.
  JapaneseEraInfo : Array Of TJapaneseEraInfo;

 Procedure ExtractJapaneseEras(Info : TStrings);
  Var
   i   : Integer;
   s   : PChar;
   e   : PChar;
   Num : String;
  Begin
   SetLength(JapaneseEraInfo, Info.Count);
   For i := 0 To Info.Count - 1 Do
    Begin
     s := PChar(Info[i]);
     With JapaneseEraInfo[i] Do
      Begin
       // Start.Year
       e := StrScan(s, ' ');
       SetString(Num, s, e - s);
       Start.Year := StrToInt(Num);
       s          := e + 1;
       // Start.Month
       e := StrScan(s, ' ');
       SetString(Num, s, e - s);
       Start.Month := StrToInt(Num);
       s           := e + 1;
       // Start.Day
       e := StrScan(s, '=');
       SetString(Num, s, e - s);
       Start.Day := StrToInt(Num);
       s         := e + 1;
       // NativeName
       e := StrScan(s, '_');
       SetString(NativeName, s, e - s);
       s := e + 1;
       // ShortNativeName
       e := StrScan(s, '_');
       SetString(ShortNativeName, s, e - s);
       s := e + 1;
       // EnglishName
       e := StrScan(s, '_');
       SetString(EnglishName, s, e - s);
       s := e + 1;
       // ShortEnglishName
       SetString(ShortEnglishName, s, StrLen(s));
      End;
    End;
  End;

 Procedure GetJapaneseErasFromKnownInfo;
  Const
   KnownInfo = '1868 01 01=明治_明_Meiji_M' + #13#10
   + '1912 07 30=大正_大_Taisho_T' + #13#10
   + '1926 12 25=昭和_昭_Showa_S' + #13#10
   + '1989 01 08=平成_平_Heisei_H' + #13#10
   + '2019 05 01=令和_令_Reiwa_R';
  Var
   Info : TStrings;
  Begin
   Info := TStringList.Create;
   Try
    Info.Text := KnownInfo;
    ExtractJapaneseEras(Info);
   Finally
    Info.Free;
   End;
  End;

 Function GetJapaneseErasFromRegistry : Boolean;
  Const
   ErasKey = '\SYSTEM\CurrentControlSet\Control\Nls\Calendars\Japanese\Eras';
  Var
   r    : TRegistry;
   Info : TStrings;
   i    : Integer;
  Begin
   Result := False;
   Try
    r := TRegistry.Create(KEY_QUERY_VALUE);
    Try
     r.RootKey := HKEY_LOCAL_MACHINE;
     If r.OpenKeyReadOnly(ErasKey) Then
      Begin
       Info := TStringList.Create;
       Try
        r.GetValueNames(Info);
        For i    := 0 To Info.Count - 1 Do
         Info[i] := Info[i] + '=' + r.ReadString(Info[i]);
        ExtractJapaneseEras(Info);
        Result := (Info.Count <> 0);
       Finally
        Info.Free;
       End;
      End;
    Finally
     r.Free;
    End;
   Except
    Result := False;
   End;
  End;

 Procedure InitializeJapaneseEraInfo;
  Var
   i : Integer;
  Begin
   If Not GetJapaneseErasFromRegistry Then
    GetJapaneseErasFromKnownInfo;
   For i := 0 To Length(JapaneseEraInfo) - 1 Do
    With JapaneseEraInfo[i] Do
     StartDate         := EncodeDate(Start.Year, Start.Month, Start.Day);
   JapaneseMinDateTime := JapaneseEraInfo[0].StartDate;
   With JapaneseEraInfo[Length(JapaneseEraInfo) - 1].Start Do
    JapaneseMaxDateTime := EncodeDate(Year + 99, 1, 1) - 0.00001;
  End;

 Procedure FinalizeJapaneseEraInfo;
  Begin
   SetLength(JapaneseEraInfo, 0);
  End;

{ TJapaneseCalendar }

  Class Function TJapaneseCalendar.CalendarID : Cardinal;

Begin
 Result := CAL_JAPAN;

End;

  Class Function TJapaneseCalendar.SettingsClass : TCalendarSettingsClass;

Begin
 Result := TJapaneseCalendarSettings;

End;

  Class Function TJapaneseCalendar.MaxEra : Integer;

Begin
 Result := Length(JapaneseEraInfo) + CommonEra;

End;

  Class Function TJapaneseCalendar.MinSupportedDateTime : TDateTime;

Begin
 Result := Max(JapaneseMinDateTime, Inherited);

End;

  Class Function TJapaneseCalendar.MaxSupportedDateTime : TDateTime;

Begin
 Result := Min(JapaneseMaxDateTime, Inherited);

End;

 Function TJapaneseCalendar.ConvertYear(Year, FromEra, ToEra : Integer) : Integer;
  Begin
   If Year = 0 Then
    YearError(FromEra, Year)
   Else If FromEra <> ToEra Then
    Begin
     If (FromEra > CommonEra) And (FromEra <= MaxEra) Then
      Year := OffsetYear(Year, +(JapaneseEraInfo[FromEra - 2].Start.Year - 1), FromEra, CommonEra)
     Else If FromEra <> CommonEra Then
      EraError(FromEra);
     If (ToEra > CommonEra) And (ToEra <= MaxEra) Then
      Year := OffsetYear(Year, -(JapaneseEraInfo[ToEra - 2].Start.Year - 1), CommonEra, ToEra)
     Else If ToEra <> CommonEra Then
      EraError(FromEra);
    End
   Else If (FromEra < CommonEra) Or (FromEra > MaxEra) Then
    EraError(FromEra);
   Result := Year;
  End;

 Function TJapaneseCalendar.StartOfEra(Era : Integer) : TDateTime;
  Begin
   If (Era > CommonEra) And (Era <= MaxEra) Then
    Result := JapaneseEraInfo[Era - 2].StartDate
   Else
    Result := Inherited StartOfEra(Era);
  End;

 Function TJapaneseCalendar.BestEraOfBaseEraYear(Year : Integer) : Integer;
  Var
   i : Integer;
  Begin
   If DefaultEra = CommonEra Then
    Result := Inherited BestEraOfBaseEraYear(Year)
   Else
    Begin
     For i := Length(JapaneseEraInfo) - 1 Downto 1 Do
      If Year >= JapaneseEraInfo[i].Start.Year Then
       Begin
        Result := i + 2;
        Exit;
       End;
     Result := MeijiEra;
    End;
  End;

{ TJapaneseCalendarSettings }

  Class Function TJapaneseCalendarSettings.CalendarClass : TCalendarClass;

Begin
 Result := TJapaneseCalendar;

End;

 Procedure TJapaneseCalendarSettings.PrepareEraName(Era : Integer; Const Locale : String; CalendarID : Cardinal);
  Begin
   If Era = TJapaneseCalendar.CommonEra Then
    Inherited PrepareEraName(Era, Locale, CAL_GREGORIAN)
   Else
    Begin
     If Pos('Jpan;', GetLocaleScripts(Locale)) <> 0 Then
      Begin
       EraNames[Era]      := JapaneseEraInfo[Era - 2].NativeName;
       ShortEraNames[Era] := JapaneseEraInfo[Era - 2].ShortNativeName
      End
     Else
      Begin
       EraNames[Era]      := JapaneseEraInfo[Era - 2].EnglishName;
       ShortEraNames[Era] := JapaneseEraInfo[Era - 2].ShortEnglishName;
      End;
    End;
  End;

 Procedure TJapaneseCalendarSettings.PrepareDateFormats(Const Locale : String; CalendarID : Cardinal);
  Begin
   If SameText(Locale, 'ja-JP') Then
    Inherited PrepareDateFormats(Locale, CalendarID)
   Else
    Begin
     LongDateFormat  := 'gg y, MMMM d';
     ShortDateFormat := 'gg y/M/d';
     YearMonthFormat := 'gg y, MMMM';
     MonthDayFormat  := 'MMMM, d';
    End;
   YearFormat := 'gg y';
  End;

Initialization
 InitializeJapaneseEraInfo;
 CalendarTypes.Register(TJapaneseCalendar, ['ja-JP']);

Finalization
 FinalizeJapaneseEraInfo;

End.
