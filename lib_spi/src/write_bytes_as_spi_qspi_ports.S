// Copyright (c) 2016-2018, XMOS Ltd, All rights reserved

//Write bytes for QSPI SPI mode.  That is all data is output from the SIO port one
//word at a time.  As all the bits are doubled up so it takes two words to make
//up the required byte.  The data must be transmitted from pin IO0 (SI) of the
//4 pin port.

#if defined(__XS2A__)

#define STACKWORDS          8 //TODO: how to calculate?

#define EIGHT_CLOCK_EDGES   16 //doubled up

//Registers
#define QSPI_PORTS          r0
#define TX_DATA             r1
#define NUM_DATA            r2
#define SCLK                r3
#define SIO                 r4
#define CLK_EDGES           r5
#define WORD_OUT_ONE        r6
#define WORD_OUT_TWO        r7
#define ZIP_OUT          r8
#define INDEX               r9
#define CLK_START_END       r10

#define PORT_DELAY          r8
#define PORT_TIME           r11

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
//qspi_port_spi_mode_zero_write_bytes_asm
//
//Writes bytes from memory up to and including speeds of 50MHz
//
//in      - internal_handle : spi_handle_t
//out     - tx_bytes : char*
//in      - num_bytes : unsigned
//return  - void
////////////////////////////////////////////////////////////////////////////////

.cc_top qspi_port_spi_mode_zero_write_bytes_asm.function
.globl  qspi_port_spi_mode_zero_write_bytes_asm
.align  4
.type qspi_port_spi_mode_zero_write_bytes_asm,@function

qspi_port_spi_mode_zero_write_bytes_asm:
.issue_mode dual
  DUALENTSP_lu6 STACKWORDS

  //Callee save registers: TODO: why SP[1]..SP[3]
  std r4, r5, sp[1]
  std r6, r7, sp[2]
  std r8, r9, sp[3]

  //Deducting one from NUM_DATA from the get-go to enable 1 byte reads below...
  {ldw SIO, QSPI_PORTS[1]; sub NUM_DATA, NUM_DATA, 1}
  //Initialising the INDEX to -1
  {ldw SCLK, QSPI_PORTS[2]; mkmsk INDEX, 32}
  //Mode 0 requires cpol 0 clock edges
  //cpol 0 starts/finish low
  {ldw CLK_EDGES, dp[clock_edges_cpol_zero]; ldc CLK_START_END, 0}
  outpw res[SCLK], CLK_START_END, 1

  bl qspi_port_write_bytes_asm

  //Callee restore registers
  ldd r4, r5, sp[1]
  ldd r6, r7, sp[2]
  ldd r8, r9, sp[3]

  retsp STACKWORDS

.qspi_port_spi_mode_zero_write_bytes_asm_tmp:
  .size qspi_port_spi_mode_zero_write_bytes_asm, .qspi_port_spi_mode_zero_write_bytes_asm_tmp - qspi_port_spi_mode_zero_write_bytes_asm
  .align  4
  .cc_bottom qspi_port_spi_mode_zero_write_bytes_asm.function


////////////////////////////////////////////////////////////////////////////////
//qspi_port_spi_mode_one_write_bytes_asm
//
//Writes bytes from memory up to and including speeds of 50MHz
//
//in      - internal_handle : spi_handle_t
//out     - tx_bytes : char*
//in      - num_bytes : unsigned
//return  - void
////////////////////////////////////////////////////////////////////////////////

.cc_top qspi_port_spi_mode_one_write_bytes_asm.function
.globl  qspi_port_spi_mode_one_write_bytes_asm
.align  4
.type qspi_port_spi_mode_one_write_bytes_asm,@function

qspi_port_spi_mode_one_write_bytes_asm:

.issue_mode dual
  DUALENTSP_lu6 STACKWORDS

  //Callee save registers: TODO: why SP[1]..SP[3]
  std r4, r5, sp[1]
  std r6, r7, sp[2]
  std r8, r9, sp[3]

  //TODO:

  //Callee restore registers
  ldd r4, r5, sp[1]
  ldd r6, r7, sp[2]
  ldd r8, r9, sp[3]

retsp STACKWORDS

.qspi_port_spi_mode_one_write_bytes_asm_tmp:
  .size qspi_port_spi_mode_one_write_bytes_asm, .qspi_port_spi_mode_one_write_bytes_asm_tmp - qspi_port_spi_mode_one_write_bytes_asm
  .align  4
  .cc_bottom qspi_port_spi_mode_one_write_bytes_asm.function


////////////////////////////////////////////////////////////////////////////////
//qspi_port_spi_mode_two_write_bytes_asm
//
//Writes bytes from memory up to and including speeds of 50MHz
//
//in      - internal_handle : spi_handle_t
//out     - tx_bytes : char*
//in      - num_bytes : unsigned
//return  - void
////////////////////////////////////////////////////////////////////////////////

.cc_top qspi_port_spi_mode_two_write_bytes_asm.function
.globl  qspi_port_spi_mode_two_write_bytes_asm
.align  4
.type qspi_port_spi_mode_two_write_bytes_asm,@function

qspi_port_spi_mode_two_write_bytes_asm:

.issue_mode dual
  DUALENTSP_lu6 STACKWORDS

  //Callee save registers: TODO: why SP[1]..SP[3]
  std r4, r5, sp[1]
  std r6, r7, sp[2]
  std r8, r9, sp[3]

  //TODO:

  //Callee restore registers
  ldd r4, r5, sp[1]
  ldd r6, r7, sp[2]
  ldd r8, r9, sp[3]

retsp STACKWORDS

