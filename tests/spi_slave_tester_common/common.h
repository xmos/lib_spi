// Copyright 2015-2025 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.
#ifndef COMMON_SLAVE_H_
#define COMMON_SLAVE_H_

#include <print.h>

static void set_mode_bits(spi_mode_t mode, unsigned &cpol, unsigned &cpha){
    switch(mode){
        case SPI_MODE_0:cpol = 0; cpha= 0; break;
        case SPI_MODE_1:cpol = 0; cpha= 1; break;
        case SPI_MODE_2:cpol = 1; cpha= 0; break;
        case SPI_MODE_3:cpol = 1; cpha= 1; break;
    }
}

static void send_data_to_tester(
        out port setup_strobe_port,
        out port setup_data_port,
        unsigned data){
    setup_data_port <: data;
    sync(setup_data_port);
    setup_strobe_port <: 1; // Twice to meet timing on harness
    setup_strobe_port <: 1;
    setup_strobe_port <: 0;
    setup_strobe_port <: 0;
}

static void broadcast_settings(
        out port setup_strobe_port,
        out port setup_data_port,
        spi_mode_t mode,
        int mosi_enabled,
        int miso_enabled,
        unsigned num_bits,
        unsigned kbps,
        unsigned initial_clock_delay // in ns

){
    unsigned cpha, cpol;

    set_mode_bits(mode, cpol, cpha);

    setup_strobe_port <: 0;
    setup_strobe_port <: 0;

    send_data_to_tester(setup_strobe_port, setup_data_port, cpol);
    send_data_to_tester(setup_strobe_port, setup_data_port, cpha);
    send_data_to_tester(setup_strobe_port, setup_data_port, miso_enabled);
    send_data_to_tester(setup_strobe_port, setup_data_port, num_bits);
    send_data_to_tester(setup_strobe_port, setup_data_port, kbps);
    send_data_to_tester(setup_strobe_port, setup_data_port, initial_clock_delay);
}

static int request_response(
        out port setup_strobe_port,
        in port setup_resp_port
){
    int r;
    setup_resp_port when pinseq(1) :> r; // Wait for ACK from tester first

    setup_strobe_port <: 1; // Repeat to make sure we are not too fast
    setup_strobe_port <: 1;
    setup_strobe_port <: 1;
    setup_strobe_port <: 1;
    setup_strobe_port <: 0;
    setup_strobe_port <: 0;
    setup_strobe_port <: 0;
    setup_strobe_port <: 0;

    setup_resp_port :> r;

    return r;

}

void flush_print(void){
    delay_microseconds(10);
}

#define NUMBER_OF_TEST_BYTES 16
#define NUMBER_OF_TEST_WORDS (NUMBER_OF_TEST_BYTES/sizeof(uint32_t))

static const uint8_t tx_data[NUMBER_OF_TEST_BYTES] = {
        0xaa, 0x02, 0x04, 0x08, 0x10, 0x20, 0x04, 0x80,
        0xfe, 0xfd, 0xfb, 0xf7, 0xef, 0xdf, 0xbf, 0x7f
};

static const uint8_t rx_data[NUMBER_OF_TEST_BYTES] = {
        0xaa, 0xf7, 0xfb, 0xef, 0xdf, 0xbf, 0xfd, 0x7f,
        0x01, 0x08, 0x04, 0x10, 0x20, 0x04, 0x02, 0x80,
};



#endif /* COMMON_SLAVE_H_ */
