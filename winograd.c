#include <stdio.h>
#include "conv.h"
#include "tools/tools.h"
#include <time.h>

void winograd_f23(float *input, float *weights, float *output, int SIZE, int IC, int OC) {
    
    for (int ih = 0; ih < SIZE; ih+=2) {
        for (int iw = 0; iw < SIZE; iw+=2) {
            float *inp_tile = input + (ih*(SIZE+2)+iw)*IC;

            winograd_f23_v1(inp_tile, weights, output+(ih*SIZE+iw)*OC, output+((ih+1)*SIZE+iw)*OC, IC, OC, IC*(SIZE+2)*4);

        }
    }
}