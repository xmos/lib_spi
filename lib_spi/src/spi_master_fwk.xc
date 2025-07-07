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
        out port p_ss[num_slaves],
        static const size_t num_slaves,
        clock ?cb){


    // Declare the fwk_io_master
    // MODE == 1 fixed for now
    #define CPOL 0
    #define CPHA 1
    #define DIV 50

    if(isnull(cb)){
        printstrln("Must supply clockblock");
    }
 
    spi_master_t spi_ctx;
    spi_master_device_t spi_dev;
    unsafe{
        spi_master_device_init(&spi_dev, &spi_ctx,
            0, // cs pin in port
            CPOL, CPHA,
            spi_master_source_clock_xcore,
            DIV,
            spi_master_sample_delay_0,
            0, 0 ,0 ,0 );
        spi_master_init(&spi_ctx, cb, (port)p_ss[0], (port)sclk, (port)mosi, (port)miso);
    }


    int accepting_new_transactions = 1;

    while(1){
        select {
            case accepting_new_transactions => i[int x].begin_transaction(unsigned device_index,
                unsigned speed_in_khz, spi_mode_t mode):{
                accepting_new_transactions = 0;
                spi_master_start_transaction(&spi_dev);
                break;
            }
            case i[int x].end_transaction(unsigned ss_deassert_time):{
                //Unlock the transaction
                accepting_new_transactions = 1;
                spi_master_end_transaction(&spi_dev);
                break;
            }
            case i[int x].transfer8(uint8_t data)-> uint8_t r :{
                printstrln("transfer8");
                printhexln((int)&data);
                printhexln((int)&r);
                spi_master_transfer(&spi_dev, (uint8_t *)&data, (uint8_t *)&r, 1);
                printstrln("transfer8");
                break;
            }
            case i[int x].transfer32(uint32_t data) -> uint32_t r:{
                printstrln("transfer32");
                spi_master_transfer(&spi_dev, (uint8_t *)&data, (uint8_t *)&r, 4);
                printstrln("transfer32");
                break;
            }
        }
    }

}

