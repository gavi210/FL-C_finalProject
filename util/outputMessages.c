#include <stdlib.h>
#include <stdio.h>

extern char *type_name[];
extern FILE *output_stream;
extern void yyerror();

void dumpExpression(int type, double value) {
  char *buffer = (char*)malloc(256 * sizeof(char));

  switch(type) { // depending on the type, the value is printed in a different way
    case VOID_TYPE: 
      sprintf(buffer, "Type: %s", type_name[type]); // no value printed - VOID has no value associated
      break;
    case BOOL_TYPE:
      if(value == 1.0) // 1.0 stands for truthness
        sprintf(buffer, "Type: %s, Value: true", type_name[type]);
      else 
        sprintf(buffer, "Type: %s, Value: false", type_name[type]);
      break;
    case INT_TYPE: 
      sprintf(buffer, "Type: %s, Value: %d", type_name[type], (int) value);
      break;
    case DOUBLE_TYPE:
      sprintf(buffer, "Type: %s, Value: %f", type_name[type], value);
      break;
    default: 
      sprintf(buffer, "No valid type specified!");
  }

  printMessage(buffer);
  return;
}

/* generates 'incompatible types error' message, stating the two types involved that don't match  */
void throwIncompatibleTypeError(char* operator, int type1, int type2) {
  char buffer[1024]; 
  snprintf(buffer, sizeof(buffer), "Operation '%s' is not applicabile with %s and %s!\n", operator, type_name[type1], type_name[type2]);

  yyerror(buffer);
  return;
}

/* prints the output message to the output stream */
void printMessage(char* message) {
  fprintf(output_stream, "%s\n", message);
  return;
}