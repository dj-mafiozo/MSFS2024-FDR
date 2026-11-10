Program ProbeSavedFMC;
{$APPTYPE CONSOLE}

Uses
 System.SysUtils, System.JSON, FireDAC.Comp.Client, FireDAC.Phys.SQLite,
 FireDAC.Stan.Def, FireDAC.Stan.Async, FireDAC.DApt, FMCScreensU;

Var
 d        : TFDPhysSQLiteDriverLink;
 c        : TFDConnection;
 q        : TFDQuery;
 s        : TFMCScreen;
 j        : TJSONObject;
 n        : Integer;
 Selected : Integer;
 Takeoff  : Integer;

Begin
 If ParamCount <> 1 Then
  Raise Exception.Create('Usage: ProbeSavedFMC database.db (read only)');
 d := TFDPhysSQLiteDriverLink.Create(Nil);
 c := TFDConnection.Create(Nil);
 q := TFDQuery.Create(Nil);
 Try
  d.VendorLib                    := ExtractFilePath(ParamStr(0)) + 'sqlite3.dll';
  c.LoginPrompt                  := False;
  c.ResourceOptions.SilentMode   := True;
  c.Params.Values['DriverID']    := 'SQLite';
  c.Params.Values['Database']    := ParamStr(1);
  c.Params.Values['OpenMode']    := 'ReadOnly';
  c.Params.Values['LockingMode'] := 'Normal';
  c.Params.Values['SharedCache'] := 'False';
  c.Connected                    := True;
  q.Connection                   := c;
  q.FormatOptions.StrsTrim       := False;
  q.Open('select * from trip_fmc_screens order by id');
  n        := 0;
  Selected := 0;
  Takeoff  := 0;
  While Not q.Eof Do
   Begin
    s := TFMCScreen.Create;
    Try
     s.Provider   := q.FieldByName('provider').AsString;
     s.Available  := q.FieldByName('available').AsInteger <> 0;
     s.PowerState := q.FieldByName('powered').AsInteger;
     s.Lines.Text := q.FieldByName('raw_text').AsWideString;
     s.IdentifyPage;
     j := ParseFMCValues(s);
     Try
      Inc(n);
      If (j.GetValue('approach_flaps_deg') <> Nil) And Not(j.GetValue('vref_kt') Is TJSONNull) Then
       Begin
        Inc(Selected);
        Writeln('id=', q.FieldByName('id').AsInteger, ' ', j.ToJSON);
       End;
      If (j.GetValue('v1_kt') <> Nil) And Not(j.GetValue('v1_kt') Is TJSONNull) Then
       Begin
        Inc(Takeoff);
        Writeln('id=', q.FieldByName('id').AsInteger, ' ', j.ToJSON);
       End;
     Finally
      j.Free;
     End;
    Finally
     s.Free;
    End;
    q.Next;
   End;
  Writeln('Read-only replay: ', n, ' screens, ', Takeoff, ' selected takeoff screens, ', Selected, ' selected approach screens.');
 Finally
  q.Free;
  c.Free;
  d.Free;
 End;
End.
