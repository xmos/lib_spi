#if defined(__XS2A__)

//Callee save registers
//Dont touch sp[0] as thats used for the lr
std r4, r5, sp[1] //sp[2]..sp[3]
std r6, r7, sp[2] //sp[4]..sp[5]
std r8, r9, sp[3] //sp[6]..sp[7]
stw r10, sp[8]    //sp[8]

#endif //defined(__XS2A__)
