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
/// This unit implements the localization components.
/// </summary>
Unit i18nLocalizer;

{$I DELPHIAREA.INC}

Interface

 Uses
  Windows, Messages, SysUtils, Classes, Controls,
  i18nCore, i18nCatalog, i18nPlurals, i18nCalendar, i18nHashList;

 Type
  TLocalizer  = Class;
  TTranslator = Class;

{$Region 'xmldoc'}
/// <summary>
/// TTranslatables maintains the list of translatable properties and string
/// literals.
/// </summary>
{$Endregion}

  TTranslatables = Class(TPersistent)
   Private
    fTranslator : TTranslator;
    fProperties : TTextItems;
    fLiterals   : TTextItems;
    Function GetDomainName : String;
    Function GetDomainOwner : TComponent;
    Procedure ReadProperties(Reader : TReader);
    Procedure WriteProperties(Writer : TWriter);
    Procedure ReadLiterals(Reader : TReader);
    Procedure WriteLiterals(Writer : TWriter);
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Reads and writes the content of <see cref="Properties"/> and <see cref="Literals"/>
    /// properties as if they were published.
    /// </summary>
    /// <param name="Filer">
    /// The current <see cref="TReader"/> or <see cref="TWriter"/> object that is
    /// loading or saving the published properties.
    /// </param>
    {$Endregion}
    Procedure DefineProperties(Filer : TFiler); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Specifies the object that owns this object.
    /// </summary>
    /// <returns>
    /// Returns the object that owns this object
    /// </returns>
    {$Endregion}
    Function GetOwner : TPersistent; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Normalizes translatable properties by removing the invalid entries,
    /// and retrieving their original values.
    /// </summary>
    {$Endregion}
    Procedure NormalizeProperties;
    {$Region 'xmldoc'}
    /// <summary>
    /// Copies value of the translatable properties to the actual properties.
    /// </summary>
    {$Endregion}
    Procedure ApplyProperties;
    {$Region 'xmldoc'}
    /// <summary>
    /// Reverts value of translatable items to their original values.
    /// </summary>
    {$Endregion}
    Procedure DiscardTranslations;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the class.
    /// </summary>
    /// <param name="ATranslator">
    /// The <see cref="TTranslator"/> component that owns this instance.
    /// </param>
    {$Endregion}
    Constructor Create(ATranslator : TTranslator);
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
    /// Gets the top level component that owns the translatable properties and
    /// string literals.
    /// </summary>
    /// <seealso cref="DomainName"/>
    {$Endregion}
    Property DomainOwner : TComponent Read GetDomainOwner;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the name of the text domain that maintains the translatable properties
    /// and string literals.
    /// </summary>
    /// <seealso cref="DomainOwner"/>
    {$Endregion}
    Property DomainName : String Read GetDomainName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the translatable properties.
    /// </summary>
    /// <seealso cref="Literals"/>
    {$Endregion}
    Property Properties : TTextItems Read fProperties;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the translatable string literals.
    /// </summary>
    /// <seealso cref="Properties"/>
    {$Endregion}
    Property Literals : TTextItems Read fLiterals;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the <see cref="TTranslator"/> component that owns this object.
    /// </summary>
    {$Endregion}
    Property Translator : TTranslator Read fTranslator;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This enumeration type identifies the notifications of the <see cref="TLocalizer"/>
/// component.
/// </summary>
{$Endregion}

  TLocalizerNotification = (
  {$Region 'xmldoc'}
  /// The content of the <see cref="TLocalizer"/> component is about to be changed.
  {$Endregion}
  lnChanging,
  {$Region 'xmldoc'}
  /// The content of the <see cref="TLocalizer"/> component is changed.
  {$Endregion}
  lnChanged,
  {$Region 'xmldoc'}
  /// The translation catalog of the <see cref="TLocalizer"/> component is about to be changed.
  {$Endregion}
  lnCatalogChanging,
  {$Region 'xmldoc'}
  /// The translation catalog of the <see cref="TLocalizer"/> component is changed.
  {$Endregion}
  lnCatalogChanged,
  {$Region 'xmldoc'}
  /// The <see cref="TLocalizer.Culture"/> property is about to be changed.
  {$Endregion}
  lnCultureChanging,
  {$Region 'xmldoc'}
  /// The <see cref="TLocalizer.Culture"/> property is changed.
  {$Endregion}
  lnCultureChanged,
  {$Region 'xmldoc'}
  /// The <see cref="TLocalizer.BiDiMode"/> property is about to be changed.
  {$Endregion}
  lnBiDiModeChanging,
  {$Region 'xmldoc'}
  /// The <see cref="TLocalizer.BiDiMode"/> property is changed.
  {$Endregion}
  lnBiDiModeChanged,
  {$Region 'xmldoc'}
  /// The <see cref="TLocalizer.Options"/> property is about to be changed.
  {$Endregion}
  lnOptionsChanging,
  {$Region 'xmldoc'}
  /// The <see cref="TLocalizer.Options"/> property is changed.
  {$Endregion}
  lnOptionsChanged
  );

{$Region 'xmldoc'}
/// <summary>
/// ILocalizerLink interface lets an object to be notified about changes in one
/// or more <see cref="TLocalizer"/> components.
/// </summary>
/// <remarks>
/// Use ILocalizerLink interface when defining objects that can be linked to one
/// or more instances of <see cref="TLocalizer"/> components.
/// </remarks>
/// <seealso cref="TLocalizer.RegisterListener"/>
/// <seealso cref="TLocalizer.UnregisterListener"/>
{$Endregion}

  ILocalizerLink = Interface
   {$Region 'xmldoc'}
   /// <summary>
   /// Notifies that a linked <see cref="TLocalizer"/> component is changed.
   /// </summary>
   /// <param name="Sender">
   /// The <see cref="TLocalizer"/> component who originated the notification.
   /// </param>
   /// <param name="Reason">
   /// The reason of the notification.
   /// </param>
   {$Endregion}
   Procedure LocalizerNotify(Sender : TLocalizer; Reason : TLocalizerNotification);
  End;

{$Region 'xmldoc'}
/// <summary>
/// This enumeration type identifies the ways to determine the state of a flag that
/// is also manageable by a <see cref="TLocalizer"/> component.
/// </summary>
{$Endregion}

  TLocalizerSwicth = (
  {$Region 'xmldoc'}
  /// The flag is only on if it is activated in the related <see cref="TLocalizer"/>
  /// component. Otherwise the flag is off.
  {$Endregion}
  lsDefault,
  {$Region 'xmldoc'}
  /// The flag is always on regardless of its state in the related
  /// <see cref="TLocalizer"/> component.
  {$Endregion}
  lsAlways,
  {$Region 'xmldoc'}
  /// The flag is always off regardless of its state in the related
  /// <see cref="TLocalizer"/> component.
  {$Endregion}
  lsNever
  );

{$Region 'xmldoc'}
/// <summary>
/// This enumeration type identifies the possible options that can be selected
/// in a <see cref="TLocalizer"/> component.
/// </summary>
{$Endregion}

  TLocalizerOption = (
  {$Region 'xmldoc'}
  /// Automatically selects the active culture based on the user's locale settings.
  {$Endregion}
  loAutoSetectLanguage,
  {$Region 'xmldoc'}
  /// Sets BiDiMode of the application according to the active culture.
  {$Endregion}
  loAdjustApplicationBiDiMode,
  {$Region 'xmldoc'}
  /// Translates format settings according to the active culture.
  {$Endregion}
  loAdjustFormatSettings,
  {$Region 'xmldoc'}
  /// Loads the approperiate keyboard layout according to the active culture.
  {$Endregion}
  loAdjustKeyboardLayout,
  {$Region 'xmldoc'}
  /// When formatting numbers and date-time values, uses native digits of
  /// the active culture.
  {$Endregion}
  loUseNativeDigits,
  {$Region 'xmldoc'}
  /// When formatting dates, uses the active culture's calendar system instead
  /// of the default Gregorian Calendar.
  {$Endregion}
  loUseNativeCalendar
  );

{$Region 'xmldoc'}
/// <summary>
/// This data type represents the set of options that are selected in a
/// <see cref="TLocalizer"/> component.
/// </summary>
{$Endregion}

  TLocalizerOptions = Set Of TLocalizerOption;

{$Region 'xmldoc'}
/// <summary>
/// TLocalizerNotifyEvent is the type for event handlers that respond when a
/// <see cref="TLocalizer"/> component sends a notification.
/// </summary>
/// <param name="Sender">
/// The object that generated the event.
/// </param>
/// <param name="Reason">
/// The reason of the notification.
/// </param>
{$Endregion}

  TLocalizerNotifyEvent = Procedure(Sender : TObject; Reason : TLocalizerNotification) Of Object;

