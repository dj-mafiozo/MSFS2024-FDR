param([string]$DelphiRoot='C:\Program Files (x86)\Embarcadero\Studio\19.0',[string]$SDKRoot='C:\MSFS 2024 SDK',[string]$I18nRoot='')
$ErrorActionPreference='Stop'
python "$PSScriptRoot\tools\check_fonts.py"
if($LASTEXITCODE -ne 0){throw 'Bundled fonts or licenses are incomplete'}
python "$PSScriptRoot\tools\check_version.py"
if($LASTEXITCODE -ne 0){throw 'VersionInfo configuration is inconsistent'}
$i18n=$I18nRoot
if([string]::IsNullOrWhiteSpace($i18n)){$i18n=Join-Path (Split-Path $PSScriptRoot) 'i18n\Packages';if(-not(Test-Path -LiteralPath $i18n)){$i18n=Join-Path $PSScriptRoot 'vendor\i18n\Packages'}}
if(-not (Test-Path -LiteralPath $i18n)){throw 'Missing i18n package; install it beside the repository.'}
$sourcePaths=@("$PSScriptRoot\src")+@(Get-ChildItem "$PSScriptRoot\src" -Directory -Recurse | Where-Object {$_.FullName -notmatch '[\\/]__(history|recovery)([\\/]|$)'} | ForEach-Object FullName)
$unitPaths=($sourcePaths -join ';')+';'+$i18n
$vendor=Join-Path (Split-Path $PSScriptRoot) 'FSHudPanel\vendor\WebView4Delphi-main'
if(-not (Test-Path $vendor)){$vendor=Join-Path $PSScriptRoot 'vendor\WebView4Delphi-main'}
New-Item -ItemType Directory -Path "$PSScriptRoot\bin","$PSScriptRoot\.build\Win64\Release" -Force | Out-Null
Copy-Item "$vendor\bin64\WebView2Loader.dll" "$PSScriptRoot\bin\WebView2Loader.dll" -Force
Copy-Item -LiteralPath "$PSScriptRoot\translations\MSFS2024-FDR.i18n" -Destination "$PSScriptRoot\bin\MSFS2024-FDR.i18n" -Force
Push-Location "$PSScriptRoot\src"
try {
  $env:BDS=$DelphiRoot
  $env:BDSINCLUDE=Join-Path $DelphiRoot 'include'
  & "$env:WINDIR\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe" "$PSScriptRoot\src\MSFS2024-FDR.dproj" /t:Build /p:Config=Release /p:Platform=Win64 "/p:I18nRoot=$i18n" /v:minimal /nologo
  if ($LASTEXITCODE -ne 0) {throw 'Delphi VCL build failed'}
  $sim="$SDKRoot\SimConnect SDK\lib\SimConnect.dll"
  if(-not (Test-Path -LiteralPath $sim)){$sim="$PSScriptRoot\runtime\SimConnect.dll"}
  [IO.File]::WriteAllBytes("$PSScriptRoot\bin\SimConnect.dll",[IO.File]::ReadAllBytes($sim))
  $sqlite=Join-Path (Split-Path $PSScriptRoot) 'MSFS-Flight-Data-Recorder-master\third_party\sqlite3\sqlite3.dll'
  if(-not (Test-Path -LiteralPath $sqlite)){$sqlite="$PSScriptRoot\runtime\sqlite3.dll"}
  [IO.File]::WriteAllBytes("$PSScriptRoot\bin\sqlite3.dll",[IO.File]::ReadAllBytes($sqlite))
}finally{Pop-Location}

& python "$PSScriptRoot\tools\build_help.py"
if($LASTEXITCODE -ne 0){throw 'Help build failed'}
