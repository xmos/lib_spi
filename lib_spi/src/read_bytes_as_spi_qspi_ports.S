// Copyright (c) 2016-2018, XMOS Ltd, All rights reserved

//Read bytes for QSPI SPI mode.  That is all data is input from the SIO port one
//word at a time.  As all the bits are doubled up so it takes two words to make
//up the required byte.  The data we're actually interested in comes from
//pin IO1 (SO) of the 4 pin port.

#include <xs1.h>

#if defined(__XS2A__)

#define STACKWORDS_TEN      10
#define STACKWORDS_NONE     0

#define EIGHT_CLOCK_EDGES   16 //doubled up

#define CLK_START_END_STACK_LOCATION 9

#define PORT_SETUP_DELAYS_OFFSET 0
#define PORT_INPUT_DELAYS_OFFSET 1

//Registers
#define QSPI_PORTS          r0
#define PORT_TIMINGS        r1
#define RX_DATA             r2
#define NUM_DATA            r3
#define SCLK                r4
#define SIO                 r5
#define CLK_EDGES           r6
#define CLK_START_END       r7 //Saved onto the stack!
#define PORT_MODE           r7
#define PORT_TIME           r7
#define WORD_IN_ONE         r8
#define WORD_IN_TWO         r9
#define INDEX               r10
#define BYTE_IN             r11
#define PORT_SETUP_TIME     r11
#define PORT_INPUT_TIME     r11

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
//qspi_port_spi_mode_zero_read_bytes_asm
//
//Reads bytes from memory up to and including speeds of 50MHz
//
//in      - internal_handle : spi_handle_t
//in      - port_timings : port_timings_t
//in/out  - rx_bytes : char*
//in      - num_bytes : unsigned
//return  - void
////////////////////////////////////////////////////////////////////////////////

.cc_top qspi_port_spi_mode_zero_read_bytes_asm.function
.globl  qspi_port_spi_mode_zero_read_bytes_asm
.align  4
.type qspi_port_spi_mode_zero_read_bytes_asm,@function

qspi_port_spi_mode_zero_read_bytes_asm:
.issue_mode dual
  DUALENTSP_lu6 STACKWORDS_TEN

  //Callee save registers
  //Dont touch sp[0] as thats used for the lr
  std r4, r5, sp[1] //sp[2]..sp[3]
  std r6, r7, sp[2] //sp[4]..sp[5]
  std r8, r9, sp[3] //sp[6]..sp[7]
  stw r10, sp[8]    //sp[8]

  //Deducting one from NUM_DATA from the get-go to enable 1 byte reads below...
  {ldw SCLK, QSPI_PORTS[1]; sub NUM_DATA, NUM_DATA, 1}
  {ldw SIO, QSPI_PORTS[2]; mkmsk INDEX, 32}
  //Mode 0 requires cpol 0 clock edges
  //cpol 0 starts/finish low
  {ldw CLK_EDGES, dp[clock_edges_cpol_zero]; ldc CLK_START_END, 0}
  outpw res[SCLK], CLK_START_END, 1

  //Store the CLK_START_END to the stack as we'll clobber this register in the
  //loop below.  We can restore it from the stack at the end of the loop.
  stw CLK_START_END, sp[CLK_START_END_STACK_LOCATION]

  bl qspi_port_read_bytes_asm

  //Callee restore registers
  ldd r4, r5, sp[1] //sp[2]..sp[3]
  ldd r6, r7, sp[2] //sp[4]..sp[5]
  ldd r8, r9, sp[3] //sp[6]..sp[7]
  ldw r10, sp[8]    //sp[8]

  retsp STACKWORDS_TEN

.qspi_port_spi_mode_zero_read_bytes_asm_tmp:
  .size qspi_port_spi_mode_zero_read_bytes_asm, .qspi_port_spi_mode_zero_read_bytes_asm_tmp - qspi_port_spi_mode_zero_read_bytes_asm
  .align  4
  .cc_bottom qspi_port_spi_mode_zero_read_bytes_asm.function


////////////////////////////////////////////////////////////////////////////////
//qspi_port_spi_mode_one_read_bytes_asm
//
//Reads bytes from memory up to and including speeds of 50MHz
//
//in      - internal_handle : spi_handle_t
//in      - port_timings : port_timings_t
//in/out  - rx_bytes : char*
//in      - num_bytes : unsigned
//return  - void
////////////////////////////////////////////////////////////////////////////////

.cc_top qspi_port_spi_mode_one_read_bytes_asm.function
.globl  qspi_port_spi_mode_one_read_bytes_asm
.align  4
.type qspi_port_spi_mode_one_read_bytes_asm,@function

qspi_port_spi_mode_one_read_bytes_asm:

