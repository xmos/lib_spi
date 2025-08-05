// Copyright 2015-2025 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.
#include <platform.h>
#include <xclib.h>
#include <stdio.h>
#include <stdlib.h>
#include "spi.h"
#include "common.h"

out buffered port:32    p_miso = XS1_PORT_1A;
in port                 p_ss   = XS1_PORT_1B;
in port                 p_sclk = XS1_PORT_1C;
in buffered port:32     p_mosi = XS1_PORT_1D;
clock                   cb     = XS1_CLKBLK_1;

out port setup_strobe_port = XS1_PORT_1E;
out port setup_data_port = XS1_PORT_16B;
in port setup_resp_port = XS1_PORT_1F;

#define KBPS 1000


#if (TRANSFER_SIZE == SPI_TRANSFER_SIZE_8)
#define BITS_PER_TRANSFER 8
#elif (TRANSFER_SIZE == SPI_TRANSFER_SIZE_32)
#define BITS_PER_TRANSFER 32
#else
#error Invalid transfer size given
#endif


// This sends 128b transfer then steps through from 1b to SPI_TRANSFER_SIZE bits and exits

[[combinable]]
void app(server interface spi_slave_callback_if spi_i,
        int mosi_enabled, int miso_enabled){

    unsigned bpt = 0;
    spi_transfer_type_t tt = TRANSFER_SIZE;
    switch(tt){
    case SPI_TRANSFER_SIZE_8:bpt = 8;break;
    case SPI_TRANSFER_SIZE_32:bpt = 32;break;
    }


    unsigned num_bits = NUMBER_OF_TEST_BYTES*8;

    //First check a multi byte transfer
    printf("Send initial settings\n");
    // printf("%u\n", num_bits);

    broadcast_settings(setup_strobe_port, setup_data_port,
            SPI_MODE, mosi_enabled, miso_enabled, num_bits, KBPS, 2000);

    unsigned rx_byte_no = 0;
    unsigned tx_byte_no = 0;
    while(1){
        select {
            case spi_i.master_requires_data() -> uint32_t r:{
                // printf("master_requires_data\n");
                if(tx_byte_no < NUMBER_OF_TEST_BYTES){
                    switch(tt){
                    case SPI_TRANSFER_SIZE_8:
                        r = tx_data[tx_byte_no];
                        tx_byte_no++;
                        break;
                    case SPI_TRANSFER_SIZE_32:
                        r =   (tx_data[tx_byte_no+3]<<0)
                            | (tx_data[tx_byte_no+2]<<8)
                            | (tx_data[tx_byte_no+1]<<16)
                            | (tx_data[tx_byte_no+0]<<24);
                        tx_byte_no+=4;
                        break;
                    }
                }
                if(!miso_enabled){
                    printf("Error: master cannot require data when miso is not enabled\n");
                    flush_print();
                    _Exit(1);
                }
                break;
            }
            case spi_i.master_supplied_data(uint32_t datum, uint32_t valid_bits):{
                // printf("master_supplied_data\n");
                for(unsigned i=0; i<valid_bits/8;i++){
                    uint8_t d = (datum >> (valid_bits - 8))&0xff;
                    if(rx_data[rx_byte_no] != d){
                        printf("Error: Expected %02x from master but got %02x for transfer of %d\n",
                                rx_data[rx_byte_no], d, num_bits);
                        flush_print();
                        _Exit(1);
                    }
                    rx_byte_no++;
                    datum <<= 8;
                }

                if(valid_bits < 8){
                    datum <<= (8-valid_bits);
                } else
                    datum >>= (valid_bits-8);
                datum &= 0xff;

                if(valid_bits&0x7){
                    uint32_t d =(rx_data[rx_byte_no]>>(8-(valid_bits&0x7)))<<(8-(valid_bits&0x7));
                    if(datum != d){
                        printf("Error: Expected %02x from master but got %02x for transfer of %d\n",
                                d, datum, num_bits);
                        flush_print();
                        _Exit(1);
                    }
                }
                break;
            }

            case spi_i.master_ends_transaction():{
                // printf("master_ends_transaction\n");
                //Then check all sub word transfers
                if(num_bits == NUMBER_OF_TEST_BYTES*8){
                    num_bits = 0;
                }
                if(num_bits == bpt){
                    printf("Test completed\n");
                    flush_print();
                    _Exit(0);
                }
                num_bits++;

                int r = request_response(setup_strobe_port, setup_resp_port);

                if(r){
                    printf("Error: Master Rx error\n");
                    flush_print();
                    _Exit(1);
                }
                if(num_bits > bpt){
                    printf("Error: Too many bits %d expecting %d\n", num_bits, bpt);
                    flush_print();
                    _Exit(1);
                }


                broadcast_settings(setup_strobe_port, setup_data_port,
                        SPI_MODE, mosi_enabled, miso_enabled, num_bits, KBPS, 2000);
                rx_byte_no = 0;
                tx_byte_no = 0;
                break;
            }
        }
    }
}

static void load(static const unsigned num_threads){
    switch(num_threads){
    case 3: par {par(int i=0;i<3;i++) while(1);}break;
    case 6: par {par(int i=0;i<6;i++) while(1);}break;
    case 7: par {par(int i=0;i<7;i++) while(1);}break;
    }
}
#define MOSI_ENABLED 1

#if MISO_ENABLED
#define MISO p_miso
#else
#define MISO null
#endif

int main(){
    interface spi_slave_callback_if i;
    par {
#if COMBINED == 1
        [[combine]]
        par {
            spi_slave(i, p_sclk, p_mosi, MISO, p_ss, cb, SPI_MODE, TRANSFER_SIZE);
            app(i, MOSI_ENABLED, MISO_ENABLED);
        }
#else
        spi_slave(i, p_sclk, p_mosi, MISO, p_ss, cb, SPI_MODE, TRANSFER_SIZE);
        app(i, MOSI_ENABLED, MISO_ENABLED);
#endif
        load(BURNT_THREADS);
    }
    return 0;
}
