.global igemm4x16_v1
.type igemm4x16_v1, %function
// no stack, 4 input channel read in loop


igemm4x16_v1:
    // x0: indirction input address
    // x1: weights address
    // x2: output address
    // x3: output stride
    // x4: IC

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

    mov     x15, #9             // k idx
kernel_loop:

    ldr     x10, [x0]            // pixel0
    ldr     x11, [x0, 72]        // pixel1 (+ 9*8)
    ldr     x12, [x0, 144]       // pixel2 (+ 18*8)
    ldr     x13, [x0, 216]       // pixel3 (+ 27*8)

    mov     x16, x4             // ic idx
ic_loop:
    // load inputs

    ld1         {v0.4s}, [x10], #16
    ld1         {v1.4s}, [x11], #16
    ld1         {v2.4s}, [x12], #16
    ld1         {v3.4s}, [x13], #16

    //                                      input: v0, v1, v2, v3
    // load weights                         weights: v4, v5, v6, v7

    ld1         {v4.4s, v5.4s, v6.4s, v7.4s}, [x1], #64

    fmla        v16.4s, v4.4s, v0.s[0]
    fmla        v17.4s, v5.4s, v0.s[0]
    fmla        v18.4s, v6.4s, v0.s[0]
    fmla        v19.4s, v7.4s, v0.s[0]
    fmla        v20.4s, v4.4s, v1.s[0]
    fmla        v21.4s, v5.4s, v1.s[0]
    fmla        v22.4s, v6.4s, v1.s[0]
    fmla        v23.4s, v7.4s, v1.s[0]
    fmla        v24.4s, v4.4s, v2.s[0]
    fmla        v25.4s, v5.4s, v2.s[0]
    fmla        v26.4s, v6.4s, v2.s[0]
    fmla        v27.4s, v7.4s, v2.s[0]
    fmla        v28.4s, v4.4s, v3.s[0]
    fmla        v29.4s, v5.4s, v3.s[0]
    fmla        v30.4s, v6.4s, v3.s[0]
    fmla        v31.4s, v7.4s, v3.s[0]
    
    ld1         {v4.4s, v5.4s, v6.4s, v7.4s}, [x1], #64

    fmla        v16.4s, v4.4s, v0.s[1]
    fmla        v17.4s, v5.4s, v0.s[1]
    fmla        v18.4s, v6.4s, v0.s[1]
    fmla        v19.4s, v7.4s, v0.s[1]
    fmla        v20.4s, v4.4s, v1.s[1]
    fmla        v21.4s, v5.4s, v1.s[1]
    fmla        v22.4s, v6.4s, v1.s[1]
    fmla        v23.4s, v7.4s, v1.s[1]
    fmla        v24.4s, v4.4s, v2.s[1]
    fmla        v25.4s, v5.4s, v2.s[1]
    fmla        v26.4s, v6.4s, v2.s[1]
    fmla        v27.4s, v7.4s, v2.s[1]
    fmla        v28.4s, v4.4s, v3.s[1]
    fmla        v29.4s, v5.4s, v3.s[1]
    fmla        v30.4s, v6.4s, v3.s[1]
    fmla        v31.4s, v7.4s, v3.s[1]
    
    ld1         {v4.4s, v5.4s, v6.4s, v7.4s}, [x1], #64

    fmla        v16.4s, v4.4s, v0.s[2]
    fmla        v17.4s, v5.4s, v0.s[2]
    fmla        v18.4s, v6.4s, v0.s[2]
    fmla        v19.4s, v7.4s, v0.s[2]
    fmla        v20.4s, v4.4s, v1.s[2]
    fmla        v21.4s, v5.4s, v1.s[2]
    fmla        v22.4s, v6.4s, v1.s[2]
    fmla        v23.4s, v7.4s, v1.s[2]
    fmla        v24.4s, v4.4s, v2.s[2]
    fmla        v25.4s, v5.4s, v2.s[2]
    fmla        v26.4s, v6.4s, v2.s[2]
    fmla        v27.4s, v7.4s, v2.s[2]
    fmla        v28.4s, v4.4s, v3.s[2]
    fmla        v29.4s, v5.4s, v3.s[2]
    fmla        v30.4s, v6.4s, v3.s[2]
    fmla        v31.4s, v7.4s, v3.s[2]
    
    ld1         {v4.4s, v5.4s, v6.4s, v7.4s}, [x1], #64

    fmla        v16.4s, v4.4s, v0.s[3]
    fmla        v17.4s, v5.4s, v0.s[3]
    fmla        v18.4s, v6.4s, v0.s[3]
    fmla        v19.4s, v7.4s, v0.s[3]
    fmla        v20.4s, v4.4s, v1.s[3]
    fmla        v21.4s, v5.4s, v1.s[3]
    fmla        v22.4s, v6.4s, v1.s[3]
    fmla        v23.4s, v7.4s, v1.s[3]
    fmla        v24.4s, v4.4s, v2.s[3]
    fmla        v25.4s, v5.4s, v2.s[3]
    fmla        v26.4s, v6.4s, v2.s[3]
    fmla        v27.4s, v7.4s, v2.s[3]
    fmla        v28.4s, v4.4s, v3.s[3]
    fmla        v29.4s, v5.4s, v3.s[3]
    fmla        v30.4s, v6.4s, v3.s[3]
    fmla        v31.4s, v7.4s, v3.s[3]   


    subs x16, x16, #4
    bgt ic_loop

    adds x0, x0, #8
    subs x15, x15, #1
    bgt kernel_loop

    // store outputs

    st1 {v16.4s, v17.4s, v18.4s, v19.4s}, [x2], #64
    add x2, x2, x3

    st1 {v20.4s, v21.4s, v22.4s, v23.4s}, [x2], #64
    add x2, x2, x3

    st1 {v24.4s, v25.4s, v26.4s, v27.4s}, [x2], #64
    add x2, x2, x3

    st1 {v28.4s, v29.4s, v30.4s, v31.4s}, [x2], #64


    ret
