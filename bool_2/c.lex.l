%{
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"
#include <stdbool.h>

int yywrap (void) {return 1;}

void yyerror (char *s);

int yylex();

%}


%%

[ ]         { /* skip blanks */ }

false     {yylval = 0; return BOOLVALUE; }
true      {yylval = 1; return BOOLVALUE; }

and       {return AND;}

.         {ECHO; yyerror ("unexpected character");}

%%

