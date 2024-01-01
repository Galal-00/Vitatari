	
	INCLUDE SpaceInvaders.s
	AREA WELCOME_CODE, CODE, READONLY


	EXPORT __main
    ENTRY
__main FUNCTION

	BL SETUP
	
	BL LOSE_FUNCTION
	BL WIN_FUNCTION
	
	BL DRAW_LOGO
	BL DELAY_1000MS
	BL DELAY_1000MS
	BL DELAY_1000MS
	
	BL Choose_Game

Stop
	B Stop

	ENDFUNC



FLASH_IMAGE FUNCTION
	PUSH {R0-R12, LR}
	
	;=======USAGE=======
	;LDR R0, =X start
	;LDR R3, =Y start
	;LDR R5, =Image Address
	;BL FLASH_IMAGE
	
	LDR R1, =0x1F
	LDR R11, =3
	
FLASH_IMAGE_LOOP	
	BL DELAY_25MS
	MOV R12, R1
	LSL R12, #5
	ORR R12, R12, R1
	LSL R12, #6
	ORR R12, R12, R1
	
	BL DRAW_COMP_IMAGE_IN_COLOR
	
	SUBS R1, R1, #1
	CMP R1, #10
	BGT FLASH_IMAGE_LOOP
	LDR R1, =0x1F
	SUBS R11, #1
	BGT FLASH_IMAGE_LOOP
	
	LDR R12, =BLACK
	BL DRAW_COMP_IMAGE_IN_COLOR

	POP {R0-R12, PC}
	ENDFUNC
	
	

	



Choose_Game FUNCTION
	PUSH {R0-R12, LR}
	
	LDR R0, =GPIOA_ODR
	ldrh r2, [r0]
    ORR r2, #0x0F00
    STR R2, [R0]

Start_Choose_Game

	; Draw Background 
	LDR R10, =BLACK	; SET COLOR
	LDR R1, =0		; SET X1
	LDR R0, =0		; SET Y1
	LDR R4, =320	; SET X2
	LDR R3, =240	; SET Y2
	BL DRAW_RECTANGLE_FILLED


	; Draw "Choose The Game", "Breakout", "Space Invaders"
	; Draw arrow at Choose The Game (X1, Y1) = (13, 27)
	LDR R0, =13
	LDR R3, =27
	LDR R5, =CHOOSE_A_GAME
	BL DRAW_COMP_IMAGE
	
	; Draw arrow at Breakout (X1, Y1) = (59, 114)
	LDR R0, =59
	LDR R3, =114
	LDR R5, =BREAKOUT
	BL DRAW_COMP_IMAGE
	
	; Draw arrow at Space Invaders (X1, Y1) = (59, 142)
	LDR R0, =59
	LDR R3, =142
	LDR R5, =Space_Invaders
	BL DRAW_COMP_IMAGE

	; Select Breakout by defaul                                                
	MOV R7, #0
	BL Change_Selection
	
	LDR R0, =GPIOA_ODR
	ldrh r2, [r0]
    ORR r2, #0x0F00
    STR R2, [R0]
	
WelcomeLOOP
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
	
	CMP r1, #0x0B00	; PA10 input
	MOVEQ R7, #0 ;Select breakout
	
	CMP r1, #0x0D00	; PA9 input
	MOVEQ R7, #1 ;Select spaceInvaders
	
	BL Change_Selection
	
	CMP r1, #0x0E00	; PA8 input
	BNE WelcomeLOOP
	
	; Draw Background 
	LDR R10, =BLACK	; SET COLOR
	LDR R1, =0		; SET X1
	LDR R0, =0		; SET Y1
	LDR R4, =320	; SET X2
	LDR R3, =240	; SET Y2
	BL DRAW_RECTANGLE_FILLED
	
	LDR R0, =152
	LDR R3, =109
	LDR R5, =THREE
	BL DRAW_COMP_IMAGE
	BL DELAY_500MS
	LDR R5, =TWO
	BL DRAW_COMP_IMAGE
	BL DELAY_500MS
	LDR R5, =ONE
	BL DRAW_COMP_IMAGE
	BL DELAY_500MS
	LDR R0, =104
	LDR R3, =92	
	LDR R5, =GO
	BL DRAW_COMP_IMAGE
	BL DELAY_500MS
	
	; Draw Background 
	LDR R10, =BLACK	; SET COLOR
	LDR R1, =104		; SET X1
	LDR R0, =92		; SET Y1
	LDR R4, =216	; SET X2
	LDR R3, =148	; SET Y2
	BL DRAW_RECTANGLE_FILLED
	
	
	CMP R7, #1
	BEQ spaceInvaders