{$Region 'xmldoc'}
/// <summary>
/// TLocalizer provides the core functionality for localizing an application.
/// </summary>
/// <remarks>
/// <para>
/// TLocalizer provides properties and methods to manage how deep an application
/// should be localized.
/// </para>
/// <para>
/// TLocalizer can control the formatting parameters, the calendar system, the
/// keyboard layout, and the application's bi-directional mode based on the selected
/// locale.
/// </para>
/// <para>
/// TLocalizer loads the translation catalog from an application's resource, a file,
/// or a directory. Then, it provides a list of <see cref="TCultureInfo"/> objects
/// that represent the available translation languages. By selecting one of these
/// <see cref="TCultureInfo"/> objects, TLocalizer automatically updates the locale
/// specific settings of the application and notifies the linked <see cref="TTranslator"/>
/// components to update the user interface of the application according to the selected
/// language.
/// </para>
/// <para>
/// Each application needs only one instance of the TLocalizer component. However,
/// you can have more than one instance whenever it is needed. For example, suppose
/// an application that can print reports in a language different from the user
/// interface language. In this case, the application needs one instance of the
/// TLocalizer component for managing the user interface and another one for handling
/// the reports.
/// </para>
/// <para>
/// It is highly recommended to use formatting functions of TLocalizer component to
/// format values in your application. In this way, you have full control on how the
/// localization should affect the formatting of values by just adjusting the properties
/// of the TLocalizer component.
/// </para>
/// </remarks>
/// <seealso cref="TTranslator"/>
/// <group name="Components"/>
{$Endregion}
{$IFDEF COMPILER_XE2_UP}

  [ComponentPlatformsAttribute(pidWin32 Or pidWin64)]
  {$ENDIF}
  TLocalizer = Class(TComponent)
   Private
    Class Var
    TheFirstInstance : TLocalizer;
   Private
    fURI            : String;
    fCatalog        : TTranslationCatalog;
    fPluralForms    : TPluralForms;
    fOptions        : TLocalizerOptions;
    fCulture        : TCultureInfo;
    fClients        : TList;
    fOnNotification : TLocalizerNotifyEvent;
    fBiDiToggled    : Boolean;
    fUpdateCount    : Integer;
    Function GetCultures : TReadonlyCultureList;
    Procedure SetURI(Const Value : String);
    Procedure SetCulture(Value : TCultureInfo);
    Function GetCultureIndex : Integer;
    Procedure SetCultureIndex(Value : Integer);
    Procedure SetOptions(Value : TLocalizerOptions);
    Function GetBiDiMode : TBiDiMode;
    Procedure ReadTargetCulture(Reader : TReader);
    Procedure WriteTargetCulture(Writer : TWriter);
   Protected
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
    /// Initializes the component when it is first loaded into memory.
    /// </summary>
    {$Endregion}
    Procedure Loaded; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Notifies the linked objects with a <see cref="TLocalizerNotification"/> of
    /// lnChanging.
    /// </summary>
    {$Endregion}
    Procedure BeginUpdate; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Notifies the linked objects with a <see cref="TLocalizerNotification"/> of
    /// lnChanged.
    /// </summary>
    {$Endregion}
    Procedure EndUpdate; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnNotification"/> event.
    /// </summary>
    /// <param name="Reason">
    /// The reason of the notification.
    /// </param>
    {$Endregion}
    Procedure DoNotification(Reason : TLocalizerNotification); Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Loads the translation catalog from the location specified by the <see cref="URI"/>
    /// property.
    /// </summary>
    {$Endregion}
    Procedure ReloadCatalog; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Performs the required actions when the active culture changes.
    /// </summary>
    /// <remarks>
    /// <para>
    /// ApplyCultureChanges updates the plural rule of <see cref="PluralForms"/>
    /// object based on the currently active language and notifies the linked
    /// objects with a <see cref="TLocalizerNotification"/> of lnCultureChanged.
    /// </para>
    /// <para>
    /// Depending on the value of the <see cref="Options"/> property, ApplyCultureChanges
    /// may also call <see cref="AdjustApplicationBiDi"/>, <see cref="AdjustKeyboardLayout"/>,
    /// and <see cref="AdjustFormatSettings"/> methods.
    /// </para>
    /// </remarks>
    {$Endregion}
    Procedure ApplyCultureChanges; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Sets the BiDiMode property of the application according to the language's
    /// direction of the currently active culture.
    /// NOTE: This method is called automatically if loAdjustApplicationBiDiMode
    /// is toggled on in the component's <see cref="Options"/>.
    /// </summary>
    /// <seealso cref="AdjustKeyboardLayout"/>
    /// <seealso cref="AdjustFormatSettings"/>
    {$Endregion}
    Procedure AdjustApplicationBiDi; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Loads the proper keyboard layout based on the locale of the currently active
    /// culture.
    /// NOTE: This method is called automatically if loAdjustKeyboardLayout is
    /// toggled on in the component's <see cref="Options"/>.
    /// </summary>
    /// <seealso cref="AdjustApplicationBiDi"/>
    /// <seealso cref="AdjustFormatSettings"/>
    {$Endregion}
    Procedure AdjustKeyboardLayout; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Updates the global format settings of the application according to the locale
    /// of the currently active culture.
    /// NOTE: This method is called automatically if loAdjustFormatSettings is
    /// toggled on in the component's <see cref="Options"/>.
    /// </summary>
    /// <seealso cref="AdjustApplicationBiDi"/>
    /// <seealso cref="AdjustKeyboardLayout"/>
    {$Endregion}
    Procedure AdjustFormatSettings; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Finds the <see cref="TTextTranslation"/> object of a given text string in the
    /// loaded translation catalog.
    /// </summary>
    /// <param name="Text">
    /// The text to be located. It is in the original language of the application.
    /// </param>
    /// <param name="DomainName">
    /// Determines the name of the domain where the translation is looked up.
    ///
    /// A text domain is a set of translatable strings in a translation catalog, and
    /// the domain name is usually the name of the container (e.g. form, frame, data
    /// module, etc.) where the text strings are referenced in.
    ///
    /// If the DomainName parameter is omitted or an empty string is passed, only
    /// the translatable strings of the domain related to the currently active form
    /// will be looked up.
    ///
    /// If '*' is used as the DomainName parameter, all the text domains will be
    /// looked up.
    /// </param>
    /// <returns>
    /// The <see cref="TTextTranslation"/> object of the text string or <see langword="nil"/>
    /// if the text is not found.
    /// </returns>
    {$Endregion}
    Function FindTranslation(Const Text : String; Const DomainName : String = '') : TTextTranslation; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether the component can translate properties and string literals that
    /// are maintained by a specified <see cref="TTranslatables"/> object.
    /// </summary>
    /// <param name="Translatables">
    /// The <see cref="TTranslatables"/> object that maintains translatable properties
    /// and string literals.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the component is able to translate the specified
    /// translatable items. Otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="Translate"/>
    {$Endregion}
    Function CanTranslate(Translatables : TTranslatables) : Boolean; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Attempts to translate properties and string literals that are maintained by
    /// a specified <see cref="TTranslatables"/> object.
    /// </summary>
    /// <param name="Translatables">
    /// The <see cref="TTranslatables"/> object that maintains translatable properties
    /// and string literals.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the component was able to translate the
    /// specified translatable items. Otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="CanTranslate"/>
    {$Endregion}
    Function Translate(Translatables : TTranslatables) : Boolean; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Broadcasts a notification to the linked objects.
    /// </summary>
    /// <param name="Reason">
    /// The reason of the notification.
    /// </param>
    /// <seealso cref="ILocalizerLink"/>
    /// <seealso cref="RegisterListener"/>
    /// <seealso cref="UnregisterListener"/>
    {$Endregion}
    Procedure NotifyClients(Reason : TLocalizerNotification);
    {$Region 'xmldoc'}
    /// <summary>
    /// Provides direct access to the <see cref="TTranslationCatalog"/> object that
    /// maintains the loaded translation catalog.
    /// </summary>
    {$Endregion}
    Property Catalog : TTranslationCatalog Read fCatalog;
    {$Region 'xmldoc'}
    /// <summary>
    /// Provides direct access to the <see cref="PluralForms"/> object that decides
    /// which plural form of the active language is correct for expressing a noun or
    /// unit.
    /// </summary>
    {$Endregion}
    Property PluralForms : TPluralForms Read fPluralForms;
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
    /// Returns the least recently created instance of the <see cref="TLocalizer"/>
    /// component that is not destroyed yet. Usually this instance is the only instance
    /// of the <see cref="TLocalizer"/> component in an application.
    /// </summary>
    /// <returns>
    /// The oldest instance of the <see cref="TLocalizer"/> component or <see langword="nil"/>
    /// if no instance is in memory right now.
    /// </returns>
    {$Endregion}
    Class Function FirstInstance : TLocalizer; Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Enables an object that implements the <see cref="ILocalizerLink"/> interface
    /// to be notified about changes in this instance of the component.
    /// </summary>
    /// <param name="Client">
    /// The object with <see cref="ILocalizerLink"/> interface that is interested
    /// in receiving the notifications.
    /// </param>
    /// <seealso cref="ILocalizerLink"/>
    /// <seealso cref="UnregisterListener"/>
    {$Endregion}
    Procedure RegisterListener(Client : ILocalizerLink);
    {$Region 'xmldoc'}
    /// <summary>
    /// Stops sending the notifications to an object that was previously registered
    /// by a call to <see cref="RegisterListener"/> method.
    /// </summary>
    /// <param name="Client">
    /// The object with <see cref="ILocalizerLink"/> interface that is no more
    /// interested in receiving the notifications.
    /// </param>
    /// <seealso cref="ILocalizerLink"/>
    /// <seealso cref="RegisterListener"/>
    {$Endregion}
    Procedure UnregisterListener(Client : ILocalizerLink);
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether the component is ready to localize the application.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> if the component is fully loaded and its
    /// <see cref="Culture"/> property is assigned. Otherwise, returns
    /// <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function IsReady : Boolean;
    {$Region 'xmldoc'}
    /// <summary>
    /// Attempts to translate a text string into the currently active language, by
    /// looking up the translation in the loaded translation catalog.
    /// </summary>
    /// <param name="Text">
    /// The text to be translated. It is in the original language of the application.
    /// </param>
    /// <param name="DomainName">
    /// Determines the name of the domain where the translation is looked up.
    ///
    /// A text domain is a set of translatable strings in a translation catalog, and
    /// the domain name is usually the name of the container (e.g. form, frame, data
    /// module, etc.) where the text strings are referenced in.
    ///
    /// If the DomainName parameter is omitted or an empty string is passed, only
    /// the translatable strings of the domain related to the currently active form
    /// will be looked up.
    ///
    /// If '*' is used as the DomainName parameter, all the text domains will be
    /// looked up.
    /// </param>
    /// <returns>
    /// Returns the translated text if it is found. Otherwise, returns the original
    /// text.
    /// </returns>
    /// <seealso cref="GetNText"/>
    {$Endregion}
    Function GetText(Const Text : String; Const DomainName : String = '') : String; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Attempts to translate a text string into the currently active language, by
    /// looking up the appropriate plural form of the translation in the translation
    /// data.
    /// </summary>
    /// <param name="TextVariants">
    /// The plural forms of the text to be located, in the original language of the
    /// application.
    ///
    /// The plural forms are grammatical variants of a text depending on a number. For
    /// example, The English language has two plural forms: singular and plural.
    /// </param>
    /// <param name="N">
    /// The number (in addition to the language) that determines which plural form
    /// should be selected.
    /// </param>
    /// <param name="DomainName">
    /// Determines the name of the domain where the translation is looked up.
    ///
    /// A text domain is a set of translatable strings in a translation catalog, and
    /// the domain name is usually the name of the container (e.g. form, frame, data
    /// module, etc.) where the text strings are referenced in.
    ///
    /// If the DomainName parameter is omitted or an empty string is passed, only
    /// the translatable strings of the domain related to the currently active form
    /// will be looked up.
    ///
    /// If '*' is used as the DomainName parameter, all the text domains will be
    /// looked up.
    /// </param>
    /// <returns>
    /// Returns the appropriate plural form of the translated text if it is found.
    /// Otherwise, returns the appropriate plural form of the original text.
    /// </returns>
    /// <seealso cref="GetText"/>
    {$Endregion}
    Function GetNText(Const TextVariants : Array Of String; n : Integer; Const DomainName : String = '') : String; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a formatted string assembled from a format string in C# language style
    /// and an array of arguments.
    /// </summary>
    /// <remarks>
    /// FormatCS returns a string produced according to the formatting string <paramref name="Fmt"/>
    /// and currently active culture.
    ///
    /// NOTE: Regardless of value of the <see cref="Options"/> property, FormatCS always
    /// uses the native calendar system of the currently active culture to format a date
    /// value.
    /// </remarks>
    /// <param name="Fmt">
    /// The format string. See <see cref="i18nUtils.FormatCS"/> for details.
    /// </param>
    /// <param name="Args">
    /// The values to be formatted.
    /// </param>
    /// <returns>
    /// The formatted string.
    /// </returns>
    {$Endregion}
    Function FormatCS(Const Fmt : String; Const Args : Array Of Variant) : String;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a formatted string assembled from a format string and an array of
    /// arguments.
    /// </summary>
    /// <remarks>
    /// Format method acts like Format function of Delphi, except that it uses the
    /// currently active culture's preferences for formatting the values.
    ///
    /// The <see cref="Options"/> property determines whether the numbers should be
    /// expressed in native digits or not.
    /// </remarks>
    /// <param name="Fmt">
    /// The format string as in used by Delphi's standard Format function.
    /// </param>
    /// <param name="Args">
    /// The array of arguments to apply to the format specifiers in the format string.
    /// </param>
    /// <returns>
    /// The formatted string.
    /// </returns>
    {$Endregion}
    Function Format(Const Fmt : String; Const Args : Array Of Const) : String;
    {$Region 'xmldoc'}
    /// <summary>
    /// Formats a floating point value.
    /// </summary>
    /// <remarks>
    /// FormatNumber method acts like FormatFloat function of Delphi, except that it
    /// uses the currently active culture's preferences for formatting the number.
    ///
    /// The <see cref="Options"/> property determines whether the number should be
    /// expressed in native digits or not.
    /// </remarks>
    /// <param name="Fmt">
    /// The format string.
    /// </param>
    /// <param name="Value">
    /// The floating point value to format.
    /// </param>
    /// <returns>
    /// The formatted string.
    /// </returns>
    {$Endregion}
    Function FormatNumber(Const Fmt : String; Const Value : Extended) : String;
    {$Region 'xmldoc'}
    /// <summary>
    /// Formats a floating point value as a percentage.
    /// </summary>
    /// <remarks>
    /// FormatPercent represents a floating point value as a percentage using the
    /// percentage format of the currently active culture.
    ///
    /// The <see cref="Options"/> property determines whether the percentage should
    /// be expressed in native digits or not.
    /// </remarks>
    /// <param name="Value">
    /// The floating point value to format.
    /// </param>
    /// <param name="Decimals">
    /// The number of decimals.
    /// </param>
    /// <returns>
    /// The formatted string.
    /// </returns>
    {$Endregion}
    Function FormatPercent(Const Value : Extended; Decimals : Integer = 2) : String;
    {$Region 'xmldoc'}
    /// <summary>
    /// Formats a <see cref="TDateTime"/> value.
    /// </summary>
    /// <remarks>
    /// FormatDateTime formats the <see cref="TDateTime"/> value given by <paramref name="Value"/>
    /// using the format given by <paramref name="Fmt"/> and currently active culture.
    ///
    /// The <see cref="Options"/> property determines whether the native calendar
    /// system and the native digits should be used for expressing the date and
    /// time components.
    /// </remarks>
    /// <param name="Fmt">
    /// The format string. See <see cref="TCalendar.Format"/> method for details.
    /// </param>
    /// <param name="Value">
    /// The <see cref="TDateTime"/> value to format.
    /// </param>
    /// <returns>
    /// The formatted date-time string.
    /// </returns>
    /// <seealso cref="TryParseDateTime"/>
    /// <seealso cref="ParseDateTime"/>
    {$Endregion}
    Function FormatDateTime(Const Fmt : String; Const DateTime : TDateTime) : String;
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts a string to a <see cref="TDateTime"/> value using a specified format
    /// string.
    /// </summary>
    /// <remarks>
    /// The ParseDateTime method scans the string given by <paramref name="Str"/>
    /// using the format string given by <paramref name="Fmt"/> to extract its
    /// date and time values.
    ///
    /// The <see cref="Options"/> property determines whether the ParseDateTime
    /// method should use the native calendar system of the currently active culture
    /// or the Gregorian calendar to extract the date and time components from the
    /// input string.
    /// </remarks>
    /// <param name="Fmt">
    /// The format string. See the <see cref="TCalendar.Format"/> method for details.
    /// </param>
    /// <param name="Str">
    /// The date and time value as a string.
    /// </param>
    /// <returns>
    /// The <see cref="TDateTime"/> value.
    /// </returns>
    /// <exception cref="EConvertError">
    /// Occurs when the conversion is failed.
    /// </exception>
    /// <seealso cref="TryParseDateTime"/>
    /// <seealso cref="FormatDateTime"/>
    {$Endregion}
    Function ParseDateTime(Const Fmt : String; Const Str : String) : TDateTime;
    {$Region 'xmldoc'}
    /// <summary>
    /// Converts a string to a <see cref="TDateTime"/> value using a specified format
    /// string.
    /// </summary>
    /// <remarks>
    /// The TryParseDateTime method scans the string given by <paramref name="Str"/>
    /// using the format string given by <paramref name="Fmt"/> to extract its
    /// date and time values.
    ///
    /// The <see cref="Options"/> property determines whether the TryParseDateTime
    /// method should use the native calendar system of the currently active culture
    /// or the Gregorian calendar to extract the date and time components from the
    /// input string.
    /// </remarks>
    /// <param name="Fmt">
    /// The format string. See the <see cref="TCalendar.Format"/> method for details.
    /// </param>
    /// <param name="Str">
    /// The date and time value as a string.
    /// </param>
    /// <param name="DateTime">
    /// The <see cref="TDateTime"/> value.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the conversion is succeeded, otherwise
    /// returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="ParseDateTime"/>
    /// <seealso cref="FormatDateTime"/>
    {$Endregion}
    Function TryParseDateTime(Const Fmt : String; Const Str : String; Var DateTime : TDateTime) : Boolean;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns a string that its embedded digits will always be displayed in native
    /// digits of the currently active culture, regardless of Windows settings.
    /// </summary>
    /// <remarks>
    /// Based on the user's selection (configurable via Windows control panel), Windows
    /// may display nominal digits (0-9) in different digit shapes.
    ///
    /// NativeDigits substitutes the nominal digits in the string with the native digits
    /// of the currently active culture and inserts appropriate Unicode control character
    /// in front of the string to prevent automatic digit substitution by Windows.
    /// </remarks>
    /// <param name="Str">
    /// The string to convert.
    /// </param>
    /// <returns>
    /// The string that its digits are fixed as native.
    /// </returns>
    {$Endregion}
    Function NativeDigits(Const Str : String) : String;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the available cultures that the application can be localized to.
    /// </summary>
    {$Endregion}
    Property Cultures : TReadonlyCultureList Read GetCultures;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the BiDiMode of the currently active culture.
    /// </summary>
    {$Endregion}
    Property BiDiMode : TBiDiMode Read GetBiDiMode;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets whether direction of the currently active language differs from the
    /// direction of the application's original language.
    /// </summary>
    {$Endregion}
    Property IsBiDiToggled : Boolean Read fBiDiToggled;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the index of currently active culture in the list of available
    /// cultures that the application can be localized to.
    /// </summary>
    {$Endregion}
    Property CultureIndex : Integer Read GetCultureIndex Write SetCultureIndex;
   Published
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the location of the translation catalog to load.
    /// </summary>
    /// <remarks>
    /// <para>
    /// The URI property determines the location of the translation catalog that
    /// is required for translating the application's strings.
    /// </para>
    /// <para>
    /// The URI can be simply a path to a translation catalog file, but it can also
    /// address a directory or an application's resource.
    /// </para>
    /// <para>
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
    /// </para>
    /// <para>
    /// The file and directory paths can use environment variables.
    /// <example><code>
    /// Localizer1.URI := 'dir:%ALLUSERSPROFILE%\MyApp\';
    /// Localizer2.URI := '%USERPROFILE%\MyApp\myapp.i18n';
    /// </code>
    /// </example>
    /// </para>
    /// <para>
    /// NOTE: For convenience, a relative file or directory is considered to be
    /// relative to the application's directory instead of the current directory.
    /// </para>
    /// </remarks>
    /// <exception cref="ETranslationCatalogError">
    /// Occurs when a problem is encountered while loading the translation catalog.
    /// </exception>
    {$Endregion}
    Property URI : String Read fURI Write SetURI;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the currently active culture.
    /// </summary>
    {$Endregion}
    Property Culture : TCultureInfo Read fCulture Write SetCulture;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the component's preferences.
    /// </summary>
    /// <remarks>
    /// The Options property determines whether the component should automatically
    /// perform some tasks or not. It also specifies how the formatting methods
    /// should express the numbers and the components of dates.
    /// </remarks>
    {$Endregion}
    Property Options : TLocalizerOptions Read fOptions Write SetOptions Default
    [loAdjustApplicationBiDiMode, loAdjustFormatSettings, loUseNativeDigits, loUseNativeCalendar];
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the component's properties change.
    /// </summary>
    {$Endregion}
    Property OnNotification : TLocalizerNotifyEvent Read fOnNotification Write fOnNotification;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TTranslator maintains the list of translatable strings for a form, frame,
