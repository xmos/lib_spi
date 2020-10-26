// Copyright (c) 2020, XMOS Ltd, All rights reserved

#include <stdint.h>

#include "spi.h"

void spi_master_start_transaction(
		spi_master_device_t *dev)
{
	spi_master_t *spi = dev->spi_master_ctx;

	/* enable fast mode and high priority */
	SPI_IO_SETSR(XS1_SR_QUEUE_MASK | XS1_SR_FAST_MASK);

	if (dev->cs_assert_val != spi->current_device) {
		spi->current_device = dev->cs_assert_val;

		if (dev->source_clock == spi_master_source_clock_ref) {
			clock_set_source_clk_ref(spi->clock_block);
		} else {
			clock_set_source_clk_xcore(spi->clock_block);
		}
		clock_set_divide(spi->clock_block, dev->clock_divisor);

		if ((dev->miso_sample_delay & 1) == 0) {
			port_set_sample_falling_edge(spi->miso_port);
		} else {
			port_set_sample_rising_edge(spi->miso_port);
		}
		SPI_IO_RESOURCE_SETC(spi->miso_port, SPI_IO_SETC_PAD_DELAY(dev->miso_pad_delay));

		/* Output the clock idle value */
		clock_start(spi->clock_block);
		spi_io_port_outpw(spi->sclk_port, dev->clock_bits >> 1, 1);
		spi_io_port_sync(spi->sclk_port);
		clock_stop(spi->clock_block);

		/*
		 * This transaction is with a different chip
		 * than last time, so there is no need to wait
		 * for the minimum CS to CS time.
		 */
		port_clear_trigger_time(spi->cs_port);
	} else {
		/*
		 * This ensures that the CS_high to CS_low
		 * minimum time is met.
		 */
		spi_io_port_sync(spi->cs_port);
	}

	spi->first_transfer = 1;

	/* Assert CS now */
	port_out(spi->cs_port, dev->cs_assert_val);
	spi_io_port_sync(spi->cs_port);

	/*
	 * Assert CS again, scheduled for earliest time the
	 * data is allowed to start moving. The first transfer
	 * will sync on CS before starting to ensure the minimum
	 * CS to data time is met.
	 */
	if (dev->cs_to_clk_delay_ticks > 1) {
		port_out_at_time(spi->cs_port, port_get_trigger_time(spi->cs_port) + dev->cs_to_clk_delay_ticks, dev->cs_assert_val);
	}
}

void spi_master_transfer(
		spi_master_device_t *dev,
		uint8_t *data_out,
		uint8_t *data_in,
		size_t len)
{
	const uint32_t start_time = 1;
	spi_master_t *spi = dev->spi_master_ctx;
	uint32_t tmp;
	uint32_t word_out;
	uint32_t word_in;
	int i;

	if (spi->first_transfer) {
		/* Ensure the minimum CS to data time is met */
		spi_io_port_sync(spi->cs_port);
		spi->first_transfer = 0;
	} else {
		port_clear_trigger_time(spi->cs_port);
	}

	port_set_trigger_time(spi->mosi_port, start_time);
	port_set_trigger_time(spi->sclk_port, start_time + dev->clock_delay);

	tmp = data_out[0];
	word_out = tmp; /* todo: word_out should be the first two bytes (if len >= 2) */
	asm volatile("zip %0, %1, 0" :"+r"(tmp), "+r"(word_out));
	word_out = bitrev(word_out) >> 16; /* todo don't shift obviously if outputting 2 bytes */

	spi_io_port_outpw(spi->mosi_port, word_out, 16); /* todo: 32 if len >= 2, else 16 */
	spi_io_port_outpw(spi->sclk_port, dev->clock_bits, 16); /* todo: 32 if len >= 2, else 16 */

	port_set_trigger_time(spi->miso_port, start_time + 14 + dev->miso_initial_trigger_delay); /* don't ask. todo: fix for 2 bytes */

	clock_start(spi->clock_block);

	/* todo: only output whole words after the first */
	for (i = 1; i < len; i++) {
		tmp = data_out[i];
		word_out = tmp;
		asm volatile("zip %0, %1, 0" :"+r"(tmp), "+r"(word_out));
		word_out = bitrev(word_out) >> 16;
		spi_io_port_outpw(spi->mosi_port, word_out, 16); /* todo: 32 */
		spi_io_port_outpw(spi->sclk_port, dev->clock_bits, 16);
		//port_out(ctx->mosi_port, word_out);
		//port_out(ctx->sclk_port, ctx->clock_bits);

		if (spi->miso_port == 0) {
			continue;
		}
		word_in = bitrev(port_in(spi->miso_port));
		spi_io_port_shift_count(spi->miso_port, 16); //todo: remove for 32
		asm volatile("unzip %0, %1, 0" :"+r"(tmp), "+r"(word_in));
		data_in[i-1] = word_in;
	}

	word_in = bitrev(port_in(spi->miso_port));
	asm volatile("unzip %0, %1, 0" :"+r"(tmp), "+r"(word_in));
	data_in[i-1] = word_in;

	spi_io_port_sync(spi->sclk_port);
	clock_stop(spi->clock_block);

	/* Assert CS again now */
	port_out(spi->cs_port, dev->cs_assert_val);
	spi_io_port_sync(spi->cs_port);

	/*
	 * And assert CS again, scheduled for earliest time CS
	 * is allowed to deassert.
	 */
	if (dev->clk_to_cs_delay_ticks > 1) {
		port_out_at_time(spi->cs_port, port_get_trigger_time(spi->cs_port) + dev->clk_to_cs_delay_ticks, dev->cs_assert_val);
	}
}

