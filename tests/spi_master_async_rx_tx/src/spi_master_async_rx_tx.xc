// Copyright 2015-2025 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.
#include <platform.h>
#include <xclib.h>
#include <stdio.h>
#include <stdlib.h>
#include "spi.h"
#include "spi_async_tester.h"

in buffered port:32    p_miso   = XS1_PORT_1A;
out port               p_ss[1]  = {XS1_PORT_1B};
out buffered port:32   p_sclk   = XS1_PORT_1C;
out buffered port:32   p_mosi   = XS1_PORT_1D;
clock                  cb0      = XS1_CLKBLK_1;
clock                  cb1      = XS1_CLKBLK_2;

out port setup_strobe_port = XS1_PORT_1E;
out port setup_data_port = XS1_PORT_16B;

typedef enum {
    SPI_TRANSFER_WIDTH_8,
    SPI_TRANSFER_WIDTH_32
} t_transfer_width;

void flush_print(void){
    delay_microseconds(1000);
}

/* This counts up to 16 bytes (steps of 4 if 32b) */
static void inc_state(unsigned &count, spi_mode_t &mode,
        unsigned &speed_index, t_transfer_width &transfer_width){

    // printf("count: %u, speed_idx: %u (%u), mode: %d width: %d\n", count, speed_index, SPEED_TESTS, mode, transfer_width * 24 + 8);
    if(count == 16){
        count = 0;
        if(++speed_index == SPEED_TESTS){
            printf("Transfers complete\n");
            flush_print();
            _Exit(0);
        }
    } else {
        if(transfer_width == SPI_TRANSFER_WIDTH_8){
            count++;
        } else {
            count+=4;
        }
    }
}

[[combinable]]
void app(client interface spi_master_async_if spi_i, int mosi_enabled, int miso_enabled){
    // if testing just one speed, do fastest (idx 0)
    unsigned speed_lut[3] = {2000, 200, 500};

    uint8_t tx8[NUMBER_OF_TEST_BYTES];
    uint8_t rx8[NUMBER_OF_TEST_BYTES];
    uint8_t * movable tx_ptr8 = tx8;
    uint8_t * movable rx_ptr8 = rx8;

    uint32_t tx32[NUMBER_OF_TEST_BYTES];
    uint32_t rx32[NUMBER_OF_TEST_BYTES];
    uint32_t * movable tx_ptr32 = tx32;
    uint32_t * movable rx_ptr32 = rx32;

    for(unsigned i=0;i<NUMBER_OF_TEST_BYTES;i++)
        tx_ptr8[i] = tx_data[i];

    for(unsigned j=0;j<NUMBER_OF_TEST_WORDS;j++)
        tx_ptr32[j] = byterev((tx_data, unsigned[])[j]);

    unsigned inter_frame_gap = 1000;
    unsigned speed_index = 0;
    unsigned device_id = 0;

    spi_mode_t mode = SPI_MODE;
    unsigned speed_in_kbps = speed_lut[speed_index];
    t_transfer_width transfer_width = TRANSFER_WIDTH == 8 ? SPI_TRANSFER_WIDTH_8 : SPI_TRANSFER_WIDTH_32;
    unsigned count = 0;    //bytes or words

    broadcast_settings(setup_strobe_port, setup_data_port,
                mode, speed_in_kbps, mosi_enabled, miso_enabled,
                device_id, inter_frame_gap, count);

    //setup the transaction
    spi_i.begin_transaction(device_id, speed_in_kbps, mode);
    spi_i.init_transfer_array_8(move(rx_ptr8), move(tx_ptr8), count);

    while(1){
        select {

            case spi_i.transfer_complete():{
                if(transfer_width == SPI_TRANSFER_WIDTH_8){
                    spi_i.retrieve_transfer_buffers_8(rx_ptr8, tx_ptr8);
                } else {
                    spi_i.retrieve_transfer_buffers_32(rx_ptr32, tx_ptr32);
                }
                spi_i.end_transaction(inter_frame_gap);


                //verify the data
                if(transfer_width == SPI_TRANSFER_WIDTH_8){
                     if(miso_enabled){
                        for(unsigned j=0;j<count;j++){
                            uint8_t rx = rx_ptr8[j];
                            if(rx != rx_data[j]) {
                                printf("Error, incorrect 8b data at idx %u received: 0x%x expecting(0x%x)\n", j, rx, rx_data[j]);
                                printf("Speed: %, mode: %u, count: %u\n", speed_in_kbps, mode, count);
                                flush_print();
                                _Exit(1);
                            }
                        }
                    }
                } else {
                    for(unsigned j=0;j<count/sizeof(uint32_t);j++){
                        uint32_t rx = rx_ptr32[j];
                        rx = byterev(rx);
                        if(miso_enabled){
                            if(rx != (rx_data, unsigned[])[j]) {
                                printf("Error, incorrect 32b data at idx %u received: 0x%x expecting(0x%x)\n", j, rx, rx_data[j]);
                                printf("Speed: %, mode: %u, count: %u\n", speed_in_kbps, mode, count);
                                flush_print();
                                _Exit(1);
                            }
                        }
                    }

                }
                //if error then abort
                inc_state(count, mode, speed_index, transfer_width);
                if(transfer_width == SPI_TRANSFER_WIDTH_8){
                    broadcast_settings(setup_strobe_port, setup_data_port,
                                mode, speed_in_kbps, mosi_enabled, miso_enabled,
                                device_id, inter_frame_gap, count);
                } else {

                    broadcast_settings(setup_strobe_port, setup_data_port,
                                mode, speed_in_kbps, mosi_enabled, miso_enabled,
                                device_id, inter_frame_gap, count);
                }

                //setup the next
                spi_i.begin_transaction(device_id, speed_in_kbps, mode);
                if(transfer_width == SPI_TRANSFER_WIDTH_8){
                    spi_i.init_transfer_array_8(move(rx_ptr8), move(tx_ptr8), count);
                } else {
                    spi_i.init_transfer_array_32(move(rx_ptr32), move(tx_ptr32), count/sizeof(uint32_t));
                }
                break;
            }
        }
    }
}

static void load(static const unsigned num_threads){
    switch(num_threads){
    case 2: par {par(int i=0;i<2;i++) while(1);}break;
    case 3: par {par(int i=0;i<3;i++) while(1);}break;
    case 4: par {par(int i=0;i<4;i++) while(1);}break;
    case 5: par {par(int i=0;i<5;i++) while(1);}break;
    case 6: par {par(int i=0;i<6;i++) while(1);}break;
    case 7: par {par(int i=0;i<7;i++) while(1);}break;
    }
}

#if MOSI_ENABLED
#define MOSI p_mosi
#else
#define MOSI null
#endif

int main(){
    interface spi_master_async_if i[1];
    par {
#if COMBINED == 1
        [[combine]]
        par {
            spi_master_async(i, 1, p_sclk, MOSI, p_miso, p_ss, 1, cb0, cb1);
            app(i[0], MOSI_ENABLED, 1);
        }
        load(BURNT_THREADS);
#else
        spi_master_async(i, 1, p_sclk, MOSI, p_miso, p_ss, 1, cb0, cb1);
        app(i[0], MOSI_ENABLED, 1);
        load(BURNT_THREADS);
#endif
    }
    return 0;
}
