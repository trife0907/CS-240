.data
newline: .asciiz "\n" # Newline character

.text
.globl main

main:
li $t0, 1 # Iitialize start and end of loop
li $t1, 101

loop:
li $v0, 1 # Prints integer
move $a0, $t0
syscall

li $v0, 4 # Prints newline
la $a0, newline
syscall

addi $t0, $t0, 1 # Increment

blt $t0, $t1, loop # Branch 

li $v0, 10 # Exit cleanly
syscall