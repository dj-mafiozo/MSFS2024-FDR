{$StackFrames On}
Unit frmReportU;

Interface

 Uses
  UIFontsU, LocalizationU, i18nLocalizer, i18nCore,
  System.Classes, System.SysUtils, Vcl.Forms, Vcl.StdCtrls, Vcl.Controls,
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Graphics;

 Type
  TfrmReport = Class(TLocalizedForm)
    AppTranslator  : TTranslator;
    mReport        : TMemo;
    btnClose       : TButton;
    ReportPanel    : TPanel;
    ReportGroupBox : TGroupBox;
    Procedure TranslateTitle(Sender : TObject);
    Procedure CloseClick    (Sender : TObject);
    Procedure FormClose     (Sender : TObject; Var Action : TCloseAction);
   Private
    fTitleSource : String;
    fRich        : TRichEdit;
    fScroll      : TScrollBox;
   Public
    Constructor Create         (AOwner : TComponent); Override;
    Procedure   SetHTMLDocument(Const HTML : String);
    Procedure   SetReport      (Const Markdown : String); Overload;
    Procedure   SetReport      (Const Markdown : String; Landing : Boolean); Overload;
  End;

Implementation

 Uses
  System.Math, SimBriefImportU, MarkdownRichEditU;
{$R *.dfm}

 Constructor TfrmReport.Create(AOwner : TComponent);
  Begin
   Inherited;
   fScroll                := TScrollBox.Create(Self);
   fScroll.Parent         := ReportPanel;
   fScroll.Align          := alClient;
   fScroll.BorderStyle    := bsNone;
   mReport.Parent         := fScroll;
   mReport.Align          := alTop;
   mReport.ReadOnly       := True;
   mReport.BevelInner     := bvNone;
   mReport.BevelOuter     := bvNone;
   mReport.BorderStyle    := bsNone;
   mReport.Color          := clBtnFace;
   mReport.ScrollBars     := ssNone;
   mReport.WordWrap       := False;
   mReport.Font.Name      := 'Consolas';
   mReport.ParentBiDiMode := False;
   mReport.BiDiMode       := bdLeftToRight;
   fRich                  := TRichEdit.Create(Self);
   fRich.Parent           := ReportPanel;
   fRich.Align            := alClient;
   fRich.ReadOnly         := True;
   fRich.BorderStyle      := bsNone;
   fRich.Color            := clBtnFace;
   fRich.ScrollBars       := ssVertical;
   fRich.Font.Name        := 'Segoe UI';
   fRich.Font.Size        := 11;
   fRich.Visible          := False;
   ApplyLocalePresentation(Self, Language);
  End;

 Procedure TfrmReport.SetHTMLDocument(Const HTML : String);
  Var
   b : TBitmap;
   i : Integer;
   w : Integer;
  Begin
   fTitleSource    := '';
   fRich.Visible   := False;
   fScroll.Visible := True;
   mReport.Text    := SimBriefPlainText(HTML);
   b               := TBitmap.Create;
   Try
    b.Canvas.Font.Assign(mReport.Font);
    mReport.Height := Max(1, mReport.Lines.Count) * b.Canvas.TextHeight('Mg') + 12;
    w              := 1;
    For i          := 0 To mReport.Lines.Count - 1 Do
     w             := Max(w, b.Canvas.TextWidth(mReport.Lines[i]) + 12);
    // The outer scrollbox owns both scroll directions, including long OFP lines.
    mReport.Align := alNone;
    mReport.SetBounds(0, 0, Max(fScroll.ClientWidth, w), mReport.Height);
   Finally
    b.Free;
   End;
   fScroll.VertScrollBar.Position := 0;
   fScroll.HorzScrollBar.Position := 0;
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
   mReport.Text    := Markdown;
   fScroll.Visible := False;
   fRich.Visible   := True;
   RenderMarkdown(fRich, Markdown);
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
