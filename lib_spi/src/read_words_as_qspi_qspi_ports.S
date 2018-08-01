// Copyright (c) 2016-2018, XMOS Ltd, All rights reserved

//Read words for QSPI QSPI mode.  That is all data is input from the SIO port one
//word at a time.  As all the bits are doubled up so it takes two words to make
//up the required word.

#if defined(__XS2A__)

#define STACKWORDS          8 //TODO: how to calculate?

#define EIGHT_CLOCK_EDGES   16 //doubled up

//Registers
#define QSPI_PORTS          r0
#define RX_DATA             r1
#define NUM_DATA            r2
#define SCLK                r3
#define SIO                 r4
#define CLK_EDGES           r5
#define PORT_TIME           r6
#define WORD_IN_ONE         r6
#define PORT_DELAY          r7
#define WORD_IN_TWO         r7
#define INDEX               r9
#define CLK_START_END       r10

//Data Pool for clock edges
.section  .dp.data,"awd",@progbits
.align 4
.cc_top clock_edge_data.datum
clock_edges_cpol_zero:
  .word 0xAAAA //8 edges (doubled up to 16)
clock_edges_cpol_one:
  .word 0x5555 //8 edges (doubled up to 16)
.cc_bottom clock_edge_data.datum
.text

////////////////////////////////////////////////////////////////////////////////
//qspi_port_qspi_mode_zero_read_words_asm
//
//Reads words from memory up to and including speeds of 50MHz
//
//in      - internal_handle : spi_handle_t
//out     - rx_bytes : char*
//in      - num_bytes : unsigned
//return  - void
////////////////////////////////////////////////////////////////////////////////

.cc_top qspi_port_qspi_mode_zero_read_words_asm.function
.globl  qspi_port_qspi_mode_zero_read_words_asm
.align  4
.type qspi_port_qspi_mode_zero_read_words_asm,@function

qspi_port_qspi_mode_zero_read_words_asm:
.issue_mode dual
  DUALENTSP_lu6 STACKWORDS

  //Callee save registers: TODO: why SP[1]..SP[3]
  std r4, r5, sp[1]
  std r6, r7, sp[2]
  std r8, r9, sp[3]

  //Deducting one from NUM_DATA from the get-go to enable 1 byte reads below...
  {ldw SIO, QSPI_PORTS[2]; sub NUM_DATA, NUM_DATA, 1}
  //Initialising the INDEX to -1
  {ldw SCLK, QSPI_PORTS[1]; mkmsk INDEX, 32}
  //Mode 0 requires cpol 0 clock edges
  //cpol 0 starts/finish low
  {ldw CLK_EDGES, dp[clock_edges_cpol_zero]; ldc CLK_START_END, 0}
  outpw res[SCLK], CLK_START_END, 1

  bl qspi_port_read_words_asm

  //Callee restore registers
  ldd r4, r5, sp[1]
  ldd r6, r7, sp[2]
  ldd r8, r9, sp[3]

  retsp STACKWORDS

.qspi_port_qspi_mode_zero_read_words_asm_tmp:
  .size qspi_port_qspi_mode_zero_read_words_asm, .qspi_port_qspi_mode_zero_read_words_asm_tmp - qspi_port_qspi_mode_zero_read_words_asm
  .align  4
  .cc_bottom qspi_port_qspi_mode_zero_read_words_asm.function


////////////////////////////////////////////////////////////////////////////////
//qspi_port_qspi_mode_one_read_words_asm
//
//Reads bytes from memory up to and including speeds of 50MHz
//
//in      - internal_handle : spi_handle_t
//in/out  - rx_bytes : char*
//in      - num_bytes : unsigned
//return  - void
////////////////////////////////////////////////////////////////////////////////

.cc_top qspi_port_qspi_mode_one_read_words_asm.function
.globl  qspi_port_qspi_mode_one_read_words_asm
.align  4
.type qspi_port_qspi_mode_one_read_words_asm,@function

qspi_port_qspi_mode_one_read_words_asm:

