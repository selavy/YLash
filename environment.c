#include "environment.h"

static char ** envp = NULL;

char ** get_environment() {
  return envp;
}

void set_environment( char ** env ) {
  envp = env;
}
