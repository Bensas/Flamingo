%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.h"
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
  char * string;
  char * gate;
  struct symtab * id;
}
%start Program
/* all Vt announced here */
%token <id> ID
%token <value> NUMBER
%token <value> TRUE
%token <value> FALSE
%token <string> STRING
%token DECL_INT
%token DECL_STRING
%token DECL_REGISTER
%token ASSIGN
%token AND
%token OR
%token NOT
%token SMALLER_OR_EQ
%token GREATER_OR_EQ
%token GREATER_THAN
%token SMALLER_THAN
%token EQ
%token NOT_EQ
%token EXIT
%token IF
%token ELSE
%token DO
%token WHILE
%token PRINT
%token END
%token OPEN_PARENTHESIS
%token CLOSE_PARENTHESIS
%token OPEN_BRACKET
%token CLOSE_BRACKET
%token PIPE
%token PLUS
%token MINUS
%token MULTIPLY
%token DIVIDE
%token MODULO
%token <gate> GATE
%token MEASURE

%type <value> Integer Term Unit BoolExp BoolExpOr BoolVal RelationalExp
%type <string> GateApply

%%

/* Defincion de la gramatica */

/* Primeras definiciones: un programa es un conjunto de definiciones (declaracion + asignacion)*/

Program : Statement {;}
    | Statement Program {;}
    ;

Statement : Definition END {;}
    | IfStatement {;}
    | WhileStatement {;}
    | PrintStatement END {;}
    | GateApply END {;}
    | EXIT END {exit(0);}
    ;

IfStatement : IF BoolVal '{' Program '}' {;}
    | IF BoolVal '{' Program '}' ELSE '{' Program '}' {;}
    | IF BoolVal '{' Program '}' ELSE IfStatement {;}
    ;

WhileStatement : WHILE BoolVal '{' Program '}' {;}
    | DO '{' Program '}' WHILE BoolVal END {;}
    ;

PrintStatement : PRINT STRING {printf("%s",$2);}
    | PRINT ID {;}
    ;

BoolExp : BoolExp AND BoolExpOr {$$ = $1 && $3;}
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
    | Integer GREATER_THAN Integer {$$ = ($1 > $3)?1:0;}
    | Integer SMALLER_THAN Integer {$$ = ($1 < $3)?1:0;}
    ;

//State state = new State(new Qbit[]{new Qbit(1, 0), new Qbit(0, 1)});//register reg = |01>
Definition : ID ASSIGN Integer {printf("Integer variable set with %d\n",$3);}
        | ID ASSIGN STRING {printf("String variable set with %s\n", $3);}
        | ID ASSIGN PIPE QbitValues GREATER_THAN {
            $$ = malloc(strlen($1->name) + 27 + strlen($4));
            sprintf($$, "%s = new State(new Qbit[]{%s});", $1, $4);
        }
        ;

QbitValues : '0' QbitValues {
          $$ = malloc(27);
          sprintf($$, "new Qbit[]{new Qbit(1, 0),");}
        | '1' QbitValues {
          $$ = malloc(27);
          sprintf($$, "new Qbit[]{new Qbit(0, 1),");}
        | '0' {$$ = malloc(26);
              sprintf($$, "new Qbit[]{new Qbit(1, 0)");}
        | '1' {$$ = malloc(26);
              sprintf($$, "new Qbit[]{new Qbit(0, 1)");}
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
  ID  {;}             /*FIXME: decidir esto despues */
  | '-' Unit {$$ = -$2;}
  | NUMBER  {$$ = $1;}
  | '(' Integer ')'  {$$ = $2;}
  | Integer {;}
  ;

GateApply : //state.applyGateToQbit(0, new Hadamard2d());  ----------  H(reg, 0);
  GATE OPEN_PARENTHESIS ID Integer CLOSE_PARENTHESIS END { 
    printf("OOGABOOGA\n");
      printf("%s", $1);
      if (strcmp($1, "ID") != 0){
          // printf("TUVIEJA 1 %s\n", $3->name);
          // strlen($3->name);
          // printf("TUVIEJA 2\n");
          // strcmp($1, "H");
          //             printf("TUVIEJA 3\n");

          $$ = malloc(strlen($3->name) + 
          ((strcmp($1, "H") == 0) ? 37 : (strcmp($1, "CNOT") == 0) ? 31 : 35)+ 
          numOfDigits($4));
          // printf("%d\n", strlen($3->name) + 
          // ((strcmp($1, "H") == 0) ? 37 : (strcmp($1, "CNOT") == 0) ? 31 : 35)+ 
          // numOfDigits($4));

          if (strcmp($1, "H") == 0){
              sprintf($$, "%s.applyGateToQbit(%d, new Hadamard2d());\n", $3->name, $4);
              printf("TUVIEJA 1\n");
              break;
          } else if (strcmp($1, "X") == 0){
              sprintf($$, "%s.applyGateToQbit(%d, new PauliX2D());\n", $3->name, $4);
              break;
          } else if (strcmp($1, "Y") == 0){
              sprintf($$, "%s.applyGateToQbit(%d, new PauliY2D());\n", $3->name, $4);
              break;
          } else if (strcmp($1, "Z") == 0){
              sprintf($$, "%s.applyGateToQbit(%d, new PauliZ2D());\n", $3->name, $4);
              break;
          } else if (strcmp($1, "CNOT") == 0){
              sprintf($$, "%s.applyGateToQbit(%d, new CNOT());\n", $3->name, $4);
          }
      }      
  }
  ; 


%%

#define DEFAULT_OUTFILE "Main.java"

int main(int argc, char **argv)
{
    char* head = "import quantum.State;\
      import quantum.Qbit;\
      import quantum.Gates.*;\
      public class Main {\
        public static void main(String[] args){";
    char* tail = "}}";
    char *inputFile;
    char *outputFile;
    extern FILE *yyin, *yyout;

    outputFile = argv[0];
    if(argc > 3)
    {
        printf("Too many arguments!");
        exit(1);
    }
    if(argc > 1)
    {
        inputFile = argv[1];
        yyin = fopen(inputFile,"r");
        if(yyin == NULL)
        {
            printf("Failed to open %s!", inputFile); 
            exit(1);
        }
    }
    if(argc > 2)
    {
        outputFile = argv[2];
    }
    else
    {
        outputFile = DEFAULT_OUTFILE;
    }

    yyout = fopen(outputFile,"w");
    if(yyout == NULL)
    {
        printf("Unable to create file.\n");
        exit(1);
    }

    fputs(head, yyout);
    yyparse();
    fputs(tail, yyout);

    // if(!parsing_done)
    // {
    //   warning("Premature EOF",(char *)0);
    //   unlink(outputFile);
    //   exit(1);
    // }
    exit(0);
}

int numOfDigits(int n){
    int result = 1;
    int aux = n;
    while (aux/10 != 0){
        aux /= 10;
        result++;
    }
    return result;
}