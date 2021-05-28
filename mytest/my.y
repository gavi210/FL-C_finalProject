%{

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <math.h>

/* symbl table implementation */

struct number{
    union{
        int ival;
        double dval;
    };
    char type;
    char *name;
};
typedef struct number number;

int yyerror (char *s);
int yylex();

void addSymbol(number symbol);
void printRes(number symbol);
void addSymbolInt(char *name, int value);
void addSymbolDouble(char *name, double value);

number computePlusExpression(number sym1, number sym2);
number computeMinusExpression(number sym1, number sym2);
number computeMultExpression(number sym1, number sym2);
number computeDivExpression(number sym1, number sym2);

char INT_TYPE = 1;
char FLOAT_TYPE = 2;

%}

%union{
    struct number value;
    char *string;
}

%token INT DOUBLE 
%token <string> VARNAME
%token <value> DOUBLEVAL INTEGERVAL

%token '(' ')'
%token O_PAR C_PAR

%type <value> expr assignment

%left '+' '-'
%left '*' '/'
%left '('
%right ')'

%%

program :   program expr '\n'               { printRes($2); }
        |   program assignment '\n'         { addSymbol($2); }
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
        ;

assignment: INT VARNAME '=' expr        { if($4.type == '1') 
                                            {$$.type = '1'; $$.name = strdup($2); $$.ival = $4.ival;}
                                          else{ yyerror ("syntax error"); return 1;}
                                        }
        |   DOUBLE VARNAME '=' expr     { if($4.type == '2') 
                                            {$$.type = '2'; $$.name = strdup($2); $$.dval = $4.dval; }
                                          else{ yyerror ("syntax error"); return 1;}
                                        }
        ;

%%

int main(void){
    yyparse();
    return 0;
}

void printRes(number symbol){
    if(symbol.type == '1'){
        printf("type: %c, name: %s, value: %hi\n", symbol.type, symbol.name, symbol.ival);
    }else{
        printf("type: %c, name: %s, value: %f\n", symbol.type, symbol.name, symbol.dval);
    }
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


void addSymbol(number symbol){
    if(symbol.type == '1'){
        printf("type: %c, name: %s, value: %hi\n", symbol.type, symbol.name, symbol.ival);
    }else{
        printf("type: %c, name: %s, value: %f\n", symbol.type, symbol.name, symbol.dval);
    }
    
}

int yyerror(char *s){
    printf("%s\n", s);
    return 0;
}