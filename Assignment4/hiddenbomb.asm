# Bitmap Display Settings:
# Unit Width: 32
# Unit Height: 32
# Display Width: 256
# Display Height: 256
# Base Address: 0x10008000 ($gp)
# Click "Connect to MIPS" before running.
# Keep delayed branching unchecked.

.data
board: .word 0,0,0,0,0,0,0,0,0
colors: .word 0x00333333, 0x0044CC44, 0x00FF4444
help: .asciiz "AVOID THE BOMB\nReveal 5 safe squares to win!\nChoose a square and press Enter:\n1 2 3\n4 5 6\n7 8 9\n\n"
prompt: .asciiz "Choose a square (1-9): "
invalid: .asciiz "Invalid move. Enter 1-9 and choose an unopened square.\n"
score: .asciiz "Safe squares found: "
newline: .asciiz "\n"
win: .asciiz "You win!\n"
lose: .asciiz "BOOM! You hit the bomb. Game over.\n"
input: .space 4

.text
.globl main
main:
    li $v0, 42	# Random bomb index, 0-8
    li $a0, 0
    li $a1, 9
    syscall
    move $s0, $a0	# Keep bomb location separate from board
    li $s1, 0	# Number of safe squares found
    li $v0, 4
    la $a0, help
    syscall
    jal draw_board

turn:
    jal get_move	# Returns an unopened index in $v0
    beq $v0, $s0, hit_bomb
    sll $t0, $v0, 2
    la $t1, board
    addu $t1, $t1, $t0
    li $t2, 1
    sw $t2, 0($t1)	# Mark this cell safe (green)
    addiu $s1, $s1, 1
    jal draw_board
    li $v0, 4
    la $a0, score
    syscall
    li $v0, 1
    move $a0, $s1
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    beq $s1, 5, won
    j turn

won:
    la $s3, win
    j finish
    
hit_bomb:
    la $s3, lose
    
finish:
    sll $t0, $s0, 2
    la $t1, board
    addu $t1, $t1, $t0
    li $t2, 2
    sw $t2, 0($t1)	# Reveal the bomb in red
    jal draw_board
    li $v0, 4
    move $a0, $s3
    syscall
    li $v0, 10
    syscall

get_move:
    li $v0, 4
    la $a0, prompt
    syscall
    li $v0, 8
    la $a0, input
    li $a1, 4
    syscall
    lbu $t0, input
    addiu $t0, $t0, -49	# ASCII '1' -> index 0
    bltz $t0, bad_move
    bgt $t0, 8, bad_move
    lbu $t1, input+1
    bne $t1, 10, bad_move	# Only one digit followed by Enter
    sll $t1, $t0, 2
    la $t2, board
    addu $t2, $t2, $t1
    lw $t3, 0($t2)
    bnez $t3, bad_move	# Already revealed
    move $v0, $t0
    jr $ra
    
bad_move:
    li $v0, 4
    la $a0, invalid
    syscall
    j get_move

draw_board:
    addiu $sp, $sp, -8
    sw $ra, 4($sp)
    sw $s2, 0($sp)
    li $t0, 0x10008000
    li $t1, 64
    
clear:
    sw $zero, 0($t0)
    addiu $t0, $t0, 4
    addiu $t1, $t1, -1
    bnez $t1, clear
    li $s2, 0
    
paint:
    sll $t0, $s2, 2
    la $t1, board
    addu $t1, $t1, $t0
    lw $t0, 0($t1)
    sll $t0, $t0, 2
    la $t1, colors
    addu $t1, $t1, $t0
    lw $a1, 0($t1)	# Color for this cell's value
    li $t0, 3
    divu $s2, $t0
    mflo $t1	# Row = index / 3
    mfhi $t2	# Column = index % 3ww
    mul $t1, $t1, 24	# Each tile row starts 3*8 units lower
    mul $t2, $t2, 3	# Each column starts 3 units farther right
    addu $t1, $t1, $t2
    sll $t1, $t1, 2	# Convert unit index to byte offset
    li $a0, 0x10008000
    addu $a0, $a0, $t1
    jal draw_tile
    addiu $s2, $s2, 1
    blt $s2, 9, paint
    lw $s2, 0($sp)
    lw $ra, 4($sp)
    addiu $sp, $sp, 8
    jr $ra

draw_tile:
    sw $a1, 0($a0)
    sw $a1, 4($a0)
    sw $a1, 32($a0)
    sw $a1, 36($a0)
    jr $ra
