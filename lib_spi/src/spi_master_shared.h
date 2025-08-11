// Copyright 2025 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.
#include <xs1.h>
#include <xclib.h>
#include <stdlib.h>

#include "spi.h"
extern "C"{
    #include "spi_fwk.h"
}

// Clockblock-less SPI transfer functions. These are slow (max around 1 Mbps) but are suitable for control transfer
// When clockblock resources are scarce
uint8_t transfer8_sync_zero_clkblk(
        out buffered port:32 sclk,
        out buffered port:32 ?mosi,
        in buffered port:32 ?miso,
        uint8_t data, const unsigned period,
        unsigned cpol, unsigned cpha);

uint32_t transfer32_sync_zero_clkblk(
        out buffered port:32 sclk,
        out buffered port:32 ?mosi,
        in buffered port:32 ?miso,
        uint32_t data, const unsigned period,
        const unsigned cpol, const unsigned cpha);

// Optional function to determine the actual set speed for particular clock settings.
unsigned spi_master_get_actual_clock_rate(spi_master_source_clock_t source_clock, unsigned divider);

// Find the best clock divider and source to hit the target rate. Note this will always round down to the next slowest available rate
// effectively using a ceil type function
void spi_master_determine_clock_settings(spi_master_source_clock_t *source_clock, unsigned *divider, unsigned speed_in_khz);