.issue_mode dual
  DUALENTSP_lu6 STACKWORDS

  //Callee save registers: TODO: why SP[1]..SP[3]
  std r4, r5, sp[1]
  std r6, r7, sp[2]
  std r8, r9, sp[3]

  //Deducting one from NUM_DATA from the get-go to enable 1 byte reads below...
  {ldw SIO, QSPI_PORTS[2]; sub NUM_DATA, NUM_DATA, 1}
  //Initialising the INDEX to -1
  {ldw SCLK, QSPI_PORTS[1]; mkmsk INDEX, 32}
  //Mode 1 requires cpol 0 clock edges
  //cpol 0 starts/finish low
  {ldw CLK_EDGES, dp[clock_edges_cpol_zero]; ldc CLK_START_END, 0}
  outpw res[SCLK], CLK_START_END, 1

  //TODO: Offset cpha

  bl qspi_port_read_words_asm

  //Callee restore registers
  ldd r4, r5, sp[1]
  ldd r6, r7, sp[2]
  ldd r8, r9, sp[3]

retsp STACKWORDS

.qspi_port_qspi_mode_one_read_words_asm_tmp:
  .size qspi_port_qspi_mode_one_read_words_asm, .qspi_port_qspi_mode_one_read_words_asm_tmp - qspi_port_qspi_mode_one_read_words_asm
  .align  4
  .cc_bottom qspi_port_qspi_mode_one_read_words_asm.function


////////////////////////////////////////////////////////////////////////////////
//qspi_port_qspi_mode_two_read_words_asm
//
//Reads bytes from memory up to and including speeds of 50MHz
//
//in      - internal_handle : spi_handle_t
//in/out  - rx_bytes : char*
//in      - num_bytes : unsigned
//return  - void
////////////////////////////////////////////////////////////////////////////////

.cc_top qspi_port_qspi_mode_two_read_words_asm.function
.globl  qspi_port_qspi_mode_two_read_words_asm
.align  4
.type qspi_port_qspi_mode_two_read_words_asm,@function

qspi_port_qspi_mode_two_read_words_asm:

.issue_mode dual
  DUALENTSP_lu6 STACKWORDS

  //Callee save registers: TODO: why SP[1]..SP[3]
  std r4, r5, sp[1]
  std r6, r7, sp[2]
  std r8, r9, sp[3]

  //Deducting one from NUM_DATA from the get-go to enable 1 byte reads below...
  {ldw SIO, QSPI_PORTS[2]; sub NUM_DATA, NUM_DATA, 1}
  //Initialising the INDEX to -1
  {ldw SCLK, QSPI_PORTS[1]; mkmsk INDEX, 32}
  //Mode 2 requires cpol 1 clock edges
  //cpol 1 starts/finish high
  {ldw CLK_EDGES, dp[clock_edges_cpol_one]; ldc CLK_START_END, 1}
  outpw res[SCLK], CLK_START_END, 1

  bl qspi_port_read_words_asm

  //Callee restore registers
  ldd r4, r5, sp[1]
  ldd r6, r7, sp[2]
  ldd r8, r9, sp[3]

retsp STACKWORDS

.qspi_port_qspi_mode_two_read_words_asm_tmp:
  .size qspi_port_qspi_mode_two_read_words_asm, .qspi_port_qspi_mode_two_read_words_asm_tmp - qspi_port_qspi_mode_two_read_words_asm
  .align  4
  .cc_bottom qspi_port_qspi_mode_two_read_words_asm.function


////////////////////////////////////////////////////////////////////////////////
//qspi_port_qspi_mode_three_read_words_asm
//
//Reads bytes from memory up to and including speeds of 50MHz
//
//in      - internal_handle : spi_handle_t
//in/out  - rx_bytes : char*
//in      - num_bytes : unsigned
//return  - void
////////////////////////////////////////////////////////////////////////////////

.cc_top qspi_port_qspi_mode_three_read_words_asm.function
.globl  qspi_port_qspi_mode_three_read_words_asm
.align  4
.type qspi_port_qspi_mode_three_read_words_asm,@function

qspi_port_qspi_mode_three_read_words_asm:

