	
	INCLUDE SpaceInvaders.s
	AREA WELCOME_CODE, CODE, READONLY


	EXPORT __main
    ENTRY
__main FUNCTION

	BL SETUP
	
	; Draw Background 
	LDR R10, =BLACK	; SET COLOR
	LDR R1, =0		; SET X1
	LDR R0, =0		; SET Y1
	LDR R4, =320	; SET X2
	LDR R3, =240	; SET Y2
	BL DRAW_RECTANGLE_FILLED

    MOV R0, #100
	MOV R3, #50
	BL DRAW_MONSTER
	
	MOV R3, #50
	MOV R0, #50
	LDR R5, =MINI_SPACESHIP
	BL DRAW_IMAGE

	;BL Choose_Game

	B Stop
Stop

	ENDFUNC
	
DRAW_IMAGE FUNCTION
	PUSH {R0-R12, LR}
		
	; MODIFY MADCTL
	; EXCHANGE ROW AND COLUMN, SET BGR MODE
	MOV R2, #0x36
	BL LCD_COMMAND_WRITE

	MOV R2, #0x28
	BL LCD_DATA_WRITE
	
	
	; R0 = X start
	; R3 = Y start
	; R5 = Image Address
	
	;=======USAGE=======
	;MOV R0, X start
	;MOV R3, Y start
	;LDR R5, Image Address
	;BL DRAW_IMAGE

	LDRH R6, [R5], #2	; Read X dimension
	ADD R1, R0, R6		; X end
	
	LDRH R6, [R5], #2	; Read Y dimension
	ADD R4, R3, R6		; Y end
	
	LDR R7, [R5], #4	; Read Image Size
	
	;LDRH R6, [R5], #2	; Read Dummy
	
	
	;MOV R3, #101		;X start
	;ADD R4, R3, #20		;X end
	;MOV R0, #91			;Y start
	;ADD R1, R0, #14		;Y end
	BL ADDRESS_SET

	;LDR R5, =ZERO
	;MOV R7, #315


	;MEMORY WRITE
	MOV R2, #0x2C
	BL LCD_COMMAND_WRITE

IMAGE_LOOP
	LDRH R6, [R5], #2

	MOV R2, R6
	LSR R2, #8
	BL LCD_DATA_WRITE
	MOV R2, R6
	BL LCD_DATA_WRITE

	SUBS R7, R7, #1
	CMP R7, #0
	BGT IMAGE_LOOP


	; MODIFY MADCTL
	; EXCHANGE ROW AND COLUMN, SET BGR MODE
	MOV R2, #0x36
	BL LCD_COMMAND_WRITE

	MOV R2, #0x08
	BL LCD_DATA_WRITE

	POP {R0-R12, PC}
	
	ENDFUNC
	
DRAW_MONSTER FUNCTION
	PUSH {R0-R12, LR}
		
	LDR R5, =MONSTER
	; MODIFY MADCTL
	; EXCHANGE ROW AND COLUMN, SET BGR MODE
	MOV R2, #0x36
	BL LCD_COMMAND_WRITE

	MOV R2, #0x28
	BL LCD_DATA_WRITE
	
	;=======USAGE=======
	;MOV R0, X start
	;MOV R3, Y start
	;LDR R5, Image Address                                                                                                    
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

MONSTER_LOOP
	LDRH R6, [R5], #2
    LDRH R8, [R5], #2

MONSTER_COLOR_LOOP

	MOV R2, R6
	LSR R2, #8
	BL LCD_DATA_WRITE
	MOV R2, R6
	BL LCD_DATA_WRITE

	SUBS R7, #1
	CMP R7, #0
    BLE EXIT_MONSTER_LOOP

    SUBS R8, #1
	CMP R8, #0
    BLE MONSTER_LOOP
	
	B MONSTER_COLOR_LOOP

EXIT_MONSTER_LOOP
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
	

Flash_Image FUNCTION
	PUSH {R0-R12, LR}
	
	;=======USAGE=======
	;LDR R0, =X start
	;LDR R3, =Y start
	;LDR R5, =Image Address
	;BL Flash_Image
	
	LDR R1, =0x1F
	LDR R11, =3
	
Flash_Image_LOOP	
	BL delay_25ms
	MOV R12, R1
	LSL R12, #5
	ORR R12, R12, R1
	LSL R12, #6
	ORR R12, R12, R1
	
	BL DRAW_COMP_IMAGE_IN_COLOR
	
	SUBS R1, R1, #1
	CMP R1, #10
	BGT Flash_Image_LOOP
	LDR R1, =0x1F
	SUBS R11, #1
	BGT Flash_Image_LOOP
	
	LDR R12, =BLACK
	BL DRAW_COMP_IMAGE_IN_COLOR

	POP {R0-R12, PC}
	ENDFUNC
	