.issue_mode dual
  DUALENTSP_lu6 STACKWORDS_TEN

  //Callee save registers
  //Dont touch sp[0] as thats used for the lr
  std r4, r5, sp[1] //sp[2]..sp[3]
  std r6, r7, sp[2] //sp[4]..sp[5]
  std r8, r9, sp[3] //sp[6]..sp[7]
  stw r10, sp[8]    //sp[8]

  //Deducting one from NUM_DATA from the get-go to enable 1 byte reads below...
  {ldw SCLK, QSPI_PORTS[1]; sub NUM_DATA, NUM_DATA, 1}
  {ldw SIO, QSPI_PORTS[2]; mkmsk INDEX, 32}
  //Mode 1 requires cpol 0 clock edges
  //cpol 0 starts/finish low
  {ldw CLK_EDGES, dp[clock_edges_cpol_zero]; ldc CLK_START_END, 0}
  outpw res[SCLK], CLK_START_END, 1

  //Store the CLK_START_END to the stack as we'll clobber this register in the
  //loop below.  We can restore it from the stack at the end of the loop.
  stw CLK_START_END, sp[CLK_START_END_STACK_LOCATION]

  //TODO: Offset cpha

  bl qspi_port_read_bytes_asm

  //Callee restore registers
  ldd r4, r5, sp[1] //sp[2]..sp[3]
  ldd r6, r7, sp[2] //sp[4]..sp[5]
  ldd r8, r9, sp[3] //sp[6]..sp[7]
  ldw r10, sp[8]    //sp[8]

retsp STACKWORDS_TEN

.qspi_port_spi_mode_one_read_bytes_asm_tmp:
  .size qspi_port_spi_mode_one_read_bytes_asm, .qspi_port_spi_mode_one_read_bytes_asm_tmp - qspi_port_spi_mode_one_read_bytes_asm
  .align  4
  .cc_bottom qspi_port_spi_mode_one_read_bytes_asm.function


////////////////////////////////////////////////////////////////////////////////
//qspi_port_spi_mode_two_read_bytes_asm
//
//Reads bytes from memory up to and including speeds of 50MHz
//
//in      - internal_handle : spi_handle_t
//in      - port_timings : port_timings_t
//in/out  - rx_bytes : char*
//in      - num_bytes : unsigned
//return  - void
////////////////////////////////////////////////////////////////////////////////

.cc_top qspi_port_spi_mode_two_read_bytes_asm.function
.globl  qspi_port_spi_mode_two_read_bytes_asm
.align  4
.type qspi_port_spi_mode_two_read_bytes_asm,@function

qspi_port_spi_mode_two_read_bytes_asm:

.issue_mode dual
  DUALENTSP_lu6 STACKWORDS_TEN

  //Callee save registers
  //Dont touch sp[0] as thats used for the lr
  std r4, r5, sp[1] //sp[2]..sp[3]
  std r6, r7, sp[2] //sp[4]..sp[5]
  std r8, r9, sp[3] //sp[6]..sp[7]
  stw r10, sp[8]    //sp[8]

  //Deducting one from NUM_DATA from the get-go to enable 1 byte reads below...
  {ldw SCLK, QSPI_PORTS[1]; sub NUM_DATA, NUM_DATA, 1}
  {ldw SIO, QSPI_PORTS[2]; mkmsk INDEX, 32}
  //Mode 2 requires cpol 1 clock edges
  //cpol 1 starts/finish high
  {ldw CLK_EDGES, dp[clock_edges_cpol_one]; ldc CLK_START_END, 1}
  outpw res[SCLK], CLK_START_END, 1

  //Store the CLK_START_END to the stack as we'll clobber this register in the
  //loop below.  We can restore it from the stack at the end of the loop.
  stw CLK_START_END, sp[CLK_START_END_STACK_LOCATION]

  bl qspi_port_read_bytes_asm

  //Callee restore registers
  ldd r4, r5, sp[1] //sp[2]..sp[3]
  ldd r6, r7, sp[2] //sp[4]..sp[5]
  ldd r8, r9, sp[3] //sp[6]..sp[7]
  ldw r10, sp[8]    //sp[8]

retsp STACKWORDS_TEN

.qspi_port_spi_mode_two_read_bytes_asm_tmp:
  .size qspi_port_spi_mode_two_read_bytes_asm, .qspi_port_spi_mode_two_read_bytes_asm_tmp - qspi_port_spi_mode_two_read_bytes_asm
  .align  4
  .cc_bottom qspi_port_spi_mode_two_read_bytes_asm.function


