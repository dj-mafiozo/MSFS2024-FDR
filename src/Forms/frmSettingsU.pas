Unit frmSettingsU;

Interface

 Uses
  LocalizationU, i18nLocalizer, i18nCore, Winapi.Windows, System.Classes, System.SysUtils,
  System.IniFiles, System.Math, Vcl.ComCtrls, Vcl.Forms, Vcl.StdCtrls, Vcl.Controls, Vcl.Samples.Spin, Vcl.ExtCtrls,
  OllamaAnalysisU, ParameterNamesU, Vcl.ValEdit, Vcl.Grids;

 Type
  TfrmSettings = Class(TLocalizedForm)
   Published
    AppTranslator    : TTranslator;
    SettingsPages : TPageControl;
    UnitsPage : TTabSheet;
    UnitsEditor : TValueListEditor;
    GeneralPage, AnalysisPage, AIPage : TTabSheet;
    ProviderPages : TPageControl;
    CodexPage, GeminiPage, OllamaPage : TTabSheet;
    LanguageLabel    : TLabel;
    cbLanguage       : TComboBox;
    seBefore         : TSpinEdit;
    seAfter          : TSpinEdit;
    seLandingBefore  : TSpinEdit;
    seLandingAfter   : TSpinEdit;
    lStartWindow     : TLabel;
    lLandingWindow   : TLabel;
    lBefore          : TLabel;
    lAfter           : TLabel;
    lLandingBefore   : TLabel;
    lLandingAfter    : TLabel;
    lOllamaURL       : TLabel;
    lOllamaModel     : TLabel;
    lOllamaContext   : TLabel;
    seOllamaContext  : TSpinEdit;
    eOllamaURL       : TEdit;
    cbOllamaModel    : TComboBox;
    btnOllamaRefresh : TButton;
    ModelsTimer      : TTimer;
    lProvider        : TLabel;
    lCodexPath       : TLabel;
    lCodexModel      : TLabel;
    lGeminiModel     : TLabel;
    lKey             : TLabel;
    lTimeout         : TLabel;
    lHelp            : TLabel;
    cbProvider       : TComboBox;
    eCodexPath       : TEdit;
    eCodexModel      : TEdit;
    eGeminiModel     : TEdit;
    eGeminiKey       : TEdit;
    seTimeout        : TSpinEdit;
    btnOK            : TButton;
    btnCancel        : TButton;
    btnResetLayout   : TButton;
    Procedure RefreshOllamaModels(Sender : TObject);
    Procedure ModelsTick(Sender : TObject);
    Procedure ModelsActivate(Sender : TObject);
   Private
    fModelsThread   : TOllamaModelsThread;
    fModelsURL      : String;
    fRefreshPending : Boolean;
   Public
    Destructor Destroy; Override;
    Procedure Load(Config : TMemIniFile);
    Procedure Save(Config : TMemIniFile);
  End;

 Procedure ReadAnalysisWindow(Config : TMemIniFile; Landing : Boolean; Out BeforeSeconds, AfterSeconds : Integer);

