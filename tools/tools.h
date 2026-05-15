#ifndef WRITE_ARRAY_H
#define WRITE_ARRAY_H

#include <stdint.h>
#include <stddef.h>

void writeArrayToFile(void *array, int size, const char *filename, int integer);
void fillArrayWithRandom(float *arr, int size);

void pack_weights(float* weights, float* packed, int OC, int IC, int nr);
void pack_weights_ic3(float* weights, float* packed);
void conv_simple(float *input, float *weights, float *output, int SIZE, int IC, int OC, int p, int stride);

void winograd(float *inp, float *weight, float *output, int SIZE, int IC, int OC);
void transform_kernel_f23(float* kernel, int IC, int OC, float *U);
void pointwise_conv_simple(float *inp, float *weights, float *output, int IC, int OC, int SIZE);
void depthwise_conv_simple(float *inp, float *weights, float *output, int IC, int OC, int SIZE);


#endif