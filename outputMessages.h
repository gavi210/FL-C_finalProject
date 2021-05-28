#include <stdlib.h>
#include <stdio.h>

extern char *type_name[];
extern struct node *getsym(char *sym_name);

// output adapts to variable type
void printResult(int type, double value) {
  char buffer[1024];
  if(type == 0) // boolean
    snprintf(buffer, sizeof(buffer), "Type: %s, Value: %d\n", type_name[type], value!=0.0);
  else if(type == 1) // integer
    snprintf(buffer, sizeof(buffer), "Type: %s, Value: %d\n", type_name[type], (int) value);
  else // double
    snprintf(buffer, sizeof(buffer), "Type: %s, Value: %f\n", type_name[type], value);

  printf("%s\n", buffer);
  return;
}

void nodeToString(char *sym_name) {
  node *table_entry = getsym(sym_name);
  if (table_entry == 0)  {
    printf("Variable %s not defined!", sym_name); 
  }
  else { 
    char buffer[1024];
    if(table_entry->type == 0) // boolean
      snprintf(buffer, sizeof(buffer), "Name: %s, Type: %s, Value: %d\n", sym_name, type_name[table_entry->type], table_entry->value!=0.0);
    else if(table_entry->type == 1) // integer
      snprintf(buffer, sizeof(buffer), "Name: %s, Type: %s, Value: %d\n", sym_name, type_name[table_entry->type], (int) table_entry->value);
    else // double
      snprintf(buffer, sizeof(buffer), "Name: %s, Type: %s, Value: %f\n", sym_name, type_name[table_entry->type], table_entry->value);

  printf("%s\n", buffer);
  }
}