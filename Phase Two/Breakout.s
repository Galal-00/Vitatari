	INCLUDE TFT_Lib.s
	AREA BREAKOUT_CODE, CODE, READONLY

main_Breakout FUNCTION
	PUSH {R0-R12, LR}
    ;This is the main funcion, you should only call two functions, one that sets up the TFT
	;And the other that draws a rectangle over the entire screen (ie from (0,0) to (320,240)) with a certain color of your choice

	 ;PLAN: 13 block in  row , 22 pixel each , 2 PIXEL space between , 5 pixel right ,5 pixel left , 3 brick rows 
	 ;, 20pixel top  
	
	;FINAL TODO: CALL FUNCTION SETUP

	;FINAL TODO: DRAW THE ENTIRE SCREEN WITH A CERTAIN COLOR
	
;MAINLOOP


	;LDR R0, =GPIOC_IDR
	;LDR R1, [R0]
	;MOV R2, #1
	;LSL R2, #13
	;AND R1, R1, R2
	;CMP R1, #0
	;BNE MAINLOOP
	BL INITIALIZE_VARIABLES
	BL DRAW_BLOCKS
	LDR R7, =WHITE
	bl Draw_Platform
	bl Draw_Border
	;48 length , 4 width , 
	
	; Static Draw ball
;	MOV R2, #130
;	MOV R5, #180
;	LDR R10, =WHITE
;	BL DRAW_BALL
	
	MOV R2, #144
	MOV R5, #5
	LDR R10, =WHITE
	BL Draw_Score_Board_Zero
	
	MOV R2, #164
	MOV R5, #5
	LDR R10, =WHITE
	BL Draw_Score_Board_Zero
	
	
gameLoop
		;Check if did_move in prev loop if yes skips moving in this loop
		ldr r5 , =did_move
		ldrh r6 , [r5]
		cmp r6 , #0
		subne r6, #1
		moveq r6, #1
		strh r6, [r5]
		bne ballAnimate
		
		;buttons def
		mov r0, #0
		mov r1, #0
		mov r2, #0x0B00	; PA10 input
		mov r3, #0x0D00 ; PA9 input
		mov r4, #0x0E00 ; PA8 input
		; get input
		ldr r0, =GPIOA_IDR
		ldrh r1, [r0]
		AND r1, r1, #0x0F00
		CMP r1, r2
		beq left
		cmp r1 , r3
		beq right
		b ballAnimate
left
		
		bl MOVE_SPRITE_LEFT
		ldr r4 , =moving_right
		ldrh r6 , [r4]
		mov r6 , #0
		b ballAnimate
right	
		bl MOVE_SPRITE_RIGHT
		ldr r4 , =moving_right
		ldrh r6 , [r4]
		mov r6 , #1
		b ballAnimate
		
ballAnimate
	; Update ball position based on velocity
	
	; delete old ball
	LDR R0, =ballX
	LDRH R2, [R0]
	LDR R0, =ballY
	LDRH R5 , [R0]
	
	LDR R10, =BLACK
	BL DRAW_BALL
    
; VERTICAL MOVMENT
    LDR R0, =ballY
	LDRH R2, [R0]
    LDR R1, =ballVelY
	LDRH R3, [R1]
    ; check collision y
	ldr r7, =y_negative
	ldrh r8, [r7]
	CMP r8, #1
	BEQ check_y_neg_CMP
check_y_pos_CMP
	CMP R2, #215     ; bottom wall
	BGE check_platform
	ADDS R2, R2, R3
	B contCompY
check_y_neg_CMP
	CMP R2, #43		; upper wall
	BLE yPos
    SUBS R2, R2, R3
	B contCompY
check_platform
	ldr r5, =SPRITE_X	; get current X
	ldrh r6, [r5]
	add r7, r6, #47	; platform width
	ldr r5, =ballX	; get ball X
	ldrh r8, [r5]
	CMP r6, r8
	BGT contCompY
	CMP r7, r8
	BLT contCompY
	
	
