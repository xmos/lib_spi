// Copyright (c) 2018, XMOS Ltd, All rights reserved

#ifndef _SPI_IMPL_H_
#define _SPI_IMPL_H_

#include <xccompat.h>

//out should really be available from xccompat.h
#ifdef __XC__
#define out out
#else
#define out
#endif

//unsafe should really be available from xccompat.h
#ifdef __XC__
#define unsafe unsafe
#else
#define unsafe
#endif

//bidirectional buffered ports should really be available from xccompat.h
#ifdef __XC__
typedef [[bidirectional]]buffered port:32 bidirectional_buffered_port_t;
#else
typedef unsigned bidirectional_buffered_port_t;
#endif

//TODO: lift this up into xmos_spi.h
//Cyclical includes is preventing this between xmos_spi.h and spi_impl.h
typedef enum spi_mode_t
{
  spi_mode_0, //CPOL 0; CPHA 0;
  spi_mode_1, //CPOL 0; CPHA 1;
  spi_mode_2, //CPOL 1; CPHA 0;
  spi_mode_3, //CPOL 1; CPHA 1;
}spi_mode_t;

typedef enum ports_type_t
{
  spi_ports_impl,
  qspi_ports_impl,
} ports_type_t;

#define SIZEOF_SPI_HANDLE 7
typedef struct spi_handle_t
{
  const unsigned x[SIZEOF_SPI_HANDLE];
} spi_handle_t;

typedef struct spi_ports_impl_t
{
#ifdef __XC__
  unsafe out port                     spi_cs;
  unsafe out buffered port:32         spi_sclk;
  unsafe out buffered port:32         spi_mosi;
  unsafe in buffered port:32          spi_miso;
  unsafe clock                        spi_clk_blk;
#else
  unsigned                            spi_cs;
  unsigned                            spi_sclk;
  unsigned                            spi_mosi;
  unsigned                            spi_miso;
  unsigned                            spi_clk_blk;
#endif
} spi_ports_impl_t;

typedef struct qspi_ports_impl_t
{
#ifdef __XC__
  unsafe out port                             qspi_cs;
  unsafe out buffered port:32                 qspi_sclk;
  unsafe [[bidirectional]]buffered port:32    qspi_sio;
  unsafe clock                                qspi_clk_blk;
#else
  unsigned                                    qspi_cs;
  unsigned                                    qspi_sclk;
  unsigned                                    qspi_sio;
  unsigned                                    qspi_clk_blk;
#endif
} qspi_ports_impl_t;

typedef union ports_union_t
{
  spi_ports_impl_t spi_ports_impl;
  qspi_ports_impl_t qspi_ports_impl;
} ports_union_t;

typedef struct spi_handle_impl_t
{
  ports_union_t ports_union;
  ports_type_t  port_type;
  spi_mode_t    spi_mode;
} spi_handle_impl_t;


//SPI handle creation...

//These are all defined in spi_func_ptrs.c
extern void set_spi_mode_zero_fptrs(void);
extern void set_spi_mode_one_fptrs(void);
extern void set_spi_mode_two_fptrs(void);
extern void set_spi_mode_three_fptrs(void);

inline void create_spi_handle(spi_handle_t * const handle,
                              const spi_mode_t mode,
                              out port cs,
                              out_buffered_port_32_t sclk,
                              out_buffered_port_32_t mosi,
                              in_buffered_port_32_t miso,
                              const clock clk_blk)
{
  unsafe
  {
    spi_handle_impl_t *unsafe internal_handle = (spi_handle_impl_t *unsafe)handle;

    internal_handle->port_type = spi_ports_impl;
    internal_handle->spi_mode = mode;
    internal_handle->ports_union.spi_ports_impl.spi_cs = cs;
    internal_handle->ports_union.spi_ports_impl.spi_sclk = sclk;
    internal_handle->ports_union.spi_ports_impl.spi_mosi = mosi;
    internal_handle->ports_union.spi_ports_impl.spi_miso = miso;
    internal_handle->ports_union.spi_ports_impl.spi_clk_blk = clk_blk;

    switch(mode)
    {
      case spi_mode_0:
        set_spi_mode_zero_fptrs();
        break;
      case spi_mode_1:
        set_spi_mode_one_fptrs();
        break;
      case spi_mode_2:
        set_spi_mode_two_fptrs();
        break;
      case spi_mode_3:
        set_spi_mode_three_fptrs();
        break;
      default:
        __builtin_unreachable();
        break;
    }
  }
}

//QSPI handle creation...

#if defined(__XS2A__)

//These are all defined in spi_func_ptrs.c
extern void set_qspi_mode_zero_fptrs(void);
extern void set_qspi_mode_one_fptrs(void);
extern void set_qspi_mode_two_fptrs(void);
extern void set_qspi_mode_three_fptrs(void);

inline void create_qspi_handle(spi_handle_t * const handle,
                               const spi_mode_t mode,
                               out port cs,
                               out_buffered_port_32_t sclk,
                               bidirectional_buffered_port_t sio,
                               const clock clk_blk)
{
  unsafe
  {
    spi_handle_impl_t *unsafe internal_handle = (spi_handle_impl_t *unsafe)handle;

    internal_handle->port_type = qspi_ports_impl;
    internal_handle->spi_mode = mode;
    internal_handle->ports_union.qspi_ports_impl.qspi_cs = cs;
    internal_handle->ports_union.qspi_ports_impl.qspi_sclk = sclk;
    internal_handle->ports_union.qspi_ports_impl.qspi_sio = sio;
    internal_handle->ports_union.qspi_ports_impl.qspi_clk_blk = clk_blk;

    switch(mode)
    {
      case spi_mode_0:
        set_qspi_mode_zero_fptrs();
        break;
      case spi_mode_1:
        set_qspi_mode_one_fptrs();
        break;
      case spi_mode_2:
        set_qspi_mode_two_fptrs();
        break;
      case spi_mode_3:
        set_qspi_mode_three_fptrs();
        break;
      default:
        __builtin_unreachable();
        break;
    }
  }
}

#endif //defined(__XS2A__)

#endif //_SPI_IMPL_H_
