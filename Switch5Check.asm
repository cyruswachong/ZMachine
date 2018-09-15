.global CheckSwitch5




CheckSwitch5:
PUSH {R6, R7, R8, R9, R10, R11, R14}
LDR R9,= 0x41220000
LDR R8, [R9]        ;@ load value of switches
TST R8, #32         ;@ check if sw 5 is up
BNE print            ;@ if not up, exit
BEQ exit           ;@ if equal, print out op code and opernads


print:

	LDR R11, =ZSpare
	LDRB R8, [R11, #300]
	LDR R10, =# 0xE0001030
	MOV R9, #48
	STR R9, [R10]
	MOV R9, #120
	STR R9, [R10]

	LSR R9, R8, #28
	CMP R9, #10
	BLGE letter
	BLLT num

	LSR R9, R8, #24
	AND R9, #0b00001111
	CMP R9, #10
	BLGE letter
	BLLT num

	LSR R9, R8, #20
	AND R9, #0b00001111
	CMP R9, #10
	BLGE letter
	BLLT num

	LSR R9, R8, #16
	AND R9, #0b00001111
	CMP R9, #10
	BLGE letter
	BLLT num

    LSR R9, R8, #12
    AND R9, #0b00001111
    CMP R9, #10
    BLGE letter
    BLLT num

    LSR R9, R8, #8
    AND R9, #0b00001111
    CMP R9, #10
    BLGE letter
    BLLT num

    LSR R9, R8, #4
    AND R9, #0b00001111
    CMP R9, #10
    BLGE letter
    BLLT num

    LSR R9, R8, #0
    AND R9, #0b00001111
    CMP R9, #10
    BLGE letter
    BLLT num
	B loop1
num:
PUSH {R14}
ADD R9, #48
STR R9, [R10]
POP {R15}

letter:
PUSH {R14}
ADD R9, #87
STR R9, [R10]
POP {R15}





	loop1:
	LDR R9, = ZSpare		;@ read number of operands
	LDR R9, [R9, #100]

	LDR R10, =#0xE0001030
	MOV R11, #10
	STR R11, [R10]
	MOV R11, #79
	STR R11, [R10]
	MOV R11, #80
	STR R11, [R10]
	MOV R11, #69
	STR R11, [R10]
	MOV R11, #82
	STR R11, [R10]
	MOV R11, #65
	STR R11, [R10]
	MOV R11, #78
	STR R11, [R10]
	MOV R11, #68
	STR R11, [R10]
	MOV R11, #83
	STR R11, [R10]
	MOV R11, #58
	STR R11, [R10]
	SUBS R9, #1
	BMI exit
	MOV R8, R0
	MOV R7, #12

	BL printOpcode
	SUBS R9, #1
	BMI exit
	MOV R8, R1
	MOV R7, #12
	BL printOpcode
	SUBS R9, #1
	BMI exit
	MOV R8, R2
	MOV R7, #12
	BL printOpcode
	SUBS R9, #1
	BMI exit
	MOV R8, R3
	MOV R7, #12
	BL printOpcode
	SUBS R9, #1
	BMI exit
    B exit
printOpcode:
	PUSH {R14}
	LDR R10, =# 0xE0001030
	MOV R11, #10
	STR R11, [R10]
	MOV R11, #13
	STR R11, [R10]
	MOV R11, #48
	STR R11, [R10]
	MOV R11, #120
	STR R11, [R10]
printOpcode1:
	LSR R11, R8, R7
	AND R11, #0b00001111
	CMP R11, #10
	BLGE letter_op
	BLLT num_op
	SUBS R7, #4
	POPMI {R15}
	B printOpcode1

letter_op:
PUSH {R14}
LDR R10, =# 0xE0001030
ADD R11, #87
STR R11, [R10]
POP {R15}

num_op:
PUSH {R14}
LDR R10, =# 0xE0001030
ADD R11, #48
STR R11, [R10]
POP {R15}

exit:
POP {R6, R7, R8, R9, R10, R11, R15}
