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
/// This unit implements a class to evaluate expressions in C language syntax.
/// </summary>
Unit i18nCExpr;

{$I DELPHIAREA.INC}

Interface

 Uses
  SysUtils, Classes, Types;

 Type

  {$Region 'xmldoc'}
  /// <summary>
  /// ECExpressionError is the exception class for problems that occur while parsing
  /// an expression in C language syntax.
  /// </summary>
  /// <remarks>
  /// ECExpressionError exception occurs when an expression in C language syntax has
  /// a syntax error.
  /// </remarks>
  /// <seealso cref="TCExpression"/>
  {$Endregion}
  ECExpressionError = Class(Exception)
   Private
    fExpression : String;
    fOffset     : Integer;
    fToken      : String;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Sets the additional information about the error.
    /// </summary>
    /// <param name="AExpression">
    /// The expression that caused the exception to occur.
    /// </param>
    /// <param name="AOffset">
    /// The offset from the start of the expression where the parser encountered
    /// the problem.
    /// </param>
    /// <param name="AToken">
    /// The last token that the parser was processing when the problem occurred.
    /// </param>
    {$Endregion}
    Procedure SetErrorDetails(Const AExpression : String; AOffset : Integer; Const AToken : String);
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the expression that caused the exception to occur.
    /// </summary>
    {$Endregion}
    Property Expression : String Read fExpression;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the offset from the start of the expression where the parser encountered
    /// the problem.
    /// </summary>
    {$Endregion}
    Property Offset : Integer Read fOffset;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the last token that the parser was processing when the problem occurred.
    /// </summary>
    {$Endregion}
    Property Token : String Read fToken;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TCExprVar represents an integer variable in an expression.
/// </summary>
/// <seealso cref="TCExpression"/>
{$Endregion}

  TCExprVar = Class(TObject)
   Private
    fName     : String;
    fValue    : Integer;
    fRefCount : Integer;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Increments the reference count of the variable.
    /// </summary>
    /// <returns>
    /// The object itself.
    /// </returns>
    /// <seealso cref="RefCount"/>
    {$Endregion}
    Function AddRef : TCExprVar; Inline;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the class for a specified variable name.
    /// </summary>
    /// <param name="AName">
    /// The name of the variable.
    /// </param>
    {$Endregion}
    Constructor Create(Const AName : String);
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the name of the variable.
    /// </summary>
    {$Endregion}
    Property Name : String Read fName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the number of times that the variable is referenced in the expression.
    /// </summary>
    {$Endregion}
    Property RefCount : Integer Read fRefCount;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the value of the variable.
    /// </summary>
    {$Endregion}
    Property Value : Integer Read fValue Write fValue;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TCExprNode is the base class for sub-expressions of an expression.
/// </summary>
{$Endregion}

    TCExprNode = Class Abstract(TObject)
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Evaluates the value of the sub-expression.
    /// </summary>
    /// <returns>
    /// The value of the sub-expression after evaluation.
    /// </returns>
    /// <seealso cref="Value"/>
    {$Endregion}
    Function GetValue : Integer; Virtual; Abstract;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the sub-expression as a string.
    /// </summary>
    /// <returns>
    /// The sub-expression as string.
    /// </returns>
    /// <seealso cref="AsString"/>
    {$Endregion}
    Function GetAsString : String; Virtual; Abstract;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether the value of sub-expression depends on the value of one
    /// or more variables.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> if the value of sub-expression depends on
    /// one or more variables. Otherwise, returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function IsVariable : Boolean; Virtual; Abstract;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the sub-expression as a string.
    /// </summary>
    {$Endregion}
    Property AsString : String Read GetAsString;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the value of the sub-expression after evaluation.
    /// </summary>
    {$Endregion}
    Property Value : Integer Read GetValue;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TCExprVarNode represents a reference to an integer variable in an expression.
/// </summary>
{$Endregion}

  TCExprVarNode = Class(TCExprNode)
   Private
    fVariable : TCExprVar;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Evaluates the value of the sub-expression.
    /// </summary>
    /// <returns>
    /// The value of the variable.
    /// </returns>
    /// <seealso cref="Value"/>
    {$Endregion}
    Function GetValue : Integer; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the sub-expression as a string.
    /// </summary>
    /// <returns>
    /// The name of the variable.
    /// </returns>
    /// <seealso cref="AsString"/>
    {$Endregion}
    Function GetAsString : String; Override;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the class for a specified variable.
    /// </summary>
    /// <param name="AVariable">
    /// The variable that this instance references.
    /// </param>
    {$Endregion}
    Constructor Create(Const AVariable : TCExprVar);
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether the value of sub-expression depends on the value of one
    /// or more variables.
    /// </summary>
    /// <returns>
    /// Returns always <see langword="true"/>.
    /// </returns>
    {$Endregion}
    Function IsVariable : Boolean; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the variable to which this sub-expression refers.
    /// </summary>
    {$Endregion}
    Property Variable : TCExprVar Read fVariable;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TCExprConstNode represents an integer constant in an expression.
