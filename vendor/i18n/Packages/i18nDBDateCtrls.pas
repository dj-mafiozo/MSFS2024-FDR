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
/// fields that represent date and time values.
/// </summary>
Unit i18nDBDateCtrls;

{$I DELPHIAREA.INC}

Interface

 Uses
  SysUtils, Types, Windows, Messages, Classes, Graphics, Controls, DB,
  DBCtrls, i18nDateCtrls, i18nCalendar;

 Type
  {$Region 'xmldoc'}
  /// <summary>
  /// TCustomDBIntlDateTimeLabel is the base class for data-aware label controls
  /// that display the value of a date-time field.
  /// </summary>
  /// <remarks>
  /// <para>
  /// Use TCustomDBIntlDateTimeLabel as a base class when defining objects that
  /// display the value of a date-time database field on a form.
  /// </para>
  ///
  /// <para>
  /// TCustomDBIntlDateTimeLabel can use different calendar systems for displaying the
  /// dates. The <see cref="CalendarType"/> property is the main property that specifies
  /// which calendar system should be used by the control. If the <see cref="CalendarType"/>
  /// property is not set, the <see cref="Culture"/> property can do this task. In addition,
  /// the <see cref="Culture"/> property provides the locale specific settings of the control.
  /// If none of these two properties are set the <see cref="DefaultCalendar"/> global
  /// variable determines the calendar system used by the control.
  /// </para>
  ///
  /// <para>
  /// TCustomDBIntlDateTimeLabel can be linked to a <see cref="TLocalizer"/>
  /// component. In this case, the <see cref="TLocalizer"/> component determines
  /// the localized strings and the calendar system that should be used for displaying
  /// the date-time value.
  /// </para>
  /// </remarks>
  {$Endregion}
  TCustomDBIntlDateTimeLabel = Class(TCustomIntlDateTimeLabel)
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
    /// Gets the <see cref="TField"/> object for the database field the control
    /// represents.
    /// </summary>
    {$Endregion}
    Property Field : TField Read GetField;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TDBIntlDateTimeLabel is a data-aware label control to display the value of a
