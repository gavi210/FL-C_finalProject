#include <stdlib.h>
#include <string.h>
#include <stdio.h>

typedef struct node
{
  char *name;               /* name of the variable                 */
  int type;                 /* 0 - boolean, 1 - integer, 2 - double */
  double value;             /* value hold by the variable           */
  struct node *sub_table;   /* subscope */
  struct node *prev;        /* pointer to previous inserted node    */
  struct node *parent;
} node;

node *sym_table; // pointer used to access the current symbol table - updated during parsing

// invoked at the beginning of the parsing - default table
node * initialize_table() {
  node * default_table; 
  default_table = (node *) malloc (sizeof(node));
  // initialize content - empty table
  default_table->parent = (node *)0;
  default_table->prev = (node *)0;
  default_table->sub_table = (node *)0;

  return default_table;
}

void enter_sub_table() {
  node * sub_table = initialize_table(); // initialize empty table
  sym_table->sub_table = sub_table;
  sub_table->parent = sym_table; // symmtric reference - only the initial node has reference to parent

  sym_table = sub_table;  // update pointer to sub scope
}

// 0 - successfully exited, -1 - error
int exit_sub_table() {
  if(sym_table->parent == (node *)0) { // trying exiting from default table - parsing error 
    //printf("Trying exiting from default symbol table... parsing error!\n");
    yyerror("Cannot exit from the base variable scope!");
    return -1;
  }
  sym_table = sym_table->parent; // switch back to parent
  return 0;
}

// insert new node - update global variable sym_table
void putsym (char *sym_name, int sym_type, double sym_value)
{
  node *new_node;
  new_node = (node *) malloc (sizeof(node));
  // assign fields
  new_node->name = (char *) malloc (strlen(sym_name)+1);
  strcpy (new_node->name,sym_name);
  new_node->type = sym_type;
  new_node->value = sym_value;
  // add new node as list head
  new_node->parent = sym_table->parent; // nodes in the table don't have reference to parent
  new_node->prev = (node *)sym_table;
  new_node->sub_table = (node *)0;

  sym_table = new_node; // update pointer to last inserted node
}

// pointer to node, (node *)0 pointer if element not found
node * getsym (char *sym_name) {
  node *curr_node = sym_table;
  while(curr_node->parent != (node *)0 || curr_node->prev != (node *)0) {
    // head of the list
    //if(curr_node->name == (node *)0)
    //  curr_node = curr_node->parent;
    if(curr_node->prev == (node *)0)
      curr_node = curr_node->parent;
    else if(strcmp (curr_node->name,sym_name) == 0) // names matches
      return curr_node; // node found
    else 
      curr_node = curr_node->prev;
  }

  // if here no value found
  return (node *)0;
}

// search in the current scope if variable with sym_name already decleared
bool already_decleared_in_scope(char *sym_name) {
  node *curr_node = sym_table;
  while(curr_node->prev != (node *)0) {
    if(strcmp (curr_node->name,sym_name) == 0)
      return true;
    else 
      curr_node = curr_node->prev;
  }

  // if here not found - not decleared in scope yet
  return false;
}

/* 
  return 0 - successfully inserted, -1 - error since name already in use
*/
int insert_variable (char *sym_name, int sym_type, double sym_value) {  
  // verifies whether the sym_name is currently available
  if (already_decleared_in_scope(sym_name))  {
    // name in use - return error - duplicate variable
    char *buffer = (char*)malloc(256 * sizeof(char));
    sprintf(buffer, "Variable %s already decleared in scope!", sym_name);
    //printf("Variable %s already decleared in scope!\n", sym_name);
    yyerror(buffer);
    return -1; 
  }
  else { 
    
    putsym (sym_name, sym_type, sym_value);
    return 0;
  }
}