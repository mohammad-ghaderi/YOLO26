.global gemm_ic3s2
.type gemm_ic3s2, %function

.extern exp_pack1
.extern exp_pack2
.extern exp_pack3

// 4 output in each iteration


gemm_ic3s2:
    // x0: input address
    // x1: weights address
    // x2: output address
    // x3: SIZE

    sub sp, sp, #80
    stp q14,  q15,  [sp, #0]
    stp q8,  q9,  [sp, #32]
    str q10, [sp, #64]

    // output address:
    // x16, x2, x14, x15
    // x16 is for the prev unfinished

    add x14, x2, #64
    add x15, x14, #64
    add x16, x15, #64


    mov     x9, #12         // IC:3 * 4bytes
    // add     x6, x3, #2      // SIZE+2
    mul     x9, x9, x3      // x9 = next input layer

    mov     x10, x0         // row0
    add     x11, x10, x9    // row1
    add     x12, x11, x9    // row2

    // input
    // v16, v19 | v22, v25 | v28, v31       v4
    // v15, v18 | v21, v24 | v27, v30       v5
    // v14, v17 | v20, v23 | v26, v29       v6

    // output
    // v0, v1, v2, v3

    // weight
    // v7

    // activation constants
    // v8, v9, v10
    ldr     q8, exp_pack1          // v8 = {hi, lo, LOG2EF, 0.5}
    ldr     q9, exp_pack2          // v9 = {c1, c2 , p4, p5}
    ldr     q10, exp_pack3         // v10 = {p0, p1, p2, p3}

    mov     x6, x3
    lsr     x6, x6, #1      // x6 = SIZE/2  -> oh
    mov     x7, x6          // x7 = SIZE/2  -> ow
.oh_loop:

    movi    v4.4s, #0
    movi    v5.4s, #0
    movi    v6.4s, #0
.ow_loop:
    ld1     {v14.4s, v15.4s, v16.4s}, [x10], #48 // row0
    ld1     {v17.4s, v18.4s, v19.4s}, [x10], #48 // row0
    ld1     {v20.4s, v21.4s, v22.4s}, [x11], #48 // row1
    ld1     {v23.4s, v24.4s, v25.4s}, [x11], #48 // row1
    ld1     {v26.4s, v27.4s, v28.4s}, [x12], #48 // row2
    ld1     {v29.4s, v30.4s, v31.4s}, [x12], #48 // row2

    mov     x13, x1     // reset weights pointer
    mov     x8, #16
.oc_loop:
    movi    v0.4s, #0
    movi    v1.4s, #0
    movi    v2.4s, #0
    movi    v3.4s, #0

    // R of RGB

    ld1     {v7.4s}, [x13], #16        // w1

    fmla    v0.4s, v7.4s, v4.s[1]
    fmla    v1.4s, v7.4s, v14.s[3]
    fmla    v2.4s, v7.4s, v16.s[1]
    fmla    v3.4s, v7.4s, v17.s[3]

    ld1     {v7.4s}, [x13], #16        // w2

    fmla    v0.4s, v7.4s, v14.s[0]
    fmla    v1.4s, v7.4s, v15.s[2]
    fmla    v2.4s, v7.4s, v17.s[0]
    fmla    v3.4s, v7.4s, v18.s[2]

    ld1     {v7.4s}, [x13], #16        // w3

    fmla    v0.4s, v7.4s, v14.s[3]
    fmla    v1.4s, v7.4s, v16.s[1]
    fmla    v2.4s, v7.4s, v17.s[3]
    fmla    v3.4s, v7.4s, v19.s[1]

    ld1     {v7.4s}, [x13], #16        // w4

    fmla    v0.4s, v7.4s, v5.s[1]
    fmla    v1.4s, v7.4s, v20.s[3]
    fmla    v2.4s, v7.4s, v22.s[1]
    fmla    v3.4s, v7.4s, v23.s[3]

    ld1     {v7.4s}, [x13], #16        // w5

    fmla    v0.4s, v7.4s, v20.s[0]
    fmla    v1.4s, v7.4s, v21.s[2]
    fmla    v2.4s, v7.4s, v23.s[0]
    fmla    v3.4s, v7.4s, v24.s[2]

    ld1     {v7.4s}, [x13], #16        // w6

    fmla    v0.4s, v7.4s, v20.s[3]
    fmla    v1.4s, v7.4s, v22.s[1]
    fmla    v2.4s, v7.4s, v23.s[3]
    fmla    v3.4s, v7.4s, v25.s[1]

    ld1     {v7.4s}, [x13], #16        // w7

    fmla    v0.4s, v7.4s, v6.s[1]
    fmla    v1.4s, v7.4s, v26.s[3]
    fmla    v2.4s, v7.4s, v28.s[1]
    fmla    v3.4s, v7.4s, v29.s[3]

    ld1     {v7.4s}, [x13], #16        // w8

    fmla    v0.4s, v7.4s, v26.s[0]
    fmla    v1.4s, v7.4s, v27.s[2]
    fmla    v2.4s, v7.4s, v29.s[0]
    fmla    v3.4s, v7.4s, v30.s[2]

    ld1     {v7.4s}, [x13], #16        // w9

    fmla    v0.4s, v7.4s, v26.s[3]
    fmla    v1.4s, v7.4s, v28.s[1]
    fmla    v2.4s, v7.4s, v29.s[3]
    fmla    v3.4s, v7.4s, v31.s[1]


    // G of RGB

    ld1     {v7.4s}, [x13], #16        // w1

    fmla    v0.4s, v7.4s, v4.s[2]
    fmla    v1.4s, v7.4s, v15.s[0]
    fmla    v2.4s, v7.4s, v16.s[2]
    fmla    v3.4s, v7.4s, v18.s[0]

    ld1     {v7.4s}, [x13], #16        // w2

    fmla    v0.4s, v7.4s, v14.s[1]
    fmla    v1.4s, v7.4s, v15.s[3]
    fmla    v2.4s, v7.4s, v17.s[1]
    fmla    v3.4s, v7.4s, v18.s[3]

    ld1     {v7.4s}, [x13], #16        // w3

    fmla    v0.4s, v7.4s, v15.s[0]
    fmla    v1.4s, v7.4s, v16.s[2]
    fmla    v2.4s, v7.4s, v18.s[0]
    fmla    v3.4s, v7.4s, v19.s[2]

    ld1     {v7.4s}, [x13], #16        // w4

    fmla    v0.4s, v7.4s, v5.s[2]
    fmla    v1.4s, v7.4s, v21.s[0]
    fmla    v2.4s, v7.4s, v22.s[2]
    fmla    v3.4s, v7.4s, v24.s[0]

    ld1     {v7.4s}, [x13], #16        // w5

    fmla    v0.4s, v7.4s, v20.s[1]
    fmla    v1.4s, v7.4s, v21.s[3]
    fmla    v2.4s, v7.4s, v23.s[1]
    fmla    v3.4s, v7.4s, v24.s[3]

    ld1     {v7.4s}, [x13], #16        // w6

    fmla    v0.4s, v7.4s, v21.s[0]
    fmla    v1.4s, v7.4s, v22.s[2]
    fmla    v2.4s, v7.4s, v24.s[0]
    fmla    v3.4s, v7.4s, v25.s[2]

    ld1     {v7.4s}, [x13], #16        // w7

    fmla    v0.4s, v7.4s, v6.s[2]
    fmla    v1.4s, v7.4s, v27.s[0]
    fmla    v2.4s, v7.4s, v28.s[2]
    fmla    v3.4s, v7.4s, v30.s[0]

    ld1     {v7.4s}, [x13], #16        // w8

    fmla    v0.4s, v7.4s, v26.s[1]
    fmla    v1.4s, v7.4s, v27.s[3]
    fmla    v2.4s, v7.4s, v29.s[1]
    fmla    v3.4s, v7.4s, v30.s[3]

    ld1     {v7.4s}, [x13], #16        // w9

    fmla    v0.4s, v7.4s, v27.s[0]
    fmla    v1.4s, v7.4s, v28.s[2]
    fmla    v2.4s, v7.4s, v30.s[0]
    fmla    v3.4s, v7.4s, v31.s[2]

    // B of RGB 

    ld1     {v7.4s}, [x13], #16        // w1

    fmla    v0.4s, v7.4s, v4.s[3]
    fmla    v1.4s, v7.4s, v15.s[1]
    fmla    v2.4s, v7.4s, v16.s[3]
    fmla    v3.4s, v7.4s, v18.s[1]

    ld1     {v7.4s}, [x13], #16        // w2

    fmla    v0.4s, v7.4s, v14.s[2]
    fmla    v1.4s, v7.4s, v16.s[0]
    fmla    v2.4s, v7.4s, v17.s[2]
    fmla    v3.4s, v7.4s, v19.s[0]

    ld1     {v7.4s}, [x13], #16        // w3

    fmla    v0.4s, v7.4s, v15.s[1]
    fmla    v1.4s, v7.4s, v16.s[3]
    fmla    v2.4s, v7.4s, v18.s[1]
    fmla    v3.4s, v7.4s, v19.s[3]

    ld1     {v7.4s}, [x13], #16        // w4

    fmla    v0.4s, v7.4s, v5.s[3]
    fmla    v1.4s, v7.4s, v21.s[1]
    fmla    v2.4s, v7.4s, v22.s[3]
    fmla    v3.4s, v7.4s, v24.s[1]

    ld1     {v7.4s}, [x13], #16        // w5

    fmla    v0.4s, v7.4s, v20.s[2]
    fmla    v1.4s, v7.4s, v22.s[0]
    fmla    v2.4s, v7.4s, v23.s[2]
    fmla    v3.4s, v7.4s, v25.s[0]

    ld1     {v7.4s}, [x13], #16        // w6

    fmla    v0.4s, v7.4s, v21.s[1]
    fmla    v1.4s, v7.4s, v22.s[3]
    fmla    v2.4s, v7.4s, v24.s[1]
    fmla    v3.4s, v7.4s, v25.s[3]

    ld1     {v7.4s}, [x13], #16        // w7

    fmla    v0.4s, v7.4s, v6.s[3]
    fmla    v1.4s, v7.4s, v27.s[1]
    fmla    v2.4s, v7.4s, v28.s[3]
    fmla    v3.4s, v7.4s, v30.s[1]

    ld1     {v7.4s}, [x13], #16        // w8

    fmla    v0.4s, v7.4s, v26.s[2]
    fmla    v1.4s, v7.4s, v28.s[0]
    fmla    v2.4s, v7.4s, v29.s[2]
    fmla    v3.4s, v7.4s, v31.s[0]

    ld1     {v7.4s}, [x13], #16        // w9

    fmla    v0.4s, v7.4s, v27.s[1]
    fmla    v1.4s, v7.4s, v28.s[3]
    fmla    v2.4s, v7.4s, v30.s[1]
    fmla    v3.4s, v7.4s, v31.s[3]

    // v11, v12, v13, v7, 

    // store 

    st1     {v0.4s}, [x2], #16
    st1     {v1.4s}, [x14], #16
    st1     {v2.4s}, [x15], #16
    st1     {v3.4s}, [x16], #16

    subs    x8, x8, #4
    bgt .oc_loop
    
    mov     v4.16b, v19.16b
    mov     v5.16b, v25.16b
    mov     v6.16b, v31.16b

    add x2, x2, #192
    add x14, x14, #192
    add x15, x15, #192
    add x16, x16, #192

    subs    x7, x7, #4
    bgt .ow_loop

    add x10, x10, x9
    add x11, x11, x9
    add x12, x12, x9

    mov     x7, x3
    lsr     x7, x7, #1

    subs    x6, x6, #1
    bgt .oh_loop

    ldp q14,  q15,  [sp, #0]
    ldp q8,  q9,  [sp, #32]
    ldr q10, [sp, #64]
    add sp, sp, #80

    ret
