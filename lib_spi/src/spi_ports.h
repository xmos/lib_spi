// Copyright (c) 2018, XMOS Ltd, All rights reserved

#ifndef _SPI_PORTS_H_
#define _SPI_PORTS_H_

/**
 * SPI port implementation (4 wires)
**/
typedef struct spi_ports_impl_t
{
#ifdef __XC__
  out port                            spi_cs;
  out buffered port:32                spi_sclk;
  out buffered port:32                spi_mosi;
  in buffered port:32                 spi_miso;
#else
  unsigned int                        spi_cs;
  unsigned int                        spi_sclk;
  unsigned int                        spi_mosi;
  unsigned int                        spi_miso;
#endif
} spi_ports_impl_t;

/**
 * QSPI port implementation (6 wires)
**/
typedef struct qspi_ports_impl_t
{
#ifdef __XC__
  out port                            qspi_cs;
  out buffered port:32                qspi_sclk;
  [[bidirectional]]buffered port:32   qspi_sio;
#else
  unsigned int                        qspi_cs;
  unsigned int                        qspi_sclk;
  unsigned int                        qspi_sio;
#endif
} qspi_ports_impl_t;

/**
 * Port union
**/
typedef union ports_union_t
{
  spi_ports_impl_t spi_ports_impl;
  qspi_ports_impl_t qspi_ports_impl;
} ports_union_t;

#endif //_SPI_PORTS_H_
