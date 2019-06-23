/* this lex exists for testing yacc only  */

%{
#include <stdio.h>
#include "y.tab.h"
int yylex();
void yyerror (char *s);
%}

%%
[0-9]+ {yylval.value = atoi(yytext);return Number;}
"true" {yylval.value = 1;return TRUE;}
"false" {yylval.value = 0;return FALSE;}
"&&"			{ return AND; }
"||"			{ return OR; }
"!"				{ return NOT; }
"<="			{ return SMALLER_OR_EQ; }
">="			{ return GREATER_OR_EQ; }
"=="			{ return EQ; }
"!="			{ return NOT_EQ; }
[a-zA-Z]+ {yylval.string = (char*)malloc(strlen(yytext)); strcpy(yylval.string, yytext);return Identifier;}
[-+*/%()=;] {return yytext[0];}
[\n]+   ;
[ \t]+  ;
%% 