/*
  In this file are decleared the support methods that generate and print informative messages about
  the expressions evaluated by the compiler.
*/

/* Prints type and value for the given expression. The method customizes the output string to better print the expression value  */
void dumpExpression(int type, double value);

/* Should and expression cannot be evaluated due to incompatible types, the method generates the correspondent informative error
   message */
void throwIncompatibleTypeError(char* operator, int type1, int type2);

/* Support methods to print the input message to the 'output_stream' */
void printMessage(char* message);