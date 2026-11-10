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
/// This unit implements data-aware controls for displaying and editing data
/// fields that represent locales, countries, and currencies.
/// </summary>
Unit i18nDBCtrls;

{$I DELPHIAREA.INC}

Interface

 Uses
  Windows, Messages, Classes, Graphics, Controls, DB, DBCtrls, ImgList,
  {$IFDEF COMPILER_XE3_UP} UITypes, {$ENDIF}
  SysUtils, i18nCore, i18nCtrls;

 Type
  {$Region 'xmldoc'}
  /// <summary>
  /// TCustomDBImageLabel is the base class for data-aware label controls that display
  /// an image icon plus value of a field.
  /// </summary>
  /// <remarks>
  /// Use TCustomDBImageLabel as a base class when defining objects that display an
  /// icon followed by value of a database field on a form. TCustomDBImageLabel
  /// implements properties to specify the icon from an image list component, along
  /// with its appearance and placement on the label.
  /// </remarks>
  {$Endregion}
  TCustomDBImageLabel = Class(TCustomImageLabel)
   Private
    fDataLink : TFieldDataLink;
    Procedure DataChange(Sender : TObject);
    Function GetDataField : WideString; Inline;
    Procedure SetDataField(Const Value : WideString); Inline;
    Function GetDataSource : TDataSource; Inline;
    Procedure SetDataSource(Value : TDataSource); Inline;
    Function GetField : TField;
    Procedure CMGetDataLink(Var Message : TMessage); Message CM_GETDATALINK;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Updates the control when it is first loaded into memory.
    /// </summary>
    {$Endregion}
    Procedure Loaded; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Determines the string that appears as the text of the label.
    /// </summary>
    /// <returns>
    /// The text that appears on the label.
    /// </returns>
    {$Endregion}
    Function GetLabelText : String; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Sets the <see cref="AutoSize"/> property.
    /// </summary>
    /// <param name="Value">
    /// Indicates whether the auto size should be on or off.
    /// </param>
    {$Endregion}
    Procedure SetAutoSize(Value : Boolean); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Helps the data-aware control manage its link to the data source and respond
    /// to data events.
    /// </summary>
    {$Endregion}
    Property DataLink : TFieldDataLink Read fDataLink;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the name of field whose value is displayed by the control.
    /// </summary>
    {$Endregion}
    Property DataField : WideString Read GetDataField Write SetDataField;
    {$Region 'xmldoc'}
    /// <summary>
    /// Links the control to the dataset that contains the field it represents.
    /// </summary>
    {$Endregion}
    Property DataSource : TDataSource Read GetDataSource Write SetDataSource;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the control.
    /// </summary>
    /// <param name="AOwner">
    /// The owner component.
    /// </param>
    {$Endregion}
    Constructor Create(AOwner : TComponent); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Destroys the control and releases its allocated memory.
    /// </summary>
    {$Endregion}
    Destructor Destroy; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Specifies whether the control's alignment is in a right-to-left mode.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> if the control's alignment is in a right-to-left
    /// mode, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function UseRightToLeftAlignment : Boolean; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the <see cref="TField"/> object for the database field that the control
    /// represents.
    /// </summary>
    {$Endregion}
    Property Field : TField Read GetField;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TDBImageLabel is a data-aware label control that displays an image icon plus value of
/// a field.
/// </summary>
/// <remarks>
/// <para>
/// Use TDBImageLabel to display an icon followed by value of a database field on a form.
/// The <see cref="ImageIndex"/> property determines which image of the image list identified
/// by the <see cref="Images"/> property will be displayed.
/// </para>
/// <para>
/// TDBImageLabel control can have a border. The <see cref="BorderColor"/> and
/// <see cref="BorderWidth"/> properties determine color and thickness of the
/// border.
/// </para>
/// <para>
/// TDBImageLabel publishes many of the properties, events, and methods of
/// <see cref="TCustomDBImageLabel"/>, but does not introduce any new behavior.
/// </para>
/// </remarks>
/// <group name="Components"/>
{$Endregion}
{$IFDEF COMPILER_XE2_UP}

  [ComponentPlatformsAttribute(pidWin32 Or pidWin64)]
  {$ENDIF}
  TDBImageLabel = Class(TCustomDBImageLabel)
   Published
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets how the control aligns within its container (parent control).
    /// </summary>
    {$Endregion}
    Property Align;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the horizontal placement of the text within the label.
    /// </summary>
    {$Endregion}
    Property Alignment;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether a control should be constrained by <see cref="Margins"/>.
    /// </summary>
    {$Endregion}
    Property AlignWithMargins;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets how the control is anchored to its parent.
    /// </summary>
    {$Endregion}
    Property Anchors;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control sizes itself automatically to accommodate
    /// its contents.
    /// </summary>
    {$Endregion}
    Property AutoSize Default False;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the bidirectional mode for the control.
    /// </summary>
    {$Endregion}
    Property BiDiMode;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the color of the control's border.
    /// </summary>
    {$Endregion}
    Property BorderColor;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the width of the control's border.
    /// </summary>
    {$Endregion}
    Property BorderWidth;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the background color of the control.
    /// </summary>
    {$Endregion}
    Property Color Nodefault;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the size constraints for the control.
    /// </summary>
    {$Endregion}
    Property Constraints;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the name of field whose value is displayed by the control.
    /// </summary>
    {$Endregion}
    Property DataField;
    {$Region 'xmldoc'}
    /// <summary>
    /// Links the control to the dataset that contains the field it represents.
    /// </summary>
    {$Endregion}
    Property DataSource;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the image used to represent the mouse pointer when it passes
    /// into the region covered by the control.
    /// </summary>
    {$Endregion}
    Property DragCursor;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control is being dragged normally or for docking.
    /// </summary>
    {$Endregion}
    Property DragKind;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets how the control initiates drag-and-drop or drag-and-dock operations.
    /// </summary>
    {$Endregion}
    Property DragMode;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control responds to keyboard, mouse, and timer events.
    /// </summary>
    {$Endregion}
    Property Enabled;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets a windowed control associated with the label.
    /// </summary>
    {$Endregion}
    Property FocusControl;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the attributes of text written on the control.
    /// </summary>
    {$Endregion}
    Property Font;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the radius of the glow around the label.
    /// NOTE: This feature is only available in Windows Vista and later.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property GlowSize;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the text string that can appear when the user moves the mouse over
    /// the control.
    /// </summary>
    {$Endregion}
    Property Hint;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets which image is displayed as the icon on the label.
    /// </summary>
    {$Endregion}
    Property ImageIndex;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the images that can appear on the control.
    /// </summary>
    {$Endregion}
    Property Images;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the margins of the control.
    /// </summary>
    {$Endregion}
    Property Margins;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the distance between the image and the text from the control's border.
    /// </summary>
    {$Endregion}
    Property Padding;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="BiDiMode"/>.
    /// </summary>
    {$Endregion}
    Property ParentBiDiMode;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="Color"/>.
    /// </summary>
    {$Endregion}
    Property ParentColor;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="Font"/>.
    /// </summary>
    {$Endregion}
    Property ParentFont;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="ShowHint"/>.
    /// </summary>
    {$Endregion}
    Property ParentShowHint;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the pop-up menu associated with the control.
    /// </summary>
    {$Endregion}
    Property PopupMenu;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets how an ampersand in the label text is displayed.
    /// </summary>
    {$Endregion}
    Property ShowAccelChar;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control displays a Help <see cref="Hint"/> when the mouse
    /// pointer rests momentarily on the control.
    /// </summary>
    {$Endregion}
    Property ShowHint;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the number of pixels between the image and the text of the control.
    /// </summary>
    {$Endregion}
    Property Spacing;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the touch manager component associated with the control.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property Touch;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether controls that sit below the label on a form can be seen
    /// through the label.
    /// </summary>
    {$Endregion}
    Property Transparent;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the vertical placement of the text within the label.
    /// </summary>
    {$Endregion}
    Property Layout;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control appears onscreen.
    /// </summary>
    {$Endregion}
    Property Visible;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets Specifies whether the label text wraps when it is too long for the
    /// width of the label.
    /// </summary>
    {$Endregion}
    Property WordWrap;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user clicks the control.
    /// </summary>
    {$Endregion}
    Property OnClick;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user right-clicks the control or otherwise invokes the pop-up
    /// menu (such as using the keyboard).
    /// </summary>
    {$Endregion}
    Property OnContextPopup;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user double-clicks the left mouse button when the mouse pointer
    /// is over the control.
    /// </summary>
    {$Endregion}
    Property OnDblClick;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user drops an object being dragged on the control.
    /// </summary>
    {$Endregion}
    Property OnDragDrop;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user drags an object over the control.
    /// </summary>
    {$Endregion}
    Property OnDragOver;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the dragging of an object ends, either by docking the object or
    /// by canceling the dragging.
    /// </summary>
    {$Endregion}
    Property OnEndDock;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the dragging of an object ends, either by dropping the object or
    /// by canceling the dragging.
    /// </summary>
    {$Endregion}
    Property OnEndDrag;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when user performs a gesture associated with the control.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property OnGesture;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user presses a mouse button with the mouse pointer over the
    /// control and the parent form is not active.
    /// </summary>
    {$Endregion}
    Property OnMouseActivate;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user presses a mouse button with the mouse pointer over the
    /// control.
    /// </summary>
    {$Endregion}
    Property OnMouseDown;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user moves the mouse pointer while the mouse pointer is over
    /// the control.
    /// </summary>
    {$Endregion}
    Property OnMouseMove;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user releases a mouse button that was pressed with the mouse
    /// pointer over the control.
    /// </summary>
    {$Endregion}
    Property OnMouseUp;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user moves the mouse into the control.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property OnMouseEnter;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user moves the mouse outside of the control.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property OnMouseLeave;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the mouse wheel is rotated.
    /// </summary>
    {$Endregion}
    Property OnMouseWheel;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the mouse wheel is rotated downward.
    /// </summary>
    {$Endregion}
    Property OnMouseWheelDown;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the mouse wheel is rotated upward.
    /// </summary>
    {$Endregion}
    Property OnMouseWheelUp;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs immediately after the control is resized.
    /// </summary>
    {$Endregion}
    Property OnResize;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user begins to drag the control with a <see cref="DragKind"/>
    /// of <see cref="DragKind.dkDock"/>.
    /// </summary>
    {$Endregion}
    Property OnStartDock;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user begins to drag the control with a <see cref="DragKind"/>
    /// of <see cref="DragKind.dkDrag"/>.
    /// </summary>
    {$Endregion}
    Property OnStartDrag;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TCustomDBCultureLabel is the base class for data-aware label controls that display
/// value of a locale field.
/// </summary>
/// <remarks>
/// Use TCustomDBCultureLabel as a base class when defining objects that display
/// value of a database field, where the field represents either a locale name or
/// a locale identifier.
/// </remarks>
{$Endregion}

  TCustomDBCultureLabel = Class(TCustomCultureLabel)
   Private
    fDataLink : TFieldDataLink;
    Procedure DataChange(Sender : TObject);
    Function GetCulture : TCultureInfo; Inline;
    Function GetDataField : WideString; Inline;
    Procedure SetDataField(Const Value : WideString); Inline;
    Function GetDataSource : TDataSource; Inline;
    Procedure SetDataSource(Value : TDataSource); Inline;
    Function GetField : TField;
    Procedure CMGetDataLink(Var Message : TMessage); Message CM_GETDATALINK;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Prevents <see cref="Culture"/> property to be saved and loaded.
    /// </summary>
    /// <param name="Filer">
    /// The current <see cref="TReader"/> or <see cref="TWriter"/> object that is
    /// loading or saving the published properties.
    /// </param>
    {$Endregion}
    Procedure DefineProperties(Filer : TFiler); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Updates the control when it is first loaded into memory.
    /// </summary>
    {$Endregion}
    Procedure Loaded; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Determines the string that appears as the text of the label.
    /// </summary>
    /// <returns>
    /// The text that appears on the label.
    /// </returns>
    {$Endregion}
    Function GetLabelText : String; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Determines the country flag icon that appears on the control.
    /// </summary>
    /// <returns>
    /// The index of a country flag icon or -1 if no icon should be displayed.
    /// </returns>
    {$Endregion}
    Function GetImageIndex : TImageIndex; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Sets the <see cref="AutoSize"/> property.
    /// </summary>
    /// <param name="Value">
    /// Indicates whether the auto size should be on or off.
    /// </param>
    {$Endregion}
    Procedure SetAutoSize(Value : Boolean); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Helps the data-aware control manage its link to the data source and respond
    /// to data events.
    /// </summary>
    {$Endregion}
    Property DataLink : TFieldDataLink Read fDataLink;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the name of the locale field that is represented by the control.
    /// </summary>
    {$Endregion}
    Property DataField : WideString Read GetDataField Write SetDataField;
    {$Region 'xmldoc'}
    /// <summary>
    /// Links the control to the dataset that contains the field it represents.
    /// </summary>
    {$Endregion}
    Property DataSource : TDataSource Read GetDataSource Write SetDataSource;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the control.
    /// </summary>
    /// <param name="AOwner">
    /// The owner component.
    /// </param>
    {$Endregion}
    Constructor Create(AOwner : TComponent); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Destroys the control and releases its allocated memory.
    /// </summary>
    {$Endregion}
    Destructor Destroy; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Specifies whether the control's alignment is in a right-to-left mode.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> if the control's alignment is in a right-to-left
    /// mode, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function UseRightToLeftAlignment : Boolean; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the <see cref="TField"/> object for the database field that the control
    /// represents.
    /// </summary>
    {$Endregion}
    Property Field : TField Read GetField;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the <see cref="TCultureInfo"/> object that the value of the locale field
    /// represents.
    /// </summary>
    {$Endregion}
    Property Culture : TCultureInfo Read GetCulture;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TDBCultureLabel is a data-aware label control that displays value of a locale
/// field.
/// </summary>
/// <remarks>
/// <para>
/// Use TDBCultureLabel to display value of a database field on a form, when the field
/// represents either a locale name or a locale identifier.
/// </para>
/// <para>
/// TDBCultureLabel publishes many of the properties, events, and methods of
/// <see cref="TCustomDBCultureLabel"/>, but does not introduce any new behavior.
/// </para>
/// </remarks>
/// <group name="Components"/>
{$Endregion}
{$IFDEF COMPILER_XE2_UP}

  [ComponentPlatformsAttribute(pidWin32 Or pidWin64)]
  {$ENDIF}
  TDBCultureLabel = Class(TCustomDBCultureLabel)
   Published
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets how the control aligns within its container (parent control).
    /// </summary>
    {$Endregion}
    Property Align;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the horizontal placement of the text within the label.
    /// </summary>
    {$Endregion}
    Property Alignment;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether a control should be constrained by <see cref="Margins"/>.
    /// </summary>
    {$Endregion}
    Property AlignWithMargins;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets how the control is anchored to its parent.
    /// </summary>
    {$Endregion}
    Property Anchors;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control sizes itself automatically to accommodate
    /// its contents.
    /// </summary>
    {$Endregion}
    Property AutoSize Default False;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the bidirectional mode for the control.
    /// </summary>
    {$Endregion}
    Property BiDiMode;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the color of the control's border.
    /// </summary>
    {$Endregion}
    Property BorderColor;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the width of the control's border.
    /// </summary>
    {$Endregion}
    Property BorderWidth;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the text of the label when the database field has no value or its
    /// value is not a valid locale name or locale identifer.
    /// </summary>
    {$Endregion}
    Property Caption;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the background color of the control.
    /// </summary>
    {$Endregion}
    Property Color Nodefault;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the size constraints for the control.
    /// </summary>
    {$Endregion}
    Property Constraints;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the name of the locale field that is represented by the control.
    /// </summary>
    {$Endregion}
    Property DataField;
    {$Region 'xmldoc'}
    /// <summary>
    /// Links the control to the dataset that contains the field it represents.
    /// </summary>
    {$Endregion}
    Property DataSource;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets which value of <see cref="TCultureInfo.DisplayNames"/> should be
    /// displayed as the text label on the control.
    /// </summary>
    {$Endregion}
    Property DisplayName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the image used to represent the mouse pointer when it passes
    /// into the region covered by the control.
    /// </summary>
    {$Endregion}
    Property DragCursor;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control is being dragged normally or for docking.
    /// </summary>
    {$Endregion}
    Property DragKind;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets how the control initiates drag-and-drop or drag-and-dock operations.
    /// </summary>
    {$Endregion}
    Property DragMode;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control responds to keyboard, mouse, and timer events.
    /// </summary>
    {$Endregion}
    Property Enabled;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the flag icons that can appear on the control.
    /// </summary>
    {$Endregion}
    Property Flags;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets a windowed control associated with the label.
    /// </summary>
    {$Endregion}
    Property FocusControl;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the attributes of text written on the control.
    /// </summary>
    {$Endregion}
    Property Font;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the radius of the glow around the label.
    /// NOTE: This feature is only available in Windows Vista and later.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property GlowSize;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the text string that can appear when the user moves the mouse over
    /// the control.
    /// </summary>
    {$Endregion}
    Property Hint;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the margins of the control.
    /// </summary>
    {$Endregion}
    Property Margins;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the distance between the image and the text from the control's border.
    /// </summary>
    {$Endregion}
    Property Padding;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="BiDiMode"/>.
    /// </summary>
    {$Endregion}
    Property ParentBiDiMode;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="Color"/>.
    /// </summary>
    {$Endregion}
    Property ParentColor;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="Font"/>.
    /// </summary>
    {$Endregion}
    Property ParentFont;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="ShowHint"/>.
    /// </summary>
    {$Endregion}
    Property ParentShowHint;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the pop-up menu associated with the control.
    /// </summary>
    {$Endregion}
    Property PopupMenu;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets how an ampersand in the label text is displayed.
    /// </summary>
    {$Endregion}
    Property ShowAccelChar;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control displays a Help <see cref="Hint"/> when the mouse
    /// pointer rests momentarily on the control.
    /// </summary>
    {$Endregion}
    Property ShowHint;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the number of pixels between the image and the text of the control.
    /// </summary>
    {$Endregion}
    Property Spacing;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the touch manager component associated with the control.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property Touch;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether controls that sit below the label on a form can be seen
    /// through the label.
    /// </summary>
    {$Endregion}
    Property Transparent;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the vertical placement of the text within the label.
    /// </summary>
    {$Endregion}
    Property Layout;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control appears onscreen.
    /// </summary>
    {$Endregion}
    Property Visible;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets Specifies whether the label text wraps when it is too long for the
    /// width of the label.
    /// </summary>
    {$Endregion}
    Property WordWrap;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user clicks the control.
    /// </summary>
    {$Endregion}
    Property OnClick;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user right-clicks the control or otherwise invokes the pop-up
    /// menu (such as using the keyboard).
    /// </summary>
    {$Endregion}
    Property OnContextPopup;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user double-clicks the left mouse button when the mouse pointer
    /// is over the control.
    /// </summary>
    {$Endregion}
    Property OnDblClick;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user drops an object being dragged on the control.
    /// </summary>
    {$Endregion}
    Property OnDragDrop;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user drags an object over the control.
    /// </summary>
    {$Endregion}
    Property OnDragOver;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the dragging of an object ends, either by docking the object or
    /// by canceling the dragging.
    /// </summary>
    {$Endregion}
    Property OnEndDock;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the dragging of an object ends, either by dropping the object or
    /// by canceling the dragging.
    /// </summary>
    {$Endregion}
    Property OnEndDrag;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when user performs a gesture associated with the control.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property OnGesture;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user presses a mouse button with the mouse pointer over the
    /// control and the parent form is not active.
    /// </summary>
    {$Endregion}
    Property OnMouseActivate;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user presses a mouse button with the mouse pointer over the
    /// control.
    /// </summary>
    {$Endregion}
    Property OnMouseDown;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user moves the mouse pointer while the mouse pointer is over
    /// the control.
    /// </summary>
    {$Endregion}
    Property OnMouseMove;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user releases a mouse button that was pressed with the mouse
    /// pointer over the control.
    /// </summary>
    {$Endregion}
    Property OnMouseUp;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user moves the mouse into the control.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property OnMouseEnter;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user moves the mouse outside of the control.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property OnMouseLeave;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the mouse wheel is rotated.
    /// </summary>
    {$Endregion}
    Property OnMouseWheel;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the mouse wheel is rotated downward.
    /// </summary>
    {$Endregion}
    Property OnMouseWheelDown;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the mouse wheel is rotated upward.
    /// </summary>
    {$Endregion}
    Property OnMouseWheelUp;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs immediately after the control is resized.
    /// </summary>
    {$Endregion}
    Property OnResize;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user begins to drag the control with a <see cref="DragKind"/>
    /// of <see cref="DragKind.dkDock"/>.
    /// </summary>
    {$Endregion}
    Property OnStartDock;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user begins to drag the control with a <see cref="DragKind"/>
    /// of <see cref="DragKind.dkDrag"/>.
    /// </summary>
    {$Endregion}
    Property OnStartDrag;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TCustomDBCultureBox is the base class for data-aware combo box controls that enable
