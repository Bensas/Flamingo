#include <stdio.h>
#include <stdlib.h>
#include "hashmap.h"

map_t map=NULL;

void init_parser()
{
    map=hashmap_new();
}


