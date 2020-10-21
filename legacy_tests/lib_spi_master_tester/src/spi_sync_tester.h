// Copyright (c) 2015-2020, XMOS Ltd, All rights reserved
#ifndef SPI_SYNC_TESTER_H_
#define SPI_SYNC_TESTER_H_

#define VERBOSE 0

#include "common.h"

int test_transfer8(spi_io_ctx_t *spi_ctx,
        port_t setup_strobe_port,
        port_t setup_data_port,
        unsigned device_id,
        unsigned inter_frame_gap,
        unsigned cpol,
        unsigned cpha,
        unsigned speed_in_kbps,
        int mosi_enabled,
        int miso_enabled) {
    int error = 0;]
    uint8_t rx[NUMBER_OF_TEST_BYTES];

    broadcast_settings(setup_strobe_port, setup_data_port,
                       cpha, cpol,
                       speed_in_kbps,
                       mosi_enabled, miso_enabled,
                       device_id, inter_frame_gap,
                       NUMBER_OF_TEST_BYTES);

    spi_io_start_transaction(spi_ctx,
                             speed_in_kbps,
                             cpol, cpha);

    for(unsigned j=0;j<NUMBER_OF_TEST_BYTES;j++){
        spi_io_transfer_bytes(spi_ctx,
                              data_out,
                              rx);
        if(miso_enabled){
            if(rx != rx_data[j]) error = 1;
            if(VERBOSE && (rx != rx_data[j]))
                printf("%02x %02x\n", rx, rx_data[j]);
        }
    }

    spi_io_end_transaction(spi_ctx,
          inter_frame_gap);

    if(error)
        printf("ERROR: master got the wrong data\n");

    return error;
}

int test_transfer32(spi_io_ctx_t *spi_ctx,
        port_t setup_strobe_port,
        port_t setup_data_port,
        unsigned device_id,
        unsigned inter_frame_gap,
        unsigned cpol,
        unsigned cpha,
        unsigned speed_in_kbps,
        int mosi_enabled,
        int miso_enabled) {
    int error = 0;
    uint32_t rx[NUMBER_OF_TEST_WORDS];

    broadcast_settings(setup_strobe_port, setup_data_port,
                       cpha, cpol,
                       speed_in_kbps,
                       mosi_enabled, miso_enabled,
                       device_id, inter_frame_gap,
                       NUMBER_OF_TEST_BYTES);

    spi_io_start_transaction(spi_ctx,
                             speed_in_kbps,
                             cpol, cpha);

    for(unsigned j=0;j<NUMBER_OF_TEST_WORDS;j++){
        spi_io_transfer_32(spi_ctx,
                           byterev((tx_data, unsigned[])[j]),
                           rx);
        rx = byterev(rx);
        if(miso_enabled){
            if(rx != (rx_data, unsigned[])[j]) error = 1;
            if(VERBOSE && (rx != (rx_data, unsigned[])[j]))
               printf("%08x %08x\n", rx ,(rx_data, unsigned[])[j]);
        }
    }

    spi_io_end_transaction(spi_ctx,
          inter_frame_gap);

    if(error)
        printf("ERROR: master got the wrong data\n");
    return error;
}

#endif /* SPI_SYNC_TESTER_H_ */