/// users to choose value of a locale field from a list of <see cref="TCultureInfo"/>
/// objects.
/// </summary>
/// <remarks>
/// <para>
/// Use TCustomDBCultureBox as a base class when defining data-aware combo box controls
/// that provide a list of <see cref="TCultureInfo"/> objects to update value of a
/// database field.
/// </para>
/// <para>
/// The type of the database field must be either string or numeric to store respectively
/// the locale name or the locale identifier of the selected <see cref="TCultureInfo"/>
/// object.
/// </para>
/// </remarks>
{$Endregion}

  TCustomDBCultureBox = Class(TCustomCultureBox)
   Private
    fDataLink : TFieldDataLink;
    Function GetDataField : WideString; Inline;
    Procedure SetDataField(Const Value : WideString); Inline;
    Function GetDataSource : TDataSource; Inline;
    Procedure SetDataSource(Value : TDataSource); Inline;
    Function GetField : TField; Inline;
    Function GetReadOnly : Boolean; Inline;
    Procedure SetReadOnly(Value : Boolean); Inline;
    Procedure UpdateData(Sender : TObject);
    Procedure DataChange(Sender : TObject);
    Procedure CMExit(Var Message : TCMExit); Message CM_EXIT;
    Procedure CMGetDataLink(Var Message : TMessage); Message CM_GETDATALINK;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Prevents <see cref="ItemSelected"/> property to be saved and loaded.
    /// </summary>
    /// <param name="Filer">
    /// The current <see cref="TReader"/> or <see cref="TWriter"/> object that is
    /// loading or saving the published properties.
    /// </param>
    {$Endregion}
    Procedure DefineProperties(Filer : TFiler); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Updates the control when it is first loaded into memory.
    /// </summary>
    {$Endregion}
    Procedure Loaded; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Responds to the user's item selection.
    /// </summary>
    {$Endregion}
    Procedure Select; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Responds when the user presses a key.
    /// </summary>
    /// <param name="Key">
    /// The key that was pressed. If the method changes Key to 0, processing of the keystroke stops.
    /// </param>
    /// <param name="Shift">
    /// Indicates the concurrent state of the Ctrl, Shift, and Alt keys.
    /// </param>
    {$Endregion}
    Procedure KeyDown(Var Key : Word; Shift : TShiftState); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Responds when the user presses a key while the control has focus.
    /// </summary>
    /// <param name="Key">
    /// The key code of the key that was pressed.
    /// </param>
    {$Endregion}
    Procedure KeyPress(Var Key : Char); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Provides specific message responses for the control.
    /// </summary>
    /// <param name="Message">
    /// The message's details.
    /// </param>
    {$Endregion}
    Procedure WndProc(Var Message : TMessage); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Responds to changes in the <see cref="Items"/> property
    /// </summary>
    {$Endregion}
    Procedure DoItemsChange; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Helps the data-aware control manage its link to the data source and respond
    /// to data events.
    /// </summary>
    {$Endregion}
    Property DataLink : TFieldDataLink Read fDataLink;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the name of the locale field that is represented by the control.
    /// </summary>
    {$Endregion}
    Property DataField : WideString Read GetDataField Write SetDataField;
    {$Region 'xmldoc'}
    /// <summary>
    /// Links the control to the dataset that contains the field it represents.
    /// </summary>
    {$Endregion}
    Property DataSource : TDataSource Read GetDataSource Write SetDataSource;
    {$Region 'xmldoc'}
    /// <summary>
    /// Determines whether the user can change the field value using the control.
    /// </summary>
    {$Endregion}
    Property Readonly : Boolean Read GetReadOnly Write SetReadOnly Default False;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the control.
    /// </summary>
    /// <param name="AOwner">
    /// The owner component.
    /// </param>
    {$Endregion}
    Constructor Create(AOwner : TComponent); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Destroys the control and releases its allocated memory.
    /// </summary>
    {$Endregion}
    Destructor Destroy; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Invokes an action with the control as its target.
    /// </summary>
    /// <param name="Action">
    /// Specifies the action that was invoked.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the action was successfully dispatched,
    /// and <see langword="false"/> if the control could not handle the action.
    /// </returns>
    /// <seealso cref="UpdateAction"/>
    {$Endregion}
    Function ExecuteAction(Action : TBasicAction) : Boolean; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Updates an action to reflect the current state of the control.
    /// </summary>
    /// <param name="Action">
    /// Specifies the action that should be updated.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the action component now reflects the
    /// state of the control, and <see langword="false"/> if it did not know how
    /// to update the action.
    /// </returns>
    /// <seealso cref="ExecuteAction"/>
    {$Endregion}
    Function UpdateAction(Action : TBasicAction) : Boolean; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Specifies whether the control's alignment is in a right-to-left mode.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> if the control's alignment is in a right-to-left
    /// mode, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function UseRightToLeftAlignment : Boolean; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the <see cref="TField"/> object for the database field that the control
    /// represents.
    /// </summary>
    {$Endregion}
    Property Field : TField Read GetField;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TDBCultureBox is a data-aware combo box control that enables users to choose
/// value of a locale field from a list of <see cref="TCultureInfo"/> objects.
/// </summary>
/// <remarks>
/// <para>
/// Use TDBCultureBox to enable users to choose value of a database field, which represents
/// a locale name or a locale identifier, from a list of <see cref="TCultureInfo"/> objects.
/// </para>
/// <para>
/// The type of the database field must be either string or numeric to store respectively
/// the locale name or the locale identifier of the selected <see cref="TCultureInfo"/>
/// object.
/// </para>
/// <para>
/// TDBCultureBox publishes many of the properties, events, and methods of
/// <see cref="TCustomDBCultureBox"/>, but does not introduce any new behavior.
/// </para>
/// </remarks>
/// <group name="Components"/>
{$Endregion}
{$IFDEF COMPILER_XE2_UP}

  [ComponentPlatformsAttribute(pidWin32 Or pidWin64)]
  {$ENDIF}
  TDBCultureBox = Class(TCustomDBCultureBox)
   Published
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets how the control aligns within its container (parent control).
    /// </summary>
    {$Endregion}
    Property Align;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether a control should be constrained by <see cref="Margins"/>.
    /// </summary>
    {$Endregion}
    Property AlignWithMargins;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets how the control is anchored to its parent.
    /// </summary>
    {$Endregion}
    Property Anchors;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the user can give focus to items by typing in the list.
    /// </summary>
    {$Endregion}
    Property AutoComplete;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the delay between a key press and an attempt to <see cref="AutoComplete"/>.
    /// </summary>
    {$Endregion}
    Property AutoCompleteDelay;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the drop-down closes up automatically when the user selects an item.
    /// </summary>
    {$Endregion}
    Property AutoCloseUp;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the drop-down list drops down automatically in response to user keystrokes.
    /// </summary>
    {$Endregion}
    Property AutoDropDown;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets which edges of the control are beveled.
    /// </summary>
    {$Endregion}
    Property BevelEdges;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the cut of the inner bevel.
    /// </summary>
    {$Endregion}
    Property BevelInner;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the control's bevel style.
    /// </summary>
    {$Endregion}
    Property BevelKind;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the cut of the outer bevel.
    /// </summary>
    {$Endregion}
    Property BevelOuter;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the bidirectional mode for the control.
    /// </summary>
    {$Endregion}
    Property BiDiMode;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the background color of the control.
    /// </summary>
    {$Endregion}
    Property Color Nodefault;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the size constraints for the control.
    /// </summary>
    {$Endregion}
    Property Constraints;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control has a three-dimensional look.
    /// </summary>
    {$Endregion}
    Property Ctl3D;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the name of the locale field that is represented by the control.
    /// </summary>
    {$Endregion}
    Property DataField;
    {$Region 'xmldoc'}
    /// <summary>
    /// Links the control to the dataset that contains the field it represents.
    /// </summary>
    {$Endregion}
    Property DataSource;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets which value of <see cref="TCultureInfo.DisplayNames"/> should be
    /// displayed as the label of items.
    /// </summary>
    {$Endregion}
    Property DisplayName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control's image is rendered directly to the window or
    /// painted to an in-memory bitmap first.
    /// </summary>
    {$Endregion}
    Property DoubleBuffered;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the image used to represent the mouse pointer when it passes
    /// into the region covered by the control.
    /// </summary>
    {$Endregion}
    Property DragCursor;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control is being dragged normally or for docking.
    /// </summary>
    {$Endregion}
    Property DragKind;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets how the control initiates drag-and-drop or drag-and-dock operations.
    /// </summary>
    {$Endregion}
    Property DragMode;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the maximum number of items displayed in the drop-down list.
    /// </summary>
    {$Endregion}
    Property DropDownCount;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control responds to keyboard, mouse, and timer events.
    /// </summary>
    {$Endregion}
    Property Enabled;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the placement of the flag icon in regard of the text label.
    /// </summary>
    {$Endregion}
    Property FlagPosition;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the flag icons that can appear on the control.
    /// </summary>
    {$Endregion}
    Property Flags;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the attributes of text written on the control.
    /// </summary>
    {$Endregion}
    Property Font;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the text string that can appear when the user moves the mouse over
    /// the control.
    /// </summary>
    {$Endregion}
    Property Hint;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the behavior of the input method editor (IME).
    /// </summary>
    {$Endregion}
    Property ImeMode;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the input method editor (IME) to use for converting keyboard input.
    /// </summary>
    {$Endregion}
    Property ImeName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the <see cref="TCultureInfo"/> objects in the control.
    /// </summary>
    {$Endregion}
    Property Items;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the margins of the control.
    /// </summary>
    {$Endregion}
    Property Margins;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="BiDiMode"/>.
    /// </summary>
    {$Endregion}
    Property ParentBiDiMode;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="Color"/>.
    /// </summary>
    {$Endregion}
    Property ParentColor;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="Ctl3D"/>.
    /// </summary>
    {$Endregion}
    Property ParentCtl3D;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="DoubleBuffered"/>.
    /// </summary>
    {$Endregion}
    Property ParentDoubleBuffered;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="Font"/>.
    /// </summary>
    {$Endregion}
    Property ParentFont;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="ShowHint"/>.
    /// </summary>
    {$Endregion}
    Property ParentShowHint;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the pop-up menu associated with the control.
    /// </summary>
    {$Endregion}
    Property PopupMenu;
    {$Region 'xmldoc'}
    /// <summary>
    /// Determines whether the user can change the field value using the control.
    /// </summary>
    {$Endregion}
    Property Readonly;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control displays a Help <see cref="Hint"/> when the mouse
    /// pointer rests momentarily on the control.
    /// </summary>
    {$Endregion}
    Property ShowHint;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the items in the list are arranged alphabetically.
    /// </summary>
    {$Endregion}
    Property Sorted;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the position of the control in its parent's tab order.
    /// </summary>
    {$Endregion}
    Property TabOrder;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the user can tab to a control.
    /// </summary>
    {$Endregion}
    Property TabStop;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets thet text that is displayed as a text watermark in the control.
    /// NOTE: This feature is only available in Windows Vista and later.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property TextHint;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the touch manager component associated with the control.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property Touch;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control appears onscreen.
    /// </summary>
    {$Endregion}
    Property Visible;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user clicks the control.
    /// </summary>
    {$Endregion}
    Property OnClick;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the drop-down list closes up due to some user action.
    /// </summary>
    {$Endregion}
    Property OnCloseUp;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user right-clicks the control or otherwise invokes the pop-up
    /// menu (such as using the keyboard).
    /// </summary>
    {$Endregion}
    Property OnContextPopup;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user double-clicks the left mouse button when the mouse pointer
    /// is over the control.
    /// </summary>
    {$Endregion}
    Property OnDblClick;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user drops an object being dragged on the control.
    /// </summary>
    {$Endregion}
    Property OnDragDrop;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user drags an object over the control.
    /// </summary>
    {$Endregion}
    Property OnDragOver;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when text label of an item needs to be displayed.
    /// </summary>
    {$Endregion}
    Property OnDrawItemLabel;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user opens the drop-down list.
    /// </summary>
    {$Endregion}
    Property OnDropDown;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the dragging of an object ends, either by docking the object or
    /// by canceling the dragging.
    /// </summary>
    {$Endregion}
    Property OnEndDock;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the dragging of an object ends, either by dropping the object or
    /// by canceling the dragging.
    /// </summary>
    {$Endregion}
    Property OnEndDrag;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when a control receives the input focus.
    /// </summary>
    {$Endregion}
    Property OnEnter;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the input focus shifts away from one control to another.
    /// </summary>
    {$Endregion}
    Property OnExit;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when user performs a gesture associated with the control.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property OnGesture;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when <see cref="Items"/> property changed.
    /// </summary>
    {$Endregion}
    Property OnItemsChange;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when a user presses any key while the control has focus.
    /// </summary>
    {$Endregion}
    Property OnKeyDown;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when key pressed.
    /// </summary>
    {$Endregion}
    Property OnKeyPress;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user releases a key that has been pressed.
    /// </summary>
    {$Endregion}
    Property OnKeyUp;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user presses a mouse button with the mouse pointer over the
    /// control and the parent form is not active.
    /// </summary>
    {$Endregion}
    Property OnMouseActivate;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user presses a mouse button with the mouse pointer over the
    /// control.
    /// </summary>
    {$Endregion}
    Property OnMouseDown;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user moves the mouse pointer while the mouse pointer is over
    /// the control.
    /// </summary>
    {$Endregion}
    Property OnMouseMove;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user releases a mouse button that was pressed with the mouse
    /// pointer over the control.
    /// </summary>
    {$Endregion}
    Property OnMouseUp;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user moves the mouse into the control.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property OnMouseEnter;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user moves the mouse outside of the control.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property OnMouseLeave;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the mouse wheel is rotated.
    /// </summary>
    {$Endregion}
    Property OnMouseWheel;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the mouse wheel is rotated downward.
    /// </summary>
    {$Endregion}
    Property OnMouseWheelDown;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the mouse wheel is rotated upward.
    /// </summary>
    {$Endregion}
    Property OnMouseWheelUp;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs immediately after the control is resized.
    /// </summary>
    {$Endregion}
    Property OnResize;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user selects an item in the drop-down list
    /// </summary>
    {$Endregion}
    Property OnSelect;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user begins to drag the control with a <see cref="DragKind"/>
    /// of <see cref="DragKind.dkDock"/>.
    /// </summary>
    {$Endregion}
    Property OnStartDock;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user begins to drag the control with a <see cref="DragKind"/>
    /// of <see cref="DragKind.dkDrag"/>.
    /// </summary>
    {$Endregion}
    Property OnStartDrag;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TCustomDBCultureListBox is the base class for data-aware list box controls that
/// enable users to choose value of a locale field from a list of <see cref="TCultureInfo"/>
/// objects.
/// </summary>
/// <remarks>
/// <para>
/// Use TCustomDBCultureListBox as a base class when defining data-aware list box controls
/// that provide a list of <see cref="TCultureInfo"/> objects to update value of a database
/// field.
/// </para>
/// <para>
/// The type of the database field must be either string or numeric to store respectively
/// the locale name or the locale identifier of the selected <see cref="TCultureInfo"/>
/// object.
/// </para>
/// </remarks>
{$Endregion}

  TCustomDBCultureListBox = Class(TCustomCultureListBox)
   Private
    fDataLink : TFieldDataLink;
    Function GetDataField : WideString; Inline;
    Procedure SetDataField(Const Value : WideString); Inline;
    Function GetDataSource : TDataSource; Inline;
    Procedure SetDataSource(Value : TDataSource); Inline;
    Function GetField : TField; Inline;
    Function GetReadOnly : Boolean; Inline;
    Procedure SetReadOnly(Value : Boolean); Inline;
    Procedure UpdateData(Sender : TObject);
    Procedure DataChange(Sender : TObject);
    Procedure CMExit(Var Message : TCMExit); Message CM_EXIT;
    Procedure CMGetDataLink(Var Message : TMessage); Message CM_GETDATALINK;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Prevents <see cref="ItemSelected"/> property to be saved and loaded.
    /// </summary>
    /// <param name="Filer">
    /// The current <see cref="TReader"/> or <see cref="TWriter"/> object that is
    /// loading or saving the published properties.
    /// </param>
    {$Endregion}
    Procedure DefineProperties(Filer : TFiler); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Updates the control when it is first loaded into memory.
    /// </summary>
    {$Endregion}
    Procedure Loaded; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Responds to mouse clicks.
    /// </summary>
    {$Endregion}
    Procedure Click; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Responds when the user presses a key.
    /// </summary>
    /// <param name="Key">
    /// The key that was pressed. If the method changes Key to 0, processing of the keystroke stops.
    /// </param>
    /// <param name="Shift">
    /// Indicates the concurrent state of the Ctrl, Shift, and Alt keys.
    /// </param>
    {$Endregion}
    Procedure KeyDown(Var Key : Word; Shift : TShiftState); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Responds when the user presses a key while the control has focus.
    /// </summary>
    /// <param name="Key">
    /// The key code of the key that was pressed.
    /// </param>
    {$Endregion}
    Procedure KeyPress(Var Key : Char); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Provides specific message responses for the control.
    /// </summary>
    /// <param name="Message">
    /// The message's details.
    /// </param>
    {$Endregion}
    Procedure WndProc(Var Message : TMessage); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Responds to changes in the <see cref="Items"/> property
    /// </summary>
    {$Endregion}
    Procedure DoItemsChange; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Helps the data-aware control manage its link to the data source and respond
    /// to data events.
    /// </summary>
    {$Endregion}
    Property DataLink : TFieldDataLink Read fDataLink;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the name of the locale field that is represented by the control.
    /// </summary>
    {$Endregion}
    Property DataField : WideString Read GetDataField Write SetDataField;
    {$Region 'xmldoc'}
    /// <summary>
    /// Links the control to the dataset that contains the field it represents.
    /// </summary>
    {$Endregion}
    Property DataSource : TDataSource Read GetDataSource Write SetDataSource;
    {$Region 'xmldoc'}
    /// <summary>
    /// Determines whether the user can change the field value using the control.
    /// </summary>
    {$Endregion}
    Property Readonly : Boolean Read GetReadOnly Write SetReadOnly Default False;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the control.
    /// </summary>
    /// <param name="AOwner">
    /// The owner component.
    /// </param>
    {$Endregion}
    Constructor Create(AOwner : TComponent); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Destroys the control and releases its allocated memory.
    /// </summary>
    {$Endregion}
    Destructor Destroy; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Invokes an action with the control as its target.
    /// </summary>
    /// <param name="Action">
    /// Specifies the action that was invoked.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the action was successfully dispatched,
    /// and <see langword="false"/> if the control could not handle the action.
    /// </returns>
    /// <seealso cref="UpdateAction"/>
    {$Endregion}
    Function ExecuteAction(Action : TBasicAction) : Boolean; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Updates an action to reflect the current state of the control.
    /// </summary>
    /// <param name="Action">
    /// Specifies the action that should be updated.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the action component now reflects the
    /// state of the control, and <see langword="false"/> if it did not know how
    /// to update the action.
    /// </returns>
    /// <seealso cref="ExecuteAction"/>
    {$Endregion}
    Function UpdateAction(Action : TBasicAction) : Boolean; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Specifies whether the control's alignment is in a right-to-left mode.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> if the control's alignment is in a right-to-left
    /// mode, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function UseRightToLeftAlignment : Boolean; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the <see cref="TField"/> object for the database field that the control
    /// represents.
    /// </summary>
    {$Endregion}
    Property Field : TField Read GetField;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TDBCultureListBox is a data-aware list box control that enables users to choose
