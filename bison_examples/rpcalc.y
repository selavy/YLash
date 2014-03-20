%{
#define YYSTYPE double
#include <math.h>
#include <ctype.h>
#include <stdio.h>

  void yyerror(char * s);
%}

%token NUM

%%

input: /* empty */
       | input line
       ;

line: '\n'
| exp '\n' { printf("\t%.10g\n", $1); }
;

exp: NUM { $$ = $1; }
| exp exp '+' { $$ = $1 + $2; }
| exp exp '-' { $$ = $1 - $2; }
| exp exp '*' { $$ = $1 * $2; }
| exp exp '/' { $$ = $1 / $2; }
| exp exp '^' { $$ = pow ($1, $2); }
| exp 'n' { $$ = -$1; }
;
%%

void
yyerror(char *s) {
  printf("%s\n", s);
}

int
yylex()
{
  int c;
  while((c = getchar()) == ' ' || c == '\t');
  /* process numbers */
  if( c == '.' || isdigit(c)) {
    ungetc(c,stdin);
    scanf("%lf", &yylval);
    return NUM;
  }
  if(c == EOF) return 0;
  return c;
}

int
main() {
  yyparse();
  return 0;
}
