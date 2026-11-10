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
/// This unit implements classes and functions to determine how languages
/// handle plurals of nouns or unit expressions.
/// </summary>
Unit i18nPlurals;

{$I DELPHIAREA.INC}

Interface

 Uses
  Windows, SysUtils, Classes, i18nHashList, i18nCExpr;

 Type

  {$Region 'xmldoc'}
  /// <summary>
  /// EPluralFormsError is the exception class for problems that occur while using
  /// an instance of the <see cref="TPluralForms"/> class.
  /// </summary>
  /// <remarks>
  /// EPluralFormsError represents exceptions that occur when trying to use a plural
  /// rule. These exceptions include:
  /// <list type="bullet">
  ///   <item>Attempts to use a plural rule that is not in a correct syntax.</item>
  ///   <item>Specifying an invalid value for the number of plurals.</item>
  ///   <item>Using a variable other than <c>n</c> in a formula of the plural rule.</item>
  /// </list>
  /// </remarks>
  /// <seealso cref="TPluralForms"/>
  {$Endregion}
   EPluralFormsError = Class(Exception);

 {$Region 'xmldoc'}
 /// <summary>
 /// TPluralForms manages the way a language handles plurals of nouns or unit
 /// expressions.
 /// </summary>
 /// <remarks>
 /// Plural forms are grammatical variants depending on a number. Some languages
 /// have only one form. Some other have two forms, called singular and plural.
 /// Other languages have three forms, called singular, dual and plural. There
 /// are also languages with up to six forms.
 ///
 /// Use TPluralForms to select the proper plural form from a list of plural forms
 /// that a language may have. The selection is handled by the rules of the language
 /// and a specified number.
 ///
 /// TPluralForms not only has a method to select the right plural form but also has
 /// properties and methods to specify the rules of the language to handle the selection.
 ///
 /// TPluralForms provides two ways to define the language's rules for selecting a plural
 /// form:
 /// <list type="bullet">
 ///   <item>
 ///   Designating either the locale or the international language code of the target
 ///   language. TPluralForms knows the plural rules of most languages.</item>
 ///   <item>
 ///   Specifying the number of plural forms for the target language, and supplying a
 ///   formula to dictate its rules.</item>
 /// </list>
 /// </remarks>
 {$Endregion}

   TPluralForms = Class(TObject)
    Private
     fNumOfPlurals : Integer;
     fFormula      : TCExpression;
     Cache         : TKeyLookup<Integer, Integer>;
     Function GetRule : String;
     Procedure SetRule(Const Value : String);
    Public
     {$Region 'xmldoc'}
     /// <summary>
     /// Creates an instance of the class.
     /// </summary>
     /// <param name="ARule">
     /// The plural rule to initialize the instance.
     /// </param>
     /// <seealso cref="Rule"/>
     {$Endregion}
     Constructor Create(Const ARule : String);
     {$Region 'xmldoc'}
     /// <summary>
     /// Destroys the instance of the class and releases its allocated memory.
     /// </summary>
     {$Endregion}
     Destructor Destroy; Override;
     {$Region 'xmldoc'}
     /// <summary>
     /// Retrieves the information about the plural form selection of a specified language.
     /// </summary>
     /// <param name="Locale">
     /// The locale or the two-character international language code of the target language.
     /// </param>
     /// <param name="DefaultRule">
     /// The plural rule that will be returned if the rule of the specified locale/language
     /// is unknown.
     /// </param>
     /// <returns>
     /// If the plural rule of the language given by <paramref name="Locale"/> is known,
     /// returns it. Otherwise, returns the rule given by <paramref name="DefaultRule"/>.
     /// </returns>
     /// <seealso cref="Rule"/>
     {$Endregion}
     Class Function RuleOf(Const Locale : String; Const DefaultRule : String = '') : String; Static;
     {$Region 'xmldoc'}
     /// <summary>
     /// Parses a specified plural rule and extracts the number of plural forms plus
     /// the formula for selecting a plural form.
     /// </summary>
     /// <param name="ARule">
     /// The plural rule to parse.
     /// </param>
     /// <param name="ANumOfPlurals">
     /// Returns the number of plural forms.
     /// </param>
     /// <param name="AFormula">
     /// Returns the formula for selecting a plural form as an expression in C language
     /// syntax.
     /// </param>
     /// <returns>
     /// Returns <see langword="true"/> if the rule is parsed successfully. Otherwise,
     /// returns <see langword="false"/>.
     /// </returns>
     /// <seealso cref="Apply"/>
     /// <seealso cref="Rule"/>
     {$Endregion}
     Class Function ParseRule(Const ARule : String; Out ANumOfPlurals : Integer; Out AFormula : String) : Boolean; Static;
     {$Region 'xmldoc'}
     /// <summary>
     /// Sets a custom rule for selecting the plural forms by specifying the number
     /// of plural forms in a target language and providing a formula that evaluates
     /// the index of the proper plural form based on variable <c>n</c>.
     /// </summary>
     /// <param name="ANumOfPlurals">
     /// The number of plural forms for the target language.
     /// </param>
     /// <param name="AFormula">
     /// The expression in C language syntax that returns the index of the right plural
     /// form based on variable <c>n</c>. See <see cref="Rule"/> property for more
     /// information.
     /// </param>
     /// <exception cref="EPluralFormsError">
     /// Occurs when value of either of the parameters is not acceptable.
     /// </exception>
     /// <exception cref="ECExpressionError">
     /// Occurs when the expression specified by <paramref name="AFormula"/> has
     /// a syntax error.
     /// </exception>
     /// <seealso cref="ParseRule"/>
     /// <seealso cref="Rule"/>
     {$Endregion}
     Procedure Apply(ANumOfPlurals : Integer; Const AFormula : String);
     {$Region 'xmldoc'}
     /// <summary>
     /// Extracts the number of plurals from a specified plural rule.
     /// </summary>
     /// <param name="ARule">
     /// The plural rule to extract the number of plurals from it.
     /// </param>
     /// <returns>
     /// Returns the number of plurals indicated by the specified plural rule.
     /// </returns>
     /// <exception cref="EPluralFormsError">
     /// Occurs when the rule is not in correct syntax.
     /// </exception>
     {$Endregion}
     Class Function ExtractNumOfPlurals(Const ARule : String) : Integer; Static;
     {$Region 'xmldoc'}
     /// <summary>
     /// Finds the index of the right plural form for expressing a specified number
     /// of nouns or units.
     /// </summary>
     /// <param name="N">
     /// The number of nouns or units to express.
     /// </param>
     /// <returns>
     /// The zero-based index of the proper plural form in a list of plural forms.
     /// </returns>
     {$Endregion}
     Function IndexOf(n : Integer) : Integer;
     {$Region 'xmldoc'}
     /// <summary>
     /// Gets or sets the plural rule of the target language as a string.
     /// </summary>
     /// <remarks>
     /// The Rule property provides the information about the plural form selection. For
     /// example, the plural rule for English language looks like this:
     /// <code>
     /// nplurals=2; plural=(n == 1) ? 0 : 1;
     /// </code>
     /// The <c>nplurals</c> value must be a decimal number which specifies how many
     /// different plural forms exist for this language. The string following <c>plural</c>
     /// is an expression which is using the C language syntax. Exceptions are that numbers
     /// must be decimal, and the only variable allowed is <c>n</c>. Spaces are allowed in
     /// the expression. This expression will be evaluated whenever <see cref="IndexOf"/>
     /// method is called. The absolute value of the numeric value passed to this method is then
     /// assigned to the variable <c>n</c> in the expression. The resulting value then
     /// must be greater than or equal to zero and smaller than the value given as the
     /// value of <c>nplurals</c>.</remarks>
     /// <exception cref="EPluralFormsError">
     /// Occurs when the rule is not in correct syntax or indicates an unacceptable value
     /// or expression.
     /// </exception>
     /// <exception cref="ECExpressionError">
     /// Occurs when the expression part of the rule has a syntax error.
     /// </exception>
     /// <seealso cref="NumOfPlurals"/>
     /// <seealso cref="TCExpression"/>
     {$Endregion}
     Property Rule : String Read GetRule Write SetRule;
     {$Region 'xmldoc'}
     /// <summary>
     /// Gets the number of plural forms for the current target language.
     /// </summary>
     /// <seealso cref="Rule"/>
     {$Endregion}
     Property NumOfPlurals : Integer Read fNumOfPlurals;
     {$Region 'xmldoc'}
     /// <summary>
     /// Gets the <see cref="TCExpression"/> object that evaluates the plural rules
     /// for the current target language.
     /// </summary>
     /// <seealso cref="Rule"/>
     /// <seealso cref="TCExpression"/>
     {$Endregion}
     Property Formula : TCExpression Read fFormula;
   End;

 Implementation

  Uses
   i18nCore, Types;

  Resourcestring
   SInvalidPluralRule = 'Invalid plural rule'#13#10'%s';
   SInvalidPluralNum = 'The number of plurals (%d) must be an integer value greater that or equal to one';
   SInvalidPluralVar = 'The only allowed variable in a plural formula is ''n''';

  Type
   TLocalePluralRuleTableEntry = Record
    Locale     : String;
    PluralRule : String;
   End;

  Const
   // Sorted list of Locale/Language -> Prural Rule
   LocalePluralRuleTable : Array[1..125] Of TLocalePluralRuleTableEntry = (
   (Locale : 'ach'; PluralRule : 'nplurals=2; plural=n>1;'),
   (Locale : 'af'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'ak'; PluralRule : 'nplurals=2; plural=n>1;'),
   (Locale : 'am'; PluralRule : 'nplurals=2; plural=n>1;'),
   (Locale : 'an'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'ar'; PluralRule : 'nplurals=6; plural=n==0 ? 0 : n==1 ? 1 : n==2 ? 2 : n%100>=3 && n%100<=10 ? 3 : n%100>=11 ? 4 : 5;'),
   (Locale : 'arn'; PluralRule : 'nplurals=2; plural=n>1;'),
   (Locale : 'ast'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'ay'; PluralRule : 'nplurals=1; plural=0;'),
   (Locale : 'az'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'be'; PluralRule : 'nplurals=3; plural=n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2;'),
   (Locale : 'bg'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'bn'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'bo'; PluralRule : 'nplurals=1; plural=0;'),
   (Locale : 'br'; PluralRule : 'nplurals=2; plural=n>1;'),
   (Locale : 'bs'; PluralRule : 'nplurals=3; plural=n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2;'),
   (Locale : 'ca'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'cgg'; PluralRule : 'nplurals=1; plural=0;'),
   (Locale : 'cs'; PluralRule : 'nplurals=3; plural=n==1 ? 0 : n>=2 && n<=4 ? 1 : 2;'),
   (Locale : 'csb'; PluralRule : 'nplurals=3; plural=n==1 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2;'),
   (Locale : 'cy'; PluralRule : 'nplurals=4; plural=n==1 ? 0 : n==2 ? 1 : n!=8 && n!=11 ? 2 : 3;'),
   (Locale : 'da'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'de'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'dz'; PluralRule : 'nplurals=1; plural=0;'),
   (Locale : 'el'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'en'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'eo'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'es'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'et'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'eu'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'fa'; PluralRule : 'nplurals=1; plural=0;'),
   (Locale : 'fi'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'fil'; PluralRule : 'nplurals=2; plural=n>1;'),
   (Locale : 'fo'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'fr'; PluralRule : 'nplurals=2; plural=n>1;'),
   (Locale : 'fur'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'fy'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'ga'; PluralRule : 'nplurals=5; plural=n==1 ? 0 : n==2 ? 1 : n<7 ? 2 : n<11 ? 3 : 4;'),
   (Locale : 'gd'; PluralRule : 'nplurals=4; plural=n==1 || n==11 ? 0 : n==2 || n==12 ? 1 : n>2 && n<20 ? 2 : 3;'),
   (Locale : 'gl'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'gu'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'gun'; PluralRule : 'nplurals=2; plural=n>1;'),
   (Locale : 'ha'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'he'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'hi'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'hy'; PluralRule : 'nplurals=1; plural=0;'),
   (Locale : 'hr'; PluralRule : 'nplurals=3; plural=n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2;'),
   (Locale : 'hu'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'ia'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'id'; PluralRule : 'nplurals=1; plural=0;'),
   (Locale : 'is'; PluralRule : 'nplurals=2; plural=n%10!=1 || n%100==11;'),
   (Locale : 'it'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'ja'; PluralRule : 'nplurals=1; plural=0;'),
   (Locale : 'jv'; PluralRule : 'nplurals=2; plural=n!=0;'),
   (Locale : 'ka'; PluralRule : 'nplurals=1; plural=0;'),
   (Locale : 'kk'; PluralRule : 'nplurals=1; plural=0;'),
   (Locale : 'km'; PluralRule : 'nplurals=1; plural=0;'),
   (Locale : 'kn'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'ko'; PluralRule : 'nplurals=1; plural=0;'),
   (Locale : 'ku'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'kw'; PluralRule : 'nplurals=4; plural=n==1 ? 0 : n==2 ? 1 : n==3 ? 2 : 3;'),
   (Locale : 'ky'; PluralRule : 'nplurals=1; plural=0;'),
   (Locale : 'lb'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'ln'; PluralRule : 'nplurals=2; plural=n>1;'),
   (Locale : 'lo'; PluralRule : 'nplurals=1; plural=0;'),
   (Locale : 'lt'; PluralRule : 'nplurals=3; plural=n%10==1 && n%100!=11 ? 0 : n%10>=2 && (n%100<10 || n%100>=20) ? 1 : 2;'),
   (Locale : 'lv'; PluralRule : 'nplurals=3; plural=n%10==1 && n%100!=11 ? 0 : n!=0 ? 1 : 2;'),
   (Locale : 'mai'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'mfe'; PluralRule : 'nplurals=2; plural=n>1;'),
   (Locale : 'mg'; PluralRule : 'nplurals=2; plural=n>1;'),
   (Locale : 'mi'; PluralRule : 'nplurals=2; plural=n>1;'),
   (Locale : 'mk'; PluralRule : 'nplurals=2; plural=n==1 || n%10==1 ? 0 : 1;'),
   (Locale : 'ml'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'mn'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'mr'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'ms'; PluralRule : 'nplurals=1; plural=0;'),
   (Locale : 'mt'; PluralRule : 'nplurals=4; plural=n==1 ? 0 : n==0 || (n%100>1 && n%100<11) ? 1 : n%100>10 && n%100<20 ? 2 : 3;'),
   (Locale : 'nah'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'nap'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'nb'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'ne'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'nl'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'se'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'nn'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'no'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'nso'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'oc'; PluralRule : 'nplurals=2; plural=n>1;'),
   (Locale : 'or'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'ps'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'pa'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'pap'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'pl'; PluralRule : 'nplurals=3; plural=n==1 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2;'),
   (Locale : 'pms'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'pt'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'pt-BR'; PluralRule : 'nplurals=2; plural=n>1;'),
   (Locale : 'rm'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'ro'; PluralRule : 'nplurals=3; plural=n==1 ? 0 : n==0 || (n%100 > 0 && n%100 < 20) ? 1 : 2;'),
   (Locale : 'ru'; PluralRule : 'nplurals=3; plural=n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2;'),
   (Locale : 'sco'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'si'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'sk'; PluralRule : 'nplurals=3; plural=n==1 ? 0 : n>=2 && n<=4 ? 1 : 2;'),
   (Locale : 'sl'; PluralRule : 'nplurals=4; plural=n%100==1 ? 1 : n%100==2 ? 2 : n%100==3 || n%100==4 ? 3 : 0;'),
   (Locale : 'so'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'son'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'sq'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'sr'; PluralRule : 'nplurals=3; plural=n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2;'),
   (Locale : 'su'; PluralRule : 'nplurals=1; plural=0;'),
   (Locale : 'sw'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'sv'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'ta'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'te'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'tg'; PluralRule : 'nplurals=1; plural=0;'),
   (Locale : 'ti'; PluralRule : 'nplurals=2; plural=n>1;'),
   (Locale : 'th'; PluralRule : 'nplurals=1; plural=0;'),
   (Locale : 'tk'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'tr'; PluralRule : 'nplurals=2; plural=n>1;'),
   (Locale : 'tt'; PluralRule : 'nplurals=1; plural=0;'),
   (Locale : 'ug'; PluralRule : 'nplurals=1; plural=0;'),
   (Locale : 'uk'; PluralRule : 'nplurals=3; plural=n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2;'),
   (Locale : 'ur'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'uz'; PluralRule : 'nplurals=1; plural=0;'),
   (Locale : 'vi'; PluralRule : 'nplurals=1; plural=0;'),
   (Locale : 'wa'; PluralRule : 'nplurals=2; plural=n>1;'),
   (Locale : 'yo'; PluralRule : 'nplurals=2; plural=n!=1;'),
   (Locale : 'zh'; PluralRule : 'nplurals=1; plural=0;'));

 { TPluralForms }

  Constructor TPluralForms.Create(Const ARule : String);
   Begin
    Cache := TKeyLookup<Integer, Integer>.Create(32);
    SetRule(ARule);
   End;

  Destructor TPluralForms.Destroy;
   Begin
    Cache.Free;
    If Assigned(fFormula) Then
     fFormula.Free;
    Inherited Destroy;
   End;

  Function TPluralForms.GetRule : String;
   Begin
    Result := Format('nplurals=%d; plural=%s;', [NumOfPlurals, Formula.Source]);
   End;

  Procedure TPluralForms.SetRule(Const Value : String);
   Var
    LNumOfPlurals : Integer;
    LFormula      : String;
   Begin
    If Not ParseRule(Value, LNumOfPlurals, LFormula) Then
     Raise EPluralFormsError.CreateResFmt(@SInvalidPluralRule, [Value]);
    Apply(LNumOfPlurals, LFormula);
   End;

   Class Function TPluralForms.RuleOf(Const Locale : String; Const DefaultRule : String) : String;

  Var
   l : Integer;
   h : Integer;
   m : Integer;
   c : Integer;

 Begin
  Result := DefaultRule;
  l      := Low(LocalePluralRuleTable);
  h      := High(LocalePluralRuleTable);
  Repeat
   m := (l + h) Shr 1;
   c := CompareText(LocalePluralRuleTable[m].Locale, Locale);
   If c < 0 Then
    l := m + 1
   Else If c > 0 Then
    h := m - 1
   Else
    Begin
     Result := LocalePluralRuleTable[m].PluralRule;
     Exit;
    End;
  Until l > h;
  If SameLanguage(LocalePluralRuleTable[m].Locale, Locale) Then
   Result := LocalePluralRuleTable[m].PluralRule
  Else If m > Low(LocalePluralRuleTable) Then
   Begin
    Dec(m);
    If SameLanguage(LocalePluralRuleTable[m].Locale, Locale) Then
     Result := LocalePluralRuleTable[m].PluralRule;
   End

 End;

   Class Function TPluralForms.ExtractNumOfPlurals(Const ARule : String) : Integer;

  Var
   NotUsed : String;

 Begin
  If Not ParseRule(ARule, Result, NotUsed) Then
   Raise EPluralFormsError.CreateResFmt(@SInvalidPluralRule, [ARule]);

 End;

   Class Function TPluralForms.ParseRule(Const ARule : String; Out ANumOfPlurals : Integer; Out AFormula : String) : Boolean;

  Const
   Pattern = 'nplurals=#; plural=*;';

  Var
   p : PChar;
   s : PChar;
   e : PChar;

 Begin
  Result        := False;
  ANumOfPlurals := 0;
  AFormula      := '';
  p             := PChar(Pattern);
  s             := PChar(ARule);
  While CharInSet(s^, [' ', ^I]) Do
   Inc(s);
  While s^ = p^Do
   Begin
    Inc(s);
    Inc(p);
   End;
  While CharInSet(s^, [' ', ^I]) Do
   Inc(s);
  If (s^ = '=') And (p^ = '=') Then
   Begin
    Inc(s);
    While CharInSet(s^, [' ', ^I]) Do
     Inc(s);
    Inc(p);
   End;
  If p^ <> '#' Then
   Exit;
  Inc(p);
  If Not CharInSet(s^, ['0'..'9']) Then
   Exit;
  Repeat
   ANumOfPlurals := ANumOfPlurals * 10 + Ord(s^) - Ord('0');
   Inc(s);
  Until Not CharInSet(s^, ['0'..'9']);
  While CharInSet(s^, [' ', ^I]) Do
   Inc(s);
  If (s^ = ';') And (p^ = ';') Then
   Begin
    Inc(s);
    While CharInSet(s^, [' ', ^I]) Do
     Inc(s);
    Inc(p, 2);
   End;
  While s^ = p^Do
   Begin
    Inc(s);
    Inc(p);
   End;
  While CharInSet(s^, [' ', ^I]) Do
   Inc(s);
  If (s^ = '=') And (p^ = '=') Then
   Begin
    Inc(s);
    While CharInSet(s^, [' ', ^I]) Do
     Inc(s);
    Inc(p);
   End;
  If p^ <> '*' Then
   Exit;
  e := StrScan(s, ';');
  If e <> Nil Then
   Begin
    Repeat
     Dec(e);
    Until(s < e) Or Not CharInSet(e^, [' ', ^I]);
    SetString(AFormula, s, e - s + 1)
   End
  Else
   AFormula := Trim(s);
  Result    := (AFormula <> '');

 End;

  Procedure TPluralForms.Apply(ANumOfPlurals : Integer; Const AFormula : String);
   Var
    NewFormula : TCExpression;
   Begin
    If (NumOfPlurals = ANumOfPlurals) And Assigned(Formula) And (Formula.Source = AFormula) Then
     Exit;
    If ANumOfPlurals < 1 Then
     Raise EPluralFormsError.CreateResFmt(@SInvalidPluralNum, [ANumOfPlurals]);
    NewFormula := TCExpression.Create(AFormula);
    If (NewFormula.VarCount > 1) Or ((NewFormula.VarCount = 1) And (NewFormula.Vars['n'].RefCount = 0)) Then
     Begin
      NewFormula.Free;
      Raise EPluralFormsError.CreateRes(@SInvalidPluralVar);
     End;
    If Assigned(fFormula) Then
     fFormula.Free;
    fFormula      := NewFormula;
    fNumOfPlurals := ANumOfPlurals;
    Cache.Clear;
   End;

  Function TPluralForms.IndexOf(n : Integer) : Integer;
   Begin
    If n < 0 Then
     n := -n;
    If Not Cache.Retrieve(n, Result) Then
     Begin
      Formula.Vars['n'].Value := n;
      Result                  := Formula.Evaluate;
      Cache.Add(n, Result);
     End;
   End;

End.
