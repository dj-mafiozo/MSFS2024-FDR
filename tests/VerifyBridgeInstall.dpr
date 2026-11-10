Program VerifyBridgeInstall;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU, System.SysUtils, System.Classes, System.IOUtils, System.JSON, System.DateUtils, SetupBridgeU, SimulatorPackagesU;

Procedure Check(b : Boolean; Const s : String);
 Begin
  If Not b Then
   Raise Exception.Create(s);
 End;

Var
 Root      : String;
 Source    : String;
 Target    : String;
 Community : String;
 CfgDir    : String;
 p         : String;
 Dirs      : TArray<String>;
 Stamp     : TDateTime;
 Rejected  : Boolean;

Type

 [TestFixture]
 TVerifyBridgeInstallTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyBridgeInstallTests.Regression;
 Begin
  Root      := TestDataDirectory;
  Source    := TPath.Combine(Root, 'stage');
  Target    := TPath.Combine(Root, 'installed');
  Community := TPath.Combine(Root, 'packages\Community');
  ForceDirectories(Source);
  ForceDirectories(Target);
  ForceDirectories(Community);
  TFile.WriteAllText(TPath.Combine(Target, 'installation.json'), '{}');
  TFile.WriteAllText(TPath.Combine(Source, 'manifest.json'), '{"title":"MSFS24-FDR-Bridge"}');
  TFile.WriteAllText(TPath.Combine(Source, 'layout.json'), '{}');
  TFile.WriteAllText(TPath.Combine(Source, 'panel.js'), 'v1');
  CfgDir := TPath.Combine(Root, 'roaming\Microsoft Flight Simulator 2024');
  ForceDirectories(CfgDir);
  TFile.WriteAllText(TPath.Combine(CfgDir, 'UserCfg.opt'), 'InstalledPackagesPath "' + TPath.Combine(Root, 'packages') + '"', TEncoding.UTF8);
  Dirs := SimulatorCommunityDirectories(TPath.Combine(Root, 'local'), TPath.Combine(Root, 'roaming'));
  Check((Length(Dirs) = 1) And SameText(Dirs[0], Community), 'Custom packages path');
  ConfigureCommunityBridge(Target, Source, Community, True);
  p := TPath.Combine(Community, BridgePackageName + '\panel.js');
  Check(TFile.ReadAllText(p) = 'v1', 'Install');
  Stamp := EncodeDate(2020, 1, 2);
  TFile.SetLastWriteTime(p, Stamp);
  ConfigureCommunityBridge(Target, Source, Community, True);
  Check(Abs(TFile.GetLastWriteTime(p) - Stamp) < 1 / SecsPerDay, 'Unchanged files not replaced');
  TFile.WriteAllText(TPath.Combine(Source, 'panel.js'), 'v2');
  TFile.WriteAllText(TPath.Combine(Source, 'new.js'), 'new');
  ConfigureCommunityBridge(Target, Source, Community, True);
  Check(TFile.ReadAllText(p) = 'v2', 'Update');
  TFile.WriteAllText(p, 'broken');
  ConfigureCommunityBridge(Target, Source, Community, True);
  Check(TFile.ReadAllText(p) = 'v2', 'Repair');
  TFile.WriteAllText(TPath.Combine(Community, 'unrelated.txt'), 'keep');
  TFile.WriteAllText(TPath.Combine(Community, BridgePackageName + '\user-note.txt'), 'keep');
  ConfigureCommunityBridge(Target, '', Community, False);
  Check(Not FileExists(p), 'Unchecked removes owned addon');
  Check(FileExists(TPath.Combine(Community, 'unrelated.txt')), 'Other addons preserved');
  Check(FileExists(TPath.Combine(Community, BridgePackageName + '\user-note.txt')), 'Unowned file preserved');
  Check(Not FileExists(TPath.Combine(Target, BridgeReceiptName)), 'Receipt removed');
  Rejected := False;
  Try
   ConfigureCommunityBridge(Target, Source, Community, True);
  Except
   Rejected := True;
  End;
  Check(Rejected, 'Unmanaged existing folder protected');
  System.Writeln('PASS: custom Community detection, bridge install/update/repair, unchanged-file preservation, uninstall/unchecked cleanup and unowned-file protection. Isolated fixtures only.');

 End;

Begin
 RunNativeTests(TVerifyBridgeInstallTests);
End.