.qspi_port_spi_mode_two_write_bytes_asm_tmp:
  .size qspi_port_spi_mode_two_write_bytes_asm, .qspi_port_spi_mode_two_write_bytes_asm_tmp - qspi_port_spi_mode_two_write_bytes_asm
  .align  4
  .cc_bottom qspi_port_spi_mode_two_write_bytes_asm.function


////////////////////////////////////////////////////////////////////////////////
//qspi_port_spi_mode_three_write_bytes_asm
//
//Writes bytes from memory up to and including speeds of 50MHz
//
//in      - internal_handle : spi_handle_t
//out     - tx_bytes : char*
//in      - num_bytes : unsigned
//return  - void
////////////////////////////////////////////////////////////////////////////////

.cc_top qspi_port_spi_mode_three_write_bytes_asm.function
.globl  qspi_port_spi_mode_three_write_bytes_asm
.align  4
.type qspi_port_spi_mode_three_write_bytes_asm,@function

qspi_port_spi_mode_three_write_bytes_asm:

.issue_mode dual
  DUALENTSP_lu6 STACKWORDS

  //Callee save registers: TODO: why SP[1]..SP[3]
  std r4, r5, sp[1]
  std r6, r7, sp[2]
  std r8, r9, sp[3]

  //TODO:

  bl qspi_port_write_bytes_asm

  //Callee restore registers
  ldd r4, r5, sp[1]
  ldd r6, r7, sp[2]
  ldd r8, r9, sp[3]

retsp STACKWORDS

.qspi_port_spi_mode_three_write_bytes_asm_tmp:
  .size qspi_port_spi_mode_three_write_bytes_asm, .qspi_port_spi_mode_three_write_bytes_asm_tmp - qspi_port_spi_mode_three_write_bytes_asm
  .align  4
  .cc_bottom qspi_port_spi_mode_three_write_bytes_asm.function


////////////////////////////////////////////////////////////////////////////////
//qspi_port_write_bytes_asm
////////////////////////////////////////////////////////////////////////////////

.cc_top qspi_port_write_bytes_asm.function
.globl  qspi_port_write_bytes_asm
.align  4
.type qspi_port_write_bytes_asm,@function

qspi_port_write_bytes_asm:

.issue_mode dual
  DUALENTSP_lu6 STACKWORDS

  //Format the first byte so that it is all lined up on the SI pin
  add INDEX, INDEX, 1
  {ld8u WORD_OUT_ONE, TX_DATA[INDEX]; ldc ZIP_OUT, 0x00}
  add WORD_OUT_TWO, WORD_OUT_ONE, 0     //Duplicate
  zip WORD_OUT_ONE, WORD_OUT_TWO, 0     //Double up all the bits
  unzip WORD_OUT_ONE, WORD_OUT_TWO, 3   //Unzip into two words
  zip ZIP_OUT, WORD_OUT_ONE, 0          //Align out to SI...
  zip ZIP_OUT, WORD_OUT_TWO, 0          //...
  zip ZIP_OUT, WORD_OUT_ONE, 0          //...
  zip ZIP_OUT, WORD_OUT_TWO, 0          //...Align out to SI

  //Line the QSPI_PORTS up to output the clock edges and start outputting
  //at the required times
  setc res[SIO], 0x1   //TODO: find docs on what 0x1 means for port resource type
  in PORT_TIME, res[SIO]
  getts PORT_TIME, res[SIO]
  ldc PORT_DELAY, 0x96 //TODO: configurable port setup delay
  add PORT_DELAY, PORT_TIME, PORT_DELAY
  setpt res[SCLK], PORT_DELAY
  setpt res[SIO], PORT_DELAY
  outpw res[SCLK], CLK_EDGES, EIGHT_CLOCK_EDGES

  //If there is only one byte of data to send:
  //skip on down to read the final(only) byte...
  bf NUM_DATA, qspi_port_spi_mode_zero_write_bytes_asm_final_byte

qspi_port_spi_mode_zero_write_bytes_asm_loop:

  {out res[SIO], WORD_OUT_ONE; add INDEX, INDEX, 1}
  {out res[SIO], WORD_OUT_TWO; sub NUM_DATA, NUM_DATA, 1}

  //Format the next word...
  {ld8u WORD_OUT_ONE, TX_DATA[INDEX]; ldc ZIP_OUT, 0x00}
  add WORD_OUT_TWO, WORD_OUT_ONE, 0     //Duplicate
  zip WORD_OUT_ONE, WORD_OUT_TWO, 0     //Double up all the bits
  unzip WORD_OUT_ONE, WORD_OUT_TWO, 3   //Unzip into two words
  zip ZIP_OUT, WORD_OUT_ONE, 0          //Align out to SI...
  zip ZIP_OUT, WORD_OUT_TWO, 0          //...
  zip ZIP_OUT, WORD_OUT_ONE, 0          //...
  zip ZIP_OUT, WORD_OUT_TWO, 0          //...Align out to SI

  //Output clock edges to carry data that will be input on the next iteration
  outpw res[SCLK], CLK_EDGES, EIGHT_CLOCK_EDGES

  //Go back around the loop if more data to read...
  bt NUM_DATA, qspi_port_spi_mode_zero_write_bytes_asm_loop

qspi_port_spi_mode_zero_write_bytes_asm_final_byte:

  //Output the final byte
  out res[SIO], WORD_OUT_ONE
  out res[SIO], WORD_OUT_TWO

  //Wait for SCLK to complete
  outpw res[SCLK], CLK_START_END, 1
  syncr res[SCLK]

  retsp STACKWORDS

.qspi_port_write_bytes_asm_tmp:
  .size qspi_port_write_bytes_asm, .qspi_port_write_bytes_asm_tmp - qspi_port_write_bytes_asm
  .align  4
  .cc_bottom qspi_port_write_bytes_asm.function

#endif //defined(__XS2A__)
