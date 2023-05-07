.global decimal_to_string
//R0 = Holds Buffer
//R2 = Counter for 1000s
//R3 = Counter for 100s
//R4 = Counter for 10s
//R5 = Test Value Storage and 1s 

.data
str: .asciz ""

.text
decimal_to_string:
        //Set up and Throw Random Number into Register
    @We receive the balance in r0
    mov r5, r0

    mov r3, #0
    mov r2, #0
    mov r4, #0


//Literally Count 1000s
convert_1000:
        sub r5, r5, #1000
        add r2, r2, #1
        cmp r5, #1000
        bge convert_1000

//Literally Count 100s
convert_100:
        sub r5, r5, #100
        add r3, r3, #1
        cmp r5, #100
        bge convert_100

//Literally Count 10s
convert_10:
        sub r5, r5, #10
        add r4, r4, #1
        cmp r5, #10
        bge convert_10

//Convert to Hex and Load
hex_load:
        add r2, r2, #48
        add r3, r3, #48
        add r4, r4, #48
        add r5, r5, #48

        //Load Everything into Buffer
        ldr r0, =str
        strb r2, [r0], #1  // Store r2 in str and increment r0 by 1
        strb r3, [r0], #1
        strb r4, [r0], #1
        strb r5, [r0], #1

        @Loading our string so we can pass back to function
        ldr r1, =str

        bx lr