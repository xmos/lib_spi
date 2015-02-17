.. include:: ../../../README.rst

Typical Resource Usage
......................

.. resusage::

  * - configuration: Master (synchronous, zero clock blocks, MISO enabled, MOSI enabled)
    - globals: out buffered port:32 p_sclk = XS1_PORT_1A; out buffered port:32 p_mosi =  XS1_PORT_1B; in buffered port:32 p_miso = XS1_PORT_1C; out port p_ss[1] = {XS1_PORT_1D};
    - locals: interface spi_master_if i[1];
    - fn: spi_master(i, 1, p_sclk, p_mosi, p_miso, p_ss, 1, null);
    - pins: 4
    - ports: 4 (1-bit)
  * - configuration: Master (synchronous, one clock block, MISO enabled, MOSI enabled)
    - globals: out buffered port:32 p_sclk = XS1_PORT_1A; out buffered port:32 p_mosi =  XS1_PORT_1B; in buffered port:32 p_miso = XS1_PORT_1C; out port p_ss[1] = {XS1_PORT_1D};clock cb = XS1_CLKBLK_1;
    - locals: interface spi_master_if i[1];
    - fn: spi_master(i, 1, p_sclk, p_mosi, p_miso, p_ss, 1, cb);
    - pins: 4
    - ports: 4 (1-bit)
  * - configuration: Master (synchronous, zero clock blocks, MISO enabled, MOSI disabled)
    - globals: out buffered port:32 p_sclk = XS1_PORT_1A; in buffered port:32 p_miso = XS1_PORT_1C; out port p_ss[1] = {XS1_PORT_1D};
    - locals: interface spi_master_if i[1];
    - fn: spi_master(i, 1, p_sclk, null, p_miso, p_ss, 1, null);
    - pins: 3
    - ports: 3 (1-bit)
  * - configuration: Master (synchronous, one clock block, MISO enabled, MOSI enabled)
    - globals: out buffered port:32 p_sclk = XS1_PORT_1A; in buffered port:32 p_miso = XS1_PORT_1C; out port p_ss[1] = {XS1_PORT_1D};clock cb = XS1_CLKBLK_1;
    - locals: interface spi_master_if i[1];
    - fn: spi_master(i, 1, p_sclk, null, p_miso, p_ss, 1, cb);
    - pins: 3
    - ports: 3 (1-bit)
  * - configuration: Master (synchronous, zero clock blocks, MISO disabled, MOSI enabled)
    - globals: out buffered port:32 p_sclk = XS1_PORT_1A; out buffered port:32 p_mosi =  XS1_PORT_1B; out port p_ss[1] = {XS1_PORT_1D};
    - locals: interface spi_master_if i[1];
    - fn: spi_master(i, 1, p_sclk, p_mosi, null, p_ss, 1, null);
    - pins: 3
    - ports: 3 (1-bit)
  * - configuration: Master (synchronous, one clock block, MISO disabled, MOSI enabled)
    - globals: out buffered port:32 p_sclk = XS1_PORT_1A; out buffered port:32 p_mosi =  XS1_PORT_1B; out port p_ss[1] = {XS1_PORT_1D};clock cb = XS1_CLKBLK_1;
    - locals: interface spi_master_if i[1];
    - fn: spi_master(i, 1, p_sclk, p_mosi, null, p_ss, 1, cb);
    - pins: 3
    - ports: 3 (1-bit)
  * - configuration: Master (asynchronous, MISO enabled, MOSI enabled)
    - globals: out buffered port:32 p_sclk = XS1_PORT_1A; out buffered port:32 p_mosi =  XS1_PORT_1B; in buffered port:32 p_miso = XS1_PORT_1C; out port p_ss[1] = {XS1_PORT_1D};clock cb0 = XS1_CLKBLK_1; clock cb1 = XS1_CLKBLK_2;
    - locals: interface spi_master_async_if i[1];
    - fn: spi_master_async(i, 1, p_sclk, p_mosi, p_miso, p_ss, 1, cb0, cb1);
    - pins: 4
    - ports: 4 (1-bit)
  * - configuration: Master (asynchronous, MISO enabled, MOSI disabled)
    - globals: out buffered port:32 p_sclk = XS1_PORT_1A; in buffered port:32 p_miso = XS1_PORT_1C; out port p_ss[1] = {XS1_PORT_1D};clock cb0 = XS1_CLKBLK_1; clock cb1 = XS1_CLKBLK_2;
    - locals: interface spi_master_async_if i[1];
    - fn: spi_master_async(i, 1, p_sclk, null, p_miso, p_ss, 1, cb0, cb1);
    - pins: 3
    - ports: 3 (1-bit)
  * - configuration: Slave (MISO Enabled, 32 bit transfer mode)
    - globals: in port p_sclk = XS1_PORT_1A; in buffered port:32 p_mosi = XS1_PORT_1B; out buffered port:32 p_miso = XS1_PORT_1C; in port p_ss = XS1_PORT_1D;clock cb = XS1_CLKBLK_1;
    - locals: interface spi_slave_callback_if i;
    - fn: spi_slave(i, p_sclk, p_mosi, p_miso, p_ss, cb, SPI_MODE_0, SPI_TRANSFER_SIZE_32);
    - pins: 4
    - ports: 4 (1-bit)
  * - configuration: Slave (MISO Disabled, 32 bit transfer mode)
    - globals: in port p_sclk = XS1_PORT_1A; in buffered port:32 p_mosi = XS1_PORT_1B; in port p_ss = XS1_PORT_1D;clock cb = XS1_CLKBLK_1;
    - locals: interface spi_slave_callback_if i;
    - fn: spi_slave(i, p_sclk, p_mosi, null, p_ss, cb, SPI_MODE_0, SPI_TRANSFER_SIZE_32);
    - pins: 3
    - ports: 3 (1-bit)
  * - configuration: Slave (MISO Enabled, 8 bit transfer mode)
    - globals: in port p_sclk = XS1_PORT_1A; in buffered port:32 p_mosi = XS1_PORT_1B; out buffered port:32 p_miso = XS1_PORT_1C; in port p_ss = XS1_PORT_1D;clock cb = XS1_CLKBLK_1;
    - locals: interface spi_slave_callback_if i;
    - fn: spi_slave(i, p_sclk, p_mosi, p_miso, p_ss, cb, SPI_MODE_0, SPI_TRANSFER_SIZE_8);
    - pins: 4
    - ports: 4 (1-bit)
  * - configuration: Slave (MISO Disabled, 8 bit transfer mode)
    - globals: in port p_sclk = XS1_PORT_1A; in buffered port:32 p_mosi = XS1_PORT_1B; in port p_ss = XS1_PORT_1D;clock cb = XS1_CLKBLK_1;
    - locals: interface spi_slave_callback_if i;
    - fn: spi_slave(i, p_sclk, p_mosi, null, p_ss, cb, SPI_MODE_0, SPI_TRANSFER_SIZE_8);
    - pins: 3
    - ports: 3 (1-bit)

