#include "spi_registers.h"

#if defined(__XS2A__)

//Unzip the two words that were input.  We are basically obtaining all the
//bits that were input on SIO pin 1 from the two input words.  Unzipping
//WORD_IN_TWO:WORD_IN_ONE saves us a nibble swap later
unzip WORD_IN_TWO, WORD_IN_ONE, 2  //zip out the correct nibbles
unzip WORD_IN_TWO, WORD_IN_ONE, 1  //zip out the correct bit pairs
unzip WORD_IN_TWO, WORD_IN_ONE, 0  //zip out the correct bits

//Now bitrev the final word and shuffle it down 3 bytes!
bitrev BYTE_IN, WORD_IN_TWO
shr BYTE_IN, BYTE_IN, 24

#endif //defined(__XS2A__)
