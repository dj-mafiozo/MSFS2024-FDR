{$StackFrames On}
Unit LocalizationU;

Interface

 Uses
  System.Classes, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.UITypes, LocalizationCatalogU, i18nLocalizer;

 Const
  UILanguageCount = 32;
  UILanguageLocales : Array[0..UILanguageCount-1] Of String = (
   'ar-SA',
   'be-BY',
   'cs-CZ',
   'da-DK',
   'de-AT',
   'de-CH',
   'de-DE',
   'el-GR',
   'en-GB',
   'en-US',
   'es-ES',
   'fi-FI',
   'fr-CA',
   'fr-FR',
   'he-IL',
   'hi-IN',
   'hr-HR',
   'id-ID',
   'it-IT',
   'ja-JP',
   'nb-NO',
   'nl-NL',
   'pl-PL',
   'pt-BR',
   'pt-PT',
   'ru-RU',
   'sk-SK',
   'sv-SE',
   'tr-TR',
   'uk-UA',
   'vi-VN',
   'zh-CN');
  UILanguageNames : Array[0..UILanguageCount-1] Of String = (
   'العربية',
   'Беларуская',
   'Čeština',
   'Dansk',
   'Deutsch (Österreich)',
   'Deutsch (Schweiz)',
   'Deutsch',
   'Ελληνικά',
   'English (United Kingdom)',
   'English',
   'Español',
   'Suomi',
   'Français (Canada)',
   'Français',
   'עברית',
   'हिन्दी',
   'Hrvatski',
   'Bahasa Indonesia',
   'Italiano',
   '日本語',
   'Norsk (bokmål)',
   'Nederlands',
   'Polski',
   'Português (Brasil)',
   'Português',
   'Русский',
   'Slovenčina',
   'Svenska',
   'Türkçe',
   'Українська',
   'Tiếng Việt',
   '简体中文');

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
 Function NormalizeLanguage(Const Locale : String) : String;
 Function WindowsLanguage : String;
 Function LanguagePreference : String;
 Procedure SetLanguage(Const Locale : String);
 Procedure LocalizeRoot(Root : TComponent);

