%{
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>
#include <stdbool.h>

#include "util/symbolTable.h"
#include "util/typeSystem.h"
#include "util/outputMessages.h"

#include "util/macros/parser.h"

#define PARSING_ERROR 1
#define YYERROR_VERBOSE 1 

void yyerror (char const *message);

int yylex(void);

int yywrap() {
      return 1;
}

struct parse_tree_node {
      int type;     
      double value;     
      char* lexeme;
}; 

%}

%union {
       char* lexeme; // text for identifiers
       double value; // value for tokens
       int type;
       struct parse_tree_node parse_tree_node_info;
       }

%locations  // decleare the YYLTYPE struct 
%{ 
      YYLTYPE yylloc;  // instantiate the global instance
%}

// constant values 
%token <value> BOOL_VAL INT_VAL FLOAT_VAL 

// identifier for variables
%token <lexeme> IDENTIFIER

// data types
%token <type> DOUBLE INT BOOLEAN

// reserved keywords
%token <type> WHILE IF ELSE PRINT

%type <type> enter_sub_scope exit_sub_scope decl typename assign

%type <parse_tree_node_info> list_stmt stmt ctrl_stmt cond_stmt while_stmt if_stmt else_stmt expr_stmt expr a_expr b_expr

// precedence rules
%nonassoc ENTER_SUB_SCOPE EXIT_SUB_SCOPE

%nonassoc INT_VAL FLOAT_VAL BOOL_VAL IDENTIFIER BOOLEAN INT DOUBLE WHILE IF PRINT ';' '}' 

%right ASSIGN_OP
%left BIGGER_THAN SMALLER_THAN EQUAL_TO NOT_EQUAL_TO BIGGER_EQ_THAN SMALLER_EQ_THAN
%left NOT
%left MINUS PLUS
%left MOLT DIV
%left C_PAR
%right UMINUS O_PAR

%nonassoc IFX // gives single IF lower precedence
%nonassoc ELSE

%nonassoc LIST_STMT 

%start list_stmt // scope

%%

list_stmt : 
      | list_stmt stmt %prec LIST_STMT { ASSIGN_VOID_TYPE($$) }
      ;

stmt  : ';'                     { ASSIGN_VOID_TYPE($$) }
      | PRINT expr ';'          { DUMP_VAR($2.lexeme) ASSIGN_VOID_TYPE($$) }
      | ctrl_stmt               { ASSIGN_VOID_TYPE($$) }
      | expr_stmt  ';'          { ASSIGN_VOID_TYPE($$) }
      ;

ctrl_stmt :  while_stmt     		{ ASSIGN_VOID_TYPE($$) }
      |  cond_stmt          		{ ASSIGN_VOID_TYPE($$) }
      ;

while_stmt :  WHILE expr enter_sub_scope stmt exit_sub_scope           	{ CHECK_EXPR_BOOL($2, $$) }
      |  WHILE expr '{' enter_sub_scope list_stmt exit_sub_scope '}'  	{ CHECK_EXPR_BOOL($2, $$) }
      ;

cond_stmt : if_stmt %prec IFX                                         	{ ASSIGN_VOID_TYPE($$) }
      |  if_stmt else_stmt                                            	{ ASSIGN_VOID_TYPE($$) }
      ;

if_stmt : IF expr enter_sub_scope stmt  exit_sub_scope        								{ CHECK_EXPR_BOOL($2, $$) }
      |  IF expr '{' enter_sub_scope list_stmt exit_sub_scope '}' %prec IFX  	{ CHECK_EXPR_BOOL($2, $$) }
      ;

else_stmt : ELSE enter_sub_scope stmt exit_sub_scope              		{ ASSIGN_VOID_TYPE($$) }
      | ELSE '{' enter_sub_scope list_stmt exit_sub_scope '}'         { ASSIGN_VOID_TYPE($$) }

expr_stmt : expr                { DUMP_EXPR($1) ASSIGN_VOID_TYPE($$) } 
      | decl                    { ASSIGN_VOID_TYPE($$) }
      | assign                  { ASSIGN_VOID_TYPE($$) }
      ;

expr  : O_PAR expr C_PAR      { COPY_TYPE_VALUE($$, $2) }
      | a_expr                { COPY_TYPE_VALUE($$, $1) }
      | b_expr                { COPY_TYPE_VALUE($$, $1) }
      | IDENTIFIER            { CHECK_VAR_DECLEARED($$, getsym($1), $1) }
      ;

a_expr : expr PLUS expr        { if(typesAreCorrect($1.type, $3.type, PLUS)) {
                                  $$.type = max($1.type, $3.type); $$.value = getValue(PLUS, $$.type, $1.value, $3.value);
                                } else { printIncompatibleTypesError("+", $1.type, $3.type); return -1; } }
      | expr MINUS expr       { if(typesAreCorrect($1.type, $3.type, MINUS)) {
                                  $$.type = max($1.type, $3.type); $$.value = $1.value - $3.value;
                                } else { printIncompatibleTypesError("-", $1.type, $3.type); return -1; } }
      | expr MOLT expr        { if(typesAreCorrect($1.type, $3.type, MOLT)) {
                                  $$.type = max($1.type, $3.type); $$.value = $1.value * $3.value; 
                                } else { printIncompatibleTypesError("*", $1.type, $3.type); return -1; } }
      | expr DIV expr         { if(typesAreCorrect($1.type, $3.type, DIV)) {
                                  $$.type = max($1.type, $3.type); $$.value = $1.value / $3.value;
                                } else { printIncompatibleTypesError("/", $1.type, $3.type); return -1; } }

      | MINUS expr %prec UMINUS { if(typesAreCorrect($2.type, $2.type, UMINUS)) {
                                  $$.type = $2.type; $$.value = - ($2.value);
                                } else {
                                  char buffer[1024];
                                  snprintf(buffer, sizeof(buffer), "Operation '- UMINUS' is not applicabile with %s!\n", type_name[$2.type]);
                                  yyerror(buffer);
                                  return -1; } }
      | INT_VAL               { $$.type = INT_TYPE; $$.value = $1; }
      | FLOAT_VAL             { $$.type = DOUBLE_TYPE; $$.value = $1; }
      ;