yNeg
; set x to be -ve moving
	ldr r7, =y_negative
	ldrh r8, [r7]
	mov r8, #1
	strh r8, [r7]
	SUBS R2, R2, R3
	ldr r5, =did_move
	ldr r6, [r5]
	CMP r6, #1
	SUBEQ r2, r2, #1
	;increament x for deflection
	
;	ldr r9 , =ballX
;	ldrh r10 , [r9]
;	add r10 , r10 , #3
;	strh r10 , [r9]
	B contCompY
yPos
; set x to be +ve moving
	ldr r7, =y_negative
	ldrh r8, [r7]
	mov r8, #0
	strh r8, [r7]
	ADDS R2, R2, R3

contCompY
	LDR R0, =ballY
	STRH R2, [R0] 
	
	
	
;Horizontal movement
	LDR R1, =ballX
	LDRH R2, [R1]
    ;LDR R1, =ballVelX
	;LDRH R3, [R1]
	; check collision x
	ldr r7, =x_negative
	ldrh r8, [r7]
	CMP r8, #1
	BEQ check_x_neg_CMP
check_x_pos_CMP
	CMP R2, #306     ; Right wall
	BGE xNeg
	ADDS R2, R2, R3
	B contCompX
check_x_neg_CMP
	CMP R2, #9		; Left wall
	BLE xPos
    SUBS R2, R2, R3
	B contCompX
xNeg
; set x to be -ve moving
	ldr r7, =x_negative
	ldrh r8, [r7]
	mov r8, #1
	strh r8, [r7]
	SUBS R2, R2, R3
	B contCompX
xPos
; set x to be +ve moving
	ldr r7, =x_negative
	ldrh r8, [r7]
	mov r8, #0
	strh r8, [r7]
	ADDS R2, R2, R3
    
contCompX
	; store new position in ball x
    STRH R2, [R1]

checky
	mov r10, #0
check_collision
	LDR R4, =ballX
	LDRH R5 , [R4]
	ADD r11 , r5, #4 ; right (x2) ball hitbox 
	subs r12 , r5,#4 ; left (x1) ball hitbox
	LDR R6, =ballY
	LDRH R7 , [R6]
	ADD r4 , R7 , #4 ; bottom (y2) of the ball
	sub r5, r7, #4	; top (y1) of the ball
	ldr r2, =BLOCK_ARMY_X	; get block X
	ldrh r1, [r2, r10]	;X1
	CMP r1, #0
	BEQ repeat_check
	ldr r3, =BLOCK_ARMY_Y	; get block Y
	ldrh r0, [r3, r10]	;Y1
	add r8, r1, #20	; block X2
	add r9, r0, #6	; block Y2
	
	CMP r1, r11
	BGT repeat_check
	CMP r8, r12
	BLT repeat_check
	
	CMP R5, R9
	BGT repeat_check
	CMP R4, R0
	BLT repeat_check

has_collided
	; reverse y dir
	ldr r7, =y_negative
	ldrh r8, [r7]
	eor r8, #0x0001
	strh r8, [r7]
	; delete block
	ldr r3, =BLOCK_HEALTH
	LDRH r4, [r3, r10]
	CMP r4, #0
	subne r4, #1
	strh r4, [r3, r10]
convert_cyan
	cmp r4, #2
	BNE convert_yellow
	BL DRAW_BLOCK_CYAN
convert_yellow
	CMP r4, #1
	BNE convert_none
	BL DRAW_BLOCK_YELLOW
convert_none
	CMP r4, #0
	BNE Draw_Ball_GLOOP
	BL DEL_BLOCK
	mov r1, #0
	strh r1, [r2, r10]
	ldr r8 , =breakout_score
	ldr r9 , [r8]
	ADD r9 ,r9 , #1
	B Draw_Ball_GLOOP
	
repeat_check
	add r10, r10, #2
	CMP r10, #140
	BEQ Draw_Ball_GLOOP
	B check_collision

Draw_Ball_GLOOP
	LDR R0, =ballX
	LDRH R2 , [R0]
	LDR R0, =ballY
	LDRH R5 , [R0]
	
	LDR R10, =WHITE
	BL DRAW_BALL
	bl delay_100_MILLIsecond
    B gameLoop

