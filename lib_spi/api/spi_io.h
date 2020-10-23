// Copyright (c) 2020, XMOS Ltd, All rights reserved
#pragma once

/** \file
 *  \brief API for QSPI I/O
 */

#define CS_AUTO_ASSERT 0

#include <stdlib.h> /* for size_t */
#include <stdint.h>
#include <xclib.h> /* for byterev() */
#include <xcore/assert.h>
#include <xcore/port.h>
#include <xcore/clock.h>

typedef enum {
	spi_master_sample_delay_0 = 0, /*< Samples 1/2 clock cycle after output from device */
	spi_master_sample_delay_1 = 1, /*< Samples 3/4 clock cycle after output from device */
	spi_master_sample_delay_2 = 2, /*< Samples 1 clock cycle after output from device */
	spi_master_sample_delay_3 = 3, /*< Samples 1 and 1/4 clock cycle after output from device */
	spi_master_sample_delay_4 = 4, /*< Samples 1 and 1/2 clock cycle after output from device */
} spi_master_sample_delay_t;

typedef enum {
	spi_master_source_clock_ref = 0,
	spi_master_source_clock_xcore
} spi_master_source_clock_t;

#define SPI_MODE_0 0,0
#define SPI_MODE_1 0,1
#define SPI_MODE_2 1,0
#define SPI_MODE_3 1,1


typedef struct {
	/**
	 * The clock block to use for the SPI master interface.
	 */
	xclock_t clock_block;

	/**
	 * The chip select port. May be a multibit port.
	 */
	port_t cs_port;

	/**
	 * The SCLK port. MUST be a 1-bit port.
	 */
	port_t sclk_port;

	/**
	 * The MOSI port. MUST be a 1-bit port.
	 */
	port_t mosi_port;

	/**
	 * The MISO port. MUST be a 1-bit port.
	 */
	port_t miso_port;

	uint32_t current_device;
	int first_transfer;

} spi_master_t;

typedef struct {
	spi_master_t *spi_master_ctx;

	spi_master_source_clock_t source_clock;

	/**
	 * The divisor to use for SPI transactions.
	 *
	 * The frequency of SCLK will be set to:
	 * (F_src) / (2 * full_speed_clk_divisor)
	 * Where F_src is the frequency of the source clock.
	 */
	int clock_divisor;

	/**
	 * When to sample MISO. See spi_master_sample_delay_t.
	 */
	spi_master_sample_delay_t miso_sample_delay;

	/**
	 * Number of core clock cycles to delay sampling the MISO pad during
	 * a transaction. This allows for more fine grained adjustment
	 * of sampling time. The value may be between 0 and 5.
	 */
	uint32_t miso_pad_delay;
	uint32_t miso_initial_trigger_delay;

	uint32_t cs_assert_val;
	uint32_t clock_delay;
	uint32_t clock_bits;

	uint32_t cs_to_clk_delay_ticks;
	uint32_t clk_to_cs_delay_ticks;
	uint32_t cs_to_cs_delay_ticks;

} spi_master_device_t;

void spi_master_init(
		spi_master_t *ctx,
		xclock_t clock_block,
		port_t cs_port,
		port_t sclk_port,
		port_t mosi_port,
		port_t miso_port);

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
		uint32_t cs_to_cs_delay_ticks);

void spi_master_start_transaction(
		spi_master_device_t *dev);

void spi_master_transfer(
		spi_master_device_t *dev,
		uint8_t *data_out,
		uint8_t *data_in,
		size_t len);

void spi_master_end_transaction(
		spi_master_device_t *dev);

void spi_master_deinit(
		spi_master_t *ctx);



/* The SETC constant for pad delay is missing from xs2a_user.h */
#define SPI_IO_SETC_PAD_DELAY(n) (0x7007 | ((n) << 3))

