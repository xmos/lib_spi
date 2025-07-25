// Copyright 2015-2025 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.
#include <platform.h>
#include <xclib.h>
#include <stdio.h>
#include <stdlib.h>
#include "spi.h"
#include "spi_sync_tester.h"
extern "C"{
    #include "../src/spi_fwk.h"
}

// access internal functions
extern void spi_master_determine_clock_settings(spi_master_source_clock_t *source_clock, unsigned *divider, unsigned speed_in_khz);
extern unsigned spi_master_get_actual_clock_rate(spi_master_source_clock_t source_clock, unsigned divider);



in buffered port:32   p_miso  = XS1_PORT_1A;
out port              p_ss    = XS1_PORT_1B;
out buffered port:32  p_sclk  = XS1_PORT_1C;
out buffered port:32  p_mosi  = XS1_PORT_1D;
clock                 cb      = XS1_CLKBLK_1;

out port setup_strobe_port = XS1_PORT_1E;
out port setup_data_port = XS1_PORT_16B;


static unsigned get_max_speed(unsigned transfer_width, client interface spi_master_if i){
    unsigned min_test_speed = 1000, max_test_speed = 150000;//kbps
    unsigned iteration = 0;
    unsigned test_speed = min_test_speed;
    while(1){
        // Make sure we set the actual speed attainable
        spi_master_source_clock_t source_clock;
        unsigned divider;
        spi_master_determine_clock_settings(&source_clock, &divider, test_speed);
        unsigned actual_test_speed = spi_master_get_actual_clock_rate(source_clock, divider);

        printf("testing:%u:%u:", transfer_width, actual_test_speed);
        int error = 0;
        if(transfer_width == 8){
            error = test_transfer8(i, setup_strobe_port, setup_data_port, 0, 100,
                                    SPI_MODE, actual_test_speed, MOSI_ENABLED, MISO_ENABLED);
        } else {
            error = test_transfer32(i, setup_strobe_port, setup_data_port, 0, 100,
                                        SPI_MODE, actual_test_speed, MOSI_ENABLED, MISO_ENABLED);
        }



        if(error){
            printf("FAIL\n");
            test_speed = (test_speed + min_test_speed) / 2;

        } else {
            printf("PASS\n");
            test_speed = (test_speed + max_test_speed) / 2;
        }
        if(iteration++ == 7) return 0; // 7 always gets us there
    }
    return 0;
}

void app(client interface spi_master_if i, int mosi_enabled, int miso_enabled){
    printf("%d\n", get_max_speed(8, i));
    printf("%d\n", get_max_speed(32, i));
    _Exit(1);
}

static void load(static const unsigned num_threads){
    switch(num_threads){
    case 3: par {par(int i=0;i<3;i++) while(1);}break;
    case 4: par {par(int i=0;i<4;i++) while(1);}break;
    case 5: par {par(int i=0;i<5;i++) while(1);}break;
    case 6: par {par(int i=0;i<6;i++) while(1);}break;
    case 7: par {par(int i=0;i<7;i++) while(1);}break;
    }
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

int main(){
    interface spi_master_if i[1];
    par {
        spi_master(i, 1, p_sclk, MOSI, MISO, p_ss, 1, cb);
        app(i[0], MOSI_ENABLED, MISO_ENABLED);
        load(BURNT_THREADS);
    }
    return 0;
}
