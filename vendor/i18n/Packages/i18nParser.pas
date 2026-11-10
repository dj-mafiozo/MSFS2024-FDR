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
/// This unit implements classes to retrieve constant and literal strings from
/// source code in Delphi language.
/// </summary>
Unit i18nParser;

{$I DELPHIAREA.INC}

Interface

 Uses
  SysUtils, Classes, Contnrs, i18nCatalog, i18nLocalizer;

 Type

  {$Region 'xmldoc'}
  /// <summary>
  /// EPascalParserError is the exception class for problems that occur while parsing
  /// Pascal source code.
  /// </summary>
  /// <remarks>
  /// The EPascalParserError exception occurs when the Pascal parser encounters an error
  /// in the source code being parsed.
  /// </remarks>
  /// <seealso cref="TPascalStringCollector"/>
  {$Endregion}
  EPascalParserError = Class(Exception)
   Private
    fOffset : Integer;
    fLineNo : Integer;
    fColNo  : Integer;
    fToken  : String;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Sets the additional information about the error.
    /// </summary>
    /// <param name="AOffset">
    /// The character index from the beginning of the source code where the error
    /// occurred.
    /// </param>
    /// <param name="ALineNo">
    /// The line number of the source code where the error occurred.
    /// </param>
    /// <param name="AColNo">
    /// The character index from beginning of the line where the error occurred.
    /// </param>
    /// <param name="AToken">
    /// The last token that the parser was processing when the error occurred.
    /// </param>
    {$Endregion}
    Procedure SetErrorDetails(AOffset, ALineNo, AColNo : Integer; Const AToken : String);
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the character index from the beginning of the source code where the
    /// error occurred.
    /// </summary>
    {$Endregion}
    Property Offset : Integer Read fOffset;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the line number of the source code where the error occurred.
    /// </summary>
    {$Endregion}
    Property LineNo : Integer Read fLineNo;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the character index from beginning of the line where the error occurred.
    /// </summary>
    {$Endregion}
    Property ColNo : Integer Read fColNo;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the last token that the parser was processing when the error occurred.
    /// </summary>
    {$Endregion}
    Property Token : String Read fToken;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This enumeration type identifies the different types of Pascal tokens.
/// </summary>
{$Endregion}

  TPascalToken = (
  {$Region 'xmldoc'}
  /// Indicates that the token is a Pascal reserved word.
  {$Endregion}
  T_ReservedWord,
  {$Region 'xmldoc'}
  /// Indicates that the token is an identifier.
  {$Endregion}
  T_Identifier,
  {$Region 'xmldoc'}
  /// Indicates that the token is a symbol (e.g., operators).
  {$Endregion}
  T_Symbol,
  {$Region 'xmldoc'}
  /// Indicates that the token is a string literal.
  {$Endregion}
  T_String,
  {$Region 'xmldoc'}
  /// Indicates that the token is an integer literal.
  {$Endregion}
  T_Integer,
  {$Region 'xmldoc'}
  /// Indicates that the token is a floating-point literal.
  {$Endregion}
  T_Float,
  {$Region 'xmldoc'}
  /// Indicates that the token is an integer literal in hexadecimal notation.
  {$Endregion}
  T_Hex,
  {$Region 'xmldoc'}
  /// Indicates that the token is a character literal.
  {$Endregion}
  T_Character,
  {$Region 'xmldoc'}
  /// Indicates that the token is a block of assembly code.
  {$Endregion}
  T_Assembler,
  {$Region 'xmldoc'}
  /// Indicates that the token is a comment.
  {$Endregion}
  T_Comment,
  {$Region 'xmldoc'}
  /// Indicates that the token is a series of whitespace characters.
  {$Endregion}
  T_WhiteSpace,
  {$Region 'xmldoc'}
  /// Indicates that end of Pascal code is reached.
  {$Endregion}
  T_EOF
  );

{$Region 'xmldoc'}
/// <summary>
/// This enumeration type identifies the errors that may occur while parsing
/// Pascal code.
/// </summary>
{$Endregion}

  TPascalParseError = (
  {$Region 'xmldoc'}
  /// No error
  {$Endregion}
  peNone,
  {$Region 'xmldoc'}
  /// An unterminated comment found
  {$Endregion}
  peUnterminatedComment,
  {$Region 'xmldoc'}
  /// An unterminated string literal found
  {$Endregion}
  peUnterminatedString,
  {$Region 'xmldoc'}
  /// A syntax error found
  {$Endregion}
  peSyntaxError
  );

{$Region 'xmldoc'}
/// <summary>
/// TPascalTokenizer extracts special symbols, reserved words, identifiers,
/// numerals, and character strings from Pascal code.
/// </summary>
{$Endregion}

  TPascalTokenizer = Class(TObject)
   Private
    fSource          : String;
    fToken           : String;
    fTokenPtr        : PChar;
    fTokenLen        : Integer;
    fTokenID         : TPascalToken;
    fError           : TPascalParseError;
    fInsideAssembler : Boolean;
    Function GetToken : String;
    Function GetTokenAsSource : String;
    Function GetTokenPos : Integer;
    Function GetTokenLineNo : Integer;
    Function GetTokenColNo : Integer;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the next Pascal token from Pascal code.
    /// </summary>
    /// <param name="S">
    /// Pointer to the Pascal code. When the method exits, the pointer
    /// moves to the end of the current token.
    /// </param>
    /// <param name="Error">
    /// Returns the parser error if any.
    /// </param>
    /// <returns>
    /// The <see cref="TPascalToken"/> value of the token.
    /// </returns>
    /// <seealso cref="Next"/>
    {$Endregion}
    Function GetNextToken(Var s : PChar; Out Err : TPascalParseError) : TPascalToken;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the class for tokenizing specified Pascal code.
    /// </summary>
    /// <param name="ASource">
    /// The Pascal code to parse.
    /// </param>
    /// <param name="APos">
    /// The offset that indicates the start position of parsing.
    /// </param>
    {$Endregion}
    Constructor Create(Const ASource : String; APos : Integer = 1);
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether a token string is a Pascal reserved word.
    /// </summary>
    /// <param name="Token">
    /// The token string to examine.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the token string is a Pascal reserved
    /// word, otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="IsDirective"/>
    /// <seealso cref="IsPropertyDirective"/>
    /// <seealso cref="IsVisibilityDirective"/>
    /// <seealso cref="IsPortabilityDirective"/>
    {$Endregion}
    Class Function IsReservedWord(Const Token : String) : Boolean; Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether a token string is a Pascal directive.
    /// </summary>
    /// <param name="Token">
    /// The token string to examine.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the token string is a Pascal directive,
    /// otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="IsReservedWord"/>
    /// <seealso cref="IsPropertyDirective"/>
    /// <seealso cref="IsVisibilityDirective"/>
    /// <seealso cref="IsPortabilityDirective"/>
    {$Endregion}
    Class Function IsDirective(Const Token : String) : Boolean; Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether a token string is a Pascal property directive.
    /// </summary>
    /// <param name="Token">
    /// The token string to examine.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the token string is a Pascal property
    /// directive, otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="IsReservedWord"/>
    /// <seealso cref="IsDirective"/>
    /// <seealso cref="IsVisibilityDirective"/>
    /// <seealso cref="IsPortabilityDirective"/>
    {$Endregion}
    Class Function IsPropertyDirective(Const Token : String) : Boolean; Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether a token string is a Pascal visibility directive.
    /// </summary>
    /// <param name="Token">
    /// The token string to examine.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the token string is a Pascal visibility
    /// directive, otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="IsReservedWord"/>
    /// <seealso cref="IsDirective"/>
    /// <seealso cref="IsPropertyDirective"/>
    /// <seealso cref="IsPortabilityDirective"/>
    {$Endregion}
    Class Function IsVisibilityDirective(Const Token : String) : Boolean; Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether a token string is a Pascal portability directive.
    /// </summary>
    /// <param name="Token">
    /// The token string to examine.
    /// </param>
    /// <returns>
    /// Returns <see langword="true"/> if the token string is a Pascal portability
    /// directive, otherwise returns <see langword="false"/>.
    /// </returns>
    /// <seealso cref="IsReservedWord"/>
    /// <seealso cref="IsDirective"/>
    /// <seealso cref="IsPropertyDirective"/>
    /// <seealso cref="IsVisibilityDirective"/>
    {$Endregion}
    Class Function IsPortabilityDirective(Const Token : String) : Boolean; Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Updates the properties with the next token.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> while no error is occurred and end of Pascal
    /// code is not reached, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function Next : Boolean;
    {$Region 'xmldoc'}
    /// <summary>
    /// Instructs the parser to start at a specified position of the Pascal code.
    /// </summary>
    /// <param name="Pos">
    /// The character index that parsing should start from.
    /// </param>
    {$Endregion}
    Procedure SetPosition(Pos : Integer);
    {$Region 'xmldoc'}
    /// <summary>
    /// The Pascal code that is being parsed.
    /// </summary>
    {$Endregion}
    Property Source : String Read fSource;
    {$Region 'xmldoc'}
    /// <summary>
    /// The current token as a string in lower case letters.
    /// </summary>
    {$Endregion}
    Property Token : String Read GetToken;
    {$Region 'xmldoc'}
    /// <summary>
    /// The current token as it appeared in the code.
    /// </summary>
    {$Endregion}
    Property TokenAsSource : String Read GetTokenAsSource;
    {$Region 'xmldoc'}
    /// <summary>
    /// The pointer to the current token within the <see cref="Source"/> property.
    /// </summary>
    {$Endregion}
    Property TokenPtr : PChar Read fTokenPtr;
    {$Region 'xmldoc'}
    /// <summary>
    /// The character index of the current token from beginning of the <see cref="Source"/>
    /// property.
    /// </summary>
    {$Endregion}
    Property TokenPos : Integer Read GetTokenPos;
    {$Region 'xmldoc'}
    /// <summary>
    /// The length of current token in characters.
    /// </summary>
    {$Endregion}
    Property TokenLen : Integer Read fTokenLen;
    {$Region 'xmldoc'}
    /// <summary>
    /// The current token as a <see cref="TPascalToken"/> value.
    /// </summary>
    {$Endregion}
    Property TokenID : TPascalToken Read fTokenID;
    {$Region 'xmldoc'}
    /// <summary>
    /// The line number of the current token in the <see cref="Source"/> property.
    /// </summary>
    {$Endregion}
    Property TokenLineNo : Integer Read GetTokenLineNo;
    {$Region 'xmldoc'}
    /// <summary>
    /// The character index from beginning of the line the current token is placed.
    /// </summary>
    {$Endregion}
    Property TokenColNo : Integer Read GetTokenColNo;
    {$Region 'xmldoc'}
    /// <summary>
    /// The last parse error.
    /// </summary>
    {$Endregion}
    Property Error : TPascalParseError Read fError;
  End;

  TStringValueReference = Class;
  TCodeBlock = Class;