Display_Sccore FUNCTION
	PUSH {R0-R12, LR}
	
	LDR R10, =SCORE
	LDRH R1, [R10]
	
	LDR R10, =prevSCORE
	LDRH R2, [R10]
	
	CMP R1, R2
	BEQ exit_program
	
	STRH R1, [R10]

    MOV R10, #10   	;@ Set the divisor to 10

	MOV R11, #3	 	; Number of digits
	MOV R0, #192	; X start of first digit
	MOV R3, #2		; Y start of all digits
	
convert_binary_to_decimal

    UDIV R2, R1, R10         ;@ Divide the binary number by 10
    MUL R4, R2, R10          ;@ Multiply the quotient by 10
    SUB R6, R1, R4          ;@ Calculate the remainder
	MOV R1, R2

	LDR R5, =ZERO
	MOV R7, #32
	MLA R5, R6, R7, R5
	
	SUB R0, R0, #20
	;MOV R3, Y start
	;LDR R5, Image Address
	BL DRAW_COMP_IMAGE
	
	SUBS R11, R11, #1
	BGT convert_binary_to_decimal

exit_program

	POP {R0-R12, PC}
	ENDFUNC
	
DRAW_COMP_IMAGE_IN_COLOR FUNCTION
	PUSH {R0-R12, LR}
		
	; MODIFY MADCTL
	; EXCHANGE ROW AND COLUMN, SET BGR MODE
	MOV R2, #0x36
	BL LCD_COMMAND_WRITE

	MOV R2, #0x28
	BL LCD_DATA_WRITE
	
	
	; R0 = X start
	; R3 = Y start
	; R5 = Image Address
	
	;=======USAGE=======
	;LDR R0, =X start
	;LDR R3, =Y start
	;LDR R5, =Image Address
	;BL DRAW_COMP_IMAGE
	
	LDR R7, [R5], #4	; Read Image Size
	
	LDR R11, [R5], #4	; Read 

	LDR R6, [R5], #2	; Read X dimension
	ADD R1, R0, R6		; X end
	
	LDR R6, [R5], #2	; Read Y dimension
	ADD R4, R3, R6		; Y end
	
	LDR R8, [R5], #2	; Read Color0
	
	LDR R9, [R5], #2	; Read Color1
	MOV R9, R12
	
	

	
	BL ADDRESS_SET


	;MEMORY WRITE
	MOV R2, #0x2C
	BL LCD_COMMAND_WRITE


COMP_IMAGE_LOOP_IN_COLOR
	LDR R0, [R5], #4
	
	LDR R3, =0x80000000	; 0b 10000000 00000000 00000000 00000000

word_LOOP_IN_COLOR
	ANDS R1, R0, R3
	MOV R6, R9
	MOVEQ R6, R8

	MOV R10, R11
comp_LOOP_IN_COLOR
	MOV R2, R6
	LSR R2, #8
	BL LCD_DATA_WRITE
	MOV R2, R6
	BL LCD_DATA_WRITE

	SUBS R7, R7, #1
	CMP R7, #0
	BLE out_LOOP_IN_COLOR
	
	SUBS R10, R10, #1
	CMP R10, #0
	BGT comp_LOOP_IN_COLOR
	
	LSR R3, #1
	CMP R3, #0
	BGT word_LOOP_IN_COLOR
	
	B COMP_IMAGE_LOOP_IN_COLOR
	
out_LOOP_IN_COLOR

	; MODIFY MADCTL
	; EXCHANGE ROW AND COLUMN, SET BGR MODE
	MOV R2, #0x36
	BL LCD_COMMAND_WRITE

	MOV R2, #0x08
	BL LCD_DATA_WRITE
	
	;BL PORTA_CONF    
	;BL LCD_INIT
	
    LDR R0, =GPIOA_ODR
	LDR r2, [r0]
    ORR r2, #0x0F00
    STR R2, [R0]

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
	BL delay_1000ms
	LDR R5, =TWO
	BL DRAW_COMP_IMAGE
	BL delay_1000ms
	LDR R5, =ONE
	BL DRAW_COMP_IMAGE
	BL delay_1000ms
	LDR R0, =104
	LDR R3, =92	
	LDR R5, =GO
	BL DRAW_COMP_IMAGE
	BL delay_1000ms
	
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

End_Change_Selection
	POP {R0-R12, PC}
	ENDFUNC
	
	B dummydum2
	LTORG
dummydum2
	

DRAW_COMP_IMAGE FUNCTION
	PUSH {R0-R12, LR}
		
	; MODIFY MADCTL
	; EXCHANGE ROW AND COLUMN, SET BGR MODE
	MOV R2, #0x36
	BL LCD_COMMAND_WRITE

	MOV R2, #0x28
	BL LCD_DATA_WRITE
	
	
	; R0 = X start
	; R3 = Y start
	; R5 = Image Address
	
	;=======USAGE=======
	;LDR R0, =X start
	;LDR R3, =Y start
	;LDR R5, =Image Address
	;BL DRAW_COMP_IMAGE
	
	LDR R7, [R5], #4	; Read Image Size
	
	LDR R11, [R5], #4	; Read 

	LDR R6, [R5], #2	; Read X dimension
	ADD R1, R0, R6		; X end
	
	LDR R6, [R5], #2	; Read Y dimension
	ADD R4, R3, R6		; Y end
	
	LDR R8, [R5], #2	; Read Color0
	
	LDR R9, [R5], #2	; Read Color1
	
	

	
	BL ADDRESS_SET


	;MEMORY WRITE
	MOV R2, #0x2C
	BL LCD_COMMAND_WRITE