Implementation

 Uses
  System.Generics.Collections, System.Types, UIFontsU, Winapi.Windows, System.SysUtils, System.SyncObjs, i18nCore, i18nCatalog, i18nDialogs, i18nHashList;

 Type
  TTranslatorAccess = Class(TTranslator);
  TControlAccess = Class(TControl);
  TPresentationLink = Class(TComponent)
   Public
    OriginalAfter, OriginalBeforeFlip : TNotifyEvent;
    Positions : TDictionary<String,TPoint>;
    Destructor Destroy; Override;
    Procedure BeforeFlip(Sender : TObject);
    Procedure Translated(Sender : TObject);
    Procedure RestoreLTR;
  End;

 Var
  Instance          : TApplicationLocalizer;
  Lock              : TCriticalSection;
  CurrentLanguage   : String = 'pl-PL';
  PreferredLanguage : String = 'auto';

 Destructor TPresentationLink.Destroy;
  Begin Positions.Free; Inherited; End;
 Procedure TPresentationLink.BeforeFlip(Sender : TObject);
  Var I : Integer; C : TControl;
  Begin
   If Assigned(OriginalBeforeFlip) Then OriginalBeforeFlip(Sender);
   If (Owner Is TWinControl) And (TWinControl(Owner).BiDiMode = bdLeftToRight) Then
    Begin
     If Positions = Nil Then Positions := TDictionary<String,TPoint>.Create;
     Positions.Clear;
     For I := 0 To Owner.ComponentCount-1 Do
      If (Owner.Components[I] Is TControl) And (Owner.Components[I].Name <> '') Then
       Begin
        C := TControl(Owner.Components[I]);
        If C.Parent <> Nil Then Positions.AddOrSetValue(C.Name,Point(C.Left,C.Parent.ClientWidth));
       End;
    End;
  End;
 Procedure TPresentationLink.RestoreLTR;
  Var Pair : TPair<String,TPoint>; C : TComponent; Control : TControl; X : Integer;
  Begin
   // Auto-sized translated labels change width between flips. Restore their LTR
   // anchor positions rather than accumulating a width-dependent offset.
   If (Positions <> Nil) And (Owner Is TWinControl) And (TWinControl(Owner).BiDiMode = bdLeftToRight) Then
    Begin
     For Pair In Positions Do
      Begin
       C := Owner.FindComponent(Pair.Key);
       If C Is TControl Then
        Begin
         Control := TControl(C); X := Pair.Value.X;
         If (Control.Parent <> Nil) And (akRight In Control.Anchors) And Not (akLeft In Control.Anchors) Then
          Inc(X,Control.Parent.ClientWidth-Pair.Value.Y);
         If Control.Align = alNone Then Control.Left := X;
        End;
      End;
     Positions.Clear;
    End;
  End;

 Procedure TPresentationLink.Translated(Sender : TObject);
  Begin
   If Assigned(OriginalAfter) Then OriginalAfter(Sender);
   ApplyLocalePresentation(Owner,Language);
  End;
 Procedure RestoreLayouts(Root : TComponent);
  Var I : Integer;
  Begin
   If Root Is TPresentationLink Then TPresentationLink(Root).RestoreLTR;
   For I := 0 To Root.ComponentCount-1 Do RestoreLayouts(Root.Components[I]);
  End;

 Function AppLocalizer : TLocalizer;
  Begin
   If Instance = Nil Then
    Begin
     Instance         := TApplicationLocalizer.Create(Nil);
     Instance.Options := [loAdjustApplicationBiDiMode];
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
   Try
    Result := AppLocalizer.GetText(Text, Domain);
   Finally
    Lock.Leave;
   End;
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

 Function NormalizeLanguage(Const Locale : String) : String;
  Var Code, Primary : String; I : Integer;
  Begin
   Code := StringReplace(Trim(Locale),'_','-',[rfReplaceAll]);
   For I := 0 To UILanguageCount-1 Do
    If SameText(Code,UILanguageLocales[I]) Then Exit(UILanguageLocales[I]);
   Primary := LowerCase(Copy(Code,1,Pos('-',Code+'-')-1));
   If Primary = 'de' Then Result := 'de-DE'
   Else If Primary = 'en' Then Result := 'en-US'
   Else If Primary = 'es' Then Result := 'es-ES'
   Else If Primary = 'fr' Then Result := 'fr-FR'
   Else If Primary = 'it' Then Result := 'it-IT'
   Else If Primary = 'pl' Then Result := 'pl-PL'
   Else If Primary = 'pt' Then Result := 'pt-PT'
   Else If Primary = 'ru' Then Result := 'ru-RU'
   Else If Primary = 'tr' Then Result := 'tr-TR'
   Else If Primary = 'be' Then Result := 'be-BY'
   Else If Primary = 'el' Then Result := 'el-GR'
   Else If Primary = 'uk' Then Result := 'uk-UA'
   Else If Primary = 'hr' Then Result := 'hr-HR'
   Else If Primary = 'cs' Then Result := 'cs-CZ'
   Else If Primary = 'da' Then Result := 'da-DK'
   Else If Primary = 'nl' Then Result := 'nl-NL'
   Else If Primary = 'fi' Then Result := 'fi-FI'
   Else If Primary = 'no' Then Result := 'nb-NO'
   Else If Primary = 'nb' Then Result := 'nb-NO'
   Else If Primary = 'nn' Then Result := 'nb-NO'
   Else If Primary = 'sk' Then Result := 'sk-SK'
   Else If Primary = 'sv' Then Result := 'sv-SE'
   Else If Primary = 'zh' Then Result := 'zh-CN'
   Else If Primary = 'ja' Then Result := 'ja-JP'
   Else If Primary = 'vi' Then Result := 'vi-VN'
   Else If Primary = 'hi' Then Result := 'hi-IN'
   Else If Primary = 'ar' Then Result := 'ar-SA'
   Else If Primary = 'he' Then Result := 'he-IL'
   Else If Primary = 'iw' Then Result := 'he-IL'
   Else If Primary = 'id' Then Result := 'id-ID'
   Else If Primary = 'in' Then Result := 'id-ID'
   Else Result := 'en-US';
  End;

 Function WindowsLanguage : String;
  Var
   Buffer : Array [0 .. LOCALE_NAME_MAX_LENGTH] Of WideChar;
  Begin
   Result := 'en-US';
   // UI language, not the user's independent number/date format locale.
   If LCIDToLocaleName(MAKELCID(GetUserDefaultUILanguage, SORT_DEFAULT), Buffer, Length(Buffer), 0) > 0 Then
    Result := NormalizeLanguage(Buffer);
  End;

 Function LanguagePreference : String;
  Begin
   Lock.Enter;
   Try
    Result := PreferredLanguage;
   Finally
    Lock.Leave;
   End;
  End;

 Procedure SetLanguage(Const Locale : String);
  Var I : Integer;
  Begin
   Lock.Enter;
   Try
    If (Trim(Locale) = '') Or SameText(Locale, 'auto') Then
     Begin
      PreferredLanguage := 'auto';
      CurrentLanguage   := WindowsLanguage;
     End
    Else
     Begin
      PreferredLanguage := NormalizeLanguage(Locale);
      CurrentLanguage   := PreferredLanguage;
     End;
    Application.DefaultFont.Name := LocaleFontName(CurrentLanguage);
    AppLocalizer.Culture := CultureOf(CurrentLanguage);
    For I := 0 To Screen.FormCount-1 Do RestoreLayouts(Screen.Forms[I]);
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
   Link       : TPresentationLink;
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
    C := Root.FindComponent('LocalePresentation');
    If Not (C Is TPresentationLink) Then
     Begin
      // A new window may inherit Application.BiDiMode before its translator is
      // attached. Start from the DFM's LTR geometry so the first RTL flip occurs.
      If Root Is TControl Then
       Begin TControlAccess(Root).ParentBiDiMode := False; TControlAccess(Root).BiDiMode := bdLeftToRight; End;
      Link := TPresentationLink.Create(Root); Link.Name := 'LocalePresentation';
      Link.OriginalAfter := Translator.OnAfterTranslate;
      Link.OriginalBeforeFlip := Translator.OnBeforeFlipLayout;
      Translator.OnBeforeFlipLayout := Link.BeforeFlip;
      Translator.OnAfterTranslate := Link.Translated;
     End;
    If Root Is TControl Then TControlAccess(Root).ParentBiDiMode := False;
    ApplyLocalePresentation(Root,Language);
    Translator.AutoBiDiLayout := True;
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
   Dialog.Font.Name := LocaleFontName(Language);
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
   Dialog.Font.Name := LocaleFontName(Language);
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
