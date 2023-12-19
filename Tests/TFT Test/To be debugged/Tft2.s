	AREA MYDATA, DATA, READONLY
		
RCC_BASE EQU 0x40021000				; Clock register base address
RCC_APB2ENR EQU RCC_BASE + 0x18		; Register responsible for port activation
	
RCC_IOABEN EQU 0x02					; Port A is bit 2	
RCC_IOPBEN EQU 0x03					; Port B is bit 3
RCC_IOCBEN EQU 0x04					; Port C is bit 4

GPIOA_BASE EQU 0x40010800	; Base address of port A
GPIOB_BASE EQU 0x40010C00	; Base address of port B
GPIOC_BASE EQU 0x40011000	; Base address of port C

GPIOx_CRL EQU 0x00			; Configuration register L
GPIOx_CRH EQU 0x04			; Configuration register H	
GPIOx_ODR EQU 0x0C			; Data register
	
GPIOA_ODR EQU GPIOA_BASE + 0x0C
GPIOB_ODR EQU GPIOB_BASE + 0x0C

INTERVAL EQU 0x566004		; 1 sec delay interval
	
	;just some color codes, 16-bit colors coded in RGB 565
BLACK	EQU   	0x0000
BLUE 	EQU  	0x001F
RED  	EQU  	0xF800
RED2   	EQU 	0x4000
GREEN 	EQU  	0x07E0
CYAN  	EQU  	0x07FF
MAGENTA EQU 	0xF81F
YELLOW	EQU  	0xFFE0
WHITE 	EQU  	0xFFFF
GREEN2 	EQU 	0x2FA4
CYAN2 	EQU  	0x07FF
	
	; TFT PINOUT
	; D0 - D7 : A0 - A7
	; LCD_RST : A8
	; LCD_CS : A9
	; LCD_RS : A10
	; LCD_WR : A11 
	; LCD_RD : A12
	
	; ENG AYMAN TFT PINOUT
	;the following are pins connected from the TFT to our EasyMX board
;RD = PB9		Read pin	--> to read from touch screen input 
;WR = PB8		Write pin	--> to write data/command to display
;RS = PB7		Command pin	--> to choose command or data to write
;CS = PB6		Chip Select	--> to enable the TFT, lol	(active low)
;RST= PB15		Reset		--> to reset the TFT (active low)
;D0-7 = PA0-7	Data BUS	--> Put your command or data on this bus
	
	EXPORT __main
	
	AREA MYCODE, CODE, READONLY
	ENTRY

__main FUNCTION
	
	BL SETUP
	
;LOOP_MAIN


	;FINAL TODO: DRAW THE ENTIRE SCREEN WITH A CERTAIN COLOR
	;X1 = [0] r0
	;Y1 = [0] r1
	;X2 = [240] r3
	;Y2 = [320] r4
	;AREA = [0x12C00] r5
	;COLOR = [BLUE] r10
	
	MOV R0, #0
	MOV R4, #0x140
	MOV R3, #0xF0
	MOV R1, #0
	MOV R5, #0x12C00
	LDR R10, =CYAN
	
	BL DRAW_RECTANGLE_FILLED
	
	BL delay_1_second
	BL delay_1_second
	
	;B LOOP_MAIN
	
	ENDFUNC


LCD_WRITE FUNCTION
	PUSH {r0-r3, LR}
	;this function takes what is inside r2 and writes it to the tft
	;this function writes 8 bits only
	;later we will choose whether those 8 bits are considered a command, or just pure data


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SETTING WR to 0 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LDR r1, =GPIOB_ODR
	LDR r0, [r1]
	MOV R3, #1
	LSL R3, #8
	MVN R3, R3
	AND r0, r0, r3
	STRH r0, [r1]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; HERE YOU PUT YOUR DATA which is in R2 TO PE0-7 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LDR r1, =GPIOA_ODR
	STRB r2, [r1]			;only write the lower byte to PE0-7
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;; SETTING WR to 1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LDR r1, =GPIOB_ODR
	LDR r0, [r1]
	MOV R3, #1
	LSL R3, #8
	ORR r0, r0, r3
	STRH r0, [r1]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	POP {R0-r3, PC}
	ENDFUNC

LCD_COMMAND_WRITE FUNCTION
	PUSH {R0-R3, LR}
	;this function writes a command to the TFT, the command is read from R2
	;it writes LOW to RS first to specify that we are writing a command not data.


	;RD HIGH
	LDR r1, =GPIOB_ODR
	LDR r0, [r1]
	MOV R3, #1
	LSL R3, #9
	ORR r0, r0, r3
	STRH r0, [r1]

