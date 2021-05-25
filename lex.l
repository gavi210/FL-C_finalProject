%option noyywrap
%{
#include <stdlib.h>
#include <string.h>
#include "y.tab.h" // imports all declarations done in yacc.y

%}

DIGIT         [0-9]
INT_NUM       {DIGIT}+
FLOAT_NUM     {INT_NUM}(\.{DIGIT}+)

BOOL_VAL true|false

%%

[ ]     { /* skip blanks */ }
\n      { /* skip new line character */ }

{INT_NUM}      { yylval.value = atof(yytext); return NUM_VAL;}
{FlOAT_NUM}    { yylval.value = atof(yytext); return NUM_VAL;}

{BOOL_VAL}  { if (strcmp(yytext,"true") == 0) yylval.value = 1; else yylval.value = 0; return BOOL_VAL; }

"+"     { return PLUS; }
"-"     { return MINUS; }
"*"     { return MOLT; }
"/"     { return DIV; }

"<"     { return SMALLER_THAN; }
">"     { return BIGGER_THAN; }
"=="    { return EQUAL_TO; }
"!="    { return NOT_EQUAL_TO; }
"!"     { return NOT; }

"("     { return O_PAR; }
")"     { return C_PAR; }

.       { return (int) yytext[0]; /* always matches, wrong input captured at parsing stage */} 

%%

