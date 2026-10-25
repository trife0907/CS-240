.data
.byte 70
.byte 105
.byte 122
.byte 122
.byte 0
.byte 66
.byte 117
.byte 122
.byte 122
.byte 0
.byte 70
.byte 105
.byte 122
.byte 122
.byte 66
.byte 117
.byte 122
.byte 122
.byte 0
.byte 10
.byte 0

.text
.globl main
main:
addi $t0, $zero, 1
addi $t1, $zero, 101
addi $t2, $zero, 3
addi $t3, $zero, 5
addi $t4, $zero, 15
L_00400014:
j L_00400064
L_00400018:
addi $v0, $zero, 4
lui $a0, 4097
ori $a0, $a0, 10
syscall
j L_0040008C
L_0040002C:
addi $v0, $zero, 4
lui $a0, 4097
ori $a0, $a0, 0
syscall
j L_0040008C
L_00400040:
addi $v0, $zero, 4
lui $a0, 4097
ori $a0, $a0, 5
syscall
j L_0040008C
L_00400054:
addi $v0, $zero, 1
addu $a0, $t0, $zero
syscall
j L_0040008C
L_00400064:
div $t0, $t4
mfhi $t5
beq $t5, $zero, L_00400018
div $t0, $t2
mfhi $t5
beq $t5, $zero, L_0040002C
div $t0, $t3
mfhi $t5
beq $t5, $zero, L_00400040
j L_00400054
L_0040008C:
addi $v0, $zero, 4
lui $a0, 4097
ori $a0, $a0, 19
syscall
addi $t0, $t0, 1
slt $at, $t0, $t1
bne $at, $zero, L_00400014
addi $v0, $zero, 10
syscall
