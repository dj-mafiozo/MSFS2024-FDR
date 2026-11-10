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
/// This unit implements classes and functions to format text in Rich Edit
/// controls using BBCode-style tags.
/// </summary>
Unit i18nBBCode;

{$I DELPHIAREA.INC}

Interface

 Uses
  SysUtils, Classes, Types, Contnrs, Windows, Messages, Graphics,
  RichEdit, ComCtrls;

 Type

  {$Region 'xmldoc'}
  /// <summary>
  /// This is a class reference for the <see cref="TBBCode"/> class or for one of
  /// its descendants.
  /// </summary>
  /// <remarks>
  /// TBBCodeClass is the metaclass for <see cref="TBBCode"/>. Its value is the
  /// class reference for <see cref="TBBCode"/> or for one of its descendants.
  /// </remarks>
  {$Endregion}
  TBBCodeClass = Class Of TBBCode;

{$Region 'xmldoc'}
/// <summary>
/// This class is the base class for classes that represent a BBCode tag.
/// </summary>
/// <remarks>
/// <para>
/// TBBCode is an abstract class that cannot be instantiated. Descendant
/// BBCode classes override many of the methods of the TBBCode class to address
/// the particular character and paragraph format settings of the Rich Edit
/// controls.
/// </para>
/// <para>
/// To add support for a new BBCode tag, subclass the TBBCode class and override
/// at least the <see cref="TBBCode.GetTagName"/> and <see cref="TBBCode.Prepare"/>
/// methods. Then, register the new class using the <see cref="BBCodes.Register"/>
/// procedure.
/// </para>
/// </remarks>
{$Endregion}

    TBBCode = Class Abstract(TObject)
   Private
    fSelStart  : Integer;
    fSelEnd    : Integer;
    fAttribute : String;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the BBCode tag that is represented by this BBCode object.
    /// </summary>
    /// <returns>
    /// The BBCode tag.
    /// </returns>
    {$Endregion}
    Class Function GetTagName : String; Virtual; Abstract;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the internal offset of a character in a Rich Edit control by
    /// considering CR/LF pair of characters as only one character.
    /// </summary>
    /// <param name="hRichEdit">
    /// Window handle of the Rich Edit control.
    /// </param>
    /// <param name="CharPos">
    /// The logical offset of the character.
    /// </param>
    /// <returns>
    /// The actual zero-based offset of the character.
    /// </returns>
    {$Endregion}
    Function RealCharPos(hRichEdit : THandle; CharPos : Integer) : Integer; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Selects a range of characters in a Rich Edit control.
    /// </summary>
    /// <param name="hRichEdit">
    /// Window handle of the Rich Edit control.
    /// </param>
    /// <param name="ASelStart">
    /// Start of the selection range in character position.
    /// </param>
    /// <param name="ASelEnd">
    /// End of the selection range in character position.
    /// </param>
    {$Endregion}
    Procedure SelectRange(hRichEdit : THandle; ASelStart, ASelEnd : Integer); Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Updates the value of the paragraph and character format settings according to
    /// the BBCode requirements.
    /// </summary>
    /// <param name="ParaFormat">
    /// Paragraph format settings.
    /// </param>
    /// <param name="CharFormat">
    /// Character format settings.
    /// </param>
    {$Endregion}
    Procedure Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2); Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the raw parameters of the BBCode tag.
    /// </summary>
    {$Endregion}
    Property Attribute : String Read fAttribute Write fAttribute;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Applies the BBCode to a Rich Edit control at a specified text range.
    /// </summary>
    /// <param name="hRichEdit">
    /// Window handle of the Rich Edit control.
    /// </param>
    /// <param name="ASelStart">
    /// Start of the selection range in character position.
    /// </param>
    /// <param name="ASelEnd">
    /// End of the selection range in character position.
    /// </param>
    {$Endregion}
    Procedure Apply(hRichEdit : THandle; ASelStart, ASelEnd : Integer); Overload; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Applies the BBCode to a Rich Edit control at the text range specified
    /// by the <see cref="SelStart"/> and <see cref="SelEnd"/> properties.
    /// </summary>
    /// <param name="hRichEdit">
    /// Window handle of the Rich Edit control.
    /// </param>
    /// <param name="Offset">
    /// Optional amount of characters to offset the text range.
    /// </param>
    {$Endregion}
    Procedure Apply(hRichEdit : THandle; Offset : Integer = 0); Overload; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// In a specified Rich Edit control, surrounds a specified text range with
    /// the BBCode's open and close tags.
    /// </summary>
    /// <param name="hRichEdit">
    /// Window handle of the Rich Edit control.
    /// </param>
    /// <param name="ASelStart">
    /// Start of the selection range in character position.
    /// </param>
    /// <param name="ASelEnd">
    /// End of the selection range in character position.
    /// </param>
    {$Endregion}
    Function Mark(hRichEdit : THandle; ASelStart, ASelEnd : Integer) : Integer; Overload; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// In a specified Rich Edit control, surrounds the text range specified by
    /// the <see cref="SelStart"/> and <see cref="SelEnd"/> properties with the BBCode's
    /// open and close tags.
    /// </summary>
    /// <param name="hRichEdit">
    /// Window handle of the Rich Edit control.
    /// </param>
    /// <param name="Offset">
    /// Optional amount of characters to offset the text range.
    /// </param>
    {$Endregion}
    Function Mark(hRichEdit : THandle; Offset : Integer = 0) : Integer; Overload; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the BBCode tag name.
    /// </summary>
    {$Endregion}
    Property TagName : String Read GetTagName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the start of the text range, in character position.
    /// </summary>
    {$Endregion}
    Property SelStart : Integer Read fSelStart Write fSelStart;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the end of the text range, in character position.
    /// </summary>
    {$Endregion}
    Property SelEnd : Integer Read fSelEnd Write fSelEnd;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TBBCodeObjectList maintains a list of (owned) <see cref="TBBCode"/> objects.
/// </summary>
/// <remarks>
/// Use TBBCodeObjectList to store and maintain a list of <see cref="TBBCode"/>
/// objects and provides properties and methods to add, delete, rearrange, locate,
/// access, and sort them.
/// </remarks>
{$Endregion}

  TBBCodeObjectList = Class(TObjectList)
   Private
    Function GetItems(Index : Integer) : TBBCode; Inline;
    Procedure SetItems(Index : Integer; Value : TBBCode);
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Retrieves the first <see cref="TBBCode"/> object in the <see cref="Items"/>
    /// array.
    /// </summary>
    /// <returns>
    /// The first item in the list.
    /// </returns>
    /// <seealso cref="Last"/>
    {$Endregion}
    Function First : TBBCode; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Retrieves the last <see cref="TBBCode"/> object in the
    /// <see cref="Items"/> array.
    /// </summary>
    /// <returns>
    /// The last item in the list.
    /// </returns>
    /// <seealso cref="First"/>
    {$Endregion}
    Function Last : TBBCode; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Inserts the <paramref name="Item"/> parameter at the end of the
    /// <see cref="Items"/> array.
    /// </summary>
    /// <param name="Item">
    /// The <see cref="TBBCode"/> object to add.
    /// </param>
    /// <returns>
    /// The index of the new item.
    /// </returns>
    /// <seealso cref="Insert"/>
    {$Endregion}
    Function Add(Item : TBBCode) : Integer; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Inserts the <paramref name="Item"/> parameter in the
    /// <see cref="Items"/> array, at the position specified
    /// by <paramref name="Index"/>.
    /// </summary>
    /// <param name="Index">
    /// Position of the item in the <see cref="Items"/> array.
    /// </param>
    /// <param name="Item">
    /// The <see cref="TBBCode"/> object to insert.
    /// </param>
    /// <seealso cref="Add"/>
    {$Endregion}
    Procedure Insert(Index : Integer; Item : TBBCode); Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Deletes the first reference to the <paramref name="Item"/> parameter from
    /// the <see cref="Items"/> array.
    /// </summary>
    /// <param name="Item">
    /// The <see cref="TBBCode"/> object to remove.
    /// </param>
    /// <returns>
    /// The index of the removed item, or -1 if the item is not found.
    /// </returns>
    /// <seealso cref="RemoveItem"/>
    {$Endregion}
    Function Remove(Item : TBBCode) : Integer; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Deletes the first or last reference to the <paramref name="Item"/> parameter
    /// from the <see cref="Items"/> array.
    /// </summary>
    /// <param name="Item">
    /// The <see cref="TBBCode"/> object to remove.
    /// </param>
    /// <param name="Direction">
    /// The direction of search for locating the item.
    /// </param>
    /// <returns>
    /// The index of the removed item, or -1 if the item is not found.
    /// </returns>
    /// <seealso cref="Remove"/>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Function RemoveItem(Item : TBBCode; Direction : TList.TDirection) : Integer;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Deletes the first reference to the <paramref name="Item"/> parameter from
    /// the <see cref="Items"/> array.
    /// </summary>
    /// <param name="Item">
    /// The <see cref="TBBCode"/> object to extract.
    /// </param>
    /// <returns>
    /// The extracted item, or <see langword="nil"/> if the item is not found.
    /// </returns>
    /// <seealso cref="ExtractItem"/>
    {$Endregion}
    Function Extract(Item : TBBCode) : TBBCode; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Deletes the first or last reference to the <paramref name="Item"/> parameter
    /// from the <see cref="Items"/> array.
    /// </summary>
    /// <param name="Item">
    /// The <see cref="TBBCode"/> object to extract.
    /// </param>
    /// <param name="Direction">
    /// The direction of search for locating the item.
    /// </param>
    /// <returns>
    /// The extracted item, or <see langword="nil"/> if the item is not found.
    /// </returns>
    /// <seealso cref="Extract"/>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Function ExtractItem(Item : TBBCode; Direction : TList.TDirection) : TBBCode; Inline;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the index of the first reference to the <paramref name="Item"/> parameter
    /// in the <see cref="Items"/> array.
    /// </summary>
    /// <param name="Item">
    /// The <see cref="TBBCode"/> object to locate.
    /// </param>
    /// <returns>
    /// The index of the item, or -1 if the item is not found.
    /// </returns>
    /// <seealso cref="IndexOfItem"/>
    {$Endregion}
    Function IndexOf(Item : TBBCode) : Integer; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the index of the first or last reference to the <paramref name="Item"/>
    /// parameter in the <see cref="Items"/> array.
    /// </summary>
    /// <param name="Item">
    /// The <see cref="TBBCode"/> object to locate.
    /// </param>
    /// <param name="Direction">
    /// The direction of search for locating the item.
    /// </param>
    /// <returns>
    /// The index of the item, or -1 if the item is not found.
    /// </returns>
    /// <seealso cref="IndexOf"/>
    {$Endregion}
    {$IFDEF COMPILER2010_UP}
    Function IndexOfItem(Item : TBBCode; Direction : TList.TDirection) : Integer; Inline;
    {$ENDIF}
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the <see cref="TBBCode"/> objects.
    /// </summary>
    {$Endregion}
    Property Items[Index : Integer] : TBBCode Read GetItems Write SetItems; Default;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class is the base class for classes that represent a BBCode tag that
/// toggles a feature on or off.
/// </summary>
/// <remarks>
/// TSwitchableBBCode is an abstract class that cannot be instantiated. This class
/// is the ancestor for BBCode classes that represent a BBCode tag, which can be toggled
/// on or off using an optional parameter.
/// </remarks>
{$Endregion}

    TSwitchableBBCode = Class Abstract(TBBCode)
   Private
    Function GetActive : Boolean;
    Procedure SetActive(Value : Boolean);
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the BBCode is on or off.
    /// </summary>
    {$Endregion}
    Property Active : Boolean Read GetActive Write SetActive;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class controls the bold attribute of characters in a Rich Edit control.
/// </summary>
/// <remarks>
/// TBBCodeBold class represents the <c>[B]</c> BBCode tag.
/// <para>
/// The <c>[B]</c> BBCode tag accepts one optional parameter, that can be one
/// of the values listed in the following table:
/// </para>
/// <list type="table">
///   <listheader>
///     <term>Value</term>
///     <description>Description</description>
///   </listheader>
///   <item>
///     <term>On | Yes</term>
///     <description>Marks characters as bold (default)</description>
///   </item>
///   <item>
///     <term>Off | No</term>
///     <description>Removes the bold formatting of the characters</description>
///   </item>
/// </list>
/// </remarks>
{$Endregion}

  TBBCodeBold = Class(TSwitchableBBCode)
   Protected
    Class Function GetTagName : String; Override;
    Procedure Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2); Override;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class controls the italic attribute of characters in a Rich Edit control.
/// </summary>
/// <remarks>
/// TBBCodeItalic class represents the <c>[I]</c> BBCode tag.
/// <para>
/// The <c>[I]</c> BBCode tag accepts one optional parameter, that can be one
/// of the values listed in the following table:
/// </para>
/// <list type="table">
///   <listheader>
///     <term>Value</term>
///     <description>Description</description>
///   </listheader>
///   <item>
///     <term>On | Yes</term>
///     <description>Marks characters as italic (default)</description>
///   </item>
///   <item>
///     <term>Off | No</term>
///     <description>Removes the italic format of the characters</description>
///   </item>
/// </list>
/// </remarks>
{$Endregion}

  TBBCodeItalic = Class(TSwitchableBBCode)
   Protected
    Class Function GetTagName : String; Override;
    Procedure Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2); Override;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class controls the underline attribute of characters in a Rich Edit control.
