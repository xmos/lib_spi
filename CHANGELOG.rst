lib_spi change log
==================

4.0.0
-----

  * CHANGED: SPI master async reduced clock blocks from two to one
  * CHANGED: SPI master sync increased max speed to 25+ Mbps
  * RESOLVED: SPI master (all) swapping of SPI modes 0 and 1
  * RESOLVED: Non-funcional tests

3.4.0
-----

  * CHANGED: Refresh to use latest doc builder and library format
  * ADDED: Support for XCommon CMake build system
  * REMOVED: XCORE-200 targets in examples (now targets XK-EVK-XU316)

3.3.0
-----

  * ADDED: Support for XS3

3.2.0
-----

  * CHANGED: Use XMOS Public Licence Version 1
  * CHANGED: Rearrange documentation files

3.1.1
-----

  * CHANGED: Pin Python package versions
  * REMOVED: not necessary cpanfile

3.1.0
-----

  * Set up clock port in synchronous master every time (that way clock port can
    be shared with another task)
  * Add shutdown function to asynchronous master

3.0.4
-----

  * Make use of Wavedrom in documentation generation offline (fixes automated
    build due to a known Wavevedrom issue where it would generate zero size PNG)

3.0.3
-----

  * Documentation fixes and improvements
  * Fix initial asynchronous SCLK port configuration

3.0.2
-----

  * Update to source code license and copyright

3.0.1
-----

  * Minor user guide and documentation fixes

3.0.0
-----

  * Consolidated version, major rework from previous SPI components

