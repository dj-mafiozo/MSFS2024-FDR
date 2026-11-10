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
/// This unit is somehow a workaround for bugs and backward incompatibility
/// issues of functions introduced in <c>winnls.h</c> header file of Windows SDK.
/// </summary>
/// <remarks>
/// This unit is not a complete Delphi translation of constants, data types,
/// and functions that are declared in <c>winnls.h</c> header file.
/// </remarks>
Unit i18nWinNLS;

{$I DELPHIAREA.INC}

Interface

 Uses
  Windows, SysUtils, Types;

 Type
  LOCALETYPE = DWORD;

 Const
  LOCALE_ALL             = $00000000; // enumerate all named based locales
  LOCALE_WINDOWS         = $00000001; // shipped locales and/or replacements for them
  LOCALE_SUPPLEMENTAL    = $00000002; // supplemental locales only
  LOCALE_ALTERNATE_SORTS = $00000004; // alternate sort locales
  LOCALE_NEUTRALDATA     = $00000010; // Locales that are "neutral" (language only, region data is default)
  LOCALE_SPECIFICDATA    = $00000020; // Locales that contain language and region data

 Type
  LCTYPE = DWORD;

 Const
  { Modifiers }
  LOCALE_RETURN_NUMBER = $20000000;
// WINVER >= 0x0601
  LOCALE_RETURN_GENITIVE_NAMES = $10000000;
  LOCALE_ALLOW_NEUTRAL_NAMES   = $08000000;
{ Information }
  LOCALE_IGEOID = $0000005B;
// WINVER >= 0x0500
  LOCALE_IDEFAULTEBCDICCODEPAGE = $00001012;
  LOCALE_IPAPERSIZE             = $0000100A;
  LOCALE_SENGCURRNAME           = $00001007;
  LOCALE_SNATIVECURRNAME        = $00001008;
  LOCALE_SYEARMONTH             = $00001006;
  LOCALE_SSORTNAME              = $00001013;
  LOCALE_IDIGITSUBSTITUTION     = $00001014;
// WINVER >= 0x0600
  LOCALE_SNAME                = $0000005C;
  LOCALE_SDURATION            = $0000005D;
  LOCALE_SKEYBOARDSTOINSTALL  = $0000005E;
  LOCALE_SSHORTESTDAYNAME1    = $00000060;
  LOCALE_SSHORTESTDAYNAME2    = $00000061;
  LOCALE_SSHORTESTDAYNAME3    = $00000062;
  LOCALE_SSHORTESTDAYNAME4    = $00000063;
  LOCALE_SSHORTESTDAYNAME5    = $00000064;
  LOCALE_SSHORTESTDAYNAME6    = $00000065;
  LOCALE_SSHORTESTDAYNAME7    = $00000066;
  LOCALE_SISO639LANGNAME2     = $00000067;
  LOCALE_SISO3166CTRYNAME2    = $00000068;
  LOCALE_SNAN                 = $00000069;
  LOCALE_SPOSINFINITY         = $0000006A;
  LOCALE_SNEGINFINITY         = $0000006B;
  LOCALE_SSCRIPTS             = $0000006C;
  LOCALE_SPARENT              = $0000006D;
  LOCALE_SCONSOLEFALLBACKNAME = $0000006E;
  LOCALE_SLANGDISPLAYNAME     = $0000006F;
// WINVER >= 0x0700
  LOCALE_IREADINGLAYOUT       = $00000070;
  LOCALE_INEUTRAL             = $00000071;
  LOCALE_INEGATIVEPERCENT     = $00000074;
  LOCALE_IPOSITIVEPERCENT     = $00000075;
  LOCALE_SPERCENT             = $00000076;
  LOCALE_SPERMILLE            = $00000077;
  LOCALE_SMONTHDAY            = $00000078;
  LOCALE_SSHORTTIME           = $00000079;
  LOCALE_SOPENTYPELANGUAGETAG = $0000007A;
  LOCALE_SSORTLOCALE          = $0000007B;
// New locale information types
  LOCALE_SLOCALIZEDDISPLAYNAME = $00000002;
// WINVER >= 0x0601
  LOCALE_SENGLISHDISPLAYNAME = $00000072;
  LOCALE_SNATIVEDISPLAYNAME  = $00000073;
// WINVER >= 0x0600
  LOCALE_SLOCALIZEDLANGUAGENAME = $0000006F;
// Renamed information types
  LOCALE_SENGLISHLANGUAGENAME  = $00001001;
  LOCALE_SNATIVELANGUAGENAME   = $00000004;
  LOCALE_SLOCALIZEDCOUNTRYNAME = $00000006;
  LOCALE_SENGLISHCOUNTRYNAME   = $00001002;
  LOCALE_SNATIVECOUNTRYNAME    = $00000008;

 Type
  CALID = DWORD;

 Const
  CAL_GREGORIAN              = 1;  // Gregorian (localized)
  CAL_GREGORIAN_US           = 2;  //	Gregorian (English strings always)
  CAL_JAPAN                  = 3;  // Japanese Emperor Era
  CAL_TAIWAN                 = 4;  //	Taiwan calendar
  CAL_KOREA                  = 5;  // Korean Tangun Era
  CAL_HIJRI                  = 6;  // Hijri (Arabic Lunar)
  CAL_THAI                   = 7;  // Thai
  CAL_HEBREW                 = 8;  // Hebrew (Lunar)
  CAL_GREGORIAN_ME_FRENCH    = 9;  // Gregorian Middle East French
  CAL_GREGORIAN_ARABIC       = 10; //	Gregorian Arabic
  CAL_GREGORIAN_XLIT_ENGLISH = 11; // Gregorian transliterated English
  CAL_GREGORIAN_XLIT_FRENCH  = 12; // Gregorian transliterated French
  CAL_PERSIAN                = 22; // Maybe versions of Windows after Windows 7: Persian calendar
  CAL_UMALQURA               = 23; // Windows Vista and later: Um Al Qura (Arabic lunar) calendar

 Type
  CALTYPE = DWORD;

 Const
  { Modifiers }
  CAL_RETURN_NUMBER = LOCALE_RETURN_NUMBER;
// WinVer >= $0601
  CAL_RETURN_GENITIVE_NAMES = LOCALE_RETURN_GENITIVE_NAMES;
{ Information }
// WinVer >= $0500
  CAL_SYEARMONTH       = $0000002F;
  CAL_ITWODIGITYEARMAX = $00000030;
// WINVER >= $0600
  CAL_SSHORTESTDAYNAME1 = $00000031;
  CAL_SSHORTESTDAYNAME2 = $00000032;
  CAL_SSHORTESTDAYNAME3 = $00000033;
  CAL_SSHORTESTDAYNAME4 = $00000034;
  CAL_SSHORTESTDAYNAME5 = $00000035;
  CAL_SSHORTESTDAYNAME6 = $00000036;
  CAL_SSHORTESTDAYNAME7 = $00000037;
