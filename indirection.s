.global build_indirection
.type build_indirection, %function
.extern zero_buffer

build_indirection:
    // x0 = input
    // x1 = indirection
    // x2 = size
    // x3 = IC

    adrp x5, zero_buffer
    add  x5, x5, :lo12:zero_buffer

    mov x6, #0         // oy
oy_loop:
    mov x7, #0         // ox
    subs x10, x6, #1    // x10 = oy - 1
ox_loop:
    mov x8, #0         // ky
    subs x11, x7, #1    // x11 = ox - 1
ky_loop:
    mov x9, #0         // kx
    add x12, x10, x8    // iy
kx_loop:
    add x13, x11, x9     // ix

    cmp x12, #0
    blt zero_padding
    cmp x13, #0
    blt zero_padding
    cmp x12, x2
    bge zero_padding
    cmp x13, x2
    bge zero_padding

    mul x14, x12, x2
    add x14, x14, x13
    mul x14, x14, x3    // x14 = offset -> (iy*W + ix)*IC
    add x14, x0, x14
    str x14, [x1], #8

    b loop_inc
zero_padding:
    str x5, [x1], #8

loop_inc:
    add x9, x9, #1
    cmp x9, #3
    blt kx_loop

    add x8, x8, #1
    cmp x8, #3
    blt ky_loop

    add x7, x7, #1
    cmp x7, x2
    blt ox_loop

    add x6, x6, #1
    cmp x6, x2
    blt oy_loop

    ret
