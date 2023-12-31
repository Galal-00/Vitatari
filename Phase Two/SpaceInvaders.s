	INCLUDE Breakout.s

	AREA SPACE_INVADERS, CODE, READONLY

main_Space FUNCTION
		
	BL INITIALIZE_VARIABLES_space
	; BLACK BG
	LDR R10, =BLACK
	MOV R1, R2	; X1 
	MOV R0, R5	; Y1
	ADD R4, R1, #320	; X2
	ADD R3, R0, #240	; Y2
	BL DRAW_RECTANGLE_FILLED
	
	; GREEN GOBLIN LEGION
	BL DRAW_LEGION
	
	; SPACESHIP COORDNIATES

	ldr R1, =SPACE_X  	;Space_X = Starting x
	ldr R7, =SPACE_Y	;Space_Y = Starting y
	ldrh r2,[r1]
	ldrh r5 , [r7]
	BL DRAW_SPACESHIP
	
	;;;;
	MOV R7,#23
SpaceGLoop
		LDR R0, =GPIOA_ODR
		ldrh r2, [r0]
		ORR r2, #0xFF00
		STRH R2, [R0]
		;buttons def
		mov r0, #0
		mov r1, #0
		mov r2, #0x0B00	; PA10 input
		mov r3, #0x0D00 ; PA9 input
		mov r4, #0x0E00 ; PA8 input
		; get input
		ldr r0, =GPIOA_IDR
		ldr r1, [r0]
		AND r1, r1, #0x0F00
		;;;
		LDR R5,=SPACE_HEALTH
		LDRH R6,[R5]
		MOV R5,R6
		CMP R5,#0
		BEQ STOP
		;;;

		LDR R5,=GREEN_GOBLIN_DEATH_COUNT
		LDRH R6,[R5]
		MOV R5,R6
		CMP R5,#18
		BEQ STOP
		;;;;;;
		
		CMP r1, r2			;See if Button PA7 is pressed then moves left
		beq Spaceleft
		cmp r1 , r3			;See if Button PA9 is pressed then moves right
		beq Spaceright		
		cmp r1 , r4			;See if Button PA8 is pressed then shoot
		beq Shoot
		MOV R11, #0			;if we don't shoot (PA8 not pressed) reset R11 to 0
		
		B GOBLIN_SHOOT
Spaceleft
			bl MOVE_SPACE_LEFT
			b GOBLIN_SHOOT
Spaceright	
			bl MOVE_SPACE_RIGHT
			b GOBLIN_SHOOT
Shoot
;R11 = 1 if PA8 was pressed last loop (for debounce)
			CMP R11, #1
			BEQ BULLET_ANIMATE
			MOV R11, #1
			bl SHOOT_SBULLET
			b GOBLIN_SHOOT
			
GOBLIN_SHOOT
		BL PORTAA_CONF
		CMP R7,#0
		SUB R7,R7,#1
		BL PORTAA_CONF
		BGT BULLET_ANIMATE
		BL PORTAA_CONF
		MOV R7,#23
		BL PORTAA_CONF
		BL SHOOT_GBULLET
BULLET_ANIMATE
			BL PORTAA_CONF
			
			BL MOVE_GBULLETS_DOWN
			BL PORTAA_CONF
			BL MOVE_BULLET_UP
			BL PORTAA_CONF
			bl delay_100_MILLIsecond
			bl delay_100_MILLIsecond
			bl delay_100_MILLIsecond
			bl delay_100_MILLIsecond
			b SpaceGLoop

STOP
	B STOP
    POP {R0-R12, PC}
    ENDFUNC
	
	B DUMMY4	
	LTORG
DUMMY4

