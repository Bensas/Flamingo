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
#define IF_STATEMENT_LENGTH 7
#define IF_ELSE_STATEMENT_LENGTH 14
%}

%union {
  struct number {
      float value;
      var_type_t type;
      int resolvable;
      char * text;
  } number;
  struct boolean{
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
%type <string> GateApply Statement Declaration Definition PrintStatement WhileStatement IfStatement Function

%%

/* Defincion de la gramatica */

/* Primeras definiciones: un programa es un conjunto de definiciones (declaracion + asignacion)*/

Program : Function {
         fputs($1, yyout);
        }
		| EXIT END	{;}
    ;

Function : Statement {
		$$ = $1;
		//printf("Function->Statement: alive with 1 statement with len %lu\n",strlen($$));
		}
	| Function Statement {
		//printf("Function->Function Statement: alive with more than 1 statement with len %lu\n",strlen($$));
		int len = strlen($1) + strlen($2) +2;
	 	$$ = malloc(len);
	 	snprintf($$,len,"%s\n%s",$1,$2);
		}
    ;

Statement : Declaration END {
		int len = strlen($1) + 2;
		$$ = malloc(len);
        snprintf($$,len, "%s;", $1);
    }
    | IfStatement {;}
    | WhileStatement {
			int len = strlen($1) + 1;
    	$$ = malloc(len);
        snprintf($$,len, "%s;", $1);
		}
    | PrintStatement END {
			int len = strlen($1) + 2;
    	$$ = malloc(len);
        snprintf($$,len, "%s;", $1);
    	}
    | GateApply END {
			int len = strlen($1) + 2;
			$$ = malloc(len);
    	snprintf($$,len, "%s;", $1);
      }
    ;

IfStatement : IF OPEN_PARENTHESIS BoolExp CLOSE_PARENTHESIS OPEN_BRACKET Function CLOSE_BRACKET {
                    int length = IF_STATEMENT_LENGTH + strlen($3.text) + strlen($6) + 1;
                    $$ = malloc(length);
                    snprintf($$, length, "if (%s){%s}", $3.text, $6);
            }
            | IF OPEN_PARENTHESIS BoolExp CLOSE_PARENTHESIS OPEN_BRACKET Function CLOSE_BRACKET ELSE OPEN_BRACKET Function CLOSE_BRACKET {
                    int length = IF_ELSE_STATEMENT_LENGTH + strlen($3.text) + strlen($6) + strlen($10) + 1;
                    $$ = malloc(length);
                    snprintf($$, length, "if (%s){%s} else {%s}", $3.text, $6, $10);
            }
            | IF OPEN_PARENTHESIS BoolExp CLOSE_PARENTHESIS OPEN_BRACKET Function CLOSE_BRACKET ELSE IfStatement {
                    int length = IF_ELSE_STATEMENT_LENGTH + strlen($3.text) + strlen($6) + strlen($9) + 1;
                    $$ = malloc(length);
                    snprintf($$, length, "if (%s){%s} else %s", $3.text, $6, $9);
            }
    ;

WhileStatement : WHILE OPEN_PARENTHESIS BoolExp CLOSE_PARENTHESIS OPEN_BRACKET Function CLOSE_BRACKET {

			int len = 7 + strlen($3.text) + 4 + strlen($6) + 2 +1;
			$$ = malloc(len);

			snprintf($$,len,"while( %s ){\n%s\n}",$3.text,$6);
			}
    ;

PrintStatement : PRINT STRING {
		int len = 21 + strlen($2);
		$$ = malloc(len);
		snprintf($$,len, "System.out.println(%s)", $2);
	}
	| PRINT ID {
		//This code will work once we have a structure for variables so we can typecheck
		if ($2->var_type == TYPE_REG){
			int len = strlen($2->name) + 21;
			$$ = malloc(len);
			snprintf($$, len, "%s.printAmplitudes()", $2->name);
		} else {
			int len = strlen($2->name) + 21;
			$$ = malloc(len);
			snprintf($$, len, "System.out.println(%s)", $2->name);
		}
		;}
	;

BoolExp : BoolExp AND BoolExpOr {
		$$.value = $1.value && $3.value;
		int len = 2;
		if($1.resolvable == 0 || $3.resolvable == 0){
				$$.resolvable = 0;
				len = strlen($1.text) + 4 + strlen($3.text)+1;
				$$.text = malloc(len);
				snprintf($$.text,len,"%s && %s",$1.text,$3.text);
		}else{
			$$.resolvable = 1;
			if($$.value == 1){
				$$.text=malloc(5); snprintf($$.text,5,"TRUE");
			}else{
				$$.text=malloc(6); snprintf($$.text,6,"FALSE");
			}
		}
		}
	| BoolExpOr {
		$$.value = $1.value;
		$$.resolvable = $1.resolvable;
		int len = strlen($1.text)+1;
		$$.text = malloc(len);
		snprintf($$.text,len,"%s",$1.text);
	}
	;

BoolExpOr : BoolExpOr OR BoolVal {
		$$.value = $1.value || $3.value;
		int len = 2;
		if($1.resolvable == 0 || $3.resolvable == 0){
				$$.resolvable = 0;
				len = strlen($1.text) + 4 + strlen($3.text)+1;
				$$.text = malloc(len);
				snprintf($$.text,len,"%s || %s",$1.text,$3.text);
		}else{
			$$.resolvable = 1;
			if($$.value == 1){
				$$.text=malloc(5); snprintf($$.text,5,"TRUE");
			}else{
				$$.text=malloc(6); snprintf($$.text,6,"FALSE");
			}
		}
		}
	| BoolVal {
		$$.value = $1.value;
		$$.resolvable = $1.resolvable;
		int len = strlen($1.text)+1;
		$$.text = malloc(len);
		snprintf($$.text,len,"%s",$1.text);
		}
	;

BoolVal : OPEN_PARENTHESIS BoolExp CLOSE_PARENTHESIS {
			$$.value = $2.value;$$.resolvable = $2.resolvable;
				if($2.resolvable == 0){
					int len = 2+strlen($2.text)+1;
					$$.text = malloc(len);
					snprintf($$.text,len,"(%s)",$2.text);
				}else{
					if($$.value == 1){
						$$.text=malloc(5); snprintf($$.text,5,"TRUE");
					}else{
						$$.text=malloc(6); snprintf($$.text,6,"FALSE");
					}
				}
		}
    | NOT BoolVal {
			$$.value = 1 - $2.value; $$.resolvable = $2.resolvable;
			if($2.resolvable == 0){
					int len = 1+strlen($2.text)+1;
					$$.text = malloc(len);
					snprintf($$.text,len,"!%s",$2.text);
			}else{
				if($$.value == 1){
					$$.text=malloc(5); snprintf($$.text,5,"TRUE");
				}else{
					$$.text=malloc(6); snprintf($$.text,6,"FALSE");
				}
			}
			}
    | TRUE {$$.value = 1;	$$.resolvable=1; $$.text=malloc(5); snprintf($$.text,5,"TRUE");}
    | FALSE {$$.value = 0;	$$.resolvable=1; $$.text=malloc(6); snprintf($$.text,6,"FALSE");}
    | RelationalExp {
			$$.value = $1.value;	$$.resolvable = $1.resolvable;
			if($1.resolvable == 0){
					int len = strlen($1.text)+1;
					$$.text = malloc(len);
					snprintf($$.text,len,"%s",$1.text);
			}else{
				if($$.value == 1){
					$$.text=malloc(5); snprintf($$.text,5,"TRUE");
				}else{
					$$.text=malloc(6); snprintf($$.text,6,"FALSE");
				}
			}
		}
    ;

RelationalExp : NumericExpression SMALLER_OR_EQ NumericExpression {
				$$.value = ($1.value <= $3.value)?1:0;
				int len;
				if($1.resolvable == 0 || $3.resolvable == 0){
						$$.resolvable = 0;
						len = strlen($1.text) + 4 + strlen($3.text)+1;
						$$.text = malloc(len);
						snprintf($$.text,len,"%s <= %s",$1.text,$3.text);
				}else{
					$$.resolvable = 1;
					if($$.value == 1){
						len = 5; $$.text=malloc(len); snprintf($$.text,len,"TRUE");
					}else{
						len = 6; $$.text=malloc(len); snprintf($$.text,len,"FALSE");
					}
				}
			}
    | NumericExpression GREATER_OR_EQ NumericExpression {
				$$.value = ($1.value >= $3.value)?1:0;
				int len;
				if($1.resolvable == 0 || $3.resolvable == 0){
					$$.resolvable = 0;
					len = strlen($1.text) + 4 + strlen($3.text)+1;
					$$.text = malloc(len);
					snprintf($$.text,len,"%s >= %s",$1.text,$3.text);
				}else{
					$$.resolvable = 1;
					if($$.value == 1){
						len = 5; $$.text=malloc(len); snprintf($$.text,len,"TRUE");
					}else{
						len = 6; $$.text=malloc(len); snprintf($$.text,len,"FALSE");
					}
				}
			}
    | NumericExpression EQ NumericExpression {
			$$.value = ($1.value == $3.value)?1:0;
			int len;
			if($1.resolvable == 0 || $3.resolvable == 0){
				$$.resolvable = 0;
					len = strlen($1.text) + 4 + strlen($3.text)+1;
					$$.text = malloc(len);
					snprintf($$.text,len,"%s == %s",$1.text,$3.text);
			}else{
				$$.resolvable = 1;
				if($$.value == 1){
					len = 5; $$.text=malloc(len); snprintf($$.text,len,"TRUE");
				}else{
					len = 6; $$.text=malloc(len); snprintf($$.text,len,"FALSE");
				}
			}
			}
    | NumericExpression NOT_EQ NumericExpression {
			$$.value = ($1.value != $3.value)?1:0;
			int len;
			if($1.resolvable == 0 || $3.resolvable == 0){
				$$.resolvable = 0;
					len = strlen($1.text) + 4 + strlen($3.text)+1;
					$$.text = malloc(len);
					snprintf($$.text,len,"%s != %s",$1.text,$3.text);
			}else{
				$$.resolvable = 1;
				if($$.value == 1){
					len = 5; $$.text=malloc(len); snprintf($$.text,len,"TRUE");
				}else{
					len = 6; $$.text=malloc(len); snprintf($$.text,len,"FALSE");
				}
			}
			}
    | NumericExpression GREATER_THAN NumericExpression {
			$$.value = ($1.value > $3.value)?1:0;
			int len;
			if($1.resolvable == 0 || $3.resolvable == 0){
				$$.resolvable = 0;
					len = strlen($1.text) + 3 + strlen($3.text)+1;
					$$.text = malloc(len);
					snprintf($$.text,len,"%s > %s",$1.text,$3.text);
			}else{
				$$.resolvable = 1;
				if($$.value == 1){
					len = 5; $$.text=malloc(len); snprintf($$.text,len,"TRUE");
				}else{
					len = 6; $$.text=malloc(len); snprintf($$.text,len,"FALSE");
				}
			}
			}
    | NumericExpression SMALLER_THAN NumericExpression {
			$$.value = ($1.value < $3.value)?1:0;
			int len;
			if($1.resolvable == 0 || $3.resolvable == 0){
				$$.resolvable = 0;
					len = strlen($1.text) + 3 + strlen($3.text)+1;
					$$.text = malloc(len);
					snprintf($$.text,len,"%s < %s",$1.text,$3.text);
			}else{
				$$.resolvable = 1;
				if($$.value == 1){
					len = 5; $$.text=malloc(len); snprintf($$.text,len,"TRUE");
				}else{
					len = 6; $$.text=malloc(len); snprintf($$.text,len,"FALSE");
				}
			}
		}
    ;

//State state = new State(new Qbit[]{new Qbit(1, 0), new Qbit(0, 1)});//register reg = |01>

Declaration : DECL_INT ID {
			int len = INTEGER_LENGTH + SPACE_LEN + strlen($2->name);
            exit_program_if_variable_was_declared($2->name);

            //Variable was not declared;
            store_new_symbol($2->name, $2);
            update_key_type($2->name, INTEGER_TYPE);

            $$ = malloc(len);
        	snprintf($$,len + 1, "int %s", $2->name);
            printf("Fue una declaracion: %s\n", $$);
        }
        | DECL_FLOAT ID {
			int len = FLOAT_LENGTH + SPACE_LEN + strlen($2->name);
            exit_program_if_variable_was_declared($2->name);

            //Variable was not declared
            store_new_symbol($2->name, $2);
            update_key_type($2->name, FLOAT_TYPE);

            $$ = malloc(len);
        	snprintf($$,len + 1, "float %s", $2->name);
            printf("Fue una declaracion: %s\n", $$);
        }
        | DECL_STRING ID {
			int len = STRING_LEN + SPACE_LEN + strlen($2->name);
            exit_program_if_variable_was_declared($2->name);

            //Variable was not declared
            store_new_symbol($2->name, $2);
            update_key_type($2->name, TYPE_STRING);

            $$ = malloc(len);
        	snprintf($$,len + 1, "String %s", $2->name);
            printf("Fue una declaracion\n");
        }
        | DECL_REGISTER ID {
			int len = STATE_LEN + SPACE_LEN + strlen($2->name);
            exit_program_if_variable_was_declared($2->name);
        	$$ = malloc(len);

            //Variable was not declared
            store_new_symbol($2->name, $2);
            update_key_type($2->name, TYPE_REG);

        	snprintf($$,len + 1, "State %s", $2->name);
            printf("Fue una declaracion: %s\n", $$);
        }
        | DECL_INT ID ASSIGN NumericExpression {
            exit_program_if_variable_was_declared($2->name);

            //Variable was not declared
            store_new_symbol($2->name, $2);
            update_key_type($2->name, INTEGER_TYPE);

            if($4.type == INTEGER_TYPE) {
                int len = INTEGER_LENGTH + SPACE_LEN + strlen($2->name) + 1 + num_of_digits($4.value) +1;
                $$ = malloc(len);
                snprintf($$,len, "%s %s=%s", "int", $2->name, $4.text);
            } else {
                perror("Error: Float to Int\n");
                exit(1);
            }

            printf("Decl int queda: %s\n", $$);
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
            store_new_symbol($2->name, $2);
            update_key_type($2->name, FLOAT_TYPE);
            printf("Defined a float variable: %s, value of %f, type of %d\n", $2->name, $4.value, symlook($2->name)->var_type);
            $$ = malloc(FLOAT_LENGTH + SPACE_LEN + strlen($2->name) + SPACE_LEN + strlen($4.text));
            sprintf($$, "float %s = %s", $2->name, $4.text);
            printf("Decl float queda: %s\n", $$);
        }
        | DECL_STRING ID ASSIGN STRING {
            int len = STRING_LEN + SPACE_LEN + strlen($2->name) + 1 + strlen($4);
            $$ = malloc(len);
            $$[len] = '\0';
            snprintf($$,len+1, "String %s%c%s", $2->name, '=', $4);
            printf("Defined a string variable %s, value of %s\n", $$, $4);
            printf("Definicion de string queda: %s\n", $$);
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
            int len = 6 + strlen($2->name) + 27 + strlen(qbitInitializations);
            $$ = malloc(len);
            snprintf($$,len,"State %s = new State(new Qbit[]{%s})",$2->name, qbitInitializations);
            printf("Acabo de escribir:\n");
            printf("State %s = new State(new Qbit[]{%s})\n",$2->name, qbitInitializations);

            printf("Definitooon\n");		//FIXME remove this when this joke gets old

            free(qbitInitializations);
        }
        | Definition {$$ = $1; printf("Value of Decl: %s\n", $$);}
        ;

Definition : ID ASSIGN NumericExpression {
                int firstDeclaration = 0;
                if(is_declared($1->name)) {
                    //Type verifications
                    if($1->var_type != $3.type) {
                        perror("Error while defining");
                        exit(1);
                    }
                } else {
                    store_new_symbol($1->name, $1);
                    update_key_type($1->name, $3.type);
                    firstDeclaration = 1;
                }
                int length = 0;
                length = strlen($1->name) + SPACE_LEN + 1 + SPACE_LEN;
                if($3.type == INTEGER_TYPE) {
                    length += INTEGER_LENGTH + 1;
                } else {
                    length += FLOAT_LENGTH + 1;
                }
                if($3.resolvable) {
                    length += num_of_digits($3.value);
                    $$ = malloc(length);
                    if($3.type == INTEGER_TYPE) {
                        if(firstDeclaration) {
                            sprintf($$, "int %s = %d", $1->name, (int)$3.value);
                        } else {
                            sprintf($$, "%s = %d", $1->name, (int)$3.value);
                        }
                    } else {
                        if(firstDeclaration) {
                            sprintf($$, "float %s = %f", $1->name, $3.value);
                        } else {
                            sprintf($$, "%s = %f", $1->name, $3.value);
                        }
                    }
                } else {
                    length += strlen($3.text);
                    $$ = malloc(length);
                    if($3.type == INTEGER_TYPE) {
                        if(firstDeclaration) {
                            sprintf($$, "int %s = %s", $1->name, $3.text);
                        } else {
                            sprintf($$, "%s = %s", $1->name, $3.text);
                        }
                    } else {
                        if(firstDeclaration) {
                            sprintf($$, "float %s = %s", $1->name, $3.text);
                        } else {
                            sprintf($$, "%s = %s", $1->name, $3.text);
                        }
                    }
                }
                printf("Value of non typed definition: %s\n", $$);
            }
        | ID ASSIGN QBIT_STR {;}

NumericExpression :
  NumericExpression PLUS Term  {
                        if($1.type == FLOAT_TYPE || $3.type == FLOAT_TYPE) {
                            $$.type = FLOAT_TYPE;
                        } else {
                            $$.type = INTEGER_TYPE;
                        }
                        if($1.resolvable && $3.resolvable) {
                            if($1.type == FLOAT_TYPE || $3.type == FLOAT_TYPE) {
                                $$.value = $1.value + $3.value;
                                $$.text = malloc(20);
                                sprintf($$.text, "%f", $$.value);
                            } else {
                                $$.value = (int)$1.value + (int)$3.value;
                                $$.text = malloc(num_of_digits((int)$$.value));
                                sprintf($$.text, "%d", (int)$$.value);
                            }
                            $$.resolvable = 1;
                        } else {
                            $$.resolvable = 0;
                            $$.text = malloc(strlen($1.text) + 2*SPACE_LEN + 1 + strlen($3.text));
                            sprintf($$.text, "%s + %s", $1.text, $3.text);
                        }
                        }
  | NumericExpression MINUS Term  {
                        if($1.type == FLOAT_TYPE || $3.type == FLOAT_TYPE) {
                            $$.type = FLOAT_TYPE;
                        } else {
                            $$.type = INTEGER_TYPE;
                        }
                        if($1.resolvable && $3.resolvable) {
                            if($1.type == FLOAT_TYPE || $3.type == FLOAT_TYPE) {
                                $$.value = $1.value - $3.value;
                                $$.text = malloc(20);
                                sprintf($$.text, "%f", $$.value);
                            } else {
                                $$.value = (int)$1.value - (int)$3.value;
                                $$.text = malloc(num_of_digits((int)$$.value));
                                sprintf($$.text, "%d", (int)$$.value);
                            }
                            $$.resolvable = 1;
                        } else {
                            $$.resolvable = 0;
                            $$.text = malloc(strlen($1.text) + 2*SPACE_LEN + 1 + strlen($3.text));
                            sprintf($$.text, "%s - %s", $1.text, $3.text);
                        }
                    }
  | Term  {
            $$.type = $1.type;
            if($1.resolvable) {
                $$.value = $1.value;
								printf("\033[36m");
                printf("Term value is: %f\n", $1.value);
								printf("\033[37m");
                $$.resolvable = 1;
            } else {
                $$.resolvable = 0;
            }
						printf("\033[36m");
            printf("TERM type of: %d\n", $$.type);
						printf("\033[37m");
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
                            if($1.type == FLOAT_TYPE || $3.type == FLOAT_TYPE) {
                                $$.value = $1.value * $3.value;
                                $$.text = malloc(20);
                                sprintf($$.text, "%f", $$.value);
                            } else {
                                $$.value = (int)$1.value * (int)$3.value;
                                $$.text = malloc(num_of_digits((int)$$.value));
                                sprintf($$.text, "%d", (int)$$.value);
                            }
                            $$.resolvable = 1;
                        } else {
                            $$.resolvable = 0;
                            $$.text = malloc(strlen($1.text) + 2*SPACE_LEN + 1 +strlen($3.text));
                            sprintf($$.text, "%s * %s", $1.text, $3.text);
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
                            if($$.type == INTEGER_TYPE) {
                                $$.text = malloc(num_of_digits((int)$$.value));
                                sprintf($$.text, "%d", (int)$$.value);
                            } else {
                                $$.text = malloc(20);
                                sprintf($$.text, "%f", $$.value);
                            }
                        } else {
                            $$.resolvable = 0;
                            $$.text = malloc(strlen($1.text) + strlen($3.text) + 1 + 2*SPACE_LEN);
                            sprintf($$.text, "%s / %s", $1.text, $3.text);
                        }
                        printf("Divide expression was: %s\n", $$.text);
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
                            $$.text = malloc(num_of_digits((int)$$.value));
                            sprintf($$.text, "%d", (int)$$.value);
                        } else {
                            $$.resolvable = 0;
                            $$.text = malloc(strlen($1.text) + strlen($3.text) + 1 + 2*SPACE_LEN);
                            sprintf($$.text, "%s %c %s", $1.text, '%', $3.text);
                        }
                    }
  | Unit {$$.type = $1.type;
          if($1.resolvable) {
            $$.value = $1.value;
            $$.resolvable = 1;
          } else {
              $$.resolvable = 0;
          }
          $$.text = $1.text;
					printf("\033[36m");
          printf("UNIT type of: %d\n", $$.type);
					printf("\033[37m");
        }
  ;

