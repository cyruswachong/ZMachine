.align 4
.global Ctype

Ctype:
PUSH {R6, R10, R11, R12}
MOV R11, #0                 ;@ AMOUNT OF OPERANDS
MOV R12, #6                 ;@ WHAT BITS TO READ
LDRB R6, [R7, R4]            ;@ LOADS BYTE AFTER OPCODE



ADD R4, #1

Ctypetest:
LSR R10, R6, R12            ;@ GETS TWO DESIRED BITS
AND R10, R10, #0b11         ;@ ISOLATES TWO DESIRED BITS
CMP R10, #0b11              ;@ CHECKING IF 2 BITS ARE "11"
BEQ check_counter           ;@ IF "11", EXIT LOOP
ADD R11, R11, #1            ;@ INCREMENTS OPERANDS IF NOT "11"
SUBS R12, R12, #2           ;@ SUBTRACTS SHIFT BY TWO, FOR NEXT 2 BITS
BMI check_counter           ;@ EXITS LOOP IF R12 IS 0
BGE Ctypetest               ;@ RELOOPS IF R12 IS NOT 0

check_counter:
PUSH {R11,R12}
LDR R12, =ZSpare
STR R11, [R12, #100]
POP {R11,R12}

    LSR R7, R8, #5              ;@ SHIFT SO 6TH BIT IS VISIBLE
    AND R7, #0b00000001         ;@ EXCTRACT 6TH BIT
    ;@MOV R10, R6                 ;@ STORE FOR LATER USE IN INSTRUCTION FINDING
    CMP R7, #0b00000001         ;@ TEST IF BIT IS 1 OR 0
    AND R9, R8, #0b00011111 ;@ GET 5 LSB OF THE OPCODE
    LDR R7, =Zmemory
    BEQ C_variable
    BNE C_twoOperands

C_twoOperands:

LSR R10, R6, #6             ;@ CHECKS LEFTMOST TWO BITS
AND R10, R10, #0b11         ;@ ISOLATES TWO LEFTMOST BITS
CMP R10, #0b10              ;@ CHECKS IF BITS ARE "10"
BLEQ Val_in_register_first
CMP R10, #01                ;@ CHECKS IF BITS ARE "01"
BLEQ eight_bit_first
BLNE sixteen_bit_first

LSR R10, R6, #4             ;@ CHECKS BITS 4 AND 5
AND R10, R10, #0b11         ;@ ISOLATES BITS 4 AND 5
CMP R10, #0b10              ;@ CHECKS IF BITS ARE "10"
BLEQ Val_in_register_second
CMP R10, #0b01              ;@ CHECKS IF BITS ARE "01"
BLEQ eight_bit_second
BLNE sixteen_bit_second

POP {R6, R10, R11, R12}
B two


C_variable:
;@ FIRST OPERAND CHECK
MOV R12, R11
LSR R10, R6, #6         ;@ CHECKS LEFTMOST TWO BITS
AND R10, R10, #0b11     ;@ ISOLATES TWO LEFTMOST BITS
SUBS R12, R12, #1       ;@ CHECKS IF OPERAND COUNT IS MET
BMI variable_exit
CMP R10, #0b10            ;@ CHECKS IF BITS ARE "10"
BLEQ Val_in_register_first
CMP R10, #0b01            ;@ CHECKS IF BITS ARE "01"
BLEQ eight_bit_first
CMP R10, #0b00
BLEQ sixteen_bit_first


;@ SECOND OPERAND CHECK
LSR R10, R6, #4         ;@ CHECKS BITS 4 AND 5
AND R10, R10, #0b11     ;@ ISOLATES BITS 4 AND 5
SUBS R12, R12, #1       ;@ CHECKS IF OPERAND COUNT IS MET
BMI variable_exit
CMP R10, #0b10            ;@ CHECKS IF BITS ARE "10"
BLEQ Val_in_register_second
CMP R10, #0b01            ;@ CHECKS IF BITS ARE "01"
BLEQ eight_bit_second
CMP R10, #0b00
BLEQ sixteen_bit_second


;@ THIRD OPERAND CHECKS
LSR R10, R6, #2         ;@ CHECKS BITS 2 AND 3
AND R10, R10, #0b11     ;@ ISOLATES BITS 2 AND 3
SUBS R12, R12, #1       ;@ CHECKS IF OPERAND COUNT IS MET
BMI variable_exit
CMP R10, #0b10            ;@ CHECKS IF BITS ARE "10"
BLEQ Val_in_register_third
CMP R10, #0b01            ;@ CHECKS IF BITS ARE "01"
BLEQ eight_bit_third
CMP R10, #0b00
BLEQ sixteen_bit_third


;@ FOURTH OPERAND CHECK
MOV R10, R6
AND R10, R10, #0b11     ;@ ISOLATES BITS 4 AND 5
SUBS R12, R12, #1       ;@ CHECKS IF OPERAND COUNT IS MET
BMI variable_exit
CMP R10, #0b10            ;@ CHECKS IF BITS ARE "10"
BLEQ Val_in_register_fourth
CMP R10, #0b01            ;@ CHECKS IF BITS ARE "01"
BLEQ eight_bit_fourth
CMP R10, #0b00
BLEQ sixteen_bit_fourth



B variable_exit

variable_exit:
POP {R6, R10, R11, R12}
b variable

Val_in_register_first:
PUSH {R14}              ;@ PUSH LR, SO IT GOES BACK TO CALL LOC.
LDRB R0, [R7, R4]       ;@ READ NEXT BYTE INTO R0
MOV R7, R0              ;@ USE R7 AS "INPUT" TO FUNCTION
;@BL checkRegisterType    ;@ CALL FUNCTION, R7 USED AS INPUT FOR FUNCTION
MOV R0, R7              ;@ MOVE VALUE FROM FUNCTION BACK INTO R0
LDR R7, =Zmemory        ;@ REALLOCATE R7 AS ZMEM
ADD R4, R4, #1          ;@ INCREMENT R4
POP {R15}

eight_bit_first:
PUSH {R14}
LDRB R0, [R7, R4]       ;@ LOAD NEXT BYTE AS R0
ADD R4, R4, #1          ;@ INCREMENT R4 BY 1
POP {R15}

sixteen_bit_first:
PUSH {R14}              ;@ POP LR
BL sixteenbitLoad
MOV R0, R7              ;@ MOVE VALUE FROM FUNCTION BACK INTO R0
LDR R7, =Zmemory        ;@ REALLOCATE R7 AS ZMEM

POP {R15}               ;@ POP BACK


Val_in_register_second:
PUSH {R14}              ;@ PUSH LR, SO IT GOES BACK TO CALL LOC.
LDRB R1, [R7, R4]       ;@ READ NEXT BYTE INTO R0
MOV R7, R1              ;@ USE R7 AS "INPUT" TO FUNCTION
;@BL checkRegisterType    ;@ CALL FUNCTION
MOV R1, R7              ;@ MOVE VALUE FROM FUNCTION BACK INTO R0
LDR R7, =Zmemory        ;@ REALLOCATE R7 AS ZMEM
ADD R4, R4, #1          ;@ INCREMENT R4
POP {R15}

eight_bit_second:
PUSH {R14}
LDRB R1, [R7, R4]       ;@ LOAD NEXT BYTE AS R0
ADD R4, R4, #1          ;@ INCREMENT R4 BY 1
POP {R15}

sixteen_bit_second:
PUSH {R14}              ;@ POP LR
BL sixteenbitLoad
MOV R1, R7              ;@ MOVE VALUE FROM FUNCTION BACK INTO R0
LDR R7, =Zmemory        ;@ REALLOCATE R7 AS ZMEM

POP {R15}               ;@ POP BACK


Val_in_register_third:
PUSH {R14}              ;@ PUSH LR, SO IT GOES BACK TO CALL LOC.
LDRB R2, [R7, R4]       ;@ READ NEXT BYTE INTO R0
MOV R7, R2              ;@ USE R7 AS "INPUT" TO FUNCTION
;@BL checkRegisterType    ;@ CALL FUNCTION
MOV R2, R7              ;@ MOVE VALUE FROM FUNCTION BACK INTO R0
LDR R7, =Zmemory        ;@ REALLOCATE R7 AS ZMEM
ADD R4, R4, #1          ;@ INCREMENT R4
POP {R15}

eight_bit_third:
PUSH {R14}
LDRB R2, [R7, R4]       ;@ LOAD NEXT BYTE AS R0
ADD R4, R4, #1          ;@ INCREMENT R4 BY 1
POP {R15}

sixteen_bit_third:
PUSH {R14}              ;@ POP LR
BL sixteenbitLoad
MOV R2, R7              ;@ MOVE VALUE FROM FUNCTION BACK INTO R0
LDR R7, =Zmemory        ;@ REALLOCATE R7 AS ZMEM

POP {R15}               ;@ POP BACK


Val_in_register_fourth:
PUSH {R14}              ;@ PUSH LR, SO IT GOES BACK TO CALL LOC.
LDRB R3, [R7, R4]       ;@ READ NEXT BYTE INTO R0
MOV R7, R1              ;@ USE R7 AS "INPUT" TO FUNCTION
;@BL checkRegisterType    ;@ CALL FUNCTION
MOV R3, R7              ;@ MOVE VALUE FROM FUNCTION BACK INTO R0
LDR R7, =Zmemory        ;@ REALLOCATE R7 AS ZMEM
ADD R4, R4, #1          ;@ INCREMENT R4
POP {R15}

eight_bit_fourth:
PUSH {R14}
LDRB R3, [R7, R4]       ;@ LOAD NEXT BYTE AS R0
ADD R4, R4, #1          ;@ INCREMENT R4 BY 1
POP {R15}

sixteen_bit_fourth:
PUSH {R14}              ;@ POP LR
BL sixteenbitLoad
MOV R3, R7              ;@ MOVE VALUE FROM FUNCTION BACK INTO R0
LDR R7, =Zmemory        ;@ REALLOCATE R7 AS ZMEM

POP {R15}               ;@ POP BACK


