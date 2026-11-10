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
/// This unit implements classes for managing translation catalogs and
/// translation repositories.
/// </summary>
Unit i18nCatalog;

{$I DELPHIAREA.INC}

Interface

 Uses
  Windows, SysUtils, Classes, Contnrs, XMLIntf,
  i18nHashList, i18nCore, i18nPlurals, i18nUtils, i18nUnicode;

 Const

  {$Region 'xmldoc'}
  /// <summary>
  /// This constant represents the default extension of translation files.
  /// </summary>
  {$Endregion}
  i18nCatalogFileExt = '.i18n';

{$Region 'xmldoc'}
/// <summary>
/// This constant represents the default extension of translation repository files.
/// </summary>
{$Endregion}
  i18nRepositoryFileExt = '.m17n';

 Type

  {$Region 'xmldoc'}
  /// <summary>
  /// ETranslationCatalogError is the exception class for problems that occur while
  /// loading a translation catalog into memory.
  /// </summary>
  /// <seealso cref="TTranslationCatalog"/>
  {$Endregion}
   ETranslationCatalogError = Class(Exception);

 {$Region 'xmldoc'}
 /// <summary>
 /// ETranslationRepositoryError is the exception class for problems that occur
 /// while loading a translation repository into memory.
 /// </summary>
 /// <seealso cref="TTranslationRepository"/>
 {$Endregion}

    ETranslationRepositoryError = Class(Exception);

  {$Region 'xmldoc'}
  /// <summary>
  /// TXMLPersistentHashItem is the base class for all hash item objects that are
  /// able to be saved to or loaded from an XML node.
  /// </summary>
  /// <seealso cref="TXMLPersistentHashList"/>
  {$Endregion}

      TXMLPersistentHashItem = Class Abstract(THashItem)
     Protected
      {$Region 'xmldoc'}
      /// <summary>
      /// Reads the object's content from an XML node.
      /// </summary>
      /// <param name="Node">
      /// The XML node.
      /// </param>
      /// <seealso cref="Save"/>
      {$Endregion}
      Procedure Load(Const Node : IXMLNode); Virtual; Abstract;
      {$Region 'xmldoc'}
      /// <summary>
      /// Writes the object's content to an XML node.
      /// </summary>
      /// <param name="Node">
      /// The XML node.
      /// </param>
      /// <seealso cref="Save"/>
      {$Endregion}
      Procedure Save(Const Node : IXMLNode); Virtual; Abstract;
    End;

  {$Region 'xmldoc'}
  /// <summary>
  /// TXMLPersistentHashList is the base class for all hash list objects that are
  /// able to add an item directly from an XML node.
  /// </summary>
  /// <seealso cref="TXMLPersistentHashItem"/>
  {$Endregion}

      TXMLPersistentHashList = Class Abstract(THashList)
     Protected
      {$Region 'xmldoc'}
      /// <summary>
      /// Returns the <see cref="TXMLPersistentHashItem"/> class that represents
      /// individual items of the list.
      /// </summary>
      /// <returns>
      /// The <see cref="TXMLPersistentHashItem"/> class or one of its descendants.
      /// </returns>
      {$Endregion}
      Function GetItemClass : THashItemClass; Override;
      {$Region 'xmldoc'}
      /// <summary>
      /// Creates a new item from a specified XML node, and then adds the item to the list.
      /// </summary>
      /// <param name="Node">
      /// The XML node.
      /// </param>
      /// <returns>
      /// The <see cref="TXMLPersistentHashItem"/> object that is newly added to the list.
      /// </returns>
      {$Endregion}
      Function Add(Const Node : IXMLNode) : TXMLPersistentHashItem; Overload; Virtual; Abstract;
    End;

    TTextItems = Class;

  {$Region 'xmldoc'}
  /// <summary>
  /// TTextItem represents a text string including its translation.
  /// </summary>
  /// <remarks>
  /// <para>
  /// TTextItem stores the original value of a text string and comments regarding its
  /// value. If the text is translated, it also provides the translated version of
  /// the text.
  /// </para>
  /// <para>
  /// TTextItem does not store any of the original and translated languages. If
  /// you need to know about those languages, use <see cref="TTextDefinition"/>
  /// class instead.
  /// </para>
  /// </remarks>
  /// <seealso cref="TTextItems"/>
  /// <seealso cref="TTextDefinition"/>
  {$Endregion}

    TTextItem = Class(TXMLPersistentHashItem)
     Private
      fID              : String;
      fComment         : String;
      fOriginalValue   : String;
      fTranslatedValue : String;
      fIsTranslated    : Boolean;
      fTag             : Integer;
      Procedure SetOriginalValue(Const Value : String);
      Procedure SetTranslatedValue(Const Value : String);
      Procedure SetIsTranslated(Value : Boolean);
      Function GetValue : String;
      Procedure SetValue(Const Value : String);
      Function GetHasPluralForms : Boolean; Inline;
      Function GetPluralCount : Integer; Inline;
      Function GetPlurals(Index : Integer) : String; Inline;
      Procedure SetPlurals(Index : Integer; Const PluralForm : String); Inline;
      Function GetOwnerList : TTextItems; Inline;
      Function GetPrev : TTextItem; Inline;
      Function GetNext : TTextItem; Inline;
     Protected
      {$Region 'xmldoc'}
      /// <summary>
      /// Returns a unique key that identifies the object.
      /// </summary>
      /// <returns>
      /// Returns the unique key of the item.
      /// </returns>
      {$Endregion}
      Function GetKey : String; Override;
      {$Region 'xmldoc'}
      /// <summary>
      /// Reads properties of the object from an XML node.
      /// </summary>
      /// <param name="Node">
      /// The XML node.
      /// </param>
      /// <seealso cref="Save"/>
      {$Endregion}
      Procedure Load(Const Node : IXMLNode); Override;
      {$Region 'xmldoc'}
      /// <summary>
      /// Writes properties of the object to an XML node.
      /// </summary>
      /// <param name="Node">
      /// The XML node.
      /// </param>
      /// <seealso cref="Load"/>
      {$Endregion}
      Procedure Save(Const Node : IXMLNode); Override;
     Public
      {$Region 'xmldoc'}
      /// <summary>
      /// Creates an instance of the class.
      /// </summary>
      /// <param name="AID">
      /// The unique identifier of the new instance.
      /// </param>
      {$Endregion}
      Constructor Create(Const AID : String); Override;
      {$Region 'xmldoc'}
      /// <summary>
      /// Copies another object to this object.
      /// </summary>
      /// <param name="Source">
      /// The source object.
      /// </param>
      {$Endregion}
      Procedure Assign(Source : TPersistent); Override;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets the unique identifier of this object.
      /// </summary>
      {$Endregion}
      Property ID : String Read fID;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets or sets the original (untranslated) value of text string.
      /// </summary>
      {$Endregion}
      Property OriginalValue : String Read fOriginalValue Write SetOriginalValue;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets or sets the translated value of the text string.
      /// </summary>
      {$Endregion}
      Property TranslatedValue : String Read fTranslatedValue Write SetTranslatedValue;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets or sets either the original or translated value of the text string.
      /// </summary>
      {$Endregion}
      Property Value : String Read GetValue Write SetValue;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets whether the text string is a list of null character separated
      /// sub-strings, which represent plural forms of the text.
      /// </summary>
      /// <seealso cref="PluralCount"/>
      /// <seealso cref="Plurals"/>
      {$Endregion}
      Property HasPluralForms : Boolean Read GetHasPluralForms;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets the number of plural forms that the text string have.
      /// </summary>
      /// <seealso cref="HasPluralForms"/>
      /// <seealso cref="Plurals"/>
      {$Endregion}
      Property PluralCount : Integer Read GetPluralCount;
      {$Region 'xmldoc'}
      /// <summary>
      /// Lists the plural forms of the text string.
      /// </summary>
      /// <seealso cref="HasPluralForms"/>
      /// <seealso cref="PluralCount"/>
      {$Endregion}
      Property Plurals[Index : Integer] : String Read GetPlurals Write SetPlurals;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets comments regarding the text string.
      /// </summary>
      {$Endregion}
      Property Comment : String Read fComment Write fComment;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets or sets whether the text string is translated.
      /// </summary>
      {$Endregion}
      Property IsTranslated : Boolean Read fIsTranslated Write SetIsTranslated;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets or sets the integer value that is stored as part of the object.
      /// </summary>
      {$Endregion}
      Property Tag : Integer Read fTag Write fTag;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets the <see cref="TTextItems"/> object that owns this object.
      /// </summary>
      {$Endregion}
      Property Owner : TTextItems Read GetOwnerList;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets the object in the owner <see cref="TTextItems"/> object that is placed
      /// just before this object.
      /// </summary>
      /// <seealso cref="Next"/>
      {$Endregion}
      Property Prev : TTextItem Read GetPrev;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets the object in the owner <see cref="TTextItems"/> object that is placed
      /// just after this object.
      /// </summary>
      /// <seealso cref="Prev"/>
      {$Endregion}
      Property Next : TTextItem Read GetNext;
    End;

  {$Region 'xmldoc'}
  /// <summary>
  /// TTextItems maintains a list of <see cref="TTextItem"/> objects.
  /// </summary>
  {$Endregion}

    TTextItems = Class(TXMLPersistentHashList)
     Private
      Function GetItems(Const ID : String) : TTextItem; Inline;
      Function GetFirst : TTextItem; Inline;
      Function GetLast : TTextItem; Inline;
     Protected
      {$Region 'xmldoc'}
      /// <summary>
      /// Returns the <see cref="TXMLPersistentHashItem"/> class that represents
      /// individual items of the list.
      /// </summary>
      /// <returns>
      /// The <see cref="TXMLPersistentHashItem"/> class or one of its descendants.
      /// </returns>
      {$Endregion}
      Function GetItemClass : THashItemClass; Override;
      {$Region 'xmldoc'}
      /// <summary>
      /// Creates a new item from a specified XML node, and then adds the item to the list.
      /// </summary>
      /// <param name="Node">
      /// The XML node.
      /// </param>
      /// <returns>
      /// The <see cref="TXMLPersistentHashItem"/> object that is newly added to the list.
      /// </returns>
      {$Endregion}
      Function Add(Const Node : IXMLNode) : TXMLPersistentHashItem; Overload; Override;
     Public
      {$Region 'xmldoc'}
      /// <summary>
      /// Removes the translations from all items.
      /// </summary>
      {$Endregion}
      Procedure DiscardTranslations;
      {$Region 'xmldoc'}
      /// <summary>
      /// Copies the text strings that are represented by items of this list to a
      /// <see cref="TStrings"/> object.
      /// </summary>
      /// <param name="Dest">
      /// The target <see cref="TStrings"/> object.
      /// </param>
      {$Endregion}
      Procedure AssignTo(Dest : TPersistent); Override;
      {$Region 'xmldoc'}
      /// <summary>
      /// Loads the list from a specified <see cref="TReader"/> object.
      /// </summary>
      /// <param name="Reader">
      /// The <see cref="TReader"/> object to load items from.
      /// </param>
      /// <seealso cref="Write"/>
      {$Endregion}
      Procedure Read(Reader : TReader);
      {$Region 'xmldoc'}
      /// <summary>
      /// Saves the list to a specified <see cref="TWriter"/> object.
      /// </summary>
      /// <param name="Writer">
      /// The <see cref="TWriter"/> object to save items to.
      /// </param>
      /// <seealso cref="Read"/>
      {$Endregion}
      Procedure Write(Writer : TWriter);
      {$Region 'xmldoc'}
      /// <summary>
      /// Looks for an item with a specified identifier.
      /// </summary>
      /// <param name="ID">
      /// The identifier of the item to find.
      /// </param>
      /// <returns>
      /// Returns the found <see cref="TTextItem"/> object, or <see langword="nil"/>
      /// if the identifier is not found.
      /// </returns>
      {$Endregion}
      Function Find(Const ID : String) : TTextItem; Inline;
      {$Region 'xmldoc'}
      /// <summary>
      /// Creates a new item with a specified identifier and adds it to the list.
      /// </summary>
      /// <param name="ID">
      /// The unique identifier of the new item.
      /// </param>
      /// <returns>
      /// Returns a <see cref="TTextItem"/> object that is either a newly created
      /// object or an already existing object with the specified identifier.
      /// </returns>
      {$Endregion}
      Function Add(Const ID : String) : TTextItem; Overload; Inline;
      {$Region 'xmldoc'}
      /// <summary>
      /// Removes an item with a specified identifier from the list.
      /// </summary>
      /// <param name="ID">
      /// The identifier of the item to remove.
      /// </param>
      /// <returns>
      /// Returns the <see cref="TTextItem"/> that is removed from the list, or
      /// <see langword="nil"/> if the item is not found.
      /// </returns>
      /// <seealso cref="Delete"/>
      {$Endregion}
      Function Extract(Const ID : String) : TTextItem; Inline;
      {$Region 'xmldoc'}
      /// <summary>
      /// Removes an item with a specified identifier from the list and destroys its
      /// object.
      /// </summary>
      /// <param name="ID">
      /// The identifier of the item to remove.
      /// </param>
      /// <returns>
      /// Returns <see langword="true"/> if the item is found, otherwise returns
      /// <see langword="false"/>.
      /// </returns>
      /// <seealso cref="Extract"/>
      {$Endregion}
      Function Delete(Const ID : String) : Boolean; Inline;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets the first item in the list.
      /// </summary>
      {$Endregion}
      Property First : TTextItem Read GetFirst;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets the last item in the list.
      /// </summary>
      {$Endregion}
      Property Last : TTextItem Read GetLast;
      {$Region 'xmldoc'}
      /// <summary>
      /// Provides access to items by their identifier.
      /// </summary>
      {$Endregion}
      Property Items[Const ID : String] : TTextItem Read GetItems; Default;
    End;

  {$Region 'xmldoc'}
  /// <summary>
  /// This enumeration type identifies the options for merging the translation
  /// catalogs.
  /// </summary>
  {$Endregion}

    TMergeOption = (
    {$Region 'xmldoc'}
    /// If an entry exists in both source and target, use the source entry.
    {$Endregion}
    moPreferSource,
    {$Region 'xmldoc'}
    /// If a text domain no longer exists in the source, remove it from the target.
    {$Endregion}
    moDeleteDomainsNotInSource,
    {$Region 'xmldoc'}
    /// If a text definition no longer exists in the source, remove it from the target.
    {$Endregion}
    moDeleteDefinitionsNotInSource
    );

  {$Region 'xmldoc'}
  /// <summary>
  /// This data type represents a set of <see cref="TMergeOption"/> values.
  /// </summary>
  {$Endregion}

    TMergeOptions = Set Of TMergeOption;

  {$Region 'xmldoc'}
  /// <summary>
  /// This enumeration type identifies the options for compacting the translation
  /// catalogs.
  /// </summary>
  {$Endregion}

    TCompactOption = (
    {$Region 'xmldoc'}
    /// Removes developer's comments.
    {$Endregion}
    coDropComments,
    {$Region 'xmldoc'}
    /// Removes translator's notes.
    {$Endregion}
    coDropNotes,
    {$Region 'xmldoc'}
    /// Removes items that do not affect the translation.
    {$Endregion}
    coUsablesOnly
    );

  {$Region 'xmldoc'}
  /// <summary>
  /// This data type represents a set of <see cref="TCompactOption"/> values.
  /// </summary>
  {$Endregion}

    TCompactOptions = Set Of TCompactOption;

  {$Region 'xmldoc'}
  /// <summary>
  /// This enumeration type identifies the possible states of a translation.
  /// </summary>
  {$Endregion}

    TTranslationState = (
    {$Region 'xmldoc'}
    /// The text is not translated.
    {$Endregion}
    tsNone,
    {$Region 'xmldoc'}
    /// The text is somehow translated, but the translation is not approved yet.
    {$Endregion}
    tsFuzzy,
    {$Region 'xmldoc'}
    /// The text is automatically translated by the Google's online translator service.
    {$Endregion}
    tsGoogle,
    {$Region 'xmldoc'}
    /// The text is automatically translated using the knowledge of the past translations.
    {$Endregion}
    tsAuto,
    {$Region 'xmldoc'}
    /// The text is translated and approved by a translator person.
    {$Endregion}
    tsUser
    );

  {$Region 'xmldoc'}
  /// <summary>
  /// This data type represents a set of <see cref="TTranslationState"/> values.
  /// </summary>
  {$Endregion}

    TTranslationStates = Set Of TTranslationState;

  {$Region 'xmldoc'}
  /// <summary>
  /// This data type stores the statistical information about a translation set.
  /// </summary>
  {$Endregion}

    TTranslationStats = Record
     {$Region 'xmldoc'}
     /// The total number of text entries.
     {$Endregion}
     Total : Integer;
     {$Region 'xmldoc'}
     /// The number of text entries for each translation state.
     {$Endregion}
     SubTotal : Array [TTranslationState] Of Integer;
     {$Region 'xmldoc'}
     /// Returns the number of entries with approved translation.
     {$Endregion}
     Function Approved : Integer;
     {$Region 'xmldoc'}
     /// Returns the ratio of approved translations to total entries.
     {$Endregion}
     Function Progress : Double;
    End;

    TTextTranslations = Class;

  {$Region 'xmldoc'}
  /// <summary>
  /// TTextTranslation represents the translation of a text string for a single
  /// language.
  /// </summary>
  /// <remarks>
  /// TTextTranslation stores the translation of a text string along with its state and
  /// translator's comments for a single language.
  /// </remarks>
  /// <seealso cref="TTextTranslations"/>
  /// <seealso cref="TTextDefinition"/>
  {$Endregion}

    TTextTranslation = Class(TXMLPersistentHashItem)
     Private
      fLocale : String;
      fValue  : String;
      fState  : TTranslationState;
      fNote   : String;
      Function GetPluralCount : Integer; Inline;
      Function GetPlurals(Index : Integer) : String; Inline;
      Procedure SetPlurals(Index : Integer; Const PluralForm : String); Inline;
      Function GetOwnerList : TTextTranslations; Inline;
      Function GetPrev : TTextTranslation; Inline;
      Function GetNext : TTextTranslation; Inline;
     Protected
      Const
      {$Region 'xmldoc'}
      /// <summary>
      /// This constant specifies those <see cref="TTranslationState"/> values that
      /// state a translation acceptable.
      /// </summary>
      /// <seealso cref="IsApproved"/>
      {$Endregion}
      AcceptedTranslationStates = [tsUser];
     Protected
      {$Region 'xmldoc'}
      /// <summary>
      /// Returns a unique key that identifies the object.
      /// </summary>
      /// <returns>
      /// Returns the unique key of the item.
      /// </returns>
      {$Endregion}
      Function GetKey : String; Override;
      {$Region 'xmldoc'}
      /// <summary>
      /// Reads properties of the object from an XML node.
      /// </summary>
      /// <param name="Node">
      /// The XML node.
      /// </param>
      /// <seealso cref="Save"/>
      {$Endregion}
      Procedure Load(Const Node : IXMLNode); Override;
      {$Region 'xmldoc'}
      /// <summary>
      /// Writes properties of the object to an XML node.
      /// </summary>
      /// <param name="Node">
      /// The XML node.
      /// </param>
      /// <seealso cref="Load"/>
      {$Endregion}
      Procedure Save(Const Node : IXMLNode); Override;
     Public
      {$Region 'xmldoc'}
      /// <summary>
      /// Creates an instance of the class for a specific locale.
      /// </summary>
      /// <param name="ALocale">
      /// The locale that identifies the instance and specifies the language of the
      /// translation.
      /// </param>
      {$Endregion}
      Constructor Create(Const ALocale : String); Override;
      {$Region 'xmldoc'}
      /// <summary>
      /// Copies another object to this object.
      /// </summary>
      /// <param name="Source">
      /// The source object.
      /// </param>
      {$Endregion}
      Procedure Assign(Source : TPersistent); Override;
      {$Region 'xmldoc'}
      /// <summary>
      /// Copies another object to this object based on the given <paramref name="Options"/>.
      /// </summary>
      /// <param name="Source">
      /// The source object.
      /// </param>
      /// <param name="Options">
      /// Determines how the source object should be copied to this object.
      /// </param>
      /// <seealso cref="Assign"/>
      {$Endregion}
      Procedure Merge(Source : TTextTranslation; Options : TMergeOptions = []);
      {$Region 'xmldoc'}
      /// <summary>
      /// Indicates whether the translation is approved. An approved translation
      /// has <see cref="State"/> of tsUser.
      /// </summary>
      /// <returns>
      /// Returns <see langword="true"/> if the translation is approved, otherwise
      /// returns <see langword="false"/>.
      /// </returns>
      /// <seealso cref="State"/>
      {$Endregion}
      Function IsApproved : Boolean; Inline;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets the locale that identifies the object and determines the language
      /// of the translation.
      /// </summary>
      {$Endregion}
      Property Locale : String Read fLocale;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets or sets the translated text.
      /// </summary>
      {$Endregion}
      Property Value : String Read fValue Write fValue;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets the number of plural forms in the translation.
      /// </summary>
      /// <seealso cref="Plurals"/>
      {$Endregion}
      Property PluralCount : Integer Read GetPluralCount;
      {$Region 'xmldoc'}
      /// <summary>
      /// Lists the plural forms in the translation.
      /// </summary>
      /// <seealso cref="PluralCount"/>
      {$Endregion}
      Property Plurals[Index : Integer] : String Read GetPlurals Write SetPlurals;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets or sets the state of the translation.
      /// </summary>
      {$Endregion}
      Property State : TTranslationState Read fState Write fState;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets or sets the translator's notes regarding the translation.
      /// </summary>
      {$Endregion}
      Property Note : String Read fNote Write fNote;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets the <see cref="TTextTranslations"/> object that owns this object.
      /// </summary>
      {$Endregion}
      Property Owner : TTextTranslations Read GetOwnerList;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets the object in the owner <see cref="TTextTranslations"/> object that is
      /// placed just before this object.
      /// </summary>
      /// <seealso cref="Next"/>
      {$Endregion}
      Property Prev : TTextTranslation Read GetPrev;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets the object in the owner <see cref="TTextTranslations"/> object that is
      /// placed just after this object.
      /// </summary>
      /// <seealso cref="Prev"/>
      {$Endregion}
      Property Next : TTextTranslation Read GetNext;
    End;

    TTextDefinition = Class;

  {$Region 'xmldoc'}
  /// <summary>
  /// TTextItems represents translations of a text string in different languages
  /// by maintaining a list of <see cref="TTextTranslation"/> objects.
  /// </summary>
  {$Endregion}

    TTextTranslations = Class(TXMLPersistentHashList)
     Private
      fDefinition : TTextDefinition;
      Function GetItems(Const Locale : String) : TTextTranslation; Inline;
      Function GetFirst : TTextTranslation; Inline;
      Function GetLast : TTextTranslation; Inline;
     Protected
      {$Region 'xmldoc'}
      /// <summary>
      /// Returns the <see cref="TXMLPersistentHashItem"/> class that represents
      /// individual items of the list.
      /// </summary>
      /// <returns>
      /// The <see cref="TXMLPersistentHashItem"/> class or one of its descendants.
      /// </returns>
      {$Endregion}
      Function GetItemClass : THashItemClass; Override;
      {$Region 'xmldoc'}
      /// <summary>
      /// Creates a new item from a specified XML node, and then adds the item to the list.
      /// </summary>
      /// <param name="Node">
      /// The XML node.
      /// </param>
      /// <returns>
      /// The <see cref="TXMLPersistentHashItem"/> object that is newly added to the list.
      /// </returns>
      {$Endregion}
      Function Add(Const Node : IXMLNode) : TXMLPersistentHashItem; Overload; Override;
     Public
      {$Region 'xmldoc'}
      /// <summary>
      /// Creates an instance of the class for a specified text.
      /// </summary>
      /// <param name="ADefinition">
      /// The <see cref="TTextDefinition"/> object that represents the text in its
      /// original language.
      /// </param>
      {$Endregion}
      Constructor Create(ADefinition : TTextDefinition); Reintroduce;
      {$Region 'xmldoc'}
      /// <summary>
      /// Combines items of another object with items of this object based on the
      /// given options.
      /// </summary>
      /// <param name="Source">
      /// The source object.
      /// </param>
      /// <param name="Options">
      /// Determines how the source object should be combined by this object.
      /// </param>
      /// <seealso cref="Assign"/>
      {$Endregion}
      Procedure Merge(Source : TTextTranslations; Options : TMergeOptions = []);
      {$Region 'xmldoc'}
      /// <summary>
      /// Looks up for an item with a specified locale.
      /// </summary>
      /// <param name="Locale">
      /// The locale of the item to find.
      /// </param>
      /// <returns>
      /// Returns the found <see cref="TTextTranslation"/> object, or <see langword="nil"/>
      /// if the locale is not found.
      /// </returns>
      /// <seealso cref="NearestTo"/>
      {$Endregion}
      Function Find(Const Locale : String) : TTextTranslation; Inline;
      {$Region 'xmldoc'}
      /// <summary>
      /// Creates a new item with a specified locale and adds it to the list.
      /// </summary>
      /// <param name="Locale">
      /// The locale of the new item.
      /// </param>
      /// <returns>
      /// Returns a <see cref="TTextTranslation"/> object that is either a newly created
      /// object or an already existing object with the specified locale.
      /// </returns>
      {$Endregion}
      Function Add(Const Locale : String) : TTextTranslation; Overload; Inline;
      {$Region 'xmldoc'}
      /// <summary>
      /// Removes an item with a specified locale from the list.
      /// </summary>
      /// <param name="Locale">
      /// The locale of the item to remove.
      /// </param>
      /// <returns>
      /// Returns the <see cref="TTextTranslation"/> that is removed from the list,
      /// or <see langword="nil"/> if the item is not found.
      /// </returns>
      /// <seealso cref="Delete"/>
      {$Endregion}
      Function Extract(Const Locale : String) : TTextTranslation; Inline;
      {$Region 'xmldoc'}
      /// <summary>
      /// Removes an item with a specified locale from the list and destroys its
      /// object.
      /// </summary>
      /// <param name="Locale">
      /// The locale of the item to remove.
      /// </param>
      /// <returns>
      /// Returns <see langword="true"/> if the item is found, otherwise returns
      /// <see langword="false"/>.
      /// </returns>
      /// <seealso cref="Extract"/>
      {$Endregion}
      Function Delete(Const Locale : String) : Boolean; Inline;
      {$Region 'xmldoc'}
      /// <summary>
      /// Looks up for an item with the nearest language match to a specified locale.
      /// </summary>
      /// <param name="Locale">
      /// The locale to look for.
      /// </param>
      /// <returns>
      /// Returns the matched <see cref="TTextTranslation"/> object, or <see langword="nil"/>
      /// if no match is found.
      /// </returns>
      /// <seealso cref="Find"/>
      {$Endregion}
      Function NearestTo(Const Locale : String) : TTextTranslation;
      {$Region 'xmldoc'}
      /// <summary>
      /// Sets state of all translations to fuzzy.
      /// </summary>
      {$Endregion}
      Procedure DisapproveAll;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets the <see cref="TTextDefinition"/> object that represents the original
      /// text of this set of translations.
      /// </summary>
      {$Endregion}
      Property Definition : TTextDefinition Read fDefinition;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets the item on top of the list.
      /// </summary>
      {$Endregion}
      Property First : TTextTranslation Read GetFirst;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets the item on bottom of the list.
      /// </summary>
      {$Endregion}
      Property Last : TTextTranslation Read GetLast;
      {$Region 'xmldoc'}
      /// <summary>
      /// Lists the items with their locale.
      /// </summary>
      {$Endregion}
      Property Items[Const Locale : String] : TTextTranslation Read GetItems; Default;
    End;

    TTextDictionary = Class;

  {$Region 'xmldoc'}
  /// <summary>
  /// TTextDefinition represents a text string and its translations.
  /// </summary>
  /// <remarks>
  /// TTextDefinition stores a text string along with its comments and translations
  /// for different languages.
  /// </remarks>
  /// <seealso cref="TTextTranslation"/>
  /// <seealso cref="TTextDictionary"/>
  {$Endregion}

    TTextDefinition = Class(TXMLPersistentHashItem)
     Private
      fID           : String;
      fComment      : String;
      fValue        : String;
      fTranslations : TTextTranslations;
      Function GetLocale : String;
      Function GetHasPluralForms : Boolean; Inline;
      Function GetPluralCount : Integer; Inline;
      Function GetPlurals(Index : Integer) : String; Inline;
      Procedure SetPlurals(Index : Integer; Const PluralForm : String); Inline;
      Function GetDictionary : TTextDictionary; Inline;
      Function GetPrev : TTextDefinition; Inline;
      Function GetNext : TTextDefinition; Inline;
     Protected
      {$Region 'xmldoc'}
      /// <summary>
      /// Returns a unique key that identifies the object.
      /// </summary>
      /// <returns>
      /// Returns the unique key of the item.
      /// </returns>
      {$Endregion}
      Function GetKey : String; Override;
      {$Region 'xmldoc'}
      /// <summary>
      /// Reads properties of the object from an XML node.
      /// </summary>
      /// <param name="Node">
      /// The XML node.
      /// </param>
      /// <seealso cref="Save"/>
      {$Endregion}
      Procedure Load(Const Node : IXMLNode); Override;
      {$Region 'xmldoc'}
      /// <summary>
      /// Writes properties of the object to an XML node.
      /// </summary>
      /// <param name="Node">
      /// The XML node.
      /// </param>
      /// <seealso cref="Load"/>
      {$Endregion}
      Procedure Save(Const Node : IXMLNode); Override;
     Public
      {$Region 'xmldoc'}
      /// <summary>
      /// Creates an instance of the class.
      /// </summary>
      /// <param name="AID">
      /// The unique identifier of the instance.
      /// </param>
      {$Endregion}
      Constructor Create(Const AID : String); Override;
      {$Region 'xmldoc'}
      /// <summary>
      /// Destroys the instance and releases its allocated memory.
      /// </summary>
      {$Endregion}
      Destructor Destroy; Override;
      {$Region 'xmldoc'}
      /// <summary>
      /// Copies another object to this object.
      /// </summary>
      /// <param name="Source">
      /// The source object.
      /// </param>
      /// <seealso cref="Merge"/>
      {$Endregion}
      Procedure Assign(Source : TPersistent); Override;
      {$Region 'xmldoc'}
      /// <summary>
      /// Combines another object with this object based on the given <paramref name="Options"/>.
      /// </summary>
      /// <param name="Source">
      /// The source object.
      /// </param>
      /// <param name="Options">
      /// Determines how the source object should be combined by this object.
      /// </param>
      /// <seealso cref="Assign"/>
      {$Endregion}
      Procedure Merge(Source : TTextDefinition; Options : TMergeOptions = []);
      {$Region 'xmldoc'}
      /// <summary>
      /// Updates this object with the information provided by a <see cref="TTextItem"/>
      /// object.
      /// </summary>
      /// <param name="Source">
      /// The source <see cref="TTextItem"/> object.
      /// </param>
      {$Endregion}
      Procedure Revise(Source : TTextItem); Overload;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets the unique identifier of this object.
      /// </summary>
      {$Endregion}
      Property ID : String Read fID;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets the locale of the original language of the text string.
      /// </summary>
      {$Endregion}
      Property Locale : String Read GetLocale;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets or sets the original value of the text string.
      /// </summary>
      {$Endregion}
      Property Value : String Read fValue Write fValue;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets whether the text string is a list of null character separated
      /// sub-strings, which represent plural forms of the text.
      /// </summary>
      /// <seealso cref="PluralCount"/>
      /// <seealso cref="Plurals"/>
      {$Endregion}
      Property HasPluralForms : Boolean Read GetHasPluralForms;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets the number of plural forms that the text string have.
      /// </summary>
      /// <seealso cref="HasPluralForms"/>
      /// <seealso cref="Plurals"/>
      {$Endregion}
      Property PluralCount : Integer Read GetPluralCount;
      {$Region 'xmldoc'}
      /// <summary>
      /// Lists the plural forms of the text string.
      /// </summary>
      /// <seealso cref="HasPluralForms"/>
      /// <seealso cref="PluralCount"/>
      {$Endregion}
      Property Plurals[Index : Integer] : String Read GetPlurals Write SetPlurals;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets the translations of the text string.
      /// </summary>
      {$Endregion}
      Property Translations : TTextTranslations Read fTranslations;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets comments regarding the text string.
      /// </summary>
      {$Endregion}
      Property Comment : String Read fComment Write fComment;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets the <see cref="TTextDictionary"/> object that owns this object.
      /// </summary>
      {$Endregion}
      Property Dictionary : TTextDictionary Read GetDictionary;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets the object in the owner <see cref="TTextDefinition"/> object that is
      /// placed just before this object.
      /// </summary>
      /// <seealso cref="Next"/>
      {$Endregion}
      Property Prev : TTextDefinition Read GetPrev;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets the object in the owner <see cref="TTextDefinition"/> object that is
      /// placed just after this object.
      /// </summary>
      /// <seealso cref="Prev"/>
      {$Endregion}
      Property Next : TTextDefinition Read GetNext;
    End;

    TTextDomain = Class;

  {$Region 'xmldoc'}
  /// <summary>
  /// This enumeration type identifies the different kinds of usage for
  /// <see cref="TTextDictionary"/> objects.
  /// </summary>
  {$Endregion}

    TTextDitionaryKind = (
    {$Region 'xmldoc'}
    /// The <see cref="TTextDictionary"/> object contains information regarding
    /// properties.
    {$Endregion}
    dkProperty,
    {$Region 'xmldoc'}
    /// The <see cref="TTextDictionary"/> object contains information regarding
    /// string literals and string constants.
    {$Endregion}
    dkLiteral
    );

  {$Region 'xmldoc'}
  /// <summary>
  /// TTextDictionary maintains a list of <see cref="TTextDefinition"/> objects.
  /// </summary>
  {$Endregion}

    TTextDictionary = Class(TXMLPersistentHashList)
     Private
      fTextDomain : TTextDomain;
      fKind       : TTextDitionaryKind;
      Function GetItems(Const ID : String) : TTextDefinition; Inline;
      Function GetFirst : TTextDefinition; Inline;
      Function GetLast : TTextDefinition; Inline;
     Protected
      Const
      {$Region 'xmldoc'}
      /// <summary>
      /// This constant specifies the maximum percentage of changes in a string, so
      /// that the new string still can be expressed as a modified version of the
      /// original one.
      /// </summary>
      /// <seealso cref="Merge"/>
      /// <seealso cref="Revise"/>
      {$Endregion}
      AcceptedSimilarityRatio = 0.80;
     Protected
      {$Region 'xmldoc'}
      /// <summary>
      /// Returns the <see cref="TXMLPersistentHashItem"/> class that represents
      /// individual items of the list.
      /// </summary>
      /// <returns>
      /// The <see cref="TXMLPersistentHashItem"/> class or one of its descendants.
      /// </returns>
      {$Endregion}
      Function GetItemClass : THashItemClass; Override;
      {$Region 'xmldoc'}
      /// <summary>
      /// Creates a new item from a specified XML node, and then adds the item to the list.
      /// </summary>
      /// <param name="Node">
      /// The XML node.
      /// </param>
      /// <returns>
      /// The <see cref="TXMLPersistentHashItem"/> object that is newly added to the list.
      /// </returns>
      {$Endregion}
      Function Add(Const Node : IXMLNode) : TXMLPersistentHashItem; Overload; Override;
     Public
      {$Region 'xmldoc'}
      /// <summary>
      /// Creates an instance of the object.
      /// </summary>
      /// <param name="ATextDomain">
      /// The <see cref="TTextDomain"/> object that owns this object.
      /// </param>
      /// <param name="AKind">
      /// Determines whether the object provides information about property or
      /// litral strings.
      /// </param>
      {$Endregion}
      Constructor Create(ATextDomain : TTextDomain; AKind : TTextDitionaryKind); Reintroduce;
      {$Region 'xmldoc'}
      /// <summary>
      /// Copies another object to this object.
      /// </summary>
      /// <param name="Source">
      /// The source object.
      /// </param>
      /// <seealso cref="Merge"/>
      {$Endregion}
      Procedure Assign(Source : TPersistent); Override;
      {$Region 'xmldoc'}
      /// <summary>
      /// Combines items of another object with items of this object based on the
      /// given options.
      /// </summary>
      /// <param name="Source">
      /// The source object.
      /// </param>
      /// <param name="Options">
      /// Determines how the source object should be combined by this object.
      /// </param>
      /// <seealso cref="Assign"/>
      {$Endregion}
      Procedure Merge(Source : TTextDictionary; Options : TMergeOptions = []);
      {$Region 'xmldoc'}
      /// <summary>
      /// Updates this object with the information provided by a <see cref="TTextItems"/>
      /// object.
      /// </summary>
      /// <param name="Source">
      /// The source <see cref="TTextItems"/> object.
      /// </param>
      /// <param name="KeepRemovedEntries">
      /// Indicates whether to keep the entries that are not in the source.
      /// </param>
      {$Endregion}
      Procedure Revise(Source : TTextItems; KeepRemovedEntries : Boolean);
      {$Region 'xmldoc'}
      /// <summary>
      /// Looks up for an item with a specified identifier.
      /// </summary>
      /// <param name="ID">
      /// The identifier of the item to find.
      /// </param>
      /// <returns>
      /// Returns the found <see cref="TTextDefinition"/> object, or <see langword="nil"/>
      /// if the identifier is not found.
      /// </returns>
      {$Endregion}
      Function Find(Const ID : String) : TTextDefinition; Inline;
      {$Region 'xmldoc'}
      /// <summary>
      /// Creates a new item with a specified identifier and adds it to the list.
      /// </summary>
      /// <param name="ID">
      /// The unique identifier of the new item.
      /// </param>
      /// <returns>
      /// Returns a <see cref="TTextDefinition"/> object that is either a newly created
      /// object or an already existing object with the specified identifier.
      /// </returns>
      {$Endregion}
      Function Add(Const ID : String) : TTextDefinition; Overload; Inline;
      {$Region 'xmldoc'}
      /// <summary>
      /// Removes an item with a specified identifier from the list.
      /// </summary>
      /// <param name="ID">
      /// The identifier of the item to remove.
      /// </param>
      /// <returns>
      /// Returns the <see cref="TTextDefinition"/> that is removed from the list,
      /// or <see langword="nil"/> if the item is not found.
      /// </returns>
      /// <seealso cref="Delete"/>
      {$Endregion}
      Function Extract(Const ID : String) : TTextDefinition; Inline;
      {$Region 'xmldoc'}
      /// <summary>
      /// Removes an item with a specified identifier from the list and destroys its
      /// object.
      /// </summary>
      /// <param name="ID">
      /// The identifier of the item to remove.
      /// </param>
      /// <returns>
      /// Returns <see langword="true"/> if the item is found, otherwise returns
      /// <see langword="false"/>.
      /// </returns>
      /// <seealso cref="Extract"/>
      {$Endregion}
      Function Delete(Const ID : String) : Boolean; Inline;
      {$Region 'xmldoc'}
      /// <summary>
      /// Tries to reduce memory usage of items by purging unwanted information.
      /// </summary>
      /// <param name="Options">
      /// Determines how to compact the object.
      /// </param>
      {$Endregion}
      Procedure Compact(Options : TCompactOptions);
      {$Region 'xmldoc'}
      /// <summary>
      /// Copies the translation in a specified language to the original definition, for
      /// all the items.
      /// NOTE: Do not call this method directly.
      /// </summary>
      /// <param name="Locale">
      /// The locale that specifies the language of the source translation.
      /// </param>
      /// <returns>
      /// Returns <see langword="true"/> if all the items has an acceptable translation
      /// for the specified locale. Otherwise, returns <see langword="false"/>.
      /// </returns>
      /// <seealso cref="OrigialToTranslation"/>
      {$Endregion}
      Function TranslationToOriginal(Const Locale : String) : Boolean;
      {$Region 'xmldoc'}
      /// <summary>
      /// Copies the original definition to the translation in a specified language, for
      /// all the items.
      /// NOTE: Do not call this method directly.
      /// </summary>
      /// <param name="Locale">
      /// The locale that specifies the language of the target translation.
      /// </param>
      /// <seealso cref="TranslationToOriginal"/>
      {$Endregion}
      Procedure OrigialToTranslation(Const Locale : String);
      {$Region 'xmldoc'}
      /// <summary>
      /// Adds a translation entry for a specified locale to all the items.
      /// </summary>
      /// <param name="Locale">
      /// The locale that specifies the language of the translation entry.
      /// </param>
      /// <seealso cref="Undefine"/>
      {$Endregion}
      Procedure Define(Const Locale : String);
      {$Region 'xmldoc'}
      /// <summary>
      /// Remove the translation entry for a specified locale from all the items.
      /// </summary>
      /// <param name="Locale">
      /// The locale that specifies the language of the translation entry.
      /// </param>
      /// <seealso cref="Define"/>
      {$Endregion}
      Procedure Undefine(Const Locale : String);
      {$Region 'xmldoc'}
      /// <summary>
      /// Retrieves the list of languages that the items have a translation entry
      /// for them.
      /// </summary>
      /// <param name="Dest">
      /// The list that saves the translation languages as <see cref="TCultureInfo"/>
      /// objects.
      /// </param>
      {$Endregion}
      Procedure RetrieveCultures(Dest : TCultureList);
      {$Region 'xmldoc'}
      /// <summary>
      /// Retrieves the statistical information about the translation entries of a
      /// specific language.
      /// </summary>
      /// <param name="Locale">
      /// The locale that determines the entries in interest.
      /// </param>
      /// <param name="Stats">
      /// The <see cref="TTranslationStats"/> records that represents the result.
      /// This fields of this record must be initialized.
      /// </param>
      {$Endregion}
      Procedure UpdateStats(Const Locale : String; Var Stats : TTranslationStats);
      {$Region 'xmldoc'}
      /// <summary>
      /// Finds the translation entry for a specific item in a specific language.
      /// </summary>
      /// <param name="ID">
      /// The unique identifier of the item.
      /// </param>
      /// <param name="Locale">
      /// The locale of the translation entry.
      /// </param>
      /// <returns>
      /// Returns the found <see cref="TTextTranslation"/> object or <see langword="nil"/>
      /// if the translation is not found.
      /// </returns>
      /// <seealso cref="Translate"/>
      {$Endregion}
      Function TranslationOf(Const ID, Locale : String) : TTextTranslation;
      {$Region 'xmldoc'}
      /// <summary>
      /// Uses this object's information to translate a list of text strings given
      /// by <paramref name="TextItems"/> into a specified language.
      /// </summary>
      /// <param name="TextItems">
      /// The text items to translate.
      /// </param>
      /// <param name="Locale">
      /// The locale that specifies the target translation language.
      /// </param>
      /// <seealso cref="TranslationOf"/>
      {$Endregion}
      Procedure Translate(TextItems : TTextItems; Locale : String);
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets the <see cref="TextDomain"/> object that owns this object.
      /// </summary>
      {$Endregion}
      Property TextDomain : TTextDomain Read fTextDomain;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets whether the items of the list represent translatable properties or
      /// translatable string literals.
      /// </summary>
      {$Endregion}
      Property Kind : TTextDitionaryKind Read fKind;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets the item on top of the list.
      /// </summary>
      {$Endregion}
      Property First : TTextDefinition Read GetFirst;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets the item on bottom of the list.
      /// </summary>
      {$Endregion}
      Property Last : TTextDefinition Read GetLast;
      {$Region 'xmldoc'}
      /// <summary>
      /// Lists the items with their identifier.
      /// </summary>
      {$Endregion}
      Property Items[Const ID : String] : TTextDefinition Read GetItems; Default;
    End;

    TTextDomains = Class;

  {$Region 'xmldoc'}
  /// <summary>
  /// TTextDomain represents a set of translatable strings in a translation catalog.
  /// </summary>
  /// <remarks>
  /// <para>
  /// TTextDomain maintains two lists of translatable strings, one for properties
  /// and another for string literals. These strings are usually used within the same
  /// Pascal unit.
  /// </para>
  /// </remarks>
  /// <seealso cref="TTextDomains"/>
  /// <seealso cref="TTranslationCatalog"/>
  {$Endregion}

    TTextDomain = Class(TXMLPersistentHashItem)
     Private
      fName       : String;
      fProperties : TTextDictionary;
      fLiterals   : TTextDictionary;
      Function GetOwnerList : TTextDomains; Inline;
      Function GetPrev : TTextDomain; Inline;
      Function GetNext : TTextDomain; Inline;
     Protected
      {$Region 'xmldoc'}
      /// <summary>
      /// Returns a unique key that identifies the object.
      /// </summary>
      /// <returns>
      /// Returns the unique key of the item.
      /// </returns>
      {$Endregion}
      Function GetKey : String; Override;
      {$Region 'xmldoc'}
      /// <summary>
      /// Reads properties of the object from an XML node.
      /// </summary>
      /// <param name="Node">
      /// The XML node.
      /// </param>
      /// <seealso cref="Save"/>
      {$Endregion}
      Procedure Load(Const Node : IXMLNode); Override;
      {$Region 'xmldoc'}
      /// <summary>
      /// Writes properties of the object to an XML node.
      /// </summary>
      /// <param name="Node">
      /// The XML node.
      /// </param>
      /// <seealso cref="Load"/>
      {$Endregion}
      Procedure Save(Const Node : IXMLNode); Override;
     Public
      {$Region 'xmldoc'}
      /// <summary>
      /// Creates an instance of a class.
      /// </summary>
      /// <param name="AName">
      /// The unique name of the instance.
      /// </param>
      {$Endregion}
      Constructor Create(Const AName : String); Override;
      {$Region 'xmldoc'}
      /// <summary>
      /// Destroys the instance and releases its allocated memory.
      /// </summary>
      {$Endregion}
      Destructor Destroy; Override;
      {$Region 'xmldoc'}
      /// <summary>
      /// Copies another object to this object.
      /// </summary>
      /// <param name="Source">
      /// The source object.
      /// </param>
      {$Endregion}
      Procedure Assign(Source : TPersistent); Override;
      {$Region 'xmldoc'}
      /// <summary>
      /// Copies another object to this object based on the given <paramref name="Options"/>.
      /// </summary>
      /// <param name="Source">
      /// The source object.
      /// </param>
      /// <param name="Options">
      /// Determines how the source object should be copied to this object.
      /// </param>
      /// <seealso cref="Assign"/>
      {$Endregion}
      Procedure Merge(Source : TTextDomain; Options : TMergeOptions = []);
      {$Region 'xmldoc'}
      /// <summary>
      /// Retrieves the statistical information about the translations in a specific
      /// language.
      /// </summary>
      /// <param name="Locale">
      /// The locale that determines the language in interest.
      /// </param>
      /// <returns>
      /// Returns a <see cref="TTranslationStats"/> record.
      /// </returns>
      {$Endregion}
      Function StatsOf(Const Locale : String) : TTranslationStats;
      {$Region 'xmldoc'}
      /// <summary>
      /// Retrieves the name of components that have translatable property in this domain.
      /// </summary>
      /// <param name="dstList">
      /// The <see cref="TStrings"/> object that receives the name of components.
      /// </param>
      /// <seealso cref="HasComponent"/>
      /// <seealso cref="DeleteComponent"/>
      /// <seealso cref="RenameComponent"/>
      {$Endregion}
      Procedure GetComponents(dstList : TStrings);
      {$Region 'xmldoc'}
      /// <summary>
      /// Indicates whether a component has a translatable property in this domain.
      /// </summary>
      /// <param name="ComponentName">
      /// The name of component to examine.
      /// </param>
      /// <returns>
      /// Returns <see langword="true"/> if the component has a translatable property
      /// in this domain. Otherwise, returns <see langword="false"/>.
      /// </returns>
      /// <seealso cref="GetComponents"/>
      /// <seealso cref="DeleteComponent"/>
      /// <seealso cref="RenameComponent"/>
      {$Endregion}
      Function HasComponent(Const ComponentName : String) : Boolean;
      {$Region 'xmldoc'}
      /// <summary>
      /// Removes properties of a specified component from this domain.
      /// </summary>
      /// <param name="ComponentName">
      /// The name of component to remove its properties.
      /// </param>
      /// <returns>
      /// Returns <see langword="true"/> if the component had a translatable property
      /// in this domain. Otherwise, returns <see langword="false"/>.
      /// </returns>
      /// <seealso cref="HasComponent"/>
      /// <seealso cref="GetComponents"/>
      /// <seealso cref="RenameComponent"/>
      {$Endregion}
      Function DeleteComponent(Const ComponentName : String) : Boolean;
      {$Region 'xmldoc'}
      /// <summary>
      /// Updates path of properties in the domain for a specified component to reflect
      /// the new name of the component.
      /// </summary>
      /// <param name="ComponentName">
      /// The old name of the component.
      /// </param>
      /// <param name="NewComponentName">
      /// The new name of the component. This name must be a valid Pascal identifier
      /// and the domain must not have already a property for the new component name.
      /// </param>
      /// <returns>
      /// Returns <see langword="true"/> if the component renamed successfully. Otherwise,
      /// returns <see langword="false"/>.
      /// </returns>
      /// <seealso cref="Rename"/>
      /// <seealso cref="HasComponent"/>
      /// <seealso cref="GetComponents"/>
      /// <seealso cref="DeleteComponent"/>
      {$Endregion}
      Function RenameComponent(Const ComponentName, NewComponentName : String) : Boolean;
      {$Region 'xmldoc'}
      /// <summary>
      /// <para>
      /// Changes the unique name of the domain.
      /// </para>
      /// <para>
      /// NOTE: This method destroys the current instance and creates a new one. Therefore,
      /// after calling this method, any access to the old object raises an AV exception.
      /// </para>
      /// </summary>
      /// <param name="NewName">
      /// The new name of the domain. This name must be a valid Pascal identifier and
      /// the <see cref="Owner"/> object must not have already a domain with this name.
      /// </param>
      /// <returns>
      /// Returns the <see cref="TTextDomain"/> object with the new name, or <see langword="nil"/>
      /// if the rename is not possible.
      /// </returns>
      /// <seealso cref="RenameComponent"/>
      {$Endregion}
      Function Rename(Const NewName : String) : TTextDomain;
      {$Region 'xmldoc'}
      /// <summary>
      /// Indicates whether the domain maintains any translatable string.
      /// </summary>
      /// <returns>
      /// Returns <see langword="true"/> if the domain has any translatable string,
      /// otherwise returns <see langword="false"/>.
      /// </returns>
      {$Endregion}
      Function Empty : Boolean; Inline;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets the unique name of the domain.
      /// </summary>
      {$Endregion}
      Property Name : String Read fName;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets the translatable properties in the domain.
      /// </summary>
      {$Endregion}
      Property Properties : TTextDictionary Read fProperties;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets the translatable string literals in the domain.
      /// </summary>
      {$Endregion}
      Property Literals : TTextDictionary Read fLiterals;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets the <see cref="TTextDomains"/> object that owns this domain.
      /// </summary>
      {$Endregion}
      Property Owner : TTextDomains Read GetOwnerList;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets the domain in the owner <see cref="TTextDomains"/> object that is placed
      /// just before this domain.
      /// </summary>
      /// <seealso cref="Next"/>
      {$Endregion}
      Property Prev : TTextDomain Read GetPrev;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets the domain in the owner <see cref="TTextDomains"/> object that is placed
      /// just after this domain.
      /// </summary>
      /// <seealso cref="Prev"/>
      {$Endregion}
      Property Next : TTextDomain Read GetNext;
    End;

    TTranslationCatalog = Class;

  {$Region 'xmldoc'}
  /// <summary>
  /// TTextDomains maintains a list of <see cref="TTextDomain"/> objects.
  /// </summary>
  {$Endregion}

    TTextDomains = Class(TXMLPersistentHashList)
     Private
      fCatalog : TTranslationCatalog;
      Function GetItems(Const Name : String) : TTextDomain;
      Function GetFirst : TTextDomain; Inline;
      Function GetLast : TTextDomain; Inline;
     Protected
      {$Region 'xmldoc'}
      /// <summary>
      /// Returns the <see cref="TXMLPersistentHashItem"/> class that represents
      /// individual items of the list.
      /// </summary>
      /// <returns>
      /// The <see cref="TXMLPersistentHashItem"/> class or one of its descendants.
      /// </returns>
      {$Endregion}
      Function GetItemClass : THashItemClass; Override;
      {$Region 'xmldoc'}
      /// <summary>
      /// Creates a new item from a specified XML node, and then adds the item to the list.
      /// </summary>
      /// <param name="Node">
      /// The XML node.
      /// </param>
      /// <returns>
      /// The <see cref="TXMLPersistentHashItem"/> object that is newly added to the list.
      /// </returns>
      {$Endregion}
      Function Add(Const Node : IXMLNode) : TXMLPersistentHashItem; Overload; Override;
     Public
      {$Region 'xmldoc'}
      /// <summary>
      /// Creates an instance of the class.
      /// </summary>
      /// <param name="ACatalog">
      /// The translation catalog that owns the domains.
      /// </param>
      {$Endregion}
      Constructor Create(ACatalog : TTranslationCatalog); Reintroduce;
      {$Region 'xmldoc'}
      /// <summary>
      /// Copies another object to this object based on the given <paramref name="Options"/>.
      /// </summary>
      /// <param name="Source">
      /// The source object.
      /// </param>
      /// <param name="Options">
      /// Determines how the source object should be copied to this object.
      /// </param>
      /// <seealso cref="Assign"/>
      {$Endregion}
      Procedure Merge(Source : TTextDomains; Options : TMergeOptions = []);
      {$Region 'xmldoc'}
      /// <summary>
      /// Looks up for a domain with a specified name.
      /// </summary>
      /// <param name="Name">
      /// The name of the domain to find.
      /// </param>
      /// <returns>
      /// Returns the found <see cref="TTextDomain"/> object, or <see langword="nil"/>
      /// if the name is not found.
      /// </returns>
      {$Endregion}
      Function Find(Const Name : String) : TTextDomain; Inline;
      {$Region 'xmldoc'}
      /// <summary>
      /// Creates a new domain with a specified name and adds it to the list.
      /// </summary>
      /// <param name="Name">
      /// The name of the new domain.
      /// </param>
      /// <returns>
      /// Returns a <see cref="TTextDomain"/> object that is either a newly created
      /// domain or an already existing domain with the specified name.
      /// </returns>
      {$Endregion}
      Function Add(Const Name : String) : TTextDomain; Overload; Inline;
      {$Region 'xmldoc'}
      /// <summary>
      /// Removes a domain with a specified name from the list.
      /// </summary>
      /// <param name="Name">
      /// The name of the domain to remove.
      /// </param>
      /// <returns>
      /// Returns the <see cref="TTextDomain"/> that is removed from the list, or
      /// <see langword="nil"/> if the domain is not found.
      /// </returns>
      /// <seealso cref="Delete"/>
      {$Endregion}
      Function Extract(Const Name : String) : TTextDomain; Inline;
      {$Region 'xmldoc'}
      /// <summary>
      /// Removes a domain with a specified name from the list and destroys its object.
      /// </summary>
      /// <param name="Name">
      /// The name of the domain to remove.
      /// </param>
      /// <returns>
      /// Returns <see langword="true"/> if the item is found, otherwise returns
      /// <see langword="false"/>.
      /// </returns>
      /// <seealso cref="Extract"/>
      {$Endregion}
      Function Delete(Const Name : String) : Boolean; Inline;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets the translation catalog that owns this domains.
      /// </summary>
      {$Endregion}
      Property Catalog : TTranslationCatalog Read fCatalog;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets the domain in top of the list.
      /// </summary>
      {$Endregion}
      Property First : TTextDomain Read GetFirst;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets the domain in bottom of the list.
      /// </summary>
      {$Endregion}
      Property Last : TTextDomain Read GetLast;
      {$Region 'xmldoc'}
      /// <summary>
      /// Lists the domains by their names.
      /// </summary>
      {$Endregion}
      Property Items[Const Name : String] : TTextDomain Read GetItems; Default;
    End;

    TTranslationRepository = Class;

  {$Region 'xmldoc'}
  /// <summary>
  /// TTranslationCatalog represents a translation catalog, which contains information
  /// to translate strings of an application.
  /// </summary>
  /// <remarks>
  /// TTranslationCatalog stores information about a translation set. This information
  /// includes original and translated strings, available translation languages, and
  /// plural forms of the languages. Usually each application uses only one translation
  /// catalog.
  /// </remarks>
  {$Endregion}

    TTranslationCatalog = Class(TPersistent)
     Private
      fNativeCulture     : TCultureInfo;
      fCultures          : TCultureList;
      fTextDomains       : TTextDomains;
      fCustomPluralRules : TKeyLookup<TCultureInfo, String>;
      fCompressed        : Boolean;
      fUpdateCount       : Integer;
      fRepository        : TTranslationRepository;
      Function GetCultures : TReadonlyCultureList; Inline;
      Procedure SetNativeCulture(Value : TCultureInfo);
     Protected
      {$Region 'xmldoc'}
      /// <summary>
      /// Ensures all text definitions in all text domains have the same set of
      /// translation entries. It also deletes empty text domains.
      /// </summary>
      {$Endregion}
      Procedure NormalizeTranslations;
      {$Region 'xmldoc'}
      /// <summary>
      /// Ensures the <see cref="Cultures"/> property lists all all the available
      /// translation languages.
      /// </summary>
      {$Endregion}
      Procedure NormalizeCultures;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gives access to the custom rules of plural forms for the translation languages.
      /// </summary>
      {$Endregion}
      Property CustomPluralRules : TKeyLookup < TCultureInfo, String > Read fCustomPluralRules;
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
      /// Indicates whether the translation catalog contains any information.
      /// </summary>
      /// <returns>
      /// returns <see langword="true"/> if the translation catalog is empty, otherwise
      /// returns <see langword="false"/>.
      /// </returns>
      {$Endregion}
      Function Empty : Boolean; Inline;
      {$Region 'xmldoc'}
      /// <summary>
      /// Clears all the translation catalog.
      /// </summary>
      {$Endregion}
      Procedure Clear;
      {$Region 'xmldoc'}
      /// <summary>
      /// Prevents rearranging and normalizing content until the <see cref="EndUpdate"/>
      /// method is called.
      /// </summary>
      /// <seealso cref="EndUpdate"/>
      {$Endregion}
      Procedure BeginUpdate;
      {$Region 'xmldoc'}
      /// <summary>
      /// Reenables rearranging and normalizing content that was turned off with the
      /// <see cref="BeginUpdate"/> method.
      /// </summary>
      /// <seealso cref="BeginUpdate"/>
      {$Endregion}
      Procedure EndUpdate;
      {$Region 'xmldoc'}
      /// <summary>
      /// Removes unwanted information from the translation catalog.
      /// </summary>
      /// <param name="Options">
      /// Specifies which content should be purged and which one should be kept.
      /// </param>
      {$Endregion}
      Procedure Compact(Options : TCompactOptions);
      {$Region 'xmldoc'}
      /// <summary>
      /// Adds a new language to the translation catalog.
      /// </summary>
      /// <param name="Culture">
      /// The <see cref="TCultureInfo"/> object that represents the new language.
      /// </param>
      {$Endregion}
      Procedure Add(Culture : TCultureInfo);
      {$Region 'xmldoc'}
      /// <summary>
      /// Deletes a translation language and all of its related information from the
      /// translation catalog.
      /// </summary>
      /// <param name="Culture">
      /// The <see cref="TCultureInfo"/> object that represents the language to delete.
      /// </param>
      /// <returns>
      /// Returns <see langword="true"/> if the language was in the list of available
      /// translation languages, and removed. Otherwise, returns <see langword="false"/>.
      /// </returns>
      {$Endregion}
      Function Remove(Culture : TCultureInfo) : Boolean;
      {$Region 'xmldoc'}
      /// <summary>
      /// Copies another translation catalog to this one.
      /// </summary>
      /// <param name="Source">
      /// The source object.
      /// </param>
      {$Endregion}
      Procedure Assign(Source : TPersistent); Override;
      {$Region 'xmldoc'}
      /// <summary>
      /// Combines another translation catalog with this one based on the given
      /// <paramref name="Options"/>.
      /// </summary>
      /// <param name="Source">
      /// The source translation catalog.
      /// </param>
      /// <param name="Options">
      /// Determines how the two catalogs should be merged.
      /// </param>
      /// <seealso cref="Assign"/>
      {$Endregion}
      Procedure Merge(Source : TTranslationCatalog; Options : TMergeOptions = []);
      {$Region 'xmldoc'}
      /// <summary>
      /// Retrieves the statistical information about the translations in a specific
      /// language.
      /// </summary>
      /// <param name="Locale">
      /// The <see cref="TCultureInfo"/> object that represents the language in
      /// interest.
      /// </param>
      /// <returns>
      /// Returns a <see cref="TTranslationStats"/> record.
      /// </returns>
      {$Endregion}
      Function StatsOf(Culture : TCultureInfo) : TTranslationStats;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets the rule for the plural forms of a specific translation language.
      /// </summary>
      /// <param name="Culture">
      /// The <see cref="TCultureInfo"/> object that represents the language in
      /// interest.
      /// </param>
      /// <returns>
      /// The rule of plural forms of the language as a steing.
      /// </returns>
      /// <seealso cref="ChangePluralRuleOf"/>
      /// <seealso cref="TPluralForms.Rule"/>
      {$Endregion}
      Function PluralRuleOf(Culture : TCultureInfo) : String;
      {$Region 'xmldoc'}
      /// <summary>
      /// Sets a new rule for the plural forms of a specific translation language.
      /// NOTE: This method does not validate the plural rule.
      /// </summary>
      /// <param name="Culture">
      /// The <see cref="TCultureInfo"/> object that represents the language in
      /// interest.
      /// </param>
      /// <param name="PluralRule">
      /// The rule of plural forms of the language as a steing.
      /// </param>
      /// <seealso cref="PluralRuleOf"/>
      /// <seealso cref="TPluralForms.Rule"/>
      {$Endregion}
      Procedure ChangePluralRuleOf(Culture : TCultureInfo; Const PluralRule : String);
      {$Region 'xmldoc'}
      /// <summary>
      /// Uses the translation in a specified language for all instances of a specified
      /// string in the translation catalog.
      /// </summary>
      /// <param name="OriginalText">
      /// The text to use the translatin.
      /// </param>
      /// <param name="TranslatedText">
      /// The translation of the text given by <paramref name="OriginalText"/>
      /// in the language specified by <paramref name="Culture"/>.
      /// </param>
      /// <param name="Culture">
      /// The <see cref="TCultureInfo"/> object that represents the language of the
      /// translation.
      /// </param>
      /// <param name="AffectedTranslations">
      /// The list of <see cref="TTextTranslation"/> objects that are affected by
      /// this method.
      /// </param>
      /// <returns>
      /// The number of affected <see cref="TTextTranslation"/> object.
      /// </returns>
      /// <seealso cref="UseRepository"/>
      {$Endregion}
      Function UseTranslation(Const OriginalText : String; Const TranslatedText : String; Culture : TCultureInfo; AffectedTranslations : TList = Nil) : Integer;
      {$Region 'xmldoc'}
      /// <summary>
      /// Uses the linked translation repository to translate all the untranslated
      /// strings in the translation catalog.
      /// </summary>
      /// <param name="AffectedTranslations">
      /// The list of <see cref="TTextTranslation"/> objects that are affected by
      /// this method.
      /// </param>
      /// <returns>
      /// The number of affected <see cref="TTextTranslation"/> object.
      /// </returns>
      /// <seealso cref="UseTranslation"/>
      /// <seealso cref="Repository"/>
      {$Endregion}
      Function UseRepository(AffectedTranslations : TList = Nil) : Integer; Overload;
      {$Region 'xmldoc'}
      /// <summary>
      /// Uses the linked translation repository to translate the untranslated
      /// strings of a given language in the translation catalog.
      /// </summary>
      /// <param name="Culture">
      /// The <see cref="TCultureInfo"/> object that represents the language in
      /// interest.
      /// </param>
      /// <param name="AffectedTranslations">
      /// The list of <see cref="TTextTranslation"/> objects that are affected by
      /// this method.
      /// </param>
      /// <returns>
      /// The number of affected <see cref="TTextTranslation"/> object.
      /// </returns>
      /// <seealso cref="UseTranslation"/>
      /// <seealso cref="Repository"/>
      {$Endregion}
      Function UseRepository(Culture : TCultureInfo; AffectedTranslations : TList = Nil) : Integer; Overload;
      {$Region 'xmldoc'}
      /// <summary>
      /// Writes the translation catalog to an XML document.
      /// </summary>
      /// <param name="Document">
      /// The target XML document.
      /// </param>
      /// <seealso cref="SaveToStream"/>
      /// <seealso cref="SaveToFile"/>
      {$Endregion}
      Procedure SaveToXML(Const Document : IXMLDocument);
      {$Region 'xmldoc'}
      /// <summary>
      /// Writes the translation catalog to a stream.
      /// </summary>
      /// <param name="Stream">
      /// The target stream.
      /// </param>
      /// <seealso cref="SaveToXML"/>
      /// <seealso cref="SaveToFile"/>
      /// <seealso cref="Compressed"/>
      {$Endregion}
      Procedure SaveToStream(Stream : TStream);
      {$Region 'xmldoc'}
      /// <summary>
      /// Writes the translation catalog to a file.
      /// </summary>
      /// <param name="FileName">
      /// The path to the target file. The path can use environment variables.
      /// For convenience, a relative path is considered ro be relative to the
      /// application's directory rather than the current directory.
      /// </param>
      /// <seealso cref="SaveToXML"/>
      /// <seealso cref="SaveToStream"/>
      /// <seealso cref="Compressed"/>
      {$Endregion}
      Procedure SaveToFile(Const FileName : String);
      {$Region 'xmldoc'}
      /// <summary>
      /// Reads the translation catalog from an XML document.
      /// </summary>
      /// <param name="Document">
      /// The source XML document.
      /// </param>
      /// <seealso cref="LoadFromStream"/>
      /// <seealso cref="LoadFromResource"/>
      /// <seealso cref="LoadFromFile"/>
      /// <seealso cref="LoadFromFiles"/>
      /// <seealso cref="LoadFromDirectory"/>
      /// <seealso cref="Open"/>
      /// <exception cref="ETranslationCatalogError">
      /// Occurs when the method encounters a problem while loading the translation
      /// catalog.
      /// </exception>
      {$Endregion}
      Procedure LoadFromXML(Const Document : IXMLDocument);
      {$Region 'xmldoc'}
      /// <summary>
      /// Reads the translation catalog from a stream.
      /// </summary>
      /// <param name="Stream">
      /// The source stream.
      /// </param>
      /// <seealso cref="LoadFromXML"/>
      /// <seealso cref="LoadFromResource"/>
      /// <seealso cref="LoadFromFile"/>
      /// <seealso cref="LoadFromFiles"/>
      /// <seealso cref="LoadFromDirectory"/>
      /// <seealso cref="Open"/>
      /// <exception cref="ETranslationCatalogError">
      /// Occurs when the method encounters a problem while loading the translation
      /// catalog.
      /// </exception>
      {$Endregion}
      Procedure LoadFromStream(Stream : TStream);
      {$Region 'xmldoc'}
      /// <summary>
      /// Reads the translation catalog from a file.
      /// </summary>
      /// <param name="FileName">
      /// The path to the source file. The path can use environment variables.
      /// For convenience, a relative path is considered ro be relative to the
      /// application's directory rather than the current directory.
      /// </param>
      /// <seealso cref="LoadFromXML"/>
      /// <seealso cref="LoadFromStream"/>
      /// <seealso cref="LoadFromResource"/>
      /// <seealso cref="LoadFromFiles"/>
      /// <seealso cref="LoadFromDirectory"/>
      /// <seealso cref="Open"/>
      /// <exception cref="ETranslationCatalogError">
      /// Occurs when the method encounters a problem while loading the translation
      /// catalog.
      /// </exception>
      {$Endregion}
      Procedure LoadFromFile(Const FileName : String);
      {$Region 'xmldoc'}
      /// <summary>
      /// Reads the translation catalog from a particular resource name and type.
      /// </summary>
      /// <param name="hInstance">
      /// The instance handle associated with the executable or shared library that
      /// contains the resource
      /// </param>
      /// <param name="ResName">
      /// The name of the resource.
      /// </param>
      /// <param name="ResType">
      /// The type of the resource.
      /// </param>
      /// <seealso cref="LoadFromXML"/>
      /// <seealso cref="LoadFromStream"/>
      /// <seealso cref="LoadFromFile"/>
      /// <seealso cref="LoadFromFiles"/>
      /// <seealso cref="LoadFromDirectory"/>
      /// <seealso cref="Open"/>
      /// <exception cref="ETranslationCatalogError">
      /// Occurs when the method encounters a problem while loading the translation
      /// catalog.
      /// </exception>
      {$Endregion}
      Procedure LoadFromResource(hInstance : HINST; Const ResName : String; ResType : PChar = RT_RCDATA); Overload;
      {$Region 'xmldoc'}
      /// <summary>
      /// Reads the translation catalog from a particular resource ID and type.
      /// </summary>
      /// <param name="hInstance">
      /// The instance handle associated with the executable or shared library that
      /// contains the resource
      /// </param>
      /// <param name="ResID">
      /// The ID of the resource.
      /// </param>
      /// <param name="ResType">
      /// The type of the resource.
      /// </param>
      /// <seealso cref="LoadFromXML"/>
      /// <seealso cref="LoadFromStream"/>
      /// <seealso cref="LoadFromFile"/>
      /// <seealso cref="LoadFromFiles"/>
      /// <seealso cref="LoadFromDirectory"/>
      /// <seealso cref="Open"/>
      /// <exception cref="ETranslationCatalogError">
      /// Occurs when the method encounters a problem while loading the translation
      /// catalog.
      /// </exception>
      {$Endregion}
      Procedure LoadFromResource(hInstance : HINST; ResID : Integer; ResType : PChar = RT_RCDATA); Overload;
      {$Region 'xmldoc'}
      /// <summary>
      /// Reads a set of translation catalogs from a specified list of files and
      /// merge them together.
      /// </summary>
      /// <param name="FileNames">
      /// The list of file names. The file paths can use environment variables.
      /// For convenience, a relative path is considered ro be relative to the
      /// application's directory rather than the current directory.
      /// </param>
      /// <param name="IgnoreErrors">
      /// Indicates whether failure in reading any file should fail the entire
      /// process.
      /// </param>
      /// <seealso cref="LoadFromXML"/>
      /// <seealso cref="LoadFromStream"/>
      /// <seealso cref="LoadFromResource"/>
      /// <seealso cref="LoadFromFile"/>
      /// <seealso cref="LoadFromDirectory"/>
      /// <seealso cref="Open"/>
      /// <exception cref="ETranslationCatalogError">
      /// Occurs when the method encounters a problem while loading the translation
      /// catalog.
      /// </exception>
      {$Endregion}
      Procedure LoadFromFiles(FileNames : TStrings; IgnoreErrors : Boolean);
      {$Region 'xmldoc'}
      /// <summary>
      /// Searches in a directory for translation catalogs and merge them together.
      /// </summary>
      /// <param name="Path">
      /// The path to the directory. The path can use environment variables.
      /// For convenience, a relative path is considered ro be relative to the
      /// application's directory rather than the current directory.
      /// </param>
      /// <param name="IncludeSubDirs">
      /// Indicates whether the search should follow the sub-directories.
      /// </param>
      /// <param name="FileMask">
      /// Specifies the file mask for selecting the files in interest.
      /// </param>
      /// <param name="IgnoreErrors">
      /// Indicates whether failure in reading any file should fail the entire
      /// process.
      /// </param>
      /// <seealso cref="LoadFromXML"/>
      /// <seealso cref="LoadFromStream"/>
      /// <seealso cref="LoadFromResource"/>
      /// <seealso cref="LoadFromFile"/>
      /// <seealso cref="LoadFromFiles"/>
      /// <seealso cref="Open"/>
      /// <exception cref="ETranslationCatalogError">
      /// Occurs when the method encounters a problem while loading the translation
      /// catalog.
      /// </exception>
      {$Endregion}
      Procedure LoadFromDirectory(Const Path : String; IncludeSubDirs : Boolean = False; Const FileMask : String = ''; IgnoreErrors : Boolean = True);
      {$Region 'xmldoc'}
      /// <summary>
      /// Loads a translation catalog form a specified location.
      /// </summary>
      /// <remarks>
      /// The <paramref name="URI"/> parameter determines the location of the translation
      /// catalog to load. It can be simply a path to a translation catalog file, but it
      /// can also address a directory or an application's resource. The file and directory
      /// paths can use environment variables.
      /// <list type="table">
      ///   <listheader>
      ///     <term>URI Format</term>
      ///     <description>Description</description>
      ///   </listheader>
      ///   <item>
      ///     <term>
      ///     res:&lt;ResName&gt;[.&lt;ResType&gt;]</term>
      ///     <description>
      ///     Loads the translation catalog from an application's resource.</description>
      ///     <example><code>
      ///     Localizer1.URI := 'res:translations';        // ResType is RCDATA
      ///     Localizer2.URI := 'res:translations.i18n';
      ///     </code>
      ///     </example>
      ///   </item>
      ///   <item>
      ///     <term>
      ///     dir:&lt;Directory&gt;\[FileMask]</term>
      ///     <description>
      ///     Merges the translation catalogs found in a specified directory, and
      ///     loads them.</description>
      ///     <example><code>
      ///     Localizer1.URI := 'dir:langs\';              // FileMask is *.i18n
      ///     Localizer2.URI := 'dir:langs\*.*';
      ///     </code>
      ///     </example>
      ///   </item>
      ///   <item>
      ///     <term>
      ///     dirs:&lt;Directory&gt;\[FileMask]</term>
      ///     <description>
      ///     Merges the translation catalogs found in a specified directory including
      ///     its sub-directories, and loads them.</description>
      ///     <example><code>
      ///     Localizer1.URI := 'dirx:langs\';             // FileMask is *.i18n
      ///     Localizer2.URI := 'dirx:langs\*.*';
      ///     </code>
      ///     </example>
      ///   </item>
      ///   <item>
      ///     <term>
      ///     [file:]&lt;FilePath&gt;</term>
      ///     <description>
      ///     Load the translation catalog from a specified file.</description>
      ///     <example><code>
      ///     Localizer1.URI := 'file:langs\MyApp.i18n';
      ///     Localizer2.URI := 'langs\MyApp.i18n';
      ///     </code>
      ///     </example>
      ///   </item>
      /// </list>
      /// NOTE: For convenience, a relative file or directory is considered to be
      /// relative to the application's directory instead of the current directory.
      /// </remarks>
      /// <example><code>
      /// Localizer1.URI := 'dir:%ALLUSERSPROFILE%\MyApp\';
      /// Localizer2.URI := '%USERPROFILE%\MyApp\myapp.i18n';
      /// </code>
      /// </example>
      /// <param name="URL">
      /// The address that specifies the location of a catalog to load.
      /// </param>
      /// <seealso cref="LoadFromXML"/>
      /// <seealso cref="LoadFromStream"/>
      /// <seealso cref="LoadFromResource"/>
      /// <seealso cref="LoadFromFile"/>
      /// <seealso cref="LoadFromFiles"/>
      /// <seealso cref="LoadFromDirectory"/>
      /// <exception cref="ETranslationCatalogError">
      /// Occurs when the method encounters a problem while loading the translation
      /// catalog.
      /// </exception>
      {$Endregion}
      Procedure Open(Const URI : String); Virtual;
      {$Region 'xmldoc'}
      /// <summary>
      /// Lists the text domain in the translation catalog.
      /// </summary>
      {$Endregion}
      Property TextDomains : TTextDomains Read fTextDomains;
      {$Region 'xmldoc'}
      /// <summary>
      /// Lists the <see cref="TCultureInfo"/> objects that represent the available
      /// translation languages of the translation catalog.
      /// </summary>
      /// <seealso cref="NativeCulture"/>
      {$Endregion}
      Property Cultures : TReadonlyCultureList Read GetCultures;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets the <see cref="TCultureInfo"/> object that represents the original language
      /// of strings in the translation catalog.
      /// </summary>
      /// <seealso cref="Cultures"/>
      {$Endregion}
      Property NativeCulture : TCultureInfo Read fNativeCulture Write SetNativeCulture;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets or sets whether the translation catalog should be saved in compressed
      /// format.
      /// </summary>
      {$Endregion}
      Property Compressed : Boolean Read fCompressed Write fCompressed;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets or sets the translation repository that is linked to this translation
      /// catalog.
      /// </summary>
      {$Endregion}
      Property Repository : TTranslationRepository Read fRepository Write fRepository;
    End;

  {$Region 'xmldoc'}
  /// <summary>
  /// TTranslationRepository represents a translation repository, which contains
  /// information about the past translations.
  /// </summary>
  /// <remarks>
  /// <para>
  /// TTranslationRepository maintains a persistent history of the translations.
  /// This information can be used later to automatically translate strings that
  /// were recorded.
  /// </para>
  /// <para>
  /// TTranslationRepository provides some methods to add new entries to the
  /// translation repository and use the translation history to translate new
  /// text.
  /// </para>
  /// </remarks>
  {$Endregion}

    TTranslationRepository = Class(TObject)
     Private
      Type
      TTranslationRepositoryItem = Class
       Public
        Key       : String;
        Culture   : TCultureInfo;
        Text      : String;
        Hits      : Integer;
        Relatives : TStringList;         { Locale => TTranslationRepositoryItem }
      End;
     Private
      Items     : TStringList;                 { Key => TTranslationRepositoryItem }
      Relations : TObjectList;             { List of all TTranslationRepositoryItem.Relatives }
      fModified : Boolean;
      Function GetPhraseCount : Integer;
      Function GetRelationCount : Integer;
      Function CreateRelationship : TStringList;
      Function KeyOf(Const Text : String; Culture : TCultureInfo) : String;
      Function Find(Const Text : String; Culture : TCultureInfo; Out Item : TTranslationRepositoryItem) : Boolean;
      Function FindOrCreate(Const Text : String; Culture : TCultureInfo) : TTranslationRepositoryItem; Overload;
      Function FindOrCreate(Const Key, Text : String; Culture : TCultureInfo) : TTranslationRepositoryItem; Overload;
      Procedure Relate(Item1, Item2 : TTranslationRepositoryItem);
     Public
      {$Region 'xmldoc'}
      /// <summary>
      /// Creates an instance of the class.
      /// </summary>
      {$Endregion}
      Constructor Create; Virtual;
      {$Region 'xmldoc'}
      /// <summary>
      /// Destroys the class and releases its allocated memory.
      /// </summary>
      {$Endregion}
      Destructor Destroy; Override;
      {$Region 'xmldoc'}
      /// <summary>
      /// Clears content of the translation repository.
      /// </summary>
      {$Endregion}
      Procedure Clear;
      {$Region 'xmldoc'}
      /// <summary>
      /// Indicates whether the translation repository contains any information.
      /// </summary>
      /// <returns>
      /// Returns <see langword="true"/> if the translation repository is empty,
      /// otherwise returns <see langword="false"/>.
      /// </returns>
      {$Endregion}
      Function Empty : Boolean; Inline;
      {$Region 'xmldoc'}
      /// <summary>
      /// Removes the translation history of a text string in a specific language.
      /// </summary>
      /// <param name="Text">
      /// The text to remove its translation history.
      /// </param>
      /// <param name="Culture">
      /// The <see cref="TCultureInfo"/> object that represents the language of
      /// the given <paramref name="Text"/>.
      /// </param>
      /// <returns>
      /// Returns <see langword="true"/> if the text string had any history to remove,
      /// otherwise returns <see langword="false"/>.
      /// </returns>
      {$Endregion}
      Function Remove(Const Text : String; Culture : TCultureInfo) : Boolean;
      {$Region 'xmldoc'}
      /// <summary>
      /// Defines two text strings in different (or same) languages as synonyms.
      /// </summary>
      /// <param name="Text1">
      /// The first text string.
      /// </param>
      /// <param name="Culture1">
      /// The <see cref="TCultureInfo"/> object that represents the language of
      /// the given <paramref name="Text1"/>.
      /// </param>
      /// <param name="Text2">
      /// The second text string.
      /// </param>
      /// <param name="Culture2">
      /// The <see cref="TCultureInfo"/> object that represents the language of
      /// the given <paramref name="Text2"/>.
      /// </param>
      /// <returns>
      /// Returns <see langword="true"/> if the two text strings are defined synonyms
      /// successfully. Otherwise, returns <see langword="false"/>.
      /// </returns>
      /// <seealso cref="HasSynonym"/>
      /// <seealso cref="FindSynonym"/>
      /// <seealso cref="FindAllSynonyms"/>
      {$Endregion}
      Function DefineSynonym(Const Text1 : String; Culture1 : TCultureInfo; Const Text2 : String; Culture2 : TCultureInfo) : Boolean;
      {$Region 'xmldoc'}
      /// <summary>
      /// Indicates whether a text string in a specified language has a synonym
      /// in another specified language.
      /// </summary>
      /// <param name="SourceText">
      /// The text string to examine.
      /// </param>
      /// <param name="SourceCulture">
      /// The <see cref="TCultureInfo"/> object that represents the language of
      /// the given <paramref name="SourceText"/>.
      /// </param>
      /// <param name="TargetCulture">
      /// The <see cref="TCultureInfo"/> object that represents the language of
      /// the requested synonym.
      /// </param>
      /// <returns>
      /// Returns <see langword="true"/> if the text strings has a synonym in the
      /// specified language, otherwise returns <see langword="false"/>.
      /// </returns>
      /// <seealso cref="DefineSynonym"/>
      /// <seealso cref="FindSynonym"/>
      /// <seealso cref="FindAllSynonyms"/>
      {$Endregion}
      Function HasSynonym(Const SourceText : String; SourceCulture, TargetCulture : TCultureInfo) : Boolean;
      {$Region 'xmldoc'}
      /// <summary>
      /// For a specified text in a specified language, retrieves its synonym in
      /// another specified language.
      /// </summary>
      /// <param name="SourceText">
      /// The text string to find its synonym.
      /// </param>
      /// <param name="SourceCulture">
      /// The <see cref="TCultureInfo"/> object that represents the language of
      /// the given <paramref name="SourceText"/>.
      /// </param>
      /// <param name="TargetCulture">
      /// The <see cref="TCultureInfo"/> object that represents the language of
      /// the returned <paramref name="Synonym"/>.
      /// </param>
      /// <param name="Synonym">
      /// Returns the found synonym.
      /// </param>
      /// <returns>
      /// Returns <see langword="true"/> if the text strings has a synonym in the
      /// specified language, otherwise returns <see langword="false"/>.
      /// </returns>
      /// <seealso cref="DefineSynonym"/>
      /// <seealso cref="HasSynonym"/>
      /// <seealso cref="FindAllSynonyms"/>
      {$Endregion}
      Function FindSynonym(Const SourceText : String; SourceCulture, TargetCulture : TCultureInfo; Out Synonym : String) : Boolean;
      {$Region 'xmldoc'}
      /// <summary>
      /// For a specified text in a specified language, retrieves all of its synonyms
      /// in another specified language.
      /// </summary>
      /// <param name="SourceText">
      /// The text string to find its synonyms.
      /// </param>
      /// <param name="SourceCulture">
      /// The <see cref="TCultureInfo"/> object that represents the language of
      /// the given <paramref name="SourceText"/>.
      /// </param>
      /// <param name="TargetCulture">
      /// The <see cref="TCultureInfo"/> object that represents the language of
      /// the returned <paramref name="Synonyms"/>.
      /// </param>
      /// <param name="Synonyms">
      /// Returns the list of found synonyms.
      /// </param>
      /// <returns>
      /// Returns the number of found synonyms for the given text string.
      /// </returns>
      /// <remarks>
      /// Each individual synonym in the <paramref name="Synonyms"/> list is
      /// escaped using <see cref="EscapeString"/> global function.
      /// </remarks>
      /// <seealso cref="DefineSynonym"/>
      /// <seealso cref="HasSynonym"/>
      /// <seealso cref="FindSynonym"/>
      {$Endregion}
      Function FindAllSynonyms(Const SourceText : String; SourceCulture, TargetCulture : TCultureInfo; Synonyms : TStrings) : Integer;
      {$Region 'xmldoc'}
      /// <summary>
      /// Improves the translation repository using the translated strings of a
      /// translation catalog.
      /// </summary>
      /// <param name="Catalog">
      /// The source translation catalog to learn from.
      /// </param>
      /// <seealso cref="Merge"/>
      {$Endregion}
      Procedure Learn(Catalog : TTranslationCatalog);
      {$Region 'xmldoc'}
      /// <summary>
      /// Combines information of another translation repository with this one.
      /// </summary>
      /// <param name="Repository">
      /// The source translation repository.
      /// </param>
      /// <seealso cref="Learn"/>
      {$Endregion}
      Procedure Merge(Repository : TTranslationRepository);
      {$Region 'xmldoc'}
      /// <summary>
      /// Writes the translation repository to an XML document.
      /// </summary>
      /// <param name="Document">
      /// The target XML document.
      /// </param>
      /// <seealso cref="SaveToStream"/>
      /// <seealso cref="SaveToFile"/>
      {$Endregion}
      Procedure SaveToXML(Const Document : IXMLDocument);
      {$Region 'xmldoc'}
      /// <summary>
      /// Writes the translation repository to a stream.
      /// </summary>
      /// <param name="Stream">
      /// The target stream.
      /// </param>
      /// <seealso cref="SaveToXML"/>
      /// <seealso cref="SaveToFile"/>
      {$Endregion}
      Procedure SaveToStream(Stream : TStream);
      {$Region 'xmldoc'}
      /// <summary>
      /// Writes the translation repository to a file.
      /// </summary>
      /// <param name="FileName">
      /// The path to the target file. The path can use environment variables.
      /// For convenience, a relative path is considered ro be relative to the
      /// application's directory rather than the current directory.
      /// </param>
      /// <seealso cref="SaveToXML"/>
      /// <seealso cref="SaveToStream"/>
      {$Endregion}
      Procedure SaveToFile(Const FileName : String);
      {$Region 'xmldoc'}
      /// <summary>
      /// Reads the translation repository from an XML document.
      /// </summary>
      /// <param name="Document">
      /// The source XML document.
      /// </param>
      /// <seealso cref="LoadFromStream"/>
      /// <seealso cref="LoadFromFile"/>
      /// <exception cref="ETranslationRepositoryError">
      /// Occurs when the method encounters a problem while loading the translation
      /// repository.
      /// </exception>
      {$Endregion}
      Procedure LoadFromXML(Const Document : IXMLDocument);
      {$Region 'xmldoc'}
      /// <summary>
      /// Reads the translation repository from a stream.
      /// </summary>
      /// <param name="Stream">
      /// The source stream.
      /// </param>
      /// <seealso cref="LoadFromXML"/>
      /// <seealso cref="LoadFromFile"/>
      /// <exception cref="ETranslationRepositoryError">
      /// Occurs when the method encounters a problem while loading the translation
      /// repository.
      /// </exception>
      {$Endregion}
      Procedure LoadFromStream(Stream : TStream);
      {$Region 'xmldoc'}
      /// <summary>
      /// Reads the translation repository from a file.
      /// </summary>
      /// <param name="FileName">
      /// The path to the source file. The path can use environment variables.
      /// For convenience, a relative path is considered ro be relative to the
      /// application's directory rather than the current directory.
      /// </param>
      /// <seealso cref="LoadFromXML"/>
      /// <seealso cref="LoadFromStream"/>
      /// <exception cref="ETranslationRepositoryError">
      /// Occurs when the method encounters a problem while loading the translation
      /// repository.
      /// </exception>
      {$Endregion}
      Procedure LoadFromFile(Const FileName : String);
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets the number of text strings in the translation repository.
      /// </summary>
      {$Endregion}
      Property PhraseCount : Integer Read GetPhraseCount;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets the number of relationships in the translation repository.
      /// </summary>
      {$Endregion}
      Property RelationCount : Integer Read GetRelationCount;
      {$Region 'xmldoc'}
      /// <summary>
      /// Gets or sets whether the translation repository is modified.
      /// </summary>
      {$Endregion}
      Property Modified : Boolean Read fModified Write fModified;
    End;

  Implementation

   Uses
    Types, XMLDoc, ZLib, StrUtils, Character, i18nMD5, i18nZStrList;

   Resourcestring
    SCatalogLoadError1 = 'The translation catalog cannot be loaded because its format is not supported';
    SCatalogLoadError2 = 'Unable to load the translation catalog: %s';
    SRepositoryLoadError1 = 'The translation repository cannot be loaded because its format is not supported';
    SRepositoryLoadError2 = 'Unable to load the translation repository: %s';
    SDirNotFoundError = 'Directory not found: %s';
    SSchemaError = '''%s:'' is not supported';

  { Helper Functions }

   Function NormalizePath(Const Path : String) : String;
    Begin
     Result := ExpandEnvStr(Path);
     If (ExtractFileDrive(Result) = '') And (Pos('\', ExtractFileDir(Result)) <> 1) Then
      Result := ExtractFilePath(ParamStr(0)) + Result;
    End;

   Function IsTrivial(c : Char) : Boolean;
    Begin
     Result := (c <> #0)
     And (CharIsWhiteSpace(c) Or CharIsSeparator(c) Or
     CharInSet(c, ['(', ')', '[', ']', '<', '>', '|', ':', '.']));
    End;

   Function TrimTrivials(Const Str : String) : String;
    Var
     i, j : Integer;
    Begin
     i := 1;
     j := Length(Str);
     While (i <= j) And IsTrivial(Str[i]) Do
      Inc(i);
     While (j >= i) And IsTrivial(Str[j]) Do
      Dec(j);
     Result := Copy(Str, i, j - i + 1);
    End;

   Function ModelTrivials(Const Str, Template : String) : String;
    Var
     Leading, Trailing : String;
     i, j              : Integer;
    Begin
     i := 1;
     j := Length(Template);
     While (i <= j) And IsTrivial(Template[i]) Do
      Inc(i);
     While (j >= i) And IsTrivial(Template[j]) Do
      Dec(j);
     Leading  := Copy(Template, 1, i - 1);
     Trailing := Copy(Template, j + 1, MaxInt);
     i        := 1;
     j        := Length(Str);
     While (i <= j) And IsTrivial(Str[i]) Do
      Inc(i);
     While (j >= i) And IsTrivial(Str[j]) Do
      Dec(j);
     Result := Leading + Copy(Str, i, j - i + 1) + Trailing;
    End;

   Function LettersOnly(Const Str : String) : String;
    Var
     i, n : Integer;
    Begin
     SetString(Result, Nil, Length(Str));
     n     := 0;
     For i := 1 To Length(Str) Do
      If CharIsLetter(Str[i]) Or (Str[i] = #0) Then
       Begin
        Inc(n);
        Result[n] := CharToUpper(Str[i]);
       End;
     SetLength(Result, n);
    End;

   Function IsXML(Stream : TStream) : Boolean;

     Function Swap(WC : WideChar) : WideChar; Inline;
      Begin
       Result := WideChar(System.Swap(Word(WC)));
      End;
    Const
     UNICODE_BOM : WideChar = #$FEFF;
     UNICODE_BOM_SWAPPED : WideChar = #$FFFE;
     UTF8_BOM : PAnsiChar = #$EF#$BB#$BF;
    Const
     xmlSignW : PWideChar = '<?xml';
     xmlSignA : PAnsiChar = '<?xml';
    Var
     BufferW      : Array [1..7] Of WideChar;
     BufferA      : Array [1..9] Of AnsiChar Absolute BufferW;
     BOM          : WideChar Absolute BufferW;
     BytesRead, i : Integer;

    Begin
     Result    := False;
     BytesRead := Stream.Read(BufferW, SizeOf(BufferW));
     Try
      If BytesRead = SizeOf(BufferW) Then
       Begin
        If (BOM = UNICODE_BOM_SWAPPED) Or (BufferW[1] = Swap('<')) Then
         Begin
          For i       := 1 To BytesRead Div 2 Do
           BufferW[i] := Swap(BufferW[i]);
         End;
        If BOM = UNICODE_BOM Then
         Begin
          BufferW[Length(xmlSignW) + 2] := #0;
          Result                        := (lstrcmpiW(@BufferW[2], xmlSignW) = 0);
         End
        Else If CompareMem(@BufferA[1], UTF8_BOM, 3) Then
         Begin
          BufferA[Length(xmlSignA) + 4] := #0;
          Result                        := (lstrcmpiA(@BufferA[4], xmlSignA) = 0);
         End
        Else
         Begin
          If BufferA[1] = '<' Then
           Begin
            BufferA[Length(xmlSignA) + 1] := #0;
            Result                        := (lstrcmpiA(@BufferA[1], xmlSignA) = 0);
           End
          Else If BufferW[1] = '<' Then
           Begin
            BufferW[Length(xmlSignW) + 1] := #0;
            Result                        := (lstrcmpiW(@BufferW[1], xmlSignW) = 0);
           End;
         End;
       End;
     Finally
      Stream.Seek( -BytesRead, soFromCurrent);
     End;
   End;

  Procedure WriteTextNode(Node : IXMLNode; HasPluralForms : Boolean; Const Value : String);
   Var
    i : Integer;
   Begin
    If HasPluralForms Then
     Begin
      For i                             := 0 To ZStrings.Count(Value) - 1 Do
       Node.AddChild('PluralForm').Text := EscapeString(ZStrings.GetSubStrAt(Value, i));
     End
    Else
     Node.Text := EscapeString(Value);
   End;

  Function ReadTextNode(Node : IXMLNode; HasPluralForms : Boolean) : String;
   Var
    ChildNode : IXMLNode;
   Begin
    If Node.IsTextElement Or Not HasPluralForms Then
     Result := UnescapeString(Node.Text)
    Else
     Begin
      Result    := '';
      ChildNode := Node.ChildNodes.First;
      While ChildNode <> Nil Do
       Begin
        If SameText(ChildNode.NodeName, 'PluralForm') Then
         ZStrings.Add(Result, UnescapeString(ChildNode.Text));
        ChildNode := ChildNode.NextSibling;
       End;
     End;
   End;

 { TXMLPersistentHashList }

  Function TXMLPersistentHashList.GetItemClass : THashItemClass;
   Begin
    Result := TXMLPersistentHashItem;
   End;

 { TTextItem }

  Constructor TTextItem.Create(Const AID : String);
   Begin
    fID := AID;
   End;

  Function TTextItem.GetKey : String;
   Begin
    Result := fID;
   End;

  Procedure TTextItem.Load(Const Node : IXMLNode);
   Var
    ChildNode : IXMLNode;
   Begin
    If Node.HasChildNodes Then
     Begin
      ChildNode := Node.ChildNodes.FindNode('Comment');
      If ChildNode <> Nil Then
       fComment := UnescapeString(ChildNode.Text);
      ChildNode := Node.ChildNodes.FindNode('OriginalValue');
      If ChildNode <> Nil Then
       Begin
        fOriginalValue := ReadTextNode(ChildNode, HasPluralForms);
        ChildNode      := Node.ChildNodes.FindNode('TranslatedValue');
        If ChildNode <> Nil Then
         Begin
          fTranslatedValue := ReadTextNode(ChildNode, HasPluralForms);
          fIsTranslated    := True;
         End;
       End;
     End;
   End;

  Procedure TTextItem.Save(Const Node : IXMLNode);
   Begin
    Node.Attributes['ID'] := ID;
    If Comment <> '' Then
     Node.AddChild('Comment').Text := EscapeString(Comment);
    WriteTextNode(Node.AddChild('OriginalValue'), HasPluralForms, OriginalValue);
    If IsTranslated Then
     WriteTextNode(Node.AddChild('TranslatedValue'), HasPluralForms, TranslatedValue);
   End;

  Procedure TTextItem.SetOriginalValue(Const Value : String);
   Begin
    If OriginalValue <> Value Then
     Begin
      fOriginalValue   := Value;
      fTranslatedValue := '';
      fIsTranslated    := False;
     End;
   End;

  Procedure TTextItem.SetTranslatedValue(Const Value : String);
   Begin
    If fTranslatedValue <> Value Then
     Begin
      fTranslatedValue := Value;
      fIsTranslated    := True;
     End;
   End;

  Procedure TTextItem.SetIsTranslated(Value : Boolean);
   Begin
    If IsTranslated <> Value Then
     Begin
      fIsTranslated := Value;
      If Not fIsTranslated Then
       fTranslatedValue := '';
     End;
   End;

  Function TTextItem.GetValue : String;
   Begin
    If IsTranslated Then
     Result := TranslatedValue
    Else
     Result := OriginalValue;
   End;

  Procedure TTextItem.SetValue(Const Value : String);
   Begin
    If OriginalValue <> Value Then
     TranslatedValue := Value
    Else
     IsTranslated := False;
   End;

  Function TTextItem.GetHasPluralForms : Boolean;
   Begin
    Result := (PChar(ID)^ = '#');
   End;

  Function TTextItem.GetPluralCount : Integer;
   Begin
    Result := ZStrings.Count(Value);
   End;

  Function TTextItem.GetPlurals(Index : Integer) : String;
   Begin
    Result := ZStrings.GetSubStrAt(Value, Index);
   End;

  Procedure TTextItem.SetPlurals(Index : Integer; Const PluralForm : String);
   Var
    NewValue : String;
   Begin
    NewValue := Value;
    ZStrings.SetSubStrAt(NewValue, Index, PluralForm);
    Value := NewValue;
   End;

  Procedure TTextItem.Assign(Source : TPersistent);
   Begin
    If Source Is TTextItem Then
     Begin
      fOriginalValue   := TTextItem(Source).fOriginalValue;
      fTranslatedValue := TTextItem(Source).fTranslatedValue;
      fIsTranslated    := TTextItem(Source).fIsTranslated;
      fComment         := TTextItem(Source).fComment;
     End
    Else
     Inherited Assign(Source);
   End;

  Function TTextItem.GetOwnerList : TTextItems;
   Begin
    Result := TTextItems(Inherited Owner);
   End;

  Function TTextItem.GetNext : TTextItem;
   Begin
    Result := TTextItem(Inherited Next);
   End;

  Function TTextItem.GetPrev : TTextItem;
   Begin
    Result := TTextItem(Inherited Prev);
   End;

 { TTextItems }

  Function TTextItems.GetItemClass : THashItemClass;
   Begin
    Result := TTextItem;
   End;

  Function TTextItems.GetItems(Const ID : String) : TTextItem;
   Begin
    Result := TTextItem(Inherited Items[ID]);
   End;

  Function TTextItems.GetFirst : TTextItem;
   Begin
    Result := TTextItem(Inherited First);
   End;

  Function TTextItems.GetLast : TTextItem;
   Begin
    Result := TTextItem(Inherited Last);
   End;

  Procedure TTextItems.DiscardTranslations;
   Var
    Item : TTextItem;
   Begin
    Item := First;
    While Item <> Nil Do
     Begin
      Item.IsTranslated := False;
      Item              := Item.Next;
     End;
   End;

  Function TTextItems.Find(Const ID : String) : TTextItem;
   Begin
    Result := TTextItem(Inherited Find(ID));
   End;

  Function TTextItems.Add(Const ID : String) : TTextItem;
   Begin
    Result := TTextItem(Inherited Add(ID));
   End;

  Function TTextItems.Add(Const Node : IXMLNode) : TXMLPersistentHashItem;
   Begin
    Result := Add(Node.Attributes['ID']);
    Result.Load(Node);
   End;

  Function TTextItems.Extract(Const ID : String) : TTextItem;
   Begin
    Result := TTextItem(Inherited Extract(ID));
   End;

  Function TTextItems.Delete(Const ID : String) : Boolean;
   Begin
    Result := Inherited Delete(ID);
   End;

  Procedure TTextItems.AssignTo(Dest : TPersistent);
   Var
    Item : TTextItem;
   Begin
    If Dest Is TStrings Then
     Begin
      TStrings(Dest).BeginUpdate;
      Try
       TStrings(Dest).Clear;
       Item := First;
       While Item <> Nil Do
        Begin
         TStrings(Dest).Values[Item.ID] := EscapeString(Item.Value);
         Item                           := Item.Next;
        End;
      Finally
       TStrings(Dest).EndUpdate;
      End;
     End
    Else
     Inherited AssignTo(Dest);
  End;

 Procedure TTextItems.Read(Reader : TReader);
  Var
   Data        : String;
   ID, Comment : String;
   p           : Integer;
  Begin
   Clear;
   Reader.ReadListBegin;
   While Not Reader.EndOfList Do
    Begin
     Data := Reader.ReadString;
     p    := Pos('=', Data);
     If p <> 0 Then
      Begin
       ID      := Copy(Data, 1, p - 1);
       Comment := Copy(Data, p + 1, Length(Data) - p);
      End
     Else
      Begin
       ID      := Data;
       Comment := '';
      End;
     Add(ID).Comment := Comment;
    End;
   Reader.ReadListEnd;
  End;

 Procedure TTextItems.Write(Writer : TWriter);
  Var
   Item : TTextItem;
   Data : String;
  Begin
   Writer.WriteListBegin;
   Item := First;
   While Item <> Nil Do
    Begin
     Data := Item.ID;
     If Item.Comment <> '' Then
      Data := Data + '=' + Item.Comment;
     Writer.WriteString(Data);
     Item := Item.Next;
    End;
   Writer.WriteListEnd;
  End;

{ TTranslationStats }

 Function TTranslationStats.Approved : Integer;
  Var
   State : TTranslationState;
  Begin
   Result    := 0;
   For State := Low(TTranslationState) To High(TTranslationState) Do
    If State In TTextTranslation.AcceptedTranslationStates Then
     Inc(Result, SubTotal[State]);
  End;

 Function TTranslationStats.Progress : Double;
  Begin
   If Total <> 0 Then
    Result := 100 * Approved / Total
   Else
    Result := 100;
  End;

{ TTextTranslation }

 Constructor TTextTranslation.Create(Const ALocale : String);
  Begin
   fLocale := ALocale;
  End;

 Function TTextTranslation.GetKey : String;
  Begin
   Result := fLocale;
  End;

 Procedure TTextTranslation.Load(Const Node : IXMLNode);
  Var
   StateStr : String;
  Begin
   If Node.HasAttribute('State') Then
    Begin
     StateStr := Node.Attributes['State'];
     State    := TTranslationState(AnsiIndexText(StateStr, ['Fuzzy', 'Google', 'Auto', 'User']) + 1);
    End
   Else
    State := tsUser;
   If Node.HasAttribute('Note') Then
    Note := UnescapeString(Node.Attributes['Note']);
   Value := ReadTextNode(Node, Owner.Definition.HasPluralForms);
  End;

 Procedure TTextTranslation.Save(Const Node : IXMLNode);
  Begin
   Node.Attributes['Locale'] := Locale;
   Case State Of
    tsNone   : Node.Attributes['State'] := 'None';
    tsFuzzy  : Node.Attributes['State'] := 'Fuzzy';
    tsGoogle : Node.Attributes['State'] := 'Google';
    tsAuto   : Node.Attributes['State'] := 'Auto';
   End;
   If Note <> '' Then
    Node.Attributes['Note'] := EscapeString(Note);
   WriteTextNode(Node, Owner.Definition.HasPluralForms, Value);
  End;

 Procedure TTextTranslation.Assign(Source : TPersistent);
  Begin
   If Source Is TTextTranslation Then
    Begin
     State := TTextTranslation(Source).State;
     Value := TTextTranslation(Source).Value;
     Note  := TTextTranslation(Source).Note;
    End
   Else
    Inherited Assign(Source);
  End;

 Procedure TTextTranslation.Merge(Source : TTextTranslation; Options : TMergeOptions);
  Begin
   If (State < Source.State) Or (moPreferSource In Options) Then
    Assign(Source);
  End;

 Function TTextTranslation.IsApproved : Boolean;
  Begin
   Result := (State In AcceptedTranslationStates);
  End;

 Function TTextTranslation.GetPluralCount : Integer;
  Begin
   Result := ZStrings.Count(Value);
  End;

 Function TTextTranslation.GetPlurals(Index : Integer) : String;
  Begin
   Result := ZStrings.GetSubStrAt(Value, Index);
  End;

 Procedure TTextTranslation.SetPlurals(Index : Integer; Const PluralForm : String);
  Begin
   ZStrings.SetSubStrAt(fValue, Index, PluralForm);
  End;

 Function TTextTranslation.GetOwnerList : TTextTranslations;
  Begin
   Result := TTextTranslations(Inherited Owner);
  End;

 Function TTextTranslation.GetNext : TTextTranslation;
  Begin
   Result := TTextTranslation(Inherited Next);
  End;

 Function TTextTranslation.GetPrev : TTextTranslation;
  Begin
   Result := TTextTranslation(Inherited Prev);
  End;

{ TTextTranslations }

 Constructor TTextTranslations.Create(ADefinition : TTextDefinition);
  Begin
   Inherited Create(32);
   fDefinition := ADefinition;
  End;

 Function TTextTranslations.GetItemClass : THashItemClass;
  Begin
   Result := TTextTranslation;
  End;

 Function TTextTranslations.GetItems(Const Locale : String) : TTextTranslation;
  Begin
   Result := TTextTranslation(Inherited Items[Locale]);
  End;

 Function TTextTranslations.GetFirst : TTextTranslation;
  Begin
   Result := TTextTranslation(Inherited First);
  End;

 Function TTextTranslations.GetLast : TTextTranslation;
  Begin
   Result := TTextTranslation(Inherited Last);
  End;

 Procedure TTextTranslations.Merge(Source : TTextTranslations; Options : TMergeOptions);
  Var
   Translation : TTextTranslation;
  Begin
   Translation := Source.First;
   While Translation <> Nil Do
    Begin
     Add(Translation.Locale).Merge(Translation, Options);
     Translation := Translation.Next;
    End;
  End;

 Function TTextTranslations.Find(Const Locale : String) : TTextTranslation;
  Begin
   Result := TTextTranslation(Inherited Find(Locale));
  End;

 Function TTextTranslations.Add(Const Locale : String) : TTextTranslation;
  Begin
   Result := TTextTranslation(Inherited Add(Locale));
  End;

 Function TTextTranslations.Add(Const Node : IXMLNode) : TXMLPersistentHashItem;
  Begin
   Result := Add(Node.Attributes['Locale']);
   Result.Load(Node);
  End;

 Function TTextTranslations.Extract(Const Locale : String) : TTextTranslation;
  Begin
   Result := TTextTranslation(Inherited Extract(Locale));
  End;

 Function TTextTranslations.Delete(Const Locale : String) : Boolean;
  Begin
   Result := Inherited Delete(Locale);
  End;

 Function TTextTranslations.NearestTo(Const Locale : String) : TTextTranslation;
  Var
   Culture     : TCultureInfo;
   Translation : TTextTranslation;
  Begin
   Result := Find(Locale);
   If Result = Nil Then
    Begin
     Culture := CultureOf(Locale, False);
     If Culture <> Nil Then
      Begin
       Translation := First;
       While Translation <> Nil Do
        Begin
         If Culture.IsDialectOf(Translation.Locale) Then
          Begin
           If (Result = Nil) Or (Result.State < Translation.State) Then
            Result := Translation;
           If Result.State = tsUser Then
            Exit;
          End;
         Translation := Translation.Next;
        End;
      End;
    End;
  End;

 Procedure TTextTranslations.DisapproveAll;
  Var
   Translation : TTextTranslation;
  Begin
   Translation := First;
   While Translation <> Nil Do
    Begin
     If Translation.IsApproved Then
      Translation.State := tsFuzzy;
     Translation        := Translation.Next;
    End;
  End;

{ TTextDefinition }

 Constructor TTextDefinition.Create(Const AID : String);
  Begin
   fTranslations := TTextTranslations.Create(Self);
   fID           := AID;
  End;

 Destructor TTextDefinition.Destroy;
  Begin
   fTranslations.Free;
   Inherited Destroy;
  End;

 Function TTextDefinition.GetKey : String;
  Begin
   Result := fID;
  End;

 Procedure TTextDefinition.Load(Const Node : IXMLNode);
  Var
   ChildNode : IXMLNode;
  Begin
   If Node.HasChildNodes Then
    Begin
     ChildNode := Node.ChildNodes.First;
     While ChildNode <> Nil Do
      Begin
       Case AnsiIndexText(ChildNode.NodeName, ['Comment', 'Value', 'Translation']) Of
        0 : Comment := UnescapeString(ChildNode.Text);
        1 : Value := ReadTextNode(ChildNode, HasPluralForms);
        2 : Translations.Add(ChildNode);
       End;
       ChildNode := ChildNode.NextSibling;
      End;
    End;
  End;

 Procedure TTextDefinition.Save(Const Node : IXMLNode);
  Var
   Translation : TTextTranslation;
  Begin
   Node.Attributes['ID'] := ID;
   If Comment <> '' Then
    Node.AddChild('Comment').Text := EscapeString(Comment);
   If Value <> '' Then
    WriteTextNode(Node.AddChild('Value'), HasPluralForms, Value);
   Translation := Translations.First;
   While Translation <> Nil Do
    Begin
     If (Translation.State <> tsNone) Or (Translation.Value <> '') Then
      Translation.Save(Node.AddChild('Translation'));
     Translation := Translation.Next;
    End;
  End;

 Procedure TTextDefinition.Assign(Source : TPersistent);
  Begin
   If Source Is TTextDefinition Then
    Begin
     fComment := TTextDefinition(Source).Comment;
     fValue   := TTextDefinition(Source).Value;
     Translations.Assign(TTextDefinition(Source).Translations);
    End
   Else
    Inherited Assign(Source);
  End;

 Procedure TTextDefinition.Merge(Source : TTextDefinition; Options : TMergeOptions);
  Begin
   If Source.Locale = Locale Then
    Begin
     If moPreferSource In Options Then
      Begin
       If Value <> Source.Value Then
        Begin
         Translations.DisapproveAll;
         fValue := Source.Value;
        End;
       fComment := Source.Comment;
      End
     Else If (Source.Comment <> '') And (Pos(Source.Comment, Comment) = 0) Then
      Begin
       If Comment = '' Then
        Comment := Source.Comment
       Else
        Comment := Comment + #13#10 + Source.Comment;
      End;
    End
   Else If Source.Value <> '' Then
    Begin
     With Translations.Add(Source.Locale) Do
      Begin
       Value := Source.Value;
       State := tsUser;
       Note  := Comment;
      End;
    End;
   Translations.Merge(Source.Translations, Options);
  End;

 Procedure TTextDefinition.Revise(Source : TTextItem);
  Begin
   If Value <> Source.Value Then
    Begin
     Translations.DisapproveAll;
     fValue := Source.Value;
    End;
   fComment := Source.Comment;
  End;

 Function TTextDefinition.GetLocale : String;
  Var
   Culture : TCultureInfo;
  Begin
   Culture := Dictionary.TextDomain.Owner.Catalog.NativeCulture;
   If Assigned(Culture) Then
    Result := Culture.Locale
   Else
    Result := '';
  End;

 Function TTextDefinition.GetHasPluralForms : Boolean;
  Begin
   Result := (PChar(ID)^ = '#');
  End;

 Function TTextDefinition.GetPluralCount : Integer;
  Begin
   Result := ZStrings.Count(Value);
  End;

 Function TTextDefinition.GetPlurals(Index : Integer) : String;
  Begin
   Result := ZStrings.GetSubStrAt(Value, Index);
  End;

 Procedure TTextDefinition.SetPlurals(Index : Integer; Const PluralForm : String);
  Begin
   ZStrings.SetSubStrAt(fValue, Index, PluralForm);
  End;

 Function TTextDefinition.GetDictionary : TTextDictionary;
  Begin
   Result := TTextDictionary(Inherited Owner);
  End;

 Function TTextDefinition.GetNext : TTextDefinition;
  Begin
   Result := TTextDefinition(Inherited Next);
  End;

 Function TTextDefinition.GetPrev : TTextDefinition;
  Begin
   Result := TTextDefinition(Inherited Prev);
  End;

{ TTextDictionary }

 Constructor TTextDictionary.Create(ATextDomain : TTextDomain; AKind : TTextDitionaryKind);
  Begin
   Inherited Create(256);
   fTextDomain := ATextDomain;
   fKind       := AKind;
  End;

 Function TTextDictionary.GetItemClass : THashItemClass;
  Begin
   Result := TTextDefinition;
  End;

 Function TTextDictionary.GetItems(Const ID : String) : TTextDefinition;
  Begin
   Result := TTextDefinition(Inherited Items[ID]);
  End;

 Function TTextDictionary.GetFirst : TTextDefinition;
  Begin
   Result := TTextDefinition(Inherited First);
  End;

 Function TTextDictionary.GetLast : TTextDefinition;
  Begin
   Result := TTextDefinition(Inherited Last);
  End;

 Procedure TTextDictionary.Assign(Source : TPersistent);
  Begin
   If Source Is TTextDictionary Then
    fKind := TTextDictionary(Source).Kind;
   Inherited Assign(Source);
  End;

 Procedure TTextDictionary.Merge(Source : TTextDictionary; Options : TMergeOptions);
  Var
   SrcDefinition, Definition : TTextDefinition;
   Added, Removed            : TTextDefinition;
   NewDefinitions            : TList;
   Ratio, BestRatio          : Double;
   i, SimilarIndex           : Integer;
  Begin
   NewDefinitions := TList.Create;
   Try
    // Add new or update exiting definitions
    SrcDefinition := Source.First;
    While SrcDefinition <> Nil Do
     Begin
      Definition := Find(SrcDefinition.ID);
      If Definition = Nil Then
       Begin
        Definition := Add(SrcDefinition.ID);
        NewDefinitions.Add(Definition);
        Definition.Assign(SrcDefinition);
       End
      Else
       Definition.Merge(SrcDefinition, Options);
      SrcDefinition := SrcDefinition.Next;
     End;
    // A new definition can be a renamed or slightly modified version of an old one
    Removed    := Nil;
    Definition := First;
    While Definition <> Nil Do
     Begin
      If Not Source.Exists(Definition.ID) Then
       Removed   := Definition;
      Definition := Definition.Next;
      If Removed <> Nil Then
       Begin
        // Attempt to find a new definition similar to the removed one
        BestRatio    := 0;
        SimilarIndex := -1;
        For i        := 0 To NewDefinitions.Count - 1 Do
         Begin
          Added := TTextDefinition(NewDefinitions[i]);
          If Added.HasPluralForms = Removed.HasPluralForms Then
           Begin
            Ratio := TextSimilarityRatio(Added.Value, Removed.Value);
            If (Ratio >= AcceptedSimilarityRatio) And (Ratio > BestRatio)Then
             Begin
              BestRatio    := Ratio;
              SimilarIndex := i;
             End;
           End;
         End;
        // If there is a new and similar definition, it's a revised version of the removed one
        If SimilarIndex >= 0 Then
         Begin
          Added := TTextDefinition(NewDefinitions[SimilarIndex]);
          If Added.Value <> Removed.Value Then
           Removed.Translations.DisapproveAll;
          Added.Translations.Merge(Removed.Translations);
          NewDefinitions.Delete(SimilarIndex);
          Removed.Delete;
         End
        Else If moDeleteDefinitionsNotInSource In Options Then
         Removed.Delete;
        Removed := Nil;
       End;
     End;
   Finally
    NewDefinitions.Free;
   End;
  End;

 Procedure TTextDictionary.Revise(Source : TTextItems; KeepRemovedEntries : Boolean);
  Var
   Item                       : TTextItem;
   Definition, Added, Removed : TTextDefinition;
   NewDefinitions             : TList;
   Ratio, BestRatio           : Double;
   i, SimilarIndex            : Integer;
  Begin
   NewDefinitions := TList.Create;
   Try
    // Add new or update exiting definitions
    Item := Source.First;
    While Item <> Nil Do
     Begin
      Definition := Find(Item.ID);
      If Definition = Nil Then
       Begin
        Definition := Add(Item.ID);
        NewDefinitions.Add(Definition);
       End;
      Definition.Revise(Item);
      Item := Item.Next;
     End;
    // A new definition can be a renamed or slightly modified version of an old one
    Removed    := Nil;
    Definition := First;
    While Definition <> Nil Do
     Begin
      If Not Source.Exists(Definition.ID) Then
       Removed   := Definition;
      Definition := Definition.Next;
      If Removed <> Nil Then
       Begin
        // Attempt to find a new definition similar to the removed one
        BestRatio    := 0;
        SimilarIndex := -1;
        For i        := 0 To NewDefinitions.Count - 1 Do
         Begin
          Added := TTextDefinition(NewDefinitions[i]);
          If Added.HasPluralForms = Removed.HasPluralForms Then
           Begin
            Ratio := TextSimilarityRatio(Added.Value, Removed.Value);
            If (Ratio >= AcceptedSimilarityRatio) And (Ratio > BestRatio) Then
             Begin
              BestRatio    := Ratio;
              SimilarIndex := i;
             End;
           End;
         End;
        // If there is a new and similar definition, it's a revised version of the removed one
        If SimilarIndex >= 0 Then
         Begin
          Added := TTextDefinition(NewDefinitions[SimilarIndex]);
          Added.Translations.Assign(Removed.Translations);
          If Added.Value <> Removed.Value Then
           Added.Translations.DisapproveAll;
          NewDefinitions.Delete(SimilarIndex);
          Removed.Delete;
         End
        Else If Not KeepRemovedEntries Then
         Removed.Delete;
        Removed := Nil;
       End;
     End;
   Finally
    NewDefinitions.Free;
   End;
  End;

 Function TTextDictionary.Find(Const ID : String) : TTextDefinition;
  Begin
   Result := TTextDefinition(Inherited Find(ID));
  End;

 Function TTextDictionary.Add(Const ID : String) : TTextDefinition;
  Begin
   Result := TTextDefinition(Inherited Add(ID));
  End;

 Function TTextDictionary.Add(Const Node : IXMLNode) : TXMLPersistentHashItem;
  Begin
   Result := Add(Node.Attributes['ID']);
   Result.Load(Node);
  End;

 Function TTextDictionary.Extract(Const ID : String) : TTextDefinition;
  Begin
   Result := TTextDefinition(Inherited Extract(ID));
  End;

 Function TTextDictionary.Delete(Const ID : String) : Boolean;
  Begin
   Result := Inherited Delete(ID);
  End;

 Procedure TTextDictionary.Compact(Options : TCompactOptions);
  Var
   Definition         : TTextDefinition;
   Translation        : TTextTranslation;
   NotUsedTranslation : TTextTranslation;
  Begin
   Definition := First;
   While Definition <> Nil Do
    Begin
     If coDropComments In Options Then
      Definition.Comment := '';
     NotUsedTranslation  := Nil;
     Translation         := Definition.Translations.First;
     While Translation <> Nil Do
      Begin
       If (coUsablesOnly In Options) And
       (Not Translation.IsApproved Or (Translation.Value = Definition.Value))
       Then
        NotUsedTranslation := Translation
       Else If coDropNotes In Options Then
        Translation.Note := '';
       Translation       := Translation.Next;
       If NotUsedTranslation <> Nil Then
        Begin
         NotUsedTranslation.Delete;
         NotUsedTranslation := Nil;
        End;
      End;
     Definition := Definition.Next;
    End;
  End;

 Function TTextDictionary.TranslationToOriginal(Const Locale : String) : Boolean;
  Var
   Definition  : TTextDefinition;
   Translation : TTextTranslation;
  Begin
   Result     := True;
   Definition := First;
   While Definition <> Nil Do
    Begin
     Translation := Definition.Translations.NearestTo(Locale);
     If (Translation <> Nil) And Translation.IsApproved Then
      Begin
       Definition.Value   := Translation.Value;
       Definition.Comment := Translation.Note;
      End
     Else
      Result    := False;
     Definition := Definition.Next;
    End;
  End;

 Procedure TTextDictionary.OrigialToTranslation(Const Locale : String);
  Var
   Definition  : TTextDefinition;
   Translation : TTextTranslation;
  Begin
   Definition := First;
   While Definition <> Nil Do
    Begin
     Translation       := Definition.Translations.Add(Locale);
     Translation.Value := Definition.Value;
     Translation.Note  := Definition.Comment;
     Translation.State := tsUser;
     Definition        := Definition.Next;
    End;
  End;

 Procedure TTextDictionary.Define(Const Locale : String);

   Function AutoTranslate(Const Text : String; Out TranslatedText : String) : Boolean;
    Begin
     With TextDomain.Owner.Catalog Do
      Result := (NativeCulture <> Nil) And (Repository <> Nil) And
      Repository.FindSynonym(Text, NativeCulture, CultureOf(Locale), TranslatedText);
    End;
  Var
   CanUseOriginal, IsOriginal : Boolean;
   Definition                 : TTextDefinition;
   Translation                : TTextTranslation;
   NearestTranslation         : TTextTranslation;
   TranslatedText             : String;

  Begin
   CanUseOriginal := (TextDomain.Owner.Catalog.NativeCulture <> Nil)
   And TextDomain.Owner.Catalog.NativeCulture.IsDialectOf(Locale);
   IsOriginal := CanUseOriginal
   And SameText(TextDomain.Owner.Catalog.NativeCulture.Locale, Locale);
   Definition := First;
   While Definition <> Nil Do
    Begin
     If Not Definition.Translations.Exists(Locale) Then
      Begin
       NearestTranslation := Definition.Translations.NearestTo(Locale);
       Translation        := Definition.Translations.Add(Locale);
       If (NearestTranslation <> Nil) And NearestTranslation.IsApproved Then
        Begin
         Translation.Value := NearestTranslation.Value;
         Translation.State := tsAuto;
        End
       Else If CanUseOriginal Then
        Begin
         Translation.Value := Definition.Value;
         If IsOriginal Then
          Translation.State := tsUser
         Else
          Translation.State := tsAuto;
        End
       Else If AutoTranslate(Definition.Value, TranslatedText) Then
        Begin
         Translation.Value := TranslatedText;
         Translation.State := tsAuto;
        End;
      End;
     Definition := Definition.Next;
    End;
  End;

 Procedure TTextDictionary.Undefine(Const Locale : String);
  Var
   Definition : TTextDefinition;
  Begin
   Definition := First;
   While Definition <> Nil Do
    Begin
     Definition.Translations.Delete(Locale);
     Definition := Definition.Next;
    End;
  End;

 Procedure TTextDictionary.RetrieveCultures(Dest : TCultureList);
  Var
   Definition  : TTextDefinition;
   Translation : TTextTranslation;
  Begin
   Definition := First;
   While Definition <> Nil Do
    Begin
     Translation := Definition.Translations.First;
     While Translation <> Nil Do
      Begin
       Dest.Add(Translation.Locale);
       Translation := Translation.Next;
      End;
     Definition := Definition.Next;
    End;
  End;

 Procedure TTextDictionary.UpdateStats(Const Locale : String; Var Stats : TTranslationStats);
  Var
   Definition  : TTextDefinition;
   Translation : TTextTranslation;
  Begin
   Inc(Stats.Total, Count);
   Definition := First;
   While Definition <> Nil Do
    Begin
     Translation := Definition.Translations.Find(Locale);
     If Translation <> Nil Then
      Inc(Stats.SubTotal[Translation.State]);
     Definition := Definition.Next;
    End;
  End;

 Function TTextDictionary.TranslationOf(Const ID, Locale : String) : TTextTranslation;
  Var
   Definition : TTextDefinition;
  Begin
   Definition := Find(ID);
   If Definition <> Nil Then
    Result := Definition.Translations.NearestTo(Locale)
   Else
    Result := Nil;
  End;

 Procedure TTextDictionary.Translate(TextItems : TTextItems; Locale : String);
  Var
   TextItem    : TTextItem;
   Translation : TTextTranslation;
  Begin
   TextItem := TextItems.First;
   While TextItem <> Nil Do
    Begin
     Translation := TranslationOf(TextItem.ID, Locale);
     If (Translation <> Nil) And Translation.IsApproved Then
      TextItem.TranslatedValue := Translation.Value
     Else
      TextItem.IsTranslated := False;
     TextItem               := TextItem.Next;
    End;
  End;

{ TTextDomain }

 Constructor TTextDomain.Create(Const AName : String);
  Begin
   fProperties := TTextDictionary.Create(Self, dkProperty);
   fLiterals   := TTextDictionary.Create(Self, dkLiteral);
   fName       := AName;
  End;

 Destructor TTextDomain.Destroy;
  Begin
   fProperties.Free;
   fLiterals.Free;
   Inherited Destroy;
  End;

 Function TTextDomain.GetKey : String;
  Begin
   Result := fName;
  End;

 Procedure TTextDomain.Load(Const Node : IXMLNode);
  Var
   ChildNode : IXMLNode;
  Begin
   If Node.HasChildNodes Then
    Begin
     ChildNode := Node.ChildNodes.First;
     While ChildNode <> Nil Do
      Begin
       Case AnsiIndexText(ChildNode.NodeName, ['Property', 'Literal']) Of
        0 : Properties.Add(ChildNode);
        1 : Literals.Add(ChildNode);
       End;
       ChildNode := ChildNode.NextSibling;
      End;
    End;
  End;

 Procedure TTextDomain.Save(Const Node : IXMLNode);
  Var
   Definition : TTextDefinition;
  Begin
   Node.Attributes['Name'] := Name;
   Definition              := Properties.First;
   While Definition <> Nil Do
    Begin
     Definition.Save(Node.AddChild('Property'));
     Definition := Definition.Next;
    End;
   Definition := Literals.First;
   While Definition <> Nil Do
    Begin
     Definition.Save(Node.AddChild('Literal'));
     Definition := Definition.Next;
    End;
  End;

 Procedure TTextDomain.Assign(Source : TPersistent);
  Begin
   If Source Is TTextDomain Then
    Begin
     Properties.Assign(TTextDomain(Source).Properties);
     Literals.Assign(TTextDomain(Source).Literals);
    End
   Else
    Inherited Assign(Source);
  End;

 Procedure TTextDomain.Merge(Source : TTextDomain; Options : TMergeOptions);
  Begin
   Properties.Merge(Source.Properties, Options);
   Literals.Merge(Source.Literals, Options);
  End;

 Function TTextDomain.GetOwnerList : TTextDomains;
  Begin
   Result := TTextDomains(Inherited Owner);
  End;

 Function TTextDomain.GetNext : TTextDomain;
  Begin
   Result := TTextDomain(Inherited Next);
  End;

 Function TTextDomain.GetPrev : TTextDomain;
  Begin
   Result := TTextDomain(Inherited Prev);
  End;

 Function TTextDomain.Empty : Boolean;
  Begin
   Result := (Properties.Count = 0) And (Literals.Count = 0);
  End;

 Function TTextDomain.StatsOf(Const Locale : String) : TTranslationStats;
  Begin
   FillChar(Result, SizeOf(Result), 0);
   Properties.UpdateStats(Locale, Result);
   Literals.UpdateStats(Locale, Result);
  End;

 Procedure TTextDomain.GetComponents(dstList : TStrings);
  Var
   Prop          : TTextDefinition;
   ComponentName : String;
  Begin
   dstList.BeginUpdate;
   Try
    dstList.Clear;
    Prop := Properties.First;
    While Prop <> Nil Do
     Begin
      ComponentName := ExtractComponentName(Prop.ID);
      If (ComponentName <> '') And (dstList.IndexOf(ComponentName) < 0) Then
       dstList.Add(ComponentName);
      Prop := Prop.Next;
     End;
   Finally
    dstList.EndUpdate;
   End;
  End;

 Function TTextDomain.HasComponent(Const ComponentName : String) : Boolean;
  Var
   Prop : TTextDefinition;
  Begin
   Result := False;
   Prop   := Properties.First;
   While Prop <> Nil Do
    Begin
     If AnsiStartsText(ComponentName, Prop.ID) And
     CharInSet(Prop.ID[Length(ComponentName) + 1], ['.', '[']) Then
      Begin
       Result := True;
       Exit;
      End;
     Prop := Prop.Next;
    End;
  End;

 Function TTextDomain.DeleteComponent(Const ComponentName : String) : Boolean;
  Var
   Prop       : TTextDefinition;
   TargetProp : TTextDefinition;
  Begin
   Result     := False;
   TargetProp := Nil;
   Prop       := Properties.First;
   While Prop <> Nil Do
    Begin
     If AnsiStartsText(ComponentName, Prop.ID) And
     CharInSet(Prop.ID[Length(ComponentName) + 1], ['.', '['])
     Then
      TargetProp := Prop;
     Prop        := Prop.Next;
     If TargetProp <> Nil Then
      Begin
       TargetProp.Delete;
       TargetProp := Nil;
       Result     := True;
      End;
    End;
  End;

 Function TTextDomain.RenameComponent(Const ComponentName, NewComponentName : String) : Boolean;
  Var
   Prop       : TTextDefinition;
   TargetProp : TTextDefinition;
   FieldPath  : String;
  Begin
   Result := False;
   If ComponentName = NewComponentName Then
    Result := True
   Else If SameText(ComponentName, NewComponentName) Then
    Begin
     Prop := Properties.First;
     While Prop <> Nil Do
      Begin
       If AnsiStartsText(ComponentName, Prop.ID) And
       CharInSet(Prop.ID[Length(ComponentName) + 1], ['.', '[']) Then
        Begin
         FieldPath := Copy(Prop.ID, Length(ComponentName) + 1, MaxInt);
         Prop.fID  := NewComponentName + FieldPath;
         Result    := True;
        End;
       Prop := Prop.Next;
      End;
    End
   Else If Not HasComponent(NewComponentName) Then
    Begin
     TargetProp := Nil;
     Prop       := Properties.First;
     While Prop <> Nil Do
      Begin
       If AnsiStartsText(ComponentName, Prop.ID) And
       CharInSet(Prop.ID[Length(ComponentName) + 1], ['.', '[']) Then
        TargetProp := Prop;
       Prop        := Prop.Next;
       If TargetProp <> Nil Then
        Begin
         FieldPath := Copy(TargetProp.ID, Length(ComponentName) + 1, MaxInt);
         With Properties.Add(NewComponentName + FieldPath) Do
          Begin
           Assign(TargetProp);
           MoveBefore(TargetProp);
          End;
         TargetProp.Delete;
         TargetProp := Nil;
         Result     := True;
        End;
      End;
    End;
  End;

 Function TTextDomain.Rename(Const NewName : String) : TTextDomain;
  Begin
   If SameText(NewName, Name) Then
    Begin
     fName  := NewName;
     Result := Self;
    End
   Else If Not Owner.Exists(NewName) Then
    Begin
     Result := Owner.Add(NewName);
     Result.Assign(Self);
     Result.MoveBefore(Self);
     Self.Delete;
    End
   Else
    Result := Nil;
  End;

{ TTextDomains }

 Constructor TTextDomains.Create(ACatalog : TTranslationCatalog);
  Begin
   Inherited Create(32);
   fCatalog := ACatalog;
  End;

 Function TTextDomains.GetItemClass : THashItemClass;
  Begin
   Result := TTextDomain;
  End;

 Function TTextDomains.GetItems(Const Name : String) : TTextDomain;
  Begin
   Result := TTextDomain(Inherited Items[Name]);
  End;

 Function TTextDomains.GetFirst : TTextDomain;
  Begin
   Result := TTextDomain(Inherited First);
  End;

 Function TTextDomains.GetLast : TTextDomain;
  Begin
   Result := TTextDomain(Inherited Last);
  End;

 Procedure TTextDomains.Merge(Source : TTextDomains; Options : TMergeOptions);
  Var
   TextDomain, Removed : TTextDomain;
  Begin
   If moDeleteDomainsNotInSource In Options Then
    Begin
     Removed    := Nil;
     TextDomain := First;
     While TextDomain <> Nil Do
      Begin
       If Not Source.Exists(TextDomain.Name) Then
        Removed   := TextDomain;
       TextDomain := TextDomain.Next;
       If Removed <> Nil Then
        Begin
         Removed.Delete;
         Removed := Nil;
        End;
      End;
    End;
   TextDomain := Source.First;
   While TextDomain <> Nil Do
    Begin
     Add(TextDomain.Name).Merge(TextDomain, Options);
     TextDomain := TextDomain.Next;
    End;
  End;

 Function TTextDomains.Find(Const Name : String) : TTextDomain;
  Begin
   Result := TTextDomain(Inherited Find(Name));
  End;

 Function TTextDomains.Add(Const Name : String) : TTextDomain;
  Begin
   Result := TTextDomain(Inherited Add(Name));
  End;

 Function TTextDomains.Add(Const Node : IXMLNode) : TXMLPersistentHashItem;
  Begin
   Result := Add(Node.Attributes['Name']);
   Result.Load(Node);
  End;

 Function TTextDomains.Extract(Const Name : String) : TTextDomain;
  Begin
   Result := TTextDomain(Inherited Extract(Name));
  End;

 Function TTextDomains.Delete(Const Name : String) : Boolean;
  Begin
   Result := Inherited Delete(Name);
  End;

{ TTranslationCatalog }

 Constructor TTranslationCatalog.Create;
  Begin
   fTextDomains       := TTextDomains.Create(Self);
   fCultures          := TCultureList.Create;
   fCustomPluralRules := TKeyLookup<TCultureInfo, String>.Create;
  End;

 Destructor TTranslationCatalog.Destroy;
  Begin
   fCultures.Free;
   fTextDomains.Free;
   fCustomPluralRules.Free;
   Inherited Destroy;
  End;

 Function TTranslationCatalog.GetCultures : TReadonlyCultureList;
  Begin
   Result := fCultures;
  End;

 Procedure TTranslationCatalog.SetNativeCulture(Value : TCultureInfo);
  Var
   TextDomain : TTextDomain;
  Begin
   If NativeCulture <> Value Then
    Begin
     TextDomain := TextDomains.First;
     While TextDomain <> Nil Do
      Begin
       If NativeCulture <> Nil Then
        Begin
         TextDomain.Properties.OrigialToTranslation(NativeCulture.Locale);
         TextDomain.Literals.OrigialToTranslation(NativeCulture.Locale);
        End;
       If Value <> Nil Then
        Begin
         TextDomain.Properties.TranslationToOriginal(Value.Locale);
         TextDomain.Literals.TranslationToOriginal(Value.Locale);
        End;
       TextDomain := TextDomain.Next;
      End;
     fNativeCulture := Value;
    End;
  End;

 Procedure TTranslationCatalog.NormalizeCultures;
  Var
   TextDomain : TTextDomain;
  Begin
   If fUpdateCount = 0 Then
    Begin
     fCultures.Clear;
     TextDomain := TextDomains.First;
     While TextDomain <> Nil Do
      Begin
       TextDomain.Properties.RetrieveCultures(fCultures);
       TextDomain.Literals.RetrieveCultures(fCultures);
       TextDomain := TextDomain.Next;
      End;
     If (Repository = Nil) And (NativeCulture <> Nil) Then
      fCultures.Add(NativeCulture);
    End;
  End;

 Procedure TTranslationCatalog.NormalizeTranslations;
  Var
   TextDomain, ToDelete : TTextDomain;
   i                    : Integer;
  Begin
   If fUpdateCount = 0 Then
    Begin
     ToDelete   := Nil;
     TextDomain := TextDomains.First;
     While TextDomain <> Nil Do
      Begin
       If TextDomain.Empty Then
        ToDelete := TextDomain
       Else
        For i := 0 To Cultures.Count - 1 Do
         Begin
          TextDomain.Properties.Define(Cultures[i].Locale);
          TextDomain.Literals.Define(Cultures[i].Locale);
         End;
       TextDomain := TextDomain.Next;
       If ToDelete <> Nil Then
        Begin
         ToDelete.Delete;
         ToDelete := Nil;
        End;
      End;
    End;
  End;

 Procedure TTranslationCatalog.Clear;
  Begin
   fNativeCulture := Nil;
   fCultures.Clear;
   fTextDomains.Clear;
   fCustomPluralRules.Clear;
   fCompressed := False;
  End;

 Function TTranslationCatalog.Empty : Boolean;
  Begin
   Result := (TextDomains.Count = 0);
  End;

 Procedure TTranslationCatalog.BeginUpdate;
  Begin
   Inc(fUpdateCount);
  End;

 Procedure TTranslationCatalog.EndUpdate;
  Begin
   Dec(fUpdateCount);
   If fUpdateCount = 0 Then
    Begin
     NormalizeCultures;
     If Assigned(Repository) Then
      NormalizeTranslations;
    End;
  End;

 Procedure TTranslationCatalog.Compact(Options : TCompactOptions);
  Var
   TextDomain : TTextDomain;
  Begin
   BeginUpdate;
   Try
    TextDomain := TextDomains.First;
    While TextDomain <> Nil Do
     Begin
      TextDomain.Properties.Compact(Options);
      TextDomain.Literals.Compact(Options);
      TextDomain := TextDomain.Next;
     End;
   Finally
    EndUpdate;
   End;
  End;

 Procedure TTranslationCatalog.Add(Culture : TCultureInfo);
  Var
   TextDomain : TTextDomain;
  Begin
   If Culture <> Nil Then
    Begin
     fCultures.Add(Culture);
     TextDomain := TextDomains.First;
     While TextDomain <> Nil Do
      Begin
       TextDomain.Properties.Define(Culture.Locale);
       TextDomain.Literals.Define(Culture.Locale);
       TextDomain := TextDomain.Next;
      End;
    End;
  End;

 Function TTranslationCatalog.Remove(Culture : TCultureInfo) : Boolean;
  Var
   TextDomain : TTextDomain;
  Begin
   Result := False;
   If (Culture <> Nil) And (fCultures.Remove(Culture) >= 0) Then
    Begin
     TextDomain := TextDomains.First;
     While TextDomain <> Nil Do
      Begin
       TextDomain.Properties.Undefine(Culture.Locale);
       TextDomain.Literals.Undefine(Culture.Locale);
       TextDomain := TextDomain.Next;
      End;
     Result := True;
    End;
  End;

 Procedure TTranslationCatalog.Assign(Source : TPersistent);
  Begin
   If Source Is TTranslationCatalog Then
    Begin
     fTextDomains.Assign(TTranslationCatalog(Source).TextDomains);
     fCultures.Assign(TTranslationCatalog(Source).Cultures);
     fNativeCulture := TTranslationCatalog(Source).NativeCulture;
     fCustomPluralRules.CopyFrom(TTranslationCatalog(Source).CustomPluralRules);
    End
   Else
    Inherited Assign(Source);
  End;

 Procedure TTranslationCatalog.Merge(Source : TTranslationCatalog; Options : TMergeOptions);
  Begin
   BeginUpdate;
   Try
    TextDomains.Merge(Source.TextDomains, Options);
    Source.CustomPluralRules.ForEach(
    Function(Const Culture : TCultureInfo; Const PluralRule : String) : Boolean
    Begin
    If moPreferSource In Options Then
    CustomPluralRules.AddOrUpdate(Culture, PluralRule)
    Else
    CustomPluralRules.Add(Culture, PluralRule);
    Result := True;
    End);
   Finally
    EndUpdate;
   End;
  End;

 Function TTranslationCatalog.StatsOf(Culture : TCultureInfo) : TTranslationStats;
  Var
   TextDomain : TTextDomain;
  Begin
   FillChar(Result, SizeOf(Result), 0);
   TextDomain := TextDomains.First;
   While TextDomain <> Nil Do
    Begin
     If Culture <> Nil Then
      Begin
       TextDomain.Properties.UpdateStats(Culture.Locale, Result);
       TextDomain.Literals.UpdateStats(Culture.Locale, Result);
      End
     Else
      Begin
       Inc(Result.Total, TextDomain.Properties.Count);
       Inc(Result.Total, TextDomain.Literals.Count);
      End;
     TextDomain := TextDomain.Next;
    End;
  End;

 Function TTranslationCatalog.PluralRuleOf(Culture : TCultureInfo) : String;
  Begin
   If Culture = Nil Then
    Begin
     If NativeCulture = Nil Then
      Culture := GetApplicationDefaultCulture
     Else
      Culture := NativeCulture;
    End;
   If Not CustomPluralRules.Retrieve(Culture, Result) Then
    Result := Culture.PluralRule;
  End;

 Procedure TTranslationCatalog.ChangePluralRuleOf(Culture : TCultureInfo; Const PluralRule : String);
  Begin
   If Culture <> Nil Then
    CustomPluralRules.AddOrUpdate(Culture, PluralRule);
  End;

 Function TTranslationCatalog.UseTranslation(Const OriginalText : String; Const TranslatedText : String; Culture : TCultureInfo; AffectedTranslations : TList) : Integer;
  Var
   OriginalLettersOnly : String;
   Count               : Integer;

   Procedure ApplyTo(Dictionary : TTextDictionary);
    Var
     Definition  : TTextDefinition;
     Translation : TTextTranslation;
    Begin
     Definition := Dictionary.First;
     While Definition <> Nil Do
      Begin
       Translation := Definition.Translations.Find(Culture.Locale);
       If (Translation <> Nil) And (Translation.State = tsNone) And
       (LettersOnly(Definition.Value) = OriginalLettersOnly) Then
        Begin
         Translation.Value := ModelTrivials(TranslatedText, OriginalText);
         Translation.State := tsAuto;
         If AffectedTranslations <> Nil Then
          AffectedTranslations.Add(Translation);
         Inc(Count);
        End;
       Definition := Definition.Next;
      End;
    End;
  Var
   TextDomain : TTextDomain;

  Begin
   Count := 0;
   If (NativeCulture <> Nil) And (OriginalText <> '') Then
    Begin
     OriginalLettersOnly := LettersOnly(OriginalText);
     TextDomain          := TextDomains.First;
     While TextDomain <> Nil Do
      Begin
       ApplyTo(TextDomain.Properties);
       ApplyTo(TextDomain.Literals);
       TextDomain := TextDomain.Next;
      End;
     If Repository <> Nil Then
      Repository.DefineSynonym(OriginalText, NativeCulture, TranslatedText, Culture);
    End;
   Result := Count;
  End;

 Function TTranslationCatalog.UseRepository(AffectedTranslations : TList) : Integer;
  Var
   Count : Integer;

   Procedure Process(Dictionary : TTextDictionary);
    Var
     Definition     : TTextDefinition;
     Translation    : TTextTranslation;
     TranslatedText : String;
     TargetLocale   : TCultureInfo;
    Begin
     TargetLocale := Nil;
     Definition   := Dictionary.First;
     While Definition <> Nil Do
      Begin
       Translation := Definition.Translations.First;
       While Translation <> Nil Do
        Begin
         If Not Translation.IsApproved And (Translation.State <> tsAuto) Then
          Begin
           If (TargetLocale = Nil) Or (TargetLocale.Locale <> Translation.Locale) Then
            TargetLocale := CultureOf(Translation.Locale);
           If Repository.FindSynonym(Definition.Value, NativeCulture, TargetLocale, TranslatedText) Then
            Begin
             Translation.Value := TranslatedText;
             Translation.State := tsAuto;
             If AffectedTranslations <> Nil Then
              AffectedTranslations.Add(Translation);
             Inc(Count);
            End;
          End;
         Translation := Translation.Next;
        End;
       Definition := Definition.Next;
      End;
    End;
  Var
   TextDomain : TTextDomain;

  Begin
   Count := 0;
   If (NativeCulture <> Nil) And (Repository <> Nil) Then
    Begin
     TextDomain := TextDomains.First;
     While TextDomain <> Nil Do
      Begin
       Process(TextDomain.Properties);
       Process(TextDomain.Literals);
       TextDomain := TextDomain.Next;
      End;
    End;
   Result := Count;
  End;

 Function TTranslationCatalog.UseRepository(Culture : TCultureInfo; AffectedTranslations : TList) : Integer;
  Var
   Count : Integer;

   Procedure Process(Dictionary : TTextDictionary);
    Var
     Definition     : TTextDefinition;
     Translation    : TTextTranslation;
     TranslatedText : String;
    Begin
     Definition := Dictionary.First;
     While Definition <> Nil Do
      Begin
       Translation := Definition.Translations.Find(Culture.Locale);
       If (Translation <> Nil) And Not Translation.IsApproved And (Translation.State <> tsAuto) And
       Repository.FindSynonym(Definition.Value, NativeCulture, Culture, TranslatedText) Then
        Begin
         Translation.Value := TranslatedText;
         Translation.State := tsAuto;
         If AffectedTranslations <> Nil Then
          AffectedTranslations.Add(Translation);
         Inc(Count);
        End;
       Definition := Definition.Next;
      End;
    End;
  Var
   TextDomain : TTextDomain;

  Begin
   Count := 0;
   If (NativeCulture <> Nil) And (Culture <> Nil) And (Repository <> Nil) Then
    Begin
     TextDomain := TextDomains.First;
     While TextDomain <> Nil Do
      Begin
       Process(TextDomain.Properties);
       Process(TextDomain.Literals);
       TextDomain := TextDomain.Next;
      End;
    End;
   Result := Count;
  End;

 Procedure TTranslationCatalog.SaveToXML(Const Document : IXMLDocument);
  Var
   TextDomain : TTextDomain;
  Begin
   Document.DocumentElement := Document.CreateElement('i18nCatalog', '');
   With Document.DocumentElement Do
    Begin
     Attributes['Version'] := '1.0';
     If NativeCulture <> Nil Then
      Attributes['Locale'] := NativeCulture.Locale;
     CustomPluralRules.ForEach(
     Function(Const Culture : TCultureInfo; Const PluralRule : String) : Boolean
     Begin
     If Cultures.Exists(Culture) And (Culture.PluralRule <> PluralRule) Then
     With AddChild('PluralForm') Do
     Begin
     Attributes['Locale'] := Culture.Locale;
     Attributes['Rule']   := PluralRule;
     End;
     Result := True;
     End);
     TextDomain := TextDomains.First;
     While TextDomain <> Nil Do
      Begin
       TextDomain.Save(AddChild('Domain'));
       TextDomain := TextDomain.Next;
      End;
    End;
  End;

 Procedure TTranslationCatalog.SaveToStream(Stream : TStream);
  Var
   Document          : IXMLDocument;
   CompressionStream : TCompressionStream;
  Begin
   Document := NewXMLDocument();
   Try
    Document.Options    := [doNodeAutoIndent];
    Document.StandAlone := 'yes';
    Document.Encoding   := 'utf-8';
    SaveToXML(Document);
    If Compressed Then
     Begin
      CompressionStream := TCompressionStream.Create(clDefault, Stream);
      Try
       Document.SaveToStream(CompressionStream);
      Finally
       CompressionStream.Free;
      End;
     End
    Else
     Document.SaveToStream(Stream);
   Finally
    Document := Nil;
   End;
  End;

 Procedure TTranslationCatalog.SaveToFile(Const FileName : String);
  Var
   Stream : TFileStream;
  Begin
   Stream := TFileStream.Create(NormalizePath(FileName), fmCreate);
   Try
    SaveToStream(Stream);
   Finally
    Stream.Free;
   End;
  End;

 Procedure TTranslationCatalog.LoadFromXML(Const Document : IXMLDocument);
  Var
   Culture   : TCultureInfo;
   ChildNode : IXMLNode;
   Locale    : String;
  Begin
   Clear;
   If (Document.DocumentElement = Nil) Or
   Not SameText(Document.DocumentElement.NodeName, 'i18nCatalog')
   Then
    Raise ETranslationCatalogError.CreateRes(@SCatalogLoadError1);
   BeginUpdate;
   Try
    Try
     If Document.DocumentElement.HasAttribute('Locale') Then
      Begin
       Locale         := Document.DocumentElement.Attributes['Locale'];
       fNativeCulture := CultureOf(Locale);
      End;
     If Document.DocumentElement.HasChildNodes Then
      Begin
       ChildNode := Document.DocumentElement.ChildNodes.First;
       While ChildNode <> Nil Do
        Begin
         Case AnsiIndexText(ChildNode.NodeName, ['Domain', 'PluralForm']) Of
          0 :
           TextDomains.Add(ChildNode);
          1 :
           With TPluralForms.Create(ChildNode.Attributes['Rule']) Do
            Try
             Culture := CultureOf(String(ChildNode.Attributes['Locale']));
             If Assigned(Culture) And (Culture.PluralRule <> Rule) Then
              CustomPluralRules.Add(Culture, Rule);
            Finally
             Free;
            End;
         End;
         ChildNode := ChildNode.NextSibling;
        End;
      End;
    Except
     On E : ETranslationCatalogError Do
      Raise;
     On E : Exception Do
      Begin
       Clear;
       Raise ETranslationCatalogError.CreateResFmt(@SCatalogLoadError2, [E.Message]);
      End;
    End;
   Finally
    EndUpdate;
   End;
  End;

 Procedure TTranslationCatalog.LoadFromStream(Stream : TStream);
  Var
   Document            : IXMLDocument;
   DecompressionStream : TDecompressionStream;
   IsCompressed        : Boolean;
  Begin
   IsCompressed := False;
   Document     := TXMLDocument.Create(Nil);
   Try
    Try
     If Not IsXML(Stream) Then
      Begin
       DecompressionStream := TDecompressionStream.Create(Stream);
       Try
        Document.LoadFromStream(DecompressionStream);
        IsCompressed := True;
       Finally
        DecompressionStream.Free;
       End;
      End
     Else
      Document.LoadFromStream(Stream);
    Except
     On E : Exception Do
      Begin
       Clear;
       Raise ETranslationCatalogError.CreateResFmt(@SCatalogLoadError2, [E.Message]);
      End;
    End;
    LoadFromXML(Document);
    Compressed := IsCompressed;
   Finally
    Document := Nil;
   End;
  End;

 Procedure TTranslationCatalog.LoadFromFile(Const FileName : String);
  Var
   Stream : TFileStream;
  Begin
   Stream := TFileStream.Create(NormalizePath(FileName), fmOpenRead Or fmShareDenyWrite);
   Try
    LoadFromStream(Stream);
   Finally
    Stream.Free;
   End;
  End;

 Procedure TTranslationCatalog.LoadFromResource(hInstance : HINST; Const ResName : String; ResType : PChar);
  Var
   Stream : TResourceStream;
  Begin
   Stream := TResourceStream.Create(hInstance, ResName, ResType);
   Try
    LoadFromStream(Stream);
   Finally
    Stream.Free;
   End;
  End;

 Procedure TTranslationCatalog.LoadFromResource(hInstance : HINST; ResID : Integer; ResType : PChar);
  Var
   Stream : TResourceStream;
  Begin
   Stream := TResourceStream.CreateFromID(hInstance, ResID, ResType);
   Try
    LoadFromStream(Stream);
   Finally
    Stream.Free;
   End;
  End;

 Procedure TTranslationCatalog.LoadFromFiles(FileNames : TStrings; IgnoreErrors : Boolean);
  Var
   SubCatalog : TTranslationCatalog;
   i          : Integer;
  Begin
   Clear;
   If FileNames.Count <> 0 Then
    Begin
     BeginUpdate;
     Try
      SubCatalog := TTranslationCatalog.Create;
      Try
       SubCatalog.EndUpdate; // intentionally without BeginUpdate
       For i := 0 To FileNames.Count - 1 Do
        Begin
         Try
          SubCatalog.LoadFromFile(FileNames[i]);
         Except
          On E : Exception Do
           Begin
            If Not(E Is ETranslationCatalogError) Or Not IgnoreErrors Then
             Begin
              Clear;
              Raise;
             End;
            Continue;
           End;
         End;
         If NativeCulture = Nil Then
          NativeCulture := SubCatalog.NativeCulture;
         Merge(SubCatalog);
        End;
      Finally
       SubCatalog.Free;
      End;
     Finally
      EndUpdate;
     End;
    End;
  End;

 Procedure TTranslationCatalog.LoadFromDirectory(Const Path : String; IncludeSubDirs : Boolean; Const FileMask : String; IgnoreErrors : Boolean);
  Var
   Files : TStringList;
   Mask  : String;

   Procedure Search(Const Dir : String);
    Var
     f : TSearchRec;
    Begin
     If FindFirst(Dir + Mask, faAnyFile And Not faDirectory, f) = 0 Then
      Begin
       Repeat
        Files.Add(Dir + f.Name);
       Until FindNext(f) <> 0;
       FindClose(f);
      End;
     If IncludeSubDirs And (FindFirst(Dir + '*.*', faDirectory, f) = 0) Then
      Begin
       Repeat
        If LongBool(f.Attr And faDirectory) And (f.Name <> '.') And (f.Name <> '..') Then
         Search(Dir + f.Name + '\');
       Until FindNext(f) <> 0;
       FindClose(f);
      End;
    End;
  Var
   SearchPath : String;

  Begin
   SearchPath := IncludeTrailingPathDelimiter(NormalizePath(Path));
   If Not DirectoryExists(SearchPath) Then
    Begin
     {$IFDEF COMPILER2010_UP}
     Raise EDirectoryNotFoundException.CreateFmt(SDirNotFoundError, [SearchPath]);
     {$ELSE}
     Raise Exception.CreateFmt(SDirNotFoundError, [SearchPath]);
     {$ENDIF}
    End;
   If FileMask = '' Then
    Mask := '*' + i18nCatalogFileExt
   Else
    Mask := FileMask;
   Files := TStringList.Create;
   Try
    Search(SearchPath);
    LoadFromFiles(Files, IgnoreErrors);
   Finally
    Files.Free;
   End;
  End;

 Procedure TTranslationCatalog.Open(Const URI : String);
  Var
   Schema, Path      : String;
   FileDir, FileMask : String;
   ResName, ResType  : String;
  Begin
   If Pos(':', URI) > 2 Then
    Begin
     Schema := LowerCase(Copy(URI, 1, Pos(':', URI) - 1));
     Path   := Copy(URI, Length(Schema) + 2, Length(URI) - Length(Schema) - 1);
    End
   Else
    Begin
     Schema := 'file';
     Path   := URI;
    End;
   Try
    If Schema = 'file' Then
     LoadFromFile(Path)
    Else If (Schema = 'dir') Or (Schema = 'dirx') Then
     Begin
      FileDir  := ExtractFilePath(Path);
      FileMask := ExtractFileName(Path);
      LoadFromDirectory(FileDir, Schema = 'dirx', FileMask);
     End
    Else If Schema = 'res' Then
     Begin
      If Pos('.', Path) = 0 Then
       LoadFromResource(hInstance, Path)
      Else
       Begin
        ResName := Copy(Path, 1, Pos('.', Path) - 1);
        ResType := Copy(Path, Pos('.', Path) + 1, MaxInt);
        LoadFromResource(hInstance, ResName, PChar(ResType));
       End;
     End
    Else
     Begin
      {$IFDEF COMPILER2010_UP}
      Raise ENotSupportedException.CreateFmt(SSchemaError, [Schema]);
      {$ELSE}
      Raise Exception.CreateFmt(SSchemaError, [Schema]);
      {$ENDIF}
     End;
   Except
    Clear;
    Raise;
   End;
  End;

{ TTranslationRepository }

 Constructor TTranslationRepository.Create;
  Begin
   Relations           := TObjectList.Create(True);
   Items               := TStringList.Create;
   Items.OwnsObjects   := True;
   Items.CaseSensitive := True;
   Items.Duplicates    := dupAccept;
   Items.Sorted        := True;
  End;

 Destructor TTranslationRepository.Destroy;
  Begin
   Items.Free;
   Relations.Free;
   Inherited Destroy;
  End;

 Function TTranslationRepository.GetPhraseCount : Integer;
  Begin
   Result := Items.Count;
  End;

 Function TTranslationRepository.GetRelationCount : Integer;
  Begin
   Result := Relations.Count;
  End;

 Procedure TTranslationRepository.Clear;
  Begin
   Items.Clear;
   Relations.Clear;
   fModified := False;
  End;

 Function TTranslationRepository.Empty : Boolean;
  Begin
   Result := (Relations.Count = 0);
  End;

 Function TTranslationRepository.CreateRelationship : TStringList;
  Begin
   Result               := TStringList.Create;
   Result.Duplicates    := dupAccept;
   Result.CaseSensitive := True;
   Result.Sorted        := True;
   Relations.Add(Result);
  End;

 Function TTranslationRepository.KeyOf(Const Text : String; Culture : TCultureInfo) : String;
  Begin
   Result := Culture.Language2 + GetStringIdentifier(LettersOnly(Text));
  End;

 Function TTranslationRepository.Find(Const Text : String; Culture : TCultureInfo; Out Item : TTranslationRepositoryItem) : Boolean;
  Var
   Index : Integer;
  Begin
   Result := False;
   If Culture <> Nil Then
    Begin
     If Items.Find(KeyOf(Text, Culture), Index) Then
      Begin
       Item   := TTranslationRepositoryItem(Items.Objects[Index]);
       Result := True;
      End;
    End;
  End;

 Function TTranslationRepository.FindOrCreate(Const Text : String; Culture : TCultureInfo) : TTranslationRepositoryItem;
  Begin
   Result := FindOrCreate(KeyOf(Text, Culture), Text, Culture);
  End;

 Function TTranslationRepository.FindOrCreate(Const Key, Text : String; Culture : TCultureInfo) : TTranslationRepositoryItem;
  Var
   Index          : Integer;
   NormalizedText : String;
  Begin
   NormalizedText := TrimTrivials(Text);
   If Items.Find(Key, Index) Then
    Repeat
     Result := TTranslationRepositoryItem(Items.Objects[Index]);
     If Result.Text = NormalizedText Then
      Exit;
     Inc(Index);
    Until(Index >= Items.Count) Or (Items[Index] <> Key);
   Result         := TTranslationRepositoryItem.Create;
   Result.Key     := Key;
   Result.Culture := Culture;
   Result.Text    := NormalizedText;
   Items.AddObject(Key, Result);
   fModified := True;
  End;

 Procedure TTranslationRepository.Relate(Item1, Item2 : TTranslationRepositoryItem);
  Var
   Relation : TStringList;
   i        : Integer;
  Begin
   If Item1.Relatives <> Item2.Relatives Then
    Begin
     If Item1.Relatives = Nil Then
      Begin
       Item1.Relatives := Item2.Relatives;
       Item1.Relatives.AddObject(Item1.Culture.Language2, Item1);
      End
     Else If Item2.Relatives = Nil Then
      Begin
       Item2.Relatives := Item1.Relatives;
       Item2.Relatives.AddObject(Item2.Culture.Language2, Item2);
      End
     Else
      Begin
       Relation := Item2.Relatives;
       For i    := Relation.Count - 1 Downto 0 Do
        If Item1.Relatives.IndexOfObject(Relation.Objects[i]) < 0 Then
         Item1.Relatives.AddObject(Relation.Strings[i], Relation.Objects[i]);
       For i := Items.Count - 1 Downto 0 Do
        If TTranslationRepositoryItem(Items.Objects[i]).Relatives = Relation Then
         TTranslationRepositoryItem(Items.Objects[i]).Relatives := Item1.Relatives;
       Relations.Remove(Relation);
      End;
     fModified := True;
    End
   Else If (Item1.Relatives = Nil) And (Item1 <> Item2) Then
    Begin
     Relation := CreateRelationship;
     Relation.AddObject(Item1.Culture.Language2, Item1);
     Item1.Relatives := Relation;
     Relation.AddObject(Item2.Culture.Language2, Item2);
     Item2.Relatives := Relation;
     fModified       := True;
    End;
  End;

 Function TTranslationRepository.Remove(Const Text : String; Culture : TCultureInfo) : Boolean;
  Var
   Item                : TTranslationRepositoryItem;
   Relatives           : TStringList;
   Index               : Integer;
   Key, NormalizedText : String;
  Begin
   Result := False;
   If Culture <> Nil Then
    Begin
     Key := KeyOf(Text, Culture);
     If Items.Find(Key, Index) Then
      Begin
       NormalizedText := TrimTrivials(Text);
       Repeat
        Item := TTranslationRepositoryItem(Items.Objects[Index]);
        If Item.Text = NormalizedText Then
         Begin
          Relatives := Item.Relatives;
          Items.Delete(Index);
          Index := Relatives.IndexOfObject(Item);
          If Index >= 0 Then
           Relatives.Delete(Index);
          If Relatives.Count = 1 Then
           Begin
            Item  := TTranslationRepositoryItem(Relatives.Objects[0]);
            Index := Items.IndexOfObject(Item);
            If Index >= 0 Then
             Items.Delete(Index);
            Relatives.Clear;
           End;
          If Relatives.Count = 0 Then
           Relations.Remove(Relatives);
          Result    := True;
          fModified := True;
          Exit;
         End;
        Inc(Index);
       Until(Index >= Items.Count) Or (Items[Index] <> Key);
      End
    End;
  End;

 Function TTranslationRepository.DefineSynonym(Const Text1 : String; Culture1 : TCultureInfo; Const Text2 : String; Culture2 : TCultureInfo) : Boolean;
  Var
   Item1, Item2 : TTranslationRepositoryItem;
  Begin
   Result := False;
   If (Text1 <> '') And (Text2 <> '') And
   (Culture1 <> Nil) And (Culture2 <> Nil) And
   ((Culture1 <> Culture2) Or (Text1 <> Text2)) Then
    Begin
     Item1 := FindOrCreate(Text1, Culture1);
     Inc(Item1.Hits);
     Item2 := FindOrCreate(Text2, Culture2);
     Inc(Item2.Hits);
     Relate(Item1, Item2);
     Result := True;
    End;
  End;

 Function TTranslationRepository.HasSynonym(Const SourceText : String; SourceCulture, TargetCulture : TCultureInfo) : Boolean;
  Var
   Item : TTranslationRepositoryItem;
  Begin
   Result := (SourceCulture <> Nil) And (TargetCulture <> Nil)
   And (SourceCulture.IsDialectOf(TargetCulture) Or
   (Find(SourceText, SourceCulture, Item) And
   (Item.Relatives.IndexOf(TargetCulture.Language2) >= 0)));
  End;

 Function TTranslationRepository.FindSynonym(Const SourceText : String; SourceCulture, TargetCulture : TCultureInfo; Out Synonym : String) : Boolean;
  Var
   Item, PreferedItem : TTranslationRepositoryItem;
   Relatives          : TStringList;
   i                  : Integer;
  Begin
   If SourceCulture = TargetCulture Then
    Begin
     Synonym := SourceText;
     Result  := True;
    End
   Else
    Begin
     Result := False;
     If (SourceCulture <> Nil) And (TargetCulture <> Nil) Then
      Begin
       If Find(SourceText, SourceCulture, Item) And
       Item.Relatives.Find(TargetCulture.Language2, i) Then
        Begin
         Relatives    := Item.Relatives;
         PreferedItem := TTranslationRepositoryItem(Relatives.Objects[i]);
         For i        := i + 1 To Relatives.Count - 1 Do
          Begin
           Item := TTranslationRepositoryItem(Relatives.Objects[i]);
           If Not Item.Culture.IsDialectOf(TargetCulture) Then
            Break
           Else If Item.Hits > PreferedItem.Hits Then
            PreferedItem := Item;
          End;
         Synonym := ModelTrivials(PreferedItem.Text, SourceText);
         Result  := True;
        End
       Else If SourceCulture.IsDialectOf(TargetCulture) Then
        Begin
         Synonym := SourceText;
         Result  := True;
        End
       Else If TrimTrivials(SourceText) = '' Then
        Begin
         Synonym := SourceText;
         Result  := True;
        End;
      End;
    End;
  End;

 Function TTranslationRepository.FindAllSynonyms(Const SourceText : String; SourceCulture, TargetCulture : TCultureInfo; Synonyms : TStrings) : Integer;
  Var
   Item                   : TTranslationRepositoryItem;
   Relatives              : TStringList;
   Synonym, EscapedSource : String;
   i                      : Integer;
  Begin
   Result := 0;
   If (SourceCulture <> Nil) And (TargetCulture <> Nil) Then
    Begin
     Synonyms.BeginUpdate;
     Try
      If Find(SourceText, SourceCulture, Item) And
      Item.Relatives.Find(TargetCulture.Language2, i) Then
       Begin
        Relatives := Item.Relatives;
        For i     := i To Relatives.Count - 1 Do
         Begin
          Item := TTranslationRepositoryItem(Relatives.Objects[i]);
          If Not Item.Culture.IsDialectOf(TargetCulture) Then
           Break;
          Synonym := ModelTrivials(Item.Text, SourceText);
          Synonyms.AddObject(EscapeString(Synonym), TObject(Item.Hits));
          Inc(Result);
         End;
       End
      Else If TrimTrivials(SourceText) = '' Then
       Begin
        Synonyms.Add(EscapeString(SourceText));
        Inc(Result);
       End;
      If SourceCulture.IsDialectOf(TargetCulture) Then
       Begin
        EscapedSource := EscapeString(SourceText);
        i             := Synonyms.IndexOf(EscapedSource);
        If SourceCulture = TargetCulture Then
         Begin
          If i < 0 Then
           Begin
            Synonyms.AddObject(EscapedSource, TObject(MaxInt));
            Inc(Result);
           End
          Else
           Synonyms.Objects[i] := TObject(MaxInt);
         End
        Else If i < 0 Then
         Begin
          Synonyms.Add(EscapedSource);
          Inc(Result);
         End;
       End;
     Finally
      Synonyms.EndUpdate;
     End;
    End;
  End;

 Procedure TTranslationRepository.Learn(Catalog : TTranslationCatalog);

   Procedure LearnFrom(Dictionary : TTextDictionary);
    Var
     Definition       : TTextDefinition;
     Translation      : TTextTranslation;
     DefItem, TraItem : TTranslationRepositoryItem;
    Begin
     Definition := Dictionary.First;
     While Definition <> Nil Do
      Begin
       DefItem     := Nil;
       Translation := Definition.Translations.First;
       While Translation <> Nil Do
        Begin
         If Translation.IsApproved Then
          Begin
           If DefItem = Nil Then
            Begin
             DefItem := FindOrCreate(Definition.Value, Catalog.NativeCulture);
             Inc(DefItem.Hits);
            End;
           TraItem := FindOrCreate(Translation.Value, CultureOf(Translation.Locale));
           Inc(TraItem.Hits);
           Relate(DefItem, TraItem);
          End;
         Translation := Translation.Next;
        End;
       Definition := Definition.Next;
      End;
    End;
  Var
   TextDomain : TTextDomain;

  Begin
   If Not Catalog.Empty And (Catalog.NativeCulture <> Nil) Then
    Begin
     TextDomain := Catalog.TextDomains.First;
     While TextDomain <> Nil Do
      Begin
       LearnFrom(TextDomain.Properties);
       LearnFrom(TextDomain.Literals);
       TextDomain := TextDomain.Next;
      End;
    End;
  End;

 Procedure TTranslationRepository.Merge(Repository : TTranslationRepository);
  Var
   Synonyms   : TStringList;
   Base, This : TTranslationRepositoryItem;
   i, j       : Integer;
  Begin
   For i := 0 To Repository.Relations.Count - 1 Do
    Begin
     Base     := Nil;
     Synonyms := TStringList(Repository.Relations[i]);
     For j    := 0 To Synonyms.Count - 1 Do
      Begin
       With TTranslationRepositoryItem(Synonyms.Objects[j]) Do
        Begin
         This := FindOrCreate(Key, Text, Culture);
         Inc(This.Hits, Hits);
        End;
       If Base <> Nil Then
        Relate(Base, This);
       Base := This;
      End;
    End;
  End;

 Procedure TTranslationRepository.SaveToXML(Const Document : IXMLDocument);
  Var
   Relatives : TStringList;
   Item      : TTranslationRepositoryItem;
   i, j      : Integer;
  Begin
   Document.DocumentElement := Document.CreateElement('i18nRepository', '');
   With Document.DocumentElement Do
    Begin
     Attributes['Version'] := '1.0';
     For i                 := 0 To Relations.Count - 1 Do
      Begin
       Relatives := TStringList(Relations[i]);
       If Relatives.Count <> 0 Then
        With AddChild('Synonyms') Do
         Begin
          For j := 0 To Relatives.Count - 1 Do
           Begin
            Item := TTranslationRepositoryItem(Relatives.Objects[j]);
            With AddChild('Text') Do
             Begin
              Attributes['Locale'] := Item.Culture.Locale;
              If Item.Hits <> 0 Then
               Attributes['Hits'] := Item.Hits;
              Text                := EscapeString(Item.Text);
             End;
           End;
         End;
      End;
    End;
   fModified := False;
  End;

 Procedure TTranslationRepository.SaveToStream(Stream : TStream);
  Var
   Document : IXMLDocument;
  Begin
   Document := NewXMLDocument();
   Try
    Document.Options    := [doNodeAutoIndent];
    Document.StandAlone := 'yes';
    Document.Encoding   := 'utf-8';
    SaveToXML(Document);
    Document.SaveToStream(Stream);
   Finally
    Document := Nil;
   End;
  End;

 Procedure TTranslationRepository.SaveToFile(Const FileName : String);
  Var
   Stream : TFileStream;
  Begin
   Stream := TFileStream.Create(NormalizePath(FileName), fmCreate);
   Try
    SaveToStream(Stream);
   Finally
    Stream.Free;
   End;
  End;

 Procedure TTranslationRepository.LoadFromXML(Const Document : IXMLDocument);
  Var
   SynNode, ItemNode : IXMLNode;
   Relatives         : TStringList;
   Item              : TTranslationRepositoryItem;
  Begin
   Clear;
   If (Document.DocumentElement = Nil) Or
   Not SameText(Document.DocumentElement.NodeName, 'i18nRepository')
   Then
    Raise ETranslationRepositoryError.CreateRes(@SRepositoryLoadError1);
   If Document.DocumentElement.HasChildNodes Then
    Begin
     Try
      SynNode := Document.DocumentElement.ChildNodes.First;
      While SynNode <> Nil Do
       Begin
        If SameText(SynNode.NodeName, 'Synonyms') And SynNode.HasChildNodes Then
         Begin
          Relatives := CreateRelationship;
          ItemNode  := SynNode.ChildNodes.First;
          While ItemNode <> Nil Do
           Begin
            If SameText(ItemNode.NodeName, 'Text') Then
             Begin
              Item := TTranslationRepositoryItem.Create;
              Try
               Item.Relatives := Relatives;
               Item.Culture   := CultureOf(String(ItemNode.Attributes['Locale']));
               Item.Text      := UnescapeString(ItemNode.Text);
               If ItemNode.HasAttribute('Key') Then
                Item.Key := ItemNode.Attributes['Key']
               Else
                Item.Key := KeyOf(Item.Text, Item.Culture);
               If ItemNode.HasAttribute('Hits') Then
                Item.Hits := ItemNode.Attributes['Hits'];
               Relatives.AddObject(Item.Culture.Language2, Item);
               Items.AddObject(Item.Key, Item);
              Except
               Item.Free;
              End;
             End;
            ItemNode := ItemNode.NextSibling;
           End;
         End;
        SynNode := SynNode.NextSibling;
       End;
     Except
      On E : Exception Do
       Begin
        Clear;
        Raise ETranslationRepositoryError.CreateResFmt(@SRepositoryLoadError2, [E.Message]);
       End;
     End;
    End;
  End;

 Procedure TTranslationRepository.LoadFromStream(Stream : TStream);
  Var
   Document : IXMLDocument;
  Begin
   Document := TXMLDocument.Create(Nil);
   Try
    Try
     Document.LoadFromStream(Stream);
    Except
     On E : ETranslationRepositoryError Do
      Raise;
     On E : Exception Do
      Begin
       Clear;
       Raise ETranslationRepositoryError.CreateResFmt(@SRepositoryLoadError2, [E.Message]);
      End;
    End;
    LoadFromXML(Document);
   Finally
    Document := Nil;
   End;
  End;

 Procedure TTranslationRepository.LoadFromFile(Const FileName : String);
  Var
   Stream : TFileStream;
  Begin
   Stream := TFileStream.Create(NormalizePath(FileName), fmOpenRead Or fmShareDenyWrite);
   Try
    LoadFromStream(Stream);
   Finally
    Stream.Free;
   End;
  End;

End.
