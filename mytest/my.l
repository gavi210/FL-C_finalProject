%{

#include <math.h>

struct number{
    union{
        int ival;
        double dval;
    };
    char type;
    char *name;
};

#include "y.tab.h"
void yyerror (char *s);
int yylex();
void addSymbolInt(char *name, int value);
void addSymbolDouble(char *name, int value);

%}

DIGIT         [0-9]
INT_NUM       {DIGIT}+
FLOAT_NUM     {DIGIT}+\.{DIGIT}+
BOOL_VAL      true|false

TYPE_NAME      int|double|boolean

LETTER        [a-zA-A]
IDENTIFIER    {LETTER}({LETTER}|{DIGIT})*

%%

{TYPE_NAME}                         { if (strcmp(yytext,"int") == 0) return INT; else if (strcmp(yytext,"double") == 0) return DOUBLE; }

{IDENTIFIER}                        {yylval.string = strdup(yytext); return VARNAME;}

{INT_NUM}[\.]{INT_NUM}              {yylval.value.dval = atof(yytext); return DOUBLEVAL;}

{INT_NUM}                           {yylval.value.ival = atoi(yytext); return INTEGERVAL;}

[-+*/=()\n]                         return *yytext;

[ \t]                               ; /*skip whitespaces*/

.                                   {ECHO; yyerror ("unexpected character");}

%%

int yywrap(void) {
    return 1;
}

/*"bool"                              {return BOOL;}
"double"                            {return DOUBLE;}*/