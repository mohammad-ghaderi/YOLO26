#ifndef CONV_H
#define CONV_H

#include <stddef.h>

#define MAX_SIZE 9000000

void igemm4x16_v1(float **indirection, float *w, float *output, int output_stride, int IC);
void igemm4x16_v2(float **indirection, float *w, float *output, int output_stride, int IC);
void igemm4x8_v3(float **indirection, float *w, float *output, int output_stride, int IC);
void igemm8x8_v4(float **indirection, float *w, float *output, int output_stride, int IC);
void gemm4x16_v1(float *input, float *w, float *output, int output_stride, int IC, int layer_stride, int kernel_stride);
void gemm4x16_v2(float *input, float *w, float *output, int output_stride, int IC, int layer_stride, int kernel_stride);
void gemm4x8_v3(float *input, float *w, float *output, int output_stride, int IC, int layer_stride, int kernel_stride);
void gemm8x8_v4(float *input, float *w, float *output, int output_stride, int IC, int layer_stride, int kernel_stride);
void gemm8x8_v5(float *input, float *w, float *output, int output_stride, int IC, int layer_stride, int kernel_stride);
void gemm8x8_v10(float *input, float *w, float *output, int output_stride, int IC, int layer_stride, int kernel_stride);
void gemm4x8x2_v6(float *input, float *w, float *output, int output_stride, int IC, int layer_stride, float *kernel_stride);

void conv3x3oc32_v1(float *input, float *w, float *ouptput, int IC, int SIZE, int OC);
void conv3x3oc32fp16_v1(float *input, float *w, float *ouptput, int IC, int SIZE, int OC);

void add_padding(float *inp, float *inp_padd, int size, int IC);
void add_padding_backward(float *inp, int size, int IC);
void build_indirection(float *input, float **indir, int size, int IC);
void conv_gemm4x8x2_v6(float *input, float *weights, float *output, int SIZE, int IC, int OC);
void conv_gemm8x8_v5(float *input, float *weights, float *output, int SIZE, int IC, int OC);

void winograd_f23_v1(float *input, float *weights, float *out1, float *out2, int IC, int OC, int input_stride);
void winograd_f23(float *input, float *weights, float *output, int SIZE, int IC, int OC);
// void build_indirection(float *input, float **indirection, int size, int IC);

void conv3x3(float *input, float *weights, float *output, int size, int IC, int OC, int version, int thread_cnt, int block_y, int block_x, int stride);
void conv3x3nr8(float *input, float *weights, float *output, int size, int IC, int OC, int stride);

void point_wise_5x16(float *inp, float *weights, float *output, int IC, int OC, int output_stride);
void point_wise_5x20(float *inp, float *weights, float *output, int IC, int OC, int output_stride);

void pointwise_conv5x16(float *inp, float *weights, float *output, int IC, int OC, int SIZE, int gap);
void pointwise_conv5x20(float *inp, float *weights, float *output, int IC, int OC, int SIZE);

void depth_wise_c4(float *inp, float *weights, float *output, int OC, int SIZE);
void depth_wise_c4r2(float *inp, float *weights, float *output, int OC, int SIZE, int output_stride);

void depthwise_conv_c4(float *inp, float *weights, float *output, int OC, int SIZE);
void depthwise_conv_c4r2(float *inp, float *weights, float *output, int OC, int SIZE);

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

void C3K2_C3K_True(float *arr, float *weights, int SIZE, int IC, int OC);

#endif
