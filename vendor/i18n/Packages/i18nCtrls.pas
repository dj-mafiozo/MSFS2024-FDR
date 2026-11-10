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
/// This unit implements controls that represent locales, countries, and currencies.
/// </summary>
Unit i18nCtrls;

{$I DELPHIAREA.INC}

Interface

 Uses
  Windows, Messages, Classes, Contnrs, Graphics, Controls, StdCtrls, ImgList,
  {$IFDEF COMPILER_XE3_UP} UITypes, {$ENDIF}
  i18nCore, i18nLocalizer, i18nHashList;

 Type

  {$IFNDEF COMPILER_XE2_UP}
  TListBoxItemData = TCustomLongData;
{$ENDIF}
{$Region 'xmldoc'}
/// <summary>
/// This enumeration type identifies the ways that the display parts of a control
/// can be rendered.
/// </summary>
{$Endregion}

  TPartDrawState = (
  {$Region 'xmldoc'}
  /// Render as normal.
  {$Endregion}
  pdsNormal,
  {$Region 'xmldoc'}
  /// The mouse pointer is over the control's part; render in hot state.
  {$Endregion}
  pdsHot,
  {$Region 'xmldoc'}
  /// The user has pressed the control's part; render in pressed state.
  {$Endregion}
  pdsPressed,
  {$Region 'xmldoc'}
  /// The control's part is disabled; render as disabled.
  {$Endregion}
  pdsDisabled
  );

{$Region 'xmldoc'}
/// <summary>
/// This enumeration type identifies the possible locations of a pixel that
/// specifies the transparent color of a bitmap.
/// </summary>
{$Endregion}

  TTransparentPixel = (
  {$Region 'xmldoc'}
  /// There is no transparent color.
  {$Endregion}
  tpNone,
  {$Region 'xmldoc'}
  /// The color of the pixel at the top-left corner of the bitmap image is the transparent color.
  {$Endregion}
  tpTopLeft,
  {$Region 'xmldoc'}
  /// The color of the pixel at the top-right corner of the bitmap image is the transparent color.
  {$Endregion}
  tpTopRight,
  {$Region 'xmldoc'}
  /// The color of the pixel at the bottom-right corner of the bitmap image is the transparent color.
  {$Endregion}
  tpBottomRight,
  {$Region 'xmldoc'}
  /// The color of the pixel at the bottom-left corner of the bitmap image is the transparent color.
  {$Endregion}
  tpBottomLeft
  );

{$Region 'xmldoc'}
/// <summary>
/// TCustomFlagImageList is the base class for collections of same-sized country flag
/// images, each of which can be referred to by its index or international country code.
/// </summary>
/// <remarks>
/// The flag image list is a special image list that stores a collection of icons or
/// bitmaps, which are country flags. The flag image list has methods to facilitate
/// retrieving and drawing of the stored flag images.
///
/// Use TCustomFlagImageList as a base class for image lists that store images of
/// country flags.
/// </remarks>
{$Endregion}

    TCustomFlagImageList = Class Abstract(TCustomImageList)
   Private
    Regions  : TKeyLookup<String, Integer>;
    HelperDC : HDC;
    {$IFDEF COMPILER2010_UP}
    Function GetColorDepth : TColorDepth;
    Procedure SetColorDepth(Value : TColorDepth);
    {$ENDIF}
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Prevents bitmap data from being saved and loaded.
    /// </summary>
    /// <param name="Filer">
    /// The current <see cref="TReader"/> or <see cref="TWriter"/> object that is
    /// loading or saving the flag images.
    /// </param>
    {$Endregion}
    Procedure DefineProperties(Filer : TFiler); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Resizes a bitmap specified by its handle to be the same size as the flag
    /// image list entries. This method also makes the color specified by its pixel
    /// location transparent.
    /// </summary>
    /// <param name="hImage">
    /// Handle of the bitmap image.
    /// </param>
    /// <param name="TransparentPixel">
    /// The pixel location of the transparent color.
    /// </param>
    /// <see cref="NormalizeFlag"/>
    {$Endregion}
    Procedure NormalizeImage(Var hImage : HBITMAP; TranparentPixel : TTransparentPixel = tpNone);
    {$Region 'xmldoc'}
    /// <summary>
    /// Checks the size of the flag image specified by its handle. If the image's size
    /// is not the same size as the image list entries, it resizes the image. This
    /// method also makes non-rectangular flags (for example, Nepal's flag) transparent.
    ///
    /// NormalizeFlag calls <see cref="NormalizeImage"/> to resize the flag image and
    /// make it transparent.
    /// </summary>
    /// <param name="hImage">
    /// Handle of the flag's bitmap image.
    /// </param>
    /// <param name="ISO_3166_2">
    /// Two-character international country code of the flag.
    /// </param>
    /// <see cref="NormalizeImage"/>
    {$Endregion}
    Procedure NormalizeFlag(Var hImage : HBITMAP; Const ISO_3166_2 : String); Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Adds the flag image of a country/region specified by its two-character ISO 3166/2
    /// international country code.
    ///
    /// AddFlag calls <see cref="NormalizeFlag"/> to resize the image to the size of
    /// image list entries, and make it transparent as well.
    /// </summary>
    /// <param name="ISO_3166_2">
    /// Two-character international country code of the flag.
    /// </param>
    /// <param name="hImage">
    /// Handle of the flag's bitmap image.
    /// </param>
    /// <returns>
    /// Index of the newly added flag in the image list.
    /// </returns>
    {$Endregion}
    Function AddFlag(Const ISO_3166_2 : String; hImage : HBITMAP) : Integer;
    {$Region 'xmldoc'}
    /// <summary>
    /// Sets the size of image list entries and adds flag images to it.
    /// </summary>
    {$Endregion}
    Procedure PrepareFlags; Virtual; Abstract;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the component.
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
    /// Finds the index of a flag image represented by its two-character ISO 3166/2
    /// international country code.
    /// </summary>
    /// <param name="ISO_3166_2">
    /// Two-character international country code of the flag.
    /// </param>
    /// <returns>
    /// Index of the flag image or -1 if the flag is not found.
    /// </returns>
    {$Endregion}
    Function ImageIndexOf(Const ISO_3166_2 : String) : Integer; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Finds the index of a flag image represented by its <see cref="TTerritoryInfo"/> object.
    /// </summary>
    /// <param name="Territory">
    /// The <see cref="TTerritoryInfo"/> object
    /// </param>
    /// <returns>
    /// Index of the flag image or -1 if the flag is not found.
    /// </returns>
    {$Endregion}
    Function ImageIndexOf(Territory : TTerritoryInfo) : Integer; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Finds the index of a flag image represented by its <see cref="TCultureInfo"/> object.
    /// </summary>
    /// <param name="Culture">
    /// The <see cref="TCultureInfo"/> object
    /// </param>
    /// <returns>
    /// Index of the flag image or -1 if the flag is not found.
    /// </returns>
    {$Endregion}
    Function ImageIndexOf(Culture : TCultureInfo) : Integer; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Finds the index of a flag image represented by its <see cref="TCurrencyInfo"/> object.
    /// </summary>
    /// <param name="Currency">
    /// The <see cref="TCurrencyInfo"/> object
    /// </param>
    /// <returns>
    /// Index of the flag image or -1 if the flag is not found.
    /// </returns>
    {$Endregion}
    Function ImageIndexOf(Currency : TCurrencyInfo) : Integer; Overload;
   Published
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the number of bits per pixel used for colors of the flag images.
    /// </summary>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Property ColorDepth : TColorDepth Read GetColorDepth Write SetColorDepth Default cdDeviceDependent;
    {$ENDIF}
  End;

{$Region 'xmldoc'}
/// <summary>
/// TCustomResFlagImageList is the base class for those flag image lists components,
/// which load the country flag images from an application's resource.
/// </summary>
/// <remarks>
/// The flag image list is a special image list that stores a collection of icons or
/// bitmaps, which are country flags. The flag image list has methods to facilitate
/// retrieving and drawing of the stored flag images.
///
/// Use TCustomResFlagImageList as a base class when defining flag image lists that
/// load the flag images from the application's resource. TCustomResFlagImageList
/// expects each image to be a bitmap resource named as <c>PREFIXcc</c>, where
/// <c>PREFIX</c> is a custom prefix shared with all flag images, and <c>cc</c> is the
/// two-character ISO 3166/2 international country code of the flag image.
/// </remarks>
{$Endregion}

  TCustomResFlagImageList = Class(TCustomFlagImageList)
   Private
    Function AddFlagFromResource(Const ISO_3166_2 : String; Const ResName : String; hModule : hModule = 0) : Integer;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the size of each individual flag image in pixels.
    /// </summary>
    /// <returns>
    /// The width and height of the image list entries.
    /// </returns>
    {$Endregion}
    Function GetFlagSize : TSize; Virtual; Abstract;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the prefix used in the name of each flag's bitmap resource.
    /// </summary>
    /// <returns>
    /// The prefix of bitmap resource names.
    /// </returns>
    {$Endregion}
    Function GetResourcePrefix : String; Virtual; Abstract;
    {$Region 'xmldoc'}
    /// <summary>
    /// Sets the size of image list entries and loads flag images from the application
    /// resource.
    /// </summary>
    {$Endregion}
    Procedure PrepareFlags; Override;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TFlagImageList is a special image list component that provides country flag
/// icons.
/// </summary>
/// <remarks>
/// The flag image list is a special image list that stores a collection of icons or
/// bitmaps, which are country flags. The flag image list has methods to facilitate
/// retrieving and drawing of the stored flag images.
///
/// The size of flag icons provided by TFlagImageList is 16 by 11 pixels.
/// </remarks>
/// <group name="Components"/>
{$Endregion}
{$IFDEF COMPILER_XE2_UP}

  [ComponentPlatformsAttribute(pidWin32 Or pidWin64)]
  {$ENDIF}
  TFlagImageList = Class(TCustomResFlagImageList)
   Protected
    Function GetFlagSize : TSize; Override;
    Function GetResourcePrefix : String; Override;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TCustomImageLabel is the base class for label controls that can include an image
/// on their face.
/// </summary>
/// <remarks>
/// Use TCustomImageLabel as a base class when defining objects that display an icon
/// followed by a text on a form. TCustomImageLabel implements properties to specify
/// the icon from an image list component, along with its appearance and placement on
/// the label.
/// </remarks>
{$Endregion}

    TCustomImageLabel = Class Abstract(TCustomLabel)
   Private
    fSpacing     : Integer;
    fImageIndex  : TImageIndex;
    fPadding     : TPadding;
    fBorderWidth : TBorderWidth;
    fBorderColor : TColor;
    fImages      : TCustomImageList;
    fImagesLink  : TChangeLink;
    Procedure SetSpacing(Value : Integer);
    Procedure SetPadding(Value : TPadding);
    Procedure SetBorderWidth(Value : TBorderWidth);
    Procedure SetBorderColor(Value : TColor);
    Procedure SetImages(Value : TCustomImageList);
    Procedure ImagesChanged(Sender : TObject);
    Procedure PaddingChanged(Sender : TObject);
    Procedure CNVisibleChanged(Var Message : TMessage); Message CM_VISIBLECHANGED;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Responds to notifications that components are about to be created or destroyed.
    /// </summary>
    /// <param name="AComponent">
    /// The component that generated the notification.
    /// </param>
    /// <param name="Operation">
    /// Indicates whether the component is created or destroyed.
    /// </param>
    {$Endregion}
    Procedure Notification(AComponent : TComponent; Operation : TOperation); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Draws the label's caption along with its image on a specified rectangle.
    /// </summary>
    /// <param name="Rect">
    /// Specifies the boundaries of the text and the image within the client area.
    /// </param>
    /// <param name="DrawFlags">
    /// Flags for Windows API function, DrawText.
    /// </param>
    {$Endregion}
    Procedure DoDrawText(Var Rect : TRect; DrawFlags : LongInt); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the index of the label's image in the <see cref="Images"/> image list.
    /// </summary>
    /// <returns>
    /// The index of the label's image in the image list or -1 if there is no image.
    /// </returns>
    /// <seealso cref="SetImageIndex"/>
    {$Endregion}
    Function GetImageIndex : TImageIndex; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Updates the label's image by specifying its index in the <see cref="Images"/> image list.
    /// </summary>
    /// <param name="Value">
    /// The index of the label's image in the image list or -1 if there is no image.
    /// </param>
    /// <seealso cref="GetImageIndex"/>
    {$Endregion}
    Procedure SetImageIndex(Value : TImageIndex); Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Resizes the label when the text or image changes.
    /// </summary>
    {$Endregion}
    Procedure AdjustBounds; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Draws the text and image of the label's client area.
    /// </summary>
    {$Endregion}
    Procedure Paint; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the color of the control's border.
    /// </summary>
    {$Endregion}
    Property BorderColor : TColor Read fBorderColor Write SetBorderColor Default clNone;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the width of the control's border.
    /// </summary>
    {$Endregion}
    Property BorderWidth : TBorderWidth Read fBorderWidth Write SetBorderWidth Default 0;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets which image is displayed as the icon on the label.
    /// </summary>
    {$Endregion}
    Property ImageIndex : TImageIndex Read GetImageIndex Write SetImageIndex Default - 1;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the images that can appear on the control.
    /// </summary>
    {$Endregion}
    Property Images : TCustomImageList Read fImages Write SetImages;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the number of pixels between the image and the text of the control.
    /// </summary>
    {$Endregion}
    Property Spacing : Integer Read fSpacing Write SetSpacing Default 4;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the distance between the image and the text from the control's border.
    /// </summary>
    {$Endregion}
    Property Padding : TPadding Read fPadding Write SetPadding;
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
  End;

{$Region 'xmldoc'}
/// <summary>
/// TImageLabel is a label control that can include an image on its face.
/// </summary>
/// <remarks>
/// Use TImageLabel to display an icon followed by text on a form. The <see cref="ImageIndex"/>
/// property determines which image of the image list identified by the <see cref="Images"/>
/// property will be displayed.
///
/// TImageLabel control can have a border. The <see cref="BorderColor"/> and
/// <see cref="BorderWidth"/> properties determine the color and thickness of the
/// border.
///
/// TImageLabel publishes many of the properties, events, and methods of
/// <see cref="TCustomImageLabel"/>, but does not introduce any new behavior.
/// </remarks>
/// <group name="Components"/>
{$Endregion}
{$IFDEF COMPILER_XE2_UP}

  [ComponentPlatformsAttribute(pidWin32 Or pidWin64)]
  {$ENDIF}
  TImageLabel = Class(TCustomImageLabel)
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
    /// Gets or sets the text of the label.
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
/// TCustomFlagLabel is the base class for label controls that display a country
/// flag icon on their face.
/// </summary>
/// <remarks>
/// Use TCustomFlagLabel as a base class when defining objects that display a country
/// flag icon followed by text on a form. TCustomFlagLabel implements properties that
/// specify the flag icon from a flag image list component, along with its appearance
/// and placement on the label.
/// </remarks>
{$Endregion}

    TCustomFlagLabel = Class Abstract(TCustomImageLabel)
   Private
    Procedure SetFlags(Value : TCustomFlagImageList);
    Function GetFlags : TCustomFlagImageList;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the flag icons that can appear on the control.
    /// </summary>
    {$Endregion}
    Property Flags : TCustomFlagImageList Read GetFlags Write SetFlags;
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
  End;

{$Region 'xmldoc'}
/// <summary>
/// This enumeration type identifies the possible locations of a country flag
/// icon in regard to a text label.
/// </summary>
{$Endregion}

  TFlagPosition = (
  {$Region 'xmldoc'}
  /// The country flag is placed before the text label.
  {$Endregion}
  fpBeforeLabel,
  {$Region 'xmldoc'}
  /// The country flag is placed after the text label.
  {$Endregion}
  fpAfterLabel
  );

{$Region 'xmldoc'}
/// <summary>
/// TCustomDrawItemLabelEvent is the type for event handlers that respond when the label of
/// a list item is being rendered.
/// </summary>
/// <param name="Sender">
/// The object that generated the event.
/// </param>
/// <param name="Index">
/// The index of the item whose label is being rendered.
/// </param>
/// <param name="Rect">
/// The bounding rectangle of the item's label on the control's canvas.
/// </param>
/// <param name="State">
/// The state information that can affect the way the item is drawn.
/// </param>
/// <param name="TheLabel">
/// The text of the item's label.
/// </param>
/// <param name="DefaultDraw">
/// Indicates whether the default rendering should proceed after
/// the event handler exits.
/// </param>
{$Endregion}

  TCustomDrawItemLabelEvent = Procedure(Sender : TObject; Index : Integer; Var Rect : TRect; State : TOwnerDrawState; Var TheLabel : String; Var DefaultDraw : Boolean) Of Object;

{$Region 'xmldoc'}
/// <summary>
/// TCustomFlagBox is the base class for combo box controls that represent a list
/// of country/region related items.
/// </summary>
/// <remarks>
/// Use TCustomFlagBox as a base class when defining combo box controls that represent a
/// list of country/region related items. TCustomFlagBox implements properties to specify
/// a country flag icon, along with its appearance and placement for each individual item.
/// </remarks>
{$Endregion}

    TCustomFlagBox = Class Abstract(TCustomComboBox)
   Private
    fSorted             : Boolean;
    fFlags              : TCustomFlagImageList;
    fFlagPosition       : TFlagPosition;
    fStandardItemHeight : Integer;
    fItemIndex          : Integer;
    fItemsReady         : Boolean;
    fOnDrawItemLabel    : TCustomDrawItemLabelEvent;
    fOnItemsChange      : TNotifyEvent;
    fFlagsLink          : TChangeLink;
    Procedure SetSorted(Value : Boolean);
    Procedure SetFlagPosition(Value : TFlagPosition);
    Procedure SetFlags(Value : TCustomFlagImageList);
    Procedure FlagsChanged(Sender : TObject);
    Procedure ResetItemHeight;
    Procedure CMFontChanged(Var Message : TMessage); Message CM_FONTCHANGED;
    Procedure CMEnter(Var Message : TMessage); Message CM_ENTER;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Renders an individual item in the control.
    /// </summary>
    /// <param name="Index">
    /// The index of the item to draw.
    /// </param>
    /// <param name="Rect">
    /// The boundaries of the item on the control's canvas, in client coordinates.
    /// </param>
    /// <param name="State">
    /// The state information that can affect the way the item is drawn.
    /// </param>
    {$Endregion}
    Procedure DrawItem(Index : Integer; Rect : TRect; State : TOwnerDrawState); Override;
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
    /// Initializes the window-creation parameter record.
    /// </summary>
    /// <param name="Params">
    /// The window-creation parameter record.
    /// </param>
    {$Endregion}
    Procedure CreateParams(Var Params : TCreateParams); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates the underlying Windows control that implements the control.
    /// </summary>
    {$Endregion}
    Procedure CreateWnd; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Regenerates the internal list of items.
    /// </summary>
    {$Endregion}
    Procedure RebuildInternalItems; Virtual; Abstract;
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnDrawItemLabel"/> event.
    /// </summary>
    /// <param name="Index">
    /// The index of the item, which its label is being rendered.
    /// </param>
    /// <param name="Rect">
    /// The bounding rectangle of the item's label on the countrl's canvas.
    /// </param>
    /// <param name="State">
    /// The drawing state of the item.
    /// </param>
    /// <param name="TheLabel">
    /// The text of the item's label.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the default rendering should proceed after
    /// the method exits, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function DoDrawItemLabel(Index : Integer; Var Rect : TRect; State : TOwnerDrawState; Var TheLabel : String) : Boolean; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnItemsChange"/> event.
    /// </summary>
    {$Endregion}
    Procedure DoItemsChange; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the standard height of each item, in pixels.
    /// </summary>
    /// <returns>
    /// The height of each item, in pixels.
    /// </returns>
    {$Endregion}
    Function GetStandardItemHeight : Integer; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the index of the selected item.
    /// </summary>
    /// <returns>
    /// The index of the selected item.
    /// </returns>
    /// <seealso cref="SetItemIndex"/>
    {$Endregion}
    Function GetItemIndex : Integer; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Selects an item specified by its index.
    /// </summary>
    /// <param name="Value">
    /// The index of item to select.
    /// </param>
    /// <seealso cref="GetItemIndex"/>
    {$Endregion}
    Procedure SetItemIndex(Const Value : Integer); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns an image to display for a particular item.
    /// </summary>
    /// <param name="Index">
    /// The index of the item.
    /// </param>
    /// <returns>
    /// The index of an image.
    /// </returns>
    {$Endregion}
    Function GetImageIndex(Index : Integer) : Integer; Virtual; Abstract;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a text label to display for a particular item.
    /// </summary>
    /// <param name="Index">
    /// The index of the item.
    /// </param>
    /// <returns>
    /// The text label.
    /// </returns>
    {$Endregion}
    Function GetLabelText(Index : Integer) : String; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the standard height of each item, in pixels.
    /// </summary>
    {$Endregion}
    Property StandardItemHeight : Integer Read fStandardItemHeight;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets whether the internal list of items is generated.
    /// </summary>
    {$Endregion}
    Property ItemsReady : Boolean Read fItemsReady;
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
    /// Fills the list with all the possible items.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> if the method succeeded, otherwise returns
    /// <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function CollectAll : Boolean; Virtual; Abstract;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the placement of the country flag icon in regard of the text label.
    /// </summary>
    {$Endregion}
    Property FlagPosition : TFlagPosition Read fFlagPosition Write SetFlagPosition Default fpBeforeLabel;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the flag icons that can appear on the control.
    /// </summary>
    {$Endregion}
    Property Flags : TCustomFlagImageList Read fFlags Write SetFlags;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the items in the list are arranged alphabetically.
    /// </summary>
    {$Endregion}
    Property Sorted : Boolean Read fSorted Write SetSorted Default False;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when text label of an item needs to be displayed.
    /// </summary>
    {$Endregion}
    Property OnDrawItemLabel : TCustomDrawItemLabelEvent Read fOnDrawItemLabel Write fOnDrawItemLabel;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the list is changed.
    /// </summary>
    {$Endregion}
    Property OnItemsChange : TNotifyEvent Read fOnItemsChange Write fOnItemsChange;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TCustomFlagListBox is the base class for list box controls that represent a list
