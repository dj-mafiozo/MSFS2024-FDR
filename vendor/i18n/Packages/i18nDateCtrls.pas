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
/// This unit implements controls that represent fully localizable date and
/// time values.
/// </summary>
Unit i18nDateCtrls;

{$I DELPHIAREA.INC}

Interface

 Uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls, Forms, StdCtrls,
  i18nCore, i18nCalendar, i18nLocalizer, i18nCtrls, UxTheme;

 Type

  {$Region 'xmldoc'}
  /// <summary>
  /// TDateTimeList maintains a sorted list of <see cref="TDateTime"/> values.
  /// </summary>
  /// <remarks>
  /// Use TDateTimeList to store and maintain a list of <see cref="TDateTime"/> values,
  /// which are sorted in ascending order. TDateTimeList provides properties and methods
  /// to add, delete, locate, and access the maintained <see cref="TDateTime"/>
  /// values.
  /// </remarks>
  {$Endregion}
  TDateTimeList = Class(TPersistent)
   Private
    fList        : Array Of TDateTime;
    fCount       : Integer;
    fUpdateCount : Integer;
    fOnChanging  : TNotifyEvent;
    fOnChange    : TNotifyEvent;
    Function GetCapacity : Integer; Inline;
    Procedure SetCapacity(Value : Integer);
    Function GetItems(Index : Integer) : TDate;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnChanging"/> event.
    /// </summary>
    /// <seealso cref="Change"/>
    {$Endregion}
    Procedure Changing; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnChange"/> event.
    /// </summary>
    /// <seealso cref="Changing"/>
    {$Endregion}
    Procedure Change; Virtual;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Destroys the TDateTimeList instance and releases its allocated memory.
    /// </summary>
    {$Endregion}
    Destructor Destroy; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Copies the list of <see cref="TDateTime"/> values from another object.
    /// </summary>
    /// <param name="Source">
    /// The source list.
    /// </param>
    {$Endregion}
    Procedure Assign(Source : TPersistent); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Prevents generating of the <see cref="OnChanging"/> and <see cref="OnChange"/>
    /// events until the <see cref="EndUpdate"/> method is called.
    /// </summary>
    /// <seealso cref="EndUpdate"/>
    {$Endregion}
    Procedure BeginUpdate;
    {$Region 'xmldoc'}
    /// <summary>
    /// Reenables <see cref="OnChanging"/> and <see cref="OnChange"/> events generation
    /// that was turned off with the <see cref="BeginUpdate"/> method.
    /// </summary>
    /// <seealso cref="BeginUpdate"/>
    {$Endregion}
    Procedure EndUpdate;
    {$Region 'xmldoc'}
    /// <summary>
    /// Deletes all the <see cref="TDateTime"/> values from the list.
    /// </summary>
    {$Endregion}
    Procedure Clear; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Adds a <see cref="TDateTime"/> value to the list.
    /// </summary>
    /// <param name="ADateTime">
    /// The <see cref="TDateTime"/> value to add.
    /// </param>
    /// <returns>
    /// The index of newly added <see cref="TDateTime"/> value.
    /// </returns>
    {$Endregion}
    Function Add(Const ADateTime : TDateTime) : Integer;
    {$Region 'xmldoc'}
    /// <summary>
    /// Removes a <see cref="TDateTime"/> value from the list.
    /// </summary>
    /// <param name="ADateTime">
    /// The <see cref="TDateTime"/> value to remove.
    /// </param>
    /// <returns>
    /// The index of the removed <see cref="TDateTime"/> value or -1 if the
    /// <see cref="TDateTime"/> value is not found.
    /// </returns>
    /// <seealso cref="Delete"/>
    {$Endregion}
    Function Remove(Const ADateTime : TDateTime) : Integer;
    {$Region 'xmldoc'}
    /// <summary>
    /// Deletes a <see cref="TDateTime"/> value, which is specified by its index
    /// in the list.
    /// </summary>
    /// <param name="Index">
    /// The index of <see cref="TDateTime"/> value to remove.
    /// </param>
    /// <seealso cref="Remove"/>
    {$Endregion}
    Procedure Delete(Index : Integer);
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether a specified <see cref="TDateTime"/> value is in the list.
    /// </summary>
    /// <param name="ADateTime">
    /// The <see cref="TDateTime"/> value to examine.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the <see cref="TDateTime"/> value is in the
    /// list, otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="IndexOf"/>
    /// <seealso cref="Find"/>
    {$Endregion}
    Function Exists(Const ADateTime : TDateTime) : Boolean; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Finds the index of a specified <see cref="TDateTime"/> value in the list.
    /// </summary>
    /// <param name="ADateTime">
    /// The <see cref="TDateTime"/> value to locate.
    /// </param>
    /// <returns>
    /// Returns the index of the <see cref="TDateTime"/> value if it is in the list,
    /// otherwise returns -1.
    /// </returns>
    /// <seealso cref="Find"/>
    /// <seealso cref="Exists"/>
    {$Endregion}
    Function IndexOf(Const ADateTime : TDateTime) : Integer; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Locates the index of a specified <see cref="TDateTime"/> value in the list.
    /// </summary>
    /// <param name="ADateTime">
    /// The <see cref="TDateTime"/> value to locate.
    /// </param>
    /// <param name="Index">
    /// Receives the index of the <see cref="TDateTime"/> value in the list.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the <see cref="TDateTime"/> value is in the
    /// list, otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="IndexOf"/>
    /// <seealso cref="Exists"/>
    {$Endregion}
    Function Find(Const ADateTime : TDateTime; Out Index : Integer) : Boolean;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the smallest <see cref="TDateTime"/> value in the list.
    /// </summary>
    /// <returns>
    /// Returns <see cref="Items"/>[0], or <see cref="TCalendar.NoDate"/> if the
    /// list is empty.
    /// </returns>
    /// <seealso cref="Last"/>
    {$Endregion}
    Function First : TDateTime;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the largest <see cref="TDateTime"/> value in the list.
    /// </summary>
    /// <returns>
    /// Returns <see cref="Items"/>[<see cref="Count"/> - 1], or <see cref="TCalendar.NoDate"/>
    /// if the list is empty.
    /// </returns>
    /// <seealso cref="First"/>
    {$Endregion}
    Function Last : TDateTime;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the number of <see cref="TDateTime"/> values in the list.
    /// </summary>
    {$Endregion}
    Property Count : Integer Read fCount;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the number of <see cref="TDateTime"/> values the TDateTimeList
    /// object can hold.
    /// </summary>
    {$Endregion}
    Property Capacity : Integer Read GetCapacity Write SetCapacity;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the <see cref="TDateTime"/> values in the list.
    /// </summary>
    {$Endregion}
    Property Items[Index : Integer] : TDate Read GetItems; Default;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs immediately after the list changes.
    /// </summary>
    {$Endregion}
    Property OnChange : TNotifyEvent Read fOnChange Write fOnChange;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs immediately before the list changes.
    /// </summary>
    {$Endregion}
    Property OnChanging : TNotifyEvent Read fOnChanging Write fOnChanging;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TCustomIntlDateTimeLabel is the base class for label controls that display a
/// localized <see cref="TDateTime"/> value on a form.
/// </summary>
/// <remarks>
/// <para>
/// Use TCustomIntlDateTimeLabel as a base class when defining objects that display a
/// localized <see cref="TDateTime"/> value.
/// </para>
/// <para>
/// TCustomIntlDateTimeLabel can use different calendar systems for displaying the
/// dates. The <see cref="CalendarType"/> property is the main property that specifies
/// which calendar system should be used by the control. If the <see cref="CalendarType"/>
/// property is not set, the <see cref="Culture"/> property can do this task. In addition,
/// the <see cref="Culture"/> property provides the locale specific settings of the control.
/// If none of these two properties are set the <see cref="DefaultCalendar"/> global
/// variable determines the calendar system used by the control.
/// </para>
/// <para>
/// TCustomIntlDateTimeLabel can be linked to a <see cref="TLocalizer"/> component.
/// In this case, the <see cref="TLocalizer"/> component determines the localized strings
/// and the calendar system that should be used for displaying the <see cref="TDateTime"/>
/// value.
/// </para>
/// </remarks>
{$Endregion}

  TCustomIntlDateTimeLabel = Class(TCustomImageLabel, ILocalizerLink)
   Private
    fDateTime        : TDateTime;
    fDateTimeFormat  : String;
    fCalendarType    : TCalendarClass;
    fCalendar        : TCalendar;
    fCulture         : TCultureInfo;
    fCultureCalendar : TLocalizerSwicth;
    fCultureDigits   : TLocalizerSwicth;
    fLocalizer       : TLocalizer;
    Procedure SetDateTime(Const Value : TDateTime);
    Procedure SetDateTimeFormat(Const Value : String);
    Procedure SetCalendarType(Value : TCalendarClass);
    Procedure SetCulture(Value : TCultureInfo);
    Procedure SetCultureCalendar(Value : TLocalizerSwicth);
    Procedure SetCultureDigits(Value : TLocalizerSwicth);
    Procedure SetLocalizer(Value : TLocalizer);
    Function GetUsingCultureCalendar : Boolean;
    Function GetUsingCultureDigits : Boolean;
    Function IsDateTimeStored : Boolean;
    Procedure ReadCulture(Reader : TReader);
    Procedure WriteCulture(Writer : TWriter);
    Procedure ReadCalendarType(Reader : TReader);
    Procedure WriteCalendarType(Writer : TWriter);
    Procedure CalendarChanged(Sender : TObject);
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Notifies the control about changes in the linked <see cref="TLocalizer"/>
    /// component.
    /// </summary>
    /// <param name="Sender">
    /// The <see cref="TLocalizer"/> component who originated the notification.
    /// </param>
    /// <param name="Reason">
    /// The reason of the notification.
    /// </param>
    {$Endregion}
    Procedure LocalizerNotify(Sender : TLocalizer; Reason : TLocalizerNotification);
    {$Region 'xmldoc'}
    /// <summary>
    /// Responds to notifications that components are about to be created or destroyed.
    /// </summary>
    /// <param name="AComponent">
    /// The component which generated the notification.
    /// </param>
    /// <param name="Operation">
    /// Indicates whether the component is created or destroyed.
    /// </param>
    {$Endregion}
    Procedure Notification(AComponent : TComponent; Operation : TOperation); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Reads and writes the <see cref="Culture"/> and <see cref="CalendarType"/> properties
    /// as if they were published.
    /// </summary>
    /// <param name="Filer">
    /// The current <see cref="TReader"/> or <see cref="TWriter"/> object that is
    /// loading or saving the published properties.
    /// </param>
    {$Endregion}
    Procedure DefineProperties(Filer : TFiler); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a text label to display on the control.
    /// </summary>
    /// <returns>
    /// The text label.
    /// </returns>
    {$Endregion}
    Function GetLabelText : String; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Validates the <see cref="Calendar"/> property to ensure it represents a proper
    /// calendar system with an appropriate locale settings.
    /// </summary>
    {$Endregion}
    Procedure ValidateCalendar; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the <see cref="TDateTime"/> value to be displayed on the control.
    /// </summary>
    {$Endregion}
    Property DateTime : TDateTime Read fDateTime Write SetDateTime Stored IsDateTimeStored;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the format string that determines how the <see cref="DateTime"/> property
    /// should be displayed on the control. See <see cref="TCalendar.Format"/> for details.
    /// </summary>
    /// <seealso cref="TCalendar.Format"/>
    {$Endregion}
    Property DateTimeFormat : String Read fDateTimeFormat Write SetDateTimeFormat;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the <see cref="TCalendar"/> class that is used for manipulating dates.
    /// </summary>
    /// <seealso cref="Culture"/>
    {$Endregion}
    Property CalendarType : TCalendarClass Read fCalendarType Write SetCalendarType;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the <see cref="TCultureInfo"/> object that provides the locale specific
    /// settings of the calendar.
    ///
    /// NOTE: If the <see cref="CalendarType"/> property is <see langword="nil"/>, depends
    /// on the values of <see cref="TLocalizer"/> and <see cref="CultureCalendar"/> properties,
    /// the Culture property may also determine the calendar system of the control.
    /// </summary>
    /// <seealso cref="UsingCultureCalendar"/>
    /// <seealso cref="CultureCalendar"/>
    /// <seealso cref="UsingCultureDigits"/>
    /// <seealso cref="CultureDigits"/>
    /// <seealso cref="CalendarType"/>
    /// <seealso cref="Localizer"/>
    {$Endregion}
    Property Culture : TCultureInfo Read fCulture Write SetCulture;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the calendar system used by the control should be determined
    /// by the <see cref="Culture"/> or <see cref="Localizer"/> properties.
    /// NOTE: Value of this property has no effect when the <see cref="CalendarType"/>
    /// property is not <see langword="nil"/>.
    /// </summary>
    /// <seealso cref="UsingCultureCalendar"/>
    /// <seealso cref="Culture"/>
    /// <seealso cref="Localizer"/>
    {$Endregion}
    Property CultureCalendar : TLocalizerSwicth Read fCultureCalendar Write SetCultureCalendar Default lsDefault;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the way the control renders digits should be determined
    /// by the <see cref="Culture"/> or <see cref="Localizer"/> properties.</summary>
    /// <seealso cref="UsingCultureDigits"/>
    /// <seealso cref="Culture"/>
    /// <seealso cref="Localizer"/>
    {$Endregion}
    Property CultureDigits : TLocalizerSwicth Read fCultureDigits Write SetCultureDigits Default lsDefault;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the <see cref="TLocalizer"/> component that is linked to the control.
    /// </summary>
    {$Endregion}
    Property Localizer : TLocalizer Read fLocalizer Write SetLocalizer;
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
    /// Destroys the component and releases its allocated memory.
    /// </summary>
    {$Endregion}
    Destructor Destroy; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether the control is managed by a <see cref="TLocalizer"/> component
    /// specifying the localized strings and the calendar system for displaying the
    /// <see cref="TDateTime"/> value.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> if <see cref="Localizer"/> property is not
    /// <see langword="nil"/>, otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="Localizer"/>
    {$Endregion}
    Function IsManagedByLocalizer : Boolean; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the <see cref="TCalendar"/> object that the control is using to
    /// manipulate and display dates.
    /// </summary>
    {$Endregion}
    Property Calendar : TCalendar Read fCalendar;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets whether the calendar system used by the control is determined by the
    /// <see cref="Culture"/> property.
    /// </summary>
    /// <seealso cref="CultureCalendar"/>
    /// <seealso cref="Culture"/>
    {$Endregion}
    Property UsingCultureCalendar : Boolean Read GetUsingCultureCalendar;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets whether the way that the control renders digits is determined by the
    /// <see cref="Culture"/> property.
    /// </summary>
    /// <seealso cref="CultureDigits"/>
    /// <seealso cref="Culture"/>
    {$Endregion}
    Property UsingCultureDigits : Boolean Read GetUsingCultureDigits;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TIntlDateTimeLabel is a label control that displays a localized <see cref="TDateTime"/>
/// value on a form.
/// </summary>
/// <remarks>
/// Use TIntlDateTimeLabel to display a localized <see cref="TDateTime"/> value on a form.
/// The <see cref="DateTime"/> and <see cref="DateTimeFormat"/> properties determine the
/// content that will be displayed.
///
/// TIntlDateTimeLabel can use different calendar systems for displaying the dates.
/// The <see cref="CalendarType"/> property is the main property that specifies which
/// calendar system should be used by the control. If the <see cref="CalendarType"/>
/// property is not set, the <see cref="Culture"/> property can do this task. In addition,
/// the <see cref="Culture"/> property provides the locale specific settings of the control.
/// If none of these two properties are set the <see cref="DefaultCalendar"/> global
/// variable determines the calendar system used by the control.
///
/// TIntlDateTimeLabel can be linked to a <see cref="TLocalizer"/> component. In this case,
/// the <see cref="TLocalizer"/> component determines the localized strings and the calendar
/// system that should be used for displaying the <see cref="TDateTime"/> value.
///
/// TIntlDateTimeLabel publishes many of the properties, events, and methods of
/// <see cref="TCustomIntlDateTimeLabel"/>, but does not introduce any new behavior.
/// </remarks>
/// <group name="Components"/>
{$Endregion}
{$IFDEF COMPILER_XE2_UP}

  [ComponentPlatformsAttribute(pidWin32 Or pidWin64)]
  {$ENDIF}
  TIntlDateTimeLabel = Class(TCustomIntlDateTimeLabel)
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
    Property AutoSize;
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
    ///
    /// NOTE: If the <see cref="CalendarType"/> property is <see langword="nil"/>, depends
    /// on the values of <see cref="TLocalizer"/> and <see cref="CultureCalendar"/> properties,
    /// the Culture property may also determine the calendar system of the control.
    /// </summary>
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
    /// NOTE: Value of this property has no effect when the <see cref="CalendarType"/>
    /// property is not <see langword="nil"/>.
    /// </summary>
    /// <seealso cref="UsingCultureCalendar"/>
    /// <seealso cref="Culture"/>
    /// <seealso cref="Localizer"/>
    {$Endregion}
    Property CultureCalendar;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the way the control renders digits should be determined
    /// by the <see cref="Culture"/> or <see cref="Localizer"/> properties.</summary>
    /// <seealso cref="UsingCultureDigits"/>
    /// <seealso cref="Culture"/>
    /// <seealso cref="Localizer"/>
    {$Endregion}
    Property CultureDigits;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the <see cref="TDateTime"/> value to be displayed on the control.
    /// </summary>
    {$Endregion}
    Property DateTime;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the format string that determines how the <see cref="TDateTime"/> value
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
/// This enumeration type identifies the ways that users can select dates in a
/// month calendar control.
/// </summary>
{$Endregion}

  TIntlCalSelectionStyle = (
  {$Region 'xmldoc'}
  /// User can select only a single date at a time.
  {$Endregion}
  ssSingle,
  {$Region 'xmldoc'}
  /// User can select only a single date range at a time.
  {$Endregion}
  ssRange,
  {$Region 'xmldoc'}
  // User can freely select multiple dates or range of dates.
  {$Endregion}
  ssFree
  );

{$Region 'xmldoc'}
/// <summary>
/// This enumeration type identifies the date componenets that a user can select
/// at a time on a month calendar control.
/// calendar's page types.
/// </summary>
{$Endregion}

  TIntlCalViewMode = (
  {$Region 'xmldoc'}
  /// Displays days of a month.
  {$Endregion}
  vmDay,
  {$Region 'xmldoc'}
  /// Displays months of a year.
  {$Endregion}
  vmMonth,
  {$Region 'xmldoc'}
  /// Displays years of a decade.
  {$Endregion}
  vmYear
  );

{$Region 'xmldoc'}
/// <summary>
/// This enumeration type identifies the sections of a month calendar control
/// that a mouse pointer can be over it.
/// </summary>
{$Endregion}

  TIntlCalHitTest = (
  {$Region 'xmldoc'}
  /// Nowhere
  {$Endregion}
  chtNowhere,
  {$Region 'xmldoc'}
  /// Left navigation button
  {$Endregion}
  chtArrowLeft,
  {$Region 'xmldoc'}
  /// Right navigation button
  {$Endregion}
  chtArrowRight,
  {$Region 'xmldoc'}
  /// Text of the header
  {$Endregion}
  chtHeaderText,
  {$Region 'xmldoc'}
  /// Text of the footer
  {$Endregion}
  chtFooter,
  {$Region 'xmldoc'}
  /// Week numbers column
  {$Endregion}
  chtWeekNumber,
  {$Region 'xmldoc'}
  /// Days of week row
  {$Endregion}
  chtDayOfWeek,
  {$Region 'xmldoc'}
  /// A day of month cell
  {$Endregion}
  chtDay,
  {$Region 'xmldoc'}
  /// A month cell
  {$Endregion}
  chtMonth,
  {$Region 'xmldoc'}
  /// A year cell
  {$Endregion}
  chtYear
  );

{$Region 'xmldoc'}
/// <summary>
/// This enumeration type identifies the ways an item in a month calendar
/// control can be rendered.
/// </summary>
{$Endregion}

  TIntlCalDrawState = (
  {$Region 'xmldoc'}
  /// The drawing item is part of the header.
  {$Endregion}
  cdsHeader,
  {$Region 'xmldoc'}
  /// The drawing item is part of the footer.
  {$Endregion}
  cdsFooter,
  {$Region 'xmldoc'}
  /// The drawing item is part of the fixed row (day of week cells).
  {$Endregion}
  cdsFixedRow,
  {$Region 'xmldoc'}
  /// The drawing item is part of the fixed column (week numbers).
  {$Endregion}
  cdsFixedCol,
  {$Region 'xmldoc'}
  /// The drawing item represents today's information.
  {$Endregion}
  cdsToday,
  {$Region 'xmldoc'}
  /// The drawing item is in hot state.
  {$Endregion}
  cdsHotLight,
  {$Region 'xmldoc'}
  /// The drawing item is selected.
  {$Endregion}
  cdsSelected,
  {$Region 'xmldoc'}
  /// The drawing item has focus.
  {$Endregion}
  cdsFocused,
  {$Region 'xmldoc'}
  /// The drawing item is part of another page.
  {$Endregion}
  cdsGrayed,
  {$Region 'xmldoc'}
  /// Do not draw any content.
  {$Endregion}
  cdsBlank
  );

{$Region 'xmldoc'}
/// <summary>
/// This data type represents a set of <see cref="TIntlCalDrawState"/> values.
/// </summary>
{$Endregion}

  TIntlCalDrawStates = Set Of TIntlCalDrawState;

{$Region 'xmldoc'}
/// <summary>
/// TDateHintEvent is the type for event handlers that respond when the hint
/// string for a date is requested.
/// </summary>
/// <param name="Sender">
/// The object that generated the event.
/// </param>
/// <param name="ADate">
/// The <see cref="TDate"/> value that its hint string is requested.
/// </param>
/// <param name="HintStr">
/// The hint string of the <see cref="TDate"/> value.
/// </param>
{$Endregion}

  TDateHintEvent = Procedure(Sender : TObject; Const ADate : TDate; Var HintStr : String) Of Object;

{$Region 'xmldoc'}
/// <summary>
/// TDateSelectableEvent is the type for event handlers that decide whether a
/// date can be selected.
/// </summary>
/// <param name="Sender">
/// The object that generated the event.
/// </param>
/// <param name="ADate">
/// The <see cref="TDate"/> value to select.
/// </param>
/// <param name="CanSelect">
/// Indicates whether the <see cref="TDate"/> value can be selected.
/// </param>
{$Endregion}

  TDateSelectableEvent = Procedure(Sender : TObject; Const ADate : TDate; Var CanSelect : Boolean) Of Object;

{$Region 'xmldoc'}
/// <summary>
/// TCustomDrawTextEvent is the type for event handlers that render a text.
/// </summary>
/// <param name="Sender">
/// The object that generated the event.
/// </param>
/// <param name="Canvas">
/// The canvas on which to draw the text.
/// </param>
/// <param name="ARect">
/// The bounding rectangle on the canvas where the text should be drawn.
/// </param>
/// <param name="State">
/// The state information that can affect the way the text is drawn.
/// </param>
/// <param name="AText">
/// The text to draw.
/// </param>
/// <param name="DefaultDraw">
/// Indicates whether the default rendering should proceed after the event handler exits.
/// </param>
{$Endregion}

  TCustomDrawTextEvent = Procedure(Sender : TObject; Canvas : TCanvas; Const ARect : TRect; State : TIntlCalDrawStates; Const AText : String; Var DefaultDraw : Boolean) Of Object;

{$Region 'xmldoc'}
/// <summary>
/// TCustomDrawDayEvent is the type for event handlers that render an integer value
/// as a day of the month.
/// </summary>
/// <param name="Sender">
/// The object that generated the event.
/// </param>
/// <param name="Canvas">
/// The canvas on which to draw the day of the month.
/// </param>
/// <param name="ARect">
/// The bounding rectangle on the canvas where the day of the month should be drawn.
/// </param>
/// <param name="State">
/// The state information that can affect the way the day of the month is drawn.
/// </param>
/// <param name="ADate">
/// The <see cref="TDate"/> value that represents the day of the moneh.
/// </param>
/// <param name="ADay">
/// The day of the month to draw.
/// </param>
/// <param name="DefaultDraw">
/// Indicates whether the default rendering should proceed after the event handler exits.
/// </param>
{$Endregion}

  TCustomDrawDayEvent = Procedure(Sender : TObject; Canvas : TCanvas; Const ARect : TRect; State : TIntlCalDrawStates; Const ADate : TDate; ADay : Integer; Var DefaultDraw : Boolean) Of Object;

{$Region 'xmldoc'}
/// <summary>
/// TCustomDrawDayOfWeekEvent is the type for event handlers that render name of
/// a day of the week.
/// </summary>
/// <param name="Sender">
/// The object that generated the event.
/// </param>
/// <param name="Canvas">
/// The canvas on which to draw the day's name.
/// </param>
/// <param name="ARect">
/// The bounding rectangle on the canvas where the day's name should be drawn.
/// </param>
/// <param name="State">
/// The state information that can affect the way the day's name is drawn.
/// </param>
/// <param name="ADayOfWeek">
/// The day of the week to draw its name.
/// </param>
/// <param name="DefaultDraw">
/// Indicates whether the default rendering should proceed after the event handler exits.
/// </param>
{$Endregion}

  TCustomDrawDayOfWeekEvent = Procedure(Sender : TObject; Canvas : TCanvas; Const ARect : TRect; State : TIntlCalDrawStates; ADayOfWeek : TDayOfWeek; Var DefaultDraw : Boolean) Of Object;

{$Region 'xmldoc'}
/// <summary>
/// TCustomDrawDayEvent is the type for event handlers that render an integer value
/// as a week number of the year.
/// </summary>
/// <param name="Sender">
/// The object that generated the event.
/// </param>
/// <param name="Canvas">
/// The canvas on which to draw the week number.
/// </param>
/// <param name="ARect">
/// The bounding rectangle on the canvas where the week number should be drawn.
/// </param>
/// <param name="State">
/// The state information that can affect the way the week number is drawn.
/// </param>
/// <param name="AWeek">
/// The week of the year to draw.
/// </param>
/// <param name="DefaultDraw">
/// Indicates whether the default rendering should proceed after the event handler exits.
/// </param>
{$Endregion}

  TCustomDrawWeekNumberEvent = Procedure(Sender : TObject; Canvas : TCanvas; Const ARect : TRect; State : TIntlCalDrawStates; AWeek : Integer; Var DefaultDraw : Boolean) Of Object;

{$Region 'xmldoc'}
/// <summary>
/// TCustomDrawDayOfWeekEvent is the type for event handlers that render name of
/// a month.
/// </summary>
/// <param name="Sender">
/// The object that generated the event.
/// </param>
/// <param name="Canvas">
/// The canvas on which to draw the month's name.
/// </param>
/// <param name="ARect">
/// The bounding rectangle on the canvas where the month's name should be drawn.
/// </param>
/// <param name="State">
/// The state information that can affect the way the month's name is drawn.
/// </param>
/// <param name="AMonth">
/// The month to draw its name.
/// </param>
/// <param name="DefaultDraw">
/// Indicates whether the default rendering should proceed after the event handler exits.
/// </param>
{$Endregion}

  TCustomDrawMonthEvent = Procedure(Sender : TObject; Canvas : TCanvas; Const ARect : TRect; State : TIntlCalDrawStates; AMonth : Integer; Var DefaultDraw : Boolean) Of Object;

{$Region 'xmldoc'}
/// <summary>
/// TCustomDrawDayEvent is the type for event handlers that render an integer value
/// as a year.
/// </summary>
/// <param name="Sender">
/// The object that generated the event.
/// </param>
/// <param name="Canvas">
/// The canvas on which to draw the year.
/// </param>
/// <param name="ARect">
/// The bounding rectangle on the canvas where the year should be drawn.
/// </param>
/// <param name="State">
/// The state information that can affect the way the year is drawn.
/// </param>
/// <param name="AYear">
/// The year to draw.
/// </param>
/// <param name="DefaultDraw">
/// Indicates whether the default rendering should proceed after the event handler exits.
/// </param>
{$Endregion}

  TCustomDrawYearEvent = Procedure(Sender : TObject; Canvas : TCanvas; Const ARect : TRect; State : TIntlCalDrawStates; AYear : Integer; Var DefaultDraw : Boolean) Of Object;

