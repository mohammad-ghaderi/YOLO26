.global build_indirection
.type build_indirection, %function
.extern zero_buffer

// unused registers : x18..31

build_indirection:
    // x0 = input
    // x1 = indirection
    // x2 = size
    // x3 = IC

    adrp    x15, zero_buffer
    add     x15, x15, :lo12:zero_buffer

    sub     x16, x2, #2     // x16 = size - 2
    mul     x10, x2, x3     
    lsl     x10, x10, #2    // x10 = a layer size (*4 because float is 4bytes)
    add     x11, x10, x10   // x11 = two layer size
    lsl     x12, x3, #2     // x12 = IC*4bytes
    mul     x13, x16, x3    
    lsl     x13, x13, #2    // x13 = (size-2)*IC * 4bytes
    add     x17, x12, x12   // x17 = 2*IC * 4bytes

    // ################ top layer #####################

    // first one    (top left corner)
    str     x15, [x1], #8   // zero
    str     x15, [x1], #8   // zero
    str     x15, [x1], #8   // zero
    str     x15, [x1], #8   // zero
    str     x0, [x1], #8    // pos 5
    add     x7, x0, x12
    str     x7, [x1], #8    // pos 6
    str     x15, [x1], #8   // zero
    add     x8, x0, x10
    str     x8, [x1], #8    // pos 8
    add     x8, x7, x10 
    str     x8, [x1], #8    // pos 9


    // middle of top layer
    mov     x6, x16
.middle_top:
    str     x15, [x1], #8   // zero
    str     x15, [x1], #8   // zero
    str     x15, [x1], #8   // zero
    str     x0, [x1], #8    // pos 4
    add     x7, x0, x12
    str     x7, [x1], #8    // pos 5
    add     x8, x7, x12
    str     x8, [x1], #8    // pos 6
    add     x9, x0, x10
    str     x9, [x1], #8    // pos 7
    add     x9, x7, x10
    str     x9, [x1], #8    // pos 8
    add     x9, x8, x10
    str     x9, [x1], #8    // pos 9

    add     x0, x0, x12      // move kernel
    subs    x6, x6, #1
    bne .middle_top

    // last of top layer    (top right corner)
    str     x15, [x1], #8   // zero
    str     x15, [x1], #8   // zero
    str     x15, [x1], #8   // zero
    str     x0, [x1], #8    // pos 4
    add     x7, x0, x12
    str     x7, [x1], #8    // pos 5
    str     x15, [x1], #8   // zero
    add     x8, x0, x10
    str     x8, [x1], #8    // pos 7
    add     x8, x7, x10
    str     x8, [x1], #8    // pos 8
    str     x15, [x1], #8   // zero

    sub     x0, x0, x13     // mov kernel back to the start of the row
    
    // ################ middle layer #####################
    mov     x14, x16
.middle_loop:    
    // first one
    str     x15, [x1], #8   // zero
    str     x0, [x1], #8    // pos 2
    add     x7, x0, x12
    str     x7, [x1], #8    // pos 3
    str     x15, [x1], #8   // zero
    add     x8, x0, x10
    str     x8, [x1], #8    // pos 5
    add     x8, x7, x10 
    str     x8, [x1], #8    // pos 6
    str     x15, [x1], #8   // zero
    add     x8, x0, x11
    str     x8, [x1], #8    // pos 8
    add     x8, x7, x11
    str     x8, [x1], #8    // pos 9


    // middle of middle layer
    mov     x6, x16
.middle_middle:
    str     x0, [x1], #8    // pos 1
    add     x7, x0, x12
    str     x7, [x1], #8    // pos 2
    add     x8, x7, x12
    str     x8, [x1], #8    // pos 3
    add     x9, x0, x10
    str     x9, [x1], #8    // pos 4
    add     x9, x7, x10
    str     x9, [x1], #8    // pos 5
    add     x9, x8, x10
    str     x9, [x1], #8    // pos 6
    add     x9, x0, x11
    str     x9, [x1], #8    // pos 7
    add     x9, x7, x11
    str     x9, [x1], #8    // pos 8
    add     x9, x8, x11
    str     x9, [x1], #8    // pos 9

    add     x0, x0, x12      // move kernel
    subs    x6, x6, #1
    bne .middle_middle

    // last of middle layer
    str     x0, [x1], #8    // pos 1
    add     x7, x0, x12
    str     x7, [x1], #8    // pos 2
    str     x15, [x1], #8   // zero
    add     x8, x0, x10
    str     x8, [x1], #8    // pos 4
    add     x8, x7, x10
    str     x8, [x1], #8    // pos 5
    str     x15, [x1], #8   // zero
    add     x8, x0, x11
    str     x8, [x1], #8    // pos 7
    add     x8, x7, x11
    str     x8, [x1], #8    // pos 8
    str     x15, [x1], #8   // zero

    add     x0, x0, x17     // move kernel, skip last column and go first of next row

    subs    x14, x14, #1
    bne .middle_loop

    // ################ bottom layer #####################
    
    // first one of bottom layer (bottom left corner)
    str     x15, [x1], #8   // zero
    str     x0, [x1], #8    // pos 2
    add     x7, x0, x12
    str     x7, [x1], #8    // pos 3
    str     x15, [x1], #8   // zero
    add     x8, x0, x10
    str     x8, [x1], #8    // pos 5
    add     x8, x7, x10
    str     x8, [x1], #8    // pos 6
    str     x15, [x1], #8   // zero
    str     x15, [x1], #8   // zero
    str     x15, [x1], #8   // zero

    // middle of bottom layer
    mov     x6, x16
.middle_bottom:
    str     x0, [x1], #8    // pos 1
    add     x7, x0, x12
    str     x7, [x1], #8    // pos 2
    add     x8, x7, x12
    str     x8, [x1], #8    // pos 3
    add     x9, x0, x10
    str     x9, [x1], #8    // pos 4
    add     x9, x7, x10
    str     x9, [x1], #8    // pos 5
    add     x9, x8, x10
    str     x9, [x1], #8    // pos 6
    str     x15, [x1], #8   // zero
    str     x15, [x1], #8   // zero
    str     x15, [x1], #8   // zero

    add     x0, x0, x12      // move kernel
    subs    x6, x6, #1
    bne .middle_bottom

    // last of bottom layer (bottom right corner)
    str     x0, [x1], #8    // pos 1
    add     x7, x0, x12
    str     x7, [x1], #8    // pos 2
    str     x15, [x1], #8   // zero
    add     x8, x0, x10
    str     x8, [x1], #8    // pos 4
    add     x8, x7, x10
    str     x8, [x1], #8    // pos 5
    str     x15, [x1], #8   // zero
    str     x15, [x1], #8   // zero
    str     x15, [x1], #8   // zero
    str     x15, [x1], #8   // zero

    ret