breakout
	BL main_Breakout
	B Start_Choose_Game
	
spaceInvaders
	BL main_Space
	B Start_Choose_Game
 

	
	POP {R0-R12, PC}
	ENDFUNC	
	
	
		
Change_Selection FUNCTION
	PUSH {R0-R12, LR}
	CMP R7, #0
	BEQ SELECTION_1
	CMP R7, #1
	BEQ SELECTION_2

SELECTION_1
	; Remove arrow from Space Invaders (X1, Y1) = (32, 143)
	LDR R10, =BLACK	; SET COLOR
	LDR R1, =32		; SET X1
	LDR R0, =143	; SET Y1
	ADD R4, R1, #19	; SET X2
	ADD R3, R0, #19	; SET Y2
	BL DRAW_RECTANGLE_FILLED
	; Draw arrow at Breakout (X1, Y1) = (32, 115)
	LDR R0, =32
	LDR R3, =115
	LDR R5, =ARROW
	BL DRAW_COMP_IMAGE
	
	LDR R0, =59
	LDR R3, =114
	LDR R5, =BREAKOUT
	LDR R12, =RED
	BL DRAW_COMP_IMAGE_IN_COLOR
	
	LDR R0, =59
	LDR R3, =142
	LDR R5, =Space_Invaders
	LDR R12, =WHITE
	BL DRAW_COMP_IMAGE

	B End_Change_Selection

SELECTION_2
	; Remove arrow from Breakout (X1, Y1) = (32, 115)
	LDR R10, =BLACK	; SET COLOR
	LDR R1, =32		; SET X1
	LDR R0, =115	; SET Y1
	ADD R4, R1, #19	; SET X2
	ADD R3, R0, #19	; SET Y2
	BL DRAW_RECTANGLE_FILLED
	; Draw arrow at Space Invaders (X1, Y1) = (32, 143)
	LDR R0, =32
	LDR R3, =143
	LDR R5, =ARROW
	BL DRAW_COMP_IMAGE
	
	LDR R0, =59
	LDR R3, =114
	LDR R5, =BREAKOUT
	LDR R12, =WHITE
	BL DRAW_COMP_IMAGE
	
	LDR R0, =59
	LDR R3, =142
	LDR R5, =Space_Invaders
	LDR R12, =RED
	BL DRAW_COMP_IMAGE_IN_COLOR

End_Change_Selection
	POP {R0-R12, PC}
	ENDFUNC
	
	B dummydum2
	LTORG
dummydum2



DRAW_LOGO FUNCTION
	PUSH {R0-R12, LR}
		
	LDR R5, =MONSTER
	; MODIFY MADCTL
	; EXCHANGE ROW AND COLUMN, SET BGR MODE
	MOV R2, #0x36
	BL LCD_COMMAND_WRITE

	MOV R2, #0x28
	BL LCD_DATA_WRITE
	
	;=======USAGE=======
	MOV R0,#85
	MOV R3,#29
	;MOV R0, X start
	;MOV R3, Y start                                                                                                   
	;BL DRAW_MONSTER

	LDRH R6, [R5], #2	; Read X dimension
	ADD R1, R0, R6		; X end
	LDRH R6, [R5], #2	; Read Y dimension
	ADD R4, R3, R6		; Y end
	LDR R7, [R5], #4	; Read Image Size
	
	BL ADDRESS_SET

	;MEMORY WRITE
	MOV R2, #0x2C
	BL LCD_COMMAND_WRITE

LOGO_LOOP
	LDRH R6, [R5], #2
    LDRH R8, [R5], #2

LOGO_COLOR_LOOP

	MOV R2, R6
	LSR R2, #8
	BL LCD_DATA_WRITE
	MOV R2, R6
	BL LCD_DATA_WRITE

	SUBS R7, #1
	CMP R7, #0
    BLE EXIT_LOGO_LOOP

    SUBS R8, #1
	CMP R8, #0
    BLE LOGO_LOOP
	
	B LOGO_COLOR_LOOP

EXIT_LOGO_LOOP
	; MODIFY MADCTL
	; EXCHANGE ROW AND COLUMN, SET BGR MODE
	MOV R2, #0x36
	BL LCD_COMMAND_WRITE

	MOV R2, #0x08
	BL LCD_DATA_WRITE
	
	LDR R0, =GPIOA_ODR
	LDR r2, [r0]
    ORR r2, #0x0F00
    STR R2, [R0]

	POP {R0-R12, PC}
	ENDFUNC

	END