#include <xs1.h>

#include "spi_defines.h"
#include "spi_registers.h"

#if defined(__XS2A__)

ldc PORT_MODE, XS1_SETC_COND_FULL
setc res[SIO], PORT_MODE
in PORT_TIME, res[SIO]
getts PORT_TIME, res[SIO]
ldw PORT_SETUP_TIME, PORT_TIMINGS[PORT_SETUP_DELAYS_OFFSET]
add PORT_TIME, PORT_TIME, PORT_SETUP_TIME
setpt res[SCLK], PORT_TIME
outpw res[SCLK], CLK_EDGES, EIGHT_CLOCK_EDGES_DOUBLED
ldw PORT_INPUT_TIME, PORT_TIMINGS[PORT_INPUT_DELAYS_OFFSET]
add PORT_TIME, PORT_TIME, PORT_INPUT_TIME
setpt res[SIO], PORT_TIME

#endif //defined(__XS2A__)