/// value of a locale field from a list of <see cref="TCultureInfo"/> objects.
/// </summary>
/// <remarks>
/// <para>
/// Use TDBCultureListBox to enable users to choose value of a database field, which represents
/// a locale name or a locale identifier, from a list of <see cref="TCultureInfo"/> objects.
/// </para>
/// <para>
/// The type of the database field must be either string or numeric to store respectively
/// the locale name or the locale identifier of the selected <see cref="TCultureInfo"/>
/// object.
/// </para>
/// <para>
/// TDBCultureListBox publishes many of the properties, events, and methods of
/// <see cref="TCustomDBCultureListBox"/>, but does not introduce any new behavior.
/// </para>
/// </remarks>
/// <group name="Components"/>
{$Endregion}
{$IFDEF COMPILER_XE2_UP}

  [ComponentPlatformsAttribute(pidWin32 Or pidWin64)]
  {$ENDIF}
  TDBCultureListBox = Class(TCustomDBCultureListBox)
   Published
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets how the control aligns within its container (parent control).
    /// </summary>
    {$Endregion}
    Property Align;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether a control should be constrained by <see cref="Margins"/>.
    /// </summary>
    {$Endregion}
    Property AlignWithMargins;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets how the control is anchored to its parent.
    /// </summary>
    {$Endregion}
    Property Anchors;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the user can give focus to items by typing in the list.
    /// </summary>
    {$Endregion}
    Property AutoComplete;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the delay between a key press and an attempt to <see cref="AutoComplete"/>.
    /// </summary>
    {$Endregion}
    Property AutoCompleteDelay;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets which edges of the control are beveled.
    /// </summary>
    {$Endregion}
    Property BevelEdges;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the cut of the inner bevel.
    /// </summary>
    {$Endregion}
    Property BevelInner;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the control's bevel style.
    /// </summary>
    {$Endregion}
    Property BevelKind;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the cut of the outer bevel.
    /// </summary>
    {$Endregion}
    Property BevelOuter;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the bidirectional mode for the control.
    /// </summary>
    {$Endregion}
    Property BiDiMode;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control has a border.
    /// </summary>
    {$Endregion}
    Property BorderStyle;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the background color of the control.
    /// </summary>
    {$Endregion}
    Property Color Nodefault;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the size constraints for the control.
    /// </summary>
    {$Endregion}
    Property Constraints;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control has a three-dimensional look.
    /// </summary>
    {$Endregion}
    Property Ctl3D;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the number of columns, in a multi-column list box, that are visible
    /// without having to scroll.
    /// </summary>
    {$Endregion}
    Property Columns;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the name of the locale field that is represented by the control.
    /// </summary>
    {$Endregion}
    Property DataField;
    {$Region 'xmldoc'}
    /// <summary>
    /// Links the control to the dataset that contains the field it represents.
    /// </summary>
    {$Endregion}
    Property DataSource;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets which value of <see cref="TCultureInfo.DisplayNames"/> should be
    /// displayed as the label of items.
    /// </summary>
    {$Endregion}
    Property DisplayName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control's image is rendered directly to the window or
    /// painted to an in-memory bitmap first.
    /// </summary>
    {$Endregion}
    Property DoubleBuffered;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the image used to represent the mouse pointer when it passes
    /// into the region covered by the control.
    /// </summary>
    {$Endregion}
    Property DragCursor;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control is being dragged normally or for docking.
    /// </summary>
    {$Endregion}
    Property DragKind;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets how the control initiates drag-and-drop or drag-and-dock operations.
    /// </summary>
    {$Endregion}
    Property DragMode;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control responds to keyboard, mouse, and timer events.
    /// </summary>
    {$Endregion}
    Property Enabled;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the placement of the flag icon in regard of the text label.
    /// </summary>
    {$Endregion}
    Property FlagPosition;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the flag icons that can appear on the control.
    /// </summary>
    {$Endregion}
    Property Flags;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the attributes of text written on the control.
    /// </summary>
    {$Endregion}
    Property Font;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the text string that can appear when the user moves the mouse over
    /// the control.
    /// </summary>
    {$Endregion}
    Property Hint;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the behavior of the input method editor (IME).
    /// </summary>
    {$Endregion}
    Property ImeMode;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the input method editor (IME) to use for converting keyboard input.
    /// </summary>
    {$Endregion}
    Property ImeName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the list box displays the partial items.
    /// </summary>
    {$Endregion}
    Property IntegralHeight;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the <see cref="TCultureInfo"/> objects in the control.
    /// </summary>
    {$Endregion}
    Property Items;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the margins of the control.
    /// </summary>
    {$Endregion}
    Property Margins;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="BiDiMode"/>.
    /// </summary>
    {$Endregion}
    Property ParentBiDiMode;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="Color"/>.
    /// </summary>
    {$Endregion}
    Property ParentColor;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="Ctl3D"/>.
    /// </summary>
    {$Endregion}
    Property ParentCtl3D;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="DoubleBuffered"/>.
    /// </summary>
    {$Endregion}
    Property ParentDoubleBuffered;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="Font"/>.
    /// </summary>
    {$Endregion}
    Property ParentFont;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="ShowHint"/>.
    /// </summary>
    {$Endregion}
    Property ParentShowHint;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the pop-up menu associated with the control.
    /// </summary>
    {$Endregion}
    Property PopupMenu;
    {$Region 'xmldoc'}
    /// <summary>
    /// Determines whether the user can change the field value using the control.
    /// </summary>
    {$Endregion}
    Property Readonly;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the width, in pixels, by which the list box can scroll horizontally.
    /// </summary>
    {$Endregion}
    Property ScrollWidth;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control displays a Help <see cref="Hint"/> when the mouse
    /// pointer rests momentarily on the control.
    /// </summary>
    {$Endregion}
    Property ShowHint;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the items in the list are arranged alphabetically.
    /// </summary>
    {$Endregion}
    Property Sorted;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the position of the control in its parent's tab order.
    /// </summary>
    {$Endregion}
    Property TabOrder;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the user can tab to a control.
    /// </summary>
    {$Endregion}
    Property TabStop;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the size of the tabs in the list box.
    /// </summary>
    {$Endregion}
    Property TabWidth;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the touch manager component associated with the control.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property Touch;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control appears onscreen.
    /// </summary>
    {$Endregion}
    Property Visible;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user clicks the control.
    /// </summary>
    {$Endregion}
    Property OnClick;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user right-clicks the control or otherwise invokes the pop-up
    /// menu (such as using the keyboard).
    /// </summary>
    {$Endregion}
    Property OnContextPopup;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user double-clicks the left mouse button when the mouse pointer
    /// is over the control.
    /// </summary>
    {$Endregion}
    Property OnDblClick;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user drops an object being dragged on the control.
    /// </summary>
    {$Endregion}
    Property OnDragDrop;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user drags an object over the control.
    /// </summary>
    {$Endregion}
    Property OnDragOver;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when text label of an item needs to be displayed.
    /// </summary>
    {$Endregion}
    Property OnDrawItemLabel;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the dragging of an object ends, either by docking the object or
    /// by canceling the dragging.
    /// </summary>
    {$Endregion}
    Property OnEndDock;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the dragging of an object ends, either by dropping the object or
    /// by canceling the dragging.
    /// </summary>
    {$Endregion}
    Property OnEndDrag;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when a control receives the input focus.
    /// </summary>
    {$Endregion}
    Property OnEnter;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the input focus shifts away from one control to another.
    /// </summary>
    {$Endregion}
    Property OnExit;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when user performs a gesture associated with the control.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property OnGesture;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when <see cref="Items"/> property changed.
    /// </summary>
    {$Endregion}
    Property OnItemsChange;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when a user presses any key while the control has focus.
    /// </summary>
    {$Endregion}
    Property OnKeyDown;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when key pressed.
    /// </summary>
    {$Endregion}
    Property OnKeyPress;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user releases a key that has been pressed.
    /// </summary>
    {$Endregion}
    Property OnKeyUp;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user presses a mouse button with the mouse pointer over the
    /// control and the parent form is not active.
    /// </summary>
    {$Endregion}
    Property OnMouseActivate;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user presses a mouse button with the mouse pointer over the
    /// control.
    /// </summary>
    {$Endregion}
    Property OnMouseDown;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user moves the mouse pointer while the mouse pointer is over
    /// the control.
    /// </summary>
    {$Endregion}
    Property OnMouseMove;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user releases a mouse button that was pressed with the mouse
    /// pointer over the control.
    /// </summary>
    {$Endregion}
    Property OnMouseUp;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user moves the mouse into the control.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property OnMouseEnter;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user moves the mouse outside of the control.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property OnMouseLeave;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the mouse wheel is rotated.
    /// </summary>
    {$Endregion}
    Property OnMouseWheel;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the mouse wheel is rotated downward.
    /// </summary>
    {$Endregion}
    Property OnMouseWheelDown;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the mouse wheel is rotated upward.
    /// </summary>
    {$Endregion}
    Property OnMouseWheelUp;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs immediately after the control is resized.
    /// </summary>
    {$Endregion}
    Property OnResize;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user begins to drag the control with a <see cref="DragKind"/>
    /// of <see cref="DragKind.dkDock"/>.
    /// </summary>
    {$Endregion}
    Property OnStartDock;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user begins to drag the control with a <see cref="DragKind"/>
    /// of <see cref="DragKind.dkDrag"/>.
    /// </summary>
    {$Endregion}
    Property OnStartDrag;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TCustomDBTerritoryLabel is the base class for data-aware label controls that
/// display value of a country field.
/// </summary>
/// <remarks>
/// Use TCustomDBTerritoryLabel as a base class when defining objects that display
/// value of a database field, where the field represents either an international
/// country code or a geographical identifier.
/// </remarks>
{$Endregion}

  TCustomDBTerritoryLabel = Class(TCustomTerritoryLabel)
   Private
    fDataLink : TFieldDataLink;
    Procedure DataChange(Sender : TObject);
    Function GetTerritory : TTerritoryInfo; Inline;
    Function GetDataField : WideString; Inline;
    Procedure SetDataField(Const Value : WideString); Inline;
    Function GetDataSource : TDataSource; Inline;
    Procedure SetDataSource(Value : TDataSource); Inline;
    Function GetField : TField;
    Procedure CMGetDataLink(Var Message : TMessage); Message CM_GETDATALINK;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Prevents <see cref="Territory"/> property to be saved and loaded.
    /// </summary>
    /// <param name="Filer">
    /// The current <see cref="TReader"/> or <see cref="TWriter"/> object that is
    /// loading or saving the published properties.
    /// </param>
    {$Endregion}
    Procedure DefineProperties(Filer : TFiler); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Updates the control when it is first loaded into memory.
    /// </summary>
    {$Endregion}
    Procedure Loaded; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Determines the string that appears as the text of the label.
    /// </summary>
    /// <returns>
    /// The text that appears on the label.
    /// </returns>
    {$Endregion}
    Function GetLabelText : String; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Determines the country flag icon that appears on the control.
    /// </summary>
    /// <returns>
    /// The index of a country flag icon or -1 if no icon should be displayed.
    /// </returns>
    {$Endregion}
    Function GetImageIndex : TImageIndex; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Sets the <see cref="AutoSize"/> property.
    /// </summary>
    /// <param name="Value">
    /// Indicates whether the auto size should be on or off.
    /// </param>
    {$Endregion}
    Procedure SetAutoSize(Value : Boolean); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Helps the data-aware control manage its link to the data source and respond
    /// to data events.
    /// </summary>
    {$Endregion}
    Property DataLink : TFieldDataLink Read fDataLink;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the name of the country field that is represented by the control.
    /// </summary>
    {$Endregion}
    Property DataField : WideString Read GetDataField Write SetDataField;
    {$Region 'xmldoc'}
    /// <summary>
    /// Links the control to the dataset that contains the field it represents.
    /// </summary>
    {$Endregion}
    Property DataSource : TDataSource Read GetDataSource Write SetDataSource;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the control.
    /// </summary>
    /// <param name="AOwner">
    /// The owner component.
    /// </param>
    {$Endregion}
    Constructor Create(AOwner : TComponent); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Destroys the control and releases its allocated memory.
    /// </summary>
    {$Endregion}
    Destructor Destroy; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Specifies whether the control's alignment is in a right-to-left mode.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> if the control's alignment is in a right-to-left
    /// mode, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function UseRightToLeftAlignment : Boolean; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the <see cref="TField"/> object for the database field that the control
    /// represents.
    /// </summary>
    {$Endregion}
    Property Field : TField Read GetField;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the <see cref="TTerritoryInfo"/> object that the value of the country field
    /// represents.
    /// </summary>
    {$Endregion}
    Property Territory : TTerritoryInfo Read GetTerritory;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TDBTerritoryLabel is a data-aware label control that displays value of a country
/// field.
/// </summary>
/// <remarks>
/// <para>
/// Use TDBTerritoryLabel to display value of a database field on a form, when the field
/// represents either an international country code or a geographical identifier.
/// </para>
/// <para>
/// TDBTerritoryLabel publishes many of the properties, events, and methods of
/// <see cref="TCustomDBTerritoryLabel"/>, but does not introduce any new behavior.
/// </para>
/// </remarks>
/// <group name="Components"/>
{$Endregion}
{$IFDEF COMPILER_XE2_UP}

  [ComponentPlatformsAttribute(pidWin32 Or pidWin64)]
  {$ENDIF}
  TDBTerritoryLabel = Class(TCustomDBTerritoryLabel)
   Published
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets how the control aligns within its container (parent control).
    /// </summary>
    {$Endregion}
    Property Align;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the horizontal placement of the text within the label.
    /// </summary>
    {$Endregion}
    Property Alignment;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether a control should be constrained by <see cref="Margins"/>.
    /// </summary>
    {$Endregion}
    Property AlignWithMargins;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets how the control is anchored to its parent.
    /// </summary>
    {$Endregion}
    Property Anchors;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control sizes itself automatically to accommodate
    /// its contents.
    /// </summary>
    {$Endregion}
    Property AutoSize Default False;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the bidirectional mode for the control.
    /// </summary>
    {$Endregion}
    Property BiDiMode;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the color of the control's border.
    /// </summary>
    {$Endregion}
    Property BorderColor;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the width of the control's border.
    /// </summary>
    {$Endregion}
    Property BorderWidth;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the text of the label when the database field has no value or its
    /// value is not a valid international country code or geographical identifer.
    /// </summary>
    {$Endregion}
    Property Caption;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the background color of the control.
    /// </summary>
    {$Endregion}
    Property Color Nodefault;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the size constraints for the control.
    /// </summary>
    {$Endregion}
    Property Constraints;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the name of the country field that is represented by the control.
    /// </summary>
    {$Endregion}
    Property DataField;
    {$Region 'xmldoc'}
    /// <summary>
    /// Links the control to the dataset that contains the field it represents.
    /// </summary>
    {$Endregion}
    Property DataSource;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets which value of <see cref="TTerritoryInfo.DisplayNames"/> should be
    /// displayed as the text label on the control.
    /// </summary>
    {$Endregion}
    Property DisplayName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the image used to represent the mouse pointer when it passes
    /// into the region covered by the control.
    /// </summary>
    {$Endregion}
    Property DragCursor;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control is being dragged normally or for docking.
    /// </summary>
    {$Endregion}
    Property DragKind;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets how the control initiates drag-and-drop or drag-and-dock operations.
    /// </summary>
    {$Endregion}
    Property DragMode;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control responds to keyboard, mouse, and timer events.
    /// </summary>
    {$Endregion}
    Property Enabled;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the flag icons that can appear on the control.
    /// </summary>
    {$Endregion}
    Property Flags;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets a windowed control associated with the label.
    /// </summary>
    {$Endregion}
    Property FocusControl;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the attributes of text written on the control.
    /// </summary>
    {$Endregion}
    Property Font;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the radius of the glow around the label.
    /// NOTE: This feature is only available in Windows Vista and later.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property GlowSize;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the text string that can appear when the user moves the mouse over
    /// the control.
    /// </summary>
    {$Endregion}
    Property Hint;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the margins of the control.
    /// </summary>
    {$Endregion}
    Property Margins;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the distance between the image and the text from the control's border.
    /// </summary>
    {$Endregion}
    Property Padding;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="BiDiMode"/>.
    /// </summary>
    {$Endregion}
    Property ParentBiDiMode;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="Color"/>.
    /// </summary>
    {$Endregion}
    Property ParentColor;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="Font"/>.
    /// </summary>
    {$Endregion}
    Property ParentFont;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="ShowHint"/>.
    /// </summary>
    {$Endregion}
    Property ParentShowHint;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the pop-up menu associated with the control.
    /// </summary>
    {$Endregion}
    Property PopupMenu;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets how an ampersand in the label text is displayed.
    /// </summary>
    {$Endregion}
    Property ShowAccelChar;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control displays a Help <see cref="Hint"/> when the mouse
    /// pointer rests momentarily on the control.
    /// </summary>
    {$Endregion}
    Property ShowHint;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the number of pixels between the image and the text of the control.
    /// </summary>
    {$Endregion}
    Property Spacing;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the touch manager component associated with the control.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property Touch;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether controls that sit below the label on a form can be seen
    /// through the label.
    /// </summary>
    {$Endregion}
    Property Transparent;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the vertical placement of the text within the label.
    /// </summary>
    {$Endregion}
    Property Layout;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control appears onscreen.
    /// </summary>
    {$Endregion}
    Property Visible;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets Specifies whether the label text wraps when it is too long for the
    /// width of the label.
    /// </summary>
    {$Endregion}
    Property WordWrap;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user clicks the control.
    /// </summary>
    {$Endregion}
    Property OnClick;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user right-clicks the control or otherwise invokes the pop-up
    /// menu (such as using the keyboard).
    /// </summary>
    {$Endregion}
    Property OnContextPopup;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user double-clicks the left mouse button when the mouse pointer
    /// is over the control.
    /// </summary>
    {$Endregion}
    Property OnDblClick;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user drops an object being dragged on the control.
    /// </summary>
    {$Endregion}
    Property OnDragDrop;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user drags an object over the control.
    /// </summary>
    {$Endregion}
    Property OnDragOver;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the dragging of an object ends, either by docking the object or
    /// by canceling the dragging.
    /// </summary>
    {$Endregion}
    Property OnEndDock;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the dragging of an object ends, either by dropping the object or
    /// by canceling the dragging.
    /// </summary>
    {$Endregion}
    Property OnEndDrag;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when user performs a gesture associated with the control.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property OnGesture;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user presses a mouse button with the mouse pointer over the
    /// control and the parent form is not active.
    /// </summary>
    {$Endregion}
    Property OnMouseActivate;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user presses a mouse button with the mouse pointer over the
    /// control.
    /// </summary>
    {$Endregion}
    Property OnMouseDown;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user moves the mouse pointer while the mouse pointer is over
    /// the control.
    /// </summary>
    {$Endregion}
    Property OnMouseMove;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user releases a mouse button that was pressed with the mouse
    /// pointer over the control.
    /// </summary>
    {$Endregion}
    Property OnMouseUp;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user moves the mouse into the control.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property OnMouseEnter;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user moves the mouse outside of the control.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property OnMouseLeave;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the mouse wheel is rotated.
    /// </summary>
    {$Endregion}
    Property OnMouseWheel;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the mouse wheel is rotated downward.
    /// </summary>
    {$Endregion}
    Property OnMouseWheelDown;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the mouse wheel is rotated upward.
    /// </summary>
    {$Endregion}
    Property OnMouseWheelUp;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs immediately after the control is resized.
    /// </summary>
    {$Endregion}
    Property OnResize;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user begins to drag the control with a <see cref="DragKind"/>
    /// of <see cref="DragKind.dkDock"/>.
    /// </summary>
    {$Endregion}
    Property OnStartDock;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user begins to drag the control with a <see cref="DragKind"/>
    /// of <see cref="DragKind.dkDrag"/>.
    /// </summary>
    {$Endregion}
    Property OnStartDrag;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TCustomDBTerritoryBox is the base class for data-aware combo box controls that enable
/// users to choose value of a country field from a list of <see cref="TTerritoryInfo"/>
/// objects.
/// </summary>
/// <remarks>
/// <para>
/// Use TCustomDBTerritoryBox as a base class when defining data-aware combo box controls
/// that provide a list of <see cref="TTerritoryInfo"/> objects to update value of a database
/// field.
/// </para>
/// <para>
/// The type of the database field must be either string (size of 2 or 3 characters) or numeric
/// to store respectively the international country code or the geographical identifier of the
/// selected <see cref="TTerritoryInfo"/> object.
/// </para>
/// </remarks>
{$Endregion}

  TCustomDBTerritoryBox = Class(TCustomTerritoryBox)
   Private
    fDataLink : TFieldDataLink;
    Function GetDataField : WideString; Inline;
    Procedure SetDataField(Const Value : WideString); Inline;
    Function GetDataSource : TDataSource; Inline;
    Procedure SetDataSource(Value : TDataSource); Inline;
    Function GetField : TField; Inline;
    Function GetReadOnly : Boolean; Inline;
    Procedure SetReadOnly(Value : Boolean); Inline;
    Procedure UpdateData(Sender : TObject);
    Procedure DataChange(Sender : TObject);
    Procedure CMExit(Var Message : TCMExit); Message CM_EXIT;
    Procedure CMGetDataLink(Var Message : TMessage); Message CM_GETDATALINK;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Prevents <see cref="ItemSelected"/> property to be saved and loaded.
    /// </summary>
    /// <param name="Filer">
    /// The current <see cref="TReader"/> or <see cref="TWriter"/> object that is
    /// loading or saving the published properties.
    /// </param>
    {$Endregion}
    Procedure DefineProperties(Filer : TFiler); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Updates the control when it is first loaded into memory.
    /// </summary>
    {$Endregion}
    Procedure Loaded; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Responds to the user's item selection.
    /// </summary>
    {$Endregion}
    Procedure Select; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Responds when the user presses a key.
    /// </summary>
    /// <param name="Key">
    /// The key that was pressed. If the method changes Key to 0, processing of the keystroke stops.
    /// </param>
    /// <param name="Shift">
    /// Indicates the concurrent state of the Ctrl, Shift, and Alt keys.
    /// </param>
    {$Endregion}
    Procedure KeyDown(Var Key : Word; Shift : TShiftState); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Responds when the user presses a key while the control has focus.
    /// </summary>
    /// <param name="Key">
    /// The key code of the key that was pressed.
    /// </param>
    {$Endregion}
    Procedure KeyPress(Var Key : Char); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Provides specific message responses for the control.
    /// </summary>
    /// <param name="Message">
    /// The message's details.
    /// </param>
    {$Endregion}
    Procedure WndProc(Var Message : TMessage); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Responds to changes in the <see cref="Items"/> property
    /// </summary>
    {$Endregion}
    Procedure DoItemsChange; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Helps the data-aware control manage its link to the data source and respond
    /// to data events.
    /// </summary>
    {$Endregion}
    Property DataLink : TFieldDataLink Read fDataLink;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the name of the country field that is represented by the control.
    /// </summary>
    {$Endregion}
    Property DataField : WideString Read GetDataField Write SetDataField;
    {$Region 'xmldoc'}
    /// <summary>
    /// Links the control to the dataset that contains the field it represents.
    /// </summary>
    {$Endregion}
    Property DataSource : TDataSource Read GetDataSource Write SetDataSource;
    {$Region 'xmldoc'}
    /// <summary>
    /// Determines whether the user can change the field value using the control.
    /// </summary>
    {$Endregion}
    Property Readonly : Boolean Read GetReadOnly Write SetReadOnly Default False;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the control.
    /// </summary>
    /// <param name="AOwner">
    /// The owner component.
    /// </param>
    {$Endregion}
    Constructor Create(AOwner : TComponent); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Destroys the control and releases its allocated memory.
    /// </summary>
    {$Endregion}
    Destructor Destroy; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Invokes an action with the control as its target.
    /// </summary>
    /// <param name="Action">
    /// Specifies the action that was invoked.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the action was successfully dispatched,
    /// and <see langword="false"/> if the control could not handle the action.
    /// </returns>
    /// <seealso cref="UpdateAction"/>
    {$Endregion}
    Function ExecuteAction(Action : TBasicAction) : Boolean; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Updates an action to reflect the current state of the control.
    /// </summary>
    /// <param name="Action">
    /// Specifies the action that should be updated.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the action component now reflects the
    /// state of the control, and <see langword="false"/> if it did not know how
    /// to update the action.
    /// </returns>
    /// <seealso cref="ExecuteAction"/>
    {$Endregion}
    Function UpdateAction(Action : TBasicAction) : Boolean; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Specifies whether the control's alignment is in a right-to-left mode.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> if the control's alignment is in a right-to-left
    /// mode, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function UseRightToLeftAlignment : Boolean; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the <see cref="TField"/> object for the database field that the control
    /// represents.
    /// </summary>
    {$Endregion}
    Property Field : TField Read GetField;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TDBTerritoryBox is a data-aware combo box control that enables users to choose
