#ifndef _EXECUTE_COMMAND_
#define _EXECUTE_COMMAND_

#include <stdio.h>
#include "arglist.h"

int jobs_command();
int cd_command();
int set_command();
int execute_command(char * cmd, struct list * args, unsigned int number_of_args );

#endif
