#include "spi_registers.h"

#if defined(__XS2A__)

.issue_mode dual

ld8u WORD_OUT_ONE, TX_DATA[INDEX]
{mov WORD_OUT_TWO, WORD_OUT_ONE; shr WORD_OUT_ONE, WORD_OUT_ONE, 0x4}
{ldw WORD_OUT_ONE, LUT_SI_PIN[WORD_OUT_ONE]; zext WORD_OUT_TWO, 0x4}
ldw WORD_OUT_TWO, LUT_SI_PIN[WORD_OUT_TWO]

#endif //defined(__XS2A__)
