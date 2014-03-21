%option noyywrap
%{
/*
* Lexical analyzer for YLash
*/

#include <stdlib.h>
#include "y.tab.h"

void cleanup_and_exit();
%}

%s CMD

ws [ \t]+
quit ("quit"|"exit")
argument [^ \t\n]+
command [^ \t\n]+

%%

{ws}            /*        ignore whitespace                                                                */;
"jobs"          { BEGIN CMD; return JOBS;                                          }
"set"           { BEGIN CMD; return SET;                                           }
"cd"            { BEGIN CMD; return CD;                                            }
{quit}          { cleanup_and_exit();                                                                        }
"|"             { BEGIN 0; return PIPE;                                            }
"&"             { BEGIN 0; return BCKGRND_EXEC;                                    }
<CMD>{argument} { yylval.string = yytext;          return ARGUMENT; }
{command}       { BEGIN CMD; yylval.string = yytext; return COMMAND;  }
\n              { BEGIN 0; ++yylineno; return EOL;                          }

%%

void
cleanup_and_exit(void) {
   exit (0);
}

void
yyerror(char * s) {
  fprintf(stderr, "%d: %s at %s\n", yylineno, s, yytext);
}





