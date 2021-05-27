yacc my.y -dv
lex my.l
gcc lex.yy.c y.tab.c
./a.out