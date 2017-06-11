 .global _start

# Register MAP
# r1 - address of timer 1
# r2 - address of timer 2
# r3 - 
# r4 - interrupt handler checker( we probably will not use iterrupts so I am using it as an arugument following ABI protocol)
# r5 -
# r6 -
# r7 -
# r8 -
# r9 - ADDR_JP1 address
# r10 -
# r11 -
# r12 -
# r13 -
# r14 -
# r15 -
# r16 -
# r17 -TIMER_1_ACK
# r18 -
# r19 -
# r20 -
.global TIMER_2_PERIOD,TIMER_1_PERIOD
.equ ADDR_JP1, 0xFF200060  	     	         # Address GPIO JP1
.equ TIMER_1_PERIOD, 300000000			   	 # set period of timer 1 to 3 seconds
.equ TIMER_2_PERIOD,  1000000		 	     # set period of timer 2 to 1 second 

.data



# .section .exceptions, "ax" 
# .align 2

# # Inturrupt occured. Timer 1 triggered inturrupt when 3 seconds expire.
# # TIMER_1_ACK = 1
# movi r17,0x1



# put timer address into r1
movia r1, 0xFF202000    #r1 = TIMER_1

# initialize timer period
movi r6,  %lo(TIMER_1_PERIOD)
stwio r6, 8(r1)
movi	r6,  %hi(TIMER_1_PERIOD)
stwio	r6, 12(r1)	



_start:

  movia  r9, ADDR_JP1     	
  movia  r10, 0x07f557ff    		 # set direction for motors and sensors to output, and sensor data register to inputs
  stwio  r10, 4(r9)
  movia  r10, 0xffffffff			   # resetting all value to 1 
  stwio  r10, 0(r9)

######## CHECK FOR LIGHT FOR 3 SECONDS ############

CHECK_FOR_LIGHT_3_SEC_PLUS_RESET:


 stwio 	r0, (r1)	# Reset timer 
 movui r17, 0b0100       #start timer
 stwio r17, 4(r1)       # Start the timer without continuing or interrupts 

 
 CHECK_FOR_LIGHT_3_SEC:

# check if 3 seconds have passed. if yes, branch to TURN.
ldwio		r17, (r21)
andi 		r17, r17, 1
bne r0, r17, MOVE_FORWARD


# check if sensor is valid
movia  r10, 0xfffffbff 	 # enable sensor 0
stwio  r10, 0(r9)				     # send enable to robot car
ldwio  r5,  0(r9)         	 # checking for valid data sensor 0
mov    r13,  r5					
srli   r5, r5,11         		 # (shift) bit 13 is valid bit for sensor 0
andi   r5,  r5,0x1

# check if sensor is valid. If not valid, loop again.
bne r0,  r5, CHECK_FOR_LIGHT_3_SEC 
   
# check sensor value
srli	r13,	r13, 27
andi	r13,	r13, 0x0f
movi r11,0x7

#if no light is detected reiterated check
bgt r11, r13, CHECK_FOR_LIGHT_3_SEC

#else move forward
blt r11, r13, CHECK_FOR_LIGHT_3_SEC

br CHECK_FOR_LIGHT_3_SEC



MOVE_FORWARD:

#??
# Enable motor to move forward
movia  r10, 0x07f557ff       # set direction for motors to all output 
stwio  r10, 4(r9)
movia   r10, 0xfffffff0      # motor0 enabled (bit0=0), direction set to forward (bit1=0) 
                             # motor1 enabled (bit2=0), direction set to forward (bit3=0) 
stwio   r10, 0(r9)

#enable sensors to check for light
movia  r10, 0xfffffbf0 	 # enable sensor 0
stwio  r10, 0(r9)				     # send enable to robot car
ldwio  r5,  0(r9)         	 # checking for valid data sensor 0
mov    r13,  r5					
srli   r5, r5,11         		 # (shift) bit 13 is valid bit for sensor 0
andi   r5,  r5,0x1


# check if 3 seconds have passed. if yes, branch to TURN.
#bne r0, r17, TURN

# check if sensor is valid. If not valid, loop again.
bne    r0,  r5, CHECK_FOR_LIGHT_3_SEC 
   
srli	r13,	r13, 27
andi	r13,	r13, 0x0f
movi r11,0x7
#if no light is detected reiterated check
bgt r11, r13, STOP

#else move forward
blt r11, r13, MOVE_FORWARD

STOP:

# motors and sensors are turned off. Then wait 3 seconds until light is detected
movia   r7, 0xffffffff
 stwio	 r7, 0(r9)

	movi 	r4, %lo(100000000)				/* LSB of N into r4 */
	movi	r8, %hi(100000000)				/* MSB of N into r14 */
call delay
call delay

	 br CHECK_FOR_LIGHT_3_SEC_PLUS_RESET
	
TURN:

#WRITE THIS CODE

 movia  r7, 0x07f557ff        # set direction for motors to all output 
 stwio  r7, 4(r9)
 movia	 r7, 0xfffffff8       # motor0 enabled (bit0 = 0), direction set to forward (bit1=0) 
                              # motor1 enabled (bit0 = 2), direction set to backward (bit3=1)
 stwio	 r7, 0(r9)
 	movi 	r4, %lo(100000000)				/* LSB of N into r4 */
	movi	r8, %hi(100000000)				/* MSB of N into r14 */
call delay
call delay

 br STOP

