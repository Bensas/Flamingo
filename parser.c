#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "hashmap.h"
#include "parser.h"

map_t map=NULL;

void init_parser()
{
    map=hashmap_new();
}

int is_declared(char * key)
{
    any_t * pointer=malloc(sizeof(*pointer));
    int result=hashmap_get(map,key,pointer);
    free(pointer);
    if(result==MAP_OK)
        return DECLARED;
    return UNDECLARED;
}

// Stores pair key-value. Returns undeclared if there was any problem
void update_sym_table(char * key, sym * value)
{
    hashmap_put(map, key, (any_t)value);
}

sym * symlook(char * sym_name)
{
    sym * sym_p=NULL;    
    if(is_declared(sym_name)){
        hashmap_get(map, sym_name, (any_t *)sym_p);
    }
    else{
        sym_p=(sym *)malloc(sizeof(*sym_p));
        sym_p->name=malloc(strlen(sym_name));
        strcpy(sym_p->name, sym_name);
        sym_p->is_declared=UNDECLARED;
    }
    return sym_p;
}


