.global add_padding, add_padding_backward
.type add_padding, %function
.type add_padding_backward, %function

add_padding:
    // x0: address of input array
    // x1: address of output array
    // x2: size
    // x3: IC

    movi    v5.4h, #0
    mul     x8, x2, x3              // x8 = size*IC         -> for middle values
    add     x9, x3, x3              // x9 = 2*IC            -> for two zero IC of last and first
    add     x10, x8, x3             // x10 = (size+1)*IC    -> for last zero layer, except first zero IC
    add     x11, x10, x9            // x11 = (size+3)*IC    -> for first zero layer and first zero IC of second layer


    // ------- Top zero layer -------
    mov     x7, x11
.top_loop:
    st1     {v5.4s}, [x1], #16
    subs    x7, x7, #4
    b.gt    .top_loop

    // ------- Mdille layers -------
    mov     x12, x2
.outer_loop:
    mov     x7, x8
.inner_loop:
    ld1     {v0.4s}, [x0], #16
    st1     {v0.4s}, [x1], #16

    subs    x7, x7, #4
    b.gt    .inner_loop

    // last two zero IC of each middle layer
    mov x7, x9
.two_zero:
    st1     {v5.4s}, [x1], #16
    subs    x7, x7, #4
    b.gt    .two_zero

    subs    x12, x12, #1
    b.gt    .outer_loop

    // ------- Bottom zero layer -------
    
    mov     x7, x10
.bottom_layer:
    st1     {v5.4s}, [x1], #16
    subs    x7, x7, #4
    b.gt    .bottom_layer

    ret




add_padding_backward:
    // x0: input array
    // x1: size
    // x2: IC
    // backward, no extra memory

    movi    v5.4s, #0
    mul     x8, x1, x2      // x8 = size*IC
    add     x9, x2, x2      // x9 = 2*IC

    add     x4, x1, #2      // x4 = size + 2
    mul     x5, x4, x4      // x5 = (size+2)*(size+2)
    mul     x3, x5, x2      // x3 = (size+2)*(size+2)*IC    size of all with padding

    lsl     x3, x3, #2      // x3 = 4*x3 because float is 4 bytes
    sub     x3, x3, #16     
    add     x3, x3, x0      // where to start writing backward

    mul     x5, x1, x8      // x5 = size*size*IC            size of all without padding

    lsl     x5, x5, #2      // x5 = 4*x5    because float is 4 bytes
    sub     x5, x5, #16
    add     x0, x0, x5      // where to start reading backward

    add     x6, x8, x2
.last_zero_layer_loop:               // padd 0 for bottom layer
    st1     {v5.4s}, [x3]
    sub     x3, x3, #16
    subs    x6, x6, #4
    b.gt .last_zero_layer_loop

    mov     x7, x1
.midd_loop:                          // middle layer pad + data + pad

    mov     x6, x9
.two_zero_col:                       // two column of 0 pad, one for the start of bottom layer and next for end of current layer
    st1     {v5.4s}, [x3]
    sub     x3, x3, #16
    subs    x6, x6, #4
    b.gt .two_zero_col

    mov     x6, x8
.data_loop:
    ld1     {v4.4s}, [x0]
    st1     {v4.4s}, [x3]
    sub     x0, x0, #16
    sub     x3, x3, #16
    subs    x6, x6, #4
    b.gt .data_loop

    subs    x7, x7, #1
    b.gt .midd_loop

    add     x6, x8, x9
    add     x6, x6, x2
.first_zero_layer_loop:              // top 0 layer
    st1     {v5.4s}, [x3]
    sub     x3, x3, #16
    subs    x6, x6, #4
    b.gt .first_zero_layer_loop

    ret