/// </summary>
/// <remarks>
/// TBBCodeUnderline class represents the <c>[U]</c> BBCode tag.
/// <para>
/// The <c>[U]</c> BBCode tag accepts two optional parameters, separated by comma.
/// The order of parameters is not important.
/// </para>
/// <para>
/// The <c>type</c> parameter determines the type of underline and can be one of the
/// following values:
/// </para>
/// <list type="table">
///   <listheader>
///     <term>Value</term>
///     <description>Description</description>
///   </listheader>
///   <item>
///     <term>None</term>
///     <description>No underline</description>
///   </item>
///   <item>
///     <term>Normal</term>
///     <description>Single-line solid underline (default)</description>
///   </item>
///   <item>
///     <term>Word</term>
///     <description>Single-line underline broken between words</description>
///   </item>
///   <item>
///     <term>Double</term>
///     <description>Double-line underline</description>
///   </item>
///   <item>
///     <term>Dotted</term>
///     <description>Dotted pattern underline</description>
///   </item>
///   <item>
///     <term>Dash</term>
///     <description>Dashed pattern underline</description>
///   </item>
///   <item>
///     <term>DashDot</term>
///     <description>Dash-dot pattern underline</description>
///   </item>
///   <item>
///     <term>DashDotDot</term>
///     <description>Dash-dot-dot pattern underline</description>
///   </item>
///   <item>
///     <term>Wave</term>
///     <description>Single-line wave style underline</description>
///   </item>
///   <item>
///     <term>Thick</term>
///     <description>Single-line solid underline with extra thickness</description>
///   </item>
///   <item>
///     <term>HairLine</term>
///     <description>Single-line solid underline with less thickness</description>
///   </item>
///   <item>
///     <term>DoubleWave</term>
///     <description>Double-line wave style underline</description>
///   </item>
///   <item>
///     <term>HeavyWave</term>
///     <description>Single-line wave style underline with extra thickness</description>
///   </item>
///   <item>
///     <term>LongDash</term>
///     <description>Long dash pattern underline</description>
///   </item>
/// </list>
/// <para>
/// The <c>color</c> parameter determines the color of the underline and can be one of the
/// following values:
/// </para>
/// <list type="table">
///   <listheader>
///     <term>Value</term>
///     <description>Description</description>
///   </listheader>
///   <item>
///     <term>Auto</term>
///     <description>Text's foreground color (default)</description>
///   </item>
///   <item>
///     <term>Blue</term>
///     <description>Blue</description>
///   </item>
///   <item>
///     <term>Aqua</term>
///     <description>Aqua</description>
///   </item>
///   <item>
///     <term>Lime</term>
///     <description>Lime</description>
///   </item>
///   <item>
///     <term>Fuchsia</term>
///     <description>Fuchsia</description>
///   </item>
///   <item>
///     <term>Red</term>
///     <description>Red</description>
///   </item>
///   <item>
///     <term>Yellow</term>
///     <description>Yellow</description>
///   </item>
///   <item>
///     <term>White</term>
///     <description>White</description>
///   </item>
///   <item>
///     <term>Navy</term>
///     <description>Navy</description>
///   </item>
///   <item>
///     <term>Teal</term>
///     <description>Teal</description>
///   </item>
///   <item>
///     <term>Green</term>
///     <description>Green</description>
///   </item>
///   <item>
///     <term>Purple</term>
///     <description>Purple</description>
///   </item>
///   <item>
///     <term>Maroon</term>
///     <description>Maroon</description>
///   </item>
///   <item>
///     <term>Olive</term>
///     <description>Olive</description>
///   </item>
///   <item>
///     <term>Gray</term>
///     <description>Gray</description>
///   </item>
///   <item>
///     <term>Silver</term>
///     <description>Silver</description>
///   </item>
/// </list>
/// <para>
/// Note: Some underline types may have no effect on some versions of
/// the Rich Edit control.
/// </para>
/// </remarks>
{$Endregion}

  TBBCodeUnderline = Class(TBBCode)
   Public
    Type
    {$Region 'xmldoc'}
    /// <summary>
    /// This enumeration type identifies the styles of an underline.
    /// </summary>
    {$Endregion}
    TUnderlineType = (
    {$Region 'xmldoc'}
    /// <summary>
    /// No underline
    /// </summary>
    {$Endregion}
    ulNone,
    {$Region 'xmldoc'}
    /// <summary>
    /// Single-line solid underline
    /// </summary>
    {$Endregion}
    ulNormal,
    {$Region 'xmldoc'}
    /// <summary>
    /// Single-line underline broken between words
    /// </summary>
    {$Endregion}
    ulWord,
    {$Region 'xmldoc'}
    /// <summary>
    /// Double-line underline
    /// </summary>
    {$Endregion}
    ulDouble,
    {$Region 'xmldoc'}
    /// <summary>
    /// Dotted pattern underline
    /// </summary>
    {$Endregion}
    ulDotted,
    {$Region 'xmldoc'}
    /// <summary>
    /// Dashed pattern underline
    /// </summary>
    {$Endregion}
    ulDash,
    {$Region 'xmldoc'}
    /// <summary>
    /// Dash-dot pattern underline
    /// </summary>
    {$Endregion}
    ulDashDot,
    {$Region 'xmldoc'}
    /// <summary>
    /// Dash-dot-dot pattern underline
    /// </summary>
    {$Endregion}
    ulDashDotDot,
    {$Region 'xmldoc'}
    /// <summary>
    /// Single-line wave style underline
    /// </summary>
    {$Endregion}
    ulWave,
    {$Region 'xmldoc'}
    /// <summary>
    /// Single-line solid underline with extra thickness
    /// </summary>
    {$Endregion}
    ulThick,
    {$Region 'xmldoc'}
    /// <summary>
    /// Single-line solid underline with less thickness
    /// </summary>
    {$Endregion}
    ulHairLine,
    {$Region 'xmldoc'}
    /// <summary>
    /// Double-line wave style underline
    /// </summary>
    {$Endregion}
    ulDoubleWave,
    {$Region 'xmldoc'}
    /// <summary>
    /// Single-line wave style underline with extra thickness
    /// </summary>
    {$Endregion}
    ulHeavyWave,
    {$Region 'xmldoc'}
    /// <summary>
    /// Long dash pattern underline
    /// </summary>
    {$Endregion}
    ulLongDash
    );
    {$Region 'xmldoc'}
    /// <summary>
    /// This enumeration type identifies the colors of an underline.
    /// </summary>
    {$Endregion}
    TUnderlineColor = (
    {$Region 'xmldoc'}
    /// <summary>
    /// Same color as the foreground color
    /// </summary>
    {$Endregion}
    ucAuto,
    {$Region 'xmldoc'}
    /// <summary>
    /// Blue color
    /// </summary>
    {$Endregion}
    ucBlue,
    {$Region 'xmldoc'}
    /// <summary>
    /// Aqua color
    /// </summary>
    {$Endregion}
    ucAqua,
    {$Region 'xmldoc'}
    /// <summary>
    /// Lime color
    /// </summary>
    {$Endregion}
    ucLime,
    {$Region 'xmldoc'}
    /// <summary>
    /// Fuchsia color
    /// </summary>
    {$Endregion}
    ucFuchsia,
    {$Region 'xmldoc'}
    /// <summary>
    /// Red color
    /// </summary>
    {$Endregion}
    ucRed,
    {$Region 'xmldoc'}
    /// <summary>
    /// Yellow color
    /// </summary>
    {$Endregion}
    ucYellow,
    {$Region 'xmldoc'}
    /// <summary>
    /// White color
    /// </summary>
    {$Endregion}
    ucWhite,
    {$Region 'xmldoc'}
    /// <summary>
    /// Navy color
    /// </summary>
    {$Endregion}
    ucNavy,
    {$Region 'xmldoc'}
    /// <summary>
    /// Teal color
    /// </summary>
    {$Endregion}
    ucTeal,
    {$Region 'xmldoc'}
    /// <summary>
    /// Green color
    /// </summary>
    {$Endregion}
    ucGreen,
    {$Region 'xmldoc'}
    /// <summary>
    /// Purple color
    /// </summary>
    {$Endregion}
    ucPurple,
    {$Region 'xmldoc'}
    /// <summary>
    /// Maroon color
    /// </summary>
    {$Endregion}
    ucMaroon,
    {$Region 'xmldoc'}
    /// <summary>
    /// Olive color
    /// </summary>
    {$Endregion}
    ucOlive,
    {$Region 'xmldoc'}
    /// <summary>
    /// Gray color
    /// </summary>
    {$Endregion}
    ucGray,
    {$Region 'xmldoc'}
    /// <summary>
    /// Silver color
    /// </summary>
    {$Endregion}
    ucSilver
    );
   Private
    Function GetUnderLineType : TUnderlineType;
    Procedure SetUnderlineType(Value : TUnderlineType);
    Function GetUnderLineColor : TUnderlineColor;
    Procedure SetUnderlineColor(Value : TUnderlineColor);
   Protected
    Class Function GetTagName : String; Override;
    Procedure Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2); Override;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the type of underline.
    /// </summary>
    {$Endregion}
    Property UnderlineType : TUnderlineType Read GetUnderLineType Write SetUnderlineType;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the color of the underline.
    /// </summary>
    {$Endregion}
    Property UnderlineColor : TUnderlineColor Read GetUnderLineColor Write SetUnderlineColor;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class controls the strikeout attribute of characters in a Rich Edit control.
/// </summary>
/// <remarks>
/// TBBCodeStrikeout class represents the <c>[S]</c> BBCode tag.
/// <para>
/// The <c>[S]</c> BBCode tag accepts one optional parameter, that can be one
/// of the values listed in the following table:
/// </para>
/// <list type="table">
///   <listheader>
///     <term>Value</term>
///     <description>Description</description>
///   </listheader>
///   <item>
///     <term>On | Yes</term>
///     <description>Marks characters with a line straight through the middle (default)</description>
///   </item>
///   <item>
///     <term>Off | No</term>
///     <description>Removes the strikeout format of the characters</description>
///   </item>
/// </list>
/// </remarks>
{$Endregion}

  TBBCodeStrikeout = Class(TSwitchableBBCode)
   Protected
    Class Function GetTagName : String; Override;
    Procedure Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2); Override;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class controls the font name attribute of characters in a Rich Edit control.
/// </summary>
/// <remarks>
/// TBBCodeFontFace class represents the <c>[FONT]</c> BBCode tag.
/// The <c>[FONT]</c> BBCode tag has one required parameter, which is the name of
/// the font to use for displaying the text.
/// </remarks>
{$Endregion}

  TBBCodeFontFace = Class(TBBCode)
   Private
    Function GetFontName : String;
    Procedure SetFontName(Const Value : String);
   Protected
    Class Function GetTagName : String; Override;
    Procedure Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2); Override;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the name of font.
    /// </summary>
    {$Endregion}
    Property FontName : String Read GetFontName Write SetFontName;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class controls the font size attribute of characters in a Rich Edit control.
/// </summary>
/// <remarks>
/// TBBCodeFontSize class represents the <c>[SIZE]</c> BBCode tag.
/// The <c>[SIZE]</c> BBCode tag has one required parameter, which is an integer
/// value that determines the size of the font to use for displaying the text.
/// </remarks>
{$Endregion}

  TBBCodeFontSize = Class(TBBCode)
   Private
    Function GetSize : Integer;
    Procedure SetSize(Value : Integer);
   Protected
    Class Function GetTagName : String; Override;
    Procedure Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2); Override;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the size of font, in points.
    /// </summary>
    {$Endregion}
    Property Size : Integer Read GetSize Write SetSize;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class controls the foreground color attribute of characters in a Rich Edit control.
/// </summary>
/// <remarks>
/// TBBCodeFontColor class represents the <c>[COLOR]</c> BBCode tag.
/// The <c>[COLOR]</c> BBCode tag has one required parameter, which is the foreground
/// color to use for displaying the text.
/// The color can be expressed by name (e.g. Red), web format (e.g. #F00 or #FF0000),
/// or hexadecimal value (e.g. $000000FF).
/// </remarks>
{$Endregion}

  TBBCodeFontColor = Class(TBBCode)
   Private
    Function GetColor : TColor;
    Procedure SetColor(Value : TColor);
   Protected
    Class Function GetTagName : String; Override;
    Procedure Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2); Override;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the foreground color.
    /// </summary>
    {$Endregion}
    Property Color : TColor Read GetColor Write SetColor;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class controls the background color attribute of characters in a Rich Edit control.
/// </summary>
/// <remarks>
/// TBBCodeBackColor class represents the <c>[BACKCOLOR]</c> BBCode tag.
/// The <c>[BACKCOLOR]</c> BBCode tag has one required parameter, which is the background
/// color to use for displaying the text.
/// The color can be expressed by name (e.g. Red), web format (e.g. #F00 or #FF0000),
/// or hexadecimal value (e.g. $000000FF).
/// </remarks>
{$Endregion}

  TBBCodeBackColor = Class(TBBCode)
   Private
    Function GetColor : TColor;
    Procedure SetColor(Value : TColor);
   Protected
    Class Function GetTagName : String; Override;
    Procedure Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2); Override;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the background color.
    /// </summary>
    {$Endregion}
    Property Color : TColor Read GetColor Write SetColor;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class controls the link attribute of characters in a Rich Edit control.
/// </summary>
/// <remarks>
/// TBBCodeLink class represents the <c>[LINK]</c> BBCode tag.
/// A click on the link will cause the Rich Edit control to generate a notification
/// of EN_LINK.
/// The <c>[LINK]</c> BBCode tag accepts one optional parameter, that can be one
/// of the values listed in the following table:
/// <list type="table">
///   <listheader>
///     <term>Value</term>
///     <description>Description</description>
///   </listheader>
///   <item>
///     <term>On | Yes</term>
///     <description>Marks up the text as a link (default)</description>
///   </item>
///   <item>
///     <term>Off | No</term>
///     <description>Breaks the link</description>
///   </item>
/// </list>
/// </remarks>
{$Endregion}

  TBBCodeLink = Class(TSwitchableBBCode)
   Protected
    Class Function GetTagName : String; Override;
    Procedure Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2); Override;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class controls the subscript attribute of characters in a Rich Edit control.
/// </summary>
/// <remarks>
/// TBBCodeSubscript class represents the <c>[SUB]</c> BBCode tag.
/// The <c>[SUB]</c> BBCode tag accepts one optional parameter, that can be one
/// of the values listed in the following table:
/// <list type="table">
///   <listheader>
///     <term>Value</term>
///     <description>Description</description>
///   </listheader>
///   <item>
///     <term>On | Yes</term>
///     <description>Marks characters as subscript (default)</description>
///   </item>
///   <item>
///     <term>Off | No</term>
///     <description>Removes the subscript attribute of the characters</description>
///   </item>
/// </list>
/// </remarks>
{$Endregion}

  TBBCodeSubscript = Class(TSwitchableBBCode)
   Protected
    Class Function GetTagName : String; Override;
    Procedure Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2); Override;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class controls the superscript attribute of characters in a Rich Edit control.
/// </summary>
/// <remarks>
/// TBBCodeSuperscript class represents the <c>[SUP]</c> BBCode tag.
/// The <c>[SUP]</c> BBCode tag accepts one optional parameter, that can be one
/// of the values listed in the following table:
/// <list type="table">
///   <listheader>
///     <term>Value</term>
///     <description>Description</description>
///   </listheader>
///   <item>
///     <term>On | Yes</term>
///     <description>Marks characters as superscript (default)</description>
///   </item>
///   <item>
///     <term>Off | No</term>
///     <description>Removes the superscript attribute of the characters</description>
///   </item>
/// </list>
/// </remarks>
{$Endregion}

  TBBCodeSuperscript = Class(TSwitchableBBCode)
   Protected
    Class Function GetTagName : String; Override;
    Procedure Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2); Override;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class controls the disabled attribute of characters in a Rich Edit control.
/// </summary>
/// <remarks>
/// TBBCodeDisabled class represents the <c>[DISABLED]</c> BBCode tag.
/// The <c>[DISABLED]</c> BBCode tag accepts one optional parameter, that can be
/// one of the values listed in the following table:
/// <list type="table">
///   <listheader>
///     <term>Value</term>
///     <description>Description</description>
///   </listheader>
///   <item>
///     <term>On | Yes</term>
///     <description>Displays characters as disabled (default)</description>
///   </item>
///   <item>
///     <term>Off | No</term>
///     <description>Removes the disabled attribute of the characters</description>
///   </item>
/// </list>
/// </remarks>
{$Endregion}

  TBBCodeDisabled = Class(TSwitchableBBCode)
   Protected
    Class Function GetTagName : String; Override;
    Procedure Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2); Override;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class controls the protected attribute of characters in a Rich Edit control.
/// </summary>
/// <remarks>
/// TBBCodeProtected class represents the <c>[PROTECTED]</c> BBCode tag.
/// An attempt to modify protected text will cause the Rich Edit control to generate
/// a notification of EN_PROTECTED.
/// The <c>[PROTECTED]</c> BBCode tag accepts one optional parameter, that can be
/// one of the values listed in the following table:
/// <list type="table">
///   <listheader>
///     <term>Value</term>
///     <description>Description</description>
///   </listheader>
///   <item>
///     <term>On | Yes</term>
///     <description>Marks characters as protected (default)</description>
///   </item>
///   <item>
///     <term>Off | No</term>
///     <description>Removes the protected attribute of the characters</description>
///   </item>
/// </list>
/// </remarks>
{$Endregion}

  TBBCodeProtected = Class(TSwitchableBBCode)
   Protected
    Class Function GetTagName : String; Override;
    Procedure Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2); Override;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class controls the hidden attribute of characters in a Rich Edit control.
