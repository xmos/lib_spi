// Copyright (c) 2017-2018, XMOS Ltd, All rights reserved

//In this example we are going to connect to the quad spi flash part on the
//XCORE-200-EXPLORER board at 25MHz, erase it, write some data to it and finally
//read the data back from flash in quad spi mode before disconnecting from flash.

#include <print.h>
#include <xclib.h>

#include "xmos_spi.h"

//We need to initialise our qspi ports out in a c file because XC does not
//support designated union initialisation.
extern spi_ports_t qspi_ports;

int main()
{
  char data[1] = {0xAB};
  spi_tx_bytes(&qspi_ports, spi_mode_0, data, 1);
  return 0;
}
