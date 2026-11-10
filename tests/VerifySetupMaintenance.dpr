Program VerifySetupMaintenance;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}
{$IFDEF SETUP_RESOURCE_TEST}
{$R '..\..\MSFS2024-FDR-Setup\src\SetupI18n.res'}
{$ENDIF}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU, FDRSetupProductU, Winapi.Windows, Winapi.ActiveX, System.SysUtils, System.Classes, System.IOUtils,
 System.IniFiles, Vcl.Forms, Vcl.Controls, LocalizationU, UIFontsU, SetupLocalizationU,
 SetupMaintenanceU, SetupPlatformU, UpdateProtocolU, ReleasePackageU, VersionU,
 frmSetupU, frmSetupLanguageU, frmSetupCleanupU;

Procedure Check(b : Boolean; Const MessageText : String);
 Begin
  If Not b Then
   Raise Exception.Create(MessageText);
 End;

Procedure TestLocales;
 Var
  Locale : String;
  First  : String;
  f      : TfrmSetup;
  l      : TfrmSetupLanguage;
  c      : TfrmSetupCleanup;
  Config : TMemIniFile;
 Begin
  {$IFDEF SETUP_RESOURCE_TEST}
  Check(FindResource(HInstance, 'SETUP_I18N', RT_RCDATA) <> 0, 'Embedded catalog');
  Check(Not DirectoryExists(BundledFontsDirectory), 'Bootstrap test has no external font directory');
  Check(BundledFontCount = 5, 'All five embedded font resources registered');
  {$ENDIF}
  InitializeSetupLanguage;
  Check(LanguagePreference = 'auto', 'First launch autodetects Windows');
  l := TfrmSetupLanguage.Create(Nil);
  Try
   Check(l.cbLanguage.Items.Count = 33, 'Auto plus identical 32 locales');
  Finally
   l.Free;
  End;
  For Locale In UILanguageLocales Do
   Begin
    SetLanguage(Locale);
    First := ST('Install');
    Check(First <> '', 'Translated installer message');
    If Copy(Locale, 1, 2) <> 'en' Then
     Check(First <> 'Install', 'No English fallback for ' + Locale);
    f := TfrmSetup.Create(Nil);
    c := TfrmSetupCleanup.Create(Nil);
    Try
     Check(f.cbDesktop.Caption = ST('Desktop shortcut'), 'Main wizard translated ' + Locale);
     Check(c.cbKeepFlights.Caption = ST('Keep recorded flights'), 'Data retention translated ' + Locale);
     If (Copy(Locale, 1, 2) = 'ar') Or (Copy(Locale, 1, 2) = 'he') Then
      Check(f.BiDiMode = bdRightToLeft, 'RTL installer')
     Else
      Check(f.BiDiMode = bdLeftToRight, 'LTR installer');
    Finally
     c.Free;
     f.Free;
    End;
   End;
  SetLanguage('he-IL');
  l := TfrmSetupLanguage.Create(Nil);
  Try
   l.cbLanguage.ItemIndex := 10;
   l.LanguageChange(Nil);
   Check(l.BiDiMode = bdLeftToRight, 'Language picker restores LTR');
  Finally
   l.Free;
  End;
  SaveSetupLanguage('de-AT');
  InitializeSetupLanguage;
  Check(Language = 'de-AT', 'Installer preference persisted');
  Config := TMemIniFile.Create(TPath.Combine(UserDataDirectory, 'settings.ini'));
  Try
   Check(Config.ReadString('ui', 'language', '') = 'de-AT', 'Shared application preference');
  Finally
   Config.Free;
  End;
  SetLanguage('pl-PL');
  System.Writeln('PASS: installer and retention DFM in all 32 locales, identical language list, autodetect, preference save, RTL and LTR return.');
 End;

