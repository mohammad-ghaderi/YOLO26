#include <stdio.h>
#include <stdlib.h>
#include "tools.h"


void writeArrayToFile(void *array, int size, const char *filename, int integer)
{
    FILE *f = fopen(filename, "w");
    if (!f) {
        printf("Error opening file\n");
        return;
    }

    if (integer == 1) {
        int *arr = (int *)array;
        for (int i = 0; i < size; i++)
            fprintf(f, "%d\n", (int)arr[i]);
    } else {
        float *arr = (float *)array;
        for (int i = 0; i < size; i++)
            fprintf(f, "%f\n", arr[i]);
    }

    fclose(f);
}


void fillArrayWithRandom(float *arr, int size) {
    for (int i = 0; i < size; i++) {
        float r = (float)rand() / (float)RAND_MAX;
        arr[i] = (float)r;
    }
}

void pack_weights(float* weights, float* packed, int OC, int IC, int nr) {
    int oc_blocks = (OC + nr - 1) / nr;
    int kc=IC*9;
    for (int ob = 0; ob < oc_blocks; ob++) {
        for (int k = 0; k < kc; k++) {
            for (int oc = 0; oc < nr; oc++) {
                    int oc_idx = ob * nr + oc;
                    if (oc_idx < OC)
                        *packed++ = weights[oc_idx * kc + k];
            }
        }
    }
}

void pack_weights_ic3(float* weights, float* packed) {
    for (int ob = 0; ob < 4; ob++) {
        for (int ic = 0; ic < 3; ic++) {
            for (int k = 0; k < 9; k++) {
                for (int oci = 0; oci < 4; oci++) {
                    int oc = ob*4+oci;
                    *packed++ = weights[oc*27+ k*3+ic];
                }
            }
        }
    }

}

void conv_simple(float *input, float *weights, float *output, int SIZE, int IC, int OC, int p, int stride){
    int padding = 1;
    int idx = 0;

    int OUT = (SIZE + 2*padding - 3)/stride + 1;

    int idxxx = 0;

    for (int oy = 0; oy < OUT; oy++) {
        for (int ox = 0; ox < OUT; ox++) {
            for (int oc = 0; oc < OC; oc++) {
                float ans = 0.0;
                for (int ici = 0; ici < IC; ici+=4) {
                for (int ky = 0; ky < 3; ky++) {
                    for (int kx = 0; kx < 3; kx++) {
                        for (int icc = 0; icc < 4; icc++) {
                            int ic = ici + icc;
                            int iy = oy * stride + ky - padding;
                            int ix = ox * stride + kx - padding;
                            if (iy < 0 || iy >= SIZE || ix < 0 || ix >= SIZE) continue;
                                int w_idx = ((oc*3 + ky)*3 + kx)*IC + ic;
                                float w = weights[w_idx];
                                float a = input[(iy*SIZE + ix)*IC + ic];
                                ans += w * a;
                                // if (p && oy == 0 && ox == 0 && oc == 0) {
                                //     printf("%d:  a:%f, w:%f, ans:%f  |  ic:%d, iy:%d, ix:%d, w:%d\n", ++idxxx, a, w, ans, ic, iy, ix, ky*3+kx+1);
                                // }
                            }
                        }
                    }
                }

                output[idx++] = ans;
            }
        }
    }
}



// //////////////////////////////////////////////////////////////////////////////////////////////////
// //////////////////////////////////////////////////////////////////////////////////////////////////
// //////////////                                                                  //////////////////
// //////////////                         Winograd F(2,3)                          //////////////////
// //////////////                                                                  //////////////////
// //////////////////////////////////////////////////////////////////////////////////////////////////
// //////////////////////////////////////////////////////////////////////////////////////////////////

// Main Winograd convolution

void transform_input_f23(float *inp, int SIZE, int IC, float *V) {
    // const float BT[4][4] = {
    //     {1.0f,  0.0f, -1.0f,  0.0f},
    //     {0.0f,  1.0f,  1.00f, 0.0f},
    //     {0.0f, -1.0f,  1.00f, 0.0f},
    //     {0.0f, -1.0f,  0.00f, 1.0f}
    // };

    float tmp[4*4];
    for (int ic = 0; ic < IC; ic++) {
        int idx = 0;
        for (int i = 0; i < 4; i++) {
            float *c0 = inp + ic + i*(SIZE+2)*IC;
            float *c1 = c0 + IC;
            float *c2 = c1 + IC;
            float *c3 = c2 + IC;

            tmp[idx++] = *c0 - *c2;
            tmp[idx++] = *c1 + *c2;
            tmp[idx++] = *c2 - *c1;
            tmp[idx++] = *c3 - *c1;
        }


        for (int i = 0; i < 4; i++) {
            V[IC*(i+4*0)+ic] = tmp[i] - tmp[i + 8];
            V[IC*(i+4*1)+ic] = tmp[i + 4] + tmp[i + 8];
            V[IC*(i+4*2)+ic] = tmp[i + 8] - tmp[i + 4];
            V[IC*(i+4*3)+ic] = tmp[i + 12] - tmp[i + 4];
        }
    }
    writeArrayToFile(V, IC*4*4, "out/inp^T.txt", 0);

}

