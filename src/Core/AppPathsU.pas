{$StackFrames On}
Unit AppPathsU;

Interface

 Uses
  Winapi.Windows, System.SysUtils;

 Function AcquireApplicationMutex : THandle;
 Function PreviewRecordingArgument : String;
 Function ApplicationDirectory : String;
 Function AppDataDirectory : String;
 Procedure InitializeAppStorage;
 Procedure MigrateAppStorage(Const Source, Destination : String);

Implementation

 Uses
  Winapi.ShlObj, System.IOUtils, System.Generics.Collections;

 Function AcquireApplicationMutex : THandle;
  Var
   Error : Cardinal;
  Begin
   Result := CreateMutex(Nil, False, 'MSFS24-FDR-Run_Once');
   Error  := GetLastError;
   If Result = 0 Then
    RaiseLastOSError(Error);
   If Error = ERROR_ALREADY_EXISTS Then
    Begin
     CloseHandle(Result);
     Result := 0;
    End;
  End;

 Function PreviewRecordingArgument : String;
  Begin
   Result := '';
   If (ParamCount = 1) And SameText(ExtractFileExt(ParamStr(1)), '.mfzr') And FileExists(ParamStr(1)) Then
    Result := ExpandFileName(ParamStr(1));
  End;

 Function ApplicationDirectory : String;
  Begin
   Result := ExcludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
  End;

 Procedure MigrateAppStorage(Const Source, Destination : String);
  Var
   Names   : TList<String>;
   Handles : TList<THandle>;
   N       : String;
   Pending : String;
   Target  : String;
   h       : THandle;
   i       : Integer;
  Begin
   ForceDirectories(Destination);
   If SameText(TPath.GetFullPath(Source), TPath.GetFullPath(Destination)) Then
    Exit;
   Names   := TList<String>.Create;
   Handles := TList<THandle>.Create;
   Try
    // A pending directory is a complete, immutable snapshot. Main DB is published
    // last; after a process interruption finish publishing before any DB is opened.
    Pending := TPath.Combine(Destination, 'migration.pending');
    If TDirectory.Exists(Pending) Then
     Begin
      If Not TFile.Exists(TPath.Combine(Pending, 'ready')) Then
       TDirectory.Delete(Pending, True)
      Else
       Begin
        For N In TArray<String>.Create('flight_data.db-wal', 'flight_data.db-shm', 'flight_data.db', 'settings.ini', 'msfs_fdr_debug.dmp', 'msfs_fdr_debug.log.old', 'msfs_fdr_debug.log') Do
         If TFile.Exists(TPath.Combine(Pending, N)) Then
          Begin
           Target := TPath.Combine(Destination, N);
           If TFile.Exists(Target) Then
            Raise Exception.Create('Storage migration conflict: ' + Target);
           TFile.Move(TPath.Combine(Pending, N), Target);
          End;
        TDirectory.Delete(Pending, True);
        // Recovery does not delete the old source: it may have changed since copying.
        Exit;
       End;
     End;
    If TFile.Exists(TPath.Combine(Source, 'flight_data.db')) And Not TFile.Exists(TPath.Combine(Destination, 'flight_data.db')) And Not TFile.Exists(TPath.Combine(Destination, 'flight_data.db-wal')) And Not TFile.Exists(TPath.Combine(Destination, 'flight_data.db-shm')) Then
     For N In TArray<String>.Create('flight_data.db', 'flight_data.db-wal', 'flight_data.db-shm') Do
      If TFile.Exists(TPath.Combine(Source, N)) Then
       Names.Add(N);
    For N In TArray<String>.Create('settings.ini', 'msfs_fdr_debug.dmp', 'msfs_fdr_debug.log.old', 'msfs_fdr_debug.log') Do
     If TFile.Exists(TPath.Combine(Source, N)) And Not TFile.Exists(TPath.Combine(Destination, N)) Then
      Names.Add(N);
    If Names.Count = 0 Then
     Exit;
    // Deny writers/deletion for the entire SQLite family before copying any file.
    // An already-running recorder causes a visible startup error, never a torn copy.
    For N In Names Do
     Begin
      h := CreateFile(PChar(TPath.Combine(Source, N)), GENERIC_READ, FILE_SHARE_READ, Nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
      If h = INVALID_HANDLE_VALUE Then
       RaiseLastOSError;
      Handles.Add(h);
     End;
    ForceDirectories(Pending);
    Try
     For N In Names Do
      Begin
       Target := TPath.Combine(Pending, N);
       TFile.Copy(TPath.Combine(Source, N), Target, False);
       If Not SetFileAttributes(PChar(Target), GetFileAttributes(PChar(Target)) And Not FILE_ATTRIBUTE_READONLY) Then
        RaiseLastOSError;
      End;
     TFile.WriteAllText(TPath.Combine(Pending, 'ready'), '1', TEncoding.UTF8);
     // WAL/SHM must be in place before the main database becomes visible.
     For N In TArray<String>.Create('flight_data.db-wal', 'flight_data.db-shm', 'flight_data.db', 'settings.ini', 'msfs_fdr_debug.dmp', 'msfs_fdr_debug.log.old', 'msfs_fdr_debug.log') Do
      If Names.Contains(N) Then
       TFile.Move(TPath.Combine(Pending, N), TPath.Combine(Destination, N));
     TDirectory.Delete(Pending, True);
    Except
     // Keep a complete pending snapshot for recovery. Never delete source on failure.
     If Not TFile.Exists(TPath.Combine(Pending, 'ready')) And TDirectory.Exists(Pending) Then
      TDirectory.Delete(Pending, True);
     Raise;
    End;
    For i := 0 To Handles.Count - 1 Do
     CloseHandle(Handles[i]);
    Handles.Clear;
    For N In Names Do
     Begin
      // Program Files may allow reading but deny deletion. The verified copy is
      // already installed; preserve a read-only legacy file rather than fail startup.
      DeleteFile(PChar(TPath.Combine(Source, N)));
     End;
   Finally
    For h In Handles Do
     CloseHandle(h);
    Handles.Free;
    Names.Free;
   End;
  End;

 Function AppDataDirectory : String;
  Var
   p : Array [0..MAX_PATH] Of Char;
  Begin
   {$IFDEF PORT_TEST}
   // Tests supply a per-run storage root; never migrate real user data.
   Result := GetEnvironmentVariable('MSFS_FDR_TEST_ROOT');
   If Result = '' Then
    Result := ApplicationDirectory;
   {$ELSE}
   If SHGetFolderPath(0, CSIDL_LOCAL_APPDATA, 0, SHGFP_TYPE_CURRENT, @p[0]) <> S_OK Then
    Raise Exception.Create('Cannot locate LocalAppData');
   Result := TPath.Combine(String(p), 'MSFS24-FDR');
   {$ENDIF}
   If Not ForceDirectories(Result) Then
    Raise Exception.Create('Cannot create ' + Result);
  End;

 Procedure InitializeAppStorage;
  Var
   h          : THandle;
   WaitResult : DWORD;
  Begin
   h := CreateMutex(Nil, False, 'Local\MSFS24-FDR-StorageMigration');
   If h = 0 Then
    RaiseLastOSError;
   Try
    WaitResult := WaitForSingleObject(h, 30000);
    If (WaitResult <> WAIT_OBJECT_0) And (WaitResult <> WAIT_ABANDONED) Then
     Raise Exception.Create('Another instance is migrating recorder data');
    Try
     MigrateAppStorage(ApplicationDirectory, AppDataDirectory);
    Finally
     ReleaseMutex(h);
    End;
   Finally
    CloseHandle(h);
   End;
  End;

End.
