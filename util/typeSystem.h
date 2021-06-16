/*
  This file contains the declaration of method and constants to implement the type system for the developed programming language
*/

#include <stdio.h>

#define TYPE_ERROR -1

/* 
  Values for the types have been decleared this way, since each type could be considered as a subset of the following one.
  Therefore, it will be useful to have the values for the type constants sorted in the same order as the set of values they represent  
*/
#define VOID_TYPE 0
#define BOOL_TYPE 1
#define INT_TYPE 2
#define DOUBLE_TYPE 3

/* 
  translation array. Values associated to type constants is used as the index to get the correspondent type name 
*/
char* type_name[] = {"void", "boolean", "integer", "double"};

/* returns default value for each valid data type */
double defaultValue(int type);

/* checks whether the types involved with the expresion are correct w.r.t. the operator  */
bool typesAreCorrect(int type1, int type2, int operator);

/* checks whether the types are compatible, that is, whether one could be cast to the other, should they not be the same */ 
bool areTypesCompatible(int type1, int type2);

int max(int a, int b);

/* 
  evaluated the expression result depending on the operator the type involved.
  When possible, type cohercion is applied 
*/
double getValue(int operator, int type, double val1, double val2);