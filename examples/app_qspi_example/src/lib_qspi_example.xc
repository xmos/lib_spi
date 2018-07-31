// Copyright (c) 2017-2018, XMOS Ltd, All rights reserved

#include <xclib.h>

#include "xmos_spi.h"

out port qspi_cs = XS1_PORT_1B;
out buffered port:32 qspi_sclk = XS1_PORT_1C;
[[bidirectional]] buffered port:32 qspi_sio = XS1_PORT_4B;
clock qspi_clock = XS1_CLKBLK_5;

void drive_cs_hi(void)
{
  qspi_cs <: 1;
  sync(qspi_cs);
}

void drive_cs_lo(void)
{
  qspi_cs <: 0;
  sync(qspi_cs);
}

void configure_ports()
{
  set_port_use_on(qspi_cs);
  set_port_use_on(qspi_sclk);
  set_port_use_on(qspi_sio);

  drive_cs_hi();

  set_clock_on(qspi_clock);
  set_clock_div(qspi_clock, 10);

  set_port_clock(qspi_sclk, qspi_clock);
  set_port_clock(qspi_sio, qspi_clock);

  start_clock(qspi_clock);
}

int main()
{
  configure_ports();

  struct spi_handle_t spi_handle;
  CREATE_QSPI_HANDLE(&spi_handle, spi_mode_0, qspi_cs, qspi_sclk, qspi_sio, qspi_clock);

  char output_data_single[1] = {0x9F};
  drive_cs_lo();
  spi_tx_bytes(&spi_handle, output_data_single, 1);
  drive_cs_hi();

  char output_data_multi[5] = {0x9F, 0xEB, 0xA4, 0x71, 0x63};
  drive_cs_lo();
  spi_tx_bytes(&spi_handle, output_data_multi, 5);
  drive_cs_hi();

  char input_data_single[1];
  drive_cs_lo();
  spi_rx_bytes(&spi_handle, input_data_single, 1);
  drive_cs_hi();

  char input_data_multi[5];
  drive_cs_lo();
  spi_rx_bytes(&spi_handle, input_data_multi, 5);
  drive_cs_hi();

  return 0;
}
