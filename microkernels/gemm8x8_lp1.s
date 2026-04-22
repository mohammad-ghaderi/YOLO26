.global gemm8x8_v5
.type gemm8x8_v5, %function
// no stack, 4 input channel read in loop
// with only one loop ky

gemm8x8_v5:
    // x0: input address
    // x1: weights address
    // x2: output address
    // x3: output stride
    // x4: IC
    // x5: layer stride
    // x6: kernel stride

    sub sp, sp, #112

    stp q8,  q9,  [sp, #0]
    stp q10, q11, [sp, #32]
    stp x18, x19, [sp, #64]
    stp x20, x21, [sp, #80]
    str x22, [sp, #96]

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
    add     x14, x13, x6        // pixel7 (+ (9*7)*8)
    add     x15, x14, x6
    add     x16, x15, x6
    
    lsl     x21, x6, #3

    mov     x17, x1         // w1
    add     x18, x17, x21   // w2
    add     x19, x18, x21   // w3

    lsl     x21, x21, #1


    mov     x20, #3             // ky idx
kernel_loop:

    mov     x22, x4             // ic idx
ic_loop:
    // load inputs
    ld1     {v2.4s},  [x7],  #16        // 1
    ld1     {v3.4s},  [x8],  #16        // 2
    ld1     {v4.4s},  [x9],  #16        // 3
    ld1     {v5.4s},  [x10], #16        // 4
    ld1     {v6.4s},  [x11], #16        // 5
    ld1     {v7.4s},  [x12], #16        // 6
    ld1     {v8.4s},  [x13], #16        // 7
    ld1     {v9.4s},  [x14], #16        // 8
    ld1     {v10.4s}, [x15], #16        // 9
    ld1     {v11.4s}, [x16], #16        // 10

    ld1     {v0.4s, v1.4s}, [x17], #32  // w1

    fmla    v16.4s, v0.4s, v2.s[0]      // out-1l: w1*inp1
    fmla    v17.4s, v1.4s, v2.s[0]      // out-1h: w1*inp1
    fmla    v19.4s, v1.4s, v3.s[0]      // out-2h: w1*inp2
    fmla    v18.4s, v0.4s, v3.s[0]      // out-2l: w1*inp2
    fmla    v20.4s, v0.4s, v4.s[0]      // out-3l: w1*inp3
    fmla    v21.4s, v1.4s, v4.s[0]      // out-3h: w1*inp3
    fmla    v23.4s, v1.4s, v5.s[0]      // out-4h: w1*inp4
    fmla    v22.4s, v0.4s, v5.s[0]      // out-4l: w1*inp4
    fmla    v24.4s, v0.4s, v6.s[0]      // out-5l: w1*inp5
    fmla    v25.4s, v1.4s, v6.s[0]      // out-5h: w1*inp5
    fmla    v27.4s, v1.4s, v7.s[0]      // out-6h: w1*inp6
    fmla    v26.4s, v0.4s, v7.s[0]      // out-6l: w1*inp6
    fmla    v28.4s, v0.4s, v8.s[0]      // out-7l: w1*inp7
    fmla    v29.4s, v1.4s, v8.s[0]      // out-7h: w1*inp7
    fmla    v31.4s, v1.4s, v9.s[0]      // out-8h: w1*inp8
    fmla    v30.4s, v0.4s, v9.s[0]      // out-8l: w1*inp8

    ld1     {v0.4s, v1.4s}, [x18], #32  // w2

    fmla    v16.4s, v0.4s, v3.s[0]      // out-1l: w2*inp2
    fmla    v17.4s, v1.4s, v3.s[0]      // out-1h: w2*inp2
    fmla    v19.4s, v1.4s, v4.s[0]      // out-2h: w2*inp3
    fmla    v18.4s, v0.4s, v4.s[0]      // out-2l: w2*inp3
    fmla    v20.4s, v0.4s, v5.s[0]      // out-3l: w2*inp4
    fmla    v21.4s, v1.4s, v5.s[0]      // out-3h: w2*inp4
    fmla    v23.4s, v1.4s, v6.s[0]      // out-4h: w2*inp5
    fmla    v22.4s, v0.4s, v6.s[0]      // out-4l: w2*inp5
    fmla    v24.4s, v0.4s, v7.s[0]      // out-5l: w2*inp6
    fmla    v25.4s, v1.4s, v7.s[0]      // out-5h: w2*inp6
    fmla    v27.4s, v1.4s, v8.s[0]      // out-6h: w2*inp7
    fmla    v26.4s, v0.4s, v8.s[0]      // out-6l: w2*inp7
    fmla    v28.4s, v0.4s, v9.s[0]      // out-7l: w2*inp8
    fmla    v29.4s, v1.4s, v9.s[0]      // out-7h: w2*inp8
    fmla    v31.4s, v1.4s, v10.s[0]     // out-8h: w2*inp9
    fmla    v30.4s, v0.4s, v10.s[0]     // out-8l: w2*inp9

    ld1     {v0.4s, v1.4s}, [x19], #32  // w3

    fmla    v16.4s, v0.4s, v4.s[0]      // out-1l: w3*inp3
    fmla    v17.4s, v1.4s, v4.s[0]      // out-1h: w3*inp3
    fmla    v19.4s, v1.4s, v5.s[0]      // out-2h: w3*inp4
    fmla    v18.4s, v0.4s, v5.s[0]      // out-2l: w3*inp4
    fmla    v20.4s, v0.4s, v6.s[0]      // out-3l: w3*inp5
    fmla    v21.4s, v1.4s, v6.s[0]      // out-3h: w3*inp5
    fmla    v23.4s, v1.4s, v7.s[0]      // out-4h: w3*inp6
    fmla    v22.4s, v0.4s, v7.s[0]      // out-4l: w3*inp6
    fmla    v24.4s, v0.4s, v8.s[0]      // out-5l: w3*inp7
    fmla    v25.4s, v1.4s, v8.s[0]      // out-5h: w3*inp7
    fmla    v27.4s, v1.4s, v9.s[0]      // out-6h: w3*inp8
    fmla    v26.4s, v0.4s, v9.s[0]      // out-6l: w3*inp8
    fmla    v28.4s, v0.4s, v10.s[0]     // out-7l: w3*inp9
    fmla    v29.4s, v1.4s, v10.s[0]     // out-7h: w3*inp9
    fmla    v31.4s, v1.4s, v11.s[0]     // out-8h: w3*inp10
    fmla    v30.4s, v0.4s, v11.s[0]     // out-8l: w3*inp10

    ld1     {v0.4s, v1.4s}, [x17], #32  // w1

    fmla    v16.4s, v0.4s, v2.s[1]      // out-1l: w1*inp1
    fmla    v17.4s, v1.4s, v2.s[1]      // out-1h: w1*inp1
    fmla    v19.4s, v1.4s, v3.s[1]      // out-2h: w1*inp2
    fmla    v18.4s, v0.4s, v3.s[1]      // out-2l: w1*inp2
    fmla    v20.4s, v0.4s, v4.s[1]      // out-3l: w1*inp3
    fmla    v21.4s, v1.4s, v4.s[1]      // out-3h: w1*inp3
    fmla    v23.4s, v1.4s, v5.s[1]      // out-4h: w1*inp4
    fmla    v22.4s, v0.4s, v5.s[1]      // out-4l: w1*inp4
    fmla    v24.4s, v0.4s, v6.s[1]      // out-5l: w1*inp5
    fmla    v25.4s, v1.4s, v6.s[1]      // out-5h: w1*inp5
    fmla    v27.4s, v1.4s, v7.s[1]      // out-6h: w1*inp6
    fmla    v26.4s, v0.4s, v7.s[1]      // out-6l: w1*inp6
    fmla    v28.4s, v0.4s, v8.s[1]      // out-7l: w1*inp7
    fmla    v29.4s, v1.4s, v8.s[1]      // out-7h: w1*inp7
    fmla    v31.4s, v1.4s, v9.s[1]      // out-8h: w1*inp8
    fmla    v30.4s, v0.4s, v9.s[1]      // out-8l: w1*inp8

    ld1     {v0.4s, v1.4s}, [x18], #32  // w2

    fmla    v16.4s, v0.4s, v3.s[1]      // out-1l: w2*inp2
    fmla    v17.4s, v1.4s, v3.s[1]      // out-1h: w2*inp2
    fmla    v19.4s, v1.4s, v4.s[1]      // out-2h: w2*inp3
    fmla    v18.4s, v0.4s, v4.s[1]      // out-2l: w2*inp3
    fmla    v20.4s, v0.4s, v5.s[1]      // out-3l: w2*inp4
    fmla    v21.4s, v1.4s, v5.s[1]      // out-3h: w2*inp4
    fmla    v23.4s, v1.4s, v6.s[1]      // out-4h: w2*inp5
    fmla    v22.4s, v0.4s, v6.s[1]      // out-4l: w2*inp5
    fmla    v24.4s, v0.4s, v7.s[1]      // out-5l: w2*inp6
    fmla    v25.4s, v1.4s, v7.s[1]      // out-5h: w2*inp6
    fmla    v27.4s, v1.4s, v8.s[1]      // out-6h: w2*inp7
    fmla    v26.4s, v0.4s, v8.s[1]      // out-6l: w2*inp7
    fmla    v28.4s, v0.4s, v9.s[1]      // out-7l: w2*inp8
    fmla    v29.4s, v1.4s, v9.s[1]      // out-7h: w2*inp8
    fmla    v31.4s, v1.4s, v10.s[1]     // out-8h: w2*inp9
    fmla    v30.4s, v0.4s, v10.s[1]     // out-8l: w2*inp9

    ld1     {v0.4s, v1.4s}, [x19], #32  // w3

    fmla    v16.4s, v0.4s, v4.s[1]      // out-1l: w3*inp3
    fmla    v17.4s, v1.4s, v4.s[1]      // out-1h: w3*inp3
    fmla    v19.4s, v1.4s, v5.s[1]      // out-2h: w3*inp4
    fmla    v18.4s, v0.4s, v5.s[1]      // out-2l: w3*inp4
    fmla    v20.4s, v0.4s, v6.s[1]      // out-3l: w3*inp5
    fmla    v21.4s, v1.4s, v6.s[1]      // out-3h: w3*inp5
    fmla    v23.4s, v1.4s, v7.s[1]      // out-4h: w3*inp6
    fmla    v22.4s, v0.4s, v7.s[1]      // out-4l: w3*inp6
    fmla    v24.4s, v0.4s, v8.s[1]      // out-5l: w3*inp7
    fmla    v25.4s, v1.4s, v8.s[1]      // out-5h: w3*inp7
    fmla    v27.4s, v1.4s, v9.s[1]      // out-6h: w3*inp8
    fmla    v26.4s, v0.4s, v9.s[1]      // out-6l: w3*inp8
    fmla    v28.4s, v0.4s, v10.s[1]     // out-7l: w3*inp9
    fmla    v29.4s, v1.4s, v10.s[1]     // out-7h: w3*inp9
    fmla    v31.4s, v1.4s, v11.s[1]     // out-8h: w3*inp10
    fmla    v30.4s, v0.4s, v11.s[1]     // out-8l: w3*inp10

    ld1     {v0.4s, v1.4s}, [x17], #32  // w1

    fmla    v16.4s, v0.4s, v2.s[2]      // out-1l: w1*inp1
    fmla    v17.4s, v1.4s, v2.s[2]      // out-1h: w1*inp1
    fmla    v19.4s, v1.4s, v3.s[2]      // out-2h: w1*inp2
    fmla    v18.4s, v0.4s, v3.s[2]      // out-2l: w1*inp2
    fmla    v20.4s, v0.4s, v4.s[2]      // out-3l: w1*inp3
    fmla    v21.4s, v1.4s, v4.s[2]      // out-3h: w1*inp3
    fmla    v23.4s, v1.4s, v5.s[2]      // out-4h: w1*inp4
    fmla    v22.4s, v0.4s, v5.s[2]      // out-4l: w1*inp4
    fmla    v24.4s, v0.4s, v6.s[2]      // out-5l: w1*inp5
    fmla    v25.4s, v1.4s, v6.s[2]      // out-5h: w1*inp5
    fmla    v27.4s, v1.4s, v7.s[2]      // out-6h: w1*inp6
    fmla    v26.4s, v0.4s, v7.s[2]      // out-6l: w1*inp6
    fmla    v28.4s, v0.4s, v8.s[2]      // out-7l: w1*inp7
    fmla    v29.4s, v1.4s, v8.s[2]      // out-7h: w1*inp7
    fmla    v31.4s, v1.4s, v9.s[2]      // out-8h: w1*inp8
    fmla    v30.4s, v0.4s, v9.s[2]      // out-8l: w1*inp8

    ld1     {v0.4s, v1.4s}, [x18], #32  // w2

    fmla    v16.4s, v0.4s, v3.s[2]      // out-1l: w2*inp2
    fmla    v17.4s, v1.4s, v3.s[2]      // out-1h: w2*inp2
    fmla    v19.4s, v1.4s, v4.s[2]      // out-2h: w2*inp3
    fmla    v18.4s, v0.4s, v4.s[2]      // out-2l: w2*inp3
    fmla    v20.4s, v0.4s, v5.s[2]      // out-3l: w2*inp4
    fmla    v21.4s, v1.4s, v5.s[2]      // out-3h: w2*inp4
    fmla    v23.4s, v1.4s, v6.s[2]      // out-4h: w2*inp5
    fmla    v22.4s, v0.4s, v6.s[2]      // out-4l: w2*inp5
    fmla    v24.4s, v0.4s, v7.s[2]      // out-5l: w2*inp6
    fmla    v25.4s, v1.4s, v7.s[2]      // out-5h: w2*inp6
    fmla    v27.4s, v1.4s, v8.s[2]      // out-6h: w2*inp7
    fmla    v26.4s, v0.4s, v8.s[2]      // out-6l: w2*inp7
    fmla    v28.4s, v0.4s, v9.s[2]      // out-7l: w2*inp8
    fmla    v29.4s, v1.4s, v9.s[2]      // out-7h: w2*inp8
    fmla    v31.4s, v1.4s, v10.s[2]     // out-8h: w2*inp9
    fmla    v30.4s, v0.4s, v10.s[2]     // out-8l: w2*inp9

    ld1     {v0.4s, v1.4s}, [x19], #32  // w3

    fmla    v16.4s, v0.4s, v4.s[2]      // out-1l: w3*inp3
    fmla    v17.4s, v1.4s, v4.s[2]      // out-1h: w3*inp3
    fmla    v19.4s, v1.4s, v5.s[2]      // out-2h: w3*inp4
    fmla    v18.4s, v0.4s, v5.s[2]      // out-2l: w3*inp4
    fmla    v20.4s, v0.4s, v6.s[2]      // out-3l: w3*inp5
    fmla    v21.4s, v1.4s, v6.s[2]      // out-3h: w3*inp5
    fmla    v23.4s, v1.4s, v7.s[2]      // out-4h: w3*inp6
    fmla    v22.4s, v0.4s, v7.s[2]      // out-4l: w3*inp6
    fmla    v24.4s, v0.4s, v8.s[2]      // out-5l: w3*inp7
    fmla    v25.4s, v1.4s, v8.s[2]      // out-5h: w3*inp7
    fmla    v27.4s, v1.4s, v9.s[2]      // out-6h: w3*inp8
    fmla    v26.4s, v0.4s, v9.s[2]      // out-6l: w3*inp8
    fmla    v28.4s, v0.4s, v10.s[2]     // out-7l: w3*inp9
    fmla    v29.4s, v1.4s, v10.s[2]     // out-7h: w3*inp9
    fmla    v31.4s, v1.4s, v11.s[2]     // out-8h: w3*inp10
    fmla    v30.4s, v0.4s, v11.s[2]     // out-8l: w3*inp10

    ld1     {v0.4s, v1.4s}, [x17], #32  // w1

    fmla    v16.4s, v0.4s, v2.s[3]      // out-1l: w1*inp1
    fmla    v17.4s, v1.4s, v2.s[3]      // out-1h: w1*inp1
    fmla    v19.4s, v1.4s, v3.s[3]      // out-2h: w1*inp2
    fmla    v18.4s, v0.4s, v3.s[3]      // out-2l: w1*inp2
    fmla    v20.4s, v0.4s, v4.s[3]      // out-3l: w1*inp3
    fmla    v21.4s, v1.4s, v4.s[3]      // out-3h: w1*inp3
    fmla    v23.4s, v1.4s, v5.s[3]      // out-4h: w1*inp4
    fmla    v22.4s, v0.4s, v5.s[3]      // out-4l: w1*inp4
    fmla    v24.4s, v0.4s, v6.s[3]      // out-5l: w1*inp5
    fmla    v25.4s, v1.4s, v6.s[3]      // out-5h: w1*inp5
    fmla    v27.4s, v1.4s, v7.s[3]      // out-6h: w1*inp6
    fmla    v26.4s, v0.4s, v7.s[3]      // out-6l: w1*inp6
    fmla    v28.4s, v0.4s, v8.s[3]      // out-7l: w1*inp7
    fmla    v29.4s, v1.4s, v8.s[3]      // out-7h: w1*inp7
    fmla    v31.4s, v1.4s, v9.s[3]      // out-8h: w1*inp8
    fmla    v30.4s, v0.4s, v9.s[3]      // out-8l: w1*inp8

    ld1     {v0.4s, v1.4s}, [x18], #32  // w2

    fmla    v16.4s, v0.4s, v3.s[3]      // out-1l: w2*inp2
    fmla    v17.4s, v1.4s, v3.s[3]      // out-1h: w2*inp2
    fmla    v19.4s, v1.4s, v4.s[3]      // out-2h: w2*inp3
    fmla    v18.4s, v0.4s, v4.s[3]      // out-2l: w2*inp3
    fmla    v20.4s, v0.4s, v5.s[3]      // out-3l: w2*inp4
    fmla    v21.4s, v1.4s, v5.s[3]      // out-3h: w2*inp4
    fmla    v23.4s, v1.4s, v6.s[3]      // out-4h: w2*inp5
    fmla    v22.4s, v0.4s, v6.s[3]      // out-4l: w2*inp5
    fmla    v24.4s, v0.4s, v7.s[3]      // out-5l: w2*inp6
    fmla    v25.4s, v1.4s, v7.s[3]      // out-5h: w2*inp6
    fmla    v27.4s, v1.4s, v8.s[3]      // out-6h: w2*inp7
    fmla    v26.4s, v0.4s, v8.s[3]      // out-6l: w2*inp7
    fmla    v28.4s, v0.4s, v9.s[3]      // out-7l: w2*inp8
    fmla    v29.4s, v1.4s, v9.s[3]      // out-7h: w2*inp8
    fmla    v31.4s, v1.4s, v10.s[3]     // out-8h: w2*inp9
    fmla    v30.4s, v0.4s, v10.s[3]     // out-8l: w2*inp9

    ld1     {v0.4s, v1.4s}, [x19], #32  // w3

    fmla    v16.4s, v0.4s, v4.s[3]      // out-1l: w3*inp3
    fmla    v17.4s, v1.4s, v4.s[3]      // out-1h: w3*inp3
    fmla    v19.4s, v1.4s, v5.s[3]      // out-2h: w3*inp4
    fmla    v18.4s, v0.4s, v5.s[3]      // out-2l: w3*inp4
    fmla    v20.4s, v0.4s, v6.s[3]      // out-3l: w3*inp5
    fmla    v21.4s, v1.4s, v6.s[3]      // out-3h: w3*inp5
    fmla    v23.4s, v1.4s, v7.s[3]      // out-4h: w3*inp6
    fmla    v22.4s, v0.4s, v7.s[3]      // out-4l: w3*inp6
    fmla    v24.4s, v0.4s, v8.s[3]      // out-5l: w3*inp7
    fmla    v25.4s, v1.4s, v8.s[3]      // out-5h: w3*inp7
    fmla    v27.4s, v1.4s, v9.s[3]      // out-6h: w3*inp8
    fmla    v26.4s, v0.4s, v9.s[3]      // out-6l: w3*inp8
    fmla    v28.4s, v0.4s, v10.s[3]     // out-7l: w3*inp9
    fmla    v29.4s, v1.4s, v10.s[3]     // out-7h: w3*inp9
    fmla    v31.4s, v1.4s, v11.s[3]     // out-8h: w3*inp10
    fmla    v30.4s, v0.4s, v11.s[3]     // out-8l: w3*inp10

    subs x22, x22, #4
    bgt ic_loop

    adds     x7,  x7,  x5
    adds     x8,  x8,  x5
    adds     x9,  x9,  x5
    adds     x10, x10, x5
    adds     x11, x11, x5
    adds     x12, x12, x5
    adds     x13, x13, x5
    adds     x14, x14, x5
    adds     x15, x15, x5
    adds     x16, x16, x5

    add     x17, x17, x21
    add     x18, x18, x21
    add     x19, x19, x21

    subs x20, x20, #1
    bgt kernel_loop

    // store outputs


    st1 {v16.4s, v17.4s}, [x2]
    add x2, x2, x3

    st1 {v18.4s, v19.4s}, [x2]
    add x2, x2, x3

    st1 {v20.4s, v21.4s}, [x2]
    add x2, x2, x3

    st1 {v22.4s, v23.4s}, [x2]
    add x2, x2, x3

    st1 {v24.4s, v25.4s}, [x2]
    add x2, x2, x3

    st1 {v26.4s, v27.4s}, [x2]
    add x2, x2, x3

    st1 {v28.4s, v29.4s}, [x2]
    add x2, x2, x3

    st1 {v30.4s, v31.4s}, [x2]

    ldr x22, [sp, #96]
    ldp x20, x21, [sp, #80]
    ldp x18, x19, [sp, #64]
    ldp q10, q11, [sp, #32]
    ldp q8, q9, [sp, #0]
    add sp, sp, #112

    ret
