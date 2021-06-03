# Languega Description
The developed language allows the programmer to evaluate both boolean and algebric expressions. The language is based on three data types, namely boolean, integer and double, that could be associated either to constant values or to variables.
To write a program, two control flow structures could be used, namely the *if-then-else* and the *while loop*. 
Associated to this two structures there are either single-line or multi-line blocks of code. Recalling the C language, single-line blocks could be associate to a flow structure as they are and multi-line blocks must be enclosed in curly brackets. 
The language allows multiple scope, so visibility of the variables depends on their declaration position. Each block of code associated to a control flow statement is considered as a sub-scope of the main one, and it is indipendent from the other. Consequently, variables decleared in one sub-scope are not accessible from the other sub-scopes, unless they are sub-scopes of the initial subscope.
The language offers the possibility of variable redeclaration, but this could happen only if the new variable instance is redecleared in a sub-scope where the previous declaration happened.

Starting from the language description, follows its **Formal Grammar**.

# Formal Grammar
The grammar is formally describe by the tuple G = <V,N,P,S>.

V = { BOOLEAN, INT, DOUBLE, IDENTIFIER, ASSIGN_OP, BIGGER_THAN, SMALLER_THAN, EQUAL_TO, NOT_EQUAL_TO, BIGGER_EQ_THAN, SMALLER_EQ_THAN, NOT, 
  BOOL_VAL, PLUS, MINUS, MOLT, DIV, INT_VAL, DOUBLE_VAL, O_PAR, C_PAR, IF, ELSE, WHILE, PRINT }
N = { enter_sub_scope, exit_sub_scope, decl, typename, assign, list_stmt, stmt, ctrl_stmt, cond_stmt, while_stmt, if_stmt, else_stmt,
  expr_stmt, expr, a_expr, b_expr}
P = { 
  list_stmt : | list_stmt stmt

  stmt  : ';' | PRINT expr ';' | ctrl_stmt | expr_stmt  ';'

  ctrl_stmt :  while_stmt | cond_stmt 

  while_stmt :  WHILE expr enter_sub_scope stmt exit_sub_scope |  WHILE expr '{' enter_sub_scope list_stmt exit_sub_scope '}'

  cond_stmt : if_stmt |  if_stmt else_stmt

  if_stmt : IF expr enter_sub_scope stmt  exit_sub_scope |  IF expr '{' enter_sub_scope list_stmt exit_sub_scope '}'

  else_stmt : ELSE enter_sub_scope stmt exit_sub_scope | ELSE '{' enter_sub_scope list_stmt exit_sub_scope '}'

  expr_stmt : expr | decl | assign 

  expr  : O_PAR expr C_PAR | a_expr | b_expr | IDENTIFIER

  a_expr : expr PLUS expr | expr MINUS expr | expr MOLT expr | expr DIV expr | MINUS expr | INT_VAL | FLOAT_VAL 

  b_expr : expr BIGGER_THAN expr | expr BIGGER_EQ_THAN expr | expr SMALLER_THAN expr | expr SMALLER_EQ_THAN expr | expr EQUAL_TO expr 
    | expr NOT_EQUAL_TO expr | NOT expr | BOOL_VAL

  decl : typename IDENTIFIER | typename IDENTIFIER ASSIGN_OP expr

  typename : BOOLEAN | INT | DOUBLE

  assign : IDENTIFIER ASSIGN_OP exprs

  enter_sub_scope : 

  exit_sub_scope :
}
S = {list_stmt}

# Formal Grammar Extention
The formal grammar G is not per se enough to recognize the initial described language, since G suffers form unambiguousity. To solve this problem, deambiguating rules (precedence and associativity rules) have been decleared in the Parser implementation, and the grammar with this new rules extended.

# Lexical Analyzer and Parser Interaction
To let the Lexical Analyzer and the Parser interact, the gloval variable YYLVAL has been redecleared as follows: 
```
struct parse_tree_node {
      int type;     
      double value;     
      char* lexeme;
}; 

union yylval {
       char* lexeme; 
       double value; 
       int type;
       struct parse_tree_node parse_tree_node_info;
       }
```
YYLVAL is composed of two parts: the first made of *lexeme*, *value* and *type*, and the second of *parse_tree_node_info*.
The first one is used from the Lexical Analyzer to share with the Parser additional informations about the transmitted tokens, and the second from the Parser only, to store results of the evaluated expressions.

# Parser implementation
The developed Parser checks both syntactic and semantic correctness of the input, and evaluates the well-formed expression as long as it encounters them.
Syntactic correctness is guaranteed by extending the above grammar with the mentioned precedence rules, where semantic correctness is ensured by additional *actions* associated to the production rules.

