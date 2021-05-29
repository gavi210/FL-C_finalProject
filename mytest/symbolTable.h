#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdbool.h>

struct number{
    double value;
    int type;
    char *name;
};
typedef struct number number;

/*
  Nodes linked together storing information about the different variables
*/
struct node
{
  struct number variable;
  struct node *next;      /* pointer to next node                 */
};

typedef struct node node; /* avoid writing struct to decleare pointer */

node *sym_table = (node *)0; // head of the list - default null since list empty

// insert new node - returns pointer
node * putsym (number newSymbol)
{
   // decleare pointer to next entry
  node *new_node;

  new_node = (node *) malloc (sizeof(node));
  // assign fields
  new_node->variable = newSymbol;

  // add new node as list head
  new_node->next = (struct node *)sym_table;
  sym_table = new_node;
  return new_node;
}

// pointer to node, null pointer if not present
node * getsym (char *sym_name) {
  node *curr_node;
  for (curr_node = sym_table; curr_node != (node *) 0;
       curr_node = (node *)curr_node->next)
    if (strcmp (curr_node->variable.name,sym_name) == 0) // names matches
      return curr_node;
  return 0;
}

/* 
  return 0 - successfully inserted, -1 - error since name already in use
*/
int insert_variable (number variable) {  

  
  node *table_entry;
  table_entry = getsym (variable.name);

  // verifies whether the sym_name is currently available
  if (table_entry == 0)  {
    // name not in user - insert new node
    table_entry = putsym (variable);
    return 0; 
  }
  else { 
    printf("%s is already defined\n", variable.name);
    return -1;
  }
}

number getVariable(char *sym_name){

    node *pointer = getsym(sym_name);
    return pointer->variable;

}

// true - variable previously decleared 
bool has_been_decleared(char *sym_name) {
  return getsym(sym_name) != 0;
}

/*
void printVariable(char *sym_name){
    node *pointer = getsym(sym_name);
    if (pointer == 0)  {
        printf("undefinded");
    }
  else { 
    
    number variable = pointer->variable;
    if(variable.type == '1'){
        printf("type: %c, name: %s, value: %hi\n", variable.type, variable.name, variable.value);
    }else{
        printf("type: %c, name: %s, value: %f\n", variable.type, variable.name, variable.value);
    }
    
  }
}*/