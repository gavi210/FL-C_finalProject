%option noyywrap
%{
#include <stdlib.h>
#include <string.h>

%}

DIGIT    [0-9]
NUM      {DIGIT}+(\.{DIGIT}+)?

TRUE     true
FALSE    false

%%

[ ]     { /* skip blanks */ }

{NUM}    { yylval.value = atof(yytext); return NUM;}
{TRUE}   { return TRUE; }
{FALSE}  { return FALSE; }

"+"     { return '+'; }
"-"     { return '-'; }

"<"     { return '<'; }
">"     { return '>'; }
"=="    { return '=='; }
"("     { return '('; }
")"     { return ')'; }

\n      { /* skip new line character */ }
  
%%

