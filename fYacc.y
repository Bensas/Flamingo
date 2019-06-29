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
#define STATE_LEN 6
%}

%union {
  struct number {
      float value;
      var_type_t type;
      int resolvable;
      char * text;
  } number;
  struct boolean {
      int value;
      int resolvable;
      char * text;
  } boolean;
  char * string;
  char * gate;
  struct sym * id;
}
%start Program
/* all Vt announced here */
%token <id> ID
%token <number> INTEGER_NUMBER
%token <number> FLOAT_NUMBER
%token <boolean> TRUE
%token <boolean> FALSE
%token <string> STRING
%token DECL_INT
%token DECL_FLOAT
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
%token <string> EXIT
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
%type <string> GateApply Definition Statement Declaration PrintStatement

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

Statement : Declaration END {
		int len = strlen($1) + 1;
		$$ = malloc(len);
        snprintf($$,len, "%s;", $1);
    }
    | IfStatement {;}
    | WhileStatement {;}
    | PrintStatement END {
			int len = strlen($1) + 1;
    	$$ = malloc(len);
        snprintf($$,len, "%s;", $1);
    	}
    | GateApply END {
			int len = strlen($1) + 1;
			$$ = malloc(len);
    	snprintf($$,len, "%s;", $1);
      }
    | EXIT END {exit(0);}
    ;

IfStatement : IF OPEN_PARENTHESIS BoolExp CLOSE_PARENTHESIS OPEN_BRACKET Program CLOSE_BRACKET {;}
            | IF OPEN_PARENTHESIS BoolExp CLOSE_PARENTHESIS OPEN_BRACKET Program CLOSE_BRACKET ELSE OPEN_BRACKET Program CLOSE_BRACKET {;}
            | IF OPEN_PARENTHESIS BoolExp CLOSE_PARENTHESIS OPEN_BRACKET Program CLOSE_BRACKET ELSE IfStatement {;}
    ;

WhileStatement : WHILE OPEN_PARENTHESIS BoolExp CLOSE_PARENTHESIS OPEN_BRACKET Program CLOSE_BRACKET {;}
    ;

PrintStatement : PRINT STRING {
		int len = 20 + strlen($2);
		$$ = malloc(len);
		snprintf($$,len, "System.out.println(%s)", $2);
	}
	| PRINT ID {
		//This code will work once we have a structure for variables so we can typecheck
		// if ($2->type == TYPE_REG){
		// 	$$ = malloc(strlen($2->name) + 18);
		// 	sprintf($$, "%s.printAmplitudes()", $2->name);
		/ q/ } else {
		// 	$$ = malloc(strlen($2->name) + 20);
		// 	sprintf($$, "System.out.println(%s)", $2->name);
		// }
		;}
	;

BoolExp : BoolExp AND BoolExpOr {$$.value = $1.value && $3.value;}
	| BoolExpOr {$$.value = $1.value;}
	;

BoolExpOr : BoolExpOr OR BoolVal {$$.value = $1.value || $3.value;}
	| BoolVal {$$.value = $1.value;}
	;

BoolVal : OPEN_PARENTHESIS BoolExp CLOSE_PARENTHESIS {$$.value = $2.value;}
    | NOT BoolVal {$$.value = 1 - $2.value;}
    | TRUE {$$.value = 1;}
    | FALSE {$$.value = 0;}
    | RelationalExp {$$.value = $1.value;}
    ;

RelationalExp : NumericExpression SMALLER_OR_EQ NumericExpression {$$.value = ($1.value <= $3.value)?1:0;}
    | NumericExpression GREATER_OR_EQ NumericExpression {$$.value = ($1.value >= $3.value)?1:0;}
    | NumericExpression EQ NumericExpression {$$.value = ($1.value == $3.value)?1:0;}
    | NumericExpression NOT_EQ NumericExpression {$$.value = ($1.value != $3.value)?1:0;}
    | NumericExpression GREATER_THAN NumericExpression {$$.value = ($1.value > $3.value)?1:0;}
    | NumericExpression SMALLER_THAN NumericExpression {$$.value = ($1.value < $3.value)?1:0;}
    ;

