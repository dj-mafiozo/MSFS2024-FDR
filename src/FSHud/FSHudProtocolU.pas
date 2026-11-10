{$StackFrames On}
Unit FSHudProtocolU;

Interface

 Uses
  LocalizationU, System.SysUtils;

 Function FSHudEncode(Const JSON, Key : String) : String;
 Function FSHudDecode(Const Frame, Key : String) : String;

Implementation

 Uses
  Winapi.Windows, System.NetEncoding;

 Type
  TBCHandle = Pointer;

 Function BCryptOpenAlgorithmProvider(Out h : TBCHandle; Algorithm, Provider : PWideChar; Flags : ULONG) : LongInt; Stdcall; External 'bcrypt.dll';

 Function BCryptSetProperty(h : TBCHandle; Name : PWideChar; Data : Pointer; Size, Flags : ULONG) : LongInt; Stdcall; External 'bcrypt.dll';

 Function BCryptGetProperty(h : TBCHandle; Name : PWideChar; Data : Pointer; Size : ULONG; Out Used : ULONG; Flags : ULONG) : LongInt; Stdcall; External 'bcrypt.dll';

 Function BCryptGenerateSymmetricKey(h : TBCHandle; Out k : TBCHandle; Obj : Pointer; ObjSize : ULONG; Secret : Pointer; SecretSize, Flags : ULONG) : LongInt; Stdcall; External 'bcrypt.dll';

 Function BCryptEncrypt(k : TBCHandle; Input : Pointer; InputSize : ULONG; Padding, IV : Pointer; IVSize : ULONG; Output : Pointer; OutputSize : ULONG; Out Used : ULONG; Flags : ULONG) : LongInt; Stdcall; External 'bcrypt.dll';

 Function BCryptDecrypt(k : TBCHandle; Input : Pointer; InputSize : ULONG; Padding, IV : Pointer; IVSize : ULONG; Output : Pointer; OutputSize : ULONG; Out Used : ULONG; Flags : ULONG) : LongInt; Stdcall; External 'bcrypt.dll';

 Function BCryptDestroyKey(k : TBCHandle) : LongInt; Stdcall; External 'bcrypt.dll';

 Function BCryptCloseAlgorithmProvider(h : TBCHandle; Flags : ULONG) : LongInt; Stdcall; External 'bcrypt.dll';

 Procedure Check(Status : LongInt);
  Begin
   If Status < 0 Then
    Raise Exception.Create(Tr('FSHud frame codec: ') + IntToHex(Status, 8));
  End;

 Function Transform(Const Input : TBytes; Const Key : String; Encrypt : Boolean) : TBytes;
  Var
   h      : TBCHandle;
   k      : TBCHandle;
   Secret : TBytes;
   IV     : TBytes;
   Obj    : TBytes;
   Mode   : UnicodeString;
   Size   : ULONG;
   Used   : ULONG;
  Begin
   h      := Nil;
   k      := Nil;
   Secret := TEncoding.UTF8.GetBytes(Key);
   If Length(Secret) <> 16 Then
    Raise Exception.Create(Tr('Unsupported FSHud panel protocol key size'));
   If Length(Input) = 0 Then
    Raise Exception.Create(Tr('Empty FSHud frame'));
   Try
    Check(BCryptOpenAlgorithmProvider(h, 'AES', Nil, 0));
    Mode := 'ChainingModeCBC';
    Check(BCryptSetProperty(h, 'ChainingMode', PWideChar(Mode), (Length(Mode) + 1) * 2, 0));
    Check(BCryptGetProperty(h, 'ObjectLength', @Size, SizeOf(Size), Used, 0));
    SetLength(Obj, Size);
    Check(BCryptGenerateSymmetricKey(h, k, @Obj[0], Length(Obj), @Secret[0], Length(Secret), 0));
    IV := Copy(Secret);
    SetLength(Result, Length(Input) + 32);
    If Encrypt Then
     Check(BCryptEncrypt(k, @Input[0], Length(Input), Nil, @IV[0], Length(IV), @Result[0], Length(Result), Used, 1))
    Else
     Check(BCryptDecrypt(k, @Input[0], Length(Input), Nil, @IV[0], Length(IV), @Result[0], Length(Result), Used, 1));
    SetLength(Result, Used);
   Finally
    If k <> Nil Then
     BCryptDestroyKey(k);
    If h <> Nil Then
     BCryptCloseAlgorithmProvider(h, 0);
   End;
  End;

 Function FSHudEncode(Const JSON, Key : String) : String;
  Begin
   Result := TNetEncoding.Base64.EncodeBytesToString(Transform(TEncoding.UTF8.GetBytes(JSON), Key, True));
  End;

 Function FSHudDecode(Const Frame, Key : String) : String;
  Begin
   Result := TEncoding.UTF8.GetString(Transform(TNetEncoding.Base64.DecodeStringToBytes(Frame), Key, False));
  End;

End.
