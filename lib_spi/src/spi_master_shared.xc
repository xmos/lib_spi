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


#pragma unsafe arrays
uint8_t transfer8_sync_zero_clkblk(
        out buffered port:32 sclk,
        out buffered port:32 ?mosi,
        in buffered port:32 ?miso,
        uint8_t data, const unsigned period,
        unsigned cpol, unsigned cpha){
    unsigned time, d, c = 0xaaaa>>(cpol ^ cpha);
    time = partout_timestamped(sclk, 1, cpol);
    time += 40;

    for(unsigned i=0;i<8;i++){
        partout_timed(sclk, 1, c, time);
        c>>=1;
        //sclk @ time <:>> c;

        if(!isnull(mosi)){
            partout_timed(mosi, 1, data>>7, time);
            data<<=1;
        }
        time += period / 2;

        partout_timed(sclk, 1, c, time);
        c>>=1;
        if(!isnull(miso)){
            unsigned t;
            miso @ time - 1 :> t;
            d = (d<<1) + (t&1);
        }
        time += (period + 1)/2;
    }
    partout_timed(sclk, 1, cpol, time);
    sync(sclk);
    return d;
}

#pragma unsafe arrays
uint32_t transfer32_sync_zero_clkblk(
        out buffered port:32 sclk,
        out buffered port:32 ?mosi,
        in buffered port:32 ?miso,
        uint32_t data, const unsigned period,
        const unsigned cpol, const unsigned cpha){
    unsigned time;
    uint32_t d;
    time = partout_timestamped(sclk, 1, cpol);
    time += 100;

    //bitrev the data
    for(unsigned j=0;j<2;j++){
        unsigned c = 0xaaaaaaaa>>(cpol ^ cpha);
        for(unsigned i=0;i<16;i++){
          partout_timed(sclk, 1, c, time);
          if(!isnull(mosi)){
              partout_timed(mosi, 1, data>>31, time);
              data<<=1;
          }
          c>>=1;
          time += period / 2;
          partout_timed(sclk, 1, c, time);
          c>>=1;
          if(!isnull(miso)){
              unsigned t;
              miso @ time - 1 :> t;
              d = (d<<1) + (t&1);
          }
          time += (period + 1)/2;
        }
        time += 80;
    }
    partout_timed(sclk, 1, cpol, time);
    sync(sclk);
    return d;
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
