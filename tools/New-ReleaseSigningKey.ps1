param([string]$PrivateKey=(Join-Path $env:USERPROFILE 'Documents\MSFS24-FDR-Signing\private.pem'),[switch]$RotateTrustAnchor)
$ErrorActionPreference='Stop'
$repo=Split-Path $PSScriptRoot
$openssl=Join-Path $env:ProgramFiles 'Git\usr\bin\openssl.exe'
if(-not(Test-Path -LiteralPath $openssl)){$openssl=(Get-Command openssl -ErrorAction Stop).Source}
$PrivateKey=[IO.Path]::GetFullPath($PrivateKey)
if($PrivateKey.StartsWith([IO.Path]::GetFullPath($repo)+'\',[StringComparison]::OrdinalIgnoreCase)){throw 'Private key must be outside the repository'}
if(Test-Path -LiteralPath $PrivateKey){throw 'Refusing to overwrite an existing private key'}
$public=Join-Path $repo '..\MSFS2024-FDR-Setup\src\public.pem'
if((Test-Path -LiteralPath $public) -and -not $RotateTrustAnchor){throw 'An existing public trust anchor requires explicit -RotateTrustAnchor and a rebuilt installer.'}
$dir=Split-Path $PrivateKey
$newDirectory=-not(Test-Path -LiteralPath $dir)
New-Item -ItemType Directory -Force $dir | Out-Null
if($newDirectory){
 $acl=Get-Acl -LiteralPath $dir;$acl.SetAccessRuleProtection($true,$false)
 $sid=[Security.Principal.WindowsIdentity]::GetCurrent().User
 $rule=New-Object Security.AccessControl.FileSystemAccessRule($sid,'FullControl','ContainerInherit,ObjectInherit','None','Allow')
 $acl.AddAccessRule($rule);Set-Acl -LiteralPath $dir -AclObject $acl
}
# OpenSSL asks for the passphrase locally with console echo disabled. No -passout argument.
& $openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:3072 -aes-256-cbc -out $PrivateKey
if($LASTEXITCODE -ne 0){throw 'Encrypted private-key generation failed'}
$keyAcl=Get-Acl -LiteralPath $PrivateKey;$keyAcl.SetAccessRuleProtection($true,$false)
$keyAcl.AddAccessRule((New-Object Security.AccessControl.FileSystemAccessRule([Security.Principal.WindowsIdentity]::GetCurrent().User,'FullControl','Allow')))
Set-Acl -LiteralPath $PrivateKey -AclObject $keyAcl
$pending=Join-Path $repo '.build\pending-public.pem';$pendingInc=Join-Path $repo '.build\pending-public.inc'
& $openssl pkey -in $PrivateKey -pubout -out $pending
if($LASTEXITCODE -ne 0){throw 'Public key export failed'}
& python "$PSScriptRoot\pin_release_key.py" $pending $pendingInc
if($LASTEXITCODE -ne 0){throw 'Public-key pin generation failed'}
Copy-Item -LiteralPath $pending -Destination $public -Force
Copy-Item -LiteralPath $pendingInc -Destination "$repo\..\MSFS2024-FDR-Setup\src\FDRUpdatePublicKey.inc" -Force
Copy-Item -LiteralPath $pendingInc -Destination "$repo\..\MSFS2024-FDR-Setup\src\UpdatePublicKey.inc" -Force
Remove-Item -LiteralPath $pending,$pendingInc
Write-Output 'Encrypted private.pem remains outside the repository. Rebuild Setup and PackageRelease with the new compiled public key before signing a release.'
