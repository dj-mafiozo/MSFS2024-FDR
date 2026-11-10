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
/// This unit implements some common localizable dialogs.
/// </summary>
/// <remarks>
/// TODO: Font dialog, Color dialog, Find and replace dialog, Print dialog,
/// Page setup dialog, Open dialog, Save dialog.
/// </remarks>
Unit i18nDialogs;

{$I DELPHIAREA.INC}

Interface

 Uses
  Windows, Classes, Graphics, Dialogs, Controls, Forms, StdCtrls, Menus, i18nUnicode;

 Type

  {$Region 'xmldoc'}
  /// <summary>
  /// TCustomDlgBtnCaptions is the ancestor for all objects that provide
  /// localizable captions for common dialog buttons.
  /// </summary>
  {$Endregion}
  TCustomDlgBtnCaptions = Class(TPersistent)
   Private
    fCaptions : Array [TMsgDlgBtn] Of String;
    Function GetCaptions(DlgBtn : TMsgDlgBtn) : String; Inline;
    Procedure SetCaptions(DlgBtn : TMsgDlgBtn; Const Value : String); Inline;
    Function IsStoredCaptions(DlgBtn : TMsgDlgBtn) : Boolean;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the class.
    /// </summary>
    {$Endregion}
    Constructor Create;
    {$Region 'xmldoc'}
    /// <summary>
    /// Copies the contents from a source object.
    /// </summary>
    {$Endregion}
    Procedure Assign(Source : TPersistent); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Calculates dimensions of a set of buttons that are arranged side by side.
    /// </summary>
    /// <param name="DC">
    /// The device context.
    /// </param>
    /// <param name="Buttons">
    /// The set of buttons.
    /// </param>
    /// <param name="Width">
    /// The calculated width of the buttons on the specified device context.
    /// </param>
    /// <param name="Height">
    /// The calculated height of the buttons on the specified device context.
    /// </param>
    /// <returns>
    /// The number of buttons.
    /// </returns>
    {$Endregion}
    Function GetMetrics(DC : HDC; Buttons : TMsgDlgButtons; Var Width, Height : Integer) : Integer;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists captions of the buttons.
    /// </summary>
    {$Endregion}
    Property Captions[DlgBtn : TMsgDlgBtn] : String Read GetCaptions Write SetCaptions; Default;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the caption for "Yes" button.
    /// </summary>
    {$Endregion}
    Property Yes : String Index mbYes Read GetCaptions Write SetCaptions Stored IsStoredCaptions;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the caption for "No" button.
    /// </summary>
    {$Endregion}
    Property No : String Index mbNo Read GetCaptions Write SetCaptions Stored IsStoredCaptions;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the caption for "OK" button.
    /// </summary>
    {$Endregion}
    Property OK : String Index mbOK Read GetCaptions Write SetCaptions Stored IsStoredCaptions;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the caption for "Cancel" button.
    /// </summary>
    {$Endregion}
    Property Cancel : String Index mbCancel Read GetCaptions Write SetCaptions Stored IsStoredCaptions;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the caption for "Abort" button.
    /// </summary>
    {$Endregion}
    Property Abort : String Index mbAbort Read GetCaptions Write SetCaptions Stored IsStoredCaptions;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the caption for "Retry" button.
    /// </summary>
    {$Endregion}
    Property Retry : String Index mbRetry Read GetCaptions Write SetCaptions Stored IsStoredCaptions;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the caption for "Ignore" button.
    /// </summary>
    {$Endregion}
    Property Ignore : String Index mbIgnore Read GetCaptions Write SetCaptions Stored IsStoredCaptions;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the caption for "All" button.
    /// </summary>
    {$Endregion}
    Property All : String Index mbAll Read GetCaptions Write SetCaptions Stored IsStoredCaptions;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the caption for "No to all" button.
    /// </summary>
    {$Endregion}
    Property NoToAll : String Index mbNoToAll Read GetCaptions Write SetCaptions Stored IsStoredCaptions;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the caption for "Yes to all" button.
    /// </summary>
    {$Endregion}
    Property YesToAll : String Index mbYesToAll Read GetCaptions Write SetCaptions Stored IsStoredCaptions;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the caption for "Help" button.
    /// </summary>
    {$Endregion}
    Property Help : String Index mbHelp Read GetCaptions Write SetCaptions Stored IsStoredCaptions;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the caption for "Close" button.
    /// </summary>
    {$Endregion}
    Property Close : String Index mbClose Read GetCaptions Write SetCaptions Stored IsStoredCaptions;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TCustomDlgCheckBox is the ancestor for all objects that represent a check
/// box control as a property.
/// </summary>
/// <remarks>
/// Use TCustomDlgCheckBox as a base class when defining a new object that
/// represents a check box as a published property of another object.
/// </remarks>
{$Endregion}

  TCustomDlgCheckBox = Class(TPersistent)
   Private
    fCaption     : String;
    fHint        : String;
    fAllowGrayed : Boolean;
    fState       : TCheckBoxState;
    fEnabled     : Boolean;
    fVisible     : Boolean;
    fControl     : TCheckBox;
    Procedure SetCaption(Const Value : String);
    Procedure SetHint(Const Value : String);
    Procedure SetAllowGrayed(Value : Boolean);
    Procedure SetState(Value : TCheckBoxState);
    Function GetChecked : Boolean;
    Procedure SetChecked(Value : Boolean);
    Procedure SetEnabled(Value : Boolean);
    Procedure SetVisible(Value : Boolean);
    Procedure SetControl(Value : TCheckBox);
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the check box control that will be managed by the
    /// TCustomDlgCheckBox object.
    /// </summary>
    {$Endregion}
    Property Control : TCheckBox Read fControl Write SetControl;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the check box can be in a grayed state.
    /// </summary>
    {$Endregion}
    Property AllowGrayed : Boolean Read fAllowGrayed Write SetAllowGrayed Default False;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets a text string that identifies the check box control to the user.
    /// </summary>
    {$Endregion}
    Property Caption : String Read fCaption Write SetCaption;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the check box is selected.
    /// </summary>
    {$Endregion}
    Property Checked : Boolean Read GetChecked Write SetChecked Stored False;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the check box control responds to keyboard, mouse, and timer events.
    /// </summary>
    {$Endregion}
    Property Enabled : Boolean Read fEnabled Write SetEnabled Default True;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the text string that can appear when the user moves the mouse over
    /// the check box control.
    /// </summary>
    {$Endregion}
    Property Hint : String Read fHint Write SetHint;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the check box is selected, deselected, or grayed.
    /// </summary>
    {$Endregion}
    Property State : TCheckBoxState Read fState Write SetState Default cbUnchecked;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the check box control appears onscreen.
    /// </summary>
    {$Endregion}
    Property Visible : Boolean Read fVisible Write SetVisible Default False;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the class.
    /// </summary>
    {$Endregion}
    Constructor Create;
    {$Region 'xmldoc'}
    /// <summary>
    /// Copies the settings from another check box.
    /// </summary>
    /// <param name="Source">
    /// The source object.
    /// </param>
    /// <seealso cref="AssignTo"/>
    {$Endregion}
    Procedure Assign(Source : TPersistent); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Copies the settings to another check box.
    /// </summary>
    /// <param name="Dest">
    /// The destination object.
    /// </param>
    /// <seealso cref="Assign"/>
    {$Endregion}
    Procedure AssignTo(Dest : TPersistent); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Calculates dimensions of the check box on a specified device context.
    /// </summary>
    /// <param name="DC">
    /// The device context.
    /// </param>
    /// <param name="MaxWidth">
    /// The maximum width that the check box can occupy on the specified device context.
    /// </param>
    /// <returns>
    /// The width and height of the check box on the specified device context.
    /// </returns>
    {$Endregion}
    Function GetMetrics(DC : HDC; MaxWidth : Integer) : TSize;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TMsgDlgTypeIcons stores the icons that can appear on a message dialog.
/// </summary>
{$Endregion}

  TMsgDlgTypeIcons = Class(TPersistent)
   Private
    fIcons : Array [TMsgDlgType] Of TIcon;
    Function GetIcons(DlgType : TMsgDlgType) : TIcon; Inline;
    Procedure SetIcons(DlgType : TMsgDlgType; Value : TIcon);
    Function IsStoredIcons(DlgType : TMsgDlgType) : Boolean;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the class.
    /// </summary>
    {$Endregion}
    Constructor Create;
    {$Region 'xmldoc'}
    /// <summary>
    /// Destroys the instance and releases its allocated memory.
    /// </summary>
    {$Endregion}
    Destructor Destroy; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Copies the icons from another object.
    /// </summary>
    /// <param name="Source">
    /// The source object.
    /// </param>
    {$Endregion}
    Procedure Assign(Source : TPersistent); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the available icons for a message dialog.
    /// </summary>
    {$Endregion}
    Property Icons[DlgType : TMsgDlgType] : TIcon Read GetIcons Write SetIcons; Default;
   Published
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the icon for a warning message dialog.
    /// </summary>
    {$Endregion}
    Property Warning : TIcon Index mtWarning Read GetIcons Write SetIcons Stored IsStoredIcons;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the icon for an error message dialog.
    /// </summary>
    {$Endregion}
    Property Error : TIcon Index mtError Read GetIcons Write SetIcons Stored IsStoredIcons;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the icon for an informative message dialog.
    /// </summary>
    {$Endregion}
    Property Information : TIcon Index mtInformation Read GetIcons Write SetIcons Stored IsStoredIcons;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the icon for an inquiry message dialog.
    /// </summary>
    {$Endregion}
    Property Confirmation : TIcon Index mtConfirmation Read GetIcons Write SetIcons Stored IsStoredIcons;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the icon for a custom message dialog.
    /// </summary>
    {$Endregion}
    Property Custom : TIcon Index mtCustom Read GetIcons Write SetIcons Stored IsStoredIcons;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TMsgDlgTypeCaptions stores the titles that a message dialog can have.
/// </summary>
{$Endregion}

  TMsgDlgTypeCaptions = Class(TPersistent)
   Private
    fCaptions : Array [TMsgDlgType] Of String;
    Function GetCaptions(DlgType : TMsgDlgType) : String; Inline;
    Procedure SetCaptions(DlgType : TMsgDlgType; Const Value : String); Inline;
    Function IsStoredCaptions(DlgType : TMsgDlgType) : Boolean;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the class.
    /// </summary>
    {$Endregion}
    Constructor Create;
    {$Region 'xmldoc'}
    /// <summary>
    /// Copies the titles from another object.
    /// </summary>
    /// <param name="Source">
    /// The source object.
    /// </param>
    {$Endregion}
    Procedure Assign(Source : TPersistent); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the available titles for a message dialog.
    /// </summary>
    {$Endregion}
    Property Captions[DlgType : TMsgDlgType] : String Read GetCaptions Write SetCaptions; Default;
   Published
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the title for a warning message dialog.
    /// </summary>
    {$Endregion}
    Property Warning : String Index mtWarning Read GetCaptions Write SetCaptions Stored IsStoredCaptions;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the title for an error message dialog.
    /// </summary>
    {$Endregion}
    Property Error : String Index mtError Read GetCaptions Write SetCaptions Stored IsStoredCaptions;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the title for an informative message dialog.
    /// </summary>
    {$Endregion}
    Property Information : String Index mtInformation Read GetCaptions Write SetCaptions Stored IsStoredCaptions;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the title for an inquiry message dialog.
    /// </summary>
    {$Endregion}
    Property Confirmation : String Index mtConfirmation Read GetCaptions Write SetCaptions Stored IsStoredCaptions;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the title for a custom message dialog.
    /// </summary>
    {$Endregion}
    Property Custom : String Index mtCustom Read GetCaptions Write SetCaptions Stored IsStoredCaptions;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TMsgDlgBtnCaptions stores the caption of buttons for a message dialog.
