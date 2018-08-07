#include <xs1.h>

#include "spi_defines.h"
#include "spi_registers.h"

#if defined(__XS2A__)

ldc PORT_MODE, XS1_SETC_COND_NONE
setc res[SIO], PORT_MODE
in PORT_TIME, res[SIO]
getts PORT_TIME, res[SIO]
ldw PORT_TIMINGS, PORT_TIMINGS[PORT_SETUP_DELAYS_OFFSET]
add PORT_TIME, PORT_TIME, PORT_TIMINGS
setpt res[SCLK], PORT_TIME
outpw res[SCLK], CLK_EDGES, EIGHT_CLOCK_EDGES_DOUBLED
setpt res[SIO], PORT_TIME

#endif //defined(__XS2A__)
