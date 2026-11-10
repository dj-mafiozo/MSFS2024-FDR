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
/// This unit implements an editor for the <see cref="TTranslatable"/> class
/// to allow the developer to select the translatable properties and string
/// literals.
/// </summary>
/// <remarks>
/// This unit cannot be referenced in the runtime packages.
/// </remarks>
Unit i18nPropEditor;

{$I DELPHIAREA.INC}

Interface

 Uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  i18nCore, i18nLocalizer, i18nCatalog, i18nHashList, i18nCtrls, i18nParser,
  StdCtrls, ExtCtrls, ComCtrls, ImgList, ActnList, Menus, StdActns, Tabs,
  System.Actions, i18nUnicode;

 Type

  {$Region 'xmldoc'}
  /// <summary>
  /// TTranslatablesUI engages some UI gadgets to display a list of translatable
  /// strings, so that the user can edit them and select which ones should be
  /// available to a translator.
  /// </summary>
  {$Endregion}
  TTranslatablesUI = Class
   Public
    Type
    {$Region 'xmldoc'}
    /// <summary>
    /// This enumeration type identifies the ways that a list of translatable
    /// strings can be filtered to display.
    /// </summary>
    {$Endregion}
    TFilterType = (
    {$Region 'xmldoc'}
    /// Displays all strings without filtering.
    {$Endregion}
    ftNone = 1,
    {$Region 'xmldoc'}
    /// Only lists strings with alphabetic characters.
    {$Endregion}
    ftAlphaValue,
    {$Region 'xmldoc'}
    /// Only lists strings with any non-alphabetic character.
    {$Endregion}
    ftNonAlphaValue,
    {$Region 'xmldoc'}
    /// Only lists strings with one character in length.
    {$Endregion}
    ftCharValue,
    {$Region 'xmldoc'}
    /// For properties, only lists those that their property path contains 'name'.
    /// For literals, only lists those that have plural forms.
    {$Endregion}
    ftNamePropertyOrPluralLiteral,
    {$Region 'xmldoc'}
    /// Only lists strings that satisfy a user-defined condition.
    {$Endregion}
    ftCustom
    );
    {$Region 'xmldoc'}
    /// <summary>
    /// TStats keeps the number of total and selected translatable strings in
    /// each filtering group.
    /// </summary>
    {$Endregion}
    TStats = Record
     {$Region 'xmldoc'}
     /// Lists the total number of items for each filtering group.
     {$Endregion}
     Total : Array[TFilterType] Of Integer;
     {$Region 'xmldoc'}
     /// Lists the number of selected items for each filtering group.
     {$Endregion}
     Selected : Array[TFilterType] Of Integer;
    End;
   Private
    fKind           : TTextDitionaryKind;
    fListControl    : TListView;
    fFilterControl  : TCustomListControl;
    fValueControl   : TCustomMemo;
    fCommentControl : TCustomMemo;
    fActiveFilter   : TFilterType;
    fCustomFilter   : String;
    fSelectedItem   : TTextItem;
    fPluralIndex    : Integer;
    Procedure SetActiveFilter(Value : TFilterType);
    Procedure SetCustomFilter(Const Value : String);
    Procedure SetSelectedItem(Value : TTextItem);
    Procedure SetPluralIndex(Value : Integer);
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Updates content of the linked controls to reflect the current
    /// state of the strings.
    /// </summary>
    {$Endregion}
    Procedure UpdateControls;
    {$Region 'xmldoc'}
    /// <summary>
    /// Determines which filtering options is the most suited for a specified
    /// string item.
    /// </summary>
    /// <param name="Item">
    /// The string item to examine.
    /// </param>
    /// <returns>
    /// Returns the <see cref="TFilterType"/> value that is the
    /// most suited for the given <paramref name="Item"/>.
    /// </returns>
    {$Endregion}
    Function FilterTagOf(Item : TTextItem) : TFilterType;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the image index of a specified string item.
    /// </summary>
    /// <param name="Item">
    /// The string item to get its image index.
    /// </param>
    /// <returns>
    /// The image index of the given <paramref name="Item"/>.
    /// </returns>
    {$Endregion}
    Function ImageIndexOf(Item : TTextItem) : Integer;
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts a specified filter value to a zero-based integer value.
    /// </summary>
    /// <param name="Filter">
    /// The filter value to convert.
    /// </param>
    /// <returns>
    /// Returns the zero-based integer value of <paramref name="Filter"/>.
    /// </returns>
    /// <seealso cref="FilterOfIndex"/>
    {$Endregion}
    Function IndexOfFilter(Filter : TFilterType) : Integer;
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts a specified filter as a zero-based integer value to a filter
    /// value.
    /// </summary>
    /// <param name="Index">
    /// The integer value to convert.
    /// </param>
    /// <returns>
    /// Returns filter value of <paramref name="Index"/>.
    /// </returns>
    /// <seealso cref="IndexOfFilter"/>
    {$Endregion}
    Function FilterOfIndex(Index : Integer) : TFilterType;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// The list of all string items.
    /// </summary>
    {$Endregion}
    All : TTextItems;
    {$Region 'xmldoc'}
    /// <summary>
    /// The list of item IDs that indicates which string items are selected.
    /// </summary>
    {$Endregion}
    Selection : TStringList;
    {$Region 'xmldoc'}
    /// <summary>
    /// The number of total and selected string items in each filtering group.
    /// </summary>
    {$Endregion}
    Stats : TStats;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the class.
    /// </summary>
    /// <param name="AKind">
    /// Indicates whether the class is instantiated for a list of properties or
    /// a list of string constants and literals.
    /// </param>
    /// <param name="AListControl">
    /// The control that displays the list of items.
    /// </param>
    /// <param name="AFilterControl">
    /// The control that provides filtering options.
    /// </param>
    /// <param name="AValueControl">
    /// The control that displays the value of an item.
    /// </param>
    /// <param name="ACommentControl">
    /// The control that displays the comment of an item.
    /// </param>
    {$Endregion}
    Constructor Create(AKind : TTextDitionaryKind; AListControl : TListView; AFilterControl : TCustomListControl; AValueControl, ACommentControl : TCustomMemo);
    {$Region 'xmldoc'}
    /// <summary>
    /// Destroys the instance and releases its allocated memory.
    /// </summary>
    {$Endregion}
    Destructor Destroy; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Selects a specified list of items.
    /// </summary>
    /// <param name="SelectedItems">
    /// The list of items to be selected.
    /// </param>
    /// <seealso cref="GetSelection"/>
    {$Endregion}
    Procedure SetSelection(SelectedItems : TTextItems);
    {$Region 'xmldoc'}
    /// <summary>
    /// Retrieves the list of selected items.
    /// </summary>
    /// <param name="SelectedItems">
    /// Returns the list of selected items.
    /// </param>
    /// <seealso cref="SetSelection"/>
    {$Endregion}
    Procedure GetSelection(SelectedItems : TTextItems);
    {$Region 'xmldoc'}
    /// <summary>
    /// Retrieves the list of items whose value has been edited by the user.
    /// </summary>
    /// <param name="UpdatedItems">
    /// Returns the list of edited items.
    /// </param>
    /// <seealso cref="GetSelection"/>
    {$Endregion}
    Procedure GetUpdated(UpdatedItems : TTextItems);
    {$Region 'xmldoc'}
    /// <summary>
    /// Selects or deselects a specified item.
    /// </summary>
    /// <param name="Item">
    /// The item to select or deselect.
    /// </param>
    /// <param name="Checked">
    /// Indicates whether the item should be selected or deselected.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if selection state of the item is changed.
    /// Otherwise, returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="GetChecked"/>
    /// <seealso cref="SetAllState"/>
    {$Endregion}
    Function SetChecked(Item : TTextItem; Checked : Boolean) : Boolean;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether an item is selected.
    /// </summary>
    /// <param name="Item">
    /// The item to examine.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the item is selected, Otherwise, returns
    /// <see langword="false"/>.
    /// </returns>
    /// <seealso cref="SetChecked"/>
    {$Endregion}
    Function GetChecked(Item : TTextItem) : Boolean;
    {$Region 'xmldoc'}
    /// <summary>
    /// Changes selection state of all items according to a specified state.
    /// </summary>
    /// <remarks>
    /// SetAllState changes state of all the items (<see cref="All"/>) according
    /// to the given <paramref name="State"/> value.
    /// <list type="table">
    ///   <listheader>
    ///     <term>State</term>
    ///     <description>Description</description>
    ///   </listheader>
    ///   <item>
    ///     <term>cbUnchecked</term>
    ///     <description>Deselects all the items.</description>
    ///   </item>
    ///   <item>
    ///     <term>cbChecked</term>
    ///     <description>Selects all the items.</description>
    ///   </item>
    ///   <item>
    ///     <term>cbGrayed</term>
    ///     <description>Toggles selection of all the items.</description>
    ///   </item>
    /// </list>
    /// </remarks>
    /// <param name="State">
    /// Specifies the new state of the items.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if selection state of any item is changed.
    /// Otherwise, returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="SetChecked"/>
    /// <seealso cref="CanSetAllState"/>
    {$Endregion}
    Function SetAllState(State : TCheckBoxState) : Boolean;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether any of the items in the list can change its state to a
    /// specified state.
    /// </summary>
    /// <param name="State">
    /// Specifies the new state of the items.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if state of any item can be changed, otherwise
    /// returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="SetAllState"/>
    {$Endregion}
    Function CanSetAllState(State : TCheckBoxState) : Boolean;
    {$Region 'xmldoc'}
    /// <summary>
    /// Reevaluates the information regarding to a specified item.
    /// </summary>
    /// <param name="Item">
    /// The item to reevaluate.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the reevaluation caused any changes,
    /// otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function Reevaluate(Item : TTextItem) : Boolean;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether a specified item is visible by the currently active
    /// filter.
    /// </summary>
    /// <param name="Item">
    /// The item to examine.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the item satisfies the currently active
    /// filter, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function IsVisible(Item : TTextItem) : Boolean;
    {$Region 'xmldoc'}
    /// <summary>
    /// Activates a filter using its zero-based index.
    /// </summary>
    /// <param name="Index">
    /// The zero-based index of the filter to activate.
    /// </param>
    /// <param name="CustomFilterPrompt">
    /// The prompt string that will be displayed to the user if the activated
    /// filter is a custom filter.
    /// </param>
    /// <seealso cref="ActiveFilter"/>
    {$Endregion}
    Procedure ActivateFilterByIndex(Index : Integer; Const CustomFilterPrompt : String);
    {$Region 'xmldoc'}
    /// <summary>
    /// Updates the value of the selected item using the attached edit control.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> if the value of the item is changed, otherwise
    /// returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="UpdateSelectedItemComment"/>
    /// <seealso cref="SelectedItem"/>
    {$Endregion}
    Function UpdateSelectedItemValue : Boolean;
    {$Region 'xmldoc'}
    /// <summary>
    /// Updates the comment of the selected item using the attached edit control.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> if the comment of the item is changed, otherwise
    /// returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="UpdateSelectedItemValue"/>
    /// <seealso cref="SelectedItem"/>
    {$Endregion}
    Function UpdateSelectedItemComment : Boolean;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets whether the object is representing a list of translatable properties
    /// or a list of translatable string constants and literals.
    /// </summary>
    {$Endregion}
    Property Kind : TTextDitionaryKind Read fKind;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the control that lists the translatable strings.
    /// </summary>
    {$Endregion}
    Property ListControl : TListView Read fListControl;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the control that provides filtering options.
    /// </summary>
    {$Endregion}
    Property FilterControl : TCustomListControl Read fFilterControl;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the control that displays value of the selected item.
    /// </summary>
    /// <seealso cref="SelectedItem"/>
    {$Endregion}
    Property ValueControl : TCustomMemo Read fValueControl;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the control that displays comment of the selected item.
    /// </summary>
    /// <seealso cref="SelectedItem"/>
    {$Endregion}
    Property CommentControl : TCustomMemo Read fCommentControl;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets of sets the currently active filter.
    /// </summary>
    {$Endregion}
    Property ActiveFilter : TFilterType Read fActiveFilter Write SetActiveFilter;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the user-defined filtering string.
    /// </summary>
    {$Endregion}
    Property CustomFilter : String Read fCustomFilter Write SetCustomFilter;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the translatable string that its value and comment is currently
    /// displayed.
    /// </summary>
    {$Endregion}
    Property SelectedItem : TTextItem Read fSelectedItem Write SetSelectedItem;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets which of the plural forms of the selected item is currently
    /// displayed.
    /// </summary>
    /// <seealso cref="SelectedItem"/>
    {$Endregion}
    Property PluralIndex : Integer Read fPluralIndex Write SetPluralIndex;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TTranslatableEditor displays a dialog box to select the translatable strings
