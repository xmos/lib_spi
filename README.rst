SPI Library
===========

Summary
-------

A software defined, industry-standard, SPI (serial peripheral
interface) component
that allows you to control an SPI bus via the
xCORE GPIO hardware-response ports. SPI is a four-wire hardware
bi-directional serial interface.

The SPI bus can be used by multiple tasks within the xCORE device
and (each addressing the same or different slaves) and
is compatible with other slave devices on the same bus.

Features
........

 * SPI master and SPI slave modes.
 * Supports speed of up to 100 Mbit.
 * Multiple slave device support
 * All clock polarity and phase configurations supported.


Software version and dependencies
.................................

The CHANGELOG contains information about the current and previous versions.
For a list of direct dependencies, look for DEPENDENT_MODULES in lib_spi/module_build_info.

Related application notes
.........................

The following application notes use this library:

  * AN00160 - How to communicate as SPI master
  * AN00161 - How to communicate as SPI slave
