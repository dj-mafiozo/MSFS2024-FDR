{$StackFrames On}
Unit frmMainU;

Interface

 Uses
  {$IFDEF PORT_TEST}
  TestPathsU,{$ENDIF} FSLTLU, GhostReplayU, FlapsHandleU, PanelProportionsU, frmDockViewU, FSHudReplayU, PlaybackU, fraA320PFDU, fraA320ECAMU, LegacyExportU, fraB38MEICASU, InstrumentDataU, FlightDirectorU, Boeing737PFDU, fraPFD737U, frmChangeLogU, ViewStateU, Winapi.Messages, AppPathsU, UIFontsU, Vcl.XPMan, Vcl.Menus, RecordingIndexU, LocalizationU, i18nLocalizer, Winapi.Windows, System.SysUtils, System.Classes,
  System.IOUtils, System.StrUtils, System.Math, System.IniFiles, System.Generics.Collections, Vcl.Forms,
  Vcl.Controls, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.CheckLst, Vcl.Grids,
  Vcl.DBGrids, Vcl.Dialogs, Vcl.Samples.Spin, Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param,
  System.Variants, System.UITypes, System.JSON, Vcl.Graphics, Vcl.Imaging.pngimage,
  FlightDatabaseU, RecorderWorkerU, FlightMapU, FlightChartsU, FlightTelemetryU,
  FlightAnalysisU, frmReportU, AppLogU, FlightPlanU, frmSettingsU, AnalysisContextU, frmSimBriefFrameU,
  i18nCore, System.Actions, Vcl.ActnList, System.ImageList, Vcl.ImgList,
  Vcl.ToolWin, fraEnginesU, fraSixPackU, fraFMCU, fraMapU, fraGraphU, frmViewWindowU, frmAssignGroupU,
  VirtualTrees, VirtualTrees.BaseTree, VirtualTrees.Types;

 Type
  TfrmMain = Class(TLocalizedForm)
    aAbout                     : TAction;
    aAnalysisLanding           : TAction;
    aAnalysisLiftoff           : TAction;
    aArabic                    : TAction;
    aAssign                    : TAction;
    aAuto                      : TAction;
    aBack                      : TAction;
    aBeginning                 : TAction;
    aBelarusian                : TAction;
    aChangeLog                 : TAction;
    aChinese                   : TAction;
    aClose                     : TAction;
    aCroatian                  : TAction;
    ActionList                 : TActionList;
    aCzech                     : TAction;
    aDanish                    : TAction;
    aDelete                    : TAction;
    aDeleteGroup               : TAction;
    aDutch                     : TAction;
    aEnding                    : TAction;
    aEnglish                   : TAction;
    aEnglishGB                 : TAction;
    aExportKML                 : TAction;
    aExportLegacy              : TAction;
    aFinnish                   : TAction;
    aFit                       : TAction;
    aFrench                    : TAction;
    aFrenchCA                  : TAction;
    aGerman                    : TAction;
    aGermanAT                  : TAction;
    aGermanCH                  : TAction;
    aGhostBack                 : TAction;
    aGhostBack1                : TMenuItem;
    aGhostForward              : TAction;
    aGhostForward1             : TMenuItem;
    aGhostPlayPause            : TAction;
    aGhostPlayPause1           : TMenuItem;
    aGhostStop                 : TAction;
    aGhostStop1                : TMenuItem;
    aGreek                     : TAction;
    aHebrew                    : TAction;
    aHelp                      : TAction;
    aHindi                     : TAction;
    aImportFlight              : TAction;
    aImportPlan                : TAction;
    aIndonesian                : TAction;
    aItalian                   : TAction;
    aJapanese                  : TAction;
    aLangAuto                  : TAction;
    aMetar                     : TAction;
    aNewGroup                  : TAction;
    aNorwegian                 : TAction;
    aOpen                      : TAction;
    aOverview                  : TAction;
    aPlayPause                 : TAction;
    aPolish                    : TAction;
    aPortuguese                : TAction;
    aPortugueseBR              : TAction;
    AppTranslator              : TTranslator;
    aRefresh                   : TAction;
    aRenameGroup               : TAction;
    aRussian                   : TAction;
    aSavePNGMap                : TAction;
    aSettings                  : TAction;
    aSkip                      : TAction;
    aSlovak                    : TAction;
    aSpanish                   : TAction;
    aStart                     : TAction;
    aStop                      : TAction;
    aStopPlayback              : TAction;
    aSwedish                   : TAction;
    aTiles                     : TAction;
    aTripInfo                  : TAction;
    aTurkish                   : TAction;
    aUkrainian                 : TAction;
    aVietnamese                : TAction;
    btnAnalysisLiftoff         : TToolButton;
    btnAssign                  : TToolButton;
    btnAuto                    : TToolButton;
    btnBack                    : TToolButton;
    btnBeginning               : TToolButton;
    btnDelete                  : TToolButton;
    btnDeleteGroup             : TToolButton;
    btnEnding                  : TToolButton;
    btnExit                    : TToolButton;
    btnExportKML               : TToolButton;
    btnFit                     : TToolButton;
    btnGhostBack               : TToolButton;
    btnGhostForward            : TToolButton;
    btnGhostPlayPause          : TToolButton;
    btnGhostStop               : TToolButton;
    btnImportFlight            : TToolButton;
    btnLandingAnalysis         : TToolButton;
    btnMetar                   : TToolButton;
    btnNewGroup                : TToolButton;
    btnOpen                    : TToolButton;
    btnOverview                : TToolButton;
    btnPlayPause               : TToolButton;
    btnRefresh                 : TToolButton;
    btnRenameGroup             : TToolButton;
    btnSavePNGMap              : TToolButton;
    btnSettings                : TToolButton;
    btnSkip                    : TToolButton;
    btnStart                   : TToolButton;
    btnStop                    : TToolButton;
    btnStopPlayback            : TToolButton;
    btnTiles                   : TToolButton;
    btnTripInfo                : TToolButton;
    cbGroup                    : TComboBox;
    CenterPanel                : TPanel;
    ContactGrid                : TDBGrid;
    ContactsPage               : TTabSheet;
    CursorLabel                : TLabel;
    DataGrid                   : TStringGrid;
    DataTabs                   : TPageControl;
    DockBottomSite             : TPanel;
    DockBottomSplitter         : TSplitter;
    DockLeftSite               : TPanel;
    DockLeftSplitter           : TSplitter;
    DockRightSite              : TPanel;
    DockRightSplitter          : TSplitter;
    DockTopSite                : TPanel;
    DockTopSplitter            : TSplitter;
    EnginePanel                : TPanel;
    eSearch                    : TEdit;
    eValueSearch               : TEdit;
    EventGrid                  : TDBGrid;
    EventsPage                 : TTabSheet;
    fA320ECAMFrame             : TfraA320ECAM;
    fA320PFDFrame              : TfraA320PFD;
    fB38MEICASFrame            : TfraB38MEICAS;
    fEnginesFrame              : TfraEngines;
    fFMCFrame                  : TfraFMC;
    fFMCPage                   : TTabSheet;
    fGraphFrame                : TfraGraph;
    fMapFrame                  : TfraMap;
    fPFD737Frame               : TfraPFD737;
    fSHudMemo                  : TMemo;
    fSHudPage                  : TTabSheet;
    fSimBrief                  : TfraSimBrief;
    fSixPackFrame              : TfraSixPack;
    GraphPanel                 : TPanel;
    GroupPanel                 : TPanel;
    GSXBoardingCargoProgress   : TProgressBar;
    GSXBoardingProgress        : TProgressBar;
    GSXBoardingProgressLabel   : TLabel;
    GSXBoardingProgressPanel   : TPanel;
    GSXCateringProgress        : TProgressBar;
    GSXCateringProgressLabel   : TLabel;
    GSXCateringProgressPanel   : TPanel;
    GSXDeboardingCargoProgress : TProgressBar;
    GSXDeboardingProgress      : TProgressBar;
    GSXDeboardingProgressLabel : TLabel;
    GSXDeboardingProgressPanel : TPanel;
    GSXDeiceProgress           : TProgressBar;
    GSXDeiceProgressLabel      : TLabel;
    GSXDeiceProgressPanel      : TPanel;
    GSXDepartureProgress       : TProgressBar;
    GSXDepartureProgressLabel  : TLabel;
    GSXDepartureProgressPanel  : TPanel;
    GSXGrid                    : TStringGrid;
    GSXPage                    : TTabSheet;
    GSXProgressPanel           : TPanel;
    GSXRefuelingProgress       : TProgressBar;
    GSXRefuelingProgressLabel  : TLabel;
    GSXRefuelingProgressPanel  : TPanel;
    ImageList                  : TImageList;
    ImageListSmall             : TImageList;
    ImportFlightDialog         : TOpenDialog;
    InstrumentsPanel           : TPanel;
    lATCMessage                : TLabel;
    LeftPanel                  : TPanel;
    LegacyExportDialog         : TSaveDialog;
    lPlayRate                  : TLabel;
    MainMenu                   : TMainMenu;
    MapPanel                   : TPanel;
    miAbout                    : TMenuItem;
    miAnalysis                 : TMenuItem;
    miArabic                   : TMenuItem;
    miAssign                   : TMenuItem;
    miAuto                     : TMenuItem;
    miBack                     : TMenuItem;
    miBegining                 : TMenuItem;
    miBelarusian               : TMenuItem;
    miChangeLog                : TMenuItem;
    miChartsConfigure          : TMenuItem;
    miChinese                  : TMenuItem;
    miClose                    : TMenuItem;
    miCroatian                 : TMenuItem;
    miCzech                    : TMenuItem;
    miDanish                   : TMenuItem;
    miDeleteGroup              : TMenuItem;
    miDeleteTrip               : TMenuItem;
    miDutch                    : TMenuItem;
    miEnding                   : TMenuItem;
    miEnglish                  : TMenuItem;
    miEnglishGB                : TMenuItem;
    miExport                   : TMenuItem;
    miExportLegacy             : TMenuItem;
    miFile                     : TMenuItem;
    miFinnish                  : TMenuItem;
    miFit                      : TMenuItem;
    miFrench                   : TMenuItem;
    miFrenchCA                 : TMenuItem;
    miFullView                 : TMenuItem;
    miGerman                   : TMenuItem;
    miGermanAT                 : TMenuItem;
    miGermanCH                 : TMenuItem;
    miGhost                    : TMenuItem;
    miGraphWindow              : TMenuItem;
    miGreek                    : TMenuItem;
    miGroups                   : TMenuItem;
    miHebrew                   : TMenuItem;
    miHelp                     : TMenuItem;
    miHelpContents             : TMenuItem;
    miHindi                    : TMenuItem;
    miImport                   : TMenuItem;
    miImportFlight             : TMenuItem;
    miIndonesian               : TMenuItem;
    miItalian                  : TMenuItem;
    miJapanese                 : TMenuItem;
    miLanding                  : TMenuItem;
    miLangAuto                 : TMenuItem;
    miLanguage                 : TMenuItem;
    miMapWindow                : TMenuItem;
    miMetar                    : TMenuItem;
    miNewGroup                 : TMenuItem;
    miNorwegian                : TMenuItem;
    miOpen                     : TMenuItem;
    miOverview                 : TMenuItem;
    miPlayback                 : TMenuItem;
    miPlayPause                : TMenuItem;
    miPolish                   : TMenuItem;
    miPortuguese               : TMenuItem;
    miPortugueseBR             : TMenuItem;
    miRecording                : TMenuItem;
    miRefresh                  : TMenuItem;
    miRenameGroup              : TMenuItem;
    miRussian                  : TMenuItem;
    miSaveMap                  : TMenuItem;
    miSeparator1               : TMenuItem;
    miSettings                 : TMenuItem;
    miSkip                     : TMenuItem;
    miSlovak                   : TMenuItem;
    miSpanish                  : TMenuItem;
    miStart                    : TMenuItem;
    miStop                     : TMenuItem;
    miStopPlayback             : TMenuItem;
    miSwedish                  : TMenuItem;
    miTakeoff                  : TMenuItem;
    miTiles                    : TMenuItem;
    miTools                    : TMenuItem;
    miTripInfo                 : TMenuItem;
    miTurkish                  : TMenuItem;
    miUkrainian                : TMenuItem;
    miVietnamese               : TMenuItem;
    miView                     : TMenuItem;
    miZoomIn                   : TMenuItem;
    miZoomOut                  : TMenuItem;
    mPlan                      : TMemo;
    OpenDialog                 : TOpenDialog;
    Panel1                     : TPanel;
    PlanDialog                 : TOpenDialog;
    PlanPage                   : TTabSheet;
    PlayBackRate               : TUpDown;
    PlaybackTimer              : TTimer;
    RightPanel                 : TPanel;
    SaveDialog                 : TSaveDialog;
    seInterval                 : TSpinEdit;
    SimBriefPage               : TTabSheet;
    SixPackPanel               : TPanel;
    SliderPanel                : TPanel;
    SplitLeft                  : TSplitter;
    SplitMap                   : TSplitter;
    SplitRight                 : TSplitter;
    SplitterInstruments        : TSplitter;
    SplitterSixPackEngines     : TSplitter;
    StatusBar1                 : TStatusBar;
    Timeline                   : TTrackBar;
    Timer                      : TTimer;
    ToolBar1                   : TToolBar;
    ToolBar2                   : TToolBar;
    ToolBar3                   : TToolBar;
    ToolBar4                   : TToolBar;
    ToolBar5                   : TToolBar;
    ToolBar6                   : TToolBar;
    ToolButton4                : TToolButton;
    ToolButton6                : TToolButton;
    ToolButton7                : TToolButton;
    ToolButton8                : TToolButton;
    ToolButton10               : TToolButton;
    ToolButton12               : TToolButton;
    ToolButton13               : TToolButton;
    ToolButton15               : TToolButton;
    ValuesPage                 : TTabSheet;
    ViewPan                    : TTrackBar;
    ViewsPanel                 : TPanel;
    vstRecordings              : TVirtualStringTree;
    Function  AppHelp                (Command : Word; Data : THelpEventData; Var CallHelp : Boolean) : Boolean;
    Procedure aAboutExecute          (Sender : TObject);
    Procedure aAnalysisExecute       (Sender : TObject);
    Procedure aAssignExecute         (Sender : TObject);
    Procedure aAutoExecute           (Sender : TObject);
    Procedure aBackExecute           (Sender : TObject);
    Procedure aBeginningExecute      (Sender : TObject);
    Procedure aChangeLogExecute      (Sender : TObject);
    Procedure aChartsConfigureExecute(Sender : TObject);
    Procedure aCloseExecute          (Sender : TObject);
    Procedure ActionsUpdate          (Action : TBasicAction; Var Handled : Boolean);
    Procedure aDeleteExecute         (Sender : TObject);
    Procedure aDeleteGroupExecute    (Sender : TObject);
    Procedure aEndingExecute         (Sender : TObject);
    Procedure aExportKMLExecute      (Sender : TObject);
    Procedure aExportLegacyExecute   (Sender : TObject);
    Procedure aFitExecute            (Sender : TObject);
    Procedure aGhostBackExecute      (Sender : TObject);
    Procedure aGhostForwardExecute   (Sender : TObject);
    Procedure aGhostPlayPauseExecute (Sender : TObject);
    Procedure aGhostStopExecute      (Sender : TObject);
    Procedure aGraphWindowExecute    (Sender : TObject);
    Procedure aHelpExecute           (Sender : TObject);
    Procedure aImportFlightExecute   (Sender : TObject);
    Procedure aImportPlanExecute     (Sender : TObject);
    Procedure aMapWindowExecute      (Sender : TObject);
    Procedure aMetarExecute          (Sender : TObject);
    Procedure aNewGroupExecute       (Sender : TObject);
    Procedure aOpenExecute           (Sender : TObject);
    Procedure aOverviewExecute       (Sender : TObject);
    Procedure aPlayPauseExecute      (Sender : TObject);
    Procedure ApplyChartSelection;
    Procedure aRefreshExecute        (Sender : TObject);
    Procedure aRenameGroupExecute    (Sender : TObject);
    Procedure aSavePNGMapExecute     (Sender : TObject);
    Procedure aSettingsExecute       (Sender : TObject);
    Procedure aSkipExecute           (Sender : TObject);
    Procedure aStartExecute          (Sender : TObject);
    Procedure aStopExecute           (Sender : TObject);
    Procedure aStopPlaybackExecute   (Sender : TObject);
    Procedure aTilesExecute          (Sender : TObject);
    Procedure aTripInfoExecute       (Sender : TObject);
    Procedure ChangeLanguage         (Sender : TObject);
    Procedure ChartsWheel            (Sender : TObject; Shift : TShiftState; WheelDelta : Integer; MousePos : TPoint; Var Handled : Boolean);
    Procedure ChartViewChanged       (Sender : TObject);
    Procedure DockPageChanged        (Sender : TObject);
    Procedure DockTabsMouseDown      (Sender : TObject; Button : TMouseButton; Shift : TShiftState; x, y : Integer);
    Procedure DockTabsMouseMove      (Sender : TObject; Shift : TShiftState; x, y : Integer);
    Procedure FetchWeather           (Sender : TObject);
    Procedure FinishAnalysis;
    Procedure FormCreate             (Sender : TObject);
    Procedure FormDestroy            (Sender : TObject);
    Procedure FormResize             (Sender : TObject);
    Procedure FrameMenuOpen          (Sender : TObject);
    Procedure GroupChanged           (Sender : TObject);
    Procedure InstrumentSplitMoved   (Sender : TObject);
    Procedure LanguageChanged        (Sender : TObject);
    Procedure LanguageMenuDraw       (Sender : TObject; ACanvas : TCanvas; ARect : TRect; Selected : Boolean);
    Procedure LanguageMenuMeasure    (Sender : TObject; ACanvas : TCanvas; Var Width, Height : Integer);
    Procedure NativeDockDrop         (Sender : TObject; Source : TDragDockObject; x, y : Integer);
    Procedure NativeDockOver         (Sender : TObject; Source : TDragDockObject; x, y : Integer; State : TDragState; Var Accept : Boolean);
    Procedure NativeUnDock           (Sender : TObject; Client : TControl; NewTarget : TWinControl; Var Allow : Boolean);
    Procedure PanChart               (Sender : TObject);
    Procedure PanelSplitMoved        (Sender : TObject);
    Procedure PlayBackRateChangingEx (Sender : TObject; Var AllowChange : Boolean; NewValue : Integer; Direction : TUpDownDirection);
    Procedure PlaybackTimerTimer     (Sender : TObject);
    Procedure SelectTrip             (Sender : TObject);
    Procedure Tick                   (Sender : TObject);
    Procedure TimelineChange         (Sender : TObject);
    Procedure UpdateGhostControls;
    Procedure UpdateLanguageActions;
    Procedure ValueParameterHint     (Sender : TObject; Shift : TShiftState; x, y : Integer);
    Procedure ValueSearchChange      (Sender : TObject);
    Procedure ZoomChart              (Sender : TObject);
   Private
    fAIModels          : TAIModelInventory;
    fAnalysis          : TAnalysisThread;
    fATC               : TFSHudReplay;
    fBusy              : Boolean;
    fCharts            : TFlightCharts;
    fClosing           : Boolean;
    fConfig            : TMemIniFile;
    fContacts          : TFDQuery;
    fContactSource     : TDataSource;
    fDB                : TFlightDatabase;
    fDockLayoutState   : Integer;
    fDockMapHeight     : Integer;
    fDockMouse         : TPoint;
    fDockSixPackWidth  : Integer;
    fDockTab           : TTabSheet;
    fDockViews         : TList;
    fEnginesWindow     : TfrmViewWindow;
    fEvents            : TFDQuery;
    fEventSource       : TDataSource;
    fFMCWindow         : TfrmViewWindow;
    fGhost             : TGhostReplayThread;
    fGraphWindow       : TfrmViewWindow;
    fHistory           : TFDQuery;
    fIndex             : TRecordingIndex;
    fIndexLock         : THandle;
    fInstrumentKind    : TInstrumentKind;
    fMap               : TFlightMap;
    fMapWindow         : TfrmViewWindow;
    fOpenedRecording   : Integer;
    fPanelProportions  : TPanelProportions;
    fPlanShown         : String;
    fPlayback          : TPlayback;
    fPlaybackUI        : Boolean;
    fPlot              : TTripPlot;
    fPreviewFile       : String;
    fRecorder          : TRecorderWorker;
    fRefresh           : UInt64;
    fRenderedGridIndex : Integer;
    fRenderedGridPlot  : TTripPlot;
    fRoot              : String;
    fSelected          : TStringList;
    fSimBriefWindow    : TfrmViewWindow;
    fSixPackWindow     : TfrmViewWindow;
    fSource            : TDataSource;
    fTreeUpdating      : Boolean;
    fUnsupportedShown  : String;
    fValueIndices      : TArray<Integer>;
    fViewStates        : TViewStateStore;
    Function  CanOpenRecording      (ID : Integer)          : Boolean;
    Function  CurrentTripID                                 : Integer;
    Function  GetChartsConfigure                            : TAction;
    Function  GetChartsHost                                 : TScrollBox;
    Function  GetFullView                                   : TAction;
    Function  GetGraphWindow                                : TAction;
    Function  GetMapHost                                    : TPanel;
    Function  GetMapWindow                                  : TAction;
    Function  GetZoomIn                                     : TAction;
    Function  GetZoomOut                                    : TAction;
    Function  PreviewRestricted     (Action : TBasicAction) : Boolean;
    Procedure ActivateDockPage      (Page : TTabSheet);
    Procedure AppException          (Sender : TObject; e : Exception);
    Procedure ApplyPlayback;
    Procedure ClearRecording;
    Procedure CursorMove            (Sender : TObject; Index : Integer);
    Procedure EnginesReturned       (Sender : TObject);
    Procedure EnginesWindowClick    (Sender : TObject);
    Procedure FinishDocking;
    Procedure FMCReturned           (Sender : TObject);
    Procedure FMCWindowClick        (Sender : TObject);
    Procedure GraphReturned         (Sender : TObject);
    Procedure InitializeDocking;
    Procedure MapReturned           (Sender : TObject);
    Procedure OpenDatabase          (Const Path : String);
    Procedure OpenPreview           (Const Path : String);
    Procedure PresentTrip           (TripID : Integer);
    Procedure RecordingChanged      (Sender : TBaseVirtualTree; Node : PVirtualNode; Column : TColumnIndex);
    Procedure RecordingChanging     (Sender : TBaseVirtualTree; OldNode, Node : PVirtualNode; OldColumn, NewColumn : TColumnIndex; Var AllowChange : Boolean);
    Procedure RecoverRecordings;
    Procedure RefreshHistory;
    Procedure ResetPanelLayout      (Sender : TObject);
    Procedure ResetPlayback;
    Procedure RestoreViewState      (Var Msg : TMessage); Message WM_APP + 83;
    Procedure SearchChanged         (Sender : TObject);
    Procedure SelectInstrumentFrames(Kind : TInstrumentKind);
    Procedure SimBriefReturned      (Sender : TObject);
    Procedure SimBriefWindowClick   (Sender : TObject);
    Procedure SixPackReturned       (Sender : TObject);
    Procedure SixPackWindowClick    (Sender : TObject);
    Procedure UpdateApplicationTitle;
    Procedure UpdateDockLayout;
    Procedure UpdatePlaybackControls;
    Procedure UpdatePoint           (Index : Integer);
    Procedure UpdateViewLayout;
   Public
    Procedure SelectRecording(ID : Integer);
    Property aChartsConfigure : TAction Read GetChartsConfigure;
    Property aFullView        : TAction Read GetFullView;
    Property aGraphWindow     : TAction Read GetGraphWindow;
    Property aMapWindow       : TAction Read GetMapWindow;
    Procedure UpdateGSXProgress(Labels : TStrings; Const Values : TArray<Double>);
    Property aZoomIn        : TAction Read GetZoomIn;
    Property aZoomOut       : TAction Read GetZoomOut;
    Property ChartsHost     : TScrollBox Read GetChartsHost;
    Property EnginesFrame   : TfraEngines Read fEnginesFrame;
    Property PFD737Frame    : TfraPFD737 Read fPFD737Frame;
    Property A320PFDFrame   : TfraA320PFD Read fA320PFDFrame;
    Property A320ECAMFrame  : TfraA320ECAM Read fA320ECAMFrame;
    Property InstrumentKind : TInstrumentKind Read fInstrumentKind;
    Property B38MEICASFrame : TfraB38MEICAS Read fB38MEICASFrame;
    Property EnginesWindow  : TfrmViewWindow Read fEnginesWindow;
    Property FMCFrame       : TfraFMC Read fFMCFrame;
    Property FMCWindow      : TfrmViewWindow Read fFMCWindow;
    Property GraphFrame     : TfraGraph Read fGraphFrame;
    Property GraphWindow    : TfrmViewWindow Read fGraphWindow;
    Property MapFrame       : TfraMap Read fMapFrame;
    Property MapHost        : TPanel Read GetMapHost;
    Property MapWindow      : TfrmViewWindow Read fMapWindow;
    Property RecordingRows  : TFDQuery Read fHistory;
    Property SimBriefFrame  : TfraSimBrief Read fSimBrief;
    Property SimBriefWindow : TfrmViewWindow Read fSimBriefWindow;
    Property SixPackFrame   : TfraSixPack Read fSixPackFrame;
    Property SixPackWindow  : TfrmViewWindow Read fSixPackWindow;
  End;

 Var
  frmMain : TfrmMain;

