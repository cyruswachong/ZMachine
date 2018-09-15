.global asm_main
.align 4
Zmemory: .space 2000000
.align 4
Zstack: .space 1000000
.align 4
ZRegister: .space 1000000
.align
Ztemp: .space 256
.align
ZSpare: .space 1000000

.global switch7On
.global check
.global read
.global ResetRegisters
.global Switch7Off
.global executeZmem
.global DoneExecuting
.global debouncer
.global zeroZmem
.global deleteMem
.global Zmemory
.global Zstack
.global ZRegister
.global Ztemp
.global ZSpare
.global DonePrevInstr
.align 4


asm_main:
    LDR R0, =# 0xE0001004
    LDR R9, =# 0x020
    STR R9, [R0]
    LDR R1, =# 0xE0001018
    LDR R9, =# 62
    STR R9, [R1]
    LDR R2, =# 0xE0001034
    LDR R9, =# 6
    STR R9, [R2]
    LDR R3, =# 0xE0001000
    LDR R9, =# 0x117
    STR R9, [R3]
    MOV R4, #0
    MOV R0, #0
    MOV R1, #0
    MOV R2, #0
    MOV R3, #0
    MOV R11, #0
    LDR R7, = Zmemory
    LDR R12, = ZSpare


switch7On:
;@ TESTS IF SW7 IS CURRENTLY ON (FLIPPED UP)
    LDR R9,= 0x41220000
    LDR R8, [R9]        ;@ LOADS SWITCH VALUES INTO R8
    BL debouncer
    TST R8, #128        ;@ TESTS IF SW7 IS ON
    BNE check           ;@ IF SW7 IS ON, CHECK UART STATUS
    BEQ checkSwitch6	;@ IF SW7 IS OFF, CHECK SWITCH 6

check:
;@ TESTS VALUE OF UART, TO MAKE SURE THERE IS MEMORY TO BE READ
    LDR R9, = 0xE000102C
    LDR R8, [R9]        ;@ LOADS STATUS REG. INTO R8
    LSR R8, R8, #1      ;@ LSR TO GET BIT THAT MATTERS
    TST R8, #1          ;@ IF BIT IS 0, THERE IS MEMORY TO BE READ, IF 1, IT IS EMPTY
    BNE switch7On       ;@ If UART IS EMPTY, RECHECK SWITCH VALUE
    BEQ read            ;@ If NOT EMPTY, STORE BYTE INTO ZMEM

read:
;@ THIS VALUE READS AND STORES VALUE FROM UART TO ZMEM
    PUSH {R11}
    LDR R11, =# 0xE0001030
    LDRB R8, [R11]        ;@ LOAD VALUE FROM UART INTO R8
    STRB R8, [R7, R4]     ;@ STORE BYTE INTO OFFSET OF ZMEM
    ADD R4, R4, #1        ;@ R10 WILL BE AMOUNT OF BYTES STORED
    POP {R11}
    B check           ;@ CHECK SWITCHES
;@--------------------------------------------------------------------------------------------------------
checkSwitch6:
	LDR R9,= 0x41220000
    LDR R8, [R9]        ;@ LOADS SWITCH VALUES INTO R8
	BL debouncer
    TST R8, #64
    BNE NoHeader        ;@ IF SW7 IS ON, CHECK UART STATUS
    BEQ Header			;@ IF SW7 IS OFF, CHECK SWITCH 6

NoHeader:
BL NoHeaderLoad
B ResetRegistersNoHeader

Header:
BL HeaderLoad
B ResetRegistersHeader


ResetRegistersNoHeader:
;@ RESETS REGISTERS, CHANGES R11 TO MAX ZPC VALUE
    MOV R11, R4         ;@ MAKES R11 MAXIMUM ZPC VALUE, TO TEST WHEN ZMEM IS DONE
    MOV R4, #0
    MOV R7, #0
    MOV R8, #0
    MOV R1, #0
    B Switch7Off

ResetRegistersHeader:
    MOV R7, #0
    MOV R8, #0
    MOV R1, #0
    B Switch7Off
;@----------------------------------------------------------------------------------------------------------





