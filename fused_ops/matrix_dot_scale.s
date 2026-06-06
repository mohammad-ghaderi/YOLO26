.global matrix_dot_scale
.type matrix_dot_scale, %function

// i will optimize

matrix_dot_scale:
    // x0: matrix A address
    // x1: matrix B address
    // x2: output address

    mov x8, x0

    adrp x4, .Lconstant
    ldr s29, [x4, :lo12:.Lconstant]     // scale amount

    mov x10, #400   // i
.i_loop:
    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x8], #64
    ld1     {v4.4s, v5.4s, v6.4s, v7.4s}, [x8], #64
    mov x9, x1
    mov x11, #400   // j
.j_loop:
    ld1     {v16.4s, v17.4s, v18.4s, v19.4s}, [x9], #64
    ld1     {v20.4s, v21.4s, v22.4s, v23.4s}, [x9], #64

    movi    v31.4s, #0

    fmla    v31.4s, v16.4s, v0.4s
    fmla    v31.4s, v17.4s, v1.4s
    fmla    v31.4s, v18.4s, v2.4s
    fmla    v31.4s, v19.4s, v3.4s
    fmla    v31.4s, v20.4s, v4.4s
    fmla    v31.4s, v21.4s, v5.4s
    fmla    v31.4s, v22.4s, v6.4s
    fmla    v31.4s, v23.4s, v7.4s   
    
    faddp v30.4s, v31.4s, v31.4s    // v30 = [a+b, c+d, a+b, c+d]
    faddp v31.4s, v30.4s, v30.4s    // v31 = [sum, sum, sum, sum]

    fmul s31, s31, s29              // scale the final sum
    
    str s31, [x2], #4                       // store to memory (4 bytes)

    subs x11, x11, #1
    bgt .j_loop
    
    subs x10, x10, #1
    bgt .i_loop

    ret

.section .rodata
.align 4
.Lconstant:
    .float 0.1767766952966369
    .size .Lconstant, 4