/// data module, and so on.
/// </summary>
/// <remarks>
/// <para>
/// Use TTranslator to select which properties and literal strings are translatable.
/// </para>
/// <para>
/// To translate controls' properties or messages of a form (or frame, data module,
/// etc.), drop an instance of TTranslator component on the form. Then, double click
/// on the component to bring up its component's editor.
/// </para>
/// <para>
/// The component editor lets you select which properties and literal strings
/// should be translated. You can also export the selected items into a translation
/// data file, so that you can translate the strings later using the translator
/// application (i18nHelper.exe). After clicking on OK button of the component's
/// editor, the source code will be updated automatically to reflect changes you
/// made in the translatable strings.
/// </para>
/// <para>
/// After selecting the translatable strings, the next, and of course the last, step
/// is assigning an instance of <see cref="TLocalizer"/> component to the
/// <see cref="Localizer"/> property. The <see cref="TLocalizer"/> component provides
/// the translations of the strings and specifies what is the current user interface
/// language of the application.
/// </para>
/// <para>
/// TTranslator has some events to notify you about the changes in the user interface
/// of the owner component. The <see cref="OnLoaded"/> event occurs only once when the
/// component is loaded into memory. The other events occur whenever the user interface
/// language is changed. The <see cref="OnBeforeFlipLayout"/> and <see cref="OnAfterFlipLayout"/>
/// events occur only when the direction of the new language is different from the last
/// one. However, the <see cref="OnBeforeTranslate"/> and <see cref="OnAfterTranslate"/>
/// events always occur when the language changes. The order of the events is in the
/// same order that they are mentioned here.
/// </para>
/// <para>
/// NOTE: When you drop an instance of TTranslator component on a form (or frame), it
/// resets the ParentBiDiMode of the owner form (or frame). The component manages the
/// BiDiMode of the owner form (or frame) if <see cref="AutoBiDiLayout"/> property is
/// set to <see langword="true"/>.
/// </para>
/// </remarks>
/// <seealso cref="TLocalizer"/>
/// <group name="Components"/>
{$Endregion}
{$IFDEF COMPILER_XE2_UP}

  [ComponentPlatformsAttribute(pidWin32 Or pidWin64)]
  {$ENDIF}
  TTranslator = Class(TComponent, ILocalizerLink)
   Private
    fLocalizer          : TLocalizer;
    fTranslatables      : TTranslatables;
    fCurrentCulture     : TCultureInfo;
    fAutoBiDiLayout     : Boolean;
    fOnLoaded           : TNotifyEvent;
    fOnBeforeFlipLayout : TNotifyEvent;
    fOnAfterFlipLayout  : TNotifyEvent;
    fOnBeforeTranslate  : TNotifyEvent;
    fOnAfterTranslate   : TNotifyEvent;
    fLayoutFlipped      : Boolean;
    fUpdateCount        : Integer;
    fActiveControl      : TWinControl;
    Procedure SetLocalizer(Value : TLocalizer);
    Procedure SetTranslatables(Value : TTranslatables);
    Procedure SetAutoBiDiLayout(Value : Boolean);
    Procedure Sync;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Notifies the component about changes in the linked <see cref="TLocalizer"/>
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
    /// Initializes the component when it is first loaded into memory.
    /// </summary>
    {$Endregion}
    Procedure Loaded; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Attempts to translates the translatable properties and literals using the
    /// information provided by the <see cref="Localizer"/> component. If the
    /// translation was successful, it then applies the translations to the actual
    /// properties of the owner component.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> if the translation is successful. Otherwise,
    /// returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function Translate : Boolean; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Horizontally flips content of the owner component.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> if the layout is flipped. Otherwise, returns
    /// <see langword="false"/>.
    /// </returns>
    /// <seealso cref="NeedsFlipLayout"/>
    /// <seealso cref="IsLayoutFlipped"/>
    {$Endregion}
    Function FlipLayout : Boolean; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether the controls of the owner component should be flipped
    /// to reflect the direction of the currently active language.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> if the layout should be flipped. Otherwise,
    /// returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="FlipLayout"/>
    /// <seealso cref="IsLayoutFlipped"/>
    {$Endregion}
    Function NeedsFlipLayout : Boolean; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnLoaded"/> event.
    /// </summary>
    {$Endregion}
    Procedure DoLoaded; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnBeforeTranslate"/> event.
    /// </summary>
    {$Endregion}
    Procedure DoBeforeTranslate; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnAfterTranslate"/> event.
    /// </summary>
    {$Endregion}
    Procedure DoAfterTranslate; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnBeforeFlipLayout"/> event.
    /// </summary>
    {$Endregion}
    Procedure DoBeforeFlipLayout; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnAfterFlipLayout"/> event.
    /// </summary>
    {$Endregion}
    Procedure DoAfterFlipLayout; Virtual;
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
    /// Prevents the control that owns this instance of TTranslator to draw itself
    /// on the screen.
    /// </summary>
    /// <seealso cref="EndUpdate"/>
    {$Endregion}
    Procedure BeginUpdate; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Re-enables the control that owns this instance of TTranslator to draw itself
    /// on the screen.
    /// </summary>
    /// <seealso cref="BeginUpdate"/>
    {$Endregion}
    Procedure EndUpdate; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Attempts to translate a text string into the currently active language, by
    /// looking up the translation of the translatable string literals.
    /// </summary>
    /// <param name="Text">
    /// The text to be translated. It is in the original language of the application.
    /// </param>
    /// <returns>
    /// Returns the translated text if it is found. Otherwise, returns the original
    /// text.
    /// </returns>
    /// <seealso cref="GetNText"/>
    {$Endregion}
    Function GetText(Const Text : String) : String;
    {$Region 'xmldoc'}
    /// <summary>
    /// Attempts to translate a text string into the currently active language, by
    /// looking up the appropriate plural form of the translation of the translatable
    /// string literals.
    /// </summary>
    /// <param name="TextVariants">
    /// The plural forms of the text to be located, in the original language of the
    /// application.
    /// </param>
    /// <param name="N">
    /// The number (in addition to the language) that determines which plural form
    /// should be selected.
    /// </param>
    /// <returns>
    /// Returns the appropriate plural form of the translated text if it is found.
    /// Otherwise, returns the appropriate plural form of the original text.
    /// </returns>
    /// <remarks>
    /// The plural forms are grammatical variants of a text depending on a number. For
    /// example, The English language has two plural forms: singular and plural.
    /// </remarks>
    /// <seealso cref="GetText"/>
    {$Endregion}
    Function GetNText(Const TextVariants : Array Of String; n : Integer) : String;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets whether the content the owner component is horizontally flipped
    /// to reflect the direction of the active language.
    /// </summary>
    {$Endregion}
    Property IsLayoutFlipped : Boolean Read fLayoutFlipped;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the currently active culture, which determines the language of
    /// translations.
    /// </summary>
    {$Endregion}
    Property CurrentCulture : TCultureInfo Read fCurrentCulture;
   Published
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets whether the component should flip content of its owner
    /// windowed control to reflect the direction of the active language.
    /// </summary>
    {$Endregion}
    Property AutoBiDiLayout : Boolean Read fAutoBiDiLayout Write SetAutoBiDiLayout Default True;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the <see cref="TLocalizer"/> component's that provides the
    /// translation of the strings and determines the currently active language.
    /// </summary>
    {$Endregion}
    Property Localizer : TLocalizer Read fLocalizer Write SetLocalizer;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gives direct access to the list of translatable properties and string literals
    /// of the owner component.
    /// </summary>
    {$Endregion}
    Property Translatables : TTranslatables Read fTranslatables Write SetTranslatables;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the component is first loaded into memory.
    /// </summary>
    /// <remarks>
    /// Write an OnLoaded event handler to take specific action immediately after
    /// the component is loaded into memory. OnLoaded is particularly useful for
    /// taking initialization actions.
    /// </remarks>
    {$Endregion}
    Property OnLoaded : TNotifyEvent Read fOnLoaded Write fOnLoaded;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the screen layout is about to be flipped.
    /// </summary>
    /// <seealso cref="OnAfterFlipLayout"/>
    {$Endregion}
    Property OnBeforeFlipLayout : TNotifyEvent Read fOnBeforeFlipLayout Write fOnBeforeFlipLayout;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the screen layout is flipped.
    /// </summary>
    /// <seealso cref="OnBeforeFlipLayout"/>
    {$Endregion}
    Property OnAfterFlipLayout : TNotifyEvent Read fOnAfterFlipLayout Write fOnAfterFlipLayout;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the translatable strings are about to be translated.
    /// </summary>
    /// <seealso cref="OnAfterTranslate"/>
    {$Endregion}
    Property OnBeforeTranslate : TNotifyEvent Read fOnBeforeTranslate Write fOnBeforeTranslate;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when the translatable strings are translated and applied on the screen.
    /// </summary>
    /// <seealso cref="OnBeforeTranslate"/>
    {$Endregion}
    Property OnAfterTranslate : TNotifyEvent Read fOnAfterTranslate Write fOnAfterTranslate;
  End;