Software version and dependencies
.................................

.. libdeps::

Related application notes
.........................

The following application notes use this library:

  * AN00000 - How to use the SPI master component
  * AN00000 - How to use the SPI slave component

Hardware characteristics
------------------------

The SPI protocol requires a clock, one or more slave selects
and either one or two data wires. 

:ref:`spi_wire_table`.

.. _spi_wire_table:

.. list-table:: SPI data wires
     :class: vertical-borders horizontal-borders

     * - *SCLK*
       - Clock line, driven by the master
     * - *MOSI*
       - Master Output, Slave Input data line, driven by the master
     * - *MISO*
       - Master Output, Slave Input data line, driven by the slave
     * - *SS*
       - Slave select line, driven by the master

SPI modes
.........
The data sample points for SPI are defined by the clock ploarity (CPOL) and clock phase (CPHA) 
parameters. SPI clock polarity may be inverted or non-inverted by the CPOL and the CPHA parameter 
is used to shift the sampling phase. The following for sections illustrate the MISO and MOSI data lines
relative to the clock. The timings are given by::

  * t1 - The minimum time from the start of the transaction to data being valid on the data pins,
  * t2 - The inter-transmission gap. This is the minimum amount of time that the slave select must be desserted,
  * Max clock rate - This is the maximum clock rate supported by the configuration.

For setup and hold timing characteristics, refer to ...FIXME

Mode 0 - CPOL: 0 CPHA 1
=======================
{signal: [
  {name: 'CLK',  wave: '0..101010|10....', node: '...B'},spi modes
  {name: 'MOSI', wave: 'x..2.2.2.|2.x...', data: ['MSB',,, 'LSB'] },
  {name: 'MISO', wave: 'x..2.2.2.|2.x...', data: ['MSB',,, 'LSB'], node: '...................'},
  {name: 'CS',   wave: '10.......|..1..0', node: '.A..........C..D..'},
  {              node: '.a.b........c..d'}
],
  edge: [ 'A|a','B|b', 'C|c','D|d','a<->b t1',  'c<->d t2']
}
The master and slave will drive out their first data bit on the first rising edge of the clock and sample 
on the subsequent falling edge.