/// value of a country field from a list of <see cref="TTerritoryInfo"/> objects.
/// </summary>
/// <remarks>
/// <para>
/// Use TDBTerritoryBox to enable users to choose value of a database field, which represents
/// an international country code or a geographical identifier, from a list of
/// <see cref="TTerritoryInfo"/> objects.
/// </para>
/// <para>
/// The type of the database field must be either string (size of 2 or 3 characters) or numeric
/// to store respectively the international country code or the geographical identifier of the
/// selected <see cref="TTerritoryInfo"/> object.
/// </para>
/// <para>
/// TDBTerritoryBox publishes many of the properties, events, and methods of
/// <see cref="TCustomDBTerritoryBox"/>, but does not introduce any new behavior.
/// </para>
/// </remarks>
/// <group name="Components"/>
{$Endregion}
{$IFDEF COMPILER_XE2_UP}

  [ComponentPlatformsAttribute(pidWin32 Or pidWin64)]
  {$ENDIF}
  TDBTerritoryBox = Class(TCustomDBTerritoryBox)
   Published
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets how the control aligns within its container (parent control).
    /// </summary>
    {$Endregion}
    Property Align;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether a control should be constrained by <see cref="Margins"/>.
    /// </summary>
    {$Endregion}
    Property AlignWithMargins;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets how the control is anchored to its parent.
    /// </summary>
    {$Endregion}
    Property Anchors;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the user can give focus to items by typing in the list.
    /// </summary>
    {$Endregion}
    Property AutoComplete;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the delay between a key press and an attempt to <see cref="AutoComplete"/>.
    /// </summary>
    {$Endregion}
    Property AutoCompleteDelay;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the drop-down closes up automatically when the user selects an item.
    /// </summary>
    {$Endregion}
    Property AutoCloseUp;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the drop-down list drops down automatically in response to user keystrokes.
    /// </summary>
    {$Endregion}
    Property AutoDropDown;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets which edges of the control are beveled.
    /// </summary>
    {$Endregion}
    Property BevelEdges;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the cut of the inner bevel.
    /// </summary>
    {$Endregion}
    Property BevelInner;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the control's bevel style.
    /// </summary>
    {$Endregion}
    Property BevelKind;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the cut of the outer bevel.
    /// </summary>
    {$Endregion}
    Property BevelOuter;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the bidirectional mode for the control.
    /// </summary>
    {$Endregion}
    Property BiDiMode;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the background color of the control.
    /// </summary>
    {$Endregion}
    Property Color Nodefault;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the size constraints for the control.
    /// </summary>
    {$Endregion}
    Property Constraints;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control has a three-dimensional look.
    /// </summary>
    {$Endregion}
    Property Ctl3D;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the name of the country field that is represented by the control.
    /// </summary>
    {$Endregion}
    Property DataField;
    {$Region 'xmldoc'}
    /// <summary>
    /// Links the control to the dataset that contains the field it represents.
    /// </summary>
    {$Endregion}
    Property DataSource;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets which value of <see cref="TCultureInfo.DisplayNames"/> should be
    /// displayed as the label of items.
    /// </summary>
    {$Endregion}
    Property DisplayName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control's image is rendered directly to the window or
    /// painted to an in-memory bitmap first.
    /// </summary>
    {$Endregion}
    Property DoubleBuffered;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the image used to represent the mouse pointer when it passes
    /// into the region covered by the control.
    /// </summary>
    {$Endregion}
    Property DragCursor;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control is being dragged normally or for docking.
    /// </summary>
    {$Endregion}
    Property DragKind;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets how the control initiates drag-and-drop or drag-and-dock operations.
    /// </summary>
    {$Endregion}
    Property DragMode;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the maximum number of items displayed in the drop-down list.
    /// </summary>
    {$Endregion}
    Property DropDownCount;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control responds to keyboard, mouse, and timer events.
    /// </summary>
    {$Endregion}
    Property Enabled;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the placement of the flag icon in regard of the text label.
    /// </summary>
    {$Endregion}
    Property FlagPosition;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the flag icons that can appear on the control.
    /// </summary>
    {$Endregion}
    Property Flags;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the attributes of text written on the control.
    /// </summary>
    {$Endregion}
    Property Font;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the text string that can appear when the user moves the mouse over
    /// the control.
    /// </summary>
    {$Endregion}
    Property Hint;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the behavior of the input method editor (IME).
    /// </summary>
    {$Endregion}
    Property ImeMode;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the input method editor (IME) to use for converting keyboard input.
    /// </summary>
    {$Endregion}
    Property ImeName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the <see cref="TCultureInfo"/> objects in the control.
    /// </summary>
    {$Endregion}
    Property Items;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the margins of the control.
    /// </summary>
    {$Endregion}
    Property Margins;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="BiDiMode"/>.
    /// </summary>
    {$Endregion}
    Property ParentBiDiMode;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="Color"/>.
    /// </summary>
    {$Endregion}
    Property ParentColor;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="Ctl3D"/>.
    /// </summary>
    {$Endregion}
    Property ParentCtl3D;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="DoubleBuffered"/>.
    /// </summary>
    {$Endregion}
    Property ParentDoubleBuffered;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="Font"/>.
    /// </summary>
    {$Endregion}
    Property ParentFont;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="ShowHint"/>.
    /// </summary>
    {$Endregion}
    Property ParentShowHint;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the pop-up menu associated with the control.
    /// </summary>
    {$Endregion}
    Property PopupMenu;
    {$Region 'xmldoc'}
    /// <summary>
    /// Determines whether the user can change the field value using the control.
    /// </summary>
    {$Endregion}
    Property Readonly;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control displays a Help <see cref="Hint"/> when the mouse
    /// pointer rests momentarily on the control.
    /// </summary>
    {$Endregion}
    Property ShowHint;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the items in the list are arranged alphabetically.
    /// </summary>
    {$Endregion}
    Property Sorted;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the position of the control in its parent's tab order.
    /// </summary>
    {$Endregion}
    Property TabOrder;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the user can tab to a control.
    /// </summary>
    {$Endregion}
    Property TabStop;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets thet text that is displayed as a text watermark in the control.
    /// NOTE: This feature is only available in Windows Vista and later.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property TextHint;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the touch manager component associated with the control.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property Touch;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control appears onscreen.
    /// </summary>
    {$Endregion}
    Property Visible;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user clicks the control.
    /// </summary>
    {$Endregion}
    Property OnClick;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the drop-down list closes up due to some user action.
    /// </summary>
    {$Endregion}
    Property OnCloseUp;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user right-clicks the control or otherwise invokes the pop-up
    /// menu (such as using the keyboard).
    /// </summary>
    {$Endregion}
    Property OnContextPopup;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user double-clicks the left mouse button when the mouse pointer
    /// is over the control.
    /// </summary>
    {$Endregion}
    Property OnDblClick;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user drops an object being dragged on the control.
    /// </summary>
    {$Endregion}
    Property OnDragDrop;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user drags an object over the control.
    /// </summary>
    {$Endregion}
    Property OnDragOver;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when text label of an item needs to be displayed.
    /// </summary>
    {$Endregion}
    Property OnDrawItemLabel;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user opens the drop-down list.
    /// </summary>
    {$Endregion}
    Property OnDropDown;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the dragging of an object ends, either by docking the object or
    /// by canceling the dragging.
    /// </summary>
    {$Endregion}
    Property OnEndDock;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the dragging of an object ends, either by dropping the object or
    /// by canceling the dragging.
    /// </summary>
    {$Endregion}
    Property OnEndDrag;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when a control receives the input focus.
    /// </summary>
    {$Endregion}
    Property OnEnter;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the input focus shifts away from one control to another.
    /// </summary>
    {$Endregion}
    Property OnExit;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when user performs a gesture associated with the control.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property OnGesture;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when <see cref="Items"/> property changed.
    /// </summary>
    {$Endregion}
    Property OnItemsChange;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when a user presses any key while the control has focus.
    /// </summary>
    {$Endregion}
    Property OnKeyDown;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when key pressed.
    /// </summary>
    {$Endregion}
    Property OnKeyPress;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user releases a key that has been pressed.
    /// </summary>
    {$Endregion}
    Property OnKeyUp;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user presses a mouse button with the mouse pointer over the
    /// control and the parent form is not active.
    /// </summary>
    {$Endregion}
    Property OnMouseActivate;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user presses a mouse button with the mouse pointer over the
    /// control.
    /// </summary>
    {$Endregion}
    Property OnMouseDown;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user moves the mouse pointer while the mouse pointer is over
    /// the control.
    /// </summary>
    {$Endregion}
    Property OnMouseMove;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user releases a mouse button that was pressed with the mouse
    /// pointer over the control.
    /// </summary>
    {$Endregion}
    Property OnMouseUp;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user moves the mouse into the control.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property OnMouseEnter;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user moves the mouse outside of the control.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property OnMouseLeave;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the mouse wheel is rotated.
    /// </summary>
    {$Endregion}
    Property OnMouseWheel;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the mouse wheel is rotated downward.
    /// </summary>
    {$Endregion}
    Property OnMouseWheelDown;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the mouse wheel is rotated upward.
    /// </summary>
    {$Endregion}
    Property OnMouseWheelUp;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs immediately after the control is resized.
    /// </summary>
    {$Endregion}
    Property OnResize;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user selects an item in the drop-down list
    /// </summary>
    {$Endregion}
    Property OnSelect;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user begins to drag the control with a <see cref="DragKind"/>
    /// of <see cref="DragKind.dkDock"/>.
    /// </summary>
    {$Endregion}
    Property OnStartDock;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user begins to drag the control with a <see cref="DragKind"/>
    /// of <see cref="DragKind.dkDrag"/>.
    /// </summary>
    {$Endregion}
    Property OnStartDrag;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TCustomDBTerritoryListBox is the base class for data-aware list box controls that
/// enable users to choose value of a country field from a list of <see cref="TTerritoryInfo"/>
/// objects.
/// </summary>
/// <remarks>
/// <para>
/// Use TCustomDBTerritoryListBox as a base class when defining data-aware list box controls
/// that provide a list of <see cref="TTerritoryInfo"/> objects to update value of a database
/// field.
/// </para>
/// <para>
/// The type of the database field must be either string (size of 2 or 3 characters) or numeric
/// to store respectively the international country code or the geographical identifier of the
/// selected <see cref="TTerritoryInfo"/> object.
/// </para>
/// </remarks>
{$Endregion}

  TCustomDBTerritoryListBox = Class(TCustomTerritoryListBox)
   Private
    fDataLink : TFieldDataLink;
    Function GetDataField : WideString; Inline;
    Procedure SetDataField(Const Value : WideString); Inline;
    Function GetDataSource : TDataSource; Inline;
    Procedure SetDataSource(Value : TDataSource); Inline;
    Function GetField : TField; Inline;
    Function GetReadOnly : Boolean; Inline;
    Procedure SetReadOnly(Value : Boolean); Inline;
    Procedure UpdateData(Sender : TObject);
    Procedure DataChange(Sender : TObject);
    Procedure CMExit(Var Message : TCMExit); Message CM_EXIT;
    Procedure CMGetDataLink(Var Message : TMessage); Message CM_GETDATALINK;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Prevents <see cref="ItemSelected"/> property to be saved and loaded.
    /// </summary>
    /// <param name="Filer">
    /// The current <see cref="TReader"/> or <see cref="TWriter"/> object that is
    /// loading or saving the published properties.
    /// </param>
    {$Endregion}
    Procedure DefineProperties(Filer : TFiler); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Updates the control when it is first loaded into memory.
    /// </summary>
    {$Endregion}
    Procedure Loaded; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Responds to mouse clicks.
    /// </summary>
    {$Endregion}
    Procedure Click; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Responds when the user presses a key.
    /// </summary>
    /// <param name="Key">
    /// The key that was pressed. If the method changes Key to 0, processing of the keystroke stops.
    /// </param>
    /// <param name="Shift">
    /// Indicates the concurrent state of the Ctrl, Shift, and Alt keys.
    /// </param>
    {$Endregion}
    Procedure KeyDown(Var Key : Word; Shift : TShiftState); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Responds when the user presses a key while the control has focus.
    /// </summary>
    /// <param name="Key">
    /// The key code of the key that was pressed.
    /// </param>
    {$Endregion}
    Procedure KeyPress(Var Key : Char); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Provides specific message responses for the control.
    /// </summary>
    /// <param name="Message">
    /// The message's details.
    /// </param>
    {$Endregion}
    Procedure WndProc(Var Message : TMessage); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Responds to changes in the <see cref="Items"/> property
    /// </summary>
    {$Endregion}
    Procedure DoItemsChange; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Helps the data-aware control manage its link to the data source and respond
    /// to data events.
    /// </summary>
    {$Endregion}
    Property DataLink : TFieldDataLink Read fDataLink;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the name of the country field that is represented by the control.
    /// </summary>
    {$Endregion}
    Property DataField : WideString Read GetDataField Write SetDataField;
    {$Region 'xmldoc'}
    /// <summary>
    /// Links the control to the dataset that contains the field it represents.
    /// </summary>
    {$Endregion}
    Property DataSource : TDataSource Read GetDataSource Write SetDataSource;
    {$Region 'xmldoc'}
    /// <summary>
    /// Determines whether the user can change the field value using the control.
    /// </summary>
    {$Endregion}
    Property Readonly : Boolean Read GetReadOnly Write SetReadOnly Default False;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the control.
    /// </summary>
    /// <param name="AOwner">
    /// The owner component.
    /// </param>
    {$Endregion}
    Constructor Create(AOwner : TComponent); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Destroys the control and releases its allocated memory.
    /// </summary>
    {$Endregion}
    Destructor Destroy; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Invokes an action with the control as its target.
    /// </summary>
    /// <param name="Action">
    /// Specifies the action that was invoked.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the action was successfully dispatched,
    /// and <see langword="false"/> if the control could not handle the action.
    /// </returns>
    /// <seealso cref="UpdateAction"/>
    {$Endregion}
    Function ExecuteAction(Action : TBasicAction) : Boolean; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Updates an action to reflect the current state of the control.
    /// </summary>
    /// <param name="Action">
    /// Specifies the action that should be updated.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the action component now reflects the
    /// state of the control, and <see langword="false"/> if it did not know how
    /// to update the action.
    /// </returns>
    /// <seealso cref="ExecuteAction"/>
    {$Endregion}
    Function UpdateAction(Action : TBasicAction) : Boolean; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Specifies whether the control's alignment is in a right-to-left mode.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> if the control's alignment is in a right-to-left
    /// mode, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function UseRightToLeftAlignment : Boolean; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the <see cref="TField"/> object for the database field that the control
    /// represents.
    /// </summary>
    {$Endregion}
    Property Field : TField Read GetField;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TDBTerritoryListBox is a data-aware list box control that enables users to choose
/// value of a country field from a list of <see cref="TTerritoryInfo"/> objects.
/// </summary>
/// <remarks>
/// <para>
/// Use TDBTerritoryListBox to enable users to choose value of a database field, which
/// represents an international country code or a geographical identifier, from a list of
/// <see cref="TTerritoryInfo"/> objects.
/// </para>
/// <para>
/// The type of the database field must be either string (size of 2 or 3 characters) or numeric
/// to store respectively the international country code or the geographical identifier of the
/// selected <see cref="TTerritoryInfo"/> object.
/// </para>
/// <para>
/// TDBTerritoryListBox publishes many of the properties, events, and methods of
/// <see cref="TCustomDBTerritoryListBox"/>, but does not introduce any new behavior.
/// </para>
/// </remarks>
/// <group name="Components"/>
{$Endregion}
{$IFDEF COMPILER_XE2_UP}

  [ComponentPlatformsAttribute(pidWin32 Or pidWin64)]
  {$ENDIF}
  TDBTerritoryListBox = Class(TCustomDBTerritoryListBox)
   Published
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets how the control aligns within its container (parent control).
    /// </summary>
    {$Endregion}
    Property Align;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether a control should be constrained by <see cref="Margins"/>.
    /// </summary>
    {$Endregion}
    Property AlignWithMargins;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets how the control is anchored to its parent.
    /// </summary>
    {$Endregion}
    Property Anchors;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the user can give focus to items by typing in the list.
    /// </summary>
    {$Endregion}
    Property AutoComplete;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the delay between a key press and an attempt to <see cref="AutoComplete"/>.
    /// </summary>
    {$Endregion}
    Property AutoCompleteDelay;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets which edges of the control are beveled.
    /// </summary>
    {$Endregion}
    Property BevelEdges;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the cut of the inner bevel.
    /// </summary>
    {$Endregion}
    Property BevelInner;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the control's bevel style.
    /// </summary>
    {$Endregion}
    Property BevelKind;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the cut of the outer bevel.
    /// </summary>
    {$Endregion}
    Property BevelOuter;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the bidirectional mode for the control.
    /// </summary>
    {$Endregion}
    Property BiDiMode;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control has a border.
    /// </summary>
    {$Endregion}
    Property BorderStyle;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the background color of the control.
    /// </summary>
    {$Endregion}
    Property Color Nodefault;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the size constraints for the control.
    /// </summary>
    {$Endregion}
    Property Constraints;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control has a three-dimensional look.
    /// </summary>
    {$Endregion}
    Property Ctl3D;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the number of columns, in a multi-column list box, that are visible
    /// without having to scroll.
    /// </summary>
    {$Endregion}
    Property Columns;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the name of the country field that is represented by the control.
    /// </summary>
    {$Endregion}
    Property DataField;
    {$Region 'xmldoc'}
    /// <summary>
    /// Links the control to the dataset that contains the field it represents.
    /// </summary>
    {$Endregion}
    Property DataSource;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets which value of <see cref="TCultureInfo.DisplayNames"/> should be
    /// displayed as the label of items.
    /// </summary>
    {$Endregion}
    Property DisplayName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control's image is rendered directly to the window or
    /// painted to an in-memory bitmap first.
    /// </summary>
    {$Endregion}
    Property DoubleBuffered;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the image used to represent the mouse pointer when it passes
    /// into the region covered by the control.
    /// </summary>
    {$Endregion}
    Property DragCursor;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control is being dragged normally or for docking.
    /// </summary>
    {$Endregion}
    Property DragKind;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets how the control initiates drag-and-drop or drag-and-dock operations.
    /// </summary>
    {$Endregion}
    Property DragMode;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control responds to keyboard, mouse, and timer events.
    /// </summary>
    {$Endregion}
    Property Enabled;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the placement of the flag icon in regard of the text label.
    /// </summary>
    {$Endregion}
    Property FlagPosition;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the flag icons that can appear on the control.
    /// </summary>
    {$Endregion}
    Property Flags;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the attributes of text written on the control.
    /// </summary>
    {$Endregion}
    Property Font;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the text string that can appear when the user moves the mouse over
    /// the control.
    /// </summary>
    {$Endregion}
    Property Hint;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the behavior of the input method editor (IME).
    /// </summary>
    {$Endregion}
    Property ImeMode;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the input method editor (IME) to use for converting keyboard input.
    /// </summary>
    {$Endregion}
    Property ImeName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the list box displays the partial items.
    /// </summary>
    {$Endregion}
    Property IntegralHeight;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the <see cref="TCultureInfo"/> objects in the control.
    /// </summary>
    {$Endregion}
    Property Items;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the margins of the control.
    /// </summary>
    {$Endregion}
    Property Margins;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="BiDiMode"/>.
    /// </summary>
    {$Endregion}
    Property ParentBiDiMode;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="Color"/>.
    /// </summary>
    {$Endregion}
    Property ParentColor;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="Ctl3D"/>.
    /// </summary>
    {$Endregion}
    Property ParentCtl3D;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="DoubleBuffered"/>.
    /// </summary>
    {$Endregion}
    Property ParentDoubleBuffered;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="Font"/>.
    /// </summary>
    {$Endregion}
    Property ParentFont;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="ShowHint"/>.
    /// </summary>
    {$Endregion}
    Property ParentShowHint;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the pop-up menu associated with the control.
    /// </summary>
    {$Endregion}
    Property PopupMenu;
    {$Region 'xmldoc'}
    /// <summary>
    /// Determines whether the user can change the field value using the control.
    /// </summary>
    {$Endregion}
    Property Readonly;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the width, in pixels, by which the list box can scroll horizontally.
    /// </summary>
    {$Endregion}
    Property ScrollWidth;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control displays a Help <see cref="Hint"/> when the mouse
    /// pointer rests momentarily on the control.
    /// </summary>
    {$Endregion}
    Property ShowHint;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the items in the list are arranged alphabetically.
    /// </summary>
    {$Endregion}
    Property Sorted;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the position of the control in its parent's tab order.
    /// </summary>
    {$Endregion}
    Property TabOrder;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the user can tab to a control.
    /// </summary>
    {$Endregion}
    Property TabStop;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the size of the tabs in the list box.
    /// </summary>
    {$Endregion}
    Property TabWidth;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the touch manager component associated with the control.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property Touch;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control appears onscreen.
    /// </summary>
    {$Endregion}
    Property Visible;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user clicks the control.
    /// </summary>
    {$Endregion}
    Property OnClick;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user right-clicks the control or otherwise invokes the pop-up
    /// menu (such as using the keyboard).
    /// </summary>
    {$Endregion}
    Property OnContextPopup;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user double-clicks the left mouse button when the mouse pointer
    /// is over the control.
    /// </summary>
    {$Endregion}
    Property OnDblClick;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user drops an object being dragged on the control.
    /// </summary>
    {$Endregion}
    Property OnDragDrop;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user drags an object over the control.
    /// </summary>
    {$Endregion}
    Property OnDragOver;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when text label of an item needs to be displayed.
    /// </summary>
    {$Endregion}
    Property OnDrawItemLabel;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the dragging of an object ends, either by docking the object or
    /// by canceling the dragging.
    /// </summary>
    {$Endregion}
    Property OnEndDock;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the dragging of an object ends, either by dropping the object or
    /// by canceling the dragging.
    /// </summary>
    {$Endregion}
    Property OnEndDrag;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when a control receives the input focus.
    /// </summary>
    {$Endregion}
    Property OnEnter;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the input focus shifts away from one control to another.
    /// </summary>
    {$Endregion}
    Property OnExit;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when user performs a gesture associated with the control.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property OnGesture;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when <see cref="Items"/> property changed.
    /// </summary>
    {$Endregion}
    Property OnItemsChange;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when a user presses any key while the control has focus.
    /// </summary>
    {$Endregion}
    Property OnKeyDown;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when key pressed.
    /// </summary>
    {$Endregion}
    Property OnKeyPress;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user releases a key that has been pressed.
    /// </summary>
    {$Endregion}
    Property OnKeyUp;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user presses a mouse button with the mouse pointer over the
    /// control and the parent form is not active.
    /// </summary>
    {$Endregion}
    Property OnMouseActivate;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user presses a mouse button with the mouse pointer over the
    /// control.
    /// </summary>
    {$Endregion}
    Property OnMouseDown;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user moves the mouse pointer while the mouse pointer is over
    /// the control.
    /// </summary>
    {$Endregion}
    Property OnMouseMove;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user releases a mouse button that was pressed with the mouse
    /// pointer over the control.
    /// </summary>
    {$Endregion}
    Property OnMouseUp;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user moves the mouse into the control.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property OnMouseEnter;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user moves the mouse outside of the control.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property OnMouseLeave;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the mouse wheel is rotated.
    /// </summary>
    {$Endregion}
    Property OnMouseWheel;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the mouse wheel is rotated downward.
    /// </summary>
    {$Endregion}
    Property OnMouseWheelDown;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the mouse wheel is rotated upward.
    /// </summary>
    {$Endregion}
    Property OnMouseWheelUp;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs immediately after the control is resized.
    /// </summary>
    {$Endregion}
    Property OnResize;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user begins to drag the control with a <see cref="DragKind"/>
    /// of <see cref="DragKind.dkDock"/>.
    /// </summary>
    {$Endregion}
    Property OnStartDock;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user begins to drag the control with a <see cref="DragKind"/>
    /// of <see cref="DragKind.dkDrag"/>.
    /// </summary>
    {$Endregion}
    Property OnStartDrag;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TCustomDBCurrencyLabel is the base class for data-aware label controls that
