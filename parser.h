#ifndef __PARSER_H
#define __PARSER_H

#define UNDECLARED 0
#define DECLARED 1

typedef void * any_t;
typedef enum { UNDEF_TYPE = 0, INTEGER_TYPE, FLOAT_TYPE, STRING_TYPE, REG_TYPE } var_type_t;

//typedef enum { OP_GREATER, OP_GREATER_EQ, OP_LESSER, OP_LESSER_EQ, OP_EQUALS } op_t;

typedef struct sym
{
    char *name;
    var_type_t var_type;
} sym;

/* Functions for struct sym management
*/
void declare(char * key, sym * symbol, var_type_t type);
void init_parser();
int is_declared(char * key);
sym * symlook(char * sym_name);
void store_new_symbol(char * key, sym * value);
void update_key_type(char * key, var_type_t type);

/* Auxiliar functions
*/
int num_of_digits(int n);
void exit_program_if_variable_was_declared(char * id);

//int yywrap();

#endif