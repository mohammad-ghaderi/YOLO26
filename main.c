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

float val[MAX_SIZE];
float val2[MAX_SIZE];
float val3[MAX_SIZE];
float val4[MAX_SIZE];

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
    memset(val2, 0, 256*80*80*4);
    concat_layout(arr2, val2+OC, SIZE, OC, OC*4);
    // copy arr2 for future use ******* 80*80

    weights += (32*16*16+16 + 96*128+128 + 16*32*16+32);
    IC = OC; OUT = SIZE/2; stride = 2;
    conv3x3nr8(arr2, weights, arr1, SIZE, IC, OC, stride);
    SiLU_array_bias_full(arr1, weights+IC*OC*9, OUT*OUT*OC, OC, 0);
    weights += IC*OC*9+OC;
    
    // ////////////////// C3K2 [C3K = True] ///////////////////////////////////
    IC = 128; OC = 128; stride = 1; SIZE = OUT;
    C3K2_C3K_True(arr1, weights, SIZE, IC, OC);                         // 6) C3K2 
    concat_layout(arr1, val+2*OC, SIZE, OC, 2*OC*4);
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
    
    //////////////////////////// SPPF ////////////////////////////////////  9)
    IC = 256; OC = 128;
    pointwise_conv_bias_5x16(arr2, weights, arr1, IC, OC, SIZE, 3*OC);
    weights += IC*OC+OC;
    
    maxpool_3_5x5(arr1, 3*OC*4, 4*OC*4, 4*OC*4*SIZE);
    maxpool_3_5x5(arr1+128, 3*OC*4, 4*OC*4, 4*OC*4*SIZE);
    maxpool_3_5x5(arr1+256, 3*OC*4, 4*OC*4, 4*OC*4*SIZE);
    
    IC = 512; OC = 256;
    pointwise_conv5x16(arr1, weights, arr3, IC, OC, SIZE, 0);
    bias_act_sum(arr3, weights+OC*IC, arr2, arr1, OUT, 0, OC, 0);
    weights += IC*OC+OC;
    ////////////////////////////////////////////////////////////////////


   ///////////////////////    C2PSA    //////////////////////////////////   10)
    IC = 256; OC = 256;
    pointwise_conv5x16(arr1, weights, arr2, IC, OC, SIZE, 0);           // 10.cv1
    bias_act_d(arr2, weights+IC*OC, arr3, SIZE, IC, OC, 0);                // arr2 and arr3 are needed later

    weights += IC*OC+OC;
    float *wcv2 = weights;
    weights += IC*OC+OC;
    
    IC = 128; OC = 256;
    pointwise_conv5x16(arr3, weights, arr1, IC, OC, SIZE, 0);           // 10.m0.qvk
    bias_split_attn(arr1, weights+IC*OC, arr5, 400);
    weights += IC*OC+OC;
    
    float *q1 = arr5;
    float *k1 = q1 + OUT*OUT*32;
    float *q2 = k1 + OUT*OUT*32;
    float *k2 = q2 + OUT*OUT*32;
    float *v = k2 + OUT*OUT*32;
    
    matrix_dot_scale_softmax(q1, k1, arr1);
    matrix_dot_scale_softmax(q2, k2, arr1+400*400);
    
    v_dot_attn(v, arr1, arr4);
    v_dot_attn(v+64*400, arr1+400*400, arr4+64);
    
    float *wproj = weights;
    weights += 128*128+128;
    IC = 128; OC = 128;
    depthwise_conv_c4r2(v, weights, arr1, OC, SIZE);
    tensor_sum(arr1, arr4, arr1, OUT*OUT*OC, 0);
    pointwise_conv5x16(arr1, wproj, arr4, IC, OC, SIZE, 0);
    bias_sum(arr4, wproj+IC*OC, arr3, arr1, SIZE*SIZE*IC);      // arr1 is needed later
    
    weights += IC*9+OC;
    IC = 128; OC = 256;
    pointwise_conv5x16(arr1, weights, arr4, IC, OC, SIZE, 0);
    SiLU_array_bias_full(arr4, weights+IC*OC, OUT*OUT*OC, OC, 0);
    
    weights += IC*OC+OC;
    IC = 256; OC = 128;
    pointwise_conv_bias_5x16(arr4, weights, arr3, IC, OC, SIZE, 0);
    tensor_sum(arr3, arr1, arr2+OC, OUT*OUT*OC, OC*4);
    weights += IC*OC+OC;

    IC = 256; OC = 256;
    pointwise_conv5x16(arr2, wcv2, arr3, IC, OC, SIZE, 0);
    SiLU_array_bias_full(arr3, wcv2+OC*IC, OUT*OUT*OC, OC, 0);      
    ///////////////////////////////////////////////////////////////////         // i should save arr3 for later

    OC = 384; OUT = 2*SIZE;
    upsample_concat(arr3, val, SIZE, IC, OC);

    SIZE = OUT; IC = OC; OC = 128;
    C3K2_C3K_True(val, weights, SIZE, IC, OC);      // val is needed later
    weights += 147968;
    
    IC = 128; OC = 256; OUT = 2*SIZE;
    upsample_concat(val, val2, SIZE, IC, OC);
    
    SIZE = OUT; IC = OC; OC = 64;
    C3K2_C3K_True(val2, weights, SIZE, IC, OC);     // val2 is needed later
    weights += 41216;

    IC = OC; OUT = SIZE/2; stride = 2;
    conv3x3nr8(val2, weights, arr1, SIZE, IC, OC, stride);
    SiLU_array_bias_full(arr1, weights+IC*OC*9, OUT*OUT*OC, OC, 0);
    weights += IC*OC*9+OC;

    SIZE = OUT;
    // could be optimize later
    concat_layout(arr1, val3, SIZE, 64, 128*4);
    concat_layout(val, val3+64, SIZE, 128, 64*4);

    IC = 192; OC = 128; stride = 1;
    C3K2_C3K_True(val3, weights, SIZE, IC, OC);     // val3 is needed later
    weights += 123392;
    
    IC = OC; OUT = SIZE/2; stride = 2;
    conv3x3nr8(val3, weights, arr1, SIZE, IC, OC, stride);
    SiLU_array_bias_full(arr1, weights+IC*OC*9, OUT*OUT*OC, OC, 0);
    weights += IC*OC*9+OC;

    SIZE = OUT;
    // could be optimize later
    concat_layout(arr1, val4, SIZE, 128, 256*4);
    concat_layout(arr3, val4+128, SIZE, 256, 128*4);

    ////////////// C3K2 C3K=True attn=True //////////////////////////////
    IC = 384; OC = 256;
    pointwise_conv5x16(val4, weights, arr1, IC, OC, SIZE, 0);           // 22.cv1
    bias_act_d(arr1, weights+IC*OC, arr2, SIZE, IC, OC, 0);             // arr1 is needed later
    
    weights += IC*OC+OC;
    wcv2 = weights;
    weights += IC*OC+OC;

    // bottle neck
    IC = 128; OC = 64;
    float *padded = arr2 + IC*OUT*OUT;
    add_padding(arr2, padded, SIZE, IC);
    winograd_f23(padded, weights, arr3, SIZE, IC, OC);                  // m0.m0.cv1
    SiLU_array_bias_full(arr3, weights+OC*IC*16, OUT*OUT*OC, OC, 0);
    weights += OC*IC*16+OC;
    
    IC = OC; OC = 128;
    add_padding_backward(arr3, SIZE, IC);
    winograd_f23(arr3, weights, arr4, SIZE, IC, OC);                    // m0.m0.cv2
    bias_act_sum(arr4, weights+OC*IC*16, arr2, arr5, OUT, 0, OC, 0);
    weights += OC*IC*16+OC;
    writeArrayToFile(arr5, OUT*OUT*OC, "out/out.txt", 0);
    


    
    printf("OUT : %d\n", OUT);
    printf("W : %f\n", weights[0]);
    printf("B : %f\n", weights[128*256]);

    // clock_t end = clock();
    // double time_spent = (double)(end - start) / CLOCKS_PER_SEC;
    // printf("%.6f #\n", time_spent);

    return 0;
}