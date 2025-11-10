.data
menu_txt: .asciiz "\n=== Calculadora Programador Didatica ===\n1) Base 10 -> 2, 8, 16, BCD\n0) Sair\nEscolha: "
ask_dec: .asciiz "\nDigite um inteiro decimal: "
nl: .asciiz "\n"
q1hdr: .asciiz "\n[Q1] Conversoes a partir de base 10\n"
b2hdr: .asciiz "\n(a) Decimal -> Binario (mostrando divisoes):\n"
b8hdr: .asciiz "\n(b) Decimal -> Octal (mostrando divisoes):\n"
b16hdr:.asciiz "\n(c) Decimal -> Hexadecimal (mostrando divisoes):\n"
bcchdr:.asciiz "\n(d) Decimal -> BCD (nibble por digito):\n"
divfmt: .asciiz "N ="
divfmt2:.asciiz "  ->  N/base = "
divfmt3:.asciiz "  resto = "
resbin:.asciiz "Resultado (bin): "
resoct:.asciiz "Resultado (oct): "
reshex:.asciiz "Resultado (hex): "
resbcd:.asciiz "Digito "
resbcd2:.asciiz " em BCD: "
prompt_cont: .asciiz "\nPressione ENTER para continuar..."
hexchars: .asciiz "0123456789ABCDEF"
binbuf: .space 128
octbuf: .space 128
inbuf: .space 4

.text
.globl main
main:
menu_loop:
    li $v0,4
    la $a0,menu_txt
    syscall

    li $v0,5
    syscall
    move $t0,$v0

    beq $t0,$zero,exit
    beq $t0,1,do_q1
    j menu_loop

do_q1:
    li $v0,4
    la $a0,q1hdr
    syscall
    li $v0,4
    la $a0,ask_dec
    syscall
    li $v0,5
    syscall
    move $s0,$v0

    li $v0,4
    la $a0,b2hdr
    syscall
    move $a0,$s0
    li $a1,2
    jal dec_to_base_steps
    li $v0,4
    la $a0,resbin
    syscall
    move $a0,$v0
    jal print_buffer

    li $v0,4
    la $a0,b8hdr
    syscall
    move $a0,$s0
    li $a1,8
    jal dec_to_base_steps
    li $v0,4
    la $a0,resoct
    syscall
    move $a0,$v0
    jal print_buffer

    li $v0,4
    la $a0,b16hdr
    syscall
    move $a0,$s0
    li $a1,16
    jal dec_to_base_steps
    li $v0,4
    la $a0,reshex
    syscall
    move $a0,$v0
    jal print_buffer

    li $v0,4
    la $a0,bcchdr
    syscall
    move $a0,$s0
    jal print_bcd

    jal pause
    j menu_loop

pause:
    li $v0,4
    la $a0,prompt_cont
    syscall
    li $v0,8
    la $a0,inbuf
    li $a1,4
    syscall
    jr $ra

dec_to_base_steps:
    addi $sp,$sp,-24
    sw $ra,20($sp)
    sw $s0,16($sp)
    sw $s1,12($sp)
    sw $s2,8($sp)
    sw $s3,4($sp)

    move $s0,$a0
    move $s1,$a1
    la $s2,binbuf
    move $s3,$s2

    beq $s0,$zero,dtb_zero

dtb_loop:
    li $v0,4
    la $a0,divfmt
    syscall
    li $v0,1
    move $a0,$s0
    syscall
    li $v0,4
    la $a0,divfmt2
    syscall

    div $s0,$s1
    mflo $t0
    mfhi $t1

    li $v0,1
    move $a0,$t0
    syscall
    li $v0,4
    la $a0,divfmt3
    syscall
    li $v0,1
    move $a0,$t1
    syscall
    li $v0,4
    la $a0,nl
    syscall

    blt $s1,10,store_digit_dec
    la $t2,hexchars
    addu $t2,$t2,$t1
    lbu $t3,0($t2)
    sb $t3,0($s3)
    addiu $s3,$s3,1
    move $s0,$t0
    bgtz $s0,dtb_loop
    j dtb_done