{$Region 'xmldoc'}
/// <summary>
/// Attempts to translate a text string into the currently active language, by
/// looking up the translation in the translation catalog of the least recently
/// created instance of the application's <see cref="TLocalizer"/> component.
/// </summary>
/// <param name="Text">
/// The text to be translated. It is in the original language of the application.
/// </param>
/// <param name="DomainName">
/// Determines the name of the domain where the translation is looked up.
///
/// A text domain is a set of translatable strings in a translation catalog, and
/// the domain name is usually the name of the container (e.g. form, frame, data
/// module, etc.) where the text strings are referenced in.
///
/// If the DomainName parameter is omitted or an empty string is passed, only
/// the translatable strings of the domain related to the currently active form
/// will be looked up.
///
/// If '*' is used as the DomainName parameter, all the text domains will be
/// looked up.
/// </param>
/// <returns>
/// Returns the translated text if it is found. Otherwise, returns the original
/// text.
/// </returns>
/// <seealso cref="TLocalizer.GetText"/>
/// <seealso cref="TLocalizer.GetNText"/>
/// <seealso cref="GetNText"/>
{$Endregion}

 Function GetText(Const Text : String; Const DomainName : String = '') : String;

 {$Region 'xmldoc'}
 /// <summary>
 /// Attempts to translate a text string into the currently active language, by
 /// looking up the appropriate plural form of the translation in the translation
 /// catalog of the least recently created instance of the application's
 /// <see cref="TLocalizer"/> component.
 /// </summary>
 /// <param name="TextVariants">
 /// The plural forms of the text to be located, in the original language of the
 /// application.
 ///
 /// The plural forms are grammatical variants of a text depending on a number. For
 /// example, The English language has two plural forms: singular and plural.
 /// </param>
 /// <param name="N">
 /// The number (in addition to the language) that determines which plural form
 /// should be selected.
 /// </param>
 /// <param name="DomainName">
 /// Determines the name of the domain where the translation is looked up.
 ///
 /// A text domain is a set of translatable strings in a translation catalog, and
 /// the domain name is usually the name of the container (e.g. form, frame, data
 /// module, etc.) where the text strings are referenced in.
 ///
 /// If the DomainName parameter is omitted or an empty string is passed, only
 /// the translatable strings of the domain related to the currently active form
 /// will be looked up.
 ///
 /// If '*' is used as the DomainName parameter, all the text domains will be
 /// looked up.
 /// </param>
 /// <returns>
 /// Returns the appropriate plural form of the translated text if it is found.
 /// Otherwise, returns the appropriate plural form of the original text.
 /// </returns>
 /// <seealso cref="TLocalizer.GetNText"/>
 /// <seealso cref="TLocalizer.GetText"/>
 /// <seealso cref="GetText"/>
 {$Endregion}
 Function GetNText(Const TextVariants : Array Of String; n : Integer; Const DomainName : String = '') : String;

 {$Region 'xmldoc'}
 /// <summary>
 /// Collects the list of translatable properties for a specified component and
 /// children of the component.
 /// </summary>
 /// <param name="Root">
 /// The component to collect its translatable properties.
 /// </param>
 /// <param name="Properties">
 /// The <see cref="TTextItem"/> object that receives the translatable properties
 /// of the specified component.
 /// </param>
 /// <seealso cref="SetTranslatableProperties"/>
 {$Endregion}
 Procedure GetTranslatableProperties(Root : TComponent; Properties : TTextItems); Overload;

 {$Region 'xmldoc'}
 /// <summary>
 /// Updates the specified properties of a component and children of the component
 /// with the provided translations.
 /// </summary>
 /// <param name="Root">
 /// The component to translate its properties.
 /// </param>
 /// <param name="Properties">
 /// The <see cref="TTextItem"/> object that maintains the list of translatable
 /// properties of the component, including their translations.
 /// </param>
 /// <seealso cref="GetTranslatableProperties"/>
 {$Endregion}
 Procedure SetTranslatableProperties(Root : TComponent; Properties : TTextItems); Overload;