/// </summary>
/// <remarks>
/// TBBCodeHidden class represents the <c>[HIDDEN]</c> BBCode tag.
/// The <c>[HIDDEN]</c> BBCode tag accepts one optional parameter, that can be
/// one of the values listed in the following table:
/// <list type="table">
///   <listheader>
///     <term>Value</term>
///     <description>Description</description>
///   </listheader>
///   <item>
///     <term>On | Yes</term>
///     <description>Does not display characters (default)</description>
///   </item>
///   <item>
///     <term>Off | No</term>
///     <description>Removes the hidden attribute of the characters</description>
///   </item>
/// </list>
/// </remarks>
{$Endregion}

  TBBCodeHidden = Class(TSwitchableBBCode)
   Protected
    Class Function GetTagName : String; Override;
    Procedure Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2); Override;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class controls the outline attribute of characters in a Rich Edit control.
/// </summary>
/// <remarks>
/// TBBCodeOutline class represents the <c>[OUTLINE]</c> BBCode tag.
/// The <c>[OUTLINE]</c> BBCode tag accepts one optional parameter, that can be
/// one of the values listed in the following table:
/// <list type="table">
///   <listheader>
///     <term>Value</term>
///     <description>Description</description>
///   </listheader>
///   <item>
///     <term>On | Yes</term>
///     <description>Displays characters as outlined characters (default)</description>
///   </item>
///   <item>
///     <term>Off | No</term>
///     <description>Removes the outline attribute of the characters</description>
///   </item>
/// </list>
/// </remarks>
{$Endregion}

  TBBCodeOutline = Class(TSwitchableBBCode)
   Protected
    Class Function GetTagName : String; Override;
    Procedure Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2); Override;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class controls the shadow attribute of characters in a Rich Edit control.
/// </summary>
/// <remarks>
/// TBBCodeShadow class represents the <c>[SHADOW]</c> BBCode tag.
/// The <c>[SHADOW]</c> BBCode tag accepts one optional parameter, that can be
/// one of the values listed in the following table:
/// <list type="table">
///   <listheader>
///     <term>Value</term>
///     <description>Description</description>
///   </listheader>
///   <item>
///     <term>On | Yes</term>
///     <description>Displays characters as shadowed characters (default)</description>
///   </item>
///   <item>
///     <term>Off | No</term>
///     <description>Removes the shadow attribute of the characters</description>
///   </item>
/// </list>
/// </remarks>
{$Endregion}

  TBBCodeShadow = Class(TSwitchableBBCode)
   Protected
    Class Function GetTagName : String; Override;
    Procedure Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2); Override;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class controls the emboss attribute of characters in a Rich Edit control.
/// </summary>
/// <remarks>
/// TBBCodeEmboss class represents the <c>[EMBOSS]</c> BBCode tag.
/// The <c>[EMBOSS]</c> BBCode tag accepts one optional parameter, that can be
/// one of the values listed in the following table:
/// <list type="table">
///   <listheader>
///     <term>Value</term>
///     <description>Description</description>
///   </listheader>
///   <item>
///     <term>On | Yes</term>
///     <description>Displays characters as embossed characters (default)</description>
///   </item>
///   <item>
///     <term>Off | No</term>
///     <description>Removes the emboss attribute of the characters</description>
///   </item>
/// </list>
/// </remarks>
{$Endregion}

  TBBCodeEmboss = Class(TSwitchableBBCode)
   Protected
    Class Function GetTagName : String; Override;
    Procedure Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2); Override;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class controls the imprint attribute of characters in a Rich Edit control.
/// </summary>
/// <remarks>
/// TBBCodeImprint class represents the <c>[IMPRINT]</c> BBCode tag.
/// The <c>[IMPRINT]</c> BBCode tag accepts one optional parameter, that can be
/// one of the values listed in the following table:
/// <list type="table">
///   <listheader>
///     <term>Value</term>
///     <description>Description</description>
///   </listheader>
///   <item>
///     <term>On | Yes</term>
///     <description>Displays characters as imprinted characters (default)</description>
///   </item>
///   <item>
///     <term>Off | No</term>
///     <description>Removes the imprint attribute of the characters</description>
///   </item>
/// </list>
/// </remarks>
{$Endregion}

  TBBCodeImprint = Class(TSwitchableBBCode)
   Protected
    Class Function GetTagName : String; Override;
    Procedure Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2); Override;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class controls the small caps attribute of characters in a Rich Edit control.
/// </summary>
/// <remarks>
/// TBBCodeSmallCaps class represents the <c>[SMALLCAPS]</c> BBCode tag.
/// The <c>[SMALLCAPS]</c> BBCode tag accepts one optional parameter, that can be
/// one of the values listed in the following table:
/// <list type="table">
///   <listheader>
///     <term>Value</term>
///     <description>Description</description>
///   </listheader>
///   <item>
///     <term>On | Yes</term>
///     <description>Displays characters in small capital letters (default)</description>
///   </item>
///   <item>
///     <term>Off | No</term>
///     <description>Removes the small caps attribute of the characters</description>
///   </item>
/// </list>
/// </remarks>
{$Endregion}

  TBBCodeSmallCaps = Class(TSwitchableBBCode)
   Protected
    Class Function GetTagName : String; Override;
    Procedure Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2); Override;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class controls the all caps attribute of characters in a Rich Edit control.
/// </summary>
/// <remarks>
/// TBBCodeAllCaps class represents the <c>[ALLCAPS]</c> BBCode tag.
/// The <c>[ALLCAPS]</c> BBCode tag accepts one optional parameter, that can be
/// one of the values listed in the following table:
/// <list type="table">
///   <listheader>
///     <term>Value</term>
///     <description>Description</description>
///   </listheader>
///   <item>
///     <term>On | Yes</term>
///     <description>Displays characters all in capital letters (default)</description>
///   </item>
///   <item>
///     <term>Off | No</term>
///     <description>Removes the all caps attribute of the characters</description>
///   </item>
/// </list>
/// </remarks>
{$Endregion}

  TBBCodeAllCaps = Class(TSwitchableBBCode)
   Protected
    Class Function GetTagName : String; Override;
    Procedure Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2); Override;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class controls the revised attribute of characters in a Rich Edit control.
/// </summary>
/// <remarks>
/// TBBCodeRevised class represents the <c>[REVISED]</c> BBCode tag.
/// The <c>[REVISED]</c> BBCode tag accepts one optional parameter, that can be
/// one of the values listed in the following table:
/// <list type="table">
///   <listheader>
///     <term>Value</term>
///     <description>Description</description>
///   </listheader>
///   <item>
///     <term>On | Yes</term>
///     <description>Marks up the text as revised (default)</description>
///   </item>
///   <item>
///     <term>Off | No</term>
///     <description>Removes the revised attribute of the characters</description>
///   </item>
/// </list>
/// </remarks>
/// <seealso cref="TBBCodeRevAuthor"/>
{$Endregion}

  TBBCodeRevised = Class(TSwitchableBBCode)
   Protected
    Class Function GetTagName : String; Override;
    Procedure Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2); Override;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class controls the revision author attribute of characters in a Rich Edit control.
/// </summary>
/// <remarks>
/// TBBCodeRevAuthor class represents the <c>[AUTHOR]</c> BBCode tag.
/// The <c>[AUTHOR]</c> BBCode tag has one required parameter, which is an index that
/// identifies the author making a revision. The Rich Edit control uses different text
/// colors for each different author index. The index can be a value between 0 and 255.
/// </remarks>
/// <seealso cref="TBBCodeRevised"/>
{$Endregion}

  TBBCodeRevAuthor = Class(TBBCode)
   Private
    Function GetAuthor : Byte;
    Procedure SetAuthor(Value : Byte);
   Protected
    Class Function GetTagName : String; Override;
    Procedure Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2); Override;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the index that identifies the author making a revision.
    /// </summary>
    {$Endregion}
    Property Author : Byte Read GetAuthor Write SetAuthor;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class sets the font of characters in a Rich Edit control to a monospace font.
/// </summary>
/// <remarks>
/// TBBCodeCode class represents the <c>[CODE]</c> BBCode tag.
/// The <c>[CODE]</c> BBCode tag has no parameter. Characters marked with this tag will
/// be displayed using monospace font.
/// </remarks>
/// <seealso cref="TBBCodeFontFace"/>
{$Endregion}

  TBBCodeCode = Class(TBBCode)
   Protected
    Class Function GetTagName : String; Override;
    Procedure Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2); Override;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class centers paragraphs in a Rich Edit control.
/// </summary>
/// <remarks>
/// TBBCodeCenter class represents the <c>[CENTER]</c> BBCode tag.
/// The <c>[CENTER]</c> BBCode tag has no parameter. Paragraphs marked with this tag will
/// be centered.
/// </remarks>
/// <seealso cref="TBBCodeAlign"/>
{$Endregion}

  TBBCodeCenter = Class(TBBCode)
   Protected
    Class Function GetTagName : String; Override;
    Procedure Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2); Override;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class controls the alignment of paragraphs in a Rich Edit control.
/// </summary>
/// <remarks>
/// TBBCodeAlign class represents the <c>[ALIGN]</c> BBCode tag.
/// The <c>[ALIGN]</c> BBCode tag has one required parameter, that can be
/// one of the values listed in the following table:
/// <list type="table">
///   <listheader>
///     <term>Value</term>
///     <description>Description</description>
///   </listheader>
///   <item>
///     <term>Left</term>
///     <description>Paragraphs are aligned with the left margin</description>
///   </item>
///   <item>
///     <term>Right</term>
///     <description>Paragraphs are aligned with the right margin</description>
///   </item>
///   <item>
///     <term>Center</term>
///     <description>Paragraphs are centered</description>
///   </item>
///   <item>
///     <term>Justify</term>
///     <description>Paragraphs are justified (some versions of Rich Edit control support this value)</description>
///   </item>
///   <item>
///     <term>FullInterWord</term>
///     <description>Paragraphs are justified by expanding the blanks alone</description>
///   </item>
/// </list>
/// </remarks>
/// <seealso cref="TBBCodeCenter"/>
{$Endregion}

  TBBCodeAlign = Class(TBBCode)
   Public
    Type
    {$Region 'xmldoc'}
    /// <summary>
    /// This enumeration type identifies the alignments of text for paragraphs.
    /// </summary>
    {$Endregion}
    TParaAlign = (
    {$Region 'xmldoc'}
    /// Left aligned text
    {$Endregion}
    paLeft,
    {$Region 'xmldoc'}
    /// Right aligned text
    {$Endregion}
    paRight,
    {$Region 'xmldoc'}
    /// Centered text
    {$Endregion}
    paCenter,
    {$Region 'xmldoc'}
    /// Justified text
    {$Endregion}
    paJustify,
    {$Region 'xmldoc'}
    /// Justified text by expanding the blanks alone
    {$Endregion}
    paFullInterWord
    );
   Private
    Function GetAlignment : TParaAlign;
    Procedure SetAlignment(Value : TParaAlign);
   Protected
    Class Function GetTagName : String; Override;
    Procedure Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2); Override;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the alignment for the paragraphs.
    /// </summary>
    {$Endregion}
    Property Alignment : TParaAlign Read GetAlignment Write SetAlignment;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class controls the line spacing of paragraphs in a Rich Edit control.
/// </summary>
/// <remarks>
/// TBBCodeLineSpacing class represents the <c>[LS]</c> BBCode tag.
/// The <c>[LS]</c> BBCode tag has one required parameter, that can be
/// one of the values listed in the following table:
/// <list type="table">
///   <listheader>
///     <term>Value</term>
///     <description>Description</description>
///   </listheader>
///   <item>
///     <term>1</term>
///     <description>Single spacing</description>
///   </item>
///   <item>
///     <term>1.5</term>
///     <description>One-and-a-half spacing</description>
///   </item>
///   <item>
///     <term>2</term>
///     <description>Double spacing</description>
///   </item>
/// </list>
/// </remarks>
{$Endregion}

  TBBCodeLineSpacing = Class(TBBCode)
   Public
    Type
    {$Region 'xmldoc'}
    /// <summary>
    /// This enumeration type identifies the types of line spacing for paragraphs.
    /// </summary>
    {$Endregion}
    TLineSpacing = (
    {$Region 'xmldoc'}
    /// Single spacing
    {$Endregion}
    lsSingle,
    {$Region 'xmldoc'}
    /// One-and-a-half spacing
    {$Endregion}
    lsOneAndHalf,
    {$Region 'xmldoc'}
    /// Double spacing
    {$Endregion}
    lsDouble
    );
   Private
    Function GetSpacing : TLineSpacing;
    Procedure SetSpacing(Value : TLineSpacing);
   Protected
    Class Function GetTagName : String; Override;
    Procedure Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2); Override;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the line spacing for the paragraphs.
    /// </summary>
    {$Endregion}
    Property Spacing : TLineSpacing Read GetSpacing Write SetSpacing;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class controls the amount of spacing before paragraphs in a Rich Edit control.
/// </summary>
/// <remarks>
/// TBBCodeParagraphSpaceBefore class represents the <c>[PSB]</c> BBCode tag.
/// The <c>[PSB]</c> BBCode tag has one required parameter, which is an integer value
/// that represents the amount of spacing before paragraphs, in points.
/// </remarks>
/// <seealso cref="TBBCodeParagraphSpaceAfter"/>
{$Endregion}

  TBBCodeParagraphSpaceBefore = Class(TBBCode)
   Private
    Function GetSpacing : Integer;
    Procedure SetSpacing(Value : Integer);
   Protected
    Class Function GetTagName : String; Override;
    Procedure Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2); Override;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the amount of spacing, in points.
    /// </summary>
    {$Endregion}
    Property Spacing : Integer Read GetSpacing Write SetSpacing;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class controls the amount of spacing after paragraphs in a Rich Edit control.
/// </summary>
/// <remarks>
/// TBBCodeParagraphSpaceAfter class represents the <c>[PSA]</c> BBCode tag.
/// The <c>[PSA]</c> BBCode tag has one required parameter, which is an integer value
/// that represents the amount of spacing after paragraphs, in points.
/// </remarks>
/// <seealso cref="TBBCodeParagraphSpaceBefore"/>
{$Endregion}

  TBBCodeParagraphSpaceAfter = Class(TBBCode)
   Private
    Function GetSpacing : Integer;
    Procedure SetSpacing(Value : Integer);
   Protected
    Class Function GetTagName : String; Override;
    Procedure Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2); Override;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the amount of spacing, in points.
    /// </summary>
    {$Endregion}
    Property Spacing : Integer Read GetSpacing Write SetSpacing;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class controls the amount of indent for paragraphs in a Rich Edit control.
/// </summary>
/// <remarks>
/// TBBCodeIndent class represents the <c>[INDENT]</c> BBCode tag.
/// The <c>[INDENT]</c> BBCode tag has one required parameter, which is an integer value
/// that represents the amount of indent, in points.
/// </remarks>
/// <seealso cref="TBBCodeRightIndent"/>
{$Endregion}

  TBBCodeIndent = Class(TBBCode)
   Private
    Function GetIndent : Integer;
    Procedure SetIndent(Value : Integer);
   Protected
    Class Function GetTagName : String; Override;
    Procedure Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2); Override;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the amount of indent, in points.
    /// </summary>
    {$Endregion}
    Property Indent : Integer Read GetIndent Write SetIndent;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class controls the amount of right indent for paragraphs in a Rich Edit control.
