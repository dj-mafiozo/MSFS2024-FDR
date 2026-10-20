program MockFlightPad32;
{$APPTYPE CONSOLE}
uses Winapi.Windows, System.SysUtils, FlightPadScreenIPCU;
var Publisher: TFlightPadScreenPublisher; Stop: THandle; Text, Line: string; R: Integer;
begin
  Stop := CreateEvent(nil, True, False, PChar('Local\FDR.FlightPad.TestStop.' + IntToStr(GetCurrentProcessId)));
  Publisher := TFlightPadScreenPublisher.Create(ParamStr(1));
  try
    Text := '';
    for R := 0 to 13 do
    begin
      case R of
        0: Line := 'PERF TAKE OFF'; 1: Line := 'V1 135';
        2: Line := 'VR 140'; 3: Line := 'V2 145';
        13: Line := 'SCRATCHPAD ' + WideChar($2190);
      else Line := ''; end;
      Text := Text + Copy(Line + StringOfChar(' ', 24), 1, 24) + #13#10;
    end;
    repeat Publisher.Publish(Text, True);
    until WaitForSingleObject(Stop, 20) <> WAIT_TIMEOUT;
  finally Publisher.Free; CloseHandle(Stop); end;
end.
