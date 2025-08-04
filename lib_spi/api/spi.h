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
#define async_master_shutdown shutdown
#define async_master_send_stop_bit send_stop_bit
#define async_master_read read
#define async_master_write write
#define slave_void  slave void
#define static_const_size_t static const size_t
#define static_const_spi_mode_t static const spi_mode_t
#define static_const_spi_transfer_type_t static const spi_transfer_type_t
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
 *  nominally 10 ns. The maximum setting is 65535 which equates to 655 us 
 *  over which the setting will overflow back to zero */
typedef struct spi_master_ss_clock_timing_t {
  uint32_t cs_to_clk_delay_ticks;
  uint32_t clk_to_cs_delay_ticks;
} spi_master_ss_clock_timing_t;


/** This type contains timing settings for capturing the MISO pin.
 *  When the SPI clock is above 20MHz it is usually necessary to delay the
 *  sampling of the MISO pin. These settings can be coarse grained using
 *  miso_sample_delay setting which increments in SPI half clocks or
 *  fine grained in units of core clock (eg. 600MHz) using the
 *  miso_pad_delay setting.
 *  
 *  See the following document for details on xcore.ai port timing:
 *  https://www.xmos.com/documentation/XM-014231-AN/html/rst/index.html */
typedef struct spi_master_miso_capture_timing_t {
  spi_master_sample_delay_t miso_sample_delay;
  uint32_t miso_pad_delay;
} spi_master_miso_capture_timing_t;


/** This interface allows clients to interact with SPI master task. */
#ifndef __DOXYGEN__
typedef interface spi_master_if {
#endif

  /**
   * \addtogroup spi_master_if
   * @{
   */

  /** Begin a transaction.
   *
   *  This will start a transaction on the bus. During a transaction, no
   *  other client to the SPI component can send or receive data. If
   *  another client is currently using the component then this call
   *  will block until the bus is released.
   *
   *  \param device_index  the index of the slave device to interact with.
   *  \param speed_in_khz  The speed that the SPI bus should run at during
   *                       the transaction (in kHZ). When using the version
   *                       with clockblock, the minimum speed is 100 kHz.
   *  \param mode          The mode of spi transfers during this transaction.
   */
  [[guarded]]
  void begin_transaction(unsigned device_index,
                         unsigned speed_in_khz, spi_mode_t mode);

  /** End a transaction.
   *
   *  This ends a transaction on the bus and releases the component to other
   *  clients.
   *
   *  \param ss_deassert_time  The minimum time in reference clock ticks between
   *                           assertions of the selected slave select. This
   *                           time will be ignored if the next transaction is
   *                           to a different slave select.
   */
  void end_transaction(unsigned ss_deassert_time);

  /** Transfer a byte over the spi bus.
   *
   *  This function will transmit and receive 8 bits of data over the SPI
   *  bus. The data will be transmitted least-significant bit first.
   *
   *  \param data    the data to transmit the MOSI port.
   *
   *  \returns       the data read in from the MISO port.
   */
  uint8_t transfer8(uint8_t data);

  /** Transfer a 32-bit word over the spi bus.
   *
   *  This function will transmit and receive 32 bits of data over the SPI
   *  bus. The data will be transmitted least-significant bit first and 
   *  most significant byte first (big endian)
   *
   *  \param data    the data to transmit the MOSI port.
   *
   *  \returns       the data read in from the MISO port.
   */
  uint32_t transfer32(uint32_t data);

  /** Transfer an array of bytes over the SPI interface.
   *
   *  This function will transmit and receive 32 bits of data over the SPI
   *  bus. The data will be transmitted least-significant bit first in byte
   *  order in memory. Note that XMOS uses little endian and so 32b data etc.
   *  may need byteswap() first.
   *
   *  \param data_out    Reference to data to transmit the MOSI port. May be null
   *                     if only a read is needed.
   *  \param data_in     Reference to data to receive from the MISO port. May be 
   *                     null if only a write is needed.
   *  \param num_bytes   Constant value of the size of the array to be transferred.
   *
   */
  void transfer_array(NULLABLE_ARRAY_OF(const uint8_t, data_out), NULLABLE_ARRAY_OF(uint8_t, data_in), static_const_size_t num_bytes);

  /** Sets the bit of port which is used for slave select (> 1b port type only)
   *  and only for spi_master. spi_master sets all bits in each port high/low
   *
   *  The default value (if this is not called) is the bit number is equal to 
   *  the device_index (device 0-> bit 0, device 1-> bit 1 etc.). 
   *
   *  \param device_index  The index of the device for which the port bit is to be set.
   *  \param ss_port_bit   Which bit number in the port to use for slave select.
   */
  void set_ss_port_bit(unsigned device_index, unsigned ss_port_bit);

  /** Configures the timing parameters for MISO capture. At frequencies above 20 MHz
   *  it is likely that some capture delays will need to be introduced to ensure
   *  setup and hold times are met.
   *  These settings only affect the fast SPI master which uses a clock block. 
   * 
   *  See the following document for details on xcore.ai port timing:
   *  https://www.xmos.com/documentation/XM-014231-AN/html/rst/index.html
   *
   *  \param device_index         The index of the device for which the MISO timing is to be set.
   *  \param miso_capture_timing  A structure of type spi_master_miso_capture_timing_t with
   *                              the desired settings.
   */
  void set_miso_capture_timing(unsigned device_index, spi_master_miso_capture_timing_t miso_capture_timing);

  /** Configures the timing settings for SS assert to clock delay, and last 
   *  clock to SS de-assert delay. The unit is reference timer ticks which is 
   *  nominally 10 ns. The maximum setting is 65535 which equates to 655 us 
   *  over which the setting will overflow back to zero.
   *  These settings only affect the fast SPI master which uses a clock block.
   * 
   *  \param device_index     The index of the device for which the SS timing is to be set.
   *  \param ss_clock_timing  A structure of type spi_master_ss_clock_timing_t with
   *                          the desired settings.
   */
  void set_ss_clock_timing(unsigned device_index, spi_master_ss_clock_timing_t ss_clock_timing);

  /** Shut down the SPI master interface server.
   */
  void shutdown(void);

#ifndef __DOXYGEN__
} spi_master_if;
#endif

