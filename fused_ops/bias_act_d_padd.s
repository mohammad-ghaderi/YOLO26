.global bias_act_d_padd_oc32, bias_act_d_padd
.type bias_act_d_padd, %function
.type bias_act_d_padd_oc32, %function

// add bias and SiLU activation function, and store, also store in the at the end with padding for next convolution
// oc32

bias_act_d_padd_oc32:
    // x0: input pointer
    // x1: bias pointer
    // x2: output with padding
  
    ldr     q20, exp_pack1          // v20 = {hi, lo, LOG2EF, 0.5}
    ldr     q21, exp_pack2          // v21 = {c1, c2 , p4, p5}
    ldr     q22, exp_pack3          // v22 = {p0, p1, p2, p3}

    fmov    s1, #1.0
    dup     v1.4s, v1.s[0]          // one

    dup     v16.4s, v20.s[0]         // hi
    dup     v17.4s, v20.s[1]         // lo
    
    dup     v18.4s, v20.s[2]         // LOG2EF
    dup     v7.4s, v21.s[0]         // c1
    dup     v19.4s, v21.s[1]         // c2

    dup     v23.4s, v22.s[0]         // p0

    mov     x8, x1

    movi v0.4s, #0
    mov x11, #2608      // (160+2+1)*16
.zero_padd_loop_oc32_first:
    st1     {v0.4s}, [x2], #16
    subs    x11, x11, #4
    bgt .zero_padd_loop_oc32_first

    ld1     {v24.4s, v25.4s, v26.4s, v27.4s}, [x8], #64       // bias for 0-15 oc
    ld1     {v28.4s, v29.4s, v30.4s, v31.4s}, [x8], #64       // bias for 16-31 oc
    mov x10, #160
.oh_loop_oc32:  
    mov x11, #160
