flex -l lexical_analyzer.l
yacc -vd parser.y
gcc y.tab.c -ly -ll