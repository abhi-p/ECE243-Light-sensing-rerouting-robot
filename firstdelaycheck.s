.equ TIMER, 0xFF202020

.global delay

delay:
	movia 		r21, TIMER   		/* Move address of timer into r16 */
	stwio		r4, 8(r21)
	stwio 		r8, 12(r21)
	stwio 		r0, (r21)			/* Reset timer */
	movi 		r17, 0b0100
	stwio		r17, 4(r21)			/* Start the timer */
	
poll:	
	ldwio		r17, (r21)
	andi 		r17, r17, 1
	beq 		r17, r0, poll
	
	ret
	
	
    movia r1, 0xFF202000    #r1 = TIMER_1
    movi r6, %lo(TIMER_1_PERIOD)
    stwio r6, 8(r1)
    movi	r6, r0, %hi(TIMER_1_PERIOD)
    stwio	r6, 12(r1)
	stwio 		r0, (r1)			/* Reset timer */
    movi 		r17, 0b0100
	stwio		r17, 4(r1)			/* Start the timer */
	
	
	poll:	
	ldwio		r17, (r1)
	andi 		r17, r17, 1
	beq 		r17, r0, poll
	
	ret