.ow_loop_oc32:  

    // later optimization:  ********************************** ********************************** later optimization **********************************
    // instead of input + bias = out then -out
    // optimized: (-bias) - input
    // (-bias) is build time and in one instruction i will subtract it

    ld1     {v0.4s}, [x0]
    fadd    v0.4s, v0.4s, v24.4s

    // activation part ------------------------------------------ 1
    fneg     v4.4s, v0.4s           // v4: -x
    fmin    v4.4s, v4.4s, v16.4s 
    fmax    v4.4s, v4.4s, v17.4s    // v4: x
    dup     v3.4s, v20.s[3]         // 0.5
    fmla    v3.4s, v4.4s, v18.4s    // 0.5 + x*LOG2EF   v3: fx
    fcvtzs  v5.4s, v3.4s            // float to int
    scvtf   v5.4s, v5.4s            // int to float     v5: tmp
    fcmgt   v6.4s, v5.4s, v3.4s     // v6: mask = (tmp > fx) ? 0xFFFFFFFF : 0x00000000
    and     v6.16b, v6.16b, v1.16b  // v6: mask
    fsub    v3.4s, v5.4s, v6.4s     // v3: fx = tmp - mask
    fmul    v5.4s, v3.4s, v7.4s    // v5: tmp
    fmul    v6.4s, v3.4s, v19.4s    // v6: z
    fsub    v4.4s, v4.4s, v5.4s
    fsub    v4.4s, v4.4s, v6.4s     // v4: x
    fmul    v6.4s, v4.4s, v4.4s     // v6: z
    // v1: one, v3: fx, v4: x, v6: z
    dup     v5.4s, v22.s[1]         // p1
    fmla    v5.4s, v23.4s, v4.4s
    dup     v2.4s, v22.s[2]         // p2
    fmla    v2.4s, v5.4s, v4.4s
    dup     v5.4s, v22.s[3]         // p3
    fmla    v5.4s, v2.4s, v4.4s
    dup     v2.4s, v21.s[2]         // p4
    fmla    v2.4s, v5.4s, v4.4s
    dup     v5.4s, v21.s[3]         // p5
    fmla    v5.4s, v2.4s, v4.4s     // v5: y
    fmla    v4.4s, v5.4s, v6.4s
    fadd    v4.4s, v4.4s, v1.4s     // v4: y
    // v3: fx, v4: y
    fcvtzs  v3.4s, v3.4s            // v3: mm
    movi    v2.4s, #0x7f
    add     v2.4s, v2.4s, v3.4s     // v2: mm
    shl     v2.4s, v2.4s, #23
    fmul    v4.4s, v4.4s, v2.4s     // v4: y
    // v4: exp(x)
    fadd    v4.4s, v4.4s, v1.4s
    fdiv    v0.4s, v0.4s, v4.4s
    st1     {v0.4s}, [x0], #16
    // ------------------------------------------------------

    ld1     {v0.4s}, [x0]
    fadd    v0.4s, v0.4s, v25.4s

    // activation part ------------------------------------------ 2
    fneg     v4.4s, v0.4s           // v4: -x
    fmin    v4.4s, v4.4s, v16.4s 
    fmax    v4.4s, v4.4s, v17.4s    // v4: x
    dup     v3.4s, v20.s[3]         // 0.5
    fmla    v3.4s, v4.4s, v18.4s    // 0.5 + x*LOG2EF   v3: fx
    fcvtzs  v5.4s, v3.4s            // float to int
    scvtf   v5.4s, v5.4s            // int to float     v5: tmp
    fcmgt   v6.4s, v5.4s, v3.4s     // v6: mask = (tmp > fx) ? 0xFFFFFFFF : 0x00000000
    and     v6.16b, v6.16b, v1.16b  // v6: mask
    fsub    v3.4s, v5.4s, v6.4s     // v3: fx = tmp - mask
    fmul    v5.4s, v3.4s, v7.4s    // v5: tmp
    fmul    v6.4s, v3.4s, v19.4s    // v6: z
    fsub    v4.4s, v4.4s, v5.4s
    fsub    v4.4s, v4.4s, v6.4s     // v4: x
    fmul    v6.4s, v4.4s, v4.4s     // v6: z
    // v1: one, v3: fx, v4: x, v6: z
    dup     v5.4s, v22.s[1]         // p1
    fmla    v5.4s, v23.4s, v4.4s
    dup     v2.4s, v22.s[2]         // p2
    fmla    v2.4s, v5.4s, v4.4s
    dup     v5.4s, v22.s[3]         // p3
    fmla    v5.4s, v2.4s, v4.4s
    dup     v2.4s, v21.s[2]         // p4
    fmla    v2.4s, v5.4s, v4.4s
    dup     v5.4s, v21.s[3]         // p5
    fmla    v5.4s, v2.4s, v4.4s     // v5: y
    fmla    v4.4s, v5.4s, v6.4s
    fadd    v4.4s, v4.4s, v1.4s     // v4: y
    // v3: fx, v4: y
    fcvtzs  v3.4s, v3.4s            // v3: mm
    movi    v2.4s, #0x7f
    add     v2.4s, v2.4s, v3.4s     // v2: mm
    shl     v2.4s, v2.4s, #23
    fmul    v4.4s, v4.4s, v2.4s     // v4: y
    // v4: exp(x)
    fadd    v4.4s, v4.4s, v1.4s
    fdiv    v0.4s, v0.4s, v4.4s
    st1     {v0.4s}, [x0], #16
    // ------------------------------------------------------

    ld1     {v0.4s}, [x0]
    fadd    v0.4s, v0.4s, v26.4s

    // activation part ------------------------------------------ 3
    fneg     v4.4s, v0.4s           // v4: -x
    fmin    v4.4s, v4.4s, v16.4s 
    fmax    v4.4s, v4.4s, v17.4s    // v4: x
    dup     v3.4s, v20.s[3]         // 0.5
    fmla    v3.4s, v4.4s, v18.4s    // 0.5 + x*LOG2EF   v3: fx
    fcvtzs  v5.4s, v3.4s            // float to int
    scvtf   v5.4s, v5.4s            // int to float     v5: tmp
    fcmgt   v6.4s, v5.4s, v3.4s     // v6: mask = (tmp > fx) ? 0xFFFFFFFF : 0x00000000
    and     v6.16b, v6.16b, v1.16b  // v6: mask
    fsub    v3.4s, v5.4s, v6.4s     // v3: fx = tmp - mask
    fmul    v5.4s, v3.4s, v7.4s    // v5: tmp
    fmul    v6.4s, v3.4s, v19.4s    // v6: z
    fsub    v4.4s, v4.4s, v5.4s
    fsub    v4.4s, v4.4s, v6.4s     // v4: x
    fmul    v6.4s, v4.4s, v4.4s     // v6: z
    // v1: one, v3: fx, v4: x, v6: z
    dup     v5.4s, v22.s[1]         // p1
    fmla    v5.4s, v23.4s, v4.4s
    dup     v2.4s, v22.s[2]         // p2
    fmla    v2.4s, v5.4s, v4.4s
    dup     v5.4s, v22.s[3]         // p3
    fmla    v5.4s, v2.4s, v4.4s
    dup     v2.4s, v21.s[2]         // p4
    fmla    v2.4s, v5.4s, v4.4s
    dup     v5.4s, v21.s[3]         // p5
    fmla    v5.4s, v2.4s, v4.4s     // v5: y
    fmla    v4.4s, v5.4s, v6.4s
    fadd    v4.4s, v4.4s, v1.4s     // v4: y
    // v3: fx, v4: y
    fcvtzs  v3.4s, v3.4s            // v3: mm
    movi    v2.4s, #0x7f
    add     v2.4s, v2.4s, v3.4s     // v2: mm
    shl     v2.4s, v2.4s, #23
    fmul    v4.4s, v4.4s, v2.4s     // v4: y
    // v4: exp(x)
    fadd    v4.4s, v4.4s, v1.4s
    fdiv    v0.4s, v0.4s, v4.4s
    st1     {v0.4s}, [x0], #16
    // ------------------------------------------------------

    ld1     {v0.4s}, [x0]
    fadd    v0.4s, v0.4s, v27.4s

    // activation part ------------------------------------------ 4
    fneg     v4.4s, v0.4s           // v4: -x
    fmin    v4.4s, v4.4s, v16.4s 
    fmax    v4.4s, v4.4s, v17.4s    // v4: x
    dup     v3.4s, v20.s[3]         // 0.5
    fmla    v3.4s, v4.4s, v18.4s    // 0.5 + x*LOG2EF   v3: fx
    fcvtzs  v5.4s, v3.4s            // float to int
    scvtf   v5.4s, v5.4s            // int to float     v5: tmp
    fcmgt   v6.4s, v5.4s, v3.4s     // v6: mask = (tmp > fx) ? 0xFFFFFFFF : 0x00000000
    and     v6.16b, v6.16b, v1.16b  // v6: mask
    fsub    v3.4s, v5.4s, v6.4s     // v3: fx = tmp - mask
    fmul    v5.4s, v3.4s, v7.4s    // v5: tmp
    fmul    v6.4s, v3.4s, v19.4s    // v6: z
    fsub    v4.4s, v4.4s, v5.4s
    fsub    v4.4s, v4.4s, v6.4s     // v4: x
    fmul    v6.4s, v4.4s, v4.4s     // v6: z
    // v1: one, v3: fx, v4: x, v6: z
    dup     v5.4s, v22.s[1]         // p1
    fmla    v5.4s, v23.4s, v4.4s
    dup     v2.4s, v22.s[2]         // p2
    fmla    v2.4s, v5.4s, v4.4s
    dup     v5.4s, v22.s[3]         // p3
    fmla    v5.4s, v2.4s, v4.4s
    dup     v2.4s, v21.s[2]         // p4
    fmla    v2.4s, v5.4s, v4.4s
    dup     v5.4s, v21.s[3]         // p5
    fmla    v5.4s, v2.4s, v4.4s     // v5: y
    fmla    v4.4s, v5.4s, v6.4s
    fadd    v4.4s, v4.4s, v1.4s     // v4: y
    // v3: fx, v4: y
    fcvtzs  v3.4s, v3.4s            // v3: mm
    movi    v2.4s, #0x7f
    add     v2.4s, v2.4s, v3.4s     // v2: mm
    shl     v2.4s, v2.4s, #23
    fmul    v4.4s, v4.4s, v2.4s     // v4: y
    // v4: exp(x)
    fadd    v4.4s, v4.4s, v1.4s
    fdiv    v0.4s, v0.4s, v4.4s
    st1     {v0.4s}, [x0], #16
    // ------------------------------------------------------


    // here is the [15:32]  also save with padding for next convolution


    ld1     {v0.4s}, [x0]
    fadd    v0.4s, v0.4s, v28.4s

    // activation part ------------------------------------------ 1
    fneg     v4.4s, v0.4s           // v4: -x
    fmin    v4.4s, v4.4s, v16.4s 
    fmax    v4.4s, v4.4s, v17.4s    // v4: x
    dup     v3.4s, v20.s[3]         // 0.5
    fmla    v3.4s, v4.4s, v18.4s    // 0.5 + x*LOG2EF   v3: fx
    fcvtzs  v5.4s, v3.4s            // float to int
    scvtf   v5.4s, v5.4s            // int to float     v5: tmp
    fcmgt   v6.4s, v5.4s, v3.4s     // v6: mask = (tmp > fx) ? 0xFFFFFFFF : 0x00000000
    and     v6.16b, v6.16b, v1.16b  // v6: mask
    fsub    v3.4s, v5.4s, v6.4s     // v3: fx = tmp - mask
    fmul    v5.4s, v3.4s, v7.4s    // v5: tmp
    fmul    v6.4s, v3.4s, v19.4s    // v6: z
    fsub    v4.4s, v4.4s, v5.4s
    fsub    v4.4s, v4.4s, v6.4s     // v4: x
    fmul    v6.4s, v4.4s, v4.4s     // v6: z
    // v1: one, v3: fx, v4: x, v6: z
    dup     v5.4s, v22.s[1]         // p1
    fmla    v5.4s, v23.4s, v4.4s
    dup     v2.4s, v22.s[2]         // p2
    fmla    v2.4s, v5.4s, v4.4s
    dup     v5.4s, v22.s[3]         // p3
    fmla    v5.4s, v2.4s, v4.4s
    dup     v2.4s, v21.s[2]         // p4
    fmla    v2.4s, v5.4s, v4.4s
    dup     v5.4s, v21.s[3]         // p5
    fmla    v5.4s, v2.4s, v4.4s     // v5: y
    fmla    v4.4s, v5.4s, v6.4s
    fadd    v4.4s, v4.4s, v1.4s     // v4: y
    // v3: fx, v4: y
    fcvtzs  v3.4s, v3.4s            // v3: mm
    movi    v2.4s, #0x7f
    add     v2.4s, v2.4s, v3.4s     // v2: mm
    shl     v2.4s, v2.4s, #23
    fmul    v4.4s, v4.4s, v2.4s     // v4: y
    // v4: exp(x)
    fadd    v4.4s, v4.4s, v1.4s
    fdiv    v0.4s, v0.4s, v4.4s
    st1     {v0.4s}, [x0], #16
    st1     {v0.4s}, [x2], #16
    // ------------------------------------------------------

    ld1     {v0.4s}, [x0]
    fadd    v0.4s, v0.4s, v29.4s

    // activation part ------------------------------------------ 2
    fneg     v4.4s, v0.4s           // v4: -x
    fmin    v4.4s, v4.4s, v16.4s 
    fmax    v4.4s, v4.4s, v17.4s    // v4: x
    dup     v3.4s, v20.s[3]         // 0.5
    fmla    v3.4s, v4.4s, v18.4s    // 0.5 + x*LOG2EF   v3: fx
    fcvtzs  v5.4s, v3.4s            // float to int
    scvtf   v5.4s, v5.4s            // int to float     v5: tmp
    fcmgt   v6.4s, v5.4s, v3.4s     // v6: mask = (tmp > fx) ? 0xFFFFFFFF : 0x00000000
    and     v6.16b, v6.16b, v1.16b  // v6: mask
    fsub    v3.4s, v5.4s, v6.4s     // v3: fx = tmp - mask
    fmul    v5.4s, v3.4s, v7.4s    // v5: tmp
    fmul    v6.4s, v3.4s, v19.4s    // v6: z
    fsub    v4.4s, v4.4s, v5.4s
    fsub    v4.4s, v4.4s, v6.4s     // v4: x
    fmul    v6.4s, v4.4s, v4.4s     // v6: z
    // v1: one, v3: fx, v4: x, v6: z
    dup     v5.4s, v22.s[1]         // p1
    fmla    v5.4s, v23.4s, v4.4s
    dup     v2.4s, v22.s[2]         // p2
    fmla    v2.4s, v5.4s, v4.4s
    dup     v5.4s, v22.s[3]         // p3
    fmla    v5.4s, v2.4s, v4.4s
    dup     v2.4s, v21.s[2]         // p4
    fmla    v2.4s, v5.4s, v4.4s
    dup     v5.4s, v21.s[3]         // p5
    fmla    v5.4s, v2.4s, v4.4s     // v5: y
    fmla    v4.4s, v5.4s, v6.4s
    fadd    v4.4s, v4.4s, v1.4s     // v4: y
    // v3: fx, v4: y
    fcvtzs  v3.4s, v3.4s            // v3: mm
    movi    v2.4s, #0x7f
    add     v2.4s, v2.4s, v3.4s     // v2: mm
    shl     v2.4s, v2.4s, #23
    fmul    v4.4s, v4.4s, v2.4s     // v4: y
    // v4: exp(x)
    fadd    v4.4s, v4.4s, v1.4s
    fdiv    v0.4s, v0.4s, v4.4s
    st1     {v0.4s}, [x0], #16
    st1     {v0.4s}, [x2], #16
    // ------------------------------------------------------

    ld1     {v0.4s}, [x0]
    fadd    v0.4s, v0.4s, v30.4s

    // activation part ------------------------------------------ 3
    fneg     v4.4s, v0.4s           // v4: -x
    fmin    v4.4s, v4.4s, v16.4s 
    fmax    v4.4s, v4.4s, v17.4s    // v4: x
    dup     v3.4s, v20.s[3]         // 0.5
    fmla    v3.4s, v4.4s, v18.4s    // 0.5 + x*LOG2EF   v3: fx
    fcvtzs  v5.4s, v3.4s            // float to int
    scvtf   v5.4s, v5.4s            // int to float     v5: tmp
    fcmgt   v6.4s, v5.4s, v3.4s     // v6: mask = (tmp > fx) ? 0xFFFFFFFF : 0x00000000
    and     v6.16b, v6.16b, v1.16b  // v6: mask
    fsub    v3.4s, v5.4s, v6.4s     // v3: fx = tmp - mask
    fmul    v5.4s, v3.4s, v7.4s    // v5: tmp
    fmul    v6.4s, v3.4s, v19.4s    // v6: z
    fsub    v4.4s, v4.4s, v5.4s
    fsub    v4.4s, v4.4s, v6.4s     // v4: x
    fmul    v6.4s, v4.4s, v4.4s     // v6: z
    // v1: one, v3: fx, v4: x, v6: z
    dup     v5.4s, v22.s[1]         // p1
    fmla    v5.4s, v23.4s, v4.4s
    dup     v2.4s, v22.s[2]         // p2
    fmla    v2.4s, v5.4s, v4.4s
    dup     v5.4s, v22.s[3]         // p3
    fmla    v5.4s, v2.4s, v4.4s
    dup     v2.4s, v21.s[2]         // p4
    fmla    v2.4s, v5.4s, v4.4s
    dup     v5.4s, v21.s[3]         // p5
    fmla    v5.4s, v2.4s, v4.4s     // v5: y
    fmla    v4.4s, v5.4s, v6.4s
    fadd    v4.4s, v4.4s, v1.4s     // v4: y
    // v3: fx, v4: y
    fcvtzs  v3.4s, v3.4s            // v3: mm
    movi    v2.4s, #0x7f
    add     v2.4s, v2.4s, v3.4s     // v2: mm
    shl     v2.4s, v2.4s, #23
    fmul    v4.4s, v4.4s, v2.4s     // v4: y
    // v4: exp(x)
    fadd    v4.4s, v4.4s, v1.4s
    fdiv    v0.4s, v0.4s, v4.4s
    st1     {v0.4s}, [x0], #16
    st1     {v0.4s}, [x2], #16
    // ------------------------------------------------------

    ld1     {v0.4s}, [x0]
    fadd    v0.4s, v0.4s, v31.4s

    // activation part ------------------------------------------ 4
    fneg     v4.4s, v0.4s           // v4: -x
    fmin    v4.4s, v4.4s, v16.4s 
    fmax    v4.4s, v4.4s, v17.4s    // v4: x
    dup     v3.4s, v20.s[3]         // 0.5
    fmla    v3.4s, v4.4s, v18.4s    // 0.5 + x*LOG2EF   v3: fx
    fcvtzs  v5.4s, v3.4s            // float to int
    scvtf   v5.4s, v5.4s            // int to float     v5: tmp
    fcmgt   v6.4s, v5.4s, v3.4s     // v6: mask = (tmp > fx) ? 0xFFFFFFFF : 0x00000000
    and     v6.16b, v6.16b, v1.16b  // v6: mask
    fsub    v3.4s, v5.4s, v6.4s     // v3: fx = tmp - mask
    fmul    v5.4s, v3.4s, v7.4s    // v5: tmp
    fmul    v6.4s, v3.4s, v19.4s    // v6: z
    fsub    v4.4s, v4.4s, v5.4s
    fsub    v4.4s, v4.4s, v6.4s     // v4: x
    fmul    v6.4s, v4.4s, v4.4s     // v6: z
    // v1: one, v3: fx, v4: x, v6: z
    dup     v5.4s, v22.s[1]         // p1
    fmla    v5.4s, v23.4s, v4.4s
    dup     v2.4s, v22.s[2]         // p2
    fmla    v2.4s, v5.4s, v4.4s
    dup     v5.4s, v22.s[3]         // p3
    fmla    v5.4s, v2.4s, v4.4s
    dup     v2.4s, v21.s[2]         // p4
    fmla    v2.4s, v5.4s, v4.4s
    dup     v5.4s, v21.s[3]         // p5
    fmla    v5.4s, v2.4s, v4.4s     // v5: y
    fmla    v4.4s, v5.4s, v6.4s
    fadd    v4.4s, v4.4s, v1.4s     // v4: y
    // v3: fx, v4: y
    fcvtzs  v3.4s, v3.4s            // v3: mm
    movi    v2.4s, #0x7f
    add     v2.4s, v2.4s, v3.4s     // v2: mm
    shl     v2.4s, v2.4s, #23
    fmul    v4.4s, v4.4s, v2.4s     // v4: y
    // v4: exp(x)
    fadd    v4.4s, v4.4s, v1.4s
    fdiv    v0.4s, v0.4s, v4.4s
    st1     {v0.4s}, [x0], #16
    st1     {v0.4s}, [x2], #16
    add     x0, x0, #64 // make a gap for last answer 
    // ------------------------------------------------------

    subs   x11, x11, #1
    bgt .ow_loop_oc32

    movi v0.4s, #0
    st1 {v0.4s}, [x2], #16
    st1 {v0.4s}, [x2], #16
    st1 {v0.4s}, [x2], #16
    st1 {v0.4s}, [x2], #16
    st1 {v0.4s}, [x2], #16
    st1 {v0.4s}, [x2], #16
    st1 {v0.4s}, [x2], #16
    st1 {v0.4s}, [x2], #16

    subs    x10, x10, #1
    bgt .oh_loop_oc32

    // v0 is still zero
    mov x11, #2576      // (160+1)*32
