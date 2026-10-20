{$StackFrames On}
Unit LegacyMigrationU;

Interface

 Uses
  System.SysUtils, System.Classes, System.IOUtils, System.Math, Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteWrapper,
  TelemetryCatalogU;

 Procedure UpgradeLegacy(DB : TFDConnection; Const Path : String; Existing : Boolean; DriverLink : TFDPhysSQLiteDriverLink);

Implementation

 Function Quoted(Const Name : String) : String;
  Begin
   Result := '"' + Name.Replace('"', '""') + '"';
  End;

 Procedure UpgradeLegacy(DB : TFDConnection; Const Path : String; Existing : Boolean; DriverLink : TFDPhysSQLiteDriverLink);
  Const
   BitNames : Array [0 .. 12] Of String = ('bleed_air_engine', 'eng_anti_ice', 'eng_combustion', 'eng_failed', 'eng_on_fire', 'general_eng_fire_detected', 'general_eng_fuel_valve', 'general_eng_generator_active', 'general_eng_generator_switch', 'general_eng_starter', 'general_eng_starter_active', 'turb_eng_fuel_available', 'turb_eng_is_igniting');
   Groups : Array [0 .. 12] Of Integer  = (2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3);
   Bits : Array [0 .. 12] Of Integer    = (13, 15, 17, 19, 21, 23, 25, 27, 29, 1, 3, 6, 8);
   Tables : Array [0 .. 4] Of String    = ('trip_data', 'trip_events', 'trip_liftoffs', 'trip_touchdowns', 'trips');
  Var
   Info          : TFDQuery;
   Rows          : TFDQuery;
   Insert        : TFDQuery;
   Names         : TStringList;
   PK            : Integer;
   Version       : Integer;
   i             : Integer;
   e             : Integer;
   j             : Integer;
   Count         : Integer;
   EngineType    : Integer;
   Definition    : String;
   Columns       : String;
   SourceColumns : String;
   Name          : String;
   Column        : String;
   BlobName      : String;
   G             : TGUID;
   F             : TField;
   Blob          : TBytes;
   Value         : Single;
   Present       : Boolean;
   Backup        : TFDSQLiteBackup;
  Begin
   Info   := TFDQuery.Create(Nil);
   Rows   := TFDQuery.Create(Nil);
   Insert := TFDQuery.Create(Nil);
   Names  := TStringList.Create;
   Try
    Info.Connection   := DB;
    Rows.Connection   := DB;
    Insert.Connection := DB;
    Info.Open('pragma table_info(trip_data)');
    PK            := 0;
    Definition    := 'id INTEGER PRIMARY KEY';
    Columns       := 'id';
    SourceColumns := 'rowid';
    While Not Info.Eof Do
     Begin
      Name := Info.FieldByName('name').AsString;
      Names.Add(Name);
      If Name = 'id' Then
       PK := Info.FieldByName('pk').AsInteger
      Else
       Begin
        Definition    := Definition + ',' + Quoted(Name) + ' ' + Info.FieldByName('type').AsString;
        Columns       := Columns + ',' + Quoted(Name);
        SourceColumns := SourceColumns + ',' + Quoted(Name);
       End;
      Info.Next;
     End;
    Version := DB.ExecSQLScalar('pragma user_version');
    If Existing And ((PK = 0) Or (Version < 1)) Then
     Begin
      CreateGUID(G);
      Backup := TFDSQLiteBackup.Create(Nil);
      Try
       Backup.DriverLink   := DriverLink;
       Backup.Database     := Path;
       Backup.DestDatabase := Path + '.before-native-' + Copy(GUIDToString(G), 2, 36) + '.db';
       Backup.DestMode     := smCreate;
       Backup.Backup;
      Finally
       Backup.Free;
      End;
     End;
    If PK = 0 Then
     Begin
      DB.StartTransaction;
      Try
       DB.ExecSQL('create table native_upgrade_trip_data (' + Definition + ')');
       DB.ExecSQL('insert into native_upgrade_trip_data (' + Columns + ') select ' + SourceColumns + ' from trip_data');
       Rows.Open('select rowid native_sample,* from trip_data order by rowid');
       Columns       := 'sample,engine,trip';
       SourceColumns := ':sample,:engine,:trip';
       For i         := 0 To High(EngineColumns) Do
        Begin
         Columns       := Columns + ',' + EngineColumns[i].Name;
         SourceColumns := SourceColumns + ',:v' + IntToStr(i);
        End;
       Insert.SQL.Text := 'insert or ignore into trip_engine_data (' + Columns + ') values (' + SourceColumns + ')';
       While Not Rows.Eof Do
        Begin
         Count := 0;
         F     := Rows.FindField('number_of_engines');
         If Assigned(F) Then
          Count     := EnsureRange(F.AsInteger, 0, 4);
         EngineType := 0;
         F          := Rows.FindField('engine_type');
         If Assigned(F) Then
          EngineType := F.AsInteger;
         For e       := 1 To Count Do
          Begin
           Insert.ParamByName('sample').AsLargeInt := Rows.FieldByName('native_sample').AsLargeInt;
           Insert.ParamByName('trip').AsInteger    := Rows.FieldByName('trip').AsInteger;
           Insert.ParamByName('engine').AsInteger  := e;
           For i                                   := 0 To High(EngineColumns) Do
            Begin
             Insert.ParamByName('v' + IntToStr(i)).DataType := ftFloat;
             Insert.ParamByName('v' + IntToStr(i)).Clear;
             Column  := EngineColumns[i].Name;
             F       := Rows.FindField(Column + '_' + IntToStr(e));
             Present := Assigned(F) And Not F.IsNull;
             If Present Then
              Insert.ParamByName('v' + IntToStr(i)).AsFloat := F.AsFloat
             Else
              Begin
               If e <= 2 Then
                For j := 0 To High(BitNames) Do
                 If Column = BitNames[j] Then
                  Begin
                   F := Rows.FindField('bool_group_' + IntToStr(Groups[j]));
                   If Assigned(F) And Not F.IsNull Then
                    Begin
                     Insert.ParamByName('v' + IntToStr(i)).AsInteger := Ord((Cardinal(F.AsLargeInt) And (Cardinal(1) Shl (Bits[j] + e - 1))) <> 0);
                     Present                                         := True;
                    End;
                  End;
               If Not Present Then
                Begin
                 BlobName := '';
                 Case EngineType Of
                  0 :
                   If Column = 'general_eng_rpm' Then
                    BlobName := 'engine_speed'
                   Else If Column = 'recip_eng_manifold_pressure' Then
                    BlobName := 'engine_load';
                  1 :
                   If Column = 'turb_eng_n1' Then
                    BlobName := 'engine_speed'
                   Else If Column = 'turb_eng_n2' Then
                    BlobName := 'engine_load';
                  3 :
                   If Column = 'turb_eng_n1' Then
                    BlobName := 'engine_speed'
                   Else If Column = 'turb_eng_max_torque_percent' Then
                    BlobName := 'engine_load';
                  5 :
                   If Column = 'general_eng_rpm' Then
                    BlobName := 'engine_speed'
                   Else If Column = 'turb_eng_max_torque_percent' Then
                    BlobName := 'engine_load';
                 End;
                 If BlobName <> '' Then
                  Begin
                   F := Rows.FindField(BlobName);
                   If Assigned(F) Then
                    Begin
                     Blob := F.AsBytes;
                     If Length(Blob) >= e * 4 Then
                      Begin
                       Move(Blob[(e - 1) * 4], Value, 4);
                       Insert.ParamByName('v' + IntToStr(i)).AsFloat := Value;
                      End;
                    End;
                  End;
                End;
              End;
            End;
           Insert.ExecSQL;
          End;
         Rows.Next;
        End;
       Rows.Close;
       DB.ExecSQL('drop table trip_data');
       DB.ExecSQL('alter table native_upgrade_trip_data rename to trip_data');
       DB.Commit;
      Except
       DB.Rollback;
       Raise;
      End;
     End;
    If Version < 1 Then
     Begin
      DB.StartTransaction;
      Try
       For Name In Tables Do
        Begin
         Columns := 'time_local';
         If Name = 'trip_data' Then
          Columns := 'local_time';
         If Name = 'trips' Then
          Begin
           DB.ExecSQL('update trips set departure_local_time=substr(departure_local_time,1,23)||case substr(departure_local_time,24,1) when ''-'' then ''+'' else ''-'' end||substr(departure_local_time,25) where substr(departure_l' + 'ocal_time,24,1) in (''+'',''-'') and substr(departure_local_time,25,5)<>''00:00''');
           Columns := 'destination_local_time';
          End;
         DB.ExecSQL('update ' + Name + ' set ' + Columns + '=substr(' + Columns + ',1,23)||case substr(' + Columns + ',24,1) when ''-'' then ''+'' else ''-'' end||substr(' + Columns + ',25) where substr(' + Columns + ',24,1) in (''+'',''-'') and substr(' + Columns + ',25,5)<>''00:00''');
        End;
       DB.ExecSQL('pragma user_version=1');
       DB.Commit;
      Except
       DB.Rollback;
       Raise;
      End;
     End;
   Finally
    Names.Free;
    Info.Free;
    Rows.Free;
    Insert.Free;
   End;
  End;

End.
