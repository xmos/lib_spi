// Copyright (c) 2018, XMOS Ltd, All rights reserved

#ifndef _XMOS_SPI_H_
#define _XMOS_SPI_H_

#include <xccompat.h> //From the xTIMEcomposer tools
#include <xs1.h>
#include <stddef.h>

#include "spi_ports.h"

typedef enum ports_type_t
{
  spi_ports_impl,
  qspi_ports_impl,
} ports_type_t;

typedef enum spi_mode_t
{
  spi_mode_0, //CPOL 0; CPHA 0;
  spi_mode_1, //CPOL 0; CPHA 1;
  spi_mode_2, //CPOL 1; CPHA 0;
  spi_mode_3, //CPOL 1; CPHA 1;
}spi_mode_t;

typedef struct spi_ports_t
{
  ports_union_t ports_impl;
  ports_type_t  port_type;
  clock         spi_clk_blk;
} spi_ports_t;


/**
 * spi_tx_bytes: transmit a sequence of 1..N bytes
 *
 * Note: The parameter spi_ports must be declared as a global.
 *
 *  \param spi_ports        The spi ports to be used by the library.
 *  \param spi_mode         The SPI mode of operation (determines CPOL and CPHA)
 *  \param tx_bytes         The bytes to be transmitted.
 *  \param num_bytes        The number of byters that are to be transmitted.
 **/
void spi_tx_bytes(const spi_ports_t * spi_ports,
                  const spi_mode_t spi_mode,
                  ARRAY_OF_SIZE(char, tx_bytes, num_bytes),
                  const size_t num_bytes);

void spi_rx_bytes(const spi_ports_t * spi_ports,
                  const spi_mode_t spi_mode,
                  ARRAY_OF_SIZE(char, rx_bytes, num_bytes),
                  const size_t num_bytes);

void spi_tx_words(const spi_ports_t * spi_ports,
                  const spi_mode_t spi_mode,
                  ARRAY_OF_SIZE(unsigned, tx_words, num_words),
                  const size_t num_words);

void spi_rx_words(const spi_ports_t * spi_ports,
                  const spi_mode_t spi_mode,
                  ARRAY_OF_SIZE(unsigned, rx_words, num_words),
                  const size_t num_words);

#endif // _XMOS_SPI_H_
