#include "start.h"

// Delays the code.
void delay();

// Turns on the LED at pin 21.
void turnOnLED();

// Turns off the LED at pin 21.
void turnOffLED();

// Loops forever, blinks the LED.
void blinkled() {
    while (1) {
        // Turn on LED
        turnOnLED();
        // Delay
        delay();
        // Turn off LED
        turnOffLED();
        // Delay
        delay();
    }

    return;  // This should never reach
}