{$Region 'xmldoc'}
/// <summary>
/// TCustomIntlMonthCalendar is the base class for controls that display a
/// localized calendar on a form.
/// </summary>
/// <remarks>
/// Use TCustomIntlMonthCalendar as a base class when defining objects that display a
/// localized calendar.
///
/// TCustomIntlMonthCalendar can use different calendar systems for manipulating and
/// displaying the dates. The <see cref="CalendarType"/> property is the main property
/// that specifies which calendar system should be used by the cotnrol. If the
/// <see cref="CalendarType"/> property is not set, the <see cref="Culture"/> property
/// can do this task. In addition, the <see cref="Culture"/> property provides the
/// locale specific settings of the control. If none of these two properties are set,
/// the <see cref="DefaultCalendar"/> global variable determines the calendar system
/// used by the control.
///
/// TCustomIntlDateTimeLabel can be linked to a <see cref="TLocalizer"/> component.
/// In this case, the linked <see cref="TLocalizer"/> component can provide both the
/// locale specific settings and the calendar system of the calendar control.
/// </remarks>
{$Endregion}

  TCustomIntlMonthCalendar = Class(TCustomControl, ILocalizerLink)
   Protected
    Type
    {$Region 'xmldoc'}
    /// <summary>
    /// This enumeration type identifies the sections of a month calendar control.
    /// </summary>
    {$Endregion}
    TIntlCalSection = (
    {$Region 'xmldoc'}
    /// The section of the header items.
    {$Endregion}
    csHeader,
    {$Region 'xmldoc'}
    /// The section filled by the header text.
    {$Endregion}
    csHeaderText,
    {$Region 'xmldoc'}
    /// The section filled by the left navigation button.
    {$Endregion}
    csArrowLeft,
    {$Region 'xmldoc'}
    /// The section filled by the right navigation button.
    {$Endregion}
    csArrowRight,
    {$Region 'xmldoc'}
    /// The section of the footer items.
    {$Endregion}
    csFooter,
    {$Region 'xmldoc'}
    /// The empty area shared between row of day names and column of week numbers.
    {$Endregion}
    csWeekSpace,
    {$Region 'xmldoc'}
    /// The section of names of days.
    {$Endregion}
    csDaysOfWeek,
    {$Region 'xmldoc'}
    /// The section of week numbers.
    {$Endregion}
    csWeekNumbers,
    {$Region 'xmldoc'}
    /// The section, which display days of a month, months of a year, or years of a decade.
    {$Endregion}
    csYMD
    );
    {$Region 'xmldoc'}
    /// <summary>
    /// This data type represents a set of <see cref="TIntlCalSection"/> values.
    /// </summary>
    {$Endregion}
    TIntlCalSections = Set Of TIntlCalSection;
    {$Region 'xmldoc'}
    /// <summary>
    /// This enumeration type identifies different kind of names for days of week and
    /// months.
    /// </summary>
    {$Endregion}
    TIntlCalNameKind = (
    {$Region 'xmldoc'}
    /// Full name
    {$Endregion}
    nkLong,
    {$Region 'xmldoc'}
    /// Abbreviation
    {$Endregion}
    nkShort,
    {$Region 'xmldoc'}
    /// Shortest possible abbreviation
    {$Endregion}
    nkShortest
    );
    {$Region 'xmldoc'}
    /// <summary>
    /// This data type represents the internal metrics of a month calendar control.
    /// </summary>
    {$Endregion}
    TIntlCalMetrics = Record
     {$Region 'xmldoc'}
     /// Full, abbreviation, or short name?
     {$Endregion}
     NameKind : TIntlCalNameKind;
     {$Region 'xmldoc'}
     /// Long or short date format for footer?
     {$Endregion}
     LongFormat : Boolean;
     {$Region 'xmldoc'}
     /// The client rectangle of the month calendar
     {$Endregion}
     Bounds : TRect;
     {$Region 'xmldoc'}
     /// The height of the header section
     {$Endregion}
     HeaderHeight : Integer;
     {$Region 'xmldoc'}
     /// The height of the footer section
     {$Endregion}
     FooterHeight : Integer;
     {$Region 'xmldoc'}
     /// The row's height for names of days
     {$Endregion}
     FixedRowHeight : Integer;
     {$Region 'xmldoc'}
     /// The column's width for week numbers
     {$Endregion}
     FixedColWidth : Integer;
     {$Region 'xmldoc'}
     /// The row's height for day, month, year, or decade
     {$Endregion}
     RowHeight : Integer;
     {$Region 'xmldoc'}
     /// The column's width for day, month, year, or decade
     {$Endregion}
     ColWidth : Integer;
     {$Region 'xmldoc'}
     /// The number of rows excluding the fixed row
     {$Endregion}
     RowCount : Integer;
     {$Region 'xmldoc'}
     /// The number of columns excluding the fixed column
     {$Endregion}
     ColCount : Integer;
     {$Region 'xmldoc'}
     /// The number of rows with extra height (1 pixel)
     {$Endregion}
     StretchedRows : Integer;
     {$Region 'xmldoc'}
     /// The number of columns with extra width (1 pixel)
     {$Endregion}
     StretchedCols : Integer;
     {$Region 'xmldoc'}
     /// The optimal width of the grid
     {$Endregion}
     PrefferedWidth : Integer;
     {$Region 'xmldoc'}
     /// The optimal height of the grid
     {$Endregion}
     PrefferedHeight : Integer;
     {$Region 'xmldoc'}
     /// The bounding rectangles of the month calendar's sections
     {$Endregion}
     Sections : Array[TIntlCalSection] Of TRect;
    End;
   Private
    fDate                                    : TDate;
    fDateMin                                 : TDate;
    fDateMax                                 : TDate;
    fCalendarType                            : TCalendarClass;
    fCalendar                                : TCalendar;
    fCulture                                 : TCultureInfo;
    fCultureCalendar                         : TLocalizerSwicth;
    fCultureDigits                           : TLocalizerSwicth;
    fWeekNumbers                             : Boolean;
    fCurrentView                             : TIntlCalViewMode;
    fSelectionStyle                          : TIntlCalSelectionStyle;
    fSelectionAnchor                         : TDate;
    fSelection                               : TDateTimeList;
    fShowHeader                              : Boolean;
    fShowFooter                              : Boolean;
    fFontHeader                              : TFont;
    fFontFooter                              : TFont;
    fFontDayOfWeek                           : TFont;
    fFontWeekNumbers                         : TFont;
    fEra, fYear, fMonth, fDay                : Integer;
    fMonthsInYear, fDaysInYear, fDaysInMonth : Integer;
    fMonthFirstDate                          : TDate;
    fMonthFirstDayOfWeek                     : TDayOfWeek;
    fMonthStartCell                          : Integer;
    fFirstCellDayNumber                      : Integer;
    fFirstCellYear                           : Integer;
    fActualDateMin                           : TDate;
    fActualDateMax                           : TDate;
    fHotCell                                 : Integer;
    fHotInfo                                 : TIntlCalHitTest;
    fDraggingCell                            : Integer;
    fDraggingShiftState                      : TShiftState;
    fDraggingOffPage                         : Boolean;
    fNavigationTimer                         : Integer;
    fHintDate                                : TDate;
    fMetrics                                 : TIntlCalMetrics;
    fLocalizer                               : TLocalizer;
    fPrefferedSize                           : TSize;
    fPrefferedSizeReady                      : Boolean;
    fPrefferedSizeSmallest                   : Boolean;
    fUpdateMetricsCount                      : Integer;
    fColorDivider                            : TColor;
    fColorToday                              : TColor;
    fTheme                                   : HTHEME;
    fAnimate                                 : Boolean;
    fSavedScreen                             : TBitmap;
    fSavedView                               : TIntlCalViewMode;
    fSavedDate                               : TDate;
    fSavedCellRect                           : TRect;
    fSaveFontHeader                          : Boolean;
    fSaveFontFooter                          : Boolean;
    fSaveFontDayOfWeek                       : Boolean;
    fSaveFontWeekNumbers                     : Boolean;
    fOnDateChange                            : TNotifyEvent;
    fOnPageChange                            : TNotifyEvent;
    fOnCalendarChange                        : TNotifyEvent;
    fOnSelectionChange                       : TNotifyEvent;
    fOnDateHint                              : TDateHintEvent;
    fOnDateSelectable                        : TDateSelectableEvent;
    fOnCustomDrawDayOfWeek                   : TCustomDrawDayOfWeekEvent;
    fOnCustomDrawWeekNumber                  : TCustomDrawWeekNumberEvent;
    fOnCustomDrawDay                         : TCustomDrawDayEvent;
    fOnCustomDrawMonth                       : TCustomDrawMonthEvent;
    fOnCustomDrawYear                        : TCustomDrawYearEvent;
    fOnCustomDrawHeaderText                  : TCustomDrawTextEvent;
    fOnCustomDrawFooterText                  : TCustomDrawTextEvent;
    Procedure SetDate(Const Value : TDate);
    Procedure SetDateMin(Const Value : TDate);
    Procedure SetDateMax(Const Value : TDate);
    Procedure SetCalendarType(Value : TCalendarClass);
    Procedure SetCulture(Value : TCultureInfo);
    Procedure SetCultureCalendar(Value : TLocalizerSwicth);
    Procedure SetCultureDigits(Value : TLocalizerSwicth);
    Procedure SetWeekNumbers(Value : Boolean);
    Procedure SetSelectionStyle(Value : TIntlCalSelectionStyle);
    Procedure SetShowHeader(Value : Boolean);
    Procedure SetShowFooter(Value : Boolean);
    Procedure SetFontHeader(Value : TFont);
    Procedure SetFontFooter(Value : TFont);
    Procedure SetFontDayOfWeek(Value : TFont);
    Procedure SetFontWeekNumbers(Value : TFont);
    Procedure SetCurrentView(Value : TIntlCalViewMode);
    Procedure SetLocalizer(Value : TLocalizer);
    Procedure SetColorDivider(Value : TColor);
    Procedure SetColorToday(Value : TColor);
    Function GetSelectionStart : TDate;
    Function GetSelectionEnd : TDate;
    Function GetSelectionCount : Integer;
    Function GetSelection(Index : Integer) : TDate;
    Function GetUsingCultureCalendar : Boolean;
    Function GetUsingCultureDigits : Boolean;
    Function GetMonthLastDate : TDate; Inline;
    Function GetFirstCellDate : TDate; Inline;
    Function GetLastCellDate : TDate; Inline;
    Function GetLastCellYear : Integer; Inline;
    Function GetFirstYearOnPage : Integer;
    Function GetLastYearOnPage : Integer;
    Function GetColCount : Integer; Inline;
    Function GetRowCount : Integer; Inline;
    Function GetCellCount : Integer; Inline;
    Function GetFocusedCell : Integer;
    Function GetTheme : HTHEME;
    Function IsDateStored : Boolean;
    Function IsDateMinStored : Boolean;
    Function IsDateMaxStored : Boolean;
    Procedure ReadCulture(Reader : TReader);
    Procedure WriteCulture(Writer : TWriter);
    Procedure ReadCalendarType(Reader : TReader);
    Procedure WriteCalendarType(Writer : TWriter);
    Procedure FontHeaderChanged(Sender : TObject);
    Procedure FontFooterChanged(Sender : TObject);
    Procedure FontDayOfWeekChanged(Sender : TObject);
    Procedure FontWeekNumbersChanged(Sender : TObject);
    Procedure CalendarChanged(Sender : TObject);
    Procedure WMTimer(Var Message : TWMTimer); Message WM_TIMER;
    Procedure WMEraseBkgnd(Var Message : TWMEraseBkgnd); Message WM_ERASEBKGND;
    Procedure WMGetDlgCode(Var Message : TWMGetDlgCode); Message WM_GETDLGCODE;
    Procedure WMMouseActivate(Var Message : TWMMouseActivate); Message WM_MOUSEACTIVATE;
    Procedure CMMouseLeave(Var Message : TMessage); Message CM_MOUSELEAVE;
    Procedure CMHintShow(Var Message : TCMHintShow); Message CM_HINTSHOW;
    Procedure CMFontChanged(Var Message : TMessage); Message CM_FONTCHANGED;
    Procedure ExtractDateInfo(Const ADate : TDate);
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Specifies the duration of the control's animations, in milliseconds.
    /// </summary>
    {$Endregion}
    Const AnimateDuration = 400; {ms}
    {$Region 'xmldoc'}
    /// <summary>
    /// Specifies the interval between automatic navigations, in milliseconds.
    /// </summary>
    {$Endregion}
    Const AutoNavInterval = AnimateDuration + 100; {ms}
    {$Region 'xmldoc'}
    /// <summary>
    /// Specifies the identifier of forward automatic navigation timer.
    /// </summary>
    {$Endregion}
    Const AutoNavTimerForward = 100;
    {$Region 'xmldoc'}
    /// <summary>
    /// Specifies the identifier of backward automatic navigation timer.
    /// </summary>
    {$Endregion}
    Const AutoNavTimerBackward = 200;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Notifies the control about changes in the linked <see cref="TLocalizer"/>
    /// component.
    /// </summary>
    /// <param name="Sender">
    /// The <see cref="TLocalizer"/> component who originated the notification.
    /// </param>
    /// <param name="Reason">
    /// The reason of the notification.
    /// </param>
    {$Endregion}
    Procedure LocalizerNotify(Sender : TLocalizer; Reason : TLocalizerNotification);
    {$Region 'xmldoc'}
    /// <summary>
    /// Responds to notifications that components are about to be created or destroyed.
    /// </summary>
    /// <param name="AComponent">
    /// The component, which is generated the notification.
    /// </param>
    /// <param name="Operation">
    /// Indicates whether the component is created or destroyed.
    /// </param>
    {$Endregion}
    Procedure Notification(AComponent : TComponent; Operation : TOperation); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Reads and writes the <see cref="Culture"/> and <see cref="CalendarType"/> properties
    /// as if they were published.
    /// </summary>
    /// <param name="Filer">
    /// The current <see cref="TReader"/> or <see cref="TWriter"/> object that is
    /// loading or saving the published properties.
    /// </param>
    {$Endregion}
    Procedure DefineProperties(Filer : TFiler); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Makes any required adjustments when the control changes size.
    /// </summary>
    {$Endregion}
    Procedure Resize; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Renders the control.
    /// </summary>
    {$Endregion}
    Procedure Paint; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Updates the control when it is first loaded into memory.
    /// </summary>
    {$Endregion}
    Procedure Loaded; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether the control can resize itself automatically to accommodate
    /// its contents.
    /// </summary>
    /// <param name="NewWidth">
    /// Indicates the proposed new width of the control.
    /// </param>
    /// <param name="NewHeight">
    /// Indicates the proposed new height of the control.
    /// </param>
    /// <returns>
    /// Always returns <see langword="true"/>.
    /// </returns>
    {$Endregion}
    Function CanAutoSize(Var NewWidth : Integer; Var NewHeight : Integer) : Boolean; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Responds when the user presses a mouse button down while the cursor's hotspot is
    /// over the control.
    /// </summary>
    /// <param name="Button">
    /// Determines which mouse button the user pressed.
    /// </param>
    /// <param name="Shift">
    /// Indicates which shift keys (Shift, Ctrl, or Alt) were down when the user pressed the mouse button.
    /// </param>
    /// <param name="X">
    /// The horizontal pixel coordinate of the mouse pointer within the client area of the control.
    /// </param>
    /// <param name="Y">
    /// The vertical pixel coordinate of the mouse pointer within the client area of the control.
    /// </param>
    {$Endregion}
    Procedure MouseDown(Button : TMouseButton; Shift : TShiftState; x, y : Integer); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Responds when the user moves the mouse pointer while the cursor's hotspot is
    /// over the control.
    /// </summary>
    /// <param name="Shift">
    /// Indicates which shift keys (Shift, Ctrl, or Alt) were down when the user moved the mouse pointer.
    /// </param>
    /// <param name="X">
    /// The horizontal pixel coordinate of the mouse pointer within the client area of the control.
    /// </param>
    /// <param name="Y">
    /// The vertical pixel coordinate of the mouse pointer within the client area of the control.
    /// </param>
    {$Endregion}
    Procedure MouseMove(Shift : TShiftState; x, y : Integer); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Responds when the user releases a previously pressed mouse button down while the
    /// cursor's hotspot is over the control.
    /// </summary>
    /// <param name="Button">
    /// Determines which mouse button the user released.
    /// </param>
    /// <param name="Shift">
    /// Indicates which shift keys (Shift, Ctrl, or Alt) were down when the user released the mouse button.
    /// </param>
    /// <param name="X">
    /// The horizontal pixel coordinate of the mouse pointer within the client area of the control.
    /// </param>
    /// <param name="Y">
    /// The vertical pixel coordinate of the mouse pointer within the client area of the control.
    /// </param>
    {$Endregion}
    Procedure MouseUp(Button : TMouseButton; Shift : TShiftState; x, y : Integer); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Responds when the user rotates the mouse wheel downward.
    /// </summary>
    /// <param name="Shift">
    /// Indicates which shift keys (Shift, Ctrl, or Alt) were down when the user rotated the mouse wheel.
    /// </param>
    /// <param name="MousePos">
    /// The pixel coordinates of the mouse pointer within the screen.
    /// </param>
    {$Endregion}
    Function DoMouseWheelDown(Shift : TShiftState; MousePos : TPoint) : Boolean; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Responds when the user rotates the mouse wheel upward.
    /// </summary>
    /// <param name="Shift">
    /// Indicates which shift keys (Shift, Ctrl, or Alt) were down when the user rotated the mouse wheel.
    /// </param>
    /// <param name="MousePos">
    /// The pixel coordinates of the mouse pointer within the screen.
    /// </param>
    {$Endregion}
    Function DoMouseWheelUp(Shift : TShiftState; MousePos : TPoint) : Boolean; Override;
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
    /// Updates the control when it receives input focus.
    /// </summary>
    {$Endregion}
    Procedure DoEnter; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Updates the control when it loses input focus.
    /// </summary>
    {$Endregion}
    Procedure DoExit; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnDateChange"/> event.
    /// </summary>
    {$Endregion}
    Procedure DoDateChange; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnPageChange"/> event.
    /// </summary>
    {$Endregion}
    Procedure DoPageChange; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnCalendarChange"/> event.
    /// </summary>
    {$Endregion}
    Procedure DoCalendarChange; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnSelectionChange"/> event.
    /// </summary>
    {$Endregion}
    Procedure DoSelectionChange; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnDateHint"/> event.
    /// </summary>
    /// <param name="ADate">
    /// The <see cref="TDate"/> value that its hint string is requested.
    /// </param>
    /// <param name="HintStr">
    /// The hint string of the <see cref="TDate"/> value.
    /// </param>
    {$Endregion}
    Procedure DoDateHint(Const ADate : TDate; Var HintStr : String); Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnDateSelectable"/> event.
    /// </summary>
    /// <param name="ADate">
    /// The <see cref="TDate"/> value to examine.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the <see cref="TDate"/> value can be selected,
    /// otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function DoDateSelectable(Const ADate : TDate) : Boolean; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnCustomDrawDayOfWeek"/> event.
    /// </summary>
    /// <param name="Canvas">
    /// The canvas on which to draw the day's name.
    /// </param>
    /// <param name="ARect">
    /// The bounding rectangle on the canvas where the day's name should be drawn.
    /// </param>
    /// <param name="State">
    /// The state information that can affect the way the day's name is drawn.
    /// </param>
    /// <param name="ADayOfWeek">
    /// The day of the week to draw its name.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the default rendering should proceed after
    /// the method exits, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function DoCustomDrawDayOfWeek(Canvas : TCanvas; Const ARect : TRect; State : TIntlCalDrawStates; ADayOfWeek : TDayOfWeek) : Boolean; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnCustomDrawWeekNumber"/> event.
    /// </summary>
    /// <param name="Canvas">
    /// The canvas on which to draw the week number.
    /// </param>
    /// <param name="ARect">
    /// The bounding rectangle on the canvas where the week number should be drawn.
    /// </param>
    /// <param name="State">
    /// The state information that can affect the way the week number is drawn.
    /// </param>
    /// <param name="AWeek">
    /// The week of the year to draw.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the default rendering should proceed after
    /// the method exits, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function DoCustomDrawWeekNumber(Canvas : TCanvas; Const ARect : TRect; State : TIntlCalDrawStates; AWeek : Integer) : Boolean; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnCustomDrawDay"/> event.
    /// </summary>
    /// <param name="Canvas">
    /// The canvas on which to draw the day of the month.
    /// </param>
    /// <param name="ARect">
    /// The bounding rectangle on the canvas where the day of the month should be drawn.
    /// </param>
    /// <param name="State">
    /// The state information that can affect the way the day of the month is drawn.
    /// </param>
    /// <param name="ADate">
    /// The <see cref="TDate"/> value that represents the day of the moneh.
    /// </param>
    /// <param name="ADay">
    /// The day of the month to draw.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the default rendering should proceed after
    /// the method exits, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function DoCustomDrawDay(Canvas : TCanvas; Const ARect : TRect; State : TIntlCalDrawStates; Const ADate : TDate; ADay : Integer) : Boolean; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnCustomDrawMonth"/> event.
    /// </summary>
    /// <param name="Canvas">
    /// The canvas on which to draw the month's name.
    /// </param>
    /// <param name="ARect">
    /// The bounding rectangle on the canvas where the month's name should be drawn.
    /// </param>
    /// <param name="State">
    /// The state information that can affect the way the month's name is drawn.
    /// </param>
    /// <param name="AMonth">
    /// The month to draw its name.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the default rendering should proceed after
    /// the method exits, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function DoCustomDrawMonth(Canvas : TCanvas; Const ARect : TRect; State : TIntlCalDrawStates; AMonth : Integer) : Boolean; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnCustomDrawYear"/> event.
    /// </summary>
    /// <param name="Canvas">
    /// The canvas on which to draw the year.
    /// </param>
    /// <param name="ARect">
    /// The bounding rectangle on the canvas where the year should be drawn.
    /// </param>
    /// <param name="State">
    /// The state information that can affect the way the year is drawn.
    /// </param>
    /// <param name="AYear">
    /// The year to draw.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the default rendering should proceed after
    /// the method exits, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function DoCustomDrawYear(Canvas : TCanvas; Const ARect : TRect; State : TIntlCalDrawStates; AYear : Integer) : Boolean; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnCustomDrawHeaderText"/> event.
    /// </summary>
    /// <param name="Canvas">
    /// The canvas on which to draw the text.
    /// </param>
    /// <param name="ARect">
    /// The bounding rectangle on the canvas where the text should be drawn.
    /// </param>
    /// <param name="State">
    /// The state information that can affect the way the text is drawn.
    /// </param>
    /// <param name="AText">
    /// The text to draw.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the default rendering should proceed after
    /// the method exits, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function DoCustomDrawHeaderText(Canvas : TCanvas; Const ARect : TRect; State : TIntlCalDrawStates; Const AText : String) : Boolean; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnCustomDrawFooterText"/> event.
    /// </summary>
    /// <param name="Canvas">
    /// The canvas on which to draw the text.
    /// </param>
    /// <param name="ARect">
    /// The bounding rectangle on the canvas where the text should be drawn.
    /// </param>
    /// <param name="State">
    /// The state information that can affect the way the text is drawn.
    /// </param>
    /// <param name="AText">
    /// The text to draw.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the default rendering should proceed after
    /// the method exits, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function DoCustomDrawFooterText(Canvas : TCanvas; Const ARect : TRect; State : TIntlCalDrawStates; Const AText : String) : Boolean; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a string that its embedded nominal digits (0-9) are substituted with
    /// their corresponding digits in the langauge specified by the <see cref="Culture"/>
    /// property. NormalizeDigits also inserts appropriate Unicode control character in
    /// front of the string to prevent automatic digit substitution by Windows.
    /// </summary>
    /// <param name="Str">
    /// The string to convert.
    /// </param>
    /// <returns>
    /// The string that its digits are fixed as native.
    /// </returns>
    /// <seealso cref="Culture"/>
    {$Endregion}
    Procedure NormalizeDigits(Var Str : String); Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the display name for a specified day of the week.
    /// </summary>
    /// <param name="DayOfWeek">
    /// The day of the week that its display name is requested.
    /// </param>
    /// <param name="NameKind">
    /// Determines which kind of display name is needed.
    /// </param>
    /// <returns>
    /// The display name of the specified day of the week.
    /// </returns>
    {$Endregion}
    Function GetDayName(DayOfWeek : TDayOfWeek; NameKind : TIntlCalNameKind) : String; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the display name for a specified month.
    /// </summary>
    /// <param name="Month">
    /// The month that its display name is requested.
    /// </param>
    /// <param name="NameKind">
    /// Determines which kind of display name is needed.
    /// </param>
    /// <returns>
    /// The display name of the specified month.
    /// </returns>
    {$Endregion}
    Function GetMonthName(Month : Integer; NameKind : TIntlCalNameKind) : String; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts a specified year to string.
    /// </summary>
    /// <param name="AYear">
    /// The year.
    /// </param>
    /// <returns>
    /// The string representation of the specified year.
    /// </returns>
    {$Endregion}
    Function GetYearText(AYear : Integer) : String; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts a specified day of the month to string.
    /// </summary>
    /// <param name="ADay">
    /// The day of the month.
    /// </param>
    /// <returns>
    /// The string representation of the specified day of the month.
    /// </returns>
    {$Endregion}
    Function GetDayText(ADay : Integer) : String; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts a specified week of the year to string.
    /// </summary>
    /// <param name="ADay">
    /// The week of the year.
    /// </param>
    /// <returns>
    /// The string representation of the specified week of the year.
    /// </returns>
    {$Endregion}
    Function GetWeekText(AWeek : Integer) : String; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the text of the calendar's header based on a specified view mode.
    /// </summary>
    /// <param name="ViewMode">
    /// Indicates whether the header text is going to be used.
    /// </param>
    /// <returns>
    /// The text that appears on the header.
    /// </returns>
    {$Endregion}
    Function GetHeaderText(ViewMode : TIntlCalViewMode) : String; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the today's date as the footer text.
    /// </summary>
    /// <param name="LongFormat">
    /// Indicates which of long or short date formats should be used.
    /// </param>
    /// <returns>
    /// The text that appears on the footer.
    /// </returns>
    {$Endregion}
    Function GetFooterText(LongFormat : Boolean) : String; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Determines that a point is in which section of the control.
    /// </summary>
    /// <param name="X">
    /// The point's horizontal coordinate in the control's coordinate space.
    /// </param>
    /// <param name="Y">
    /// The point's vertical coordinate in the control's coordinate space.
    /// </param>
    /// <param name="Cell">
    /// The index of the grid's cell, if the point is in the calendar's grid.
    /// </param>
    /// <returns>
    /// Returns a <see cref="TIntlCalHitTest"/> value.
    /// </returns>
    {$Endregion}
    Function GetHitTestInfoAt(x, y : Integer; Out Cell : Integer) : TIntlCalHitTest; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Determines whether a point is in a cell of the calendar's grid that represents
    /// a day of a month.
    /// </summary>
    /// <param name="X">
    /// The point's horizontal coordinate in the control's coordinate space.
    /// </param>
    /// <param name="Y">
    /// The point's vertical coordinate in the control's coordinate space.
    /// </param>
    /// <param name="ADate">
    /// The <see cref="TDate"/> value of the cell, if the point is in the calendar's grid and
    /// the grid is showing days of a month.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the point is in the calendar's grid and the grid is
    /// showing days of a month, otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="GetDateAtCell"/>
    {$Endregion}
    Function GetDateAt(x, y : Integer; Out ADate : TDate) : Boolean; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Determines whether a cell of the calendar's grid is representing a day of a month.
    /// </summary>
    /// <param name="Index">
    /// The index of the cell to examine.
    /// </param>
    /// <param name="ADate">
    /// The <see cref="TDate"/> value of the cell, if the specified cell index is in range and
    /// the calendar's grid is showing days of a month.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the specified cell index is in range and the calendar's
    /// grid is showing days of a month, otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="GetDateAt"/>
    {$Endregion}
    Function GetDateAtCell(Index : Integer; Out ADate : TDate) : Boolean; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Determines whether a point is in a cell of the calendar's grid that represents
    /// a month of a year.
    /// </summary>
    /// <param name="X">
    /// The point's horizontal coordinate in the control's coordinate space.
    /// </param>
    /// <param name="Y">
    /// The point's vertical coordinate in the control's coordinate space.
    /// </param>
    /// <param name="AMonth">
    /// The month value of the cell, if the point is in the calendar's grid and the grid
    /// is showing months of a year.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the point is in the calendar's grid and the grid is
    /// showing months of a year, otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="GetMonthAtCell"/>
    {$Endregion}
    Function GetMonthAt(x, y : Integer; Out AMonth : Integer) : Boolean; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Determines whether a cell of the calendar's grid is representing a month of the year.
    /// </summary>
    /// <param name="Index">
    /// The index of the cell to examine.
    /// </param>
    /// <param name="AMonth">
    /// The month value of the cell, if the specified cell index is in range and
    /// the calendar's grid is showing months of a year.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the specified cell index is in range and the calendar's
    /// grid is showing months of a year, otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="GetMonthAt"/>
    {$Endregion}
    Function GetMonthAtCell(Index : Integer; Out AMonth : Integer) : Boolean; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Determines whether a point is in a cell of the calendar's grid that represents
    /// a year.
    /// </summary>
    /// <param name="X">
    /// The point's horizontal coordinate in the control's coordinate space.
    /// </param>
    /// <param name="Y">
    /// The point's vertical coordinate in the control's coordinate space.
    /// </param>
    /// <param name="AYear">
    /// The year value of the cell, if the point is in the calendar's grid and the grid
    /// is showing years of a decade.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the point is in the calendar's grid and the grid is
    /// showing years of a decade, otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="GetYearAtCell"/>
    {$Endregion}
    Function GetYearAt(x, y : Integer; Out AYear : Integer) : Boolean; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Determines whether a cell of the calendar's grid is representing a year.
    /// </summary>
    /// <param name="Index">
    /// The index of the cell to examine.
    /// </param>
    /// <param name="AMonth">
    /// The year value of the cell, if the specified cell index is in range and
    /// the calendar's grid is showing years of a decade.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the specified cell index is in range and the
    /// calendar's grid is showing years of a decade, otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="GetYearAt"/>
    {$Endregion}
    Function GetYearAtCell(Index : Integer; Out AYear : Integer) : Boolean; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the bounding rectangle of the calendar's content within the client
    /// area of the control.
    /// </summary>
    /// <returns>
    /// The bounding rectangle of the calendar's content.
    /// </returns>
    {$Endregion}
    Function GetCalendarClientRect : TRect; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the bounding rectangle of a calendar's section within the client
    /// area of the control.
    /// </summary>
    /// <param name="Section">
    /// The section to get its bounding rectangle.
    /// </param>
    /// <returns>
    /// The bounding rectangle of the calendar's section.
    /// </returns>
    /// <seealso cref="GetSectionWidth"/>
    /// <seealso cref="GetSectionHeight"/>
    /// <seealso cref="CalcMetricsSections"/>
    {$Endregion}
    Function GetSectionRect(Section : TIntlCalSection) : TRect; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the width of a calendar's section, in pixels.
    /// </summary>
    /// <param name="Section">
    /// The section to get its width.
    /// </param>
    /// <returns>
    /// The width of the calendar's section.
    /// </returns>
    /// <seealso cref="GetSectionWidth"/>
    /// <seealso cref="GetSectionRect"/>
    {$Endregion}
    Function GetSectionWidth(Section : TIntlCalSection) : Integer; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the height of a calendar's section, in pixels.
    /// </summary>
    /// <param name="Section">
    /// The section to get its height.
    /// </param>
    /// <returns>
    /// The height of the calendar's section.
    /// </returns>
    /// <seealso cref="GetSectionHeight"/>
    /// <seealso cref="GetSectionRect"/>
    {$Endregion}
    Function GetSectionHeight(Section : TIntlCalSection) : Integer; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the bounding rectangle of a cell of the calendar's grid, which is
    /// specified by its row and column coordinates.
    /// </summary>
    /// <param name="Row">
    /// The row number of the cell.
    /// </param>
    /// <param name="Col">
    /// The column number of the cell.
    /// </param>
    /// <returns>
    /// The bounding rectangle of the cell.
    /// </returns>
    {$Endregion}
    Function GetCellRect(Row, Col : Integer) : TRect; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the bounding rectangle of a cell of the calendar's grid, which is
    /// specified by its index.
    /// </summary>
    /// <param name="Index">
    /// The index of the cell in the grid.
    /// </param>
    /// <returns>
    /// The bounding rectangle of the cell.
    /// </returns>
    {$Endregion}
    Function GetCellRect(Index : Integer) : TRect; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Determines whether a vertical coordinate is within the calendar's grid.
    /// </summary>
    /// <param name="Y">
    /// The vertical coordinate in the control's coordinate space.
    /// </param>
    /// <returns>
    /// Returns the row number of the grid at the specified vertical coordinate, or -1
    /// if the coordinate is not within the calendar's grid.
    /// </returns>
    /// <seealso cref="GetColAt"/>
    {$Endregion}
    Function GetRowAt(y : Integer) : Integer;
    {$Region 'xmldoc'}
    /// <summary>
    /// Determines whether a horizontal coordinate is within the calendar's grid.
    /// </summary>
    /// <param name="Y">
    /// The horizontal coordinate in the control's coordinate space.
    /// </param>
    /// <returns>
    /// Returns the column number of the grid at the specified horizontal coordinate, or -1
    /// if the coordinate is not within the calendar's grid.
    /// </returns>
    /// <seealso cref="GetRowAt"/>
    {$Endregion}
    Function GetColAt(x : Integer) : Integer;
    {$Region 'xmldoc'}
    /// <summary>
    /// Regarding to the value of <see cref="CurrentView"/> and <see cref="Date"/> properties,
    /// returns a date that represents next or previous month, year, or decade.
    /// </summary>
    /// <param name="Backward">
    /// Indicates whether the next or the previous date is needed.
    /// </param>
    /// <returns>
    /// The <see cref="TDate"/> value of the next or the previous date.
    /// </returns>
    {$Endregion}
    Function GetAdjacentPageDate(Backward : Boolean) : TDate;
    {$Region 'xmldoc'}
    /// <summary>
    /// Calculates the preffered dimension of the control's client area to display
    /// the calendar's content.
    /// </summary>
    /// <param name="AWidth">
    /// The calculated width of the control's client area.
    /// </param>
    /// <param name="AHeight">
    /// The calculated height of the control's client area.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the calculated size is the smallest possible
    /// value that can support the entire content, otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="GetPreferredControlSize"/>
    {$Endregion}
    Function GetPreferredClientSize(Out AWidth, AHeight : Integer) : Boolean; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Calculates the preffered dimension of the control (including border and bevels)
    /// to display the calendar's content.
    /// </summary>
    /// <param name="AWidth">
    /// The calculated width of the control.
    /// </param>
    /// <param name="AHeight">
    /// The calculated height of the control.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the calculated size is the smallest possible
    /// value that can support the entire content, otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="GetPreferredClientSize"/>
    {$Endregion}
    Function GetPreferredControlSize(Out AWidth, AHeight : Integer) : Boolean; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Calculates the metrics for rendering the calendar.
    /// </summary>
    /// <param name="ViewMode">
    /// Determines metrics for which page type is requested.
    /// </param>
    /// <param name="Metrics">
    /// The record that stores the calculated metrics.
    /// </param>
    /// <seealso cref="CalcMetricsSections"/>
    /// <seealso cref="UpdateMetrics"/>
    {$Endregion}
    Procedure CalcMetrics(ViewMode : TIntlCalViewMode; Out Metrics : TIntlCalMetrics); Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Calculates the bounding rectangle of calnedar's sections based on a specified metrics.
    /// </summary>
    /// <param name="Metrics">
    /// The metrics record that stores the bounding rectangle of sections.
    /// </param>
    /// <seealso cref="CalcMetrics"/>
    /// <seealso cref="UpdateMetrics"/>
    {$Endregion}
    Procedure CalcMetricsSections(Var Metrics : TIntlCalMetrics); Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Recalculates the metrics for rendering the calendar, and invalidates the control.
    /// </summary>
    /// <seealso cref="CalcMetrics"/>
    /// <seealso cref="CalcMetricsSections"/>
    {$Endregion}
    Procedure UpdateMetrics; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Reevaluates value of <see cref="ActualDateMin"/> and <see cref="ActualDateMax"/>
    /// properties.
    /// </summary>
    {$Endregion}
    Procedure UpdateMinMaxRanges; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Validates the <see cref="Calendar"/> property to ensure it represents a proper
    /// calendar system with an appropriate locale settings.
    /// </summary>
    {$Endregion}
    Procedure ValidateCalendar; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether the control is using the Windows theming system.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> if the control is using the Windows theming system
    /// to draw itself, otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="Theme"/>
    {$Endregion}
    Function IsThemed : Boolean;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether a specified year is somehow visible on the current page of the
    /// control.
    /// </summary>
    /// <param name="AYear">
    /// The year to be examined.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the year is visible on the current page, otherwise
    /// returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function IsYearOnPage(AYear : Integer) : Boolean; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Initializes the animation that changes the current page.
    /// </summary>
    /// <seealso cref="AnimatePlay"/>
    /// <seealso cref="AnimateEnd"/>
    {$Endregion}
    Procedure AnimateBegin; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Plays a previously initialized animation using the <seealso cref="AnimateBegin"/> method.
    /// </summary>
    /// <seealso cref="AnimateBegin"/>
    /// <seealso cref="AnimateEnd"/>
    {$Endregion}
    Procedure AnimatePlay; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Finalizes a previously initialized animation using the <seealso cref="AnimateBegin"/> method.
    /// </summary>
    /// <seealso cref="AnimateBegin"/>
    /// <seealso cref="AnimatePlay"/>
    {$Endregion}
    Procedure AnimateEnd; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates a bitmap that contains the current calendar's screen.
    /// </summary>
    /// <returns>
    /// The bitmap of the current calendar's screen.
    /// </returns>
    {$Endregion}
    Function TakeSnapshot : TBitmap;
    {$Region 'xmldoc'}
    /// <summary>
    /// Renders background of a calendar's section.
    /// </summary>
    /// <param name="Canvas">
    /// The canvas on which to draw the background.
    /// </param>
    /// <param name="Rect">
    /// The bounding rectangle on the canvas where the background should be drawn.
    /// </param>
    /// <param name="State">
    /// The state information that can affect the way the background is drawn.
    /// </param>
    /// <seealso cref="RenderText"/>
    {$Endregion}
    Procedure RenderBackground(Canvas : TCanvas; Var Rect : TRect; State : TIntlCalDrawStates); Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Renders a specified text.
    /// </summary>
    /// <param name="Canvas">
    /// The canvas on which to draw the text.
    /// </param>
    /// <param name="Rect">
    /// The bounding rectangle on the canvas where the text should be drawn.
    /// </param>
    /// <param name="State">
    /// The state information that can affect the way the text is drawn.
    /// </param>
    /// <param name="Text">
    /// The text to draw.
    /// </param>
    /// <param name="Alignment">
    /// The horizontal alignment of the text in regard of its bounding rectangle.
    /// </param>
    /// <seealso cref="RenderBackground"/>
    {$Endregion}
    Procedure RenderText(Canvas : TCanvas; Var Rect : TRect; State : TIntlCalDrawStates; Const Text : String; Alignment : TAlignment); Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Renders a left or right arrow.
    /// </summary>
    /// <param name="Canvas">
    /// The canvas on which to draw the arrow.
    /// </param>
    /// <param name="Rect">
    /// The bounding rectangle on the canvas where the arrow should be drawn.
    /// </param>
    /// <param name="State">
    /// The state information that can affect the way the arrow is drawn.
    /// </param>
    /// <param name="Backward">
    /// Determines whether the arrow is pointed to left or right.
    /// </param>
    /// <seealso cref="RenderBackground"/>
    /// <seealso cref="RenderText"/>
    {$Endregion}
    Procedure RenderArrow(Canvas : TCanvas; Var Rect : TRect; State : TIntlCalDrawStates; Backward : Boolean); Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Renders a marker in a specified bounding rectangle to specify the today's date.
    /// </summary>
    /// <param name="Canvas">
    /// The canvas on which to draw the marker.
    /// </param>
    /// <param name="Rect">
    /// The bounding rectangle on the canvas where the marker should be drawn.
    /// </param>
    {$Endregion}
    Procedure RenderTodayMarker(Canvas : TCanvas; Var Rect : TRect); Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Draws the entire calendar on a specified canvas.
    /// </summary>
    /// <param name="Canvas">
    /// The canvas to draw.
    /// </param>
    {$Endregion}
    Procedure DrawCalendar(Canvas : TCanvas); Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Draws the header section of the calendar on a specified canvas.
    /// </summary>
    /// <param name="Canvas">
    /// The canvas to draw.
    /// </param>
    {$Endregion}
    Procedure DrawHeader(Canvas : TCanvas); Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Draws the footer section of the calendar on a specified canvas.
    /// </summary>
    /// <param name="Canvas">
    /// The canvas to draw.
    /// </param>
    {$Endregion}
    Procedure DrawFooter(Canvas : TCanvas); Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Draws the empty area shared between row of day names and column of week
    /// numbers.
    /// </summary>
    /// <param name="Canvas">
    /// The canvas to draw.
    /// </param>
    {$Endregion}
    Procedure DrawWeekSpace(Canvas : TCanvas); Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Draws the section of the calendar that displays days of the week.
    /// </summary>
    /// <param name="Canvas">
    /// The canvas to draw.
    /// </param>
    {$Endregion}
    Procedure DrawDaysOfWeek(Canvas : TCanvas); Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Draws the section of the calendar that displays week numbers.
    /// </summary>
    /// <param name="Canvas">
    /// The canvas to draw.
    /// </param>
    {$Endregion}
    Procedure DrawWeekNumbers(Canvas : TCanvas); Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Draws the calendar's grid with days of a month.
    /// </summary>
    /// <param name="Canvas">
    /// The canvas to draw.
    /// </param>
    {$Endregion}
    Procedure DrawDays(Canvas : TCanvas); Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Draws the calendar's grid with months of a year.
    /// </summary>
    /// <param name="Canvas">
    /// The canvas to draw.
    /// </param>
    {$Endregion}
    Procedure DrawMonths(Canvas : TCanvas); Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Draws the calendar's grid with years of a decade.
    /// </summary>
    /// <param name="Canvas">
    /// The canvas to draw.
    /// </param>
    {$Endregion}
    Procedure DrawYears(Canvas : TCanvas); Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Schedules a repaint for a specified set of calendar's sections.
    /// </summary>
    /// <param name="Sections">
    /// The set of sections to repaint.
    /// </param>
    /// <seealso cref="InvalidateDateDependentSections"/>
    /// <seealso cref="FocusDate"/>
    /// <seealso cref="Date"/>
    {$Endregion}
    Procedure InvalidateSections(Sections : TIntlCalSections); Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Schedules a repaint for those calendar's sections that need to be
    /// updated when the <see cref="Date"/> property changes.
    /// </summary>
    /// <seealso cref="InvalidateSections"/>
    /// <seealso cref="Date"/>
    {$Endregion}
    Procedure InvalidateDateDependentSections; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Schedules a repaint for a cell of calendar's grid that is specified by
    /// its index.
    /// </summary>
    /// <param name="Index">
    /// The index of the cell in the grid.
    /// </param>
    {$Endregion}
    Procedure InvalidateCell(Index : Integer); Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Schedules a repaint for any part of the calendar that represents a
    /// cpmponent of a specified date.
    /// </summary>
    /// <param name="ADate">
    /// The <see cref="TDate"/> value to repaint.
    /// </param>
    /// <seealso cref="InvalidateDates"/>
    /// <seealso cref="InvalidateDateRange"/>
    {$Endregion}
    Procedure InvalidateDate(Const ADate : TDate); Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Schedules a repaint for those days in the calendar's grid that are
    /// in a specified dates.
    /// </summary>
    /// <param name="ADates">
    /// The list of <see cref="TDate"/> values to repaint.
    /// </param>
    /// <seealso cref="InvalidateDate"/>
    /// <seealso cref="InvalidateDateRange"/>
    {$Endregion}
    Procedure InvalidateDates(ADates : TDateTimeList); Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Schedules a repaint for those days in the calendar's grid that are
    /// in a specified range.
    /// </summary>
    /// <param name="ADate1">
    /// The <see cref="TDate"/> value that indicates start of the range.
    /// </param>
    /// <param name="ADate2">
    /// The <see cref="TDate"/> value that indicates end of the range.
    /// </param>
    /// <seealso cref="InvalidateDate"/>
    /// <seealso cref="InvalidateDates"/>
    {$Endregion}
    Procedure InvalidateDateRange(Const ADate1, ADate2 : TDate); Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Schedules a repaint for those part of the calendar that are in hot state.
    /// </summary>
    /// <seealso cref="InvalidateSelection"/>
    {$Endregion}
    Procedure InvalidateHotLight; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Schedules a repaint for selected cells of the calendar's grid.
    /// </summary>
    /// <seealso cref="InvalidateHotLight"/>
    {$Endregion}
    Procedure InvalidateSelection; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Selects a specified date as if clicked with the mouse. Conditional upon
    /// the value of <see cref="SelectionStyle"/> property, one date or multiple
    /// dates can be selected simultaneously.
    /// </summary>
    /// <param name="ADate">
    /// The <see cref="TDate"/> value to select.
    /// </param>
    /// <param name="ShiftState">
    /// Simulates the effect of using the Control key or the Shift key or mouse buttons
    /// when selecting the date.
    /// </param>
    /// <seealso cref="FocusDate"/>
    /// <seealso cref="Select"/>
    /// <seealso cref="ClearSelection"/>
    /// <seealso cref="IsSelected"/>
    /// <seealso cref="SelectionStart"/>
    /// <seealso cref="SelectionEnd"/>
    /// <seealso cref="SelectionCount"/>
    /// <seealso cref="Selection"/>
    /// <seealso cref="SelectionStyle"/>
    {$Endregion}
    Procedure SelectDate(Const ADate : TDate; ShiftState : TShiftState = []);
    {$Region 'xmldoc'}
    /// <summary>
    /// Marks a specified date as focused. Only one date can be focused at a time.
    /// </summary>
    /// <param name="ADate">
    /// The <see cref="TDate"/> value to mark as focused.
    /// </param>
    /// <seealso cref="SelectDate"/>
    /// <seealso cref="Date"/>
    {$Endregion}
    Procedure FocusDate(Const ADate : TDate);
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the handle to the Windows theme that is used for rendering the control.
    /// </summary>
    {$Endregion}
    Property Theme : HTHEME Read GetTheme;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the number of columns in the calendar's grid.
    /// </summary>
    {$Endregion}
    Property ColCount : Integer Read GetColCount;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the number of rows in the calendar's grid.
    /// </summary>
    {$Endregion}
    Property RowCount : Integer Read GetRowCount;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the number of cells in the calendar's grid.
    /// </summary>
    {$Endregion}
    Property CellCount : Integer Read GetCellCount;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the day of the month in the first cell of the calendar's grid.
    /// NOTE: The value of this property is valid only with a <see cref="CurrentView"/> of vmDay.
    /// </summary>
    {$Endregion}
    Property FirstCellDayNumber : Integer Read fFirstCellDayNumber;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the <see cref="TDate"/> value represented by the first cell of the calendar's grid.
    /// </summary>
    {$Endregion}
    Property FirstCellDate : TDate Read GetFirstCellDate;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the <see cref="TDate"/> value represented by the last cell of the calendar's grid.
    /// </summary>
    {$Endregion}
    Property LastCellDate : TDate Read GetLastCellDate;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the year in the first cell of the calendar's grid.
    /// NOTE: The value of this property is valid only with a <see cref="CurrentView"/> of vmYear.
    /// </summary>
    {$Endregion}
    Property FirstCellYear : Integer Read fFirstCellYear;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the year in the last cell of the calendar's grid.
    /// NOTE: The value of this property is valid only with a <see cref="CurrentView"/> of vmYear.
    /// </summary>
    {$Endregion}
    Property LastCellYear : Integer Read GetLastCellYear;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the smallest year in the calendar's grid that belongs to the current page.
    /// NOTE: The value of this property is valid only with a <see cref="CurrentView"/> of vmYear.
    /// </summary>
    {$Endregion}
    Property FirstYearOnPage : Integer Read GetFirstYearOnPage;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the largest year in the calendar's grid that belongs to the current page.
    /// NOTE: The value of this property is valid only with a <see cref="CurrentView"/> of vmYear.
    /// </summary>
    {$Endregion}
    Property LastYearOnPage : Integer Read GetLastYearOnPage;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets index of the cell in the calendar's grid, which represents the start of the month.
    /// NOTE: The value of this property is valid only with a <see cref="CurrentView"/> of vmDay.
    /// </summary>
    {$Endregion}
    Property MonthStartCell : Integer Read fMonthStartCell;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets index of the cell in the calendar's grid that has the focus.
    /// </summary>
    {$Endregion}
    Property FocusedCell : Integer Read GetFocusedCell;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets index of the cell in the calendar's grid that has the hot state.
    /// </summary>
    {$Endregion}
    Property HotCell : Integer Read fHotCell;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the last mouse hit test information.
    /// </summary>
    {$Endregion}
    Property HotInfo : TIntlCalHitTest Read fHotInfo;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets index of the cell in the calendar's grid that is being dragged.
    /// </summary>
    {$Endregion}
    Property DraggingCell : Integer Read fDraggingCell;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets whether the current cell dragging changes the current page.
    /// </summary>
    {$Endregion}
    Property DraggingOffPage : Boolean Read fDraggingOffPage;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the identifier of the current automatic navigation timer.
    /// </summary>
    {$Endregion}
    Property NavigationTimer : Integer Read fNavigationTimer;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the current focused date.
    /// </summary>
    /// <exception cref="EDateTimeError">
    /// Occurs when the assigned date is not in the supported range of the calendar.
    /// </exception>
    /// <seealso cref="IsDateInRange"/>
    {$Endregion}
    Property Date : TDate Read fDate Write SetDate Stored IsDateStored;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the smallest date that is allowed for the calendar.
    /// </summary>
    /// <seealso cref="ActualDateMin"/>
    /// <seealso cref="DateMax"/>
    {$Endregion}
    Property DateMin : TDate Read fDateMin Write SetDateMin Stored IsDateMinStored;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the largest date that is allowed for the calendar.
    /// </summary>
    /// <seealso cref="ActualDateMax"/>
    /// <seealso cref="DateMin"/>
    {$Endregion}
    Property DateMax : TDate Read fDateMax Write SetDateMax Stored IsDateMaxStored;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the <see cref="TCalendar"/> class that is used for manipulating dates.
    /// </summary>
    /// <seealso cref="Culture"/>
    {$Endregion}
    Property CalendarType : TCalendarClass Read fCalendarType Write SetCalendarType;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the <see cref="TCultureInfo"/> object that provides the locale specific
    /// settings of the calendar.
    ///
    /// NOTE: If the <see cref="CalendarType"/> property is <see langword="nil"/>, depends
    /// on the values of <see cref="TLocalizer"/> and <see cref="CultureCalendar"/> properties,
    /// the Culture property may also determine the calendar system of the control.
    /// </summary>
    /// <seealso cref="UsingCultureCalendar"/>
    /// <seealso cref="CultureCalendar"/>
    /// <seealso cref="UsingCultureDigits"/>
    /// <seealso cref="CultureDigits"/>
    /// <seealso cref="CalendarType"/>
    /// <seealso cref="Localizer"/>
    {$Endregion}
    Property Culture : TCultureInfo Read fCulture Write SetCulture;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the calendar system used by the control should be determined
    /// by the <see cref="Culture"/> or <see cref="Localizer"/> properties.
    /// NOTE: Value of this property has no effect when the <see cref="CalendarType"/>
    /// property is not <see langword="nil"/>.
    /// </summary>
    /// <seealso cref="UsingCultureCalendar"/>
    /// <seealso cref="Culture"/>
    /// <seealso cref="Localizer"/>
    {$Endregion}
    Property CultureCalendar : TLocalizerSwicth Read fCultureCalendar Write SetCultureCalendar Default lsDefault;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the way the control renders digits should be determined
    /// by the <see cref="Culture"/> or <see cref="Localizer"/> properties.</summary>
    /// <seealso cref="UsingCultureDigits"/>
    /// <seealso cref="Culture"/>
    /// <seealso cref="Localizer"/>
    {$Endregion}
    Property CultureDigits : TLocalizerSwicth Read fCultureDigits Write SetCultureDigits Default lsDefault;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the ways thet a user can select dates of the calendar.
    /// </summary>
    {$Endregion}
    Property SelectionStyle : TIntlCalSelectionStyle Read fSelectionStyle Write SetSelectionStyle Default ssSingle;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether week numbers are shown on the calendar.
    /// </summary>
    {$Endregion}
    Property WeekNumbers : Boolean Read fWeekNumbers Write SetWeekNumbers Default False;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the calendar's header is shown.
    /// </summary>
    {$Endregion}
    Property ShowHeader : Boolean Read fShowHeader Write SetShowHeader Default True;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the calendar's footer is shown.
    /// </summary>
    {$Endregion}
    Property ShowFooter : Boolean Read fShowFooter Write SetShowFooter Default True;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the font to use when writing text on the calendar's header.
    /// </summary>
    {$Endregion}
    Property FontHeader : TFont Read fFontHeader Write SetFontHeader Stored fSaveFontHeader;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the font to use when writing text on the calendar's footer.
    /// </summary>
    {$Endregion}
    Property FontFooter : TFont Read fFontFooter Write SetFontFooter Stored fSaveFontFooter;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the font to use when writing name of days on the calendar.
    /// </summary>
    {$Endregion}
    Property FontDayOfWeek : TFont Read fFontDayOfWeek Write SetFontDayOfWeek Stored fSaveFontDayOfWeek;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the font to use when writing week numbers on the calendar.
    /// </summary>
    {$Endregion}
    Property FontWeekNumbers : TFont Read fFontWeekNumbers Write SetFontWeekNumbers Stored fSaveFontWeekNumbers;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets which date's component can be selected by the user right now.
    /// </summary>
    {$Endregion}
    Property CurrentView : TIntlCalViewMode Read fCurrentView Write SetCurrentView;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the <see cref="TLocalizer"/> component that is linked to the control.
    /// </summary>
    /// <seealso cref="Culture"/>
    {$Endregion}
    Property Localizer : TLocalizer Read fLocalizer Write SetLocalizer;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the color of divider line between calendar's grid and the other parts.
    /// </summary>
    {$Endregion}
    Property ColorDivider : TColor Read fColorDivider Write SetColorDivider Default clBtnFace;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the color of marker that distinguishes the today's date.
    /// </summary>
    {$Endregion}
    Property ColorToday : TColor Read fColorToday Write SetColorToday Default clRed;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control changes the pages with an animation.
    /// </summary>
    {$Endregion}
    Property Animate : Boolean Read fAnimate Write fAnimate Default True;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the <see cref="Date"/> property changes.
    /// </summary>
    {$Endregion}
    Property OnDateChange : TNotifyEvent Read fOnDateChange Write fOnDateChange;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the control's page changes.
    /// </summary>
    {$Endregion}
    Property OnPageChange : TNotifyEvent Read fOnPageChange Write fOnPageChange;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the <see cref="Calendar"/> property changes.
    /// </summary>
    {$Endregion}
    Property OnCalendarChange : TNotifyEvent Read fOnCalendarChange Write fOnCalendarChange;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the <see cref="Selection"/> property changes.
    /// </summary>
    {$Endregion}
    Property OnSelectionChange : TNotifyEvent Read fOnSelectionChange Write fOnSelectionChange;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the mouse pauses over a day of a month.
    /// </summary>
    {$Endregion}
    Property OnDateHint : TDateHintEvent Read fOnDateHint Write fOnDateHint;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when a day of a month is about to be selected.
    /// NOTE: This event occurs only with a <see cref="SelectionStyle"/> of ssFree.
    /// </summary>
    {$Endregion}
    Property OnDateSelectable : TDateSelectableEvent Read fOnDateSelectable Write fOnDateSelectable;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when name of a day of the week needs to be displayed.
    /// </summary>
    {$Endregion}
    Property OnCustomDrawDayOfWeek : TCustomDrawDayOfWeekEvent Read fOnCustomDrawDayOfWeek Write fOnCustomDrawDayOfWeek;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when a week number needs to be displayed.
    /// </summary>
    {$Endregion}
    Property OnCustomDrawWeekNumber : TCustomDrawWeekNumberEvent Read fOnCustomDrawWeekNumber Write fOnCustomDrawWeekNumber;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when a day of a month needs to be displayed.
    /// </summary>
    {$Endregion}
    Property OnCustomDrawDay : TCustomDrawDayEvent Read fOnCustomDrawDay Write fOnCustomDrawDay;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when name of a month needs to be displayed.
    /// </summary>
    {$Endregion}
    Property OnCustomDrawMonth : TCustomDrawMonthEvent Read fOnCustomDrawMonth Write fOnCustomDrawMonth;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when a year needs to be displayed.
    /// </summary>
    {$Endregion}
    Property OnCustomDrawYear : TCustomDrawYearEvent Read fOnCustomDrawYear Write fOnCustomDrawYear;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when text of calendar's header needs to be displayed.
    /// </summary>
    {$Endregion}
    Property OnCustomDrawHeaderText : TCustomDrawTextEvent Read fOnCustomDrawHeaderText Write fOnCustomDrawHeaderText;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when text of calendar's footer needs to be displayed.
    /// </summary>
    {$Endregion}
    Property OnCustomDrawFooterText : TCustomDrawTextEvent Read fOnCustomDrawFooterText Write fOnCustomDrawFooterText;
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
    /// Reevaluates the calendar and repaints it.
    /// </summary>
    {$Endregion}
    Procedure UpdateCalendar; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Deselects all selected dates in the control, if possible.
    /// </summary>
    /// <seealso cref="Select"/>
    /// <seealso cref="IsSelected"/>
    /// <seealso cref="SelectionStart"/>
    /// <seealso cref="SelectionEnd"/>
    /// <seealso cref="SelectionCount"/>
    /// <seealso cref="Selection"/>
    /// <seealso cref="SelectionStyle"/>
    {$Endregion}
    Procedure ClearSelection; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Selects a specified date as if clicked with the mouse. Conditional upon
    /// the value of <see cref="SelectionStyle"/> property, one date or multiple
    /// dates can be selected simultaneously.
    /// </summary>
    /// <param name="ADate">
    /// The <see cref="TDate"/> value to select.
    /// </param>
    /// <param name="ShiftState">
    /// Simulates the effect of using the Control key or the Shift key when selecting
    /// the date.
    /// </param>
    /// <seealso cref="ClearSelection"/>
    /// <seealso cref="IsSelected"/>
    /// <seealso cref="SelectionStart"/>
    /// <seealso cref="SelectionEnd"/>
    /// <seealso cref="SelectionCount"/>
    /// <seealso cref="Selection"/>
    /// <seealso cref="SelectionStyle"/>
    {$Endregion}
    Procedure Select(Const ADate : TDate; ShiftState : TShiftState = []); Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether a soecified date is selected.
    /// </summary>
    /// <param name="ADate">
    /// The <see cref="TDate"/> value to examine.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the <see cref="TDate"/> value is selected,
    /// otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="Select"/>
    /// <seealso cref="ClearSelection"/>
    /// <seealso cref="SelectionStart"/>
    /// <seealso cref="SelectionEnd"/>
    /// <seealso cref="SelectionCount"/>
    /// <seealso cref="Selection"/>
    /// <seealso cref="SelectionStyle"/>
    {$Endregion}
    Function IsSelected(Const ADate : TDate) : Boolean; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether the value of <see cref="Culture"/> property is controlled
    /// by a <see cref="TLocalizer"/> component.
    /// </summary>
    /// <returns>
    /// Rteurns <see langword="true"/> if <see cref="Localizer"/> property is not
    /// <see langword="nil"/>, otherwise returns <see langword="false"/>.</returns>
    /// <seealso cref="Localizer"/>
    {$Endregion}
    Function IsManagedByLocalizer : Boolean; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether a specified year of a specified era is in the supported
    /// and allowed range of the control.
    /// </summary>
    /// <param name="AEra">
    /// The era.
    /// </param>
    /// <param name="AYear">
    /// The year of the era.
    /// </param>
    /// <returns>
    /// Rteurns <see langword="true"/> if at least one day within the specified
    /// year can be represented by the cotnrol, otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="IsMonthInRange"/>
    /// <seealso cref="IsDateInRange"/>
    /// <seealso cref="DateMin"/>
    /// <seealso cref="DateMax"/>
    /// <seealso cref="ActualDateMin"/>
    /// <seealso cref="ActualDateMax"/>
    {$Endregion}
    Function IsYearInRange(AEra, AYear : Integer) : Boolean; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether a specified year is in the supported and allowed range of
    /// the control.
    /// </summary>
    /// <param name="AYear">
    /// The year to examine.
    /// </param>
    /// <returns>
    /// Rteurns <see langword="true"/> if at least one day within the specified
    /// year can be represented by the cotnrol, otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="IsMonthInRange"/>
    /// <seealso cref="IsDateInRange"/>
    /// <seealso cref="DateMin"/>
    /// <seealso cref="DateMax"/>
    /// <seealso cref="ActualDateMin"/>
    /// <seealso cref="ActualDateMax"/>
    {$Endregion}
    Function IsYearInRange(AYear : Integer) : Boolean; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether a specified month of a specified year in a specified era
    /// is in the supported and allowed range of the control.
    /// </summary>
    /// <param name="AEra">
    /// The era.
    /// </param>
    /// <param name="AYear">
    /// The year of the era.
    /// </param>
    /// <param name="AMonth">
    /// The month of the year.
    /// </param>
    /// <returns>
    /// Rteurns <see langword="true"/> if at least one day within the specified
    /// month can be represented by the cotnrol, otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="IsYearInRange"/>
    /// <seealso cref="IsDateInRange"/>
    /// <seealso cref="DateMin"/>
    /// <seealso cref="DateMax"/>
    /// <seealso cref="ActualDateMin"/>
    /// <seealso cref="ActualDateMax"/>
    {$Endregion}
    Function IsMonthInRange(AEra, AYear, AMonth : Integer) : Boolean; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether a specified month of a specified year is in the supported
    /// and allowed range of the control.
    /// </summary>
    /// <param name="AYear">
    /// The year of the era.
    /// </param>
    /// <param name="AMonth">
    /// The month of the year.
    /// </param>
    /// <returns>
    /// Rteurns <see langword="true"/> if at least one day within the specified
    /// month can be represented by the cotnrol, otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="IsYearInRange"/>
    /// <seealso cref="IsDateInRange"/>
    /// <seealso cref="DateMin"/>
    /// <seealso cref="DateMax"/>
    /// <seealso cref="ActualDateMin"/>
    /// <seealso cref="ActualDateMax"/>
    {$Endregion}
    Function IsMonthInRange(AYear, AMonth : Integer) : Boolean; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether a specified date is in the supported and allowed range
    /// of the control.
    /// </summary>
    /// <param name="ADate">
    /// The <see cref="TDate"/> value to examine.
    /// </param>
    /// <returns>
    /// Rteurns <see langword="true"/> if the date can be represented by the cotnrol,
    /// otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="IsYearInRange"/>
    /// <seealso cref="IsMonthInRange"/>
    /// <seealso cref="DateMin"/>
    /// <seealso cref="DateMax"/>
    /// <seealso cref="ActualDateMin"/>
    /// <seealso cref="ActualDateMax"/>
    {$Endregion}
    Function IsDateInRange(Const ADate : TDate) : Boolean; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Confines a specified date to be in the supported and allowed range
    /// of the control.
    /// </summary>
    /// <param name="ADate">
    /// The <see cref="TDate"/> value to confine.
    /// </param>
    /// <returns>
    /// If the date is less than <see cref="ActualDateMin"/>, returns <see cref="ActualDateMin"/>.
    /// If the date is greater than <see cref="ActualDateMax"/>, returns <see cref="ActualDateMax"/>.
    /// If the date is between <see cref="ActualDateMax"/> and <see cref="ActualDateMax"/>, returns
    /// the date as is.
    /// </returns>
    /// <seealso cref="ActualDateMin"/>
    /// <seealso cref="ActualDateMax"/>
    {$Endregion}
    Function EnsureDateInRange(Const ADate : TDate) : TDate; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Formats a <see cref="TDateTime"/> value.
    /// </summary>
    /// <remarks>
    /// The Format method formats the <see cref="TDateTime"/> value given by
    /// <paramref name="Date"/> using the format string given by <paramref name="FmtStr"/>.
    ///
    /// The format string controls the formatting of date and time, and is composed
    /// from specifiers that represent values to insert into the formatted string.
    /// See <see cref="TCalendar.Format"/> for details.
    /// </remarks>
    /// <param name="FmtStr">
    /// The format string. See <see cref="TCalendar.Format"/> method for details.
    /// </param>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <returns>
    /// The formatted <see cref="TDateTime"/> value as a string.
    /// </returns>
    /// <seealso cref="TCalendar.Format"/>
    {$Endregion}
    Function Format(Const FmtStr : String; Const ADate : TDateTime) : String;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the <see cref="TCalendar"/> object that the control is using to
    /// manipulate and display dates.
    /// </summary>
    {$Endregion}
    Property Calendar : TCalendar Read fCalendar;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the era represented by the <see cref="Date"/> property.
    /// </summary>
    {$Endregion}
    Property Era : Integer Read fEra;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the year represented by the <see cref="Date"/> property.
    /// </summary>
    {$Endregion}
    Property Year : Integer Read fYear;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the month represented by the <see cref="Date"/> property.
    /// </summary>
    {$Endregion}
    Property Month : Integer Read fMonth;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the day of the month represented by the <see cref="Date"/> property.
    /// </summary>
    {$Endregion}
    Property Day : Integer Read fDay;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the number of days in the month represented by the <see cref="Date"/>
    /// property.
    /// </summary>
    {$Endregion}
    Property DaysInMonth : Integer Read fDaysInMonth;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the <see cref="TDate"/> value for the first day of the the month
    /// represented by the <see cref="Date"/> property.
    /// </summary>
    {$Endregion}
    Property MonthFirstDate : TDate Read fMonthFirstDate;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the <see cref="TDate"/> value for the last day of the the month
    /// represented by the <see cref="Date"/> property.
    /// </summary>
    {$Endregion}
    Property MonthLastDate : TDate Read GetMonthLastDate;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the first day of the week for the the month represented by the
    /// <see cref="Date"/> property.
    /// </summary>
    {$Endregion}
    Property MonthFirstDayOfWeek : TDayOfWeek Read fMonthFirstDayOfWeek;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the number of months in the year represented by the <see cref="Date"/>
    /// property.
    /// </summary>
    {$Endregion}
    Property MonthsInYear : Integer Read fMonthsInYear;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the number of years in the year represented by the <see cref="Date"/>
    /// property.
    /// </summary>
    {$Endregion}
    Property DaysInYear : Integer Read fDaysInYear;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the smallest date that is supported by the <see cref="Calendar"/> and
    /// is allowed by the control.
    /// </summary>
    /// <seealso cref="DateMin"/>
    /// <seealso cref="TCalendar.MinSupportedDateTime"/>
    /// <seealso cref="ActualDateMax"/>
    {$Endregion}
    Property ActualDateMin : TDate Read fActualDateMin;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the largest date that is supported by the <see cref="Calendar"/> and
    /// is allowed by the control.
    /// </summary>
    /// <seealso cref="DateMax"/>
    /// <seealso cref="TCalendar.MaxSupportedDateTime"/>
    /// <seealso cref="ActualDateMin"/>
    {$Endregion}
    Property ActualDateMax : TDate Read fActualDateMax;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the smallest selected date.
    /// </summary>
    /// <seealso cref="SelectionEnd"/>
    /// <seealso cref="SelectionCount"/>
    /// <seealso cref="Selection"/>
    /// <seealso cref="SelectionStyle"/>
    {$Endregion}
    Property SelectionStart : TDate Read GetSelectionStart;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the largest selected date.
    /// </summary>
    /// <seealso cref="SelectionStart"/>
    /// <seealso cref="SelectionCount"/>
    /// <seealso cref="Selection"/>
    /// <seealso cref="SelectionStyle"/>
    {$Endregion}
    Property SelectionEnd : TDate Read GetSelectionEnd;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the number of selected dates.
    /// </summary>
    /// <seealso cref="SelectionStart"/>
    /// <seealso cref="SelectionEnd"/>
    /// <seealso cref="Selection"/>
    /// <seealso cref="SelectionStyle"/>
    {$Endregion}
    Property SelectionCount : Integer Read GetSelectionCount;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the selected dates.
    /// </summary>
    /// <seealso cref="SelectionCount"/>
    /// <seealso cref="SelectionStart"/>
    /// <seealso cref="SelectionEnd"/>
    /// <seealso cref="SelectionStyle"/>
    {$Endregion}
    Property Selection[Index : Integer] : TDate Read GetSelection;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets whether the calendar system used by the control is determined by the
    /// <see cref="Culture"/> property.
    /// </summary>
    /// <seealso cref="CultureCalendar"/>
    /// <seealso cref="Culture"/>
    {$Endregion}
    Property UsingCultureCalendar : Boolean Read GetUsingCultureCalendar;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets whether the way that the control renders digits is determined by the
    /// <see cref="Culture"/> property.
    /// </summary>
    /// <seealso cref="CultureDigits"/>
    /// <seealso cref="Culture"/>
    {$Endregion}
    Property UsingCultureDigits : Boolean Read GetUsingCultureDigits;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TIntlMonthCalendar is a month calendar control that displays a fully localizable
