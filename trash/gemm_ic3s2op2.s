.global gemm_ic3s2op2
.type gemm_ic3s2op2, %function

.extern exp_pack1
.extern exp_pack2
.extern exp_pack3

// 2 output in each iteration


gemm_ic3s2op2:
    // x0: input address
    // x1: weights address
    // x2: output address
    // x3: SIZE

    // output address:
    // x2, x14

    add x14, x2, #64

    mov     x9, #12         // IC:3 * 4bytes
    // add     x6, x3, #2      // SIZE+2
    mul     x9, x9, x3      // x9 = next input layer

    mov     x10, x0         // row0
    add     x11, x10, x9    // row1
    add     x12, x11, x9    // row2

    // input
    // v23, v24, v25 : row0      v2
    // v26, v27, v28 : row1      v3
    // v29, v30, v31 : row2      v4

    // output
    // v0, v1

    // weight
    // v16

    // activation constants
    // v5, v6, v7

    ldr     q5, exp_pack1          // v5 = {hi, lo, LOG2EF, 0.5}
    ldr     q6, exp_pack2          // v6 = {c1, c2 , p4, p5}
    ldr     q7, exp_pack3          // v7 = {p0, p1, p2, p3}

    mov     x6, x3
    lsr     x6, x6, #1      // x6 = SIZE/2  -> oh
    mov     x7, x6          // x7 = SIZE/2  -> ow
.oh_loop:

    movi    v2.4s, #0
    movi    v3.4s, #0
    movi    v4.4s, #0
.ow_loop:
    ld1     {v23.4s, v24.4s, v25.4s}, [x10], #48 // row0
    ld1     {v26.4s, v27.4s, v28.4s}, [x11], #48 // row1
    ld1     {v29.4s, v30.4s, v31.4s}, [x12], #48 // row2

    mov     x13, x1     // reset weights pointer
    mov     x8, #16
