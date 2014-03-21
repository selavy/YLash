#ifndef _EXECUTE_COMMAND_
#define _EXECUTE_COMMAND_

#include <stdio.h>
#include <stdlib.h>
#include "arglist.h"

int jobs_command();
int cd_command();
int set_command();
int execute_command(char * cmd, char ** args);

#endif