/// </summary>
{$Endregion}

  TMsgDlgBtnCaptions = Class(TCustomDlgBtnCaptions)
   Published
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the caption for "Yes" button.
    /// </summary>
    {$Endregion}
    Property Yes;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the caption for "No" button.
    /// </summary>
    {$Endregion}
    Property No;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the caption for "OK" button.
    /// </summary>
    {$Endregion}
    Property OK;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the caption for "Cancel" button.
    /// </summary>
    {$Endregion}
    Property Cancel;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the caption for "Abort" button.
    /// </summary>
    {$Endregion}
    Property Abort;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the caption for "Retry" button.
    /// </summary>
    {$Endregion}
    Property Retry;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the caption for "Ignore" button.
    /// </summary>
    {$Endregion}
    Property Ignore;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the caption for "All" button.
    /// </summary>
    {$Endregion}
    Property All;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the caption for "No to all" button.
    /// </summary>
    {$Endregion}
    Property NoToAll;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the caption for "Yes to all" button.
    /// </summary>
    {$Endregion}
    Property YesToAll;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the caption for "Help" button.
    /// </summary>
    {$Endregion}
    Property Help;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the caption for "Close" button.
    /// </summary>
    {$Endregion}
    Property Close;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TMsgDlgCheckBox represents a check box that can appear on a message dialog.
/// </summary>
{$Endregion}

  TMsgDlgCheckBox = Class(TCustomDlgCheckBox)
   Published
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the check box can be in a grayed state.
    /// </summary>
    {$Endregion}
    Property AllowGrayed;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets a text string that identifies the check box control to the user.
    /// </summary>
    {$Endregion}
    Property Caption;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the check box is selected.
    /// </summary>
    {$Endregion}
    Property Checked;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the check box control responds to keyboard, mouse, and timer events.
    /// </summary>
    {$Endregion}
    Property Enabled;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the text string that can appear when the user moves the mouse over
    /// the check box control.
    /// </summary>
    {$Endregion}
    Property Hint;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the check box is selected, deselected, or grayed.
    /// </summary>
    {$Endregion}
    Property State;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the check box control appears onscreen.
    /// </summary>
    {$Endregion}
    Property Visible;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TMessageDialog displays a localizable message dialog.
