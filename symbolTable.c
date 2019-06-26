#include "symbolTable.h"
#include <stdlib.h>
#include <string.h>

#define MEM_BLOCK 128

static int symbolTableIsFull(symbolTableADT table);
static symbolTableADT augmentSymbolTable(symbolTableADT table);
static void copySymbolTable(symbolTableADT source, symbolTableADT dest);

struct symbolTable {
    char ** table;
    int size;
    int index;
} symbolTable;

typedef struct symbolTable tSymbolTable;

symbolTableADT createSymbolTable() {
    symbolTableADT ret = (symbolTableADT)malloc(sizeof(struct symbolTable));
    ret->table = (char**)malloc(sizeof(char*)*MEM_BLOCK);
    ret->size = 1;
    ret->index = 0;
    return ret;
}

symbolTableADT addSymbolToTable(char * symbol, symbolTableADT table) {
    symbolTableADT ret = table;
    if(symbolTableIsFull(table)) {
        ret = augmentSymbolTable(table);
    }
    ret->table[ret->index] = strdup(symbol);
    ret->index += 1;
    return ret;
}

static int symbolTableIsFull(symbolTableADT table) {
    return (table->index + 1) == (table->size);
}

static symbolTableADT augmentSymbolTable(symbolTableADT table) {
    symbolTableADT ret = createSymbolTable(table->size + MEM_BLOCK);
    copySymbolTable(table, ret);
    free(table->table);
    free(table);
    return ret;
}

static void copySymbolTable(symbolTableADT source, symbolTableADT dest) {
    for(int i = 0; i < source->index; i++) {
        dest->table[i] = source->table[i];
    }
    dest->index = source->index;
    dest->size = source->size;
}

int isInSymbolTable(char * symbol, symbolTableADT table) {
    for(int i = 0; i < table->index; i++) {
        if(strcmp(symbol, table->table[i]) == 0) {
            return 1;
        }
    }
    return 0;
}

void freeSymbolTable(symbolTableADT table) {
    for(int i = 0; i < table->index; i++) {
        free(table->table[i]);
    }
    free(table->table);
    free(table);
}