// Copyright (c) 2017-2018, XMOS Ltd, All rights reserved

#ifndef _WRITE_BYTES_AS_SPI_QSPI_PORTS_H_
#define _WRITE_BYTES_AS_SPI_QSPI_PORTS_H_

#if defined(__XS2A__)

void qspi_port_spi_mode_zero_write_bytes_asm(const spi_handle_t * const internal_handle,
                                             char * rx_bytes,
                                             unsigned num_bytes);

void qspi_port_spi_mode_one_write_bytes_asm(const spi_handle_t * const internal_handle,
                                            char * rx_bytes,
                                            unsigned num_bytes);

void qspi_port_spi_mode_two_write_bytes_asm(const spi_handle_t * const internal_handle,
                                            char * rx_bytes,
                                            unsigned num_bytes);

void qspi_port_spi_mode_three_write_bytes_asm(const spi_handle_t * const internal_handle,
                                              char * rx_bytes,
                                              unsigned num_bytes);

#endif //defined(__XS2A__)

#endif //_WRITE_BYTES_AS_SPI_QSPI_PORTS_H_
