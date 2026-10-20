{$StackFrames On}
Unit frmMainU;

Interface

 Uses
  UIFontsU, Vcl.XPMan, Vcl.Menus, LocalizationU, i18nLocalizer, Winapi.Windows, System.SysUtils, System.Classes,
  System.IOUtils, System.Math, System.IniFiles, System.Generics.Collections, Vcl.Forms,
  Vcl.Controls, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.CheckLst, Vcl.Grids,
  Vcl.DBGrids, Vcl.Dialogs, Vcl.Samples.Spin, Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param,
  System.UITypes, System.JSON, Vcl.Graphics, Vcl.Imaging.pngimage,
  FlightDatabaseU, RecorderWorkerU, FlightMapU, FlightChartsU, FlightTelemetryU,
  FlightAnalysisU, frmReportU, AppLogU, FlightPlanU, frmSettingsU, AnalysisContextU, frmSimBriefFrameU,
  i18nCore, System.Actions, Vcl.ActnList, System.ImageList, Vcl.ImgList,
  Vcl.ToolWin, fraMapU, fraGraphU, frmViewWindowU, frmAssignGroupU;

 Type
  TfrmMain = Class(TLocalizedForm)
   Published
    aAbout             : TAction;
    aAnalysisLanding   : TAction;
    aAnalysisLiftoff   : TAction;
    aArabic            : TAction;
    aAssign            : TAction;
    aAuto              : TAction;
    aBelarusian        : TAction;
    aChinese           : TAction;
    aClose             : TAction;
    aCroatian          : TAction;
    ActionList         : TActionList;
    aCzech             : TAction;
    aDanish            : TAction;
    aDelete            : TAction;
    aDeleteGroup       : TAction;
    aDutch             : TAction;
    aEnglish           : TAction;
    aEnglishGB         : TAction;
    aExportKML         : TAction;
    aFinnish           : TAction;
    aFit               : TAction;
    aFrench            : TAction;
    aFrenchCA          : TAction;
    aGerman            : TAction;
    aGermanAT          : TAction;
    aGermanCH          : TAction;
    aGreek             : TAction;
    aHebrew            : TAction;
    aHelp              : TAction;
    aHindi             : TAction;
    aImportPlan        : TAction;
    aIndonesian        : TAction;
    aItalian           : TAction;
    aJapanese          : TAction;
    aLangAuto          : TAction;
    aMetar             : TAction;
    aNewGroup          : TAction;
    aNorwegian         : TAction;
    aOpen              : TAction;
    aOverview          : TAction;
    aPolish            : TAction;
    aPortuguese        : TAction;
    aPortugueseBR      : TAction;
    AppTranslator      : TTranslator;
    aRefresh           : TAction;
    aRenameGroup       : TAction;
    aRussian           : TAction;
    aSavePNGMap        : TAction;
    aSettings          : TAction;
    aSlovak            : TAction;
    aSpanish           : TAction;
    aStart             : TAction;
    aStop              : TAction;
    aSwedish           : TAction;
    aTiles             : TAction;
    aTripInfo          : TAction;
    aTurkish           : TAction;
    aUkrainian         : TAction;
    aVietnamese        : TAction;
    btnAnalysisLiftoff : TToolButton;
    btnAssign          : TToolButton;
    btnAuto            : TToolButton;
    btnDelete          : TToolButton;
    btnDeleteGroup     : TToolButton;
    btnExit            : TToolButton;
    btnExportKML       : TToolButton;
    btnFit             : TToolButton;
    btnLandingAnalysis : TToolButton;
    btnMetar           : TToolButton;
    btnNewGroup        : TToolButton;
    btnOpen            : TToolButton;
    btnOverview        : TToolButton;
    btnRefresh         : TToolButton;
    btnRenameGroup     : TToolButton;
    btnSavePNGMap      : TToolButton;
    btnSettings        : TToolButton;
    btnStart           : TToolButton;
    btnStop            : TToolButton;
    btnTiles           : TToolButton;
    btnTripInfo        : TToolButton;
    cbGroup            : TComboBox;
    CenterPanel        : TPanel;
    ContactGrid        : TDBGrid;
    ContactsPage       : TTabSheet;
    CursorLabel        : TLabel;
    DataGrid           : TStringGrid;
    DataTabs           : TPageControl;
    EventGrid          : TDBGrid;
    EventsPage         : TTabSheet;
    GraphPanel         : TPanel;
    GroupPanel         : TPanel;
    GroupToolbarPanel  : TPanel;
    HistoryGrid        : TDBGrid;
    ImageList          : TImageList;
    ImageListSmall     : TImageList;
    LeftPanel          : TPanel;
    MainMenu           : TMainMenu;
    MapPanel           : TPanel;
    miAbout            : TMenuItem;
    miAnalysis         : TMenuItem;
    miArabic           : TMenuItem;
    miAssign           : TMenuItem;
    miAuto             : TMenuItem;
    miBelarusian       : TMenuItem;
    miChartsConfigure  : TMenuItem;
    miChinese          : TMenuItem;
    miClose            : TMenuItem;
    miCroatian         : TMenuItem;
    miCzech            : TMenuItem;
    miDanish           : TMenuItem;
    miDeleteGroup      : TMenuItem;
    miDeleteTrip       : TMenuItem;
    miDutch            : TMenuItem;
    miEnglish          : TMenuItem;
    miEnglishGB        : TMenuItem;
    miExport           : TMenuItem;
    miFile             : TMenuItem;
    miFinnish          : TMenuItem;
    miFit              : TMenuItem;
    miFrench           : TMenuItem;
    miFrenchCA         : TMenuItem;
    miFullView         : TMenuItem;
    miGerman           : TMenuItem;
    miGermanAT         : TMenuItem;
    miGermanCH         : TMenuItem;
    miGraphWindow      : TMenuItem;
    miGreek            : TMenuItem;
    miGroups           : TMenuItem;
    miHebrew           : TMenuItem;
    miHelp             : TMenuItem;
    miHelpContents     : TMenuItem;
    miHindi            : TMenuItem;
    miImport           : TMenuItem;
    miIndonesian       : TMenuItem;
    miItalian          : TMenuItem;
    miJapanese         : TMenuItem;
    miLanding          : TMenuItem;
    miLangAuto         : TMenuItem;
    miLanguage         : TMenuItem;
    miMapWindow        : TMenuItem;
    miMetar            : TMenuItem;
    miNewGroup         : TMenuItem;
    miNorwegian        : TMenuItem;
    miOpen             : TMenuItem;
    miOverview         : TMenuItem;
    miPolish           : TMenuItem;
    miPortuguese       : TMenuItem;
    miPortugueseBR     : TMenuItem;
    miRecording        : TMenuItem;
    miRefresh          : TMenuItem;
    miRenameGroup      : TMenuItem;
    miRussian          : TMenuItem;
    miSaveMap          : TMenuItem;
    miSeparator1       : TMenuItem;
    miSettings         : TMenuItem;
    miSlovak           : TMenuItem;
    miSpanish          : TMenuItem;
    miStart            : TMenuItem;
    miStop             : TMenuItem;
    miSwedish          : TMenuItem;
    miTakeoff          : TMenuItem;
    miTiles            : TMenuItem;
    miTools            : TMenuItem;
    miTripInfo         : TMenuItem;
    miTurkish          : TMenuItem;
    miUkrainian        : TMenuItem;
    miVietnamese       : TMenuItem;
    miView             : TMenuItem;
    miZoomIn           : TMenuItem;
    miZoomOut          : TMenuItem;
    mPlan              : TMemo;
    OpenDialog         : TOpenDialog;
    PlanDialog         : TOpenDialog;
    PlanPage           : TTabSheet;
    RightPanel         : TPanel;
    SaveDialog         : TSaveDialog;
    seInterval         : TSpinEdit;
    SimBriefPage       : TTabSheet;
    SplitLeft          : TSplitter;
    SplitMap           : TSplitter;
    SplitRight         : TSplitter;
    StatusBar1         : TStatusBar;
    Timeline           : TTrackBar;
    Timer              : TTimer;
    ToolBar1           : TToolBar;
    ToolBar3           : TToolBar;
    ToolBar4           : TToolBar;
    ToolBar5           : TToolBar;
    ToolButton4        : TToolButton;
    ToolButton6        : TToolButton;
    ToolButton7        : TToolButton;
    ToolButton8        : TToolButton;
    ToolButton10       : TToolButton;
    ToolButton12       : TToolButton;
    ToolButton15       : TToolButton;
    ValuesPage         : TTabSheet;
    ViewPan            : TTrackBar;
    Function AppHelp(Command : Word; Data : THelpEventData; Var CallHelp : Boolean) : Boolean;
    Procedure aAboutExecute(Sender : TObject);
    Procedure aAnalysisExecute(Sender : TObject);
    Procedure aAssignExecute(Sender : TObject);
    Procedure aAutoExecute(Sender : TObject);
    Procedure aChartsConfigureExecute(Sender : TObject);
    Procedure aCloseExecute(Sender : TObject);
    Procedure ActionsUpdate(Action : TBasicAction; Var Handled : Boolean);
    Procedure aDeleteExecute(Sender : TObject);
    Procedure aDeleteGroupExecute(Sender : TObject);
    Procedure aExportKMLExecute(Sender : TObject);
    Procedure aFitExecute(Sender : TObject);
    Procedure aGraphWindowExecute(Sender : TObject);
    Procedure aHelpExecute(Sender : TObject);
    Procedure aImportPlanExecute(Sender : TObject);
    Procedure aMapWindowExecute(Sender : TObject);
    Procedure aMetarExecute(Sender : TObject);
    Procedure aNewGroupExecute(Sender : TObject);
    Procedure aOpenExecute(Sender : TObject);
    Procedure aOverviewExecute(Sender : TObject);
    Procedure ApplyChartSelection;
    Procedure aRefreshExecute(Sender : TObject);
    Procedure aRenameGroupExecute(Sender : TObject);
    Procedure aSavePNGMapExecute(Sender : TObject);
    Procedure aSettingsExecute(Sender : TObject);
    Procedure aStartExecute(Sender : TObject);
    Procedure aStopExecute(Sender : TObject);
    Procedure aTilesExecute(Sender : TObject);
    Procedure aTripInfoExecute(Sender : TObject);
    Procedure ChangeLanguage(Sender : TObject);
    Procedure ChartsWheel(Sender : TObject; Shift : TShiftState; WheelDelta : Integer; MousePos : TPoint; Var Handled : Boolean);
    Procedure ChartViewChanged(Sender : TObject);
    Procedure FinishAnalysis;
    Procedure FormCreate(Sender : TObject);
    Procedure FormDestroy(Sender : TObject);
    Procedure FormResize(Sender : TObject);
    Procedure FrameMenuOpen(Sender : TObject);
    Procedure GroupChanged(Sender : TObject);
    Procedure LanguageChanged(Sender : TObject);
    Procedure LanguageMenuDraw(Sender : TObject; ACanvas : TCanvas; ARect : TRect; Selected : Boolean);
    Procedure LanguageMenuMeasure(Sender : TObject; ACanvas : TCanvas; Var Width, Height : Integer);
    Procedure PanChart(Sender : TObject);
    Procedure SelectTrip(Sender : TObject);
    Procedure Tick(Sender : TObject);
    Procedure TimelineChange(Sender : TObject);
    Procedure UpdateLanguageActions;
    Procedure ValueParameterHint(Sender : TObject; Shift : TShiftState; X, Y : Integer);
    Procedure ZoomChart(Sender : TObject);
   Private
    fMapFrame      : TfraMap;
    fGraphFrame    : TfraGraph;
    fMapWindow     : TfrmViewWindow;
    fGraphWindow   : TfrmViewWindow;
    fClosing       : Boolean;
    fDockMapHeight : Integer;
    fSimBrief      : TfraSimBrief;
    fDB            : TFlightDatabase;
    fRecorder      : TRecorderWorker;
    fHistory       : TFDQuery;
    fSource        : TDataSource;
    fPlot          : TTripPlot;
    fMap           : TFlightMap;
    fCharts        : TFlightCharts;
    fConfig        : TMemIniFile;
    fRoot          : String;
    fPlanShown     : String;
    fRefresh       : UInt64;
    fBusy          : Boolean;
    fAnalysis      : TAnalysisThread;
    fSelected      : TStringList;
    fEvents        : TFDQuery;
    fContacts      : TFDQuery;
    fEventSource   : TDataSource;
    fContactSource : TDataSource;
    Function GetMapWindow : TAction;
    Function GetZoomIn : TAction;
    Function GetZoomOut : TAction;
    Function GetFullView : TAction;
    Function GetChartsConfigure : TAction;
    Function GetGraphWindow : TAction;
    Procedure MapReturned(Sender : TObject);
    Procedure GraphReturned(Sender : TObject);
    Procedure UpdateViewLayout;
    Function GetMapHost : TPanel;
    Function GetChartsHost : TScrollBox;
    Procedure AppException(Sender : TObject; E : Exception);
    Procedure ResetPanelLayout(Sender : TObject);
    Procedure OpenDatabase(Const Path : String);
    Procedure RefreshHistory;
    Procedure CursorMove(Sender : TObject; Index : Integer);
    Procedure UpdatePoint(Index : Integer);
   Public
    Property aGraphWindow     : TAction Read GetGraphWindow;
    Property aChartsConfigure : TAction Read GetChartsConfigure;
    Property aFullView        : TAction Read GetFullView;
    Property aZoomOut         : TAction Read GetZoomOut;
    Property aZoomIn          : TAction Read GetZoomIn;
    Property aMapWindow       : TAction Read GetMapWindow;
    Property MapFrame         : TfraMap Read fMapFrame;
    Property GraphFrame       : TfraGraph Read fGraphFrame;
    Property MapWindow        : TfrmViewWindow Read fMapWindow;
    Property GraphWindow      : TfrmViewWindow Read fGraphWindow;
    Property MapHost          : TPanel Read GetMapHost;
    Property ChartsHost       : TScrollBox Read GetChartsHost;
  End;

 Var
  frmMain : TfrmMain;

