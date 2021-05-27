%{

#include <stdio.h>
#include <ctype.h>
#include <string.h>

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
void addSymbolInt(char *name, int value);
void addSymbolDouble(char *name, double value);



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

%type <value> expr assignment

%left '+' '-'
%left '*' '/'

%%

program :   program expr '\n'               { printf("%d\n", $2.ival); }
        |   program assignment '\n'         { addSymbol($2); }
        |
        ;

expr    :   expr '+' expr                   { $$.ival = $1.ival + $3.ival; }
        |   expr '-' expr                   { $$.ival = $1.ival - $3.ival; }
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