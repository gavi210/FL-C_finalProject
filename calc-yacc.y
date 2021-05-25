%{
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>
#include <stdbool.h>

// on parsing error
int yyerror (char const *message)
{
  return fprintf (stderr, "%s\n", message);
  fputs (message, stderr);
  fputc ('\n', stderr);
  return 0;
}

// prototype for yylex function - decleared in the lex.l file
int yylex(void);

// on EOF ends (?)
int yywrap() {
      return 1;
}

// valid data types
char* type_name[] = {"boolean", "integer", "float"};

struct detailed_node {
      int var_type;         // 0 - number, 1 - boolean, -1 -error
      double value;
}; 

// given the expr types and the operator, returns true if operators are valid, false otherwise
bool typesAreCorrect(int type1, int type2, int operator) {
  // binary arithmetic operators
  if(operator == PLUS || operator == MINUS || operator == MOLT || operator == DIV) {
    if(type1 != 0 && type2 != 0) // both numeric
      return true;
    else
      return false;
  }
  // unary arithmetic operators
  else if(operator == UMINUS) {
    if(type1 != 0) // look only at the first one, second meaningless
      return true;
    else
      return false;
  }
  // binary boolean operators
  else if(operator == BIGGER_THAN || operator == BIGGER_EQ_THAN || operator == SMALLER_THAN || operator == SMALLER_EQ_THAN || operator == EQUAL_TO || operator == NOT_EQUAL_TO) {
    if(type1 != 0 && type2 != 0)
      return true;
    else
      return false;
  }
  // unary boolean operators
  else if(operator == NOT) {
    if(type1 == 0) // look only at the first one, second meaningless
      return true;
    else
      return false; 
  }

  return false;
};

void printErrorMessage(char* operator, int type1, int type2) {
  char buffer[1024];
  snprintf(buffer, sizeof(buffer), "Operation '%s' is not applicabile with %s and %s!\n", operator, type_name[type1], type_name[type2]);

  yyerror(buffer);
  return;
}

%}

// YYSTYPE yylval - all attributes needed to capture semantic of tokens
%union {
       // char* lexeme; // actual string matching the returned token
       double value; // value for the token
       struct detailed_node detailed_node_info;
       }

%token <value> INT_VAL
%token <value> FLOAT_VAL 
%token <value> BOOL_VAL // matches boolean values (>= 0: true, < 0: false)

%type <detailed_node_info> expr
%type <detailed_node_info> stmt
 /* %type <value> line */

%left BIGGER_THAN SMALLER_THAN EQUAL_TO NOT_EQUAL_TO BIGGER_EQ_THAN SMALLER_EQ_THAN
%left MINUS PLUS
%left MOLT DIV
%left C_PAR
%right UMINUS NOT O_PAR

%start stmt

%%

stmt  : /* empty */
      | stmt expr ';' { printf("Stmt... Type: %d, Value: %f\n", $2.var_type, $2.value); } 
      ;

expr  : O_PAR expr C_PAR      { $$.var_type = $2.var_type; $$.value = $2.value; }

      | expr PLUS expr        { if(typesAreCorrect($1.var_type, $3.var_type, PLUS)) {
                                  $$.var_type = 2; $$.value = $1.value + $3.value;
                                } else { printErrorMessage("+", $1.var_type, $3.var_type); return -1; } }
      | expr MINUS expr       { if(typesAreCorrect($1.var_type, $3.var_type, MINUS)) {
                                  $$.var_type = 2; $$.value = $1.value - $3.value;
                                } else { printErrorMessage("-", $1.var_type, $3.var_type); return -1; } }
      | expr MOLT expr        { if(typesAreCorrect($1.var_type, $3.var_type, MOLT)) {
                                  $$.var_type = 2; $$.value = $1.value * $3.value; 
                                } else { printErrorMessage("*", $1.var_type, $3.var_type); return -1; } }
      | expr DIV expr         { if(typesAreCorrect($1.var_type, $3.var_type, DIV)) {
                                  $$.var_type = 2; $$.value = $1.value / $3.value;
                                } else { printErrorMessage("/", $1.var_type, $3.var_type); return -1; } }

      | MINUS expr %prec UMINUS { if(typesAreCorrect($2.var_type, 0, UMINUS)) {
                                  $$.var_type = $2.var_type; $$.value = - ($2.value);
                                } else {
                                  char buffer[1024];
                                  snprintf(buffer, sizeof(buffer), "Operation '- UMINUS' is not applicabile with %s!\n", type_name[$2.var_type]);
                                  yyerror(buffer);
                                  return -1; } }
      | expr BIGGER_THAN expr { if(typesAreCorrect($1.var_type, $3.var_type, BIGGER_THAN)) {
                                  $$.var_type = 0; $$.value = $1.value > $3.value;
                                } else { printErrorMessage(">", $1.var_type, $3.var_type); return -1; } }
      | expr BIGGER_EQ_THAN expr { if(typesAreCorrect($1.var_type, $3.var_type, BIGGER_EQ_THAN)) {
                                  $$.var_type = 0; $$.value = $1.value >= $3.value;
                                } else { printErrorMessage(">=", $1.var_type, $3.var_type); return -1; } }
      | expr SMALLER_THAN expr { if(typesAreCorrect($1.var_type, $3.var_type, SMALLER_THAN)) {
                                  $$.var_type = 0; $$.value = $1.value < $3.value;
                                } else { printErrorMessage("<", $1.var_type, $3.var_type); return -1; } }
      | expr SMALLER_EQ_THAN expr { if(typesAreCorrect($1.var_type, $3.var_type, SMALLER_EQ_THAN)) {
                                  $$.var_type = 0; $$.value = $1.value <= $3.value;
                                } else { printErrorMessage("<=", $1.var_type, $3.var_type); return -1; } }
      | expr EQUAL_TO expr    { if(typesAreCorrect($1.var_type, $3.var_type, EQUAL_TO)) {
                                  $$.var_type = 0; $$.value = $1.value == $3.value;
                                } else { printErrorMessage("==", $1.var_type, $3.var_type); return -1; } }
      | expr NOT_EQUAL_TO expr { if(typesAreCorrect($1.var_type, $3.var_type, NOT_EQUAL_TO)) {
                                  $$.var_type = 0; $$.value = !($1.value == $3.value);
                                } else { printErrorMessage("!=", $1.var_type, $3.var_type); return -1; } }
      | NOT expr              { if(typesAreCorrect($2.var_type, 0, NOT)) {
                                  $$.var_type = 0; $$.value = !($2.value);
                              } else {
                                  char buffer[1024];
                                  snprintf(buffer, sizeof(buffer), "Operation '! NOT' is not applicabile with %s!\n", type_name[$2.var_type]);
                                  yyerror(buffer);
                                  return -1; } }
      | BOOL_VAL              { $$.var_type = 0; $$.value = $1; }
      | FLOAT_VAL             { printf("Recognized float value\n"); $$.var_type = 2; $$.value = $1; }
      | INT_VAL               { printf("Recognized integer value\n"); $$.var_type = 1; $$.value = $1; }
      ;
%%

#include "lex.yy.c"

int main() {
      int code = yyparse();
      if(code == 0)
            printf("Successfully parsed!\n");
      else
            printf("Error!\n");
}
