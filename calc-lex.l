%option noyywrap
%{
#include <stdlib.h>
#include <string.h>
#include "y.tab.h" // imports all declarations done in yacc.y

%}

DIGIT         [0-9]
INT_NUM       {DIGIT}+
FLOAT_NUM     {DIGIT}+\.{DIGIT}+

BOOL_VAL      true|false

TYPE_NAME      int|double|boolean

PRINT_KEYWORD print
WHILE_KEYWORD while
IF_KEYWORD    if
ELSE_KEYWORD  else

LETTER        [a-zA-Z]
IDENTIFIER    {LETTER}({LETTER}|{DIGIT})*

%%

[ ]     { /* skip blanks */ }
\n      { /* skip new line character */ }

{INT_NUM}      { yylval.value = atof(yytext); return INT_VAL;}
{FLOAT_NUM}    { yylval.value = atof(yytext); return FLOAT_VAL;}

{BOOL_VAL}     { if (strcmp(yytext,"true") == 0) yylval.value = 1; else yylval.value = 0; return BOOL_VAL; }
{TYPE_NAME}    { if (strcmp(yytext,"int") == 0) return INT; else if (strcmp(yytext,"double") == 0) return DOUBLE; else return BOOLEAN; }

{PRINT_KEYWORD} { return PRINT; }
{WHILE_KEYWORD} { return WHILE; }
{IF_KEYWORD}    { return IF; }
{ELSE_KEYWORD}  { return ELSE; }
{IDENTIFIER}  { yylval.lexeme = strdup(yytext); return IDENTIFIER; }

"+"     { return PLUS; }
"-"     { return MINUS; }
"*"     { return MOLT; }
"/"     { return DIV; }

"="     { return ASSIGN_OP; }
"<"     { return SMALLER_THAN; }
">"     { return BIGGER_THAN; }
"<="    { return SMALLER_EQ_THAN; }
">="    { return BIGGER_EQ_THAN; }
"=="    { return EQUAL_TO; }
"!="    { return NOT_EQUAL_TO; }
"!"     { return NOT; }

"("     { return O_PAR; }
")"     { return C_PAR; }

";"     { return ';'; }
"{"     { return '{'; }
"}"     { return '}'; }

.       { return (int) yytext[0]; /* always matches, wrong input captured at parsing stage */} 

%%