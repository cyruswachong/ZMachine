.global HeaderLoad
.global NoHeaderLoad

HeaderLoad:
PUSH {R9, R10, R12, R14}
LDR R1, = ZSpare

LoadObjTable:
;@ LOADS 16 BIT NUMBER INTO R7 FROM 0x0A (OBJECT TABLE)
LDR R7, = Zmemory
	LDRB R9, [R7, #0x0A]
	LSL R9, #8
	LDRB R10, [R7, #0x0B]
	ADD R7, R9, R10
	STR R7, [R1]                ;@ store object table location (in header at offset 0x0A)

LoadZRegLocation:
;@ LOADS 16 BIT NUMBER INTO R7 FROM 0x0C (LOC OF ZREG)
LDR R7, = Zmemory
	LDRB R9, [R7, #0x0C]
	LSL R9, #8
	LDRB R10, [R7, #0x0D]
	ADD R7, R9, R10
	STR R7, [R1, #10]           ;@ store Global ZReg location

LoadZPC:
LDR R7, = Zmemory
	LDRB R9, [R7, #4]
	LSL R9, #8
	LDRB R10, [R7, #5]
	ADD R7, R9, R10
	ADD R11, R7, R4
	MOV R4, R7
	LDR R7, = Zmemory
	POP {R9, R10, R12, R15}



NoHeaderLoad:
PUSH {R8-R12, R14}
LDR R1, = ZSpare

LoadObjtable1:
    LDR R8, =#0x1000
	STR R8, [R1]

LoadZRegLocation1:
	LDR R8, =#0x4000
	STR R8, [R1, #10]

LDR R7, = Zmemory
POP {R8-R12, R15}
