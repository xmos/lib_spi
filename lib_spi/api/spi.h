#ifndef _spi_h_
#define _spi_h_

/** This interface allows clients to interact with SPI master task. */
interface spi_master_if {

  /** Begin a transaction.
   *
   *  This will start a transaction on the bus. During a transaction, no
   *  other client to the SPI component can send or receive data. If
   *  another client is currently using the component then this call
   *  will block until the bus is released.
   *
   *  \param speed_in_khz  The speed that the SPI bus should run at during
   *                       the transaction (in kHZ)
   *  \param mode          The mode of spi transfers during this transaction
   */
  [[guarded]]
  void begin_transaction(unsigned speed_in_khz, spi_mode_t mode);

  /** End a transaction.
   *
   *  This ends a transaction on the bus and releases the component to other
   *  clients.
   */
  void end_transaction(void);

  /** Transfer a byte over the spi bus.
   *
   *  This function will transmit and receive 8 bits of data over the SPI
   *  bus.
   *
   *  \param device_index  the index of the slave device to interact with
   *  \param data          the data to transmit the MOSI port
   *
   *  \returns       the data read in from the MISO port
   */
  uint8_t transfer8(unsigned device_index, uint8_t data);

  /** Transfer a 32-bit word over the spi bus.
   *
   *  This function will transmit and receive 32 bits of data over the SPI
   *  bus.
   *
   *  \param device_index  the index of the slave device to interact with
   *  \param data    the data to transmit the MOSI port
   *
   *  \returns       the data read in from the MISO port
   */
  uint32_t transfer32(unsigned device_index, uint32_t data);
};

extends client interface spi_master_if : {
  /** Transfer an array of bytes over the spi bus.
   *
   *  This function will repeatedly transmit and receive 8 bits of data
   *  over the SPI bus.
   *
   *  \param device_index  the index of the slave device to interact with
   *  \param in_data    the array to fill with data from the MOSI port. If this
   *                    parameter is null then the incoming data will be
   *                    ignored.
   *
   *  \param out_data   the array of data to transmit on the MISO port. If this
   *                    parameter is null then the data output during the output
   *                    is undefined.
   */
  void transfer_array_8(client interface spi_master_if i,
                        unsigned device_index,
                        uint8_t (& alias ?in_data)[n],
                        uint8_t (& alias ?out_data)[n],
                        size_t n);

  /** Transfer an array of 32-bit words over the spi bus.
   *
   *  This function will repeatedly transmit and receive 32 bits of data
   *  over the SPI bus.
   *
   *  \param device_index  the index of the slave device to interact with
   *  \param in_data    the array to fill with data from the MOSI port. If this
   *                    parameter is null then the incoming data will be
   *                    ignored.
   *
   *  \param out_data   the array of data to transmit on the MISO port. If this
   *                    parameter is null then the data output during the output
   *                    is undefined.
   */
  void transfer_array_32(client interface spi_master_if i,
                         unsigned device_index,
                         uint32_t (& alias ?in_data)[nwords],
                         uint32_t (& alias ?out_data)[nwords],
                         size_t nwords);
};

/** This type indicates what mode an SPI component should use */
typedef enum spi_mode_t {
  SPI_MODE_0, /**< SPI Mode 0 - Polarity = 0, Clock Edge = 1 */
  SPI_MODE_1, /**< SPI Mode 1 - Polarity = 0, Clock Edge = 0 */
  SPI_MODE_2, /**< SPI Mode 2 - Polarity = 1, Clock Edge = 0 */
  SPI_MODE_3, /**< SPI Mode 3 - Polarity = 1, Clock Edge = 1 */
} spi_mode_t;

/** Task that implements the SPI proctocol in master mode that is
    connected to a single slave on the bus.

    \param i             the interface connection to the client of the task
    \param clk           a clock block used by the task
    \param sclk          the SPI clock port
    \param mosi          the SPI MOSI (master out, slave in) port
    \param miso          the SPI MISO (master in, slave out) port
    \param clk           a clock for the component to use
*/
[[distributable]]
void spi_master_single_slave(server interface spi_master_if i,
                             out port sclk,
                             out port mosi,
                             in port miso,
                             clock clk);


