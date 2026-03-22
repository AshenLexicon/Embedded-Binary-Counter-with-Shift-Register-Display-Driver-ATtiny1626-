# Embedded LED Counter – ATtiny1626

## Overview
This project implements a button-controlled 0–9 counter on a 7-segment display using an ATtiny1626 microcontroller and a shift register.

## Features
- Register-level GPIO configuration
- Serial data transmission (bit-banging)
- Program memory lookup table
- Button debouncing
- Digit wrap-around logic

## Hardware
- ATtiny1626 (QUTy board)
- 7-segment display
- Shift register
- Push button (PA4)

## How it works
1. Button press detected (active LOW)
2. Debounce confirms press
3. Counter increments
4. Digit pattern loaded from lookup table
5. Bits shifted out via MOSI/CLK
6. Latch updates display

## Code
See `src/main.asm`
