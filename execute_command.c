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
  char ** arg = args;
  int i = 1;
  printf("EXECUTING COMMAND\n");
  printf("command:\t%s\n", cmd);
  if(*arg) {
    printf("arguments:\n");
    while(*arg) {
      printf("%d:\t%s\n", i++, *arg);
      ++arg;
    }
  }

  free_arglist(args);
  return 1;
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
