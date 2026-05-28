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
void SiLU_array_bias(float *inp, float *bias, int SIZE);
void SiLU_array_bias_oc8(float *inp, float *bias, int SIZE);
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
    SiLU_array_bias(arr2, weights+IC*OC*9, OUT*OUT*OC);
    weights += IC*OC*9+OC;

    IC = OC; SIZE = OUT; OC = 32; OUT /= 2;

    conv3x3nr8(arr2, weights, arr1, SIZE, IC, OC, stride);
    SiLU_array_bias_full(arr1, weights+IC*OC*9, OUT*OUT*OC, OC);
    weights += IC*OC*9+OC;
    
    IC = OC; SIZE = OUT; stride = 1;
    pointwise_conv5x16(arr1, weights, arr2, IC, OC, SIZE);
    SiLU_array_bias_full(arr2, weights+IC*OC, OUT*OUT*OC, OC);
    weights += IC*OC+OC;

    IC = 16; OC = 8;
    int idx = 0;

    for (int ih = 0; ih < SIZE; ih++) {         // temporal for y[-1] after split (i'll merge it later)
        for (int iw = 0; iw < SIZE; iw++) {
            for (int ic = 0; ic < IC; ic++) {
                arr3[idx++] = arr2[(ih*SIZE+iw)*IC*2+ic+IC];
            }
        }
    }

    weights += 48*64+64; // skip the conv1x1 cv2 weights and bias (IC=48 OC=64)

    add_padding_backward(arr3, SIZE, IC);
    winograd_f23(arr3, weights, arr1, SIZE, IC, OC);
    SiLU_array_bias_oc8(arr1, weights+OC*IC*16, OUT*OUT*OC);
    weights += IC*OC*16+OC;

    IC = 8; OC = 16;
    
    add_padding_backward(arr1, SIZE, IC);
    winograd_f23(arr1, weights, arr3, SIZE, IC, OC);
    SiLU_array_bias(arr3, weights+OC*IC*16, OUT*OUT*OC);

    writeArrayToFile(arr3, OUT*OUT*OC, "out/wino.txt", 0);
    
    here();
    



    return 0;
}