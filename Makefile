# MakeFile for Flamingo Language

# programs with their parameters
GCC=gcc -g -pedantic -Wall
YACC=yacc -d
LEX=lex

.PHONY: lex
lex: lex.yy.c

.PHONY: yacc
yacc: y.tab.c

.PHONY: all
all: lex yacc flamingo

flamingo: lex.yy.c y.tab.c
	$(GCC) lex.yy.c y.tab.c -o flamingompiler

y.tab.c: fYacc.y
	$(YACC) fYacc.y

lex.yy.c: y.tab.c fLex.l
	$(LEX) fLex.l


.PHONY: clean
clean:
			rm -rf *.o *.bin *.out
			rm -rf flamingo lex.yy.c y.tab.c y.tab.h
			rm -rf *.dSYM


####################################################################################################

#fake exists to test yacc programs
.PHONY: fake
fake: yacc fake_lex flamingo

fake_lex: y.tab.c fakeLex.l
	$(LEX) fakeLex.l
