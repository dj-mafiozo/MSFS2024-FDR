Unit LocalizationU;

Interface

 Uses
  System.Classes, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.UITypes, LocalizationCatalogU, i18nLocalizer;

 Type
  TLocalizedForm = Class(TForm)
   Public
    Constructor Create(AOwner : TComponent); Override;
  End;

  TLocalizedFrame = Class(TFrame)
   Private
    fLocalized : Boolean;
   Protected
    Procedure SetParent(AParent : TWinControl); Override;
   Public
    Constructor Create(AOwner : TComponent); Override;
  End;

 Function TrDomain(Const Text, Domain : String) : String;
 Function Tr(Const Text : String) : String;
 Function Language : String;
 Function AppLocalizer : TLocalizer;
 Function LocalizedInputQuery(Const Caption, Prompt : String; Var Value : String) : Boolean;
 Function LocalizedMessageDlg(Const Msg : String; DlgType : TMsgDlgType; Buttons : TMsgDlgButtons; HelpCtx : Longint) : Integer;
 Procedure SetLanguage(Const Locale : String);
 Procedure LocalizeRoot(Root : TComponent);

Implementation

 Uses
  System.SysUtils, System.SyncObjs, i18nCore, i18nCatalog, i18nDialogs, i18nHashList;

 Type
  TTranslatorAccess = Class(TTranslator);

 Var
  Instance        : TApplicationLocalizer;
  Lock            : TCriticalSection;
  CurrentLanguage : String = 'pl-PL';

 Function AppLocalizer : TLocalizer;
  Begin
   If Instance = Nil Then
    Begin
     Instance         := TApplicationLocalizer.Create(Nil);
     Instance.Options := [];
     Try
      LoadApplicationCatalog(Instance);
     Except
      FreeAndNil(Instance);
      Raise;
     End;
     Instance.Culture := CultureOf(CurrentLanguage);
    End;
   Result := Instance;
  End;

 Function TrDomain(Const Text, Domain : String) : String;
  Begin
   Lock.Enter;
   Try Result := AppLocalizer.GetText(Text, Domain); Finally Lock.Leave; End;
  End;

 Function Tr(Const Text : String) : String;
  Begin
   Lock.Enter;
   Try
    Result := AppLocalizer.GetText(Text, 'Application');
   Finally
    Lock.Leave;
   End;
  End;

 Function Language : String;
  Begin
   Lock.Enter;
   Try
    Result := CurrentLanguage;
   Finally
    Lock.Leave;
   End;
  End;

 Procedure SetLanguage(Const Locale : String);
  Begin
   Lock.Enter;
   Try
    If SameText(Locale, 'en') Or SameText(Locale, 'en-US') Then
     CurrentLanguage := 'en-US'
    Else If SameText(Locale, 'de') Or SameText(Locale, 'de-DE') Then
     CurrentLanguage := 'de-DE'
    Else If SameText(Locale, 'es') Or SameText(Locale, 'es-ES') Then
     CurrentLanguage := 'es-ES'
    Else
     CurrentLanguage := 'pl-PL';
    AppLocalizer.Culture := CultureOf(CurrentLanguage);
   Finally
    Lock.Leave;
   End;
  End;

 Procedure LocalizeRoot(Root : TComponent);
  Var
   Translator : TTranslator;
   Domain     : TTextDomain;
   Def        : TTextDefinition;
   C          : TComponent;
  Begin
   Lock.Enter;
   Try
    C := Root.FindComponent('AppTranslator');
    If C Is TTranslator Then
     Translator := TTranslator(C)
    Else
     Begin
      Translator      := TTranslator.Create(Root);
      Translator.Name := 'AppTranslator';
     End;
    Translator.AutoBiDiLayout := False;
    Domain                    := TApplicationLocalizer(AppLocalizer).Catalog.TextDomains.Find(Copy(Root.ClassName, 2, MaxInt));
    If Domain <> Nil Then
     Begin
      Def := Domain.Properties.First;
      While Def <> Nil Do
       Begin
        Translator.Translatables.Properties.Add(Def.ID).Value := Def.Value;
        Def                                                   := Def.Next;
       End;
     End;
    Translator.Localizer := AppLocalizer;
    TTranslatorAccess(Translator).Translate;
   Finally
    Lock.Leave;
   End;
  End;

 Constructor TLocalizedForm.Create(AOwner : TComponent);
  Begin
   Inherited;
   LocalizeRoot(Self);
  End;

 Constructor TLocalizedFrame.Create(AOwner : TComponent);
  Begin
   Inherited;
   // Toolbars require a parent window when translated action captions change.
  End;

 Procedure TLocalizedFrame.SetParent(AParent : TWinControl);
  Begin
   Inherited;
   If (AParent <> Nil) And Not fLocalized Then
    Begin
     LocalizeRoot(Self);
     fLocalized := True;
    End;
  End;

 Function LocalizedMessageDlg(Const Msg : String; DlgType : TMsgDlgType; Buttons : TMsgDlgButtons; HelpCtx : Longint) : Integer;
  Var
   Dialog : TMessageDialog;
  Begin
   Dialog := TMessageDialog.Create(Nil);
   Try
    Dialog.ButtonCaptions.Yes    := Tr('Tak');
    Dialog.ButtonCaptions.No     := Tr('Nie');
    Dialog.ButtonCaptions.Cancel := Tr('Anuluj');
    Dialog.ButtonCaptions.Close  := Tr('Zamknij');
    Dialog.Captions.Confirmation := Tr('Potwierdzenie');
    Dialog.Captions.Error        := Tr('Blad');
    Dialog.Captions.Information  := Tr('Informacja');
    Dialog.Captions.Warning      := Tr('Ostrzezenie');
    Result                       := Dialog.Show(Tr(Msg), DlgType, Buttons, HelpCtx);
   Finally
    Dialog.Free;
   End;
  End;

 Function LocalizedInputQuery(Const Caption, Prompt : String; Var Value : String) : Boolean;
  Var
   Dialog : TInputQueryDialog;
  Begin
   Dialog := TInputQueryDialog.Create(Nil);
   Try
    Dialog.ButtonCaptions.Cancel := Tr('Anuluj');
    Result                       := Dialog.Execute(Tr(Caption), Tr(Prompt), Value);
   Finally
    Dialog.Free;
   End;
  End;

Initialization

 Lock := TCriticalSection.Create;

Finalization

 Instance.Free;
 Lock.Free;

End.
