param([string]$DelphiRoot='')
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'Toolchain.ps1')
$DelphiRoot=Resolve-FDRDelphiRoot $DelphiRoot
$repo=Split-Path $PSScriptRoot
Invoke-FDRFormatter $repo
[xml]$main=Get-Content -LiteralPath "$repo\src\MSFS2024-FDR.dproj" -Raw -Encoding UTF8
[xml]$stub=Get-Content -LiteralPath "$repo\tools\SetupStub\MSFS24-FDR-Setup.dproj" -Raw -Encoding UTF8
$ns=New-Object Xml.XmlNamespaceManager($main.NameTable)
$ns.AddNamespace('m','http://schemas.microsoft.com/developer/msbuild/2003')
$sn=New-Object Xml.XmlNamespaceManager($stub.NameTable)
$sn.AddNamespace('m','http://schemas.microsoft.com/developer/msbuild/2003')
foreach($key in @('MajorVer','MinorVer','Release','Build','Keys')) {
 $stub.SelectSingleNode("//m:VerInfo_$key",$sn).InnerText=$main.SelectSingleNode("//m:VerInfo_$key",$ns).InnerText
}
$keys=$stub.SelectSingleNode('//m:VerInfo_Keys',$sn)
$keys.InnerText=$keys.InnerText.Replace('OriginalFilename=MSFS24-FDR.exe','OriginalFilename=MSFS24-FDR-Setup.exe').Replace('InternalName=MSFS24-FDR;','InternalName=MSFS24-FDR-Setup;').Replace('FileDescription=MSFS24 Flight Data Recorder','FileDescription=MSFS24-FDR Setup placeholder')
$stub.Save("$repo\tools\SetupStub\MSFS24-FDR-Setup.dproj")
$env:BDS=$DelphiRoot
& "$env:WINDIR\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe" "$repo\tools\SetupStub\MSFS24-FDR-Setup.dproj" /t:Build /p:Config=Release /p:Platform=Win64 /v:minimal /nologo
if($LASTEXITCODE -ne 0){throw 'Setup stub build failed'}
Write-Output 'PASS: message-only stub built by Delphi MSBuild.'