Implementation

 Uses
  TypInfo, Types, Forms, ComCtrls, Contnrs, StrUtils, ListActns, i18nMD5,
  i18nUtils, i18nZStrList, i18nBiDi, i18nUnicode, i18nCalGregorian;

 Var
  TheDefaultPluralForms : TPluralForms = Nil;

{ Local Helper Functions }

 Function DefaultPluralForms : TPluralForms;
  Begin
   If Not Assigned(TheDefaultPluralForms) Then
    TheDefaultPluralForms := TPluralForms.Create(GetApplicationDefaultCulture.PluralRule);
   Result                 := TheDefaultPluralForms;
  End;

 Procedure WriteListViewItems(Stream : TStream; ListView : TListView);
  Var
   r : Integer;
   c : Integer;
  Begin
   With TWriter.Create(Stream, 1024) Do
    Try
     WriteListBegin;
     For r := 0 To ListView.Items.Count - 1 Do
      With ListView.Items[r] Do
       Begin
        WriteString(Caption);
        WriteBoolean(Checked);
        WriteInteger(Indent);
        WriteInteger(GroupID);
        WriteInteger(ImageIndex);
        WriteInteger(OverlayIndex);
        WriteInteger(StateIndex);
        WriteListBegin;
        For c := 0 To SubItems.Count - 1 Do
         Begin
          WriteString(SubItems[c]);
          WriteInteger(SubItemImages[c]);
         End;
        WriteListEnd;
       End;
     WriteListEnd;
     WriteInteger(ListView.ItemIndex);
    Finally
     Free;
    End;
  End;

 Procedure ReadListViewItems(Stream : TStream; ListView : TListView);
  Var
   c : Integer;
  Begin
   ListView.Items.BeginUpdate;
   Try
    ListView.Items.Clear;
    With TReader.Create(Stream, 1024) Do
     Try
      ReadListBegin;
      While Not EndOfList Do
       With ListView.Items.Add Do
        Begin
         Caption      := ReadString;
         Checked      := ReadBoolean;
         Indent       := ReadInteger;
         GroupID      := ReadInteger;
         ImageIndex   := ReadInteger;
         OverlayIndex := ReadInteger;
         StateIndex   := ReadInteger;
         ReadListBegin;
         While Not EndOfList Do
          Begin
           c                := SubItems.Add(ReadString);
           SubItemImages[c] := ReadInteger;
          End;
         ReadListEnd;
        End;
      ReadListEnd;
      ListView.ItemIndex := ReadInteger;
     Finally
      Free;
     End;
   Finally
    ListView.Items.EndUpdate;
   End;
  End;

{ Global Helper Functions }

 Function GetText(Const Text : String; Const DomainName : String) : String;
  Begin
   If TLocalizer.FirstInstance <> Nil Then
    Result := TLocalizer.FirstInstance.GetText(Text, DomainName)
   Else
    Result := Text;
  End;

 Function GetNText(Const TextVariants : Array Of String; n : Integer; Const DomainName : String) : String;
  Var
   Index : Integer;
  Begin
   If Length(TextVariants) = 0 Then
    Result := ''
   Else If TLocalizer.FirstInstance <> Nil Then
    Result := TLocalizer.FirstInstance.GetNText(TextVariants, n, DomainName)
   Else
    Begin
     Index := DefaultPluralForms.IndexOf(n);
     If Index > High(TextVariants) Then
      Index := High(TextVariants);
     Result := TextVariants[Index];
    End;
  End;

 Procedure GetTranslatableProperties(Instance : TObject; Const ParentPath : String; Properties : TTextItems); Overload;

   Procedure AddProperty(Const PropPath, PropValue : String);
    Begin
     If IsStringTranslatable(PropValue) Then
      Properties.Add(PropPath).OriginalValue := PropValue;
    End;
  Var
   PropList      : PPropList;
   SubInstance   : TObject;
   PropertyCount : Integer;
   i             : Integer;
   Node          : TTreeNode;

  Begin
   If Instance Is TStrings Then
    Begin
     If AnsiEndsText('.Lines', ParentPath) Or AnsiEndsText('.SQL', ParentPath) Then
      AddProperty(ParentPath + '.Text', TStrings(Instance).Text)
     Else
      For i := 0 To TStrings(Instance).Count - 1 Do
       AddProperty(ParentPath + '[' + IntToStr(i) + ']', TStrings(Instance).Strings[i]);
    End
   Else If Instance Is TCollection Then
    Begin
     For i := 0 To TCollection(Instance).Count - 1 Do
      GetTranslatableProperties(TCollection(Instance).Items[i], ParentPath + '[' + IntToStr(i) + ']', Properties);
    End
   Else If Instance Is TListItems Then
    Begin
     TListItems(Instance).Handle; // underlining Window control is needed otherwise 'Items' can be empty
     For i := 0 To TListItems(Instance).Count - 1 Do
      GetTranslatableProperties(TListItems(Instance).Item[i], ParentPath + '[' + IntToStr(i) + ']', Properties);
    End
   Else If Instance Is TListItem Then
    Begin
     AddProperty(ParentPath + '.Caption', TListItem(Instance).Caption);
     For i := 0 To TListItem(Instance).SubItems.Count - 1 Do
      AddProperty(ParentPath + '.SubItems[' + IntToStr(i) + ']', TListItem(Instance).SubItems[i]);
    End
   Else If Instance Is TTreeNodes Then
    Begin
     Node := TTreeNodes(Instance).GetFirstNode;
     While Assigned(Node) Do
      Begin
       GetTranslatableProperties(Node, ParentPath + '[' + IntToStr(Node.Index) + ']', Properties);
       Node := Node.getNextSibling;
      End;
    End
   Else If Instance Is TTreeNode Then
    Begin
     AddProperty(ParentPath + '.Text', TTreeNode(Instance).Text);
     For i := 0 To TTreeNode(Instance).Count - 1 Do
      GetTranslatableProperties(TTreeNode(Instance).Item[i], ParentPath + '[' + IntToStr(i) + ']', Properties);
    End
   Else If (Instance Is TPersistent) And Not((Instance Is TLocalizer) Or (Instance Is TTranslator)) Then
    Begin
     PropertyCount := GetPropList(Instance, PropList);
     If PropertyCount = 0 Then
      Exit;
     Try
      For i := 0 To PropertyCount - 1 Do
       Begin
        Case (PropList^[i].PropType^)^.Kind Of
         tkString, tkLString :
          If Not(SameText(String(PropList^[i].Name), 'Name') And (Instance Is TComponent)) Then
           Try
            AddProperty(ParentPath + '.' + String(PropList^[i].Name), GetStrProp(Instance, PropList^[i]));
           Except
            // ignore exceptions
           End;
         tkWString :
          If Not(SameText(String(PropList^[i].Name), 'Name') And (Instance Is TComponent)) Then
           Try
            AddProperty(ParentPath + '.' + String(PropList^[i].Name), GetWideStrProp(Instance, PropList^[i]));
           Except
            // ignore exceptions
           End;
         tkUString :
          If Not(SameText(String(PropList^[i].Name), 'Name') And (Instance Is TComponent)) Then
           Try
            AddProperty(ParentPath + '.' + String(PropList^[i].Name), GetStrProp(Instance, PropList^[i]));
           Except
            // ignore exceptions
           End;
         tkClass :
          Begin
           SubInstance := GetObjectProp(Instance, PropList^[i]);
           If Assigned(SubInstance) And (Not(SubInstance Is TComponent) Or (csSubComponent In TComponent(SubInstance).ComponentStyle)) Then
            GetTranslatableProperties(SubInstance, ParentPath + '.' + String(PropList^[i].Name), Properties);
          End;
        End;
       End;
     Finally
      FreeMem(PropList);
     End;
    End;
  End;

 Procedure GetTranslatableProperties(Root : TComponent; Properties : TTextItems); Overload;
  Var
   i : Integer;
  Begin
   Properties.Clear;
   If Assigned(Root) Then
    Begin
     GetTranslatableProperties(Root, '', Properties);
     For i := 0 To Root.ComponentCount - 1 Do
      If Root.Components[i].Name <> '' Then
       GetTranslatableProperties(Root.Components[i], Root.Components[i].Name, Properties);
    End;
  End;

 Procedure SetTranslatableProperties(Instance : TObject; Const ParentPath : String; Properties : TTextItems); Overload;

   Function GetPropertyValue(Const PropPath : String; Out PropValue : String) : Boolean;
    Var
     Item : TTextItem;
    Begin
     Item := Properties.Find(PropPath);
     If Assigned(Item) Then
      Begin
       PropValue := Item.Value;
       Result    := True;
      End
     Else
      Result := False;
    End;
  Var
   PropList      : PPropList;
   SubInstance   : TObject;
   PropertyCount : Integer;
   i             : Integer;
   Node          : TTreeNode;
   Value         : String;
   ItemIndex     : Integer;
   AutoSize      : Integer;

  Begin
   If Instance Is TStrings Then
    Begin
     If AnsiEndsText('.Lines', ParentPath) Or AnsiEndsText('.SQL', ParentPath) Then
      Begin
       If GetPropertyValue(ParentPath + '.Text', Value) Then
        TStrings(Instance).Text := Value;
      End
     Else
      Begin
       For i := 0 To TStrings(Instance).Count - 1 Do
        If GetPropertyValue(ParentPath + '[' + IntToStr(i) + ']', Value) Then
         TStrings(Instance).Strings[i] := Value;
      End;
    End
   Else If Instance Is TCollection Then
    Begin
     For i := 0 To TCollection(Instance).Count - 1 Do
      SetTranslatableProperties(TCollection(Instance).Items[i], ParentPath + '[' + IntToStr(i) + ']', Properties);
    End
   Else If Instance Is TListItems Then
    Begin
     TListItems(Instance).Handle; // underlining Window control is needed otherwise 'Items' can be empty
     For i := 0 To TListItems(Instance).Count - 1 Do
      SetTranslatableProperties(TListItems(Instance).Item[i], ParentPath + '[' + IntToStr(i) + ']', Properties);
    End
   Else If Instance Is TListItem Then
    Begin
     If GetPropertyValue(ParentPath + '.Caption', Value) Then
      TListItem(Instance).Caption := Value;
     For i                        := 0 To TListItem(Instance).SubItems.Count - 1 Do
      If GetPropertyValue(ParentPath + '.SubItems[' + IntToStr(i) + ']', Value) Then
       TListItem(Instance).SubItems[i] := Value;
    End
   Else If Instance Is TTreeNodes Then
    Begin
     Node := TTreeNodes(Instance).GetFirstNode;
     While Assigned(Node) Do
      Begin
       SetTranslatableProperties(Node, ParentPath + '[' + IntToStr(Node.Index) + ']', Properties);
       Node := Node.getNextSibling;
      End;
    End
   Else If Instance Is TTreeNode Then
    Begin
     If GetPropertyValue(ParentPath + '.Text', Value) Then
      TTreeNode(Instance).Text := Value;
     For i                     := 0 To TTreeNode(Instance).Count - 1 Do
      SetTranslatableProperties(TTreeNode(Instance).Item[i], ParentPath + '[' + IntToStr(i) + ']', Properties);
    End
   Else If (Instance Is TPersistent) And Not(Instance Is TLocalizer) And Not(Instance Is TTranslator) Then
    Begin
     PropertyCount := GetPropList(Instance, PropList);
     If PropertyCount = 0 Then
      Exit;
     Try
      // save control's state
      ItemIndex := -1;
      AutoSize  := 0;
      If Instance Is TControl Then
       Begin
        If Instance Is TCustomListControl Then
         ItemIndex := TCustomListControl(Instance).ItemIndex;
        If IsPublishedProp(Instance, 'AutoSize') Then
         Begin
          AutoSize := GetOrdProp(Instance, 'AutoSize');
          If AutoSize <> 0 Then
           SetOrdProp(Instance, 'AutoSize', 0);
         End;
       End;
      // apply values
      For i := 0 To PropertyCount - 1 Do
       Case (PropList^[i].PropType^)^.Kind Of
        tkString, tkLString, tkWString, tkUString :
         If Not(SameText(String(PropList^[i].Name), 'Name') And (Instance Is TComponent)) Then
          Begin
           If GetPropertyValue(ParentPath + '.' + String(PropList^[i].Name), Value) Then
            Case (PropList^[i].PropType^)^.Kind Of
             tkWString : SetWideStrProp(Instance, PropList^[i], Value);
             tkUString : SetStrProp(Instance, PropList^[i], Value);
            Else SetStrProp(Instance, PropList^[i], Value);
            End;
          End;
        tkClass :
         Begin
          SubInstance := GetObjectProp(Instance, PropList^[i]);
          If Assigned(SubInstance) And (Not(SubInstance Is TComponent) Or (csSubComponent In TComponent(SubInstance).ComponentStyle)) Then
           SetTranslatableProperties(SubInstance, ParentPath + '.' + String(PropList^[i].Name), Properties);
         End;
       End;
      // restore control's state
      If ItemIndex >= 0 Then
       TCustomListControl(Instance).ItemIndex := ItemIndex;
      If AutoSize <> 0 Then
       SetOrdProp(Instance, 'AutoSize', AutoSize);
     Finally
      FreeMem(PropList);
     End;
    End;
  End;

 Procedure SetTranslatableProperties(Root : TComponent; Properties : TTextItems); Overload;
  Var
   i : Integer;
  Begin
   If Assigned(Root) Then
    Begin
     SetTranslatableProperties(Root, '', Properties);
     For i := 0 To Root.ComponentCount - 1 Do
      If Root.Components[i].Name <> '' Then
       SetTranslatableProperties(Root.Components[i], Root.Components[i].Name, Properties);
    End;
  End;