/// date-time field.
/// </summary>
/// <remarks>
/// <para>
/// Use TDBIntlDateTimeLabel to display localized value of a date-time database
/// field on a form.
/// </para>
///
/// <para>
/// TDBIntlDateTimeLabel can use different calendar systems for displaying the dates.
/// The <see cref="CalendarType"/> property is the main property that specifies which
/// calendar system should be used by the control. If the <see cref="CalendarType"/>
/// property is not set, the <see cref="Culture"/> property can do this task. In addition,
/// the <see cref="Culture"/> property provides the locale specific settings of the control.
/// If none of these two properties are set the <see cref="DefaultCalendar"/> global
/// variable determines the calendar system used by the control.
/// </para>
///
/// <para>
/// TDBIntlDateTimeLabel can be linked to a <see cref="TLocalizer"/> component.
/// In this case, the <see cref="TLocalizer"/> component determines the localized
/// strings and the calendar system that should be used for displaying the date-time
/// value.
/// </para>
///
/// <para>
/// TDBIntlDateTimeLabel publishes many of the properties, events, and methods of
/// <see cref="TCustomDBIntlDateTimeLabel"/>, but does not introduce any new behavior.
/// </para>
/// </remarks>
/// <group name="Components"/>
{$Endregion}
{$IFDEF COMPILER_XE2_UP}

  [ComponentPlatformsAttribute(pidWin32 Or pidWin64)]
  {$ENDIF}
  TDBIntlDateTimeLabel = Class(TCustomDBIntlDateTimeLabel)
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
    /// Gets or sets the <see cref="TCalendar"/> class that is used for manipulating dates.
    /// </summary>
    /// <seealso cref="Culture"/>
    {$Endregion}
    Property CalendarType;
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
    /// Gets or sets the <see cref="TCultureInfo"/> object that provides the locale specific
    /// settings of the calendar.
    /// </summary>
    /// <remarks>
    /// <para>
    /// If the <see cref="CalendarType"/> property is <see langword="nil"/>, depending
    /// on the values of <see cref="TLocalizer"/> and <see cref="CultureCalendar"/> properties,
    /// the Culture property may also determine the calendar system of the control.
    /// </para>
    /// </remarks>
    /// <seealso cref="UsingCultureCalendar"/>
    /// <seealso cref="CultureCalendar"/>
    /// <seealso cref="UsingCultureDigits"/>
    /// <seealso cref="CultureDigits"/>
    /// <seealso cref="CalendarType"/>
    /// <seealso cref="Localizer"/>
    {$Endregion}
    Property Culture;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the calendar system used by the control should be determined
    /// by the <see cref="Culture"/> or <see cref="Localizer"/> properties.
    /// </summary>
    /// <remarks>
    /// <para>
    /// Value of this property has no effect when the <see cref="CalendarType"/>
    /// property is not <see langword="nil"/>.
    /// </para>
    /// </remarks>
    /// <seealso cref="UsingCultureCalendar"/>
    /// <seealso cref="Culture"/>
    /// <seealso cref="Localizer"/>
    {$Endregion}
    Property CultureCalendar;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the way the control renders digits should be determined
    /// by the <see cref="Culture"/> or <see cref="Localizer"/> properties.
    /// </summary>
    /// <seealso cref="UsingCultureDigits"/>
    /// <seealso cref="Culture"/>
    /// <seealso cref="Localizer"/>
    {$Endregion}
    Property CultureDigits;
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
    /// Gets or sets the format string that determines how the date-time value
    /// should be displayed on the control. See <see cref="TCalendar.Format"/> for details.
    /// </summary>
    {$Endregion}
    Property DateTimeFormat;
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
    /// Gets or sets the <see cref="TLocalizer"/> component that is linked to the control.
    /// </summary>
    {$Endregion}
    Property Localizer;
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
    Property ShowAccelChar Default False;
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
    /// Gets or sets whether the label text wraps when it is too long for the
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
/// TCustomDBIntlDatePicker is the base class for data-aware controls that request
/// a localized date from the user and update a date field.
/// </summary>
/// <remarks>
/// <para>
/// Use TCustomDBIntlDatePicker as a base class when defining objects that enable
/// users to enter a localized date for a database field.
/// </para>
///
/// <para>
/// TCustomDBIntlDatePicker can use different calendar systems for getting the input
/// date. The <see cref="CalendarType"/> property is the main property that specifies
/// which calendar system should be used by the control. If the <see cref="CalendarType"/>
/// property is not set, the <see cref="Culture"/> property can do this task. In addition,
/// the <see cref="Culture"/> property provides the locale specific settings of the control.
/// If none of these two properties are set, the <see cref="DefaultCalendar"/> global
/// variable determines the calendar system used by the control.
/// </para>
///
/// <para>
/// TCustomDBIntlDatePicker can be linked to a <see cref="TLocalizer"/> component.
/// In this case, the linked <see cref="TLocalizer"/> component can provide both the
/// locale specific settings and the calendar system of the control.
/// </para>
/// </remarks>
{$Endregion}

  TCustomDBIntlDatePicker = Class(TCustomIntlDatePicker)
   Private
    fDataLink : TFieldDataLink;
    fChanging : Boolean;
    Procedure DataChange(Sender : TObject);
    Procedure UpdateData(Sender : TObject); Inline;
    Function GetDataField : WideString; Inline;
    Procedure SetDataField(Const Value : WideString); Inline;
    Function GetDataSource : TDataSource; Inline;
    Procedure SetDataSource(Value : TDataSource); Inline;
    Function GetReadOnly : Boolean; Inline;
    Procedure SetReadOnly(Value : Boolean); Inline;
    Function GetField : TField; Inline;
    Procedure CMExit(Var Message : TCMExit); Message CM_EXIT;
    Procedure CMGetDataLink(Var Message : TMessage); Message CM_GETDATALINK;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Responds when either of <see cref="Date"/> or <see cref="Checked"/> properties
    /// changes.
    /// </summary>
    {$Endregion}
    Procedure Change; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Determines whether the user can enter a different date in the control.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> if the user can enter a date, otherwise
    /// returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function CanModify : Boolean; Override;
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
    /// Helps the data-aware control manage its link to the data source and respond
    /// to data events.
    /// </summary>
    {$Endregion}
    Property DataLink : TFieldDataLink Read fDataLink;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the name of the date field that is represented by the control.
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
    /// Gets the <see cref="TField"/> object for the database field the control
    /// represents.
    /// </summary>
    {$Endregion}
    Property Field : TField Read GetField;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TDBIntlDatePicker is a data-aware control that enables the user to enter a localized