/// </summary>
/// <remarks>
/// <para>
/// Use TMessageDialog to display a modal Windows dialog box for displaying a message,
/// and getting the user response. The dialog does not appear at runtime until it is
/// activated by a call to one of its show methods.
/// </para>
/// <para>
/// TMessageDialog has properties and methods to facilitate customization of the dialog
/// and displaying messages.
/// </para>
/// </remarks>
/// <group name="Components"/>
{$Endregion}
{$IFDEF COMPILER_XE2_UP}

  [ComponentPlatformsAttribute(pidWin32 Or pidWin64)]
  {$ENDIF}
  TMessageDialog = Class(TComponent)
   Private
    fAutoHotKeys     : Boolean;
    fIcons           : TMsgDlgTypeIcons;
    fCaptions        : TMsgDlgTypeCaptions;
    fButtonCaptions  : TMsgDlgBtnCaptions;
    fDialog          : TForm;
    fFont            : TFont;
    fBiDiMode        : TBiDiMode;
    fParentFont      : Boolean;
    fParentBiDiMode  : Boolean;
    fCallbackTimer   : Boolean;
    fCheckBox        : TMsgDlgCheckBox;
    fShowTicks       : Cardinal;
    fOnShow          : TNotifyEvent;
    fOnClose         : TNotifyEvent;
    fOnCallbackTimer : TNotifyEvent;
    Procedure SetCaptions(Value : TMsgDlgTypeCaptions);
    Procedure SetIcons(Value : TMsgDlgTypeIcons);
    Procedure SetButtonCaptions(Value : TMsgDlgBtnCaptions);
    Procedure SetFont(Value : TFont);
    Function GetBiDiMode : TBiDiMode;
    Procedure SetBiDiMode(Value : TBiDiMode);
    Procedure SetParentFont(Value : Boolean);
    Procedure SetParentBiDiMode(Value : Boolean);
    Procedure SetCheckBox(Value : TMsgDlgCheckBox);
    Function GetShowDuration : Cardinal;
    Function IsStoredFont : Boolean;
    Function IsStoredBiDiMode : Boolean;
    Procedure FontChange(Sender : TObject);
    Procedure DialogShow(Sender : TObject);
    Procedure DialogClose(Sender : TObject; Var Action : TCloseAction);
    Procedure DialogKeyDown(Sender : TObject; Var Key : Word; Shift : TShiftState);
    Procedure HelpButtonClick(Sender : TObject);
    Procedure CheckBoxClicked(Sender : TObject);
    Procedure CallbackTimerTrigger(Sender : TObject);
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnShow"/> event.
    /// </summary>
    {$Endregion}
    Procedure DoShow; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnClose"/> event.
    /// </summary>
    {$Endregion}
    Procedure DoClose; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnCallbackTimer"/> event.
    /// </summary>
    {$Endregion}
    Procedure DoCallbackTimer; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the content of the visible dialog as a string. GetDialogText is
    /// called when the user presses Ctrl+C keys to put the dialog's text in the
    /// Windows clipboard.
    /// </summary>
    /// <returns>
    /// Returns a string that represents the title, message, and buttons of the dialog.
    /// </returns>
    {$Endregion}
    Function GetDialogText : String; Virtual;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the component.
    /// </summary>
    /// <param name="AOwner">
    /// The component that owns this component.
    /// </param>
    {$Endregion}
    Constructor Create(AOwner : TComponent); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Destroys the component and releases its allocated memory.
    /// </summary>
    {$Endregion}
    Destructor Destroy; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Brings up a message dialog and obtains the user's response.
    /// </summary>
    /// <param name="Msg">
    /// The content of the message that appears on the dialog.
    /// </param>
    /// <param name="DlgType">
    /// Determines the purpose of the message.
    /// </param>
    /// <param name="Buttons">
    /// Specifies what buttons should appear on the dialog.
    /// </param>
    /// <param name="DefaultButton">
    /// Specifies which button from among those specified buttons is the default button
    /// for the dialog.
    /// </param>
    /// <param name="HelpContext">
    /// Specifies the context identifier for the help topic that should appear when
    /// the user clicks the help button or presses F1 while the dialog is displayed.
    /// </param>
    /// <returns>
    /// Returns the value of the button the user selected.
    /// </returns>
    /// <seealso cref="ShowMessage"/>
    /// <seealso cref="ShowWarning"/>
    /// <seealso cref="Inform"/>
    /// <seealso cref="Confirm"/>
    /// <seealso cref="YesNoCancel"/>
    /// <seealso cref="YesNoAllCancel"/>
    /// <seealso cref="RetryIgnoreAbort"/>
    {$Endregion}
    Function Show(Const Msg : String; DlgType : TMsgDlgType; Buttons : TMsgDlgButtons; DefaultButton : TMsgDlgBtn; HelpContext : THelpContext = 0) : Integer; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Brings up a message dialog and obtains the user's response.
    /// </summary>
    /// <param name="Fmt">
    /// The format string that assembles the content of the message that appears
    /// on the dialog.
    /// </param>
    /// <param name="Args">
    /// The array of arguments to apply to the format specifiers in <paramref name="Fmt"/>.
    /// </param>
    /// <param name="DlgType">
    /// Determines the purpose of the message.
    /// </param>
    /// <param name="Buttons">
    /// Specifies what buttons should appear on the dialog.
    /// </param>
    /// <param name="DefaultButton">
    /// Specifies which button from among those specified buttons is the default button
    /// for the dialog.
    /// </param>
    /// <param name="HelpContext">
    /// Specifies the context identifier for the help topic that should appear when
    /// the user clicks the help button or presses F1 while the dialog is displayed.
    /// </param>
    /// <returns>
    /// Returns the value of the button the user selected.
    /// </returns>
    /// <seealso cref="ShowMessage"/>
    /// <seealso cref="ShowWarning"/>
    /// <seealso cref="Inform"/>
    /// <seealso cref="Confirm"/>
    /// <seealso cref="YesNoCancel"/>
    /// <seealso cref="YesNoAllCancel"/>
    /// <seealso cref="RetryIgnoreAbort"/>
    {$Endregion}
    Function Show(Const Fmt : String; Const Args : Array Of Const; DlgType : TMsgDlgType; Buttons : TMsgDlgButtons; DefaultButton : TMsgDlgBtn; HelpContext : THelpContext = 0) : Integer; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Brings up a message dialog and obtains the user's response.
    /// </summary>
    /// <param name="Msg">
    /// The content of the message that appears on the dialog.
    /// </param>
    /// <param name="DlgType">
    /// Determines the purpose of the message.
    /// </param>
    /// <param name="Buttons">
    /// Specifies what buttons should appear on the dialog.
    /// </param>
    /// <param name="HelpContext">
    /// Specifies the context identifier for the help topic that should appear when
    /// the user clicks the help button or presses F1 while the dialog is displayed.
    /// </param>
    /// <returns>
    /// Returns the value of the button the user selected.
    /// </returns>
    /// <seealso cref="ShowMessage"/>
    /// <seealso cref="ShowWarning"/>
    /// <seealso cref="Inform"/>
    /// <seealso cref="Confirm"/>
    /// <seealso cref="YesNoCancel"/>
    /// <seealso cref="YesNoAllCancel"/>
    /// <seealso cref="RetryIgnoreAbort"/>
    {$Endregion}
    Function Show(Const Msg : String; DlgType : TMsgDlgType; Buttons : TMsgDlgButtons; HelpContext : THelpContext = 0) : Integer; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Brings up a message dialog and obtains the user's response.
    /// </summary>
    /// <param name="Fmt">
    /// The format string that assembles the content of the message that appears
    /// on the dialog.
    /// </param>
    /// <param name="Args">
    /// The array of arguments to apply to the format specifiers in <paramref name="Fmt"/>.
    /// </param>
    /// <param name="DlgType">
    /// Determines the purpose of the message.
    /// </param>
    /// <param name="Buttons">
    /// Specifies what buttons should appear on the dialog.
    /// </param>
    /// <param name="HelpContext">
    /// Specifies the context identifier for the help topic that should appear when
    /// the user clicks the help button or presses F1 while the dialog is displayed.
    /// </param>
    /// <returns>
    /// Returns the value of the button the user selected.
    /// </returns>
    /// <seealso cref="ShowMessage"/>
    /// <seealso cref="ShowWarning"/>
    /// <seealso cref="Inform"/>
    /// <seealso cref="Confirm"/>
    /// <seealso cref="YesNoCancel"/>
    /// <seealso cref="YesNoAllCancel"/>
    /// <seealso cref="RetryIgnoreAbort"/>
    {$Endregion}
    Function Show(Const Fmt : String; Const Args : Array Of Const; DlgType : TMsgDlgType; Buttons : TMsgDlgButtons; HelpContext : THelpContext = 0) : Integer; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Displays a message dialog with custom title and icon.
    /// </summary>
    /// <param name="Msg">
    /// The content of the message that appears on the dialog.
    /// </param>
    /// <param name="HelpContext">
    /// Specifies the context identifier for the help topic that should appear when
    /// the user clicks the help button or presses F1 while the dialog is displayed.
    /// </param>
    /// <seealso cref="Show"/>
    /// <seealso cref="ShowWarning"/>
    /// <seealso cref="Inform"/>
    /// <seealso cref="Confirm"/>
    /// <seealso cref="YesNoCancel"/>
    /// <seealso cref="YesNoAllCancel"/>
    /// <seealso cref="RetryIgnoreAbort"/>
    {$Endregion}
    Procedure ShowMessage(Const Msg : String; HelpContext : THelpContext = 0);
    {$Region 'xmldoc'}
    /// <summary>
    /// Displays a warning message dialog.
    /// </summary>
    /// <param name="Msg">
    /// The content of the message that appears on the dialog.
    /// </param>
    /// <param name="HelpContext">
    /// Specifies the context identifier for the help topic that should appear when
    /// the user clicks the help button or presses F1 while the dialog is displayed.
    /// </param>
    /// <seealso cref="Show"/>
    /// <seealso cref="ShowMessage"/>
    /// <seealso cref="Inform"/>
    /// <seealso cref="Confirm"/>
    /// <seealso cref="YesNoCancel"/>
    /// <seealso cref="YesNoAllCancel"/>
    /// <seealso cref="RetryIgnoreAbort"/>
    {$Endregion}
    Procedure ShowWarning(Const Msg : String; HelpContext : THelpContext = 0);
    {$Region 'xmldoc'}
    /// <summary>
    /// Displays an error message dialog.
    /// </summary>
    /// <param name="Msg">
    /// The content of the message that appears on the dialog.
    /// </param>
    /// <param name="HelpContext">
    /// Specifies the context identifier for the help topic that should appear when
    /// the user clicks the help button or presses F1 while the dialog is displayed.
    /// </param>
    /// <seealso cref="Show"/>
    /// <seealso cref="ShowMessage"/>
    /// <seealso cref="ShowWarning"/>
    /// <seealso cref="Confirm"/>
    /// <seealso cref="YesNoCancel"/>
    /// <seealso cref="YesNoAllCancel"/>
    /// <seealso cref="RetryIgnoreAbort"/>
    {$Endregion}
    Procedure ShowError(Const Msg : String; HelpContext : THelpContext = 0);
    {$Region 'xmldoc'}
    /// <summary>
    /// Displays an informative message dialog.
    /// </summary>
    /// <param name="Msg">
    /// The content of the message that appears on the dialog.
    /// </param>
    /// <param name="HelpContext">
    /// Specifies the context identifier for the help topic that should appear when
    /// the user clicks the help button or presses F1 while the dialog is displayed.
    /// </param>
    /// <seealso cref="Show"/>
    /// <seealso cref="ShowMessage"/>
    /// <seealso cref="ShowWarning"/>
    /// <seealso cref="Confirm"/>
    /// <seealso cref="YesNoCancel"/>
    /// <seealso cref="YesNoAllCancel"/>
    /// <seealso cref="RetryIgnoreAbort"/>
    {$Endregion}
    Procedure Inform(Const Msg : String; HelpContext : THelpContext = 0);
    {$Region 'xmldoc'}
    /// <summary>
    /// Displays an inquiry message dialog with "Yes" and "No" buttons.
    /// </summary>
    /// <param name="Msg">
    /// The content of the message that appears on the dialog.
    /// </param>
    /// <param name="DefaultButton">
    /// Specifies which button is the default button for the dialog.
    /// </param>
    /// <param name="HelpContext">
    /// Specifies the context identifier for the help topic that should appear when
    /// the user clicks the help button or presses F1 while the dialog is displayed.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the user selects "Yes" button, otherwise
    /// returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="Show"/>
    /// <seealso cref="ShowMessage"/>
    /// <seealso cref="ShowWarning"/>
    /// <seealso cref="Inform"/>
    /// <seealso cref="YesNoCancel"/>
    /// <seealso cref="YesNoAllCancel"/>
    /// <seealso cref="RetryIgnoreAbort"/>
    {$Endregion}
    Function Confirm(Const Msg : String; DefaultButton : TMsgDlgBtn = mbYes; HelpContext : THelpContext = 0) : Boolean;
    {$Region 'xmldoc'}
    /// <summary>
    /// Displays an inquiry message dialog with "Yes" and "No", and "Cancel" buttons.
    /// </summary>
    /// <param name="Msg">
    /// The content of the message that appears on the dialog.
    /// </param>
    /// <param name="DefaultButton">
    /// Specifies which button is the default button for the dialog.
    /// </param>
    /// <param name="HelpContext">
    /// Specifies the context identifier for the help topic that should appear when
    /// the user clicks the help button or presses F1 while the dialog is displayed.
    /// </param>
    /// <returns>
    /// Returns the value of the button the user selected.
    /// </returns>
    /// <seealso cref="Show"/>
    /// <seealso cref="ShowMessage"/>
    /// <seealso cref="ShowWarning"/>
    /// <seealso cref="Inform"/>
    /// <seealso cref="Confirm"/>
    /// <seealso cref="YesNoAllCancel"/>
    /// <seealso cref="RetryIgnoreAbort"/>
    {$Endregion}
    Function YesNoCancel(Const Msg : String; DefaultButton : TMsgDlgBtn = mbYes; HelpContext : THelpContext = 0) : Integer;
    {$Region 'xmldoc'}
    /// <summary>
    /// Displays an inquiry message dialog with "Yes" and "No", "Yes to all", "No to all",
    /// and "Cancel" buttons.
    /// </summary>
    /// <param name="Msg">
    /// The content of the message that appears on the dialog.
    /// </param>
    /// <param name="DefaultButton">
    /// Specifies which button is the default button for the dialog.
    /// </param>
    /// <param name="HelpContext">
    /// Specifies the context identifier for the help topic that should appear when
    /// the user clicks the help button or presses F1 while the dialog is displayed.
    /// </param>
    /// <returns>
    /// Returns the value of the button the user selected.
    /// </returns>
    /// <seealso cref="Show"/>
    /// <seealso cref="ShowMessage"/>
    /// <seealso cref="ShowWarning"/>
    /// <seealso cref="Inform"/>
    /// <seealso cref="Confirm"/>
    /// <seealso cref="YesNoCancel"/>
    /// <seealso cref="RetryIgnoreAbort"/>
    {$Endregion}
    Function YesNoAllCancel(Const Msg : String; DefaultButton : TMsgDlgBtn = mbNo; HelpContext : THelpContext = 0) : Integer;
    {$Region 'xmldoc'}
    /// <summary>
    /// Displays a warning message dialog with "Retry" and "Ignore", and "Abort"
    /// buttons.
    /// </summary>
    /// <param name="Msg">
    /// The content of the message that appears on the dialog.
    /// </param>
    /// <param name="DefaultButton">
    /// Specifies which button is the default button for the dialog.
    /// </param>
    /// <param name="HelpContext">
    /// Specifies the context identifier for the help topic that should appear when
    /// the user clicks the help button or presses F1 while the dialog is displayed.
    /// </param>
    /// <returns>
    /// Returns the value of the button the user selected.
    /// </returns>
    /// <seealso cref="Show"/>
    /// <seealso cref="ShowMessage"/>
    /// <seealso cref="ShowWarning"/>
    /// <seealso cref="Inform"/>
    /// <seealso cref="Confirm"/>
    /// <seealso cref="YesNoCancel"/>
    /// <seealso cref="YesNoAllCancel"/>
    {$Endregion}
    Function RetryIgnoreAbort(Const Msg : String; DefaultButton : TMsgDlgBtn = mbRetry; HelpContext : THelpContext = 0) : Integer;
    {$Region 'xmldoc'}
    /// <summary>
    /// Provides direct access to the underlying form object while the dialog is
    /// displayed.
    /// </summary>
    {$Endregion}
    Property Dialog : TForm Read fDialog;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the number of milliseconds that the dialog is displayed.
    /// </summary>
    {$Endregion}
    Property ShowDuration : Cardinal Read GetShowDuration;
   Published
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the hot key of the dialog's buttons should be determined
    /// automatically.
    /// </summary>
    {$Endregion}
    Property AutoHotKeys : Boolean Read fAutoHotKeys Write fAutoHotKeys Default True;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the bidirectional mode for the dialog.
    /// </summary>
    {$Endregion}
    Property BiDiMode : TBiDiMode Read GetBiDiMode Write SetBiDiMode Stored IsStoredBiDiMode;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the captions of the dialog buttons.
    /// </summary>
    {$Endregion}
    Property ButtonCaptions : TMsgDlgBtnCaptions Read fButtonCaptions Write SetButtonCaptions;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the component should generate the periodic <see cref="OnCallbackTimer"/>
    /// event while a dialog is displayed.
    /// </summary>
    /// <remarks>
    /// <para>
    /// If CallbackTimer is <see langword="true"/> and a message dialog is displayed, the
    /// component will generate an <see cref="OnCallbackTimer"/> event on each second.
    /// </para>
    /// <para>
    /// You can use this event to take a default action if the user did not respond to the
    /// dialog in a reasonable amount of time.
    /// </para>
    /// </remarks>
    /// <seealso cref="ShowDuration"/>
    {$Endregion}
    Property CallbackTimer : Boolean Read fCallbackTimer Write fCallbackTimer Default False;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the titles of the dialog for all different types of messages.
    /// </summary>
    {$Endregion}
    Property Captions : TMsgDlgTypeCaptions Read fCaptions Write SetCaptions;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets properties of the check box that can appear on the dialog.
    /// </summary>
    {$Endregion}
    Property CheckBox : TMsgDlgCheckBox Read fCheckBox Write SetCheckBox;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the attributes of text written on the dialog.
    /// </summary>
    {$Endregion}
    Property Font : TFont Read fFont Write SetFont Stored IsStoredFont;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the icons of the dialog for all different types of messages.
    /// </summary>
    {$Endregion}
    Property Icons : TMsgDlgTypeIcons Read fIcons Write SetIcons;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the component uses its parent's <see cref="BiDiMode"/>.
    /// </summary>
    {$Endregion}
    Property ParentBiDiMode : Boolean Read fParentBiDiMode Write SetParentBiDiMode Default True;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the component uses its parent's <see cref="Font"/>.
    /// </summary>
    {$Endregion}
    Property ParentFont : Boolean Read fParentFont Write SetParentFont Default True;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the message dialog is shown.
    /// </summary>
    {$Endregion}
    Property OnShow : TNotifyEvent Read fOnShow Write fOnShow;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the message dialog closes.
    /// </summary>
    {$Endregion}
    Property OnClose : TNotifyEvent Read fOnClose Write fOnClose;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs every second while the dialog is displayed and the value of
    /// <see cref="CallbackTimer"/> property is <see langword="true"/>.</summary>
    {$Endregion}
    Property OnCallbackTimer : TNotifyEvent Read fOnCallbackTimer Write fOnCallbackTimer;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TInputQueryDlgBtnCaptions stores the caption of buttons for an input query
