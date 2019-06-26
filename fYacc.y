%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
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
  char * id;
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
%token GATE
%token MEASURE

%type <value> Integer Term Unit BoolExp BoolExpOr BoolVal RelationalExp

%%

/* Defincion de la gramatica */

/* Primeras definiciones: un programa es un conjunto de definiciones (declaracion + asignacion)*/

Program : Statement {;}
    | Statement Program {;}
    ;

Statement : Definition END {;}
    | IfStatement {;}
    | EXIT END {exit(0);}
    | WhileStatement {;}
    | PrintStatement END {;}
    ;

IfStatement : IF BoolVal '{' Program '}' {;}
    | IF BoolVal '{' Program '}' ELSE '{' Program '}' {;}
    | IF BoolVal '{' Program '}' ELSE IfStatement {;}
    ;

WhileStatement : WHILE BoolVal '{' Program '}' {;}
    | DO '{' Program '}' WHILE BoolVal END {;}
    ;

PrintStatement : PRINT STRING {printf("%s",$2);}
    | PRINT ID {printf("System.out.println(\"%s\");",$2);}
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

Definition : ID ASSIGN Integer {printf("Variable set with %d\n",$3);}
        | ID ASSIGN STRING {printf("Variable set with %s\n", $3);}
        | ID ASSIGN PIPE QbitValues GREATER_THAN
        ;

QbitValues : '0' QbitValues {}
        | '1' QbitValues {}
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
  ID  {$$ = 2;}             /*FIXME: decidir esto despues */
  | '-' Unit {$$ = -$2;}
  | NUMBER  {$$ = $1;}
  | '{' Integer ')'  {$$ = $2;}
  ;

GateApply :
  GATE OPEN_PARENTHESIS ID Integer CLOSE_PARENTHESIS END { 
  }; 


%%

#define DEFAULT_OUTFILE "Main.class"

void writeHexToFile(char* hexString, FILE* file);

int main(int argc, char **argv)
{
    char* head = "CA FE BA BE 00 00 00 34 00 0F 0A 00 03 00 0C 07 00 0D 07 00 0E 01 00 06 3C 69 6E 69 74 3E 01 00 03 28 29 56 01 00 04 43 6F 64 65 01 00 0F 4C 69 6E 65 4E 75 6D 62 65 72 54 61 62 6C 65 01 00 04 6D 61 69 6E 01 00 16 28 5B 4C 6A 61 76 61 2F 6C 61 6E 67 2F 53 74 72 69 6E 67 3B 29 56 01 00 0A 53 6F 75 72 63 65 46 69 6C 65 01 00 09 4D 61 69 6E 2E 6A 61 76 61 0C 00 04 00 05 01 00 04 4D 61 69 6E 01 00 10 6A 61 76 61 2F 6C 61 6E 67 2F 4F 62 6A 65 63 74 00 21 00 02 00 03 00 00 00 00 00 02 00 01 00 04 00 05 00 01 00 06 00 00 00 1D 00 01 00 01 00 00 00 05 2A B7 00 01 B1 00 00 00 01 00 07 00 00 00 06 00 01 00 00 00 09 00 09 00 08 00 09 00 01 00 06 00 00 00 19 00 00 00 01 00 00 00 01";
    char* tail = "B1 00 00 00 01 00 07 00 00 00 06 00 01 00 00 00 23 00 01 00 0A 00 00 00 02 00 0B";
    FILE * filePtr;
    filePtr = fopen(DEFAULT_OUTFILE, "wb");
    if(filePtr == NULL)
    {
        printf("Unable to create file.\n");
        exit(EXIT_FAILURE);
    }
    writeHexToFile(head, filePtr);
    yyparse();
    writeHexToFile(tail, filePtr);
    fclose(filePtr);
    exit(0);
}

void writeHexToFile(char* hexString, FILE* file){
    int strLen = strlen(hexString);
    while (strLen > 0){
        char * remainingStr;
        char currentChunk = strtol(hexString, &remainingStr, 16);
        fwrite(&currentChunk, sizeof(char), 1, file);
        remainingStr++;
        hexString = remainingStr;
        strLen -= 3;
    }
    return;
}