.oc_loop:
    movi    v0.4s, #0
    movi    v1.4s, #0

    // R of RGB

    ld1     {v16.4s}, [x13], #16        // w1

    fmla    v0.4s, v16.4s, v2.s[1]
    fmla    v1.4s, v16.4s, v23.s[3]

    ld1     {v16.4s}, [x13], #16        // w2

    fmla    v0.4s, v16.4s, v23.s[0]
    fmla    v1.4s, v16.4s, v24.s[2]

    ld1     {v16.4s}, [x13], #16        // w3

    fmla    v0.4s, v16.4s, v23.s[3]
    fmla    v1.4s, v16.4s, v25.s[1]

    ld1     {v16.4s}, [x13], #16        // w4

    fmla    v0.4s, v16.4s, v3.s[1]
    fmla    v1.4s, v16.4s, v26.s[3]

    ld1     {v16.4s}, [x13], #16        // w5

    fmla    v0.4s, v16.4s, v26.s[0]
    fmla    v1.4s, v16.4s, v27.s[2]

    ld1     {v16.4s}, [x13], #16        // w6

    fmla    v0.4s, v16.4s, v26.s[3]
    fmla    v1.4s, v16.4s, v28.s[1]

    ld1     {v16.4s}, [x13], #16        // w7

    fmla    v0.4s, v16.4s, v4.s[1]
    fmla    v1.4s, v16.4s, v29.s[3]

    ld1     {v16.4s}, [x13], #16        // w8

    fmla    v0.4s, v16.4s, v29.s[0]
    fmla    v1.4s, v16.4s, v30.s[2]

    ld1     {v16.4s}, [x13], #16        // w9

    fmla    v0.4s, v16.4s, v29.s[3]
    fmla    v1.4s, v16.4s, v31.s[1]


    // G of RGB

    ld1     {v16.4s}, [x13], #16        // w1

    fmla    v0.4s, v16.4s, v2.s[2]
    fmla    v1.4s, v16.4s, v24.s[0]

    ld1     {v16.4s}, [x13], #16        // w2

    fmla    v0.4s, v16.4s, v23.s[1]
    fmla    v1.4s, v16.4s, v24.s[3]

    ld1     {v16.4s}, [x13], #16        // w3

    fmla    v0.4s, v16.4s, v24.s[0]
    fmla    v1.4s, v16.4s, v25.s[2]

    ld1     {v16.4s}, [x13], #16        // w4

    fmla    v0.4s, v16.4s, v3.s[2]
    fmla    v1.4s, v16.4s, v27.s[0]

    ld1     {v16.4s}, [x13], #16        // w5

    fmla    v0.4s, v16.4s, v26.s[1]
    fmla    v1.4s, v16.4s, v27.s[3]

    ld1     {v16.4s}, [x13], #16        // w6

    fmla    v0.4s, v16.4s, v27.s[0]
    fmla    v1.4s, v16.4s, v28.s[2]

    ld1     {v16.4s}, [x13], #16        // w7

    fmla    v0.4s, v16.4s, v4.s[2]
    fmla    v1.4s, v16.4s, v30.s[0]

    ld1     {v16.4s}, [x13], #16        // w8

    fmla    v0.4s, v16.4s, v29.s[1]
    fmla    v1.4s, v16.4s, v30.s[3]

    ld1     {v16.4s}, [x13], #16        // w9

    fmla    v0.4s, v16.4s, v30.s[0]
    fmla    v1.4s, v16.4s, v31.s[2]

    // B of RGB 

    ld1     {v16.4s}, [x13], #16        // w1

    fmla    v0.4s, v16.4s, v2.s[3]
    fmla    v1.4s, v16.4s, v24.s[1]

    ld1     {v16.4s}, [x13], #16        // w2

    fmla    v0.4s, v16.4s, v23.s[2]
    fmla    v1.4s, v16.4s, v25.s[0]

    ld1     {v16.4s}, [x13], #16        // w3

    fmla    v0.4s, v16.4s, v24.s[1]
    fmla    v1.4s, v16.4s, v25.s[3]

    ld1     {v16.4s}, [x13], #16        // w4

    fmla    v0.4s, v16.4s, v3.s[3]
    fmla    v1.4s, v16.4s, v27.s[1]

    ld1     {v16.4s}, [x13], #16        // w5

    fmla    v0.4s, v16.4s, v26.s[2]
    fmla    v1.4s, v16.4s, v28.s[0]

    ld1     {v16.4s}, [x13], #16        // w6

    fmla    v0.4s, v16.4s, v27.s[1]
    fmla    v1.4s, v16.4s, v28.s[3]

    ld1     {v16.4s}, [x13], #16        // w7

    fmla    v0.4s, v16.4s, v4.s[3]
    fmla    v1.4s, v16.4s, v30.s[1]

    ld1     {v16.4s}, [x13], #16        // w8

    fmla    v0.4s, v16.4s, v29.s[2]
    fmla    v1.4s, v16.4s, v31.s[0]

    ld1     {v16.4s}, [x13], #16        // w9

    fmla    v0.4s, v16.4s, v30.s[1]
    fmla    v1.4s, v16.4s, v31.s[3]

    // SiLU -------------- activation function ----------------


    // dup     v16.4s, v5.s[0]         // hi
    // dup     v17.4s, v5.s[1]         // lo

    // fneg     v18.4s, v0.4s              // v4: -x

    // fmin    v18.4s, v18.4s, v16.4s 
    // fmax    v18.4s, v18.4s, v17.4s      // v4: x

    // dup     v16.4s, v5.s[2]             // LOG2EF
    // dup     v17.4s, v5.s[3]             // 0.5

    // fmla    v17.4s, v18.4s, v16.4s      // 0.5 + x*LOG2EF   v3: fx

    // fcvtzs  v19.4s, v17.4s              // float to int
    // scvtf   v19.4s, v19.4s              // int to float     v5: tmp
    // fcmgt   v20.4s, v19.4s, v17.4s      // v6: mask = (tmp > fx) ? 0xFFFFFFFF : 0x00000000

    // fmov    s21, #1.0
    // dup     v21.4s, v21.s[0]            // one
    // and     v20.16b, v20.16b, v21.16b   // v6: mask

    // fsub    v17.4s, v19.4s, v20.4s      // v3: fx = tmp - mask
    // dup     v16.4s, v6.s[0]             // c1
    // fmul    v19.4s, v17.4s, v16.4s      // v5: tmp
    // dup     v16.4s, v6.s[1]             // c2
    // fmul    v20.4s, v17.4s, v16.4s      // v6: z
    // fsub    v18.4s, v18.4s, v19.4s
    // fsub    v18.4s, v18.4s, v20.4s      // v4: x
    // fmul    v20.4s, v18.4s, v18.4s      // v6: z

    // // v1: one, v3: fx, v4: x, v6: z
    // dup     v16.4s, v7.s[0]             // p0
    // dup     v19.4s, v7.s[1]             // p1
    // fmla    v19.4s, v16.4s, v18.4s
    // dup     v16.4s, v7.s[2]             // p2
    // fmla    v16.4s, v19.4s, v18.4s
    // dup     v19.4s, v7.s[3]             // p3
    // fmla    v19.4s, v16.4s, v18.4s
    // dup     v16.4s, v6.s[2]             // p4
    // fmla    v16.4s, v19.4s, v18.4s
    // dup     v19.4s, v6.s[3]             // p5
    // fmla    v19.4s, v16.4s, v18.4s      // v5: y

    // fmla    v18.4s, v19.4s, v20.4s
    // fadd    v18.4s, v18.4s, v21.4s      // v4: y

    // // v3: fx, v4: y
    // fcvtzs  v17.4s, v17.4s              // v3: mm
    // movi    v16.4s, #0x7f
    // add     v16.4s, v16.4s, v17.4s      // v2: mm
    // shl     v16.4s, v16.4s, #23
    // fmul    v18.4s, v18.4s, v16.4s      // v4: y

    // // v4: exp(x)

    // fadd    v18.4s, v18.4s, v21.4s
    // fdiv    v0.4s, v0.4s, v18.4s

    // store v0
    st1     {v0.4s}, [x2], #16


    // dup     v16.4s, v5.s[0]         // hi
    // dup     v17.4s, v5.s[1]         // lo

    // fneg     v18.4s, v1.4s              // v4: -x

    // fmin    v18.4s, v18.4s, v16.4s 
    // fmax    v18.4s, v18.4s, v17.4s      // v4: x

    // dup     v16.4s, v5.s[2]             // LOG2EF
    // dup     v17.4s, v5.s[3]             // 0.5

    // fmla    v17.4s, v18.4s, v16.4s      // 0.5 + x*LOG2EF   v3: fx

    // fcvtzs  v19.4s, v17.4s              // float to int
    // scvtf   v19.4s, v19.4s              // int to float     v5: tmp
    // fcmgt   v20.4s, v19.4s, v17.4s      // v6: mask = (tmp > fx) ? 0xFFFFFFFF : 0x00000000

    // fmov    s21, #1.0
    // dup     v21.4s, v21.s[0]            // one
    // and     v20.16b, v20.16b, v21.16b   // v6: mask

    // fsub    v17.4s, v19.4s, v20.4s      // v3: fx = tmp - mask
    // dup     v16.4s, v6.s[0]             // c1
    // fmul    v19.4s, v17.4s, v16.4s      // v5: tmp
    // dup     v16.4s, v6.s[1]             // c2
    // fmul    v20.4s, v17.4s, v16.4s     // v6: z
    // fsub    v18.4s, v18.4s, v19.4s
    // fsub    v18.4s, v18.4s, v20.4s     // v4: x
    // fmul    v20.4s, v18.4s, v18.4s     // v6: z

    // // v1: one, v3: fx, v4: x, v6: z
    // dup     v16.4s, v7.s[0]             // p0
    // dup     v19.4s, v7.s[1]             // p1
    // fmla    v19.4s, v16.4s, v18.4s
    // dup     v16.4s, v7.s[2]             // p2
    // fmla    v16.4s, v19.4s, v18.4s
    // dup     v19.4s, v7.s[3]             // p3
    // fmla    v19.4s, v16.4s, v18.4s
    // dup     v16.4s, v6.s[2]             // p4
    // fmla    v16.4s, v19.4s, v18.4s
    // dup     v19.4s, v6.s[3]             // p5
    // fmla    v19.4s, v16.4s, v18.4s      // v5: y

    // fmla    v18.4s, v19.4s, v20.4s
    // fadd    v18.4s, v18.4s, v21.4s      // v4: y

    // // v3: fx, v4: y
    // fcvtzs  v17.4s, v17.4s              // v3: mm
    // movi    v16.4s, #0x7f
    // add     v16.4s, v16.4s, v17.4s      // v2: mm
    // shl     v16.4s, v16.4s, #23
    // fmul    v18.4s, v18.4s, v16.4s      // v4: y

    // // v4: exp(x)

    // fadd    v18.4s, v18.4s, v21.4s
    // fdiv    v1.4s, v1.4s, v18.4s


    // store v1
    st1     {v1.4s}, [x14], #16


    subs    x8, x8, #4
    bgt .oc_loop
    
    mov     v2.16b, v25.16b
    mov     v3.16b, v28.16b
    mov     v4.16b, v31.16b

    add x2, x2, #64
    add x14, x14, #64

    subs    x7, x7, #2
    bgt .ow_loop

    add x10, x10, x9
    add x11, x11, x9
    add x12, x12, x9

    mov     x7, x3
    lsr     x7, x7, #1

    subs    x6, x6, #1
    bgt .oh_loop

    ret