/* These appear to be missing from the public API of lib_xcore */
#define SPI_IO_RESOURCE_SETCI(res, c) asm volatile( "setc res[%0], %1" :: "r" (res), "n" (c))
#define SPI_IO_RESOURCE_SETC(res, r) asm volatile( "setc res[%0], %1" :: "r" (res), "r" (r))
#define SPI_IO_SETSR(c) asm volatile("setsr %0" : : "n"(c));
#define SPI_IO_CLRSR(c) asm volatile("clrsr %0" : : "n"(c));


/* is syncr available in lib_xcore or anywhere else..??? */
__attribute__((always_inline))
inline void spi_io_port_sync(resource_t __p)
{
	asm volatile("syncr res[%0]" : : "r" (__p));
}

/* is setpsc available in lib_xcore or anywhere else..??? */
__attribute__((always_inline))
inline void spi_io_port_shift_count(resource_t __p,
                                     uint32_t __shift_count)
{
	asm volatile("setpsc res[%0], %1" : : "r" (__p), "r" (__shift_count));
}

/* is setpsc available in lib_xcore or anywhere else..??? */
__attribute__((always_inline))
inline void spi_io_port_outpw(resource_t __p,
                              uint32_t __w,
							  uint32_t __bpw)
{
	asm volatile("outpw res[%0], %1, %2" : : "r" (__p), "r" (__w), "r" (__bpw));
}

#if 0

/**
 * Begins a new QSPI I/O transaction by starting the clock,
 * asserting CS, and sending out the first word which is
 * typically a command.
 *
 * \note If more words or bytes need to be sent or received as
 * part of this transaction, then the appropriate functions will
 * need to be called immediately following this one. For example,
 * qspi_io_bytes_out() then qspi_io_sio_direction_input() then
 * qspi_io_bytes_in(). The "out" or "in" instruction in each must
 * be executed within eight SCLK cycles of the preceding one,
 * including the OUT instruction in qspi_io_start_transaction().
 * Some analysis may be necessary depending on the frequency of SCLK.
 * These functions are all marked as inline to help keep them closer
 * together by removing the overhead associated with function calls
 * and to allow better optimization.
 *
 * \note It is likely not possible to follow an input with an output
 * within a single transaction unless the frequency of SCLK is
 * sufficiently slow. Fortunately in practice this rarely, if ever,
 * required.
 *
 * \param ctx         Pointer to the SPI I/O context.
 * \param first_word  The first word to output.
 * \param len         The total number of clock cycles in the transaction.
 *                    CS will at some point during the transaction be setup
 *                    to deassert automatically after this number of cycles.
 * \param is_spi_read Set to true if the transaction will be a SPI read with
                      no dummy cycles. This may run at a slower clock frequency
                      in order to turn around SIO from output to input in time.
 */
__attribute__((always_inline))
inline void spi_master_start_transaction(spi_master_t *ctx,
                                     uint32_t cs_pin,
									 int cpol,
									 int cpha)
                                     //spi_io_mode_t transaction_type)
{
	uint32_t cs_port_val;

	/* enable fast mode and high priority */
	SPI_IO_SETSR(XS1_SR_QUEUE_MASK | XS1_SR_FAST_MASK);

	///* CPHA 1 not supported */ xassert(cpha == 0);
	if (cpha == 0) {
		SPI_IO_RESOURCE_SETC(ctx->mosi_port, SPI_IO_SETC_PAD_DELAY(0));

		if (ctx->sclk_sample_edge == spi_io_sample_edge_0) {
			ctx->miso_sample_delay = 0;
			port_set_sample_rising_edge(ctx->miso_port);
		} else if (ctx->sclk_sample_edge == spi_io_sample_edge_1) {
			ctx->miso_sample_delay = 0;
			port_set_sample_falling_edge(ctx->miso_port);
		} else if (ctx->sclk_sample_edge == spi_io_sample_edge_2) {
			ctx->miso_sample_delay = 1;
			port_set_sample_rising_edge(ctx->miso_port);
		}
	} else {
		SPI_IO_RESOURCE_SETC(ctx->mosi_port, SPI_IO_SETC_PAD_DELAY(5));

		if (ctx->sclk_sample_edge == spi_io_sample_edge_0) {
			ctx->miso_sample_delay = 0;
			port_set_sample_falling_edge(ctx->miso_port);
		} else if (ctx->sclk_sample_edge == spi_io_sample_edge_1) {
			ctx->miso_sample_delay = 0;
			port_set_sample_rising_edge(ctx->miso_port);
		} else if (ctx->sclk_sample_edge == spi_io_sample_edge_2) {
			ctx->miso_sample_delay = 1;
			port_set_sample_falling_edge(ctx->miso_port);
		}
	}
	if (cpol == 0) {
		port_set_no_invert(ctx->sclk_port);
	} else {
		port_set_invert(ctx->sclk_port);
	}

	ctx->cpol = cpol;
	ctx->cpha = cpha;

	cs_port_val = port_peek(ctx->cs_port);

	ctx->cs_assert_val   = cs_port_val & ~(1 << cs_pin);
	ctx->cs_deassert_val = cs_port_val |  (1 << cs_pin);

	clock_set_divide(ctx->clock_block, ctx->clk_divisor);

#if !CS_AUTO_ASSERT
	port_out(ctx->cs_port, ctx->cs_assert_val);
	spi_io_port_sync(ctx->cs_port);
#endif
}