/** Task that implements the SPI proctocol in master mode that is
    connected to a multiple slaves on the bus.

    Each slave must be connected to using the same SPI mode.

    You can access different slave devices over the interface connection
    using the device_index parameter of the interface functions.
    The task will allocate the device indices in the order of the supplied
    array of slave select ports.

    \param i             an array of interface connection to the
                         clients of the task
    \param num_clients   the number of clients connected to the task
    \param clk           a clock block used by the task
    \param sclk          the SPI clock port
    \param mosi          the SPI MOSI (master out, slave in) port
    \param miso          the SPI MISO (master in, slave out) port
    \param p_ss          an array of ports connected to the slave select signals
                         of the slave
    \param num_slaves    The number of slave devices on the bus
    \param clk           a clock for the component to use
*/
[[distributable]]
void spi_master_multi_slave(server interface spi_master_if i[num_clients],
                            size_t num_clients,
                            out port sclk,
                            out port mosi,
                            in port miso,
                            out port p_ss[num_slaves],
                            size_t num_slaves,
                            clock clk);


/** Asynchronous interface to an SPI component.
 *
 *  This interface allows programs to offload SPI bus transfers to another
 *  task. An asynchronous notification occurs when the transfer is complete.
 */
typedef interface spi_master_async_if  {
  /** Initialize Transfer an array of bytes over the spi bus.
   *
   *  This function will initialize a transmit of 8 bit data
   *  over the SPI bus.
   *
   *  \param inbuf    A *movable* pointer that is moved to the other task
   *                  pointing to the buffer area to fill with data. If this
   *                  parameter is NULL then the incoming data of the transfer
   *                  will be discarded.
   *  \param outdata  A *movable* pointer that is moved to the other task
   *                  pointing to the buffer area to with data to transmit.
   *                  If this parameter is NULL then the outgoing data of the
   *                  transfer will consist of undefined values.
   *  \param nbytes   The number of bytes to transfer over the bus.
   */
  void init_transfer_array_8(uint8_t * movable inbuf,
                             uint8_t * movable outbuf,
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
   *  \param outdata  A *movable* pointer that is moved to the other task
   *                  pointing to the buffer area to with data to transmit.
   *                  If this parameter is NULL then the outgoing data of the
   *                  transfer will consist of undefined values.
   *  \param nwords   The number of words to transfer over the bus.
   */
  void init_transfer_array_32(uint8_t * movable inbuf,
                              uint8_t * movable outbuf,
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
  void retrieve_transfer_buffers_8(uint8_t * movable &inbuf,
                                   uint8_t * movable &outbuf);


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
  void retrieve_transfer_buffers_32(uint8_t * movable &inbuf,
                                   uint8_t * movable &outbuf);
} spi_master_async_if;


/** SPI master component for asynchronous API.
 *
 * This component implements SPI and allows a client to connect using the
 * asynchronous SPI master interface.
 *
 *  \param i             the interface connection to the client of the task
 *  \param clk           a clock block used by the task
 *  \param sclk          the SPI clock port
 *  \param mosi          the SPI MOSI (master out, slave in) port
 *  \param miso          the SPI MISO (master in, slave out) port
 *  \param clk           a clock for the component to use
 *  \param speed_in_khz  the speed the bus should operate at (in kHZ)
 *  \param mode          the mode of the bus
 */
[[combinable]]
void spi_master_async(server interface spi_master_async_if i,
                      out port sclk,
                      out port mosi,
                      in port miso,
                      clock clk,
                      unsigned speed_in_khz,
                      spi_mode_t mode);

/**** SLAVE ****/

/** This interface allows clients to interact with SPI slave tasks by
 *  completing callbacks that show how to handle data.
 */
typedef interface spi_slave_callback_if {

  /** This callback will get called when the master initiates a bus transfer.
   *  The application must supply the data to transmit to the master.
   *
   *  \returns the 8-bit value to transmit
   */
  uint8_t master_requires_data(void);

  /** This callback will get called after a transfer.
   *
   *  \param datum the data received from the master
   */
  void master_supplied_data(uint8_t datum);

} spi_slave_if;


/** SPI slave component.
 *
 *  This function implements an SPI slave bus.
 *
 *  \param i   The interface to connect to the user of the component.
 *             The component acts as the client and will make callbacks to
 *             the application.
 *  \param sclk          the SPI clock port
 *  \param mosi          the SPI MOSI (master out, slave in) port
 *  \param miso          the SPI MISO (master in, slave out) port
 *  \param clk           clock to be used by the component
 *  \param mode          the SPI mode of the bus
 */
 [[combinable]]
void spi_slave(client spi_slave_callback_if i,
               in port sclk, in port mosi, out port mosi,
               clock clk,
               spi_mode_t mode);

#endif // _spi_h_
