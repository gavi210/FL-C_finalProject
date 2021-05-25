flex -l c.lex.l
yacc -vd c.yacc.y
gcc y.tab.c -ly -ll
./a.out