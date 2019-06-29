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

void declare(char * key)
{
    any_t * pointer=malloc(sizeof(*pointer));
    int result=hashmap_get(map,key,pointer);
    ((sym *)*pointer)->is_declared=DECLARED;
    free(pointer);
}

void store_new_symbol(char * key, sym * value)
{
    hashmap_put(map, key, (any_t)value);
}

void update_key_value(char * key, char * value)
{
    any_t * pointer=malloc(sizeof(*pointer));
    int result=hashmap_get(map,key,pointer);
    if(result==MAP_OK){
        ((sym *)*pointer)->str=value;
    }
    free(pointer);
}

void update_key_type(char * key, var_type_t type)
{
    any_t * pointer=malloc(sizeof(*pointer));
    int result=hashmap_get(map,key,pointer);
    if(result==MAP_OK){
        ((sym *)*pointer)->var_type=type;
    }
    free(pointer);
}

sym * symlook(char * sym_name)
{
    any_t * pointer=malloc(sizeof(*pointer)); 
    sym * sym_p=NULL;
    if(is_declared(sym_name)){
        hashmap_get(map, sym_name, pointer);
        sym_p=(sym *)(*pointer); // returns a pointer to struct sym
    }
    else{
        sym_p=(sym *)malloc(sizeof(*sym_p));
        sym_p->name=malloc(strlen(sym_name));
        strcpy(sym_p->name, sym_name);
        sym_p->is_declared=UNDECLARED;
    }
    return sym_p;
}
