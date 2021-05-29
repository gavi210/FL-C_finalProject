#include <stdlib.h>
#include <stdio.h>

extern char *type_name[];
extern struct node *getsym(char *sym_name);

char * getTypeValueDescription(int type, double value) {
  char buffer[1024];
  switch(type) {
    case VOID_TYPE: 
      snprintf(buffer, sizeof(buffer), "Type: %s, so far successfully parsed input!\n", type_name[type]);
      break;
    case BOOL_TYPE:
      snprintf(buffer, sizeof(buffer), "Type: %s, Value: %d\n", type_name[type], value!=0.0);
      break;
    case INT_TYPE: 
      snprintf(buffer, sizeof(buffer), "Type: %s, Value: %d\n", type_name[type], (int) value);
      break;
    case DOUBLE_TYPE:
      snprintf(buffer, sizeof(buffer), "Type: %s, Value: %f\n", type_name[type], value);
      break;
    default: 
      snprintf(buffer, sizeof(buffer), "No valid type specified!\n");
  }

  return buffer;
}

// customize output based on type
void printExpressionResult(int type, double value) {
  char buffer[1024] = getTypeValueDescription(type, value);

  printf("%s\n", buffer);
  return;
}

void printVarDescription(char *sym_name) {
  node *table_entry = getsym(sym_name);
  if (table_entry == (node *)0)  {
    printf("Variable %s still not defined!", sym_name); 
  }
  else { 
    char buffer[1024] = getTypeValueDescription(table_entry->type, table_entry->value);
    printf("Name: %s, %s\n", table_entry->name, buffer);
  }
  return;
}