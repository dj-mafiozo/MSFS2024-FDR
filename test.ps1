param([string]$DelphiRoot='', [string[]]$Tests=@(), [string]$I18nRoot='', [string]$VirtualTreeRoot='')
$ErrorActionPreference='Stop'
$Tests=@($Tests | ForEach-Object {$_.Split(',')} | ForEach-Object {$_.Trim()} | Where-Object {$_})
. (Join-Path $PSScriptRoot 'tools\Toolchain.ps1')
$DelphiRoot=Resolve-FDRDelphiRoot $DelphiRoot
$env:BDS=$DelphiRoot
$env:BDSINCLUDE=Join-Path $DelphiRoot 'include'
foreach($check in @('sync_test_projects.py','check_project_groups.py','check_project.py','check_project_units.py','check_version.py','check_translations.py','check_documentation.py','check_fonts.py','check_addon_catalog.py','check_airliner_catalog.py')) {
 $arguments=@((Join-Path $PSScriptRoot "tools\$check"))
 if($check -eq 'sync_test_projects.py'){$arguments+='--check'}
 & python @arguments
 if($LASTEXITCODE -ne 0){throw "Check failed: $check"}
}
$msbuild=Join-Path $env:WINDIR 'Microsoft.NET\Framework\v4.0.30319\MSBuild.exe'
$projects=if($Tests.Count){$Tests}else{@(Get-ChildItem "$PSScriptRoot\tests\Verify*.dpr" | ForEach-Object BaseName)}
if(($Tests.Count -eq 0) -or ($Tests -contains 'VerifyVersionLanguage') -or ($Tests -contains 'VerifyLocaleExpansion') -or ($Tests -contains 'VerifyReleasePEM')) {
 Invoke-FDRFormatter $PSScriptRoot
 & $msbuild (Join-Path $PSScriptRoot 'src\MSFS2024-FDR.dproj') /t:Build /p:Config=Release /p:Platform=Win64 /v:minimal /nologo
 if($LASTEXITCODE -ne 0){throw 'Test application build failed'}
}
# The signing fixture copies both executables and requires matching VersionInfo.
if(($Tests.Count -eq 0) -or ($Tests -contains 'VerifyReleasePEM')) {
 & (Join-Path $PSScriptRoot 'tools/build_setup_stub.ps1') -DelphiRoot $DelphiRoot
 if($LASTEXITCODE -ne 0){throw 'Test Setup stub build failed'}
}
$dependencies=@('MockFlightPad32','MockGhostSim','MockFenixSim','MockPMDGSim','MockPMDG777Sim','MockAddonSim','MockLifecycleSim','CaptureHelpScreenshots')
try {
 # Format the complete group once, then compile that group as one MSBuild invocation.
 # Avoid reformatting shared sources while another project in the same batch builds.
 Invoke-FDRFormatter $PSScriptRoot
 $targets=($dependencies+$projects) -join ';'
 $arguments=@((Join-Path $PSScriptRoot 'tests\Tests.groupproj'),('/t:'+$targets),'/p:Config=Release','/p:Platform=Win64','/v:minimal','/nologo')
 if($I18nRoot){$arguments+="/p:I18nRoot=$I18nRoot"}
 if($VirtualTreeRoot){$arguments+="/p:VirtualTreeRoot=$VirtualTreeRoot"}
 & $msbuild @arguments
 if($LASTEXITCODE -ne 0){throw 'Test group compilation failed'}
 $failed=@()
 foreach($name in $projects) {
  & (Join-Path $PSScriptRoot "tests\$name.exe")
  if($LASTEXITCODE -ne 0){$failed+=$name}
 }
 if($failed.Count){throw ('Failed tests: '+($failed -join ', '))}
} finally {
 Get-ChildItem (Join-Path $PSScriptRoot 'tests') -Recurse -File | Where-Object {$_.Extension -in @('.rsm','.map')} | Remove-Item -Force
}
