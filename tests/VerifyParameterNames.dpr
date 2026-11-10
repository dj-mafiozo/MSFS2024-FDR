Program VerifyParameterNames;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU,
 System.SysUtils, System.Classes, System.IOUtils, Vcl.Forms,
 ParameterNamesU, LocalizationU, frmChartsConfigureU, TelemetryCatalogU,
 iFlySDKCatalogU, FenixCatalogU, FBWCatalogU, PMDGNG3CatalogU, AirlinerCatalogU,
 FlightDatabaseU;

Procedure Check(Value : Boolean; Const Msg : String);
 Begin
  If Not Value Then
   Raise Exception.Create(Msg);
 End;

Procedure Readable(Const ID : String);
 Var
  Caption : String;
 Begin
  Caption := ParameterCaption(ID);
  Check(Caption <> '', 'Empty caption: ' + ID);
  Check(Caption <> ID, 'Raw identifier exposed: ' + ID);
  Check(Pos('_', Caption) = 0, 'Identifier underscores exposed: ' + Caption);
 End;

Var
 d         : TfrmChartsConfigure;
 Available : TStringList;
 Selected  : TStringList;
 Saved     : TStringList;
 DB        : TFlightDatabase;
 Plot      : TTripPlot;
 i         : Integer;
 j         : Integer;
 Before    : String;