/// </summary>
/// <remarks>
/// TBBCodeRightIndent class represents the <c>[RINDENT]</c> BBCode tag.
/// The <c>[RINDENT]</c> BBCode tag has one required parameter, which is an integer value
/// that represents the amount of right indent, in points.
/// </remarks>
/// <seealso cref="TBBCodeIndent"/>
{$Endregion}

  TBBCodeRightIndent = Class(TBBCode)
   Private
    Function GetIndent : Integer;
    Procedure SetIndent(Value : Integer);
   Protected
    Class Function GetTagName : String; Override;
    Procedure Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2); Override;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the amount of indent, in points.
    /// </summary>
    {$Endregion}
    Property Indent : Integer Read GetIndent Write SetIndent;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class controls the text direction of paragraphs in a Rich Edit control.
/// </summary>
/// <remarks>
/// TBBCodeDir class represents the <c>[DIR]</c> BBCode tag.
/// The <c>[DIR]</c> BBCode tag has one required parameter, that can be one
/// of the values listed in the following table:
/// <list type="table">
///   <listheader>
///     <term>Value</term>
///     <description>Description</description>
///   </listheader>
///   <item>
///     <term>LTR</term>
///     <description>Displays text in left-to-right direction</description>
///   </item>
///   <item>
///     <term>RTL</term>
///     <description>Displays text in right-to-left direction</description>
///   </item>
/// </list>
/// </remarks>
{$Endregion}

  TBBCodeDir = Class(TBBCode)
   Public
    Type
    {$Region 'xmldoc'}
    /// <summary>
    /// The TTextDirection determines the direction of text for bi-directional languages.
    /// </summary>
    {$Endregion}
    TTextDirection = (
    {$Region 'xmldoc'}
    /// Left-To-Right direction
    {$Endregion}
    LTR,
    {$Region 'xmldoc'}
    /// Right-To-Left direction
    {$Endregion}
    RTL
    );
   Private
    Function GetDirection : TTextDirection;
    Procedure SetDirection(Value : TTextDirection);
   Protected
    Class Function GetTagName : String; Override;
    Procedure Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2); Override;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the direction of text.
    /// </summary>
    {$Endregion}
    Property Direction : TTextDirection Read GetDirection Write SetDirection;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class controls bulleted or numbered paragraphs in a Rich Edit control.
/// </summary>
/// <remarks>
/// TBBCodeList class represents the <c>[LIST]</c> BBCode tag.
/// The <c>[LIST]</c> BBCode tag accepts four optional parameters: <c>type</c>,
/// <c>start</c>, <c>style</c>, and <c>tab</c>. The parameters are separated by
/// comma and their order of appearance in the parameter list is not important.
/// The <c>type</c> parameter specifies whether the list is bulleted or numbered. And,
/// if the list is numbered, which numbering type is used. The <c>type</c> parameter
/// can have one of the following values:
/// <list type="table">
///   <listheader>
///     <term>Value</term>
///     <description>Description</description>
///   </listheader>
///   <item>
///     <term>None</term>
///     <description>No paragraph numbering or bullets</description>
///   </item>
///   <item>
///     <term>Bullet</term>
///     <description>Uses bullets (default)</description>
///   </item>
///   <item>
///     <term>Number</term>
///     <description>Uses Arabic numbers (1, 2, 3, ...)</description>
///   </item>
///   <item>
///     <term>LowerLetter</term>
///     <description>Uses lowercase letters (a, b, c, ...)</description>
///   </item>
///   <item>
///     <term>UpperLetter</term>
///     <description>Uses uppercase letters (A, B, C, ...)</description>
///   </item>
///   <item>
///     <term>LowerRoman</term>
///     <description>Uses lowercase Roman numerals (i, ii, iii, ...)</description>
///   </item>
///   <item>
///     <term>UpperRoman</term>
///     <description>Uses uppercase Roman numerals (I, II, III, ...)</description>
///   </item>
///   <item>
///     <term>Custom</term>
///     <description>Uses a sequence of characters beginning with the specified Unicode character</description>
///   </item>
/// </list>
/// The <c>start</c> parameter specifies the first number for numbering the list. If
/// the <c>type</c> parameter is custom, the <c>start</c> parameter indicates the
/// Unicode character that is the first character in the sequence of characters for
/// numbering. If the <c>type</c> parameter is omitted, the <c>start</c> parameter
/// can be any character to represent both numbering type and start.
/// The <c>style</c> parameter specifies the style of numbering lists, and can have
/// one of the following values:
/// <list type="table">
///   <listheader>
///     <term>Value</term>
///     <description>Description</description>
///   </listheader>
///   <item>
///     <term>Parenthesis</term>
///     <description>Follows the number with a period (default).</description>
///   </item>
///   <item>
///     <term>Enclosed</term>
///     <description>Encloses the number in parentheses.</description>
///   </item>
///   <item>
///     <term>Period</term>
///     <description>Follows the number with a period.</description>
///   </item>
///   <item>
///     <term>Simple</term>
///     <description>Displays only the number.</description>
///   </item>
/// </list>
/// The <c>tab</c> parameter is an integer value followed by an at sign (@) to specify
/// the minimum space between a paragraph bullet or number and the paragraph text, in
/// points.
/// Note: Some numbering types may have no effect on some versions of Rich Edit control.
/// </remarks>
{$Endregion}

  TBBCodeList = Class(TBBCode)
   Public
    Type
    {$Region 'xmldoc'}
    /// <summary>
    /// This enumeration type identifies the types of numbering for a list.
    /// </summary>
    {$Endregion}
    TListNumbering = (
    {$Region 'xmldoc'}
    /// No paragraph numbering or bullets
    {$Endregion}
    lnNone,
    {$Region 'xmldoc'}
    /// Uses bullets
    {$Endregion}
    lnBullet,
    {$Region 'xmldoc'}
    /// Uses Arabic numbers (1, 2, 3, ...)
    {$Endregion}
    lnNumber,
    {$Region 'xmldoc'}
    /// Uses lowercase letters (a, b, c, ...)
    {$Endregion}
    lnLowerLetter,
    {$Region 'xmldoc'}
    /// Uses uppercase letters (A, B, C, ...)
    {$Endregion}
    lnUpperLetter,
    {$Region 'xmldoc'}
    /// Uses lowercase Roman numerals (i, ii, iii, ...)
    {$Endregion}
    lnLowerRoman,
    {$Region 'xmldoc'}
    /// Uses uppercase Roman numerals (I, II, III, ...)
    {$Endregion}
    lnUpperRoman,
    {$Region 'xmldoc'}
    /// Uses a sequence of characters beginning with the specified Unicode character
    {$Endregion}
    lnCustom
    );
    {$Region 'xmldoc'}
    /// <summary>
    /// This enumeration type identifies the styles of numbering for a list.
    /// </summary>
    {$Endregion}
    TListNumberingStyle = (
    {$Region 'xmldoc'}
    /// Follows the number with a right parenthesis
    {$Endregion}
    nsParenthesis,
    {$Region 'xmldoc'}
    /// Encloses the number in parentheses
    {$Endregion}
    nsEnclosed,
    {$Region 'xmldoc'}
    /// Follows the number with a period
    {$Endregion}
    nsPeriod,
    {$Region 'xmldoc'}
    /// Displays only the number
    {$Endregion}
    nsSimple
    );
   Private
    Function GetNumbering : TListNumbering;
    Procedure SetNumbering(Value : TListNumbering);
    Function GetStyle : TListNumberingStyle;
    Procedure SetStyle(Value : TListNumberingStyle);
    Function GetStart : Word;
    Procedure SetStart(Value : Word);
    Function GetTab : Integer;
    Procedure SetTab(Value : Integer);
    Procedure DecodeAttribute(Out TheNumbering : TListNumbering; Out TheStart : Word; Out TheStyle : TListNumberingStyle; Out TheTab : Integer);
    Procedure EncodeAttribute(TheNumbering : TListNumbering; TheStart : Word; TheStyle : TListNumberingStyle; TheTab : Integer);
   Protected
    Class Function GetTagName : String; Override;
    Procedure Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2); Override;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the list is bulleted or numbered, and which numbering type is used.
    /// </summary>
    {$Endregion}
    Property Numbering : TListNumbering Read GetNumbering Write SetNumbering;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the style of the numbering.
    /// </summary>
    {$Endregion}
    Property Style : TListNumberingStyle Read GetStyle Write SetStyle;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the starting number or Unicode value used for the numbering.
    /// </summary>
    {$Endregion}
    Property Start : Word Read GetStart Write SetStart;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the minimum space between a paragraph number and the paragraph text, in points.
    /// </summary>
    {$Endregion}
    Property Tab : Integer Read GetTab Write SetTab;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This class controls the tab stops in a Rich Edit control.
/// </summary>
/// <remarks>
/// TBBCodeTabs class represents the <c>[TABS]</c> BBCode tag.
/// The <c>[TABS]</c> BBCode tag needs one or more integer values as the parameter,
/// separated by comma. Each value specifies the absolute tab stop, in points.
/// </remarks>
{$Endregion}

  TBBCodeTabs = Class(TBBCode)
   Private
    Function GetTabStops : String;
    Procedure SetTabStops(Const Value : String);
   Protected
    Class Function GetTagName : String; Override;
    Procedure Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2); Override;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the comma separated list of tab stops, in points.
    /// </summary>
    {$Endregion}
    Property TabStops : String Read GetTabStops Write SetTabStops;
  End;