/// </summary>
{$Endregion}

  TCExprConstNode = Class(TCExprNode)
   Private
    fValue : Integer;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Evaluates the value of the sub-expression.
    /// </summary>
    /// <returns>
    /// The value of the constant.
    /// </returns>
    /// <seealso cref="Value"/>
    {$Endregion}
    Function GetValue : Integer; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the sub-expression as a string.
    /// </summary>
    /// <returns>
    /// The value of constant as a string.
    /// </returns>
    /// <seealso cref="AsString"/>
    {$Endregion}
    Function GetAsString : String; Override;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the class for a specified integer value.
    /// </summary>
    /// <param name="AValue">
    /// The value of the constant that this instance represents.
    /// </param>
    {$Endregion}
    Constructor Create(AValue : Integer);
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether the value of sub-expression depends on the value of one
    /// or more variables.
    /// </summary>
    /// <returns>
    /// Returns always <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function IsVariable : Boolean; Override;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This enumeration type identifies the unary operators in a C language expression.
/// </summary>
{$Endregion}

  TCUnaryOp = (
  {$Region 'xmldoc'}
  /// unary plus (+)
  {$Endregion}
  opNone,
  {$Region 'xmldoc'}
  /// unary minus (-)
  {$Endregion}
  opNegate,
  {$Region 'xmldoc'}
  /// logical not (!)
  {$Endregion}
  opLogNot,
  {$Region 'xmldoc'}
  /// bitwise not (~)
  {$Endregion}
  opBitNot
  );

{$Region 'xmldoc'}
/// <summary>
/// TCExprUnaryNode represents a unary operation in an expression.
/// </summary>
{$Endregion}

  TCExprUnaryNode = Class(TCExprNode)
   Private
    fOp      : TCUnaryOp;
    fOperand : TCExprNode;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Evaluates the value of the sub-expression.
    /// </summary>
    /// <returns>
    /// The value of the sub-expression after evaluation.
    /// </returns>
    /// <seealso cref="Value"/>
    {$Endregion}
    Function GetValue : Integer; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the sub-expression as a string.
    /// </summary>
    /// <returns>
    /// The sub-expression as string.
    /// </returns>
    /// <seealso cref="AsString"/>
    {$Endregion}
    Function GetAsString : String; Override;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the class.
    /// </summary>
    /// <param name="AOp">
    /// The unary operator.
    /// </param>
    /// <param name="AOperand">
    /// The operand of the unary operation.
    /// </param>
    {$Endregion}
    Constructor Create(AOp : TCUnaryOp; AOperand : TCExprNode);
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether the value of sub-expression depends on the value of one
    /// or more variables.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> if the value of sub-expression depends on
    /// one or more variables. Otherwise, returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function IsVariable : Boolean; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Destroys the instance and releases its allocated memory.
    /// </summary>
    {$Endregion}
    Destructor Destroy; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the operator of the unary operation.
    /// </summary>
    {$Endregion}
    Property Op : TCUnaryOp Read fOp;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the operand of the unary operation.
    /// </summary>
    {$Endregion}
    Property Operand : TCExprNode Read fOperand;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This enumeration type identifies the binary operators in a C language expression.
/// </summary>
{$Endregion}

  TCBinaryOp = (
  {$Region 'xmldoc'}
  /// addition (+)
  {$Endregion}
  opAdd,
  {$Region 'xmldoc'}
  /// subtraction (-)
  {$Endregion}
  opSubtract,
  {$Region 'xmldoc'}
  /// multiplication (*)
  {$Endregion}
  opMultiply,
  {$Region 'xmldoc'}
  /// integer division (/)
  {$Endregion}
  opDivide,
  {$Region 'xmldoc'}
  /// remainder of integer division (%)
  {$Endregion}
  opModulus,
  {$Region 'xmldoc'}
  /// bitwise and (&amp;)
  {$Endregion}
  opBitAnd,
  {$Region 'xmldoc'}
  /// bitwise or (|)
  {$Endregion}
  opBitOr,
  {$Region 'xmldoc'}
  /// bitwise xor (^)
  {$Endregion}
  opBitXor,
  {$Region 'xmldoc'}
  /// shift left (&lt;&lt;)
  {$Endregion}
  opShiftLeft,
  {$Region 'xmldoc'}
  /// shift right (&gt;&gt;)
  {$Endregion}
  opShiftRight,
  {$Region 'xmldoc'}
  /// equality (==)
  {$Endregion}
  opEqual,
  {$Region 'xmldoc'}
  /// not equal (!=)
  {$Endregion}
  opNotEqual,
  {$Region 'xmldoc'}
  /// greater than (&gt;)
  {$Endregion}
  opGreaterThan,
  {$Region 'xmldoc'}
  /// greater than or equal (&gt;=)
  {$Endregion}
  opGreaterThanOrEqual,
  {$Region 'xmldoc'}
  /// less than (&lt;)
  {$Endregion}
  opLessThan,
  {$Region 'xmldoc'}
  /// less than or equal (&lt;=)
  {$Endregion}
  opLessThanOrEqual,
  {$Region 'xmldoc'}
  /// logical and (&amp;&amp;)
  {$Endregion}
  opLogAnd,
  {$Region 'xmldoc'}
  /// logical or (||)
  {$Endregion}
  opLogOr
  );