b_expr : expr BIGGER_THAN expr { if(typesAreCorrect($1.type, $3.type, BIGGER_THAN)) {
                                  $$.type = BOOL_TYPE; $$.value = $1.value > $3.value;
                                } else { printIncompatibleTypesError(">", $1.type, $3.type); return -1; } }
      | expr BIGGER_EQ_THAN expr { if(typesAreCorrect($1.type, $3.type, BIGGER_EQ_THAN)) {
                                  $$.type = BOOL_TYPE; $$.value = $1.value >= $3.value;
                                } else { printIncompatibleTypesError(">=", $1.type, $3.type); return -1; } }
      | expr SMALLER_THAN expr { if(typesAreCorrect($1.type, $3.type, SMALLER_THAN)) {
                                  $$.type = BOOL_TYPE; $$.value = $1.value < $3.value;
                                } else { printIncompatibleTypesError("<", $1.type, $3.type); return -1; } }
      | expr SMALLER_EQ_THAN expr { if(typesAreCorrect($1.type, $3.type, SMALLER_EQ_THAN)) {
                                  $$.type = BOOL_TYPE; $$.value = $1.value <= $3.value;
                                } else { printIncompatibleTypesError("<=", $1.type, $3.type); return -1; } }
      | expr EQUAL_TO expr    { if(typesAreCorrect($1.type, $3.type, EQUAL_TO)) {
                                  $$.type = BOOL_TYPE; $$.value = $1.value == $3.value;
                                } else { printIncompatibleTypesError("==", $1.type, $3.type); return -1; } }
      | expr NOT_EQUAL_TO expr { if(typesAreCorrect($1.type, $3.type, NOT_EQUAL_TO)) {
                                  $$.type = BOOL_TYPE; $$.value = !($1.value == $3.value);
                                } else { printIncompatibleTypesError("!=", $1.type, $3.type); return -1; } }
      | NOT expr              { if(typesAreCorrect($2.type, $2.type, NOT)) {
                                  $$.type = BOOL_TYPE; $$.value = !($2.value);
                              } else {
                                  char buffer[1024];
                                  snprintf(buffer, sizeof(buffer), "Operation '! NOT' is not applicabile with %s!\n", type_name[$2.type]);
                                  yyerror(buffer);
                                  return -1; } }
      | BOOL_VAL              { $$.type = BOOL_TYPE; $$.value = $1; }
      ;

decl : typename IDENTIFIER                  { if(insert_variable($2, $1, defaultValue($1)) == 0) $$ = $1; else return PARSING_ERROR; }
     | typename IDENTIFIER ASSIGN_OP expr   { if(areTypesCompatible($1, $4.type)) { if(insert_variable($2, $1, $4.value) == 0) $$ = $1; else return PARSING_ERROR; }
                                            	else { printf("Type does not matches... %s, %s\n", type_name[$1], type_name[$4.type]); return PARSING_ERROR; } }
     ;

typename : BOOLEAN      { $$ = BOOL_TYPE; }
      | INT             { $$ = INT_TYPE; } 
      | DOUBLE          { $$ = DOUBLE_TYPE; }
      ;

assign : IDENTIFIER ASSIGN_OP expr    { node* sym_node = getsym($1);  if(sym_node == 0) { printf("Var %s is not defined!\n", $1); return PARSING_ERROR; }
                                          else if(areTypesCompatible(sym_node->type, $3.type)) { $$ = $3.type; sym_node->value = $3.value; } else return PARSING_ERROR; }
       ;

enter_sub_scope : %prec ENTER_SUB_SCOPE    { enter_sub_table(); }
	;

exit_sub_scope :  %prec EXIT_SUB_SCOPE     { exit_sub_table(); }
	;

%%

#include "lex.yy.c"
#include "util/outputMessages.c"
#include "util/symbolTable.c"
#include "util/typeSystem.c"

/* 
  string generator for the error location 
*/
char * location_error_str() {
  char *buffer = (char*)malloc(256 * sizeof(char));   
  sprintf(buffer, "%s:%d:%d", inputFileName, yylloc.first_line, yylloc.first_column);   
  return buffer;    
}

/* adorn the error message with the error location */
void yyerror (char const *message) {
  printf ("%s: error: %s\n", location_error_str(), message);
}

int main(int argc, char** argv) {
	switch(argc) {
		case 2:
			yyin = fopen(argv[1], "r");

			if(!yyin) { // file not exists
				fprintf(stderr, "Can't read file %s\n", argv[1]);
				return 1;
			}
			else 
				inputFileName = argv[1];
			break;
		default:
		  printf("Type here the program...\n");
	}

	sym_table = initialize_table();
      
	int code = yyparse();
	if(code == 0)
				printf("Successfully parsed!\n");
	else
				printf("Parsing Error!\n");
}