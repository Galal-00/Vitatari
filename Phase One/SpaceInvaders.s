	AREA MYDATA, DATA, READONLY
	
RCC_BASE	EQU		0x40021000
RCC_APB2ENR		EQU		RCC_BASE + 0x18


AFIO_BASE		EQU		0x40010000
AFIO_MAPR	EQU		AFIO_BASE + 0x04


GPIOC_BASE         EQU      0x40011000   ; port c
GPIOC_CRH         EQU     GPIOC_BASE+0x04
GPIOC_ODR     EQU        GPIOC_BASE+0x0C
GPIOC_IDR     EQU        GPIOC_BASE+0x08
GPIOC_BRR  EQU     GPIOC_BASE +  0x14
GPIOC_BSRR  EQU     GPIOC_BASE +  0x10



GPIOA_BASE      EQU     0x40010800
GPIOA_CRH         EQU     GPIOA_BASE+0x04
GPIOA_CRL         EQU     GPIOA_BASE
GPIOA_ODR     EQU        GPIOA_BASE+0x0C
GPIOA_BRR  EQU     GPIOA_BASE +  0x14
GPIOA_BSRR  EQU     GPIOA_BASE +  0x10


GPIOB_BASE  EQU 0x40010C00
GPIOB_CRH         EQU     GPIOB_BASE+0x04
GPIOB_CRL         EQU     GPIOB_BASE
GPIOB_ODR     EQU        GPIOB_BASE+0x0C
GPIOB_BRR  EQU     GPIOB_BASE +  0x14
GPIOB_BSRR  EQU     GPIOB_BASE +  0x10


INTERVAL EQU 0x566004		;just a number to perform the delay. this number takes roughly 1 second to decrement until it reaches 0



;the following are pins connected from the TFT to our EasyMX board
;RD = PB9		Read pin	--> to read from touch screen input 
;WR = PB8		Write pin	--> to write data/command to display
;RS = PB7		Command pin	--> to choose command or data to write
;CS = PB6		Chip Select	--> to enable the TFT, lol	(active low)
;RST= PB15		Reset		--> to reset the TFT (active low)
;D0-7 = PA0-7	Data BUS	--> Put your command or data on this bus



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











	AREA MYCODE, CODE, READONLY


	EXPORT __main
    ENTRY

__main FUNCTION
    ;This is the main funcion, you should only call two functions, one that sets up the TFT
	;And the other that draws a rectangle over the entire screen (ie from (0,0) to (320,240)) with a certain color of your choice


	;FINAL TODO: CALL FUNCTION SETUP
	BL SETUP


	;FINAL TODO: DRAW THE ENTIRE SCREEN WITH A CERTAIN COLOR
	
	
;MAINLOOP


	;LDR R0, =GPIOC_IDR
	;LDR R1, [R0]
	;MOV R2, #1
	;LSL R2, #13
	;AND R1, R1, R2
	;CMP R1, #0
	;BNE MAINLOOP
	
	
	;MOV R0, #0
	;MOV R1, #0
	;MOV R3, #320
	;MOV R4, #240
	
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
	MOV R2, #250
	MOV R5, #200
	BL DRAW_SPACESHIP
	
	; SPACESHIP BULLETS
	; BULLET COORDINATES & COLOR
	MOV R2, #258
	MOV R5, #180
	LDR R10, =WHITE
	
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
	
	; GOBLIN BULLETS
	; R2, R5: (X, Y) TOP LEFT CORNER
	; R10: BULLET COLOR
	MOV R2, #180
	MOV R5, #150
	LDR R10, =GREEN
	
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
	
	; DELETE GREEN GOBLIN SPRITE
	MOV R2, #40   
	MOV R5, #120
	;BL DEL_GREEN_GOBLIN
	
		
	
	
	;LDR R10, =RED
	;BL DRAW_RECTANGLE_FILLED
    
	;LDR R10, =YELLOW
	;BL DRAW_RECTANGLE_FILLED
	
	;B MAINLOOP
	