Switch7Off:
;@ TESTS IF SWITCH IS OFF, COMES HERE IF SWITCH TURNS OFF
    LDR R9,=#0x41220000 ;@ LOADS SWITCH ADDRESS INTO R9
    LDR R8, [R9]        ;@ LOADS SWITCH VALUE INTO R8
    BL debouncer        ;@ DEBOUNCES
    TST R8, #128        ;@ TESTS IF SWITCH IS ON
    BNE zeroZmem        ;@ IF SWITCH TURNS BACK ON, ZERO OUT THE ZMEM, AND RETURN TO "ON"
    BEQ executeZmem     ;@ IF SWITCH IS STILL ZERO, EXECUTE CODE

executeZmem:
;@ EXECUTES STORED ZMEM VALUES
   LDR R7, = Zmemory   ;@ MAKES R7 POINT TO ZMEM ADDRESS
	BL CheckUART
	LDR R11, =#2000000
	CMP R4, R11         ;@ COMPARES ZPC TO MAX ZPC VALUE, IF THEY EQUAL, ZMEM HAS BEEN COMPLETELY RUN THROUGH
    BGE DoneExecuting   ;@ IF THEY EQUAL, LOOP AND KEEP CHECK SW7, UNTIL BACK ON
;@------------------------------------------------------------------------------------------------------------------------------------------
    ;@ THIS IS WHERE WE SHOULD OUTPUT
    PUSH {R5,R11}
	B decode
DonePrevInstr:
	POP {R5,R11}
;@------------------------------------------------------------------------------------------------------------------------------------------

    CMP R4, R11         ;@ COMPARES ZPC TO MAX ZPC VALUE, IF THEY EQUAL, ZMEM HAS BEEN COMPLETELY RUN THROUGH
    BGE DoneExecuting   ;@ IF THEY EQUAL, LOOP AND KEEP CHECK SW7, UNTIL BACK ON
    ;@ADD R4, R4, #1      ;@ INCREMENT ZPC IF NOT EQUAL
    B Switch7Off      ;@ RELOOP WITH SWITCH7OFF

DoneExecuting:
    LDR R9,=#0x41220000 ;@ LOAD SWITCH ADDRESS INTO R9
    LDR R8, [R9]        ;@ LOAD SWITCH VALUES INTO R8
    BL debouncer
    TST R8, #128        ;@ TEST TO SEE IF SW7 HAS NOW TURNED ON
    BNE zeroZmem        ;@ IF THE SWITCH GOES BACK UP, ZERO OUT MEMORY, AND RESTART
    BEQ DoneExecuting   ;@ IF SWITCH IS STILL DOWN, RELOOP AND RETEST

debouncer:
	PUSH {R14}
    PUSH {R8}           ;@ PUSH R8 TO NOT OVERWRITE VALUE
    LDR R8, =#1    		;@ DELAY LOOP VALUE (25000)
    B debounce
debounce:
    SUBS R8, R8, #1     ;@ DECREMENT DELAY LOOP VALUE
    BNE debounce        ;@ RELOOP IF STILL DELAY VALUES LEFT
    MOV R8, #0          ;@ MAKE R8 EQUAL TO 0
    POP {R8}            ;@ POP OLD VALUE OF R8
    LDR R9,=#0x41220000 ;@ LOAD SWITCHES ADDRESS INTO R9
    LDR R8, [R9]        ;@ LOAD SWITCHES VALUE INTO R8
    POP {R15}

zeroZmem:
    MOV R10, R11 ;@ LOOP VALUE TO ZERO OUT MEMORY
    MOV R11, #0
    BL deleteMem        ;@ MOVE TO DELETE MEMORY LOOP
    MOV R10, #0
    MOV R11, #0
    MOV R8, #0
    MOV R4, #0
    B switch7On         ;@ LOOP TO SWITCH ON

deleteMem:
	PUSH {R14}
    LDR R7, = Zmemory   ;@ R7 POINTS TO ZMEMORY
    LDRB R8, =0         ;@ MAKE R8 EQUAL TO 1 BYTE OF 0
    STRB R8, [R7, R11]  ;@ STORE 0 INTO EACH BIT OF ZMEMORY
    CMP R10, R11        ;@ COMPARE TO MAKE SURE WE MADE IT THROUGH ALL MEMORY
    ADD R11, R11, #1    ;@ INCREMENT R11
    BNE deleteMem       ;@ RELOOP IF NOT FINISHED
    POP {R15}

CheckUART:
	PUSH {R14}
    PUSH {R8, R9}
    LDR R9, =# 0xE000102C
    LDR R8, [R9]       ;@ Checks if UART is able to take bits of memory, or if its full
    LSR R8, #3
    TST R8, #1
    POP {R8, R9}
    BEQ CheckUART
    POP {R15}
