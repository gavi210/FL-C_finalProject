%{
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>
#include <stdbool.h>
#include <unistd.h>

#include "util/symbolTable.h"
#include "util/typeSystem.h"
#include "util/outputMessages.h"

#include "util/macros/parser.h"

#define PARSING_ERROR 1
#define YYERROR_VERBOSE 1 

FILE* output_stream; // output stream for the returned parser messages

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

a_expr : expr PLUS expr        	{ EVAL_ARITH_EXPR_RESULT($$, $1, $3, PLUS, "+") }
      | expr MINUS expr       	{ EVAL_ARITH_EXPR_RESULT($$, $1, $3, MINUS, "") }
      | expr MOLT expr        	{ EVAL_ARITH_EXPR_RESULT($$, $1, $3, MOLT, "*") }
      | expr DIV expr               { EVAL_ARITH_EXPR_RESULT($$, $1, $3, DIV, "/") }

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

b_expr : expr BIGGER_THAN expr      { EVAL_BOOL_EXPR_RESULT($$, $1, $3, BIGGER_THAN, ">", $1.value > $3.value) }
      | expr BIGGER_EQ_THAN expr    { EVAL_BOOL_EXPR_RESULT($$, $1, $3, BIGGER_EQ_THAN, ">=", $1.value >= $3.value) }
      | expr SMALLER_THAN expr 			{ EVAL_BOOL_EXPR_RESULT($$, $1, $3, SMALLER_THAN, "<", $1.value < $3.value) }
      | expr SMALLER_EQ_THAN expr 	{ EVAL_BOOL_EXPR_RESULT($$, $1, $3, SMALLER_EQ_THAN, "<=", $1.value <= $3.value) }
      | expr EQUAL_TO expr    			{ EVAL_BOOL_EXPR_RESULT($$, $1, $3, EQUAL_TO, "==", $1.value == $3.value) }
      | expr NOT_EQUAL_TO expr 			{ EVAL_BOOL_EXPR_RESULT($$, $1, $3, NOT_EQUAL_TO, "!", !($1.value < $3.value)) }
      | NOT expr              			{ if(typesAreCorrect($2.type, $2.type, NOT)) {
                                  		$$.type = BOOL_TYPE; $$.value = !($2.value);
                              					} else {
                                  			char buffer[1024];
                                                snprintf(buffer, sizeof(buffer), "Operation '! NOT' is not applicabile with %s!\n", type_name[$2.type]);
                                                yyerror(buffer);
                                                return -1; } }
      | BOOL_VAL              			{ $$.type = BOOL_TYPE; $$.value = $1; }
      ;

decl : typename IDENTIFIER                  { if(insert_variable($2, $1, defaultValue($1)) == 0) $$ = $1; else return PARSING_ERROR; }
     | typename IDENTIFIER ASSIGN_OP expr   { if(areTypesCompatible($1, $4.type) && insert_variable($2, $1, $4.value) == 0) $$ = $1; else return PARSING_ERROR; }
     ;

typename : BOOLEAN      { $$ = BOOL_TYPE; }
      | INT             { $$ = INT_TYPE; } 
      | DOUBLE          { $$ = DOUBLE_TYPE; }
      ;

assign : IDENTIFIER ASSIGN_OP expr    { node* sym_node = getsym($1);  if(sym_node != 0 && areTypesCompatible(sym_node->type, $3.type)) { $$ = $3.type; sym_node->value = $3.value; } else return PARSING_ERROR; }
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

char* inputFileName;

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
  fprintf(output_stream, "%s: %serror: %s%s\n", location_error_str(), RED, WHITE, message);
}

int main(int argc, char** argv) {
	// initialize default streams
	yyin = stdin;
      inputFileName = "stdin";
	char* output_file_name;
	output_stream = stdout;


	int opt; 
	int ix = 2;
	while ((opt = getopt(argc, argv, "i:o:")) != -1) {
			switch (opt) {
			case 'i': yyin = fopen(argv[ix], "r"); inputFileName = argv[ix]; ix = ix + 2; break;
			case 'o': output_stream = fopen(argv[ix], "w"); output_file_name = argv[ix]; ix = ix + 2; break;
			default:
					fprintf(stderr, "Usage: %s [-il] [file...]\n", argv[0]);
					exit(EXIT_FAILURE);
			}
	}

	if(!yyin){ // error in the customized input file
		fprintf(stderr, "Can't read input file!\n");
		
		// delete output_stream 
		if(output_stream != stdout)
			remove(output_file_name);
		return 1;
	}
	
	if(!output_stream) { // error in the customized output file 
		fprintf(stderr, "Can't write to output file!\n");
		return 1;
	}

	// no file input... read from stdin
	if(yyin == stdin)
		printf("Type here your program, ^D to terminate!\n");
	sym_table = initialize_table();

	yyparse();

	// flush output to file
	fflush(output_stream);

	// close files before exiting 
	fclose(yyin);
	fclose(output_stream);

	return 0;
}