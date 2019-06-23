%{
#include <stdio.h>
#include <stdlib.h>
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

%union {int value;char * string;}
%start Program
/* all Vt announced here */
%token <value> Identifier
%token <value> Number
%token <value> TRUE
%token <value> FALSE
%token AND
%token OR
%token NOT
%token SMALLER_OR_EQ
%token GREATER_OR_EQ
%token EQ
%token NOT_EQ
%token EXIT
%type <value> Integer Term Unit BoolExp BoolExpOr BoolVal RelationalExp

%%

/* Defincion de la gramatica */

/* Primeras definiciones: un programa es un conjunto de definiciones (declaracion + asignacion)*/

Program :
    Statement ';' {;}
    | Statement ';' Program {;}
    ;

Statement : Definition {;}
    | BoolExp {;}
    | EXIT {exit(0);}
    ;

BoolExp : BoolExp AND BoolExpOr {$$ = $1 && $3;;}
    | BoolExpOr {$$ = $1;}
    ;

BoolExpOr : BoolExpOr OR BoolVal {$$ = $1 || $3;}
    | BoolVal {$$ = $1;}
    ;

BoolVal : '(' BoolExp ')' {$$ = $2;}
    | NOT BoolVal {$$ = 1 - $2;}
    | TRUE {$$ = 1;}
    | FALSE {$$ = 0;}
    | RelationalExp {$$ = $1;}
    ;

RelationalExp : Integer SMALLER_OR_EQ Integer {$$ = ($1 <= $3)?1:0;}
    | Integer GREATER_OR_EQ Integer {$$ = ($1 >= $3)?1:0;}
    | Integer EQ Integer {$$ = ($1 == $3)?1:0;}
    | Integer NOT_EQ Integer {$$ = ($1 != $3)?1:0;}
    ;

Definition :
        Identifier '=' Integer {printf("Variable set with %d\n",$3); }
        ;

Integer :
  Integer '+' Term  {$$ = $1 + $3;}
  | Integer '-' Term  {$$ = $1 - $3;}
  | Term  {$$ = $1;}
  ;

Term :
  Term '*'  Unit   {$$ = $1 * $3;}
  | Term '/'  Unit {$$ = $1 / $3;}
  | Term '%'  Unit {$$ = $1 % $3;}
  | Unit {$$ = $1;}
  ;

Unit :
  Identifier  {$$ = 2;}             /*FIXME: decidir esto despues */
  | '-' Unit {$$ = -$2;}
  | Number  {$$ = $1;}
  | '(' Integer ')'  {$$ = $2;}
  ;


%%

int main()
{
    return yyparse();
}
