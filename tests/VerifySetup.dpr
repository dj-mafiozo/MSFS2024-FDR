Program VerifySetup;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU In 'TestPathsU.pas', DUnitX.TestFramework, NativeTestRunnerU In 'NativeTestRunnerU.pas', AppPathsU In '..\src\Core\AppPathsU.pas', FDRSetupProductU In '..\..\MSFS2024-FDR-Setup\src\FDRSetupProductU.pas', Winapi.Windows, Winapi.ActiveX, Winapi.ShlObj, System.SysUtils, System.Classes, System.IOUtils,
 System.Zip, System.JSON, Xml.XMLDoc, Xml.XMLIntf, Xml.xmldom, Xml.omnixmldom, Vcl.Forms, Vcl.ComCtrls, System.IniFiles,
 SecureZipU In '..\..\setup-core\src\SecureZipU.pas', UpdateProtocolU In '..\..\setup-common\src\UpdateProtocolU.pas', SetupPlatformU In '..\..\MSFS2024-FDR-Setup\src\SetupPlatformU.pas', SetupHandoffU In '..\..\setup-common\src\SetupHandoffU.pas', frmChangeLogU In '..\src\Forms\frmChangeLogU.pas', LocalizationU In '..\src\i18n\LocalizationU.pas', frmSettingsU In '..\src\Forms\frmSettingsU.pas';

Procedure Check(b : Boolean; Const s : String);
 Begin
  If Not b Then
   Raise Exception.Create(s);
 End;

Procedure TestRunOnce;
 Var
  h  : THandle;
  H2 : THandle;
 Begin
  Check(Not RecorderRunning(''), 'Recorder initially stopped');
  h := AcquireApplicationMutex;
  Check(h <> 0, 'Application mutex handle');
  Try
   Check(RecorderRunning(''), 'Installer detects named recorder mutex');
   H2 := AcquireRecorderMutex;
   Check(H2 = 0, 'Second instance rejected');
   Check(RecorderRunning(''), 'Duplicate check preserves first handle');
  Finally
   CloseHandle(h);
  End;
  Check(Not RecorderRunning(''), 'Closed/crashed process does not leave stale mutex');
  h := AcquireApplicationMutex;
  Check(h <> 0, 'Application restart can acquire mutex');
  CloseHandle(h);
  System.Writeln('PASS: real named run-once mutex, duplicate rejection and release.');
 End;

Procedure TestVersions;
 Var
  r        : TReleaseInfo;
  Rejected : Boolean;
  s        : String;
 Begin
  Check(CompareVersion('0.1.1', '0.1.0.65535') > 0, 'Release beats previous build');
  Check(CompareVersion('v0.1.1', '0.1.1.0') = 0, 'Tag and EXE comparison');
  Check(CompareVersion('0.1.1.10', '0.1.1.9') > 0, 'Numeric build ordering');
  Rejected := False;
  Try
   CompareVersion('Preview', '0.1.0');
  Except
   Rejected := True;
  End;
  Check(Rejected, 'Invalid version rejected');
  s := '{"tag_name":"v0.1.1","assets":[{"name":"MSFS2024-FDR-Screenshots.zip"},{"name":"MSFS2024-FDR-Win64-0.1.1.10.zip","browser_download_url":"https://github.com/dj-mafiozo/MSFS2024-FDR/releases/download/v0.1.1/app.zip","size":100}]}';
  r := ParseRelease(s);
  Check(r.Version = '0.1.1.10', 'Exact asset version selected');
  Rejected := False;
  Try
   ParseRelease('{"draft":true,"assets":[]}');
  Except
   Rejected := True;
  End;
  Check(Rejected, 'Draft rejected');
  Rejected := False;
  Try
   ParseRelease(StringReplace(s, 'https://github.com/', 'http://untrusted/', []));
  Except
   Rejected := True;
  End;
  Check(Rejected, 'Unexpected download origin rejected');
  System.Writeln('PASS: numeric release/build comparison, asset selection, draft and untrusted URL rejection.');
 End;

