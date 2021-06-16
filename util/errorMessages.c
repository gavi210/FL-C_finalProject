/*
  returns a string in the form <file_name>:<line>:<column>
*/
char *location_error_str()
{
  char *buffer = (char *)malloc(256 * sizeof(char));
  sprintf(buffer, "%s:%d:%d", inputFileName, yylloc.first_line, yylloc.first_column);
  return buffer;
}

/*
  sequence of ~^ to highlight the error position. '^' identifies the actual position
*/
char *highlight_error_position_str()
{
  char *str = (char *)malloc(sizeof(char) * yylloc.first_column);

  for (int i = 0; i < yylloc.first_column - 1; i++)
    str[i] = '~';

  str[yylloc.first_column - 1] = '^';

  char *buffer = (char *)malloc(1024 * sizeof(char));
  sprintf(buffer, "%s%s%s", GREEN, str, WHITE); // apply color to output

  return buffer;
}

char * error_line_str()
{

  char *buffer = (char *)malloc(sizeof(char) * 1024); // stores the error line
  int ix = 0;                                         // next free position in buffer

  if (yyin != stdin) // yyin should not be stdin, but left in the code to increase robustness
  {
    FILE *file = fopen(inputFileName, "r"); // reopen program file, scan it indipendently from the parser
    
    int lines_to_be_discarded = yylloc.first_line - 1; // useless lines, previous the error

    char ch = getc(file);

    while (lines_to_be_discarded > 0)
    {
      while (ch != '\n' && ch != EOF) // discard useless lines
        ch = getc(file);

      // should not be EOF -> deals with error situation to increase robustness
      if (ch == EOF)
        printf("Error retrieving error_line. Counter: %d, but encountered EOF!\n", lines_to_be_discarded);
      else
      {
        lines_to_be_discarded--;
        ch = getc(file); // read first character of the new line
      }
    }

    // ch points to first character of erroneous line

    while (ch != '\n' && ch != EOF) // copy line to buffer char by char
    {
      buffer[ix] = ch;
      ch = getc(file);
      ix++;
    }
  }

  buffer[ix] = '\0'; // mark end of line in the buffer
  return buffer;
}

/*
  returns string representing the error message
*/
char *error_descrition_str(char const *message)
{

  char *buffer = (char *)malloc(1024 * sizeof(char));
  sprintf(buffer, "%s%s: %serror: %s%s%s", BOLD, location_error_str(), RED, NO_BOLD, WHITE, message);

  return buffer;
}