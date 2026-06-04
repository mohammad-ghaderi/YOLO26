.global maxpool_3_5x5
.type maxpool_3_5x5, %function

maxpool_3_5x5:
    // x0: input address
    // x1: gap
    // x2: next column distance
    // x3: next row distance


    add x4, x2, x2 // next two columns distance
    mov x5, x0     // base of start

    mov x1, #128
.oc_loop:

    add x10, x5, x4     // x10: (0, 2)
    add x11, x10, x3    // x11: (1, 2)
    add x12, x11, x3    // x12: (2, 2)
    add x13, x12, x3    // x13: (3, 2)
    add x14, x13, x3    // x14: (4, 2)

    add x6, x5, #512       // out row 0
    add x7, x6, x3          // out row 1  
    add x8, x7, x3          // out row 2

    // v26, v27, v28, v29, v30, v31: are aux for loading

    ld1     {v2.4s}, [x10]
    ld1     {v28.4s}, [x11]
    fmax    v2.4s, v2.4s, v28.4s
    ld1     {v29.4s}, [x12]
    fmax    v2.4s, v2.4s, v29.4s
    ld1     {v30.4s}, [x13]
    fmax    v18.4s, v2.4s, v30.4s
    ld1     {v31.4s}, [x14]
    fmax    v23.4s, v18.4s, v31.4s

    subs x10, x10, x2    // prev column
    subs x11, x11, x2    // prev column
    subs x12, x12, x2    // prev column
    subs x13, x13, x2    // prev column
    subs x14, x14, x2    // prev column

    ld1     {v28.4s}, [x10]
    fmax    v1.4s, v2.4s, v28.4s
    ld1     {v29.4s}, [x11]
    fmax    v1.4s, v1.4s, v29.4s
    ld1     {v30.4s}, [x12]
    fmax    v1.4s, v1.4s, v30.4s

    ld1     {v30.4s}, [x13]
    fmax    v17.4s, v1.4s, v18.4s
    fmax    v17.4s, v17.4s, v30.4s
    ld1     {v31.4s}, [x14]
    fmax    v22.4s, v17.4s, v23.4s
    fmax    v22.4s, v22.4s, v31.4s

    subs x10, x10, x2    // prev column
    subs x11, x11, x2    // prev column
    subs x12, x12, x2    // prev column
    subs x13, x13, x2    // prev column
    subs x14, x14, x2    // prev column

    ld1     {v28.4s}, [x10]
    fmax    v0.4s, v1.4s, v28.4s
    ld1     {v29.4s}, [x11]
    fmax    v0.4s, v0.4s, v29.4s
    ld1     {v30.4s}, [x12]
    fmax    v0.4s, v0.4s, v30.4s

    ld1     {v30.4s}, [x13]
    fmax    v16.4s, v0.4s, v17.4s
    fmax    v16.4s, v16.4s, v30.4s
    ld1     {v31.4s}, [x14]
    fmax    v21.4s, v16.4s, v22.4s
    fmax    v21.4s, v21.4s, v31.4s

    st1     {v0.4s}, [x6]           // out(0,0)
    st1     {v16.4s}, [x7]          // out(1,0)
    st1     {v21.4s}, [x8]          // out(2,0)

    add x6, x6, x2
    add x7, x7, x2
    add x8, x8, x2

    add x10, x5, x4
    add x10, x10, x2
    add x11, x10, x3
    add x12, x11, x3
    add x13, x12, x3
    add x14, x13, x3

    ld1     {v3.4s}, [x10]
    ld1     {v28.4s}, [x11]
    fmax    v3.4s, v3.4s, v28.4s
    ld1     {v29.4s}, [x12]
    fmax    v3.4s, v3.4s, v29.4s
    fmax    v2.4s, v2.4s, v3.4s
    fmax    v1.4s, v1.4s, v3.4s
    fmax    v0.4s, v0.4s, v3.4s
    ld1     {v30.4s}, [x13]
    fmax    v19.4s, v3.4s, v30.4s
    fmax    v18.4s, v18.4s, v19.4s
    fmax    v17.4s, v17.4s, v19.4s
    fmax    v16.4s, v16.4s, v19.4s
    ld1     {v31.4s}, [x14]
    fmax    v24.4s, v19.4s, v31.4s
    fmax    v23.4s, v23.4s, v24.4s
    fmax    v22.4s, v22.4s, v24.4s
    fmax    v21.4s, v21.4s, v24.4s

    st1     {v0.4s}, [x6]           // out(0,1)
    st1     {v16.4s}, [x7]          // out(1,1)
    st1     {v21.4s}, [x8]          // out(2,1)


    mov x15, #16
