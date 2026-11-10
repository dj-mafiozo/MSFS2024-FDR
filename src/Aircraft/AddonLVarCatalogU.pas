{$StackFrames On}
Unit AddonLVarCatalogU;

Interface

 Uses
  AddonLVarTypesU;

 Type
  TAddonLVarField = AddonLVarTypesU.TAddonLVarField;

  TAddonLVarProfile = AddonLVarTypesU.TAddonLVarProfile;

{ FLD+ }

 Const
  AddonProfileCount = 8;
  AddonFieldCount   = 5050;
  AddonProfiles : Array [0..AddonProfileCount - 1] Of TAddonLVarProfile =
   (
    (Provider: 'PMDGDC6';      Title: 'PMDG DC-6';          First: 0;    Count: 904),
    (Provider: 'CSS737';       Title: 'CSS 737 Classic';    First: 904;  Count: 1221),
    (Provider: 'MaddogX';      Title: 'Leonardo Maddog X';  First: 2125; Count: 365),
    (Provider: 'SkySimDC9';    Title: 'SkySim DC-9';        First: 2490; Count: 488),
    (Provider: 'SkySimMD11';   Title: 'SkySim MD-11';       First: 2978; Count: 320),
    (Provider: 'TFDiMD11';     Title: 'TFDi Design MD-11';  First: 3298; Count: 1446),
    (Provider: 'AsoboBell407'; Title: 'Microsoft Bell 407'; First: 4744; Count: 72),
    (Provider: 'AsoboEC135';   Title: 'Microsoft EC135';    First: 4816; Count: 234)
   );

  AddonTitles : Array [0..51] Of TAddonTitle =
   (
    (Profile: 0; Title: 'PMDG DC-6A PMDG House (N6PA | 2021)'),
    (Profile: 0; Title: 'PMDG DC-6B PMDG House (N6PB | 2021)'),
    (Profile: 0; Title: 'PMDG DC-6B PMDG House (N6PM | 2021)'),
    (Profile: 1; Title: 'CSS B737-500 18K'),
    (Profile: 1; Title: 'CSS B737-500 20K'),
    (Profile: 1; Title: 'CSS B737-500W 20K'),
    (Profile: 2; Title: 'Fly The Maddog X MD-82 20th'),
    (Profile: 2; Title: 'Fly The Maddog X MD-83 20th'),
    (Profile: 2; Title: 'Fly The Maddog X MD-88 20th'),
    (Profile: 3; Title: 'McDonnell Douglas DC-9-10 BMI'),
    (Profile: 3; Title: 'McDonnell Douglas DC-9-10 CONTINENTAL'),
    (Profile: 3; Title: 'McDonnell Douglas DC-9-10 FINNAIR'),
    (Profile: 3; Title: 'McDonnell Douglas DC-9-10 NORTHWEST'),
    (Profile: 3; Title: 'McDonnell Douglas DC-9-10 OZARK'),
    (Profile: 3; Title: 'McDonnell Douglas DC-9-10 SWISSAIR'),
    (Profile: 3; Title: 'McDonnell Douglas DC-9-10 TWA'),
    (Profile: 3; Title: 'McDonnell Douglas DC-9-10F AMERISTAR'),
    (Profile: 3; Title: 'McDonnell Douglas DC-9-10F KALITTA'),
    (Profile: 3; Title: 'McDonnell Douglas DC-9-10F USA'),
    (Profile: 3; Title: 'McDonnell Douglas DC-9-30 AEROMEXICO'),
    (Profile: 3; Title: 'McDonnell Douglas DC-9-30 AIRTRAN'),
    (Profile: 3; Title: 'McDonnell Douglas DC-9-30 ALITALIA'),
    (Profile: 3; Title: 'McDonnell Douglas DC-9-30 ANSETT'),
    (Profile: 3; Title: 'McDonnell Douglas DC-9-30 EASTERN'),
    (Profile: 3; Title: 'McDonnell Douglas DC-9-30 KLM'),
    (Profile: 3; Title: 'McDonnell Douglas DC-9-30 PSA'),
    (Profile: 3; Title: 'McDonnell Douglas DC-9-30 USAIR'),
    (Profile: 3; Title: 'McDonnell Douglas DC-9-33 AERONAVES TSM'),
    (Profile: 3; Title: 'McDonnell Douglas DC-9-33 DHL'),
    (Profile: 3; Title: 'McDonnell Douglas DC-9-33 EVERTS'),
    (Profile: 4; Title: 'McDonnell Douglas MD-11 Alitalia'),
    (Profile: 4; Title: 'McDonnell Douglas MD-11 Delta'),
    (Profile: 4; Title: 'McDonnell Douglas MD-11 EVA Air'),
    (Profile: 4; Title: 'McDonnell Douglas MD-11 Fedex'),
    (Profile: 4; Title: 'McDonnell Douglas MD-11 Finnair'),
    (Profile: 4; Title: 'McDonnell Douglas MD-11 Garuda'),
    (Profile: 4; Title: 'McDonnell Douglas MD-11 Japan'),
    (Profile: 4; Title: 'McDonnell Douglas MD-11 KLM'),
    (Profile: 4; Title: 'McDonnell Douglas MD-11 Korean'),
    (Profile: 4; Title: 'McDonnell Douglas MD-11 Koren Air Cargo'),
    (Profile: 4; Title: 'McDonnell Douglas MD-11 LTU'),
    (Profile: 4; Title: 'McDonnell Douglas MD-11 Lufthansa'),
    (Profile: 4; Title: 'McDonnell Douglas MD-11 MartinAir'),
    (Profile: 4; Title: 'McDonnell Douglas MD-11 SaudiArabian'),
    (Profile: 4; Title: 'McDonnell Douglas MD-11 Swissair'),
    (Profile: 4; Title: 'McDonnell Douglas MD-11 Thai Airways'),
    (Profile: 4; Title: 'McDonnell Douglas MD-11 UPS'),
    (Profile: 4; Title: 'McDonnell Douglas MD-11 Varig'),
    (Profile: 4; Title: 'McDonnell Douglas MD-11 WESTERN GLOBAL'),
    (Profile: 5; Title: 'TFDi Design MD-11 GE CF6-80c'),
    (Profile: 5; Title: 'TFDi Design MD-11BCF GE CF6-80c'),
    (Profile: 5; Title: 'TFDi Design MD-11F GE CF6-80c')
   );
{ FLD- }

 Var
  AddonFields : Array [0..AddonFieldCount - 1] Of TAddonLVarField;

 Function MatchesAddon(Profile : Integer; Const Title : String) : Boolean;

