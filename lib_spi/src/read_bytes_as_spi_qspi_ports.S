// Copyright (c) 2016-2018, XMOS Ltd, All rights reserved

//Read bytes for QSPI SPI mode.  That is all data is input from the SIO port one
//word at a time.  As all the bits are doubled up so it takes two words to make
//up the required byte.  The data we're actually interested in comes from
//pin IO1 (SO) of the 4 pin port.

#include "spi_defines.h"
#include "spi_registers.h"

#if defined(__XS2A__)

.weak       _fptrgroup.SPI_RX_BYTES_IMPL.group
.weak       _fptrgroup.SPI_RX_BYTES_IMPL.nstackwords.group
.weak       _fptrgroup.SPI_RX_BYTES_IMPL.maxcores.group
.weak       _fptrgroup.SPI_RX_BYTES_IMPL.maxtimers.group
.weak       _fptrgroup.SPI_RX_BYTES_IMPL.maxchanends.group
.add_to_set _fptrgroup.SPI_RX_BYTES_IMPL.group, qspi_port_spi_mode_zero_read_bytes_asm, qspi_port_spi_mode_zero_read_bytes_asm
.add_to_set _fptrgroup.SPI_RX_BYTES_IMPL.nstackwords.group, qspi_port_spi_mode_zero_read_bytes_asm.nstackwords, qspi_port_spi_mode_zero_read_bytes_asm
.add_to_set _fptrgroup.SPI_RX_BYTES_IMPL.maxcores.group, qspi_port_spi_mode_zero_read_bytes_asm.maxcores, qspi_port_spi_mode_zero_read_bytes_asm
.add_to_set _fptrgroup.SPI_RX_BYTES_IMPL.maxtimers.group, qspi_port_spi_mode_zero_read_bytes_asm.maxtimers, qspi_port_spi_mode_zero_read_bytes_asm
.add_to_set _fptrgroup.SPI_RX_BYTES_IMPL.maxchanends.group, qspi_port_spi_mode_zero_read_bytes_asm.maxchanends, qspi_port_spi_mode_zero_read_bytes_asm
.add_to_set _fptrgroup.SPI_RX_BYTES_IMPL.group, qspi_port_spi_mode_one_read_bytes_asm, qspi_port_spi_mode_one_read_bytes_asm
.add_to_set _fptrgroup.SPI_RX_BYTES_IMPL.nstackwords.group, qspi_port_spi_mode_one_read_bytes_asm.nstackwords, qspi_port_spi_mode_one_read_bytes_asm
.add_to_set _fptrgroup.SPI_RX_BYTES_IMPL.maxcores.group, qspi_port_spi_mode_one_read_bytes_asm.maxcores, qspi_port_spi_mode_one_read_bytes_asm
.add_to_set _fptrgroup.SPI_RX_BYTES_IMPL.maxtimers.group, qspi_port_spi_mode_one_read_bytes_asm.maxtimers, qspi_port_spi_mode_one_read_bytes_asm
.add_to_set _fptrgroup.SPI_RX_BYTES_IMPL.maxchanends.group, qspi_port_spi_mode_one_read_bytes_asm.maxchanends, qspi_port_spi_mode_one_read_bytes_asm
.add_to_set _fptrgroup.SPI_RX_BYTES_IMPL.group, qspi_port_spi_mode_two_read_bytes_asm, qspi_port_spi_mode_two_read_bytes_asm
.add_to_set _fptrgroup.SPI_RX_BYTES_IMPL.nstackwords.group, qspi_port_spi_mode_two_read_bytes_asm.nstackwords, qspi_port_spi_mode_two_read_bytes_asm
.add_to_set _fptrgroup.SPI_RX_BYTES_IMPL.maxcores.group, qspi_port_spi_mode_two_read_bytes_asm.maxcores, qspi_port_spi_mode_two_read_bytes_asm
.add_to_set _fptrgroup.SPI_RX_BYTES_IMPL.maxtimers.group, qspi_port_spi_mode_two_read_bytes_asm.maxtimers, qspi_port_spi_mode_two_read_bytes_asm
.add_to_set _fptrgroup.SPI_RX_BYTES_IMPL.maxchanends.group, qspi_port_spi_mode_two_read_bytes_asm.maxchanends, qspi_port_spi_mode_two_read_bytes_asm
.add_to_set _fptrgroup.SPI_RX_BYTES_IMPL.group, qspi_port_spi_mode_three_read_bytes_asm, qspi_port_spi_mode_three_read_bytes_asm
.add_to_set _fptrgroup.SPI_RX_BYTES_IMPL.nstackwords.group, qspi_port_spi_mode_three_read_bytes_asm.nstackwords, qspi_port_spi_mode_three_read_bytes_asm
.add_to_set _fptrgroup.SPI_RX_BYTES_IMPL.maxcores.group, qspi_port_spi_mode_three_read_bytes_asm.maxcores, qspi_port_spi_mode_three_read_bytes_asm
.add_to_set _fptrgroup.SPI_RX_BYTES_IMPL.maxtimers.group, qspi_port_spi_mode_three_read_bytes_asm.maxtimers, qspi_port_spi_mode_three_read_bytes_asm
.add_to_set _fptrgroup.SPI_RX_BYTES_IMPL.maxchanends.group, qspi_port_spi_mode_three_read_bytes_asm.maxchanends, qspi_port_spi_mode_three_read_bytes_asm

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

#include "callee_save_registers_qspi_ports.S"
#include "spi_mode_zero_qspi_ports_init.S"

  bl qspi_port_read_bytes_asm

#include "callee_restore_registers_qspi_ports.S"

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

#include "callee_save_registers_qspi_ports.S"
#include "spi_mode_one_qspi_ports_init.S"

  bl qspi_port_read_bytes_asm

#include "callee_restore_registers_qspi_ports.S"

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

#include "callee_save_registers_qspi_ports.S"
#include "spi_mode_two_qspi_ports_init.S"

  bl qspi_port_read_bytes_asm

#include "callee_restore_registers_qspi_ports.S"

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

#include "callee_save_registers_qspi_ports.S"
#include "spi_mode_three_qspi_ports_init.S"

  bl qspi_port_read_bytes_asm

#include "callee_restore_registers_qspi_ports.S"

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

#include "port_setup_input_qspi_ports.S"

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
  outpw res[SCLK], CLK_EDGES, EIGHT_CLOCK_EDGES_DOUBLED

  //Input and process the data that arrived on the current iteration
  {in WORD_IN_ONE, res[SIO]; add INDEX, INDEX, 1}
  {in WORD_IN_TWO, res[SIO]; sub NUM_DATA, NUM_DATA, 1}

#include "format_read_bytes_as_spi_qspi_ports.S"

  //Store the result in the destination
  st8 BYTE_IN, RX_DATA[INDEX]

  //Go back around the loop if more data to read...
  bt NUM_DATA, qspi_port_spi_mode_zero_read_bytes_asm_loop

qspi_port_spi_mode_zero_read_bytes_asm_final_byte:

  //Set clock back to low in CPOL 0
  {in WORD_IN_ONE, res[SIO]; add INDEX, INDEX, 1}
  {in WORD_IN_TWO, res[SIO]; ldw CLK_START_END, sp[CLK_START_END_STACK_LOCATION]}
  outpw res[SCLK], CLK_START_END, 1

#include "format_read_bytes_as_spi_qspi_ports.S"

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