/// that can be translated by a <see cref="TTranslator"/> component.
/// </summary>
{$Endregion}

  TTranslatableEditor = Class(TForm)
    PageControl            : TPageControl;
    tabProperties          : TTabSheet;
    tabLiterals            : TTabSheet;
    tabExport              : TTabSheet;
    btnOK                  : TButton;
    btnCancel              : TButton;
    PropertyList           : TListView;
    ImageList              : TImageList;
    PropertyFilter         : TComboBox;
    LiteralList            : TListView;
    TextLanguageLabel      : TLabel;
    SaveDialog             : TSaveDialog;
    btnExportTo            : TButton;
    ActionList             : TActionList;
    PropsCheckAll          : TAction;
    PropsUncheckAll        : TAction;
    PropsInvertCheck       : TAction;
    PropertiesPopup        : TPopupMenu;
    CheckAll1              : TMenuItem;
    UncheckAll1            : TMenuItem;
    Invert1                : TMenuItem;
    LiteralsPopup          : TPopupMenu;
    btnPropsCheckAll       : TButton;
    btnPropsUncheckAll     : TButton;
    btnPropsInvertCheck    : TButton;
    LiteralsCheckAll       : TAction;
    LiteralsUncheckAll     : TAction;
    LiteralsInvertCheck    : TAction;
    LiteralFilter          : TComboBox;
    btnLiteralsCheckAll    : TButton;
    btnLiteralsUncheckAll  : TButton;
    btnLiteralsInvertCheck : TButton;
    CheckAll2              : TMenuItem;
    UncheckAll2            : TMenuItem;
    Invert2                : TMenuItem;
    ExportCommentsLabel    : TLabel;
    LanguageBoxPlaceHolder : TComboBox;
    TextEditorPopupMenu    : TPopupMenu;
    EditCutAction          : TEditCut;
    EditCopyAction         : TEditCopy;
    EditPasteAction        : TEditPaste;
    EditSelectAllAction    : TEditSelectAll;
    EditUndoAction         : TEditUndo;
    Undo1                  : TMenuItem;
    N1                     : TMenuItem;
    Cut1                   : TMenuItem;
    Copy1                  : TMenuItem;
    Paste1                 : TMenuItem;
    N2                     : TMenuItem;
    SelectAll1             : TMenuItem;
    PropertiesTabSet       : TTabSet;
    PropertyValue          : TMemo;
    PropertyComments       : TMemo;
    LiteralValue           : TMemo;
    LiteralComments        : TMemo;
    LiteralsTabSet         : TTabSet;
    LiteralPlurals         : TTabSet;
    Procedure FormCreate(Sender : TObject);
    Procedure FormDestroy(Sender : TObject);
    Procedure FormShow(Sender : TObject);
    Procedure PropertyFilterSelect(Sender : TObject);
    Procedure FilterDrawItem(Control : TWinControl; Index : Integer; Rect : TRect; State : TOwnerDrawState);
    Procedure ListViewCustomDraw(Sender : TCustomListView; Const ARect : TRect; Var DefaultDraw : Boolean);
    Procedure ListViewCustomDrawItem(Sender : TCustomListView; Item : TListItem; State : TCustomDrawState; Var DefaultDraw : Boolean);
    Procedure PropertyListSelectItem(Sender : TObject; Item : TListItem; Selected : Boolean);
    Procedure PropsCheckAllExecute(Sender : TObject);
    Procedure PropsCheckAllUpdate(Sender : TObject);
    Procedure PropsUncheckAllExecute(Sender : TObject);
    Procedure PropsUncheckAllUpdate(Sender : TObject);
    Procedure PropsInvertCheckExecute(Sender : TObject);
    Procedure PropsInvertCheckUpdate(Sender : TObject);
    Procedure PropertyValueExit(Sender : TObject);
    Procedure PropertyCommentsExit(Sender : TObject);
    Procedure PropertiesTabSetChange(Sender : TObject; NewTab : Integer; Var AllowChange : Boolean);
    Procedure LiteralFilterSelect(Sender : TObject);
    Procedure LiteralListSelectItem(Sender : TObject; Item : TListItem; Selected : Boolean);
    Procedure LiteralsCheckAllExecute(Sender : TObject);
    Procedure LiteralsCheckAllUpdate(Sender : TObject);
    Procedure LiteralsUncheckAllExecute(Sender : TObject);
    Procedure LiteralsUncheckAllUpdate(Sender : TObject);
    Procedure LiteralsInvertCheckExecute(Sender : TObject);
    Procedure LiteralsInvertCheckUpdate(Sender : TObject);
    Procedure LiteralValueExit(Sender : TObject);
    Procedure LiteralCommentsExit(Sender : TObject);
    Procedure LiteralsTabSetChange(Sender : TObject; NewTab : Integer; Var AllowChange : Boolean);
    Procedure LiteralListCustomDraw(Sender : TCustomListView; Const ARect : TRect; Var DefaultDraw : Boolean);
    Procedure btnExportToClick(Sender : TObject);
    Procedure PropertyListItemChecked(Sender : TObject; Item : TListItem);
    Procedure LiteralListItemChecked(Sender : TObject; Item : TListItem);
    Procedure LanguageBoxSelect(Sender : TObject);
    Procedure LiteralPluralsChange(Sender : TObject; NewTab : Integer; Var AllowChange : Boolean);
   Private
    Const FILTER_DEFAULT = TTranslatablesUI.TFilterType.ftNone;
   Private
    Properties        : TTranslatablesUI;
    Literals          : TTranslatablesUI;
    Translatables     : TTranslatables;
    TextLanguage      : TCultureBox;
    LiteralCollector  : TPascalStringCollector;
    CollectorErrorMsg : String;
    Procedure ReadProperties;
    Procedure WriteProperties;
    Procedure ReadLiterals;
    Procedure WriteLiterals;
    Procedure AddTranslatablesTo(Catalog : TTranslationCatalog; KeepObsoleteEntries : Boolean);
    Procedure ExportTo(Const FileName : String);
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Displays the editor for a specified <see cref="TTranslatables"/> object.
    /// </summary>
    /// <param name="ATranslatables">
    /// The <see cref="TTranslatables"/> object to edit.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the <see cref="TTranslatables"/>
    /// object is modified, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Class Function Execute(ATranslatables : TTranslatables) : Boolean;
  End;

