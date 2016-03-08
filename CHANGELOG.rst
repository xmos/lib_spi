SPI library change log
======================

3.1.0
-----

  * In the case of a slave select line being attached to a multi-bit port, the
    state of the other port bits will be preserved during slave select
    transitions. Note, the slave select line is assumed to attached to bit 0 of
    the port, regardless of port width.
  * Add function to allow individual bits of slave select port to be driven from
    SPI master interfaces

3.0.2
-----

  * Update to source code license and copyright

3.0.1
-----

  * Minor user guide and documentation fixes

3.0.0
-----

  * Consolidated version, major rework from previous SPI components