Unit :
  ID  {$$.resolvable = 0;
      $$.text = strdup($1->name);
      sym * aux = symlook($1->name);
      $$.type = aux->var_type;
      $$.text = strdup($1->name);}             /*FIXME: decidir esto despues */
  | MINUS Unit {
      $$.type = $2.type;
    $$.text = malloc(strlen($2.text) + 1);
    sprintf($$.text, "-%s", $2.text);
    if($2.resolvable) {
        $$.value = -$2.value;
        $$.resolvable = 1;
    } else {
        $$.resolvable = 0;
        printf("La cosa queda: %s\n", $$.text);
    }
  }
  | INTEGER_NUMBER  {$$.type = INTEGER_TYPE; $$.resolvable = 1; $$.value = $1.value; $$.text = malloc(num_of_digits((int)$1.value)); sprintf($$.text ,"%d", (int)$1.value);}
  | FLOAT_NUMBER  {$$.type = FLOAT_TYPE; $$.resolvable = 1; $$.value = $1.value; $$.text = malloc(20); sprintf($$.text ,"%f", $1.value);}
  | OPEN_PARENTHESIS NumericExpression CLOSE_PARENTHESIS  {$$.type = $2.type;
                                                            $$.text = malloc(strlen($2.text) + 2);
                                                            sprintf($$.text, "(%s)", $2.text);
                                                            if($2.resolvable) {
                                                             $$.value = $2.value;
                                                             $$.resolvable = 1;
                                                            } else {
                                                                $$.resolvable = 0;
                                                            }
                                                          }
  ;