Implementation

 Uses
  System.SysUtils, PMDGDC6LVarsU, CSS737LVarsU, MaddogXLVarsU, SkySimDC9LVarsU, SkySimMD11LVarsU, TFDiMD11LVarsU, AsoboBell407LVarsU, AsoboEC135LVarsU;

 Function MatchesAddon(Profile : Integer; Const Title : String) : Boolean;
  Var
   t : String;
   i : Integer;
  Begin
   Result := False;
   For i  := Low(AddonTitles) To High(AddonTitles) Do
    If (AddonTitles[i].Profile = Profile) And SameText(Trim(Title), AddonTitles[i].Title) Then
     Exit(True);
   t := UpperCase(Title).Replace('-', '').Replace('_', '').Replace(' ', '');
   Case Profile Of
    0 : Result := (Pos('PMDG', t) > 0) And (Pos('DC6', t) > 0);
    1 : Result := (Pos('CSS', t) > 0) And ((Pos('737', t) > 0) Or (Pos('B733', t) > 0) Or (Pos('B734', t) > 0) Or (Pos('B735', t) > 0));
    2 : Result := Pos('MADDOG', t) > 0;
    3 : Result := ((Pos('SKYSIM', t) > 0) Or (Pos('SKYDC9', t) > 0)) And (Pos('DC9', t) > 0);
    4 : Result := ((Pos('SKYSIM', t) > 0) Or (Pos('SKYMD11', t) > 0)) And (Pos('MD11', t) > 0);
    5 : Result := (Pos('TFDI', t) > 0) And (Pos('MD11', t) > 0);
    6 : Result := (Pos('BELL407', t) > 0) And (Pos('HPG', t) = 0);
    7 : Result := (Pos('EC135', t) > 0) And (Pos('HPG', t) = 0);
   End;
  End;

 Procedure InitializeFields;
  Var
   i : Integer;
  Begin
   For i                  := 0 To 903 Do
    AddonFields[0 + i]    := PMDGDC6Fields[i];
   For i                  := 0 To 1220 Do
    AddonFields[904 + i]  := CSS737Fields[i];
   For i                  := 0 To 364 Do
    AddonFields[2125 + i] := MaddogXFields[i];
   For i                  := 0 To 487 Do
    AddonFields[2490 + i] := SkySimDC9Fields[i];
   For i                  := 0 To 319 Do
    AddonFields[2978 + i] := SkySimMD11Fields[i];
   For i                  := 0 To 1445 Do
    AddonFields[3298 + i] := TFDiMD11Fields[i];
   For i                  := 0 To 71 Do
    AddonFields[4744 + i] := AsoboBell407Fields[i];
   For i                  := 0 To 233 Do
    AddonFields[4816 + i] := AsoboEC135Fields[i];
  End;

Initialization

 InitializeFields;

End.
