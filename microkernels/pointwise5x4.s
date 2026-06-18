.global point_wise_bias_ic16oc4
.type point_wise_bias_ic16oc4, %function



point_wise_bias_ic16oc4:
    // x0: input address
    // x1: weights address
    // x2: bias address
    // x3: output address
    // x4: SIZE
    // x5: output gap

    ld1 {v16.4s, v17.4s, v18.4s, v19.4s}, [x1], #64     // oc0123 ic0-1-2-3
    ld1 {v20.4s, v21.4s, v22.4s, v23.4s}, [x1], #64     // oc0123 ic4-5-6-7
    ld1 {v24.4s, v25.4s, v26.4s, v27.4s}, [x1], #64     // oc0123 ic8-9-10-11
    ld1 {v28.4s, v29.4s, v30.4s, v31.4s}, [x1], #64     // oc0123 ic12-13-14-15

    ld1     {v5.4s}, [x2]       // load bias
    mul x10, x4, x4
.hw_loop:
    mov     v4.16b, v5.16b      // sum = bias

    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x0], #64
    fmla    v4.4s, v16.4s, v0.s[0]
    fmla    v4.4s, v17.4s, v0.s[1]
    fmla    v4.4s, v18.4s, v0.s[2]
    fmla    v4.4s, v19.4s, v0.s[3]
    fmla    v4.4s, v20.4s, v1.s[0]
    fmla    v4.4s, v21.4s, v1.s[1]
    fmla    v4.4s, v22.4s, v1.s[2]
    fmla    v4.4s, v23.4s, v1.s[3]
    fmla    v4.4s, v24.4s, v2.s[0]
    fmla    v4.4s, v25.4s, v2.s[1]
    fmla    v4.4s, v26.4s, v2.s[2]
    fmla    v4.4s, v27.4s, v2.s[3]
    fmla    v4.4s, v28.4s, v3.s[0]
    fmla    v4.4s, v29.4s, v3.s[1]
    fmla    v4.4s, v30.4s, v3.s[2]
    fmla    v4.4s, v31.4s, v3.s[3]

    st1     {v4.4s}, [x3]
    add x3, x3, x5

    subs x10, x10, #1
    bgt .hw_loop

    ret
