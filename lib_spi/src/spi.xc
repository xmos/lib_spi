// Copyright (c) 2018, XMOS Ltd, All rights reserved
#include "xmos_spi.h"

void spi_tx_bytes(const spi_handle_t * const spi_handle,
                  ARRAY_OF_SIZE(char, tx_bytes, num_bytes),
                  const size_t num_bytes)
{
  unsafe
  {
    spi_handle_impl_t *unsafe internal_handle = (spi_handle_impl_t *unsafe)spi_handle;
  }
}

void spi_rx_bytes(const spi_handle_t * const spi_handle,
                  ARRAY_OF_SIZE(char, rx_bytes, num_bytes),
                  const size_t num_bytes)
{
  unsafe
  {
    spi_handle_impl_t *unsafe internal_handle = (spi_handle_impl_t *unsafe)spi_handle;
  }
}

void spi_tx_words(const spi_handle_t * const spi_handle,
                  ARRAY_OF_SIZE(unsigned, tx_words, num_words),
                  const size_t num_words)
{
  unsafe
  {
    spi_handle_impl_t *unsafe internal_handle = (spi_handle_impl_t *unsafe)spi_handle;
  }
}

void spi_rx_words(const spi_handle_t * const spi_handle,
                  ARRAY_OF_SIZE(unsigned, rx_words, num_words),
                  const size_t num_words)
{
  unsafe
  {
    spi_handle_impl_t *unsafe internal_handle = (spi_handle_impl_t *unsafe)spi_handle;
  }
}