/// dialog.
/// </summary>
{$Endregion}

  TInputQueryDlgBtnCaptions = Class(TCustomDlgBtnCaptions)
   Published
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the caption for "OK" button.
    /// </summary>
    {$Endregion}
    Property OK;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the caption for "Cancel" button.
    /// </summary>
    {$Endregion}
    Property Cancel;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the caption for "Help" button.
    /// </summary>
    {$Endregion}
    Property Help;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TInputQueryDlgValidateEvent is the type for event handlers that respond when
/// an input string needs to be validated.
/// </summary>
/// <param name="Sender">
/// The object that generated the event.
/// </param>
/// <param name="Value">
/// The string value to validate or modify.
/// </param>
/// <returns>
/// Returns <see langword="true"/> if the string value is valid, otherwise returns
/// <see langword="false"/>.
/// </returns>
{$Endregion}

  TInputQueryDlgValidateEvent = Function(Sender : TObject; Var Value : String) : Boolean Of Object;

{$Region 'xmldoc'}
/// <summary>
/// TInputQueryDialog displays a localizable input dialog box that lets the user
/// enter a string, double, or integer.
/// </summary>
/// <remarks>
/// <para>
/// Use TInputQueryDialog to display a modal Windows dialog box for requesting a string,
/// double, or integer from the user. The dialog does not appear at runtime until it
/// is activated by calling the <see cref="Execute"/> method.
/// </para>
/// <para>
/// TInputQueryDialog has properties and methods to facilitate customization of the dialog
/// and prompting for the user's input.
/// </para>
/// </remarks>
/// <group name="Components"/>
{$Endregion}
{$IFDEF COMPILER_XE2_UP}

  [ComponentPlatformsAttribute(pidWin32 Or pidWin64)]
  {$ENDIF}
  TInputQueryDialog = Class(TComponent)
   Protected
    Type
    {$Region 'xmldoc'}
    /// <summary>
    /// This enumeration type identifies the types of inputs for an input query dialog.
    /// </summary>
    {$Endregion}
    TInputType = (
    {$Region 'xmldoc'}
    /// Multiple lines of text.
    {$Endregion}
    itMultiLineText,
    {$Region 'xmldoc'}
    /// A single line of text.
    {$Endregion}
    itSingleLineText,
    {$Region 'xmldoc'}
    /// An integer number.
    {$Endregion}
    itInteger,
    {$Region 'xmldoc'}
    /// A floating point number.
    {$Endregion}
    itFloat
    );
   Private
    fButtonCaptions : TInputQueryDlgBtnCaptions;
    fDialog         : TForm;
    fFont           : TFont;
    fBiDiMode       : TBiDiMode;
    fParentFont     : Boolean;
    fParentBiDiMode : Boolean;
    fReadOnly       : Boolean;
    fInputType      : TInputType;
    fEditBox        : TCustomEdit;
    fOnShow         : TNotifyEvent;
    fOnClose        : TNotifyEvent;
    fOnValidate     : TInputQueryDlgValidateEvent;
    Procedure SetButtonCaptions(Value : TInputQueryDlgBtnCaptions);
    Procedure SetFont(Value : TFont);
    Function GetBiDiMode : TBiDiMode;
    Procedure SetBiDiMode(Value : TBiDiMode);
    Procedure SetParentFont(Value : Boolean);
    Procedure SetParentBiDiMode(Value : Boolean);
    Function IsStoredFont : Boolean;
    Function IsStoredBiDiMode : Boolean;
    Procedure FontChange(Sender : TObject);
    Procedure DialogShow(Sender : TObject);
    Procedure DialogClose(Sender : TObject; Var Action : TCloseAction);
    Procedure DialogCloseQuery(Sender : TObject; Var CanClose : Boolean);
    Procedure HelpButtonClick(Sender : TObject);
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnShow"/> event.
    /// </summary>
    {$Endregion}
    Procedure DoShow; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnClose"/> event.
    /// </summary>
    {$Endregion}
    Procedure DoClose; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnValidate"/> event.
    /// </summary>
    /// <param name="Value">
    /// The value to validate.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the value is valid, otherwise returns
    /// <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function DoValidate(Var Value : String) : Boolean;
    {$Region 'xmldoc'}
    /// <summary>
    /// Brings up an input dialog box ready for the user to enter a string,
    /// double, or integer in its edit box.
    /// </summary>
    /// <param name="ACaption">
    /// The title of the dialog.
    /// </param>
    /// <param name="APrompt">
    /// The text that prompts the user to enter input in the edit box.
    /// </param>
    /// <param name="Value">
    /// The value that appears in the edit box when the dialog box first appears
    /// and which returns the value that the user enters.
    /// </param>
    /// <param name="AInputType">
    /// Specifies the type of input that the user can enter.
    /// </param>
    /// <param name="HelpContext">
    /// Specifies the context identifier for the help topic that should appear when
    /// the user clicks the help button or presses F1 while the dialog is displayed.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the user chooses OK, and <see langword="false"/>
    /// if the user chooses Cancel or presses the Esc key.
    /// </returns>
    {$Endregion}
    Function Prompt(Const ACaption, APrompt : String; Var Value : String; AInputType : TInputType; HelpContext : THelpContext = 0) : Boolean;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the component.
    /// </summary>
    /// <param name="AOwner">
    /// The component that owns this component.
    /// </param>
    {$Endregion}
    Constructor Create(AOwner : TComponent); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Destroys the component and releases its allocated memory.
    /// </summary>
    {$Endregion}
    Destructor Destroy; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Brings up an input dialog box ready for the user to enter a string in its
    /// edit box.
    /// </summary>
    /// <param name="ACaption">
    /// The title of the dialog.
    /// </param>
    /// <param name="APrompt">
    /// The text that prompts the user to enter input in the edit box.
    /// </param>
    /// <param name="Value">
    /// The value that appears in the edit box when the dialog box first appears
    /// and which returns the value that the user enters.
    /// </param>
    /// <param name="Multiline">
    /// Indicates whether the input is a single line string or has multiple lines
    /// of text.
    /// </param>
    /// <param name="HelpContext">
    /// Specifies the context identifier for the help topic that should appear when
    /// the user clicks the help button or presses F1 while the dialog is displayed.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the user chooses OK, and <see langword="false"/>
    /// if the user chooses Cancel or presses the Esc key.
    /// </returns>
    {$Endregion}
    Function Execute(Const ACaption, APrompt : String; Var Value : String; Multiline : Boolean = False; HelpContext : THelpContext = 0) : Boolean; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Brings up an input dialog box ready for the user to enter an integer number
    /// in its edit box.
    /// </summary>
    /// <param name="ACaption">
    /// The title of the dialog.
    /// </param>
    /// <param name="APrompt">
    /// The text that prompts the user to enter input in the edit box.
    /// </param>
    /// <param name="Value">
    /// The value that appears in the edit box when the dialog box first appears
    /// and which returns the value that the user enters.
    /// </param>
    /// <param name="HelpContext">
    /// Specifies the context identifier for the help topic that should appear when
    /// the user clicks the help button or presses F1 while the dialog is displayed.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the user chooses OK, and <see langword="false"/>
    /// if the user chooses Cancel or presses the Esc key.
    /// </returns>
    {$Endregion}
    Function Execute(Const ACaption, APrompt : String; Var Value : Integer; HelpContext : THelpContext = 0) : Boolean; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Brings up an input dialog box ready for the user to enter a floating point
    /// number in its edit box.
    /// </summary>
    /// <param name="ACaption">
    /// The title of the dialog.
    /// </param>
    /// <param name="APrompt">
    /// The text that prompts the user to enter input in the edit box.
    /// </param>
    /// <param name="Value">
    /// The value that appears in the edit box when the dialog box first appears
    /// and which returns the value that the user enters.
    /// </param>
    /// <param name="HelpContext">
    /// Specifies the context identifier for the help topic that should appear when
    /// the user clicks the help button or presses F1 while the dialog is displayed.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the user chooses OK, and <see langword="false"/>
    /// if the user chooses Cancel or presses the Esc key.
    /// </returns>
    {$Endregion}
    Function Execute(Const ACaption, APrompt : String; Var Value : Double; HelpContext : THelpContext = 0) : Boolean; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Provides direct access to the underlying form object while the dialog is
    /// displayed.
    /// </summary>
    {$Endregion}
    Property Dialog : TForm Read fDialog;
    {$Region 'xmldoc'}
    /// <summary>
    /// Provides direct access to the underlying edit control while the dialog is
    /// displayed.
    /// </summary>
    {$Endregion}
    Property EditBox : TCustomEdit Read fEditBox;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the current input mode of the dialog onscreen.
    /// </summary>
    {$Endregion}
    Property InputType : TInputType Read fInputType;
   Published
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the bidirectional mode for the dialog.
    /// </summary>
    {$Endregion}
    Property BiDiMode : TBiDiMode Read GetBiDiMode Write SetBiDiMode Stored IsStoredBiDiMode;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the captions of the dialog buttons.
    /// </summary>
    {$Endregion}
    Property ButtonCaptions : TInputQueryDlgBtnCaptions Read fButtonCaptions Write SetButtonCaptions;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the attributes of text written on the dialog.
    /// </summary>
    {$Endregion}
    Property Font : TFont Read fFont Write SetFont Stored IsStoredFont;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the user can enter a value.
    /// </summary>
    {$Endregion}
    Property ReadOnly : Boolean Read fReadOnly Write fReadOnly Default False;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the component uses its parent's <see cref="BiDiMode"/>.
    /// </summary>
    {$Endregion}
    Property ParentBiDiMode : Boolean Read fParentBiDiMode Write SetParentBiDiMode Default True;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the component uses its parent's <see cref="Font"/>.
    /// </summary>
    {$Endregion}
    Property ParentFont : Boolean Read fParentFont Write SetParentFont Default True;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the dialog is shown.
    /// </summary>
    {$Endregion}
    Property OnShow : TNotifyEvent Read fOnShow Write fOnShow;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the dialog closes.
    /// </summary>
    {$Endregion}
    Property OnClose : TNotifyEvent Read fOnClose Write fOnClose;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the dialog is about to close to validate the input value.
    /// </summary>
    {$Endregion}
    Property OnValidate : TInputQueryDlgValidateEvent Read fOnValidate Write fOnValidate;
  End;

