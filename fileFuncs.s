.global files
.extern printf

.include "fileio.s"
.equ	BUFFERLEN, 250
.text

@R8 contains the file descriptor
@R10 contains the size of buffer read

@We will need to check to see if the account is valid and if so we will read it, else we repeat the account number
check_account:
    push {lr}   @Gotta save our original LR because printf fucks things up

    @Stores the inFile to the fileFuncs, we need to keep it handy so we can pass it for our macros
    ldr r1, [r1]    @Stores the info in the account number
    ldr r2, =inFile
    str r1, [r2]    @Stores the info in r1 to the inFile
    

    openFile inFile, O_RDONLY
    mov r8, r0
    BPL		rdfil  @ pos number file opened ok
	MOV		R1, #1  @ stdout
	LDR		R2, =inpErrsz	@ Error msg
	LDR		R2, [R2]
	writeFile	R1, inpErr, R2 @ print the error
	B		exit

rdfil:
    readFile	R8, balance, BUFFERLEN
    MOV		R10, R0	@ Keep the length read
    MOV		R1, #0	@ Null terminator for string

    ldr r0, =balance @we are loading the balance into r0 so when we go back to the menu it is available

    pop {lr}
    bx lr


balanceWriter:

    @r1 = account number
    @r0 = new balance
    
    @Delete our previous file so we can write to it
    mov r7, #10
    svc 0


    @Updates with the new balance
    ldr r1, [r1]
    ldr r2, =balance
    str r1, [r2]

    mov r0, #1
    ldr r1, =balance
    mov r2, #balancesz
    mov r7, #4
    svc 0

    @Lets update our inFile
    @ ldr r0, [r0]    @Stores the info in the account number
    @ ldr r2, =inFile
    @ str r0, [r2]    @Stores the info in r1 to the inFile

    

    @Create the file and set permission to write only
    openFile inFile, O_CREAT+O_WRONLY
    mov r9, r0      @Move our FD to r9

    @Write to our FD with the buffer and 4 bytes, can be made larger
    writeFile r9, balance, #4    @( WE CAN CHANGE THIS TO BE LARGER OR DYNAMIC BUT I'M TIRED)

    flushClose r9

    @pop {lr}
    bx lr


new_account_creator:

    @r1 = account number
    @r0 = new balance
    


    @Updates with the new balance
    ldr r1, [r1]
    ldr r2, =balance
    str r1, [r2]

    mov r0, #1
    ldr r1, =balance
    mov r2, #balancesz
    mov r7, #4
    svc 0

    @Lets update our inFile
    @ ldr r0, [r0]    @Stores the info in the account number
    @ ldr r2, =inFile
    @ str r0, [r2]    @Stores the info in r1 to the inFile

    

    @Create the file and set permission to write only
    openFile inFile, O_CREAT+O_WRONLY
    mov r9, r0      @Move our FD to r9

    @Write to our FD with the buffer and 4 bytes, can be made larger
    writeFile r9, balance, #4    @( WE CAN CHANGE THIS TO BE LARGER OR DYNAMIC BUT I'M TIRED)

    flushClose r9

    @pop {lr}
    bx lr

.data
    test_form: .asciz "Contained inside: %s \n"
    inFile: .asciz ""
    fsb2: .space 200

    balance: .asciz ""
    balancesz= .-balance
    fsb3: .space 100

    inpErr: .asciz	"Invalid account number.\n"
    inpErrsz: .word  .-inpErr 
    current_infile: .asciz "The current inFile is: %s \n"
