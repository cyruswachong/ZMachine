



get20th:
	LSL R11, R6, #6
	ADD R11, #40
	LDR R12, =ZRegister
	ADD R7, R11, R12
	
	BL Load2Bytes

	B pop20thTimes
	

pop20thTimes:
	SUBS R7, #1
	BLNE ZStackPOP
	BEQ loadOldZpc
	
	

loadOldZpc:
    LSL R11, R6, #6
	ADD R11, #48
	LDR R12,=ZRegister
	ADD R7, R11, R12
	
	BL Load2Bytes
	
	MOV R4, R7;@ R7 holds the return value from Load2Bytes
	
	B check28th

check28th:
	LSL R11, R6, #6
	ADD R11, #56
	LDR R12,=ZRegister
	ADD R7, R11, R12
	
	BL Load2Bytes
	
	BL destination
	
	B decrementNesting
	
decrementNesting:
	SUB R6, #1
	B 
	






ZStackPOP:
    PUSH {R14}
	BL Load2BytesZstack
	BL decrement20th
    POP {R15}

decrement20th:
	PUSH {R7-R12,R14}
	LSL R11, R6, #6
	ADD R11, #40
	LDR R12,=ZRegister
	ADD R7, R11, R12

	BL Load2Bytes
	ADD R8, R11, R12
	SUB R7, #1
	STRH R7, [R8]


	POP {R7-R12,R15}
    
    
    
    
    
    
    
    
    
    
    
    
    