{ TTranslatables }

 Constructor TTranslatables.Create(ATranslator : TTranslator);
  Begin
   Inherited Create;
   fTranslator := ATranslator;
   fProperties := TTextItems.Create;
   fLiterals   := TTextItems.Create;
  End;

 Destructor TTranslatables.Destroy;
  Begin
   fLiterals.Free;
   fProperties.Free;
   Inherited Destroy;
  End;

 Function TTranslatables.GetDomainOwner : TComponent;
  Begin
   If Assigned(Translator) Then
    Result := Translator.Owner
   Else
    Result := Nil;
  End;

 Function TTranslatables.GetDomainName : String;
  Begin
   If DomainOwner <> Nil Then
    Begin
     Result := DomainOwner.ClassName;
     If Result[1] = 'T' Then
      Delete(Result, 1, 1);
    End
   Else
    Result := '-DEFAULT-';
  End;

 Function TTranslatables.GetOwner : TPersistent;
  Begin
   Result := Translator;
  End;

 Procedure TTranslatables.ReadLiterals(Reader : TReader);
  Begin
   Literals.Read(Reader);
  End;

 Procedure TTranslatables.WriteLiterals(Writer : TWriter);
  Begin
   Literals.Write(Writer);
  End;

 Procedure TTranslatables.ReadProperties(Reader : TReader);
  Begin
   Properties.Read(Reader);
  End;

 Procedure TTranslatables.WriteProperties(Writer : TWriter);
  Begin
   Properties.Write(Writer);
  End;

 Procedure TTranslatables.DefineProperties(Filer : TFiler);
  Begin
   Inherited DefineProperties(Filer);
   Filer.DefineProperty('Properties', ReadProperties, WriteProperties, Properties.Count > 0);
   Filer.DefineProperty('Literals', ReadLiterals, WriteLiterals, Literals.Count > 0);
  End;

 Procedure TTranslatables.Assign(Source : TPersistent);
  Begin
   If Source Is TTranslatables Then
    Begin
     Properties.Assign(TTranslatables(Source).Properties);
     Literals.Assign(TTranslatables(Source).Literals);
    End
   Else
    Inherited Assign(Source);
  End;

 Procedure TTranslatables.NormalizeProperties;
  Var
   AllProperties : TTextItems;
   Current       : TTextItem;
   Origin        : TTextItem;
   Obsolete      : TTextItem;
  Begin
   AllProperties := TTextItems.Create;
   Try
    GetTranslatableProperties(DomainOwner, AllProperties);
    Obsolete := Nil;
    Current  := Properties.First;
    While Current <> Nil Do
     Begin
      Origin := AllProperties.Find(Current.ID);
      If Origin <> Nil Then
       Current.OriginalValue := Origin.OriginalValue
      Else
       Obsolete := Current;
      Current   := Current.Next;
      If Obsolete <> Nil Then
       Begin
        Obsolete.Delete;
        Obsolete := Nil;
       End;
     End;
   Finally
    AllProperties.Free;
   End;
  End;

 Procedure TTranslatables.ApplyProperties;
  Begin
   SetTranslatableProperties(DomainOwner, Properties);
  End;

 Procedure TTranslatables.DiscardTranslations;
  Begin
   Literals.DiscardTranslations;
   Properties.DiscardTranslations;
  End;

{ TLocalizer }

 Constructor TLocalizer.Create(AOwner : TComponent);
  Begin
   Inherited Create(AOwner);
   If Not Assigned(TheFirstInstance) Then
    TheFirstInstance := Self;
   fCatalog          := TTranslationCatalog.Create;
   fPluralForms      := TPluralForms.Create(GetApplicationDefaultCulture.PluralRule);
   fClients          := TList.Create;
   fOptions          := [loAdjustApplicationBiDiMode, loAdjustFormatSettings, loUseNativeDigits, loUseNativeCalendar];
  End;

 Destructor TLocalizer.Destroy;
  Begin
   fCatalog.Free;
   fPluralForms.Free;
   fClients.Free;
   If TheFirstInstance = Self Then
    TheFirstInstance := Nil;
   Inherited Destroy;
  End;

 Procedure TLocalizer.ReadTargetCulture(Reader : TReader);
  Begin
   Culture := CultureOf(Reader.ReadString);
  End;

 Procedure TLocalizer.WriteTargetCulture(Writer : TWriter);
  Begin
   Writer.WriteString(Culture.Locale);
  End;

 Procedure TLocalizer.DefineProperties(Filer : TFiler);
  Begin
   Inherited DefineProperties(Filer);
   Filer.DefineProperty('TargetCulture', ReadTargetCulture, WriteTargetCulture,
   Assigned(Culture) And Not(loAutoSetectLanguage In Options));

   // Backward compatibility
   Filer.DefineProperty('TragetCulture', ReadTargetCulture, Nil,
   Assigned(Culture) And Not(loAutoSetectLanguage In Options));
  End;

 Procedure TLocalizer.Loaded;
  Begin
   If Not(csDesigning In ComponentState) And (loAutoSetectLanguage In Options) Then
    Culture := GetUserDefaultUICulture;
   Inherited Loaded;
   If Not(csDesigning In ComponentState) Then
    ReloadCatalog;
  End;

 Procedure TLocalizer.DoNotification(Reason : TLocalizerNotification);
  Begin
   If Assigned(OnNotification) Then
    OnNotification(Self, Reason);
  End;

 Function TLocalizer.GetBiDiMode : TBiDiMode;
  Begin
   If Assigned(Culture) Then
    Result := Culture.BiDiMode
   Else
    Result := Application.BiDiMode;
  End;

 Function TLocalizer.GetCultures : TReadonlyCultureList;
  Begin
   If ([csLoading, csDesigning] * ComponentState) = [] Then
    Result := Catalog.Cultures
   Else
    Result := World.Cultures;
  End;

 Procedure TLocalizer.SetOptions(Value : TLocalizerOptions);
  Begin
   If Options <> Value Then
    Begin
     If (csDesigning In ComponentState) And (loAutoSetectLanguage In Value) Then
      Culture := Nil;
     NotifyClients(lnOptionsChanging);
     fOptions := Value;
     NotifyClients(lnOptionsChanged);
    End;
  End;

 Procedure TLocalizer.SetURI(Const Value : String);
  Begin
   If csLoading In ComponentState Then
    fURI := Value
   Else If URI <> Value Then
    Begin
     fURI := Value;
     ReloadCatalog;
    End;
  End;

 Procedure TLocalizer.SetCulture(Value : TCultureInfo);
  Var
   OldBiDiMode : TBiDiMode;
   NewBiDiMode : TBiDiMode;
  Begin
   If csLoading In ComponentState Then
    fCulture := Value
   Else If Culture <> Value Then
    Begin
     If (csDesigning In ComponentState) And Assigned(Value) Then
      Options := Options - [loAutoSetectLanguage];
     BeginUpdate;
     Try
      NotifyClients(lnCultureChanging);
      Try
       OldBiDiMode := BiDiMode;
       If Assigned(Value) Then
        NewBiDiMode := Value.BiDiMode
       Else
        NewBiDiMode := Application.BiDiMode;
       If OldBiDiMode <> NewBiDiMode Then
        Begin
         NotifyClients(lnBiDiModeChanging);
         fBiDiToggled := Not IsBiDiToggled;
        End;
       fCulture := Value;
       ApplyCultureChanges;
       If OldBiDiMode <> NewBiDiMode Then
        NotifyClients(lnBiDiModeChanged);
      Finally
       NotifyClients(lnCultureChanged);
      End;
     Finally
      EndUpdate;
     End;
    End;
  End;

 Function TLocalizer.GetCultureIndex : Integer;
  Begin
   Result := Cultures.IndexOf(Culture);
  End;

 Procedure TLocalizer.SetCultureIndex(Value : Integer);
  Begin
   If Value < 0 Then
    Culture := Nil
   Else If Value < Cultures.Count Then
    Culture := Cultures[Value];
  End;

  Class Function TLocalizer.FirstInstance : TLocalizer;