//State state = new State(new Qbit[]{new Qbit(1, 0), new Qbit(0, 1)});//register reg = |01>

Declaration : DECL_INT ID {
					int len = INTEGER_LENGTH + SPACE_LEN + strlen($2->name);
            exit_program_if_variable_was_declared($2->name);
            $$ = malloc(len);
        	snprintf($$,len, "int %s", $2->name);
            printf("Fue una declaracion\n");
        }
        | DECL_FLOAT ID {
					int len = FLOAT_LENGTH + SPACE_LEN + strlen($2->name);
            exit_program_if_variable_was_declared($2->name);
            $$ = malloc(len);
        	snprintf($$,len, "float %s", $2->name);
            printf("Fue una declaracion\n");
        }
        | DECL_STRING ID {
						int len = STRING_LEN + SPACE_LEN + strlen($2->name);
            exit_program_if_variable_was_declared($2->name);
            $$ = malloc(len);
        	snprintf($$,len, "String %s", $2->name);
            printf("Fue una declaracion\n");
        }
        | DECL_REGISTER ID {
					int len = STATE_LEN + SPACE_LEN + strlen($2->name);
            exit_program_if_variable_was_declared($2->name);
        	$$ = malloc(len);
        	snprintf($$,len, "State %s", $2->name);
            printf("Fue una declaracion\n");
        }
        | DECL_INT ID ASSIGN NumericExpression {
            exit_program_if_variable_was_declared($2->name);
            if($4.type == INTEGER_TYPE) {
                int len = INTEGER_LENGTH + SPACE_LEN + strlen($2->name) + 1 + numOfDigits($4.value) +1;
                $$ = malloc(len);
                snprintf($$,len, "%s %s=%d", "int", $2->name, (int)$4.value);
            } else {
                perror("Error: Float to Int\n");
                exit(1);
            }
            printf("Defined an integer variable: %s, value of %d\n", $$, (int)$4.value);
        }
        | DECL_FLOAT ID ASSIGN NumericExpression {
            exit_program_if_variable_was_declared($2->name);
            if($4.type == FLOAT_TYPE) {
                int length = strlen($2->name) + SPACE_LEN + FLOAT_LENGTH + 20;
                $$ = malloc(length);
                sprintf($$, "%s %s=%f", "float", $2->name, $4.value);
            } else {
                perror("Error: Int to Float");
                exit(1);
            }
            printf("Defined a float variable: %s, value of %f\n", $$, $4.value);
        }
        | DECL_STRING ID ASSIGN STRING {
						int len = STRING_LEN + SPACE_LEN + strlen($2->name) + 1 + strlen($4);
						$$ = malloc(len);
						$$[len] = '\0';
						snprintf($$,len, "%s%c%s", $2->name, '=', $4);
            printf("Defined a string variable %s, value of %s\n", $$, $4);
        }
        | DECL_REGISTER ID ASSIGN QBIT_STR {
					char* qbitInitializations = malloc((strlen($4)-2) * 15 - 1);

					for(int i = 1 ; i < strlen($4)-1 ; i++){
						if ($4[i] == '0')
							strcat(qbitInitializations, "new Qbit(1, 0)");
						else if ($4[i] == '1')
							strcat(qbitInitializations, "new Qbit(0, 1)");
						if (i != strlen($4) - 2)
							strcat(qbitInitializations, ",");
					}
					int len = 6 + strlen($2) + 27 + strlen(qbitInitializations);
					$$ = malloc(len);
					snprintf($$,len,"State %s = new State(newQbit[]{%s})",$2->name, qbitInitializations);
					printf("Acabo de escribir:\n");
					printf("State %s = new State(newQbit[]{%s})\n",$2->name, qbitInitializations);

					printf("Definitooon\n");		//FIXME remove this when this joke gets old

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
                        if($1.resolvable && $3.resolvable) {
                            $$.value = $1.value + $3.value;
                            $$.resolvable = 1;
                        } else {
                            $$.resolvable = 0;
                        }
                        }
  | NumericExpression MINUS Term  {
                        if($1.type == FLOAT_TYPE || $3.type == FLOAT_TYPE) {
                            $$.type = FLOAT_TYPE;
                        } else {
                            $$.type = INTEGER_TYPE;
                        }
                        if($1.resolvable && $3.resolvable) {
                            $$.value = $1.value - $3.value;
                            $$.resolvable = 1;
                        } else {
                            $$.resolvable = 0;
                        }
                    }
  | Term  {
            $$.type = $1.type;
            if($1.resolvable) {
                $$.value = $1.value;
                $$.resolvable = 1;
            } else {
                $$.resolvable = 0;
            }
        }
  ;