{$Region 'xmldoc'}
/// <summary>
/// TStringValue stores information about a string constant or a string literal
/// in Pascal code.
/// </summary>
{$Endregion}

    TStringValue = Class Abstract(TObject)
   Private
    fValue      : String;
    fReferences : TObjectList;
    Function GetReferenceCount : Integer; Inline;
    Function GetReferences(Index : Integer) : TStringValueReference; Inline;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Computes a unique key for the string value.
    /// </summary>
    /// <returns>
    /// Returns the unique key of the string.
    /// </returns>
    {$Endregion}
    Function GetKey : String; Virtual;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the class and initializes it with a specfied
    /// string value.
    /// </summary>
    /// <param name="AValue">
    /// The string value that the object represents.
    /// </param>
    {$Endregion}
    Constructor Create(Const AValue : String);
    {$Region 'xmldoc'}
    /// <summary>
    /// Destroys the instance and releaes its allocated memory.
    /// </summary>
    {$Endregion}
    Destructor Destroy; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Adds a reference to the string value in the <see cref="References"/> array.
    /// </summary>
    /// <param name="Block">
    /// The <see cref="TCodeBlock"/> object that represents the block of code that
    /// the string is referenced in.
    /// </param>
    /// <returns>
    /// The <see cref="TStringValueReference"/> objects that stores details of the
    /// reference.
    /// </returns>
    /// <seealso cref="TStringValueReference"/>
    {$Endregion}
    Function AddReference(Block : TCodeBlock; Pos, Len : Integer) : TStringValueReference;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether any reference of the string value can be translated.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> if at least one of references of the string
    /// value is translatable, otherwise returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function HasAnyTranslatableReference : Boolean;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the unique key of the string.
    /// </summary>
    {$Endregion}
    Property Key : String Read GetKey;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the string value.
    /// </summary>
    {$Endregion}
    Property Value : String Read fValue;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the number of references of the string value.
    /// </summary>
    {$Endregion}
    Property ReferenceCount : Integer Read GetReferenceCount;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the array of references of the string value.
    /// </summary>
    {$Endregion}
    Property References[Index : Integer] : TStringValueReference Read GetReferences;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TStringLiteral stores information about a literal string in Pascal code.
