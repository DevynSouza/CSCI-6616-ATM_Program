//R3 = Holds 10 for Mult
//R4 = Inital Load of Bit
//R8 = Holds Decimal Equivlent

.data
str: .ascii ""  // ASCII string "1234" same as user input
name: .asciz "Balance in balance Converter: %s \n"

.text
.global string_to_decimal
string_to_decimal:
    @Our balance will passed via r1 to this functino

    // Load the address of the string into r0
    ldr r0, =str
    ldr r1, [r1]
    str r1, [r0]



    // Initialize everything for sanity and testing
    mov r1, #0
    mov r3, #10
    mov r4, #0
    mov r8, #0


convert_loop:
    // Load the byte from the string into r4
    ldrb r4, [r0, r1]
    cmp r4, #110
    beq leave
    cmp r4, #0
    beq leave

    //Convert to Decimal
    sub r4, r4, #48
    mul r8, r8, r3 //10
    add r8, r8, r4
    add r1, r1, #1

    // Branch back to convert_loop
    b convert_loop

leave:
    mov r0, r8  @store the value back into r0 so it can be passed back to our menu
    bx lr

