.section    .init
.global     _start

#include    "blink_LED.c"

.equ        BASE,       0xfe200000          // Base address
.equ        GPFSEL2,    0x08		        // FSEL2 register offset 
.equ        GPSET0,     0x1c		        // GPSET0 register offset
.equ        GPCLR0,     0x28		        // GPCLR0 register offset
.equ        SET_BIT3,   0x08		        // Sets bit three b1000		
.equ        SET_BIT21,  0x200000            // Sets bit 21
.equ        COUNTER,    0xf0000

_start:
            ldr         r0, =BASE
            ldr         r2, =COUNTER
            ldr         r1, =SET_BIT3
            str         r1, [r0, #GPFSEL2]

            b           blinkled            // Go to C code for blinking control

.global     delay
delay:      mov         r10, #0             // Clear r10

dloop:      add         r10, r10, #1        // Add 1
            cmp         r10, r2             // Check if overflow occurs
            bne         dloop               // If not, go back

dend:       bx          lr                  // Otherwise, move on

.global     turnOnLED
turnOnLED:  ldr         r1, =SET_BIT21      // Load pin 21's address
            str         r1, [r0, #GPSET0]   // Set pin 21 to HIGH
            bx          lr

.global     turnOffLED
turnOffLED: ldr         r1, =SET_BIT21      // Load pin 21's address
            str         r1, [r0, #GPCLR0]   // Set pin 21 to LOW
            bx          lr
