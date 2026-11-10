Program VerifyBridgeSignature;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU, FDRSetupProductU, Winapi.Windows, System.SysUtils, System.Classes, System.IOUtils, System.JSON, System.Zip, System.Hash, SecureZipU, SetupSignatureU;

Type
 TPSS = Record
  Algorithm : PWideChar;
  Salt      : Cardinal;
 End;

Function BCryptOpenAlgorithmProvider(Out h : Pointer; a, p : PWideChar; f : Cardinal) : LongInt; Stdcall; External 'bcrypt.dll';

Function BCryptGenerateKeyPair(h : Pointer; Out k : Pointer; Bits, f : Cardinal) : LongInt; Stdcall; External 'bcrypt.dll';

Function BCryptFinalizeKeyPair(k : Pointer; f : Cardinal) : LongInt; Stdcall; External 'bcrypt.dll';

Function BCryptExportKey(k, e : Pointer; t : PWideChar; b : Pointer; s : Cardinal; Out n : Cardinal; f : Cardinal) : LongInt; Stdcall; External 'bcrypt.dll';

Function BCryptSignHash(k, p, h : Pointer; HS : Cardinal; s : Pointer; SS : Cardinal; Out n : Cardinal; f : Cardinal) : LongInt; Stdcall; External 'bcrypt.dll';

Function BCryptDestroyKey(k : Pointer) : LongInt; Stdcall; External 'bcrypt.dll';

Function BCryptCloseAlgorithmProvider(h : Pointer; f : Cardinal) : LongInt; Stdcall; External 'bcrypt.dll';

Procedure Check(b : Boolean; Const s : String);
 Begin
  If Not b Then
   Raise Exception.Create(s);
 End;

Var
 h        : Pointer;
 k        : Pointer;
 n        : Cardinal;
 Pub      : TBytes;
 p        : TPSS;
 Root     : String;
 Inner    : String;
 Outer    : String;
 Plain    : String;
 Dest     : String;
 Name     : String;
 z        : TZipFile;
 Files    : TStringList;
 b        : TBytes;
 Rejected : Boolean;

Procedure SignFile(Const FileName : String);
 Var
  Hash : TBytes;
  Sig  : TBytes;
 Begin
  Hash := THashSHA2.GetHashBytesFromFile(FileName);
  SetLength(Sig, 384);
  Check(BCryptSignHash(k, @p, @Hash[0], Length(Hash), @Sig[0], Length(Sig), n, 8) = 0, 'Sign');
  TFile.WriteAllBytes(FileName + '.sig', Sig);
 End;

Procedure SignArchive(Const Archive, Product, Platform : String);
 Var
  o : TJSONObject;
  s : TFileStream;
 Begin
  o := TJSONObject.Create;
  s := TFileStream.Create(Archive, fmOpenRead);
  Try
   o.AddPair('product', Product);
   o.AddPair('platform', Platform);
   o.AddPair('version', '0.1.1.99');
   o.AddPair('package', ExtractFileName(Archive));
   o.AddPair('size', TJSONNumber.Create(s.Size));
   o.AddPair('sha256', THashSHA2.GetHashString(s));
   TFile.WriteAllText(Archive + '.manifest.json', o.ToJSON, TEncoding.UTF8);
  Finally
   s.Free;
   o.Free;
  End;
  SignFile(Archive);
  SignFile(Archive + '.manifest.json');
 End;

Type

 [TestFixture]
 TVerifyBridgeSignatureTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyBridgeSignatureTests.Regression;
 Begin
  h     := Nil;
  k     := Nil;
  Files := TStringList.Create;
  Try
   Check(BCryptOpenAlgorithmProvider(h, 'RSA', Nil, 0) = 0, 'RSA');
   Check(BCryptGenerateKeyPair(h, k, 3072, 0) = 0, 'Key');
   Check(BCryptFinalizeKeyPair(k, 0) = 0, 'Finalize');
   Check(BCryptExportKey(k, Nil, 'RSAPUBLICBLOB', Nil, 0, n, 0) = 0, 'Public size');
   SetLength(Pub, n);
   Check(BCryptExportKey(k, Nil, 'RSAPUBLICBLOB', @Pub[0], n, n, 0) = 0, 'Public');
   p.Algorithm := 'SHA256';
   p.Salt      := 32;
   Root        := TestDataDirectory;
   Inner       := TPath.Combine(Root, 'MSFS24-FDR-Bridge-0.1.1.99.zip');
   Outer       := TPath.Combine(Root, 'MSFS2024-FDR-Win64-0.1.1.99.zip');
   Plain       := TPath.Combine(Root, 'plain.zip');
   z           := TZipFile.Create;
   Try
    z.Open(Plain, zmWrite);
    z.Add(TEncoding.UTF8.GetBytes('bridge fixture'), 'MSFS24-FDR-Bridge/panel.js');
   Finally
    z.Free;
   End;
   EncryptRelease(Plain, Inner, 'fixture-password');
   SignArchive(Inner, 'MSFS24-FDR-Bridge', 'Community');
   Check(VerifySignedFixture(Inner, True, Pub) = '0.1.1.99', 'Bridge signatures');
   z := TZipFile.Create;
   Try
    z.Open(Plain, zmWrite);
    For Name In TArray<String>.Create('', '.sig', '.manifest.json', '.manifest.json.sig') Do
     z.Add(Inner + Name, 'MSFS2024-FDR/MSFS24-FDR-Bridge.zip' + Name);
   Finally
    z.Free;
   End;
   EncryptRelease(Plain, Outer, 'fixture-password');
   SignArchive(Outer, 'MSFS2024-FDR', 'Win64');
   Check(VerifySignedFixture(Outer, False, Pub) = '0.1.1.99', 'Main signatures');
   Rejected := False;
   Try
    VerifySignedFixture(Outer, True, Pub);
   Except
    Rejected := True;
   End;
   Check(Rejected, 'Wrong product rejected');
   Dest := TPath.Combine(Root, 'outer');
   ExtractRelease(Outer, Dest, 'fixture-password', Files, Nil);
   Inner := TPath.Combine(Dest, 'MSFS24-FDR-Bridge.zip');
   Check(VerifySignedFixture(Inner, True, Pub) = '0.1.1.99', 'Nested signed manifest');
   ExtractRelease(Inner, TPath.Combine(Root, 'inner'), 'fixture-password', Files, Nil);
   Check(TFile.ReadAllText(TPath.Combine(Root, 'inner\MSFS24-FDR-Bridge\panel.js')) = 'bridge fixture', 'Both layers decrypt');
   Rejected := False;
   Try
    ExtractRelease(Inner, TPath.Combine(Root, 'wrong'), 'wrong-password', Files, Nil);
   Except
    Rejected := True;
   End;
   Check(Rejected, 'Inner password enforced');
   b     := TFile.ReadAllBytes(Inner);
   b[40] := b[40] Xor 1;
   TFile.WriteAllBytes(Inner, b);
   Rejected := False;
   Try
    VerifySignedFixture(Inner, True, Pub);
   Except
    Rejected := True;
   End;
   Check(Rejected, 'Tampered inner ZIP rejected');
  Finally
   Files.Free;
   If k <> Nil Then
    BCryptDestroyKey(k);
   If h <> Nil Then
    BCryptCloseAlgorithmProvider(h, 0);
  End;
  System.Writeln('PASS: nested encrypted ZIPs, independent RSA-3072/PSS ZIP+manifest signatures, product binding, inner password and tamper rejection. Ephemeral in-memory test key only.');

 End;

Begin
 RunNativeTests(TVerifyBridgeSignatureTests);
End.