/// display value of a currency symbol field.
/// </summary>
/// <remarks>
/// Use TCustomDBCurrencyLabel as a base class when defining objects that display
/// value of a database field, where the field represents an international monetary
/// symbol.
/// </remarks>
{$Endregion}

  TCustomDBCurrencyLabel = Class(TCustomCurrencyLabel)
   Private
    fDataLink : TFieldDataLink;
    Procedure DataChange(Sender : TObject);
    Function GetCurrency : TCurrencyInfo; Inline;
    Function GetDataField : WideString; Inline;
    Procedure SetDataField(Const Value : WideString); Inline;
    Function GetDataSource : TDataSource; Inline;
    Procedure SetDataSource(Value : TDataSource); Inline;
    Function GetField : TField;
    Procedure CMGetDataLink(Var Message : TMessage); Message CM_GETDATALINK;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Prevents <see cref="Currency"/> property to be saved and loaded.
    /// </summary>
    /// <param name="Filer">
    /// The current <see cref="TReader"/> or <see cref="TWriter"/> object that is
    /// loading or saving the published properties.
    /// </param>
    {$Endregion}
    Procedure DefineProperties(Filer : TFiler); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Updates the control when it is first loaded into memory.
    /// </summary>
    {$Endregion}
    Procedure Loaded; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Determines the string that appears as the text of the label.
    /// </summary>
    /// <returns>
    /// The text that appears on the label.
    /// </returns>
    {$Endregion}
    Function GetLabelText : String; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Determines the country flag icon that appears on the control.
    /// </summary>
    /// <returns>
    /// The index of a country flag icon or -1 if no icon should be displayed.
    /// </returns>
    {$Endregion}
    Function GetImageIndex : TImageIndex; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Sets the <see cref="AutoSize"/> property.
    /// </summary>
    /// <param name="Value">
    /// Indicates whether the auto size should be on or off.
    /// </param>
    {$Endregion}
    Procedure SetAutoSize(Value : Boolean); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Helps the data-aware control manage its link to the data source and respond
    /// to data events.
    /// </summary>
    {$Endregion}
    Property DataLink : TFieldDataLink Read fDataLink;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the name of the currency symbol field that is represented by the
    /// control.
    /// </summary>
    {$Endregion}
    Property DataField : WideString Read GetDataField Write SetDataField;
    {$Region 'xmldoc'}
    /// <summary>
    /// Links the control to the dataset that contains the field it represents.
    /// </summary>
    {$Endregion}
    Property DataSource : TDataSource Read GetDataSource Write SetDataSource;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the control.
    /// </summary>
    /// <param name="AOwner">
    /// The owner component.
    /// </param>
    {$Endregion}
    Constructor Create(AOwner : TComponent); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Destroys the control and releases its allocated memory.
    /// </summary>
    {$Endregion}
    Destructor Destroy; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Specifies whether the control's alignment is in a right-to-left mode.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> if the control's alignment is in a right-to-left
    /// mode, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function UseRightToLeftAlignment : Boolean; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the <see cref="TField"/> object for the database field that the control
    /// represents.
    /// </summary>
    {$Endregion}
    Property Field : TField Read GetField;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the <see cref="TCurrencyInfo"/> object that the value of the currency symbol
    /// field represents.
    /// </summary>
    {$Endregion}
    Property Currency : TCurrencyInfo Read GetCurrency;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TDBCurrencyLabel is a data-aware label control that displays value of a currency
/// symbol field.
/// </summary>
/// <remarks>
/// <para>
/// Use TDBCurrencyLabel to display value of a database field on a form, when the field
/// represents an international monetary symbol.
/// </para>
/// <para>
/// TDBCurrencyLabel publishes many of the properties, events, and methods of
/// <see cref="TCustomDBCurrencyLabel"/>, but does not introduce any new behavior.
/// </para>
/// </remarks>
/// <group name="Components"/>
{$Endregion}
{$IFDEF COMPILER_XE2_UP}

  [ComponentPlatformsAttribute(pidWin32 Or pidWin64)]
  {$ENDIF}
  TDBCurrencyLabel = Class(TCustomDBCurrencyLabel)
   Published
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets how the control aligns within its container (parent control).
    /// </summary>
    {$Endregion}
    Property Align;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the horizontal placement of the text within the label.
    /// </summary>
    {$Endregion}
    Property Alignment;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether a control should be constrained by <see cref="Margins"/>.
    /// </summary>
    {$Endregion}
    Property AlignWithMargins;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets how the control is anchored to its parent.
    /// </summary>
    {$Endregion}
    Property Anchors;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control sizes itself automatically to accommodate
    /// its contents.
    /// </summary>
    {$Endregion}
    Property AutoSize Default False;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the bidirectional mode for the control.
    /// </summary>
    {$Endregion}
    Property BiDiMode;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the color of the control's border.
    /// </summary>
    {$Endregion}
    Property BorderColor;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the width of the control's border.
    /// </summary>
    {$Endregion}
    Property BorderWidth;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the text of the label when the database field has no value or its
    /// value is not a valid international monetary symbol.
    /// </summary>
    {$Endregion}
    Property Caption;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the background color of the control.
    /// </summary>
    {$Endregion}
    Property Color Nodefault;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the size constraints for the control.
    /// </summary>
    {$Endregion}
    Property Constraints;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the name of the currency symbol field that is represented by the
    /// control.
    /// </summary>
    {$Endregion}
    Property DataField;
    {$Region 'xmldoc'}
    /// <summary>
    /// Links the control to the dataset that contains the field it represents.
    /// </summary>
    {$Endregion}
    Property DataSource;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets which value of <see cref="TCurrencyInfo.DisplayNames"/> should be
    /// displayed as the text label on the control.
    /// </summary>
    {$Endregion}
    Property DisplayName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the image used to represent the mouse pointer when it passes
    /// into the region covered by the control.
    /// </summary>
    {$Endregion}
    Property DragCursor;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control is being dragged normally or for docking.
    /// </summary>
    {$Endregion}
    Property DragKind;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets how the control initiates drag-and-drop or drag-and-dock operations.
    /// </summary>
    {$Endregion}
    Property DragMode;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control responds to keyboard, mouse, and timer events.
    /// </summary>
    {$Endregion}
    Property Enabled;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the flag icons that can appear on the control.
    /// </summary>
    {$Endregion}
    Property Flags;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets a windowed control associated with the label.
    /// </summary>
    {$Endregion}
    Property FocusControl;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the attributes of text written on the control.
    /// </summary>
    {$Endregion}
    Property Font;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the radius of the glow around the label.
    /// NOTE: This feature is only available in Windows Vista and later.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property GlowSize;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the text string that can appear when the user moves the mouse over
    /// the control.
    /// </summary>
    {$Endregion}
    Property Hint;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the margins of the control.
    /// </summary>
    {$Endregion}
    Property Margins;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the distance between the image and the text from the control's border.
    /// </summary>
    {$Endregion}
    Property Padding;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="BiDiMode"/>.
    /// </summary>
    {$Endregion}
    Property ParentBiDiMode;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="Color"/>.
    /// </summary>
    {$Endregion}
    Property ParentColor;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="Font"/>.
    /// </summary>
    {$Endregion}
    Property ParentFont;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="ShowHint"/>.
    /// </summary>
    {$Endregion}
    Property ParentShowHint;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the pop-up menu associated with the control.
    /// </summary>
    {$Endregion}
    Property PopupMenu;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets how an ampersand in the label text is displayed.
    /// </summary>
    {$Endregion}
    Property ShowAccelChar;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control displays a Help <see cref="Hint"/> when the mouse
    /// pointer rests momentarily on the control.
    /// </summary>
    {$Endregion}
    Property ShowHint;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the number of pixels between the image and the text of the control.
    /// </summary>
    {$Endregion}
    Property Spacing;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the touch manager component associated with the control.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property Touch;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether controls that sit below the label on a form can be seen
    /// through the label.
    /// </summary>
    {$Endregion}
    Property Transparent;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the vertical placement of the text within the label.
    /// </summary>
    {$Endregion}
    Property Layout;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control appears onscreen.
    /// </summary>
    {$Endregion}
    Property Visible;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets Specifies whether the label text wraps when it is too long for the
    /// width of the label.
    /// </summary>
    {$Endregion}
    Property WordWrap;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user clicks the control.
    /// </summary>
    {$Endregion}
    Property OnClick;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user right-clicks the control or otherwise invokes the pop-up
    /// menu (such as using the keyboard).
    /// </summary>
    {$Endregion}
    Property OnContextPopup;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user double-clicks the left mouse button when the mouse pointer
    /// is over the control.
    /// </summary>
    {$Endregion}
    Property OnDblClick;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user drops an object being dragged on the control.
    /// </summary>
    {$Endregion}
    Property OnDragDrop;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user drags an object over the control.
    /// </summary>
    {$Endregion}
    Property OnDragOver;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the dragging of an object ends, either by docking the object or
    /// by canceling the dragging.
    /// </summary>
    {$Endregion}
    Property OnEndDock;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the dragging of an object ends, either by dropping the object or
    /// by canceling the dragging.
    /// </summary>
    {$Endregion}
    Property OnEndDrag;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when user performs a gesture associated with the control.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property OnGesture;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user presses a mouse button with the mouse pointer over the
    /// control and the parent form is not active.
    /// </summary>
    {$Endregion}
    Property OnMouseActivate;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user presses a mouse button with the mouse pointer over the
    /// control.
    /// </summary>
    {$Endregion}
    Property OnMouseDown;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user moves the mouse pointer while the mouse pointer is over
    /// the control.
    /// </summary>
    {$Endregion}
    Property OnMouseMove;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user releases a mouse button that was pressed with the mouse
    /// pointer over the control.
    /// </summary>
    {$Endregion}
    Property OnMouseUp;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user moves the mouse into the control.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property OnMouseEnter;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user moves the mouse outside of the control.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property OnMouseLeave;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the mouse wheel is rotated.
    /// </summary>
    {$Endregion}
    Property OnMouseWheel;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the mouse wheel is rotated downward.
    /// </summary>
    {$Endregion}
    Property OnMouseWheelDown;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the mouse wheel is rotated upward.
    /// </summary>
    {$Endregion}
    Property OnMouseWheelUp;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs immediately after the control is resized.
    /// </summary>
    {$Endregion}
    Property OnResize;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user begins to drag the control with a <see cref="DragKind"/>
    /// of <see cref="DragKind.dkDock"/>.
    /// </summary>
    {$Endregion}
    Property OnStartDock;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user begins to drag the control with a <see cref="DragKind"/>
    /// of <see cref="DragKind.dkDrag"/>.
    /// </summary>
    {$Endregion}
    Property OnStartDrag;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TCustomDBCurrencyBox is the base class for data-aware combo box controls that enable
/// users to choose value of a currency symbol field from a list of <see cref="TCurrencyInfo"/>
/// objects.
/// </summary>
/// <remarks>
/// <para>
/// Use TCustomDBCurrencyBox as a base class when defining data-aware combo box controls
/// that provide a list of <see cref="TCurrencyInfo"/> objects to update value of a database
/// field.
/// </para>
/// <para>
/// The type of the database field must be string (size of 3 characters) to store the
/// international monetary symbol of the selected <see cref="TCurrencyInfo"/> object.
/// </para>
/// </remarks>
{$Endregion}

  TCustomDBCurrencyBox = Class(TCustomCurrencyBox)
   Private
    fDataLink : TFieldDataLink;
    Function GetDataField : WideString; Inline;
    Procedure SetDataField(Const Value : WideString); Inline;
    Function GetDataSource : TDataSource; Inline;
    Procedure SetDataSource(Value : TDataSource); Inline;
    Function GetField : TField; Inline;
    Function GetReadOnly : Boolean; Inline;
    Procedure SetReadOnly(Value : Boolean); Inline;
    Procedure UpdateData(Sender : TObject);
    Procedure DataChange(Sender : TObject);
    Procedure CMExit(Var Message : TCMExit); Message CM_EXIT;
    Procedure CMGetDataLink(Var Message : TMessage); Message CM_GETDATALINK;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Prevents <see cref="ItemSelected"/> property to be saved and loaded.
    /// </summary>
    /// <param name="Filer">
    /// The current <see cref="TReader"/> or <see cref="TWriter"/> object that is
    /// loading or saving the published properties.
    /// </param>
    {$Endregion}
    Procedure DefineProperties(Filer : TFiler); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Updates the control when it is first loaded into memory.
    /// </summary>
    {$Endregion}
    Procedure Loaded; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Responds to the user's item selection.
    /// </summary>
    {$Endregion}
    Procedure Select; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Responds when the user presses a key.
    /// </summary>
    /// <param name="Key">
    /// The key that was pressed. If the method changes Key to 0, processing of the keystroke stops.
    /// </param>
    /// <param name="Shift">
    /// Indicates the concurrent state of the Ctrl, Shift, and Alt keys.
    /// </param>
    {$Endregion}
    Procedure KeyDown(Var Key : Word; Shift : TShiftState); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Responds when the user presses a key while the control has focus.
    /// </summary>
    /// <param name="Key">
    /// The key code of the key that was pressed.
    /// </param>
    {$Endregion}
    Procedure KeyPress(Var Key : Char); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Provides specific message responses for the control.
    /// </summary>
    /// <param name="Message">
    /// The message's details.
    /// </param>
    {$Endregion}
    Procedure WndProc(Var Message : TMessage); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Responds to changes in the <see cref="Items"/> property
    /// </summary>
    {$Endregion}
    Procedure DoItemsChange; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Helps the data-aware control manage its link to the data source and respond
    /// to data events.
    /// </summary>
    {$Endregion}
    Property DataLink : TFieldDataLink Read fDataLink;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the name of the currency symbol field that is represented by
    /// the control.
    /// </summary>
    {$Endregion}
    Property DataField : WideString Read GetDataField Write SetDataField;
    {$Region 'xmldoc'}
    /// <summary>
    /// Links the control to the dataset that contains the field it represents.
    /// </summary>
    {$Endregion}
    Property DataSource : TDataSource Read GetDataSource Write SetDataSource;
    {$Region 'xmldoc'}
    /// <summary>
    /// Determines whether the user can change the field value using the control.
    /// </summary>
    {$Endregion}
    Property Readonly : Boolean Read GetReadOnly Write SetReadOnly Default False;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the control.
    /// </summary>
    /// <param name="AOwner">
    /// The owner component.
    /// </param>
    {$Endregion}
    Constructor Create(AOwner : TComponent); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Destroys the control and releases its allocated memory.
    /// </summary>
    {$Endregion}
    Destructor Destroy; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Invokes an action with the control as its target.
    /// </summary>
    /// <param name="Action">
    /// Specifies the action that was invoked.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the action was successfully dispatched,
    /// and <see langword="false"/> if the control could not handle the action.
    /// </returns>
    /// <seealso cref="UpdateAction"/>
    {$Endregion}
    Function ExecuteAction(Action : TBasicAction) : Boolean; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Updates an action to reflect the current state of the control.
    /// </summary>
    /// <param name="Action">
    /// Specifies the action that should be updated.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the action component now reflects the
    /// state of the control, and <see langword="false"/> if it did not know how
    /// to update the action.
    /// </returns>
    /// <seealso cref="ExecuteAction"/>
    {$Endregion}
    Function UpdateAction(Action : TBasicAction) : Boolean; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Specifies whether the control's alignment is in a right-to-left mode.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> if the control's alignment is in a right-to-left
    /// mode, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function UseRightToLeftAlignment : Boolean; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the <see cref="TField"/> object for the database field that the control
    /// represents.
    /// </summary>
    {$Endregion}
    Property Field : TField Read GetField;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TDBCurrencyBox is a data-aware combo box control that enables users to choose value
