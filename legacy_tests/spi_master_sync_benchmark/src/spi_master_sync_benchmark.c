// Copyright (c) 2015-2020, XMOS Ltd, All rights reserved
#include <platform.h>
#include <xclib.h>
#include <stdio.h>
#include <stdlib.h>
#include <xcore/clock.h>
#include <xcore/hwtimer.h>
#include <xcore/port.h>
#include <xcore/parallel.h>
#include "spi_io.h"

port_t p_miso = XS1_PORT_1A;
port_t p_ss[1] = {XS1_PORT_1B};
port_t p_sclk = XS1_PORT_1C;
port_t p_mosi = XS1_PORT_1D;
xclock_t cb = XS1_CLKBLK_1;

static uint32_t get_max_byte_speed(spi_io_ctx_t *spi_ctx){
    uint32_t now, then;
    uint8_t tx[1] = {0xff};
    uint8_t rx[1] = {0};
    hwtimer_t tmr = hwtimer_alloc();

    then = hwtimer_get_time(tmr);

    spi_io_start_transaction(spi_ctx, 100, 1, 1);
    spi_io_transfer_bytes(spi_ctx, tx, rx);
    spi_io_end_transaction(spi_ctx, 100);

    now = hwtimer_get_time(tmr);

    uint32_t best_time_so_far = now-then;
    uint32_t min = 0000, max = 6000;
    while(1) {
        uint32_t test_speed = min + (max-min)/32;

        then = hwtimer_get_time(tmr);

        spi_io_start_transaction(spi_ctx, test_speed, 1, 1);
        spi_io_transfer_bytes(spi_ctx, tx, rx);
        spi_io_end_transaction(spi_ctx, 100);

        now = hwtimer_get_time(tmr);

        uint32_t diff = now - then;
        if (diff < best_time_so_far){
            best_time_so_far = diff;
            min = test_speed;
        } else {
            if (max == test_speed) {
                break;
            }
            max = test_speed;
        }
    }
    hwtimer_free(tmr);
    return test_speed;
}

static uint32_t get_max_word_speed(spi_io_ctx_t *spi_ctx){
    uint32_t now, then;
    uint32_t tx[1] = {0xffff};
    uint32_t rx[1] = {0};
    hwtimer_t tmr = hwtimer_alloc();

    then = hwtimer_get_time(tmr);
    {
        spi_io_start_transaction(spi_ctx, 100, 1, 1);
        spi_io_transfer_32(spi_ctx, tx, rx);
        spi_io_end_transaction(spi_ctx, 100);
    }
    now = hwtimer_get_time(tmr);

    uint32_t best_time_so_far = now-then;
    uint32_t min = 0000, max = 6000;
    while(1){
        uint32_t test_speed = min + (max-min)/32;

        then = hwtimer_get_time(tmr);
        {
            spi_io_start_transaction(spi_ctx, test_speed, 1, 1);
            spi_io_transfer_32(spi_ctx, tx, rx);
            spi_io_end_transaction(spi_ctx, 100);
        }
        now = hwtimer_get_time(tmr);

        uint32_t diff = now - then;
        if (diff < best_time_so_far){
            best_time_so_far = diff;
            min = test_speed;
        } else {
            if (max == test_speed) {
                break;
            }
            max = test_speed;
        }
    }
    hwtimer_free(tmr);
    return test_speed;
}

void app(spi_io_ctx_t *spi_ctx){
    printf("Best byte speed: %d kbps\n", get_max_byte_speed(spi_ctx, 0));
    printf("Best word speed: %d kbps\n", get_max_word_speed(spi_ctx, 1));
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

int main(){
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

    spi_io_init(&spi_ctx, spi_io_source_clock_ref);

    PAR_JOBS(
        PJOB(app,(&ctx)),
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
