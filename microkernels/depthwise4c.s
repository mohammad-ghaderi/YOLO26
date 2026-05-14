.global depth_wise_c4
.type depth_wise_c4, %function
// compute depth wise conv for 4 channel

depth_wise_c4:
    // x0: input address
    // x1: weight address
    // x2: output address
    // x3: OC = IC
    // x4: SIZE
    
    add     x6, x4, #2
    lsl     x7, x3, #2      // x7: IC*4bytes
    mul     x6, x6, x7      // x6: next input row  -> (SIZE+2)*IC * 4bytes

    ld1     {v16.4s, v17.4s, v18.4s}, [x1], #48     // w1, w2, w3
    ld1     {v19.4s, v20.4s, v21.4s}, [x1], #48     // w4, w5, w6
    ld1     {v22.4s, v23.4s, v24.4s}, [x1], #48     // w7, w8, w9

    mov     x10, x0         // row1
    add     x11, x10, x6    // row2
    add     x12, x11, x6    // row3

    mov x8, x4
.y_loop:

    movi    v25.4s, #0
    movi    v26.4s, #0
    movi    v27.4s, #0

    // first one to start row
    ld1     {v0.4s}, [x10]
    ld1     {v1.4s}, [x11]
    ld1     {v2.4s}, [x12]

    add     x10, x10, x7
    add     x11, x11, x7
    add     x12, x12, x7

    fmla    v25.4s, v0.4s, v16.4s
    fmla    v25.4s, v1.4s, v19.4s
    fmla    v25.4s, v2.4s, v22.4s

    ld1     {v0.4s}, [x10]
    ld1     {v1.4s}, [x11]
    ld1     {v2.4s}, [x12]

    add     x10, x10, x7
    add     x11, x11, x7
    add     x12, x12, x7

    fmla    v26.4s, v0.4s, v16.4s
    fmla    v25.4s, v0.4s, v17.4s
    fmla    v26.4s, v1.4s, v19.4s
    fmla    v25.4s, v1.4s, v20.4s
    fmla    v26.4s, v2.4s, v22.4s
    fmla    v25.4s, v2.4s, v23.4s


    mov x9, x4
.x_loop:

    ld1     {v0.4s}, [x10]
    ld1     {v1.4s}, [x11]
    ld1     {v2.4s}, [x12]

    add     x10, x10, x7
    add     x11, x11, x7
    add     x12, x12, x7

    fmla    v27.4s, v0.4s, v16.4s
    fmla    v26.4s, v0.4s, v17.4s
    fmla    v25.4s, v0.4s, v18.4s
    fmla    v27.4s, v1.4s, v19.4s
    fmla    v26.4s, v1.4s, v20.4s
    fmla    v25.4s, v1.4s, v21.4s
    fmla    v27.4s, v2.4s, v22.4s
    fmla    v26.4s, v2.4s, v23.4s
    fmla    v25.4s, v2.4s, v24.4s

    st1     {v25.4s}, [x2]
    add     x2, x2, x7

    mov     v25.16b, v26.16b
    mov     v26.16b, v27.16b
    movi    v27.4s, #0

    subs x9, x9, #1
    bgt .x_loop

    subs x8, x8, #1
    bgt .y_loop
    ret
