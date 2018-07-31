// Copyright (c) 2018, XMOS Ltd, All rights reserved

#include "spi_func_ptrs.h"

#include "read_bytes_spi.h"
#include "read_bytes_as_spi_qspi_ports.h"

#ifdef __XC__
extern "C" {
#endif

//Function pointers for the actual SPI/QSPI implementation

void (*fptr_spi_tx_bytes_impl)(const spi_handle_t * const internal_handle,
                               char * tx_bytes,
                               const unsigned int num_bytes);

void (*fptr_spi_rx_bytes_impl)(const spi_handle_t * const internal_handle,
                               char * rx_bytes,
                               const unsigned int num_bytes);

void (*fptr_spi_tx_words_impl)(const spi_handle_t * const internal_handle,
                               unsigned * tx_words,
                               const unsigned int num_words);

void (*fptr_spi_rx_words_impl)(const spi_handle_t * const internal_handle,
                               unsigned * rx_words,
                               const unsigned int num_words);


//Accessors for the function pointers

void spi_tx_bytes_impl(const spi_handle_t * const internal_handle,
                       char * tx_bytes,
                       const unsigned int num_bytes)
{
  (*fptr_spi_tx_bytes_impl)(internal_handle, tx_bytes, num_bytes);
}



void spi_rx_bytes_impl(const spi_handle_t * const internal_handle,
                       char * rx_bytes,
                       const unsigned int num_bytes)
{
  (*fptr_spi_rx_bytes_impl)(internal_handle, rx_bytes, num_bytes);
}



void spi_tx_words_impl(const spi_handle_t * const internal_handle,
                       unsigned * tx_words,
                       const unsigned int num_words)
{
  (*fptr_spi_tx_words_impl)(internal_handle, tx_words, num_words);
}



void spi_rx_words_impl(const spi_handle_t * const internal_handle,
                       unsigned * rx_words,
                       const unsigned int num_words)
{
  (*fptr_spi_rx_words_impl)(internal_handle, rx_words, num_words);
}

//SPI Mode function pointer allocations

void set_spi_mode_zero_fptrs(void)
{
  fptr_spi_rx_bytes_impl = &spi_port_spi_mode_zero_read_bytes_asm;
  //TODO: fptr_spi_tx_bytes_impl = &spi_port_spi_mode_zero_write_bytes_asm;
  //TODO: fptr_spi_rx_words_impl = &spi_port_spi_mode_zero_read_words_asm;
  //TODO: fptr_spi_tx_words_impl = &spi_port_spi_mode_zero_write_words_asm;
}

void set_spi_mode_one_fptrs(void)
{
  fptr_spi_rx_bytes_impl = &spi_port_spi_mode_one_read_bytes_asm;
  //TODO: fptr_spi_tx_bytes_impl = &spi_port_spi_mode_one_write_bytes_asm;
  //TODO: fptr_spi_rx_words_impl = &spi_port_spi_mode_one_read_words_asm;
  //TODO: fptr_spi_tx_words_impl = &spi_port_spi_mode_one_write_words_asm;
}

void set_spi_mode_two_fptrs(void)
{
  fptr_spi_rx_bytes_impl = &spi_port_spi_mode_two_read_bytes_asm;
  //TODO: fptr_spi_tx_bytes_impl = &spi_port_spi_mode_two_write_bytes_asm;
  //TODO: fptr_spi_rx_words_impl = &spi_port_spi_mode_two_read_words_asm;
  //TODO: fptr_spi_tx_words_impl = &spi_port_spi_mode_two_write_words_asm;
}

void set_spi_mode_three_fptrs(void)
{
  fptr_spi_rx_bytes_impl = &spi_port_spi_mode_three_read_bytes_asm;
  //TODO: fptr_spi_tx_bytes_impl = &spi_port_spi_mode_three_write_bytes_asm;
  //TODO: fptr_spi_rx_words_impl = &spi_port_spi_mode_three_read_words_asm;
  //TODO: fptr_spi_tx_words_impl = &spi_port_spi_mode_three_write_words_asm;
}

//QSPI Mode function pointer allocations

#if defined(__XS2A__)

void set_qspi_mode_zero_fptrs(void)
{
  fptr_spi_rx_bytes_impl = &qspi_port_spi_mode_zero_read_bytes_asm;
  //TODO: fptr_spi_tx_bytes_impl = &qspi_port_spi_mode_zero_write_bytes_asm;
  //TODO: fptr_spi_rx_words_impl = &qspi_port_spi_mode_zero_read_words_asm;
  //TODO: fptr_spi_tx_words_impl = &qspi_port_spi_mode_zero_write_words_asm;
}

void set_qspi_mode_one_fptrs(void)
{
  fptr_spi_rx_bytes_impl = &qspi_port_spi_mode_one_read_bytes_asm;
  //TODO: fptr_spi_tx_bytes_impl = &qspi_port_spi_mode_one_write_bytes_asm;
  //TODO: fptr_spi_rx_words_impl = &qspi_port_spi_mode_one_read_words_asm;
  //TODO: fptr_spi_tx_words_impl = &qspi_port_spi_mode_one_write_words_asm;
}

void set_qspi_mode_two_fptrs(void)
{
  fptr_spi_rx_bytes_impl = &qspi_port_spi_mode_two_read_bytes_asm;
  //TODO: fptr_spi_tx_bytes_impl = &qspi_port_spi_mode_two_write_bytes_asm;
  //TODO: fptr_spi_rx_words_impl = &qspi_port_spi_mode_two_read_words_asm;
  //TODO: fptr_spi_tx_words_impl = &qspi_port_spi_mode_two_write_words_asm;
}

void set_qspi_mode_three_fptrs(void)
{
  fptr_spi_rx_bytes_impl = &qspi_port_spi_mode_three_read_bytes_asm;
  //TODO: fptr_spi_tx_bytes_impl = &qspi_port_spi_mode_three_write_bytes_asm;
  //TODO: fptr_spi_rx_words_impl = &qspi_port_spi_mode_three_read_words_asm;
  //TODO: fptr_spi_tx_words_impl = &qspi_port_spi_mode_three_write_words_asm;
}

#endif //defined(__XS2A__)

#ifdef __XC__
} // extern "C"
#endif
