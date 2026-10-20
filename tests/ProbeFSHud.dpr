program ProbeFSHud;
{$APPTYPE CONSOLE}
uses Winapi.Windows,System.SysUtils,System.JSON,System.Classes,FSHudClientU;
var C:TFSHudClient;Messages:TArray<TFSHudMessage>;M:TFSHudMessage;V:TJSONObject;P:TJSONPair;I:Integer;Lines:TStringList;
begin
  C:=TFSHudClient.Create;Lines:=TStringList.Create;
  try
    C.Start;
    for I:=1 to 20 do begin
      Sleep(500);Messages:=C.Take;
      for M in Messages do begin
        Lines.Add(M.Payload);V:=TJSONObject.ParseJSONValue(M.Payload) as TJSONObject;
        try Write(M.Kind,': ');for P in V do Write(P.JsonString.Value,' ');Writeln;finally V.Free;end;
      end;
    end;
    Writeln('Status: ',C.GetStatus);
    if ParamCount>0 then Lines.SaveToFile(ParamStr(1),TEncoding.UTF8);
  finally C.Free;Lines.Free;end;
end.
