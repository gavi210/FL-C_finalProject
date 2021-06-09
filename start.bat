cls
bison -dv ka.yacc.y
flex dura.lex.l
gcc lex.yy.c ka.yacc.tab.c -lm
a.exe