/// calendar on a form.
/// </summary>
/// <remarks>
/// Use TIntlMonthCalendar to enable users to select dates from a localized calendar.
///
/// TIntlMonthCalendar can use different calendar systems for manipulating and displaying
/// the dates. The <see cref="CalendarType"/> property is the main property that specifies
/// which calendar system should be used by the cotnrol. If the <see cref="CalendarType"/>
/// property is not set, the <see cref="Culture"/> property can do this task. In addition,
/// the <see cref="Culture"/> property provides the locale specific settings of the control.
/// If none of these two properties are set, the <see cref="DefaultCalendar"/> global
/// variable determines the calendar system used by the control.
///
/// TIntlMonthCalendar can be linked to a <see cref="TLocalizer"/> component. In this case,
/// the linked <see cref="TLocalizer"/> component can provide both the locale specific
/// settings and the calendar system of the calendar control.
///
/// TIntlMonthCalendar publishes many of the properties, events, and methods of
/// <see cref="TCustomIntlMonthCalendar"/>, but does not introduce any new behavior.
/// </remarks>
/// <group name="Components"/>
{$Endregion}
{$IFDEF COMPILER_XE2_UP}

  [ComponentPlatformsAttribute(pidWin32 Or pidWin64)]
  {$ENDIF}
  TIntlMonthCalendar = Class(TCustomIntlMonthCalendar)
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets which date's component can be selected by the user right now.
    /// </summary>
    {$Endregion}
    Property CurrentView;
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
    /// Gets or sets whether the control changes the pages with an animation.
    /// </summary>
    {$Endregion}
    Property Animate;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control sizes itself automatically to accommodate
    /// its contents.
    /// </summary>
    {$Endregion}
    Property AutoSize;
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
    Property BevelKind Default bkTile;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the cut of the outer bevel.
    /// </summary>
    {$Endregion}
    Property BevelOuter;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the width of the control's border.
    /// </summary>
    {$Endregion}
    Property BorderWidth Default 2;
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
    /// Gets or sets the color of divider line between calendar's grid and the other parts.
    /// </summary>
    {$Endregion}
    Property ColorDivider;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the color of marker that distinguishes the today's date.
    /// </summary>
    {$Endregion}
    Property ColorToday;
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
    ///
    /// NOTE: If the <see cref="CalendarType"/> property is <see langword="nil"/>, depends
    /// on the values of <see cref="TLocalizer"/> and <see cref="CultureCalendar"/> properties,
    /// the Culture property may also determine the calendar system of the control.
    /// </summary>
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
    /// NOTE: Value of this property has no effect when the <see cref="CalendarType"/>
    /// property is not <see langword="nil"/>.
    /// </summary>
    /// <seealso cref="UsingCultureCalendar"/>
    /// <seealso cref="Culture"/>
    /// <seealso cref="Localizer"/>
    {$Endregion}
    Property CultureCalendar;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the way the control renders digits should be determined
    /// by the <see cref="Culture"/> or <see cref="Localizer"/> properties.</summary>
    /// <seealso cref="UsingCultureDigits"/>
    /// <seealso cref="Culture"/>
    /// <seealso cref="Localizer"/>
    {$Endregion}
    Property CultureDigits;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the current focused date.
    /// </summary>
    /// <exception cref="EDateTimeError">
    /// Occurs when the assigned date is not in the supported range of the calendar.
    /// </exception>
    /// <seealso cref="IsDateInRange"/>
    {$Endregion}
    Property Date;
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
    /// Gets or sets the font to use when writing text on the calendar's header.
    /// </summary>
    {$Endregion}
    Property FontHeader;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the font to use when writing text on the calendar's footer.
    /// </summary>
    {$Endregion}
    Property FontFooter;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the font to use when writing name of days on the calendar.
    /// </summary>
    {$Endregion}
    Property FontDayOfWeek;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the font to use when writing week numbers on the calendar.
    /// </summary>
    {$Endregion}
    Property FontWeekNumbers;
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
    /// Gets or sets the ways thet a user can select dates of the calendar.
    /// </summary>
    {$Endregion}
    Property SelectionStyle;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the calendar's header is shown.
    /// </summary>
    {$Endregion}
    Property ShowHeader;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the calendar's footer is shown.
    /// </summary>
    {$Endregion}
    Property ShowFooter;
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
    /// Gets or sets whether week numbers are shown on the calendar.
    /// </summary>
    {$Endregion}
    Property WeekNumbers;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the <see cref="Calendar"/> property changes.
    /// </summary>
    {$Endregion}
    Property OnCalendarChange;
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
    /// Occurs when text of calendar's header needs to be displayed.
    /// </summary>
    {$Endregion}
    Property OnCustomDrawHeaderText;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when a day of a month needs to be displayed.
    /// </summary>
    {$Endregion}
    Property OnCustomDrawDay;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when name of a month needs to be displayed.
    /// </summary>
    {$Endregion}
    Property OnCustomDrawMonth;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when a year needs to be displayed.
    /// </summary>
    {$Endregion}
    Property OnCustomDrawYear;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when name of a day of the week needs to be displayed.
    /// </summary>
    {$Endregion}
    Property OnCustomDrawDayOfWeek;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when a week number needs to be displayed.
    /// </summary>
    {$Endregion}
    Property OnCustomDrawWeekNumber;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when text of calendar's footer needs to be displayed.
    /// </summary>
    {$Endregion}
    Property OnCustomDrawFooterText;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the <see cref="Date"/> property changes.
    /// </summary>
    {$Endregion}
    Property OnDateChange;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when a day of a month is about to be selected.
    /// NOTE: This event occurs only with a <see cref="SelectionStyle"/> of ssFree.
    /// </summary>
    {$Endregion}
    Property OnDateSelectable;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the mouse pauses over a day of a month.
    /// </summary>
    {$Endregion}
    Property OnDateHint;
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
    /// Occurs when the control's page changes.
    /// </summary>
    {$Endregion}
    Property OnPageChange;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs immediately after the control is resized.
    /// </summary>
    {$Endregion}
    Property OnResize;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the <see cref="Selection"/> property changes.
    /// </summary>
    {$Endregion}
    Property OnSelectionChange;
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
/// TPopupCloseUpEvent is the type for event handlers that respond when a popup
/// window closes.
/// </summary>
/// <param name="Sender">
/// The pop-up window that generated the event.
/// </param>
/// <param name="Accept">
/// Indicates whether the user accepted the pop-up window or canceled it.
/// </param>
{$Endregion}

  TPopupCloseUpEvent = Procedure(Sender : TObject; Accept : Boolean) Of Object;

