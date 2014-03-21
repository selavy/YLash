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
%type <string> jobs_command
%type <string> cd_command
%type <string> set_command

%%

input: /* empty string */
| input command
;

command: COMMAND EOL                 { printf("no arguments: %s\n", $1); }
| jobs_command
| cd_command
| set_command
| command_with_argument EOL  
| command_with_argument PIPE command { printf("piped command\n"); }
| COMMAND PIPE command               { printf("piped command\n"); }
;

command_with_argument: COMMAND ARGUMENT { printf("argument: %s\n", $2); }
| command_with_argument ARGUMENT        { printf("argument: %s\n", $2); }
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
  yyparse();	
}
