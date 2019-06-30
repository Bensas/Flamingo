%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "parser.h"
	#include "y.tab.h"

	extern int lineNum;
%}


%option noyywrap

string		   \"[^\"]*\"
integer 	   [0-9]+
float          [0-9]+\.[0-9]+
variableName   [a-zA-Z]+
gate           (X|Y|Z|H|CNOT|ID)
qbitString     \|[01]+>
comment 	   \/\/.*
newline		   \n

%%
{comment}		{}
"!"				{ yylval.string = strdup(yytext); return SINGLE_TERM_OP; }
"&&"			{ yylval.string = strdup(yytext); return DOUBLE_TERM_OP; }
"||"			{ yylval.string = strdup(yytext); return DOUBLE_TERM_OP; }
"<"				{ yylval.string = strdup(yytext); return RELATIONAL_OP; }
">"				{ yylval.string = strdup(yytext); return RELATIONAL_OP; }
"<="			{ yylval.string = strdup(yytext); return RELATIONAL_OP; }
">="			{ yylval.string = strdup(yytext); return RELATIONAL_OP; }
"=="			{ yylval.string = strdup(yytext); return RELATIONAL_OP; }
("{")			{ return OPEN_BRACKET; }
("}")			{ return CLOSE_BRACKET; }
";"             { return END; }
"="				{ return ASSIGN; }
"("				{ return OPEN_PARENTHESIS; }
")"				{ return CLOSE_PARENTHESIS; }
"|"             { return PIPE; }
"-"				{ return MINUS; }
"+"				{ return PLUS; }
"/"				{ return DIVIDE; }
"*"				{ return MULTIPLY; }
"%"				{ return MODULO; }
{gate}			{ yylval.gate = strdup(yytext); return GATE;}
"M"             { return MEASURE; }
"if"            { return IF; }
"else"          { return ELSE; }
"do"			{ return DO; }
"while"         { return WHILE; }
"FLAMINGO"		{ return PRINT; }
"Int"			{ return DECL_INT; }
"Float"			{ return DECL_FLOAT; }
"String"		{ return DECL_STRING; }
"Reg"			{ return DECL_REGISTER; }
"exit"			{ return EXIT;}
"TRUE"			{	return TRUE;}
"FALSE"			{	return FALSE;}
{integer}       { yylval.number.value = atof(yytext); return INTEGER_NUMBER; }
{float}         { yylval.number.value = atof(yytext); return FLOAT_NUMBER; }
{variableName}  { yylval.id = symlook(yytext); return ID; }
{string}		{ yylval.string = strdup(yytext); return STRING;}
{qbitString}	{ yylval.string = strdup(yytext); return QBIT_STR;}
{newline}		{ lineNum++;}
.				{ /* ignore other characters */ }

%%
