.global conv_igemm_3x3_int8_4x8_v1
.type conv_igemm_3x3_int8_4x8_v1, %function
// igemm no prefetch

// unused registers : x9..14, x17..31

conv_igemm_3x3_int8_4x8_v1:

    // x0 = indirection
    // x1 = weights
    // x2 = output
    // x3 = output_stride
    // x4 = IC

    movi v16.4s, #0
    movi v17.4s, #0
    movi v18.4s, #0
    movi v19.4s, #0
    movi v20.4s, #0
    movi v21.4s, #0
    movi v22.4s, #0
    movi v23.4s, #0

    mov w15, #9             // k idx
kernel_loop:

    ldr x5, [x0]            // pixel0
    ldr x6, [x0, 72]       // pixel1 (+ 9*8)
    ldr x7, [x0, 144]    // pixel2 (+ 18*8)
    ldr x8, [x0, 216]    // pixel3 (+ 27*8)

    mov x16, x4             // ic idx
ic_loop:
    // load inputs

    ld1         {v0.8b}, [x5], 8
    ld1         {v1.8b}, [x6], 8
    ld1         {v2.8b}, [x7], 8
    ld1         {v3.8b}, [x8], 8
    
    sxtl        v0.8h, v0.8b
    sxtl        v1.8h, v1.8b
    sxtl        v2.8h, v2.8b
    sxtl        v3.8h, v3.8b
    
    // load weights
    ldr         d4, [x1], 8
    sxtl        v4.8h, v4.8b

    smlal       v16.4s, v4.4h, v0.h[0]
    smlal2      v17.4s, v4.8h, v0.h[0]
    smlal       v18.4s, v4.4h, v1.h[0]
    smlal2      v19.4s, v4.8h, v1.h[0]
    smlal       v20.4s, v4.4h, v2.h[0]
    smlal2      v21.4s, v4.8h, v2.h[0]
    smlal       v22.4s, v4.4h, v3.h[0]
    smlal2      v23.4s, v4.8h, v3.h[0]

    ldr         d4, [x1], 8
    sxtl        v4.8h, v4.8b

    smlal       v16.4s, v4.4h, v0.h[1]
    smlal2      v17.4s, v4.8h, v0.h[1]
    smlal       v18.4s, v4.4h, v1.h[1]
    smlal2      v19.4s, v4.8h, v1.h[1]
    smlal       v20.4s, v4.4h, v2.h[1]
    smlal2      v21.4s, v4.8h, v2.h[1]
    smlal       v22.4s, v4.4h, v3.h[1]
    smlal2      v23.4s, v4.8h, v3.h[1]

    ldr         d4, [x1], 8
    sxtl        v4.8h, v4.8b

    smlal       v16.4s, v4.4h, v0.h[2]
    smlal2      v17.4s, v4.8h, v0.h[2]
    smlal       v18.4s, v4.4h, v1.h[2]
    smlal2      v19.4s, v4.8h, v1.h[2]
    smlal       v20.4s, v4.4h, v2.h[2]
    smlal2      v21.4s, v4.8h, v2.h[2]
    smlal       v22.4s, v4.4h, v3.h[2]
    smlal2      v23.4s, v4.8h, v3.h[2]

    ldr         d4, [x1], 8
    sxtl        v4.8h, v4.8b

    smlal       v16.4s, v4.4h, v0.h[3]
    smlal2      v17.4s, v4.8h, v0.h[3]
    smlal       v18.4s, v4.4h, v1.h[3]
    smlal2      v19.4s, v4.8h, v1.h[3]
    smlal       v20.4s, v4.4h, v2.h[3]
    smlal2      v21.4s, v4.8h, v2.h[3]
    smlal       v22.4s, v4.4h, v3.h[3]
    smlal2      v23.4s, v4.8h, v3.h[3]

    ldr         d4, [x1], 8
    sxtl        v4.8h, v4.8b

    smlal       v16.4s, v4.4h, v0.h[4]
    smlal2      v17.4s, v4.8h, v0.h[4]
    smlal       v18.4s, v4.4h, v1.h[4]
    smlal2      v19.4s, v4.8h, v1.h[4]
    smlal       v20.4s, v4.4h, v2.h[4]
    smlal2      v21.4s, v4.8h, v2.h[4]
    smlal       v22.4s, v4.4h, v3.h[4]
    smlal2      v23.4s, v4.8h, v3.h[4]

    ldr         d4, [x1], 8
    sxtl        v4.8h, v4.8b

    smlal       v16.4s, v4.4h, v0.h[5]
    smlal2      v17.4s, v4.8h, v0.h[5]
    smlal       v18.4s, v4.4h, v1.h[5]
    smlal2      v19.4s, v4.8h, v1.h[5]
    smlal       v20.4s, v4.4h, v2.h[5]
    smlal2      v21.4s, v4.8h, v2.h[5]
    smlal       v22.4s, v4.4h, v3.h[5]
    smlal2      v23.4s, v4.8h, v3.h[5]

    ldr         d4, [x1], 8
    sxtl        v4.8h, v4.8b

    smlal       v16.4s, v4.4h, v0.h[6]
    smlal2      v17.4s, v4.8h, v0.h[6]
    smlal       v18.4s, v4.4h, v1.h[6]
    smlal2      v19.4s, v4.8h, v1.h[6]
    smlal       v20.4s, v4.4h, v2.h[6]
    smlal2      v21.4s, v4.8h, v2.h[6]
    smlal       v22.4s, v4.4h, v3.h[6]
    smlal2      v23.4s, v4.8h, v3.h[6]

    ldr         d4, [x1], 8
    sxtl        v4.8h, v4.8b

    smlal       v16.4s, v4.4h, v0.h[7]
    smlal2      v17.4s, v4.8h, v0.h[7]
    smlal       v18.4s, v4.4h, v1.h[7]
    smlal2      v19.4s, v4.8h, v1.h[7]
    smlal       v20.4s, v4.4h, v2.h[7]
    smlal2      v21.4s, v4.8h, v2.h[7]
    smlal       v22.4s, v4.4h, v3.h[7]
    smlal2      v23.4s, v4.8h, v3.h[7]

    subs x16, x16, #8
    bgt ic_loop

    adds x0, x0, #8
    subs x15, x15, #1
    bgt kernel_loop

    // store outputs

    st1 {v16.4s}, [x2], 16
    st1 {v17.4s}, [x2], 16

    add x2, x2, x3

    st1 {v18.4s}, [x2], 16
    st1 {v19.4s}, [x2], 16

    add x2, x2, x3

    st1 {v20.4s}, [x2], 16
    st1 {v21.4s}, [x2], 16

    add x2, x2, x3

    st1 {v22.4s}, [x2], 16
    st1 {v23.4s}, [x2], 16

    ret
