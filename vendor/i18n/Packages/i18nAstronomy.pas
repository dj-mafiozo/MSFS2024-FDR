{------------------------------------------------------------------------------}
{                                                                              }
{  i18n Package                                                                }
{  Internationalization and Localization for Delphi                            }
{                                                                              }
{ Copyright(C) Kambiz Khojasteh                                              }
{  https://github.com/khojasteh/i18n                                           }
{                                                                              }
{------------------------------------------------------------------------------}

/// <summary>
/// This unit provides astronomical calculations for calendar systems.
/// </summary>
Unit i18nAstronomy;

{$I DELPHIAREA.INC}

Interface

 Uses
  SysUtils;

 Const
  {$Region 'xmldoc'}
  /// <summary>
  /// Minimum supported astronomical year for Vernal equinox calculations
  /// in the Gregorian calendar.
  /// </summary>
  {$Endregion}
  MEEUS_MIN_YEAR = -1000;
{$Region 'xmldoc'}
/// <summary>
/// Maximum supported astronomical year for Vernal equinox calculations
/// in the Gregorian calendar.
/// </summary>
{$Endregion}
  MEEUS_MAX_YEAR = 3000;

{$Region 'xmldoc'}
/// <summary>
/// Calculates the Julian Day of the Vernal equinox for a given astronomical
/// Gregorian year.
/// </summary>
/// <param name="Year">
/// The astronomical Gregorian year, where year 1 BC is represented as 0.
/// </param>
/// <returns>
/// Julian Day of the vernal equinox.
/// </returns>
/// <exception cref="ERangeError">
/// Raised if the year is out of the valid range (MEEUS_MIN_YEAR to MEEUS_MAX_YEAR).
/// </exception>
{$Endregion}

 Function VernalEquinoxJulianDay(Year : Integer) : Extended;

Implementation

 Uses
  Math;

 Resourcestring
  SYearOutOfRange = 'The year %d is out of range. Valid range is from %d to %d.';

 Const
  J2000_JD           = 2451545.0;
  GREGORIAN_EPOCH_JD = 1721425.5;

// Calculates the difference between Terrestrial Time (TT) and Universal Time (UT)
// in seconds for a given decimal year.

 Function DeltaTSeconds(YearDecimal : Extended) : Extended;
  Var
   u : Extended;
   t : Extended;
  Begin
   If YearDecimal < -500 Then
    Begin
     u      := (YearDecimal - 1820.0) / 100.0;
     Result := -20.0 + 32.0 * u * u;
     Exit;
    End;

   If YearDecimal < 500 Then
    Begin
     u      := YearDecimal / 100.0;
     Result := 10583.6
     - 1014.41 * u
     + 33.78311 * Sqr(u)
     - 5.952053 * Power(u, 3)
     - 0.1798452 * Power(u, 4)
     + 0.022174192 * Power(u, 5)
     + 0.0090316521 * Power(u, 6);
     Exit;
    End;

   If YearDecimal < 1600 Then
    Begin
     u      := (YearDecimal - 1000.0) / 100.0;
     Result := 1574.2
     - 556.01 * u
     + 71.23472 * Sqr(u)
     + 0.319781 * Power(u, 3)
     - 0.8503463 * Power(u, 4)
     - 0.005050998 * Power(u, 5)
     + 0.0083572073 * Power(u, 6);
     Exit;
    End;

   If YearDecimal < 1700 Then
    Begin
     t      := YearDecimal - 1600.0;
     Result := 120.0 - 0.9808 * t - 0.01532 * Sqr(t) + Power(t, 3) / 7129.0;
     Exit;
    End;

   If YearDecimal < 1800 Then
    Begin
     t      := YearDecimal - 1700.0;
     Result := 8.83
     + 0.1603 * t
     - 0.0059285 * Sqr(t)
     + 0.00013336 * Power(t, 3)
     - Power(t, 4) / 1174000.0;
     Exit;
    End;

   If YearDecimal < 1860 Then
    Begin
     t      := YearDecimal - 1800.0;
     Result := 13.72
     - 0.332447 * t
     + 0.0068612 * Sqr(t)
     + 0.0041116 * Power(t, 3)
     - 0.00037436 * Power(t, 4)
     + 0.0000121272 * Power(t, 5)
     - 0.0000001699 * Power(t, 6)
     + 0.000000000875 * Power(t, 7);
     Exit;
    End;

   If YearDecimal < 1900 Then
    Begin
     t      := YearDecimal - 1860.0;
     Result := 7.62
     + 0.5737 * t
     - 0.251754 * Sqr(t)
     + 0.01680668 * Power(t, 3)
     - 0.0004473624 * Power(t, 4)
     + Power(t, 5) / 233174.0;
     Exit;
    End;

   If YearDecimal < 1920 Then
    Begin
     t      := YearDecimal - 1900.0;
     Result := -2.79
     + 1.494119 * t
     - 0.0598939 * Sqr(t)
     + 0.0061966 * Power(t, 3)
     - 0.000197 * Power(t, 4);
     Exit;
    End;

   If YearDecimal < 1941 Then
    Begin
     t      := YearDecimal - 1920.0;
     Result := 21.20 + 0.84493 * t - 0.076100 * Sqr(t) + 0.0020936 * Power(t, 3);
     Exit;
    End;

   If YearDecimal < 1961 Then
    Begin
     t      := YearDecimal - 1950.0;
     Result := 29.07 + 0.407 * t - Sqr(t) / 233.0 + Power(t, 3) / 2547.0;
     Exit;
    End;

   If YearDecimal < 1986 Then
    Begin
     t      := YearDecimal - 1975.0;
     Result := 45.45 + 1.067 * t - Sqr(t) / 260.0 - Power(t, 3) / 718.0;
     Exit;
    End;

   If YearDecimal < 2005 Then
    Begin
     t      := YearDecimal - 2000.0;
     Result := 63.86
     + 0.3345 * t
     - 0.060374 * Sqr(t)
     + 0.0017275 * Power(t, 3)
     + 0.000651814 * Power(t, 4)
     + 0.00002373599 * Power(t, 5);
     Exit;
    End;

   If YearDecimal < 2050 Then
    Begin
     t      := YearDecimal - 2000.0;
     Result := 62.92 + 0.32217 * t + 0.005589 * Sqr(t);
     Exit;
    End;

   If YearDecimal < 2150 Then
    Begin
     u      := (YearDecimal - 1820.0) / 100.0;
     Result := -20.0 + 32.0 * u * u - 0.5628 * (2150.0 - YearDecimal);
     Exit;
    End;

   u      := (YearDecimal - 1820.0) / 100.0;
   Result := -20.0 + 32.0 * u * u;
  End;

 Type
  TEquinoxCorrectionTerm = Record
   A : Integer;
   B : Double;
   C : Double;
  End;

 Const
  // Periodic terms for Vernal Equinox (Meeus Ch. 27).
  VernalEquinoxCorrections : Array[0..23] Of TEquinoxCorrectionTerm = (
  (A : 485; B : 324.96; C : 1934.136),
  (A : 203; B : 337.23; C : 32964.467),
  (A : 199; B : 342.08; C : 20.186),
  (A : 182; B : 27.85; C : 445267.112),
  (A : 156; B : 73.14; C : 45036.886),
  (A : 136; B : 171.52; C : 22518.443),
  (A : 77; B : 222.54; C : 65928.934),
  (A : 74; B : 296.72; C : 3034.906),
  (A : 70; B : 243.58; C : 9037.513),
  (A : 58; B : 119.81; C : 33718.147),
  (A : 52; B : 297.17; C : 150.678),
  (A : 50; B : 21.02; C : 2281.226),
  (A : 45; B : 247.54; C : 29929.562),
  (A : 44; B : 325.15; C : 31555.956),
  (A : 29; B : 60.93; C : 4443.417),
  (A : 18; B : 155.12; C : 67555.328),
  (A : 17; B : 288.79; C : 4562.452),
  (A : 16; B : 198.04; C : 62894.029),
  (A : 14; B : 199.76; C : 31436.921),
  (A : 12; B : 95.39; C : 14577.848),
  (A : 12; B : 287.11; C : 31931.756),
  (A : 12; B : 320.81; C : 34777.259),
  (A : 9; B : 227.73; C : 1222.114),
  (A : 8; B : 15.45; C : 16859.074)
  );

// Calculates the Terrestrial Time of the Vernal equinox.

 Function VernalEquinoxTerrestrialTime(GregorianYear : Integer) : Extended;
  Var
   t    : Extended;
   w    : Extended;
   JDE0 : Extended;
   s    : Extended;
   i    : Integer;
  Begin
   If GregorianYear >= 1000 Then
    Begin
     // Years 1000-3000
     t    := (GregorianYear - 2000) / 1000.0;
     JDE0 := 2451623.80984
     + 365242.37404 * t
     + 0.05169 * t * t
     - 0.00411 * Power(t, 3)
     - 0.00057 * Power(t, 4);
    End
   Else
    Begin
     // Years -1000 to 999
     t    := GregorianYear / 1000.0;
     JDE0 := 1721139.29189
     + 365242.13740 * t
     + 0.06134 * t * t
     + 0.00111 * Power(t, 3)
     - 0.00071 * Power(t, 4);
    End;

   // Periodic terms (Meeus Ch. 27) use T in Julian centuries from J2000.
   // This is calculated for the moment of the Mean Equinox (JDE0).
   w := (JDE0 - J2000_JD) / 36525.0;

   s     := 0.0;
   For i := Low(VernalEquinoxCorrections) To High(VernalEquinoxCorrections) Do
    s    := s + VernalEquinoxCorrections[i].A * Cos((VernalEquinoxCorrections[i].B + VernalEquinoxCorrections[i].C * w) * Pi / 180.0);

   Result := JDE0 + s * 0.00001;
  End;

// Calculates the Julian Day of the Vernal equinox.

 Function VernalEquinoxJulianDay(Year : Integer) : Extended;
  Var
   TT : Extended;
   DT : Extended;
  Begin
   If (Year < MEEUS_MIN_YEAR) Or (Year > MEEUS_MAX_YEAR) Then
    Raise ERangeError.CreateResFmt(@SYearOutOfRange, [Year, MEEUS_MIN_YEAR, MEEUS_MAX_YEAR]);

   // Get equinox in Terrestrial Time
   TT := VernalEquinoxTerrestrialTime(Year);

   // Convert TT to UT using ΔT (estimate at mid-March)
   DT     := DeltaTSeconds(Year + 2.5 / 12.0);
   Result := TT - (DT / 86400.0);
  End;

End.