Implementation

 Uses
  {$IFDEF COMPILER_XE3_UP}
  UITypes,
  {$ENDIF}
  Types, SysUtils, Character, Clipbrd, ExtCtrls, i18nCtrls;

 Resourcestring
  SMsgDlgWarning = 'Warning';
  SMsgDlgError = 'Error';
  SMsgDlgInformation = 'Information';
  SMsgDlgConfirm = 'Confirm';

 Resourcestring
  SMsgDlgYes = 'Yes';
  SMsgDlgNo = 'No';
  SMsgDlgOK = 'OK';
  SMsgDlgCancel = 'Cancel';
  SMsgDlgHelp = 'Help';
  SMsgDlgAbort = 'Abort';
  SMsgDlgRetry = 'Retry';
  SMsgDlgIgnore = 'Ignore';
  SMsgDlgAll = 'All';
  SMsgDlgNoToAll = 'No to All';
  SMsgDlgYesToAll = 'Yes to All';
  SMsgDlgClose = 'Close';

 Const
  DialogCaptions : Array [TMsgDlgType] Of Pointer =
  (@SMsgDlgWarning, @SMsgDlgError, @SMsgDlgInformation, @SMsgDlgConfirm, Nil);
  IconIDs : Array [TMsgDlgType] Of PChar =
  (IDI_EXCLAMATION, IDI_HAND, IDI_ASTERISK, IDI_QUESTION, Nil);
  ButtonCaptions_ : Array [TMsgDlgBtn] Of Pointer =
  (@SMsgDlgYes, @SMsgDlgNo, @SMsgDlgOK, @SMsgDlgCancel, @SMsgDlgAbort,
  @SMsgDlgRetry, @SMsgDlgIgnore, @SMsgDlgAll, @SMsgDlgNoToAll,
  @SMsgDlgYesToAll, @SMsgDlgHelp {$IFDEF UNICODE}, @SMsgDlgClose {$ENDIF});
  ButtonNames : Array [TMsgDlgBtn] Of String =
  ('Yes', 'No', 'OK', 'Cancel', 'Abort', 'Retry', 'Ignore', 'All', 'NoToAll',
  'YesToAll', 'Help' {$IFDEF UNICODE}, 'Close' {$ENDIF});
  ModalResults : Array [TMsgDlgBtn] Of Integer =
  (mrYes, mrNo, mrOk, mrCancel, mrAbort, mrRetry, mrIgnore, mrAll, mrNoToAll,
  mrYesToAll, 0 {$IFDEF UNICODE}, mrClose {$ENDIF});

{ Helper Functions }

 Type
  TButtonHotKeys = Array[TMsgDlgBtn] Of Char;

 Function RemovePrefix(Const Str : String) : String;
  Var
   i : Integer;
  Begin
   Result := Str;
   i      := Length(Result);
   While i > 0 Do
    Begin
     If Result[i] = '&' Then
      Begin
       If (i = 1) Or (Result[i - 1] <> '&') Then
        Delete(Result, i, 1)
       Else
        Dec(i);
      End;
     Dec(i);
    End;
  End;

 Function GetAutoHotKey(Const Caption : String; Button : TMsgDlgBtn; Var LastHotKeys : TButtonHotKeys) : String;
  Var
   b      : TMsgDlgBtn;
   HotKey : Char;
   i      : Integer;
  Begin
   Result := RemovePrefix(Caption);
   If Not(Button In [mbOK, mbCancel]) Then
    Begin
     For i := 1 To Length(Result) Do
      Begin
       If Not CharIsLetterOrDigit(Result[i]) Then
        Continue;
       HotKey := CharToUpper(Result[i]);
       For b  := Low(TMsgDlgBtn) To Pred(Button) Do
        If HotKey = LastHotKeys[b] Then
         Begin
          HotKey := #0;
          Break;
         End;
       If HotKey <> #0 Then
        Begin
         Insert('&', Result, i);
         LastHotKeys[b] := HotKey;
         Break;
        End;
      End;
    End;
  End;

{ TCustomDlgBtnCaptions }

 Constructor TCustomDlgBtnCaptions.Create;
  Var
   DlgBtn : TMsgDlgBtn;
  Begin
   For DlgBtn         := Low(TMsgDlgBtn) To High(TMsgDlgBtn) Do
    fCaptions[DlgBtn] := LoadResString(ButtonCaptions_[DlgBtn]);
  End;

 Procedure TCustomDlgBtnCaptions.Assign(Source : TPersistent);
  Var
   DlgBtn : TMsgDlgBtn;
  Begin
   If Source Is TCustomDlgBtnCaptions Then
    For DlgBtn        := Low(TMsgDlgBtn) To High(TMsgDlgBtn) Do
     Captions[DlgBtn] := TCustomDlgBtnCaptions(Source).Captions[DlgBtn]
   Else
    Inherited Assign(Source);
  End;

 Function TCustomDlgBtnCaptions.GetMetrics(DC : HDC; Buttons : TMsgDlgButtons; Var Width, Height : Integer) : Integer;
  Const
   HorzSpacing = 4;
   VertSpacing = 2;
  Var
   b        : TMsgDlgBtn;
   TextRect : TRect;
  Begin
   Result := 0;
   For b  := Low(TMsgDlgBtn) To High(TMsgDlgBtn) Do
    If b In Buttons Then
     Begin
      Inc(Result);
      SetRect(TextRect, 0, 0, 0, 0);
      DrawText(DC, PChar(Captions[b]), Length(Captions[b]), TextRect,
      DT_CALCRECT Or DT_SINGLELINE);
      If Width < TextRect.Right - TextRect.Left + 2 * HorzSpacing Then
       Width := TextRect.Right - TextRect.Left + 2 * HorzSpacing;
      If Height < TextRect.Bottom - TextRect.Top + 2 * VertSpacing Then
       Height := TextRect.Bottom - TextRect.Top + 2 * VertSpacing;
     End;
  End;

 Function TCustomDlgBtnCaptions.GetCaptions(DlgBtn : TMsgDlgBtn) : String;
  Begin
   Result := fCaptions[DlgBtn];
  End;

 Procedure TCustomDlgBtnCaptions.SetCaptions(DlgBtn : TMsgDlgBtn; Const Value : String);
  Begin
   fCaptions[DlgBtn] := Value;
  End;

 Function TCustomDlgBtnCaptions.IsStoredCaptions(DlgBtn : TMsgDlgBtn) : Boolean;
  Begin
   Result := (fCaptions[DlgBtn] <> LoadResString(ButtonCaptions_[DlgBtn]));
  End;

{ TCustomDlgCheckBox }

 Constructor TCustomDlgCheckBox.Create;
  Begin
   Inherited Create;
   fAllowGrayed := False;
   fState       := cbUnchecked;
   fEnabled     := True;
   fVisible     := False;
  End;

 Procedure TCustomDlgCheckBox.Assign(Source : TPersistent);
  Begin
   If Source Is TCustomDlgCheckBox Then
    Begin
     Caption     := TCustomDlgCheckBox(Source).Caption;
     Hint        := TCustomDlgCheckBox(Source).Hint;
     AllowGrayed := TCustomDlgCheckBox(Source).AllowGrayed;
     State       := TCustomDlgCheckBox(Source).State;
     Enabled     := TCustomDlgCheckBox(Source).Enabled;
     Visible     := TCustomDlgCheckBox(Source).Visible;
    End
   Else If Source Is TCheckBox Then
    Begin
     Caption     := TCheckBox(Source).Caption;
     Hint        := TCheckBox(Source).Hint;
     AllowGrayed := TCheckBox(Source).AllowGrayed;
     State       := TCheckBox(Source).State;
     Enabled     := TCheckBox(Source).Enabled;
     Visible     := TCheckBox(Source).Visible;
    End
   Else
    Inherited Assign(Source);
  End;

 Procedure TCustomDlgCheckBox.AssignTo(Dest : TPersistent);
  Begin
   If Dest Is TCheckBox Then
    Begin
     TCheckBox(Dest).Caption     := Caption;
     TCheckBox(Dest).Hint        := Hint;
     TCheckBox(Dest).AllowGrayed := AllowGrayed;
     TCheckBox(Dest).State       := State;
     TCheckBox(Dest).Enabled     := Enabled;
     TCheckBox(Dest).Visible     := Visible;
    End
   Else
    Inherited AssignTo(Dest);
  End;

 Function TCustomDlgCheckBox.GetMetrics(DC : HDC; MaxWidth : Integer) : TSize;
  Const
   Spacing = 4;
  Var
   TextRect  : TRect;
   CheckSize : TSize;
  Begin
   CheckSize := GetCheckBoxSize;
   SetRect(TextRect, 0, 0, MaxWidth - CheckSize.cx + Spacing, 0);
   DrawText(DC, PChar(Caption), Length(Caption), TextRect,
   DT_CALCRECT Or DT_WORDBREAK);
   Result.cx := TextRect.Right - TextRect.Left + CheckSize.cx + Spacing;
   Result.cy := TextRect.Bottom - TextRect.Top;
   If Result.cy < CheckSize.cy Then
    Result.cy := CheckSize.cy;
  End;

 Procedure TCustomDlgCheckBox.SetCaption(Const Value : String);
  Begin
   If Caption <> Value Then
    Begin
     fCaption := Value;
     If Assigned(Control) Then
      Control.Caption := Caption;
    End;
  End;

 Procedure TCustomDlgCheckBox.SetHint(Const Value : String);
  Begin
   If Hint <> Value Then
    Begin
     fHint := Value;
     If Assigned(Control) Then
      Control.Hint := Hint;
    End;
  End;

 Procedure TCustomDlgCheckBox.SetAllowGrayed(Value : Boolean);
  Begin
   If AllowGrayed <> Value Then
    Begin
     fAllowGrayed := Value;
     If Assigned(Control) Then
      Control.AllowGrayed := AllowGrayed;
    End;
  End;

 Procedure TCustomDlgCheckBox.SetState(Value : TCheckBoxState);
  Begin
   If State <> Value Then
    Begin
     fState := Value;
     If Assigned(Control) Then
      Control.State := State;
    End;
  End;

 Function TCustomDlgCheckBox.GetChecked : Boolean;
  Begin
   Result := (State = cbChecked);
  End;

 Procedure TCustomDlgCheckBox.SetChecked(Value : Boolean);
  Begin
   If Value Then
    State := cbChecked
   Else
    State := cbUnchecked;
  End;

 Procedure TCustomDlgCheckBox.SetEnabled(Value : Boolean);
  Begin
   If Enabled <> Value Then
    Begin
     fEnabled := Value;
     If Assigned(Control) Then
      Control.Enabled := Enabled;
    End;
  End;

 Procedure TCustomDlgCheckBox.SetVisible(Value : Boolean);
  Begin
   If Visible <> Value Then
    Begin
     fVisible := Value;
     If Assigned(Control) Then
      Control.Visible := Visible;
    End;
  End;

 Procedure TCustomDlgCheckBox.SetControl(Value : TCheckBox);
  Begin
   If Control <> Value Then
    Begin
     fControl := Value;
     If Assigned(Control) Then
      AssignTo(Control);
    End;
  End;

{ TMsgDlgTypeIcons }

 Constructor TMsgDlgTypeIcons.Create;
  Var
   DlgType : TMsgDlgType;
  Begin
   For DlgType := Low(TMsgDlgType) To High(TMsgDlgType) Do
    Begin
     fIcons[DlgType] := TIcon.Create;
     If DlgType <> mtCustom Then
      fIcons[DlgType].Handle := LoadIcon(0, IconIDs[DlgType]);
    End;
  End;

 Destructor TMsgDlgTypeIcons.Destroy;
  Var
   DlgType : TMsgDlgType;
  Begin
   For DlgType := Low(TMsgDlgType) To High(TMsgDlgType) Do
    fIcons[DlgType].Free;
   Inherited Destroy;
  End;

 Procedure TMsgDlgTypeIcons.Assign(Source : TPersistent);
  Var
   DlgType : TMsgDlgType;
  Begin
   If Source Is TMsgDlgTypeIcons Then
    For DlgType     := Low(TMsgDlgType) To High(TMsgDlgType) Do
     Icons[DlgType] := TMsgDlgTypeIcons(Source).Icons[DlgType]
   Else
    Inherited Assign(Source);
  End;

 Function TMsgDlgTypeIcons.GetIcons(DlgType : TMsgDlgType) : TIcon;
  Begin
   Result := fIcons[DlgType];
  End;

 Procedure TMsgDlgTypeIcons.SetIcons(DlgType : TMsgDlgType; Value : TIcon);
  Begin
   If Assigned(Value) Then
    fIcons[DlgType].Assign(Value)
   Else If DlgType <> mtCustom Then
    fIcons[DlgType].Handle := LoadIcon(0, IconIDs[DlgType])
   Else
    fIcons[DlgType].Handle := 0;
  End;

 Function TMsgDlgTypeIcons.IsStoredIcons(DlgType : TMsgDlgType) : Boolean;
  Begin
   If fIcons[DlgType].Empty Then
    Result := False
   Else If DlgType <> mtCustom Then
    Result := (fIcons[DlgType].Handle <> LoadIcon(0, IconIDs[DlgType]))
   Else
    Result := True;
  End;