/// date for a date field.
/// </summary>
/// <remarks>
/// <para>
/// Use TDBIntlDatePicker to enable the user to enter a localized date in a database field.
/// </para>
///
/// <para>
/// TDBIntlDatePicker can use different calendar systems for getting the input date. The
/// <see cref="CalendarType"/> property is the main property that specifies which calendar
/// system should be used by the control. If the <see cref="CalendarType"/> property is not
/// set, the <see cref="Culture"/> property can do this task. In addition, the <see cref="Culture"/>
/// property provides the locale specific settings of the control. If none of these two
/// properties are set, the <see cref="DefaultCalendar"/> global variable determines the calendar
/// system used by the control.
/// </para>
///
/// <para>
/// TDBIntlDatePicker can be linked to a <see cref="TLocalizer"/> component. In this
/// case, the linked <see cref="TLocalizer"/> component can provide both the locale
/// specific settings and the calendar system of the control.
/// </para>
///
/// <para>
/// TDBIntlDatePicker publishes many of the properties, events, and methods of
/// <see cref="TCustomDBIntlDatePicker"/>, but does not introduce any new behavior.
/// </para>
/// </remarks>
/// <group name="Components"/>
{$Endregion}
{$IFDEF COMPILER_XE2_UP}

  [ComponentPlatformsAttribute(pidWin32 Or pidWin64)]
  {$ENDIF}
  TDBIntlDatePicker = Class(TCustomDBIntlDatePicker)
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
    /// Gets or sets whether the control sizes itself automatically to accommodate
    /// its contents.
    /// </summary>
    {$Endregion}
    Property AutoSize Default True;
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
    Property BevelKind Default bkNone;
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
    /// Gets or sets the border style for the control.
    /// </summary>
    {$Endregion}
    Property BorderStyle;
    {$Region 'xmldoc'}
    /// <summary>
    /// Provides access to the pop-up calendar's settings.
    /// </summary>
    {$Endregion}
    Property CalendarPopup;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the <see cref="TCalendar"/> class that is used for manipulating dates.
    /// </summary>
    /// <seealso cref="Culture"/>
    {$Endregion}
    Property CalendarType;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the background color of the control.
    /// </summary>
    {$Endregion}
    Property Color Default clWindow;
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
    /// Gets or sets the <see cref="TCultureInfo"/> object that provides the locale specific
    /// settings of the calendar.
    /// </summary>
    /// <remarks>
    /// <para>
    /// If the <see cref="CalendarType"/> property is <see langword="nil"/>, depending
    /// on the values of <see cref="TLocalizer"/> and <see cref="CultureCalendar"/> properties,
    /// the Culture property may also determine the calendar system of the control.
    /// </para>
    /// </remarks>
    /// <seealso cref="UsingCultureCalendar"/>
    /// <seealso cref="CultureCalendar"/>
    /// <seealso cref="UsingCultureDigits"/>
    /// <seealso cref="CultureDigits"/>
    /// <seealso cref="CalendarType"/>
    /// <seealso cref="Localizer"/>
    {$Endregion}
    Property Culture;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the calendar system used by the control should be determined
    /// by the <see cref="Culture"/> or <see cref="Localizer"/> properties.
    /// </summary>
    /// <remarks>
    /// <para>
    /// Value of this property has no effect when the <see cref="CalendarType"/>
    /// property is not <see langword="nil"/>.
    /// </para>
    /// </remarks>
    /// <seealso cref="UsingCultureCalendar"/>
    /// <seealso cref="Culture"/>
    /// <seealso cref="Localizer"/>
    {$Endregion}
    Property CultureCalendar;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the way the control renders digits should be determined
    /// by the <see cref="Culture"/> or <see cref="Localizer"/> properties.
    /// </summary>
    /// <seealso cref="UsingCultureDigits"/>
    /// <seealso cref="Culture"/>
    /// <seealso cref="Localizer"/>
    {$Endregion}
    Property CultureDigits;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the name of the date field that is represented by the control.
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
    /// Gets or sets the format string that determines how the <see cref="Date"/> property
    /// should be displayed on the control. See <see cref="TCalendar.Format"/> for details.
    /// </summary>
    /// <seealso cref="TCalendar.Format"/>
    {$Endregion}
    Property DateFormat;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the smallest date that is allowed for the calendar.
    /// </summary>
    /// <seealso cref="ActualDateMin"/>
    /// <seealso cref="DateMax"/>
    {$Endregion}
    Property DateMin;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the largest date that is allowed for the calendar.
    /// </summary>
    /// <seealso cref="ActualDateMax"/>
    /// <seealso cref="DateMin"/>
    {$Endregion}
    Property DateMax;
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
    /// Gets or sets the <see cref="TLocalizer"/> component that is linked to the
    /// control.
    /// </summary>
    {$Endregion}
    Property Localizer;
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
    Property ParentColor Default False;
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
    /// Gets or sets whether a check box next to the date should be displayed.
    /// </summary>
    {$Endregion}
    Property ShowCheckBox;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control displays a Help <see cref="Hint"/> when the mouse
    /// pointer rests momentarily on the control.
    /// </summary>
    {$Endregion}
    Property ShowHint;
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
    Property TabStop Default True;
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
    /// Occurs when either of <see cref="Date"/> or <see cref="Checked"/> properties change.
    /// </summary>
    {$Endregion}
    Property OnChange;
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
  VDBConsts;

