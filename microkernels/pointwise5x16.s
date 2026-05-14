.global point_wise_5x16
.type point_wise_5x16, %function

point_wise_5x16:
    // x0: input address
    // x1: weights address
    // x2: output address
    // x3: IC
    // x4: OC
    // x5: output stride

    sub     sp, sp, #32
    stp     q8, q9, [sp]

    movi    v0.4s, #0
    movi    v1.4s, #0
    movi    v2.4s, #0
    movi    v3.4s, #0

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

    lsl     x10, x3, #2

    mov     x11, x0             // inp 1
    add     x12, x11, x10       // inp 2
    add     x13, x12, x10       // inp 3
    add     x14, x13, x10       // inp 4
    add     x15, x14, x10       // inp 5


    mov x9, x3
.ic_loop:

    ld1     {v4.4s}, [x11], #16
    ld1     {v5.4s}, [x12], #16
    ld1     {v6.4s}, [x13], #16
    ld1     {v7.4s}, [x14], #16
    ld1     {v8.4s}, [x15], #16

    ld1     {v9.4s}, [x1], #16     // weights oc[0,3]

    fmla    v0.4s,  V9.4S,v4.S[0]
    fmla    v16.4s, V9.4S, v5.S[0]
    fmla    v20.4s, V9.4S, v6.S[0]
    fmla    v24.4s, V9.4S, v7.S[0]
    fmla    v28.4s, V9.4S, v8.S[0]

    ld1     {v9.4s}, [x1], #16     // weights oc[4,7]

    fmla    v1.4s,  V9.4S,v4.S[0]
    fmla    v17.4s, V9.4S, v5.S[0]
    fmla    v21.4s, V9.4S, v6.S[0]
    fmla    v25.4s, V9.4S, v7.S[0]
    fmla    v29.4s, V9.4S, v8.S[0]

    ld1     {v9.4s}, [x1], #16     // weights oc[8,11]

    fmla    v2.4s,  V9.4S,v4.S[0]
    fmla    v18.4s, V9.4S, v5.S[0]
    fmla    v22.4s, V9.4S, v6.S[0]
    fmla    v26.4s, V9.4S, v7.S[0]
    fmla    v30.4s, V9.4S, v8.S[0]

    ld1     {v9.4s}, [x1], #16     // weights oc[12, 15]

    fmla    v3.4s,  V9.4S,v4.S[0]
    fmla    v19.4s, V9.4S, v5.S[0]
    fmla    v23.4s, V9.4S, v6.S[0]
    fmla    v27.4s, V9.4S, v7.S[0]
    fmla    v31.4s, V9.4S, v8.S[0]


    ld1     {v9.4s}, [x1], #16     // weights oc[0,3]

    fmla    v0.4s,  V9.4S,v4.S[1]
    fmla    v16.4s, V9.4S, v5.S[1]
    fmla    v20.4s, V9.4S, v6.S[1]
    fmla    v24.4s, V9.4S, v7.S[1]
    fmla    v28.4s, V9.4S, v8.S[1]

    ld1     {v9.4s}, [x1], #16     // weights oc[4,7]

    fmla    v1.4s,  V9.4S,v4.S[1]
    fmla    v17.4s, V9.4S, v5.S[1]
    fmla    v21.4s, V9.4S, v6.S[1]
    fmla    v25.4s, V9.4S, v7.S[1]
    fmla    v29.4s, V9.4S, v8.S[1]

    ld1     {v9.4s}, [x1], #16     // weights oc[8,11]

    fmla    v2.4s,  V9.4S,v4.S[1]
    fmla    v18.4s, V9.4S, v5.S[1]
    fmla    v22.4s, V9.4S, v6.S[1]
    fmla    v26.4s, V9.4S, v7.S[1]
    fmla    v30.4s, V9.4S, v8.S[1]

    ld1     {v9.4s}, [x1], #16     // weights oc[12, 15]

    fmla    v3.4s,  V9.4S,v4.S[1]
    fmla    v19.4s, V9.4S, v5.S[1]
    fmla    v23.4s, V9.4S, v6.S[1]
    fmla    v27.4s, V9.4S, v7.S[1]
    fmla    v31.4s, V9.4S, v8.S[1]
    

    ld1     {v9.4s}, [x1], #16     // weights oc[0,3]

    fmla    v0.4s,  V9.4S,v4.S[2]
    fmla    v16.4s, V9.4S, v5.S[2]
    fmla    v20.4s, V9.4S, v6.S[2]
    fmla    v24.4s, V9.4S, v7.S[2]
    fmla    v28.4s, V9.4S, v8.S[2]

    ld1     {v9.4s}, [x1], #16     // weights oc[4,7]

    fmla    v1.4s,  V9.4S,v4.S[2]
    fmla    v17.4s, V9.4S, v5.S[2]
    fmla    v21.4s, V9.4S, v6.S[2]
    fmla    v25.4s, V9.4S, v7.S[2]
    fmla    v29.4s, V9.4S, v8.S[2]

    ld1     {v9.4s}, [x1], #16     // weights oc[8,11]

    fmla    v2.4s,  V9.4S,v4.S[2]
    fmla    v18.4s, V9.4S, v5.S[2]
    fmla    v22.4s, V9.4S, v6.S[2]
    fmla    v26.4s, V9.4S, v7.S[2]
    fmla    v30.4s, V9.4S, v8.S[2]

    ld1     {v9.4s}, [x1], #16     // weights oc[12, 15]

    fmla    v3.4s,  V9.4S,v4.S[2]
    fmla    v19.4s, V9.4S, v5.S[2]
    fmla    v23.4s, V9.4S, v6.S[2]
    fmla    v27.4s, V9.4S, v7.S[2]
    fmla    v31.4s, V9.4S, v8.S[2]


    ld1     {v9.4s}, [x1], #16     // weights oc[0,3]

    fmla    v0.4s,  V9.4S,v4.S[3]
    fmla    v16.4s, V9.4S, v5.S[3]
    fmla    v20.4s, V9.4S, v6.S[3]
    fmla    v24.4s, V9.4S, v7.S[3]
    fmla    v28.4s, V9.4S, v8.S[3]

    ld1     {v9.4s}, [x1], #16     // weights oc[4,7]

    fmla    v1.4s,  V9.4S,v4.S[3]
    fmla    v17.4s, V9.4S, v5.S[3]
    fmla    v21.4s, V9.4S, v6.S[3]
    fmla    v25.4s, V9.4S, v7.S[3]
    fmla    v29.4s, V9.4S, v8.S[3]

    ld1     {v9.4s}, [x1], #16     // weights oc[8,11]

    fmla    v2.4s,  V9.4S,v4.S[3]
    fmla    v18.4s, V9.4S, v5.S[3]
    fmla    v22.4s, V9.4S, v6.S[3]
    fmla    v26.4s, V9.4S, v7.S[3]
    fmla    v30.4s, V9.4S, v8.S[3]

    ld1     {v9.4s}, [x1], #16     // weights oc[12, 15]

    fmla    v3.4s,  V9.4S,v4.S[3]
    fmla    v19.4s, V9.4S, v5.S[3]
    fmla    v23.4s, V9.4S, v6.S[3]
    fmla    v27.4s, V9.4S, v7.S[3]
    fmla    v31.4s, V9.4S, v8.S[3]


    subs x9, x9, #4
    bgt .ic_loop

    st1     {v0.4s}, [x2], #16
    st1     {v1.4s}, [x2], #16
    st1     {v2.4s}, [x2], #16
    st1     {v3.4s}, [x2], #16

    add     x2, x2, x5

    st1     {v16.4s}, [x2], #16
    st1     {v17.4s}, [x2], #16
    st1     {v18.4s}, [x2], #16
    st1     {v19.4s}, [x2], #16

    add     x2, x2, x5

    st1     {v20.4s}, [x2], #16
    st1     {v21.4s}, [x2], #16
    st1     {v22.4s}, [x2], #16
    st1     {v23.4s}, [x2], #16

    add     x2, x2, x5
    
    st1     {v24.4s}, [x2], #16
    st1     {v25.4s}, [x2], #16
    st1     {v26.4s}, [x2], #16
    st1     {v27.4s}, [x2], #16

    add     x2, x2, x5
    
    st1     {v28.4s}, [x2], #16
    st1     {v29.4s}, [x2], #16
    st1     {v30.4s}, [x2], #16
    st1     {v31.4s}, [x2], #16

    ldp     q8, q9, [sp]
    add     sp, sp, #32

    ret