__attribute__((always_inline))
inline void spi_master_end_transaction(spi_master_t *ctx,
                                   uint32_t cs_pin)
{
	/* enable fast mode and high priority */
	SPI_IO_CLRSR(XS1_SR_QUEUE_MASK | XS1_SR_FAST_MASK);

#if !CS_AUTO_ASSERT
	port_out(ctx->cs_port, ctx->cs_deassert_val);
	spi_io_port_sync(ctx->cs_port);
#endif
}

__attribute__((always_inline))
inline uint32_t build_partial_word(const uint8_t *data_out, const int len, const int i)
{
	uint32_t word_out;
	word_out  = data_out[i+0] << 24;
	if (len > 1) {
		word_out |= data_out[i+1] << 16;
	}
	if (len > 2) {
		word_out |= data_out[i+2] << 8;
	}
	if (len > 3) {
		word_out |= data_out[i+3];
	}
	return bitrev(word_out);
}

__attribute__((always_inline))
inline uint32_t build_word(const uint8_t *data_out, const int i)
{
	uint32_t word_out;
	word_out  = data_out[i+0] << 24;
	word_out |= data_out[i+1] << 16;
	word_out |= data_out[i+2] << 8;
	word_out |= data_out[i+3];
	return bitrev(word_out);
}

__attribute__((always_inline))
inline void save_word(uint8_t *data_in, uint32_t word_in, const int i)
{
	word_in = bitrev(word_in);
	data_in[i+0] = (word_in >> 24) & 0xFF;
	data_in[i+1] = (word_in >> 16) & 0xFF;
	data_in[i+2] = (word_in >> 8) & 0xFF;
	data_in[i+3] = (word_in) & 0xFF;
}

__attribute__((always_inline))
inline void save_partial_word(uint8_t *data_in, uint32_t word_in, const int len, const int i)
{
	word_in = bitrev(word_in);

	word_in <<= 8 * (4 - len);

	data_in[i+0] = (word_in >> 24) & 0xFF;
	if (len > 1) {
		data_in[i+1] = (word_in >> 16) & 0xFF;
	}
	if (len > 2) {
		data_in[i+2] = (word_in >> 8) & 0xFF;
	}
	if (len > 3) {
		data_in[i+3] = (word_in) & 0xFF;
	}
}

