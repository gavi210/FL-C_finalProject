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

struct head {
    
    struct head *parent;
    struct node *first;

};
typedef struct head head; 

struct node
{
  struct number variable;
  struct node *next;      /* pointer to next node                 */
  struct head *subTable;
};

typedef struct node node; /* avoid writing struct to decleare pointer */

head first_table = {0,0}; // head of the list - default null since list empty

head *cur_table = &first_table;


// insert new node - returns pointer
node * putsym (number newSymbol)
{
   // decleare pointer to next entry
  node *new_node;

  new_node = (node *) malloc (sizeof(node));
  // assign fields
  new_node->variable = newSymbol;

  new_node->next = cur_table->first;

  cur_table->first = new_node;

  printf("%d", new_node->next);

  return new_node;
}

// pointer to node, null pointer if not present
node * getsym (char *sym_name) {

  node *curr_node;

  curr_node = cur_table->first;

  do
  {
    if (strcmp (curr_node->variable.name,sym_name) == 0) // names matches
      return curr_node;
    
    curr_node = curr_node->next;

    if(curr_node == (node *)0){
      printf("aisodasoid");
    }
  }while (curr_node != (node *)0);

  return 0;
  

  /*
  for (curr_node = cur_table->first; curr_node != (node *) 0; curr_node = (node *)curr_node->next)

    if (strcmp (curr_node->variable.name,sym_name) == 0) // names matches
      return curr_node;
  return 0;
  */
}

/* 
  return 0 - successfully inserted, -1 - error since name already in use
*/
int insert_variable (number variable) {  

  node *table_entry;
  table_entry = 0;

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

void makeSubTable(){

    head * newhead = (head *) malloc (sizeof(head));

    newhead->parent = cur_table;

    cur_table = newhead;

}

void deleteSubTable(){

    cur_table = cur_table->parent;

}