Mode 1 - CPOL: 0 CPHA 0
=======================
{signal: [
  {name: 'CLK',  wave: '0...10101|010...', node: '...B'},
  {name: 'MOSI', wave: 'x..2.2.2.|2.x...', data: ['MSB',,, 'LSB'] },
  {name: 'MISO', wave: 'x..2.2.2.|2.x...', data: ['MSB',,, 'LSB'], node: '...................'},
  {name: 'CS',   wave: '10.......|..1..0', node: '.A..........C..D..'},
  {              node: '.a.b........c..d'}
],
  edge: [ 'A|a','B|b', 'C|c','D|d','a<->b t1',  'c<->d t2']
}

The master and slave will drive out their first data bit before the first rising edge of the clock then drive on 
subsequent falling edges. They will sample on rising edges.

Mode 2 - CPOL: 1 CPHA 0
=======================
{signal: [
  {name: 'CLK',  wave: '1...01010|101...', node: '...B'},
  {name: 'MOSI', wave: 'x..2.2.2.|2.x...', data: ['MSB',,, 'LSB'] },
  {name: 'MISO', wave: 'x..2.2.2.|2.x...', data: ['MSB',,, 'LSB'], node: '...................'},
  {name: 'CS',   wave: '10.......|..1..0', node: '.A..........C..D..'},
  {              node: '.a.b........c..d'}
],
  edge: [ 'A|a','B|b', 'C|c','D|d','a<->b t1',  'c<->d t2']
}

The master and slave will drive out their first data bit before the first falling edge of the clock then drive on 
subsequent rising edges. They will sample on falling edges.

Mode 3 - CPOL: 1 CPHA 1
=======================
{signal: [
  {name: 'CLK',  wave: '1..010101|01..', node: '...B'},
  {name: 'MOSI', wave: 'x..2.2.2.|2.x...', data: ['MSB',,, 'LSB'] },
  {name: 'MISO', wave: 'x..2.2.2.|2.x...', data: ['MSB',,, 'LSB'], node: '...................'},
  {name: 'CS',   wave: '10.......|..1..0', node: '.A..........C..D..'},
  {              node: '.a.b........c..d'}
],
  edge: [ 'A|a','B|b', 'C|c','D|d','a<->b t1',  'c<->d t2']
}

The master and slave will drive out their first data bit on the first falling edge of the clock and sample 
on the subsequent rising edge.

SPI master timing characteristics
=================================
For all spi master configurations t1 is limited by the time between the client of the SPI master server calling
`begin_transaction` and one fo the data transfer initialisation methods. The inter-transmission gap, t2, is also 

Synchronous SPI master clock speeds
....................................
| Clock blocks| MISO enabled | MOSI enabled  | 62.5 MIPS max kbps | 125 MIPS max kbps |
| 0           | 1            | 0             |        2497        |            3366   |
| 0           | 1            | 1             |        1765        |            3366   |
| 1           | 1            | 0             |        2149        |            2149   |
| 1           | 1            | 1             |        2149        |            2149   |
  
Asynchronous SPI master clock speeds
....................................
The asynchronous master is limited only by the clock divider on the clock block. This mease for the 100MHz reference
clock that the asynchronous master can output a clock at up to 100MHz

SPI slave timings
.................



TODO:

  * diagrams showing connections of ports to lines (including optional
    tying down of slave select for single slave)
  * description of connecting multiple devices to the same bus

The master component of this library supports multiple slaves on unique 
slave select wires. This means that a single slave select assertion 
cannot be used to communicate with multiple slaves at the same time.

Usage
-----

SPI master synchronous operation
................................

There are two types of interface for SPI master components:
synchronous and asynchronous.

The synchronous API provides blocking operation. Whenever a client makes a
read or write call the operation will complete before the client can
move on - this will occupy the core that the client code is running on
until the end of the operation. This method is easy to use, has low
resource use and is very suitable for applications such as setup and
configuration of attached peripherals.

SPI master components are instantiated as parallel tasks that run in a
``par`` statement. For synchronous operation, the application can
connect via an interface connection using the ``spi_master_if`` interface type:

.. figure:: images/spi_master_task_diag.*

   SPI master task diagram

For example, the following code instantiates an SPI master component
and connect to it::

  port p_miso    = XS1_PORT_1A;
  port p_ss[1]   = {XS1_PORT_1B};
  port p_sclk    = XS1_PORT_1C;
  port p_mosi    = XS1_PORT_1D;
  clock clk_spi  = XS1_CLKBLK_1;

  int main(void) {
    spi_master_if i_spi[1];
    par {
      spi_master(i, 1, p_sclk, p_mosi, p_miso , p_ss, 1, clk_spi);
      my_application(i_spi[0]);
    }
    return 0;
  }

