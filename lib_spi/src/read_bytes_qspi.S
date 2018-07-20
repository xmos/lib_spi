// Copyright (c) 2016-2018, XMOS Ltd, All rights reserved

#if defined(__XS2A__)

#define STACKWORDS 8

////////////////////////////////////////////////////////////////////////////////
//qspi_port_spi_mode_zero_read_bytes_asm
//
//Reads bytes from memory up to and including speeds of 50MHz
//
//in      - internal_handle : spi_handle_t
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
  DUALENTSP_lu6 STACKWORDS

retsp STACKWORDS

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
  DUALENTSP_lu6 STACKWORDS

retsp STACKWORDS

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
  DUALENTSP_lu6 STACKWORDS

retsp STACKWORDS

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
  DUALENTSP_lu6 STACKWORDS

retsp STACKWORDS

.qspi_port_spi_mode_three_read_bytes_asm_tmp:
  .size qspi_port_spi_mode_three_read_bytes_asm, .qspi_port_spi_mode_three_read_bytes_asm_tmp - qspi_port_spi_mode_three_read_bytes_asm
  .align  4
  .cc_bottom qspi_port_spi_mode_three_read_bytes_asm.function


#endif //defined(__XS2A__)
