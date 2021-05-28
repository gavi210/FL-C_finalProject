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
void addSymbolInt(char *name, int value);
void addSymbolDouble(char *name, double value);

number computePlusExpression(number sym1, number sym2);
number computeMinusExpression(number sym1, number sym2);
number computeMultExpression(number sym1, number sym2);
number computeDivExpression(number sym1, number sym2);

int isGreaterThan(number sym1, number sym2);

char INT_TYPE = 1;
char FLOAT_TYPE = 2;

%}

%union{
    struct number value;
    char *string;
}

%token INT DOUBLE BOOLEAN PRINT

%token AND OR GTOE LTOE GT LT

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
                                                if($2.type == '1'){$$.ival = $2.ival;}
                                                else{ $$.dval = $2.dval;}
                                            }
        |   expr '+' expr                   { $$ = computePlusExpression($1, $3); }
        |   expr '-' expr                   { $$ = computeMinusExpression($1, $3); }
        |   expr '*' expr                   { $$ = computeMultExpression($1, $3); }
        |   expr '/' expr                   { $$ = computeDivExpression($1, $3); }
        |   DOUBLEVAL                       { $$.type = '2'; $$.dval = $1.dval; }
        |   INTEGERVAL                      { $$.type = '1'; $$.ival = $1.ival; }
        |   VARNAME                         { if(has_been_decleared($1)){ $$ = getVariable($1); } else {yyerror ("undeclared variable"); return 1;} }
        ;

boolexpr:   '(' boolexpr ')'                { $$ = $2; }
        |   expr GT expr                    { $$.type = 0; $$.bval = isGreaterThan($1, $3); }  
        |   boolexpr AND boolexpr           { $$.bval = $1.bval * $3.bval; }
        |   boolexpr OR boolexpr            { $$.bval = fmax($1.bval, $3.bval); }
        |   NOT boolexpr                    { $$ = $2; $$.bval = 1 - $2.bval; }
        |   BOOLVAL                         { $$.type = '0'; $$.bval = $1.bval; }
        ;

assignment: INT VARNAME '=' expr            { 
                                                if($4.type == '1') {
                                                        $$.type = '1'; $$.name = strdup($2); $$.ival = $4.ival;
                                                }
                                                else{ 
                                                    yyerror ("syntax error"); return 1;
                                                }
                                            }
        |   DOUBLE VARNAME '=' expr         { 
                                                if($4.type == '2') {
                                                    $$.type = '2'; $$.name = strdup($2); $$.dval = $4.dval; 
                                                }
                                                else{
                                                    yyerror ("syntax error"); return 1;
                                                }
                                            }
        |   BOOLEAN VARNAME '=' boolexpr    {
                                                if($4.type == '0') {
                                                    $$.type = '0'; $$.name = strdup($2); $$.bval = $4.bval; 
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
        if(symbol.bval == 0){
            printf("false\n");
        }else{
            printf("true\n");
        }
    }
    else if(symbol.type == '1'){
        printf("%i\n", symbol.ival);
    }else{
        printf("%f\n",symbol.dval);
    }
}

int isGreaterThan(number sym1, number sym2){
    printf("1 %f 2 %f\n", sym2.dval, sym2.dval);
    printf("1 %i 2 %i\n", sym2.ival, sym2.ival);
    return 0;
}

number computePlusExpression(number sym1, number sym2){

    number newNumber;

    newNumber.type = fmax(sym1.type, sym2.type);

    if(newNumber.type == '1'){
        newNumber.ival = sym1.ival + sym2.ival;
    }else{
        if(sym1.type == '1'){
            newNumber.dval = sym1.ival + sym2.dval;
        }
        else if(sym2.type == '1'){
            newNumber.dval = sym1.dval + sym2.ival;
        }
        else{
            newNumber.dval = sym1.dval + sym2.dval;
        }
    }
    return newNumber;
}

number computeMinusExpression(number sym1, number sym2){

    number newNumber;

    newNumber.type = fmax(sym1.type, sym2.type);

    if(newNumber.type == '1'){
        newNumber.ival = sym1.ival - sym2.ival;
    }else{
        if(sym1.type == '1'){
            newNumber.dval = sym1.ival - sym2.dval;
        }
        else if(sym2.type == '1'){
            newNumber.dval = sym1.dval - sym2.ival;
        }
        else{
            newNumber.dval = sym1.dval - sym2.dval;
        }
    }
    return newNumber;
}

number computeMultExpression(number sym1, number sym2){

    number newNumber;

    newNumber.type = fmax(sym1.type, sym2.type);

    if(newNumber.type == '1'){
        newNumber.ival = sym1.ival * sym2.ival;
    }else{
        if(sym1.type == '1'){
            newNumber.dval = sym1.ival * sym2.dval;
        }
        else if(sym2.type == '1'){
            newNumber.dval = sym1.dval * sym2.ival;
        }
        else{
            newNumber.dval = sym1.dval * sym2.dval;
        }
    }
    return newNumber;
}

number computeDivExpression(number sym1, number sym2){

    number newNumber;

    newNumber.type = fmax(sym1.type, sym2.type);

    if(newNumber.type == '1'){
        newNumber.ival = sym1.ival / sym2.ival;
    }else{
        if(sym1.type == '1'){
            newNumber.dval = sym1.ival / sym2.dval;
        }
        else if(sym2.type == '1'){
            newNumber.dval = sym1.dval / sym2.ival;
        }
        else{
            newNumber.dval = sym1.dval / sym2.dval;
        }
    }
    return newNumber;
}

int yyerror(char *s){
    printf("%s\n", s);
    return 0;
}