/**@}*/ // END: addtogroup spi_master_if


[[distributable]]
void spi_master(
        SERVER_INTERFACE(spi_master_if, i[num_clients]),
        static_const_size_t num_clients,
        out_buffered_port_32_t sclk,
        NULLABLE_RESOURCE(out_buffered_port_32_t, mosi),
        NULLABLE_RESOURCE(in_buffered_port_32_t, miso),
        out_port p_ss,
        static_const_size_t num_slaves,
        NULLABLE_RESOURCE(clock, clk));

/** Task that implements the SPI proctocol in master mode that is
    connected to a multiple slaves on the bus.

    Each slave must be connected to using the same SPI mode.

    You can access different slave devices over the interface connection
    using the device_index parameter of the interface functions.
    The task will allocate the device indices in the order of the supplied
    array of slave select ports.

    \param i             an array of interface connection to the
                         clients of the task.
    \param num_clients   the number of clients connected to the task.
    \param clk           a clock block used by the task.
    \param sclk          the SPI clock port.
    \param mosi          the SPI MOSI (master out, slave in) port.
    \param miso          the SPI MISO (master in, slave out) port.
    \param p_ss          A port connected to the slave select signals
                         of the slave. Multiple slaves may be supported
                         by specifying, for example, a 4-bit port.
                         Please specify mapping of bits to slaves using
                         i.set_ss_port_bit()
    \param num_slaves    The number of slave devices on the bus.
    \param clk           a clock for the component to use.
*/

/**
 * \addtogroup spi_master_async_if
 * @{
 */

/** Asynchronous interface to an SPI component.
 *
 *  This interface allows programs to offload SPI bus transfers to another
 *  task. An asynchronous notification occurs when the transfer is complete.
 */
