//
// see: http://docwiki.embarcadero.com/RADStudio/en/Compiler_Versions
//
// https://docwiki.embarcadero.com/RADStudio/Alexandria/en/Compiler_Versions

{$Undef Delphi2}
{$Undef Delphi3}
{$Undef Delphi4}
{$Undef Delphi5}
{$Undef Delphi6}
{$Undef Delphi7}
{$Undef Delphi8}
{$Undef D2005}
{$Undef D2006}
{$Undef D2007}
{$Undef D2009}
{$Undef D2010}
{$Undef D2011}
{$Undef DelphiXE}
{$Undef DelphiXE2}
{$Undef DelphiXE3}
{$Undef DelphiXE4}
{$Undef DelphiXE5}
{$Undef DelphiXE6}
{$Undef DelphiXE7}
{$Undef DelphiXE8}
{$Undef Delphi10}
{$Undef Delphi101}
{$Undef Delphi102}
{$Undef Delphi103}
{$Undef Delphi104}
{$Undef Delphi11}
{$Undef Delphi12}
{$Undef Delphi13}

// D2: VER90
// D3: VER100
// D4: VER120
// D5: VER130
// D6: VER140
// D7: VER150
// D8: VER160
// D2005: VER170
// D2006: VER180
// D2007: VER190

// D2009:
{$Ifdef VER200}
  {$Define Delphi2}
  {$Define Delphi3}
  {$Define Delphi4}
  {$Define Delphi5}
  {$Define Delphi6}
  {$Define Delphi7}
  {$Define Delphi8}
  {$Define D2005}
  {$Define D2006}
  {$Define D2007}
  {$Define D2009}
{$Endif}

// D2010:
{$Ifdef VER210}
  {$Define Delphi2}
  {$Define Delphi3}
  {$Define Delphi4}
  {$Define Delphi5}
  {$Define Delphi6}
  {$Define Delphi7}
  {$Define Delphi8}
  {$Define D2005}
  {$Define D2006}
  {$Define D2007}
  {$Define D2009}
  {$Define D2010}
{$Endif}

// D2011/XE:
{$Ifdef VER220}
  {$Define Delphi2}
  {$Define Delphi3}
  {$Define Delphi4}
  {$Define Delphi5}
  {$Define Delphi6}
  {$Define Delphi7}
  {$Define Delphi8}
  {$Define D2005}
  {$Define D2006}
  {$Define D2007}
  {$Define D2009}
  {$Define D2010}
  {$Define D2011}
  {$Define DelphiXE}
{$Endif}

// XE2:
{$Ifdef VER230}
  {$Define Delphi2}
  {$Define Delphi3}
  {$Define Delphi4}
  {$Define Delphi5}
  {$Define Delphi6}
  {$Define Delphi7}
  {$Define Delphi8}
  {$Define D2005}
  {$Define D2006}
  {$Define D2007}
  {$Define D2009}
  {$Define D2010}
  {$Define D2011}
  {$Define DelphiXE}
  {$Define DelphiXE2}
{$Endif}

// XE3:
{$Ifdef VER240}
  {$Define Delphi2}
  {$Define Delphi3}
  {$Define Delphi4}
  {$Define Delphi5}
  {$Define Delphi6}
  {$Define Delphi7}
  {$Define Delphi8}
  {$Define D2005}
  {$Define D2006}
  {$Define D2007}
  {$Define D2009}
  {$Define D2010}
  {$Define D2011}
  {$Define DelphiXE}
  {$Define DelphiXE2}
  {$Define DelphiXE3}
{$Endif}

// XE4:
{$Ifdef VER250}
  {$Define Delphi2}
  {$Define Delphi3}
  {$Define Delphi4}
  {$Define Delphi5}
  {$Define Delphi6}
  {$Define Delphi7}
  {$Define Delphi8}
  {$Define D2005}
  {$Define D2006}
  {$Define D2007}
  {$Define D2009}
  {$Define D2010}
  {$Define D2011}
  {$Define DelphiXE}
  {$Define DelphiXE2}
  {$Define DelphiXE3}
  {$Define DelphiXE4}
{$Endif}

// XE5:
{$Ifdef VER260}
  {$Define Delphi2}
  {$Define Delphi3}
  {$Define Delphi4}
  {$Define Delphi5}
  {$Define Delphi6}
  {$Define Delphi7}
  {$Define Delphi8}
  {$Define D2005}
  {$Define D2006}
  {$Define D2007}
  {$Define D2009}
  {$Define D2010}
  {$Define D2011}
  {$Define DelphiXE}
  {$Define DelphiXE2}
  {$Define DelphiXE3}
  {$Define DelphiXE4}
  {$Define DelphiXE5}
{$Endif}

