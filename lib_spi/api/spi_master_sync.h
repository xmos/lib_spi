// Copyright 2025 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.


/** This interface allows clients to interact with SPI master task. */
#ifndef __DOXYGEN__
typedef interface spi_master_if {
#endif

  /**
   * @defgroup spi_master_if
   * Methods for synchronous SPI master interface.
   * @{
   */

  /** Begin a transaction.
   *
   *  This will start a transaction on the bus. During a transaction, no
   *  other client to the SPI component can send or receive data. If
   *  another client is currently using the component then this call
   *  will block until the bus is released.
   *
   *  \param device_index  The index of the slave device to interact with.
   *  \param speed_in_khz  The speed that the SPI bus should run at during
   *                       the transaction (in kHZ). When using the version
   *                       with clockblock, the minimum speed is 100 kHz.
   *  \param mode          The mode of spi transfers during this transaction.
   */
  [[guarded]]
  void begin_transaction(unsigned device_index,
                         unsigned speed_in_khz, spi_mode_t mode);

  /** @fn void master_sync::end_transaction(unsigned ss_deassert_time)
   *  End a transaction.
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

  /** Transfer a byte over the SPI bus.
   *
   *  This function will transmit and receive 8 bits of data over the SPI
   *  bus. The data will be transmitted least-significant bit first.
   *
   *  \param data    The data to transmit the MOSI port.
   *
   *  \returns       The data read in from the MISO port.
   */
  uint8_t transfer8(uint8_t data);

  /** Transfer a 32-bit word over the SPI bus.
   *
   *  This function will transmit and receive 32 bits of data over the SPI
   *  bus. The data will be transmitted least-significant bit first and 
   *  most significant byte first (big endian)
   *
   *  \param data    The data to transmit the MOSI port.
   *
   *  \returns       The data read in from the MISO port.
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

/**@}*/ // end spi_master_if

/** Task that implements the SPI proctocol in master mode that is
    connected to a multiple slaves on the bus.

    Each slave must be connected to using the same SPI mode.

    You can access different slave devices over the interface connection
    using the device_index parameter of the interface functions.
    The task will allocate the device indices in the order of the supplied
    array of slave select ports.

    \param i             An array of interface connection to the
                         clients of the task.
    \param num_clients   The number of clients connected to the task.
    \param clk           a clock block used by the task.
    \param sclk          The SPI clock port.
    \param mosi          The SPI MOSI (master out, slave in) port.
    \param miso          The SPI MISO (master in, slave out) port.
    \param p_ss          A port connected to the slave select signals
                         of the slave. Multiple slaves may be supported
                         by specifying, for example, a 4-bit port.
                         Please specify mapping of bits to slaves using
                         i.set_ss_port_bit().
    \param num_slaves    The number of slave devices on the bus.
    \param clk           A clock for the component to use. May be set
                         to null if low speed operation is acceptable.
*/
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
