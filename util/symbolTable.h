#include <stdlib.h>
#include <string.h>
#include <stdio.h>

/* content of the variable */
struct variable {
    double value;
    int type;
    char *name;
};
typedef struct variable variable;

/* entry in the table, node in the list of variables */
struct table_node
{
  struct variable *var;
  struct table_node *next;      /* pointer to next table_node  */
};
typedef struct table_node table_node; 

/* struct encapsulating the list of table_nodes keeping information about the variables decleared in the scope */
struct table_obj {
    struct table_obj *parent; /* pointer to parent table_obj */  
    struct table_node *first;
};
typedef struct table_obj table_obj; 

/* global variable - reference to current table for the current scope */
table_obj *sym_table; 


/* METHOD PROTOTYPES */

/* initialize default symbol table */
table_obj * initialize_table();

/* from current table, decleare and enter the sub one */
void enter_sub_table();

/* exit from current subscope 
  return: 
    - 0 : ok
    - 1 : error
*/
int exit_sub_table();

/* 
  store new variable in the current table (scope)
*/
void putvar (variable *var);

// pointer to node, (node *)0 pointer if element not found
variable * getvar (char *sym_name, bool local);

// search in the current scope if variable with sym_name already decleared
bool already_decleared_in_scope(char *sym_name);

/* 
  return 0 - successfully inserted, -1 - error since name already in use
*/
int insert_variable (char *sym_name, int sym_type, double sym_value);