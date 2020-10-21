// Copyright (c) 2020, XMOS Ltd, All rights reserved

#include <stdint.h>

#include "spi_io.h"

void spi_io_deinit(const spi_io_ctx_t *ctx)
{
	port_disable(ctx->cs_port);
	port_disable(ctx->mosi_port);
	port_disable(ctx->miso_port);
	port_disable(ctx->sclk_port);
	clock_disable(ctx->clock_block);
}

void spi_io_init(const spi_io_ctx_t *ctx,
                 spi_io_source_clock_t source_clock)
{
	/* Setup the clock block */
	clock_enable(ctx->clock_block);
	if (source_clock == spi_io_source_clock_ref) {
		clock_set_source_clk_ref(ctx->clock_block);
	} else {
		clock_set_source_clk_xcore(ctx->clock_block);
	}


	/* Setup the chip select port */
	port_enable(ctx->cs_port);
	port_out(ctx->cs_port, 0xFFFFFFFF);
	spi_io_port_sync(ctx->cs_port);
	//port_set_clock(ctx->cs_port, ctx->clock_block);

	/* Setup the MOSI port */
	port_start_buffered(ctx->mosi_port, 32);
	port_set_clock(ctx->mosi_port, ctx->clock_block);

	/* Setup the MISO port */
	port_start_buffered(ctx->miso_port, 32);
	port_set_clock(ctx->miso_port, ctx->clock_block);
	if (ctx->sclk_sample_edge == spi_io_sample_edge_falling) {
		port_set_sample_falling_edge(ctx->miso_port);
	}
	SPI_IO_RESOURCE_SETC(ctx->cs_port, SPI_IO_SETC_PAD_DELAY(ctx->miso_pad_delay));

	/* Ensure the buffers are clear before the first transaction. */
	port_clear_buffer(ctx->mosi_port);
	port_clear_buffer(ctx->miso_port);

	/* Setup the SCLK port */
	port_enable(ctx->sclk_port);
	port_set_clock(ctx->sclk_port, ctx->clock_block);
	port_set_out_clock(ctx->sclk_port);
}
