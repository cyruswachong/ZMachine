.global Zcalls

Zcalls:
    PUSH {R8-R12, R14}
    ADD R6, #1 ;@ add 1 to nesting depth 
    BL zeroLocals
    BL writeToFirst;@writes 2nd operand to 
    BL storeZpc
    BL writeDestination 
    
    LSL R4, R0, #2
    ADD R4, #1
    
    PUSH {R8-R12, R15}
    
    
    
zeroLocals:
    PUSH {R14}
    MOV R10, #64 ;@ 64 because every all 32 registers are 16 bits
    b zeroReg
zeroReg:
    
    LSL R11, R6, #6;@ multiply by 64
	ADD R11, R10
	LDR R12, = ZRegister
	ADD R7, R11, R12
	
	MOV R8, #0
	BL Store2Bytes
	SUBS R10, #1
	BNE zeroReg
	POPEQ {R15}
	
/*zero22ndLocal:
    LSL R11, R6, #6
	ADD R11, #44
	LDR R12,=ZRegister
	ADD R7, R11, R12
	
	MOV R8, #1
	STRH R8, [R7]
	
	B zero22ndLocal*/

writeToFirst:
    PUSH {R14}
    LSL R11, R6, #6
	LDR R12, = ZRegister
	ADD R7, R11, R12
	
	MOV R8, R1
	BL Store2Bytes
	POP {R15}
	
	
	
storeZpc:
    PUSH {R14}
    LSL R11, R6, #6
	ADD R11, #48
	LDR R12,= ZRegister
	ADD R7, R11, R12
	
	MOV R8, R4
	BL Store2Bytes
	
	POP {R15}
	
writeDestination:
    PUSH {R14}
    LSL R11, R6, #6
	ADD R11, #56
	LDR R12,=ZRegister
	ADD R7, R11, R12
	
	MOV R8, R0
	BL Store2Bytes
	
	
	
	
	
	
	
	
	
	
	
	