.issue_mode dual
  DUALENTSP_lu6 STACKWORDS

  //Callee save registers: TODO: why SP[1]..SP[3]
  std r4, r5, sp[1]
  std r6, r7, sp[2]
  std r8, r9, sp[3]

  //Deducting one from NUM_DATA from the get-go to enable 1 byte reads below...
  {ldw SIO, QSPI_PORTS[2]; sub NUM_DATA, NUM_DATA, 1}
  //Initialising the INDEX to -1
  {ldw SCLK, QSPI_PORTS[1]; mkmsk INDEX, 32}
  //Mode 3 requires cpol 1 clock edges
  //cpol 1 starts/finish high
  {ldw CLK_EDGES, dp[clock_edges_cpol_one]; ldc CLK_START_END, 1}
  outpw res[SCLK], CLK_START_END, 1

  //TODO: Offset cpha

  bl qspi_port_read_words_asm

  //Callee restore registers
  ldd r4, r5, sp[1]
  ldd r6, r7, sp[2]
  ldd r8, r9, sp[3]

retsp STACKWORDS

.qspi_port_qspi_mode_three_read_words_asm_tmp:
  .size qspi_port_qspi_mode_three_read_words_asm, .qspi_port_qspi_mode_three_read_words_asm_tmp - qspi_port_qspi_mode_three_read_words_asm
  .align  4
  .cc_bottom qspi_port_qspi_mode_three_read_words_asm.function


////////////////////////////////////////////////////////////////////////////////
//qspi_port_read_words_asm
////////////////////////////////////////////////////////////////////////////////

.cc_top qspi_port_read_words_asm.function
.globl  qspi_port_read_words_asm
.align  4
.type qspi_port_read_words_asm,@function

qspi_port_read_words_asm:

.issue_mode dual
  DUALENTSP_lu6 STACKWORDS

  //Line the QSPI_PORTS up to output the clock edges and start inputting
  //at the required times
  setc res[SIO], 0x1   //TODO: find docs on what 0x1 means for port resource type
  in PORT_TIME, res[SIO]
  getts PORT_TIME, res[SIO]
  ldc PORT_DELAY, 0x96 //TODO: configurable port setup delay
  add PORT_DELAY, PORT_TIME, PORT_DELAY
  setpt res[SCLK], PORT_DELAY
  outpw res[SCLK], CLK_EDGES, EIGHT_CLOCK_EDGES
  ldc PORT_DELAY, 0xA5 //TODO: configurable port input delay
  add PORT_DELAY, PORT_TIME, PORT_DELAY
  setpt res[SIO], PORT_DELAY

  //There is only one word of data to read:
  //skip on down to read the final(only) byte...
  bf NUM_DATA, qspi_port_qspi_mode_read_words_asm_final_byte

qspi_port_qspi_mode_read_words_asm_loop:

  //Output clock edges to carry data that will be input on the next iteration
  outpw res[SCLK], CLK_EDGES, EIGHT_CLOCK_EDGES

  //Input and process the data that arrived on the current iteration
  {in WORD_IN_ONE, res[SIO]; add INDEX, INDEX, 1}
  {in WORD_IN_TWO, res[SIO]; sub NUM_DATA, NUM_DATA, 1}

  //Format Data
  {byterev WORD_IN_ONE, WORD_IN_ONE; byterev WORD_IN_TWO, WORD_IN_TWO}
  unzip WORD_IN_ONE, WORD_IN_TWO, 2
  byterev WORD_IN_ONE, WORD_IN_ONE

  //Store the result in the destination
  stw WORD_IN_ONE, RX_DATA[INDEX]

  //Go back around the loop if more data to read...
  bt NUM_DATA, qspi_port_qspi_mode_read_words_asm_loop

qspi_port_qspi_mode_read_words_asm_final_byte:

  //Set clock back to low in CPOL 0
  {in WORD_IN_ONE, res[SIO]; add INDEX, INDEX, 1}
  outpw res[SCLK], CLK_START_END, 1
  in WORD_IN_TWO, res[SIO]

  //Format Data
  {byterev WORD_IN_ONE, WORD_IN_ONE; byterev WORD_IN_TWO, WORD_IN_TWO}
  unzip WORD_IN_ONE, WORD_IN_TWO, 2
  byterev WORD_IN_ONE, WORD_IN_ONE

  //Store the result in the destination
  stw WORD_IN_ONE, RX_DATA[INDEX]

  //Wait for SCLK to complete
  syncr res[SCLK]

  retsp STACKWORDS

.qspi_port_read_words_asm_tmp:
  .size qspi_port_read_words_asm, .qspi_port_read_words_asm_tmp - qspi_port_read_words_asm
  .align  4
  .cc_bottom qspi_port_read_words_asm.function

#endif //defined(__XS2A__)