;;;;;;;;;;;;;;;;;;;;;;;;; SETTING RS to 0 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LDR r1, =GPIOB_ODR
	LDR r0, [r1]
	MOV r3, #1
	LSL r3, #7
	MVN r3, r3
	AND r0, r0, r3
	STRH r0, [r1]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	BL LCD_WRITE	;Call Function LCD_WRITE
	POP {R0-R3, PC}
	ENDFUNC
	
LCD_DATA_WRITE FUNCTION
	PUSH {R0-R3, LR}
	;this function writes Data to the TFT, the data is read from R2
	;it writes HIGH to RS first to specify that we are writing data not a command.



	;RD HIGH
	LDR r1, =GPIOB_ODR
	LDR r0, [r1]
	MOV R3, #1
	LSL R3, #9
	ORR r0, r0, r3
	STRH r0, [r1]

;;;;;;;;;;;;;;;;;;;;;;;;;; SETTING RS to 1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LDR r1, =GPIOB_ODR
	LDR r0, [r1]
	MOV r3, #1
	LSL r3, #7
	ORR r0, r0, r3
	STRH r0, [r1]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	BL LCD_WRITE	;Call Function LCD_WRITE
	POP {R0-R3, PC}
	ENDFUNC
	
LCD_INIT FUNCTION
	PUSH {R0-R3, LR}
  ;This function will have LCD initialization measures
  ;Only the necessary Commands are covered
  ;Eventho there are so many more in DataSheet

;RESET_SIGNAL_HIGH
	LDR r1, =GPIOB_ODR
	LDR r0, [r1]
	MOV R3, #1
	LSL R3, #15
	ORR r0, r0, R3
	STRH r0, [r1]


	BL delay_1_second


;RESET_SIGNAL_LOW
	LDR r1, =GPIOB_ODR
	LDR r0, [r1]
	MOV R3, #1
	LSL R3, #15
	MVN R3, R3
	AND r0, r0, R3
	STRH r0, [r1]


	BL delay_10_milli_second

;RESET_SIGNAL_HIGH
	LDR r1, =GPIOB_ODR
	LDR r0, [r1]
	MOV R3, #1
	LSL R3, #15
	ORR r0, r0, R3
	STRH r0, [r1]


	BL delay_1_second


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; PREPARATION FOR WRITE CYCLE SEQUENCE ;;;;;;;;;;;;;;;;;;
	;CS HIGH
	LDR r1, =GPIOB_ODR
	LDR r0, [r1]
	MOV R3, #1
	LSL R3, #6
	ORR r0, r0, R3
	STR r0, [r1]

	;WR HIGH
	LDR r1, =GPIOB_ODR
	LDR r0, [r1]
	MOV R3, #1
	LSL R3, #8
	ORR r0, r0, r3
	STRH r0, [r1]

	;RD HIGH
	LDR r1, =GPIOB_ODR
	LDR r0, [r1]
	MOV R3, #1
	LSL R3, #9
	ORR r0, r0, r3
	STRH r0, [r1]


	;CS LOW
	LDR r1, =GPIOB_ODR
	LDR r0, [r1]
	MOV R3, #1
	LSL R3, #6
	MVN R3, R3
	AND r0, r0, R3
	STR r0, [r1]

	

	;SET THE CONTRAST
	MOV R2, #0xC5
	BL LCD_COMMAND_WRITE

	;VCOM H 1111111
	MOV R2, #0x7F
	BL LCD_DATA_WRITE

	;VCOM L 00000000
	MOV R2, #0x00
	BL LCD_DATA_WRITE


	;MEMORY ACCESS CONTROL | DATASHEET PAGE 127
	MOV R2, #0x36
	BL LCD_COMMAND_WRITE

	;ADJUST THIS VALUE TO GET RIGHT COLOR AND STARTING POINT OF X AND Y
	MOV R2, #0x60
	BL LCD_DATA_WRITE

	;COLMOD: PIXEL FORMAT SET | DATASHEET PAGE 134
	MOV R2, #0x3A
	BL LCD_COMMAND_WRITE

	;16 BIT RGB AND MCU
	MOV R2, #0x55
	BL LCD_DATA_WRITE


	
	;FRAME RATE (119HZ)
	MOV R2, #0xB1
	BL LCD_COMMAND_WRITE

	;SET DIVISION RATIO TO FOSC
	MOV R2, #0x00
	BL LCD_DATA_WRITE

	;SET CLOCKS PER LINE TO 119HZ
	MOV R2, #0x10
	BL LCD_DATA_WRITE

	;SLEEP OUT | DATASHEET PAGE 245
	MOV R2, #0x11
	BL LCD_COMMAND_WRITE

	BL delay_1_second



	;NECESSARY TO WAIT 5MSEC BEFORE SENDING NEXT COMMAND
	;I WILL WAIT FOR 10MSEC TO BE SURE

	;DISPLAY ON
	MOV R2, #0x29
	BL LCD_COMMAND_WRITE

	;COLOR INVERSION OFF
	MOV R2, #0x21
	BL LCD_COMMAND_WRITE



	;MEMORY WRITE | DATASHEET PAGE 245
	MOV R2, #0x2C
	BL LCD_COMMAND_WRITE	



	POP {R0-R3, PC}
	ENDFUNC
	
