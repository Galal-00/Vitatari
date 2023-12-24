	AREA DEFINTIONS_DATA, DATA, READONLY
	
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
GPIOA_IDR     EQU        GPIOA_BASE + 0x08
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
ORANGE  EQU     0xFF5B
RED2   	EQU 	0x4000
GREEN 	EQU  	0x07E0
CYAN  	EQU  	0x07FF
MAGENTA EQU 	0xF81F
YELLOW	EQU  	0xFFE0
WHITE 	EQU  	0xFFFF
GREEN2 	EQU 	0x2FA4
CYAN2 	EQU  	0x07FF

;## BreakOut Consts
PlatformWidth EQU 47
PlatformHeight EQU 4

SPRITE_X	DCW		150
SPRITE_Y	DCW		221
	
	
	
	END

	