// Copyright 2015-2025 XMOS LIMITED.
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

#pragma unsafe arrays
[[distributable]]
void spi_master_fwk(server interface spi_master_if i[num_clients],
        static const size_t num_clients,
        out buffered port:32 sclk,
        out buffered port:32 ?mosi,
        in buffered port:32 ?miso,
        out port p_ss, // Note only one SS port supported - individual bits in port may be used however
        static const size_t num_slaves,
        clock ?cb){

    if(isnull(cb)){
        printstrln("Must supply clockblock to this version of SPI");
        // We will hit an exception shortly after this if NULL
    }

    spi_master_t spi_ctx;
    spi_master_device_t spi_dev;
    unsafe{
        spi_master_init(&spi_ctx, cb, (port)p_ss, (port)sclk, (port)mosi, (port)miso);
    }

    int accepting_new_transactions = 1;
    unsigned ss_port_bit[num_clients] = {0};

    while(1){
        select {
            case accepting_new_transactions => i[int x].begin_transaction(unsigned device_index,
                unsigned speed_in_khz, spi_mode_t mode):{
                // printf("begin_transaction: client %d\n", x);
                accepting_new_transactions = 0;

                spi_master_source_clock_t source_clock;
                unsigned divider;
                spi_master_determine_clock_settings(&source_clock, &divider, speed_in_khz);

                // unsigned actual_speed_khz = spi_master_get_actual_clock_rate(source_clock, divider);
                // printf("Actual speed_in_khz: %u div(%u) clock: %s (%u)MHz\n",
                //     actual_speed_khz,
                //     divider,
                //     ((source_clock == spi_master_source_clock_ref) ? "ref" : "core"),
                //     ((source_clock == spi_master_source_clock_ref) ? PLATFORM_REFERENCE_MHZ : PLATFORM_NODE_0_SYSTEM_FREQUENCY_MHZ));

                unsigned cpol = mode >> 1;
                unsigned cpha = mode & 0x1;
                spi_master_device_init(&spi_dev, &spi_ctx,
                    ss_port_bit[x],
                    cpol, cpha,
                    source_clock,
                    divider,
                    spi_master_sample_delay_0,
                    0, 0 ,0 ,0 );

                spi_ctx.current_device = 0xffffffff;// This is needed to force mode and speed in spi_master_start_transaction()
                                                    // Otherwise fwk_spi sees the next transaction as the same settings as last
                spi_master_start_transaction(&spi_dev);
                break;
            }

            case i[int x].end_transaction(unsigned ss_deassert_time):{
                spi_master_end_transaction(&spi_dev);
                // Unlock the transaction
                accepting_new_transactions = 1;
                break;
            }

            case i[int x].transfer8(uint8_t data)-> uint8_t r :{
                spi_master_transfer(&spi_dev, (uint8_t *)&data, (uint8_t *)&r, 1);
                break;
            }

            case i[int x].transfer32(uint32_t data) -> uint32_t r:{
                uint32_t read_val;
                data = byterev(data);
                spi_master_transfer(&spi_dev, (uint8_t *)&data, (uint8_t *)&read_val, 4);
                r = byterev(read_val);
                break;
            }

            case i[int x].set_ss_port_bit(unsigned port_bit):{
                ss_port_bit[x] = port_bit;
                break;
            }
        }
    }

}

