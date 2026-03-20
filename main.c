#include <stdio.h>
#include <string.h>
#include "tools.h"
#define MAX_SIZE 9000000

int8_t input[MAX_SIZE];
int8_t weights[MAX_SIZE];
int32_t output[MAX_SIZE];
const int SIZE = 4, IC = 16, OC = 16;

extern void add_padding(int8_t *arr, int size, int IC);


int main() {
    fillArrayWithRandom(input, SIZE*SIZE*IC*10);
    fillArrayWithRandom(weights, 9*IC*OC);

    writeArrayToFile(input, SIZE*SIZE*IC, "out/input.txt", "%d", sizeof(int8_t));
    writeArrayToFile(weights, 9*IC*OC, "out/weights.txt", "%d", sizeof(int8_t));
    
    add_padding(input, SIZE, IC);


    return 0;
}