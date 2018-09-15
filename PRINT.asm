.global PRINT_1

PRINT_1:
PUSH {R0, R1, R2, R3, R5, R6}

setup:
LDR R6, =#-5
MOV R3, #10         ;@ OFFSET FOR R3
LDR R7, =Zmemory
BL sixteenbitLoad
MOV R0, R7          ;@ FIRST 16 BITS
LDR R7, =Zmemory


Tester:
LSR R1, R0, R3
SUB R3, R3, #5
CMP R3, R6
BMI checkStop
AND R1, R1, #0b11111
CMP R1, #0
BEQ space
CMP R1, #1
BEQ newline

CMP R1, #31
CMPLT R1, #6
BGE numberprint
B questionmark

space:
LDR R2, =#32
LDR R5, =# 0xE0001030
STR R2, [R5]
B Tester

newline:
LDR R2, =#10
LDR R5, =# 0xE0001030
STR R2, [R5]
B Tester

numberprint:
ADD R2, R1, #91
LDR R5, =# 0xE0001030
STR R2, [R5]
B Tester

questionmark:
LDR R2, =#63
LDR R5, =# 0xE0001030
STR R2, [R5]
B Tester

checkStop:
LSR R1, R0, #15
AND R1, R1, #0b1
CMP R1, #0
BEQ setup

POP {R0, R1, R2, R3, R5, R6}
B DonePrevInstr