{$Region 'xmldoc'}
/// <summary>
/// TIntlMonthCalendarPopup is a pop-up window for controls that needs the user
/// select a localized date.
/// </summary>
/// <remarks>
/// Use TIntlMonthCalendarPopup in your own control to enable users to select a
/// localized date from a pop-up window.
///
/// TIntlMonthCalendarPopup can use different calendar systems for manipulating and
/// displaying the dates. The <see cref="CalendarType"/> property is the main property
/// that specifies which calendar system should be used by the cotnrol. If the
/// <see cref="CalendarType"/> property is not set, the <see cref="Culture"/> property
/// can do this task. In addition, the <see cref="Culture"/> property provides the
/// locale specific settings of the control. If none of these two properties are set,
/// the <see cref="DefaultCalendar"/> global variable determines the calendar system
/// used by the control.
/// </remarks>
{$Endregion}

  TIntlMonthCalendarPopup = Class(TCustomIntlMonthCalendar)
   Private
    fOnCloseUp : TPopupCloseUpEvent;
    Procedure WMMouseActivate(Var Message : TMessage); Message WM_MOUSEACTIVATE;
    Procedure CMVisibleChanged(Var Message : TMessage); Message CM_VISIBLECHANGED;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Initializes the window-creation parameter record.
    /// </summary>
    /// <param name="Params">
    /// The window-creation parameter record.
    /// </param>
    {$Endregion}
    Procedure CreateParams(Var Params : TCreateParams); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Responds when the user releases a previously pressed mouse button down while the
    /// cursor's hotspot is over the popup.
    /// </summary>
    /// <param name="Button">
    /// Determines which mouse button the user released.
    /// </param>
    /// <param name="Shift">
    /// Indicates which shift keys (Shift, Ctrl, or Alt) were down when the user released the mouse button.
    /// </param>
    /// <param name="X">
    /// The horizontal pixel coordinate of the mouse pointer within the client area of the popup.
    /// </param>
    /// <param name="Y">
    /// The vertical pixel coordinate of the mouse pointer within the client area of the popup.
    /// </param>
    {$Endregion}
    Procedure MouseUp(Button : TMouseButton; Shift : TShiftState; x, y : Integer); Override;
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
    /// Generates an <see cref="OnCloseUp"/> event.
    /// </summary>
    /// <param name="Accept">
    /// Indicates whether the currently selected date is acceptable.
    /// </param>
    {$Endregion}
    Procedure DoCloseUp(Accept : Boolean); Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the pop-up hides.
    /// </summary>
    {$Endregion}
    Property OnCloseUp : TPopupCloseUpEvent Read fOnCloseUp Write fOnCloseUp;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the popup.
    /// </summary>
    /// <param name="AParent">
    /// The windowed control that owns the popup.
    /// </param>
    {$Endregion}
    Constructor Create(AOwner : TWinControl); Reintroduce;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether the pop-up has input focus.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> if the popup's owner has input focus, otherwise
    /// returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function Focused : Boolean; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Displays the pop-up at a specified coordinates.
    /// </summary>
    /// <param name="X">
    /// The horizontal screen coordinate, in pixels.
    /// </param>
    /// <param name="Y">
    /// The vertical screen coordinate, in pixels.
    /// </param>
    {$Endregion}
    Procedure Show(x, y : Integer);
   Published
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the horizontal coordinate of the left edge of the pop-up relative to screen.
    /// </summary>
    {$Endregion}
    Property Left Stored False;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the vertical coordinate of the top edge of the pop-up relative to screen.
    /// </summary>
    {$Endregion}
    Property Top Stored False;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the horizontal size of the pop-up in pixels.
    /// </summary>
    {$Endregion}
    Property Width Stored False;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the vertical size of the pop-up in pixels.
    /// </summary>
    {$Endregion}
    Property Height Stored False;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control changes the pages with an animation.
    /// </summary>
    {$Endregion}
    Property Animate;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the background color of the control.
    /// </summary>
    {$Endregion}
    Property Color Default clWindow;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the color of divider line between calendar's grid and the other parts.
    /// </summary>
    {$Endregion}
    Property ColorDivider;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the color of marker that distinguishes the today's date.
    /// </summary>
    {$Endregion}
    Property ColorToday;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the attributes of text written on the control.
    /// </summary>
    {$Endregion}
    Property Font;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the font to use when writing text on the calendar's header.
    /// </summary>
    {$Endregion}
    Property FontHeader;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the font to use when writing text on the calendar's footer.
    /// </summary>
    {$Endregion}
    Property FontFooter;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the font to use when writing name of days on the calendar.
    /// </summary>
    {$Endregion}
    Property FontDayOfWeek;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the font to use when writing week numbers on the calendar.
    /// </summary>
    {$Endregion}
    Property FontWeekNumbers;
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
    /// Gets or sets whether the calendar's header is shown.
    /// </summary>
    {$Endregion}
    Property ShowHeader;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the calendar's footer is shown.
    /// </summary>
    {$Endregion}
    Property ShowFooter Default True;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the control displays a Help <see cref="Hint"/> when the mouse
    /// pointer rests momentarily on the control.
    /// </summary>
    {$Endregion}
    Property ShowHint;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether week numbers are shown on the calendar.
    /// </summary>
    {$Endregion}
    Property WeekNumbers;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when text of calendar's header needs to be displayed.
    /// </summary>
    {$Endregion}
    Property OnCustomDrawHeaderText;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when a day of a month needs to be displayed.
    /// </summary>
    {$Endregion}
    Property OnCustomDrawDay;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when name of a month needs to be displayed.
    /// </summary>
    {$Endregion}
    Property OnCustomDrawMonth;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when a year needs to be displayed.
    /// </summary>
    {$Endregion}
    Property OnCustomDrawYear;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when name of a day of the week needs to be displayed.
    /// </summary>
    {$Endregion}
    Property OnCustomDrawDayOfWeek;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when a week number needs to be displayed.
    /// </summary>
    {$Endregion}
    Property OnCustomDrawWeekNumber;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when text of calendar's footer needs to be displayed.
    /// </summary>
    {$Endregion}
    Property OnCustomDrawFooterText;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the mouse pauses over a day of a month.
    /// </summary>
    {$Endregion}
    Property OnDateHint;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This enumeration type identifies the sections of a date picker control
/// that a mouse pointer can be over it.
/// </summary>
{$Endregion}

  TIntlPickerHitTest = (
  {$Region 'xmldoc'}
  /// Nowhere
  {$Endregion}
  phtNowhere,
  {$Region 'xmldoc'}
  /// Drop-down button
  {$Endregion}
  phtDropDown,
  {$Region 'xmldoc'}
  /// Check box
  {$Endregion}
  phtCheckBox,
  {$Region 'xmldoc'}
  /// Displayed date
  {$Endregion}
  phtDate,
  {$Region 'xmldoc'}
  /// A non-specific part of the control
  {$Endregion}
  phtControl
  );

{$Region 'xmldoc'}
/// <summary>
/// TCustomIntlDatePicker is the base class for controls that request a localized
/// date from the user.
/// </summary>
/// <remarks>
/// Use TCustomIntlDatePicker as a base class when defining objects that enable
/// users to input a localized date.
///
/// TCustomIntlDatePicker can use different calendar systems for getting the input
/// date. The <see cref="CalendarType"/> property is the main property that specifies
/// which calendar system should be used by the cotnrol. If the <see cref="CalendarType"/>
/// property is not set, the <see cref="Culture"/> property can do this task. In addition,
/// the <see cref="Culture"/> property provides the locale specific settings of the control.
/// If none of these two properties are set, the <see cref="DefaultCalendar"/> global
/// variable determines the calendar system used by the control.
///
/// TCustomIntlDatePicker can be linked to a <see cref="TLocalizer"/> component.
/// In this case, the linked <see cref="TLocalizer"/> component can provide both the
/// locale specific settings and the calendar system of the control.
/// </remarks>
{$Endregion}

  TCustomIntlDatePicker = Class(TCustomControl)
   Private
    fDate          : TDate;
    fDateFormat    : String;
    fChecked       : Boolean;
    fShowCheckBox  : Boolean;
    fBorderStyle   : TBorderStyle;
    fCalendarPopup : TIntlMonthCalendarPopup;
    fCheckBoxRect  : TRect;
    fDropDownRect  : TRect;
    fDateRect      : TRect;
    fHotInfo       : TIntlPickerHitTest;
    fTheme         : HTHEME;
    fCheckPressed  : Boolean;
    fOnChange      : TNotifyEvent;
    Procedure SetDate(Const Value : TDate);
    Procedure SetDateFormat(Const Value : String);
    Procedure SetChecked(Value : Boolean);
    Procedure SetShowCheckBox(Value : Boolean);
    Procedure SetBorderStyle(Value : TBorderStyle);
    Function GetDateMin : TDate; Inline;
    Procedure SetDateMin(Const Value : TDate); Inline;
    Function GetDateMax : TDate; Inline;
    Procedure SetDateMax(Const Value : TDate); Inline;
    Function GetCalendarType : TCalendarClass; Inline;
    Procedure SetCalendarType(Value : TCalendarClass); Inline;
    Function GetCulture : TCultureInfo; Inline;
    Procedure SetCulture(Value : TCultureInfo); Inline;
    Function GetCultureCalendar : TLocalizerSwicth; Inline;
    Procedure SetCultureCalendar(Value : TLocalizerSwicth); Inline;
    Function GetCultureDigits : TLocalizerSwicth; Inline;
    Procedure SetCultureDigits(Value : TLocalizerSwicth); Inline;
    Function GetLocalizer : TLocalizer; Inline;
    Procedure SetLocalizer(Value : TLocalizer); Inline;
    Function GetCalendar : TCalendar; Inline;
    Function GetActualDateMin : TDate; Inline;
    Function GetActualDateMax : TDate; Inline;
    Function GetUsingCultureCalendar : Boolean; Inline;
    Function GetUsingCultureDigits : Boolean; Inline;
    Function GetTheme : HTHEME;
    Function IsDateStored : Boolean;
    Function IsDateMinStored : Boolean;
    Function IsDateMaxStored : Boolean;
    Procedure ReadCulture(Reader : TReader);
    Procedure WriteCulture(Writer : TWriter);
    Procedure ReadCalendarType(Reader : TReader);
    Procedure WriteCalendarType(Writer : TWriter);
    Procedure CalendarChanged(Sender : TObject);
    Procedure PopupCloseUp(Sender : TObject; Accept : Boolean);
    Procedure WMNCPaint(Var Message : TWMNCPaint); Message WM_NCPAINT;
    Procedure WMMouseActivate(Var Message : TWMMouseActivate); Message WM_MOUSEACTIVATE;
    Procedure WMSetFocus(Var Message : TWMSetFocus); Message WM_SETFOCUS;
    Procedure WMKillFocus(Var Message : TWMKillFocus); Message WM_KILLFOCUS;
    Procedure WMGetDlgCode(Var Message : TWMGetDlgCode); Message WM_GETDLGCODE;
    Procedure CMEnableChanged(Var Message : TMessage); Message CM_ENABLEDCHANGED;
    Procedure CMBiDiModeChanged(Var Message : TMessage); Message CM_BIDIMODECHANGED;
    Procedure CMBorderChanged(Var Message : TMessage); Message CM_BORDERCHANGED;
    Procedure CMCtl3DChanged(Var Message : TMessage); Message CM_CTL3DCHANGED;
    Procedure CMCancelMode(Var Message : TCMCancelMode); Message CM_CANCELMODE;
    Procedure CMMouseEnter(Var Message : TMessage); Message CM_MOUSEENTER;
    Procedure CMMouseLeave(Var Message : TMessage); Message CM_MOUSELEAVE;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Reads and writes the <see cref="Culture"/> and <see cref="CalendarType"/> properties
    /// as if they were published.
    /// </summary>
    /// <param name="Filer">
    /// The current <see cref="TReader"/> or <see cref="TWriter"/> object that is
    /// loading or saving the published properties.
    /// </param>
    {$Endregion}
    Procedure DefineProperties(Filer : TFiler); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Initializes the window-creation parameter record.
    /// </summary>
    /// <param name="Params">
    /// The window-creation parameter record.
    /// </param>
    {$Endregion}
    Procedure CreateParams(Var Params : TCreateParams); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Makes any required adjustments when the control changes size.
    /// </summary>
    {$Endregion}
    Procedure Resize; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Renders the control.
    /// </summary>
    {$Endregion}
    Procedure Paint; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether the control can resize itself automatically to accommodate
    /// its contents.
    /// </summary>
    /// <param name="NewWidth">
    /// Indicates the proposed new width of the control.
    /// </param>
    /// <param name="NewHeight">
    /// Indicates the proposed new height of the control.
    /// </param>
    /// <returns>
    /// Always returns <see langword="true"/>.
    /// </returns>
    {$Endregion}
    Function CanAutoSize(Var NewWidth : Integer; Var NewHeight : Integer) : Boolean; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Responds when the user presses a mouse button down while the cursor's hotspot is
    /// over the control.
    /// </summary>
    /// <param name="Button">
    /// Determines which mouse button the user pressed.
    /// </param>
    /// <param name="Shift">
    /// Indicates which shift keys (Shift, Ctrl, or Alt) were down when the user pressed the mouse button.
    /// </param>
    /// <param name="X">
    /// The horizontal pixel coordinate of the mouse pointer within the client area of the control.
    /// </param>
    /// <param name="Y">
    /// The vertical pixel coordinate of the mouse pointer within the client area of the control.
    /// </param>
    {$Endregion}
    Procedure MouseDown(Button : TMouseButton; Shift : TShiftState; x, y : Integer); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Responds when the user moves the mouse pointer while the cursor's hotspot is
    /// over the control.
    /// </summary>
    /// <param name="Shift">
    /// Indicates which shift keys (Shift, Ctrl, or Alt) were down when the user moved the mouse pointer.
    /// </param>
    /// <param name="X">
    /// The horizontal pixel coordinate of the mouse pointer within the client area of the control.
    /// </param>
    /// <param name="Y">
    /// The vertical pixel coordinate of the mouse pointer within the client area of the control.
    /// </param>
    {$Endregion}
    Procedure MouseMove(Shift : TShiftState; x, y : Integer); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Responds when the user releases a previously pressed mouse button down while the
    /// cursor's hotspot is over the control.
    /// </summary>
    /// <param name="Button">
    /// Determines which mouse button the user released.
    /// </param>
    /// <param name="Shift">
    /// Indicates which shift keys (Shift, Ctrl, or Alt) were down when the user released the mouse button.
    /// </param>
    /// <param name="X">
    /// The horizontal pixel coordinate of the mouse pointer within the client area of the control.
    /// </param>
    /// <param name="Y">
    /// The vertical pixel coordinate of the mouse pointer within the client area of the control.
    /// </param>
    {$Endregion}
    Procedure MouseUp(Button : TMouseButton; Shift : TShiftState; x, y : Integer); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Responds when the user rotates the mouse wheel downward.
    /// </summary>
    /// <param name="Shift">
    /// Indicates which shift keys (Shift, Ctrl, or Alt) were down when the user rotated the mouse wheel.
    /// </param>
    /// <param name="MousePos">
    /// The pixel coordinates of the mouse pointer within the screen.
    /// </param>
    {$Endregion}
    Function DoMouseWheelDown(Shift : TShiftState; MousePos : TPoint) : Boolean; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Responds when the user rotates the mouse wheel upward.
    /// </summary>
    /// <param name="Shift">
    /// Indicates which shift keys (Shift, Ctrl, or Alt) were down when the user rotated the mouse wheel.
    /// </param>
    /// <param name="MousePos">
    /// The pixel coordinates of the mouse pointer within the screen.
    /// </param>
    {$Endregion}
    Function DoMouseWheelUp(Shift : TShiftState; MousePos : TPoint) : Boolean; Override;
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
    /// Determines whether the user can enter a different date in the control.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> if the user can enter a date, oterwise
    /// returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function CanModify : Boolean; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Updates the displayed date on the control.
    /// </summary>
    {$Endregion}
    Procedure UpdateText; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Recalculates the bounding rectangle of the control's different sections.
    /// </summary>
    {$Endregion}
    Procedure UpdateRects; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the minimum vertical size of the control, in pixels.
    /// </summary>
    /// <returns>
    /// The minimum vertical size of the control, in pixels.
    /// </returns>
    {$Endregion}
    Function GetMinHeight : Integer; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Determines that a point is in which section of the control.
    /// </summary>
    /// <param name="X">
    /// The point's horizontal coordinate in the control's coordinate space.
    /// </param>
    /// <param name="Y">
    /// The point's vertical coordinate in the control's coordinate space.
    /// </param>
    /// <returns>
    /// Returns a <see cref="TIntlPickerHitTest"/> value.
    /// </returns>
    {$Endregion}
    Function GetHitTestInfoAt(x, y : Integer) : TIntlPickerHitTest; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Schedules a repaint for the check box of the control.
    /// </summary>
    {$Endregion}
    Procedure InvalidateCheckBox; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Schedules a repaint for the drop-down button of the control.
    /// </summary>
    {$Endregion}
    Procedure InvalidateDropDown; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Schedules a repaint for the displayed date of the control.
    /// </summary>
    {$Endregion}
    Procedure InvalidateDate; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Schedules a repaint for the frame of the control.
    /// </summary>
    {$Endregion}
    Procedure InvalidateFrame; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Displays the pop-up calendar.
    /// </summary>
    /// <seealso cref="CalendarPopup"/>
    {$Endregion}
    Procedure PopupDropDown; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnChange"/> event.
    /// </summary>
    {$Endregion}
    Procedure Change; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the handle to the Windows theme that is used for rendering the control.
    /// </summary>
    {$Endregion}
    Property Theme : HTHEME Read GetTheme;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the last mouse hit test information.
    /// </summary>
    {$Endregion}
    Property HotInfo : TIntlPickerHitTest Read fHotInfo;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets whether the user holding the check box pressed.
    /// </summary>
    {$Endregion}
    Property CheckPressed : Boolean Read fCheckPressed;
    {$Region 'xmldoc'}
    /// <summary>
    /// Provides access to the pop-up calendar's settings.
    /// </summary>
    {$Endregion}
    Property CalendarPopup : TIntlMonthCalendarPopup Read fCalendarPopup;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the current focused date.
    /// </summary>
    /// <exception cref="EDateTimeError">
    /// Occurs when the assigned date is not in the supported range of the calendar.
    /// </exception>
    /// <seealso cref="IsDateInRange"/>
    {$Endregion}
    Property Date : TDate Read fDate Write SetDate Stored IsDateStored;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the format string that determines how the <see cref="Date"/> property
    /// should be displayed on the control. See <see cref="TCalendar.Format"/> for details.
    /// </summary>
    /// <seealso cref="TCalendar.Format"/>
    {$Endregion}
    Property DateFormat : String Read fDateFormat Write SetDateFormat;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the smallest date that is allowed for the calendar.
    /// </summary>
    /// <seealso cref="ActualDateMin"/>
    /// <seealso cref="DateMax"/>
    {$Endregion}
    Property DateMin : TDate Read GetDateMin Write SetDateMin Stored IsDateMinStored;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the largest date that is allowed for the calendar.
    /// </summary>
    /// <seealso cref="ActualDateMax"/>
    /// <seealso cref="DateMin"/>
    {$Endregion}
    Property DateMax : TDate Read GetDateMax Write SetDateMax Stored IsDateMaxStored;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the <see cref="TCalendar"/> class that is used for manipulating dates.
    /// </summary>
    /// <seealso cref="Culture"/>
    {$Endregion}
    Property CalendarType : TCalendarClass Read GetCalendarType Write SetCalendarType;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the <see cref="TCultureInfo"/> object that provides the locale specific
    /// settings of the calendar.
    ///
    /// NOTE: If the <see cref="CalendarType"/> property is <see langword="nil"/>, conditional
    /// upon the values of <see cref="TLocalizer"/> and <see cref="CultureCalendar"/> properties,
    /// the Culture property may also determine the calendar system of the control.
    /// </summary>
    /// <seealso cref="UsingCultureCalendar"/>
    /// <seealso cref="CultureCalendar"/>
    /// <seealso cref="UsingCultureDigits"/>
    /// <seealso cref="CultureDigits"/>
    /// <seealso cref="CalendarType"/>
    /// <seealso cref="Localizer"/>
    {$Endregion}
    Property Culture : TCultureInfo Read GetCulture Write SetCulture;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the calendar system used by the control should be determined
    /// by the <see cref="Culture"/> or <see cref="Localizer"/> properties.
    /// NOTE: Value of this property has no effect when the <see cref="CalendarType"/>
    /// property is not <see langword="nil"/>.
    /// </summary>
    /// <seealso cref="UsingCultureCalendar"/>
    /// <seealso cref="Culture"/>
    /// <seealso cref="Localizer"/>
    {$Endregion}
    Property CultureCalendar : TLocalizerSwicth Read GetCultureCalendar Write SetCultureCalendar Default lsDefault;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the way the control renders digits should be determined
    /// by the <see cref="Culture"/> or <see cref="Localizer"/> properties.</summary>
    /// <seealso cref="UsingCultureDigits"/>
    /// <seealso cref="Culture"/>
    /// <seealso cref="Localizer"/>
    {$Endregion}
    Property CultureDigits : TLocalizerSwicth Read GetCultureDigits Write SetCultureDigits Default lsDefault;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the <see cref="TLocalizer"/> component that is linked to the control.
    /// </summary>
    {$Endregion}
    Property Localizer : TLocalizer Read GetLocalizer Write SetLocalizer;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the check box next to the date is selected. When the
    /// check box is not checked, user cannot enter a date.
    /// </summary>
    {$Endregion}
    Property Checked : Boolean Read fChecked Write SetChecked Default True;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether a check box next to the date should be displayed.
    /// </summary>
    {$Endregion}
    Property ShowCheckBox : Boolean Read fShowCheckBox Write SetShowCheckBox Default False;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the border style for the control.
    /// </summary>
    {$Endregion}
    Property BorderStyle : TBorderStyle Read fBorderStyle Write SetBorderStyle Default bsSingle;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when either of <see cref="Date"/> or <see cref="Checked"/> properties change.</summary>
    {$Endregion}
    Property OnChange : TNotifyEvent Read fOnChange Write fOnChange;
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
    /// Indicates whether the value of <see cref="Culture"/> property is controlled
    /// by a <see cref="TLocalizer"/> component.
    /// </summary>
    /// <returns>
    /// Rteurns <see langword="true"/> if <see cref="Localizer"/> property is not
    /// <see langword="nil"/>, otherwise returns <see langword="false"/>.</returns>
    /// <seealso cref="Localizer"/>
    {$Endregion}
    Function IsManagedByLocalizer : Boolean; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether a specified year of a specified era is in the supported
    /// and allowed range of the control.
    /// </summary>
    /// <param name="AEra">
    /// The era.
    /// </param>
    /// <param name="AYear">
    /// The year of the era.
    /// </param>
    /// <returns>
    /// Rteurns <see langword="true"/> if at least one day within the specified
    /// year can be represented by the cotnrol, otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="IsMonthInRange"/>
    /// <seealso cref="IsDateInRange"/>
    /// <seealso cref="DateMin"/>
    /// <seealso cref="DateMax"/>
    /// <seealso cref="ActualDateMin"/>
    /// <seealso cref="ActualDateMax"/>
    {$Endregion}
    Function IsYearInRange(AEra, AYear : Integer) : Boolean; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether a specified year is in the supported and allowed range of
    /// the control.
    /// </summary>
    /// <param name="AYear">
    /// The year to examine.
    /// </param>
    /// <returns>
    /// Rteurns <see langword="true"/> if at least one day within the specified
    /// year can be represented by the cotnrol, otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="IsMonthInRange"/>
    /// <seealso cref="IsDateInRange"/>
    /// <seealso cref="DateMin"/>
    /// <seealso cref="DateMax"/>
    /// <seealso cref="ActualDateMin"/>
    /// <seealso cref="ActualDateMax"/>
    {$Endregion}
    Function IsYearInRange(AYear : Integer) : Boolean; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether a specified month of a specified year in a specified era
    /// is in the supported and allowed range of the control.
    /// </summary>
    /// <param name="AEra">
    /// The era.
    /// </param>
    /// <param name="AYear">
    /// The year of the era.
    /// </param>
    /// <param name="AMonth">
    /// The month of the year.
    /// </param>
    /// <returns>
    /// Rteurns <see langword="true"/> if at least one day within the specified
    /// month can be represented by the cotnrol, otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="IsYearInRange"/>
    /// <seealso cref="IsDateInRange"/>
    /// <seealso cref="DateMin"/>
    /// <seealso cref="DateMax"/>
    /// <seealso cref="ActualDateMin"/>
    /// <seealso cref="ActualDateMax"/>
    {$Endregion}
    Function IsMonthInRange(AEra, AYear, AMonth : Integer) : Boolean; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether a specified month of a specified year is in the supported
    /// and allowed range of the control.
    /// </summary>
    /// <param name="AYear">
    /// The year of the era.
    /// </param>
    /// <param name="AMonth">
    /// The month of the year.
    /// </param>
    /// <returns>
    /// Rteurns <see langword="true"/> if at least one day within the specified
    /// month can be represented by the cotnrol, otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="IsYearInRange"/>
    /// <seealso cref="IsDateInRange"/>
    /// <seealso cref="DateMin"/>
    /// <seealso cref="DateMax"/>
    /// <seealso cref="ActualDateMin"/>
    /// <seealso cref="ActualDateMax"/>
    {$Endregion}
    Function IsMonthInRange(AYear, AMonth : Integer) : Boolean; Overload; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether a specified date is in the supported and allowed range
    /// of the control.
    /// </summary>
    /// <param name="ADate">
    /// The <see cref="TDate"/> value to examine.
    /// </param>
    /// <returns>
    /// Rteurns <see langword="true"/> if the date can be represented by the cotnrol,
    /// otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="IsYearInRange"/>
    /// <seealso cref="IsMonthInRange"/>
    /// <seealso cref="DateMin"/>
    /// <seealso cref="DateMax"/>
    /// <seealso cref="ActualDateMin"/>
    /// <seealso cref="ActualDateMax"/>
    {$Endregion}
    Function IsDateInRange(Const ADate : TDate) : Boolean; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Confines a specified date to be in the supported and allowed range
    /// of the control.
    /// </summary>
    /// <param name="ADate">
    /// The <see cref="TDate"/> value to confine.
    /// </param>
    /// <returns>
    /// If the date is less than <see cref="ActualDateMin"/>, returns <see cref="ActualDateMin"/>.
    /// If the date is greater than <see cref="ActualDateMax"/>, returns <see cref="ActualDateMax"/>.
    /// If the date is between <see cref="ActualDateMax"/> and <see cref="ActualDateMax"/>, returns
    /// the date as is.
    /// </returns>
    /// <seealso cref="ActualDateMin"/>
    /// <seealso cref="ActualDateMax"/>
    {$Endregion}
    Function EnsureDateInRange(Const ADate : TDate) : TDate; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the <see cref="TCalendar"/> object that the control is using to
    /// get and display the input date.
    /// </summary>
    {$Endregion}
    Property Calendar : TCalendar Read GetCalendar;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the smallest date that is supported by the <see cref="Calendar"/> and
    /// is allowed by the control.
    /// </summary>
    /// <seealso cref="DateMin"/>
    /// <seealso cref="TCalendar.MinSupportedDateTime"/>
    /// <seealso cref="ActualDateMax"/>
    {$Endregion}
    Property ActualDateMin : TDate Read GetActualDateMin;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the largest date that is supported by the <see cref="Calendar"/> and
    /// is allowed by the control.
    /// </summary>
    /// <seealso cref="DateMax"/>
    /// <seealso cref="TCalendar.MaxSupportedDateTime"/>
    /// <seealso cref="ActualDateMin"/>
    {$Endregion}
    Property ActualDateMax : TDate Read GetActualDateMax;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets whether the calendar system used by the control is determined by the
    /// <see cref="Culture"/> property.
    /// </summary>
    /// <seealso cref="CultureCalendar"/>
    /// <seealso cref="Culture"/>
    {$Endregion}
    Property UsingCultureCalendar : Boolean Read GetUsingCultureCalendar;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets whether the way that the control renders digits is determined by the
    /// <see cref="Culture"/> property.
    /// </summary>
    /// <seealso cref="CultureDigits"/>
    /// <seealso cref="Culture"/>
    {$Endregion}
    Property UsingCultureDigits : Boolean Read GetUsingCultureDigits;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TIntlDatePicker is a control designed specifically for entering localized dates.
