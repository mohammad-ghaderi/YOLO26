.global bias_act_sum_oc16, bias_act_sum
.type bias_act_sum_oc16, %function
.type bias_act_sum, %function


bias_act_sum_oc16:
    // x0 : input address
    // x1 : bias
    // x2 : X to sum
    // x3 : output address
    // x4 : SIZE
    // x5 : X & Output stride

    ldr     q20, exp_pack1          // v20 = {hi, lo, LOG2EF, 0.5}
    ldr     q21, exp_pack2          // v21 = {c1, c2 , p4, p5}
    ldr     q22, exp_pack3          // v22 = {p0, p1, p2, p3}

    fmov    s1, #1.0
    dup     v1.4s, v1.s[0]          // one

    dup     v16.4s, v20.s[0]         // hi
    dup     v17.4s, v20.s[1]         // lo
    
    dup     v18.4s, v20.s[2]         // LOG2EF
    dup     v24.4s, v21.s[0]         // c1
    dup     v25.4s, v21.s[1]         // c2

    dup     v26.4s, v22.s[0]         // p0

    mov     x8, x1

    ld1     {v28.4s, v29.4s, v30.4s, v31.4s}, [x8], #64       // bias for 16 oc
    mov x10, x4
.oh_loop_oc16:
    mov x11, x4
.ow_loop_oc16:

    // later optimization:  ********************************** ********************************** later optimization **********************************
    // instead of input + bias = out then -out
    // optimized: (-bias) - input
    // (-bias) is build time and in one instruction i will subtract it

    ld1     {v0.4s}, [x0], #16
    ld1     {v7.4s}, [x2], #16      // old X
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
    fmul    v5.4s, v3.4s, v24.4s    // v5: tmp
    fmul    v6.4s, v3.4s, v25.4s    // v6: z
    fsub    v4.4s, v4.4s, v5.4s
    fsub    v4.4s, v4.4s, v6.4s     // v4: x
    fmul    v6.4s, v4.4s, v4.4s     // v6: z
    // v1: one, v3: fx, v4: x, v6: z
    dup     v5.4s, v22.s[1]         // p1
    fmla    v5.4s, v26.4s, v4.4s
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
    fadd    v0.4s, v0.4s, v7.4s     // sum old X
    st1     {v0.4s}, [x3], #16
    // ------------------------------------------------------

    ld1     {v0.4s}, [x0], #16
    ld1     {v7.4s}, [x2], #16      // old X
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
    fmul    v5.4s, v3.4s, v24.4s    // v5: tmp
    fmul    v6.4s, v3.4s, v25.4s    // v6: z
    fsub    v4.4s, v4.4s, v5.4s
    fsub    v4.4s, v4.4s, v6.4s     // v4: x
    fmul    v6.4s, v4.4s, v4.4s     // v6: z
    // v1: one, v3: fx, v4: x, v6: z
    dup     v5.4s, v22.s[1]         // p1
    fmla    v5.4s, v26.4s, v4.4s
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
    fadd    v0.4s, v0.4s, v7.4s     // sum old X
    st1     {v0.4s}, [x3], #16
    // ------------------------------------------------------

    ld1     {v0.4s}, [x0], #16
    ld1     {v7.4s}, [x2], #16      // old X
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
    fmul    v5.4s, v3.4s, v24.4s    // v5: tmp
    fmul    v6.4s, v3.4s, v25.4s    // v6: z
    fsub    v4.4s, v4.4s, v5.4s
    fsub    v4.4s, v4.4s, v6.4s     // v4: x
    fmul    v6.4s, v4.4s, v4.4s     // v6: z
    // v1: one, v3: fx, v4: x, v6: z
    dup     v5.4s, v22.s[1]         // p1
    fmla    v5.4s, v26.4s, v4.4s
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
    fadd    v0.4s, v0.4s, v7.4s     // sum old X
    st1     {v0.4s}, [x3], #16
    // ------------------------------------------------------

    ld1     {v0.4s}, [x0], #16
    ld1     {v7.4s}, [x2], #16      // old X
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
    fmul    v5.4s, v3.4s, v24.4s    // v5: tmp
    fmul    v6.4s, v3.4s, v25.4s    // v6: z
    fsub    v4.4s, v4.4s, v5.4s
    fsub    v4.4s, v4.4s, v6.4s     // v4: x
    fmul    v6.4s, v4.4s, v4.4s     // v6: z
    // v1: one, v3: fx, v4: x, v6: z
    dup     v5.4s, v22.s[1]         // p1
    fmla    v5.4s, v26.4s, v4.4s
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
    fadd    v0.4s, v0.4s, v7.4s     // sum old X
    st1     {v0.4s}, [x3], #16
    // ------------------------------------------------------

    add     x2, x2, x5
    add     x3, x3, x5

    subs    x11, x11, #1
    bgt .ow_loop_oc16

    subs    x10, x10, #1
    bgt .oh_loop_oc16

    ret