{$Region 'xmldoc'}
/// <summary>
/// TCExprBinaryNode represents a binary operation in an expression.
/// </summary>
{$Endregion}

  TCExprBinaryNode = Class(TCExprNode)
   Private
    fOp           : TCBinaryOp;
    fOperandLeft  : TCExprNode;
    fOperandRight : TCExprNode;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Evaluates the value of the sub-expression.
    /// </summary>
    /// <returns>
    /// The value of the sub-expression after evaluation.
    /// </returns>
    /// <seealso cref="Value"/>
    {$Endregion}
    Function GetValue : Integer; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the sub-expression as a string.
    /// </summary>
    /// <returns>
    /// The sub-expression as string.
    /// </returns>
    /// <seealso cref="AsString"/>
    {$Endregion}
    Function GetAsString : String; Override;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the class.
    /// </summary>
    /// <param name="AOp">
    /// The binary operator.
    /// </param>
    /// <param name="AOperandLeft">
    /// The left operand of the binary operation.
    /// </param>
    /// <param name="AOperandRight">
    /// The right operand of the binary operation.
    /// </param>
    {$Endregion}
    Constructor Create(AOp : TCBinaryOp; AOperandLeft, AOperandRight : TCExprNode);
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether the value of sub-expression depends on the value of one
    /// or more variables.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> if the value of sub-expression depends on
    /// one or more variables. Otherwise, returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function IsVariable : Boolean; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Destroys the instance and releases its allocated memory.
    /// </summary>
    {$Endregion}
    Destructor Destroy; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the operator of the binary operation.
    /// </summary>
    {$Endregion}
    Property Op : TCBinaryOp Read fOp;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the left operand of the binary operation.
    /// </summary>
    {$Endregion}
    Property OperandLeft : TCExprNode Read fOperandLeft;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the right operand of the binary operation.
    /// </summary>
    {$Endregion}
    Property OperandRight : TCExprNode Read fOperandRight;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TCExprTernaryNode represents a ternary conditional operation in an expression.
/// </summary>
{$Endregion}

  TCExprTernaryNode = Class(TCExprNode)
   Private
    fCondition    : TCExprNode;
    fOperandTrue  : TCExprNode;
    fOperandFalse : TCExprNode;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Evaluates the value of the sub-expression.
    /// </summary>
    /// <returns>
    /// The value of the sub-expression after evaluation.
    /// </returns>
    /// <seealso cref="Value"/>
    {$Endregion}
    Function GetValue : Integer; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the sub-expression as a string.
    /// </summary>
    /// <returns>
    /// The sub-expression as string.
    /// </returns>
    /// <seealso cref="AsString"/>
    {$Endregion}
    Function GetAsString : String; Override;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the class.
    /// </summary>
    /// <param name="ACondition">
    /// The condition operand.
    /// </param>
    /// <param name="AOperandTrue">
    /// The operand that evaluates when the condition evaluates to true.
    /// </param>
    /// <param name="AOperandFalse">
    /// The operand that evaluates when the condition evaluates to false.
    /// </param>
    {$Endregion}
    Constructor Create(ACondition, AOperandTrue, AOperandFalse : TCExprNode);
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether the value of sub-expression depends on the value of one
    /// or more variables.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> if the value of sub-expression depends on
    /// one or more variables. Otherwise, returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function IsVariable : Boolean; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Destroys the instance and releases its allocated memory.
    /// </summary>
    {$Endregion}
    Destructor Destroy; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the condition operand of the ternary operation.
    /// </summary>
    {$Endregion}
    Property Condition : TCExprNode Read fCondition;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the operand for the true case of the ternary operation.
    /// </summary>
    {$Endregion}
    Property OperandTrue : TCExprNode Read fOperandTrue;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the operand for the false case of the ternary operation.
    /// </summary>
    {$Endregion}
    Property OperandFalse : TCExprNode Read fOperandFalse;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TCExpression is parser and evaluator for expressions in C language syntax.