Implementation

{$R *.dfm}

 Uses
  Types, StrUtils, Character, CommCtrl, i18nZStrList, i18nIDE;

 Resourcestring
  SEditorCaption = 'Translatables of %s';
  SCustomFilter = 'Custom Filter';
  SPropertyFilterPrompt = 'Property''s path contains:';
  SLiteralFilterPrompt = 'String contains:';
  SNoItemsToView = 'There are no items to show in this view.';
  SCollectError = 'Constant and literal strings can not be collected from the source code.';
  SParserError = 'The parser found error in your code: %s';
  SFileExists = '%s alreay exists.';
  SContentMismatch = 'The selected file is not a translation catalog file.';
  SLanguageMismatch = 'The base language of the selected translation catalog file is not same as the selected language.';
  SUpdateAction = 'Press [OK] to update the content of the file.';
  SReplaceAction = 'Press [OK] to replace the file.';
  SCancelAction = 'Press [Cancel] to stop the operation.';

 Const
  clAlternative = $F9FBFB;

{ Helper Functions }

 Function IsStringAlpha(Const Str : String) : Boolean;
  Var
   i : Integer;
  Begin
   Result := False;
   For i  := 1 To Length(Str) Do
    If CharIsLetter(Str[i]) Then
     Begin
      Result := True;
      Exit;
     End;
  End;

