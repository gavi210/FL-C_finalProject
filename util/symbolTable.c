#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdbool.h>

table_obj * initialize_table() {
  table_obj *default_table = (table_obj *) malloc(sizeof(table_obj)); 
  // set to null pointers
  default_table->parent = (table_obj *) 0;
  default_table->first = (table_node *) 0;

  return default_table;
}

void enter_sub_table() {
    table_obj * newHead = (table_obj *) malloc (sizeof(table_obj));
    newHead->parent = sym_table;
    newHead->first = NULL;
    sym_table = newHead;
}

int exit_sub_table() {
  if(sym_table->parent == (table_obj *) 0) {
    yyerror("Cannot exit from default variable scope!");
    return -1; // error
  }
  else {
    sym_table = sym_table->parent;
    return 0;
  }
}

void putvar (variable *var) {
  table_node *new_node; // decleare pointer to next entry
  new_node = (table_node *) malloc (sizeof(table_node));

  // assign content
  new_node->var = var;

  if(sym_table->first){ // if there are already variables stored (check could be avoided(?))
      new_node->next = sym_table->first;
  }

  sym_table->first = new_node; // add as table_obj
}


/* 
  returns the variable identified by the sym_name.
  parameter 'local' determines the scope of the search: 
    - local = true -> variable searched in the current scope
    - local = false -> the search spans to the parent scopes too
 */
variable * getvar (char *var_name, bool local) {

    table_node * curr_node = sym_table->first;
    table_obj * curr_table = sym_table;

    while(curr_node != (table_node *)0 || curr_table->parent != (table_obj *) 0){
        if(curr_node == (table_node *)0 && local){ // search limited to current scope - cannot go to parent
            return (variable *)0; // element not found
        }
        else if(curr_node == (table_node *)0 && !local){ // search allowed in the parent scope
            curr_node = curr_table->parent->first;
            curr_table = curr_table->parent; // reassign table_node and check != null again
        }
        // here sure curr_node != null
        else if(strcmp (curr_node->var->name, var_name) == 0) {
            return curr_node->var;
        }
        else 
          curr_node = curr_node->next;
    }
    
    // if here no value found
    char *buffer = (char*)malloc(256 * sizeof(char));
    sprintf(buffer, "Variable %s has not been defined!", var_name);
    yyerror(buffer);
    return (variable *)0;
}

/* 
  safe insertion method: checks whether the variable has already been decleared prior to insert the new var - avoid duplicates
*/
int insert_variable(char *sym_name, int sym_type, double sym_value) {  

  if (already_decleared_in_scope(sym_name)) { // variable not prev decleared in current scope
    char *buffer = (char*)malloc(256 * sizeof(char));
    sprintf(buffer, "Variable %s already decleared in this scope!", sym_name);
    yyerror(buffer);
    return -1;  
  }
  else { 
    // instantiate variable 
    variable *var = (variable *) malloc(sizeof(variable));
    var->name = sym_name;
    var->type = sym_type;
    var->value = sym_value;
    putvar(var);
    return 0; 
  }
}

// search in the current scope if variable with sym_name already decleared
bool already_decleared_in_scope(char *var_name) {
  table_node *curr_node = sym_table->first;
  while(curr_node != (table_node *)0) { // loop until element found
    if(strcmp (curr_node->var->name,var_name) == 0) // matches
      return true;
    else 
      curr_node = curr_node->next;
  }
  // if here not found - not decleared in scope yet
  return false;
}
