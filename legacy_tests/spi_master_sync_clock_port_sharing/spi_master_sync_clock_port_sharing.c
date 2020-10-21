// Copyright (c) 2020, XMOS Ltd, All rights reserved
#include <platform.h>
#include <xclib.h>
#include <stdio.h>
#include <stdlib.h>
#include <xcore/clock.h>
#include <xcore/port.h>
#include <xcore/parallel.h>
#include "spi_io.h"
#include "spi_sync_tester.h"

port_t p_miso = XS1_PORT_1A;
port_t p_ss[1] = {XS1_PORT_1B};
port_t p_sclk = XS1_PORT_1C;
port_t p_mosi = XS1_PORT_1D;
xclock_t cb = XS1_CLKBLK_1;

port_t setup_strobe_port = XS1_PORT_1E;
port_t setup_data_port = XS1_PORT_16B;

void app(spi_io_ctx_t *spi_ctx, int mosi_enabled, int miso_enabled){
    int count = 0;

    while (1) {
        unsigned inter_frame_gap = 1000;
        unsigned cpol = 0;;
        unsigned cpha = 0;
        unsigned device_id = 0;
        unsigned speed_in_kbps = 500;

        // do a test transfer
        int ret = test_transfer8(spi_ctx, setup_strobe_port, setup_data_port, device_id,
                                 inter_frame_gap, cpol, cpha, speed_in_kbps,
                                 mosi_enabled, miso_enabled);
        if (ret != 0)
            printf("Error %d in round %d\n", ret, count);

        // now do something to the clock port
        {   unsigned sclk;
            asm volatile("ldw %0, dp[p_sclk]" : "=r"(sclk));
            asm volatile("setclk res[%0], %1" :: "r"(sclk), "r"(XS1_CLKBLK_REF));
        }

        count++;
        if (count == 8) {
            _Exit(0);
        }
    }
}

DECLARE_JOB(timebomb, (void));

void timebomb(void) {
    hwtimer_t tmr = hwtimer_alloc();
    unsigned t = hwtimer_get_time(tmr);
    (void) hwtimer_wait_until(t + 10000000);
    printf("Timeout!\n");
    _Exit(1);
}

int main() {
    spi_io_ctx_t spi_ctx = {
            .clock_block = CB,
            .cs_port = p_ss[0],
            .sclk_port = p_sclk,
            .mosi_port = MOSI,
            .miso_port = MISO,
            .clk_divisor = 1, /* 100 / (2 * 2) = 25 MHz */
            .sclk_sample_delay = 0,
            .sclk_sample_edge = spi_io_sample_edge_falling,
            .miso_pad_delay = 0,
    };

    port_enable(setup_strobe_port);
    port_enable(setup_data_port);

    /* These might not be needed with new api */
    // port_start_buffered(p_miso, 32);
    // port_enable(p_ss[0]);
    // port_start_buffered(p_sclk, 32);
    // port_start_buffered(p_mosi, 32);
    // clock_enable(cb);

    spi_io_init(&spi_ctx, spi_io_source_clock_ref);

    PAR_JOBS(
        PJOB(timebomb,()),
        PJOB(app,(&ctx, MOSI_ENABLED, MISO_ENABLED)),
#if FULL_LOAD == 1
        PJOB(burn,()),
        PJOB(burn,()),
        PJOB(burn,()),
        PJOB(burn,()),
        PJOB(burn,()),
        PJOB(burn,())
#endif
    );
    return 0;
}
