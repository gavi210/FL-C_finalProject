/* This file contains macros to support location tracking, or the current token being read by the Parser */

/* Initialize yylloc */
# define LOCATION_RESET(Loc)                  \
  (Loc).first_column = (Loc).first_line = 1;  \
  (Loc).last_column =  (Loc).last_line = 1;

/* Advance of NUM lines - '\n' char read */
# define LOCATION_ADV_LINE(Loc)             \
  (Loc).last_column = 1;                    \
  (Loc).last_line += 1;                     

/* Advance of NUM column - new token read */
#define LOCATION_ADV_COLUMNS(Loc, Num, Line, NextToken, yytext)     \
  (Loc).last_column += Num;                                         \

/* Restart: move the first cursor to the last position. */
# define LOCATION_STEP(Loc)                   \
  (Loc).first_column = (Loc).last_column;     \
  (Loc).first_line = (Loc).last_line;