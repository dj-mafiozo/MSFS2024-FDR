Program CheckDFM;
{$APPTYPE CONSOLE}

Uses
 System.SysUtils, System.Classes;

Var
 s : TFileStream;
 d : TMemoryStream;

Begin
 s := TFileStream.Create(ParamStr(1), fmOpenRead Or fmShareDenyNone);
 d := TMemoryStream.Create;
 Try
  ObjectTextToBinary(s, d);
  Writeln('DFM OK');
 Finally
  d.Free;
  s.Free;
 End;

End.
