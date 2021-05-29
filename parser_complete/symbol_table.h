#include <stdio.h>
#include <ctype.h>

struct symrec{
    char* name;             /*symbol name */
    int type;               /* bool -> 0, integer -> 1, float -> 2 */
    union{
        int ival;
        double dval;
        bool bval;
    };
    struct symrec *next;    /* pointer to the next node since it is a linked list */
};

typedef struct symrec symrec;

symrec *sym_table = (symrec *)0;
symrec *putsymbool();
symrec *putsymint();
symrec *putsymdouble();
symrec *getsym();

symrec * putsymint(char *sym_name, int type, int val){

    symrec *ptr;
    ptr = (symrec *) malloc (sizeof(symrec));
    ptr$->$name = (char *) malloc (strlen(sym_name)+1);
    strcpy (ptr$->$name,sym_name);
    ptr$->$next = (struct symrec *)sym_table;
    sym_table = ptr;
    return ptr;

}


symrec * putsym ( char *sym_name )
{
  symrec *ptr;
  ptr = (symrec *) malloc (sizeof(symrec));
  ptr$->$name = (char *) malloc (strlen(sym_name)+1);
  strcpy (ptr$->$name,sym_name);
  ptr$->$next = (struct symrec *)sym_table;
  sym_table = ptr;
  return ptr;
}
symrec * getsym ( char *sym_name )
{
  symrec *ptr;
  for (ptr = sym_table; ptr != (symrec *) 0;
       ptr = (symrec *)ptr$->$next)
    if (strcmp (ptr$->$name,sym_name) == 0)
      return ptr;
  return 0;
}