Note that the connection is an array of interfaces, so several tasks
can connect to the same component instance. The slave select ports are
also an array since the same SPI data lines can connect to several
devices via different slave lines.

The application can use the client end of the interface connection to
perform SPI bus operations e.g.::

  void my_application(client spi_master_if spi) {
    uint8_t val;
    printf("Doing one byte transfer. Sending 0x22.\n");
    spi.begin_transaction(0, 100, SPI_MODE_0);
    val = spi.transfer8(0x22);
    spi.end_transaction(1000);
    printf("Read data %d from the bus.\n", val);
  }

Here, ``begin_transaction`` selects the device ``0`` and asserts its
slave select line. The application can then transfer data to and from
the slave device and finish with ``end_transaction``, which de-asserts
the slave select line.

Operations such as ``spi.transfer8`` will
block until the operation is completed on the bus.
More information on interfaces and tasks can be be found in
the :ref:`XMOS Programming Guide<programming_guide>`. By default the
SPI synchronous master mode component does not use any logical cores of its
own. It is a *distributed* task which means it will perform its
function on the logical core of the application task connected to
it (provided the application task is on the same tile).

Synchronous master state machine
................................

digraph g {
	begin_transaction -> transfer8
	begin_transaction -> transfer32

	transfer8 -> transfer8
	transfer8 -> transfer32
	transfer32 -> transfer8
	transfer32 -> transfer32

	transfer32 -> end_transaction
	transfer32 -> end_transaction

	end_transaction -> begin_transaction 
}

|newpage|

SPI master asynchronous operation
.................................

The synchronous API will block your application until the bus
operation is complete. In cases where the application cannot afford to
wait for this long the asynchronous API can be used.

The asynchronous API offloads operations to another task. Calls are
provide to initiate reads and writes and notifications are provided
when the operation completes. This API requires more management in the
application but can provide much more efficient operation.
It is particularly suitable for applications where the SPI bus is
being used for continuous data transfer.

Setting up an asynchronous SPI master component is done in the same
manner as the synchronous component::

  port p_miso    = XS1_PORT_1A;
  port p_ss[1]   = {XS1_PORT_1B};
  port p_sclk    = XS1_PORT_1C;
  port p_mosi    = XS1_PORT_1D;
  clock cb0      = XS1_CLKBLK_1;
  clock cb1      = XS1_CLKBLK_2;

  int main(void) {
    i2c_master_async_if i_spi[1];
    par {
      spi_master_async(i_spi, 1, p_sclk, p_mosi, p_miso, p_ss, 1, cb0, cb1);
      my_application(i_spi[0]);
    }
    return 0;
  }

|newpage|

The application can use the asynchronous API to offload bus
operations to the component. This is done by moving pointers to the
SPI slave task to transfer and then retrieving pointers when the
operation is complete. For example, the following code
repeatedly calculates 100 bytes to send over the bus and handles 100
bytes coming back from the slave::

  void my_application(client spi_master_async_if spi) {
    uint8_t outdata[100];
    uint8_t indata[100];
    uint8_t * movable buf_in = indata;
    uint8_t * movable buf_out = outdata;

    // create and send initial data
    fill_buffer_with_data(outdata);
    spi.begin_transaction(0, 100, SPI_MODE_0);
    spi.init_transfer_array_8(move(buf_in), move(buf_out), 100);
    while (1) {
      select {
        case spi.operation_complete():
          retreive_transfer_buffers_8(buf_in, buf_out);
          spi.end_transaction();

          // Handle the data that has come in
          handle_incoming_data(buf_in);
          // Calculate the next set of data to go
          fill_buffer_with_data(buf_out);

          spi.begin_transaction(0, 100, SPI_MODE_0);
          spi.init_transfer_array_8(move(buf_in), move(buf_out));
          break;
      }
    }
  }

The SPI asynchronous task is combinable so can be run on a logical
core with other tasks (including the application task it is connected to).

|newpage|

Asynchronous master command buffering
.....................................

In order to provide asynchronous behaviour for multiple clients the asynchronous master 
will store up to one ``begin_transaction`` and one ``init_transfer_array_8`` or 
``init_transfer_array_32`` from each client. This means that if the master is busy 
doing a transfer for client x, then client y will still be able to begin a transaction 
and send data fully asynchronously. Consequently, after client y has issued 
``init_transfer_array_8`` or ``init_transfer_array_32`` the it will be able to get 
back to work whilst waiting for the notification.

Asynchronous master state machine
.................................

