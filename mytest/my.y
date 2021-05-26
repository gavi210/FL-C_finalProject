%{

#include <stdio.h>
int yyerror (char *s);
int yylex();
%}

%union{
    int intType;
    char* string;
}

%token <intType> INTEGERVAL INT
%token <string> VARNAME
%type <intType> expr

%left '+' '-'
%left '*' '/'

%%

program :   program expr '\n'               { printf("%d\n", $2); }
        |   program assignment '\n'         { printf("New variable\n"); }
        |
        ;

expr    :   INTEGERVAL                      { $$ = $1; }
        |   expr '+' expr                   { $$ = $1 + $3; }
        |   expr '-' expr                   { $$ = $1 - $3; }
        ;

assignment: INT VARNAME '=' INTEGERVAL      { printf("New variable %s\n", $2); }

%%

int main(void){
    yyparse();
    return 0;
}

int yyerror(char *s){
    printf("%s\n", s);
    return 0;
}