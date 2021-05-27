%{
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>
#include <stdbool.h>
#include "symbolTable.h"

#define TYPE_ERROR -1
#define BOOL_TYPE 0
#define INT_TYPE 1
#define DOUBLE_TYPE 2

#define PARSING_ERROR 1

// print parsing error
int yyerror (char const *message)
{
  return fprintf (stderr, "%s\n", message);
  fputs (message, stderr);
  fputc ('\n', stderr);
  return 0;
}

// prototype for yylex function - produced by compling lex.l file
int yylex(void);

// on EOF - stop scanning - code 1 -> wrapup reading
int yywrap() {
      return 1;
}

// valid data types
char* type_name[] = {"boolean", "integer", "double"};

// returns default value given the type
double defaultValue(int type) {
  if(type == BOOL_TYPE)
    return 1.0;
  else if(type == INT_TYPE || type == DOUBLE_TYPE)
    return 0.0;
  else 
    return -1.0;
}

struct parse_tree_node {
      int type;         // 0 - boolean, 1 - integer, 2 - double, -1 -error
      double value;     
      char* lexeme;    // variable name
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

// boolean operators - must be both boolean 
bool typesMatches(int type1, int type2) {
  if(type1 == BOOL_TYPE || type2 == BOOL_TYPE) { // at least on boolean 
    if(type1 == type2)  {// even the other must be boolean
      printf("Types matches!\n");
      return true;
    }
    else 
      return false;
  }
  else if(type1 == type2) { // equal - both int or both double
    return true;
  }
  else if(type1 > type2) { // first double - other int
    return true;
  }
  else 
    return false; // first int - other double
}

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

void nodeToString(char *sym_name) {
  node *table_entry = getsym(sym_name);
  if (table_entry == 0)  {
    printf("Variable %s not defined!", sym_name); 
  }
  else { 
    char buffer[1024];
    if(table_entry->type == 0) // boolean
      snprintf(buffer, sizeof(buffer), "Name: %s, Type: %s, Value: %d\n", sym_name, type_name[table_entry->type], table_entry->value!=0.0);
    else if(table_entry->type == 1) // integer
      snprintf(buffer, sizeof(buffer), "Name: %s, Type: %s, Value: %d\n", sym_name, type_name[table_entry->type], (int) table_entry->value);
    else // double
      snprintf(buffer, sizeof(buffer), "Name: %s, Type: %s, Value: %f\n", sym_name, type_name[table_entry->type], table_entry->value);

  printf("%s\n", buffer);
  }
}

%}

// YYSTYPE yylval - all attributes needed to capture semantic of tokens

// lexeme - on id
// value - on constant
// pointer - on internal node
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

// print content of a variable
%token PRINT

// assignment operator
%token ASSIGN_OP

%type <parse_tree_node_info> expr
%type <parse_tree_node_info> stmt
%type <type> decl
%type <type> typename
%type <type> assign

%right ASSIGN_OP
%left BIGGER_THAN SMALLER_THAN EQUAL_TO NOT_EQUAL_TO BIGGER_EQ_THAN SMALLER_EQ_THAN
%left NOT
%left MINUS PLUS
%left MOLT DIV
%left C_PAR
%right UMINUS O_PAR

// scope for the language
%start stmt

%%
stmt  : 
      | stmt expr ';'         { printResult($2.type, $2.value); } 
      | stmt decl ';'   
      | stmt assign ';'        
      | stmt PRINT expr ';'   { nodeToString($3.lexeme);}
      | stmt WHILE O_PAR expr C_PAR '{' stmt '}' ';' { if($4.type != BOOL_TYPE) return PARSING_ERROR; }
      | stmt ';'
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
%%

#include "lex.yy.c"

int main() {
      int code = yyparse();
      if(code == 0)
            printf("Successfully parsed!\n");
      else
            printf("Parsing Error!\n");
}