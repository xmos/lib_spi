Typical Resource Usage
......................

.. resusage::

  * - configuration: Master (synchronous, zero clock blocks)
    - globals: out buffered port:32 p_sclk = XS1_PORT_1A; out buffered port:32 p_mosi =  XS1_PORT_1B; in buffered port:32 p_miso = XS1_PORT_1C; out port p_ss[1] = {XS1_PORT_1D};
    - locals: interface spi_master_if i[1];
    - fn: spi_master(i, 1, p_sclk, p_mosi, p_miso, p_ss, 1, null);
    - pins: 4
    - ports: 4 (1-bit)
  * - configuration: Master (synchronous, one clock block)
    - globals: out buffered port:32 p_sclk = XS1_PORT_1A; out buffered port:32 p_mosi =  XS1_PORT_1B; in buffered port:32 p_miso = XS1_PORT_1C; out port p_ss[1] = {XS1_PORT_1D};clock cb = XS1_CLKBLK_1;
    - locals: interface spi_master_if i[1];
    - fn: spi_master(i, 1, p_sclk, p_mosi, p_miso, p_ss, 1, cb);
    - pins: 4
    - ports: 4 (1-bit)
  * - configuration: Master (asynchronous)
    - globals: out buffered port:32 p_sclk = XS1_PORT_1A; out buffered port:32 p_mosi =  XS1_PORT_1B; in buffered port:32 p_miso = XS1_PORT_1C; out port p_ss[1] = {XS1_PORT_1D};clock cb0 = XS1_CLKBLK_1; clock cb1 = XS1_CLKBLK_2;
    - locals: interface spi_master_async_if i[1];
    - fn: spi_master_async(i, 1, p_sclk, p_mosi, p_miso, p_ss, 1, cb0, cb1);
    - pins: 4
    - ports: 4 (1-bit)
  * - configuration: Slave (32 bit transfer mode)
    - globals: in port p_sclk = XS1_PORT_1A; in buffered port:32 p_mosi = XS1_PORT_1B; out buffered port:32 p_miso = XS1_PORT_1C; in port p_ss = XS1_PORT_1D;clock cb = XS1_CLKBLK_1;
    - locals: interface spi_slave_callback_if i;
    - fn: spi_slave(i, p_sclk, p_mosi, p_miso, p_ss, cb, SPI_MODE_0, SPI_TRANSFER_SIZE_32);
    - pins: 4
    - ports: 4 (1-bit)
  * - configuration: Slave (8 bit transfer mode)
    - globals: in port p_sclk = XS1_PORT_1A; in buffered port:32 p_mosi = XS1_PORT_1B; out buffered port:32 p_miso = XS1_PORT_1C; in port p_ss = XS1_PORT_1D;clock cb = XS1_CLKBLK_1;
    - locals: interface spi_slave_callback_if i;
    - fn: spi_slave(i, p_sclk, p_mosi, p_miso, p_ss, cb, SPI_MODE_0, SPI_TRANSFER_SIZE_8);
    - pins: 4
    - ports: 4 (1-bit)

The number of pins is reduced if either of the data lines are not required.