/// of country/region related items.
/// </summary>
/// <remarks>
/// Use TCustomFlagListBox as a base class when defining list box controls that represent a
/// list of country/region related items. TCustomFlagListBox implements properties to specify
/// a country flag icon, along with its appearance and placement for each individual item.
/// </remarks>
{$Endregion}

    TCustomFlagListBox = Class Abstract(TCustomListBox)
   Private
    fSorted             : Boolean;
    fFlags              : TCustomFlagImageList;
    fFlagPosition       : TFlagPosition;
    fStandardItemHeight : Integer;
    fItemIndex          : Integer;
    fItemsReady         : Boolean;
    fOnDrawItemLabel    : TCustomDrawItemLabelEvent;
    fOnItemsChange      : TNotifyEvent;
    fFlagsLink          : TChangeLink;
    Procedure SetSorted(Value : Boolean);
    Procedure SetFlagPosition(Value : TFlagPosition);
    Procedure SetFlags(Value : TCustomFlagImageList);
    Procedure FlagsChanged(Sender : TObject);
    Procedure ResetItemHeight;
    Procedure CMFontChanged(Var Message : TMessage); Message CM_FONTCHANGED;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Renders an individual item in the control.
    /// </summary>
    /// <param name="Index">
    /// The index of the item to draw.
    /// </param>
    /// <param name="Rect">
    /// The boundaries of the item on the control's canvas, in client coordinates.
    /// </param>
    /// <param name="State">
    /// The state information that can affect the way the item is drawn.
    /// </param>
    {$Endregion}
    Procedure DrawItem(Index : Integer; Rect : TRect; State : TOwnerDrawState); Override;
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
    /// Creates the underlying Windows control that implements the control.
    /// </summary>
    {$Endregion}
    Procedure CreateWnd; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Regenerates the internal list of items.
    /// </summary>
    {$Endregion}
    Procedure RebuildInternalItems; Virtual; Abstract;
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnDrawItemLabel"/> event.
    /// </summary>
    /// <param name="Index">
    /// The index of the item, which its label is being rendered.
    /// </param>
    /// <param name="Rect">
    /// The bounding rectangle of the item's label on the countrl's canvas.
    /// </param>
    /// <param name="State">
    /// The drawing state of the item.
    /// </param>
    /// <param name="TheLabel">
    /// The text of the item's label.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the default rendering should proceed after
    /// the method exits, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function DoDrawItemLabel(Index : Integer; Var Rect : TRect; State : TOwnerDrawState; Var TheLabel : String) : Boolean; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnItemsChange"/> event.
    /// </summary>
    {$Endregion}
    Procedure DoItemsChange; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the standard height of each item, in pixels.
    /// </summary>
    /// <returns>
    /// The height of each item, in pixels.
    /// </returns>
    {$Endregion}
    Function GetStandardItemHeight : Integer; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the index of the selected item.
    /// </summary>
    /// <returns>
    /// The index of the selected item.
    /// </returns>
    /// <seealso cref="SetItemIndex"/>
    {$Endregion}
    Function GetItemIndex : Integer; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Selects an item specified by its index.
    /// </summary>
    /// <param name="Value">
    /// The index of item to select.
    /// </param>
    /// <seealso cref="GetItemIndex"/>
    {$Endregion}
    Procedure SetItemIndex(Const Value : Integer); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns an image to display for a particular item.
    /// </summary>
    /// <param name="Index">
    /// The index of the item.
    /// </param>
    /// <returns>
    /// The index of an image.
    /// </returns>
    {$Endregion}
    Function GetImageIndex(Index : Integer) : Integer; Virtual; Abstract;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a text label to display for a particular item.
    /// </summary>
    /// <param name="Index">
    /// The index of the item.
    /// </param>
    /// <returns>
    /// The text label.
    /// </returns>
    {$Endregion}
    Function GetLabelText(Index : Integer) : String; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the standard height of each item, in pixels.
    /// </summary>
    {$Endregion}
    Property StandardItemHeight : Integer Read fStandardItemHeight;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets whether the internal list of items is generated.
    /// </summary>
    {$Endregion}
    Property ItemsReady : Boolean Read fItemsReady;
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
    /// Fills the list with all the possible items.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> if the method succeeded, otherwise returns
    /// <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function CollectAll : Boolean; Virtual; Abstract;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the placement of the country flag icon in regard of the text label.
    /// </summary>
    {$Endregion}
    Property FlagPosition : TFlagPosition Read fFlagPosition Write SetFlagPosition Default fpBeforeLabel;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the flag icons that can appear on the control.
    /// </summary>
    {$Endregion}
    Property Flags : TCustomFlagImageList Read fFlags Write SetFlags;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the items in the list are arranged alphabetically.
    /// </summary>
    {$Endregion}
    Property Sorted : Boolean Read fSorted Write SetSorted Default False;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when text label of an item needs to be displayed.
    /// </summary>
    {$Endregion}
    Property OnDrawItemLabel : TCustomDrawItemLabelEvent Read fOnDrawItemLabel Write fOnDrawItemLabel;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the list is changed.
    /// </summary>
    {$Endregion}
    Property OnItemsChange : TNotifyEvent Read fOnItemsChange Write fOnItemsChange;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class stores state of items in a check list for later retrieval.
/// </summary>
/// <remarks>
/// Use TCheckListRecall to save current state of items in a check list.
///
/// To restore the state of items in a check list to its original state, all that
/// is necessary is to free the TCheckListRecall object and the referenced check
/// list is automatically restored to the saved states.
///
/// You can update the TCheckListRecall instance to reflect the current state of the
/// referenced check list by calling the <see cref="Store"/> method. You can prevent
/// the TCheckListRecall destructor from updating the referenced check list by calling
/// the <see cref="Forget"/> method.
/// </remarks>
{$Endregion}

  TCheckListRecall = Class(TPersistent)
   Private
    Type
    TStateRec = Packed Record
     State    : TCheckBoxState;
     Disabled : Boolean;
    End;
   Private
    CheckList : TPersistent;
    StateInfo : TKeyLookup<String, TStateRec>;
    Function StateRec(AState : TCheckBoxState; ADisabled : Boolean) : TStateRec; Inline;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the class.
    /// </summary>
    /// <param name="AReference">
    /// The check list object to save and restore its state.
    /// </param>
    {$Endregion}
    Constructor Create(AReference : TPersistent);
    {$Region 'xmldoc'}
    /// <summary>
    /// Destroys the TCheckListRecall instance, assigning the stored state to the
    /// referenced object.
    /// </summary>
    {$Endregion}
    Destructor Destroy; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Saves the current state of the check list referenced by <see cref="Reference"/> property.
    /// </summary>
    /// <seealso cref="Forget"/>
    {$Endregion}
    Procedure Store;
    {$Region 'xmldoc'}
    /// <summary>
    /// Discards the saved states and prevents the TCheckListRecall object from updating the
    /// check list referenced by <see cref="Reference"/> property.
    /// </summary>
    /// <seealso cref="Store"/>
    {$Endregion}
    Procedure Forget;
    {$Region 'xmldoc'}
    /// <summary>
    /// Copies the state of items from another object.
    /// </summary>
    /// <param name="Source">
    /// The source object.
    /// </param>
    {$Endregion}
    Procedure Assign(Source : TPersistent); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Copies the state of items to another object.
    /// </summary>
    /// <param name="Dest">
    /// The destination object.
    /// </param>
    {$Endregion}
    Procedure AssignTo(Dest : TPersistent); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the reference to the check list object that is updated when you destroy
    /// the TCheckListRecall instance.
    /// </summary>
    {$Endregion}
    Property Reference : TPersistent Read CheckList Write CheckList;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TCustomFlagCheckListBox is the base class for check list box controls that represent
/// a list of country/region related items.
/// </summary>
/// <remarks>
/// Use TCustomFlagCheckListBox as a base class when defining check list box controls that
/// represent a list of country/region related items. TCustomFlagCheckListBox implements
/// properties to specify a country flag icon, along with its appearance and placement for
/// each individual item.
/// </remarks>
{$Endregion}

    TCustomFlagCheckListBox = Class Abstract(TCustomFlagListBox)
   Private
    fFlat         : Boolean;
    fAllowGrayed  : Boolean;
    fOnClickCheck : TNotifyEvent;
    fWrapperList  : TObjectList;
    fCheckWidth   : Integer;
    Procedure SetFlat(Value : Boolean);
    Procedure SetChecked(Index : Integer; Value : Boolean);
    Function GetChecked(Index : Integer) : Boolean;
    Procedure SetState(Index : Integer; Value : TCheckBoxState);
    Function GetState(Index : Integer) : TCheckBoxState;
    Function GetItemEnabled(Index : Integer) : Boolean;
    Procedure SetItemEnabled(Index : Integer; Value : Boolean);
    Procedure ToggleClickCheck(Index : Integer);
    Procedure InvalidateCheck(Index : Integer);
    Function CreateWrapper(Index : Integer) : TObject;
    Function ExtractWrapper(Index : Integer) : TObject;
    Function GetWrapper(Index : Integer) : TObject;
    Function HaveWrapper(Index : Integer) : Boolean;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Renders a check box on the control's canvas.
    /// </summary>
    /// <param name="Rect">
    /// The boundaries of the check box on the control's canvas, in client coordinates.
    /// </param>
    /// <param name="AState">
    /// The state of the check box.
    /// </param>
    /// <param name="AEnabled">
    /// Determines whether the check box is enabled.
    /// </param>
    {$Endregion}
    Procedure DrawCheck(Const Rect : TRect; AState : TCheckBoxState; AEnabled : Boolean);
    {$Region 'xmldoc'}
    /// <summary>
    /// Renders an individual item in the control.
    /// </summary>
    /// <param name="Index">
    /// The index of the item to draw.
    /// </param>
    /// <param name="Rect">
    /// The boundaries of the item on the control's canvas, in client coordinates.
    /// </param>
    /// <param name="State">
    /// The state information that can affect the way the item is drawn.
    /// </param>
    {$Endregion}
    Procedure DrawItem(Index : Integer; Rect : TRect; State : TOwnerDrawState); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Retrieves the data associated with an item in the check list box.
    /// </summary>
    /// <param name="Index">
    /// The index of the item.
    /// </param>
    /// <returns>
    /// The data associated with the item.
    /// </returns>
    /// <seealso cref="InternalSetItemData"/>
    {$Endregion}
    Function InternalGetItemData(Index : Integer) : TListBoxItemData; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Associates a data with a specified item in the check list box.
    /// </summary>
    /// <param name="Index">
    /// The index of the item.
    /// </param>
    /// <param name="AData">
    /// The data to associate with the item.
    /// </param>
    /// <seealso cref="InternalGetItemData"/>
    {$Endregion}
    Procedure InternalSetItemData(Index : Integer; AData : TListBoxItemData); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the state data associated with an item in the check list box.
    /// </summary>
    /// <param name="Index">
    /// The index of the item.
    /// </param>
    /// <returns>
    /// The data associated with the item.
    /// </returns>
    /// <seealso cref="SetItemData"/>
    {$Endregion}
    Function GetItemData(Index : Integer) : TListBoxItemData; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Updates the state data associated with a specified item in the check list box.
    /// </summary>
    /// <param name="Index">
    /// The index of the item.
    /// </param>
    /// <param name="AData">
    /// The data to associate with the item.
    /// </param>
    /// <seealso cref="GetItemData"/>
    {$Endregion}
    Procedure SetItemData(Index : Integer; AData : TListBoxItemData); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Loads the internal list of items from a <see cref="TStrings"/> object.
    /// </summary>
    /// <param name="RecreateItems">
    /// The source <see cref="TStrings"/> object.
    /// </param>
    /// <seealso cref="SaveRecreateItems"/>
    {$Endregion}
    Procedure LoadRecreateItems(RecreateItems : TStrings); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Saves the internal list of items into a <see cref="TStrings"/> object.
    /// </summary>
    /// <param name="RecreateItems">
    /// The destination <see cref="TStrings"/> object.
    /// </param>
    /// <seealso cref="LoadRecreateItems"/>
    {$Endregion}
    Procedure SaveRecreateItems(RecreateItems : TStrings); Override;
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
    /// Responds when the user presses a key while the control has focus.
    /// </summary>
    /// <param name="Key">
    /// The key code of the key that was pressed.
    /// </param>
    {$Endregion}
    Procedure KeyPress(Var Key : Char); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Deletes an item from the internal list of items, and releases its associated data.
    /// </summary>
    /// <param name="Index">
    /// The index of the item.
    /// </param>
    {$Endregion}
    Procedure DeleteString(Index : Integer); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Removes all of the items from the internal list of items.
    /// </summary>
    {$Endregion}
    Procedure ResetContent; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnClickCheck"/> event.
    /// </summary>
    {$Endregion}
    Procedure ClickCheck; Dynamic;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the standard height of each item, in pixels.
    /// </summary>
    /// <returns>
    /// The height of each item, in pixels.
    /// </returns>
    {$Endregion}
    Function GetStandardItemHeight : Integer; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the width of check boxes, in pixels.
    /// </summary>
    {$Endregion}
    Property CheckWidth : Integer Read fCheckWidth;
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
    /// Changes the state of all items to a specified state.
    /// </summary>
    /// <param name="AState">
    /// Specifies the new state of the items.
    /// </param>
    /// <param name="AllowGrayed">
    /// Determines whether the items in "grayed" state can be altered.
    /// </param>
    /// <param name="AllowDisabled">
    /// Determines whether the disabled items can be altered.
    /// </param>
    /// <seealso cref="Checked"/>
    /// <seealso cref="State"/>
    /// <seealso cref="ItemEnabled"/>
    /// <seealso cref="AllowGrayed"/>
    {$Endregion}
    Procedure RestateAll(AState : TCheckBoxState; AllowGrayed : Boolean = True; AllowDisabled : Boolean = True);
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists which items are checked.
    /// </summary>
    {$Endregion}
    Property Checked[Index : Integer] : Boolean Read GetChecked Write SetChecked;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the state of individual items in the list.
    /// </summary>
    {$Endregion}
    Property State[Index : Integer] : TCheckBoxState Read GetState Write SetState;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists enabled or disabled state of individual items in the list.
    /// </summary>
    {$Endregion}
    Property ItemEnabled[Index : Integer] : Boolean Read GetItemEnabled Write SetItemEnabled;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the check boxes can be in a "grayed" state.
    /// </summary>
    {$Endregion}
    Property AllowGrayed : Boolean Read fAllowGrayed Write fAllowGrayed Default False;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the check boxes appear three-dimensional.
    /// </summary>
    {$Endregion}
    Property Flat : Boolean Read fFlat Write SetFlat Default True;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the user selects or deselects an item's check box.
    /// </summary>
    {$Endregion}
    Property OnClickCheck : TNotifyEvent Read fOnClickCheck Write fOnClickCheck;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TCustomCultureLabel is the base class for label controls that display a
/// <see cref="TCultureInfo"/> object on a form.
/// </summary>
/// <remarks>
/// Use TCustomCultureLabel as a base class when defining objects that display a
/// <see cref="TCultureInfo"/> object. TCustomCultureLabel implements properties to
/// specify the <see cref="TCultureInfo"/> object, along with its interested piece
/// of information that should be displayed.
///
/// TCustomCultureLabel can be linked to a <see cref="TLocalizer"/> component. In
/// this case, the <see cref="TLocalizer"/> component determines the culture being
/// displayed by the control.
/// </remarks>
{$Endregion}

  TCustomCultureLabel = Class(TCustomFlagLabel, ILocalizerLink)
   Private
    fCulture     : TCultureInfo;
    fDisplayName : TCultureDisplayName;
    fLocalizer   : TLocalizer;
    Procedure SetCulture(Value : TCultureInfo);
    Procedure SetDisplayName(Value : TCultureDisplayName);
    Procedure SetLocalizer(Value : TLocalizer);
    Procedure ReadCulture(Reader : TReader);
    Procedure WriteCulture(Writer : TWriter);
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
    /// Reads and writes the <see cref="Culture"/> property as if it was published.
    /// </summary>
    /// <param name="Filer">
    /// The current <see cref="TReader"/> or <see cref="TWriter"/> object that is
    /// loading or saving the published properties.
    /// </param>
    {$Endregion}
    Procedure DefineProperties(Filer : TFiler); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a country flag icon to display on the control.
    /// </summary>
    /// <returns>
    /// The index of a country flag icon or -1 if no icon should be displayed.
    /// </returns>
    {$Endregion}
    Function GetImageIndex : TImageIndex; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a text label to display for on the control.
    /// </summary>
    /// <returns>
    /// The text label.
    /// </returns>
    {$Endregion}
    Function GetLabelText : String; Override;
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
    /// Gets or sets which value of <see cref="TCultureInfo.DisplayNames"/> should be
    /// displayed as the text label on the control.
    /// </summary>
    {$Endregion}
    Property DisplayName : TCultureDisplayName Read fDisplayName Write SetDisplayName Default cnEnglishDisplayName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the <see cref="TCultureInfo"/> object that the control is displaying.
    /// </summary>
    {$Endregion}
    Property Culture : TCultureInfo Read fCulture Write SetCulture;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TCultureLabel is a label control that displays a <see cref="TCultureInfo"/> object
/// on a form.
/// </summary>
/// <remarks>
/// Use TCultureLabel to display a <see cref="TCultureInfo"/> object on a form. The
/// <see cref="Culture"/> and <see cref="DisplayName"/> properties determine the content
/// that will be displayed.
///
/// TCultureLabel can be linked to a <see cref="TLocalizer"/> component. In this case,
/// the <see cref="TLocalizer"/> component determines the <see cref="TCultureInfo"/>
/// being displayed by the control.
///
/// TCultureLabel publishes many of the properties, events, and methods of
/// <see cref="TCustomCultureLabel"/>, but does not introduce any new behavior.
/// </remarks>
/// <group name="Components"/>
{$Endregion}
{$IFDEF COMPILER_XE2_UP}

  [ComponentPlatformsAttribute(pidWin32 Or pidWin64)]
  {$ENDIF}
  TCultureLabel = Class(TCustomCultureLabel)
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
    /// Gets or sets the text of the label when <see cref="Culture"/> property has no value.
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
    /// Gets or sets the <see cref="TCultureInfo"/> object that the control is displaying.
    /// </summary>
    {$Endregion}
    Property Culture;
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
/// TCustomCultureBox is the base class for combo box controls that represent a list
/// of <see cref="TCultureInfo"/> objects.
/// </summary>
/// <remarks>
/// Use TCustomCultureBox as a base class when defining combo box controls that represent
/// a list of <see cref="TCultureInfo"/> objects. TCustomCultureBox has properties and
/// methods to facilitate displaying, retrieving, sorting, and selecting of the stored
/// <see cref="TCultureInfo"/> objects.
///
/// TCustomCultureBox also implements properties to specify a country flag icon, along
/// with its appearance and placement for each individual item.
///
/// TCustomCultureBox can be linked to a <see cref="TLocalizer"/> component. In this case,
/// the <see cref="TLocalizer"/> component provides the <see cref="TCultureInfo"/> objects
/// for the <see cref="Items"/> property. Also the selected item of the control
/// will be synchronized with the current culture of the <see cref="TLocalizer"/> component.
/// </remarks>
{$Endregion}

  TCustomCultureBox = Class(TCustomFlagBox, ILocalizerLink)
   Private
    fCultures    : TCultureList;
    fDisplayName : TCultureDisplayName;
    fLocalizer   : TLocalizer;
    Procedure SetCultures(Value : TCultureList);
    Procedure SetItemSelected(Value : TCultureInfo);
    Function GetItemSelected : TCultureInfo;
    Procedure SetLocalizer(Value : TLocalizer);
    Procedure SetDisplayName(Value : TCultureDisplayName);
    Procedure CulturesChanged(Sender : TObject);
    Procedure ReadItemSelected(Reader : TReader);
    Procedure WriteItemSelected(Writer : TWriter);
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
    /// Reads and writes the <see cref="ItemSelected"/> property as if it was published.
    /// </summary>
    /// <param name="Filer">
    /// The current <see cref="TReader"/> or <see cref="TWriter"/> object that is
    /// loading or saving the published properties.
    /// </param>
    {$Endregion}
    Procedure DefineProperties(Filer : TFiler); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gererates an <see cref="OnSelect"/> event.
    /// </summary>
    {$Endregion}
    Procedure Select; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Fills the internal list of items by display name of the <see cref="TCultureInfo"/>
    /// objects in the <see cref="Items"/> property.
    /// </summary>
    {$Endregion}
    Procedure RebuildInternalItems; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a country flag icon for the specified item.
    /// </summary>
    /// <param name="Index">
    /// The index of the item.
    /// </param>
    /// <returns>
    /// The index of a country flag icon or -1 if no icon is available.
    /// </returns>
    {$Endregion}
    Function GetImageIndex(Index : Integer) : Integer; Override;
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
    /// Destroys the control and releases its allocated memory.
    /// </summary>
    {$Endregion}
    Destructor Destroy; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Fills the <see cref="Items"/> property with all the known <see cref="TCultureInfo"/>
    /// objects.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> if the control is not linked to a <see cref="TLocalizer"/>
    /// component, otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="18nCore.TWorld.Cultures"/>
    /// <seealso cref="IsManagedByLocalizer"/>
    {$Endregion}
    Function CollectAll : Boolean; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether the <see cref="Items"/> property is filled by a <see cref="TLocalizer"/>
    /// component.
    /// </summary>
    /// <returns>
    /// Rteurns <see langword="true"/> if <see cref="Localizer"/> property is not
    /// <see langword="nil"/>, otherwise returns <see langword="false"/>.</returns>
    /// <seealso cref="Localizer"/>
    {$Endregion}
    Function IsManagedByLocalizer : Boolean; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets which value of <see cref="TCultureInfo.DisplayNames"/> should be
    /// displayed as the label of items.
    /// </summary>
    {$Endregion}
    Property DisplayName : TCultureDisplayName Read fDisplayName Write SetDisplayName Default cnEnglishDisplayName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the currently selected <see cref="TCultureInfo"/> object.
    /// </summary>
    {$Endregion}
    Property ItemSelected : TCultureInfo Read GetItemSelected Write SetItemSelected;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the <see cref="TCultureInfo"/> objects in the control.
    /// </summary>
    {$Endregion}
    Property Items : TCultureList Read fCultures Write SetCultures;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TCultureBox is a combo box control that represents a list of <see cref="TCultureInfo"/>
/// objects.
/// </summary>
/// <remarks>
/// Use TCultureBox to enable users to select a <see cref="TCultureInfo"/> object from a list.
///
/// TCultureBox also implements properties to specify a country flag icon, along with its
/// appearance and placement for each individual item.
///
/// TCultureBox can be linked to a <see cref="TLocalizer"/> component. In this case,
/// the <see cref="TLocalizer"/> component provides the list of <see cref="TCultureInfo"/>
/// objects being displayed by the control.
///
/// TCultureBox publishes many of the properties, events, and methods of
/// <see cref="TCustomCultureBox"/>, but does not introduce any new behavior.
/// </remarks>
/// <group name="Components"/>
{$Endregion}
{$IFDEF COMPILER_XE2_UP}

  [ComponentPlatformsAttribute(pidWin32 Or pidWin64)]
  {$ENDIF}
  TCultureBox = Class(TCustomCultureBox)
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
    /// Gets or sets the currently selected <see cref="TCultureInfo"/> object.
    /// </summary>
    {$Endregion}
    Property ItemSelected;
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
    /// Gets or sets the text that is displayed as a text watermark in the control.
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
/// TCustomCultureListBox is the base class for list box controls that represent a list
/// of <see cref="TCultureInfo"/> objects.
/// </summary>
/// <remarks>
/// Use TCustomCultureListBox as a base class when defining list box controls that represent
/// a list of <see cref="TCultureInfo"/> objects. TCustomCultureListBox has properties and
/// methods to facilitate displaying, retrieving, sorting, and selecting of the stored
/// <see cref="TCultureInfo"/> objects.
///
/// TCustomCultureListBox also implements properties to specify a country flag icon, along
/// with its appearance and placement for each individual item.
///
/// TCustomCultureListBox can be linked to a <see cref="TLocalizer"/> component. In this
/// case, the <see cref="TLocalizer"/> component provides the <see cref="TCultureInfo"/>
/// objects for the <see cref="Items"/> property. Also the selected item of the control
/// will be synchronized with the current culture of the <see cref="TLocalizer"/> component.
/// </remarks>
{$Endregion}

  TCustomCultureListBox = Class(TCustomFlagListBox, ILocalizerLink)
   Private
    fCultures    : TCultureList;
    fDisplayName : TCultureDisplayName;
    fLocalizer   : TLocalizer;
    Procedure SetCultures(Value : TCultureList);
    Procedure SetItemSelected(Value : TCultureInfo);
    Function GetItemSelected : TCultureInfo;
    Procedure SetLocalizer(Value : TLocalizer);
    Procedure SetDisplayName(Value : TCultureDisplayName);
    Procedure CulturesChanged(Sender : TObject);
    Procedure ReadItemSelected(Reader : TReader);
    Procedure WriteItemSelected(Writer : TWriter);
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
    /// Reads and writes the <see cref="ItemSelected"/> property as if it was published.
    /// </summary>
    /// <param name="Filer">
    /// The current <see cref="TReader"/> or <see cref="TWriter"/> object that is
    /// loading or saving the published properties.
    /// </param>
    {$Endregion}
    Procedure DefineProperties(Filer : TFiler); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnClick"/> event.
    /// </summary>
    {$Endregion}
    Procedure Click; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Sets the <see cref="MultiSelect"/> property.
    /// </summary>
    /// <param name="Value">
    /// Determines whether more than one item can be selected.
    /// </param>
    {$Endregion}
    Procedure SetMultiSelect(Value : Boolean); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Fills the internal list of items by display name of the <see cref="TCultureInfo"/>
    /// objects in the <see cref="Items"/> property.
    /// </summary>
    {$Endregion}
    Procedure RebuildInternalItems; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a country flag icon for the specified item.
    /// </summary>
    /// <param name="Index">
    /// The index of the item.
    /// </param>
    /// <returns>
    /// The index of a country flag icon or -1 if no icon is available.
    /// </returns>
    {$Endregion}
    Function GetImageIndex(Index : Integer) : Integer; Override;
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
    /// Destroys the control and releases its allocated memory.
    /// </summary>
    {$Endregion}
    Destructor Destroy; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Fills the <see cref="Items"/> property with all the known <see cref="TCultureInfo"/>
    /// objects.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> if the control is not linked to a <see cref="TLocalizer"/>
    /// component, otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="18nCore.TWorld.Cultures"/>
    /// <seealso cref="IsManagedByLocalizer"/>
    {$Endregion}
    Function CollectAll : Boolean; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Retrieves the list of currently selected <see cref="TCultureInfo"/> objects.
    /// </summary>
    /// <param name="Dest">
    /// The list that receives the selected <see cref="TCultureInfo"/> objects.
    /// </param>
    /// <seealso cref="SetSelection"/>
    {$Endregion}
    Procedure GetSelection(Dest : TCultureList);
    {$Region 'xmldoc'}
    /// <summary>
    /// If <see cref="MultiSelect"/> is <see langword="true"/>, selects the items that are
    /// identified by a specified list of <see cref="TCultureInfo"/> objects.
    /// </summary>
    /// <param name="Source">
    /// The list of <see cref="TCultureInfo"/> objects to select.
    /// </param>
    /// <seealso cref="GetSelection"/>
    /// <seealso cref="MultiSelect"/>
    {$Endregion}
    Procedure SetSelection(Source : TReadonlyCultureList);
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether the <see cref="Items"/> property is filled by a <see cref="TLocalizer"/>
    /// component.
    /// </summary>
    /// <returns>
    /// Rteurns <see langword="true"/> if <see cref="Localizer"/> property is not
    /// <see langword="nil"/>, otherwise returns <see langword="false"/>.</returns>
    /// <seealso cref="Localizer"/>
    {$Endregion}
    Function IsManagedByLocalizer : Boolean; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets which value of <see cref="TCultureInfo.DisplayNames"/> should be
    /// displayed as the label of items.
    /// </summary>
    {$Endregion}
    Property DisplayName : TCultureDisplayName Read fDisplayName Write SetDisplayName Default cnEnglishDisplayName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the currently selected <see cref="TCultureInfo"/> object.
    /// </summary>
    {$Endregion}
    Property ItemSelected : TCultureInfo Read GetItemSelected Write SetItemSelected;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the <see cref="TCultureInfo"/> objects in the control.
    /// </summary>
    {$Endregion}
    Property Items : TCultureList Read fCultures Write SetCultures;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TCultureListBox is a list box control that represents a list of <see cref="TCultureInfo"/>
