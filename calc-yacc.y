%{
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>
#include <stdbool.h>

//  print parsing error
int yyerror (char const *message)
{
  return fprintf (stderr, "%s\n", message);
  fputs (message, stderr);
  fputc ('\n', stderr);
  return 0;
}

// prototype for yylex function - produced by compling lex.l file
int yylex(void);

// on EOF - stop scanning
int yywrap() {
      return 1;
}

// valid data types
char* type_name[] = {"boolean", "integer", "float"};

struct detailed_node {
      int var_type;         // 0 - boolean, 1 - integer, 2 - double, -1 -error
      double value;
}; 

// true - operands are compatible
// false - operands not compatible
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

  // other cases return false
  return false;
};

// on type not compatible - prompt the user error reason
void printErrorMessage(char* operator, int type1, int type2) {
  char buffer[1024];
  snprintf(buffer, sizeof(buffer), "Operation '%s' is not applicabile with %s and %s!\n", operator, type_name[type1], type_name[type2]);

  yyerror(buffer);
  return;
}

// output adapts to variable type
void printResult(int type, double value) {
  char buffer[1024];
  if(type == 0) // boolean
    snprintf(buffer, sizeof(buffer), "Type: %s, Value: %d\n", type_name[type], value!=0.0);
  else if(type == 1) // integer
    snprintf(buffer, sizeof(buffer), "Type: %s, Value: %d\n", type_name[type], (int) value);
  else // double
    snprintf(buffer, sizeof(buffer), "Type: %s, Value: %f\n", type_name[type], value);

  printf("%s\n", buffer);
  return;
}

// return max value from a and b - if int (1) and duoble (2) - returns double (2)
int max(int a, int b) {

  if(a >= b)
    return a;
  else 
    return b;
}

// return the correct value for the operation - apply type cohercion 
double getValue(int operator, int type, double val1, double val2) {
  double result;
  if(operator == DIV) {
    if(type == 1) 
      result = (int) val1 / (int) val2;
    else
      result = val1 / val2;
  }
  else if(operator == MOLT) {
    result = val1 * val2;
  } 
  else if(operator == PLUS) {
    result = val1 + val2;
  }
  else
    result = val1 - val2;

  return result;
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

%left BIGGER_THAN SMALLER_THAN EQUAL_TO NOT_EQUAL_TO BIGGER_EQ_THAN SMALLER_EQ_THAN
%left MINUS PLUS
%left MOLT DIV
%left C_PAR
%right UMINUS NOT O_PAR

%start stmt

%%

stmt  : 
      | stmt expr ';'   { printResult($2.var_type, $2.value); } 
      | stmt ';'        { printResult($1.var_type, $1.value); }
      ;

expr  : O_PAR expr C_PAR      { $$.var_type = $2.var_type; $$.value = $2.value; }

      | expr PLUS expr        { if(typesAreCorrect($1.var_type, $3.var_type, PLUS)) {
                                  $$.var_type = max($1.var_type, $3.var_type); $$.value = getValue(PLUS, $$.var_type, $1.value, $3.value);
                                } else { printErrorMessage("+", $1.var_type, $3.var_type); return -1; } }
      | expr MINUS expr       { if(typesAreCorrect($1.var_type, $3.var_type, MINUS)) {
                                  $$.var_type = max($1.var_type, $3.var_type); $$.value = $1.value - $3.value;
                                } else { printErrorMessage("-", $1.var_type, $3.var_type); return -1; } }
      | expr MOLT expr        { if(typesAreCorrect($1.var_type, $3.var_type, MOLT)) {
                                  $$.var_type = max($1.var_type, $3.var_type); $$.value = $1.value * $3.value; 
                                } else { printErrorMessage("*", $1.var_type, $3.var_type); return -1; } }
      | expr DIV expr         { if(typesAreCorrect($1.var_type, $3.var_type, DIV)) {
                                  $$.var_type = max($1.var_type, $3.var_type); $$.value = $1.value / $3.value;
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
      | FLOAT_VAL             { $$.var_type = 2; $$.value = $1; }
      | INT_VAL               { $$.var_type = 1; $$.value = $1; }
      ;
%%

#include "lex.yy.c"

int main() {
      int code = yyparse();
      if(code == 0)
            printf("Successfully parsed!\n");
      else
            printf("Parsing Error!\n");
}
