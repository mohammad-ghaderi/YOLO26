#include <stdio.h>
#include "conv.h"
#include "tools/tools.h"
#include <time.h>



void transform_weight_f23(float* weight, int IC, int OC) {
    // const float ktm[4][3] = {
    //     {1.0f,  0.0f, 0.0f},
    //     {0.5f,  0.5f, 0.5f},
    //     {0.5f, -0.5f, 0.5f},
    //     {0.0f,  0.0f, 1.0f}
    // };
    float U[IC*OC*16];
    float tmp[3*4];
    float *w = weight;

    for (int oc = 0; oc < OC; oc++) {
        for (int ic = 0; ic < IC; ic++) {
            float *k0 = weight + ic;
            float *k1 = k0 + IC;
            float *k2 = k1 + IC;
            
            for (int i = 0; i < 3; i++) {
                tmp[i*4+0] = *k0;
                tmp[i*4+1] = *k0*0.5f + *k1*0.5f + *k2*0.5f;
                tmp[i*4+2] = *k0*0.5f - *k1*0.5f + *k2*0.5f;
                tmp[i*4+3] = *k2;
                
                k0 += 3*IC;
                k1 += 3*IC;
                k2 += 3*IC;
            }
            
            for (int i = 0; i < 4; i++) {
                U[(oc*16+i)*IC + ic] = tmp[i];
                U[(oc*16+i+4)*IC + ic] = tmp[i]*0.5f + tmp[i+4]*0.5f + tmp[i+8]*0.5f;
                U[(oc*16+i+8)*IC + ic] = tmp[i]*0.5f - tmp[i+4]*0.5f + tmp[i+8]*0.5f;
                U[(oc*16+i+12)*IC + ic] = tmp[i+8];
            }
        }
        weight += IC*9;
    }

    int idx = 0;
    for (int oc = 0; oc < OC; oc+=4) {
        for (int ic = 0; ic < IC; ic+=4) {
            for (int ky = 0; ky < 4; ky++) {
                for (int icc = 0; icc < 4; icc++) {
                    for (int kx = 0; kx < 4; kx++) {
                        int k = ky*4+kx;
                        for (int ioc = 0; ioc < 4; ioc++) {
                            int base_i = (oc+ioc)*IC*16;
                            int second_i = ic+icc;
                            int final_i = base_i + k*IC + second_i;
                            w[idx++] = U[final_i];
                        }
                    }
                }
            }
        }
    }
}


void winograd_f23(float *input, float *weights, float *output, int SIZE, int IC, int OC) {

    transform_weight_f23(weights, IC, OC);
    
    for (int ih = 0; ih < SIZE; ih+=2) {
        for (int iw = 0; iw < SIZE; iw+=2) {
            float *inp_tile = input + (ih*(SIZE+2)+iw)*IC;

            winograd_f23_v1(inp_tile, weights, output+(ih*SIZE+iw)*OC, output+((ih+1)*SIZE+iw)*OC, IC, OC, IC*(SIZE+2)*4);

        }
    }
}