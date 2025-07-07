// Copyright 2015-2025 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.
#include <xs1.h>
#include <xclib.h>
#include <print.h>
#include <stdlib.h>

#include "spi.h"
extern "C"{
    #include "spi_fwk.h"
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
                accepting_new_transactions = 0;

                unsigned div = (XS1_TIMER_KHZ + 4*speed_in_khz - 1)/(4*speed_in_khz);
                unsigned cpol = mode >> 1;
                unsigned cpha = mode & 0x1;
                spi_master_device_init(&spi_dev, &spi_ctx,
                    ss_port_bit[x],
                    cpol, cpha,
                    spi_master_source_clock_ref,
                    div,
                    spi_master_sample_delay_0,
                    0, 0 ,0 ,0 );
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

