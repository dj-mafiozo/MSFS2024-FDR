{$StackFrames On}
Unit frmViewWindowU;

Interface

 Uses
  System.Classes, Vcl.Controls, Vcl.Forms, LocalizationU, i18nLocalizer;

 Type
  TfrmViewWindow = Class(TLocalizedForm)
   Published
    AppTranslator  : TTranslator;
    Procedure FormClose(Sender : TObject; Var Action : TCloseAction);
    Procedure TranslateTitle(Sender : TObject);
   Private
    fView          : TFrame;
    fDock          : TWinControl;
    fReturned      : TNotifyEvent;
    fTitle         : String;
    Procedure ReturnView;
   Public
    Destructor Destroy; Override;
    Procedure Attach(View : TFrame; Dock : TWinControl; Const Title : String; Returned : TNotifyEvent);
  End;

Implementation

 {$R *.dfm}

 Procedure TfrmViewWindow.Attach(View : TFrame; Dock : TWinControl; Const Title : String; Returned : TNotifyEvent);
  Begin
   fView := View;
   HelpType := htContext;
   HelpContext := View.HelpContext;
   fDock := Dock;
   fReturned := Returned;
   fTitle := Title;
   TranslateTitle(Self);
   View.Parent := Self;
   View.Align := alClient;
   Dock.Visible := False;
   Show;
  End;

 Procedure TfrmViewWindow.TranslateTitle(Sender : TObject);
  Begin
   If fTitle <> '' Then Caption := Tr(fTitle);
  End;

 Procedure TfrmViewWindow.ReturnView;
  Var
   View : TFrame;
   Dock : TWinControl;
   Returned : TNotifyEvent;
  Begin
   View := fView;
   Dock := fDock;
   Returned := fReturned;
   fView := Nil;
   fDock := Nil;
   fReturned := Nil;
   If (View <> Nil) And (Dock <> Nil) Then
    Begin
     View.Parent := Dock;
     View.Align := alClient;
     Dock.Visible := True;
    End;
   If Assigned(Returned) Then Returned(Self);
  End;

 Procedure TfrmViewWindow.FormClose(Sender : TObject; Var Action : TCloseAction);
  Begin
   ReturnView;
   Action := caFree;
  End;

 Destructor TfrmViewWindow.Destroy;
  Begin
   ReturnView;
   Inherited;
  End;

End.
