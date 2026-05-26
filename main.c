#include <stdio.h>
#include <string.h>
#include <time.h>
#include "tools/tools.h"
#include "conv.h"
#include "loader.h"
#include <arm_neon.h>

#define STB_IMAGE_IMPLEMENTATION
#include "tools/stb_image.h"


float arr1[MAX_SIZE];
float arr2[MAX_SIZE];
float arr3[MAX_SIZE];

int SIZE = 640, IC = 3, OC = 16;
int stride = 2;

void SiLU(float *inp);
void SiLU_array(float *inp, int SIZE);
void SiLU_array_bias(float *inp, float *bias, int SIZE, int OC);
void SiLU_array_bias_full(float *inp, float *bias, int SIZE, int OC);


void here() {
    return;
}

void gemm_ic3s2(float *inp, float *weights, float *arr2, int SIZE);

int main() {
    // int width, height, channels;
    // unsigned char *img = stbi_load("test/img.jpg", &width, &height, &channels, 3);
    if (load_image() != 0) {
        printf("Failed to load image!\n");
        return 1;
    }
    if (load_weights() != 0) {
        printf("Failed to load weights!\n");
        return 1;
    }

    float *weights = params;
    
    for (int i = 0; i < SIZE*SIZE*IC; i++) arr1[IC*SIZE+i] = (float)img[i] / 255.0f;
    
    int OUT = (SIZE + 2 - 3)/stride + 1;

    gemm_ic3s2(arr1, weights, arr2, SIZE);
    weights += IC*OC*9;
    SiLU_array_bias(arr2, weights, OUT*OUT*OC, OC);
    weights += OC;

    IC = OC; SIZE = OUT; OC = 32; OUT /= 2;

    conv3x3nr8(arr2, weights, arr1, SIZE, IC, OC, stride);
    weights += IC*OC*9;
    SiLU_array_bias_full(arr1, weights, OUT*OUT*OC, OC);
    weights += OC;
    
    IC = OC; SIZE = OUT;
    pointwise_conv5x16(arr1, weights, arr2, IC, OC, SIZE);
    weights += IC*OC;
    SiLU_array_bias_full(arr2, weights, OUT*OUT*OC, OC);
    weights += OC;

    IC = 16; OC = 8;
    int idx = 0;

    for (int i = 0; i < (SIZE+2)*IC; i++) arr3[idx++] = 0;
    for (int ih = 0; ih < SIZE; ih++) {
        for (int ic = 0; ic < IC; ic++) arr3[idx++] = 0;
        for (int iw = 0; iw < SIZE; iw++) {
            for (int ic = 0; ic < IC; ic++) {
                arr3[idx++] = arr2[(ih*SIZE+iw)*IC*2+ic+IC];
            }
        }
        for (int ic = 0; ic < IC; ic++) arr3[idx++] = 0;
    }
    for (int i = 0; i < (SIZE+2)*IC; i++) arr3[idx++] = 0;

    writeArrayToFile(weights, IC*OC*9, "out/weights.txt", 0);

    winograd_f23(arr3, weights, arr1, SIZE, IC, OC);
    weights += IC*OC;
    SiLU_array_bias_full(arr1, weights, OUT*OUT*OC, OC);
    
    writeArrayToFile(arr1, OUT*OUT*OC, "out/output.txt", 0);
    here();
    

    // float bias[OC];
    // add_padding_backward(arr2, SIZE, IC);
    // winograd_f23(arr2, weights, arr1, SIZE, IC, OC);
    
    
    // I should do the winograd weight transform and packing in the build time
    





    return 0;
}