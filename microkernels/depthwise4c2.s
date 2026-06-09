.global depth_wise_c4r2
.type depth_wise_c4r2, %function
// compute depth wise conv for 4 channel 
// in each loop compute 2 row

////// Later optimize -> comput all OC then move the kernel <<< ****************************** <<<<

depth_wise_c4r2:
    // x0: input address
    // x1: weight address
    // x2: output address row 1
    // x3: input stride
    // x4: SIZE
    // x5: output stride
    // x6: bias address
    
    mul     x8, x4, x3      // x8: next input row  -> next row

    mul     x7, x5, x4
    add     x16, x2, x7     // output row 2
    add     x17, x16, x7     // output row 2

    ld1     {V7.4s}, [x6]   // bias

    ld1     {v16.4s, v17.4s, v18.4s}, [x1], #48     // w1, w2, w3
    ld1     {v19.4s, v20.4s, v21.4s}, [x1], #48     // w4, w5, w6
    ld1     {v22.4s, v23.4s, v24.4s}, [x1], #48     // w7, w8, w9

    mov     x10, x0         // row1
    add     x11, x10, x8    // row2
    add     x12, x11, x8    // row3
    add     x13, x12, x8    // row4


    // first rows

    movi    v4.4s, #0  // r1
    movi    v5.4s, #0
    movi    v6.4s, #0
    movi    v25.4s, #0  // r2
    movi    v26.4s, #0
    movi    v27.4s, #0
    movi    v28.4s, #0  // r3
    movi    v29.4s, #0
    movi    v30.4s, #0

    // col 1
    ld1     {v0.4s}, [x10]
    ld1     {v1.4s}, [x11]
    ld1     {v2.4s}, [x12]
    ld1     {v3.4s}, [x13]

    add     x10, x10, x3
    add     x11, x11, x3
    add     x12, x12, x3
    add     x13, x13, x3

    fmla    v4.4s, v0.4s, v20.4s
    fmla    v5.4s, v0.4s, v19.4s
    fmla    v25.4s, v0.4s, v17.4s
    fmla    v26.4s, v0.4s, v16.4s
    fmla    v4.4s, v1.4s, v23.4s
    fmla    v5.4s, v1.4s, v22.4s
    fmla    v25.4s, v1.4s, v20.4s
    fmla    v26.4s, v1.4s, v19.4s
    fmla    v28.4s, v1.4s, v17.4s
    fmla    v29.4s, v1.4s, v16.4s
    fmla    v25.4s, v2.4s, v23.4s
    fmla    v26.4s, v2.4s, v22.4s
    fmla    v28.4s, v2.4s, v20.4s
    fmla    v29.4s, v2.4s, v19.4s
    fmla    v28.4s, v3.4s, v23.4s
    fmla    v29.4s, v3.4s, v22.4s

    mov x15, #19
.fisrt_rows_x_loop:
    // col2
    ld1     {v0.4s}, [x10]
    ld1     {v1.4s}, [x11]
    ld1     {v2.4s}, [x12]
    ld1     {v3.4s}, [x13]

    add     x10, x10, x3
    add     x11, x11, x3
    add     x12, x12, x3
    add     x13, x13, x3

    fmla    v4.4s, v0.4s, v21.4s
    fmla    v5.4s, v0.4s, v20.4s
    fmla    v6.4s, v0.4s, v19.4s
    fmla    v25.4s, v0.4s, v18.4s
    fmla    v26.4s, v0.4s, v17.4s
    fmla    v27.4s, v0.4s, v16.4s
    fmla    v4.4s, v1.4s, v24.4s
    fmla    v5.4s, v1.4s, v23.4s
    fmla    v6.4s, v1.4s, v22.4s
    fmla    v25.4s, v1.4s, v21.4s
    fmla    v26.4s, v1.4s, v20.4s
    fmla    v27.4s, v1.4s, v19.4s
    fmla    v28.4s, v1.4s, v18.4s
    fmla    v29.4s, v1.4s, v17.4s
    fmla    v30.4s, v1.4s, v16.4s
    fmla    v25.4s, v2.4s, v24.4s
    fmla    v26.4s, v2.4s, v23.4s
    fmla    v27.4s, v2.4s, v22.4s
    fmla    v28.4s, v2.4s, v21.4s
    fmla    v29.4s, v2.4s, v20.4s
    fmla    v30.4s, v2.4s, v19.4s
    fmla    v28.4s, v3.4s, v24.4s
    fmla    v29.4s, v3.4s, v23.4s
    fmla    v30.4s, v3.4s, v22.4s

    fadd    v4.4s, v4.4s, v7.4s
    fadd    v25.4s, v25.4s, v7.4s
    fadd    v28.4s, v28.4s, v7.4s

    st1     {v4.4s}, [x2]
    st1     {v25.4s}, [x16]
    st1     {v28.4s}, [x17]
    add     x2, x2, x5
    add     x16, x16, x5
    add     x17, x17, x5


    mov     v4.16b, v5.16b
    mov     v5.16b, v6.16b
    mov     v25.16b, v26.16b
    mov     v26.16b, v27.16b
    mov     v28.16b, v29.16b
    mov     v29.16b, v30.16b
    movi    v6.4s, #0
    movi    v27.4s, #0
    movi    v30.4s, #0

    subs x15, x15, #1
    bgt .fisrt_rows_x_loop

    fadd    v4.4s, v4.4s, v7.4s
    fadd    v25.4s, v25.4s, v7.4s
    fadd    v28.4s, v28.4s, v7.4s

    st1     {v4.4s}, [x2]
    st1     {v25.4s}, [x16]
    st1     {v28.4s}, [x17]
    add     x2, x2, x5
    add     x16, x16, x5
    add     x17, x17, x5

    add     x16, x16, x7
    add     x17, x17, x7

    add     x10, x10, x8
    add     x11, x11, x8
    add     x12, x12, x8
    add     x13, x13, x8

    // middle rows

    mov x14, #14
