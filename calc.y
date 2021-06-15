%{

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <math.h>
#include "./utils/symbol_table.c"

/* symbl table implementation */

int yyerror (const char *s);
int yylex();
int success = 1;

void printRes(number symbol);
void addSymbol(char *name, int value);

int isGreaterThan(number sym1, number sym2);
int isGreaterThanOrEqual(number sym1, number sym2);
bool areTypesComp(number sym1, number sym2);

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

%token IF ELSE WHILE

%token <string> IDENTIFIER
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

program :   program assignment ';'          { ; }
        |   program declaration ';'         { insert_variable($2); }
        |   program PRINT expr ';'          { printRes($3); }
        |   program ctrlstmt ';'            { ; }
        |   
        ;

ctrlstmt:   IF'(' boolexpr ')''{' program'}'{ ; }
        |   IF'(' boolexpr ')''{' program'}' ELSE '{' program '}' {;}
        |   WHILE'(' boolexpr ')''{' program'}'{ ; }
        ;

expr    : boolexpr                          { $$ = $1; }  
        | numexpr                           { $$ = $1; }  
        ;

numexpr :   '(' numexpr ')'                 { 
                                                $$.type = $2.type;
                                                if($2.type == INTEGER_TYPE){$$.value = $2.value;}
                                                else{ $$.value = $2.value;}
                                            }
        |   '-' numexpr                     { if($2.type != BOOLEAN_TYPE) {$$.type = $2.type; $$.value = - $2.value;} else { yyerror("type mismatch"); return 1;}}
        |   numexpr '+' numexpr             { if(areTypesComp($1, $3)) {$$.type = fmax($1.type, $3.type); $$.value = $1.value + $3.value;} else { yyerror("type mismatch"); return 1;} }
        |   numexpr '-' numexpr             { if(areTypesComp($1, $3)) {$$.type = fmax($1.type, $3.type); $$.value = $1.value - $3.value;} else { yyerror("type mismatch"); return 1;} }
        |   numexpr '*' numexpr             { if(areTypesComp($1, $3)) {$$.type = fmax($1.type, $3.type); $$.value = $1.value * $3.value;} else { yyerror("type mismatch"); return 1;} }
        |   numexpr '/' numexpr             { if(areTypesComp($1, $3)) {$$.type = fmax($1.type, $3.type); $$.value = $1.value / $3.value;} else { yyerror("type mismatch"); return 1;} }
        |   DOUBLEVAL                       { $$.type = DOUBLE_TYPE; $$.value = $1.value; }
        |   INTEGERVAL                      { $$.type = INTEGER_TYPE; $$.value = $1.value; }
        |   IDENTIFIER                      { if(!is_not_in_table($1, true)){ $$ = get_variable($1); } else {yyerror ("undeclared variable"); return 1;} }
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
        |   IDENTIFIER                      { if(getsym($1, true)->variable.type != BOOLEAN_TYPE){yyerror ("type mismatch"); return 1; }}
        ;   

declaration:INT IDENTIFIER                  { $$.type = INTEGER_TYPE; $$.name = strdup($2); $$.value = 0; }
        |   DOUBLE IDENTIFIER               { $$.type = DOUBLE_TYPE; $$.name = strdup($2); $$.value = 0.0; }
        |   BOOLEAN IDENTIFIER              { $$.type = BOOLEAN_TYPE; $$.name = strdup($2); $$.value = 0; }
        |   INT IDENTIFIER '=' numexpr      { 
                                                if($4.type == INTEGER_TYPE) {
                                                        $$.type = INTEGER_TYPE; $$.name = strdup($2); $$.value = $4.value;
                                                }
                                                else{ 
                                                    yyerror ("type error"); return 1;
                                                }
                                            }
        |   DOUBLE IDENTIFIER '=' numexpr   { 
                                                if($4.type == INTEGER_TYPE) {
                                                    $$.type = DOUBLE_TYPE; $$.name = strdup($2); $$.value = $4.value; 
                                                }
                                                else{
                                                    yyerror ("type error"); return 1;
                                                }
                                            }
        |   BOOLEAN IDENTIFIER '=' boolexpr { 
                                                if($4.type == BOOLEAN_TYPE) {
                                                    $$.type = BOOLEAN_TYPE; $$.name = strdup($2); $$.value = $4.value; 
                                                }
                                                else{
                                                    yyerror ("type error"); return 1;
                                                }
                                            }
       
assignment: IDENTIFIER '=' boolexpr            { if(areTypesComp(getsym($1, false)->variable, $3)) { getsym($1, false)->variable.value = $3.value; } else { yyerror("type mismatch"); return 1;}}
        |   IDENTIFIER '=' numexpr             { if(areTypesComp(getsym($1, false)->variable, $3)) { getsym($1, false)->variable.value = $3.value; } else { yyerror("type mismatch"); return 1;}}
        ;

%%

int main(void){
    yyparse();
    if(success)
    	printf("Parsing Successful\n");
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

bool areTypesComp(number sym1, number sym2){
//    printf("%d, %d", sym1.type, sym2.type);
    if(sym1.type == sym2.type){
        return true;
    }else if(sym1.type * sym2.type == 0){
        return false;
    }else if(sym1.type > sym2.type){
        return true;
    }else{
        return false;
    }

}

int yyerror(const char *msg){
    extern int yylineno;
	printf("Parsing Failed\nLine Number: %d %s\n",yylineno,msg);
    success = 0;
	return 0;
}