{ TStringsInfo }

 Constructor TTranslatablesUI.Create(AKind : TTextDitionaryKind; AListControl : TListView; AFilterControl : TCustomListControl; AValueControl, ACommentControl : TCustomMemo);
  Begin
   All                  := TTextItems.Create;
   Selection            := TStringList.Create;
   Selection.Duplicates := dupIgnore;
   Selection.Sorted     := True;
   fKind                := AKind;
   fListControl         := AListControl;
   fFilterControl       := AFilterControl;
   fValueControl        := AValueControl;
   fCommentControl      := ACommentControl;
  End;

 Destructor TTranslatablesUI.Destroy;
  Begin
   All.Free;
   Selection.Free;
   Inherited Destroy;
  End;

 Procedure TTranslatablesUI.SetActiveFilter(Value : TFilterType);
  Begin
   If ActiveFilter <> Value Then
    Begin
     fActiveFilter := Value;
     UpdateControls;
    End;
  End;

 Procedure TTranslatablesUI.SetCustomFilter(Const Value : String);
  Begin
   If (CustomFilter <> Value) Or ((Value <> '') And (ActiveFilter <> ftCustom)) Then
    Begin
     fActiveFilter := ftCustom;
     fCustomFilter := Value;
     UpdateControls;
    End;
  End;

 Procedure TTranslatablesUI.SetSelectedItem(Value : TTextItem);
  Begin
   If SelectedItem <> Value Then
    Begin
     fSelectedItem := Value;
     fPluralIndex  := 0;
     If Assigned(SelectedItem) Then
      Begin
       If SelectedItem.HasPluralForms Then
        ValueControl.Text := SelectedItem.Plurals[PluralIndex]
       Else
        ValueControl.Text      := SelectedItem.Value;
       ValueControl.Modified   := False;
       ValueControl.ReadOnly   := (Kind = dkLiteral);
       CommentControl.Text     := SelectedItem.Comment;
       CommentControl.Modified := False;
       CommentControl.ReadOnly := False;
      End
     Else
      Begin
       ValueControl.Clear;
       ValueControl.ReadOnly := True;
       CommentControl.Clear;
       CommentControl.ReadOnly := True;
      End;
    End;
  End;

 Procedure TTranslatablesUI.SetPluralIndex(Value : Integer);
  Begin
   If Not(Assigned(SelectedItem) And SelectedItem.HasPluralForms) Then
    Value := 0;
   If PluralIndex <> Value Then
    Begin
     fPluralIndex      := Value;
     ValueControl.Text := SelectedItem.Plurals[PluralIndex];
    End;
  End;

 Procedure TTranslatablesUI.SetSelection(SelectedItems : TTextItems);
  Var
   Item   : TTextItem;
   Source : TTextItem;
   Filter : TFilterType;
  Begin
   // prepare selection list
   Item := SelectedItems.First;
   While Item <> Nil Do
    Begin
     Source := All.Find(Item.ID);
     If Source <> Nil Then
      Begin
       Source.Comment := Item.Comment;
       Selection.Add(Source.ID)
      End;
     Item := Item.Next;
    End;
   // prepare filter information
   Stats.Total[ftNone]    := All.Count;
   Stats.Selected[ftNone] := Selection.Count;
   Item                   := All.First;
   While Item <> Nil Do
    Begin
     Filter   := FilterTagOf(Item);
     Item.Tag := Ord(Filter);
     Inc(Stats.Total[Filter]);
     If GetChecked(Item) Then
      Inc(Stats.Selected[Filter]);
     Item := Item.Next;
    End;
  End;

 Procedure TTranslatablesUI.GetSelection(SelectedItems : TTextItems);
  Var
   Item : TTextItem;
  Begin
   SelectedItems.Clear;
   Item := All.First;
   While Item <> Nil Do
    Begin
     If GetChecked(Item) Then
      SelectedItems.Add(Item.ID).Assign(Item);
     Item := Item.Next;
    End;
  End;

 Procedure TTranslatablesUI.GetUpdated(UpdatedItems : TTextItems);
  Var
   Item : TTextItem;
  Begin
   UpdatedItems.Clear;
   Item := All.First;
   While Item <> Nil Do
    Begin
     If Item.IsTranslated Then
      UpdatedItems.Add(Item.ID).Assign(Item);
     Item := Item.Next;
    End;
  End;

 Function TTranslatablesUI.FilterTagOf(Item : TTextItem) : TFilterType;
  Begin
   If (Kind = dkProperty) And AnsiEndsText('Name', Item.ID) Then
    Result := ftNamePropertyOrPluralLiteral
   Else If (Kind = dkLiteral) And Item.HasPluralForms Then
    Result := ftNamePropertyOrPluralLiteral
   Else If Length(Item.Value) = 1 Then
    Result := ftCharValue
   Else If IsStringAlpha(Item.Value) Then
    Result := ftAlphaValue
   Else
    Result := ftNonAlphaValue;
  End;

 Function TTranslatablesUI.ImageIndexOf(Item : TTextItem) : Integer;
  Begin
   If Item.Tag = 0 Then
    Item.Tag := Ord(FilterTagOf(Item));
   Result    := Item.Tag;
   If Item.Comment <> '' Then
    Inc(Result, 7);
  End;

 Function TTranslatablesUI.FilterOfIndex(Index : Integer) : TFilterType;
  Begin
   Result := TFilterType(Index + 1);
  End;

 Function TTranslatablesUI.IndexOfFilter(Filter : TFilterType) : Integer;
  Begin
   Result := Ord(Filter) - 1;
  End;

 Function TTranslatablesUI.IsVisible(Item : TTextItem) : Boolean;
  Begin
   If ActiveFilter = ftCustom Then
    If Kind = dkProperty Then
     Result := (Pos(LowerCase(CustomFilter), LowerCase(Item.ID)) <> 0)
    Else
     Result := (Pos(LowerCase(CustomFilter), LowerCase(Item.Value)) <> 0)
   Else
    Result := (ActiveFilter In [ftNone, TFilterType(Item.Tag)]);
  End;

 Procedure TTranslatablesUI.UpdateControls;
  Var
   Item               : TTextItem;
   SavedOnItemChecked : TLVCheckedItemEvent;
  Begin
   If ActiveFilter = ftCustom Then
    Begin
     Stats.Total[ftCustom]    := 0;
     Stats.Selected[ftCustom] := 0;
    End;
   SelectedItem              := Nil;
   SavedOnItemChecked        := ListControl.OnItemChecked;
   ListControl.OnItemChecked := Nil;
   ListControl.Items.BeginUpdate;
   Try
    ListControl.Items.Clear;
    Item := All.First;
    While Item <> Nil Do
     Begin
      If IsVisible(Item) Then
       With ListControl.Items.Add Do
        Begin
         Data := Item;
         If Kind = dkProperty Then
          Begin
           Caption := Item.ID;
           SubItems.Add(Item.Value);
          End
         Else If Item.HasPluralForms Then
          Begin
           Caption := ZStrings.Split(Item.Value, '|');
           SubItems.Add(IntToStr(Item.PluralCount));
          End
         Else
          Caption   := Item.Value;
         ImageIndex := ImageIndexOf(Item);
         Checked    := GetChecked(Item);
         If ActiveFilter = ftCustom Then
          Begin
           Inc(Stats.Total[ftCustom]);
           If Checked Then
            Inc(Stats.Selected[ftCustom]);
          End;
        End;
      Item := Item.Next;
     End;
   Finally
    ListControl.Items.EndUpdate;
    ListControl.OnItemChecked := SavedOnItemChecked;
   End;
   If ListControl.Items.Count > 0 Then
    ListControl.ItemIndex  := 0;
   ListControl.Width       := ListControl.Width + 1;
   ListControl.Width       := ListControl.Width - 1;
   FilterControl.ItemIndex := IndexOfFilter(ActiveFilter);
   If ActiveFilter = ftCustom Then
    FilterControl.Invalidate;
  End;

 Function TTranslatablesUI.SetChecked(Item : TTextItem; Checked : Boolean) : Boolean;
  Var
   Index : Integer;
  Begin
   Result := False;
   If Item.HasPluralForms Then
    Exit;
   Index := Selection.IndexOf(Item.ID);
   If Checked Xor (Index >= 0) Then
    Begin
     If Checked Then
      Begin
       Selection.Add(Item.ID);
       Inc(Stats.Selected[TFilterType(Item.Tag)]);
       Inc(Stats.Selected[ftNone]);
      End
     Else
      Begin
       Selection.Delete(Index);
       Dec(Stats.Selected[TFilterType(Item.Tag)]);
       Dec(Stats.Selected[ftNone]);
      End;
     FilterControl.Invalidate;
     Result := True;
    End;
  End;

 Function TTranslatablesUI.GetChecked(Item : TTextItem) : Boolean;
  Begin
   Result := Item.HasPluralForms Or (Selection.IndexOf(Item.ID) >= 0);
  End;

 Function TTranslatablesUI.SetAllState(State : TCheckBoxState) : Boolean;
  Var
   i                  : Integer;
   SavedOnItemChecked : TLVCheckedItemEvent;
  Begin
   Result             := False;
   SavedOnItemChecked := ListControl.OnItemChecked;
   Try
    For i := 0 To ListControl.Items.Count - 1 Do
     With ListControl.Items[i] Do
      Begin
       If TTextItem(Data).HasPluralForms Then
        Continue;
       Case State Of
        cbUnchecked :
         Begin
          If SetChecked(TTextItem(Data), False) Then
           Begin
            Checked := False;
            Result  := True;
           End;
         End;
        cbChecked :
         Begin
          If SetChecked(TTextItem(Data), True) Then
           Begin
            Checked := True;
            Result  := True;
           End;
         End;
       Else
         Checked := Not Checked;
         If SetChecked(TTextItem(Data), Checked) Then
          Result := True;
       End;
      End;
   Finally
    ListControl.OnItemChecked := SavedOnItemChecked;
   End;
  End;

 Function TTranslatablesUI.CanSetAllState(State : TCheckBoxState) : Boolean;
  Var
   StatsFixed : Integer;
  Begin
   StatsFixed := 0;
   If (Kind = dkLiteral) And (ActiveFilter In [ftNone, ftNamePropertyOrPluralLiteral]) Then
    StatsFixed := Stats.Total[ftNamePropertyOrPluralLiteral];
   Case State Of
    cbUnchecked : Result := (Stats.Selected[ActiveFilter] <> StatsFixed);
    cbChecked   : Result := (Stats.Selected[ActiveFilter] <> Stats.Total[ActiveFilter]);
   Else Result := (Stats.Total[ActiveFilter] <> StatsFixed);
   End;
  End;

 Function TTranslatablesUI.Reevaluate(Item : TTextItem) : Boolean;
  Var
   OldFilter : TFilterType;
   NewFilter : TFilterType;
  Begin
   Result    := False;
   OldFilter := TFilterType(Item.Tag);
   NewFilter := FilterTagOf(Item);
   If NewFilter <> OldFilter Then
    Begin
     Dec(Stats.Total[OldFilter]);
     Inc(Stats.Total[NewFilter]);
     If Selection.IndexOf(Item.ID) >= 0 Then
      Begin
       Dec(Stats.Selected[OldFilter]);
       Inc(Stats.Selected[NewFilter]);
      End;
     Item.Tag := Ord(NewFilter);
     FilterControl.Invalidate;
     Result := True;
    End;
  End;

 Procedure TTranslatablesUI.ActivateFilterByIndex(Index : Integer; Const CustomFilterPrompt : String);
  Var
   Filter : String;
  Begin
   ActiveFilter := FilterOfIndex(Index);
   If ActiveFilter = ftCustom Then
    Begin
     Filter := CustomFilter;
     If InputQuery(SCustomFilter, CustomFilterPrompt, Filter) Then
      CustomFilter := Filter;
    End;
  End;

 Function TTranslatablesUI.UpdateSelectedItemValue : Boolean;
  Begin
   Result := False;
   If Assigned(SelectedItem) And ValueControl.Modified And (Kind = dkProperty) Then
    Begin
     If SelectedItem.Value <> ValueControl.Text Then
      Begin
       SelectedItem.Value := ValueControl.Text;
       If Kind = dkProperty Then
        ListControl.Selected.SubItems[0] := SelectedItem.Value
       Else
        ListControl.Selected.Caption := SelectedItem.Value;
       If Reevaluate(SelectedItem) Then
        ListControl.Selected.ImageIndex := ImageIndexOf(SelectedItem);
       Result                           := True;
      End;
     ValueControl.Modified := False;
    End;
  End;

 Function TTranslatablesUI.UpdateSelectedItemComment : Boolean;
  Begin
   Result := False;
   If Assigned(SelectedItem) And CommentControl.Modified Then
    Begin
     CommentControl.Text := Trim(CommentControl.Text);
     If SelectedItem.Comment <> CommentControl.Text Then
      Begin
       SelectedItem.Comment            := CommentControl.Text;
       ListControl.Selected.ImageIndex := ImageIndexOf(SelectedItem);
       Result                          := True;
      End;
     CommentControl.Modified := False;
    End;
  End;

