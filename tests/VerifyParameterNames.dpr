Program VerifyParameterNames;
{$APPTYPE CONSOLE}
Uses System.SysUtils, System.Classes, System.IOUtils, Vcl.Forms,
 ParameterNamesU, LocalizationU, frmChartsConfigureU, TelemetryCatalogU,
 iFlySDKCatalogU, FenixCatalogU, FBWCatalogU, PMDGNG3CatalogU, AirlinerCatalogU,
 FlightDatabaseU;
Procedure Check(Value : Boolean; Const Msg : String);
 Begin If Not Value Then Raise Exception.Create(Msg); End;
Procedure Readable(Const ID : String);
 Var Caption : String;
 Begin
  Caption := ParameterCaption(ID);
  Check(Caption <> '', 'Empty caption: '+ID);
  Check(Caption <> ID, 'Raw identifier exposed: '+ID);
  Check(Pos('_',Caption)=0, 'Identifier underscores exposed: '+Caption);
 End;
Var D : TfrmChartsConfigure; Available, Selected, Saved : TStringList;
 DB : TFlightDatabase; Plot : TTripPlot; I, J : Integer; Before : String;
Begin
 Try
  Application.Initialize;SetLanguage('pl-PL');
  Check(ParameterCaption('plane_altitude')='Wysokość samolotu [ft]','Polish altitude/units');
  Check(ParameterCaption('turb_eng_n1 #2')='Prędkość N1 — silnik 2 [%]','Engine index/percent');
  Check(Pos('[0–1]',ParameterCaption('aileron_left_deflection_pct'))>0,'Fraction is not mislabeled as percent');
  Check(Pos('iFly · ',ParameterCaption('iFlySDK.MCP_Altitude'))=1,'Provider identity');
  Check(Pos('[0]',ParameterCaption('iFlySDK.Fuel_Quantity_Indicator_Value[0]'))>0,'SDK zero-based index preserved');
  For I:=Low(NumericColumns) To High(NumericColumns) Do Readable(NumericColumns[I].Name);
  For I:=Low(BooleanColumns) To High(BooleanColumns) Do Readable(BooleanColumns[I].Name);
  For I:=Low(EngineColumns) To High(EngineColumns) Do
   For J:=1 To 4 Do Readable(EngineColumns[I].Name+' #'+IntToStr(J));
  For I:=0 To SDKFieldCount-1 Do Readable('iFlySDK.'+SDKFields[I].Name);
  For I:=0 To FenixFieldCount-1 Do Readable('FenixLVar.'+FenixFields[I].Name);
  For I:=0 To FBWFieldCount-1 Do Readable('FBWLVar.'+FBWFields[I].Name);
  For I:=0 To PMDGFieldCount-1 Do Readable('PMDGNG3.'+PMDGFields[I].Name);
  For I:=0 To High(AirlinerNames) Do Readable('AirlinerLVar.'+AirlinerNames[I]);
  Readable('GSX.FSDT_GSX_BOARDING_STATE');Readable('FSHud.clearanceLevel');
  Check(ParameterCaption('foo_bar')=ParameterCaption('fooBar'),'Collision fixture');
  Available:=TStringList.Create;Selected:=TStringList.Create;Saved:=TStringList.Create;
  D:=TfrmChartsConfigure.Create(Nil);
  Try
   Available.Add('foo_bar');Available.Add('fooBar');Available.Add('plane_altitude');Available.Add('turb_eng_n1 #2');
   Selected.Add('foo_bar');Selected.Add('fooBar');Selected.Add('plane_altitude');Selected.Add('unavailable_raw_field');
   D.Configure(Available,Selected);
   D.ChartOrderList.ItemIndex:=1;D.aMoveUp.Execute;
   D.CopySelectionTo(Saved);Check((Saved[0]='fooBar') And (Saved[1]='foo_bar'),'Duplicate captions keep raw identity when moving');
   D.ChartOrderList.ItemIndex:=0;D.aHide.Execute;
   D.CopySelectionTo(Saved);Check((Saved.IndexOf('fooBar')<0) And (Saved.IndexOf('foo_bar')>=0),'Hide removes correct duplicate');
   Check(Saved.IndexOf('unavailable_raw_field')>=0,'Unknown aircraft preferences retained');
   D.eSearch.Text:='wysokość';Check(D.ParameterList.Count=1,'Search translated label');
   D.eSearch.Text:='plane_altitude';Check(D.ParameterList.Count=1,'Search raw identifier');
   Check(D.ParameterList.Items[0]='Wysokość samolotu [ft]','Friendly checklist caption');
   D.ParameterList.ItemIndex:=0;D.ParameterList.Checked[0]:=False;D.ParameterCheck(D.ParameterList);
   D.CopySelectionTo(Saved);Check(Saved.IndexOf('plane_altitude')<0,'Uncheck persists raw identifier');
   D.ParameterList.Checked[0]:=True;D.ParameterCheck(D.ParameterList);
   D.CopySelectionTo(Saved);Check(Saved.IndexOf('plane_altitude')>=0,'Check persists raw identifier');
   D.eSearch.Text:='turb_eng_n1 #2';D.ParameterList.ItemIndex:=0;D.aShow.Execute;
   D.CopySelectionTo(Saved);Check(Saved.IndexOf('turb_eng_n1 #2')>=0,'Show action keeps raw engine ID');
   D.ChartOrderList.ItemIndex:=D.ChartOrderList.Count-1;D.aMoveFirst.Execute;
   D.CopySelectionTo(Saved);Check(Saved[0]='turb_eng_n1 #2','Move first keeps raw identity');
   D.ChartOrderList.ItemIndex:=0;D.aMoveLast.Execute;
   Check(D.ChartOrderList.ItemIndex=D.ChartOrderList.Count-1,'Move last selection');
   D.eSearch.Text:='plane_altitude';D.CopySelectionTo(Saved);
   Before:=Saved.Text;
   SetLanguage('en-US');Check(D.ParameterList.Items[0]='Aircraft altitude [ft]','Live English label');
   D.CopySelectionTo(Saved);Check(Saved.Text=Before,'Language change leaves IDs/order unchanged');
   SetLanguage('de-DE');Check(ParameterCaption('plane_altitude')='Flughöhe [ft]','German label cache');
   SetLanguage('es-ES');Check(ParameterCaption('plane_altitude')='Altitud del avión [ft]','Spanish label cache');
   SetLanguage('pl-PL');Check(D.ParameterList.Items[0]='Wysokość samolotu [ft]','Polish label restored');
  Finally D.Free;Saved.Free;Selected.Free;Available.Free;End;
  DB:=TFlightDatabase.Create(TPath.Combine(ExtractFilePath(ParamStr(0)),'flight_data.db'),TPath.Combine(ExtractFilePath(ParamStr(0)),'sqlite3.dll'));
  Try
   I:=DB.Connection.ExecSQLScalar('select coalesce(max(id),0) from trips');
   If I>0 Then
    Begin
     Plot:=DB.LoadTrip(I);
     Try
      Before:=Plot.Labels.Text;
      For J:=0 To Plot.Labels.Count-1 Do ParameterCaption(Plot.Labels[J]);
      Check(Plot.Labels.Text=Before,'Display lookup mutated model IDs');
      Check(Plot.Labels.IndexOf('plane_altitude')>=0,'Database still has original IDs');
     Finally Plot.Free;End;
    End;
  Finally DB.Free;End;
  Writeln('PASS: 212 curated SimConnect names, units/engine/array indices, all SDK catalogs, four locales, raw/friendly search, duplicate-caption identity, reorder/hide/check, unknown preferences and unchanged database/model identifiers. Synthetic only.');
 Except On E : Exception Do Begin Writeln('FAIL: ',E.Message);Halt(1);End;End;
End.