Term :
  Term MULTIPLY  Unit   {
                        if($1.type == FLOAT_TYPE || $3.type == FLOAT_TYPE) {
                            $$.type = FLOAT_TYPE;
                        } else {
                            $$.type = INTEGER_TYPE;
                        }
                        if($1.resolvable && $3.resolvable) {
                            $$.value = $1.value * $3.value;
                            $$.resolvable = 1;
                        } else {
                            $$.resolvable = 0;
                        }
                        }
  | Term DIVIDE  Unit {
                        if($1.type == FLOAT_TYPE || $3.type == FLOAT_TYPE) {
                            $$.type = FLOAT_TYPE;
                        } else {
                            $$.type = INTEGER_TYPE;
                        }
                        if($1.resolvable && $3.resolvable) {
                            $$.value = $1.value / $3.value;
                            $$.resolvable = 1;
                        } else {
                            $$.resolvable = 0;
                        }
                      }
  | Term MODULO Unit {
                        if($1.type != INTEGER_TYPE || $3.type != INTEGER_TYPE) {
                            perror("Type error when computing modular arithmetic\n");
                            exit(1);
                        }
                        $$.type = INTEGER_TYPE;
                        if($1.resolvable && $3.resolvable) {
                            $$.value = (int)$1.value % (int)$3.value;
                            $$.resolvable = 1;
                        } else {
                            $$.resolvable = 0;
                        }
                    }
  | Unit {$$.type = $1.type;
          if($1.resolvable) {
            $$.value = $1.value;
            $$.resolvable = 1;
          } else {
              $$.resolvable = 0;
          }
        }
  ;

Unit :
  ID  {$$.resolvable = 0;
      $$.text = strdup($1->name);
      sym * aux = symlook($1->name);
      $$.type = aux->var_type;}             /*FIXME: decidir esto despues */
  | MINUS Unit {
      $$.type = $2.type;
      if($2.resolvable) {
        $$.value = -$2.value;
        $$.resolvable = 1;
      } else {
          $$.resolvable = 0;
          $$.text = malloc(1 + strlen($2.text));
          sprintf($$.text, "-%s", $2.text);
          printf("La cosa queda: %s\n", $$.text);
      } 
    }
  | INTEGER_NUMBER  {printf("Integer type: %d\n", $$.type);$$.type = INTEGER_TYPE; $$.resolvable = 1; $$.value = $1.value;}
  | FLOAT_NUMBER  {$$.type = FLOAT_TYPE; $$.resolvable = 1; $$.value = $1.value;}
  | OPEN_PARENTHESIS NumericExpression CLOSE_PARENTHESIS  {$$.type = $2.type;
                                                            if($2.resolvable) {
                                                             $$.value = $2.value;
                                                             $$.resolvable = 1;
                                                            } else {
                                                                $$.resolvable = 0;
                                                                $$.text = malloc(strlen($2.text));
                                                                sprintf($$.text, "(%s)", $$.text);
                                                            }
                                                          }
  ;


