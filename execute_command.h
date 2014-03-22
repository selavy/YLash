#ifndef _EXECUTE_COMMAND_
#define _EXECUTE_COMMAND_

#include "general.h"
#include "environment.h"

extern char ** environ;

int jobs_command(void);
int cd_command(char * arg);
int set_command(char * var, char * val);
int execute_command(char * cmd, char ** args, int in_background);
void check_background_processes(void);

#endif