{ TCustomDBIntlDateTimeLabel }

 Constructor TCustomDBIntlDateTimeLabel.Create(AOwner : TComponent);
  Begin
   Inherited Create(AOwner);
   ControlStyle           := ControlStyle + [csReplicatable];
   fDataLink              := TFieldDataLink.Create;
   fDataLink.Control      := Self;
   fDataLink.OnDataChange := DataChange;
   AutoSize               := False;
  End;

 Destructor TCustomDBIntlDateTimeLabel.Destroy;
  Begin
   FreeAndNil(fDataLink);
   Inherited Destroy;
  End;

 Procedure TCustomDBIntlDateTimeLabel.Loaded;
  Begin
   Inherited Loaded;
   If csDesigning In ComponentState Then
    DataChange(Self);
  End;

 Function TCustomDBIntlDateTimeLabel.GetDataField : WideString;
  Begin
   Result := DataLink.FieldName;
  End;

 Procedure TCustomDBIntlDateTimeLabel.SetDataField(Const Value : WideString);
  Begin
   DataLink.FieldName := Value;
  End;

 Function TCustomDBIntlDateTimeLabel.GetDataSource : TDataSource;
  Begin
   Result := DataLink.DataSource;
  End;

 Procedure TCustomDBIntlDateTimeLabel.SetDataSource(Value : TDataSource);
  Begin
   DataLink.DataSource := Value;
  End;

 Function TCustomDBIntlDateTimeLabel.GetField : TField;
  Begin
   If Assigned(DataLink) Then
    Result := DataLink.Field
   Else
    Result := Nil;
  End;

 Function TCustomDBIntlDateTimeLabel.GetLabelText : String;
  Begin
   If Assigned(Field) Then
    Result := Inherited GetLabelText
   Else If csDesigning In ComponentState Then
    Result := Name
   Else
    Result := '';
  End;

 Procedure TCustomDBIntlDateTimeLabel.SetAutoSize(Value : Boolean);
  Begin
   If AutoSize <> Value Then
    Begin
     If Value And fDataLink.DataSourceFixed Then
      DatabaseError(SDataSourceFixed);
     Inherited SetAutoSize(Value);
    End;
  End;

 Procedure TCustomDBIntlDateTimeLabel.CMGetDataLink(Var Message : TMessage);
  Begin
   Message.Result := Integer(DataLink);
  End;

 Procedure TCustomDBIntlDateTimeLabel.DataChange(Sender : TObject);
  Begin
   If Assigned(Field) And Not Field.IsNull Then
    DateTime := Field.AsDateTime
   Else
    DateTime := TCalendar.NoDate;
  End;

 Function TCustomDBIntlDateTimeLabel.UseRightToLeftAlignment : Boolean;
  Begin
   Result := DBUseRightToLeftAlignment(Self, Field);
  End;

