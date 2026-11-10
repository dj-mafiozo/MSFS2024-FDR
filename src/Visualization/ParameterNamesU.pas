{$StackFrames On}
Unit ParameterNamesU;

Interface

 Uses
  System.IniFiles, System.Classes;

 Const
  DisplayUnitCount = 23;

 Function SourceDisplayUnit(Index : Integer) : String;
 Function DisplayUnitOptions(Const Source : String) : String;
 Procedure LoadDisplayUnits(Config : TCustomIniFile);
 Procedure SaveDisplayUnit(Config : TCustomIniFile; Const Source, Target : String);
 Function ParameterDisplayText(Const Identifier : String; Value : Double; Const AircraftICAO : String = ''; Const AircraftTitle : String = ''; FlapPositionCount : Integer = 0) : String;
 Function GSXDisplayText(Const Identifier : String; Labels : TStrings; Const Values : TArray<Double>) : String;
 Function ParameterDisplayValue(Const Identifier : String; Value : Double) : Double;
 Function ParameterDisplayUnit(Const Identifier : String) : String;
 Function ParameterSourceUnit(Const Identifier : String) : String;
 Function ParameterCaption(Const Identifier : String) : String;

Implementation

 Uses
  System.SysUtils, System.StrUtils, System.Generics.Collections,
  FlapsHandleU, TelemetryCatalogU, AirlinerCatalogU, LocalizationU, System.Math,
  iFlySDKCatalogU, PMDGNG3CatalogU, PMDG777CatalogU, FenixCatalogU, FBWCatalogU, GSXVarsU, AddonLVarCatalogU;

 Var
  ValueLabels   : TObjectDictionary<String, TStringList>;
  Captions      : TDictionary<String, String>;
  Units         : TDictionary<String, String>;
  CurrentLocale : String;
  DisplayUnits  : TDictionary<String, String>;

 Function UnitCaption(Const Value : String) : String;
  Begin
   If SameText(Value, 'MHz') Then
    Exit('MHz');
   If SameText(Value, 'KHz') Then
    Exit('kHz');
   If SameText(Value, 'Nautical miles') Then
    Exit('NM');
   If SameText(Value, 'Radians') Then
    Exit('rad');
   Case IndexText(Value, ['Feet', 'Feet per minute', 'Feet/minute', 'Degrees', 'Knots', 'Celsius', 'Percent', 'Percent Over 100', 'Millibars', 'inHg', 'GForce', 'Gallons', 'Pounds', 'Pounds per hour', 'RPM', 'Hours', 'Seconds', 'Volts', 'Meters', 'Meters per second', 'psf', 'psi', 'Mach', 'Kelvin', 'Amps']) Of
    0  : Result := 'ft';
    1  : Result := 'ft/min';
    2  : Result := 'ft/min';
    3  : Result := #$00B0;
    4  : Result := 'kt';
    5  : Result := #$00B0 + 'C';
    6  : Result := '%';
    7  : Result := '0' + #$2013 + '1';
    8  : Result := 'hPa';
    9  : Result := 'inHg';
    10 : Result := 'g';
    11 : Result := 'US gal';
    12 : Result := 'lb';
    13 : Result := 'lb/h';
    14 : Result := 'rpm';
    15 : Result := 'h';
    16 : Result := 's';
    17 : Result := 'V';
    18 : Result := 'm';
    19 : Result := 'm/s';
    20 : Result := 'psf';
    21 : Result := 'psi';
    22 : Result := 'Mach';
    23 : Result := 'K';
    24 : Result := 'A';
   Else Result := '';
   End;
  End;

 Procedure EnsureMetadata;
  Var
   i : Integer;
  Begin
   If Units <> Nil Then
    Exit;
   Units := TDictionary<String, String>.Create;
   For i := Low(NumericColumns) To High(NumericColumns) Do
    Units.AddOrSetValue(NumericColumns[i].Name, UnitCaption(SimFields[NumericColumns[i].FieldIndex].Units));
   For i := Low(AirlinerNames) To High(AirlinerNames) Do
    Units.AddOrSetValue(LowerCase('AirlinerLVar.' + AirlinerNames[i]), UnitCaption(AirlinerUnits[i]));
   For i := Low(EngineColumns) To High(EngineColumns) Do
    Units.AddOrSetValue(EngineColumns[i].Name, UnitCaption(SimFields[EngineColumns[i].FieldIndex].Units));
   Units.AddOrSetValue('turn_indicator_rate', #$00B0 + '/s');
   Units.AddOrSetValue('turn_coordinator_ball', '-127..127');
   Units.AddOrSetValue('pmdg777.fmc_v1', 'kt');
   Units.AddOrSetValue('pmdg777.fmc_vr', 'kt');
   Units.AddOrSetValue('pmdg777.fmc_v2', 'kt');
   Units.AddOrSetValue('pmdg777.fmc_landingvref', 'kt');
   Units.AddOrSetValue('pmdg777.fmc_cruisealt', 'ft');
   Units.AddOrSetValue('pmdg777.fmc_landingaltitude', 'ft');
   Units.AddOrSetValue('pmdg777.fmc_transitionalt', 'ft');
   Units.AddOrSetValue('pmdg777.fmc_transitionlevel', 'ft');
   Units.AddOrSetValue('pmdg777.fmc_accelerationalt', 'ft');
   Units.AddOrSetValue('pmdg777.fmc_eoaccelerationalt', 'ft');
   Units.AddOrSetValue('pmdg777.mcp_heading', '°');
   Units.AddOrSetValue('pmdg777.mcp_altitude', 'ft');
   Units.AddOrSetValue('pmdg777.mcp_vertspeed', 'ft/min');
   Units.AddOrSetValue('pmdg777.mcp_fpa', '°');
   Units.AddOrSetValue('pmdg777.fuel_qtycenter', 'lb');
   Units.AddOrSetValue('pmdg777.fuel_qtyleft', 'lb');
   Units.AddOrSetValue('pmdg777.fuel_qtyright', 'lb');
   Units.AddOrSetValue('pmdg777.fuel_qtyaux', 'lb');
  End;

 Function SourceDisplayUnit(Index : Integer) : String;
  Const
   Names : Array [0..DisplayUnitCount - 1] Of String = ('ft', 'ft/min', #$00B0, 'kt', #$00B0 + 'C', '%', '0' + #$2013 + '1', 'hPa', 'inHg', 'g', 'US gal', 'lb', 'lb/h', 'rpm', 'h', 's', 'V', 'm', 'm/s', 'psf', 'psi', 'Mach', 'K');
  Begin
   Result := Names[Index];
  End;

 Function DisplayUnitOptions(Const Source : String) : String;
  Begin
   Result := Source;
   If (Source = 'ft') Or (Source = 'm') Then
    Result := 'ft,m,km'
   Else If (Source = 'ft/min') Or (Source = 'm/s') Or (Source = 'kt') Then
    Result := 'ft/min,m/s,kt,km/h'
   Else If (Source = 'lb') Then
    Result := 'lb,kg'
   Else If (Source = 'lb/h') Then
    Result := 'lb/h,kg/h'
   Else If (Source = 'US gal') Then
    Result := 'US gal,l'
   Else If (Source = 'hPa') Or (Source = 'inHg') Or (Source = 'psf') Or (Source = 'psi') Then
    Result := 'hPa,inHg,psf,psi,Pa,kPa'
   Else If (Source = #$00B0 + 'C') Or (Source = 'K') Then
    Result := #$00B0 + 'C,' + #$00B0 + 'F,K'
   Else If Source = #$00B0 Then
    Result := #$00B0 + ',rad'
   Else If (Source = 'h') Or (Source = 's') Then
    Result := 'h,min,s'
   Else If (Source = '%') Or (Source = '0' + #$2013 + '1') Then
    Result := '%,0' + #$2013 + '1';
  End;

 Function ValidTarget(Const Source, Target : String) : Boolean;
  Var
   Options : TStringList;
  Begin
   Options := TStringList.Create;
   Try
    Options.StrictDelimiter := True;
    Options.Delimiter       := ',';
    Options.DelimitedText   := DisplayUnitOptions(Source);
    Result                  := Options.IndexOf(Target) >= 0;
   Finally
    Options.Free;
   End;
  End;

 Procedure LoadDisplayUnits(Config : TCustomIniFile);
  Var
   i      : Integer;
   Source : String;
   Target : String;
  Begin
   If DisplayUnits = Nil Then
    DisplayUnits := TDictionary<String, String>.Create;
   DisplayUnits.Clear;
   For i := 0 To DisplayUnitCount - 1 Do
    Begin
     Source := SourceDisplayUnit(i);
     Target := Config.ReadString('display_units', Source, Source);
     If ValidTarget(Source, Target) Then
      DisplayUnits.AddOrSetValue(Source, Target);
    End;
   If Captions <> Nil Then
    Captions.Clear;
  End;

 Procedure SaveDisplayUnit(Config : TCustomIniFile; Const Source, Target : String);
  Begin
   If ValidTarget(Source, Target) Then
    Config.WriteString('display_units', Source, Target);
  End;

 Function TargetUnit(Const Source : String) : String;
  Begin
   Result := Source;
   If DisplayUnits <> Nil Then
    If Not DisplayUnits.TryGetValue(Source, Result) Then
     Result := Source;
  End;

 Function ParameterSourceUnit(Const Identifier : String) : String;
  Var
   Base : String;
   p    : Integer;
  Begin
   EnsureMetadata;
   Base := Identifier;
   If Pos('.', Base) = 0 Then
    Begin
     p := LastDelimiter('#', Base);
     If p > 0 Then
      Base := Trim(Copy(Base, 1, p - 1));
    End;
   If Not Units.TryGetValue(LowerCase(Base), Result) Then
    Result := '';
  End;

 Procedure UnitScale(Const Name : String; Out Factor, Offset : Double);
  Begin
   Factor := 1;
   Offset := 0;
   If Name = 'ft' Then
    Factor := 0.3048
   Else If Name = 'km' Then
    Factor := 1000
   Else If Name = 'ft/min' Then
    Factor := 0.3048 / 60
   Else If Name = 'kt' Then
    Factor := 1852 / 3600
   Else If Name = 'km/h' Then
    Factor := 1 / 3.6
   Else If (Name = 'lb') Or (Name = 'lb/h') Then
    Factor := 0.45359237
   Else If Name = 'US gal' Then
    Factor := 3.785411784
   Else If Name = 'hPa' Then
    Factor := 100
   Else If Name = 'inHg' Then
    Factor := 3386.389
   Else If Name = 'psf' Then
    Factor := 47.8802589803358
   Else If Name = 'psi' Then
    Factor := 6894.757293168
   Else If Name = 'kPa' Then
    Factor := 1000
   Else If Name = #$00B0 + 'C' Then
    Offset := 273.15
   Else If Name = #$00B0 + 'F' Then
    Begin
     Factor := 5 / 9;
     Offset := 273.15 - 32 * 5 / 9;
    End
   Else If Name = #$00B0 Then
    Factor := Pi / 180
   Else If Name = 'h' Then
    Factor := 3600
   Else If Name = 'min' Then
    Factor := 60
   Else If Name = '%' Then
    Factor := 0.01;
  End;

 Function ParameterDisplayUnit(Const Identifier : String) : String;
  Begin
   Result := TargetUnit(ParameterSourceUnit(Identifier));
  End;

 Function ParameterDisplayValue(Const Identifier : String; Value : Double) : Double;
  Var
   Source : String;
   Target : String;
   a      : Double;
   b      : Double;
   c      : Double;
   d      : Double;
  Begin
   Result := Value;
   Source := ParameterSourceUnit(Identifier);
   Target := TargetUnit(Source);
   If (Source = '') Or (Source = Target) Or IsNan(Value) Or IsInfinite(Value) Then
    Exit;
   UnitScale(Source, a, b);
   UnitScale(Target, c, d);
   Result := (Value * a + b - d) / c;
  End;

 Procedure EnsureValueLabels;
  Var
   i : Integer;
   j : Integer;

   Procedure Add(Const Name, Definition : String);
    Var
     List : TStringList;
    Begin
     If Definition = '' Then
      Exit;
     List                    := TStringList.Create;
     List.NameValueSeparator := '=';
     List.Text               := StringReplace(Definition, '\r\n', #13#10, [rfReplaceAll]);
     ValueLabels.AddOrSetValue(LowerCase(Name), List);
    End;

  Begin
   If ValueLabels <> Nil Then
    Exit;
   ValueLabels := TObjectDictionary<String, TStringList>.Create([doOwnsValues]);
   For i       := 0 To High(SimFields) Do
    Add(SimFields[i].Name, SimFields[i].DisplayValue);
   For i := 0 To High(NumericColumns) Do
    Add(NumericColumns[i].Name, SimFields[NumericColumns[i].FieldIndex].DisplayValue);
   For i := 0 To High(EngineColumns) Do
    Begin
     Add(EngineColumns[i].Name, SimFields[EngineColumns[i].FieldIndex].DisplayValue);
     For j := 1 To 16 Do
      Add(EngineColumns[i].Name + ' #' + IntToStr(j), SimFields[EngineColumns[i].FieldIndex].DisplayValue);
    End;
   For i := 0 To High(SDKFields) Do
    Add('iFlySDK.' + SDKFields[i].Name, SDKFields[i].DisplayValue);
   For i := 0 To High(PMDGFields) Do
    Add('PMDGNG3.' + PMDGFields[i].Name, PMDGFields[i].DisplayValue);
   For i := 0 To High(PMDG777Fields) Do
    Add('PMDG777.' + PMDG777Fields[i].Name, PMDG777Fields[i].DisplayValue);
   For i := 0 To High(FenixFields) Do
    Add('FenixLVar.' + FenixFields[i].Name, FenixFields[i].DisplayValue);
   For i := 0 To High(FBWFields) Do
    Add('FBWLVar.' + FBWFields[i].Name, FBWFields[i].DisplayValue);
   For i := 0 To High(GSXFields) Do
    Add('GSX.' + GSXFields[i].Name, GSXFields[i].DisplayValue);
   For i := 0 To High(AddonFields) Do
    Add(AddonFields[i].Provider + '.' + AddonFields[i].Name, AddonFields[i].DisplayValue);
  End;

 Function ParameterDisplayText(Const Identifier : String; Value : Double; Const AircraftICAO, AircraftTitle : String; FlapPositionCount : Integer) : String;
  Var
   List       : TStringList;
   Key        : String;
   Lookup     : String;
   Definition : String;
   Index      : Integer;
  Begin
   Result := '-';
   If IsNan(Value) Or IsInfinite(Value) Then
    Exit;
   EnsureValueLabels;
   Lookup := LowerCase(Identifier);
   If SameText(Identifier, 'flaps_handle_index') Then
    Begin
     Lookup := '@flaps:' + UpperCase(Trim(AircraftICAO)) + ':' + UpperCase(AircraftTitle) + ':' + IntToStr(FlapPositionCount);
     If Not ValueLabels.ContainsKey(Lookup) Then
      Begin
       Definition := FlapsHandleDisplayValue(AircraftICAO, AircraftTitle, FlapPositionCount);
       List       := TStringList.Create;
       List.Text  := StringReplace(Definition, '\r\n', #13#10, [rfReplaceAll]);
       ValueLabels.Add(Lookup, List);
      End;
    End;
   If ValueLabels.TryGetValue(Lookup, List) And (Abs(Value) < 1E15) Then
    If Value = Trunc(Value) Then
     Begin
      Key   := Format('%.0f', [Value]);
      Index := List.IndexOfName(Key);
      If Index >= 0 Then
       Begin
        Result := List.ValueFromIndex[Index];
        If StartsText('GSX.', Identifier) Then
         Result := Tr(Result);
        Exit;
       End;
     End;
   Result := Format('%.8g', [ParameterDisplayValue(Identifier, Value)]);
  End;

 Function GSXDisplayText(Const Identifier : String; Labels : TStrings; Const Values : TArray<Double>) : String;
  Var
   Name        : String;
   Direction   : String;
   CurrentText : String;
   TargetText  : String;
   CargoText   : String;
   v           : Double;
   Current     : Double;
   Target      : Double;
   Cargo       : Double;
   k           : Integer;

   Function Read(Const Field : String) : Double;
    Var
     n : Integer;
    Begin
     Result := NaN;
     n      := Labels.IndexOf('GSX.' + Field);
     If (n >= 0) And (n < Length(Values)) And Not IsInfinite(Values[n]) Then
      Result := Values[n];
    End;

   Function CountText(Number : Double) : String;
    Begin
     Result := '-';
     If Not IsNan(Number) And (Number >= 0) Then
      Result := Format('%.0f', [Number]);
    End;

  Begin
   Name   := Copy(Identifier, 5, MaxInt);
   v      := Read(Name);
   Result := ParameterDisplayText(Identifier, v);
   If IsNan(v) Or IsInfinite(v) Then
    Exit;
   If EndsText('_STATE', Name) Then
    Begin
     If IsNan(v) Or IsInfinite(v) Or (v < 1) Or (v > 6) Or (v <> Trunc(v)) Then
      Exit(Tr('Brak danych'));
     k         := Trunc(v);
     Direction := '';
     If Name = 'FSDT_GSX_BOARDING_STATE' Then
      Direction := 'BOARDING';
     If Name = 'FSDT_GSX_DEBOARDING_STATE' Then
      Direction := 'DEBOARDING';
     If (Direction <> '') And (k In [5, 6]) Then
      Begin
       Current := Read('FSDT_GSX_NUMPASSENGERS_' + Direction + '_TOTAL');
       Target  := Read('FSDT_GSX_NUMPASSENGERS');
       If Not IsNan(Target) Then
        If Target <= 0 Then
         Target    := NaN;
       Cargo       := Read('FSDT_GSX_' + Direction + '_CARGO_PERCENT');
       CurrentText := CountText(Current);
       TargetText  := CountText(Target);
       CargoText   := '-';
       If Not IsNan(Cargo) And (Cargo >= 0) And (Cargo <= 100) Then
        CargoText := Format('%.0f%%', [Cargo]);
       Result     := Result + ' (' + Format(Tr('Passengers: %s/%s; baggage: %s'), [CurrentText, TargetText, CargoText]) + ')';
      End;
    End
   Else If EndsText('_CARGO_PERCENT', Name) And Not IsNan(v) And (v >= 0) And (v <= 100) Then
    Result := Format('%.0f%%', [v])
   Else If (Name = 'FSDT_GSX_BOARDING_CARGO') Or (Name = 'FSDT_GSX_DEBOARDING_CARGO') Or (Name = 'FSDT_VAR_Frozen') Then
    Begin
     If v = 0 Then
      Result := Tr('Inactive')
     Else If v = 1 Then
      Result := Tr('Active');
    End;
  End;

 Function Humanize(Const Name : String) : String;
  Var
   i     : Integer;
   Word  : String;
   Token : String;

   Procedure Flush;
    Begin
     If Word = '' Then
      Exit;
     Token := TrDomain(LowerCase(Word), 'ParameterWords');
     If Token = LowerCase(Word) Then
      Begin
       If (Length(Word) <= 3) And (Word = UpperCase(Word)) Then
        Token := Word
       Else
        Token := LowerCase(Word);
      End;
     If Result <> '' Then
      Result := Result + ' ';
     Result  := Result + Token;
     Word    := '';
    End;

  Begin
   Result := '';
   Word   := '';
   For i  := 1 To Length(Name) Do
    Begin
     If CharInSet(Name[i], ['_', '.', '-', ' ']) Then
      Flush
     Else If Name[i] = '[' Then
      Begin
       Flush;
       If Result <> '' Then
        Result := Result + ' ';
       Word    := '[';
      End
     Else If Name[i] = ']' Then
      Begin
       Word := Word + ']';
       Flush;
      End
     Else
      Begin
       If (i > 1) And CharInSet(Name[i], ['A'..'Z']) And (CharInSet(Name[i - 1], ['a'..'z']) Or ((i < Length(Name)) And CharInSet(Name[i - 1], ['A'..'Z']) And CharInSet(Name[i + 1], ['a'..'z']))) Then
        Flush;
       If (i > 1) And CharInSet(Name[i], ['0'..'9']) And CharInSet(Name[i - 1], ['a'..'z', 'A'..'Z']) And Not SameText(Word, 'N') And Not SameText(Word, 'V') Then
        Flush;
       Word := Word + Name[i];
      End;
    End;
   Flush;
   If Result <> '' Then
    Result[1] := UpperCase(Copy(Result, 1, 1))[1];
  End;

 Function ParameterCaption(Const Identifier : String) : String;
  Var
   Base     : String;
   Source   : String;
   Suffix   : String;
   UnitText : String;
   Engine   : String;
   Locale   : String;
   p        : Integer;
  Begin
   // UI-only cache: never used by the recorder or database schema.
   Locale := Language;
   If Captions = Nil Then
    Captions := TDictionary<String, String>.Create;
   If CurrentLocale <> Locale Then
    Begin
     Captions.Clear;
     CurrentLocale := Locale;
    End;
   If Captions.TryGetValue(Identifier, Result) Then
    Exit;
   EnsureMetadata;
   Base     := Identifier;
   Source   := '';
   Suffix   := '';
   UnitText := '';
   p        := Pos('.', Base);
   If p > 0 Then
    Case IndexText(Copy(Base, 1, p - 1), ['iFlySDK', 'FenixLVar', 'FBWLVar', 'PMDGNG3', 'AirlinerLVar', 'GSX', 'FSHud', 'PMDG777', 'PMDGDC6', 'CSS737', 'MaddogX', 'SkySimDC9', 'SkySimMD11', 'TFDiMD11', 'AsoboBell407', 'AsoboEC135']) Of
     0  : Source := 'iFly';
     1  : Source := 'Fenix';
     2  : Source := 'FBW';
     3  : Source := 'PMDG 737';
     4  : Source := 'Airliner';
     5  : Source := 'GSX';
     6  : Source := 'FSHud';
     7  : Source := 'PMDG 777';
     8  : Source := 'PMDG DC-6';
     9  : Source := 'CSS 737';
     10 : Source := 'Maddog X';
     11 : Source := 'SkySim DC-9';
     12 : Source := 'SkySim MD-11';
     13 : Source := 'TFDi MD-11';
     14 : Source := 'Bell 407';
     15 : Source := 'EC135';
    End;
   If Source <> '' Then
    Delete(Base, 1, p);
   p := LastDelimiter('#', Base);
   If (p > 0) And (Source = '') And TryStrToInt(Trim(Copy(Base, p + 1, MaxInt)), p) Then
    Begin
     Engine := Trim(Copy(Base, LastDelimiter('#', Base) + 1, MaxInt));
     Base   := Trim(Copy(Base, 1, LastDelimiter('#', Base) - 1));
     Suffix := ' — ' + TrDomain('engine', 'ParameterWords') + ' ' + Engine;
    End;
   Result := TrDomain(Base, 'Parameters');
   If Result = Base Then
    Result := Humanize(Base);
   If Source = '' Then
    Units.TryGetValue(LowerCase(Base), UnitText)
   Else
    Units.TryGetValue(LowerCase(Identifier), UnitText);
   UnitText := TargetUnit(UnitText);
   If UnitText <> '' Then
    UnitText := ' [' + UnitText + ']';
   Result    := Result + Suffix + UnitText;
   If Source <> '' Then
    Result := Source + ' · ' + Result;
   Captions.AddOrSetValue(Identifier, Result);
  End;

Initialization

 Captions := Nil;
 Units    := Nil;

Finalization

 ValueLabels.Free;
 DisplayUnits.Free;
 Captions.Free;
 Units.Free;

End.