COMP_IMAGE_LOOP
	LDR R0, [R5], #4
	
	LDR R3, =0x80000000	; 0b 10000000 00000000 00000000 00000000

word_LOOP
	ANDS R1, R0, R3
	MOV R6, R9
	MOVEQ R6, R8

	MOV R10, R11
comp_LOOP
	MOV R2, R6
	LSR R2, #8
	BL LCD_DATA_WRITE
	MOV R2, R6
	BL LCD_DATA_WRITE

	SUBS R7, R7, #1
	CMP R7, #0
	BLE out_LOOP
	
	SUBS R10, R10, #1
	CMP R10, #0
	BGT comp_LOOP
	
	LSR R3, #1
	CMP R3, #0
	BGT word_LOOP
	
	B COMP_IMAGE_LOOP
	
out_LOOP

	; MODIFY MADCTL
	; EXCHANGE ROW AND COLUMN, SET BGR MODE
	MOV R2, #0x36
	BL LCD_COMMAND_WRITE

	MOV R2, #0x08
	BL LCD_DATA_WRITE
	
	;BL PORTA_CONF    
	;BL LCD_INIT
	
    LDR R0, =GPIOA_ODR
	LDR r2, [r0]
    ORR r2, #0x0F00
    STR R2, [R0]

	POP {R0-R12, PC}
	
	ENDFUNC
	
	
DRAW_COMP_IMAGE_WITHOUT_BACKGROUND FUNCTION
	PUSH {R0-R12, LR}
		
	; R0 = X start
	; R3 = Y start
	; R5 = Image Address
	
	;=======USAGE=======
	;MOV R0, X start
	;MOV R3, Y start
	;LDR R5, Image Address
	;BL DRAW_COMP_IMAGE
	
	MOV R1, R0
	MOV R0, R3
	
	LDR R7, [R5], #4	; Read Image Size
	
	LDR R11, [R5], #4	; Read PixelsperBit
	MOV R8, R11

	LDRH R2, [R5], #2	; Read X dimension
	ADD R2, R2, #1
	ADD R4, R1, R2		; X end
	
	LDRH R6, [R5], #2	; Read Y dimension
	
	LDRH R6, [R5], #2	; Read Color0 ; BACKGROUND  Color
	
	LDRH R10, [R5], #2	; Read Color1



COMP_IMAGE_WITHOUT_BACKGROUND_LOOP
	LDR R12, [R5], #4
	
	LDR R9, =0x80000000	; 0b 10000000 00000000 00000000 00000000

word_WITHOUT_BACKGROUND_LOOP
	ANDS R6, R9, R12
	MOV R11, R8
	
comp_WITHOUT_BACKGROUND_LOOP
	CMP R6, #0
	BEQ skipPixel
	BL DRAWPIXEL

skipPixel

	ADD R1, R1, #1
	CMP R4, R1
	ADDEQ R0, R0, #1
	CMP R4, R1
	SUBEQ R1, R1, R2
	

	SUBS R7, R7, #1
	CMP R7, #0
	BLE out_LOOP_WITHOUT_BACKGROUND
	
	SUBS R11, R11, #1
	CMP R11, #0
	BGT comp_WITHOUT_BACKGROUND_LOOP
	
	LSR R9, #1
	CMP R9, #0
	BGT word_WITHOUT_BACKGROUND_LOOP
	
	B COMP_IMAGE_WITHOUT_BACKGROUND_LOOP
	
out_LOOP_WITHOUT_BACKGROUND

	;BL PORTA_CONF    
	;BL LCD_INIT
	
    LDR R0, =GPIOA_ODR
	LDR r2, [r0]
    ORR r2, #0x0F00
    STR R2, [R0]

	POP {R0-R12, PC}
	
	ENDFUNC
	
	

SETUP   FUNCTION
	;THIS FUNCTION ENABLES PORT E, MARKS IT AS OUTPUT, CONFIGURES SOME GPIO
	;THEN FINALLY IT CALLS LCD_INIT (HINT, USE THIS SETUP FUNCTION DIRECTLY IN THE MAIN)
	PUSH {R0-R12, LR}
    BL PORTA_CONF    
	BL LCD_INIT
	
    LDR R0, =GPIOA_ODR
	ldr r2, [r0]
    ORR r2, #0x0F00
    STR R2, [R0]
	POP {R0-R12, PC}

    ENDFUNC
	
	
PORTA_CONF  FUNCTION
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

	END