/// objects.
/// </summary>
/// <remarks>
/// Use TCultureListBox to enable users to select a <see cref="TCultureInfo"/> object from a list.
///
/// TCultureListBox also implements properties to specify a country flag icon, along with its
/// appearance and placement for each individual item.
///
/// TCultureListBox can be linked to a <see cref="TLocalizer"/> component. In this case,
/// the <see cref="TLocalizer"/> component provides the list of <see cref="TCultureInfo"/>
/// objects being displayed by the control.
///
/// TCultureListBox publishes many of the properties, events, and methods of
/// <see cref="TCustomCultureListBox"/>, but does not introduce any new behavior.
/// </remarks>
/// <group name="Components"/>
{$Endregion}
{$IFDEF COMPILER_XE2_UP}

  [ComponentPlatformsAttribute(pidWin32 Or pidWin64)]
  {$ENDIF}
  TCultureListBox = Class(TCustomCultureListBox)
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
    /// Gets or sets whether the user can select a sequential range of items in the list box.
    /// </summary>
    {$Endregion}
    Property ExtendedSelect;
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
    /// Gets or sets the currently selected <see cref="TCultureInfo"/> object.
    /// </summary>
    {$Endregion}
    Property ItemSelected;
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
    /// Gets or sets whether the user can select more than one item at a time.
    /// </summary>
    {$Endregion}
    Property MultiSelect;
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
/// TCustomCultureCheckListBox is the base class for check list box controls that
/// represent a list of <see cref="TCultureInfo"/> objects.
/// </summary>
/// <remarks>
/// Use TCustomCultureCheckListBox as a base class when defining controls that represent
/// a check list of <see cref="TCultureInfo"/> objects. TCustomCultureCheckListBox has
/// properties and methods to facilitate displaying, retrieving, sorting, and selecting
/// of the stored <see cref="TCultureInfo"/> objects.
///
/// TCustomCultureCheckListBox also implements properties to specify a country flag
/// icon, along with its appearance and placement for each individual item.
///
/// TCustomCultureCheckListBox can be linked to a <see cref="TLocalizer"/> component.
/// In this case, the <see cref="TLocalizer"/> component provides the <see cref="TCultureInfo"/>
/// objects for the <see cref="Items"/> property.
/// </remarks>
{$Endregion}

  TCustomCultureCheckListBox = Class(TCustomFlagCheckListBox, ILocalizerLink)
   Private
    fCultures    : TCultureList;
    fDisplayName : TCultureDisplayName;
    fLocalizer   : TLocalizer;
    Procedure SetCultures(Value : TCultureList);
    Procedure SetItemSelected(Value : TCultureInfo);
    Function GetItemSelected : TCultureInfo;
    Procedure SetLocalizer(Value : TLocalizer);
    Procedure SetDisplayName(Value : TCultureDisplayName);
    Procedure CulturesChanged(Sender : TObject);
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
    /// Fills the internal list of items by display name of the <see cref="TCultureInfo"/>
    /// objects in the <see cref="Items"/> property.
    /// </summary>
    {$Endregion}
    Procedure RebuildInternalItems; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a country flag icon for the specified item.
    /// </summary>
    /// <param name="Index">
    /// The index of the item.
    /// </param>
    /// <returns>
    /// The index of a country flag icon or -1 if no icon is available.
    /// </returns>
    {$Endregion}
    Function GetImageIndex(Index : Integer) : Integer; Override;
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
    /// Destroys the control and releases its allocated memory.
    /// </summary>
    {$Endregion}
    Destructor Destroy; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Fills the <see cref="Items"/> property with all the known <see cref="TCultureInfo"/>
    /// objects.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> if the control is not linked to a <see cref="TLocalizer"/>
    /// component, otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="18nCore.TWorld.Cultures"/>
    /// <seealso cref="IsManagedByLocalizer"/>
    {$Endregion}
    Function CollectAll : Boolean; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Retrieves the list of checked <see cref="TCultureInfo"/> objects.
    /// </summary>
    /// <param name="Dest">
    /// The list that receives the checked <see cref="TCultureInfo"/> objects.
    /// </param>
    /// <param name="AllowDisabled">
    /// Determines whether the disabled items can be retrieved.
    /// </param>
    /// <seealso cref="SetSelection"/>
    {$Endregion}
    Procedure GetSelection(Dest : TCultureList; AllowDisabled : Boolean = True); Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Checkes the items that are identified by a specified list of <see cref="TCultureInfo"/> objects.
    /// </summary>
    /// <param name="Source">
    /// The list of <see cref="TCultureInfo"/> objects to select.
    /// </param>
    /// <param name="AllowDisabled">
    /// Determines whether the disabled items can be altered.
    /// </param>
    /// <seealso cref="GetSelection"/>
    {$Endregion}
    Procedure SetSelection(Source : TReadonlyCultureList; AllowDisabled : Boolean = True); Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether the <see cref="Items"/> property is filled by a <see cref="TLocalizer"/>
    /// component.
    /// </summary>
    /// <returns>
    /// Rteurns <see langword="true"/> if <see cref="Localizer"/> property is not
    /// <see langword="nil"/>, otherwise returns <see langword="false"/>.</returns>
    /// <seealso cref="Localizer"/>
    {$Endregion}
    Function IsManagedByLocalizer : Boolean; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets which value of <see cref="TCultureInfo.DisplayNames"/> should be
    /// displayed as the label of items.
    /// </summary>
    {$Endregion}
    Property DisplayName : TCultureDisplayName Read fDisplayName Write SetDisplayName Default cnEnglishDisplayName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the currently selected <see cref="TCultureInfo"/> object.
    /// </summary>
    {$Endregion}
    Property ItemSelected : TCultureInfo Read GetItemSelected Write SetItemSelected;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the <see cref="TCultureInfo"/> objects in the control.
    /// </summary>
    {$Endregion}
    Property Items : TCultureList Read fCultures Write SetCultures;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TCultureCheckListBox is a check list box control that represents a list of
/// <see cref="TCultureInfo"/> objects.
/// </summary>
/// <remarks>
/// Use TCultureCheckListBox to enable users to select multiple <see cref="TCultureInfo"/>
/// objects from a list.
///
/// TCultureCheckListBox also implements properties to specify a country flag icon,
/// along with its appearance and placement for each individual item.
///
/// TCultureCheckListBox can be linked to a <see cref="TLocalizer"/> component.
/// In this case, the <see cref="TLocalizer"/> component provides the list of
/// <see cref="TCultureInfo"/> objects being displayed by the control.
///
/// TCultureCheckListBox publishes many of the properties, events, and methods of
/// <see cref="TCustomCultureCheckListBox"/>, but does not introduce any new behavior.
/// </remarks>
/// <group name="Components"/>
{$Endregion}
{$IFDEF COMPILER_XE2_UP}

  [ComponentPlatformsAttribute(pidWin32 Or pidWin64)]
  {$ENDIF}
  TCultureCheckListBox = Class(TCustomCultureCheckListBox)
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
    /// Gets or sets whether the check boxes can be in a "grayed" state.
    /// </summary>
    {$Endregion}
    Property AllowGrayed;
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
    /// Gets or sets whether the check boxes appear three-dimensional.
    /// </summary>
    {$Endregion}
    Property Flat;
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
    /// Occurs when the user selects or deselects an item's check box.
    /// </summary>
    {$Endregion}
    Property OnClickCheck;
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
/// TCustomTerritoryLabel is the base class for label controls that display a
/// <see cref="TTerritoryInfo"/> object on a form.
/// </summary>
/// <remarks>
/// Use TCustomTerritoryLabel as a base class when defining objects that display a
/// <see cref="TTerritoryInfo"/> object. TCustomTerritoryLabel implements properties
/// to specify the <see cref="TTerritoryInfo"/> object, along with its interested piece
/// of information that should be displayed.
/// </remarks>
{$Endregion}

  TCustomTerritoryLabel = Class(TCustomFlagLabel)
   Private
    fTerritory   : TTerritoryInfo;
    fDisplayName : TTerritoryDisplayName;
    Procedure SetTerritory(Value : TTerritoryInfo);
    Procedure SetDisplayName(Value : TTerritoryDisplayName);
    Procedure ReadTerritory(Reader : TReader);
    Procedure WriteTerritory(Writer : TWriter);
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Reads and writes the <see cref="Territory"/> property as if it was published.
    /// </summary>
    /// <param name="Filer">
    /// The current <see cref="TReader"/> or <see cref="TWriter"/> object that is
    /// loading or saving the published properties.
    /// </param>
    {$Endregion}
    Procedure DefineProperties(Filer : TFiler); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a country flag icon to display on the control.
    /// </summary>
    /// <returns>
    /// The index of a country flag icon or -1 if no icon should be displayed.
    /// </returns>
    {$Endregion}
    Function GetImageIndex : TImageIndex; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a text label to display for on the control.
    /// </summary>
    /// <returns>
    /// The text label.
    /// </returns>
    {$Endregion}
    Function GetLabelText : String; Override;
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
    /// Gets or sets which value of <see cref="TTerritoryInfo.DisplayNames"/> should be
    /// displayed as the text label on the control.
    /// </summary>
    {$Endregion}
    Property DisplayName : TTerritoryDisplayName Read fDisplayName Write SetDisplayName Default tnFriendlyName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the <see cref="TTerritoryInfo"/> object that the control is displaying.
    /// </summary>
    {$Endregion}
    Property Territory : TTerritoryInfo Read fTerritory Write SetTerritory;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TTerritoryLabel is a label control that displays a <see cref="TTerritoryInfo"/> object
/// on a form.
/// </summary>
/// <remarks>
/// Use TTerritoryLabel to display a <see cref="TTerritoryInfo"/> object on a form. The
/// <see cref="Territory"/> and <see cref="DisplayName"/> properties determine the content
/// that will be displayed.
///
/// TTerritoryLabel publishes many of the properties, events, and methods of
/// <see cref="TCustomTerritoryLabel"/>, but does not introduce any new behavior.
/// </remarks>
/// <group name="Components"/>
{$Endregion}
{$IFDEF COMPILER_XE2_UP}

  [ComponentPlatformsAttribute(pidWin32 Or pidWin64)]
  {$ENDIF}
  TTerritoryLabel = Class(TCustomTerritoryLabel)
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
    /// Gets or sets the text of the label when <see cref="Territory"/> property has no value.
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
    /// Gets or sets the <see cref="TTerritoryInfo"/> object that the control is displaying.
    /// </summary>
    {$Endregion}
    Property Territory;
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
/// TCustomTerritoryBox is the base class for combo box controls that represent a list
/// of <see cref="TTerritoryInfo"/> objects.
/// </summary>
/// <remarks>
/// Use TCustomTerritoryBox as a base class when defining combo box controls that represent
/// a list of <see cref="TTerritoryInfo"/> objects. TCustomTerritoryBox has properties and
/// methods to facilitate displaying, retrieving, sorting, and selecting of the stored
/// <see cref="TTerritoryInfo"/> objects.
///
/// TCustomTerritoryBox also implements properties to specify a country flag icon, along
/// with its appearance and placement for each individual item.
/// </remarks>
{$Endregion}

  TCustomTerritoryBox = Class(TCustomFlagBox)
   Private
    fTerritories : TTerritoryList;
    fDisplayName : TTerritoryDisplayName;
    Procedure SetTerritories(Value : TTerritoryList);
    Procedure SetItemSelected(Value : TTerritoryInfo);
    Function GetItemSelected : TTerritoryInfo;
    Procedure SetDisplayName(Value : TTerritoryDisplayName);
    Procedure TerritoriesChanged(Sender : TObject);
    Procedure ReadItemSelected(Reader : TReader);
    Procedure WriteItemSelected(Writer : TWriter);
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Reads and writes the <see cref="ItemSelected"/> property as if it was published.
    /// </summary>
    /// <param name="Filer">
    /// The current <see cref="TReader"/> or <see cref="TWriter"/> object that is
    /// loading or saving the published properties.
    /// </param>
    {$Endregion}
    Procedure DefineProperties(Filer : TFiler); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Fills the internal list of items by display name of the <see cref="TTerritoryInfo"/>
    /// objects in the <see cref="Items"/> property.
    /// </summary>
    {$Endregion}
    Procedure RebuildInternalItems; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a country flag icon for the specified item.
    /// </summary>
    /// <param name="Index">
    /// The index of the item.
    /// </param>
    /// <returns>
    /// The index of a country flag icon or -1 if no icon is available.
    /// </returns>
    {$Endregion}
    Function GetImageIndex(Index : Integer) : Integer; Override;
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
    /// Fills the <see cref="Items"/> property with all the known <see cref="TTerritoryInfo"/>
    /// objects.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/>.
    /// </returns>
    /// <seealso cref="18nCore.TWorld.Territories"/>
    {$Endregion}
    Function CollectAll : Boolean; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets which value of <see cref="TTerritoryInfo.DisplayNames"/> should be
    /// displayed as the label of items.
    /// </summary>
    {$Endregion}
    Property DisplayName : TTerritoryDisplayName Read fDisplayName Write SetDisplayName Default tnFriendlyName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the currently selected <see cref="TTerritoryInfo"/> object.
    /// </summary>
    {$Endregion}
    Property ItemSelected : TTerritoryInfo Read GetItemSelected Write SetItemSelected;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the <see cref="TTerritoryInfo"/> objects in the control.
    /// </summary>
    {$Endregion}
    Property Items : TTerritoryList Read fTerritories Write SetTerritories;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TTerritoryBox is a combo box control that represents a list of <see cref="TTerritoryInfo"/>
/// objects.
/// </summary>
/// <remarks>
/// Use TTerritoryBox to enable users to select a <see cref="TTerritoryInfo"/> object from a list.
///
/// TTerritoryBox also implements properties to specify a country flag icon, along with its
/// appearance and placement for each individual item.
///
/// TTerritoryBox publishes many of the properties, events, and methods of
/// <see cref="TCustomTerritoryBox"/>, but does not introduce any new behavior.
/// </remarks>
/// <group name="Components"/>
{$Endregion}
{$IFDEF COMPILER_XE2_UP}

  [ComponentPlatformsAttribute(pidWin32 Or pidWin64)]
  {$ENDIF}
  TTerritoryBox = Class(TCustomTerritoryBox)
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
    /// Gets or sets which value of <see cref="TTerritoryInfo.DisplayNames"/> should be
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
    /// Lists the <see cref="TTerritoryInfo"/> objects in the control.
    /// </summary>
    {$Endregion}
    Property Items;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the currently selected <see cref="TTerritoryInfo"/> object.
    /// </summary>
    {$Endregion}
    Property ItemSelected;
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
    /// Gets or sets the text that is displayed as a text watermark in the control.
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
/// TCustomTerritoryListBox is the base class for list box controls that represent a list
/// of <see cref="TTerritoryInfo"/> objects.
/// </summary>
/// <remarks>
/// Use TCustomTerritoryListBox as a base class when defining list box controls that represent
/// a list of <see cref="TTerritoryInfo"/> objects. TCustomTerritoryListBox has properties and
/// methods to facilitate displaying, retrieving, sorting, and selecting of the stored
/// <see cref="TTerritoryInfo"/> objects.
///
/// TCustomTerritoryListBox also implements properties to specify a country flag icon, along
/// with its appearance and placement for each individual item.
/// </remarks>
{$Endregion}

  TCustomTerritoryListBox = Class(TCustomFlagListBox)
   Private
    fTerritories : TTerritoryList;
    fDisplayName : TTerritoryDisplayName;
    Procedure SetTerritories(Value : TTerritoryList);
    Procedure SetItemSelected(Value : TTerritoryInfo);
    Function GetItemSelected : TTerritoryInfo;
    Procedure SetDisplayName(Value : TTerritoryDisplayName);
    Procedure TerritoriesChanged(Sender : TObject);
    Procedure ReadItemSelected(Reader : TReader);
    Procedure WriteItemSelected(Writer : TWriter);
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Reads and writes the <see cref="ItemSelected"/> property as if it was published.
    /// </summary>
    /// <param name="Filer">
    /// The current <see cref="TReader"/> or <see cref="TWriter"/> object that is
    /// loading or saving the published properties.
    /// </param>
    {$Endregion}
    Procedure DefineProperties(Filer : TFiler); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Fills the internal list of items by display name of the <see cref="TTerritoryInfo"/>
    /// objects in the <see cref="Items"/> property.
    /// </summary>
    {$Endregion}
    Procedure RebuildInternalItems; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a country flag icon for the specified item.
    /// </summary>
    /// <param name="Index">
    /// The index of the item.
    /// </param>
    /// <returns>
    /// The index of a country flag icon or -1 if no icon is available.
    /// </returns>
    {$Endregion}
    Function GetImageIndex(Index : Integer) : Integer; Override;
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
    /// Fills the <see cref="Items"/> property with all the known <see cref="TTerritoryInfo"/>
    /// objects.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> if the control is not linked to a <see cref="TLocalizer"/>
    /// component, otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="18nCore.TWorld.Territorys"/>
    {$Endregion}
    Function CollectAll : Boolean; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Retrieves the list of currently selected <see cref="TTerritoryInfo"/> objects.
    /// </summary>
    /// <param name="Dest">
    /// The list that receives the selected <see cref="TTerritoryInfo"/> objects.
    /// </param>
    /// <seealso cref="SetSelection"/>
    {$Endregion}
    Procedure GetSelection(Dest : TTerritoryList);
    {$Region 'xmldoc'}
    /// <summary>
    /// Selects the items that are identified by a specified list of <see cref="TTerritoryInfo"/> objects.
    /// </summary>
    /// <param name="Source">
    /// The list of <see cref="TTerritoryInfo"/> objects to select.
    /// </param>
    /// <seealso cref="GetSelection"/>
    /// <seealso cref="MultiSelect"/>
    {$Endregion}
    Procedure SetSelection(Source : TReadonlyTerritoryList);
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets which value of <see cref="TTerritoryInfo.DisplayNames"/> should be
    /// displayed as the label of items.
    /// </summary>
    {$Endregion}
    Property DisplayName : TTerritoryDisplayName Read fDisplayName Write SetDisplayName Default tnFriendlyName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the currently selected <see cref="TTerritoryInfo"/> object.
    /// </summary>
    {$Endregion}
    Property ItemSelected : TTerritoryInfo Read GetItemSelected Write SetItemSelected;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the <see cref="TTerritoryInfo"/> objects in the control.
    /// </summary>
    {$Endregion}
    Property Items : TTerritoryList Read fTerritories Write SetTerritories;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TTerritoryListBox is a list box control that represents a list of
