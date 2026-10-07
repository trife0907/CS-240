.data
fizztext: .asciiz "Fizz"
buzztext: .asciiz "Buzz"
fizzbuzztext: .asciiz "FizzBuzz"
newline: .asciiz "\n"

.text
.globl main

main:
li $t0, 1 # Initialize values
li $t1, 101
li $t2, 3
li $t3, 5
li $t4, 15

Loop:
j Checks

FizzBuzz:
li $v0, 4 # Print "FizzBuzz"
la $a0, fizzbuzztext
syscall
j LoopEnd

Fizz:
li $v0, 4 # Print "Fizz"
la $a0, fizztext
syscall
j LoopEnd

Buzz:
li $v0, 4 # Print "Buzz"
la $a0, buzztext
syscall
j LoopEnd

Regular:
li $v0, 1 # Print integer
move $a0, $t0
syscall
j LoopEnd

Checks:
rem $t5, $t0, $t4 # Divisible by 15
beq $t5, $zero, FizzBuzz

rem $t5, $t0, $t2 # Divisible by 3
beq $t5, $zero, Fizz

rem $t5, $t0, $t3 # Divisible by 5
beq $t5, $zero, Buzz

j Regular # Jump to Regular if integer is not divisible by 3, 5, or 15

LoopEnd:
li $v0, 4 # Print newline
la $a0, newline
syscall

addi $t0, $t0, 1
blt $t0, $t1, Loop

Exit:
li $v0, 10
syscall