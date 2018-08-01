// Copyright (c) 2017-2018, XMOS Ltd, All rights reserved

#ifndef _READ_WORDS_AS_QSPI_QSPI_PORTS_H_
#define _READ_WORDS_AS_QSPI_QSPI_PORTS_H_

#if defined(__XS2A__)

void qspi_port_qspi_mode_zero_read_words_asm(const spi_handle_t * const internal_handle,
                                             unsigned * rx_words,
                                             unsigned num_words);

void qspi_port_qspi_mode_one_read_words_asm(const spi_handle_t * const internal_handle,
                                            unsigned * rx_words,
                                            unsigned num_words);

void qspi_port_qspi_mode_two_read_words_asm(const spi_handle_t * const internal_handle,
                                            unsigned * rx_words,
                                            unsigned num_words);

void qspi_port_qspi_mode_three_read_words_asm(const spi_handle_t * const internal_handle,
                                              unsigned * rx_words,
                                              unsigned num_words);

#endif //defined(__XS2A__)

#endif //_READ_WORDS_AS_QSPI_QSPI_PORTS_H_
