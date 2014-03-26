#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>

#define PS "/bin/ps"
#define XARGS "/usr/bin/xargs"
#define GREP "/bin/grep"
#define LS "/bin/ls"
#define ECHO "/bin/echo"

int main (int argc, char **argv) {
  int status;
  int pipe_fd[2];
  int pipe2[2];
  pid_t pid;

  if (-1 == pipe (pipe_fd)) {
    perror ("pipe");
    exit (1);
  }

  pid = fork();
  if (-1 == pid) {
    perror ("fork");
    exit (1);
  } else if(!pid) {
    close (pipe_fd[0]);
    dup2 (pipe_fd[1], STDOUT_FILENO);
    if (-1 == execl (LS, "ls", (char *) NULL)) {
      perror ("execl");
      exit (1);
    }
  }

  if (-1 == waitpid (pid, &status, 0)) {
    fprintf (stderr, "Error executing: %s", LS);
    exit (1);
  }

  if(-1 == pipe (pipe2)) {
    perror ("pipe");
    exit (1);
  }

  pid = fork();
  if (-1 == pid) {
    perror ("fork");
    exit (1);
  } else if (!pid) {
    close (pipe_fd[1]);
    dup2 (pipe_fd[0], STDIN_FILENO);
    close (pipe2[0]);
    dup2 (pipe2[1], STDOUT_FILENO);
    if (-1 == execl (GREP, "grep", "main.c", (char *) NULL)) {
      perror ("execl"); 
      exit (1);
    }
  }

  close (pipe_fd[0]);
  close (pipe_fd[1]);

  if (-1 == waitpid (pid, &status, 0)) {
    fprintf (stderr, "Error executing: %s", GREP);
    exit (1);
  }

  pid = fork();
  if (-1 == pid) {
    perror ("fork");
    exit (1);
  } else if (!pid) {
    close (pipe2[1]);
    dup2 (pipe2[0], STDIN_FILENO);
    if (-1 == execl (XARGS, "echo", "echo", (char *) NULL)) {
      perror ("execl");
      exit (1);
    }
  }

  close (pipe2[0]);
  close (pipe2[1]);

  if (-1 == waitpid (pid, &status, 0)) {
    fprintf (stderr, "Error executing: %s\n", GREP);
    exit (1);
  }

  return 0;
}
