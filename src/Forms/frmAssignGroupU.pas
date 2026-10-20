Unit frmAssignGroupU;

Interface

 Uses
  System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, LocalizationU, i18nLocalizer,
  i18nCore;

 Type
  TfrmAssignGroup = Class(TLocalizedForm)
   Published
    lGroup        : TLabel;
    cbGroups      : TComboBox;
    btnOK         : TButton;
    btnCancel     : TButton;
    AppTranslator : TTranslator;
  End;

Implementation

 {$R *.dfm}

End.