PORTAA_CONF  FUNCTION
    PUSH {R0-R2, LR}
    ; Enable GPIOA clock
    LDR R0, =RCC_APB2ENR         ; Address of RCC_APB2ENR register
    LDR R1, [R0]                 ; Read the current value of RCC_APB2ENR
	MOV R2, #1
    ORR R1, R1, R2, LSL #2        ; Set bit 2 to enable GPIOA clock
    STR R1, [R0]                 ; Write the updated value back to RCC_APB2ENR
    
    ; Configure PORT A AS OUTPUT (LOWER 8 PINS)
    LDR R0, =GPIOA_CRL                  
    MOV R2, #0x33333333     ;ALL 8 LOWER PINS OF PORT A AS OUTPUT WITH MAX SPEED OF 50 MHZ
    STR R2, [R0]

    ; Configure PORT A AS OUTPUT (HIGHER 8 PINS)
    LDR R0, =GPIOA_CRH           ; Address of GPIOC_CRH register
    LDR R2, =0x88888888     ;ALL 8 LOWER PINS OF PORT A AS OUTPUT WITH MAX SPEED OF 50 MHZ
    STR R2, [R0]                 ; Write the updated value back to GPIOC_CRH

	; Configure PORT A AS OUTPUT (HIGHER 8 PINS)
    LDR R0, =GPIOA_ODR          ; Address of GPIOC_CRH register
    LDR R2, =0xFF00     ;ALL 8 LOWER PINS OF PORT A AS OUTPUT WITH MAX SPEED OF 50 MHZ
    STR R2, [R0]

    ; Enable GPIOC clock
    LDR R0, =RCC_APB2ENR         ; Address of RCC_APB2ENR register
    LDR R1, [R0]                 ; Read the current value of RCC_APB2ENR
	MOV R2, #1
    ORR R1, R1, R2, LSL #4        ; Set bit 4 to enable GPIOC clock
    STR R1, [R0]                 ; Write the updated value back to RCC_APB2ENR
    
    ; Configure PC13 as input pull up 
    LDR R0, =GPIOC_CRH           ; Address of GPIOC_CRH register
    LDR R1, [R0]                 ; Read the current value of GPIOC_CRH
    MOV R1, #0x88888888      ; Set mode bits for pin 13 (input mode)
    STR R1, [R0]                 ; Write the updated value back to GPIOC_CRH

	LDR R0, =GPIOC_ODR
	MOV R1, #0x00
	STR R1, [R0]


    ; Enable GPIOB clock
    LDR R0, =RCC_APB2ENR         ; Address of RCC_APB2ENR register
    LDR R1, [R0]                 ; Read the current value of RCC_APB2ENR
	MOV R2, #1
    ORR R1, R1, R2, LSL #3        ; Set bit 3 to enable GPIOB clock
    STR R1, [R0]                 ; Write the updated value back to RCC_APB2ENR
    
    
    LDR R0, =GPIOB_CRL           ; Address of GPIOC_CRL register
    MOV R1, #0x33333333      ; Set mode bits for pin 13 (output mode, max speed 50 MHz)
    STR R1, [R0]                 ; Write the updated value back to GPIOC_CRH


    LDR R0, =GPIOB_CRH           ; Address of GPIOC_CRL register
    MOV R1, #0x33333333      ; Set mode bits for pin 13 (output mode, max speed 50 MHz)
    STR R1, [R0]                 ; Write the updated value back to GPIOC_CRH


	




    POP {R0-R2, PC}

    ENDFUNC

DRAW_G_BULLET FUNCTION
	PUSH {r0 - r5, r10, LR}
	; GOBLIN BULLETS
	; R2, R5: (X, Y) TOP LEFT CORNER
	; R10: BULLET COLOR
	
	; HORIZONTAL UPPER RECT
	ADD R1, R2, #0	; X1 
	ADD R0, R5, #0	; Y1
	ADD R4, R1, #5	; X2
	ADD R3, R0, #1	; Y2
	BL DRAW_RECTANGLE_FILLED
	
	; HORIZONTAL LOWER RECT
	ADD R1, R2, #1	; X1 
	ADD R0, R5, #2	; Y1
	ADD R4, R1, #3	; X2
	ADD R3, R0, #1	; Y2
	BL DRAW_RECTANGLE_FILLED
	POP {r0 - r5, r10, PC}

DRAW_S_BULLET FUNCTION
	PUSH {r0-r5, r10, LR}
	; R2, R5: (X, Y) TOP LEFT CORNER
	; R10: BULLET COLOR
	
	; CENTRAL SQUARE
	ADD R1, R2, #1	; X1 
	ADD R0, R5, #2	; Y1
	ADD R4, R1, #3	; X2
	ADD R3, R0, #2	; Y2
	BL DRAW_RECTANGLE_FILLED
	
	; VERTICAL RECT
	ADD R1, R2, #2	; X1 
	ADD R0, R5, #0	; Y1
	ADD R4, R1, #1	; X2
	ADD R3, R0, #5	; Y2
	BL DRAW_RECTANGLE_FILLED
	
	; HORIZONTAL RECT
	ADD R1, R2, #0	; X1 
	ADD R0, R5, #3	; Y1
	ADD R4, R1, #5	; X2
	ADD R3, R0, #0	; Y2
	BL DRAW_RECTANGLE_FILLED
	
	POP {r0-r5, r10, PC}
	ENDFUNC

