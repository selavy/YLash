CC = gcc
YACC = yacc
LEX = lex
CFLAGS = -g

OBJS = execute_command.o parse.o environment.o

YLash: $(OBJS)
	$(CC) -o YLash $(CFLAGS) $(OBJS)
parse.o: parse.c parse.h
	$(CC) -c parse.c
parse.c: parse.lex
	$(LEX) -o parse.c parse.lex
parse.h: parse.y
	$(YACC) -o parse.h parse.y
execute_command.o: execute_command.h execute_command.c
	$(CC) $(CFLAGS) -c execute_command.c
environment.o: environment.h environment.c
	$(CC) $(CFLAGS) -c environment.c
.PHONY: clean
clean:
	rm -rf YLash *.o parse.h parse.c