{ TTranslatableEditor }

  Class Function TTranslatableEditor.Execute(ATranslatables : TTranslatables) : Boolean;

Begin
 Result := False;
 With Create(Application) Do
  Try
   Translatables := ATranslatables;
   Caption       := Format(SEditorCaption, [Translatables.DomainName]);
   ReadProperties;
   ReadLiterals;
   If ShowModal = mrOk Then
    Begin
     WriteProperties;
     WriteLiterals;
     Result := True;
    End;
  Finally
   Free;
  End;

End;

 Procedure TTranslatableEditor.FormCreate(Sender : TObject);
  Begin
   TextLanguage            := TCultureBox.Create(Self);
   TextLanguage.Parent     := LanguageBoxPlaceHolder.Parent;
   TextLanguage.Flags      := TFlagImageList.Create(Self);
   TextLanguage.BoundsRect := LanguageBoxPlaceHolder.BoundsRect;
   TextLanguage.TabOrder   := LanguageBoxPlaceHolder.TabOrder;
   TextLanguage.OnSelect   := LanguageBoxPlaceHolder.OnSelect;
   TextLanguage.Sorted     := True;
   TextLanguage.CollectAll;
   TextLanguageLabel.FocusControl := TextLanguage;
   LanguageBoxPlaceHolder.Free;
   Properties                  := TTranslatablesUI.Create(dkProperty, PropertyList, PropertyFilter, PropertyValue, PropertyComments);
   Literals                    := TTranslatablesUI.Create(dkLiteral, LiteralList, LiteralFilter, LiteralValue, LiteralComments);
   PropertyValue.Visible       := (PropertiesTabSet.TabIndex = 0);
   PropertyComments.Visible    := (PropertiesTabSet.TabIndex = 1);
   LiteralValue.Visible        := (LiteralsTabSet.TabIndex = 0);
   LiteralComments.Visible     := (LiteralsTabSet.TabIndex = 1);
   PageControl.ActivePageIndex := 0;
  End;

 Procedure TTranslatableEditor.FormDestroy(Sender : TObject);
  Begin
   If Assigned(LiteralCollector) Then
    LiteralCollector.Free;
   Properties.Free;
   Literals.Free;
  End;

 Procedure TTranslatableEditor.FormShow(Sender : TObject);
  Begin
   Properties.ActiveFilter   := FILTER_DEFAULT;
   Literals.ActiveFilter     := FILTER_DEFAULT;
   TextLanguage.ItemSelected := GetApplicationDefaultCulture;
   If Not Assigned(TextLanguage.ItemSelected) Then
    TextLanguage.ItemSelected := GetUserDefaultUICulture;
   btnExportTo.Enabled        := Assigned(TextLanguage.ItemSelected);
  End;

 Procedure TTranslatableEditor.ListViewCustomDraw(Sender : TCustomListView; Const ARect : TRect; Var DefaultDraw : Boolean);
  Var
   TextRect : TRect;
  Begin
   If TListView(Sender).Items.Count = 0 Then
    Begin
     TextRect := ARect;
     InflateRect(TextRect, -40, -50);
     TListView(Sender).Canvas.Font.Color := clGrayText;
     DrawText(TListView(Sender).Canvas.Handle, PChar(SNoItemsToView),
     Length(SNoItemsToView), TextRect, DT_CENTER Or DT_NOPREFIX Or DT_WORDBREAK);
    End;
  End;

 Procedure TTranslatableEditor.ListViewCustomDrawItem(Sender : TCustomListView; Item : TListItem; State : TCustomDrawState; Var DefaultDraw : Boolean);
  Begin
   If Odd(Item.Index) Then
    TListView(Sender).Canvas.Brush.Color := clAlternative;
  End;

 Procedure TTranslatableEditor.FilterDrawItem(Control : TWinControl; Index : Integer; Rect : TRect; State : TOwnerDrawState);
  Var
   Target : TTranslatablesUI;
   Filter : TTranslatablesUI.TFilterType;
   Info   : String;
   c      : Integer;
   s      : Integer;
   r      : TRect;
  Begin
   If Control = PropertyFilter Then
    Target := Properties
   Else
    Target := Literals;
   With TComboBox(Control) Do
    Begin
     Filter := Target.FilterOfIndex(Index);
     If Odd(Index) And (([odComboBoxEdit, odSelected] * State) = []) Then
      Canvas.Brush.Color := clAlternative;
     Canvas.FillRect(Rect);
     InflateRect(Rect, -2, -1);
     ImageList.Draw(Canvas, Rect.Left,
     (Rect.Top + Rect.Bottom - ImageList.Height) Div 2, Ord(Filter) - 1);
     Inc(Rect.Left, ImageList.Width + 2);
     Dec(Rect.Right, 2);
     Info := Items[Index];
     DrawText(Canvas.Handle, PChar(Info), Length(Info), Rect,
     DT_LEFT Or DT_VCENTER Or DT_SINGLELINE Or DT_NOPREFIX);
     If Filter = ftCustom Then
      Begin
       Inc(Rect.Left, Canvas.TextWidth(Info) + 8);
       If Not(odSelected In State) Then
        Canvas.Font.Color := clGrayText;
       Canvas.Font.Style  := [];
       Info               := Target.CustomFilter;
       DrawText(Canvas.Handle, PChar(Info), Length(Info), Rect,
       DT_LEFT Or DT_VCENTER Or DT_SINGLELINE Or DT_NOPREFIX);
       Canvas.Font.Style := [fsBold];
      End;
     If Not(odSelected In State) Then
      Canvas.Font.Color := clHotLight;
     Canvas.Font.Size   := Canvas.Font.Size - 1;
     If odComboBoxEdit In State Then
      Begin
       Info := FormatFloat('#,##0', Target.Stats.Selected[Filter]) + ' / '
       + FormatFloat('#,##0', Target.Stats.Total[Filter]);
       DrawText(Canvas.Handle, PChar(Info), Length(Info), Rect,
       DT_RIGHT Or DT_VCENTER Or DT_SINGLELINE Or DT_NOPREFIX);
      End
     Else
      Begin
       s := Canvas.TextWidth(' ');
       c := Rect.Right - Length(FormatFloat('#,##0', Target.Stats.Total[ftNone])) * s * 3;
       SetRect(r, c - s, Rect.Top, c + s, Rect.Bottom);
       DrawText(Canvas.Handle, '/', 1, r,
       DT_CENTER Or DT_VCENTER Or DT_SINGLELINE Or DT_NOPREFIX);
       SetRect(r, c + s, Rect.Top, Rect.Right, Rect.Bottom);
       Info := FormatFloat('#,##0', Target.Stats.Total[Filter]);
       DrawText(Canvas.Handle, PChar(Info), Length(Info), r,
       DT_LEFT Or DT_VCENTER Or DT_SINGLELINE Or DT_NOPREFIX);
       SetRect(r, Rect.Left, Rect.Top, c - s - s Div 2, Rect.Bottom);
       Info := FormatFloat('#,##0', Target.Stats.Selected[Filter]);
       DrawText(Canvas.Handle, PChar(Info), Length(Info), r,
       DT_RIGHT Or DT_VCENTER Or DT_SINGLELINE Or DT_NOPREFIX);
      End;
    End;
  End;

 Procedure TTranslatableEditor.LanguageBoxSelect(Sender : TObject);
  Begin
   btnExportTo.Enabled := Assigned(TextLanguage.ItemSelected);
  End;

