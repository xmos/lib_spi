// Copyright (c) 2016-2018, XMOS Ltd, All rights reserved

#define STACKWORDS 8

////////////////////////////////////////////////////////////////////////////////
//spi_port_spi_mode_zero_read_bytes_asm
//
//Reads bytes from memory up to and including speeds of 50MHz
//
//in      - internal_handle : spi_handle_t
//in/out  - rx_bytes : char*
//in      - num_bytes : unsigned
//return  - void
////////////////////////////////////////////////////////////////////////////////

.cc_top spi_port_spi_mode_zero_read_bytes_asm.function
.globl  spi_port_spi_mode_zero_read_bytes_asm
.align  4
.type spi_port_spi_mode_zero_read_bytes_asm,@function

spi_port_spi_mode_zero_read_bytes_asm:

.issue_mode dual
  DUALENTSP_lu6 STACKWORDS

retsp STACKWORDS

.spi_port_spi_mode_zero_read_bytes_asm_tmp:
  .size spi_port_spi_mode_zero_read_bytes_asm, .spi_port_spi_mode_zero_read_bytes_asm_tmp - spi_port_spi_mode_zero_read_bytes_asm
  .align  4
  .cc_bottom spi_port_spi_mode_zero_read_bytes_asm.function


////////////////////////////////////////////////////////////////////////////////
//spi_port_spi_mode_one_read_bytes_asm
//
//Reads bytes from memory up to and including speeds of 50MHz
//
//in      - internal_handle : spi_handle_t
//in/out  - rx_bytes : char*
//in      - num_bytes : unsigned
//return  - void
////////////////////////////////////////////////////////////////////////////////

.cc_top spi_port_spi_mode_one_read_bytes_asm.function
.globl  spi_port_spi_mode_one_read_bytes_asm
.align  4
.type spi_port_spi_mode_one_read_bytes_asm,@function

spi_port_spi_mode_one_read_bytes_asm:

.issue_mode dual
  DUALENTSP_lu6 STACKWORDS

retsp STACKWORDS

.spi_port_spi_mode_one_read_bytes_asm_tmp:
  .size spi_port_spi_mode_one_read_bytes_asm, .spi_port_spi_mode_one_read_bytes_asm_tmp - spi_port_spi_mode_one_read_bytes_asm
  .align  4
  .cc_bottom spi_port_spi_mode_one_read_bytes_asm.function


////////////////////////////////////////////////////////////////////////////////
//spi_port_spi_mode_two_read_bytes_asm
//
//Reads bytes from memory up to and including speeds of 50MHz
//
//in      - internal_handle : spi_handle_t
//in/out  - rx_bytes : char*
//in      - num_bytes : unsigned
//return  - void
////////////////////////////////////////////////////////////////////////////////

.cc_top spi_port_spi_mode_two_read_bytes_asm.function
.globl  spi_port_spi_mode_two_read_bytes_asm
.align  4
.type spi_port_spi_mode_two_read_bytes_asm,@function

spi_port_spi_mode_two_read_bytes_asm:

.issue_mode dual
  DUALENTSP_lu6 STACKWORDS

retsp STACKWORDS

.spi_port_spi_mode_two_read_bytes_asm_tmp:
  .size spi_port_spi_mode_two_read_bytes_asm, .spi_port_spi_mode_two_read_bytes_asm_tmp - spi_port_spi_mode_two_read_bytes_asm
  .align  4
  .cc_bottom spi_port_spi_mode_two_read_bytes_asm.function


////////////////////////////////////////////////////////////////////////////////
//spi_port_spi_mode_three_read_bytes_asm
//
//Reads bytes from memory up to and including speeds of 50MHz
//
//in      - internal_handle : spi_handle_t
//in/out  - rx_bytes : char*
//in      - num_bytes : unsigned
//return  - void
////////////////////////////////////////////////////////////////////////////////

.cc_top spi_port_spi_mode_three_read_bytes_asm.function
.globl  spi_port_spi_mode_three_read_bytes_asm
.align  4
.type spi_port_spi_mode_three_read_bytes_asm,@function

spi_port_spi_mode_three_read_bytes_asm:

.issue_mode dual
  DUALENTSP_lu6 STACKWORDS

retsp STACKWORDS

.spi_port_spi_mode_three_read_bytes_asm_tmp:
  .size spi_port_spi_mode_three_read_bytes_asm, .spi_port_spi_mode_three_read_bytes_asm_tmp - spi_port_spi_mode_three_read_bytes_asm
  .align  4
  .cc_bottom spi_port_spi_mode_three_read_bytes_asm.function
