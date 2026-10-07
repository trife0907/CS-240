.data
title: .asciiz "Sum of even integers from 1 through 100:\n"

.text
.globl main

main:
li $v0, 4 # Print title text
la $a0, title
syscall

li $t0, 1 # Initalize start and end of loop
li $t1, 101
li $t3, 0 # Initialize sum to zero

loop:
andi $t2, $t0, 1 # Determine if $t0 is even using bitwise AND (even == 0)
beq $t2, $zero, even # If equal(even), branch to even
j end # Otherwise, jump to end

even:
add $t3, $t3, $t0 # Sum the even numbers

end:
addi $t0, $t0, 1 # Increment loop
blt $t0, $t1, loop # Branch condition

li $v0, 1 # Print final sum
move $a0, $t3
syscall

li $v0, 10
syscall