Implementation

 {$R *.dfm}

 Destructor TfrmSettings.Destroy;
  Begin
   If ModelsTimer <> Nil Then
    ModelsTimer.Enabled := False;
   If fModelsThread <> Nil Then
    Begin
     fModelsThread.Terminate;
     fModelsThread.Free;
    End;
   Inherited;
  End;

 Procedure TfrmSettings.ModelsActivate(Sender : TObject);
  Begin
   ProviderPages.ActivePageIndex := cbProvider.ItemIndex;
   If cbProvider.ItemIndex = 2 Then
    RefreshOllamaModels(Sender);
  End;

 Procedure TfrmSettings.RefreshOllamaModels(Sender : TObject);
  Var
   Selected : String;
  Begin
   If fModelsThread <> Nil Then
    Begin
     fRefreshPending := True;
     fModelsThread.Terminate;
     Exit;
    End;
   fRefreshPending := False;
   fModelsURL      := Trim(eOllamaURL.Text);
   Selected        := cbOllamaModel.Text;
   cbOllamaModel.Items.Clear;
   cbOllamaModel.Text       := Selected;
   lHelp.Caption            := Tr('Ollama: pobieranie listy modeli...');
   btnOllamaRefresh.Enabled := False;
   fModelsThread            := TOllamaModelsThread.Create(fModelsURL);
   fModelsThread.Start;
   ModelsTimer.Enabled := True;
  End;

 Procedure TfrmSettings.ModelsTick(Sender : TObject);
  Var
   Selected : String;
   Index    : Integer;
  Begin
   If (fModelsThread = Nil) Or (WaitForSingleObject(fModelsThread.Handle, 0) <> WAIT_OBJECT_0) Then
    Exit;
   ModelsTimer.Enabled      := False;
   btnOllamaRefresh.Enabled := True;
   Try
    If Not fRefreshPending And (fModelsURL = Trim(eOllamaURL.Text)) Then
     If fModelsThread.Error <> '' Then
      lHelp.Caption := Tr('Ollama: ') + Copy(fModelsThread.Error, 1, 75)
     Else
      Begin
       Selected := cbOllamaModel.Text;
       cbOllamaModel.Items.Assign(fModelsThread.Models);
       Index := cbOllamaModel.Items.IndexOf(Selected);
       If (Selected = '') And (cbOllamaModel.Items.Count > 0) Then
        Index                  := 0;
       cbOllamaModel.ItemIndex := Index;
       If (Index < 0) And (Selected <> '') Then
        cbOllamaModel.Text := Selected;
       If cbOllamaModel.Items.Count = 0 Then
        lHelp.Caption := Tr('Ollama: brak zainstalowanych modeli.')
       Else If (Index < 0) And (Selected <> '') Then
        lHelp.Caption := Tr('Ollama: zapisany model nie wystepuje na liscie serwera.')
       Else
        lHelp.Caption := Tr('Ollama: dostepne modele: ') + IntToStr(cbOllamaModel.Items.Count) + '.';
      End
    Else
     lHelp.Caption := Tr('Ollama: adres zmieniony; odswiez liste modeli.');
   Finally
    FreeAndNil(fModelsThread);
   End;
   If fRefreshPending Then
    RefreshOllamaModels(Self);
  End;

 Procedure ReadAnalysisWindow(Config : TMemIniFile; Landing : Boolean; Out BeforeSeconds, AfterSeconds : Integer);
  Var
   Prefix        : String;
   DefaultBefore : Integer;
  Begin
   Prefix        := 'takeoff_';
   DefaultBefore := 60;
   If Landing Then
    Begin
     Prefix        := 'landing_';
     DefaultBefore := 180;
    End;
   BeforeSeconds := EnsureRange(Config.ReadInteger('ai', Prefix + 'before_seconds', Config.ReadInteger('ai', 'context_before_seconds', DefaultBefore)), 1, 300);
   AfterSeconds  := EnsureRange(Config.ReadInteger('ai', Prefix + 'after_seconds', Config.ReadInteger('ai', 'context_after_seconds', 30)), 1, 300);
  End;

 Procedure TfrmSettings.Load(Config : TMemIniFile);
  Var
   BeforeSeconds : Integer;
   AfterSeconds  : Integer;
   I, Row : Integer; Source, Target : String;
  Begin
   UnitsEditor.Strings.Clear;
   For I := 0 To DisplayUnitCount-1 Do
    Begin
     Source := SourceDisplayUnit(I);
     Target := Config.ReadString('display_units', Source, Source);
     Row := UnitsEditor.InsertRow(Source, Target, True);
     UnitsEditor.ItemProps[Row-1].EditStyle := esPickList;
     UnitsEditor.ItemProps[Row-1].ReadOnly := False;
     UnitsEditor.ItemProps[Row-1].PickList.CommaText := DisplayUnitOptions(Source);
    End;
   cbLanguage.ItemIndex := 0;
   If SameText(Config.ReadString('ui', 'language', 'pl-PL'), 'en-US') Then cbLanguage.ItemIndex := 1;
   If SameText(Config.ReadString('ui', 'language', 'pl-PL'), 'de-DE') Then cbLanguage.ItemIndex := 2;
   If SameText(Config.ReadString('ui', 'language', 'pl-PL'), 'es-ES') Then cbLanguage.ItemIndex := 3;
   ReadAnalysisWindow(Config, False, BeforeSeconds, AfterSeconds);
   seBefore.Value := BeforeSeconds;
   seAfter.Value  := AfterSeconds;
   ReadAnalysisWindow(Config, True, BeforeSeconds, AfterSeconds);
   seLandingBefore.Value := BeforeSeconds;
   seLandingAfter.Value  := AfterSeconds;
   cbProvider.ItemIndex  := 0;
   If SameText(Config.ReadString('ai', 'provider', 'codex'), 'gemini') Then
    cbProvider.ItemIndex := 1;
   If SameText(Config.ReadString('ai', 'provider', 'codex'), 'ollama') Then
    cbProvider.ItemIndex := 2;
   seOllamaContext.Value := EnsureRange(Config.ReadInteger('ai', 'ollama_context_tokens', 32768), 2048, 262144);
   eOllamaURL.Text       := Config.ReadString('ai', 'ollama_url', 'http://localhost:11434');
   cbOllamaModel.Text    := Config.ReadString('ai', 'ollama_model', '');
   eCodexPath.Text       := Config.ReadString('ai', 'codex_path', '');
   eCodexModel.Text      := Config.ReadString('ai', 'codex_model', '');
   eGeminiModel.Text     := Config.ReadString('ai', 'model', 'gemma-4-31b-it');
   eGeminiKey.Text       := Config.ReadString('ai', 'gemini_api_key', '');
   seTimeout.Value := EnsureRange(Config.ReadInteger('ai', 'timeout_seconds', 180), 1, 1800);
   ProviderPages.ActivePageIndex := cbProvider.ItemIndex;
  End;

 Procedure TfrmSettings.Save(Config : TMemIniFile);
  Var I : Integer;
  Begin
   For I := 1 To UnitsEditor.RowCount-1 Do
    SaveDisplayUnit(Config, UnitsEditor.Cells[0,I], UnitsEditor.Cells[1,I]);
   LoadDisplayUnits(Config);
   If cbProvider.ItemIndex = 2 Then
    Config.WriteString('ai', 'provider', 'ollama')
   Else If cbProvider.ItemIndex = 1 Then
    Config.WriteString('ai', 'provider', 'gemini')
   Else
    Config.WriteString('ai', 'provider', 'codex');
   Config.WriteInteger('ai', 'ollama_context_tokens', seOllamaContext.Value);
   Config.WriteString('ai', 'ollama_url', Trim(eOllamaURL.Text));
   Config.WriteString('ai', 'ollama_model', Trim(cbOllamaModel.Text));
   Config.WriteString('ai', 'codex_path', Trim(eCodexPath.Text));
   Config.WriteString('ai', 'codex_model', Trim(eCodexModel.Text));
   Config.WriteString('ai', 'model', Trim(eGeminiModel.Text));
   Config.WriteString('ai', 'gemini_api_key', Trim(eGeminiKey.Text));
   Config.WriteInteger('ai', 'timeout_seconds', seTimeout.Value);
   Config.WriteInteger('ai', 'takeoff_before_seconds', seBefore.Value);
   Config.WriteInteger('ai', 'takeoff_after_seconds', seAfter.Value);
   Config.WriteInteger('ai', 'landing_before_seconds', seLandingBefore.Value);
   Config.WriteInteger('ai', 'landing_after_seconds', seLandingAfter.Value);
   Case cbLanguage.ItemIndex Of
    1: Config.WriteString('ui', 'language', 'en-US');
    2: Config.WriteString('ui', 'language', 'de-DE');
    3: Config.WriteString('ui', 'language', 'es-ES');
    Else Config.WriteString('ui', 'language', 'pl-PL');
   End;
   Config.UpdateFile;
   SetLanguage(Config.ReadString('ui', 'language', 'pl-PL'));
  End;

End.