.y_loop:

    movi    v25.4s, #0  // r1
    movi    v26.4s, #0
    movi    v27.4s, #0
    movi    v28.4s, #0  // r2
    movi    v29.4s, #0
    movi    v30.4s, #0

    // col 1
    ld1     {v0.4s}, [x10]
    ld1     {v1.4s}, [x11]
    ld1     {v2.4s}, [x12]
    ld1     {v3.4s}, [x13]

    add     x10, x10, x3
    add     x11, x11, x3
    add     x12, x12, x3
    add     x13, x13, x3

    fmla    v25.4s, v0.4s, v17.4s
    fmla    v26.4s, v0.4s, v16.4s
    fmla    v25.4s, v1.4s, v20.4s
    fmla    v26.4s, v1.4s, v19.4s
    fmla    v28.4s, v1.4s, v17.4s
    fmla    v29.4s, v1.4s, v16.4s
    fmla    v25.4s, v2.4s, v23.4s
    fmla    v26.4s, v2.4s, v22.4s
    fmla    v28.4s, v2.4s, v20.4s
    fmla    v29.4s, v2.4s, v19.4s
    fmla    v28.4s, v3.4s, v23.4s
    fmla    v29.4s, v3.4s, v22.4s

    mov x15, #19
._x_loop:
    // col2
    ld1     {v0.4s}, [x10]
    ld1     {v1.4s}, [x11]
    ld1     {v2.4s}, [x12]
    ld1     {v3.4s}, [x13]

    add     x10, x10, x3
    add     x11, x11, x3
    add     x12, x12, x3
    add     x13, x13, x3

    fmla    v25.4s, v0.4s, v18.4s
    fmla    v26.4s, v0.4s, v17.4s
    fmla    v27.4s, v0.4s, v16.4s
    fmla    v25.4s, v1.4s, v21.4s
    fmla    v26.4s, v1.4s, v20.4s
    fmla    v27.4s, v1.4s, v19.4s
    fmla    v28.4s, v1.4s, v18.4s
    fmla    v29.4s, v1.4s, v17.4s
    fmla    v30.4s, v1.4s, v16.4s
    fmla    v25.4s, v2.4s, v24.4s
    fmla    v26.4s, v2.4s, v23.4s
    fmla    v27.4s, v2.4s, v22.4s
    fmla    v28.4s, v2.4s, v21.4s
    fmla    v29.4s, v2.4s, v20.4s
    fmla    v30.4s, v2.4s, v19.4s
    fmla    v28.4s, v3.4s, v24.4s
    fmla    v29.4s, v3.4s, v23.4s
    fmla    v30.4s, v3.4s, v22.4s

    fadd    v25.4s, v25.4s, v7.4s
    fadd    v28.4s, v28.4s, v7.4s

    st1     {v25.4s}, [x16]
    st1     {v28.4s}, [x17]
    add     x16, x16, x5
    add     x17, x17, x5

    mov     v25.16b, v26.16b
    mov     v26.16b, v27.16b
    mov     v28.16b, v29.16b
    mov     v29.16b, v30.16b
    movi    v27.4s, #0
    movi    v30.4s, #0

    subs x15, x15, #1
    bgt ._x_loop

    fadd    v25.4s, v25.4s, v7.4s
    fadd    v28.4s, v28.4s, v7.4s

    st1     {v25.4s}, [x16]
    st1     {v28.4s}, [x17]
    add     x16, x16, x5
    add     x17, x17, x5
    add     x16, x16, x7
    add     x17, x17, x7

    add     x10, x10, x8
    add     x11, x11, x8
    add     x12, x12, x8
    add     x13, x13, x8

    subs x14, x14, #2
    bgt .y_loop


    // last rows
    mov     x2, x16
    add     x16, x2, x7
    add     x17, x16, x7


    movi    v4.4s, #0  // r1
    movi    v5.4s, #0
    movi    v6.4s, #0
    movi    v25.4s, #0  // r2
    movi    v26.4s, #0
    movi    v27.4s, #0
    movi    v28.4s, #0  // r3
    movi    v29.4s, #0
    movi    v30.4s, #0

    // col 1
    ld1     {v0.4s}, [x10]
    ld1     {v1.4s}, [x11]
    ld1     {v2.4s}, [x12]
    ld1     {v3.4s}, [x13]

    add     x10, x10, x3
    add     x11, x11, x3
    add     x12, x12, x3
    add     x13, x13, x3

    fmla    v4.4s, v0.4s, v17.4s
    fmla    v5.4s, v0.4s, v16.4s
    fmla    v4.4s, v1.4s, v20.4s
    fmla    v5.4s, v1.4s, v19.4s
    fmla    v25.4s, v1.4s, v17.4s
    fmla    v26.4s, v1.4s, v16.4s
    fmla    v4.4s, v2.4s, v23.4s
    fmla    v5.4s, v2.4s, v22.4s
    fmla    v25.4s, v2.4s, v20.4s
    fmla    v26.4s, v2.4s, v19.4s
    fmla    v28.4s, v2.4s, v17.4s
    fmla    v29.4s, v2.4s, v16.4s
    fmla    v25.4s, v3.4s, v23.4s
    fmla    v26.4s, v3.4s, v22.4s
    fmla    v28.4s, v3.4s, v20.4s
    fmla    v29.4s, v3.4s, v19.4s

    mov x15, #19