Stop_Breakout
		B Stop_Breakout
		POP {R0-R12, PC}
		ENDFUNC
		
;############

DRAW_BLOCKS FUNCTION
	; R0: HEIGHT Y1
	; R1: WIDTH X1
	; R3: HEIGHT Y2
	; R4: WIDTH X2
	PUSH {R0 - R12, LR}
	MOV R0,#40
	ADD R3,R0,#6
	MOV R6,#4
	ldr r7, =BLOCK_ARMY_X
	ldr r9, =BLOCK_ARMY_Y
	LDR R11, =BLOCK_HEALTH
	mov r8, #0
	MOV R12, #1 ; HEALTH COUNTER (SINGLE HEALTH)
COLSETUP
	MOV R1,#7
	ADD R4,R1,#20
	MOV R5,#13
	LDR R10,=YELLOW
	CMP r6, #4
	BLT ORANGE_BLOCKS
	LDR r10, =ORANGE
	B ROWSETUP
ORANGE_BLOCKS
	CMP R6, #2
	BNE ROWSETUP
	LDR R10, =CYAN
ROWSETUP
	strh r1, [r7, r8]
	strh r0, [r9, r8]
	CMP R6, #2
	ADDEQ R12, R12, #1 ; DOUBLE HEALTH
	CMP R6, #4
	ADDEQ R12, R12, #2 ; TRIPLE HEALTH
	STRH R12, [R11, R8]	; HEALTH INIT
	MOV R12, #1
	add r8, r8, #2
	bl DRAW_RECTANGLE_FILLED
	ADD R1, R1, #22
	ADD R4, R4, #22
	SUBS R5,R5,#1
	CMP R5,#0
	BGE ROWSETUP
	ADD R0,R0,#9
	ADD R3,R3,#9
	SUBS R6,R6,#1
	CMP R6,#0
	BGE COLSETUP
	POP {R0 - R12, PC}
	ENDFUNC
	
DRAW_BLOCK FUNCTION
	; R0: HEIGHT Y1
	; R1: WIDTH X1
	; R3: HEIGHT Y2
	; R4: WIDTH X2
	; R10: COLOR
	PUSH {R0 - R12, LR}
	ADD R3,R0,#6
	ADD R4,R1,#20
	BL DRAW_RECTANGLE_FILLED
	POP {R0 - R12, PC}
	ENDFUNC

DRAW_BLOCK_YELLOW FUNCTION
	; R0: HEIGHT Y1
	; R1: WIDTH X1
	; R3: HEIGHT Y2
	; R4: WIDTH X2
	; R10: COLOR
	PUSH {R0 - R12, LR}
	LDR R10, =YELLOW
	BL DRAW_BLOCK
	POP {R0 - R12, PC}
	ENDFUNC
DRAW_BLOCK_CYAN FUNCTION
	; R0: HEIGHT Y1
	; R1: WIDTH X1
	; R3: HEIGHT Y2
	; R4: WIDTH X2
	; R10: COLOR
	PUSH {R0 - R12, LR}
	LDR R10, =CYAN
	BL DRAW_BLOCK
	POP {R0 - R12, PC}
	ENDFUNC

DEL_BLOCK FUNCTION
	; R0: HEIGHT Y1
	; R1: WIDTH X1
	; R3: HEIGHT Y2
	; R4: WIDTH X2
	; R10: COLOR
	PUSH {R0 - R12, LR}
	LDR R10, =BLACK
	BL DRAW_BLOCK
	POP {R0 - R12, PC}
	ENDFUNC

