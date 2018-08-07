// Copyright (c) 2018, XMOS Ltd, All rights reserved

#include <stddef.h>

#include "spi_func_ptrs.h"

#include "read_bytes_spi.h"
#include "read_bytes_as_spi_qspi_ports.h"

#include "read_words_as_qspi_qspi_ports.h"

#include "write_bytes_as_spi_qspi_ports.h"

#ifdef __XC__
extern "C" {
#endif

//Function pointers for the actual SPI/QSPI implementation

void (*fptr_spi_tx_bytes_impl)(const spi_handle_t * const internal_handle,
                               const port_timings_t port_timings,
                               char * tx_bytes,
                               const unsigned int num_bytes);

void (*fptr_spi_rx_bytes_impl)(const spi_handle_t * const internal_handle,
                               const port_timings_t port_timings,
                               char * rx_bytes,
                               const unsigned int num_bytes);

void (*fptr_spi_tx_words_impl)(const spi_handle_t * const internal_handle,
                               const port_timings_t port_timings,
                               unsigned * tx_words,
                               const unsigned int num_words);

void (*fptr_spi_rx_words_impl)(const spi_handle_t * const internal_handle,
                               const port_timings_t port_timings,
                               unsigned * rx_words,
                               const unsigned int num_words);

void (*fptr_qspi_tx_bytes_impl)(const spi_handle_t * const internal_handle,
                                const port_timings_t port_timings,
                                char * tx_bytes,
                                const unsigned int num_bytes);

void (*fptr_qspi_rx_bytes_impl)(const spi_handle_t * const internal_handle,
                                const port_timings_t port_timings,
                                char * rx_bytes,
                                const unsigned int num_bytes);

void (*fptr_qspi_tx_words_impl)(const spi_handle_t * const internal_handle,
                                const port_timings_t port_timings,
                                unsigned * tx_words,
                                const unsigned int num_words);

void (*fptr_qspi_rx_words_impl)(const spi_handle_t * const internal_handle,
                                const port_timings_t port_timings,
                                unsigned * rx_words,
                                const unsigned int num_words);


//Accessors for the function pointers

void spi_tx_bytes_impl(const spi_handle_t * const internal_handle,
                       const port_timings_t port_timings,
                       char * tx_bytes,
                       const unsigned int num_bytes)
{
  (*fptr_spi_tx_bytes_impl)(internal_handle, port_timings, tx_bytes, num_bytes);
}



void spi_rx_bytes_impl(const spi_handle_t * const internal_handle,
                       const port_timings_t port_timings,
                       char * rx_bytes,
                       const unsigned int num_bytes)
{
  (*fptr_spi_rx_bytes_impl)(internal_handle, port_timings, rx_bytes, num_bytes);
}



void spi_tx_words_impl(const spi_handle_t * const internal_handle,
                       const port_timings_t port_timings,
                       unsigned * tx_words,
                       const unsigned int num_words)
{
  (*fptr_spi_tx_words_impl)(internal_handle, port_timings, tx_words, num_words);
}



void spi_rx_words_impl(const spi_handle_t * const internal_handle,
                       const port_timings_t port_timings,
                       unsigned * rx_words,
                       const unsigned int num_words)
{
  (*fptr_spi_rx_words_impl)(internal_handle, port_timings, rx_words, num_words);
}



void qspi_tx_bytes_impl(const spi_handle_t * const internal_handle,
                        const port_timings_t port_timings,
                        char * tx_bytes,
                        const unsigned int num_bytes)
{
  (*fptr_qspi_tx_bytes_impl)(internal_handle, port_timings, tx_bytes, num_bytes);
}



void qspi_rx_bytes_impl(const spi_handle_t * const internal_handle,
                        const port_timings_t port_timings,
                        char * rx_bytes,
                        const unsigned int num_bytes)
{
  (*fptr_qspi_rx_bytes_impl)(internal_handle, port_timings, rx_bytes, num_bytes);
}



void qspi_tx_words_impl(const spi_handle_t * const internal_handle,
                        const port_timings_t port_timings,
                        unsigned * tx_words,
                        const unsigned int num_words)
{
  (*fptr_qspi_tx_words_impl)(internal_handle, port_timings, tx_words, num_words);
}



void qspi_rx_words_impl(const spi_handle_t * const internal_handle,
                        const port_timings_t port_timings,
                        unsigned * rx_words,
                        const unsigned int num_words)
{
  (*fptr_qspi_rx_words_impl)(internal_handle, port_timings, rx_words, num_words);
}



//SPI port function pointer allocations

void set_spi_port_mode_zero_fptrs(void)
{
  //For SPI transactions...
  fptr_spi_rx_bytes_impl = &spi_port_spi_mode_zero_read_bytes_asm;
  //TODO: fptr_spi_tx_bytes_impl = &spi_port_spi_mode_zero_write_bytes_asm;
  //TODO: fptr_spi_rx_words_impl = &spi_port_spi_mode_zero_read_words_asm;
  //TODO: fptr_spi_tx_words_impl = &spi_port_spi_mode_zero_write_words_asm;

  //No QSPI transactions supported
  fptr_qspi_rx_bytes_impl = NULL;
  fptr_qspi_tx_bytes_impl = NULL;
  fptr_qspi_rx_words_impl = NULL;
  fptr_qspi_tx_words_impl = NULL;
}

void set_spi_port_mode_one_fptrs(void)
{
  //For SPI transactions...
  fptr_spi_rx_bytes_impl = &spi_port_spi_mode_one_read_bytes_asm;
  //TODO: fptr_spi_tx_bytes_impl = &spi_port_spi_mode_one_write_bytes_asm;
  //TODO: fptr_spi_rx_words_impl = &spi_port_spi_mode_one_read_words_asm;
  //TODO: fptr_spi_tx_words_impl = &spi_port_spi_mode_one_write_words_asm;

  //No QSPI transactions supported
  fptr_qspi_rx_bytes_impl = NULL;
  fptr_qspi_tx_bytes_impl = NULL;
  fptr_qspi_rx_words_impl = NULL;
  fptr_qspi_tx_words_impl = NULL;
}

void set_spi_port_mode_two_fptrs(void)
{
  //For SPI transactions...
  fptr_spi_rx_bytes_impl = &spi_port_spi_mode_two_read_bytes_asm;
  //TODO: fptr_spi_tx_bytes_impl = &spi_port_spi_mode_two_write_bytes_asm;
  //TODO: fptr_spi_rx_words_impl = &spi_port_spi_mode_two_read_words_asm;
  //TODO: fptr_spi_tx_words_impl = &spi_port_spi_mode_two_write_words_asm;

  //No QSPI transactions supported
  fptr_qspi_rx_bytes_impl = NULL;
  fptr_qspi_tx_bytes_impl = NULL;
  fptr_qspi_rx_words_impl = NULL;
  fptr_qspi_tx_words_impl = NULL;
}

void set_spi_port_mode_three_fptrs(void)
{
  //For SPI transactions...
  fptr_spi_rx_bytes_impl = &spi_port_spi_mode_three_read_bytes_asm;
  //TODO: fptr_spi_tx_bytes_impl = &spi_port_spi_mode_three_write_bytes_asm;
  //TODO: fptr_spi_rx_words_impl = &spi_port_spi_mode_three_read_words_asm;
  //TODO: fptr_spi_tx_words_impl = &spi_port_spi_mode_three_write_words_asm;

  //No QSPI transactions supported
  fptr_qspi_rx_bytes_impl = NULL;
  fptr_qspi_tx_bytes_impl = NULL;
  fptr_qspi_rx_words_impl = NULL;
  fptr_qspi_tx_words_impl = NULL;
}

//QSPI port function pointer allocations

#if defined(__XS2A__)

void set_qspi_port_mode_zero_fptrs(void)
{
  //For SPI transactions...
  fptr_spi_rx_bytes_impl = &qspi_port_spi_mode_zero_read_bytes_asm;
  fptr_spi_tx_bytes_impl = &qspi_port_spi_mode_zero_write_bytes_asm;
  //TODO: fptr_spi_rx_words_impl = &qspi_port_spi_mode_zero_read_words_asm;
  //TODO: fptr_spi_tx_words_impl = &qspi_port_spi_mode_zero_write_words_asm;

  //For QSPI transactions...
  //TODO: fptr_qspi_rx_bytes_impl = &qspi_port_qspi_mode_zero_read_bytes_asm;
  //TODO: fptr_qspi_tx_bytes_impl = &qspi_port_qspi_mode_zero_write_bytes_asm;
  fptr_qspi_rx_words_impl = &qspi_port_qspi_mode_zero_read_words_asm;
  //TODO: fptr_qspi_tx_words_impl = &qspi_port_qspi_mode_zero_write_words_asm;
}

void set_qspi_port_mode_one_fptrs(void)
{
  //For SPI transactions...
  fptr_spi_rx_bytes_impl = &qspi_port_spi_mode_one_read_bytes_asm;
  fptr_spi_tx_bytes_impl = &qspi_port_spi_mode_one_write_bytes_asm;
  //TODO: fptr_spi_rx_words_impl = &qspi_port_spi_mode_one_read_words_asm;
  //TODO: fptr_spi_tx_words_impl = &qspi_port_spi_mode_one_write_words_asm;

  //For QSPI transactions...
  //TODO: fptr_qspi_rx_bytes_impl = &qspi_port_qspi_mode_one_read_bytes_asm;
  //TODO: fptr_qspi_tx_bytes_impl = &qspi_port_qspi_mode_one_write_bytes_asm;
  fptr_qspi_rx_words_impl = &qspi_port_qspi_mode_one_read_words_asm;
  //TODO: fptr_qspi_tx_words_impl = &qspi_port_qspi_mode_one_write_words_asm;
}

void set_qspi_port_mode_two_fptrs(void)
{
  //For SPI transactions...
  fptr_spi_rx_bytes_impl = &qspi_port_spi_mode_two_read_bytes_asm;
  fptr_spi_tx_bytes_impl = &qspi_port_spi_mode_two_write_bytes_asm;
  //TODO: fptr_spi_rx_words_impl = &qspi_port_spi_mode_two_read_words_asm;
  //TODO: fptr_spi_tx_words_impl = &qspi_port_spi_mode_two_write_words_asm;

  //For QSPI transactions...
  //TODO: fptr_qspi_rx_bytes_impl = &qspi_port_qspi_mode_two_read_bytes_asm;
  //TODO: fptr_qspi_tx_bytes_impl = &qspi_port_qspi_mode_two_write_bytes_asm;
  fptr_qspi_rx_words_impl = &qspi_port_qspi_mode_two_read_words_asm;
  //TODO: fptr_qspi_tx_words_impl = &qspi_port_qspi_mode_two_write_words_asm;
}

void set_qspi_port_mode_three_fptrs(void)
{
  //For SPI transactions...
  fptr_spi_rx_bytes_impl = &qspi_port_spi_mode_three_read_bytes_asm;
  fptr_spi_tx_bytes_impl = &qspi_port_spi_mode_three_write_bytes_asm;
  //TODO: fptr_spi_rx_words_impl = &qspi_port_spi_mode_three_read_words_asm;
  //TODO: fptr_spi_tx_words_impl = &qspi_port_spi_mode_three_write_words_asm;

  //For QSPI transactions...
  //TODO: fptr_qspi_rx_bytes_impl = &qspi_port_qspi_mode_three_read_bytes_asm;
  //TODO: fptr_qspi_tx_bytes_impl = &qspi_port_qspi_mode_three_write_bytes_asm;
  fptr_qspi_rx_words_impl = &qspi_port_qspi_mode_three_read_words_asm;
  //TODO: fptr_qspi_tx_words_impl = &qspi_port_qspi_mode_three_write_words_asm;
}

#endif //defined(__XS2A__)

#ifdef __XC__
} // extern "C"
#endif