DRAW_SPACESHIP FUNCTION
	PUSH {R0-R5, R10, LR}
	; SPACESHIP
	; R2, R5: (X, Y) TOP LEFT CORNER
	
	; BOTTOM HORIZONTAL WHITE RECT
	LDR R10, =WHITE
	ADD R1, R2, #3	; X1 
	ADD R0, R5, #21	; Y1
	ADD R4, R1, #15	; X2
	ADD R3, R0, #1	; Y2
	BL DRAW_RECTANGLE_FILLED
	
	; MIDDLE HORIZONTAL WHITE RECT
	LDR R10, =WHITE
	ADD R1, R2, #0	; X1 
	ADD R0, R5, #18	; Y1
	ADD R4, R1, #21	; X2
	ADD R3, R0, #2	; Y2
	BL DRAW_RECTANGLE_FILLED
	
	; MIDDLE HORIZONTAL BLUE RECT
	LDR R10, =BLUE
	ADD R1, R2, #0	; X1 
	ADD R0, R5, #16	; Y1
	ADD R4, R1, #21	; X2
	ADD R3, R0, #1	; Y2
	BL DRAW_RECTANGLE_FILLED
	
	; MIDDLE VERTICAL BLUE OUTLINE
	LDR R10, =BLUE
	ADD R1, R2, #6	; X1 
	ADD R0, R5, #11	; Y1
	ADD R4, R1, #9	; X2
	ADD R3, R0, #4	; Y2
	BL DRAW_RECTANGLE_FILLED
	
	; INNER VERTICAL BLUE OUTLINE
	LDR R10, =BLUE
	ADD R1, R2, #8	; X1 
	ADD R0, R5, #4	; Y1
	ADD R4, R1, #5	; X2
	ADD R3, R0, #6	; Y2
	BL DRAW_RECTANGLE_FILLED
	
	; POINTY RED HEAD
	LDR R10, =RED
	ADD R1, R2, #9	; X1 
	ADD R0, R5, #0	; Y1
	ADD R4, R1, #3	; X2
	ADD R3, R0, #2	; Y2
	BL DRAW_RECTANGLE_FILLED
	
	; LEFT WING RED BLASTERS
	LDR R10, =RED
	ADD R1, R2, #0	; X1 
	ADD R0, R5, #10	; Y1
	ADD R4, R1, #3	; X2
	ADD R3, R0, #5	; Y2
	BL DRAW_RECTANGLE_FILLED
	
	; RIGHT WING RED BLASTERS
	LDR R10, =RED
	ADD R1, R2, #18	; X1 
	ADD R0, R5, #10	; Y1
	ADD R4, R1, #3	; X2
	ADD R3, R0, #5	; Y2
	BL DRAW_RECTANGLE_FILLED
	
	; LEFT WING WHITE
	LDR R10, =WHITE
	ADD R1, R2, #0	; X1 
	ADD R0, R5, #13	; Y1
	ADD R4, R1, #2	; X2
	ADD R3, R0, #2	; Y2
	BL DRAW_RECTANGLE_FILLED
	
	; RIGHT WING WHITE
	LDR R10, =WHITE
	ADD R1, R2, #19	; X1 
	ADD R0, R5, #13	; Y1
	ADD R4, R1, #2	; X2
	ADD R3, R0, #2	; Y2
	BL DRAW_RECTANGLE_FILLED
	
	; BOTTOM RED BOOSTERS
	LDR R10, =RED
	ADD R1, R2, #8	; X1 
	ADD R0, R5, #23	; Y1
	ADD R4, R1, #5	; X2
	ADD R3, R0, #1	; Y2
	BL DRAW_RECTANGLE_FILLED
	
	; LEFT BLUE BOOSTER
	LDR R10, =BLUE
	ADD R1, R2, #6	; X1 
	ADD R0, R5, #23	; Y1
	ADD R4, R1, #3	; X2
	ADD R3, R0, #0	; Y2
	BL DRAW_RECTANGLE_FILLED
	
	; RIGHT BLUE BOOSTER
	LDR R10, =BLUE
	ADD R1, R2, #12	; X1 
	ADD R0, R5, #23	; Y1
	ADD R4, R1, #3	; X2
	ADD R3, R0, #0	; Y2
	BL DRAW_RECTANGLE_FILLED
	
	; UPPER WHITE VERTICAL BODY
	LDR R10, =WHITE
	ADD R1, R2, #9	; X1 
	ADD R0, R5, #5	; Y1
	ADD R4, R1, #3	; X2
	ADD R3, R0, #6	; Y2
	BL DRAW_RECTANGLE_FILLED
	
	; MIDDLE WHITE VERTICAL BODY
	LDR R10, =WHITE
	ADD R1, R2, #7	; X1 
	ADD R0, R5, #12	; Y1
	ADD R4, R1, #7	; X2
	ADD R3, R0, #5	; Y2
	BL DRAW_RECTANGLE_FILLED
	
	; MIDDLE RED DOT
	LDR R10, =RED
	ADD R1, R2, #9	; X1 
	ADD R0, R5, #13	; Y1
	ADD R4, R1, #3	; X2
	ADD R3, R0, #3	; Y2
	BL DRAW_RECTANGLE_FILLED
	POP {R0-R5, R10, PC}
	ENDFUNC
	
DRAW_LEGION FUNCTION
	PUSH {R0-R12, LR}
	; CREATE LEGION OF GOBLINS
	; R2, R5: STARTING X, Y
	LDR R3, =GREEN_GOBLIN_X
	LDR R4, =GREEN_GOBLIN_Y
	LDR R7, =GREEN_GOBLIN_HEALTH	
	MOV R8, #2
	MOV R6,#0
	
	MOV R5, #46		;Y
	MOV R0, #2  ;MOVE VERTICALLY
