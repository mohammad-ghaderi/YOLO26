.global add_padding
.type add_padding, %function

add_padding:
    // x0: input array
    // x1: size
    // x2: IC
    // backward, no extra memory

    movi v5.16b, #0
    mul x8, x1, x2      // x8 = size*IC
    add x9, x2, x2      // x9 = 2*IC

    add x4, x1, #2      // x4 = size + 2
    mul x5, x4, x4      // x5 = (size+2)*(size+2)
    mul x3, x5, x2      // x3 = (size+2)*(size+2)*IC    size of all with padding

    sub x3, x3, #16     
    add x3, x3, x0      // where to start writing backward

    mul x5, x1, x8      // x5 = size*size*IC            size of all without padding

    sub x5, x5, #16
    add x0, x0, x5      // where to start reading backward

    add x6, x8, x2
last_zero_layer_loop:               // padd 0 for bottom layer
    st1 {v5.16b}, [x3]
    sub x3, x3, #16
    subs x6, x6, #16
    b.gt last_zero_layer_loop

    mov x7, x1
midd_loop:                          // middle layer pad + data + pad

    mov x6, x9
two_zero_col:                       // two column of 0 pad, one for the start of bottom layer and next for end of current layer
    st1 {v5.16b}, [x3]
    sub x3, x3, #16
    subs x6, x6, #16
    b.gt two_zero_col

    mov x6, x8
data_loop:
    ld1 {v4.16b}, [x0]
    st1 {v4.16b}, [x3]
    sub x0, x0, #16
    sub x3, x3, #16
    subs x6, x6, #16
    b.gt data_loop

    subs x7, x7, #1
    b.gt midd_loop

    add x6, x8, x9
    add x6, x6, x2
first_zero_layer_loop:              // top 0 layer
    st1 {v5.16b}, [x3]
    sub x3, x3, #16
    subs x6, x6, #16
    b.gt first_zero_layer_loop

    ret