// WinVer >= $0601
  CAL_SMONTHDAY        = $00000038;
  CAL_SABBREVERASTRING = $00000039;

 Type
  GEOCLASS = DWORD;

 Const
  GEOCLASS_NATION = 16;
  GEOCLASS_REGION = 14;

 Type
  GEOTYPE = DWORD;

 Const
  GEO_NATION            = $0001;
  GEO_LATITUDE          = $0002;
  GEO_LONGITUDE         = $0003;
  GEO_ISO2              = $0004;
  GEO_ISO3              = $0005;
  GEO_RFC1766           = $0006;
  GEO_LCID              = $0007;
  GEO_FRIENDLYNAME      = $0008;
  GEO_OFFICIALNAME      = $0009;
  GEO_TIMEZONES         = $000A;
  GEO_OFFICIALLANGUAGES = $000B;

 Type
  GEOID = DWORD;

 Type
  LOCALE_ENUMPROCEX = Function(lpLocaleString : PChar; dwFlags : DWORD; lParam : lParam) : BOOL;

  Stdcall;

  GEO_ENUMPROC = Function(GEOID : GEOID) : BOOL;

  Stdcall;

 Function LCIDToLocaleName(LocaleID : LCID) : String;
 Function LocaleNameToLCID(Const LocaleName : String) : LCID;
 Function GetLocaleInt(LocaleID : LCID; LCTYPE : LCTYPE; Default : Integer) : Integer; Overload;
 Function GetLocaleStr(LocaleID : LCID; LCTYPE : LCTYPE; Const Default : String) : String; Overload;
 Function GetLocaleInt(Const LocaleName : String; LCTYPE : LCTYPE; Default : Integer) : Integer; Overload;
 Function GetLocaleStr(Const LocaleName : String; LCTYPE : LCTYPE; Const Default : String) : String; Overload;
 Function EnumSystemLocalesEx(LocaleEnumProcEx : LOCALE_ENUMPROCEX; dwFlags : DWORD; lParam : lParam; lpReserved : Pointer) : BOOL;
 Function GetCalendarInt(LocaleID : LCID; Calendar : CALID; CALTYPE : CALTYPE; Default : Integer) : Integer; Overload;
 Function GetCalendarStr(LocaleID : LCID; Calendar : CALID; CALTYPE : CALTYPE; Const Default : String) : String; Overload;
 Function GetCalendarInt(Const LocaleName : String; Calendar : CALID; CALTYPE : CALTYPE; Default : Integer) : Integer; Overload;
 Function GetCalendarStr(Const LocaleName : String; Calendar : CALID; CALTYPE : CALTYPE; Const Default : String) : String; Overload;
 Function GetUserDefaultUILanguage : LANGID;
 Function GetUserGeoID(GEOCLASS : GEOCLASS) : GEOID;
 Function GetGeoStr(GEOID : GEOID; GEOTYPE : GEOTYPE; Const Default : String) : String;
 Function EnumSystemGeoID(GEOCLASS : GEOCLASS; ParentGeoId : GEOID; GeoEnumProc : GEO_ENUMPROC) : Boolean;
 Function GetLocaleScripts(Const LocaleName : String) : String;
 Function GetStringScripts(Const Str : String; AllowInheritedCommon : Boolean = False) : String;
 Function VerifyScripts(Const LocaleScripts, TestScripts : String; AllowLatin : Boolean = True) : Boolean;
 Function WinVer : Word; Inline;

