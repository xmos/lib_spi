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
#include "spi_master_shared_fwk.h"

#define SPI_MAX_DEVICES 32 //Used to size the array of which bit in the SS port maps to which device


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
        // We will hit an exception shortly after this if cb is NULL
    }

    spi_master_t spi_master;
    spi_master_device_t spi_dev;
    unsafe{
        spi_master_init(&spi_master, cb, (port)p_ss, (port)sclk, (port)mosi, (port)miso);
    }

    int accepting_new_transactions = 1;

    // By default use the port bit which is the number of the client (client 0 uses port bit 0 etc.)
    uint8_t ss_port_bit[SPI_MAX_DEVICES];
    for(int i = 0; i < SPI_MAX_DEVICES; i++){
        ss_port_bit[i] = i;
    }

    while(1){
        select {
            case accepting_new_transactions => i[int x].begin_transaction(unsigned device_index,
                unsigned speed_in_khz, spi_mode_t mode):{
                accepting_new_transactions = 0;

                spi_master_source_clock_t source_clock;
                unsigned divider;
                spi_master_determine_clock_settings(&source_clock, &divider, speed_in_khz);

                // unsigned actual_speed_khz = spi_master_get_actual_clock_rate(source_clock, divider);
                // printf("Actual speed_in_khz: %u div(%u) clock: (%s) %uMHz\n",
                //     actual_speed_khz,
                //     divider,
                //     ((source_clock == spi_master_source_clock_ref) ? "ref" : "core"),
                //     ((source_clock == spi_master_source_clock_ref) ? PLATFORM_REFERENCE_MHZ : PLATFORM_NODE_0_SYSTEM_FREQUENCY_MHZ));

                unsigned cpol = mode >> 1;
                unsigned cpha = mode & 0x1;
                spi_master_device_init(&spi_dev, &spi_master,
                    ss_port_bit[device_index],
                    cpol, cpha,
                    source_clock,
                    divider,
                    spi_master_sample_delay_0,
                    0, 0 ,0 ,0 );

                spi_master.current_device = 0xffffffff; // This is needed to force mode and speed in spi_master_start_transaction()
                                                        // Otherwise fwk_spi sees the next transaction on the existing device as the same settings as last on the same client
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
                spi_master_transfer(&spi_dev, (uint8_t *)&data, &r, 1);
                break;
            }

            case i[int x].transfer32(uint32_t data) -> uint32_t r:{
                uint32_t read_val;
                // For 32b words, we need to swap to big endian (standard for SPI) from little endian (XMOS)
                // This means we transmit the MSByte first
                data = byterev(data);
                spi_master_transfer(&spi_dev, (uint8_t *)&data, (uint8_t *)&read_val, 4);
                r = byterev(read_val);
                break;
            }

            case i[int x].set_ss_port_bit(unsigned port_bit):{
                if(port_bit > SPI_MAX_DEVICES){
                    printstrln("Invalid port bit - must be less than SPI_MAX_DEVICES");
                }
                ss_port_bit[x] = port_bit;
                break;
            }

            case i[int x].shutdown(void):{
                // We don't use spi_master_deinit(&spi_master);  This completely turns off resources.
                p_ss <: 0xffffffff;

                // If using XC, then we need to enable/init which is how XC does it
                if (!isnull(mosi)) {
                    set_port_use_on(mosi);
                }
                set_port_use_on(miso);
                set_port_use_on(sclk);
                set_clock_on(cb);
                
                return;
            }
        }
    }

}