Procedure Fixtures;
 Begin
  ForceDirectories(TPath.Combine(UserDataDirectory, 'Recordings'));
  TFile.WriteAllText(TPath.Combine(UserDataDirectory, 'Recordings\one.mfzr'), 'flight');
  TFile.WriteAllText(TPath.Combine(UserDataDirectory, 'loose.mfzr'), 'loose flight');
  TFile.WriteAllText(TPath.Combine(UserDataDirectory, 'loose.mfzr-wal'), 'wal');
  TFile.WriteAllText(TPath.Combine(UserDataDirectory, 'flight_data.mfzi'), 'index');
  TFile.WriteAllText(TPath.Combine(UserDataDirectory, 'settings.ini'), 'settings');
  ForceDirectories(TPath.Combine(UserDataDirectory, 'Logs'));
  TFile.WriteAllText(TPath.Combine(UserDataDirectory, 'Logs\one.log'), 'log');
 End;

Procedure TestRetention;
 Var
  a : Integer;
  b : Integer;
 Begin
  For a  := 0 To 1 Do
   For b := 0 To 1 Do
    Begin
     Fixtures;
     CleanupUserData(a = 1, b = 1);
     Check(FileExists(TPath.Combine(UserDataDirectory, 'settings.ini')) = (a = 1), 'Independent settings retention');
     Check(FileExists(TPath.Combine(UserDataDirectory, 'Logs\one.log')) = (a = 1), 'Logs follow settings');
     Check(FileExists(TPath.Combine(UserDataDirectory, 'Recordings\one.mfzr')) = (b = 1), 'Independent recordings retention');
     Check(FileExists(TPath.Combine(UserDataDirectory, 'flight_data.mfzi')) = (b = 1), 'Recording index follows flights');
     Check(FileExists(TPath.Combine(UserDataDirectory, 'loose.mfzr-wal')) = (b = 1), 'Loose recording WAL follows flights');
    End;
  CleanupUserData(False, False);
  System.Writeln('PASS: all four independent settings/flight retention combinations on isolated user data.');
 End;