{$Region 'xmldoc'}
/// <summary>
/// BBCodes class provides some class methods to set content of the Rich Edit
/// controls using BBCode formatted text.
/// </summary>
/// <remarks>
/// Use methods of the BBCodes class to display BBCode formatted text on the Rich
/// Edit control.
/// <para>
/// The following table lists the recognized BBCode tags. Case is ignored in tags.
/// To know about the attributes of each tag, please refer to the documentation
/// of its class.
/// </para>
/// <list type="table">
///   <listheader>
///     <term>BBCode Tag</term>
///     <description>Class</description>
///     <description>Description</description>
///   </listheader>
///   <item>
///     <term>B</term>
///     <description><see cref="TBBCodeBold"/></description>
///     <description>Displays text as bold.</description>
///   </item>
///   <item>
///     <term>I</term>
///     <description><see cref="TBBCodeItalic"/></description>
///     <description>Displays the text as italic.</description>
///   </item>
///   <item>
///     <term>U</term>
///     <description><see cref="TBBCodeUnderline"/></description>
///     <description>Displays the text with underline.</description>
///   </item>
///   <item>
///     <term>Strikeout</term>
///     <description><see cref="TBBCodeStrikeout"/></description>
///     <description>Displays the text with a line straight through the middle.</description>
///   </item>
///   <item>
///     <term>FONT</term>
///     <description><see cref="TBBCodeFontFace"/></description>
///     <description>Determines the name of the font to use for displaying the text.</description>
///   </item>
///   <item>
///     <term>SIZE</term>
///     <description><see cref="TBBCodeFontSize"/></description>
///     <description>Determines the size of the font to use for displaying the text.</description>
///   </item>
///   <item>
///     <term>COLOR</term>
///     <description><see cref="TBBCodeFontColor"/></description>
///     <description>Determines the color of the font to use for displaying the text.</description>
///   </item>
///   <item>
///     <term>BACKCOLOR</term>
///     <description><see cref="TBBCodeBackColor"/></description>
///     <description>Determines the background color to use for displaying the text.</description>
///   </item>
///   <item>
///     <term>LINK</term>
///     <description><see cref="TBBCodeLink"/></description>
///     <description>Marks up the text as a link.</description>
///   </item>
///   <item>
///     <term>SUB</term>
///     <description><see cref="TBBCodeSubscript"/></description>
///     <description>Displays the text as subscript.</description>
///   </item>
///   <item>
///     <term>SUP</term>
///     <description><see cref="TBBCodeSuperscript"/></description>
///     <description>Displays the text as superscript.</description>
///   </item>
///   <item>
///     <term>DISABLED</term>
///     <description><see cref="TBBCodeDisabled"/></description>
///     <description>Displays the text as disabled.</description>
///   </item>
///   <item>
///     <term>PROTECTED</term>
///     <description><see cref="TBBCodeProtected"/></description>
///     <description>Prevents modification of the text.</description>
///   </item>
///   <item>
///     <term>HIDDEN</term>
///     <description><see cref="TBBCodeHidden"/></description>
///     <description>Does not display the text.</description>
///   </item>
///   <item>
///     <term>OUTLINE</term>
///     <description><see cref="TBBCodeOutline"/></description>
///     <description>Displays the text with outlined characters.</description>
///   </item>
///   <item>
///     <term>SHADOW</term>
///     <description><see cref="TBBCodeShadow"/></description>
///     <description>Displays the text as shadowed.</description>
///   </item>
///   <item>
///     <term>EMBOSS</term>
///     <description><see cref="TBBCodeEmboss"/></description>
///     <description>Displays the text as embossed.</description>
///   </item>
///   <item>
///     <term>IMPRINT</term>
///     <description><see cref="TBBCodeImprint"/></description>
///     <description>Displays the text as imprinted.</description>
///   </item>
///   <item>
///     <term>SMALLCAPS</term>
///     <description><see cref="TBBCodeSmallCaps"/></description>
///     <description>Displays the text in small capital letters.</description>
///   </item>
///   <item>
///     <term>REVISED</term>
///     <description><see cref="TBBCodeRevised"/></description>
///     <description>Marks up the text as revised.</description>
///   </item>
///   <item>
///     <term>AUTHOR</term>
///     <description><see cref="TBBCodeRevAuthor"/></description>
///     <description>Uses different text colors for each different author.</description>
///   </item>
///   <item>
///     <term>CODE</term>
///     <description><see cref="TBBCodeCode"/></description>
///     <description>Displays the text using monospace font.</description>
///   </item>
///   <item>
///     <term>CENTER</term>
///     <description><see cref="TBBCodeCenter"/></description>
///     <description>Centers the paragraphs.</description>
///   </item>
///   <item>
///     <term>ALIGN</term>
///     <description><see cref="TBBCodeAlign"/></description>
///     <description>Determines alignment of the paragraphs.</description>
///   </item>
///   <item>
///     <term>LS</term>
///     <description><see cref="TBBCodeLineSpacing"/></description>
///     <description>Determines spacing between lines of the paragraphs.</description>
///   </item>
///   <item>
///     <term>PSB</term>
///     <description><see cref="TBBCodeParagraphSpaceBefore"/></description>
///     <description>Determines the amount of spacing before the paragraphs.</description>
///   </item>
///   <item>
///     <term>PSA</term>
///     <description><see cref="TBBCodeParagraphSpaceAfter"/></description>
///     <description>Determines the amount of spacing after the paragraphs.</description>
///   </item>
///   <item>
///     <term>INDENT</term>
///     <description><see cref="TBBCodeIndent"/></description>
///     <description>Determines the amount of left indent for the paragraphs.</description>
///   </item>
///   <item>
///     <term>RINDENT</term>
///     <description><see cref="TBBCodeRightIndent"/></description>
///     <description>Determines the amount of right indent for the paragraphs.</description>
///   </item>
///   <item>
///     <term>DIR</term>
///     <description><see cref="TBBCodeDir"/></description>
///     <description>Displays the paragraphs in either right-to-left or left-to-right direction.</description>
///   </item>
///   <item>
///     <term>LIST</term>
///     <description><see cref="TBBCodeList"/></description>
///     <description>Displays the paragraphs as bulleted or numbered list.</description>
///   </item>
///   <item>
///     <term>TABS</term>
///     <description><see cref="TBBCodeTabs"/></description>
///     <description>Specifies the absolute tab stops.</description>
///   </item>
/// </list>
/// </remarks>
{$Endregion}

  BBCodes = Class
   Private
    Class Var BBCodeClasses : TStringList;
    Class Procedure Cleanup; Static;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts the string representation of a color to a color value. The string
    /// representation of the color can be expressed by name (e.g. Red), web format
    /// (e.g. #F00 or #FF0000), or hexadecimal value (e.g. $000000FF).
    /// </summary>
    /// <param name="Str">
    /// The string representation of the color.
    /// </param>
    /// <param name="DefColor">
    /// The default color if the conversion failed.
    /// </param>
    /// <returns>
    /// Returns the corresponding color value of the color string, or <paramref name="DefColor"/>
    /// if the string does not represent a color.
    /// </returns>
    {$Endregion}
    Class Function StrToColor(Const Str : String; DefColor : TColor) : TColor; Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts a color value to its string representation.
    /// </summary>
    /// <param name="Color">
    /// The color to be converted.
    /// </param>
    /// <returns>
    /// The string representation of the color.
    /// </returns>
    {$Endregion}
    Class Function ColorToStr(Color : TColor) : String; Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts a Roman numeral to an integer value.
    /// </summary>
    /// <param name="Roman">
    /// Roman numeral as a string.
    /// </param>
    /// <returns>
    /// The integer value of the Roman numeral, or zero if the conversion failed.
    /// </returns>
    /// <seealso cref="NumberToRoman"/>
    {$Endregion}
    Class Function RomanToNumber(Const Roman : String) : Integer; Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts an integer value to a Roman numeral.
    /// </summary>
    /// <param name="Number">
    /// The integer value to convert.
    /// </param>
    /// <returns>
    /// The Roman numeral as a string.
    /// </returns>
    /// <seealso cref="RomanToNumber"/>
    {$Endregion}
    Class Function NumberToRoman(Number : Integer) : String; Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts a sequence of letters to an integer value. For example, 'A' represents 1,
    /// 'Z' represents 26, and 'AA' represents 27.
    /// </summary>
    /// <param name="Letter">
    /// The sequence of letters.
    /// </param>
    /// <returns>
    /// The integer value of the sequence of letters, or zero if the conversion failed.
    /// </returns>
    /// <seealso cref="NumberToLetter"/>
    {$Endregion}
    Class Function LetterToNumber(Const Letter : String) : Integer; Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts an integer value to a sequence of letters. For example, 1 represents 'A',
    /// 26 represents 'Z', and 27 represents 'AA'.
    /// </summary>
    /// <param name="Number">
    /// The integer value to convert.
    /// </param>
    /// <returns>
    /// The sequence of letters corresponding to the integer value.
    /// </returns>
    /// <seealso cref="LetterToNumber"/>
    {$Endregion}
    Class Function NumberToLetter(Number : Integer) : String; Static;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Registers a BBCode class for subsequent use in calls to <see cref="FindBBCodeClass"/>,
    /// <see cref="ParseBBCode"/> and <see cref="ApplyBBCode"/> functions.
    /// </summary>
    /// <param name="BBCodeClass">
    /// The class to register.
    /// </param>
    /// <seealso cref="Unregister"/>
    /// <seealso cref="Find"/>
    /// <seealso cref="Parse"/>
    /// <seealso cref="Apply"/>
    {$Endregion}
    Class Procedure Register(BBCodeClass : TBBCodeClass); Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Unregisters a BBCode class.
    /// </summary>
    /// <param name="BBCodeClass">
    /// The class to unregister.
    /// </param>
    /// <seealso cref="Register"/>
    {$Endregion}
    Class Procedure Unregister(BBCodeClass : TBBCodeClass); Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Determines whether a BBCode class is registered or not.
    /// </summary>
    /// <param name="BBCodeClass">
    /// The class to examine.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the class is registered, otherwise returns
    /// <see langword="false"/>.
    /// </returns>
    /// <seealso cref="Register"/>
    {$Endregion}
    Class Function IsRegistered(BBCodeClass : TBBCodeClass) : Boolean; Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Searches in the registered BBCode classes to find a class with the specified
    /// tag name. The search is case-insensitive.
    /// </summary>
    /// <param name="TagName">
    /// BBCode tag name to search.
    /// </param>
    /// <returns>
    /// The BBCode class with the specified tag name, or <see langword="nil"/>
    /// if the tag name could not be found.
    /// </returns>
    /// <seealso cref="Register"/>
    {$Endregion}
    Class Function Find(Const TagName : String) : TBBCodeClass; Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Parses a BBCode formatted text to extract the plain text and BBCode objects
    /// used for formatting the text. The BBCode tags without any registered
    /// BBCode class will be ignored.
    /// </summary>
    /// <param name="BBCodeText">
    /// The BBCode formatted text.
    /// </param>
    /// <param name="PlainText">
    /// Plain text extracted from the BBCode formatted text.
    /// </param>
    /// <param name="BBCodes">
    /// List of BBCode objects extracted from the BBCode formatted text.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the function is succeeded, otherwise returns
    /// <see langword="false"/>.
    /// </returns>
    /// <seealso cref="Register"/>
    {$Endregion}
    Class Function Parse(Const BBCodeText : String; Out PlainText : String; BBCodes : TBBCodeObjectList) : Boolean; Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Sets content of a Rich Edit control using a BBCode formatted text.
    /// </summary>
    /// <param name="hRichEdit">
    /// Window handle of the target Rich Edit control.
    /// </param>
    /// <param name="BBCodeText">
    /// BBCode formatted text.
    /// </param>
    /// <param name="Append">
    /// Determines whether the new text should be appended to the old content of the Rich Edit control or replace it.
    /// </param>
    {$Endregion}
    Class Procedure Apply(hRichEdit : THandle; Const BBCodeText : String; Append : Boolean = False); Overload; Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Sets content of a Rich Edit control using a BBCode formatted text.
    /// </summary>
    /// <param name="RichEdit">
    /// Target Rich Edit control
    /// </param>
    /// <param name="BBCodeText">
    /// BBCode formatted text.
    /// </param>
    /// <param name="Append">
    /// Determines whether the new text should be appended to the old content of the Rich Edit control or replace it.
    /// </param>
    {$Endregion}
    Class Procedure Apply(RichEdit : TCustomRichEdit; Const BBCodeText : String; Append : Boolean = False); Overload; Static;
  End;

Implementation

{ TBBCode }

 Function TBBCode.RealCharPos(hRichEdit : THandle; CharPos : Integer) : Integer;
  Var
   FindText      : TFindText;
   NumLineBreaks : Integer;
   LineIndex     : Integer;
   LineCount     : Integer;
   LineStart     : Integer;
   LineLength    : Integer;
   CharCount     : Integer;
  Begin
   Result              := CharPos;
   FindText.chrg.cpMin := 0;
   FindText.chrg.cpMax := -1;
   FindText.lpstrText  := #13#10;
   If SendMessage(hRichEdit, EM_FINDTEXT, 0, LPARAM(@FindText)) = -1 Then
    Begin
     CharCount     := 0;
     NumLineBreaks := 0;
     LineCount     := SendMessage(hRichEdit, EM_GETLINECOUNT, 0, 0);
     For LineIndex := 0 To LineCount - 1 Do
      Begin
       LineStart := SendMessageW(hRichEdit, EM_LINEINDEX, LineIndex, 0);
       If CharPos < (LineStart + NumLineBreaks) Then
        Break;
       If LineStart > CharCount Then
        Begin
         Inc(NumLineBreaks);
         Inc(CharCount);
        End;
       LineLength := SendMessageW(hRichEdit, EM_LINELENGTH, LineStart, 0);
       Inc(CharCount, LineLength);
       If (CharPos >= (LineStart + NumLineBreaks)) And
       (CharPos < (LineStart + LineLength + NumLineBreaks))
       Then
        Break;
      End;
     Dec(Result, NumLineBreaks); {deflate CR/LF -> CR}
    End;
  End;

 Procedure TBBCode.SelectRange(hRichEdit : THandle; ASelStart, ASelEnd : Integer);
  Var
   Range : TCharRange;
  Begin
   Range.cpMin := RealCharPos(hRichEdit, ASelStart);
   Range.cpMax := RealCharPos(hRichEdit, ASelEnd);
   SendMessage(hRichEdit, EM_EXSETSEL, 0, LPARAM(@Range));
  End;

 Procedure TBBCode.Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2);
  Begin
   FillChar(ParaFormat, SizeOf(ParaFormat), 0);
   ParaFormat.cbSize := SizeOf(ParaFormat);
   FillChar(CharFormat, SizeOf(CharFormat), 0);
   CharFormat.cbSize := SizeOf(CharFormat);
  End;

 Procedure TBBCode.Apply(hRichEdit : THandle; ASelStart, ASelEnd : Integer);
  Var
   ParaFormat : TParaFormat2;
   CharFormat : TCharFormat2;
  Begin
   SelectRange(hRichEdit, ASelStart, ASelEnd);
   Prepare(ParaFormat, CharFormat);
   If ParaFormat.dwMask <> 0 Then
    SendMessage(hRichEdit, EM_SETPARAFORMAT, 0, LPARAM(@ParaFormat));
   If CharFormat.dwMask <> 0 Then
    SendMessage(hRichEdit, EM_SETCHARFORMAT, SCF_SELECTION, LPARAM(@CharFormat));
  End;

 Procedure TBBCode.Apply(hRichEdit : THandle; Offset : Integer);
  Begin
   Apply(hRichEdit, SelStart + Offset, SelEnd + Offset);
  End;

 Function TBBCode.Mark(hRichEdit : THandle; ASelStart, ASelEnd : Integer) : Integer;
  Var
   OpenTag, CloseTag : String;
  Begin
   If Attribute = '' Then
    OpenTag := '[' + TagName + ']'
   Else
    OpenTag := '[' + TagName + '=' + Attribute + ']';
   CloseTag := '[/' + TagName + ']';
   SelectRange(hRichEdit, ASelEnd, ASelEnd);
   SendMessage(hRichEdit, EM_REPLACESEL, 0, LPARAM(PChar(CloseTag)));
   SelectRange(hRichEdit, ASelStart, ASelStart);
   SendMessage(hRichEdit, EM_REPLACESEL, 0, LPARAM(PChar(OpenTag)));
   Result := Length(OpenTag);
  End;

 Function TBBCode.Mark(hRichEdit : THandle; Offset : Integer = 0) : Integer;
  Begin
   Result := Mark(hRichEdit, SelStart + Offset, SelEnd + Offset);
  End;

{ TBBCodeObjectList }

 Function TBBCodeObjectList.GetItems(Index : Integer) : TBBCode;
  Begin
   Result := TBBCode(Get(Index));
  End;

 Procedure TBBCodeObjectList.SetItems(Index : Integer; Value : TBBCode);
  Begin
   Put(Index, Value);
  End;

 Function TBBCodeObjectList.First : TBBCode;
  Begin
   Result := TBBCode(Inherited First);
  End;

 Function TBBCodeObjectList.Last : TBBCode;
  Begin
   Result := TBBCode(Inherited Last);
  End;

 Function TBBCodeObjectList.Add(Item : TBBCode) : Integer;
  Begin
   Result := Inherited Add(Item);
  End;

 Procedure TBBCodeObjectList.Insert(Index : Integer; Item : TBBCode);
  Begin
   Inherited Insert(Index, Item);
  End;

 Function TBBCodeObjectList.Remove(Item : TBBCode) : Integer;
  Begin
   Result := Inherited Remove(Item);
  End;

{$IFDEF COMPILER2010_UP}

 Function TBBCodeObjectList.RemoveItem(Item : TBBCode; Direction : TList.TDirection) : Integer;
  Begin
   Result := Inherited RemoveItem(Item, Direction);
  End;
{$ENDIF}

 Function TBBCodeObjectList.Extract(Item : TBBCode) : TBBCode;
  Begin
   Result := TBBCode(Inherited Extract(Item));
  End;

{$IFDEF COMPILER2010_UP}

 Function TBBCodeObjectList.ExtractItem(Item : TBBCode; Direction : TList.TDirection) : TBBCode;
  Begin
   Result := TBBCode(Inherited ExtractItem(Item, Direction));
  End;
{$ENDIF}

 Function TBBCodeObjectList.IndexOf(Item : TBBCode) : Integer;
  Begin
   Result := Inherited IndexOf(Item);
  End;

{$IFDEF COMPILER2010_UP}

 Function TBBCodeObjectList.IndexOfItem(Item : TBBCode; Direction : TList.TDirection) : Integer;
  Begin
   Result := Inherited IndexOfItem(Item, Direction);
  End;
{$ENDIF}

{ TSwitchableBBCode }

 Const
  SInactives : Array[1..2] Of String = ('Off', 'No');

 Function TSwitchableBBCode.GetActive : Boolean;
  Var
   i : Integer;
  Begin
   Result := True;
   For i  := Low(SInactives) To High(SInactives) Do
    If SameText(Attribute, SInactives[i]) Then
     Begin
      Result := False;
      Exit;
     End;
  End;

 Procedure TSwitchableBBCode.SetActive(Value : Boolean);
  Begin
   If Not Value Then
    Attribute := SInactives[1]
   Else
    Attribute := '';
  End;

{ TBBCodeBold }

  Class Function TBBCodeBold.GetTagName : String;

Begin
 Result := 'B';

End;

 Procedure TBBCodeBold.Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2);
  Begin
   Inherited Prepare(ParaFormat, CharFormat);
   With CharFormat Do
    Begin
     dwMask := dwMask Or CFM_BOLD;
     If Active Then
      dwEffects := dwEffects Or CFE_BOLD
     Else
      dwEffects := dwEffects And Not CFE_BOLD;
    End;
  End;

{ TBBCodeItalic }

  Class Function TBBCodeItalic.GetTagName : String;

Begin
 Result := 'I';

End;

 Procedure TBBCodeItalic.Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2);
  Begin
   Inherited Prepare(ParaFormat, CharFormat);
   With CharFormat Do
    Begin
     dwMask := dwMask Or CFM_ITALIC;
     If Active Then
      dwEffects := dwEffects Or CFE_ITALIC
     Else
      dwEffects := dwEffects And Not CFE_ITALIC;
    End;
  End;

{ TBBCodeUnderline }

  Class Function TBBCodeUnderline.GetTagName : String;

Begin
 Result := 'U';