;xr2:144 yr5:5
Draw_Score_Board_Zero FUNCTION
	; START_X : R2, START_Y: R5
	PUSH {r0-r5, LR}
	; TOP BORDER
	ADDS R1, R2, #1		; SET X1
	ADDS R0, R5, #0		; SET Y1
	ADDS R4, R1, #10	; SET X2
	ADDS R3, R0, #2		; SET Y2
	BL DRAW_RECTANGLE_FILLED
	
	; LEFT BORDER
	ADDS R1, R2, #0		; SET X1
	ADDS R0, R5, #1		; SET Y1
	ADDS R4, R1, #2		; SET X2
	ADDS R3, R0, #20	; SET Y2
	BL DRAW_RECTANGLE_FILLED
	
	; RIGHT BORDER
	ADDS R1, R2, #10	; SET X1
	ADDS R0, R5, #1		; SET Y1
	ADDS R4, R1, #2		; SET X2
	ADDS R3, R0, #20	; SET Y2
	BL DRAW_RECTANGLE_FILLED
	
	; BOTTOM BORDER
	ADDS R1, R2, #1		; SET X1
	ADDS R0, R5, #20	; SET Y1
	ADDS R4, R1, #10	; SET X2
	ADDS R3, R0, #2		; SET Y2
	BL DRAW_RECTANGLE_FILLED
	
	POP {r0-r5, PC}
	ENDFUNC
	
	B dummyBREAKOUT
	LTORG
dummyBREAKOUT

;#############
DRAW_BALL FUNCTION
	PUSH {R0-R5, R10, LR}
	; R0: HEIGHT Y1
	; R1: WIDTH X1
	; R3: HEIGHT Y2
	; R4: WIDTH X2
	; R2, R5: (X, Y) Center point
	; R10: COLOR
	; 1ST RECTANGLE
	
	
	SUBS R1, R2, #3	; SET X1
	SUBS R0, R5, #1	; SET Y1
	ADDS R4, R1, #7	; SET X2
	ADDS R3, R0, #3	; SET Y2
	
	BL DRAW_RECTANGLE_FILLED
	
	; 2ND RECTANGLE
	ADDS R1, R1, #1	; SET X1
	SUBS R0, R0, #1	; SET Y1
	ADDS R4, R1, #5	; SET X2
	ADDS R3, R0, #5	; SET Y2
	
	BL DRAW_RECTANGLE_FILLED
	
	; 3RD RECTANGLE
	ADDS R1, R1, #1	; SET X1
	SUBS R0, R0, #1	; SET Y1
	ADDS R4, R1, #3	; SET X2
	ADDS R3, R0, #6	; SET Y2
	
	BL DRAW_RECTANGLE_FILLED
	POP {R0-R5, R10, PC}
	ENDFUNC
;##################################
Draw_Platform FUNCTION
	PUSH {r0-r7,r10, LR}
	ldr r5, =SPRITE_Y
	ldr r6 , =SPRITE_X
	ldrh r0 , [r5]
	ldrh r1 , [r6]
	;mov R0, #221		; HEIGHT Y1
	;MOV R1, #150		; WIDTH X1
	ADD R3,R0 , #4		; HEIGHT Y2
	ADD R4,R1,#47   	;WIDTH X2
	MOV R10, R7
	BL DRAW_RECTANGLE_FILLED
	POP {r0-r7,r10, PC}
	ENDFUNC
;###############
MOVE_SPRITE_LEFT	FUNCTION
	PUSH{R0-R12,LR}
	;TODO: CHECK FOR SCREEN BOUNDARIES, IF THE SPRITE TOUCHES A WALL, DON'T MOVE
	
	;TODO: COVER THE SPIRIT WITH THE BACKGROUND COLOR
	
	;TODO: REDRAW THE SPIRIT IN THE NEW COORDINATES AND UPDATE ITS COORDINATES IN THE DATASECTION
	

	 
	
	
	ldr r5, =SPRITE_Y
	ldr r6 , =SPRITE_X
	ldrh r0 , [r5]
	ldrh r1 , [r6]
	subs r1 ,r1 , #5
	;cancel mov cond
	ldr r7 , =0
	cmp r1 ,r7
	ble cancelmov
	
	LDR R7, =BLACK
	bl Draw_Platform
	
	
	
	LDR R7, =WHITE
	strh r1, [r6]
	bl Draw_Platform
	
	
	
cancelmov

	POP{R0-R12,PC}
	ENDFUNC