{ TMsgDlgTypeCaptions }

 Constructor TMsgDlgTypeCaptions.Create;
  Var
   DlgType : TMsgDlgType;
  Begin
   For DlgType := Low(TMsgDlgType) To High(TMsgDlgType) Do
    If DlgType <> mtCustom Then
     fCaptions[DlgType] := LoadResString(DialogCaptions[DlgType])
    Else
     fCaptions[DlgType] := '';
  End;

 Procedure TMsgDlgTypeCaptions.Assign(Source : TPersistent);
  Var
   DlgType : TMsgDlgType;
  Begin
   If Source Is TMsgDlgTypeCaptions Then
    For DlgType        := Low(TMsgDlgType) To High(TMsgDlgType) Do
     Captions[DlgType] := TMsgDlgTypeCaptions(Source).Captions[DlgType]
   Else
    Inherited Assign(Source);
  End;

 Function TMsgDlgTypeCaptions.GetCaptions(DlgType : TMsgDlgType) : String;
  Begin
   Result := fCaptions[DlgType];
  End;

 Procedure TMsgDlgTypeCaptions.SetCaptions(DlgType : TMsgDlgType; Const Value : String);
  Begin
   fCaptions[DlgType] := Value;
  End;

 Function TMsgDlgTypeCaptions.IsStoredCaptions(DlgType : TMsgDlgType) : Boolean;
  Begin
   If DlgType <> mtCustom Then
    Result := (fCaptions[DlgType] <> LoadResString(DialogCaptions[DlgType]))
   Else
    Result := (fCaptions[DlgType] <> '');
  End;

