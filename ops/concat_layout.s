.global concat_layout
.type concat_layout, %function


concat_layout:  
    // x0: input address
    // x1: output address
    // x2: SIZE
    // x3: IC
    // x4: gap

    mul x10, x2, x2 // size*size
.hw_loop:
    mov x11, x3
.ic_loop:
    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x0], #64
    st1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x1], #64

    subs x11, x11, #16
    bgt .ic_loop

    add x1, x1, x4

    subs x10, x10, #1
    bgt .hw_loop

    ret