/// of a currency symbol field from a list of <see cref="TCurrencyInfo"/> objects.
/// </summary>
/// <remarks>
/// <para>
/// Use TDBCurrencyBox to enable users to choose value of a database field, which
/// represents an international monetary symbol, from a list of <see cref="TCurrencyInfo"/>
/// objects.
/// </para>
/// <para>
/// The type of the database field must be string (size of 3 characters) to store the
/// international monetary symbol of the selected <see cref="TCurrencyInfo"/> object.
/// </para>
/// <para>
/// TDBCurrencyBox publishes many of the properties, events, and methods of
/// <see cref="TCustomDBCurrencyBox"/>, but does not introduce any new behavior.
/// </para>
/// </remarks>
/// <group name="Components"/>
{$Endregion}
{$IFDEF COMPILER_XE2_UP}

  [ComponentPlatformsAttribute(pidWin32 Or pidWin64)]
  {$ENDIF}
  TDBCurrencyBox = Class(TCustomDBCurrencyBox)
   Published
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets how the control aligns within its container (parent control).
    /// </summary>
    {$Endregion}
    Property Align;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether a control should be constrained by <see cref="Margins"/>.
    /// </summary>
    {$Endregion}
    Property AlignWithMargins;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets how the control is anchored to its parent.
    /// </summary>
    {$Endregion}
    Property Anchors;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the user can give focus to items by typing in the list.
    /// </summary>
    {$Endregion}
    Property AutoComplete;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the delay between a key press and an attempt to <see cref="AutoComplete"/>.
    /// </summary>
    {$Endregion}
    Property AutoCompleteDelay;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the drop-down closes up automatically when the user selects an item.
    /// </summary>
    {$Endregion}
    Property AutoCloseUp;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the drop-down list drops down automatically in response to user keystrokes.
    /// </summary>
    {$Endregion}
    Property AutoDropDown;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets which edges of the control are beveled.
    /// </summary>
    {$Endregion}
    Property BevelEdges;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the cut of the inner bevel.
    /// </summary>
    {$Endregion}
    Property BevelInner;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the control's bevel style.
    /// </summary>
    {$Endregion}
    Property BevelKind;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the cut of the outer bevel.
    /// </summary>
    {$Endregion}
    Property BevelOuter;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the bidirectional mode for the control.
    /// </summary>
    {$Endregion}
    Property BiDiMode;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the background color of the control.
    /// </summary>
    {$Endregion}
    Property Color Nodefault;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the size constraints for the control.
    /// </summary>
    {$Endregion}
    Property Constraints;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control has a three-dimensional look.
    /// </summary>
    {$Endregion}
    Property Ctl3D;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the name of the currency symbol field that is represented by the
    /// control.
    /// </summary>
    {$Endregion}
    Property DataField;
    {$Region 'xmldoc'}
    /// <summary>
    /// Links the control to the dataset that contains the field it represents.
    /// </summary>
    {$Endregion}
    Property DataSource;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets which value of <see cref="TCultureInfo.DisplayNames"/> should be
    /// displayed as the label of items.
    /// </summary>
    {$Endregion}
    Property DisplayName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control's image is rendered directly to the window or
    /// painted to an in-memory bitmap first.
    /// </summary>
    {$Endregion}
    Property DoubleBuffered;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the image used to represent the mouse pointer when it passes
    /// into the region covered by the control.
    /// </summary>
    {$Endregion}
    Property DragCursor;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control is being dragged normally or for docking.
    /// </summary>
    {$Endregion}
    Property DragKind;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets how the control initiates drag-and-drop or drag-and-dock operations.
    /// </summary>
    {$Endregion}
    Property DragMode;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the maximum number of items displayed in the drop-down list.
    /// </summary>
    {$Endregion}
    Property DropDownCount;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control responds to keyboard, mouse, and timer events.
    /// </summary>
    {$Endregion}
    Property Enabled;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the placement of the flag icon in regard of the text label.
    /// </summary>
    {$Endregion}
    Property FlagPosition;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the flag icons that can appear on the control.
    /// </summary>
    {$Endregion}
    Property Flags;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the attributes of text written on the control.
    /// </summary>
    {$Endregion}
    Property Font;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the text string that can appear when the user moves the mouse over
    /// the control.
    /// </summary>
    {$Endregion}
    Property Hint;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the behavior of the input method editor (IME).
    /// </summary>
    {$Endregion}
    Property ImeMode;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the input method editor (IME) to use for converting keyboard input.
    /// </summary>
    {$Endregion}
    Property ImeName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the <see cref="TCultureInfo"/> objects in the control.
    /// </summary>
    {$Endregion}
    Property Items;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the margins of the control.
    /// </summary>
    {$Endregion}
    Property Margins;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="BiDiMode"/>.
    /// </summary>
    {$Endregion}
    Property ParentBiDiMode;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="Color"/>.
    /// </summary>
    {$Endregion}
    Property ParentColor;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="Ctl3D"/>.
    /// </summary>
    {$Endregion}
    Property ParentCtl3D;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="DoubleBuffered"/>.
    /// </summary>
    {$Endregion}
    Property ParentDoubleBuffered;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="Font"/>.
    /// </summary>
    {$Endregion}
    Property ParentFont;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="ShowHint"/>.
    /// </summary>
    {$Endregion}
    Property ParentShowHint;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the pop-up menu associated with the control.
    /// </summary>
    {$Endregion}
    Property PopupMenu;
    {$Region 'xmldoc'}
    /// <summary>
    /// Determines whether the user can change the field value using the control.
    /// </summary>
    {$Endregion}
    Property Readonly;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control displays a Help <see cref="Hint"/> when the mouse
    /// pointer rests momentarily on the control.
    /// </summary>
    {$Endregion}
    Property ShowHint;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the items in the list are arranged alphabetically.
    /// </summary>
    {$Endregion}
    Property Sorted;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the position of the control in its parent's tab order.
    /// </summary>
    {$Endregion}
    Property TabOrder;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the user can tab to a control.
    /// </summary>
    {$Endregion}
    Property TabStop;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets thet text that is displayed as a text watermark in the control.
    /// NOTE: This feature is only available in Windows Vista and later.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property TextHint;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the touch manager component associated with the control.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property Touch;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control appears onscreen.
    /// </summary>
    {$Endregion}
    Property Visible;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user clicks the control.
    /// </summary>
    {$Endregion}
    Property OnClick;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the drop-down list closes up due to some user action.
    /// </summary>
    {$Endregion}
    Property OnCloseUp;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user right-clicks the control or otherwise invokes the pop-up
    /// menu (such as using the keyboard).
    /// </summary>
    {$Endregion}
    Property OnContextPopup;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user double-clicks the left mouse button when the mouse pointer
    /// is over the control.
    /// </summary>
    {$Endregion}
    Property OnDblClick;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user drops an object being dragged on the control.
    /// </summary>
    {$Endregion}
    Property OnDragDrop;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user drags an object over the control.
    /// </summary>
    {$Endregion}
    Property OnDragOver;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when text label of an item needs to be displayed.
    /// </summary>
    {$Endregion}
    Property OnDrawItemLabel;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user opens the drop-down list.
    /// </summary>
    {$Endregion}
    Property OnDropDown;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the dragging of an object ends, either by docking the object or
    /// by canceling the dragging.
    /// </summary>
    {$Endregion}
    Property OnEndDock;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the dragging of an object ends, either by dropping the object or
    /// by canceling the dragging.
    /// </summary>
    {$Endregion}
    Property OnEndDrag;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when a control receives the input focus.
    /// </summary>
    {$Endregion}
    Property OnEnter;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the input focus shifts away from one control to another.
    /// </summary>
    {$Endregion}
    Property OnExit;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when user performs a gesture associated with the control.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property OnGesture;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when <see cref="Items"/> property changed.
    /// </summary>
    {$Endregion}
    Property OnItemsChange;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when a user presses any key while the control has focus.
    /// </summary>
    {$Endregion}
    Property OnKeyDown;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when key pressed.
    /// </summary>
    {$Endregion}
    Property OnKeyPress;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user releases a key that has been pressed.
    /// </summary>
    {$Endregion}
    Property OnKeyUp;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user presses a mouse button with the mouse pointer over the
    /// control and the parent form is not active.
    /// </summary>
    {$Endregion}
    Property OnMouseActivate;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user presses a mouse button with the mouse pointer over the
    /// control.
    /// </summary>
    {$Endregion}
    Property OnMouseDown;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user moves the mouse pointer while the mouse pointer is over
    /// the control.
    /// </summary>
    {$Endregion}
    Property OnMouseMove;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user releases a mouse button that was pressed with the mouse
    /// pointer over the control.
    /// </summary>
    {$Endregion}
    Property OnMouseUp;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user moves the mouse into the control.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property OnMouseEnter;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user moves the mouse outside of the control.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property OnMouseLeave;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the mouse wheel is rotated.
    /// </summary>
    {$Endregion}
    Property OnMouseWheel;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the mouse wheel is rotated downward.
    /// </summary>
    {$Endregion}
    Property OnMouseWheelDown;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the mouse wheel is rotated upward.
    /// </summary>
    {$Endregion}
    Property OnMouseWheelUp;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs immediately after the control is resized.
    /// </summary>
    {$Endregion}
    Property OnResize;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user selects an item in the drop-down list
    /// </summary>
    {$Endregion}
    Property OnSelect;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user begins to drag the control with a <see cref="DragKind"/>
    /// of <see cref="DragKind.dkDock"/>.
    /// </summary>
    {$Endregion}
    Property OnStartDock;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user begins to drag the control with a <see cref="DragKind"/>
    /// of <see cref="DragKind.dkDrag"/>.
    /// </summary>
    {$Endregion}
    Property OnStartDrag;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TCustomDBCurrencyListBox is the base class for data-aware list box controls that enable
/// users to choose value of a currency symbol field from a list of <see cref="TCurrencyInfo"/>
/// objects.
/// </summary>
/// <remarks>
/// <para>
/// Use TCustomDBCurrencyListBox as a base class when defining data-aware list box controls
/// that provide a list of <see cref="TCurrencyInfo"/> objects to update value of a database
/// field.
/// </para>
/// <para>
/// The type of the database field must be string (size of 3 characters) to store the
/// international monetary symbol of the selected <see cref="TCurrencyInfo"/> object.
/// </para>
/// </remarks>
{$Endregion}

  TCustomDBCurrencyListBox = Class(TCustomCurrencyListBox)
   Private
    fDataLink : TFieldDataLink;
    Function GetDataField : WideString; Inline;
    Procedure SetDataField(Const Value : WideString); Inline;
    Function GetDataSource : TDataSource; Inline;
    Procedure SetDataSource(Value : TDataSource); Inline;
    Function GetField : TField; Inline;
    Function GetReadOnly : Boolean; Inline;
    Procedure SetReadOnly(Value : Boolean); Inline;
    Procedure UpdateData(Sender : TObject);
    Procedure DataChange(Sender : TObject);
    Procedure CMExit(Var Message : TCMExit); Message CM_EXIT;
    Procedure CMGetDataLink(Var Message : TMessage); Message CM_GETDATALINK;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Prevents <see cref="ItemSelected"/> property to be saved and loaded.
    /// </summary>
    /// <param name="Filer">
    /// The current <see cref="TReader"/> or <see cref="TWriter"/> object that is
    /// loading or saving the published properties.
    /// </param>
    {$Endregion}
    Procedure DefineProperties(Filer : TFiler); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Updates the control when it is first loaded into memory.
    /// </summary>
    {$Endregion}
    Procedure Loaded; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Responds to mouse clicks.
    /// </summary>
    {$Endregion}
    Procedure Click; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Responds when the user presses a key.
    /// </summary>
    /// <param name="Key">
    /// The key that was pressed. If the method changes Key to 0, processing of the keystroke stops.
    /// </param>
    /// <param name="Shift">
    /// Indicates the concurrent state of the Ctrl, Shift, and Alt keys.
    /// </param>
    {$Endregion}
    Procedure KeyDown(Var Key : Word; Shift : TShiftState); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Responds when the user presses a key while the control has focus.
    /// </summary>
    /// <param name="Key">
    /// The key code of the key that was pressed.
    /// </param>
    {$Endregion}
    Procedure KeyPress(Var Key : Char); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Provides specific message responses for the control.
    /// </summary>
    /// <param name="Message">
    /// The message's details.
    /// </param>
    {$Endregion}
    Procedure WndProc(Var Message : TMessage); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Responds to changes in the <see cref="Items"/> property
    /// </summary>
    {$Endregion}
    Procedure DoItemsChange; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Helps the data-aware control manage its link to the data source and respond
    /// to data events.
    /// </summary>
    {$Endregion}
    Property DataLink : TFieldDataLink Read fDataLink;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the name of the currency symbol field that is represented by
    /// the control.
    /// </summary>
    {$Endregion}
    Property DataField : WideString Read GetDataField Write SetDataField;
    {$Region 'xmldoc'}
    /// <summary>
    /// Links the control to the dataset that contains the field it represents.
    /// </summary>
    {$Endregion}
    Property DataSource : TDataSource Read GetDataSource Write SetDataSource;
    {$Region 'xmldoc'}
    /// <summary>
    /// Determines whether the user can change the field value using the control.
    /// </summary>
    {$Endregion}
    Property Readonly : Boolean Read GetReadOnly Write SetReadOnly Default False;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the control.
    /// </summary>
    /// <param name="AOwner">
    /// The owner component.
    /// </param>
    {$Endregion}
    Constructor Create(AOwner : TComponent); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Destroys the control and releases its allocated memory.
    /// </summary>
    {$Endregion}
    Destructor Destroy; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Invokes an action with the control as its target.
    /// </summary>
    /// <param name="Action">
    /// Specifies the action that was invoked.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the action was successfully dispatched,
    /// and <see langword="false"/> if the control could not handle the action.
    /// </returns>
    /// <seealso cref="UpdateAction"/>
    {$Endregion}
    Function ExecuteAction(Action : TBasicAction) : Boolean; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Updates an action to reflect the current state of the control.
    /// </summary>
    /// <param name="Action">
    /// Specifies the action that should be updated.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the action component now reflects the
    /// state of the control, and <see langword="false"/> if it did not know how
    /// to update the action.
    /// </returns>
    /// <seealso cref="ExecuteAction"/>
    {$Endregion}
    Function UpdateAction(Action : TBasicAction) : Boolean; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Specifies whether the control's alignment is in a right-to-left mode.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> if the control's alignment is in a right-to-left
    /// mode, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function UseRightToLeftAlignment : Boolean; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the <see cref="TField"/> object for the database field that the control
    /// represents.
    /// </summary>
    {$Endregion}
    Property Field : TField Read GetField;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TDBCurrencyListBox is a data-aware list box control that enables users to choose value
/// of a currency symbol field from a list of <see cref="TCurrencyInfo"/> objects.
/// </summary>
/// <remarks>
/// <para>
/// Use TDBCurrencyListBox to enable users to choose value of a database field, which
/// represents an international monetary symbol, from a list of <see cref="TCurrencyInfo"/>
/// objects.
/// </para>
/// <para>
/// The type of the database field must be string (size of 3 characters) to store the
/// international monetary symbol of the selected <see cref="TCurrencyInfo"/> object.
/// </para>
/// <para>
/// TDBCurrencyListBox publishes many of the properties, events, and methods of
/// <see cref="TCustomDBCurrencyListBox"/>, but does not introduce any new behavior.
/// </para>
/// </remarks>
/// <group name="Components"/>
{$Endregion}
{$IFDEF COMPILER_XE2_UP}

  [ComponentPlatformsAttribute(pidWin32 Or pidWin64)]
  {$ENDIF}
  TDBCurrencyListBox = Class(TCustomDBCurrencyListBox)
   Published
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets how the control aligns within its container (parent control).
    /// </summary>
    {$Endregion}
    Property Align;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether a control should be constrained by <see cref="Margins"/>.
    /// </summary>
    {$Endregion}
    Property AlignWithMargins;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets how the control is anchored to its parent.
    /// </summary>
    {$Endregion}
    Property Anchors;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the user can give focus to items by typing in the list.
    /// </summary>
    {$Endregion}
    Property AutoComplete;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the delay between a key press and an attempt to <see cref="AutoComplete"/>.
    /// </summary>
    {$Endregion}
    Property AutoCompleteDelay;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets which edges of the control are beveled.
    /// </summary>
    {$Endregion}
    Property BevelEdges;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the cut of the inner bevel.
    /// </summary>
    {$Endregion}
    Property BevelInner;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the control's bevel style.
    /// </summary>
    {$Endregion}
    Property BevelKind;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the cut of the outer bevel.
    /// </summary>
    {$Endregion}
    Property BevelOuter;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the bidirectional mode for the control.
    /// </summary>
    {$Endregion}
    Property BiDiMode;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control has a border.
    /// </summary>
    {$Endregion}
    Property BorderStyle;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the background color of the control.
    /// </summary>
    {$Endregion}
    Property Color Nodefault;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the size constraints for the control.
    /// </summary>
    {$Endregion}
    Property Constraints;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control has a three-dimensional look.
    /// </summary>
    {$Endregion}
    Property Ctl3D;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the number of columns, in a multi-column list box, that are visible
    /// without having to scroll.
    /// </summary>
    {$Endregion}
    Property Columns;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the name of the currency symbol field that is represented by the
    /// control.
    /// </summary>
    {$Endregion}
    Property DataField;
    {$Region 'xmldoc'}
    /// <summary>
    /// Links the control to the dataset that contains the field it represents.
    /// </summary>
    {$Endregion}
    Property DataSource;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets which value of <see cref="TCultureInfo.DisplayNames"/> should be
    /// displayed as the label of items.
    /// </summary>
    {$Endregion}
    Property DisplayName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control's image is rendered directly to the window or
    /// painted to an in-memory bitmap first.
    /// </summary>
    {$Endregion}
    Property DoubleBuffered;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the image used to represent the mouse pointer when it passes
    /// into the region covered by the control.
    /// </summary>
    {$Endregion}
    Property DragCursor;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control is being dragged normally or for docking.
    /// </summary>
    {$Endregion}
    Property DragKind;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets how the control initiates drag-and-drop or drag-and-dock operations.
    /// </summary>
    {$Endregion}
    Property DragMode;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control responds to keyboard, mouse, and timer events.
    /// </summary>
    {$Endregion}
    Property Enabled;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the placement of the flag icon in regard of the text label.
    /// </summary>
    {$Endregion}
    Property FlagPosition;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the flag icons that can appear on the control.
    /// </summary>
    {$Endregion}
    Property Flags;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the attributes of text written on the control.
    /// </summary>
    {$Endregion}
    Property Font;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the text string that can appear when the user moves the mouse over
    /// the control.
    /// </summary>
    {$Endregion}
    Property Hint;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the behavior of the input method editor (IME).
    /// </summary>
    {$Endregion}
    Property ImeMode;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the input method editor (IME) to use for converting keyboard input.
    /// </summary>
    {$Endregion}
    Property ImeName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the list box displays the partial items.
    /// </summary>
    {$Endregion}
    Property IntegralHeight;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the <see cref="TCultureInfo"/> objects in the control.
    /// </summary>
    {$Endregion}
    Property Items;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the margins of the control.
    /// </summary>
    {$Endregion}
    Property Margins;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="BiDiMode"/>.
    /// </summary>
    {$Endregion}
    Property ParentBiDiMode;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="Color"/>.
    /// </summary>
    {$Endregion}
    Property ParentColor;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="Ctl3D"/>.
    /// </summary>
    {$Endregion}
    Property ParentCtl3D;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="DoubleBuffered"/>.
    /// </summary>
    {$Endregion}
    Property ParentDoubleBuffered;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="Font"/>.
    /// </summary>
    {$Endregion}
    Property ParentFont;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control uses its parent's <see cref="ShowHint"/>.
    /// </summary>
    {$Endregion}
    Property ParentShowHint;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the pop-up menu associated with the control.
    /// </summary>
    {$Endregion}
    Property PopupMenu;
    {$Region 'xmldoc'}
    /// <summary>
    /// Determines whether the user can change the field value using the control.
    /// </summary>
    {$Endregion}
    Property Readonly;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the width, in pixels, by which the list box can scroll horizontally.
    /// </summary>
    {$Endregion}
    Property ScrollWidth;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control displays a Help <see cref="Hint"/> when the mouse
    /// pointer rests momentarily on the control.
    /// </summary>
    {$Endregion}
    Property ShowHint;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the items in the list are arranged alphabetically.
    /// </summary>
    {$Endregion}
    Property Sorted;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the position of the control in its parent's tab order.
    /// </summary>
    {$Endregion}
    Property TabOrder;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the user can tab to a control.
    /// </summary>
    {$Endregion}
    Property TabStop;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the size of the tabs in the list box.
    /// </summary>
    {$Endregion}
    Property TabWidth;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the touch manager component associated with the control.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property Touch;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control appears onscreen.
    /// </summary>
    {$Endregion}
    Property Visible;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user clicks the control.
    /// </summary>
    {$Endregion}
    Property OnClick;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user right-clicks the control or otherwise invokes the pop-up
    /// menu (such as using the keyboard).
    /// </summary>
    {$Endregion}
    Property OnContextPopup;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user double-clicks the left mouse button when the mouse pointer
    /// is over the control.
    /// </summary>
    {$Endregion}
    Property OnDblClick;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user drops an object being dragged on the control.
    /// </summary>
    {$Endregion}
    Property OnDragDrop;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user drags an object over the control.
    /// </summary>
    {$Endregion}
    Property OnDragOver;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when text label of an item needs to be displayed.
    /// </summary>
    {$Endregion}
    Property OnDrawItemLabel;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the dragging of an object ends, either by docking the object or
    /// by canceling the dragging.
    /// </summary>
    {$Endregion}
    Property OnEndDock;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the dragging of an object ends, either by dropping the object or
    /// by canceling the dragging.
    /// </summary>
    {$Endregion}
    Property OnEndDrag;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when a control receives the input focus.
    /// </summary>
    {$Endregion}
    Property OnEnter;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the input focus shifts away from one control to another.
    /// </summary>
    {$Endregion}
    Property OnExit;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when user performs a gesture associated with the control.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property OnGesture;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when <see cref="Items"/> property changed.
    /// </summary>
    {$Endregion}
    Property OnItemsChange;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when a user presses any key while the control has focus.
    /// </summary>
    {$Endregion}
    Property OnKeyDown;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when key pressed.
    /// </summary>
    {$Endregion}
    Property OnKeyPress;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user releases a key that has been pressed.
    /// </summary>
    {$Endregion}
    Property OnKeyUp;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user presses a mouse button with the mouse pointer over the
    /// control and the parent form is not active.
    /// </summary>
    {$Endregion}
    Property OnMouseActivate;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user presses a mouse button with the mouse pointer over the
    /// control.
    /// </summary>
    {$Endregion}
    Property OnMouseDown;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user moves the mouse pointer while the mouse pointer is over
    /// the control.
    /// </summary>
    {$Endregion}
    Property OnMouseMove;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user releases a mouse button that was pressed with the mouse
    /// pointer over the control.
    /// </summary>
    {$Endregion}
    Property OnMouseUp;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user moves the mouse into the control.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property OnMouseEnter;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user moves the mouse outside of the control.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property OnMouseLeave;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the mouse wheel is rotated.
    /// </summary>
    {$Endregion}
    Property OnMouseWheel;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the mouse wheel is rotated downward.
    /// </summary>
    {$Endregion}
    Property OnMouseWheelDown;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the mouse wheel is rotated upward.
    /// </summary>
    {$Endregion}
    Property OnMouseWheelUp;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs immediately after the control is resized.
    /// </summary>
    {$Endregion}
    Property OnResize;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user begins to drag the control with a <see cref="DragKind"/>
    /// of <see cref="DragKind.dkDock"/>.
    /// </summary>
    {$Endregion}
    Property OnStartDock;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user begins to drag the control with a <see cref="DragKind"/>
    /// of <see cref="DragKind.dkDrag"/>.
    /// </summary>
    {$Endregion}
    Property OnStartDrag;
  End;

Implementation

 Uses
  Types, VDBConsts, Forms, StdCtrls;

