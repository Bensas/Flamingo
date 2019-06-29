#ifndef __PARSER_H
#define __PARSER_H

//#define NSYMS 20 /* maximum number of symbols */

#define UNDECLARED 0
#define DECLARED 1

typedef void * any_t;
typedef enum var_type_t { TYPE_UNDEF = 0, INTEGER_TYPE, FLOAT_TYPE, TYPE_STRING, TYPE_REG } var_type_t;

//typedef enum { OP_GREATER, OP_GREATER_EQ, OP_LESSER, OP_LESSER_EQ, OP_EQUALS, OP_NOT_EQ } op_t;

typedef struct sym
{
    char *name;
    char *str;
    var_type_t var_type;
    int is_declared;
} sym;

//struct symtab *symlook();

//void warning(char *s, char *t);
void init_parser();
void update_sym_table(char * key, sym * value);
sym * symlook(char * sym_name); 
int numOfDigits(int n);
void exit_program_if_variable_was_declared(char * id);
//int yywrap();

#endif