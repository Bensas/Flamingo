#ifndef SYMBOL_TABLE
#define SYMBOL_TABLE

typedef struct symbolTable * symbolTableADT;

symbolTableADT createSymbolTable();
symbolTableADT addSymbolToTable(char * symbol, symbolTableADT table);
int isInSymbolTable(char * symbol, symbolTableADT table);
void freeSymbolTable(symbolTableADT table);

#endif