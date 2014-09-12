SPI library
-----------

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