.zero_padd_loop_oc32_last:
    st1     {v0.4s}, [x2], #16
    subs    x11, x11, #4
    bgt .zero_padd_loop_oc32_last

    ret

// ################################################
// ################################################
// ################################################
// ################################################

bias_act_d_padd:
    // x0: input pointer
    // x1: bias pointer
    // x2: output with padding
    // x3: SIZE
    // x4: IC
    // x5: OC
  
    ldr     q20, exp_pack1          // v20 = {hi, lo, LOG2EF, 0.5}
    ldr     q21, exp_pack2          // v21 = {c1, c2 , p4, p5}
    ldr     q22, exp_pack3          // v22 = {p0, p1, p2, p3}

    fmov    s1, #1.0
    dup     v1.4s, v1.s[0]          // one

    dup     v16.4s, v20.s[0]         // hi
    dup     v17.4s, v20.s[1]         // lo
    
    dup     v18.4s, v20.s[2]         // LOG2EF
    dup     v7.4s, v21.s[0]         // c1
    dup     v19.4s, v21.s[1]         // c2

    dup     v23.4s, v22.s[0]         // p0

    movi v0.4s, #0
    add     x11, x3, #3
    mul     x11, x11, x4 // (SIZE+2+1)*(IC/2)
    lsr     x11, x11, #1