{ TCustomDBImageLabel }

 Constructor TCustomDBImageLabel.Create(AOwner : TComponent);
  Begin
   Inherited Create(AOwner);
   ControlStyle           := ControlStyle + [csReplicatable];
   fDataLink              := TFieldDataLink.Create;
   fDataLink.Control      := Self;
   fDataLink.OnDataChange := DataChange;
   AutoSize               := False;
  End;

 Destructor TCustomDBImageLabel.Destroy;
  Begin
   FreeAndNil(fDataLink);
   Inherited Destroy;
  End;

 Procedure TCustomDBImageLabel.Loaded;
  Begin
   Inherited Loaded;
   If csDesigning In ComponentState Then
    DataChange(Self);
  End;

 Function TCustomDBImageLabel.GetDataField : WideString;
  Begin
   Result := DataLink.FieldName;
  End;

 Procedure TCustomDBImageLabel.SetDataField(Const Value : WideString);
  Begin
   DataLink.FieldName := Value;
  End;

 Function TCustomDBImageLabel.GetDataSource : TDataSource;
  Begin
   Result := DataLink.DataSource;
  End;

 Procedure TCustomDBImageLabel.SetDataSource(Value : TDataSource);
  Begin
   DataLink.DataSource := Value;
  End;

 Function TCustomDBImageLabel.GetField : TField;
  Begin
   If Assigned(DataLink) Then
    Result := DataLink.Field
   Else
    Result := Nil;
  End;

 Function TCustomDBImageLabel.GetLabelText : String;
  Begin
   If Assigned(Field) Then
    Result := Inherited GetLabelText
   Else If csDesigning In ComponentState Then
    Result := Name
   Else
    Result := '';
  End;

 Procedure TCustomDBImageLabel.SetAutoSize(Value : Boolean);
  Begin
   If AutoSize <> Value Then
    Begin
     If Value And fDataLink.DataSourceFixed Then
      DatabaseError(SDataSourceFixed);
     Inherited SetAutoSize(Value);
    End;
  End;

 Procedure TCustomDBImageLabel.CMGetDataLink(Var Message : TMessage);
  Begin
   Message.Result := Integer(DataLink);
  End;

 Procedure TCustomDBImageLabel.DataChange(Sender : TObject);
  Begin
   If Assigned(Field) And Not Field.IsNull Then
    Caption := Field.DisplayText
   Else
    Caption := '';
  End;

 Function TCustomDBImageLabel.UseRightToLeftAlignment : Boolean;
  Begin
   Result := DBUseRightToLeftAlignment(Self, Field)
  End;

{ TCustomDBCultureLabel }

 Constructor TCustomDBCultureLabel.Create(AOwner : TComponent);
  Begin
   Inherited Create(AOwner);
   ControlStyle           := ControlStyle + [csReplicatable];
   fDataLink              := TFieldDataLink.Create;
   fDataLink.Control      := Self;
   fDataLink.OnDataChange := DataChange;
   AutoSize               := False;
  End;

 Destructor TCustomDBCultureLabel.Destroy;
  Begin
   FreeAndNil(fDataLink);
   Inherited Destroy;
  End;

 Procedure TCustomDBCultureLabel.DefineProperties(Filer : TFiler);
  Begin
   Inherited Culture := Nil;
   Inherited DefineProperties(Filer);
   DataChange(Self);
  End;

 Procedure TCustomDBCultureLabel.Loaded;
  Begin
   Inherited Loaded;
   If csDesigning In ComponentState Then
    DataChange(Self);
  End;

 Function TCustomDBCultureLabel.GetCulture : TCultureInfo;
  Begin
   Result := Inherited Culture;
  End;

 Function TCustomDBCultureLabel.GetDataField : WideString;
  Begin
   Result := DataLink.FieldName;
  End;

 Procedure TCustomDBCultureLabel.SetDataField(Const Value : WideString);
  Begin
   DataLink.FieldName := Value;
  End;

 Function TCustomDBCultureLabel.GetDataSource : TDataSource;
  Begin
   Result := DataLink.DataSource;
  End;

 Procedure TCustomDBCultureLabel.SetDataSource(Value : TDataSource);
  Begin
   DataLink.DataSource := Value;
  End;

 Function TCustomDBCultureLabel.GetField : TField;
  Begin
   If Assigned(DataLink) Then
    Result := DataLink.Field
   Else
    Result := Nil;
  End;

 Function TCustomDBCultureLabel.GetLabelText : String;
  Begin
   If Assigned(Field) Then
    Result := Inherited GetLabelText
   Else If csDesigning In ComponentState Then
    Result := Name
   Else
    Result := '';
  End;

 Function TCustomDBCultureLabel.GetImageIndex : TImageIndex;
  Begin
   If Assigned(Field) Then
    Result := Inherited GetImageIndex
   Else
    Result := -1;
  End;

 Procedure TCustomDBCultureLabel.SetAutoSize(Value : Boolean);
  Begin
   If AutoSize <> Value Then
    Begin
     If Value And fDataLink.DataSourceFixed Then
      DatabaseError(SDataSourceFixed);
     Inherited SetAutoSize(Value);
    End;
  End;

 Procedure TCustomDBCultureLabel.CMGetDataLink(Var Message : TMessage);
  Begin
   Message.Result := Integer(DataLink);
  End;

 Procedure TCustomDBCultureLabel.DataChange(Sender : TObject);
  Begin
   If Assigned(Field) And Not Field.IsNull Then
    If Field Is TNumericField Then
     Inherited Culture := CultureOf(Field.AsInteger)  // Locale ID
    Else
     Inherited Culture := CultureOf(Field.AsString)   // Locale Name
   Else
    Inherited Culture := Nil;
  End;

 Function TCustomDBCultureLabel.UseRightToLeftAlignment : Boolean;
  Begin
   Result := DBUseRightToLeftAlignment(Self, Field);
  End;

{ TCustomDBCultureBox }

 Constructor TCustomDBCultureBox.Create(AOwner : TComponent);
  Begin
   Inherited Create(AOwner);
   ControlStyle           := ControlStyle + [csReplicatable];
   fDataLink              := TFieldDataLink.Create;
   fDataLink.Control      := Self;
   fDataLink.OnDataChange := DataChange;
   fDataLink.OnUpdateData := UpdateData;
  End;

 Destructor TCustomDBCultureBox.Destroy;
  Begin
   FreeAndNil(fDataLink);
   Inherited Destroy;
  End;

 Procedure TCustomDBCultureBox.DefineProperties(Filer : TFiler);
  Begin
   ItemIndex := -1;
   Inherited DefineProperties(Filer);
   DataChange(Self);
  End;

 Procedure TCustomDBCultureBox.Loaded;
  Begin
   Inherited Loaded;
   If csDesigning In ComponentState Then
    DataChange(Self);
  End;

 Procedure TCustomDBCultureBox.Select;
  Begin
   If DataLink.Edit Then
    Begin
     Inherited Select;
     DataLink.Modified;
    End;
  End;

 Procedure TCustomDBCultureBox.KeyDown(Var Key : Word; Shift : TShiftState);
  Begin
   If (Key <> VK_TAB) And Not DataLink.CanModify Then
    Key := 0;
   Inherited KeyDown(Key, Shift);
  End;

 Procedure TCustomDBCultureBox.KeyPress(Var Key : Char);
  Begin
   If Not DataLink.CanModify Then
    Key := #0
   Else If Key = #27 Then
    DataLink.Reset;
   Inherited KeyPress(Key);
  End;

 Procedure TCustomDBCultureBox.CMExit(Var Message : TCMExit);
  Begin
   Try
    DataLink.UpdateRecord;
   Except
    SelectAll;
    SetFocus;
    Raise;
   End;
   Inherited;
  End;

 Procedure TCustomDBCultureBox.CMGetDataLink(Var Message : TMessage);
  Begin
   Message.Result := Integer(DataLink);
  End;

 Procedure TCustomDBCultureBox.WndProc(Var Message : TMessage);
  Begin
   If Not(csDesigning In ComponentState) Then
    Case Message.Msg Of
     WM_LBUTTONDOWN :
      If Not DataLink.Edit Then
       Begin
        SetFocus;
        With TWMLButtonDown(Message) Do
         MouseDown(mbLeft, KeysToShiftState(Keys), XPos, YPos);
        Exit;
       End;
     WM_COMMAND :
      If (TWMCommand(Message).NotifyCode = CBN_SELCHANGE) And Not DataLink.Edit Then
       Begin
        PostMessage(Handle, CB_SHOWDROPDOWN, 0, 0);
        Exit;
       End;
     CB_SHOWDROPDOWN :
      If Message.WParam <> 0 Then
       DataLink.Edit
      Else If Not DataLink.Editing Then
       DataChange(Self); // Restore last value
    End;
   Inherited WndProc(Message);
  End;

 Procedure TCustomDBCultureBox.UpdateData(Sender : TObject);
  Begin
   If Assigned(Field) Then
    Begin
     If Assigned(ItemSelected) Then
      If Field Is TNumericField Then
       Field.AsInteger := ItemSelected.LocaleID
      Else
       Field.AsString := ItemSelected.Locale
     Else
      Field.Clear;
    End;
  End;

 Procedure TCustomDBCultureBox.DataChange(Sender : TObject);
  Begin
   If Assigned(Field) And Not Field.IsNull Then
    If Field Is TNumericField Then
     ItemSelected := CultureOf(Field.AsInteger)
    Else
     ItemSelected := CultureOf(Field.AsString)
   Else
    ItemSelected := Nil;
  End;

 Function TCustomDBCultureBox.GetDataField : WideString;
  Begin
   Result := DataLink.FieldName;
  End;

 Procedure TCustomDBCultureBox.SetDataField(Const Value : WideString);
  Begin
   DataLink.FieldName := Value;
  End;

 Function TCustomDBCultureBox.GetDataSource : TDataSource;
  Begin
   Result := DataLink.DataSource;
  End;

 Procedure TCustomDBCultureBox.SetDataSource(Value : TDataSource);
  Begin
   DataLink.DataSource := Value;
  End;

 Function TCustomDBCultureBox.GetReadOnly : Boolean;
  Begin
   Result := DataLink.ReadOnly;
  End;

 Procedure TCustomDBCultureBox.SetReadOnly(Value : Boolean);
  Begin
   DataLink.ReadOnly := Value;
  End;

 Function TCustomDBCultureBox.GetField : TField;
  Begin
   Result := DataLink.Field;
  End;

 Procedure TCustomDBCultureBox.DoItemsChange;
  Begin
   DataChange(Self);
   Inherited DoItemsChange;
  End;

 Function TCustomDBCultureBox.UpdateAction(Action : TBasicAction) : Boolean;
  Begin
   Result := Inherited UpdateAction(Action) Or Assigned(DataLink) And
   DataLink.UpdateAction(Action);
  End;

 Function TCustomDBCultureBox.ExecuteAction(Action : TBasicAction) : Boolean;
  Begin
   Result := Inherited ExecuteAction(Action) Or Assigned(DataLink) And
   DataLink.ExecuteAction(Action);
  End;

 Function TCustomDBCultureBox.UseRightToLeftAlignment : Boolean;
  Begin
   Result := DBUseRightToLeftAlignment(Self, Field);
  End;

{ TCustomDBCultureListBox }

 Constructor TCustomDBCultureListBox.Create(AOwner : TComponent);
  Begin
   Inherited Create(AOwner);
   ControlStyle           := ControlStyle + [csReplicatable];
   fDataLink              := TFieldDataLink.Create;
   fDataLink.Control      := Self;
   fDataLink.OnDataChange := DataChange;
   fDataLink.OnUpdateData := UpdateData;
  End;

 Destructor TCustomDBCultureListBox.Destroy;
  Begin
   FreeAndNil(fDataLink);
   Inherited Destroy;
  End;

 Procedure TCustomDBCultureListBox.DefineProperties(Filer : TFiler);
  Begin
   ItemIndex := -1;
   Inherited DefineProperties(Filer);
   DataChange(Self);
  End;

 Procedure TCustomDBCultureListBox.Loaded;
  Begin
   Inherited Loaded;
   If csDesigning In ComponentState Then
    DataChange(Self);
  End;

 Procedure TCustomDBCultureListBox.Click;
  Begin
   If DataLink.Edit Then
    Begin
     Inherited Click;
     DataLink.Modified;
    End;
  End;

 Procedure TCustomDBCultureListBox.KeyDown(Var Key : Word; Shift : TShiftState);
  Begin
   If (Key <> VK_TAB) And Not DataLink.Edit Then
    Key := 0;
   Inherited KeyDown(Key, Shift);
  End;

 Procedure TCustomDBCultureListBox.KeyPress(Var Key : Char);
  Begin
   If Key = #27 Then
    DataLink.Reset
   Else If Not DataLink.Edit Then
    Key := #0;
   Inherited KeyPress(Key);
  End;

 Procedure TCustomDBCultureListBox.CMExit(Var Message : TCMExit);
  Begin
   Try
    DataLink.UpdateRecord;
   Except
    SetFocus;
    Raise;
   End;
   Inherited;
  End;

 Procedure TCustomDBCultureListBox.CMGetDataLink(Var Message : TMessage);
  Begin
   Message.Result := Integer(DataLink);
  End;

 Procedure TCustomDBCultureListBox.WndProc(Var Message : TMessage);
  Begin
   If Not(csDesigning In ComponentState) Then
    Case Message.Msg Of
     WM_LBUTTONDOWN :
      If Not DataLink.Edit Then
       Begin
        SetFocus;
        With TWMLButtonDown(Message) Do
         MouseDown(mbLeft, KeysToShiftState(Keys), XPos, YPos);
        Exit;
       End;
     WM_COMMAND :
      If (TWMCommand(Message).NotifyCode = LBN_SELCHANGE) And Not DataLink.Edit Then
       Exit;
    End;
   Inherited WndProc(Message);
  End;

 Procedure TCustomDBCultureListBox.UpdateData(Sender : TObject);
  Begin
   If Assigned(Field) Then
    Begin
     If Assigned(ItemSelected) Then
      If Field Is TNumericField Then
       Field.AsInteger := ItemSelected.LocaleID
      Else
       Field.AsString := ItemSelected.Locale
     Else
      Field.Clear;
    End;
  End;

 Procedure TCustomDBCultureListBox.DataChange(Sender : TObject);
  Begin
   If Assigned(Field) And Not Field.IsNull Then
    If Field Is TNumericField Then
     ItemSelected := CultureOf(Field.AsInteger)
    Else
     ItemSelected := CultureOf(Field.AsString)
   Else
    ItemSelected := Nil;
  End;

 Function TCustomDBCultureListBox.GetDataField : WideString;
  Begin
   Result := DataLink.FieldName;
  End;

 Procedure TCustomDBCultureListBox.SetDataField(Const Value : WideString);
  Begin
   DataLink.FieldName := Value;
  End;

 Function TCustomDBCultureListBox.GetDataSource : TDataSource;
  Begin
   Result := DataLink.DataSource;
  End;

 Procedure TCustomDBCultureListBox.SetDataSource(Value : TDataSource);
  Begin
   DataLink.DataSource := Value;
  End;

 Function TCustomDBCultureListBox.GetReadOnly : Boolean;
  Begin
   Result := DataLink.ReadOnly;
  End;

 Procedure TCustomDBCultureListBox.SetReadOnly(Value : Boolean);
  Begin
   DataLink.ReadOnly := Value;
  End;

 Function TCustomDBCultureListBox.GetField : TField;
  Begin
   Result := DataLink.Field;
  End;

 Procedure TCustomDBCultureListBox.DoItemsChange;
  Begin
   DataChange(Self);
   Inherited DoItemsChange;
  End;

 Function TCustomDBCultureListBox.UpdateAction(Action : TBasicAction) : Boolean;
  Begin
   Result := Inherited UpdateAction(Action) Or Assigned(DataLink) And
   DataLink.UpdateAction(Action);
  End;

 Function TCustomDBCultureListBox.ExecuteAction(Action : TBasicAction) : Boolean;
  Begin
   Result := Inherited ExecuteAction(Action) Or Assigned(DataLink) And
   DataLink.ExecuteAction(Action);
  End;

 Function TCustomDBCultureListBox.UseRightToLeftAlignment : Boolean;
  Begin
   Result := DBUseRightToLeftAlignment(Self, Field);
  End;

{ TCustomDBTerritoryLabel }

 Constructor TCustomDBTerritoryLabel.Create(AOwner : TComponent);
  Begin
   Inherited Create(AOwner);
   ControlStyle           := ControlStyle + [csReplicatable];
   fDataLink              := TFieldDataLink.Create;
   fDataLink.Control      := Self;
   fDataLink.OnDataChange := DataChange;
   AutoSize               := False;
  End;

 Procedure TCustomDBTerritoryLabel.DefineProperties(Filer : TFiler);
  Begin
   Inherited Territory := Nil;
   Inherited DefineProperties(Filer);
   DataChange(Self);
  End;

 Destructor TCustomDBTerritoryLabel.Destroy;
  Begin
   FreeAndNil(fDataLink);
   Inherited Destroy;
  End;

 Procedure TCustomDBTerritoryLabel.Loaded;
  Begin
   Inherited Loaded;
   If csDesigning In ComponentState Then
    DataChange(Self);
  End;

 Function TCustomDBTerritoryLabel.GetTerritory : TTerritoryInfo;
  Begin
   Result := Inherited Territory;
  End;

 Function TCustomDBTerritoryLabel.GetDataField : WideString;
  Begin
   Result := DataLink.FieldName;
  End;

 Procedure TCustomDBTerritoryLabel.SetDataField(Const Value : WideString);
  Begin
   DataLink.FieldName := Value;
  End;

 Function TCustomDBTerritoryLabel.GetDataSource : TDataSource;
  Begin
   Result := DataLink.DataSource;
  End;

 Procedure TCustomDBTerritoryLabel.SetDataSource(Value : TDataSource);
  Begin
   DataLink.DataSource := Value;
  End;

 Function TCustomDBTerritoryLabel.GetField : TField;
  Begin
   If Assigned(DataLink) Then
    Result := DataLink.Field
   Else
    Result := Nil;
  End;

 Function TCustomDBTerritoryLabel.GetLabelText : String;
  Begin
   If Assigned(Field) Then
    Result := Inherited GetLabelText
   Else If csDesigning In ComponentState Then
    Result := Name
   Else
    Result := '';
  End;

 Function TCustomDBTerritoryLabel.GetImageIndex : TImageIndex;
  Begin
   If Assigned(Field) Then
    Result := Inherited GetImageIndex
   Else
    Result := -1;
  End;

 Procedure TCustomDBTerritoryLabel.SetAutoSize(Value : Boolean);
  Begin
   If AutoSize <> Value Then
    Begin
     If Value And fDataLink.DataSourceFixed Then
      DatabaseError(SDataSourceFixed);
     Inherited SetAutoSize(Value);
    End;
  End;

 Procedure TCustomDBTerritoryLabel.CMGetDataLink(Var Message : TMessage);
  Begin
   Message.Result := Integer(DataLink);
  End;

 Procedure TCustomDBTerritoryLabel.DataChange(Sender : TObject);
  Begin
   If Assigned(Field) And Not Field.IsNull Then
    If Field Is TNumericField Then
     Inherited Territory := TerritoryOf(Field.AsInteger)
    Else
     Inherited Territory := TerritoryOf(Field.AsString)
   Else
    Inherited Territory := Nil;
  End;

 Function TCustomDBTerritoryLabel.UseRightToLeftAlignment : Boolean;
  Begin
   Result := DBUseRightToLeftAlignment(Self, Field);
  End;