Procedure TestRepair;
 Var
  Stage   : String;
  Target  : String;
  Exe     : String;
  Healthy : String;
  Files   : TStringList;
  Stamp   : TDateTime;
  f       : TfrmSetup;
 Begin
  Stage  := TPath.Combine(TestDataDirectory, 'payload');
  Target := InstallDirectory;
  ForceDirectories(Stage);
  Files := TStringList.Create;
  Try
   Exe := TPath.Combine(Stage, MainExeName);
   TFile.Copy(TestRepositoryPath('bin\' + MainExeName), Exe);
   TFile.WriteAllText(TPath.Combine(Stage, 'healthy.dll'), 'healthy');
   TFile.WriteAllText(TPath.Combine(Stage, 'broken.dll'), 'expected');
   TFile.WriteAllText(TPath.Combine(Stage, SetupExeName), 'setup fixture');
   Files.Add(MainExeName);
   Files.Add(SetupExeName);
   Files.Add('healthy.dll');
   Files.Add('broken.dll');
   InstallPayload(Stage, Target, Files, False, False, False, []);
   f := TfrmSetup.Create(Nil);
   Try
    Check(f.Pages.ActivePage = f.MaintenancePage, 'Existing installation opens maintenance');
    f.rbRepair.Checked := True;
    f.NextClick(Nil);
    Check(f.Pages.ActivePage = f.OptionsPage, 'Repair selection reaches task options');
    f.BackClick(Nil);
    Check(f.Pages.ActivePage = f.MaintenancePage, 'Back returns to maintenance');
   Finally
    f.Free;
   End;
   Healthy := TPath.Combine(Target, 'healthy.dll');
   TFile.SetLastWriteTime(Healthy, EncodeDate(2020, 1, 1));
   Stamp := TFile.GetLastWriteTime(Healthy);
   TFile.WriteAllText(TPath.Combine(Target, 'broken.dll'), 'corrupted');
   TFile.Delete(TPath.Combine(Target, MainExeName));
   Check(InstalledVersion(Target) = ReadVersionInfo(Exe).FileVersion, 'Missing executable detected from installation metadata');
   InstallPayload(Stage, Target, Files, False, False, False, [], True);
   Check(TFile.GetLastWriteTime(Healthy) = Stamp, 'Repair never rewrites healthy payload');
   Check(TFile.ReadAllText(TPath.Combine(Target, 'broken.dll')) = 'expected', 'Repair replaces corrupt payload');
   Check(FileExists(TPath.Combine(Target, MainExeName)), 'Repair restores missing executable');
  Finally
   Files.Free;
  End;
  System.Writeln('PASS: maintenance selection, installed-version metadata fallback and repair of missing/corrupt files preserving healthy timestamps.');
 End;

Procedure TestExactVersion;
 Var
  s    : String;
  Info : TReleaseInfo;
 Begin
  s := '[{"assets":[{"name":"MSFS2024-FDR-Win64-0.1.1.18.zip","size":100,"browser_download_url":"https://github.com/dj-mafiozo/MSFS2024-FDR/releases/download/v0.1.1.18/MSFS2024-FDR-Win64-0.1.1.18.zip"}]},' +
  '{"assets":[{"name":"MSFS2024-FDR-Win64-99.0.0.1.zip","size":100,"browser_download_url":"https://github.com/dj-mafiozo/MSFS2024-FDR/releases/download/v99.0.0.1/MSFS2024-FDR-Win64-99.0.0.1.zip"}]}]';
  Check(TryReleaseVersion(s, '0.1.1.18', Info), 'Installed release found');
  Check(Info.Version = '0.1.1.18', 'Reinstall never selects newer version');
  Check(Not TryReleaseVersion(s, '0.1.1.17', Info), 'Unavailable installed release does not fall back to latest');
  System.Writeln('PASS: reinstall/repair selects the exact installed release and refuses a missing version instead of upgrading.');
 End;

Procedure TestPackagePolicy;
 Var
  Name : String;
 Begin
  For Name In TArray<String>.Create('MSFS2024-FDR.exe', 'MSFS24-FDR-Setup.exe', 'Assets\A320-MCDU.png', 'fonts\manifest.json', 'help\a.chm', 'settings.example.ini', 'LICENSE') Do
   Check(IncludeRuntimeFile(Name), 'Runtime included: ' + Name);
  For Name In TArray<String>.Create('Optional-Community/msfs24-fdr-weather/manifest.json', 'Optional-Community/msfs24-fdr-weather/layout.json', 'Optional-Community/msfs24-fdr-weather/InGamePanels/InGamePanel_FDRWeather.spb', 'Optional-Community/msfs24-fdr-weather/html_ui/icons/toolbar/ICON_TOOLBAR_FDR_WEATHER.svg') Do
   Check(Not IncludeRuntimeFile(Name), 'Raw bridge excluded in favour of signed nested ZIP: ' + Name);
  Check(Not IncludeRuntimeFile('Optional-Community/mateusz-efb-ifly/panel.js'), 'Old iFly bridge excluded');
  For Name In TArray<String>.Create('private.pem', 'settings.ini', 'simbrief-latest.json', 'flight_data.mfzi', 'Recordings\one.mfzr', 'Logs\debug.txt', 'PackageRelease.exe', 'source.pas') Do
   Check(Not IncludeRuntimeFile(Name), 'Private/development file excluded: ' + Name);
  System.Writeln('PASS: standalone bin packager includes required runtime and excludes user data, secrets and source.');
 End;

Type

 [TestFixture]
 TVerifySetupMaintenanceTests = Class
  Public
   [Test]
   Procedure Regression;
 End;

Procedure TVerifySetupMaintenanceTests.Regression;
 Begin
  Try
   Application.Initialize;
   CoInitialize(Nil);
   Try
    TestLocales;
    TestRetention;
    TestRepair;
    TestExactVersion;
    TestPackagePolicy;
   Finally
    CoUninitialize;
   End;
  Except
   On E : Exception Do
    Begin
     System.Writeln(E.ClassName + ': ' + E.Message);
     Raise Exception.Create('Regression failed; see diagnostic above');
    End;
  End;

 End;

Begin
 RunNativeTests(TVerifySetupMaintenanceTests);

End.
