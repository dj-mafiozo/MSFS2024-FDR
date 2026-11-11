Program VerifySetupSignature;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU In 'TestPathsU.pas', DUnitX.TestFramework, NativeTestRunnerU In 'NativeTestRunnerU.pas', FDRSetupProductU In '..\..\MSFS2024-FDR-Setup\src\FDRSetupProductU.pas', System.SysUtils, System.Classes, System.IOUtils, SetupSignatureU In '..\..\setup-common\src\SetupSignatureU.pas', SetupPlatformU In '..\..\MSFS2024-FDR-Setup\src\SetupPlatformU.pas';

Function BCryptOpenAlgorithmProvider(Out h : Pointer; a, p : PWideChar; f : Cardinal) : LongInt; Stdcall; External 'bcrypt.dll';

Function BCryptGenerateKeyPair(h : Pointer; Out k : Pointer; Bits, f : Cardinal) : LongInt; Stdcall; External 'bcrypt.dll';

Function BCryptFinalizeKeyPair(k : Pointer; f : Cardinal) : LongInt; Stdcall; External 'bcrypt.dll';

Function BCryptExportKey(k, e : Pointer; t : PWideChar; b : Pointer; Size : Cardinal; Out n : Cardinal; f : Cardinal) : LongInt; Stdcall; External 'bcrypt.dll';

Function BCryptSignHash(k, p, h : Pointer; HS : Cardinal; s : Pointer; SS : Cardinal; Out n : Cardinal; f : Cardinal) : LongInt; Stdcall; External 'bcrypt.dll';

Function BCryptDestroyKey(k : Pointer) : LongInt; Stdcall; External 'bcrypt.dll';

Function BCryptCloseAlgorithmProvider(h : Pointer; f : Cardinal) : LongInt; Stdcall; External 'bcrypt.dll';

Type
 TPSS = Record
  Algorithm : PWideChar;
  Salt      : Cardinal;
 End;

Procedure Check(b : Boolean; Const Msg : String);
 Begin
  If Not b Then
   Raise Exception.Create(Msg);
 End;

Var
 h        : Pointer;
 k        : Pointer;
 Pub      : TBytes;
 Hash     : TBytes;
 Sig      : TBytes;
 Other    : TBytes;
 n        : Cardinal;
 p        : TPSS;
 Rejected : Boolean;

Type

 [TestFixture]
 TVerifySetupSignatureTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifySetupSignatureTests.Regression;
 Begin
  Try
   h := Nil;
   k := Nil;
   Check(BCryptOpenAlgorithmProvider(h, 'RSA', Nil, 0) = 0, 'Open RSA');
   Try
    Check(BCryptGenerateKeyPair(h, k, 3072, 0) = 0, 'Generate ephemeral test RSA');
    Check(BCryptFinalizeKeyPair(k, 0) = 0, 'Finalize RSA');
    Check(BCryptExportKey(k, Nil, 'RSAPUBLICBLOB', Nil, 0, n, 0) = 0, 'Public size');
    SetLength(Pub, n);
    Check(BCryptExportKey(k, Nil, 'RSAPUBLICBLOB', @Pub[0], n, n, 0) = 0, 'Public export');
    SetLength(Hash, 32);
    FillChar(Hash[0], 32, 17);
    SetLength(Sig, 384);
    p.Algorithm := 'SHA256';
    p.Salt      := 32;
    Check(BCryptSignHash(k, @p, @Hash[0], 32, @Sig[0], 384, n, 8) = 0, 'Sign RSA-PSS');
    VerifyPSS(Pub, Hash, Sig);
    Sig[0]   := Sig[0] Xor 1;
    Rejected := False;
    Try
     VerifyPSS(Pub, Hash, Sig);
    Except
     Rejected := True;
    End;
    Check(Rejected, 'Changed signature rejected');
    Sig[0]   := Sig[0] Xor 1;
    Hash[0]  := Hash[0] Xor 1;
    Rejected := False;
    Try
     VerifyPSS(Pub, Hash, Sig);
    Except
     Rejected := True;
    End;
    Check(Rejected, 'Changed payload hash rejected');
    Hash[0] := Hash[0] Xor 1;
    p.Salt  := 20;
    Check(BCryptSignHash(k, @p, @Hash[0], 32, @Sig[0], 384, n, 8) = 0, 'Alternate salt fixture');
    Rejected := False;
    Try
     VerifyPSS(Pub, Hash, Sig);
    Except
     Rejected := True;
    End;
    Check(Rejected, 'Non-32-byte PSS salt rejected');
    SetLength(Other, 0);
    Rejected := False;
    Try
     VerifyPSS(Other, Hash, Sig);
    Except
     Rejected := True;
    End;
    Check(Rejected, 'Missing public key rejected');
   Finally
    If k <> Nil Then
     BCryptDestroyKey(k);
    If h <> Nil Then
     BCryptCloseAlgorithmProvider(h, 0);
   End;
   RememberAcceptedVersion('0.1.1.16');
   Check(HighestAcceptedVersion = '0.1.1.16', 'Accepted version persisted');
   Rejected := False;
   Try
    RememberAcceptedVersion('0.1.0.65535');
   Except
    Rejected := True;
   End;
   Check(Rejected, 'Rollback floor cannot decrease');
   RememberAcceptedVersion('0.1.1.17');
   Check(HighestAcceptedVersion = '0.1.1.17', 'Higher version accepted');
   System.Writeln('PASS: native RSA-3072/PSS SHA-256 salt32 verification, tampered signature/hash and wrong salt rejection, persistent rollback floor.');
  Except
   On e : Exception Do
    Begin
     System.Writeln(e.ClassName + ': ' + e.Message);
     Raise Exception.Create('Regression failed; see diagnostic above');
    End;
  End;

 End;

Begin
 RunNativeTests(TVerifySetupSignatureTests);
End.
