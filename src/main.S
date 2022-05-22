.syntax unified
.global main
.set GPIOTE_EVENTS_IN0, 0x40006100
.set GPIOTE_EVENTS_IN1, 0x40006104
.set GPIOTE_INTENSET, 0x40006304
.set GPIOTE_CONFIG0, 0x40006510
.set GPIOTE_CONFIG1, 0x40006514


@ NVIC Constants
.set NVIC_ISER0, 0xE000E100

.type main, %function
main:
  bl init
  bl init_systick
show:
  bl feed
  bl update_state
  bl show_state
  b show
.size main, .-main
.type init, %function
init:
  push {lr}
  @ 1: Configure GPIOTE_CONFIG[0] (Section 6.9.4.8 in nRF52833 reference manual)
  @ mode = 1 (event), pin = 14 and port = 0 (P0.14 = Button A), polarity = 1 (LoToHi)
  ldr r0, =GPIOTE_CONFIG0
  ldr r1, =(1 | 14 << 8 | 0 << 13 | 1 << 16)
  str r1, [r0]
  @ configure GPIOTE_CONFIG[1]
  ldr r0, =GPIOTE_CONFIG1
  ldr r1, =(1 |23 << 8 | 0<<13 | 1 <<16)
  str r1, [r0]
@ 2: Enable Interrupt for GPIOTE[0] (id = 6) (S6.9.4.6 in nRF52833 reference manual)
  ldr r0, =GPIOTE_INTENSET
  ldr r1, =0b11
  str r1, [r0]
