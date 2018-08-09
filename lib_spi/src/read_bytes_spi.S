// Copyright (c) 2016-2018, XMOS Ltd, All rights reserved

#define STACKWORDS 8

.weak       _fptrgroup.SPI_RX_BYTES_IMPL.group
.weak       _fptrgroup.SPI_RX_BYTES_IMPL.nstackwords.group
.weak       _fptrgroup.SPI_RX_BYTES_IMPL.maxcores.group
.weak       _fptrgroup.SPI_RX_BYTES_IMPL.maxtimers.group
.weak       _fptrgroup.SPI_RX_BYTES_IMPL.maxchanends.group
.add_to_set _fptrgroup.SPI_RX_BYTES_IMPL.group, spi_port_spi_mode_zero_read_bytes_asm, spi_port_spi_mode_zero_read_bytes_asm
.add_to_set _fptrgroup.SPI_RX_BYTES_IMPL.nstackwords.group, spi_port_spi_mode_zero_read_bytes_asm.nstackwords, spi_port_spi_mode_zero_read_bytes_asm
.add_to_set _fptrgroup.SPI_RX_BYTES_IMPL.maxcores.group, spi_port_spi_mode_zero_read_bytes_asm.maxcores, spi_port_spi_mode_zero_read_bytes_asm
.add_to_set _fptrgroup.SPI_RX_BYTES_IMPL.maxtimers.group, spi_port_spi_mode_zero_read_bytes_asm.maxtimers, spi_port_spi_mode_zero_read_bytes_asm
.add_to_set _fptrgroup.SPI_RX_BYTES_IMPL.maxchanends.group, spi_port_spi_mode_zero_read_bytes_asm.maxchanends, spi_port_spi_mode_zero_read_bytes_asm
.add_to_set _fptrgroup.SPI_RX_BYTES_IMPL.group, spi_port_spi_mode_one_read_bytes_asm, spi_port_spi_mode_one_read_bytes_asm
.add_to_set _fptrgroup.SPI_RX_BYTES_IMPL.nstackwords.group, spi_port_spi_mode_one_read_bytes_asm.nstackwords, spi_port_spi_mode_one_read_bytes_asm
.add_to_set _fptrgroup.SPI_RX_BYTES_IMPL.maxcores.group, spi_port_spi_mode_one_read_bytes_asm.maxcores, spi_port_spi_mode_one_read_bytes_asm
.add_to_set _fptrgroup.SPI_RX_BYTES_IMPL.maxtimers.group, spi_port_spi_mode_one_read_bytes_asm.maxtimers, spi_port_spi_mode_one_read_bytes_asm
.add_to_set _fptrgroup.SPI_RX_BYTES_IMPL.maxchanends.group, spi_port_spi_mode_one_read_bytes_asm.maxchanends, spi_port_spi_mode_one_read_bytes_asm
.add_to_set _fptrgroup.SPI_RX_BYTES_IMPL.group, spi_port_spi_mode_two_read_bytes_asm, spi_port_spi_mode_two_read_bytes_asm
.add_to_set _fptrgroup.SPI_RX_BYTES_IMPL.nstackwords.group, spi_port_spi_mode_two_read_bytes_asm.nstackwords, spi_port_spi_mode_two_read_bytes_asm
.add_to_set _fptrgroup.SPI_RX_BYTES_IMPL.maxcores.group, spi_port_spi_mode_two_read_bytes_asm.maxcores, spi_port_spi_mode_two_read_bytes_asm
.add_to_set _fptrgroup.SPI_RX_BYTES_IMPL.maxtimers.group, spi_port_spi_mode_two_read_bytes_asm.maxtimers, spi_port_spi_mode_two_read_bytes_asm
.add_to_set _fptrgroup.SPI_RX_BYTES_IMPL.maxchanends.group, spi_port_spi_mode_two_read_bytes_asm.maxchanends, spi_port_spi_mode_two_read_bytes_asm
.add_to_set _fptrgroup.SPI_RX_BYTES_IMPL.group, spi_port_spi_mode_three_read_bytes_asm, spi_port_spi_mode_three_read_bytes_asm
.add_to_set _fptrgroup.SPI_RX_BYTES_IMPL.nstackwords.group, spi_port_spi_mode_three_read_bytes_asm.nstackwords, spi_port_spi_mode_three_read_bytes_asm
.add_to_set _fptrgroup.SPI_RX_BYTES_IMPL.maxcores.group, spi_port_spi_mode_three_read_bytes_asm.maxcores, spi_port_spi_mode_three_read_bytes_asm
.add_to_set _fptrgroup.SPI_RX_BYTES_IMPL.maxtimers.group, spi_port_spi_mode_three_read_bytes_asm.maxtimers, spi_port_spi_mode_three_read_bytes_asm
.add_to_set _fptrgroup.SPI_RX_BYTES_IMPL.maxchanends.group, spi_port_spi_mode_three_read_bytes_asm.maxchanends, spi_port_spi_mode_three_read_bytes_asm

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
