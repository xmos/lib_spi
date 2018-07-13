// Copyright (c) 2017-2018, XMOS Ltd, All rights reserved

#include "xmos_spi.h"

//I've had to initialise my spi_ports_t out here as XC does not support
//designated union initialisation even though our C does.
spi_ports_t qspi_ports = {
                            {
                              .qspi_ports_impl = {
                                XS1_PORT_1B,
                                XS1_PORT_1C,
                                XS1_PORT_4B
                              }
                            },
                            qspi_ports_impl,
                            XS1_CLKBLK_5
                          };
