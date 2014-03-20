all:
	yacc -d parse.y
	lex parse.lex
	gcc -o YLash y.tab.c lex.yy.c

no_parser: parse.lex
	lex parse.lex
	gcc -o YLash -g lex.yy.c

.PHONY: clean
clean:
	rm -rf YLash *.tab.* *.yy.c