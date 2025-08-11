// Copyright 2025 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.


/** Asynchronous interface to an SPI component.
 *
 *  This interface allows programs to offload SPI bus transfers to another
 *  task. An asynchronous notification occurs when the transfer is complete.
 */
#ifndef __DOXYGEN__
typedef interface spi_master_async_if  {
#endif
  
  /**
  * @defgroup spi_master_async_if
  * Methods for asynchronous SPI master interface.
  * @{
  */

  /** @fn void master_async::begin_transaction(unsigned device_index,
                              unsigned speed_in_khz, spi_mode_t mode)
   *  Begin a transaction.
   *
   *  This will start a transaction on the bus. During a transaction, no
   *  other client to the SPI component can send or receive data. If
   *  another client is currently using the component then this call
   *  will block until the bus is released.
   *
   *  \param device_index  The index of the slave device to interact with.
   *  \param speed_in_khz  The speed that the SPI bus should run at during
   *                       the transaction (in kHZ). The minimum speed is 100 kHz.
   *  \param mode          The mode of spi transfers during this transaction
   */
  void begin_transaction(unsigned device_index,
                         unsigned speed_in_khz, spi_mode_t mode);

  /** @fn void master_async::end_transaction(unsigned ss_deassert_time)
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

  /** Initialize Transfer an array of bytes over the SPI bus.
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

  /** Initialize Transfer an array of bytes over the SPI bus.
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

  /** Shut down the SPI master interface server. Must be done after all transactions are complete
   *  to avoid leaving moveable pointers in the wrong place.
   */
  void shutdown(void);

/**@}*/ // end spi_master_async_if

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