// XE6:
{$Ifdef VER270}
  {$Define Delphi2}
  {$Define Delphi3}
  {$Define Delphi4}
  {$Define Delphi5}
  {$Define Delphi6}
  {$Define Delphi7}
  {$Define Delphi8}
  {$Define D2005}
  {$Define D2006}
  {$Define D2007}
  {$Define D2009}
  {$Define D2010}
  {$Define D2011}
  {$Define DelphiXE}
  {$Define DelphiXE2}
  {$Define DelphiXE3}
  {$Define DelphiXE4}
  {$Define DelphiXE5}
  {$Define DelphiXE6}
{$Endif}

// XE7:
{$Ifdef VER280}
  {$Define Delphi2}
  {$Define Delphi3}
  {$Define Delphi4}
  {$Define Delphi5}
  {$Define Delphi6}
  {$Define Delphi7}
  {$Define Delphi8}
  {$Define D2005}
  {$Define D2006}
  {$Define D2007}
  {$Define D2009}
  {$Define D2010}
  {$Define D2011}
  {$Define DelphiXE}
  {$Define DelphiXE2}
  {$Define DelphiXE3}
  {$Define DelphiXE4}
  {$Define DelphiXE5}
  {$Define DelphiXE6}
  {$Define DelphiXE7}
{$Endif}

// XE8:
{$Ifdef VER290}
  {$Define Delphi2}
  {$Define Delphi3}
  {$Define Delphi4}
  {$Define Delphi5}
  {$Define Delphi6}
  {$Define Delphi7}
  {$Define Delphi8}
  {$Define D2005}
  {$Define D2006}
  {$Define D2007}
  {$Define D2009}
  {$Define D2010}
  {$Define D2011}
  {$Define DelphiXE}
  {$Define DelphiXE2}
  {$Define DelphiXE3}
  {$Define DelphiXE4}
  {$Define DelphiXE5}
  {$Define DelphiXE6}
  {$Define DelphiXE7}
  {$Define DelphiXE8}
{$Endif}

// D10 Seattle:
{$Ifdef VER300}
  {$Define Delphi2}
  {$Define Delphi3}
  {$Define Delphi4}
  {$Define Delphi5}
  {$Define Delphi6}
  {$Define Delphi7}
  {$Define Delphi8}
  {$Define D2005}
  {$Define D2006}
  {$Define D2007}
  {$Define D2009}
  {$Define D2010}
  {$Define D2011}
  {$Define DelphiXE}
  {$Define DelphiXE2}
  {$Define DelphiXE3}
  {$Define DelphiXE4}
  {$Define DelphiXE5}
  {$Define DelphiXE6}
  {$Define DelphiXE7}
  {$Define DelphiXE8}
  {$Define Delphi10}
{$Endif}

// D10.1 Berlin:
{$Ifdef VER310}
  {$Define Delphi2}
  {$Define Delphi3}
  {$Define Delphi4}
  {$Define Delphi5}
  {$Define Delphi6}
  {$Define Delphi7}
  {$Define Delphi8}
  {$Define D2005}
  {$Define D2006}
  {$Define D2007}
  {$Define D2009}
  {$Define D2010}
  {$Define D2011}
  {$Define DelphiXE}
  {$Define DelphiXE2}
  {$Define DelphiXE3}
  {$Define DelphiXE4}
  {$Define DelphiXE5}
  {$Define DelphiXE6}
  {$Define DelphiXE7}
  {$Define DelphiXE8}
  {$Define Delphi10}
  {$Define Delphi101}
{$Endif}

// D10.2 Tokyo:
{$Ifdef VER320}
  {$Define Delphi2}
  {$Define Delphi3}
  {$Define Delphi4}
  {$Define Delphi5}
  {$Define Delphi6}
  {$Define Delphi7}
  {$Define Delphi8}
  {$Define D2005}
  {$Define D2006}
  {$Define D2007}
  {$Define D2009}
  {$Define D2010}
  {$Define D2011}
  {$Define DelphiXE}
  {$Define DelphiXE2}
  {$Define DelphiXE3}
  {$Define DelphiXE4}
  {$Define DelphiXE5}
  {$Define DelphiXE6}
  {$Define DelphiXE7}
  {$Define DelphiXE8}
  {$Define Delphi10}
  {$Define Delphi101}
  {$Define Delphi102}
{$Endif}

