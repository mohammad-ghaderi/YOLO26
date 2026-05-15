// load_weights.c
#include "loader.h"
#include <stdio.h>

float params[NUM_PARAM];

int load_weights(void) {
    FILE *fp = fopen("params/param.bin", "rb");
    if (!fp) return -1;
    
    size_t n = fread(params, sizeof(float), NUM_PARAM, fp);
    fclose(fp);
    
    return (n == NUM_PARAM) ? 0 : -1;
}