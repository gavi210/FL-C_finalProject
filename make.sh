yacc calc.y -dv
flex calc.l
gcc lex.yy.c y.tab.c -lfl -lm 
./a.out