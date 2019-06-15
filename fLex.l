%{
	#include <stdio.h>
	#include <stdlib.h>
%}

%option noyywrap

digit          [0-9]
string		   \"[^\"]*\"
number         -?[0-9]+(\.[0-9]+)?
variable       [a-zA-Z]+

%%
"&&"			{ printf("Conjunction"); }
"||"			{ printf("Disyunction"); }
"<="			{ printf("Smaller or equal"); }
">="			{ printf("Bigger or equal"); }
"=="			{ printf("Equal"); }
"!="			{ printf("Not equal"); }
("{")			{ printf("Open key"); }
("}")			{ printf("Closed key"); }
";"             { printf("Semi colon"); }
"="				{ printf("Assignment"); }
"("				{ printf("Open parenthesis"); }
")"				{ printf("Closed parenthesis"); }
"|"             { printf("Pipe"); }
"!"				{ printf("Negation"); }
"-"				{ printf("Substraction"); }
"+"				{ printf("Sum"); }
"/"				{ printf("Division"); }
"*"				{ printf("Multiplication"); }
"%"				{ printf("Module"); }
"<"				{ printf("Smaller"); }
">"				{ printf("Bigger"); }
"H"             { printf("Applies Hadamard"); }
"X"             { printf("Applies X gate"); }
"Y"             { printf("Applies Y gate"); }
"Z"             { printf("Applies Z gate"); }
"CNOT"          { printf("Applies CNOT gate"); }
"ID"            { printf("Applies ID gate"); }
"M"             { printf("Measures the state of a qubit"); }
"if"            { printf("If conditional"); }
"else"          { printf("Else conditional"); }
"while"         { printf("While loop"); }
"FLAMINGO"		{ printf("Our printf"); }
{number}        { printf("This is a number"); }
{variable}    	{ printf("This is a variable"); }
{string}		{ printf("This is a string"); }
.				{ /* ignorare other characters */ }

%%
