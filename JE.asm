JE:
    MOV R8, #0
    CMP R0, R1
    MOVEQ R8, #1
    BL check7th
    CMP R8, R9
    BLEQ branchLength
    
    
check7th:
    PUSH {R14}
    LDR R7, =Zmemory
    LDRB R9, [R7,R4]
    ADD R4, #1
    LSR R9, #7
    POP {R15}
    
/*branchCall:
    PUSH {R14}
    LDR R7, =Zmemory
    LDRB R8, [R7,R4]
    ADD R4, #1
    LSR R9, R8, #7
    CMP R9, #0b00000001
    BNE flipConditions
    B branchLength*/
    
branchLength:
    PUSH {R14}
    LSR R9, R8, #6
    CMP R9, #0b00000001
    BEQ shortBranch
    B longBranch

shortBranch:
    AND R9, R8, #0b00111111
    CMP R9, #0
    BEQ returnZero
     CMP R9, #1
    BEQ returnOne
    B Zbranch

returnZero:
    MOV R12, #0
    POP {R15}
    
returnOne:
    MOV R12, #1
    POP {R15}


longBranch:
    LDRB R10, [R7,R4];@ load second offset byte
    ADD R4, #1
    AND R9, R8, #0b00111111
    AND R11, R9, #0b00100000
    CMP R11, #0b00100000
    ADDEQ R9, #0b11000000
    LSL R9, #8
    ADD R9, R10
    ADD R4, R4, R9
    SUB R4, #2
    POP {R15}
    ;@ not sure what to do
