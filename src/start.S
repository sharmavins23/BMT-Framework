.section    .init
.global     _start

.equ        BASE,       0xfe200000          // Base address
.equ        GPFSEL2,    0x08		        // FSEL2 register offset 
.equ        GPSET0,     0x1c		        // GPSET0 register offset
.equ        GPCLR0,     0x28		        // GPCLR0 register offset
.equ        SET_BIT3,   0x08		        // Sets bit three b1000		
.equ        SET_BIT21,  0x200000            // Sets bit 21
.equ        COUNTER,    0xf0000

_start:
            ldr         x0, =BASE
            ldr         x2, =COUNTER
            ldr         x1, =SET_BIT3
            str         x1, [x0, #GPFSEL2]

            b           blinkled            // Go to C code for blinking control

.global     delay
delay:      mov         x10, #0             // Clear r10

dloop:      add         x10, x10, #1        // Add 1
            cmp         x10, x2             // Check if overflow occurs
            bne         dloop               // If not, go back

dend:       ret                             // Otherwise, move on

.global     turnOnLED
turnOnLED:  ldr         x1, =SET_BIT21      // Load pin 21's address
            str         x1, [x0, #GPSET0]   // Set pin 21 to HIGH
            ret

.global     turnOffLED
turnOffLED: ldr         x1, =SET_BIT21      // Load pin 21's address
            str         x1, [x0, #GPCLR0]   // Set pin 21 to LOW
            ret
