######         Maman 11 - Q4          #####

### Part 1
# This program reads a hex string from the user, up to 36 characters, separated by $.
# It stores the string in stringhex.

### Data Segment
.data 
stringhex: .space 37          # Space to save the user input (36 characters + null terminator)
user_input_prompt: .asciiz "Enter a hex string (max 36 characters, separated by $): "
invalid_prompt: .asciiz "Wrong input. Please try again.\n" # Error message

### Text Segment
.text
main:

get_user_input:
    li $v0, 4              # Print message to the user
    la $a0, user_input_prompt         
    syscall                   

    li $v0, 8              # Read user input
    la $a0, stringhex
    li $a1, 37             # Maximum number of characters (36 + 1 for null terminator)
    syscall

    la $a0, stringhex      # Validate input
    jal is_valid
    
    move $t0, $v0          # Store the return value of is_valid

    beq $t0, $zero, invalid_input  # If the input is invalid, print error message and prompt again

    li $v0, 10             # Exit program (for testing purposes)
    syscall

invalid_input:
    li $v0, 4              # Print error message
    la $a0, invalid_prompt
    syscall
    
    j get_user_input       # Jump to get_user_input to prompt again

### Procedure: is_valid
is_valid:
    li $t0, 0              # Initialize counters
    li $t2, 0              # Character count within current segment
    li $t3, 1              # State: 1 - expect hex, 2 - expect $

is_valid_loop:
    lb $t1, 0($a0)         # Load character
    beq $t1, $zero, is_valid_end  # If end of string, end loop

    beq $t3, 1, check_hex  # If expecting hex character, check it
    beq $t3, 2, check_dollar  # If expecting $, check it

check_hex:
    blt $t1, '0', invalid_input   # Check if the character is between '0' and '9' or 'A' and 'F'
    bgt $t1, 'F', invalid_input
    blt $t1, 'A', check_digit

    bgt $t1, '9', check_alpha

check_digit:
    addi $t2, $t2, 1       # Increment character counter in segment
    addi $a0, $a0, 1       # Move to the next character
    beq $t2, 2, set_dollar_state # If 2 characters read, expect $
    j is_valid_loop

check_alpha:
    addi $t2, $t2, 1       # Increment character counter in segment
    addi $a0, $a0, 1       # Move to the next character
    beq $t2, 2, set_dollar_state # If 2 characters read, expect $
    j is_valid_loop

set_dollar_state:
    li $t2, 0              # Reset character counter
    li $t3, 2              # Set state to expect $
    j is_valid_loop

check_dollar:
    beq $t1, '$', dollar_found  # If character is $, validate it
    j invalid_input

dollar_found:
    li $t3, 1              # Set state to expect hex character
    addi $a0, $a0, 1       # Move to the next character
    j is_valid_loop

is_valid_end:
    li $v0, 1              # Set return value to valid (1)
    jr $ra                 # Return from function

invalid_input:
    li $v0, 0              # Set return value to invalid (0)
    jr $ra                 # Return from function
