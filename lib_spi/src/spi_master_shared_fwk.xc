// Copyright 2025 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.
#include <xs1.h>
#include <xclib.h>
#include <stdlib.h>

//TODO DEL these
#include <stdio.h>
#include <print.h>
#include <platform.h>

#include "spi.h"
extern "C"{
    #include "spi_fwk.h"
}


// Optional function to determine the actual set speed for particular clock settings.
unsigned spi_master_get_actual_clock_rate(spi_master_source_clock_t source_clock, unsigned divider){
    unsigned actual_speed_khz = ((source_clock == spi_master_source_clock_ref) ? PLATFORM_REFERENCE_MHZ : PLATFORM_NODE_0_SYSTEM_FREQUENCY_MHZ) * 1000 
                                / 2
                                / (divider == 0 ? 1 : ((divider) * 2));

    return actual_speed_khz;
}


// Find the best clock divider and source to hit the target rate. Note this will always round down to the next slowest available rate
// effectively using a ceil type function
void spi_master_determine_clock_settings(spi_master_source_clock_t *source_clock, unsigned *divider, unsigned speed_in_khz){
    // Clock blocks divide at / (2 * div) for div > 0 or / 1 where div == 0. Maximum clock block division is 255 * 2 = 510
    // Due to SPI needing to output each bit twice (to allow control over clock edges) the overal SPI clock rate is / 2 further
    // to the divider.
    // Steps get very granular as div -> 1 so use ref clock below 2MHz and core clock above 2MHz
    // The minimum SPI clock speed is therefore 100e6 / (255 * 2 * 2) = 98kHz on the ref clock
    // The minimum SPI clock speed at 800MHz core clock (typical highest) is 800e6 / (255 * 2 * 2) = 784kHz
    if(speed_in_khz > 2000){
        *source_clock = spi_master_source_clock_xcore;
        *divider = (PLATFORM_NODE_0_SYSTEM_FREQUENCY_MHZ * 1000 + 4 * speed_in_khz - 1)/(4 * speed_in_khz);
    } else {
        *source_clock = spi_master_source_clock_ref;
        *divider = (PLATFORM_REFERENCE_MHZ * 1000 + 4 * speed_in_khz - 1)/(4 * speed_in_khz);
    }

    // Avoid overflow of the 8b divider reg.
    if(*divider > 255){
        *divider = 255;
    }
}
