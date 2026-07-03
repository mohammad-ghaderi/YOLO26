#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include "conv.h"
#include "func.h"
#include "tools/tools.h"
#include <time.h>

// extern float *indirection_buffer[320*320*9];
float *indirection_buffer[MAX_SIZE];

float pack_w[MAX_SIZE];

void conv3x3nr8(float *input, float *weights, float *output, int size, int IC, int OC, int stride) {
    int OUT = (size + 2*1 - 3)/stride + 1;
    int kc=IC*9;
    int nr = 8;
    int mr = 4;
    int block_y = 8, block_x = 8;
    if (OUT == 20) {
        block_y = 4;
        block_x = 4;
    }
    
    add_padding_backward(input, size, IC);      // later i join this with last layer activation function section, to save some time

    int oc_blocks=(OC+nr-1)/nr;
    
    for (int by = 0; by < OUT/block_y; by++) {
        for (int bx = 0; bx < OUT/block_x; bx++) {
            for(int ob=0;ob<oc_blocks;ob++) {
                float *w=weights+ob*kc*nr;
                for (int ipy = 0; ipy < block_y; ipy++) {
                    for (int ipx = 0; ipx < block_x; ipx+=mr) {
                        int px = bx*block_x + ipx, py = by*block_y +ipy;
                        int p = py*OUT + px;
                        gemm4x8_v3(input + (py*stride*(size+2)+px*stride)*IC, w, output+p*OC+ob*nr, (OC - nr)*4, IC, (size-1)*IC*4, stride*IC*4);
                    }
                }
            }
        }
    }
}

void conv3x3(float *input, float *weights, float *output, int size, int IC, int OC, int version, int thread_cnt, int block_y, int block_x, int stride){
    int OUT = (size + 2*1 - 3)/stride + 1;
    int kc=IC*9;
    int nr = 16;
    int mr = 4;

    if (version == 3 || version == 4 || version == 7 || version == 8 || version == 9 || version == 10) {
        nr = 8;
    }
    if (version == 4 || version == 8 || version == 9 || version == 10) {
        mr = 8;
    }
    
    pack_weights(weights, pack_w, OC, IC, nr);
    
    weights = pack_w;
 
    int oc_blocks=(OC+nr-1)/nr;
    clock_t start = clock();
    
    if (version <= 4) build_indirection(input, indirection_buffer, size, IC);
    else add_padding_backward(input, size, IC);
    
    // omp_set_num_threads(thread_cnt);

// #pragma omp parallel for
// for(int ob=0;ob<oc_blocks;ob++) {
//     float *w=weights+ob*kc*nr;
    for (int by = 0; by < OUT/block_y; by++) {
        // printf("thread %d -> %d\n", omp_get_thread_num(), by);
        for (int bx = 0; bx < OUT/block_x; bx++) {

            for(int ob=0;ob<oc_blocks;ob++) {
                float *w=weights+ob*kc*nr;
                for (int ipy = 0; ipy < block_y; ipy++) {
                    for (int ipx = 0; ipx < block_x; ipx+=mr) {
                        int px = bx*block_x + ipx, py = by*block_y +ipy;
                        int p = py*OUT + px;
                        switch (version) {
                            case 1:
                                igemm4x16_v1(indirection_buffer + p*9, w, output+p*OC+ob*nr, (OC - nr)*4, IC);
                                break;
                            case 2:
                                igemm4x16_v2(indirection_buffer + p*9, w, output+p*OC+ob*nr, (OC - nr)*4, IC);
                                break;
                            case 3:
                                igemm4x8_v3(indirection_buffer + p*9, w, output+p*OC+ob*nr, (OC - nr)*4, IC);
                                break;
                            case 4:
                                igemm8x8_v4(indirection_buffer + p*9, w, output+p*OC+ob*nr, (OC - nr)*4, IC);
                                break;
                            case 5:
                                gemm4x16_v1(input + (py*stride*(size+2)+px*stride)*IC, w, output+p*OC+ob*nr, (OC - nr)*4, IC, (size-1)*IC*4, stride*IC*4);
                                break;
                            case 6:
                                gemm4x16_v2(input + (py*stride*(size+2)+px*stride)*IC, w, output+p*OC+ob*nr, (OC - nr)*4, IC, (size-1)*IC*4, stride*IC*4);
                                break;
                            case 7:
                                gemm4x8_v3(input + (py*stride*(size+2)+px*stride)*IC, w, output+p*OC+ob*nr, (OC - nr)*4, IC, (size-1)*IC*4, stride*IC*4);
                                break;
                            case 8:
                                gemm8x8_v4(input + (py*stride*(size+2)+px*stride)*IC, w, output+p*OC+ob*nr, (OC - nr)*4, IC, (size-1)*IC*4, stride*IC*4);
                                break;
                            case 9:
                                gemm8x8_v5(input + (py*stride*(size+2)+px*stride)*IC, w, output+p*OC+ob*nr, OC*4, IC, (size+1)*IC*4, stride*IC*4);
                                break;
                            case 10:
                                gemm8x8_v10(input + (py*stride*(size+2)+px*stride)*IC, w, output+p*OC+ob*nr, OC*4, IC, (size+1)*IC*4, stride*IC*4);
                                break;
                        }
                    }
                }
            }
        }
    }

    clock_t end = clock();

    double time_spent = (double)(end - start) / CLOCKS_PER_SEC;
    printf("%.6f #\n", time_spent);
}