/// </summary>
/// <remarks>
/// Use TIntlDatePicker to enables users to eneter a date in a custom calendar system
/// and in a locale specific format.
///
/// TIntlDatePicker can use different calendar systems for getting the input  date.
/// The <see cref="CalendarType"/> property is the main property that specifies which
/// calendar system should be used by the cotnrol. If the <see cref="CalendarType"/>
/// property is not set, the <see cref="Culture"/> property can do this task. In addition,
/// the <see cref="Culture"/> property provides the locale specific settings of the control.
/// If none of these two properties are set, the <see cref="DefaultCalendar"/> global
/// variable determines the calendar system used by the control.
///
/// TIntlDatePicker can be linked to a <see cref="TLocalizer"/> component. In this case,
/// the linked <see cref="TLocalizer"/> component can provide both the locale specific
/// settings and the calendar system of the control.
///
/// TIntlDatePicker publishes many of the properties, events, and methods of
/// <see cref="TCustomIntlDatePicker"/>, but does not introduce any new behavior.
/// </remarks>
/// <group name="Components"/>
{$Endregion}
{$IFDEF COMPILER_XE2_UP}

  [ComponentPlatformsAttribute(pidWin32 Or pidWin64)]
  {$ENDIF}
  TIntlDatePicker = Class(TCustomIntlDatePicker)
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
    /// Gets or sets whether the check box next to the date is selected. When the
    /// check box is not checked, user cannot enter a date.
    /// </summary>
    {$Endregion}
    Property Checked;
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
    ///
    /// NOTE: If the <see cref="CalendarType"/> property is <see langword="nil"/>, depends
    /// on the values of <see cref="TLocalizer"/> and <see cref="CultureCalendar"/> properties,
    /// the Culture property may also determine the calendar system of the control.
    /// </summary>
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
    /// NOTE: Value of this property has no effect when the <see cref="CalendarType"/>
    /// property is not <see langword="nil"/>.
    /// </summary>
    /// <seealso cref="UsingCultureCalendar"/>
    /// <seealso cref="Culture"/>
    /// <seealso cref="Localizer"/>
    {$Endregion}
    Property CultureCalendar;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the way the control renders digits should be determined
    /// by the <see cref="Culture"/> or <see cref="Localizer"/> properties.</summary>
    /// <seealso cref="UsingCultureDigits"/>
    /// <seealso cref="Culture"/>
    /// <seealso cref="Localizer"/>
    {$Endregion}
    Property CultureDigits;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the current focused date.
    /// </summary>
    /// <exception cref="EDateTimeError">
    /// Occurs when the assigned date is not in the supported range of the calendar.
    /// </exception>
    /// <seealso cref="IsDateInRange"/>
    {$Endregion}
    Property Date;
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
    /// Occurs when either of <see cref="Date"/> or <see cref="Checked"/> properties change.</summary>
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
  RTLConsts, Math, Types, Variants, Themes, ComCtrls, i18nUnicode;

 Resourcestring
  SDateOutOfRangeError = 'The date must be between %s and %s';

 Type
   TControlHack = Class(TControl);

 { Helper Functions }

  Procedure SwapScreenByScroll(DC : HDC; Const Rect : TRect; OfsX, OfsY : Integer; OldBmp, NewBmp : TBitmap; RightToLeft : Boolean; Duration : Cardinal);
   Var
    Step, LastStep, Distance, x : Integer;
    StartTime                   : Cardinal;
   Begin
    StartTime := GetTickCount;
    Distance  := Rect.Right - Rect.Left;
    Step      := 0;
    Repeat
     LastStep := Step;
     Repeat
      Sleep(1);
      Step := MulDiv(Distance, GetTickCount - StartTime, Duration);
     Until Step <> LastStep;
     x := Min(Rect.Left + Step, Rect.Right);
     If RightToLeft Then
      Begin
       BitBlt(DC, Rect.Left, Rect.Top, x - Rect.Left, Rect.Bottom - Rect.Top,
       NewBmp.Canvas.Handle, Rect.Right - x - OfsX, Rect.Top - OfsY, SRCCOPY);
       BitBlt(DC, x, Rect.Top, Rect.Right - x, Rect.Bottom - Rect.Top,
       OldBmp.Canvas.Handle, Rect.Left - OfsX, Rect.Top - OfsY, SRCCOPY);
      End
     Else
      Begin
       BitBlt(DC, Rect.Left, Rect.Top, Rect.Right - x, Rect.Bottom - Rect.Top,
       OldBmp.Canvas.Handle, x - OfsX, Rect.Top - OfsY, SRCCOPY);
       BitBlt(DC, Rect.Right - x, Rect.Top, x - Rect.Left, Rect.Bottom - Rect.Top,
       NewBmp.Canvas.Handle, Rect.Left - OfsX, Rect.Top - OfsY, SRCCOPY);
      End;
    Until x = Rect.Right;
   End;

  Procedure SwapScreenByZoom(DC : HDC; Const Rect : TRect; OfsX, OfsY : Integer; OldBmp, NewBmp : TBitmap; Const OldRect, NewRect : TRect; Duration : Cardinal);
   Var
    Progress, LastProgress : Integer;
    StartTime              : Cardinal;
    r                      : TRect;
   Begin
    StartTime := GetTickCount;
    Progress  := 0;
    Repeat
     LastProgress := Progress;
     Repeat
      Sleep(1);
      Progress := MulDiv(200, GetTickCount - StartTime, Duration);
     Until Progress <> LastProgress;
     If Progress > 100 Then
      Progress := 100;
     r.Left    := OldRect.Left + MulDiv(Rect.Left - OldRect.Left, 100 - Progress, 100);
     r.Top     := OldRect.Top + MulDiv(Rect.Top - OldRect.Top, 100 - Progress, 100);
     r.Right   := OldRect.Right + MulDiv(Rect.Right - OldRect.Right, 100 - Progress, 100);
     r.Bottom  := OldRect.Bottom + MulDiv(Rect.Bottom - OldRect.Bottom, 100 - Progress, 100);
     StretchBlt(DC, Rect.Left, Rect.Top, Rect.Right - Rect.Left, Rect.Bottom - Rect.Top,
     OldBmp.Canvas.Handle, r.Left - OfsX, r.Top - OfsY, r.Right - r.Left, r.Bottom - r.Top, SRCCOPY);
    Until Progress = 100;
    StartTime := GetTickCount;
    Progress  := 0;
    Repeat
     LastProgress := Progress;
     Repeat
      Sleep(1);
      Progress := MulDiv(200, GetTickCount - StartTime, Duration);
     Until Progress <> LastProgress;
     If Progress > 100 Then
      Progress := 100;
     r.Left    := NewRect.Left + MulDiv(Rect.Left - NewRect.Left, Progress, 100);
     r.Top     := NewRect.Top + MulDiv(Rect.Top - NewRect.Top, Progress, 100);
     r.Right   := NewRect.Right + MulDiv(Rect.Right - NewRect.Right, Progress, 100);
     r.Bottom  := NewRect.Bottom + MulDiv(Rect.Bottom - NewRect.Bottom, Progress, 100);
     StretchBlt(DC, Rect.Left, Rect.Top, Rect.Right - Rect.Left, Rect.Bottom - Rect.Top,
     NewBmp.Canvas.Handle, r.Left - OfsX, r.Top - OfsY, r.Right - r.Left, r.Bottom - r.Top, SRCCOPY);
    Until Progress = 100;
   End;

 { TDateTimeList }

  Destructor TDateTimeList.Destroy;
   Begin
    Capacity := 0;
    Inherited Destroy;
   End;

  Function TDateTimeList.GetCapacity : Integer;
   Begin
    Result := Length(fList);
   End;

  Procedure TDateTimeList.SetCapacity(Value : Integer);
   Begin
    If Capacity <> Value Then
     Begin
      SetLength(fList, Value);
      If Capacity < Count Then
       Begin
        Changing;
        fCount := Capacity;
        Change;
       End;
     End;
   End;

  Function TDateTimeList.GetItems(Index : Integer) : TDate;
   Begin
    If (Index < 0) Or (Index >= Count) Then
     Raise EListError.CreateFmt(SListIndexError, [Index]);
    Result := fList[Index];
   End;

  Procedure TDateTimeList.Changing;
   Begin
    If (fUpdateCount = 0) And Assigned(OnChanging) Then
     OnChanging(Self);
   End;

  Procedure TDateTimeList.Change;
   Begin
    If (fUpdateCount = 0) And Assigned(OnChange) Then
     OnChange(Self);
   End;

  Procedure TDateTimeList.Assign(Source : TPersistent);
   Begin
    If Source Is TDateTimeList Then
     Begin
      Changing;
      fList  := Copy(TDateTimeList(Source).fList, 0, TDateTimeList(Source).fCount);
      fCount := TDateTimeList(Source).fCount;
      Change;
     End
    Else
     Inherited Assign(Source);
   End;

  Procedure TDateTimeList.BeginUpdate;
   Begin
    If fUpdateCount = 0 Then
     Changing;
    Inc(fUpdateCount);
   End;

  Procedure TDateTimeList.EndUpdate;
   Begin
    Dec(fUpdateCount);
    If fUpdateCount = 0 Then
     Change;
   End;

  Procedure TDateTimeList.Clear;
   Begin
    If Count <> 0 Then
     Begin
      Changing;
      fCount := 0;
      Change;
     End;
   End;

  Function TDateTimeList.Add(Const ADateTime : TDateTime) : Integer;
   Var
    Index : Integer;
   Begin
    If Not Find(ADateTime, Index) Then
     Begin
      Changing;
      If Capacity = Count Then
       Capacity := Count + 4;
      If Index <> Count Then
       Move(fList[Index], fList[Index + 1], (Count - Index) * SizeOf(TDateTime));
      fList[Index] := ADateTime;
      Inc(fCount);
      Change;
     End;
    Result := Index;
   End;

  Function TDateTimeList.Remove(Const ADateTime : TDateTime) : Integer;
   Var
    Index : Integer;
   Begin
    Result := -1;
    If Find(ADateTime, Index) Then
     Delete(Index);
   End;

  Procedure TDateTimeList.Delete(Index : Integer);
   Begin
    If (Index < 0) Or (Index >= Count) Then
     Raise EListError.CreateFmt(SListIndexError, [Index]);
    Changing;
    Dec(fCount);
    If Index <> Count Then
     Move(fList[Index + 1], fList[Index], (Count - Index) * SizeOf(TDateTime));
    Change;
   End;

  Function TDateTimeList.Exists(Const ADateTime : TDateTime) : Boolean;
   Var
    Index : Integer;
   Begin
    Result := Find(ADateTime, Index);
   End;

  Function TDateTimeList.IndexOf(Const ADateTime : TDateTime) : Integer;
   Begin
    If Not Find(ADateTime, Result) Then
     Result := -1;
   End;

  Function TDateTimeList.Find(Const ADateTime : TDateTime; Out Index : Integer) : Boolean;
   Var
    l, h, m : Integer;
    c       : Integer;
   Begin
    l := 0;
    h := Count - 1;
    While l <= h Do
     Begin
      m := (l + h) Shr 1;
      c := TCalendar.Compare(fList[m], ADateTime);
      If  c < 0 Then
       l := m + 1
      Else
       Begin
        h := m - 1;
        If c = 0 Then
         Begin
          Result := True;
          Index  := m;
          Exit;
         End;
       End;
     End;
    Index  := l;
    Result := False;
   End;

  Function TDateTimeList.First : TDateTime;
   Begin
    If Count <> 0 Then
     Result := Items[0]
    Else
     Result := TCalendar.NoDate;
   End;

  Function TDateTimeList.Last : TDateTime;
   Begin
    If Count <> 0 Then
     Result := Items[Count - 1]
    Else
     Result := TCalendar.NoDate;
   End;

 { TCustomIntlDateTimeLabel }

  Constructor TCustomIntlDateTimeLabel.Create(AOwner : TComponent);
   Begin
    Inherited Create(AOwner);
    ControlStyle       := ControlStyle - [csSetCaption];
    fCalendar          := DefaultCalendar.Clone;
    fCalendar.OnChange := CalendarChanged;
    fDateTime          := TCalendar.Today;
    ShowAccelChar      := False;
   End;

  Destructor TCustomIntlDateTimeLabel.Destroy;
   Begin
    Localizer := Nil;
    fCalendar.Free;
    Inherited Destroy;
   End;

  Procedure TCustomIntlDateTimeLabel.SetDateTime(Const Value : TDateTime);
   Begin
    If Not TCalendar.IsSame(DateTime, Value) Then
     Begin
      fDateTime := Value;
      AdjustBounds;
      Invalidate;
     End;
   End;

  Procedure TCustomIntlDateTimeLabel.SetDateTimeFormat(Const Value : String);
   Begin
    If DateTimeFormat <> Value Then
     Begin
      fDateTimeFormat := Value;
      AdjustBounds;
      Invalidate;
     End;
   End;

  Procedure TCustomIntlDateTimeLabel.SetCalendarType(Value : TCalendarClass);
   Begin
    If CalendarType <> Value Then
     Begin
      fCalendarType := Value;
      ValidateCalendar;
     End;
   End;

  Procedure TCustomIntlDateTimeLabel.SetCulture(Value : TCultureInfo);
   Begin
    If Culture <> Value Then
     Begin
      fCulture := Value;
      ValidateCalendar;
     End;
   End;

  Procedure TCustomIntlDateTimeLabel.SetCultureCalendar(Value : TLocalizerSwicth);
   Begin
    If CultureCalendar <> Value Then
     Begin
      fCultureCalendar := Value;
      If Assigned(Culture) Then
       ValidateCalendar;
     End;
   End;

  Procedure TCustomIntlDateTimeLabel.SetCultureDigits(Value : TLocalizerSwicth);
   Begin
    If CultureDigits <> Value Then
     Begin
      fCultureDigits := Value;
      If Assigned(Culture) Then
       Begin
        AdjustBounds;
        Invalidate;
       End;
     End;
   End;

  Procedure TCustomIntlDateTimeLabel.SetLocalizer(Value : TLocalizer);
   Begin
    If Localizer <> Value Then
     Begin
      If Assigned(Localizer) Then
       Begin
        Localizer.RemoveFreeNotification(Self);
        Localizer.UnregisterListener(Self);
       End;
      fLocalizer := Value;
      If Assigned(Localizer) Then
       Begin
        Localizer.FreeNotification(Self);
        Localizer.RegisterListener(Self);
       End;
      If Not(csDestroying In ComponentState) Then
       LocalizerNotify(Localizer, lnCultureChanged);
     End;
   End;

  Function TCustomIntlDateTimeLabel.GetUsingCultureCalendar : Boolean;
   Begin
    Result := (CultureCalendar <> lsNever) And Assigned(Culture) And Not Assigned(CalendarType);
    If Result And Assigned(Localizer) And (CultureCalendar = lsDefault) Then
     Result := (loUseNativeCalendar In Localizer.Options)
   End;

  Function TCustomIntlDateTimeLabel.GetUsingCultureDigits : Boolean;
   Begin
    Result := (CultureDigits <> lsNever) And Assigned(Culture) And Not Culture.IsUsingNominalDigits;
    If Result And Assigned(Localizer) And (CultureDigits = lsDefault) Then
     Result := (loUseNativeDigits In Localizer.Options)
   End;

  Function TCustomIntlDateTimeLabel.IsDateTimeStored : Boolean;
   Begin
    Result := Not TCalendar.IsToday(DateTime);
   End;

  Procedure TCustomIntlDateTimeLabel.CalendarChanged(Sender : TObject);
   Begin
    AdjustBounds;
    Invalidate;
   End;

  Procedure TCustomIntlDateTimeLabel.ReadCulture(Reader : TReader);
   Begin
    Culture := CultureOf(Reader.ReadString);
   End;

  Procedure TCustomIntlDateTimeLabel.WriteCulture(Writer : TWriter);
   Begin
    Writer.WriteString(Culture.Locale);
   End;

  Procedure TCustomIntlDateTimeLabel.ReadCalendarType(Reader : TReader);
   Begin
    CalendarType := CalendarTypes.ByName(Reader.ReadString);
   End;

  Procedure TCustomIntlDateTimeLabel.WriteCalendarType(Writer : TWriter);
   Begin
    Writer.WriteString(CalendarType.CalendarName);
   End;

  Procedure TCustomIntlDateTimeLabel.DefineProperties(Filer : TFiler);
   Begin
    Inherited DefineProperties(Filer);
    Filer.DefineProperty('CultureInfo', ReadCulture, WriteCulture,
    Not Assigned(Localizer) And Assigned(Culture));
    Filer.DefineProperty('CalendarClass', ReadCalendarType, WriteCalendarType,
    Assigned(CalendarType));
   End;

  Procedure TCustomIntlDateTimeLabel.Notification(AComponent : TComponent; Operation : TOperation);
   Begin
    Inherited Notification(AComponent, Operation);
    If (Operation = opRemove) And (AComponent = Localizer) Then
     Localizer := Nil;
   End;

  Procedure TCustomIntlDateTimeLabel.LocalizerNotify(Sender : TLocalizer; Reason : TLocalizerNotification);
   Begin
    Case Reason Of
     lnCultureChanged :
      If Assigned(Localizer) Then
       Culture := Localizer.Culture
      Else
       Culture := Nil;
     lnOptionsChanged :
      ValidateCalendar;
    End;
  End;

 Function TCustomIntlDateTimeLabel.GetLabelText : String;
  Begin
   Result := Calendar.Format(DateTimeFormat, DateTime);
   If Assigned(Culture) Then
    Result := Culture.FreezeDigits(Result, UsingCultureDigits);
  End;

 Function TCustomIntlDateTimeLabel.IsManagedByLocalizer : Boolean;
  Begin
   Result := Assigned(Localizer);
  End;

 Procedure TCustomIntlDateTimeLabel.ValidateCalendar;

   Procedure InitNewCalendar;
    Begin
     fCalendar.OnChange := CalendarChanged;
     CalendarChanged(Nil);
    End;
  Var
   Reference : TCalendar;

  Begin
   If Not Assigned(CalendarType) Then
    Begin
     If UsingCultureCalendar Then
      Reference := Culture.NativeCalendar
     Else
      Reference := DefaultCalendar;
     If Reference.ClassType <> Calendar.ClassType Then
      Begin
       FreeAndNil(fCalendar);
       fCalendar := Reference.Clone;
       InitNewCalendar;
      End
     Else
      fCalendar.Assign(Reference);
    End
   Else If CalendarType <> Calendar.ClassType Then
    Begin
     FreeAndNil(fCalendar);
     If Assigned(Culture) Then
      fCalendar := CalendarType.Create(Culture.Locale)
     Else
      fCalendar := CalendarType.Create(LOCALE_USER_DEFAULT);
     InitNewCalendar;
    End
   Else If Assigned(Culture) Then
    fCalendar.Settings.Prepare(Culture.Locale)
   Else
    fCalendar.Settings.Prepare(LOCALE_USER_DEFAULT);
  End;

