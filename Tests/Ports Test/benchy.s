	AREA MYDATA, DATA, READONLY
	
RCC_BASE	EQU		0x40021000
RCC_APB2ENR		EQU		RCC_BASE + 0x18


GPIOC_BASE         EQU      0x40011000   ; port c
GPIOC_CRH         EQU     GPIOC_BASE+0x04
GPIOC_CRL         EQU     GPIOC_BASE
GPIOC_ODR     EQU        GPIOC_BASE+0x0C
GPIOC_IDR     EQU        GPIOC_BASE+0x08



GPIOA_BASE      EQU     0x40010800
GPIOA_CRH         EQU     GPIOA_BASE+0x04
GPIOA_CRL         EQU     GPIOA_BASE
GPIOA_ODR     EQU        GPIOA_BASE+0x0C



GPIOB_BASE  EQU 0x40010C00
GPIOB_CRH         EQU     GPIOB_BASE+0x04
GPIOB_CRL         EQU     GPIOB_BASE
GPIOB_ODR     EQU        GPIOB_BASE+0x0C

; A15, B3, B4, B1, B0


INTERVAL EQU 0x566004		;just a number to perform the delay. this number takes roughly 1 second to decrement until it reaches 0



	AREA MYCODE, CODE, READONLY


	EXPORT __main
    ENTRY

__main FUNCTION
    

	;FINAL TODO: CALL FUNCTION SETUP
	BL SETUP
loopyyy
    ;BL TEST_A
	;BL TEST_B
	;BL TEST_C
    
	LDR R0, =GPIOA_ODR
	MOV R1, #0xFFFF
	STR R1, [R0]
	
	LDR R0, =GPIOB_ODR
	MOV R1, #0xFFFF
	STR R1, [R0]
	
	LDR R0, =GPIOC_ODR
	MOV R1, #0xFFFF
	STR R1, [R0]
	
	B loopyyy
    
    ENDFUNC










SETUP  FUNCTION
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
    MOV R2, #0x33333333     ;ALL 8 LOWER PINS OF PORT A AS OUTPUT WITH MAX SPEED OF 50 MHZ
    STR R2, [R0]                 ; Write the updated value back to GPIOC_CRH



    ; Enable GPIOC clock
    LDR R0, =RCC_APB2ENR         ; Address of RCC_APB2ENR register
    LDR R1, [R0]                 ; Read the current value of RCC_APB2ENR
	MOV R2, #1
    ORR R1, R1, R2, LSL #4        ; Set bit 4 to enable GPIOC clock
    STR R1, [R0]                 ; Write the updated value back to RCC_APB2ENR
    
    ; Configure PC13 as output push-pull 
    LDR R0, =GPIOC_CRH           ; Address of GPIOC_CRH register
    MOV R2, #0x33333333      ; Set mode bits for pin 13 (output mode, max speed 50 MHz)
    STR R2, [R0]                 ; Write the updated value back to GPIOC_CRH

    ; Configure PC13 as output push-pull 
    LDR R0, =GPIOC_CRL           ; Address of GPIOC_CRH register
    MOV R2, #0x33333333      ; Set mode bits for pin 13 (output mode, max speed 50 MHz)
    STR R2, [R0]   


    ; Enable GPIOB clock
    LDR R0, =RCC_APB2ENR         ; Address of RCC_APB2ENR register
    LDR R1, [R0]                 ; Read the current value of RCC_APB2ENR
	MOV R2, #1
    ORR R1, R1, R2, LSL #3        ; Set bit 3 to enable GPIOB clock
    STR R1, [R0]                 ; Write the updated value back to RCC_APB2ENR
    
    
    LDR R0, =GPIOB_CRL           ; Address of GPIOC_CRL register
    LDR R1, [R0]                 ; Read the current value of GPIOC_CRH
    AND R1, R1, #0x00FFFFFF      ; Clear the configuration bits for pin 13 (CLEAR THE BITS 23,22,21,20)
    ORR R1, R1, #0x33000000      ; Set mode bits for pin 13 (output mode, max speed 50 MHz)
    STR R1, [R0]                 ; Write the updated value back to GPIOC_CRH


    LDR R0, =GPIOB_CRH           ; Address of GPIOC_CRL register
    MOV R2, #0x33333333      ; Set mode bits for pin 13 (output mode, max speed 50 MHz)
    STR R2, [R0] 




    POP{R0-R2, PC}

    ENDFUNC





TEST_A  FUNCTION
    PUSH{R0-R12, LR}
    LDR R0, =GPIOA_ODR
    MOV R2, #0

TESTA_LOOP
    MOV R1, #1
    LSL R1, R2
    STR R1, [R0]
    BL delay_1_second
    ADD R2, R2, #1
    CMP R2, #16
    BLT TESTA_LOOP

    POP{R0-R12, PC}
    ENDFUNC


TEST_B  FUNCTION
    PUSH{R0-R12, LR}
    LDR R0, =GPIOB_ODR
    MOV R2, #0

TESTB_LOOP
    MOV R1, #1
    LSL R1, R2
    STR R1, [R0]
    BL delay_1_second
    ADD R2, R2, #1
    CMP R2, #16
    BLT TESTB_LOOP

    POP{R0-R12, PC}
    ENDFUNC


TEST_C  FUNCTION
    PUSH{R0-R12, LR}
    LDR R0, =GPIOC_ODR
    MOV R2, #0

TESTC_LOOP
    MOV R1, #1
    LSL R1, R2
    STR R1, [R0]
    BL delay_1_second
    ADD R2, R2, #1
    CMP R2, #16
    BLT TESTC_LOOP

    POP{R0-R12, PC}
    ENDFUNC







delay_1_second FUNCTION
    PUSH {R0, LR}               ; Push R4 and Link Register (LR) onto the stack
    LDR R0, =INTERVAL           ; Load the delay count
DelayInner_Loop
        SUBS R0, #1             ; Decrement the delay count
		cmp	R0, #0
        BGT DelayInner_Loop     ; Branch until the count becomes zero
    
    POP {R0, PC}                ; Pop R4 and return from subroutine
	ENDFUNC





    END