// Copyright (c) 2018, XMOS Ltd, All rights reserved

#include "xmos_spi.h"

#include "spi_func_ptrs.h"

#if defined(XASSERT_ENABLE_ASSERTIONS)
#include <xassert.h>
#endif //defined(XASSERT_ENABLE_ASSERTIONS)

void spi_tx_bytes(const spi_handle_t * const spi_handle,
                  const transaction_type_t transaction_type,
                  const port_timings_t port_timings,
                  ARRAY_OF_SIZE(char, tx_bytes, num_bytes),
                  const size_t num_bytes)
{
  switch(transaction_type)
  {
    //Suitable for both SPI and QSPI ports
    case transaction_type_spi:
      spi_tx_bytes_impl(spi_handle, port_timings, tx_bytes, num_bytes);
      break;
    //Suitable only for QSPI ports
    case ports_type_qspi:
      #if defined(XASSERT_ENABLE_ASSERTIONS)
      unsafe
      {
        spi_handle_impl_t *unsafe internal_handle = (spi_handle_impl_t *unsafe)spi_handle;
        assert(internal_handle->port_type == ports_type_qspi && msg("transaction_type_qspi can only be used in conjunction with QSPI ports"));
      }
      #endif //defined(XASSERT_ENABLE_ASSERTIONS)
      qspi_tx_bytes_impl(spi_handle, port_timings, tx_bytes, num_bytes);
      break;
    default:
      __builtin_unreachable();
      break;
  }
}

void spi_rx_bytes(const spi_handle_t * const spi_handle,
                  const transaction_type_t transaction_type,
                  const port_timings_t port_timings,
                  ARRAY_OF_SIZE(char, rx_bytes, num_bytes),
                  const size_t num_bytes)
{
  switch(transaction_type)
  {
    //Suitable for both SPI and QSPI ports
    case transaction_type_spi:
      spi_rx_bytes_impl(spi_handle, port_timings, rx_bytes, num_bytes);
      break;
    //Suitable only for QSPI ports
    case ports_type_qspi:
      #if defined(XASSERT_ENABLE_ASSERTIONS)
      unsafe
      {
        spi_handle_impl_t *unsafe internal_handle = (spi_handle_impl_t *unsafe)spi_handle;
        assert(internal_handle->port_type == ports_type_qspi && msg("transaction_type_qspi can only be used in conjunction with QSPI ports"));
      }
      #endif //defined(XASSERT_ENABLE_ASSERTIONS)
      qspi_rx_bytes_impl(spi_handle, port_timings, rx_bytes, num_bytes);
      break;
    default:
      __builtin_unreachable();
      break;
  }
}

void spi_tx_words(const spi_handle_t * const spi_handle,
                  const transaction_type_t transaction_type,
                  const port_timings_t port_timings,
                  ARRAY_OF_SIZE(unsigned, tx_words, num_words),
                  const size_t num_words)
{
  switch(transaction_type)
  {
    //Suitable for both SPI and QSPI ports
    case transaction_type_spi:
      spi_tx_words_impl(spi_handle, port_timings, tx_words, num_words);
      break;
    //Suitable only for QSPI ports
    case ports_type_qspi:
      #if defined(XASSERT_ENABLE_ASSERTIONS)
      unsafe
      {
        spi_handle_impl_t *unsafe internal_handle = (spi_handle_impl_t *unsafe)spi_handle;
        assert(internal_handle->port_type == ports_type_qspi && msg("transaction_type_qspi can only be used in conjunction with QSPI ports"));
      }
      #endif //defined(XASSERT_ENABLE_ASSERTIONS)
      qspi_tx_words_impl(spi_handle, port_timings, tx_words, num_words);
      break;
    default:
      __builtin_unreachable();
      break;
  }
}

void spi_rx_words(const spi_handle_t * const spi_handle,
                  const transaction_type_t transaction_type,
                  const port_timings_t port_timings,
                  ARRAY_OF_SIZE(unsigned, rx_words, num_words),
                  const size_t num_words)
{
  switch(transaction_type)
  {
    //Suitable for both SPI and QSPI ports
    case transaction_type_spi:
      spi_rx_words_impl(spi_handle, port_timings, rx_words, num_words);
      break;
    //Suitable only for QSPI ports
    case ports_type_qspi:
      #if defined(XASSERT_ENABLE_ASSERTIONS)
      unsafe
      {
        spi_handle_impl_t *unsafe internal_handle = (spi_handle_impl_t *unsafe)spi_handle;
        assert(internal_handle->port_type == ports_type_qspi && msg("transaction_type_qspi can only be used in conjunction with QSPI ports"));
      }
      #endif //defined(XASSERT_ENABLE_ASSERTIONS)
      qspi_rx_words_impl(spi_handle, port_timings, rx_words, num_words);
      break;
    default:
      __builtin_unreachable();
      break;
  }
}