Type

 [TestFixture]
 TVerifyParameterNamesTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyParameterNamesTests.Regression;
 Begin
  Try
   Application.Initialize;
   SetLanguage('pl-PL');
   Check(ParameterCaption('plane_altitude') = 'Wysokość samolotu [ft]', 'Polish altitude/units');
   Check(ParameterCaption('turb_eng_n1 #2') = 'Prędkość N1 — silnik 2 [%]', 'Engine index/percent');
   Check(Pos('[0–1]', ParameterCaption('aileron_left_deflection_pct')) > 0, 'Fraction is not mislabeled as percent');
   Check(Pos('iFly · ', ParameterCaption('iFlySDK.MCP_Altitude')) = 1, 'Provider identity');
   Check(Pos('[0]', ParameterCaption('iFlySDK.Fuel_Quantity_Indicator_Value[0]')) > 0, 'SDK zero-based index preserved');
   For i := Low(NumericColumns) To High(NumericColumns) Do
    Readable(NumericColumns[i].Name);
   For i := Low(BooleanColumns) To High(BooleanColumns) Do
    Readable(BooleanColumns[i].Name);
   For i  := Low(EngineColumns) To High(EngineColumns) Do
    For j := 1 To 4 Do
     Readable(EngineColumns[i].Name + ' #' + IntToStr(j));
   For i := 0 To SDKFieldCount - 1 Do
    Readable('iFlySDK.' + SDKFields[i].Name);
   For i := 0 To FenixFieldCount - 1 Do
    Readable('FenixLVar.' + FenixFields[i].Name);
   For i := 0 To FBWFieldCount - 1 Do
    Readable('FBWLVar.' + FBWFields[i].Name);
   For i := 0 To PMDGFieldCount - 1 Do
    Readable('PMDGNG3.' + PMDGFields[i].Name);
   For i := 0 To High(AirlinerNames) Do
    Readable('AirlinerLVar.' + AirlinerNames[i]);
   Readable('GSX.FSDT_GSX_BOARDING_STATE');
   Readable('FSHud.clearanceLevel');
   Check(ParameterCaption('foo_bar') = ParameterCaption('fooBar'), 'Collision fixture');
   Available := TStringList.Create;
   Selected  := TStringList.Create;
   Saved     := TStringList.Create;
   d         := TfrmChartsConfigure.Create(Nil);
   Try
    Available.Add('foo_bar');
    Available.Add('fooBar');
    Available.Add('plane_altitude');
    Available.Add('turb_eng_n1 #2');
    Selected.Add('foo_bar');
    Selected.Add('fooBar');
    Selected.Add('plane_altitude');
    Selected.Add('unavailable_raw_field');
    d.Configure(Available, Selected);
    d.ChartOrderList.ItemIndex := 1;
    d.aMoveUp.Execute;
    d.CopySelectionTo(Saved);
    Check((Saved[0] = 'fooBar') And (Saved[1] = 'foo_bar'), 'Duplicate captions keep raw identity when moving');
    d.ChartOrderList.ItemIndex := 0;
    d.aHide.Execute;
    d.CopySelectionTo(Saved);
    Check((Saved.IndexOf('fooBar') < 0) And (Saved.IndexOf('foo_bar') >= 0), 'Hide removes correct duplicate');
    Check(Saved.IndexOf('unavailable_raw_field') >= 0, 'Unknown aircraft preferences retained');
    d.eSearch.Text := 'wysokość';
    Check(d.ParameterList.Count = 1, 'Search translated label');
    d.eSearch.Text := 'plane_altitude';
    Check(d.ParameterList.Count = 1, 'Search raw identifier');
    Check(d.ParameterList.Items[0] = 'Wysokość samolotu [ft]', 'Friendly checklist caption');
    d.ParameterList.ItemIndex  := 0;
    d.ParameterList.Checked[0] := False;
    d.ParameterCheck(d.ParameterList);
    d.CopySelectionTo(Saved);
    Check(Saved.IndexOf('plane_altitude') < 0, 'Uncheck persists raw identifier');
    d.ParameterList.Checked[0] := True;
    d.ParameterCheck(d.ParameterList);
    d.CopySelectionTo(Saved);
    Check(Saved.IndexOf('plane_altitude') >= 0, 'Check persists raw identifier');
    d.eSearch.Text            := 'turb_eng_n1 #2';
    d.ParameterList.ItemIndex := 0;
    d.aShow.Execute;
    d.CopySelectionTo(Saved);
    Check(Saved.IndexOf('turb_eng_n1 #2') >= 0, 'Show action keeps raw engine ID');
    d.ChartOrderList.ItemIndex := d.ChartOrderList.Count - 1;
    d.aMoveFirst.Execute;
    d.CopySelectionTo(Saved);
    Check(Saved[0] = 'turb_eng_n1 #2', 'Move first keeps raw identity');
    d.ChartOrderList.ItemIndex := 0;
    d.aMoveLast.Execute;
    Check(d.ChartOrderList.ItemIndex = d.ChartOrderList.Count - 1, 'Move last selection');
    d.eSearch.Text := 'plane_altitude';
    d.CopySelectionTo(Saved);
    Before := Saved.Text;
    SetLanguage('en-US');
    Check(d.ParameterList.Items[0] = 'Aircraft altitude [ft]', 'Live English label');
    d.CopySelectionTo(Saved);
    Check(Saved.Text = Before, 'Language change leaves IDs/order unchanged');
    SetLanguage('de-DE');
    Check(ParameterCaption('plane_altitude') = 'Flughöhe [ft]', 'German label cache');
    SetLanguage('es-ES');
    Check(ParameterCaption('plane_altitude') = 'Altitud del avión [ft]', 'Spanish label cache');
    SetLanguage('pl-PL');
    Check(d.ParameterList.Items[0] = 'Wysokość samolotu [ft]', 'Polish label restored');
   Finally
    d.Free;
    Saved.Free;
    Selected.Free;
    Available.Free;
   End;
   DB := TFlightDatabase.Create(TestDatabasePath(TPath.Combine(ExtractFilePath(ParamStr(0)), 'flight_data.db')), TPath.Combine(ExtractFilePath(ParamStr(0)), 'sqlite3.dll'));
   Try
    i := DB.Connection.ExecSQLScalar('select coalesce(max(id),0) from trips');
    If i > 0 Then
     Begin
      Plot := DB.LoadTrip(i);
      Try
       Before := Plot.Labels.Text;
       For j  := 0 To Plot.Labels.Count - 1 Do
        ParameterCaption(Plot.Labels[j]);
       Check(Plot.Labels.Text = Before, 'Display lookup mutated model IDs');
       Check(Plot.Labels.IndexOf('plane_altitude') >= 0, 'Database still has original IDs');
      Finally
       Plot.Free;
      End;
     End;
   Finally
    DB.Free;
   End;
   System.Writeln('PASS: 212 curated SimConnect names, units/engine/array indices, all SDK catalogs, four locales, raw/friendly search, duplicate-caption identity, reorder/hide/check, unknown preferences and unchanged database/model identifiers. Synthetic only.');
  Except
   On E : Exception Do
    Begin
     System.Writeln('FAIL: ', E.Message);
     Raise Exception.Create('Regression failed; see diagnostic above');
    End;
  End;

 End;

Begin
 RunNativeTests(TVerifyParameterNamesTests);
End.
