%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.h"

FILE *yyout;

int yylex();
void yyerror(const char *str)
{
        fprintf(stderr,"error: %s\n",str);
}

int yywrap()
{
        return 1;
}

#define STRING_LEN 6
#define SPACE_LEN 1
%}

%union {
  struct number {
      float value;
      enum type {INTEGER_TYPE, FLOAT_TYPE} type;
  } number;
  int boolean;
  char * string;
  char * gate;
  struct symtab * id;
}
%start Program
/* all Vt announced here */
%token <string> ID
%token <number> INTEGER_NUMBER
%token <number> FLOAT_NUMBER
%token <boolean> TRUE
%token <boolean> FALSE
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

%type <boolean> BoolExp BoolExpOr BoolVal RelationalExp
%type <number> NumericExpression Term Unit
%type <string> GateApply QbitValues Definition Statement

%%

/* Defincion de la gramatica */

/* Primeras definiciones: un programa es un conjunto de definiciones (declaracion + asignacion)*/

Program : Statement {
        // fputs($1, yyout);
        }
    | Program Statement {
        // fputs($2, yyout);
        }
    ;

Statement : Definition END {
                    // printf("HOLAA VIEJA %s\n", $1);
                    // printf("Length: %d\n", strlen($1));
                    int length = strlen($1) + 1;
                    $$ = malloc(length);
                    $$[length] = '\0';
                     sprintf($$, "%s;", $1);
                     printf("Tu vieja: %s\n", $$);
                     }
    | IfStatement {;}
    | WhileStatement {;}
    | PrintStatement END {;}
    | GateApply END {$$ = malloc(strlen($1) + 1);
                     sprintf($$, "%s;", $1);
                    }
    | EXIT END {exit(0);}
    ;

IfStatement : IF BoolVal OPEN_BRACKET Program CLOSE_BRACKET {;}
    ;

WhileStatement : WHILE BoolVal OPEN_BRACKET Program CLOSE_BRACKET {;}
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

BoolVal : OPEN_PARENTHESIS BoolExp CLOSE_PARENTHESIS {$$ = $2;}
    | NOT BoolVal {$$ = 1 - $2;}
    | TRUE {$$ = 1;}
    | FALSE {$$ = 0;}
    | RelationalExp {$$ = $1;}
    ;

RelationalExp : NumericExpression SMALLER_OR_EQ NumericExpression {$$ = ($1.value <= $3.value)?1:0;}
    | NumericExpression GREATER_OR_EQ NumericExpression {$$ = ($1.value >= $3.value)?1:0;}
    | NumericExpression EQ NumericExpression {$$ = ($1.value == $3.value)?1:0;}
    | NumericExpression NOT_EQ NumericExpression {$$ = ($1.value != $3.value)?1:0;}
    | NumericExpression GREATER_THAN NumericExpression {$$ = ($1.value > $3.value)?1:0;}
    | NumericExpression SMALLER_THAN NumericExpression {$$ = ($1.value < $3.value)?1:0;}
    ;

//State state = new State(new Qbit[]{new Qbit(1, 0), new Qbit(0, 1)});//register reg = |01>

Definition : ID ASSIGN NumericExpression {
            printf("NumericExpression variable set with %f\n",$3.value);
            }
        | ID ASSIGN STRING {
            int length = STRING_LEN + SPACE_LEN + strlen($1) + 1 + strlen($3);
            $$ = malloc(length);
            $$[length] = '\0';
            sprintf($$, "%s%s%c%s", "String ", $1, '=', $3);
            // printf("String variable set with %s of length %d\n", $3, strlen($3));
            }
        | ID ASSIGN PIPE QbitValues GREATER_THAN {
            $$ = malloc(4 + 27 + strlen($4));
            sprintf($$, "%s = new State(new Qbit[]{%s})", "hola", $4);
            printf("Definitooon\n");
        }
        ;

QbitValues : '0' QbitValues {
          $$ = malloc(27);
          sprintf($$, "new Qbit[]{new Qbit(1, 0),");
          printf("Qbit0\n");}
        | '1' QbitValues {
          $$ = malloc(27);
          sprintf($$, "new Qbit[]{new Qbit(0, 1),");printf("Qbit1\n");}
        | '0' {$$ = malloc(26);
              sprintf($$, "new Qbit[]{new Qbit(1, 0)");printf("Qbit0-2\n");}
        | '1' {$$ = malloc(26);
              sprintf($$, "new Qbit[]{new Qbit(0, 1)");printf("Qbit1-2\n");}
        ;

NumericExpression :
  NumericExpression PLUS Term  {$$.value = $1.value + $3.value;}
  | NumericExpression MINUS Term  {$$.value = $1.value - $3.value;}
  | Term  {$$.value = $1.value;}
  ;

Term :
  Term MULTIPLY  Unit   {$$.value = $1.value * $3.value;}
  | Term DIVIDE  Unit {$$.value = $1.value / $3.value;}
  | Term MODULO  Unit {
                        if($$.type != INTEGER_TYPE) {
                            perror("Type error when computing modular arithmetic\n");
                            exit(1);
                        }
                        $$.value = (int)$1.value % (int)$3.value;
                        }
  | Unit {$$ = $1;}
  ;

Unit :
  ID  {;}             /*FIXME: decidir esto despues */
  | '-' Unit {$$.value = -$2.value;}
  | INTEGER_NUMBER  {$$.type = INTEGER_TYPE; $$.value = $1.value;}
  | FLOAT_NUMBER  {$$.type = FLOAT_TYPE; $$.value = $1.value;}
  | '(' NumericExpression ')'  {$$.value = $2.value;}
  ;


GateApply : //state.applyGateToQbit(0, new Hadamard2d());  ----------  H(reg, 0);
  GATE OPEN_PARENTHESIS ID NumericExpression CLOSE_PARENTHESIS { 
      if (strcmp($1, "ID") != 0){
          $$ = malloc(4 + 
          ((strcmp($1, "H") == 0) ? 37 : (strcmp($1, "CNOT") == 0) ? 31 : 35)+ 
          numOfDigits($4));

          if (strcmp($1, "H") == 0){
              sprintf($$, "%s.applyGateToQbit(%d, new Hadamard2d())", "hola", (int)$4.value);
              break;
          } else if (strcmp($1, "X") == 0){
              sprintf($$, "%s.applyGateToQbit(%d, new PauliX2D())", "hola", (int)$4.value);
              break;
          } else if (strcmp($1, "Y") == 0){
              sprintf($$, "%s.applyGateToQbit(%d, new PauliY2D())", "hola", (int)$4.value);
              break;
          } else if (strcmp($1, "Z") == 0){
              sprintf($$, "%s.applyGateToQbit(%d, new PauliZ2D())", "hola", (int)$4.value);
              break;
          } else if (strcmp($1, "CNOT") == 0){
              sprintf($$, "%s.applyGateToQbit(%d, new CNOT())", "hola", (int)$4.value);
          }
      }      
  }
  ;


%%

#define DEFAULT_OUTFILE "Main.java"

int main(int argc, char **argv)
{
    char* head = "import quantum.State;\n\
      import quantum.Qbit;\n\
      import quantum.Gates.*\n\
      public class Main {\n\
        public static void main(String[] args){\n";
    char* tail = "  }\n}\n";
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