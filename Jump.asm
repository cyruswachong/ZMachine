JE:
MOV R8, #0
CMP R0, R1
MOVEQ R8, #1
BL Check7th
CMP R8, R9
BEQ branchCall
BNE DonePrevInstr

JL:
LSL R0, R0, #16
ASR R0, R0, #16
LSL R1, R1, #16
ASR R1, R1, #16

MOV R8, #0
CMP R0, R1
MOVLT R8, #1
BL Check7th
CMP R8, R9
BEQ branchCall
BNE DonePrevInstr

JG:
LSL R0, R0, #16
ASR R0, R0, #16
LSL R1, R1, #16
ASR R1, R1, #16

MOV R8, #0
CMP R0, R1
MOVGT R8, #1
BL Check7th
CMP R8, R9
BEQ branchCall
BNE DonePrevInstr

Check7th:
    PUSH {R14}
    LDR R7, =Zmemory
    LDRB R9, [R7,R4]
    ADD R4, #1
    LSR R9, #7
    POP {R15}
