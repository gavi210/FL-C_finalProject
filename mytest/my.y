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

#define BOOLEAN_TYPE 0
#define INTEGER_TYPE 1
#define DOUBLE_TYPE 2

%}

%union{
    struct number value;
    char *string;
}

%token INT DOUBLE BOOLEAN PRINT

%token AND OR GTOE LTOE GT LT EQUAL

%token IF WHILE

%token <string> VARNAME
%token <value> DOUBLEVAL INTEGERVAL BOOLVAL

%token '(' ')'

%type <value> expr numexpr assignment 
%type <value> declaration boolexpr

%left '+' '-'
%left '*' '/'
%left '('
%right ')'

%left AND OR 
%left NOT

%start program

%%

program :   program assignment ';'          { insert_variable($2); }
        |   program declaration ';'         { insert_variable($2); }
        |   program PRINT expr ';'          { printRes($3); }
        |   program ctrlstmt ';'            { ; }
        |   
        ;

ctrlstmt:   IF'(' boolexpr ')''{' program'}'{ ; }
        |   WHILE'(' boolexpr ')''{' program'}'{ ; }
        ;

expr    :   numexpr                         { $$ = $1; }
        |   boolexpr                        { $$ = $1; }
        ;

numexpr :   '(' numexpr ')'                 { 
                                                $$.type = $2.type;
                                                if($2.type == INTEGER_TYPE){$$.value = $2.value;}
                                                else{ $$.value = $2.value;}
                                            }
        |   numexpr '+' numexpr             { $$.type = fmax($1.type, $3.type); $$.value = $1.value + $3.value; }
        |   numexpr '-' numexpr             { $$.type = fmax($1.type, $3.type); $$.value = $1.value - $3.value; }
        |   numexpr '*' numexpr             { $$.type = fmax($1.type, $3.type); $$.value = $1.value * $3.value; }
        |   numexpr '/' numexpr             { $$.type = fmax($1.type, $3.type); $$.value = $1.value / $3.value; }
        |   DOUBLEVAL                       { $$.type = INTEGER_TYPE; $$.value = $1.value; }
        |   INTEGERVAL                      { $$.type = INTEGER_TYPE; $$.value = $1.value; }
        |   VARNAME                         { if(has_been_decleared($1)){ $$ = getVariable($1); } else {yyerror ("undeclared variable"); return 1;} }
        ;

boolexpr:   '(' boolexpr ')'                { $$ = $2; }
        |   numexpr GT numexpr              { $$.type = BOOLEAN_TYPE; $$.value = isGreaterThan($1, $3); }
        |   numexpr LT numexpr              { $$.type = BOOLEAN_TYPE; $$.value = isGreaterThan($3, $1); }
        |   numexpr GTOE numexpr            { $$.type = BOOLEAN_TYPE; $$.value = isGreaterThanOrEqual($1, $3); }
        |   numexpr LTOE numexpr            { $$.type = BOOLEAN_TYPE; $$.value = isGreaterThanOrEqual($3, $1); }
        |   numexpr EQUAL numexpr           { $$.type = BOOLEAN_TYPE; if($1.value == $3.value) { $$.value = 1; } else { $$.value = 0; }}
        |   boolexpr AND boolexpr           { $$.value = $1.value * $3.value; }
        |   boolexpr OR boolexpr            { $$.value = fmax($1.value, $3.value); }
        |   NOT boolexpr                    { $$ = $2; $$.value = 1 - $2.value; }
        |   BOOLVAL                         { $$.type = BOOLEAN_TYPE; $$.value = $1.value; }
        |   VARNAME                         { if(has_been_decleared($1)){ $$ = getVariable($1); } else {yyerror ("undeclared variable"); return 1;} }
        ;   

declaration:INT VARNAME                     { $$.type = INTEGER_TYPE; $$.name = strdup($2); $$.value = 0; }
        |   DOUBLE VARNAME                  { $$.type = DOUBLE_TYPE; $$.name = strdup($2); $$.value = 0.0; }
        |   BOOLEAN VARNAME                 { $$.type = BOOLEAN_TYPE; $$.name = strdup($2); $$.value = 0; }
        ;

assignment: INT VARNAME '=' numexpr         { 
                                                if($4.type == INTEGER_TYPE) {
                                                        $$.type = INTEGER_TYPE; $$.name = strdup($2); $$.value = $4.value;
                                                }
                                                else{ 
                                                    yyerror ("type error"); return 1;
                                                }
                                            }
        |   DOUBLE VARNAME '=' numexpr      { 
                                                if($4.type == INTEGER_TYPE) {
                                                    $$.type = DOUBLE_TYPE; $$.name = strdup($2); $$.value = $4.value; 
                                                }
                                                else{
                                                    yyerror ("type error"); return 1;
                                                }
                                            }
        |   BOOLEAN VARNAME '=' boolexpr    {
                                                if($4.type == BOOLEAN_TYPE) {
                                                    $$.type = BOOLEAN_TYPE; $$.name = strdup($2); $$.value = $4.value; 
                                                }
                                                else{
                                                    yyerror ("type error"); return 1;
                                                }
                                            }
        ;

%%

int main(void){
    yyparse();
    return 0;
}

void printRes(number symbol){

    if(symbol.type == BOOLEAN_TYPE){
        if(symbol.value == 0){
            printf("false\n");
        }else{
            printf("true\n");
        }
    }
    else if(symbol.type == INTEGER_TYPE){
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