.w_loop:
    add x6, x6, x2
    add x7, x7, x2
    add x8, x8, x2

    add x10, x10, x2
    add x11, x11, x2
    add x12, x12, x2
    add x13, x13, x2
    add x14, x14, x2

    ld1     {v4.4s}, [x10]
    ld1     {v28.4s}, [x11]
    fmax    v4.4s, v4.4s, v28.4s
    ld1     {v29.4s}, [x12]
    fmax    v4.4s, v4.4s, v29.4s
    fmax    v3.4s, v3.4s, v4.4s
    fmax    v2.4s, v2.4s, v4.4s
    fmax    v1.4s, v1.4s, v4.4s
    fmax    v0.4s, v0.4s, v4.4s
    ld1     {v30.4s}, [x13]
    fmax    v20.4s, v4.4s, v30.4s
    fmax    v19.4s, v19.4s, v20.4s
    fmax    v18.4s, v18.4s, v20.4s
    fmax    v17.4s, v17.4s, v20.4s
    fmax    v16.4s, v16.4s, v20.4s
    ld1     {v31.4s}, [x14]
    fmax    v25.4s, v20.4s, v31.4s
    fmax    v24.4s, v24.4s, v25.4s
    fmax    v23.4s, v23.4s, v25.4s
    fmax    v22.4s, v22.4s, v25.4s
    fmax    v21.4s, v21.4s, v25.4s

    st1     {v0.4s}, [x6]           // out(0,2)
    st1     {v16.4s}, [x7]          // out(1,2)
    st1     {v21.4s}, [x8]          // out(2,2)

    mov     v0.16b, v1.16b
    mov     v16.16b, v17.16b
    mov     v21.16b, v22.16b
    mov     v1.16b, v2.16b
    mov     v17.16b, v18.16b
    mov     v22.16b, v23.16b
    mov     v2.16b, v3.16b
    mov     v18.16b, v19.16b
    mov     v23.16b, v24.16b
    mov     v3.16b, v4.16b
    mov     v19.16b, v20.16b
    mov     v24.16b, v25.16b

    subs x15, x15, #1
    bgt .w_loop

    add x6, x6, x2
    add x7, x7, x2
    add x8, x8, x2

    st1     {v0.4s}, [x6] 
    st1     {v16.4s}, [x7]
    st1     {v21.4s}, [x8]

    add x6, x6, x2
    add x7, x7, x2
    add x8, x8, x2

    st1     {v1.4s}, [x6] 
    st1     {v17.4s}, [x7]
    st1     {v22.4s}, [x8]

    add x5, x5, #16
    subs x1, x1, #4
    bgt .oc_loop






    add x4, x0, x3

// MAIN 
    mov x9, #5
.h_main_loop:
    mov x5, x4     // base of start

    mov x1, #128