/// <see cref="TTerritoryInfo"/> objects.
/// </summary>
/// <remarks>
/// Use TTerritoryListBox to enable users to select a <see cref="TTerritoryInfo"/>
/// object from a list.
///
/// TTerritoryListBox also implements properties to specify a country flag icon,
/// along with its appearance and placement for each individual item.
///
/// TTerritoryListBox publishes many of the properties, events, and methods of
/// <see cref="TCustomTerritoryListBox"/>, but does not introduce any new behavior.
/// </remarks>
/// <group name="Components"/>
{$Endregion}
{$IFDEF COMPILER_XE2_UP}

  [ComponentPlatformsAttribute(pidWin32 Or pidWin64)]
  {$ENDIF}
  TTerritoryListBox = Class(TCustomTerritoryListBox)
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
    /// Gets or sets which value of <see cref="TTerritoryInfo.DisplayNames"/> should be
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
    /// Gets or sets whether the user can select a sequential range of items in the list box.
    /// </summary>
    {$Endregion}
    Property ExtendedSelect;
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
    /// Lists the <see cref="TTerritoryInfo"/> objects in the control.
    /// </summary>
    {$Endregion}
    Property Items;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the currently selected <see cref="TTerritoryInfo"/> object.
    /// </summary>
    {$Endregion}
    Property ItemSelected;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the margins of the control.
    /// </summary>
    {$Endregion}
    Property Margins;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the user can select more than one item at a time.
    /// </summary>
    {$Endregion}
    Property MultiSelect;
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
/// TCustomTerritoryCheckListBox is the base class for check list box controls that
/// represent a list of <see cref="TTerritoryInfo"/> objects.
/// </summary>
/// <remarks>
/// Use TCustomTerritoryCheckListBox as a base class when defining controls that represent
/// a check list of <see cref="TTerritoryInfo"/> objects. TCustomTerritoryCheckListBox has
/// properties and methods to facilitate displaying, retrieving, sorting, and selecting
/// of the stored <see cref="TTerritoryInfo"/> objects.
///
/// TCustomTerritoryCheckListBox also implements properties to specify a country flag
/// icon, along with its appearance and placement for each individual item.
/// </remarks>
{$Endregion}

  TCustomTerritoryCheckListBox = Class(TCustomFlagCheckListBox)
   Private
    fTerritories : TTerritoryList;
    fDisplayName : TTerritoryDisplayName;
    Procedure SetTerritories(Value : TTerritoryList);
    Procedure SetItemSelected(Value : TTerritoryInfo);
    Function GetItemSelected : TTerritoryInfo;
    Procedure SetDisplayName(Value : TTerritoryDisplayName);
    Procedure TerritoriesChanged(Sender : TObject);
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Fills the internal list of items by display name of the <see cref="TTerritoryInfo"/>
    /// objects in the <see cref="Items"/> property.
    /// </summary>
    {$Endregion}
    Procedure RebuildInternalItems; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a country flag icon for the specified item.
    /// </summary>
    /// <param name="Index">
    /// The index of the item.
    /// </param>
    /// <returns>
    /// The index of a country flag icon or -1 if no icon is available.
    /// </returns>
    {$Endregion}
    Function GetImageIndex(Index : Integer) : Integer; Override;
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
    /// Fills the <see cref="Items"/> property with all the known <see cref="TTerritoryInfo"/>
    /// objects.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> if the control is not linked to a <see cref="TLocalizer"/>
    /// component, otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="18nCore.TWorld.Territorys"/>
    {$Endregion}
    Function CollectAll : Boolean; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Retrieves the list of checked <see cref="TTerritoryInfo"/> objects.
    /// </summary>
    /// <param name="Dest">
    /// The list that receives the checked <see cref="TTerritoryInfo"/> objects.
    /// </param>
    /// <param name="AllowDisabled">
    /// Determines whether the disabled items can be retrieved.
    /// </param>
    /// <seealso cref="SetSelection"/>
    {$Endregion}
    Procedure GetSelection(Dest : TTerritoryList; AllowDisabled : Boolean = True); Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Checkes the items that are identified by a specified list of <see cref="TTerritoryInfo"/> objects.
    /// </summary>
    /// <param name="Source">
    /// The list of <see cref="TTerritoryInfo"/> objects to select.
    /// </param>
    /// <param name="AllowDisabled">
    /// Determines whether the disabled items can be altered.
    /// </param>
    /// <seealso cref="GetSelection"/>
    {$Endregion}
    Procedure SetSelection(Source : TReadonlyTerritoryList; AllowDisabled : Boolean = True); Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets which value of <see cref="TTerritoryInfo.DisplayNames"/> should be
    /// displayed as the label of items.
    /// </summary>
    {$Endregion}
    Property DisplayName : TTerritoryDisplayName Read fDisplayName Write SetDisplayName Default tnFriendlyName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the currently selected <see cref="TTerritoryInfo"/> object.
    /// </summary>
    {$Endregion}
    Property ItemSelected : TTerritoryInfo Read GetItemSelected Write SetItemSelected;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the <see cref="TTerritoryInfo"/> objects in the control.
    /// </summary>
    {$Endregion}
    Property Items : TTerritoryList Read fTerritories Write SetTerritories;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TTerritoryCheckListBox is a check list box control that represents a list of
/// <see cref="TTerritoryInfo"/> objects.
/// </summary>
/// <remarks>
/// Use TTerritoryCheckListBox to enable users to select multiple <see cref="TTerritoryInfo"/>
/// objects from a list.
///
/// TTerritoryCheckListBox also implements properties to specify a country flag icon,
/// along with its appearance and placement for each individual item.
///
/// TTerritoryCheckListBox publishes many of the properties, events, and methods of
/// <see cref="TCustomTerritoryCheckListBox"/>, but does not introduce any new behavior.
/// </remarks>
/// <group name="Components"/>
{$Endregion}
{$IFDEF COMPILER_XE2_UP}

  [ComponentPlatformsAttribute(pidWin32 Or pidWin64)]
  {$ENDIF}
  TTerritoryCheckListBox = Class(TCustomTerritoryCheckListBox)
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
    /// Gets or sets whether the check boxes can be in a "grayed" state.
    /// </summary>
    {$Endregion}
    Property AllowGrayed;
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
    /// Gets or sets which value of <see cref="TTerritoryInfo.DisplayNames"/> should be
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
    /// Gets or sets whether the check boxes appear three-dimensional.
    /// </summary>
    {$Endregion}
    Property Flat;
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
    /// Lists the <see cref="TTerritoryInfo"/> objects in the control.
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
    /// Occurs when the user selects or deselects an item's check box.
    /// </summary>
    {$Endregion}
    Property OnClickCheck;
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
/// TCustomCurrencyLabel is the base class for label controls that display a
/// <see cref="TCurrencyInfo"/> object on a form.
/// </summary>
/// <remarks>
/// Use TCustomCurrencyLabel as a base class when defining objects that display a
/// <see cref="TCurrencyInfo"/> object. TCustomCurrencyLabel implements properties
/// to specify the <see cref="TCurrencyInfo"/> object, along with its interested piece
/// of information that should be displayed.
/// </remarks>
{$Endregion}

  TCustomCurrencyLabel = Class(TCustomFlagLabel)
   Private
    fCurrency    : TCurrencyInfo;
    fDisplayName : TCurrencyDisplayName;
    Procedure SetCurrency(Value : TCurrencyInfo);
    Procedure SetDisplayName(Value : TCurrencyDisplayName);
    Procedure ReadCurrency(Reader : TReader);
    Procedure WriteCurrency(Writer : TWriter);
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Reads and writes the <see cref="Currency"/> property as if it was published.
    /// </summary>
    /// <param name="Filer">
    /// The current <see cref="TReader"/> or <see cref="TWriter"/> object that is
    /// loading or saving the published properties.
    /// </param>
    {$Endregion}
    Procedure DefineProperties(Filer : TFiler); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a country flag icon to display on the control.
    /// </summary>
    /// <returns>
    /// The index of a country flag icon or -1 if no icon should be displayed.
    /// </returns>
    {$Endregion}
    Function GetImageIndex : TImageIndex; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a text label to display for on the control.
    /// </summary>
    /// <returns>
    /// The text label.
    /// </returns>
    {$Endregion}
    Function GetLabelText : String; Override;
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
    /// Gets or sets which value of <see cref="TCurrencyInfo.DisplayNames"/> should be
    /// displayed as the text label on the control.
    /// </summary>
    {$Endregion}
    Property DisplayName : TCurrencyDisplayName Read fDisplayName Write SetDisplayName Default crnEnglishName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the <see cref="TCurrencyInfo"/> object that the control is displaying.
    /// </summary>
    {$Endregion}
    Property Currency : TCurrencyInfo Read fCurrency Write SetCurrency;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TCurrencyLabel is a label control that displays a <see cref="TCurrencyInfo"/> object
/// on a form.
/// </summary>
/// <remarks>
/// Use TCurrencyLabel to display a <see cref="TCurrencyInfo"/> object on a form. The
/// <see cref="Currency"/> and <see cref="DisplayName"/> properties determine the content
/// that will be displayed.
///
/// TCurrencyLabel publishes many of the properties, events, and methods of
/// <see cref="TCustomCurrencyLabel"/>, but does not introduce any new behavior.
/// </remarks>
/// <group name="Components"/>
{$Endregion}
{$IFDEF COMPILER_XE2_UP}

  [ComponentPlatformsAttribute(pidWin32 Or pidWin64)]
  {$ENDIF}
  TCurrencyLabel = Class(TCustomCurrencyLabel)
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
    /// Gets or sets the text of the label when <see cref="Currency"/> property has no value.
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
    /// Gets or sets the <see cref="TCurrencyInfo"/> object that the control is displaying.
    /// </summary>
    {$Endregion}
    Property Currency;
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
/// TCustomCurrencyBox is the base class for combo box controls that represent a list
/// of <see cref="TCurrencyInfo"/> objects.
/// </summary>
/// <remarks>
/// Use TCustomCurrencyBox as a base class when defining combo box controls that represent
/// a list of <see cref="TCurrencyInfo"/> objects. TCustomCurrencyBox has properties and
/// methods to facilitate displaying, retrieving, sorting, and selecting of the stored
/// <see cref="TCurrencyInfo"/> objects.
///
/// TCustomCurrencyBox also implements properties to specify a country flag icon, along
/// with its appearance and placement for each individual item.
/// </remarks>
{$Endregion}

  TCustomCurrencyBox = Class(TCustomFlagBox)
   Private
    fCurrencies  : TCurrencyList;
    fDisplayName : TCurrencyDisplayName;
    Procedure SetCurrencies(Value : TCurrencyList);
    Procedure SetItemSelected(Value : TCurrencyInfo);
    Function GetItemSelected : TCurrencyInfo;
    Procedure SetDisplayName(Value : TCurrencyDisplayName);
    Procedure CurrenciesChanged(Sender : TObject);
    Procedure ReadItemSelected(Reader : TReader);
    Procedure WriteItemSelected(Writer : TWriter);
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Reads and writes the <see cref="ItemSelected"/> property as if it was published.
    /// </summary>
    /// <param name="Filer">
    /// The current <see cref="TReader"/> or <see cref="TWriter"/> object that is
    /// loading or saving the published properties.
    /// </param>
    {$Endregion}
    Procedure DefineProperties(Filer : TFiler); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Fills the internal list of items by display name of the <see cref="TCurrencyInfo"/>
    /// objects in the <see cref="Items"/> property.
    /// </summary>
    {$Endregion}
    Procedure RebuildInternalItems; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a country flag icon for the specified item.
    /// </summary>
    /// <param name="Index">
    /// The index of the item.
    /// </param>
    /// <returns>
    /// The index of a country flag icon or -1 if no icon is available.
    /// </returns>
    {$Endregion}
    Function GetImageIndex(Index : Integer) : Integer; Override;
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
    /// Fills the <see cref="Items"/> property with all the known <see cref="TCurrencyInfo"/>
    /// objects.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/>.
    /// </returns>
    /// <seealso cref="18nCore.TWorld.Currencies"/>
    {$Endregion}
    Function CollectAll : Boolean; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets which value of <see cref="TCurrencyInfo.DisplayNames"/> should be
    /// displayed as the label of items.
    /// </summary>
    {$Endregion}
    Property DisplayName : TCurrencyDisplayName Read fDisplayName Write SetDisplayName Default crnEnglishName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the currently selected <see cref="TCurrencyInfo"/> object.
    /// </summary>
    {$Endregion}
    Property ItemSelected : TCurrencyInfo Read GetItemSelected Write SetItemSelected;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the <see cref="TCurrencyInfo"/> objects in the control.
    /// </summary>
    {$Endregion}
    Property Items : TCurrencyList Read fCurrencies Write SetCurrencies;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TCurrencyBox is a combo box control that represents a list of <see cref="TCurrencyInfo"/>
/// objects.
/// </summary>
/// <remarks>
/// Use TCurrencyBox to enable users to select a <see cref="TCurrencyInfo"/> object from a list.
///
/// TCurrencyBox also implements properties to specify a country flag icon, along with its
/// appearance and placement for each individual item.
///
/// TCurrencyBox publishes many of the properties, events, and methods of
/// <see cref="TCustomCurrencyBox"/>, but does not introduce any new behavior.
/// </remarks>
/// <group name="Components"/>
{$Endregion}
{$IFDEF COMPILER_XE2_UP}

  [ComponentPlatformsAttribute(pidWin32 Or pidWin64)]
  {$ENDIF}
  TCurrencyBox = Class(TCustomCurrencyBox)
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
    /// Gets or sets which value of <see cref="TCurrencyInfo.DisplayNames"/> should be
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
    /// Lists the <see cref="TCurrencyInfo"/> objects in the control.
    /// </summary>
    {$Endregion}
    Property Items;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the currently selected <see cref="TCurrencyInfo"/> object.
    /// </summary>
    {$Endregion}
    Property ItemSelected;
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
    /// Gets or sets the text that is displayed as a text watermark in the control.
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
/// TCustomCurrencyListBox is the base class for list box controls that represent a list
/// of <see cref="TCurrencyInfo"/> objects.
/// </summary>
/// <remarks>
/// Use TCustomCurrencyListBox as a base class when defining list box controls that represent
/// a list of <see cref="TCurrencyInfo"/> objects. TCustomCurrencyListBox has properties and
/// methods to facilitate displaying, retrieving, sorting, and selecting of the stored
/// <see cref="TCurrencyInfo"/> objects.
///
/// TCustomCurrencyListBox also implements properties to specify a country flag icon, along
/// with its appearance and placement for each individual item.
/// </remarks>
{$Endregion}

  TCustomCurrencyListBox = Class(TCustomFlagListBox)
   Private
    fCurrencies  : TCurrencyList;
    fDisplayName : TCurrencyDisplayName;
    Procedure SetCurrencies(Value : TCurrencyList);
    Procedure SetItemSelected(Value : TCurrencyInfo);
    Function GetItemSelected : TCurrencyInfo;
    Procedure SetDisplayName(Value : TCurrencyDisplayName);
    Procedure CurrenciesChanged(Sender : TObject);
    Procedure ReadItemSelected(Reader : TReader);
    Procedure WriteItemSelected(Writer : TWriter);
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Reads and writes the <see cref="ItemSelected"/> property as if it was published.
    /// </summary>
    /// <param name="Filer">
    /// The current <see cref="TReader"/> or <see cref="TWriter"/> object that is
    /// loading or saving the published properties.
    /// </param>
    {$Endregion}
    Procedure DefineProperties(Filer : TFiler); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Fills the internal list of items by display name of the <see cref="TCurrencyInfo"/>
    /// objects in the <see cref="Items"/> property.
    /// </summary>
    {$Endregion}
    Procedure RebuildInternalItems; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a country flag icon for the specified item.
    /// </summary>
    /// <param name="Index">
    /// The index of the item.
    /// </param>
    /// <returns>
    /// The index of a country flag icon or -1 if no icon is available.
    /// </returns>
    {$Endregion}
    Function GetImageIndex(Index : Integer) : Integer; Override;
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
    /// Fills the <see cref="Items"/> property with all the known <see cref="TCurrencyInfo"/>
    /// objects.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> if the control is not linked to a <see cref="TLocalizer"/>
    /// component, otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="18nCore.TWorld.Currencys"/>
    {$Endregion}
    Function CollectAll : Boolean; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Retrieves the list of currently selected <see cref="TCurrencyInfo"/> objects.
    /// </summary>
    /// <param name="Dest">
    /// The list that receives the selected <see cref="TCurrencyInfo"/> objects.
    /// </param>
    /// <seealso cref="SetSelection"/>
    {$Endregion}
    Procedure GetSelection(Dest : TCurrencyList);
    {$Region 'xmldoc'}
    /// <summary>
    /// Selects the items that are identified by a specified list of <see cref="TCurrencyInfo"/> objects.
    /// </summary>
    /// <param name="Source">
    /// The list of <see cref="TCurrencyInfo"/> objects to select.
    /// </param>
    /// <seealso cref="GetSelection"/>
    /// <seealso cref="MultiSelect"/>
    {$Endregion}
    Procedure SetSelection(Source : TReadonlyCurrencyList);
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets which value of <see cref="TCurrencyInfo.DisplayNames"/> should be
    /// displayed as the label of items.
    /// </summary>
    {$Endregion}
    Property DisplayName : TCurrencyDisplayName Read fDisplayName Write SetDisplayName Default crnEnglishName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the currently selected <see cref="TCurrencyInfo"/> object.
    /// </summary>
    {$Endregion}
    Property ItemSelected : TCurrencyInfo Read GetItemSelected Write SetItemSelected;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the <see cref="TCurrencyInfo"/> objects in the control.
    /// </summary>
    {$Endregion}
    Property Items : TCurrencyList Read fCurrencies Write SetCurrencies;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TCurrencyListBox is a list box control that represents a list of
/// <see cref="TCurrencyInfo"/> objects.
/// </summary>
/// <remarks>
/// Use TCurrencyListBox to enable users to select a <see cref="TCurrencyInfo"/>
/// object from a list.
///
/// TCurrencyListBox also implements properties to specify a country flag icon,
/// along with its appearance and placement for each individual item.
///
/// TCurrencyListBox publishes many of the properties, events, and methods of
/// <see cref="TCustomCurrencyListBox"/>, but does not introduce any new behavior.
/// </remarks>
/// <group name="Components"/>
{$Endregion}
{$IFDEF COMPILER_XE2_UP}

  [ComponentPlatformsAttribute(pidWin32 Or pidWin64)]
  {$ENDIF}
  TCurrencyListBox = Class(TCustomCurrencyListBox)
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
    /// Gets or sets which value of <see cref="TCurrencyInfo.DisplayNames"/> should be
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
    /// Gets or sets whether the user can select a sequential range of items in the list box.
    /// </summary>
    {$Endregion}
    Property ExtendedSelect;
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
    /// Lists the <see cref="TCurrencyInfo"/> objects in the control.
    /// </summary>
    {$Endregion}
    Property Items;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the currently selected <see cref="TCurrencyInfo"/> object.
    /// </summary>
    {$Endregion}
    Property ItemSelected;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the margins of the control.
    /// </summary>
    {$Endregion}
    Property Margins;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the user can select more than one item at a time.
    /// </summary>
    {$Endregion}
    Property MultiSelect;
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
/// TCustomCurrencyCheckListBox is the base class for check list box controls that
/// represent a list of <see cref="TCurrencyInfo"/> objects.
/// </summary>
/// <remarks>
/// Use TCustomCurrencyCheckListBox as a base class when defining controls that represent
/// a check list of <see cref="TCurrencyInfo"/> objects. TCustomCurrencyCheckListBox has
/// properties and methods to facilitate displaying, retrieving, sorting, and selecting
/// of the stored <see cref="TCurrencyInfo"/> objects.
///
/// TCustomCurrencyCheckListBox also implements properties to specify a country flag
/// icon, along with its appearance and placement for each individual item.
/// </remarks>
{$Endregion}

  TCustomCurrencyCheckListBox = Class(TCustomFlagCheckListBox)
   Private
    fCurrencies  : TCurrencyList;
    fDisplayName : TCurrencyDisplayName;
    Procedure SetCurrencies(Value : TCurrencyList);
    Procedure SetItemSelected(Value : TCurrencyInfo);
    Function GetItemSelected : TCurrencyInfo;
    Procedure SetDisplayName(Value : TCurrencyDisplayName);
    Procedure CurrenciesChanged(Sender : TObject);
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Fills the internal list of items by display name of the <see cref="TCurrencyInfo"/>
    /// objects in the <see cref="Items"/> property.
    /// </summary>
    {$Endregion}
    Procedure RebuildInternalItems; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a country flag icon for the specified item.
    /// </summary>
    /// <param name="Index">
    /// The index of the item.
    /// </param>
    /// <returns>
    /// The index of a country flag icon or -1 if no icon is available.
    /// </returns>
    {$Endregion}
    Function GetImageIndex(Index : Integer) : Integer; Override;
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
    /// Fills the <see cref="Items"/> property with all the known <see cref="TCurrencyInfo"/>
    /// objects.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> if the control is not linked to a <see cref="TLocalizer"/>
    /// component, otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="18nCore.TWorld.Currencys"/>
    {$Endregion}
    Function CollectAll : Boolean; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Retrieves the list of checked <see cref="TCurrencyInfo"/> objects.
    /// </summary>
    /// <param name="Dest">
    /// The list that receives the checked <see cref="TCurrencyInfo"/> objects.
    /// </param>
    /// <param name="AllowDisabled">
    /// Determines whether the disabled items can be retrieved.
    /// </param>
    /// <seealso cref="SetSelection"/>
    {$Endregion}
    Procedure GetSelection(Dest : TCurrencyList; AllowDisabled : Boolean = True); Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Checkes the items that are identified by a specified list of <see cref="TCurrencyInfo"/> objects.
    /// </summary>
    /// <param name="Source">
    /// The list of <see cref="TCurrencyInfo"/> objects to select.
    /// </param>
    /// <param name="AllowDisabled">
    /// Determines whether the disabled items can be altered.
    /// </param>
    /// <seealso cref="GetSelection"/>
    {$Endregion}
    Procedure SetSelection(Source : TReadonlyCurrencyList; AllowDisabled : Boolean = True); Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets which value of <see cref="TCurrencyInfo.DisplayNames"/> should be
    /// displayed as the label of items.
    /// </summary>
    {$Endregion}
    Property DisplayName : TCurrencyDisplayName Read fDisplayName Write SetDisplayName Default crnEnglishName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the currently selected <see cref="TCurrencyInfo"/> object.
    /// </summary>
    {$Endregion}
    Property ItemSelected : TCurrencyInfo Read GetItemSelected Write SetItemSelected;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the <see cref="TCurrencyInfo"/> objects in the control.
    /// </summary>
    {$Endregion}
    Property Items : TCurrencyList Read fCurrencies Write SetCurrencies;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TCurrencyCheckListBox is a check list box control that represents a list of
/// <see cref="TCurrencyInfo"/> objects.
/// </summary>
/// <remarks>
/// Use TCurrencyCheckListBox to enable users to select multiple <see cref="TCurrencyInfo"/>
/// objects from a list.
///
/// TCurrencyCheckListBox also implements properties to specify a country flag icon,
/// along with its appearance and placement for each individual item.
///
/// TCurrencyCheckListBox publishes many of the properties, events, and methods of
/// <see cref="TCustomCurrencyCheckListBox"/>, but does not introduce any new behavior.
/// </remarks>
/// <group name="Components"/>
{$Endregion}
{$IFDEF COMPILER_XE2_UP}

  [ComponentPlatformsAttribute(pidWin32 Or pidWin64)]
  {$ENDIF}
  TCurrencyCheckListBox = Class(TCustomCurrencyCheckListBox)
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
    /// Gets or sets whether the check boxes can be in a "grayed" state.
    /// </summary>
    {$Endregion}
    Property AllowGrayed;
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
    /// Gets or sets which value of <see cref="TCurrencyInfo.DisplayNames"/> should be
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
    /// Gets or sets whether the check boxes appear three-dimensional.
    /// </summary>
    {$Endregion}
    Property Flat;
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
    /// Lists the <see cref="TCurrencyInfo"/> objects in the control.
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
    /// Occurs when the user selects or deselects an item's check box.
    /// </summary>
    {$Endregion}
    Property OnClickCheck;
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
/// Returns the size of the check box drawn by the <see cref="DrawCheckBox"/> global function.
/// </summary>
/// <returns>
/// The width and height of the check box, in pixels.
/// </returns>
/// <seealso cref="DrawCheckBox"/>
{$Endregion}

 Function GetCheckBoxSize : TSize;

 {$Region 'xmldoc'}
 /// <summary>
 /// Draws a check box on a specified device context.
 /// </summary>
 /// <param name="DC">
 /// Handle to the device context.
 /// </param>
 /// <param name="Rect">
 /// Specifies the boundaries that the check box will be centered in.
 /// </param>
 /// <param name="State">
 /// Specifies the state of the check box.
 /// </param>
 /// <param name="DrawState">
 /// Specifies how the check box should appear.
 /// </param>
 /// <param name="Flat">
 /// Indicates whether the check box appears three-dimensional.
 /// </param>
 /// <param name="Themed">
 /// Indicates whether the check box should be drawn using the Windows theme.
 /// </param>
 /// <returns>
 /// The bounding rectangle of the check box.
 /// </returns>
 /// <seealso cref="GetCheckBoxSize"/>
 {$Endregion}
 Function DrawCheckBox(DC : HDC; Const Rect : TRect; State : TCheckBoxState; DrawState : TPartDrawState; Flat, Themed : Boolean) : TRect;

 {$Region 'xmldoc'}
 /// <summary>
 /// Returns the size of the drop-down button drawn by the <see cref="DrawDropDown"/> global function.
 /// </summary>
 /// <returns>
 /// The width and height of the drop-down button, in pixels.
 /// </returns>
 /// <seealso cref="DrawDropDown"/>
 {$Endregion}
 Function GetDropDownSize : TSize;

 {$Region 'xmldoc'}
 /// <summary>
 /// Draws a drop-down button on a specified device context.
 /// </summary>
 /// <param name="DC">
 /// Handle to the device context.
 /// </param>
 /// <param name="Rect">
 /// Specifies the boundaries that the drop-down button will be centered in.
 /// </param>
 /// <param name="DrawState">
 /// Specifies how the drop-down button should appear.
 /// </param>
 /// <param name="Themed">
 /// Indicates whether the drop-down button should be drawn using the Windows theme.
 /// </param>
 /// <returns>
 /// The bounding rectangle of the drop-down button.
 /// </returns>
 /// <seealso cref="GetDropDownSize"/>
 {$Endregion}
 Procedure DrawDropDown(DC : HDC; Const Rect : TRect; DrawState : TPartDrawState; Themed : Boolean);