ADDRESS_SET FUNCTION
	;THIS FUNCTION TAKES X1, X2, Y1, Y2
	;IT ISSUES COLUMN ADDRESS SET TO SPECIFY THE START AND END COLUMNS (X1 AND X2)
	;IT ISSUES PAGE ADDRESS SET TO SPECIFY THE START AND END PAGE (Y1 AND Y2)
	;THIS FUNCTION JUST MARKS THE PLAYGROUND WHERE WE WILL ACTUALLY DRAW OUR PIXELS, MAYBE TARGETTING EACH PIXEL AS IT IS.
	;R0 = X1
	;R1 = X2
	;R3 = Y1
	;R4 = Y2

	;PUSHING ANY NEEDED REGISTERS
	PUSH {R0-R4, LR}
	

	;COLUMN ADDRESS SET | DATASHEET PAGE 110
	MOV R2, #0x2A
	BL LCD_COMMAND_WRITE

	;TODO: SEND THE FIRST PARAMETER (HIGHER 8-BITS OF THE STARTING COLUMN, AKA HIGHER 8-BITS OF X1)
	MOV R2, R0
	LSR R2, #8
	BL LCD_DATA_WRITE

	;TODO: SEND THE SECOND PARAMETER (LOWER 8-BITS OF THE STARTING COLUMN, AKA LOWER 8-BITS OF X1)
	MOV R2, R0
	BL LCD_DATA_WRITE


	;TODO: SEND THE THIRD PARAMETER (HIGHER 8-BITS OF THE ENDING COLUMN, AKA HIGHER 8-BITS OF X2)
	MOV R2, R4
	LSR R2, #8
	BL LCD_DATA_WRITE

	;TODO: SEND THE FOURTH PARAMETER (LOWER 8-BITS OF THE ENDING COLUMN, AKA LOWER 8-BITS OF X2)
	MOV R2, R4
	BL LCD_DATA_WRITE



	;PAGE ADDRESS SET | DATASHEET PAGE 110
	MOV R2, #0x2B
	BL LCD_COMMAND_WRITE

	;TODO: SEND THE FIRST PARAMETER (HIGHER 8-BITS OF THE STARTING PAGE, AKA HIGHER 8-BITS OF Y1)
	MOV R2, R1
	LSL R2, #8
	BL LCD_DATA_WRITE

	;TODO: SEND THE SECOND PARAMETER (LOWER 8-BITS OF THE STARTING PAGE, AKA LOWER 8-BITS OF Y1)
	MOV R2, R1
	BL LCD_DATA_WRITE


	;TODO: SEND THE THIRD PARAMETER (HIGHER 8-BITS OF THE ENDING PAGE, AKA HIGHER 8-BITS OF Y2)
	MOV R2, R3
	LSL R2, #8
	BL LCD_DATA_WRITE

	;TODO: SEND THE FOURTH PARAMETER (LOWER 8-BITS OF THE ENDING PAGE, AKA LOWER 8-BITS OF Y2)
	MOV R2, R3
	BL LCD_DATA_WRITE

	;MEMORY WRITE
	MOV R2, #0x2C
	BL LCD_COMMAND_WRITE


	;POPPING ALL REGISTERS I PUSHED
	POP {R0-R4, PC}
	ENDFUNC
	
