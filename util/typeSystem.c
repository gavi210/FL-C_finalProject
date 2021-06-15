#include <stdio.h>
#include <stdbool.h>

// returns default value for each valid data type
double defaultValue(int type) {
  if(type == BOOL_TYPE)
    return 1.0;
  else
    return 0.0; 
}

// true - operands are compatible
// false - operands not compatible
bool typesAreCorrect(int type1, int type2, int operator) {
  // binary arithmetic operators
  if(operator == PLUS || operator == MINUS || operator == MOLT || operator == DIV) {
    if(type1 > BOOL_TYPE  && type2 > BOOL_TYPE) // both numeric
      return true;
    else
      return false;
  }
  // unary arithmetic operators
  else if(operator == UMINUS) {
    if(type1 > BOOL_TYPE) // look only at the first one, second meaningless
      return true;
    else
      return false;
  }
  // binary boolean operators
  else if(operator == BIGGER_THAN || operator == BIGGER_EQ_THAN || operator == SMALLER_THAN || operator == SMALLER_EQ_THAN || operator == EQUAL_TO || operator == NOT_EQUAL_TO) {
    if(type1 > BOOL_TYPE && type2 > BOOL_TYPE) // boolean operators applied over numeric types
      return true;
    else
      return false;
  }
  // unary boolean operators
  else if(operator == NOT) {
    if(type1 == BOOL_TYPE) // look only at the first one, second meaningless
      return true;
    else
      return false; 
  }

  // other cases return false
  return false;
};

// boolean operators - must be both boolean 
// otherwise accept any combination of int and
bool areTypesCompatible(int type1, int type2) {

  if(type1 == BOOL_TYPE || type2 == BOOL_TYPE) { // at least on boolean 
    if(type1 == type2)   // even the other must be boolean
      return true;
    else {
      char *buffer = (char*)malloc(256 * sizeof(char));
      sprintf(buffer, "Types %s and %s are not compatible!", type_name[type1], type_name[type2]);
      yyerror(buffer);
      return false;
    }
  }
  else if(type1 == type2) { // equal - both int or both double
    return true;
  }
  else if(type1 > type2)  // first double - other int
    return true;
  else {
    char *buffer = (char*)malloc(256 * sizeof(char));
    sprintf(buffer, "Types %s and %s are not compatible!", type_name[type1], type_name[type2]);
    yyerror(buffer);
    return false; // first int - other double
  }
}

// return max value from a and b - if int (1) and duoble (2) - returns double (2)
int max(int a, int b) {

  if(a >= b)
    return a;
  else 
    return b;
}

// return the correct value for the operation - apply type cohercion 
double getValue(int operator, int type, double val1, double val2) {
  double result;
  if(operator == DIV) {
    if(type == INT_TYPE) 
      result = (int) val1 / (int) val2; // cast before computing result - integer division
    else
      result = val1 / val2; // standard division
  }
  else if(operator == MOLT) {
    result = val1 * val2;
  } 
  else if(operator == PLUS) {
    result = val1 + val2;
  }
  else
    result = val1 - val2;

  return result;
}