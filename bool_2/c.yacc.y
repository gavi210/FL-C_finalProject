%{
void yyerror (char *s);
int yylex();
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>
#include "y.tab.h"
%}

%token AND
%token BOOLVALUE
%left BOOLVALUE

%%

program : program statement '\n'
        | 
        ;

statement: boolExpr {printf("%d\n", $1);}
        ;
    
boolExpr: BOOLVALUE
        | boolExpr AND boolExpr { $$ = $1 * $3; }
        ;

%%

int main (void) {
	return yyparse ( );
}

void yyerror (char *s) {fprintf (stderr, "%s\n", s);}