GateApply : //state.applyGateToQbit(0, new Hadamard2d());  ----------  H(reg, 0);
  GATE OPEN_PARENTHESIS ID NumericExpression CLOSE_PARENTHESIS {
			int len;
      if (strcmp($1, "ID") != 0){
		  len = strlen($3->name) +
          		((strcmp($1, "H") == 0) ? 37 : (strcmp($1, "CNOT") == 0) ? 35 : 36) +
          		num_of_digits((int)$4.value);
          $$ = malloc(len);

          if (strcmp($1, "H") == 0){
              snprintf($$,len, "%s.applyGateToQbit(%d, new Hadamard2d())", $3->name, (int)$4.value);
              break;
          } else if (strcmp($1, "X") == 0){
              snprintf($$, len, "%s.applyGateToQbit(%d, new PauliX2D())", $3->name, (int)$4.value);
              break;
          } else if (strcmp($1, "Y") == 0){
              snprintf($$, len, "%s.applyGateToQbit(%d, new PauliY2D())", $3->name, (int)$4.value);
              break;
          } else if (strcmp($1, "Z") == 0){
              snprintf($$, len, "%s.applyGateToQbit(%d, new PauliZ2D())", $3->name, (int)$4.value);
              break;
          } else if (strcmp($1, "CNOT") == 0){
              snprintf($$, len, "%s.applyGateToQbits(%d, %d, new CNOT())", $3->name, (int)$4.value, (int)$4.value+1);
          }
      }
  }
  ;


