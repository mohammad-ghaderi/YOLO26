#include <stdio.h>
#include <string.h>
#include "../conv.h"
#include "../func.h"
#include "../tools/tools.h"

float arrt2[MAX_SIZE];
float arrt3[MAX_SIZE];
float arrt4[MAX_SIZE];
float arrt5[MAX_SIZE];

void C3K2_C3K_True(float *arr, float *weights, int SIZE, int IC, int OC) {
    int stride = 1, OUT = SIZE;
    pointwise_conv5x16(arr, weights, arrt2, IC, OC, SIZE, OC/2);          // cv1
    float *next_arr = arrt2 + OUT*OUT*(OC+OC/2);
    bias_act_d(arrt2, weights+IC*OC, next_arr, SIZE, IC, OC);
    weights += IC*OC+OC;
    
    float *wcv2 = weights;                      // store cv2 weights address
    weights += (OC+OC/2)*OC+OC;
    
    IC = OC/2; OC = OC/4;
    pointwise_conv5x16(next_arr, weights, arr, IC, OC, SIZE, 0);       // m0.cv1
    SiLU_array_bias_full(arr, weights+OC*IC, OUT*OUT*OC, OC, 0);
    weights += OC*IC+OC;
    
    pointwise_conv5x16(next_arr, weights, arrt3+OC, IC, OC, SIZE, OC);   // m0.cv2
    SiLU_array_bias_full(arrt3+OC, weights+IC*OC, OUT*OUT*OC, OC, OC*4);
    weights += OC*IC+OC;
    
    float *wm0cv3 = weights;                    // store m0.cv3 weights address
    weights += IC*IC+IC;                        // skip cv3
    
    IC = OC;
    float *padded = arr + IC*OUT*OUT;
    add_padding(arr, padded, SIZE, IC);
    winograd_f23(padded, weights, arrt4, SIZE, IC, OC);                  // m0.m0.cv1
    SiLU_array_bias_full(arrt4, weights+OC*IC*16, OUT*OUT*OC, OC, 0);
    weights += OC*IC*16+OC;
    
    add_padding_backward(arrt4, SIZE, IC);
    winograd_f23(arrt4, weights, arrt5, SIZE, IC, OC);                    // m0.m0.cv2
    bias_act_sum(arrt5, weights+OC*IC*16, arr, arrt4, OUT, 0, OC, 0);
    weights += OC*IC*16+OC;
    
    padded = arrt4 + IC*OUT*OUT;
    add_padding(arrt4, padded, SIZE, IC);
    winograd_f23(padded, weights, arr, SIZE, IC, OC);                  // m0.m1.cv1
    SiLU_array_bias_full(arr, weights+OC*IC*16, OUT*OUT*OC, OC, 0);
    weights += OC*IC*16+OC;
    
    add_padding_backward(arr, SIZE, IC);
    winograd_f23(arr, weights, arrt5, SIZE, IC, OC);                    // m0.m1.cv2
    bias_act_sum(arrt5, weights+OC*IC*16, arrt4, arrt3, OUT, OC*4, OC, 0);
    
    weights = wm0cv3;
    OC = 2*IC; IC = OC;
    pointwise_conv5x16(arrt3, weights, arrt2+2*OC, IC, OC, SIZE, 2*OC);            // m0.cv3
    SiLU_array_bias_full(arrt2+2*OC, weights+IC*OC, OUT*OUT*OC, OC, 2*OC*4);
    
    weights = wcv2;
    IC = OC+2*OC; OC = 2*OC;
    pointwise_conv5x16(arrt2, weights, arr, IC, OC, SIZE, 0);                   // cv2
    SiLU_array_bias_full(arr, weights+IC*OC, OUT*OUT*OC, OC, 0);
}