
%{
#include <stdio.h>
#include "y.tab.h"
int yylex();
void yyerror (char *s);
%}

%%
[0-9]+ {printf("found num\n");return Num;}
[a-zA-Z]+ {printf("found identifier\n");return Identifier;}
= {printf("found equals\n");return Equals;}
; {printf("found colon\n");return Colon;}
[\n]+;
[ \t]+;
%%