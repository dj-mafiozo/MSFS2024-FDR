{$StackFrames On}
Unit LocalizationU;

Interface

 Uses
  System.Classes, Winapi.Messages, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.UITypes, LocalizationCatalogU, i18nLocalizer;

 Const
  UILanguageCount = 32;
  UILanguageLocales : Array [0..UILanguageCount - 1] Of String = ('ar-SA', 'be-BY', 'cs-CZ', 'da-DK', 'de-AT', 'de-CH', 'de-DE', 'el-GR', 'en-GB', 'en-US', 'es-ES', 'fi-FI', 'fr-CA', 'fr-FR', 'he-IL', 'hi-IN', 'hr-HR', 'id-ID', 'it-IT', 'ja-JP', 'nb-NO', 'nl-NL', 'pl-PL', 'pt-BR', 'pt-PT', 'ru-RU', 'sk-SK', 'sv-SE', 'tr-TR', 'uk-UA', 'vi-VN', 'zh-CN');
  UILanguageNames : Array [0..UILanguageCount - 1] Of String = ('العربية', 'Беларуская', 'Čeština', 'Dansk', 'Deutsch (Österreich)', 'Deutsch (Schweiz)', 'Deutsch', 'Ελληνικά', 'English (United Kingdom)', 'English', 'Español', 'Suomi', 'Français (Canada)', 'Français', 'עברית', 'हिन्दी', 'Hrvatski', 'Bahasa Indonesia', 'Italiano', '日本語', 'Norsk (bokmål)', 'Nederlands', 'Polski', 'Português (Brasil)', 'Português', 'Русский', 'Slovenčina', 'Svenska', 'Türkçe', 'Українська', 'Tiếng Việt', '简体中文');

 Type
  TLocalizedForm = Class(TForm)
   Private
    fMenuVisualState    : String;
    fMenuRepaintPending : Boolean;
    Procedure CMMenuChanged(Var Message : TMessage); Message CM_MENUCHANGED;
    Procedure RepaintMenu(Var Message : TMessage); Message WM_APP + $31F;
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
 Function LocalizedMessageDlg(Const Msg : String; DlgType : TMsgDlgType; Buttons : TMsgDlgButtons; HelpCtx : LongInt) : Integer;
 Function NormalizeLanguage(Const Locale : String) : String;
 Function WindowsLanguage : String;
 Function LanguagePreference : String;
 Procedure SetLanguage(Const Locale : String);
 Procedure LocalizeRoot(Root : TComponent);

