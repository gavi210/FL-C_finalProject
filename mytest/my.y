%{

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <math.h>
#include "symbolTable.h"

/* symbl table implementation */

int yyerror (char *s);
int yylex();

void printRes(number symbol);
void addSymbol(char *name, int value);

int isGreaterThan(number sym1, number sym2);
int isGreaterThanOrEqual(number sym1, number sym2);

%}

%union{
    struct number value;
    char *string;
}

%token INT DOUBLE BOOLEAN PRINT

%token AND OR GTOE LTOE GT LT EQUAL

%token <string> VARNAME
%token <value> DOUBLEVAL INTEGERVAL BOOLVAL

%token '(' ')'

%type <value> expr boolexpr assignment

%left PRINT
%left '+' '-'
%left '*' '/'
%left '('
%right ')'

%left AND OR
%left NOT

%%

program :   program assignment '\n'         { insert_variable($2); }
        |   program PRINT expr '\n'         { printRes($3); }
        |   program PRINT boolexpr '\n'     { printRes($3); }
        |   
        ;

expr    :   '(' expr ')'                    { 
                                                $$.type = $2.type;
                                                if($2.type == '1'){$$.value = $2.value;}
                                                else{ $$.value = $2.value;}
                                            }
        |   expr '+' expr                   { $$.type = fmax($1.type, $3.type); $$.value = $1.value + $3.value; }
        |   expr '-' expr                   { $$.type = fmax($1.type, $3.type); $$.value = $1.value - $3.value; }
        |   expr '*' expr                   { $$.type = fmax($1.type, $3.type); $$.value = $1.value * $3.value; }
        |   expr '/' expr                   { $$.type = fmax($1.type, $3.type); $$.value = $1.value / $3.value; }
        |   DOUBLEVAL                       { $$.type = '2'; $$.value = $1.value; }
        |   INTEGERVAL                      { $$.type = '1'; $$.value = $1.value; }
        |   VARNAME                         { if(has_been_decleared($1)){ $$ = getVariable($1); } else {yyerror ("undeclared variable"); return 1;} }
        ;

boolexpr:   '(' boolexpr ')'                { $$ = $2; }
        |   expr GT expr                    { $$.type = '0'; $$.value = isGreaterThan($1, $3); }
        |   expr LT expr                    { $$.type = '0'; $$.value = isGreaterThan($3, $1); }
        |   expr GTOE expr                  { $$.type = '0'; $$.value = isGreaterThanOrEqual($1, $3); }
        |   expr LTOE expr                  { $$.type = '0'; $$.value = isGreaterThanOrEqual($3, $1); }
        |   expr EQUAL expr                 { $$.type = '0'; if($1.value == $3.value) { $$.value = 1; } else { $$.value = 0; }}
        |   boolexpr AND boolexpr           { $$.value = $1.value * $3.value; }
        |   boolexpr OR boolexpr            { $$.value = fmax($1.value, $3.value); }
        |   NOT boolexpr                    { $$ = $2; $$.value = 1 - $2.value; }
        |   BOOLVAL                         { $$.type = '0'; $$.value = $1.value; }
        ;

assignment: INT VARNAME '=' expr            { 
                                                if($4.type == '1') {
                                                        $$.type = '1'; $$.name = strdup($2); $$.value = $4.value;
                                                }
                                                else{ 
                                                    yyerror ("syntax error"); return 1;
                                                }
                                            }
        |   DOUBLE VARNAME '=' expr         { 
                                                if($4.type == '2') {
                                                    $$.type = '2'; $$.name = strdup($2); $$.value = $4.value; 
                                                }
                                                else{
                                                    yyerror ("syntax error"); return 1;
                                                }
                                            }
        |   BOOLEAN VARNAME '=' boolexpr    {
                                                if($4.type == '0') {
                                                    $$.type = '0'; $$.name = strdup($2); $$.value = $4.value; 
                                                }
                                                else{
                                                    yyerror ("syntax error"); return 1;
                                                }
                                            }
        ;

%%

int main(void){
    yyparse();
    return 0;
}

void printRes(number symbol){

    if(symbol.type == '0'){
        if(symbol.value == 0){
            printf("false\n");
        }else{
            printf("true\n");
        }
    }
    else if(symbol.type == '1'){
        printf("%i\n", (int) symbol.value);
    }else{
        printf("%f\n", symbol.value);
    }
}

int isGreaterThan(number sym1, number sym2){
    if(sym1.value > sym2.value){
        return 1;
    }else{
        return 0;
    }
}

int isGreaterThanOrEqual(number sym1, number sym2){
    if(sym1.value >= sym2.value){
        return 1;
    }else{
        return 0;
    }
}

int yyerror(char *s){
    printf("%s\n", s);
    return 0;
}