End;

 Procedure TBBCodeUnderline.Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2);
  Begin
   Inherited Prepare(ParaFormat, CharFormat);
   With CharFormat Do
    Begin
     dwMask := dwMask Or CFM_UNDERLINE;
     If UnderlineType <> ulNone Then
      Begin
       dwEffects      := dwEffects Or CFE_UNDERLINE;
       dwMask         := dwMask Or CFM_UNDERLINETYPE;
       bUnderlineType := Ord(UnderlineType) Or (Ord(UnderlineColor) Shl 4);
      End
     Else
      dwEffects := dwEffects And Not CFE_UNDERLINE;
    End;
  End;

 Const
  SUnderlineType : Array[TBBCodeUnderline.TUnderlineType] Of String =
  ('None', 'Normal', 'Word', 'Double', 'Dotted', 'Dash',
  'DashDot', 'DashDotDot', 'Wave', 'Thick', 'HairLine',
  'DoubleWave', 'HeavyWave', 'LongDash');
  SUnderlineColor : Array[TBBCodeUnderline.TUnderlineColor] Of String =
  ('Auto', 'Blue', 'Aqua', 'Lime', 'Fuchsia', 'Red',
  'Yellow', 'White', 'Navy', 'Teal', 'Green', 'Purple',
  'Maroon', 'Olive', 'Gray', 'Silver');

 Function TBBCodeUnderline.GetUnderLineType : TUnderlineType;
  Var
   t            : TUnderlineType;
   Attr1, Attr2 : String;
   i            : Integer;
  Begin
   Result := ulNormal;
   i      := Pos(',', Attribute);
   If i <> 0 Then
    Begin
     Attr1 := Trim(Copy(Attribute, 1, i - 1));
     Attr2 := Trim(Copy(Attribute, i + 1, Length(Attribute) - i));
     If Attr1 = '' Then
      Attribute := Attr2
     Else If Attr2 = '' Then
      Attribute := Attr1
     Else
      Begin
       For t := Low(TUnderlineType) To High(TUnderlineType) Do
        If SameText(Attr1, SUnderlineType[t]) Or
        SameText(Attr2, SUnderlineType[t]) Then
         Begin
          Result := t;
          Exit;
         End;
       Exit;
      End
    End;
   If Attribute <> '' Then
    For t := Low(TUnderlineType) To High(TUnderlineType) Do
     If SameText(Attribute, SUnderlineType[t]) Then
      Begin
       Result := t;
       Exit;
      End;
  End;

 Procedure TBBCodeUnderline.SetUnderlineType(Value : TUnderlineType);
  Begin
   If UnderlineType <> Value Then
    Begin
     If UnderlineColor <> ucAuto Then
      Attribute := SUnderlineColor[UnderlineColor]
     Else
      Attribute := '';
     If Value <> ulNormal Then
      Begin
       If Attribute <> '' Then
        Attribute := ',' + Attribute;
       Attribute  := SUnderlineType[Value] + Attribute;
      End;
    End;
  End;

 Function TBBCodeUnderline.GetUnderLineColor : TUnderlineColor;
  Var
   c            : TUnderlineColor;
   Attr1, Attr2 : String;
   i            : Integer;
  Begin
   Result := ucAuto;
   i      := Pos(',', Attribute);
   If i <> 0 Then
    Begin
     Attr1 := Trim(Copy(Attribute, 1, i - 1));
     Attr2 := Trim(Copy(Attribute, i + 1, Length(Attribute) - i));
     If Attr1 = '' Then
      Attribute := Attr2
     Else If Attr2 = '' Then
      Attribute := Attr1
     Else
      Begin
       For c := Low(TUnderlineColor) To High(TUnderlineColor) Do
        If SameText(Attr1, SUnderlineColor[c]) Or
        SameText(Attr2, SUnderlineColor[c]) Then
         Begin
          Result := c;
          Exit;
         End;
       Exit;
      End
    End;
   If Attribute <> '' Then
    For c := Low(TUnderlineColor) To High(TUnderlineColor) Do
     If SameText(Attribute, SUnderlineColor[c]) Then
      Begin
       Result := c;
       Exit;
      End;
  End;

 Procedure TBBCodeUnderline.SetUnderlineColor(Value : TUnderlineColor);
  Begin
   If UnderlineColor <> Value Then
    Begin
     If UnderlineType <> ulNormal Then
      Attribute := SUnderlineType[UnderlineType]
     Else
      Attribute := '';
     If Value <> ucAuto Then
      Begin
       If Attribute <> '' Then
        Attribute := Attribute + ',';
       Attribute  := Attribute + SUnderlineColor[Value]
      End;
    End;
  End;

{ TBBCodeStrikeout }

  Class Function TBBCodeStrikeout.GetTagName : String;

Begin
 Result := 'S';

End;

 Procedure TBBCodeStrikeout.Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2);
  Begin
   Inherited Prepare(ParaFormat, CharFormat);
   With CharFormat Do
    Begin
     dwMask := dwMask Or CFM_STRIKEOUT;
     If Active Then
      dwEffects := dwEffects Or CFE_STRIKEOUT
     Else
      dwEffects := dwEffects And Not CFE_STRIKEOUT;
    End;
  End;

{ TBBCodeFont }

  Class Function TBBCodeFontFace.GetTagName : String;

Begin
 Result := 'FONT';

End;

 Procedure TBBCodeFontFace.Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2);
  Begin
   Inherited Prepare(ParaFormat, CharFormat);
   With CharFormat Do
    Begin
     dwMask := dwMask Or CFM_FACE;
     StrLCopy(szFaceName, PChar(FontName), High(szFaceName) - 1);
    End;
  End;

 Function TBBCodeFontFace.GetFontName : String;
  Begin
   Result := Attribute;
  End;

 Procedure TBBCodeFontFace.SetFontName(Const Value : String);
  Begin
   Attribute := Value;
  End;

{ TBBCodeSize }

  Class Function TBBCodeFontSize.GetTagName : String;

Begin
 Result := 'SIZE';

End;

 Procedure TBBCodeFontSize.Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2);
  Begin
   Inherited Prepare(ParaFormat, CharFormat);
   With CharFormat Do
    Begin
     dwMask  := dwMask Or CFM_SIZE;
     yHeight := Size * 20;
    End;
  End;

 Function TBBCodeFontSize.GetSize : Integer;
  Begin
   Result := StrToIntDef(Attribute, 10);
  End;

 Procedure TBBCodeFontSize.SetSize(Value : Integer);
  Begin
   Attribute := IntToStr(Value);
  End;

{ TBBCodeColor }

  Class Function TBBCodeFontColor.GetTagName : String;

Begin
 Result := 'COLOR';

End;

 Procedure TBBCodeFontColor.Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2);
  Var
   c : TColor;
  Begin
   Inherited Prepare(ParaFormat, CharFormat);
   c := Color;
   With CharFormat Do
    Begin
     dwMask := dwMask Or CFM_COLOR;
     If c = clWindowText Then
      dwEffects := dwEffects Or CFE_AUTOCOLOR
     Else
      Begin
       dwEffects   := dwEffects And Not CFE_AUTOCOLOR;
       crTextColor := ColorToRGB(c);
      End;
    End;
  End;

 Function TBBCodeFontColor.GetColor : TColor;
  Begin
   Result := BBCodes.StrToColor(Attribute, clWindowText);
  End;

 Procedure TBBCodeFontColor.SetColor(Value : TColor);
  Begin
   Attribute := BBCodes.ColorToStr(Value);
  End;

{ TBBCodeBackColor }

  Class Function TBBCodeBackColor.GetTagName : String;

Begin
 Result := 'BACKCOLOR';

End;

 Procedure TBBCodeBackColor.Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2);
  Var
   c : TColor;
  Begin
   Inherited Prepare(ParaFormat, CharFormat);
   c := Color;
   With CharFormat Do
    Begin
     dwMask := dwMask Or CFM_BACKCOLOR;
     If c = clWindow Then
      dwEffects := dwEffects Or CFE_AUTOBACKCOLOR
     Else
      Begin
       dwEffects   := dwEffects And Not CFE_AUTOBACKCOLOR;
       crBackColor := ColorToRGB(c);
      End;
    End;
  End;

 Function TBBCodeBackColor.GetColor : TColor;
  Begin
   Result := BBCodes.StrToColor(Attribute, clWindow);
  End;

 Procedure TBBCodeBackColor.SetColor(Value : TColor);
  Begin
   Attribute := BBCodes.ColorToStr(Value);
  End;

{ TBBCodeLink }

  Class Function TBBCodeLink.GetTagName : String;

Begin
 Result := 'LINK';

End;

 Procedure TBBCodeLink.Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2);
  Begin
   Inherited Prepare(ParaFormat, CharFormat);
   With CharFormat Do
    Begin
     dwMask := dwMask Or CFM_LINK;
     If Active Then
      dwEffects := dwEffects Or CFE_LINK
     Else
      dwEffects := dwEffects And Not CFE_LINK;
    End;
  End;

{ TBBCodeSubscript }

  Class Function TBBCodeSubscript.GetTagName : String;

Begin
 Result := 'SUB';

End;

 Procedure TBBCodeSubscript.Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2);
  Begin
   Inherited Prepare(ParaFormat, CharFormat);
   With CharFormat Do
    Begin
     dwMask := dwMask Or CFM_SUBSCRIPT;
     If Active Then
      dwEffects := dwEffects Or CFE_SUBSCRIPT
     Else
      dwEffects := dwEffects And Not CFE_SUBSCRIPT;
    End;
  End;

{ TBBCodeSuperscript }

  Class Function TBBCodeSuperscript.GetTagName : String;

Begin
 Result := 'SUP';

End;

 Procedure TBBCodeSuperscript.Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2);
  Begin
   Inherited Prepare(ParaFormat, CharFormat);
   With CharFormat Do
    Begin
     dwMask := dwMask Or CFM_SUPERSCRIPT;
     If Active Then
      dwEffects := dwEffects Or CFE_SUPERSCRIPT
     Else
      dwEffects := dwEffects And Not CFE_SUPERSCRIPT;
    End;
  End;

{ TBBCodeDisabled }

  Class Function TBBCodeDisabled.GetTagName : String;

Begin
 Result := 'DISABLED';

End;

 Procedure TBBCodeDisabled.Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2);
  Begin
   Inherited Prepare(ParaFormat, CharFormat);
   With CharFormat Do
    Begin
     dwMask := dwMask Or CFM_DISABLED;
     If Active Then
      dwEffects := dwEffects Or CFE_DISABLED
     Else
      dwEffects := dwEffects And Not CFE_DISABLED;
    End;
  End;

{ TBBCodeProtected }

  Class Function TBBCodeProtected.GetTagName : String;

Begin
 Result := 'PROTECTED';

End;

 Procedure TBBCodeProtected.Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2);
  Begin
   Inherited Prepare(ParaFormat, CharFormat);
   With CharFormat Do
    Begin
     dwMask := dwMask Or CFM_PROTECTED;
     If Active Then
      dwEffects := dwEffects Or CFE_PROTECTED
     Else
      dwEffects := dwEffects And Not CFE_PROTECTED;
    End;
  End;

{ TBBCodeHidden }

  Class Function TBBCodeHidden.GetTagName : String;

Begin
 Result := 'HIDDEN';

End;

 Procedure TBBCodeHidden.Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2);
  Begin
   Inherited Prepare(ParaFormat, CharFormat);
   With CharFormat Do
    Begin
     dwMask := dwMask Or CFM_HIDDEN;
     If Active Then
      dwEffects := dwEffects Or CFE_HIDDEN
     Else
      dwEffects := dwEffects And Not CFE_HIDDEN;
    End;
  End;

{ TBBCodeOutline }

  Class Function TBBCodeOutline.GetTagName : String;

Begin
 Result := 'OUTLINE';

End;

 Procedure TBBCodeOutline.Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2);
  Begin
   Inherited Prepare(ParaFormat, CharFormat);
   With CharFormat Do
    Begin
     dwMask := dwMask Or CFM_OUTLINE;
     If Active Then
      dwEffects := dwEffects Or CFE_OUTLINE
     Else
      dwEffects := dwEffects And Not CFE_OUTLINE;
    End;
  End;

{ TBBCodeShadow }

  Class Function TBBCodeShadow.GetTagName : String;

Begin
 Result := 'SHADOW';

End;

 Procedure TBBCodeShadow.Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2);
  Begin
   Inherited Prepare(ParaFormat, CharFormat);
   With CharFormat Do
    Begin
     dwMask := dwMask Or CFM_SHADOW;
     If Active Then
      dwEffects := dwEffects Or CFE_SHADOW
     Else
      dwEffects := dwEffects And Not CFE_SHADOW;
    End;
  End;

{ TBBCodeEmboss }

  Class Function TBBCodeEmboss.GetTagName : String;

Begin
 Result := 'EMBOSS';

End;

 Procedure TBBCodeEmboss.Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2);
  Begin
   Inherited Prepare(ParaFormat, CharFormat);
   With CharFormat Do
    Begin
     dwMask := dwMask Or CFM_EMBOSS;
     If Active Then
      dwEffects := dwEffects Or CFE_EMBOSS
     Else
      dwEffects := dwEffects And Not CFE_EMBOSS;
    End;
  End;

{ TBBCodeImprint }

  Class Function TBBCodeImprint.GetTagName : String;

Begin
 Result := 'IMPRINT';

End;

 Procedure TBBCodeImprint.Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2);
  Begin
   Inherited Prepare(ParaFormat, CharFormat);
   With CharFormat Do
    Begin
     dwMask := dwMask Or CFM_IMPRINT;
     If Active Then
      dwEffects := dwEffects Or CFE_IMPRINT
     Else
      dwEffects := dwEffects And Not CFE_IMPRINT;
    End;
  End;

{ TBBCodeSmallCaps }

  Class Function TBBCodeSmallCaps.GetTagName : String;

Begin
 Result := 'SMALLCAPS';

End;

 Procedure TBBCodeSmallCaps.Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2);
  Begin
   Inherited Prepare(ParaFormat, CharFormat);
   With CharFormat Do
    Begin
     dwMask := dwMask Or CFM_SMALLCAPS;
     If Active Then
      dwEffects := dwEffects Or CFE_SMALLCAPS
     Else
      dwEffects := dwEffects And Not CFE_SMALLCAPS;
    End;
  End;

{ TBBCodeAllCaps }

  Class Function TBBCodeAllCaps.GetTagName : String;

Begin
 Result := 'CAPS';

End;

 Procedure TBBCodeAllCaps.Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2);
  Begin
   Inherited Prepare(ParaFormat, CharFormat);
   With CharFormat Do
    Begin
     dwMask := dwMask Or CFM_ALLCAPS;
     If Active Then
      dwEffects := dwEffects Or CFE_ALLCAPS
     Else
      dwEffects := dwEffects And Not CFE_ALLCAPS;
    End;
  End;

{ TBBCodeRevised }

  Class Function TBBCodeRevised.GetTagName : String;

Begin
 Result := 'REVISED';

End;

 Procedure TBBCodeRevised.Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2);
  Begin
   Inherited Prepare(ParaFormat, CharFormat);
   With CharFormat Do
    Begin
     dwMask := dwMask Or CFM_REVISED;
     If Active Then
      dwEffects := dwEffects Or CFE_REVISED
     Else
      dwEffects := dwEffects And Not CFE_REVISED;
    End;
  End;

{ TBBCodeAuthor }

  Class Function TBBCodeRevAuthor.GetTagName : String;

Begin
 Result := 'AUTHOR';

End;

 Procedure TBBCodeRevAuthor.Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2);
  Begin
   Inherited Prepare(ParaFormat, CharFormat);
   With CharFormat Do
    Begin
     dwMask     := dwMask Or CFM_REVAUTHOR;
     bRevAuthor := Author;
    End;
  End;

 Function TBBCodeRevAuthor.GetAuthor : Byte;
  Begin
   Result := StrToIntDef(Attribute, 0);
  End;

 Procedure TBBCodeRevAuthor.SetAuthor(Value : Byte);
  Begin
   Attribute := IntToStr(Value);
  End;

{ TBBCodeCode }

  Class Function TBBCodeCode.GetTagName : String;

Begin
 Result := 'CODE';

End;

 Procedure TBBCodeCode.Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2);
  Begin
   Inherited Prepare(ParaFormat, CharFormat);
   With CharFormat Do
    Begin
     dwMask := dwMask Or CFM_FACE;
     StrCopy(szFaceName, 'Courier New');
    End;
  End;

