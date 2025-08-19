:orphan:

####################
lib_spi: SPI library
####################

:vendor: XMOS
:version: 4.0.0
:scope: General Use
:description: SPI Master and Slave components
:category: General Purpose
:keywords: SPI
:devices: xcore-200, xcore.ai

*******
Summary
*******

SPI is a four-wire hardware bi-directional serial interface.
This library provides a  software defined, industry-standard, SPI (serial peripheral
interface) component that allows control a SPI bus via the `xcore` GPIO ports. 

********
Features
********

* SPI master and SPI slave modes.
* Supports speed of up to 75 Mbit.
* Multiple slave device support
* All clock polarity and phase configurations supported.

************
Known issues
************

* None

****************
Development repo
****************

* `lib_spi <https://www.github.com/xmos/lib_spi>`_

**************
Required tools
**************

* XMOS XTC Tools: 15.3.1

*********************************
Required libraries (dependencies)
*********************************

* None

*************************
Related application notes
*************************

Please see `examples` section of user guide for SPI slave and SPI master examples.


*******
Support
*******

This package is supported by XMOS Ltd. Issues can be raised against the software at
`www.xmos.com/support <https://www.xmos.com/support>`_
