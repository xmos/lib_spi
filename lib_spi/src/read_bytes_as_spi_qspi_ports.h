// Copyright (c) 2017-2018, XMOS Ltd, All rights reserved

#ifndef _READ_BYTES_AS_SPI_QSPI_PORTS_H_
#define _READ_BYTES_AS_SPI_QSPI_PORTS_H_

#if defined(__XS2A__)

__attribute__((fptrgroup("SPI_RX_BYTES_IMPL")))
void qspi_port_spi_mode_zero_read_bytes_asm(const spi_handle_t * const internal_handle,
                                            const port_timings_t port_timings,
                                            char * rx_bytes,
                                            unsigned num_bytes);

__attribute__((fptrgroup("SPI_RX_BYTES_IMPL")))
void qspi_port_spi_mode_one_read_bytes_asm(const spi_handle_t * const internal_handle,
                                           const port_timings_t port_timings,
                                           char * rx_bytes,
                                           unsigned num_bytes);

__attribute__((fptrgroup("SPI_RX_BYTES_IMPL")))
void qspi_port_spi_mode_two_read_bytes_asm(const spi_handle_t * const internal_handle,
                                           const port_timings_t port_timings,
                                           char * rx_bytes,
                                           unsigned num_bytes);

__attribute__((fptrgroup("SPI_RX_BYTES_IMPL")))
void qspi_port_spi_mode_three_read_bytes_asm(const spi_handle_t * const internal_handle,
                                             const port_timings_t port_timings,
                                             char * rx_bytes,
                                             unsigned num_bytes);

#endif //defined(__XS2A__)

#endif //_READ_BYTES_AS_SPI_QSPI_PORTS_H_
