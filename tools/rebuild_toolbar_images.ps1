param([ValidateSet('all','main','small','simbrief','charts','map','graph')][string]$List='all',[string]$DelphiRoot='C:\Program Files (x86)\Embarcadero\Studio\19.0')
$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot
New-Item -ItemType Directory -Path "$root\.build" -Force | Out-Null
& "$DelphiRoot\bin\dcc64.exe" -B -Q '-NSSystem;Winapi;Vcl' "-U$DelphiRoot\lib\win64\release" "-E$root\.build" "-N0$root\.build" "$PSScriptRoot\RebuildToolbarImages.dpr"
if($LASTEXITCODE -ne 0){throw 'Icon helper build failed'}
$entries=@(@('main','src\Forms\frmMainU.dfm','ImageList',22,'main'),@('small','src\Forms\frmMainU.dfm','ImageListSmall',16,'main'),@('simbrief','src\Frames\frmSimBriefFrameU.dfm','ImageList',22,'simbrief'),@('charts','src\Forms\frmChartsConfigureU.dfm','ImageList',22,'charts'),@('map','src\Frames\fraMapU.dfm','ImageList',22,'main'),@('graph','src\Frames\fraGraphU.dfm','ImageList',22,'main'))
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
 $block=[regex]::Replace($match.Value,'Bitmap = \{[\s\S]*?\}',[Text.RegularExpressions.MatchEvaluator]{param($m)$bitmap})
 $block=[regex]::Replace($block,'(?m)^    Masked = (True|False)\r?\n','')
 $block=$block.Replace('    ColorDepth = cd32Bit',"    ColorDepth = cd32Bit`r`n    Masked = False")
 $text=$text.Substring(0,$match.Index)+$block+$text.Substring($match.Index+$match.Length)
 [IO.File]::WriteAllText($path,$text,(New-Object Text.UTF8Encoding($true)))
}