.oc_main_loop:

    add x10, x5, x2     
    add x10, x10, x2    // x10: (0, 2)
    add x11, x10, x3    // x11: (1, 2)
    add x12, x11, x3    // x12: (2, 2)
    add x13, x12, x3    // x13: (3, 2)
    add x14, x13, x3    // x14: (4, 2)
    add x15, x14, x3    // x15: (5, 2)
    add x16, x15, x3    // x16: (6, 2)

    add x6, x5, #512
    add x6, x6, x3
    add x6, x6, x3          // out row 0
    add x7, x6, x3          // out row 1  
    add x8, x7, x3          // out row 2

    // v26, v27, v28, v29, v30, v31: are aux for loading

    ld1     {v28.4s}, [x10]
    ld1     {v29.4s}, [x11]
    ld1     {v2.4s}, [x12]
    ld1     {v26.4s}, [x13]
    ld1     {v27.4s}, [x14]
    ld1     {v30.4s}, [x15]
    ld1     {v31.4s}, [x16]
    fmax    v2.4s, v2.4s, v26.4s
    fmax    v2.4s, v2.4s, v27.4s
    fmax    v18.4s, v2.4s, v30.4s
    fmax    v23.4s, v18.4s, v31.4s
    fmax    v18.4s, v18.4s, v29.4s
    fmax    v2.4s, v2.4s, v29.4s
    fmax    v2.4s, v2.4s, v28.4s

    subs x10, x10, x2    // prev column
    subs x11, x11, x2    // prev column
    subs x12, x12, x2    // prev column
    subs x13, x13, x2    // prev column
    subs x14, x14, x2    // prev column
    subs x15, x15, x2    // prev column
    subs x16, x16, x2    // prev column

    ld1     {v28.4s}, [x10]
    ld1     {v29.4s}, [x11]
    ld1     {v1.4s}, [x12]
    ld1     {v26.4s}, [x13]
    ld1     {v27.4s}, [x14]
    ld1     {v30.4s}, [x15]
    ld1     {v31.4s}, [x16]
    fmax    v1.4s, v1.4s, v26.4s
    fmax    v1.4s, v1.4s, v27.4s
    fmax    v17.4s, v1.4s, v30.4s
    fmax    v22.4s, v17.4s, v31.4s
    fmax    v17.4s, v17.4s, v29.4s
    fmax    v1.4s, v1.4s, v29.4s
    fmax    v1.4s, v1.4s, v28.4s
    fmax    v1.4s, v1.4s, v2.4s
    fmax    v17.4s, v17.4s, v18.4s
    fmax    v22.4s, v22.4s, v23.4s


    subs x10, x10, x2    // prev column
    subs x11, x11, x2    // prev column
    subs x12, x12, x2    // prev column
    subs x13, x13, x2    // prev column
    subs x14, x14, x2    // prev column
    subs x15, x15, x2    // prev column
    subs x16, x16, x2    // prev column
    
    ld1     {v28.4s}, [x10]
    ld1     {v29.4s}, [x11]
    ld1     {v0.4s}, [x12]
    ld1     {v26.4s}, [x13]
    ld1     {v27.4s}, [x14]
    ld1     {v30.4s}, [x15]
    ld1     {v31.4s}, [x16]
    fmax    v0.4s, v0.4s, v26.4s
    fmax    v0.4s, v0.4s, v27.4s
    fmax    v16.4s, v0.4s, v30.4s
    fmax    v21.4s, v16.4s, v31.4s
    fmax    v16.4s, v16.4s, v29.4s
    fmax    v0.4s, v0.4s, v29.4s
    fmax    v0.4s, v0.4s, v28.4s
    fmax    v0.4s, v0.4s, v1.4s
    fmax    v16.4s, v16.4s, v17.4s
    fmax    v21.4s, v21.4s, v22.4s

    st1     {v0.4s}, [x6]           // out(0,0)
    st1     {v16.4s}, [x7]          // out(1,0)
    st1     {v21.4s}, [x8]          // out(2,0)

    add x6, x6, x2
    add x7, x7, x2
    add x8, x8, x2

    add x10, x5, x2
    add x10, x10, x2
    add x10, x10, x2
    add x11, x10, x3
    add x12, x11, x3
    add x13, x12, x3
    add x14, x13, x3
    add x15, x14, x3
    add x16, x15, x3

    ld1     {v28.4s}, [x10]
    ld1     {v29.4s}, [x11]
    ld1     {v3.4s}, [x12]
    ld1     {v26.4s}, [x13]
    ld1     {v27.4s}, [x14]
    ld1     {v30.4s}, [x15]
    ld1     {v31.4s}, [x16]
    fmax    v3.4s, v3.4s, v26.4s
    fmax    v3.4s, v3.4s, v27.4s
    fmax    v19.4s, v3.4s, v30.4s
    fmax    v24.4s, v19.4s, v31.4s
    fmax    v19.4s, v19.4s, v29.4s
    fmax    v3.4s, v3.4s, v29.4s
    fmax    v3.4s, v3.4s, v28.4s
    fmax    v2.4s, v2.4s, v3.4s
    fmax    v1.4s, v1.4s, v3.4s
    fmax    v0.4s, v0.4s, v3.4s
    fmax    v18.4s, v18.4s, v19.4s
    fmax    v17.4s, v17.4s, v19.4s
    fmax    v16.4s, v16.4s, v19.4s
    fmax    v23.4s, v23.4s, v24.4s
    fmax    v22.4s, v22.4s, v24.4s
    fmax    v21.4s, v21.4s, v24.4s


    st1     {v0.4s}, [x6]           // out(0,1)
    st1     {v16.4s}, [x7]          // out(1,1)
    st1     {v21.4s}, [x8]          // out(2,1)
    
    mov x17, #16
