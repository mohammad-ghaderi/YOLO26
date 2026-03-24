.global conv_direct_3x3_int8_4x16_ic3_v9
.type conv_direct_3x3_int8_4x16_ic3_v9, %function
// supporting stride, ic = 3

// unused registers : x11..14, x18..31

conv_direct_3x3_int8_4x16_ic3_v9:

    // x0 = input
    // x1 = weights
    // x2 = output
    // x3 = output_stride
    // x4 = IC
    // x5 = layer_stride
    // x6 = kernel_stride

    movi v16.4s, #0
    movi v17.4s, #0
    movi v18.4s, #0
    movi v19.4s, #0

    movi v20.4s, #0
    movi v21.4s, #0
    movi v22.4s, #0
    movi v23.4s, #0

    movi v24.4s, #0
    movi v25.4s, #0
    movi v26.4s, #0
    movi v27.4s, #0

    movi v28.4s, #0
    movi v29.4s, #0
    movi v30.4s, #0
    movi v31.4s, #0

    mov x8, x0
    add x9, x8, #16

    mov w15, #3             // ky idx
kernel_loop:

    // load inputs

    ld1         {v6.16b}, [x8]
    ld1         {v7.16b}, [x9]
    
    sxtl        v0.8h, v6.8b 
    sxtl2       v1.8h, v6.16b
    sxtl        v2.8h, v7.8b 
    sxtl2       v3.8h, v7.16b
    
    // load weights

    ldp         d4, d5, [x1], 16                // # w1
    sxtl        v4.8h, v4.8b
    sxtl        v5.8h, v5.8b
    
    smlal       v16.4s, v4.4h, v0.h[0]
    smlal2      v17.4s, v4.8h, v0.h[0]
    smlal       v18.4s, v5.4h, v0.h[0]
    smlal2      v19.4s, v5.8h, v0.h[0]
    smlal       v20.4s, v4.4h, v0.h[6]
    smlal2      v21.4s, v4.8h, v0.h[6]
    smlal       v22.4s, v5.4h, v0.h[6]
    smlal2      v23.4s, v5.8h, v0.h[6]
    smlal       v24.4s, v4.4h, v1.h[4]
    smlal2      v25.4s, v4.8h, v1.h[4]
    smlal       v26.4s, v5.4h, v1.h[4]
    smlal2      v27.4s, v5.8h, v1.h[4]
    smlal       v28.4s, v4.4h, v2.h[2]
    smlal2      v29.4s, v4.8h, v2.h[2]
    smlal       v30.4s, v5.4h, v2.h[2]
    smlal2      v31.4s, v5.8h, v2.h[2]

    ldp         d4, d5, [x1], 16                // # w2
    sxtl        v4.8h, v4.8b
    sxtl        v5.8h, v5.8b


    smlal       v16.4s, v4.4h, v0.h[1]
    smlal2      v17.4s, v4.8h, v0.h[1]
    smlal       v18.4s, v5.4h, v0.h[1]
    smlal2      v19.4s, v5.8h, v0.h[1]
    smlal       v20.4s, v4.4h, v0.h[7]
    smlal2      v21.4s, v4.8h, v0.h[7]
    smlal       v22.4s, v5.4h, v0.h[7]
    smlal2      v23.4s, v5.8h, v0.h[7]
    smlal       v24.4s, v4.4h, v1.h[5]
    smlal2      v25.4s, v4.8h, v1.h[5]
    smlal       v26.4s, v5.4h, v1.h[5]
    smlal2      v27.4s, v5.8h, v1.h[5]
    smlal       v28.4s, v4.4h, v2.h[3]
    smlal2      v29.4s, v4.8h, v2.h[3]
    smlal       v30.4s, v5.4h, v2.h[3]
    smlal2      v31.4s, v5.8h, v2.h[3]

    ldp         d4, d5, [x1], 16                // # w3
    sxtl        v4.8h, v4.8b
    sxtl        v5.8h, v5.8b

    smlal       v16.4s, v4.4h, v0.h[2]
    smlal2      v17.4s, v4.8h, v0.h[2]
    smlal       v18.4s, v5.4h, v0.h[2]
    smlal2      v19.4s, v5.8h, v0.h[2]
    smlal       v20.4s, v4.4h, v1.h[0]
    smlal2      v21.4s, v4.8h, v1.h[0]
    smlal       v22.4s, v5.4h, v1.h[0]
    smlal2      v23.4s, v5.8h, v1.h[0]
    smlal       v24.4s, v4.4h, v1.h[6]
    smlal2      v25.4s, v4.8h, v1.h[6]
    smlal       v26.4s, v5.4h, v1.h[6]
    smlal2      v27.4s, v5.8h, v1.h[6]
    smlal       v28.4s, v4.4h, v2.h[4]
    smlal2      v29.4s, v4.8h, v2.h[4]
    smlal       v30.4s, v5.4h, v2.h[4]
    smlal2      v31.4s, v5.8h, v2.h[4]

    ldp         d4, d5, [x1], 16                // # w4
    sxtl        v4.8h, v4.8b
    sxtl        v5.8h, v5.8b

    smlal       v16.4s, v4.4h, v0.h[3]
    smlal2      v17.4s, v4.8h, v0.h[3]
    smlal       v18.4s, v5.4h, v0.h[3]
    smlal2      v19.4s, v5.8h, v0.h[3]
    smlal       v20.4s, v4.4h, v1.h[1]
    smlal2      v21.4s, v4.8h, v1.h[1]
    smlal       v22.4s, v5.4h, v1.h[1]
    smlal2      v23.4s, v5.8h, v1.h[1]
    smlal       v24.4s, v4.4h, v1.h[7]
    smlal2      v25.4s, v4.8h, v1.h[7]
    smlal       v26.4s, v5.4h, v1.h[7]
    smlal2      v27.4s, v5.8h, v1.h[7]
    smlal       v28.4s, v4.4h, v2.h[5]
    smlal2      v29.4s, v4.8h, v2.h[5]
    smlal       v30.4s, v5.4h, v2.h[5]
    smlal2      v31.4s, v5.8h, v2.h[5]

    ldp         d4, d5, [x1], 16                // # w5
    sxtl        v4.8h, v4.8b
    sxtl        v5.8h, v5.8b

    smlal       v16.4s, v4.4h, v0.h[4]
    smlal2      v17.4s, v4.8h, v0.h[4]
    smlal       v18.4s, v5.4h, v0.h[4]
    smlal2      v19.4s, v5.8h, v0.h[4]
    smlal       v20.4s, v4.4h, v1.h[2]
    smlal2      v21.4s, v4.8h, v1.h[2]
    smlal       v22.4s, v5.4h, v1.h[2]
    smlal2      v23.4s, v5.8h, v1.h[2]
    smlal       v24.4s, v4.4h, v2.h[0]
    smlal2      v25.4s, v4.8h, v2.h[0]
    smlal       v26.4s, v5.4h, v2.h[0]
    smlal2      v27.4s, v5.8h, v2.h[0]
    smlal       v28.4s, v4.4h, v2.h[6]
    smlal2      v29.4s, v4.8h, v2.h[6]
    smlal       v30.4s, v5.4h, v2.h[6]
    smlal2      v31.4s, v5.8h, v2.h[6]

    ldp         d4, d5, [x1], 16                // # w6
    sxtl        v4.8h, v4.8b
    sxtl        v5.8h, v5.8b

    smlal       v16.4s, v4.4h, v0.h[5]
    smlal2      v17.4s, v4.8h, v0.h[5]
    smlal       v18.4s, v5.4h, v0.h[5]
    smlal2      v19.4s, v5.8h, v0.h[5]
    smlal       v20.4s, v4.4h, v1.h[3]
    smlal2      v21.4s, v4.8h, v1.h[3]
    smlal       v22.4s, v5.4h, v1.h[3]
    smlal2      v23.4s, v5.8h, v1.h[3]
    smlal       v24.4s, v4.4h, v2.h[1]
    smlal2      v25.4s, v4.8h, v2.h[1]
    smlal       v26.4s, v5.4h, v2.h[1]
    smlal2      v27.4s, v5.8h, v2.h[1]
    smlal       v28.4s, v4.4h, v2.h[7]
    smlal2      v29.4s, v4.8h, v2.h[7]
    smlal       v30.4s, v5.4h, v2.h[7]
    smlal2      v31.4s, v5.8h, v2.h[7]

    ldp         d4, d5, [x1], 16                // # w7
    sxtl        v4.8h, v4.8b
    sxtl        v5.8h, v5.8b

    smlal       v16.4s, v4.4h, v0.h[6]
    smlal2      v17.4s, v4.8h, v0.h[6]
    smlal       v18.4s, v5.4h, v0.h[6]
    smlal2      v19.4s, v5.8h, v0.h[6]
    smlal       v20.4s, v4.4h, v1.h[4]
    smlal2      v21.4s, v4.8h, v1.h[4]
    smlal       v22.4s, v5.4h, v1.h[4]
    smlal2      v23.4s, v5.8h, v1.h[4]
    smlal       v24.4s, v4.4h, v2.h[2]
    smlal2      v25.4s, v4.8h, v2.h[2]
    smlal       v26.4s, v5.4h, v2.h[2]
    smlal2      v27.4s, v5.8h, v2.h[2]
    smlal       v28.4s, v4.4h, v3.h[0]
    smlal2      v29.4s, v4.8h, v3.h[0]
    smlal       v30.4s, v5.4h, v3.h[0]
    smlal2      v31.4s, v5.8h, v3.h[0]

    ldp         d4, d5, [x1], 16                // # w8
    sxtl        v4.8h, v4.8b
    sxtl        v5.8h, v5.8b

    smlal       v16.4s, v4.4h, v0.h[7]
    smlal2      v17.4s, v4.8h, v0.h[7]
    smlal       v18.4s, v5.4h, v0.h[7]
    smlal2      v19.4s, v5.8h, v0.h[7]
    smlal       v20.4s, v4.4h, v1.h[5]
    smlal2      v21.4s, v4.8h, v1.h[5]
    smlal       v22.4s, v5.4h, v1.h[5]
    smlal2      v23.4s, v5.8h, v1.h[5]
    smlal       v24.4s, v4.4h, v2.h[3]
    smlal2      v25.4s, v4.8h, v2.h[3]
    smlal       v26.4s, v5.4h, v2.h[3]
    smlal2      v27.4s, v5.8h, v2.h[3]
    smlal       v28.4s, v4.4h, v3.h[1]
    smlal2      v29.4s, v4.8h, v3.h[1]
    smlal       v30.4s, v5.4h, v3.h[1]
    smlal2      v31.4s, v5.8h, v3.h[1]

    ldp         d4, d5, [x1], 16                // # w9
    sxtl        v4.8h, v4.8b
    sxtl        v5.8h, v5.8b

    smlal       v16.4s, v4.4h, v1.h[0]
    smlal2      v17.4s, v4.8h, v1.h[0]
    smlal       v18.4s, v5.4h, v1.h[0]
    smlal2      v19.4s, v5.8h, v1.h[0]
    smlal       v20.4s, v4.4h, v1.h[6]
    smlal2      v21.4s, v4.8h, v1.h[6]
    smlal       v22.4s, v5.4h, v1.h[6]
    smlal2      v23.4s, v5.8h, v1.h[6]
    smlal       v24.4s, v4.4h, v2.h[4]
    smlal2      v25.4s, v4.8h, v2.h[4]
    smlal       v26.4s, v5.4h, v2.h[4]
    smlal2      v27.4s, v5.8h, v2.h[4]
    smlal       v28.4s, v4.4h, v3.h[2]
    smlal2      v29.4s, v4.8h, v3.h[2]
    smlal       v30.4s, v5.4h, v3.h[2]
    smlal2      v31.4s, v5.8h, v3.h[2]

    adds x8, x8, x5
    adds x9, x9, x5

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

    ret
