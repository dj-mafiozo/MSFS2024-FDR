param([string]$DelphiRoot='C:\Program Files (x86)\Embarcadero\Studio\19.0',[string[]]$Tests=@(),[string]$I18nRoot='')
$ErrorActionPreference='Stop'
python "$PSScriptRoot\tools\check_fonts.py"
if($LASTEXITCODE -ne 0){throw 'Bundled fonts or licenses are incomplete'}
python "$PSScriptRoot\tools\check_version.py"
if($LASTEXITCODE -ne 0){throw 'VersionInfo configuration is inconsistent'}
python "$PSScriptRoot\tools\check_documentation.py"
if($LASTEXITCODE -ne 0){throw 'Documentation translations are incomplete'}
python "$PSScriptRoot\tools\check_translations.py"
if($LASTEXITCODE -ne 0){throw 'Translations are incomplete or stale'}
python "$PSScriptRoot\tools\check_project.py"
if($LASTEXITCODE -ne 0){throw 'Delphi project source list is incomplete'}
python "$PSScriptRoot\tools\check_airliner_catalog.py"
if($LASTEXITCODE -ne 0){throw 'AIRLINER catalog metadata mismatch'}
$i18n=$I18nRoot
if([string]::IsNullOrWhiteSpace($i18n)){$i18n=Join-Path (Split-Path $PSScriptRoot) 'i18n\Packages';if(-not(Test-Path -LiteralPath $i18n)){$i18n=Join-Path $PSScriptRoot 'vendor\i18n\Packages'}}
if(-not (Test-Path -LiteralPath $i18n)){throw 'Missing i18n package; install it beside the repository.'}
$sourcePaths=@("$PSScriptRoot\src")+@(Get-ChildItem "$PSScriptRoot\src" -Directory -Recurse | Where-Object {$_.FullName -notmatch '[\\/]__(history|recovery)([\\/]|$)'} | ForEach-Object FullName)
$unitPaths=($sourcePaths -join ';')+';'+$i18n
$vendor=Join-Path (Split-Path $PSScriptRoot) 'FSHudPanel\vendor\WebView4Delphi-main'
if(-not (Test-Path $vendor)){$vendor=Join-Path $PSScriptRoot 'vendor\WebView4Delphi-main'}
$analysisTempBefore=$env:TEMP;$analysisTmpBefore=$env:TMP
New-Item -ItemType Directory -Path "$PSScriptRoot\.build\test-temp","$PSScriptRoot\.build\Win32\Tests","$PSScriptRoot\.build\Win64\Tests" -Force | Out-Null
$env:TEMP="$PSScriptRoot\.build\test-temp";$env:TMP=$env:TEMP
Copy-Item "$PSScriptRoot\bin\sqlite3.dll" "$PSScriptRoot\tests\sqlite3.dll" -Force
Copy-Item "$PSScriptRoot\bin\SimConnect.dll" "$PSScriptRoot\tests\SimConnect.dll" -Force
Copy-Item "$vendor\bin64\WebView2Loader.dll" "$PSScriptRoot\tests\WebView2Loader.dll" -Force
& python "$PSScriptRoot\tools\build_help.py"
if($LASTEXITCODE -ne 0){throw 'Help build failed'}
if(Test-Path "$PSScriptRoot\bin\help"){New-Item -ItemType Directory -Path "$PSScriptRoot\tests\help" -Force | Out-Null;Copy-Item -Path "$PSScriptRoot\bin\help\*" -Destination "$PSScriptRoot\tests\help" -Recurse -Force}
if(($Tests.Count -eq 0) -or ($Tests -contains 'VerifyVersionLanguage') -or ($Tests -contains 'VerifyLocaleExpansion')) {
 $env:BDS=$DelphiRoot;$env:BDSINCLUDE=Join-Path $DelphiRoot 'include'
 & "$env:WINDIR\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe" "$PSScriptRoot\src\MSFS2024-FDR.dproj" /t:Build /p:Config=Debug /p:Platform=Win64 "/p:I18nRoot=$i18n" /v:minimal /nologo
 if($LASTEXITCODE -ne 0){throw 'VersionInfo test application build failed'}
}
Push-Location "$PSScriptRoot\tests"
try {
  & "$DelphiRoot\bin\dcc32.exe" -B -Q '-NSSystem;System.Win;Winapi;Vcl;Data;Xml;Xml.Win' "-U$DelphiRoot\lib\win32\release;$unitPaths" "-E$PSScriptRoot\tests" "-N0$PSScriptRoot\.build\Win32\Tests" 'MockFlightPad32.dpr'
  if($LASTEXITCODE -ne 0){throw 'Compile failed: MockFlightPad32'}
  foreach($mock in @('MockFenixSim','MockPMDGSim')) {
    & "$DelphiRoot\bin\dcc64.exe" -B -Q '-NSSystem;System.Win;Winapi;Vcl;Data;Xml;Xml.Win' "-U$DelphiRoot\lib\win64\release;$unitPaths" "-E$PSScriptRoot\tests" "-N0$PSScriptRoot\.build\Win64\Tests" "$mock.dpr"
    if($LASTEXITCODE -ne 0){throw "Compile failed: $mock"}
  }
  if($Tests.Count -eq 0){$Tests=@('VerifyPort','VerifyLegacy','VerifyUI','VerifyDiagnostics','VerifyFlightPlan','VerifyAnalysis','VerifyContext','VerifyReport','VerifyMetar','VerifyChartView','VerifyAircraftSDK','VerifyFenix','VerifyFBW','VerifyPMDG','VerifyFMC','VerifyFlightPad','VerifyAirbusMCDU','VerifyOllama','VerifyOllamaModels','VerifyTripInfo','VerifyPrecision','VerifyAirliner','VerifyGroundWeather','VerifySimBrief','VerifySimBriefUI','VerifyGSX','VerifySession','VerifyFSHud','VerifyRecorderWorker','VerifySimBacklog','VerifyBoeingFMC','VerifyIFlyDisplays','VerifyLocalization','VerifyChartsConfigure','VerifyDetachedViews','VerifyGroups','VerifyHelpAbout','VerifyParameterNames','VerifyDisplayUnits','VerifyChartDrag','VerifyVersionLanguage','VerifyLocaleExpansion','VerifyGlobalLocales','VerifyRTLReturn')}
  foreach($test in $Tests) {
    & "$DelphiRoot\bin\dcc64.exe" -B -Q -DPORT_TEST '-NSSystem;System.Win;Winapi;Vcl;Data;Xml;Xml.Win' "-U$DelphiRoot\lib\win64\release;$unitPaths;$vendor\source" "-I$vendor\source;$i18n" "-E$PSScriptRoot\tests" "-N0$PSScriptRoot\.build\Win64\Tests" "$test.dpr"
    if($LASTEXITCODE -ne 0){throw "Compile failed: $test"}
    $testPreference=$ErrorActionPreference
    try {$ErrorActionPreference='Continue'; & (Join-Path "$PSScriptRoot\tests" "$test.exe");$testExit=$LASTEXITCODE}
    finally {$ErrorActionPreference=$testPreference}
    if($testExit -ne 0){throw "Test failed: $test"}
  }
}finally{Pop-Location;$env:TEMP=$analysisTempBefore;$env:TMP=$analysisTmpBefore}
