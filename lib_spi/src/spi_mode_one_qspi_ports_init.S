#include "spi_defines.h"
#include "spi_registers.h"

#if defined(__XS2A__)

.issue_mode dual

//Deducting one from NUM_DATA from the get-go to enable 1 byte reads below...
{ldw SCLK, QSPI_PORTS[1]; sub NUM_DATA, NUM_DATA, 1}
{ldw SIO, QSPI_PORTS[2]; mkmsk INDEX, 32}
//Mode 1 requires cpol 0 clock edges
//cpol 0 starts/finish low
{ldw CLK_EDGES, dp[clock_edges_cpol_zero]; ldc CLK_START_END, 0}
outpw res[SCLK], CLK_START_END, 1

//Store the CLK_START_END to the stack as we'll clobber this register in the
//loop below.  We can restore it from the stack at the end of the loop.
stw CLK_START_END, sp[CLK_START_END_STACK_LOCATION]

//TODO: Offset cpha

#endif //defined(__XS2A__)
