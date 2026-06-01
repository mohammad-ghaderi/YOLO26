.global SiLU, SiLU_array, SiLU_array_bias_oc16, SiLU_array_bias_oc8, SiLU_array_bias_full
.type SiLU, %function
.type SiLU_array, %function
.type SiLU_array_bias_oc16, %function
.type SiLU_array_bias_oc8, %function
.type SiLU_array_bias_full, %function
// no stack, 4 input channel read in loop
// with two loop ky kx
// this code is the implementation of ncnn with some changes

// v1, v2, v3, v4, v5, v6

SiLU:
    // x0 : input address

    ld1     {v0.4s}, [x0]

    ldr     q20, exp_pack1          // v20 = {hi, lo, LOG2EF, 0.5}
    ldr     q21, exp_pack2          // v21 = {c1, c2 , p4, p5}
    ldr     q22, exp_pack3          // v22 = {p0, p1, p2, p3}

    dup     v2.4s, v20.s[0]         // hi
    dup     v3.4s, v20.s[1]         // lo

    fneg     v4.4s, v0.4s            // v4: -x

    fmin    v4.4s, v4.4s, v2.4s 
    fmax    v4.4s, v4.4s, v3.4s     // v4: x

    dup     v2.4s, v20.s[2]         // LOG2EF
    dup     v3.4s, v20.s[3]         // 0.5

    fmla    v3.4s, v4.4s, v2.4s     // 0.5 + x*LOG2EF   v3: fx

    fcvtzs  v5.4s, v3.4s            // float to int
    scvtf   v5.4s, v5.4s            // int to float     v5: tmp
    fcmgt   v6.4s, v5.4s, v3.4s     // v6: mask = (tmp > fx) ? 0xFFFFFFFF : 0x00000000

    fmov    s1, #1.0
    dup     v1.4s, v1.s[0]          // one
    and     v6.16b, v6.16b, v1.16b  // v6: mask

    fsub    v3.4s, v5.4s, v6.4s     // v3: fx = tmp - mask
    dup     v2.4s, v21.s[0]         // c1
    fmul    v5.4s, v3.4s, v2.4s     // v5: tmp
    dup     v2.4s, v21.s[1]         // c2
    fmul    v6.4s, v3.4s, v2.4s     // v6: z
    fsub    v4.4s, v4.4s, v5.4s
    fsub    v4.4s, v4.4s, v6.4s     // v4: x
    fmul    v6.4s, v4.4s, v4.4s     // v6: z

    // v1: one, v3: fx, v4: x, v6: z
    dup     v2.4s, v22.s[0]         // p0
    dup     v5.4s, v22.s[1]         // p1
    fmla    v5.4s, v2.4s, v4.4s
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
    st1     {v0.4s}, [x0]

    ret


SiLU_array:
    // x0 : input address
    // x1 : SIZE

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

    
    mov x10, x1
.loop:    
    ld1     {v0.4s}, [x0]


    fneg     v4.4s, v0.4s            // v4: -x

    fmin    v4.4s, v4.4s, v16.4s 
    fmax    v4.4s, v4.4s, v17.4s     // v4: x

    dup     v3.4s, v20.s[3]         // 0.5

    fmla    v3.4s, v4.4s, v18.4s     // 0.5 + x*LOG2EF   v3: fx

    fcvtzs  v5.4s, v3.4s            // float to int
    scvtf   v5.4s, v5.4s            // int to float     v5: tmp
    fcmgt   v6.4s, v5.4s, v3.4s     // v6: mask = (tmp > fx) ? 0xFFFFFFFF : 0x00000000

    and     v6.16b, v6.16b, v1.16b  // v6: mask

    fsub    v3.4s, v5.4s, v6.4s     // v3: fx = tmp - mask
    fmul    v5.4s, v3.4s, v24.4s     // v5: tmp
    fmul    v6.4s, v3.4s, v25.4s     // v6: z
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
    st1     {v0.4s}, [x0], #16

    subs    x10, x10, #4
    bgt .loop

    ret

SiLU_array_bias_oc16:
    // x0 : input address
    // x1 : bias
    // x2 : SIZE

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

    lsr x10, x2, #4
    ld1     {v28.4s, v29.4s, v30.4s, v31.4s}, [x8], #64       // bias for 16 oc
.main_loop_oc16:    


    // later optimization:  ********************************** ********************************** later optimization **********************************
    // instead of input + bias = out then -out
    // optimized: (-bias) - input
    // (-bias) is build time and in one instruction i will subtract it

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
    st1     {v0.4s}, [x0], #16
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
    st1     {v0.4s}, [x0], #16
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
    st1     {v0.4s}, [x0], #16
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
    st1     {v0.4s}, [x0], #16
    // ------------------------------------------------------


    subs    x10, x10, #1
    bgt .main_loop_oc16

    ret


SiLU_array_bias_oc8:
    // x0 : input address
    // x1 : bias
    // x2 : SIZE

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

    lsr x10, x2, #3
    ld1     {v28.4s, v29.4s}, [x8], #32       // bias for 8 oc
.main_loop_oc8:    


    // later optimization:  ********************************** ********************************** later optimization **********************************
    // instead of input + bias = out then -out
    // optimized: (-bias) - input
    // (-bias) is build time and in one instruction i will subtract it

    ld1     {v0.4s}, [x0]
    fadd    v0.4s, v0.4s, v28.4s

    // activation part ------------------------------------------ 1
    fneg    v4.4s, v0.4s            // v4: -x
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
    st1     {v0.4s}, [x0], #16
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
    st1     {v0.4s}, [x0], #16
    // ------------------------------------------------------

    subs    x10, x10, #1
    bgt .main_loop_oc8

    ret


SiLU_array_bias_full:
    // x0 : input address
    // x1 : bias
    // x2 : SIZE
    // x3 : OC
    // x4 : output stride

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
    lsr     x11, x3, #4             // OC/16

    mov     x10, x2                 // SIZE*SIZE*OC
._loop:    
    ld1     {v28.4s, v29.4s, v30.4s, v31.4s}, [x8], #64       // bias for 16 oc

    // later optimization:  ********************************** ********************************** later optimization **********************************
    // instead of input + bias = out then -out
    // optimized: (-bias) - input
    // (-bias) is build time and in one instruction i will subtract it

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
    st1     {v0.4s}, [x0], #16
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
    st1     {v0.4s}, [x0], #16
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
    st1     {v0.4s}, [x0], #16
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
    st1     {v0.4s}, [x0], #16
    // ------------------------------------------------------

    subs    x11, x11, #1
    bne  ._not_end_of_OC
    mov x8, x1
    lsr     x11, x3, #4             // OC/16
    add x0, x0, x4                 // skip the gap
._not_end_of_OC:

    subs    x10, x10, #16
    bgt ._loop

    ret




    .align 4
exp_pack1:
    .float  88.3762626647949        // hi
    .float  -88.3762626647949       // lo
    .float  1.44269504088896341     // LOG2EF 
    .float  0.5                     // 0.5
    
exp_pack2:
    .float  0.693359375             // C1
    .float  -2.12194440e-4          // C2
    .float  1.6666665459E-1         // p4
    .float  5.0000001201E-1         // p5 

exp_pack3:
    .float 1.9875691500E-4          // p0
    .float 1.3981999507E-3          // p1   
    .float 8.3334519073E-3          // p2   
    .float 4.1665795894E-2          // p3
