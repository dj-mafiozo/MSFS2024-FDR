Program VerifySetupArchitecture;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU, System.SysUtils, System.Classes, System.IOUtils, Vcl.Forms,
 SetupProductU, SetupProcessU, SetupHandoffU, UpdateProtocolU, SetupServicesU,
 frmSetupBaseU, SetupWindowsU;

Type
 TFixtureSetup = Class(TfrmSetupBase)
  Protected
   Function ZipPassword : String; Override;
 End;

Function TFixtureSetup.ZipPassword : String;
 Begin
  Result := 'public-fixture';
 End;

Procedure Check(b : Boolean; Const s : String);
 Begin
  If Not b Then
   Raise Exception.Create(s);
 End;

Var
 f    : TFixtureSetup;
 Info : TReleaseInfo;
 Name : String;
 i    : Integer;

Type

 [TestFixture]
 TVerifySetupArchitectureTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifySetupArchitectureTests.Regression;
 Begin
  Try
   Application.Initialize;
   For i := 1 To 2 Do
    Begin
     Name                          := 'IndependentProduct' + IntToStr(i);
     SetupProduct                  := Default(TSetupProduct);
     SetupProduct.ID               := Name;
     SetupProduct.DisplayName      := Name;
     SetupProduct.MainExe          := Name + '.exe';
     SetupProduct.SetupExe         := Name + '-Setup.exe';
     SetupProduct.SetupUpdate      := Name + '-Setup.upd';
     SetupProduct.MutexName        := Name + '-Once';
     SetupProduct.Repository       := 'example/' + Name;
     SetupProduct.ArchivePrefix    := Name + '-Win64-';
     SetupProduct.ArchiveRoot      := Name;
     SetupProduct.SignatureProduct := Name;
     SetupProduct.Platform         := 'Win64';
     Check(ExtractFileName(InstallDirectory) = Name, 'Product-specific Program Files root');
     Check(Pos(Name, LatestReleaseURL) > 0, 'Product-specific release URL');
     Check(MainExeName = Name + '.exe', 'Configured host executable');
     Info := ParseRelease('{"assets":[{"name":"' + Name + '-Win64-1.2.3.4.zip","size":123,"browser_download_url":"https://github.com/example/' + Name + '/releases/download/v1.2.3.4/archive.zip"}]}');
     Check(Info.Version = '1.2.3.4', 'Generic release parser');
     f := TFixtureSetup.Create(Nil);
     Try
      Check(f.Pages.PageCount = 5, 'Base DFM has only reusable pages');
      Check(f.FindComponent('cbBridge') = Nil, 'No FDR component in base');
      Check(Pos(Name, f.Caption) > 0, 'Product-aware wizard title');
      f.NextClick(Nil);
      Check(f.Pages.ActivePage = f.OptionsPage, 'Base options navigation');
      f.BackClick(Nil);
      Check(f.Pages.ActivePage = f.WelcomePage, 'Base back navigation');
     Finally
      f.Free;
     End;
    End;
   System.Writeln('PASS: two independent product identities, generic protocol/process helpers and reusable DFM; no FDR units linked by this fixture.');
  Except
   On E : Exception Do
    Begin
     System.Writeln(E.ClassName + ': ' + E.Message);
     Raise Exception.Create('Regression failed; see diagnostic above');
    End;
  End;

 End;

Begin
 RunNativeTests(TVerifySetupArchitectureTests);
End.
