.global igemm4x16_v2
.type igemm4x16_v2, %function
// using v8-v11 and recover with stack, 8 input channel read in loop


igemm4x16_v2:
    // x0: indirction input address
    // x1: weights address
    // x2: output address
    // x3: output stride
    // x4: IC

    sub     sp, sp, #64            // allocate 64 bytes on stack
    stp     q8, q9, [sp, #0]       // store q8 and q9
    stp     q10, q11, [sp, #32]    // store q10 and q11

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

    ld1         {v0.8h}, [x10], 16
    ld1         {v1.8h}, [x11], 16
    ld1         {v2.8h}, [x12], 16
    ld1         {v3.8h}, [x13], 16
    
    // convert float16 -> float32
    fcvtl2      v8.4s,  v0.8h
    fcvtl       v0.4s,  v0.4h
    fcvtl2      v9.4s,  v1.8h
    fcvtl       v1.4s,  v1.4h
    fcvtl2      v10.4s, v2.8h
    fcvtl       v2.4s,  v2.4h
    fcvtl2      v11.4s, v3.8h
    fcvtl       v3.4s,  v3.4h

    //                                      input: v0, v8, v1, v9, v2, v10, v3, v11
    // load weights                         weights: v4, v5, v6, v7

    ld1         {v4.8h, v5.8h}, [x1], 32
    fcvtl       v6.4s, v5.4h
    fcvtl2      v7.4s, v5.8h
    fcvtl2      v5.4s, v4.8h
    fcvtl       v4.4s, v4.4h

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
    
    ld1         {v4.8h, v5.8h}, [x1], 32
    fcvtl       v6.4s, v5.4h
    fcvtl2      v7.4s, v5.8h
    fcvtl2      v5.4s, v4.8h
    fcvtl       v4.4s, v4.4h

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
    
    ld1         {v4.8h, v5.8h}, [x1], 32
    fcvtl       v6.4s, v5.4h
    fcvtl2      v7.4s, v5.8h
    fcvtl2      v5.4s, v4.8h
    fcvtl       v4.4s, v4.4h

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
    
    ld1         {v4.8h, v5.8h}, [x1], 32
    fcvtl       v6.4s, v5.4h
    fcvtl2      v7.4s, v5.8h
    fcvtl2      v5.4s, v4.8h
    fcvtl       v4.4s, v4.4h

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
    
    ld1         {v4.8h, v5.8h}, [x1], 32
    fcvtl       v6.4s, v5.4h
    fcvtl2      v7.4s, v5.8h
    fcvtl2      v5.4s, v4.8h
    fcvtl       v4.4s, v4.4h

    fmla        v16.4s, v4.4s, v8.s[0]
    fmla        v17.4s, v5.4s, v8.s[0]
    fmla        v18.4s, v6.4s, v8.s[0]
    fmla        v19.4s, v7.4s, v8.s[0]
    fmla        v20.4s, v4.4s, v9.s[0]
    fmla        v21.4s, v5.4s, v9.s[0]
    fmla        v22.4s, v6.4s, v9.s[0]
    fmla        v23.4s, v7.4s, v9.s[0]
    fmla        v24.4s, v4.4s, v10.s[0]
    fmla        v25.4s, v5.4s, v10.s[0]
    fmla        v26.4s, v6.4s, v10.s[0]
    fmla        v27.4s, v7.4s, v10.s[0]
    fmla        v28.4s, v4.4s, v11.s[0]
    fmla        v29.4s, v5.4s, v11.s[0]
    fmla        v30.4s, v6.4s, v11.s[0]
    fmla        v31.4s, v7.4s, v11.s[0]
    
    ld1         {v4.8h, v5.8h}, [x1], 32
    fcvtl       v6.4s, v5.4h
    fcvtl2      v7.4s, v5.8h
    fcvtl2      v5.4s, v4.8h
    fcvtl       v4.4s, v4.4h

    fmla        v16.4s, v4.4s, v8.s[1]
    fmla        v17.4s, v5.4s, v8.s[1]
    fmla        v18.4s, v6.4s, v8.s[1]
    fmla        v19.4s, v7.4s, v8.s[1]
    fmla        v20.4s, v4.4s, v9.s[1]
    fmla        v21.4s, v5.4s, v9.s[1]
    fmla        v22.4s, v6.4s, v9.s[1]
    fmla        v23.4s, v7.4s, v9.s[1]
    fmla        v24.4s, v4.4s, v10.s[1]
    fmla        v25.4s, v5.4s, v10.s[1]
    fmla        v26.4s, v6.4s, v10.s[1]
    fmla        v27.4s, v7.4s, v10.s[1]
    fmla        v28.4s, v4.4s, v11.s[1]
    fmla        v29.4s, v5.4s, v11.s[1]
    fmla        v30.4s, v6.4s, v11.s[1]
    fmla        v31.4s, v7.4s, v11.s[1]
    
    ld1         {v4.8h, v5.8h}, [x1], 32
    fcvtl       v6.4s, v5.4h
    fcvtl2      v7.4s, v5.8h
    fcvtl2      v5.4s, v4.8h
    fcvtl       v4.4s, v4.4h

    fmla        v16.4s, v4.4s, v8.s[2]
    fmla        v17.4s, v5.4s, v8.s[2]
    fmla        v18.4s, v6.4s, v8.s[2]
    fmla        v19.4s, v7.4s, v8.s[2]
    fmla        v20.4s, v4.4s, v9.s[2]
    fmla        v21.4s, v5.4s, v9.s[2]
    fmla        v22.4s, v6.4s, v9.s[2]
    fmla        v23.4s, v7.4s, v9.s[2]
    fmla        v24.4s, v4.4s, v10.s[2]
    fmla        v25.4s, v5.4s, v10.s[2]
    fmla        v26.4s, v6.4s, v10.s[2]
    fmla        v27.4s, v7.4s, v10.s[2]
    fmla        v28.4s, v4.4s, v11.s[2]
    fmla        v29.4s, v5.4s, v11.s[2]
    fmla        v30.4s, v6.4s, v11.s[2]
    fmla        v31.4s, v7.4s, v11.s[2]  
    
    ld1         {v4.8h, v5.8h}, [x1], 32
    fcvtl       v6.4s, v5.4h
    fcvtl2      v7.4s, v5.8h
    fcvtl2      v5.4s, v4.8h
    fcvtl       v4.4s, v4.4h

    fmla        v16.4s, v4.4s, v8.s[3]
    fmla        v17.4s, v5.4s, v8.s[3]
    fmla        v18.4s, v6.4s, v8.s[3]
    fmla        v19.4s, v7.4s, v8.s[3]
    fmla        v20.4s, v4.4s, v9.s[3]
    fmla        v21.4s, v5.4s, v9.s[3]
    fmla        v22.4s, v6.4s, v9.s[3]
    fmla        v23.4s, v7.4s, v9.s[3]
    fmla        v24.4s, v4.4s, v10.s[3]
    fmla        v25.4s, v5.4s, v10.s[3]
    fmla        v26.4s, v6.4s, v10.s[3]
    fmla        v27.4s, v7.4s, v10.s[3]
    fmla        v28.4s, v4.4s, v11.s[3]
    fmla        v29.4s, v5.4s, v11.s[3]
    fmla        v30.4s, v6.4s, v11.s[3]
    fmla        v31.4s, v7.4s, v11.s[3]  


    subs x16, x16, #8
    bgt ic_loop

    adds x0, x0, #8
    subs x15, x15, #1
    bgt kernel_loop

    // store outputs

    st1 {v16.4s}, [x2], #16
    st1 {v17.4s}, [x2], #16
    st1 {v18.4s}, [x2], #16
    st1 {v19.4s}, [x2], #16

    add x2, x2, x3

    st1 {v20.4s}, [x2], #16
    st1 {v21.4s}, [x2], #16
    st1 {v22.4s}, [x2], #16
    st1 {v23.4s}, [x2], #16

    add x2, x2, x3

    st1 {v24.4s}, [x2], #16
    st1 {v25.4s}, [x2], #16
    st1 {v26.4s}, [x2], #16
    st1 {v27.4s}, [x2], #16

    add x2, x2, x3

    st1 {v28.4s}, [x2], #16
    st1 {v29.4s}, [x2], #16
    st1 {v30.4s}, [x2], #16
    st1 {v31.4s}, [x2], #16


    ldp     q10, q11, [sp, #32]    // restore q10 and q11
    ldp     q8, q9,  [sp, #0]      // restore q8 and q9
    add     sp, sp, #64            // deallocate stack space
    
    ret
