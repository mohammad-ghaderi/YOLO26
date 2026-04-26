.global winograd_f23_v1
.type winograd_f23_v1, %function

.extern transformed_input

winograd_f23_v1:
    // x0: input address of a tile
    // x1: transformed weights address
    // x2: output address row 1
    // x3: output stride row 2
    // x4: IC
    // x5: OC
    // x6: input stride

    lsl     x9, x4, #2      // IC*4bytes
    lsl     x8, x5, #2      // OC*4bytes

    ldr     x14, =transformed_input
    mov     x15, x14
    mov     x16, x4         // ic idx 
.ic_loop:
    // tmp for store input @ B
    // v18, v19, v0, v1
    // v22, v23, v2, v3
    // v26, v27, v4, v5
    // v30, v31, v6, v7

    // B.T
    // [[1,  0, -1, 0],
    //  [0,  1,  1, 0],
    //  [0, -1,  1, 0],
    //  [0, -1,  0, 1]]

    // input @ B
    mov     x10, x0
    add     x11, x10, x9
    add     x12, x11, x9
    add     x13, x12, x9

    // row 1
    ld1     {v16.4s}, [x10]
    ld1     {v17.4s}, [x11]
    ld1     {v20.4s}, [x12]
    ld1     {v21.4s}, [x13]

    fsub    v18.4s, v16.4s, v20.4s
    fadd    v19.4s, v17.4s, v20.4s
    fsub    v0.4s, v20.4s, v17.4s
    fsub    v1.4s, v21.4s, v17.4s

    add     x10, x10, x6
    add     x11, x11, x6
    add     x12, x12, x6
    add     x13, x13, x6

    // row 2
    ld1     {v16.4s}, [x10]
    ld1     {v17.4s}, [x11]
    ld1     {v20.4s}, [x12]
    ld1     {v21.4s}, [x13]

    fsub    v22.4s, v16.4s, v20.4s
    fadd    v23.4s, v17.4s, v20.4s
    fsub    v2.4s, v20.4s, v17.4s
    fsub    v3.4s, v21.4s, v17.4s

    add     x10, x10, x6
    add     x11, x11, x6
    add     x12, x12, x6
    add     x13, x13, x6

    // row 3
    ld1     {v16.4s}, [x10]
    ld1     {v17.4s}, [x11]
    ld1     {v20.4s}, [x12]
    ld1     {v21.4s}, [x13]

    fsub    v26.4s, v16.4s, v20.4s
    fadd    v27.4s, v17.4s, v20.4s
    fsub    v4.4s, v20.4s, v17.4s
    fsub    v5.4s, v21.4s, v17.4s

    add     x10, x10, x6
    add     x11, x11, x6
    add     x12, x12, x6
    add     x13, x13, x6

    // row 4
    ld1     {v16.4s}, [x10]
    ld1     {v17.4s}, [x11]
    ld1     {v20.4s}, [x12]
    ld1     {v21.4s}, [x13]

    fsub    v30.4s, v16.4s, v20.4s
    fadd    v31.4s, v17.4s, v20.4s
    fsub    v6.4s, v20.4s, v17.4s
    fsub    v7.4s, v21.4s, v17.4s

    // B.T @ (input @ B)
    // col 1
    fsub    v16.4s, v18.4s, v26.4s
    fadd    v20.4s, v22.4s, v26.4s
    fsub    v24.4s, v26.4s, v22.4s
    fsub    v28.4s, v30.4s, v22.4s
    // col 2
    fsub    v17.4s, v19.4s, v27.4s
    fadd    v21.4s, v23.4s, v27.4s
    fsub    v25.4s, v27.4s, v23.4s
    fsub    v29.4s, v31.4s, v23.4s
    // col 3
    fsub    v18.4s, v0.4s, v4.4s
    fadd    v22.4s, v2.4s, v4.4s
    fsub    v26.4s, v4.4s, v2.4s
    fsub    v30.4s, v6.4s, v2.4s
    // col 4
    fsub    v19.4s, v1.4s, v5.4s
    fadd    v23.4s, v3.4s, v5.4s
    fsub    v27.4s, v5.4s, v3.4s
    fsub    v31.4s, v7.4s, v3.4s

    // V : stores 4x6x6 of transofrmed input for 4 channel 4x6
    // v16, v17, v18, v19
    // v20, v21, v22, v23
    // v24, v25, v26, v27
    // v28, v29, v30, v31

    st1     {v16.4s}, [x15], #16
    st1     {v17.4s}, [x15], #16
    st1     {v18.4s}, [x15], #16
    st1     {v19.4s}, [x15], #16
    st1     {v20.4s}, [x15], #16
    st1     {v21.4s}, [x15], #16
    st1     {v22.4s}, [x15], #16
    st1     {v23.4s}, [x15], #16
    st1     {v24.4s}, [x15], #16
    st1     {v25.4s}, [x15], #16
    st1     {v26.4s}, [x15], #16
    st1     {v27.4s}, [x15], #16
    st1     {v28.4s}, [x15], #16
    st1     {v29.4s}, [x15], #16
    st1     {v30.4s}, [x15], #16
    st1     {v31.4s}, [x15], #16

    add     x0, x0, #16

    subs x16, x16, #4
    bgt .ic_loop

    
    // transformed_weight @ transformed_input
    mov x16, x5
