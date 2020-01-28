// Copyright (c) 2020, XMOS Ltd, All rights reserved
#include <platform.h>
#include <xclib.h>
#include <stdio.h>
#include <stdlib.h>
#include <print.h>
#include "spi.h"
#include "spi_sync_tester.h"

in buffered port:32    p_miso   = XS1_PORT_1A;
out port               p_ss[1]  = {XS1_PORT_1B};
out buffered port:32   p_sclk   = XS1_PORT_1C;
out buffered port:32   p_mosi   = XS1_PORT_1D;
clock                  cb       = XS1_CLKBLK_1;

out port setup_strobe_port = XS1_PORT_1E;
out port setup_data_port = XS1_PORT_16B;

[[combinable]]
void app(client interface spi_master_if spi_i, int mosi_enabled, int miso_enabled){
    int count = 0;
    timer always;
    int start;
    always :> start;

    while (1) {
        select {
            case always when timerafter(start) :> void:
                unsigned inter_frame_gap = 1000;
                unsigned device_id = 0;
                spi_mode_t mode = SPI_MODE_0;
                unsigned speed_in_kbps = 500;

                // do a test transfer
                int ret = test_transfer8(spi_i, setup_strobe_port, setup_data_port, device_id,
                                         inter_frame_gap, mode, speed_in_kbps,
                                         mosi_enabled, miso_enabled);
                if (ret != 0)
                    printf("Error %d in round %d\n", ret, count);

                // now do something to the clock port
                {   unsigned sclk;
                    asm volatile("ldw %0, dp[p_sclk]" : "=r"(sclk));
                    asm volatile("setclk res[%0], %1" :: "r"(sclk), "r"(XS1_CLKBLK_REF));
                }

                count++;
                if (count == 8)
                    _Exit(0);

                break;
        }
    }
}

void timebomb(){
    timer tmr;
    int t;
    tmr :> t;
    tmr when timerafter(t + 10000000) :> void;
    printf("Timeout!\n");
    _Exit(1);
}

int main(){
    par {
        timebomb();
        {   interface spi_master_if i[1];
#if COMBINED == 1
            [[combine]]
#endif
            par {
                app(i[0], 1, 1);
                spi_master(i, 1, p_sclk, p_mosi, p_miso, p_ss, 1, cb);
            }
        }
    }
    return 0;
}
