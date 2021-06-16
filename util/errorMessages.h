/* constants to customize output messages - stdout only */
#define BOLD         "\033[1m"
#define NO_BOLD      "\033[22m"
#define RED  "\x1B[31m"
#define GREEN  "\x1B[32m"
#define YELLOW  "\x1B[33m"
#define BLUE  "\x1B[34m"
#define WHITE  "\x1B[37m"

/*
  generates the string to inform the user about the position of the error in the program
*/
char * location_error_str();

/*
  generates the sequence of ~^ to highlight the position of the error in the line
*/
char * highlight_error_position_str();

/*
  returns a copy of the program line containing the error
*/
char * error_line_str();

/*
  generates the stirng describing the error reason
*/
char * error_descrition_str();