Implementation

 Uses
  UxTheme, SysUtils, Types, CommCtrl, Themes, RTLConsts, CheckLst;

{$R i18nFlags_16x11.res}

 Const
  HorzSpacing = 2;
  VertSpacing = 1;

{$IFNDEF COMPILER_XE2_UP}

 Type
  TCustomStyleServices = Class(TThemeServices)
   Public
    Function Enabled : Boolean;
  End;

 Function TCustomStyleServices.Enabled : Boolean;
  Begin
   Result := ThemesEnabled;
  End;

 Function StyleServices : TCustomStyleServices;
  Begin
   Result := TCustomStyleServices(ThemeServices);
  End;
{$ENDIF}

{ Helper Functions }

 Var
  CheckBoxSize : TSize;

 Function GetCheckBoxSize : TSize;
  Begin
   Result := CheckBoxSize;
  End;

 Function CalcCheckBoxSize : TSize;
  Begin
   With TBitmap.Create Do
    Try
     Handle    := LoadBitmap(0, PChar(OBM_CHECKBOXES));
     Result.cx := Width Div 4;
     Result.cy := Height Div 3;
    Finally
     Free;
    End;
  End;

 Function DrawCheckBox(DC : HDC; Const Rect : TRect; State : TCheckBoxState; DrawState : TPartDrawState; Flat, Themed : Boolean) : TRect;
  Var
   DrawRect       : TRect Absolute Result;
   DrawDetail     : TThemedButton;
   DrawFlag       : Integer;
   OldRgn, Rgn    : HRgn;
   Brush          : HBRUSH;
   ElementDetails : TThemedElementDetails;
  Begin
   OldRgn          := 0;
   DrawRect.Left   := (Rect.Left + Rect.Right - CheckBoxSize.cx) Div 2;
   DrawRect.Top    := (Rect.Top + Rect.Bottom - CheckBoxSize.cy) Div 2;
   DrawRect.Right  := DrawRect.Left + CheckBoxSize.cx;
   DrawRect.Bottom := DrawRect.Top + CheckBoxSize.cy;
   If Not RectVisible(DC, DrawRect) Then
    Exit;
   If Flat Then
    Begin
     OldRgn := CreateRectRgn(0, 0, 0, 0);
     GetClipRgn(DC, OldRgn);
     With DrawRect Do
      Rgn := CreateRectRgn(Left + 2, Top + 2, Right - 2, Bottom - 2);
     SelectClipRgn(DC, Rgn);
     DeleteObject(Rgn);
    End;
   If Themed And StyleServices.Enabled Then
    Begin
     Case State Of
      cbChecked :
       Case DrawState Of
        pdsNormal :
         DrawDetail := tbCheckBoxCheckedNormal;
        pdsHot :
         DrawDetail := tbCheckBoxCheckedHot;
        pdsPressed :
         DrawDetail := tbCheckBoxCheckedPressed;
       Else // pdsDisabled
         DrawDetail := tbCheckBoxCheckedDisabled;
       End;
      cbUnchecked :
       Case DrawState Of
        pdsNormal :
         DrawDetail := tbCheckBoxUncheckedNormal;
        pdsHot :
         DrawDetail := tbCheckBoxUncheckedHot;
        pdsPressed :
         DrawDetail := tbCheckBoxUncheckedPressed;
       Else // pdsDisabled
         DrawDetail := tbCheckBoxUncheckedDisabled;
       End;
     Else // cbGrayed
       Case DrawState Of
        pdsNormal :
         DrawDetail := tbCheckBoxMixedNormal;
        pdsHot :
         DrawDetail := tbCheckBoxMixedHot;
        pdsPressed :
         DrawDetail := tbCheckBoxMixedPressed;
       Else // pdsDisabled
         DrawDetail := tbCheckBoxMixedDisabled;
       End;
     End;
     ElementDetails := StyleServices.GetElementDetails(DrawDetail);
     StyleServices.DrawElement(DC, ElementDetails, DrawRect);
    End
   Else
    Begin
     Case State Of
      cbChecked :
       DrawFlag := DFCS_BUTTONCHECK Or DFCS_CHECKED;
      cbUnchecked :
       DrawFlag := DFCS_BUTTONCHECK;
     Else // cbGrayed
       DrawFlag := DFCS_BUTTON3STATE Or DFCS_CHECKED;
     End;
     Case DrawState Of
      pdsDisabled : DrawFlag := DrawFlag Or DFCS_INACTIVE;
      pdsHot      : DrawFlag := DrawFlag Or DFCS_HOT;
      pdsPressed  : DrawFlag := DrawFlag Or DFCS_PUSHED;
     End;
     DrawFrameControl(DC, DrawRect, DFC_BUTTON, DrawFlag);
    End;
   If Flat Then
    Begin
     InflateRect(DrawRect, -1, -1);
     SelectClipRgn(DC, OldRgn);
     DeleteObject(OldRgn);
     Brush := CreateSolidBrush(ColorToRGB(clBtnShadow));
     FrameRect(DC, DrawRect, Brush);
     DeleteObject(Brush);
    End;
  End;

 Var
  DropDownSize : TSize;

 Function GetDropDownSize : TSize;
  Begin
   Result := DropDownSize;
  End;

 Function CalcDropDownSize : TSize;
  Begin
   Result.cx := GetSystemMetrics(SM_CXVSCROLL);
   Result.cy := GetSystemMetrics(SM_CYVSCROLL);
  End;

 Procedure DrawDropDown(DC : HDC; Const Rect : TRect; DrawState : TPartDrawState; Themed : Boolean);
  Var
   DrawDetail     : TThemedComboBox;
   DrawFlag       : Integer;
   ElementDetails : TThemedElementDetails;
  Begin
   If Not RectVisible(DC, Rect) Then
    Exit;
   If Themed And StyleServices.Enabled Then
    Begin
     Case DrawState Of
      pdsNormal :
       DrawDetail := tcDropDownButtonNormal;
      pdsHot :
       DrawDetail := tcDropDownButtonHot;
      pdsPressed :
       DrawDetail := tcDropDownButtonPressed;
     Else // pdsDisabled
       DrawDetail := tcDropDownButtonDisabled;
     End;
     ElementDetails := StyleServices.GetElementDetails(DrawDetail);
     StyleServices.DrawElement(DC, ElementDetails, Rect);
    End
   Else
    Begin
     DrawFlag := DFCS_SCROLLCOMBOBOX;
     Case DrawState Of
      pdsDisabled : DrawFlag := DrawFlag Or DFCS_INACTIVE;
      pdsHot      : DrawFlag := DrawFlag Or DFCS_HOT;
      pdsPressed  : DrawFlag := DrawFlag Or DFCS_PUSHED;
     End;
     DrawFrameControl(DC, Rect, DFC_SCROLL, DrawFlag);
    End;
  End;

{$IFDEF COMPILER2010_UP}

 Procedure FillGlassRect(Canvas : TCanvas; Rect : TRect);
  Var
   MemDC       : HDC;
   PaintBuffer : HPAINTBUFFER;
  Begin
   PaintBuffer := BeginBufferedPaint(Canvas.Handle, Rect, BPBF_TOPDOWNDIB, Nil, MemDC);
   Try
    FillRect(MemDC, Rect, Canvas.Brush.Handle);
    BufferedPaintMakeOpaque(PaintBuffer, Rect);
   Finally
    EndBufferedPaint(PaintBuffer, True);
   End;
  End;
{$ENDIF}

 Function FindFlags(Root : TComponent) : TCustomFlagImageList;
  Var
   i : Integer;
  Begin
   Result := Nil;
   If Assigned(Root) Then
    For i := 0 To Root.ComponentCount - 1 Do
     If Root.Components[i] Is TCustomFlagImageList Then
      Begin
       Result := TCustomFlagImageList(Root.Components[i]);
       Exit;
      End;
  End;

{ TCustomFlagImageList }

 Constructor TCustomFlagImageList.Create(AOwner : TComponent);
  Begin
   Inherited Create(AOwner);
   Regions    := TKeyLookup<String, Integer>.Create;
   BlendColor := clFuchsia;
   HelperDC   := CreateCompatibleDC(0);
   Try
    PrepareFlags;
   Finally
    DeleteDC(HelperDC);
   End;
  End;

{$IFDEF COMPILER2010_UP}

 Function TCustomFlagImageList.GetColorDepth : TColorDepth;
  Begin
   Result := Inherited ColorDepth;
  End;
{$ENDIF}
{$IFDEF COMPILER2010_UP}

 Procedure TCustomFlagImageList.SetColorDepth(Value : TColorDepth);
  Begin
   If Inherited ColorDepth <> Value Then
    Begin
     Inherited ColorDepth := Value;
     PrepareFlags;
    End;
  End;
{$ENDIF}

 Procedure TCustomFlagImageList.DefineProperties(Filer : TFiler);
  Var
   Stream : TMemoryStream;
  Begin
   Stream := TMemoryStream.Create;
   Try
    WriteData(Stream);
    Handle := 0;
    Inherited DefineProperties(Filer);
    Stream.Position := 0;
    ReadData(Stream);
   Finally
    Stream.Free;
   End;
  End;

 Destructor TCustomFlagImageList.Destroy;
  Begin
   Regions.Free;
   Inherited Destroy;
  End;

 Procedure TCustomFlagImageList.NormalizeImage(Var hImage : HBITMAP; TranparentPixel : TTransparentPixel);
  Var
   Image           : TBitmap;
   NormalizedImage : TBitmap;
  Begin
   NormalizedImage := TBitmap.Create;
   Try
    NormalizedImage.Canvas.Brush.Color := BlendColor;
    NormalizedImage.Width              := Width;
    NormalizedImage.Height             := Height;
    If hImage <> 0 Then
     Begin
      Image := TBitmap.Create;
      Try
       Image.Handle      := hImage;
       Image.Transparent := (TranparentPixel <> tpNone);
       Case TranparentPixel Of
        tpTopLeft     : Image.TransparentColor := Image.Canvas.Pixels[0, 0];
        tpTopRight    : Image.TransparentColor := Image.Canvas.Pixels[Image.Width - 1, 0];
        tpBottomRight : Image.TransparentColor := Image.Canvas.Pixels[Image.Width - 1, Image.Height - 1];
        tpBottomLeft  : Image.TransparentColor := Image.Canvas.Pixels[0, Image.Height - 1];
       End;
       NormalizedImage.Canvas.Draw(
       (NormalizedImage.Width - Image.Width) Div 2,
       (NormalizedImage.Height - Image.Height) Div 2, Image);
      Finally
       Image.Free;
      End;
     End;
    hImage := NormalizedImage.ReleaseHandle;
   Finally
    NormalizedImage.Free;
   End;
  End;

 Procedure TCustomFlagImageList.NormalizeFlag(Var hImage : HBITMAP; Const ISO_3166_2 : String);
  Var
   Info : TBitmapInfo;
  Begin
   FillChar(Info, SizeOf(Info), 0);
   Info.bmiHeader.biSize := SizeOf(Info.bmiHeader);
   GetDIBits(HelperDC, hImage, 0, 0, Nil, Info, DIB_RGB_COLORS);
   If (Info.bmiHeader.biWidth <> Width) Or (Info.bmiHeader.biHeight <> Height) Then
    Begin
     If ISO_3166_2 = 'NP' Then            // Nepal's flag is triangular
      NormalizeImage(hImage, tpTopRight)
     Else
      NormalizeImage(hImage);
    End;
  End;

 Function TCustomFlagImageList.AddFlag(Const ISO_3166_2 : String; hImage : HBITMAP) : Integer;
  Begin
   NormalizeFlag(hImage, ISO_3166_2);
   Result := ImageList_AddMasked(Handle, hImage, BlendColor);
   Regions.Add(ISO_3166_2, Result);
  End;

 Function TCustomFlagImageList.ImageIndexOf(Const ISO_3166_2 : String) : Integer;
  Begin
   If Not Regions.Retrieve(UpperCase(ISO_3166_2), Result) Then
    Result := -1;
  End;

 Function TCustomFlagImageList.ImageIndexOf(Territory : TTerritoryInfo) : Integer;
  Begin
   If Not Assigned(Territory) Or Not Regions.Retrieve(Territory.Code2, Result) Then
    Result := -1;
  End;

 Function TCustomFlagImageList.ImageIndexOf(Culture : TCultureInfo) : Integer;
  Begin
   If Not Assigned(Culture) Or Not Assigned(Culture.Country) Or
   Not Regions.Retrieve(Culture.Country.Code2, Result)
   Then
    Result := -1;
  End;

 Function TCustomFlagImageList.ImageIndexOf(Currency : TCurrencyInfo) : Integer;
  Var
   Code : String;
  Begin
   If Assigned(Currency) Then
    Begin
     If Assigned(Currency.OriginCountry) Then
      Code := Currency.OriginCountry.Code2
     Else
      Code := 'EU';
     If Not Regions.Retrieve(Code, Result) Then
      Result := -1;
    End
   Else
    Result := -1;
  End;

{ TCustomResFlagImageList }

 Function EnumBitmapsCallback(hModule : hModule; lpszType, lpszName : PChar; lParam : lParam) : Integer; Stdcall;
  Var
   IL         : TCustomResFlagImageList Absolute lParam;
   ISO_3166_2 : String;
  Begin
   If (lpszType = RT_BITMAP) And (ULONG_PTR(lpszName) Shr 16 <> 0) And
   (AnsiStrPos(lpszName, PChar(IL.GetResourcePrefix)) = lpszName) Then
    Begin
     SetString(ISO_3166_2, lpszName + Length(IL.GetResourcePrefix),
     StrLen(lpszName) - Cardinal(Length(IL.GetResourcePrefix)));
     IL.AddFlagFromResource(ISO_3166_2, lpszName, hModule);
    End;
   Result := 1;
  End;

 Function TCustomResFlagImageList.AddFlagFromResource(Const ISO_3166_2, ResName : String; hModule : hModule) : Integer;
  Var
   hImage : HBITMAP;
  Begin
   If hModule = 0 Then
    hModule := HInstance;
   hImage   := LoadImage(hModule, PChar(ResName), IMAGE_BITMAP, 0, 0, LR_CREATEDIBSECTION);
   Try
    Result := AddFlag(UpperCase(ISO_3166_2), hImage);
   Finally
    DeleteObject(hImage);
   End;
  End;

 Procedure TCustomResFlagImageList.PrepareFlags;
  Begin
   Handle := 0;
   With GetFlagSize Do
    SetSize(cx, cy);
   EnumResourceNames(HInstance, RT_BITMAP, @EnumBitmapsCallback, lParam(Self));
  End;

{ TFlagImageList }

 Function TFlagImageList.GetFlagSize : TSize;
  Begin
   Result.cx := 16;
   Result.cy := 11;
  End;

 Function TFlagImageList.GetResourcePrefix : String;
  Begin
   Result := 'FLAG_';
  End;

{ TCustomImageLabel }

 Constructor TCustomImageLabel.Create(AOwner : TComponent);
  Begin
   Inherited Create(AOwner);
   fImagesLink          := TChangeLink.Create;
   fImagesLink.OnChange := ImagesChanged;
   fPadding             := TPadding.Create(Self);
   fPadding.OnChange    := PaddingChanged;
   fBorderColor         := clNone;
   fImageIndex          := -1;
   fSpacing             := 4;
  End;

 Destructor TCustomImageLabel.Destroy;
  Begin
   Images := Nil;
   fImagesLink.Free;
   fPadding.Free;
   Inherited Destroy;
  End;

 Procedure TCustomImageLabel.SetSpacing(Value : Integer);
  Begin
   If Spacing <> Value Then
    Begin
     fSpacing := Value;
     If Assigned(Images) And (ImageIndex >= 0) Then
      Begin
       AdjustBounds;
       Invalidate;
      End;
    End;
  End;

 Procedure TCustomImageLabel.SetBorderWidth(Value : TBorderWidth);
  Begin
   If BorderWidth <> Value Then
    Begin
     fBorderWidth := Value;
     AdjustBounds;
     Invalidate;
    End;
  End;

 Procedure TCustomImageLabel.SetBorderColor(Value : TColor);
  Begin
   If BorderColor <> Value Then
    Begin
     fBorderColor := Value;
     If BorderWidth <> 0 Then
      Invalidate;
    End;
  End;

 Function TCustomImageLabel.GetImageIndex : TImageIndex;
  Begin
   Result := fImageIndex;
  End;

 Procedure TCustomImageLabel.SetImageIndex(Value : TImageIndex);
  Var
   NeedsAdjustment : Boolean;
  Begin
   If ImageIndex <> Value Then
    Begin
     NeedsAdjustment := (ImageIndex < 0) Or (Value < 0);
     fImageIndex     := Value;
     If Assigned(Images) And NeedsAdjustment Then
      AdjustBounds;
     Invalidate;
    End;
  End;

 Procedure TCustomImageLabel.SetImages(Value : TCustomImageList);
  Begin
   If Images <> Value Then
    Begin
     If Assigned(Images) Then
      Begin
       Images.RemoveFreeNotification(Self);
       Images.UnRegisterChanges(fImagesLink);
      End;
     fImages := Value;
     If Assigned(Images) Then
      Begin
       Images.FreeNotification(Self);
       Images.RegisterChanges(fImagesLink);
      End;
     fImagesLink.Change;
    End;
  End;

 Procedure TCustomImageLabel.SetPadding(Value : TPadding);
  Begin
   Padding.Assign(Value);
  End;

 Procedure TCustomImageLabel.ImagesChanged(Sender : TObject);
  Begin
   AdjustBounds;
   Invalidate;
  End;

 Procedure TCustomImageLabel.PaddingChanged(Sender : TObject);
  Begin
   AdjustBounds;
   Invalidate;
  End;

 Procedure TCustomImageLabel.CNVisibleChanged(Var Message : TMessage);
  Begin
   Inherited;
   If Visible Then
    Begin
     AdjustBounds;
     Invalidate;
    End;
  End;

 Procedure TCustomImageLabel.Notification(AComponent : TComponent; Operation : TOperation);
  Begin
   Inherited Notification(AComponent, Operation);
   If (Operation = opRemove) And (AComponent = Images) Then
    Images := Nil;
  End;

 Procedure TCustomImageLabel.DoDrawText(Var Rect : TRect; DrawFlags : Integer);
  Var
   ConsiderImage : Boolean;
   ConsiderText  : Boolean;
   x, y, i       : Integer;
   tm            : TTextMetric;
  Begin
   ConsiderText  := (GetLabelText <> '');
   ConsiderImage := Assigned(Images) And (ImageIndex >= 0);
   If (DrawFlags And DT_CALCRECT) = DT_CALCRECT Then
    Begin
     If ConsiderText Then
      Begin
       If ConsiderImage Then
        Dec(Rect.Right, Images.Width + Spacing);
       Inherited DoDrawText(Rect, DrawFlags);
       If ConsiderImage Then
        Begin
         Inc(Rect.Right, Images.Width + Spacing);
         If Images.Height > (Rect.Bottom - Rect.Top) Then
          Rect.Bottom := Rect.Top + Images.Height;
        End;
      End
     Else If ConsiderImage Then
      Begin
       Rect.Right  := Rect.Left + Images.Width;
       Rect.Bottom := Rect.Top + Images.Height;
      End
     Else If Not(csDesigning In ComponentState) Then
      Begin
       Rect.Right  := Rect.Left;
       Rect.Bottom := Rect.Top;
      End;
    End
   Else
    Begin
     If ConsiderImage Then
      Begin
       If UseRightToLeftAlignment Then
        Begin
         x := Rect.Right - Images.Width;
         Dec(Rect.Right, Images.Width + Spacing);
        End
       Else
        Begin
         x := Rect.Left;
         Inc(Rect.Left, Images.Width + Spacing);
        End;
       If ConsiderText Then
        Begin
         GetTextMetrics(Canvas.Handle, tm);
         i := (tm.tmHeight - Images.Height) Div 2;
         If i < 0 Then
          Begin
           y := Rect.Top;
           If (Rect.Bottom - Rect.Top) = Images.Height Then
            Inc(Rect.Top, -i);
          End
         Else
          y := Rect.Top + i;
         Inherited DoDrawText(Rect, DrawFlags);
        End
       Else
        y := (Rect.Top + Rect.Bottom - Images.Height) Div 2;
       Images.Draw(Canvas, x, y, GetImageIndex, Enabled);
      End
     Else If ConsiderText Then
      Inherited DoDrawText(Rect, DrawFlags)
    End;
  End;

 Procedure TCustomImageLabel.AdjustBounds;
  Const
   WordWraps : Array[Boolean] Of Word = (0, DT_WordBREAK);
  Var
   DC           : HDC;
   x            : Integer;
   Rect         : TRect;
   TheAlignment : TAlignment;
  Begin
   If (([csReading, csLoading, csDestroying] * ComponentState) = []) And
   AutoSize And (Visible Or (csDesigning In ComponentState)) Then
    Begin
     Rect := ClientRect;
     Dec(Rect.Right, Padding.Left + Padding.Right + 2 * BorderWidth);
     Dec(Rect.Bottom, Padding.Top + Padding.Bottom + 2 * BorderWidth);
     DC := GetDC(0);
     Try
      Canvas.Handle := DC;
      DoDrawText(Rect, DT_EXPANDTABS Or DT_CALCRECT Or WordWraps[WordWrap]);
      Canvas.Handle := 0;
     Finally
      ReleaseDC(0, DC);
     End;
     Inc(Rect.Right, Padding.Left + Padding.Right + 2 * BorderWidth);
     Inc(Rect.Bottom, Padding.Top + Padding.Bottom + 2 * BorderWidth);
     x            := Left;
     TheAlignment := Alignment;
     If UseRightToLeftAlignment Then
      ChangeBiDiModeAlignment(TheAlignment);
     If TheAlignment = taRightJustify Then
      Inc(x, Width - Rect.Right);
     SetBounds(x, Top, Rect.Right, Rect.Bottom);
    End;
  End;

 Procedure TCustomImageLabel.Paint;
  Const
   Alignments : Array[TAlignment] Of Word = (DT_LEFT, DT_RIGHT, DT_CENTER);
   WordWraps : Array[Boolean] Of Word = (0, DT_WordBREAK);
  Var
   Rect, CalcRect : TRect;
   DrawStyle      : LongInt;
   TheAlignment   : TAlignment;
  Begin
   With Canvas Do
    Begin
     Rect := ClientRect;
     If Not Transparent Then
      Begin
       Brush.Color := Self.Color;
       Brush.Style := bsSolid;
       {$IFDEF COMPILER2010_UP}
       If Not(csGlassPaint In ControlState) Then
        FillRect(Rect)
       Else
        FillGlassRect(Canvas, Rect);
       {$ELSE}
       FillRect(Rect);
       {$ENDIF}
      End;
     Brush.Style := bsClear;
     If BorderWidth <> 0 Then
      Begin
       If BorderColor <> clNone Then
        Begin
         If BorderColor = clDefault Then
          Pen.Color := Font.Color
         Else
          Pen.Color := BorderColor;
         Pen.Width  := BorderWidth;
         Pen.Style  := psInsideFrame;
         Rectangle(Rect);
        End;
       InflateRect(Rect, -BorderWidth, -BorderWidth);
      End;
     Inc(Rect.Left, Padding.Left);
     Inc(Rect.Top, Padding.Top);
     Dec(Rect.Right, Padding.Right);
     Dec(Rect.Bottom, Padding.Bottom);
     DrawStyle := DT_EXPANDTABS Or WordWraps[WordWrap] Or Alignments[Alignment];
     If Not AutoSize Or (Align <> alNone) Then
      Begin
       CalcRect := Rect;
       DoDrawText(CalcRect, DrawStyle Or DT_CALCRECT);
       TheAlignment := Alignment;
       If UseRightToLeftAlignment Then
        ChangeBiDiModeAlignment(TheAlignment);
       Case TheAlignment Of
        taRightJustify : OffsetRect(CalcRect, Rect.Right - CalcRect.Right, 0);
        taCenter       : OffsetRect(CalcRect, (Rect.Right - CalcRect.Right) Div 2, 0);
       End;
       Case Layout Of
        tlBottom : OffsetRect(CalcRect, 0, Rect.Bottom - CalcRect.Bottom);
        tlCenter : OffsetRect(CalcRect, 0, (Rect.Bottom - CalcRect.Bottom) Div 2);
       End;
       DoDrawText(CalcRect, DrawStyle);
      End
     Else
      DoDrawText(Rect, DrawStyle);
    End;
  End;

