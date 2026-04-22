.global gemm4x8_v3
.type gemm4x8_v3, %function



gemm4x8_v3:
    // x0: input address
    // x1: weights address
    // x2: output address
    // x3: output stride
    // x4: IC
    // x5: layer stride
    // x6: kernel sride

    movi    v16.4s, #0
    movi    v17.4s, #0

    movi    v18.4s, #0
    movi    v19.4s, #0

    movi    v20.4s, #0
    movi    v21.4s, #0
    
    movi    v22.4s, #0
    movi    v23.4s, #0

    mov     x10, x0             // pixel0
    add     x11, x10, x6        // pixel1 
    add     x12, x11, x6        // pixel2 
    add     x13, x12, x6        // pixel3 

    mov     x14, #3             // ky idx
    mov     x15, #3             // k idx
kernel_loop:

    mov     x16, x4             // ic idx
ic_loop:
    // load inputs
    ld1         {v0.4s,  v1.4s},  [x10], #32
    ld1         {v2.4s,  v3.4s},  [x11], #32
    ld1         {v24.4s, v25.4s}, [x12], #32
    ld1         {v26.4s, v27.4s}, [x13], #32
    

    //                                      input: v0, v1, v2, v3, v24, v25, v26, v27
    // load weights                         weights: v4, v5, v6, v7

    ld1         {v4.4s, v5.4s}, [x1], #32

    fmla        v16.4s, v4.4s, v0.s[0]
    fmla        v17.4s, v5.4s, v0.s[0]
    fmla        v18.4s, v4.4s, v2.s[0]
    fmla        v19.4s, v5.4s, v2.s[0]
    fmla        v20.4s, v4.4s, v24.s[0]
    fmla        v21.4s, v5.4s, v24.s[0]
    fmla        v22.4s, v4.4s, v26.s[0]
    fmla        v23.4s, v5.4s, v26.s[0]

    ld1         {v4.4s, v5.4s}, [x1], #32

    fmla        v16.4s, v4.4s, v0.s[1]
    fmla        v17.4s, v5.4s, v0.s[1]
    fmla        v18.4s, v4.4s, v2.s[1]
    fmla        v19.4s, v5.4s, v2.s[1]
    fmla        v20.4s, v4.4s, v24.s[1]
    fmla        v21.4s, v5.4s, v24.s[1]
    fmla        v22.4s, v4.4s, v26.s[1]
    fmla        v23.4s, v5.4s, v26.s[1]

    ld1         {v4.4s, v5.4s}, [x1], #32

    fmla        v16.4s, v4.4s, v0.s[2]
    fmla        v17.4s, v5.4s, v0.s[2]
    fmla        v18.4s, v4.4s, v2.s[2]
    fmla        v19.4s, v5.4s, v2.s[2]
    fmla        v20.4s, v4.4s, v24.s[2]
    fmla        v21.4s, v5.4s, v24.s[2]
    fmla        v22.4s, v4.4s, v26.s[2]
    fmla        v23.4s, v5.4s, v26.s[2]

    ld1         {v4.4s, v5.4s}, [x1], #32

    fmla        v16.4s, v4.4s, v0.s[3]
    fmla        v17.4s, v5.4s, v0.s[3]
    fmla        v18.4s, v4.4s, v2.s[3]
    fmla        v19.4s, v5.4s, v2.s[3]
    fmla        v20.4s, v4.4s, v24.s[3]
    fmla        v21.4s, v5.4s, v24.s[3]
    fmla        v22.4s, v4.4s, v26.s[3]
    fmla        v23.4s, v5.4s, v26.s[3]

    ld1         {v4.4s, v5.4s}, [x1], #32

    fmla        v16.4s, v4.4s, v1.s[0]
    fmla        v17.4s, v5.4s, v1.s[0]
    fmla        v18.4s, v4.4s, v3.s[0]
    fmla        v19.4s, v5.4s, v3.s[0]
    fmla        v20.4s, v4.4s, v25.s[0]
    fmla        v21.4s, v5.4s, v25.s[0]
    fmla        v22.4s, v4.4s, v27.s[0]
    fmla        v23.4s, v5.4s, v27.s[0]

    ld1         {v4.4s, v5.4s}, [x1], #32

    fmla        v16.4s, v4.4s, v1.s[1]
    fmla        v17.4s, v5.4s, v1.s[1]
    fmla        v18.4s, v4.4s, v3.s[1]
    fmla        v19.4s, v5.4s, v3.s[1]
    fmla        v20.4s, v4.4s, v25.s[1]
    fmla        v21.4s, v5.4s, v25.s[1]
    fmla        v22.4s, v4.4s, v27.s[1]
    fmla        v23.4s, v5.4s, v27.s[1]

    ld1         {v4.4s, v5.4s}, [x1], #32

    fmla        v16.4s, v4.4s, v1.s[2]
    fmla        v17.4s, v5.4s, v1.s[2]
    fmla        v18.4s, v4.4s, v3.s[2]
    fmla        v19.4s, v5.4s, v3.s[2]
    fmla        v20.4s, v4.4s, v25.s[2]
    fmla        v21.4s, v5.4s, v25.s[2]
    fmla        v22.4s, v4.4s, v27.s[2]
    fmla        v23.4s, v5.4s, v27.s[2]

    ld1         {v4.4s, v5.4s}, [x1], #32

    fmla        v16.4s, v4.4s, v1.s[3]
    fmla        v17.4s, v5.4s, v1.s[3]
    fmla        v18.4s, v4.4s, v3.s[3]
    fmla        v19.4s, v5.4s, v3.s[3]
    fmla        v20.4s, v4.4s, v25.s[3]
    fmla        v21.4s, v5.4s, v25.s[3]
    fmla        v22.4s, v4.4s, v27.s[3]
    fmla        v23.4s, v5.4s, v27.s[3]


    subs x16, x16, #8
    bgt ic_loop

    subs x15, x15, #1
    bgt kernel_loop

    adds x10, x10, x5
    adds x11, x11, x5
    adds x12, x12, x5
    adds x13, x13, x5

    mov x15, #3

    subs x14, x14, #1
    bgt kernel_loop
    
    // store outputs

    st1 {v16.4s, v17.4s}, [x2], #32
    add x2, x2, x3

    st1 {v18.4s, v19.4s}, [x2], #32
    add x2, x2, x3

    st1 {v20.4s, v21.4s}, [x2], #32
    add x2, x2, x3

    st1 {v22.4s, v23.4s}, [x2], #32
    add x2, x2, x3


    ret