{ TBBCodeCenter }

  Class Function TBBCodeCenter.GetTagName : String;

Begin
 Result := 'CENTER';

End;

 Procedure TBBCodeCenter.Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2);
  Begin
   Inherited Prepare(ParaFormat, CharFormat);
   With ParaFormat Do
    Begin
     dwMask     := dwMask Or PFM_ALIGNMENT;
     wAlignment := PFA_CENTER;
    End;
  End;

{ TBBCodeAlign }

  Class Function TBBCodeAlign.GetTagName : String;

Begin
 Result := 'ALIGN';

End;

 Procedure TBBCodeAlign.Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2);
  Begin
   Inherited Prepare(ParaFormat, CharFormat);
   With ParaFormat Do
    Begin
     dwMask     := dwMask Or PFM_ALIGNMENT;
     wAlignment := Ord(Alignment) + 1;
    End;
  End;

 Const
  SParaAlign : Array[TBBCodeAlign.TParaAlign] Of String =
  ('Left', 'Right', 'Center', 'Justify', 'FullInterWord');

 Function TBBCodeAlign.GetAlignment : TParaAlign;
  Var
   ParaAlign : TParaAlign;
  Begin
   If Attribute <> '' Then
    Begin
     For ParaAlign := Low(TParaAlign) To High(TParaAlign) Do
      If SameText(Attribute, SParaAlign[ParaAlign]) Then
       Begin
        Result := ParaAlign;
        Exit;
       End;
    End;
   Result := paLeft;
  End;

 Procedure TBBCodeAlign.SetAlignment(Value : TParaAlign);
  Begin
   Attribute := SParaAlign[Value];
  End;

{ TBBCodeLineSpacing }

  Class Function TBBCodeLineSpacing.GetTagName : String;

Begin
 Result := 'LS';

End;

 Procedure TBBCodeLineSpacing.Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2);
  Begin
   Inherited Prepare(ParaFormat, CharFormat);
   With ParaFormat Do
    Begin
     dwMask           := dwMask Or PFM_LINESPACING;
     bLineSpacingRule := Ord(Spacing);
    End;
  End;

 Function TBBCodeLineSpacing.GetSpacing : TLineSpacing;
  Var
   Spacing : Single;
  Begin
   Spacing := StrToFloatDef(Attribute, 1);
   If Spacing <= 1 Then
    Result := lsSingle
   Else If Spacing >= 2 Then
    Result := lsDouble
   Else
    Result := lsOneAndHalf;
  End;

 Procedure TBBCodeLineSpacing.SetSpacing(Value : TLineSpacing);
  Begin
   Case Value Of
    lsSingle     : Attribute := '1';
    lsOneAndHalf : Attribute := '1.5';
    lsDouble     : Attribute := '2';
   End;
  End;

{ TBBCodeParagraphSpaceBefore }

  Class Function TBBCodeParagraphSpaceBefore.GetTagName : String;

Begin
 Result := 'PSB';

End;

 Procedure TBBCodeParagraphSpaceBefore.Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2);
  Begin
   Inherited Prepare(ParaFormat, CharFormat);
   With ParaFormat Do
    Begin
     dwMask        := dwMask Or PFM_SPACEBEFORE;
     dySpaceBefore := Spacing * 20;
    End;
  End;

 Function TBBCodeParagraphSpaceBefore.GetSpacing : Integer;
  Begin
   Result := StrToIntDef(Attribute, 0);
  End;

 Procedure TBBCodeParagraphSpaceBefore.SetSpacing(Value : Integer);
  Begin
   Attribute := IntToStr(Value);
  End;

{ TBBCodeParagraphSpaceAfter }

  Class Function TBBCodeParagraphSpaceAfter.GetTagName : String;

Begin
 Result := 'PSA';

End;

 Procedure TBBCodeParagraphSpaceAfter.Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2);
  Begin
   Inherited Prepare(ParaFormat, CharFormat);
   With ParaFormat Do
    Begin
     dwMask       := dwMask Or PFM_SPACEAFTER;
     dySpaceAfter := Spacing * 20;
    End;
  End;

 Function TBBCodeParagraphSpaceAfter.GetSpacing : Integer;
  Begin
   Result := StrToIntDef(Attribute, 0);
  End;

 Procedure TBBCodeParagraphSpaceAfter.SetSpacing(Value : Integer);
  Begin
   Attribute := IntToStr(Value);
  End;

{ TBBCodeIndent }

  Class Function TBBCodeIndent.GetTagName : String;

Begin
 Result := 'INDENT';

End;

 Procedure TBBCodeIndent.Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2);
  Begin
   Inherited Prepare(ParaFormat, CharFormat);
   With ParaFormat Do
    Begin
     dwMask        := dwMask Or PFM_OFFSETINDENT Or PFM_OFFSET;
     dxStartIndent := Indent * 20;
     dxOffset      := 0;
    End;
  End;

 Function TBBCodeIndent.GetIndent : Integer;
  Begin
   Result := StrToIntDef(Attribute, 16);
  End;

 Procedure TBBCodeIndent.SetIndent(Value : Integer);
  Begin
   Attribute := IntToStr(Value);
  End;

{ TBBCodeRightIndent }

  Class Function TBBCodeRightIndent.GetTagName : String;

Begin
 Result := 'RINDENT';

End;

 Procedure TBBCodeRightIndent.Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2);
  Begin
   Inherited Prepare(ParaFormat, CharFormat);
   With ParaFormat Do
    Begin
     dwMask        := dwMask Or PFM_RIGHTINDENT;
     dxRightIndent := Indent * 20;
    End;
  End;

 Function TBBCodeRightIndent.GetIndent : Integer;
  Begin
   Result := StrToIntDef(Attribute, 16);
  End;

 Procedure TBBCodeRightIndent.SetIndent(Value : Integer);
  Begin
   Attribute := IntToStr(Value);
  End;

{ TBBCodeDir }

  Class Function TBBCodeDir.GetTagName : String;

Begin
 Result := 'DIR';

End;

 Procedure TBBCodeDir.Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2);
  Begin
   Inherited Prepare(ParaFormat, CharFormat);
   With ParaFormat Do
    Begin
     dwMask := dwMask Or PFM_RTLPARA;
     If Direction = RTL Then
      wReserved := wReserved Or PFE_RTLPARA
     Else
      wReserved := wReserved And Not PFE_RTLPARA
    End;
  End;

 Const
  STextDirection : Array[TBBCodeDir.TTextDirection] Of String =
  ('LTR', 'RTL');

 Function TBBCodeDir.GetDirection : TTextDirection;
  Var
   TextDir : TTextDirection;
  Begin
   If Attribute <> '' Then
    Begin
     For TextDir := Low(TTextDirection) To High(TTextDirection) Do
      If SameText(Attribute, STextDirection[TextDir]) Then
       Begin
        Result := TextDir;
        Exit;
       End;
    End;
   Result := TTextDirection.LTR;
  End;

 Procedure TBBCodeDir.SetDirection(Value : TTextDirection);
  Begin
   Attribute := STextDirection[Value];
  End;

{ TBBCodeList }

  Class Function TBBCodeList.GetTagName : String;

Begin
 Result := 'LIST';

End;

 Procedure TBBCodeList.Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2);
  Var
   TheNumbering : TListNumbering;
   TheStart     : Word;
   TheStyle     : TListNumberingStyle;
   TheTab       : Integer;
  Begin
   DecodeAttribute(TheNumbering, TheStart, TheStyle, TheTab);
   Inherited Prepare(ParaFormat, CharFormat);
   With ParaFormat Do
    Begin
     dwMask := dwMask Or PFM_NUMBERING Or PFM_NUMBERINGSTART Or
     PFM_NUMBERINGSTYLE Or PFM_NUMBERINGTAB Or PFM_OFFSETINDENT Or PFM_OFFSET;
     dxStartIndent   := 8 * 20;
     dxOffset        := 0;
     wNumbering      := Ord(TheNumbering);
     wNumberingStyle := Ord(TheStyle) Shl 8;
     wNumberingStart := TheStart;
     wNumberingTab   := TheTab * 20;
    End;
  End;

 Const
  SNone = 'None';
  SListNumberingStyle : Array[TBBCodeList.TListNumberingStyle] Of String =
  ('Parenthesis', 'Enclosed', 'Period', 'Simple');

 Procedure TBBCodeList.DecodeAttribute(Out TheNumbering : TListNumbering; Out TheStart : Word; Out TheStyle : TListNumberingStyle; Out TheTab : Integer);
  Var
   i                   : Integer;
   Attr1, Attr2, Attr3 : String;
   s                   : TListNumberingStyle;
  Begin
   i := Pos(',', Attribute);
   If i <> 0 Then
    Begin
     Attr1 := Trim(Copy(Attribute, 1, i - 1));
     Attr2 := Trim(Copy(Attribute, i + 1, Length(Attribute) - i));
     i     := Pos(',', Attr2);
     If i <> 0 Then
      Begin
       Attr3 := Trim(Copy(Attr2, i + 1, Length(Attr2) - i));
       Attr2 := Trim(Copy(Attr2, 1, i - 1));
      End
     Else
      Attr3 := '';
     If Attr1 = '' Then
      Begin
       Attr1 := Attr2;
       Attr2 := '';
      End;
     If Attr2 = '' Then
      Begin
       Attr2 := Attr3;
       Attr3 := '';
      End;
    End
   Else
    Begin
     Attr1 := Attribute;
     Attr2 := '';
     Attr3 := '';
    End;
   TheStyle     := nsParenthesis;
   TheNumbering := lnBullet;
   TheStart     := 1;
   TheTab       := 0;
   If Attr1 <> '' Then
    Begin
     // style
     For s := Low(TListNumberingStyle) To High(TListNumberingStyle) Do
      If SameText(Attr1, SListNumberingStyle[s]) Then
       Begin
        TheStyle := s;
        Attr1    := Attr2;
        Attr2    := Attr3;
        Attr3    := '';
        Break;
       End
      Else If (Attr2 <> '') And SameText(Attr2, SListNumberingStyle[s]) Then
       Begin
        TheStyle := s;
        Attr2    := Attr3;
        Attr3    := '';
        Break;
       End
      Else If (Attr3 <> '') And SameText(Attr3, SListNumberingStyle[s]) Then
       Begin
        TheStyle := s;
        Attr3    := '';
        Break;
       End;
      // tab
     If (Length(Attr1) > 1) And (Pos('@', Attr1) = 1) Then
      Begin
       TheTab := StrToIntDef(Copy(Attr1, 2, Length(Attr1) - 1), 0);
       Attr1  := Attr2;
       Attr2  := Attr3;
       Attr3  := '';
      End
     Else If (Length(Attr2) > 1) And (Pos('@', Attr2) = 1) Then
      Begin
       TheTab := StrToIntDef(Copy(Attr2, 2, Length(Attr2) - 1), 0);
       Attr2  := Attr3;
       Attr3  := '';
      End
     Else If (Length(Attr3) > 1) And (Pos('@', Attr3) = 1) Then
      Begin
       TheTab := StrToIntDef(Copy(Attr3, 2, Length(Attr3) - 1), 0);
       Attr3  := '';
      End;
     // numbering & start
     If Attr1 = '' Then
      TheNumbering := lnBullet
     Else If SameText(Attr1, SNone) Then
      TheNumbering := lnNone
     Else
      Begin
       TheStart := StrToIntDef(Attr1, 0);
       If TheStart <> 0 Then
        TheNumbering := lnNumber
       Else
        Begin
         TheStart := BBCodes.LetterToNumber(Attr1);
         If TheStart <> 0 Then
          Begin
           TheNumbering := lnUpperLetter;
           If (Length(Attr1) > 1) Or (Pos(UpCase(Attr1[1]), 'IVX') <> 0) Then
            Begin
             i := BBCodes.RomanToNumber(Attr1);
             If i <> 0 Then
              Begin
               TheStart     := i;
               TheNumbering := lnUpperRoman;
              End;
            End;
           If IsCharLower(Attr1[1]) Then
            Dec(TheNumbering);
          End
         Else
          Begin
           TheStart     := Ord(Attr1[1]);
           TheNumbering := lnCustom;
          End;
        End;
      End;
    End;
  End;

 Procedure TBBCodeList.EncodeAttribute(TheNumbering : TListNumbering; TheStart : Word; TheStyle : TListNumberingStyle; TheTab : Integer);
  Begin
   If TheNumbering <> lnNone Then
    Begin
     Attribute := '';
     If (TheNumbering <> lnBullet) And (TheStart <> 0) Then
      Begin
       Case TheNumbering Of
        lnNumber      : Attribute := IntToStr(TheStart);
        lnLowerLetter : Attribute := LowerCase(BBCodes.NumberToLetter(TheStart));
        lnUpperLetter : Attribute := BBCodes.NumberToLetter(TheStart);
        lnLowerRoman  : Attribute := LowerCase(BBCodes.NumberToRoman(TheStart));
        lnUpperRoman  : Attribute := BBCodes.NumberToRoman(TheStart);
        lnCustom      : Attribute := Chr(TheStart);
       End;
       If TheStyle <> nsParenthesis Then
        Attribute := Attribute + ',' + SListNumberingStyle[TheStyle];
      End;
     If TheTab <> 0 Then
      Begin
       If Attribute <> '' Then
        Attribute := Attribute + ',';
       Attribute  := Attribute + '@' + IntToStr(TheTab);
      End;
    End
   Else
    Attribute := SNone;
  End;

 Function TBBCodeList.GetNumbering : TListNumbering;
  Var
   TheNumbering : TListNumbering;
   TheStart     : Word;
   TheStyle     : TListNumberingStyle;
   TheTab       : Integer;
  Begin
   DecodeAttribute(TheNumbering, TheStart, TheStyle, TheTab);
   Result := TheNumbering;
  End;

 Procedure TBBCodeList.SetNumbering(Value : TListNumbering);
  Var
   TheNumbering : TListNumbering;
   TheStart     : Word;
   TheStyle     : TListNumberingStyle;
   TheTab       : Integer;
  Begin
   DecodeAttribute(TheNumbering, TheStart, TheStyle, TheTab);
   EncodeAttribute(Value, TheStart, TheStyle, TheTab);
  End;

 Function TBBCodeList.GetStart : Word;
  Var
   TheNumbering : TListNumbering;
   TheStart     : Word;
   TheStyle     : TListNumberingStyle;
   TheTab       : Integer;
  Begin
   DecodeAttribute(TheNumbering, TheStart, TheStyle, TheTab);
   Result := TheStart;
  End;

 Procedure TBBCodeList.SetStart(Value : Word);
  Var
   TheNumbering : TListNumbering;
   TheStart     : Word;
   TheStyle     : TListNumberingStyle;
   TheTab       : Integer;
  Begin
   DecodeAttribute(TheNumbering, TheStart, TheStyle, TheTab);
   EncodeAttribute(TheNumbering, Value, TheStyle, TheTab);
  End;

 Function TBBCodeList.GetStyle : TListNumberingStyle;
  Var
   TheNumbering : TListNumbering;
   TheStart     : Word;
   TheStyle     : TListNumberingStyle;
   TheTab       : Integer;
  Begin
   DecodeAttribute(TheNumbering, TheStart, TheStyle, TheTab);
   Result := TheStyle;
  End;

 Procedure TBBCodeList.SetStyle(Value : TListNumberingStyle);
  Var
   TheNumbering : TListNumbering;
   TheStart     : Word;
   TheStyle     : TListNumberingStyle;
   TheTab       : Integer;
  Begin
   DecodeAttribute(TheNumbering, TheStart, TheStyle, TheTab);
   EncodeAttribute(TheNumbering, TheStart, Value, TheTab);
  End;

 Function TBBCodeList.GetTab : Integer;
  Var
   TheNumbering : TListNumbering;
   TheStart     : Word;
   TheStyle     : TListNumberingStyle;
   TheTab       : Integer;
  Begin
   DecodeAttribute(TheNumbering, TheStart, TheStyle, TheTab);
   Result := TheTab;
  End;

 Procedure TBBCodeList.SetTab(Value : Integer);
  Var
   TheNumbering : TListNumbering;
   TheStart     : Word;
   TheStyle     : TListNumberingStyle;
   TheTab       : Integer;
  Begin
   DecodeAttribute(TheNumbering, TheStart, TheStyle, TheTab);
   EncodeAttribute(TheNumbering, TheStart, TheStyle, Value);
  End;

