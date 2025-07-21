// Copyright 2015-2025 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.
#include <platform.h>
#include <xclib.h>
#include <xs1.h>
#include <stdio.h>
#include <stdlib.h>
#include "spi.h"


in buffered port:32    p_miso   = XS1_PORT_1A;
out port               p_ss     = XS1_PORT_1B;
out buffered port:32   p_sclk   = XS1_PORT_1C;
out buffered port:32   p_mosi   = XS1_PORT_1D;
clock                  cb0      = XS1_CLKBLK_1;
clock                  cb1      = XS1_CLKBLK_2;

out port setup_strobe_port = XS1_PORT_1E;
out port setup_data_port = XS1_PORT_16B;

void flush_print(void){
    delay_microseconds(1000);
}

void app(client interface spi_master_async_if i, int mosi_enabled,
        int miso_enabled, streaming chanend c, unsigned speed){
    set_core_fast_mode_on();
    uint32_t tx[8] = {0xed, 0xc0ffee, 0x0000000f, 0x000000f0, 0x00000f00, 0x0000f000, 0x000f0000, 0x00f00000};
    uint32_t rx[8] = {0x0};
    uint32_t * movable tx_ptr = tx;
    uint32_t * movable rx_ptr = rx;

    while(1){
        c <: 0;
        i.begin_transaction(0, speed, SPI_MODE_0);
        c <: 1;
        i.init_transfer_array_32(move(rx_ptr), move(tx_ptr), sizeof(tx)/sizeof(tx[0]));
        c <: 2;
        select {
            case i.transfer_complete():{
                break;
            }
        }
        c <: 3;
        i.retrieve_transfer_buffers_32(rx_ptr, tx_ptr);

        if(MOSI_ENABLED && (tx_ptr[0] != rx_ptr[0] || tx_ptr[1] != rx_ptr[1])){
            printf("Loopback didn't work!\n");
            printf("Tx: 0x%x 0x%x, Rx: 0x%x 0x%x\n", tx_ptr[0], tx_ptr[1], rx_ptr[0], rx_ptr[1]);
            _Exit(1);
        } else {
            // printf("Loopback PASS\n");
        }
        c <: 4;
        i.end_transaction(100);
        c <: 5;

        int holdoff_ticks = (10000 - speed) * 10;
        delay_ticks(holdoff_ticks); //Ensure one client doesn't hog the test
    }
}

#define CLIENTS 3
[[combinable]]
void watcher(streaming chanend c[CLIENTS]){
    int seen[CLIENTS] = {0};
    set_core_fast_mode_on();
    //TODO maybe put a timeout in here
    while(1){
        select{
            case c[int i] :> int token:{
                timer t;
                int time;
                t :> time;
                // printf("Got %d from client: %d @ %d\n",token, i, time);

                if(token == 5){
                    seen[i] = 1;
                }
                int any_not_seen = 0;
                for(unsigned j=0;j<CLIENTS;j++)
                    any_not_seen |= (seen[j] == 0);

                if(!any_not_seen){
                    printf("Transfers complete\n");
                    flush_print();
                    _Exit(0);
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
    streaming chan c[3];
    interface spi_master_async_if i[3];
    par {

#if COMBINED == 1
        [[combine]]
         par {
            spi_master_async_fwk(i, 3, p_sclk, MOSI, p_miso, p_ss, 1, cb0, cb1);
            watcher(c);
        }
#else
        spi_master_async_fwk(i, 3, p_sclk, MOSI, p_miso, p_ss, 1, cb0, cb1);
        watcher(c);
#endif
        app(i[0], MOSI_ENABLED, 1, c[0], 5000);
        app(i[1], MOSI_ENABLED, 1, c[1], 6000);
        app(i[2], MOSI_ENABLED, 1, c[2], 7000);
        load(BURNT_THREADS);
    }
    return 0;
}
