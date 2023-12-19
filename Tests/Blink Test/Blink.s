	AREA MYDATA, DATA, READONLY
		
RCC_BASE EQU 0x40021000				; Clock register base address
RCC_APB2ENR EQU RCC_BASE + 0x18		; Register responsible for port activation
RCC_IOPCEN EQU 0x04					; Port C is bit 4
	
GPIOC_BASE EQU 0x40011000	; Base addr of port C
GPIOx_CRH EQU 0x04			; Configuration register		
GPIOx_ODR EQU 0x0C			; Data register
GPIOx_BSRR EQU 0x10			; Atomic set/reset register

INTERVAL EQU 0x566004		; 1 sec delay interval
	
	EXPORT __main
	
	AREA MYCODE, CODE, READONLY
	ENTRY

__main FUNCTION
	
	BL SETUP
	
LOOP
	BL Delay_1_SEC
	BL Delay_1_SEC
	
	; Set pin 13 in port C to high
	LDR R0, =GPIOC_BASE
	LDR R4, =GPIOx_ODR
	ADD R0, R0 , R4
	LDR R1, [R0]
	MOV R3, #1
	ORR R1, R1, R3, LSL #13
	STR R1, [R0]
	
	BL Delay_1_SEC
	
	; Set pin 13 in port C to low
	LDR R0, =GPIOC_BASE
	LDR R4, =GPIOx_ODR
	ADD R0, R0 , R4
	LDR R1, [R0]
	MOV R3, #1
	LSL	R3, #13
	MVN R3, R3
	AND R1, R1, R3
	STR R1, [R0]
	
	B LOOP
	
	ENDFUNC
	
SETUP FUNCTION
	PUSH {R0-R4, LR}
	; Configure GPIOC Port (Pin 13) to output
	; Blink the built-in LED (2 sec on, 1 sec off)
	
	; Enable Port C
	LDR R0, =RCC_APB2ENR
	LDR R1, [R0]
	MOV R3, #1
	ORR R1, R1, R3, LSL #4	; Enable Port C Clock
	STR R1, [R0]
	
	; Output mode (MODE13 REG)
	LDR R0, =GPIOC_BASE
	LDR R3, =GPIOx_CRH
	ADD R0, R0 , R3
	LDR R1, [R0]
	MOV R3, #1
	ORR R1, R1, R3, LSL #21	; 10: Output mode, max speed 2 MHz.
	STR R1, [R0]
	
	; Output is defaulted to push-pull
	POP {R0-R4, PC}
	ENDFUNC
	
Delay_1_SEC FUNCTION
	PUSH {R0-R4, LR}
	; 1 Second delay
	LDR R0, =INTERVAL
delay_loop_SEC
	SUBS R0, #1
	CMP R0, #1
	BGE delay_loop_SEC
	POP {R0-R4, PC}
	ENDFUNC
	
	END
