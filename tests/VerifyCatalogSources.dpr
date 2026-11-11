Program VerifyCatalogSources;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU                                                                         In 'TestPathsU.pas', System.SysUtils, System.Classes, System.IOUtils, System.JSON,
 System.RegularExpressions, Winapi.Windows, DUnitX.TestFramework, NativeTestRunnerU In 'NativeTestRunnerU.pas',
 FlapsHandleU In '..\src\Visualization\FlapsHandleU.pas', ParameterNamesU In '..\src\Visualization\ParameterNamesU.pas', FenixCatalogU In '..\src\Aircraft\Fenix\FenixCatalogU.pas';

Type

 [TestFixture]
 TCatalogSourcesTests = Class
  Public
   [Test] Procedure ExplicitEnumExtraction;
   [Test] Procedure FenixModularInventory;
   [Test] Procedure CommittedProvenance;
 End;

Function LoadJSON(Const FileName : String) : TJSONObject;
 Begin
  Result := TJSONObject.ParseJSONValue(TFile.ReadAllText(FileName, TEncoding.UTF8)) As TJSONObject;
  Assert.IsNotNull(Result);
 End;

Procedure WriteFile(Const Path, Text : String);
 Begin
  ForceDirectories(ExtractFileDir(Path));
  TFile.WriteAllText(Path, Text, TEncoding.UTF8);
 End;