// Properties

 Procedure TTranslatableEditor.ReadProperties;
  Begin
   GetTranslatableProperties(Translatables.DomainOwner, Properties.All);
   Properties.SetSelection(Translatables.Properties);
   Properties.All.Sort;
  End;

 Procedure TTranslatableEditor.WriteProperties;
  Var
   UpdatedProperties : TTextItems;
  Begin
   Properties.GetSelection(Translatables.Properties);
   UpdatedProperties := TTextItems.Create;
   Try
    Properties.GetUpdated(UpdatedProperties);
    SetTranslatableProperties(Translatables.DomainOwner, UpdatedProperties);
   Finally
    UpdatedProperties.Free;
   End;
  End;

 Procedure TTranslatableEditor.PropertyFilterSelect(Sender : TObject);
  Begin
   Properties.ActivateFilterByIndex(PropertyFilter.ItemIndex, SPropertyFilterPrompt);
  End;

 Procedure TTranslatableEditor.PropertyListItemChecked(Sender : TObject; Item : TListItem);
  Begin
   If Not Properties.SetChecked(TTextItem(Item.Data), Item.Checked) Then
    Item.Checked := Properties.GetChecked(TTextItem(Item.Data));
  End;

 Procedure TTranslatableEditor.PropertyListSelectItem(Sender : TObject; Item : TListItem; Selected : Boolean);
  Begin
   If Selected And Assigned(Item) Then
    Properties.SelectedItem := TTextItem(Item.Data)
   Else
    Begin
     Properties.SelectedItem := Nil;
     If Assigned(PropertyList.ItemFocused) Then
      PropertyList.ItemFocused.Focused := False;
    End;
  End;

 Procedure TTranslatableEditor.PropertyValueExit(Sender : TObject);
  Begin
   Properties.UpdateSelectedItemValue;
  End;

 Procedure TTranslatableEditor.PropertyCommentsExit(Sender : TObject);
  Begin
   Properties.UpdateSelectedItemComment;
  End;

 Procedure TTranslatableEditor.PropertiesTabSetChange(Sender : TObject; NewTab : Integer; Var AllowChange : Boolean);
  Begin
   PropertyValue.Visible    := (NewTab = 0);
   PropertyComments.Visible := (NewTab = 1);
  End;

 Procedure TTranslatableEditor.PropsCheckAllExecute(Sender : TObject);
  Begin
   Properties.SetAllState(cbChecked);
  End;

 Procedure TTranslatableEditor.PropsCheckAllUpdate(Sender : TObject);
  Begin
   PropsCheckAll.Enabled := Properties.CanSetAllState(cbChecked);
  End;

 Procedure TTranslatableEditor.PropsUncheckAllExecute(Sender : TObject);
  Begin
   Properties.SetAllState(cbUnchecked);
  End;

 Procedure TTranslatableEditor.PropsUncheckAllUpdate(Sender : TObject);
  Begin
   PropsUncheckAll.Enabled := Properties.CanSetAllState(cbUnchecked);
  End;

 Procedure TTranslatableEditor.PropsInvertCheckExecute(Sender : TObject);
  Begin
   Properties.SetAllState(cbGrayed);
  End;

 Procedure TTranslatableEditor.PropsInvertCheckUpdate(Sender : TObject);
  Begin
   PropsInvertCheck.Enabled := Properties.CanSetAllState(cbGrayed);
  End;

