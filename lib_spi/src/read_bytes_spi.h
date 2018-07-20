// Copyright (c) 2017-2018, XMOS Ltd, All rights reserved

#ifndef _READ_BYTES_SPI_H_
#define _READ_BYTES_SPI_H_

void spi_port_spi_mode_zero_read_bytes_asm(const spi_handle_t * const internal_handle,
                                           char * rx_bytes,
                                           unsigned num_bytes);

void spi_port_spi_mode_one_read_bytes_asm(const spi_handle_t * const internal_handle,
                                          char * rx_bytes,
                                          unsigned num_bytes);

void spi_port_spi_mode_two_read_bytes_asm(const spi_handle_t * const internal_handle,
                                          char * rx_bytes,
                                          unsigned num_bytes);

void spi_port_spi_mode_three_read_bytes_asm(const spi_handle_t * const internal_handle,
                                            char * rx_bytes,
                                            unsigned num_bytes);

#endif //_READ_BYTES_SPI_H_