{ TMessageDialog }

 Constructor TMessageDialog.Create(AOwner : TComponent);
  Begin
   Inherited Create(AOwner);
   fAutoHotKeys    := True;
   fCheckBox       := TMsgDlgCheckBox.Create;
   fIcons          := TMsgDlgTypeIcons.Create;
   fCaptions       := TMsgDlgTypeCaptions.Create;
   fButtonCaptions := TMsgDlgBtnCaptions.Create;
   fFont           := TFont.Create;
   fFont.OnChange  := FontChange;
   ParentBiDiMode  := True;
   ParentFont      := True;
  End;

 Destructor TMessageDialog.Destroy;
  Begin
   fIcons.Free;
   fCaptions.Free;
   fButtonCaptions.Free;
   fCheckBox.Free;
   fFont.Free;
   Inherited Destroy;
  End;

 Function TMessageDialog.GetShowDuration : Cardinal;
  Begin
   If Assigned(Dialog) Then
    Result := GetTickCount - fShowTicks
   Else
    Result := fShowTicks;
  End;

 Procedure TMessageDialog.SetCheckBox(Value : TMsgDlgCheckBox);
  Begin
   fCheckBox.Assign(Value);
  End;

 Procedure TMessageDialog.SetIcons(Value : TMsgDlgTypeIcons);
  Begin
   fIcons.Assign(Value);
  End;

 Procedure TMessageDialog.SetCaptions(Value : TMsgDlgTypeCaptions);
  Begin
   fCaptions.Assign(Value);
  End;

 Procedure TMessageDialog.SetButtonCaptions(Value : TMsgDlgBtnCaptions);
  Begin
   fButtonCaptions.Assign(Value);
  End;

 Procedure TMessageDialog.SetFont(Value : TFont);
  Begin
   fFont.Assign(Value);
  End;

 Function TMessageDialog.GetBiDiMode : TBiDiMode;
  Begin
   If ParentBiDiMode Then
    fBiDiMode := Application.BiDiMode;
   Result     := fBiDiMode;
  End;

 Procedure TMessageDialog.SetBiDiMode(Value : TBiDiMode);
  Begin
   fBiDiMode       := Value;
   fParentBiDiMode := False;
  End;

 Procedure TMessageDialog.SetParentFont(Value : Boolean);
  Begin
   If ParentFont <> Value Then
    Begin
     If Value Then
      fFont.Assign(Application.DefaultFont);
     fParentFont := Value;
    End;
  End;

 Procedure TMessageDialog.SetParentBiDiMode(Value : Boolean);
  Begin
   If ParentBiDiMode <> Value Then
    Begin
     If Value Then
      fBiDiMode      := Application.BiDiMode;
     fParentBiDiMode := Value;
    End;
  End;

 Function TMessageDialog.IsStoredFont : Boolean;
  Begin
   Result := Not ParentFont;
  End;

 Function TMessageDialog.IsStoredBiDiMode : Boolean;
  Begin
   Result := Not ParentBiDiMode;
  End;

 Procedure TMessageDialog.FontChange(Sender : TObject);
  Begin
   fParentFont := False;
  End;

 Procedure TMessageDialog.DialogShow(Sender : TObject);
  Begin
   DoShow;
  End;

 Procedure TMessageDialog.DialogClose(Sender : TObject; Var Action : TCloseAction);
  Begin
   DoClose;
  End;

 Procedure TMessageDialog.DialogKeyDown(Sender : TObject; Var Key : Word; Shift : TShiftState);
  Begin
   If (Shift = [ssCtrl]) And (Key = Word('C')) Then
    Begin
     Beep;
     Clipboard.AsText := GetDialogText;
    End;
  End;

 Procedure TMessageDialog.HelpButtonClick(Sender : TObject);
  Begin
   Application.HelpContext(Dialog.HelpContext);
  End;

 Procedure TMessageDialog.CheckBoxClicked(Sender : TObject);
  Begin
   If Assigned(CheckBox.Control) Then
    CheckBox.State := CheckBox.Control.State;
  End;

 Procedure TMessageDialog.CallbackTimerTrigger(Sender : TObject);
  Begin
   DoCallbackTimer;
  End;

 Procedure TMessageDialog.DoShow;
  Begin
   If Assigned(OnShow) Then
    OnShow(Self);
  End;

 Procedure TMessageDialog.DoClose;
  Begin
   If Assigned(OnClose) Then
    OnClose(Self);
  End;

 Procedure TMessageDialog.DoCallbackTimer;
  Begin
   If Assigned(OnCallbackTimer) Then
    OnCallbackTimer(Self);
  End;

 Function TMessageDialog.GetDialogText : String;
  Var
   DividerLine, ButtonCaptions, MessageCaption : String;
   i                                           : Integer;
  Begin
   If Assigned(Dialog) Then
    Begin
     ButtonCaptions := '';
     MessageCaption := '';
     DividerLine    := StringOfChar('-', 27) + sLineBreak;
     For i          := 0 To Dialog.ComponentCount - 1 Do
      If Dialog.Components[i] Is TButton Then
       ButtonCaptions := ButtonCaptions + TButton(Dialog.Components[i])
       .Caption + StringOfChar(' ', 3)
      Else If Dialog.Components[i] Is TStaticText Then
       MessageCaption := TStaticText(Dialog.Components[i]).Caption;
     ButtonCaptions   := StringReplace(ButtonCaptions, '&', '', [rfReplaceAll]);
     Result           := DividerLine + Dialog.Caption + sLineBreak + DividerLine +
     MessageCaption + sLineBreak + DividerLine + ButtonCaptions + sLineBreak +
     DividerLine;
    End
   Else
    Result := '';
  End;

 Function TMessageDialog.Show(Const Msg : String; DlgType : TMsgDlgType; Buttons : TMsgDlgButtons; DefaultButton : TMsgDlgBtn; HelpContext : THelpContext) : Integer;
  Const
   mcHorzMargin     = 8;
   mcVertMargin     = 6;
   mcHorzSpacing    = 8;
   mcVertSpacing    = 5;
   mcButtonWidth    = 60;
   mcButtonHeight   = 14;
   mcButtonSpacing  = 4;
   mcMinDialogWidth = 260;
  Var
   DC                                       : HDC;
   tm                                       : TTextMetric;
   TextRect                                 : TRect;
   TextSize, IconSize, CheckSize            : TSize;
   HorzMargin, VertMargin                   : Integer;
   HorzSpacing, VertSpacing                 : Integer;
   ButtonWidth, ButtonHeight, ButtonSpacing : Integer;
   ButtonCount, ButtonGroupWidth            : Integer;
   IconTextWidth, IconTextHeight            : Integer;
   b, CancelButton                          : TMsgDlgBtn;
   x, MinDialogWidth                        : Integer;
   ButtonsPanel                             : TPanel;
   Button                                   : TButton;
   HotKeys                                  : TButtonHotKeys;
  Begin
   fDialog := TForm.CreateNew(Application);
   Try
    // init dialog
    Dialog.BiDiMode    := BiDiMode;
    Dialog.Color       := clWindow;
    Dialog.Font        := Font;
    Dialog.ShowHint    := True;
    Dialog.KeyPreview  := True;
    Dialog.BorderStyle := bsToolWindow;
    Dialog.Position    := poScreenCenter;
    Dialog.HelpContext := HelpContext;
    Dialog.Icon        := Application.Icon;
    Dialog.OnShow      := DialogShow;
    Dialog.OnClose     := DialogClose;
    Dialog.OnKeyDown   := DialogKeyDown;
    Dialog.Canvas.Font := Dialog.Font;
    Dialog.Caption     := Captions[DlgType];
    If Dialog.Caption = '' Then
     Dialog.Caption := Application.Title;
    // calculate metrics
    DC := Dialog.Canvas.Handle;
    GetTextMetrics(DC, tm);
    HorzMargin     := MulDiv(mcHorzMargin, tm.tmAveCharWidth, 4);
    VertMargin     := MulDiv(mcVertMargin, tm.tmHeight, 8);
    HorzSpacing    := MulDiv(mcHorzSpacing, tm.tmAveCharWidth, 4);
    VertSpacing    := MulDiv(mcVertSpacing, tm.tmHeight, 8);
    ButtonWidth    := MulDiv(mcButtonWidth, tm.tmAveCharWidth, 4);
    ButtonHeight   := MulDiv(mcButtonHeight, tm.tmHeight, 8);
    ButtonSpacing  := MulDiv(mcButtonSpacing, tm.tmAveCharWidth, 4);
    MinDialogWidth := MulDiv(mcMinDialogWidth, tm.tmAveCharWidth, 4);
    // calculate size of buttons
    ButtonCount := ButtonCaptions.GetMetrics(DC, Buttons, ButtonWidth, ButtonWidth);
    If ButtonCount > 0 Then
     ButtonGroupWidth := ButtonWidth * ButtonCount + ButtonSpacing * (ButtonCount - 1)
    Else
     ButtonGroupWidth := 0;
    // calculate size of message
    SetRect(TextRect, 0, 0, Screen.Width Div 3, 0);
    DrawText(DC, PChar(Msg), Length(Msg), TextRect,
    DT_EXPANDTABS Or DT_CALCRECT Or DT_WORDBREAK);
    OffsetRect(TextRect, HorzMargin, VertMargin);
    TextSize.cx    := TextRect.Right - TextRect.Left;
    TextSize.cy    := TextRect.Bottom - TextRect.Top;
    IconTextWidth  := TextSize.cx + 2 * HorzMargin;
    IconTextHeight := TextSize.cy + 2 * VertMargin;
    // calculate size of icon
    If Not Icons[DlgType].Empty Then
     Begin
      IconSize.cx := Icons[DlgType].Width;
      IconSize.cy := Icons[DlgType].Height;
     End
    Else
     Begin
      IconSize.cx := 0;
      IconSize.cy := 0;
     End;
    If IconSize.cx <> 0 Then
     Begin
      OffsetRect(TextRect, IconSize.cx + HorzSpacing, 0);
      Inc(IconTextWidth, IconSize.cx + HorzSpacing);
      If IconSize.cy > TextSize.cy Then
       Begin
        OffsetRect(TextRect, 0, (IconSize.cy - TextSize.cy) Div 2);
        Inc(IconTextHeight, IconSize.cy - TextSize.cy);
       End;
     End;
    // adjust size
    If IconTextWidth < ButtonGroupWidth + 2 * HorzMargin Then
     Begin
      Inc(TextSize.cx, ButtonGroupWidth + 2 * HorzMargin - IconTextWidth);
      IconTextWidth := ButtonGroupWidth + 2 * HorzMargin;
     End;
    If IconTextWidth < MinDialogWidth Then
     Begin
      Inc(TextSize.cx, MinDialogWidth - IconTextWidth);
      IconTextWidth := MinDialogWidth;
     End;
    // calculate size of check box
    If CheckBox.Visible Then
     Begin
      CheckSize := CheckBox.GetMetrics(DC, TextSize.cx);
      If CheckSize.cx > TextSize.cx Then
       Begin
        Inc(IconTextWidth, CheckSize.cx - TextSize.cx);
        Inc(TextSize.cx, CheckSize.cx - TextSize.cx);
       End;
     End
    Else
     Begin
      CheckSize.cx := 0;
      CheckSize.cy := 0;
     End;
    // create icon
    If IconSize.cx <> 0 Then
     With TImage.Create(Dialog) Do
      Begin
       Name         := 'Image';
       Parent       := Dialog;
       Center       := True;
       Proportional := True;
       Picture.Icon.Assign(Icons[DlgType]);
       SetBounds(HorzMargin, VertMargin, IconSize.cx, IconSize.cy);
      End;
    // create message
    If Msg <> '' Then
     With TStaticText.Create(Dialog) Do
      Begin
       Name          := 'Message';
       Parent        := Dialog;
       AutoSize      := False;
       ShowAccelChar := False;
       Caption       := Msg;
       BoundsRect    := TextRect;
      End;
    // create checkbox
    If CheckBox.Visible Then
     Begin
      CheckBox.Control := TCheckBox.Create(Dialog);
      With CheckBox.Control Do
       Begin
        Parent   := Dialog;
        WordWrap := True;
        OnClick  := CheckBoxClicked;
        SetBounds(TextRect.Left, IconTextHeight, CheckSize.cx, CheckSize.cy);
        Inc(IconTextHeight, VertMargin + CheckSize.cy);
       End;
     End;
    // create buttons
    If ButtonCount > 0 Then
     Begin
      ButtonsPanel := TPanel.Create(Dialog);
      With ButtonsPanel Do
       Begin
        Name             := 'ButtonsPanel';
        Parent           := Dialog;
        Caption          := '';
        ShowCaption      := False;
        BevelOuter       := bvNone;
        ParentBackground := False;
        SetBounds(0, IconTextHeight, IconTextWidth, ButtonHeight + 2 * VertSpacing - 1);
       End;
      With TBevel.Create(Dialog) Do
       Begin
        Parent := ButtonsPanel;
        SetBounds(0, 0, ButtonsPanel.Width, 1);
        Shape := bsTopLine;
       End;
      FillChar(HotKeys, SizeOf(HotKeys), 0);
      If mbCancel In Buttons Then
       CancelButton := mbCancel
      Else If mbNo In Buttons Then
       CancelButton := mbNo
      Else
       CancelButton := mbOK;
      x             := ButtonsPanel.ClientWidth - ButtonGroupWidth - HorzMargin;
      For b         := Low(TMsgDlgBtn) To High(TMsgDlgBtn) Do
       If b In Buttons Then
        Begin
         Button := TButton.Create(Dialog);
         With Button Do
          Begin
           Name   := ButtonNames[b];
           Parent := ButtonsPanel;
           If AutoHotKeys Then
            Caption := GetAutoHotKey(ButtonCaptions[b], b, HotKeys)
           Else
            Caption    := ButtonCaptions[b];
           ModalResult := ModalResults[b];
           If b = DefaultButton Then
            Begin
             Default              := True;
             Dialog.ActiveControl := Button;
            End;
           If b = CancelButton Then
            Cancel := True;
           If b = mbHelp Then
            OnClick := HelpButtonClick;
           SetBounds(x, VertSpacing, ButtonWidth, ButtonHeight);
           Inc(x, ButtonWidth + ButtonSpacing);
          End;
        End;
     End;
    // adjust dialog size
    Dialog.ClientWidth := IconTextWidth;
    If ButtonCount > 0 Then
     Dialog.ClientHeight := IconTextHeight + ButtonHeight + 2 * VertSpacing
    Else
     Dialog.ClientHeight := IconTextHeight;
    // do the flip if needed
    If Dialog.UseRightToLeftAlignment Then
     Dialog.FlipChildren(True);
    // create callback timer
    If CallbackTimer Then
     With TTimer.Create(Dialog) Do
      Begin
       Name    := 'Timer';
       OnTimer := CallbackTimerTrigger;
      End;
    // show the dialog
    fShowTicks := GetTickCount;
    Result     := Dialog.ShowModal;
    fShowTicks := GetTickCount - fShowTicks;
   Finally
    CheckBox.Control := Nil;
    FreeAndNil(fDialog);
   End;
  End;

 Function TMessageDialog.Show(Const Fmt : String; Const Args : Array Of Const; DlgType : TMsgDlgType; Buttons : TMsgDlgButtons; DefaultButton : TMsgDlgBtn; HelpContext : THelpContext) : Integer;
  Begin
   Result := Show(Format(Fmt, Args), DlgType, Buttons, DefaultButton, HelpContext);
  End;

 Function TMessageDialog.Show(Const Msg : String; DlgType : TMsgDlgType; Buttons : TMsgDlgButtons; HelpContext : THelpContext) : Integer;
  Var
   DefaultButton : TMsgDlgBtn;
  Begin
   If mbOK In Buttons Then
    DefaultButton := mbOK
   Else If mbYes In Buttons Then
    DefaultButton := mbYes
   Else
    DefaultButton := mbRetry;
   Result         := Show(Msg, DlgType, Buttons, DefaultButton, HelpContext);
  End;

 Function TMessageDialog.Show(Const Fmt : String; Const Args : Array Of Const; DlgType : TMsgDlgType; Buttons : TMsgDlgButtons; HelpContext : THelpContext) : Integer;
  Begin
   Result := Show(Format(Fmt, Args), DlgType, Buttons, HelpContext)
  End;

 Procedure TMessageDialog.ShowMessage(Const Msg : String; HelpContext : THelpContext);
  Var
   Buttons : TMsgDlgButtons;
  Begin
   Buttons := [mbOK];
   If HelpContext <> 0 Then
    Include(Buttons, mbHelp);
   Show(Msg, mtCustom, Buttons, HelpContext);
  End;

 Procedure TMessageDialog.ShowWarning(Const Msg : String; HelpContext : THelpContext);
  Var
   Buttons : TMsgDlgButtons;
  Begin
   Buttons := [mbOK];
   If HelpContext <> 0 Then
    Include(Buttons, mbHelp);
   Show(Msg, mtWarning, Buttons, HelpContext);
  End;

 Procedure TMessageDialog.ShowError(Const Msg : String; HelpContext : THelpContext);
  Var
   Buttons : TMsgDlgButtons;
  Begin
   Buttons := [mbOK];
   If HelpContext <> 0 Then
    Include(Buttons, mbHelp);
   Show(Msg, mtError, Buttons, HelpContext);
  End;

 Procedure TMessageDialog.Inform(Const Msg : String; HelpContext : THelpContext);
  Var
   Buttons : TMsgDlgButtons;
  Begin
   Buttons := [mbOK];
   If HelpContext <> 0 Then
    Include(Buttons, mbHelp);
   Show(Msg, mtInformation, Buttons, HelpContext);
  End;

 Function TMessageDialog.Confirm(Const Msg : String; DefaultButton : TMsgDlgBtn; HelpContext : THelpContext) : Boolean;
  Var
   Buttons : TMsgDlgButtons;
  Begin
   Buttons := [mbYes, mbNo];
   If HelpContext <> 0 Then
    Include(Buttons, mbHelp);
   Result := (Show(Msg, mtConfirmation, Buttons, DefaultButton, HelpContext) = mrYes);
  End;

 Function TMessageDialog.YesNoCancel(Const Msg : String; DefaultButton : TMsgDlgBtn; HelpContext : THelpContext) : Integer;
  Var
   Buttons : TMsgDlgButtons;
  Begin
   Buttons := [mbYes, mbNo, mbCancel];
   If HelpContext <> 0 Then
    Include(Buttons, mbHelp);
   Result := Show(Msg, mtConfirmation, Buttons, DefaultButton, HelpContext);
  End;

 Function TMessageDialog.YesNoAllCancel(Const Msg : String; DefaultButton : TMsgDlgBtn; HelpContext : THelpContext) : Integer;
  Var
   Buttons : TMsgDlgButtons;
  Begin
   Buttons := [mbYes, mbNo, mbYesToAll, mbNoToAll, mbCancel];
   If HelpContext <> 0 Then
    Include(Buttons, mbHelp);
   Result := Show(Msg, mtConfirmation, Buttons, DefaultButton, HelpContext);
  End;

 Function TMessageDialog.RetryIgnoreAbort(Const Msg : String; DefaultButton : TMsgDlgBtn; HelpContext : THelpContext) : Integer;
  Var
   Buttons : TMsgDlgButtons;
  Begin
   Buttons := [mbRetry, mbIgnore, mbAbort];
   If HelpContext <> 0 Then
    Include(Buttons, mbHelp);
   Result := Show(Msg, mtWarning, Buttons, DefaultButton, HelpContext);
  End;

