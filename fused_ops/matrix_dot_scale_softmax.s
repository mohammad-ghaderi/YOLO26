.global matrix_dot_scale_softmax
.type matrix_dot_scale_softmax, %function

// i will optimize

matrix_dot_scale_softmax:
    // x0: matrix A address
    // x1: matrix B address
    // x2: output address


    mov x8, x0

    ldr     q20, exp_pack1              // v20 = {hi, lo, LOG2EF, 0.5}
    ldr     q21, exp_pack2              // v21 = {c1, c2 , p4, p5}
    ldr     q22, exp_pack3              // v22 = {p0, p1, p2, p3}
    adrp x4, .Lconstant
    ldr s29, [x4, :lo12:.Lconstant]     // scale amount

    mov x10, #400   // i
.i_loop:
    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x8], #64
    ld1     {v4.4s, v5.4s, v6.4s, v7.4s}, [x8], #64
    
    adrp x4, .neg_inf
    ldr s28, [x4, :lo12:.neg_inf]      // -inf

    mov x7, x2                  // store to rewrite for softmax
    mov x9, x1
    mov x11, #400   // j
.j_loop:
    movi    v31.4s, #0

    ld1     {v16.4s, v17.4s, v18.4s, v19.4s}, [x9], #64
    fmla    v31.4s, v16.4s, v0.4s
    fmla    v31.4s, v17.4s, v1.4s
    fmla    v31.4s, v18.4s, v2.4s
    fmla    v31.4s, v19.4s, v3.4s
    ld1     {v16.4s, v17.4s, v18.4s, v19.4s}, [x9], #64
    fmla    v31.4s, v16.4s, v4.4s
    fmla    v31.4s, v17.4s, v5.4s
    fmla    v31.4s, v18.4s, v6.4s
    fmla    v31.4s, v19.4s, v7.4s
    
    faddp v30.4s, v31.4s, v31.4s    // v30 = [a+b, c+d, a+b, c+d]
    faddp v31.4s, v30.4s, v30.4s    // v31 = [sum, sum, sum, sum]

    fmul s31, s31, s29              // scale the final sum
    
    str s31, [x2], #4                       // store to memory (4 bytes)
    fmax s28, s28, s31

    subs x11, x11, #1
    bgt .j_loop

    movi    v27.4s, #0              // sum = 0

    dup v28.4s, v28.s[0]            // v28 = [max, max, max, max]
    mov x2, x7
    mov x11, #400
.exp_loop:
    ld1     {v16.4s}, [x2]
    fsub    v16.4s, v16.4s, v28.4s      // x = (x - max)

    dup     v18.4s, v20.s[0]            // hi
    dup     v19.4s, v20.s[1]            // lo

    fmin    v23.4s, v16.4s, v18.4s 
    fmax    v23.4s, v23.4s, v19.4s      // v23: x

    dup     v18.4s, v20.s[2]            // LOG2EF
    dup     v19.4s, v20.s[3]            // 0.5

    fmla    v19.4s, v23.4s, v18.4s      // 0.5 + x*LOG2EF   v19: fx

    fcvtzs  v24.4s, v19.4s              // float to int
    scvtf   v24.4s, v24.4s              // int to float     v24: tmp
    fcmgt   v25.4s, v24.4s, v19.4s      // v25: mask = (tmp > fx) ? 0xFFFFFFFF : 0x00000000

    fmov    s17, #1.0
    dup     v17.4s, v17.s[0]            // one
    and     v25.16b, v25.16b, v17.16b   // v25: mask

    fsub    v19.4s, v24.4s, v25.4s      // v19: fx = tmp - mask
    dup     v18.4s, v21.s[0]            // c1
    fmul    v24.4s, v19.4s, v18.4s      // v24: tmp
    dup     v18.4s, v21.s[1]            // c2
    fmul    v25.4s, v19.4s, v18.4s      // v25: z
    fsub    v23.4s, v23.4s, v24.4s
    fsub    v23.4s, v23.4s, v25.4s      // v23: x
    fmul    v25.4s, v23.4s, v23.4s      // v25: z

    // v1: one, v19: fx, v23: x, v25: z
    dup     v18.4s, v22.s[0]            // p0
    dup     v24.4s, v22.s[1]            // p1
    fmla    v24.4s, v18.4s, v23.4s
    dup     v18.4s, v22.s[2]            // p2
    fmla    v18.4s, v24.4s, v23.4s
    dup     v24.4s, v22.s[3]            // p3
    fmla    v24.4s, v18.4s, v23.4s
    dup     v18.4s, v21.s[2]            // p4
    fmla    v18.4s, v24.4s, v23.4s
    dup     v24.4s, v21.s[3]            // p5
    fmla    v24.4s, v18.4s, v23.4s      // v24: y

    fmla    v23.4s, v24.4s, v25.4s
    fadd    v23.4s, v23.4s, v17.4s      // v23: y

    // v19: fx, v23: y
    fcvtzs  v19.4s, v19.4s              // v19: mm
    movi    v18.4s, #0x7f
    add     v18.4s, v18.4s, v19.4s      // v18: mm
    shl     v18.4s, v18.4s, #23
    fmul    v23.4s, v23.4s, v18.4s      // v23: y

    // v23: exp(x) ----> x = x - max

    fadd    v27.4s, v27.4s, v23.4s
    st1     {v23.4s}, [x2], #16

    subs x11, x11, #4
    bgt .exp_loop


    faddp v27.4s, v27.4s, v27.4s    // v27 = [a+b, c+d, a+b, c+d]
    faddp v27.4s, v27.4s, v27.4s    // v27 = [sum, sum, sum, sum]

    mov x2, x7
    mov x11, #400
.softmax_loop:
    ld1     {v16.4s}, [x2]
    fdiv    v16.4s, v16.4s, v27.4s
    st1     {v16.4s}, [x2], #16

    subs x11, x11, #4
    bgt .softmax_loop
    
    subs x10, x10, #1
    bgt .i_loop

    ret

.section .rodata
.align 4
.Lconstant:
    .float 0.1767766952966369
.neg_inf:
    .word 0xFF800000               // -inf as hex

.size .Lconstant, 4
.size .neg_inf, 4
