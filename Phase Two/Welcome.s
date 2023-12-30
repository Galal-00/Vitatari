	
	INCLUDE SpaceInvaders.s
	AREA WELCOME_CODE, CODE, READONLY


	EXPORT __main
    ENTRY
__main FUNCTION

	BL SETUP
	mov r0, #0
	mov r1, #0
	mov r3, #240 ; PA9 input
	mov r4, #320 ; PA8 input
	ldr r10, =BLACK
	BL DRAW_RECTANGLE_FILLED
	LDR R0, =GPIOA_ODR
	ldrh r2, [r0]
    ORR r2, #0x0F00
    STR R2, [R0]
	
	mov r0, #0
	mov r1, #0
	mov r2, #0x0B00	; PA10 input
	mov r3, #0x0D00 ; PA9 input
	mov r4, #0x0E00 ; PA8 input
	BL main_Breakout
;4 2 1, 0 if all connected
; right button invaders , left btn breakout
;WelcomeLOOP
;	
;	ldr r0, =GPIOA_IDR
;	ldr r1, [r0]
;	AND r1, r1, #0x0F00
;	CMP r1, r2
;	BEQ breakout
;	CMP r1, r3
;	BEQ spaceInvaders
;	
;	
;	B WelcomeLOOP
;breakout
;	BL main_Breakout
;	B Stop
;spaceInvaders
;	BL main_Space
	B Stop
Stop

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