.zero_padd_loop_first:
    st1     {v0.4s}, [x2], #16
    subs    x11, x11, #4
    bgt .zero_padd_loop_first

    mov x10, x3
.oh_loop:
    mov x11, x3
.ow_loop:
    lsr x12, x5, #1     // first half counter
    mov     x8, x1
.oc_first_half_loop:
    ld1     {v24.4s, v25.4s, v26.4s, v27.4s}, [x8], #64       // bias

    // later optimization:  ********************************** ********************************** later optimization **********************************
    // instead of input + bias = out then -out
    // optimized (-bias) - input
    // (-bias) is build time and in one instruction i will subtract it

    ld1     {v0.4s}, [x0]
    fadd    v0.4s, v0.4s, v24.4s

    // activation part ------------------------------------------ 1
    fneg     v4.4s, v0.4s           // v4: -x
    fmin    v4.4s, v4.4s, v16.4s 
    fmax    v4.4s, v4.4s, v17.4s    // v4: x
    dup     v3.4s, v20.s[3]         // 0.5
    fmla    v3.4s, v4.4s, v18.4s    // 0.5 + x*LOG2EF   v3: fx
    fcvtzs  v5.4s, v3.4s            // float to int
    scvtf   v5.4s, v5.4s            // int to float     v5: tmp
    fcmgt   v6.4s, v5.4s, v3.4s     // v6: mask = (tmp > fx) ? 0xFFFFFFFF : 0x00000000
    and     v6.16b, v6.16b, v1.16b  // v6: mask
    fsub    v3.4s, v5.4s, v6.4s     // v3: fx = tmp - mask
    fmul    v5.4s, v3.4s, v7.4s    // v5: tmp
    fmul    v6.4s, v3.4s, v19.4s    // v6: z
    fsub    v4.4s, v4.4s, v5.4s
    fsub    v4.4s, v4.4s, v6.4s     // v4: x
    fmul    v6.4s, v4.4s, v4.4s     // v6: z
    // v1: one, v3: fx, v4: x, v6: z
    dup     v5.4s, v22.s[1]         // p1
    fmla    v5.4s, v23.4s, v4.4s
    dup     v2.4s, v22.s[2]         // p2
    fmla    v2.4s, v5.4s, v4.4s
    dup     v5.4s, v22.s[3]         // p3
    fmla    v5.4s, v2.4s, v4.4s
    dup     v2.4s, v21.s[2]         // p4
    fmla    v2.4s, v5.4s, v4.4s
    dup     v5.4s, v21.s[3]         // p5
    fmla    v5.4s, v2.4s, v4.4s     // v5: y
    fmla    v4.4s, v5.4s, v6.4s
    fadd    v4.4s, v4.4s, v1.4s     // v4: y
    // v3: fx, v4: y
    fcvtzs  v3.4s, v3.4s            // v3: mm
    movi    v2.4s, #0x7f
    add     v2.4s, v2.4s, v3.4s     // v2: mm
    shl     v2.4s, v2.4s, #23
    fmul    v4.4s, v4.4s, v2.4s     // v4: y
    // v4: exp(x)
    fadd    v4.4s, v4.4s, v1.4s
    fdiv    v0.4s, v0.4s, v4.4s
    st1     {v0.4s}, [x0], #16
    // ------------------------------------------------------

    ld1     {v0.4s}, [x0]
    fadd    v0.4s, v0.4s, v25.4s

    // activation part ------------------------------------------ 2
    fneg     v4.4s, v0.4s           // v4: -x
    fmin    v4.4s, v4.4s, v16.4s 
    fmax    v4.4s, v4.4s, v17.4s    // v4: x
    dup     v3.4s, v20.s[3]         // 0.5
    fmla    v3.4s, v4.4s, v18.4s    // 0.5 + x*LOG2EF   v3: fx
    fcvtzs  v5.4s, v3.4s            // float to int
    scvtf   v5.4s, v5.4s            // int to float     v5: tmp
    fcmgt   v6.4s, v5.4s, v3.4s     // v6: mask = (tmp > fx) ? 0xFFFFFFFF : 0x00000000
    and     v6.16b, v6.16b, v1.16b  // v6: mask
    fsub    v3.4s, v5.4s, v6.4s     // v3: fx = tmp - mask
    fmul    v5.4s, v3.4s, v7.4s    // v5: tmp
    fmul    v6.4s, v3.4s, v19.4s    // v6: z
    fsub    v4.4s, v4.4s, v5.4s
    fsub    v4.4s, v4.4s, v6.4s     // v4: x
    fmul    v6.4s, v4.4s, v4.4s     // v6: z
    // v1: one, v3: fx, v4: x, v6: z
    dup     v5.4s, v22.s[1]         // p1
    fmla    v5.4s, v23.4s, v4.4s
    dup     v2.4s, v22.s[2]         // p2
    fmla    v2.4s, v5.4s, v4.4s
    dup     v5.4s, v22.s[3]         // p3
    fmla    v5.4s, v2.4s, v4.4s
    dup     v2.4s, v21.s[2]         // p4
    fmla    v2.4s, v5.4s, v4.4s
    dup     v5.4s, v21.s[3]         // p5
    fmla    v5.4s, v2.4s, v4.4s     // v5: y
    fmla    v4.4s, v5.4s, v6.4s
    fadd    v4.4s, v4.4s, v1.4s     // v4: y
    // v3: fx, v4: y
    fcvtzs  v3.4s, v3.4s            // v3: mm
    movi    v2.4s, #0x7f
    add     v2.4s, v2.4s, v3.4s     // v2: mm
    shl     v2.4s, v2.4s, #23
    fmul    v4.4s, v4.4s, v2.4s     // v4: y
    // v4: exp(x)
    fadd    v4.4s, v4.4s, v1.4s
    fdiv    v0.4s, v0.4s, v4.4s
    st1     {v0.4s}, [x0], #16
    // ------------------------------------------------------

    ld1     {v0.4s}, [x0]
    fadd    v0.4s, v0.4s, v26.4s

    // activation part ------------------------------------------ 3
    fneg     v4.4s, v0.4s           // v4: -x
    fmin    v4.4s, v4.4s, v16.4s 
    fmax    v4.4s, v4.4s, v17.4s    // v4: x
    dup     v3.4s, v20.s[3]         // 0.5
    fmla    v3.4s, v4.4s, v18.4s    // 0.5 + x*LOG2EF   v3: fx
    fcvtzs  v5.4s, v3.4s            // float to int
    scvtf   v5.4s, v5.4s            // int to float     v5: tmp
    fcmgt   v6.4s, v5.4s, v3.4s     // v6: mask = (tmp > fx) ? 0xFFFFFFFF : 0x00000000
    and     v6.16b, v6.16b, v1.16b  // v6: mask
    fsub    v3.4s, v5.4s, v6.4s     // v3: fx = tmp - mask
    fmul    v5.4s, v3.4s, v7.4s    // v5: tmp
    fmul    v6.4s, v3.4s, v19.4s    // v6: z
    fsub    v4.4s, v4.4s, v5.4s
    fsub    v4.4s, v4.4s, v6.4s     // v4: x
    fmul    v6.4s, v4.4s, v4.4s     // v6: z
    // v1: one, v3: fx, v4: x, v6: z
    dup     v5.4s, v22.s[1]         // p1
    fmla    v5.4s, v23.4s, v4.4s
    dup     v2.4s, v22.s[2]         // p2
    fmla    v2.4s, v5.4s, v4.4s
    dup     v5.4s, v22.s[3]         // p3
    fmla    v5.4s, v2.4s, v4.4s
    dup     v2.4s, v21.s[2]         // p4
    fmla    v2.4s, v5.4s, v4.4s
    dup     v5.4s, v21.s[3]         // p5
    fmla    v5.4s, v2.4s, v4.4s     // v5: y
    fmla    v4.4s, v5.4s, v6.4s
    fadd    v4.4s, v4.4s, v1.4s     // v4: y
    // v3: fx, v4: y
    fcvtzs  v3.4s, v3.4s            // v3: mm
    movi    v2.4s, #0x7f
    add     v2.4s, v2.4s, v3.4s     // v2: mm
    shl     v2.4s, v2.4s, #23
    fmul    v4.4s, v4.4s, v2.4s     // v4: y
    // v4: exp(x)
    fadd    v4.4s, v4.4s, v1.4s
    fdiv    v0.4s, v0.4s, v4.4s
    st1     {v0.4s}, [x0], #16
    // ------------------------------------------------------

    ld1     {v0.4s}, [x0]
    fadd    v0.4s, v0.4s, v27.4s

    // activation part ------------------------------------------ 4
    fneg     v4.4s, v0.4s           // v4: -x
    fmin    v4.4s, v4.4s, v16.4s 
    fmax    v4.4s, v4.4s, v17.4s    // v4: x
    dup     v3.4s, v20.s[3]         // 0.5
    fmla    v3.4s, v4.4s, v18.4s    // 0.5 + x*LOG2EF   v3: fx
    fcvtzs  v5.4s, v3.4s            // float to int
    scvtf   v5.4s, v5.4s            // int to float     v5: tmp
    fcmgt   v6.4s, v5.4s, v3.4s     // v6: mask = (tmp > fx) ? 0xFFFFFFFF : 0x00000000
    and     v6.16b, v6.16b, v1.16b  // v6: mask
    fsub    v3.4s, v5.4s, v6.4s     // v3: fx = tmp - mask
    fmul    v5.4s, v3.4s, v7.4s    // v5: tmp
    fmul    v6.4s, v3.4s, v19.4s    // v6: z
    fsub    v4.4s, v4.4s, v5.4s
    fsub    v4.4s, v4.4s, v6.4s     // v4: x
    fmul    v6.4s, v4.4s, v4.4s     // v6: z
    // v1: one, v3: fx, v4: x, v6: z
    dup     v5.4s, v22.s[1]         // p1
    fmla    v5.4s, v23.4s, v4.4s
    dup     v2.4s, v22.s[2]         // p2
    fmla    v2.4s, v5.4s, v4.4s
    dup     v5.4s, v22.s[3]         // p3
    fmla    v5.4s, v2.4s, v4.4s
    dup     v2.4s, v21.s[2]         // p4
    fmla    v2.4s, v5.4s, v4.4s
    dup     v5.4s, v21.s[3]         // p5
    fmla    v5.4s, v2.4s, v4.4s     // v5: y
    fmla    v4.4s, v5.4s, v6.4s
    fadd    v4.4s, v4.4s, v1.4s     // v4: y
    // v3: fx, v4: y
    fcvtzs  v3.4s, v3.4s            // v3: mm
    movi    v2.4s, #0x7f
    add     v2.4s, v2.4s, v3.4s     // v2: mm
    shl     v2.4s, v2.4s, #23
    fmul    v4.4s, v4.4s, v2.4s     // v4: y
    // v4: exp(x)
    fadd    v4.4s, v4.4s, v1.4s
    fdiv    v0.4s, v0.4s, v4.4s
    st1     {v0.4s}, [x0], #16
    // ------------------------------------------------------

    subs    x12, x12, #16
    bgt .oc_first_half_loop

    lsr x12, x5, #1         // second half counter
