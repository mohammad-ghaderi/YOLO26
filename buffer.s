.bss
.align 12
.global zero_buffer
zero_buffer:
    .skip 4096

.align 12
.global indirection_buffer
indirection_buffer:
    .skip 320*320*9*8           // maximum (i would reduce this if i don't use indirection for first conv)
