.global upsample_concat
.type upsample_concat, %function


upsample_concat:
    // x0: input address
    // x1: output address
    // x2: SIZE
    // x3: IC
    // x4: OC

    lsl x12, x4, #2         // OC*4bytes (gap)
    add x14, x2, x2
    mul x14, x12, x14        // x14: output row distance
    
    mov x5, x1          // output (0, 0)
    add x6, x5, x12     // output (0, 1)
    add x7, x5, x14     // output (1, 0)
    add x8, x6, x14     // output (1, 1)

    lsl x15, x3, #2
    subs x15, x12, x15
    add x15, x15, x12   // output stride (OC-IC+ column)

    mov x9, x2
.h_loop:
    mov x10, x2
.w_loop:
    mov x11, x3
.oc_loop:
    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x0], #64

    st1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x5], #64
    st1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x6], #64
    st1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x7], #64
    st1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x8], #64

    subs x11, x11, #16
    bgt .oc_loop

    add x5, x5, x15
    add x6, x6, x15
    add x7, x7, x15
    add x8, x8, x15

    subs x10, x10, #1
    bgt .w_loop

    add x5, x5, x14
    add x6, x6, x14
    add x7, x7, x14
    add x8, x8, x14
    subs x9, x9, #1
    bgt .h_loop
    
    ret