Implementation

{$R *.dfm}

 Uses
  frmWeatherU, frmTripInfoU, frmChartsConfigureU, frmAboutU, AppHelpU, ParameterNamesU, VersionU, RecordingTreeU;

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

 Procedure TfrmMain.AppException(Sender : TObject; e : Exception);

   Procedure LogStackTrace(e : Exception);
    Begin
     If Not e.StackTrace.IsEmpty Then
      Log(0, 'StackTrace = [' + #13#10 + e.StackTrace + #13#10 + ')');
    End;

  Begin
   Log(0, Format('MSFS24-FDR (ver. %s): %s at %p: %s', [VersionInfo.FileVersion, e.ClassName, ExceptAddr, e.Message]));
   LogStackTrace(e);
   Application.ShowException(e);
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

 Procedure TfrmMain.ResetPlayback;
  Begin
   FreeAndNil(fGhost);
   PlaybackTimer.Enabled := False;
   lATCMessage.Caption   := '';
   If fPlayback <> Nil Then
    fPlayback.Bind(Nil);
   UpdatePlaybackControls;
  End;

 Procedure TfrmMain.UpdatePlaybackControls;
  Var
   HasData : Boolean;
  Begin
   UpdateGhostControls;
   HasData               := (fPlayback <> Nil) And (fPlayback.Count > 0);
   aPlayPause.Enabled    := HasData And (fPlayback.Count > 1);
   aStopPlayback.Enabled := HasData;
   aBeginning.Enabled    := HasData;
   aEnding.Enabled       := HasData;
   aBack.Enabled         := HasData;
   aSkip.Enabled         := HasData;
   PlayBackRate.Enabled  := HasData;
   If fPlayback = Nil Then
    Exit;
   lPlayRate.ParentBiDiMode := False;
   lPlayRate.BiDiMode       := bdLeftToRight;
   lPlayRate.Caption        := fPlayback.RateCaption;
   Timeline.Enabled         := HasData And (fPlayback.Count > 1);
   If fPlayback.Playing Then
    Begin
     aPlayPause.ImageIndex := 65;
     aPlayPause.Caption    := Tr('Pauza');
    End
   Else
    Begin
     aPlayPause.ImageIndex := 64;
     aPlayPause.Caption    := Tr('Odtwórz');
    End;
   PlaybackTimer.Enabled := fPlayback.Playing;
  End;

 Procedure TfrmMain.ApplyPlayback;
  Begin
   If (fPlayback = Nil) Or (fPlayback.Count = 0) Then
    Begin
     UpdatePlaybackControls;
     Exit;
    End;
   fPlaybackUI := True;
   fPlayback.Present(fPlot);
   Try
    Timeline.Position := fPlayback.Position;
    UpdatePoint(fPlayback.Position);
   Finally
    fPlaybackUI := False;
   End;
   UpdatePlaybackControls;
  End;

 Procedure TfrmMain.PlayBackRateChangingEx(Sender : TObject; Var AllowChange : Boolean; NewValue : Integer; Direction : TUpDownDirection);
  Begin
   AllowChange := (NewValue >= 0) And (NewValue <= 8);
   If Not AllowChange Or (fPlayback = Nil) Then
    Exit;
   fPlayback.SetRate(NewValue, GetTickCount64);
   ApplyPlayback;
  End;

 Procedure TfrmMain.aBackExecute(Sender : TObject);
  Begin
   If fPlayback <> Nil Then
    Begin
     fPlayback.Skip( -30, GetTickCount64);
     ApplyPlayback;
    End;
  End;

 Procedure TfrmMain.aBeginningExecute(Sender : TObject);
  Begin
   If fPlayback <> Nil Then
    Begin
     fPlayback.Seek(0, GetTickCount64);
     ApplyPlayback;
    End;
  End;

 Procedure TfrmMain.ActionsUpdate(Action : TBasicAction; Var Handled : Boolean);
  Var
   HasPlot  : Boolean;
   HasTrip  : Boolean;
   HasGroup : Boolean;
  Begin
   If (Action = Nil) Or (csLoading In ComponentState) Or (fConfig = Nil) Then
    Exit;
   If (Action = aStart) Or (Action = aStop) Or (Action = aAuto) Then
    Begin
     TAction(Action).Enabled := (fPreviewFile = '') And Assigned(fRecorder);
     If TAction(Action).Enabled Then
      TAction(Action).Enabled := fRecorder.Snapshot.SimulatorSupported;
     Handled                  := True;
     Exit;
    End;
   If PreviewRestricted(Action) Then
    Begin
     TAction(Action).Enabled := False;
     Handled                 := True;
     Exit;
    End;
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
   HasTrip  := CurrentTripID > 0;
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
   If (Action = aChartsConfigure) Or (Action = aZoomIn) Or (Action = aZoomOut) Or (Action = aFullView) Or (Action = aExportKML) Or (Action = aExportLegacy) Then
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
   i : Integer;
  Begin
   UpdateApplicationTitle;
   If fDockViews <> Nil Then
    For i                                := 0 To fDockViews.Count - 1 Do
     TfrmDockView(fDockViews[i]).Caption := TfrmDockView(fDockViews[i]).Page.Caption;
   If Assigned(fCharts) Then
    Begin
     fCharts.Hint := Tr('Przeciaganie: przesuwanie czasu. Shift + przeciaganie: zoom zakresu. Ctrl + kolko: zoom. Dwuklik: calosc.');
     fCharts.Invalidate;
    End;
   If Assigned(fMap) Then
    fMap.Invalidate;
   If Assigned(fPlot) Then
    For i := 0 To fPlot.Labels.Count - 1 Do
     If i + 1 < DataGrid.RowCount Then
      DataGrid.Cells[0, i + 1] := ParameterCaption(fPlot.Labels[i]);

   If fIndex <> Nil Then
    RefreshHistory;
  End;

 Procedure TfrmMain.LanguageMenuMeasure(Sender : TObject; ACanvas : TCanvas; Var Width, Height : Integer);
  Var
   Item : TMenuItem;
   a    : TAction;
  Begin
   Item              := Sender As TMenuItem;
   a                 := Item.Action As TAction;
   ACanvas.Font.Name := LocaleFontName(UILanguageLocales[a.Tag - 1]);
   Width             := ACanvas.TextWidth(UILanguageNames[a.Tag - 1]) + 64;
   Height            := Max(28, ACanvas.TextHeight(UILanguageNames[a.Tag - 1]) + 8);
  End;

 Procedure TfrmMain.LanguageMenuDraw(Sender : TObject; ACanvas : TCanvas; ARect : TRect; Selected : Boolean);
  Var
   Item  : TMenuItem;
   a     : TAction;
   Text  : String;
   Code  : String;
   Flags : Cardinal;
  Begin
   Item := Sender As TMenuItem;
   a    := Item.Action As TAction;
   Code := UILanguageLocales[a.Tag - 1];
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
   Text  := UILanguageNames[a.Tag - 1];
   Flags := DT_SINGLELINE Or DT_VCENTER Or DT_NOPREFIX;
   If (Copy(Code, 1, 2) = 'ar') Or (Copy(Code, 1, 2) = 'he') Then
    Flags := Flags Or DT_RTLREADING;
   DrawText(ACanvas.Handle, PChar(Text), Length(Text), ARect, Flags);
  End;

 Procedure TfrmMain.UpdateLanguageActions;
  Var
   i      : Integer;
   Action : TAction;
   Item   : TMenuItem;
  Begin
   fPFD737Frame.aWindow.Caption := Tr('Osobne okno');
   miLanguage.AutoHotkeys       := maManual;
   For i                        := 0 To ActionList.ActionCount - 1 Do
    If ActionList.Actions[i] Is TAction Then
     Begin
      Action := TAction(ActionList.Actions[i]);
      If Action = aLangAuto Then
       Action.Checked := LanguagePreference = 'auto'
      Else If (Action.Category = 'Language') And (Action.Tag > 0) And (Action.Tag <= UILanguageCount) Then
       Begin
        Action.Caption := UILanguageNames[Action.Tag - 1];
        Action.Checked := (LanguagePreference <> 'auto') And (Language = UILanguageLocales[Action.Tag - 1]);
       End;
     End;
   For i := 0 To miLanguage.Count - 1 Do
    Begin
     Item := miLanguage.Items[i];
     If (Item.Action Is TAction) And (Item.Action.Tag > 0) And (Item.Action.Tag <= UILanguageCount) Then
      Item.Caption := UILanguageNames[Item.Action.Tag - 1];
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

 Procedure TfrmMain.ValueParameterHint(Sender : TObject; Shift : TShiftState; x, y : Integer);
  Var
   Col  : Integer;
   Row  : Integer;
   Name : String;
  Begin
   DataGrid.MouseToCell(x, y, Col, Row);
   If Assigned(fPlot) And (Row > 0) And (Row <= Length(fValueIndices)) Then
    Begin
     Name          := fPlot.Labels[fValueIndices[Row - 1]];
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
   UpdateApplicationTitle;
   fATC                  := TFSHudReplay.Create;
   fPlayback             := TPlayback.Create;
   PlayBackRate.Position := 4;
   UpdatePlaybackControls;
   fPreviewFile                      := PreviewRecordingArgument;
   aAnalysisLanding.Hint             := Tr('Shift + klik: nowy raport po polsku');
   aAnalysisLiftoff.Hint             := aAnalysisLanding.Hint;
   Application.OnException           := AppException;
   Application.OnHelp                := AppHelp;
   fPFD737Frame.aWindow.OnExecute    := SixPackWindowClick;
   fB38MEICASFrame.aWindow.OnExecute := EnginesWindowClick;
   fA320PFDFrame.aWindow.OnExecute   := SixPackWindowClick;
   fA320ECAMFrame.aWindow.OnExecute  := EnginesWindowClick;
   fSixPackFrame.ShowEmbeddedEngines := False;
   fFMCFrame.aWindow.OnExecute       := FMCWindowClick;
   fSixPackFrame.aWindow.OnExecute   := SixPackWindowClick;
   fEnginesFrame.aWindow.OnExecute   := EnginesWindowClick;
   fRoot                             := AppDataDirectory;
   {$IFDEF PORT_TEST}
   fAIModels := TAIModelInventory.Create(TestDataDirectory, TestDataDirectory);
   {$ELSE}
   fAIModels := TAIModelInventory.Create(GetEnvironmentVariable('LOCALAPPDATA'), GetEnvironmentVariable('APPDATA'));
   {$ENDIF}
   fAIModels.Start;
   fConfig     := TMemIniFile.Create(TPath.Combine(fRoot, IfThen(fPreviewFile <> '', 'preview.ini', 'settings.ini')), TEncoding.UTF8);
   fViewStates := TViewStateStore.Create(fConfig);
   LoadDisplayUnits(fConfig);
   SetLanguage(fConfig.ReadString('ui', 'language', 'auto'));

   UpdateLanguageActions;
   fSimBrief.Parent := SimBriefPage;
   fSimBrief.Align  := alClient;
   fSimBrief.Configure(fConfig);
   fSimBrief.aWindow.OnExecute := SimBriefWindowClick;
   fSelected                   := TStringList.Create;
   fSelected.StrictDelimiter   := True;
   fSelected.Delimiter         := ',';
   fSelected.DelimitedText     := fConfig.ReadString('charts', 'parameters', 'plane_altitude,vertical_speed,turb_eng_n1 #1');
   LeftPanel.Width             := EnsureRange(fConfig.ReadInteger('layout', 'left_width', 300), 180, Max(180, ClientWidth Div 2 - 100));
   RightPanel.Width            := EnsureRange(fConfig.ReadInteger('layout', 'right_width', 300), 180, Max(180, ClientWidth Div 2 - 100));
   fDockMapHeight              := EnsureRange(fConfig.ReadInteger('layout', 'map_height', 390), 100, Max(100, CenterPanel.Height - 180));
   MapPanel.Height             := fDockMapHeight;
   InstrumentsPanel.Height     := EnsureRange(fConfig.ReadInteger('layout', 'instruments_height', 176), 100, Max(100, CenterPanel.Height - 180));
   fDockSixPackWidth           := EnsureRange(fConfig.ReadInteger('layout', 'six_pack_width', 385), 100, Max(100, CenterPanel.Width - 100));
   SixPackPanel.Width          := fDockSixPackWidth;
   StartLog(TPath.Combine(fRoot, IfThen(fPreviewFile <> '', 'preview_debug.log', 'msfs_fdr_debug.log')), fConfig.ReadString('logging', 'verbose', 'INFO'));
   Log(2, 'Delphi VCL recorder started: ' + ParamStr(0));
   If (GetModuleHandle('GTIII-OSD64.dll') <> 0) Or (GetModuleHandle('GTIII-OSD64-VK.dll') <> 0) Then
    Log(1, 'ASUS GPU Tweak III OSD injected into recorder process');
   seInterval.Value := EnsureRange(fConfig.ReadInteger('recording', 'sample_interval_ms', 250), 1, 60000);
   aAuto.Checked    := fConfig.ReadBool('recording', 'enabled', True);
   fMapFrame.Parent := MapPanel;
   fMapFrame.Align  := alClient;
   fMapFrame.BindActions(aMapWindowExecute, ActionsUpdate);
   miMapWindow.Action := aMapWindow;
   fMap               := fMapFrame.Map;
   aTiles.Checked     := fConfig.ReadBool('map', 'online_tiles', aTiles.Checked);
   fMap.TilesEnabled  := aTiles.Checked;
   fGraphFrame.Parent := GraphPanel;
   fGraphFrame.Align  := alClient;
   fGraphFrame.BindActions(aChartsConfigureExecute, aGraphWindowExecute, ActionsUpdate);
   miZoomIn.Action          := aZoomIn;
   miZoomOut.Action         := aZoomOut;
   miFullView.Action        := aFullView;
   miChartsConfigure.Action := aChartsConfigure;
   miGraphWindow.Action     := aGraphWindow;
   FrameMenuOpen(Self);
   fCharts              := fGraphFrame.Charts;
   fCharts.Hint         := Tr('Przeciaganie: przesuwanie czasu. Shift + przeciaganie: zoom zakresu. Ctrl + kolko: zoom. Dwuklik: calosc.');
   fCharts.ShowHint     := True;
   fCharts.OnCursor     := CursorMove;
   fCharts.OnViewChange := ChartViewChanged;
   fSource              := TDataSource.Create(Self);
   ConfigureRecordingTree(vstRecordings);
   vstRecordings.OnFocusChanged  := RecordingChanged;
   vstRecordings.OnFocusChanging := RecordingChanging;
   vstRecordings.OnDblClick      := SelectTrip;
   eSearch.OnChange              := SearchChanged;
   fSource.OnDataChange          := Nil;
   fEventSource                  := TDataSource.Create(Self);
   fContactSource                := TDataSource.Create(Self);
   EventGrid.DataSource          := fEventSource;
   ContactGrid.DataSource        := fContactSource;
   If fPreviewFile <> '' Then
    OpenPreview(fPreviewFile)
   Else
    OpenDatabase(TPath.Combine(fRoot, 'flight_data.mfzi'));
   fViewStates.RegisterView('map', aMapWindowExecute);
   fViewStates.RegisterView('charts', aGraphWindowExecute);
   fViewStates.RegisterView('fmc', FMCWindowClick);
   fViewStates.RegisterView('six_pack', SixPackWindowClick);
   fViewStates.RegisterView('engines', EnginesWindowClick);
   fViewStates.RegisterView('simbrief', SimBriefWindowClick);
   InitializeDocking;
   UpdateDockLayout;
   fPanelProportions := TPanelProportions.Create;
   fPanelProportions.Add(LeftPanel, True, 180, 240);
   fPanelProportions.Add(RightPanel, True, 180, 240);
   fPanelProportions.Add(DockLeftSite, True, 100, 240, True);
   fPanelProportions.Add(DockRightSite, True, 100, 240, True);
   fPanelProportions.Add(DockTopSite, False, 100, 260, True);
   fPanelProportions.Add(DockBottomSite, False, 100, 260, True);
   fPanelProportions.Add(MapPanel, False, 100, 100);
   fPanelProportions.Add(InstrumentsPanel, False, 100, 100);
   fPanelProportions.Add(SixPackPanel, True, 100, 100);
   fPanelProportions.Capture;
   PostMessage(Handle, WM_APP + 83, 0, 0);
  End;

 Procedure TfrmMain.RestoreViewState(Var Msg : TMessage);
  Begin
   If Not fClosing And (fViewStates <> Nil) Then
    Begin
     fViewStates.Restore;
     RestoreDockTree(DockLeftSite, fConfig);
     RestoreDockTree(DockRightSite, fConfig);
     RestoreDockTree(DockTopSite, fConfig);
     RestoreDockTree(DockBottomSite, fConfig);
     If DockLeftSite.DockClientCount > 0 Then
      DockLeftSite.Width := Max(240, fConfig.ReadInteger('dock', 'left_width', 300));
     If DockRightSite.DockClientCount > 0 Then
      DockRightSite.Width := Max(240, fConfig.ReadInteger('dock', 'right_width', 300));
     If DockTopSite.DockClientCount > 0 Then
      DockTopSite.Height := Max(200, fConfig.ReadInteger('dock', 'top_height', 250));
     If DockBottomSite.DockClientCount > 0 Then
      DockBottomSite.Height := Max(200, fConfig.ReadInteger('dock', 'bottom_height', 250));
     PanelSplitMoved(Self);
     DockPageChanged(Self);
    End;
  End;

 Procedure TfrmMain.FormDestroy(Sender : TObject);
  Begin
   FreeAndNil(fGhost);
   FreeAndNil(fAIModels);
   fClosing := True;
   ResetPlayback;
   FreeAndNil(fPanelProportions);
   FinishDocking;
   If fViewStates <> Nil Then
    fViewStates.BeginShutdown;
   Application.OnHelp := Nil;
   FreeAndNil(fSimBriefWindow);
   FreeAndNil(fEnginesWindow);
   FreeAndNil(fSixPackWindow);
   FreeAndNil(fFMCWindow);
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
     fConfig.WriteInteger('layout', 'instruments_height', InstrumentsPanel.Height);
     If SixPackPanel.Align = alLeft Then
      fDockSixPackWidth := SixPackPanel.Width;
     fConfig.WriteInteger('layout', 'six_pack_width', fDockSixPackWidth);
     fConfig.UpdateFile;
    End;
   If Assigned(fMap) Then
    UpdateGSXProgress(Nil, Nil);
   fMap.SetData(Nil);
   If Assigned(fCharts) Then
    fCharts.SetData(Nil);
   FreeAndNil(fSimBrief);
   ResetPlayback;
   fPlot.Free;
   fATC.Free;
   fRecorder.Free;
   fPlayback.Free;
   fPlayback := Nil;
   fEvents.Free;
   fContacts.Free;
   fHistory.Free;
   fIndex.Free;
   If fIndexLock <> 0 Then
    CloseHandle(fIndexLock);
   fDB.Free;
   fViewStates.Free;
   fConfig.Free;
   fSelected.Free;
  End;

 Procedure TfrmMain.SimBriefWindowClick(Sender : TObject);
  Begin
   If fSimBriefWindow <> Nil Then
    Begin
     fSimBriefWindow.Close;
     Exit;
    End;
   fSimBriefWindow                       := TfrmViewWindow.Create(Self);
   fSimBriefWindow.ClientWidth           := 960;
   fSimBriefWindow.ClientHeight          := 650;
   fSimBriefWindow.Constraints.MinWidth  := 360;
   fSimBriefWindow.Constraints.MinHeight := 290;
   SimBriefPage.TabVisible               := False;
   Try
    fSimBriefWindow.Attach(fSimBrief, SimBriefPage, 'SimBrief Dispatch', SimBriefReturned, fViewStates, 'simbrief');
   Except
    FreeAndNil(fSimBriefWindow);
    SimBriefPage.TabVisible := True;
    Raise;
   End;
  End;

 Procedure TfrmMain.SimBriefReturned(Sender : TObject);
  Begin
   fSimBriefWindow := Nil;
   If Not fClosing Then
    Begin
     SimBriefPage.TabVisible := True;
     DataTabs.ActivePage     := SimBriefPage;
    End;
  End;

// Instrument slots retain one dock/float state when the aircraft-specific frame changes.

 Procedure TfrmMain.SelectInstrumentFrames(Kind : TInstrumentKind);
  Var
   PrimaryDetached : Boolean;
   EnginesDetached : Boolean;
   PrimaryBounds   : TRect;
   EngineBounds    : TRect;
  Begin
   If fInstrumentKind = Kind Then
    Exit;
   PrimaryDetached := fSixPackWindow <> Nil;
   EnginesDetached := fEnginesWindow <> Nil;
   If PrimaryDetached Then
    Begin
     PrimaryBounds := fSixPackWindow.BoundsRect;
     fSixPackWindow.Close;
    End;
   If EnginesDetached Then
    Begin
     EngineBounds := fEnginesWindow.BoundsRect;
     fEnginesWindow.Close;
    End;
   fInstrumentKind         := Kind;
   fSixPackFrame.Visible   := Not(Kind In [ikB38MPFD, ikA320PFD]);
   fPFD737Frame.Visible    := Kind = ikB38MPFD;
   fEnginesFrame.Visible   := Not(Kind In [ikB38MPFD, ikA320PFD]);
   fB38MEICASFrame.Visible := Kind = ikB38MPFD;
   fA320PFDFrame.Visible   := Kind = ikA320PFD;
   fA320ECAMFrame.Visible  := Kind = ikA320PFD;
   If PrimaryDetached Then
    Begin
     SixPackWindowClick(Self);
     fSixPackWindow.BoundsRect := PrimaryBounds;
    End;
   If EnginesDetached Then
    Begin
     EnginesWindowClick(Self);
     fEnginesWindow.BoundsRect := EngineBounds;
    End;
  End;

 Procedure TfrmMain.EnginesWindowClick(Sender : TObject);
  Begin
   If fEnginesWindow <> Nil Then
    Begin
     fEnginesWindow.Close;
     Exit;
    End;
   fEnginesWindow              := TfrmViewWindow.Create(Self);
   fEnginesWindow.ClientWidth  := 960;
   fEnginesWindow.ClientHeight := 650;
   If fInstrumentKind = ikB38MPFD Then
    Begin
     fEnginesWindow.ClientWidth  := 640;
     fEnginesWindow.ClientHeight := 840;
    End;
   fEnginesWindow.Constraints.MinWidth  := 360;
   fEnginesWindow.Constraints.MinHeight := 290;
   EnginePanel.Visible                  := False;
   Try
    If fInstrumentKind = ikB38MPFD Then
     fEnginesWindow.Attach(fB38MEICASFrame, EnginePanel, 'B38M EICAS', EnginesReturned, fViewStates, 'engines')
    Else If fInstrumentKind = ikA320PFD Then
     fEnginesWindow.Attach(fA320ECAMFrame, EnginePanel, 'A320 ECAM', EnginesReturned, fViewStates, 'engines')
    Else
     fEnginesWindow.Attach(fEnginesFrame, EnginePanel, 'Silniki', EnginesReturned, fViewStates, 'engines');
    UpdateViewLayout;
   Except
    FreeAndNil(fEnginesWindow);
    EnginePanel.Visible := True;
    Raise;
   End;
  End;

 Procedure TfrmMain.EnginesReturned(Sender : TObject);
  Begin
   fEnginesWindow := Nil;
   If Not fClosing Then
    Begin
     EnginePanel.Visible := True;
     UpdateViewLayout;
    End;
  End;

 Procedure TfrmMain.SixPackWindowClick(Sender : TObject);
  Begin
   If fSixPackWindow <> Nil Then
    Begin
     fSixPackWindow.Close;
     Exit;
    End;
   fSixPackWindow              := TfrmViewWindow.Create(Self);
   fSixPackWindow.ClientWidth  := 960;
   fSixPackWindow.ClientHeight := 650;
   If fInstrumentKind = ikB38MPFD Then
    Begin
     fSixPackWindow.ClientWidth  := 600;
     fSixPackWindow.ClientHeight := 680;
    End;
   fSixPackWindow.Constraints.MinWidth  := 360;
   fSixPackWindow.Constraints.MinHeight := 290;
   SixPackPanel.Visible                 := False;
   Try
    If fInstrumentKind = ikB38MPFD Then
     fSixPackWindow.Attach(fPFD737Frame, SixPackPanel, 'B38M PFD', SixPackReturned, fViewStates, 'six_pack')
    Else If fInstrumentKind = ikA320PFD Then
     fSixPackWindow.Attach(fA320PFDFrame, SixPackPanel, 'A320 PFD', SixPackReturned, fViewStates, 'six_pack')
    Else
     fSixPackWindow.Attach(fSixPackFrame, SixPackPanel, 'Six-pack', SixPackReturned, fViewStates, 'six_pack');
    UpdateViewLayout;
   Except
    FreeAndNil(fSixPackWindow);
    SixPackPanel.Visible := True;
    Raise;
   End;
  End;

 Procedure TfrmMain.SixPackReturned(Sender : TObject);
  Begin
   fSixPackWindow := Nil;
   If Not fClosing Then
    Begin
     SixPackPanel.Visible := True;
     UpdateViewLayout;
    End;
  End;

 Procedure TfrmMain.FMCWindowClick(Sender : TObject);
  Begin
   If fFMCWindow <> Nil Then
    Begin
     fFMCWindow.Close;
     Exit;
    End;
   fFMCWindow              := TfrmViewWindow.Create(Self);
   fFMCWindow.BorderStyle  := bsDialog;
   fFMCWindow.ClientWidth  := 440;
   fFMCWindow.ClientHeight := 750;
   fFMCPage.TabVisible     := False;
   Try
    fFMCWindow.Attach(fFMCFrame, fFMCPage, 'FMC/MCDU', FMCReturned, fViewStates, 'fmc');
   Except
    FreeAndNil(fFMCWindow);
    fFMCPage.TabVisible := True;
    Raise;
   End;
  End;

 Procedure TfrmMain.FMCReturned(Sender : TObject);
  Begin
   fFMCWindow := Nil;
   If Not fClosing Then
    Begin
     fFMCPage.TabVisible := True;
     DataTabs.ActivePage := fFMCPage;
    End;
  End;

 Procedure TfrmMain.FormResize(Sender : TObject);
  Begin
   If (StatusBar1 <> Nil) And (StatusBar1.Panels.Count > 0) Then
    StatusBar1.Panels.Items[0].Width := Self.ClientWidth;
   If (fPanelProportions <> Nil) And Not fClosing And (WindowState <> wsMinimized) Then
    Begin
     fPanelProportions.Apply;
     If MapPanel.Align = alTop Then
      fDockMapHeight := MapPanel.Height;
     If SixPackPanel.Align = alLeft Then
      fDockSixPackWidth := SixPackPanel.Width;
    End;
  End;

 Function TfrmMain.PreviewRestricted(Action : TBasicAction) : Boolean;
  Begin
   Result := (fPreviewFile <> '') And ((Action = aStart) Or (Action = aStop) Or (Action = aAuto) Or (Action = aOpen) Or (Action = aImportFlight) Or (Action = aImportPlan) Or (Action = aNewGroup) Or (Action = aAssign) Or (Action = aDelete) Or (Action = aRenameGroup) Or (Action = aDeleteGroup) Or (Action = aOverview));
  End;

 Procedure TfrmMain.OpenPreview(Const Path : String);
  Var
   i : Integer;
  Begin
   fDB := TFlightDatabase.Create(Path, TPath.Combine(ApplicationDirectory, 'sqlite3.dll'), True, True);
   If VarToStr(fDB.Connection.ExecSQLScalar('pragma quick_check')) <> 'ok' Then
    Raise Exception.Create('Invalid recording database');
   If Integer(fDB.Connection.ExecSQLScalar('select count(*) from trips')) <> 1 Then
    Raise Exception.Create('A recording file must contain exactly one trip');
   fHistory            := TFDQuery.Create(Nil);
   fHistory.Connection := fDB.Connection;
   fHistory.Open('select * from trips');
   Caption            := 'MSFS24-FDR - ' + ExtractFileName(Path);
   seInterval.Enabled := False;
   LeftPanel.Visible  := False;
   SplitLeft.Visible  := False;
   aAuto.Checked      := False;
   For i              := 0 To ActionList.ActionCount - 1 Do
    If PreviewRestricted(ActionList.Actions[i]) Then
     TAction(ActionList.Actions[i]).Enabled := False;
   fSimBrief.ReadOnly                       := True;
   PresentTrip(CurrentTripID);
  End;

 Procedure TfrmMain.OpenDatabase(Const Path : String);
  Var
   IndexPath  : String;
   LegacyPath : String;
  Begin
   If Assigned(fAnalysis) Then
    Exit;
   fEnginesFrame.Clear;
   fPFD737Frame.Clear;
   fB38MEICASFrame.Clear;
   fA320PFDFrame.Clear;
   fA320ECAMFrame.Clear;
   fSixPackFrame.Clear;
   fFMCFrame.Load(Nil, 0);
   fATC.Load(Nil, 0);
   fSHudMemo.Clear;
   fSimBrief.SetTrip(Nil, 0);
   fMap.SetData(Nil);
   fCharts.SetData(Nil);
   ResetPlayback;
   FreeAndNil(fPlot);
   fSource.DataSet := Nil;
   FreeAndNil(fHistory);
   fEventSource.DataSet   := Nil;
   fContactSource.DataSet := Nil;
   FreeAndNil(fEvents);
   FreeAndNil(fContacts);
   FreeAndNil(fRecorder);
   FreeAndNil(fDB);
   FreeAndNil(fIndex);
   fOpenedRecording := 0;
   // One writer/recovery owner per user. Never recover files written by another instance.
   If fIndexLock = 0 Then
    Begin
     fIndexLock := CreateFile(PChar(TPath.Combine(fRoot, 'recordings.lock')), GENERIC_READ Or GENERIC_WRITE, 0, Nil, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
     If fIndexLock = INVALID_HANDLE_VALUE Then
      Begin
       fIndexLock := 0;
       Raise Exception.Create(Tr('Magazyn nagrań jest już otwarty w innej instancji programu.'));
      End;
    End;
   IndexPath  := TPath.Combine(fRoot, 'flight_data.mfzi');
   LegacyPath := TPath.Combine(fRoot, 'flight_data.db');
   If SameText(ExtractFileExt(Path), '.mfzi') Then
    IndexPath := Path
   Else If SameText(ExtractFileExt(Path), '.db') Or SameText(ExtractFileExt(Path), '.mfzr') Then
    LegacyPath := Path;
   fIndex      := TRecordingIndex.Create(IndexPath, TPath.Combine(ApplicationDirectory, 'sqlite3.dll'));
   fIndex.Migrate(LegacyPath);
   {$IFNDEF PORT_TEST}
   If Not SameText(LegacyPath, TPath.Combine(ApplicationDirectory, 'flight_data.db')) Then
    fIndex.Migrate(TPath.Combine(ApplicationDirectory, 'flight_data.db'));
   {$ENDIF}
   fIndex.Discover(fRoot);
   {$IFNDEF PORT_TEST}
   If Not SameText(fRoot, ApplicationDirectory) Then
    fIndex.Discover(ApplicationDirectory, False);
   {$ENDIF}
   RecoverRecordings;
   fDB                 := TFlightDatabase.Create(':memory:', TPath.Combine(ApplicationDirectory, 'sqlite3.dll'));
   fHistory            := TFDQuery.Create(Nil);
   fHistory.Connection := fIndex.Connection;
   fSource.DataSet     := fHistory;
   RefreshHistory;
   fRecorder := TRecorderWorker.Create(IndexPath, ApplicationDirectory, fConfig.ReadString('flightplan', 'fallback_pln', ''), IfThen(fConfig.ReadBool('flightplan', 'bridge_enabled', True), EnsureRange(fConfig.ReadInteger('flightplan', 'bridge_port', 19787), 1024, 65535), 0)
   {$IFDEF PORT_TEST}, False{$ENDIF});
   fRecorder.Configure(seInterval.Value, aAuto.Checked);
   fRecorder.Start;
  End;

 Procedure TfrmMain.RecoverRecordings;
  Var
   q           : TFDQuery;
   ID          : Integer;
   Error       : String;
   Description : String;
  Begin
   q := TFDQuery.Create(Nil);
   Try
    q.Connection := fIndex.Connection;
    q.Open('select id,title,started_utc,status from trips where recovery_pending=1 order by started_utc desc,id desc');
    While Not q.Eof Do
     Begin
      ID          := q.FieldByName('id').AsInteger;
      Description := q.FieldByName('started_utc').AsString + ' ' + q.FieldByName('title').AsString;
      fIndex.Connection.ExecSQL('update trips set status=''interupted'' where id=:id', [ID]);
      If LocalizedMessageDlg(Tr('Znaleziono przerwane nagranie:') + sLineBreak + Description + sLineBreak + sLineBreak + Tr('Lot może być niepełny lub plik uszkodzony. Spróbować przywrócić nagranie?'), mtWarning, [mbYes, mbNo], 0) = mrYes Then
       Begin
        If Not fIndex.Recover(ID, Error) Then
         ShowMessage(Tr('Nie udało się przywrócić nagrania:') + sLineBreak + Error);
       End
      Else
      // Keep both file and metadata; a later launch will offer recovery again.
       fIndex.Connection.ExecSQL('update trips set recovery_pending=1 where id=:id', [ID]);
      q.Next;
     End;
   Finally
    q.Free;
   End;
  End;

 Function TfrmMain.CanOpenRecording(ID : Integer) : Boolean;
  Begin
   Result := False;
   If (ID = 0) Or (fHistory = Nil) Or Not fHistory.Active Then
    Exit;
   If Not fHistory.Locate('id', ID, []) Then
    Exit;
   Result := (fHistory.FieldByName('status').AsString <> 'recording') And (fHistory.FieldByName('status').AsString <> 'finalizing') And (fHistory.FieldByName('status').AsString <> 'error') And (fHistory.FieldByName('recovery_pending').AsInteger = 0) And (fHistory.FieldByName('relative_path').AsString <> '') And FileExists(fIndex.Resolve(fHistory.FieldByName('relative_path').AsString));
  End;

 Function TfrmMain.CurrentTripID : Integer;
  Begin
   Result := 0;
   If fPreviewFile <> '' Then
    Begin
     If (fDB <> Nil) And (fHistory <> Nil) And fHistory.Active Then
      Result := fHistory.FieldByName('id').AsInteger;
     Exit;
    End;
   If CanOpenRecording(RecordingNodeID(vstRecordings.FocusedNode)) And (fOpenedRecording = RecordingNodeID(vstRecordings.FocusedNode)) Then
    Result := fHistory.FieldByName('local_trip_id').AsInteger;
  End;

 Procedure TfrmMain.SelectRecording(ID : Integer);
  Var
   Node : PVirtualNode;
  Begin
   Node := vstRecordings.GetFirst;
   While Node <> Nil Do
    Begin
     If RecordingNodeID(Node) = ID Then
      Begin
       If Not CanOpenRecording(ID) Then
        Exit;
       If vstRecordings.FocusedNode = Node Then
        SelectTrip(Self)
       Else
        vstRecordings.FocusedNode   := Node;
       vstRecordings.Selected[Node] := True;
       Exit;
      End;
     Node := vstRecordings.GetNext(Node);
    End;
  End;

 Procedure TfrmMain.ClearRecording;
  Begin
   If Assigned(fAnalysis) Then
    Exit;
   fMap.SetData(Nil);
   fCharts.SetData(Nil);
   fEnginesFrame.Clear;
   fPFD737Frame.Clear;
   fB38MEICASFrame.Clear;
   fA320PFDFrame.Clear;
   fA320ECAMFrame.Clear;
   fSixPackFrame.Clear;
   fFMCFrame.Load(Nil, 0);
   fATC.Load(Nil, 0);
   fSHudMemo.Clear;
   fSimBrief.SetTrip(Nil, 0);
   ResetPlayback;
   FreeAndNil(fPlot);
   FreeAndNil(fEvents);
   FreeAndNil(fContacts);
   FreeAndNil(fDB);
   fOpenedRecording := 0;
   mPlan.Clear;
   DataGrid.RowCount := 2;
   DataGrid.Rows[1].Clear;
   CursorLabel.Caption := '';
   Timeline.Position   := 0;
  End;

 Procedure TfrmMain.RecordingChanging(Sender : TBaseVirtualTree; OldNode, Node : PVirtualNode; OldColumn, NewColumn : TColumnIndex; Var AllowChange : Boolean);
  Begin
   If fTreeUpdating Then
    Exit;
   AllowChange := Not Assigned(fAnalysis) And ((RecordingNodeID(Node) = 0) Or CanOpenRecording(RecordingNodeID(Node)));
  End;

 Procedure TfrmMain.RecordingChanged(Sender : TBaseVirtualTree; Node : PVirtualNode; Column : TColumnIndex);
  Begin
   If fTreeUpdating Or Assigned(fAnalysis) Then
    Exit;
   If CanOpenRecording(RecordingNodeID(Node)) Then
    SelectTrip(Sender)
   Else
    ClearRecording;
  End;

 Procedure TfrmMain.SearchChanged(Sender : TObject);
  Begin
   If (fIndex <> Nil) And Not fTreeUpdating Then
    RefreshHistory;
  End;

 Procedure TfrmMain.RefreshHistory;
  Var
   ID      : Integer;
   GroupID : Integer;
   Index   : Integer;
   q       : TFDQuery;
  Begin
   If fPreviewFile <> '' Then
    Exit;
   If (fHistory = Nil) Or fTreeUpdating Then
    Exit;
   fTreeUpdating := True;
   Try
    ID      := RecordingNodeID(vstRecordings.FocusedNode);
    GroupID := 0;
    If cbGroup.ItemIndex >= 0 Then
     GroupID := Integer(NativeInt(cbGroup.Items.Objects[cbGroup.ItemIndex]));
    cbGroup.Items.BeginUpdate;
    Try
     cbGroup.Items.Clear;
     cbGroup.Items.AddObject('', Nil);
     q := TFDQuery.Create(Nil);
     Try
      q.Connection := fIndex.Connection;
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
    fHistory.SQL.Text := 'select t.*,g.name as group_name from trips t left join trip_groups g on g.id=t.group_id order by julianday(t.started_utc) desc,t.id desc';
    fHistory.Open;
    FillRecordingTree(vstRecordings, fHistory, fIndex, GroupID, eSearch.Text, Language);
    If ID > 0 Then
     fHistory.Locate('id', ID, []);
   Finally
    fTreeUpdating := False;
   End;
   If (fOpenedRecording > 0) And (RecordingNodeID(vstRecordings.FocusedNode) = 0) Then
    ClearRecording;
  End;

 Procedure TfrmMain.GroupChanged(Sender : TObject);
  Begin
   RefreshHistory;
  End;

 Procedure TfrmMain.Tick(Sender : TObject);
  Var
   NowMS      : UInt64;
   State      : TRecorderState;
   StatusText : String;
  Begin
   UpdateGhostControls;
   UpdateDockLayout;
   If fPreviewFile <> '' Then
    Begin
     FinishAnalysis;
     Exit;
    End;
   If fBusy Or Not Assigned(fRecorder) Then
    Exit;
   fBusy := True;
   Try
    FinishAnalysis;
    fRecorder.Configure(seInterval.Value, aAuto.Checked);
    State := fRecorder.Snapshot;
    If State.UnsupportedSimulator = '' Then
     fUnsupportedShown := ''
    Else If fUnsupportedShown <> State.UnsupportedSimulator Then
     Begin
      fUnsupportedShown := State.UnsupportedSimulator;
      ShowMessage(Format(Tr('This simulator is not supported: %s. Please use Microsoft Flight Simulator 2024. Recording is disabled.'), [State.UnsupportedSimulator]));
     End;
    StatusText := State.Status;
    If (State.Error <> '') And Not SameText(State.Status, State.Error) Then
     StatusText := State.Status + ' | ' + State.Error;
    If StatusBar1.Panels.Items[0].Text <> StatusText Then
     StatusBar1.Panels.Items[0].Text := StatusText;
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
   f : TfrmTripInfo;
  Begin
   If CurrentTripID = 0 Then
    Exit;
   If (fHistory = Nil) Or Not fHistory.Active Or fHistory.IsEmpty Then
    Exit;
   f := TfrmTripInfo.Create(Self);
   Try
    If fPreviewFile <> '' Then
     f.LoadTrip(fDB.Connection, CurrentTripID)
    Else
     f.LoadTrip(fDB.Connection, CurrentTripID, fIndex.Connection, fOpenedRecording);
    f.ConfigureSimBrief(fConfig);
    If fPreviewFile <> '' Then
     f.btnImport.Enabled := False;
    f.ShowModal;
   Finally
    f.Free;
   End;
  End;

 Procedure TfrmMain.aImportFlightExecute(Sender : TObject);
  Begin
   If (fPreviewFile <> '') Or (fIndex = Nil) Then
    Exit;
   If ImportFlightDialog.Execute Then
    Try
     fIndex.Migrate(ImportFlightDialog.FileName);
     RecoverRecordings;
     RefreshHistory;
    Except
     On e : Exception Do
      ShowMessage(e.Message);
    End;
  End;

 Procedure TfrmMain.aOpenExecute(Sender : TObject);
  Begin
   If fPreviewFile <> '' Then
    Exit;
   If OpenDialog.Execute Then
    Try
     OpenDatabase(OpenDialog.FileName);
    Except
     On e : Exception Do
      ShowMessage(e.Message);
    End;
  End;

 Procedure TfrmMain.ResetPanelLayout(Sender : TObject);
  Var
   i : Integer;
  Begin
   If fDockViews <> Nil Then
    For i := 0 To fDockViews.Count - 1 Do
     TfrmDockView(fDockViews[i]).ManualDock(DataTabs, Nil, alClient);
   LeftPanel.Width         := 300;
   RightPanel.Width        := 300;
   fDockMapHeight          := 390;
   InstrumentsPanel.Height := 176;
   fDockSixPackWidth       := 385;
   SixPackPanel.Width      := 385;
   If MapPanel.Align = alTop Then
    MapPanel.Height := 390;
   UpdateViewLayout;
   fViewStates.Reset;
   fConfig.EraseSection('layout');
   fConfig.EraseSection('dock.tree');
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

 Procedure TfrmMain.PanelSplitMoved(Sender : TObject);
  Begin
   If fPanelProportions = Nil Then
    Exit;
   If Sender Is TSplitter Then
    Begin
     fPanelProportions.CaptureGroup(TSplitter(Sender).Parent, TSplitter(Sender).Align In [alLeft, alRight]);
     fPanelProportions.Apply;
    End
   Else If Sender Is TPanel Then
    Begin
     fPanelProportions.CaptureGroup(TPanel(Sender).Parent, TPanel(Sender).Align In [alLeft, alRight]);
     fPanelProportions.Apply;
    End
   Else
    fPanelProportions.Capture;
   If MapPanel.Align = alTop Then
    fDockMapHeight := MapPanel.Height;
   If SixPackPanel.Align = alLeft Then
    fDockSixPackWidth := SixPackPanel.Width;
  End;

 Procedure TfrmMain.InstrumentSplitMoved(Sender : TObject);
  Begin
   If SixPackPanel.Visible And EnginePanel.Visible Then
    fDockSixPackWidth := SixPackPanel.Width;
   PanelSplitMoved(Sender);
  End;

 Procedure TfrmMain.UpdateDockLayout;
  Var
   i       : Integer;
   State   : Integer;
   HasTabs : Boolean;
  Begin
   If fClosing Or (DataTabs = Nil) Then
    Exit;
   HasTabs  := False;
   For i    := 0 To DataTabs.PageCount - 1 Do
    HasTabs := HasTabs Or DataTabs.Pages[i].TabVisible;
   State    := 32;
   If HasTabs Then
    State := State Or 1;
   If DockLeftSite.DockClientCount > 0 Then
    State := State Or 2;
   If DockRightSite.DockClientCount > 0 Then
    State := State Or 4;
   If DockTopSite.DockClientCount > 0 Then
    State := State Or 8;
   If DockBottomSite.DockClientCount > 0 Then
    State := State Or 16;
   // No geometry mutation or realignment on unchanged timer ticks.
   If fDockLayoutState = State Then
    Exit;
   fDockLayoutState := State;
   DisableAlign;
   Try
    RightPanel.Visible         := HasTabs;
    SplitRight.Visible         := RightPanel.Visible;
    DockLeftSite.Visible       := DockLeftSite.DockClientCount > 0;
    DockRightSite.Visible      := DockRightSite.DockClientCount > 0;
    DockTopSite.Visible        := DockTopSite.DockClientCount > 0;
    DockBottomSite.Visible     := DockBottomSite.DockClientCount > 0;
    DockLeftSplitter.Visible   := DockLeftSite.Visible;
    DockRightSplitter.Visible  := DockRightSite.Visible;
    DockTopSplitter.Visible    := DockTopSite.Visible;
    DockBottomSplitter.Visible := DockBottomSite.Visible;
    // VCL orders equal-aligned siblings by their coordinates. Keep each
    // splitter next to its own pane, including after a pane was hidden.
    DockLeftSite.Left      := 0;
    DockLeftSplitter.Left  := DockLeftSite.Width;
    LeftPanel.Left         := DockLeftSite.Width + DockLeftSplitter.Width;
    SplitLeft.Left         := LeftPanel.Left + LeftPanel.Width;
    DockRightSite.Left     := ClientWidth;
    DockRightSplitter.Left := ClientWidth - DockRightSite.Width;
    RightPanel.Left        := DockRightSplitter.Left - RightPanel.Width;
    SplitRight.Left        := RightPanel.Left - SplitRight.Width;
    DockTopSite.Top        := ToolBar1.Top + ToolBar1.Height;
    DockTopSplitter.Top    := DockTopSite.Top + DockTopSite.Height;
    StatusBar1.Top         := ClientHeight;
    DockBottomSite.Top     := Max(0, ClientHeight - StatusBar1.Height - DockBottomSite.Height);
    DockBottomSplitter.Top := Max(0, DockBottomSite.Top - DockBottomSplitter.Height);
   Finally
    EnableAlign;
   End;
  End;

 Procedure TfrmMain.UpdateViewLayout;
  Begin
   If SixPackPanel.Align = alLeft Then
    fDockSixPackWidth             := SixPackPanel.Width;
   InstrumentsPanel.Visible       := SixPackPanel.Visible Or EnginePanel.Visible;
   SplitterInstruments.Visible    := InstrumentsPanel.Visible;
   SplitterSixPackEngines.Visible := SixPackPanel.Visible And EnginePanel.Visible;
   If EnginePanel.Visible Then
    Begin
     SixPackPanel.Align          := alLeft;
     SixPackPanel.Width          := Min(fDockSixPackWidth, Max(100, InstrumentsPanel.ClientWidth - SplitterSixPackEngines.Width - 100));
     SplitterSixPackEngines.Left := SixPackPanel.Left + SixPackPanel.Width;
    End
   Else
    SixPackPanel.Align := alClient;
   If MapPanel.Align = alTop Then
    fDockMapHeight := MapPanel.Height;
   ViewsPanel.DisableAlign;
   Try
    // Timeline belongs to CenterPanel; splitters can resize only view siblings.
    InstrumentsPanel.Top    := ViewsPanel.ClientHeight;
    SplitterInstruments.Top := Max(0, ViewsPanel.ClientHeight - InstrumentsPanel.Height - SplitterInstruments.Height);
    MapPanel.Top            := 0;
    SplitMap.Top            := MapPanel.Height;
    SplitMap.Visible        := MapPanel.Visible And GraphPanel.Visible;
    If GraphPanel.Visible Then
     Begin
      MapPanel.Align  := alTop;
      MapPanel.Height := fDockMapHeight;
     End
    Else
     MapPanel.Align := alClient;
   Finally
    ViewsPanel.EnableAlign;
    PanelSplitMoved(Self);
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
    fMapWindow.Attach(fMapFrame, MapPanel, 'Mapa lotu', MapReturned, fViewStates, 'map');
    aMapWindow.Checked := True;
    UpdateViewLayout;
   Except
    FreeAndNil(fMapWindow);
    Raise;
   End;
  End;

 Procedure TfrmMain.FetchWeather(Sender : TObject);
  Begin
   If fPreviewFile <> '' Then
    Exit;
   If CurrentTripID = 0 Then
    Exit;
   If fHistory.IsEmpty Then
    Exit;
   Try
    fRecorder.Command('metar', fIndex.PathFor(fOpenedRecording), CurrentTripID);
    StatusBar1.Panels.Items[0].Text := Tr('Zlecono METAR dla czasow startu i ladowania. Odswiez analize po pobraniu.');
   Except
    On e : Exception Do
     ShowMessage(e.Message);
   End;
  End;

 Procedure TfrmMain.aMetarExecute(Sender : TObject);
  Var
   f : TfrmWeather;
  Begin
   If (fDB = Nil) Or (fPlot = Nil) Or (CurrentTripID = 0) Then
    Exit;
   f := TfrmWeather.Create(Self);
   Try
    f.Load(fDB.Connection, CurrentTripID, (fPreviewFile = '') And (fRecorder <> Nil), FetchWeather);
    f.ShowModal;
   Finally
    f.Free;
   End;
  End;

 Procedure TfrmMain.aChangeLogExecute(Sender : TObject);
  Begin
   ShowChangeLog(Self);
  End;

 Procedure TfrmMain.aSettingsExecute(Sender : TObject);
  Var
   f : TfrmSettings;
  Begin
   f := TfrmSettings.Create(Self);
   Try
    f.Load(fConfig);
    f.btnResetLayout.OnClick := ResetPanelLayout;
    If f.ShowModal = mrOk Then
     Begin
      f.Save(fConfig);
      fCharts.Invalidate;
      UpdatePoint(Timeline.Position);

      UpdateLanguageActions;
      fPlanShown := '';
      If Assigned(fSimBrief) Then
       fSimBrief.Retranslate;
     End;
   Finally
    f.Free;
   End;
  End;

 Procedure TfrmMain.aSkipExecute(Sender : TObject);
  Begin
   If fPlayback <> Nil Then
    Begin
     fPlayback.Skip(30, GetTickCount64);
     ApplyPlayback;
    End;
  End;

 Procedure TfrmMain.aImportPlanExecute(Sender : TObject);
  Begin
   If fPreviewFile <> '' Then
    Exit;
   If Not PlanDialog.Execute Then
    Exit;
   Try
    fRecorder.Command('plan', PlanDialog.FileName);
    mPlan.Text := Tr('PLN import queued: ') + PlanDialog.FileName;
    ActivateDockPage(PlanPage);
   Except
    On e : Exception Do
     Begin
      Log(1, 'PLN import: ' + e.Message);
      ShowMessage(e.Message);
     End;
   End;
  End;

 Procedure TfrmMain.aStartExecute(Sender : TObject);
  Begin
   If (fPreviewFile <> '') Or (fRecorder = Nil) Then
    Exit;
   If Not fRecorder.Snapshot.SimulatorSupported Then
    Exit;
   fRecorder.Command('start');
   RefreshHistory;
  End;

 Procedure TfrmMain.aStopExecute(Sender : TObject);
  Begin
   If fPreviewFile <> '' Then
    Exit;
   aAuto.Checked := False;
   fRecorder.Configure(seInterval.Value, False);
   fRecorder.Command('stop');
   RefreshHistory;
  End;

 Procedure TfrmMain.aStopPlaybackExecute(Sender : TObject);
  Begin
   If fPlayback <> Nil Then
    Begin
     fPlayback.Stop(GetTickCount64);
     PlayBackRate.Position := 4;
     ApplyPlayback;
    End;
  End;

 Procedure TfrmMain.aRefreshExecute(Sender : TObject);
  Begin
   RefreshHistory;
   If Assigned(fPlot) Then
    SelectTrip(Self);
  End;

 Procedure TfrmMain.SelectTrip(Sender : TObject);
  Var
   ID   : Integer;
   Node : PVirtualNode;
  Begin
   If fPreviewFile <> '' Then
    Exit;
   If fTreeUpdating Or Assigned(fAnalysis) Then
    Exit;
   If vstRecordings.FocusedNode = Nil Then
    Begin
     Node := vstRecordings.GetFirst;
     While Node <> Nil Do
      Begin
       If CanOpenRecording(RecordingNodeID(Node)) Then
        Begin
         fTreeUpdating := True;
         Try
          vstRecordings.FocusedNode    := Node;
          vstRecordings.Selected[Node] := True;
         Finally
          fTreeUpdating := False;
         End;
         Break;
        End;
       Node := vstRecordings.GetNext(Node);
      End;
    End;
   ID := RecordingNodeID(vstRecordings.FocusedNode);
   If Not CanOpenRecording(ID) Then
    Exit;
   If fHistory.IsEmpty Then
    Begin
     fMap.SetData(Nil);
     fCharts.SetData(Nil);
     fEnginesFrame.Clear;
     fPFD737Frame.Clear;
     fB38MEICASFrame.Clear;
     fA320PFDFrame.Clear;
     fA320ECAMFrame.Clear;
     fSixPackFrame.Clear;
     fFMCFrame.Load(Nil, 0);
     fATC.Load(Nil, 0);
     fSHudMemo.Clear;
     ResetPlayback;
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
   fEnginesFrame.Clear;
   fPFD737Frame.Clear;
   fB38MEICASFrame.Clear;
   fA320PFDFrame.Clear;
   fA320ECAMFrame.Clear;
   fSixPackFrame.Clear;
   ResetPlayback;
   FreeAndNil(fPlot);
   fFMCFrame.Load(Nil, 0);
   fATC.Load(Nil, 0);
   fSHudMemo.Clear;
   fSimBrief.SetTrip(Nil, 0);
   FreeAndNil(fEvents);
   FreeAndNil(fContacts);
   FreeAndNil(fDB);
   fOpenedRecording := 0;
   fDB              := TFlightDatabase.Create(fIndex.PathFor(ID), TPath.Combine(ApplicationDirectory, 'sqlite3.dll'));
   fOpenedRecording := ID;
   PresentTrip(CurrentTripID);
  End;

 Procedure TfrmMain.PresentTrip(TripID : Integer);
  Begin
   ResetPlayback;
   fPlot             := fDB.LoadTrip(TripID);
   fRenderedGridPlot := Nil;
   fPlayback.Bind(fPlot);
   PlayBackRate.Position := 4;
   UpdatePlaybackControls;
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
   fATC.Load(fDB.Connection, fPlot.TripID);
   fSHudMemo.Clear;
   fFMCFrame.Load(fDB.Connection, fPlot.TripID);
   fFMCFrame.SetTime('');
   fEnginesFrame.Clear;
   fPFD737Frame.Clear;
   fB38MEICASFrame.Clear;
   fA320PFDFrame.Clear;
   fA320ECAMFrame.Clear;
   fSixPackFrame.Clear;
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
   i       : Integer;
  Begin
   Indices := TList<Integer>.Create;
   Try
    If fPlot <> Nil Then
     For Name In fSelected Do
      Begin
       i := fPlot.Labels.IndexOf(Name);
       If i >= 0 Then
        Indices.Add(i);
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

 Procedure TfrmMain.PlaybackTimerTimer(Sender : TObject);
  Begin
   UpdateDockLayout;
   If (fPlayback = Nil) Or Not fPlayback.Playing Then
    Begin
     UpdatePlaybackControls;
     Exit;
    End;
   fPlayback.Advance(GetTickCount64);
   ApplyPlayback;
  End;

 Procedure TfrmMain.ChartViewChanged(Sender : TObject);
  Var
   Span : Double;
   Full : Double;
   Lo   : Double;
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

 Procedure TfrmMain.UpdateApplicationTitle;
  Var
   v : TExeVersionInfo;
  Begin
   v                 := ExeVersionInfo;
   Application.Title := 'MSFS24-FDR';
   If v.Available Then
    Application.Title := Application.Title + ' ' + v.FileVersion;
   Caption            := Application.Title;
  End;

 Procedure TfrmMain.DockPageChanged(Sender : TObject);
  Var
   p : TTabSheet;
   i : Integer;
   c : TControl;
  Begin
   If (DataTabs = Nil) Or fClosing Then
    Exit;
   p := DataTabs.ActivePage;
   If p = Nil Then
    Exit;
   p.Realign;
   For i := 0 To p.ControlCount - 1 Do
    Begin
     c := p.Controls[i];
     If c Is TfrmDockView Then
      TfrmDockView(c).FitClient(Self)
     Else If (c Is TFrame) And (c.Align = alClient) Then
      If (c.Width <> p.ClientWidth) Or (c.Height <> p.ClientHeight) Then
       c.SetBounds(0, 0, p.ClientWidth, p.ClientHeight);
    End;
  End;

 Procedure TfrmMain.DockTabsMouseDown(Sender : TObject; Button : TMouseButton; Shift : TShiftState; x, y : Integer);
  Var
   i : Integer;
   j : Integer;
   p : TTabSheet;
  Begin
   fDockTab := Nil;
   If Button <> mbLeft Then
    Exit;
   i := DataTabs.IndexOfTabAt(x, y);
   If i < 0 Then
    Exit;
   For j := 0 To DataTabs.PageCount - 1 Do
    Begin
     p := DataTabs.Pages[j];
     If p.TabVisible Then
      Begin
       If i = 0 Then
        Begin
         If (p = fFMCPage) Or (p = SimBriefPage) Then
          fDockTab := p;
         Break;
        End;
       Dec(i);
      End;
    End;
   fDockMouse := Point(x, y);
  End;

 Procedure TfrmMain.DockTabsMouseMove(Sender : TObject; Shift : TShiftState; x, y : Integer);
  Var
   p : TTabSheet;
   w : TfrmViewWindow;
  Begin
   If Not(ssLeft In Shift) Then
    Begin
     fDockTab := Nil;
     Exit;
    End;
   If (fDockTab = Nil) Or ((Abs(x - fDockMouse.x) < 8) And (Abs(y - fDockMouse.y) < 8)) Then
    Exit;
   p        := fDockTab;
   fDockTab := Nil;
   If p = fFMCPage Then
    Begin
     FMCWindowClick(Self);
     w := fFMCWindow;
    End
   Else
    Begin
     SimBriefWindowClick(Self);
     w := fSimBriefWindow;
    End;
   If w <> Nil Then
    w.BeginDrag(False);
  End;

 Procedure TfrmMain.NativeDockDrop(Sender : TObject; Source : TDragDockObject; x, y : Integer);
  Var
   p : TPanel;
  Begin
   If Not(Sender Is TPanel) Then
    Exit;
   p := TPanel(Sender);
   If p.Align In [alLeft, alRight] Then
    p.Width := Max(240, p.Width)
   Else
    p.Height := Max(200, p.Height);
   PanelSplitMoved(Sender);
  End;

 Procedure TfrmMain.NativeUnDock(Sender : TObject; Client : TControl; NewTarget : TWinControl; Var Allow : Boolean);
  Var
   p : TPanel;
  Begin
   Allow := True;
   If Not(Sender Is TPanel) Then
    Exit;
   p := TPanel(Sender);
   If p.DockClientCount <= 1 Then
    If p.Align In [alLeft, alRight] Then
     p.Width := 12
    Else
     p.Height := 12;
  End;

 Procedure TfrmMain.NativeDockOver(Sender : TObject; Source : TDragDockObject; x, y : Integer; State : TDragState; Var Accept : Boolean);
  Begin
   Accept := (Source.Control Is TfrmDockView) Or (Source.Control Is TfrmViewWindow);
  End;

 Procedure TfrmMain.InitializeDocking;
  Var
   Pages : TList;
   i     : Integer;
   v     : TfrmDockView;
   c     : TComponent;
  Begin
   fDockViews := TList.Create;
   Pages      := TList.Create;
   Try
    For i := 0 To DataTabs.PageCount - 1 Do
     Pages.Add(DataTabs.Pages[i]);
    For i := 0 To Pages.Count - 1 Do
     Begin
      If (TTabSheet(Pages[i]) = fFMCPage) Or (TTabSheet(Pages[i]) = SimBriefPage) Then
       Continue;
      v := TfrmDockView.Create(Self);
      fDockViews.Add(v);
      v.Attach(TTabSheet(Pages[i]), DataTabs);
      TTabSheet(v.Parent).PageIndex := i;
     End;
    For i := 0 To fDockViews.Count - 1 Do
     TfrmDockView(fDockViews[i]).Restore(fConfig);
    c := FindComponent(fConfig.ReadString('dock', 'active_page', PlanPage.Name));
    If c Is TTabSheet Then
     ActivateDockPage(TTabSheet(c))
    Else
     ActivateDockPage(PlanPage);
   Finally
    Pages.Free;
   End;
  End;

 Procedure TfrmMain.ActivateDockPage(Page : TTabSheet);
  Var
   i : Integer;
   v : TfrmDockView;
  Begin
   If (Page.PageControl = DataTabs) Or (fDockViews = Nil) Then
    Begin
     DataTabs.ActivePage := Page;
     Exit;
    End;
   For i := 0 To fDockViews.Count - 1 Do
    Begin
     v := TfrmDockView(fDockViews[i]);
     If v.Page = Page Then
      Begin
       If v.Parent Is TTabSheet Then
        TTabSheet(v.Parent).PageControl.ActivePage := TTabSheet(v.Parent)
       Else
        v.BringToFront;
       Exit;
      End;
    End;
  End;

 Procedure TfrmMain.FinishDocking;
  Var
   i : Integer;
   v : TfrmDockView;
   p : TTabSheet;
  Begin
   If fDockViews = Nil Then
    Exit;
   p := DataTabs.ActivePage;
   If p <> Nil Then
    Begin
     If (p.ControlCount > 0) And (p.Controls[0] Is TfrmDockView) Then
      p := TfrmDockView(p.Controls[0]).Page;
     fConfig.WriteString('dock', 'active_page', p.Name);
    End;
   SaveDockTree(DockLeftSite, fConfig);
   SaveDockTree(DockRightSite, fConfig);
   SaveDockTree(DockTopSite, fConfig);
   SaveDockTree(DockBottomSite, fConfig);
   fConfig.WriteInteger('dock', 'left_width', DockLeftSite.Width);
   fConfig.WriteInteger('dock', 'right_width', DockRightSite.Width);
   fConfig.WriteInteger('dock', 'top_height', DockTopSite.Height);
   fConfig.WriteInteger('dock', 'bottom_height', DockBottomSite.Height);
   For i := 0 To fDockViews.Count - 1 Do
    TfrmDockView(fDockViews[i]).Save(fConfig);
   For i := fDockViews.Count - 1 Downto 0 Do
    Begin
     v := TfrmDockView(fDockViews[i]);
     v.ReleasePage;
     v.Free;
    End;
   FreeAndNil(fDockViews);
  End;

 Procedure TfrmMain.CursorMove(Sender : TObject; Index : Integer);
  Begin
   If (fPlayback <> Nil) And fPlayback.Playing Then
    Exit;
   If fPlot <> Nil Then
    fPlot.ClearDisplayPoint;
   If Timeline.Position = Index Then
    Exit;
   If Not fPlaybackUI And (fPlayback <> Nil) Then
    fPlayback.Seek(Index, GetTickCount64);
   Timeline.Position := Index;
   UpdatePoint(Index);
  End;

 Procedure TfrmMain.TimelineChange(Sender : TObject);
  Begin
   If fPlaybackUI Then
    Exit;
   If Not fPlaybackUI And (fPlot <> Nil) Then
    fPlot.ClearDisplayPoint;
   If Not fPlaybackUI And (fPlayback <> Nil) Then
    fPlayback.Seek(Timeline.Position, GetTickCount64);
   UpdatePoint(Timeline.Position);
  End;

 Procedure TfrmMain.ValueSearchChange(Sender : TObject);
  Begin
   fRenderedGridPlot := Nil;
   UpdatePoint(Timeline.Position);
  End;

 Procedure TfrmMain.UpdateGSXProgress(Labels : TStrings; Const Values : TArray<Double>);
  Var
   AnyVisible : Boolean;

   Function Read(Const Name : String) : Double;
    Var
     i : Integer;
    Begin
     Result := NaN;
     If Labels = Nil Then
      Exit;
     i := Labels.IndexOf('GSX.' + Name);
     If (i >= 0) And (i < Length(Values)) Then
      If Not IsInfinite(Values[i]) Then
       Result := Values[i];
    End;

   Procedure Bar(Control : TProgressBar; State, Current, Target : Double);
    Var
     Style    : TProgressBarStyle;
     Position : Integer;
    Begin
     Style    := pbstMarquee;
     Position := 0;
     If Not IsNan(Current) And Not IsNan(Target) Then
      If (Current >= 0) And (Target > 0) Then
       Begin
        Style    := pbstNormal;
        Position := Round(EnsureRange(Current / Target, 0.0, 1.0) * 100);
       End;
     If (State = 6) And (Style = pbstMarquee) Then
      Begin
       Style    := pbstNormal;
       Position := 100;
      End;
     If Control.Style <> Style Then
      Control.Style := Style;
     If Control.Position <> Position Then
      Control.Position := Position;
    End;

   Procedure Service(Panel : TPanel; LabelControl : TLabel; Progress, CargoProgress : TProgressBar; Const Kind : String);
    Var
     State   : Double;
     Current : Double;
     Target  : Double;
     Visible : Boolean;
     Name    : String;
     Text    : String;
    Begin
     Name    := 'GSX.FSDT_GSX_' + Kind + '_STATE';
     State   := Read('FSDT_GSX_' + Kind + '_STATE');
     Visible := False;
     If Not IsNan(State) Then
      Visible := (State = 4) Or (State = 5) Or (State = 6);
     If Panel.Visible <> Visible Then
      Panel.Visible := Visible;
     If Not Visible Then
      Begin
       If Progress.Style <> pbstNormal Then
        Progress.Style   := pbstNormal;
       Progress.Position := 0;
       If CargoProgress <> Nil Then
        Begin
         CargoProgress.Style    := pbstNormal;
         CargoProgress.Position := 0;
        End;
       Exit;
      End;
     AnyVisible            := True;
     Text                  := ParameterCaption(Name) + ': ' + ParameterDisplayText(Name, State);
     LabelControl.Hint     := GSXDisplayText(Name, Labels, Values);
     LabelControl.ShowHint := True;
     Current               := NaN;
     Target                := NaN;
     If (Kind = 'BOARDING') Or (Kind = 'DEBOARDING') Then
      Begin
       Current       := Read('FSDT_GSX_NUMPASSENGERS_' + Kind + '_TOTAL');
       Target        := Read('FSDT_GSX_NUMPASSENGERS');
       Progress.Hint := ParameterCaption('GSX.FSDT_GSX_NUMPASSENGERS_' + Kind + '_TOTAL');
       Bar(CargoProgress, State, Read('FSDT_GSX_' + Kind + '_CARGO_PERCENT'), 100);
       CargoProgress.Hint := ParameterCaption('GSX.FSDT_GSX_' + Kind + '_CARGO_PERCENT');
      End
     Else If Kind = 'REFUELING' Then
      Begin
       Current       := Read('FSDT_GSX_FUEL_COUNTER');
       Target        := Read('FSDT_GSX_FUEL_COUNTER_MAX');
       Progress.Hint := ParameterCaption('GSX.FSDT_GSX_FUEL_COUNTER_MAX');
       If Not IsNan(Current) And Not IsNan(Target) Then
        If (Current >= 0) And (Target > 0) Then
         Text := Text + ' (' + ParameterCaption('GSX.FSDT_GSX_FUEL_COUNTER') + ': ' + Format('%.0f/%.0f', [Current, Target]) + ')';
      End;
     Bar(Progress, State, Current, Target);
     If LabelControl.Caption <> Text Then
      LabelControl.Caption := Text;
    End;

  Begin
   AnyVisible := False;
   Service(GSXBoardingProgressPanel, GSXBoardingProgressLabel, GSXBoardingProgress, GSXBoardingCargoProgress, 'BOARDING');
   Service(GSXDeboardingProgressPanel, GSXDeboardingProgressLabel, GSXDeboardingProgress, GSXDeboardingCargoProgress, 'DEBOARDING');
   Service(GSXRefuelingProgressPanel, GSXRefuelingProgressLabel, GSXRefuelingProgress, Nil, 'REFUELING');
   Service(GSXCateringProgressPanel, GSXCateringProgressLabel, GSXCateringProgress, Nil, 'CATERING');
   Service(GSXDepartureProgressPanel, GSXDepartureProgressLabel, GSXDepartureProgress, Nil, 'DEPARTURE');
   Service(GSXDeiceProgressPanel, GSXDeiceProgressLabel, GSXDeiceProgress, Nil, 'DEICE');
   If GSXProgressPanel.Visible <> AnyVisible Then
    GSXProgressPanel.Visible := AnyVisible;
  End;

 Procedure TfrmMain.UpdatePoint(Index : Integer);
  Var
   FlapCount   : Integer;
   p           : TPlotPoint;
   i           : Integer;
   r           : Integer;
   g           : Integer;
   Search      : String;
   Name        : String;
   CaptionText : String;
  Begin
   If Not Assigned(fPlot) Or (Index < 0) Or (Index >= fPlot.Points.Count) Then
    Exit;
   p         := fPlot.DisplayPoint(Index);
   FlapCount := RecordedFlapPositionCount(fPlot.Labels, p.Values);
   fFMCFrame.SetTime(p.Time);
   lATCMessage.Caption := fATC.LastMessageAt(p.Time, 30);
   lATCMessage.Hint    := lATCMessage.Caption;
   If fSHudMemo.Text <> fATC.TextAt(p.Time) Then
    Begin
     fSHudMemo.Text     := fATC.TextAt(p.Time);
     fSHudMemo.SelStart := Length(fSHudMemo.Text);
     fSHudMemo.Perform(EM_SCROLLCARET, 0, 0);
    End;
   B38MInfoOnLeft            := fConfig.ReadBool('instruments', 'b38m_flight_info_left', True);
   B38MInfoEnabled           := fConfig.ReadBool('instruments', 'b38m_flight_info', True);
   B38MAoAEnabled            := fConfig.ReadBool('instruments', 'b38m_aoa', False);
   B38MFlightDirectorEnabled := fConfig.ReadBool('instruments', 'b38m_flight_director', True);
   InstrumentKindOverride    := fConfig.ReadInteger('debug', 'instrument_kind', -1);
   SelectInstrumentFrames(InstrumentProfile(fPlot, Index).Kind);
   fB38MEICASFrame.SetPoint(fPlot, Index);
   fA320PFDFrame.SetPoint(fPlot, Index);
   fA320ECAMFrame.SetPoint(fPlot, Index);
   fEnginesFrame.SetPoint(fPlot, Index);
   fSixPackFrame.SetPoint(fPlot, Index);
   fPFD737Frame.SetPoint(fPlot, Index);
   fMap.SetCursor(Index);
   fCharts.SetCursor(Index);
   UpdateGSXProgress(fPlot.Labels, p.Values);
   CursorLabel.Caption := p.Time;
   If fPlaybackUI And (fRenderedGridPlot = fPlot) And (fRenderedGridIndex = Index) Then
    Exit;
   fRenderedGridPlot  := fPlot;
   fRenderedGridIndex := Index;
   Search             := LowerCase(Trim(eValueSearch.Text));
   SetLength(fValueIndices, fPlot.Labels.Count);
   r                   := 0;
   g                   := 1;
   GSXGrid.RowCount    := Max(2, fPlot.Labels.Count + 1);
   GSXGrid.Cells[0, 0] := 'GSX Pro';
   GSXGrid.Cells[1, 0] := Tr('Wartość');
   For i               := 0 To fPlot.Labels.Count - 1 Do
    Begin
     Name        := fPlot.Labels[i];
     CaptionText := ParameterCaption(Name);
     If Pos('GSX.', Name) = 1 Then
      Begin
       GSXGrid.Cells[0, g] := CaptionText;
       GSXGrid.Cells[1, g] := '';
       If Not IsNan(p.Values[i]) Then
        GSXGrid.Cells[1, g] := GSXDisplayText(Name, fPlot.Labels, p.Values);
       Inc(g);
      End;
     If (Search = '') Or (Pos(Search, LowerCase(Name)) > 0) Or (Pos(Search, LowerCase(CaptionText)) > 0) Then
      Begin
       fValueIndices[r] := i;
       Inc(r);
      End;
    End;
   SetLength(fValueIndices, r);
   GSXGrid.RowCount := Max(2, g);
   If g = 1 Then
    Begin
     GSXGrid.Cells[0, 1] := '';
     GSXGrid.Cells[1, 1] := '';
    End;
   DataGrid.RowCount    := Max(2, r + 1);
   DataGrid.Cells[0, 0] := Tr('Parametr');
   DataGrid.Cells[1, 0] := Tr('Wartość');
   For r                := 0 To High(fValueIndices) Do
    Begin
     i                        := fValueIndices[r];
     DataGrid.Cells[0, r + 1] := ParameterCaption(fPlot.Labels[i]);
     DataGrid.Cells[1, r + 1] := '';
     If Not IsNan(p.Values[i]) Then
      DataGrid.Cells[1, r + 1] := ParameterDisplayText(fPlot.Labels[i], p.Values[i], fPlot.AircraftTypeICAO, fPlot.AircraftTitle, FlapCount);
     If Pos('GSX.', fPlot.Labels[i]) = 1 Then
      DataGrid.Cells[1, r + 1] := GSXDisplayText(fPlot.Labels[i], fPlot.Labels, p.Values);
    End;
   If Length(fValueIndices) = 0 Then
    Begin
     DataGrid.Cells[0, 1] := '';
     DataGrid.Cells[1, 1] := '';
    End;
  End;

 Procedure TfrmMain.aExportLegacyExecute(Sender : TObject);
  Begin
   If (fDB = Nil) Or (fPlot = Nil) Or (fPlot.TripID <= 0) Then
    Exit;
   LegacyExportDialog.FileName := 'flight-' + IntToStr(fPlot.TripID) + '-legacy.db';
   If LegacyExportDialog.Execute Then
    ExportLegacyFlight(fDB.Connection, fPlot.TripID, LegacyExportDialog.FileName);
  End;

 Procedure TfrmMain.aEndingExecute(Sender : TObject);
  Begin
   If fPlayback <> Nil Then
    Begin
     fPlayback.Seek(fPlayback.Count - 1, GetTickCount64);
     ApplyPlayback;
    End;
  End;

 Procedure TfrmMain.aExportKMLExecute(Sender : TObject);
  Begin
   If CurrentTripID = 0 Then
    Exit;
   If fHistory.IsEmpty Then
    Exit;
   SaveDialog.FileName := 'flight-' + fHistory.FieldByName('id').AsString + '.kml';
   If SaveDialog.Execute Then
    fDB.ExportKML(CurrentTripID, SaveDialog.FileName);
  End;

 Procedure TfrmMain.aDeleteExecute(Sender : TObject);
  Var
   ID : Integer;
  Begin
   If fPreviewFile <> '' Then
    Exit;
   If CurrentTripID = 0 Then
    Exit;
   If fHistory.IsEmpty Then
    Exit;
   ID := RecordingNodeID(vstRecordings.FocusedNode);
   If ID = fRecorder.Snapshot.Trip Then
    Begin
     ShowMessage(Tr('Najpierw zako'#324'cz nagrywanie tego lotu.'));
     Exit;
    End;
   If LocalizedMessageDlg(Tr('Usun'#261#263' wybrany lot wraz z danymi?'), mtConfirmation, [mbYes, mbNo], 0) = mrYes Then
    Begin
     ClearRecording;
     If Not DeleteFile(PChar(fIndex.PathFor(ID))) Then
      RaiseLastOSError;
     fIndex.Connection.ExecSQL('delete from trips where id=:id', [ID]);
     RefreshHistory;
    End;
  End;

 Procedure TfrmMain.aNewGroupExecute(Sender : TObject);
  Var
   Name : String;
  Begin
   If fPreviewFile <> '' Then
    Exit;
   Name := '';
   If LocalizedInputQuery(Tr('Nowa grupa'), Tr('Nazwa:'), Name) And (Trim(Name) <> '') Then
    Begin
     fIndex.Connection.ExecSQL('insert into trip_groups(name,sort_order) values (:n,(select coalesce(max(sort_order),0)+1 from trip_groups))', [Trim(Name)]);
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
   If fPreviewFile <> '' Then
    Exit;
   If CurrentTripID = 0 Then
    Exit;
   If fHistory.IsEmpty Then
    Exit;
   TripID := fHistory.FieldByName('id').AsInteger;
   q      := TFDQuery.Create(Nil);
   Dialog := TfrmAssignGroup.Create(Self);
   Try
    q.Connection := fIndex.Connection;
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
     fIndex.Connection.ExecSQL('update trips set group_id=null where id=:id', [TripID])
    Else
     fIndex.Connection.ExecSQL('update trips set group_id=:g where id=:id', [GroupID, TripID]);
   Finally
    Dialog.Free;
    q.Free;
   End;
   RefreshHistory;

  End;

 Procedure TfrmMain.aFitExecute(Sender : TObject);
  Begin
   fMap.Fit;
  End;

 Procedure TfrmMain.UpdateGhostControls;
  Var
   s : TGhostState;
  Begin
   aGhostPlayPause.Enabled := (fPlot <> Nil) And (fPlot.Points.Count > 0);
   aGhostStop.Enabled      := fGhost <> Nil;
   aGhostBack.Enabled      := fGhost <> Nil;
   aGhostForward.Enabled   := fGhost <> Nil;
   aGhostPlayPause.Checked := False;
   If fGhost <> Nil Then
    Begin
     s                       := fGhost.Snapshot;
     aGhostPlayPause.Checked := s.Playing;
     If s.Failed Then
      Begin
       FreeAndNil(fGhost);
       ShowMessage(s.Error);
      End;
    End;
   If aGhostPlayPause.Checked Then
    aGhostPlayPause.ImageIndex := 65
   Else
    aGhostPlayPause.ImageIndex := 64;
  End;

 Procedure TfrmMain.aGhostBackExecute(Sender : TObject);
  Begin
   If fGhost <> Nil Then
    fGhost.Skip( -10);
  End;

 Procedure TfrmMain.aGhostForwardExecute(Sender : TObject);
  Begin
   If fGhost <> Nil Then
    fGhost.Skip(10);
  End;

 Procedure TfrmMain.aGhostPlayPauseExecute(Sender : TObject);
  Begin
   If fGhost <> Nil Then
    fGhost.Toggle
   Else If (fPlot <> Nil) And (fPlot.Points.Count > 0) Then
    Try
     fGhost := TGhostReplayThread.Create(fPlot, TPath.Combine(ApplicationDirectory, 'SimConnect.dll'),
     fConfig.ReadString('ghost', 'vmr_file', ''), fConfig.ReadInteger('ghost', 'refresh_hz', 30), fPlayback.Time, fAIModels);
     fGhost.Start;
    Except
     On e : Exception Do
      Begin
       FreeAndNil(fGhost);
       ShowMessage(e.Message);
      End;
    End;
   UpdateGhostControls;
  End;

 Procedure TfrmMain.aGhostStopExecute(Sender : TObject);
  Begin
   FreeAndNil(fGhost);
   UpdateGhostControls;
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
    fGraphWindow.Attach(fGraphFrame, GraphPanel, 'Wykresy lotu', GraphReturned, fViewStates, 'charts');
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
   j             : TJSONObject;
   Key           : String;
   Prompt        : String;
   TableName     : String;
   Provider      : String;
   Model         : String;
   f             : TfrmReport;
  Begin
   If CurrentTripID = 0 Then
    Exit;
   If fHistory.IsEmpty Or Assigned(fAnalysis) Then
    Exit;
   TableName := 'trip_touchdowns';
   If Sender = aAnalysisLiftoff Then
    TableName := 'trip_liftoffs';
   q          := TFDQuery.Create(Nil);
   j          := TJSONObject.Create;
   Try
    q.Connection := fDB.Connection;
    q.Open('select * from ' + TableName + ' where trip=' + IntToStr(CurrentTripID) + ' order by id desc limit 1');
    If q.IsEmpty Then
     Begin
      ShowMessage(Tr('Brak zarejestrowanego kontaktu z pasem dla tego lotu.'));
      Exit;
     End;
    If (q.FieldByName('analysis_report').AsString <> '') And (GetKeyState(VK_SHIFT) >= 0) Then
     Begin
      f := TfrmReport.Create(Self);
      f.SetReport(q.FieldByName('analysis_report').AsString, TableName = 'trip_touchdowns');
      f.Show;
      Exit;
     End;
    Key      := fConfig.ReadString('ai', 'gemini_api_key', '');
    Provider := fConfig.ReadString('ai', 'provider', 'codex');
    If SameText(Provider, 'gemini') And (Key = '') Then
     Begin
      ShowMessage(Tr('Ustaw ai/gemini_api_key w settings.ini i uruchom ponownie.'));
      Exit;
     End;
    FreeAndNil(j);
    ReadAnalysisWindow(fConfig, TableName = 'trip_touchdowns', BeforeSeconds, AfterSeconds);
    j := BuildContactContext(fDB, q, BeforeSeconds, AfterSeconds);
    j.AddPair('aircraft', fHistory.FieldByName('title').AsString);
    If TableName = 'trip_touchdowns' Then
     Prompt := BuildAnalysisPrompt(j.ToJSON, 'l'#261'dowanie')
    Else
     Prompt := BuildAnalysisPrompt(j.ToJSON, 'start');
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
    j.Free;
    q.Free;
   End;
  End;

 Procedure TfrmMain.FinishAnalysis;
  Var
   f : TfrmReport;
  Begin
   If Not Assigned(fAnalysis) Or (WaitForSingleObject(fAnalysis.Handle, 0) <> WAIT_OBJECT_0) Then
    Exit;
   Try
    If fAnalysis.Error <> '' Then
     ShowMessage(fAnalysis.Error)
    Else
     Begin
      If fPreviewFile = '' Then
       fDB.Connection.ExecSQL('update ' + fAnalysis.TableName + ' set analysis_report=:r where id=:id', [fAnalysis.Report, fAnalysis.RowID]);
      f := TfrmReport.Create(Self);
      f.SetReport(fAnalysis.Report, fAnalysis.TableName = 'trip_touchdowns');
      f.Show;
     End;
   Finally
    FreeAndNil(fAnalysis);
    aOpen.Enabled            := fPreviewFile = '';
    aAnalysisLanding.Enabled := True;
    aAnalysisLiftoff.Enabled := True;
   End;
  End;

 Procedure TfrmMain.aOverviewExecute(Sender : TObject);
  Var
   q : TFDQuery;
   p : TPlotPoint;
  Begin
   If fPreviewFile <> '' Then
    Exit;
   fMap.SetData(Nil);
   fCharts.SetData(Nil);
   fEnginesFrame.Clear;
   fPFD737Frame.Clear;
   fB38MEICASFrame.Clear;
   fA320PFDFrame.Clear;
   fA320ECAMFrame.Clear;
   fSixPackFrame.Clear;
   ResetPlayback;
   FreeAndNil(fPlot);
   fPlot := TTripPlot.Create;
   q     := TFDQuery.Create(Nil);
   Try
    q.Connection := fIndex.Connection;
    q.Open('select departure_latitude,departure_longitude,destination_latitude,destination_longitude,coalesce(group_id,0) gid from trips where destination_latitude is not null and destination_longitude is not null');
    While Not q.Eof Do
     Begin
      p             := Default(TPlotPoint);
      p.GroupID     := q.FieldByName('gid').AsInteger;
      p.Lat         := q.FieldByName('departure_latitude').AsFloat;
      p.Lon         := q.FieldByName('departure_longitude').AsFloat;
      p.BreakBefore := True;
      fPlot.Points.Add(p);
      p.Lat         := q.FieldByName('destination_latitude').AsFloat;
      p.Lon         := q.FieldByName('destination_longitude').AsFloat;
      p.BreakBefore := False;
      fPlot.Points.Add(p);
      q.Next;
     End;
   Finally
    q.Free;
   End;
   fMap.SetData(fPlot);

   DataGrid.RowCount   := 2;
   CursorLabel.Caption := Tr('Wszystkie trasy '#8212' kolory wed'#322'ug grup');
  End;

 Procedure TfrmMain.aPlayPauseExecute(Sender : TObject);
  Begin
   If fPlayback = Nil Then
    Exit;
   If fPlayback.Playing Then
    fPlayback.Pause(GetTickCount64)
   Else
    fPlayback.Play(GetTickCount64);
   ApplyPlayback;
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
   If fPreviewFile <> '' Then
    Exit;
   If cbGroup.ItemIndex <= 0 Then
    Exit;
   ID   := Integer(NativeInt(cbGroup.Items.Objects[cbGroup.ItemIndex]));
   Name := cbGroup.Text;
   If LocalizedInputQuery(Tr('Zmie'#324' nazw'#281' grupy'), Tr('Nazwa:'), Name) And (Trim(Name) <> '') Then
    Begin
     fIndex.Connection.ExecSQL('update trip_groups set name=:n where id=:id', [Trim(Name), ID]);
     RefreshHistory;
    End;
  End;

 Procedure TfrmMain.aDeleteGroupExecute(Sender : TObject);
  Var
   ID : Integer;
  Begin
   If fPreviewFile <> '' Then
    Exit;
   If cbGroup.ItemIndex <= 0 Then
    Exit;
   ID := Integer(NativeInt(cbGroup.Items.Objects[cbGroup.ItemIndex]));
   If MessageDlg(Tr('Usun'#261#263' grup'#281'? Loty pozostan'#261' w bazie bez tej grupy.'), mtConfirmation, [mbYes, mbNo], 0) <> mrYes Then
    Exit;
   fIndex.Connection.StartTransaction;
   Try
    fIndex.Connection.ExecSQL('update trips set group_id=null where group_id=:id', [ID]);
    fIndex.Connection.ExecSQL('delete from trip_groups where id=:id', [ID]);
    fIndex.Connection.Commit;
   Except
    fIndex.Connection.Rollback;
    Raise;
   End;
   RefreshHistory;
  End;

End.