{ TBBCodeTabs }

  Class Function TBBCodeTabs.GetTagName : String;

Begin
 Result := 'TABS';

End;

 Procedure TBBCodeTabs.Prepare(Var ParaFormat : TParaFormat2; Var CharFormat : TCharFormat2);
  Var
   Tabs, Tab : String;
   TabStop   : Integer;
   i         : Integer;
  Begin
   Inherited Prepare(ParaFormat, CharFormat);
   With ParaFormat Do
    Begin
     dwMask    := dwMask Or PFM_TABSTOPS;
     cTabCount := 0;
     While (Tabs <> '') And (cTabCount <= High(rgxTabs)) Do
      Begin
       i := Pos(',', Tabs);
       If i <> 0 Then
        Begin
         Tab := Copy(Tabs, 1, i - 1);
         Delete(Tabs, 1, i);
        End
       Else
        Begin
         Tab  := Tabs;
         Tabs := '';
        End;
       TabStop := StrToIntDef(Tab, 0);
       If TabStop <> 0 Then
        Begin
         rgxTabs[cTabCount] := TabStop * 20;
         Inc(cTabCount);
        End;
      End;
    End;
  End;

 Function TBBCodeTabs.GetTabStops : String;
  Begin
   Result := Attribute;
  End;

 Procedure TBBCodeTabs.SetTabStops(Const Value : String);
  Begin
   Attribute := Value;
  End;

{ BBCodes }

  Class Function BBCodes.StrToColor(Const Str : String; DefColor : TColor) : TColor;

Begin
 If Pos('#', Str) = 1 Then
  Begin
   If Length(Str) = 7 Then
    Try
     Result := RGB(
     StrToInt('$' + Copy(Str, 2, 2)),
     StrToInt('$' + Copy(Str, 4, 2)),
     StrToInt('$' + Copy(Str, 6, 2)));
    Except
     Result := DefColor;
    End
   Else If Length(Str) = 4 Then
    Try
     Result := RGB(
     (StrToInt('$' + Copy(Str, 2, 1)) Shl 4) Or StrToInt('$' + Copy(Str, 2, 1)),
     (StrToInt('$' + Copy(Str, 3, 1)) Shl 4) Or StrToInt('$' + Copy(Str, 3, 1)),
     (StrToInt('$' + Copy(Str, 4, 1)) Shl 4) Or StrToInt('$' + Copy(Str, 4, 1)))
    Except
     Result := DefColor;
    End
   Else
    Result := DefColor;
  End
 Else If Pos('$', Str) = 1 Then
  Result := StrToIntDef(Str, DefColor)
 Else If Not IdentToColor('cl' + Str, Integer(Result)) Then
  Result := DefColor;

End;

  Class Function BBCodes.ColorToStr(Color : TColor) : String;

 Var
  RGB : Integer;

Begin
 If ColorToIdent(Color, Result) Then
  Delete(Result, 1, 2)
 Else
  Begin
   RGB    := ColorToRGB(Color);
   Result := '#'
   + IntToHex(GetRValue(RGB), 2)
   + IntToHex(GetGValue(RGB), 2)
   + IntToHex(GetBValue(RGB), 2);
  End;

End;

  Class Function BBCodes.RomanToNumber(Const Roman : String) : Integer;

 Const
  Numbers : Array[1..7] Of Integer = (1, 5, 10, 50, 100, 500, 1000);
  Romans = 'IVXLCDMivxlcdm';

 Var
  i, n               : Integer;
  NewValue, OldValue : Integer;

Begin
 Result   := 0;
 OldValue := 0;
 For i    := Length(Roman) Downto 1 Do
  Begin
   n := Pos(Roman[i], Romans);
   If n = 0 Then
    Begin
     Result := 0;
     Exit;
    End;
   If n > High(Numbers) Then
    NewValue := Numbers[n - High(Numbers)]
   Else
    NewValue := Numbers[n];
   If NewValue < OldValue Then
    Dec(Result, NewValue)
   Else
    Inc(Result, NewValue);
   OldValue := NewValue;
  End;

End;

  Class Function BBCodes.NumberToRoman(Number : Integer) : String;
// Taken from http://www.swissdelphicenter.ch/torry/showcode.php?id=766

 Const
  Numbers : Array[1..13] Of Integer =
  (1, 4, 5, 9, 10, 40, 50, 90, 100, 400, 500, 900, 1000);
  Romans : Array[1..13] Of String =
  ('I', 'IV', 'V', 'IX', 'X', 'XL', 'L', 'XC', 'C', 'CD', 'D', 'CM', 'M');

 Var
  i : Integer;

Begin
 Result := '';
 For i  := 13 Downto 1 Do
  While Number >= Numbers[i] Do
   Begin
    Number := Number - Numbers[i];
    Result := Result + Romans[i];
   End;

End;

  Class Function BBCodes.LetterToNumber(Const Letter : String) : Integer;

 Var
  i : Integer;

Begin
 Result := 0;
 For i  := 1 To Length(Letter) Do
  Begin
   If (Letter[i] >= 'A') And (Letter[i] <= 'Z') Then
    Result := Result * 26 + Ord(Letter[i]) - Ord('A') + 1
   Else If (Letter[i] >= 'a') And (Letter[i] <= 'z') Then
    Result := Result * 26 + Ord(Letter[i]) - Ord('a') + 1
   Else
    Begin
     Result := 0;
     Exit;
    End;
  End;

End;

  Class Function BBCodes.NumberToLetter(Number : Integer) : String;

Begin
 Result := '';
 While Number > 0 Do
  Begin
   Result := Chr(Ord('A') + (Number - 1) Mod 26) + Result;
   Number := (Number - 1) Div 26;
  End;

End;

  Class Procedure BBCodes.Cleanup;

Begin
 If Assigned(BBCodeClasses) Then
  FreeAndNil(BBCodeClasses);

End;

  Class Procedure BBCodes.Register(BBCodeClass : TBBCodeClass);

 Var
  Index : Integer;

Begin
 If Not Assigned(BBCodeClasses) Then
  Begin
   BBCodeClasses               := TStringList.Create;
   BBCodeClasses.CaseSensitive := False;
   BBCodeClasses.Sorted        := True;
  End;
 If BBCodeClasses.Find(BBCodeClass.GetTagName, Index) Then
  BBCodeClasses.Objects[Index] := TObject(BBCodeClass)
 Else
  BBCodeClasses.AddObject(BBCodeClass.GetTagName, TObject(BBCodeClass));

End;

  Class Procedure BBCodes.Unregister(BBCodeClass : TBBCodeClass);

 Var
  Index : Integer;

Begin
 If Assigned(BBCodeClasses) And
 BBCodeClasses.Find(BBCodeClass.GetTagName, Index) And
 (BBCodeClasses.Objects[Index] = TObject(BBCodeClass))
 Then
  BBCodeClasses.Delete(Index);

End;

  Class Function BBCodes.IsRegistered(BBCodeClass : TBBCodeClass) : Boolean;

 Var
  Index : Integer;

Begin
 Result := Assigned(BBCodeClasses)
 And BBCodeClasses.Find(BBCodeClass.GetTagName, Index)
 And (BBCodeClasses.Objects[Index] = TObject(BBCodeClass));

End;

  Class Function BBCodes.Find(Const TagName : String) : TBBCodeClass;

 Var
  Index : Integer;

Begin
 If Assigned(BBCodeClasses) And BBCodeClasses.Find(UpperCase(TagName), Index) Then
  Result := TBBCodeClass(BBCodeClasses.Objects[Index])
 Else
  Result := Nil;

End;

  Class Function BBCodes.Parse(Const BBCodeText : String; Out PlainText : String; BBCodes : TBBCodeObjectList) : Boolean;

 Var
  Stack        : TList;
  BBCode       : TBBCodeClass;
  Current      : TBBCode;
  IsClosingTag : Boolean;
  Tag, Attr    : String;
  p, s, t      : PChar;
  Len          : Integer;

Begin
 Result  := True;
 Current := Nil;
 SetString(PlainText, Nil, Length(BBCodeText));
 Stack := TList.Create;
 Try
  s   := PChar(BBCodeText);
  p   := s;
  Len := 0;
  While p^ <> #0 Do
   Begin
    If p^ = '[' Then
     Begin
      // more plain text?
      If p <> s Then
       Begin
        StrLCopy(@PlainText[Len + 1], s, p - s);
        Inc(Len, p - s);
        s := p;
       End;
      Inc(p);
      // is it the escaped '[' character?
      If p^ = '[' Then
       Begin
        Inc(Len);
        PlainText[Len] := '[';
       End
      Else
       Begin
        // is it a closing tag?
        If p^ = '/' Then
         Begin
          IsClosingTag := True;
          Inc(p);
         End
        Else
         IsClosingTag := False;
        // get the tag name
        t := p;
        While IsCharAlphaNumeric(p^) Do
         Inc(p);
        SetString(Tag, t, p - t);
        // skip blanks
        While (p^ = ' ') Or (p^ = #13) Or (p^ = #10) Or (p^ = #9) Do
         Inc(p);
        // is it the closing tag?
        If IsClosingTag Then
         Begin
          If (p^ = ']') And Assigned(Current) And SameText(Current.TagName, Tag) Then
           Begin
            Current.SelEnd := Len;
            BBCodes.Add(Current);
            Current := Nil;
            // go up one level
            If Stack.Count <> 0 Then
             Begin
              Current := TBBCode(Stack.Last);
              Stack.Delete(Stack.Count - 1);
             End;
           End
          Else
           Begin
            Inc(Len);
            PlainText[Len] := '[';
            p              := s;
            Result         := False;
           End;
         End
        Else
         Begin
          // is there an attribute
          Attr := '';
          If p^ = '=' Then
           Begin
            Inc(p);
            t := p;
            While (p^ <> #0) And (p^ <> ']') Do
             Inc(p);
            SetString(Attr, t, p - t);
           End;
          BBCode := Find(Tag);
          If (p^ = ']') And Assigned(BBCode) Then
           Begin
            // put the current BBCode on the stack
            If Assigned(Current) Then
             Stack.Add(Current);
            // create new BBCode
            Current           := BBCode.Create;
            Current.SelStart  := Len;
            Current.Attribute := Trim(Attr);
           End
          Else
           Begin
            Inc(Len);
            PlainText[Len] := '[';
            p              := s;
            Result         := False;
           End;
         End;
       End;
      s := p + 1;
      If ((Len = 0) Or (PlainText[Len] = #10)) And (s^ = #13) Then
       Begin
        Dec(Len);
        Inc(s);
       End;
     End;
    Inc(p);
   End;
  // more plain text?
  If p <> s Then
   Begin
    StrLCopy(@PlainText[Len + 1], s, p - s);
    Inc(Len, p - s);
   End;
  SetLength(PlainText, Len);
  // any open tag?
  While Assigned(Current) Do
   Begin
    Current.SelEnd := Len;
    BBCodes.Add(Current);
    Current := Nil;
    If Stack.Count <> 0 Then
     Begin
      Current := TBBCode(Stack.Last);
      Stack.Delete(Stack.Count - 1);
     End;
    Result := False;
   End;
 Finally
  Stack.Free;
 End;

End;

  Class Procedure BBCodes.Apply(hRichEdit : THandle; Const BBCodeText : String; Append : Boolean);

 Var
  BBCodes   : TBBCodeObjectList;
  Range     : TCharRange;
  PlainText : String;
  i, Offset : Integer;

Begin
 BBCodes := TBBCodeObjectList.Create(True);
 Try
  Parse(BBCodeText, PlainText, BBCodes);
  SendMessage(hRichEdit, WM_SETREDRAW, 0, 0);
  Try
   If Not Append Then
    SetWindowText(hRichEdit, '');
   Offset      := GetWindowTextLength(hRichEdit);
   Range.cpMin := Offset;
   Range.cpMax := Offset;
   SendMessage(hRichEdit, EM_EXSETSEL, 0, LPARAM(@Range));
   SendMessage(hRichEdit, EM_REPLACESEL, 0, LPARAM(PChar(PlainText)));
   For i := BBCodes.Count - 1 Downto 0 Do
    BBCodes[i].Apply(hRichEdit, Offset);
   SendMessage(hRichEdit, EM_SETSEL, 0, 0);
   SendMessage(hRichEdit, EM_EMPTYUNDOBUFFER, 0, 0);
  Finally
   SendMessage(hRichEdit, WM_SETREDRAW, 1, 0);
   InvalidateRect(hRichEdit, Nil, True);
  End;
 Finally
  BBCodes.Free;
 End;

End;

  Class Procedure BBCodes.Apply(RichEdit : TCustomRichEdit; Const BBCodeText : String; Append : Boolean);

Begin
 Apply(RichEdit.Handle, BBCodeText, Append);

End;

Initialization
 BBCodes.Register(TBBCodeBold);
 BBCodes.Register(TBBCodeItalic);
 BBCodes.Register(TBBCodeUnderline);
 BBCodes.Register(TBBCodeStrikeout);
 BBCodes.Register(TBBCodeFontFace);
 BBCodes.Register(TBBCodeFontSize);
 BBCodes.Register(TBBCodeFontColor);
 BBCodes.Register(TBBCodeBackColor);
 BBCodes.Register(TBBCodeLink);
 BBCodes.Register(TBBCodeSubscript);
 BBCodes.Register(TBBCodeSuperscript);
 BBCodes.Register(TBBCodeDisabled);
 BBCodes.Register(TBBCodeProtected);
 BBCodes.Register(TBBCodeHidden);
 BBCodes.Register(TBBCodeOutline);
 BBCodes.Register(TBBCodeShadow);
 BBCodes.Register(TBBCodeEmboss);
 BBCodes.Register(TBBCodeImprint);
 BBCodes.Register(TBBCodeSmallCaps);
 BBCodes.Register(TBBCodeAllCaps);
 BBCodes.Register(TBBCodeRevised);
 BBCodes.Register(TBBCodeRevAuthor);
 BBCodes.Register(TBBCodeCode);
 BBCodes.Register(TBBCodeCenter);
 BBCodes.Register(TBBCodeAlign);
 BBCodes.Register(TBBCodeLineSpacing);
 BBCodes.Register(TBBCodeParagraphSpaceBefore);
 BBCodes.Register(TBBCodeParagraphSpaceAfter);
 BBCodes.Register(TBBCodeIndent);
 BBCodes.Register(TBBCodeRightIndent);
 BBCodes.Register(TBBCodeDir);
 BBCodes.Register(TBBCodeList);
 BBCodes.Register(TBBCodeTabs);

Finalization
 BBCodes.Cleanup;

End.
