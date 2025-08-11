// Copyright 2014-2025 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.
#ifndef _spi_h_
#define _spi_h_
#include <xs1.h>
#include <stdint.h>
#include <stddef.h>
#include <xccompat.h>
extern "C" {
  #include "../src/spi_fwk.h"
}
// These are needed for DOXYGEN to render properly
#ifndef __DOXYGEN__
#define static_const_unsigned static const unsigned
#define static_const_size_t static const size_t
#define out_port out port
#define in_port in port
#define static_const_size_t static const size_t
#define static_const_spi_mode_t static const spi_mode_t
#define static_const_spi_transfer_type_t static const spi_transfer_type_t
#define uint32_t_movable_ptr_t uint32_t * movable
#define uint8_t_movable_ptr_t uint8_t * movable
#endif

/** This type indicates what clocking mode a SPI component should use */
typedef enum spi_mode_t {
  SPI_MODE_0 = 0, /**< SPI Mode 0 - Polarity = 0, Phase = 0 */
  SPI_MODE_1 = 1, /**< SPI Mode 1 - Polarity = 0, Phase = 1 */
  SPI_MODE_2 = 2, /**< SPI Mode 2 - Polarity = 1, Phase = 0 */
  SPI_MODE_3 = 3, /**< SPI Mode 3 - Polarity = 1, Phase = 1 */
} spi_mode_t;


/** This type contains timing settings for SS assert to clock delay and last 
 *  clock to SS de-assert delay. The unit is reference timer ticks which is 
 *  nominally 10 ns. The maximum setting is 65535 which equates to 655 us,
 *  over which the setting will overflow back to zero */
typedef struct spi_master_ss_clock_timing_t {
  uint32_t cs_to_clk_delay_ticks;
  uint32_t clk_to_cs_delay_ticks;
} spi_master_ss_clock_timing_t;


/** This type contains timing settings for capturing the MISO pin for SPI master.
 *  When the SPI clock is above 20MHz it is usually necessary to delay the
 *  sampling of the MISO pin. These settings can be coarse grained using
 *  miso_sample_delay setting which increments in SPI half clocks or
 *  fine grained in units of core clock (eg. 600 MHz -> 1.66 ns) using the
 *  miso_pad_delay setting.
 *  
 *  See the following document for details on xcore.ai port timing:
 *  https://www.xmos.com/documentation/XM-014231-AN/html/rst/index.html */
typedef struct spi_master_miso_capture_timing_t {
  spi_master_sample_delay_t miso_sample_delay;
  uint32_t miso_pad_delay;
} spi_master_miso_capture_timing_t;


#include "spi_master_sync.h"
#include "spi_master_async.h"
#include "spi_slave.h"

#endif // _spi_h_