void spi_master_end_transaction(
		spi_master_device_t *dev)
{
	const uint32_t cs_deassert_val = 0xFFFFFFFF;
	spi_master_t *spi = dev->spi_master_ctx;

	/* enable fast mode and high priority */
	SPI_IO_CLRSR(XS1_SR_QUEUE_MASK | XS1_SR_FAST_MASK);

	spi_io_port_sync(spi->cs_port);

	port_out(spi->cs_port, cs_deassert_val);
	spi_io_port_sync(spi->cs_port);

	/*
	 * Deassert CS again, scheduled for earliest time CS
	 * is allowed to be re-asserted. The next transaction
	 * will sync on CS before starting to ensure the minimum
	 * CS to CS time is met.
	 */
	if (dev->cs_to_cs_delay_ticks > 1) {
		port_out_at_time(spi->cs_port, port_get_trigger_time(spi->cs_port) + dev->cs_to_cs_delay_ticks, cs_deassert_val);
	}
}

void spi_master_deinit(spi_master_t *spi)
{
	port_disable(spi->cs_port);
	port_disable(spi->mosi_port);
	port_disable(spi->miso_port);
	port_disable(spi->sclk_port);
	clock_disable(spi->clock_block);
}

void spi_master_device_init(
		spi_master_device_t *dev,
		spi_master_t *spi,
		uint32_t cs_pin,
		int cpol,
		int cpha,
		spi_master_source_clock_t source_clock,
		uint32_t clock_divisor,
		spi_master_sample_delay_t miso_sample_delay,
		uint32_t miso_pad_delay,
		uint32_t cs_to_clk_delay_ticks,
		uint32_t clk_to_cs_delay_ticks,
		uint32_t cs_to_cs_delay_ticks)
{
	dev->spi_master_ctx = spi;

	dev->source_clock = source_clock;
	dev->clock_divisor = clock_divisor;
	dev->miso_sample_delay = miso_sample_delay;

	dev->miso_initial_trigger_delay = (miso_sample_delay + 1) >> 1;
	dev->miso_pad_delay = miso_pad_delay;

	dev->cs_assert_val = 0xFFFFFFFF & ~(1 << cs_pin);
	dev->clock_delay = cpha ? 0 : 1;
	dev->clock_bits = cpol ? 0xAAAAAAAA : 0x55555555;

	dev->cs_to_clk_delay_ticks = cs_to_clk_delay_ticks;
	dev->clk_to_cs_delay_ticks = clk_to_cs_delay_ticks;
	dev->cs_to_cs_delay_ticks = cs_to_cs_delay_ticks;
}

void spi_master_init(
		spi_master_t *spi,
		xclock_t clock_block,
		port_t cs_port,
		port_t sclk_port,
		port_t mosi_port,
		port_t miso_port)
{
	/* Setup the clock block */
	spi->clock_block = clock_block;
	clock_enable(spi->clock_block);

	/* Setup the chip select port */
	spi->cs_port = cs_port;
	port_enable(spi->cs_port);
	port_set_clock(spi->cs_port, XS1_CLKBLK_REF);
	port_out(spi->cs_port, 0xFFFFFFFF);
	spi_io_port_sync(spi->cs_port);
	spi->current_device = 0xFFFFFFFF;

	/* Setup the SCLK port */
	spi->sclk_port = sclk_port;
	port_start_buffered(spi->sclk_port, 32);
	port_set_clock(spi->sclk_port, spi->clock_block);

	/* Setup the MOSI port */
	spi->mosi_port = mosi_port;
	port_start_buffered(spi->mosi_port, 32);
	port_set_clock(spi->mosi_port, spi->clock_block);

	/* Setup the MISO port */
	spi->miso_port = miso_port;
	port_start_buffered(spi->miso_port, 32);
	port_set_clock(spi->miso_port, spi->clock_block);

	/* Ensure the buffers are clear before the first transaction. */
	port_clear_buffer(spi->mosi_port);
	port_clear_buffer(spi->miso_port);
}