.oc_second_half_loop:
    ld1     {v24.4s, v25.4s, v26.4s, v27.4s}, [x8], #64       // bias

    // later optimization:  ********************************** ********************************** later optimization **********************************
    // instead of input + bias = out then -out
    // optimized (-bias) - input
    // (-bias) is build time and in one instruction i will subtract it

    ld1     {v0.4s}, [x0]
    fadd    v0.4s, v0.4s, v24.4s

    // activation part ------------------------------------------ 1
    fneg     v4.4s, v0.4s           // v4: -x
    fmin    v4.4s, v4.4s, v16.4s 
    fmax    v4.4s, v4.4s, v17.4s    // v4: x
    dup     v3.4s, v20.s[3]         // 0.5
    fmla    v3.4s, v4.4s, v18.4s    // 0.5 + x*LOG2EF   v3: fx
    fcvtzs  v5.4s, v3.4s            // float to int
    scvtf   v5.4s, v5.4s            // int to float     v5: tmp
    fcmgt   v6.4s, v5.4s, v3.4s     // v6: mask = (tmp > fx) ? 0xFFFFFFFF : 0x00000000
    and     v6.16b, v6.16b, v1.16b  // v6: mask
    fsub    v3.4s, v5.4s, v6.4s     // v3: fx = tmp - mask
    fmul    v5.4s, v3.4s, v7.4s    // v5: tmp
    fmul    v6.4s, v3.4s, v19.4s    // v6: z
    fsub    v4.4s, v4.4s, v5.4s
    fsub    v4.4s, v4.4s, v6.4s     // v4: x
    fmul    v6.4s, v4.4s, v4.4s     // v6: z
    // v1: one, v3: fx, v4: x, v6: z
    dup     v5.4s, v22.s[1]         // p1
    fmla    v5.4s, v23.4s, v4.4s
    dup     v2.4s, v22.s[2]         // p2
    fmla    v2.4s, v5.4s, v4.4s
    dup     v5.4s, v22.s[3]         // p3
    fmla    v5.4s, v2.4s, v4.4s
    dup     v2.4s, v21.s[2]         // p4
    fmla    v2.4s, v5.4s, v4.4s
    dup     v5.4s, v21.s[3]         // p5
    fmla    v5.4s, v2.4s, v4.4s     // v5: y
    fmla    v4.4s, v5.4s, v6.4s
    fadd    v4.4s, v4.4s, v1.4s     // v4: y
    // v3: fx, v4: y
    fcvtzs  v3.4s, v3.4s            // v3: mm
    movi    v2.4s, #0x7f
    add     v2.4s, v2.4s, v3.4s     // v2: mm
    shl     v2.4s, v2.4s, #23
    fmul    v4.4s, v4.4s, v2.4s     // v4: y
    // v4: exp(x)
    fadd    v4.4s, v4.4s, v1.4s
    fdiv    v0.4s, v0.4s, v4.4s
    st1     {v0.4s}, [x0], #16
    st1     {v0.4s}, [x2], #16
    // ------------------------------------------------------

    ld1     {v0.4s}, [x0]
    fadd    v0.4s, v0.4s, v25.4s

    // activation part ------------------------------------------ 2
    fneg     v4.4s, v0.4s           // v4: -x
    fmin    v4.4s, v4.4s, v16.4s 
    fmax    v4.4s, v4.4s, v17.4s    // v4: x
    dup     v3.4s, v20.s[3]         // 0.5
    fmla    v3.4s, v4.4s, v18.4s    // 0.5 + x*LOG2EF   v3: fx
    fcvtzs  v5.4s, v3.4s            // float to int
    scvtf   v5.4s, v5.4s            // int to float     v5: tmp
    fcmgt   v6.4s, v5.4s, v3.4s     // v6: mask = (tmp > fx) ? 0xFFFFFFFF : 0x00000000
    and     v6.16b, v6.16b, v1.16b  // v6: mask
    fsub    v3.4s, v5.4s, v6.4s     // v3: fx = tmp - mask
    fmul    v5.4s, v3.4s, v7.4s    // v5: tmp
    fmul    v6.4s, v3.4s, v19.4s    // v6: z
    fsub    v4.4s, v4.4s, v5.4s
    fsub    v4.4s, v4.4s, v6.4s     // v4: x
    fmul    v6.4s, v4.4s, v4.4s     // v6: z
    // v1: one, v3: fx, v4: x, v6: z
    dup     v5.4s, v22.s[1]         // p1
    fmla    v5.4s, v23.4s, v4.4s
    dup     v2.4s, v22.s[2]         // p2
    fmla    v2.4s, v5.4s, v4.4s
    dup     v5.4s, v22.s[3]         // p3
    fmla    v5.4s, v2.4s, v4.4s
    dup     v2.4s, v21.s[2]         // p4
    fmla    v2.4s, v5.4s, v4.4s
    dup     v5.4s, v21.s[3]         // p5
    fmla    v5.4s, v2.4s, v4.4s     // v5: y
    fmla    v4.4s, v5.4s, v6.4s
    fadd    v4.4s, v4.4s, v1.4s     // v4: y
    // v3: fx, v4: y
    fcvtzs  v3.4s, v3.4s            // v3: mm
    movi    v2.4s, #0x7f
    add     v2.4s, v2.4s, v3.4s     // v2: mm
    shl     v2.4s, v2.4s, #23
    fmul    v4.4s, v4.4s, v2.4s     // v4: y
    // v4: exp(x)
    fadd    v4.4s, v4.4s, v1.4s
    fdiv    v0.4s, v0.4s, v4.4s
    st1     {v0.4s}, [x0], #16
    st1     {v0.4s}, [x2], #16
    // ------------------------------------------------------

    ld1     {v0.4s}, [x0]
    fadd    v0.4s, v0.4s, v26.4s

    // activation part ------------------------------------------ 3
    fneg     v4.4s, v0.4s           // v4: -x
    fmin    v4.4s, v4.4s, v16.4s 
    fmax    v4.4s, v4.4s, v17.4s    // v4: x
    dup     v3.4s, v20.s[3]         // 0.5
    fmla    v3.4s, v4.4s, v18.4s    // 0.5 + x*LOG2EF   v3: fx
    fcvtzs  v5.4s, v3.4s            // float to int
    scvtf   v5.4s, v5.4s            // int to float     v5: tmp
    fcmgt   v6.4s, v5.4s, v3.4s     // v6: mask = (tmp > fx) ? 0xFFFFFFFF : 0x00000000
    and     v6.16b, v6.16b, v1.16b  // v6: mask
    fsub    v3.4s, v5.4s, v6.4s     // v3: fx = tmp - mask
    fmul    v5.4s, v3.4s, v7.4s    // v5: tmp
    fmul    v6.4s, v3.4s, v19.4s    // v6: z
    fsub    v4.4s, v4.4s, v5.4s
    fsub    v4.4s, v4.4s, v6.4s     // v4: x
    fmul    v6.4s, v4.4s, v4.4s     // v6: z
    // v1: one, v3: fx, v4: x, v6: z
    dup     v5.4s, v22.s[1]         // p1
    fmla    v5.4s, v23.4s, v4.4s
    dup     v2.4s, v22.s[2]         // p2
    fmla    v2.4s, v5.4s, v4.4s
    dup     v5.4s, v22.s[3]         // p3
    fmla    v5.4s, v2.4s, v4.4s
    dup     v2.4s, v21.s[2]         // p4
    fmla    v2.4s, v5.4s, v4.4s
    dup     v5.4s, v21.s[3]         // p5
    fmla    v5.4s, v2.4s, v4.4s     // v5: y
    fmla    v4.4s, v5.4s, v6.4s
    fadd    v4.4s, v4.4s, v1.4s     // v4: y
    // v3: fx, v4: y
    fcvtzs  v3.4s, v3.4s            // v3: mm
    movi    v2.4s, #0x7f
    add     v2.4s, v2.4s, v3.4s     // v2: mm
    shl     v2.4s, v2.4s, #23
    fmul    v4.4s, v4.4s, v2.4s     // v4: y
    // v4: exp(x)
    fadd    v4.4s, v4.4s, v1.4s
    fdiv    v0.4s, v0.4s, v4.4s
    st1     {v0.4s}, [x0], #16
    st1     {v0.4s}, [x2], #16
    // ------------------------------------------------------

    ld1     {v0.4s}, [x0]
    fadd    v0.4s, v0.4s, v27.4s

    // activation part ------------------------------------------ 4
    fneg     v4.4s, v0.4s           // v4: -x
    fmin    v4.4s, v4.4s, v16.4s 
    fmax    v4.4s, v4.4s, v17.4s    // v4: x
    dup     v3.4s, v20.s[3]         // 0.5
    fmla    v3.4s, v4.4s, v18.4s    // 0.5 + x*LOG2EF   v3: fx
    fcvtzs  v5.4s, v3.4s            // float to int
    scvtf   v5.4s, v5.4s            // int to float     v5: tmp
    fcmgt   v6.4s, v5.4s, v3.4s     // v6: mask = (tmp > fx) ? 0xFFFFFFFF : 0x00000000
    and     v6.16b, v6.16b, v1.16b  // v6: mask
    fsub    v3.4s, v5.4s, v6.4s     // v3: fx = tmp - mask
    fmul    v5.4s, v3.4s, v7.4s    // v5: tmp
    fmul    v6.4s, v3.4s, v19.4s    // v6: z
    fsub    v4.4s, v4.4s, v5.4s
    fsub    v4.4s, v4.4s, v6.4s     // v4: x
    fmul    v6.4s, v4.4s, v4.4s     // v6: z
    // v1: one, v3: fx, v4: x, v6: z
    dup     v5.4s, v22.s[1]         // p1
    fmla    v5.4s, v23.4s, v4.4s
    dup     v2.4s, v22.s[2]         // p2
    fmla    v2.4s, v5.4s, v4.4s
    dup     v5.4s, v22.s[3]         // p3
    fmla    v5.4s, v2.4s, v4.4s
    dup     v2.4s, v21.s[2]         // p4
    fmla    v2.4s, v5.4s, v4.4s
    dup     v5.4s, v21.s[3]         // p5
    fmla    v5.4s, v2.4s, v4.4s     // v5: y
    fmla    v4.4s, v5.4s, v6.4s
    fadd    v4.4s, v4.4s, v1.4s     // v4: y
    // v3: fx, v4: y
    fcvtzs  v3.4s, v3.4s            // v3: mm
    movi    v2.4s, #0x7f
    add     v2.4s, v2.4s, v3.4s     // v2: mm
    shl     v2.4s, v2.4s, #23
    fmul    v4.4s, v4.4s, v2.4s     // v4: y
    // v4: exp(x)
    fadd    v4.4s, v4.4s, v1.4s
    fdiv    v0.4s, v0.4s, v4.4s
    st1     {v0.4s}, [x0], #16
    st1     {v0.4s}, [x2], #16
    // ------------------------------------------------------

    subs    x12, x12, #16
    bgt .oc_second_half_loop

    // -------------------------------------------
    add x0, x0, x5, lsl #1  // make a gap for last answer (OC/2 *4bytes = OC*2)
    // ------------------------------------------------------
    subs   x11, x11, #1
    bgt .ow_loop

    movi v0.4s, #0
    mov x11, x5
.oc_zero_loop:
    st1 {v0.4s}, [x2], #16
    subs x11, x11, #4
    bgt .oc_zero_loop

    subs    x10, x10, #1
    bgt .oh_loop


    // v0 is still zero
    mov     x8, x1
    add     x11, x3, #1
    mul     x11, x11, x4 // (SIZE+1)*(IC/2)
    lsr     x11, x11, #1
.zero_padd_loop_second:
    st1     {v0.4s}, [x2], #16
    subs    x11, x11, #4
    bgt .zero_padd_loop_second


    ret