{ TCustomIntlMonthCalendar }

 Constructor TCustomIntlMonthCalendar.Create(AOwner : TComponent);
  Begin
   Inherited Create(AOwner);
   ControlStyle              := ControlStyle + [csOpaque] - [csSetCaption];
   fCalendar                 := DefaultCalendar.Clone;
   fCalendar.OnChange        := CalendarChanged;
   fSelection                := TDateTimeList.Create;
   fFontHeader               := TFont.Create;
   fFontHeader.OnChange      := FontHeaderChanged;
   fFontFooter               := TFont.Create;
   fFontFooter.OnChange      := FontFooterChanged;
   fFontDayOfWeek            := TFont.Create;
   fFontDayOfWeek.OnChange   := FontDayOfWeekChanged;
   fFontWeekNumbers          := TFont.Create;
   fFontWeekNumbers.OnChange := FontWeekNumbersChanged;
   fDate                     := TCalendar.Today;
   fDateMin                  := TCalendar.NoDate;
   fDateMax                  := TCalendar.NoDate;
   fColorDivider             := clBtnFace;
   fColorToday               := clRed;
   fShowHeader               := True;
   fShowFooter               := True;
   fAnimate                  := True;
   fHintDate                 := Calendar.NoDate;
   fDraggingCell             := -1;
   fHotCell                  := -1;
   ParentColor               := False;
   Color                     := clWindow;
   BevelKind                 := bkTile;
   BorderWidth               := 2;
   TabStop                   := True;
   UpdateCalendar;
   Width  := 148;
   Height := 133;
  End;

 Destructor TCustomIntlMonthCalendar.Destroy;
  Begin
   Localizer := Nil;
   fSelection.Free;
   fFontHeader.Free;
   fFontFooter.Free;
   fFontDayOfWeek.Free;
   fFontWeekNumbers.Free;
   fCalendar.Free;
   If Assigned(fSavedScreen) Then
    fSavedScreen.Free;
   If fTheme <> 0 Then
    CloseThemeData(fTheme);
   Inherited Destroy;
  End;

 Procedure TCustomIntlMonthCalendar.SetDate(Const Value : TDate);
  Begin
   If (csDesigning In ComponentState) And Calendar.IsNoDate(Value) Then
    Begin
     Select(Calendar.Today);
     Exit;
    End;
   If Not IsDateInRange(Value) Then
    Begin
     Raise EDateTimeError.CreateResFmt(@SDateOutOfRangeError,
     [Calendar.Format('ddddd', ActualDateMin),
     Calendar.Format('ddddd', ActualDateMax)]);
    End;
   If csLoading In ComponentState Then
    Begin
     fDate            := Trunc(Value);
     fSelectionAnchor := fDate;
    End
   Else
    Select(Value);
  End;

 Procedure TCustomIntlMonthCalendar.SetDateMin(Const Value : TDate);
  Begin
   If Calendar.IsNoDate(Value) Then
    fDateMin := Calendar.NoDate
   Else
    Begin
     fDateMin := Trunc(Value);
     If Not Calendar.IsNoDate(DateMax) And
     (Calendar.CompareDate(DateMin, DateMax) > 0)
     Then
      fDateMin := fDateMax;
    End;
   UpdateMinMaxRanges;
  End;

 Procedure TCustomIntlMonthCalendar.SetDateMax(Const Value : TDate);
  Begin
   If Calendar.IsNoDate(Value) Then
    fDateMax := Calendar.NoDate
   Else
    Begin
     fDateMax := Trunc(Value);
     If Not Calendar.IsNoDate(DateMin) And
     (Calendar.CompareDate(DateMin, DateMax) > 0)
     Then
      fDateMax := fDateMin;
    End;
   UpdateMinMaxRanges;
  End;

 Procedure TCustomIntlMonthCalendar.SetCalendarType(Value : TCalendarClass);
  Begin
   If CalendarType <> Value Then
    Begin
     fCalendarType := Value;
     ValidateCalendar;
    End;
  End;

 Procedure TCustomIntlMonthCalendar.SetCulture(Value : TCultureInfo);
  Begin
   If Culture <> Value Then
    Begin
     fCulture := Value;
     ValidateCalendar;
    End;
  End;

 Procedure TCustomIntlMonthCalendar.SetCultureCalendar(Value : TLocalizerSwicth);
  Begin
   If CultureCalendar <> Value Then
    Begin
     fCultureCalendar := Value;
     If Assigned(Culture) Then
      ValidateCalendar;
    End;
  End;

 Procedure TCustomIntlMonthCalendar.SetCultureDigits(Value : TLocalizerSwicth);
  Begin
   If CultureDigits <> Value Then
    Begin
     fCultureDigits := Value;
     If Assigned(Culture) Then
      UpdateMetrics;
    End;
  End;

 Procedure TCustomIntlMonthCalendar.SetWeekNumbers(Value : Boolean);
  Begin
   If WeekNumbers <> Value Then
    Begin
     fWeekNumbers := Value;
     UpdateMetrics;
    End;
  End;

 Procedure TCustomIntlMonthCalendar.SetSelectionStyle(Value : TIntlCalSelectionStyle);
  Var
   OldStyle : TIntlCalSelectionStyle;
   TheDate  : TDate;
   i        : Integer;
  Begin
   If SelectionStyle <> Value Then
    Begin
     OldStyle        := SelectionStyle;
     fSelectionStyle := Value;
     If Not(csLoading In ComponentState) Then
      Begin
       Case OldStyle Of
        ssSingle :
         Begin
          If SelectionStyle = ssFree Then
           fSelection.Add(Date);
          fSelectionAnchor := Date;
         End;
        ssRange :
         Begin
          If SelectionStyle = ssFree Then
           Begin
            TheDate := Min(Date, fSelectionAnchor);
            For i   := 0 To Calendar.DaysBetween(Date, fSelectionAnchor) Do
             fSelection.Add(Calendar.NextDay(TheDate, i));
           End
          Else
           InvalidateDateRange(fSelectionAnchor, Date);
          fSelectionAnchor := Date;
         End;
        ssFree :
         Begin
          If (SelectionStyle <> ssRange) Or (fSelection.Count = 0) Then
           fSelectionAnchor := Date
          Else If fSelection.First = Date Then
           fSelectionAnchor := fSelection.Last
          Else If fSelection.Last = Date Then
           fSelectionAnchor := fSelection.First
          Else
           Begin
            fSelectionAnchor := fSelection.First;
            FocusDate(fSelection.Last);
           End;
          fSelection.Clear;
          InvalidateDateRange(fSelectionAnchor, Date);
         End;
       End;
      End
    End;
  End;

 Procedure TCustomIntlMonthCalendar.SetShowHeader(Value : Boolean);
  Begin
   If ShowHeader <> Value Then
    Begin
     fShowHeader := Value;
     UpdateMetrics;
    End;
  End;

 Procedure TCustomIntlMonthCalendar.SetShowFooter(Value : Boolean);
  Begin
   If ShowFooter <> Value Then
    Begin
     fShowFooter := Value;
     UpdateMetrics;
    End;
  End;

 Procedure TCustomIntlMonthCalendar.SetColorDivider(Value : TColor);
  Begin
   If ColorDivider <> Value Then
    Begin
     fColorDivider := Value;
     InvalidateSections([csDaysOfWeek, csWeekNumbers]);
    End;
  End;

 Procedure TCustomIntlMonthCalendar.SetColorToday(Value : TColor);
  Begin
   If ColorToday <> Value Then
    Begin
     fColorToday := Value;
     InvalidateDate(Calendar.Today);
     InvalidateSections([csFooter]);
    End;
  End;

 Procedure TCustomIntlMonthCalendar.SetFontHeader(Value : TFont);
  Begin
   fFontHeader.Assign(Value);
  End;

 Procedure TCustomIntlMonthCalendar.SetFontFooter(Value : TFont);
  Begin
   fFontFooter.Assign(Value);
  End;

 Procedure TCustomIntlMonthCalendar.SetFontDayOfWeek(Value : TFont);
  Begin
   fFontDayOfWeek.Assign(Value);
  End;

 Procedure TCustomIntlMonthCalendar.SetFontWeekNumbers(Value : TFont);
  Begin
   fFontWeekNumbers.Assign(Value);
  End;

 Procedure TCustomIntlMonthCalendar.SetCurrentView(Value : TIntlCalViewMode);
  Begin
   If CurrentView <> Value Then
    Begin
     If Not(csLoading In ComponentState) Then
      Begin
       fHintDate     := Calendar.NoDate;
       fDraggingCell := -1;
       fHotCell      := -1;
       fHotInfo      := chtNowhere;
       AnimateBegin;
       Try
        fCurrentView := Value;
        CalcMetrics(CurrentView, fMetrics);
        CalcMetricsSections(fMetrics);
        AnimatePlay;
       Finally
        AnimateEnd;
       End;
       DoPageChange;
       Invalidate;
      End
     Else
      fCurrentView := Value;
    End;
  End;

 Procedure TCustomIntlMonthCalendar.SetLocalizer(Value : TLocalizer);
  Begin
   If Localizer <> Value Then
    Begin
     If Assigned(Localizer) Then
      Begin
       Localizer.RemoveFreeNotification(Self);
       Localizer.UnregisterListener(Self);
      End;
     fLocalizer := Value;
     If Assigned(Localizer) Then
      Begin
       Localizer.FreeNotification(Self);
       Localizer.RegisterListener(Self);
      End;
     If Not(csDestroying In ComponentState) Then
      LocalizerNotify(Localizer, lnCultureChanged);
    End;
  End;

 Function TCustomIntlMonthCalendar.GetUsingCultureCalendar : Boolean;
  Begin
   Result := (CultureCalendar <> lsNever) And Assigned(Culture) And Not Assigned(CalendarType);
   If Result And Assigned(Localizer) And (CultureCalendar = lsDefault) Then
    Result := (loUseNativeCalendar In Localizer.Options)
  End;

 Function TCustomIntlMonthCalendar.GetUsingCultureDigits : Boolean;
  Begin
   Result := (CultureDigits <> lsNever) And Assigned(Culture) And Not Culture.IsUsingNominalDigits;
   If Result And Assigned(Localizer) And (CultureDigits = lsDefault) Then
    Result := (loUseNativeDigits In Localizer.Options)
  End;

 Procedure TCustomIntlMonthCalendar.NormalizeDigits(Var Str : String);
  Begin
   If Assigned(Culture) Then
    Str := Culture.FreezeDigits(Str, UsingCultureDigits);
  End;

 Function TCustomIntlMonthCalendar.GetDayName(DayOfWeek : TDayOfWeek; NameKind : TIntlCalNameKind) : String;
  Begin
   Case NameKind Of
    nkLong     : Result := Calendar.Settings.DayNames[DayOfWeek];
    nkShort    : Result := Calendar.Settings.ShortDayNames[DayOfWeek];
    nkShortest : Result := Calendar.Settings.ShortestDayNames[DayOfWeek];
   Else Result := '';
   End;
   NormalizeDigits(Result);
  End;

 Function TCustomIntlMonthCalendar.GetMonthName(Month : Integer; NameKind : TIntlCalNameKind) : String;
  Begin
   If NameKind = nkLong Then
    Result := Calendar.Settings.MonthNames[Month]
   Else
    Result := Calendar.Settings.ShortMonthNames[Month];
   NormalizeDigits(Result);
  End;

 Function TCustomIntlMonthCalendar.GetYearText(AYear : Integer) : String;
  Var
   YearStartDate : TDate;
  Begin
   YearStartDate := Calendar.StartOfYear(Era, AYear);
   Result        := Format(Calendar.Settings.YearFormat, YearStartDate);
  End;

 Function TCustomIntlMonthCalendar.GetDayText(ADay : Integer) : String;
  Begin
   Result := IntToStr(ADay);
   NormalizeDigits(Result);
  End;

 Function TCustomIntlMonthCalendar.GetWeekText(AWeek : Integer) : String;
  Begin
   Result := IntToStr(AWeek);
   NormalizeDigits(Result);
  End;

 Function TCustomIntlMonthCalendar.GetHeaderText(ViewMode : TIntlCalViewMode) : String;
  Begin
   If ViewMode = vmYear Then
    Begin
     If IsRightToLeft Then
      Result := GetYearText(LastYearOnPage) + ' - ' + GetYearText(FirstYearOnPage)
     Else
      Result := GetYearText(FirstYearOnPage) + ' - ' + GetYearText(LastYearOnPage);
    End
   Else
    Begin
     If ViewMode = vmMonth Then
      Result := Format(Calendar.Settings.YearFormat, Date)
     Else
      Result := Format(Calendar.Settings.YearMonthFormat, Date);
    End;
  End;

 Function TCustomIntlMonthCalendar.GetFooterText(LongFormat : Boolean) : String;
  Begin
   If LongFormat Then
    Result := Format(Calendar.Settings.LongDateFormat, Calendar.Today)
   Else
    Result := Format(Calendar.Settings.ShortDateFormat, Calendar.Today);
  End;

 Function TCustomIntlMonthCalendar.GetMonthLastDate : TDate;
  Begin
   Result := MonthFirstDate + DaysInMonth - 1;
  End;

 Function TCustomIntlMonthCalendar.GetFirstCellDate : TDate;
  Begin
   Result := MonthFirstDate - MonthStartCell;
  End;

 Function TCustomIntlMonthCalendar.GetLastCellDate : TDate;
  Begin
   Result := FirstCellDate + CellCount - 1;
  End;

 Function TCustomIntlMonthCalendar.GetLastCellYear : Integer;
  Begin
   Result := FirstCellYear + CellCount - 1;
  End;

 Function TCustomIntlMonthCalendar.GetFirstYearOnPage : Integer;
  Begin
   Result := FirstCellYear;
   While (Result < Year) And Not(IsYearOnPage(Result) And IsYearInRange(Era, Result)) Do
    Result := Calendar.OffsetYear(Era, Result, +1);
  End;

 Function TCustomIntlMonthCalendar.GetLastYearOnPage : Integer;
  Begin
   Result := LastCellYear;
   While (Result > Year) And Not(IsYearOnPage(Result) And IsYearInRange(Era, Result)) Do
    Result := Calendar.OffsetYear(Era, Result, -1);
  End;

 Function TCustomIntlMonthCalendar.GetColCount : Integer;
  Begin
   Result := fMetrics.ColCount;
  End;

 Function TCustomIntlMonthCalendar.GetRowCount : Integer;
  Begin
   Result := fMetrics.RowCount;
  End;

 Function TCustomIntlMonthCalendar.GetCellCount : Integer;
  Begin
   Result := RowCount * ColCount;
  End;

 Function TCustomIntlMonthCalendar.GetFocusedCell : Integer;
  Begin
   Case CurrentView Of
    vmDay   : Result := MonthStartCell + Day - 1;
    vmMonth : Result := Month - 1;
    vmYear  : Result := Year - FirstCellYear;
   Else Result := -1;
   End;
  End;

 Function TCustomIntlMonthCalendar.GetSelectionStart : TDate;
  Begin
   Case SelectionStyle Of
    ssSingle : Result := Date;
    ssRange  : Result := Min(Date, fSelectionAnchor);
   Else Result := fSelection.First;
   End;
  End;

 Function TCustomIntlMonthCalendar.GetSelectionEnd : TDate;
  Begin
   Case SelectionStyle Of
    ssSingle : Result := Date;
    ssRange  : Result := Max(Date, fSelectionAnchor);
   Else Result := fSelection.Last;
   End;
  End;

 Function TCustomIntlMonthCalendar.GetSelectionCount : Integer;
  Begin
   Case SelectionStyle Of
    ssSingle : Result := 1;
    ssRange  : Result := Calendar.DaysBetween(fSelectionAnchor, Date) + 1;
   Else Result := fSelection.Count;
   End;
  End;

 Function TCustomIntlMonthCalendar.GetSelection(Index : Integer) : TDate;
  Begin
   Case SelectionStyle Of
    ssSingle :
     Begin
      If Index <> 0 Then
       Raise EListError.CreateFmt(SListIndexError, [Index]);
      Result := Date;
     End;
    ssRange :
     Begin
      If (Index < 0) Or (Index > Calendar.DaysBetween(fSelectionAnchor, Date)) Then
       Raise EListError.CreateFmt(SListIndexError, [Index]);
      Result := Min(Date, fSelectionAnchor) + Index;
     End
   Else
     Result := fSelection[Index];
   End;
  End;

 Function TCustomIntlMonthCalendar.GetAdjacentPageDate(Backward : Boolean) : TDate;
  Var
   Dir : Integer;
  Begin
   If Backward Then
    Dir := -1
   Else
    Dir   := +1;
   Result := Date;
   Case CurrentView Of
    vmDay   : Calendar.IncMonth(Result, Dir);
    vmMonth : Calendar.IncYear(Result, Dir);
    vmYear  : Calendar.IncYear(Result, Dir * 10);
   End;
  End;

 Function TCustomIntlMonthCalendar.GetCalendarClientRect : TRect;
  Var
   TL, BR : Integer;
  Begin
   If fUpdateMetricsCount = 0 Then
    Begin
     Result := fMetrics.Bounds;
     Exit;
    End;
   Result := ClientRect;
   If BevelKind In [bkTile, bkSoft] Then
    Begin
     TL := 0;
     BR := 0;
     If (BevelInner = bvLowered) Or ((BevelInner = bvRaised) And (BevelKind = bkSoft)) Then
      Inc(TL);
     If BevelOuter In [bvLowered, bvRaised] Then
      Inc(BR);
     If beLeft In BevelEdges Then
      Inc(Result.Left, TL);
     If beTop In BevelEdges Then
      Inc(Result.Top, TL);
     If beRight In BevelEdges Then
      Dec(Result.Right, BR);
     If beBottom In BevelEdges Then
      Dec(Result.Bottom, BR);
    End;
  End;

 Function TCustomIntlMonthCalendar.GetSectionRect(Section : TIntlCalSection) : TRect;
  Begin
   Result := fMetrics.Sections[Section];
  End;

 Function TCustomIntlMonthCalendar.GetSectionWidth(Section : TIntlCalSection) : Integer;
  Begin
   With fMetrics.Sections[Section] Do
    Result := Right - Left;
  End;

 Function TCustomIntlMonthCalendar.GetSectionHeight(Section : TIntlCalSection) : Integer;
  Begin
   With fMetrics.Sections[Section] Do
    Result := Bottom - Top;
  End;

 Function TCustomIntlMonthCalendar.GetCellRect(Row, Col : Integer) : TRect;
  Begin
   If (Row < 0) And (Col < 0) Then
    Result := fMetrics.Sections[csWeekSpace]
   Else If Row < 0 Then
    Begin
     Result := fMetrics.Sections[csDaysOfWeek];
     Dec(Result.Bottom, 2);
    End
   Else If Col < 0 Then
    Begin
     Result := fMetrics.Sections[csWeekNumbers];
     If IsRightToLeft Then
      Inc(Result.Left, 2)
     Else
      Dec(Result.Right, 2);
    End
   Else
    Result := fMetrics.Sections[csYMD];
   If Row >= 0 Then
    Begin
     Inc(Result.Top, Row * fMetrics.RowHeight + Min(Row, fMetrics.StretchedRows));
     Result.Bottom := Result.Top + fMetrics.RowHeight;
     If Row < fMetrics.StretchedRows Then
      Inc(Result.Bottom);
    End;
   If Col >= 0 Then
    Begin
     If IsRightToLeft And (CurrentView In [vmDay, vmMonth]) Then
      Begin
       Dec(Result.Right, Col * fMetrics.ColWidth + Min(Col, fMetrics.StretchedCols));
       Result.Left := Result.Right - fMetrics.ColWidth;
       If Col < fMetrics.StretchedCols Then
        Dec(Result.Left);
      End
     Else
      Begin
       Inc(Result.Left, Col * fMetrics.ColWidth + Min(Col, fMetrics.StretchedCols));
       Result.Right := Result.Left + fMetrics.ColWidth;
       If Col < fMetrics.StretchedCols Then
        Inc(Result.Right);
      End;
    End;
  End;

 Function TCustomIntlMonthCalendar.GetCellRect(Index : Integer) : TRect;
  Begin
   Result := GetCellRect(Index Div ColCount, Index Mod ColCount);
  End;

 Function TCustomIntlMonthCalendar.GetRowAt(y : Integer) : Integer;
  Var
   d : Integer;
  Begin
   Dec(y, fMetrics.Sections[csYMD].Top);
   d := (fMetrics.RowHeight + 1) * fMetrics.StretchedRows;
   If y < d Then
    Result := y Div (fMetrics.RowHeight + 1)
   Else
    Result := fMetrics.StretchedRows + (y - d) Div fMetrics.RowHeight;
  End;

 Function TCustomIntlMonthCalendar.GetColAt(x : Integer) : Integer;
  Var
   d : Integer;
  Begin
   Dec(x, fMetrics.Sections[csYMD].Left);
   If IsRightToLeft And (CurrentView In [vmDay, vmMonth]) Then
    x := (fMetrics.Sections[csYMD].Right - fMetrics.Sections[csYMD].Left) - x - 1;
   d  := (fMetrics.ColWidth + 1) * fMetrics.StretchedCols;
   If x < d Then
    Result := x Div (fMetrics.ColWidth + 1)
   Else
    Result := fMetrics.StretchedCols + (x - d) Div fMetrics.ColWidth;
  End;

 Function TCustomIntlMonthCalendar.GetPreferredClientSize(Out AWidth, AHeight : Integer) : Boolean;
  Var
   Metrics : TIntlCalMetrics;
   Mode    : TIntlCalViewMode;
  Begin
   If Not fPrefferedSizeReady Then
    Begin
     fPrefferedSizeReady    := True;
     fPrefferedSize.cx      := fMetrics.PrefferedWidth;
     fPrefferedSize.cy      := fMetrics.PrefferedHeight;
     fPrefferedSizeSmallest := (fMetrics.NameKind = nkShortest);
     For Mode               := Low(TIntlCalViewMode) To High(TIntlCalViewMode) Do
      Begin
       CalcMetrics(Mode, Metrics);
       If fPrefferedSize.cx < Metrics.PrefferedWidth Then
        fPrefferedSize.cx := Metrics.PrefferedWidth;
       If fPrefferedSize.cy < Metrics.PrefferedHeight Then
        fPrefferedSize.cy := Metrics.PrefferedHeight;
       If Mode = vmDay Then
        fPrefferedSizeSmallest := (Metrics.NameKind = nkShortest);
      End;
    End;
   AWidth  := fPrefferedSize.cx;
   AHeight := fPrefferedSize.cy;
   Result  := fPrefferedSizeSmallest;
  End;

 Function TCustomIntlMonthCalendar.GetPreferredControlSize(Out AWidth, AHeight : Integer) : Boolean;
  Var
   EdgeSize : Integer;
  Begin
   Result := GetPreferredClientSize(AWidth, AHeight);
   Inc(AWidth, 2 * BorderWidth);
   Inc(AHeight, 2 * BorderWidth);
   If BevelKind <> bkNone Then
    Begin
     EdgeSize := 0;
     If BevelInner <> bvNone Then
      Inc(EdgeSize, BevelWidth);
     If BevelOuter <> bvNone Then
      Inc(EdgeSize, BevelWidth);
     If beLeft In BevelEdges Then
      Inc(AWidth, EdgeSize);
     If beRight In BevelEdges Then
      Inc(AWidth, EdgeSize);
     If beTop In BevelEdges Then
      Inc(AHeight, EdgeSize);
     If beBottom In BevelEdges Then
      Inc(AHeight, EdgeSize);
    End;
  End;

 Function TCustomIntlMonthCalendar.GetHitTestInfoAt(x, y : Integer; Out Cell : Integer) : TIntlCalHitTest;
  Var
   Pt : TPoint;
  Begin
   Pt.x   := x;
   Pt.y   := y;
   Cell   := -1;
   Result := chtNowhere;
   If PtInRect(fMetrics.Bounds, Pt) Then
    Begin
     If PtInRect(fMetrics.Sections[csHeader], Pt) Then
      Begin
       If PtInRect(fMetrics.Sections[csHeaderText], Pt) Then
        Result := chtHeaderText
       Else If PtInRect(fMetrics.Sections[csArrowLeft], Pt) Then
        Result := chtArrowLeft
       Else If PtInRect(fMetrics.Sections[csArrowRight], Pt) Then
        Result := chtArrowRight;
      End
     Else If PtInRect(fMetrics.Sections[csFooter], Pt) Then
      Result := chtFooter
     Else If (CurrentView = vmDay) And PtInRect(fMetrics.Sections[csDaysOfWeek], Pt) Then
      Result := chtDayOfWeek
     Else If (CurrentView = vmDay) And WeekNumbers And PtInRect(fMetrics.Sections[csWeekNumbers], Pt) Then
      Result := chtWeekNumber
     Else If PtInRect(fMetrics.Sections[csYMD], Pt) Then
      Begin
       Cell := GetRowAt(y) * fMetrics.ColCount + GetColAt(x);
       Case CurrentView Of
        vmDay   : Result := chtDay;
        vmMonth : Result := chtMonth;
        vmYear  : Result := chtYear;
       End;
      End;
    End
   Else
  End;

 Function TCustomIntlMonthCalendar.GetTheme : HTHEME;
  Var
   ListView : TListView;
  Begin
   If fTheme = 0 Then
    Begin
     ListView := TListView.Create(Nil);
     Try
      ListView.Visible      := False;
      ListView.ParentWindow := Handle;
      fTheme                := OpenThemeData(ListView.Handle, 'listview');
     Finally
      ListView.Free;
     End;
    End;
   Result := fTheme;
  End;

 Function TCustomIntlMonthCalendar.IsDateStored : Boolean;
  Begin
   Result := Not Calendar.IsToday(Date);
  End;

 Function TCustomIntlMonthCalendar.IsDateMinStored : Boolean;
  Begin
   Result := Not Calendar.IsNoDate(DateMin);
  End;

 Function TCustomIntlMonthCalendar.IsDateMaxStored : Boolean;
  Begin
   Result := Not Calendar.IsNoDate(DateMax);
  End;

 Function TCustomIntlMonthCalendar.IsManagedByLocalizer : Boolean;
  Begin
   Result := Assigned(Localizer);
  End;

 Procedure TCustomIntlMonthCalendar.WMEraseBkgnd(Var Message : TWMEraseBkgnd);
  Begin
   Message.Result := 1;
  End;

 Procedure TCustomIntlMonthCalendar.WMGetDlgCode(Var Message : TWMGetDlgCode);
  Begin
   Message.Result := DLGC_WANTARROWS;
  End;

 Procedure TCustomIntlMonthCalendar.WMMouseActivate(Var Message : TWMMouseActivate);
  Begin
   Inherited;
   If CanFocus Then
    SetFocus;
  End;

 Procedure TCustomIntlMonthCalendar.WMTimer(Var Message : TWMTimer);
  Var
   TheDate : TDate;
  Begin
   If NavigationTimer = AutoNavTimerForward Then
    TheDate := GetAdjacentPageDate(False)
   Else If NavigationTimer = AutoNavTimerBackward Then
    TheDate := GetAdjacentPageDate(True)
   Else
    Begin
     Inherited;
     Exit;
    End;
   If IsDateInRange(TheDate) Then
    SelectDate(TheDate);
  End;

 Procedure TCustomIntlMonthCalendar.CMMouseLeave(Var Message : TMessage);
  Begin
   Inherited;
   InvalidateHotLight;
   fHotCell := -1;
   fHotInfo := chtNowhere;
  End;

 Procedure TCustomIntlMonthCalendar.CMHintShow(Var Message : TCMHintShow);
  Var
   TheDate : TDate;
   TheCell : Integer;
  Begin
   TheCell := -1;
   With Message.HintInfo^Do
    Begin
     If (GetHitTestInfoAt(CursorPos.x, CursorPos.y, TheCell) = chtDay) And GetDateAtCell(TheCell, TheDate) Then
      Begin
       If TheDate <> fHintDate Then
        Begin
         fHintDate := TheDate;
         DoDateHint(TheDate, HintStr);
        End;
      End
     Else
      Begin
       fHintDate := Calendar.NoDate;
       Inherited;
      End;
     CursorRect := GetCellRect(TheCell);
    End;
  End;

 Procedure TCustomIntlMonthCalendar.CMFontChanged(Var Message : TMessage);
  Begin
   Inherited;
   Inc(fUpdateMetricsCount);
   Try
    If Not fSaveFontHeader Then
     FontHeader.Assign(Font);
    If Not fSaveFontFooter Then
     FontFooter.Assign(Font);
    If Not fSaveFontDayOfWeek Then
     FontDayOfWeek.Assign(Font);
    If Not fSaveFontWeekNumbers Then
     FontWeekNumbers.Assign(Font);
   Finally
    Dec(fUpdateMetricsCount);
   End;
   UpdateMetrics;
  End;

 Procedure TCustomIntlMonthCalendar.DoDateChange;
  Begin
   If Assigned(OnDateChange) Then
    OnDateChange(Self);
  End;

 Procedure TCustomIntlMonthCalendar.DoPageChange;
  Begin
   If Assigned(OnPageChange) Then
    OnPageChange(Self);
  End;

 Procedure TCustomIntlMonthCalendar.DoCalendarChange;
  Begin
   If Assigned(OnCalendarChange) Then
    OnCalendarChange(Self);
  End;

 Procedure TCustomIntlMonthCalendar.DoSelectionChange;
  Begin
   If Assigned(OnSelectionChange) Then
    OnSelectionChange(Self);
  End;

 Procedure TCustomIntlMonthCalendar.DoDateHint(Const ADate : TDate; Var HintStr : String);
  Begin
   HintStr := Hint;
   If Assigned(OnDateHint) Then
    OnDateHint(Self, ADate, HintStr);
  End;

 Function TCustomIntlMonthCalendar.DoDateSelectable(Const ADate : TDate) : Boolean;
  Begin
   Result := True;
   If Assigned(OnDateSelectable) Then
    OnDateSelectable(Self, ADate, Result);
  End;

 Function TCustomIntlMonthCalendar.DoCustomDrawDayOfWeek(Canvas : TCanvas; Const ARect : TRect; State : TIntlCalDrawStates; ADayOfWeek : TDayOfWeek) : Boolean;
  Begin
   Result := True;
   If Assigned(OnCustomDrawDayOfWeek) Then
    OnCustomDrawDayOfWeek(Self, Canvas, ARect, State, ADayOfWeek, Result);
  End;

 Function TCustomIntlMonthCalendar.DoCustomDrawWeekNumber(Canvas : TCanvas; Const ARect : TRect; State : TIntlCalDrawStates; AWeek : Integer) : Boolean;
  Begin
   Result := True;
   If Assigned(OnCustomDrawWeekNumber) Then
    OnCustomDrawWeekNumber(Self, Canvas, ARect, State, AWeek, Result);
  End;

 Function TCustomIntlMonthCalendar.DoCustomDrawDay(Canvas : TCanvas; Const ARect : TRect; State : TIntlCalDrawStates; Const ADate : TDate; ADay : Integer) : Boolean;
  Begin
   Result := True;
   If Assigned(OnCustomDrawDay) Then
    OnCustomDrawDay(Self, Canvas, ARect, State, ADate, ADay, Result);
  End;

 Function TCustomIntlMonthCalendar.DoCustomDrawMonth(Canvas : TCanvas; Const ARect : TRect; State : TIntlCalDrawStates; AMonth : Integer) : Boolean;
  Begin
   Result := True;
   If Assigned(OnCustomDrawMonth) Then
    OnCustomDrawMonth(Self, Canvas, ARect, State, AMonth, Result);
  End;

 Function TCustomIntlMonthCalendar.DoCustomDrawYear(Canvas : TCanvas; Const ARect : TRect; State : TIntlCalDrawStates; AYear : Integer) : Boolean;
  Begin
   Result := True;
   If Assigned(OnCustomDrawYear) Then
    OnCustomDrawYear(Self, Canvas, ARect, State, AYear, Result);
  End;

 Function TCustomIntlMonthCalendar.DoCustomDrawHeaderText(Canvas : TCanvas; Const ARect : TRect; State : TIntlCalDrawStates; Const AText : String) : Boolean;
  Begin
   Result := True;
   If Assigned(OnCustomDrawHeaderText) Then
    OnCustomDrawHeaderText(Self, Canvas, ARect, State, AText, Result);
  End;

 Function TCustomIntlMonthCalendar.DoCustomDrawFooterText(Canvas : TCanvas; Const ARect : TRect; State : TIntlCalDrawStates; Const AText : String) : Boolean;
  Begin
   Result := True;
   If Assigned(OnCustomDrawFooterText) Then
    OnCustomDrawFooterText(Self, Canvas, ARect, State, AText, Result);
  End;

 Procedure TCustomIntlMonthCalendar.LocalizerNotify(Sender : TLocalizer; Reason : TLocalizerNotification);
  Begin
   Case Reason Of
    lnCultureChanged :
     If Assigned(Localizer) Then
      Culture := Localizer.Culture
     Else
      Culture := Nil;
    lnOptionsChanged :
     ValidateCalendar;
   End;
  End;

 Procedure TCustomIntlMonthCalendar.FontHeaderChanged(Sender : TObject);
  Begin
   fSaveFontHeader := (FontHeader.Handle <> Font.Handle);
   UpdateMetrics;
  End;

 Procedure TCustomIntlMonthCalendar.FontFooterChanged(Sender : TObject);
  Begin
   fSaveFontFooter := (FontFooter.Handle <> Font.Handle);
   UpdateMetrics;
  End;

 Procedure TCustomIntlMonthCalendar.FontDayOfWeekChanged(Sender : TObject);
  Begin
   fSaveFontDayOfWeek := (FontDayOfWeek.Handle <> Font.Handle);
   UpdateMetrics;
  End;

 Procedure TCustomIntlMonthCalendar.FontWeekNumbersChanged(Sender : TObject);
  Begin
   fSaveFontWeekNumbers := (FontWeekNumbers.Handle <> Font.Handle);
   If WeekNumbers Then
    UpdateMetrics;
  End;

 Procedure TCustomIntlMonthCalendar.CalendarChanged(Sender : TObject);
  Begin
   UpdateCalendar;
   DoCalendarChange;
  End;

 Procedure TCustomIntlMonthCalendar.ReadCulture(Reader : TReader);
  Begin
   Culture := CultureOf(Reader.ReadString);
  End;

 Procedure TCustomIntlMonthCalendar.WriteCulture(Writer : TWriter);
  Begin
   Writer.WriteString(Culture.Locale);
  End;

 Procedure TCustomIntlMonthCalendar.ReadCalendarType(Reader : TReader);
  Begin
   CalendarType := CalendarTypes.ByName(Reader.ReadString);
  End;

 Procedure TCustomIntlMonthCalendar.WriteCalendarType(Writer : TWriter);
  Begin
   Writer.WriteString(CalendarType.CalendarName);
  End;

 Procedure TCustomIntlMonthCalendar.DefineProperties(Filer : TFiler);
  Begin
   Inherited DefineProperties(Filer);
   Filer.DefineProperty('CultureInfo', ReadCulture, WriteCulture,
   Not Assigned(Localizer) And Assigned(Culture));
   Filer.DefineProperty('CalendarClass', ReadCalendarType, WriteCalendarType,
   Assigned(CalendarType));
  End;

 Procedure TCustomIntlMonthCalendar.Notification(AComponent : TComponent; Operation : TOperation);
  Begin
   Inherited Notification(AComponent, Operation);
   If (Operation = opRemove) And (AComponent = Localizer) Then
    Localizer := Nil;
  End;

 Procedure TCustomIntlMonthCalendar.Resize;
  Begin
   Inherited Resize;
   UpdateMetrics;
  End;

 Procedure TCustomIntlMonthCalendar.Paint;
  Var
   Rect : TRect;
  Begin
   DrawCalendar(Canvas);
   Rect := ClientRect;
   If Not EqualRect(fMetrics.Bounds, Rect) Then
    Begin
     With fMetrics.Bounds Do
      ExcludeClipRect(Canvas.Handle, Left, Top, Right, Bottom);
     Canvas.Brush.Color := Color;
     Canvas.FillRect(Rect);
    End;
  End;

 Procedure TCustomIntlMonthCalendar.Loaded;
  Begin
   Inherited Loaded;
   If (Assigned(CalendarType) Or Assigned(Culture)) Or
   (Assigned(Localizer) And Assigned(Localizer.Culture))
   Then
    ValidateCalendar
   Else
    Begin
     UpdateCalendar;
     DoCalendarChange;
    End;
   DoPageChange;
   DoDateChange;
   DoSelectionChange;
  End;

 Function TCustomIntlMonthCalendar.CanAutoSize(Var NewWidth, NewHeight : Integer) : Boolean;
  Begin
   Result := True;
   If AutoSize And Not(csLoading In ComponentState) Then
    GetPreferredControlSize(NewWidth, NewHeight);
  End;

 Procedure TCustomIntlMonthCalendar.MouseDown(Button : TMouseButton; Shift : TShiftState; x, y : Integer);
  Var
   TheDate                   : TDate;
   TheYear, TheMonth, TheDay : Integer;
   TheCell                   : Integer;
  Begin
   fDraggingCell := -1;
   If (Button = mbLeft) And Not(ssDouble In Shift) Then
    Begin
     Case GetHitTestInfoAt(x, y, TheCell) Of
      chtArrowLeft :
       Begin
        TheDate := GetAdjacentPageDate(True);
        If IsDateInRange(TheDate) Then
         Begin
          fNavigationTimer := SetTimer(Handle, AutoNavTimerBackward, AutoNavInterval, Nil);
          SelectDate(TheDate);
         End;
       End;
      chtArrowRight :
       Begin
        TheDate := GetAdjacentPageDate(False);
        If IsDateInRange(TheDate) Then
         Begin
          fNavigationTimer := SetTimer(Handle, AutoNavTimerForward, AutoNavInterval, Nil);
          SelectDate(TheDate);
         End;
       End;
      chtHeaderText :
       Case CurrentView Of
        vmDay   : CurrentView := vmMonth;
        vmMonth : CurrentView := vmYear;
       End;
      chtFooter :
       Begin
        CurrentView := vmDay;
        Select(Calendar.Today);
        InvalidateSections([csFooter]);
       End;
      chtDay :
       If GetDateAtCell(TheCell, TheDate) Then
        Begin
         SelectDate(TheDate, Shift);
         fDraggingCell := TheCell;
        End;
      chtMonth :
       If GetMonthAtCell(TheCell, TheMonth) Then
        Begin
         TheDay := Min(Day, Calendar.DaysInMonth(Era, Year, TheMonth));
         Select(Calendar.EncodeDate(Era, Year, TheMonth, TheDay));
         fDraggingCell := TheCell;
        End;
      chtYear :
       If GetYearAtCell(TheCell, TheYear) Then
        Begin
         fDraggingOffPage := Not IsYearOnPage(TheYear);
         TheMonth         := Min(Month, Calendar.MonthsInYear(Era, TheYear));
         TheDay           := Min(Day, Calendar.DaysInMonth(Era, TheYear, TheMonth));
         Select(Calendar.EncodeDate(Era, TheYear, TheMonth, TheDay));
         fDraggingCell := TheCell;
        End;
     End;
     fDraggingShiftState := Shift + [ssShift];
    End;
   Inherited MouseDown(Button, Shift, x, y);
  End;

 Procedure TCustomIntlMonthCalendar.MouseMove(Shift : TShiftState; x, y : Integer);
  Var
   TheDate                   : TDate;
   TheYear, TheMonth, TheDay : Integer;
   TheCell                   : Integer;
   TheHitTest                : TIntlCalHitTest;
  Begin
   If NavigationTimer <> 0 Then
    Exit;
   TheHitTest := GetHitTestInfoAt(x, y, TheCell);
   If (TheHitTest <> HotInfo) Or (TheCell <> HotCell) Then
    Begin
     InvalidateHotLight;
     fHotInfo := TheHitTest;
     fHotCell := TheCell;
     InvalidateHotLight;
    End;
   If (DraggingCell >= 0) And (DraggingCell <> TheCell) And (TheCell >= 0) Then
    Begin
     Case HotInfo Of
      chtDay :
       If GetDateAtCell(TheCell, TheDate) Then
        Begin
         fDraggingCell := TheCell;
         SelectDate(TheDate, fDraggingShiftState);
        End;
      chtMonth :
       If GetMonthAtCell(TheCell, TheMonth) Then
        Begin
         fDraggingCell := TheCell;
         TheDay        := Min(Day, Calendar.DaysInMonth(Era, Year, TheMonth));
         Select(Calendar.EncodeDate(Era, Year, TheMonth, TheDay));
        End;
      chtYear :
       If GetYearAtCell(TheCell, TheYear) Then
        Begin
         fDraggingCell    := TheCell;
         fDraggingOffPage := Not IsYearOnPage(TheYear);
         TheMonth         := Min(Month, Calendar.MonthsInYear(Era, TheYear));
         TheDay           := Min(Day, Calendar.DaysInMonth(Era, TheYear, TheMonth));
         Select(Calendar.EncodeDate(Era, TheYear, TheMonth, TheDay));
        End;
     End;
    End;
   Inherited MouseMove(Shift, x, y);
  End;

 Procedure TCustomIntlMonthCalendar.MouseUp(Button : TMouseButton; Shift : TShiftState; x, y : Integer);
  Var
   TheMonth, TheYear : Integer;
  Begin
   If NavigationTimer <> 0 Then
    Begin
     KillTimer(Handle, NavigationTimer);
     fNavigationTimer := 0;
     InvalidateHotLight;
    End;
   If DraggingCell >= 0 Then
    Begin
     fDraggingCell := -1;
     If (Button = mbLeft) And (HotCell >= 0) Then
      Case HotInfo Of
       chtMonth :
        If GetMonthAtCell(HotCell, TheMonth) Then
         CurrentView := vmDay;
       chtYear :
        If Not DraggingOffPage And GetYearAtCell(HotCell, TheYear) Then
         CurrentView := vmMonth;
      End;
    End;
   Inherited MouseUp(Button, Shift, x, y);
  End;

 Function TCustomIntlMonthCalendar.DoMouseWheelDown(Shift : TShiftState; MousePos : TPoint) : Boolean;
  Begin
   Result := Inherited DoMouseWheelDown(Shift, MousePos);
   If Not Result Then
    Begin
     Case CurrentView Of
      vmDay   : Select(Calendar.NextDay(Date), Shift);
      vmMonth : Select(Calendar.NextMonth(Date));
      vmYear  : Select(Calendar.NextYear(Date));
     End;
     Result := True;
    End;
  End;

 Function TCustomIntlMonthCalendar.DoMouseWheelUp(Shift : TShiftState; MousePos : TPoint) : Boolean;
  Begin
   Result := Inherited DoMouseWheelUp(Shift, MousePos);
   If Not Result Then
    Begin
     Case CurrentView Of
      vmDay   : Select(Calendar.PrevDay(Date), Shift);
      vmMonth : Select(Calendar.PrevMonth(Date));
      vmYear  : Select(Calendar.prevYear(Date));
     End;
     Result := True;
    End;
  End;

 Procedure TCustomIntlMonthCalendar.KeyDown(Var Key : Word; Shift : TShiftState);
  Begin
   Inherited KeyDown(Key, Shift);
   If (SelectionStyle <> ssFree) Or (ssShift In Shift) Or Not(ssCtrl In Shift) Then
    Include(Shift, ssLeft);
   Case Key Of
    VK_RIGHT :
     Begin
      Case CurrentView Of
       vmDay :
        If IsRightToLeft Then
         SelectDate(Calendar.PrevDay(Date), Shift)
        Else
         SelectDate(Calendar.NextDay(Date), Shift);
       vmMonth :
        If IsRightToLeft Then
         Select(Calendar.PrevMonth(Date))
        Else
         Select(Calendar.NextMonth(Date));
       vmYear :
        Select(Calendar.NextYear(Date));
      End;
      Key := 0;
     End;
    VK_LEFT :
     Begin
      Case CurrentView Of
       vmDay :
        If IsRightToLeft Then
         SelectDate(Calendar.NextDay(Date), Shift)
        Else
         SelectDate(Calendar.PrevDay(Date), Shift);
       vmMonth :
        If IsRightToLeft Then
         Select(Calendar.NextMonth(Date))
        Else
         Select(Calendar.PrevMonth(Date));
       vmYear :
        Select(Calendar.prevYear(Date));
      End;
      Key := 0;
     End;
    VK_DOWN :
     Begin
      Case CurrentView Of
       vmDay   : SelectDate(Calendar.NextDay(Date, ColCount), Shift);
       vmMonth : Select(Calendar.NextMonth(Date, ColCount));
       vmYear  : Select(Calendar.NextYear(Date, ColCount));
      End;
      Key := 0;
     End;
    VK_UP :
     Begin
      Case CurrentView Of
       vmDay   : SelectDate(Calendar.PrevDay(Date, ColCount), Shift);
       vmMonth : Select(Calendar.PrevMonth(Date, ColCount));
       vmYear  : Select(Calendar.prevYear(Date, ColCount));
      End;
      Key := 0;
     End;
    VK_NEXT :
     Begin
      Case CurrentView Of
       vmDay   : SelectDate(Calendar.NextMonth(Date), Shift);
       vmMonth : Select(Calendar.NextYear(Date));
       vmYear  : Select(Calendar.NextYear(Date, 10));
      End;
      Key := 0;
     End;
    VK_PRIOR :
     Begin
      Case CurrentView Of
       vmDay   : SelectDate(Calendar.PrevMonth(Date), Shift);
       vmMonth : Select(Calendar.prevYear(Date));
       vmYear  : Select(Calendar.prevYear(Date, 10));
      End;
      Key := 0;
     End;
    VK_HOME :
     Begin
      Case CurrentView Of
       vmDay   : SelectDate(MonthFirstDate, Shift);
       vmMonth : Select(Calendar.StartOfYear(Date));
       vmYear  : Select(Calendar.StartOfYear(Era, FirstYearOnPage));
      End;
      Key := 0;
     End;
    VK_END :
     Begin
      Case CurrentView Of
       vmDay   : SelectDate(MonthLastDate, Shift);
       vmMonth : Select(Calendar.EndOfYear(Date));
       vmYear  : Select(Calendar.EndOfYear(Era, LastYearOnPage));
      End;
      Key := 0;
     End;
    VK_SPACE :
     Begin
      If CurrentView = vmDay Then
       SelectDate(Date, [ssLeft, ssCtrl])
      Else If CurrentView = vmYear Then
       CurrentView := vmMonth
      Else
       CurrentView := vmDay;
      Key          := 0;
     End;
    VK_BACK :
     Begin
      If CurrentView = vmDay Then
       CurrentView := vmMonth
      Else If CurrentView = vmMonth Then
       CurrentView := vmYear;
      Key          := 0;
     End;
   End;
  End;

 Procedure TCustomIntlMonthCalendar.DoEnter;
  Begin
   Inherited DoEnter;
   InvalidateSelection;
  End;

 Procedure TCustomIntlMonthCalendar.DoExit;
  Begin
   Inherited DoExit;
   InvalidateSelection;
  End;

 Function TCustomIntlMonthCalendar.IsThemed : Boolean;
  Begin
   Result := (Win32MajorVersion > 5) And ThemeControl(Self) And (Theme <> 0);
  End;

 Function TCustomIntlMonthCalendar.IsYearOnPage(AYear : Integer) : Boolean;
  Begin
   Result := (AYear = Year)
   Or ((Calendar.EraOf(Calendar.StartOfYear(Era, AYear)) = Era)
   And (AYear Div 10 = Year Div 10));
  End;

 Procedure TCustomIntlMonthCalendar.AnimateBegin;
  Begin
   If Assigned(fSavedScreen) Then
    FreeAndNil(fSavedScreen);
   If Animate And Showing Then
    Begin
     fSavedScreen   := TakeSnapshot;
     fSavedView     := CurrentView;
     fSavedDate     := Date;
     fSavedCellRect := GetCellRect(FocusedCell);
    End;
  End;

 Procedure TCustomIntlMonthCalendar.AnimateEnd;
  Begin
   If Assigned(fSavedScreen) Then
    FreeAndNil(fSavedScreen);
  End;

 Procedure TCustomIntlMonthCalendar.AnimatePlay;
  Var
   NewScreen : TBitmap;
   Rect      : TRect;
   DC        : HDC;
  Begin
   If Animate And Showing And Assigned(fSavedScreen) Then
    Begin
     NewScreen := TakeSnapshot;
     Try
      DC := GetDC(Handle);
      Try
       Rect := fMetrics.Bounds;
       If ShowHeader Then
        Begin
         BitBlt(DC, Rect.Left, Rect.Top, Rect.Right - Rect.Left,
         fMetrics.HeaderHeight, NewScreen.Canvas.Handle, 0, 0, SRCCOPY);
         Inc(Rect.Top, fMetrics.HeaderHeight);
        End;
       If ShowFooter Then
        Dec(Rect.Bottom, fMetrics.FooterHeight);
       If CurrentView = fSavedView Then
        Begin
         SwapScreenByScroll(DC, Rect, fMetrics.Bounds.Left, fMetrics.Bounds.Top,
         fSavedScreen, NewScreen, Date < fSavedDate, AnimateDuration);
        End
       Else
        Begin
         SwapScreenByZoom(DC, Rect, fMetrics.Bounds.Left, fMetrics.Bounds.Top,
         fSavedScreen, NewScreen, fSavedCellRect, GetCellRect(FocusedCell),
         AnimateDuration);
        End;
      Finally
       ReleaseDC(Handle, DC);
      End;
     Finally
      NewScreen.Free;
     End;
    End;
  End;

 Function TCustomIntlMonthCalendar.TakeSnapshot : TBitmap;
  Begin
   Result := TBitmap.Create;
   With fMetrics.Bounds Do
    Begin
     Result.Width  := Right - Left;
     Result.Height := Bottom - Top;
     SetWindowOrgEx(Result.Canvas.Handle, -Left, -Top, Nil);
    End;
   DrawCalendar(Result.Canvas);
   SetWindowOrgEx(Result.Canvas.Handle, 0, 0, Nil);
  End;

 Procedure TCustomIntlMonthCalendar.RenderBackground(Canvas : TCanvas; Var Rect : TRect; State : TIntlCalDrawStates);
  Const
   CP_CALITEM = LVP_LISTITEM;
  Var
   StateId   : Integer;
   ForeColor : Cardinal;
  Begin
   If ((cdsSelected In State) Or (cdsHotLight In State)) And IsThemed Then
    Begin
     If cdsGrayed In State Then
      StateId := LIS_DISABLED
     Else If cdsSelected In State Then
      Begin
       If Focused Then
        If cdsHotLight In State Then
         StateId := LISS_HOTSELECTED
        Else
         StateId := LIS_SELECTED
       Else
        StateId := LIS_SELECTEDNOTFOCUS
      End
     Else If cdsHotLight In State Then
      StateId := LIS_HOT
     Else
      StateId := LIS_NORMAL;
     If cdsGrayed In State Then
      ForeColor := ColorToRGB(clGrayText)
     Else If cdsHeader In State Then
      ForeColor := ColorToRGB(FontHeader.Color)
     Else If cdsFixedRow In State Then
      ForeColor := ColorToRGB(FontDayOfWeek.Color)
     Else If cdsFixedCol In State Then
      ForeColor := ColorToRGB(FontWeekNumbers.Color)
     Else
      ForeColor         := ColorToRGB(Font.Color);
     Canvas.Brush.Color := Color;
     Canvas.FillRect(Rect);
     DrawThemeBackground(Theme, Canvas.Handle, CP_CALITEM, StateId, Rect, @Rect);
     GetThemeColor(Theme, CP_CALITEM, StateId, TMT_TEXTCOLOR, ForeColor);
     Canvas.Font.Color := ForeColor;
    End
   Else
    Begin
     If cdsGrayed In State Then
      Canvas.Font.Color := clGrayText
     Else If cdsSelected In State Then
      If cdsFocused In State Then
       Canvas.Font.Color := clHighlightText
      Else
       Canvas.Font.Color := clBtnText
     Else If cdsHotLight In State Then
      Canvas.Font.Color := clHotLight
     Else If cdsHeader In State Then
      Canvas.Font.Color := FontHeader.Color
     Else If cdsFooter In State Then
      Canvas.Font.Color := FontFooter.Color
     Else If cdsFixedRow In State Then
      Canvas.Font.Color := FontDayOfWeek.Color
     Else If cdsFixedCol In State Then
      Canvas.Font.Color := FontWeekNumbers.Color
     Else
      Canvas.Font.Color := Font.Color;
     If cdsSelected In State Then
      If cdsFocused In State Then
       Canvas.Brush.Color := clHighlight
      Else
       Canvas.Brush.Color := clBtnFace
     Else
      Canvas.Brush.Color := Color;
     Canvas.FillRect(Rect);
    End;
   InflateRect(Rect, -1, -1);
   SetBkMode(Canvas.Handle, Transparent);
  End;

 Procedure TCustomIntlMonthCalendar.RenderText(Canvas : TCanvas; Var Rect : TRect; State : TIntlCalDrawStates; Const Text : String; Alignment : TAlignment);
  Const
   TextAlignments : Array[TAlignment] Of Cardinal = (DT_LEFT, DT_RIGHT, DT_CENTER);
  Var
   DrawFlags : Cardinal;
  Begin
   DrawFlags := DrawTextBiDiModeFlags(TextAlignments[Alignment] Or DT_VCENTER
   Or DT_NOPREFIX Or DT_SINGLELINE);
   Windows.DrawText(Canvas.Handle, PChar(Text), Length(Text), Rect, DrawFlags);
  End;

 Procedure TCustomIntlMonthCalendar.RenderArrow(Canvas : TCanvas; Var Rect : TRect; State : TIntlCalDrawStates; Backward : Boolean);
  Var
   Points     : Array[0..2] Of TPoint;
   ArrowWidth : Integer;
   w, h       : Integer;
  Begin
   w := Rect.Right - Rect.Left;
   h := Rect.Bottom - Rect.Top;
   If w < h Then
    ArrowWidth := w Div 6
   Else
    ArrowWidth := h Div 6;
   If Backward Then
    Begin
     Points[0].x := Rect.Left + (w Div 2 - ArrowWidth + 1);
     Points[1].x := Points[0].x + ArrowWidth;
    End
   Else
    Begin
     Points[0].x := Rect.Right - (w Div 2 - ArrowWidth + 1);
     Points[1].x := Points[0].x - ArrowWidth;
    End;
   Points[2].x        := Points[1].x;
   Points[0].y        := (Rect.Top + Rect.Bottom) Div 2;
   Points[1].y        := Points[0].y - ArrowWidth;
   Points[2].y        := Points[0].y + ArrowWidth;
   Canvas.Brush.Color := Canvas.Font.Color;
   Canvas.Pen.Color   := Canvas.Font.Color;
   Canvas.Polygon(Points);
  End;

 Procedure TCustomIntlMonthCalendar.RenderTodayMarker(Canvas : TCanvas; Var Rect : TRect);
  Begin
   Canvas.Brush.Style := bsClear;
   Canvas.Pen.Width   := 0;
   Canvas.Pen.Color   := ColorToday;
   Canvas.RoundRect(Rect.Left + 1, Rect.Top + 1, Rect.Right - 1, Rect.Bottom - 1, 4, 4);
   Canvas.Brush.Style := bsSolid;
  End;

 Procedure TCustomIntlMonthCalendar.DrawCalendar(Canvas : TCanvas);
  Begin
   If RectVisible(Canvas.Handle, fMetrics.Bounds) Then
    Begin
     If ShowHeader Then
      DrawHeader(Canvas);
     Case CurrentView Of
      vmDay :
       Begin
        If WeekNumbers Then
         Begin
          DrawWeekSpace(Canvas);
          DrawWeekNumbers(Canvas);
         End;
        DrawDaysOfWeek(Canvas);
        DrawDays(Canvas);
       End;
      vmMonth :
       DrawMonths(Canvas);
      vmYear :
       DrawYears(Canvas);
     End;
     If ShowFooter Then
      DrawFooter(Canvas);
    End;
  End;

 Procedure TCustomIntlMonthCalendar.DrawHeader(Canvas : TCanvas);
  Var
   Rect       : TRect;
   State      : TIntlCalDrawStates;
   HeaderText : String;
  Begin
   Rect := GetSectionRect(csHeader);
   If RectVisible(Canvas.Handle, Rect) Then
    Begin
     Canvas.Font := FontHeader;
     // Left Arrow
     Rect := GetSectionRect(csArrowLeft);
     If RectVisible(Canvas.Handle, Rect) Then
      Begin
       State := [cdsHeader];
       If Not IsDateInRange(GetAdjacentPageDate(True)) Then
        Include(State, cdsGrayed)
       Else If HotInfo = chtArrowLeft Then
        Begin
         Include(State, cdsHotLight);
         If NavigationTimer <> 0 Then
          Include(State, cdsSelected);
        End;
       RenderBackground(Canvas, Rect, State);
       RenderArrow(Canvas, Rect, State, True);
      End;
     // Right Arrow
     Rect := GetSectionRect(csArrowRight);
     If RectVisible(Canvas.Handle, Rect) Then
      Begin
       State := [cdsHeader];
       If Not IsDateInRange(GetAdjacentPageDate(False)) Then
        Include(State, cdsGrayed)
       Else If HotInfo = chtArrowRight Then
        Begin
         Include(State, cdsHotLight);
         If NavigationTimer <> 0 Then
          Include(State, cdsSelected);
        End;
       RenderBackground(Canvas, Rect, State);
       RenderArrow(Canvas, Rect, State, False);
      End;
     // Header text
     Rect := GetSectionRect(csHeaderText);
     If RectVisible(Canvas.Handle, Rect) Then
      Begin
       State := [cdsHeader];
       If (HotInfo = chtHeaderText) And (CurrentView <> vmYear) Then
        Include(State, cdsHotLight);
       RenderBackground(Canvas, Rect, State);
       HeaderText := GetHeaderText(CurrentView);
       If DoCustomDrawHeaderText(Canvas, Rect, State, HeaderText) Then
        RenderText(Canvas, Rect, State, HeaderText, taCenter);
      End;
    End;
  End;

 Procedure TCustomIntlMonthCalendar.DrawFooter(Canvas : TCanvas);
  Const
   Spacing = 2;
  Var
   Rect, r    : TRect;
   State      : TIntlCalDrawStates;
   FooterText : String;
  Begin
   Rect := GetSectionRect(csFooter);
   If RectVisible(Canvas.Handle, Rect) Then
    Begin
     Canvas.Pen.Width := 0;
     Canvas.Pen.Color := Color;
     Canvas.MoveTo(Rect.Left, Rect.Top);
     Canvas.LineTo(Rect.Right, Rect.Top);
     Inc(Rect.Top);
     Canvas.MoveTo(Rect.Left, Rect.Top);
     Canvas.LineTo(Rect.Right, Rect.Top);
     Inc(Rect.Top);
     Canvas.Font := FontFooter;
     State       := [cdsFooter];
     If (HotInfo = chtFooter) And Not Calendar.IsToday(Date) Then
      Include(State, cdsHotLight);
     RenderBackground(Canvas, Rect, State);
     FooterText := GetFooterText(fMetrics.LongFormat);
     If DoCustomDrawFooterText(Canvas, Rect, State, FooterText) Then
      Begin
       InflateRect(Rect, -Spacing, -Spacing);
       r.Top    := Rect.Top;
       r.Bottom := Rect.Bottom;
       If IsRightToLeft Then
        Begin
         r.Right := Rect.Right;
         r.Left  := r.Right - fMetrics.FooterHeight;
         Dec(Rect.Right, fMetrics.FooterHeight + Spacing);
        End
       Else
        Begin
         r.Left  := Rect.Left;
         r.Right := r.Left + fMetrics.FooterHeight;
         Inc(Rect.Left, fMetrics.FooterHeight + Spacing);
        End;
       RenderText(Canvas, Rect, State, FooterText, taLeftJustify);
       RenderTodayMarker(Canvas, r);
      End;
    End;
  End;

 Procedure TCustomIntlMonthCalendar.DrawWeekSpace(Canvas : TCanvas);
  Var
   Rect : TRect;
  Begin
   Rect := GetSectionRect(csWeekSpace);
   If RectVisible(Canvas.Handle, Rect) Then
    RenderBackground(Canvas, Rect, [cdsFixedRow, cdsFixedCol, cdsBlank]);
  End;

 Procedure TCustomIntlMonthCalendar.DrawDaysOfWeek(Canvas : TCanvas);
  Var
   Rect      : TRect;
   Col       : Integer;
   DayOfWeek : TDayOfWeek;
   State     : TIntlCalDrawStates;
  Begin
   Rect := GetSectionRect(csDaysOfWeek);
   If RectVisible(Canvas.Handle, Rect) Then
    Begin
     Canvas.Pen.Width := 0;
     Dec(Rect.Bottom);
     Canvas.Pen.Color := Color;
     Canvas.MoveTo(Rect.Left, Rect.Bottom);
     Canvas.LineTo(Rect.Right, Rect.Bottom);
     Dec(Rect.Bottom);
     Canvas.Pen.Color := ColorDivider;
     Canvas.MoveTo(Rect.Left, Rect.Bottom);
     Canvas.LineTo(Rect.Right, Rect.Bottom);
     Canvas.Font := FontDayOfWeek;
     For Col     := 0 To ColCount - 1 Do
      Begin
       DayOfWeek := TDayOfWeek(((Ord(Calendar.Settings.FirstDayOfWeek) + Col - 1) Mod Calendar.DaysPerWeek) + 1);
       Rect      := GetCellRect( -1, Col);
       If RectVisible(Canvas.Handle, Rect) Then
        Begin
         State := [cdsFixedRow];
         If Calendar.IsToday(DayOfWeek) And Calendar.IsThisMonth(Era, Year, Month) Then
          Include(State, cdsToday);
         RenderBackground(Canvas, Rect, State);
         If DoCustomDrawDayOfWeek(Canvas, Rect, State, DayOfWeek) Then
          RenderText(Canvas, Rect, State, GetDayName(DayOfWeek, fMetrics.NameKind), taCenter);
        End;
      End;
    End;
  End;

 Procedure TCustomIntlMonthCalendar.DrawWeekNumbers(Canvas : TCanvas);
  Var
   Rect                 : TRect;
   Row, TheWeek         : Integer;
   StartRange, EndRange : Integer;
   WeekStartDate        : TDateTime;
   State                : TIntlCalDrawStates;
  Begin
   Rect := GetSectionRect(csWeekNumbers);
   If RectVisible(Canvas.Handle, Rect) Then
    Begin
     Canvas.Pen.Width := 0;
     If IsRightToLeft Then
      Begin
       Canvas.Pen.Color := Color;
       Canvas.MoveTo(Rect.Left, Rect.Top);
       Canvas.LineTo(Rect.Left, Rect.Bottom);
       Inc(Rect.Left);
       Canvas.Pen.Color := ColorDivider;
       Canvas.MoveTo(Rect.Left, Rect.Top);
       Canvas.LineTo(Rect.Left, Rect.Bottom);
       Inc(Rect.Left);
      End
     Else
      Begin
       Dec(Rect.Right);
       Canvas.Pen.Color := Color;
       Canvas.MoveTo(Rect.Right, Rect.Top);
       Canvas.LineTo(Rect.Right, Rect.Bottom);
       Dec(Rect.Right);
       Canvas.Pen.Color := ColorDivider;
       Canvas.MoveTo(Rect.Right, Rect.Top);
       Canvas.LineTo(Rect.Right, Rect.Bottom);
      End;
     StartRange  := MonthStartCell Div ColCount;
     EndRange    := (MonthStartCell + DaysInMonth - 1) Div ColCount;
     Canvas.Font := FontWeekNumbers;
     For Row     := 0 To RowCount - 1 Do
      Begin
       Rect := GetCellRect(Row, -1);
       If RectVisible(Canvas.Handle, Rect) Then
        Begin
         WeekStartDate := Calendar.NextWeek(FirstCellDate, Row);
         State         := [cdsFixedCol];
         If (Row = (MonthStartCell + Day - 1) Div ColCount) Or
         IsDateInRange(WeekStartDate) Or
         IsDateInRange(Calendar.EndOfWeek(WeekStartDate)) Then
          Begin
           If (Row < StartRange) Or (Row > EndRange) Then
            Include(State, cdsGrayed);
           If Calendar.IsThisWeek(WeekStartDate) Then
            Include(State, cdsToday);
           If Row = StartRange Then
            TheWeek := Calendar.WeekOfYear(MonthFirstDate)
           Else
            TheWeek := Calendar.WeekOfYear(WeekStartDate);
          End
         Else
          Begin
           Include(State, cdsBlank);
           TheWeek := 0;
          End;
         RenderBackground(Canvas, Rect, State);
         If Not(cdsBlank In State) And DoCustomDrawWeekNumber(Canvas, Rect, State, TheWeek) Then
          RenderText(Canvas, Rect, State, GetWeekText(TheWeek), taCenter);
        End;
      End;
    End;
  End;

 Procedure TCustomIntlMonthCalendar.DrawDays(Canvas : TCanvas);
  Var
   Rect    : TRect;
   Cell    : Integer;
   TheDate : TDate;
   TheDay  : Integer;
   State   : TIntlCalDrawStates;
  Begin
   Rect := GetSectionRect(csYMD);
   If RectVisible(Canvas.Handle, Rect) Then
    Begin
     Canvas.Font := Font;
     For Cell    := 0 To CellCount - 1 Do
      Begin
       Rect := GetCellRect(Cell);
       If RectVisible(Canvas.Handle, Rect) Then
        Begin
         TheDate := FirstCellDate + Cell;
         State   := [];
         If Cell < MonthStartCell Then
          Begin
           TheDay := FirstCellDayNumber + Cell;
           Include(State, cdsGrayed);
          End
         Else If Cell >= MonthStartCell + DaysInMonth Then
          Begin
           TheDay := Cell - MonthStartCell - DaysInMonth + 1;
           Include(State, cdsGrayed);
          End
         Else
          TheDay := Cell - MonthStartCell + 1;
         If IsDateInRange(TheDate) Then
          Begin
           If IsSelected(TheDate) Then
            Include(State, cdsSelected);
           If (Cell = FocusedCell) And Focused Then
            Include(State, cdsFocused);
           If Cell = HotCell Then
            Include(State, cdsHotLight);
           If Calendar.IsToday(TheDate) Then
            Include(State, cdsToday);
          End
         Else
          Include(State, cdsBlank);
         RenderBackground(Canvas, Rect, State);
         If Not(cdsBlank In State) And DoCustomDrawDay(Canvas, Rect, State, TheDate, TheDay) Then
          Begin
           RenderText(Canvas, Rect, State, GetDayText(TheDay), taCenter);
           If cdsToday In State Then
            RenderTodayMarker(Canvas, Rect);
           If cdsFocused In State Then
            Canvas.DrawFocusRect(Rect);
          End;
        End;
      End;
    End;
  End;

 Procedure TCustomIntlMonthCalendar.DrawMonths(Canvas : TCanvas);
  Var
   Rect     : TRect;
   Cell     : Integer;
   TheMonth : Integer;
   State    : TIntlCalDrawStates;
  Begin
   Rect := GetSectionRect(csYMD);
   If RectVisible(Canvas.Handle, Rect) Then
    Begin
     Canvas.Font := Font;
     For Cell    := 0 To CellCount - 1 Do
      Begin
       Rect := GetCellRect(Cell);
       If RectVisible(Canvas.Handle, Rect) Then
        Begin
         TheMonth := Cell + 1;
         State    := [];
         If IsMonthInRange(Era, Year, TheMonth) Then
          Begin
           If Cell = FocusedCell Then
            Begin
             Include(State, cdsSelected);
             If Focused Then
              Include(State, cdsFocused);
            End;
           If Cell = HotCell Then
            Include(State, cdsHotLight);
           If Calendar.IsThisMonth(Era, Year, TheMonth) Then
            Include(State, cdsToday);
          End
         Else
          Include(State, cdsBlank);
         RenderBackground(Canvas, Rect, State);
         If Not(cdsBlank In State) And DoCustomDrawMonth(Canvas, Rect, State, TheMonth) Then
          Begin
           RenderText(Canvas, Rect, State, GetMonthName(TheMonth, fMetrics.NameKind), taCenter);
           If cdsFocused In State Then
            Canvas.DrawFocusRect(Rect);
          End;
        End;
      End;
    End;
  End;

 Procedure TCustomIntlMonthCalendar.DrawYears(Canvas : TCanvas);
  Var
   Rect    : TRect;
   Cell    : Integer;
   TheYear : Integer;
   State   : TIntlCalDrawStates;
  Begin
   Rect := GetSectionRect(csYMD);
   If RectVisible(Canvas.Handle, Rect) Then
    Begin
     Canvas.Font := Font;
     For Cell    := 0 To CellCount - 1 Do
      Begin
       Rect := GetCellRect(Cell);
       If RectVisible(Canvas.Handle, Rect) Then
        Begin
         TheYear := Calendar.OffsetYear(Era, FirstCellYear, Cell);
         State   := [];
         If IsYearInRange(Era, TheYear) Then
          Begin
           If Cell = FocusedCell Then
            Begin
             Include(State, cdsSelected);
             If Focused Then
              Include(State, cdsFocused);
            End
           Else If Not IsYearOnPage(TheYear) Then
            Include(State, cdsGrayed);
           If Cell = HotCell Then
            Include(State, cdsHotLight);
           If Calendar.IsThisYear(Era, TheYear) Then
            Include(State, cdsToday);
          End
         Else
          Include(State, cdsBlank);
         RenderBackground(Canvas, Rect, State);
         If Not(cdsBlank In State) And DoCustomDrawYear(Canvas, Rect, State, TheYear) Then
          Begin
           RenderText(Canvas, Rect, State, GetYearText(TheYear), taCenter);
           If cdsFocused In State Then
            Canvas.DrawFocusRect(Rect);
          End;
        End;
      End;
    End;
  End;

 Procedure TCustomIntlMonthCalendar.InvalidateSections(Sections : TIntlCalSections);
  Var
   Section : TIntlCalSection;
  Begin
   If WindowHandle <> 0 Then
    Begin
     If (CurrentView <> vmDay) Or Not WeekNumbers Then
      Begin
       Exclude(Sections, csWeekSpace);
       Exclude(Sections, csWeekNumbers);
       If CurrentView <> vmDay Then
        Exclude(Sections, csDaysOfWeek);
      End;
     If Not ShowHeader Then
      Begin
       Exclude(Sections, csHeader);
       Exclude(Sections, csHeaderText);
       Exclude(Sections, csArrowLeft);
       Exclude(Sections, csArrowRight);
      End;
     If Not ShowFooter Then
      Exclude(Sections, csFooter);
     For Section := Low(TIntlCalSection) To High(TIntlCalSection) Do
      If Section In Sections Then
       InvalidateRect(WindowHandle, GetSectionRect(Section), False);
    End;
  End;

 Procedure TCustomIntlMonthCalendar.InvalidateDateDependentSections;
  Begin
   InvalidateSections([csHeader, csWeekNumbers, csYMD, csFooter]);
  End;

 Procedure TCustomIntlMonthCalendar.InvalidateCell(Index : Integer);
  Begin
   If (WindowHandle <> 0) And (Index >= 0) And (Index < CellCount) Then
    InvalidateRect(WindowHandle, GetCellRect(Index), False);
  End;

 Procedure TCustomIntlMonthCalendar.InvalidateDate(Const ADate : TDate);
  Var
   TheYear : Integer;
  Begin
   If WindowHandle <> 0 Then
    Case CurrentView Of
     vmDay :
      InvalidateCell(Trunc(ADate) - Trunc(FirstCellDate));
     vmMonth :
      InvalidateCell(Calendar.MonthOfYear(ADate) - 1);
     vmYear :
      Begin
       TheYear := Calendar.ConvertYear(Calendar.YearOf(ADate), Calendar.DefaultEra, Era);
       InvalidateCell(TheYear - FirstCellYear);
      End;
    End;
  End;

 Procedure TCustomIntlMonthCalendar.InvalidateDates(ADates : TDateTimeList);
  Var
   i, Index : Integer;
  Begin
   If (WindowHandle <> 0) And (CurrentView = vmDay) And (ADates.Count <> 0) Then
    Begin
     ADates.Find(FirstCellDate, i);
     For i := i To fSelection.Count - 1 Do
      Begin
       Index := Trunc(ADates[i]) - Trunc(FirstCellDate);
       If Index >= CellCount Then
        Exit;
       InvalidateCell(Index);
      End;
    End;
  End;

 Procedure TCustomIntlMonthCalendar.InvalidateDateRange(Const ADate1, ADate2 : TDate);
  Var
   Index        : Integer;
   iStart, iEnd : Integer;
  Begin
   If (WindowHandle <> 0) And (CurrentView = vmDay) Then
    Begin
     iStart := Trunc(ADate1) - Trunc(FirstCellDate);
     iEnd   := Trunc(ADate2) - Trunc(FirstCellDate);
     If iStart > iEnd Then
      Begin
       Index  := iStart;
       iStart := iEnd;
       iEnd   := Index;
      End;
     If iStart < 0 Then
      iStart := 0;
     If iEnd >= CellCount Then
      iEnd     := CellCount - 1;
     For Index := iStart To iEnd Do
      InvalidateCell(Index);
    End;
  End;

 Procedure TCustomIntlMonthCalendar.InvalidateSelection;
  Begin
   Case CurrentView Of
    vmDay :
     Begin
      Case SelectionStyle Of
       ssSingle :
        InvalidateCell(MonthStartCell + Day - 1);
       ssRange :
        InvalidateDateRange(Date, fSelectionAnchor);
       ssFree :
        Begin
         InvalidateDates(fSelection);
         If Not fSelection.Exists(Date) Then
          InvalidateCell(MonthStartCell + Day - 1);
        End;
      End;
     End;
    vmMonth :
     InvalidateCell(Month - 1);
    vmYear :
     InvalidateCell(Year - FirstCellYear);
   End;
  End;

 Procedure TCustomIntlMonthCalendar.InvalidateHotLight;
  Begin
   Case HotInfo Of
    chtYear, chtMonth, chtDay : InvalidateCell(HotCell);
    chtHeaderText             : InvalidateSections([csHeaderText]);
    chtArrowLeft              : InvalidateSections([csArrowLeft]);
    chtArrowRight             : InvalidateSections([csArrowRight]);
    chtFooter                 : InvalidateSections([csFooter]);
   End;
  End;

 Procedure TCustomIntlMonthCalendar.CalcMetrics(ViewMode : TIntlCalViewMode; Out Metrics : TIntlCalMetrics);
  Const
   HSpacing = 4;
   VSpacing = 2;
  Var
   DC       : HDC;
   OldFont  : HFONT;
   NameKind : TIntlCalNameKind;
   DoW      : TDayOfWeek;
   Extends  : Array[TIntlCalNameKind] Of TSize;
   Extend   : TSize;
   w, h, m  : Integer;
   s        : String;
  Begin
   If (csLoading In ComponentState) Or (WindowHandle = 0) Or (fUpdateMetricsCount <> 0) Then
    Exit;
   Inc(fUpdateMetricsCount);
   DC := CreateCompatibleDC(0);
   Try
    OldFont := SelectObject(DC, Font.Handle);
    Try
     Metrics.Bounds         := GetCalendarClientRect;
     Metrics.HeaderHeight   := 0;
     Metrics.FooterHeight   := 0;
     Metrics.FixedRowHeight := 0;
     Metrics.FixedColWidth  := 0;
     w                      := Metrics.Bounds.Right - Metrics.Bounds.Left;
     h                      := Metrics.Bounds.Bottom - Metrics.Bounds.Top;
     If ShowHeader Then
      Begin
       s := GetHeaderText(ViewMode);
       SelectObject(DC, FontHeader.Handle);
       GetTextExtentPoint32(DC, PChar(s), Length(s), Extend);
       SelectObject(DC, Font.Handle);
       Metrics.HeaderHeight := Max(3 * Extend.cy Div 2, 13) + VSpacing;
       If Not Odd(Metrics.HeaderHeight) Then
        Inc(Metrics.HeaderHeight);
       Dec(h, Metrics.HeaderHeight);
      End;
     If ShowFooter Then
      Begin
       Metrics.LongFormat := True;
       SelectObject(DC, FontFooter.Handle);
       s := GetFooterText(Metrics.LongFormat);
       GetTextExtentPoint32(DC, PChar(s), Length(s), Extend);
       If Extend.cx > 75 * w Div 100 Then
        Begin
         Metrics.LongFormat := False;
         s                  := GetFooterText(Metrics.LongFormat);
         GetTextExtentPoint32(DC, PChar(s), Length(s), Extend);
        End;
       SelectObject(DC, Font.Handle);
       Metrics.FooterHeight := Max(3 * Extend.cy Div 2, 13) + VSpacing;
       If Not Odd(Metrics.FooterHeight) Then
        Inc(Metrics.FooterHeight);
       Dec(h, Metrics.FooterHeight);
      End;
     Case ViewMode Of
      vmDay :
       Begin
        Metrics.ColCount := Calendar.DaysPerWeek;
        Metrics.RowCount := Ceil(Ceil(DaysInYear / MonthsInYear) / Metrics.ColCount) + 1;
        If WeekNumbers Then
         Begin
          s := GetWeekText(Calendar.WeeksInYear(Year));
          SelectObject(DC, FontWeekNumbers.Handle);
          GetTextExtentPoint32(DC, PChar(s), Length(s), Extend);
          SelectObject(DC, Font.Handle);
          Metrics.FixedColWidth := Extend.cx + 3 * HSpacing Div 2 + 2;
          Dec(w, Metrics.FixedColWidth);
         End;
        s := GetDayText(Ceil(DaysInYear / MonthsInYear));
        GetTextExtentPoint32(DC, PChar(s), Length(s), Extend);
        For NameKind       := Low(TIntlCalNameKind) To High(TIntlCalNameKind) Do
         Extends[NameKind] := Extend;
        SelectObject(DC, FontDayOfWeek.Handle);
        For DoW := Low(TDayOfWeek) To High(TDayOfWeek) Do
         Begin
          For NameKind := nkLong To nkShortest Do
           Begin
            s := GetDayName(DoW, NameKind);
            GetTextExtentPoint32(DC, PChar(s), Length(s), Extend);
            If Extend.cx > Extends[NameKind].cx Then
             Extends[NameKind].cx := Extend.cx;
            If Extend.cy > Extends[NameKind].cy Then
             Extends[NameKind].cy := Extend.cy;
           End;
         End;
        SelectObject(DC, Font.Handle);
        Metrics.NameKind := nkShortest;
        For NameKind     := nkLong To nkShortest Do
         Begin
          If (Extends[NameKind].cx + HSpacing) * Metrics.ColCount <= w Then
           Begin
            Metrics.NameKind := NameKind;
            Break;
           End;
         End;
        Metrics.FixedRowHeight := Extends[Metrics.NameKind].cy + VSpacing + 2;
        Dec(h, Metrics.FixedRowHeight);
        Metrics.ColWidth        := w Div Metrics.ColCount;
        Metrics.RowHeight       := h Div Metrics.RowCount;
        Metrics.StretchedCols   := w - Metrics.ColWidth * Metrics.ColCount;
        Metrics.StretchedRows   := h - Metrics.RowHeight * Metrics.RowCount;
        Metrics.PrefferedWidth  := Metrics.FixedColWidth + (Extends[Metrics.NameKind].cx + HSpacing) * Metrics.ColCount;
        Metrics.PrefferedHeight := Metrics.FixedRowHeight + (Extends[Metrics.NameKind].cy + 2 * VSpacing) * Metrics.RowCount;
       End;
      vmMonth :
       Begin
        Metrics.ColCount      := 3;
        Metrics.RowCount      := Ceil(MonthsInYear / Metrics.ColCount);
        Metrics.ColWidth      := w Div Metrics.ColCount;
        Metrics.RowHeight     := h Div Metrics.RowCount;
        Metrics.StretchedRows := h - (Metrics.RowHeight * Metrics.RowCount);
        Metrics.StretchedCols := w - (Metrics.ColWidth * Metrics.ColCount);
        FillChar(Extends[nkLong], SizeOf(Extend) * 2, 0);
        For m         := 1 To Calendar.MaxMonthsPerYear Do
         For NameKind := nkLong To nkShort Do
          Begin
           s := GetMonthName(m, NameKind);
           GetTextExtentPoint32(DC, PChar(s), Length(s), Extend);
           If Extend.cx > Extends[NameKind].cx Then
            Extends[NameKind].cx := Extend.cx;
           If Extend.cy > Extends[NameKind].cy Then
            Extends[NameKind].cy := Extend.cy;
          End;
        Metrics.NameKind := nkShort;
        For NameKind     := nkLong To nkShort Do
         Begin
          If (Extends[NameKind].cx + HSpacing) * Metrics.ColCount <= w Then
           Begin
            Metrics.NameKind := NameKind;
            Break;
           End;
         End;
        Metrics.PrefferedWidth  := (Extends[Metrics.NameKind].cx + HSpacing) * Metrics.ColCount;
        Metrics.PrefferedHeight := (Extends[Metrics.NameKind].cy + VSpacing) * Metrics.RowCount;
       End;
      vmYear :
       Begin
        Metrics.ColCount      := 4;
        Metrics.RowCount      := 3;
        Metrics.ColWidth      := w Div Metrics.ColCount;
        Metrics.RowHeight     := h Div Metrics.RowCount;
        Metrics.StretchedRows := h - (Metrics.RowHeight * Metrics.RowCount);
        Metrics.StretchedCols := w - (Metrics.ColWidth * Metrics.ColCount);
        s                     := GetYearText(Calendar.YearOf(Calendar.MaxSupportedDateTime));
        GetTextExtentPoint32(DC, PChar(s), Length(s), Extend);
        Metrics.PrefferedWidth  := (Extend.cx + HSpacing) * Metrics.ColCount;
        Metrics.PrefferedHeight := (Extend.cy + VSpacing) * Metrics.RowCount;
       End;
     End;
     Inc(Metrics.PrefferedHeight, Metrics.HeaderHeight);
     Inc(Metrics.PrefferedHeight, Metrics.FooterHeight);
    Finally
     SelectObject(DC, OldFont);
    End;
   Finally
    DeleteObject(DC);
    Dec(fUpdateMetricsCount);
   End;
  End;

 Procedure TCustomIntlMonthCalendar.CalcMetricsSections(Var Metrics : TIntlCalMetrics);
  Var
   Sec : TIntlCalSection;
  Begin
   If (csLoading In ComponentState) Or (WindowHandle = 0) Or (fUpdateMetricsCount <> 0) Then
    Exit;
   For Sec := Low(TIntlCalSection) To High(TIntlCalSection) Do
    With fMetrics, Sections[Sec] Do
     Begin
      Sections[Sec] := Bounds;
      Case Sec Of
       csHeader :
        Begin
         Bottom := Top + HeaderHeight;
        End;
       csHeaderText :
        Begin
         Inc(Left, HeaderHeight);
         Dec(Right, HeaderHeight);
         Bottom := Top + HeaderHeight;
        End;
       csArrowLeft :
        Begin
         Right  := Left + HeaderHeight;
         Bottom := Top + HeaderHeight;
        End;
       csArrowRight :
        Begin
         Left   := Right - HeaderHeight;
         Bottom := Top + HeaderHeight;
        End;
       csFooter :
        Begin
         Top := Bottom - FooterHeight;
        End;
       csWeekSpace :
        Begin
         Inc(Top, HeaderHeight);
         If IsRightToLeft Then
          Left := Right - FixedColWidth
         Else
          Right := Left + FixedColWidth;
         Bottom := Top + FixedRowHeight;
        End;
       csDaysOfWeek :
        Begin
         Inc(Top, HeaderHeight);
         If IsRightToLeft Then
          Dec(Right, FixedColWidth)
         Else
          Inc(Left, FixedColWidth);
         Bottom := Top + FixedRowHeight;
        End;
       csWeekNumbers :
        Begin
         Inc(Top, HeaderHeight);
         Inc(Top, FixedRowHeight);
         If IsRightToLeft Then
          Left := Right - FixedColWidth
         Else
          Right := Left + FixedColWidth;
         Dec(Bottom, FooterHeight);
        End;
       csYMD :
        Begin
         Inc(Top, HeaderHeight);
         Inc(Top, FixedRowHeight);
         If IsRightToLeft Then
          Dec(Right, FixedColWidth)
         Else
          Inc(Left, FixedColWidth);
         Dec(Bottom, FooterHeight);
        End;
      End;
     End;
  End;

 Procedure TCustomIntlMonthCalendar.UpdateMetrics;
  Begin
   If fUpdateMetricsCount = 0 Then
    Begin
     fPrefferedSizeReady := False;
     CalcMetrics(CurrentView, fMetrics);
     CalcMetricsSections(fMetrics);
     If Not(csLoading In ComponentState) Then
      AdjustSize;
     Invalidate;
    End;
  End;

 Procedure TCustomIntlMonthCalendar.UpdateMinMaxRanges;
  Var
   i : Integer;
  Begin
   If Calendar.IsNoDate(DateMin) Or
   (Calendar.CompareDate(DateMin, Calendar.MinSupportedDateTime) < 0)
   Then
    fActualDateMin := Trunc(Calendar.MinSupportedDateTime)
   Else
    fActualDateMin := DateMin;
   If Calendar.IsNoDate(DateMax) Or
   (Calendar.CompareDate(DateMax, Calendar.MaxSupportedDateTime) > 0)
   Then
    fActualDateMax := Trunc(Calendar.MaxSupportedDateTime)
   Else
    fActualDateMax := DateMax;
   If Not(csLoading In ComponentState) Then
    Begin
     Case SelectionStyle Of
      ssRange :
       fSelectionAnchor := EnsureDateInRange(fSelectionAnchor);
      ssFree :
       Begin
        fSelection.Find(ActualDateMin, i);
        If i = fSelection.Count Then
         fSelection.Clear
        Else
         Begin
          For i := i - 1 Downto 0 Do
           fSelection.Delete(i);
          If fSelection.Find(ActualDateMax, i) Then
           Inc(i);
          If i = 0 Then
           fSelection.Clear
          Else
           Begin
            For i := fSelection.Count - 1 Downto i Do
             fSelection.Delete(i);
           End;
         End;
       End;
     End;
     FocusDate(EnsureDateInRange(Date));
     InvalidateDateDependentSections;
    End;
  End;

 Procedure TCustomIntlMonthCalendar.UpdateCalendar;
  Begin
   Inc(fUpdateMetricsCount);
   Try
    If Assigned(Culture) Then
     BiDiMode := Culture.BiDiMode
    Else
     ParentBiDiMode := True;
    UpdateMinMaxRanges;
    ExtractDateInfo(EnsureDateInRange(Date));
   Finally
    Dec(fUpdateMetricsCount);
   End;
   UpdateMetrics;
  End;

 Procedure TCustomIntlMonthCalendar.ValidateCalendar;

   Procedure InitNewCalendar;
    Begin
     fCalendar.OnChange := CalendarChanged;
     UpdateCalendar;
     DoCalendarChange;
    End;
  Var
   Reference : TCalendar;

  Begin
   If csLoading In ComponentState Then
    Exit;
   If Not Assigned(CalendarType) Then
    Begin
     If UsingCultureCalendar Then
      Reference := Culture.NativeCalendar
     Else
      Reference := DefaultCalendar;
     If Reference.ClassType <> Calendar.ClassType Then
      Begin
       FreeAndNil(fCalendar);
       fCalendar := Reference.Clone;
       InitNewCalendar;
      End
     Else
      fCalendar.Assign(Reference);
    End
   Else If CalendarType <> Calendar.ClassType Then
    Begin
     FreeAndNil(fCalendar);
     If Assigned(Culture) Then
      fCalendar := CalendarType.Create(Culture.Locale)
     Else
      fCalendar := CalendarType.Create(LOCALE_USER_DEFAULT);
     InitNewCalendar;
    End
   Else If Assigned(Culture) Then
    fCalendar.Settings.Prepare(Culture.Locale)
   Else
    fCalendar.Settings.Prepare(LOCALE_USER_DEFAULT);
  End;

 Procedure TCustomIntlMonthCalendar.ExtractDateInfo(Const ADate : TDate);
  Begin
   If csLoading In ComponentState Then
    Exit;
   fDate := ADate;
   Calendar.DecodeDate(Date, fEra, fYear, fMonth, fDay);
   fMonthsInYear        := Calendar.MonthsInYear(Era, Year);
   fDaysInYear          := Calendar.DaysInYear(Era, Year);
   fDaysInMonth         := Calendar.DaysInMonth(Era, Year, Month);
   fMonthFirstDate      := Date - Day + 1;
   fMonthFirstDayOfWeek := Calendar.DayOfWeek(MonthFirstDate);
   fMonthStartCell      := Calendar.DaysOfWeekBetween(MonthFirstDayOfWeek, Calendar.Settings.FirstDayOfWeek);
   If fMonthStartCell = 0 Then
    Inc(fMonthStartCell, Calendar.DaysPerWeek);
   fFirstCellDayNumber := Calendar.DayOfMonth(FirstCellDate);
   fFirstCellYear      := Calendar.OffsetYear(Era, Year, -(Year Mod 10) - 1);
  End;

 Procedure TCustomIntlMonthCalendar.FocusDate(Const ADate : TDate);
  Var
   OldEra, OldYear, OldMonth, OldDay : Integer;
   OldMonthsInYear                   : Integer;
  Begin
   If (csLoading In ComponentState) Or (ADate = Date) Then
    Exit;
   OldDay := Day;
   fDay   := Trunc(ADate) - Trunc(MonthFirstDate) + 1;
   If (Day >= 1) And (Day <= DaysInMonth) Then
    Begin
     fDate := ADate;
     If CurrentView = vmDay Then
      Begin
       InvalidateCell(MonthStartCell + OldDay - 1);
       InvalidateCell(MonthStartCell + Day - 1);
      End;
    End
   Else
    Begin
     OldEra          := Era;
     OldYear         := Year;
     OldMonth        := Month;
     fDay            := OldDay;
     OldMonthsInYear := MonthsInYear;
     AnimateBegin;
     Try
      ExtractDateInfo(ADate);
      Case CurrentView Of
       vmDay :
        Begin
         AnimatePlay;
         DoPageChange;
         InvalidateDateDependentSections;
        End;
       vmMonth :
        Begin
         If (Era <> OldEra) Or (Year <> OldYear) Then
          Begin
           If OldMonthsInYear <> MonthsInYear Then
            CalcMetrics(CurrentView, fMetrics);
           AnimatePlay;
           DoPageChange;
           InvalidateDateDependentSections;
          End
         Else
          Begin
           InvalidateCell(OldMonth - 1);
           InvalidateCell(Month - 1);
          End;
        End;
       vmYear :
        Begin
         If (Era <> OldEra) Or ((OldYear Div 10) <> (Year Div 10)) Then
          Begin
           AnimatePlay;
           DoPageChange;
           InvalidateDateDependentSections;
          End
         Else
          Begin
           InvalidateCell(OldYear - FirstCellYear);
           InvalidateCell(Year - FirstCellYear);
          End;
        End;
      End;
     Finally
      AnimateEnd;
     End;
    End;
   DoDateChange;
  End;

 Function TCustomIntlMonthCalendar.GetDateAt(x, y : Integer; Out ADate : TDate) : Boolean;
  Var
   Cell : Integer;
  Begin
   Result := (GetHitTestInfoAt(x, y, Cell) = chtDay) And GetDateAtCell(Cell, ADate);
  End;

 Function TCustomIntlMonthCalendar.GetDateAtCell(Index : Integer; Out ADate : TDate) : Boolean;
  Begin
   Result := False;
   If (CurrentView = vmDay) And (Index >= 0) And (Index < CellCount) Then
    Begin
     ADate  := FirstCellDate + Index;
     Result := IsDateInRange(ADate);
    End;
  End;

 Function TCustomIntlMonthCalendar.GetMonthAt(x, y : Integer; Out AMonth : Integer) : Boolean;
  Var
   Cell : Integer;
  Begin
   Result := (GetHitTestInfoAt(x, y, Cell) = chtMonth) And GetMonthAtCell(Cell, AMonth);
  End;

 Function TCustomIntlMonthCalendar.GetMonthAtCell(Index : Integer; Out AMonth : Integer) : Boolean;
  Begin
   Result := False;
   If (CurrentView = vmMonth) And (Index >= 0) And (Index < CellCount) Then
    Begin
     AMonth := Index + 1;
     Result := IsMonthInRange(Era, Year, AMonth);
    End;
  End;

 Function TCustomIntlMonthCalendar.GetYearAt(x, y : Integer; Out AYear : Integer) : Boolean;
  Var
   Cell : Integer;
  Begin
   Result := (GetHitTestInfoAt(x, y, Cell) = chtYear) And GetYearAtCell(Cell, AYear);
  End;

 Function TCustomIntlMonthCalendar.GetYearAtCell(Index : Integer; Out AYear : Integer) : Boolean;
  Begin
   Result := False;
   If (CurrentView = vmYear) And (Index >= 0) And (Index < CellCount) Then
    Begin
     AYear  := Calendar.OffsetYear(FirstCellYear, Index);
     Result := IsYearInRange(Era, AYear);
    End;
  End;

 Procedure TCustomIntlMonthCalendar.SelectDate(Const ADate : TDate; ShiftState : TShiftState);
  Var
   i, Dir              : Integer;
   AnchorDate, TheDate : TDate;
   Changed             : Boolean;
  Begin
   Changed    := False;
   AnchorDate := EnsureDateInRange(ADate);
   Case SelectionStyle Of
    ssSingle :
     Changed := (fDate <> AnchorDate);
    ssRange :
     If (ssLeft In ShiftState) And (fSelectionAnchor <> AnchorDate) Then
      Begin
       If Not(ssShift In ShiftState) Then
        fSelectionAnchor := AnchorDate;
       InvalidateDateRange(fSelectionAnchor, AnchorDate);
       Changed := True;
      End;
     Else // ssFree
     If Not(ssCtrl In ShiftState) And (fSelection.Count <> 0) Then
      Begin
       InvalidateDates(fSelection);
       fSelection.Clear;
       Changed := True;
      End;
    If ssLeft In ShiftState Then
    Begin
    If ssShift In ShiftState Then
    Begin
    If AnchorDate < fSelectionAnchor Then
    Dir := +1
    Else
    Dir     := -1;
    TheDate := AnchorDate;
    For i   := 0 To Calendar.DaysBetween(fSelectionAnchor, AnchorDate) Do
    Begin
    If Not fSelection.Exists(TheDate) And DoDateSelectable(TheDate) Then
    Begin
    fSelection.Add(TheDate);
    InvalidateDate(TheDate);
    Changed := True;
    End;
    Calendar.IncDay(TheDate, Dir);
    End;
    End
    Else If ssCtrl In ShiftState Then
    Begin
    If fSelection.Remove(AnchorDate) >= 0 Then
    Begin
    InvalidateDate(AnchorDate);
    Changed := True;
    End
    Else If DoDateSelectable(AnchorDate) Then
    Begin
    fSelection.Add(AnchorDate);
    InvalidateDate(AnchorDate);
    Changed := True;
    End;
    fSelectionAnchor := AnchorDate;
    End
    Else
    Begin
    If Not fSelection.Exists(AnchorDate) And DoDateSelectable(AnchorDate) Then
    Begin
    InvalidateDate(AnchorDate);
    fSelection.Add(AnchorDate);
    Changed := True;
    End;
    fSelectionAnchor := AnchorDate;
    End;
    End;
    End; // case
    FocusDate(AnchorDate);
    If Changed Then
    DoSelectionChange;
    End;

    Procedure TCustomIntlMonthCalendar.Select(Const ADate : TDate; ShiftState : TShiftState);
    Begin
    SelectDate(ADate, ShiftState + [ssLeft]);
    End;

    Procedure TCustomIntlMonthCalendar.ClearSelection;
    Begin
    Case SelectionStyle Of
    ssRange :
     Begin
      If fSelectionAnchor <> Date Then
       Begin
        InvalidateDateRange(fSelectionAnchor, Date);
        fSelectionAnchor := Date;
        DoSelectionChange;
       End;
     End;
    ssFree :
     Begin
      If fSelection.Count <> 0 Then
       Begin
        InvalidateDates(fSelection);
        fSelection.Clear;
        DoSelectionChange;
       End;
     End;
   End;
  End;

 Function TCustomIntlMonthCalendar.IsSelected(Const ADate : TDate) : Boolean;
  Begin
   Case SelectionStyle Of
    ssSingle :
     Result := Calendar.IsSameDay(ADate, Date);
    ssRange :
     Begin
      Case Calendar.CompareDate(ADate, Date) Of
       -1 : Result := (Calendar.CompareDate(ADate, fSelectionAnchor) >= 0);
       +1 : Result := (Calendar.CompareDate(ADate, fSelectionAnchor) <= 0);
      Else Result := True;
      End;
     End
   Else
     Result := fSelection.Exists(Trunc(ADate));
   End;
  End;

 Function TCustomIntlMonthCalendar.IsYearInRange(AEra, AYear : Integer) : Boolean;
  Begin
   Result := Calendar.IsValidYear(AEra, AYear) And
   (IsDateInRange(Calendar.StartOfYear(AEra, AYear)) Or
   IsDateInRange(Calendar.EndOfYear(AEra, AYear)));
  End;

 Function TCustomIntlMonthCalendar.IsYearInRange(AYear : Integer) : Boolean;
  Begin
   Result := IsYearInRange(Era, AYear);
  End;

 Function TCustomIntlMonthCalendar.IsMonthInRange(AEra, AYear, AMonth : Integer) : Boolean;
  Begin
   Result := Calendar.IsValidMonth(AEra, AYear, AMonth) And
   (IsDateInRange(Calendar.StartOfMonth(AEra, AYear, AMonth)) Or
   IsDateInRange(Calendar.EndOfMonth(AEra, AYear, AMonth)));
  End;

 Function TCustomIntlMonthCalendar.IsMonthInRange(AYear, AMonth : Integer) : Boolean;
  Begin
   Result := IsMonthInRange(Era, AYear, AMonth);
  End;

 Function TCustomIntlMonthCalendar.IsDateInRange(Const ADate : TDate) : Boolean;
  Begin
   Result := Calendar.IsInRange(Trunc(ADate), ActualDateMin, ActualDateMax);
  End;

 Function TCustomIntlMonthCalendar.EnsureDateInRange(Const ADate : TDate) : TDate;
  Begin
   If IsDateInRange(ADate) Then
    Result := Trunc(ADate)
   Else If Calendar.CompareDate(ADate, ActualDateMax) > 0 Then
    Result := ActualDateMax
   Else
    Result := ActualDateMin;
  End;

 Function TCustomIntlMonthCalendar.Format(Const FmtStr : String; Const ADate : TDateTime) : String;
  Begin
   Result := Calendar.Format(FmtStr, ADate);
   NormalizeDigits(Result);
  End;