{ TCustomFlagLabel }

 Constructor TCustomFlagLabel.Create(AOwner : TComponent);
  Begin
   Inherited Create(AOwner);
   If csDesigning In ComponentState Then
    Flags := FindFlags(AOwner);
  End;

 Procedure TCustomFlagLabel.SetFlags(Value : TCustomFlagImageList);
  Begin
   Inherited Images := Value;
  End;

 Function TCustomFlagLabel.GetFlags : TCustomFlagImageList;
  Begin
   Result := TCustomFlagImageList(Inherited Images);
  End;

{ TCustomFlagBox }

 Constructor TCustomFlagBox.Create(AOwner : TComponent);
  Begin
   Inherited Create(AOwner);
   Style      := csDropDownList;
   fFlagsLink := TChangeLink.Create;
   If csDesigning In ComponentState Then
    Flags              := FindFlags(AOwner);
   fFlagsLink.OnChange := FlagsChanged;
   fItemIndex          := -1;
  End;

 Destructor TCustomFlagBox.Destroy;
  Begin
   Flags := Nil;
   fFlagsLink.Free;
   Inherited Destroy;
  End;

 Procedure TCustomFlagBox.FlagsChanged(Sender : TObject);
  Begin
   ResetItemHeight;
   Invalidate;
  End;

 Procedure TCustomFlagBox.SetSorted(Value : Boolean);
  Begin
   If Sorted <> Value Then
    Begin
     fSorted := Value;
     RebuildInternalItems;
    End;
  End;

 Procedure TCustomFlagBox.SetFlagPosition(Value : TFlagPosition);
  Begin
   If FlagPosition <> Value Then
    Begin
     fFlagPosition := Value;
     Invalidate;
    End;
  End;

 Procedure TCustomFlagBox.SetFlags(Value : TCustomFlagImageList);
  Begin
   If Flags <> Value Then
    Begin
     If Assigned(Flags) Then
      Begin
       Flags.RemoveFreeNotification(Self);
       Flags.UnRegisterChanges(fFlagsLink);
      End;
     fFlags := Value;
     If Assigned(Flags) Then
      Begin
       Flags.FreeNotification(Self);
       Flags.RegisterChanges(fFlagsLink);
      End;
     fFlagsLink.Change;
    End;
  End;

 Function TCustomFlagBox.GetItemIndex : Integer;
  Begin
   If ItemsReady Then
    Result := Inherited GetItemIndex
   Else
    Result := fItemIndex;
  End;

 Procedure TCustomFlagBox.SetItemIndex(Const Value : Integer);
  Begin
   If ItemsReady Then
    Inherited SetItemIndex(Value)
   Else
    fItemIndex := Value;
  End;

 Function TCustomFlagBox.DoDrawItemLabel(Index : Integer; Var Rect : TRect; State : TOwnerDrawState; Var TheLabel : String) : Boolean;
  Begin
   Result := True;
   If Assigned(OnDrawItemLabel) Then
    OnDrawItemLabel(Self, Index, Rect, State, TheLabel, Result);
  End;

 Procedure TCustomFlagBox.DoItemsChange;
  Begin
   If Assigned(OnItemsChange) Then
    OnItemsChange(Self);
  End;

 Procedure TCustomFlagBox.DrawItem(Index : Integer; Rect : TRect; State : TOwnerDrawState);
  Var
   TheLabel : String;
   x, y     : Integer;
  Begin
   Canvas.FillRect(Rect);
   SetBkMode(Canvas.Handle, Transparent);
   If Index >= 0 Then
    Begin
     If Assigned(Flags) Then
      Begin
       If UseRightToLeftAlignment Xor (FlagPosition = fpAfterLabel) Then
        Begin
         x := Rect.Right - Flags.Width - HorzSpacing;
         Dec(Rect.Right, Flags.Width + 2 * HorzSpacing);
        End
       Else
        Begin
         x := Rect.Left + HorzSpacing;
         Inc(Rect.Left, Flags.Width + 2 * HorzSpacing);
        End;
       y := (Rect.Top + Rect.Bottom - Flags.Height) Div 2;
       Flags.Draw(Canvas, x, y, GetImageIndex(Index));
      End;
     TheLabel := GetLabelText(Index);
     If DoDrawItemLabel(Index, Rect, State, TheLabel) Then
      Begin
       InflateRect(Rect, -HorzSpacing, 0);
       DrawText(Canvas.Handle, PChar(TheLabel), Length(TheLabel), Rect,
       DrawTextBiDiModeFlags(DT_LEFT Or DT_VCENTER Or DT_EXPANDTABS Or
       DT_SINGLELINE Or DT_NOPREFIX));
      End;
    End;
  End;

 Procedure TCustomFlagBox.Notification(AComponent : TComponent; Operation : TOperation);
  Begin
   Inherited Notification(AComponent, Operation);
   If (Operation = opRemove) And (AComponent = Flags) Then
    Flags := Nil;
  End;

 Procedure TCustomFlagBox.CreateParams(Var Params : TCreateParams);
  Begin
   Inherited CreateParams(Params);
   Params.Style := Params.Style Or CBS_OWNERDRAWFIXED Or CBS_DROPDOWNLIST;
  End;

 Procedure TCustomFlagBox.CreateWnd;
  Begin
   Inherited CreateWnd;
   ResetItemHeight;
   If Not(csRecreating In ControlState) Then
    Begin
     RebuildInternalItems;
     fItemsReady := True;
     If fItemIndex <> -1 Then
      Inherited ItemIndex := fItemIndex;
    End;
  End;

 Procedure TCustomFlagBox.CMFontChanged(Var Message : TMessage);
  Begin
   Inherited;
   ResetItemHeight;
  End;

 Procedure TCustomFlagBox.CMEnter(Var Message : TMessage);
  Begin
   Inherited;
   Invalidate;
  End;

 Function TCustomFlagBox.GetLabelText(Index : Integer) : String;
  Begin
   Result := Items[Index];
  End;

 Function TCustomFlagBox.GetStandardItemHeight;
  Begin
   If WindowHandle = 0 Then
    Result := Abs(Font.Height) + 2
   Else
    Result := Canvas.TextHeight('|');
   If Assigned(Flags) And (Result < Flags.Height) Then
    Result := Flags.Height;
   Inc(Result, 2 * VertSpacing);
  End;

 Procedure TCustomFlagBox.ResetItemHeight;
  Begin
   fStandardItemHeight := GetStandardItemHeight;
   If (WindowHandle = 0) Or (Style = csOwnerDrawVariable) Then
    Inherited ItemHeight := StandardItemHeight
   Else
    SendMessage(WindowHandle, CB_SETITEMHEIGHT, 0, StandardItemHeight);
  End;

{ TCustomFlagListBox }

 Constructor TCustomFlagListBox.Create(AOwner : TComponent);
  Begin
   Inherited Create(AOwner);
   Style      := lbOwnerDrawFixed;
   fFlagsLink := TChangeLink.Create;
   If csDesigning In ComponentState Then
    Flags              := FindFlags(AOwner);
   fFlagsLink.OnChange := FlagsChanged;
   fItemIndex          := -1;
  End;

 Destructor TCustomFlagListBox.Destroy;
  Begin
   Flags := Nil;
   fFlagsLink.Free;
   Inherited Destroy;
  End;

 Procedure TCustomFlagListBox.FlagsChanged(Sender : TObject);
  Begin
   ResetItemHeight;
   Invalidate;
  End;

 Procedure TCustomFlagListBox.SetSorted(Value : Boolean);
  Begin
   If Sorted <> Value Then
    Begin
     fSorted := Value;
     RebuildInternalItems;
    End;
  End;

 Procedure TCustomFlagListBox.SetFlagPosition(Value : TFlagPosition);
  Begin
   If FlagPosition <> Value Then
    Begin
     fFlagPosition := Value;
     Invalidate;
    End;
  End;

 Procedure TCustomFlagListBox.SetFlags(Value : TCustomFlagImageList);
  Begin
   If Flags <> Value Then
    Begin
     If Assigned(Flags) Then
      Begin
       Flags.RemoveFreeNotification(Self);
       Flags.UnRegisterChanges(fFlagsLink);
      End;
     fFlags := Value;
     If Assigned(Flags) Then
      Begin
       Flags.FreeNotification(Self);
       Flags.RegisterChanges(fFlagsLink);
      End;
     fFlagsLink.Change;
    End;
  End;

 Function TCustomFlagListBox.GetItemIndex : Integer;
  Begin
   If ItemsReady Then
    Result := Inherited GetItemIndex
   Else
    Result := fItemIndex;
  End;

 Procedure TCustomFlagListBox.SetItemIndex(Const Value : Integer);
  Begin
   If ItemsReady Then
    Inherited SetItemIndex(Value)
   Else
    fItemIndex := Value;
  End;

 Function TCustomFlagListBox.GetLabelText(Index : Integer) : String;
  Begin
   Result := Items[Index];
  End;

 Procedure TCustomFlagListBox.DrawItem(Index : Integer; Rect : TRect; State : TOwnerDrawState);
  Var
   TheLabel : String;
   x, y     : Integer;
  Begin
   Canvas.FillRect(Rect);
   SetBkMode(Canvas.Handle, Transparent);
   If Index >= 0 Then
    Begin
     If Assigned(Flags) Then
      Begin
       If UseRightToLeftAlignment Xor (FlagPosition = fpAfterLabel) Then
        Begin
         x := Rect.Right - Flags.Width - HorzSpacing;
         Dec(Rect.Right, Flags.Width + 2 * HorzSpacing);
        End
       Else
        Begin
         x := Rect.Left + HorzSpacing;
         Inc(Rect.Left, Flags.Width + 2 * HorzSpacing);
        End;
       y := (Rect.Top + Rect.Bottom - Flags.Height) Div 2;
       Flags.Draw(Canvas, x, y, GetImageIndex(Index));
      End;
     TheLabel := GetLabelText(Index);
     If DoDrawItemLabel(Index, Rect, State, TheLabel) Then
      Begin
       InflateRect(Rect, -HorzSpacing, 0);
       DrawText(Canvas.Handle, PChar(TheLabel), Length(TheLabel), Rect,
       DrawTextBiDiModeFlags(DT_LEFT Or DT_VCENTER Or DT_EXPANDTABS Or
       DT_SINGLELINE Or DT_NOPREFIX));
      End;
    End;
  End;

 Procedure TCustomFlagListBox.Notification(AComponent : TComponent; Operation : TOperation);
  Begin
   Inherited Notification(AComponent, Operation);
   If (Operation = opRemove) And (AComponent = Flags) Then
    Flags := Nil;
  End;

 Procedure TCustomFlagListBox.CreateWnd;
  Begin
   Inherited CreateWnd;
   ResetItemHeight;
   If Not(csRecreating In ControlState) Then
    Begin
     RebuildInternalItems;
     fItemsReady := True;
     If fItemIndex <> -1 Then
      Inherited ItemIndex := fItemIndex;
    End;
  End;

 Procedure TCustomFlagListBox.CMFontChanged(Var Message : TMessage);
  Begin
   Inherited;
   ResetItemHeight;
  End;

 Function TCustomFlagListBox.DoDrawItemLabel(Index : Integer; Var Rect : TRect; State : TOwnerDrawState; Var TheLabel : String) : Boolean;
  Begin
   Result := True;
   If Assigned(OnDrawItemLabel) Then
    OnDrawItemLabel(Self, Index, Rect, State, TheLabel, Result);
  End;

 Procedure TCustomFlagListBox.DoItemsChange;
  Begin
   If Assigned(OnItemsChange) Then
    OnItemsChange(Self);
  End;

 Function TCustomFlagListBox.GetStandardItemHeight;
  Begin
   If WindowHandle = 0 Then
    Result := Abs(Font.Height) + 2
   Else
    Result := Canvas.TextHeight('|');
   If Assigned(Flags) And (Result < Flags.Height) Then
    Result := Flags.Height;
   Inc(Result, 2 * VertSpacing);
  End;

 Procedure TCustomFlagListBox.ResetItemHeight;
  Begin
   fStandardItemHeight := GetStandardItemHeight;
   If (WindowHandle = 0) Or (Style = lbOwnerDrawVariable) Then
    Inherited ItemHeight := StandardItemHeight
   Else
    SendMessage(WindowHandle, LB_SETITEMHEIGHT, 0, StandardItemHeight);
  End;

{ TCheckListBoxDataWrapper }

 Type
  TCheckListBoxDataWrapper = Class
   Private
    fState    : TCheckBoxState;
    fDisabled : Boolean;
    Procedure SetChecked(Value : Boolean); Inline;
    Function GetChecked : Boolean; Inline;
   Protected
    Data : TListBoxItemData;
   Public
    Class Function GetDefaultState : TCheckBoxState; Static;
    Property Checked  : Boolean Read GetChecked Write SetChecked;
    Property State    : TCheckBoxState Read fState Write fState;
    Property Disabled : Boolean Read fDisabled Write fDisabled;
  End;

  Class Function TCheckListBoxDataWrapper.GetDefaultState : TCheckBoxState;

Begin
 Result := cbUnchecked;

End;

 Procedure TCheckListBoxDataWrapper.SetChecked(Value : Boolean);
  Begin
   fState := TCheckBoxState(Value);
  End;

 Function TCheckListBoxDataWrapper.GetChecked : Boolean;
  Begin
   Result := (fState = cbChecked);
  End;

{ TCheckListRecall }

 Constructor TCheckListRecall.Create(AReference : TPersistent);
  Begin
   CheckList := AReference;
   StateInfo := TKeyLookup<String, TStateRec>.Create;
   If Assigned(CheckList) Then
    Assign(CheckList);
  End;

 Destructor TCheckListRecall.Destroy;
  Begin
   If Assigned(CheckList) Then
    AssignTo(CheckList);
   StateInfo.Free;
   Inherited Destroy;
  End;

 Procedure TCheckListRecall.Store;
  Begin
   If Assigned(CheckList) Then
    Assign(CheckList);
  End;

 Procedure TCheckListRecall.Forget;
  Begin
   CheckList := Nil;
   StateInfo.Clear;
  End;

 Procedure TCheckListRecall.Assign(Source : TPersistent);
  Var
   i : Integer;
  Begin
   If Source Is TCheckListRecall Then
    StateInfo.CopyFrom(TCheckListRecall(Source).StateInfo)
   Else If Source Is TCustomCultureCheckListBox Then
    Begin
     StateInfo.Clear;
     With TCustomCultureCheckListBox(Source), StateInfo Do
      For i := 0 To Items.Count - 1 Do
       Add(Items[i].Locale, StateRec(State[i], Not ItemEnabled[i]));
    End
   Else If Source Is TCustomTerritoryCheckListBox Then
    Begin
     StateInfo.Clear;
     With TCustomTerritoryCheckListBox(Source), StateInfo Do
      For i := 0 To Items.Count - 1 Do
       Add(Items[i].Code2, StateRec(State[i], Not ItemEnabled[i]));
    End
   Else If Source Is TCustomCurrencyCheckListBox Then
    Begin
     StateInfo.Clear;
     With TCustomCurrencyCheckListBox(Source), StateInfo Do
      For i := 0 To Items.Count - 1 Do
       Add(Items[i].IntlSymbol, StateRec(State[i], Not ItemEnabled[i]));
    End
   Else If Source Is TCheckListBox Then
    Begin
     StateInfo.Clear;
     With TCheckListBox(Source), StateInfo Do
      For i := 0 To Items.Count - 1 Do
       Add(Items[i], StateRec(State[i], Not ItemEnabled[i]));
    End
   Else
    Inherited Assign(Source);
  End;

 Procedure TCheckListRecall.AssignTo(Dest : TPersistent);
  Var
   i   : Integer;
   Rec : TStateRec;
  Begin
   If Dest Is TCustomCultureCheckListBox Then
    With TCustomCultureCheckListBox(Dest) Do
     For i := 0 To Items.Count - 1 Do
      Begin
       If StateInfo.Retrieve(Items[i].Locale, Rec) Then
        Begin
         State[i]       := Rec.State;
         ItemEnabled[i] := Not Rec.Disabled;
        End
       Else
        Begin
         State[i]       := TCheckListBoxDataWrapper.GetDefaultState;
         ItemEnabled[i] := True;
        End;
      End
   Else If Dest Is TCustomTerritoryCheckListBox Then
    With TCustomTerritoryCheckListBox(Dest) Do
     For i := 0 To Items.Count - 1 Do
      Begin
       If StateInfo.Retrieve(Items[i].Code2, Rec) Then
        Begin
         State[i]       := Rec.State;
         ItemEnabled[i] := Not Rec.Disabled;
        End
       Else
        Begin
         State[i]       := TCheckListBoxDataWrapper.GetDefaultState;
         ItemEnabled[i] := True;
        End;
      End
   Else If Dest Is TCustomCurrencyCheckListBox Then
    With TCustomCurrencyCheckListBox(Dest) Do
     For i := 0 To Items.Count - 1 Do
      Begin
       If StateInfo.Retrieve(Items[i].IntlSymbol, Rec) Then
        Begin
         State[i]       := Rec.State;
         ItemEnabled[i] := Not Rec.Disabled;
        End
       Else
        Begin
         State[i]       := TCheckListBoxDataWrapper.GetDefaultState;
         ItemEnabled[i] := True;
        End;
      End
   Else If Dest Is TCheckListBox Then
    With TCheckListBox(Dest) Do
     For i := 0 To Items.Count - 1 Do
      Begin
       If StateInfo.Retrieve(Items[i], Rec) Then
        Begin
         State[i]       := Rec.State;
         ItemEnabled[i] := Not Rec.Disabled;
        End
       Else
        Begin
         State[i]       := TCheckListBoxDataWrapper.GetDefaultState;
         ItemEnabled[i] := True;
        End;
      End
   Else
    Inherited AssignTo(Dest);
  End;

 Function TCheckListRecall.StateRec(AState : TCheckBoxState; ADisabled : Boolean) : TStateRec;
  Begin
   Result.State    := AState;
   Result.Disabled := ADisabled;
  End;