DRAW_RECTANGLE_FILLED FUNCTION
	PUSH {R0-R10, LR}
	;TODO: IMPLEMENT THIS FUNCTION ENTIRELY, AND SPECIFY THE ARGUMENTS IN COMMENTS, WE DRAW A RECTANGLE BY SPECIFYING ITS TOP-LEFT AND LOWER-RIGHT POINTS, THEN FILL IT WITH THE SAME COLOR
	;X1 = [0] r0
	;Y1 = [0] r1
	;X2 = [240] r3
	;Y2 = [320] r4
	;AREA = [0x12C00] r5
	;COLOR = [BLUE] r10
	
	BL ADDRESS_SET
	
	;MEMORY WRITE CMD
	MOV R2, #0x2C
	BL LCD_COMMAND_WRITE
	
LOOP
	MOV R2, R10
	LSR R2, #8
	BL LCD_DATA_WRITE	;Writes lower 8 bits of color
	MOV R2, R10
	BL LCD_DATA_WRITE	;Writes higher 8 bits of color
	SUBS R5, #1
	CMP R5, #0
	BNE LOOP
	



	POP {R0-R10, PC}
	ENDFUNC

SETUP FUNCTION
	PUSH {R0-R3, LR}
	
	; Enable Port A
	LDR R0, =RCC_APB2ENR
	LDR R1, [R0]
	MOV R3, #1
	ORR R1, R1, R3, LSL #2	; Enable Port A
	STR R1, [R0]
	
	; Output mode (LOWER PINS)
	LDR R0, =GPIOA_BASE
	LDR R3, =GPIOx_CRL
	ADD R0, R0 , R3
	;LDR R1, [R0]
	MOV R3, #0x33333333
	;ORR R1, R1, R3 ; 0101: Output mode, max speed 10 MHz. Push-pull
	STR R3, [R0]
	
	; Output mode (HIGHER PINS)
	LDR R0, =GPIOA_BASE
	LDR R3, =GPIOx_CRH
	ADD R0, R0 , R3
	;LDR R1, [R0]
	MOV R3, #0x33333333
	;ORR R1, R1, R3 ; 0101: Output mode, max speed 10 MHz. Push-pull
	STR R3, [R0]
	
	; Enable Port B
	LDR R0, =RCC_APB2ENR
	LDR R1, [R0]
	MOV R3, #1
	ORR R1, R1, R3, LSL #3	; Enable Port B
	STR R1, [R0]
	
	; Output mode (LOWER PINS)
	LDR R0, =GPIOB_BASE
	LDR R3, =GPIOx_CRL
	ADD R0, R0 , R3
	;LDR R1, [R0]
	MOV R3, #0x33333333
	;ORR R1, R1, R3 ; 0101: Output mode, max speed 10 MHz. Push-pull
	STR R3, [R0]
	
	; Output mode (HIGHER PINS)
	LDR R0, =GPIOB_BASE
	LDR R3, =GPIOx_CRH
	ADD R0, R0 , R3
	;LDR R1, [R0]
	MOV R3, #0x33333333
	;ORR R1, R1, R3 ; 0101: Output mode, max speed 10 MHz. Push-pull
	STR R3, [R0]
	
	
	LDR r1, =GPIOA_ODR
	LDR r0, [r1]
	ORR r0, #0x00007F00
	STRH r0, [r1]
	
	BL LCD_INIT

	POP {R0-R3, PC}
	ENDFUNC

delay_1_second FUNCTION
	;this function just delays for 1 second
	PUSH {R8, LR}
	LDR r8, =INTERVAL
delay_loop
	SUBS r8, #1
	CMP r8, #0
	BGE delay_loop
	POP {R8, PC}
	ENDFUNC

delay_half_second FUNCTION
	;this function just delays for half a second
	PUSH {R8, LR}
	LDR r8, =INTERVAL
delay_loop1
	SUBS r8, #2
	CMP r8, #0
	BGE delay_loop1

	POP {R8, PC}
	ENDFUNC

delay_milli_second FUNCTION
	;this function just delays for a millisecond
	PUSH {R8, LR}
	LDR r8, =INTERVAL
delay_loop2
	SUBS r8, #1000
	CMP r8, #0
	BGE delay_loop2

	POP {R8, PC}
	ENDFUNC
	
delay_10_milli_second FUNCTION
	;this function just delays for 10 millisecondS
	PUSH {R8, LR}
	LDR r8, =INTERVAL
delay_loop3
	SUBS r8, #100
	CMP r8, #0
	BGE delay_loop3

	POP {R8, PC}
	ENDFUNC
	
	END