STOP
	B STOP
    
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
	PUSH {R0-R5, LR}
	; CREATE LEGION OF GOBLINS
	; R2, R5: STARTING X, Y
	MOV R5, #41		;Y
	MOV R0, #2  ;MOVE VERTICALLY
LEGION_COLUMN
	MOV R2,#24	;X
	MOV R1, #5	;MOVE HORIZONTALLY
LEGION_ROW
	; DRAW GREEN GOBLIN SPRITE
	BL DRAW_GREEN_GOBLIN
	ADD R2, R2, #49
	SUBS R1,R1,#1
	CMP R1, #0
	BGE LEGION_ROW
	ADD R5, R5, #31
	SUBS R0,R0,#1
	CMP R0, #0
	BGE LEGION_COLUMN
	POP {R0-R5, PC}
	
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

;#####################################################################################################################################################################
LCD_WRITE   FUNCTION
	;this function takes what is inside r2 and writes it to the tft
	;this function writes 8 bits only
	;later we will choose whether those 8 bits are considered a command, or just pure data
	;your job is to just write 8-bits (regardless if data or command) to PE0-7 and set WR appropriately
	;arguments: R2 = data to be written to the D0-7 bus

	;TODO: PUSH THE NEEDED REGISTERS TO SAVE THEIR CONTENTS. HINT: Push any register you will modify inside the function
	PUSH {r0-r3, LR}


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SETTING WR to 0 ;;;;;;;;;;;;;;;;;;;;;
	;TODO: RESET WR TO 0
	LDR r1, =GPIOB_ODR
	LDR r0, [r1]
	MOV R3, #1
	LSL R3, #8
	MVN R3, R3
	AND r0, r0, R3
	STRH r0, [r1]
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;BL delay_1_second

	;;;;;;;;;;;;; HERE YOU PUT YOUR DATA which is in R2 TO PE0-7 ;;;;;;;;;;;;;;;;;
	;TODO: SET PE0-7 WITH THE LOWER 8-bits of R2
	LDR r1, =GPIOA_ODR
	STRB r2, [r1]			;only write the lower byte to PE0-7
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;BL delay_1_second

	;;;;;;;;;;;;;;;;;;;;;;;;;; SETTING WR to 1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;TODO: SET WR TO 1 AGAIN (ie make a rising edge)
	LDR r1, =GPIOB_ODR
	LDR r0, [r1]
	MOV R3, #1
	ORR r0, r0, R3, LSL #8
	STRH r0, [r1]
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;BL delay_1_second


	;TODO: POP THE REGISTERS YOU JUST PUSHED.
	POP {R0-r3, PC}
    ENDFUNC
;#####################################################################################################################################################################