{ TCustomFlagCheckListBox }

 Constructor TCustomFlagCheckListBox.Create(AOwner : TComponent);
  Begin
   Inherited Create(AOwner);
   fWrapperList := TObjectList.Create;
   fCheckWidth  := CheckBoxSize.cx + HorzSpacing;
   fFlat        := True;
  End;

 Destructor TCustomFlagCheckListBox.Destroy;
  Begin
   fWrapperList.Free;
   Inherited Destroy;
  End;

 Procedure TCustomFlagCheckListBox.SetFlat(Value : Boolean);
  Begin
   If Flat <> Value Then
    Begin
     fFlat := Value;
     Invalidate;
    End;
  End;

 Function TCustomFlagCheckListBox.GetChecked(Index : Integer) : Boolean;
  Begin
   If ItemsReady And HaveWrapper(Index) Then
    Result := TCheckListBoxDataWrapper(GetWrapper(Index)).Checked
   Else
    Result := False;
  End;

 Procedure TCustomFlagCheckListBox.SetChecked(Index : Integer; Value : Boolean);
  Begin
   If ItemsReady And (Checked[Index] <> Value) Then
    Begin
     TCheckListBoxDataWrapper(GetWrapper(Index)).Checked := Value;
     InvalidateCheck(Index);
    End;
  End;

 Function TCustomFlagCheckListBox.GetState(Index : Integer) : TCheckBoxState;
  Begin
   If ItemsReady And HaveWrapper(Index) Then
    Result := TCheckListBoxDataWrapper(GetWrapper(Index)).State
   Else
    Result := TCheckListBoxDataWrapper.GetDefaultState;
  End;

 Procedure TCustomFlagCheckListBox.SetState(Index : Integer; Value : TCheckBoxState);
  Begin
   If ItemsReady And (State[Index] <> Value) Then
    Begin
     TCheckListBoxDataWrapper(GetWrapper(Index)).State := Value;
     InvalidateCheck(Index);
    End;
  End;

 Function TCustomFlagCheckListBox.GetItemEnabled(Index : Integer) : Boolean;
  Begin
   If ItemsReady And HaveWrapper(Index) Then
    Result := Not TCheckListBoxDataWrapper(GetWrapper(Index)).Disabled
   Else
    Result := True;
  End;

 Procedure TCustomFlagCheckListBox.SetItemEnabled(Index : Integer; Value : Boolean);
  Begin
   If ItemsReady And (ItemEnabled[Index] <> Value) Then
    Begin
     TCheckListBoxDataWrapper(GetWrapper(Index)).Disabled := Not Value;
     InvalidateCheck(Index);
    End;
  End;

 Procedure TCustomFlagCheckListBox.ClickCheck;
  Begin
   If Assigned(fOnClickCheck) Then
    fOnClickCheck(Self);
  End;

 Procedure TCustomFlagCheckListBox.KeyPress(Var Key : Char);
  Begin
   If Key = ' ' Then
    ToggleClickCheck(ItemIndex);
   Inherited KeyPress(Key);
  End;

 Procedure TCustomFlagCheckListBox.MouseDown(Button : TMouseButton; Shift : TShiftState; x, y : Integer);
  Var
   Index : Integer;
  Begin
   Inherited;
   If Button = mbLeft Then
    Begin
     Index := ItemAtPos(Point(x, y), True);
     If (Index >= 0) And GetItemEnabled(Index) Then
      If UseRightToLeftAlignment Then
       Begin
        Dec(x, ItemRect(Index).Right - CheckWidth);
        If (x > 0) And (x < CheckWidth) Then
         ToggleClickCheck(Index)
       End
      Else
       Begin
        If x - ItemRect(Index).Left < CheckWidth Then
         ToggleClickCheck(Index)
       End;
    End;
  End;

 Function TCustomFlagCheckListBox.CreateWrapper(Index : Integer) : TObject;
  Begin
   Result := TCheckListBoxDataWrapper.Create;
   fWrapperList.Add(Result);
   Inherited SetItemData(Index, TListBoxItemData(Result));
  End;

 Function TCustomFlagCheckListBox.ExtractWrapper(Index : Integer) : TObject;
  Begin
   Result := TCheckListBoxDataWrapper(Inherited GetItemData(Index));
   If LB_ERR = Integer(Result) Then
    Raise EListError.CreateResFmt(@SListIndexError, [Index]);
   If (Result <> Nil) And Not(Result Is TCheckListBoxDataWrapper) Then
    Result := Nil;
  End;

 Function TCustomFlagCheckListBox.HaveWrapper(Index : Integer) : Boolean;
  Begin
   Result := ExtractWrapper(Index) <> Nil;
  End;

 Function TCustomFlagCheckListBox.GetWrapper(Index : Integer) : TObject;
  Begin
   Result := ExtractWrapper(Index);
   If Result = Nil Then
    Result := CreateWrapper(Index);
  End;

 Function TCustomFlagCheckListBox.InternalGetItemData(Index : Integer) : TListBoxItemData;
  Begin
   Result := Inherited GetItemData(Index);
  End;

 Procedure TCustomFlagCheckListBox.InternalSetItemData(Index : Integer; AData : TListBoxItemData);
  Begin
   Inherited SetItemData(Index, AData);
  End;

 Function TCustomFlagCheckListBox.GetItemData(Index : Integer) : TListBoxItemData;
  Begin
   Result := 0;
   If HaveWrapper(Index) Then
    Result := TCheckListBoxDataWrapper(GetWrapper(Index)).Data;
  End;

 Procedure TCustomFlagCheckListBox.SetItemData(Index : Integer; AData : TListBoxItemData);
  Var
   Wrapper : TCheckListBoxDataWrapper;
  Begin
   If HaveWrapper(Index) Or (AData <> 0) Then
    Begin
     Wrapper      := TCheckListBoxDataWrapper(GetWrapper(Index));
     Wrapper.Data := AData;
    End;
  End;

 Procedure TCustomFlagCheckListBox.ResetContent;
  Begin
   fWrapperList.Clear;
   Inherited ResetContent;
  End;

 Procedure TCustomFlagCheckListBox.LoadRecreateItems(RecreateItems : TStrings);
  Var
   i, Index : Integer;
  Begin
   With RecreateItems Do
    Begin
     BeginUpdate;
     Try
      Items.NameValueSeparator := NameValueSeparator;
      Items.QuoteChar          := QuoteChar;
      Items.Delimiter          := Delimiter;
      Items.LineBreak          := LineBreak;
      For i                    := 0 To Count - 1 Do
       Begin
        Index := Items.Add(RecreateItems[i]);
        If Objects[i] <> Nil Then
         InternalSetItemData(Index, TListBoxItemData(Objects[i]));
       End;
     Finally
      EndUpdate;
     End;
    End;
  End;

 Procedure TCustomFlagCheckListBox.SaveRecreateItems(RecreateItems : TStrings);
  Var
   i       : Integer;
   Wrapper : TCheckListBoxDataWrapper;
  Begin
   fWrapperList.OwnsObjects := False;
   fWrapperList.Clear;
   fWrapperList.OwnsObjects := True;
   With RecreateItems Do
    Begin
     BeginUpdate;
     Try
      NameValueSeparator := Items.NameValueSeparator;
      QuoteChar          := Items.QuoteChar;
      Delimiter          := Items.Delimiter;
      LineBreak          := Items.LineBreak;
      For i              := 0 To Items.Count - 1 Do
       Begin
        Wrapper := TCheckListBoxDataWrapper(ExtractWrapper(i));
        AddObject(Items[i], Wrapper);
        If Wrapper <> Nil Then
         fWrapperList.Add(Wrapper);
       End;
     Finally
      EndUpdate;
     End;
    End;
  End;

 Procedure TCustomFlagCheckListBox.DeleteString(Index : Integer);
  Var
   Wrapper : TCheckListBoxDataWrapper;
  Begin
   If HaveWrapper(Index) Then
    Begin
     Wrapper := TCheckListBoxDataWrapper(GetWrapper(Index));
     fWrapperList.Remove(Wrapper);
    End;
   Inherited DeleteString(Index);
  End;

 Procedure TCustomFlagCheckListBox.ToggleClickCheck;
  Begin
   If (Index >= 0) And (Index < Count) And ItemEnabled[Index] Then
    Begin
     Case State[Index] Of
      cbUnchecked :
       If AllowGrayed Then
        State[Index] := cbGrayed
       Else
        State[Index] := cbChecked;
      cbChecked :
       State[Index] := cbUnchecked;
      cbGrayed :
       State[Index] := cbChecked;
     End;
     ClickCheck;
    End;
  End;

 Procedure TCustomFlagCheckListBox.InvalidateCheck(Index : Integer);
  Var
   Rect : TRect;
  Begin
   If WindowHandle <> 0 Then
    Begin
     Rect := ItemRect(Index);
     If UseRightToLeftAlignment Then
      Rect.Left := Rect.Right - CheckWidth
     Else
      Rect.Right := Rect.Left + CheckWidth;
     InvalidateRect(WindowHandle, Rect, Not(csOpaque In ControlStyle));
     UpdateWindow(WindowHandle);
    End;
  End;

 Procedure TCustomFlagCheckListBox.RestateAll(AState : TCheckBoxState; AllowGrayed : Boolean; AllowDisabled : Boolean);
  Var
   i : Integer;
  Begin
   For i := 0 To Items.Count - 1 Do
    If ItemEnabled[i] Or (Not ItemEnabled[i] And AllowDisabled) Then
     If(AllowGrayed Or (GetState(i) <> cbGrayed))Then
      SetState(i, AState);
  End;

 Function TCustomFlagCheckListBox.GetStandardItemHeight : Integer;
  Begin
   Result := Inherited GetStandardItemHeight;
   If Result < CheckBoxSize.cy + 2 * VertSpacing Then
    Result := CheckBoxSize.cy + 2 * VertSpacing;
  End;

 Procedure TCustomFlagCheckListBox.DrawItem(Index : Integer; Rect : TRect; State : TOwnerDrawState);
  Var
   r      : TRect;
   Enable : Boolean;
  Begin
   If (Index >= 0) And (Index < Count) Then
    Begin
     r := Rect;
     If UseRightToLeftAlignment Then
      Begin
       r.Left := r.Right - CheckWidth;
       Dec(Rect.Right, CheckWidth);
      End
     Else
      Begin
       r.Right := r.Left + CheckWidth;
       Inc(Rect.Left, CheckWidth);
      End;
     Canvas.FillRect(r);
     Enable := Self.Enabled And ItemEnabled[Index];
     DrawCheck(r, GetState(Index), Enable);
     If IntersectRect(r, Rect, Canvas.ClipRect) Then
      Begin
       If Not Enable Then
        Canvas.Font.Color := clGrayText;
       Inherited DrawItem(Index, Rect, State);
      End;
    End;
  End;

 Procedure TCustomFlagCheckListBox.DrawCheck(Const Rect : TRect; AState : TCheckBoxState; AEnabled : Boolean);
  Var
   DrawState : TPartDrawState;
  Begin
   If AEnabled Then
    DrawState := pdsNormal
   Else
    DrawState := pdsDisabled;
   DrawCheckBox(Canvas.Handle, Rect, AState, DrawState, Flat, ThemeControl(Self));
  End;

{ TCustomCultureLabel }

 Constructor TCustomCultureLabel.Create(AOwner : TComponent);
  Begin
   Inherited Create(AOwner);
   fDisplayName := cnEnglishDisplayName;
  End;

 Destructor TCustomCultureLabel.Destroy;
  Begin
   Localizer := Nil;
   Inherited Destroy;
  End;

 Procedure TCustomCultureLabel.ReadCulture(Reader : TReader);
  Begin
   Culture := CultureOf(Reader.ReadString);
  End;

 Procedure TCustomCultureLabel.WriteCulture(Writer : TWriter);
  Begin
   Writer.WriteString(Culture.Locale);
  End;

 Procedure TCustomCultureLabel.DefineProperties(Filer : TFiler);
  Begin
   Inherited DefineProperties(Filer);
   Filer.DefineProperty('CultureInfo', ReadCulture, WriteCulture,
   Not Assigned(Localizer) And Assigned(Culture));
  End;

 Procedure TCustomCultureLabel.Notification(AComponent : TComponent; Operation : TOperation);
  Begin
   Inherited Notification(AComponent, Operation);
   If (Operation = opRemove) And (AComponent = Localizer) Then
    Localizer := Nil;
  End;

 Function TCustomCultureLabel.GetImageIndex : TImageIndex;
  Begin
   Result := Flags.ImageIndexOf(Culture);
  End;

 Function TCustomCultureLabel.GetLabelText : String;
  Begin
   If (DisplayName = cnNone) Or Not Assigned(Culture) Then
    Result := Caption
   Else
    Result := Culture.DisplayNames[DisplayName];
  End;

 Procedure TCustomCultureLabel.SetDisplayName(Value : TCultureDisplayName);
  Begin
   If DisplayName <> Value Then
    Begin
     fDisplayName := Value;
     AdjustBounds;
     Invalidate;
    End;
  End;

 Procedure TCustomCultureLabel.SetCulture(Value : TCultureInfo);
  Begin
   If Culture <> Value Then
    Begin
     fCulture := Value;
     AdjustBounds;
     Invalidate;
    End;
  End;

 Procedure TCustomCultureLabel.SetLocalizer(Value : TLocalizer);
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

 Procedure TCustomCultureLabel.LocalizerNotify(Sender : TLocalizer; Reason : TLocalizerNotification);
  Begin
   If Reason = lnCultureChanged Then
    Begin
     If Assigned(Localizer) Then
      Culture := Localizer.Culture
     Else
      Culture := Nil;
    End;
  End;

 Function TCustomCultureLabel.IsManagedByLocalizer : Boolean;
  Begin
   Result := Assigned(Localizer);
  End;

{ TCustomCultureBox }

 Constructor TCustomCultureBox.Create(AOwner : TComponent);
  Begin
   Inherited Create(AOwner);
   fCultures          := TCultureList.Create;
   fCultures.OnChange := CulturesChanged;
   fDisplayName       := cnEnglishDisplayName;
  End;

 Destructor TCustomCultureBox.Destroy;
  Begin
   fCultures.OnChange := Nil;
   Localizer          := Nil;
   fCultures.Free;
   Inherited Destroy;
  End;

 Procedure TCustomCultureBox.CulturesChanged(Sender : TObject);
  Begin
   If ItemsReady Then
    Begin
     fCultures.AssignLabelsTo(Inherited Items, DisplayName);
     DoItemsChange;
    End;
  End;

 Procedure TCustomCultureBox.LocalizerNotify(Sender : TLocalizer; Reason : TLocalizerNotification);
  Begin
   Case Reason Of
    lnCatalogChanged :
     If Assigned(Localizer) Then
      Begin
       fCultures.Assign(Localizer.Cultures);
       ItemSelected := Localizer.Culture;
      End
     Else
      fCultures.Clear;
    lnCultureChanged :
     If Assigned(Localizer) Then
      ItemSelected := Localizer.Culture
     Else
      ItemSelected := Nil;
   End;
  End;

 Procedure TCustomCultureBox.SetLocalizer(Value : TLocalizer);
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
      LocalizerNotify(Localizer, lnCatalogChanged);
    End;
  End;

 Procedure TCustomCultureBox.SetCultures(Value : TCultureList);
  Begin
   fCultures.Assign(Value);
  End;

 Procedure TCustomCultureBox.SetItemSelected(Value : TCultureInfo);
  Begin
   ItemIndex := fCultures.IndexOf(Value);
  End;

 Function TCustomCultureBox.GetItemSelected : TCultureInfo;
  Begin
   If Cardinal(ItemIndex) < Cardinal(fCultures.Count) Then
    Result := fCultures[ItemIndex]
   Else
    Result := Nil;
  End;

 Procedure TCustomCultureBox.SetDisplayName(Value : TCultureDisplayName);
  Begin
   If DisplayName <> Value Then
    Begin
     fDisplayName := Value;
     RebuildInternalItems;
    End;
  End;

 Function TCustomCultureBox.GetImageIndex(Index : Integer) : Integer;
  Begin
   If (Index >= 0) And (Index < fCultures.Count) And Assigned(Flags) Then
    Result := Flags.ImageIndexOf(fCultures[Index])
   Else
    Result := -1;
  End;

 Function TCustomCultureBox.IsManagedByLocalizer : Boolean;
  Begin
   Result := Assigned(Localizer);
  End;

 Procedure TCustomCultureBox.ReadItemSelected(Reader : TReader);
  Begin
   ItemSelected := CultureOf(Reader.ReadString);
  End;

 Procedure TCustomCultureBox.WriteItemSelected(Writer : TWriter);
  Begin
   Writer.WriteString(ItemSelected.Locale);
  End;

 Procedure TCustomCultureBox.DefineProperties(Filer : TFiler);
  Begin
   Inherited DefineProperties(Filer);
   Filer.DefineProperty('Selected', ReadItemSelected, WriteItemSelected,
   Not Assigned(Localizer) And Assigned(ItemSelected));
  End;

 Procedure TCustomCultureBox.Notification(AComponent : TComponent; Operation : TOperation);
  Begin
   Inherited Notification(AComponent, Operation);
   If (Operation = opRemove) And (AComponent = Localizer) Then
    Localizer := Nil;
  End;

 Procedure TCustomCultureBox.Select;
  Begin
   Inherited Select;
   If Assigned(Localizer) Then
    Localizer.Culture := ItemSelected;
  End;

 Function TCustomCultureBox.CollectAll : Boolean;
  Begin
   Result := False;
   If Not Assigned(Localizer) Then
    Begin
     fCultures.Assign(World.Cultures);
     Result := True;
    End
  End;

 Procedure TCustomCultureBox.RebuildInternalItems;
  Var
   Sel : TCultureInfo;
  Begin
   fCultures.OnChange := Nil;
   Try
    Sel := ItemSelected;
    If Sorted Then
     fCultures.Sort(DisplayName);
    If WindowHandle <> 0 Then
     Begin
      fCultures.AssignLabelsTo(Inherited Items, DisplayName);
      DoItemsChange;
     End;
    ItemSelected := Sel;
   Finally
    fCultures.OnChange := CulturesChanged;
   End;
  End;

{ TCustomCultureListBox }

 Constructor TCustomCultureListBox.Create(AOwner : TComponent);
  Begin
   Inherited Create(AOwner);
   fCultures          := TCultureList.Create;
   fCultures.OnChange := CulturesChanged;
   fDisplayName       := cnEnglishDisplayName;
  End;

 Destructor TCustomCultureListBox.Destroy;
  Begin
   fCultures.OnChange := Nil;
   Localizer          := Nil;
   fCultures.Free;
   Inherited Destroy;
  End;

 Procedure TCustomCultureListBox.CulturesChanged(Sender : TObject);
  Begin
   If ItemsReady Then
    Begin
     fCultures.AssignLabelsTo(Inherited Items, DisplayName);
     DoItemsChange;
    End;
  End;

 Procedure TCustomCultureListBox.LocalizerNotify(Sender : TLocalizer; Reason : TLocalizerNotification);
  Begin
   Case Reason Of
    lnCatalogChanged :
     If Assigned(Localizer) Then
      Begin
       fCultures.Assign(Localizer.Cultures);
       ItemSelected := Localizer.Culture;
      End
     Else
      fCultures.Clear;
    lnCultureChanged :
     If Assigned(Localizer) Then
      ItemSelected := Localizer.Culture
     Else
      ItemSelected := Nil;
   End;
  End;

 Procedure TCustomCultureListBox.SetLocalizer(Value : TLocalizer);
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
       MultiSelect := False;
       Localizer.FreeNotification(Self);
       Localizer.RegisterListener(Self);
      End;
     If Not(csDestroying In ComponentState) Then
      LocalizerNotify(Localizer, lnCatalogChanged);
    End;
  End;

 Procedure TCustomCultureListBox.SetMultiSelect(Value : Boolean);
  Begin
   Inherited SetMultiSelect(Value And Not Assigned(Localizer));
  End;

 Procedure TCustomCultureListBox.SetCultures(Value : TCultureList);
  Begin
   fCultures.Assign(Value);
  End;

 Procedure TCustomCultureListBox.SetItemSelected(Value : TCultureInfo);
  Begin
   ItemIndex := fCultures.IndexOf(Value);
  End;

 Function TCustomCultureListBox.GetItemSelected : TCultureInfo;
  Begin
   If Cardinal(ItemIndex) < Cardinal(fCultures.Count) Then
    Result := fCultures[ItemIndex]
   Else
    Result := Nil;
  End;

 Procedure TCustomCultureListBox.SetDisplayName(Value : TCultureDisplayName);
  Begin
   If DisplayName <> Value Then
    Begin
     fDisplayName := Value;
     RebuildInternalItems;
    End;
  End;

 Function TCustomCultureListBox.GetImageIndex(Index : Integer) : Integer;
  Begin
   If (Index >= 0) And (Index < fCultures.Count) And Assigned(Flags) Then
    Result := Flags.ImageIndexOf(fCultures[Index])
   Else
    Result := -1;
  End;

 Function TCustomCultureListBox.IsManagedByLocalizer : Boolean;
  Begin
   Result := Assigned(Localizer);
  End;

 Procedure TCustomCultureListBox.ReadItemSelected(Reader : TReader);
  Begin
   ItemSelected := CultureOf(Reader.ReadString);
  End;

 Procedure TCustomCultureListBox.WriteItemSelected(Writer : TWriter);
  Begin
   Writer.WriteString(ItemSelected.Locale);
  End;

 Procedure TCustomCultureListBox.DefineProperties(Filer : TFiler);
  Begin
   Inherited DefineProperties(Filer);
   Filer.DefineProperty('Selected', ReadItemSelected, WriteItemSelected,
   Not Assigned(Localizer) And Assigned(ItemSelected));
  End;

 Procedure TCustomCultureListBox.Notification(AComponent : TComponent; Operation : TOperation);
  Begin
   Inherited Notification(AComponent, Operation);
   If (Operation = opRemove) And (AComponent = Localizer) Then
    Localizer := Nil;
  End;

 Procedure TCustomCultureListBox.Click;
  Begin
   Inherited Click;
   If Assigned(Localizer) Then
    Localizer.Culture := ItemSelected;
  End;

 Function TCustomCultureListBox.CollectAll : Boolean;
  Begin
   Result := False;
   If Not Assigned(Localizer) Then
    Begin
     fCultures.Assign(World.Cultures);
     Result := True;
    End
  End;

 Procedure TCustomCultureListBox.RebuildInternalItems;
  Var
   Sel : TCultureInfo;
  Begin
   fCultures.OnChange := Nil;
   Try
    Sel := ItemSelected;
    If Sorted Then
     fCultures.Sort(DisplayName);
    If WindowHandle <> 0 Then
     Begin
      fCultures.AssignLabelsTo(Inherited Items, DisplayName);
      DoItemsChange;
     End;
    ItemSelected := Sel;
   Finally
    fCultures.OnChange := CulturesChanged;
   End;
  End;

 Procedure TCustomCultureListBox.SetSelection(Source : TReadonlyCultureList);
  Var
   i : Integer;
  Begin
   If MultiSelect Then
    For i        := 0 To fCultures.Count - 1 Do
     Selected[i] := Source.Exists(fCultures[i]);
  End;

 Procedure TCustomCultureListBox.GetSelection(Dest : TCultureList);
  Var
   i : Integer;
  Begin
   Dest.BeginUpdate;
   Try
    Dest.Clear;
    For i := 0 To fCultures.Count - 1 Do
     If Selected[i] Then
      Dest.Add(fCultures[i]);
   Finally
    Dest.EndUpdate;
   End;
  End;

{ TCustomCultureCheckListBox }

 Constructor TCustomCultureCheckListBox.Create(AOwner : TComponent);
  Begin
   Inherited Create(AOwner);
   fCultures          := TCultureList.Create;
   fCultures.OnChange := CulturesChanged;
   fDisplayName       := cnEnglishDisplayName;
  End;

 Destructor TCustomCultureCheckListBox.Destroy;
  Begin
   fCultures.OnChange := Nil;
   Localizer          := Nil;
   fCultures.Free;
   Inherited Destroy;
  End;

 Procedure TCustomCultureCheckListBox.CulturesChanged(Sender : TObject);
  Begin
   If ItemsReady Then
    Begin
     fCultures.AssignLabelsTo(Inherited Items, DisplayName);
     DoItemsChange;
    End;
  End;

 Procedure TCustomCultureCheckListBox.LocalizerNotify(Sender : TLocalizer; Reason : TLocalizerNotification);
  Begin
   If Reason = lnCatalogChanged Then
    Begin
     If Assigned(Localizer) Then
      fCultures.Assign(Localizer.Cultures)
     Else
      fCultures.Clear;
    End;
  End;

 Procedure TCustomCultureCheckListBox.SetLocalizer(Value : TLocalizer);
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
      LocalizerNotify(Localizer, lnCatalogChanged);
    End;
  End;

 Procedure TCustomCultureCheckListBox.SetCultures(Value : TCultureList);
  Begin
   fCultures.Assign(Value);
  End;

 Procedure TCustomCultureCheckListBox.SetItemSelected(Value : TCultureInfo);
  Begin
   ItemIndex := fCultures.IndexOf(Value);
  End;

 Function TCustomCultureCheckListBox.GetItemSelected : TCultureInfo;
  Begin
   If Cardinal(ItemIndex) < Cardinal(fCultures.Count) Then
    Result := fCultures[ItemIndex]
   Else
    Result := Nil;
  End;

 Procedure TCustomCultureCheckListBox.SetDisplayName(Value : TCultureDisplayName);
  Begin
   If DisplayName <> Value Then
    Begin
     fDisplayName := Value;
     RebuildInternalItems;
    End;
  End;

 Function TCustomCultureCheckListBox.GetImageIndex(Index : Integer) : Integer;
  Begin
   If (Index >= 0) And (Index < fCultures.Count) And Assigned(Flags) Then
    Result := Flags.ImageIndexOf(fCultures[Index])
   Else
    Result := -1;
  End;

 Function TCustomCultureCheckListBox.IsManagedByLocalizer : Boolean;
  Begin
   Result := Assigned(Localizer);
  End;

 Procedure TCustomCultureCheckListBox.Notification(AComponent : TComponent; Operation : TOperation);
  Begin
   Inherited Notification(AComponent, Operation);
   If (Operation = opRemove) And (AComponent = Localizer) Then
    Localizer := Nil;
  End;

 Function TCustomCultureCheckListBox.CollectAll : Boolean;
  Begin
   Result := False;
   If Not Assigned(Localizer) Then
    Begin
     fCultures.Assign(World.Cultures);
     Result := True;
    End
  End;

 Procedure TCustomCultureCheckListBox.RebuildInternalItems;
  Var
   Sel          : TCultureInfo;
   RestorePoint : TCheckListRecall;
  Begin
   fCultures.OnChange := Nil;
   Try
    RestorePoint := TCheckListRecall.Create(Self);
    Try
     Sel := ItemSelected;
     If Self.Sorted Then
      fCultures.Sort(DisplayName);
     If WindowHandle <> 0 Then
      Begin
       fCultures.AssignLabelsTo(Inherited Items, DisplayName);
       DoItemsChange;
      End;
     ItemSelected := Sel;
     Assign(RestorePoint);
    Finally
     RestorePoint.Free;
    End;
   Finally
    fCultures.OnChange := CulturesChanged;
   End;
  End;

 Procedure TCustomCultureCheckListBox.GetSelection(Dest : TCultureList; AllowDisabled : Boolean);
  Var
   i : Integer;
  Begin
   Dest.BeginUpdate;
   Try
    Dest.Clear;
    For i := 0 To Count - 1 Do
     If Checked[i] And (AllowDisabled Or ItemEnabled[i]) Then
      Dest.Add(Items[i]);
   Finally
    Dest.EndUpdate;
   End;
  End;

 Procedure TCustomCultureCheckListBox.SetSelection(Source : TReadonlyCultureList; AllowDisabled : Boolean);
  Var
   i : Integer;
  Begin
   For i := 0 To Count - 1 Do
    If AllowDisabled Or ItemEnabled[i] Then
     Checked[i] := Source.Exists(Items[i]);
  End;

{ TCustomTerritoryLabel }

 Constructor TCustomTerritoryLabel.Create(AOwner : TComponent);
  Begin
   Inherited Create(AOwner);
   fDisplayName := tnFriendlyName;
  End;

 Procedure TCustomTerritoryLabel.ReadTerritory(Reader : TReader);
  Begin
   Territory := TerritoryOf(Reader.ReadString);
  End;

 Procedure TCustomTerritoryLabel.WriteTerritory(Writer : TWriter);
  Begin
   Writer.WriteString(Territory.Code2);
  End;

 Procedure TCustomTerritoryLabel.DefineProperties(Filer : TFiler);
  Begin
   Inherited DefineProperties(Filer);
   Filer.DefineProperty('TerritoryInfo', ReadTerritory, WriteTerritory, Assigned(Territory));
  End;

 Function TCustomTerritoryLabel.GetImageIndex : TImageIndex;
  Begin
   Result := Flags.ImageIndexOf(Territory);
  End;

 Function TCustomTerritoryLabel.GetLabelText : String;
  Begin
   If (DisplayName = tnNone) Or Not Assigned(Territory) Then
    Result := Caption
   Else
    Result := Territory.DisplayNames[DisplayName];
  End;

 Procedure TCustomTerritoryLabel.SetDisplayName(Value : TTerritoryDisplayName);
  Begin
   If DisplayName <> Value Then
    Begin
     fDisplayName := Value;
     AdjustBounds;
     Invalidate;
    End;
  End;

 Procedure TCustomTerritoryLabel.SetTerritory(Value : TTerritoryInfo);
  Begin
   If Territory <> Value Then
    Begin
     fTerritory := Value;
     AdjustBounds;
     Invalidate;
    End;
  End;

