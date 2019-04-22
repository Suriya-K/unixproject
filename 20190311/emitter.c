
#include <math.h>
#include <stdio.h>
#include "emitter.h"
void emit(char *msg, double v){
 double newv=round(v);
 
 printf("%lf becomes %lf: %s\n", v, newv, msg);
 fflush(stdout);
 return;
}
