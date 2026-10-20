Unit FDRTypesU;

Interface

 Uses
  Winapi.Windows, System.SysUtils;

 Type
  TReading = Record
   Public
    Name      : String;
    Source    : String;
    Kind      : String;
    Units     : String;
    RawHex    : String;
    ValueText : String;
  End;

  TReadings = Array Of TReading;

  TCaptureTime = Record
   Public
    UTCUS : Int64;
    QPC   : Int64;
  End;

 Function CaptureTime : TCaptureTime;
 Function HexBytes(P : Pointer; Size : Integer) : String;
 Function MakeReading(Const Name, Source, Kind, Units : String; P : Pointer; Size : Integer) : TReading;

Implementation

 Procedure PreciseFileTime(Out FT : TFileTime); Stdcall; External 'kernel32.dll' Name 'GetSystemTimePreciseAsFileTime';

 Function CaptureTime : TCaptureTime;
  Var
   FT    : TFileTime;
   Ticks : UInt64;
  Begin
   PreciseFileTime(FT);
   QueryPerformanceCounter(Result.QPC);
   Ticks        := (UInt64(FT.dwHighDateTime) Shl 32) Or FT.dwLowDateTime;
   Result.UTCUS := Int64(Ticks Div 10) - 11644473600000000;
  End;

 Function HexBytes(P : Pointer; Size : Integer) : String;
  Const
   Digits : String = '0123456789ABCDEF';
  Var
   I : Integer;
   B : Byte;
  Begin
   SetLength(Result, Size * 2);
   For I := 0 To Size - 1 Do
    Begin
     B                 := PByte(NativeUInt(P) + NativeUInt(I))^;
     Result[I * 2 + 1] := Digits[B Shr 4 + 1];
     Result[I * 2 + 2] := Digits[(B And 15) + 1];
    End;
  End;

 Function MakeReading(Const Name, Source, Kind, Units : String; P : Pointer; Size : Integer) : TReading;
  Var
   D  : Double;
   N  : Integer;
   A  : AnsiString;
   FS : TFormatSettings;
  Begin
   Result.Name   := Name;
   Result.Source := Source;
   Result.Kind   := Kind;
   Result.Units  := Units;
   Result.RawHex := HexBytes(P, Size);
   If Kind = 'float64' Then
    Begin
     Move(P^, D, 8);
     FS                  := TFormatSettings.Create;
     FS.DecimalSeparator := '.';
     Result.ValueText    := FloatToStrF(D, ffGeneral, 17, 0, FS);
    End
   Else If Kind = 'int32' Then
    Begin
     Move(P^, N, 4);
     Result.ValueText := IntToStr(N);
    End
   Else If Kind = 'char' Then
    Begin
     SetString(A, PAnsiChar(P), Size);
     Result.ValueText := String(A);
    End
   Else
    Result.ValueText := IntToStr(PByte(P)^);
  End;

End.
