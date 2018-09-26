.section  .dp.data,"awd",@progbits
.align 4
.cc_top clock_edge_data.datum
.globl clock_edges_cpol_zero
.globl clock_edges_cpol_one
clock_edges_cpol_zero:
  .word 0xAAAA //8 edges (doubled up to 16)
clock_edges_cpol_one:
  .word 0x5555 //8 edges (doubled up to 16)
.cc_bottom clock_edge_data.datum
.text
