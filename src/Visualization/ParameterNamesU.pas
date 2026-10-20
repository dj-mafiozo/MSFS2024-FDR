{$StackFrames On}
Unit ParameterNamesU;

Interface

 Uses
  System.IniFiles;

 Const
  DisplayUnitCount = 23;

 Function SourceDisplayUnit(Index : Integer) : String;
 Function DisplayUnitOptions(Const Source : String) : String;
 Procedure LoadDisplayUnits(Config : TCustomIniFile);
 Procedure SaveDisplayUnit(Config : TCustomIniFile; Const Source, Target : String);
 Function ParameterDisplayValue(Const Identifier : String; Value : Double) : Double;
 Function ParameterSourceUnit(Const Identifier : String) : String;

 Function ParameterCaption(Const Identifier : String) : String;

Implementation

 Uses
  System.SysUtils, System.StrUtils, System.Classes, System.Generics.Collections,
  TelemetryCatalogU, AirlinerCatalogU, LocalizationU, System.Math;

 Var
  Captions      : TDictionary<String, String>;
  Units         : TDictionary<String, String>;
  CurrentLocale : String;
  DisplayUnits  : TDictionary<String, String>;

 Function UnitCaption(Const Value : String) : String;
  Begin
   Case IndexText(Value, ['Feet', 'Feet per minute', 'Feet/minute', 'Degrees', 'Knots', 'Celsius', 'Percent', 'Percent Over 100', 'Millibars', 'inHg', 'GForce', 'Gallons', 'Pounds', 'Pounds per hour', 'RPM', 'Hours', 'Seconds', 'Volts', 'Meters', 'Meters per second', 'psf', 'psi', 'Mach', 'Kelvin']) Of
    0 :
     Result := 'ft';
    1, 2 :
     Result := 'ft/min';
    3 :
     Result := #$00B0;
    4 :
     Result := 'kt';
    5 :
     Result := #$00B0 + 'C';
    6 :
     Result := '%';
    7 :
     Result := '0' + #$2013 + '1';
    8 :
     Result := 'hPa';
    9 :
     Result := 'inHg';
    10 :
     Result := 'g';
    11 :
     Result := 'US gal';
    12 :
     Result := 'lb';
    13 :
     Result := 'lb/h';
    14 :
     Result := 'rpm';
    15 :
     Result := 'h';
    16 :
     Result := 's';
    17 :
     Result := 'V';
    18 :
     Result := 'm';
    19 :
     Result := 'm/s';
    20 :
     Result := 'psf';
    21 :
     Result := 'psi';
    22 :
     Result := 'Mach';
    23 :
     Result := 'K';
    Else
     Result := '';
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
  End;

 Function SourceDisplayUnit(Index : Integer) : String;
  Const
   Names : Array [0 .. DisplayUnitCount - 1] Of String = ('ft', 'ft/min', #$00B0, 'kt', #$00B0 + 'C', '%', '0' + #$2013 + '1', 'hPa', 'inHg', 'g', 'US gal', 'lb', 'lb/h', 'rpm', 'h', 's', 'V', 'm', 'm/s', 'psf', 'psi', 'Mach', 'K');
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
   P    : Integer;
  Begin
   EnsureMetadata;
   Base := Identifier;
   If Pos('.', Base) = 0 Then
    Begin
     P := LastDelimiter('#', Base);
     If P > 0 Then
      Base := Trim(Copy(Base, 1, P - 1));
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

 Function ParameterDisplayValue(Const Identifier : String; Value : Double) : Double;
  Var
   Source : String;
   Target : String;
   A      : Double;
   B      : Double;
   C      : Double;
   D      : Double;
  Begin
   Result := Value;
   Source := ParameterSourceUnit(Identifier);
   Target := TargetUnit(Source);
   If (Source = '') Or (Source = Target) Or IsNan(Value) Or IsInfinite(Value) Then
    Exit;
   UnitScale(Source, A, B);
   UnitScale(Target, C, D);
   Result := (Value * A + B - D) / C;
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
       If (i > 1) And CharInSet(Name[i], ['A' .. 'Z']) And (CharInSet(Name[i - 1], ['a' .. 'z']) Or ((i < Length(Name)) And CharInSet(Name[i - 1], ['A' .. 'Z']) And CharInSet(Name[i + 1], ['a' .. 'z']))) Then
        Flush;
       If (i > 1) And CharInSet(Name[i], ['0' .. '9']) And CharInSet(Name[i - 1], ['a' .. 'z', 'A' .. 'Z']) And Not SameText(Word, 'N') And Not SameText(Word, 'V') Then
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
   P        : Integer;
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
   P        := Pos('.', Base);
   If P > 0 Then
    Case IndexText(Copy(Base, 1, P - 1), ['iFlySDK', 'FenixLVar', 'FBWLVar', 'PMDGNG3', 'AirlinerLVar', 'GSX', 'FSHud']) Of
     0 :
      Source := 'iFly';
     1 :
      Source := 'Fenix';
     2 :
      Source := 'FBW';
     3 :
      Source := 'PMDG 737';
     4 :
      Source := 'Airliner';
     5 :
      Source := 'GSX';
     6 :
      Source := 'FSHud';
    End;
   If Source <> '' Then
    Delete(Base, 1, P);
   P := LastDelimiter('#', Base);
   If (P > 0) And (Source = '') And TryStrToInt(Trim(Copy(Base, P + 1, MaxInt)), P) Then
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

 DisplayUnits.Free;
 Captions.Free;
 Units.Free;

End.
