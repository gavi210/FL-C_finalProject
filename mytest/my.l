%{

#include "y.tab.h"
void yyerror (char *s);
int yylex();

%}

%%

"int"                               {return INT;}

[a-z]([a-z]|[0-9])*                 {yylval.string = strdup(yytext); return VARNAME;}

[0-9]+                              {yylval.intType = atoi(yytext); return INTEGERVAL;}

[-+=\n]                             return *yytext;

[ \t]                               ; /*skip whitespaces*/

.                                   {ECHO; yyerror ("unexpected character");}

%%

int yywrap(void) {
    return 1;
}

/* [0-9]+.[0-9]+                     {yylval = atod(yytext); return DOUBLEVAL;} */

/*"bool"                              {return BOOL;}
"double"                            {return DOUBLE;}*/