Procedure Tool(Const Name, Args : String);
 Var
  SI   : TStartupInfo;
  PI   : TProcessInformation;
  Cmd  : String;
  Code : DWORD;
 Begin
  FillChar(SI, SizeOf(SI), 0);
  SI.cb := SizeOf(SI);
  FillChar(PI, SizeOf(PI), 0);
  Cmd := 'python "' + TestRepositoryPath('tools\' + Name) + '" ' + Args;
  UniqueString(Cmd);
  Assert.IsTrue(CreateProcess(Nil, PChar(Cmd), Nil, Nil, False, CREATE_NO_WINDOW, Nil, Nil, SI, PI), 'Start source tool');
  Try
   If WaitForSingleObject(PI.hProcess, 30000) <> WAIT_OBJECT_0 Then
    Begin
     TerminateProcess(PI.hProcess, 1);
     Assert.Fail('Source tool timed out');
    End;
   Assert.IsTrue(GetExitCodeProcess(PI.hProcess, Code));
   Assert.AreEqual(0, Integer(Code), 'Source tool failed: ' + Name);
  Finally
   CloseHandle(PI.hThread);
   CloseHandle(PI.hProcess);
  End;
 End;

Procedure TCatalogSourcesTests.ExplicitEnumExtraction;
 Var
  Cases   : TJSONArray;
  Results : TJSONArray;
  o       : TJSONObject;
  Input   : String;
  Output  : String;

  Procedure Description(Const Text : String);
   Begin
    o := TJSONObject.Create;
    o.AddPair('description', Text);
    Cases.AddElement(o);
   End;

  Procedure XML(Const Text : String);
   Begin
    o := TJSONObject.Create;
    o.AddPair('xml', Text);
    Cases.AddElement(o);
   End;

  Function Item(Index : Integer) : TJSONObject;
   Begin
    Result := Results.Items[Index] As TJSONObject;
   End;

 Begin
  Cases := TJSONArray.Create;
  Try
   Description('0: switch OFF 1: switch AUTO 2: switch ON');
   Description('0' + #$FF1A + 'DIM' + #$FF1B + '1' + #$FF1A + 'OFF' + #$FF1B + '2' + #$FF1A + 'BRT');
   Description('0: 5 ... 7: 640');
   Description('Positions 0..6');
   Description('0~9: ''0''~''9'' 10: ''A'' 24: blank');
   Description('0: A 0: B');
   XML('<UseTemplate><ANIMTIP_0>OFF</ANIMTIP_0><ANIMTIP_1>AUTO</ANIMTIP_1><ANIMTIP_2>ON</ANIMTIP_2></UseTemplate>');
   XML('<UseTemplate><ANIMTIP_0>TT:RESOURCE.OFF</ANIMTIP_0><ANIMTIP_1>ON</ANIMTIP_1></UseTemplate>');
   XML('<UseTemplate><ANIMTIP_0>#VALUE#</ANIMTIP_0><ANIMTIP_1>ON</ANIMTIP_1></UseTemplate>');
   XML('<UseTemplate><LEFT_SINGLE_CODE>1 (&gt;L:TEST_SWITCH, number)</LEFT_SINGLE_CODE><LEFT_LEAVE_CODE>0 (&gt;L:TEST_SWITCH, number)</LEFT_LEAVE_CODE></UseTemplate>');
   XML('<UseTemplate><LEFT_SINGLE_CODE>1 (&gt;L:FIRST)</LEFT_SINGLE_CODE><LEFT_LEAVE_CODE>0 (&gt;L:OTHER)</LEFT_LEAVE_CODE></UseTemplate>');
   Input  := TestDataDirectory + 'enum-input.json';
   Output := TestDataDirectory + 'enum-output.json';
   WriteFile(Input, Cases.ToJSON);
   Tool('audit_display_values.py', '--extract-labels "' + Input + '" "' + Output + '"');
   Results := TJSONObject.ParseJSONValue(TFile.ReadAllText(Output, TEncoding.UTF8)) As TJSONArray;
   Try
    Assert.AreEqual('AUTO', Item(0).GetValue('1').Value);
    Assert.AreEqual('BRT', Item(1).GetValue('2').Value);
    Assert.AreEqual(2, Item(2).Count);
    Assert.AreEqual('640', Item(2).GetValue('7').Value);
    Assert.AreEqual(0, Item(3).Count);
    Assert.AreEqual(2, Item(4).Count);
    Assert.AreEqual('A', Item(4).GetValue('10').Value);
    Assert.AreEqual(0, Item(5).Count);
    Assert.AreEqual('AUTO', (Item(6).GetValue('indexed') As TJSONObject).GetValue('1').Value);
    Assert.AreEqual(0, (Item(7).GetValue('indexed') As TJSONObject).Count);
    Assert.AreEqual(0, (Item(8).GetValue('indexed') As TJSONObject).Count);
    Assert.AreEqual('TEST_SWITCH', (Item(9).GetValue('momentary') As TJSONArray).Items[0].Value);
    Assert.IsTrue(Item(10).GetValue('momentary') Is TJSONNull);
   Finally
    Results.Free;
   End;
  Finally
   Cases.Free;
  End;
 End;

Procedure TCatalogSourcesTests.FenixModularInventory;
 Var
  Base        : String;
  PackageRoot : String;
  Model       : String;
  Panel       : String;
  Previous    : String;
  Output      : String;
  ChangedHash : String;
  CockpitHash : String;
  Data        : TJSONObject;
  Again       : TJSONObject;
  Variables   : TJSONObject;

  Function PackageModel(Const Folder, Name, Version : String) : String;
   Var
    Root : String;
   Begin
    Root := Base + Folder + '\';
    WriteFile(Root + 'manifest.json', '{"package_version":"' + Version + '"}');
    Result := Root + 'SimObjects\Airplanes\FNX_32X\attachments\fnx\Part_Interior_Cockpit\model\Cockpit_Behavior.xml';
    WriteFile(Result, '<ModelBehaviors><UseTemplate Name="Fixture"><VAR_NAME>' + Name + '</VAR_NAME></UseTemplate></ModelBehaviors>');
   End;

  Procedure Run(Const Source, Extra : String);
   Begin
    Tool('import_fenix_catalog.py', '"' + ExcludeTrailingPathDelimiter(Source) + '" "' + Output + '" --previous "' + Previous + '" ' + Extra);
   End;

 Begin
  Base        := TestDataDirectory + 'fenix\';
  PackageRoot := Base + 'fnx-aircraft-a32x-common\';
  Model       := PackageModel('fnx-aircraft-a32x-common', 'S_GEAR', '3.0.fixture');
  WriteFile(Model, '<ModelBehaviors><UseTemplate Name="Controls"><VAR_NAME>S_GEAR</VAR_NAME><VAR_NAME_LIT>I_GEAR</VAR_NAME_LIT><VAR_NAME_BAD>#PLACEHOLDER#</VAR_NAME_BAD></UseTemplate></ModelBehaviors>');
  Panel := PackageRoot + 'SimObjects\Airplanes\FNX_32X\attachments\fnx\Part_Interior_Panel_A321\model\Panel.xml';
  WriteFile(Panel, '<ModelBehaviors><UseTemplate Name="Panel"><VAR_NAME>S_MOVED</VAR_NAME><VAR_NAME_LIT>I_NEW_A321</VAR_NAME_LIT><VAR_NAME_1>I_GEAR</VAR_NAME_1></UseTemplate></ModelBehaviors>');
  Previous := Base + 'previous.json';
  Output   := Base + 'output.json';
  WriteFile(Previous, '{"sha256":"old-cockpit","variables":{"S_GEAR":[],"I_GEAR":[],"S_MOVED":[],"CB_OLD":[]},"retired_variables":{"I_NEW_A321":[]}}');
  Run(Model, '');
  Data := LoadJSON(Output);
  Try
   Variables := Data.GetValue('variables') As TJSONObject;
   Assert.AreEqual(4, Variables.Count);
   Assert.AreEqual(2, (Variables.GetValue('I_GEAR') As TJSONArray).Count);
   Assert.IsNotNull((Data.GetValue('retired_variables') As TJSONObject).GetValue('CB_OLD'));
   Assert.IsNull((Data.GetValue('retired_variables') As TJSONObject).GetValue('I_NEW_A321'));
   Assert.AreEqual('3.0.fixture', Data.GetValue('package_version').Value);
   Assert.AreEqual(0, Pos(PackageRoot, Data.ToJSON));
   ChangedHash := Data.GetValue('catalog_sha256').Value;
   CockpitHash := Data.GetValue('sha256').Value;
   Run(Model, '');
   Again := LoadJSON(Output);
   Try
    Assert.AreEqual(Data.ToJSON, Again.ToJSON);
   Finally
    Again.Free;
   End;
   Run(PackageRoot, '');
   Again := LoadJSON(Output);
   Try
    Assert.AreEqual(Variables.ToJSON, Again.GetValue('variables').ToJSON);
   Finally
    Again.Free;
   End;
   Run(Model, '--cockpit-only');
   Again := LoadJSON(Output);
   Try
    Assert.AreEqual(2, (Again.GetValue('variables') As TJSONObject).Count);
   Finally
    Again.Free;
   End;
   WriteFile(Panel, StringReplace(TFile.ReadAllText(Panel), 'I_NEW_A321', 'I_CHANGED_A321', []));
   Run(Model, '');
   Again := LoadJSON(Output);
   Try
    Assert.AreNotEqual(ChangedHash, Again.GetValue('catalog_sha256').Value);
    Assert.AreEqual(CockpitHash, Again.GetValue('sha256').Value);
   Finally
    Again.Free;
   End;
  Finally
   Data.Free;
  End;
  PackageModel('fnx-aircraft-320', 'S_CEO', '3.0.fixture');
  PackageModel('fnx-aircraft-319', 'S_OLD_PACKAGE', '2.5.fixture');
  PackageModel('fnx-aircraft-320-liveries', 'S_LIVERY', '3.0.fixture');
  Run(Model, '');
  Data := LoadJSON(Output);
  Try
   Variables := Data.GetValue('variables') As TJSONObject;
   Assert.IsNotNull(Variables.GetValue('S_CEO'));
   Assert.IsNull(Variables.GetValue('S_OLD_PACKAGE'));
   Assert.IsNull(Variables.GetValue('S_LIVERY'));
   Assert.AreEqual(2, (Data.GetValue('source_packages') As TJSONArray).Count);
  Finally
   Data.Free;
  End;
 End;

Procedure TCatalogSourcesTests.CommittedProvenance;
 Var
  Data       : TJSONObject;
  Mapping    : TJSONObject;
  Values     : TJSONObject;
  Variables  : TJSONObject;
  Retired    : TJSONObject;
  Row        : TJSONObject;
  Pair       : TJSONPair;
  Entry      : TJSONPair;
  Sources    : TJSONArray;
  Source     : TJSONValue;
  Number     : Double;
  Code       : String;
  Dictionary : String;
  Labels     : TStringList;
  i          : Integer;
 Begin
  Data := LoadJSON(TestRepositoryPath('support\display-values\catalog.json'));
  Try
   Sources := Data.GetValue('sources') As TJSONArray;
   Assert.IsTrue(Sources.Count > 200);
   For Pair In Data.GetValue('mappings') As TJSONObject Do
    Begin
     Mapping := Pair.JsonValue As TJSONObject;
     Values  := Mapping.GetValue('values') As TJSONObject;
     Assert.IsTrue(Values.Count > 0);
     Assert.IsTrue((Mapping.GetValue('sources') As TJSONArray).Count > 0);
     For Entry In Values Do
      Begin
       Assert.IsTrue(TryStrToFloat(Entry.JsonString.Value, Number, TFormatSettings.Invariant));
       Assert.IsTrue(Trim(Entry.JsonValue.Value) <> '');
       Assert.IsFalse(TRegEx.IsMatch(Entry.JsonValue.Value, '[\r\n\t]'));
      End;
     For Source In Mapping.GetValue('sources') As TJSONArray Do
      Assert.IsTrue(TRegEx.IsMatch((Sources.Items[StrToInt(Source.Value)] As TJSONObject).GetValue('sha256').Value, '^[a-f0-9]{64}$'));
    End;
   Assert.AreEqual('AUTO', ParameterDisplayText('FenixLVar.S_OH_EXT_LT_STROBE', 1));
   Assert.AreEqual('BRT', ParameterDisplayText('iFlySDK.Compass_Light_Switch_Status', 2));
  Finally
   Data.Free;
  End;
  Data   := LoadJSON(TestRepositoryPath('support\display-values\flaps.json'));
  Labels := TStringList.Create;
  Try
   Assert.AreEqual('', Data.GetValue('default_display_value').Value);
   For Pair In Data.GetValue('aircraft') As TJSONObject Do
    Begin
     Code := Pair.JsonString.Value;
     Row  := Pair.JsonValue As TJSONObject;
     Assert.IsTrue(TRegEx.IsMatch(Code, '^[A-Z0-9]{2,4}$'));
     Assert.IsTrue((Row.GetValue('sources') As TJSONArray).Count > 0);
     If Row.GetValue('labels') Is TJSONArray Then
      Begin
       Sources     := Row.GetValue('labels') As TJSONArray;
       Dictionary  := FlapsHandleDisplayValue(Code);
       Labels.Text := StringReplace(Dictionary, '\r\n', sLineBreak, [rfReplaceAll]);
       For i       := 0 To Sources.Count - 1 Do
        Assert.AreEqual(Sources.Items[i].Value, Labels.Values[IntToStr(i)], Code);
      End;
    End;
  Finally
   Labels.Free;
   Data.Free;
  End;
  Data := LoadJSON(TestRepositoryPath('support\fenix\variables.json'));
  Try
   Variables := Data.GetValue('variables') As TJSONObject;
   Retired   := Data.GetValue('retired_variables') As TJSONObject;
   Assert.AreEqual(FenixFieldCount, Variables.Count);
   Assert.AreEqual(Variables.Count, StrToInt(Data.GetValue('variable_count').Value));
   For Pair In Variables Do
    Assert.IsNull(Retired.GetValue(Pair.JsonString.Value));
   Assert.IsNotNull(Variables.GetValue('B_CONFIG_BARO_UNIT'));
   Assert.IsNotNull(Variables.GetValue('N_CONFIG_ENGINETYPE'));
   Assert.IsNotNull(Variables.GetValue('N_FC_BRAKE_LEFT'));
   Assert.IsNotNull(Variables.GetValue('N_FC_BRAKE_RIGHT'));
   Assert.IsNotNull(Variables.GetValue('I_MIP_AUTOLAND_CAPT_L'));
   Assert.IsNotNull(Retired.GetValue('CB_A01_HP_FUEL_SOV_1'));
  Finally
   Data.Free;
  End;
 End;

Begin
 RunNativeTests(TCatalogSourcesTests);
End.
