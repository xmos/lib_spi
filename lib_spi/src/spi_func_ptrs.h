// Copyright (c) 2018, XMOS Ltd, All rights reserved

#ifndef _SPI_FUNC_PTRS_H_
#define _SPI_FUNC_PTRS_H_

#include "spi_impl.h"

#ifdef __XC__
extern "C" {
#endif

//Accessors for the function pointers
void spi_tx_bytes_impl(const spi_handle_t * const internal_handle,
                       const port_timings_t port_timings,
                       char * tx_bytes,
                       const unsigned int num_bytes);

void spi_rx_bytes_impl(const spi_handle_t * const internal_handle,
                       const port_timings_t port_timings,
                       char * rx_bytes,
                       const unsigned int num_bytes);

void spi_tx_words_impl(const spi_handle_t * const internal_handle,
                       const port_timings_t port_timings,
                       unsigned * tx_words,
                       const unsigned int num_words);

void spi_rx_words_impl(const spi_handle_t * const internal_handle,
                       const port_timings_t port_timings,
                       unsigned * rx_words,
                       const unsigned int num_words);

void qspi_tx_bytes_impl(const spi_handle_t * const internal_handle,
                        const port_timings_t port_timings,
                        char * tx_bytes,
                        const unsigned int num_bytes);

void qspi_rx_bytes_impl(const spi_handle_t * const internal_handle,
                        const port_timings_t port_timings,
                        char * rx_bytes,
                        const unsigned int num_bytes);

void qspi_tx_words_impl(const spi_handle_t * const internal_handle,
                        const port_timings_t port_timings,
                        unsigned * tx_words,
                        const unsigned int num_words);

void qspi_rx_words_impl(const spi_handle_t * const internal_handle,
                        const port_timings_t port_timings,
                        unsigned * rx_words,
                        const unsigned int num_words);

//SPI Mode function pointer allocations
void set_spi_port_mode_zero_fptrs(void);
void set_spi_port_mode_one_fptrs(void);
void set_spi_port_mode_two_fptrs(void);
void set_spi_port_mode_three_fptrs(void);

//QSPI Mode function pointer allocations
#if defined(__XS2A__)
void set_qspi_port_mode_zero_fptrs(void);
void set_qspi_port_mode_one_fptrs(void);
void set_qspi_port_mode_two_fptrs(void);
void set_qspi_port_mode_three_fptrs(void);
#endif //defined(__XS2A__)

#ifdef __XC__
} // extern "C"
#endif

#endif //_SPI_FUNC_PTRS_H_