GateApply : //state.applyGateToQbit(0, new Hadamard2d());  ----------  H(reg, 0);
  GATE OPEN_PARENTHESIS ID NumericExpression CLOSE_PARENTHESIS {
			int len;
      if (strcmp($1, "ID") != 0){
					len = 4 +
          ((strcmp($1, "H") == 0) ? 37 : (strcmp($1, "CNOT") == 0) ? 31 : 35)+
          numOfDigits((int)$4.value);
          $$ = malloc(len);

          if (strcmp($1, "H") == 0){
              snprintf($$,len, "%s.applyGateToQbit(%d, new Hadamard2d())", "hola", (int)$4.value);
              break;
          } else if (strcmp($1, "X") == 0){
              snprintf($$, len, "%s.applyGateToQbit(%d, new PauliX2D())", "hola", (int)$4.value);
              break;
          } else if (strcmp($1, "Y") == 0){
              snprintf($$, len, "%s.applyGateToQbit(%d, new PauliY2D())", "hola", (int)$4.value);
              break;
          } else if (strcmp($1, "Z") == 0){
              snprintf($$, len, "%s.applyGateToQbit(%d, new PauliZ2D())", "hola", (int)$4.value);
              break;
          } else if (strcmp($1, "CNOT") == 0){
              snprintf($$, len, "%s.applyGateToQbits(%d, %d, new CNOT())", "hola", (int)$4.value, (int)$4.value+1);
          }
      }
  }
  ;


%%

#define HEAD_BEGINNING "import quantum.State;\nimport quantum.Qbit;\nimport quantum.gates.*;\npublic class "
#define DEFAULT_OUTPUT_CLASS "Main"
#define HEAD_END " {\n  public static void main(String[] args){\n"
#define TAIL "  }\n}\n"

int main(int argc, char **argv)
{
    init_parser();
	char* head;
	char* tail = TAIL;
	char* inputFile;
	char* outputFile;
	char* compileCommand;
	char* runCommand;
	extern FILE *yyin, *yyout;

	int compileLen;
	int runLen;

	if(argc > 3)
	{
		printf("Too many arguments!");
		exit(1);
	}
	else if(argc > 2)
	{
		outputFile = strdup(argv[2]);
		strcat(outputFile, ".java");

		head = malloc(strlen(HEAD_BEGINNING) + strlen(argv[2]) + strlen(HEAD_END));
		strcat(head, HEAD_BEGINNING);
		strcat(head, argv[2]);
		strcat(head, HEAD_END);

		compileLen = 7 + strlen(outputFile);
		compileCommand = malloc(compileLen);
		runLen = 6 + strlen(argv[2]);
		runCommand = malloc(runLen);
		snprintf(compileCommand, compileLen, "javac %s", outputFile);
		snprintf(runCommand, runLen, "java %s", argv[2]);
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
	else
	{
		outputFile = malloc(strlen(DEFAULT_OUTPUT_CLASS) + 6);
		strcat(outputFile, DEFAULT_OUTPUT_CLASS);
		strcat(outputFile, ".java");

		head = malloc(strlen(HEAD_BEGINNING) + strlen(DEFAULT_OUTPUT_CLASS) + strlen(HEAD_END));
		strcat(head, HEAD_BEGINNING);
		strcat(head, DEFAULT_OUTPUT_CLASS);
		strcat(head, HEAD_END);

		compileLen = 7 + strlen(outputFile);
		compileCommand = malloc(compileLen);
		runLen = 6 + strlen(DEFAULT_OUTPUT_CLASS);
		runCommand = malloc(runLen);
		snprintf(compileCommand, compileLen, "javac %s", outputFile);
		snprintf(runCommand, runLen, "java %s", DEFAULT_OUTPUT_CLASS);
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
	fclose(yyout);
	system(compileCommand);
	system(runCommand);
	free(compileCommand);
	free(runCommand);
	free(head);
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

void exit_program_if_variable_was_declared(char * id){
    if(is_declared(id)){
        yyerror("Error\n");
        exit(1);
    }
}
