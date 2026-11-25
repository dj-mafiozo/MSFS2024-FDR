Unit fraValuesU;

Interface

 Uses
  System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.ToolWin, Vcl.ActnList, System.Actions, Vcl.Grids,
  Vcl.DBGrids, Vcl.CheckLst, LocalizationU;

 Type
  TfraValues = Class(TFrame)
    WindowToolbar : TToolBar;
    WindowButton  : TToolButton;
    WindowActions : TActionList;
    aWindow       : TAction;
    DataGrid      : TStringGrid;
    eValueSearch  : TEdit;
   Private
    fLocalized : Boolean;
   Protected
    Procedure SetParent(AParent : TWinControl); Override;
  End;

Implementation
{$R *.dfm}

 Procedure TfraValues.SetParent(AParent : TWinControl);
  Begin
   Inherited;
   If (AParent <> Nil) And Not fLocalized Then
    Begin
     LocalizeRoot(Self);
     fLocalized := True;
    End;
  End;

End.
