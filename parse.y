%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "arglist.h"
#include "execute_command.h"

  int number_of_arguments = 0;

  struct list * arglist;

  void add_argument(char * s);
  void clear_arguments();
  void print_arguments();
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
%type <string> jobs_command
%type <string> cd_command
%type <string> set_command

%%

input: /* empty string */
| input command { print_arguments(); clear_arguments(); }
;

command: EOL
| COMMAND EOL                 { printf("no arguments: %s\n", $1); }
| jobs_command
| cd_command
| set_command
| command_with_argument EOL  
| command_with_argument PIPE command { printf("piped command\n"); }
| COMMAND PIPE command               { printf("piped command\n"); }
;

command_with_argument: COMMAND ARGUMENT { add_argument($2); }
| command_with_argument ARGUMENT        { add_argument($2); }
;

jobs_command: JOBS EOL { printf("execute jobs command\n"); $$ = ""; }
;

set_command: SET ARGUMENT ARGUMENT EOL { printf("execute set command\n"); $$ = ""; }
;

cd_command: CD ARGUMENT EOL { printf("execute cd command\n"); $$ = ""; }
;
 
%%

int
main(void) {
  /*
   * initialize arglist
   */
  arglist = NULL;
  yyparse();	
  
  /*
   * get rid of anything that might still be left to not leak memory.
   */
  clear_arguments();
}

/*
 * add_argument()
 * s: must be a valid c-string
 */
void
add_argument(char * s) {
  struct list * arg = malloc(sizeof(*arg));
  if(!arg) {
    perror("malloc failed\n");
    exit(1);
  }
  arg->arg_sz = strlen(s) + 1;
  arg->arg = malloc(arg->arg_sz);
  if(!arg->arg) {
    perror("malloc failed\n");
    exit(1);
  }
  strcpy(arg->arg, s);

  if(!arglist) {
    arg->next = NULL;
    arglist = arg;

  } else {
    arg->next = arglist;
    arglist = arg;
  }
  ++number_of_arguments;
}

void
clear_arguments() {
  struct list * arg = arglist;
  struct list * tmp;
  while(arg) {
    tmp = arg->next;
    free(arg->arg);
    arg->next = NULL;
    free(arg);
    arg = tmp;
  }
  arglist = NULL;
}

void
print_arguments() {
  struct list * arg = arglist;
  while(arg) {
    printf("%s\n", arg->arg);
    arg = arg->next;
  }
}