#ifndef __DOXYGEN__
typedef interface spi_master_async_if  {
#endif
  /** Begin a transaction.
   *
   *  This will start a transaction on the bus. During a transaction, no
   *  other client to the SPI component can send or receive data. If
   *  another client is currently using the component then this call
   *  will block until the bus is released.
   *
   *  \param device_index  the index of the slave device to interact with.
   *  \param speed_in_khz  The speed that the SPI bus should run at during
   *                       the transaction (in kHZ). The minimum speed is 100 kHz.
   *  \param mode          The mode of spi transfers during this transaction
   */
  void begin_transaction(unsigned device_index,
                         unsigned speed_in_khz, spi_mode_t mode);

  /** End a transaction.
   *
   *  This ends a transaction on the bus and releases the component to other
   *  clients.
   *
   *  \param ss_deassert_time  The minimum time in reference clock ticks between
   *                           assertions of the selected slave select. This
   *                           time will be ignored if the next transaction is
   *                           to a different slave select.
   */
  void end_transaction(unsigned ss_deassert_time);

  /** Initialize Transfer an array of bytes over the spi bus.
   *
   *  This function will initialize a transmit of 8 bit data
   *  over the SPI bus.
   *
   *  \param inbuf    A *movable* pointer that is moved to the other task
   *                  pointing to the buffer area to fill with data. If this
   *                  parameter is NULL then the incoming data of the transfer
   *                  will be discarded.
   *  \param outbuf   A *movable* pointer that is moved to the other task
   *                  pointing to the buffer area to with data to transmit.
   *                  If this parameter is NULL then the outgoing data of the
   *                  transfer will consist of undefined values.
   *  \param nbytes   The number of bytes to transfer over the bus.
   */
  void init_transfer_array_8(uint8_t_movable_ptr_t inbuf,
                             uint8_t_movable_ptr_t outbuf,
                             size_t nbytes);

  /** Initialize Transfer an array of bytes over the spi bus.
   *
   *  This function will initialize a transmit of 32 bit data
   *  over the SPI bus.
   *
   *  \param inbuf    A *movable* pointer that is moved to the other task
   *                  pointing to the buffer area to fill with data. If this
   *                  parameter is NULL then the incoming data of the transfer
   *                  will be discarded.
   *  \param outbuf   A *movable* pointer that is moved to the other task
   *                  pointing to the buffer area to with data to transmit.
   *                  If this parameter is NULL then the outgoing data of the
   *                  transfer will consist of undefined values.
   *  \param nwords   The number of words to transfer over the bus.
   */
  void init_transfer_array_32(uint32_t_movable_ptr_t inbuf,
                              uint32_t_movable_ptr_t outbuf,
                              size_t nwords);

  /** Transfer completed notification.
   *
   *  This notification occurs when a transfer is completed.
   */
  [[notification]]
  slave void transfer_complete(void);

  /** Retrieve transfer buffers.
   *
   *  This function should be called after the transfer_complete() notification
   *  and will return the buffers given to the other task by
   *  init_transfer_array_8().
   *
   *  \param inbuf    A movable pointer that will be set to the buffer
   *                  pointer that was filled during the transfer.
   *  \param outbuf   A movable pointer that will be set to the buffer
   *                  pointer that was transmitted during the transfer.
   */
  [[clears_notification]]
  void retrieve_transfer_buffers_8(REFERENCE_PARAM(uint8_t_movable_ptr_t, inbuf),
                                   REFERENCE_PARAM(uint8_t_movable_ptr_t, outbuf));


  /** Retrieve transfer buffers.
   *
   *  This function should be called after the transfer_complete() notification
   *  and will return the buffers given to the other task by
   *  init_transfer_array_32().
   *
   *  \param inbuf    A movable pointer that will be set to the buffer
   *                  pointer that was filled during the transfer.
   *  \param outbuf   A movable pointer that will be set to the buffer
   *                  pointer that was transmitted during the transfer.
   */
  [[clears_notification]]
  void retrieve_transfer_buffers_32(REFERENCE_PARAM(uint32_t_movable_ptr_t, inbuf),
                                    REFERENCE_PARAM(uint32_t_movable_ptr_t, outbuf));

  /** Sets the bit of port which is used for slave select (> 1b port type only)
   *  and only for spi_master. spi_master sets all bits in each port high/low
   *
   *  The default value (if this is not called) is the bit number is equal to 
   *  the device_index (0->0, 1->1 etc.). 
   *
   *  \param device_index  The index of the device for which the port bit is to be set.
   *  \param ss_port_bit   Which bit number in the port to use for slave select.
   */
  void set_ss_port_bit(unsigned device_index, unsigned ss_port_bit);

   /** Configures the timing parameters for MISO capture. At frequencies above 20 MHz
   *  it is likely that some capture delays will need to be introduced to ensure
   *  setup and hold times are met.
   * 
   *  See the following document for details on xcore.ai port timing:
   *  https://www.xmos.com/documentation/XM-014231-AN/html/rst/index.html
   *
   *  \param device_index         The index of the device for which the MISO timing is to be set.
   *  \param miso_capture_timing  A structure of type spi_master_miso_capture_timing_t with
   *                              the desired settings.
   */
  void set_miso_capture_timing(unsigned device_index, spi_master_miso_capture_timing_t miso_capture_timing);

  /** Configures the timing settings for SS assert to clock delay, and last 
   *  clock to SS de-assert delay. The unit is reference timer ticks which is 
   *  nominally 10 ns. The maximum setting is 65535 which equates to 655 us 
   *  over which the setting will overflow back to zero.
   * 
   *  \param device_index     The index of the device for which the SS timing is to be set.
   *  \param ss_clock_timing  A structure of type spi_master_ss_clock_timing_t with
   *                          the desired settings.
   */
  void set_ss_clock_timing(unsigned device_index, spi_master_ss_clock_timing_t ss_clock_timing);

  /** Shut down the SPI master interface server.
   */
  void shutdown(void);

  /**@}*/ // END: addtogroup spi_master_async_if

#ifndef __DOXYGEN__
} spi_master_async_if;
#endif