// D10.3 Rio:
{$Ifdef VER330}
  {$Define Delphi2}
  {$Define Delphi3}
  {$Define Delphi4}
  {$Define Delphi5}
  {$Define Delphi6}
  {$Define Delphi7}
  {$Define Delphi8}
  {$Define D2005}
  {$Define D2006}
  {$Define D2007}
  {$Define D2009}
  {$Define D2010}
  {$Define D2011}
  {$Define DelphiXE}
  {$Define DelphiXE2}
  {$Define DelphiXE3}
  {$Define DelphiXE4}
  {$Define DelphiXE5}
  {$Define DelphiXE6}
  {$Define DelphiXE7}
  {$Define DelphiXE8}
  {$Define Delphi10}
  {$Define Delphi101}
  {$Define Delphi102}
  {$Define Delphi103}
{$Endif}

// D10.4 Sydney:
{$Ifdef VER340}
  {$Define Delphi2}
  {$Define Delphi3}
  {$Define Delphi4}
  {$Define Delphi5}
  {$Define Delphi6}
  {$Define Delphi7}
  {$Define Delphi8}
  {$Define D2005}
  {$Define D2006}
  {$Define D2007}
  {$Define D2009}
  {$Define D2010}
  {$Define D2011}
  {$Define DelphiXE}
  {$Define DelphiXE2}
  {$Define DelphiXE3}
  {$Define DelphiXE4}
  {$Define DelphiXE5}
  {$Define DelphiXE6}
  {$Define DelphiXE7}
  {$Define DelphiXE8}
  {$Define Delphi10}
  {$Define Delphi101}
  {$Define Delphi102}
  {$Define Delphi103}
  {$Define Delphi104}
{$Endif}

// D11.0 Alexandria
{$Ifdef VER350}
  {$Define Delphi2}
  {$Define Delphi3}
  {$Define Delphi4}
  {$Define Delphi5}
  {$Define Delphi6}
  {$Define Delphi7}
  {$Define Delphi8}
  {$Define D2005}
  {$Define D2006}
  {$Define D2007}
  {$Define D2009}
  {$Define D2010}
  {$Define D2011}
  {$Define DelphiXE}
  {$Define DelphiXE2}
  {$Define DelphiXE3}
  {$Define DelphiXE4}
  {$Define DelphiXE5}
  {$Define DelphiXE6}
  {$Define DelphiXE7}
  {$Define DelphiXE8}
  {$Define Delphi10}
  {$Define Delphi101}
  {$Define Delphi102}
  {$Define Delphi103}
  {$Define Delphi104}
  {$Define Delphi11}
{$Endif}

// D12.0 Athens
{$Ifdef VER360}
  {$Define Delphi2}
  {$Define Delphi3}
  {$Define Delphi4}
  {$Define Delphi5}
  {$Define Delphi6}
  {$Define Delphi7}
  {$Define Delphi8}
  {$Define D2005}
  {$Define D2006}
  {$Define D2007}
  {$Define D2009}
  {$Define D2010}
  {$Define D2011}
  {$Define DelphiXE}
  {$Define DelphiXE2}
  {$Define DelphiXE3}
  {$Define DelphiXE4}
  {$Define DelphiXE5}
  {$Define DelphiXE6}
  {$Define DelphiXE7}
  {$Define DelphiXE8}
  {$Define Delphi10}
  {$Define Delphi101}
  {$Define Delphi102}
  {$Define Delphi103}
  {$Define Delphi104}
  {$Define Delphi11}
  {$Define Delphi12}
{$Endif}

// D13.0 Florence
{$Ifdef VER370}
  {$Define Delphi2}
  {$Define Delphi3}
  {$Define Delphi4}
  {$Define Delphi5}
  {$Define Delphi6}
  {$Define Delphi7}
  {$Define Delphi8}
  {$Define D2005}
  {$Define D2006}
  {$Define D2007}
  {$Define D2009}
  {$Define D2010}
  {$Define D2011}
  {$Define DelphiXE}
  {$Define DelphiXE2}
  {$Define DelphiXE3}
  {$Define DelphiXE4}
  {$Define DelphiXE5}
  {$Define DelphiXE6}
  {$Define DelphiXE7}
  {$Define DelphiXE8}
  {$Define Delphi10}
  {$Define Delphi101}
  {$Define Delphi102}
  {$Define Delphi103}
  {$Define Delphi104}
  {$Define Delphi11}
  {$Define Delphi12}
  {$Define Delphi13}
{$Endif}