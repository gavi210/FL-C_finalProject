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

struct list {
    
    struct list *parent;
    struct node *first;

};
typedef struct list list; 

struct node
{
  struct number *variable;
  struct node *next;      /* pointer to next node                 */
  struct list *subTable;
};

typedef struct node node; /* avoid writing struct to decleare pointer */

list main_table = {0,0}; // list of the list - default null since list empty

list *cur_table = &main_table;

// insert new node - returns pointer
node * putsym (number *newSymbol)
{
   // pointer to next entry
  node *new_node;
  new_node = (node *) malloc (sizeof(node));
  
  // assign fields - add node as head
  new_node->variable = newSymbol;
  new_node->next = cur_table->first;
  cur_table->first = new_node;

  return new_node;
}

// pointer to node, null pointer if not present
node * getsym (char *sym_name) {
  node *curr_node = cur_table->first;
  list *curr_table = cur_table;

  while(curr_node != (node *) 0 || curr_table->parent != (list *) 0) { // other elements to be analyzed remaining
    if(curr_node == (node *) 0) { // reached the end, but parent != null -> goes up with table and points to first element
      curr_table = curr_table->parent;
      curr_node = curr_table->first;
    }
    else if (strcmp (curr_node->variable->name,sym_name) == 0) // names matches
      return curr_node;
    else {
      curr_node = curr_node->next;
    }
  }
  return 0;
}

/* 
  return 0 - successfully inserted, -1 - error since name already in use
*/
int insert_variable (number *variable) {  
  node *table_entry;
  // not decleared in scope!
  table_entry = getsym (variable->name);

  // verifies whether the sym_name is currently available
  if (table_entry == 0)  {
    // name not in user - insert new node
    table_entry = putsym (variable);
    return 0; 
  }
  else { 
    printf("%s is already defined\n", variable->name);
    return -1;
  }
}

number *getVariable(char *sym_name){

    return getsym(sym_name)->variable;
}

// true - variable previously decleared 
bool has_been_decleared(char *sym_name) {
  return getsym(sym_name) != 0;
}

void makeSubTable(){

    list * newhead = (list *) malloc (sizeof(list));

    newhead->parent = cur_table;

    cur_table = newhead;

}

void deleteSubTable(){

    cur_table = cur_table->parent;
}

void print_table_rec(node *curr_node, int counter) {
  // printf("Inside table_rec... counter: %d\n", counter);
  if(curr_node == (node *) 0)
    return;

  // CURRENT NODE INFO
  char indent[counter];
  for (int i = 0; i < counter; i++)
    indent[i] = '\t'; 
  printf("%sName: %s, Type: %d, Value: %f\n", indent, curr_node->variable->name, curr_node->variable->type, curr_node->variable->value);

  // RECURSIVLY SUB TABLE
  if(curr_node->subTable != (list *) 0)
    print_table_rec(curr_node->subTable->first, counter + 1);
  else 
    printf("Subtable for variable %s is null!\n", curr_node->variable->name);
  // NEXT IN TABLE
  print_table_rec(curr_node->next, counter);
}

void print_table() {
  printf("printing table\n");
  print_table_rec(main_table.first, 0);
}
