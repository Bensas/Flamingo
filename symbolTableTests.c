#include <assert.h>
#include <stdio.h>
#include "symbolTable.h"

int main(void) {
    symbolTableADT testTable = createSymbolTable();
    testTable = addSymbolToTable("symbolA",testTable);
    assert(isInSymbolTable("symbolA", testTable));
    testTable = addSymbolToTable("symbolB", testTable);
    assert(isInSymbolTable("symbolB", testTable));
    assert( ! isInSymbolTable("symbolC", testTable));
    freeSymbolTable(testTable);
    printf("All tests ran successfully\n");
}