/// </summary>
/// <remarks>
/// <para>
/// TCExpression parses and evaluates an expression (specified as a string) which is using
/// the C language syntax. Exceptions are that numbers must be decimal and no assignment,
/// increment/decrement, or comma operators are allowed. The expression can use user-defined
/// variables.
/// </para>
/// <para>
/// TCExpression supports comparison and logical operations as well as arithmetic
/// and bitwise ones. The comparison and logical operations always evaluate to
/// either zero (false) or one (true).
/// </para>
/// <para>
/// TCExpression parses the expression once to build the parse tree. Then, each time
/// you call the <see cref="Evaluate"/> method, it uses the parse tree and the value
/// of the variables listed by the <see cref="Vars"/> property to calculate the result
/// of the expression. For this reason, TCExpression is very useful and suitable when
/// you have one expression that will be evaluated many times with different variable
/// values.
/// </para>
/// <para>
/// The following table lists C operators that are supported by TCExpression. The
/// operators are listed in order of precedence (highest to lowest). Their associativity
/// indicates in what order operators of equal precedence in an expression are applied.
/// </para>
/// <list type="table">
///   <listheader>
///     <term>Operator</term>
///     <description>Description</description>
///     <description>Associativity</description>
///   </listheader>
///   <item>
///     <term>+ - ! ~</term>
///     <description>Unary plus • Unary minus • Logical negation •
///     Bitwise complement</description>
///     <description>right-to-left</description>
///   </item>
///   <item>
///     <term>* / %</term>
///     <description>Multiplication • Division • Modulus</description>
///     <description>left-to-right</description>
///   </item>
///   <item>
///     <term>+ -</term>
///     <description>Addition • Subtraction</description>
///     <description>left-to-right</description>
///   </item>
///   <item>
///     <term>&lt;&lt; &gt;&gt;</term>
///     <description>Bitwise shift left • Bitwise shift right</description>
///     <description>left-to-right</description>
///   </item>
///   <item>
///     <term>&lt; &lt;= &gt; &gt;=</term>
///     <description>Relational less than • less than or equal to •
///     greater than • greater than or equal to</description>
///     <description>left-to-right</description>
///   </item>
///   <item>
///     <term>== !=</term>
///     <description>Relational is equal to • is not equal to</description>
///     <description>left-to-right</description>
///   </item>
///   <item>
///     <term>&amp;</term>
///     <description>Bitwise AND</description>
///     <description>left-to-right</description>
///   </item>
///   <item>
///     <term>^</term>
///     <description>Bitwise exclusive OR</description>
///     <description>left-to-right</description>
///   </item>
///   <item>
///     <term>|</term>
///     <description>Bitwise inclusive OR</description>
///     <description>left-to-right</description>
///   </item>
///   <item>
///     <term>&amp;&amp;</term>
///     <description>Logical AND</description>
///     <description>left-to-right</description>
///   </item>
///   <item>
///     <term>||</term>
///     <description>Logical OR</description>
///     <description>left-to-right</description>
///   </item>
///   <item>
///     <term>?:</term>
///     <description>Ternary conditional</description>
///     <description>left-to-right</description>
///   </item>
/// </list>
/// <para>
/// Parentheses are also used to group sub-expressions to force a different
/// precedence; such parenthetical expressions can be nested and are evaluated
/// from inner to outer.
/// </para>
/// </remarks>
{$Endregion}

  TCExpression = Class(TObject)
   Private
    fSource : String;
    fVars   : TStringList;
    Expr    : TCExprNode;
    Function GetFormattedSource : String; Inline;
    Function GetVarCount : Integer; Inline;
    Function GetVarNames(Index : Integer) : String; Inline;
    Function GetVars(Const Name : String) : TCExprVar;
    Function Parse(Const Expression : String) : TCExprNode;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the expression evaluator for a specified expression in
    /// C language syntax.
    /// </summary>
    /// <param name="Expression">
    /// The expression to parse and evaluate.
    /// </param>
    /// <exception cref="ECExpressionError">
    /// Occurs when the expression has a syntax error.
    /// </exception>
    {$Endregion}
    Constructor Create(Const Expression : String);
    {$Region 'xmldoc'}
    /// <summary>
    /// Destroys the instance and releases its allocated memory.
    /// </summary>
    {$Endregion}
    Destructor Destroy; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Evaluates the expression for the variables specified by the <see cref="Vars"/>
    /// property.
    /// </summary>
    /// <returns>
    /// Returns the result of the expression.
    /// </returns>
    {$Endregion}
    Function Evaluate : Integer; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether the value of expression depends on the values of any variables.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> if the value of the expression depends on
    /// one or more variables. Otherwise, returns <see langword="false"/>.
    /// </returns>
    {$Endregion}
    Function IsVariable : Boolean; Inline;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the source expression.
    /// </summary>
    /// <seealso cref="FormattedSource"/>
    {$Endregion}
    Property Source : String Read fSource;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the source expression as formatted.
    /// </summary>
    /// <seealso cref="Source"/>
    {$Endregion}
    Property FormattedSource : String Read GetFormattedSource;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the number of variables in the expression.
    /// </summary>
    {$Endregion}
    Property VarCount : Integer Read GetVarCount;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the names of variables in the expression.
    /// </summary>
    {$Endregion}
    Property VarNames[Index : Integer] : String Read GetVarNames;
    {$Region 'xmldoc'}
    /// <summary>
    /// Lists the variables in the expression.
    /// </summary>
    /// <remarks>
    /// <para>
    /// Use the Vars property to get or set values of variables in the expression.
    /// </para>
    /// <para>
    /// TCExpression does not prevent you from setting values for variables that are not used by
    /// the expression. This helps you to manage the variables within your code independent
    /// of the expression being used. You can examine the value of <see cref="TCExprVar.RefCount"/>
    /// property to discover whether a variable is referenced in the expression or not.
    /// </para>
    /// </remarks>
    /// <seealso cref="TCExprVar"/>
    {$Endregion}
    Property Vars[Const Name : String] : TCExprVar Read GetVars;
  End;

