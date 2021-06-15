#define RED  "\x1B[31m"
#define GREEN  "\x1B[32m"
#define YELLOW  "\x1B[33m"
#define BLUE  "\x1B[34m"
#define WHITE  "\x1B[37m"

char *inputFileName; // needed for the 

char * getTypeValueDescription(int type, double value);

// customize output based on type
void printExpressionResult(int type, double value);

void dumpVar(char *sym_name);

void printIncompatibleTypesError(char* operator, int type1, int type2);

void printMessage(char* message);