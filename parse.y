%{

#include "general.h"
#include "execute_command.h"

  struct list {
    char * arg;
    struct list * next;
  };

  extern char * yytext;
  int number_of_arguments;
  struct list * arglist;
  struct list * tail;
  char * current_command = NULL;

  struct command * create_command (int flags);
  void add_argument (char * s);
  void clear_arguments ();
  void print_arguments ();
  char** package_arglist ();
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
%type <string> qerror
%type <string> pipe_error

%%

 /********************************************************************************/
 /*
  * Top level: matches either a command or a blank line
  * if blank line, just print the prompt again
  * if command then execute command and print prompt
  */
input: /* empty string */
| input EOL {
  printf("quash$> ");
 }
| input qerror {
  clear_arguments();
  if(current_command) {
    free(current_command);
    current_command = NULL;
  }
  printf("quash$> ");
 }
| input command {
  
  /*
   * Check if any of the background processes have finished
   */
  check_background_processes();

  /*
   * probably unnecessary, but it won't hurt anything
   * if the arguments have already been cleared
   */
  clear_arguments();

  if(current_command) {
    free(current_command);
    current_command = NULL;
  }

  /*
   * print the prompt again
   */
  printf("quash$> ");
 }
| error { yyerrok; printf("quash: syntax error"); yyclearin; }
;
 
 /**********************************************************************************/
command: COMMAND EOL {
  current_command = strdup ($1);
  exec_cmd (create_command (FOREGROUND_EXEC));
 }
| COMMAND BCKGRND_EXEC EOL {
  current_command = strdup($1);
  exec_cmd (create_command (BACKGROUND_EXEC));
 }
| jobs_command
| cd_command
| set_command
| command_with_argument EOL {
  exec_cmd (create_command (FOREGROUND_EXEC));
  }
| command_with_argument BCKGRND_EXEC EOL {
  exec_cmd (create_command (BACKGROUND_EXEC));
 }
| command_with_argument PIPE command { printf("single pipe\n"); }
| COMMAND PIPE command { printf("multiple pipes\n"); } 
;

 /**********************************************************************************/
other_command: COMMAND {
  current_command = strdup($1);
 }
;

 /**********************************************************************************/
qerror: pipe_error
;

 /**********************************************************************************/
pipe_error: COMMAND PIPE EOL     { printf("Usage: [command] | [command]\n"); }
| command_with_argument PIPE EOL { printf("Usage: [command] | [command]\n"); }
| COMMAND BCKGRND_EXEC PIPE EOL  { printf("quash: syntax error near unexpected token '|'\n"); }
;

 /**********************************************************************************/
command_with_argument: other_command ARGUMENT { add_argument($2); }
| command_with_argument ARGUMENT              { add_argument($2); }
;

 /**********************************************************************************/
jobs_command: JOBS EOL { jobs_command(); }
;

 /**********************************************************************************/
set_command: SET ARGUMENT ARGUMENT EOL { set_command($2, $3); }
;

 /**********************************************************************************/
cd_command: CD ARGUMENT EOL { cd_command($2); }
;
 
%%

int
main(int argc, char **argv, char **envp) {
  /*
   * initialize arglist
   */
  arglist = NULL;
  number_of_arguments = 0;
  set_environment(envp);

  printf("quash$> ");
  /*
   * call the parser
   */
  yyparse();	
  
  /*
   * get rid of anything that might still be left to not leak memory.
   */
  clear_arguments();
}


struct command * create_command (int flags) {
  struct command * new_command = malloc (sizeof (*new_command));
  if (!new_command) {
    perror ("malloc");
    return NULL;
  }

  new_command->command = strdup (current_command);
  new_command->arguments = package_arglist();
  clear_arguments();
  new_command->pipe_fd[0] = 0;
  new_command->pipe_fd[1] = 0;
  new_command->flags = flags;
  return new_command;
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
  arg->arg = strdup(s);
  if(!(arg->arg)) {
    fprintf(stderr,"malloc failed\n");
    exit(1);
  }

  if(!arglist) {
    arg->next = NULL;
    arglist = arg;
    tail = arg;

  } else {
    tail->next = arg;
    tail = arg;
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
    packaged = malloc(sizeof(*packaged) * 2);
    if(!packaged) {
      fprintf(stderr, "malloc failed\n");
      exit(1);
    }
    packaged[0] = strdup(current_command);
    packaged[1] = (char *) NULL;
    return packaged;
  } else {
    int i;
    struct list * arg = arglist;
    packaged = malloc(sizeof(*packaged) * (number_of_arguments + 2));
    
    packaged[0] = strdup(current_command);
    for(i = 0; i < number_of_arguments; ++i) {
      packaged[i+1] = strdup(arg->arg);
      if(!packaged[i+1]) {
	fprintf(stderr, "malloc failed\n");
	exit(1);
      }
      arg = arg->next;
    }
    packaged[i+1] = (char *) NULL; /* sentinel value */
    return packaged;
  }
}
