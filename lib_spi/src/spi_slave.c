// Copyright (c) 2015-2020, XMOS Ltd, All rights reserved
#include <xs1.h>
#include <xclib.h>
#include <stdio.h>
#include <stdlib.h>
#include <xcore/clock.h>
#include <xcore/port.h>
#include <xcore/triggerable.h>

#include "spi.h"

#define ASSERTED 1

void spi_slave(
        const spi_slave_callback_group_t *spi_cbg,
        port_t p_sclk,
        port_t p_mosi,
        port_t p_miso,
        port_t p_cs,
        xclock_t cb_clk,
        int cpol,
        int cpha) {
    uint32_t cs_val;
    uint8_t *out_buf = NULL;
    size_t out_buf_len = 0;
    uint8_t *in_buf = NULL;
    size_t in_buf_len = 0;
    size_t bytes_read = 0;
    size_t bytes_written = 0;
    int running = 0;

	/* Enable fast mode and high priority */
	SPI_IO_SETSR(XS1_SR_QUEUE_MASK | XS1_SR_FAST_MASK);

    /* Setup the chip select port */
    port_enable(p_cs);
    port_set_invert(p_cs);

    /* Setup the SCLK port and associated clock block */
    port_enable(p_sclk);
    clock_enable(cb_clk);
    clock_set_source_port(cb_clk, p_sclk);
    clock_set_divide(cb_clk, 0);    /* Ensure divide is 0 */

    /* Setup the MOSI port */
    port_start_buffered(p_mosi, 8);
    spi_io_configure_in_port_strobed_slave(p_mosi, p_cs, cb_clk);
    port_clear_buffer(p_mosi);

    /* Setup the MISO port */
    if (p_miso != 0) {
        port_start_buffered(p_miso, 8);
        spi_io_configure_out_port_strobed_slave(p_miso, p_cs, cb_clk, 0);
        port_clear_buffer(p_miso);
    }

    if (cpol != cpha) {
        port_set_invert(p_sclk);
    } else {
        port_set_no_invert(p_sclk);
    }

    clock_start(cb_clk);

    spi_io_port_sync(p_sclk);

    /* Wait until CS is not asserted to begin */
    cs_val = port_in_when_pinsneq(p_cs, PORT_UNBUFFERED, ASSERTED);

    triggerable_disable_all();

	TRIGGERABLE_SETUP_EVENT_VECTOR(p_cs, cs_changed);
	TRIGGERABLE_SETUP_EVENT_VECTOR(p_mosi, mosi_changed);

    port_set_trigger_in_not_equal(p_cs, cs_val);

    while(1) {
    	triggerable_enable_trigger(p_cs);

        if (running == 1) {
        	triggerable_enable_trigger(p_mosi);
        }

        TRIGGERABLE_WAIT_EVENT(cs_changed, mosi_changed);

        cs_changed: {
            triggerable_disable_all();
            /* Update next CS event */
            cs_val = port_in(p_cs);
            port_set_trigger_value(p_cs, cs_val);

            if (cs_val == ASSERTED) {
                spi_cbg->slave_transaction_started(spi_cbg->app_data, &out_buf, &out_buf_len, &in_buf, &in_buf_len);
                bytes_read = 0;
                bytes_written = 0;
                running = 1;
            } else {
                uint32_t data = 0;
                size_t read_bits = port_force_input(p_mosi, &data);
                uint32_t mask;

                if (read_bits > 0) {
                    asm volatile("mkmsk %0, %1": "=r"(mask) : "r"(read_bits));
                    in_buf[bytes_read] = ((bitrev(data)>>24) & mask);
                }
                spi_cbg->slave_transaction_ended(spi_cbg->app_data, &out_buf, bytes_written, &in_buf, bytes_read, read_bits);

                port_clear_buffer(p_mosi);
                running = 0;
                continue;
            }

            if (p_miso != 0) {
                port_clear_buffer(p_miso);
                uint32_t out_byte = 0x00;
                if ((out_buf != NULL) && (bytes_written < out_buf_len)) {
                    out_byte = bitrev(out_buf[bytes_written])>>24;
                    bytes_written++;
                }

                /* Must get first bit on the wire before clock edge */
                if (cpha == 0) {
                    asm volatile("setclk res[%0], %1"::"r"(p_miso), "r"(XS1_CLKBLK_REF));
                    spi_io_port_outpw(p_miso, out_byte, 1);
                    asm volatile("setclk res[%0], %1"::"r"(p_miso), "r"(cb_clk));
                    out_byte >>= 1;
                    spi_io_port_outpw(p_miso, out_byte, 7);
                } else {
                    spi_io_port_outpw(p_miso, out_byte, 8);
                }
            }

            port_clear_buffer(p_mosi);
            continue;
        }

        mosi_changed: {
            triggerable_disable_all();

            if (p_miso != 0) {
                port_clear_buffer(p_miso);
                uint32_t out_byte = 0x00;
                if ((out_buf != NULL) && (bytes_written < out_buf_len)) {
                    out_byte = bitrev(out_buf[bytes_written])>>24;
                    bytes_written++;
                }
                spi_io_port_outpw(p_miso, out_byte, 8);
            }

            uint32_t in_byte = port_in(p_mosi);

            if ((in_buf != NULL) && (bytes_read < in_buf_len)) {
                in_buf[bytes_read] = bitrev(in_byte)>>24;
                bytes_read++;
            }

            continue;
        }
    }
}
