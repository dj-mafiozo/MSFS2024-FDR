Unit SimulatorPackagesU;

Interface

 Uses
  System.SysUtils;

 Function SimulatorCommunityDirectories(Const LocalData, RoamingData : String) : TArray<String>;

Implementation

 Uses
  System.Classes, System.IOUtils, System.Generics.Collections, System.StrUtils;

 Function SimulatorCommunityDirectories(Const LocalData, RoamingData : String) : TArray<String>;
  Var
   Found : TStringList;
   Cfgs  : TList<String>;
   p     : String;
   Line  : String;
   Value : String;
   Root  : String;
   Lines : TStringList;
   i     : Integer;

   Procedure Candidate(Const Folder : String);
    Begin
     If DirectoryExists(Folder) Then
      Cfgs.Add(TPath.Combine(Folder, 'UserCfg.opt'));
    End;

  Begin
   Found := TStringList.Create;
   Cfgs  := TList<String>.Create;
   Lines := TStringList.Create;
   Try
    Found.CaseSensitive := False;
    Found.Sorted        := True;
    Found.Duplicates    := dupIgnore;
    Candidate(TPath.Combine(LocalData, 'Packages\Microsoft.Limitless_8wekyb3d8bbwe\LocalCache'));
    Candidate(TPath.Combine(RoamingData, 'Microsoft Flight Simulator 2024'));
    Root := TPath.Combine(LocalData, 'Packages');
    If DirectoryExists(Root) Then
     For p In TDirectory.GetDirectories(Root, 'Microsoft.Limitless_*', TSearchOption.soTopDirectoryOnly) Do
      Candidate(TPath.Combine(p, 'LocalCache'));
    For p In Cfgs Do
     If FileExists(p) Then
      Begin
       Lines.LoadFromFile(p, TEncoding.UTF8);
       For Line In Lines Do
        Begin
         Value := Trim(Line);
         If Not StartsText('InstalledPackagesPath ', Value) Then
          Continue;
         Value := Trim(Copy(Value, Length('InstalledPackagesPath') + 1, MaxInt));
         If (Length(Value) >= 2) And (Value[1] = '"') And (Value[Length(Value)] = '"') Then
          Value := Copy(Value, 2, Length(Value) - 2);
         If Not TPath.IsPathRooted(Value) Then
          Continue;
         Value := TPath.Combine(Value, 'Community');
         If DirectoryExists(Value) Then
          Found.Add(TPath.GetFullPath(Value));
        End;
      End;
     // Standard Store location, including installations with a missing UserCfg.opt.
    Root := TPath.Combine(LocalData, 'Packages\Microsoft.Limitless_8wekyb3d8bbwe\LocalCache\Packages\Community');
    If DirectoryExists(Root) Then
     Found.Add(TPath.GetFullPath(Root));
    SetLength(Result, Found.Count);
    For i      := 0 To Found.Count - 1 Do
     Result[i] := Found[i];
   Finally
    Lines.Free;
    Cfgs.Free;
    Found.Free;
   End;
  End;

End.
