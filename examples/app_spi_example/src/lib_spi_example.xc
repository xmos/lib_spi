// Copyright (c) 2017-2018, XMOS Ltd, All rights reserved

#include <xclib.h>

#include "xmos_spi.h"

out port spi_cs = XS1_PORT_1B;
out buffered port:32 spi_sclk = XS1_PORT_1C;
out buffered port:32 spi_mosi = XS1_PORT_1D;
in buffered port:32 spi_miso = XS1_PORT_1E;
clock spi_clock = XS1_CLKBLK_5;

int main()
{
  char data[1] = {0xAB};
  spi_handle_t spi_handle;
  CREATE_SPI_HANDLE(&spi_handle, spi_mode_0, spi_cs, spi_sclk, spi_mosi, spi_miso, spi_clock);
  spi_rx_bytes(&spi_handle, data, 1);
  return 0;
}