;##############
MOVE_SPRITE_RIGHT	FUNCTION
	PUSH{R0-R12,LR}
	;TODO: CHECK FOR SCREEN BOUNDARIES, IF THE SPRITE TOUCHES A WALL, DON'T MOVE
	
	;TODO: COVER THE SPIRIT WITH THE BACKGROUND COLOR
	
	;TODO: REDRAW THE SPIRIT IN THE NEW COORDINATES AND UPDATE ITS COORDINATES IN THE DATASECTION
	
	;cancel mov cond
	 
	

	
	ldr r5, =SPRITE_Y
	ldr r6 , =SPRITE_X
	ldrh r0 , [r5]
	ldrh r1 , [r6]
	ADD r1 ,r1 , #5
	ldr r7 , = 270
	cmp r1 ,r7
	bge cancelMovR

	LDR R7, =BLACK
	bl Draw_Platform
	
	LDR R7, =WHITE
	strh r1, [r6]
	bl Draw_Platform
	
	
	
cancelMovR

	POP{R0-R12,PC}
	ENDFUNC
;##############
INITIALIZE_VARIABLES	FUNCTION
	PUSH{R0-R12,LR}
	;THIS FUNCTION JUST INITIALIZES ANY VARIABLE IN THE DATASECTION TO ITS INITIAL VALUES
	;ALTHOUGH WE SPECIFIED SOME VALUES IN THE DATA AREA, BUT THEIR VALUES MIGHT BE ALTERED DURING BOOT TIME.
	;SO WE NEED TO IMPLEMENT THIS FUNCTION THAT REINITIALIZES ALL VARIABLES
	ldr r0 , =SPRITE_X
	ldr r1 , [r0]
	mov r1 , #150
	strh r1, [r0]
	ldr r0 , =SPRITE_Y
	ldr r1 , [r0]
	mov r1 , #221
	strh r1, [r0]
	
	ldr r0 , =ballX
	ldr r1 , [r0]
	mov r1 , #160
	strh r1, [r0]
	
	ldr r0 , =ballY
	ldr r1 , [r0]
	mov r1 , #110
	strh r1, [r0]
	
	ldr r0 , =ballVelX
	ldr r1 , [r0]
	mov r1 , #1
	strh r1, [r0]
	
	ldr r0 , =ballVelY
	ldr r1 , [r0]
	mov r1 , #1
	strh r1, [r0]

	ldr r0 , =x_negative
	ldr r1 , [r0]
	mov r1 , #0
	strh r1, [r0]
	
	ldr r0 , =y_negative
	ldr r1 , [r0]
	mov r1 , #0
	strh r1, [r0]
	
		
	ldr r0 , =did_move
	ldr r1 , [r0]
	mov r1 , #0
	strh r1, [r0]

	ldr r0 , =moving_right
	ldr r1 , [r0]
	mov r1 , #0
	strh r1, [r0]
	
	ldr r0 , =moving_down
	ldr r1 , [r0]
	mov r1 , #0
	strh r1, [r0]
	
	ldr r0 , =breakout_score
	ldr r1 , [r0]
	mov r1 , #0
	strh r1, [r0]
	
	POP{R0-R12,PC}
	ENDFUNC
	
;##############
Draw_Border FUNCTION
	PUSH {r0-r4, LR}
	;Border DRAW
	;top border
	mov R0, #33		; HEIGHT Y1
	MOV R1, #0 	; WIDTH X1
	MOV R3, #37	; HEIGHT Y2
	MOV R4, #320	; WIDTH X2
	LDR R10, =WHITE
	BL DRAW_RECTANGLE_FILLED
	;left border
	mov R0, #33	; HEIGHT Y1
	MOV R1, #0 	; WIDTH X1
	MOV R3, #240	; HEIGHT Y2
	MOV R4, #4	; WIDTH X2
	LDR R10, =WHITE
	BL DRAW_RECTANGLE_FILLED
	;right border
	mov R0, #33	; HEIGHT Y1
	MOV R1, #316 	; WIDTH X1
	MOV R3, #240	; HEIGHT Y2
	MOV R4, #320	; WIDTH X2
	LDR R10, =WHITE
	BL DRAW_RECTANGLE_FILLED
	POP {r0-r4, PC}
	ENDFUNC
	END