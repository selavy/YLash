#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>

#define RECV 2
#define SEND 1
#define UNUSED 0 
#define BACKGROUND 1
#define FOREGROUND 0

struct command {
  char cmd[256];
  char argument[256];
  int using_pipe;
  int pipe_fd[2];
  int background;
  pid_t pid;
};

struct command * add_command (char * cmd_str, char * argument, int background);
void connect_commands (struct command * from, struct command * to);
void execute_command (struct command * cmd);

int main (int argc, char **argv) {
  struct command *command1, *command2, *command3;
  
  command1 = add_command ("/bin/ls", "-a", FOREGROUND);
  command2 = add_command ("/bin/grep", "main.c", FOREGROUND);
  command3 = add_command ("/usr/bin/xargs", "echo", FOREGROUND);
  connect_commands (command1, command2);
  connect_commands (command2, command3);
  execute_command (command1);
  execute_command (command2);
  execute_command (command3);
  
  return 0;
}

void connect_commands (struct command * from, struct command * to) {
  int pipe_fd[2];

  if( (from == NULL) || (to == NULL)) {
    fprintf (stderr, "Tried to connect with a NULL command\n");
    return;
  }

  if(-1 == pipe(pipe_fd)) {
    perror ("pipe");
    return;
  }
  
  from->using_pipe |= SEND;
  to->using_pipe |= RECV;
  from->pipe_fd[1] = pipe_fd[1];
  to->pipe_fd[0] = pipe_fd[0];
}

void execute_command (struct command * cmd) {
  pid_t pid;
  if (cmd == NULL) return;

  pid = fork();
  if (-1 == pid) {
    perror ("fork");
    return;
  } else if (!pid) {
    if (cmd->using_pipe != UNUSED) {
      if (0 != (cmd->using_pipe & RECV)) {
	dup2 (cmd->pipe_fd[0], STDIN_FILENO);
      } else {
	if (cmd->pipe_fd[0] != 0) close (cmd->pipe_fd[0]);
      }
      if (0 != (cmd->using_pipe & SEND)) {
	dup2 (cmd->pipe_fd[1], STDOUT_FILENO);
      } else {
	if (cmd->pipe_fd[1] != 0) close (cmd->pipe_fd[1]);
      }
    }

    if (-1 == execl (cmd->cmd, cmd->cmd, cmd->argument, (char *) NULL)) {
      fprintf(stderr, "Unable to execute: %s\n", cmd->cmd);
      return;
    }
  } else {
    if (cmd->using_pipe != UNUSED) {
      if(0 != (cmd->using_pipe & RECV)) {
	close (cmd->pipe_fd[0]);
      }
      if(0 != (cmd->using_pipe & SEND)) {
	close (cmd->pipe_fd[1]);
      }
    }
   
    if (cmd->background == FOREGROUND) {
      int status;
      if (-1 == waitpid (pid, &status, 0)) {
	fprintf (stderr, "Problems executing: %s\n", cmd->cmd);
	return;
      }
    }
    return;
  }
}

struct command * add_command (char * cmd_str, char * argument, int background) {
  struct command * cmd = malloc (sizeof (*cmd));
  memcpy (cmd->cmd, cmd_str, strlen (cmd_str) + 1);
  memcpy (cmd->argument, argument, strlen (argument) + 1);
  cmd->background = background;
  cmd->pipe_fd[0] = 0; cmd->pipe_fd[1] = 0;
  return cmd;
}

