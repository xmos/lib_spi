// Copyright (c) 2016-2018, XMOS Ltd, All rights reserved

//Write bytes for QSPI SPI mode.  That is all data is output from the SIO port one
//word at a time.  As all the bits are doubled up so it takes two words to make
//up the required byte.  The data must be transmitted from pin IO0 (SI) of the
//4 pin port.

#include "spi_defines.h"
#include "spi_registers.h"

#if defined(__XS2A__)

////////////////////////////////////////////////////////////////////////////////
//qspi_port_spi_mode_zero_write_bytes_asm
//
//Writes bytes from memory up to and including speeds of 50MHz
//
//in      - internal_handle : spi_handle_t
//in      - port_timings : port_timings_t
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
  DUALENTSP_lu6 STACKWORDS_TEN

#include "callee_save_registers_qspi_ports.S"
#include "spi_mode_zero_qspi_ports_init.S"

  bl qspi_port_write_bytes_asm

#include "callee_restore_registers_qspi_ports.S"

  retsp STACKWORDS_TEN

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
//in      - port_timings : port_timings_t
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
  DUALENTSP_lu6 STACKWORDS_TEN

#include "callee_save_registers_qspi_ports.S"
#include "spi_mode_one_qspi_ports_init.S"

  bl qspi_port_write_bytes_asm

#include "callee_restore_registers_qspi_ports.S"

retsp STACKWORDS_TEN

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
//in      - port_timings : port_timings_t
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
  DUALENTSP_lu6 STACKWORDS_TEN

#include "callee_save_registers_qspi_ports.S"
#include "spi_mode_two_qspi_ports_init.S"

  bl qspi_port_write_bytes_asm

#include "callee_restore_registers_qspi_ports.S"

retsp STACKWORDS_TEN

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
//in      - port_timings : port_timings_t
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
  DUALENTSP_lu6 STACKWORDS_TEN

#include "callee_save_registers_qspi_ports.S"
#include "spi_mode_three_qspi_ports_init.S"

  bl qspi_port_write_bytes_asm

#include "callee_restore_registers_qspi_ports.S"

retsp STACKWORDS_TEN

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

//This table is a lookup that gives the value of a nibble as though it had been
//formatted to line up with the SI pin of the 4bit SIO port.  Two nibbles are
//required to make up a byte that will be transmitted via the port.
lut_align_byte_to_si_pin:

  .word 0x00000000 //0x0 (Reversed)
  .word 0x11000000 //0x1 (Reversed)
  .word 0x00110000 //0x2 (Reversed)
  .word 0x11110000 //0x3 (Reversed)
  .word 0x00001100 //0x4 (Reversed)
  .word 0x11001100 //0x5 (Reversed)
  .word 0x00111100 //0x6 (Reversed)
  .word 0x11111100 //0x7 (Reversed)
  .word 0x00000011 //0x8 (Reversed)
  .word 0x11000011 //0x9 (Reversed)
  .word 0x00110011 //0xA (Reversed)
  .word 0x11110011 //0xB (Reversed)
  .word 0x00001111 //0xC (Reversed)
  .word 0x11001111 //0xD (Reversed)
  .word 0x00111111 //0xE (Reversed)
  .word 0x11111111 //0xF (Reversed)

qspi_port_write_bytes_asm:
.issue_mode dual
  DUALENTSP_lu6 STACKWORDS_NONE

  //Format the first byte so that it is all lined up on the SI pin
  {add INDEX, INDEX, 1; ldap LUT_SI_PIN, lut_align_byte_to_si_pin}

#include "format_write_bytes_as_spi_qspi_ports.S"
#include "port_setup_output_qspi_ports.S"

  //If there is only one byte of data to send:
  //skip on down to read the final(only) byte...
  bf NUM_DATA, qspi_port_spi_mode_zero_write_bytes_asm_final_byte

//To successfully write at our intended top speed of 50MHz we need to get round
//this loop within 160ns (i.e if cycle time at 50MHz = 20ns and 1 byte is output
//as 8 bits then 20 * 8 = 160ns).  The XTA currently times this loop as follows:
//xta 1>load bin/lib_qspi_example.xe
//xta 2>config tasks tile[0] 8
//xta 3>add exclusion qspi_port_spi_mode_zero_write_bytes_asm_final_byte
//xta 4>analyze endpoints qspi_port_spi_mode_zero_write_bytes_asm_loop qspi_port_spi_mode_zero_write_bytes_asm_loop
//xta 5>print trace -
//*        0.0: ( 16.0ns) 0x404dc qspi_port_write_bytes_asm + 56 { out (r2r)    res[r4], r7  ; add (2rus)   r10, r10, 0x1 } (P)
//*       16.0: ( 16.0ns) 0x404e0 qspi_port_write_bytes_asm + 60 { out (r2r)    res[r4], r8  ; ld8u (3r)    r7, r1[r10]  } (P)
//        32.0: ( 16.0ns) 0x404e4 qspi_port_write_bytes_asm + 64 { add (2rus)   r8, r7, 0x0  ; shr (2rus)   r7, r7, 0x4  }
//        48.0: ( 16.0ns) 0x404e8 qspi_port_write_bytes_asm + 68 { zext (rus)   r8, 0x4      ; ldw (3r)     r7, r11[r7]  }
//        64.0: ( 16.0ns) 0x404ec qspi_port_write_bytes_asm + 72 { sub (2rus)   r2, r2, 0x1  ; ldw (3r)     r8, r11[r8]  }
//*       80.0: ( 16.0ns) 0x404f0 qspi_port_write_bytes_asm + 76 outpw (l2rus) res[r3], r5, 0x10 (P)
//        96.0: ( 16.0ns) 0x404f4 qspi_port_write_bytes_asm + 80 bt (lru6)    r2, -0x7
//xta 6>quit
qspi_port_spi_mode_zero_write_bytes_asm_loop:

  {out res[SIO], WORD_OUT_ONE; add INDEX, INDEX, 1}
  {out res[SIO], WORD_OUT_TWO; sub NUM_DATA, NUM_DATA, 1}

#include "format_write_bytes_as_spi_qspi_ports.S"

  //Output clock edges to carry data that will be input on the next iteration
  //Go back around the loop if more data to read...
  outpw res[SCLK], CLK_EDGES, EIGHT_CLOCK_EDGES_DOUBLED

  bt NUM_DATA, qspi_port_spi_mode_zero_write_bytes_asm_loop

qspi_port_spi_mode_zero_write_bytes_asm_final_byte:

  //Output the final byte
  out res[SIO], WORD_OUT_ONE
  {out res[SIO], WORD_OUT_TWO; ldw CLK_START_END, sp[CLK_START_END_STACK_LOCATION]}

  //Wait for SCLK to complete
  outpw res[SCLK], CLK_START_END, 1
  syncr res[SCLK]

  retsp STACKWORDS_NONE

.qspi_port_write_bytes_asm_tmp:
  .size qspi_port_write_bytes_asm, .qspi_port_write_bytes_asm_tmp - qspi_port_write_bytes_asm
  .align  4
  .cc_bottom qspi_port_write_bytes_asm.function

#endif //defined(__XS2A__)
