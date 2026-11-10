# Resolve installed tools without user-specific paths or drive assumptions.
function Resolve-FDRDelphiRoot([string]$Requested='') {
 $candidates=@($Requested,$env:BDS)
 foreach($registry in @('HKCU:\Software\Embarcadero\BDS','HKLM:\Software\Embarcadero\BDS','HKLM:\Software\WOW6432Node\Embarcadero\BDS')) {
  if(Test-Path $registry){foreach($key in (Get-ChildItem $registry | Sort-Object PSChildName -Descending)){$candidates+=(Get-ItemProperty $key.PSPath -ErrorAction SilentlyContinue).RootDir}}
 }
 $command=Get-Command dcc64.exe -ErrorAction SilentlyContinue
 if($command){$candidates+=Split-Path (Split-Path $command.Source)}
 foreach($candidate in $candidates){if($candidate -and (Test-Path (Join-Path $candidate 'bin\dcc64.exe'))){return (Resolve-Path $candidate).Path}}
 throw 'Delphi not found. Set BDS or pass -DelphiRoot.'
}
function Invoke-FDRFormatter([string]$Repository) {
 $p=Start-Process -FilePath (Join-Path $Repository 'Tools\Formatter\Format_MSFS24-FDR.exe') -ArgumentList '/nogui' -WindowStyle Hidden -Wait -PassThru
 if($p.ExitCode -ne 0){throw 'Formatter failed'}
}
