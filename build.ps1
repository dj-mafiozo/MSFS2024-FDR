param([string]$DelphiRoot='',[string]$SDKRoot=$env:MSFS_SDK,[string]$I18nRoot='',[string]$VirtualTreeRoot='')
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'tools\Toolchain.ps1')
$DelphiRoot=Resolve-FDRDelphiRoot $DelphiRoot
$formatter=Start-Process -FilePath "$PSScriptRoot\Tools\Formatter\Format_MSFS24-FDR.exe" -ArgumentList '/nogui' -WindowStyle Hidden -Wait -PassThru
if($formatter.ExitCode -ne 0){throw 'Formatter failed'}

python "$PSScriptRoot\tools\check_addon_catalog.py"
if($LASTEXITCODE -ne 0){throw 'Aircraft catalog metadata mismatch'}
python "$PSScriptRoot\tools\check_fonts.py"
if($LASTEXITCODE -ne 0){throw 'Bundled fonts or licenses are incomplete'}
python "$PSScriptRoot\tools\check_version.py"
if($LASTEXITCODE -ne 0){throw 'VersionInfo configuration is inconsistent'}
$i18n=$I18nRoot
if([string]::IsNullOrWhiteSpace($i18n)){$i18n=Join-Path (Split-Path $PSScriptRoot) 'i18n\Packages';if(-not(Test-Path -LiteralPath $i18n)){$i18n=Join-Path $PSScriptRoot 'vendor\i18n\Packages'}}
if(-not (Test-Path -LiteralPath $i18n)){throw 'Missing i18n package; install it beside the repository.'}
$virtualTree=$VirtualTreeRoot
if([string]::IsNullOrWhiteSpace($virtualTree)){$virtualTree=Join-Path (Split-Path $PSScriptRoot) 'Virtual-TreeView\Source';if(-not(Test-Path -LiteralPath $virtualTree)){$virtualTree=Join-Path $PSScriptRoot 'vendor\Virtual-TreeView\Source'}}
if(-not(Test-Path -LiteralPath (Join-Path $virtualTree 'VirtualTrees.pas'))){throw 'Missing Virtual TreeView V8 source; set -VirtualTreeRoot.'}
$sourcePaths=@("$PSScriptRoot\src")+@(Get-ChildItem "$PSScriptRoot\src" -Directory -Recurse | Where-Object {$_.FullName -notmatch '[\\/]__(history|recovery)([\\/]|$)'} | ForEach-Object FullName)
$unitPaths=($sourcePaths -join ';')+';'+$i18n+';'+$virtualTree
New-Item -ItemType Directory -Path "$PSScriptRoot\bin","$PSScriptRoot\.build\Win64\Release" -Force | Out-Null
Copy-Item -LiteralPath "$PSScriptRoot\translations\MSFS2024-FDR.i18n" -Destination "$PSScriptRoot\bin\MSFS2024-FDR.i18n" -Force
Push-Location "$PSScriptRoot\src"
try {
  $env:BDS=$DelphiRoot
  $env:BDSINCLUDE=Join-Path $DelphiRoot 'include'
  & "$env:WINDIR\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe" "$PSScriptRoot\src\MSFS2024-FDR.dproj" /t:Build /p:Config=Release /p:Platform=Win64 "/p:I18nRoot=$i18n" "/p:VirtualTreeRoot=$virtualTree" /v:minimal /nologo
  if ($LASTEXITCODE -ne 0) {throw 'Delphi VCL build failed'}
  $sim=if($SDKRoot){Join-Path $SDKRoot 'SimConnect SDK\lib\SimConnect.dll'}else{Join-Path $PSScriptRoot 'runtime\SimConnect.dll'}
  if(-not (Test-Path -LiteralPath $sim)){$sim="$PSScriptRoot\runtime\SimConnect.dll"}
  [IO.File]::WriteAllBytes("$PSScriptRoot\bin\SimConnect.dll",[IO.File]::ReadAllBytes($sim))
  $sqlite=Join-Path (Split-Path $PSScriptRoot) 'MSFS-Flight-Data-Recorder-master\third_party\sqlite3\sqlite3.dll'
  if(-not (Test-Path -LiteralPath $sqlite)){$sqlite="$PSScriptRoot\runtime\sqlite3.dll"}
  [IO.File]::WriteAllBytes("$PSScriptRoot\bin\sqlite3.dll",[IO.File]::ReadAllBytes($sqlite))
}finally{Pop-Location}

& python "$PSScriptRoot\tools\build_help.py"
if($LASTEXITCODE -ne 0){throw 'Help build failed'}

& "$PSScriptRoot\tools\build_setup_stub.ps1" -DelphiRoot $DelphiRoot
if($LASTEXITCODE -ne 0){throw 'Setup stub build failed'}
