.global depth_wise_c4r2
.type depth_wise_c4r2, %function
// compute depth wise conv for 4 channel 
// in each loop compute 2 row

depth_wise_c4r2:
    // x0: input address
    // x1: weight address
    // x2: output address row 1
    // x3: OC = IC
    // x4: SIZE
    // x5: output stride
    
    add     x8, x4, #2
    lsl     x9, x3, #2      // x9: IC*4bytes
    mul     x8, x8, x9      // x8: next input row  -> (SIZE+2)*IC * 4bytes

    add     x16, x2, x5     // output row 2

    ld1     {v16.4s, v17.4s, v18.4s}, [x1], #48     // w1, w2, w3
    ld1     {v19.4s, v20.4s, v21.4s}, [x1], #48     // w4, w5, w6
    ld1     {v22.4s, v23.4s, v24.4s}, [x1], #48     // w7, w8, w9

    mov     x10, x0         // row1
    add     x11, x10, x8    // row2
    add     x12, x11, x8    // row3
    add     x13, x12, x8    // row4

    mov x14, x4
.y_loop:

    movi    v25.4s, #0
    movi    v26.4s, #0
    movi    v27.4s, #0
    movi    v28.4s, #0
    movi    v29.4s, #0
    movi    v30.4s, #0

    // first one to start row
    ld1     {v0.4s}, [x10]
    ld1     {v1.4s}, [x11]
    ld1     {v2.4s}, [x12]
    ld1     {v3.4s}, [x13]

    add     x10, x10, x9
    add     x11, x11, x9
    add     x12, x12, x9
    add     x13, x13, x9

    fmla    v25.4s, v0.4s, v16.4s
    fmla    v25.4s, v1.4s, v19.4s
    fmla    v25.4s, v2.4s, v22.4s

    fmla    v28.4s, v1.4s, v16.4s
    fmla    v28.4s, v2.4s, v19.4s
    fmla    v28.4s, v3.4s, v22.4s

    ld1     {v0.4s}, [x10]
    ld1     {v1.4s}, [x11]
    ld1     {v2.4s}, [x12]
    ld1     {v3.4s}, [x13]

    add     x10, x10, x9
    add     x11, x11, x9
    add     x12, x12, x9
    add     x13, x13, x9

    fmla    v26.4s, v0.4s, v16.4s
    fmla    v25.4s, v0.4s, v17.4s
    fmla    v26.4s, v1.4s, v19.4s
    fmla    v25.4s, v1.4s, v20.4s
    fmla    v26.4s, v2.4s, v22.4s
    fmla    v25.4s, v2.4s, v23.4s

    fmla    v29.4s, v1.4s, v16.4s
    fmla    v28.4s, v1.4s, v17.4s
    fmla    v29.4s, v2.4s, v19.4s
    fmla    v28.4s, v2.4s, v20.4s
    fmla    v29.4s, v3.4s, v22.4s
    fmla    v28.4s, v3.4s, v23.4s


    mov x15, x4
.x_loop:

    ld1     {v0.4s}, [x10]
    ld1     {v1.4s}, [x11]
    ld1     {v2.4s}, [x12]
    ld1     {v3.4s}, [x13]

    add     x10, x10, x9
    add     x11, x11, x9
    add     x12, x12, x9
    add     x13, x13, x9

    fmla    v27.4s, v0.4s, v16.4s
    fmla    v26.4s, v0.4s, v17.4s
    fmla    v25.4s, v0.4s, v18.4s
    fmla    v27.4s, v1.4s, v19.4s
    fmla    v26.4s, v1.4s, v20.4s
    fmla    v25.4s, v1.4s, v21.4s
    fmla    v27.4s, v2.4s, v22.4s
    fmla    v26.4s, v2.4s, v23.4s
    fmla    v25.4s, v2.4s, v24.4s

    fmla    v30.4s, v1.4s, v16.4s
    fmla    v29.4s, v1.4s, v17.4s
    fmla    v28.4s, v1.4s, v18.4s
    fmla    v30.4s, v2.4s, v19.4s
    fmla    v29.4s, v2.4s, v20.4s
    fmla    v28.4s, v2.4s, v21.4s
    fmla    v30.4s, v3.4s, v22.4s
    fmla    v29.4s, v3.4s, v23.4s
    fmla    v28.4s, v3.4s, v24.4s

    st1     {v25.4s}, [x2]
    st1     {v28.4s}, [x16]
    add     x2, x2, x9
    add     x16, x16, x9

    mov     v25.16b, v26.16b
    mov     v26.16b, v27.16b
    mov     v28.16b, v29.16b
    mov     v29.16b, v30.16b
    movi    v27.4s, #0
    movi    v30.4s, #0

    subs x15, x15, #1
    bgt .x_loop

    add     x10, x10, x8
    add     x11, x11, x8
    add     x12, x12, x8
    add     x13, x13, x8

    add     x2, x2, x5
    add     x16, x16, x5

    subs x14, x14, #2
    bgt .y_loop
    ret
