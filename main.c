#include <stdio.h>
#include <string.h>
#include <time.h>
#include "tools/tools.h"
#include "conv.h"
#include "func.h"
#include "loader.h"
#include <arm_neon.h>

#define STB_IMAGE_IMPLEMENTATION
#include "tools/stb_image.h"


float arr1[MAX_SIZE];
float arr2[MAX_SIZE];
float arr3[MAX_SIZE];
float arr4[MAX_SIZE];
float arr5[MAX_SIZE];

int SIZE = 640, IC = 3, OC = 16;
int stride = 2;

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

    // clock_t start = clock();

    float *weights = params;
    
    for (int i = 0; i < SIZE*SIZE*IC; i++) arr1[IC*SIZE+i] = (float)img[i] / 255.0f;
    
    int OUT = (SIZE + 2 - 3)/stride + 1;

    gemm_ic3s2(arr1, weights, arr2, SIZE);
    SiLU_array_bias_oc16(arr2, weights+IC*OC*9, OUT*OUT*OC);
    weights += IC*OC*9+OC;

    IC = OC; SIZE = OUT; OC = 32; OUT = SIZE/2;

    conv3x3nr8(arr2, weights, arr1, SIZE, IC, OC, stride);
    SiLU_array_bias_full(arr1, weights+IC*OC*9, OUT*OUT*OC, OC, 0);
    weights += IC*OC*9+OC;
    
    /////////////////////////////  C3K2  ////////////////////////////////////////////
    IC = OC; SIZE = OUT; stride = 1;
    pointwise_conv5x16(arr1, weights, arr2, IC, OC, SIZE, 16);
    float *next_arr = arr2 + OUT*OUT*(OC+16);
    bias_act_d_padd_oc32(arr2, weights+IC*OC, next_arr);
    weights += IC*OC+OC;

    IC = 16; OC = 8;
    weights += 48*64+64; // skip the conv1x1 cv2 weights and bias (IC=48 OC=64)

    winograd_f23(next_arr, weights, arr1, SIZE, IC, OC);
    SiLU_array_bias_oc8(arr1, weights+OC*IC*16, OUT*OUT*OC);
    weights += IC*OC*16+OC;

    IC = 8; OC = 16;
    
    add_padding_backward(arr1, SIZE, IC);
    winograd_f23(arr1, weights, arr3, SIZE, IC, OC);
    bias_act_sum_oc16(arr3, weights+OC*IC*16, arr2+OC, arr2+2*OC, OUT, 2*OC*4);

    weights -= (8*16*16+8 + 48*64+64);
    
    IC = 48; OC = 64;
    pointwise_conv5x16(arr2, weights, arr1, IC, OC, SIZE, 0);
    SiLU_array_bias_full(arr1, weights+OC*IC, OUT*OUT*OC, OC, 0);
    //////////////////////////////////////////////////////////////////////////////////////

    
    weights += (8*16*16+8 + 48*64+64 + 8*16*16+16);
    IC = OC; OUT = SIZE/2; stride = 2;
    conv3x3nr8(arr1, weights, arr2, SIZE, IC, OC, stride);
    SiLU_array_bias_full(arr2, weights+IC*OC*9, OUT*OUT*OC, OC, 0);
    weights += IC*OC*9+OC;


    /////////////////////////////  C3K2  ////////////////////////////////////////////
    stride = 1; SIZE = OUT;
    pointwise_conv5x16(arr2, weights, arr1, IC, OC, SIZE, 32); // make it 32 later
    next_arr = arr1 + OUT*OUT*(OC+32);

    bias_act_d_padd(arr1, weights+IC*OC, next_arr, SIZE, IC, OC);
    weights += IC*OC+OC;
    weights += 96*128+128; // skip the conv1x1 cv2 weights and bias (IC=96 OC=128)
    IC = 32; OC = 16;
    winograd_f23(next_arr, weights, arr2, SIZE, IC, OC);
    SiLU_array_bias_oc16(arr2, weights+OC*IC*16, OUT*OUT*OC);
    weights += OC*IC*16+OC;
    
    IC = OC; OC = 32;
    add_padding_backward(arr2, SIZE, IC);
    winograd_f23(arr2, weights, arr3, SIZE, IC, OC);
    bias_act_sum(arr3, weights+OC*IC*16, arr1+OC, arr1+2*OC, OUT, 2*OC*4, OC, 2*OC*4);
    weights -= (32*16*16+16 + 96*128+128);

    IC = 96; OC = 128;
    pointwise_conv5x16(arr1, weights, arr2, IC, OC, SIZE, 0);
    SiLU_array_bias_full(arr2, weights+OC*IC, OUT*OUT*OC, OC, 0);
    //////////////////////////////////////////////////////////////////////////////////////
    
    // copy arr2 for future use ******* 80*80

    weights += (32*16*16+16 + 96*128+128 + 16*32*16+32);
    IC = OC; OUT = SIZE/2; stride = 2;
    conv3x3nr8(arr2, weights, arr1, SIZE, IC, OC, stride);
    SiLU_array_bias_full(arr1, weights+IC*OC*9, OUT*OUT*OC, OC, 0);
    weights += IC*OC*9+OC;
    
    // ////////////////// C3K2 [C3K = True] ///////////////////////////////////
    IC = 128; OC = 128; stride = 1; SIZE = OUT;
    C3K2_C3K_True(arr1, weights, SIZE, IC, OC);                         // 6) C3K2 
    weights += 115200;

    // copy arr1 for future use ******* 40*40

    IC = 128; OC = 256; OUT = SIZE/2; stride = 2;
    conv3x3nr8(arr1, weights, arr2, SIZE, IC, OC, stride);              // 7)
    SiLU_array_bias_full(arr2, weights+IC*OC*9, OUT*OUT*OC, OC, 0);
    weights += IC*OC*9+OC;
    
    // ////////////////// C3K2 [C3K = True] ///////////////////////////////////

    IC = 256; OC = 256; SIZE = OUT; stride = 1;
    C3K2_C3K_True(arr2, weights, SIZE, IC, OC);                         // 8) C3K2 
    weights += 459776;

    IC = 256; OC = 128;
    memset(arr1, 0, SIZE*SIZE*512*4);
    pointwise_conv_bias_5x16(arr2, weights, arr1, IC, OC, SIZE, 3*OC);

    here();
    maxpool_3_5x5(arr1, 3*OC*4, 4*OC*4, 4*OC*4*SIZE);
    maxpool_3_5x5(arr1+128, 3*OC*4, 4*OC*4, 4*OC*4*SIZE);
    maxpool_3_5x5(arr1+256, 3*OC*4, 4*OC*4, 4*OC*4*SIZE);
    
    writeArrayToFile(arr1, OUT*OUT*OC*4, "out/out.txt", 0);
    
    
    // printf("W : %f\n", weights[0]);
    
    // clock_t end = clock();
    // double time_spent = (double)(end - start) / CLOCKS_PER_SEC;
    // printf("%.6f #\n", time_spent);

    return 0;
}