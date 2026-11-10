Unit LegacyExportU;

Interface

 Uses
  FireDAC.Comp.Client;

 Procedure ExportLegacyFlight(Source : TFDConnection; TripID : Integer; Const FileName : String);

Implementation

 Uses
  Winapi.Windows, System.SysUtils, System.Classes, System.IOUtils, System.Variants,
  Data.DB, FireDAC.Stan.Param;

{$I LegacyExportSchema.inc}

 Procedure ExportLegacyFlight(Source : TFDConnection; TripID : Integer; Const FileName : String);
  Var
   Target         : TFDConnection;
   Rows           : TFDQuery;
   Insert         : TFDQuery;
   Columns        : TFDQuery;
   TempName       : String;
   TargetName     : String;
   Cols           : String;
   Params         : String;
   Expression     : String;
   Name           : String;
   Filter         : String;
   TableName      : String;
   i              : Integer;
   t              : Integer;
   GroupID        : Integer;
   OwnTransaction : Boolean;
   HasGroups      : Boolean;
   Token          : TGUID;
  Begin
   If (Source = Nil) Or Not Source.Connected Or (TripID <= 0) Then
    Raise Exception.Create('No flight selected for legacy export.');
   TargetName := TPath.GetFullPath(FileName);
   If SameText(TargetName, TPath.GetFullPath(Source.Params.Values['Database'])) Then
    Raise Exception.Create('The export cannot overwrite its source recording.');
   If Integer(Source.ExecSQLScalar('select count(*) from trips where id=:id', [TripID])) <> 1 Then
    Raise Exception.Create('The selected flight does not exist.');
   CreateGUID(Token);
   TempName       := TargetName + '.' + GUIDToString(Token) + '.tmp';
   Target         := TFDConnection.Create(Nil);
   Rows           := TFDQuery.Create(Nil);
   Insert         := TFDQuery.Create(Nil);
   Columns        := TFDQuery.Create(Nil);
   OwnTransaction := Not Source.InTransaction;
   Try
    Try
     If OwnTransaction Then
      Source.StartTransaction;
     Target.LoginPrompt               := False;
     Target.Params.Values['DriverID'] := 'SQLite';
     Target.Params.Values['Database'] := TempName;
     Target.Params.Values['OpenMode'] := 'CreateUTF8';
     Target.Connected                 := True;
     Target.ExecSQL('PRAGMA journal_mode=DELETE');
     Rows.Connection    := Source;
     Insert.Connection  := Target;
     Columns.Connection := Target;
     Target.StartTransaction;
     GroupID   := 0;
     HasGroups := Integer(Source.ExecSQLScalar('select count(*) from sqlite_master where type=''table'' and name=''trip_groups''')) > 0;
     For t     := Low(LegacyTableNames) To High(LegacyTableNames) Do
      Target.ExecSQL(LegacyTableSQL[t]);
     For t := Low(LegacyTableNames) To High(LegacyTableNames) Do
      Begin
       TableName := LegacyTableNames[t];
       Rows.Open('select name from sqlite_master where type=''table'' and name=:n', [TableName]);
       If Rows.IsEmpty Then
        Begin
         Rows.Close;
         Continue;
        End;
       Rows.Close;
       // Discover source columns without requiring newer schema migrations.
       Rows.Open('select * from ' + TableName + ' where 0=1');
       Columns.Open('pragma table_info(' + TableName + ')');
       Cols   := '';
       Params := '';
       While Not Columns.Eof Do
        Begin
         Name := Columns.FieldByName('name').AsString;
         If Rows.FindField(Name) <> Nil Then
          Begin
           If Cols <> '' Then
            Begin
             Cols   := Cols + ',';
             Params := Params + ',';
            End;
           Cols   := Cols + '"' + Name + '"';
           Params := Params + ':p' + IntToStr(Cols.CountChar(','));
          End;
         Columns.Next;
        End;
       Columns.Close;
       Rows.Close;
       If Cols = '' Then
        Continue;
       If TableName = 'trips' Then
        Filter := 'id=' + IntToStr(TripID)
       Else If TableName = 'trip_groups' Then
        Filter := 'id=' + IntToStr(GroupID)
       Else
        Filter    := 'trip=' + IntToStr(TripID);
       Expression := Cols;
       If TableName = 'trip_data' Then
        For i       := 1 To 3 Do
         Expression := StringReplace(Expression, '"bool_group_' + IntToStr(i) + '"', '(' + LegacyBoolExpressions[i] + ') as "bool_group_' + IntToStr(i) + '"', [rfReplaceAll]);
       Rows.Open('select ' + Expression + ' from ' + TableName + ' where ' + Filter);
       Insert.SQL.Text            := 'insert into ' + TableName + '(' + Cols + ') values(' + Params + ')';
       For i                      := 0 To Rows.FieldCount - 1 Do
        Insert.Params[i].DataType := Rows.Fields[i].DataType;
       Insert.Prepare;
       While Not Rows.Eof Do
        Begin
         For i := 0 To Rows.FieldCount - 1 Do
          Begin
           Name                      := Rows.Fields[i].FieldName;
           Insert.Params[i].DataType := Rows.Fields[i].DataType;
           If (TableName = 'trips') And (Name = 'group_id') Then
            Begin
             GroupID := Rows.Fields[i].AsInteger;
             If Not HasGroups Then
              GroupID := 0;
             If GroupID > 0 Then
              If Integer(Source.ExecSQLScalar('select count(*) from trip_groups where id=:id', [GroupID])) = 0 Then
               GroupID := 0;
             If GroupID = 0 Then
              Insert.Params[i].Clear
             Else
              Insert.Params[i].AsInteger := GroupID;
            End
           Else If Name = 'analysis_report' Then
            Insert.Params[i].Clear
           Else If (TableName = 'trip_data') And (Pos('bool_group_', Name) = 1) Then
            Insert.Params[i].AsLargeInt := Rows.Fields[i].AsLargeInt And Int64(LegacyBoolMasks[StrToInt(Copy(Name, 12, 1))])
           Else If Rows.Fields[i].IsNull Then
            Insert.Params[i].Clear
           Else
            Insert.Params[i].Value := Rows.Fields[i].Value;
          End;
         Insert.ExecSQL;
         Rows.Next;
        End;
       Rows.Close;
       Insert.Close;
       Insert.Unprepare;
      End;
     // Qt uses user_version to distinguish corrected local-time offsets.
     Target.ExecSQL('pragma user_version=' + IntToStr(Integer(Source.ExecSQLScalar('pragma user_version'))));
     Target.ExecSQL('create index idx_trip_data_trip on trip_data(trip)');
     Target.ExecSQL('create index idx_trip_engine_data_trip on trip_engine_data(trip)');
     If String(Target.ExecSQLScalar('pragma integrity_check')) <> 'ok' Then
      Raise Exception.Create('Legacy export integrity check failed.');
     Target.Commit;
     Target.Close;
     If OwnTransaction Then
      Source.Commit;
     If Not MoveFileEx(PChar(TempName), PChar(TargetName), MOVEFILE_REPLACE_EXISTING Or MOVEFILE_WRITE_THROUGH) Then
      RaiseLastOSError;
    Except
     If Target.InTransaction Then
      Target.Rollback;
     If OwnTransaction And Source.InTransaction Then
      Source.Rollback;
     Target.Close;
     If TFile.Exists(TempName) Then
      TFile.Delete(TempName);
     Raise;
    End;
   Finally
    Columns.Free;
    Insert.Free;
    Rows.Free;
    Target.Free;
   End;
  End;

End.
