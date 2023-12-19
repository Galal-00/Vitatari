	AREA MYDATA, DATA, READONLY
	
RCC_BASE	EQU		0x40021000
RCC_APB2ENR		EQU		RCC_BASE + 0x18


GPIOC_BASE         EQU      0x40011000   ; port c
GPIOC_CRH         EQU     GPIOC_BASE+0x04
GPIOC_ODR     EQU        GPIOC_BASE+0x0C

INTERVAL EQU 0x566004		;just a number to perform the delay. this number takes roughly 1 second to decrement until it reaches 0


	AREA MYCODE, CODE, READONLY


;/* Start of main program */
	EXPORT __main
    ENTRY

__main FUNCTION
    ; Enable GPIOC clock
    LDR R0, =RCC_APB2ENR         ; Address of RCC_APB2ENR register
    LDR R1, [R0]                 ; Read the current value of RCC_APB2ENR
	MOV R2, #1
    ORR R1, R1, R2, LSL #4        ; Set bit 4 to enable GPIOC clock
    STR R1, [R0]                 ; Write the updated value back to RCC_APB2ENR
    
    ; Configure PC13 as output push-pull 
    LDR R0, =GPIOC_CRH           ; Address of GPIOC_CRH register
    LDR R1, [R0]                 ; Read the current value of GPIOC_CRH
    AND R1, R1, #0xFF0FFFFF      ; Clear the configuration bits for pin 13 (CLEAR THE BITS 23,22,21,20)
    ORR R1, R1, #0x00300000      ; Set mode bits for pin 13 (output mode, max speed 50 MHz)
    STR R1, [R0]                 ; Write the updated value back to GPIOC_CRH
    
    

Loop
    LDR R1, =GPIOC_ODR          ; Address of GPIOC_BSRR register
    LDR R3, [R1]                 ; Read the current value of GPIOC_BSRR
    MOV R0, #1	; Set bit 13 (PC13) in R0
	ORR R3, R3, R0, LSL #13
    STR R3, [R1]                 ; Write the updated value back to GPIOC_BSRR
    
	;NOTE: LED IS ACTIVE LOW, SO IF YOU WRITE HIGH ON PC13, THE LED WILL TURN OFF,
	;IF YOU WRITE LOW, THE LED WILL TURN ON,
	;THIS IS ONLY FOR THE BUILT IN LED.
	
    BL DelayMs                   ; Call the delay function
	
	LDR R1, =GPIOC_ODR          ; Address of GPIOC_BSRR register
	LDR R3, [R1]                 ; Read the current value of GPIOC_BSRR
	MOV R0, #1	; RESET bit 13 (PC13) in R0
	LSL R0, R0, #13
	MVN R0, R0
	AND R3, R3, R0
	STR R3, [R1]                 ; Write the updated value back to GPIOC_BSRR
	
	BL DelayMs                   ; Call the delay function
   
    B Loop                     ; repeat loop FOREVER
    

    
    ENDFUNC
	
		
		
		



DelayMs FUNCTION
    PUSH {R0, LR}               ; Push R4 and Link Register (LR) onto the stack
    LDR R0, =INTERVAL           ; Load the delay count
DelayInner_Loop
        SUBS R0, #1             ; Decrement the delay count
		cmp	R0, #0
        BGT DelayInner_Loop     ; Branch until the count becomes zero
    
    POP {R0, PC}                ; Pop R4 and return from subroutine
	ENDFUNC



	END