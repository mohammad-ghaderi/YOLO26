.global gemm8x8fp16_v4
.type gemm8x8fp16_v4, %function
// no stack, 4 input channel read in loop


gemm8x8fp16_v4:
    // x0: indirction input address
    // x1: weights address
    // x2: output address
    // x3: output stride
    // x4: IC
    // x5: layer stride
    // x6: kernel sride

    sub     sp, sp, #32
    stp     q8, q9, [sp]

    movi    v16.4s, #0
    movi    v17.4s, #0

    movi    v18.4s, #0
    movi    v19.4s, #0

    movi    v20.4s, #0
    movi    v21.4s, #0

    movi    v22.4s, #0
    movi    v23.4s, #0

    movi    v24.4s, #0
    movi    v25.4s, #0

    movi    v26.4s, #0
    movi    v27.4s, #0

    movi    v28.4s, #0
    movi    v29.4s, #0
    
    movi    v30.4s, #0
    movi    v31.4s, #0


    mov     x7,  x0             // pixel0
    add     x8,  x7,  x6        // pixel1 (+ (9*1)*8)
    add     x9,  x8,  x6        // pixel2 (+ (9*2)*8)
    add     x10, x9,  x6        // pixel3 (+ (9*3)*8)
    add     x11, x10, x6        // pixel4 (+ (9*4)*8)
    add     x12, x11, x6        // pixel5 (+ (9*5)*8)
    add     x13, x12, x6        // pixel6 (+ (9*6)*8)
    add     x17, x13, x6        // pixel7 (+ (9*7)*8)

    mov     x14, #3             // ky idx
    mov     x15, #3             // kx idx
kernel_loop:

    mov     x16, x4             // ic idx
