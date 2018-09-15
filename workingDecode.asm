.global zero
.global one
.global two
.global variable
.global decode
.global PRINT_NUM
.align 4

decode:
	MOV R12, #0 ;@ONLY USED IN DIV AND MOD
	MOV R6, #0

checkType:
    LDRB R8, [R7,R4]            ;@ LOAD BYTE OF ZMEMORY AT OFFSET OF ZPC INTO R8
	    PUSH {R5, R11}
		LDR R11, =ZSpare
		MOV R5, R4
		STR R5, [R11, #150]		;@ load zpc value of opcode into mem
		STRB R8, [R11, #300]
		POP {R5,R11}
    MOV R11, R4                 ;@ MOVE CURRENT ZPC INTO R11
    ADD R4, R4, #1              ;@ INCREMENT ZPC
    LSR R9, R8, #6              ;@ SHIFT SO ONLY 6TH AND 7TH BIT REMAIN
    CMP R9, #0b11               ;@ TESTING IF CTYPE
    BEQ Ctype
    CMP R9, #0b10               ;@ TESTING IF ATYPE
    BEQ Atype
    B Btype                     ;@ ELSE, BTYPE

Atype:
    LSR R9, R8, #4              ;@ SHIFT SO 4TH AND 5TH BIT ARE LSB'S
    AND R9, #0b00000011         ;@ EXTRACT 4TH AND 5TH BITS
    MOV R10, R9                 ;@ STORE FOR LATER USE IN INSTRUCTION FINDING
    CMP R9, #0b00000011         ;@ TEST IF THE BITS ARE "11"
    BEQ zeroOperands            ;@ IF BITS ARE "11", THERE ARE ZERO OPERANDS
    BNE oneOperand              ;@ IF ANOTHER COMBINATION, THERE IS 1 OPERAND

Btype:
    LSR R9, R8, #6              ;@ SHIFT SO 6TH BIT IS VISIBLE
    AND R9, #0b00000001         ;@ EXCTRACT 6TH BIT
    MOV R10, R9                 ;@ STORE FOR LATER USE IN INSTRUCTION FINDING
    CMP R9, #0b00000001         ;@ TEST IF BIT IS 1 OR 0
    BEQ Bindicator1B            ;@ IF 6TH BIT IS 0, INDICATOR
    BNE Bconstant1B             ;@ IF 6TH BIT IS 1, CONSTANT

Bindicator1B:
	LDRB R0, [R7,R4]            ;@ LOADS NEXT BYTE FROM ZMEMORY INTO R0
    ADD R4, #1                  ;@ INCREMENTS R4 AHEAD OF TIME FOR NEXT READ
    MOV R7, R0
    BL checkRegisterType
    MOV R0, R7
    LDR R7, =Zmemory
    B Btype2

Bconstant1B:
    LDRB R0, [R7,R4]            ;@ LOADS NEXT BYTE FROM ZMEMORY INTO R0
    ADD R4, #1                  ;@ INCREMENTS R4 AHEAD OF TIME FOR NEXT READ
    B Btype2

Btype2:
    LSR R9, R8, #5              ;@ SHIFT SO 5TH BIT IS LSB
    AND R9, #0b00000001         ;@ EXTRACT 5TH BIT
    MOV R10, R9                 ;@ STORE FOR LATER USE IN INSTRUCTION FINDING
    CMP R9, #0b00000001         ;@ CHECKING 5TH BIT VALUE
    BEQ B2indicator1B           ;@ IF 5TH BIT IS 0, INDICATOR
    BNE B2constant1B            ;@ IF 5TH BIT IS 1, CONSTANT

B2indicator1B:
    ;@store into R1
	LDRB R7, [R7, R4]           ;@ most likely will change, but still need to
    ADD R4, #1                  ;@ INCREMENTS R4 AHEAD OF TIME FOR NEXT READ
    BL checkRegisterType
    MOV R1, R7
    LDR R7, =Zmemory
    AND R9, R8, #0b00011111     ;@ EXTRACTS LAST 5 BITS FROM R8, PUSH INTO R9
    B two

B2constant1B:
    ;@store into R1
    LDRB R1, [R7, R4]           ;@ LOADS NEXT BYTE INTO R1
    ADD R4, #1                  ;@ INCREMENTS R4 AHEAD OF TIME FOR NEXT READ
    AND R9, R8, #0b00011111     ;@ EXTRACTS LAST 5 BITS FROM R8, PUSH INTO R9
    B two

zeroOperands:
    B AInstructionIndicator     ;@ DOES NOT DO ANYTHING, GOES DIRECTLY TO WHERE IT NEEDS TO

oneOperand:                     ;@ TEST IF BITS ARE 01, 10, OR 00
    CMP R9, #0b10               ;@ TESTS IF "10"
    BEQ Aindicator1B            ;@ IF "10", GO HERE
    CMP R9, #0b01               ;@ TESTS IF "01"
    BEQ Aconstant1B             ;@ IF "01", GO HERE
    B Aconstant2B               ;@ ELSE IF "00", GO HERE

Aconstant1B:
        ;@ RETRIEVE FIRST OPERAND, AND STORE INTO R0
    LDRB R0, [R7,R4]
    ADD R4, #1
    B AInstructionIndicator


Aconstant2B:
    ;@ Retrieve Operand and store into R0
    BL sixteenbitLoad
    MOV R0, R7
    LDR R7, =Zmemory
    B AInstructionIndicator

Aindicator1B:
    LDRB R7, [R7,R4]            ;@ LOADS NEXT BYTE FROM ZMEMORY INTO R0
    ADD R4, #1                  ;@ INCREMENTS R4 AHEAD OF TIME FOR NEXT READ
    BL checkRegisterType
    MOV R0, R7
    LDR R7, =Zmemory
    B AInstructionIndicator


AInstructionIndicator:
    AND R9, R8, #0b00001111 ;@ GET 4 LSB OF THE OPCODE
    CMP R10, #0b00000011    ;@ R10 DETERMINES NUMBER OF OPERANDS (SAVED VALUES OF 4TH AND 5TH BIT)
    BEQ zero                ;@ IF 4TH AND 5TH BITS ARE "00", THEN ZERO OPERANDS
    B one                   ;@ IF THEY ARE ANY OTHER COMBINATION, ONE OPERAND

zero:
PUSH {R11,R12}
LDR R12, =ZSpare
MOV R11, #0
STR R11, [R12, #100]
POP {R11,R12}
    CMP R9, #0b00000010
    BEQ PRINT

    CMP R9, #0b00001000
    BEQ RET_POPPED

    CMP R9, #0b00001101
    BEQ VERIFY

    B crash

one:
PUSH {R11,R12}
LDR R12, =ZSpare
MOV R11, #1
STR R11, [R12, #100]
POP {R11,R12}
    CMP R9, #0b00000101
    BEQ INC

    CMP R9, #0b00000110
    BEQ DEC

    CMP R9, #0b00001111
    BEQ CALL_1N

    CMP R9, #0b00001011
    BEQ RET

    B crash

two:
PUSH {R11,R12}
LDR R12, =ZSpare
MOV R11, #2
STR R11, [R12, #100]
POP {R11,R12}

    CMP R9, #0b00010100
    BEQ ADD

    CMP R9, #0b00010101
    BEQ SUB

    CMP R9, #0b00010110
    BEQ MUL

    CMP R9, #0b00010111
    BEQ DIV

    CMP R9, #0b00011000
    BEQ MOD

    CMP R9, #0b00000001
    BEQ JE

    CMP R9, #0b00000010
    BEQ JL

    CMP R9, #0b00000011
    BEQ JG

    CMP R9, #0b00011001
    BEQ CALL_2S

    CMP R9, #0b00011010
    BEQ CALL_2N

    CMP R9, #0b00001010
    BEQ TEST_ATTR

    CMP R9, #0b00001011
    BEQ SET_ATTR

    CMP R9, #0b00001100
    BEQ CLEAR_ATTR

    B crash


variable:
    CMP R9, #0b00011000
    BEQ NOT

    CMP R9, #0b00000101
    BEQ PRINT_CHAR

    CMP R9, #0b00000110
    BEQ PRINT_NUM

    CMP R9, #0b00001000
    BEQ PUSH

    CMP R9, #0b00001001
    BEQ PULL

    B crash


;@==================================================================================INSTRUCTIONS========================================================================================
;@==================================================================================INSTRUCTIONS========================================================================================
;@==================================================================================INSTRUCTIONS========================================================================================

;@ 0 Operand Instructions

PRINT:
B PRINT_1

RET_POPPED:
B RET_POPPED

VERIFY:
B VERIFY_1

;@ 1 Operand Instructions

INC:
    B INC

DEC:
    B DEC

CALL_1N:
    B CALL_1N

RET:
    B RET

;@ 2 Operand Instructions

ADD:
	ADD R8, R0, R1 ;@R11 is currently the destination but this most likely will have to be stored in some locaton in Zmemory
	LDRB R7, [R7,R4]
	ADD R4, #1
	BL destination
	BL CheckSwitch5
	B DonePrevInstr

SUB:
	SUB R8, R0, R1	;@R11 is currently the destination but this most likely will have to be stored in some locaton in Zmemory
	LDRB R7, [R7,R4]
	ADD R4, #1
	BL destination
	BL CheckSwitch5
	B DonePrevInstr

MUL:
	BL mult
	MOV R8, R0
	LDRB R7, [R7,R4]
	ADD R4, #1
	BL destination
	BL CheckSwitch5
	B DonePrevInstr

DIV:
	BL divide
	MOV R8, R0
	LDRB R7, [R7,R4]
	ADD R4, #1
	BL destination
	BL CheckSwitch5
	B DonePrevInstr

MOD:
	BL modulus
	MOV R8, R0
	LDRB R7, [R7,R4]
	ADD R4, #1
    BL destination
    BL CheckSwitch5
	B DonePrevInstr
JE:

    B crash

JL:
    B crash

JG:
    B crash

CALL_2S:
    B CALL_2S

CALL_2N:
    B CALL_2N

TEST_ATTR:
    B TEST_ATTR

SET_ATTR:
    B SET_ATTR

CLEAR_ATTR:
    B CLEAR_ATTR

;@ Variable Operand Instructions

NOT:
B NOT

PRINT_CHAR:
PUSH {R10}
LDR R10, =#0xE0001030
STR R0, [R10]
POP {R10}
BL CheckSwitch5
B DonePrevInstr


PRINT_NUM:
BL printnum
PUSH {R9, R10, R11}
LDR R10, =#0xE0001030
LDRB R9, [R0]
STRB R9, [R10]
LDRB R9, [R0, #1]
STRB R9, [R10]
LDRB R9, [R0, #2]
STRB R9, [R10]
LDRB R9, [R0, #3]
STRB R9, [R10]
LDRB R9, [R0, #4]
STRB R9, [R10]
LDRB R9, [R0, #5]
STRB R9, [R10]
POP {R9, R10, R11}
BL CheckSwitch5
B DonePrevInstr

PUSH:
B PUSH

PULL:
B PULL

;@==================================================================================INSTRUCTIONS========================================================================================
;@==================================================================================INSTRUCTIONS========================================================================================
;@==================================================================================INSTRUCTIONS========================================================================================