Procedure TestZIP;
 Var
  z        : TZipFile;
  Plain    : String;
  Archive  : String;
  Dest     : String;
  Files    : TStringList;
  Rejected : Boolean;
  Data     : TBytes;
  f        : TFileStream;
  b        : Byte;
 Begin
  Plain   := TPath.Combine(TestDataDirectory, 'plain.zip');
  Archive := TPath.Combine(TestDataDirectory, 'encrypted.zip');
  Dest    := TPath.Combine(TestDataDirectory, 'extracted');
  z       := TZipFile.Create;
  Try
   z.Open(Plain, zmWrite);
   z.Add(TEncoding.UTF8.GetBytes('test payload'), 'MSFS2024-FDR/sub/file.txt');
   z.Add(TEncoding.UTF8.GetBytes('never extract'), 'congratulations.mfz');
  Finally
   z.Free;
  End;
  EncryptRelease(Plain, Archive, 'fixture-password');
  Files := TStringList.Create;
  Try
   ExtractRelease(Archive, Dest, 'fixture-password', Files, Nil);
   Check(TFile.ReadAllText(TPath.Combine(Dest, 'sub/file.txt')) = 'test payload', 'Encrypted deflate round trip');
   Check(Not FileExists(TPath.Combine(Dest, 'congratulations.mfz')), 'Decoy never extracted');
   Check(Files.Count = 1, 'Decoy absent from install manifest');
   Rejected := False;
   Try
    ExtractRelease(Archive, TPath.Combine(TestDataDirectory, 'wrong'), 'wrong', Files, Nil);
   Except
    Rejected := True;
   End;
   Check(Rejected, 'Wrong password rejected');
   Rejected := False;
   Try
    ExtractRelease(Plain, TPath.Combine(TestDataDirectory, 'unencrypted'), 'fixture-password', Files, Nil);
   Except
    Rejected := True;
   End;
   Check(Rejected, 'Unencrypted release rejected');
   Rejected := False;
   Try
    SafeZipName('../outside');
   Except
    Rejected := True;
   End;
   Check(Rejected, 'Traversal rejected');
   Rejected := False;
   Try
    SafeZipName('C:\outside');
   Except
    Rejected := True;
   End;
   Check(Rejected, 'Absolute path rejected');
   Rejected := False;
   Try
    SafeZipName('sub/file:stream');
   Except
    Rejected := True;
   End;
   Check(Rejected, 'ADS rejected');
   Rejected := False;
   Try
    SafeZipName('sub/CON.txt');
   Except
    Rejected := True;
   End;
   Check(Rejected, 'Device name rejected');
   TFile.Copy(Archive, TPath.Combine(TestDataDirectory, 'encrypted-good.zip'));
   // Corrupt encrypted data; the central directory remains readable.
   f := TFileStream.Create(Archive, fmOpenReadWrite);
   Try
    f.Position := 31 + Length('MSFS2024-FDR/sub/file.txt') + 12;
    f.ReadBuffer(b, 1);
    b := b Xor $80;
    f.Seek( -1, soCurrent);
    f.WriteBuffer(b, 1);
   Finally
    f.Free;
   End;
   Rejected := False;
   Try
    ExtractRelease(Archive, TPath.Combine(TestDataDirectory, 'corrupt'), 'fixture-password', Files, Nil);
   Except
    Rejected := True;
   End;
   Check(Rejected, 'Corrupt compressed payload rejected');
  Finally
   Files.Free;
  End;
  System.Writeln('PASS: encrypted ZIP round trip, password, decoy exclusion, corruption, path traversal, ADS and device names.');
 End;

