%{
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>
#include <stdbool.h>
#include "util/symbolTable.h"
#include "util/yydeclarations.h"
#include "util/typeSystem.h"
#include "util/outputMessages.h"

#define PARSING_ERROR 1

// on type not compatible - prompt the user error reason
void printErrorMessage(char* operator, int type1, int type2);

struct parse_tree_node {
      int type;     
      double value;     
      char* lexeme;
}; 

%}

%union {
       char* lexeme; // yytext for the identifier
       double value; // value for the token
       int type;
       struct parse_tree_node parse_tree_node_info;
       }

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
      | list_stmt stmt %prec LIST_STMT { $$.type = VOID_TYPE; }
      ;

stmt  : ';'                     { $$.type = VOID_TYPE; }
      | PRINT expr ';'          { printVarDescription($2.lexeme); $$.type = VOID_TYPE; }
      | ctrl_stmt               { $$.type = VOID_TYPE; }
      | expr_stmt  ';'          { $$.type = VOID_TYPE; }
      ;

ctrl_stmt :  while_stmt     { $$.type = VOID_TYPE; }   
      |  cond_stmt          { $$.type = VOID_TYPE; }
      ;

while_stmt :  WHILE expr enter_sub_scope stmt exit_sub_scope           { if($2.type != BOOL_TYPE) return PARSING_ERROR; else $$.type = VOID_TYPE; }
      |  WHILE expr '{' enter_sub_scope list_stmt exit_sub_scope '}'  { if($2.type != BOOL_TYPE) return PARSING_ERROR; else $$.type = VOID_TYPE; }
      ;

cond_stmt : if_stmt %prec IFX                                         { $$.type = VOID_TYPE; }
      |  if_stmt else_stmt                                            { $$.type = VOID_TYPE; }
      ;

if_stmt : IF expr enter_sub_scope stmt  exit_sub_scope        { if($2.type != BOOL_TYPE) return PARSING_ERROR; else $$.type = VOID_TYPE; }
      |  IF expr '{' enter_sub_scope list_stmt exit_sub_scope '}'     %prec IFX  { if($2.type != BOOL_TYPE) return PARSING_ERROR; else $$.type = VOID_TYPE; }
      ;

else_stmt : ELSE enter_sub_scope stmt exit_sub_scope              { $$.type = VOID_TYPE; }
      | ELSE '{' enter_sub_scope list_stmt exit_sub_scope '}'         { $$.type = VOID_TYPE; }

expr_stmt : expr                { printExpressionResult($1.type, $1.value); $$.type = VOID_TYPE; } 
      | decl                    { $$.type = VOID_TYPE; }
      | assign                  { $$.type = VOID_TYPE; }
      ;

expr  : O_PAR expr C_PAR      { $$.type = $2.type; $$.value = $2.value; }
      | a_expr                { $$.type = $1.type; $$.value = $1.value; }
      | b_expr                { $$.type = $1.type; $$.value = $1.value; }
      | IDENTIFIER            { node* sym_node = getsym($1);  if(sym_node == 0) { printf("Var %s is not defined!\n", $1); return PARSING_ERROR; }
                                else { $$.value = sym_node->value; $$.type = sym_node->type; $$.lexeme = sym_node->name; } }
      ;

a_expr : expr PLUS expr        { if(typesAreCorrect($1.type, $3.type, PLUS)) {
                                  $$.type = max($1.type, $3.type); $$.value = getValue(PLUS, $$.type, $1.value, $3.value);
                                } else { printErrorMessage("+", $1.type, $3.type); return -1; } }
      | expr MINUS expr       { if(typesAreCorrect($1.type, $3.type, MINUS)) {
                                  $$.type = max($1.type, $3.type); $$.value = $1.value - $3.value;
                                } else { printErrorMessage("-", $1.type, $3.type); return -1; } }
      | expr MOLT expr        { if(typesAreCorrect($1.type, $3.type, MOLT)) {
                                  $$.type = max($1.type, $3.type); $$.value = $1.value * $3.value; 
                                } else { printErrorMessage("*", $1.type, $3.type); return -1; } }
      | expr DIV expr         { if(typesAreCorrect($1.type, $3.type, DIV)) {
                                  $$.type = max($1.type, $3.type); $$.value = $1.value / $3.value;
                                } else { printErrorMessage("/", $1.type, $3.type); return -1; } }

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
                                } else { printErrorMessage(">", $1.type, $3.type); return -1; } }
      | expr BIGGER_EQ_THAN expr { if(typesAreCorrect($1.type, $3.type, BIGGER_EQ_THAN)) {
                                  $$.type = BOOL_TYPE; $$.value = $1.value >= $3.value;
                                } else { printErrorMessage(">=", $1.type, $3.type); return -1; } }
      | expr SMALLER_THAN expr { if(typesAreCorrect($1.type, $3.type, SMALLER_THAN)) {
                                  $$.type = BOOL_TYPE; $$.value = $1.value < $3.value;
                                } else { printErrorMessage("<", $1.type, $3.type); return -1; } }
      | expr SMALLER_EQ_THAN expr { if(typesAreCorrect($1.type, $3.type, SMALLER_EQ_THAN)) {
                                  $$.type = BOOL_TYPE; $$.value = $1.value <= $3.value;
                                } else { printErrorMessage("<=", $1.type, $3.type); return -1; } }
      | expr EQUAL_TO expr    { if(typesAreCorrect($1.type, $3.type, EQUAL_TO)) {
                                  $$.type = BOOL_TYPE; $$.value = $1.value == $3.value;
                                } else { printErrorMessage("==", $1.type, $3.type); return -1; } }
      | expr NOT_EQUAL_TO expr { if(typesAreCorrect($1.type, $3.type, NOT_EQUAL_TO)) {
                                  $$.type = BOOL_TYPE; $$.value = !($1.value == $3.value);
                                } else { printErrorMessage("!=", $1.type, $3.type); return -1; } }
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

void printErrorMessage(char* operator, int type1, int type2) {
  char buffer[1024];
  snprintf(buffer, sizeof(buffer), "Operation '%s' is not applicabile with %s and %s!\n", operator, type_name[type1], type_name[type2]);

  yyerror(buffer);
  return;
}

extern FILE* yyin;

int main(int argc, char** argv) {
	switch(argc) {
		case 2:
			yyin = fopen(argv[1], "r");
      if(!yyin)
        {
          fprintf(stderr, "Can't read file %s\n", argv[1]);
          return 1;
        }
			break;
		default:
		  printf("Type your program...\n");
	}
	sym_table = initialize_table();
	int code = yyparse();
	if(code == 0)
				printf("Successfully parsed!\n");
	else
				printf("Parsing Error!\n");
}