/** SPI master component for asynchronous API.
 *
 * This component implements SPI and allows a client to connect using the
 * asynchronous SPI master interface.
 *
 *  \param i             an array of interface connection to the
 *                       clients of the task.
 *  \param num_clients   the number of clients connected to the task.
 *  \param sclk          the SPI clock port.
 *  \param mosi          the SPI MOSI (master out, slave in) port.
 *  \param miso          the SPI MISO (master in, slave out) port.
 *  \param p_ss          a port of any width which outputs the slave select signals
 *  \param num_slaves    The number of slave devices on the bus.
 *  \param clk           a clock block for the component to use.
 */
[[combinable]]
void spi_master_async(
        SERVER_INTERFACE(spi_master_async_if, i[num_clients]),
        static_const_size_t num_clients,
        out_buffered_port_32_t sclk,
        NULLABLE_RESOURCE(out_buffered_port_32_t, mosi),
        in_buffered_port_32_t miso,
        out_port p_ss,
        static_const_size_t num_slaves,
        clock clk);

/**** SLAVE ****/

/**
 * \addtogroup spi_slave_callback_if
 * @{
 */

/** This interface allows clients to interact with SPI slave tasks by
 *  completing callbacks that show how to handle data.
 */
#ifndef __DOXYGEN__
typedef interface spi_slave_callback_if {
#endif

  /** This callback will get called when the master de-asserts on the slave
   *  select line to end a transaction.
   */
  void master_ends_transaction(void);

  /** This callback will get called when the master initiates a bus transfer
   *  or when more data is required during a transaction.
   *  The application must supply the data to transmit to the master. If
   *  the spi slave component is set to ``SPI_TRANSFER_SIZE_32`` mode then
   *  this callback will not be called and master_requires_data32() will
   *  be called instead. Data is transmitted for the least significant bit
   *  first.  If the master completes the transaction before 8 bits are
   *  transferred the remaining bits are discarded.
   *
   *  \returns the 8-bit value to transmit.
   */
  uint32_t master_requires_data(void);

  /** This callback will get called after a transfer. It will occur after
   *  every 8 bits transferred if the slave component is set to
   *  ``SPI_TRANSFER_SIZE_8``. If the component is set to
   *  ``SPI_TRANSFER_SIZE_32`` then it will occur if the master ends the
   *  transaction before 32 bits are transferred.
   *
   *  \param datum the data received from the master.
   *  \param valid_bits the number of valid bits of data received from the master.
   */
  void master_supplied_data(uint32_t datum, uint32_t valid_bits);

  /** Request shut down the SPI slave interface client.
   */
  [[notification]]
  slave void request_shutdown(void);

  /** Acknowledgment that the SPI slave task has been shutdown.
   */
  [[clears_notification]]
  [[guarded]]
  void shutdown_complete(void);

#ifndef __DOXYGEN__
} spi_slave_callback_if;
#endif

  /**@}*/ // END: addtogroup spi_slave_callback_if


/** This type specifies the transfer size from the SPI slave component
    to the application */
typedef enum spi_transfer_type_t {
  SPI_TRANSFER_SIZE_8, ///< Transfers should by 8-bit.
  SPI_TRANSFER_SIZE_32 ///< Transfers should be 32-bit.
} spi_transfer_type_t;

/** SPI slave component.
 *
 *  This function implements an SPI slave bus.
 *
 *  \param spi_i   The interface to connect to the user of the component.
 *             The component acts as the client and will make callbacks to
 *             the application.
 *  \param p_sclk        the SPI clock port.
 *  \param p_mosi        the SPI MOSI (master out, slave in) port.
 *  \param p_miso        the SPI MISO (master in, slave out) port.
 *  \param p_ss          the SPI SS (slave select) port.
 *  \param clk           clock to be used by the component.
 *  \param mode          the SPI mode of the bus.
 *  \param transfer_type the type of transfer the slave will perform: either
 *                       ``SPI_TRANSFER_SIZE_8`` or ``SPI_TRANSFER_SIZE_32``.
 */
 [[combinable]]
  void spi_slave(CLIENT_INTERFACE(spi_slave_callback_if, spi_i),
                 in_port p_sclk,
                 in_buffered_port_32_t p_mosi,
                 NULLABLE_RESOURCE(out_buffered_port_32_t, p_miso),
                 in_port p_ss,
                 clock clk,
                 static_const_spi_mode_t mode,
                 static_const_spi_transfer_type_t transfer_type);

#endif // _spi_h_