%%

#define HEAD_BEGINNING "import quantum.State;\nimport quantum.Qbit;\nimport quantum.gates.*;\n\nimport static java.lang.Boolean.FALSE;\nimport static java.lang.Boolean.TRUE;\n\npublic class "
#define DEFAULT_OUTPUT_CLASS "Main"
#define HEAD_END " {\n  public static void main(String[] args){\n"
#define TAIL 

void printVarTypes() {
		printf("\033[34m");
    printf("TYPE_UNDEF: %d\n", TYPE_UNDEF);
    printf("INTEGER_TYPE: %d\n", INTEGER_TYPE);
    printf("FLOAT_TYPE: %d\n", FLOAT_TYPE);
    printf("TYPE_STRING: %d\n", TYPE_STRING);
    printf("TYPE_REG: %d\n", TYPE_REG);
		printf("\033[37m");
}

int main(int argc, char **argv)
{
    printVarTypes();
    init_parser();
	char* head;
	char* tail = "  }\n}\n";
	char* inputFile;
	char* outputFile;
	char* compileCommand;
	char* runCommand;
	extern FILE *yyin, *yyout;

	int compileLen;
	int runLen;


	outputFile = malloc(strlen(DEFAULT_OUTPUT_CLASS) + 6);
    strcat(outputFile, DEFAULT_OUTPUT_CLASS);
    strcat(outputFile, ".java");

    head = malloc(strlen(HEAD_BEGINNING) + strlen(DEFAULT_OUTPUT_CLASS) + strlen(HEAD_END) + 1);
	strcat(head, HEAD_BEGINNING);
	strcat(head, DEFAULT_OUTPUT_CLASS);
	strcat(head, HEAD_END);

	compileLen = 7 + strlen(outputFile);
	compileCommand = malloc(compileLen);
	runLen = 6 + strlen(DEFAULT_OUTPUT_CLASS);
	runCommand = malloc(runLen);
	snprintf(compileCommand, compileLen, "javac %s", outputFile);
	snprintf(runCommand, runLen, "java %s", DEFAULT_OUTPUT_CLASS);

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
		outputFile = strdup(argv[2]);
		strcat(outputFile, ".java");

		head = malloc(strlen(HEAD_BEGINNING) + strlen(argv[2]) + strlen(HEAD_END) + 1);
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

	if(argc > 3)
	{
		printf("Too many arguments!");
		exit(1);
	}

	printf("%d\n", argc);

	yyout = fopen(outputFile,"w");
	if(yyout == NULL)
	{
		printf("Unable to create file.\n");
		exit(1);
	}

	fputs(head, yyout);
	yyparse();
	fputs("  }\n}\n", yyout);

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

int num_of_digits(int n){
	int result = 1;
	int aux = n;
	while (aux/10 != 0){
		aux /= 10;
		result++;
	}
	return result + (n<0?1:0);
}

void exit_program_if_variable_was_declared(char * id){
    if(is_declared(id)){
        yyerror("Symbol already in use\n");
        exit(1);
    }
}