digraph g {
	begin_transaction -> init_transfer_array_8
	begin_transaction -> init_transfer_array_32

	init_transfer_array_8 -> transfer_complete
	transfer_complete -> retrieve_transfer_buffers_8
	retrieve_transfer_buffers_8 -> end_transaction

	init_transfer_array_32 -> transfer_complete
	transfer_complete -> retrieve_transfer_buffers_32
	retrieve_transfer_buffers_32 -> end_transaction

	retrieve_transfer_buffers_32 -> retrieve_transfer_buffers_32
	retrieve_transfer_buffers_32 -> retrieve_transfer_buffers_8
	retrieve_transfer_buffers_8 -> retrieve_transfer_buffers_32
	retrieve_transfer_buffers_8 -> retrieve_transfer_buffers_8

	end_transaction -> begin_transaction 
}

Master inter-transaction gap
............................

For both synchronous and asynchronous modes the ``end_transaction`` requires a  
slave select deassert time. This parameter will provide a minimum deassert time between
two transaction on the same slave select. In the case where a ``begin_transaction`` 
asserting the slave select would violate the previous ``end_transaction`` then the 
``begin_transaction`` will block until the slave select deassert time has been 
satisified.


|newpage|

Slave usage
...........

SPI slave components are instantiated as parallel tasks that run in a
``par`` statement. The application can connect via an interface
connection.

.. figure:: images/spi_slave_task_diag.pdf

  SPI slave task diagram

For example, the following code instantiates an SPI slave component
and connect to it::

  out buffered port:32    miso = XS1_PORT_1A;
  in port                 p_ss = XS1_PORT_1B;
  in port                 sclk = XS1_PORT_1C;
  in buffered port:32     mosi = XS1_PORT_1D;
  clock                   cb   = XS1_CLKBLK_1;

  int main(void) {
    interface spi_slave_callback_if spi_i;
    par {
      spi_slave(i, p_sclk, p_mosi, p_miso, p_ss, cb, SPI_MODE_0,
                SPI_TRANSFER_SIZE_8);
      my_application(i2c);
    }
    return 0;
  }

When a slave component is instantiated the mode and transfer size
needs to be specified.

|newpage|

The slave component acts as the client of the interface
connection. This means it can "callback" to the application to respond
to requests from the bus master. For example, the following code
snippet shows part of an application that responds to SPI transactions
where the first word is a command to read or write command and
subsequent transfers either provide or consume data::

  while (1) {
    uint32_t command = 0;
    size_t index = 0;
    select {
      case spi.master_starts_transaction():
         // The master has asserted slave select to start a transaction.
         command = 0;
         index = 0;
         break;
      case spi.master_supplied_data32(uint32_t data):
         if (command == 0) {
           command = data;
         } else if (command == WRITE_COMMAND) {
           handle_write_data_item(data, index);
           index++;
         }
         break;
      case spi.master_requires_data32() -> uint32_t data:
         if (command == 0) {
           // Not got the command yet.
           data = 0;
         } else if (command == READ_COMMAND) {
           data = get_read_data_item(index);
           index++;
         } else {
           data = 0;
         }
         break;
      case spi.master_requires_data() -> uint8_t data:
         // We are working in 32-bit mode so nothing to do here.
         break;
      case spi.master_supplied_data(uint8_t data):
         // We are working in 32-bit mode so nothing to do here.
         break;
      case spi.master_ends_transaction():
         // The master has de-asserted slave select.
         break;
     }
  }

Note that the time taken to handle the callbacks will determine the
timing requirements of the SPI slave. See application note AN????? for
more details on different ways of working with the SPI slave component.

Master API
----------

All SPI master functions can be accessed via the ``spi.h`` header::

  #include <spi.h>

You will also have to add ``lib_spi`` to the
``USED_MODULES`` field of your application Makefile.

Supporting types
................

The following type is used to configure the SPI components.

.. doxygenenum:: spi_mode_t

|newpage|

Creating an SPI master instance
...............................

.. doxygenfunction:: spi_master

|newpage|

.. doxygenfunction:: spi_master_async

|newpage|

SPI master interface
.....................

.. doxygeninterface:: spi_master_if

|newpage|

SPI master asynchronous interface
.................................

.. doxygeninterface:: spi_master_async_if

Slave API
---------

All SPI slave functions can be accessed via the ``spi.h`` header::

  #include <spi.h>

You will also have to add ``lib_spi`` to the
``USED_MODULES`` field of your application Makefile.

Creating an SPI slave instance
..............................

.. doxygenfunction:: spi_slave

|newpage|

.. doxygenenum:: spi_transfer_type_t

|newpage|

The SPI slave interface API
...........................

.. doxygeninterface:: spi_slave_callback_if
