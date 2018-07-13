// Copyright (c) 2017-2018, XMOS Ltd, All rights reserved

#include <print.h>
#include <xclib.h>

#include "xmos_spi.h"

spi_ports_t spi_ports = {
                            {
                              {
                                XS1_PORT_1B,
                                XS1_PORT_1C,
                                XS1_PORT_1D,
                                XS1_PORT_1E,
                              }
                            },
                            spi_ports_impl,
                            XS1_CLKBLK_5
                          };

int main()
{
  char data[1] = {0xAB};
  spi_tx_bytes(&spi_ports, spi_mode_0, data, 1);
  return 0;
}