{ TCustomTerritoryBox }

 Constructor TCustomTerritoryBox.Create(AOwner : TComponent);
  Begin
   Inherited Create(AOwner);
   fTerritories          := TTerritoryList.Create;
   fTerritories.OnChange := TerritoriesChanged;
   fDisplayName          := tnFriendlyName;
  End;

 Destructor TCustomTerritoryBox.Destroy;
  Begin
   fTerritories.OnChange := Nil;
   fTerritories.Free;
   Inherited Destroy;
  End;

 Procedure TCustomTerritoryBox.TerritoriesChanged(Sender : TObject);
  Begin
   If ItemsReady Then
    Begin
     fTerritories.AssignLabelsTo(Inherited Items, DisplayName);
     DoItemsChange;
    End;
  End;

 Procedure TCustomTerritoryBox.ReadItemSelected(Reader : TReader);
  Begin
   ItemSelected := TerritoryOf(Reader.ReadString);
  End;

 Procedure TCustomTerritoryBox.WriteItemSelected(Writer : TWriter);
  Begin
   Writer.WriteString(ItemSelected.Code2);
  End;

 Procedure TCustomTerritoryBox.DefineProperties(Filer : TFiler);
  Begin
   Inherited DefineProperties(Filer);
   Filer.DefineProperty('Selected', ReadItemSelected, WriteItemSelected, Assigned(ItemSelected));
  End;

 Procedure TCustomTerritoryBox.SetTerritories(Value : TTerritoryList);
  Begin
   fTerritories.Assign(Value);
  End;

 Procedure TCustomTerritoryBox.SetItemSelected(Value : TTerritoryInfo);
  Begin
   ItemIndex := fTerritories.IndexOf(Value);
  End;

 Function TCustomTerritoryBox.GetItemSelected : TTerritoryInfo;
  Begin
   If Cardinal(ItemIndex) < Cardinal(fTerritories.Count) Then
    Result := fTerritories[ItemIndex]
   Else
    Result := Nil;
  End;

 Procedure TCustomTerritoryBox.SetDisplayName(Value : TTerritoryDisplayName);
  Begin
   If DisplayName <> Value Then
    Begin
     fDisplayName := Value;
     RebuildInternalItems;
    End;
  End;

 Function TCustomTerritoryBox.GetImageIndex(Index : Integer) : Integer;
  Begin
   If (Index >= 0) And (Index < fTerritories.Count) And Assigned(Flags) Then
    Result := Flags.ImageIndexOf(fTerritories[Index])
   Else
    Result := -1;
  End;

 Function TCustomTerritoryBox.CollectAll : Boolean;
  Begin
   fTerritories.Assign(World.Territories);
   Result := True;
  End;

 Procedure TCustomTerritoryBox.RebuildInternalItems;
  Var
   Sel : TTerritoryInfo;
  Begin
   fTerritories.OnChange := Nil;
   Try
    Sel := ItemSelected;
    If Sorted Then
     fTerritories.Sort(DisplayName);
    If WindowHandle <> 0 Then
     Begin
      fTerritories.AssignLabelsTo(Inherited Items, DisplayName);
      DoItemsChange;
     End;
    ItemSelected := Sel;
   Finally
    fTerritories.OnChange := TerritoriesChanged;
   End;
  End;

{ TCustomTerritoryListBox }

 Constructor TCustomTerritoryListBox.Create(AOwner : TComponent);
  Begin
   Inherited Create(AOwner);
   fTerritories          := TTerritoryList.Create;
   fTerritories.OnChange := TerritoriesChanged;
   fDisplayName          := tnFriendlyName;
  End;

 Destructor TCustomTerritoryListBox.Destroy;
  Begin
   fTerritories.OnChange := Nil;
   fTerritories.Free;
   Inherited Destroy;
  End;

 Procedure TCustomTerritoryListBox.TerritoriesChanged(Sender : TObject);
  Begin
   If ItemsReady Then
    Begin
     fTerritories.AssignLabelsTo(Inherited Items, DisplayName);
     DoItemsChange;
    End;
  End;

 Procedure TCustomTerritoryListBox.ReadItemSelected(Reader : TReader);
  Begin
   ItemSelected := TerritoryOf(Reader.ReadString);
  End;

 Procedure TCustomTerritoryListBox.WriteItemSelected(Writer : TWriter);
  Begin
   Writer.WriteString(ItemSelected.Code2);
  End;

 Procedure TCustomTerritoryListBox.DefineProperties(Filer : TFiler);
  Begin
   Inherited DefineProperties(Filer);
   Filer.DefineProperty('Selected', ReadItemSelected, WriteItemSelected, Assigned(ItemSelected));
  End;

 Procedure TCustomTerritoryListBox.SetTerritories(Value : TTerritoryList);
  Begin
   fTerritories.Assign(Value);
  End;

 Procedure TCustomTerritoryListBox.SetItemSelected(Value : TTerritoryInfo);
  Begin
   ItemIndex := fTerritories.IndexOf(Value);
  End;

 Function TCustomTerritoryListBox.GetItemSelected : TTerritoryInfo;
  Begin
   If Cardinal(ItemIndex) < Cardinal(fTerritories.Count) Then
    Result := fTerritories[ItemIndex]
   Else
    Result := Nil;
  End;

 Procedure TCustomTerritoryListBox.SetDisplayName(Value : TTerritoryDisplayName);
  Begin
   If DisplayName <> Value Then
    Begin
     fDisplayName := Value;
     RebuildInternalItems;
    End;
  End;

 Function TCustomTerritoryListBox.GetImageIndex(Index : Integer) : Integer;
  Begin
   If (Index >= 0) And (Index < fTerritories.Count) And Assigned(Flags) Then
    Result := Flags.ImageIndexOf(fTerritories[Index])
   Else
    Result := -1;
  End;

 Function TCustomTerritoryListBox.CollectAll : Boolean;
  Begin
   fTerritories.Assign(World.Territories);
   Result := True;
  End;

 Procedure TCustomTerritoryListBox.RebuildInternalItems;
  Var
   Sel : TTerritoryInfo;
  Begin
   fTerritories.OnChange := Nil;
   Try
    Sel := ItemSelected;
    If Sorted Then
     fTerritories.Sort(DisplayName);
    If WindowHandle <> 0 Then
     Begin
      fTerritories.AssignLabelsTo(Inherited Items, DisplayName);
      DoItemsChange;
     End;
    ItemSelected := Sel;
   Finally
    fTerritories.OnChange := TerritoriesChanged;
   End;
  End;

 Procedure TCustomTerritoryListBox.SetSelection(Source : TReadonlyTerritoryList);
  Var
   i : Integer;
  Begin
   If MultiSelect Then
    For i        := 0 To fTerritories.Count - 1 Do
     Selected[i] := Source.Exists(fTerritories[i]);
  End;

 Procedure TCustomTerritoryListBox.GetSelection(Dest : TTerritoryList);
  Var
   i : Integer;
  Begin
   Dest.BeginUpdate;
   Try
    Dest.Clear;
    For i := 0 To fTerritories.Count - 1 Do
     If Selected[i] Then
      Dest.Add(fTerritories[i]);
   Finally
    Dest.EndUpdate;
   End;
  End;

{ TCustomTerritoryCheckListBox }

 Constructor TCustomTerritoryCheckListBox.Create(AOwner : TComponent);
  Begin
   Inherited Create(AOwner);
   fTerritories          := TTerritoryList.Create;
   fTerritories.OnChange := TerritoriesChanged;
   fDisplayName          := tnFriendlyName;
  End;

 Destructor TCustomTerritoryCheckListBox.Destroy;
  Begin
   fTerritories.OnChange := Nil;
   fTerritories.Free;
   Inherited Destroy;
  End;

 Procedure TCustomTerritoryCheckListBox.TerritoriesChanged(Sender : TObject);
  Begin
   If ItemsReady Then
    Begin
     fTerritories.AssignLabelsTo(Inherited Items, DisplayName);
     DoItemsChange;
    End;
  End;

 Procedure TCustomTerritoryCheckListBox.SetTerritories(Value : TTerritoryList);
  Begin
   fTerritories.Assign(Value);
  End;

 Procedure TCustomTerritoryCheckListBox.SetItemSelected(Value : TTerritoryInfo);
  Begin
   ItemIndex := fTerritories.IndexOf(Value);
  End;

 Function TCustomTerritoryCheckListBox.GetItemSelected : TTerritoryInfo;
  Begin
   If Cardinal(ItemIndex) < Cardinal(fTerritories.Count) Then
    Result := fTerritories[ItemIndex]
   Else
    Result := Nil;
  End;

 Procedure TCustomTerritoryCheckListBox.SetDisplayName(Value : TTerritoryDisplayName);
  Begin
   If DisplayName <> Value Then
    Begin
     fDisplayName := Value;
     RebuildInternalItems;
    End;
  End;

 Function TCustomTerritoryCheckListBox.GetImageIndex(Index : Integer) : Integer;
  Begin
   If (Index >= 0) And (Index < fTerritories.Count) And Assigned(Flags) Then
    Result := Flags.ImageIndexOf(fTerritories[Index])
   Else
    Result := -1;
  End;

 Function TCustomTerritoryCheckListBox.CollectAll : Boolean;
  Begin
   fTerritories.Assign(World.Territories);
   Result := True;
  End;

 Procedure TCustomTerritoryCheckListBox.RebuildInternalItems;
  Var
   Sel          : TTerritoryInfo;
   RestorePoint : TCheckListRecall;
  Begin
   fTerritories.OnChange := Nil;
   Try
    RestorePoint := TCheckListRecall.Create(Self);
    Try
     Sel := ItemSelected;
     If Sorted Then
      fTerritories.Sort(DisplayName);
     If WindowHandle <> 0 Then
      Begin
       fTerritories.AssignLabelsTo(Inherited Items, DisplayName);
       DoItemsChange;
      End;
     ItemSelected := Sel;
    Finally
     RestorePoint.Free;
    End;
   Finally
    fTerritories.OnChange := TerritoriesChanged;
   End;
  End;

 Procedure TCustomTerritoryCheckListBox.GetSelection(Dest : TTerritoryList; AllowDisabled : Boolean);
  Var
   i : Integer;
  Begin
   Dest.BeginUpdate;
   Try
    Dest.Clear;
    For i := 0 To Count - 1 Do
     If Checked[i] And (AllowDisabled Or ItemEnabled[i]) Then
      Dest.Add(Items[i]);
   Finally
    Dest.EndUpdate;
   End;
  End;

 Procedure TCustomTerritoryCheckListBox.SetSelection(Source : TReadonlyTerritoryList; AllowDisabled : Boolean);
  Var
   i : Integer;
  Begin
   For i := 0 To Count - 1 Do
    If AllowDisabled Or ItemEnabled[i] Then
     Checked[i] := Source.Exists(Items[i]);
  End;

{ TCustomCurrencyLabel }

 Constructor TCustomCurrencyLabel.Create(AOwner : TComponent);
  Begin
   Inherited Create(AOwner);
   fDisplayName := crnEnglishName;
  End;

 Procedure TCustomCurrencyLabel.ReadCurrency(Reader : TReader);
  Begin
   Currency := CurrencyOf(Reader.ReadString);
  End;

 Procedure TCustomCurrencyLabel.WriteCurrency(Writer : TWriter);
  Begin
   Writer.WriteString(Currency.IntlSymbol);
  End;

 Procedure TCustomCurrencyLabel.DefineProperties(Filer : TFiler);
  Begin
   Inherited DefineProperties(Filer);
   Filer.DefineProperty('CurrencyInfo', ReadCurrency, WriteCurrency, Assigned(Currency));
  End;

 Function TCustomCurrencyLabel.GetImageIndex : TImageIndex;
  Begin
   Result := Flags.ImageIndexOf(Currency);
  End;

 Function TCustomCurrencyLabel.GetLabelText : String;
  Begin
   If (DisplayName = crnNone) Or Not Assigned(Currency) Then
    Result := Caption
   Else
    Result := Currency.DisplayNames[DisplayName];
  End;

 Procedure TCustomCurrencyLabel.SetDisplayName(Value : TCurrencyDisplayName);
  Begin
   If DisplayName <> Value Then
    Begin
     fDisplayName := Value;
     AdjustBounds;
     Invalidate;
    End;
  End;

 Procedure TCustomCurrencyLabel.SetCurrency(Value : TCurrencyInfo);
  Begin
   If Currency <> Value Then
    Begin
     fCurrency := Value;
     AdjustBounds;
     Invalidate;
    End;
  End;

{ TCustomCurrencyBox }

 Constructor TCustomCurrencyBox.Create(AOwner : TComponent);
  Begin
   Inherited Create(AOwner);
   fCurrencies          := TCurrencyList.Create;
   fCurrencies.OnChange := CurrenciesChanged;
   fDisplayName         := crnEnglishName;
  End;

 Destructor TCustomCurrencyBox.Destroy;
  Begin
   fCurrencies.OnChange := Nil;
   fCurrencies.Free;
   Inherited Destroy;
  End;

 Procedure TCustomCurrencyBox.CurrenciesChanged(Sender : TObject);
  Begin
   If ItemsReady Then
    Begin
     fCurrencies.AssignLabelsTo(Inherited Items, DisplayName);
     DoItemsChange;
    End;
  End;

 Procedure TCustomCurrencyBox.ReadItemSelected(Reader : TReader);
  Begin
   ItemSelected := CurrencyOf(Reader.ReadString);
  End;

 Procedure TCustomCurrencyBox.WriteItemSelected(Writer : TWriter);
  Begin
   Writer.WriteString(ItemSelected.IntlSymbol);
  End;

 Procedure TCustomCurrencyBox.DefineProperties(Filer : TFiler);
  Begin
   Inherited DefineProperties(Filer);
   Filer.DefineProperty('Selected', ReadItemSelected, WriteItemSelected, Assigned(ItemSelected));
  End;

 Procedure TCustomCurrencyBox.SetCurrencies(Value : TCurrencyList);
  Begin
   fCurrencies.Assign(Value);
  End;

 Procedure TCustomCurrencyBox.SetItemSelected(Value : TCurrencyInfo);
  Begin
   ItemIndex := fCurrencies.IndexOf(Value);
  End;

 Function TCustomCurrencyBox.GetItemSelected : TCurrencyInfo;
  Begin
   If Cardinal(ItemIndex) < Cardinal(fCurrencies.Count) Then
    Result := fCurrencies[ItemIndex]
   Else
    Result := Nil;
  End;

 Procedure TCustomCurrencyBox.SetDisplayName(Value : TCurrencyDisplayName);
  Begin
   If DisplayName <> Value Then
    Begin
     fDisplayName := Value;
     RebuildInternalItems;
    End;
  End;

 Function TCustomCurrencyBox.GetImageIndex(Index : Integer) : Integer;
  Begin
   If (Index >= 0) And (Index < fCurrencies.Count) And Assigned(Flags) Then
    Result := Flags.ImageIndexOf(fCurrencies[Index])
   Else
    Result := -1;
  End;

 Function TCustomCurrencyBox.CollectAll : Boolean;
  Begin
   fCurrencies.Assign(World.Currencies);
   Result := True;
  End;

 Procedure TCustomCurrencyBox.RebuildInternalItems;
  Var
   Sel : TCurrencyInfo;
  Begin
   fCurrencies.OnChange := Nil;
   Try
    Sel := ItemSelected;
    If Sorted Then
     fCurrencies.Sort(DisplayName);
    If WindowHandle <> 0 Then
     Begin
      fCurrencies.AssignLabelsTo(Inherited Items, DisplayName);
      DoItemsChange;
     End;
    ItemSelected := Sel;
   Finally
    fCurrencies.OnChange := CurrenciesChanged;
   End;
  End;

{ TCustomCurrencyListBox }

 Constructor TCustomCurrencyListBox.Create(AOwner : TComponent);
  Begin
   Inherited Create(AOwner);
   fCurrencies          := TCurrencyList.Create;
   fCurrencies.OnChange := CurrenciesChanged;
   fDisplayName         := crnEnglishName;
  End;

 Destructor TCustomCurrencyListBox.Destroy;
  Begin
   fCurrencies.OnChange := Nil;
   fCurrencies.Free;
   Inherited Destroy;
  End;

 Procedure TCustomCurrencyListBox.CurrenciesChanged(Sender : TObject);
  Begin
   If ItemsReady Then
    Begin
     fCurrencies.AssignLabelsTo(Inherited Items, DisplayName);
     DoItemsChange;
    End;
  End;

 Procedure TCustomCurrencyListBox.ReadItemSelected(Reader : TReader);
  Begin
   ItemSelected := CurrencyOf(Reader.ReadString);
  End;

 Procedure TCustomCurrencyListBox.WriteItemSelected(Writer : TWriter);
  Begin
   Writer.WriteString(ItemSelected.IntlSymbol);
  End;

 Procedure TCustomCurrencyListBox.DefineProperties(Filer : TFiler);
  Begin
   Inherited DefineProperties(Filer);
   Filer.DefineProperty('Selected', ReadItemSelected, WriteItemSelected, Assigned(ItemSelected));
  End;

 Procedure TCustomCurrencyListBox.SetCurrencies(Value : TCurrencyList);
  Begin
   fCurrencies.Assign(Value);
  End;

 Procedure TCustomCurrencyListBox.SetItemSelected(Value : TCurrencyInfo);
  Begin
   ItemIndex := fCurrencies.IndexOf(Value);
  End;

 Function TCustomCurrencyListBox.GetItemSelected : TCurrencyInfo;
  Begin
   If Cardinal(ItemIndex) < Cardinal(fCurrencies.Count) Then
    Result := fCurrencies[ItemIndex]
   Else
    Result := Nil;
  End;

 Procedure TCustomCurrencyListBox.SetDisplayName(Value : TCurrencyDisplayName);
  Begin
   If DisplayName <> Value Then
    Begin
     fDisplayName := Value;
     RebuildInternalItems;
    End;
  End;

 Function TCustomCurrencyListBox.GetImageIndex(Index : Integer) : Integer;
  Begin
   If (Index >= 0) And (Index < fCurrencies.Count) And Assigned(Flags) Then
    Result := Flags.ImageIndexOf(fCurrencies[Index])
   Else
    Result := -1;
  End;

 Function TCustomCurrencyListBox.CollectAll : Boolean;
  Begin
   fCurrencies.Assign(World.Currencies);
   Result := True;
  End;

 Procedure TCustomCurrencyListBox.RebuildInternalItems;
  Var
   Sel : TCurrencyInfo;
  Begin
   fCurrencies.OnChange := Nil;
   Try
    Sel := ItemSelected;
    If Sorted Then
     fCurrencies.Sort(DisplayName);
    If WindowHandle <> 0 Then
     Begin
      fCurrencies.AssignLabelsTo(Inherited Items, DisplayName);
      DoItemsChange;
     End;
    ItemSelected := Sel;
   Finally
    fCurrencies.OnChange := CurrenciesChanged;
   End;
  End;

 Procedure TCustomCurrencyListBox.SetSelection(Source : TReadonlyCurrencyList);
  Var
   i : Integer;
  Begin
   If MultiSelect Then
    For i        := 0 To fCurrencies.Count - 1 Do
     Selected[i] := Source.Exists(fCurrencies[i]);
  End;

 Procedure TCustomCurrencyListBox.GetSelection(Dest : TCurrencyList);
  Var
   i : Integer;
  Begin
   Dest.BeginUpdate;
   Try
    Dest.Clear;
    For i := 0 To fCurrencies.Count - 1 Do
     If Selected[i] Then
      Dest.Add(fCurrencies[i]);
   Finally
    Dest.EndUpdate;
   End;
  End;

{ TCustomCurrencyCheckListBox }

 Constructor TCustomCurrencyCheckListBox.Create(AOwner : TComponent);
  Begin
   Inherited Create(AOwner);
   fCurrencies          := TCurrencyList.Create;
   fCurrencies.OnChange := CurrenciesChanged;
   fDisplayName         := crnEnglishName;
  End;

 Destructor TCustomCurrencyCheckListBox.Destroy;
  Begin
   fCurrencies.OnChange := Nil;
   fCurrencies.Free;
   Inherited Destroy;
  End;

 Procedure TCustomCurrencyCheckListBox.CurrenciesChanged(Sender : TObject);
  Begin
   If ItemsReady Then
    Begin
     fCurrencies.AssignLabelsTo(Inherited Items, DisplayName);
     DoItemsChange;
    End;
  End;

 Procedure TCustomCurrencyCheckListBox.SetCurrencies(Value : TCurrencyList);
  Begin
   fCurrencies.Assign(Value);
  End;

 Procedure TCustomCurrencyCheckListBox.SetItemSelected(Value : TCurrencyInfo);
  Begin
   ItemIndex := fCurrencies.IndexOf(Value);
  End;

 Function TCustomCurrencyCheckListBox.GetItemSelected : TCurrencyInfo;
  Begin
   If Cardinal(ItemIndex) < Cardinal(fCurrencies.Count) Then
    Result := fCurrencies[ItemIndex]
   Else
    Result := Nil;
  End;

 Procedure TCustomCurrencyCheckListBox.SetDisplayName(Value : TCurrencyDisplayName);
  Begin
   If DisplayName <> Value Then
    Begin
     fDisplayName := Value;
     RebuildInternalItems;
    End;
  End;

 Function TCustomCurrencyCheckListBox.GetImageIndex(Index : Integer) : Integer;
  Begin
   If (Index >= 0) And (Index < fCurrencies.Count) And Assigned(Flags) Then
    Result := Flags.ImageIndexOf(fCurrencies[Index])
   Else
    Result := -1;
  End;

 Function TCustomCurrencyCheckListBox.CollectAll : Boolean;
  Begin
   fCurrencies.Assign(World.Currencies);
   Result := True;
  End;

 Procedure TCustomCurrencyCheckListBox.RebuildInternalItems;
  Var
   Sel          : TCurrencyInfo;
   RestorePoint : TCheckListRecall;
  Begin
   fCurrencies.OnChange := Nil;
   Try
    RestorePoint := TCheckListRecall.Create(Self);
    Try
     Sel := ItemSelected;
     If Sorted Then
      fCurrencies.Sort(DisplayName);
     If WindowHandle <> 0 Then
      Begin
       fCurrencies.AssignLabelsTo(Inherited Items, DisplayName);
       DoItemsChange;
      End;
     ItemSelected := Sel;
    Finally
     RestorePoint.Free;
    End;
   Finally
    fCurrencies.OnChange := CurrenciesChanged;
   End;
  End;

 Procedure TCustomCurrencyCheckListBox.GetSelection(Dest : TCurrencyList; AllowDisabled : Boolean);
  Var
   i : Integer;
  Begin
   Dest.BeginUpdate;
   Try
    Dest.Clear;
    For i := 0 To Count - 1 Do
     If Checked[i] And (AllowDisabled Or ItemEnabled[i]) Then
      Dest.Add(Items[i]);
   Finally
    Dest.EndUpdate;
   End;
  End;

 Procedure TCustomCurrencyCheckListBox.SetSelection(Source : TReadonlyCurrencyList; AllowDisabled : Boolean);
  Var
   i : Integer;
  Begin
   For i := 0 To Count - 1 Do
    If AllowDisabled Or ItemEnabled[i] Then
     Checked[i] := Source.Exists(Items[i]);
  End;

Initialization
 CheckBoxSize := CalcCheckBoxSize;
 DropDownSize := CalcDropDownSize;

End.