Procedure TestXML;
 Var
  s        : String;
  t        : String;
  Rejected : Boolean;
  Doc      : IXMLDocument;
  Document : TXMLDocument;
 Begin
  s := '<SimBase.Document><Launch.Addon><Name>Other</Name><Path>other.exe</Path></Launch.Addon></SimBase.Document>';
  t := PatchExeXML(s, 'C:\Program Files\MSFS24-FDR\MSFS2024-FDR.exe', True);
  Check(Pos('other.exe', t) > 0, 'Other autostart preserved');
  Check(Pos('MSFS2024-FDR.exe', t) > 0, 'Recorder autostart added');
  t := PatchExeXML(t, 'C:\Program Files\MSFS24-FDR\MSFS2024-FDR.exe', True);
  Check(Pos('<Name>MSFS24-FDR</Name>', Copy(t, Pos('<Name>MSFS24-FDR</Name>', t) + Length('<Name>MSFS24-FDR</Name>'), MaxInt)) = 0, 'Repeated merge does not duplicate autostart');
  t := PatchExeXML(t, 'C:\Program Files\MSFS24-FDR\MSFS2024-FDR.exe', False);
  Check(Pos('MSFS2024-FDR.exe', t) = 0, 'Own autostart removed');
  Check(Pos('other.exe', t) > 0, 'Other entry retained on uninstall');
  Rejected := False;
  Try
   PatchExeXML('<!DOCTYPE x [<!ENTITY e SYSTEM "file:///C:/Windows/win.ini">]><SimBase.Document>&e;</SimBase.Document>', 'app.exe', True);
  Except
   Rejected := True;
  End;
  Check(Rejected, 'External entities prohibited');
  Rejected := False;
  Try
   PatchExeXML('broken', 'app.exe', True);
  Except
   Rejected := True;
  End;
  Check(Rejected, 'Bad XML rejected without saving');
  t                  := PatchExeXML('', 'C:\Pr?ba & test\Za???? <x>.exe', True);
  Document           := TXMLDocument.Create(Nil);
  Doc                := Document;
  Document.DOMVendor := GetDOMVendor(sOmniXmlVendor);
  Doc.LoadFromXML(t);
  Check(Doc.DocumentElement.ChildNodes.FindNode('Launch.Addon').ChildNodes.FindNode('Path').Text = 'C:\Pr?ba & test\Za???? <x>.exe', 'Unicode and escaped path round trip');
  Check(Pos('UTF-8', t) > 0, 'Explicit UTF-8 declaration');
  t := PatchExeXML('<SimBase.Document><!--keep--><Launch.Addon><Path>unnamed.exe</Path></Launch.Addon></SimBase.Document>', 'app.exe', True);
  Check((Pos('<!--keep-->', t) > 0) And (Pos('unnamed.exe', t) > 0), 'Comments and unnamed foreign entries preserved');
  System.Writeln('PASS: simulator XML merge/removal, preservation of other add-ons and rejection of invalid XML/DTD.');
 End;

