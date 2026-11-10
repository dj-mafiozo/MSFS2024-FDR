Program VerifyHelpContexts;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, System.SysUtils, System.Types, System.Classes, System.IOUtils,
 System.RegularExpressions, System.JSON, System.Hash, DUnitX.TestFramework, NativeTestRunnerU;

Type

 [TestFixture]
 THelpContextsTests = Class
  Public
   [Test] Procedure DFMAndLocalizedManual;
 End;
{ FLD+ }

Const
 Languages : Array[0..3] Of String =
  (
   'pl',
   'en',
   'de',
   'es'
  );
{ FLD- }

Function ReadHelpText(Const Path, Lang : String) : String;
 Var
  Encoding : TEncoding;
 Begin
  If Lang = 'pl' Then
   Encoding := TEncoding.GetEncoding(1250)
  Else
   Encoding := TEncoding.GetEncoding(1252);
  Try
   Result := TFile.ReadAllText(Path, Encoding);
  Finally
   Encoding.Free;
  End;
 End;

Procedure THelpContextsTests.DFMAndLocalizedManual;
 Var
  Lang        : String;
  Header      : String;
  Path        : String;
  Text        : String;
  Title       : String;
  Base        : String;
  Match       : TMatch;
  Image       : TMatch;
  Proof       : TJSONObject;
  RecordProof : TJSONObject;
  Count       : Integer;
 Begin
  Proof := TJSONObject.ParseJSONValue(TFile.ReadAllText(TestRepositoryPath('bin\help\build.json'), TEncoding.UTF8)) As TJSONObject;
  Try
   For Lang In Languages Do
    Begin
     Base   := TestRepositoryPath('help\' + Lang + '\');
     Header := TFile.ReadAllText(Base + 'contexts.h');
     For Path In TDirectory.GetFiles(TestRepositoryPath('src'), '*.dfm', TSearchOption.soAllDirectories) Do
      Begin
       If (Pos('__history', Path) > 0) Or (Pos('__recovery', Path) > 0) Then
        Continue;
       Text := TFile.ReadAllText(Path, TEncoding.UTF8);
       Assert.IsTrue(TRegEx.IsMatch(Text, '(?s)^(?:object|inherited)[^\r\n]*[\r\n]+\s+HelpContext\s*=\s*\d+'), Path + ' root context');
       For Match In TRegEx.Matches(Text, '\bHelpContext\s*=\s*(\d+)') Do
        Assert.IsTrue(TRegEx.IsMatch(Header, '(?m)^#define\s+\w+\s+' + Match.Groups[1].Value + '\s*$'), Path + ' mapped context ' + Match.Groups[1].Value);
      End;
     Text := ReadHelpText(Base + 'contents.hhc', Lang);
     Assert.IsFalse(Text.Contains('&#'), 'TOC names use native Windows codepage, not numeric references');
     If Lang = 'pl' Then
      Assert.IsTrue(Text.Contains('GSX Pro: usługi i postęp'), 'Polish TOC glyphs');
     Assert.IsTrue(TRegEx.Matches(Text, '<ul>').Count > 5, 'Hierarchical help tree');
     Count := 0;
     For Path In TDirectory.GetFiles(Base, '*.htm') Do
      Begin
       Inc(Count);
       Text := ReadHelpText(Path, Lang);
       Assert.IsFalse(Text.ToLower.Contains('<nav'), 'No global all-topic navigation');
       Assert.IsTrue(Text.Contains('lang="' + Lang + '"'));
       For Image In TRegEx.Matches(Text, '<img[^>]+src="images/([^"]+)"') Do
        Begin
         Assert.IsTrue(Image.Groups[1].Value.StartsWith(Lang + '-'), 'Screenshot language matches manual');
         Assert.IsTrue(FileExists(TestRepositoryPath('help\images\' + Image.Groups[1].Value)));
        End;
      End;
     Assert.AreEqual(62, Count);
     Assert.IsTrue(FileExists(Base + 'ecam-sts.htm'));
     Assert.IsTrue(FileExists(Base + 'simvars.htm'));
     Text := ReadHelpText(Base + 'simvars.htm', Lang);
     Assert.IsTrue(Text.Contains('eng_oil_pressure #4'), 'All four engine catalogs');
     Assert.IsTrue(Text.Contains('398 SimVars'), 'Complete standard catalog');
     RecordProof := Proof.GetValue(Lang) As TJSONObject;
     Assert.AreEqual(THashSHA2.GetHashStringFromFile(TestRepositoryPath('bin\help\MSFS2024-FDR.' + Lang + '.chm')), RecordProof.GetValue('chm_sha256').Value);
     Assert.IsTrue(StrToInt(RecordProof.GetValue('images').Value) >= 57);
    End;
  Finally
   Proof.Free;
  End;
 End;

Begin
 RunNativeTests(THelpContextsTests);
End.
