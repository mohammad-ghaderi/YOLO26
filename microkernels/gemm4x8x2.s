.global gemm4x8x2_v6
.type gemm4x8x2_v6, %function
// no stack, 4 input channel read in loop


gemm4x8x2_v6:
    // x0: input address
    // x1: weights address
    // x2: output address
    // x3: output stride
    // x4: IC
    // x5: layer stride
    // x6: next ouput row 

    sub sp, sp, #160

    stp q8,  q9,  [sp, #0]
    stp q10, q11, [sp, #32]
    stp q12, q13, [sp, #64]
    stp x18, x19, [sp, #96]
    stp x20, x21, [sp, #112]
    stp x22, x23, [sp, #128]
    str x24, [sp, #144]

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

    lsl     x23, x4, #2

    mov     x7,  x0              // input pixel1 in a rows
    add     x8,  x7,  x23        // input pixel2 in a rows
    add     x9,  x8,  x23        // input pixel3 in a rows
    add     x10, x9,  x23        // input pixel4 in a rows
    add     x11, x10, x23        // input pixel5 in a rows
    add     x12, x11, x23        // input pixel6 in a rows

    mov     x13, #3
    mul     x13, x13, x5
    sub     x13, x13, #16       // 3row - 16

    lsl     x23, x23, #3


    mov     x14, x1         // w1
    add     x15, x14, x23   // w2
    add     x16, x15, x23   // w3
    add     x17, x16, x23   // w4
    add     x18, x17, x23   // w5
    add     x19, x18, x23   // w6
    add     x20, x19, x23   // w7
    add     x21, x20, x23   // w8
    add     x22, x21, x23   // w9


    mov     x24, x4             // ic idx
ic_loop:
    // load inputs
    ld1     {v2.4s},  [x7]              // 1,1   r,c
    ld1     {v3.4s},  [x8]              // 1,2
    ld1     {v4.4s},  [x9]              // 1,3
    ld1     {v5.4s},  [x10]             // 1,4
    ld1     {v6.4s},  [x11]             // 1,5
    ld1     {v7.4s},  [x12]             // 1,6

    add     x7, x7, x5
    add     x8, x8, x5
    add     x9, x9, x5
    add     x10, x10, x5
    add     x11, x11, x5
    add     x12, x12, x5

    ld1     {v8.4s},  [x7]              // 2,1
    ld1     {v9.4s},  [x8]              // 2,2
    ld1     {v10.4s}, [x9]              // 2,3
    ld1     {v11.4s}, [x10]             // 2,4
    ld1     {v12.4s}, [x11]             // 2,5
    ld1     {v13.4s}, [x12]             // 2,6

    ld1     {v0.4s, v1.4s}, [x14], #32  // w1 [0]

    fmla    v16.4s, v0.4s, v2.s[0]      // out-(1,1)l: w1*inp(1,1)
    fmla    v17.4s, v1.4s, v2.s[0]      // out-(1,1)h: w1*inp(1,1)
    fmla    v19.4s, v1.4s, v3.s[0]      // out-(1,2)h: w1*inp(1,2)
    fmla    v18.4s, v0.4s, v3.s[0]      // out-(1,2)l: w1*inp(1,2)
    fmla    v20.4s, v0.4s, v4.s[0]      // out-(1,3)l: w1*inp(1,3)
    fmla    v21.4s, v1.4s, v4.s[0]      // out-(1,3)h: w1*inp(1,3)
    fmla    v23.4s, v1.4s, v5.s[0]      // out-(1,4)h: w1*inp(1,4)
    fmla    v22.4s, v0.4s, v5.s[0]      // out-(1,4)l: w1*inp(1,4)
    fmla    v24.4s, v0.4s, v8.s[0]      // out-(2,1)l: w1*inp(2,1)
    fmla    v25.4s, v1.4s, v8.s[0]      // out-(2,1)h: w1*inp(2,1)
    fmla    v27.4s, v1.4s, v9.s[0]      // out-(2,2)h: w1*inp(2,2)
    fmla    v26.4s, v0.4s, v9.s[0]      // out-(2,2)l: w1*inp(2,2)
    fmla    v28.4s, v0.4s, v10.s[0]     // out-(2,3)l: w1*inp(2,3)
    fmla    v29.4s, v1.4s, v10.s[0]     // out-(2,3)h: w1*inp(2,3)
    fmla    v31.4s, v1.4s, v11.s[0]     // out-(2,4)h: w1*inp(2,4)
    fmla    v30.4s, v0.4s, v11.s[0]     // out-(2,4)l: w1*inp(2,4)

    ld1     {v0.4s, v1.4s}, [x14], #32  // w1 [1]

    fmla    v16.4s, v0.4s, v2.s[1]      // out-(1,1)l: w1*inp(1,1)
    fmla    v17.4s, v1.4s, v2.s[1]      // out-(1,1)h: w1*inp(1,1)
    fmla    v19.4s, v1.4s, v3.s[1]      // out-(1,2)h: w1*inp(1,2)
    fmla    v18.4s, v0.4s, v3.s[1]      // out-(1,2)l: w1*inp(1,2)
    fmla    v20.4s, v0.4s, v4.s[1]      // out-(1,3)l: w1*inp(1,3)
    fmla    v21.4s, v1.4s, v4.s[1]      // out-(1,3)h: w1*inp(1,3)
    fmla    v23.4s, v1.4s, v5.s[1]      // out-(1,4)h: w1*inp(1,4)
    fmla    v22.4s, v0.4s, v5.s[1]      // out-(1,4)l: w1*inp(1,4)
    fmla    v24.4s, v0.4s, v8.s[1]      // out-(2,1)l: w1*inp(2,1)
    fmla    v25.4s, v1.4s, v8.s[1]      // out-(2,1)h: w1*inp(2,1)
    fmla    v27.4s, v1.4s, v9.s[1]      // out-(2,2)h: w1*inp(2,2)
    fmla    v26.4s, v0.4s, v9.s[1]      // out-(2,2)l: w1*inp(2,2)
    fmla    v28.4s, v0.4s, v10.s[1]     // out-(2,3)l: w1*inp(2,3)
    fmla    v29.4s, v1.4s, v10.s[1]     // out-(2,3)h: w1*inp(2,3)
    fmla    v31.4s, v1.4s, v11.s[1]     // out-(2,4)h: w1*inp(2,4)
    fmla    v30.4s, v0.4s, v11.s[1]     // out-(2,4)l: w1*inp(2,4)

    ld1     {v0.4s, v1.4s}, [x14], #32  // w1 [2]

    fmla    v16.4s, v0.4s, v2.s[2]      // out-(1,1)l: w1*inp(1,1)
    fmla    v17.4s, v1.4s, v2.s[2]      // out-(1,1)h: w1*inp(1,1)
    fmla    v19.4s, v1.4s, v3.s[2]      // out-(1,2)h: w1*inp(1,2)
    fmla    v18.4s, v0.4s, v3.s[2]      // out-(1,2)l: w1*inp(1,2)
    fmla    v20.4s, v0.4s, v4.s[2]      // out-(1,3)l: w1*inp(1,3)
    fmla    v21.4s, v1.4s, v4.s[2]      // out-(1,3)h: w1*inp(1,3)
    fmla    v23.4s, v1.4s, v5.s[2]      // out-(1,4)h: w1*inp(1,4)
    fmla    v22.4s, v0.4s, v5.s[2]      // out-(1,4)l: w1*inp(1,4)
    fmla    v24.4s, v0.4s, v8.s[2]      // out-(2,1)l: w1*inp(2,1)
    fmla    v25.4s, v1.4s, v8.s[2]      // out-(2,1)h: w1*inp(2,1)
    fmla    v27.4s, v1.4s, v9.s[2]      // out-(2,2)h: w1*inp(2,2)
    fmla    v26.4s, v0.4s, v9.s[2]      // out-(2,2)l: w1*inp(2,2)
    fmla    v28.4s, v0.4s, v10.s[2]     // out-(2,3)l: w1*inp(2,3)
    fmla    v29.4s, v1.4s, v10.s[2]     // out-(2,3)h: w1*inp(2,3)
    fmla    v31.4s, v1.4s, v11.s[2]     // out-(2,4)h: w1*inp(2,4)
    fmla    v30.4s, v0.4s, v11.s[2]     // out-(2,4)l: w1*inp(2,4)

    ld1     {v0.4s, v1.4s}, [x14], #32  // w1 [3]

    fmla    v16.4s, v0.4s, v2.s[3]      // out-(1,1)l: w1*inp(1,1)
    fmla    v17.4s, v1.4s, v2.s[3]      // out-(1,1)h: w1*inp(1,1)
    fmla    v19.4s, v1.4s, v3.s[3]      // out-(1,2)h: w1*inp(1,2)
    fmla    v18.4s, v0.4s, v3.s[3]      // out-(1,2)l: w1*inp(1,2)
    fmla    v20.4s, v0.4s, v4.s[3]      // out-(1,3)l: w1*inp(1,3)
    fmla    v21.4s, v1.4s, v4.s[3]      // out-(1,3)h: w1*inp(1,3)
    fmla    v23.4s, v1.4s, v5.s[3]      // out-(1,4)h: w1*inp(1,4)
    fmla    v22.4s, v0.4s, v5.s[3]      // out-(1,4)l: w1*inp(1,4)
    fmla    v24.4s, v0.4s, v8.s[3]      // out-(2,1)l: w1*inp(2,1)
    fmla    v25.4s, v1.4s, v8.s[3]      // out-(2,1)h: w1*inp(2,1)
    fmla    v27.4s, v1.4s, v9.s[3]      // out-(2,2)h: w1*inp(2,2)
    fmla    v26.4s, v0.4s, v9.s[3]      // out-(2,2)l: w1*inp(2,2)
    fmla    v28.4s, v0.4s, v10.s[3]     // out-(2,3)l: w1*inp(2,3)
    fmla    v29.4s, v1.4s, v10.s[3]     // out-(2,3)h: w1*inp(2,3)
    fmla    v31.4s, v1.4s, v11.s[3]     // out-(2,4)h: w1*inp(2,4)
    fmla    v30.4s, v0.4s, v11.s[3]     // out-(2,4)l: w1*inp(2,4)


    ld1     {v0.4s, v1.4s}, [x15], #32  // w2 [0]

    fmla    v16.4s, v0.4s, v3.s[0]      // out-(1,1)l: w2*inp(1,2)
    fmla    v17.4s, v1.4s, v3.s[0]      // out-(1,1)h: w2*inp(1,2)
    fmla    v19.4s, v1.4s, v4.s[0]      // out-(1,2)h: w2*inp(1,3)
    fmla    v18.4s, v0.4s, v4.s[0]      // out-(1,2)l: w2*inp(1,3)
    fmla    v20.4s, v0.4s, v5.s[0]      // out-(1,3)l: w2*inp(1,4)
    fmla    v21.4s, v1.4s, v5.s[0]      // out-(1,3)h: w2*inp(1,4)
    fmla    v23.4s, v1.4s, v6.s[0]      // out-(1,4)h: w2*inp(1,5)
    fmla    v22.4s, v0.4s, v6.s[0]      // out-(1,4)l: w2*inp(1,5)
    fmla    v24.4s, v0.4s, v9.s[0]      // out-(2,1)l: w2*inp(2,2)
    fmla    v25.4s, v1.4s, v9.s[0]      // out-(2,1)h: w2*inp(2,2)
    fmla    v27.4s, v1.4s, v10.s[0]     // out-(2,2)h: w2*inp(2,3)
    fmla    v26.4s, v0.4s, v10.s[0]     // out-(2,2)l: w2*inp(2,3)
    fmla    v28.4s, v0.4s, v11.s[0]     // out-(2,3)l: w2*inp(2,4)
    fmla    v29.4s, v1.4s, v11.s[0]     // out-(2,3)h: w2*inp(2,4)
    fmla    v31.4s, v1.4s, v12.s[0]     // out-(2,4)h: w2*inp(2,5)
    fmla    v30.4s, v0.4s, v12.s[0]     // out-(2,4)l: w2*inp(2,5)

    ld1     {v0.4s, v1.4s}, [x15], #32  // w2 [1]

    fmla    v16.4s, v0.4s, v3.s[1]      // out-(1,1)l: w2*inp(1,2)
    fmla    v17.4s, v1.4s, v3.s[1]      // out-(1,1)h: w2*inp(1,2)
    fmla    v19.4s, v1.4s, v4.s[1]      // out-(1,2)h: w2*inp(1,3)
    fmla    v18.4s, v0.4s, v4.s[1]      // out-(1,2)l: w2*inp(1,3)
    fmla    v20.4s, v0.4s, v5.s[1]      // out-(1,3)l: w2*inp(1,4)
    fmla    v21.4s, v1.4s, v5.s[1]      // out-(1,3)h: w2*inp(1,4)
    fmla    v23.4s, v1.4s, v6.s[1]      // out-(1,4)h: w2*inp(1,5)
    fmla    v22.4s, v0.4s, v6.s[1]      // out-(1,4)l: w2*inp(1,5)
    fmla    v24.4s, v0.4s, v9.s[1]      // out-(2,1)l: w2*inp(2,2)
    fmla    v25.4s, v1.4s, v9.s[1]      // out-(2,1)h: w2*inp(2,2)
    fmla    v27.4s, v1.4s, v10.s[1]     // out-(2,2)h: w2*inp(2,3)
    fmla    v26.4s, v0.4s, v10.s[1]     // out-(2,2)l: w2*inp(2,3)
    fmla    v28.4s, v0.4s, v11.s[1]     // out-(2,3)l: w2*inp(2,4)
    fmla    v29.4s, v1.4s, v11.s[1]     // out-(2,3)h: w2*inp(2,4)
    fmla    v31.4s, v1.4s, v12.s[1]     // out-(2,4)h: w2*inp(2,5)
    fmla    v30.4s, v0.4s, v12.s[1]     // out-(2,4)l: w2*inp(2,5)

    ld1     {v0.4s, v1.4s}, [x15], #32  // w2 [2]

    fmla    v16.4s, v0.4s, v3.s[2]      // out-(1,1)l: w2*inp(1,2)
    fmla    v17.4s, v1.4s, v3.s[2]      // out-(1,1)h: w2*inp(1,2)
    fmla    v19.4s, v1.4s, v4.s[2]      // out-(1,2)h: w2*inp(1,3)
    fmla    v18.4s, v0.4s, v4.s[2]      // out-(1,2)l: w2*inp(1,3)
    fmla    v20.4s, v0.4s, v5.s[2]      // out-(1,3)l: w2*inp(1,4)
    fmla    v21.4s, v1.4s, v5.s[2]      // out-(1,3)h: w2*inp(1,4)
    fmla    v23.4s, v1.4s, v6.s[2]      // out-(1,4)h: w2*inp(1,5)
    fmla    v22.4s, v0.4s, v6.s[2]      // out-(1,4)l: w2*inp(1,5)
    fmla    v24.4s, v0.4s, v9.s[2]      // out-(2,1)l: w2*inp(2,2)
    fmla    v25.4s, v1.4s, v9.s[2]      // out-(2,1)h: w2*inp(2,2)
    fmla    v27.4s, v1.4s, v10.s[2]     // out-(2,2)h: w2*inp(2,3)
    fmla    v26.4s, v0.4s, v10.s[2]     // out-(2,2)l: w2*inp(2,3)
    fmla    v28.4s, v0.4s, v11.s[2]     // out-(2,3)l: w2*inp(2,4)
    fmla    v29.4s, v1.4s, v11.s[2]     // out-(2,3)h: w2*inp(2,4)
    fmla    v31.4s, v1.4s, v12.s[2]     // out-(2,4)h: w2*inp(2,5)
    fmla    v30.4s, v0.4s, v12.s[2]     // out-(2,4)l: w2*inp(2,5)

    ld1     {v0.4s, v1.4s}, [x15], #32  // w2 [3]

    fmla    v16.4s, v0.4s, v3.s[3]      // out-(1,1)l: w2*inp(1,2)
    fmla    v17.4s, v1.4s, v3.s[3]      // out-(1,1)h: w2*inp(1,2)
    fmla    v19.4s, v1.4s, v4.s[3]      // out-(1,2)h: w2*inp(1,3)
    fmla    v18.4s, v0.4s, v4.s[3]      // out-(1,2)l: w2*inp(1,3)
    fmla    v20.4s, v0.4s, v5.s[3]      // out-(1,3)l: w2*inp(1,4)
    fmla    v21.4s, v1.4s, v5.s[3]      // out-(1,3)h: w2*inp(1,4)
    fmla    v23.4s, v1.4s, v6.s[3]      // out-(1,4)h: w2*inp(1,5)
    fmla    v22.4s, v0.4s, v6.s[3]      // out-(1,4)l: w2*inp(1,5)
    fmla    v24.4s, v0.4s, v9.s[3]      // out-(2,1)l: w2*inp(2,2)
    fmla    v25.4s, v1.4s, v9.s[3]      // out-(2,1)h: w2*inp(2,2)
    fmla    v27.4s, v1.4s, v10.s[3]     // out-(2,2)h: w2*inp(2,3)
    fmla    v26.4s, v0.4s, v10.s[3]     // out-(2,2)l: w2*inp(2,3)
    fmla    v28.4s, v0.4s, v11.s[3]     // out-(2,3)l: w2*inp(2,4)
    fmla    v29.4s, v1.4s, v11.s[3]     // out-(2,3)h: w2*inp(2,4)
    fmla    v31.4s, v1.4s, v12.s[3]     // out-(2,4)h: w2*inp(2,5)
    fmla    v30.4s, v0.4s, v12.s[3]     // out-(2,4)l: w2*inp(2,5)


    ld1     {v0.4s, v1.4s}, [x16], #32  // w3 [0]

    fmla    v16.4s, v0.4s, v4.s[0]      // out-(1,1)l: w3*inp(1,3)
    fmla    v17.4s, v1.4s, v4.s[0]      // out-(1,1)h: w3*inp(1,3)
    fmla    v19.4s, v1.4s, v5.s[0]      // out-(1,2)h: w3*inp(1,4)
    fmla    v18.4s, v0.4s, v5.s[0]      // out-(1,2)l: w3*inp(1,4)
    fmla    v20.4s, v0.4s, v6.s[0]      // out-(1,3)l: w3*inp(1,5)
    fmla    v21.4s, v1.4s, v6.s[0]      // out-(1,3)h: w3*inp(1,5)
    fmla    v23.4s, v1.4s, v7.s[0]      // out-(1,4)h: w3*inp(1,6)
    fmla    v22.4s, v0.4s, v7.s[0]      // out-(1,4)l: w3*inp(1,6)
    fmla    v24.4s, v0.4s, v10.s[0]     // out-(2,1)l: w3*inp(2,3)
    fmla    v25.4s, v1.4s, v10.s[0]     // out-(2,1)h: w3*inp(2,3)
    fmla    v27.4s, v1.4s, v11.s[0]     // out-(2,2)h: w3*inp(2,4)
    fmla    v26.4s, v0.4s, v11.s[0]     // out-(2,2)l: w3*inp(2,4)
    fmla    v28.4s, v0.4s, v12.s[0]     // out-(2,3)l: w3*inp(2,5)
    fmla    v29.4s, v1.4s, v12.s[0]     // out-(2,3)h: w3*inp(2,5)
    fmla    v31.4s, v1.4s, v13.s[0]     // out-(2,4)h: w3*inp(2,6)
    fmla    v30.4s, v0.4s, v13.s[0]     // out-(2,4)l: w3*inp(2,6)

    ld1     {v0.4s, v1.4s}, [x16], #32  // w3 [1]

    fmla    v16.4s, v0.4s, v4.s[1]      // out-(1,1)l: w3*inp(1,3)
    fmla    v17.4s, v1.4s, v4.s[1]      // out-(1,1)h: w3*inp(1,3)
    fmla    v19.4s, v1.4s, v5.s[1]      // out-(1,2)h: w3*inp(1,4)
    fmla    v18.4s, v0.4s, v5.s[1]      // out-(1,2)l: w3*inp(1,4)
    fmla    v20.4s, v0.4s, v6.s[1]      // out-(1,3)l: w3*inp(1,5)
    fmla    v21.4s, v1.4s, v6.s[1]      // out-(1,3)h: w3*inp(1,5)
    fmla    v23.4s, v1.4s, v7.s[1]      // out-(1,4)h: w3*inp(1,6)
    fmla    v22.4s, v0.4s, v7.s[1]      // out-(1,4)l: w3*inp(1,6)
    fmla    v24.4s, v0.4s, v10.s[1]     // out-(2,1)l: w3*inp(2,3)
    fmla    v25.4s, v1.4s, v10.s[1]     // out-(2,1)h: w3*inp(2,3)
    fmla    v27.4s, v1.4s, v11.s[1]     // out-(2,2)h: w3*inp(2,4)
    fmla    v26.4s, v0.4s, v11.s[1]     // out-(2,2)l: w3*inp(2,4)
    fmla    v28.4s, v0.4s, v12.s[1]     // out-(2,3)l: w3*inp(2,5)
    fmla    v29.4s, v1.4s, v12.s[1]     // out-(2,3)h: w3*inp(2,5)
    fmla    v31.4s, v1.4s, v13.s[1]     // out-(2,4)h: w3*inp(2,6)
    fmla    v30.4s, v0.4s, v13.s[1]     // out-(2,4)l: w3*inp(2,6)

    ld1     {v0.4s, v1.4s}, [x16], #32  // w3 [2]

    fmla    v16.4s, v0.4s, v4.s[2]      // out-(1,1)l: w3*inp(1,3)
    fmla    v17.4s, v1.4s, v4.s[2]      // out-(1,1)h: w3*inp(1,3)
    fmla    v19.4s, v1.4s, v5.s[2]      // out-(1,2)h: w3*inp(1,4)
    fmla    v18.4s, v0.4s, v5.s[2]      // out-(1,2)l: w3*inp(1,4)
    fmla    v20.4s, v0.4s, v6.s[2]      // out-(1,3)l: w3*inp(1,5)
    fmla    v21.4s, v1.4s, v6.s[2]      // out-(1,3)h: w3*inp(1,5)
    fmla    v23.4s, v1.4s, v7.s[2]      // out-(1,4)h: w3*inp(1,6)
    fmla    v22.4s, v0.4s, v7.s[2]      // out-(1,4)l: w3*inp(1,6)
    fmla    v24.4s, v0.4s, v10.s[2]     // out-(2,1)l: w3*inp(2,3)
    fmla    v25.4s, v1.4s, v10.s[2]     // out-(2,1)h: w3*inp(2,3)
    fmla    v27.4s, v1.4s, v11.s[2]     // out-(2,2)h: w3*inp(2,4)
    fmla    v26.4s, v0.4s, v11.s[2]     // out-(2,2)l: w3*inp(2,4)
    fmla    v28.4s, v0.4s, v12.s[2]     // out-(2,3)l: w3*inp(2,5)
    fmla    v29.4s, v1.4s, v12.s[2]     // out-(2,3)h: w3*inp(2,5)
    fmla    v31.4s, v1.4s, v13.s[2]     // out-(2,4)h: w3*inp(2,6)
    fmla    v30.4s, v0.4s, v13.s[2]     // out-(2,4)l: w3*inp(2,6)

    ld1     {v0.4s, v1.4s}, [x16], #32  // w3 [3]

    fmla    v16.4s, v0.4s, v4.s[3]      // out-(1,1)l: w3*inp(1,3)
    fmla    v17.4s, v1.4s, v4.s[3]      // out-(1,1)h: w3*inp(1,3)
    fmla    v19.4s, v1.4s, v5.s[3]      // out-(1,2)h: w3*inp(1,4)
    fmla    v18.4s, v0.4s, v5.s[3]      // out-(1,2)l: w3*inp(1,4)
    fmla    v20.4s, v0.4s, v6.s[3]      // out-(1,3)l: w3*inp(1,5)
    fmla    v21.4s, v1.4s, v6.s[3]      // out-(1,3)h: w3*inp(1,5)
    fmla    v23.4s, v1.4s, v7.s[3]      // out-(1,4)h: w3*inp(1,6)
    fmla    v22.4s, v0.4s, v7.s[3]      // out-(1,4)l: w3*inp(1,6)
    fmla    v24.4s, v0.4s, v10.s[3]     // out-(2,1)l: w3*inp(2,3)
    fmla    v25.4s, v1.4s, v10.s[3]     // out-(2,1)h: w3*inp(2,3)
    fmla    v27.4s, v1.4s, v11.s[3]     // out-(2,2)h: w3*inp(2,4)
    fmla    v26.4s, v0.4s, v11.s[3]     // out-(2,2)l: w3*inp(2,4)
    fmla    v28.4s, v0.4s, v12.s[3]     // out-(2,3)l: w3*inp(2,5)
    fmla    v29.4s, v1.4s, v12.s[3]     // out-(2,3)h: w3*inp(2,5)
    fmla    v31.4s, v1.4s, v13.s[3]     // out-(2,4)h: w3*inp(2,6)
    fmla    v30.4s, v0.4s, v13.s[3]     // out-(2,4)l: w3*inp(2,6)


    add     x7, x7, x5
    add     x8, x8, x5
    add     x9, x9, x5
    add     x10, x10, x5
    add     x11, x11, x5
    add     x12, x12, x5

    // replace input row 3 with row 1
    ld1     {v2.4s},  [x7]          // 3,1   r,c
    ld1     {v3.4s},  [x8]          // 3,2
    ld1     {v4.4s},  [x9]          // 3,3
    ld1     {v5.4s},  [x10]         // 3,4
    ld1     {v6.4s},  [x11]         // 3,5
    ld1     {v7.4s},  [x12]         // 3,6

    ld1     {v0.4s, v1.4s}, [x17], #32  // w4 [0]

    fmla    v16.4s, v0.4s, v8.s[0]      // out-(1,1)l: w4*inp(2,1)
    fmla    v17.4s, v1.4s, v8.s[0]      // out-(1,1)h: w4*inp(2,1)
    fmla    v19.4s, v1.4s, v9.s[0]      // out-(1,2)h: w4*inp(2,2)
    fmla    v18.4s, v0.4s, v9.s[0]      // out-(1,2)l: w4*inp(2,2)
    fmla    v20.4s, v0.4s, v10.s[0]     // out-(1,3)l: w4*inp(2,3)
    fmla    v21.4s, v1.4s, v10.s[0]     // out-(1,3)h: w4*inp(2,3)
    fmla    v23.4s, v1.4s, v11.s[0]     // out-(1,4)h: w4*inp(2,4)
    fmla    v22.4s, v0.4s, v11.s[0]     // out-(1,4)l: w4*inp(2,4)
    fmla    v24.4s, v0.4s, v2.s[0]      // out-(2,1)l: w4*inp(3,1)
    fmla    v25.4s, v1.4s, v2.s[0]      // out-(2,1)h: w4*inp(3,1)
    fmla    v27.4s, v1.4s, v3.s[0]      // out-(2,2)h: w4*inp(3,2)
    fmla    v26.4s, v0.4s, v3.s[0]      // out-(2,2)l: w4*inp(3,2)
    fmla    v28.4s, v0.4s, v4.s[0]      // out-(2,3)l: w4*inp(3,3)
    fmla    v29.4s, v1.4s, v4.s[0]      // out-(2,3)h: w4*inp(3,3)
    fmla    v31.4s, v1.4s, v5.s[0]      // out-(2,4)h: w4*inp(3,4)
    fmla    v30.4s, v0.4s, v5.s[0]      // out-(2,4)l: w4*inp(3,4)

    ld1     {v0.4s, v1.4s}, [x17], #32  // w4 [1]

    fmla    v16.4s, v0.4s, v8.s[1]      // out-(1,1)l: w4*inp(2,1)
    fmla    v17.4s, v1.4s, v8.s[1]      // out-(1,1)h: w4*inp(2,1)
    fmla    v19.4s, v1.4s, v9.s[1]      // out-(1,2)h: w4*inp(2,2)
    fmla    v18.4s, v0.4s, v9.s[1]      // out-(1,2)l: w4*inp(2,2)
    fmla    v20.4s, v0.4s, v10.s[1]     // out-(1,3)l: w4*inp(2,3)
    fmla    v21.4s, v1.4s, v10.s[1]     // out-(1,3)h: w4*inp(2,3)
    fmla    v23.4s, v1.4s, v11.s[1]     // out-(1,4)h: w4*inp(2,4)
    fmla    v22.4s, v0.4s, v11.s[1]     // out-(1,4)l: w4*inp(2,4)
    fmla    v24.4s, v0.4s, v2.s[1]      // out-(2,1)l: w4*inp(3,1)
    fmla    v25.4s, v1.4s, v2.s[1]      // out-(2,1)h: w4*inp(3,1)
    fmla    v27.4s, v1.4s, v3.s[1]      // out-(2,2)h: w4*inp(3,2)
    fmla    v26.4s, v0.4s, v3.s[1]      // out-(2,2)l: w4*inp(3,2)
    fmla    v28.4s, v0.4s, v4.s[1]      // out-(2,3)l: w4*inp(3,3)
    fmla    v29.4s, v1.4s, v4.s[1]      // out-(2,3)h: w4*inp(3,3)
    fmla    v31.4s, v1.4s, v5.s[1]      // out-(2,4)h: w4*inp(3,4)
    fmla    v30.4s, v0.4s, v5.s[1]      // out-(2,4)l: w4*inp(3,4)

    ld1     {v0.4s, v1.4s}, [x17], #32  // w4 [2]

    fmla    v16.4s, v0.4s, v8.s[2]      // out-(1,1)l: w4*inp(2,1)
    fmla    v17.4s, v1.4s, v8.s[2]      // out-(1,1)h: w4*inp(2,1)
    fmla    v19.4s, v1.4s, v9.s[2]      // out-(1,2)h: w4*inp(2,2)
    fmla    v18.4s, v0.4s, v9.s[2]      // out-(1,2)l: w4*inp(2,2)
    fmla    v20.4s, v0.4s, v10.s[2]     // out-(1,3)l: w4*inp(2,3)
    fmla    v21.4s, v1.4s, v10.s[2]     // out-(1,3)h: w4*inp(2,3)
    fmla    v23.4s, v1.4s, v11.s[2]     // out-(1,4)h: w4*inp(2,4)
    fmla    v22.4s, v0.4s, v11.s[2]     // out-(1,4)l: w4*inp(2,4)
    fmla    v24.4s, v0.4s, v2.s[2]      // out-(2,1)l: w4*inp(3,1)
    fmla    v25.4s, v1.4s, v2.s[2]      // out-(2,1)h: w4*inp(3,1)
    fmla    v27.4s, v1.4s, v3.s[2]      // out-(2,2)h: w4*inp(3,2)
    fmla    v26.4s, v0.4s, v3.s[2]      // out-(2,2)l: w4*inp(3,2)
    fmla    v28.4s, v0.4s, v4.s[2]      // out-(2,3)l: w4*inp(3,3)
    fmla    v29.4s, v1.4s, v4.s[2]      // out-(2,3)h: w4*inp(3,3)
    fmla    v31.4s, v1.4s, v5.s[2]      // out-(2,4)h: w4*inp(3,4)
    fmla    v30.4s, v0.4s, v5.s[2]      // out-(2,4)l: w4*inp(3,4)

    ld1     {v0.4s, v1.4s}, [x17], #32  // w4 [3]

    fmla    v16.4s, v0.4s, v8.s[3]      // out-(1,1)l: w4*inp(2,1)
    fmla    v17.4s, v1.4s, v8.s[3]      // out-(1,1)h: w4*inp(2,1)
    fmla    v19.4s, v1.4s, v9.s[3]      // out-(1,2)h: w4*inp(2,2)
    fmla    v18.4s, v0.4s, v9.s[3]      // out-(1,2)l: w4*inp(2,2)
    fmla    v20.4s, v0.4s, v10.s[3]     // out-(1,3)l: w4*inp(2,3)
    fmla    v21.4s, v1.4s, v10.s[3]     // out-(1,3)h: w4*inp(2,3)
    fmla    v23.4s, v1.4s, v11.s[3]     // out-(1,4)h: w4*inp(2,4)
    fmla    v22.4s, v0.4s, v11.s[3]     // out-(1,4)l: w4*inp(2,4)
    fmla    v24.4s, v0.4s, v2.s[3]      // out-(2,1)l: w4*inp(3,1)
    fmla    v25.4s, v1.4s, v2.s[3]      // out-(2,1)h: w4*inp(3,1)
    fmla    v27.4s, v1.4s, v3.s[3]      // out-(2,2)h: w4*inp(3,2)
    fmla    v26.4s, v0.4s, v3.s[3]      // out-(2,2)l: w4*inp(3,2)
    fmla    v28.4s, v0.4s, v4.s[3]      // out-(2,3)l: w4*inp(3,3)
    fmla    v29.4s, v1.4s, v4.s[3]      // out-(2,3)h: w4*inp(3,3)
    fmla    v31.4s, v1.4s, v5.s[3]      // out-(2,4)h: w4*inp(3,4)
    fmla    v30.4s, v0.4s, v5.s[3]      // out-(2,4)l: w4*inp(3,4)


    ld1     {v0.4s, v1.4s}, [x18], #32  // w5 [0]

    fmla    v16.4s, v0.4s, v9.s[0]      // out-(1,1)l: w5*inp(2,2)
    fmla    v17.4s, v1.4s, v9.s[0]      // out-(1,1)h: w5*inp(2,2)
    fmla    v19.4s, v1.4s, v10.s[0]     // out-(1,2)h: w5*inp(2,3)
    fmla    v18.4s, v0.4s, v10.s[0]     // out-(1,2)l: w5*inp(2,3)
    fmla    v20.4s, v0.4s, v11.s[0]     // out-(1,3)l: w5*inp(2,4)
    fmla    v21.4s, v1.4s, v11.s[0]     // out-(1,3)h: w5*inp(2,4)
    fmla    v23.4s, v1.4s, v12.s[0]     // out-(1,4)h: w5*inp(2,5)
    fmla    v22.4s, v0.4s, v12.s[0]     // out-(1,4)l: w5*inp(2,5)
    fmla    v24.4s, v0.4s, v3.s[0]      // out-(2,1)l: w5*inp(3,2)
    fmla    v25.4s, v1.4s, v3.s[0]      // out-(2,1)h: w5*inp(3,2)
    fmla    v27.4s, v1.4s, v4.s[0]      // out-(2,2)h: w5*inp(3,3)
    fmla    v26.4s, v0.4s, v4.s[0]      // out-(2,2)l: w5*inp(3,3)
    fmla    v28.4s, v0.4s, v5.s[0]      // out-(2,3)l: w5*inp(3,4)
    fmla    v29.4s, v1.4s, v5.s[0]      // out-(2,3)h: w5*inp(3,4)
    fmla    v31.4s, v1.4s, v6.s[0]      // out-(2,4)h: w5*inp(3,5)
    fmla    v30.4s, v0.4s, v6.s[0]      // out-(2,4)l: w5*inp(3,5)

    ld1     {v0.4s, v1.4s}, [x18], #32  // w5 [1]

    fmla    v16.4s, v0.4s, v9.s[1]      // out-(1,1)l: w5*inp(2,2)
    fmla    v17.4s, v1.4s, v9.s[1]      // out-(1,1)h: w5*inp(2,2)
    fmla    v19.4s, v1.4s, v10.s[1]     // out-(1,2)h: w5*inp(2,3)
    fmla    v18.4s, v0.4s, v10.s[1]     // out-(1,2)l: w5*inp(2,3)
    fmla    v20.4s, v0.4s, v11.s[1]     // out-(1,3)l: w5*inp(2,4)
    fmla    v21.4s, v1.4s, v11.s[1]     // out-(1,3)h: w5*inp(2,4)
    fmla    v23.4s, v1.4s, v12.s[1]     // out-(1,4)h: w5*inp(2,5)
    fmla    v22.4s, v0.4s, v12.s[1]     // out-(1,4)l: w5*inp(2,5)
    fmla    v24.4s, v0.4s, v3.s[1]      // out-(2,1)l: w5*inp(3,2)
    fmla    v25.4s, v1.4s, v3.s[1]      // out-(2,1)h: w5*inp(3,2)
    fmla    v27.4s, v1.4s, v4.s[1]      // out-(2,2)h: w5*inp(3,3)
    fmla    v26.4s, v0.4s, v4.s[1]      // out-(2,2)l: w5*inp(3,3)
    fmla    v28.4s, v0.4s, v5.s[1]      // out-(2,3)l: w5*inp(3,4)
    fmla    v29.4s, v1.4s, v5.s[1]      // out-(2,3)h: w5*inp(3,4)
    fmla    v31.4s, v1.4s, v6.s[1]      // out-(2,4)h: w5*inp(3,5)
    fmla    v30.4s, v0.4s, v6.s[1]      // out-(2,4)l: w5*inp(3,5)

    ld1     {v0.4s, v1.4s}, [x18], #32  // w5 [2]

    fmla    v16.4s, v0.4s, v9.s[2]      // out-(1,1)l: w5*inp(2,2)
    fmla    v17.4s, v1.4s, v9.s[2]      // out-(1,1)h: w5*inp(2,2)
    fmla    v19.4s, v1.4s, v10.s[2]     // out-(1,2)h: w5*inp(2,3)
    fmla    v18.4s, v0.4s, v10.s[2]     // out-(1,2)l: w5*inp(2,3)
    fmla    v20.4s, v0.4s, v11.s[2]     // out-(1,3)l: w5*inp(2,4)
    fmla    v21.4s, v1.4s, v11.s[2]     // out-(1,3)h: w5*inp(2,4)
    fmla    v23.4s, v1.4s, v12.s[2]     // out-(1,4)h: w5*inp(2,5)
    fmla    v22.4s, v0.4s, v12.s[2]     // out-(1,4)l: w5*inp(2,5)
    fmla    v24.4s, v0.4s, v3.s[2]      // out-(2,1)l: w5*inp(3,2)
    fmla    v25.4s, v1.4s, v3.s[2]      // out-(2,1)h: w5*inp(3,2)
    fmla    v27.4s, v1.4s, v4.s[2]      // out-(2,2)h: w5*inp(3,3)
    fmla    v26.4s, v0.4s, v4.s[2]      // out-(2,2)l: w5*inp(3,3)
    fmla    v28.4s, v0.4s, v5.s[2]      // out-(2,3)l: w5*inp(3,4)
    fmla    v29.4s, v1.4s, v5.s[2]      // out-(2,3)h: w5*inp(3,4)
    fmla    v31.4s, v1.4s, v6.s[2]      // out-(2,4)h: w5*inp(3,5)
    fmla    v30.4s, v0.4s, v6.s[2]      // out-(2,4)l: w5*inp(3,5)

    ld1     {v0.4s, v1.4s}, [x18], #32  // w5 [3]

    fmla    v16.4s, v0.4s, v9.s[3]      // out-(1,1)l: w5*inp(2,2)
    fmla    v17.4s, v1.4s, v9.s[3]      // out-(1,1)h: w5*inp(2,2)
    fmla    v19.4s, v1.4s, v10.s[3]     // out-(1,2)h: w5*inp(2,3)
    fmla    v18.4s, v0.4s, v10.s[3]     // out-(1,2)l: w5*inp(2,3)
    fmla    v20.4s, v0.4s, v11.s[3]     // out-(1,3)l: w5*inp(2,4)
    fmla    v21.4s, v1.4s, v11.s[3]     // out-(1,3)h: w5*inp(2,4)
    fmla    v23.4s, v1.4s, v12.s[3]     // out-(1,4)h: w5*inp(2,5)
    fmla    v22.4s, v0.4s, v12.s[3]     // out-(1,4)l: w5*inp(2,5)
    fmla    v24.4s, v0.4s, v3.s[3]      // out-(2,1)l: w5*inp(3,2)
    fmla    v25.4s, v1.4s, v3.s[3]      // out-(2,1)h: w5*inp(3,2)
    fmla    v27.4s, v1.4s, v4.s[3]      // out-(2,2)h: w5*inp(3,3)
    fmla    v26.4s, v0.4s, v4.s[3]      // out-(2,2)l: w5*inp(3,3)
    fmla    v28.4s, v0.4s, v5.s[3]      // out-(2,3)l: w5*inp(3,4)
    fmla    v29.4s, v1.4s, v5.s[3]      // out-(2,3)h: w5*inp(3,4)
    fmla    v31.4s, v1.4s, v6.s[3]      // out-(2,4)h: w5*inp(3,5)
    fmla    v30.4s, v0.4s, v6.s[3]      // out-(2,4)l: w5*inp(3,5)

    ld1     {v0.4s, v1.4s}, [x19], #32  // w6 [0]

    fmla    v16.4s, v0.4s, v10.s[0]     // out-(1,1)l: w5*inp(2,3)
    fmla    v17.4s, v1.4s, v10.s[0]     // out-(1,1)h: w5*inp(2,3)
    fmla    v19.4s, v1.4s, v11.s[0]     // out-(1,2)h: w5*inp(2,4)
    fmla    v18.4s, v0.4s, v11.s[0]     // out-(1,2)l: w5*inp(2,4)
    fmla    v20.4s, v0.4s, v12.s[0]     // out-(1,3)l: w5*inp(2,5)
    fmla    v21.4s, v1.4s, v12.s[0]     // out-(1,3)h: w5*inp(2,5)
    fmla    v23.4s, v1.4s, v13.s[0]     // out-(1,4)h: w5*inp(2,6)
    fmla    v22.4s, v0.4s, v13.s[0]     // out-(1,4)l: w5*inp(2,6)
    fmla    v24.4s, v0.4s, v4.s[0]      // out-(2,1)l: w5*inp(3,3)
    fmla    v25.4s, v1.4s, v4.s[0]      // out-(2,1)h: w5*inp(3,3)
    fmla    v27.4s, v1.4s, v5.s[0]      // out-(2,2)h: w5*inp(3,4)
    fmla    v26.4s, v0.4s, v5.s[0]      // out-(2,2)l: w5*inp(3,4)
    fmla    v28.4s, v0.4s, v6.s[0]      // out-(2,3)l: w5*inp(3,5)
    fmla    v29.4s, v1.4s, v6.s[0]      // out-(2,3)h: w5*inp(3,5)
    fmla    v31.4s, v1.4s, v7.s[0]      // out-(2,4)h: w5*inp(3,6)
    fmla    v30.4s, v0.4s, v7.s[0]      // out-(2,4)l: w5*inp(3,6)

    ld1     {v0.4s, v1.4s}, [x19], #32  // w6 [1]

    fmla    v16.4s, v0.4s, v10.s[1]     // out-(1,1)l: w5*inp(2,3)
    fmla    v17.4s, v1.4s, v10.s[1]     // out-(1,1)h: w5*inp(2,3)
    fmla    v19.4s, v1.4s, v11.s[1]     // out-(1,2)h: w5*inp(2,4)
    fmla    v18.4s, v0.4s, v11.s[1]     // out-(1,2)l: w5*inp(2,4)
    fmla    v20.4s, v0.4s, v12.s[1]     // out-(1,3)l: w5*inp(2,5)
    fmla    v21.4s, v1.4s, v12.s[1]     // out-(1,3)h: w5*inp(2,5)
    fmla    v23.4s, v1.4s, v13.s[1]     // out-(1,4)h: w5*inp(2,6)
    fmla    v22.4s, v0.4s, v13.s[1]     // out-(1,4)l: w5*inp(2,6)
    fmla    v24.4s, v0.4s, v4.s[1]      // out-(2,1)l: w5*inp(3,3)
    fmla    v25.4s, v1.4s, v4.s[1]      // out-(2,1)h: w5*inp(3,3)
    fmla    v27.4s, v1.4s, v5.s[1]      // out-(2,2)h: w5*inp(3,4)
    fmla    v26.4s, v0.4s, v5.s[1]      // out-(2,2)l: w5*inp(3,4)
    fmla    v28.4s, v0.4s, v6.s[1]      // out-(2,3)l: w5*inp(3,5)
    fmla    v29.4s, v1.4s, v6.s[1]      // out-(2,3)h: w5*inp(3,5)
    fmla    v31.4s, v1.4s, v7.s[1]      // out-(2,4)h: w5*inp(3,6)
    fmla    v30.4s, v0.4s, v7.s[1]      // out-(2,4)l: w5*inp(3,6)

    ld1     {v0.4s, v1.4s}, [x19], #32  // w6 [2]

    fmla    v16.4s, v0.4s, v10.s[2]     // out-(1,1)l: w5*inp(2,3)
    fmla    v17.4s, v1.4s, v10.s[2]     // out-(1,1)h: w5*inp(2,3)
    fmla    v19.4s, v1.4s, v11.s[2]     // out-(1,2)h: w5*inp(2,4)
    fmla    v18.4s, v0.4s, v11.s[2]     // out-(1,2)l: w5*inp(2,4)
    fmla    v20.4s, v0.4s, v12.s[2]     // out-(1,3)l: w5*inp(2,5)
    fmla    v21.4s, v1.4s, v12.s[2]     // out-(1,3)h: w5*inp(2,5)
    fmla    v23.4s, v1.4s, v13.s[2]     // out-(1,4)h: w5*inp(2,6)
    fmla    v22.4s, v0.4s, v13.s[2]     // out-(1,4)l: w5*inp(2,6)
    fmla    v24.4s, v0.4s, v4.s[2]      // out-(2,1)l: w5*inp(3,3)
    fmla    v25.4s, v1.4s, v4.s[2]      // out-(2,1)h: w5*inp(3,3)
    fmla    v27.4s, v1.4s, v5.s[2]      // out-(2,2)h: w5*inp(3,4)
    fmla    v26.4s, v0.4s, v5.s[2]      // out-(2,2)l: w5*inp(3,4)
    fmla    v28.4s, v0.4s, v6.s[2]      // out-(2,3)l: w5*inp(3,5)
    fmla    v29.4s, v1.4s, v6.s[2]      // out-(2,3)h: w5*inp(3,5)
    fmla    v31.4s, v1.4s, v7.s[2]      // out-(2,4)h: w5*inp(3,6)
    fmla    v30.4s, v0.4s, v7.s[2]      // out-(2,4)l: w5*inp(3,6)

    ld1     {v0.4s, v1.4s}, [x19], #32  // w6 [3]

    fmla    v16.4s, v0.4s, v10.s[3]     // out-(1,1)l: w5*inp(2,3)
    fmla    v17.4s, v1.4s, v10.s[3]     // out-(1,1)h: w5*inp(2,3)
    fmla    v19.4s, v1.4s, v11.s[3]     // out-(1,2)h: w5*inp(2,4)
    fmla    v18.4s, v0.4s, v11.s[3]     // out-(1,2)l: w5*inp(2,4)
    fmla    v20.4s, v0.4s, v12.s[3]     // out-(1,3)l: w5*inp(2,5)
    fmla    v21.4s, v1.4s, v12.s[3]     // out-(1,3)h: w5*inp(2,5)
    fmla    v23.4s, v1.4s, v13.s[3]     // out-(1,4)h: w5*inp(2,6)
    fmla    v22.4s, v0.4s, v13.s[3]     // out-(1,4)l: w5*inp(2,6)
    fmla    v24.4s, v0.4s, v4.s[3]      // out-(2,1)l: w5*inp(3,3)
    fmla    v25.4s, v1.4s, v4.s[3]      // out-(2,1)h: w5*inp(3,3)
    fmla    v27.4s, v1.4s, v5.s[3]      // out-(2,2)h: w5*inp(3,4)
    fmla    v26.4s, v0.4s, v5.s[3]      // out-(2,2)l: w5*inp(3,4)
    fmla    v28.4s, v0.4s, v6.s[3]      // out-(2,3)l: w5*inp(3,5)
    fmla    v29.4s, v1.4s, v6.s[3]      // out-(2,3)h: w5*inp(3,5)
    fmla    v31.4s, v1.4s, v7.s[3]      // out-(2,4)h: w5*inp(3,6)
    fmla    v30.4s, v0.4s, v7.s[3]      // out-(2,4)l: w5*inp(3,6)

    add     x7, x7, x5
    add     x8, x8, x5
    add     x9, x9, x5
    add     x10, x10, x5
    add     x11, x11, x5
    add     x12, x12, x5

    // replace input row 1 with row 4
    ld1     {v8.4s},  [x7]          // 4,1   r,c
    ld1     {v9.4s},  [x8]          // 4,2
    ld1     {v10.4s}, [x9]          // 4,3
    ld1     {v11.4s}, [x10]         // 4,4
    ld1     {v12.4s}, [x11]         // 4,5
    ld1     {v13.4s}, [x12]         // 4,6

    ld1     {v0.4s, v1.4s}, [x20], #32  // w7 [0]

    fmla    v16.4s, v0.4s, v2.s[0]      // out-(1,1)l: w7*inp(3,1)
    fmla    v17.4s, v1.4s, v2.s[0]      // out-(1,1)h: w7*inp(3,1)
    fmla    v19.4s, v1.4s, v3.s[0]      // out-(1,2)h: w7*inp(3,2)
    fmla    v18.4s, v0.4s, v3.s[0]      // out-(1,2)l: w7*inp(3,2)
    fmla    v20.4s, v0.4s, v4.s[0]      // out-(1,3)l: w7*inp(3,3)
    fmla    v21.4s, v1.4s, v4.s[0]      // out-(1,3)h: w7*inp(3,3)
    fmla    v23.4s, v1.4s, v5.s[0]      // out-(1,4)h: w7*inp(3,4)
    fmla    v22.4s, v0.4s, v5.s[0]      // out-(1,4)l: w7*inp(3,4)
    fmla    v24.4s, v0.4s, v8.s[0]      // out-(2,1)l: w7*inp(4,1)
    fmla    v25.4s, v1.4s, v8.s[0]      // out-(2,1)h: w7*inp(4,1)
    fmla    v27.4s, v1.4s, v9.s[0]      // out-(2,2)h: w7*inp(4,2)
    fmla    v26.4s, v0.4s, v9.s[0]      // out-(2,2)l: w7*inp(4,2)
    fmla    v28.4s, v0.4s, v10.s[0]     // out-(2,3)l: w7*inp(4,3)
    fmla    v29.4s, v1.4s, v10.s[0]     // out-(2,3)h: w7*inp(4,3)
    fmla    v31.4s, v1.4s, v11.s[0]     // out-(2,4)h: w7*inp(4,4)
    fmla    v30.4s, v0.4s, v11.s[0]     // out-(2,4)l: w7*inp(4,4)

    ld1     {v0.4s, v1.4s}, [x20], #32  // w7 [1]

    fmla    v16.4s, v0.4s, v2.s[1]      // out-(1,1)l: w7*inp(3,1)
    fmla    v17.4s, v1.4s, v2.s[1]      // out-(1,1)h: w7*inp(3,1)
    fmla    v19.4s, v1.4s, v3.s[1]      // out-(1,2)h: w7*inp(3,2)
    fmla    v18.4s, v0.4s, v3.s[1]      // out-(1,2)l: w7*inp(3,2)
    fmla    v20.4s, v0.4s, v4.s[1]      // out-(1,3)l: w7*inp(3,3)
    fmla    v21.4s, v1.4s, v4.s[1]      // out-(1,3)h: w7*inp(3,3)
    fmla    v23.4s, v1.4s, v5.s[1]      // out-(1,4)h: w7*inp(3,4)
    fmla    v22.4s, v0.4s, v5.s[1]      // out-(1,4)l: w7*inp(3,4)
    fmla    v24.4s, v0.4s, v8.s[1]      // out-(2,1)l: w7*inp(4,1)
    fmla    v25.4s, v1.4s, v8.s[1]      // out-(2,1)h: w7*inp(4,1)
    fmla    v27.4s, v1.4s, v9.s[1]      // out-(2,2)h: w7*inp(4,2)
    fmla    v26.4s, v0.4s, v9.s[1]      // out-(2,2)l: w7*inp(4,2)
    fmla    v28.4s, v0.4s, v10.s[1]     // out-(2,3)l: w7*inp(4,3)
    fmla    v29.4s, v1.4s, v10.s[1]     // out-(2,3)h: w7*inp(4,3)
    fmla    v31.4s, v1.4s, v11.s[1]     // out-(2,4)h: w7*inp(4,4)
    fmla    v30.4s, v0.4s, v11.s[1]     // out-(2,4)l: w7*inp(4,4)


    ld1     {v0.4s, v1.4s}, [x20], #32  // w7 [2]

    fmla    v16.4s, v0.4s, v2.s[2]      // out-(1,1)l: w7*inp(3,1)
    fmla    v17.4s, v1.4s, v2.s[2]      // out-(1,1)h: w7*inp(3,1)
    fmla    v19.4s, v1.4s, v3.s[2]      // out-(1,2)h: w7*inp(3,2)
    fmla    v18.4s, v0.4s, v3.s[2]      // out-(1,2)l: w7*inp(3,2)
    fmla    v20.4s, v0.4s, v4.s[2]      // out-(1,3)l: w7*inp(3,3)
    fmla    v21.4s, v1.4s, v4.s[2]      // out-(1,3)h: w7*inp(3,3)
    fmla    v23.4s, v1.4s, v5.s[2]      // out-(1,4)h: w7*inp(3,4)
    fmla    v22.4s, v0.4s, v5.s[2]      // out-(1,4)l: w7*inp(3,4)
    fmla    v24.4s, v0.4s, v8.s[2]      // out-(2,1)l: w7*inp(4,1)
    fmla    v25.4s, v1.4s, v8.s[2]      // out-(2,1)h: w7*inp(4,1)
    fmla    v27.4s, v1.4s, v9.s[2]      // out-(2,2)h: w7*inp(4,2)
    fmla    v26.4s, v0.4s, v9.s[2]      // out-(2,2)l: w7*inp(4,2)
    fmla    v28.4s, v0.4s, v10.s[2]     // out-(2,3)l: w7*inp(4,3)
    fmla    v29.4s, v1.4s, v10.s[2]     // out-(2,3)h: w7*inp(4,3)
    fmla    v31.4s, v1.4s, v11.s[2]     // out-(2,4)h: w7*inp(4,4)
    fmla    v30.4s, v0.4s, v11.s[2]     // out-(2,4)l: w7*inp(4,4)


    ld1     {v0.4s, v1.4s}, [x20], #32  // w7 [3]

    fmla    v16.4s, v0.4s, v2.s[3]      // out-(1,1)l: w7*inp(3,1)
    fmla    v17.4s, v1.4s, v2.s[3]      // out-(1,1)h: w7*inp(3,1)
    fmla    v19.4s, v1.4s, v3.s[3]      // out-(1,2)h: w7*inp(3,2)
    fmla    v18.4s, v0.4s, v3.s[3]      // out-(1,2)l: w7*inp(3,2)
    fmla    v20.4s, v0.4s, v4.s[3]      // out-(1,3)l: w7*inp(3,3)
    fmla    v21.4s, v1.4s, v4.s[3]      // out-(1,3)h: w7*inp(3,3)
    fmla    v23.4s, v1.4s, v5.s[3]      // out-(1,4)h: w7*inp(3,4)
    fmla    v22.4s, v0.4s, v5.s[3]      // out-(1,4)l: w7*inp(3,4)
    fmla    v24.4s, v0.4s, v8.s[3]      // out-(2,1)l: w7*inp(4,1)
    fmla    v25.4s, v1.4s, v8.s[3]      // out-(2,1)h: w7*inp(4,1)
    fmla    v27.4s, v1.4s, v9.s[3]      // out-(2,2)h: w7*inp(4,2)
    fmla    v26.4s, v0.4s, v9.s[3]      // out-(2,2)l: w7*inp(4,2)
    fmla    v28.4s, v0.4s, v10.s[3]     // out-(2,3)l: w7*inp(4,3)
    fmla    v29.4s, v1.4s, v10.s[3]     // out-(2,3)h: w7*inp(4,3)
    fmla    v31.4s, v1.4s, v11.s[3]     // out-(2,4)h: w7*inp(4,4)
    fmla    v30.4s, v0.4s, v11.s[3]     // out-(2,4)l: w7*inp(4,4)

    ld1     {v0.4s, v1.4s}, [x21], #32  // w8 [0]

    fmla    v16.4s, v0.4s, v3.s[0]      // out-(1,1)l: w8*inp(3,2)
    fmla    v17.4s, v1.4s, v3.s[0]      // out-(1,1)h: w8*inp(3,2)
    fmla    v19.4s, v1.4s, v4.s[0]      // out-(1,2)h: w8*inp(3,3)
    fmla    v18.4s, v0.4s, v4.s[0]      // out-(1,2)l: w8*inp(3,3)
    fmla    v20.4s, v0.4s, v5.s[0]      // out-(1,3)l: w8*inp(3,4)
    fmla    v21.4s, v1.4s, v5.s[0]      // out-(1,3)h: w8*inp(3,4)
    fmla    v23.4s, v1.4s, v6.s[0]      // out-(1,4)h: w8*inp(3,5)
    fmla    v22.4s, v0.4s, v6.s[0]      // out-(1,4)l: w8*inp(3,5)
    fmla    v24.4s, v0.4s, v9.s[0]      // out-(2,1)l: w8*inp(4,2)
    fmla    v25.4s, v1.4s, v9.s[0]      // out-(2,1)h: w8*inp(4,2)
    fmla    v27.4s, v1.4s, v10.s[0]     // out-(2,2)h: w8*inp(4,3)
    fmla    v26.4s, v0.4s, v10.s[0]     // out-(2,2)l: w8*inp(4,3)
    fmla    v28.4s, v0.4s, v11.s[0]     // out-(2,3)l: w8*inp(4,4)
    fmla    v29.4s, v1.4s, v11.s[0]     // out-(2,3)h: w8*inp(4,4)
    fmla    v31.4s, v1.4s, v12.s[0]     // out-(2,4)h: w8*inp(4,5)
    fmla    v30.4s, v0.4s, v12.s[0]     // out-(2,4)l: w8*inp(4,5)

    ld1     {v0.4s, v1.4s}, [x21], #32  // w8 [1]

    fmla    v16.4s, v0.4s, v3.s[1]      // out-(1,1)l: w8*inp(3,2)
    fmla    v17.4s, v1.4s, v3.s[1]      // out-(1,1)h: w8*inp(3,2)
    fmla    v19.4s, v1.4s, v4.s[1]      // out-(1,2)h: w8*inp(3,3)
    fmla    v18.4s, v0.4s, v4.s[1]      // out-(1,2)l: w8*inp(3,3)
    fmla    v20.4s, v0.4s, v5.s[1]      // out-(1,3)l: w8*inp(3,4)
    fmla    v21.4s, v1.4s, v5.s[1]      // out-(1,3)h: w8*inp(3,4)
    fmla    v23.4s, v1.4s, v6.s[1]      // out-(1,4)h: w8*inp(3,5)
    fmla    v22.4s, v0.4s, v6.s[1]      // out-(1,4)l: w8*inp(3,5)
    fmla    v24.4s, v0.4s, v9.s[1]      // out-(2,1)l: w8*inp(4,2)
    fmla    v25.4s, v1.4s, v9.s[1]      // out-(2,1)h: w8*inp(4,2)
    fmla    v27.4s, v1.4s, v10.s[1]     // out-(2,2)h: w8*inp(4,3)
    fmla    v26.4s, v0.4s, v10.s[1]     // out-(2,2)l: w8*inp(4,3)
    fmla    v28.4s, v0.4s, v11.s[1]     // out-(2,3)l: w8*inp(4,4)
    fmla    v29.4s, v1.4s, v11.s[1]     // out-(2,3)h: w8*inp(4,4)
    fmla    v31.4s, v1.4s, v12.s[1]     // out-(2,4)h: w8*inp(4,5)
    fmla    v30.4s, v0.4s, v12.s[1]     // out-(2,4)l: w8*inp(4,5)

    ld1     {v0.4s, v1.4s}, [x21], #32  // w8 [2]

    fmla    v16.4s, v0.4s, v3.s[2]      // out-(1,1)l: w8*inp(3,2)
    fmla    v17.4s, v1.4s, v3.s[2]      // out-(1,1)h: w8*inp(3,2)
    fmla    v19.4s, v1.4s, v4.s[2]      // out-(1,2)h: w8*inp(3,3)
    fmla    v18.4s, v0.4s, v4.s[2]      // out-(1,2)l: w8*inp(3,3)
    fmla    v20.4s, v0.4s, v5.s[2]      // out-(1,3)l: w8*inp(3,4)
    fmla    v21.4s, v1.4s, v5.s[2]      // out-(1,3)h: w8*inp(3,4)
    fmla    v23.4s, v1.4s, v6.s[2]      // out-(1,4)h: w8*inp(3,5)
    fmla    v22.4s, v0.4s, v6.s[2]      // out-(1,4)l: w8*inp(3,5)
    fmla    v24.4s, v0.4s, v9.s[2]      // out-(2,1)l: w8*inp(4,2)
    fmla    v25.4s, v1.4s, v9.s[2]      // out-(2,1)h: w8*inp(4,2)
    fmla    v27.4s, v1.4s, v10.s[2]     // out-(2,2)h: w8*inp(4,3)
    fmla    v26.4s, v0.4s, v10.s[2]     // out-(2,2)l: w8*inp(4,3)
    fmla    v28.4s, v0.4s, v11.s[2]     // out-(2,3)l: w8*inp(4,4)
    fmla    v29.4s, v1.4s, v11.s[2]     // out-(2,3)h: w8*inp(4,4)
    fmla    v31.4s, v1.4s, v12.s[2]     // out-(2,4)h: w8*inp(4,5)
    fmla    v30.4s, v0.4s, v12.s[2]     // out-(2,4)l: w8*inp(4,5)

    ld1     {v0.4s, v1.4s}, [x21], #32  // w8 [3]

    fmla    v16.4s, v0.4s, v3.s[3]      // out-(1,1)l: w8*inp(3,2)
    fmla    v17.4s, v1.4s, v3.s[3]      // out-(1,1)h: w8*inp(3,2)
    fmla    v19.4s, v1.4s, v4.s[3]      // out-(1,2)h: w8*inp(3,3)
    fmla    v18.4s, v0.4s, v4.s[3]      // out-(1,2)l: w8*inp(3,3)
    fmla    v20.4s, v0.4s, v5.s[3]      // out-(1,3)l: w8*inp(3,4)
    fmla    v21.4s, v1.4s, v5.s[3]      // out-(1,3)h: w8*inp(3,4)
    fmla    v23.4s, v1.4s, v6.s[3]      // out-(1,4)h: w8*inp(3,5)
    fmla    v22.4s, v0.4s, v6.s[3]      // out-(1,4)l: w8*inp(3,5)
    fmla    v24.4s, v0.4s, v9.s[3]      // out-(2,1)l: w8*inp(4,2)
    fmla    v25.4s, v1.4s, v9.s[3]      // out-(2,1)h: w8*inp(4,2)
    fmla    v27.4s, v1.4s, v10.s[3]     // out-(2,2)h: w8*inp(4,3)
    fmla    v26.4s, v0.4s, v10.s[3]     // out-(2,2)l: w8*inp(4,3)
    fmla    v28.4s, v0.4s, v11.s[3]     // out-(2,3)l: w8*inp(4,4)
    fmla    v29.4s, v1.4s, v11.s[3]     // out-(2,3)h: w8*inp(4,4)
    fmla    v31.4s, v1.4s, v12.s[3]     // out-(2,4)h: w8*inp(4,5)
    fmla    v30.4s, v0.4s, v12.s[3]     // out-(2,4)l: w8*inp(4,5)

    ld1     {v0.4s, v1.4s}, [x22], #32  // w9 [0]

    fmla    v16.4s, v0.4s, v4.s[0]      // out-(1,1)l: w9*inp(3,3)
    fmla    v17.4s, v1.4s, v4.s[0]      // out-(1,1)h: w9*inp(3,3)
    fmla    v19.4s, v1.4s, v5.s[0]      // out-(1,2)h: w9*inp(3,4)
    fmla    v18.4s, v0.4s, v5.s[0]      // out-(1,2)l: w9*inp(3,4)
    fmla    v20.4s, v0.4s, v6.s[0]      // out-(1,3)l: w9*inp(3,5)
    fmla    v21.4s, v1.4s, v6.s[0]      // out-(1,3)h: w9*inp(3,5)
    fmla    v23.4s, v1.4s, v7.s[0]      // out-(1,4)h: w9*inp(3,6)
    fmla    v22.4s, v0.4s, v7.s[0]      // out-(1,4)l: w9*inp(3,6)
    fmla    v24.4s, v0.4s, v10.s[0]     // out-(2,1)l: w9*inp(4,3)
    fmla    v25.4s, v1.4s, v10.s[0]     // out-(2,1)h: w9*inp(4,3)
    fmla    v27.4s, v1.4s, v11.s[0]     // out-(2,2)h: w9*inp(4,4)
    fmla    v26.4s, v0.4s, v11.s[0]     // out-(2,2)l: w9*inp(4,4)
    fmla    v28.4s, v0.4s, v12.s[0]     // out-(2,3)l: w9*inp(4,5)
    fmla    v29.4s, v1.4s, v12.s[0]     // out-(2,3)h: w9*inp(4,5)
    fmla    v31.4s, v1.4s, v13.s[0]     // out-(2,4)h: w9*inp(4,6)
    fmla    v30.4s, v0.4s, v13.s[0]     // out-(2,4)l: w9*inp(4,6)

    ld1     {v0.4s, v1.4s}, [x22], #32  // w9 [1]

    fmla    v16.4s, v0.4s, v4.s[1]      // out-(1,1)l: w9*inp(3,3)
    fmla    v17.4s, v1.4s, v4.s[1]      // out-(1,1)h: w9*inp(3,3)
    fmla    v19.4s, v1.4s, v5.s[1]      // out-(1,2)h: w9*inp(3,4)
    fmla    v18.4s, v0.4s, v5.s[1]      // out-(1,2)l: w9*inp(3,4)
    fmla    v20.4s, v0.4s, v6.s[1]      // out-(1,3)l: w9*inp(3,5)
    fmla    v21.4s, v1.4s, v6.s[1]      // out-(1,3)h: w9*inp(3,5)
    fmla    v23.4s, v1.4s, v7.s[1]      // out-(1,4)h: w9*inp(3,6)
    fmla    v22.4s, v0.4s, v7.s[1]      // out-(1,4)l: w9*inp(3,6)
    fmla    v24.4s, v0.4s, v10.s[1]     // out-(2,1)l: w9*inp(4,3)
    fmla    v25.4s, v1.4s, v10.s[1]     // out-(2,1)h: w9*inp(4,3)
    fmla    v27.4s, v1.4s, v11.s[1]     // out-(2,2)h: w9*inp(4,4)
    fmla    v26.4s, v0.4s, v11.s[1]     // out-(2,2)l: w9*inp(4,4)
    fmla    v28.4s, v0.4s, v12.s[1]     // out-(2,3)l: w9*inp(4,5)
    fmla    v29.4s, v1.4s, v12.s[1]     // out-(2,3)h: w9*inp(4,5)
    fmla    v31.4s, v1.4s, v13.s[1]     // out-(2,4)h: w9*inp(4,6)
    fmla    v30.4s, v0.4s, v13.s[1]     // out-(2,4)l: w9*inp(4,6)

    ld1     {v0.4s, v1.4s}, [x22], #32  // w9 [2]

    fmla    v16.4s, v0.4s, v4.s[2]      // out-(1,1)l: w9*inp(3,3)
    fmla    v17.4s, v1.4s, v4.s[2]      // out-(1,1)h: w9*inp(3,3)
    fmla    v19.4s, v1.4s, v5.s[2]      // out-(1,2)h: w9*inp(3,4)
    fmla    v18.4s, v0.4s, v5.s[2]      // out-(1,2)l: w9*inp(3,4)
    fmla    v20.4s, v0.4s, v6.s[2]      // out-(1,3)l: w9*inp(3,5)
    fmla    v21.4s, v1.4s, v6.s[2]      // out-(1,3)h: w9*inp(3,5)
    fmla    v23.4s, v1.4s, v7.s[2]      // out-(1,4)h: w9*inp(3,6)
    fmla    v22.4s, v0.4s, v7.s[2]      // out-(1,4)l: w9*inp(3,6)
    fmla    v24.4s, v0.4s, v10.s[2]     // out-(2,1)l: w9*inp(4,3)
    fmla    v25.4s, v1.4s, v10.s[2]     // out-(2,1)h: w9*inp(4,3)
    fmla    v27.4s, v1.4s, v11.s[2]     // out-(2,2)h: w9*inp(4,4)
    fmla    v26.4s, v0.4s, v11.s[2]     // out-(2,2)l: w9*inp(4,4)
    fmla    v28.4s, v0.4s, v12.s[2]     // out-(2,3)l: w9*inp(4,5)
    fmla    v29.4s, v1.4s, v12.s[2]     // out-(2,3)h: w9*inp(4,5)
    fmla    v31.4s, v1.4s, v13.s[2]     // out-(2,4)h: w9*inp(4,6)
    fmla    v30.4s, v0.4s, v13.s[2]     // out-(2,4)l: w9*inp(4,6)

    ld1     {v0.4s, v1.4s}, [x22], #32  // w9 [3]

    fmla    v16.4s, v0.4s, v4.s[3]      // out-(1,1)l: w9*inp(3,3)
    fmla    v17.4s, v1.4s, v4.s[3]      // out-(1,1)h: w9*inp(3,3)
    fmla    v19.4s, v1.4s, v5.s[3]      // out-(1,2)h: w9*inp(3,4)
    fmla    v18.4s, v0.4s, v5.s[3]      // out-(1,2)l: w9*inp(3,4)
    fmla    v20.4s, v0.4s, v6.s[3]      // out-(1,3)l: w9*inp(3,5)
    fmla    v21.4s, v1.4s, v6.s[3]      // out-(1,3)h: w9*inp(3,5)
    fmla    v23.4s, v1.4s, v7.s[3]      // out-(1,4)h: w9*inp(3,6)
    fmla    v22.4s, v0.4s, v7.s[3]      // out-(1,4)l: w9*inp(3,6)
    fmla    v24.4s, v0.4s, v10.s[3]     // out-(2,1)l: w9*inp(4,3)
    fmla    v25.4s, v1.4s, v10.s[3]     // out-(2,1)h: w9*inp(4,3)
    fmla    v27.4s, v1.4s, v11.s[3]     // out-(2,2)h: w9*inp(4,4)
    fmla    v26.4s, v0.4s, v11.s[3]     // out-(2,2)l: w9*inp(4,4)
    fmla    v28.4s, v0.4s, v12.s[3]     // out-(2,3)l: w9*inp(4,5)
    fmla    v29.4s, v1.4s, v12.s[3]     // out-(2,3)h: w9*inp(4,5)
    fmla    v31.4s, v1.4s, v13.s[3]     // out-(2,4)h: w9*inp(4,6)
    fmla    v30.4s, v0.4s, v13.s[3]     // out-(2,4)l: w9*inp(4,6)

    sub     x7,  x7,  x13
    sub     x8,  x8,  x13
    sub     x9,  x9,  x13
    sub     x10, x10, x13
    sub     x11, x11, x13
    sub     x12, x12, x13

    subs x24, x24, #4
    bgt ic_loop


    // store outputs

    st1 {v16.4s, v17.4s}, [x2]
    add x2, x2, x3

    st1 {v18.4s, v19.4s}, [x2]
    add x2, x2, x3

    st1 {v20.4s, v21.4s}, [x2]
    add x2, x2, x3

    st1 {v22.4s, v23.4s}, [x2]
    add x2, x2, x3


    st1 {v24.4s, v25.4s}, [x6]
    add x6, x6, x3

    st1 {v26.4s, v27.4s}, [x6]
    add x6, x6, x3

    st1 {v28.4s, v29.4s}, [x6]
    add x6, x6, x3

    st1 {v30.4s, v31.4s}, [x6]

    ldr x24, [sp, #144]
    ldp x22, x23, [sp, #128]
    ldp x20, x21, [sp, #112]
    ldp x18, x19, [sp, #96]
    ldp q12, q13, [sp, #64]
    ldp q10, q11, [sp, #32]
    ldp q8, q9, [sp, #0]
    add sp, sp, #160

    ret
