# Bitmap Display Settings:
# Unit Width: 8
# Unit Height: 8
# Display Width: 256
# Display Height: 128
# Base Address: 0x10008000 ($gp)
# Click "Connect to MIPS" before running.
# Keep delayed branching unchecked.

.data
player: .word 0, 0, player_card
dealer: .word 0, 0, dealer_card
player_card: .asciiz "Player draws: "
dealer_card: .asciiz "Dealer draws: "
help: .asciiz "BLACKJACK\n1 = hit, 2 = stand. A printed 1 is an ace.\nBlue top bar = you; red bottom bar = dealer.\nDealer stands on 17, including soft 17.\n\n"
prompt: .asciiz "Hit (1) or stand (2)? "
invalid: .asciiz "Enter just 1 or 2.\n"
p_total: .asciiz "Your total: "
d_total: .asciiz "Dealer total: "
newline: .asciiz "\n"
win: .asciiz "You win!\n"
lose: .asciiz "Dealer wins!\n"
tie: .asciiz "Tie game!\n"
input: .space 4

.text
.globl main
main:
    li $v0, 4
    la $a0, help
    syscall
    li $s0, 2
    
initial_deal:
    la $a0, player
    jal deal_card
    la $a0, dealer
    jal deal_card
    addiu $s0, $s0, -1
    bnez $s0, initial_deal
    jal show_table
    lw $t0, player
    lw $t1, dealer
    beq $t0, 21, compare	# A two-card 21 ends the round
    beq $t1, 21, dealer_wins

player_turn:
    lw $t0, player
    beq $t0, 21, dealer_turn
    li $v0, 4
    la $a0, prompt
    syscall
    li $v0, 8
    la $a0, input
    li $a1, 4
    syscall
    lbu $t0, input
    lbu $t1, input+1
    bne $t1, 10, bad_input
    beq $t0, 50, dealer_turn	# ASCII '2' = stand
    bne $t0, 49, bad_input	# ASCII '1' = hit
    la $a0, player
    jal deal_card
    jal show_table
    lw $t0, player
    bgt $t0, 21, dealer_wins	# Player busts
    j player_turn
    
bad_input:
    li $v0, 4
    la $a0, invalid
    syscall
    j player_turn

dealer_turn:
    lw $t0, dealer
    bge $t0, 17, compare	# Stand on 17 or higher
    la $a0, dealer
    jal deal_card
    jal show_table
    j dealer_turn
    
compare:
    lw $t0, dealer
    bgt $t0, 21, player_wins	# Dealer busts
    lw $t1, player
    bgt $t1, $t0, player_wins
    blt $t1, $t0, dealer_wins
    la $a0, tie
    j finish
    
player_wins:
    la $a0, win
    j finish
    
dealer_wins:
    la $a0, lose
    
finish:
    li $v0, 4
    syscall
    li $v0, 10
    syscall

deal_card:
    move $t7, $a0
    li $v0, 42	# Random rank: 0-12, then add 1
    li $a0, 0
    li $a1, 13
    syscall
    addiu $t0, $a0, 1
    ble $t0, 10, add_card
    li $t0, 10	# Jack, queen, king are worth 10
    
add_card:
    lw $t1, 0($t7)	# Hand total
    lw $t2, 4($t7)	# Aces currently worth 11
    addu $t1, $t1, $t0
    bne $t0, 1, adjust_aces
    addiu $t1, $t1, 10	# Count the new ace as 11 initially
    addiu $t2, $t2, 1
    
adjust_aces:
    ble $t1, 21, save_hand
    beqz $t2, save_hand
    addiu $t1, $t1, -10	# Change one ace from 11 to 1
    addiu $t2, $t2, -1
    j adjust_aces
    
save_hand:
    sw $t1, 0($t7)
    sw $t2, 4($t7)
    li $v0, 4
    lw $a0, 8($t7)
    syscall
    li $v0, 1
    move $a0, $t0
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    jr $ra

show_table:
    addiu $sp, $sp, -8
    sw $ra, 4($sp)
    li $v0, 4
    la $a0, p_total
    syscall
    li $v0, 1
    lw $a0, player
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    la $a0, d_total
    syscall
    li $v0, 1
    lw $a0, dealer
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    lw $a0, player
    li $a1, 0x10008200	# Top bar: display row 4
    li $a2, 0x004488FF
    jal draw_bar
    lw $a0, dealer
    li $a1, 0x10008500	# Bottom bar: display row 10
    li $a2, 0x00FF4444
    jal draw_bar
    li $t0, 0x10008154	# Column 21, starting at row 2
    li $t1, 12	# Draw 12 units downward
    li $t2, 0x00FFFFFF	# White
    
draw_limit:
    sw $t2, 0($t0)
    addiu $t0, $t0, 128	# Move down one display row
    addiu $t1, $t1, -1
    bnez $t1, draw_limit
    lw $ra, 4($sp)
    addiu $sp, $sp, 8
    jr $ra

draw_bar:
    li $t0, 0
    
bar_loop:
    li $t1, 0
    bge $t0, $a0, paint_block
    move $t1, $a2
    
paint_block:
    sw $t1, 0($a1)
    sw $t1, 128($a1)	# Next row: 32 units * 4 bytes
    addiu $a1, $a1, 4
    addiu $t0, $t0, 1
    blt $t0, 32, bar_loop
    jr $ra
