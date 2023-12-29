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
	;B MAINLOOP
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
	CMP R2, #50		; upper wall
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
	str r8, [r7]
	SUBS R2, R2, R3
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
	str r8, [r7]
	ADDS R2, R2, R3
	

contCompY
	STRH R2, [R0] 

	;B Draw_Ball_GLOOP
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
	str r8, [r7]
	SUBS R2, R2, R3
	B contCompX
xPos
; set x to be +ve moving
	ldr r7, =x_negative
	ldrh r8, [r7]
	mov r8, #0
	str r8, [r7]
	ADDS R2, R2, R3
    
contCompX
	; store new position in ball x
	
    STRH R2, [R1]


Draw_Ball_GLOOP
	LDR R0, =ballX
	LDRH R2 , [R0]
	LDR R0, =ballY
	LDRH R5 , [R0]
	
	LDR R10, =WHITE
	BL DRAW_BALL
	bl delay_100_MILLIsecond
    B gameLoop
	; Check for collisions with walls
;    LDR R2, =ballX
;    ldrh R0, [R2]
;	LDR R3, =ballVelX
;	ldrh R1, [R3]

;    ADDS R2, R0, R1
;    CMP R2, #316     ; Right wall
;    BGT reverseXVel

;    CMP R0, #4        ; Left wall
;    BLS reverseXVel
	
;    LDR R0, =ballVelX
;    STRH R0, =ballVelX
   ;B noReverseXVel

;reverseXVel
;    LDR R1, =ballVelX
;    ldrh R0 , [R1]
;	NEGS R0, R0
;    STR R0, [R1]

;noReverseXVel

;;     Check for collisions with top and bottom walls

;	LDR R2, =ballY
;    LDR R0, [R2]
;	LDR R3, =ballVelY
;	LDR R1, [R3]

;    ADDS R2, R0, R1

;    CMP R2, #240     ; Bottom wall
;    BGT reverseYVel

;    CMP R0, #33       ; Top wall
;    BLT reverseYVel

;    LDR R0, =ballVelY
;    STRH R0, =ballVelY
;    B noReverseYVel

;reverseYVel
;    LDR R0, =ballVelY
;    NEGS R0, R0
;    STRH R0, =ballVelY

;noReverseYVel

;    ; ... (existing code)

;    BL DRAW_BLOCKS
;    LDR R7, =WHITE
;    BL Draw_Platform
;    BL Draw_Border

;    ; Draw the ball
;    LDR R2, =ballX
;    LDR R5, =ballY
;    LDR R10, =WHITE
;    BL DRAW_BALL

		

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
	PUSH {R0 - R6, R10, LR}
	MOV R0,#40
	ADD R3,R0,#6
	MOV R6,#4
COLSETUP
	MOV R1,#7
	ADD R4,R1,#20
	MOV R5,#13
	LDR R10,=YELLOW
	CMP R6, #2
	BNE ROWSETUP
	LDR R10, =ORANGE
ROWSETUP

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
	POP {R0 - R6, R10, PC}
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
	ADDS R3, R0, #7	; SET Y2
	
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
	str r1, [r0]
	ldr r0 , =SPRITE_Y
	ldr r1 , [r0]
	mov r1 , #221
	str r1, [r0]
	
	ldr r0 , =ballX
	ldr r1 , [r0]
	mov r1 , #160
	str r1, [r0]
	
	ldr r0 , =ballY
	ldr r1 , [r0]
	mov r1 , #50
	str r1, [r0]
	
	ldr r0 , =ballVelX
	ldr r1 , [r0]
	mov r1 , #1
	str r1, [r0]
	
	ldr r0 , =ballVelY
	ldr r1 , [r0]
	mov r1 , #1
	str r1, [r0]

	ldr r0 , =x_negative
	ldr r1 , [r0]
	mov r1 , #0
	str r1, [r0]
	
	ldr r0 , =y_negative
	ldr r1 , [r0]
	mov r1 , #0
	str r1, [r0]
	
		
	ldr r0 , =did_move
	ldr r1 , [r0]
	mov r1 , #0
	str r1, [r0]

	ldr r0 , =moving_right
	ldr r1 , [r0]
	mov r1 , #0
	str r1, [r0]
	
	ldr r0 , =moving_down
	ldr r1 , [r0]
	mov r1 , #0
	str r1, [r0]
	;TODO: INITIALIZE STARTING_X TO 150, NOTICE THAT STARTING_X IS DECLARED AS 16-BITS
	
	
	;TODO: INITIALIZE STARTING_Y TO 170, NOTICE THAT STARTING_Y IS DECLARED AS 16-BITS
	
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