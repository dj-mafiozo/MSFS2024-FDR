{$StackFrames On}
Unit TestPathsU;

Interface

 Function TestDataDirectory : String;
 Function TestDatabasePath(Const Path : String) : String;
 Function TestRuntimeFile(Const Name : String) : String;
 Function TestRepositoryPath(Const Relative : String) : String;

Implementation

 Uses
  Winapi.Windows, System.SysUtils, System.Types, System.IOUtils;

 Var
  DataRoot       : String;
  RepositoryRoot : String;

 Function TestRepositoryPath(Const Relative : String) : String;
  Begin
   Result := TPath.Combine(RepositoryRoot, Relative);
  End;

 Function TestRuntimeFile(Const Name : String) : String;
  Begin
   Result := TPath.Combine(ExtractFilePath(ParamStr(0)), Name);
   If Not FileExists(Result) Then
    Result := TestRepositoryPath('bin\' + Name);
  End;

 Function TestDataDirectory : String;
  Begin
   Result := IncludeTrailingPathDelimiter(DataRoot);
  End;

 Function TestDatabasePath(Const Path : String) : String;
  Begin
   Result := Path;
   If (ExtractFilePath(Path) = '') Or SameText(ExtractFilePath(Path), ExtractFilePath(ParamStr(0))) Then
    Result := TPath.Combine(DataRoot, ExtractFileName(Path));
  End;

 Procedure InitializePaths;
  Var
   p    : String;
   f    : String;
   Dest : String;
  Begin
   p := ExcludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
   While (p <> '') And Not FileExists(TPath.Combine(p, 'src\MSFS2024-FDR.dpr')) Do
    Begin
     f := ExtractFileDir(p);
     If SameText(f, p) Then
      Break;
     p := f;
    End;
   If Not FileExists(TPath.Combine(p, 'src\MSFS2024-FDR.dpr')) Then
    Raise Exception.Create('Cannot locate test repository root');
   RepositoryRoot := p;
   DataRoot       := TestRepositoryPath('.build\test-data\' + ChangeFileExt(ExtractFileName(ParamStr(0)), '') + '\' + IntToStr(GetCurrentProcessID) + '-' + IntToStr(GetTickCount64));
   ForceDirectories(DataRoot);
   SetEnvironmentVariable('MSFS_FDR_TEST_ROOT', PChar(DataRoot));
   // Existing IPC mocks expect DLLs and their Win32 publisher beside fixture data.
   For f In TDirectory.GetFiles(ExtractFilePath(ParamStr(0)), '*.dll') Do
    Begin
     Dest := TPath.Combine(DataRoot, ExtractFileName(f));
     TFile.Copy(f, Dest, True);
    End;
   f := TestRuntimeFile('MockFlightPad32.exe');
   If FileExists(f) Then
    TFile.Copy(f, TPath.Combine(DataRoot, 'MockFlightPad32.exe'), True);
   If TDirectory.Exists(TestRepositoryPath('tests\fixtures')) Then
    TDirectory.Copy(TestRepositoryPath('tests\fixtures'), TPath.Combine(DataRoot, 'fixtures'));
  End;

Initialization
 InitializePaths;

End.