Begin
 Result := TheFirstInstance;

End;

 Procedure TLocalizer.NotifyClients(Reason : TLocalizerNotification);
  Var
   i : Integer;
  Begin
   If Not(csLoading In ComponentState) Then
    Begin
     For i := fClients.Count - 1 Downto 0 Do
      ILocalizerLink(fClients[i]).LocalizerNotify(Self, Reason);
     DoNotification(Reason);
    End;
  End;

 Procedure TLocalizer.RegisterListener(Client : ILocalizerLink);
  Begin
   fClients.Add(Pointer(Client));
  End;

 Procedure TLocalizer.UnregisterListener(Client : ILocalizerLink);
  Begin
   If Not(csDestroying In ComponentState) Then
    fClients.Remove(Pointer(Client));
  End;

 Function TLocalizer.IsReady : Boolean;
  Begin
   Result := Not(csLoading In ComponentState) And Assigned(Culture);
  End;

 Procedure TLocalizer.BeginUpdate;
  Begin
   Inc(fUpdateCount);
   If fUpdateCount = 1 Then
    NotifyClients(lnChanging);
  End;

 Procedure TLocalizer.EndUpdate;
  Begin
   Dec(fUpdateCount);
   If fUpdateCount = 0 Then
    NotifyClients(lnChanged);
  End;

 Procedure TLocalizer.ReloadCatalog;
  Var
   OldCulture : TCultureInfo;
  Begin
   If ([csLoading, csDesigning] * ComponentState) = [] Then
    Begin
     BeginUpdate;
     Try
      OldCulture := Culture;
      NotifyClients(lnCatalogChanging);
      Try
       If URI <> '' Then
        Begin
         Catalog.Open(URI);
         If Catalog.Cultures.Exists(OldCulture) Then
          fCulture := Nil
         Else
          OldCulture := Catalog.Cultures.FindNearest(OldCulture);
        End
       Else
        Catalog.Clear;
      Finally
       NotifyClients(lnCatalogChanged);
       Culture := OldCulture;
      End;
     Finally
      EndUpdate;
     End;
    End;
  End;

 Procedure TLocalizer.ApplyCultureChanges;
  Var
   PostSetBiDiMode : Boolean;
  Begin
   If ([csLoading, csDesigning] * ComponentState) = [] Then
    Begin
     PluralForms.Rule := Catalog.PluralRuleOf(Culture);
     PostSetBiDiMode  := (Application.BiDiMode = bdLeftToRight);
     If Not PostSetBiDiMode And (loAdjustApplicationBiDiMode In Options) Then
      AdjustApplicationBiDi;
     If loAdjustFormatSettings In Options Then
      AdjustFormatSettings;
     If PostSetBiDiMode And (loAdjustApplicationBiDiMode In Options) Then
      AdjustApplicationBiDi;
     If loAdjustKeyboardLayout In Options Then
      AdjustKeyboardLayout;
    End;
  End;

 Procedure TLocalizer.AdjustApplicationBiDi;
  Begin
   If Assigned(Culture) Then
    Application.BiDiMode := Culture.BiDiMode
   Else If IsBiDiToggled Then
    Begin
     If Application.BiDiMode = bdRightToLeft Then
      Application.BiDiMode := bdLeftToRight
     Else
      Application.BiDiMode := bdRightToLeft;
    End;
  End;

 Procedure TLocalizer.AdjustFormatSettings;
  Begin
   If Assigned(Culture) Then
    SetThreadLocale(Culture.LocaleID)
   Else
    SetThreadLocale(GetUserDefaultUICulture.LocaleID);
   GetFormatSettings;
   DefaultCalendar.Settings.Prepare(GetThreadLocale);
  End;

 Procedure TLocalizer.AdjustKeyboardLayout;
  Const
   MaxLayoutCount = 255;
  Var
   Layouts           : Packed Array[1..MaxLayoutCount] Of HKL;
   AutoBiDiLayout    : HKL;
   NonAutoBiDiLayout : HKL;
   i                 : Integer;
  Begin
   Application.BiDiKeyboard    := '';
   Application.NonBiDiKeyboard := '';
   If Assigned(Culture) Then
    Begin
     If BiDiMode = bdRightToLeft Then
      Begin
       AutoBiDiLayout    := 0;
       NonAutoBiDiLayout := 0;
       For i             := 1 To GetKeyboardLayoutList(MaxLayoutCount, Layouts) Do
        Begin
         If Windows.LANGID(Layouts[i]) = Culture.LANGID Then
          Begin
           AutoBiDiLayout := Layouts[i];
           If NonAutoBiDiLayout <> 0 Then
            Break;
          End
         Else If NonAutoBiDiLayout = 0 Then
          Begin
           NonAutoBiDiLayout := Layouts[i];
           If AutoBiDiLayout <> 0 Then
            Break;
          End;
        End;
       If (AutoBiDiLayout <> 0) And (NonAutoBiDiLayout <> 0) Then
        Begin
         Application.BiDiKeyboard    := IntToHex(Windows.LANGID(AutoBiDiLayout), 8);
         Application.NonBiDiKeyboard := IntToHex(Windows.LANGID(NonAutoBiDiLayout), 8);
        End;
      End;
     LoadKeyboardLayout(PChar(IntToHex(Culture.LANGID, 8)), KLF_ACTIVATE);
    End;
  End;

 Function TLocalizer.CanTranslate(Translatables : TTranslatables) : Boolean;
  Begin
   Result := Assigned(Culture)
   And (([csLoading, csDesigning] * ComponentState) = [])
   And Catalog.TextDomains.Exists(Translatables.DomainName);
  End;

 Function TLocalizer.Translate(Translatables : TTranslatables) : Boolean;
  Var
   TextDomain : TTextDomain;
  Begin
   Result := False;
   If Assigned(Culture) Then
    Begin
     TextDomain := Catalog.TextDomains.Find(Translatables.DomainName);
     If TextDomain <> Nil Then
      Begin
       TextDomain.Properties.Translate(Translatables.Properties, Culture.Locale);
       TextDomain.Literals.Translate(Translatables.Literals, Culture.Locale);
       Result := True;
      End;
    End;
  End;

 Function TLocalizer.FindTranslation(Const Text : String; Const DomainName : String) : TTextTranslation;
  Var
   TextID     : String;
   TextDomain : TTextDomain;
  Begin
   Result := Nil;
   If Assigned(Culture) Then
    Begin
     TextID := GetStringIdentifier(Text);
     If DomainName = '*' Then
      Begin
       TextDomain := Catalog.TextDomains.First;
       While (TextDomain <> Nil) And (Result = Nil) Do
        Begin
         Result     := TextDomain.Literals.TranslationOf(TextID, Culture.Locale);
         TextDomain := TextDomain.Next;
        End;
      End
     Else
      Begin
       If DomainName = '' Then
        Begin
         If Screen.ActiveForm <> Nil Then
          TextDomain := Catalog.TextDomains.Find(Screen.ActiveForm.Name)
         Else
          TextDomain := Nil;
        End
       Else
        TextDomain := Catalog.TextDomains.Find(DomainName);
       If TextDomain <> Nil Then
        Result := TextDomain.Literals.TranslationOf(TextID, Culture.Locale);
      End;
    End;
  End;

 Function TLocalizer.GetText(Const Text : String; Const DomainName : String) : String;
  Var
   Translation : TTextTranslation;
  Begin
   Translation := FindTranslation(Text, DomainName);
   If Assigned(Translation) And Translation.IsApproved Then
    Result := Translation.Value
   Else
    Result := Text;
  End;

 Function TLocalizer.GetNText(Const TextVariants : Array Of String; n : Integer; Const DomainName : String) : String;
  Var
   Translation : TTextTranslation;
   Index       : Integer;
  Begin
   If Length(TextVariants) = 0 Then
    Result := ''
   Else
    Begin
     Translation := FindTranslation(ZStrings.Construct(TextVariants), DomainName);
     If Assigned(Translation) And Translation.IsApproved Then
      Begin
       Index  := PluralForms.IndexOf(n);
       Result := Translation.Plurals[Index];
      End
     Else
      Begin
       Index := DefaultPluralForms.IndexOf(n);
       If Index > High(TextVariants) Then
        Index := High(TextVariants);
       Result := TextVariants[Index];
      End
    End;
  End;

 Function TLocalizer.FormatCS(Const Fmt : String; Const Args : Array Of Variant) : String;
  Begin
   If Not(loUseNativeDigits In Options) Then
    Result := i18nUtils.FormatCS(UCC_NODS + Fmt, Args, Culture)
   Else
    Result := i18nUtils.FormatCS(Fmt, Args, Culture);
  End;

 Function TLocalizer.Format(Const Fmt : String; Const Args : Array Of Const) : String;
  Begin
   If Assigned(Culture) Then
    Result := Culture.Format(Fmt, Args, loUseNativeDigits In Options)
   Else
    Result := SysUtils.Format(Fmt, Args);
  End;

 Function TLocalizer.FormatNumber(Const Fmt : String; Const Value : Extended) : String;
  Begin
   If Assigned(Culture) Then
    Result := Culture.FormatNumber(Fmt, Value, loUseNativeDigits In Options)
   Else
    Result := SysUtils.FormatFloat(Fmt, Value);
  End;

 Function TLocalizer.FormatPercent(Const Value : Extended; Decimals : Integer) : String;
  Begin
   If Assigned(Culture) Then
    Result := Culture.FormatPercent(Value, Decimals, loUseNativeDigits In Options)
   Else
    Result := SysUtils.Format('%.*f%%', [Abs(Decimals), Value * 100.0]);
  End;

 Function TLocalizer.FormatDateTime(Const Fmt : String; Const DateTime : TDateTime) : String;
  Begin
   If Assigned(Culture) And (loUseNativeCalendar In Options) Then
    Result := Culture.FormatDateTime(Fmt, DateTime, loUseNativeDigits In Options)
   Else
    Result := DefaultCalendar.Format(Fmt, DateTime);
   If Assigned(Culture) And (loUseNativeDigits In Options) Then
    Result := Culture.FreezeDigits(Result, True);
  End;

 Function TLocalizer.ParseDateTime(Const Fmt, Str : String) : TDateTime;
  Begin
   If Assigned(Culture) Then
    If loUseNativeCalendar In Options Then
     Result := Culture.ParseDateTime(Fmt, Str)
    Else
     Result := DefaultCalendar.Parse(Fmt, Culture.UnfreezeDigits(Str))
   Else
    Result := DefaultCalendar.Parse(Fmt, Str);
  End;

 Function TLocalizer.TryParseDateTime(Const Fmt, Str : String; Var DateTime : TDateTime) : Boolean;
  Begin
   If Assigned(Culture) Then
    If loUseNativeCalendar In Options Then
     Result := Culture.TryParseDateTime(Fmt, Str, DateTime)
    Else
     Result := DefaultCalendar.TryParse(Fmt, Culture.UnfreezeDigits(Str), DateTime)
   Else
    Result := DefaultCalendar.TryParse(Fmt, Str, DateTime);
  End;

 Function TLocalizer.NativeDigits(Const Str : String) : String;
  Begin
   If Assigned(Culture) Then
    Result := Culture.FreezeDigits(Str, True)
   Else
    Result := Str;
  End;

