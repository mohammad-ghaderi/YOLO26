#include <stdio.h>
#include <string.h>
#include <time.h>
#include "tools/tools.h"
#include "conv.h"
#include "loader.h"
#include <arm_neon.h>

#define STB_IMAGE_IMPLEMENTATION
#include "tools/stb_image.h"


float input[MAX_SIZE];
float new_inp[MAX_SIZE];
float weights[MAX_SIZE];
float pw[MAX_SIZE];
float output[MAX_SIZE];

int SIZE = 640, IC = 3, OC = 16;
int stride = 2;

void SiLU(float *inp);
void SiLU_array(float *inp, int SIZE);



void gemm_ic3s2(float *inp, float *weights, float *output, int SIZE);

int main() {
    int width, height, channels;
    unsigned char *img = stbi_load("test/img.jpg", &width, &height, &channels, 3);
    
    if (load_weights() != 0) {
        printf("Failed to load weights!\n");
        return 1;
    }

    int OUT = (SIZE + 2 - 3)/stride + 1;
    // writeArrayToFile(img, IC, "out/input.txt", 0);
    // writeArrayToFile(weights, 9*IC*OC, "out/weights.txt", 0);
    // writeArrayToFile(weights, 9*OC, "out/weights.txt", 0);  // for depth wise
    
    memset(output, 0, OUT*OUT*OC*4);
    // add_padding_backward(input, SIZE, IC);
    // winograd(input, weights, output, SIZE, IC, OC);


    // conv3x3(input, weights, output, SIZE, IC, OC, version, thread, block_y, block_x, stride);
    // winograd_f23(input, weights, output, SIZE, IC, OC);
    // pointwise_conv_simple(input, weights, output, IC, OC, SIZE);
    // pointwise_conv5x16(input, weights, output, IC, OC, SIZE);
    // pointwise_conv5x20(input, weights, output, IC, OC, SIZE);
    // depthwise_conv_simple(input, weights, output, IC, OC, SIZE);
    // depthwise_conv_c4(input, weights, output, OC, SIZE);
    // depthwise_conv_c4r2(input, weights, output, OC, SIZE);
    // conv3x3(input, weights, output, SIZE, IC, OC, 7, 1, 4, 4, stride);

    pack_weights_ic3(weights, pw);

    // clock_t start = clock();

    gemm_ic3s2(input, pw, output, SIZE);
    // SiLU_array(output, OUT*OUT*OC);
    // for (int i = 0; i < OUT*OUT*OC; i+=4) SiLU(output+i);


    // clock_t end = clock();
    // double time_spent = (double)(end - start) / CLOCKS_PER_SEC;
    // printf("%.6f #\n", time_spent);

    // if (!notprint) writeArrayToFile(output, OUT*OUT*OC, "out/out.txt", 0);



    return 0;
}