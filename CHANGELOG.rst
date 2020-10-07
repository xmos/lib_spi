SPI library change log
======================

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

