// Copyright (c) 2015-2020, XMOS Ltd, All rights reserved
#include <platform.h>
#include <xclib.h>
#include <stdio.h>
#include <stdlib.h>
#include "spi.h"
#include "spi_sync_tester.h"

in buffered port:32   p_miso  = XS1_PORT_1A;
out port              p_ss[1] = {XS1_PORT_1B};
out buffered port:32  p_sclk  = XS1_PORT_1C;
out buffered port:32  p_mosi  = XS1_PORT_1D;
clock                 cb      = XS1_CLKBLK_1;

out port setup_strobe_port = XS1_PORT_1E;
out port setup_data_port = XS1_PORT_16B;

void app(client interface spi_master_if i, int mosi_enabled, int miso_enabled) {
    unsigned speed = SPEED;

    for(spi_mode_t mode = SPI_MODE_0; mode <= SPI_MODE_3; mode ++){
        test_transfer8(i, setup_strobe_port, setup_data_port, 0, 100,
                mode, speed, mosi_enabled, miso_enabled);
    }
    for(spi_mode_t mode = SPI_MODE_0; mode <= SPI_MODE_3; mode ++){
        test_transfer32(i, setup_strobe_port, setup_data_port, 0, 100,
                mode, speed, mosi_enabled, miso_enabled);
    }
    _Exit(1);
}

#if MOSI_ENABLED
#define MOSI p_mosi
#else
#define MOSI null
#endif

#if MISO_ENABLED
#define MISO p_miso
#else
#define MISO null
#endif

#if CB_ENABLED
#define CB cb
#else
#define CB null
#endif

int main(){
    interface spi_master_if i[1];
    par {
        spi_master(i, 1, p_sclk, MOSI, MISO, p_ss, 1, CB);
        app(i[0], MOSI_ENABLED, MISO_ENABLED);
#if FULL_LOAD == 1
        par {par(int i=0;i<6;i++) while(1);}
#endif
    }
    return 0;
}
