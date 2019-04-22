//60160240 chonphisit seangwitthayanon Group 1
#include <cstdlib>
#include <iostream>
#include <ctime>
#include <cmath>
#include "emitter.hpp"

int main(void){
 double d;

 srand((unsigned int)time(NULL));
 d=(double)rand()+M_PI;
 emit("Hello, World!",d);
 return EXIT_SUCCESS;
}
