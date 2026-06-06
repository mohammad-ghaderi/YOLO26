.global bias_split_attn
.type bias_split_attn, %function

bias_split_attn:
    // x0: input address
    // x1: bias address
    // x2: output first head address
    // x3: size
    

    ///######### Q of qkv for the fist head #######
    mov x8, x0
    ld1     {v16.4s, v17.4s, v18.4s, v19.4s}, [x1], #64         // Load bias for 0..15
    ld1     {v20.4s, v21.4s, v22.4s, v23.4s}, [x1], #64         // Load bias for 16..31
    mov x10, x3    // 400*400
.wh_loop_q1:
    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x8], #64
    fadd     v0.4s, v0.4s, v16.4s
    fadd     v1.4s, v1.4s, v17.4s
    fadd     v2.4s, v2.4s, v18.4s
    fadd     v3.4s, v3.4s, v19.4s
    st1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x2], #64
    
    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x8]
    fadd     v0.4s, v0.4s, v20.4s
    fadd     v1.4s, v1.4s, v21.4s
    fadd     v2.4s, v2.4s, v22.4s
    fadd     v3.4s, v3.4s, v23.4s
    st1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x2], #64

    add x8, x8, #960
    subs x10, x10, #1
    bgt .wh_loop_q1

    /////    K of qkv for the fist head       //////
    add x8, x0, #128
    ld1     {v16.4s, v17.4s, v18.4s, v19.4s}, [x1], #64         // Load bias for 0..15
    ld1     {v20.4s, v21.4s, v22.4s, v23.4s}, [x1], #64         // Load bias for 16..31
    mov x10, x3    // 400*400
.wh_loop_k1:
    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x8], #64
    fadd     v0.4s, v0.4s, v16.4s
    fadd     v1.4s, v1.4s, v17.4s
    fadd     v2.4s, v2.4s, v18.4s
    fadd     v3.4s, v3.4s, v19.4s
    st1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x2], #64
    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x8]
    fadd     v0.4s, v0.4s, v20.4s
    fadd     v1.4s, v1.4s, v21.4s
    fadd     v2.4s, v2.4s, v22.4s
    fadd     v3.4s, v3.4s, v23.4s
    st1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x2], #64

    add x8, x8, #960
    subs x10, x10, #1
    bgt .wh_loop_k1


    /////    V of qkv for the fist head       //////
    add x8, x0, #256
    ld1     {v16.4s, v17.4s, v18.4s, v19.4s}, [x1], #64         // Load bias for 0..15
    ld1     {v20.4s, v21.4s, v22.4s, v23.4s}, [x1], #64         // Load bias for 16..31
    ld1     {v24.4s, v25.4s, v26.4s, v27.4s}, [x1], #64         // Load bias for 32..47
    ld1     {v28.4s, v29.4s, v30.4s, v31.4s}, [x1], #64         // Load bias for 48..63
    mov x10, x3    // 400*400
.wh_loop_v1:
    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x8], #64
    fadd     v0.4s, v0.4s, v16.4s
    fadd     v1.4s, v1.4s, v17.4s
    fadd     v2.4s, v2.4s, v18.4s
    fadd     v3.4s, v3.4s, v19.4s
    st1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x2], #64
    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x8], #64
    fadd     v0.4s, v0.4s, v20.4s
    fadd     v1.4s, v1.4s, v21.4s
    fadd     v2.4s, v2.4s, v22.4s
    fadd     v3.4s, v3.4s, v23.4s
    st1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x2], #64
    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x8], #64
    fadd     v0.4s, v0.4s, v24.4s
    fadd     v1.4s, v1.4s, v25.4s
    fadd     v2.4s, v2.4s, v26.4s
    fadd     v3.4s, v3.4s, v27.4s
    st1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x2], #64
    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x8]
    fadd     v0.4s, v0.4s, v28.4s
    fadd     v1.4s, v1.4s, v29.4s
    fadd     v2.4s, v2.4s, v30.4s
    fadd     v3.4s, v3.4s, v31.4s
    st1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x2], #64


    add x8, x8, #832
    subs x10, x10, #1
    bgt .wh_loop_v1




    // second head

    add x0, x0, #512


    ///######### Q of qkv for the second head #######
    mov x8, x0
    ld1     {v16.4s, v17.4s, v18.4s, v19.4s}, [x1], #64         // Load bias for 0..15
    ld1     {v20.4s, v21.4s, v22.4s, v23.4s}, [x1], #64         // Load bias for 16..31
    mov x10, x3    // 400*400
