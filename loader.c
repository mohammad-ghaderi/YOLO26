// load_weights.c
#include "loader.h"
#include <stdio.h>

float params[NUM_PARAM];
unsigned char img[IMAGE_SIZE];

int load_weights(void) {
    FILE *fp = fopen("params/param.bin", "rb");
    if (!fp) return -1;
    
    size_t n = fread(params, sizeof(float), NUM_PARAM, fp);
    fclose(fp);
    
    return (n == NUM_PARAM) ? 0 : -1;
}

int load_image(void) {
    FILE *fp = fopen("params/img.bin", "rb");
    if (!fp) return -1;
    
    size_t n = fread(img, sizeof(unsigned char), IMAGE_SIZE, fp);
    fclose(fp);
    
    return (n == IMAGE_SIZE) ? 0 : -1;
}