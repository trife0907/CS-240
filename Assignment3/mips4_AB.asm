.data
int1: .word 6 # Initialize numbers and allocate space in memory for them
int2: .word 7
sum: .word 0

.text
.globl main

main:
lw $t0, int1 # Load integers from memory
lw $t1, int2

add $t2, $t0, $t1 # Add the two integers

sw $t2, sum # Store sum to memory

li $v0, 10
syscall