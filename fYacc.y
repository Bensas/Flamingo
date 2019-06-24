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

%union {
  int value;
}

%token <string> STRING
%token <symp> ID
%token <int> NUMBER 
%token <cmd> PLUS MINUS MULTIPLY DIVIDE MODULO GATE
%token <cmd> DECL_INT, DECL_STRING, DECL_REGISTER
%token <cmd> ASSIGN GREATER GREATER_OR_EQ SMALLER SMALLER_OR_EQ EQ NOT_EQ
%token <cmd> NOT AND OR
%token <cmd> END PRINT
%token <cmd> OPEN_PARENTHESIS CLOSE_PARENTHESIS OPEN_BRACKET CLOSE_BRACKET PIPE
%token <cmd> IF ELSE WHILE

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

GateApply :
  GATE OPEN_PARENTHESIS ID Integer CLOSE_PARENTHESIS END { }; 


%%

int main()
{
    return yyparse();
}
