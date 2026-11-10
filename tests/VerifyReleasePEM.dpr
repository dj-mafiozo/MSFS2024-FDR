Program VerifyReleasePEM;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, Winapi.Windows, System.SysUtils, System.Types, System.Classes, System.IOUtils,
 System.JSON, System.Hash, System.Zip, DUnitX.TestFramework, NativeTestRunnerU;

Type

 [TestFixture]
 TReleasePEMTests = Class
  Public
   [Test] Procedure EncryptedFixtureRoundTrip;
 End;

Function Q(Const s : String) : String;
 Begin
  Result := '"' + ExcludeTrailingPathDelimiter(s) + '"';
 End;

Procedure Save(Const Name, Text : String);
 Begin
  ForceDirectories(ExtractFileDir(Name));
  TFile.WriteAllText(Name, Text, TEncoding.UTF8);
 End;

Function Run(Const Command, Directory, Input : String) : Cardinal;
 Var
  SI        : TStartupInfo;
  PI        : TProcessInformation;
  SA        : TSecurityAttributes;
  ReadPipe  : THandle;
  WritePipe : THandle;
  LogHandle : THandle;
  Cmd       : String;
  Bytes     : TBytes;
  Written   : DWORD;
 Begin
  FillChar(SA, SizeOf(SA), 0);
  SA.nLength        := SizeOf(SA);
  SA.bInheritHandle := True;
  Assert.IsTrue(CreatePipe(ReadPipe, WritePipe, @SA, 0));
  SetHandleInformation(WritePipe, HANDLE_FLAG_INHERIT, 0);
  LogHandle := CreateFile(PChar(Directory + '\process.log'), GENERIC_WRITE, FILE_SHARE_READ, @SA, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
  Assert.IsTrue(LogHandle <> INVALID_HANDLE_VALUE);
  Try
   FillChar(SI, SizeOf(SI), 0);
   SI.cb         := SizeOf(SI);
   SI.dwFlags    := STARTF_USESTDHANDLES;
   SI.hStdInput  := ReadPipe;
   SI.hStdOutput := LogHandle;
   SI.hStdError  := LogHandle;
   Cmd           := Command;
   UniqueString(Cmd);
   Assert.IsTrue(CreateProcess(Nil, PChar(Cmd), Nil, Nil, True, CREATE_NO_WINDOW, Nil, PChar(Directory), SI, PI), 'Start fixture process');
   CloseHandle(ReadPipe);
   ReadPipe := 0;
   Try
    Bytes := TEncoding.UTF8.GetBytes(Input);
    If Length(Bytes) > 0 Then
     Assert.IsTrue(WriteFile(WritePipe, Bytes[0], Length(Bytes), Written, Nil));
    CloseHandle(WritePipe);
    WritePipe := 0;
    If WaitForSingleObject(PI.hProcess, 120000) <> WAIT_OBJECT_0 Then
     Begin
      TerminateProcess(PI.hProcess, 1);
      Assert.Fail('Fixture subprocess timeout');
     End;
    Assert.IsTrue(GetExitCodeProcess(PI.hProcess, Result));
   Finally
    CloseHandle(PI.hThread);
    CloseHandle(PI.hProcess);
   End;
  Finally
   If ReadPipe <> 0 Then
    CloseHandle(ReadPipe);
   If WritePipe <> 0 Then
    CloseHandle(WritePipe);
   CloseHandle(LogHandle);
  End;
 End;

Procedure TReleasePEMTests.EncryptedFixtureRoundTrip;
 Var
  Base       : String;
  Repo       : String;
  Setup      : String;
  Shared     : String;
  Engine     : String;
  Build      : String;
  Tools      : String;
  BinDir     : String;
  PrivateKey : String;
  PublicKey  : String;
  OpenSSL    : String;
  Delphi     : String;
  Helper     : String;
  Archive    : String;
  Output     : String;
  Signer     : String;
  Name       : String;
  Target     : String;
  Unpack     : String;
  Files      : TStringDynArray;
  Zip        : TZipFile;
  i          : Integer;
  Manifest   : TJSONObject;
  Bytes      : TBytes;

  Procedure CopySource(Const Relative, Destination : String);
   Begin
    ForceDirectories(ExtractFileDir(Destination));
    TFile.Copy(TestRepositoryPath(Relative), Destination, True);
   End;

  Procedure Execute(Const Command : String; Const Input : String = '');
   Var
    Code : Cardinal;
    Log  : String;
   Begin
    Code := Run(Command, Base, Input);
    If Code <> 0 Then
     Begin
      Log := TFile.ReadAllText(Base + '\process.log');
      TFile.WriteAllText(TestDataDirectory + 'release-pem-failure.log', Command + sLineBreak + Log);
      Assert.Fail('Fixture subprocess failed: ' + Command + sLineBreak + Log);
     End;
   End;

  Procedure CopyNames(Const Source, Destination : String; Const Names : Array Of String);
   Var
    n : String;
   Begin
    For n In Names Do
     CopySource(Source + n, Destination + n);
   End;

 Begin
  OpenSSL := GetEnvironmentVariable('OPENSSL_EXE');
  If OpenSSL = '' Then
   OpenSSL := TPath.Combine(GetEnvironmentVariable('ProgramFiles'), 'Git\usr\bin\openssl.exe');
  If Not FileExists(OpenSSL) Then
   OpenSSL := 'openssl.exe';
  Delphi   := GetEnvironmentVariable('BDS');
  Assert.IsTrue(FileExists(Delphi + '\bin\dcc64.exe'), 'Set BDS for native packager fixture');
  Base := TPath.Combine(TPath.GetTempPath, 'MSFS-FDR-PEM-Test-' + TGUID.NewGuid.ToString);
  Assert.IsFalse(Base.StartsWith(TestRepositoryPath(''), True), 'Ephemeral private key must remain outside repository');
  ForceDirectories(Base);
  Try
   Repo   := Base + '\MSFS2024-FDR\';
   Setup  := Base + '\MSFS2024-FDR-Setup\src\';
   Shared := Base + '\setup-common\src\';
   Engine := Base + '\setup-core\src\';
   Build  := Repo + '.build\';
   Tools  := Repo + 'tools\';
   BinDir := Repo + 'bin\';
   ForceDirectories(Setup);
   ForceDirectories(Shared);
   ForceDirectories(Engine);
   ForceDirectories(Build);
   ForceDirectories(Tools);
   ForceDirectories(BinDir);
   ForceDirectories(Repo + 'src\Common');
   PrivateKey := Base + '\private.pem';
   PublicKey  := Setup + 'public.pem';
   Execute(Q(OpenSSL) + ' genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:3072 -aes-256-cbc -pass stdin -out ' + Q(PrivateKey), 'public-test-fixture-passphrase' + #10);
   Assert.IsTrue(TFile.ReadAllText(PrivateKey).StartsWith('-----BEGIN ENCRYPTED PRIVATE KEY-----'));
   Execute(Q(OpenSSL) + ' pkey -in ' + Q(PrivateKey) + ' -passin stdin -pubout -out ' + Q(PublicKey), 'public-test-fixture-passphrase' + #10);
   Execute('python ' + Q(TestRepositoryPath('tools\pin_release_key.py')) + ' ' + Q(PublicKey) + ' ' + Q(Setup + 'UpdatePublicKey.inc'));
   CopyNames('..\MSFS2024-FDR-Setup\src\', Setup, ['PackageRelease.dpr', 'ReleasePackageU.pas', 'FDRSetupProductU.pas']);
   CopyNames('..\setup-common\src\', Shared, ['SetupProductU.pas', 'SetupSignatureU.pas', 'UpdateProtocolU.pas']);
   CopySource('..\setup-core\src\SecureZipU.pas', Engine + 'SecureZipU.pas');
   TFile.Copy(Setup + 'UpdatePublicKey.inc', Setup + 'FDRUpdatePublicKey.inc');
   CopySource('src\Common\VersionU.pas', Repo + 'src\Common\VersionU.pas');
   Save(Engine + 'ZipPasswordU.pas', 'unit ZipPasswordU; interface function GetZipPassword:string; implementation function GetZipPassword:string;begin Result:=''public-archive-fixture'';end;end.');
   Save(Engine + 'congratulations.mfz', 'NEVER EXTRACT THIS FIXTURE');
   Save(Repo + 'src\MSFS2024-FDR.dpr', 'fixture repository marker');
   Signer := StringReplace(TestRepositoryPath('tools\Sign-Release.ps1'), '''', '''''', [rfReplaceAll]);
   Save(Tools + 'Sign-Release.ps1', 'param([string]$Archive,[string]$PrivateKey)' + sLineBreak + '$ErrorActionPreference=''Stop''' + sLineBreak + '$secret=ConvertTo-SecureString ''public-test-fixture-passphrase'' -AsPlainText -Force' + sLineBreak + '& ''' + Signer + ''' -Archive $Archive -PrivateKey $PrivateKey -KeyPassword $secret' + sLineBreak);
   CopyNames('bin\', BinDir, ['MSFS2024-FDR.exe', 'MSFS24-FDR-Setup.exe', 'SimConnect.dll', 'sqlite3.dll', 'MSFS2024-FDR.i18n', 'LICENSE']);
   Save(BinDir + 'settings.ini', 'PRIVATE FIXTURE - NEVER PACKAGE');
   Save(BinDir + 'simbrief-latest.json', '{"private":"fixture"}');
   Save(BinDir + 'settings.example.ini', '[ui]' + sLineBreak + 'language=auto');
   Execute(Q(TestRepositoryPath('Tools\Formatter\Format_MSFS24-FDR.exe')) + ' /nogui');
   Execute(Q(Delphi + '\bin\dcc64.exe') + ' -B -Q -NSSystem;System.Win;Winapi;Vcl;Xml;Xml.Win ' + Q('-U' + Delphi + '\lib\win64\release;' + Setup + ';' + Repo + 'src\Common;' + Shared + ';' + Engine) + ' ' + Q('-E' + Build) + ' ' + Q('-N0' + Build) + ' ' + Q(Setup + 'PackageRelease.dpr'));
   Target := BinDir + 'Optional-Community\MSFS24-FDR-Bridge\';
   Save(Target + 'manifest.json', '{}');
   Save(Target + 'layout.json', '{}');
   Save(Target + 'InGamePanels\InGamePanel_FDRBridge.spb', 'public fixture');
   Helper := Build + 'PackageRelease.exe';
   Output := Repo + 'dist';
   Execute(Q(Helper) + ' --package --key ' + Q(PrivateKey) + ' --output ' + Q(Output));
   Files := TDirectory.GetFiles(Output, 'MSFS2024-FDR-Win64-*.zip');
   Assert.AreEqual(1, Integer(Length(Files)));
   Archive  := Files[0];
   Manifest := TJSONObject.ParseJSONValue(TFile.ReadAllText(Archive + '.manifest.json')) As TJSONObject;
   Try
    Assert.AreEqual(LowerCase(THashSHA2.GetHashStringFromFile(Archive)), Manifest.GetValue('sha256').Value);
   Finally
    Manifest.Free;
   End;
   Zip := TZipFile.Create;
   Try
    Zip.Open(Archive, zmRead);
    For i := 0 To Zip.FileCount - 1 Do
     Begin
      Assert.IsTrue((Zip.FileInfo[i].Flag And 1) <> 0, 'Every entry encrypted');
      Name := ExtractFileName(StringReplace(Zip.FileNames[i], '/', '\', [rfReplaceAll]));
      Assert.IsFalse(SameText(Name, 'settings.ini') Or SameText(Name, 'simbrief-latest.json') Or SameText(Name, 'private.pem'));
     End;
   Finally
    Zip.Free;
   End;
   Save(PublicKey, 'UNTRUSTED REPLACED PUBLIC PEM');
   Save(Build + 'public.pem', 'UNTRUSTED RUNTIME PUBLIC PEM');
   Unpack := Repo + 'unpacked';
   Execute(Q(Helper) + ' --verify ' + Q(Archive) + ' ' + Q(Unpack));
   Assert.IsFalse(FileExists(Unpack + '\congratulations.mfz'));
   Assert.AreEqual(THashSHA2.GetHashStringFromFile(BinDir + 'MSFS2024-FDR.exe'), THashSHA2.GetHashStringFromFile(Unpack + '\MSFS2024-FDR.exe'));
   Bytes    := TFile.ReadAllBytes(Archive + '.manifest.json.sig');
   Bytes[0] := Bytes[0] Xor 1;
   TFile.WriteAllBytes(Archive + '.manifest.json.sig', Bytes);
   Assert.IsTrue(Run(Q(Helper) + ' --verify ' + Q(Archive) + ' ' + Q(Repo + 'must-not-extract'), Base, '') <> 0);
   Assert.IsFalse(DirectoryExists(Repo + 'must-not-extract'));
   Save(Tools + 'Sign-Release.ps1', StringReplace(TFile.ReadAllText(Tools + 'Sign-Release.ps1'), 'public-test-fixture-passphrase', 'WRONG-PUBLIC-FIXTURE-PASSWORD', [rfReplaceAll]));
   Assert.IsTrue(Run(Q(Helper) + ' --package --key ' + Q(PrivateKey) + ' --output ' + Q(Repo + 'failed-release'), Base, '') <> 0);
   If DirectoryExists(Repo + 'failed-release') Then
    Assert.AreEqual(0, Integer(Length(TDirectory.GetFiles(Repo + 'failed-release', '*.zip*'))));
  Finally
   // Only the verified, uniquely named system-temp fixture may be removed.
   Assert.IsTrue(ExtractFileDir(Base) = ExcludeTrailingPathDelimiter(TPath.GetTempPath));
   Assert.IsTrue(ExtractFileName(Base).StartsWith('MSFS-FDR-PEM-Test-'));
   TDirectory.Delete(Base, True);
  End;
 End;

Begin
 RunNativeTests(TReleasePEMTests);

End.
