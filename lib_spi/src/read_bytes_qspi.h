// Copyright (c) 2017-2018, XMOS Ltd, All rights reserved

#ifndef _READ_BYTES_QSPI_H_
#define _READ_BYTES_QSPI_H_

#if defined(__XS2A__)

void qspi_port_spi_mode_zero_read_bytes_asm(const spi_handle_t * const internal_handle,
                                            char * rx_bytes,
                                            unsigned num_bytes);

void qspi_port_spi_mode_one_read_bytes_asm(const spi_handle_t * const internal_handle,
                                           char * rx_bytes,
                                           unsigned num_bytes);

void qspi_port_spi_mode_two_read_bytes_asm(const spi_handle_t * const internal_handle,
                                           char * rx_bytes,
                                           unsigned num_bytes);

void qspi_port_spi_mode_three_read_bytes_asm(const spi_handle_t * const internal_handle,
                                             char * rx_bytes,
                                             unsigned num_bytes);

#endif //defined(__XS2A__)

#endif //_READ_BYTES_QSPI_H_
