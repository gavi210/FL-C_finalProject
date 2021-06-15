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

struct head {
    
    struct head *parent;
    struct node *first;

};
typedef struct head head; 

struct node
{
  struct number variable;
  struct node *next;      /* pointer to next node  */
  struct head *subTable;
};
typedef struct node node; 


head first_table = {NULL, NULL};

head *symbol_table = &first_table;


/* function declaration */

node * putsym (number newSymbol);
node * getsym (char *sym_name, bool local);
int insert_variable (number variable);
bool is_not_in_table(char *sym_name, bool local);
void makeSubTable();
void deleteSubTable();

node * putsym (number newSymbol)
{
    // decleare pointer to next entry
    node *new_node;

    new_node = (node *) malloc (sizeof(node));
    // assign fields
    new_node->variable = newSymbol;

    // if the symbol_table is initialized
    if(symbol_table->first){
        new_node->next = symbol_table->first;
    }

    symbol_table->first = new_node;

    return new_node;
}

// pointer to node, null pointer if not present
node * getsym (char *sym_name, bool local) {

    node * curr_node = symbol_table->first;
    head * curr_table = symbol_table;

    while(curr_node != (node *)0 || curr_table->parent != (head *) 0){
        if(curr_node == (node *)0 && local){
            return 0;
        }
        else if(curr_node == (node *)0 && !local){
            curr_node = curr_table->parent->first;
            curr_table = curr_table->parent;
        }
        if(strcmp (curr_node->variable.name,sym_name) == 0) {
            return curr_node;
        }
        curr_node = curr_node->next;
    }

    return 0;

}

/* 
  return 0 - successfully inserted, -1 - error since name already in use
*/
int insert_variable (number variable) {  

  if (is_not_in_table(variable.name, true))  {
    putsym (variable);
    return 0; 
  }
  else { 
    printf("%s is already defined\n", variable.name);
    return -1;
  }
}

number get_variable(char *variable_name){
    return getsym(variable_name, false)->variable;
}

bool is_not_in_table(char *sym_name, bool local) {
  return getsym(sym_name, local) == 0;
}

void makeSubTable(){
    head * newhead = (head *) malloc (sizeof(head));
    newhead->parent = symbol_table;
    newhead->first = NULL;
    symbol_table = newhead;
}

void deleteSubTable(){
    symbol_table = symbol_table->parent;
}
