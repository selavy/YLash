%{
#include <stdio.h>
#include <stdlib.h>
%}

%union {
  char * string;
}

%token <string> JOBS
%token <string> SET
%token <string> CD
%token <string> PIPE
%token <string> BCKGRND_EXEC
%token <string> EOL
%token <string> COMMAND
%token <string> ARGUMENT

%type <string> command
%type <string> command_with_argument

%%

input: /* empty string */
| input command
;

command: COMMAND EOL         { printf("no arguments: %s\n", $$); }
| command_with_argument EOL  { printf("arguments: %s\n", $$); }
| command_with_argument PIPE command { printf("piped command\n"); }
| COMMAND PIPE command { printf("piped command\n"); }
;

command_with_argument: COMMAND ARGUMENT
| command_with_argument ARGUMENT
;
 
%%

int
main(void) {
  yyparse();	
}
