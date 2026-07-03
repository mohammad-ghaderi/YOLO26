#ifndef FUNC_H
#define FUNC_H

void add_padding(float *inp, float *inp_padd, int size, int IC);
void add_padding_backward(float *inp, int size, int IC);
void build_indirection(float *input, float **indir, int size, int IC);

void SiLU(float *inp);
void SiLU_array(float *inp, int SIZE);
void sigmoid_array(float *inp, int SIZE);
void SiLU_array_bias_oc16(float *inp, float *bias, int SIZE);
void SiLU_array_bias_oc8(float *inp, float *bias, int SIZE);
void SiLU_array_bias_full(float *inp, float *bias, int SIZE, int OC, int gap);
void bias_act_d_padd_oc32(float *inp, float *bias, float *out);
void bias_act_d_padd(float *inp, float *bias, float *out, int SIZE, int IC, int OC);
void bias_act_d(float *inp, float *bias, float *out, int SIZE, int IC, int OC, int gap);
void bias_act_sum_oc16(float *inp, float *bias, float *X, float *out, int SIZE, int output_stride);
void bias_act_sum(float *inp, float *bias, float *X, float *out, int SIZE, int output_stride, int OC, int x_stride);

void bias_split_attn(float *inp, float *bias, float *out, int size);

void C3K2_C3K_True(float *arr, float *weights, int SIZE, int IC, int OC);

void maxpool_3_5x5(float *inp, int gap, int next_col, int next_row);

void matrix_dot_scale_softmax(float *A, float *B, float *C);
void v_dot_attn(float *v, float *attn, float *output);

void tensor_sum(float *A, float *B, float *output, int number, int out_gap);
void bias_sum(float *input, float *bias, float *X, float *output, int number);
void concat_layout(float *input, float *output, int SIZE, int IC, int gap);
void upsample_concat(float *input, float *output, int SIZE, int IC, int OC);


#endif