Implementation

 Resourcestring
  SUnexpectedEndOfExpressionError = 'Unexpected end of expression';
  SUnexpectedSymbolError = 'Unexpected symbol ''%s''';
  SMissingExpectedSymbolError = 'Missing symbol ''%s''';

 Const
  UnaryOpSymbols : Array[TCUnaryOp] Of String = ('+', '-', '!', '~');
  BinaryOpSymbols : Array[TCBinaryOp] Of String = ('+', '-', '*', '/', '%',
  '&', '|', '^', '<<', '>>', '==', '!=', '>', '>=', '<', '<=', '&&', '||');

{ ECExpressionError }

 Procedure ECExpressionError.SetErrorDetails(Const AExpression : String; AOffset : Integer; Const AToken : String);
  Begin
   fExpression := AExpression;
   fOffset     := AOffset;
   fToken      := AToken;
  End;

{ TCExprVar }

 Constructor TCExprVar.Create(Const AName : String);
  Begin
   fName := AName;
  End;

 Function TCExprVar.AddRef : TCExprVar;
  Begin
   Inc(fRefCount);
   Result := Self;
  End;

{ TCExprVarNode }

 Constructor TCExprVarNode.Create(Const AVariable : TCExprVar);
  Begin
   fVariable := AVariable.AddRef;
  End;

 Function TCExprVarNode.GetAsString : String;
  Begin
   Result := Variable.Name;
  End;

 Function TCExprVarNode.GetValue : Integer;
  Begin
   Result := Variable.Value;
  End;

 Function TCExprVarNode.IsVariable : Boolean;
  Begin
   Result := True;
  End;

{ TCExprConstNode }

 Constructor TCExprConstNode.Create(AValue : Integer);
  Begin
   fValue := AValue;
  End;

 Function TCExprConstNode.GetAsString : String;
  Begin
   Result := IntToStr(Value)
  End;

 Function TCExprConstNode.GetValue : Integer;
  Begin
   Result := fValue;
  End;

 Function TCExprConstNode.IsVariable : Boolean;
  Begin
   Result := False;
  End;

{ TCExprUnaryNode }

 Constructor TCExprUnaryNode.Create(AOp : TCUnaryOp; AOperand : TCExprNode);
  Begin
   fOp      := AOp;
   fOperand := AOperand;
  End;

 Destructor TCExprUnaryNode.Destroy;
  Begin
   fOperand.Free;
   Inherited Destroy;
  End;

 Function TCExprUnaryNode.GetAsString : String;

   Function ToString(Operand : TCExprNode) : String;
    Begin
     Result := Operand.AsString;
     If (Operand Is TCExprUnaryNode) Or
     (Operand Is TCExprBinaryNode) Or
     (Operand Is TCExprTernaryNode)
     Then
      Result := '(' + Result + ')';
    End;

  Begin
   Result := UnaryOpSymbols[Op] + ToString(Operand);
  End;

 Function TCExprUnaryNode.GetValue : Integer;
  Begin
   Case Op Of
    opNegate : Result := -Operand.Value;
    opBitNot : Result := Not Operand.Value;
    opLogNot : Result := Ord(Operand.Value = 0);
   Else Result := Operand.Value
   End;
  End;

 Function TCExprUnaryNode.IsVariable : Boolean;
  Begin
   Result := Operand.IsVariable;
  End;

