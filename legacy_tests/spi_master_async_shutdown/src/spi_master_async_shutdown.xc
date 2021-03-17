// Copyright 2020-2021 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.
#include <platform.h>
#include <xclib.h>
#include <stdio.h>
#include <stdlib.h>
#include <print.h>
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

[[combinable]]
void app(client interface spi_master_async_if spi_i, int mosi_enabled, int miso_enabled){
    unsigned inter_frame_gap = 1000;
    unsigned device_id = 0;
    spi_mode_t mode = SPI_MODE_0;
    unsigned speed_in_kbps = 500;
    unsigned count = 1;

    broadcast_settings(setup_strobe_port, setup_data_port,
                mode, speed_in_kbps, mosi_enabled, miso_enabled,
                device_id, inter_frame_gap, count);

    uint8_t tx[1] = {(tx_data, unsigned char[])[0]};
    uint8_t rx[1];
    uint8_t * movable tx_ptr = tx;
    uint8_t * movable rx_ptr = rx;

    spi_i.begin_transaction(device_id, speed_in_kbps, mode);
    spi_i.init_transfer_array_8(move(rx_ptr), move(tx_ptr), count);

    while(1){
        select {
            case spi_i.transfer_complete():{
                spi_i.retrieve_transfer_buffers_8(rx_ptr, tx_ptr);
                spi_i.end_transaction(inter_frame_gap);
                spi_i.shutdown();
                return;
            }
        }
    }
}

int main(){
    interface spi_master_async_if i[1];
    for (int j = 0; j < 2; j++) { // go around a couple of times in order to exercise the shutdown
      par {
#if COMBINED == 1
          [[combine]]
          par {
              spi_master_async(i, 1, p_sclk, p_mosi, p_miso, p_ss, 1, cb0, cb1);
              app(i[0], 1, 1);
          }
#else
          spi_master_async(i, 1, p_sclk, p_mosi, p_miso, p_ss, 1, cb0, cb1);
          app(i[0], 1, 1);
#endif
      }
    }
    return 0;
}