{ TIntlMonthCalendarPopup }

 Constructor TIntlMonthCalendarPopup.Create(AOwner : TWinControl);
  Begin
   Inherited Create(AOwner);
   ControlStyle := ControlStyle + [csNoDesignVisible];
   TabStop      := False;
   ShowFooter   := True;
   ParentColor  := True;
   BevelKind    := bkNone;
   Visible      := False;
   Parent       := AOwner;
  End;

 Procedure TIntlMonthCalendarPopup.WMMouseActivate(Var Message : TMessage);
  Begin
   Message.Result := MA_NOACTIVATE;
  End;

 Procedure TIntlMonthCalendarPopup.CMVisibleChanged(Var Message : TMessage);
  Begin
   Inherited;
   CurrentView := vmDay;
   If Not Visible And Assigned(Parent) Then
    Parent.Invalidate;
  End;

 Procedure TIntlMonthCalendarPopup.MouseUp(Button : TMouseButton; Shift : TShiftState; x, y : Integer);
  Var
   Offset : Integer;
  Begin
   If (Button = mbLeft) And (GetHitTestInfoAt(x, y, Offset) In [chtDay, chtFooter]) Then
    DoCloseUp(True);
   Inherited MouseUp(Button, Shift, x, y);
  End;

 Procedure TIntlMonthCalendarPopup.KeyDown(Var Key : Word; Shift : TShiftState);
  Begin
   If Key In [VK_RETURN, VK_ESCAPE] Then
    Begin
     DoCloseUp(Key = VK_RETURN);
     Key := 0;
    End;
   Inherited KeyDown(Key, Shift);
  End;

 Procedure TIntlMonthCalendarPopup.CreateParams(Var Params : TCreateParams);
  Begin
   Inherited CreateParams(Params);
   With Params Do
    Begin
     Style             := WS_POPUP Or WS_BORDER;
     WindowClass.Style := WindowClass.Style Or CS_SAVEBITS Or CS_DROPSHADOW;
    End;
  End;

 Function TIntlMonthCalendarPopup.Focused : Boolean;
  Begin
   Result := Parent.Focused;
  End;

 Procedure TIntlMonthCalendarPopup.Show(x, y : Integer);
  Begin
   SetWindowPos(Handle, HWND_TOP, x, y, 0, 0,
   SWP_NOSIZE Or SWP_NOACTIVATE Or SWP_SHOWWINDOW);
   Visible := True;
  End;

 Procedure TIntlMonthCalendarPopup.DoCloseUp(Accept : Boolean);
  Begin
   If Assigned(OnCloseUp) Then
    OnCloseUp(Self, Accept);
  End;