Implementation

 Uses
  System.Generics.Collections, System.Types, Vcl.Menus, UIFontsU, Winapi.Windows, System.SysUtils, System.SyncObjs, i18nCore, i18nCatalog, i18nDialogs, i18nHashList;

 Type
   TTranslatorAccess = Class(TTranslator);

    TControlAccess = Class(TControl);

    TPresentationLink = Class(TComponent)
     Public
      OriginalAfter      : TNotifyEvent;
      OriginalBeforeFlip : TNotifyEvent;
      Positions          : TDictionary<String, TPoint>;
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
    Begin
     Positions.Free;
     Inherited;
    End;

   Procedure TPresentationLink.BeforeFlip(Sender : TObject);
    Var
     i : Integer;
     c : TControl;
    Begin
     If Assigned(OriginalBeforeFlip) Then
      OriginalBeforeFlip(Sender);
     If (Owner Is TWinControl) And (TWinControl(Owner).BiDiMode = bdLeftToRight) Then
      Begin
       If Positions = Nil Then
        Positions := TDictionary<String, TPoint>.Create;
       Positions.Clear;
       For i := 0 To Owner.ComponentCount - 1 Do
        If (Owner.Components[i] Is TControl) And (Owner.Components[i].Name <> '') Then
         Begin
          c := TControl(Owner.Components[i]);
          If c.Parent <> Nil Then
           Positions.AddOrSetValue(c.Name, Point(c.Left, c.Parent.ClientWidth));
         End;
      End;
    End;

   Procedure TPresentationLink.RestoreLTR;
    Var
     Pair    : TPair<String, TPoint>;
     c       : TComponent;
     Control : TControl;
     x       : Integer;
    Begin
     // Auto-sized translated labels change width between flips. Restore their LTR
     // anchor positions rather than accumulating a width-dependent offset.
     If (Positions <> Nil) And (Owner Is TWinControl) And (TWinControl(Owner).BiDiMode = bdLeftToRight) Then
      Begin
       For Pair In Positions Do
        Begin
         c := Owner.FindComponent(Pair.Key);
         If c Is TControl Then
          Begin
           Control := TControl(c);
           x       := Pair.Value.x;
           If (Control.Parent <> Nil) And (akRight In Control.Anchors) And Not(akLeft In Control.Anchors) Then
            Inc(x, Control.Parent.ClientWidth - Pair.Value.Y);
           If Control.Align = alNone Then
            Control.Left := x;
          End;
        End;
       Positions.Clear;
      End;
    End;

   Procedure TPresentationLink.Translated(Sender : TObject);
    Begin
     If Assigned(OriginalAfter) Then
      OriginalAfter(Sender);
     ApplyLocalePresentation(Owner, Language);
    End;

   Procedure RestoreLayouts(Root : TComponent);
    Var
     i : Integer;
    Begin
     If Root Is TPresentationLink Then
      TPresentationLink(Root).RestoreLTR;
     For i := 0 To Root.ComponentCount - 1 Do
      RestoreLayouts(Root.Components[i]);
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
  Var
   Code    : String;
   Primary : String;
   i       : Integer;
  Begin
   Code  := StringReplace(Trim(Locale), '_', '-', [rfReplaceAll]);
   For i := 0 To UILanguageCount - 1 Do
    If SameText(Code, UILanguageLocales[i]) Then
     Exit(UILanguageLocales[i]);
   Primary := LowerCase(Copy(Code, 1, Pos('-', Code + '-') - 1));
   If Primary = 'de' Then
    Result := 'de-DE'
   Else If Primary = 'en' Then
    Result := 'en-US'
   Else If Primary = 'es' Then
    Result := 'es-ES'
   Else If Primary = 'fr' Then
    Result := 'fr-FR'
   Else If Primary = 'it' Then
    Result := 'it-IT'
   Else If Primary = 'pl' Then
    Result := 'pl-PL'
   Else If Primary = 'pt' Then
    Result := 'pt-PT'
   Else If Primary = 'ru' Then
    Result := 'ru-RU'
   Else If Primary = 'tr' Then
    Result := 'tr-TR'
   Else If Primary = 'be' Then
    Result := 'be-BY'
   Else If Primary = 'el' Then
    Result := 'el-GR'
   Else If Primary = 'uk' Then
    Result := 'uk-UA'
   Else If Primary = 'hr' Then
    Result := 'hr-HR'
   Else If Primary = 'cs' Then
    Result := 'cs-CZ'
   Else If Primary = 'da' Then
    Result := 'da-DK'
   Else If Primary = 'nl' Then
    Result := 'nl-NL'
   Else If Primary = 'fi' Then
    Result := 'fi-FI'
   Else If Primary = 'no' Then
    Result := 'nb-NO'
   Else If Primary = 'nb' Then
    Result := 'nb-NO'
   Else If Primary = 'nn' Then
    Result := 'nb-NO'
   Else If Primary = 'sk' Then
    Result := 'sk-SK'
   Else If Primary = 'sv' Then
    Result := 'sv-SE'
   Else If Primary = 'zh' Then
    Result := 'zh-CN'
   Else If Primary = 'ja' Then
    Result := 'ja-JP'
   Else If Primary = 'vi' Then
    Result := 'vi-VN'
   Else If Primary = 'hi' Then
    Result := 'hi-IN'
   Else If Primary = 'ar' Then
    Result := 'ar-SA'
   Else If Primary = 'he' Then
    Result := 'he-IL'
   Else If Primary = 'iw' Then
    Result := 'he-IL'
   Else If Primary = 'id' Then
    Result := 'id-ID'
   Else If Primary = 'in' Then
    Result := 'id-ID'
   Else
    Result := 'en-US';
  End;

 Function WindowsLanguage : String;
  Var
   Buffer : Array [0..LOCALE_NAME_MAX_LENGTH] Of WideChar;
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
  Var
   i : Integer;
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
    AppLocalizer.Culture         := CultureOf(CurrentLanguage);
    For i                        := 0 To Screen.FormCount - 1 Do
     RestoreLayouts(Screen.Forms[i]);
   Finally
    Lock.Leave;
   End;
  End;

 Procedure LocalizeRoot(Root : TComponent);
  Var
   Translator : TTranslator;
   Domain     : TTextDomain;
   Def        : TTextDefinition;
   c          : TComponent;
   Link       : TPresentationLink;
  Begin
   If (Root = Nil) Or (csDesigning In Root.ComponentState) Then
    Exit;
   Lock.Enter;
   Try
    c := Root.FindComponent('AppTranslator');
    If c Is TTranslator Then
     Translator := TTranslator(c)
    Else
     Begin
      Translator      := TTranslator.Create(Root);
      Translator.Name := 'AppTranslator';
     End;
    c := Root.FindComponent('LocalePresentation');
    If Not(c Is TPresentationLink) Then
     Begin
      // A new window may inherit Application.BiDiMode before its translator is
      // attached. Start from the DFM's LTR geometry so the first RTL flip occurs.
      If Root Is TControl Then
       Begin
        TControlAccess(Root).ParentBiDiMode := False;
        TControlAccess(Root).BiDiMode       := bdLeftToRight;
       End;
      Link                          := TPresentationLink.Create(Root);
      Link.Name                     := 'LocalePresentation';
      Link.OriginalAfter            := Translator.OnAfterTranslate;
      Link.OriginalBeforeFlip       := Translator.OnBeforeFlipLayout;
      Translator.OnBeforeFlipLayout := Link.BeforeFlip;
      Translator.OnAfterTranslate   := Link.Translated;
     End;
    If Root Is TControl Then
     TControlAccess(Root).ParentBiDiMode := False;
    ApplyLocalePresentation(Root, Language);
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

 Procedure TLocalizedForm.CMMenuChanged(Var Message : TMessage);
  Var
   State : String;
   i     : Integer;
   Item  : TMenuItem;
  Begin
   // Submenu action updates do not change the visible menu bar. Reattaching
   // invokes VCL's RTL workaround; unconditional DrawMenuBar also flickers.
   If (FormStyle = fsNormal) And HandleAllocated And (Menu <> Nil) And
   Not Menu.AutoMerge And (GetMenu(Handle) = Menu.Handle) Then
    Begin
     State := IntToStr(Ord(BiDiMode));
     For i := 0 To Menu.Items.Count - 1 Do
      Begin
       Item := Menu.Items[i];
       If Item.Visible Then
        State := State + Format('|%d:%s:%d:%d:%d',
        [Length(Item.Caption), Item.Caption, Ord(Item.Enabled),
        Ord(Item.Checked), Item.ImageIndex]);
      End;
     If State <> fMenuVisualState Then
      Begin
       fMenuVisualState := State;
       If Not fMenuRepaintPending Then
        fMenuRepaintPending := PostMessage(Handle, WM_APP + $31F, 0, 0);
      End;
     Message.Result := 0;
    End
   Else
    Begin
     fMenuVisualState := '';
     Inherited;
    End;
  End;

 Procedure TLocalizedForm.RepaintMenu(Var Message : TMessage);
  Begin
   fMenuRepaintPending := False;
   If HandleAllocated And (Menu <> Nil) And (GetMenu(Handle) = Menu.Handle) Then
    DrawMenuBar(Handle);
   Message.Result := 0;
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

 Function LocalizedMessageDlg(Const Msg : String; DlgType : TMsgDlgType; Buttons : TMsgDlgButtons; HelpCtx : LongInt) : Integer;
  Var
   Dialog : TMessageDialog;
  Begin
   Dialog           := TMessageDialog.Create(Nil);
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
   Dialog           := TInputQueryDialog.Create(Nil);
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
