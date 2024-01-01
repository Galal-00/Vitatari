	
	INCLUDE TFT_Lib.s
	AREA FUNCTIONSCODE, CODE, READONLY


	; DISPLAY_SCORE
	; DISPLAY_SPACE_HEALTH
	; DRAW_MONSTER
	; DRAW_IMAGE
	; DRAW_COMP_IMAGE
	; DRAW_COMP_IMAGE_WITHOUT_BACKGROUND
	; DRAW_COMP_IMAGE_IN_COLOR
	; SETUP
	; PORTA_CONF
	;




DISPLAY_SCORE FUNCTION
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



DISPLAY_SPACE_HEALTH FUNCTION
	PUSH {R0-R12, LR}
		
	LDR R12, =SPACE_HEALTH
	LDRH R11, [R12]
	
	LDR R10, =BLACK	; SET COLOR
	LDR R1, =260		; SET X1
	LDR R0, =6		; SET Y1
	LDR R4, =320		; SET X2
	LDR R3, =23		; SET Y2
	BL DRAW_RECTANGLE_FILLED
	
	LDR R0, =300
	LDR R3, =6
	LDR R5, =MINI_SPACESHIP
	
DISPLAY_SPACE_HEALTH_LOOP

	SUBS R11, #1
	BLT EXIT_DISPLAY_SPACE_HEALTH_LOOP

	BL DRAW_IMAGE
	
	SUB R0, #19
	B DISPLAY_SPACE_HEALTH_LOOP
EXIT_DISPLAY_SPACE_HEALTH_LOOP

	POP {R0-R12, PC}
	ENDFUNC



DISPLAY_GOBLIN_BOSS_HEALTH FUNCTION
	PUSH {R0-R12, LR}
		
	LDR R12, =GOBLIN_BOSS_HEALTH
	LDRH R11, [R12]
	
	LDR R10, =RED		; SET COLOR
	LDR R1, =0			; SET X1
	LDR R0, =25			; SET Y1
	MOV R4, R11, LSL #4	; SET X2
	LDR R3, =28			; SET Y2
	BL DRAW_RECTANGLE_FILLED
	
	MOV R1, R4
	MOV R4, #320
	LDR R10, =BLACK		; SET COLOR
	BL DRAW_RECTANGLE_FILLED
	
	LDR R0, =300
	LDR R3, =6
	LDR R5, =MINI_SPACESHIP

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


	
DRAW_IMAGE FUNCTION
	PUSH {R0-R12, LR}
		
	; MODIFY MADCTL
	; EXCHANGE ROW AND COLUMN, SET BGR MODE
	MOV R2, #0x36
	BL LCD_COMMAND_WRITE

	MOV R2, #0x28
	BL LCD_DATA_WRITE

	;=======USAGE=======
	;LDR R0, =X start
	;LDR R3, =Y start
	;LDR R5, =Image Address
	;BL DRAW_IMAGE

	LDRH R6, [R5], #2	; Read X dimension
	ADD R1, R0, R6		; X end
	
	LDRH R6, [R5], #2	; Read Y dimension
	ADD R4, R3, R6		; Y end
	
	LDR R7, [R5], #4	; Read Image Size

	BL ADDRESS_SET
	
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

	LDR R0, =GPIOA_ODR
	LDR r2, [r0]
    ORR r2, #0x0F00
    STR R2, [R0]

	POP {R0-R12, PC}
	ENDFUNC



DRAW_COMP_IMAGE FUNCTION
	PUSH {R0-R12, LR}
		
	; MODIFY MADCTL
	; EXCHANGE ROW AND COLUMN, SET BGR MODE
	MOV R2, #0x36
	BL LCD_COMMAND_WRITE

	MOV R2, #0x28
	BL LCD_DATA_WRITE
	
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
	
    LDR R0, =GPIOA_ODR
	LDR r2, [r0]
    ORR r2, #0x0F00
    STR R2, [R0]

	POP {R0-R12, PC}
	ENDFUNC



	B DUM0
	LTORG
DUM0



DRAW_COMP_IMAGE_WITHOUT_BACKGROUND FUNCTION
	PUSH {R0-R12, LR}

	;=======USAGE=======
	;LDR R0, =X start
	;LDR R3, =Y start
	;LDR R5, =Image Address
	;BL DRAW_COMP_IMAGE_WITHOUT_BACKGROUND
	
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
	
    LDR R0, =GPIOA_ODR
	LDR r2, [r0]
    ORR r2, #0x0F00
    STR R2, [R0]

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

	;=======USAGE=======
	;LDR R0, =X start
	;LDR R3, =Y start
	;LDR R5, =Image Address
	;LDR R12, =Color
	;BL DRAW_COMP_IMAGE_IN_COLOR
	
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


		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
DELAY_1000MS FUNCTION
    PUSH {R0, LR}
    LDR R0, =16002114		; INTERVAL for 1000ms
DELAY_1000MS_Loop
	SUBS R0, #1
	BGT DELAY_1000MS_Loop
	POP {R0, PC}
	ENDFUNC
	
	
	
DELAY_100MS FUNCTION
    PUSH {R0, LR}
    LDR R0, =1600211		; INTERVAL for 100ms
DELAY_100MS_Loop
	SUBS R0, #1
	BGT DELAY_100MS_Loop
	POP {R0, PC}
	ENDFUNC
	
	
	
DELAY_10MS FUNCTION
    PUSH {R0, LR}
    LDR R0, =160021		; INTERVAL for 10ms
DELAY_10MS_Loop
	SUBS R0, #1
	BGT DELAY_10MS_Loop
	POP {R0, PC}
	ENDFUNC



DELAY_1MS FUNCTION
    PUSH {R0, LR}
    LDR R0, =16002		; INTERVAL for 1ms
DELAY_1MS_Loop
	SUBS R0, #1
	BGT DELAY_1MS_Loop
	POP {R0, PC}
	ENDFUNC



DELAY_500MS FUNCTION
    PUSH {R0, LR}
    LDR R0, =8001057		; INTERVAL for 500ms
DELAY_500MS_Loop
	SUBS R0, #1
	BGT DELAY_500MS_Loop
	POP {R0, PC}
	ENDFUNC



DELAY_50MS FUNCTION
    PUSH {R0, LR}
    LDR R0, =800106		; INTERVAL for 50ms
DELAY_50MS_Loop
	SUBS R0, #1
	BGT DELAY_50MS_Loop
	POP {R0, PC}
	ENDFUNC



DELAY_250MS FUNCTION
    PUSH {R0, LR}
    LDR R0, =4000528		; INTERVAL for 250ms
DELAY_250MS_Loop
	SUBS R0, #1
	BGT DELAY_250MS_Loop
	POP {R0, PC}
	ENDFUNC



DELAY_25MS FUNCTION
    PUSH {R0, LR}
    LDR R0, =400053		; INTERVAL for 25ms
DELAY_25MS_Loop
	SUBS R0, #1
	BGT DELAY_25MS_Loop
	POP {R0, PC}
	ENDFUNC
		
	END