void transform_kernel_f23(float* kernel, int IC, int OC, float *U) {
    // const float ktm[4][3] = {
    //     {1.0f,  0.0f, 0.0f},
    //     {0.5f,  0.5f, 0.5f},
    //     {0.5f, -0.5f, 0.5f},
    //     {0.0f,  0.0f, 1.0f}
    // };


    float tmp[3*4];
    for (int oc = 0; oc < OC; oc++) {
        for (int ic = 0; ic < IC; ic++) {
            float *k0 = kernel + ic;
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
        kernel += IC*9;
    }
}

void transform_output_f23(float *out) {
    // const float otm[2][4] = {
    //     {1.0f,  1.0f,  1.0f,  0.0f},
    //     {0.0f,  1.0f, -1.0f,  1.0f}
    // };

    float tmp[4*2];

    for (int i = 0; i < 4; i++) {
        float *o0 = out + 4*i;
        float *o1 = out + 4*i + 1;
        float *o2 = out + 4*i + 2;
        float *o3 = out + 4*i + 3;
        
        tmp[i*2] = *o0 + *o1 + *o2;
        tmp[i*2+1] = *o1 - *o2 + *o3;
    }
    
    for (int i = 0; i < 2; i++) {
        out[i] = tmp[i] + tmp[2+i] + tmp[4+i];
        out[2+i] = tmp[2+i] - tmp[4+i] + tmp[6+i];
    }
}

void winograd(float *inp, float *weight, float *output, int SIZE, int IC, int OC) {

    float U[IC*OC*16];
    float V[IC*4*4];
    float tmp[16];

    transform_kernel_f23(weight, IC, OC, U);
    writeArrayToFile(U, IC*OC*4*4, "out/wt.txt", 0);
    
    for (int ih = 0; ih < SIZE; ih+=2) {
        for (int iw = 0; iw < SIZE; iw+=2) {
            float *inp_tile = inp + (ih*(SIZE+2)+iw)*IC;
            for (int oc = 0; oc < OC; oc++) {
                transform_input_f23(inp_tile, SIZE, IC, V);
                float *w = U + oc*IC*16;
                for (int k = 0; k < 16; k++) {
                    tmp[k] = 0;
                    for (int ic = 0; ic < IC; ic++) {
                        // if (k == 0) printf("inp:%f, w:%f\n", V[ic], U[ic]);
                        tmp[k] += V[k*IC+ ic] * w[k*IC + ic];
                    }
                }
                transform_output_f23(tmp);
                
                output[(ih*SIZE+iw)*OC+oc] = tmp[0];
                output[(ih*SIZE+iw+1)*OC+oc] = tmp[1];
                output[((ih+1)*SIZE+iw)*OC+oc] = tmp[2];
                output[((ih+1)*SIZE+iw+1)*OC+oc] = tmp[3];
            }

        }
    }




}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
//////////////////////                            //////////////////////////
//////////////////////     PointWise Conv 1x1     //////////////////////////
//////////////////////                            //////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

void pointwise_conv_simple(float *inp, float *weights, float *output, int IC, int OC, int SIZE) {

    int idx = 0;
    for (int ih = 0; ih < SIZE; ih++) {
        for (int iw = 0; iw < SIZE; iw++) {
            for (int oc = 0; oc < OC; oc++) {
                float ans = 0;
                for (int ic = 0; ic < IC; ic++) {
                    float x = inp[(ih*SIZE+iw)*IC+ic];
                    float w = weights[oc*IC+ic];
                    ans += x * w;
                    // if (oc == 16 && ih == 0 && iw == 0) {
                    //     printf("x:%f, w:%f, ans:%f\n", x, w, ans);
                    // }
                }
                output[idx++] = ans;
            }
        }
    }
}


////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
//////////////////////                            //////////////////////////
//////////////////////     DepthWise Conv 3x3     //////////////////////////
//////////////////////                            //////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

void depthwise_conv_simple(float *inp, float *weights, float *output, int IC, int OC, int SIZE) {
     int idx = 0;
    for (int ih = 0; ih < SIZE; ih++) {
        for (int iw = 0; iw < SIZE; iw++) {
            for (int oc = 0; oc < OC; oc++) {
                float ans = 0;
                for (int kx = 0; kx < 3; kx++) {
                    for (int ky = 0; ky < 3; ky++) {
                        float x = inp[((ih+ky)*(SIZE+2)+(iw+kx))*OC+oc];
                        float w = weights[oc*9+3*ky+kx];
                        ans += x * w;
                        // if (oc == 0 && ih == 0 && iw == 0) {
                        //     printf("x:%f, w:%f, ans:%f\n", x, w, ans);
                        // }
                    }
                }
                output[idx++] = ans;
            }
        }
    }
}
