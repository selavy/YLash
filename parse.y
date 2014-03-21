%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "arglist.h"
#include "execute_command.h"

  extern char * yytext;

  int number_of_arguments;
  struct list * arglist;
  char * current_command;

  void add_argument(char * s);
  void clear_arguments();
  void print_arguments();
  char** package_arglist();
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
%type <string> other_command

%%

input: /* empty string */
| input command { clear_arguments(); printf("> "); }
;

command: EOL
| COMMAND EOL {
  char ** args = package_arglist();
  execute_command($1, args);
  clear_arguments();
 }
| jobs_command
| cd_command
| set_command
| command_with_argument EOL   {
  char ** args = package_arglist();
  execute_command(current_command, args);
  clear_arguments();
  free(current_command);
  }
| command_with_argument PIPE command 
| COMMAND PIPE command 
;

other_command: COMMAND {
  $$ = strdup(yytext);
  current_command = malloc(strlen($1) + 1);
  if(!current_command) {
    fprintf(stderr, "malloc failed\n");
    exit(1);
  }
  strcpy(current_command, $1);
 }
;

command_with_argument: other_command ARGUMENT { add_argument($2); }
| command_with_argument ARGUMENT              { add_argument($2); }
;

jobs_command: JOBS EOL { jobs_command(); }
;

set_command: SET ARGUMENT ARGUMENT EOL { set_command(); }
;

cd_command: CD ARGUMENT EOL { cd_command(); }
;
 
%%

int
main(int argc, char **argv, char **envp) {
  /*
   * initialize arglist
   */
  arglist = NULL;
  number_of_arguments = 0;

  printf("> ");
  /*
   * call the parser
   */
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
    fprintf(stderr, "malloc failed\n");
    exit(1);
  }
  arg->arg_sz = strlen(s) + 1;
  arg->arg = malloc(arg->arg_sz);
  if(!arg->arg) {
    fprintf(stderr,"malloc failed\n");
    exit(0);
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
  number_of_arguments = 0;
}

void
print_arguments() {
  struct list * arg = arglist;
  while(arg) {
    printf("%s\n", arg->arg);
    arg = arg->next;
  }
}

char **
package_arglist() {
  char ** packaged;
  if(number_of_arguments == 0) {
    packaged = malloc(sizeof(*packaged));
    if(!packaged) {
      fprintf(stderr, "malloc failed\n");
      exit(1);
    }
    packaged[0] = (char *) NULL;
    return packaged;
  } else {
    int i;
    struct list * arg = arglist;
    packaged = malloc(sizeof(*packaged) * (number_of_arguments + 1));
    
    for(i = 0; i < number_of_arguments; ++i) {
      packaged[i] = malloc(arg->arg_sz);
      if(!packaged[i]) {
	fprintf(stderr, "malloc failed\n");
	exit(1);
      }
      strcpy(packaged[i], arg->arg);
      arg = arg->next;
    }
    packaged[i] = (char *) NULL; /* sentinel value */
    return packaged;
  }
}
