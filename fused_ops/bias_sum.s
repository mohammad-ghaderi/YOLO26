.global bias_sum
.type bias_sum, %function


bias_sum:
    // x0: input address
    // x1: bias address
    // x2: X sum address
    // x3: output address
    // x4: number

    mov x5, x1

.loop:
    // 0:31
    ld1     {v16.4s, v17.4s, v18.4s, v19.4s}, [x1], #64
    ld1     {v20.4s, v21.4s, v22.4s, v23.4s}, [x1], #64

    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x0], #64
    ld1     {v4.4s, v5.4s, v6.4s, v7.4s}, [x0], #64

    ld1     {v24.4s, v25.4s, v26.4s, v27.4s}, [x2], #64
    ld1     {v28.4s, v29.4s, v30.4s, v31.4s}, [x2], #64

    fadd    v0.4s, v0.4s, v16.4s
    fadd    v1.4s, v1.4s, v17.4s
    fadd    v2.4s, v2.4s, v18.4s
    fadd    v3.4s, v3.4s, v19.4s
    fadd    v4.4s, v4.4s, v20.4s
    fadd    v5.4s, v5.4s, v21.4s
    fadd    v6.4s, v6.4s, v22.4s
    fadd    v7.4s, v7.4s, v23.4s
    fadd    v0.4s, v0.4s, v24.4s
    fadd    v1.4s, v1.4s, v25.4s
    fadd    v2.4s, v2.4s, v26.4s
    fadd    v3.4s, v3.4s, v27.4s
    fadd    v4.4s, v4.4s, v28.4s
    fadd    v5.4s, v5.4s, v29.4s
    fadd    v6.4s, v6.4s, v30.4s
    fadd    v7.4s, v7.4s, v31.4s

    st1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x3], #64
    st1     {v4.4s, v5.4s, v6.4s, v7.4s}, [x3], #64
    // 32:63
    ld1     {v16.4s, v17.4s, v18.4s, v19.4s}, [x1], #64
    ld1     {v20.4s, v21.4s, v22.4s, v23.4s}, [x1], #64

    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x0], #64
    ld1     {v4.4s, v5.4s, v6.4s, v7.4s}, [x0], #64

    ld1     {v24.4s, v25.4s, v26.4s, v27.4s}, [x2], #64
    ld1     {v28.4s, v29.4s, v30.4s, v31.4s}, [x2], #64

    fadd    v0.4s, v0.4s, v16.4s
    fadd    v1.4s, v1.4s, v17.4s
    fadd    v2.4s, v2.4s, v18.4s
    fadd    v3.4s, v3.4s, v19.4s
    fadd    v4.4s, v4.4s, v20.4s
    fadd    v5.4s, v5.4s, v21.4s
    fadd    v6.4s, v6.4s, v22.4s
    fadd    v7.4s, v7.4s, v23.4s
    fadd    v0.4s, v0.4s, v24.4s
    fadd    v1.4s, v1.4s, v25.4s
    fadd    v2.4s, v2.4s, v26.4s
    fadd    v3.4s, v3.4s, v27.4s
    fadd    v4.4s, v4.4s, v28.4s
    fadd    v5.4s, v5.4s, v29.4s
    fadd    v6.4s, v6.4s, v30.4s
    fadd    v7.4s, v7.4s, v31.4s

    st1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x3], #64
    st1     {v4.4s, v5.4s, v6.4s, v7.4s}, [x3], #64
    // 64:95
    ld1     {v16.4s, v17.4s, v18.4s, v19.4s}, [x1], #64
    ld1     {v20.4s, v21.4s, v22.4s, v23.4s}, [x1], #64

    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x0], #64
    ld1     {v4.4s, v5.4s, v6.4s, v7.4s}, [x0], #64

    ld1     {v24.4s, v25.4s, v26.4s, v27.4s}, [x2], #64
    ld1     {v28.4s, v29.4s, v30.4s, v31.4s}, [x2], #64

    fadd    v0.4s, v0.4s, v16.4s
    fadd    v1.4s, v1.4s, v17.4s
    fadd    v2.4s, v2.4s, v18.4s
    fadd    v3.4s, v3.4s, v19.4s
    fadd    v4.4s, v4.4s, v20.4s
    fadd    v5.4s, v5.4s, v21.4s
    fadd    v6.4s, v6.4s, v22.4s
    fadd    v7.4s, v7.4s, v23.4s
    fadd    v0.4s, v0.4s, v24.4s
    fadd    v1.4s, v1.4s, v25.4s
    fadd    v2.4s, v2.4s, v26.4s
    fadd    v3.4s, v3.4s, v27.4s
    fadd    v4.4s, v4.4s, v28.4s
    fadd    v5.4s, v5.4s, v29.4s
    fadd    v6.4s, v6.4s, v30.4s
    fadd    v7.4s, v7.4s, v31.4s

    st1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x3], #64
    st1     {v4.4s, v5.4s, v6.4s, v7.4s}, [x3], #64
    // 96:127
    ld1     {v16.4s, v17.4s, v18.4s, v19.4s}, [x1], #64
    ld1     {v20.4s, v21.4s, v22.4s, v23.4s}, [x1], #64

    ld1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x0], #64
    ld1     {v4.4s, v5.4s, v6.4s, v7.4s}, [x0], #64

    ld1     {v24.4s, v25.4s, v26.4s, v27.4s}, [x2], #64
    ld1     {v28.4s, v29.4s, v30.4s, v31.4s}, [x2], #64

    fadd    v0.4s, v0.4s, v16.4s
    fadd    v1.4s, v1.4s, v17.4s
    fadd    v2.4s, v2.4s, v18.4s
    fadd    v3.4s, v3.4s, v19.4s
    fadd    v4.4s, v4.4s, v20.4s
    fadd    v5.4s, v5.4s, v21.4s
    fadd    v6.4s, v6.4s, v22.4s
    fadd    v7.4s, v7.4s, v23.4s
    fadd    v0.4s, v0.4s, v24.4s
    fadd    v1.4s, v1.4s, v25.4s
    fadd    v2.4s, v2.4s, v26.4s
    fadd    v3.4s, v3.4s, v27.4s
    fadd    v4.4s, v4.4s, v28.4s
    fadd    v5.4s, v5.4s, v29.4s
    fadd    v6.4s, v6.4s, v30.4s
    fadd    v7.4s, v7.4s, v31.4s

    st1     {v0.4s, v1.4s, v2.4s, v3.4s}, [x3], #64
    st1     {v4.4s, v5.4s, v6.4s, v7.4s}, [x3], #64

    mov x1, x5

    subs x4, x4, #128
    bgt .loop


    ret
