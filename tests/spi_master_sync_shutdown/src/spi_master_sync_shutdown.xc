// Copyright 2025 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.
#include <platform.h>
#include <xclib.h>
#include <stdio.h>
#include <stdlib.h>
#include "spi.h"
#include "spi_sync_tester.h"


in buffered port:32   p_miso  = on tile[0]: XS1_PORT_1A;
out port              p_ss    = on tile[0]: XS1_PORT_1B;
out buffered port:32  p_sclk  = on tile[0]: XS1_PORT_1C;
out buffered port:32  p_mosi  = on tile[0]: XS1_PORT_1D;
clock                 cb      = on tile[0]: XS1_CLKBLK_1;

out port setup_strobe_port = on tile[0]: XS1_PORT_1E;
out port setup_data_port = on tile[0]: XS1_PORT_16B;

#define SPI_MODE SPI_MODE_0
#define SPI_KBPS 1000


// We can only distribute if the main par is a flat list of tasks, not a loop
// However a clean exit should result in no exception
#if DISTRIBUTED
#define LOOPS   1
#else
#define LOOPS   5
#endif

void app(client interface spi_master_if i, int mosi_enabled, int miso_enabled, int spi_mode){
    for(int loop = 0; loop < LOOPS; loop++){
        test_transfer8(i, setup_strobe_port, setup_data_port, 0, 100,
                spi_mode, SPI_KBPS, mosi_enabled, miso_enabled);

        test_transfer32(i, setup_strobe_port, setup_data_port, 0, 100,
                spi_mode, SPI_KBPS, mosi_enabled, miso_enabled);

        i.shutdown();
    }

    printf("Transfers complete\n");

    // Should exit normally, no need for forced exit
}

int main(){
    interface spi_master_if i[1];
    par {
#if DISTRIBUTED
        par 
        {
    #if CB_ENABLED
            [[distribute]]
            spi_master(i, 1, p_sclk, p_mosi, p_miso, p_ss, 1, cb);
    #else
            [[distribute]]
            spi_master(i, 1, p_sclk, p_mosi, p_miso, p_ss, 1, null);
    #endif
            app(i[0], 1, 1, SPI_MODE);
        }
#else // NOT distributed - uses own thread
        par 
        {
            on tile[0]: {
    #if CB_ENABLED
                for(int loop = 0; loop < LOOPS; loop++){spi_master(i, 1, p_sclk, p_mosi, p_miso, p_ss, 1, cb);}
    #else
                for(int loop = 0; loop < LOOPS; loop++){spi_master(i, 1, p_sclk, p_mosi, p_miso, p_ss, 1, null);}
    #endif
            }
            on tile[0]: app(i[0], 1, 1, SPI_MODE);
        }
#endif // NOT distributed
    }
    return 0;
}
