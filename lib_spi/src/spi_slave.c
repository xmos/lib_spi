// Copyright (c) 2015-2020, XMOS Ltd, All rights reserved
#include <xs1.h>
#include <xclib.h>
#include <stdio.h>
#include <stdlib.h>
#include <xcore/clock.h>
#include <xcore/port.h>
#include <xcore/port_protocol.h>
#include <xcore/triggerable.h>
#include <xcore/interrupt_wrappers.h>
#include <xcore/interrupt.h>

#include "spi.h"

#define ASSERTED 1

typedef struct internal_ctx {
    port_t p_miso;
    port_t p_mosi;
    port_t p_cs;
    xclock_t cb_clk;
    int cpol;
    int cpha;
    const spi_slave_callback_group_t *spi_cbg;
    volatile uint32_t cs_val;
    uint8_t * volatile out_buf;
    volatile size_t out_buf_len;
    uint8_t * volatile in_buf;
    volatile size_t in_buf_len;
    volatile size_t bytes_read;
    volatile size_t bytes_written;
} internal_ctx_t;


DEFINE_INTERRUPT_CALLBACK(spi_isr_grp, cs_isr, arg)
{
    internal_ctx_t* ctx = (internal_ctx_t*)arg;

    /* Update next CS event */
    ctx->cs_val = port_in(ctx->p_cs);
    port_set_trigger_value(ctx->p_cs, ctx->cs_val);

    if (ctx->cs_val == ASSERTED) {
        ctx->spi_cbg->slave_transaction_started(ctx->spi_cbg->app_data, &ctx->out_buf, &ctx->out_buf_len, &ctx->in_buf, &ctx->in_buf_len);
        ctx->bytes_read = 0;
        ctx->bytes_written = 0;
        triggerable_enable_trigger(ctx->p_mosi);

        if (ctx->p_mosi != 0) {
            port_clear_buffer(ctx->p_mosi);
        }
        if (ctx->p_miso != 0) {
            port_clear_buffer(ctx->p_miso);
        }

    } else {
        uint32_t data = 0;
        size_t read_bits = port_force_input(ctx->p_mosi, &data);
        uint32_t mask;

        if (read_bits > 0) {
            asm volatile("mkmsk %0, %1": "=r"(mask) : "r"(read_bits));
            ctx->in_buf[ctx->bytes_read] = ((bitrev(data)>>24) & mask);
        }
        ctx->spi_cbg->slave_transaction_ended(ctx->spi_cbg->app_data, &ctx->out_buf, ctx->bytes_written, &ctx->in_buf, ctx->bytes_read, read_bits);

        if (ctx->p_miso != 0) {
            port_clear_buffer(ctx->p_miso);
        }
        triggerable_disable_trigger(ctx->p_mosi);
        return;
    }

    if (ctx->p_miso != 0) {

        port_clear_buffer(ctx->p_miso);

        uint32_t out_byte = 0x00;
        if ((ctx->out_buf != NULL) && (ctx->bytes_written < ctx->out_buf_len)) {
            out_byte = bitrev(ctx->out_buf[ctx->bytes_written])>>24;
            ctx->bytes_written++;
        }

        /* Must get first bit on the wire before clock edge */
        if (ctx->cpha == 0) {
            asm volatile("setclk res[%0], %1"::"r"(ctx->p_miso), "r"(XS1_CLKBLK_REF));
            spi_io_port_outpw(ctx->p_miso, out_byte, 1);
            spi_io_port_sync(ctx->p_miso);
            asm volatile("setclk res[%0], %1"::"r"(ctx->p_miso), "r"(ctx->cb_clk));
            out_byte >>= 1;
            spi_io_port_outpw(ctx->p_miso, out_byte, 7);
        } else {
            //spi_io_port_outpw(p_miso, out_byte, 8);
            port_out(ctx->p_miso, out_byte);
        }

        port_clear_buffer(ctx->p_mosi);

        if ((ctx->out_buf != NULL) && (ctx->bytes_written < ctx->out_buf_len)) {
            out_byte = bitrev(ctx->out_buf[ctx->bytes_written])>>24;
            ctx->bytes_written++;
        }
        //spi_io_port_outpw(p_miso, out_byte, 8);
        port_out(ctx->p_miso, out_byte);
    }
}

void spi_slave(
        const spi_slave_callback_group_t *spi_cbg,
        port_t p_sclk,
        port_t p_mosi,
        port_t p_miso,
        port_t p_cs,
        xclock_t cb_clk,
        int cpol,
        int cpha) {
    internal_ctx_t int_ctx = {
        .p_miso = p_miso,
        .p_mosi = p_mosi,
        .p_cs = p_cs,
        .cb_clk = cb_clk,
        .cpol = cpol,
        .cpha = cpha,
        .spi_cbg = spi_cbg,
        .cs_val = !ASSERTED,
        .out_buf = NULL,
        .out_buf_len = 0,
        .in_buf = NULL,
        .in_buf_len = 0,
        .bytes_read = 0,
        .bytes_written = 0,
    };

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
    port_enable(p_mosi);
    port_protocol_in_strobed_slave(p_mosi, p_cs, cb_clk);
    port_set_transfer_width(p_mosi, 8);

    /* Setup the MISO port */
    if (p_miso != 0) {
        port_enable(p_miso);
        port_protocol_out_strobed_slave(p_miso, p_cs, cb_clk, 0);
        port_set_transfer_width(p_miso, 8);
    }

    if (cpol != cpha) {
        port_set_invert(p_sclk);
    } else {
        port_set_no_invert(p_sclk);
    }

    clock_start(cb_clk);

    spi_io_port_sync(p_sclk);

    /* Wait until CS is not asserted to begin */
    int_ctx.cs_val = port_in_when_pinsneq(p_cs, PORT_UNBUFFERED, ASSERTED);

    triggerable_setup_interrupt_callback(p_cs, &int_ctx, INTERRUPT_CALLBACK(cs_isr));

    interrupt_mask_all();

    triggerable_enable_trigger(p_cs);
    port_set_trigger_in_not_equal(p_cs, int_ctx.cs_val);

    interrupt_unmask_all();

    while (1) {
        uint32_t in_byte = port_in(p_mosi);

        if ((int_ctx.in_buf != NULL) && (int_ctx.bytes_read < int_ctx.in_buf_len)) {
            int_ctx.in_buf[int_ctx.bytes_read] = bitrev(in_byte)>>24;
            int_ctx.bytes_read++;
        }

        if (p_miso != 0) {
            uint32_t out_byte = 0x00000000;
            if ((int_ctx.out_buf != NULL) && (int_ctx.bytes_written < int_ctx.out_buf_len)) {
                out_byte = bitrev(int_ctx.out_buf[int_ctx.bytes_written])>>24;
                int_ctx.bytes_written++;
            }

            port_out(p_miso, out_byte);
        }
    }
}