.w_main_loop:
    add x6, x6, x2
    add x7, x7, x2
    add x8, x8, x2

    add x10, x10, x2
    add x11, x11, x2
    add x12, x12, x2
    add x13, x13, x2
    add x14, x14, x2
    add x15, x15, x2
    add x16, x16, x2

    ld1     {v28.4s}, [x10]
    ld1     {v29.4s}, [x11]
    ld1     {v4.4s}, [x12]
    ld1     {v26.4s}, [x13]
    ld1     {v27.4s}, [x14]
    ld1     {v30.4s}, [x15]
    ld1     {v31.4s}, [x16]
    fmax    v4.4s, v4.4s, v26.4s
    fmax    v4.4s, v4.4s, v27.4s
    fmax    v20.4s, v4.4s, v30.4s
    fmax    v25.4s, v20.4s, v31.4s
    fmax    v20.4s, v20.4s, v29.4s
    fmax    v4.4s, v4.4s, v29.4s
    fmax    v4.4s, v4.4s, v28.4s
    fmax    v3.4s, v3.4s, v4.4s
    fmax    v2.4s, v2.4s, v4.4s
    fmax    v1.4s, v1.4s, v4.4s
    fmax    v0.4s, v0.4s, v4.4s
    fmax    v19.4s, v19.4s, v20.4s
    fmax    v18.4s, v18.4s, v20.4s
    fmax    v17.4s, v17.4s, v20.4s
    fmax    v16.4s, v16.4s, v20.4s
    fmax    v24.4s, v24.4s, v25.4s
    fmax    v23.4s, v23.4s, v25.4s
    fmax    v22.4s, v22.4s, v25.4s
    fmax    v21.4s, v21.4s, v25.4s

    st1     {v0.4s}, [x6]           // out(0,2)
    st1     {v16.4s}, [x7]          // out(1,2)
    st1     {v21.4s}, [x8]          // out(2,2)

    mov     v0.16b, v1.16b
    mov     v16.16b, v17.16b
    mov     v21.16b, v22.16b
    mov     v1.16b, v2.16b
    mov     v17.16b, v18.16b
    mov     v22.16b, v23.16b
    mov     v2.16b, v3.16b
    mov     v18.16b, v19.16b
    mov     v23.16b, v24.16b
    mov     v3.16b, v4.16b
    mov     v19.16b, v20.16b
    mov     v24.16b, v25.16b

    subs x17, x17, #1
    bgt .w_main_loop

    add x6, x6, x2
    add x7, x7, x2
    add x8, x8, x2

    st1     {v0.4s}, [x6] 
    st1     {v16.4s}, [x7]
    st1     {v21.4s}, [x8]

    add x6, x6, x2
    add x7, x7, x2
    add x8, x8, x2

    st1     {v1.4s}, [x6] 
    st1     {v17.4s}, [x7]
    st1     {v22.4s}, [x8]

    add x5, x5, #16
    subs x1, x1, #4
    bgt .oc_main_loop

    add x4, x4, x3
    add x4, x4, x3
    add x4, x4, x3

    subs x9, x9, #1
    bgt .h_main_loop


    /// last two rows ///

    mov x5, x4

    mov x1, #128
