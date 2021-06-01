#include <stdio.h>

#define TYPE_ERROR -1
#define VOID_TYPE 0
#define BOOL_TYPE 1
#define INT_TYPE 2
#define DOUBLE_TYPE 3

// valid data types
char* type_name[] = {"void", "boolean", "integer", "double"};

// returns default value for each valid data type
double defaultValue(int type);

// true - operands are compatible, false - otherwise
bool typesAreCorrect(int type1, int type2, int operator);

// boolean operators - must be both boolean 
bool areTypesCompatible(int type1, int type2);

int max(int a, int b);

// return the correct value for the operation - apply type cohercion 
double getValue(int operator, int type, double val1, double val2);