.oc_loop:
    mov     x15, x14        // x14 = address of transformed input
    
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

    mov x17, x4
.ic_loop_dot:
    // row 1
    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x15], #64    // input  (transformed)

    ld1     {v4.4s, v5.4s, v6.4s, v7.4s}, [x1], #64     // weight (transformed)
    fmla    v16.4s, v4.4s, v0.s[0]
    fmla    v17.4s, v5.4s, v1.s[0]
    fmla    v18.4s, v6.4s, v2.s[0]
    fmla    v19.4s, v7.4s, v3.s[0]

    ld1     {v4.4s, v5.4s, v6.4s, v7.4s}, [x1], #64
    fmla    v16.4s, v4.4s, v0.s[1]
    fmla    v17.4s, v5.4s, v1.s[1]
    fmla    v18.4s, v6.4s, v2.s[1]
    fmla    v19.4s, v7.4s, v3.s[1]

    ld1     {v4.4s, v5.4s, v6.4s, v7.4s}, [x1], #64
    fmla    v16.4s, v4.4s, v0.s[2]
    fmla    v17.4s, v5.4s, v1.s[2]
    fmla    v18.4s, v6.4s, v2.s[2]
    fmla    v19.4s, v7.4s, v3.s[2]

    ld1     {v4.4s, v5.4s, v6.4s, v7.4s}, [x1], #64
    fmla    v16.4s, v4.4s, v0.s[3]
    fmla    v17.4s, v5.4s, v1.s[3]
    fmla    v18.4s, v6.4s, v2.s[3]
    fmla    v19.4s, v7.4s, v3.s[3]

    // row 2
    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x15], #64

    ld1     {v4.4s, v5.4s, v6.4s, v7.4s}, [x1], #64
    fmla    v20.4s, v4.4s, v0.s[0]
    fmla    v21.4s, v5.4s, v1.s[0]
    fmla    v22.4s, v6.4s, v2.s[0]
    fmla    v23.4s, v7.4s, v3.s[0]

    ld1     {v4.4s, v5.4s, v6.4s, v7.4s}, [x1], #64
    fmla    v20.4s, v4.4s, v0.s[1]
    fmla    v21.4s, v5.4s, v1.s[1]
    fmla    v22.4s, v6.4s, v2.s[1]
    fmla    v23.4s, v7.4s, v3.s[1]

    ld1     {v4.4s, v5.4s, v6.4s, v7.4s}, [x1], #64
    fmla    v20.4s, v4.4s, v0.s[2]
    fmla    v21.4s, v5.4s, v1.s[2]
    fmla    v22.4s, v6.4s, v2.s[2]
    fmla    v23.4s, v7.4s, v3.s[2]

    ld1     {v4.4s, v5.4s, v6.4s, v7.4s}, [x1], #64
    fmla    v20.4s, v4.4s, v0.s[3]
    fmla    v21.4s, v5.4s, v1.s[3]
    fmla    v22.4s, v6.4s, v2.s[3]
    fmla    v23.4s, v7.4s, v3.s[3]

    // row 3
    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x15], #64

    ld1     {v4.4s, v5.4s, v6.4s, v7.4s}, [x1], #64
    fmla    v24.4s, v4.4s, v0.s[0]
    fmla    v25.4s, v5.4s, v1.s[0]
    fmla    v26.4s, v6.4s, v2.s[0]
    fmla    v27.4s, v7.4s, v3.s[0]

    ld1     {v4.4s, v5.4s, v6.4s, v7.4s}, [x1], #64
    fmla    v24.4s, v4.4s, v0.s[1]
    fmla    v25.4s, v5.4s, v1.s[1]
    fmla    v26.4s, v6.4s, v2.s[1]
    fmla    v27.4s, v7.4s, v3.s[1]

    ld1     {v4.4s, v5.4s, v6.4s, v7.4s}, [x1], #64
    fmla    v24.4s, v4.4s, v0.s[2]
    fmla    v25.4s, v5.4s, v1.s[2]
    fmla    v26.4s, v6.4s, v2.s[2]
    fmla    v27.4s, v7.4s, v3.s[2]

    ld1     {v4.4s, v5.4s, v6.4s, v7.4s}, [x1], #64
    fmla    v24.4s, v4.4s, v0.s[3]
    fmla    v25.4s, v5.4s, v1.s[3]
    fmla    v26.4s, v6.4s, v2.s[3]
    fmla    v27.4s, v7.4s, v3.s[3]

    // row 4
    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x15], #64

    ld1     {v4.4s, v5.4s, v6.4s, v7.4s}, [x1], #64
    fmla    v28.4s, v4.4s, v0.s[0]
    fmla    v29.4s, v5.4s, v1.s[0]
    fmla    v30.4s, v6.4s, v2.s[0]
    fmla    v31.4s, v7.4s, v3.s[0]

    ld1     {v4.4s, v5.4s, v6.4s, v7.4s}, [x1], #64
    fmla    v28.4s, v4.4s, v0.s[1]
    fmla    v29.4s, v5.4s, v1.s[1]
    fmla    v30.4s, v6.4s, v2.s[1]
    fmla    v31.4s, v7.4s, v3.s[1]

    ld1     {v4.4s, v5.4s, v6.4s, v7.4s}, [x1], #64
    fmla    v28.4s, v4.4s, v0.s[2]
    fmla    v29.4s, v5.4s, v1.s[2]
    fmla    v30.4s, v6.4s, v2.s[2]
    fmla    v31.4s, v7.4s, v3.s[2]

    ld1     {v4.4s, v5.4s, v6.4s, v7.4s}, [x1], #64
    fmla    v28.4s, v4.4s, v0.s[3]
    fmla    v29.4s, v5.4s, v1.s[3]
    fmla    v30.4s, v6.4s, v2.s[3]
    fmla    v31.4s, v7.4s, v3.s[3]

    subs x17, x17, #4           // next 4 ic channel
    bgt .ic_loop_dot

    // output before transform
    // v16, v17, v18, v19
    // v20, v21, v22, v23
    // v24, v25, v26, v27
    // v28, v29, v30, v31

    // [1, 1,  1, 0]
    // [0, 1, -1, 1]

    // transforming output
    //      r1+r2
    fadd    v0.4s, v16.4s, v17.4s
    fadd    v2.4s, v20.4s, v21.4s
    fadd    v4.4s, v24.4s, v25.4s
    fadd    v6.4s, v28.4s, v29.4s
    //      (r1+r2)+r3
    fadd    v0.4s, v0.4s, v18.4s
    fadd    v2.4s, v2.4s, v22.4s
    fadd    v4.4s, v4.4s, v26.4s
    fadd    v6.4s, v6.4s, v30.4s
    //      r2-r3
    fsub    v1.4s, v17.4s, v18.4s
    fsub    v3.4s, v21.4s, v22.4s
    fsub    v5.4s, v25.4s, v26.4s
    fsub    v7.4s, v29.4s, v30.4s
    //      (r2-r3)+r4
    fadd    v1.4s, v1.4s, v19.4s
    fadd    v3.4s, v3.4s, v23.4s
    fadd    v5.4s, v5.4s, v27.4s
    fadd    v7.4s, v7.4s, v31.4s

    // final answer
    //      v16, v17
    //      v18, v19
    fadd    v16.4s, v0.4s, v2.4s
    fadd    v18.4s, v1.4s, v3.4s
    fadd    v16.4s, v16.4s, v4.4s
    fadd    v18.4s, v18.4s, v5.4s

    fadd    v17.4s, v2.4s, v6.4s
    fadd    v19.4s, v3.4s, v7.4s
    fsub    v17.4s, v17.4s, v4.4s
    fsub    v19.4s, v19.4s, v5.4s


    // store output
    st1     {v16.4s}, [x2]
    add     x2, x2, x8
    st1     {v18.4s}, [x2], #16
    sub     x2, x2, x8

    st1     {v17.4s}, [x3]
    add     x3, x3, x8
    st1     {v19.4s}, [x3], #16
    sub     x3, x3, x8

    subs x16, x16, #4
    bgt .oc_loop
    ret
