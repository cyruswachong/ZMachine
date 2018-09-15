.global checkRegisterType



checkRegisterType:
    PUSH {R8-R12,R14}
    CMP R7, #0xff
    CMPLT R7, #0x10
    BGE globalIndicator
    CMP R7, #0x0f
    CMPLT R7, #0x01
    BGE localIndicator
    B ZStackIndicator

globalIndicator:
    LDR R8, = Zmemory     ;@R9 is the address of the global ZRegisters and will change depending on Header mode
    LDR R11, = ZSpare
    LDR R11, [R11, #10]
    ADD R8, R8, R11;@ no header mode
    SUB R7, #16
    LSL R7, #1              ;@ A: This is where your Zregister is located within the set ofglobal Zregisters.
    ADD R7, R8
    BL Load2Bytes
    POP {R8-R12, R15}

localIndicator:
    ;@ For A: This is where your Zregister is located within the set of 32 Zregisters for a given Zprocedure.
    LDR R11, = ZRegister
    SUB R8, R7, #1
    LSL R8, #1
    ;@ For B: Gives you the offset of your current Zprocedure’s Zregisters within your Zregister area.
    LSL R9, R6, #6 ;@ R6 is nesting depth
    ;@ For C: Gives you an offset of your Zregister in question within your your local Zregister memory.
    ADD R10, R8, R9
    ADD R7, R10, R11  ;@ R11 is the location of your Zprocedure local Zregisters.
                      ;@ This is the address of the high-order byte of your Zregister.
                      ;@ The next byte is the low-order byte of your Zregister.
    BL Load2Bytes
    POP {R8-R12, R15}
    ;@ might have to pop here to restore registers

;@POSSIBLE ZSTACK FUNCTIONS

ZStackIndicator:
    LDR R9, = Zstack
    BL ZStackPOP
    MOV R7, R8
    POP {R8-R12, R15}

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
