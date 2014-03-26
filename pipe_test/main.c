#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>

#define PS "/bin/ps"
#define XARGS "/usr/bin/xargs"
#define GREP "/bin/grep"

int main(int argc, char **argv) {
  int pipe_fd[2];
  pid_t pid;

  if(-1 == pipe (pipe_fd)) {
    perror ("pipe");
    exit (1);
  }

  pid = fork();
  if (-1 == pid) {
    close (pipe_fd[0]);
    close (pipe_fd[1]);
    perror ("fork");
    exit (1);
  } else if (!pid) {
    close (pipe_fd[0]);
    dup2 (pipe_fd[1], STDOUT_FILENO);
    if (-1 == execl (PS, "ps", "ax", (char *) NULL)) {
      perror ("execl");
      exit (1);
    }
  } else {
    int status;
    if (-1 == waitpid (pid, &status, 0)) {
      close (pipe_fd[0]);
      close (pipe_fd[1]);
      fprintf (stderr, "Problem executing: %s\n", PS);
      exit (1);
    }

    pid = fork();
    if (-1 == pid) {
      close (pipe_fd[0]);
      close (pipe_fd[1]);
      perror ("fork");
      exit (1);
    } else if (!pid) {
      close (pipe_fd[1]);
      dup2 (pipe_fd[0], STDIN_FILENO);
      if (-1 == execl ("/bin/grep", "grep", "bash", (char *) NULL)) {
	perror ("execl failed");
	exit (1);
      }
    } else {
      close (pipe_fd[0]);
      close (pipe_fd[1]);
      if (-1 == waitpid (pid, &status, 0)) {
	close (pipe_fd[0]);
	close (pipe_fd[1]);
	fprintf (stderr, "Problem executing: %s\n", XARGS);
	exit (1);
      }
    }
  }

  return 0;
}