## Disambiguation Rules
In the grammar G two main abiguity issues must be resolved. The first issue regards the operators precedence, and the second the IF-ELSE statement.
To solve the first problem, highest priority has been given to arithmetic operators, middle priority the boolean operators and lowest priority to the assignment operator.
To solve the second issure, lower priority has been given tp the IF clause, so that the ELSE branch is always evaluated first, connecting it to the closest IF clause.
 
Follows the declearation of the rules:
```
%nonassoc ENTER_SUB_SCOPE EXIT_SUB_SCOPE

%nonassoc INT_VAL FLOAT_VAL BOOL_VAL IDENTIFIER BOOLEAN INT DOUBLE WHILE IF PRINT ';' '}' 

// operators precedence
%right ASSIGN_OP
%left BIGGER_THAN SMALLER_THAN EQUAL_TO NOT_EQUAL_TO BIGGER_EQ_THAN SMALLER_EQ_THAN
%left NOT
%left MINUS PLUS
%left MOLT DIV
%left C_PAR
%right UMINUS O_PAR

// if-then-else issue
%nonassoc IFX
%nonassoc ELSE

%nonassoc LIST_STMT 
```

## Sematic Correctness 
Semantic correctness cannot be directly ensured though the grammar definition. Therefore, semantic actions have been associated to each production rule and they aims to evaluate the result of the encountered expressions during the parsing too.

To better understand this actions, follows a description of the notion of expression.

## Expression
### Notion of Expression
An expression could be of different kinds: 
- a constant value: ``` 10; true; ... ```
- the result unary expression: ``` Op Operand ```
- the result binary expression: ``` Operand Op Operand ```
- a variable evaluation: ``` a; ```, where ``` a ``` is a variable previously defined

### Expression Evaluation
Expressions are evaluated following a bottom-up procedure, starting from the single operands' value, up to the final result. 

Let's see how the different kind of expressions are evaluated.

#### Constants
The evaluation in this case is straightforward and very intuitive. The Lexical Analyzer identifies the different tokens representing constant values, that are: *true*, *false*, *number* with and without the *dot "."*. It returs them to the Parser and places the relevant information in the YYLVAL variable. The parser assign the constants their correspondent type and value attributes based on the information store in the global variable, and populates the ``` parse_tree_node_info ``` variable.

Constants are evalueated differently, whether they are boolean or a number.
For the boolean constants, their evaluation is trivial, since the TRUE token identifies the *true* value and the FALSE token *false*. For the numerical constants, their actual value is extracted invoking the ``` atof() ``` C function.

#### Unary Expression Evaluation
This expression is composed by two expressions, one nested into the other. Therefore, to compute the final result, the parent attributes could be evaluated only after having successfully evaluated the inner expr and ensured type compatibility with the outer operator. If the inner expression's type is compatible with the outer operator, attributes of the whole expression are evaluate. If it is not compatible, a semantic error is generated.

#### Binary Expression Evaluation
This expression is composed by three expressions: the parent (most general), and the two sub-expression representing the operands. As for the previous unary case, the whole expression is evaluated only if the types of the inner-expressions are compatible with the operator in between them.

#### Variable Evaluation
To evaluate this kind of expression, a *table lookup* operation needs to be performed. 
When the Lexical Anlyzer recognizes a variable, it communicates the lexeme to the Parser, that uses the variable name to lookup the table. 
The lookup could either go successfully, if the variable was declearead, or fails. In the first case, attibutes of the expression associated with the variable are returned, and in the second case, a PARSING ERROR is returned.

### Operations Supported
The Parser implementation deals with the following operations:
- Arithmetic Operations: 
  - plus (+)
  - minus (-)
  - multiplication (*)
  - division (/)
- Boolean Operations:
  - greater than (>)
  - greater or equal than (>=)
  - smaller than (<)
  - greater or equal than (<=)
  - equality  (==)
  - inequality (!=)

### Implicit Type Casting
Automatic casting is done at parsing time when integer expressions appears with double expressions in an operation. In this case, the integer is cast to double, and the final expression result computed. 

# Valid Input Examples
A series of valid input examples are listed in the tests folder.


# Run the Parser
To run the parser, first clone the repo in the local machine to download the *parser.c* file. 
```
git clone <repo_url>
```

Then make the *parser.c* file executable
```
chmod +x parser.c
```

Execution of the parser could be customized with two options: the *-i <input_file>* and the *-o <output_file>*. They allows to specify an input/output stream different from the default one, the *stdin* and *stdout*.

Run the parser with the command
```
./compiler.c [-i <input_file>]
```