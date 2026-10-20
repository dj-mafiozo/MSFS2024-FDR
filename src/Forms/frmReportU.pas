{$StackFrames On}
Unit frmReportU;

Interface

 Uses
  UIFontsU, LocalizationU, i18nLocalizer, System.Classes, System.SysUtils, System.IOUtils,
  Vcl.Forms, Vcl.StdCtrls, Vcl.Controls, Vcl.ExtCtrls,
  uWVBrowser, uWVWindowParent, uWVLoader, uWVTypeLibrary, uWVCoreWebView2Args, ReportMarkdownU,
  i18nCore;

 Type
  TfrmReport = Class(TLocalizedForm)
   Published
    AppTranslator  : TTranslator;
    mReport        : TMemo;
    btnClose       : TButton;
    BrowserPanel   : TPanel;
    ReportGroupBox : TGroupBox;
    StartTimer     : TTimer;
    Procedure TranslateTitle(Sender : TObject);
    Procedure CloseClick(Sender : TObject);
    Procedure FormClose(Sender : TObject; Var Action : TCloseAction);
    Procedure StartTick(Sender : TObject);
   Private
    fBrowser     : TWVBrowser;
    fHost        : TWVWindowParent;
    fTitleSource : String;
    fHTML        : Boolean;
    fReport      : String;
    fStarted     : Boolean;
    Function DocumentHTML : String;
    Procedure Created(Sender : TObject);
    Procedure NavigationCompleted(Sender : TObject; Const WebView : ICoreWebView2; Const Args : ICoreWebView2NavigationCompletedEventArgs);
   Public
    Constructor Create(AOwner : TComponent); Override;
    Destructor Destroy; Override;
    Procedure SetHTMLDocument(Const HTML : String);
    Procedure SetReport(Const Markdown : String); Overload;
    Procedure SetReport(Const Markdown : String; Landing : Boolean); Overload;
  End;

Implementation

 {$R *.dfm}

 Constructor TfrmReport.Create(AOwner : TComponent);
  Begin
   Inherited;
   fHost                          := TWVWindowParent.Create(Self);
   fHost.Parent                   := BrowserPanel;
   fHost.Align                    := alClient;
   fBrowser                       := TWVBrowser.Create(Self);
   fHost.Browser                  := fBrowser;
   fBrowser.OnAfterCreated        := Created;
   fBrowser.OnNavigationCompleted := NavigationCompleted;
   If GlobalWebView2Loader = Nil Then
    Begin
     GlobalWebView2Loader                := TWVLoader.Create(Nil);
     GlobalWebView2Loader.UserDataFolder := TPath.Combine(GetEnvironmentVariable('LOCALAPPDATA'), 'MSFSFDR\ReportsWebView2');
     GlobalWebView2Loader.StartWebView2;
    End;
   ApplyLocalePresentation(Self,Language);
  End;

 Destructor TfrmReport.Destroy;
  Begin
   If StartTimer <> Nil Then
    StartTimer.Enabled := False;
   fBrowser.Free;
   fHost.Free;
   Inherited;
  End;

 Function TfrmReport.DocumentHTML : String;
  Begin
   If fHTML Then
    Result := fReport
   Else
    Result := ReportHTML(fReport);
  End;

 Procedure TfrmReport.SetHTMLDocument(Const HTML : String);
  Begin
   fTitleSource := '';
   fHTML        := True;
   fReport      := HTML;
   mReport.Text := HTML;
   If fBrowser.Initialized Then
    fBrowser.NavigateToString(DocumentHTML);
  End;

 Procedure TfrmReport.TranslateTitle(Sender : TObject);
  Begin
   If fTitleSource <> '' Then
    Caption := Tr(fTitleSource);
  End;

 Procedure TfrmReport.SetReport(Const Markdown : String; Landing : Boolean);
  Begin
   If Landing Then
    fTitleSource := 'Analiza lądowania'
   Else
    fTitleSource := 'Analiza startu';
   SetReport(Markdown);
  End;

 Procedure TfrmReport.SetReport(Const Markdown : String);
  Begin
   If fTitleSource = '' Then
    fTitleSource := 'Analiza kontaktu z pasem';
   TranslateTitle(Self);
   fHTML        := False;
   fReport      := Markdown;
   mReport.Text := Markdown;
   If (fBrowser <> Nil) And fBrowser.Initialized Then
    fBrowser.NavigateToString(DocumentHTML);
  End;

 Procedure TfrmReport.Created(Sender : TObject);
  Begin
   fHost.UpdateSize;
   fBrowser.NavigateToString(DocumentHTML);
  End;

 Procedure TfrmReport.NavigationCompleted(Sender : TObject; Const WebView : ICoreWebView2; Const Args : ICoreWebView2NavigationCompletedEventArgs);
  Var
   A : TCoreWebView2NavigationCompletedEventArgs;
  Begin
   A := TCoreWebView2NavigationCompletedEventArgs.Create(Args);
   Try
    mReport.Visible      := Not A.IsSuccess;
    BrowserPanel.Visible := A.IsSuccess;
   Finally
    A.Free;
   End;
  End;

 Procedure TfrmReport.StartTick(Sender : TObject);
  Begin
   If GlobalWebView2Loader = Nil Then
    Exit;
   If GlobalWebView2Loader.InitializationError Then
    Begin
     StartTimer.Enabled := False;
     Exit;
    End;
   If GlobalWebView2Loader.Initialized And Not fStarted Then
    Begin
     fStarted           := True;
     StartTimer.Enabled := False;
     fBrowser.CreateBrowser(fHost.Handle);
    End;
  End;

 Procedure TfrmReport.CloseClick(Sender : TObject);
  Begin
   Close;
  End;

 Procedure TfrmReport.FormClose(Sender : TObject; Var Action : TCloseAction);
  Begin
   Action := caFree;
  End;

End.
