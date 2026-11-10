param([string]$DelphiRoot='')
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'Toolchain.ps1')
$DelphiRoot=Resolve-FDRDelphiRoot $DelphiRoot
$repo=Split-Path $PSScriptRoot;$setup=Join-Path $repo '..\MSFS2024-FDR-Setup\src'
& python "$PSScriptRoot\pin_release_key.py" "$setup\public.pem" "$setup\UpdatePublicKey.inc"
if($LASTEXITCODE -ne 0){throw 'Invalid public PEM trust anchor'}
Copy-Item -LiteralPath "$setup\UpdatePublicKey.inc" -Destination "$setup\FDRUpdatePublicKey.inc" -Force
& python "$PSScriptRoot\build_resources.py" --setup
if($LASTEXITCODE -ne 0){throw 'Setup RC resource build failed'}
Copy-Item -LiteralPath "$repo\translations\MSFS2024-FDR.i18n" -Destination "$repo\bin" -Force