store_digit_dec:
    addiu $t3,$t1,48
    sb $t3,0($s3)
    addiu $s3,$s3,1
    move $s0,$t0
    bgtz $s0,dtb_loop

dtb_done:
    sb $zero,0($s3)
    la $a0,binbuf
    jal strrev
    move $v0,$a0
    j dtb_epilogue

dtb_zero:
    la $v0,binbuf
    li $t4,'0'
    sb $t4,0($v0)
    sb $zero,1($v0)

dtb_epilogue:
    lw $ra,20($sp)
    lw $s0,16($sp)
    lw $s1,12($sp)
    lw $s2,8($sp)
    lw $s3,4($sp)
    addi $sp,$sp,24
    jr $ra

print_buffer:
    li $v0,4
    move $a0,$a0
    syscall
    li $v0,4
    la $a0,nl
    syscall
    jr $ra

strrev:
    addi $sp,$sp,-16
    sw $ra,12($sp)
    sw $s0,8($sp)
    sw $s1,4($sp)
    sw $s2,0($sp)
    move $s0,$a0
    move $s1,$a0
sr_len:
    lbu $t0,0($s1)
    beq $t0,$zero,sr_go
    addiu $s1,$s1,1
    j sr_len
sr_go:
    addiu $s1,$s1,-1
sr_swap:
    bgeu $s0,$s1,sr_done
    lbu $t1,0($s0)
    lbu $t2,0($s1)
    sb $t2,0($s0)
    sb $t1,0($s1)
    addiu $s0,$s0,1
    addiu $s1,$s1,-1
    j sr_swap
sr_done:
    lw $ra,12($sp)
    lw $s0,8($sp)
    lw $s1,4($sp)
    lw $s2,0($sp)
    addi $sp,$sp,16
    jr $ra

print_bcd:
    addi $sp,$sp,-16
    sw $ra,12($sp)
    sw $s0,8($sp)
    sw $s1,4($sp)

    move $s0,$a0
    beq $s0,$zero,pb_zero

    la $s1,octbuf
pb_loop:
    li $t0,10
    div $s0,$t0
    mflo $t1
    mfhi $t2
    addiu $t2,$t2,48
    sb $t2,0($s1)
    addiu $s1,$s1,1
    move $s0,$t1
    bgtz $s0,pb_loop
    sb $zero,0($s1)

    la $a0,octbuf
    jal strrev
    move $s0,$v0

pb_print:
    lbu $t3,0($s0)
    beq $t3,$zero,pb_end

    li $v0,4
    la $a0,resbcd
    syscall
    li $v0,11
    move $a0,$t3
    syscall
    li $v0,4
    la $a0,resbcd2
    syscall

    addiu $t3,$t3,-48
    move $a0,$t3
    jal print_bcd4
    li $v0,4
    la $a0,nl
    syscall

    addiu $s0,$s0,1
    j pb_print

pb_zero:
    li $v0,4
    la $a0,resbcd
    syscall
    li $v0,11
    li $a0,'0'
    syscall
    li $v0,4
    la $a0,resbcd2
    syscall
    li $a0,0
    jal print_bcd4
    li $v0,4
    la $a0,nl
    syscall

pb_end:
    lw $ra,12($sp)
    lw $s0,8($sp)
    lw $s1,4($sp)
    addi $sp,$sp,16
    jr $ra

print_bcd4:
    li $t0,8
    li $t1,4
    li $t2,2
    li $t3,1
    move $t4,$a0

    div $t4,$t0
    mflo $t5
    mfhi $t4
    addiu $t5,$t5,48
    li $v0,11
    move $a0,$t5
    syscall

    div $t4,$t1
    mflo $t5
    mfhi $t4
    addiu $t5,$t5,48
    li $v0,11
    move $a0,$t5
    syscall

    div $t4,$t2
    mflo $t5
    mfhi $t4
    addiu $t5,$t5,48
    li $v0,11
    move $a0,$t5
    syscall

    div $t4,$t3
    mflo $t5
    mfhi $t4
    addiu $t5,$t5,48
    li $v0,11
    move $a0,$t5
    syscall
    jr $ra

exit:
    li $v0,10
    syscall
