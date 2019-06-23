/* this lex exists for testing yacc only  */

%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
int yylex();
void yyerror (char *s);
%}

%%
[0-9]+ {yylval.value = atoi(yytext);return NUMBER;}
"true" {yylval.value = 1;return TRUE;}
"false" {yylval.value = 0;return FALSE;}
"&&"			{ return AND; }
"||"			{ return OR; }
"!"				{ return NOT; }
"<="			{ return SMALLER_OR_EQ; }
">="			{ return GREATER_OR_EQ; }
"=="			{ return EQ; }
"!="			{ return NOT_EQ; }
"exit"          { return EXIT; }
\"[a-zA-Z0-9]+\" {yylval.string = (char*)malloc(strlen(yytext));strcpy(yylval.string, yytext);return STRING;}
[a-zA-Z]+ {yylval.string = (char*)malloc(strlen(yytext)); strcpy(yylval.string, yytext);return IDENTIFIER;}
[-+*/%()=;] {return yytext[0];}
[\n]+   ;
[ \t]+  ;
%% 