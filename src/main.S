#include <avr/io.h> // Include register definitions and useful macros

.global main
main:


;; Configure control pin's as outputs 

ldi r16, PIN0_bm
sts PORTC_OUTCLR, r16 ;; output set low 
sts PORTC_DIRSET, r16 ;; CLK output

ldi r17, PIN2_bm
sts PORTC_OUTCLR, r17 ;; output set low 
sts PORTC_DIRSET, r17  ;; MOSI output

ldi r18, PIN1_bm
sts PORTA_OUTCLR, r18 ;; output set low 
sts PORTA_DIRSET, r18 ;; LATCH output

ldi r29, PIN4_bm 
STS PORTA_DIRCLR, r29 ;; Button 0 input

ldi r30, PORT_PULLUPEN_bm 
sts PORTA_PIN4CTRL, r30 ;; Enabling internal pullup resistor 

clr r20 ;; Clearing register of any excess as r20 holds the digit index



loop: ;; Main Loop for the code
    

    ; r20 holds the digit index
    ldi ZL, lo8(digit_table) ;; Pointing to low byte of the digit_table 
    ldi ZH, hi8(digit_table) ;; Pointing to high byte of the digit_table 

    clr r21          ; zero register for carry handling 
    add ZL, r20      ; add digit offset to low byte
    adc ZH, r21      ; add carry to high byte

    lpm r19, Z    ; load pattern into r19 

    ldi r22, 8 ;; number of loops needing to occur. 

    send_loop:
        sbrc r19, 7 ;; looks at most significant bit in r19, skips next line if MSB is 0 
        rjmp send_one ;; jumps to send one if not skipped by line 47

        ; otherwise send zero
        sts PORTC_OUTCLR, r17 ;; sets MOSI low
        rjmp after_send_bit ;; Jumpts to send_bit

    send_one:
        sts PORTC_OUTSET, r17 ;; Sets mosi High (then goes after_send_bit)

    after_send_bit:
        ; pulse clock - uploads to the shift latch
        sts PORTC_OUTSET, r16 ;; Sets CLK high 
        sts PORTC_OUTCLR, r16 ;; Sets CLK low

        ; shift to next bit
        lsl r19 ;; Moves regsiter 19 pattern to the left making MSB move into carry 

        ; loop bookkeeping
        dec r22 ;; reduces number of loops needed by one 
        brne send_loop ;; send back to the beginning untill r22 == 0 


    ;; Latch Pulse - Drive Displatch == uploads to the LED 

    sts PORTA_OUTSET, r18 ;; Set Latch High
    sts PORTA_OUTCLR, r18  ;; Set Latch Low

wait_press:
    lds r28, PORTA_IN ;; Registers inputs from PIN's A 
    and r28, r29 ;; isolates Button 0 Pin 
    cpi r28, 0x00 ;; compares register, if unpressed repeats 
    brne wait_press ;; goes back to wait_press 

    ; debounce delay after first detected press
   ldi r24, 255 ;; inputing number into register 24 for delaying time through dec 
delay_press:
    ldi r25, 255 ;; inputing number into register 25 for delaying time through dec 
delay_delay_press:
    dec r25 ;; remove 1 value from register 25 
    brne delay_delay_press ;; go back to delay_delay_press (once r25 is 0 this is skipped)

    dec r24 ;; remove 1 value form register 24 
    brne delay_press ;; go back to delay_press (once r24 is 0, this is skipped )

    ; confirm it is still pressed
    lds r28, PORTA_IN ;; checking if pressed 
    and r28, r29 ;; isolating buttion 0 pin 
    cpi r28, 0x00 ;;determining if button is pressed 
    brne wait_press ;; if pressed going back to wait_press (skip if button is pressed)

    inc r20 ;; increment register 20 by 1 due to button being pressed 
    cpi r20, 10 ;; comparing register 20 to the value 10, if 10 skipping the loop and clearing its value back to 0  
    brne wait_release ;; going to wait_release
    clr r20 ;; clearing register 20 to 0 

wait_release:
    lds r28, PORTA_IN ;; checking if pressed
    and r28, r29 ;; isolating button 0 pin 
    cpi r28, 0x00 ;; determining if button is pressed 
    breq wait_release ;; if not pressed going back to wait release 

    ; debounce delay after release
    ldi r24, 255 
delay_release:
    ldi r25, 255
delay_delay_release:
    dec r25
    brne delay_delay_release

    dec r24
    brne delay_release

    ; confirm it is still released
    lds r28, PORTA_IN ;; load inputs 
    and r28, r29 ;; isolate button 0 pins 
    cpi r28, 0x00 ;; compare if value is 0 
    breq wait_release ;; go to wait release 

    rjmp loop


.section .progmem.data
digit_table:
   .byte 0b10001000 ; 0
   .byte 0b11101011 ; 1
   .byte 0b11000100 ; 2
   .byte 0b11000001 ; 3
   .byte 0b10100011 ; 4
   .byte 0b10010001 ; 5
   .byte 0b10010000 ; 6
   .byte 0b11001011 ; 7
   .byte 0b10000000 ; 8
   .byte 0b10000001 ; 9
