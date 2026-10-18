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
lines: .word 0,1,2, 3,4,5, 6,7,8 # Rows
       .word 0,3,6, 1,4,7, 2,5,8 # Columns
       .word 0,4,8, 2,4,6 # Diagonals
colors: .word 0x00333333, 0x00FF4444, 0x004488FF

prompts: .word x_prompt, o_prompt
x_prompt: .asciiz "X (red), choose a square (1-9): "
o_prompt: .asciiz "O (blue), choose a square (1-9): "
invalid: .asciiz "Invalid move. Enter 1-9 and choose an empty square.\n"
x_win: .asciiz "X wins!\n"
o_win: .asciiz "O wins!\n"
tie: .asciiz "Tie game!\n"
help: .asciiz "TIC-TAC-TOE\nSquare numbers:\n1 2 3\n4 5 6\n7 8 9\n\n"
input: .space 4

.text
.globl main

main:
    li $s0, 1 	# Current player: 1 = X, 2 = O
    li $s1, 0 	# Number of successful moves
    li $v0, 4
    la $a0, help
    syscall
    jal draw_board

turn:
    move $a0, $s0
    jal get_move	# Returns an empty index in $v0
    sll $t0, $v0, 2 	# Array index * 4 bytes
    la $t1, board
    addu $t1, $t1, $t0
    sw $s0, 0($t1)
    addiu $s1, $s1, 1
    jal draw_board
    jal check_winner 	# Returns 0, 1 (X), or 2 (O)
    bnez $v0, won
    beq $s1, 9, tied
    li $t0, 3
    subu $s0, $t0, $s0 # Switch 1 to 2, or 2 to 1
    j turn
    
won:
    la $a0, x_win
    beq $v0, 1, finish
    la $a0, o_win
    j finish
    
tied:
    la $a0, tie

finish:
    li $v0, 4
    syscall
    li $v0, 10
    syscall

get_move:
    addiu $t0, $a0, -1
    sll $t0, $t0, 2
    la $t1, prompts
    addu $t1, $t1, $t0
    lw $t7, 0($t1)	# Keep the current player's prompt

ask:
    li $v0, 4
    move $a0, $t7
    syscall
    li $v0, 8
    la $a0, input
    li $a1, 4
    syscall
    lbu $t0, input
    addiu $t0, $t0, -49 # ASCII '1' becomes index 0
    bltz $t0, bad_move
    bgt $t0, 8, bad_move
    lbu $t1, input+1
    bne $t1, 10, bad_move # The digit must be followed by Enter
    sll $t1, $t0, 2
    la $t2, board
    addu $t2, $t2, $t1
    lw $t3, 0($t2)
    bnez $t3, bad_move	# Reject an occupied square
    move $v0, $t0
    jr $ra
    
bad_move:
    li $v0, 4
    la $a0, invalid
    syscall
    j ask

check_winner:
    la $t0, lines
    li $t1, 8
    la $t2, board
    
check_line:
    lw $t3, 0($t0)
    sll $t3, $t3, 2
    addu $t3, $t2, $t3
    lw $t4, 0($t3)
    beqz $t4, next_line	# Three empty cells are not a win
    lw $t3, 4($t0)
    sll $t3, $t3, 2
    addu $t3, $t2, $t3
    lw $t5, 0($t3)
    bne $t4, $t5, next_line
    lw $t3, 8($t0)
    sll $t3, $t3, 2
    addu $t3, $t2, $t3
    lw $t5, 0($t3)
    bne $t4, $t5, next_line
    move $v0, $t4
    jr $ra

next_line:
    addiu $t0, $t0, 12	# Next group of three words
    addiu $t1, $t1, -1
    bnez $t1, check_line
    li $v0, 0
    jr $ra
    
draw_board:
    addiu $sp, $sp -8
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
    mfhi $t2	# Column = index % 3
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
