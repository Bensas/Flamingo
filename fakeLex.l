/* this lex exists for testing yacc only  */

%{
#include <stdio.h>
#include "y.tab.h"
int yylex();
void yyerror (char *s);
%}

%%
[0-9]+ {yylval.value = atoi(yytext);return Number;}
[a-zA-Z]+ {return Identifier;}

[-+*/%()=;] {return yytext[0];}
[\n]+;
[ \t]+;
%%