// Literals

 Procedure TTranslatableEditor.ReadLiterals;
  Var
   SourceCode : String;
   ParseError : String;
  Begin
   If ideGetActiveEditorText(SourceCode) Then
    Begin
     Try
      LiteralCollector := TPascalStringCollector.Create(SourceCode, Translatables.Translator);
     Except
      On E : Exception Do
       Begin
        CollectorErrorMsg := Format(SParserError, [ParseError, E.Message]);
        LiteralCollector  := Nil;
       End;
     End;
     If Assigned(LiteralCollector) Then
      Begin
       LiteralCollector.GetTranslatableStrings(Literals.All);
       Literals.SetSelection(Translatables.Literals);
      End;
    End;
  End;

 Procedure TTranslatableEditor.WriteLiterals;
  Var
   SourceCode : String;
  Begin
   If Assigned(LiteralCollector) Then
    Begin
     Literals.GetSelection(Translatables.Literals);
     SourceCode := LiteralCollector.SetTranslatableStrings(Translatables.Literals);
     ideSetActiveEditorText(TrimRight(SourceCode));
    End;
  End;

 Procedure TTranslatableEditor.LiteralFilterSelect(Sender : TObject);
  Begin
   Literals.ActivateFilterByIndex(LiteralFilter.ItemIndex, SLiteralFilterPrompt);
  End;

 Procedure TTranslatableEditor.LiteralListCustomDraw(Sender : TCustomListView; Const ARect : TRect; Var DefaultDraw : Boolean);
  Var
   TextRect : TRect;
   ErrorMsg : String;
  Begin
   If Not Assigned(LiteralCollector) Then
    Begin
     TextRect := ARect;
     InflateRect(TextRect, -40, -50);
     TListView(Sender).Canvas.Font.Color := clRed;
     TListView(Sender).Canvas.Font.Size  := 12;
     ErrorMsg                            := SCollectError;
     If CollectorErrorMsg <> '' Then
      ErrorMsg := ErrorMsg + #13#10 + CollectorErrorMsg;
     DrawText(TListView(Sender).Canvas.Handle, PChar(ErrorMsg), Length(ErrorMsg),
     TextRect, DT_CENTER Or DT_NOPREFIX Or DT_WORDBREAK);
    End
   Else
    ListViewCustomDraw(Sender, ARect, DefaultDraw);
  End;

 Procedure TTranslatableEditor.LiteralListItemChecked(Sender : TObject; Item : TListItem);
  Begin
   If Not Literals.SetChecked(TTextItem(Item.Data), Item.Checked) Then
    Item.Checked := Literals.GetChecked(TTextItem(Item.Data));
  End;

 Procedure TTranslatableEditor.LiteralListSelectItem(Sender : TObject; Item : TListItem; Selected : Boolean);
  Var
   i : Integer;
  Begin
   If Selected And Assigned(Item) Then
    Literals.SelectedItem := TTextItem(Item.Data)
   Else
    Begin
     Literals.SelectedItem := Nil;
     If Assigned(LiteralList.ItemFocused) Then
      LiteralList.ItemFocused.Focused := False;
    End;
   If Assigned(Literals.SelectedItem) And Literals.SelectedItem.HasPluralForms Then
    Begin
     If LiteralPlurals.Tabs.Count <> Literals.SelectedItem.PluralCount Then
      Begin
       LiteralPlurals.Tabs.BeginUpdate;
       LiteralPlurals.Tabs.Clear;
       For i := 0 To Literals.SelectedItem.PluralCount - 1 Do
        LiteralPlurals.Tabs.Add(Format(' plural=%d ', [i]));
       LiteralPlurals.Tabs.EndUpdate;
      End;
     LiteralPlurals.TabIndex := Literals.PluralIndex;
     LiteralValue.Height     := LiteralPlurals.BoundsRect.Top - LiteralValue.Top + 1;
     LiteralPlurals.Visible  := True;
    End
   Else If LiteralPlurals.Visible Then
    Begin
     LiteralValue.Height    := LiteralPlurals.BoundsRect.Bottom - LiteralValue.Top - 1;
     LiteralPlurals.Visible := False;
    End;
  End;

 Procedure TTranslatableEditor.LiteralPluralsChange(Sender : TObject; NewTab : Integer; Var AllowChange : Boolean);
  Begin
   Literals.PluralIndex := NewTab;
  End;

 Procedure TTranslatableEditor.LiteralValueExit(Sender : TObject);
  Begin
   Literals.UpdateSelectedItemValue;
  End;

 Procedure TTranslatableEditor.LiteralCommentsExit(Sender : TObject);
  Begin
   Literals.UpdateSelectedItemComment;
  End;

 Procedure TTranslatableEditor.LiteralsTabSetChange(Sender : TObject; NewTab : Integer; Var AllowChange : Boolean);
  Begin
   LiteralValue.Visible    := (NewTab = 0);
   LiteralComments.Visible := (NewTab = 1);
  End;

 Procedure TTranslatableEditor.LiteralsCheckAllExecute(Sender : TObject);
  Begin
   Literals.SetAllState(cbChecked);
  End;

 Procedure TTranslatableEditor.LiteralsCheckAllUpdate(Sender : TObject);
  Begin
   LiteralsCheckAll.Enabled := Literals.CanSetAllState(cbChecked);
  End;

 Procedure TTranslatableEditor.LiteralsUncheckAllExecute(Sender : TObject);
  Begin
   Literals.SetAllState(cbUnchecked);
  End;

 Procedure TTranslatableEditor.LiteralsUncheckAllUpdate(Sender : TObject);
  Begin
   LiteralsUncheckAll.Enabled := Literals.CanSetAllState(cbUnchecked);
  End;

 Procedure TTranslatableEditor.LiteralsInvertCheckExecute(Sender : TObject);
  Begin
   Literals.SetAllState(cbGrayed);
  End;

 Procedure TTranslatableEditor.LiteralsInvertCheckUpdate(Sender : TObject);
  Begin
   LiteralsInvertCheck.Enabled := Literals.CanSetAllState(cbGrayed);
  End;