/// </summary>
{$Endregion}

   TStringLiteral = Class(TStringValue);

 {$Region 'xmldoc'}
 /// <summary>
 /// TStringConstant stores information about a constant or resource string in
 /// a Pascal code.
 /// </summary>
 {$Endregion}

   TStringConstant = Class(TStringValue)
    Private
     fName       : String;
     fIsResource : Boolean;
    Public
     {$Region 'xmldoc'}
     /// <summary>
     /// Creates an instance of the class and initializes it with name and value
     /// of the string constant.
     /// </summary>
     /// <param name="AName">
     /// The name of string constant that this object represents.
     /// </param>
     /// <param name="AValue">
     /// The value of string constant that this object represents.
     /// </param>
     /// <param name="ResStr">
     /// Indicates whether the string constant is a resource string.
     /// </param>
     {$Endregion}
     Constructor Create(Const AName, AValue : String; ResStr : Boolean);
     {$Region 'xmldoc'}
     /// <summary>
     /// Gets whether the string constant is a resource string.
     /// </summary>
     {$Endregion}
     Property IsResourceString : Boolean Read fIsResource;
     {$Region 'xmldoc'}
     /// <summary>
     /// Gets the name of string constant.
     /// </summary>
     {$Endregion}
     Property Name : String Read fName;
   End;

 {$Region 'xmldoc'}
 /// <summary>
 /// TStringPlural stores information about a string that lists plural forms
 /// of a phrase.
 /// </summary>
 {$Endregion}

   TStringPlural = Class(TStringValue)
    Protected
     {$Region 'xmldoc'}
     /// <summary>
     /// Computes a unique key for the string value.
     /// </summary>
     /// <returns>
     /// Returns the unique key of the string.
     /// </returns>
     {$Endregion}
     Function GetKey : String; Override;
   End;

 {$Region 'xmldoc'}
 /// <summary>
 /// This enumeration type identifies the different states of a reference to a
 /// string constant or string literal.
 /// </summary>
 {$Endregion}

   TStringReferenceState = (
   {$Region 'xmldoc'}
   /// Not translatable
   {$Endregion}
   rsUntranslatable,
   {$Region 'xmldoc'}
   /// Not translated
   {$Endregion}
   rsUntranslated,
   {$Region 'xmldoc'}
   /// Translated using <see cref="TTrsnalator.GetText"/> method
   {$Endregion}
   rsTranslatorGetText,
   {$Region 'xmldoc'}
   /// Translated using <see cref="TTrsnalator.GetNText"/> method
   {$Endregion}
   rsTranslatorGetNText,
   {$Region 'xmldoc'}
   /// Translated using global <see cref="GetText"/> function
   {$Endregion}
   rsGlobalGetText,
   {$Region 'xmldoc'}
   /// Translated using global <see cref="GetNText"/> function
   {$Endregion}
   rsGlobalGetNText
   );

 {$Region 'xmldoc'}
 /// <summary>
 /// TStringValueReference stores information about a reference to a string
 /// constant or a string literal in Pascal code.
 /// </summary>
 {$Endregion}

   TStringValueReference = Class(TObject)
    Private
     fStrValue : TStringValue;
     fBlock    : TCodeBlock;
     fPos      : Integer;
     fLen      : Integer;
     fState    : TStringReferenceState;
     fFuncPos  : Integer;
    Public
     {$Region 'xmldoc'}
     /// <summary>
     /// Creates an instance of the class for a specified <see cref="TStringValue"/>
     /// object.
     /// </summary>
     /// <param name="AStrValue">
     /// The <see cref="TStringValue"/> object referenced by this instance.
     /// </param>
     /// <param name="ABlock">
     /// The <see cref="TCodeBlock"/> object that represents the block of code that
     /// the string is referenced in.
     /// </param>
     /// <param name="APos">
     /// The start position of this reference of the string value from start of the
     /// Pascal source code.
     /// </param>
     /// <param name="ALen">
     /// The length of this reference of the string value, in characters.
     /// </param>
     {$Endregion}
     Constructor Create(AStrValue : TStringValue; ABlock : TCodeBlock; APos, ALen : Integer);
     {$Region 'xmldoc'}
     /// <summary>
     /// Indicates whether this reference of the string value can be translated.
     /// </summary>
     /// <returns>
     /// Returns <see langword="true"/> if this reference of the string can be translated.
     /// Otherwise, returns <see langword="false"/>.
     /// </returns>
     {$Endregion}
     Function IsTranslatable : Boolean; Inline;
     {$Region 'xmldoc'}
     /// <summary>
     /// Indicates whether this reference of the string value is already passed to
     /// a translation function.
     /// </summary>
     /// <returns>
     /// Returns <see langword="true"/> if this reference of the string is passed to a
     /// translation function. Otherwise, returns <see langword="false"/>.
     /// </returns>
     {$Endregion}
     Function IsTranslated : Boolean; Inline;
     {$Region 'xmldoc'}
     /// <summary>
     /// Gets the <see cref="TStringValue"/> object that represents the referenced
     /// string value.
     /// </summary>
     {$Endregion}
     Property StrValue : TStringValue Read fStrValue;
     {$Region 'xmldoc'}
     /// <summary>
     /// Gets the <see cref="TCodeBlock"/> object that represents the block of code
     /// that the string is referenced in.
     /// </summary>
     {$Endregion}
     Property Block : TCodeBlock Read fBlock;
     {$Region 'xmldoc'}
     /// <summary>
     /// Gets the offset of this reference of the string value in the Pascal
     /// source code.
     /// </summary>
     {$Endregion}
     Property Pos : Integer Read fPos;
     {$Region 'xmldoc'}
     /// <summary>
     /// Gets the length of this reference of the string value.
     /// </summary>
     {$Endregion}
     Property Len : Integer Read fLen;
     {$Region 'xmldoc'}
     /// <summary>
     /// Gets or sets the current translation state of this reference of the string
     /// value.
     /// </summary>
     {$Endregion}
     Property State : TStringReferenceState Read fState Write fState;
     {$Region 'xmldoc'}
     /// <summary>
     /// Gets or sets the offset of translator function that this reference of the
     /// string value is passed to.
     /// </summary>
     {$Endregion}
     Property FuncPos : Integer Read fFuncPos Write fFuncPos;
   End;

 {$Region 'xmldoc'}
 /// <summary>
 /// TCodeBlock represents the body of a unit, procedure, function, or method in
 /// Pascal code.
 /// </summary>
 {$Endregion}

   TCodeBlock = Class(TObject)
    Private
     fName         : String;
     fParent       : TCodeBlock;
     fBlocks       : TObjectList;
     fStringValues : TObjectList;
     Function GetFullName : String;
     Function GetBlockCount : Integer; Inline;
     Function GetBlocks(Index : Integer) : TCodeBlock; Inline;
     Function GetStringCount : Integer; Inline;
     Function GetStrings(Index : Integer) : TStringValue; Inline;
    Public
     {$Region 'xmldoc'}
     /// <summary>
     /// Creates an instance of the class.
     /// </summary>
     /// <param name="AParent">
     /// The block that this block is inside it.
     /// </param>
     /// <param name="AName">
     /// The name of unit, procedure, function, or method that its body is
     /// represented by this block.
     /// </param>
     {$Endregion}
     Constructor Create(AParent : TCodeBlock; Const AName : String);
     {$Region 'xmldoc'}
     /// <summary>
     /// Destroys the instance and releases its allocated memory.
     /// </summary>
     {$Endregion}
     Destructor Destroy; Override;
     {$Region 'xmldoc'}
     /// <summary>
     /// Indicates whether a specified block is the current block or one of its
     /// parent blocks.
     /// </summary>
     /// <param name="ABlockName">
     /// The name of the black to be checked for accessibility.
     /// </param>
     /// <returns>
     /// Returns <see langword="true"/> if the block specified by its name is
     /// either the current block or one of its parent blocks, otherwise returns
     /// <see langword="false"/>.
     /// </returns>
     {$Endregion}
     Function HaveAccessTo(Const ABlockName : String) : Boolean;
     {$Region 'xmldoc'}
     /// <summary>
     /// Creates a new block as the child block of the current one.
     /// </summary>
     /// <param name="ABlockName">
     /// The name of the child block.
     /// </param>
     /// <returns>
     /// The <see cref="TCodeBlock"/> object that represents the new child block.
     /// </returns>
     {$Endregion}
     Function AddBlock(Const ABlockName : String) : TCodeBlock;
     {$Region 'xmldoc'}
     /// <summary>
     /// Adds a new string value to the list of current block's strings.
     /// </summary>
     /// <param name="StringValue">
     /// The new <see cref="TStringValue"/> object to add.
     /// </param>
     {$Endregion}
     Procedure AddString(StringValue : TStringValue);
     {$Region 'xmldoc'}
     /// <summary>
     /// Searches the current block and its parent blocks to find a string constant
     /// that is identified by its name.
     /// </summary>
     /// <param name="AName">
     /// The name of string constant to find.
     /// </param>
     /// <returns>
     /// The found <see cref="TStringConstant"/> object or <see langword="nil"/> if
     /// a string constant with the specified name is not found.
     /// </returns>
     /// <seealso cref="StringByValue"/>
     {$Endregion}
     Function StringByName(Const AName : String) : TStringConstant;
     {$Region 'xmldoc'}
     /// <summary>
     /// Searches the current block and its parent blocks to find a string constant
     /// or a string literal that has a specified value.
     /// </summary>
     /// <param name="AValue">
     /// The string value to find.
     /// </param>
     /// <returns>
     /// The found <see cref="TStringValue"/> object or <see langword="nil"/> if
     /// the string value is not found.
     /// </returns>
     /// <seealso cref="StringByName"/>
     {$Endregion}
     Function StringByValue(Const AValue : String) : TStringValue;
     {$Region 'xmldoc'}
     /// <summary>
     /// Gets the name that identifies the block.
     /// </summary>
     {$Endregion}
     Property Name : String Read fName;
     {$Region 'xmldoc'}
     /// <summary>
     /// Gets the qualified name of the block.
     /// </summary>
     {$Endregion}
     Property FullName : String Read GetFullName;
     {$Region 'xmldoc'}
     /// <summary>
     /// Gets the parent block of the current block.
     /// </summary>
     {$Endregion}
     Property Parent : TCodeBlock Read fParent;
     {$Region 'xmldoc'}
     /// <summary>
     /// Gets the number of direct child blocks of this block.
     /// </summary>
     {$Endregion}
     Property BlockCount : Integer Read GetBlockCount;
     {$Region 'xmldoc'}
     /// <summary>
     /// Lists the direct child blocks of this block.
     /// </summary>
     {$Endregion}
     Property Blocks[Index : Integer] : TCodeBlock Read GetBlocks;
     {$Region 'xmldoc'}
     /// <summary>
     /// Gets the number of string constants and string literals in this block.
     /// </summary>
     {$Endregion}
     Property StringCount : Integer Read GetStringCount;
     {$Region 'xmldoc'}
     /// <summary>
     /// Lists the string constants and the string literals in this block.
     /// </summary>
     {$Endregion}
     Property Strings[Index : Integer] : TStringValue Read GetStrings;
   End;

 {$Region 'xmldoc'}
 /// <summary>
 /// TPascalStringCollector parses Pascal code and extracts its string constants
 /// and string literals. TPascalStringCollector can also modify the Pascal code
 /// so as to make a selection of those extracted strings translatable.
 /// </summary>
 {$Endregion}

   TPascalStringCollector = Class(TObject)
    Private
     fSource     : String;
     fTranslator : TTranslator;
     fMainBlock  : TCodeBlock;
     Function ParseAndCollectStrings : TCodeBlock;
    Private
     Const SGetText = 'GetText';
     Const SGetNText = 'GetNText';
    Protected
     {$Region 'xmldoc'}
     /// <summary>
     /// Modifies a specified Pascal source code to disallow translating of a
     /// specified string.
     /// </summary>
     /// <param name="ASource">
     /// The Pascal source code to modify.
     /// </param>
     /// <param name="StrRef">
     /// The information about the string.
     /// </param>
     /// <returns>
     /// Returns <see langword="true"/> if the source code is modified to reflect
     /// the request. Otherwise returns <see langword="false"/>.
     /// </returns>
     /// <seealso cref="EnableTranslation"/>
     {$Endregion}
     Function DisableTranslation(Var ASource : String; StrRef : TStringValueReference) : Boolean;
     {$Region 'xmldoc'}
     /// <summary>
     /// Modifies a specified Pascal source code to allow translating of a specified
     /// string.
     /// </summary>
     /// <param name="ASource">
     /// The Pascal source code to modify.
     /// </param>
     /// <param name="StrRef">
     /// The information about the string.
     /// </param>
     /// <returns>
     /// Returns <see langword="true"/> if the source code is modified to reflect
     /// the request. Otherwise returns <see langword="false"/>.
     /// </returns>
     /// <seealso cref="DisableTranslation"/>
     {$Endregion}
     Function EnableTranslation(Var ASource : String; StrRef : TStringValueReference) : Boolean;
     {$Region 'xmldoc'}
     /// <summary>
     /// Gets the <see cref="TCodeBlock"/> object that contains information about
     /// the parsed Pascal code.
     /// </summary>
     {$Endregion}
     Property MainBlock : TCodeBlock Read fMainBlock;
    Public
     {$Region 'xmldoc'}
     /// <summary>
     /// Creates an instance of the class.
     /// </summary>
     /// <param name="ASource">
     /// The Pascal code that its string values should be extracted or mark as
     /// translatable.
     /// </param>
     /// <param name="ATranslator">
     /// The <see cref="TTranslator"/> component instance that will
     /// be used for modifing the Pascal code, so that a selection of string values
     /// can be translated.
     /// </param>
     {$Endregion}
     Constructor Create(Const ASource : String; ATranslator : TTranslator = Nil);
     {$Region 'xmldoc'}
     /// <summary>
     /// Destroys the instance and releases its allocated memory.
     /// </summary>
     {$Endregion}
     Destructor Destroy; Override;
     {$Region 'xmldoc'}
     /// <summary>
     /// Extracts only the translatable string values from the Pascal code.
     /// </summary>
     /// <param name="Dest">
     /// The list of extracted strings.
     /// </param>
     /// <seealso cref="SetTranslatableStrings"/>
     {$Endregion}
     Procedure GetTranslatableStrings(Dest : TTextItems);
     {$Region 'xmldoc'}
     /// <summary>
     /// Returns a modified version of the source code, where only a specified
     /// list of strings are marked as translatable.
     /// </summary>
     /// <param name="Strings">
     /// The list of strings that can be translated.
     /// </param>
     /// <returns>
     /// The modified source code.
     /// </returns>
     /// <seealso cref="GetTranslatableStrings"/>
     {$Endregion}
     Function SetTranslatableStrings(Strings : TTextItems) : String;
     {$Region 'xmldoc'}
     /// <summary>
     /// Gets the original source code.
     /// </summary>
     {$Endregion}
     Property Source : String Read fSource;
     {$Region 'xmldoc'}
     /// <summary>
     /// Gets the <see cref="TTranslator"/> component instance that
     /// is used for for modifing the original source code, so that a selection of
     /// string values can be translated.
     /// </summary>
     {$Endregion}
     Property Translator : TTranslator Read fTranslator;
   End;

 {$Region 'xmldoc'}
 /// <summary>
 /// Indicates whether a specified name is a valid Pascal identifier.
 /// </summary>
 /// <param name="AName">
 /// The name to check for validity.
 /// </param>
 /// <returns>
 /// Returns <see langword="true"/> if the specified name is a valid Pascal identifier.
 /// Otherwise returns <see langword="false"/>.
 /// </returns>
 {$Endregion}

  Function IsValidIdentifier(Const AName : String) : Boolean;

 Implementation

  Uses
   RTLConsts, Types, StrUtils, i18nHashList, i18nMD5, i18nUtils, i18nZStrList;

  Resourcestring
   SSyntaxError = 'Syntax error';
   SUnterminatedCommentError = 'Unterminated comment';
   SUnterminatedStringError = 'Unterminated string';
   SUnexpectedEndOfFileError = 'Unexpected end of file';
   SUnexpectedSomethingError = 'Unexpected ''%s''';
   SSomethingExpectedButEndOfFileError = '''%s'' expected but end of file reached.';
   SSomethingExpectedError = '''%s'' expected but ''%s'' found';
   SIdentifierExpectedError = 'Identifier expected but ''%s'' found';
   SStringConstantExpectedError = 'String constant expected but ''%s'' found';

 { Helper Functions }

  Function IsValidIdentifier(Const AName : String) : Boolean;
   Var
    i : Integer;
   Begin
    Result := False;
    If (Length(AName) > 0) And CharInSet(AName[1], ['A'..'Z', 'a'..'z', '_']) Then
     Begin
      For i := 2 To Length(AName) Do
       If Not CharInSet(AName[i], ['A'..'Z', 'a'..'z', '0'..'9', '_']) Then
        Exit;
      Result := Not TPascalTokenizer.IsReservedWord(AName);
     End;
   End;

 { EPascalParserError }

  Procedure EPascalParserError.SetErrorDetails(AOffset, ALineNo, AColNo : Integer; Const AToken : String);
   Begin
    fOffset := AOffset;
    fLineNo := ALineNo;
    fColNo  := AColNo;
    fToken  := AToken;
   End;

 { TPascalTokenizer }

  Constructor TPascalTokenizer.Create(Const ASource : String; APos : Integer);
   Begin
    fSource := ASource;
    SetPosition(APos);
   End;

  Function TPascalTokenizer.GetToken : String;
   Begin
    If fTokenID In [T_ReservedWord, T_Identifier] Then
     Result := fToken
    Else If fTokenID <> T_EOF Then
     SetString(Result, fTokenPtr, fTokenLen)
    Else
     Result := '';
   End;

  Function TPascalTokenizer.GetTokenAsSource : String;
   Begin
    If fTokenID <> T_EOF Then
     SetString(Result, fTokenPtr, fTokenLen)
    Else
     Result := '';
   End;

  Function TPascalTokenizer.GetTokenPos : Integer;
   Begin
    Result := fTokenPtr - PChar(fSource) + 1;
   End;

  Function TPascalTokenizer.GetTokenLineNo : Integer;
   Var
    p : PChar;
   Begin
    Result := 1;
    p      := PChar(fSource);
    While p <= fTokenPtr Do
     Begin
      If CharInSet(p^, [#10, #13]) Then
       Begin
        Inc(Result);
        If (p^ <> (p + 1)^) And CharInSet((p + 1)^, [#10, #13]) Then
         Inc(p);
       End;
      Inc(p);
     End;
   End;

  Function TPascalTokenizer.GetTokenColNo : Integer;
   Var
    p : PChar;
   Begin
    p := fTokenPtr;
    While (p >= PChar(fSource)) And Not CharInSet(p^, [#10, #13]) Do
     Dec(p);
    Result := fTokenPtr - p;
   End;

  Function TPascalTokenizer.GetNextToken(Var s : PChar; Out Err : TPascalParseError) : TPascalToken;
   Var
    Identifier : String;
    p          : Char;
   Begin
    Result := T_EOF;
    Err    := peNone;
    Case s^Of
     #0 :                                            // end of file or white space?
      Begin
       If fTokenPtr - PChar(fSource) < Length(Source) Then
        Begin
         Inc(s);
         Result := T_WhiteSpace;
        End;
      End;
     '&' :                                           // reserved word as identifier
      Begin
       Inc(s);
       If CharInSet(s^, ['A'..'Z', 'a'..'z', '_']) Then
        Begin
         Repeat
          Inc(s);
         Until Not CharInSet(s^, ['A'..'Z', 'a'..'z', '0'..'9', '_']);
         Result := T_Identifier;
        End
       Else
        Err := peSyntaxError;
      End;
     'A'..'Z', 'a'..'z', '_' :                       // reserved word, identifier
      Begin
       Repeat
        Inc(s);
       Until Not CharInSet(s^, ['A'..'Z', 'a'..'z', '0'..'9', '_']);
       SetString(Identifier, fTokenPtr, s - fTokenPtr);
       If IsReservedWord(Identifier) Then
        Result := T_ReservedWord
       Else
        Result := T_Identifier;
      End;
     #1..#32 :                                       // white space
      Begin
       Repeat
        Inc(s);
       Until Not CharInSet(s^, [#1..#32]);
       Result := T_WhiteSpace;
      End;
     '0'..'9' :                                      // number, float
      Begin
       Result := T_Integer;
       Repeat
        Inc(s);
       Until Not CharInSet(s^, ['0'..'9']);
       If s^ = '.' Then
        Begin
         Result := T_Float;
         Repeat
          Inc(s);
         Until Not CharInSet(s^, ['0'..'9']);
        End;
       If CharInSet(s^, ['E', 'e']) Then
        Begin
         Result := T_Float;
         Inc(s);
         If CharInSet(s^, ['+', '-']) Then
          Inc(s);
         If CharInSet(s^, ['0'..'9']) Then
          Repeat
           Inc(s);
          Until Not CharInSet(s^, ['0'..'9'])
         Else
          Begin
           Err    := peSyntaxError;
           Result := T_EOF;
          End;
        End;
      End;
     '$' :                                           // hex
      Begin
       Repeat
        Inc(s);
       Until Not CharInSet(s^, ['0'..'9', 'a'..'f', 'A'..'F']);
       If (s - 1)^ <> '$' Then
        Result := T_Hex
       Else
        Err := peSyntaxError;
      End;
     '#' :                                           // character
      Begin
       Inc(s);
       If s^ = '$' Then
        Begin
         Repeat
          Inc(s);
         Until Not CharInSet(s^, ['0'..'9', 'a'..'f', 'A'..'F']);
         If (s - 1)^ <> '$' Then
          Result := T_Character;
        End
       Else
        Begin
         While CharInSet(s^, ['0'..'9']) Do
          Inc(s);
         If (s - 1)^ <> '#' Then
          Result := T_Character
         Else
          Err := peSyntaxError;
        End;
      End;
     '''' :                                          // string
      Begin
       Inc(s);
       While ((s^ <> '''') Or ((s + 1)^ = '''')) And (s^ <> #0) Do
        Begin
         If (s^ = '''') And ((s + 1)^ = '''') Then
          Inc(s);
         Inc(s);
        End;
       If s^ <> #0 Then
        Begin
         Inc(s);
         Result := T_String;
        End
       Else
        Err := peUnterminatedString;
      End;
     '{' :                                           // comment { }
      Begin
       Repeat
        Inc(s)
       Until(s^ = '}') Or (s^ = #0);
       If s^ <> #0 Then
        Begin
         Inc(s);
         Result := T_Comment;
        End
       Else
        Err := peUnterminatedComment;
      End
    Else
      If (s^ = '(') And ((s + 1)^ = '*') Then        // comment (* *)
       Begin
        Inc(s, 2);
        While Not((s^ = '*') And ((s + 1)^ = ')')) And (s^ <> #0) Do
         Inc(s);
        If s^ <> #0 Then
         Begin
          Inc(s, 2);
          Result := T_Comment;
         End
        Else
         Err := peUnterminatedComment;
       End
      Else If (s^ = '/') And ((s + 1)^ = '/') Then   // inline comment
       Begin
        Inc(s, 2);
        While Not CharInSet(s^, [#0, #10, #13]) Do
         Inc(s);
        Result := T_Comment;
       End
      Else                                           // symbol
       Begin
        p := s^;
        Inc(s);
        If ((p = ':') And (s^ = '=')) Or
        ((p = '.') And (s^ = '.')) Or
        ((p = '>') And (s^ = '=')) Or
        ((p = '<') And ((s^ = '=') Or (s^ = '>')))
        Then
         Inc(s);
        Result := T_Symbol;
       End;
    End;
  End;

 Function TPascalTokenizer.Next : Boolean;
  Const
   BeginASM = 'asm';
   EndASM   = 'end';
  Var
   s, p : PChar;
  Begin
   Repeat
    Inc(fTokenPtr, fTokenLen);
    s := fTokenPtr;
    If Not fInsideAssembler Then
     Begin
      fTokenID  := GetNextToken(s, fError);
      fTokenLen := s - fTokenPtr;
      If fTokenID In [T_Identifier, T_ReservedWord] Then
       Begin
        SetString(fToken, fTokenPtr, fTokenLen);
        fToken := LowerCase(fToken);
        If (fTokenID = T_ReservedWord) And (fToken = BeginASM) Then
         fInsideAssembler := True;
       End;
     End
    Else
     Begin
      Repeat
       Repeat
        p        := s;
        fTokenID := GetNextToken(s, fError);
       Until fTokenID In [T_Identifier, T_EOF];
       SetString(fToken, p, s - p);
      Until(fTokenID = T_EOF) Or (LowerCase(fToken) = EndASM);
      If fTokenID <> T_EOF Then
       fTokenID        := T_Assembler;
      fTokenLen        := p - fTokenPtr;
      fInsideAssembler := False;
     End;
   Until Not(TokenID In [T_WhiteSpace, T_Comment]);
   Result := (TokenID <> T_EOF);
  End;

 Procedure TPascalTokenizer.SetPosition(Pos : Integer);
  Begin
   If Pos < 1 Then
    Pos := 1;
   If Pos > Length(fSource) Then
    Pos             := Length(Source);
   fInsideAssembler := False;
   fTokenPtr        := PChar(fSource);
   fTokenLen        := Pos - 1;
   Next;
  End;

  Class Function TPascalTokenizer.IsReservedWord(Const Token : String) : Boolean;

 Const
  ReservedWords : Array[1..66] Of String = (
  'and', 'array', 'as', 'asm', 'begin', 'case', 'class', 'const',
  'constructor', 'destructor', 'dispinterface', 'div', 'do', 'downto',
  'else', 'end', 'except', 'exports', 'file', 'finalization', 'finally',
  'for', 'function', 'goto', 'if', 'implementation', 'in', 'inherited',
  'initialization', 'inline', 'interface', 'is', 'label', 'library',
  'mod', 'nil', 'not', 'object', 'of', 'operator', 'or', 'out', 'packed',
  'procedure', 'program', 'property', 'raise', 'record', 'repeat',
  'resourcestring', 'set', 'shl', 'shr', 'string', 'then', 'threadvar',
  'to', 'try', 'type', 'unit', 'until', 'uses', 'var', 'while', 'with', 'xor');

 Var
  i          : Integer;
  LowerToken : String;

Begin
 Result     := False;
 LowerToken := LowerCase(Token);
 For i      := Low(ReservedWords) To High(ReservedWords) Do
  If ReservedWords[i] = LowerToken Then
   Begin
    Result := True;
    Exit;
   End;

End;

  Class Function TPascalTokenizer.IsDirective(Const Token : String) : Boolean;

 Const
  Directives : Array[1..33] Of String = (
  'abstract', 'assembler', 'cdecl', 'delayed', 'deprecated', 'dispid',
  'dynamic', 'experimental', 'export', 'external', 'far', 'final',
  'forward', 'helper', 'inline', 'library', 'local', 'message', 'near',
  'overload', 'override', 'pascal', 'platform', 'reference', 'register',
  'reintroduce', 'safecall', 'sealed', 'static', 'stdcall', 'varargs',
  'virtual', 'winapi');

 Var
  i          : Integer;
  LowerToken : String;

Begin
 Result     := False;
 LowerToken := LowerCase(Token);
 For i      := Low(Directives) To High(Directives) Do
  If Directives[i] = LowerToken Then
   Begin
    Result := True;
    Exit;
   End;

End;

  Class Function TPascalTokenizer.IsPropertyDirective(Const Token : String) : Boolean;

 Const
  PropertyDirectives : Array[1..10] Of String = (
  'default', 'dispid', 'implements', 'index', 'nodefault', 'read',
  'readonly', 'stored', 'write', 'writeonly');

 Var
  i          : Integer;
  LowerToken : String;

Begin
 Result     := False;
 LowerToken := LowerCase(Token);
 For i      := Low(PropertyDirectives) To High(PropertyDirectives) Do
  If PropertyDirectives[i] = LowerToken Then
   Begin
    Result := True;
    Exit;
   End;

End;

  Class Function TPascalTokenizer.IsVisibilityDirective(Const Token : String) : Boolean;

 Const
  VisibilityDirectives : Array[1..5] Of String = (
  'strict', 'private', 'protected', 'public', 'published');

 Var
  i          : Integer;
  LowerToken : String;

Begin
 Result     := False;
 LowerToken := LowerCase(Token);
 For i      := Low(VisibilityDirectives) To High(VisibilityDirectives) Do
  If VisibilityDirectives[i] = LowerToken Then
   Begin
    Result := True;
    Exit;
   End;

End;

  Class Function TPascalTokenizer.IsPortabilityDirective(Const Token : String) : Boolean;

 Const
  PortabilityDirectives : Array[1..4] Of String = (
  'deprecated', 'experimental', 'library', 'platform');

 Var
  i          : Integer;
  LowerToken : String;

Begin
 Result     := False;
 LowerToken := LowerCase(Token);
 For i      := Low(PortabilityDirectives) To High(PortabilityDirectives) Do
  If PortabilityDirectives[i] = LowerToken Then
   Begin
    Result := True;
    Exit;
   End;

End;

{ TStringValue }

 Constructor TStringValue.Create(Const AValue : String);
  Begin
   fValue      := AValue;
   fReferences := TObjectList.Create(True);
  End;

 Destructor TStringValue.Destroy;
  Begin
   fReferences.Free;
   Inherited Destroy;
  End;

 Function TStringValue.AddReference(Block : TCodeBlock; Pos, Len : Integer) : TStringValueReference;
  Begin
   Result := TStringValueReference.Create(Self, Block, Pos, Len);
   fReferences.Add(Result);
  End;

 Function TStringValue.HasAnyTranslatableReference : Boolean;
  Var
   i : Integer;
  Begin
   Result := False;
   For i  := 0 To ReferenceCount - 1 Do
    If References[i].IsTranslatable Then
     Begin
      Result := True;
      Exit;
     End;
  End;

 Function TStringValue.GetKey : String;
  Begin
   Result := GetStringIdentifier(Value);
  End;

 Function TStringValue.GetReferenceCount : Integer;
  Begin
   Result := fReferences.Count;
  End;

 Function TStringValue.GetReferences(Index : Integer) : TStringValueReference;
  Begin
   Result := TStringValueReference(fReferences[Index]);
  End;

{ TStringConstant }

 Constructor TStringConstant.Create(Const AName, AValue : String; ResStr : Boolean);
  Begin
   Inherited Create(AValue);
   fName       := AName;
   fIsResource := ResStr;
  End;

{ TStringPlural }

 Function TStringPlural.GetKey : String;
  Begin
   Result := '#' + Inherited GetKey;
  End;

{ TStringValueReference }

 Constructor TStringValueReference.Create(AStrValue : TStringValue; ABlock : TCodeBlock; APos, ALen : Integer);
  Begin
   fStrValue := AStrValue;
   fBlock    := ABlock;
   fPos      := APos;
   fLen      := ALen;
  End;

 Function TStringValueReference.IsTranslatable : Boolean;
  Begin
   Result := (State <> rsUntranslatable);
  End;

 Function TStringValueReference.IsTranslated : Boolean;
  Begin
   Result := Not(State In [rsUntranslatable, rsUntranslated]);
  End;

{ TCodeBlock }

 Constructor TCodeBlock.Create(AParent : TCodeBlock; Const AName : String);
  Begin
   fName         := AName;
   fParent       := AParent;
   fBlocks       := TObjectList.Create(True);
   fStringValues := TObjectList.Create(True);
  End;

 Destructor TCodeBlock.Destroy;
  Begin
   fBlocks.Free;
   fStringValues.Free;
   Inherited Destroy;
  End;

 Function TCodeBlock.GetFullName : String;
  Begin
   If Assigned(Parent) Then
    Result := Parent.FullName + '.' + Name
   Else
    Result := Name;
  End;

 Function TCodeBlock.GetBlockCount : Integer;
  Begin
   Result := fBlocks.Count;
  End;

 Function TCodeBlock.GetBlocks(Index : Integer) : TCodeBlock;
  Begin
   Result := TCodeBlock(fBlocks[Index]);
  End;

 Function TCodeBlock.GetStringCount : Integer;
  Begin
   Result := fStringValues.Count;
  End;

 Function TCodeBlock.GetStrings(Index : Integer) : TStringValue;
  Begin
   Result := TStringValue(fStringValues[Index]);
  End;

 Function TCodeBlock.HaveAccessTo(Const ABlockName : String) : Boolean;
  Var
   Block : TCodeBlock;
  Begin
   Result := False;
   Block  := Self;
   Repeat
    If AnsiStartsText(ABlockName, Block.Name) And
    ((Length(Block.Name) = Length(ABlockName)) Or
    (Block.Name[Length(ABlockName) + 1] = '.')) Then
     Begin
      Result := True;
      Exit;
     End;
    Block := Block.Parent;
   Until Not Assigned(Block);
  End;

 Function TCodeBlock.AddBlock(Const ABlockName : String) : TCodeBlock;
  Begin
   Result := TCodeBlock.Create(Self, ABlockName);
   fBlocks.Add(Result);
  End;

 Procedure TCodeBlock.AddString(StringValue : TStringValue);
  Begin
   fStringValues.Add(StringValue);
  End;

 Function TCodeBlock.StringByName(Const AName : String) : TStringConstant;
  Var
   i : Integer;
  Begin
   For i := 0 To StringCount - 1 Do
    If Strings[i] Is TStringConstant Then
     Begin
      Result := TStringConstant(Strings[i]);
      If SameText(Result.Name, AName) Then
       Exit;
     End;
   If Assigned(Parent) Then
    Result := Parent.StringByName(AName)
   Else
    Result := Nil;
  End;

 Function TCodeBlock.StringByValue(Const AValue : String) : TStringValue;
  Var
   i : Integer;
  Begin
   For i := 0 To StringCount - 1 Do
    Begin
     Result := Strings[i];
     If Result.Value = AValue Then
      Exit;
    End;
   If Assigned(Parent) Then
    Result := Parent.StringByValue(AValue)
   Else
    Result := Nil;
  End;

{ TPascalStringCollector }

 Constructor TPascalStringCollector.Create(Const ASource : String; ATranslator : TTranslator);
  Begin
   fSource     := ASource;
   fTranslator := ATranslator;
   fMainBlock  := ParseAndCollectStrings;
  End;

 Destructor TPascalStringCollector.Destroy;
  Begin
   If Assigned(fMainBlock) Then
    fMainBlock.Free;
   Inherited Destroy;
  End;

 Function TPascalStringCollector.ParseAndCollectStrings : TCodeBlock;
  Var
   t : TPascalTokenizer;
  Type
   TDeclType = (dtMain, dtInterface, dtImplementation, dtFunction, dtClass);

   Procedure ProcessDecl(Block : TCodeBlock; DeclType : TDeclType); Forward;

   Procedure Error(Const ErrorText : String); Overload;
    Var
     e : EPascalParserError;
    Begin
     e := EPascalParserError.CreateFmt('[%d:%d] %s', [t.TokenLineNo, t.TokenColNo, ErrorText]);
     e.SetErrorDetails(t.TokenPos, t.TokenLineNo, t.TokenColNo, t.TokenAsSource);
     Raise e;
    End;

   Procedure Error(Const ErrorText : String; Const Args : Array Of Const); Overload;
    Begin
     Error(Format(ErrorText, Args));
    End;

   Function NextToken : Boolean;
    Begin
     Result := True;
     If Not t.Next Then
      Case t.Error Of
       peUnterminatedComment : Error(SUnterminatedCommentError);
       peUnterminatedString  : Error(SUnterminatedStringError);
       peSyntaxError         : Error(SSyntaxError);
      Else Result := False;
      End;
    End;

   Procedure NextTokenNeeded;
    Begin
     If Not NextToken Then
      Error(SUnexpectedEndOfFileError)
    End;

   Procedure SkipToSymbol(Const Symbol : String);
    Begin
     While (t.TokenID <> T_Symbol) Or (t.Token <> Symbol) Do
      If Not NextToken Then
       Error(SSomethingExpectedButEndOfFileError, [Symbol]);
    End;

   Procedure SkipAfterSymbol(Const Symbol : String);
    Begin
     SkipToSymbol(Symbol);
     NextTokenNeeded;
    End;

   Procedure SkipBlock(Const BeginToken, EndToken : String);
    Var
     Level : Integer;
    Begin
     Level := 0;
     Repeat
      If t.Token = BeginToken Then
       Inc(Level)
      Else If t.Token = EndToken Then
       Dec(Level);
     Until(Level = 0) Or Not NextToken;
     If Level <> 0 Then
      Error(SSomethingExpectedButEndOfFileError, [EndToken]);
     NextTokenNeeded;
    End;

   Procedure ProcessIdentifier(Out Ident : String; Out Pos : Integer; AllowGenerics : Boolean); Overload;
    Var
     ValidTokens : Set Of TPascalToken;
    Begin
     Pos         := t.TokenPos;
     ValidTokens := [T_Identifier];
     Repeat
      If Not(t.TokenID In ValidTokens) Then
       Error(SIdentifierExpectedError, [t.Token]);
      Ident := Ident + t.Token;
      NextTokenNeeded;
      If AllowGenerics And (t.Token = '<') Then
       Begin
        Repeat
         Ident := Ident + t.Token;
         NextTokenNeeded;
        Until(t.Token = '>');
        Ident := Ident + t.Token;
        NextTokenNeeded;
       End;
      If t.Token <> '.' Then
       Exit;
      Ident := Ident + t.Token;
      NextTokenNeeded;
      Include(ValidTokens, T_ReservedWord);
     Until False;
    End;

   Procedure ProcessIdentifier(Out Ident : String; AllowGenerics : Boolean); Overload;
    Var
     Pos : Integer;
    Begin
     ProcessIdentifier(Ident, Pos, AllowGenerics);
    End;

   Procedure ProcessString(Out Str : String; Out Pos, Len : Integer);
    Var
     SubStr : String;
    Begin
     If Not(t.TokenID In [T_String, T_Character]) Then
      Error(SStringConstantExpectedError, [t.Token]);
     Str := '';
     Len := 0;
     Pos := t.TokenPos;
     Repeat
      SubStr := t.Token;
      If t.TokenID = T_String Then
       SubStr := AnsiDequotedStr(t.Token, '''')
      Else
       SubStr := Char(StrToInt(Copy(SubStr, 2, Length(SubStr) - 1)));
      Str     := Str + SubStr;
      Len     := t.TokenPos - Pos + t.TokenLen;
      NextTokenNeeded;
      If t.Token = '+' Then
       NextTokenNeeded;
     Until Not(t.TokenID In [T_String, T_Character]);
    End;

   Procedure ProcessConsts(Block : TCodeBlock; IsResource, CanCollect : Boolean);
    Var
     Indetifier, Value  : String;
     ValuePos, ValueLen : Integer;
     StrConst           : TStringConstant;
    Begin
     If t.Token = '[' Then
      SkipBlock('[', ']');
     While (t.TokenID = T_Identifier) And Not t.IsVisibilityDirective(t.Token) Do
      Begin
       Indetifier := t.TokenAsSource;
       SkipAfterSymbol('=');
       If (t.TokenID In [T_ReservedWord, T_Identifier]) And
       ((t.Token = 'string') Or (t.Token = 'ansistring') Or
       (t.Token = 'widestring') Or (t.Token = 'utf8string') Or
       (t.Token = 'unicodestring') Or (t.Token = 'rawbytestring') Or
       (t.Token = 'shortstring')) Then
        Begin
         NextTokenNeeded;
         If t.Token <> '(' Then
          Error(SSomethingExpectedError, ['(', t.Token]);
         NextTokenNeeded;
        End;
       If t.TokenID In [T_String, T_Character] Then
        Begin
         ProcessString(Value, ValuePos, ValueLen);
         If CanCollect And IsStringTranslatable(Value) Then
          Begin
           StrConst := TStringConstant.Create(Indetifier, Value, IsResource);
           Block.AddString(StrConst);
          End;
        End
       Else If t.TokenID = T_Symbol Then
        Begin
         If t.Token = '(' Then
          SkipBlock('(', ')')
         Else If t.Token = '[' Then
          SkipBlock('[', ']');
        End;
       SkipAfterSymbol(';');
       If t.Token = '[' Then
        SkipBlock('[', ']');
      End;
    End;

   Procedure ProcessFuncDecl(Block : TCodeBlock; Out FuncName : String; Out Prototype : Boolean);
    Begin
     If t.TokenID = T_Identifier Then
      ProcessIdentifier(FuncName, True)
     Else
      FuncName := '';
     If t.Token = '(' Then
      SkipBlock('(', ')');
     SkipAfterSymbol(';');
     Prototype := False;
     While (t.TokenID = T_Identifier) And t.IsDirective(t.Token) Do
      Begin
       If (t.Token = 'forward') Or (t.Token = 'external') Then
        Prototype := True;
       SkipAfterSymbol(';');
      End;
    End;

   Procedure SkipFuncDecl(Block : TCodeBlock);
    Var
     FuncName  : String;
     Prototype : Boolean;
    Begin
     ProcessFuncDecl(Block, FuncName, Prototype);
    End;

   Procedure SkipTypeDecl(Block : TCodeBlock);
    Var
     AlreadyEndOfDecl : Boolean;
    Begin
     If t.Token = '[' Then
      SkipBlock('[', ']');
     While t.TokenID = T_Identifier Do
      Begin
       If t.Token = '<' Then
        SkipBlock('<', '>');
       SkipAfterSymbol('=');
       If t.Token = 'packed' Then
        NextTokenNeeded;
       AlreadyEndOfDecl := False;
       If t.Token = 'record' Then
        SkipBlock('record', 'end')
       Else If (t.Token = 'function') Or (t.Token = 'procedure') Or
       (t.Token = 'constructor') Or (t.Token = 'destructor') Then
        Begin
         NextTokenNeeded;
         SkipFuncDecl(Block);
         AlreadyEndOfDecl := True;
        End
       Else If (t.Token = 'class') Or (t.Token = 'interface') Or (t.Token = 'dispinterface') Then
        Begin
         Repeat
          NextToken;
         Until(t.TokenID <> T_Identifier) Or Not t.IsDirective(t.Token);
         If t.Token <> 'of' Then
          Begin
           If t.Token = '(' Then
            Begin
             SkipBlock('(', ')');
             While (t.TokenID = T_Identifier) And t.IsPortabilityDirective(t.Token) Do
              NextTokenNeeded;
            End;
           If t.Token = 'for' Then
            Begin
             NextTokenNeeded;
             If t.TokenID <> T_Identifier Then
              Error(SIdentifierExpectedError, [t.Token]);
             NextTokenNeeded;
            End;
           If t.Token <> ';' Then
            Begin
             ProcessDecl(Block, dtClass);
             If t.Token <> 'end' Then
              Error(SSomethingExpectedError, ['end', t.Token]);
            End;
          End;
        End;
       If Not AlreadyEndOfDecl Then
        SkipAfterSymbol(';');
       If (t.TokenID = T_Identifier) And t.IsVisibilityDirective(t.Token) Then
        Exit;
       If t.Token = '[' Then
        SkipBlock('[', ']');
      End;
    End;

   Procedure SkipVarDecl(Block : TCodeBlock);
    Var
     AlreadyEndOfDecl : Boolean;
    Begin
     If t.Token = '[' Then
      SkipBlock('[', ']');
     While t.TokenID = T_Identifier Do
      Begin
       SkipAfterSymbol(':');
       If t.Token = 'packed' Then
        NextTokenNeeded;
       AlreadyEndOfDecl := False;
       If t.Token = 'record' Then
        SkipBlock('record', 'end')
       Else If (t.Token = 'function') Or (t.Token = 'procedure') Then
        Begin
         NextTokenNeeded;
         SkipFuncDecl(Block);
         AlreadyEndOfDecl := True;
        End;
       If Not AlreadyEndOfDecl Then
        SkipAfterSymbol(';');
       If (t.TokenID = T_Identifier) And t.IsVisibilityDirective(t.Token) Then
        Exit;
       If t.Token = '[' Then
        SkipBlock('[', ']');
      End;
    End;

   Procedure ProcessBody(Block : TCodeBlock; CanCollect : Boolean);
    Var
     Level                        : Integer;
     StrValue                     : TStringValue;
     Str, Ident, Plural           : String;
     IdentPos, PluralPos, FuncPos : Integer;
     StrPos, StrLen               : Integer;
     AlreadyNextToken, InPlural   : Boolean;
     TranslationState             : TStringReferenceState;
     OpenBraces                   : Integer;

     Procedure PrepareReference(StrRef : TStringValueReference);
      Begin
       If TranslationState In [rsTranslatorGetNText, rsGlobalGetNText] Then
        Begin
         StrRef.State := rsUntranslatable;
         If InPlural Then
          ZStrings.Add(Plural, StrRef.StrValue.Value);
        End
       Else If Not CanCollect Or ((FuncPos = 0) And (TranslationState <> rsUntranslated)) Then
        StrRef.State := rsUntranslatable
       Else
        Begin
         StrRef.State   := TranslationState;
         StrRef.FuncPos := FuncPos;
         FuncPos        := 0;
        End;
      End;

    Begin
     If CanCollect Then
      Level := 0
     Else
      Level           := 1;
     FuncPos          := 0;
     PluralPos        := 0;
     OpenBraces       := 0;
     InPlural         := False;
     TranslationState := rsUntranslated;
     Repeat
      AlreadyNextToken := False;
      Case t.TokenID Of
       T_ReservedWord :
        Begin
         If (t.Token = 'begin') Or (t.Token = 'asm') Or
         (t.Token = 'case') Or (t.Token = 'try')
         Then
          Inc(Level)
         Else If t.Token = 'end' Then
          Begin
           Dec(Level);
           If Level <= 0 Then
            Begin
             If (Level = 0) And t.Next Then
              Begin
               If Not Assigned(Block.Parent) Then
                Begin
                 If t.Token <> '.' Then
                  Error(SSomethingExpectedError, ['.', t.Token]);
                End
               Else
                Begin
                 If t.Token <> ';' Then
                  Error(SSomethingExpectedError, [';', t.Token]);
                End;
              End;
             Exit;
            End
          End;
        End;
       T_Identifier :
        Begin
         ProcessIdentifier(Ident, IdentPos, False);
         If t.Token = '(' Then
          Begin
           If TranslationState = rsUntranslated Then
            Begin
             If SameText(Ident, SGetText) Then
              TranslationState := rsGlobalGetText
             Else If SameText(Ident, SGetNText) Then
              TranslationState := rsGlobalGetNText
             Else If Assigned(Translator) Then
              Begin
               If SameText(Ident, Translator.Name + '.' + SGetText) Then
                TranslationState := rsTranslatorGetText
               Else If SameText(Ident, Translator.Name + '.' + SGetNText) Then
                TranslationState := rsTranslatorGetNText
              End;
             FuncPos    := IdentPos;
             OpenBraces := 0;
            End;
          End
         Else If t.Token <> '[' Then
          Begin
           StrValue := Block.StringByName(Ident);
           If Assigned(StrValue) Then
            PrepareReference(StrValue.AddReference(Block, IdentPos, Length(Ident)));
          End;
         AlreadyNextToken := True;
        End;
       T_String, T_Character :
        Begin
         ProcessString(Str, StrPos, StrLen);
         If IsStringTranslatable(Str) Then
          Begin
           StrValue := Block.StringByValue(Str);
           If Not Assigned(StrValue) Then
            Begin
             StrValue := TStringLiteral.Create(Str);
             Block.AddString(StrValue);
            End;
           PrepareReference(StrValue.AddReference(Block, StrPos, StrLen));
          End;
         AlreadyNextToken := True;
        End;
       T_Symbol :
        Begin
         If TranslationState <> rsUntranslated Then
          Begin
           If t.Token = ')' Then
            Begin
             Dec(OpenBraces);
             If OpenBraces = 0 Then
              Begin
               TranslationState := rsUntranslated;
               FuncPos          := 0;
              End;
            End
           Else If t.Token = '(' Then
            Inc(OpenBraces)
           Else If TranslationState In [rsTranslatorGetNText, rsGlobalGetNText] Then
            Begin
             If t.Token = '[' Then
              Begin
               PluralPos := t.TokenPos;
               InPlural  := True;
               Plural    := '';
              End
             Else If t.Token = ']' Then
              Begin
               InPlural := False;
               StrValue := Block.StringByValue(Plural);
               If Not Assigned(StrValue) Then
                Begin
                 StrValue := TStringPlural.Create(Plural);
                 Block.AddString(StrValue);
                End;
               StrValue.AddReference(Block, PluralPos, t.TokenPos - PluralPos).State := TranslationState;
              End;
            End;
          End;
        End;
      End;
      If Not AlreadyNextToken Then
       NextTokenNeeded;
     Until False;
    End;

   Procedure ProcessDecl(Block : TCodeBlock; DeclType : TDeclType);
    Var
     SubBlock         : TCodeBlock;
     FuncName         : String;
     FuncPrototype    : Boolean;
     AlreadyNextToken : Boolean;
    Begin
     Repeat
      AlreadyNextToken := False;
      If t.TokenID = T_ReservedWord Then
       Begin
        If t.Token = 'class' Then
         NextTokenNeeded;
        If (t.Token = 'function') Or (t.Token = 'procedure') Or
        (t.Token = 'constructor') Or (t.Token = 'destructor') Or
        (t.Token = 'operator') Then
         Begin
          NextTokenNeeded;
          ProcessFuncDecl(Block, FuncName, FuncPrototype);
          If Not FuncPrototype And (DeclType In [dtMain, dtImplementation, dtFunction]) Then
           Begin
            SubBlock := Block.AddBlock(FuncName);
            ProcessDecl(SubBlock, dtFunction);
            ProcessBody(SubBlock, True);
           End
          Else
           AlreadyNextToken := True;
         End
        Else If t.Token = 'resourcestring' Then
         Begin
          NextTokenNeeded;
          ProcessConsts(Block, True, DeclType <> dtClass);
          AlreadyNextToken := True;
         End
        Else If t.Token = 'const' Then
         Begin
          NextTokenNeeded;
          ProcessConsts(Block, False, DeclType <> dtClass);
          AlreadyNextToken := True;
         End
        Else If t.Token = 'type' Then
         Begin
          NextTokenNeeded;
          SkipTypeDecl(Block);
          AlreadyNextToken := True;
         End
        Else If (t.Token = 'var') Or (t.Token = 'threadvar') Then
         Begin
          NextTokenNeeded;
          SkipVarDecl(Block);
          AlreadyNextToken := True;
         End
        Else If t.Token = 'asm' Then
         Begin
          If DeclType <> dtFunction Then
           Error(SUnexpectedSomethingError, [t.Token]);
          Exit;
         End
        Else If t.Token = 'begin' Then
         Begin
          If Not(DeclType In [dtMain, dtImplementation, dtFunction]) Then
           Error(SUnexpectedSomethingError, [t.Token]);
          Exit;
         End
        Else If t.Token = 'end' Then
         Begin
          If Not(DeclType In [dtMain, dtImplementation, dtClass]) Then
           Error(SUnexpectedSomethingError, [t.Token]);
          Exit;
         End
        Else If t.Token = 'implementation' Then
         Begin
          If DeclType <> dtInterface Then
           Error(SUnexpectedSomethingError, [t.Token]);
          Exit;
         End
        Else If (t.Token = 'initialization') Or (t.Token = 'finalization') Then
         Begin
          If DeclType <> dtImplementation Then
           Error(SUnexpectedSomethingError, [t.Token]);
          Exit;
         End
       End
      Else If t.TokenID = T_Symbol Then
       Begin
        If t.Token = '[' Then
         Begin
          SkipBlock('[', ']');
          AlreadyNextToken := True;
         End;
       End
      Else If (DeclType = dtClass) And (t.TokenID = T_Identifier) Then
       Begin
        If t.IsVisibilityDirective(t.Token) Then
         Begin
          Repeat
           NextTokenNeeded;
          Until(t.TokenID <> T_Identifier) Or Not t.IsVisibilityDirective(t.Token);
          AlreadyNextToken := True;
         End
        Else If t.IsPropertyDirective(t.Token) Then
         Begin
          Repeat
           SkipAfterSymbol(';');
          Until(t.TokenID <> T_Identifier) Or Not t.IsPropertyDirective(t.Token);
          AlreadyNextToken := True;
         End
        Else
         Begin
          SkipVarDecl(Block);
          AlreadyNextToken := True;
         End;
       End;
      If Not AlreadyNextToken Then
       SkipAfterSymbol(';');
     Until False;
    End;
  Var
   MainType, MainName : String;

  Begin
   Result := Nil;
   t      := TPascalTokenizer.Create(Source);
   Try
    If t.TokenID = T_EOF Then
     NextTokenNeeded;
    MainType := t.Token;
    NextTokenNeeded;
    ProcessIdentifier(MainName, False);
    SkipAfterSymbol(';');
    Result := TCodeBlock.Create(Nil, MainName);
    Try
     If (MainType = 'program') Or (MainType = 'library') Or (MainType = 'package') Then
      Begin
       ProcessDecl(Result, dtMain);
       ProcessBody(Result, t.Token = 'begin');
      End
     Else If MainType = 'unit' Then
      Begin
       If t.Token <> 'interface' Then
        Error(SSomethingExpectedError, ['interface', t.Token]);
       NextTokenNeeded;
       ProcessDecl(Result, dtInterface);
       If t.Token <> 'implementation' Then
        Error(SSomethingExpectedError, ['implementation', t.Token]);
       NextTokenNeeded;
       ProcessDecl(Result, dtImplementation);
       If (t.Token <> 'begin') Or NextToken Then
        ProcessBody(Result, False);
      End;
    Except
     If Assigned(Result) Then
      FreeAndNil(Result);
     Raise;
    End;
   Finally
    t.Free;
   End;
  End;

 Function TPascalStringCollector.DisableTranslation(Var ASource : String; StrRef : TStringValueReference) : Boolean;
  Var
   t : TPascalTokenizer;
  Begin
   Result := False;
   If (StrRef.FuncPos = 0) Or Not(StrRef.State In [rsTranslatorGetText, rsGlobalGetText]) Then
    Exit;
   t := TPascalTokenizer.Create(ASource, StrRef.Pos + StrRef.Len);
   Try
    If ((t.Token = ',') And Not(t.Next And (t.TokenID In [T_Identifier, T_String]) And t.Next)) Or (t.Token <> ')') Then
     Exit;
    Delete(ASource, StrRef.Pos + StrRef.Len, t.TokenPos - (StrRef.Pos + StrRef.Len) + 1);
    Delete(ASource, StrRef.FuncPos, StrRef.Pos - StrRef.FuncPos);
   Finally
    t.Free;
   End;
   Result := True;
  End;

 Function TPascalStringCollector.EnableTranslation(Var ASource : String; StrRef : TStringValueReference) : Boolean;
  Var
   OldCode, NewCode : String;
  Begin
   OldCode := Copy(ASource, StrRef.Pos, StrRef.Len);
   If Assigned(Translator) And (Translator.Owner <> Nil) And (Translator.Name <> '') And
   StrRef.Block.HaveAccessTo(Translator.Owner.ClassName)
   Then
    NewCode := Format('%s.%s(%s)', [Translator.Name, SGetText, OldCode])
   Else
    NewCode := Format('%s(%s, ''*'')', [SGetText, OldCode]);
   Delete(ASource, StrRef.Pos, StrRef.Len);
   Insert(NewCode, ASource, StrRef.Pos);
   Result := True;
  End;

 Procedure TPascalStringCollector.GetTranslatableStrings(Dest : TTextItems);

   Procedure GetTranslatableStringsOf(Block : TCodeBlock);
    Var
     i      : Integer;
     StrVal : TStringValue;
    Begin
     For i := 0 To Block.StringCount - 1 Do
      Begin
       StrVal := Block.Strings[i];
       If StrVal.HasAnyTranslatableReference Then
        Dest.Add(StrVal.Key).OriginalValue := StrVal.Value;
      End;
     For i := 0 To Block.BlockCount - 1 Do
      GetTranslatableStringsOf(Block.Blocks[i]);
    End;

  Begin
   If Assigned(MainBlock) Then
    GetTranslatableStringsOf(MainBlock);
  End;

 Function TPascalStringCollector.SetTranslatableStrings(Strings : TTextItems) : String;

   Procedure SortReferences(Block : TCodeBlock; SortedList : TList);
    Var
     i, j, Index : Integer;
     Reference   : TStringValueReference;
    Begin
     For i  := 0 To Block.StringCount - 1 Do
      For j := 0 To Block.Strings[i].ReferenceCount - 1 Do
       Begin
        Reference := Block.Strings[i].References[j];
        Index     := 0;
        While Index < SortedList.Count Do
         Begin
          If TStringValueReference(SortedList[Index]).Pos < Reference.Pos Then
           Break;
          Inc(Index);
         End;
        SortedList.Insert(Index, Reference);
       End;
     For i := 0 To Block.BlockCount - 1 Do
      SortReferences(Block.Blocks[i], SortedList);
    End;
  Var
   i          : Integer;
   SortedList : TList;
   Item       : TTextItem;
   StrRef     : TStringValueReference;

  Begin
   Result := Source;
   If Assigned(MainBlock) Then
    Begin
     SortedList := TList.Create;
     Try
      SortReferences(MainBlock, SortedList);
      For i := 0 To SortedList.Count - 1 Do
       Begin
        StrRef := TStringValueReference(SortedList[i]);
        If StrRef.IsTranslatable Then
         Begin
          Item := Strings.Find(StrRef.StrValue.Key);
          If Not StrRef.IsTranslated And Assigned(Item) Then
           EnableTranslation(Result, StrRef)
          Else If StrRef.IsTranslated And Not Assigned(Item) Then
           DisableTranslation(Result, StrRef);
         End;
       End;
     Finally
      SortedList.Free;
     End;
    End;
  End;

End.
