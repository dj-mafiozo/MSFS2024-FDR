Unit FSLTLU;

Interface

 Uses
  System.SysUtils, System.Classes, System.SyncObjs, System.Generics.Collections;

 Type
  TAIModelProvider = (ampDefault, ampAIG, ampFSLTL);

  TFSLTLProfile = Record
   Prefix : String;
   ICAO   : String;
   Inputs : String;
  End;

  TAIModelInfo = Record
   Title        : String;
   Livery       : String;
   ICAO         : String;
   Airline      : String;
   Registration : String;
   Variation    : String;
   Model        : String;
   Provider     : TAIModelProvider;
  End;

  TAIModelInventory = Class(TThread)
   Private
    fLocal   : String;
    fRoaming : String;
    fModels  : TArray<TAIModelInfo>;
    fError   : String;
   Protected
    Procedure Execute; Override;
   Public
    Constructor Create(Const LocalData, RoamingData : String);
    Destructor Destroy; Override;
    Function Models : TArray<TAIModelInfo>;
    Property Error : String Read fError;
  End;

 Function FSLTLProfileIndex(Const Title : String) : Integer;
 Function FSLTLUses(Const Title, SimVar : String) : Boolean;
 Function AIModelMatchScore(Const Model : TAIModelInfo; Const ICAO, Airline, Registration, AircraftTitle : String) : Integer;
 Function ReadAIModels(Const Communities : TArray<String>) : TArray<TAIModelInfo>;

Implementation

 Uses
  System.IOUtils, System.IniFiles, System.StrUtils, System.Math, SimulatorPackagesU, AppLogU;

 Const
  {$I FSLTLProfiles.inc}
  Function FSLTLProfileIndex(Const Title : String) : Integer;

 Var
  i    : Integer;
  Best : Integer;
  t    : String;

Begin
 t      := UpperCase(Title);
 Result := -1;
 Best   := 0;
 For i  := 0 To High(FSLTLProfiles) Do
  If StartsText(FSLTLProfiles[i].Prefix, t) And (Length(FSLTLProfiles[i].Prefix) > Best) Then
   Begin
    Result := i;
    Best   := Length(FSLTLProfiles[i].Prefix);
   End;