{ TCustomIntlDatePicker }

 Constructor TCustomIntlDatePicker.Create(AOwner : TComponent);
  Begin
   Inherited Create(AOwner);
   ControlStyle   := ControlStyle + [csOpaque] - [csSetCaption];
   fCalendarPopup := TIntlMonthCalendarPopup.Create(Self);
   fCalendarPopup.SetSubComponent(True);
   fCalendarPopup.Name             := 'CalendarPopup';
   fCalendarPopup.OnCloseUp        := PopupCloseUp;
   fCalendarPopup.OnCalendarChange := CalendarChanged;
   fDate                           := Calendar.Today;
   fBorderStyle                    := bsSingle;
   fShowCheckBox                   := False;
   fChecked                        := True;
   ParentColor                     := False;
   Color                           := clWindow;
   TabStop                         := True;
   AutoSize                        := True;
   UpdateText;
  End;

 Destructor TCustomIntlDatePicker.Destroy;
  Begin
   If fTheme <> 0 Then
    CloseThemeData(fTheme);
   Inherited Destroy;
  End;

 Procedure TCustomIntlDatePicker.CalendarChanged(Sender : TObject);
  Begin
   UpdateText;
  End;

 Procedure TCustomIntlDatePicker.PopupCloseUp(Sender : TObject; Accept : Boolean);
  Begin
   If Accept Then
    Date                 := CalendarPopup.Date;
   CalendarPopup.Visible := False;
  End;

 Procedure TCustomIntlDatePicker.SetDate(Const Value : TDate);
  Begin
   If (csDesigning In ComponentState) And Calendar.IsNoDate(Value) Then
    Begin
     Date := Calendar.Today;
     Exit;
    End;
   If Not IsDateInRange(Value) Then
    Begin
     Raise EDateTimeError.CreateResFmt(@SDateOutOfRangeError,
     [Calendar.Format('ddddd', ActualDateMin),
     Calendar.Format('ddddd', ActualDateMax)]);
    End;
   If Not Calendar.IsSameDay(Date, Value) And CanModify Then
    Begin
     fDate := Calendar.DateOf(Value);
     UpdateText;
     Change;
    End;
  End;

 Procedure TCustomIntlDatePicker.SetDateFormat(Const Value : String);
  Begin
   If DateFormat <> Value Then
    Begin
     fDateFormat := Value;
     UpdateText;
    End;
  End;

 Procedure TCustomIntlDatePicker.SetChecked(Value : Boolean);
  Begin
   If (Checked <> Value) And CanModify Then
    Begin
     fChecked := Value;
     If Not Checked And CalendarPopup.Visible Then
      PopupCloseUp(CalendarPopup, False);
     InvalidateCheckBox;
     InvalidateDate;
     Change;
    End;
  End;

 Procedure TCustomIntlDatePicker.SetShowCheckBox(Value : Boolean);
  Begin
   If ShowCheckBox <> Value Then
    Begin
     fShowCheckBox := Value;
     UpdateRects;
    End;
  End;

 Procedure TCustomIntlDatePicker.SetBorderStyle(Value : TBorderStyle);
  Begin
   If BorderStyle <> Value Then
    Begin
     fBorderStyle := Value;
     RecreateWnd;
    End;
  End;

 Function TCustomIntlDatePicker.GetDateMin : TDate;
  Begin
   Result := CalendarPopup.DateMin;
  End;

 Procedure TCustomIntlDatePicker.SetDateMin(Const Value : TDate);
  Begin
   CalendarPopup.DateMin := Value;
  End;

 Function TCustomIntlDatePicker.GetDateMax : TDate;
  Begin
   Result := CalendarPopup.DateMax;
  End;

 Procedure TCustomIntlDatePicker.SetDateMax(Const Value : TDate);
  Begin
   CalendarPopup.DateMax := Value;
  End;

 Function TCustomIntlDatePicker.GetCalendarType : TCalendarClass;
  Begin
   Result := CalendarPopup.CalendarType;
  End;

 Procedure TCustomIntlDatePicker.SetCalendarType(Value : TCalendarClass);
  Begin
   CalendarPopup.CalendarType := Value;
  End;

 Function TCustomIntlDatePicker.GetCulture : TCultureInfo;
  Begin
   Result := CalendarPopup.Culture;
  End;

 Procedure TCustomIntlDatePicker.SetCulture(Value : TCultureInfo);
  Begin
   CalendarPopup.Culture := Value;
  End;

 Function TCustomIntlDatePicker.GetCultureCalendar : TLocalizerSwicth;
  Begin
   Result := CalendarPopup.CultureCalendar;
  End;

 Procedure TCustomIntlDatePicker.SetCultureCalendar(Value : TLocalizerSwicth);
  Begin
   CalendarPopup.CultureCalendar := Value;
  End;

 Function TCustomIntlDatePicker.GetCultureDigits : TLocalizerSwicth;
  Begin
   Result := CalendarPopup.CultureDigits;
  End;

 Procedure TCustomIntlDatePicker.SetCultureDigits(Value : TLocalizerSwicth);
  Begin
   CalendarPopup.CultureDigits := Value;
   UpdateText;
  End;

 Function TCustomIntlDatePicker.GetLocalizer : TLocalizer;
  Begin
   Result := CalendarPopup.Localizer;
  End;

 Procedure TCustomIntlDatePicker.SetLocalizer(Value : TLocalizer);
  Begin
   CalendarPopup.Localizer := Value;
  End;

 Function TCustomIntlDatePicker.GetCalendar : TCalendar;
  Begin
   Result := CalendarPopup.Calendar;
  End;

 Function TCustomIntlDatePicker.GetActualDateMin : TDate;
  Begin
   Result := CalendarPopup.ActualDateMin;
  End;

 Function TCustomIntlDatePicker.GetActualDateMax : TDate;
  Begin
   Result := CalendarPopup.ActualDateMax;
  End;

 Function TCustomIntlDatePicker.GetUsingCultureCalendar : Boolean;
  Begin
   Result := CalendarPopup.UsingCultureCalendar;
  End;

 Function TCustomIntlDatePicker.GetUsingCultureDigits : Boolean;
  Begin
   Result := CalendarPopup.UsingCultureDigits;
  End;

 Function TCustomIntlDatePicker.GetTheme : HTHEME;
  Begin
   If fTheme = 0 Then
    fTheme := OpenThemeData(WindowHandle, 'datepicker');
   Result  := fTheme;
  End;

 Function TCustomIntlDatePicker.IsDateStored : Boolean;
  Begin
   Result := Not Calendar.IsToday(Date);
  End;

 Function TCustomIntlDatePicker.IsDateMinStored : Boolean;
  Begin
   Result := Not Calendar.IsNoDate(DateMin);
  End;

 Function TCustomIntlDatePicker.IsDateMaxStored : Boolean;
  Begin
   Result := Not Calendar.IsNoDate(DateMax);
  End;

 Procedure TCustomIntlDatePicker.ReadCulture(Reader : TReader);
  Begin
   Culture := CultureOf(Reader.ReadString);
  End;

 Procedure TCustomIntlDatePicker.WriteCulture(Writer : TWriter);
  Begin
   Writer.WriteString(Culture.Locale);
  End;

 Procedure TCustomIntlDatePicker.ReadCalendarType(Reader : TReader);
  Begin
   CalendarType := CalendarTypes.ByName(Reader.ReadString);
  End;

 Procedure TCustomIntlDatePicker.WriteCalendarType(Writer : TWriter);
  Begin
   Writer.WriteString(CalendarType.CalendarName);
  End;

 Procedure TCustomIntlDatePicker.DefineProperties(Filer : TFiler);
  Begin
   Inherited DefineProperties(Filer);
   Filer.DefineProperty('CultureInfo', ReadCulture, WriteCulture,
   Not Assigned(Localizer) And Assigned(Culture));
   Filer.DefineProperty('CalendarClass', ReadCalendarType, WriteCalendarType,
   Assigned(CalendarType));
  End;

 Procedure TCustomIntlDatePicker.CreateParams(Var Params : TCreateParams);
  Begin
   Inherited CreateParams(Params);
   If BorderStyle = bsSingle Then
    Begin
     If Ctl3D Then
      Params.ExStyle := Params.ExStyle Or WS_EX_CLIENTEDGE
     Else
      Params.Style := Params.Style Or WS_BORDER;
    End;
  End;

 Procedure TCustomIntlDatePicker.Resize;
  Begin
   Inherited Resize;
   UpdateRects;
  End;

 Function TCustomIntlDatePicker.CanAutoSize(Var NewWidth, NewHeight : Integer) : Boolean;
  Begin
   If AutoSize Then
    NewHeight := GetMinHeight;
   Result     := True;
  End;

 Procedure TCustomIntlDatePicker.MouseDown(Button : TMouseButton; Shift : TShiftState; x, y : Integer);
  Begin
   If Button = mbLeft Then
    Begin
     Case HotInfo Of
      phtCheckBox :
       Begin
        fCheckPressed := True;
        InvalidateCheckBox;
       End;
      phtDropDown, phtDate :
       Begin
        If CalendarPopup.Visible Then
         PopupCloseUp(CalendarPopup, False)
        Else
         PopupDropDown;
       End;
     End;
    End;
   Inherited MouseDown(Button, Shift, x, y);
  End;

 Procedure TCustomIntlDatePicker.MouseMove(Shift : TShiftState; x, y : Integer);
  Var
   TheHitTest : TIntlPickerHitTest;
  Begin
   TheHitTest := GetHitTestInfoAt(x, y);
   If TheHitTest <> HotInfo Then
    Begin
     Case HotInfo Of
      phtCheckBox : InvalidateCheckBox;
      phtDropDown : InvalidateDropDown;
     End;
     fHotInfo := TheHitTest;
     Case HotInfo Of
      phtCheckBox : InvalidateCheckBox;
      phtDropDown : InvalidateDropDown;
     End;
    End;
   Inherited MouseMove(Shift, x, y);
  End;

 Procedure TCustomIntlDatePicker.MouseUp(Button : TMouseButton; Shift : TShiftState; x, y : Integer);
  Begin
   If Button = mbLeft Then
    Begin
     If CheckPressed Then
      Begin
       If HotInfo = phtCheckBox Then
        Checked := Not Checked
       Else
        InvalidateCheckBox;
      End;
     fCheckPressed := False;
    End;
   Inherited MouseUp(Button, Shift, x, y);
  End;

 Function TCustomIntlDatePicker.DoMouseWheelDown(Shift : TShiftState; MousePos : TPoint) : Boolean;
  Begin
   Result := Inherited DoMouseWheelDown(Shift, MousePos);
   If Not Result Then
    Begin
     Date   := EnsureDateInRange(Calendar.NextDay(Date));
     Result := True;
    End;
  End;

 Function TCustomIntlDatePicker.DoMouseWheelUp(Shift : TShiftState; MousePos : TPoint) : Boolean;
  Begin
   Result := Inherited DoMouseWheelUp(Shift, MousePos);
   If Not Result Then
    Begin
     Date   := EnsureDateInRange(Calendar.PrevDay(Date));
     Result := True;
    End;
  End;

 Procedure TCustomIntlDatePicker.KeyDown(Var Key : Word; Shift : TShiftState);
  Begin
   Inherited KeyDown(Key, Shift);
   If CalendarPopup.Visible Then
    Begin
     CalendarPopup.KeyDown(Key, Shift);
     Exit;
    End;
   Case Key Of
    VK_DOWN :
     Begin
      If ssAlt In Shift Then
       PopupDropDown
      Else
       Date := EnsureDateInRange(Calendar.NextDay(Date));
      Key   := 0;
     End;
    VK_UP :
     Begin
      Date := EnsureDateInRange(Calendar.PrevDay(Date));
      Key  := 0;
     End;
    VK_NEXT :
     Begin
      Date := EnsureDateInRange(Calendar.NextMonth(Date));
      Key  := 0;
     End;
    VK_PRIOR :
     Begin
      Date := EnsureDateInRange(Calendar.PrevMonth(Date));
      Key  := 0;
     End;
    VK_SPACE :
     Begin
      If ShowCheckBox Then
       Checked := Not Checked;
      Key      := 0;
     End;
   End;
  End;

 Function TCustomIntlDatePicker.CanModify : Boolean;
  Begin
   Result := True;
  End;

 Procedure TCustomIntlDatePicker.Paint;
  Const
   CheckStates : Array[Boolean] Of TCheckBoxState = (cbUnchecked, cbChecked);
  Var
   DrawState           : TPartDrawState;
   DrawFlags           : Cardinal;
   TextRect, FocusRect : TRect;
   StateId             : Integer;
  Begin
   // check box
   If ShowCheckBox And RectVisible(Canvas.Handle, fCheckBoxRect) Then
    Begin
     If Enabled Then
      If HotInfo = phtCheckBox Then
       If CheckPressed Then
        DrawState := pdsPressed
       Else
        DrawState := pdsHot
      Else
       DrawState := pdsNormal
     Else
      DrawState    := pdsDisabled;
     fCheckBoxRect := DrawCheckBox(Canvas.Handle, fCheckBoxRect,
     CheckStates[Checked], DrawState, False, ThemeControl(Self));
    End;
   // drop down
   If RectVisible(Canvas.Handle, fDropDownRect) Then
    Begin
     If Enabled Then
      If CalendarPopup.Visible Then
       DrawState := pdsPressed
      Else If HotInfo = phtDropDown Then
       DrawState := pdsHot
      Else
       DrawState := pdsNormal
     Else
      DrawState := pdsDisabled;
     DrawDropDown(Canvas.Handle, fDropDownRect, DrawState, ThemeControl(Self));
    End;
   // content
   If RectVisible(Canvas.Handle, fDateRect) Then
    Begin
     Canvas.Font        := Font;
     Canvas.Brush.Color := Color;
     Canvas.FillRect(fDateRect);
     TextRect := fDateRect;
     InflateRect(TextRect, -2, 0);
     DrawFlags := DrawTextBiDiModeFlags(DT_LEFT Or DT_VCENTER Or DT_NOPREFIX Or DT_SINGLELINE);
     If CalendarPopup.IsThemed Then
      Begin
       If Checked And Enabled Then
        StateId := DPDT_NORMAL
       Else
        StateId := DPDT_DISABLED;
       DrawThemeText(Theme, Canvas.Handle, DP_DATETEXT, StateId, PChar(Caption), Length(Caption), DrawFlags, 0, TextRect);
      End
     Else
      Begin
       If Not(Checked And Enabled) Then
        Canvas.Font.Color := clGrayText;
       DrawText(Canvas.Handle, PChar(Caption), Length(Caption), TextRect, DrawFlags);
      End;
     If Focused And Not CalendarPopup.Visible Then
      Begin
       FillChar(FocusRect, SizeOf(FocusRect), 0);
       DrawText(Canvas.Handle, PChar(Caption), Length(Caption), FocusRect, DrawFlags Or DT_CALCRECT);
       OffsetRect(FocusRect, 0, (TextRect.Top + TextRect.Bottom - FocusRect.Bottom) Div 2);
       If UseRightToLeftAlignment Then
        OffsetRect(FocusRect, TextRect.Right - FocusRect.Right, 0)
       Else
        OffsetRect(FocusRect, TextRect.Left, 0);
       InflateRect(FocusRect, 2, 4);
       SetTextColor(Canvas.Handle, ColorToRGB(Font.Color));
       Canvas.DrawFocusRect(FocusRect);
      End;
    End;
  End;

 Procedure TCustomIntlDatePicker.UpdateText;
  Begin
   Caption := CalendarPopup.Format(DateFormat, Date);
   InvalidateDate;
  End;

 Procedure TCustomIntlDatePicker.UpdateRects;
  Var
   Rect : TRect;
  Begin
   If Not HandleAllocated Then
    Exit;
   Rect          := ClientRect;
   fDateRect     := Rect;
   fDropDownRect := Rect;
   fCheckBoxRect := Rect;
   If UseRightToLeftAlignment Then
    Begin
     fDropDownRect.Right := fDropDownRect.Left + GetDropDownSize.cx;
     fDateRect.Left      := fDropDownRect.Right + 2;
     If fShowCheckBox Then
      Begin
       fCheckBoxRect.Left := fCheckBoxRect.Right - GetCheckBoxSize.cx - 4;
       fDateRect.Right    := fCheckBoxRect.Left - 2;
      End;
    End
   Else
    Begin
     fDropDownRect.Left := fDropDownRect.Right - GetDropDownSize.cx;
     fDateRect.Right    := fDropDownRect.Left - 2;
     If fShowCheckBox Then
      Begin
       fCheckBoxRect.Right := fCheckBoxRect.Left + GetCheckBoxSize.cx + 4;
       fDateRect.Left      := fCheckBoxRect.Right + 2;
      End;
    End;
   Invalidate;
  End;

 Function TCustomIntlDatePicker.GetMinHeight : Integer;
  Var
   DC      : HDC;
   OldFont : HFONT;
   Metrics : TTextMetric;
  Begin
   DC := GetDC(WindowHandle);
   Try
    OldFont := SelectObject(DC, Font.Handle);
    GetTextMetrics(DC, Metrics);
    SelectObject(DC, OldFont);
   Finally
    ReleaseDC(WindowHandle, DC);
   End;
   Result := Metrics.tmHeight + (Height - ClientHeight) + 4;
   If Result < GetDropDownSize.cy Then
    Result := GetDropDownSize.cy;
   If ShowCheckBox And (Result < GetCheckBoxSize.cy) Then
    Result := GetCheckBoxSize.cy;
  End;

 Function TCustomIntlDatePicker.GetHitTestInfoAt(x, y : Integer) : TIntlPickerHitTest;
  Var
   Pt : TPoint;
  Begin
   Pt.x := x;
   Pt.y := y;
   If ShowCheckBox And PtInRect(fCheckBoxRect, Pt) Then
    Result := phtCheckBox
   Else If PtInRect(fDropDownRect, Pt) Then
    Result := phtDropDown
   Else If PtInRect(fDateRect, Pt) Then
    Result := phtDate
   Else If PtInRect(ClientRect, Pt) Then
    Result := phtControl
   Else
    Result := phtNowhere;
  End;

 Procedure TCustomIntlDatePicker.InvalidateCheckBox;
  Begin
   If ShowCheckBox And HandleAllocated Then
    InvalidateRect(WindowHandle, fCheckBoxRect, False);
  End;

 Procedure TCustomIntlDatePicker.InvalidateDropDown;
  Begin
   If HandleAllocated Then
    InvalidateRect(WindowHandle, fDropDownRect, False);
  End;

 Procedure TCustomIntlDatePicker.InvalidateDate;
  Begin
   If HandleAllocated Then
    InvalidateRect(WindowHandle, fDateRect, False);
  End;

 Procedure TCustomIntlDatePicker.InvalidateFrame;
  Begin
   If ThemeControl(Self) And HandleAllocated Then
    RedrawWindow(WindowHandle, Nil, 0, RDW_FRAME Or RDW_INVALIDATE Or RDW_UPDATENOW);
  End;

 Procedure TCustomIntlDatePicker.PopupDropDown;
  Var
   TopLeft    : TPoint;
   x, y, w, h : Integer;
   Monitor    : TMonitor;
  Begin
   If Enabled And CanModify And Not CalendarPopup.Visible Then
    Begin
     Monitor := Screen.MonitorFromWindow(Handle);
     CalendarPopup.HandleNeeded;
     TopLeft := Parent.ClientToScreen(Point(Left, Top));
     CalendarPopup.GetPreferredControlSize(w, h);
     If w < Width Then
      w := Width;
     If UseRightToLeftAlignment Then
      x := TopLeft.x + Width - w
     Else
      x := TopLeft.x;
     If x < Monitor.Left Then
      x := Monitor.Left
     Else If x + w > Monitor.Left + Monitor.Width Then
      x := Monitor.Left + Monitor.Width - w;
     y  := TopLeft.y + Height;
     If y + h > Monitor.Top + Monitor.Height Then
      y                 := TopLeft.y - h;
     CalendarPopup.Date := Date;
     Checked            := True;
     CalendarPopup.SetBounds(x, y, w, h);
     CalendarPopup.Show(x, y);
     InvalidateDropDown;
     InvalidateDate;
    End;
  End;

 Procedure TCustomIntlDatePicker.Change;
  Begin
   If Assigned(OnChange) Then
    OnChange(Self);
  End;

 Procedure TCustomIntlDatePicker.WMNCPaint(Var Message : TWMNCPaint);
  Var
   DC      : HDC;
   StateId : Integer;
   Rect    : TRect;
  Begin
   Inherited;
   If (BorderStyle = bsSingle) And ThemeControl(Self) Then
    Begin
     Rect := BoundsRect;
     OffsetRect(Rect, -Rect.Left, -Rect.Top);
     If Enabled Then
      If Focused Then
       StateId := DPDB_FOCUSED
      Else If HotInfo <> phtNowhere Then
       StateId := DPDB_HOT
      Else
       StateId := DPDB_NORMAL
     Else
      StateId := DPDB_DISABLED;
     DC       := GetWindowDC(WindowHandle);
     Try
      ExcludeClipRect(DC, Rect.Left + 2, Rect.Top + 2, Rect.Right - 2, Rect.Bottom - 2);
      DrawThemeBackground(Theme, DC, DP_DATEBORDER, StateId, Rect, Nil);
     Finally
      ReleaseDC(WindowHandle, DC);
     End;
    End;
  End;

 Procedure TCustomIntlDatePicker.WMMouseActivate(Var Message : TWMMouseActivate);
  Begin
   Inherited;
   If CanFocus Then
    SetFocus;
  End;

 Procedure TCustomIntlDatePicker.WMSetFocus(Var Message : TWMSetFocus);
  Begin
   Inherited;
   InvalidateDate;
   InvalidateFrame;
  End;

 Procedure TCustomIntlDatePicker.WMKillFocus(Var Message : TWMKillFocus);
  Begin
   Inherited;
   If CalendarPopup.Visible Then
    PopupCloseUp(CalendarPopup, False);
   InvalidateDate;
   InvalidateFrame;
  End;

 Procedure TCustomIntlDatePicker.WMGetDlgCode(Var Message : TWMGetDlgCode);
  Begin
   Message.Result := DLGC_WANTARROWS;
  End;

 Procedure TCustomIntlDatePicker.CMEnableChanged(Var Message : TMessage);
  Begin
   Inherited;
   Invalidate;
  End;

 Procedure TCustomIntlDatePicker.CMBiDiModeChanged(Var Message : TMessage);
  Begin
   Inherited;
   UpdateRects;
  End;

 Procedure TCustomIntlDatePicker.CMBorderChanged(Var Message : TMessage);
  Begin
   Inherited;
   AdjustSize;
   InvalidateFrame;
  End;

 Procedure TCustomIntlDatePicker.CMCtl3DChanged(Var Message : TMessage);
  Begin
   Inherited;
   AdjustSize;
   InvalidateFrame;
  End;

 Procedure TCustomIntlDatePicker.CMCancelMode(Var Message : TCMCancelMode);
  Begin
   If (Message.Sender <> Self) And (Message.Sender <> CalendarPopup) And
   CalendarPopup.Visible And Not CalendarPopup.ContainsControl(Message.Sender)
   Then
    PopupCloseUp(CalendarPopup, False);
  End;

 Procedure TCustomIntlDatePicker.CMMouseEnter(Var Message : TMessage);
  Begin
   Inherited;
   fHotInfo := phtControl;
   InvalidateFrame;
  End;

 Procedure TCustomIntlDatePicker.CMMouseLeave(Var Message : TMessage);
  Begin
   Case HotInfo Of
    phtCheckBox : InvalidateCheckBox;
    phtDropDown : InvalidateDropDown;
   End;
   fHotInfo := phtNowhere;
   InvalidateFrame;
   Inherited;
  End;

 Function TCustomIntlDatePicker.IsManagedByLocalizer : Boolean;
  Begin
   Result := Assigned(Localizer);
  End;

 Function TCustomIntlDatePicker.IsYearInRange(AEra, AYear : Integer) : Boolean;
  Begin
   Result := CalendarPopup.IsYearInRange(AEra, AYear);
  End;

 Function TCustomIntlDatePicker.IsYearInRange(AYear : Integer) : Boolean;
  Begin
   Result := CalendarPopup.IsYearInRange(AYear);
  End;

 Function TCustomIntlDatePicker.IsMonthInRange(AEra, AYear, AMonth : Integer) : Boolean;
  Begin
   Result := CalendarPopup.IsMonthInRange(AEra, AYear, AMonth);
  End;

 Function TCustomIntlDatePicker.IsMonthInRange(AYear, AMonth : Integer) : Boolean;
  Begin
   Result := CalendarPopup.IsMonthInRange(AYear, AMonth);
  End;

 Function TCustomIntlDatePicker.IsDateInRange(Const ADate : TDate) : Boolean;
  Begin
   Result := CalendarPopup.IsDateInRange(ADate);
  End;

 Function TCustomIntlDatePicker.EnsureDateInRange(Const ADate : TDate) : TDate;
  Begin
   Result := CalendarPopup.EnsureDateInRange(ADate);
  End;

End.
