param(
  [string]$FlightPadRoot='',
  [string]$DelphiRoot=''
)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'Toolchain.ps1')
$DelphiRoot=Resolve-FDRDelphiRoot $DelphiRoot
$project=Split-Path $PSScriptRoot
if(-not $FlightPadRoot){$FlightPadRoot=Join-Path (Split-Path $project) 'FlightPadFMC\Windows'}
if(-not(Test-Path $FlightPadRoot)){throw 'FlightPadFMC not found beside this repository; pass -FlightPadRoot.'}
Invoke-FDRFormatter $project
$shared=Join-Path $FlightPadRoot 'Common\FlightPadScreenIPC.pas'
$externalIPC=([IO.File]::ReadAllText($shared) -replace '(?i)unit FlightPadScreenIPC;', 'unit FlightPadScreenIPCU;') -replace '\r\n', "`n"
$recorderIPC=[IO.File]::ReadAllText((Join-Path $project 'src\fmc\FlightPadScreenIPCU.pas')) -replace '\r\n', "`n"
if($externalIPC.Trim() -ne $recorderIPC.Trim()){throw 'IPC implementations differ (unit-name normalization allowed)'}
$compiler=Join-Path $DelphiRoot 'bin\dcc32.exe'
foreach($folder in @('FenixA320','FBWA320')) {
  $out=Join-Path $project ('.build\flightpad-verify\'+$folder)
  New-Item -ItemType Directory -Path $out -Force | Out-Null
  foreach($source in Get-ChildItem -LiteralPath (Join-Path $FlightPadRoot $folder) -Filter *.dpr) {
    & $compiler -B -Q '-NSSystem;Winapi;Vcl;Data' "-U$DelphiRoot\lib\win32\release;$FlightPadRoot\Common;$FlightPadRoot\$folder" "-N0$out" "-E$out" $source.FullName
    if($LASTEXITCODE -ne 0){throw "Compile failed: $($source.Name)"}
  }
}
$out=Join-Path $project '.build\flightpad-verify\tests'
New-Item -ItemType Directory -Path $out -Force | Out-Null
& $compiler -B -Q '-NSSystem;Winapi;Vcl;Data' "-U$DelphiRoot\lib\win32\release;$FlightPadRoot\Common" "-N0$out" "-E$out" (Join-Path $FlightPadRoot 'tests\ExportTests.dpr')
if($LASTEXITCODE -ne 0){throw 'Compile failed: ExportTests'}
& (Join-Path $out 'ExportTests.exe')
if($LASTEXITCODE -ne 0){throw 'FlightPad model export test failed'}
Write-Output 'PASS: four installed FlightPad clients compile; identical IPC unit in FDR and FlightPad.'
