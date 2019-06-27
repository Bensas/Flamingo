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
#define INTEGER_LENGTH 3
#define FLOAT_LENGTH 5
#define SPACE_LEN 1
#define NUMBER_LENGTH 15
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
%token <string> QBIT_STR

%type <boolean> BoolExp BoolExpOr BoolVal RelationalExp
%type <number> NumericExpression Term Unit
%type <string> GateApply Definition Statement

%%

/* Defincion de la gramatica */

/* Primeras definiciones: un programa es un conjunto de definiciones (declaracion + asignacion)*/

Program : Statement {
         fputs($1, yyout);
        }
    | Program Statement {
         fputs($2, yyout);
        }
    ;

Statement : Declaration END {;} 
    | Definition END {
        int length = strlen($1) + 1;
        $$ = malloc(length);
        sprintf($$, "%s;", $1);
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

Declaration : DECL_INT ID {
            printf("Fue una declaracion\n");
        }
        | DECL_STRING ID {
            printf("Fue una declaracion\n");
        }
        | DECL_REGISTER ID {
            printf("Fue una declaracion\n");
        }
        | DECL_INT Definition {
            printf("Fue una declaracion con asignacion\n");
            }
        | DECL_STRING Definition {
            printf("Fue una declaracion con asignacion\n");
            }
        | DECL_REGISTER Definition {
            printf("Fue una declaracion\n");
        }
        ;

Definition : ID ASSIGN NumericExpression {
            printf("NumericExpression variable set with %f\n",$3.value);
            int length = 0;
            if($3.type == INTEGER_TYPE) {
                length = INTEGER_LENGTH + SPACE_LEN + strlen($1) + 1 + numOfDigits((int)$3.value);
                $$ = malloc(length);
                sprintf($$, "%s%s%c%d%c", "int ", $1, '=', (int)$3.value, '\0');
            } else {
                length = FLOAT_LENGTH + SPACE_LEN + strlen($1) + 1 + NUMBER_LENGTH;
                $$ = malloc(length);
                sprintf($$, "%s%s%c%f%c", "float ", $1, '=', $3.value, '\0');
            }
            printf("%s\n", $$);
            }
        | ID ASSIGN STRING {
            int length = STRING_LEN + SPACE_LEN + strlen($1) + 1 + strlen($3);
            $$ = malloc(length);
            $$[length] = '\0';
            sprintf($$, "%s%s%c%s", "String ", $1, '=', $3);
            // printf("String variable set with %s of length %d\n", $3, strlen($3));
            }
        | ID ASSIGN QBIT_STR {
            char* qbitInitializations = malloc((strlen($3)-2) * 15 - 1);
			for (int i = 1; i < strlen($3)-1; i++){
				if ($3[i] == '0')
					strcat(qbitInitializations, "new Qbit(1, 0)");
				else if ($3[i] == '1')
					strcat(qbitInitializations, "new Qbit(0, 1)");
				if (i != strlen($3) - 2)
					strcat(qbitInitializations, ",");
			}
			$$ = malloc(4 + 27 + strlen(qbitInitializations));
			sprintf($$, "%s = new State(new Qbit[]{%s})", "hola", qbitInitializations);
			printf("Definitooon\n");
			free(qbitInitializations);	
        }
        ;

NumericExpression :
  NumericExpression PLUS Term  {
                        if($1.type == FLOAT_TYPE || $3.type == FLOAT_TYPE) {
                            $$.type = FLOAT_TYPE;
                        } else {
                            $$.type = INTEGER_TYPE;
                        }
                        $$.value = $1.value + $3.value;
                        }
  | NumericExpression MINUS Term  {
                        if($1.type == FLOAT_TYPE || $3.type == FLOAT_TYPE) {
                            $$.type = FLOAT_TYPE;
                        } else {
                            $$.type = INTEGER_TYPE;
                        }
                        $$.value = $1.value - $3.value;}
  | Term  {$$.type = $1.type;$$.value = $1.value;}
  ;

Term :
  Term MULTIPLY  Unit   {
                        if($1.type == FLOAT_TYPE || $3.type == FLOAT_TYPE) {
                            $$.type = FLOAT_TYPE;
                        } else {
                            $$.type = INTEGER_TYPE;
                        }
                        $$.value = $1.value * $3.value;
                        }
  | Term DIVIDE  Unit {
                        if($1.type == FLOAT_TYPE || $3.type == FLOAT_TYPE) {
                            $$.type = FLOAT_TYPE;
                        } else {
                            $$.type = INTEGER_TYPE;
                        }
                        $$.value = $1.value / $3.value;
                      }
  | Term MODULO  Unit {
                        if($$.type != INTEGER_TYPE) {
                            perror("Type error when computing modular arithmetic\n");
                            exit(1);
                        }
                        $$.value = (int)$1.value % (int)$3.value;
                        $$.type = INTEGER_TYPE;
                        }
  | Unit {$$.type = $1.type;$$ = $1;}
  ;

Unit :
  ID  {;}             /*FIXME: decidir esto despues */
  | '-' Unit {$$.type = $2.type ;$$.value = -$2.value;}
  | INTEGER_NUMBER  {$$.type = INTEGER_TYPE; $$.value = $1.value;}
  | FLOAT_NUMBER  {$$.type = FLOAT_TYPE; $$.value = $1.value;}
  | '(' NumericExpression ')'  {$$.type = $2.type;$$.value = $2.value;}
  ;


GateApply : //state.applyGateToQbit(0, new Hadamard2d());  ----------  H(reg, 0);
  GATE OPEN_PARENTHESIS ID NumericExpression CLOSE_PARENTHESIS { 
      if (strcmp($1, "ID") != 0){
          $$ = malloc(4 + 
          ((strcmp($1, "H") == 0) ? 37 : (strcmp($1, "CNOT") == 0) ? 31 : 35)+ 
          numOfDigits((int)$4.value));

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
              sprintf($$, "%s.applyGateToQbits(%d, %d, new CNOT())", "hola", (int)$4.value, (int)$4.value+1);
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