{ TCustomDBIntlDatePicker }

 Constructor TCustomDBIntlDatePicker.Create(AOwner : TComponent);
  Begin
   Inherited Create(AOwner);
   fDataLink              := TFieldDataLink.Create;
   fDataLink.Control      := Self;
   fDataLink.OnDataChange := DataChange;
   fDataLink.OnUpdateData := UpdateData;
   Checked                := False;
  End;

 Destructor TCustomDBIntlDatePicker.Destroy;
  Begin
   FreeAndNil(fDataLink);
   Inherited Destroy;
  End;

 Procedure TCustomDBIntlDatePicker.Change;
  Begin
   If Not fChanging And DataLink.Edit Then
    Begin
     Inherited Change;
     DataLink.Modified;
    End;
  End;

 Function TCustomDBIntlDatePicker.CanModify : Boolean;
  Begin
   Result := fChanging Or DataLink.CanModify;
  End;

 Procedure TCustomDBIntlDatePicker.KeyPress(Var Key : Char);
  Begin
   If Not DataLink.CanModify Then
    Key := #0
   Else If Key = #27 Then
    DataLink.Reset;
   Inherited KeyPress(Key);
  End;

 Function TCustomDBIntlDatePicker.GetDataField : WideString;
  Begin
   Result := DataLink.FieldName;
  End;

 Procedure TCustomDBIntlDatePicker.SetDataField(Const Value : WideString);
  Begin
   DataLink.FieldName := Value;
  End;

 Function TCustomDBIntlDatePicker.GetDataSource : TDataSource;
  Begin
   Result := DataLink.DataSource;
  End;

 Procedure TCustomDBIntlDatePicker.SetDataSource(Value : TDataSource);
  Begin
   DataLink.DataSource := Value;
  End;

 Function TCustomDBIntlDatePicker.GetField : TField;
  Begin
   Result := DataLink.Field;
  End;

 Function TCustomDBIntlDatePicker.GetReadOnly : Boolean;
  Begin
   Result := DataLink.ReadOnly;
  End;

 Procedure TCustomDBIntlDatePicker.SetReadOnly(Value : Boolean);
  Begin
   DataLink.ReadOnly := Value;
  End;

 Procedure TCustomDBIntlDatePicker.CMExit(Var Message : TCMExit);
  Begin
   Try
    DataLink.UpdateRecord;
   Except
    SetFocus;
    Raise;
   End;
   Inherited;
  End;

 Procedure TCustomDBIntlDatePicker.CMGetDataLink(Var Message : TMessage);
  Begin
   Message.Result := Integer(DataLink);
  End;

 Procedure TCustomDBIntlDatePicker.DataChange(Sender : TObject);
  Begin
   fChanging := True;
   Try
    If Assigned(Field) Then
     Begin
      If Field.IsNull Then
       Checked := False
      Else
       Begin
        Checked := True;
        Date    := Field.AsDateTime;
       End;
     End
    Else
     Begin
      Date    := Calendar.Today;
      Checked := False;
     End;
   Finally
    fChanging := False;
   End;
  End;

 Procedure TCustomDBIntlDatePicker.UpdateData(Sender : TObject);
  Begin
   If Assigned(Field) Then
    Begin
     If Checked Then
      Field.AsDateTime := Date
     Else
      Field.Clear;
    End;
  End;

 Function TCustomDBIntlDatePicker.ExecuteAction(Action : TBasicAction) : Boolean;
  Begin
   Result := Inherited ExecuteAction(Action)
   Or Assigned(DataLink) And DataLink.ExecuteAction(Action);
  End;

 Function TCustomDBIntlDatePicker.UpdateAction(Action : TBasicAction) : Boolean;
  Begin
   Result := Inherited UpdateAction(Action)
   Or Assigned(DataLink) And DataLink.UpdateAction(Action);
  End;

 Function TCustomDBIntlDatePicker.UseRightToLeftAlignment : Boolean;
  Begin
   Result := DBUseRightToLeftAlignment(Self, Field);
  End;

End.
