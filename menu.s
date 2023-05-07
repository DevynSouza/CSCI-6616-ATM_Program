.global menuRunner
.extern scanf
.extern printf

.include "fileFuncs.s"

.data
    output_account_num: .asciz "The account number you entered was: %s \n"
    balance_msg: .asciz "Your current balance is: $%s \n"
    invalid_choice_msg: .asciz "Invalid choice please try again!\n"
    input_buffer: .asciz ""
    sb1: .space 100

    dep_amount: .asciz ""
    sb6: .space 50
    dep_msg: .asciz "Please enter amount to deposit: "
    dep_msg_sz= .-dep_msg
    dep_confirm: .asciz "You are depositing: %s \n"
    dep_string_form: .asciz "%s"

    with_amount: .asciz ""
    sb10: .space 50
    with_msg: .asciz "Please enter amount to withdraw: "
    with_msg_sz= .-with_msg
    with_confirm: .asciz "You are withdrawing: %s \n"
    with_string_form: .asciz "%s"

    sb2: .space 100
    dec_format: .asciz "%d"
    sb7: .space 10
    accountNumber: .ascii ""
    sb5: .space 25

    string_format: .asciz "%s"
    welcome_msg: .asciz "Hello and welcome to the First National Bank of Devyn and Julia!\n"
    account_num_msg: .asciz "\nPlease Enter your 4 digit account number: "
    menu_msg: .asciz "Please enter a number for the selection you would like to make: \n
        1. Withdraw
        2. Deposit
        3. Choose a different Account
        4. Exit
        Selection: "
    choice_format: .asciz "%s"
    sb8: .space 100
    choice: .asciz ""
    spacer: .space 100
    balance_string: .word

    sb3: .space 100
    new_balance_string: .asciz ""
    sb9: .space 100
    new_balance_works: .asciz "Your new balance is: %s \n"
    sb4: .space 100


.text
menuRunner:
    ldr r0, =string_format
    ldr r1, =welcome_msg               @new line is required for printing
    bl printf

    @For some reason your welcome_msg seems to be getting overwritten or something? I can't print it again once we get our input

account_chooser:
    @Enter account number below with these printf and scanf together
    ldr r0, =string_format
    ldr r1, =account_num_msg              
    bl printf

    ldr r0, =string_format         @We utilize a decimal format so we can get the number without parsing user input in ascii
    ldr r1, =accountNumber         @Where we store the user's account number
    bl scanf

    @We want the account number as a string so we can look for it in our filesystem
    ldr r0, =output_account_num     @We pass the message we want to print as well as how to output it
    ldr r1, =accountNumber          @Load memory address then derefernce so we can get the correct value            
    bl printf


restart:
    @We must now locate the file based on the account
    ldr r0, =output_account_num
    ldr r1, =accountNumber      @Load memory address then derefernce so we can get the correct value            
    bl check_account            @In File Funcs
    
    @We didn't error so now we will save our balance
    ldr r0, [r0]    @Dereference the value in the address we returned from r0
    ldr r1, =balance_string 
    str r0, [r1]    @Stores the info in r1 to the balance_string

    @Now we enter menu loop
    ldr r0, =balance_msg
    ldr r1, =balance_string
    bl printf

    @We now also want to get the actual value of the balance
    @b string_to_decimal


    b menu_loop

menu_loop:  @This is where the actual menu comes into play. We probably won't deal with pins at the moment and xor them like we said

    ldr r0, =menu_msg
    bl printf


    @Format must come first then the buffer
    @This is where we choose the option
    ldr r0, =dec_format
    ldr r1, =choice
    bl scanf

@Check to see if the input is either 1,2,3,4
validity_checker:
    @This will give us the number we input
    ldr r0, =choice
    ldr r0, [r0]    @Dereference so we can get the actual number

    cmp r0, #1      @withdraw
    beq withdraw     
    cmp r0, #2      @deposit
    beq deposit    
    cmp r0, #3      @Choose different account
    beq account_chooser    
    cmp r0, #4
    beq exit  @creates an account

    ldr r0, =invalid_choice_msg
    bl printf

    
    b menu_loop   @ branches back to the menu loop to ask for user input again


deposit:

    ldr r1,=balance_string
    bl string_to_decimal

    @Our balance is returned in r8 then held in r9
    mov r9, r8  

    mov r0, #1
    ldr r1, =dep_msg
    mov r2, #dep_msg_sz
    mov r7, #4
    svc #0

    ldr r0, =dep_string_form
    ldr r1, =dep_amount
    bl scanf

    @Now we need to convert the string to decimal again
    ldr r1, =dep_amount
    bl string_to_decimal

    @Stored out updated balance in r8
    add r0, r9, r8

    bl decimal_to_string

    @r1 = newStr
    ldr r2, =new_balance_string
    ldr r1, [r1]
    str r1, [r2]

    ldr r0, =new_balance_works
    ldr r1, =new_balance_string
    bl printf

    ldr r1, =new_balance_string
    ldr r0, =accountNumber

    bl balanceWriter

    b restart

withdraw:

    ldr r1,=balance_string
    bl string_to_decimal

    @Our balance is returned in r8 then held in r9
    mov r9, r8  

    mov r0, #1
    ldr r1, =with_msg
    mov r2, #with_msg_sz
    mov r7, #4
    svc #0

    ldr r0, =with_string_form
    ldr r1, =with_amount
    bl scanf

    @Now we need to convert the string to decimal again
    ldr r1, =with_amount
    bl string_to_decimal

    @Stored out updated balance in r8
    sub r0, r9, r8

    bl decimal_to_string

    @r1 = newStr
    ldr r2, =new_balance_string
    ldr r1, [r1]
    str r1, [r2]

    ldr r0, =new_balance_works
    ldr r1, =new_balance_string
    bl printf

    ldr r1, =new_balance_string
    ldr r0, =accountNumber

    bl balanceWriter

    b restart

exit:
	mov r0, #0	@0 return code
	mov r7, #1	@Service command for exiting
	svc 0