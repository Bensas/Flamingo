#include <stdio.h>
#include <stdlib.h>
#include "hashmap.h"
#include "parser.h"

map_t map=NULL;

void init_parser()
{
    map=hashmap_new();
}

int is_declared(char * key)
{
    any_t pointer=malloc(sizeof(*pointer));
    int result=hashmap_get(map,key,pointer);
    free(pointer);
    if(result==MAP_OK)
        return DECLARED;
    return UNDECLARED;
}

// Stores pair key-value. Returns undeclared if there was any problem
int update_sym_table(char * key, any_t value){
    return hashmap_put(map, key, value)==MAP_OK? DECLARED : UNDECLARED;
}

