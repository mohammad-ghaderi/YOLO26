.global tensor_sum
.type tensor_sum, %function


tensor_sum:
    // x0: A address
    // x1: B address
    // x2: output address
    // x3: number
    // x4: output gap

.loop:
    // 0:31
    ld1     {v16.4s, v17.4s, v18.4s, v19.4s}, [x1], #64
    ld1     {v20.4s, v21.4s, v22.4s, v23.4s}, [x1], #64

    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x0], #64
    ld1     {v4.4s, v5.4s, v6.4s, v7.4s}, [x0], #64

    fadd    v0.4s, v0.4s, v16.4s
    fadd    v1.4s, v1.4s, v17.4s
    fadd    v2.4s, v2.4s, v18.4s
    fadd    v3.4s, v3.4s, v19.4s
    fadd    v4.4s, v4.4s, v20.4s
    fadd    v5.4s, v5.4s, v21.4s
    fadd    v6.4s, v6.4s, v22.4s
    fadd    v7.4s, v7.4s, v23.4s

    st1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x2], #64
    st1     {v4.4s, v5.4s, v6.4s, v7.4s}, [x2], #64
    // 32:63
    ld1     {v16.4s, v17.4s, v18.4s, v19.4s}, [x1], #64
    ld1     {v20.4s, v21.4s, v22.4s, v23.4s}, [x1], #64

    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x0], #64
    ld1     {v4.4s, v5.4s, v6.4s, v7.4s}, [x0], #64

    fadd    v0.4s, v0.4s, v16.4s
    fadd    v1.4s, v1.4s, v17.4s
    fadd    v2.4s, v2.4s, v18.4s
    fadd    v3.4s, v3.4s, v19.4s
    fadd    v4.4s, v4.4s, v20.4s
    fadd    v5.4s, v5.4s, v21.4s
    fadd    v6.4s, v6.4s, v22.4s
    fadd    v7.4s, v7.4s, v23.4s

    st1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x2], #64
    st1     {v4.4s, v5.4s, v6.4s, v7.4s}, [x2], #64
    // 64:95
    ld1     {v16.4s, v17.4s, v18.4s, v19.4s}, [x1], #64
    ld1     {v20.4s, v21.4s, v22.4s, v23.4s}, [x1], #64

    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x0], #64
    ld1     {v4.4s, v5.4s, v6.4s, v7.4s}, [x0], #64

    fadd    v0.4s, v0.4s, v16.4s
    fadd    v1.4s, v1.4s, v17.4s
    fadd    v2.4s, v2.4s, v18.4s
    fadd    v3.4s, v3.4s, v19.4s
    fadd    v4.4s, v4.4s, v20.4s
    fadd    v5.4s, v5.4s, v21.4s
    fadd    v6.4s, v6.4s, v22.4s
    fadd    v7.4s, v7.4s, v23.4s

    st1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x2], #64
    st1     {v4.4s, v5.4s, v6.4s, v7.4s}, [x2], #64
    // 96:127
    ld1     {v16.4s, v17.4s, v18.4s, v19.4s}, [x1], #64
    ld1     {v20.4s, v21.4s, v22.4s, v23.4s}, [x1], #64

    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x0], #64
    ld1     {v4.4s, v5.4s, v6.4s, v7.4s}, [x0], #64

    fadd    v0.4s, v0.4s, v16.4s
    fadd    v1.4s, v1.4s, v17.4s
    fadd    v2.4s, v2.4s, v18.4s
    fadd    v3.4s, v3.4s, v19.4s
    fadd    v4.4s, v4.4s, v20.4s
    fadd    v5.4s, v5.4s, v21.4s
    fadd    v6.4s, v6.4s, v22.4s
    fadd    v7.4s, v7.4s, v23.4s

    st1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x2], #64
    st1     {v4.4s, v5.4s, v6.4s, v7.4s}, [x2], #64

    add x2, x2, x4

    subs x3, x3, #128
    bgt .loop


    ret
