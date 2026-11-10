{------------------------------------------------------------------------------}
{                                                                              }
{  i18n Package                                                                }
{  Internationalization and Localization for Delphi                            }
{                                                                              }
{ Copyright(c) Kambiz Khojasteh                                              }
{  https://github.com/khojasteh/i18n                                           }
{                                                                              }
{------------------------------------------------------------------------------}

/// <summary>
/// This unit registers components, component editors, and property editors of
/// the i18n package.
/// </summary>
/// <remarks>
/// This unit cannot be referenced in the runtime packages.
/// </remarks>
Unit i18nReg;

{$I DELPHIAREA.INC}

Interface

 Uses
  Windows, Classes, SysUtils, DesignIntf, DesignEditors, Forms,
  i18nCore, i18nCtrls;

 Type
  TTranslatorComponentEditor = Class(TComponentEditor)
   Public
    Function GetVerbCount : Integer; Override;
    Function GetVerb(Index : Integer) : String; Override;
    Procedure ExecuteVerb(Index : Integer); Override;
    Procedure Edit; Override;
  End;

  TTranslatablePropertyEditor = Class(TClassProperty)
   Public
    Function GetAttributes : TPropertyAttributes; Override;
    Procedure Edit; Override;
  End;

  TURIPropertyEditor = Class(TStringProperty)
   Public
    Function GetAttributes : TPropertyAttributes; Override;
    Procedure Edit; Override;
  End;

  TCheckListClass = Class Of TCustomFlagCheckListBox;

  TCustomCheckListPropertyEditor = Class(TClassProperty)
   Private
    Procedure SelectAllClicked(Sender : TObject);
    Procedure ClearSelectionClicked(Sender : TObject);
    Procedure InvertSelectionClicked(Sender : TObject);
   Protected
    CheckList : TCustomFlagCheckListBox;
    Function CreateDialog(CheckListClass : TCheckListClass) : TForm;
   Public
    Function GetAttributes : TPropertyAttributes; Override;
  End;

  TCultureListPropertyEditor = Class(TCustomCheckListPropertyEditor)
   Public
    Procedure Edit; Override;
  End;

  TCulturePropertyEditor = Class(TPropertyEditor)
   Protected
    Function GetCultures : TReadonlyCultureList; Virtual;
   Public
    Function GetAttributes : TPropertyAttributes; Override;
    Procedure GetValues(Proc : TGetStrProc); Override;
    Function GetValue : String; Override;
    Procedure SetValue(Const Value : String); Override;
  End;

  TTerritoryListPropertyEditor = Class(TCustomCheckListPropertyEditor)
   Public
    Procedure Edit; Override;
  End;

  TTerritoryPropertyEditor = Class(TPropertyEditor)
   Protected
    Function GetTerritories : TReadonlyTerritoryList; Virtual;
   Public
    Function GetAttributes : TPropertyAttributes; Override;
    Procedure GetValues(Proc : TGetStrProc); Override;
    Function GetValue : String; Override;
    Procedure SetValue(Const Value : String); Override;
  End;

  TCurrencyListPropertyEditor = Class(TCustomCheckListPropertyEditor)
   Public
    Procedure Edit; Override;
  End;

  TCurrencyPropertyEditor = Class(TPropertyEditor)
   Protected
    Function GetCurrencies : TReadonlyCurrencyList; Virtual;
   Public
    Function GetAttributes : TPropertyAttributes; Override;
    Procedure GetValues(Proc : TGetStrProc); Override;
    Function GetValue : String; Override;
    Procedure SetValue(Const Value : String); Override;
  End;

  TGoogleLangPropertyEditor = Class(TStringProperty)
   Public
    Function GetAttributes : TPropertyAttributes; Override;
    Procedure GetValues(Proc : TGetStrProc); Override;
    Function GetValue : String; Override;
    Procedure SetValue(Const Value : String); Override;
  End;

  TCalendarSystemPropertyEditor = Class(TPropertyEditor)
   Public
    Function GetAttributes : TPropertyAttributes; Override;
    Procedure GetValues(Proc : TGetStrProc); Override;
    Function GetValue : String; Override;
    Procedure SetValue(Const Value : String); Override;
  End;

  TIntlDateTimePropertyEditor = Class(TDateProperty)
   Public
    Function GetAttributes : TPropertyAttributes; Override;
    Function GetValue : String; Override;
    Procedure SetValue(Const Value : String); Override;
    Procedure Edit; Override;
  End;

  TIntlDatePropertyEditor = Class(TDateProperty)
   Public
    Function GetAttributes : TPropertyAttributes; Override;
    Function GetValue : String; Override;
    Procedure SetValue(Const Value : String); Override;
    Procedure Edit; Override;
  End;

  TCoreSelectionEditor = Class(TSelectionEditor)
   Public
    Procedure RequiresUnits(Proc : TGetStrProc); Override;
  End;

  TCalendarSelectionEditor = Class(TSelectionEditor)
   Public
    Procedure RequiresUnits(Proc : TGetStrProc); Override;
  End;

 Procedure Register;

Implementation

 Uses
  i18nCatalog, i18nPropEditor, i18nLocalizer, i18nDialogs, i18nGoogle,
  i18nCalendar, i18nDateCtrls, Types, TypInfo, Graphics, Dialogs, Controls,
  StdCtrls, ExtCtrls, Menus, SysConst, i18nDBCtrls, i18nDBDateCtrls;

 Resourcestring
  SSelectTranslatables = 'Select translatables...';
  STranslationFileOpenTitle = 'Select a translation file';
  STranslationFileFileFilter = 'Translation Catalog Files|*' + i18nCatalogFileExt + '|All Files|*.*';
  SLocalizerManagedList = 'The languages in this list are managed by the localizer component and cannot be altered manually.';
  SLocalizerManagedProp = 'This property is managed by the linked localizer component and cannot be altered manually.';
  SDialogButtonOK = 'OK';
  SDialogButtonCancel = 'Cancel';
  SDialogItemSelect = 'Select All';
  SDialogItemDeselect = 'Clear Selection';
  SDialogItemInvert = 'Invert Selection';

 Procedure Register;
  Begin
   RegisterComponents('i18n', [TLocalizer, TTranslator]);
   RegisterComponents('i18n', [TMessageDialog, TInputQueryDialog]);
   RegisterComponents('i18n', [TGoogleTranslator, TFlagImageList, TImageLabel]);
   RegisterComponents('i18n', [TCultureLabel, TCultureBox, TCultureListBox, TCultureCheckListBox]);
   RegisterComponents('i18n', [TTerritoryLabel, TTerritoryBox, TTerritoryListBox, TTerritoryCheckListBox]);
   RegisterComponents('i18n', [TCurrencyLabel, TCurrencyBox, TCurrencyListBox, TCurrencyCheckListBox]);
   RegisterComponents('i18n', [TIntlDateTimeLabel, TIntlMonthCalendar, TIntlDatePicker]);

   RegisterComponents('i18n DB', [TDBImageLabel]);
   RegisterComponents('i18n DB', [TDBCultureLabel, TDBCultureBox, TDBCultureListBox]);
   RegisterComponents('i18n DB', [TDBTerritoryLabel, TDBTerritoryBox, TDBTerritoryListBox]);
   RegisterComponents('i18n DB', [TDBCurrencyLabel, TDBCurrencyBox, TDBCurrencyListBox]);
   RegisterComponents('i18n DB', [TDBIntlDateTimeLabel, TDBIntlDatePicker]);

   RegisterComponentEditor(TTranslator, TTranslatorComponentEditor);

   RegisterPropertyEditor(TypeInfo(TCultureInfo), Nil, '', TCulturePropertyEditor);
   RegisterPropertyEditor(TypeInfo(TTerritoryInfo), Nil, '', TTerritoryPropertyEditor);
   RegisterPropertyEditor(TypeInfo(TCurrencyInfo), Nil, '', TCurrencyPropertyEditor);

   RegisterPropertyEditor(TypeInfo(TCultureList), Nil, '', TCultureListPropertyEditor);
   RegisterPropertyEditor(TypeInfo(TTerritoryList), Nil, '', TTerritoryListPropertyEditor);
   RegisterPropertyEditor(TypeInfo(TCurrencyList), Nil, '', TCurrencyListPropertyEditor);

   RegisterPropertyEditor(TypeInfo(TTranslatables), TTranslator, 'Translatables', TTranslatablePropertyEditor);

   RegisterPropertyEditor(TypeInfo(String), TLocalizer, 'URI', TURIPropertyEditor);

   RegisterPropertyEditor(TypeInfo(String), TCustomGoogleService, 'SourceLang', TGoogleLangPropertyEditor);
   RegisterPropertyEditor(TypeInfo(String), TCustomGoogleService, 'TargetLang', TGoogleLangPropertyEditor);

   {$IFDEF COMPILER2010_UP}
   RegisterPropertyEditor(TypeInfo(TCalendarClass), Nil, '', TCalendarSystemPropertyEditor);
   {$ENDIF}

   RegisterPropertyEditor(TypeInfo(TDateTime), TCustomIntlDateTimeLabel, '', TIntlDateTimePropertyEditor);
   RegisterPropertyEditor(TypeInfo(TDate), TCustomIntlMonthCalendar, '', TIntlDatePropertyEditor);
   RegisterPropertyEditor(TypeInfo(TDate), TCustomIntlDatePicker, '', TIntlDatePropertyEditor);

   RegisterSelectionEditor(TLocalizer, TCoreSelectionEditor);
   RegisterSelectionEditor(TTranslator, TCoreSelectionEditor);
   RegisterSelectionEditor(TCustomGoogleTranslator, TCoreSelectionEditor);
   RegisterSelectionEditor(TCustomFlagImageList, TCoreSelectionEditor);
   RegisterSelectionEditor(TCustomCultureLabel, TCoreSelectionEditor);
   RegisterSelectionEditor(TCustomCultureBox, TCoreSelectionEditor);
   RegisterSelectionEditor(TCustomCultureListBox, TCoreSelectionEditor);
   RegisterSelectionEditor(TCustomCultureCheckListBox, TCoreSelectionEditor);
   RegisterSelectionEditor(TCustomTerritoryLabel, TCoreSelectionEditor);
   RegisterSelectionEditor(TCustomTerritoryBox, TCoreSelectionEditor);
   RegisterSelectionEditor(TCustomTerritoryListBox, TCoreSelectionEditor);
   RegisterSelectionEditor(TCustomTerritoryCheckListBox, TCoreSelectionEditor);

   RegisterSelectionEditor(TCustomIntlMonthCalendar, TCalendarSelectionEditor);
   RegisterSelectionEditor(TCustomIntlDatePicker, TCalendarSelectionEditor);
  End;

{ Helper Functions }

 Function IsManagedByLocalizer(Obj : TPersistent) : Boolean;
  Begin
   If Obj Is TCustomCultureLabel Then
    Result := TCustomCultureLabel(Obj).IsManagedByLocalizer
   Else If Obj Is TCustomCultureBox Then
    Result := TCustomCultureBox(Obj).IsManagedByLocalizer
   Else If Obj Is TCustomCultureListBox Then
    Result := TCustomCultureListBox(Obj).IsManagedByLocalizer
   Else If Obj Is TCustomCultureCheckListBox Then
    Result := TCustomCultureCheckListBox(Obj).IsManagedByLocalizer
   Else If Obj Is TCustomIntlDateTimeLabel Then
    Result := TCustomIntlDateTimeLabel(Obj).IsManagedByLocalizer
   Else If Obj Is TCustomIntlMonthCalendar Then
    Result := TCustomIntlMonthCalendar(Obj).IsManagedByLocalizer
   Else If Obj Is TCustomIntlDatePicker Then
    Result := TCustomIntlDatePicker(Obj).IsManagedByLocalizer
   Else
    Result := False;
  End;

 Function PromptForDate(Const ACaption : String; Var DateTime : TDateTime) : Boolean;
  Var
   Dialog  : TForm;
   IntlCal : TIntlMonthCalendar;
  Begin
   Result := False;
   Dialog := TForm.Create(Application);
   Try
    Dialog.BorderStyle  := bsDialog;
    Dialog.Position     := poMainFormCenter;
    Dialog.ClientWidth  := 360;
    Dialog.ClientHeight := 240;
    Dialog.BorderWidth  := 8;
    Dialog.Caption      := ACaption;
    IntlCal             := TIntlMonthCalendar.Create(Dialog);
    With IntlCal Do
     Begin
      SetBounds(0, 0, Dialog.ClientWidth, Dialog.ClientHeight - 33);
      FontHeader.Style    := [fsBold];
      FontHeader.Size     := FontHeader.Size + 2;
      FontFooter.Style    := [fsBold];
      FontDayOfWeek.Color := clNavy;
      If Not Calendar.IsNoDate(DateTime) Then
       Date  := DateTime;
      Parent := Dialog;
     End;
    With TButton.Create(Dialog) Do
     Begin
      SetBounds(Dialog.ClientWidth - 158, Dialog.ClientHeight - 25, 75, 25);
      Caption     := SDialogButtonOK;
      ModalResult := mrOk;
      Default     := True;
      Parent      := Dialog;
     End;
    With TButton.Create(Dialog) Do
     Begin
      SetBounds(Dialog.ClientWidth - 75, Dialog.ClientHeight - 25, 75, 25);
      Caption     := SDialogButtonCancel;
      ModalResult := mrCancel;
      Cancel      := True;
      Parent      := Dialog;
     End;
    If Dialog.ShowModal = mrOk Then
     Begin
      DateTime := IntlCal.Date;
      Result   := True;
     End;
   Finally
    Dialog.Free;
   End;
  End;

{ TTranslatorComponentEditor }

 Function TTranslatorComponentEditor.GetVerbCount : Integer;
  Begin
   Result := 1;
  End;

 Function TTranslatorComponentEditor.GetVerb(Index : Integer) : String;
  Begin
   If Index = 0 Then
    Result := SSelectTranslatables
   Else
    Result := Inherited GetVerb(Index);
  End;

 Procedure TTranslatorComponentEditor.ExecuteVerb(Index : Integer);
  Begin
   If Index = 0 Then
    Edit
   Else
    Inherited ExecuteVerb(Index);
  End;

 Procedure TTranslatorComponentEditor.Edit;
  Begin
   If TTranslatableEditor.Execute(TTranslator(GetComponent).Translatables) Then
    Designer.Modified;
  End;

{ TTranslatablePropertyEditor }

 Function TTranslatablePropertyEditor.GetAttributes : TPropertyAttributes;
  Begin
   Result := [paDialog];
  End;

 Procedure TTranslatablePropertyEditor.Edit;
  Begin
   If TTranslatableEditor.Execute(TTranslatables(GetOrdValue)) Then
    Designer.Modified;
  End;

{ TKnowledgeBasePropertyEditor }

 Function TURIPropertyEditor.GetAttributes : TPropertyAttributes;
  Begin
   Result := [paDialog, paRevertable];
  End;

 Procedure TURIPropertyEditor.Edit;
  Var
   FileName : String;
  Begin
   FileName := GetValue;
   If Pos('res:', LowerCase(FileName)) = 1 Then
    FileName := ''
   Else If Pos('dirx:', LowerCase(FileName)) = 1 Then
    FileName := Copy(FileName, 6, Length(FileName) - 5)
   Else If Pos('dir:', LowerCase(FileName)) = 1 Then
    FileName := Copy(FileName, 5, Length(FileName) - 4)
   Else If Pos('file:', LowerCase(FileName)) = 1 Then
    FileName := Copy(FileName, 6, Length(FileName) - 5);
   If PromptForFileName(FileName, STranslationFileFileFilter, i18nCatalogFileExt, STranslationFileOpenTitle) Then
    SetValue(FileName);
  End;

{ TCustomCheckListPropertyEditor }

 Function TCustomCheckListPropertyEditor.GetAttributes : TPropertyAttributes;
  Begin
   Result := [paDialog, paReadOnly];
  End;

 Type
   TCheckListHack = Class(TCustomFlagCheckListBox);

  Function TCustomCheckListPropertyEditor.CreateDialog(CheckListClass : TCheckListClass) : TForm;
   Var
    Dialog   : TForm;
    MenuItem : TMenuItem;
   Begin
    Dialog := TForm.CreateNew(Application);
    Try
     Dialog.BorderStyle  := bsDialog;
     Dialog.Position     := poMainFormCenter;
     Dialog.ClientWidth  := 350;
     Dialog.ClientHeight := 353;
     Dialog.BorderWidth  := 8;
     Dialog.Caption      := GetComponent(0).GetNamePath + '.' + GetName;
     CheckList           := CheckListClass.Create(Dialog);
     With TCheckListHack(CheckList) Do
      Begin
       PopupMenu := TPopupMenu.Create(Dialog);
       Flags     := TFlagImageList.Create(Dialog);
       Align     := alClient;
       Sorted    := True;
       Parent    := Dialog;
       CollectAll;
      End;
     With TButton.Create(Dialog) Do
      Begin
       SetBounds(0, Dialog.ClientHeight - 25, 120, 25);
       Caption := SDialogItemInvert;
       OnClick := InvertSelectionClicked;
       Parent  := Dialog;
      End;
     With TButton.Create(Dialog) Do
      Begin
       SetBounds(Dialog.ClientWidth - 158, Dialog.ClientHeight - 25, 75, 25);
       Caption     := SDialogButtonOK;
       ModalResult := mrOk;
       Default     := True;
       Parent      := Dialog;
      End;
     With TButton.Create(Dialog) Do
      Begin
       SetBounds(Dialog.ClientWidth - 75, Dialog.ClientHeight - 25, 75, 25);
       Caption     := SDialogButtonCancel;
       ModalResult := mrCancel;
       Cancel      := True;
       Parent      := Dialog;
      End;
     With TBevel.Create(Dialog) Do
      Begin
       Shape  := bsSpacer;
       Align  := alBottom;
       Height := 33;
       Parent := Dialog;
      End;
     With TCheckListHack(CheckList).PopupMenu Do
      Begin
       MenuItem         := TMenuItem.Create(Dialog);
       MenuItem.Caption := SDialogItemSelect;
       MenuItem.OnClick := SelectAllClicked;
       Items.Add(MenuItem);
       MenuItem         := TMenuItem.Create(Dialog);
       MenuItem.Caption := SDialogItemDeselect;
       MenuItem.OnClick := ClearSelectionClicked;
       Items.Add(MenuItem);
       MenuItem         := TMenuItem.Create(Dialog);
       MenuItem.Caption := SDialogItemInvert;
       MenuItem.OnClick := InvertSelectionClicked;
       Items.Add(MenuItem);
      End;
    Except
     Dialog.Free;
     Dialog := Nil;
    End;
    Result := Dialog;
  End;

 Procedure TCustomCheckListPropertyEditor.SelectAllClicked(Sender : TObject);
  Begin
   CheckList.RestateAll(cbChecked);
  End;

 Procedure TCustomCheckListPropertyEditor.ClearSelectionClicked(Sender : TObject);
  Begin
   CheckList.RestateAll(cbUnchecked);
  End;

 Procedure TCustomCheckListPropertyEditor.InvertSelectionClicked(Sender : TObject);
  Var
   i : Integer;
  Begin
   For i                 := 0 To CheckList.Count - 1 Do
    CheckList.Checked[i] := Not CheckList.Checked[i];
  End;

{ TCultureListPropertyEditor }

 Procedure TCultureListPropertyEditor.Edit;
  Var
   Dialog   : TForm;
   Cultures : TCultureList;
  Begin
   If IsManagedByLocalizer(GetComponent(0)) Then
    Begin
     MessageDlg(SLocalizerManagedList, mtWarning, [mbOK], 0);
     Exit;
    End;
   Cultures := TCultureList(GetOrdValue);
   Dialog   := CreateDialog(TCultureCheckListBox);
   Try
    TCultureCheckListBox(CheckList).SetSelection(Cultures);
    If Dialog.ShowModal = mrOk Then
     Begin
      TCultureCheckListBox(CheckList).GetSelection(Cultures);
      Modified;
     End;
   Finally
    Dialog.Free;
   End;
  End;

{ TCulturePropertyEditor }

 Function TCulturePropertyEditor.GetAttributes : TPropertyAttributes;
  Begin
   Result := [paValueList, paSortList, paRevertable];
  End;

 Procedure TCulturePropertyEditor.GetValues(Proc : TGetStrProc);
  Var
   i        : Integer;
   Cultures : TReadonlyCultureList;
  Begin
   Cultures := GetCultures;
   For i    := 0 To Cultures.Count - 1 Do
    Proc(Cultures[i].EnglishDisplayName);
  End;

 Function TCulturePropertyEditor.GetValue : String;
  Var
   Culture : TCultureInfo;
  Begin
   Culture := TCultureInfo(GetOrdValue);
   If Assigned(Culture) Then
    Result := Culture.EnglishDisplayName
   Else
    Result := '';
  End;

 Procedure TCulturePropertyEditor.SetValue(Const Value : String);
  Var
   i        : Integer;
   Cultures : TReadonlyCultureList;
  Begin
   If IsManagedByLocalizer(GetComponent(0)) Then
    Begin
     MessageDlg(SLocalizerManagedProp, mtWarning, [mbOK], 0);
     Exit;
    End;
   Cultures := GetCultures;
   i        := Cultures.IndexOfName(Value, cnEnglishDisplayName);
   If i < 0 Then
    i := Cultures.NearestIndexOf(Value);
   If i >= 0 Then
    SetOrdValue(Integer(Cultures[i]))
   Else
    SetOrdValue(0);
  End;

 Function TCulturePropertyEditor.GetCultures : TReadonlyCultureList;
  Var
   Component : TPersistent;
  Begin
   Component := GetComponent(0);
   If Component Is TLocalizer Then
    Result := TLocalizer(Component).Cultures
   Else If Component Is TCustomCultureBox Then
    Result := TCustomCultureBox(Component).Items
   Else If Component Is TCustomCultureListBox Then
    Result := TCustomCultureListBox(Component).Items
   Else If Component Is TCustomCultureCheckListBox Then
    Result := TCustomCultureCheckListBox(Component).Items
   Else
    Result := World.Cultures;
  End;

{ TTerritoryListPropertyEditor }

 Procedure TTerritoryListPropertyEditor.Edit;
  Var
   Dialog      : TForm;
   Territories : TTerritoryList;
  Begin
   Territories := TTerritoryList(GetOrdValue);
   Dialog      := CreateDialog(TTerritoryCheckListBox);
   Try
    TTerritoryCheckListBox(CheckList).SetSelection(Territories);
    If Dialog.ShowModal = mrOk Then
     Begin
      TTerritoryCheckListBox(CheckList).GetSelection(Territories);
      Modified;
     End;
   Finally
    Dialog.Free;
   End;
  End;

{ TTerritoryPropertyEditor }

 Function TTerritoryPropertyEditor.GetAttributes : TPropertyAttributes;
  Begin
   Result := [paValueList, paSortList, paRevertable];
  End;

 Procedure TTerritoryPropertyEditor.GetValues(Proc : TGetStrProc);
  Var
   i           : Integer;
   Territories : TReadonlyTerritoryList;
  Begin
   Territories := GetTerritories;
   For i       := 0 To Territories.Count - 1 Do
    Proc(Territories[i].FriendlyName);
  End;

 Function TTerritoryPropertyEditor.GetValue : String;
  Var
   Territory : TTerritoryInfo;
  Begin
   Territory := TTerritoryInfo(GetOrdValue);
   If Assigned(Territory) Then
    Result := Territory.FriendlyName
   Else
    Result := '';
  End;

 Procedure TTerritoryPropertyEditor.SetValue(Const Value : String);
  Var
   i           : Integer;
   Territories : TReadonlyTerritoryList;
  Begin
   Territories := GetTerritories;
   i           := Territories.IndexOfName(Value, tnFriendlyName);
   If i < 0 Then
    i := Territories.IndexOf(Value);
   If i >= 0 Then
    SetOrdValue(Integer(Territories[i]))
   Else
    SetOrdValue(0);
  End;

 Function TTerritoryPropertyEditor.GetTerritories : TReadonlyTerritoryList;
  Var
   Component : TPersistent;
  Begin
   Component := GetComponent(0);
   If Component Is TCustomTerritoryBox Then
    Result := TCustomTerritoryBox(Component).Items
   Else If Component Is TCustomTerritoryListBox Then
    Result := TCustomTerritoryListBox(Component).Items
   Else If Component Is TCustomTerritoryCheckListBox Then
    Result := TCustomTerritoryCheckListBox(Component).Items
   Else
    Result := World.Territories;
  End;

{ TCurrencyListPropertyEditor }

 Procedure TCurrencyListPropertyEditor.Edit;
  Var
   Dialog     : TForm;
   Currencies : TCurrencyList;
  Begin
   Currencies := TCurrencyList(GetOrdValue);
   Dialog     := CreateDialog(TCurrencyCheckListBox);
   Try
    TCurrencyCheckListBox(CheckList).SetSelection(Currencies);
    If Dialog.ShowModal = mrOk Then
     Begin
      TCurrencyCheckListBox(CheckList).GetSelection(Currencies);
      Modified;
     End;
   Finally
    Dialog.Free;
   End;
  End;

{ TCurrencyPropertyEditor }

 Function TCurrencyPropertyEditor.GetAttributes : TPropertyAttributes;
  Begin
   Result := [paValueList, paSortList, paRevertable];
  End;

 Procedure TCurrencyPropertyEditor.GetValues(Proc : TGetStrProc);
  Var
   i          : Integer;
   Currencies : TReadonlyCurrencyList;
  Begin
   Currencies := GetCurrencies;
   For i      := 0 To Currencies.Count - 1 Do
    Proc(Currencies[i].EnglishName);
  End;

 Function TCurrencyPropertyEditor.GetValue : String;
  Var
   Currency : TCurrencyInfo;
  Begin
   Currency := TCurrencyInfo(GetOrdValue);
   If Assigned(Currency) Then
    Result := Currency.EnglishName
   Else
    Result := '';
  End;

 Procedure TCurrencyPropertyEditor.SetValue(Const Value : String);
  Var
   i          : Integer;
   Currencies : TReadonlyCurrencyList;
  Begin
   Currencies := GetCurrencies;
   i          := Currencies.IndexOfName(Value, crnEnglishName);
   If i < 0 Then
    i := Currencies.IndexOf(Value);
   If i >= 0 Then
    SetOrdValue(Integer(Currencies[i]))
   Else
    SetOrdValue(0);
  End;

 Function TCurrencyPropertyEditor.GetCurrencies : TReadonlyCurrencyList;
  Var
   Component : TPersistent;
  Begin
   Component := GetComponent(0);
   If Component Is TCustomCurrencyBox Then
    Result := TCustomCurrencyBox(Component).Items
   Else If Component Is TCustomCurrencyListBox Then
    Result := TCustomCurrencyListBox(Component).Items
   Else If Component Is TCustomCurrencyCheckListBox Then
    Result := TCustomCurrencyCheckListBox(Component).Items
   Else
    Result := World.Currencies;
  End;

{ TGoogleLangPropertyEditor }

 Function TGoogleLangPropertyEditor.GetAttributes : TPropertyAttributes;
  Begin
   Result := [paValueList, paSortList, paRevertable];
  End;

 Function TGoogleLangPropertyEditor.GetValue : String;
  Var
   Culture : TCultureInfo;
   Lang    : String;
   Name    : String;
  Begin
   Lang    := Inherited GetValue;
   Culture := GoogleLangToCulture(Lang);
   If Assigned(Culture) Then
    Begin
     If Lang = Culture.Language2 Then
      Name := Culture.EnglishLanguageName
     Else
      Name  := Culture.EnglishDisplayName;
     Result := Lang + ' -- ' + Name;
    End
   Else
    Result := Lang;
  End;

 Procedure TGoogleLangPropertyEditor.GetValues(Proc : TGetStrProc);
  Var
   i       : Integer;
   Lang    : String;
   Name    : String;
   Culture : TCultureInfo;
  Begin
   For i := Low(GoogleLanguages) To High(GoogleLanguages) Do
    Begin
     Lang    := GoogleLanguages[i];
     Culture := GoogleLangToCulture(Lang);
     If Assigned(Culture) Then
      Begin
       If Lang = Culture.Language2 Then
        Name := Culture.EnglishLanguageName
       Else
        Name := Culture.EnglishDisplayName;
       Lang  := Lang + ' -- ' + Name;
      End;
     Proc(Lang);
    End;
  End;

 Procedure TGoogleLangPropertyEditor.SetValue(Const Value : String);
  Var
   Lang : String;
  Begin
   If Pos(' ', Value) <> 0 Then
    Lang := Copy(Value, 1, Pos(' ', Value) - 1)
   Else
    Lang := Value;
   Inherited SetValue(Lang);
  End;

{ TCalendarSystemPropertyEditor }

 Function TCalendarSystemPropertyEditor.GetAttributes : TPropertyAttributes;
  Begin
   Result := [paValueList, paSortList, paRevertable];
  End;

 Procedure TCalendarSystemPropertyEditor.GetValues(Proc : TGetStrProc);
  Var
   i : Integer;
  Begin
   For i := 0 To CalendarTypes.Count - 1 Do
    Proc(CalendarTypes.ByIndex(i).CalendarName);
  End;

 Function TCalendarSystemPropertyEditor.GetValue : String;
  Var
   CalendarClass : TCalendarClass;
  Begin
   CalendarClass := TCalendarClass(GetOrdValue);
   If Assigned(CalendarClass) Then
    Result := CalendarClass.CalendarName
   Else
    Result := '';
  End;

 Procedure TCalendarSystemPropertyEditor.SetValue(Const Value : String);
  Var
   CalendarClass : TCalendarClass;
  Begin
   CalendarClass := CalendarTypes.ByName(Trim(Value));
   If Assigned(CalendarClass) Then
    SetOrdValue(Integer(CalendarClass))
   Else
    SetOrdValue(0);
  End;

{ TIntlDateTimePropertyEditor }

 Function TIntlDateTimePropertyEditor.GetAttributes : TPropertyAttributes;
  Begin
   Result := [paDialog];
  End;

 Function TIntlDateTimePropertyEditor.GetValue : String;
  Var
   DT : TDateTime;
  Begin
   DT := GetFloatValue;
   If TCalendar.IsNoDate(DT) Then
    Result := ''
   Else
    Result := DefaultCalendar.Format('C', DT);
  End;

 Procedure TIntlDateTimePropertyEditor.SetValue(Const Value : String);
  Var
   DT : TDateTime;
  Begin
   If Value = '' Then
    SetFloatValue(TCalendar.NoDate)
   Else If DefaultCalendar.TryParse('C', Value, DT) Then
    SetFloatValue(DT)
   Else
    Raise EConvertError.CreateResFmt(@SInvalidDateTime, [Value]);
  End;

 Procedure TIntlDateTimePropertyEditor.Edit;
  Var
   DT      : TDateTime;
   Caption : String;
  Begin
   DT      := GetFloatValue;
   Caption := GetComponent(0).GetNamePath + '.' + GetName;
   If PromptForDate(Caption, DT) Then
    SetFloatValue(DT);
  End;

{ TIntlDatePropertyEditor }

 Function TIntlDatePropertyEditor.GetAttributes : TPropertyAttributes;
  Begin
   Result := [paDialog];
  End;

 Function TIntlDatePropertyEditor.GetValue : String;
  Var
   DT : TDateTime;
  Begin
   DT := GetFloatValue;
   If TCalendar.IsNoDate(DT) Then
    Result := ''
   Else
    Result := DefaultCalendar.Format('C', Trunc(DT));
  End;

 Procedure TIntlDatePropertyEditor.SetValue(Const Value : String);
  Var
   DT : TDateTime;
  Begin
   If Value = ''Then
    SetFloatValue(TCalendar.NoDate)
   Else If DefaultCalendar.TryParse('C', Value, DT) Then
    SetFloatValue(Trunc(DT))
   Else
    Raise EConvertError.CreateResFmt(@SInvalidDate, [Value]);
  End;

 Procedure TIntlDatePropertyEditor.Edit;
  Var
   DT      : TDateTime;
   Caption : String;
  Begin
   DT      := GetFloatValue;
   Caption := GetComponent(0).GetNamePath + '.' + GetName;
   If PromptForDate(Caption, DT) Then
    SetFloatValue(DT);
  End;

{ TCoreSelectionEditor }

 Procedure TCoreSelectionEditor.RequiresUnits(Proc : TGetStrProc);
  Begin
   Proc('i18nCore');
  End;

{ TCalendarSelectionEditor }

 Procedure TCalendarSelectionEditor.RequiresUnits(Proc : TGetStrProc);
  Begin
   Proc('i18nCore');
   Proc('i18nLocalizer');
   Proc('i18nCalendar');
  End;

End.
