%{
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>
#include <stdbool.h>
#include "symbolTable.h"
#include "yydeclarations.h"
#include "typeSystem.h"
#include "outputMessages.h"

#define PARSING_ERROR 1
#define VOID -2  // as long as stmt type is VOID - no paring error found

// on type not compatible - prompt the user error reason
void printErrorMessage(char* operator, int type1, int type2) {
  char buffer[1024];
  snprintf(buffer, sizeof(buffer), "Operation '%s' is not applicabile with %s and %s!\n", operator, type_name[type1], type_name[type2]);

  yyerror(buffer);
  return;
}

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
%token <value> INT_VAL
%token <value> FLOAT_VAL 
%token <value> BOOL_VAL

// identifier for variables
%token <lexeme> IDENTIFIER

// data types
%token <type> BOOLEAN
%token <type> INT
%token <type> DOUBLE
%token <type> WHILE
%token <type> IF
%token <type> ELSE

// print content of a variable
%token <type> PRINT

// assignment operator
%token ASSIGN_OP

%type <type> enter_sub_scope
%type <type> exit_sub_scope

%type <parse_tree_node_info> stmt_list
%type <parse_tree_node_info> stmt
%type <parse_tree_node_info> ctrl_stmt
%type <parse_tree_node_info> cond_stmt
%type <parse_tree_node_info> while_stmt
%type <parse_tree_node_info> if_stmt
%type <parse_tree_node_info> else_stmt
%type <parse_tree_node_info> expr_stmt

%type <parse_tree_node_info> expr

%type <type> decl
%type <type> typename
%type <type> assign

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

%nonassoc STMT_LIST 

%start stmt_list // scope

%%

stmt_list : 
      | stmt_list stmt %prec STMT_LIST { $$.type = VOID; }
      ;

stmt  : ';'                     { $$.type = VOID; }
      | PRINT expr ';'          { nodeToString($2.lexeme); $$.type = VOID; }
      | ctrl_stmt               { $$.type = VOID; }
      | expr_stmt  ';'          { $$.type = VOID; printf("Read declaration pt2\n"); }
      ;

ctrl_stmt :  while_stmt     { $$.type = VOID; }   
      |  cond_stmt          { $$.type = VOID; }
      ;

while_stmt :  WHILE expr enter_sub_scope stmt exit_sub_scope           { if($2.type != BOOL_TYPE) return PARSING_ERROR; else $$.type = VOID; }
      |  WHILE expr '{' enter_sub_scope stmt_list exit_sub_scope '}'  { if($2.type != BOOL_TYPE) return PARSING_ERROR; else $$.type = VOID; }
      ;

cond_stmt : if_stmt %prec IFX                                         { $$.type = VOID; }
      |  if_stmt else_stmt                                            { $$.type = VOID; }
      ;

if_stmt : IF expr enter_sub_scope stmt  exit_sub_scope        { if($2.type != BOOL_TYPE) return PARSING_ERROR; else $$.type = VOID; }
      |  IF expr '{' enter_sub_scope stmt_list exit_sub_scope '}'     %prec IFX  { if($2.type != BOOL_TYPE) return PARSING_ERROR; else $$.type = VOID; }
      ;

else_stmt : ELSE enter_sub_scope stmt exit_sub_scope              { $$.type = VOID; }
      | ELSE '{' enter_sub_scope stmt_list exit_sub_scope '}'         { $$.type = VOID; }

expr_stmt : expr                { printResult($1.type, $1.value); $$.type = VOID; } 
      | decl                    { $$.type = VOID; printf("Read declaration!\n"); }
      | assign                  { $$.type = VOID; }
      ;

expr  : O_PAR expr C_PAR      { $$.type = $2.type; $$.value = $2.value; }

      | expr PLUS expr        { if(typesAreCorrect($1.type, $3.type, PLUS)) {
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

      | MINUS expr %prec UMINUS { if(typesAreCorrect($2.type, 0, UMINUS)) {
                                  $$.type = $2.type; $$.value = - ($2.value);
                                } else {
                                  char buffer[1024];
                                  snprintf(buffer, sizeof(buffer), "Operation '- UMINUS' is not applicabile with %s!\n", type_name[$2.type]);
                                  yyerror(buffer);
                                  return -1; } }
      | expr BIGGER_THAN expr { if(typesAreCorrect($1.type, $3.type, BIGGER_THAN)) {
                                  $$.type = 0; $$.value = $1.value > $3.value;
                                } else { printErrorMessage(">", $1.type, $3.type); return -1; } }
      | expr BIGGER_EQ_THAN expr { if(typesAreCorrect($1.type, $3.type, BIGGER_EQ_THAN)) {
                                  $$.type = 0; $$.value = $1.value >= $3.value;
                                } else { printErrorMessage(">=", $1.type, $3.type); return -1; } }
      | expr SMALLER_THAN expr { if(typesAreCorrect($1.type, $3.type, SMALLER_THAN)) {
                                  $$.type = 0; $$.value = $1.value < $3.value;
                                } else { printErrorMessage("<", $1.type, $3.type); return -1; } }
      | expr SMALLER_EQ_THAN expr { if(typesAreCorrect($1.type, $3.type, SMALLER_EQ_THAN)) {
                                  $$.type = 0; $$.value = $1.value <= $3.value;
                                } else { printErrorMessage("<=", $1.type, $3.type); return -1; } }
      | expr EQUAL_TO expr    { if(typesAreCorrect($1.type, $3.type, EQUAL_TO)) {
                                  $$.type = 0; $$.value = $1.value == $3.value;
                                } else { printErrorMessage("==", $1.type, $3.type); return -1; } }
      | expr NOT_EQUAL_TO expr { if(typesAreCorrect($1.type, $3.type, NOT_EQUAL_TO)) {
                                  $$.type = 0; $$.value = !($1.value == $3.value);
                                } else { printErrorMessage("!=", $1.type, $3.type); return -1; } }
      | NOT expr              { if(typesAreCorrect($2.type, 0, NOT)) {
                                  $$.type = 0; $$.value = !($2.value);
                              } else {
                                  char buffer[1024];
                                  snprintf(buffer, sizeof(buffer), "Operation '! NOT' is not applicabile with %s!\n", type_name[$2.type]);
                                  yyerror(buffer);
                                  return -1; } }
      | BOOL_VAL              { $$.type = 0; $$.value = $1; }
      | FLOAT_VAL             { $$.type = 2; $$.value = $1; }
      | INT_VAL               { $$.type = 1; $$.value = $1; }
      | IDENTIFIER            { node* sym_node = getsym($1);  if(sym_node == 0) { printf("Var %s is not defined!\n", $1); return PARSING_ERROR; }
                                else { $$.value = sym_node->value; $$.type = sym_node->type; $$.lexeme = sym_node->name; } }
      ;

decl : typename IDENTIFIER                  { if(insert_variable($2, $1, defaultValue($1)) == 0) $$ = $1; else return PARSING_ERROR; }
     | typename IDENTIFIER ASSIGN_OP expr   { if(typesMatches($1, $4.type)) { if(insert_variable($2, $1, $4.value) == 0) $$ = $1; else return PARSING_ERROR; }
                                            else { printf("Type does not matches... %s, %s\n", type_name[$1], type_name[$4.type]); return PARSING_ERROR; } }
     ;

typename : BOOLEAN      { $$ = BOOL_TYPE; }
      | INT             { $$ = INT_TYPE; } 
      | DOUBLE          { $$ = DOUBLE_TYPE; }
      ;

assign : IDENTIFIER ASSIGN_OP expr    { node* sym_node = getsym($1);  if(sym_node == 0) { printf("Var %s is not defined!\n", $1); return PARSING_ERROR; }
                                else if(typesMatches(sym_node->type, $3.type)) { $$ = $3.type; sym_node->value = $3.value; } else return PARSING_ERROR; }
       ;

enter_sub_scope : %prec ENTER_SUB_SCOPE    { enter_sub_table(); }
          ;

exit_sub_scope :  %prec EXIT_SUB_SCOPE     { exit_sub_table(); }
          ;

%%

#include "lex.yy.c"

int main() {
      sym_table = initialize_table();
      int code = yyparse();
      if(code == 0)
            printf("Successfully parsed!\n");
      else
            printf("Parsing Error!\n");
}