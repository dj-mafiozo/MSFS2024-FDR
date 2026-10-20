{$StackFrames On}
Unit frmSimBriefU;

Interface

 Uses
  LocalizationU, i18nLocalizer, i18nCore, System.Classes, Vcl.Forms, Vcl.Controls,
  Vcl.ExtCtrls, Vcl.StdCtrls;

 Type
  TfrmSimBrief = Class(TLocalizedForm)
   Published
    AppTranslator : TTranslator;
    ViewGroupBox  : TGroupBox;
    ViewHost      : TPanel;
    btnClose      : TButton;
  End;

 Procedure ShowSimBriefWindow(View : TWinControl);

Implementation

 {$R *.dfm}

 Procedure ShowSimBriefWindow(View : TWinControl);
  Var
   Window         : TfrmSimBrief;
   PreviousParent : TWinControl;
   PreviousAlign  : TAlign;
  Begin
   PreviousParent := View.Parent;
   PreviousAlign  := View.Align;
   Window         := TfrmSimBrief.Create(GetParentForm(View));
   Try
    View.Parent := Window.ViewHost;
    View.Align  := alClient;
    Window.ShowModal;
   Finally
    View.Parent := PreviousParent;
    View.Align  := PreviousAlign;
    Window.Free;
   End;
  End;

End.
