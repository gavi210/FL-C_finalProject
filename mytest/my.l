%{

#include <math.h>

struct number{
    double value;
    int type;
    char *name;
};

#include "y.tab.h"
void yyerror (char *s);
int yylex();
void addSymbol(char *name, int value);

%}

DIGIT         [0-9]
INT_NUM       {DIGIT}+
FLOAT_NUM     {DIGIT}+\.{DIGIT}+

TYPE_NAME      int|double|boolean

LETTER        [a-zA-A]
IDENTIFIER    {LETTER}({LETTER}|{DIGIT})*

%%

print                               { return PRINT; }

true                                {yylval.value.value = 1; return BOOLVAL; }
false                               {yylval.value.value = 0; return BOOLVAL; }

and                                 { return AND; }
or                                  { return OR; }
not                                 { return NOT; }

if                                  { return IF; }

{TYPE_NAME}                         { if (strcmp(yytext,"int") == 0) return INT; else if (strcmp(yytext,"double") == 0) return DOUBLE; else return BOOLEAN; }

{IDENTIFIER}                        {yylval.string = strdup(yytext); return VARNAME;}

{INT_NUM}[\.]{INT_NUM}              {yylval.value.value = atof(yytext); return DOUBLEVAL;}

{INT_NUM}                           {yylval.value.value = atoi(yytext); return INTEGERVAL;}

"=="                                { return EQUAL; }    
"<="                                { return LTOE; }
"=>"                                { return GTOE; }
">"                                 { return GT; }
"<"                                 { return LT; }

[-+*/=()\n{};]                      return *yytext;

[ \t]                               ; /*skip whitespaces*/

.                                   {ECHO; yyerror ("unexpected character");}

%%

int yywrap(void) {
    return 1;
}