End;

 Function FSLTLUses(Const Title, SimVar : String) : Boolean;
  Var
   i     : Integer;
   s     : String;
   Name  : String;
   Base  : String;
   Input : String;
  Begin
   Result := False;
   i      := FSLTLProfileIndex(Title);
   If i < 0 Then
    Exit;
   Name := UpperCase(SimVar);
   Base := Name.Split([':'])[0];
   For Input In FSLTLProfiles[i].Inputs.Split(['|']) Do
    Begin
     s := Input;
     If (s = Name) Or ((Pos('#', s) > 0) And StartsText(Base + ':', s)) Then
      Exit(True);
    End;
  End;

 Function Clean(Const s : String) : String;
  Var
   i      : Integer;
   Quoted : Boolean;
  Begin
   Result := Trim(s);
   Quoted := False;
   For i  := 1 To Length(Result) Do
    Begin
     If Result[i] = '"' Then
      Quoted := Not Quoted;
     If (Result[i] = ';') And Not Quoted Then
      Begin
       Result := Trim(Copy(Result, 1, i - 1));
       Break;
      End;
    End;
   If (Length(Result) >= 2) And (Result[1] = '"') And (Result[Length(Result)] = '"')Then
    Result := Copy(Result, 2, Length(Result) - 2);
  End;

 Function GeneralValue(Const FileName, Key : String; Depth : Integer = 0) : String;
  Var
   Ini  : TMemIniFile;
   Base : String;
  Begin
   Result := '';
   If (Depth > 4) Or Not FileExists(FileName) Then
    Exit;
   Ini := TMemIniFile.Create(FileName, TEncoding.UTF8);
   Try
    Result := Clean(Ini.ReadString('GENERAL', Key, ''));
    If Result = '' Then
     Begin
      Base := Clean(Ini.ReadString('VARIATION', 'base_container', ''));
      If Base <> '' Then
       Result := GeneralValue(TPath.GetFullPath(TPath.Combine(ExtractFileDir(FileName), Base + '\aircraft.cfg')), Key, Depth + 1);
     End;
   Finally
    Ini.Free;
   End;
  End;

 Function ReadAIModels(Const Communities : TArray<String>) : TArray<TAIModelInfo>;
  Var
   List         : TList<TAIModelInfo>;
   Community    : String;
   PackageDir   : String;
   AircraftDir  : String;
   Cfg          : String;
   Title        : String;
   ProviderName : String;
   TypeCode     : String;
   Ini          : TMemIniFile;
   Sections     : TStringList;
   Section      : String;
   m            : TAIModelInfo;
  Begin
   List     := TList<TAIModelInfo>.Create;
   Sections := TStringList.Create;
   Try
    For Community In Communities Do
     If DirectoryExists(Community) Then
      For PackageDir In TDirectory.GetDirectories(Community, '*', TSearchOption.soTopDirectoryOnly) Do
       Begin
        ProviderName := LowerCase(ExtractFileName(PackageDir));
        If (Pos('fsltl', ProviderName) = 0) And (Pos('aig', ProviderName) = 0) Then
         Continue;
        AircraftDir := TPath.Combine(PackageDir, 'SimObjects\Airplanes');
        If Not DirectoryExists(AircraftDir) Then
         Continue;
        For AircraftDir In TDirectory.GetDirectories(AircraftDir, '*', TSearchOption.soTopDirectoryOnly) Do
         Begin
          Cfg := TPath.Combine(AircraftDir, 'aircraft.cfg');
          If Not FileExists(Cfg) Then
           Continue;
          Ini := TMemIniFile.Create(Cfg, TEncoding.UTF8);
          Try
           TypeCode := UpperCase(GeneralValue(Cfg, 'icao_type_designator'));
           Sections.Clear;
           Ini.ReadSections(Sections);
           For Section In Sections Do
            If StartsText('FLTSIM.', Section) Then
             Begin
              Title := Clean(Ini.ReadString(Section, 'title', ''));
              If Title = '' Then
               Continue;
              m       := Default(TAIModelInfo);
              m.Title := Title;
              If (Pos('fsltl', ProviderName) > 0) Or StartsText('FSLTL_', Title) Then
               m.Provider := ampFSLTL
              Else
               m.Provider    := ampAIG;
              m.ICAO         := TypeCode;
              m.Airline      := UpperCase(Clean(Ini.ReadString(Section, 'icao_airline', Ini.ReadString(Section, 'atc_parking_codes', ''))));
              m.Registration := UpperCase(Clean(Ini.ReadString(Section, 'atc_id', '')));
              m.Livery       := Clean(Ini.ReadString(Section, 'ui_variation', ''));
              m.Variation    := Clean(Ini.ReadString(Section, 'atc_airline', ''));
              m.Model        := Clean(Ini.ReadString(Section, 'model', ''));
              List.Add(m);
             End;
          Finally
           Ini.Free;
          End;
         End;
       End;
    Result := List.ToArray;
   Finally
    Sections.Free;
    List.Free;
   End;
  End;

 Function AIModelMatchScore(Const Model : TAIModelInfo; Const ICAO, Airline, Registration, AircraftTitle : String) : Integer;
  Var
   Exact    : Boolean;
   TypeCode : String;
   Target   : String;
   Title    : String;
   Carrier  : String;
   Tail     : String;
  Begin
   Result   := -1;
   TypeCode := UpperCase(Model.ICAO);
   Target   := UpperCase(ICAO);
   Title    := UpperCase(Model.Title + ' ' + Model.Livery + ' ' + Model.Variation);
   Exact    := (TypeCode <> '') And (TypeCode = Target);
   If Exact Then
    Result := 50000
   Else If ((Target = 'B38M') And (TypeCode = 'B738')) Or ((Target = 'A320') And (TypeCode = 'A20N')) Or ((Target = 'A321') And (TypeCode = 'A21N')) Then
    Result := 20000
   Else
    Exit;
   Carrier := UpperCase(Airline);
   Tail    := UpperCase(Registration);
   If (Tail <> '') And ((SameText(Tail, Model.Registration)) Or (Pos(Tail, Title) > 0)) Then
    Inc(Result, 9000);
   If (Model.Airline <> '') And (Model.Airline <> 'ZZZZ') And (Pos(' ' + UpperCase(Model.Airline) + ' ', ' ' + UpperCase(AircraftTitle) + ' ') > 0) Then
    Inc(Result, 5000);
   If (Carrier <> '') And ((SameText(Carrier, Model.Airline)) Or ((Model.Airline = '') And (Pos(Carrier, Title) > 0)) Or ((Length(Carrier) >= 3) And SameText(Copy(Carrier, 1, 3), Model.Airline))) Then
    Inc(Result, 5000);
   If (Model.Livery <> '') And (Pos(UpperCase(Model.Livery), UpperCase(AircraftTitle)) > 0)Then
    Inc(Result, 3000);
   If Pos('-STUB', Title) > 0 Then
    Dec(Result, 2000);
   If Model.Provider = ampFSLTL Then
    Inc(Result, 300)
   Else If Model.Provider = ampAIG Then
    Inc(Result, 200);
  End;

 Constructor TAIModelInventory.Create(Const LocalData, RoamingData : String);
  Begin
   Inherited Create(True);
   FreeOnTerminate := False;
   fLocal          := LocalData;
   fRoaming        := RoamingData;
  End;

 Destructor TAIModelInventory.Destroy;
  Begin
   Terminate;
   If Suspended Then
    Start;
   WaitFor;
   Inherited;
  End;

 Procedure TAIModelInventory.Execute;
  Begin
   Try
    If Not Terminated Then
     fModels := ReadAIModels(SimulatorCommunityDirectories(fLocal, fRoaming));
   Except
    On E : Exception Do
     Begin
      fError := E.Message;
      Log(1, 'AI model inventory: ' + fError);
     End;
   End;
  End;

 Function TAIModelInventory.Models : TArray<TAIModelInfo>;
  Begin
   WaitFor;
   Result := fModels;
  End;

End.
