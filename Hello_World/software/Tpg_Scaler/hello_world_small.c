#include <stdio.h>
#include "system.h"

#define SCALER_BASE 0x5000

int main(void) {
    volatile unsigned short *scaler = (volatile unsigned short *)SCALER_BASE;
    volatile unsigned char  *scaler8 = (volatile unsigned char *)SCALER_BASE;

    // Write output width and height as 2-byte registers
    scaler[1] = 10;   // offset 0x02 = trigger reg 0 = OUTPUT_WIDTH
    scaler[2] = 5;    // offset 0x04 = trigger reg 1 = OUTPUT_HEIGHT

    printf("scaler16[1] = %d\n", scaler[1]);
    printf("scaler16[2] = %d\n", scaler[2]);

    while(1);
    return 0;
}
