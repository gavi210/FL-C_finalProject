%{
#include "ka.yacc.tab.h"
void yyerror (char *s);
int yylex();
%}

%%
"print"				   {return print;}
"exit"				   {return exit_cmd;}
[a-zA-Z]			   {yylval.id = yytext[0]; return identifier;}
[0-9]+                 {yylval.num = atoi(yytext); return number;}
[ \t\n]                ;
[-+=]           	   {return yytext[0];}
;                      {return semicolon;}   
                   
.                      {ECHO; yyerror ("unexpected character");}

%%
int yywrap (void) {return 1;}