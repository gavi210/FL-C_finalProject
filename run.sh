flex -l calc-lex.l
yacc -vd calc-yacc.y
gcc y.tab.c -ly -ll
./a.out sample_programs/cond_stmt/b.txt