LEGION_COLUMN
	MOV R2,#24	;X
	MOV R1, #5	;MOVE HORIZONTALLY
LEGION_ROW
	; DRAW GREEN GOBLIN SPRITE
	BL DRAW_GREEN_GOBLIN
	strh R2,[R3,R6]
	strh R5,[R4,R6]
	strh R8,[R7,R6]
	ldrh R12,[R3,R6]
	add R6,R6,#2
	ADD R2, R2, #49
	SUBS R1,R1,#1
	CMP R1, #0
	BGE LEGION_ROW
	ADD R5, R5, #31
	SUBS R0,R0,#1
	CMP R0, #0
	BGE LEGION_COLUMN
	POP {R0-R12, PC}
	ENDFUNC
DEL_GREEN_GOBLIN FUNCTION
	PUSH {R0-R4, R10, LR}
	
	; DELETE GREEN GOBLIN
	; R2, R5: STARTING X, Y OF SPRITE
	
	LDR R10, =BLACK
	MOV R1, R2	; X1 
	MOV R0, R5	; Y1
	ADD R4, R1, #34	; X2
	ADD R3, R0, #21	; Y2
	BL DRAW_RECTANGLE_FILLED
	
	POP {R0-R4, R10, PC}
	ENDFUNC

DRAW_GREEN_GOBLIN FUNCTION
	PUSH {R0-R5, R10, LR}
	; GREEN GOBLIN SPRITE
	
	; R2, R5: (X, Y) TOP LEFT CORNER
	; MIDDLE BG GREEN RECTANGLE
	LDR R10, =GREEN
	ADD R1, R2, #0	; X1 
	ADD R0, R5, #8	; Y1
	ADD R4, R1, #34	; X2
	ADD R3, R0, #7	; Y2
	BL DRAW_RECTANGLE_FILLED
	
	; MIDDLE BG RED RECTANGLE
	LDR R10, =RED
	ADD R1, R2, #1	; X1 
	ADD R0, R5, #9	; Y1
	ADD R4, R1, #32	; X2
	ADD R3, R0, #5	; Y2 
	BL DRAW_RECTANGLE_FILLED
	
	; MIDDLE TOP BG GREEN RECTANGLE
	LDR R10, =GREEN
	ADD R1, R2, #2	; X1 
	ADD R0, R5, #3	; Y1
	ADD R4, R1, #30	; X2
	ADD R3, R0, #8	; Y2 
	BL DRAW_RECTANGLE_FILLED
	
	; TOP BG GREEN RECTANGLE
	LDR R10, =GREEN
	ADD R1, R2, #8	; X1 
	ADD R0, R5, #0	; Y1
	ADD R4, R1, #19	; X2
	ADD R3, R0, #3	; Y2 
	BL DRAW_RECTANGLE_FILLED
	
	; LEFT EYE BG RED RECTANGLE
	LDR R10, =RED
	ADD R1, R2, #10	; X1 
	ADD R0, R5, #5	; Y1
	ADD R4, R1, #2	; X2
	ADD R3, R0, #4	; Y2 
	BL DRAW_RECTANGLE_FILLED
	
	; RIGHT EYE BG RED RECTANGLE
	LDR R10, =RED
	ADD R1, R2, #23	; X1 
	ADD R0, R5, #5	; Y1
	ADD R4, R1, #2	; X2
	ADD R3, R0, #4	; Y2 
	BL DRAW_RECTANGLE_FILLED
	
	; 1ST LEG BG RED RECTANGLE
	LDR R10, =GREEN
	ADD R1, R2, #3	; X1 
	ADD R0, R5, #13	; Y1
	ADD R4, R1, #4	; X2
	ADD R3, R0, #8	; Y2 
	BL DRAW_RECTANGLE_FILLED
	
	; 2ND LEG BG RED RECTANGLE
	LDR R10, =GREEN
	ADD R1, R2, #11	; X1 
	ADD R0, R5, #13	; Y1
	ADD R4, R1, #4	; X2
	ADD R3, R0, #8	; Y2 
	BL DRAW_RECTANGLE_FILLED
	
	; 3RD LEG BG RED RECTANGLE
	LDR R10, =GREEN
	ADD R1, R2, #19	; X1 
	ADD R0, R5, #13	; Y1
	ADD R4, R1, #4	; X2
	ADD R3, R0, #8	; Y2 
	BL DRAW_RECTANGLE_FILLED
	
	; 4TH LEG BG RED RECTANGLE
	LDR R10, =GREEN
	ADD R1, R2, #27	; X1 
	ADD R0, R5, #13	; Y1
	ADD R4, R1, #4	; X2
	ADD R3, R0, #8	; Y2 
	BL DRAW_RECTANGLE_FILLED
	
	POP {R0-R5, R10, PC}
	ENDFUNC		
;###################
	B DUMMY3	
	LTORG
