param([string]$DelphiRoot='',[ValidateSet('Debug','Release')][string]$Config='Release',[switch]$RealInstaller)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'Toolchain.ps1')
$DelphiRoot=Resolve-FDRDelphiRoot $DelphiRoot
$repo=Split-Path $PSScriptRoot
if(-not $RealInstaller) {
 & "$PSScriptRoot\build_setup_stub.ps1" -DelphiRoot $DelphiRoot
 if($LASTEXITCODE -ne 0){throw 'Setup stub build failed'}
 return
}
$setup=Join-Path $repo '..\MSFS2024-FDR-Setup\src'
$core=Join-Path $repo '..\setup-core\src'
if(-not(Test-Path -LiteralPath "$core\ZipPasswordU.pas")){throw 'Private ZipPasswordU.pas is required for a distributable installer; see support/setup/README.md.'}
if(-not(Test-Path -LiteralPath "$repo\..\MSFS2024-FDR-Setup\src\UpdatePublicKey.inc")){throw 'Pinned public key missing: run tools/New-ReleaseSigningKey.ps1 once on the release machine.'}
$passwordSourceHash=(Get-FileHash -LiteralPath "$core\ZipPasswordU.pas" -Algorithm SHA256).Hash
$env:BDS=$DelphiRoot
$env:BDSINCLUDE=Join-Path $DelphiRoot 'include'
New-Item -ItemType Directory -Force "$repo\bin","$repo\.build\Win64\Setup-$Config" | Out-Null
& "$PSScriptRoot\build_setup_resources.ps1" -DelphiRoot $DelphiRoot
[xml]$mainProject=Get-Content -LiteralPath "$repo\src\MSFS2024-FDR.dproj" -Raw
$ns=New-Object Xml.XmlNamespaceManager($mainProject.NameTable);$ns.AddNamespace('m','http://schemas.microsoft.com/developer/msbuild/2003')
$numbers=@('MajorVer','MinorVer','Release','Build') | ForEach-Object {$mainProject.SelectSingleNode("//m:VerInfo_$_",$ns).InnerText}
$version=$numbers -join '.'
$setupKeys=$mainProject.SelectSingleNode('//m:VerInfo_Keys',$ns).InnerText
$setupKeys=$setupKeys -replace 'FileDescription=[^;]*','FileDescription=MSFS24-FDR Setup' -replace 'OriginalFilename=[^;]*','OriginalFilename=MSFS24-FDR-Setup.exe' -replace 'ProductName=[^;]*','ProductName=MSFS24-FDR Setup'
$setupKeys=$setupKeys.Replace(';','%3b')

$versionArgs=@("/p:VerInfo_MajorVer=$($numbers[0])","/p:VerInfo_MinorVer=$($numbers[1])","/p:VerInfo_Release=$($numbers[2])","/p:VerInfo_Build=$($numbers[3])","/p:VerInfo_Keys=$setupKeys")
& "$env:WINDIR\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe" "$setup\MSFS24-FDR-Setup.dproj" /t:Build "/p:Config=$Config" /p:Platform=Win64 @versionArgs /v:minimal /nologo
if($LASTEXITCODE -ne 0){throw 'Setup build failed'}
Push-Location $setup
try {
 & "$DelphiRoot\bin\dcc64.exe" -B -Q '-NSSystem;System.Win;Winapi;Vcl;Xml;Xml.Win' "-U$DelphiRoot\lib\win64\release;$repo\..\MSFS2024-FDR-Setup\src;$repo\src\Common;$repo\src\Core;$repo\..\setup-common\src;$repo\..\setup-core\src" "-E$repo\.build\Win64\Setup-$Config" "-N0$repo\.build\Win64\Setup-$Config" PackageRelease.dpr
 if($LASTEXITCODE -ne 0){throw 'Release archive helper build failed'}
 Copy-Item -LiteralPath "$repo\.build\Win64\Setup-$Config\PackageRelease.exe" -Destination "$repo\.build\PackageRelease.exe" -Force
} finally {Pop-Location}
if((Get-FileHash -LiteralPath "$core\ZipPasswordU.pas" -Algorithm SHA256).Hash -ne $passwordSourceHash){throw 'Private ZIP implementation changed during build; rebuild setup and helper together.'}
New-Item -ItemType Directory -Force "$repo\bin\licenses" | Out-Null
Copy-Item -LiteralPath "$repo\src\Common\LICENSE" -Destination "$repo\bin\licenses\Common-LICENSE.txt" -Force
Copy-Item -LiteralPath "$repo\..\setup-common\LICENSE" -Destination "$repo\bin\licenses\setup-common-LICENSE.txt" -Force
Copy-Item -LiteralPath "$repo\support\i18n\LICENSE" -Destination "$repo\bin\licenses\i18n-LICENSE.txt" -Force
Copy-Item -LiteralPath "$repo\vendor\Delphi-StackTrace\License" -Destination "$repo\bin\licenses\Delphi-StackTrace-LICENSE.txt" -Force
Copy-Item -LiteralPath "$repo\support\flightpad\LICENSE.md" -Destination "$repo\bin\licenses\FlightPadFMC-LICENSE.txt" -Force
Copy-Item -LiteralPath "$repo\docs\flightsim-to\START-HERE.en.txt","$repo\README.md","$repo\README.en.md","$repo\README.de.md","$repo\README.es.md" -Destination "$repo\bin" -Force
Get-ChildItem -LiteralPath "$repo\support" -Recurse -Filter '*.md' | ForEach-Object {
 $relative=$_.FullName.Substring((Join-Path $repo 'support').Length).TrimStart('\')
 $destination=Join-Path "$repo\bin\support" $relative
 New-Item -ItemType Directory -Force (Split-Path $destination) | Out-Null
 Copy-Item -LiteralPath $_.FullName -Destination $destination -Force
 # Remove only a byte-identical copy from the previous generated documentation layout.
 $legacyRoot=[IO.Path]::GetFullPath("$repo\bin\docs\support")
 $legacy=[IO.Path]::GetFullPath((Join-Path $legacyRoot $relative))
 if($legacy.StartsWith($legacyRoot+'\',[StringComparison]::OrdinalIgnoreCase) -and (Test-Path -LiteralPath $legacy -PathType Leaf)) {
  if((Get-FileHash -LiteralPath $legacy).Hash -eq (Get-FileHash -LiteralPath $_.FullName).Hash){Remove-Item -LiteralPath $legacy}
 }
}
New-Item -ItemType Directory -Force "$repo\bin\community\Bridge" | Out-Null
Copy-Item -LiteralPath "$repo\community\Bridge\README.en.md" -Destination "$repo\bin\community\Bridge\README.en.md" -Force
foreach($folder in @('translations','runtime')) {
 New-Item -ItemType Directory -Force "$repo\bin\$folder" | Out-Null
 Get-ChildItem -LiteralPath "$repo\$folder" -Filter 'README*.md' | Copy-Item -Destination "$repo\bin\$folder" -Force
}
Get-ChildItem -LiteralPath $repo -Filter 'Translation.*.md' | Copy-Item -Destination "$repo\bin" -Force
Get-ChildItem -LiteralPath $repo -Filter 'Testy*.md' | Copy-Item -Destination "$repo\bin" -Force
Copy-Item -LiteralPath "$repo\LICENSE","$repo\NOTICE.en.md" -Destination "$repo\bin" -Force
Copy-Item -LiteralPath "$repo\changelog.md","$repo\CHANGELOG.en.md" -Destination "$repo\bin" -Force
Write-Output 'PASS: native Win64 setup and password-aware archive helper built; no password was printed.'