.last_rows_x_loop:
    // col2
    ld1     {v0.4s}, [x10]
    ld1     {v1.4s}, [x11]
    ld1     {v2.4s}, [x12]
    ld1     {v3.4s}, [x13]

    add     x10, x10, x3
    add     x11, x11, x3
    add     x12, x12, x3
    add     x13, x13, x3

    fmla    v4.4s, v0.4s, v18.4s
    fmla    v5.4s, v0.4s, v17.4s
    fmla    v6.4s, v0.4s, v16.4s
    fmla    v4.4s, v1.4s, v21.4s
    fmla    v5.4s, v1.4s, v20.4s
    fmla    v6.4s, v1.4s, v19.4s
    fmla    v25.4s, v1.4s, v18.4s
    fmla    v26.4s, v1.4s, v17.4s
    fmla    v27.4s, v1.4s, v16.4s
    fmla    v4.4s, v2.4s, v24.4s
    fmla    v5.4s, v2.4s, v23.4s
    fmla    v6.4s, v2.4s, v22.4s
    fmla    v25.4s, v2.4s, v21.4s
    fmla    v26.4s, v2.4s, v20.4s
    fmla    v27.4s, v2.4s, v19.4s
    fmla    v28.4s, v2.4s, v18.4s
    fmla    v29.4s, v2.4s, v17.4s
    fmla    v30.4s, v2.4s, v16.4s
    fmla    v25.4s, v3.4s, v24.4s
    fmla    v26.4s, v3.4s, v23.4s
    fmla    v27.4s, v3.4s, v22.4s
    fmla    v28.4s, v3.4s, v21.4s
    fmla    v29.4s, v3.4s, v20.4s
    fmla    v30.4s, v3.4s, v19.4s

    fadd    v4.4s, v4.4s, v7.4s
    fadd    v25.4s, v25.4s, v7.4s
    fadd    v28.4s, v28.4s, v7.4s

    st1     {v4.4s}, [x2]
    st1     {v25.4s}, [x16]
    st1     {v28.4s}, [x17]
    add     x2, x2, x5
    add     x16, x16, x5
    add     x17, x17, x5


    mov     v4.16b, v5.16b
    mov     v5.16b, v6.16b
    mov     v25.16b, v26.16b
    mov     v26.16b, v27.16b
    mov     v28.16b, v29.16b
    mov     v29.16b, v30.16b
    movi    v6.4s, #0
    movi    v27.4s, #0
    movi    v30.4s, #0

    subs x15, x15, #1
    bgt .last_rows_x_loop

    fadd    v4.4s, v4.4s, v7.4s
    fadd    v25.4s, v25.4s, v7.4s
    fadd    v28.4s, v28.4s, v7.4s

    st1     {v4.4s}, [x2]
    st1     {v25.4s}, [x16]
    st1     {v28.4s}, [x17]


    ret