////////////////////////////////////////////////////////////////////////////////
//qspi_port_spi_mode_three_read_bytes_asm
//
//Reads bytes from memory up to and including speeds of 50MHz
//
//in      - internal_handle : spi_handle_t
//in      - port_timings : port_timings_t
//in/out  - rx_bytes : char*
//in      - num_bytes : unsigned
//return  - void
////////////////////////////////////////////////////////////////////////////////

.cc_top qspi_port_spi_mode_three_read_bytes_asm.function
.globl  qspi_port_spi_mode_three_read_bytes_asm
.align  4
.type qspi_port_spi_mode_three_read_bytes_asm,@function

qspi_port_spi_mode_three_read_bytes_asm:

.issue_mode dual
  DUALENTSP_lu6 STACKWORDS_TEN

  //Callee save registers
  //Dont touch sp[0] as thats used for the lr
  std r4, r5, sp[1] //sp[2]..sp[3]
  std r6, r7, sp[2] //sp[4]..sp[5]
  std r8, r9, sp[3] //sp[6]..sp[7]
  stw r10, sp[8]    //sp[8]

  //Deducting one from NUM_DATA from the get-go to enable 1 byte reads below...
  {ldw SCLK, QSPI_PORTS[1]; sub NUM_DATA, NUM_DATA, 1}
  {ldw SIO, QSPI_PORTS[2]; mkmsk INDEX, 32}
  //Mode 3 requires cpol 1 clock edges
  //cpol 1 starts/finish high
  {ldw CLK_EDGES, dp[clock_edges_cpol_one]; ldc CLK_START_END, 1}
  outpw res[SCLK], CLK_START_END, 1

  //Store the CLK_START_END to the stack as we'll clobber this register in the
  //loop below.  We can restore it from the stack at the end of the loop.
  stw CLK_START_END, sp[CLK_START_END_STACK_LOCATION]

  //TODO: Offset cpha

  bl qspi_port_read_bytes_asm

  //Callee restore registers
  ldd r4, r5, sp[1] //sp[2]..sp[3]
  ldd r6, r7, sp[2] //sp[4]..sp[5]
  ldd r8, r9, sp[3] //sp[6]..sp[7]
  ldw r10, sp[8]    //sp[8]

retsp STACKWORDS_TEN

.qspi_port_spi_mode_three_read_bytes_asm_tmp:
  .size qspi_port_spi_mode_three_read_bytes_asm, .qspi_port_spi_mode_three_read_bytes_asm_tmp - qspi_port_spi_mode_three_read_bytes_asm
  .align  4
  .cc_bottom qspi_port_spi_mode_three_read_bytes_asm.function


////////////////////////////////////////////////////////////////////////////////
//qspi_port_read_bytes_asm
////////////////////////////////////////////////////////////////////////////////

.cc_top qspi_port_read_bytes_asm.function
.globl  qspi_port_read_bytes_asm
.align  4
.type qspi_port_read_bytes_asm,@function

qspi_port_read_bytes_asm:

.issue_mode dual
  DUALENTSP_lu6 STACKWORDS_NONE

  //Line the QSPI_PORTS up to output the clock edges and start inputting
  //at the required times
  ldc PORT_MODE, XS1_SETC_COND_FULL
  setc res[SIO], PORT_MODE
  in PORT_TIME, res[SIO]
  getts PORT_TIME, res[SIO]
  ldw PORT_SETUP_TIME, PORT_TIMINGS[PORT_SETUP_DELAYS_OFFSET]
  add PORT_TIME, PORT_TIME, PORT_SETUP_TIME
  setpt res[SCLK], PORT_TIME
  outpw res[SCLK], CLK_EDGES, EIGHT_CLOCK_EDGES
  ldw PORT_INPUT_TIME, PORT_TIMINGS[PORT_INPUT_DELAYS_OFFSET]
  add PORT_TIME, PORT_TIME, PORT_INPUT_TIME
  setpt res[SIO], PORT_TIME

  //There is only one byte of data to read:
  //skip on down to read the final(only) byte...
  bf NUM_DATA, qspi_port_spi_mode_zero_read_bytes_asm_final_byte

