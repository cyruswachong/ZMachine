.global branchCall


branchCall:
    PUSH {R14}
    LDR R7, =Zmemory
    LDRB R8, [R7,R4]
    ADD R4, #1
    LSR R9, R8, #7
    CMP R9, #0b00000001
    BNE flipConditions
    BEQ branchLength

branchLength:
    LSR R9, R8, #6
    AND R9, #0b1
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
    LSL R9, #8
    ADD R9, R10
    BL signExtension
    ;@AND R11, R9, #0b00100000
    ;@CMP R11, #0b00100000
    ;@ADDEQ R9, #0b11000000
    ;@LSL R9, #8
    ;@ADD R9, R10
    B Zbranch

signExtension:
;@ what is this used for
    /*PUSH {R8, R10, R14}
    LSR R10, R9, #13
    AND R10, R10, #0b1
    LSL R8, R10, #14
    ADD R9, R8
    LSL R8, R10, #15
    ADD R9, R8
    SXTH R9, R9*/
    AND R11, R9, #0b00100000
    CMP R11, #0b00100000
    ADDEQ R9, #0b11000000
    LSL R9, #8
    ADD R9, R10
    POP {R8, R10, R15}

Zbranch:
    ADD R4, R4, R9
    SUB R4, #2
    POP {R15}

flipConditions:
	;@ how does this work
    LSR R9, R8, #6
    CMP R9, #0b00000001
    BNE shortBranch
    B longBranch
    ;@ Figure out what to do here
