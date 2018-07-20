// Copyright (c) 2018, XMOS Ltd, All rights reserved

#include "spi_impl.h"

//Issue a compile time error if the size of the internal spi_handle
//implementation does not match the size of the spi handle given...
_Static_assert(sizeof(spi_handle_impl_t) == (SIZEOF_SPI_HANDLE<<2),
 "Invalid spi_handle_imple_t size detected");
