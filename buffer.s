.bss
.align 12
.global zero_buffer
zero_buffer:
    .skip 4096

.align 12
.global transformed_input
transformed_input:
    .skip 4*4*256*4


.data
.align 4
.global exp_pack1
exp_pack1:
    .float  88.3762626647949        // hi
    .float  -88.3762626647949       // lo
    .float  1.44269504088896341     // LOG2EF 
    .float  0.5                     // 0.5
.global exp_pack2    
exp_pack2:
    .float  0.693359375             // C1
    .float  -2.12194440e-4          // C2
    .float  1.6666665459E-1         // p4
    .float  5.0000001201E-1         // p5 
.global exp_pack3
exp_pack3:
    .float 1.9875691500E-4          // p0
    .float 1.3981999507E-3          // p1   
    .float 8.3334519073E-3          // p2   
    .float 4.1665795894E-2          // p3
