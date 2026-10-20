program CheckDFM;
{$APPTYPE CONSOLE}
uses System.SysUtils,System.Classes;
var S:TFileStream;D:TMemoryStream;
begin S:=TFileStream.Create(ParamStr(1),fmOpenRead or fmShareDenyNone);D:=TMemoryStream.Create;
try ObjectTextToBinary(S,D);Writeln('DFM OK');finally D.Free;S.Free;end;end.
