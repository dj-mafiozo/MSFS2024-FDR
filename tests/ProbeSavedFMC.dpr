program ProbeSavedFMC;
{$APPTYPE CONSOLE}
uses System.SysUtils, System.JSON, FireDAC.Comp.Client, FireDAC.Phys.SQLite,
  FireDAC.Stan.Def, FireDAC.Stan.Async, FireDAC.DApt, FMCScreensU;
var D: TFDPhysSQLiteDriverLink; C: TFDConnection; Q: TFDQuery;
    S: TFMCScreen; J: TJSONObject; N, Selected, Takeoff: Integer;
begin
  if ParamCount<>1 then raise Exception.Create('Usage: ProbeSavedFMC database.db (read only)');
  D:=TFDPhysSQLiteDriverLink.Create(nil);C:=TFDConnection.Create(nil);Q:=TFDQuery.Create(nil);
  try
    D.VendorLib:=ExtractFilePath(ParamStr(0))+'sqlite3.dll';
    C.LoginPrompt:=False;C.ResourceOptions.SilentMode:=True;
    C.Params.Values['DriverID']:='SQLite';C.Params.Values['Database']:=ParamStr(1);
    C.Params.Values['OpenMode']:='ReadOnly';C.Params.Values['LockingMode']:='Normal';
    C.Params.Values['SharedCache']:='False';C.Connected:=True;
    Q.Connection:=C;Q.FormatOptions.StrsTrim:=False;
    Q.Open('select * from trip_fmc_screens order by id');N:=0;Selected:=0;Takeoff:=0;
    while not Q.Eof do begin
      S:=TFMCScreen.Create;
      try
        S.Provider:=Q.FieldByName('provider').AsString;S.Available:=Q.FieldByName('available').AsInteger<>0;
        S.PowerState:=Q.FieldByName('powered').AsInteger;S.Lines.Text:=Q.FieldByName('raw_text').AsWideString;
        S.IdentifyPage;J:=ParseFMCValues(S);
        try
          Inc(N);
          if (J.GetValue('approach_flaps_deg')<>nil) and not (J.GetValue('vref_kt') is TJSONNull) then begin
            Inc(Selected);Writeln('id=',Q.FieldByName('id').AsInteger,' ',J.ToJSON);
          end;
          if (J.GetValue('v1_kt')<>nil) and not (J.GetValue('v1_kt') is TJSONNull) then begin
            Inc(Takeoff);Writeln('id=',Q.FieldByName('id').AsInteger,' ',J.ToJSON);
          end;
        finally J.Free;end;
      finally S.Free;end;
      Q.Next;
    end;
    Writeln('Read-only replay: ',N,' screens, ',Takeoff,' selected takeoff screens, ',Selected,' selected approach screens.');
  finally Q.Free;C.Free;D.Free;end;
end.
