SPI Library
===========

.. rheader::

   SPI |version|

SPI Libary
----------

A software defined, industry-standard, SPI (serial peripheral
interface) component
that allows you to control an SPI bus via the
xCORE GPIO hardware-response ports. SPI is a four-wire hardware
bi-directional serial interface. This component is controlled
via C using the XMOS multicore extensions and can either act as
SPI master or slave.

The component can be used by multiple tasks within the xCORE device
and (each addressing the same or different slaves) and
is compatible with other slave devices on the same bus.

Features
........

 * SPI master and SPI slave modes.
 * Supports speed of ?? Mbit.
 * Multiple slave device support
 * All clock polarity and phase configurations supported.

Components
...........

 * SPI master (mode 0,1,2,3)
 * SPI master, multiple slaves (mode 0,1,2,3)
 * SPI slave (mode 0,1,2,3)

Resource Usage
..............

.. list-table::
   :header-rows: 1
   :class: wide vertical-borders horizontal-borders

   * - Configuration
     - Pins
     - Port Blocks
     - Clock Blocks
     - Ram
     - Logical cores
   * - Master
     - 3
     - 3 x 1-bit
     - 1
     - ??
     - 0
   * - Master (multiple slave)
     - 3 + number of slaves
     - 3 x 1-bit + number of slaves
     - 1
     - ??
     - 0
   * - Slave
     - 4
     - 3 x 1-bit + 1 x n-bit
     - 1
     - ??
     - 1


Software version and dependencies
.................................

This document pertains to version |version| of the SPI library. It is
intended to be used with version 13.x of the xTIMEcomposer studio tools.

The library does not have any dependencies (i.e. it does not rely on any
other libraries).

Related application notes
.........................

The following application notes use this library:

  * AN00052 - How to use the SPI master component
  * AN00057 - How to use the SPI slave component

Hardware characteristics
------------------------

The SPI protocol requires two wires to be connected to the xCORE
device: a clock line and data line as shown in
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

TODO:

  * diagrams showing connections of ports to lines (including optional
    tying down of slave select for single slave)
  * mode descriptions (polarity and phase) with timing diags


Master API
----------

All SPI master functions can be accessed via the ``spi.h`` header::

  #include <spi.h>

You will also have to add ``lib_spi`` to the
``USED_MODULES`` field of your application Makefile.

SPI master components are instantiated as parallel tasks that run in a
``par`` statement. The application can connect via an interface
connection.

.. figure:: images/task_diag-crop.*

   SPI task diagram

For example, the following code instantiates an SPI master component
for a single slave and connects to it::

  spi_master_ports_t spi_ports = { XS1_PORT_1A, XS1_PORT_1B, XS1_PORT_1C };
  clock spi_clk = XS1_CLKBLK_2;

  void my_application(client interface spi_master_if i_spi)
  {
     uint32 data_in, data_out;
     ...
     data_in = i_spi.transfer32(data_out);
     ...
  }

  int main(void) {
    interface spi_master_if i_spi;
    par {
      spi_master_single_slave(spi_ports, spi_clk, i_spi, SPI_MODE_0);
      my_application(i_spi);
    }
    return 0;
  }

Synchronous vs. Asynchronous operation
......................................

There are two types of interface for SPI master components:
synchronous and asynchronous.

The synchronous API provides blocking operation. Whenever a client makes a
read or write call the operation will complete before the client can
move on - this will occupy the core that the client code is running on
until the end of the operation. This method is easy to use, has low
resource use and is very suitable for applications such as setup and
configuration of attached peripherals.

The asynchronous API offloads operations to another task. Calls are
provide to initiate reads and writes and notifications are provided
when the operation completes. This API is trickier to use but can
provide more efficient operation. It is suitable for applications
where the SPI bus is being used for continuous data transfer.


|newpage|

Supporting types
................

The following type is used to configure the SPI components.

.. doxygenenum:: spi_mode_t

|newpage|

Creating an SPI master instance
...............................

|newpage|

.. doxygenfunction:: spi_master_single_slave

|newpage|

.. doxygenfunction:: spi_master_multi_slave

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

TODO


Creating an SPI slave instance
..............................

.. doxygenfunction:: spi_slave


The SPI slave interface API
...........................

.. doxygeninterface:: spi_slave_callback_if
