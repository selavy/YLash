#ifndef _GENERAL_
#define _GENERAL_

#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>

#ifndef TRUE
#define TRUE 1
#endif
#ifndef FALSE
#define FALSE 0
#endif

#define PIPE_UNUSED 1
#define SEND 2
#define RECV 4
#define BACKGROUND_EXEC 8
#define FOREGROUND_EXEC 0

struct command {
  char * command;
  char ** arguments;
  int pipe_fd[2];
  int flags;
  pid_t pid;
};

#endif