bias_act_sum:
    // x0 : input address
    // x1 : bias
    // x2 : X to sum
    // x3 : output address
    // x4 : SIZE
    // x5 : Output stride
    // x6 : OC
    // x7 : X stride

    ldr     q20, exp_pack1          // v20 = {hi, lo, LOG2EF, 0.5}
    ldr     q21, exp_pack2          // v21 = {c1, c2 , p4, p5}
    ldr     q22, exp_pack3          // v22 = {p0, p1, p2, p3}

    fmov    s1, #1.0
    dup     v1.4s, v1.s[0]          // one

    dup     v16.4s, v20.s[0]         // hi
    dup     v17.4s, v20.s[1]         // lo
    
    dup     v18.4s, v20.s[2]         // LOG2EF
    dup     v24.4s, v21.s[0]         // c1
    dup     v25.4s, v21.s[1]         // c2

    dup     v26.4s, v22.s[0]         // p0


    mov x10, x4
.oh_loop:
    mov x11, x4
.ow_loop:
    mov     x8, x1
    mov x12, x6
.oc_loop:
    ld1     {v28.4s, v29.4s, v30.4s, v31.4s}, [x8], #64       // bias

    // later optimization:  ********************************** ********************************** later optimization **********************************
    // instead of input + bias = out then -out
    // optimized: (-bias) - input
    // (-bias) is build time and in one instruction i will subtract it

    ld1     {v0.4s}, [x0], #16
    ld1     {v7.4s}, [x2], #16      // old X
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
    fmul    v5.4s, v3.4s, v24.4s    // v5: tmp
    fmul    v6.4s, v3.4s, v25.4s    // v6: z
    fsub    v4.4s, v4.4s, v5.4s
    fsub    v4.4s, v4.4s, v6.4s     // v4: x
    fmul    v6.4s, v4.4s, v4.4s     // v6: z
    // v1: one, v3: fx, v4: x, v6: z
    dup     v5.4s, v22.s[1]         // p1
    fmla    v5.4s, v26.4s, v4.4s
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
    fadd    v0.4s, v0.4s, v7.4s     // sum old X
    st1     {v0.4s}, [x3], #16
    // ------------------------------------------------------

    ld1     {v0.4s}, [x0], #16
    ld1     {v7.4s}, [x2], #16      // old X
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
    fmul    v5.4s, v3.4s, v24.4s    // v5: tmp
    fmul    v6.4s, v3.4s, v25.4s    // v6: z
    fsub    v4.4s, v4.4s, v5.4s
    fsub    v4.4s, v4.4s, v6.4s     // v4: x
    fmul    v6.4s, v4.4s, v4.4s     // v6: z
    // v1: one, v3: fx, v4: x, v6: z
    dup     v5.4s, v22.s[1]         // p1
    fmla    v5.4s, v26.4s, v4.4s
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
    fadd    v0.4s, v0.4s, v7.4s     // sum old X
    st1     {v0.4s}, [x3], #16
    // ------------------------------------------------------

    ld1     {v0.4s}, [x0], #16
    ld1     {v7.4s}, [x2], #16      // old X
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
    fmul    v5.4s, v3.4s, v24.4s    // v5: tmp
    fmul    v6.4s, v3.4s, v25.4s    // v6: z
    fsub    v4.4s, v4.4s, v5.4s
    fsub    v4.4s, v4.4s, v6.4s     // v4: x
    fmul    v6.4s, v4.4s, v4.4s     // v6: z
    // v1: one, v3: fx, v4: x, v6: z
    dup     v5.4s, v22.s[1]         // p1
    fmla    v5.4s, v26.4s, v4.4s
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
    fadd    v0.4s, v0.4s, v7.4s     // sum old X
    st1     {v0.4s}, [x3], #16
    // ------------------------------------------------------

    ld1     {v0.4s}, [x0], #16
    ld1     {v7.4s}, [x2], #16      // old X
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
    fmul    v5.4s, v3.4s, v24.4s    // v5: tmp
    fmul    v6.4s, v3.4s, v25.4s    // v6: z
    fsub    v4.4s, v4.4s, v5.4s
    fsub    v4.4s, v4.4s, v6.4s     // v4: x
    fmul    v6.4s, v4.4s, v4.4s     // v6: z
    // v1: one, v3: fx, v4: x, v6: z
    dup     v5.4s, v22.s[1]         // p1
    fmla    v5.4s, v26.4s, v4.4s
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
    fadd    v0.4s, v0.4s, v7.4s     // sum old X
    st1     {v0.4s}, [x3], #16

    subs   x12, x12, #16
    bgt .oc_loop

    // ------------------------------------------------------

    add     x2, x2, x7
    add     x3, x3, x5

    subs    x11, x11, #1
    bgt .ow_loop

    subs    x10, x10, #1
    bgt .oh_loop

    ret