// Export

 Procedure TTranslatableEditor.AddTranslatablesTo(Catalog : TTranslationCatalog; KeepObsoleteEntries : Boolean);
  Var
   TextItems  : TTextItems;
   TextDomain : TTextDomain;
  Begin
   TextItems := TTextItems.Create;
   Try
    TextDomain := Catalog.TextDomains.Add(Translatables.DomainName);
    Properties.GetSelection(TextItems);
    TextDomain.Properties.Revise(TextItems, KeepObsoleteEntries);
    Literals.GetSelection(TextItems);
    TextDomain.Literals.Revise(TextItems, KeepObsoleteEntries);
   Finally
    TextItems.Free;
   End;
  End;

 Procedure TTranslatableEditor.ExportTo(Const FileName : String);
  Var
   Catalog       : TTranslationCatalog;
   ReplaceReason : String;
   WarningMsg    : String;
  Begin
   Catalog := TTranslationCatalog.Create;
   Try
    If FileExists(FileName) Then
     Begin
      ReplaceReason := '';
      Try
       Catalog.LoadFromFile(FileName);
       If Not Catalog.Empty And (Catalog.NativeCulture <> TextLanguage.ItemSelected) Then
        ReplaceReason := SLanguageMismatch;
      Except
       ReplaceReason := SContentMismatch;
      End;
      WarningMsg := Format(SFileExists, [FileName]);
      If ReplaceReason <> '' Then
       WarningMsg := WarningMsg + ' ' + ReplaceReason;
      WarningMsg  := WarningMsg + #13#10#13#10;
      If ReplaceReason <> '' Then
       WarningMsg := WarningMsg + SReplaceAction
      Else
       WarningMsg := WarningMsg + SUpdateAction;
      WarningMsg  := WarningMsg + #13#10 + SCancelAction;
      If MessageDlg(WarningMsg, mtWarning, [mbOK, mbCancel], 0) <> mrOk Then
       Exit;
      If ReplaceReason <> '' Then
       Catalog.Clear;
     End;
    Catalog.NativeCulture := TextLanguage.ItemSelected;
    AddTranslatablesTo(Catalog, False);
    Catalog.SaveToFile(FileName);
   Finally
    Catalog.Free;
   End;
  End;

 Procedure TTranslatableEditor.btnExportToClick(Sender : TObject);
  Var
   FileName : String;
  Begin
   If SaveDialog.FileName = '' Then
    Begin
     FileName := TextLanguage.ItemSelected.Locale;
     If Assigned(Translatables.DomainOwner) And
     (Translatables.DomainOwner.UnitName <> '')
     Then
      FileName           := Translatables.DomainOwner.UnitName + '.' + FileName;
     SaveDialog.FileName := FileName;
    End;
   If SaveDialog.Execute Then
    Begin
     ExportTo(SaveDialog.FileName);
     ModalResult := mrOk;
    End;
  End;

End.
