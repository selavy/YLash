#include "execute_command.h"

struct joblist {
  struct joblist * next;
  struct joblist * prev;
  pid_t pid;
  unsigned int jobid;
  char * command;
};

static struct joblist * jobs = NULL;
static unsigned int next_job_id = 0;
static void free_arglist(char ** arglist);
static int add_job( pid_t pid, char * command );

static int
add_job( pid_t pid, char * command ) {
  struct joblist * job = malloc(sizeof(*job));
  if(!job) {
    fprintf(stderr, "malloc failed\n");
    return -1;
  }

  job->pid = pid;
  job->jobid = next_job_id++;
  job->command = strdup(command);
  if(!job->command) {
    fprintf(stderr, "malloc failed\n");
    free(job);
    return -1;
  }

  if(jobs) jobs->prev = job;
  job->next = jobs;
  job->prev = NULL; /* don't really need to do this, but just in case */
  jobs = job;

  printf("[%d] %d running in background\n", job->jobid, pid);
  return 0;
}

void
check_background_processes(void) {
  struct joblist * p = jobs;
  while(p) {
    /*int result = kill(p->pid, 0); 
    printf("result = %d\n", result);
    if ((-1 == result) && (errno == ESRCH)) { */
    int status;
    if(waitpid(p->pid, &status, WNOHANG) > 0) {
      /* process no longer exists */
      struct joblist * prev = p->prev;
      struct joblist * next = p->next;
      printf ("[%d] %d finished %s\n", p->jobid, p->pid, p->command);
      free (p->command);
      
      if (prev) prev->next = next;
      if (next) next->prev = prev;
      if (jobs == p) jobs = p->next;
      free (p);
      p = next;
    }
    else p = p->next;
  }
}

int
jobs_command(void) {
  struct joblist * job;
  check_background_processes();
  job = jobs;
  while(job) {
    printf("[%d] %d %s\n", job->jobid, job->pid, job->command);
    job = job->next;
  }
  return 0;
}

int
cd_command(char * arg) {
  /*
   * Maybe in the future I will want to change this to just:
   * return chdir(arg);
   */
  if(-1 == chdir(arg)) {
    fprintf(stderr, "unable to change to: %s\n", arg);
    return -1;
  }
  return 0;
}

int
set_command(char * var, char * val) {
  setenv(var, val, 1);
  return 0;
}

int
execute_command(char * cmd, char ** args, int in_background) {
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
    if(in_background) {
      add_job( pid, cmd );
    } else {
      int status;
      if(-1 == waitpid( pid, &status, 0 ) ) {
	fprintf(stderr, "Error calling %s\n", cmd);
      }
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