//To successfully write at our intended top speed of 50MHz we need to get round
//this loop within 160ns (i.e if cycle time at 50MHz = 20ns and 1 byte is output
//as 8 bits then 20 * 8 = 160ns).  The XTA currently times this loop as follows:
//  xta 1>load bin/lib_qspi_example.xe
//  xta 2>config tasks tile[0] 8
//  xta 3>add exclusion qspi_port_spi_mode_zero_read_bytes_asm_final_byte
//  xta 4>analyze endpoints qspi_port_spi_mode_zero_read_bytes_asm_loop qspi_port_spi_mode_zero_read_bytes_asm_loop
//  xta 5>print trace -
//  *        0.0: ( 16.0ns) 0x4030c qspi_port_read_bytes_asm + 48 outpw (l2rus) res[r3], r5, 0x10 (P)
//  *       16.0: ( 16.0ns) 0x40310 qspi_port_read_bytes_asm + 52 { in (2r)      r6, res[r4]  ; add (2rus)   r9, r9, 0x1  } (P)
//  *       32.0: ( 16.0ns) 0x40314 qspi_port_read_bytes_asm + 56 { in (2r)      r7, res[r4]  ; sub (2rus)   r2, r2, 0x1  } (P)
//          48.0: ( 16.0ns) 0x40318 qspi_port_read_bytes_asm + 60 unzip (l2rus) r7, r6, 0x2
//          64.0: ( 16.0ns) 0x4031c qspi_port_read_bytes_asm + 64 unzip (l2rus) r7, r6, 0x1
//          80.0: ( 16.0ns) 0x40320 qspi_port_read_bytes_asm + 68 unzip (l2rus) r7, r6, 0x0
//          96.0: ( 16.0ns) 0x40324 qspi_port_read_bytes_asm + 72 { bitrev (2r)  r8, r7       ; nop (0r)                  }
//         112.0: ( 16.0ns) 0x40328 qspi_port_read_bytes_asm + 76 { shr (2rus)   r8, r8, 0x18 ; nop (0r)                  }
//         128.0: ( 16.0ns) 0x4032c qspi_port_read_bytes_asm + 80 st8 (l3r)    r8, r1[r9]
//         144.0: ( 16.0ns) 0x40330 qspi_port_read_bytes_asm + 84 bt (lru6)    r2, -0xa
//  xta 6>quit
qspi_port_spi_mode_zero_read_bytes_asm_loop:

  //Output clock edges to carry data that will be input on the next iteration
  outpw res[SCLK], CLK_EDGES, EIGHT_CLOCK_EDGES

  //Input and process the data that arrived on the current iteration
  {in WORD_IN_ONE, res[SIO]; add INDEX, INDEX, 1}
  {in WORD_IN_TWO, res[SIO]; sub NUM_DATA, NUM_DATA, 1}

  //Unzip the two words that were input.  We are basically obtaining all the
  //bits that were input on SIO pin 1 from the two input words.  Unzipping
  //WORD_IN_TWO:WORD_IN_ONE saves us a nibble swap later
  unzip WORD_IN_TWO, WORD_IN_ONE, 2  //zip out the correct nibbles
  unzip WORD_IN_TWO, WORD_IN_ONE, 1  //zip out the correct bit pairs
  unzip WORD_IN_TWO, WORD_IN_ONE, 0  //zip out the correct bits

  //Now bitrev the final word and shuffle it down 3 bytes!
  bitrev BYTE_IN, WORD_IN_TWO
  shr BYTE_IN, BYTE_IN, 24

  //Store the result in the destination
  st8 BYTE_IN, RX_DATA[INDEX]

  //Go back around the loop if more data to read...
  bt NUM_DATA, qspi_port_spi_mode_zero_read_bytes_asm_loop

qspi_port_spi_mode_zero_read_bytes_asm_final_byte:

  //Set clock back to low in CPOL 0
  {in WORD_IN_ONE, res[SIO]; add INDEX, INDEX, 1}
  {in WORD_IN_TWO, res[SIO]; ldw CLK_START_END, sp[CLK_START_END_STACK_LOCATION]}
  outpw res[SCLK], CLK_START_END, 1

  //Unzip the two words that were input.  We are basically obtaining all the
  //bits that were input on SIO pin 1 from the two input words.  Unzipping
  //WORD_IN_TWO:WORD_IN_ONE saves us a nibble swap later
  unzip WORD_IN_TWO, WORD_IN_ONE, 2  //zip out the correct nibbles
  unzip WORD_IN_TWO, WORD_IN_ONE, 1  //zip out the correct bit pairs
  unzip WORD_IN_TWO, WORD_IN_ONE, 0  //zip out the correct bits

  //Now bitrev the word and shuffle it down 3 bytes storing the result in r0!
  bitrev BYTE_IN, WORD_IN_TWO
  shr BYTE_IN, BYTE_IN, 24

  //Store the result in the destination
  st8 BYTE_IN, RX_DATA[INDEX]

  //Wait for SCLK to complete
  syncr res[SCLK]

  retsp STACKWORDS_NONE

.qspi_port_read_bytes_asm_tmp:
  .size qspi_port_read_bytes_asm, .qspi_port_read_bytes_asm_tmp - qspi_port_read_bytes_asm
  .align  4
  .cc_bottom qspi_port_read_bytes_asm.function

#endif //defined(__XS2A__)
