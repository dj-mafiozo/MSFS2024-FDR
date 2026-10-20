Program VerifyGroups;
{$APPTYPE CONSOLE}
Uses System.SysUtils, System.Classes, System.IOUtils, Vcl.Forms, Vcl.Controls,
 Vcl.ExtCtrls, Data.DB, FireDAC.Comp.Client, FlightDatabaseU, FlightTelemetryU,
 TelemetryCatalogU, frmMainU, frmAssignGroupU;
Procedure Check(Value : Boolean; Const Msg : String);
 Begin If Not Value Then Raise Exception.Create(Msg); End;
Type TProbe = Class
 Expected, Chosen, ResultCode : Integer;
 Seen : Boolean;
 Procedure Tick(Sender : TObject);
End;
Procedure TProbe.Tick(Sender : TObject);
 Var I : Integer; D : TfrmAssignGroup;
 Begin
  For I := 0 To Screen.FormCount - 1 Do
   If Screen.Forms[I] Is TfrmAssignGroup Then
    Begin
     TTimer(Sender).Enabled := False;
     D := TfrmAssignGroup(Screen.Forms[I]);
     Check(D.BorderStyle = bsDialog, 'Dialog border');
     Check(Integer(NativeInt(D.cbGroups.Items.Objects[D.cbGroups.ItemIndex])) = Expected, 'Current group');
     D.cbGroups.ItemIndex := D.cbGroups.Items.IndexOfObject(TObject(NativeInt(Chosen)));
     Check(D.cbGroups.ItemIndex >= 0, 'Group available');
     Seen := True;
     If ResultCode = mrOk Then D.btnOK.Click Else D.btnCancel.Click;
     Exit;
    End;
 End;
Var DB : TFlightDatabase; S : TFlightSample; M : TfrmMain; P : TProbe;
 T : TTimer; IDs : Array[0..2] Of Integer; G : Array[0..1] Of Integer;
 I,K : Integer; Root : String; Rows : TDataSet;
Procedure Filter(GroupID : Integer);
 Begin
  M.cbGroup.ItemIndex := M.cbGroup.Items.IndexOfObject(TObject(NativeInt(GroupID)));
  M.GroupChanged(M.cbGroup);
 End;
Procedure Assign(Current, Target, Code : Integer);
 Begin
  P.Expected := Current; P.Chosen := Target; P.ResultCode := Code; P.Seen := False;
  T.Enabled := True;
  M.aAssignExecute(M.aAssign);
  Check(P.Seen, 'Modal dialog opened');
 End;
Begin
 Try
  Application.Initialize;
  Root := ExtractFilePath(ParamStr(0));
  DB := TFlightDatabase.Create(TPath.Combine(Root,'flight_data.db'),TPath.Combine(Root,'sqlite3.dll'));
  S := TFlightSample.Create;
  Try
   For K := 0 To FieldCount - 1 Do
    Begin
     If SimFields[K].Name = 'time_zulu.year' Then S.Numbers[K] := 2026;
     If SimFields[K].Name = 'time_zulu.month' Then S.Numbers[K] := 10;
     If SimFields[K].Name = 'time_zulu.day' Then S.Numbers[K] := 18;
     If SimFields[K].Name = 'title' Then S.Texts[K] := 'Group fixture';
    End;
   For I := 0 To 2 Do IDs[I] := DB.StartTrip(S);
   For I := 0 To 1 Do
    Begin
     DB.Connection.ExecSQL('insert into trip_groups(name) values (:n)', ['Group test '+IntToStr(IDs[0])+'-'+IntToStr(I)]);
     G[I] := DB.Connection.ExecSQLScalar('select last_insert_rowid()');
     DB.Connection.ExecSQL('update trips set group_id=:g where id=:id',[G[I],IDs[I]]);
    End;
  Finally S.Free; DB.Free; End;
  M := TfrmMain.Create(Nil); P := TProbe.Create; T := TTimer.Create(Nil);
  Try
   M.Timer.Enabled := False; T.Enabled := False; T.Interval := 20; T.OnTimer := P.Tick;
   Rows := M.HistoryGrid.DataSource.DataSet;
   Check(M.cbGroup.Items[0] = '', 'Empty means no filter');
   Filter(G[0]); Check((Rows.RecordCount = 1) And (Rows.FieldByName('id').AsInteger = IDs[0]), 'First group');
   M.aRefreshExecute(M.aRefresh); Check(Integer(NativeInt(M.cbGroup.Items.Objects[M.cbGroup.ItemIndex])) = G[0], 'Refresh preserves filter');
   Assign(G[0],G[1],mrCancel); Check(Rows.RecordCount = 1, 'Cancel preserves assignment');
   Assign(G[0],G[1],mrOk); Check(Rows.IsEmpty, 'Reassignment removes filtered row');
   Check((M.DataGrid.RowCount = 2) And (M.DataGrid.Cells[1,1] = ''), 'No stale inspector');
   Filter(G[1]); Check(Rows.RecordCount = 2, 'Second group');
   Rows.Locate('id',IDs[0],[]); Assign(G[1],0,mrOk);
   Check(Rows.RecordCount = 1, 'Unassign removes filtered row');
   Filter(0); Check(Rows.Locate('id',IDs[0],[]), 'All includes ungrouped');
   Check(Rows.Locate('id',IDs[2],[]), 'All includes originally ungrouped');
   M.cbGroup.ItemIndex := -1; M.GroupChanged(M.cbGroup);
   Check(M.cbGroup.ItemIndex = 0, 'No selection means all');
   Filter(G[0]); Check(Rows.IsEmpty, 'Empty group');
  Finally T.Free; P.Free; M.Free; End;
  Writeln('PASS: group filtering, empty/all selection, refresh retention, modal OK/Cancel, assignment/unassignment and empty groups. Synthetic SQLite/VCL only.');
 Except On E : Exception Do Begin Writeln('FAIL: ',E.Message); Halt(1); End; End;
End.
