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
"jobs"          { printf("matched jobs\n"); BEGIN CMD; return JOBS;                                          }
"set"           { printf("matched set\n");  BEGIN CMD; return SET;                                           }
"cd"            { printf("matched cd\n");   BEGIN CMD; return CD;                                            }
{quit}          { cleanup_and_exit();                                                                        }
"|"             { printf("matched '|'\n");  BEGIN 0; return PIPE;                                            }
"&"             { printf("matched '&'\n");  BEGIN 0; return BCKGRND_EXEC;                                    }
<CMD>{argument} { printf("matched argument %s\n", yytext); yylval.string = yytext;          return ARGUMENT; }
{command}       { printf("matched token: %s\n", yytext); BEGIN CMD; yylval.string = yytext; return COMMAND;  }
\n              { printf("matched end of line\n"); BEGIN 0; ++yylineno; return EOL;                          }

%%

void
cleanup_and_exit(void) {
   exit (0);
}

void
yyerror(char * s) {
  fprintf(stderr, "%d: %s at %s\n", yylineno, s, yytext);
}





