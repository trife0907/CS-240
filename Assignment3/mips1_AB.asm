.data
greeting: .asciiz "Hello World\n" # Our variable

.text
.globl main

main:
li $v0, 4 # Print a string
la $a0, greeting
syscall

li $v0, 10 # Exit cleanly
syscall