{ TTranslator }

 Type
   TWinControlHack = Class(TWinControl);

  Constructor TTranslator.Create(AOwner : TComponent);
   Begin
    Inherited Create(AOwner);
    fTranslatables  := TTranslatables.Create(Self);
    fAutoBiDiLayout := True;
    If csDesigning In ComponentState Then
     Begin
      Localizer := TLocalizer.FirstInstance;
      If (Owner Is TWinControl) And Not(csLoading In Owner.ComponentState) Then
       Begin
        // ParentBiDiMode messes things up simetimes; better to be off!
        TWinControlHack(Owner).ParentBiDiMode := False;
       End;
     End;
   End;

  Destructor TTranslator.Destroy;
   Begin
    Localizer := Nil;
    fTranslatables.Free;
    Inherited Destroy;
   End;

  Procedure TTranslator.Notification(AComponent : TComponent; Operation : TOperation);
   Begin
    Inherited Notification(AComponent, Operation);
    If (Operation = opRemove) And (AComponent = Localizer) Then
     Localizer := Nil;
   End;

  Procedure TTranslator.Loaded;
   Begin
    Inherited Loaded;
    If Not(csDesigning In ComponentState) Then
     Begin
      Translatables.NormalizeProperties;
      DoLoaded;
      Sync;
     End;
   End;

  Procedure TTranslator.SetLocalizer(Value : TLocalizer);
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
      Sync;
     End;
   End;

  Procedure TTranslator.SetTranslatables(Value : TTranslatables);
   Begin
    Translatables.Assign(Value);
   End;

  Procedure TTranslator.SetAutoBiDiLayout(Value : Boolean);
   Begin
    If AutoBiDiLayout <> Value Then
     Begin
      fAutoBiDiLayout := Value;
      If (([csDesigning, csLoading] * ComponentState) = []) And NeedsFlipLayout Then
       FlipLayout;
     End;
   End;

  Function TTranslator.GetText(Const Text : String) : String;
   Var
    TextID  : String;
    Literal : TTextItem;
   Begin
    Result := Text;
    If Text <> '' Then
     Begin
      TextID  := GetStringIdentifier(Text);
      Literal := Translatables.Literals.Find(TextID);
      If Assigned(Literal) And Literal.IsTranslated Then
       Result := Literal.Value;
     End;
   End;

  Function TTranslator.GetNText(Const TextVariants : Array Of String; n : Integer) : String;
   Var
    TextID  : String;
    Literal : TTextItem;
    Index   : Integer;
   Begin
    If Length(TextVariants) = 0 Then
     Result := ''
    Else
     Begin
      TextID  := '#' + GetStringIdentifier(ZStrings.Construct(TextVariants));
      Literal := Translatables.Literals.Find(TextID);
      If Assigned(Literal) And Literal.IsTranslated And Assigned(Localizer) Then
       Begin
        Index  := Localizer.PluralForms.IndexOf(n);
        Result := Literal.Plurals[Index];
       End
      Else
       Begin
        Index := DefaultPluralForms.IndexOf(n);
        If Index > High(TextVariants) Then
         Index := High(TextVariants);
        Result := TextVariants[Index];
       End;
     End;
   End;

  Procedure TTranslator.Sync;
   Begin
    If (([csDestroying, csLoading, csDesigning] * ComponentState) = []) And
    (Assigned(CurrentCulture) Or (Assigned(Localizer) And Localizer.IsReady)) Then
     Begin
      If NeedsFlipLayout Then
       FlipLayout;
      Translate;
     End;
   End;

  Procedure TTranslator.LocalizerNotify(Sender : TLocalizer; Reason : TLocalizerNotification);
   Begin
    If ([csLoading, csDesigning] * ComponentState) = [] Then
     Case Reason Of
      lnChanging :
       BeginUpdate;
      lnBiDiModeChanged :
       If NeedsFlipLayout Then
        FlipLayout;
      lnCultureChanged :
       Translate;
      lnChanged :
       EndUpdate;
     End;
  End;

 Procedure TTranslator.DoLoaded;
  Begin
   If Assigned(OnLoaded) Then
    OnLoaded(Self);
  End;

 Procedure TTranslator.DoBeforeTranslate;
  Begin
   If Assigned(OnBeforeTranslate) Then
    OnBeforeTranslate(Self);
  End;

 Procedure TTranslator.DoAfterTranslate;
  Begin
   If Assigned(OnAfterTranslate) Then
    OnAfterTranslate(Self);
  End;

 Procedure TTranslator.DoBeforeFlipLayout;
  Begin
   If Assigned(OnBeforeFlipLayout) Then
    OnBeforeFlipLayout(Self);
  End;

 Procedure TTranslator.DoAfterFlipLayout;
  Begin
   If Assigned(OnAfterFlipLayout) Then
    OnAfterFlipLayout(Self);
  End;

 Procedure TTranslator.BeginUpdate;
  Begin
   If (fUpdateCount = 0) And (Owner Is TWinControl) Then
    Begin
     If Owner Is TCustomForm Then
      fActiveControl := TCustomForm(Owner).ActiveControl;
     If TWinControl(Owner).HandleAllocated And TWinControl(Owner).Visible Then
      TWinControl(Owner).Perform(WM_SETREDRAW, 0, 0);
    End;
   Inc(fUpdateCount);
  End;

 Procedure TTranslator.EndUpdate;
  Begin
   Dec(fUpdateCount);
   If (fUpdateCount = 0) And (Owner Is TWinControl) Then
    Begin
     If TWinControl(Owner).HandleAllocated And TWinControl(Owner).Visible Then
      Begin
       TWinControl(Owner).Perform(WM_SETREDRAW, 1, 0);
       RedrawWindow(TWinControl(Owner).Handle, Nil, 0,
       RDW_ERASE Or RDW_INVALIDATE Or RDW_ALLCHILDREN Or RDW_UPDATENOW);
      End;
     If (Owner Is TCustomForm) And Assigned(fActiveControl) Then
      TCustomForm(Owner).ActiveControl := fActiveControl;
    End;
  End;

 Function TTranslator.Translate : Boolean;
  Begin
   Result := False;
   DoBeforeTranslate;
   Try
    If Assigned(Localizer) And Localizer.Translate(Translatables) Then
     Begin
      fCurrentCulture := Localizer.Culture;
      Translatables.ApplyProperties;
      Result := True;
     End
    Else If Assigned(CurrentCulture) Then
     Begin
      fCurrentCulture := Nil;
      Translatables.DiscardTranslations;
      Translatables.ApplyProperties;
     End;
   Finally
    DoAfterTranslate;
   End;
  End;

 Function TTranslator.FlipLayout : Boolean;
  Var
   ListViews : TList;
   Streams   : TObjectList;

   // By chaging BiDiMode of a list view, it may lose its items.
   // The following procedure saves the items of all the list view controls, so
   // that we can restore them when needed.

   Procedure StoreListViews;
    Var
     i        : Integer;
     ListView : TListView;
     Stream   : TStream;
    Begin
     ListViews := Nil;
     Streams   := Nil;
     For i     := 0 To Owner.ComponentCount - 1 Do
      If Owner.Components[i] Is TCustomListView Then
       Begin
        ListView := TListView(Owner.Components[i]);
        If ListView.ParentBiDiMode And Not ListView.OwnerData And
        Not(ListView.Action Is TCustomListAction) Then
         Begin
          ListView.HandleNeeded;
          If ListView.Items.Count <> 0 Then
           Begin
            Stream := TMemoryStream.Create;
            Try
             WriteListViewItems(Stream, ListView);
             If Not Assigned(ListViews) Then
              Begin
               ListViews := TList.Create;
               Streams   := TObjectList.Create(True);
              End;
             ListViews.Add(ListView);
             Streams.Add(Stream);
            Except
             Stream.Free;
            End;
           End;
         End;
       End;
    End;

  // The following procedure restores items of any list view control that has
  // lost its items.

   Procedure RestoreListViews;
    Var
     i        : Integer;
     ListView : TListView;
     Stream   : TStream;
    Begin
     If Assigned(ListViews) Then
      Try
       For i := ListViews.Count - 1 Downto 0 Do
        Begin
         ListView := TListView(ListViews[i]);
         ListView.HandleNeeded;
         If ListView.Items.Count = 0 Then
          Begin
           Stream := TStream(Streams[i]);
           Stream.Seek(0, soFromBeginning);
           ReadListViewItems(Stream, ListView);
          End;
        End;
      Finally
       ListViews.Free;
       Streams.Free;
      End;
    End;

  Begin
   Result := False;
   If Owner Is TWinControl Then
    Begin
     DoBeforeFlipLayout;
     Try
      StoreListViews;
      Try
       Try
        If TWinControl(Owner).BiDiMode = bdLeftToRight Then
         TWinControl(Owner).BiDiMode := bdRightToLeft
        Else
         TWinControl(Owner).BiDiMode := bdLeftToRight;
        Application.ProcessMessages;
       Except
        // ignore exceptions
       End;
       fLayoutFlipped := Not IsLayoutFlipped;
       BiDi.FlipChildren(TWinControl(Owner));
      Finally
       RestoreListViews;
      End;
      Result := True;
     Finally
      DoAfterFlipLayout;
     End;
    End;
  End;

 Function TTranslator.NeedsFlipLayout : Boolean;
  Begin
   Result := False;
   If Owner Is TWinControl Then
    Begin
     If AutoBiDiLayout And Assigned(Localizer) And Localizer.IsBiDiToggled Then
      Result := (TWinControl(Owner).BiDiMode <> Localizer.BiDiMode)
     Else
      Result := IsLayoutFlipped;
    End;
  End;

Initialization

Finalization
 If Assigned(TheDefaultPluralForms) Then
  FreeAndNil(TheDefaultPluralForms);

End.