__attribute__((always_inline))
inline void spi_master_transfer(const spi_master_t *ctx,
                            const uint8_t *data_out,
                            uint8_t *data_in,
							size_t len)
{
	int i = 1;
	int do_input;
	int do_output;
	int word_count;
	uint32_t word_out;
	uint32_t word_in;
	uint32_t remainder;
	uint32_t start_time;

	if (len == 0) {
		return;
	}

	if (ctx->cpha == 0) {
		start_time = 0;
	} else {
		start_time = 1;
	}

	word_count = len / sizeof(uint32_t);
	remainder = len & sizeof(uint32_t) - 1; /* get the byte remainder */

	/*
	 * Set the CS port's clock to the SPI clock block.
	 */
	port_set_clock(ctx->cs_port, ctx->clock_block);

#if CS_AUTO_ASSERT
	//start_time = 1;
	//port_set_trigger_time(ctx->cs_port, start_time);
	port_out(ctx->cs_port, ctx->cs_assert_val);
#endif

	if (ctx->mosi_port != 0) {
		if (data_out != NULL) {
			word_out = build_partial_word(data_out, len, 0);
			do_output = 1;
		} else {
			word_out = 0;
			do_output = 2;
		}

		//port_set_trigger_time(ctx->mosi_port, start_time);

		uint32_t tw = len >= 4 ? 32 : len * 8 - 1;

		/* Output the first bit before the clock starts */
		port_set_clock(ctx->mosi_port, XS1_CLKBLK_REF);
		spi_io_port_outpw(ctx->mosi_port, word_out, 1);
		word_out >>= 1;
		spi_io_port_sync(ctx->mosi_port);
		port_set_clock(ctx->mosi_port, ctx->clock_block);

		/* Set the remaining bits to go out after the clock starts */
		spi_io_port_outpw(ctx->mosi_port, word_out, tw);

	} else {
		do_output = 0;
	}

	if (ctx->miso_port != 0 && data_in != NULL) {
		uint32_t first_input_time;
		do_input = 1;
		first_input_time = start_time + (len >= 4 ? 32 : len * 8) + ctx->miso_sample_delay - 1;
		port_set_trigger_time(ctx->miso_port, first_input_time);
	} else {
		do_input = 0;
	}

	clock_start(ctx->clock_block);

#if CS_AUTO_ASSERT
	spi_io_port_sync(ctx->cs_port);
#endif

	/*
	 * Step one of the attempt to stop the clock on the last byte
	 * at precisely the right time. The clock should get stopped
	 * two SCLK cycles after this output completes, hence the -2.
	 */
	port_out_at_time(ctx->cs_port, start_time + 8 * len - 2, ctx->cs_assert_val);

	/*
	 * Each iteration of this loop must execute within
	 * no more than 8 SCLK cycles.
	 */
	if (word_count >= 1) {
		for (i = 1; i < word_count; i++) {
			if (do_output) {
				if (do_output == 1) {
					word_out = build_word(data_out, i * sizeof(uint32_t));
				} else if (do_output == 2) {
					word_out = 0;
				}
				port_out(ctx->mosi_port, word_out);
			}
			if (do_input) {
				save_word(data_in, port_in(ctx->miso_port), (i - 1) * sizeof(uint32_t));
			}
		}

		if (remainder > 0) {
			if (do_output) {
				if (do_output == 1) {
					word_out = build_partial_word(data_out, remainder, i * sizeof(uint32_t));
				} else if (do_output == 2) {
					word_out = 0;
				}
				spi_io_port_outpw(ctx->mosi_port, word_out, remainder * 8);
			}

			if (do_input) {
				word_in = port_in(ctx->miso_port);
				spi_io_port_shift_count(ctx->miso_port, remainder * 8);
				//save_word(data_in, word_in, (i - 1) * sizeof(uint32_t));
			}
		}
	}

	/*
	 * Attempt to stop the clock at precisely the right time.
	 *
	 * 1) Output another '0' on CS two cycles before the end of
	 *    the transaction. This is done above.
	 * 2) Wait for this to complete with sync. This will return
	 *    1 full SCLK cycle after the '0' is output.
	 * 3) Stop the clock. This will take one full SCLK cycle.
	 */
	spi_io_port_sync(ctx->cs_port);
	//port_set_inout_data(ctx->sclk_port);
	clock_stop(ctx->clock_block);

	/*
	 * Set the clock port back to data and outputting 0. (keep invert on if CPOL is 1).
	 * Turn the clock back on.
	 * This will let the last port_in() complete for certain mode and delay combinations.
	 * Then turn the clock off.
	 * Set the clock port back to outputting the clock.
	 */
	//port_set_inout_data(ctx->sclk_port);
	//clock_start(ctx->clock_block);

	/*
	 * Set the CS port's clock back to the reference clock
	 */
	port_set_clock(ctx->cs_port, XS1_CLKBLK_REF);

#if CS_AUTO_ASSERT
	port_out(ctx->cs_port, ctx->cs_deassert_val);
#endif

	if (word_count >= 1 && remainder > 0 && do_input) {
		save_word(data_in, word_in, (i - 1) * sizeof(uint32_t));
	}

	if (do_input) {
		if (remainder > 0) {
			save_partial_word(data_in, port_in(ctx->miso_port), remainder, (i - 1) * sizeof(uint32_t));
		} else {
			save_word(data_in, port_in(ctx->miso_port), (i - 1) * sizeof(uint32_t));
		}
	}

	//clock_stop(ctx->clock_block);
	//port_set_out_clock(ctx->sclk_port);
}

