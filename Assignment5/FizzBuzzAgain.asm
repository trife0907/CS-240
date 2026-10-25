.data
fizztext: .asciiz "Fizz"
buzztext: .asciiz "Buzz"
fizzbuzztext: .asciiz "FizzBuzz"
newline: .asciiz "\n"

.text
.globl main

main:
addi $t0, $zero, 1
addi $t1, $zero, 101
addi $t2, $zero, 3
addi $t3, $zero, 5
addi $t4, $zero, 15

Loop:
j Checks

FizzBuzz:
addi $v0, $zero, 4
lui $a0, 0x1001
ori $a0, $a0, 0x000A
syscall
j LoopEnd

Fizz:
addi $v0, $zero, 4
lui $a0, 0x1001
ori $a0, $a0, 0x0000
syscall
j LoopEnd

Buzz:
addi $v0, $zero, 4
lui $a0, 0x1001
ori $a0, $a0, 0x0005
syscall
j LoopEnd

Regular:
addi $v0, $zero, 1
addu $a0, $t0, $zero
syscall
j LoopEnd

Checks:
div $t0, $t4
mfhi $t5
beq $t5, $zero, FizzBuzz

div $t0, $t2
mfhi $t5
beq $t5, $zero, Fizz

div $t0, $t3
mfhi $t5
beq $t5, $zero, Buzz

j Regular

LoopEnd:
addi $v0, $zero, 4
lui $a0, 0x1001
ori $a0, $a0, 0x0013
syscall

addi $t0, $t0, 1
slt $at, $t0, $t1
bne $at, $zero, Loop

Exit:
addi $v0, $zero, 10
syscall