;#####################################################################################################################################################################
LCD_COMMAND_WRITE   FUNCTION
	;this function writes a command to the TFT, the command is read from R2
	;it writes LOW to RS first to specify that we are writing a command not data.
	;then it normally calls the function LCD_WRITE we just defined above
	;arguments: R2 = data to be written on D0-7 bus

	;TODO: PUSH ANY NEEDED REGISTERS
	PUSH {R0-R3, LR}
	


	;TODO: SET RD HIGH (we won't need reading anyways, but we must keep read pin to high, which means we will not read anything)
	LDR r1, =GPIOB_ODR
	LDR r0, [r1]
	MOV R3, #1
	ORR r0, r0, R3, LSL #9
	STRH r0, [r1]

	;;;;;;;;;;;;;;;;;;;;;;;;; SETTING RS to 0 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;TODO: SET RS TO 0 (to specify that we are writing commands not data on the D0-7 bus)
	LDR r1, =GPIOB_ODR
	LDR r0, [r1]
	MOV R3, #1
	LSL R3, #7
	MVN R3, R3
	AND r0, r0, R3
	STRH r0, [r1]
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;TODO: CALL FUNCTION LCD_WRITE
	BL LCD_WRITE


	;TODO: POP ALL REGISTERS YOU PUSHED
	POP {R0-R3, PC}
    ENDFUNC
;#####################################################################################################################################################################






;#####################################################################################################################################################################
LCD_DATA_WRITE  FUNCTION
	;this function writes Data to the TFT, the data is read from R2
	;it writes HIGH to RS first to specify that we are writing actual data not a command.
	;arguments: R2 = data

	;TODO: PUSH ANY NEEDED REGISTERS
	PUSH {R0-R3, LR}

	;TODO: SET RD TO HIGH (we don't need to read anything)
	LDR r1, =GPIOB_ODR
	LDR r0, [r1]
	MOV R3, #1
	ORR r0, r0, R3, LSL #9
	STRH r0, [r1]

	;;;;;;;;;;;;;;;;;;;; SETTING RS to 1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;TODO: SET RS TO 1 (to specify that we are sending actual data not a command on the D0-7 bus)
	LDR r1, =GPIOB_ODR
	LDR r0, [r1]
	MOV R3, #1
	ORR r0, r0, R3, LSL #7
	STRH r0, [r1]
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;TODO: CALL FUNCTION LCD_WRITE
	BL LCD_WRITE

	;TODO: POP ANY REGISTER YOU PUSHED
	POP {R0-R3, PC}
    ENDFUNC
	
;#####################################################################################################################################################################
	
;#####################################################################################################################################################################
LCD_INIT    FUNCTION
	;This function executes the minimum needed LCD initialization measures
	;Only the necessary Commands are covered
	;Eventho there are so many more in the DataSheet

	;TODO: PUSH ANY NEEDED REGISTERS
  	PUSH {R0-R3, LR}

	;;;;;;;;;;;;;;;;; HARDWARE RESET (putting RST to high then low then high again) ;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;TODO: SET RESET PIN TO HIGH
	LDR r1, =GPIOB_ODR
	LDR r0, [r1]
	MOV R3, #1
	ORR r0, r0, R3, LSL #15
	STRH r0, [r1]

	;TODO: DELAY FOR SOME TIME
	BL delay_1_second

	;TODO: RESET RESET PIN TO LOW
	LDR r1, =GPIOB_ODR
	LDR r0, [r1]
	MOV R3, #1
	LSL R3, #15
	MVN R3, R3
	AND r0, r0, R3
	STRH r0, [r1]

	;TODO: DELAY FOR SOME TIME
	BL delay_1_second

	;TODO: SET RESET PIN TO HIGH AGAIN
	LDR r1, =GPIOB_ODR
	LDR r0, [r1]
	MOV R3, #1
	ORR r0, r0, R3, LSL #15
	STRH r0, [r1]

	;TODO: DELAY FOR SOME TIME
	BL delay_1_second
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;






	;;;;;;;;;;;;;;;;; PREPARATION FOR WRITE CYCLE SEQUENCE (setting CS to high, then configuring WR and RD, then resetting CS to low) ;;;;;;;;;;;;;;;;;;
	;TODO: SET CS PIN HIGH
	LDR r1, =GPIOB_ODR
	LDR r0, [r1]
	MOV R3, #1
	ORR r0, r0, R3, LSL #6
	STR r0, [r1]
    
    

	;TODO: SET WR PIN HIGH
	LDR r1, =GPIOB_ODR
	LDR r0, [r1]
	MOV R3, #1
	ORR r0, r0, R3, LSL #8
	STRH r0, [r1]

	;TODO: SET RD PIN HIGH
	LDR r1, =GPIOB_ODR
	LDR r0, [r1]
	MOV R3, #1
	ORR r0, r0, R3, LSL #9
	STRH r0, [r1]

    

	;TODO: SET CS PIN LOW
	LDR r1, =GPIOB_ODR
	LDR r0, [r1]
	MOV R3, #1
	LSL R3, #6
	MVN R3, R3
	AND r0, r0, R3
	STR r0, [r1]
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	




	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SOFTWARE INITIALIZATION SEQUENCE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;TODO: ISSUE THE "SET CONTRAST" COMMAND, ITS HEX CODE IS 0xC5
	MOV R2, #0xC5
	BL LCD_COMMAND_WRITE

	;THIS COMMAND REQUIRES 2 PARAMETERS TO BE SENT AS DATA, THE VCOM H, AND THE VCOM L
	;WE WANT TO SET VCOM H TO A SPECIFIC VOLTAGE WITH CORRESPONDS TO A BINARY CODE OF 1111111 OR 0x7F HEXA
	;TODO: SEND THE FIRST PARAMETER (THE VCOM H) NEEDED BY THE COMMAND, WITH HEX 0x7F, PARAMETERS ARE SENT AS DATA BUT COMMANDS ARE SENT AS COMMANDS
	MOV R2, #0x7F
	BL LCD_DATA_WRITE

	;WE WANT TO SET VCOM L TO A SPECIFIC VOLTAGE WITH CORRESPONDS TO A BINARY CODE OF 00000000 OR 0x00 HEXA
	;TODO: SEND THE SECOND PARAMETER (THE VCOM L) NEEDED BY THE CONTRAST COMMAND, WITH HEX 0x00, PARAMETERS ARE SENT AS DATA BUT COMMANDS ARE SENT AS COMMANDS
	MOV R2, #0x00
	BL LCD_DATA_WRITE


	;MEMORY ACCESS CONTROL AKA MADCLT | DATASHEET PAGE 127
	;WE WANT TO SET MX (to draw from left to right) AND SET MV (to configure the TFT to be in horizontal landscape mode, not a vertical screen)
	;TODO: ISSUE THE COMMAND MEMORY ACCESS CONTROL, HEXCODE 0x36
	MOV R2, #0x36
	BL LCD_COMMAND_WRITE

	;TODO: SEND ONE NEEDED PARAMETER ONLY WITH MX AND MV SET TO 1. HOW WILL WE SEND PARAMETERS? AS DATA OR AS COMMAND?
	MOV R2, #0x08
	BL LCD_DATA_WRITE



	;COLMOD: PIXEL FORMAT SET | DATASHEET PAGE 134
	;THIS COMMAND LETS US CHOOSE WHETHER WE WANT TO USE 16-BIT COLORS OR 18-BIT COLORS.
	;WE WILL ALWAYS USE 16-BIT COLORS
	;TODO: ISSUE THE COMMAND COLMOD
	MOV R2, #0x3A
	BL LCD_COMMAND_WRITE

	;TODO: SEND THE NEEDED PARAMETER WHICH CORRESPONDS TO 16-BIT RGB AND 16-BIT MCU INTERFACE FORMAT
	MOV R2, #0x55
	BL LCD_DATA_WRITE
	


	;SLEEP OUT | DATASHEET PAGE 101
	;TODO: ISSUE THE SLEEP OUT COMMAND TO EXIT SLEEP MODE (THIS COMMAND TAKES NO PARAMETERS, JUST SEND THE COMMAND)
	MOV R2, #0x11
	BL LCD_COMMAND_WRITE

	;NECESSARY TO WAIT 5ms BEFORE SENDING NEXT COMMAND
	;I WILL WAIT FOR 10MSEC TO BE SURE
	;TODO: DELAY FOR AT LEAST 10ms
	BL delay_1_second


	;DISPLAY ON | DATASHEET PAGE 109
	;TODO: ISSUE THE COMMAND, IT TAKES NO PARAMETERS
	MOV R2, #0x29
	BL LCD_COMMAND_WRITE


	;COLOR INVERSION OFF | DATASHEET PAGE 105
	;NOTE: SOME TFTs HAS COLOR INVERTED BY DEFAULT, SO YOU WOULD HAVE TO INVERT THE COLOR MANUALLY SO COLORS APPEAR NATURAL
	;MEANING THAT IF THE COLORS ARE INVERTED WHILE YOU ALREADY TURNED OFF INVERSION, YOU HAVE TO TURN ON INVERSION NOT TURN IT OFF.
	;TODO: ISSUE THE COMMAND, IT TAKES NO PARAMETERS
	MOV R2, #0x20
	BL LCD_COMMAND_WRITE



	;MEMORY WRITE | DATASHEET PAGE 245
	;WE NEED TO PREPARE OUR TFT TO SEND PIXEL DATA, MEMORY WRITE SHOULD ALWAYS BE ISSUED BEFORE ANY PIXEL DATA SENT
	;TODO: ISSUE MEMORY WRITE COMMAND
	MOV R2, #0x2C
	BL LCD_COMMAND_WRITE	


	;TODO: POP ALL PUSHED REGISTERS
	POP {R0-R3, PC}
    ENDFUNC
;#####################################################################################################################################################################









;#####################################################################################################################################################################
ADDRESS_SET     FUNCTION
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
	MOV R2, R1
	LSR R2, #8
	BL LCD_DATA_WRITE

	;TODO: SEND THE FOURTH PARAMETER (LOWER 8-BITS OF THE ENDING COLUMN, AKA LOWER 8-BITS OF X2)
	MOV R2, R1
	BL LCD_DATA_WRITE



	;PAGE ADDRESS SET | DATASHEET PAGE 110
	MOV R2, #0x2B
	BL LCD_COMMAND_WRITE

	;TODO: SEND THE FIRST PARAMETER (HIGHER 8-BITS OF THE STARTING PAGE, AKA HIGHER 8-BITS OF Y1)
	MOV R2, R3
	LSR R2, #8
	BL LCD_DATA_WRITE

	;TODO: SEND THE SECOND PARAMETER (LOWER 8-BITS OF THE STARTING PAGE, AKA LOWER 8-BITS OF Y1)
	MOV R2, R3
	BL LCD_DATA_WRITE


	;TODO: SEND THE THIRD PARAMETER (HIGHER 8-BITS OF THE ENDING PAGE, AKA HIGHER 8-BITS OF Y2)
	MOV R2, R4
	LSR R2, #8
	BL LCD_DATA_WRITE

	;TODO: SEND THE FOURTH PARAMETER (LOWER 8-BITS OF THE ENDING PAGE, AKA LOWER 8-BITS OF Y2)
	MOV R2, R4
	BL LCD_DATA_WRITE

	;MEMORY WRITE
	MOV R2, #0x2C
	BL LCD_COMMAND_WRITE


	;POPPING ALL REGISTERS I PUSHED
	POP {R0-R4, PC}
    ENDFUNC
;#####################################################################################################################################################################





;#####################################################################################################################################################################
DRAWPIXEL   FUNCTION
	PUSH {R0-R5, r10, LR}
	;THIS FUNCTION TAKES X AND Y AND A COLOR AND DRAWS THIS EXACT PIXEL
	;NOTE YOU HAVE TO CALL ADDRESS SET ON A SPECIFIC PIXEL WITH LENGTH 1 AND WIDTH 1 FROM THE STARTING COORDINATES OF THE PIXEL, THOSE STARTING COORDINATES ARE GIVEN AS PARAMETERS
	;THEN YOU SIMPLY ISSUE MEMORY WRITE COMMAND AND SEND THE COLOR
	;R0 = X
	;R1 = Y
	;R10 = COLOR

	;CHIP SELECT ACTIVE, WRITE LOW TO CS
	LDR r3, =GPIOB_ODR
	LDR r4, [r3]
	MOV R5, #1
	LSL R5, #6
	MVN R5, R5
	AND r4, r4, R5
	STR r4, [r3]

	;TODO: SETTING PARAMETERS FOR FUNC 'ADDRESS_SET' CALL, THEN CALL FUNCTION ADDRESS SET
	;NOTE YOU MIGHT WANT TO PERFORM PARAMETER REORDERING, AS ADDRESS SET FUNCTION TAKES X1, X2, Y1, Y2 IN R0, R1, R3, R4 BUT THIS FUNCTION TAKES X,Y IN R0 AND R1
	MOV R3, R1 ;Y1
	ADD R1, R0, #1 ;X2
	ADD R4, R3, #1 ;Y2
	BL ADDRESS_SET


	
	;MEMORY WRITE
	MOV R2, #0x2C
	BL LCD_COMMAND_WRITE


	;SEND THE COLOR DATA | DATASHEET PAGE 114
	;HINT: WE SEND THE HIGHER 8-BITS OF THE COLOR FIRST, THEN THE LOWER 8-BITS
	;HINT: WE SEND THE COLOR OF ONLY 1 PIXEL BY 2 DATA WRITES, THE FIRST TO SEND THE HIGHER 8-BITS OF THE COLOR, THE SECOND TO SEND THE LOWER 8-BITS OF THE COLOR
	;REMINDER: WE USE 16-BIT PER PIXEL COLOR
	;TODO: SEND THE SINGLE COLOR, PASSED IN R10
	MOV R2, R10
	LSR R2, #8
	BL LCD_DATA_WRITE
	MOV R2, R10
	BL LCD_DATA_WRITE


	
	POP {R0-R5, r10, PC}
    ENDFUNC
;#####################################################################################################################################################################







;##########################################################################################################################################
DRAW_RECTANGLE_FILLED   FUNCTION
	;TODO: IMPLEMENT THIS FUNCTION ENTIRELY, AND SPECIFY THE ARGUMENTS IN COMMENTS, WE DRAW A RECTANGLE BY SPECIFYING ITS TOP-LEFT AND LOWER-RIGHT POINTS, THEN FILL IT WITH THE SAME COLOR
	;X1 = [] r0
	;Y1 = [] r1
	;X2 = [] r3
	;Y2 = [] r4
	;COLOR = [] r10
	
	
	PUSH {R0-R12, LR}
	
	push{r0-r4}


	PUSH {R1}
	PUSH {R3}
	
	pop {r1}
	pop {r3}
	
	;THE NEXT FUNCTION TAKES x1, x2, y1, y2
	;R0 = x1
	;R1 = x2
	;R3 = y1
	;R4 = y2
	bl ADDRESS_SET
	
	pop{r0-r4}
	

	SUBS R3, R3, R0
	add r3, r3, #1
	SUBS R4, R4, R1
	add r4, r4, #1
	MUL R3, R3, R4


;MEMORY WRITE
	MOV R2, #0x2C
	BL LCD_COMMAND_WRITE


RECT_FILL_LOOP
	MOV R2, R10
	LSR R2, #8
	BL LCD_DATA_WRITE
	MOV R2, R10
	BL LCD_DATA_WRITE

	SUBS R3, R3, #1
	CMP R3, #0
	BGT RECT_FILL_LOOP


END_RECT_FILL
	POP {R0-R12, PC}

    ENDFUNC
;##########################################################################################################################################









;#####################################################################################################################################################################
SETUP   FUNCTION
	;THIS FUNCTION ENABLES PORT E, MARKS IT AS OUTPUT, CONFIGURES SOME GPIO
	;THEN FINALLY IT CALLS LCD_INIT (HINT, USE THIS SETUP FUNCTION DIRECTLY IN THE MAIN)
	PUSH {R0-R12, LR}

    BL PORTA_CONF    

	BL LCD_INIT

	POP {R0-R12, PC}

    ENDFUNC
;#####################################################################################################################################################################










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
    MOV R2, #0x33333333     ;ALL 8 LOWER PINS OF PORT A AS OUTPUT WITH MAX SPEED OF 50 MHZ
    STR R2, [R0]                 ; Write the updated value back to GPIOC_CRH



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







    POP{R0-R2, PC}

    ENDFUNC










delay_1_second FUNCTION
    PUSH {R0-R12, LR}               ; Push R4 and Link Register (LR) onto the stack
    LDR R0, =INTERVAL           ; Load the delay count
DelayInner_Loop
        SUBS R0, #1             ; Decrement the delay count
		cmp	R0, #0
        BGT DelayInner_Loop     ; Branch until the count becomes zero
    
    POP {R0-R12, PC}                ; Pop R4 and return from subroutine
	ENDFUNC

	
	





delay_10_MILLIsecond FUNCTION
    PUSH {R0-R12, LR}               ; Push R4 and Link Register (LR) onto the stack
    LDR R0, =INTERVAL           ; Load the delay count
DelayInner_Loop2
        SUBS R0, #1000             ; Decrement the delay count
		cmp	R0, #0
        BGT DelayInner_Loop2     ; Branch until the count becomes zero
    
    POP {R0-R12, PC}                ; Pop R4 and return from subroutine
	ENDFUNC

;##########

	END