param([ValidateSet('all','main','small','simbrief','charts','map','graph','fmc','sixpack','engines','pfd737')][string]$List='all',[string]$DelphiRoot='')
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'Toolchain.ps1')
$DelphiRoot=Resolve-FDRDelphiRoot $DelphiRoot
$root=Split-Path $PSScriptRoot
New-Item -ItemType Directory -Path "$root\.build" -Force | Out-Null
& "$DelphiRoot\bin\dcc64.exe" -B -Q '-NSSystem;Winapi;Vcl' "-U$DelphiRoot\lib\win64\release" "-E$root\.build" "-N0$root\.build" "$PSScriptRoot\RebuildToolbarImages.dpr"
if($LASTEXITCODE -ne 0){throw 'Icon helper build failed'}
$entries=@(@('main','src\Forms\frmMainU.dfm','ImageList',22,'main'),@('small','src\Forms\frmMainU.dfm','ImageListSmall',16,'main'),@('simbrief','src\Frames\frmSimBriefFrameU.dfm','ImageList',22,'dispatch'),@('charts','src\Forms\frmChartsConfigureU.dfm','ImageList',22,'charts'),@('map','src\Frames\fraMapU.dfm','ImageList',22,'views'),@('graph','src\Frames\fraGraphU.dfm','ImageList',22,'views'),@('fmc','src\Frames\fraFMCU.dfm','ImageList1',22,'window'),@('sixpack','src\Frames\fraSixPackU.dfm','ImageList1',22,'window'),@('engines','src\Frames\fraEnginesU.dfm','ImageList1',22,'window'),@('pfd737','src\Frames\fraPFD737U.dfm','ImageList1',22,'window'))
foreach($entry in $entries) {
 if($List -ne 'all' -and $List -ne $entry[0]){continue}
 & "$root\.build\RebuildToolbarImages.exe" $root $entry[4] $entry[3]
 if($LASTEXITCODE -ne 0){throw 'Icon rebuild failed'}
 $path=Join-Path $root $entry[1]
 $text=[IO.File]::ReadAllText($path)
 $generated=[IO.File]::ReadAllText((Join-Path $root ('.build\'+$entry[4]+'-images.dfm')))
 $bitmap=[regex]::Match($generated,'Bitmap = \{[\s\S]*?\}').Value
 $pattern='(?ms)^  object '+[regex]::Escape($entry[2])+': TImageList\r?\n.*?^  end'
 $match=[regex]::Match($text,$pattern)
 if(-not $match.Success -or -not $bitmap){throw 'Image list resource missing'}
 $oldHeader=[regex]::Match($match.Value,'Bitmap = \{\s*([0-9A-Fa-f]{12})').Groups[1].Value
 $newHeader=[regex]::Match($bitmap,'Bitmap = \{\s*([0-9A-Fa-f]{12})').Groups[1].Value
 $oldCount=[Convert]::ToInt32($oldHeader.Substring(10,2)+$oldHeader.Substring(8,2),16)
 $newCount=[Convert]::ToInt32($newHeader.Substring(10,2)+$newHeader.Substring(8,2),16)
 if($newCount -lt $oldCount){throw "Refusing to discard manually added icons from $($entry[1]); update the icon catalog first."}

 $block=[regex]::Replace($match.Value,'Bitmap = \{[\s\S]*?\}',[Text.RegularExpressions.MatchEvaluator]{param($m)$bitmap})
 $block=[regex]::Replace($block,'(?m)^    Masked = (True|False)\r?\n','')
 $block=$block.Replace('    ColorDepth = cd32Bit',"    ColorDepth = cd32Bit`r`n    Masked = False")
 $text=$text.Substring(0,$match.Index)+$block+$text.Substring($match.Index+$match.Length)
 [IO.File]::WriteAllText($path,$text,(New-Object Text.UTF8Encoding($true)))
}
