%option noyywrap
%{
#include <stdlib.h>
#include <string.h>

struct Tuple 
{
    char* lexeme;
    double value;
} yylval;

%}

DIGIT       [0-9]
INT_NUM     {DIGIT}+
INT_TYPE    int
REAL_NUM    {DIGIT}\.{DIGIT}+
REAL_TYPE   real


LETTER      [a-zA-Z]
ID          {LETTER}({LETTER}|{DIGIT})*


%%

{INT_NUM}       { printf("Integer: %d\n", atoi(yytext)); }
{INT_TYPE}      { printf("Int_type: %s\n", yytext); }
{REAL_NUM}      { printf("Real: %f\n", atof(yytext)); }
{REAL_TYPE}     { printf("Real_type: %s\n", yytext); }
{ID}            { printf("Id: %s\n", yytext); }

"+"             { printf("Operator: %s\n", yytext); }
"-"             { printf("Operator: %s\n", yytext); }
"*"             { printf("Operator: %s\n", yytext); }
"/"             { printf("Operator: %s\n", yytext); }

"&&"            { printf("Operator: %s\n", yytext); }            
"||"            { printf("Operator: %s\n", yytext); }
"!"             { printf("Operator: %s\n", yytext); }
"=="            { printf("Operator: %s\n", yytext); }
"<>"            { printf("Operator: %s\n", yytext); }
"<"             { printf("Operator: %s\n", yytext); }
"<="            { printf("Operator: %s\n", yytext); }
">"             { printf("Operator: %s\n", yytext); }
">="            { printf("Operator: %s\n", yytext); }

"("             { printf("Operator: %s\n", yytext); }
")"             { printf("Operator: %s\n", yytext); }
";"             { printf("Operator: %s\n", yytext); }
"="             { printf("Operator: %s\n", yytext); }

[ \t\n]+          /* eat up whitespace */
.               { printf( "Unrecognized character: %s\n", yytext ); }

%%

int main( int argc, char **argv )
    {
    ++argv, --argc;  /* skip over program name */
    if ( argc > 0 )
            yyin = fopen( argv[0], "r" );
    else
            yyin = stdin;

    yylex();
    }