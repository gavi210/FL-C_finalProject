#include <stdlib.h>
#include <stdio.h>

extern char *type_name[];
extern struct node *getsym(char *sym_name);
extern char *inputFileName; // needed for the 


char * getTypeValueDescription(int type, double value) {

  char *buffer = (char*)malloc(256 * sizeof(char));

  switch(type) {
    case VOID_TYPE: 
      sprintf(buffer, "Type: %s", type_name[type]);
      break;
    case BOOL_TYPE:
      sprintf(buffer, "Type: %s, Value: %d", type_name[type], value!=0.0);
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

  return buffer;
}

// customize output based on type
void printExpressionResult(int type, double value) {
  char *output_str = getTypeValueDescription(type, value);

  printf("%s\n", output_str);
  return;
}

void printVarDescription(char *sym_name) {
  node *table_entry = getsym(sym_name);
  if (table_entry == (node *)0)  {
    printf("Variable %s still not defined!\n", sym_name); 
  }
  else { 
    char *output_str = getTypeValueDescription(table_entry->type, table_entry->value);
    printf("Name: %s, %s\n", table_entry->name, output_str);
  }
  return;
}

/* 
  string generator for the error location - location for the error always returned 
  differentiate among parsing and semantic error
*/
char * location_error_str() {
  char *buffer = (char*)malloc(256 * sizeof(char));   
  sprintf(buffer, "%s:%d:%d", inputFileName, yylloc.first_line, yylloc.first_line);   
  return buffer;    
}