Procedure TestFiles;
 Var
  Stage    : String;
  Target   : String;
  Xml      : String;
  UserData : String;
  Programs : String;
  Folder   : String;
  Files    : TStringList;
  Rejected : Boolean;
 Begin
  Stage  := TPath.Combine(TestDataDirectory, 'stage');
  Target := InstallDirectory;
  ForceDirectories(Stage);
  Files    := TStringList.Create;
  Xml      := TPath.Combine(TestDataDirectory, 'exe.xml');
  UserData := TPath.Combine(TestDataDirectory, 'private.mfzr');
  TFile.WriteAllText(UserData, 'keep');
  Try
   TFile.Copy(TestRepositoryPath('bin\' + MainExeName), TPath.Combine(Stage, MainExeName));
   Files.Add(MainExeName);
   TFile.WriteAllText(TPath.Combine(Stage, SetupExeName), 'setup fixture');
   Files.Add(SetupExeName);
   Programs := TPath.Combine(TestDataDirectory, 'WindowsFolder-' + IntToStr(CSIDL_COMMON_PROGRAMS));
   ForceDirectories(Programs);
   Folder := TPath.Combine(Programs, 'DJ M@fi0z0' + #$2122);
   TFile.WriteAllText(TPath.Combine(Programs, 'MSFS24-FDR.lnk'), 'legacy');
   InstallPayload(Stage, Target, Files, True, False, True, [Xml]);
   Check(Not FileExists(TPath.Combine(Programs, 'MSFS24-FDR.lnk')), 'Legacy top-level shortcut removed');
   Check(FileExists(TPath.Combine(Folder, 'MSFS24-FDR.lnk')), 'Publisher application shortcut');
   Check(TFile.ReadAllText(TPath.Combine(Folder, 'Odinstaluj MSFS24-FDR.lnk')).Contains(SetupExeName + sLineBreak + '/uninstall'), 'Uninstall shortcut target and arguments');
   Check(FileExists(TPath.Combine(Target, MainExeName)), 'Installed payload');
   Check(Pos('MSFS24-FDR', TFile.ReadAllText(Xml)) > 0, 'Simulator option enabled');
   Check(FileExists(TPath.Combine(TestDataDirectory, 'registry.txt')), 'Registry operation isolated in test double');
   Files.Delete(Files.IndexOf(SetupExeName));
   InstallPayload(Stage, Target, Files, False, False, True, [Xml]);
   Check(Pos(SetupExeName, TFile.ReadAllText(TPath.Combine(Target, 'installation.json'))) > 0, 'Unchanged setup retained in manifest');
   Check(Not DirectoryExists(Folder), 'Unchecked task removes both shortcuts and empty folder');
   InstallPayload(Stage, Target, Files, True, False, True, [Xml]);
   TFile.WriteAllText(TPath.Combine(Folder, 'other-product.lnk'), 'keep');
   TFile.WriteAllText(TPath.Combine(Target, SetupUpdateName), 'new setup');
   ReplacePendingSetup(Target, $FFFFFFFE);
   Check(TFile.ReadAllText(TPath.Combine(Target, SetupExeName)) = 'new setup', 'Pending setup replaces previous executable');
   Check(Not FileExists(TPath.Combine(Target, SetupUpdateName)), 'Pending setup removed after replacement');
   Check(Pos('/ShowChangeLog', TFile.ReadAllText(TPath.Combine(TestDataDirectory, 'launch.txt'))) > 0, 'Handoff relaunches with changelog');
   Files.Add('missing.dll');
   Rejected := False;
   Try
    InstallPayload(Stage, Target, Files, False, False, True, [Xml]);
   Except
    Rejected := True;
   End;
   Check(Rejected, 'Failed copy rejected');
   Check(FileExists(TPath.Combine(Target, MainExeName)), 'Rollback restores old executable');
   RemoveInstallation(Target);
   Check(Not FileExists(TPath.Combine(Target, MainExeName)), 'Uninstall removed app');
   Check(Not FileExists(TPath.Combine(Target, SetupExeName)), 'Uninstall removed unchanged installer');
   Check(TFile.ReadAllText(UserData) = 'keep', 'Uninstall preserves recordings');
   Check(Not FileExists(TPath.Combine(Folder, 'MSFS24-FDR.lnk')) And Not FileExists(TPath.Combine(Folder, 'Odinstaluj MSFS24-FDR.lnk')), 'Uninstall removes both own shortcuts');
   Check(TFile.ReadAllText(TPath.Combine(Folder, 'other-product.lnk')) = 'keep', 'Shared publisher folder and other products retained');
   Rejected := False;
   Try
    ValidateInstallDirectory(TPath.GetTempPath);
   Except
    Rejected := True;
   End;
   Check(Rejected, 'Non-Program-Files target rejected');
  Finally
   Files.Free;
  End;
  System.Writeln('PASS: isolated install/update/uninstall, options, unchanged-setup manifest, file rollback and preserved user data.');
 End;

Procedure TestForms;
 Var
  f : TfrmChangeLog;
  s : TfrmSettings;
  c : TMemIniFile;
 Begin
  f := TfrmChangeLog.Create(Nil);
  Try
   SetLanguage('pl-PL');
   f.FormShow(Nil);
   Check(f.Caption = 'Historia zmian', 'Polish changelog');
   Check(f.Content.ReadOnly, 'Changelog read only');
   SetLanguage('fr-FR');
   f.FormShow(Nil);
   Check(f.Caption = 'Changelog', 'English for non-Polish language');
   Check(Pos('Changelog', f.Content.Text) > 0, 'English changelog content rendered');
  Finally
   f.Free;
  End;
  c := TMemIniFile.Create(TPath.Combine(TestDataDirectory, 'settings.ini'));
  s := TfrmSettings.Create(Nil);
  Try
   s.Load(c);
   Check(Not s.cbAutomaticUpdates.Checked, 'Automatic updates opt in');
   s.cbAutomaticUpdates.Checked := True;
   s.Save(c);
   Check(Not c.ReadBool('updates', 'automatic', True), 'Automatic updates cannot be enabled in this release');
   c.WriteBool('updates', 'automatic', True);
   s.Load(c);
   Check(Not s.cbAutomaticUpdates.Checked And Not s.cbAutomaticUpdates.Enabled, 'Legacy/manual INI opt-in cannot enable updates');
   Check(Not s.btnCheckUpdates.Enabled, 'Manual update disabled');
   s.CheckUpdatesClick(Nil);
   Check(Not s.UpdateRequested, 'Programmatic update request blocked');
  Finally
   s.Free;
   c.Free;
  End;
  System.Writeln('PASS: native changelog DFM, language selection and automatic-update settings.');
 End;

Type

 [TestFixture]
 TVerifySetupTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifySetupTests.Regression;
 Begin
  Try
   Application.Initialize;
   TestXML;
   CoInitialize(Nil);
   Try
    TestRunOnce;
    TestVersions;
    TestZIP;
    TestFiles;
    TestForms;
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
 RunNativeTests(TVerifySetupTests);
End.