.wh_loop_q2:
    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x8], #64
    fadd     v0.4s, v0.4s, v16.4s
    fadd     v1.4s, v1.4s, v17.4s
    fadd     v2.4s, v2.4s, v18.4s
    fadd     v3.4s, v3.4s, v19.4s
    st1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x2], #64
    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x8]
    fadd     v0.4s, v0.4s, v20.4s
    fadd     v1.4s, v1.4s, v21.4s
    fadd     v2.4s, v2.4s, v22.4s
    fadd     v3.4s, v3.4s, v23.4s
    st1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x2], #64

    add x8, x8, #960
    subs x10, x10, #1
    bgt .wh_loop_q2



    /////    K of qkv for the second head       //////
    add x8, x0, #128
    ld1     {v16.4s, v17.4s, v18.4s, v19.4s}, [x1], #64         // Load bias for 0..15
    ld1     {v20.4s, v21.4s, v22.4s, v23.4s}, [x1], #64         // Load bias for 16..31
    mov x10, x3    // 400*400
.wh_loop_k2:
    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x8], #64
    fadd     v0.4s, v0.4s, v16.4s
    fadd     v1.4s, v1.4s, v17.4s
    fadd     v2.4s, v2.4s, v18.4s
    fadd     v3.4s, v3.4s, v19.4s
    st1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x2], #64
    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x8]
    fadd     v0.4s, v0.4s, v20.4s
    fadd     v1.4s, v1.4s, v21.4s
    fadd     v2.4s, v2.4s, v22.4s
    fadd     v3.4s, v3.4s, v23.4s
    st1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x2], #64

    add x8, x8, #960
    subs x10, x10, #1
    bgt .wh_loop_k2


    /////    V of qkv for the fist head       //////
    add x8, x0, #256
    ld1     {v16.4s, v17.4s, v18.4s, v19.4s}, [x1], #64         // Load bias for 0..15
    ld1     {v20.4s, v21.4s, v22.4s, v23.4s}, [x1], #64         // Load bias for 16..31
    ld1     {v24.4s, v25.4s, v26.4s, v27.4s}, [x1], #64         // Load bias for 32..47
    ld1     {v28.4s, v29.4s, v30.4s, v31.4s}, [x1], #64         // Load bias for 48..63
    mov x10, x3    // 400*400
.wh_loop_v2:
    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x8], #64
    fadd     v0.4s, v0.4s, v16.4s
    fadd     v1.4s, v1.4s, v17.4s
    fadd     v2.4s, v2.4s, v18.4s
    fadd     v3.4s, v3.4s, v19.4s
    st1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x2], #64
    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x8], #64
    fadd     v0.4s, v0.4s, v20.4s
    fadd     v1.4s, v1.4s, v21.4s
    fadd     v2.4s, v2.4s, v22.4s
    fadd     v3.4s, v3.4s, v23.4s
    st1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x2], #64
    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x8], #64
    fadd     v0.4s, v0.4s, v24.4s
    fadd     v1.4s, v1.4s, v25.4s
    fadd     v2.4s, v2.4s, v26.4s
    fadd     v3.4s, v3.4s, v27.4s
    st1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x2], #64
    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x8]
    fadd     v0.4s, v0.4s, v28.4s
    fadd     v1.4s, v1.4s, v29.4s
    fadd     v2.4s, v2.4s, v30.4s
    fadd     v3.4s, v3.4s, v31.4s
    st1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x2], #64


    add x8, x8, #832
    subs x10, x10, #1
    bgt .wh_loop_v2

    ret
