// Copyright 2021-2025 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.
#pragma once

/** \file
 *  \brief API for SPI I/O
 */

/**
 * The minimum number of clock ticks that should
 * be specified for any SPI master delay value.
 */
#define SPI_MASTER_MINIMUM_DELAY 10

#include <stdlib.h> /* for size_t */
#include <stdint.h>
#include <xclib.h> /* for byterev() */
#include <xccompat.h>
#ifndef __XC__
#include <xcore/assert.h>
#include <xcore/port.h>
#include <xcore/clock.h>
#include <xcore/thread.h>
#else
#define xclock_t clock
#define port_t port
#define thread_mode_t int
#endif

/* The SETC constant for pad delay is missing from xs2a_user.h */
#define SPI_IO_SETC_PAD_DELAY(n) (0x7007 | ((n) << 3))

/* These appear to be missing from the public API of lib_xcore */
#define SPI_IO_RESOURCE_SETCI(res, c) asm volatile( "setc res[%0], %1" :: "r" (res), "n" (c))
#define SPI_IO_RESOURCE_SETC(res, r) asm volatile( "setc res[%0], %1" :: "r" (res), "r" (r))

/* is setpsc available in lib_xcore or anywhere else..??? */
#ifndef __XC__
__attribute__((always_inline))
inline void spi_io_port_outpw(
        resource_t __p,
        uint32_t __w,
        uint32_t __bpw)
{
    asm volatile("outpw res[%0], %1, %2" : : "r" (__p), "r" (__w), "r" (__bpw));
}
#endif

/**
 * \addtogroup hil_spi_master hil_spi_master
 *
 * The public API for using the HIL SPI master.
 * @{
 */

/**
 * Enum type representing the different options
 * for the SPI master sample delay.
 */
typedef enum {
    spi_master_sample_delay_0 = 0, /**< Samples 1/2 clock cycle after output from device */
    spi_master_sample_delay_1 = 1, /**< Samples 3/4 clock cycle after output from device */
    spi_master_sample_delay_2 = 2, /**< Samples 1 clock cycle after output from device */
    spi_master_sample_delay_3 = 3, /**< Samples 1 and 1/4 clock cycle after output from device */
    spi_master_sample_delay_4 = 4, /**< Samples 1 and 1/2 clock cycle after output from device */
} spi_master_sample_delay_t;

/**
 * Enum type used to set which of the two clock sources SCLK is derived from.
 */
typedef enum {
    spi_master_source_clock_ref = 0, /**< SCLK is derived from the 100 MHz reference clock */
    spi_master_source_clock_xcore    /**< SCLK is derived from the core clock */
} spi_master_source_clock_t;

/**
 * Struct to hold a SPI master context.
 *
 * The members in this struct should not be accessed directly.
 */
typedef struct {
    xclock_t clock_block;
    port_t cs_port;
    port_t sclk_port;
    port_t mosi_port;
    port_t miso_port;
    uint32_t current_device;
    int delay_before_transfer;
} spi_master_t;

/**
 * Struct type representing a SPI device connected to a SPI master
 * interface.
 *
 * The members in this struct should not be accessed directly.
 */
typedef struct {
    spi_master_t *spi_master_ctx;
    spi_master_source_clock_t source_clock;
    int clock_divisor;
    spi_master_sample_delay_t miso_sample_delay;
    uint32_t miso_pad_delay;
    uint32_t miso_initial_trigger_delay;
    uint32_t cs_assert_val;
    uint32_t clock_delay;
    uint32_t clock_bits;
    uint32_t cs_to_clk_delay_ticks;
    uint32_t clk_to_cs_delay_ticks;
    uint32_t cs_to_cs_delay_ticks;
    thread_mode_t thread_mode;
} spi_master_device_t;

/**
 * Initializes a SPI master I/O interface.
 *
 * Note: To guarantee timing in all situations, the SPI I/O interface
 * implicitly sets the fast mode and high priority status register bits
 * for the duration of SPI operations.  This may reduce the MIPS of other
 * threads based on overall system setup.
 *
 * \param spi         The spi_master_t context to initialize.
 * \param clock_block The clock block to use for the SPI master interface.
 * \param cs_port     The SPI interface's chip select port. This may be a multi-bit port.
 * \param sclk_port   The SPI interface's SCLK port. Must be a 1-bit port.
 * \param mosi_port   The SPI interface's MOSI port. Must be a 1-bit port.
 * \param miso_port   The SPI interface's MISO port. Must be a 1-bit port.
 */
void spi_master_init(
        spi_master_t *spi,
        xclock_t clock_block,
        port_t cs_port,
        port_t sclk_port,
        port_t mosi_port,
        port_t miso_port);

