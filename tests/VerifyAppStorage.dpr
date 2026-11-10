Program VerifyAppStorage;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU,
 Winapi.Windows, System.SysUtils, System.Classes, System.IOUtils,
 AppPathsU, FlightDatabaseU;

Procedure Check(b : Boolean; Const s : String);
 Begin
  If Not b Then
   Raise Exception.Create(s);
 End;

Var
 Root   : String;
 Seed   : String;
 Old    : String;
 Dest   : String;
 n      : String;
 DLL    : String;
 DB     : TFlightDatabase;
 h      : THandle;
 Failed : Boolean;

Type

 [TestFixture]
 TVerifyAppStorageTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyAppStorageTests.Regression;
 Begin
  Root := TPath.Combine(TPath.GetTempPath, 'FDR-storage-' + IntToStr(GetCurrentProcessId));
  Seed := TPath.Combine(Root, 'seed');
  Old  := TPath.Combine(Root, 'legacy');
  Dest := TPath.Combine(Root, 'data');
  ForceDirectories(Seed);
  ForceDirectories(Old);
  DLL := TPath.Combine(ExtractFilePath(ParamStr(0)), 'sqlite3.dll');
  Try
   DB := TFlightDatabase.Create(TPath.Combine(Seed, 'flight_data.db'), DLL);
   Try
    DB.Connection.ExecSQL('PRAGMA journal_mode=WAL');
    DB.Connection.ExecSQL('PRAGMA wal_autocheckpoint=0');
    DB.Connection.ExecSQL('create table migration_probe(value integer)');
    DB.Connection.ExecSQL('insert into migration_probe values(12345)');
    Check(TFile.Exists(TPath.Combine(Seed, 'flight_data.db-wal')), 'Real WAL fixture missing');
    // Frozen copy after a committed write: simulates files left by abrupt exit.
    For n In TArray<String>.Create('flight_data.db', 'flight_data.db-wal', 'flight_data.db-shm') Do
     If TFile.Exists(TPath.Combine(Seed, n)) Then
      TFile.Copy(TPath.Combine(Seed, n), TPath.Combine(Old, n));
   Finally
    DB.Free;
   End;
   TFile.WriteAllText(TPath.Combine(Old, 'settings.ini'), 'sample_interval_ms=250');
   TFile.WriteAllText(TPath.Combine(Old, 'msfs_fdr_debug.log'), 'old log');
   h := CreateFile(PChar(TPath.Combine(Old, 'flight_data.db')), GENERIC_READ Or GENERIC_WRITE, FILE_SHARE_READ Or FILE_SHARE_WRITE, Nil, OPEN_EXISTING, 0, 0);
   Check(h <> INVALID_HANDLE_VALUE, 'Lock fixture');
   Try
    Failed := False;
    Try
     MigrateAppStorage(Old, Dest);
    Except
     On E : EOSError Do
      Failed := True;
    End;
    Check(Failed, 'An active writer must prevent migration');
    Check(Not TFile.Exists(TPath.Combine(Dest, 'flight_data.db')), 'No partial target with active writer');
   Finally
    CloseHandle(h);
   End;
   MigrateAppStorage(Old, Dest);
   Check(TFile.ReadAllText(TPath.Combine(Dest, 'settings.ini')) = 'sample_interval_ms=250', 'Settings copied');
   Check(Not TFile.Exists(TPath.Combine(Old, 'flight_data.db')), 'Source moved');
   DB := TFlightDatabase.Create(TPath.Combine(Dest, 'flight_data.db'), DLL);
   Try
    Check(DB.Connection.ExecSQLScalar('select value from migration_probe') = 12345, 'Committed WAL record survived');
   Finally
    DB.Free;
   End;
   MigrateAppStorage(Old, Dest);
   TFile.WriteAllText(TPath.Combine(Old, 'settings.ini'), 'conflict');
   TFile.WriteAllText(TPath.Combine(Old, 'flight_data.db'), 'do not import');
   MigrateAppStorage(Old, Dest);
   Check(TFile.ReadAllText(TPath.Combine(Dest, 'settings.ini')) = 'sample_interval_ms=250', 'Existing settings not overwritten');
   Check(TFile.Exists(TPath.Combine(Old, 'flight_data.db')), 'Conflicting source retained');
   ForceDirectories(TPath.Combine(Dest, 'migration.pending'));
   TFile.WriteAllText(TPath.Combine(Dest, 'migration.pending\ready'), '1');
   TFile.WriteAllText(TPath.Combine(Dest, 'migration.pending\msfs_fdr_debug.log.old'), 'recover');
   MigrateAppStorage(Old, Dest);
   Check(TFile.ReadAllText(TPath.Combine(Dest, 'msfs_fdr_debug.log.old')) = 'recover', 'Interrupted migration recovery');
   ForceDirectories(TPath.Combine(Root, 'readonly'));
   n := TPath.Combine(Root, 'readonly\settings.ini');
   TFile.WriteAllText(n, 'read only install');
   SetFileAttributes(PChar(n), FILE_ATTRIBUTE_READONLY);
   Try
    MigrateAppStorage(TPath.Combine(Root, 'readonly'), TPath.Combine(Root, 'readonly-data'));
    Check(TFile.Exists(n), 'Read-only original retained');
    Check(TFile.ReadAllText(TPath.Combine(Root, 'readonly-data\settings.ini')) = 'read only install', 'Read-only installation copied');
    TFile.WriteAllText(TPath.Combine(Root, 'readonly-data\settings.ini'), 'writable user copy');
    Check(TFile.ReadAllText(TPath.Combine(Root, 'readonly-data\settings.ini')) = 'writable user copy', 'Migrated settings writable');
   Finally
    SetFileAttributes(PChar(n), FILE_ATTRIBUTE_NORMAL);
   End;
   System.Writeln('PASS: real SQLite WAL, settings/log move, writer lock, conflict preservation, idempotence and interrupted publication recovery.');
  Finally
   If TDirectory.Exists(Root) Then
    TDirectory.Delete(Root, True);
  End;

 End;

Begin
 RunNativeTests(TVerifyAppStorageTests);
End.
