#include <stdlib.h>
#include <string.h>
#include <stdio.h>

/*
  Nodes linked together storing information about the different variables
*/
struct node
{
  char *name;             /* name of the variable                 */
  int type;               /* 0 - boolean, 1 - integer, 2 - double */
  double value;           /* value hold by the variable           */
  struct node *next;      /* pointer to next node                 */
};

typedef struct node node; /* avoid writing struct to decleare pointer */

node *sym_table = (node *)0; // head of the list - default null since list empty

// insert new node - returns pointer
node * putsym (char *sym_name, int sym_type, double sym_value)
{
   // decleare pointer to next entry
  node *new_node;
  new_node = (node *) malloc (sizeof(node));
  // assign fields
  new_node->name = (char *) malloc (strlen(sym_name)+1);
  strcpy (new_node->name,sym_name);
  new_node->type = sym_type;
  new_node->value = sym_value;
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
    if (strcmp (curr_node->name,sym_name) == 0) // names matches
      return curr_node;
  return 0;
}

/* 
  return 0 - successfully inserted, -1 - error since name already in use
*/
int insert_variable (char *sym_name, int sym_type, double sym_value) {  
  node *table_entry;
  table_entry = getsym (sym_name);

  // verifies whether the sym_name is currently available
  if (table_entry == 0)  {
    // name not in user - insert new node
    table_entry = putsym (sym_name, sym_type, sym_value);
    return 0; 
  }
  else { 
    printf("%s is already defined\n", sym_name);
    return -1;
  }
}

// true - variable previously decleared 
bool has_been_decleared(char *sym_name) {
  return getsym(sym_name) != 0;
}
