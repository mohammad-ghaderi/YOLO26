.global v_dot_attn
.type v_dot_attn, %function


v_dot_attn:
    // x0: v address
    // x1: attn address
    // x2: output address

    mov x7, x0
    mov x8, x1
    mov x9, x2

    mov x10, #400
.loop:
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

    
    mov x11, #400
.k_loop:
    
    ld1     {v7.4s}, [x1], #16
    dup     v6.4s, v7.s[0]
    
    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x0], #64
    fmla    v16.4s, v0.4s, v6.4s
    fmla    v17.4s, v1.4s, v6.4s
    fmla    v18.4s, v2.4s, v6.4s
    fmla    v19.4s, v3.4s, v6.4s
    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x0], #64
    fmla    v20.4s, v0.4s, v6.4s
    fmla    v21.4s, v1.4s, v6.4s
    fmla    v22.4s, v2.4s, v6.4s
    fmla    v23.4s, v3.4s, v6.4s
    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x0], #64
    fmla    v24.4s, v0.4s, v6.4s
    fmla    v25.4s, v1.4s, v6.4s
    fmla    v26.4s, v2.4s, v6.4s
    fmla    v27.4s, v3.4s, v6.4s
    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x0], #64
    fmla    v28.4s, v0.4s, v6.4s
    fmla    v29.4s, v1.4s, v6.4s
    fmla    v30.4s, v2.4s, v6.4s
    fmla    v31.4s, v3.4s, v6.4s
    // add x0, x0, #320

    dup     v6.4s, v7.s[1]
    
    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x0], #64
    fmla    v16.4s, v0.4s, v6.4s
    fmla    v17.4s, v1.4s, v6.4s
    fmla    v18.4s, v2.4s, v6.4s
    fmla    v19.4s, v3.4s, v6.4s
    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x0], #64
    fmla    v20.4s, v0.4s, v6.4s
    fmla    v21.4s, v1.4s, v6.4s
    fmla    v22.4s, v2.4s, v6.4s
    fmla    v23.4s, v3.4s, v6.4s
    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x0], #64
    fmla    v24.4s, v0.4s, v6.4s
    fmla    v25.4s, v1.4s, v6.4s
    fmla    v26.4s, v2.4s, v6.4s
    fmla    v27.4s, v3.4s, v6.4s
    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x0], #64
    fmla    v28.4s, v0.4s, v6.4s
    fmla    v29.4s, v1.4s, v6.4s
    fmla    v30.4s, v2.4s, v6.4s
    fmla    v31.4s, v3.4s, v6.4s
    // add x0, x0, #320

    dup     v6.4s, v7.s[2]
    
    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x0], #64
    fmla    v16.4s, v0.4s, v6.4s
    fmla    v17.4s, v1.4s, v6.4s
    fmla    v18.4s, v2.4s, v6.4s
    fmla    v19.4s, v3.4s, v6.4s
    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x0], #64
    fmla    v20.4s, v0.4s, v6.4s
    fmla    v21.4s, v1.4s, v6.4s
    fmla    v22.4s, v2.4s, v6.4s
    fmla    v23.4s, v3.4s, v6.4s
    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x0], #64
    fmla    v24.4s, v0.4s, v6.4s
    fmla    v25.4s, v1.4s, v6.4s
    fmla    v26.4s, v2.4s, v6.4s
    fmla    v27.4s, v3.4s, v6.4s
    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x0], #64
    fmla    v28.4s, v0.4s, v6.4s
    fmla    v29.4s, v1.4s, v6.4s
    fmla    v30.4s, v2.4s, v6.4s
    fmla    v31.4s, v3.4s, v6.4s
    // add x0, x0, #320

    dup     v6.4s, v7.s[3]
    
    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x0], #64
    fmla    v16.4s, v0.4s, v6.4s
    fmla    v17.4s, v1.4s, v6.4s
    fmla    v18.4s, v2.4s, v6.4s
    fmla    v19.4s, v3.4s, v6.4s
    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x0], #64
    fmla    v20.4s, v0.4s, v6.4s
    fmla    v21.4s, v1.4s, v6.4s
    fmla    v22.4s, v2.4s, v6.4s
    fmla    v23.4s, v3.4s, v6.4s
    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x0], #64
    fmla    v24.4s, v0.4s, v6.4s
    fmla    v25.4s, v1.4s, v6.4s
    fmla    v26.4s, v2.4s, v6.4s
    fmla    v27.4s, v3.4s, v6.4s
    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x0], #64
    fmla    v28.4s, v0.4s, v6.4s
    fmla    v29.4s, v1.4s, v6.4s
    fmla    v30.4s, v2.4s, v6.4s
    fmla    v31.4s, v3.4s, v6.4s
    // add x0, x0, #320

    subs x11, x11, #4
    bgt .k_loop


    st1     {v16.4s, v17.4s, v18.4s, v19.4s}, [x2], #64
    st1     {v20.4s, v21.4s, v22.4s, v23.4s}, [x2], #64
    st1     {v24.4s, v25.4s, v26.4s, v27.4s}, [x2], #64
    st1     {v28.4s, v29.4s, v30.4s, v31.4s}, [x2]
    add x2, x2, #320

    mov x0, x7

    subs x10, x10, #1
    bgt .loop
    
    ret
