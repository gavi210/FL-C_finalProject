#include <stdio.h>

// print parsing error
int yyerror (char const *message)
{
  return fprintf (stderr, "%s\n", message);
  fputs (message, stderr);
  fputc ('\n', stderr);
  return 0;
}

// prototype for yylex function - produced by compling lex.l file
int yylex(void);

// on EOF - stop scanning - code 1 -> stop reading
int yywrap() {
      return 1;
}