Implementation

 {$R *.dfm}

 Uses
  frmTripInfoU, frmChartsConfigureU, frmAboutU, AppHelpU, ParameterNamesU, VersionU;

 Function TfrmMain.GetMapWindow : TAction;
  Begin
   If fMapFrame <> Nil Then
    Result := fMapFrame.aMapWindow
   Else
    Result := Nil;
  End;

 Function TfrmMain.GetZoomIn : TAction;
  Begin
   If fGraphFrame <> Nil Then
    Result := fGraphFrame.aZoomIn
   Else
    Result := Nil;
  End;

 Function TfrmMain.GetZoomOut : TAction;
  Begin
   If fGraphFrame <> Nil Then
    Result := fGraphFrame.aZoomOut
   Else
    Result := Nil;
  End;

 Function TfrmMain.GetFullView : TAction;
  Begin
   If fGraphFrame <> Nil Then
    Result := fGraphFrame.aFullView
   Else
    Result := Nil;
  End;

 Function TfrmMain.GetChartsConfigure : TAction;
  Begin
   If fGraphFrame <> Nil Then
    Result := fGraphFrame.aChartsConfigure
   Else
    Result := Nil;
  End;

 Function TfrmMain.GetGraphWindow : TAction;
  Begin
   If fGraphFrame <> Nil Then
    Result := fGraphFrame.aGraphWindow
   Else
    Result := Nil;
  End;

 Procedure TfrmMain.AppException(Sender : TObject; E : Exception);
  Procedure LogStackTrace(E : Exception);
   Begin
    If Not E.StackTrace.IsEmpty Then
     Log(0, 'StackTrace = [' + #13#10 + E.StackTrace + #13#10 + ')');
   End;

  Begin
   Log(0, Format('MSFS24-FDR (ver. %s): %s at %p: %s', [VersionInfo.FileVersion, E.ClassName, ExceptAddr, E.Message]));
   LogStackTrace(E);
   Application.ShowException(E);
  End;

 Procedure TfrmMain.aChartsConfigureExecute(Sender : TObject);
  Var
   Dialog : TfrmChartsConfigure;
  Begin
   If (fPlot = Nil) Or (fPlot.TripID <= 0) Then
    Exit;
   If fGraphWindow <> Nil Then
    Dialog := TfrmChartsConfigure.Create(fGraphWindow)
   Else
    Dialog := TfrmChartsConfigure.Create(Self);
   Try
    Dialog.Configure(fPlot.Labels, fSelected);
    If Dialog.ShowModal = mrOk Then
     Begin
      Dialog.CopySelectionTo(fSelected);
      ApplyChartSelection;
      fConfig.WriteString('charts', 'parameters', fSelected.DelimitedText);
      fConfig.UpdateFile;
     End;
   Finally
    Dialog.Free;
   End;
  End;

 Procedure TfrmMain.aAutoExecute(Sender : TObject);
  Begin
   If Assigned(fRecorder) Then
    fRecorder.Configure(seInterval.Value, aAuto.Checked);
  End;

 Procedure TfrmMain.ActionsUpdate(Action : TBasicAction; Var Handled : Boolean);
  Var
   HasPlot, HasTrip, HasGroup : Boolean;
  Begin
   If (Action = Nil) Or (csLoading In ComponentState) Or (fConfig = Nil) Then
    Exit;
   If (Action = aMapWindow) Or (Action = aGraphWindow) Then
    Begin
     If Action = aMapWindow Then
      Begin
       aMapWindow.Checked := fMapWindow <> Nil;
       If aMapWindow.Checked Then
        aMapWindow.Hint := Tr('Przywróć widok w głównym oknie')
       Else
        aMapWindow.Hint := Tr('Otwórz mapę w osobnym oknie');
      End
     Else
      Begin
       aGraphWindow.Checked := fGraphWindow <> Nil;
       If aGraphWindow.Checked Then
        aGraphWindow.Hint := Tr('Przywróć widok w głównym oknie')
       Else
        aGraphWindow.Hint := Tr('Otwórz wykresy w osobnym oknie');
      End;
     Handled := True;
     Exit;
    End;
   HasPlot  := Assigned(fPlot) And (fPlot.TripID > 0) And (fPlot.Points.Count > 0);
   HasTrip  := Assigned(fHistory) And fHistory.Active And Not fHistory.IsEmpty;
   HasGroup := (cbGroup.ItemIndex >= 0) And (NativeInt(cbGroup.Items.Objects[cbGroup.ItemIndex]) > 0);
   If (Action = aAnalysisLiftoff) Or (Action = aAnalysisLanding) Then
    TAction(Action).Enabled := HasTrip And Not Assigned(fAnalysis)
   Else If (Action = aTripInfo) Or (Action = aAssign) Or (Action = aDelete) Or (Action = aMetar) Or (Action = aImportPlan) Then
    TAction(Action).Enabled := HasTrip
   Else If (Action = aRenameGroup) Or (Action = aDeleteGroup) Then
    TAction(Action).Enabled := HasGroup
   Else If Action = aSavePNGMap Then
    TAction(Action).Enabled := Assigned(fPlot) And (fPlot.Points.Count > 0)
   Else If Action = aOpen Then
    TAction(Action).Enabled := Not Assigned(fAnalysis);
   If (Action = aChartsConfigure) Or (Action = aZoomIn) Or (Action = aZoomOut) Or (Action = aFullView) Or (Action = aExportKML) Then
    Begin
     TAction(Action).Enabled := HasPlot;
     Handled                 := True;
    End;
  End;

 Procedure TfrmMain.aCloseExecute(Sender : TObject);
  Begin
   Close;
  End;

 Procedure TfrmMain.LanguageChanged(Sender : TObject);
  Var
   I : Integer;
  Begin
   If Assigned(fCharts) Then
    Begin
     fCharts.Hint := Tr('Przeciaganie: przesuwanie czasu. Shift + przeciaganie: zoom zakresu. Ctrl + kolko: zoom. Dwuklik: calosc.');
     fCharts.Invalidate;
    End;
   If Assigned(fMap) Then
    fMap.Invalidate;
   If Assigned(fPlot) Then
    For I := 0 To fPlot.Labels.Count - 1 Do
     If I + 1 < DataGrid.RowCount Then
      DataGrid.Cells[0, I + 1] := ParameterCaption(fPlot.Labels[I]);

  End;

 Procedure TfrmMain.LanguageMenuMeasure(Sender : TObject; ACanvas : TCanvas; Var Width, Height : Integer);
  Var
   Item : TMenuItem;
   A    : TAction;
  Begin
   Item              := Sender As TMenuItem;
   A                 := Item.Action As TAction;
   ACanvas.Font.Name := LocaleFontName(UILanguageLocales[A.Tag - 1]);
   Width             := ACanvas.TextWidth(UILanguageNames[A.Tag - 1]) + 64;
   Height            := Max(28, ACanvas.TextHeight(UILanguageNames[A.Tag - 1]) + 8);
  End;

 Procedure TfrmMain.LanguageMenuDraw(Sender : TObject; ACanvas : TCanvas; ARect : TRect; Selected : Boolean);
  Var
   Item       : TMenuItem;
   A          : TAction;
   Text, Code : String;
   Flags      : Cardinal;
  Begin
   Item := Sender As TMenuItem;
   A    := Item.Action As TAction;
   Code := UILanguageLocales[A.Tag - 1];
   If Selected Then
    Begin
     ACanvas.Brush.Color := clHighlight;
     ACanvas.Font.Color  := clHighlightText;
    End
   Else
    Begin
     ACanvas.Brush.Color := clMenu;
     ACanvas.Font.Color  := clMenuText;
    End;
   ACanvas.FillRect(ARect);
   ACanvas.Font.Name := LocaleFontName(Code);
   If Item.Checked Then
    ACanvas.TextOut(ARect.Left + 5, ARect.Top + 4, #$2713);
   If Assigned(MainMenu.Images) And (Item.ImageIndex >= 0) And (Item.ImageIndex < MainMenu.Images.Count) Then
    MainMenu.Images.Draw(ACanvas, ARect.Left + 18, ARect.Top + (ARect.Height - MainMenu.Images.Height) Div 2, Item.ImageIndex);
   Inc(ARect.Left, 40);
   Text  := UILanguageNames[A.Tag - 1];
   Flags := DT_SINGLELINE Or DT_VCENTER Or DT_NOPREFIX;
   If (Copy(Code, 1, 2) = 'ar') Or (Copy(Code, 1, 2) = 'he') Then
    Flags := Flags Or DT_RTLREADING;
   DrawText(ACanvas.Handle, PChar(Text), Length(Text), ARect, Flags);
  End;

 Procedure TfrmMain.UpdateLanguageActions;
  Var
   I      : Integer;
   Action : TAction;
   Item : TMenuItem;
  Begin
   miLanguage.AutoHotkeys := maManual;
   For I := 0 To ActionList.ActionCount - 1 Do
    If ActionList.Actions[I] Is TAction Then
     Begin
      Action := TAction(ActionList.Actions[I]);
      If Action = aLangAuto Then
       Action.Checked := LanguagePreference = 'auto'
      Else If (Action.Category = 'Language') And (Action.Tag > 0) And (Action.Tag <= UILanguageCount) Then
       Begin
        Action.Caption := UILanguageNames[Action.Tag - 1];
        Action.Checked := (LanguagePreference <> 'auto') And (Language = UILanguageLocales[Action.Tag - 1]);
       End;
     End;
   For I := 0 To miLanguage.Count-1 Do
    Begin
     Item := miLanguage.Items[I];
     If (Item.Action Is TAction) And (Item.Action.Tag > 0) And (Item.Action.Tag <= UILanguageCount) Then
      Item.Caption := UILanguageNames[Item.Action.Tag-1];
    End;
  End;

 Procedure TfrmMain.ChangeLanguage(Sender : TObject);
  Var
   Action : TAction;
  Begin
   If Sender Is TMenuItem Then
    Action := TMenuItem(Sender).Action As TAction
   Else If Sender Is TAction Then
    Action := TAction(Sender)
   Else
    Exit;
   If Action = aLangAuto Then
    SetLanguage('auto')
   Else If (Action.Tag > 0) And (Action.Tag <= UILanguageCount) Then
    SetLanguage(UILanguageLocales[Action.Tag - 1])
   Else
    Exit;
   fConfig.WriteString('ui', 'language', LanguagePreference);
   fConfig.UpdateFile;
   UpdateLanguageActions;
   fPlanShown := '';
   If Assigned(fSimBrief) Then
    fSimBrief.Retranslate;
  End;

 Procedure TfrmMain.ValueParameterHint(Sender : TObject; Shift : TShiftState; X, Y : Integer);
  Var
   Col, Row : Integer;
   Name     : String;
  Begin
   DataGrid.MouseToCell(X, Y, Col, Row);
   If Assigned(fPlot) And (Row > 0) And (Row <= fPlot.Labels.Count) Then
    Begin
     Name          := fPlot.Labels[Row - 1];
     DataGrid.Hint := ParameterCaption(Name) + sLineBreak + Name;
    End
   Else
    DataGrid.Hint := '';
  End;

 Procedure TfrmMain.aAboutExecute(Sender : TObject);
  Var
   Dialog : TfrmAbout;
  Begin
   Dialog := TfrmAbout.Create(Self);
   Try
    Dialog.ShowModal;
   Finally
    Dialog.Free;
   End;
  End;

 Procedure TfrmMain.aHelpExecute(Sender : TObject);
  Begin
   ShowAppHelp(Screen.ActiveControl);
  End;

 Function TfrmMain.AppHelp(Command : Word; Data : THelpEventData; Var CallHelp : Boolean) : Boolean;
  Begin
   Result := RouteAppHelp(Command, Data, CallHelp);
  End;

 Procedure TfrmMain.FrameMenuOpen(Sender : TObject);
  Begin
   miMapWindow.Visible       := miMapWindow.Action <> Nil;
   miGraphWindow.Visible     := miGraphWindow.Action <> Nil;
   miZoomIn.Visible          := miZoomIn.Action <> Nil;
   miZoomOut.Visible         := miZoomOut.Action <> Nil;
   miFullView.Visible        := miFullView.Action <> Nil;
   miChartsConfigure.Visible := miChartsConfigure.Action <> Nil;
  End;

 Procedure TfrmMain.FormCreate(Sender : TObject);
  Begin
   aAnalysisLanding.Hint   := Tr('Shift + klik: nowy raport po polsku');
   aAnalysisLiftoff.Hint   := aAnalysisLanding.Hint;
   Application.OnException := AppException;
   Application.OnHelp      := AppHelp;
   fRoot                   := ExtractFilePath(ParamStr(0));
   fConfig                 := TMemIniFile.Create(TPath.Combine(fRoot, 'settings.ini'), TEncoding.UTF8);
   LoadDisplayUnits(fConfig);
   SetLanguage(fConfig.ReadString('ui', 'language', 'auto'));

   UpdateLanguageActions;
   fSimBrief        := TfraSimBrief.Create(Self);
   fSimBrief.Parent := SimBriefPage;
   fSimBrief.Align  := alClient;
   fSimBrief.Configure(fConfig);
   fSelected                 := TStringList.Create;
   fSelected.StrictDelimiter := True;
   fSelected.Delimiter       := ',';
   fSelected.DelimitedText   := fConfig.ReadString('charts', 'parameters', 'plane_altitude,vertical_speed,turb_eng_n1 #1');
   LeftPanel.Width           := EnsureRange(fConfig.ReadInteger('layout', 'left_width', 300), 180, Max(180, ClientWidth Div 2 - 100));
   RightPanel.Width          := EnsureRange(fConfig.ReadInteger('layout', 'right_width', 300), 180, Max(180, ClientWidth Div 2 - 100));
   fDockMapHeight            := EnsureRange(fConfig.ReadInteger('layout', 'map_height', 390), 100, Max(100, CenterPanel.Height - 180));
   MapPanel.Height           := fDockMapHeight;
   StartLog(TPath.Combine(fRoot, 'msfs_fdr_debug.log'), fConfig.ReadString('logging', 'verbose', 'INFO'));
   Log(2, 'Delphi VCL recorder started: ' + ParamStr(0));
   If (GetModuleHandle('GTIII-OSD64.dll') <> 0) Or (GetModuleHandle('GTIII-OSD64-VK.dll') <> 0) Then
    Log(1, 'ASUS GPU Tweak III OSD injected into recorder process');
   seInterval.Value := EnsureRange(fConfig.ReadInteger('recording', 'sample_interval_ms', 500), 1, 60000);
   aAuto.Checked    := fConfig.ReadBool('recording', 'enabled', True);
   fMapFrame        := TfraMap.Create(Self);
   fMapFrame.Parent := MapPanel;
   fMapFrame.Align  := alClient;
   fMapFrame.BindActions(aMapWindowExecute, ActionsUpdate);
   miMapWindow.Action := aMapWindow;
   fMap               := fMapFrame.Map;
   aTiles.Checked     := fConfig.ReadBool('map', 'online_tiles', aTiles.Checked);
   fMap.TilesEnabled  := aTiles.Checked;
   fGraphFrame        := TfraGraph.Create(Self);
   fGraphFrame.Parent := GraphPanel;
   fGraphFrame.Align  := alClient;
   fGraphFrame.BindActions(aChartsConfigureExecute, aGraphWindowExecute, ActionsUpdate);
   miZoomIn.Action          := aZoomIn;
   miZoomOut.Action         := aZoomOut;
   miFullView.Action        := aFullView;
   miChartsConfigure.Action := aChartsConfigure;
   miGraphWindow.Action     := aGraphWindow;
   FrameMenuOpen(Self);
   fCharts                := fGraphFrame.Charts;
   fCharts.Hint           := Tr('Przeciaganie: przesuwanie czasu. Shift + przeciaganie: zoom zakresu. Ctrl + kolko: zoom. Dwuklik: calosc.');
   fCharts.ShowHint       := True;
   fCharts.OnCursor       := CursorMove;
   fCharts.OnViewChange   := ChartViewChanged;
   fSource                := TDataSource.Create(Self);
   HistoryGrid.DataSource := fSource;
   fSource.OnDataChange   := Nil;
   fEventSource           := TDataSource.Create(Self);
   fContactSource         := TDataSource.Create(Self);
   EventGrid.DataSource   := fEventSource;
   ContactGrid.DataSource := fContactSource;
   OpenDatabase(TPath.Combine(fRoot, 'flight_data.db'));
  End;

 Procedure TfrmMain.FormDestroy(Sender : TObject);
  Begin
   fClosing           := True;
   Application.OnHelp := Nil;
   FreeAndNil(fMapWindow);
   FreeAndNil(fGraphWindow);
   If Assigned(Timer) Then
    Timer.Enabled := False;
   If Assigned(fAnalysis) Then
    Begin
     fAnalysis.Terminate;
     fAnalysis.WaitFor;
     FreeAndNil(fAnalysis);
    End;
   If Assigned(fConfig) Then
    Begin
     fConfig.WriteInteger('recording', 'sample_interval_ms', seInterval.Value);
     fConfig.WriteBool('recording', 'enabled', aAuto.Checked);
     fConfig.WriteBool('map', 'online_tiles', aTiles.Checked);
     If Assigned(fSelected) Then
      fConfig.WriteString('charts', 'parameters', fSelected.DelimitedText);
     fConfig.WriteInteger('layout', 'left_width', LeftPanel.Width);
     fConfig.WriteInteger('layout', 'right_width', RightPanel.Width);
     If MapPanel.Align = alTop Then
      fDockMapHeight := MapPanel.Height;
     fConfig.WriteInteger('layout', 'map_height', fDockMapHeight);
     fConfig.UpdateFile;
    End;
   If Assigned(fMap) Then
    fMap.SetData(Nil);
   If Assigned(fCharts) Then
    fCharts.SetData(Nil);
   FreeAndNil(fSimBrief);
   fPlot.Free;
   fRecorder.Free;
   fEvents.Free;
   fContacts.Free;
   fHistory.Free;
   fDB.Free;
   fConfig.Free;
   fSelected.Free;
  End;

 Procedure TfrmMain.FormResize(Sender : TObject);
  Begin
   StatusBar1.Panels.Items[0].Width := Self.ClientWidth;
  End;

 Procedure TfrmMain.OpenDatabase(Const Path : String);
  Begin
   fSimBrief.SetTrip(Nil, 0);
   fMap.SetData(Nil);
   fCharts.SetData(Nil);
   FreeAndNil(fPlot);
   fSource.DataSet := Nil;
   FreeAndNil(fHistory);
   fEventSource.DataSet   := Nil;
   fContactSource.DataSet := Nil;
   FreeAndNil(fEvents);
   FreeAndNil(fContacts);
   FreeAndNil(fRecorder);
   FreeAndNil(fDB);
   fDB       := TFlightDatabase.Create(Path, TPath.Combine(fRoot, 'sqlite3.dll'));
   fRecorder := TRecorderWorker.Create(Path, fRoot, fConfig.ReadString('flightplan', 'fallback_pln', ''), IfThen(fConfig.ReadBool('flightplan', 'bridge_enabled', True), EnsureRange(fConfig.ReadInteger('flightplan', 'bridge_port', 19787), 1024, 65535), 0)
    {$IFDEF PORT_TEST}, False{$ENDIF});
   fRecorder.Configure(seInterval.Value, aAuto.Checked);
   fRecorder.Start;
   fHistory            := TFDQuery.Create(Nil);
   fHistory.Connection := fDB.Connection;
   fSource.DataSet     := fHistory;
   RefreshHistory;
  End;

 Procedure TfrmMain.RefreshHistory;
  Var
   ID      : Integer;
   GroupID : Integer;
   Index   : Integer;
   q       : TFDQuery;
  Begin
   ID      := 0;
   GroupID := 0;
   If cbGroup.ItemIndex >= 0 Then
    GroupID := Integer(NativeInt(cbGroup.Items.Objects[cbGroup.ItemIndex]));
   If fHistory.Active And Not fHistory.IsEmpty Then
    ID := fHistory.FieldByName('id').AsInteger;
   cbGroup.Items.BeginUpdate;
   Try
    cbGroup.Items.Clear;
    cbGroup.Items.AddObject('', Nil);
    q := TFDQuery.Create(Nil);
    Try
     q.Connection := fDB.Connection;
     q.Open('select id,name from trip_groups order by sort_order,name');
     While Not q.Eof Do
      Begin
       cbGroup.Items.AddObject(q.FieldByName('name').AsString, TObject(NativeInt(q.FieldByName('id').AsInteger)));
       q.Next;
      End;
    Finally
     q.Free;
    End;
    Index := cbGroup.Items.IndexOfObject(TObject(NativeInt(GroupID)));
    If Index < 0 Then
     Begin
      Index   := 0;
      GroupID := 0;
     End;
    cbGroup.ItemIndex := Index;
   Finally
    cbGroup.Items.EndUpdate;
   End;
   fHistory.Close;
   fHistory.SQL.Text := 'select t.id,t.title,t.atc_id,t.departure_icao,t.destination_icao,t.departure_zulu_time,t.destination_zulu_time,g.name as group_name from trips t left join trip_groups g on g.id=t.group_id';
   If GroupID > 0 Then
    Begin
     fHistory.SQL.Add('where t.group_id=:group_id');
     fHistory.ParamByName('group_id').AsInteger := GroupID;
    End;
   fHistory.SQL.Add('order by t.id desc');
   fHistory.Open;
   If ID > 0 Then
    fHistory.Locate('id', ID, []);
  End;

 Procedure TfrmMain.GroupChanged(Sender : TObject);
  Begin
   RefreshHistory;
   SelectTrip(Self);
  End;

 Procedure TfrmMain.Tick(Sender : TObject);
  Var
   NowMS : UInt64;
   State : TRecorderState;
  Begin
   If fBusy Or Not Assigned(fRecorder) Then
    Exit;
   fBusy := True;
   Try
    FinishAnalysis;
    fRecorder.Configure(seInterval.Value, aAuto.Checked);
    State                           := fRecorder.Snapshot;
    StatusBar1.Panels.Items[0].Text := State.Status;
    If State.Error <> '' Then
     StatusBar1.Panels.Items[0].Text := State.Status + ' | ' + State.Error;
    If State.Ready And (fPlanShown <> State.Plan) Then
     Begin
      fPlanShown := State.Plan;
      mPlan.Text := Tr('Current/next recording:') + sLineBreak + fPlanShown;
     End;
    NowMS := GetTickCount64;
    If NowMS >= fRefresh Then
     Begin
      fRefresh := NowMS + 5000;
      RefreshHistory;
     End;
   Finally
    fBusy := False;
   End;
  End;

 Procedure TfrmMain.aTripInfoExecute(Sender : TObject);
  Var
   F : TfrmTripInfo;
  Begin
   If (fHistory = Nil) Or Not fHistory.Active Or fHistory.IsEmpty Then
    Exit;
   F := TfrmTripInfo.Create(Self);
   Try
    F.LoadTrip(fDB.Connection, fHistory.FieldByName('id').AsInteger);
    F.ConfigureSimBrief(fConfig);
    F.ShowModal;
   Finally
    F.Free;
   End;
  End;

 Procedure TfrmMain.aOpenExecute(Sender : TObject);
  Begin
   If OpenDialog.Execute Then
    Try
     OpenDatabase(OpenDialog.FileName);
    Except
     On E : Exception Do
      ShowMessage(E.Message);
    End;
  End;

 Procedure TfrmMain.ResetPanelLayout(Sender : TObject);
  Begin
   LeftPanel.Width  := 300;
   RightPanel.Width := 300;
   fDockMapHeight   := 390;
   If MapPanel.Align = alTop Then
    MapPanel.Height := 390;
   UpdateViewLayout;
   fConfig.EraseSection('layout');
   fConfig.UpdateFile;
  End;

 Procedure TfrmMain.ChartsWheel(Sender : TObject; Shift : TShiftState; WheelDelta : Integer; MousePos : TPoint; Var Handled : Boolean);
  Begin
   If (fGraphWindow = Nil) And (fGraphFrame <> Nil) Then
    fGraphFrame.Wheel(Sender, Shift, WheelDelta, MousePos, Handled);
  End;

 Function TfrmMain.GetMapHost : TPanel;
  Begin
   Result := fMapFrame.MapHost;
  End;

 Function TfrmMain.GetChartsHost : TScrollBox;
  Begin
   Result := fGraphFrame.ChartsHost;
  End;

 Procedure TfrmMain.UpdateViewLayout;
  Begin
   If MapPanel.Align = alTop Then
    fDockMapHeight := MapPanel.Height;
   CenterPanel.DisableAlign;
   Try
    SplitMap.Visible := MapPanel.Visible And GraphPanel.Visible;
    If GraphPanel.Visible Then
     Begin
      MapPanel.Align  := alTop;
      MapPanel.Height := fDockMapHeight;
     End
    Else
     MapPanel.Align := alClient;
   Finally
    CenterPanel.EnableAlign;
   End;
  End;

 Procedure TfrmMain.MapReturned(Sender : TObject);
  Begin
   fMapWindow         := Nil;
   aMapWindow.Checked := False;
   If Not fClosing Then
    UpdateViewLayout;
  End;

 Procedure TfrmMain.GraphReturned(Sender : TObject);
  Begin
   fGraphWindow         := Nil;
   aGraphWindow.Checked := False;
   If Not fClosing Then
    UpdateViewLayout;
  End;

 Procedure TfrmMain.aMapWindowExecute(Sender : TObject);
  Begin
   If fMapWindow <> Nil Then
    Begin
     fMapWindow.Close;
     Exit;
    End;
   If MapPanel.Align = alTop Then
    fDockMapHeight := MapPanel.Height;
   fMapWindow      := TfrmViewWindow.Create(Self);
   Try
    fMapWindow.Attach(fMapFrame, MapPanel, 'Mapa lotu', MapReturned);
    aMapWindow.Checked := True;
    UpdateViewLayout;
   Except
    FreeAndNil(fMapWindow);
    Raise;
   End;
  End;

 Procedure TfrmMain.aMetarExecute(Sender : TObject);
  Begin
   If fHistory.IsEmpty Then
    Exit;
   Try
    fRecorder.Command('metar', '', fHistory.FieldByName('id').AsInteger);
    StatusBar1.Panels.Items[0].Text := Tr('Zlecono METAR dla czasow startu i ladowania. Odswiez analize po pobraniu.');
   Except
    On E : Exception Do
     ShowMessage(E.Message);
   End;
  End;

 Procedure TfrmMain.aSettingsExecute(Sender : TObject);
  Var
   F : TfrmSettings;
  Begin
   F := TfrmSettings.Create(Self);
   Try
    F.Load(fConfig);
    F.btnResetLayout.OnClick := ResetPanelLayout;
    If F.ShowModal = mrOk Then
     Begin
      F.Save(fConfig);
      fCharts.Invalidate;
      UpdatePoint(Timeline.Position);

      UpdateLanguageActions;
      fPlanShown := '';
      If Assigned(fSimBrief) Then
       fSimBrief.Retranslate;
     End;
   Finally
    F.Free;
   End;
  End;

 Procedure TfrmMain.aImportPlanExecute(Sender : TObject);
  Begin
   If Not PlanDialog.Execute Then
    Exit;
   Try
    fRecorder.Command('plan', PlanDialog.FileName);
    mPlan.Text          := Tr('PLN import queued: ') + PlanDialog.FileName;
    DataTabs.ActivePage := PlanPage;
   Except
    On E : Exception Do
     Begin
      Log(1, 'PLN import: ' + E.Message);
      ShowMessage(E.Message);
     End;
   End;
  End;

 Procedure TfrmMain.aStartExecute(Sender : TObject);
  Begin
   fRecorder.Command('start');
   RefreshHistory;
  End;

 Procedure TfrmMain.aStopExecute(Sender : TObject);
  Begin
   aAuto.Checked := False;
   fRecorder.Configure(seInterval.Value, False);
   fRecorder.Command('stop');
   RefreshHistory;
  End;

 Procedure TfrmMain.aRefreshExecute(Sender : TObject);
  Begin
   RefreshHistory;
   If Assigned(fPlot) Then
    SelectTrip(Self);
  End;

 Procedure TfrmMain.SelectTrip(Sender : TObject);
  Begin
   If fHistory.IsEmpty Then
    Begin
     fMap.SetData(Nil);
     fCharts.SetData(Nil);
     FreeAndNil(fPlot);
     If Assigned(fEvents) Then
      fEvents.Close;
     If Assigned(fContacts) Then
      fContacts.Close;
     mPlan.Clear;
     DataGrid.RowCount := 2;
     DataGrid.Rows[1].Clear;
     CursorLabel.Caption := '';
     Timeline.Position   := 0;
     fSimBrief.SetTrip(Nil, 0);
     Exit;
    End;
   fMap.SetData(Nil);
   fCharts.SetData(Nil);
   FreeAndNil(fPlot);
   fPlot := fDB.LoadTrip(fHistory.FieldByName('id').AsInteger);
   fSimBrief.SetTrip(fDB.Connection, fPlot.TripID);
   fMap.SetData(fPlot);
   If fEvents = Nil Then
    Begin
     fEvents              := TFDQuery.Create(Nil);
     fEvents.Connection   := fDB.Connection;
     fEventSource.DataSet := fEvents;
    End;
   If fContacts = Nil Then
    Begin
     fContacts              := TFDQuery.Create(Nil);
     fContacts.Connection   := fDB.Connection;
     fContactSource.DataSet := fContacts;
    End;
   fEvents.Close;
   fEvents.Open('select event,time_zulu,time_local from trip_events where trip=' + IntToStr(fPlot.TripID) + ' order by time_zulu,event_seq');
   fContacts.Close;
   fContacts.Open('select ''Start'' kind,id,time_zulu,icao,runway,airspeed_indicated,vertical_speed,NULL g_force from trip_liftoffs where trip=' + IntToStr(fPlot.TripID) + ' union all select ''Landing'',id,time_zulu,icao,runway,airspeed_indicated,vertical_speed,g_force from trip_touchdowns where trip=' + IntToStr(fPlot.TripID) + ' order by time_zulu');
   fCharts.SetData(fPlot);
   mPlan.Clear;
   If fPlot.FlightPlan <> Nil Then
    Begin
     mPlan.Lines.Add(fPlot.FlightPlan.Source);
     mPlan.Lines.Add(fPlot.FlightPlan.Summary);
     mPlan.Lines.Add('');
     mPlan.Lines.Add(Tr('Map: only explicit coordinates; procedures are not expanded.'));
     mPlan.Lines.Add('');
     mPlan.Lines.Add(fPlot.FlightPlan.Raw);
    End
   Else
    mPlan.Lines.Add(Tr('No saved flight plan for this recording.'));
   Timeline.Max      := Max(1, fPlot.Points.Count - 1);
   Timeline.Position := 0;
   ApplyChartSelection;
   If fPlot.Points.Count > 0 Then
    UpdatePoint(0);
  End;

 Procedure TfrmMain.ApplyChartSelection;
  Var
   Indices : TList<Integer>;
   Name    : String;
   I       : Integer;
  Begin
   Indices := TList<Integer>.Create;
   Try
    If fPlot <> Nil Then
     For Name In fSelected Do
      Begin
       I := fPlot.Labels.IndexOf(Name);
       If I >= 0 Then
        Indices.Add(I);
      End;
    fCharts.Select(Indices);
   Finally
    Indices.Free;
   End;
  End;

 Procedure TfrmMain.ZoomChart(Sender : TObject);
  Begin
   fGraphFrame.ZoomChart(Sender);
  End;

 Procedure TfrmMain.PanChart(Sender : TObject);
  Begin
   If ViewPan.Tag = 0 Then
    fCharts.Pan(ViewPan.Position / 1000);
  End;

 Procedure TfrmMain.ChartViewChanged(Sender : TObject);
  Var
   Span, Full, Lo : Double;
  Begin
   If fCharts = Nil Then
    Exit;
   Span        := fCharts.ViewEnd - fCharts.ViewStart;
   ViewPan.Tag := 1;
   Try
    Full := 0;
    Lo   := 0;
    If (fPlot <> Nil) And (fPlot.Points.Count > 0) Then
     Begin
      Lo   := fPlot.Points.First.Seconds;
      Full := fPlot.Points.Last.Seconds - Lo;
     End;
    ViewPan.Enabled := Full > Span + 0.001;
    If ViewPan.Enabled Then
     ViewPan.Position := Round((fCharts.ViewStart - Lo) / (Full - Span) * 1000)
    Else
     ViewPan.Position := 0;
    fGraphFrame.SetViewCaption(Format('%.1f - %.1f s', [fCharts.ViewStart, fCharts.ViewEnd]));
   Finally
    ViewPan.Tag := 0;
   End;
  End;

 Procedure TfrmMain.CursorMove(Sender : TObject; Index : Integer);
  Begin
   If Timeline.Position = Index Then
    Exit;
   Timeline.Position := Index;
   UpdatePoint(Index);
  End;

 Procedure TfrmMain.TimelineChange(Sender : TObject);
  Begin
   UpdatePoint(Timeline.Position);
  End;

 Procedure TfrmMain.UpdatePoint(Index : Integer);
  Var
   P : TPlotPoint;
   I : Integer;
  Begin
   If Not Assigned(fPlot) Or (Index < 0) Or (Index >= fPlot.Points.Count) Then
    Exit;
   P := fPlot.Points[Index];
   fMap.SetCursor(Index);
   fCharts.SetCursor(Index);
   CursorLabel.Caption  := P.Time;
   DataGrid.RowCount    := fPlot.Labels.Count + 1;
   DataGrid.Cells[0, 0] := Tr('Parametr');
   DataGrid.Cells[1, 0] := Tr('Warto'#347#263);
   For I                := 0 To fPlot.Labels.Count - 1 Do
    Begin
     DataGrid.Cells[0, I + 1] := ParameterCaption(fPlot.Labels[I]);
     If IsNan(P.Values[I]) Then
      DataGrid.Cells[1, I + 1] := ''
     Else
      DataGrid.Cells[1, I + 1] := Format('%.8g', [ParameterDisplayValue(fPlot.Labels[I], P.Values[I])]);
    End;
  End;

 Procedure TfrmMain.aExportKMLExecute(Sender : TObject);
  Begin
   If fHistory.IsEmpty Then
    Exit;
   SaveDialog.FileName := 'flight-' + fHistory.FieldByName('id').AsString + '.kml';
   If SaveDialog.Execute Then
    fDB.ExportKML(fHistory.FieldByName('id').AsInteger, SaveDialog.FileName);
  End;

 Procedure TfrmMain.aDeleteExecute(Sender : TObject);
  Var
   ID : Integer;
  Begin
   If fHistory.IsEmpty Then
    Exit;
   ID := fHistory.FieldByName('id').AsInteger;
   If ID = fRecorder.Snapshot.Trip Then
    Begin
     ShowMessage(Tr('Najpierw zako'#324'cz nagrywanie tego lotu.'));
     Exit;
    End;
   If LocalizedMessageDlg(Tr('Usun'#261#263' wybrany lot wraz z danymi?'), mtConfirmation, [mbYes, mbNo], 0) = mrYes Then
    Begin
     fDB.DeleteTrip(ID);
     fMap.SetData(Nil);
     fCharts.SetData(Nil);
     FreeAndNil(fPlot);
     RefreshHistory;
    End;
  End;

 Procedure TfrmMain.aNewGroupExecute(Sender : TObject);
  Var
   Name : String;
  Begin
   Name := '';
   If LocalizedInputQuery(Tr('Nowa grupa'), Tr('Nazwa:'), Name) And (Trim(Name) <> '') Then
    Begin
     fDB.Connection.ExecSQL('insert into trip_groups(name,sort_order) values (:n,(select coalesce(max(sort_order),0)+1 from trip_groups))', [Trim(Name)]);
     RefreshHistory;
    End;
  End;

 Procedure TfrmMain.aAssignExecute(Sender : TObject);
  Var
   GroupID : Integer;
   TripID  : Integer;
   Dialog  : TfrmAssignGroup;
   q       : TFDQuery;
  Begin
   If fHistory.IsEmpty Then
    Exit;
   TripID := fHistory.FieldByName('id').AsInteger;
   q      := TFDQuery.Create(Nil);
   Dialog := TfrmAssignGroup.Create(Self);
   Try
    q.Connection := fDB.Connection;
    q.Open('select group_id from trips where id=:id', [TripID]);
    GroupID := q.FieldByName('group_id').AsInteger;
    Dialog.cbGroups.Items.AddObject(Tr('Bez grupy'), Nil);
    q.Close;
    q.Open('select id,name from trip_groups order by sort_order,name');
    While Not q.Eof Do
     Begin
      Dialog.cbGroups.Items.AddObject(q.FieldByName('name').AsString, TObject(NativeInt(q.FieldByName('id').AsInteger)));
      q.Next;
     End;
    Dialog.cbGroups.ItemIndex := Dialog.cbGroups.Items.IndexOfObject(TObject(NativeInt(GroupID)));
    If Dialog.cbGroups.ItemIndex < 0 Then
     Dialog.cbGroups.ItemIndex := 0;
    If Dialog.ShowModal <> mrOk Then
     Exit;
    GroupID := Integer(NativeInt(Dialog.cbGroups.Items.Objects[Dialog.cbGroups.ItemIndex]));
    If GroupID = 0 Then
     fDB.Connection.ExecSQL('update trips set group_id=null where id=:id', [TripID])
    Else
     fDB.Connection.ExecSQL('update trips set group_id=:g where id=:id', [GroupID, TripID]);
   Finally
    Dialog.Free;
    q.Free;
   End;
   RefreshHistory;
   SelectTrip(Self);
  End;

 Procedure TfrmMain.aFitExecute(Sender : TObject);
  Begin
   fMap.Fit;
  End;

 Procedure TfrmMain.aGraphWindowExecute(Sender : TObject);
  Begin
   If fGraphWindow <> Nil Then
    Begin
     fGraphWindow.Close;
     Exit;
    End;
   fGraphWindow := TfrmViewWindow.Create(Self);
   Try
    fGraphWindow.Attach(fGraphFrame, GraphPanel, 'Wykresy lotu', GraphReturned);
    aGraphWindow.Checked := True;
    UpdateViewLayout;
   Except
    FreeAndNil(fGraphWindow);
    Raise;
   End;
  End;

 Procedure TfrmMain.aTilesExecute(Sender : TObject);
  Begin
   If fMap = Nil Then
    Exit;
   fMap.TilesEnabled := aTiles.Checked;
   fMap.Invalidate;
  End;

 Procedure TfrmMain.aAnalysisExecute(Sender : TObject);
  Var
   BeforeSeconds : Integer;
   AfterSeconds  : Integer;
   q             : TFDQuery;
   J             : TJSONObject;
   Key           : String;
   Prompt        : String;
   TableName     : String;
   Provider      : String;
   Model         : String;
   F             : TfrmReport;
  Begin
   If fHistory.IsEmpty Or Assigned(fAnalysis) Then
    Exit;
   TableName := 'trip_touchdowns';
   If Sender = aAnalysisLiftoff Then
    TableName := 'trip_liftoffs';
   q          := TFDQuery.Create(Nil);
   J          := TJSONObject.Create;
   Try
    q.Connection := fDB.Connection;
    q.Open('select * from ' + TableName + ' where trip=' + fHistory.FieldByName('id').AsString + ' order by id desc limit 1');
    If q.IsEmpty Then
     Begin
      ShowMessage(Tr('Brak zarejestrowanego kontaktu z pasem dla tego lotu.'));
      Exit;
     End;
    If (q.FieldByName('analysis_report').AsString <> '') And (GetKeyState(VK_SHIFT) >= 0) Then
     Begin
      F := TfrmReport.Create(Self);
      F.SetReport(q.FieldByName('analysis_report').AsString, TableName = 'trip_touchdowns');
      F.Show;
      Exit;
     End;
    Key      := fConfig.ReadString('ai', 'gemini_api_key', '');
    Provider := fConfig.ReadString('ai', 'provider', 'codex');
    If SameText(Provider, 'gemini') And (Key = '') Then
     Begin
      ShowMessage(Tr('Ustaw ai/gemini_api_key w settings.ini i uruchom ponownie.'));
      Exit;
     End;
    FreeAndNil(J);
    ReadAnalysisWindow(fConfig, TableName = 'trip_touchdowns', BeforeSeconds, AfterSeconds);
    J := BuildContactContext(fDB, q, BeforeSeconds, AfterSeconds);
    J.AddPair('aircraft', fHistory.FieldByName('title').AsString);
    If TableName = 'trip_touchdowns' Then
     Prompt := BuildAnalysisPrompt(J.ToJSON, 'l'#261'dowanie')
    Else
     Prompt := BuildAnalysisPrompt(J.ToJSON, 'start');
    If SameText(Provider, 'codex') Then
     Model := fConfig.ReadString('ai', 'codex_model', '')
    Else If SameText(Provider, 'ollama') Then
     Model := fConfig.ReadString('ai', 'ollama_model', '')
    Else
     Model              := fConfig.ReadString('ai', 'model', 'gemma-4-31b-it');
    fAnalysis           := TAnalysisThread.Create(Provider, Key, Model, Prompt, fConfig.ReadString('ai', 'codex_path', ''), fConfig.ReadInteger('ai', 'timeout_seconds', 180), fConfig.ReadString('ai', 'ollama_url', 'http://localhost:11434'), fConfig.ReadInteger('ai', 'ollama_context_tokens', 32768));
    fAnalysis.RowID     := q.FieldByName('id').AsInteger;
    fAnalysis.TableName := TableName;
    fAnalysis.Start;
    aOpen.Enabled                   := False;
    aAnalysisLanding.Enabled        := False;
    aAnalysisLiftoff.Enabled        := False;
    StatusBar1.Panels.Items[0].Text := Tr('Trwa analiza AI wybranego kontaktu...');
   Finally
    J.Free;
    q.Free;
   End;
  End;

 Procedure TfrmMain.FinishAnalysis;
  Var
   F : TfrmReport;
  Begin
   If Not Assigned(fAnalysis) Or (WaitForSingleObject(fAnalysis.Handle, 0) <> WAIT_OBJECT_0) Then
    Exit;
   Try
    If fAnalysis.Error <> '' Then
     ShowMessage(fAnalysis.Error)
    Else
     Begin
      fDB.Connection.ExecSQL('update ' + fAnalysis.TableName + ' set analysis_report=:r where id=:id', [fAnalysis.Report, fAnalysis.RowID]);
      F := TfrmReport.Create(Self);
      F.SetReport(fAnalysis.Report, fAnalysis.TableName = 'trip_touchdowns');
      F.Show;
     End;
   Finally
    FreeAndNil(fAnalysis);
    aOpen.Enabled            := True;
    aAnalysisLanding.Enabled := True;
    aAnalysisLiftoff.Enabled := True;
   End;
  End;

 Procedure TfrmMain.aOverviewExecute(Sender : TObject);
  Var
   q : TFDQuery;
   P : TPlotPoint;
  Begin
   fMap.SetData(Nil);
   fCharts.SetData(Nil);
   FreeAndNil(fPlot);
   fPlot := TTripPlot.Create;
   q     := TFDQuery.Create(Nil);
   Try
    q.Connection := fDB.Connection;
    q.Open('select departure_latitude,departure_longitude,destination_latitude,destination_longitude,coalesce(group_id,0) gid from trips where destination_latitude is not null and destination_longitude is not null');
    While Not q.Eof Do
     Begin
      P             := Default (TPlotPoint);
      P.GroupID     := q.FieldByName('gid').AsInteger;
      P.Lat         := q.FieldByName('departure_latitude').AsFloat;
      P.Lon         := q.FieldByName('departure_longitude').AsFloat;
      P.BreakBefore := True;
      fPlot.Points.Add(P);
      P.Lat         := q.FieldByName('destination_latitude').AsFloat;
      P.Lon         := q.FieldByName('destination_longitude').AsFloat;
      P.BreakBefore := False;
      fPlot.Points.Add(P);
      q.Next;
     End;
   Finally
    q.Free;
   End;
   fMap.SetData(fPlot);

   DataGrid.RowCount   := 2;
   CursorLabel.Caption := Tr('Wszystkie trasy '#8212' kolory wed'#322'ug grup');
  End;

 Procedure TfrmMain.aSavePNGMapExecute(Sender : TObject);
  Var
   Dialog : TSaveDialog;
   Bitmap : TBitmap;
   PNG    : TPngImage;
  Begin
   Dialog := TSaveDialog.Create(Self);
   Bitmap := TBitmap.Create;
   PNG    := TPngImage.Create;
   Try
    Dialog.Filter     := 'PNG image (*.png)|*.png';
    Dialog.DefaultExt := 'png';
    Dialog.Options    := [ofOverwritePrompt, ofPathMustExist];
    If Dialog.Execute Then
     Begin
      Bitmap.SetSize(fMap.Width, fMap.Height);
      fMap.PaintTo(Bitmap.Canvas, 0, 0);
      PNG.Assign(Bitmap);
      PNG.SaveToFile(Dialog.FileName);
     End;
   Finally
    Dialog.Free;
    Bitmap.Free;
    PNG.Free;
   End;
  End;

 Procedure TfrmMain.aRenameGroupExecute(Sender : TObject);
  Var
   ID   : Integer;
   Name : String;
  Begin
   If cbGroup.ItemIndex <= 0 Then
    Exit;
   ID   := Integer(NativeInt(cbGroup.Items.Objects[cbGroup.ItemIndex]));
   Name := cbGroup.Text;
   If LocalizedInputQuery(Tr('Zmie'#324' nazw'#281' grupy'), Tr('Nazwa:'), Name) And (Trim(Name) <> '') Then
    Begin
     fDB.Connection.ExecSQL('update trip_groups set name=:n where id=:id', [Trim(Name), ID]);
     RefreshHistory;
    End;
  End;

 Procedure TfrmMain.aDeleteGroupExecute(Sender : TObject);
  Var
   ID : Integer;
  Begin
   If cbGroup.ItemIndex <= 0 Then
    Exit;
   ID := Integer(NativeInt(cbGroup.Items.Objects[cbGroup.ItemIndex]));
   If MessageDlg(Tr('Usun'#261#263' grup'#281'? Loty pozostan'#261' w bazie bez tej grupy.'), mtConfirmation, [mbYes, mbNo], 0) <> mrYes Then
    Exit;
   fDB.Connection.StartTransaction;
   Try
    fDB.Connection.ExecSQL('update trips set group_id=null where group_id=:id', [ID]);
    fDB.Connection.ExecSQL('delete from trip_groups where id=:id', [ID]);
    fDB.Connection.Commit;
   Except
    fDB.Connection.Rollback;
    Raise;
   End;
   RefreshHistory;
  End;

End.