{ TCustomDBTerritoryBox }

 Constructor TCustomDBTerritoryBox.Create(AOwner : TComponent);
  Begin
   Inherited Create(AOwner);
   ControlStyle           := ControlStyle + [csReplicatable];
   fDataLink              := TFieldDataLink.Create;
   fDataLink.Control      := Self;
   fDataLink.OnDataChange := DataChange;
   fDataLink.OnUpdateData := UpdateData;
  End;

 Destructor TCustomDBTerritoryBox.Destroy;
  Begin
   FreeAndNil(fDataLink);
   Inherited Destroy;
  End;

 Procedure TCustomDBTerritoryBox.DefineProperties(Filer : TFiler);
  Begin
   ItemIndex := -1;
   Inherited DefineProperties(Filer);
   DataChange(Self);
  End;

 Procedure TCustomDBTerritoryBox.Loaded;
  Begin
   Inherited Loaded;
   If csDesigning In ComponentState Then
    DataChange(Self);
  End;

 Procedure TCustomDBTerritoryBox.Select;
  Begin
   If DataLink.Edit Then
    Begin
     Inherited Select;
     DataLink.Modified;
    End;
  End;

 Procedure TCustomDBTerritoryBox.KeyDown(Var Key : Word; Shift : TShiftState);
  Begin
   If (Key <> VK_TAB) And Not DataLink.CanModify Then
    Key := 0;
   Inherited KeyDown(Key, Shift);
  End;

 Procedure TCustomDBTerritoryBox.KeyPress(Var Key : Char);
  Begin
   If Not DataLink.CanModify Then
    Key := #0
   Else If Key = #27 Then
    DataLink.Reset;
   Inherited KeyPress(Key);
  End;

 Procedure TCustomDBTerritoryBox.CMExit(Var Message : TCMExit);
  Begin
   Try
    DataLink.UpdateRecord;
   Except
    SelectAll;
    SetFocus;
    Raise;
   End;
   Inherited;
  End;

 Procedure TCustomDBTerritoryBox.CMGetDataLink(Var Message : TMessage);
  Begin
   Message.Result := Integer(DataLink);
  End;

 Procedure TCustomDBTerritoryBox.WndProc(Var Message : TMessage);
  Begin
   If Not(csDesigning In ComponentState) Then
    Case Message.Msg Of
     WM_LBUTTONDOWN :
      If Not DataLink.Edit Then
       Begin
        SetFocus;
        With TWMLButtonDown(Message) Do
         MouseDown(mbLeft, KeysToShiftState(Keys), XPos, YPos);
        Exit;
       End;
     WM_COMMAND :
      If (TWMCommand(Message).NotifyCode = CBN_SELCHANGE) And Not DataLink.Edit Then
       Begin
        PostMessage(Handle, CB_SHOWDROPDOWN, 0, 0);
        Exit;
       End;
     CB_SHOWDROPDOWN :
      If Message.WParam <> 0 Then
       DataLink.Edit
      Else If Not DataLink.Editing Then
       DataChange(Self); // Restore last value
    End;
   Inherited WndProc(Message);
  End;

 Procedure TCustomDBTerritoryBox.UpdateData(Sender : TObject);
  Begin
   If Assigned(Field) Then
    Begin
     If Assigned(ItemSelected) Then
      If Field Is TNumericField Then
       Field.AsInteger := ItemSelected.GEOID
      Else If Field.Size = 3 Then
       Field.AsString := ItemSelected.Code3
      Else
       Field.AsString := ItemSelected.Code2
     Else
      Field.Clear;
    End;
  End;

 Procedure TCustomDBTerritoryBox.DataChange(Sender : TObject);
  Begin
   If Assigned(Field) And Not Field.IsNull Then
    If Field Is TNumericField Then
     ItemSelected := TerritoryOf(Field.AsInteger)
    Else
     ItemSelected := TerritoryOf(Field.AsString)
   Else
    ItemSelected := Nil;
  End;

 Function TCustomDBTerritoryBox.GetDataField : WideString;
  Begin
   Result := DataLink.FieldName;
  End;

 Procedure TCustomDBTerritoryBox.SetDataField(Const Value : WideString);
  Begin
   DataLink.FieldName := Value;
  End;

 Function TCustomDBTerritoryBox.GetDataSource : TDataSource;
  Begin
   Result := DataLink.DataSource;
  End;

 Procedure TCustomDBTerritoryBox.SetDataSource(Value : TDataSource);
  Begin
   DataLink.DataSource := Value;
  End;

 Function TCustomDBTerritoryBox.GetReadOnly : Boolean;
  Begin
   Result := DataLink.ReadOnly;
  End;

 Procedure TCustomDBTerritoryBox.SetReadOnly(Value : Boolean);
  Begin
   DataLink.ReadOnly := Value;
  End;

 Function TCustomDBTerritoryBox.GetField : TField;
  Begin
   Result := DataLink.Field;
  End;

 Procedure TCustomDBTerritoryBox.DoItemsChange;
  Begin
   DataChange(Self);
   Inherited DoItemsChange;
  End;

 Function TCustomDBTerritoryBox.UpdateAction(Action : TBasicAction) : Boolean;
  Begin
   Result := Inherited UpdateAction(Action) Or Assigned(DataLink) And
   DataLink.UpdateAction(Action);
  End;

 Function TCustomDBTerritoryBox.ExecuteAction(Action : TBasicAction) : Boolean;
  Begin
   Result := Inherited ExecuteAction(Action) Or Assigned(DataLink) And
   DataLink.ExecuteAction(Action);
  End;

 Function TCustomDBTerritoryBox.UseRightToLeftAlignment : Boolean;
  Begin
   Result := DBUseRightToLeftAlignment(Self, Field);
  End;

{ TCustomDBTerritoryListBox }

 Constructor TCustomDBTerritoryListBox.Create(AOwner : TComponent);
  Begin
   Inherited Create(AOwner);
   ControlStyle           := ControlStyle + [csReplicatable];
   fDataLink              := TFieldDataLink.Create;
   fDataLink.Control      := Self;
   fDataLink.OnDataChange := DataChange;
   fDataLink.OnUpdateData := UpdateData;
  End;

 Destructor TCustomDBTerritoryListBox.Destroy;
  Begin
   FreeAndNil(fDataLink);
   Inherited Destroy;
  End;

 Procedure TCustomDBTerritoryListBox.DefineProperties(Filer : TFiler);
  Begin
   ItemIndex := -1;
   Inherited DefineProperties(Filer);
   DataChange(Self);
  End;

 Procedure TCustomDBTerritoryListBox.Loaded;
  Begin
   Inherited Loaded;
   If csDesigning In ComponentState Then
    DataChange(Self);
  End;

 Procedure TCustomDBTerritoryListBox.Click;
  Begin
   If DataLink.Edit Then
    Begin
     Inherited Click;
     DataLink.Modified;
    End;
  End;

 Procedure TCustomDBTerritoryListBox.KeyDown(Var Key : Word; Shift : TShiftState);
  Begin
   If (Key <> VK_TAB) And Not DataLink.Edit Then
    Key := 0;
   Inherited KeyDown(Key, Shift);
  End;

 Procedure TCustomDBTerritoryListBox.KeyPress(Var Key : Char);
  Begin
   If Key = #27 Then
    DataLink.Reset
   Else If Not DataLink.Edit Then
    Key := #0;
   Inherited KeyPress(Key);
  End;

 Procedure TCustomDBTerritoryListBox.CMExit(Var Message : TCMExit);
  Begin
   Try
    DataLink.UpdateRecord;
   Except
    SetFocus;
    Raise;
   End;
   Inherited;
  End;

 Procedure TCustomDBTerritoryListBox.CMGetDataLink(Var Message : TMessage);
  Begin
   Message.Result := Integer(DataLink);
  End;

 Procedure TCustomDBTerritoryListBox.WndProc(Var Message : TMessage);
  Begin
   If Not(csDesigning In ComponentState) Then
    Case Message.Msg Of
     WM_LBUTTONDOWN :
      If Not DataLink.Edit Then
       Begin
        SetFocus;
        With TWMLButtonDown(Message) Do
         MouseDown(mbLeft, KeysToShiftState(Keys), XPos, YPos);
        Exit;
       End;
     WM_COMMAND :
      If (TWMCommand(Message).NotifyCode = LBN_SELCHANGE) And Not DataLink.Edit Then
       Exit;
    End;
   Inherited WndProc(Message);
  End;

 Procedure TCustomDBTerritoryListBox.UpdateData(Sender : TObject);
  Begin
   If Assigned(Field) Then
    Begin
     If Assigned(ItemSelected) Then
      If Field Is TNumericField Then
       Field.AsInteger := ItemSelected.GEOID
      Else If Field.Size = 3 Then
       Field.AsString := ItemSelected.Code3
      Else
       Field.AsString := ItemSelected.Code2
     Else
      Field.Clear;
    End;
  End;

 Procedure TCustomDBTerritoryListBox.DataChange(Sender : TObject);
  Begin
   If Assigned(Field) And Not Field.IsNull Then
    If Field Is TNumericField Then
     ItemSelected := TerritoryOf(Field.AsInteger)
    Else
     ItemSelected := TerritoryOf(Field.AsString)
   Else
    ItemSelected := Nil;
  End;

 Function TCustomDBTerritoryListBox.GetDataField : WideString;
  Begin
   Result := DataLink.FieldName;
  End;

 Procedure TCustomDBTerritoryListBox.SetDataField(Const Value : WideString);
  Begin
   DataLink.FieldName := Value;
  End;

 Function TCustomDBTerritoryListBox.GetDataSource : TDataSource;
  Begin
   Result := DataLink.DataSource;
  End;

 Procedure TCustomDBTerritoryListBox.SetDataSource(Value : TDataSource);
  Begin
   DataLink.DataSource := Value;
  End;

 Function TCustomDBTerritoryListBox.GetReadOnly : Boolean;
  Begin
   Result := DataLink.ReadOnly;
  End;

 Procedure TCustomDBTerritoryListBox.SetReadOnly(Value : Boolean);
  Begin
   DataLink.ReadOnly := Value;
  End;

 Function TCustomDBTerritoryListBox.GetField : TField;
  Begin
   Result := DataLink.Field;
  End;

 Procedure TCustomDBTerritoryListBox.DoItemsChange;
  Begin
   DataChange(Self);
   Inherited DoItemsChange;
  End;

 Function TCustomDBTerritoryListBox.UpdateAction(Action : TBasicAction) : Boolean;
  Begin
   Result := Inherited UpdateAction(Action) Or Assigned(DataLink) And
   DataLink.UpdateAction(Action);
  End;

 Function TCustomDBTerritoryListBox.ExecuteAction(Action : TBasicAction) : Boolean;
  Begin
   Result := Inherited ExecuteAction(Action) Or Assigned(DataLink) And
   DataLink.ExecuteAction(Action);
  End;

 Function TCustomDBTerritoryListBox.UseRightToLeftAlignment : Boolean;
  Begin
   Result := DBUseRightToLeftAlignment(Self, Field);
  End;

{ TCustomDBCurrencyLabel }

 Constructor TCustomDBCurrencyLabel.Create(AOwner : TComponent);
  Begin
   Inherited Create(AOwner);
   ControlStyle           := ControlStyle + [csReplicatable];
   fDataLink              := TFieldDataLink.Create;
   fDataLink.Control      := Self;
   fDataLink.OnDataChange := DataChange;
   AutoSize               := False;
  End;

 Procedure TCustomDBCurrencyLabel.DefineProperties(Filer : TFiler);
  Begin
   Inherited Currency := Nil;
   Inherited DefineProperties(Filer);
   DataChange(Self);
  End;

 Destructor TCustomDBCurrencyLabel.Destroy;
  Begin
   FreeAndNil(fDataLink);
   Inherited Destroy;
  End;

 Procedure TCustomDBCurrencyLabel.Loaded;
  Begin
   Inherited Loaded;
   If csDesigning In ComponentState Then
    DataChange(Self);
  End;

 Function TCustomDBCurrencyLabel.GetCurrency : TCurrencyInfo;
  Begin
   Result := Inherited Currency;
  End;

 Function TCustomDBCurrencyLabel.GetDataField : WideString;
  Begin
   Result := DataLink.FieldName;
  End;

 Procedure TCustomDBCurrencyLabel.SetDataField(Const Value : WideString);
  Begin
   DataLink.FieldName := Value;
  End;

 Function TCustomDBCurrencyLabel.GetDataSource : TDataSource;
  Begin
   Result := DataLink.DataSource;
  End;

 Procedure TCustomDBCurrencyLabel.SetDataSource(Value : TDataSource);
  Begin
   DataLink.DataSource := Value;
  End;

 Function TCustomDBCurrencyLabel.GetField : TField;
  Begin
   If Assigned(DataLink) Then
    Result := DataLink.Field
   Else
    Result := Nil;
  End;

 Function TCustomDBCurrencyLabel.GetLabelText : String;
  Begin
   If Assigned(Field) Then
    Result := Inherited GetLabelText
   Else If csDesigning In ComponentState Then
    Result := Name
   Else
    Result := '';
  End;

 Function TCustomDBCurrencyLabel.GetImageIndex : TImageIndex;
  Begin
   If Assigned(Field) Then
    Result := Inherited GetImageIndex
   Else
    Result := -1;
  End;

 Procedure TCustomDBCurrencyLabel.SetAutoSize(Value : Boolean);
  Begin
   If AutoSize <> Value Then
    Begin
     If Value And fDataLink.DataSourceFixed Then
      DatabaseError(SDataSourceFixed);
     Inherited SetAutoSize(Value);
    End;
  End;

 Procedure TCustomDBCurrencyLabel.CMGetDataLink(Var Message : TMessage);
  Begin
   Message.Result := Integer(DataLink);
  End;

 Procedure TCustomDBCurrencyLabel.DataChange(Sender : TObject);
  Begin
   If Assigned(Field) And Not Field.IsNull Then
    Inherited Currency := CurrencyOf(Field.AsString)
   Else
    Inherited Currency := Nil;
  End;

 Function TCustomDBCurrencyLabel.UseRightToLeftAlignment : Boolean;
  Begin
   Result := DBUseRightToLeftAlignment(Self, Field);
  End;

{ TCustomDBCurrencyBox }

 Constructor TCustomDBCurrencyBox.Create(AOwner : TComponent);
  Begin
   Inherited Create(AOwner);
   ControlStyle           := ControlStyle + [csReplicatable];
   fDataLink              := TFieldDataLink.Create;
   fDataLink.Control      := Self;
   fDataLink.OnDataChange := DataChange;
   fDataLink.OnUpdateData := UpdateData;
  End;

 Destructor TCustomDBCurrencyBox.Destroy;
  Begin
   FreeAndNil(fDataLink);
   Inherited Destroy;
  End;

 Procedure TCustomDBCurrencyBox.DefineProperties(Filer : TFiler);
  Begin
   ItemIndex := -1;
   Inherited DefineProperties(Filer);
   DataChange(Self);
  End;

 Procedure TCustomDBCurrencyBox.Loaded;
  Begin
   Inherited Loaded;
   If csDesigning In ComponentState Then
    DataChange(Self);
  End;

 Procedure TCustomDBCurrencyBox.Select;
  Begin
   If DataLink.Edit Then
    Begin
     Inherited Select;
     DataLink.Modified;
    End;
  End;

 Procedure TCustomDBCurrencyBox.KeyDown(Var Key : Word; Shift : TShiftState);
  Begin
   If (Key <> VK_TAB) And Not DataLink.CanModify Then
    Key := 0;
   Inherited KeyDown(Key, Shift);
  End;

 Procedure TCustomDBCurrencyBox.KeyPress(Var Key : Char);
  Begin
   If Not DataLink.CanModify Then
    Key := #0
   Else If Key = #27 Then
    DataLink.Reset;
   Inherited KeyPress(Key);
  End;

 Procedure TCustomDBCurrencyBox.CMExit(Var Message : TCMExit);
  Begin
   Try
    DataLink.UpdateRecord;
   Except
    SelectAll;
    SetFocus;
    Raise;
   End;
   Inherited;
  End;

 Procedure TCustomDBCurrencyBox.CMGetDataLink(Var Message : TMessage);
  Begin
   Message.Result := Integer(DataLink);
  End;

 Procedure TCustomDBCurrencyBox.WndProc(Var Message : TMessage);
  Begin
   If Not(csDesigning In ComponentState) Then
    Case Message.Msg Of
     WM_LBUTTONDOWN :
      If Not DataLink.Edit Then
       Begin
        SetFocus;
        With TWMLButtonDown(Message) Do
         MouseDown(mbLeft, KeysToShiftState(Keys), XPos, YPos);
        Exit;
       End;
     WM_COMMAND :
      If (TWMCommand(Message).NotifyCode = CBN_SELCHANGE) And Not DataLink.Edit Then
       Begin
        PostMessage(Handle, CB_SHOWDROPDOWN, 0, 0);
        Exit;
       End;
     CB_SHOWDROPDOWN :
      If Message.WParam <> 0 Then
       DataLink.Edit
      Else If Not DataLink.Editing Then
       DataChange(Self); // Restore last value
    End;
   Inherited WndProc(Message);
  End;

 Procedure TCustomDBCurrencyBox.UpdateData(Sender : TObject);
  Begin
   If Assigned(Field) Then
    Begin
     If Assigned(ItemSelected) Then
      Field.AsString := ItemSelected.IntlSymbol
     Else
      Field.Clear;
    End;
  End;

 Procedure TCustomDBCurrencyBox.DataChange(Sender : TObject);
  Begin
   If Assigned(Field) And Not Field.IsNull Then
    ItemSelected := CurrencyOf(Field.AsString)
   Else
    ItemSelected := Nil;
  End;

 Function TCustomDBCurrencyBox.GetDataField : WideString;
  Begin
   Result := DataLink.FieldName;
  End;

 Procedure TCustomDBCurrencyBox.SetDataField(Const Value : WideString);
  Begin
   DataLink.FieldName := Value;
  End;

 Function TCustomDBCurrencyBox.GetDataSource : TDataSource;
  Begin
   Result := DataLink.DataSource;
  End;

 Procedure TCustomDBCurrencyBox.SetDataSource(Value : TDataSource);
  Begin
   DataLink.DataSource := Value;
  End;

 Function TCustomDBCurrencyBox.GetReadOnly : Boolean;
  Begin
   Result := DataLink.ReadOnly;
  End;

 Procedure TCustomDBCurrencyBox.SetReadOnly(Value : Boolean);
  Begin
   DataLink.ReadOnly := Value;
  End;

 Function TCustomDBCurrencyBox.GetField : TField;
  Begin
   Result := DataLink.Field;
  End;

 Procedure TCustomDBCurrencyBox.DoItemsChange;
  Begin
   DataChange(Self);
   Inherited DoItemsChange;
  End;

 Function TCustomDBCurrencyBox.UpdateAction(Action : TBasicAction) : Boolean;
  Begin
   Result := Inherited UpdateAction(Action) Or Assigned(DataLink) And
   DataLink.UpdateAction(Action);
  End;

 Function TCustomDBCurrencyBox.ExecuteAction(Action : TBasicAction) : Boolean;
  Begin
   Result := Inherited ExecuteAction(Action) Or Assigned(DataLink) And
   DataLink.ExecuteAction(Action);
  End;

 Function TCustomDBCurrencyBox.UseRightToLeftAlignment : Boolean;
  Begin
   Result := DBUseRightToLeftAlignment(Self, Field);
  End;

{ TCustomDBCurrencyListBox }

 Constructor TCustomDBCurrencyListBox.Create(AOwner : TComponent);
  Begin
   Inherited Create(AOwner);
   ControlStyle           := ControlStyle + [csReplicatable];
   fDataLink              := TFieldDataLink.Create;
   fDataLink.Control      := Self;
   fDataLink.OnDataChange := DataChange;
   fDataLink.OnUpdateData := UpdateData;
  End;

 Destructor TCustomDBCurrencyListBox.Destroy;
  Begin
   FreeAndNil(fDataLink);
   Inherited Destroy;
  End;

 Procedure TCustomDBCurrencyListBox.DefineProperties(Filer : TFiler);
  Begin
   ItemIndex := -1;
   Inherited DefineProperties(Filer);
   DataChange(Self);
  End;

 Procedure TCustomDBCurrencyListBox.Loaded;
  Begin
   Inherited Loaded;
   If csDesigning In ComponentState Then
    DataChange(Self);
  End;

 Procedure TCustomDBCurrencyListBox.Click;
  Begin
   If DataLink.Edit Then
    Begin
     Inherited Click;
     DataLink.Modified;
    End;
  End;

 Procedure TCustomDBCurrencyListBox.KeyDown(Var Key : Word; Shift : TShiftState);
  Begin
   If (Key <> VK_TAB) And Not DataLink.Edit Then
    Key := 0;
   Inherited KeyDown(Key, Shift);
  End;

 Procedure TCustomDBCurrencyListBox.KeyPress(Var Key : Char);
  Begin
   If Key = #27 Then
    DataLink.Reset
   Else If Not DataLink.Edit Then
    Key := #0;
   Inherited KeyPress(Key);
  End;

 Procedure TCustomDBCurrencyListBox.CMExit(Var Message : TCMExit);
  Begin
   Try
    DataLink.UpdateRecord;
   Except
    SetFocus;
    Raise;
   End;
   Inherited;
  End;

 Procedure TCustomDBCurrencyListBox.CMGetDataLink(Var Message : TMessage);
  Begin
   Message.Result := Integer(DataLink);
  End;

 Procedure TCustomDBCurrencyListBox.WndProc(Var Message : TMessage);
  Begin
   If Not(csDesigning In ComponentState) Then
    Case Message.Msg Of
     WM_LBUTTONDOWN :
      If Not DataLink.Edit Then
       Begin
        SetFocus;
        With TWMLButtonDown(Message) Do
         MouseDown(mbLeft, KeysToShiftState(Keys), XPos, YPos);
        Exit;
       End;
     WM_COMMAND :
      If (TWMCommand(Message).NotifyCode = LBN_SELCHANGE) And Not DataLink.Edit Then
       Exit;
    End;
   Inherited WndProc(Message);
  End;

 Procedure TCustomDBCurrencyListBox.UpdateData(Sender : TObject);
  Begin
   If Assigned(Field) Then
    Begin
     If Assigned(ItemSelected) Then
      Field.AsString := ItemSelected.IntlSymbol
     Else
      Field.Clear;
    End;
  End;

 Procedure TCustomDBCurrencyListBox.DataChange(Sender : TObject);
  Begin
   If Assigned(Field) And Not Field.IsNull Then
    ItemSelected := CurrencyOf(Field.AsString)
   Else
    ItemSelected := Nil;
  End;

 Function TCustomDBCurrencyListBox.GetDataField : WideString;
  Begin
   Result := DataLink.FieldName;
  End;

 Procedure TCustomDBCurrencyListBox.SetDataField(Const Value : WideString);
  Begin
   DataLink.FieldName := Value;
  End;

 Function TCustomDBCurrencyListBox.GetDataSource : TDataSource;
  Begin
   Result := DataLink.DataSource;
  End;

 Procedure TCustomDBCurrencyListBox.SetDataSource(Value : TDataSource);
  Begin
   DataLink.DataSource := Value;
  End;

 Function TCustomDBCurrencyListBox.GetReadOnly : Boolean;
  Begin
   Result := DataLink.ReadOnly;
  End;

 Procedure TCustomDBCurrencyListBox.SetReadOnly(Value : Boolean);
  Begin
   DataLink.ReadOnly := Value;
  End;

 Function TCustomDBCurrencyListBox.GetField : TField;
  Begin
   Result := DataLink.Field;
  End;

 Procedure TCustomDBCurrencyListBox.DoItemsChange;
  Begin
   DataChange(Self);
   Inherited DoItemsChange;
  End;

 Function TCustomDBCurrencyListBox.UpdateAction(Action : TBasicAction) : Boolean;
  Begin
   Result := Inherited UpdateAction(Action) Or Assigned(DataLink) And
   DataLink.UpdateAction(Action);
  End;

 Function TCustomDBCurrencyListBox.ExecuteAction(Action : TBasicAction) : Boolean;
  Begin
   Result := Inherited ExecuteAction(Action) Or Assigned(DataLink) And
   DataLink.ExecuteAction(Action);
  End;

 Function TCustomDBCurrencyListBox.UseRightToLeftAlignment : Boolean;
  Begin
   Result := DBUseRightToLeftAlignment(Self, Field);
  End;

End.
