%{
#include <stdio.h>
int yylex();
void yyerror(const char *str)
{
        fprintf(stderr,"error: %s\n",str);
}
 
int yywrap()
{
        return 1;
} 

%}

%token Identifier
%token Num
%token Colon
%token Equals

%%

/* Defincion de la gramatica */

/* Primeras definiciones: un programa es un conjunto de definiciones (declaracion + asignacion)*/

Program : 
    Definition Colon {;}
    | Definition Colon Program {;}
    ;

Definition : 
        Identifier Equals Num {printf("Variable set"); }
        ;

%%

int main()
{
    return yyparse();
} 