// Copyright (c) 2015-2020, XMOS Ltd, All rights reserved
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

void app(spi_io_ctx_t *spi_ctx, int mosi_enabled, int miso_enabled) {
    unsigned speed = SPEED;

    for (unsigned cpol=0; cpol<2; cpol++) {
        for (unsigned cpha=0; cpha<2; cpha++) {
            test_transfer8(spi_ctx, setup_strobe_port, setup_data_port, 0, 100,
                    cpol, cpha, speed, mosi_enabled, miso_enabled);
            printf("Transfer8 MODE_%u complete\n", (cpol<<1) | cpha);
        }
    }

    for (unsigned cpol=0; cpol<2; cpol++) {
        for (unsigned cpha=0; cpha<2; cpha++) {
            test_transfer32(spi_ctx, setup_strobe_port, setup_data_port, 0, 100,
                    cpol, cpha, speed, mosi_enabled, miso_enabled);
            printf("Transfer32 MODE_%u complete\n", (cpol<<1) | cpha);
        }
    }

    _Exit(1);
}

#if MOSI_ENABLED
#define MOSI p_mosi
#else
#define MOSI 0
#endif

#if MISO_ENABLED
#define MISO p_miso
#else
#define MISO 0
#endif

#if CB_ENABLED
#define CB cb
#else
#define CB 0
#endif

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
        PJOB(app,(&ctx, MOSI_ENABLED, MISO_ENABLED)),
#if FULL_LOAD == 1
        PJOB(burn,()),
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
