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

%union {int value;}
%start Program
/* all Vt announced here */
%token <value> Identifier
%token <value> Number

%type <value> Integer Term Unit

%%

/* Defincion de la gramatica */

/* Primeras definiciones: un programa es un conjunto de definiciones (declaracion + asignacion)*/

Program :
    Definition ';' {;}
    | Definition ';' Program {;}
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
