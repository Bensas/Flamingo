/* this lex exists for testing yacc only  */

%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
int yylex();
void yyerror (char *s);
%}

%%
[0-9]+              {yylval.value = atoi(yytext);return NUMBER;}
"true"              {return TRUE;}
"false"             {return FALSE;}
"&&"			    { return AND; }
"||"		    	{ return OR; }
"!"				    { return NOT; }
"<="	    		{ return SMALLER_OR_EQ; }
">="		    	{ return GREATER_OR_EQ; }
">"                 { return GREATER_THAN; }
"<"                 { return SMALLER_THAN; }
"=="	    		{ return EQ; }
"!="	    		{ return NOT_EQ; }
"exit"              { return EXIT; }
"if"                { return IF; }
"else"              { return ELSE; }
"while"             { return WHILE; }
"FLAMINGO"		    { return PRINT; }
"do"                { return DO; }
[-+*/%=;{}()]       { return yytext[0]; }
\"[a-zA-Z0-9 _-]+\"    { yylval.string = strdup(yytext);return STRING; }
[a-zA-Z0-9_-]+      { yylval.string = strdup(yytext); strcpy(yylval.string, yytext);return IDENTIFIER; }
[\n]+               ;
[ \t]+              ;

%%