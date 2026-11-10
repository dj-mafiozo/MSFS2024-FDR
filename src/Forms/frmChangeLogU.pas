{$StackFrames On}
Unit frmChangeLogU;

Interface

 Uses
  System.Classes, Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls;

 Type
  TfrmChangeLog = Class(TForm)
   Content  : TRichEdit;
   Buttons  : TPanel;
   btnClose : TButton;
   Procedure FormShow(Sender : TObject);
  End;

 Procedure ShowChangeLog(Owner : TComponent);

Implementation

 Uses
  System.SysUtils, System.IOUtils, LocalizationU, AppPathsU, MarkdownRichEditU;
{$R *.dfm}

 Procedure TfrmChangeLog.FormShow(Sender : TObject);
  Var
   Name : String;
   Path : String;
  Begin
   If SameText(Copy(Language, 1, 2), 'pl') Then
    Begin
     Name             := 'changelog.md';
     Caption          := 'Historia zmian';
     btnClose.Caption := 'Zamknij';
    End
   Else
    Begin
     Name             := 'CHANGELOG.en.md';
     Caption          := 'Changelog';
     btnClose.Caption := 'Close';
    End;
   Path := TPath.Combine(ApplicationDirectory, Name);
   If Not FileExists(Path) Then
    Path := TPath.GetFullPath(TPath.Combine(ApplicationDirectory, '..\' + Name));
   If FileExists(Path) Then
    RenderMarkdown(Content, TFile.ReadAllText(Path, TEncoding.UTF8))
   Else
    Content.Text := Name + ' — file unavailable';
  End;

 Procedure ShowChangeLog(Owner : TComponent);
  Var
   f : TfrmChangeLog;
  Begin
   f := TfrmChangeLog.Create(Owner);
   Try
    f.ShowModal;
   Finally
    f.Free;
   End;
  End;

End.