Implementation

 Var { kernel32.dll }
  _LCIDToLocaleName : Function(LocaleID : LCID; lpName : PChar; cchName : Integer; Flags : DWORD) : Integer;
  Stdcall;
  _LocaleNameToLCID : Function(lpName : PChar; dwFlags : DWORD) : LCID;
  Stdcall;
  _GetLocaleInfoEx : Function(lpLocaleName : PChar; LCTYPE : LCTYPE; lpLCData : PChar; cchData : Integer) : Integer;
  Stdcall;
  _EnumSystemLocalesEx : Function(lpLocaleEnumProcEx : LOCALE_ENUMPROCEX; dwFlags : DWORD; lParam : lParam; lpReserved : Pointer) : BOOL;
  Stdcall;
  _GetStringScripts : Function(dwFlags : DWORD; lpString : PChar; cchString : Integer; lpScripts : PChar; cchScripts : Integer) : Integer;
  Stdcall;
  _VerifyScripts : Function(dwFlags : DWORD; lpLocaleScripts : PChar; cchLocaleScripts : Integer; lpTestScripts : PChar; cchTestScripts : Integer) : BOOL;
  Stdcall;
  _GetCalendarInfo : Function(LocaleID : LCID; Calendar : CALID; CALTYPE : CALTYPE; lpCalData : PChar; cchData : Integer; lpValue : PDWORD) : Integer;
  Stdcall;
  _GetCalendarInfoEx : Function(lpLocaleName : PChar; Calendar : CALID; lpReserved : PChar; CALTYPE : CALTYPE; lpCalData : PChar; cchData : Integer; lpValue : PDWORD) : Integer;
  Stdcall;
  _GetUserDefaultUILanguage : Function : LANGID;
  Stdcall;
  _EnumSystemGeoID : Function(GEOCLASS : GEOCLASS; ParentGeoId : GEOID; lplpGeoEnumProc : GEO_ENUMPROC) : BOOL;
  Stdcall;
  _GetUserGeoID : Function(GEOCLASS : GEOCLASS) : GEOID;
  Stdcall;
  _GetGeoInfo : Function(Location : GEOID; GEOTYPE : GEOTYPE; lpGeoData : PChar; cchData : Integer; LANGID : LANGID) : Integer;
  Stdcall;

 Var { Idndl.dll }
  _DownlevelGetLocaleScripts : Function(lpLocaleName : PChar; lpScripts : PChar; cchScripts : Integer) : Integer;
  Stdcall;
  _DownlevelGetStringScripts : Function(dwFlags : DWORD; lpString : PChar; cchString : Integer; lpScripts : PChar; cchScripts : Integer) : Integer;
  Stdcall;
  _DownlevelVerifyScripts : Function(dwFlags : DWORD; lpLocaleScripts : PChar; cchLocaleScripts : Integer; lpTestScripts : PChar; cchTestScripts : Integer) : BOOL;
  Stdcall;

 Type
  TLocaleTableEntry = Record
   ID       : LANGID;
   Lang3    : String;
   CurSymbl : String;
   Name     : String;
  End;

 Const
  // Sorted list of missing locale info for versions of Windows prior to Vista
  LocaleTable : Array[1..211] Of TLocaleTableEntry = (
  (ID : $0401; Lang3 : 'ara'; CurSymbl : 'SAR'; Name : 'ar-SA'),
  (ID : $0402; Lang3 : 'bul'; CurSymbl : 'BGN'; Name : 'bg-BG'),
  (ID : $0403; Lang3 : 'cat'; CurSymbl : 'EUR'; Name : 'ca-ES'),
  (ID : $0404; Lang3 : 'zho'; CurSymbl : 'TWD'; Name : 'zh-TW'),
  (ID : $0405; Lang3 : 'ces'; CurSymbl : 'CZK'; Name : 'cs-CZ'),
  (ID : $0406; Lang3 : 'dan'; CurSymbl : 'DKK'; Name : 'da-DK'),
  (ID : $0407; Lang3 : 'deu'; CurSymbl : 'EUR'; Name : 'de-DE'),
  (ID : $0408; Lang3 : 'ell'; CurSymbl : 'EUR'; Name : 'el-GR'),
  (ID : $0409; Lang3 : 'eng'; CurSymbl : 'USD'; Name : 'en-US'),
  (ID : $040A; Lang3 : 'spa'; CurSymbl : 'EUR'; Name : 'es-ES_tradnl'),
  (ID : $040B; Lang3 : 'fin'; CurSymbl : 'EUR'; Name : 'fi-FI'),
  (ID : $040C; Lang3 : 'fra'; CurSymbl : 'EUR'; Name : 'fr-FR'),
  (ID : $040D; Lang3 : 'heb'; CurSymbl : 'ILS'; Name : 'he-IL'),
  (ID : $040E; Lang3 : 'hun'; CurSymbl : 'HUF'; Name : 'hu-HU'),
  (ID : $040F; Lang3 : 'isl'; CurSymbl : 'ISK'; Name : 'is-IS'),
  (ID : $0410; Lang3 : 'ita'; CurSymbl : 'EUR'; Name : 'it-IT'),
  (ID : $0411; Lang3 : 'jpn'; CurSymbl : 'JPY'; Name : 'ja-JP'),
  (ID : $0412; Lang3 : 'kor'; CurSymbl : 'KRW'; Name : 'ko-KR'),
  (ID : $0413; Lang3 : 'nld'; CurSymbl : 'EUR'; Name : 'nl-NL'),
  (ID : $0414; Lang3 : 'nob'; CurSymbl : 'NOK'; Name : 'nb-NO'),
  (ID : $0415; Lang3 : 'pol'; CurSymbl : 'PLN'; Name : 'pl-PL'),
  (ID : $0416; Lang3 : 'por'; CurSymbl : 'BRL'; Name : 'pt-BR'),
  (ID : $0417; Lang3 : 'roh'; CurSymbl : 'CHF'; Name : 'rm-CH'),
  (ID : $0418; Lang3 : 'ron'; CurSymbl : 'RON'; Name : 'ro-RO'),
  (ID : $0419; Lang3 : 'rus'; CurSymbl : 'RUB'; Name : 'ru-RU'),
  (ID : $041A; Lang3 : 'hrv'; CurSymbl : 'HRK'; Name : 'hr-HR'),
  (ID : $041B; Lang3 : 'slk'; CurSymbl : 'EUR'; Name : 'sk-SK'),
  (ID : $041C; Lang3 : 'sqi'; CurSymbl : 'ALL'; Name : 'sq-AL'),
  (ID : $041D; Lang3 : 'swe'; CurSymbl : 'SEK'; Name : 'sv-SE'),
  (ID : $041E; Lang3 : 'tha'; CurSymbl : 'THB'; Name : 'th-TH'),
  (ID : $041F; Lang3 : 'tur'; CurSymbl : 'TRY'; Name : 'tr-TR'),
  (ID : $0420; Lang3 : 'urd'; CurSymbl : 'PKR'; Name : 'ur-PK'),
  (ID : $0421; Lang3 : 'ind'; CurSymbl : 'IDR'; Name : 'id-ID'),
  (ID : $0422; Lang3 : 'ukr'; CurSymbl : 'UAH'; Name : 'uk-UA'),
  (ID : $0423; Lang3 : 'bel'; CurSymbl : 'BYR'; Name : 'be-BY'),
  (ID : $0424; Lang3 : 'slv'; CurSymbl : 'EUR'; Name : 'sl-SI'),
  (ID : $0425; Lang3 : 'est'; CurSymbl : 'EEK'; Name : 'et-EE'),
  (ID : $0426; Lang3 : 'lav'; CurSymbl : 'LVL'; Name : 'lv-LV'),
  (ID : $0427; Lang3 : 'lit'; CurSymbl : 'LTL'; Name : 'lt-LT'),
  (ID : $0428; Lang3 : 'tgk'; CurSymbl : 'TJS'; Name : 'tg-Cyrl-TJ'),
  (ID : $0429; Lang3 : 'fas'; CurSymbl : 'IRR'; Name : 'fa-IR'),
  (ID : $042A; Lang3 : 'vie'; CurSymbl : 'VND'; Name : 'vi-VN'),
  (ID : $042B; Lang3 : 'hye'; CurSymbl : 'AMD'; Name : 'hy-AM'),
  (ID : $042C; Lang3 : 'aze'; CurSymbl : 'AZN'; Name : 'az-Latn-AZ'),
  (ID : $042D; Lang3 : 'eus'; CurSymbl : 'EUR'; Name : 'eu-ES'),
  (ID : $042E; Lang3 : 'hsb'; CurSymbl : 'EUR'; Name : 'hsb-DE'),
  (ID : $042F; Lang3 : 'mkd'; CurSymbl : 'MKD'; Name : 'mk-MK'),
  (ID : $0432; Lang3 : 'tsn'; CurSymbl : 'ZAR'; Name : 'tn-ZA'),
  (ID : $0434; Lang3 : 'xho'; CurSymbl : 'ZAR'; Name : 'xh-ZA'),
  (ID : $0435; Lang3 : 'zul'; CurSymbl : 'ZAR'; Name : 'zu-ZA'),
  (ID : $0436; Lang3 : 'afr'; CurSymbl : 'ZAR'; Name : 'af-ZA'),
  (ID : $0437; Lang3 : 'kat'; CurSymbl : 'GEL'; Name : 'ka-GE'),
  (ID : $0438; Lang3 : 'fao'; CurSymbl : 'DKK'; Name : 'fo-FO'),
  (ID : $0439; Lang3 : 'hin'; CurSymbl : 'INR'; Name : 'hi-IN'),
  (ID : $043A; Lang3 : 'mlt'; CurSymbl : 'EUR'; Name : 'mt-MT'),
  (ID : $043B; Lang3 : 'sme'; CurSymbl : 'NOK'; Name : 'se-NO'),
  (ID : $043E; Lang3 : 'msa'; CurSymbl : 'MYR'; Name : 'ms-MY'),
  (ID : $043F; Lang3 : 'kaz'; CurSymbl : 'KZT'; Name : 'kk-KZ'),
  (ID : $0440; Lang3 : 'kir'; CurSymbl : 'KGS'; Name : 'ky-KG'),
  (ID : $0441; Lang3 : 'swa'; CurSymbl : 'KES'; Name : 'sw-KE'),
  (ID : $0442; Lang3 : 'tuk'; CurSymbl : 'TMT'; Name : 'tk-TM'),
  (ID : $0443; Lang3 : 'uzb'; CurSymbl : 'UZS'; Name : 'uz-Latn-UZ'),
  (ID : $0444; Lang3 : 'tat'; CurSymbl : 'RUB'; Name : 'tt-RU'),
  (ID : $0445; Lang3 : 'bng'; CurSymbl : 'INR'; Name : 'bn-IN'),
  (ID : $0446; Lang3 : 'pan'; CurSymbl : 'INR'; Name : 'pa-IN'),
  (ID : $0447; Lang3 : 'guj'; CurSymbl : 'INR'; Name : 'gu-IN'),
  (ID : $0448; Lang3 : 'ori'; CurSymbl : 'INR'; Name : 'or-IN'),
  (ID : $0449; Lang3 : 'tam'; CurSymbl : 'INR'; Name : 'ta-IN'),
  (ID : $044A; Lang3 : 'tel'; CurSymbl : 'INR'; Name : 'te-IN'),
  (ID : $044B; Lang3 : 'kan'; CurSymbl : 'INR'; Name : 'kn-IN'),
  (ID : $044C; Lang3 : 'mym'; CurSymbl : 'INR'; Name : 'ml-IN'),
  (ID : $044D; Lang3 : 'asm'; CurSymbl : 'INR'; Name : 'as-IN'),
  (ID : $044E; Lang3 : 'mar'; CurSymbl : 'INR'; Name : 'mr-IN'),
  (ID : $044F; Lang3 : 'san'; CurSymbl : 'INR'; Name : 'sa-IN'),
  (ID : $0450; Lang3 : 'mon'; CurSymbl : 'MNT'; Name : 'mn-MN'),
  (ID : $0451; Lang3 : 'bod'; CurSymbl : 'CNY'; Name : 'bo-CN'),
  (ID : $0452; Lang3 : 'cym'; CurSymbl : 'GBP'; Name : 'cy-GB'),
  (ID : $0453; Lang3 : 'khm'; CurSymbl : 'KHR'; Name : 'km-KH'),
  (ID : $0454; Lang3 : 'lao'; CurSymbl : 'LAK'; Name : 'lo-LA'),
  (ID : $0456; Lang3 : 'glg'; CurSymbl : 'EUR'; Name : 'gl-ES'),
  (ID : $0457; Lang3 : 'kok'; CurSymbl : 'INR'; Name : 'kok-IN'),
  (ID : $045A; Lang3 : 'syr'; CurSymbl : 'SYP'; Name : 'syr-SY'),
  (ID : $045B; Lang3 : 'sin'; CurSymbl : 'LKR'; Name : 'si-LK'),
  (ID : $045D; Lang3 : 'iku'; CurSymbl : 'CAD'; Name : 'iu-Cans-CA'),
  (ID : $045E; Lang3 : 'amh'; CurSymbl : 'ETB'; Name : 'am-ET'),
  (ID : $0461; Lang3 : 'nep'; CurSymbl : 'NPR'; Name : 'ne-NP'),
  (ID : $0462; Lang3 : 'fry'; CurSymbl : 'EUR'; Name : 'fy-NL'),
  (ID : $0463; Lang3 : 'pus'; CurSymbl : 'AFN'; Name : 'ps-AF'),
  (ID : $0464; Lang3 : 'fil'; CurSymbl : 'PHP'; Name : 'fil-PH'),
  (ID : $0465; Lang3 : 'div'; CurSymbl : 'MVR'; Name : 'dv-MV'),
  (ID : $0468; Lang3 : 'hau'; CurSymbl : 'NGN'; Name : 'ha-Latn-NG'),
  (ID : $046A; Lang3 : 'yor'; CurSymbl : 'NGN'; Name : 'yo-NG'),
  (ID : $046B; Lang3 : 'qub'; CurSymbl : 'BOB'; Name : 'quz-BO'),
  (ID : $046C; Lang3 : 'nso'; CurSymbl : 'ZAR'; Name : 'nso-ZA'),
  (ID : $046D; Lang3 : 'bak'; CurSymbl : 'RUB'; Name : 'ba-RU'),
  (ID : $046E; Lang3 : 'ltz'; CurSymbl : 'EUR'; Name : 'lb-LU'),
  (ID : $046F; Lang3 : 'kal'; CurSymbl : 'DKK'; Name : 'kl-GL'),
  (ID : $0470; Lang3 : 'ibo'; CurSymbl : 'NGN'; Name : 'ig-NG'),
  (ID : $0478; Lang3 : 'iii'; CurSymbl : 'CNY'; Name : 'ii-CN'),
  (ID : $047A; Lang3 : 'arn'; CurSymbl : 'CLP'; Name : 'arn-CL'),
  (ID : $047C; Lang3 : 'moh'; CurSymbl : 'CAD'; Name : 'moh-CA'),
  (ID : $047E; Lang3 : 'bre'; CurSymbl : 'EUR'; Name : 'br-FR'),
  (ID : $0480; Lang3 : 'uig'; CurSymbl : 'CNY'; Name : 'ug-CN'),
  (ID : $0481; Lang3 : 'mri'; CurSymbl : 'NZD'; Name : 'mi-NZ'),
  (ID : $0482; Lang3 : 'oci'; CurSymbl : 'EUR'; Name : 'oc-FR'),
  (ID : $0483; Lang3 : 'cos'; CurSymbl : 'EUR'; Name : 'co-FR'),
  (ID : $0484; Lang3 : 'gsw'; CurSymbl : 'EUR'; Name : 'gsw-FR'),
  (ID : $0485; Lang3 : 'sah'; CurSymbl : 'RUB'; Name : 'sah-RU'),
  (ID : $0486; Lang3 : 'qut'; CurSymbl : 'GTQ'; Name : 'qut-GT'),
  (ID : $0487; Lang3 : 'kin'; CurSymbl : 'RWF'; Name : 'rw-RW'),
  (ID : $0488; Lang3 : 'wol'; CurSymbl : 'XOF'; Name : 'wo-SN'),
  (ID : $048C; Lang3 : 'prs'; CurSymbl : 'AFN'; Name : 'prs-AF'),
  (ID : $0491; Lang3 : 'gla'; CurSymbl : 'GBP'; Name : 'gd-GB'),
  (ID : $0801; Lang3 : 'ara'; CurSymbl : 'IQD'; Name : 'ar-IQ'),
  (ID : $0804; Lang3 : 'zho'; CurSymbl : 'CNY'; Name : 'zh-CN'),
  (ID : $0807; Lang3 : 'deu'; CurSymbl : 'CHF'; Name : 'de-CH'),
  (ID : $0809; Lang3 : 'eng'; CurSymbl : 'GBP'; Name : 'en-GB'),
  (ID : $080A; Lang3 : 'spa'; CurSymbl : 'MXN'; Name : 'es-MX'),
  (ID : $080C; Lang3 : 'fra'; CurSymbl : 'EUR'; Name : 'fr-BE'),
  (ID : $0810; Lang3 : 'ita'; CurSymbl : 'CHF'; Name : 'it-CH'),
  (ID : $0813; Lang3 : 'nld'; CurSymbl : 'EUR'; Name : 'nl-BE'),
  (ID : $0814; Lang3 : 'nno'; CurSymbl : 'NOK'; Name : 'nn-NO'),
  (ID : $0816; Lang3 : 'por'; CurSymbl : 'EUR'; Name : 'pt-PT'),
  (ID : $081A; Lang3 : 'srp'; CurSymbl : 'CSD'; Name : 'sr-Latn-CS'),
  (ID : $081D; Lang3 : 'swe'; CurSymbl : 'EUR'; Name : 'sv-FI'),
  (ID : $082C; Lang3 : 'aze'; CurSymbl : 'AZN'; Name : 'az-Cyrl-AZ'),
  (ID : $082E; Lang3 : 'dsb'; CurSymbl : 'EUR'; Name : 'dsb-DE'),
  (ID : $083B; Lang3 : 'smf'; CurSymbl : 'SEK'; Name : 'se-SE'),
  (ID : $083C; Lang3 : 'gle'; CurSymbl : 'EUR'; Name : 'ga-IE'),
  (ID : $083E; Lang3 : 'msa'; CurSymbl : 'BND'; Name : 'ms-BN'),
  (ID : $0843; Lang3 : 'uzb'; CurSymbl : 'UZS'; Name : 'uz-Cyrl-UZ'),
  (ID : $0845; Lang3 : 'bng'; CurSymbl : 'BDT'; Name : 'bn-BD'),
  (ID : $0850; Lang3 : 'mon'; CurSymbl : 'CNY'; Name : 'mn-Mong-CN'),
  (ID : $085D; Lang3 : 'iku'; CurSymbl : 'CAD'; Name : 'iu-Latn-CA'),
  (ID : $085F; Lang3 : 'tzm'; CurSymbl : 'DZD'; Name : 'tzm-Latn-DZ'),
  (ID : $086B; Lang3 : 'que'; CurSymbl : 'USD'; Name : 'quz-EC'),
  (ID : $0C01; Lang3 : 'ara'; CurSymbl : 'EGP'; Name : 'ar-EG'),
  (ID : $0C04; Lang3 : 'zho'; CurSymbl : 'HKD'; Name : 'zh-HK'),
  (ID : $0C07; Lang3 : 'deu'; CurSymbl : 'EUR'; Name : 'de-AT'),
  (ID : $0C09; Lang3 : 'eng'; CurSymbl : 'AUD'; Name : 'en-AU'),
  (ID : $0C0A; Lang3 : 'spa'; CurSymbl : 'EUR'; Name : 'es-ES'),
  (ID : $0C0C; Lang3 : 'fra'; CurSymbl : 'CAD'; Name : 'fr-CA'),
  (ID : $0C1A; Lang3 : 'srp'; CurSymbl : 'CSD'; Name : 'sr-Cyrl-CS'),
  (ID : $0C3B; Lang3 : 'smg'; CurSymbl : 'EUR'; Name : 'se-FI'),
  (ID : $0C6B; Lang3 : 'qup'; CurSymbl : 'PEN'; Name : 'quz-PE'),
  (ID : $1001; Lang3 : 'ara'; CurSymbl : 'LYD'; Name : 'ar-LY'),
  (ID : $1004; Lang3 : 'zho'; CurSymbl : 'SGD'; Name : 'zh-SG'),
  (ID : $1007; Lang3 : 'deu'; CurSymbl : 'EUR'; Name : 'de-LU'),
  (ID : $1009; Lang3 : 'eng'; CurSymbl : 'CAD'; Name : 'en-CA'),
  (ID : $100A; Lang3 : 'spa'; CurSymbl : 'GTQ'; Name : 'es-GT'),
  (ID : $100C; Lang3 : 'fra'; CurSymbl : 'CHF'; Name : 'fr-CH'),
  (ID : $101A; Lang3 : 'hrb'; CurSymbl : 'BAM'; Name : 'hr-BA'),
  (ID : $103B; Lang3 : 'smj'; CurSymbl : 'NOK'; Name : 'smj-NO'),
  (ID : $1401; Lang3 : 'ara'; CurSymbl : 'DZD'; Name : 'ar-DZ'),
  (ID : $1404; Lang3 : 'zho'; CurSymbl : 'MOP'; Name : 'zh-MO'),
  (ID : $1407; Lang3 : 'deu'; CurSymbl : 'CHF'; Name : 'de-LI'),
  (ID : $1409; Lang3 : 'eng'; CurSymbl : 'NZD'; Name : 'en-NZ'),
  (ID : $140A; Lang3 : 'spa'; CurSymbl : 'CRC'; Name : 'es-CR'),
  (ID : $140C; Lang3 : 'fra'; CurSymbl : 'EUR'; Name : 'fr-LU'),
  (ID : $141A; Lang3 : 'bsb'; CurSymbl : 'BAM'; Name : 'bs-Latn-BA'),
  (ID : $143B; Lang3 : 'smk'; CurSymbl : 'SEK'; Name : 'smj-SE'),
  (ID : $1801; Lang3 : 'ara'; CurSymbl : 'MAD'; Name : 'ar-MA'),
  (ID : $1809; Lang3 : 'eng'; CurSymbl : 'EUR'; Name : 'en-IE'),
  (ID : $180A; Lang3 : 'spa'; CurSymbl : 'PAB'; Name : 'es-PA'),
  (ID : $180C; Lang3 : 'fra'; CurSymbl : 'EUR'; Name : 'fr-MC'),
  (ID : $181A; Lang3 : 'srs'; CurSymbl : 'BAM'; Name : 'sr-Latn-BA'),
  (ID : $183B; Lang3 : 'sma'; CurSymbl : 'NOK'; Name : 'sma-NO'),
  (ID : $1C01; Lang3 : 'ara'; CurSymbl : 'TND'; Name : 'ar-TN'),
  (ID : $1C09; Lang3 : 'eng'; CurSymbl : 'ZAR'; Name : 'en-ZA'),
  (ID : $1C0A; Lang3 : 'spa'; CurSymbl : 'DOP'; Name : 'es-DO'),
  (ID : $1C1A; Lang3 : 'srn'; CurSymbl : 'BAM'; Name : 'sr-Cyrl-BA'),
  (ID : $1C3B; Lang3 : 'smb'; CurSymbl : 'SEK'; Name : 'sma-SE'),
  (ID : $2001; Lang3 : 'ara'; CurSymbl : 'OMR'; Name : 'ar-OM'),
  (ID : $2009; Lang3 : 'eng'; CurSymbl : 'JMD'; Name : 'en-JM'),
  (ID : $200A; Lang3 : 'spa'; CurSymbl : 'VEF'; Name : 'es-VE'),
  (ID : $201A; Lang3 : 'bsc'; CurSymbl : 'BAM'; Name : 'bs-Cyrl-BA'),
  (ID : $203B; Lang3 : 'sms'; CurSymbl : 'EUR'; Name : 'sms-FI'),
  (ID : $2401; Lang3 : 'ara'; CurSymbl : 'YER'; Name : 'ar-YE'),
  (ID : $2409; Lang3 : 'eng'; CurSymbl : 'USD'; Name : 'en-029'),
  (ID : $240A; Lang3 : 'spa'; CurSymbl : 'COP'; Name : 'es-CO'),
  (ID : $241A; Lang3 : 'srp'; CurSymbl : 'RSD'; Name : 'sr-Latn-RS'),
  (ID : $243B; Lang3 : 'smn'; CurSymbl : 'EUR'; Name : 'smn-FI'),
  (ID : $2801; Lang3 : 'ara'; CurSymbl : 'SYP'; Name : 'ar-SY'),
  (ID : $2809; Lang3 : 'eng'; CurSymbl : 'BZD'; Name : 'en-BZ'),
  (ID : $280A; Lang3 : 'spa'; CurSymbl : 'PEN'; Name : 'es-PE'),
  (ID : $281A; Lang3 : 'srp'; CurSymbl : 'RSD'; Name : 'sr-Cyrl-RS'),
  (ID : $2C01; Lang3 : 'ara'; CurSymbl : 'JOD'; Name : 'ar-JO'),
  (ID : $2C09; Lang3 : 'eng'; CurSymbl : 'TTD'; Name : 'en-TT'),
  (ID : $2C0A; Lang3 : 'spa'; CurSymbl : 'ARS'; Name : 'es-AR'),
  (ID : $2C1A; Lang3 : 'srp'; CurSymbl : 'EUR'; Name : 'sr-Latn-ME'),
  (ID : $3001; Lang3 : 'ara'; CurSymbl : 'LBP'; Name : 'ar-LB'),
  (ID : $3009; Lang3 : 'eng'; CurSymbl : 'ZWL'; Name : 'en-ZW'),
  (ID : $300A; Lang3 : 'spa'; CurSymbl : 'USD'; Name : 'es-EC'),
  (ID : $301A; Lang3 : 'srp'; CurSymbl : 'EUR'; Name : 'sr-Cyrl-ME'),
  (ID : $3401; Lang3 : 'ara'; CurSymbl : 'KWD'; Name : 'ar-KW'),
  (ID : $3409; Lang3 : 'eng'; CurSymbl : 'PHP'; Name : 'en-PH'),
  (ID : $340A; Lang3 : 'spa'; CurSymbl : 'CLP'; Name : 'es-CL'),
  (ID : $3801; Lang3 : 'ara'; CurSymbl : 'AED'; Name : 'ar-AE'),
  (ID : $380A; Lang3 : 'spa'; CurSymbl : 'UYU'; Name : 'es-UY'),
  (ID : $3C01; Lang3 : 'ara'; CurSymbl : 'BHD'; Name : 'ar-BH'),
  (ID : $3C0A; Lang3 : 'spa'; CurSymbl : 'PYG'; Name : 'es-PY'),
  (ID : $4001; Lang3 : 'ara'; CurSymbl : 'QAR'; Name : 'ar-QA'),
  (ID : $4009; Lang3 : 'eng'; CurSymbl : 'INR'; Name : 'en-IN'),
  (ID : $400A; Lang3 : 'spa'; CurSymbl : 'BOB'; Name : 'es-BO'),
  (ID : $4409; Lang3 : 'eng'; CurSymbl : 'MYR'; Name : 'en-MY'),
  (ID : $440A; Lang3 : 'spa'; CurSymbl : 'USD'; Name : 'es-SV'),
  (ID : $4809; Lang3 : 'eng'; CurSymbl : 'SGD'; Name : 'en-SG'),
  (ID : $480A; Lang3 : 'spa'; CurSymbl : 'HNL'; Name : 'es-HN'),
  (ID : $4C0A; Lang3 : 'spa'; CurSymbl : 'NIO'; Name : 'es-NI'),
  (ID : $500A; Lang3 : 'spa'; CurSymbl : 'USD'; Name : 'es-PR'),
  (ID : $540A; Lang3 : 'spa'; CurSymbl : 'USD'; Name : 'es-US'));

 Function LookupLocale(LANGID : LANGID; Out Index : Integer) : Boolean;
  Var
   l : Integer;
   h : Integer;
   m : Integer;
  Begin
   If SUBLANGID(LANGID) = 0 Then
    LANGID := MAKELANGID(LANGID, SUBLANG_DEFAULT);
   l       := Low(LocaleTable);
   h       := High(LocaleTable);
   Repeat
    m := (l + h) Shr 1;
    With LocaleTable[m] Do
     If ID < LANGID Then
      l := m + 1
     Else If ID > LANGID Then
      h := m - 1
     Else
      Begin
       Index  := m;
       Result := True;
       Exit;
      End;
   Until l > h;
   Result := False;
  End;

 Function LCIDToLocaleName(LocaleID : LCID) : String;
  Var
   Buffer : Array[0..LOCALE_NAME_MAX_LENGTH] Of Char;
   l      : Integer;
  Begin
   Result := '';
   If (LocaleID = LOCALE_NEUTRAL) Or (LocaleID = LOCALE_USER_DEFAULT) Then
    LocaleID := GetUserDefaultLCID
   Else If LocaleID = LOCALE_SYSTEM_DEFAULT Then
    LocaleID := GetSystemDefaultLCID;
   If Assigned(_LCIDToLocaleName) Then
    Begin
     l := _LCIDToLocaleName(LocaleID, Buffer, LOCALE_NAME_MAX_LENGTH, 0);
     If l > 0 Then
      SetString(Result, Buffer, l - 1);
    End
   Else If LookupLocale(LocaleID, l) Then
    Begin
     Result := LocaleTable[l].Name;
     If SUBLANGID(LocaleID) = 0 Then
      Result := Copy(Result, 1, Pos('-', Result) - 1);
    End;
  End;

 Function LocaleNameToLCID(Const LocaleName : String) : LCID;
  Var
   i    : Integer;
   Lang : String;
  Begin
   If Assigned(_LocaleNameToLCID) Then
    Result := _LocaleNameToLCID(PChar(LocaleName), 0)
   Else If Pos('-', LocaleName) <> 0 Then
    Begin
     For i := Low(LocaleTable) To High(LocaleTable) Do
      If SameText(LocaleTable[i].Name, LocaleName) Then
       Begin
        Result := LocaleTable[i].ID;
        Exit;
       End;
     Result := 0;
    End
   Else
    Begin
     Lang  := LowerCase(LocaleName) + '-';
     For i := Low(LocaleTable) To High(LocaleTable) Do
      If Pos(Lang, LocaleTable[i].Name) = 1 Then
       Begin
        Result := PRIMARYLANGID(LocaleTable[i].ID);
        Exit;
       End;
     Result := 0;
    End;
  End;

 Function GetLocaleInt(LocaleID : LCID; LCTYPE : LCTYPE; Default : Integer) : Integer; Inline;
  Var
   Buffer : Array[0..0] Of Char Absolute Result;
  Begin
   If GetLocaleInfo(LocaleID, LCTYPE Or LOCALE_RETURN_NUMBER, Buffer,
   SizeOf(Integer) Div SizeOf(Char)) = 0
   Then
    Result := Default;
  End;

 Function GetLocaleStr(LocaleID : LCID; LCTYPE : LCTYPE; Const Default : String) : String;
  Var
   Buffer : Array[0..512] Of Char;
   l      : Integer;
  Begin
   If ((LCTYPE And $00FFFFFF) = LOCALE_SINTLSYMBOL) And
   ((LocaleID = $468) Or (LocaleID = $46A) Or (LocaleID = $470)) Then
    Begin
     Result := 'NGN';                  // workaround Windows bug
     Exit;
    End;
   If WinVer < $0601 Then
    Case LCTYPE And $00FFFFFF Of
     LOCALE_SENGLISHDISPLAYNAME :
      Begin
       Result := GetLocaleStr(LocaleID, LOCALE_SENGLANGUAGE, '');
       If Result <> '' Then
        Begin
         If Result = 'Farsi' Then
          Result := 'Persian';
         Result  := Result + ' (' + GetLocaleStr(LocaleID, LOCALE_SENGCOUNTRY, '') + ')';
        End
       Else
        Result := Default;
       Exit;
      End;
     LOCALE_SNATIVEDISPLAYNAME :
      Begin
       Result := GetLocaleStr(LocaleID, LOCALE_SNATIVELANGNAME, '');
       If Result <> '' Then
        Result := Result + ' (' + GetLocaleStr(LocaleID, LOCALE_SNATIVECTRYNAME, '') + ')'
       Else
        Result := Default;
       Exit;
      End;
    Else
      If WinVer < $0600 Then
       Begin
        Case LCTYPE And $00FFFFFF Of
         LOCALE_SLOCALIZEDLANGUAGENAME :
          LCTYPE := (LCTYPE And $FF000000) Or LOCALE_SLANGUAGE;
         LOCALE_SISO3166CTRYNAME2 :
          Begin
           l := GetLocaleInt(LocaleID, LOCALE_IGEOID, 0);
           If l <> 0 Then
            Result := GetGeoStr(l, GEO_ISO3, Default)
           Else
            Result := Default;
           Exit;
          End;
         LOCALE_SISO639LANGNAME2 :
          Begin
           If LookupLocale(LocaleID, l) Then
            Result := LocaleTable[l].Lang3
           Else
            Result := Default;
           Exit;
          End;
         LOCALE_SINTLSYMBOL :
          Begin
           If LookupLocale(LocaleID, l) Then
            Result := LocaleTable[l].CurSymbl
           Else
            Result := Default;
           Exit;
          End;
         LOCALE_SNAME :
          Begin
           If LookupLocale(LocaleID, l) Then
            Result := LocaleTable[l].Name
           Else
            Result := Default;
           Exit;
          End;
        End;
       End;
    End;
   l := GetLocaleInfo(LocaleID, LCTYPE, Buffer, Length(Buffer));
   If l > 0 Then
    SetString(Result, Buffer, l - 1)
   Else
    Result := Default;
  End;

 Function GetLocaleInt(Const LocaleName : String; LCTYPE : LCTYPE; Default : Integer) : Integer;
  Var
   Buffer : Array[0..0] Of Char Absolute Result;
  Begin
   If Assigned(_GetLocaleInfoEx) Then
    Begin
     If _GetLocaleInfoEx(PChar(LocaleName), LCTYPE Or LOCALE_RETURN_NUMBER,
     Buffer, SizeOf(Integer) Div SizeOf(Char)) = 0
     Then
      Result := Default;
    End
   Else
    Result := GetLocaleInt(LocaleNameToLCID(LocaleName), LCTYPE, Default);
  End;

 Function GetLocaleStr(Const LocaleName : String; LCTYPE : LCTYPE; Const Default : String) : String;
  Var
   Buffer : Array[0..512] Of Char;
   l      : Integer;
  Begin
   If Assigned(_GetLocaleInfoEx) Then
    Begin
     If ((LCTYPE And $00FFFFFF) = LOCALE_SINTLSYMBOL) And
     (Pos('-NG', UpperCase(LocaleName)) = Length(LocaleName) - 2) Then
      Begin
       Result := 'NGN';                // workaround Windows bug
       Exit;
      End;
     If WinVer < $0601 Then
      Case LCTYPE And $00FFFFFF Of
       LOCALE_SENGLISHDISPLAYNAME :
        Begin
         Result := GetLocaleStr(LocaleName, LOCALE_SENGLANGUAGE, '');
         If Result <> '' Then
          Result := Result + ' (' + GetLocaleStr(LocaleName, LOCALE_SENGCOUNTRY, '') + ')'
         Else
          Result := Default;
         Exit;
        End;
       LOCALE_SNATIVEDISPLAYNAME :
        Begin
         Result := GetLocaleStr(LocaleName, LOCALE_SNATIVELANGNAME, '');
         If Result <> '' Then
          Result := Result + ' (' + GetLocaleStr(LocaleName, LOCALE_SNATIVECTRYNAME, '') + ')'
         Else
          Result := Default;
         Exit;
        End;
      End;
     l := _GetLocaleInfoEx(PChar(LocaleName), LCTYPE, Buffer, Length(Buffer));
     If l > 0 Then
      SetString(Result, Buffer, l - 1)
     Else
      Result := Default;
    End
   Else
    Result := GetLocaleStr(LocaleNameToLCID(LocaleName), LCTYPE, Default);
  End;

 Function EnumSystemLocalesEx(LocaleEnumProcEx : LOCALE_ENUMPROCEX; dwFlags : DWORD; lParam : lParam; lpReserved : Pointer) : BOOL;
  Begin
   If Assigned(_EnumSystemLocalesEx) Then
    Result := _EnumSystemLocalesEx(LocaleEnumProcEx, dwFlags, lParam, lpReserved)
   Else
    Result := False;
  End;

 Function GetLocaleScripts(Const LocaleName : String) : String;
  Var
   Buffer : Array[0..512] Of Char;
   l      : Integer;
  Begin
   If Assigned(_GetLocaleInfoEx) Then
    l := _GetLocaleInfoEx(PChar(LocaleName), LOCALE_SSCRIPTS, Buffer, Length(Buffer))
   Else If Assigned(_DownlevelGetLocaleScripts) Then
    l := _DownlevelGetLocaleScripts(PChar(LocaleName), Buffer, Length(Buffer))
   Else
    l := 0;
   If l > 0 Then
    SetString(Result, Buffer, l - 1)
   Else
    Result := '';
  End;

 Function GetStringScripts(Const Str : String; AllowInheritedCommon : Boolean) : String;
  Const
   GSS_ALLOW_INHERITED_COMMON = 1;
  Var
   Buffer : Array[0..512] Of Char;
   Flags  : Integer;
   l      : Integer;
  Begin
   If AllowInheritedCommon Then
    Flags := GSS_ALLOW_INHERITED_COMMON
   Else
    Flags := 0;
   If Assigned(_GetStringScripts) Then
    l := _GetStringScripts(Flags, PChar(Str), Length(Str), Buffer, Length(Buffer))
   Else If Assigned(_DownlevelGetStringScripts) Then
    l := _DownlevelGetStringScripts(Flags, PChar(Str), Length(Str), Buffer, Length(Buffer))
   Else
    l := 0;
   If l > 0 Then
    SetString(Result, Buffer, l - 1)
   Else
    Result := '';
  End;

 Function VerifyScripts(Const LocaleScripts, TestScripts : String; AllowLatin : Boolean) : Boolean;
  Const
   VS_ALLOW_LATIN = 1;
  Var
   Flags : Integer;
  Begin
   If AllowLatin Then
    Flags := VS_ALLOW_LATIN
   Else
    Flags := 0;
   If Assigned(_VerifyScripts) Then
    Result := _VerifyScripts(Flags, PChar(LocaleScripts), Length(LocaleScripts),
    PChar(TestScripts), Length(TestScripts))
   Else If Assigned(_DownlevelVerifyScripts) Then
    Result := _DownlevelVerifyScripts(Flags, PChar(LocaleScripts),
    Length(LocaleScripts), PChar(TestScripts), Length(TestScripts))
   Else
    Result := False;
  End;

 Function GetCalendarInt(LocaleID : LCID; Calendar : CALID; CALTYPE : CALTYPE; Default : Integer) : Integer;
  Begin
   Result := Default;
   If Assigned(_GetCalendarInfo) Then
    _GetCalendarInfo(LocaleID, Calendar, CALTYPE Or CAL_RETURN_NUMBER, Nil, 0, @Result);
  End;

 Function GetCalendarStr(LocaleID : LCID; Calendar : CALID; CALTYPE : CALTYPE; Const Default : String) : String;
  Var
   Buffer : Array[0..512] Of Char;
   l      : Integer;
  Begin
   If Assigned(_GetCalendarInfo) Then
    Begin
     l := _GetCalendarInfo(LocaleID, Calendar, CALTYPE, Buffer, Length(Buffer), Nil);
     If l > 0 Then
      SetString(Result, Buffer, l - 1)
     Else
      Result := Default
    End
   Else
    Result := Default;
  End;

 Function GetCalendarInt(Const LocaleName : String; Calendar : CALID; CALTYPE : CALTYPE; Default : Integer) : Integer;
  Begin
   If Assigned(_GetCalendarInfoEx) Then
    Begin
     If _GetCalendarInfoEx(PChar(LocaleName), Calendar, Nil,
     CALTYPE Or CAL_RETURN_NUMBER, Nil, 0, @Result) = 0
     Then
      Result := Default;
    End
   Else
    Result := GetCalendarInt(LocaleNameToLCID(LocaleName), Calendar, CALTYPE, Default);
  End;

 Function GetCalendarStr(Const LocaleName : String; Calendar : CALID; CALTYPE : CALTYPE; Const Default : String) : String;
  Var
   Buffer : Array[0..512] Of Char;
   l      : Integer;
  Begin
   If Assigned(_GetCalendarInfoEx) Then
    Begin
     l := _GetCalendarInfoEx(PChar(LocaleName), Calendar, Nil, CALTYPE,
     Buffer, Length(Buffer), Nil);
     If l > 0 Then
      SetString(Result, Buffer, l - 1)
     Else
      Result := Default
    End
   Else
    Result := GetCalendarStr(LocaleNameToLCID(LocaleName), Calendar, CALTYPE, Default);
  End;

 Function GetUserDefaultUILanguage : LANGID;
  Begin
   If Assigned(_GetUserDefaultUILanguage) Then
    Result := _GetUserDefaultUILanguage
   Else
    Result := GetUserDefaultLangID;
  End;

 Function GetUserGeoID(GEOCLASS : GEOCLASS) : GEOID;
  Begin
   If Assigned(_GetUserGeoID) Then
    Result := _GetUserGeoID(GEOCLASS)
   Else
    Result := 0;
  End;

 Function GetGeoStr(GEOID : GEOID; GEOTYPE : GEOTYPE; Const Default : String) : String;
  Var
   Buffer : Array[0..512] Of Char;
   l      : Integer;
  Begin
   If Assigned(_GetGeoInfo) Then
    Begin
     l := _GetGeoInfo(GEOID, GEOTYPE, Buffer, Length(Buffer), 0);
     If l > 0 Then
      SetString(Result, Buffer, l - 1)
     Else
      Result := Default;
    End
   Else
    Result := Default;
  End;

 Function EnumSystemGeoID(GEOCLASS : GEOCLASS; ParentGeoId : GEOID; GeoEnumProc : GEO_ENUMPROC) : Boolean;
  Begin
   If Assigned(_EnumSystemGeoID) Then
    Result := _EnumSystemGeoID(GEOCLASS, ParentGeoId, @GeoEnumProc)
   Else
    Result := False;
  End;

 Function WinVer : Word;
  Begin
   Result := (Win32MajorVersion Shl 8) Or Win32MinorVersion;
  End;

 Var
  Idndl : THandle = 0;

 Procedure InitializeNLS;
  Var
   hModule : THandle;
  Begin
   hModule := GetModuleHandle(kernel32);
   @_LCIDToLocaleName := GetProcAddress(hModule, 'LCIDToLocaleName');
   @_LocaleNameToLCID := GetProcAddress(hModule, 'LocaleNameToLCID');
   @_GetLocaleInfoEx := GetProcAddress(hModule, 'GetLocaleInfoEx');
   @_EnumSystemLocalesEx := GetProcAddress(hModule, 'EnumSystemLocalesEx');
   @_GetStringScripts := GetProcAddress(hModule, 'GetStringScripts');
   @_VerifyScripts := GetProcAddress(hModule, 'VerifyScripts');
   @_GetCalendarInfo := GetProcAddress(hModule, 'GetCalendarInfoW');
   @_GetCalendarInfoEx := GetProcAddress(hModule, 'GetCalendarInfoExW');
   @_EnumSystemGeoID := GetProcAddress(hModule, 'EnumSystemGeoID');
   @_GetUserDefaultUILanguage := GetProcAddress(hModule, 'GetUserDefaultUILanguage');
   @_GetUserGeoID := GetProcAddress(hModule, 'GetUserGeoID');
   @_GetGeoInfo := GetProcAddress(hModule, 'GetGeoInfoW');
   If Not Assigned(_GetLocaleInfoEx) Then
    Begin
     hModule := LoadLibrary('Idndl.dll');
     If hModule > 0 Then
      Begin
       Idndl := hModule;
       @_DownlevelGetLocaleScripts := GetProcAddress(hModule, 'DownlevelGetLocaleScripts');
       @_DownlevelGetStringScripts := GetProcAddress(hModule, 'DownlevelGetStringScripts');
       @_DownlevelVerifyScripts := GetProcAddress(hModule, 'DownlevelVerifyScripts');
      End;
    End;
  End;

 Procedure FinalizeNLS;
  Begin
   If Idndl <> 0 Then
    Begin
     FreeLibrary(Idndl);
     Idndl := 0;
    End;
  End;

Initialization
 InitializeNLS;

Finalization
 FinalizeNLS;

End.