#endif

#if 0
__attribute__((always_inline))
inline void spi_master_transfer(const spi_master_t *ctx,
                            const uint8_t *data_out,
                            uint8_t *data_in)
{
	int i;
	int do_input;
	int do_output;
	uint32_t word_out;
	uint32_t start_time = 1;
	size_t len = ctx->transaction_length;

	if (len == 0) {
		return;
	}

	port_set_trigger_time(ctx->cs_port, start_time);
	port_out(ctx->cs_port, 0);

	if (ctx->mosi_port != 0) {
		if (data_out != NULL) {
			word_out = byterev(bitrev(data_out[0]));
			do_output = 1;
		} else {
			word_out = 0;
			do_output = 2;
		}

		port_set_trigger_time(ctx->mosi_port, start_time);
		spi_io_port_shift_count(ctx->mosi_port, 8);
		port_out(ctx->mosi_port, word_out);
	} else {
		do_output = 0;
	}

	if (ctx->miso_port != 0 && data_in != NULL) {
		do_input = 1;
		port_set_trigger_time(ctx->miso_port, 8 + ctx->miso_sample_delay);
	} else {
		do_input = 0;
	}

	clock_start(ctx->clock_block);

	/*
	 * Each iteration of this loop must execute within
	 * no more than 8 SCLK cycles.
	 */
	for (i = 1; i < len; i++) {
		if (do_output) {
			if (do_output == 1) {
				word_out = byterev(bitrev(data_out[i]));
			} else if (do_output == 2) {
				word_out = 0;
			}
			spi_io_port_outpw(ctx->mosi_port, word_out, 8);
		}
		if (do_input) {
			data_in[i-1] = byterev(bitrev(port_in(ctx->miso_port)));
			spi_io_port_shift_count(ctx->miso_port, 8);
		}
	}

	/*
	 * Attempt to stop the clock at precisely the right time.
	 *
	 * 1) Output another '0' on CS two cycles before the end of
	 *    the transaction.
	 * 2) Wait for this to complete with sync. This will return
	 *    1 full SCLK cycle after the '0' is output.
	 * 3) Stop the clock. This will take one full SCLK cycle.
	 */
	port_out_at_time(ctx->cs_port, start_time + 8 * len - 2, 0);
	spi_io_port_sync(ctx->cs_port);
	clock_stop(ctx->clock_block);

	/*
	 * Now deassert CS. Its clock needs to be set back to the
	 * reference clock since SCLK has been stopped.
	 */
	port_set_clock(ctx->cs_port, XS1_CLKBLK_REF);
	port_out(ctx->cs_port, 1);
	spi_io_port_sync(ctx->cs_port);

	/*
	 * Now set the CS port's clock back to the SPI clock block.
	 */
	port_set_clock(ctx->cs_port, ctx->clock_block);

	if (do_input) {
		data_in[i-1] = byterev(bitrev(port_in(ctx->miso_port)));
	}
}
#endif
