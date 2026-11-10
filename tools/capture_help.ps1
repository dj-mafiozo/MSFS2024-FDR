param([string]$DelphiRoot='')
$ErrorActionPreference='Stop'
$repo=Split-Path $PSScriptRoot
. (Join-Path $PSScriptRoot 'Toolchain.ps1')
$DelphiRoot=Resolve-FDRDelphiRoot $DelphiRoot
$env:BDS=$DelphiRoot
$env:BDSINCLUDE=Join-Path $DelphiRoot 'include'
Invoke-FDRFormatter $repo
& python (Join-Path $PSScriptRoot 'sync_test_projects.py') --check
if($LASTEXITCODE -ne 0){throw 'Test projects not synchronized'}
& (Join-Path $env:WINDIR 'Microsoft.NET\Framework\v4.0.30319\MSBuild.exe') (Join-Path $repo 'tests\CaptureHelpScreenshots.dproj') /t:Build /p:Config=Release /p:Platform=Win64 /v:minimal /nologo
if($LASTEXITCODE -ne 0){throw 'Screenshot generator build failed'}
try {
 & python (Join-Path $PSScriptRoot 'help_assets.py') --prepare
 if($LASTEXITCODE -ne 0){throw 'Screenshot preparation failed'}
 & (Join-Path $repo 'tests\CaptureHelpScreenshots.exe')
 if($LASTEXITCODE -ne 0){throw 'Screenshot capture failed'}
 & python (Join-Path $PSScriptRoot 'help_assets.py') --stamp
 if($LASTEXITCODE -ne 0){throw 'Screenshot provenance failed'}
} finally {
 Get-ChildItem (Join-Path $repo 'tests') -File -Recurse | Where-Object {$_.Extension -in @('.map','.rsm')} | Remove-Item -Force
}
