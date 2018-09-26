// Copyright (c) 2018, XMOS Ltd, All rights reserved

#ifndef _XMOS_SPI_H_
#define _XMOS_SPI_H_

#include <xccompat.h>
#include <xs1.h>
#include <stddef.h>

#include "spi_impl.h"

/**
 * CREATE_SPI_HANDLE: Create a handle using SPI ports to be used within this library
 *
 * Note: The parameters cs, sclk, mosi and miso must be declared as a global.
 *
 *  \param handle: spi_handle_t                       The handle obtained from create_spi_ports/create_qspi_ports.
 *  \param mode: spi_mode_t                           The mode SPI will operate in.
 *  \param sclk: out buffered port:32                 The port connected to the clock input for the device.
 *  \param mosi: out buffered port:32                 The port connected to the master output slave input for the device.
 *  \param miso: in buffered port:32                  The port connected to the master input slave output for the device.
 *  \param clk_blk: clock                             The clock resource for the device.
 **/
#define CREATE_SPI_HANDLE(handle, mode, sclk, mosi, miso, clk_blk) \
  (create_spi_handle(handle, mode, sclk, mosi, miso, clk_blk))

/**
 * CREATE_QSPI_HANDLE: Create a handle using Quad-SPI ports to be used within this library
 *
 * Note: The parameters cs, sclk and sio must be declared as a global.
 *
 *  \param handle: spi_handle_t                       The handle obtained from create_spi_ports/create_qspi_ports.
 *  \param mode: spi_mode_t                           The mode SPI will operate in.
 *  \param sclk: out buffered port:32                 The port connected to the clock input for the device.
 *  \param sio: [[bidirectional]] buffered port:32    The port connected to the master output slave input for the device.
 *  \param clk_blk: clock                             The clock resource for the device.
 **/
#if defined(__XS2A__)
#define CREATE_QSPI_HANDLE(handle, mode, sclk, sio, clk_blk) \
  (create_qspi_handle(handle, mode, sclk, sio, clk_blk))
#else //defined(__XS2A__)
#error "CREATE_QSPI_HANDLE() may only be used for XS2 devices"
#endif //defined(__XS2A__)

/**
 * spi_tx_bytes: transmit a sequence of 1..N bytes
 *
 *  \param spi_handle       The handle obtained from create_spi_ports/create_qspi_ports.
 *  \param transaction_type The type of transaction of the data.
 *  \param port_timings     The delay times in clock cycles for the ports to adhere to
 *  \param tx_bytes         The bytes to be transmitted.
 *  \param num_bytes        The number of bytes that are to be transmitted.
 **/
void spi_tx_bytes(const spi_handle_t * const spi_handle,
                  transaction_type_t transaction_type,
                  port_timings_t port_timings,
                  ARRAY_OF_SIZE(char, tx_bytes, num_bytes),
                  size_t num_bytes);

/**
 * spi_rx_bytes: receive a sequence of 1..N bytes
 *
 *  \param spi_handle       The handle obtained from create_spi_ports/create_qspi_ports.
 *  \param transaction_type The type of transaction of the data.
 *  \param port_timings     The delay times in clock cycles for the ports to adhere to
 *  \param rx_bytes         An array for the bytes to be received into.
 *  \param num_bytes        The number of bytes that are to be received.
 **/
void spi_rx_bytes(const spi_handle_t * const spi_handle,
                  transaction_type_t transaction_type,
                  port_timings_t port_timings,
                  ARRAY_OF_SIZE(char, rx_bytes, num_bytes),
                  size_t num_bytes);

/**
 * spi_tx_words: transmit a sequence of 1..N words
 *
 *  \param spi_handle       The handle obtained from create_spi_ports/create_qspi_ports.
 *  \param transaction_type The type of transaction of the data.
 *  \param port_timings     The delay times in clock cycles for the ports to adhere to
 *  \param tx_words         An array of words to be transmitted.
 *  \param num_words        The number of words that are to be transmitted.
 **/
void spi_tx_words(const spi_handle_t * const spi_handle,
                  transaction_type_t transaction_type,
                  port_timings_t port_timings,
                  ARRAY_OF_SIZE(unsigned, tx_words, num_words),
                  size_t num_words);

/**
 * spi_rx_words: receive a sequence of 1..N words
 *
 *  \param spi_handle       The handle obtained from create_spi_ports/create_qspi_ports.
 *  \param transaction_type The type of transaction of the data.
 *  \param port_timings     The delay times in clock cycles for the ports to adhere to
 *  \param rx_words         An array for the words to be received into.
 *  \param num_words        The number of words that are to be received.
 **/
void spi_rx_words(const spi_handle_t * const spi_handle,
                  transaction_type_t transaction_type,
                  port_timings_t port_timings,
                  ARRAY_OF_SIZE(unsigned, rx_words, num_words),
                  size_t num_words);

#endif // _XMOS_SPI_H_
