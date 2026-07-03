#include <stdio.h>
#include <string.h>
#include <time.h>
#include "tools/tools.h"
#include "conv.h"
#include "func.h"
#include "loader.h"

#define STB_IMAGE_IMPLEMENTATION
#include "tools/stb_image.h"

typedef struct {
    float x1, y1, x2, y2;
    float prob;
    int class_idx;
} Detect;

float arr1[MAX_SIZE];
float arr2[MAX_SIZE];
float arr3[MAX_SIZE];
float arr4[MAX_SIZE];
float arr5[MAX_SIZE];

float val[MAX_SIZE];
float val2[MAX_SIZE];
float val3[MAX_SIZE];
float val4[MAX_SIZE];

float out80[82*82*64];
float out40[42*42*128];
// float out20[20*20*256]; 
const float THRESHOLD = 0.25f;

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
    C3K2_C3K_True(val2, weights, SIZE, IC, OC);
    for (int i = 0; i < 80*80*64; i++) out80[i] = val2[i];          // out 80*80
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
    C3K2_C3K_True(val3, weights, SIZE, IC, OC);
    for (int i = 0; i < 40*40*128; i++) out40[i] = val3[i];         // out 40*40
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
    pointwise_conv5x16(val4, weights, arr1, IC, OC, SIZE, 128);           // 22.cv1
    bias_act_d(arr1, weights+IC*OC, arr2, SIZE, IC, OC, 128*4);             // arr1 is needed later
    
    weights += IC*OC+OC;
    wcv2 = weights;
    weights += IC*OC+OC;

    // bottle neck
    IC = 128; OC = 64;
    float *padded = arr2 + IC*OUT*OUT;
    add_padding(arr2, padded, SIZE, IC);
    winograd_f23(padded, weights, arr4, SIZE, IC, OC);                  // m0.m0.cv1
    SiLU_array_bias_full(arr4, weights+OC*IC*16, OUT*OUT*OC, OC, 0);
    weights += OC*IC*16+OC;
    
    IC = OC; OC = 128;
    add_padding_backward(arr4, SIZE, IC);
    winograd_f23(arr4, weights, arr5, SIZE, IC, OC);                    // m0.m0.cv2
    bias_act_sum(arr5, weights+OC*IC*16, arr2, arr3, OUT, 0, OC, 0);
    weights += OC*IC*16+OC;
    
    // PSABlock
    IC = 128; OC = 256;
    pointwise_conv5x16(arr3, weights, arr2, IC, OC, SIZE, 0);           // 22.m0.qvk
    bias_split_attn(arr2, weights+IC*OC, arr5, 400);
    weights += IC*OC+OC;
    
    q1 = arr5;
    k1 = q1 + OUT*OUT*32;
    q2 = k1 + OUT*OUT*32;
    k2 = q2 + OUT*OUT*32;
    v = k2 + OUT*OUT*32;
    
    matrix_dot_scale_softmax(q1, k1, arr2);
    matrix_dot_scale_softmax(q2, k2, arr2+400*400);
    
    v_dot_attn(v, arr2, arr4);
    v_dot_attn(v+64*400, arr2+400*400, arr4+64);
    
    wproj = weights;
    weights += 128*128+128;
    IC = 128; OC = 128;
    depthwise_conv_c4r2(v, weights, arr2, OC, SIZE);
    tensor_sum(arr2, arr4, arr2, OUT*OUT*OC, 0);
    pointwise_conv5x16(arr2, wproj, arr4, IC, OC, SIZE, 0);
    bias_sum(arr4, wproj+IC*OC, arr3, arr2, SIZE*SIZE*IC);      // arr2 is needed later
    
    weights += IC*9+OC;
    IC = 128; OC = 256;
    pointwise_conv5x16(arr2, weights, arr4, IC, OC, SIZE, 0);
    SiLU_array_bias_full(arr4, weights+IC*OC, OUT*OUT*OC, OC, 0);
    
    weights += IC*OC+OC;
    IC = 256; OC = 128;
    pointwise_conv_bias_5x16(arr4, weights, arr3, IC, OC, SIZE, 0);
    tensor_sum(arr3, arr2, arr1+OC*2, OUT*OUT*OC, 2*OC*4);
    weights += IC*OC+OC;
    
    IC = 384; OC = 256;
    pointwise_conv5x16(arr1, wcv2, arr2, IC, OC, SIZE, 0);
    SiLU_array_bias_full(arr2, wcv2+OC*IC, OUT*OUT*OC, OC, 0);          // 22.cv2
    /////////////////////////////////////////////////////////////////////////////// arr2 20*20

    /////////////////// Detect //////////////////////////

    ////// one2one.cv3   [scores] ///////

    float scores[80*80+40*40+20*20];
    int idx[80*80+40*40+20*20];

    float *w_cv2 = weights;
    weights += 127276;
    
    // seq0
    OUT = 80; SIZE = 80; IC = 64; OC = 64;
    depthwise_conv_c4r2_normal(out80, weights, arr1, OC, SIZE);     // 0.0.0 g=64
    SiLU_array(arr1, OUT*OUT*OC);
    weights += OC*9+OC;
    OC = 80;
    pointwise_conv5x16(arr1, weights, arr3, IC, OC, SIZE, 0);       // 0.0.1
    SiLU_array_bias_full(arr3, weights+OC*IC, OUT*OUT*OC, OC, 0);
    weights += OC*IC+OC;
    IC = OC;
    depthwise_conv_c4r2_normal(arr3, weights, arr1, OC, SIZE);      // 0.1.0 g=80
    SiLU_array(arr1, OUT*OUT*OC);
    weights += OC*9+OC;
    pointwise_conv5x16(arr1, weights, arr3, IC, OC, SIZE, 0);       // 0.1.1
    SiLU_array_bias_full(arr3, weights+OC*IC, OUT*OUT*OC, OC, 0);
    weights += OC*IC+OC;
    pointwise_conv_bias_5x16(arr3, weights, arr1, IC, OC, SIZE, 0); // 0.2      // score for 80*80
    weights += OC*IC+OC;
    sigmoid_array(arr1, OUT*OUT*OC);

    for (int i = 0; i < OUT*OUT; i++) {
        float mx = 0;
        int index = 0;
        for (int j = 0; j < OC; j++) {
            if (arr1[i*OC+j] > mx) {
                mx = arr1[i*OC+j]; index = j;
            }
        }
        scores[i] = mx;
        idx[i] = index;
    }

    // seq1
    OUT = 40; SIZE = 40; IC = 128; OC = 128;
    depthwise_conv_c4r2_normal(out40, weights, arr1, OC, SIZE);     // 1.0.0 g=128
    SiLU_array(arr1, OUT*OUT*OC);
    weights += OC*9+OC;
    OC = 80;
    pointwise_conv5x16(arr1, weights, arr3, IC, OC, SIZE, 0);       // 1.0.1
    SiLU_array_bias_full(arr3, weights+OC*IC, OUT*OUT*OC, OC, 0);
    weights += OC*IC+OC;
    IC = OC;
    depthwise_conv_c4r2_normal(arr3, weights, arr1, OC, SIZE);      // 1.1.0 g=80
    SiLU_array(arr1, OUT*OUT*OC);
    weights += OC*9+OC;
    pointwise_conv5x16(arr1, weights, arr3, IC, OC, SIZE, 0);       // 1.1.1
    SiLU_array_bias_full(arr3, weights+OC*IC, OUT*OUT*OC, OC, 0);
    weights += OC*IC+OC;
    pointwise_conv_bias_5x16(arr3, weights, arr1, IC, OC, SIZE, 0); // 1.2      // score for 40*40
    weights += OC*IC+OC;    
    sigmoid_array(arr1, OUT*OUT*OC);

    for (int i = 0; i < OUT*OUT; i++) {
        float mx = 0;
        int index = 0;
        for (int j = 0; j < OC; j++) {
            if (arr1[i*OC+j] > mx) {
                mx = arr1[i*OC+j]; index = j;
            }
        }
        scores[80*80+i] = mx;
        idx[80*80+i] = index;
    }

    // seq2
    OUT = 20; SIZE = 20; IC = 256; OC = 256;
    depthwise_conv_c4r2_normal(arr2, weights, arr1, OC, SIZE);      // 2.0.0 g=256
    SiLU_array(arr1, OUT*OUT*OC);
    weights += OC*9+OC;
    OC = 80;
    pointwise_conv5x16(arr1, weights, arr3, IC, OC, SIZE, 0);       // 2.0.1
    SiLU_array_bias_full(arr3, weights+OC*IC, OUT*OUT*OC, OC, 0);
    weights += OC*IC+OC;
    IC = OC;
    depthwise_conv_c4r2_normal(arr3, weights, arr1, OC, SIZE);      // 2.1.0 g=80
    SiLU_array(arr1, OUT*OUT*OC);
    weights += OC*9+OC;
    pointwise_conv5x16(arr1, weights, arr3, IC, OC, SIZE, 0);       // 2.1.1
    SiLU_array_bias_full(arr3, weights+OC*IC, OUT*OUT*OC, OC, 0);
    weights += OC*IC+OC;
    pointwise_conv_bias_5x16(arr3, weights, arr1, IC, OC, SIZE, 0); // 2.2      // score for 40*40
    weights += OC*IC+OC;
    sigmoid_array(arr1, OUT*OUT*OC);

    for (int i = 0; i < OUT*OUT; i++) {
        float mx = 0;
        int index = 0;
        for (int j = 0; j < OC; j++) {
            if (arr1[i*OC+j] > mx) {
                mx = arr1[i*OC+j]; index = j;
            }
        }
        scores[80*80+40*40+i] = mx;
        idx[80*80+40*40+i] = index;
    }

    float top_val[300];
    int top_idx[300];
    int count = 0;
    for (int i = 0; i < 8400; i++) {
        float v = scores[i];

        if (v < THRESHOLD)
            continue;

        if (count < 300) {
            top_idx[count] = i;
            top_val[count] = v;
            count++;
            continue;
        }

        /* find current smallest among top 300 */
        int min_pos = 0;
        for (int j = 1; j < 300; j++) {
            if (top_val[j] < top_val[min_pos])
                min_pos = j;
        }

        if (v > top_val[min_pos]) {
            top_val[min_pos] = v;
            top_idx[min_pos] = i;
        }
    }

    ////// one2one.cv2   [boxes] ////////
    weights = w_cv2;

    // seq0
    OUT = 80; SIZE = 80; IC = 64; OC = 16;
    add_padding_backward(out80, SIZE, IC);
    winograd_f23(out80, weights, arr1, SIZE, IC, OC);
    SiLU_array_bias_oc16(arr1, weights+OC*IC*16, OUT*OUT*OC); // later optmization (fuse bias act padd for oc16) *****
    weights += IC*OC*16+OC;
    IC = OC;
    add_padding_backward(arr1, SIZE, IC);
    winograd_f23(arr1, weights, arr3, SIZE, IC, OC);
    SiLU_array_bias_oc16(arr3, weights+OC*IC*16, OUT*OUT*OC);
    weights += IC*OC*16+OC;
    OC = 4;
    point_wise_bias_ic16oc4(arr3, weights, weights+OC*IC, arr4, SIZE, 4*4);
    weights += OC*IC+OC;

    // seq1
    OUT = 40; SIZE = 40; IC = 128; OC = 16;
    add_padding_backward(out40, SIZE, IC);
    winograd_f23(out40, weights, arr1, SIZE, IC, OC);
    SiLU_array_bias_oc16(arr1, weights+OC*IC*16, OUT*OUT*OC); // later optmization (fuse bias act padd for oc16) *****
    weights += IC*OC*16+OC;
    IC = OC;
    add_padding_backward(arr1, SIZE, IC);
    winograd_f23(arr1, weights, arr3, SIZE, IC, OC);
    SiLU_array_bias_oc16(arr3, weights+OC*IC*16, OUT*OUT*OC);
    weights += IC*OC*16+OC;
    OC = 4;
    point_wise_bias_ic16oc4(arr3, weights, weights+OC*IC, arr4+80*80*4, SIZE, 4*4);
    weights += OC*IC+OC;

    // seq2
    OUT = 20; SIZE = 20; IC = 256; OC = 16;
    add_padding_backward(arr2, SIZE, IC);
    winograd_f23(arr2, weights, arr1, SIZE, IC, OC);
    SiLU_array_bias_oc16(arr1, weights+OC*IC*16, OUT*OUT*OC); // later optmization (fuse bias act padd for oc16) *****
    weights += IC*OC*16+OC;
    IC = OC;
    add_padding_backward(arr1, SIZE, IC);
    winograd_f23(arr1, weights, arr3, SIZE, IC, OC);
    SiLU_array_bias_oc16(arr3, weights+OC*IC*16, OUT*OUT*OC);
    weights += IC*OC*16+OC;
    OC = 4;
    point_wise_bias_ic16oc4(arr3, weights, weights+OC*IC, arr4+(80*80+40*40)*4, SIZE, 4*4);
    weights += OC*IC+OC;

    Detect result[300];

    int rel_i, base, mult;
    for (int i = 0; i < count; i++) {
        int index = top_idx[i];
        if (index < 80*80) {
            base = 80;
            mult = 8;
        } else if (index < 80*80+40*40) {
            rel_i = index - 80*80;
            base = 40;
            mult = 16;
        } else {
            rel_i = index - (80*80+40*40);
            base = 20;
            mult = 32;
        }
        result[i].prob = top_val[i];
        result[i].class_idx = idx[index];
        result[i].x1 = (((rel_i%base)+0.5) - arr4[index*4+0])*mult;
        result[i].y1 = (((rel_i/base)+0.5) - arr4[index*4+1])*mult;
        result[i].x2 = (((rel_i%base)+0.5) + arr4[index*4+2])*mult;
        result[i].y2 = (((rel_i/base)+0.5) + arr4[index*4+3])*mult;

        printf("(%f %f %f %f) prob:%f class: %d\n", result[i].x1, result[i].y1, result[i].x2, result[i].y2, result[i].prob, result[i].class_idx);
    }
    

    // writeArrayToFile(arr1, OUT*OUT*OC, "out/out.txt", 0);

    // clock_t end = clock();
    // double time_spent = (double)(end - start) / CLOCKS_PER_SEC;
    // printf("%.6f #\n", time_spent);

    return 0;
}