void pack(float *weights, float *pack_w, int IC, int OC, int nr) {
    int idx = 0;
    for (int ocb = 0; ocb < OC; ocb+=nr) {
        for (int ic = 0; ic < IC; ic++) {
            for (int oci = 0; oci < nr; oci++) {
                int oc = ocb + oci;
                pack_w[idx++] = weights[oc*IC+ic];
            }
        }
    }
}

void pointwise_conv5x16(float *inp, float *weights, float *output, int IC, int OC, int SIZE, int gap) {
    int nr = 16, mr = 5;
    
    for (int ih = 0; ih < SIZE; ih++) {
        for (int iw = 0; iw < SIZE; iw+=mr) {
            for (int oc = 0; oc < OC; oc+=nr) {
                point_wise_5x16(inp+(ih*SIZE+iw)*IC, weights+oc*IC, output+(ih*SIZE+iw)*(OC+gap)+oc, IC, OC, (OC+gap-nr)*4);
            }
        }
    }
}

void pointwise_conv_bias_5x16(float *inp, float *weights, float *output, int IC, int OC, int SIZE, int gap) {
    int nr = 16, mr = 5;
    float *bias = weights + OC*IC;

    for (int ih = 0; ih < SIZE; ih++) {
        for (int iw = 0; iw < SIZE; iw+=mr) {
            for (int oc = 0; oc < OC; oc+=nr) {
                point_wise_bias_5x16(inp+(ih*SIZE+iw)*IC, weights+oc*IC, bias+oc, output+(ih*SIZE+iw)*(OC+gap)+oc, IC, OC, (OC+gap-nr)*4);
            }
        }
    }
}

void pointwise_conv5x20(float *inp, float *weights, float *output, int IC, int OC, int SIZE) {
    int nr = 20, mr = 5;

    for (int ih = 0; ih < SIZE; ih++) {
        for (int iw = 0; iw < SIZE; iw+=mr) {
            for (int oc = 0; oc < OC; oc+=nr) {
                point_wise_5x20(inp+(ih*SIZE+iw)*IC, weights+oc*IC, output+(ih*SIZE+iw)*OC+oc, IC, OC, (OC-nr)*4);
            }
        }
    }
}

void pack_depth(float *weights, float *pack_w, int OC) {
    int idx = 0;
    for (int ocb = 0; ocb < OC; ocb+=4) {
        for (int ky = 0; ky < 3; ky++) {
            for (int kx = 0; kx < 3; kx++) {
                for (int oci = 0; oci < 4; oci++) {
                    int oc = ocb+oci;
                    pack_w[idx++] = weights[oc*9+3*ky+kx];
                }
            }
        }
    }
} 

void depthwise_conv_c4(float *inp, float *weights, float *output, int OC, int SIZE) {
    
    for (int ocb = 0; ocb < OC; ocb+=4) {
        depth_wise_c4(inp+ocb, weights+ocb*9, output+ocb, OC, SIZE);
    }
}

void depthwise_conv_c4r2(float *inp, float *weights, float *output, int OC, int SIZE) {

    for (int ocb = 0; ocb < OC/2; ocb+=4) {
        depth_wise_c4r2(inp+ocb, weights+ocb*9, output+ocb, OC*2, SIZE, OC*4, weights+OC*9+ocb);
    }
    for (int ocb = OC/2; ocb < OC; ocb+=4) {
        depth_wise_c4r2(inp+(OC/2*SIZE*SIZE)+ocb-OC/2, weights+ocb*9, output+ocb, OC*2, SIZE, OC*4, weights+OC*9+ocb);
    }
}


void depthwise_conv_c4r2_normal(float *inp, float *weights, float *output, int OC, int SIZE) {
    int ocb = 0;
    for (int ocb = 0; ocb < OC; ocb+=4) {
        depth_wise_c4r2(inp+ocb, weights+ocb*9, output+ocb, OC*4, SIZE, OC*4, weights+OC*9+ocb);
    }
}