%{

#include <stdio.h>

/* symbl table implementation */


int yyerror (char *s);
int yylex();
void addSymbolInt(char *name, int value);
void addSymbolDouble(char *name, double value);


%}

%union{
    int intType;
    double doubleType;
    char* string;
}

%token INT DOUBLE

%token <intType> INTEGERVAL
%token <doubleType> DOUBLEVAL
%token <string> VARNAME

%type <intType> expr

%left '+' '-'
%left '*' '/'

%%

program :   program expr '\n'               { printf("%d\n", $2); }
        |   program assignment '\n'         { }
        |
        ;

expr    :   DOUBLEVAL                       { $$ = $1; }
        |   INTEGERVAL                      { $$ = $1; }
        |   expr '+' expr                   { $$ = $1 + $3; }
        |   expr '-' expr                   { $$ = $1 - $3; }
        ;

assignment: INT VARNAME '=' expr      { addSymbolInt($2, $4); }
        |   DOUBLE VARNAME '=' expr    { addSymbolDouble($2, $4); }
        ;

%%

int main(void){
    yyparse();
    return 0;
}

void addSymbolInt(char *name, int value){
    printf("%s, %d\n", name, value);
}

void addSymbolDouble(char *name, double value){
    printf("%s, %f\n", name, value);
}

int yyerror(char *s){
    printf("%s\n", s);
    return 0;
}