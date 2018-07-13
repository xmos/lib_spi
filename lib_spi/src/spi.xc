// Copyright (c) 2018, XMOS Ltd, All rights reserved
#include "xmos_spi.h"

void spi_tx_bytes(const spi_ports_t * spi_ports,
                  const spi_mode_t spi_mode,
                  ARRAY_OF_SIZE(char, tx_bytes, num_bytes),
                  const size_t num_bytes)
{
  //Determine if this is a transmission via standart SPI ports or via QSPI ports
  //TODO:  Assess how efficient this code is in terms of size and speed.  We
  //could have timing issues where the time between make this call and the
  //transmission actually being made it too long.
  switch(spi_ports->port_type)
  {
    case spi_ports_impl:
      //Do SPI transmit
      break;
    case qspi_ports_impl:
      //Do QSPI transmit
      break;
    default:
      #if defined(XASSERT_ENABLE_ASSERTIONS)
        assert(0 && msg("Invalid ports_type_t value"));
      #endif //defined(XASSERT_ENABLE_ASSERTIONS)
      __builtin_unreachable();
      break;
  }
}

void spi_rx_bytes(const spi_ports_t * spi_ports,
                  const spi_mode_t spi_mode,
                  ARRAY_OF_SIZE(char, rx_bytes, num_bytes),
                  const size_t num_bytes)
{
  //TODO
}

void spi_tx_words(const spi_ports_t * spi_ports,
                  const spi_mode_t spi_mode,
                  ARRAY_OF_SIZE(unsigned, tx_words, num_words),
                  const size_t num_words)
{
  //TODO
}

void spi_rx_words(const spi_ports_t * spi_ports,
                  const spi_mode_t spi_mode,
                  ARRAY_OF_SIZE(unsigned, rx_words, num_words),
                  const size_t num_words)
{
  //TODO
}
