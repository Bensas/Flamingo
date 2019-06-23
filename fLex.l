%{
	#include <stdio.h>
	#include <stdlib.h>
%}


%option noyywrap

digit          [0-9]
string		   \"[^\"]*\"
number         -?[0-9]+(\.[0-9]+)?
variableName   [a-zA-Z]+
gate           (X|Y|Z|H|CNOT|ID)

%%
"&&"			{ return AND; }
"||"			{ return OR; }
"<="			{ return SMALLER_OR_EQ; }
">="			{ return GREATER_OR_EQ; }
"=="			{ return EQ; }
"!="			{ return NOT_EQ; }
("{")			{ return OPEN_BRACKET; }
("}")			{ return CLOSE_BRACKET; }
";"             { return END; }
"="				{ return ASSIGN; }
"("				{ return OPEN_PARENTHESIS; }
")"				{ return CLOSE_PARENTHESIS; }
"|"             { return PIPE; }
"!"				{ return NOT; }
"-"				{ return MINUS; }
"+"				{ return PLUS; }
"/"				{ retutn DIVIDE; }
"*"				{ return MULTIPLY; }
"%"				{ return MODULO; }
"<"				{ return SMALLER; }
">"				{ return GREATER; }
{gate}			{ yylval.symp = symlook(yytext); return GATE;}
"M"             { return MEASURE; }
"if"            { return IF; }
"else"          { return ELSE; }
"while"         { return WHILE; }
"FLAMINGO"		{ return PRINT; }
"Int"			{ return DECL_INT; }
"String"		{ return DECL_STRING; }
"Register"		{ return DECL_REGISTER; }
{number}        { yylval.num = atoi(yytext); return NUMBER; }
{variableName}  { yyval.id = strdup(yytext); return ID; }
{string}		{ yylval.string = strdup(yytext); return STRING;}
.				{ /* ignorare other characters */ }

%%