{ TInputDialog }

 Constructor TInputQueryDialog.Create(AOwner : TComponent);
  Begin
   Inherited Create(AOwner);
   fButtonCaptions := TInputQueryDlgBtnCaptions.Create;
   fFont           := TFont.Create;
   fFont.OnChange  := FontChange;
   ParentBiDiMode  := True;
   ParentFont      := True;
  End;

 Destructor TInputQueryDialog.Destroy;
  Begin
   fButtonCaptions.Free;
   fFont.Free;
   Inherited Destroy;
  End;

 Procedure TInputQueryDialog.SetButtonCaptions(Value : TInputQueryDlgBtnCaptions);
  Begin
   fButtonCaptions.Assign(Value);
  End;

 Procedure TInputQueryDialog.SetFont(Value : TFont);
  Begin
   fFont.Assign(Value);
  End;

 Function TInputQueryDialog.GetBiDiMode : TBiDiMode;
  Begin
   If ParentBiDiMode Then
    fBiDiMode := Application.BiDiMode;
   Result     := fBiDiMode;
  End;

 Procedure TInputQueryDialog.SetBiDiMode(Value : TBiDiMode);
  Begin
   fBiDiMode       := Value;
   fParentBiDiMode := False;
  End;

 Procedure TInputQueryDialog.SetParentFont(Value : Boolean);
  Begin
   If ParentFont <> Value Then
    Begin
     If Value Then
      fFont.Assign(Application.DefaultFont);
     fParentFont := Value;
    End;
  End;

 Procedure TInputQueryDialog.SetParentBiDiMode(Value : Boolean);
  Begin
   If ParentBiDiMode <> Value Then
    Begin
     fBiDiMode       := Application.BiDiMode;
     fParentBiDiMode := Value;
    End;
  End;

 Function TInputQueryDialog.IsStoredFont : Boolean;
  Begin
   Result := Not ParentFont;
  End;

 Function TInputQueryDialog.IsStoredBiDiMode : Boolean;
  Begin
   Result := Not ParentBiDiMode;
  End;

 Procedure TInputQueryDialog.FontChange(Sender : TObject);
  Begin
   fParentFont := False;
  End;

 Procedure TInputQueryDialog.DialogShow(Sender : TObject);
  Begin
   DoShow;
   If EditBox.ReadOnly Then
    Windows.SetFocus(GetNextDlgTabItem(Dialog.Handle, EditBox.Handle, False));
  End;

 Procedure TInputQueryDialog.DialogClose(Sender : TObject; Var Action : TCloseAction);
  Begin
   DoClose;
  End;

 Procedure TInputQueryDialog.DialogCloseQuery(Sender : TObject; Var CanClose : Boolean);
  Var
   Value : String;
  Begin
   If (Dialog.ModalResult = mrOk) And Not EditBox.ReadOnly Then
    Begin
     Value := EditBox.Text;
     If Not DoValidate(Value) Then
      Begin
       EditBox.SetFocus;
       CanClose := False;
      End;
     EditBox.Text := Value;
    End;
  End;

 Procedure TInputQueryDialog.HelpButtonClick(Sender : TObject);
  Begin
   Application.HelpContext(Dialog.HelpContext);
  End;

 Procedure TInputQueryDialog.DoShow;
  Begin
   If Assigned(OnShow) Then
    OnShow(Self);
  End;

 Procedure TInputQueryDialog.DoClose;
  Begin
   If Assigned(OnClose) Then
    OnClose(Self);
  End;

 Function TInputQueryDialog.DoValidate(Var Value : String) : Boolean;
  Begin
   If Assigned(OnValidate) Then
    Result := OnValidate(Self, Value)
   Else
    Begin
     Try
      Case InputType Of
       itInteger : StrToInt(Value);
       itFloat   : StrToFloat(Value);
      End;
      Result := True;
     Except
      Result := False;
     End;
    End;
  End;

 Function TInputQueryDialog.Prompt(Const ACaption, APrompt : String; Var Value : String; AInputType : TInputType; HelpContext : THelpContext) : Boolean;
  Const
   mcHorzMargin    = 8;
   mcVertMargin    = 6;
   mcButtonWidth   = 60;
   mcButtonHeight  = 14;
   mcButtonSpacing = 4;
   mcEditBoxWidth  = 300;
  Var
   DC                                       : HDC;
   tm                                       : TTextMetric;
   TextRect                                 : TRect;
   HorzMargin, VertMargin                   : Integer;
   ButtonWidth, ButtonHeight, ButtonSpacing : Integer;
   ButtonCount, ButtonGroupWidth            : Integer;
   EditBoxWidth, TextEditHeight             : Integer;
   Buttons                                  : TMsgDlgButtons;
   b                                        : TMsgDlgBtn;
   x                                        : Integer;
   ButtonAnchors                            : TAnchors;
  Begin
   Result     := False;
   fInputType := AInputType;
   fDialog    := TForm.CreateNew(Application);
   Try
    // init dialog
    Dialog.Caption  := ACaption;
    Dialog.BiDiMode := BiDiMode;
    Dialog.Font     := Font;
    If InputType = itMultiLineText Then
     Begin
      Dialog.BorderStyle := bsSizeable;
      Dialog.BorderIcons := [biSystemMenu, biMaximize];
     End
    Else
     Dialog.BorderStyle := bsDialog;
    Dialog.ShowHint     := True;
    Dialog.Position     := poScreenCenter;
    Dialog.HelpContext  := HelpContext;
    Dialog.OnShow       := DialogShow;
    Dialog.OnClose      := DialogClose;
    Dialog.OnCloseQuery := DialogCloseQuery;
    Dialog.Canvas.Font  := Dialog.Font;
    // calculate metrics
    DC := Dialog.Canvas.Handle;
    GetTextMetrics(DC, tm);
    HorzMargin    := MulDiv(mcHorzMargin, tm.tmAveCharWidth, 4);
    VertMargin    := MulDiv(mcVertMargin, tm.tmHeight, 8);
    ButtonWidth   := MulDiv(mcButtonWidth, tm.tmAveCharWidth, 4);
    ButtonHeight  := MulDiv(mcButtonHeight, tm.tmHeight, 8);
    ButtonSpacing := MulDiv(mcButtonSpacing, tm.tmAveCharWidth, 4);
    EditBoxWidth  := MulDiv(mcEditBoxWidth, tm.tmAveCharWidth, 4);
    If InputType = itMultiLineText Then
     EditBoxWidth := MulDiv(EditBoxWidth, 150, 100);
    // calculate size of buttons
    Buttons := [mbOK];
    If Not ReadOnly Then
     Include(Buttons, mbCancel);
    If HelpContext <> 0 Then
     Include(Buttons, mbHelp);
    ButtonCount      := ButtonCaptions.GetMetrics(DC, Buttons, ButtonWidth, ButtonHeight);
    ButtonGroupWidth := ButtonWidth * ButtonCount + ButtonSpacing * (ButtonCount - 1);
    If EditBoxWidth < ButtonGroupWidth Then
     EditBoxWidth := ButtonGroupWidth;
    // calculate size of prompt
    SetRect(TextRect, 0, 0, EditBoxWidth, 0);
    DrawText(DC, PChar(APrompt), Length(APrompt), TextRect,
    DT_CALCRECT Or DT_WORDBREAK Or Dialog.DrawTextBiDiModeFlagsReadingOnly);
    TextEditHeight := TextRect.Bottom;
    OffsetRect(TextRect, HorzMargin, VertMargin);
    // create edit box
    If InputType = itMultiLineText Then
     fEditBox := TMemo.Create(Dialog)
    Else
     Begin
      fEditBox := TEdit.Create(Dialog);
      If InputType In [itInteger, itFloat] Then
       Begin
        TEdit(fEditBox).NumbersOnly := True;
        If BiDiMode = bdRightToLeft Then
         fEditBox.BiDiMode := bdRightToLeftNoAlign;
       End;
     End;
    EditBox.ReadOnly := ReadOnly;
    With EditBox Do
     Begin
      Name   := 'EditBox';
      Parent := Dialog;
      Text   := Value;
      Left   := TextRect.Left;
      Top    := TextRect.Bottom + tm.tmInternalLeading;
      Width  := EditBoxWidth;
      If InputType = itMultiLineText Then
       Begin
        ClientHeight               := (tm.tmHeight + tm.tmInternalLeading) * 15;
        TMemo(EditBox).WantReturns := True;
        TMemo(EditBox).WordWrap    := False;
        TMemo(EditBox).ScrollBars  := ssVertical;
       End;
      Inc(TextEditHeight, Height + tm.tmInternalLeading);
     End;
    // create prompt
    If APrompt <> '' Then
     With TStaticText.Create(Dialog) Do
      Begin
       Name         := 'EditBoxLabel';
       Parent       := Dialog;
       AutoSize     := False;
       Caption      := APrompt;
       FocusControl := EditBox;
       BoundsRect   := TextRect;
      End;
    // set dialog's size and adjust anchors
    Dialog.ClientWidth          := EditBoxWidth + 2 * HorzMargin;
    Dialog.ClientHeight         := TextEditHeight + 3 * VertMargin + ButtonHeight;
    Dialog.Constraints.MinWidth := ButtonWidth + ButtonGroupWidth + 2 *
    HorzMargin + Dialog.Width - Dialog.ClientWidth;
    Dialog.Constraints.MinHeight := Dialog.Height -
    (tm.tmHeight + tm.tmInternalLeading) * 10;
    EditBox.Anchors := [akLeft, akTop, akRight, akBottom];
    If Dialog.UseRightToLeftAlignment Then
     ButtonAnchors := [akLeft, akBottom]
    Else
     ButtonAnchors := [akRight, akBottom];
    // create buttons
    x     := Dialog.ClientWidth - ButtonGroupWidth - HorzMargin;
    For b := Low(TMsgDlgBtn) To High(TMsgDlgBtn) Do
     If b In Buttons Then
      Begin
       With TButton.Create(Dialog) Do
        Begin
         Name        := ButtonNames[b];
         Parent      := Dialog;
         Caption     := ButtonCaptions[b];
         ModalResult := ModalResults[b];
         Anchors     := ButtonAnchors;
         If b = mbOK Then
          Default := True;
         If b = mbCancel Then
          Cancel := True;
         If b = mbHelp Then
          OnClick := HelpButtonClick;
         SetBounds(x, TextEditHeight + 2 * VertMargin, ButtonWidth,
         ButtonHeight);
         Inc(x, ButtonWidth + ButtonSpacing);
        End;
      End;
     // do the flip if needed
    If Dialog.UseRightToLeftAlignment Then
     Dialog.FlipChildren(True);
    // show the dialog
    If Dialog.ShowModal = mrOk Then
     Begin
      Value  := EditBox.Text;
      Result := True;
     End;
   Finally
    FreeAndNil(fDialog);
   End;
  End;

 Function TInputQueryDialog.Execute(Const ACaption, APrompt : String; Var Value : String; Multiline : Boolean; HelpContext : THelpContext) : Boolean;
  Begin
   If Multiline Then
    Result := Prompt(ACaption, APrompt, Value, itMultiLineText, HelpContext)
   Else
    Result := Prompt(ACaption, APrompt, Value, itSingleLineText, HelpContext);
  End;

 Function TInputQueryDialog.Execute(Const ACaption, APrompt : String; Var Value : Integer; HelpContext : THelpContext) : Boolean;
  Var
   StrValue : String;
  Begin
   Result   := False;
   StrValue := IntToStr(Value);
   If Prompt(ACaption, APrompt, StrValue, itInteger, HelpContext) Then
    Begin
     Try
      Value  := StrToInt(StrValue);
      Result := True;
     Except
      // no exception
     End;
    End;
  End;

 Function TInputQueryDialog.Execute(Const ACaption, APrompt : String; Var Value : Double; HelpContext : THelpContext) : Boolean;
  Var
   StrValue : String;
  Begin
   Result   := False;
   StrValue := Format('%g', [Value]);
   If Prompt(ACaption, APrompt, StrValue, itInteger, HelpContext) Then
    Begin
     Try
      Value  := StrToFloat(StrValue);
      Result := True;
     Except
      // no exception
     End;
    End;
  End;

End.
