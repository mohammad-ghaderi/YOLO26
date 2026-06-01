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
float arr4[MAX_SIZE];
float arr5[MAX_SIZE];

int SIZE = 640, IC = 3, OC = 16;
int stride = 2;

void SiLU(float *inp);
void SiLU_array(float *inp, int SIZE);
void SiLU_array_bias_oc16(float *inp, float *bias, int SIZE);
void SiLU_array_bias_oc8(float *inp, float *bias, int SIZE);
void SiLU_array_bias_full(float *inp, float *bias, int SIZE, int OC, int gap);
void bias_act_d_padd_oc32(float *inp, float *bias, float *out);
void bias_act_d_padd(float *inp, float *bias, float *out, int SIZE, int IC, int OC);
void bias_act_d(float *inp, float *bias, float *out, int SIZE, int IC, int OC);
void bias_act_sum_oc16(float *inp, float *bias, float *X, float *out, int SIZE, int output_stride);
void bias_act_sum(float *inp, float *bias, float *X, float *out, int SIZE, int output_stride, int OC, int x_stride);

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
    memset(arr2, 0, sizeof(float)*SIZE*SIZE*OC*3);
    pointwise_conv5x16(arr1, weights, arr2, IC, OC, SIZE, 64);          // 6.cv1
    next_arr = arr2 + OUT*OUT*(OC+64);
    bias_act_d(arr2, weights+IC*OC, next_arr, SIZE, IC, OC);
    weights += IC*OC+OC;
    weights += 192*128+128;
    
    IC = 64; OC = 32;
    pointwise_conv5x16(next_arr, weights, arr1, IC, OC, SIZE, 0);       // 6.m0.cv1
    SiLU_array_bias_full(arr1, weights+OC*IC, OUT*OUT*OC, OC, 0);
    weights += OC*IC+OC;
    
    memset(arr3, 0, sizeof(float)*OUT*OUT*OC*2);
    pointwise_conv5x16(next_arr, weights, arr3+OC, IC, OC, SIZE, OC);   // 6.m0.cv2
    SiLU_array_bias_full(arr3+OC, weights+IC*OC, OUT*OUT*OC, OC, OC*4);
    // bias_act_sum(arr3+OC, weights+IC*OC, arr1+OC, arr3+OC, SIZE, OC*4, OC);
    // writeArrayToFile(arr3, OUT*OUT*(OC), "out/out.txt", 0);

    weights += OC*IC+OC;
    weights += 64*64+64;    // skip cv3
    IC = 32; OC = 32;
    float *padded = arr1 + IC*OUT*OUT;
    add_padding(arr1, padded, SIZE, IC);
    winograd_f23(padded, weights, arr4, SIZE, IC, OC);                  // 6.m0.m0.cv1
    SiLU_array_bias_full(arr4, weights+OC*IC*16, OUT*OUT*OC, OC, 0);
    weights += OC*IC*16+OC;
    
    add_padding_backward(arr4, SIZE, IC);
    winograd_f23(arr4, weights, arr5, SIZE, IC, OC);                    // 6.m0.m0.cv2
    bias_act_sum(arr5, weights+OC*IC*16, arr1, arr4, OUT, 0, OC, 0);
    weights += OC*IC*16+OC;

    padded = arr4 + IC*OUT*OUT;
    add_padding(arr4, padded, SIZE, IC);
    winograd_f23(padded, weights, arr1, SIZE, IC, OC);                  // 6.m0.m1.cv1
    SiLU_array_bias_full(arr1, weights+OC*IC*16, OUT*OUT*OC, OC, 0);
    weights += OC*IC*16+OC;
    
    add_padding_backward(arr1, SIZE, IC);
    winograd_f23(arr1, weights, arr5, SIZE, IC, OC);                    // 6.m0.m1.cv2
    bias_act_sum(arr5, weights+OC*IC*16, arr4, arr3, OUT, OC*4, OC, 0);
    // weights += OC*IC*16+OC;
    
    weights -= (3*(OC*IC*16+OC) +  64*64+64);
    IC = 64;OC = 64;
    pointwise_conv5x16(arr3, weights, arr2+2*OC, IC, OC, SIZE, 2*OC);            // 6.m0.cv3
    SiLU_array_bias_full(arr2+2*OC, weights+IC*OC, OUT*OUT*OC, OC, 2*OC*4);
    
    weights -= (2*(64*32+32) + 192*128+128);
    IC = 192; OC = 128;
    pointwise_conv5x16(arr2, weights, arr1, IC, OC, SIZE, 0);
    SiLU_array_bias_full(arr1, weights+IC*OC, OUT*OUT*OC, OC, 0);
    // printf("weights[0] %f\n", weights[0]);


    writeArrayToFile(arr1, OUT*OUT*OC, "out/out.txt", 0);


    return 0;
}