DUMMY3
INITIALIZE_VARIABLES_space	FUNCTION
	PUSH{R0-R12,LR}
	;THIS FUNCTION JUST INITIALIZES ANY VARIABLE IN THE DATASECTION TO ITS INITIAL VALUES
	;ALTHOUGH WE SPECIFIED SOME VALUES IN THE DATA AREA, BUT THEIR VALUES MIGHT BE ALTERED DURING BOOT TIME.
	;SO WE NEED TO IMPLEMENT THIS FUNCTION THAT REINITIALIZES ALL VARIABLES
	ldr r0 , =SPACE_X
	ldr r1 , [r0]
	mov r1 , #250	;starting position y
	str r1, [r0]
	ldr r0 , =SPACE_Y
	ldr r1 , [r0]
	mov r1 , #200	;starting position y
	str r1, [r0]
	
	
	ldr r0 , =SPACE_HEALTH
	ldr r1 , [r0]
	mov r1 , #3	;HEALTH
	str r1, [r0]
	;######
	ldr r0 ,=BULLET_MEMORY_X
	mov r1,#0
	strh r1,[r0]		;X1
	strh r1,[r0,#2]		;X2
	strh r1,[r0,#4]		;X3
	strh r1,[r0,#6]		;Y1
	strh r1,[r0,#8]		;Y2
	strh r1,[r0,#10]	;Y3
	;#####
	ldr r0 ,=GOBLIN_BULLETS_X
	mov r1,#0
	strh r1,[r0]		;Bullet 1 X
	strh r1,[r0,#2]		;Bullet 2 X
	strh r1,[r0,#4]		;Bullet 3 X
	strh r1,[r0,#6]		;Bullet 4 X
	strh r1,[r0,#8]		;Bullet 5 X
	;#####
	ldr r0 ,=GOBLIN_BULLETS_Y
	mov r1,#0
	strh r1,[r0]		;Bullet 1 Y
	strh r1,[r0,#2]		;Bullet 2 Y
	strh r1,[r0,#4]		;Bullet 3 Y
	strh r1,[r0,#6]		;Bullet 4 Y
	strh r1,[r0,#8]		;Bullet 5 Y
	;###################
	LDR R0,=GREEN_GOBLIN_DEATH_COUNT
	mov r1,#0
	strh r1,[r0]
	
	POP{R0-R12,PC}
	ENDFUNC
;#########################
COVER_SPACESHIP	FUNCTION
	PUSH{R0-R12,LR}
	
	;SPRITE_X: STARTING X
	;SPRITE_Y: STARTING Y
	;BOTH ARGUMENTS ARE INITIALLY STORED INSIDE THE DATASECTION
	
	;COLOR = [] r10
	;R1 SET X1
	;R0 SET Y1
	;R4 SET X2
	;R3 SET Y2
	
	;TODO: COVER THE SPIRIT WITH THE BACKGROUND COLOR
	ldr r5, =SPACE_X
	ldr r6, =SPACE_Y
	ldrh r1, [r5]
	ldrh r0, [r6]
	mov r4, r1
	add r4, r4, #21	;SpaceShip Width
	mov r3, r0
	add r3, r3, #24 ;SpaceShip Height
	
	
	ldr r10, =BLACK
	BL DRAW_RECTANGLE_FILLED
	
	
	POP{R0-R12,PC}
	ENDFUNC
	

;#####################################
MOVE_SPACE_RIGHT	FUNCTION
	PUSH{R0-R12,LR}
	;CHECK FOR SCREEN BOUNDARIES, IF THE SPRITE TOUCHES A WALL, DON'T MOVE
	ldr r7, =SPACE_X
	ldrh r0, [r7]
	ADD r0, r0, #10 ;move in x axis by 10 pixils
	ldr r1 , = 299	;right screen boundries 
	CMP r0,r1		;Check for collisions
	BGE cancelmovRight
	
	;COVER THE SPACESHIP WITH THE BACKGROUND COLOR
	BL COVER_SPACESHIP
	
	;REDRAW THE SPACESHIP IN THE NEW COORDINATES AND UPDATE ITS COORDINATES IN THE DATASECTION

	; R2, R5: (X, Y) TOP LEFT CORNER
	ldr r6, =SPACE_Y
	ldrh r5, [r6]
	mov r2, r0
	BL DRAW_SPACESHIP
	strh r0, [r7] 	;Update SPAXE_X to new position
	
cancelmovRight

	POP{R0-R12,PC}
	ENDFUNC
;#############
MOVE_SPACE_LEFT	FUNCTION
	PUSH{R0-R12,LR}
	;CHECK FOR SCREEN BOUNDARIES, IF THE SPRITE TOUCHES A WALL, DON'T MOVE
	ldr r7, =SPACE_X
	ldrh r0, [r7]
	SUBS r0, r0, #10 ;move left by 10 pixils
	CMP r0,#0		;check for left screen boundry
	BLE cancelmovLeft
	;COVER THE SPACESHIP WITH THE BACKGROUND COLOR
	BL COVER_SPACESHIP
	
	;REDRAW THE SPACESHIP IN THE NEW COORDINATES AND UPDATE ITS COORDINATES IN THE DATASECTION

	; R2, R5: (X, Y) TOP LEFT CORNER

	ldr r6, =SPACE_Y
	ldrh r5, [r6]	
	mov r2, r0
	BL DRAW_SPACESHIP
	strh r0, [r7]

cancelmovLeft

	POP{R0-R12,PC}
	ENDFUNC
;##########################
SHOOT_SBULLET	FUNCTION
	PUSH{R0-R12,LR}
	
	; R2, R5: (X, Y) TOP LEFT CORNER 
	; R10: BULLET COLOR

	;R8 [R8,2] [R8,4] = X1, X2, X3
	;[R8,6] [R8,8] [R8,10] = Y1, Y2, Y3
	
	ldr R8, =BULLET_MEMORY_X
	ldrh R1, [R8]	;X1
	ldrh R2,[R8,#2] ;X2
	ldrh R3,[R8,#4]	;X3
	ldrh R4,[R8,#6]	;Y1
	ldrh R5,[R8,#8]	;Y2
	ldrh R6,[R8,#10];Y3
	LDR R10, =WHITE
	
;If X = 0 then a bullet can be fired

cmpX1	
	cmp R1,#0	
	bne cmpX2 ;if it can't be fired check the next bullet
	PUSH{R2,R5}
	ldr r7, =SPACE_X
	ldrh r2, [r7]
	ADD r2, r2, #8
	MOV r5,#190
	BL DRAW_S_BULLET
	strh r2,[R8]		;Update the coordinates of the bullet 
	strh r5,[R8,#6]
	POP{R2,R5}
	b noShoot
cmpX2
	cmp R2,#0
	bne cmpX3
	PUSH{R2,R5}
	ldr r7, =SPACE_X
	ldrh r2, [r7]
	ADD r2, r2, #8
	MOV r5,#190
	BL DRAW_S_BULLET
	strh r2,[R8,#2]
	strh r5,[R8,#8]
	POP{R2,R5}
	b noShoot
cmpX3
	cmp R3,#0
	bne noShoot
	PUSH{R2,R5}
	ldr r7, =SPACE_X
	ldrh r2, [r7]
	ADD r2, r2, #8
	MOV r5,#190
	BL DRAW_S_BULLET
	strh r2,[R8,#4]
	strh r5,[R8,#10]
	POP{R2,R5}

noShoot
	POP{R0-R12,PC}
	ENDFUNC	
	
;##########################
MOVE_BULLET_UP FUNCTION
	; R2, R5: (X, Y) TOP LEFT CORNER
	; R10: BULLET COLOR

	;R8 [R8,2] [R8,4] = X1, X2, X3
	;[R8,6] [R8,8] [R8,10] = Y1, Y2, Y3
	PUSH{R0-R12,LR}
	MOV R0,#0
	MOV R12,#0	;Counter to loop on the Goblin array
	ldr R8, =BULLET_MEMORY_X
	ldrh R1, [R8]	;X1
	ldrh R2,[R8,#2] ;X2
	ldrh R3,[R8,#4]	;X3
	ldrh R4,[R8,#6]	;Y1
	ldrh R5,[R8,#8]	;Y2
	ldrh R6,[R8,#10];Y3
cmpX11	
	cmp R1,#0   				
	beq cmpX22
	PUSH{R2,R5}
	MOV r2, R1
	MOV r5, R4
	LDR R10, =BLACK
	BL DRAW_S_BULLET
	SUB r5, r5, #3
	BL KILL
	CMP R12 , #1
	BEQ set_X1_0
	LDR R10, =WHITE
	BL DRAW_S_BULLET			;Draw the bullet in new location
	strh r5,[R8,#6]				;Update Y1
	POP{R2,R5}
	b cmpX22
set_X1_0
	strh r0,[r8]
	POP{R2,R5}
	
cmpX22
	cmp R2,#0
	beq cmpX33
	LDR R10, =BLACK
	BL DRAW_S_BULLET
	SUB r5, r5, #3
	BL KILL
	CMP R12 , #1
	BEQ set_X2_0
	LDR R10, =WHITE
	BL DRAW_S_BULLET
	strh r5,[R8,#8]
	b cmpX33
	
set_X2_0
	strh r0,[r8,#2]
	
	
cmpX33
	cmp R3,#0
	beq NoMove
	PUSH{R2,R5}
	MOV r2, R3
	MOV r5, R6
	LDR R10, =BLACK
	BL DRAW_S_BULLET
	SUB r5, r5, #3
	BL KILL
	CMP R12 , #1
	BEQ set_X3_0
	LDR R10, =WHITE
	BL DRAW_S_BULLET
	strh r5,[R8,#10]
	POP{R2,R5}
	b NoMove
set_X3_0
	strh r0,[r8,#4]
	POP{R2,R5}

NoMove
	POP{R0-R12,PC}
	ENDFUNC
;########################
KILL FUNCTION
	;R2 = x , R5 = y
	
	PUSH{R0-R11,LR}
	LDR R1, =GREEN_GOBLIN_X
	LDR R7, =GREEN_GOBLIN_Y
	LDR R8, =GREEN_GOBLIN_DEATH_COUNT
	LDR R9,	=GREEN_GOBLIN_HEALTH	
	MOV R0, #0
	

CHECK_COLLISION
	ldrh R3,[R1,R0]  ;X1 GOBLIN
	ldrh R4,[R7,R0]  ;Y1 GOBLIN
	ldrh R11,[R9,R0] ;Goblin Health
	ADD R4,R4,#21	 ;Y2 GOBLIN
	ADD R6,R3,#34    ;X2 GOBLIN
	SUB R3,R3,#5
	CMP R0,#36		;last position in array
	BEQ CHECKS_FINISHED
	ADD R0,#2		;increment array index
	CMP R11,#0		;goblin already dead
	BEQ CHECK_COLLISION
	CMP R2,R3		;Bullet X with Goblin x1
	BLT CHECK_COLLISION
	CMP R2,R6		;Bullet X with Goblin x2
	BGT CHECK_COLLISION
	CMP R5,R4		;Bullet Y with Y position of Goblin
	BGT CHECK_COLLISION
	; DELETE GREEN GOBLIN
	; R2, R5: STARTING X, Y OF SPRITE
	PUSH{R0-R11}
	ADD R3,R3,#5
	MOV R2,R3
	MOV R5,R4
	SUB R5,R5,#21
	SUB R0,R0,#2
	SUB R11,R11,#1
	STRH R11,[R9,R0] 	
	CMP R11,#0
	BNE SKIP_GOBLIN_DELETE
	BL DEL_GREEN_GOBLIN
	LDRH R10,[R8]
	ADD R10,R10,#1
	STRH R10,[R8]
SKIP_GOBLIN_DELETE
	POP{R0-R11}
	MOV R12 , #1
	B GOOUT
	;set x0
CHECKS_FINISHED
	MOV R12 , #1	
	CMP R5, #25
	BLE GOOUT
	MOV R12 , #0
GOOUT
	POP{R0-R11,PC}
	ENDFUNC
	
;######################################
SHOOT_GBULLET FUNCTION
	PUSH{R0-R12,LR}
	LDR R0,=SPACE_X
	LDRH R1,[R0]	
	MOV R0, R1     			  ;R0 X0 of spaceship
	ADD R0,R0,#10     			  ;R0 X midpoint of spaceship
	LDR R1,=GREEN_GOBLIN_X    ;R1 ADDRESS GREEN GOBLIN X
	LDR R2,=GREEN_GOBLIN_Y	  ;R2 ADDRESS GREEN GOBLIN Y
	LDR R6,=GREEN_GOBLIN_HEALTH ;R6 ADDRESS GREEN GOBLIN HEALTH
	LDR R9,=GOBLIN_BULLETS_X    ;X OF GOBLIN BULLETS
	LDR R11,=GOBLIN_BULLETS_Y   ;y OF GOBLIN BULLETS
	MOV R3,#34		          ;R3 GOBLIN ARRAY INDEX
	
SHOOTING_LOOP
	CMP  R3,#24
	BLT END_SHOOT_LOOP
	LDRH R4,[R1,R3]           ;R4 X1 OF GREEN GOBLIN
	ADD  R5,R4,#34            ;R5 X2 OF GREEN_GOBLIN
	SUB  R3,R3,#2
	CMP	 R0,R4                ;CHECKING BOUNDARIES OF X1
	BLT  SHOOTING_LOOP      
	CMP  R0,R5                ;CHECKING BOUNDARIES OF X2
	BGT  SHOOTING_LOOP
	ADD R3,R3,#2
COLUMN_COMPARE
	LDRH R7,[R6,R3]           ;R7 HEALTH OF GREEN GOBLIN
	CMP R7,#0
	BEQ CHANGE_COLUMN
	LDRH R8,[R2,R3]           ;VALUE OF GOBLIN Y1
	PUSH {R2,R5}
	MOV R2,R4       		  ;VALUE OF X1 IN R2
	ADD R2,R2,#14           ;MIDDLE OF GREEN GOBLIN
	MOV R5,R8
	ADD R5,R5,#22             ;Y2 OF GOBLIN
	LDR R10,=GREEN
	BL STORE_GOBLIN_BULLETS
	CMP R12,#0
	BEQ END_SHOOT_LOOP2
	BL DRAW_G_BULLET
	POP {R2,R5}
	B END_SHOOT_LOOP
CHANGE_COLUMN
	SUB	R3,R3,#12	  ;GO UP ONE ROW IF THE LAST ONE IS DEAD
	CMP R3,#0
	BLT END_SHOOT_LOOP
	B COLUMN_COMPARE
END_SHOOT_LOOP2
	POP{R2,R5}
	
END_SHOOT_LOOP
	POP{R0-R12,PC}
	
	ENDFUNC
;####################################
STORE_GOBLIN_BULLETS FUNCTION
		;R2 = x , R5 = y
		;R12 = 1 IF SUCCESSFUL, IF FAIL = 0 
	PUSH{R0-R11,LR}
	MOV R0,#0					;LOOP INDEX
	LDR R3, =GOBLIN_BULLETS_X	
	LDR R4, =GOBLIN_BULLETS_Y
	MOV R12,#0					;STATUS 1 IF SUCCESSFUL, IF FAIL = 0 
STORE_LOOP
	CMP R0,#10
	BEQ END_STORE_LOOP
	LDRH R6,[R3,R0]				;X VALUE 0 IF EMPTY
	ADD R0,R0,#2
	CMP R6,#0					;IF THERE EXIST A BULLET CHECK FOR ANOTHER EMPTY SPOT
	BNE STORE_LOOP
	SUB R0,R0,#2
	STRH R2,[R3,R0]				;STORES X IN BULLET X
	STRH R5,[R4,R0]				;STORES Y IN BULLET Y
	MOV R12,#1
END_STORE_LOOP	
	POP{R0-R11,PC}
	ENDFUNC
	B DUMMMMMM
	LTORG
DUMMMMMM
;################################################
MOVE_GBULLETS_DOWN FUNCTION
	PUSH{R0-R12,LR}
	LDR R0,=GOBLIN_BULLETS_X         ;R0 ADDRESS OF GOBLIN BULLET X
	LDR R1,=GOBLIN_BULLETS_Y         ;R1 ADDRESS OF GOBLIN BULLET Y
	LDR R8,=SPACE_X                  ;R8 ADDRESS SPACE SHIP X
	LDR R9,=SPACE_Y				     ;R9 ADDRESS SPACE SHIP Y
	LDRH R6,[R8]                     ;FREEING UP REGISTER R6
	MOV R8,R6                        ;R8 CONTAINS THE SPACE X
	SUB R8,R8,#5
	LDRH R7,[R9]                     ;FREEING UP REGISTER R7
	MOV R9,R7                        ;R9 CONTAINS THE SPACE Y
	SUB R9,R9,#3
	LDR R6,=SPACE_HEALTH             ;R6 HEALTH OF SPACE SHIP
	MOV R12,#0                    ;R12 INDEX FOR BULLETS ARRAY
	MOV R11,#0                       ;R11 REMOVE FROM MEMORY REGISTER
BULLET_MOVE

	LDRH R2,[R0,R12]                  ;R2 BULLET X
	LDRH R5,[R1,R12]                  ;R5 BULLET Y 	
	CMP R12,#8
	ADD R12,R12,#2					  ;INCREASE INDEX
	BGT END_GBULLETS_DOWN
	CMP R2,#0
	BEQ BULLET_MOVE
	LDR R10,=BLACK
	BL DRAW_G_BULLET
	ADD R5,R5,#3                      ;MOVE BULLET DOWN
	CMP R2,R8						  ;COMPARING GOBLIN BULLET WITH X1 SPACE
	BLT CHECK_MAP_BOUNDS			  ;IF OUT OF BOUNDS CHECK IF IN BOUNDS
	ADD R8,R8,#21					  ;GETTING X2
	CMP R2,R8						  ;COMPARING GOBLIN BULLET WITH X2 SPACE
	SUB R8,R8,#21					  ;GETTING X2	
	BGT CHECK_MAP_BOUNDS
	CMP R5,R9						  ;COMPARING BULLET WITH Y1
	BLT CHECK_MAP_BOUNDS
	LDRH R7,[R6]					  ;R7 = HEALTH
	SUB R7,R7,#1
	STRH R7,[R6]				  ;STORES NEW HEALTH VALUE
	PUSH{R0-R12}
	MOV R2,R8
	MOV R5,R9
	BL COVER_SPACESHIP
	BL delay_100_MILLIsecond
	BL DRAW_SPACESHIP
	BL delay_100_MILLIsecond
	BL COVER_SPACESHIP
	BL delay_100_MILLIsecond
	BL DRAW_SPACESHIP
	POP{R0-R12}
	B DELETE_G_BULLET
	 
	;ADD ANIMATION
	
CHECK_MAP_BOUNDS
	CMP R5,#240
	BGE DELETE_G_BULLET              ;IF IT REACHED END OF SCREEN JUMP TO DELETE THE BULLET
	LDR R10,=GREEN
	BL DRAW_G_BULLET
	SUB R12,R12,#2
	STRH R5,[R1,R12]
	ADD R12,R12,#2
	B BULLET_MOVE
DELETE_G_BULLET
	SUB R12,R12,#2
	STRH R11,[R0,R12]
	ADD R12,R12,#2
	B BULLET_MOVE
END_GBULLETS_DOWN
	POP{R0-R12,PC}
	ENDFUNC
;################################################
	
	END