// Copyright 2015-2025 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.
#include <xs1.h>
#include <xclib.h>
#include <stdio.h>
#include <stdlib.h>

#include "spi.h"

#define ASSERTED 1

 [[combinable]]
void spi_slave(client spi_slave_callback_if spi_i,
               in port sclk,
               in buffered port:32 mosi,
               out buffered port:32 ?miso,
               in port ss,
               clock clk,
               static const spi_mode_t mode,
               static const spi_transfer_type_t transfer_type){

    //first setup the ports

    set_port_inv(ss);

    stop_clock(clk);
    set_clock_src(clk, sclk);

    configure_in_port_strobed_slave(mosi, ss, clk);
    if(!isnull(miso)){
        set_port_use_on(miso); // Set to Hi-Z (input) and reset port
        asm volatile ("setc res[%0], %1"::"r"(miso), "r"(XS1_SETC_BUF_BUFFERS)); // Switch to buffered mode
    }
    
    // note do NOT configure MISO yet. We will leave this as an input so Hi-Z

    start_clock(clk);

    switch(mode){
        case SPI_MODE_1:
        case SPI_MODE_2:
            set_port_inv(sclk);
            break;
        case SPI_MODE_0:
        case SPI_MODE_3:
            set_port_no_inv(sclk);
            break;
    }
    sync(sclk);

    int ss_val;
    uint32_t buffer;

    // Wait for de-assert
    ss when pinseq(!ASSERTED) :> ss_val;

    while(1){
        select {
            case ss when pinsneq(ss_val) :> ss_val:{
                if(!isnull(miso)){
                    clearbuf(miso);
                }

                if(ss_val != ASSERTED){
                    // Make MISO go Hi-Z if SS not asserted. It will switch
                    // to output again on the next out or partout
                    if(!isnull(miso)){
                        set_port_use_on(miso); // Set to Hi-Z and reset
                        asm volatile ("setc res[%0], %1"::"r"(miso), "r"(XS1_SETC_BUF_BUFFERS)); // Switch to buffered mode
                    }
                    unsigned remaining_bits = endin(mosi);
                    uint32_t data;
                    // Make MISO go Hi-Z if SS not asserted. It will switch
                    // to output again on the next out or partout
                    mosi :> data;
                    if(remaining_bits){ //FIXME can this be more then tw?
                        data = bitrev(data);
                        if(transfer_type == SPI_TRANSFER_SIZE_8)
                            data >>= (32-8);
                        spi_i.master_supplied_data(data, remaining_bits);
                    }
                    clearbuf(mosi);
                    spi_i.master_ends_transaction();
                break;
                }

                // ss_val == ASSERTED
                if(!isnull(miso)){
                    uint32_t data = spi_i.master_requires_data();
                    // Note port is only configured as buffered input at the moment

                    if(transfer_type == SPI_TRANSFER_SIZE_8){
                        data = (bitrev(data)>>24);
                        // Send data before clock. Use ref clock to allow port to output in absence of SPI clock
                        if((mode == SPI_MODE_0) || (mode == SPI_MODE_2)){
                            asm volatile ("setclk res[%0], %1"::"r"(miso), "r"(XS1_CLKBLK_REF));
                            partout(miso, 1, data);
                            asm volatile ("setclk res[%0], %1"::"r"(miso), "r"(clk));
                            data = data>>1;
                            partout(miso, 7, data);
                        } else {
                            asm volatile ("setclk res[%0], %1"::"r"(miso), "r"(clk)); // Attach to SPI clock
                            partout(miso, 8, data);
                        }
                     } else {
                        data = bitrev(data);
                        // Send data before clock. Use ref clock to allow port to output in absence of SPI clock
                        if((mode == SPI_MODE_0) || (mode == SPI_MODE_2)){
                            asm volatile ("setclk res[%0], %1"::"r"(miso), "r"(XS1_CLKBLK_REF));
                            partout(miso, 1, data);
                            asm volatile ("setclk res[%0], %1"::"r"(miso), "r"(clk));
                            data = data>>1;
                            partout(miso, 31, data);
                        } else {
                            asm volatile ("setclk res[%0], %1"::"r"(miso), "r"(clk)); // Attach to SPI clock
                            miso <: data;
                        }
                    }
                    buffer = spi_i.master_requires_data();

                    if(transfer_type == SPI_TRANSFER_SIZE_8){
                        buffer = (bitrev(buffer)>>24);
                    } else {
                        buffer = bitrev(buffer);
                    }
                } // !isnull(miso)
                clearbuf(mosi);
                if(transfer_type == SPI_TRANSFER_SIZE_8){
                    asm volatile ("settw res[%0], %1"::"r"(mosi), "r"(8)); // Transfer width
                }
                break;
            } // case ss

            case mosi :> int i:{
                if(transfer_type == SPI_TRANSFER_SIZE_8){
                    if(!isnull(miso)){
                        //clearbuf(miso);//FIXME this is not correct - do something better
                        partout(miso, 8, buffer);
                        buffer = spi_i.master_requires_data();
                        buffer = (bitrev(buffer)>>24);
                    }
                    spi_i.master_supplied_data(bitrev(i)>>24, 8);
                } else {
                    if(!isnull(miso)){
                        //clearbuf(miso);//FIXME this is not correct - do something better
                        miso <: buffer;
                        buffer = spi_i.master_requires_data();
                        buffer = bitrev(buffer);
                    }
                    spi_i.master_supplied_data(bitrev(i), 32);
                }
                break;
            } // case mosi

            case spi_i.request_shutdown():{
                set_port_use_on(mosi);
                if (!isnull(miso)) {
                    set_port_use_on(miso);
                }
                set_port_use_on(sclk);
                set_port_use_on(ss);
                set_clock_on(clk);
                spi_i.shutdown_complete();
                return;
                break;
            }
        } // select
    } // while(1)
}
