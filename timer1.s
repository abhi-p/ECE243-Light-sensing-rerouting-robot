.equ TIMER_1, 0xFF202000

.global _timer1


_timer1:
	movi r18, 0x01
	movia r3, TIMER_1
	stwio r18, 4(r3) 

	br HBInit
		
Mloop:
	br HBCheck

loop2:	
	beq r0, r18, RETURN
	
	
	br Mloop
	
HBInit:
	movia r20, TIMER_1_PERIOD
	sthio r4, 8(r20)
	sthio r5, 12(r20)
	
	stwio r0, 0(r20)
	movi r19, 0x04
	stwio r19, 4(r20)
	br Mloop
	
HBCheck:	
	
	ldwio r19, 0(r20)
	andi r19, r19, 0x01
	beq r19, r0, doneHBC
	addi r18, r18, -1 


	stwio r0, 0(r20) ####### resets timeout 	

doneHBC: br loop2 
	
RETURN: ret
