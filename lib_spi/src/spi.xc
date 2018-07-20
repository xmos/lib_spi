// Copyright (c) 2018, XMOS Ltd, All rights reserved

#include "xmos_spi.h"

#include "spi_func_ptrs.h"

void spi_tx_bytes(const spi_handle_t * const spi_handle,
                  ARRAY_OF_SIZE(char, tx_bytes, num_bytes),
                  const size_t num_bytes)
{
  spi_tx_bytes_impl(spi_handle, tx_bytes, num_bytes);
}

void spi_rx_bytes(const spi_handle_t * const spi_handle,
                  ARRAY_OF_SIZE(char, rx_bytes, num_bytes),
                  const size_t num_bytes)
{
  spi_rx_bytes_impl(spi_handle, rx_bytes, num_bytes);
}

void spi_tx_words(const spi_handle_t * const spi_handle,
                  ARRAY_OF_SIZE(unsigned, tx_words, num_words),
                  const size_t num_words)
{
  spi_tx_words_impl(spi_handle, tx_words, num_words);
}

void spi_rx_words(const spi_handle_t * const spi_handle,
                  ARRAY_OF_SIZE(unsigned, rx_words, num_words),
                  const size_t num_words)
{
  spi_rx_words_impl(spi_handle, rx_words, num_words);
}
