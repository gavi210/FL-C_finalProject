#include "table.c"

number *generateNumberObj(char userInput[]) {
  char *ptr = strtok(userInput, " "); // discard the initial 

  double value = atof(strtok(NULL, " "));
  int type = atoi(strtok(NULL, " "));
  char *name_original = strtok(NULL, " ");
  char *name = (char*) malloc(sizeof(name_original));
  strcpy(name, name_original);
  name[strlen(name)-1] = '\0';  // discard the last \n

  //printf("Value: %f, Type: %d, Name: %s\n", value, type, name);

  number * new_number; 
  new_number = (number *) malloc(sizeof(number));

  new_number->value = value;
  new_number->type = type;
  new_number->name = name;

  return new_number;
}

int main() {
  char userInput[256];
  char delim[] = " ";

  printf("Variable specification: [c,h,p] [value] [type] [name]\n");

  while(strncmp(userInput, "EXIT", 4) != 0) {
    print_table();
    fgets(userInput, sizeof(userInput), stdin);

    //printf("Read input: %s", userInput);

    // depending on the action
    switch(userInput[0]) {
      case 'c': // children -> enter sub scope
        {
          makeSubTable(); // enter sub-scope
          insert_variable(generateNumberObj(userInput));
        }
        break;
      case 'h':
        // add as head 
        {
        number *new_number = generateNumberObj(userInput);
        insert_variable(new_number);
        }
        break;
      case 'p':
        // exit form sub scope
        deleteSubTable();
        insert_variable(generateNumberObj(userInput));
        break;
      default:
        ;
    }
  }


}
