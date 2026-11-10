param([Parameter(Mandatory=$true)][string]$Archive,[string]$PrivateKey=$env:MSFS_FDR_SIGNING_KEY,[Security.SecureString]$KeyPassword)
$ErrorActionPreference='Stop'
$repo=Split-Path $PSScriptRoot
if(-not $PrivateKey){$PrivateKey=Join-Path $env:USERPROFILE 'Documents\MSFS24-FDR-Signing\private.pem'}
$PrivateKey=[IO.Path]::GetFullPath($PrivateKey)
if($PrivateKey.StartsWith([IO.Path]::GetFullPath($repo)+'\',[StringComparison]::OrdinalIgnoreCase)){throw 'Private key must be outside the repository'}
if(-not(Test-Path -LiteralPath $PrivateKey)){throw 'Missing encrypted private.pem; run tools/New-ReleaseSigningKey.ps1 locally first.'}
if(-not([IO.File]::ReadAllText($PrivateKey).StartsWith('-----BEGIN ENCRYPTED PRIVATE KEY-----'))){throw 'An encrypted PKCS#8 PEM key is required'}
$openssl=Join-Path $env:ProgramFiles 'Git\usr\bin\openssl.exe'
if(-not(Test-Path -LiteralPath $openssl)){$openssl=(Get-Command openssl -ErrorAction Stop).Source}
if(-not $KeyPassword){$KeyPassword=Read-Host 'Private PEM passphrase' -AsSecureString}
function Run-OpenSSL([string]$arguments) {
 $info=New-Object Diagnostics.ProcessStartInfo;$info.FileName=$openssl;$info.Arguments=$arguments
 $info.UseShellExecute=$false;$info.RedirectStandardInput=$true;$info.RedirectStandardError=$true;$info.CreateNoWindow=$true
 $proc=New-Object Diagnostics.Process;$proc.StartInfo=$info;$ptr=[IntPtr]::Zero
 try {
  [void]$proc.Start();$ptr=[Runtime.InteropServices.Marshal]::SecureStringToBSTR($KeyPassword)
  $inputBytes=(New-Object Text.UTF8Encoding($false)).GetBytes([Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)+"`n")
  try {$proc.StandardInput.BaseStream.Write($inputBytes,0,$inputBytes.Length);$proc.StandardInput.BaseStream.Flush();$proc.StandardInput.Close()}
  finally {[Array]::Clear($inputBytes,0,$inputBytes.Length)}
  $errorText=$proc.StandardError.ReadToEnd();$proc.WaitForExit();if($proc.ExitCode -ne 0){throw ('OpenSSL failed: '+$errorText)}
 } finally {if($ptr -ne [IntPtr]::Zero){[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)};$proc.Dispose()}
}
if($PrivateKey.Contains('"') -or $Archive.Contains('"')){throw 'Invalid path'}
$name=[IO.Path]::GetFileName($Archive)
$product='MSFS2024-FDR';$platform='Win64'
if($name -match '^MSFS24-FDR-Bridge-(\d+\.\d+\.\d+\.\d+)\.zip$'){$version=$Matches[1];$product='MSFS24-FDR-Bridge';$platform='Community'}
elseif($name -match '^MSFS2024-FDR-Win64-(\d+\.\d+\.\d+\.\d+)\.zip$'){$version=$Matches[1]}
else{throw 'Unexpected release filename'}
;$sha=[Security.Cryptography.SHA256]::Create();$s=[IO.File]::OpenRead($Archive)
try {$hash=$sha.ComputeHash($s);$size=$s.Length} finally {$s.Dispose();$sha.Dispose()}
$manifest=[ordered]@{product=$product;platform=$platform;version=$version;package=$name;size=$size;sha256=([BitConverter]::ToString($hash).Replace('-','').ToLowerInvariant())}
[IO.File]::WriteAllText($Archive+'.manifest.json',($manifest | ConvertTo-Json -Compress),(New-Object Text.UTF8Encoding($false)))
Run-OpenSSL ('dgst -sha256 -sign "'+$PrivateKey+'" -passin stdin -sigopt rsa_padding_mode:pss -sigopt rsa_pss_saltlen:32 -out "'+$Archive+'.sig" "'+$Archive+'"')
Run-OpenSSL ('dgst -sha256 -sign "'+$PrivateKey+'" -passin stdin -sigopt rsa_padding_mode:pss -sigopt rsa_pss_saltlen:32 -out "'+$Archive+'.manifest.json.sig" "'+$Archive+'.manifest.json"')
Write-Output 'RSA-PSS ZIP and manifest signatures created; no private key or passphrase was exported to the package.'