.oc_last_loop:

    add x10, x5, x2
    add x10, x10, x2    // x10: (0, 2)
    add x11, x10, x3    // x11: (1, 2)
    add x12, x11, x3    // x12: (2, 2)
    add x13, x12, x3    // x13: (3, 2)

    add x6, x5, x3
    add x6, x6, x3
    add x6, x6, #512       // out row 0
    add x7, x6, x3          // out row 1  

    // v26, v27, v28, v29, v30, v31: are aux for loading

    ld1     {v2.4s}, [x10]
    ld1     {v18.4s}, [x11]
    ld1     {v26.4s}, [x12]
    fmax    v18.4s, v18.4s, v26.4s
    ld1     {v27.4s}, [x13]
    fmax    v18.4s, v18.4s, v27.4s

    subs x10, x10, x2    // prev column
    subs x11, x11, x2    // prev column
    subs x12, x12, x2    // prev column
    subs x13, x13, x2    // prev column

    ld1     {v1.4s}, [x10]
    fmax    v1.4s, v1.4s, v2.4s
    ld1     {v17.4s}, [x11]
    ld1     {v26.4s}, [x12]
    fmax    v17.4s, v17.4s, v26.4s
    ld1     {v27.4s}, [x13]
    fmax    v17.4s, v17.4s, v27.4s
    fmax    v17.4s, v17.4s, v18.4s

    subs x10, x10, x2    // prev column
    subs x11, x11, x2    // prev column
    subs x12, x12, x2    // prev column
    subs x13, x13, x2    // prev column

    ld1     {v0.4s}, [x10]
    fmax    v0.4s, v0.4s, v1.4s
    ld1     {v16.4s}, [x11]
    ld1     {v26.4s}, [x12]
    fmax    v16.4s, v16.4s, v26.4s
    ld1     {v27.4s}, [x13]
    fmax    v16.4s, v16.4s, v27.4s
    fmax    v16.4s, v16.4s, v17.4s

    fmax    v0.4s, v0.4s, v16.4s

    st1     {v0.4s}, [x6]           // out(0,0)
    st1     {v16.4s}, [x7]          // out(1,0)

    add x6, x6, x2
    add x7, x7, x2

    add x10, x5, x2
    add x10, x10, x2
    add x10, x10, x2
    add x11, x10, x3
    add x12, x11, x3
    add x13, x12, x3
    
    ld1     {v3.4s}, [x10]
    ld1     {v19.4s}, [x11]
    ld1     {v26.4s}, [x12]
    fmax    v19.4s, v19.4s, v26.4s
    ld1     {v27.4s}, [x13]
    fmax    v19.4s, v19.4s, v27.4s
    fmax    v2.4s, v2.4s, v3.4s
    fmax    v1.4s, v1.4s, v3.4s
    fmax    v0.4s, v0.4s, v3.4s
    fmax    v18.4s, v18.4s, v19.4s
    fmax    v17.4s, v17.4s, v19.4s
    fmax    v16.4s, v16.4s, v19.4s

    fmax    v0.4s, v0.4s, v16.4s

    st1     {v0.4s}, [x6]           // out(0,1)
    st1     {v16.4s}, [x7]          // out(1,1)

    mov x15, #16
.w_last_loop:
    add x6, x6, x2
    add x7, x7, x2

    add x10, x10, x2
    add x11, x11, x2
    add x12, x12, x2
    add x13, x13, x2

    ld1     {v4.4s}, [x10]
    ld1     {v20.4s}, [x11]
    ld1     {v26.4s}, [x12]
    fmax    v20.4s, v20.4s, v26.4s
    ld1     {v27.4s}, [x13]
    fmax    v20.4s, v20.4s, v27.4s
    fmax    v3.4s, v3.4s, v4.4s
    fmax    v2.4s, v2.4s, v4.4s
    fmax    v1.4s, v1.4s, v4.4s
    fmax    v0.4s, v0.4s, v4.4s
    fmax    v19.4s, v19.4s, v20.4s
    fmax    v18.4s, v18.4s, v20.4s
    fmax    v17.4s, v17.4s, v20.4s
    fmax    v16.4s, v16.4s, v20.4s

    fmax    v0.4s, v0.4s, v16.4s

    st1     {v0.4s}, [x6]           // out(0,2)
    st1     {v16.4s}, [x7]          // out(1,2)

    mov     v0.16b, v1.16b
    mov     v16.16b, v17.16b
    mov     v1.16b, v2.16b
    mov     v17.16b, v18.16b
    mov     v2.16b, v3.16b
    mov     v18.16b, v19.16b
    mov     v3.16b, v4.16b
    mov     v19.16b, v20.16b

    subs x15, x15, #1
    bgt .w_last_loop

    add x6, x6, x2
    add x7, x7, x2

    fmax    v0.4s, v0.4s, v16.4s

    st1     {v0.4s}, [x6] 
    st1     {v16.4s}, [x7]

    add x6, x6, x2
    add x7, x7, x2

    fmax    v1.4s, v1.4s, v17.4s

    st1     {v1.4s}, [x6] 
    st1     {v17.4s}, [x7]

    add x5, x5, #16
    subs x1, x1, #4
    bgt .oc_last_loop

    ret
