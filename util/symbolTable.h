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
node * initialize_table();

void enter_sub_table();

// 0 - successfully exited, -1 - error
int exit_sub_table();

// insert new node - update global variable sym_table
void putsym (char *sym_name, int sym_type, double sym_value);

// pointer to node, (node *)0 pointer if element not found
node * getsym (char *sym_name);

// search in the current scope if variable with sym_name already decleared
bool already_decleared_in_scope(char *sym_name);

/* 
  return 0 - successfully inserted, -1 - error since name already in use
*/
int insert_variable (char *sym_name, int sym_type, double sym_value);