{ TCExprBinaryNode }

 Constructor TCExprBinaryNode.Create(AOp : TCBinaryOp; AOperandLeft, AOperandRight : TCExprNode);
  Begin
   fOp           := AOp;
   fOperandLeft  := AOperandLeft;
   fOperandRight := AOperandRight;
  End;

 Destructor TCExprBinaryNode.Destroy;
  Begin
   fOperandLeft.Free;
   fOperandRight.Free;
   Inherited Destroy;
  End;

 Function TCExprBinaryNode.GetAsString : String;

   Function ToString(Operand : TCExprNode) : String;
    Begin
     Result := Operand.AsString;
     If (Operand Is TCExprTernaryNode) Or ((Operand Is TCExprBinaryNode) And
     ((TCExprBinaryNode(Operand).Op <> Op) Or Not(Op In [opMultiply, opAdd, opSubtract, opBitAnd, opBitOr, opBitXor, opLogAnd, opLogOr])) And
     (Not(TCExprBinaryNode(Operand).Op In [opAdd, opSubtract]) Or Not(Op In [opAdd, opSubtract])))
     Then
      Result := '(' + Result + ')';
    End;

  Begin
   Result := ToString(OperandLeft) + ' ' + BinaryOpSymbols[Op] + ' ' + ToString(OperandRight);
  End;

 Function TCExprBinaryNode.GetValue : Integer;
  Begin
   Case Op Of
    opAdd :
     Result := OperandLeft.Value + OperandRight.Value;
    opSubtract :
     Result := OperandLeft.Value - OperandRight.Value;
    opMultiply :
     Result := OperandLeft.Value * OperandRight.Value;
    opDivide :
     Result := OperandLeft.Value Div OperandRight.Value;
    opModulus :
     Result := OperandLeft.Value Mod OperandRight.Value;
    opBitAnd :
     Result := OperandLeft.Value And OperandRight.Value;
    opBitOr :
     Result := OperandLeft.Value Or OperandRight.Value;
    opBitXor :
     Result := OperandLeft.Value Xor OperandRight.Value;
    opShiftLeft :
     Result := OperandLeft.Value Shl OperandRight.Value;
    opShiftRight :
     Result := OperandLeft.Value Shr OperandRight.Value;
    opEqual :
     Result := Ord(OperandLeft.Value = OperandRight.Value);
    opNotEqual :
     Result := Ord(OperandLeft.Value <> OperandRight.Value);
    opGreaterThan :
     Result := Ord(OperandLeft.Value > OperandRight.Value);
    opGreaterThanOrEqual :
     Result := Ord(OperandLeft.Value >= OperandRight.Value);
    opLessThan :
     Result := Ord(OperandLeft.Value < OperandRight.Value);
    opLessThanOrEqual :
     Result := Ord(OperandLeft.Value <= OperandRight.Value);
    opLogAnd :
     Begin
      Result := Ord(OperandLeft.Value <> 0);
      If Result <> 0 Then
       Result := Ord(OperandRight.Value <> 0);
     End;
    opLogOr :
     Begin
      Result := Ord(OperandLeft.Value <> 0);
      If Result = 0 Then
       Result := Ord(OperandRight.Value <> 0);
     End
   Else
     Result := 0; // To prevent compiler warning; code never reaches here.
   End;
  End;

 Function TCExprBinaryNode.IsVariable : Boolean;
  Begin
   Result := OperandLeft.IsVariable Or OperandRight.IsVariable;
  End;

{ TCExprTernaryNode }

 Constructor TCExprTernaryNode.Create(ACondition, AOperandTrue, AOperandFalse : TCExprNode);
  Begin
   fCondition    := ACondition;
   fOperandTrue  := AOperandTrue;
   fOperandFalse := AOperandFalse;
  End;

 Destructor TCExprTernaryNode.Destroy;
  Begin
   fCondition.Free;
   fOperandTrue.Free;
   fOperandFalse.Free;
   Inherited Destroy;
  End;

 Function TCExprTernaryNode.GetAsString : String;

   Function ToString(Operand : TCExprNode) : String;
    Begin
     Result := Operand.AsString;
     If (Operand Is TCExprBinaryNode) Or (Operand Is TCExprTernaryNode) Then
      Result := '(' + Result + ')';
    End;

  Begin
   Result := ToString(Condition) + ' ? ' + ToString(OperandTrue) + ' : ' + ToString(OperandFalse);
  End;

 Function TCExprTernaryNode.GetValue : Integer;
  Begin
   If Condition.Value <> 0 Then
    Result := OperandTrue.Value
   Else
    Result := OperandFalse.Value;
  End;

 Function TCExprTernaryNode.IsVariable : Boolean;
  Begin
   If Not Condition.IsVariable Then
    If Condition.Value <> 0 Then
     Result := OperandTrue.IsVariable
    Else
     Result := OperandFalse.IsVariable
   Else
    Result := True;
  End;

