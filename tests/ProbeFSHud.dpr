Program ProbeFSHud;
{$APPTYPE CONSOLE}

Uses
 Winapi.Windows, System.SysUtils, System.JSON, System.Classes, FSHudClientU In '..\src\FSHud\FSHudClientU.pas';

Var
 c        : TFSHudClient;
 Messages : TArray<TFSHudMessage>;
 m        : TFSHudMessage;
 v        : TJSONObject;
 p        : TJSONPair;
 i        : Integer;
 Lines    : TStringList;

Begin
 c     := TFSHudClient.Create;
 Lines := TStringList.Create;
 Try
  c.Start;
  For i := 1 To 20 Do
   Begin
    Sleep(500);
    Messages := c.Take;
    For m In Messages Do
     Begin
      Lines.Add(m.Payload);
      v := TJSONObject.ParseJSONValue(m.Payload) As TJSONObject;
      Try
       Write(m.Kind, ': ');
       For p In v Do
        Write(p.JsonString.Value, ' ');
       Writeln;
      Finally
       v.Free;
      End;
     End;
   End;
  Writeln('Status: ', c.GetStatus);
  If ParamCount > 0 Then
   Lines.SaveToFile(ParamStr(1), TEncoding.UTF8);
 Finally
  c.Free;
  Lines.Free;
 End;
End.
