#include "execute_command.h"

static void free_arglist(char ** arglist);

int
jobs_command() {
  return 1;
}

int
cd_command(char * arg) {
  return 1;
}

int
set_command(char * args) {
  return 1;
}

int
execute_command(char * cmd, char ** args) {
  pid_t pid = fork();
  if(pid == -1) {
    perror("fork");
    return -1;
  } else if(!pid) {
    if( -1 == execvpe(cmd, args, get_environment()) ) {
      fprintf(stderr, "%s: command not recognized\n", cmd);
      return -1;
    }
  } else {
    int status;
    if(-1 == waitpid( pid, &status, 0 ) ) {
      fprintf(stderr, "Error calling %s\n", cmd);
    }
    return 0;
  }
}

static void
free_arglist(char ** arglist) {
  char ** arg = arglist;
  while(*arg) {
    free(*arg);
    ++arg;
  }
  free(arglist);
}
