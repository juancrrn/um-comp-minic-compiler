	.data
$str1:
	.asciiz "Inicio del programa\n"
$str2:
	.asciiz "Introduce el valor de \"c\":\n"
$str3:
	.asciiz "\"c\" no era nulo."
$str4:
	.asciiz "\n"
$str5:
	.asciiz "\"c\" si era nulo."
$str6:
	.asciiz "\"d\" vale"
$str7:
	.asciiz "\"e\" vale"
$str8:
	.asciiz "Final"
_a:
	.word 0
_b:
	.word 0
_c:
	.word 0
_d:
	.word 0
_e:
	.word 0

	.text
	.globl main

main:
	li $t0, 1
	sw $t0, _a
	li $t0, 2
	li $t1, 3
	mul $t2, $t0, $t1
	sw $t2, _b
	li $t0, 5
	li $t1, 2
	add $t2, $t0, $t1
	sw $t2, _d
	li $t0, 9
	li $t1, 3
	div $t2, $t0, $t1
	sw $t2, _e
	la $a0, $str1
	li $v0, 4
	syscall
	la $a0, $str2
	li $v0, 4
	syscall
	li $v0, 5
	syscall
	sw $v0, _c
	lw $t0, _c
	beqz $t0, $l1
	la $a0, $str3
	li $v0, 4
	syscall
	la $a0, $str4
	li $v0, 4
	syscall
	b $l2
$l1:
	la $a0, $str5
	li $v0, 4
	syscall
	la $a0, $str4
	li $v0, 4
	syscall
$l2:
$l3:
	lw $t0, _d
	beqz $t0, $l4
	la $a0, $str6
	li $v0, 4
	syscall
	lw $t1, _d
	move $a0, $t1
	li $v0, 1
	syscall
	la $a0, $str4
	li $v0, 4
	syscall
	lw $t1, _d
	li $t2, 1
	sub $t3, $t1, $t2
	sw $t3, _d
	b $l3
$l4:
$l5:
	la $a0, $str7
	li $v0, 4
	syscall
	lw $t0, _e
	move $a0, $t0
	li $v0, 1
	syscall
	la $a0, $str4
	li $v0, 4
	syscall
	lw $t0, _e
	li $t1, 1
	sub $t2, $t0, $t1
	sw $t2, _e
	lw $t0, _e
	bnez $t0, $l5
	la $a0, $str8
	li $v0, 4
	syscall
	la $a0, $str4
	li $v0, 4
	syscall

	jr $ra
