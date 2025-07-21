// Copyright 2025 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.
#include <platform.h>
#include <xclib.h>
#include <stdio.h>
#include <stdlib.h>
#include "spi.h"
#include "spi_sync_tester.h"

in buffered port:32   p_miso  = XS1_PORT_1A;
out port              p_ss    = XS1_PORT_1B;
out buffered port:32  p_sclk  = XS1_PORT_1C;
out buffered port:32  p_mosi  = XS1_PORT_1D;
clock                 cb      = XS1_CLKBLK_1;

out port setup_strobe_port = XS1_PORT_1E;
out port setup_data_port = XS1_PORT_16B;

#define SPI_MODE SPI_MODE_0
#define SPI_KBPS 10000

void app(client interface spi_master_if i, int mosi_enabled, int miso_enabled, int spi_mode){
    for(int loop = 0; loop < 10; loop++){
        test_transfer8(i, setup_strobe_port, setup_data_port, 0, 100,
                spi_mode, SPI_KBPS, mosi_enabled, miso_enabled);

        i.shutdown();

        test_transfer32(i, setup_strobe_port, setup_data_port, 0, 100,
                spi_mode, SPI_KBPS, mosi_enabled, miso_enabled);

        i.shutdown();
    }

    printf("Transfers complete\n");
    _Exit(0);
}


int main(){
    interface spi_master_if i[1];
    par {
        {
            while(1){
                spi_master_fwk(i, 1, p_sclk, p_mosi, p_miso, p_ss, 1, cb);
            }
        }
        app(i[0], 1, 1, SPI_MODE);
    }
    return 0;
}
