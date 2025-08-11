// Copyright 2025 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.


/** This interface allows clients to interact with SPI slave tasks by
 *  completing callbacks that show how to handle data.
 */
#ifndef __DOXYGEN__
typedef interface spi_slave_callback_if {
#endif

  /**
  * @defgroup spi_slave_callback_if
  * Methods for SPI slave interface.
  * @{
  */


  /** This callback will get called when the master de-asserts on the slave
   *  select line to end a transaction.
   */
  void master_ends_transaction(void);

  /** This callback will get called when the master initiates a bus transfer
   *  or when more data is required during a transaction.
   *  The application must supply the data to transmit to the master. 
   *  Data is transmitted with the least significant bit
   *  first.  If the master completes the transaction before 8/32 bits (
   *  depending on SPI_TRANSFER_SIZE_8 or SPI_TRANSFER_SIZE_32) are
   *  transferred and the remaining bits are discarded.
   *
   *  \returns the 8-bit or 32-bit value to transmit.
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

/**@}*/ // end: spi_slave_callback_if


/** This type specifies the transfer size from the SPI slave component
    to the application */
typedef enum spi_transfer_type_t {
  SPI_TRANSFER_SIZE_8, ///< Transfers should be 8-bit.
  SPI_TRANSFER_SIZE_32 ///< Transfers should be 32-bit.
} spi_transfer_type_t;

/** SPI slave component.
 *
 *  This function implements an SPI slave bus.
 *
 *  \param spi_i   		 The interface to connect to the user of the component.
 *             			 The component acts as the client and will make callbacks to
 *             			 the application.
 *  \param p_sclk        The SPI clock port.
 *  \param p_mosi        The SPI MOSI (master out, slave in) port.
 *  \param p_miso        The SPI MISO (master in, slave out) port.
 *  \param p_ss          The SPI SS (slave select) port.
 *  \param clk           Clock to be used by the component.
 *  \param mode          The SPI mode of the bus.
 *  \param transfer_type The type of transfer the slave will perform: either
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
