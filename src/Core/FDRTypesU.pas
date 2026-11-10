{$StackFrames On}
Unit FDRTypesU;

Interface

 Uses
  Winapi.Windows, System.SysUtils;

 Type
  TReading = Record
   Name      : String;
   Source    : String;
   Kind      : String;
   Units     : String;
   RawHex    : String;
   ValueText : String;
  End;

  TReadings = Array Of TReading;

  TCaptureTime = Record
   UTCUS : Int64;
   QPC   : Int64;
  End;

 Function CaptureTime : TCaptureTime;
 Function HexBytes(p : Pointer; Size : Integer) : String;
 Function MakeReading(Const Name, Source, Kind, Units : String; p : Pointer; Size : Integer) : TReading;

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

 Function HexBytes(p : Pointer; Size : Integer) : String;
  Const
   Digits : String = '0123456789ABCDEF';
  Var
   i : Integer;
   b : Byte;
  Begin
   SetLength(Result, Size * 2);
   For i := 0 To Size - 1 Do
    Begin
     b                 := PByte(NativeUInt(p) + NativeUInt(i))^;
     Result[i * 2 + 1] := Digits[b Shr 4 + 1];
     Result[i * 2 + 2] := Digits[(b And 15) + 1];
    End;
  End;

 Function MakeReading(Const Name, Source, Kind, Units : String; p : Pointer; Size : Integer) : TReading;
  Var
   d  : Double;
   n  : Integer;
   a  : AnsiString;
   FS : TFormatSettings;
  Begin
   Result.Name   := Name;
   Result.Source := Source;
   Result.Kind   := Kind;
   Result.Units  := Units;
   Result.RawHex := HexBytes(p, Size);
   If Kind = 'float64' Then
    Begin
     Move(p^, d, 8);
     FS                  := TFormatSettings.Create;
     FS.DecimalSeparator := '.';
     Result.ValueText    := FloatToStrF(d, ffGeneral, 17, 0, FS);
    End
   Else If Kind = 'int32' Then
    Begin
     Move(p^, n, 4);
     Result.ValueText := IntToStr(n);
    End
   Else If Kind = 'char' Then
    Begin
     SetString(a, PAnsiChar(p), Size);
     Result.ValueText := String(a);
    End
   Else
    Result.ValueText := IntToStr(PByte(p)^);
  End;

End.