/**
 * Initialize a SPI device. Multiple SPI devices may be initialized per SPI interface.
 * Each must be on a unique pin of the interface's chip select port.
 *
 * \param dev                   The context representing the device to initialize.
 * \param spi                   The context representing the SPI master interface that the device is connected to.
 * \param cs_pin                The bit number of the chip select port that is connected to the device's chip select pin.
 * \param cpol                  The clock polarity required by the device.
 * \param cpha                  The clock phase required by the device.
 * \param source_clock          The source clock to derive SCLK from. See spi_master_source_clock_t.
 * \param clock_divisor         The value to divide the source clock by.
 *                              The frequency of SCLK will be set to:
 *                               - (F_src) / (4 * clock_divisor) when clock_divisor > 0
 *                               - (F_src) / (2)                 when clock_divisor = 0
 *                              Where F_src is the frequency of the source clock.
 * \param miso_sample_delay     When to sample MISO. See spi_master_sample_delay_t.
 * \param miso_pad_delay        The number of core clock cycles to delay sampling the MISO pad during
 *                              a transaction. This allows for more fine grained adjustment
 *                              of sampling time. The value may be between 0 and 5.
 * \param cs_to_clk_delay_ticks The minimum number of reference clock ticks between assertion of chip select
 *                              and the first clock edge.
 * \param clk_to_cs_delay_ticks The minimum number of reference clock ticks between the last clock edge and
 *                              de-assertion of chip select.
 * \param cs_to_cs_delay_ticks  The minimum number of reference clock ticks between transactions, which is between
 *                              de-assertion of chip select and the end of one transaction, and its re-assertion at
 *                              the beginning of the next.
 */
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

/**
 * Starts a SPI transaction with the specified SPI device. This leaves chip select asserted.
 *
 * \param dev The SPI device with which to start a transaction.
 */
void spi_master_start_transaction(
        spi_master_device_t *dev);

/**
 * Transfers data to/from the specified SPI device. This may be called
 * multiple times during a single transaction.
 *
 * \param dev      The SPI device with which to transfer data.
 * \param data_out Buffer containing the data to send to the device.
 *                 May be NULL if no data needs to be sent.
 * \param data_in  Buffer to save the data received from the device.
 *                 May be NULL if the data received is not needed.
 * \param len      The length in bytes of the data to transfer. Both
 *                 buffers must be at least this large if not NULL.
 */
void spi_master_transfer(
        spi_master_device_t *dev,
        uint8_t *data_out,
        uint8_t *data_in,
        size_t len);

#ifndef __XC__
/**
 * Enforces a minimum delay between the time this is called and
 * the next transfer. It must be called during a transaction.
 * It returns immediately.
 *
 * \param dev         The active SPI device.
 * \param delay_ticks The number of reference clock ticks to delay.
 */
static inline void spi_master_delay_before_next_transfer(
        spi_master_device_t *dev,
        uint32_t delay_ticks)
{
    spi_master_t *spi = dev->spi_master_ctx;

    spi->delay_before_transfer = 1;

    port_clear_trigger_time(spi->cs_port);

    /* Assert CS now */
    port_out(spi->cs_port, dev->cs_assert_val);
    port_sync(spi->cs_port);

    /*
     * Assert CS again, scheduled for earliest time the
     * next transfer is allowed to start.
     */
    if (delay_ticks >= SPI_MASTER_MINIMUM_DELAY) {
        port_out_at_time(spi->cs_port, port_get_trigger_time(spi->cs_port) + delay_ticks, dev->cs_assert_val);
    }
}
#endif
/**
 * Ends a SPI transaction with the specified SPI device. This leaves chip select de-asserted.
 *
 * \param dev The SPI device with which to end a transaction.
 */
void spi_master_end_transaction(
        spi_master_device_t *dev);

/**
 * De-initializes the specified SPI master interface. This disables the
 * ports and clock block.
 *
 * \param spi The spi_master_t context to de-initialize.
 */
void spi_master_deinit(
        spi_master_t *spi);

#ifndef __XC__
/**
 * Master has started a transaction
 *
 * This callback function will be called when the SPI master has asserted
 * this slave's chip select.
 *
 * The input and output buffer may be the same; however, partial byte/incomplete
 * reads will result in out_buf bits being masked off due to a partial bit output.
 *
 * \param app_data   A pointer to application specific data provided
 *                   by the application. Used to share data between
 * \param out_buf    The buffer to send to the master
 * \param outbuf_len The length in bytes of out_buf
 * \param in_buf     The buffer to receive into from the master
 * \param inbuf_len  The length in bytes of in_buf
 */
typedef void (*slave_transaction_started_t)(void *app_data, uint8_t **out_buf, size_t *outbuf_len, uint8_t **in_buf, size_t *inbuf_len);

/**
 * Master has ended a transaction
 *
 * This callback function will be called when the SPI master has de-asserted
 * this slave's chip select.
 *
 * The value of bytes_read contains the number of full bytes that are in
 * in_buf.  When read_bits is greater than 0, the byte after the last full byte
 * contains the partial bits read.
 *
 * \param app_data      A pointer to application specific data provided
 *                      by the application. Used to share data between
 * \param out_buf       The buffer that had been provided to be sent to the master
 * \param bytes_written The length in bytes of out_buf that had been written
 * \param in_buf        The buffer that had been provided to be received into from the master
 * \param bytes_read    The length in bytes of in_buf that has been read in to
 * \param read_bits     The length in bits of in_buf
 */
typedef void (*slave_transaction_ended_t)(void *app_data, uint8_t **out_buf, size_t bytes_written, uint8_t **in_buf, size_t bytes_read, size_t read_bits);

/**
 * This attribute must be specified on all SPI callback functions
 * provided by the application.
 */
#define SPI_CALLBACK_ATTR __attribute__((fptrgroup("spi_callback")))

/**@}*/ // END: addtogroup hil_spi_master


#endif