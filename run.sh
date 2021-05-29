flex -l lexical_analyzer.l
yacc -vd parser.y
gcc y.tab.c -ly -ll
./a.out tests/cond_stmt/b.txt