ic_loop:
    // load inputs

    ld1         {v0.4h}, [x7], 8
    ld1         {v1.4h}, [x8], 8
    ld1         {v2.4h}, [x9], 8
    ld1         {v3.4h}, [x10], 8
    ld1         {v4.4h}, [x11], 8
    ld1         {v5.4h}, [x12], 8
    ld1         {v6.4h}, [x13], 8
    ld1         {v7.4h}, [x17], 8
    
    // convert float16 -> float32
    fcvtl       v0.4s, v0.4h
    fcvtl       v1.4s, v1.4h
    fcvtl       v2.4s, v2.4h
    fcvtl       v3.4s, v3.4h
    fcvtl       v4.4s, v4.4h
    fcvtl       v5.4s, v5.4h
    fcvtl       v6.4s, v6.4h
    fcvtl       v7.4s, v7.4h

    //                                      input: v0, v1, v2, v3, v4, v5, v6, v7
    // load weights                         weights: v8, v9

    ld1         {v8.8h}, [x1], 16
    fcvtl2      v9.4s, v8.8h
    fcvtl       v8.4s, v8.4h

    fmla        v16.4s, v8.4s, v0.s[0]
    fmla        v17.4s, v9.4s, v0.s[0]
    fmla        v18.4s, v8.4s, v1.s[0]
    fmla        v19.4s, v9.4s, v1.s[0]
    fmla        v20.4s, v8.4s, v2.s[0]
    fmla        v21.4s, v9.4s, v2.s[0]
    fmla        v22.4s, v8.4s, v3.s[0]
    fmla        v23.4s, v9.4s, v3.s[0]
    fmla        v24.4s, v8.4s, v4.s[0]
    fmla        v25.4s, v9.4s, v4.s[0]
    fmla        v26.4s, v8.4s, v5.s[0]
    fmla        v27.4s, v9.4s, v5.s[0]
    fmla        v28.4s, v8.4s, v6.s[0]
    fmla        v29.4s, v9.4s, v6.s[0]
    fmla        v30.4s, v8.4s, v7.s[0]
    fmla        v31.4s, v9.4s, v7.s[0]


    ld1         {v8.8h}, [x1], 16
    fcvtl2      v9.4s, v8.8h
    fcvtl       v8.4s, v8.4h

    fmla        v16.4s, v8.4s, v0.s[1]
    fmla        v17.4s, v9.4s, v0.s[1]
    fmla        v18.4s, v8.4s, v1.s[1]
    fmla        v19.4s, v9.4s, v1.s[1]
    fmla        v20.4s, v8.4s, v2.s[1]
    fmla        v21.4s, v9.4s, v2.s[1]
    fmla        v22.4s, v8.4s, v3.s[1]
    fmla        v23.4s, v9.4s, v3.s[1]
    fmla        v24.4s, v8.4s, v4.s[1]
    fmla        v25.4s, v9.4s, v4.s[1]
    fmla        v26.4s, v8.4s, v5.s[1]
    fmla        v27.4s, v9.4s, v5.s[1]
    fmla        v28.4s, v8.4s, v6.s[1]
    fmla        v29.4s, v9.4s, v6.s[1]
    fmla        v30.4s, v8.4s, v7.s[1]
    fmla        v31.4s, v9.4s, v7.s[1]


    ld1         {v8.8h}, [x1], 16
    fcvtl2      v9.4s, v8.8h
    fcvtl       v8.4s, v8.4h

    fmla        v16.4s, v8.4s, v0.s[2]
    fmla        v17.4s, v9.4s, v0.s[2]
    fmla        v18.4s, v8.4s, v1.s[2]
    fmla        v19.4s, v9.4s, v1.s[2]
    fmla        v20.4s, v8.4s, v2.s[2]
    fmla        v21.4s, v9.4s, v2.s[2]
    fmla        v22.4s, v8.4s, v3.s[2]
    fmla        v23.4s, v9.4s, v3.s[2]
    fmla        v24.4s, v8.4s, v4.s[2]
    fmla        v25.4s, v9.4s, v4.s[2]
    fmla        v26.4s, v8.4s, v5.s[2]
    fmla        v27.4s, v9.4s, v5.s[2]
    fmla        v28.4s, v8.4s, v6.s[2]
    fmla        v29.4s, v9.4s, v6.s[2]
    fmla        v30.4s, v8.4s, v7.s[2]
    fmla        v31.4s, v9.4s, v7.s[2]


    ld1         {v8.8h}, [x1], 16
    fcvtl2      v9.4s, v8.8h
    fcvtl       v8.4s, v8.4h

    fmla        v16.4s, v8.4s, v0.s[3]
    fmla        v17.4s, v9.4s, v0.s[3]
    fmla        v18.4s, v8.4s, v1.s[3]
    fmla        v19.4s, v9.4s, v1.s[3]
    fmla        v20.4s, v8.4s, v2.s[3]
    fmla        v21.4s, v9.4s, v2.s[3]
    fmla        v22.4s, v8.4s, v3.s[3]
    fmla        v23.4s, v9.4s, v3.s[3]
    fmla        v24.4s, v8.4s, v4.s[3]
    fmla        v25.4s, v9.4s, v4.s[3]
    fmla        v26.4s, v8.4s, v5.s[3]
    fmla        v27.4s, v9.4s, v5.s[3]
    fmla        v28.4s, v8.4s, v6.s[3]
    fmla        v29.4s, v9.4s, v6.s[3]
    fmla        v30.4s, v8.4s, v7.s[3]
    fmla        v31.4s, v9.4s, v7.s[3]


    subs x16, x16, #4
    bgt ic_loop

    subs x15, x15, #1
    bgt kernel_loop

    adds     x7,  x7,  x5
    adds     x8,  x8,  x5
    adds     x9,  x9,  x5
    adds     x10, x10, x5
    adds     x11, x11, x5
    adds     x12, x12, x5
    adds     x13, x13, x5
    adds     x17, x17, x5

    mov x15, #3

    subs x14, x14, #1
    bgt kernel_loop

    // store outputs


    st1 {v16.4s}, [x2], #16
    st1 {v17.4s}, [x2], #16

    add x2, x2, x3

    st1 {v18.4s}, [x2], #16
    st1 {v19.4s}, [x2], #16

    add x2, x2, x3

    st1 {v20.4s}, [x2], #16
    st1 {v21.4s}, [x2], #16
    
    add x2, x2, x3

    st1 {v22.4s}, [x2], #16
    st1 {v23.4s}, [x2], #16

    add x2, x2, x3

    st1 {v24.4s}, [x2], #16
    st1 {v25.4s}, [x2], #16

    add x2, x2, x3

    st1 {v26.4s}, [x2], #16
    st1 {v27.4s}, [x2], #16

    add x2, x2, x3

    st1 {v28.4s}, [x2], #16
    st1 {v29.4s}, [x2], #16

    add x2, x2, x3

    st1 {v30.4s}, [x2], #16
    st1 {v31.4s}, [x2], #16


    ldp     q8, q9, [sp]
    add     sp, sp, #32

    ret
