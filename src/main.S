.syntax unified
.global main
.type main, %function
main:
  ldr r0, =hello
  bl init
  bl state_happy
  b main
.size main, .-main

.type init, %function
init:
  push {lr}
  @ 1: Configure GPIOTE_CONFIG[0] (Section 6.9.4.8 in nRF52833 reference manual)
  @ mode = 1 (event), pin = 14 and port = 0 (P0.14 = Button A), polarity = 1 (LoToHi)
  ldr r0, =OFS_GPIOTE_CONFIG0
  ldr r1, =(1 | 14 << 8 | 0 << 13 | 1 << 16)
  str r1, [r0]
@ 2: Enable Interrupt for GPIOTE[0] (id = 6) (S6.9.4.6 in nRF52833 reference manual)
  ldr r0, =OFS_GPIOTE_INTENSET
  ldr r1, =0b1
  str r1, [r0]
@ 3: enable GPIOTE (interrupt #6 = NVIC_GPIOTE_ID) in NVIC_ISER0 (B3.4.4 in ARMv7-M Reference Manual)
  ldr r0, =OFS_NVIC_ISER0
  ldr r1, =(1 << 6) @ set the 6th bit since NVIC_GPIOTE_ID = 6
  str r1, [r0]
  bl init_leds
  pop {lr} 
  bx lr
.size init, .-init

state_happy:
  
  mov r0, 0 @row 0
  mov r1, 1 @col 1
  mov r2, 1 @turn on
  bl write_led
  
  mov r0, 0 @row 0
  mov r1, 3 @col 3
  mov r2, 1 @turn on

  bl write_led
  bl turn_off_led

  mov r0, 1 @row 1
  mov r1, 1 @col 1
  mov r2, 1 @turn on

  bl write_led

  mov r0, 1 @row 1
  mov r1, 3 @col 3
  mov r2, 1 @turn on

  bl write_led
  bl turn_off_led

  @mouth
  mov r0, 3 @row 3
  mov r1, 1 @col 0
  mov r2, 1 @turn on

  bl write_led

  mov r0, 3 @row 3
  mov r1, 3 @col 3
  mov r2, 1 @turn on

  bl write_led
  bl turn_off_led

  mov r0, 4 @row 4
  mov r1, 2 @col 0
  mov r2, 1 @turn on

  bl write_led
  bl turn_off_led
  b state_happy

.type turn_off_led, %function
turn_off_led:
  push {lr}
  push {r0 - r2}
  mov r0, #0b00000 @turn off row 0
  mov r1, 0 @row
  bl write_pins
  mov r0, #0b11111 @turn on col 0 and 4
  mov r1, 1 @col
  bl write_pins
  pop {r0 - r2}
  pop {lr}
  bx lr


.global GPIOTE_IRQHandler
.type GPIOTE_IRQHandler, %function
GPIOTE_IRQHandler:
  @ interrupt code goes here
  @ clear event
  b Default_Handler
  b GPIOTE_IRQHandler
  bx lr
.size GPIOTE_IRQHandler, .-GPIOTE_IRQHandler




