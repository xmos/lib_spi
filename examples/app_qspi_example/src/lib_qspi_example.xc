// Copyright (c) 2017-2018, XMOS Ltd, All rights reserved

#include <xclib.h>

#include "xmos_spi.h"

out port qspi_cs = XS1_PORT_1B;
out buffered port:32 qspi_sclk = XS1_PORT_1C;
[[bidirectional]] buffered port:32 qspi_sio = XS1_PORT_4B;
clock qspi_clock = XS1_CLKBLK_5;

int main()
{
  char data[1] = {0xAB};
  struct spi_handle_t spi_handle;
  CREATE_QSPI_HANDLE(&spi_handle, spi_mode_0, qspi_cs, qspi_sclk, qspi_sio, qspi_clock);
  spi_rx_bytes(&spi_handle, data, 1);
  return 0;
}
