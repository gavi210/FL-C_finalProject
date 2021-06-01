char *inputFileName; // needed for the 

char * getTypeValueDescription(int type, double value);

// customize output based on type
void printExpressionResult(int type, double value);

void dumpVar(char *sym_name);

void printIncompatibleTypesError(char* operator, int type1, int type2);