{ TCExpression }

 Constructor TCExpression.Create(Const Expression : String);
  Begin
   fSource             := Expression;
   fVars               := TStringList.Create;
   fVars.CaseSensitive := False;
   fVars.OwnsObjects   := True;
   fVars.Sorted        := True;
   fVars.Duplicates    := dupIgnore;
   Expr                := Parse(Expression);
  End;

 Destructor TCExpression.Destroy;
  Begin
   If Assigned(Expr) Then
    Expr.Free;
   fVars.Free;
   Inherited Destroy;
  End;

 Function TCExpression.GetFormattedSource : String;
  Begin
   Result := Expr.AsString;
  End;

 Function TCExpression.GetVarCount : Integer;
  Begin
   Result := fVars.Count;
  End;

 Function TCExpression.GetVarNames(Index : Integer) : String;
  Begin
   Result := fVars[Index];
  End;

 Function TCExpression.GetVars(Const Name : String) : TCExprVar;
  Var
   Index : Integer;
  Begin
   Index  := fVars.Add(Name);
   Result := TCExprVar(fVars.Objects[Index]);
   If Result = Nil Then
    Begin
     Result               := TCExprVar.Create(Name);
     fVars.Objects[Index] := Result;
    End;
  End;

 Function TCExpression.Evaluate : Integer;
  Begin
   Result := Expr.Value;
  End;

 Function TCExpression.IsVariable : Boolean;
  Begin
   Result := Expr.IsVariable;
  End;

 Function TCExpression.Parse(Const Expression : String) : TCExprNode;
  Type
   TCExprToken       = (ceNone, ceIdentifier, ceNumber, ceSymbol);
   TBinaryOperations = Set Of TCBinaryOp;
  Const
   BinaryOpPrecedence : Array[1..10] Of TBinaryOperations = (
   [opMultiply, opDivide, opModulus],
   [opAdd, opSubtract],
   [opShiftLeft, opShiftRight],
   [opGreaterThan, opGreaterThanOrEqual, opLessThan, opLessThanOrEqual],
   [opEqual, opNotEqual],
   [opBitAnd],
   [opBitXor],
   [opBitOr],
   [opLogAnd],
   [opLogOr]);
  Var
   s       : PChar;
   Token   : String;
   TokenID : TCExprToken;

   Procedure NextToken;
    Var
     p : PChar;
    Begin
     While CharInSet(s^, [' ', ^I, #10, #13])  Do
      Inc(s);
     p := s;
     Case s^Of
      #0 :
       Begin
        Token   := '';
        TokenID := ceNone;
       End;
      '0'..'9' :
       Begin
        Repeat
         Inc(s)
        Until Not CharInSet(s^, ['0'..'9']);
        SetString(Token, p, s - p);
        TokenID := ceNumber;
       End;
      '_', 'A'..'Z', 'a'..'z' :
       Begin
        Repeat
         Inc(s)
        Until Not CharInSet(s^, ['_', 'A'..'Z', 'a'..'z', '0'..'9']);
        SetString(Token, p, s - p);
        TokenID := ceIdentifier;
       End;
     Else
       Inc(s);
       Case p^Of
        '<' :
         If CharInSet(s^, ['<', '=']) Then
          Inc(s);
        '>' :
         If CharInSet(s^, ['>', '=']) Then
          Inc(s);
        '=' :
         If s^ = '=' Then
          Inc(s);
        '!' :
         If s^ = '=' Then
          Inc(s);
        '&' :
         If s^ = '&' Then
          Inc(s);
        '|' :
         If s^ = '|' Then
          Inc(s);
       End;
       SetString(Token, p, s - p);
       TokenID := ceSymbol;
     End;
    End;

   Function IsTokenUnaryOp(Out UnaryOp : TCUnaryOp) : Boolean;
    Var
     Op : TCUnaryOp;
    Begin
     If TokenID = ceSymbol Then
      For Op := Low(UnaryOpSymbols) To High(UnaryOpSymbols) Do
       If UnaryOpSymbols[Op] = Token Then
        Begin
         UnaryOp := Op;
         Result  := True;
         Exit;
        End;
     Result := False;
    End;

   Function IsTokenBinaryOp(Out BinaryOp : TCBinaryOp) : Boolean;
    Var
     Op : TCBinaryOp;
    Begin
     If TokenID = ceSymbol Then
      For Op := Low(BinaryOpSymbols) To High(BinaryOpSymbols) Do
       If BinaryOpSymbols[Op] = Token Then
        Begin
         BinaryOp := Op;
         Result   := True;
         Exit;
        End;
     Result := False;
    End;

   Function ParseExpression : TCExprNode; Forward;

   Function ParseFactor : TCExprNode;
    Var
     UnaryOp, Temp : TCUnaryOp;
     Value         : Integer;
    Begin
     If IsTokenUnaryOp(UnaryOp) Then
      NextToken
     Else
      UnaryOp := opNone;
     Case TokenID Of
      ceIdentifier :
       Begin
        Result := TCExprVarNode.Create(Vars[Token]);
        NextToken;
       End;
      ceNumber :
       Begin
        Result := TCExprConstNode.Create(StrToInt(Token));
        NextToken;
       End;
      ceSymbol :
       Begin
        If Token = '(' Then
         Begin
          NextToken;
          Result := ParseExpression;
          If Token <> ')' Then
           Begin
            Result.Free;
            Raise ECExpressionError.CreateResFmt(@SMissingExpectedSymbolError, [')']);
           End;
          NextToken;
         End
        Else If IsTokenUnaryOp(Temp) Then
         Result := ParseFactor
        Else
         Raise ECExpressionError.CreateResFmt(@SUnexpectedSymbolError, [Token]);
       End;
     Else
       Raise ECExpressionError.CreateRes(@SUnexpectedEndOfExpressionError);
     End;
     If UnaryOp <> opNone Then
      Begin
       Result := TCExprUnaryNode.Create(UnaryOp, Result);
       If Not Result.IsVariable Then
        Begin
         Try
          Value := Result.Value;
         Finally
          Result.Free;
         End;
         Result := TCExprConstNode.Create(Value);
        End;
      End;
    End;

   Function ParseTerm(Level : Integer = High(BinaryOpPrecedence)) : TCExprNode;
    Var
     NextOperand : TCExprNode;
     BinaryOp    : TCBinaryOp;
     Value       : Integer;
    Begin
     If Level = Low(BinaryOpPrecedence) Then
      Result := ParseFactor
     Else
      Result := ParseTerm(Level - 1);
     While IsTokenBinaryOp(BinaryOp) And (BinaryOp In BinaryOpPrecedence[Level]) Do
      Begin
       NextToken;
       Try
        If Level = Low(BinaryOpPrecedence) Then
         NextOperand := ParseFactor
        Else
         NextOperand := ParseTerm(Level - 1);
       Except
        Result.Free;
        Raise;
       End;
       Result := TCExprBinaryNode.Create(BinaryOp, Result, NextOperand);
       If Not Result.IsVariable Then
        Begin
         Try
          Value := Result.Value;
         Finally
          Result.Free;
         End;
         Result := TCExprConstNode.Create(Value);
        End;
      End;
    End;

   Function ParseExpression : TCExprNode;
    Var
     OperandTrue, OperandFalse : TCExprNode;
    Begin
     Result := ParseTerm;
     If Token = '?' Then
      Begin
       NextToken;
       Try
        OperandTrue := ParseExpression;
       Except
        ;
        Result.Free;
        Raise;
       End;
       If Token <> ':' Then
        Begin
         Result.Free;
         Raise ECExpressionError.CreateResFmt(@SMissingExpectedSymbolError, [':']);
        End;
       NextToken;
       Try
        OperandFalse := ParseExpression;
       Except
        Result.Free;
        OperandTrue.Free;
        Raise;
       End;
       If Result.IsVariable Then
        Result := TCExprTernaryNode.Create(Result, OperandTrue, OperandFalse)
       Else
        Begin
         If Result.Value <> 0 Then
          Begin
           Result.Free;
           Result := OperandTrue;
           OperandFalse.Free;
          End
         Else
          Begin
           Result.Free;
           Result := OperandFalse;
           OperandTrue.Free;
          End;
        End;
      End;
    End;
  Var
   Error : ECExpressionError;

  Begin
   s := PChar(Expression);
   NextToken;
   Try
    Result := ParseExpression;
    If TokenID <> ceNone Then
     Begin
      Result.Free;
      Raise ECExpressionError.CreateResFmt(@SUnexpectedSymbolError, [Token]);
     End;
   Except
    On E : ECExpressionError Do
     Begin
      E.SetErrorDetails(Expression, s - PChar(Expression), Token);
      Raise;
     End;
    On E : Exception Do
     Begin
      Error := ECExpressionError.Create(E.Message);
      Error.SetErrorDetails(Expression, s - PChar(Expression), Token);
      Raise Error;
     End;
   End;
  End;

End.