@ 3: enable GPIOTE (interrupt #6 = NVIC_GPIOTE_ID) in NVIC_ISER0 (B3.4.4 in ARMv7-M Reference Manual)
  ldr r0, =NVIC_ISER0
  ldr r1, =(1 << 6) @ set the 6th bit since NVIC_GPIOTE_ID = 6
  str r1, [r0]
  bl init_leds

  ldr r0, =ADR_SCB_SHPR3
  ldr r1, =(1 << 29 | 1 << 30 | 1 << 31)
  str r1, [r0]


  pop {lr}
  bx lr
.size init, .-init

.type init_systick, %function
init_systick:
  @ systick
  push {lr}
  ldr r0, =ADR_SYST_CSR
  mov r2, 0
  mov r1, 0

  bl set_bit

  mov r2, 3
  mov r1, 0
  bl set_bit

  @tickint
  mov r2, 1
  mov r1, 0
  bl set_bit
  ldr r0, =ADR_SYST_RVR
  mov r1, #64000
  str r1, [r0]
  pop {lr} 
  bx lr
.size init_systick, .-init_systick

.type show_state, %function
show_state:
  push {r0 - r2, lr}
  @ read state
  ldr r2, =state
  ldr r0, [r2]
  recgonize:
  @ happy
  cmp r0, 0
  beq show_happy
  cmp r0, 1
  beq show_hungry
  @ read state
  ldr r2, =state
  ldr r0, [r2]
  cmp r0, 2
  beq show_touch

  show_happy:
  bl state_happy
  pop {r0 - r2, lr} 
  bx lr 
  
  show_hungry:
  bl state_hungry
  pop {r0 - r2, lr}
  bx lr

  show_touch:
  bl state_touch
  pop {r0 - r2, lr}
  bx lr
.size show_state, .-show_state

.type update_state, %function
update_state:
  push {r0 - r3, lr}
  @ recognize touch state
  ldr r2, =state
  ldr r0, [r2]
  cmp r0, 2
  beq update_touch

  ldr r2, =the_cat
  @ hunger value
  ldr r0, [r2] 
  cmp r0, 20
  @ hunger > 20, happy
  bpl update_happy
  bmi update_hungry
  
  update_happy:
  ldr r2, =state
  ldr r0, [r2]
  mov r0, 0
  str r0, [r2]
  pop {r0 - r3, lr}
  bx lr
  update_hungry:
  ldr r2, =state
  ldr r0, [r2]
  mov r0, 1
  str r0, [r2]
  pop {r0 - r3, lr}
  bx lr
  update_touch:
  mov r0, 2
  str r0, [r2]
  pop {r0 - r3, lr}
  bx lr
.size update_state, .-update_state


.type state_happy, %function
state_happy:
  push {r0 - r2, lr}
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
  pop {r0 - r2, lr}
  bx lr
.size state_happy, .-state_happy

.type state_hungry, %function
state_hungry:
push {r0 - r2, lr}
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
  mov r1, 2 @col 2
  mov r2, 1 @turn on

  bl write_led
  bl turn_off_led

  mov r0, 4 @row 4
  mov r1, 1 @col 2
  mov r2, 1 @turn on
  bl write_led

  mov r0, 4 @row 4
  mov r1, 3 @col 3
  mov r2, 1 @turn on
  bl write_led
  bl turn_off_led
  pop {r0 - r2, lr}
  bx lr


.type state_happy, %function
state_touch:
  push {r0 - r2, lr}
  mov r0, 0 @row 0
  mov r1, 1 @col 1
  mov r2, 1 @turn on

  bl write_led

  mov r0, 0 @row 0
  mov r1, 3 @col 3
  mov r2, 1 @turn on

  bl write_led
  bl turn_off_led

  @mouth
  mov r0, 2 @row 2
  mov r1, 1 @col 0
  mov r2, 1 @turn on

  bl write_led

  mov r0, 2 @row 2
  mov r1, 3 @col 3
  mov r2, 1 @turn on

  bl write_led
  bl turn_off_led

  mov r0, 3 @row 3
  mov r1, 2 @col 0
  mov r2, 1 @turn on

  bl write_led
  bl turn_off_led
   
  wait_touch:
  ldr r2, =milliseconds
  ldr r0, [r2]
  cmp r0, 250
  IT mi
  bmi end_touch
  @clear the ms
  mov r0, 0
  str r0, [r2]
  @ if time consumed is less than 250ms
  bl state_happy
  ldr r2, =touch_count
  ldr r0, [r2]
  add r0, r0, 1
  str r0, [r2]
  @ if the cat has moved 3 times
  cmp r0, 3
  beq reset_touch_state
   @ keep this state for 250 ms
  b wait_touch

  @ return to other state
  reset_touch_state:
  ldr r2, =state
  ldr r0, [r2]
  mov r0, 4 @random number, the correct state will be calculated in update_state
  str r0, [r2]
  @ clear the touch_count
  ldr r2, =touch_count
  ldr r0, [r2]
  mov r0, 0
  str r0, [r2]

  b end_touch
  end_touch:
  pop {r0 - r2, lr}
  bx lr
.size state_touch, .-state_touch

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
.size turn_off_led, .-turn_off_led

.global GPIOTE_IRQHandler
.type GPIOTE_IRQHandler, %function
GPIOTE_IRQHandler:
  nop 
  push {r0, r2, lr}
  ldr r2, =GPIOTE_EVENTS_IN0
  ldr r0, [r2]
  cmp r0, 1
  beq buttonA
  b buttonB
  buttonA:
  @set feed state to 1
  ldr r2, =feed_state
  mov r0, #1
  str r0, [r2]
  @ clear event
  ldr r0, =GPIOTE_EVENTS_IN0
  ldr r1, =0
  str r1, [r0]
  pop {r0, r2, lr}
  bx lr
  buttonB:
  ldr r2, =the_cat
  ldr r0, [r2, 4]
  add r0, r0, #1
  str r0, [r2, 4]
  @ clear event
  ldr r0, =GPIOTE_EVENTS_IN1
  ldr r1, =0
  str r1, [r0]
  @set state to touch
  ldr r2, =state
  ldr r0, [r2]
  mov r0, 2
  str r0, [r2]
  pop {r0, r2, lr}
  bx lr
.size GPIOTE_IRQHandler, .-GPIOTE_IRQHandler

.global SysTick_Handler
.type SysTick_Handler, %function
SysTick_Handler:
  nop
  push {r0 - r2, lr}
  ldr r2, =milliseconds
  ldr r0, [r2]
  add r0, r0, #1
  str r0, [r2]
  pop {r0 - r2, lr}
  bx lr
.size SysTick_Handler, .-SysTick_Handler


.type feed, %function
feed:
  push {r0 - r2, lr}
  ldr r2, =feed_state
  ldr r0, [r2]
  cmp r0, 1
  IT eq
  bleq drop_food
  pop {r0 - r2, lr}
  bx lr
.size feed, .-feed

.type drop_food, %function
drop_food:
  push {r0 - r2, lr}
  ldr r0, =food_position
  ldr r0, [r0]
  mov r1, 0
  mov r2, 1
  bl write_led
wait:
  ldr r2, =milliseconds
  ldr r0, [r2]
  cmp r0, 500
  ldr r0, [r2]
  IT mi
  blmi turn_off_led
  IT mi
  bmi end_feed
  @ clear the milliseconds 
  mov r0, 0
  str r0, [r2]
  @ clear the led state
  bl turn_off_led
  @ add the food position
  ldr r0, =food_position
  ldr r1, [r0]
  add r1, r1, #1
  str r1, [r0]
  @ check if the food is on the last position
  cmp r1, 5
  beq reset_feed_state
  @set feed_state to 1
  ldr r2, =feed_state
  ldr r0, [r2]
  mov r0, 1
  str r0, [r2]
end_feed:
  @ display the next led
  pop {r0 - r2, lr}
  bx lr
reset_feed_state:
  @set feed_state to 0
  ldr r2, =feed_state
  ldr r0, [r2]
  mov r0, 0
  str r0, [r2]

  @ set food position to 0
  ldr r0, =food_position
  ldr r1, [r0]
  mov r1, 0
  str r1, [r0]

  @ add hunger level with 1
  ldr r0, =the_cat
  ldr r1, [r0] @the end of the record
  add r1, r1, #1
  str r1, [r0]

  pop {r0 - r2, lr}
  bx lr
.size drop_food, .-drop_food



.data
the_cat:
     @hunger (higher means not hungery), hapiness
.word 15,  20

.data 
food_position:
.word 0

.data
milliseconds:
.word 0

.data
feed_state:
.word 0

.data
state:
.word 0

.data
touch_count:
.word 0