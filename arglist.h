#ifndef _ARGLIST_
#define _ARGLIST_

struct list {
  char * arg;
  size_t arg_sz;
  struct list * next;
};

#endif
